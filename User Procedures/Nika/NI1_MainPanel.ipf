#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method.
//#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.66
Constant NI1AversionNumber = 2.66

//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.66 added UseBatchProcessing to prevent graphs from being displays to speed up processing of large number of images. 
//2.65 fixes for rtGlobal=3, changed Nika GSAS outptu file to xye instead of GSA. xye is better. 
//2.64 removed mar345 and Fit2D support, let's see if someone complains. 
//2.63 added Circular Q axes. 
//2.62 fix bug in Igor 8 which causes hang of the window. Panel made wider. 
//2.61 Fixed normalization bug which causes spike in intensity on our WAXS data (+1 missing Intensity normalization)
//			added Reprocess curren data and modified panel as needed.   
//2.60 added controls for delay between images and for statitics calculation
//2.59 Modified GUI on main panel to have selection of actions chose with radiobuttons and only one "Process data" button. Cleaner/simple to read interface. 
//2.58 added UserSampleName to each folder. To be used in other functions to avoid 32 characters limit. 
//2.57 changed trimname function to accept maximum possible number of characters allowed with _XYZ orientation. Will vary based on orientation now, _C will allow 25 characters. Others will be shorter. 
//2.56 added resize after recreating of the panels to prior user size. 
//2.55 removed unused functions
//2.54 Fixed bug where Fit2D loadable types were listed on incompatible versions of MacOS. 
//2.53 Modified Screen Size check to match the needs
//2.52	added getHelp button calling to www manual
//2.51 Fixed old bug where sample thickness was not converted to cm before use and used as mm. This causes old experiments with old calibration constants to be wrong.
//			old calibration constatnts need to be also scaled by 10 to fix the calibration. 
//			added a lot of 	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//2.49 Nexus input output fixes. 
//2.48 changed pinSAXS to SAXS
//2.47 changed length of name to 23 characters from 17
//2.47 fixes for WIndows panel resizing. 
//2.46 added Function for creating user custom data names
//2.45 added Scaling of panels when zoomed. 
//2.44 added Q smearing controls 
//2.43 added ability to type in Q distance from center for line profile. Is rounded to nearest full pixel. 
//2.42 added GISAXS geomtry variations which require additional panel. version 1.68 of Nika
//2.41 removed Executes in preparation fro igor 7
//2.40 fixed Azimuthal profile ASCII data saving feature. Final sorting was incorrect (bug). 
//2.39 added ADSC_A (wavelength in A) as option
//2.38 moved Dezinering on tab2. 
//2.38 Fixed naming of data when more then one "." is present in the name. It is now allowed on USAXS instrument.
//2.37 Modifications needed for 2D calibrated data input/output, added Append to Nexus file (2D data for now).  
//2.36 changed name of main panel function. Added hook functions. Modified code to remove extension from loaded file name for use as name of data later. 
//2.35 fixed /NTHR=1 to /NTHR=0, major changes supporting export of 2D calibrated data
//2.34 added possibility of importing 2DCalibrated data (EQSANS). 
//2.33 fixed bug in LP profille wave names for notes addition. 
//2.32 adds DataCalibrationStgring to data and GUI
//2.31 added *.maccd and combined all mpa formats into one loader (*.mpa). Have 4 versions of this format, three I had working versions, csv I did tno. SO the three are loaded, csv gives error. 
//2.30 added move up down controls for small screens
//2.29 updated graphs so they will not plot same data multiple times and changed where 9IDC data are stored.
//2.28 fixed bug in line profile ASCII export causing problem with data expoort for line and no names of waves being exported. 
//2.27 adds TPA/XML data file
//2.26 adds SSRLMatSAXS, fixed export of Ellipse data, fixed debugger in case movie was closed with no frames. 
//2.25 added User defined Min/max and Color scale display
//2.24 added export as distance from center, requested feature, added chack for updated Nika version for main panel and forced update on user. 
//2.23 support for display line profile with azimuthal angle for ellipse
//2.22 added option to create Movies from either images (RAW/Corrected) or 1D data lineouts
//2.21 modified saving data - now when error from ImageLineProfile is NaN, it is replaced by 0 so even data with no error are saved. Also, sorted output waves to start from low q values
//2.20  fix to automatic conversion for GI_Vertical line which was failing due to typo. 
//2.19 fixes to tilts and some other minor improvements
//2.18 added BSL changes per JOSH requests
//2.17 added mutlithread and MatrixOp/NTHR=1 where seemed possible to use multile cores
//2.16 added license for ANL
//version 2.0 adds 2D polarization support, ability to display raw or processed data
//version 2.1 adds GISAXS support	???
//version 2.11 adds compoinents for Pilatus loaders. 
//version 2.12 adds ESRF edf file format 
//version 2.13 adds ability to display image with Q axes
//version 2.14 - added match strings to Sample and empty/dark names 
//version 2.15 adds mpa/UC file type
//version 2.16 adds FITS file format and ANL license 

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//****************************************************************************************
//****************************************************************************************
//****************************************************************************************

//static Function AfterCompiledHook( )			//check if all windows are up to date to match their code
//
//	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//	//these are tools which have been upgraded to this functionality
//	//Modeling II = LSQF2_MainPanel
//	string WindowProcNames="NI1A_Convert2Dto1DPanel=NI1A_MainCheckVersion;NI1_CreateBmCntrFieldPanel=NIBC_MainCheckVersion;NEXUS_ConfigurationPanel=Nexus_MainCheckVersion;"
//	
//	NI1A_CheckWIndowsProcVersions(WindowProcNames)
//	IN2G_ResetSizesForALlPanels(WindowProcNames)
//
//end 
//****************************************************************************************
//****************************************************************************************

Function NI1A_CheckWIndowsProcVersions(WindowProcNames)
	string WindowProcNames
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i 
	string PanelName
	String ProcedureName
	For(i=0;i<ItemsInList(WindowProcNames);i+=1)
		PanelName = StringFromList(0, StringFromList(i, WindowProcNames, ";")  , "=")
		ProcedureName = StringFromList(1, StringFromList(i, WindowProcNames, ";")  , "=")
		DoWIndow $(PanelName)
		if(V_Flag)
			Execute (ProcedureName+"()") 
		endif
	endfor
end 
//*****************************************************************************************************************
//*****************************************************************************************************************

Function NI1A_MainCheckVersion()	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DoWindow NI1A_Convert2Dto1DPanel
	variable OldNikaVersion
	if(V_Flag)
		//calibration warning...
		GetWindow NI1A_Convert2Dto1DPanel, note
		OldNikaVersion = NumberbyKey("NikaProcVersion",S_value)
		if(OldNikaVersion<2.51)
			DoAlert/T="Important warning if you use absolutely calibrated data" 0, "Nika Version 1.75 corrected bug where Sample thickness for earlier versions was not converted to cm before use. You are using Nika setup created on old experiment, your calibration constant may need to be changed, see history for details. "
			string tempStr="*****    Important warning if you use absolutely calibrated data.   *******\r"
			tempStr +="Nika Version 1.75 corrected bug where Sample thickness for earlier versions was not converted to cm before use.\r"
			tempStr +="This typically canceled out during calibration standard data reduction as standard thickness was similary used as mm and the bug cancelled out.\r"
			tempStr +="But, you are using old experiment created on old Nika version, existing calibration constant may now need to be changed by factor of 10 to correct for this.\r"
			tempStr +="*****   Please, revise and double-check your calibration carefully!!!   ******\r"
			print tempStr
		endif
		if(!NI1_CheckPanelVersionNumber("NI1A_Convert2Dto1DPanel", NI1AversionNumber))
			DoAlert /T="The Nika main panel was created by incorrect version of Nika " 1, "Nika needs to be restarted to work properly. Restart now?"
			if(V_flag==1)
				NI1A_Convert2Dto1DMainPanel()
			else		//at least reinitialize the variables so we avoid major crashes...
				NI1A_Initialize2Dto1DConversion()
			endif
		endif
	endif
end
//*********************************************************** 
//***********************************************************
//***********************************************************
Function NI1_UpdatePanelVersionNumber(panelName, CurentProcVersion)
	string panelName
	variable CurentProcVersion
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DoWIndow $panelName
	if(V_Flag)
		GetWindow  $(panelName) note
		SetWindow $(panelName), note=S_Value+"NikaProcVersion:"+num2str(CurentProcVersion)+";"
		IN2G_PanelAppendSizeRecordNote(panelName)
		SetWindow $panelName,hook(ResizePanelControls)=IN2G_PanelResizePanelSize
		IN2G_ResetPanelSize(panelName,1)
		STRUCT WMWinHookStruct s
		s.eventcode=6
		s.winName=panelName
		IN2G_PanelResizePanelSize(s)
		//print "Done resizing"
	endif
end 

//***********************************************************
//*********************************************************** 
Function NI1_CheckPanelVersionNumber(panelName, CurentProcVersion)
	string panelName
	variable CurentProcVersion

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DoWIndow $panelName
	if(V_Flag)	
		GetWindow $(panelName), note
		if(stringmatch(stringbyKey("NikaProcVersion",S_value),num2str(CurentProcVersion))) //matches
			return 1
		else
			return 0
		endif
	else
		return 1
	endif
end
 
//***********************************************************
//***********************************************************
//***********************************************************

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_Convert2Dto1DMainPanel()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//first initialize 
	NI1A_Initialize2Dto1DConversion()
	IN2G_CheckScreenSize("height",740)
	KillWIndow/Z NI1A_Convert2Dto1DPanel
 	NI1A_Convert2Dto1DPanelFnct()
	NI1A_TabProc("nothing",0)
	NI1_UpdatePanelVersionNumber("NI1A_Convert2Dto1DPanel", NI1AversionNumber)
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
 
Function NI1A_Initialize2Dto1DConversion()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=GetDataFolder(1)
	variable FirstRun
	if(!DataFolderExists("root:Packages:Convert2Dto1D"))
		FirstRun=1
	endif
	
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:Convert2Dto1D

	//internal loaders
	string/g ListOfKnownExtensions=".tif;GeneralBinary;Pilatus;Nexus;BrukerCCD;MarCCD;mpa;mp/bin;BSRC/Gold;DND/txt;RIGK/Raxis;ADSC;ADSC_A;WinView spe (Princeton);ASCII;ibw;BSL/SAXS;BSL/WAXS;ascii512x512;ascii128x128;ESRFedf;"
	ListOfKnownExtensions+="SSRLMatSAXS;TPA/XML;Fuji/img;mpa/UC;FITS;.hdf;GE binary;---;"//mpa/bin;mpa/asc;mp/bin;mp/asc
//#if(Exists("ccp4unpack"))	
//	ListOfKnownExtensions+="MarIP/xop;"
//#endif
	//add Fit2D known types of PC 
	//tif					tif file
	//GeneralBinary		configurable binary loader using GBLoadWave
	//Pilatus 				readers for various Pilatus files. tiff and edf tested, for now 100k Pilatus only. 
	//BrukerCCD			bruker SMART software for CCD
	//mpa				The software is  MPA-NT (or just MPANT),  version 1.48.
						//It is from FAST ComTec, a German company that supplies multi-channel, multiparameter data collection and analysis tools.
						//The hardware I am using is the MPA-3 Dual-parameter multichannel analyzer (from FAST ComTec).
						//That hardware provides the interface to multiwire 2D gas-filled X-ray detector from Molecular Metrology (recently purchased by Rigaku/Osmic).
	//mp/bin				mp binary format. for software producing mpa files above, removed
	//mp/asc				mp ascii format, same as above, removed
	//BSRC/Gold			BESSERC 1536x1536 Gold detector binary format. It has header and 16 bit binary data
	//ASCII 				ASCII data matrix...
	//      note, if the ASCII data matrix has extension mtx, then will try to find same file with extension prn and read header info from there...
//	variable OSXVersion = str2num(StringFromList(0, StringByKey("OSVERSION",IgorInfo(3),":",";"),".")+"."+StringFromList(1, StringByKey("OSVERSION",IgorInfo(3),":",";"),"."))
// 	if(cmpstr(IgorInfo(2),"Windows")==0 || (OSXVersion>10.2 && OSXVersion<10.5))
//		ListOfKnownExtensions+="MarIP/Fit2d;ADSC/Fit2D;Bruker/Fit2D;BSL/Fit2D;Diffract/Fit2D;DIP2000/Fit2D;"		
//		ListOfKnownExtensions+="ESRF/Fit2d;Fit2D/Fi2tD;BAS/Fit2D;GAS/Fit2D;HAMA/Fit2D;IMGQ/Fit2D;"		
//		ListOfKnownExtensions+="KLORA/Fit2d;MarPck/Fi2tD;PDS/Fit2D;PHOTOM/Fit2D;PMC/Fit2D;PRINC/Fit2D;RIGK/Fit2D;"		
//	endif
//	ADSC		ADSC Detector Format : Keyword-value header and binary data
//	Bruker		Bruker format : Bruker area detector frame data format
//	BSL			BSL format : Daresbury SAXS format, based on Hmaburg format
//	Diffract		Compressed diffraction data : Compressed diffraction data
//	DIP2000		DIP-2000 (Mac science) : 2500*2500 Integer*2 special format
//	ESRF		ESRF Data format : ESRF binary, self describing format
//	Fit2D		Fit2D standard format: Self describing readable binary
//	BAS		FUJI BAS-2000 : Fuji image plate scanners (aslo BAS-1500)
//	GAS		GAS 2-D Detector (ESRF) : Raw format used on the beam-lines
//	HAMA		HAMAMATSU PHOTONICS : C4880 CCD detector format
//	IMGQ		IMAGEQUANT : Imagequant TIFF based format (molecular dynamics)
//	KLORA		KLORA : Simplified sub-set of "EDF" written by Jorg Klora
//	MarIP		MAR RESEARCH FORMAT : "image" format for on-line IP systems
//	MarPck		MAR-PCK FORMAT : Compressed old Mar format
//	MarIP		NEW MAR CODE : Same as MAR RESEARCH FORMAT
//	PDS		PDS FORMAT : Powder diffraction standard format file
//	PHOTOM		PHOTOMETRICS CCD FORMAT : X-ray image intensifier system
//	PMC		PMC Format : Photometrics Compressed XRII/CCD data
//	PRINC		PRINCETON CCD FORMAT :X-ray image intensifier system
//	RIGK		RIGAKU R-AXIS : Riguka image plate scanner format

	//Calibrated data In and Out
	string/g ListOfKnownCalibExtensions="canSAS/Nexus;EQSANS400x400;NIST_DAT_128x128;"
	string/g ListOfOutCalibExtensions="canSAS/Nexus;EQSANS400x400;"

	string/g ListOfVariables
	string/g ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="BeamCenterX;BeamCenterY;QvectorNumberPoints;QvectorMaxNumPnts;QbinningLogarithmic;SampleToCCDDistance;Wavelength;"
	ListOfVariables+="PixelSizeX;PixelSizeY;StartDataRangeNumber;EndDataRangeNumber;XrayEnergy;HorizontalTilt;VerticalTilt;AzimuthalTilt;"
	ListOfVariables+="BeamSizeX;BeamSizeY;"
	ListOfVariables+="UseBatchProcessing;"
	ListOfVariables+="DelayBetweenImages;CalculateStatistics;"
	ListOfVariables+="SampleThickness;SampleTransmission;UseI0ToCalibrate;SampleI0;EmptyI0;"
	ListOfVariables+="UseSampleThickness;UseSampleTransmission;UseI0ToCalibrate;UseSampleI0;UseEmptyI0;"
	ListOfVariables+="UseCorrectionFactor;UseMask;UseDarkField;UseEmptyField;UseSubtractFixedOffset;SubtractFixedOffset;UseSolidAngle;"
	ListOfVariables+="UseSampleMeasTime;UseEmptyMeasTime;UseDarkMeasTime;UsePixelSensitivity;UseMonitorForEF;"
	ListOfVariables+="SampleMeasurementTime;BackgroundMeasTime;EmptyMeasurementTime;"
	ListOfVariables+="CorrectionFactor;DezingerRatio;DezingerCCDData;DezingerEmpty;DezingerDarkField;DezingerHowManyTimes;"
	ListOfVariables+="DoCircularAverage;StoreDataInIgor;ExportDataOutOfIgor;Use2DdataName;DisplayDataAfterProcessing;"
	ListOfVariables+="DoSectorAverages;NumberOfSectors;SectorsStartAngle;SectorsHalfWidth;SectorsStepInAngle;"
	ListOfVariables+="ImageRangeMin;ImageRangeMax;ImageRangeMinLimit;ImageRangeMaxLimit;ImageDisplayLogScaled;UserImageRangeMin;UserImageRangeMax;UseUserDefMinMax;"
	ListOfVariables+="A2DImageRangeMin;A2DImageRangeMax;A2DImageRangeMinLimit;A2DImageRangeMaxLimit;A2DLineoutDisplayLogInt;A2DmaskImage;"
	ListOfVariables+="RemoveFirstNColumns;RemoveLastNColumns;RemoveFirstNRows;RemoveLastNRows;MaskDisplayLogImage;"
	ListOfVariables+="MaskOffLowIntPoints;LowIntToMaskOff;FixBackgroundOversubtraction;"
	ListOfVariables+="OverwriteDataIfExists;SectorsNumSect;SectorsSectWidth;SectorsGraphStartAngle;SectorsGraphEndAngle;SectorsUseRAWData;SectorsUseCorrData;"
	ListOfVariables+="DisplayBeamCenterIn2DGraph;DisplaySectorsIn2DGraph;"
	ListOfVariables+="UseQvector;UseTheta;UseDspacing;UseDistanceFromCenter;"
	ListOfVariables+="UserThetaMin;UserThetaMax;UserDMin;UserDMax;UserQMin;UserQMax;ThetaSameNumPoints;"
	ListOfVariables+="DoGeometryCorrection;DoPolarizationCorrection;Use2DPolarizationCor;Use1DPolarizationCor;StartAngle2DPolCor;InvertImages;SkipBadFiles;MaxIntForBadFile;"
	ListOfVariables+="DisplayRaw2DData;DisplayProcessed2DData;TwoDPolarizFract;"

	ListOfVariables+="Process_DisplayAve;Process_Individually;Process_Average;Process_AveNFiles;Process_ReprocessExisting;"
	//and now the function calls variables
	ListOfVariables+="UseSampleThicknFnct;UseSampleTransmFnct;UseSampleMonitorFnct;UseSampleCorrectFnct;UseSampleMeasTimeFnct;UseSampleNameFnct;"
	ListOfVariables+="UseEmptyTimeFnct;UseBackgTimeFnct;UseEmptyMonitorFnct;"
	ListOfVariables+="ProcessNImagesAtTime;SaveGSASdata;FIlesSortOrder;"
	//errors control
	ListOfVariables+="ErrorCalculationsUseOld;ErrorCalculationsUseStdDev;ErrorCalculationsUseSEM;"
	//2DCalibratedDataInput & output
	ListOfVariables+="UseCalib2DData;ExpCalib2DData;RebinCalib2DData;InclMaskCalib2DData;UseQxyCalib2DData;ReverseBinnedData;AppendToNexusFile;"

	ListOfVariables+="UseLineProfile;UseSectors;"
	ListOfVariables+="LineProf_UseBothHalfs;LineProf_DistanceFromCenter;LineProf_Width;LineProf_DistanceQ;LineProf_WidthQ;"
	ListOfVariables+="LineProfileDisplayWithQ;LineProfileDisplayWithQy;LineProfileDisplayWithQz;LineProfileDisplayWithAzA;LineProfileDisplayLogX;LineProfileDisplayLogY;"
	ListOfVariables+="LineProfileUseRAW;LineProfileUseCorrData;LineProf_EllipseAR;LineProf_LineAzAngle;LineProf_GIIncAngle;GISAXS_ycenterReflectedbeam;"
	ListOfVariables+="DisplayQValsOnImage;DisplayQvalsWIthGridsOnImg;DisplayColorScale;DisplayQCirclesOnImage;"	
	//movie creation controls
	ListOfVariables+="Movie_Use2DRAWdata;Movie_Use2DProcesseddata;Movie_Use1DData;Movie_AppendFileName;Movie_AppendAutomatically;Movie_DisplayLogInt;Movie_FrameRate;Movie_FileOpened;"
	ListOfVariables+="Movie_UseMain2DImage;Movie_UseUserHookFnct;"
	//Behavior controls
	ListOfVariables+="TrimFrontOfName;TrimEndOfName;ScaleImageBy;"	//DoubleClickConverts

	ListOfStrings="CurrentInstrumentGeometry;DataFileType;DataFileExtension;MaskFileExtension;BlankFileExtension;CurrentMaskFileName;DataCalibrationString;"
	ListOfStrings+="CurrentEmptyName;CurrentDarkFieldName;CalibrationFormula;CurrentPixSensFile;OutputDataName;UserSampleName;"
	ListOfStrings+="CCDDataPath;CCDfileName;CCDFileExtension;FileNameToLoad;ColorTableName;CurrentMaskFileName;ExportMaskFileName;ColorTableList;"
	ListOfStrings+="ConfigurationDataPath;LastLoadedConfigFile;ConfFileUserComment;ConfFileUserName;"
	ListOfStrings+="TempOutputDataname;TempOutputDatanameUserFor;"
	ListOfStrings+="Fit2Dlocation;MainPathInfoStr;"
	ListOfStrings+="SampleThicknFnct;SampleTransmFnct;SampleMonitorFnct;SampleCorrectFnct;SampleMeasTimeFnct;SampleNameFnct;"
	ListOfStrings+="EmptyTimeFnct;BackgTimeFnct;EmptyMonitorFnct;"
	ListOfStrings+="LineProf_CurveType;LineProf_KnownCurveTypes;RemoveStringFromName;"
	ListOfStrings+="SampleNameMatchStr;EmptyDarkNameMatchStr;Movie_FileName;Movie_Last1DdataSet;"
	//2DCalibratedDataInput & output
	ListOfStrings+="RebinCalib2DDataToPnts;Calib2DDataOutputFormat;"

	//now for General Binary Input
	ListOfVariables+="NIGBSkipHeaderBytes;NIGBSkipAfterEndTerm;NIGBUseSearchEndTerm;NIGBNumberOfXPoints;NIGBNumberOfYPoints;NIGBSaveHeaderInWaveNote;"
	ListOfStrings+="NIGBDataType;NIGBSearchEndTermInHeader;NIGBByteOrder;NIGBFloatDataType;"
	string ListOfStringsGB="NIGBDataTypeSelection;NIGBByteOrderSelection;"
	//Pilatus support
	ListOfVariables+="PilatusReadAuxTxtHeader;PilatusSignedData;"
	ListOfStrings+="PilatusType;PilatusFileType;PilatusColorDepth;"
	//ESRF edf support
	ListOfVariables+="ESRFEdf_ExposureTime;ESRFEdf_Center_1;ESRFEdf_Center_2;ESRFEdf_PSize_1;ESRFEdf_PSize_2;ESRFEdf_SampleDistance;ESRFEdf_SampleThickness;ESRFEdf_WaveLength;ESRFEdf_Title;"
	ListOfStrings+=""
	
	Wave/Z/T ListOfCCDDataInCCDPath
	if (!WaveExists(ListOfCCDDataInCCDPath))
		make/O/T/N=0 ListOfCCDDataInCCDPath
	endif
	Wave/Z SelectionsofCCDDataInCCDPath
	if(!WaveExists(SelectionsofCCDDataInCCDPath))
		make/O/N=0 SelectionsofCCDDataInCCDPath
	endif

	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	for(i=0;i<itemsInList(ListOfStringsGB);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStringsGB))
	endfor	
	//and now waves as needed
	Wave/Z/T ListOf2DSampleData
	if (!WaveExists(ListOf2DSampleData))
		make/N=0/T ListOf2DSampleData
	endif
	Wave/Z ListOf2DSampleDataNumbers
	if (!WaveExists(ListOf2DSampleDataNumbers))
		make/N=0 ListOf2DSampleDataNumbers
	endif
	Wave/Z/T ListOf2DMaskData
	if (!WaveExists(ListOf2DMaskData))
		make/N=0/T ListOf2DMaskData
	endif
	Wave/Z ListOf2DMaskDataNumbers
	if (!WaveExists(ListOf2DMaskDataNumbers))
		make/N=0 ListOf2DMaskDataNumbers
	endif
	Wave/Z/T ListOf2DEmptyData
	if (!WaveExists(ListOf2DEmptyData))
		make/N=0/T ListOf2DEmptyData
	endif
	//set starting values
	SVAR ColorTableList
	if(strlen(ColorTableList)<1)
		ColorTableList="Geo32;Geo32_R;Terrain;Terrain_R;Grays;Grays_R;Rainbow;Rainbow_R;YellowHot;YellowHot_R;BlueHot;BlueHot_R;BlueRedGreen;BlueRedGreen_R;RedWhiteBlue;RedWhiteBlue_R;PlanetEarth;PlanetEarth_R;"
	endif
	

	SVAR RebinCalib2DDataToPnts
	if(strlen(RebinCalib2DDataToPnts)<1)
		RebinCalib2DDataToPnts="100x100"
	endif
	SVAR Calib2DDataOutputFormat
	if(strlen(Calib2DDataOutputFormat)<1)
		Calib2DDataOutputFormat="CanSAS/Nexus"
	endif

	SVAR PilatusFileType
	if(strlen(PilatusFileType)<1)
		PilatusFileType="tiff"
	endif
	SVAR PilatusColorDepth
	if(strlen(PilatusColorDepth)<1)
		PilatusColorDepth="32"
	endif
	SVAR PilatusType
	if(strlen(PilatusType)<1)
		PilatusType="Pilatus100k"
	endif
	SVAR NIGBDataTypeSelection
	if (strlen(NIGBDataTypeSelection)<1)
		NIGBDataTypeSelection = "Double Float;Single Float;32 bit signed integer;16 bit signed integer;8 bit signed integer;32 bit unsigned integer;16 bit unsigned integer;8 bit unsigned integer;"
	endif
	SVAR NIGBDataType
	if (strlen(NIGBDataType)<1)
		NIGBDataType = "Double Float"
	endif
	SVAR NIGBByteOrderSelection
	if (strlen(NIGBByteOrderSelection)<1)
		NIGBByteOrderSelection = "High Byte First;Low Byte First;"
	endif
	SVAR NIGBByteOrder
	if (strlen(NIGBByteOrder)<1)
		NIGBByteOrder = "Low Byte First"
	endif
	SVAR NIGBFloatDataType
	if (strlen(NIGBFloatDataType)<1)
		NIGBFloatDataType = "IEEE"
	endif
	SVAR NIGBSearchEndTermInHeader
	if (strlen(NIGBSearchEndTermInHeader)<1)
		NIGBSearchEndTermInHeader = ""
	endif
	NVAR NIGBNumberOfXPoints
	if ((NIGBNumberOfXPoints)<1)
		NIGBNumberOfXPoints = 1024
	endif
	NVAR NIGBNumberOfYPoints
	if ((NIGBNumberOfYPoints)<1)
		NIGBNumberOfYPoints = 1024
	endif
	NVAR ScaleImageBy
	if ((ScaleImageBy)<0.05)
		ScaleImageBy = 1
	endif


	SVAR DataCalibrationString
	if(strlen(DataCalibrationString)<3)
		DataCalibrationString="Arbitrary"
	endif
	SVAR DataFileExtension
	if (strlen(DataFileExtension)<1)
		DataFileExtension = ".tif"
	endif
	SVAR MaskFileExtension
	if (strlen(MaskFileExtension)<1)
		MaskFileExtension = ".tif"
	endif
	SVAR BlankFileExtension
	if (strlen(BlankFileExtension)<1)
		BlankFileExtension = ".tif"
	endif
	SVAR ConfigurationDataPath
	if (strlen(ConfigurationDataPath)<1)
		ConfigurationDataPath = ""
	endif
	SVAR LastLoadedConfigFile
	if (strlen(LastLoadedConfigFile)<1)
		LastLoadedConfigFile = ""
	endif
	SVAR ConfFileUserComment
	if (strlen(ConfFileUserComment)<1)
		ConfFileUserComment = ""
	endif
	SVAR ConfFileUserName
	if (strlen(ConfFileUserName)<1)
		ConfFileUserName = ""
	endif
	//Line profile default settings
	NVAR UseLineProfile
	NVAR UseSectors
	SVAR LineProf_CurveType
	SVAR LineProf_KnownCurveTypes
	LineProf_KnownCurveTypes = "---;Vertical line;Horizontal Line;Angle Line;GI_Vertical Line;GI_Horizontal Line;Ellipse;"
	if(strlen(LineProf_CurveType)<1)
		LineProf_CurveType="---"
		UseLineProfile=0
	endif
	
	
	string ListOfVariablesL="BeamCenterX;BeamCenterY;QvectorNumberPoints;SampleToCCDDistance;"
	for(i=0;i<itemsInList(ListOfVariablesL);i+=1)	
		NVAR testVal=$(StringFromList(i,ListOfVariablesL))
		if(testVal==0)
			testVal =500
		endif
	endfor		
	ListOfVariablesL="SectorsNumSect;SectorsGraphEndAngle;"
	for(i=0;i<itemsInList(ListOfVariablesL);i+=1)	
		NVAR testVal=$(StringFromList(i,ListOfVariablesL))
		if(testVal==0)
			testVal =360
		endif
	endfor		
	ListOfVariablesL="DezingerRatio;"
	for(i=0;i<itemsInList(ListOfVariablesL);i+=1)	
		NVAR testVal=$(StringFromList(i,ListOfVariablesL))
		if(testVal==0)
			testVal =1.5
		endif
	endfor		
	ListOfVariablesL="Wavelength;"
	if(FirstRun)
		ListOfVariablesL+="QbinningLogarithmic;"
	endif
	ListOfVariablesL+="PixelSizeX;PixelSizeY;StartDataRangeNumber;EndDataRangeNumber;TwoDPolarizFract;"
	ListOfVariablesL+="SampleThickness;SampleTransmission;SampleI0;EmptyI0;DezingerHowManyTimes;"
	ListOfVariablesL+="SampleMeasurementTime;BackgroundMeasTime;EmptyMeasurementTime;"
	ListOfVariablesL+="CorrectionFactor;SectorsSectWidth;NIGBSaveHeaderInWaveNote;ProcessNImagesAtTime;LineProf_EllipseAR;"
	for(i=0;i<itemsInList(ListOfVariablesL);i+=1)	
		NVAR testVal=$(StringFromList(i,ListOfVariablesL))
		if(testVal==0)
			testVal =1
		endif
	endfor		
	ListOfVariablesL="SectorsHalfWidth;SectorsStepInAngle;Movie_FrameRate;"
	for(i=0;i<itemsInList(ListOfVariablesL);i+=1)	
		NVAR testVal=$(StringFromList(i,ListOfVariablesL))
		if(testVal==0)
			testVal =10
		endif
	endfor		
	ListOfVariablesL="NumberOfSectors;"
	for(i=0;i<itemsInList(ListOfVariablesL);i+=1)	
		NVAR testVal=$(StringFromList(i,ListOfVariablesL))
		if(testVal==0)
			testVal =36
		endif
	endfor		
	NVAR Wavelength= root:Packages:Convert2Dto1D:Wavelength
	NVAR XrayEnergy= root:Packages:Convert2Dto1D:XrayEnergy
	XrayEnergy = 12.398424437/Wavelength

	ListOfVariablesL="UseI0ToCalibrate;DezingerCCDData;DezingerEmpty;DezingerDarkField;HorizontalTilt;VerticalTilt;"
	for(i=0;i<itemsInList(ListOfVariablesL);i+=1)	
		NVAR testVal=$(StringFromList(i,ListOfVariablesL))
		if(testVal==0)
			testVal =0
		endif
	endfor		
	
	NVAR DisplayQValsOnImage
	NVAR DisplayQvalsWIthGridsOnImg
	NVAR DisplayQCirclesOnImage
	if(DisplayQCirclesOnImage+DisplayQValsOnImage+DisplayQvalsWIthGridsOnImg>1)
		DisplayQValsOnImage = 0
		DisplayQvalsWIthGridsOnImg = 0
		DisplayQCirclesOnImage = 0
	endif


	NVAR Process_DisplayAve
	NVAR Process_Individually
	NVAR Process_Average
	NVAR Process_AveNFiles
	NVAR Process_ReprocessExisting
	if(	Process_DisplayAve + Process_Individually + Process_Average + Process_AveNFiles + Process_ReprocessExisting !=1)
		Process_DisplayAve = 1
		Process_Individually = 0
		Process_Average = 0
		Process_AveNFiles = 0
		Process_ReprocessExisting = 0
	endif

	NVAR TrimEndOfName=root:Packages:Convert2Dto1D:TrimEndOfName
	NVAR TrimFrontOfName=root:Packages:Convert2Dto1D:TrimFrontOfName
	if((TrimEndOfName+TrimFrontOfName)!=1)
		TrimEndOfName = 1
		TrimFrontOfName=0
	endif
	NVAR Use2DdataName=root:Packages:Convert2Dto1D:Use2DdataName
	NVAR UseSampleNameFnct=root:Packages:Convert2Dto1D:UseSampleNameFnct
	if((Use2DdataName+UseSampleNameFnct)!=1)
		Use2DdataName = 1
		UseSampleNameFnct=0
	endif

	NVAR ErrorCalculationsUseOld
	NVAR ErrorCalculationsUseStdDev
	NVAR ErrorCalculationsUseSEM
	if(ErrorCalculationsUseOld+ErrorCalculationsUseStdDev+ErrorCalculationsUseSEM!=1)
		ErrorCalculationsUseOld=0
		ErrorCalculationsUseStdDev=1
		ErrorCalculationsUseSEM=0
		print "Uncertainty calculation method is set to \"Standard deviation\""
	else
		if(ErrorCalculationsUseOld)
			print "Uncertainty calculation method is set to \"Old method (see manual for description)\""
		elseif(ErrorCalculationsUseStdDev)
			print "Uncertainty calculation method is set to \"Standard deviation (see manual for description)\""
		else
			print "Uncertainty calculation method is set to \"Standard error of mean (see manual for description)\""
		endif
	endif

	NVAR LineProfileDisplayWithQ
	NVAR LineProfileDisplayWithQz
	NVAR LineProfileDisplayWithQy
	if(LineProfileDisplayWithQ+LineProfileDisplayWithQz+LineProfileDisplayWithQy!=1)
		LineProfileDisplayWithQ=1
		LineProfileDisplayWithQz=0
		LineProfileDisplayWithQy=0
	endif

	
	NVAR UseQvector
	NVAR UseTheta
	NVAR UseDspacing
	NVAR UseDistanceFromCenter
	if((UseQvector+UseTheta+UseDspacing+UseDistanceFromCenter)!=1)
		UseQvector=1
		UseTheta=0
		UseDspacing=0
		UseDistanceFromCenter=0
	endif

	NVAR Use2DPolarizationCor
	NVAR Use1DPolarizationCor
	if(Use2DPolarizationCor+Use1DPolarizationCor!=1)
		Use2DPolarizationCor=0
		Use1DPolarizationCor=1
	endif

	NVAR RemoveFirstNColumns
	NVAR RemoveLastNColumns
	NVAR RemoveFirstNRows
	NVAR RemoveLastNRows
	RemoveFirstNColumns=0
	RemoveLastNColumns=0
	RemoveFirstNRows=0
	RemoveLastNRows=0
	
	
	NVAR  DisplayRaw2DData
	NVAR  DisplayProcessed2DData
	if(DisplayRaw2DData+DisplayProcessed2DData!=1)
		DisplayProcessed2DData=0
		DisplayRaw2DData=1
	endif
	SVAR CCDFileExtension
	if(strlen(CCDFileExtension)<2)
		CCDFileExtension="????"
	endif
	SVAR ColorTableName
	if(strlen(ColorTableName)<2)
		ColorTableName="Terrain"
	endif
	
	NVAR SectorsUseRAWData
	NVAR SectorsUseCorrData
	if(SectorsUseRAWData+SectorsUseCorrData!=1)
		SectorsUseRAWData=1
		SectorsUseCorrData=0
	endif
	
	NVAR LineProfileUseRAW
	NVAR LineProfileUseCorrData
	if(LineProfileUseRAW+LineProfileUseCorrData!=1)
		LineProfileUseRAW=1
		LineProfileUseCorrData=0
	endif
	
	//BSL files support...
	//josh add: I added BSL sumoverframes and BSLlog 
	setDataFolder root:Packages
	NewDataFolder/O/S root:Packages:NI1_BSLFiles
	
		variable/g BSLpixels, BSLpixels1, BSLframes, BSLcurrentframe, BSLsumframes, BSLwaxsframes, BSLI1, BSLI2, BSLI1pos, BSLI2pos, BSLwaxschannels, BSLAverage, BSLFoundFrames,BSLfromframe,BSLtoframe,BSLsumseq,BSLGBformat
 		make/o/t/n=10 BSLheadnote
		make/o/n=(1,5) BSLframelistsequence
		setdimlabel 1,0,$("Frame Number"),BSLframelistsequence
		setdimlabel 1,1,$("Exposure Time"),BSLframelistsequence
		setdimlabel 1,2,$("Sum Sequence"),BSLframelistsequence
		setdimlabel 1,3,$("Elapsed Time"),BSLframelistsequence
		setdimlabel 1,4,$("Utility"),BSLframelistsequence

	setDataFOlder oldDf
	NEXUS_Initialize(0)
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1A_Convert2DTo1D()
		
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D

	NVAR UseSectors=root:Packages:Convert2Dto1D:UseSectors		//this is for Sector analysis. Only if set ot 1, sector analysis is reuired by user...
	NVAR UseLineProfile=root:Packages:Convert2Dto1D:UseLineProfile		//this is for Sector analysis. Only if set ot 1, sector analysis is reuired by user...
	
	string ListOfOrientations=""
	string CurOrient
	variable i
	NVAR DoCircularAverage=root:Packages:Convert2Dto1D:DoCircularAverage
	NVAR DoSectorAverages=root:Packages:Convert2Dto1D:DoSectorAverages
	NVAR NumberOfSectors=root:Packages:Convert2Dto1D:NumberOfSectors
	NVAR SectorsStartAngle=root:Packages:Convert2Dto1D:SectorsStartAngle
	NVAR SectorsHalfWidth=root:Packages:Convert2Dto1D:SectorsHalfWidth
	NVAR SectorsStepInAngle=root:Packages:Convert2Dto1D:SectorsStepInAngle
	NVAR LineProf_DistanceQ=root:Packages:Convert2Dto1D:LineProf_DistanceQ
	NVAR LineProf_WidthQ=root:Packages:Convert2Dto1D:LineProf_WidthQ
	NVAR UseBatchProcessing=root:Packages:Convert2Dto1D:UseBatchProcessing
	SVAR Movie_Last1DdataSet=root:Packages:Convert2Dto1D:Movie_Last1DdataSet
	string tempListOfProcessedSectors=""
	//let user run some hook function to modify parameters, if needed here. 
#if(exists("NI1_BeforeConvertDataHook")==6)
	NI1_BeforeConvertDataHook()
#endif 
		//parameters are set, now process the data as needed..
	
	NI1A_Check2DConversionData()		//this should check if input data are OK, stuff any necessary consistency checks here...
	
	NI1A_CorrectDataPerUserReq("")		//here we need to do all of the corrections as user selected...
		
	NI1A_MovieRecordFrameIfReq(2)		
	
	//sector averages are here
	if(UseSectors)		//this is all needed for sector analysis. Will need to move stuff around for line analysis later. 
	
		if (DoCircularAverage)
			ListOfOrientations+="C;"
		endif	
		if (DoSectorAverages)
			For(i=0;i<NumberOfSectors;i+=1)
				ListOfOrientations+=ReplaceString(".",num2str(IN2G_roundDecimalPlaces(SectorsStartAngle+SectorsStepInAngle*i,1)),"p")+"_"+ReplaceString(".",num2str(IN2G_roundDecimalPlaces(SectorsHalfWidth,1)),"p")+";"
			endfor
		endif	
		For(i=0;i<ItemsInList(ListOfOrientations);i+=1)
			CurOrient = stringFromList(i,ListOfOrientations)
			NI1A_FixNumPntsIfNeeded(CurOrient)
			
			NI1A_CheckGeometryWaves(CurOrient)			//checks if geometry waves exist and if they are correct, makes them correct if needed
		
			NI1A_AverageDataPerUserReq(CurOrient)
			
			NI1A_SaveDataPerUserReq(CurOrient)
			
			tempListOfProcessedSectors+=CurOrient+";"
			if(!UseBatchProcessing)
				DoUpdate
			endif
		endfor
	endif
	//line profile averages are here... 
	if(UseLineProfile)
		NI1A_LineProf_CreateLP()		//this creates line profile as user set conditions... 
		//note for future. There is a lot of unnecessary calculations here. This could be sped up by better programming. 
		//figure out which Q we analyzed...
		SVAR LineProf_CurveType=root:Packages:Convert2Dto1D:LineProf_CurveType	
//		NVAR LineProf_LineAzAngle=root:Packages:Convert2Dto1D:LineProf_LineAzAngle
		NVAR LineProf_LineAzAngleG =root:Packages:Convert2Dto1D:LineProf_LineAzAngle
		variable LineProf_LineAzAngle
		LineProf_LineAzAngle = LineProf_LineAzAngleG>=0 ? LineProf_LineAzAngleG : LineProf_LineAzAngleG+180
		string tempStr, tempStr1
		if(stringMatch(LineProf_CurveType,"Horizontal Line"))
			tempStr1="HLp_"
			sprintf tempStr, "%1.2g" LineProf_DistanceQ
		elseif(stringMatch(LineProf_CurveType,"GI_Horizontal line"))
			tempStr1="GI_HLp_"
			sprintf tempStr, "%1.2g" LineProf_DistanceQ
		elseif(stringMatch(LineProf_CurveType,"GI_Vertical line"))
			tempStr1="GI_VLp_"
			sprintf tempStr, "%1.2g" LineProf_DistanceQ
		elseif(stringMatch(LineProf_CurveType,"Vertical Line"))
			tempStr1="VLp_"
			sprintf tempStr, "%1.2g" LineProf_DistanceQ
		elseif(stringMatch(LineProf_CurveType,"Ellipse"))
			tempStr1="ELp_"
			sprintf tempStr, "%1.2g" LineProf_DistanceQ
		elseif(stringMatch(LineProf_CurveType,"Angle Line"))
			tempStr1="ALp_"
			sprintf tempStr, "%1.2g" LineProf_LineAzAngle
		endif
		NI1A_SaveDataPerUserReq(tempStr1+tempStr)
		
		tempListOfProcessedSectors+=tempStr1+tempStr+";"
		if(!UseBatchProcessing)
			doUpdate
		endif
	endif
	//here we will create special waves in case we are using 9IDC SAXS...
	NI1_9IDCCreateSMRSAXSdata(tempListOfProcessedSectors)
	
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_FixNumPntsIfNeeded(CurOrient)
	string CurOrient
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//here we fix the num pnts to max number if requested by user
	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D
	
	NVAR QvectorNumberPoints=root:Packages:Convert2Dto1D:QvectorNumberPoints
	NVAR QvectorMaxNumPnts=root:Packages:Convert2Dto1D:QvectorMaxNumPnts
	NVAR QbinningLogarithmic=root:Packages:Convert2Dto1D:QbinningLogarithmic
	
	if(QvectorMaxNumPnts)	//user wants 1 point = 1 pixel (max num points)... Need to fix the num pnts....
		QbinningLogarithmic=0		//cannot be log binning... 
		//first lets check lookup table, so we do not have to calculate this always
		Wave/Z MaxNumPntsLookupWv= root:Packages:Convert2Dto1D:MaxNumPntsLookupWv
		Wave/T/Z MaxNumPntsLookupWvLBL= root:Packages:Convert2Dto1D:MaxNumPntsLookupWvLBL
		if(!WaveExists(MaxNumPntsLookupWv))
			Make /N=0 MaxNumPntsLookupWv
			Make/T /N=0 MaxNumPntsLookupWvLBL
		endif
		//OK lookup table now exists, next check the wave note to make sure it si up to date
		string OldNote=note(MaxNumPntsLookupWv)
		NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
		NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
		SVAR CurrentMaskFileName=root:Packages:Convert2Dto1D:CurrentMaskFileName
		Wave CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
		NVAR UseMask=root:Packages:Convert2Dto1D:UseMask
		string OldCntrX, OldCntrY
		variable MaskNameNotSame, OldUseMask, OldDim0, OldDim1
		OldCntrX=StringByKey("BeamCenterX", OldNote  , "=")
		OldCntrY=StringByKey("BeamCenterY", OldNote  , "=")
		OldDim0=NumberByKey("WvDimension0", OldNote  , "=")
		OldDim1=NumberByKey("WvDimension1", OldNote  , "=")
		OldUseMask=NumberByKey("UseMask", OldNote  , "=")
		if(UseMask)
			MaskNameNotSame= abs(cmpstr(CurrentMaskFileName,stringByKey("MaskName", OldNote,"=")))
		else
			MaskNameNotSame=0
		endif
		if(cmpstr(OldCntrX,num2str(BeamCenterX))!=0 || cmpstr(OldCntrY, num2str(BeamCenterY))!=0 || OldDim0!=DimSize(CCDImageToConvert, 0 ) || OldDim1!=DimSize(CCDImageToConvert, 1) || MaskNameNotSame || OldUseMask!=UseMask)
			redimension/N=0 MaxNumPntsLookupWv
			redimension/N=0 MaxNumPntsLookupWvLBL
		endif
		variable i
		For(i=0;i<numpnts(MaxNumPntsLookupWv);i+=1)
			if(cmpstr(MaxNumPntsLookupWvLBL[i],CurOrient)==0)
				QvectorNumberPoints=MaxNumPntsLookupWv[i]
			//	print "Right number of points found in LUT"
				return 1
			endif
		endfor
		//OK, if we are here, we did not find the right value in the lookup table
		//fix the note
		note /k MaxNumPntsLookupWv
		string newNote="BeamCenterX="+num2str(BeamCenterX)+";"
		newNote+="BeamCenterY="+num2str(BeamCenterY)+";"
		newNote+="WvDimension0="+num2str(DimSize(CCDImageToConvert, 0 ))+";"
		newNote+="WvDimension1="+num2str(DimSize(CCDImageToConvert, 1))+";"
		newNote+="UseMask="+num2str(UseMask)+";"
		newNote+="MaskName="+CurrentMaskFileName+";"
		note MaxNumPntsLookupWv, newNote
		//and now find the right number... This is the most difficult part...
		NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX								//in millimeters
		NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY								//in millimeters
		NVAR HorizontalTilt = root:Packages:Convert2Dto1D:HorizontalTilt								//in degrees
		NVAR VerticalTilt = root:Packages:Convert2Dto1D:VerticalTilt								//in degrees
		Wave/Z PixRadius2DWave=root:Packages:Convert2Dto1D:PixRadius2DWave		//note, this is distance in pixles, not in radii
		if(WaveExists(PixRadius2DWave))
			OldNote = note(PixRadius2DWave)
			OldCntrX=stringByKey("BeamCenterX",OldNote,"=")
			OldCntrY=stringByKey("BeamCenterY",OldNote,"=")
			variable OldPixX=numberByKey("PixelSizeX",OldNote,"=")
			variable OldPixY=numberByKey("PixelSizeY",OldNote,"=")
			//variable OldHorizontalTilt=numberByKey("HorizontalTilt",OldNote,"=")
			//variable OldVerticalTilt=numberByKey("VerticalTilt",OldNote,"=")
			if(cmpstr(OldCntrX, num2str(BeamCenterX))!=0 || cmpstr(OldCntrY,num2str(BeamCenterY))!=0 || OldPixX!=PixelSizeX || OldPixY!=PixelSizeY)///|| OldHorizontalTilt!=HorizontalTilt || OldVerticalTilt!=VerticalTilt) lets not worry here about the tilt
				NI1A_Create2DPixRadiusWave(CCDImageToConvert)
				NI1A_Create2DAngleWave(CCDImageToConvert)
			endif
		else
			NI1A_Create2DPixRadiusWave(CCDImageToConvert)
			NI1A_Create2DAngleWave(CCDImageToConvert)
		endif
		//Ok, now the 2DRadiusWave must exist... and be correct.

		wave PixRadius2DWave=root:Packages:Convert2Dto1D:PixRadius2DWave
		Wave AnglesWave=root:Packages:Convert2Dto1D:AnglesWave
		NVAR UseMask=root:Packages:Convert2Dto1D:UseMask
		NVAR DoSectorAverages=root:Packages:Convert2Dto1D:DoSectorAverages
		variable centerAngleRad, WidthAngleRad, startAngleFIxed, endAgleFixed
		//apply mask, if selected
		duplicate/O PixRadius2DWave, MaskedRadius2DWave
		redimension/S MaskedRadius2DWave
		if(UseMask)
			wave M_ROIMask=root:Packages:Convert2Dto1D:M_ROIMask
			MatrixOp/O/NTHR=0 MaskedRadius2DWave = PixRadius2DWave * M_ROIMask
		endif
		if(cmpstr(CurOrient,"C")!=0)
			duplicate/O AnglesWave,tempAnglesMask
			centerAngleRad= (pi/180)*str2num(StringFromList(0, CurOrient,  "_"))
			WidthAngleRad= (pi/180)*str2num(StringFromList(1, CurOrient,  "_"))
			
			startAngleFixed = centerAngleRad-WidthAngleRad
			endAgleFixed = centerAngleRad+WidthAngleRad
	
			if(startAngleFixed<0)
				MultiThread tempAnglesMask = ((AnglesWave[p][q] > (2*pi+startAngleFixed) || AnglesWave[p][q] <endAgleFixed))? 1 : 0
			elseif(endAgleFixed>(2*pi))
				MultiThread tempAnglesMask = (AnglesWave[p][q] > startAngleFixed || AnglesWave[p][q] <(endAgleFixed-2*pi))? 1 : 0
			else
				MultiThread tempAnglesMask = (AnglesWave[p][q] > startAngleFixed && AnglesWave[p][q] <endAgleFixed)? 1 : 0
			endif
			
			MatrixOp/O/NTHR=0 MaskedRadius2DWave = MaskedRadius2DWave * tempAnglesMask
			killwaves tempAnglesMask
		endif
		//radius data are masked now 

		wavestats/Q MaskedRadius2DWave
		killwaves MaskedRadius2DWave
		QvectorNumberPoints=floor((V_max-V_min))
		redimension/N=(numpnts(MaxNumPntsLookupWv)+1) MaxNumPntsLookupWvLBL, MaxNumPntsLookupWv
		
		MaxNumPntsLookupWvLBL[numpnts(MaxNumPntsLookupWv)-1]= CurOrient
		MaxNumPntsLookupWv[numpnts(MaxNumPntsLookupWv)-1]= QvectorNumberPoints
		
		print "Recalculated the right number of points LUT"

		return 2
	endif
	setDataFolder OldDf
	
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_Create2DPixRadiusWave(DataWave)
	wave DataWave
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D
	
	NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance		//in millimeters
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength							//in A
	NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX								//in millimeters
	NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY								//in millimeters
	NVAR beamCenterX=root:Packages:Convert2Dto1D:beamCenterX
	NVAR beamCenterY=root:Packages:Convert2Dto1D:beamCenterY
	NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt							//tilt in degrees
	NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt								//tilt in degrees
	NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance		//distance to sample in mm 

	//wavelength=12.398424437/EnergyInKeV
	//OK, existing radius wave was not correct or did not exist, make the right one... 
	print "Creating Pix Radius wave"
	
	variable XSaDetDitsInPix=SampleToCCDDistance / PixelSizeX
	variable YSaDetDitsInPix=SampleToCCDDistance / PixelSizeY
	//Create wave for q distribution
	Duplicate/O DataWave, PixRadius2DWave
	Redimension/S PixRadius2DWave
	//PixRadius2DWave = sqrt((cos(HorizontalTilt*pi/180)*(p-BeamCenterX))^2 + (cos(VerticalTilt*pi/180)*(q-BeamCenterY))^2)
//	need to use new function... NI1T_TiltedToCorrectedR(TiltedR,SaDetDistance,alpha)
//	tilts added again 6/22/2005
//	variable tm=ticks
//	if(HorizontalTilt!=0 || VerticalTilt!=0)
//		PixRadius2DWave = sqrt((NI1T_TiltedToCorrectedR(p-BeamCenterX,XSaDetDitsInPix,HorizontalTilt))^2 + (NI1T_TiltedToCorrectedR(q-BeamCenterY,YSaDetDitsInPix,VerticalTilt))^2)
//	else
	//Note, I do not think this wave needs to be fixed for tilts. All we use it for is to get max number of pixels for any particular direction... 
	Multithread	PixRadius2DWave = sqrt((cos(HorizontalTilt*pi/180)*(p-BeamCenterX))^2 + (cos(VerticalTilt*pi/180)*(q-BeamCenterY))^2)
//	endif
//	print (ticks-tm)/60
	if(beamCenterX>0 && beamCenterX<dimsize(PixRadius2DWave,0) && beamCenterY>0 && beamCenterY<dimsize(PixRadius2DWave,1))
		PixRadius2DWave[beamCenterX][beamCenterY] = NaN
	endif
	//record for which geometry this Radius vector wave was created
	string NoteStr
	NoteStr = note(DataWave)
	NoteStr+="BeamCenterX="+num2str(BeamCenterX)+";"
	NoteStr+="BeamCenterY="+num2str(BeamCenterY)+";"
	NoteStr+="PixelSizeX="+num2str(PixelSizeX)+";"
	NoteStr+="PixelSizeY="+num2str(PixelSizeY)+";"
	NoteStr+="HorizontalTilt="+num2str(HorizontalTilt)+";"
	NoteStr+="VerticalTilt="+num2str(VerticalTilt)+";"
	note PixRadius2DWave, NoteStr
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//following code added 6 22 2005 to finish the tilts...

Function NI1T_TiltedToCorrectedR(TiltedR,SaDetDistance,alpha)			
	variable TiltedR,SaDetDistance,alpha
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//this function returns distance from beam center corrected for the effect of tilt
	//Definitions:
	//TiltedR is measured distance on detector (in same units as SaDetDistance) in either x or y directions. 
	//	Note, it is positive if the measured x is larger than x of beamstop (or same for y)
	//SaDetDistance is distance between the sample and the beam center position on thte detector Use same units as for TiltedR
	//alpha is tilt angle in particular plane. It is positive when the detector is tilted forward for X (or y) positive. It is in degrees
	 variable alphaRad=(alpha*pi/180)
	return TiltedR*cos(alphaRad) + TiltedR*sin(alphaRad)*tan(NI1T_CalcThetaForTiltToTheor(TiltedR,SaDetDistance,alphaRad))
	
end

Function NI1T_CalcThetaForTiltToTheor(radius,Distance,alphaRad)
		variable radius,Distance,alphaRad
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")	
		variable temp =radius * abs(cos(alphaRad))
		temp=temp/sqrt(distance^2 + radius^2 - 2*Distance*radius*sin(alphaRad))
		return asin(temp)
end

Function NI1T_TheoreticalToTilted(TheoreticalR,SaDetDistance,alpha)
		variable TheoreticalR,SaDetDistance,alpha
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		//this function returns distance on tilted detector compared to theoretical distacne in perpendicular plane
		//for either x or y directions
		//definitions
		// TheoreticalR is distance in either positive or negative direction in perpendicular plane to Sa-det line
		//	use same units as for SapleToDetector distance
		//	it is positive if caclualte x is larger than beam center x (or fsame for y)
		//SaDetDistance is distnace between sample and detector...
		//alpha is tilt angle. It is positive if for positive TheoreticalR the detector is tilted forward (making the calculated distacne smaller at least for small alphas
		//	alpha is in degrees
		
//		variable theta	=atan(TheoreticalR/SaDetDistance)	//theta in radians
//		return TheoreticalR * cos(theta) / cos(theta - alpha * pi/180)
		//new calculation 12 25 2010, provided by David Ilavsky
		variable betaAngle = atan(SaDetDistance/TheoreticalR)
		variable alphaRad=alpha/(2*pi)
		variable res = sin(pi/2-alphaRad) * TheoreticalR*(sin(betaAngle)/(sin(pi - alphaRad - betaAngle)))
		return res
end
//Function NI1BC_CalculatePathWvs(dspacing, wvX,wvY)
//	wave wvX, wvY
//	variable dspacing
//	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//
//	string oldDf=GetDataFOlder(1)
//	setDataFolder root:Packages:Convert2Dto1D
//
//	variable pixelDist
//	variable pixelDistXleft, pixelDistXright, pixelDistYtop, pixelDistYbot
//	NVAR Wavelength
//	NVAR SampleToCCDDistance
//	NVAR PixelSizeX
//	NVAR PixelSizeY
//	NVAR XrayEnergy
//	NVAR HorizontalTilt
//	NVAR VerticalTilt
//	NVAR ycenter=root:Packages:Convert2Dto1D:BeamCenterY
//	NVAR xcenter=root:Packages:Convert2Dto1D:BeamCenterX
//	//Ok, this should just return simple Bragg law with little trigonometry, NO tilts yet
//	variable radX = NI1BC_GetPixelFromDSpacing(dspacing, "X")
//	variable radY = NI1BC_GetPixelFromDSpacing(dspacing, "Y")
// 	pixelDist = SampleToCCDDistance *tan(2* asin( Wavelength /(2* dspacing) )  )
////			pixelDist = NI1T_TheoreticalToTilted(pixelDist,SampleToCCDDistance,HorizontalTilt) / PixelSizeX 
//	pixelDistXleft = NI1T_TheoreticalToTilted(pixelDist,SampleToCCDDistance,HorizontalTilt) / PixelSizeX
//	pixelDistXright = NI1T_TheoreticalToTilted(pixelDist,SampleToCCDDistance,-1*HorizontalTilt) / PixelSizeX
//	pixelDistYtop = NI1T_TheoreticalToTilted(pixelDist,SampleToCCDDistance,VerticalTilt) / PixelSizeY
//	pixelDistYbot = NI1T_TheoreticalToTilted(pixelDist,SampleToCCDDistance,-1*VerticalTilt) / PixelSizeY
//	redimension/N=360 wvX, wvY
//	SetScale/I x 0,(2*pi),"", wvX, wvY
//	wvX = ((x>=pi/2)&&(x<3*pi/2))? (xcenter+pixelDistXright*cos(x)) : (xcenter+pixelDistXleft*cos(x))
//	wvY = ((x>=0)&&(x<pi))? (ycenter+pixelDistYtop*sin(x)) : (ycenter+pixelDistYbot*sin(x))
//  	setDataFolder OldDf	
//end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_RemoveInfNaNsFrom10Waves(Wv1,wv2,wv3,wv4,wv5,wv6,wv7,wv8, wv9, wv10)							//removes NaNs from 3 waves
	Wave Wv1,wv2,wv3,wv4,wv5,wv6,wv7,wv8,wv9, wv10					//assume same number of points in the waves
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i=0, imax=numpnts(Wv1)-1
	For(i=imax;i>=0;i-=1)
			if (numtype(Wv1[i])!=0)
				Deletepoints i, 1, Wv1,wv2,wv3,wv4,wv5,wv6,wv7,wv8,wv9, wv10
			endif
			if (numtype(Wv2[i])!=0)
				Deletepoints i, 1, Wv1,wv2,wv3,wv4,wv5,wv6,wv7,wv8,wv9, wv10
			endif
			if (numtype(Wv3[i])!=0)
				Deletepoints i, 1, Wv1,wv2,wv3,wv4,wv5,wv6,wv7,wv8,wv9, wv10
			endif
			if (numtype(Wv4[i])!=0)
				Deletepoints i, 1, Wv1,wv2,wv3,wv4,wv5,wv6,wv7,wv8,wv9, wv10
			endif
			if (numtype(Wv5[i])!=0)
				Deletepoints i, 1, Wv1,wv2,wv3,wv4,wv5,wv6,wv7,wv8,wv9, wv10
			endif
			if (numtype(Wv6[i])!=0)
				Deletepoints i, 1, Wv1,wv2,wv3,wv4,wv5,wv6,wv7,wv8,wv9, wv10
			endif
			if (numtype(Wv7[i])!=0)
				Deletepoints i, 1, Wv1,wv2,wv3,wv4,wv5,wv6,wv7,wv8,wv9, wv10
			endif
			if (numtype(Wv8[i])!=0)
				Deletepoints i, 1, Wv1,wv2,wv3,wv4,wv5,wv6,wv7,wv8,wv9, wv10
			endif
			if (numtype(Wv9[i])!=0)
				Deletepoints i, 1, Wv1,wv2,wv3,wv4,wv5,wv6,wv7,wv8,wv9, wv10
			endif
			if (numtype(Wv10[i])!=0)
				Deletepoints i, 1, Wv1,wv2,wv3,wv4,wv5,wv6,wv7,wv8,wv9, wv10
			endif
	endfor
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function/S NI1A_UserNameStrProto(my2DWave,FileNameString)
	wave my2DWave
	string FileNameString
	return FileNameString[0,17]
end
//*******************************************************************************************************************************************
Function NI1A_SaveDataPerUserReq(CurOrient)
	string CurOrient

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=getDataFOlder(1)
	if(stringmatch(CurOrient, "*Lp*"))
		Wave/Z LineProfileIntensity=root:Packages:Convert2Dto1D:LineProfileIntensity
		Wave/Z LineProfileError=root:Packages:Convert2Dto1D:LineProfileIntSdev
		Wave/Z LineProfileQ=root:Packages:Convert2Dto1D:LineProfileQvalues
		Wave/Z LineProfileQy=root:Packages:Convert2Dto1D:LineProfileQy
		Wave/Z LineProfileQx=root:Packages:Convert2Dto1D:LineProfileQx
		Wave/Z LineProfileAzAvalues = root:Packages:Convert2Dto1D:LineProfileAzAvalues
		Wave/Z LineProfileYValsPix=root:Packages:Convert2Dto1D:LineProfileYValsPix
		Wave/Z LineProfileQz=root:Packages:Convert2Dto1D:LineProfileQz
		Wave/Z LineProfileZValsPix=root:Packages:Convert2Dto1D:LineProfileZValsPix
		WAVE/Z LineProfileDspacingWidth=root:Packages:Convert2Dto1D:LineProfileDspacingWidth
		WAVE/Z LineProfileDistacneInmmWidth=root:Packages:Convert2Dto1D:LineProfileDistacneInmmWidth
		WAVE/Z LineProfileTwoThetaWidth=root:Packages:Convert2Dto1D:LineProfileTwoThetaWidth
		WAVE/Z LineProfiledQvalues=root:Packages:Convert2Dto1D:LineProfiledQvalues
		if(!WaveExists(LineProfileQx)||numpnts(LineProfileQx)!=numpnts(LineProfileQy))
			Duplicate/O LineProfileQy, LineProfileQx
		endif
		Duplicate/O/Free LineProfileZValsPix tempWv1234, tempWv1235,tempWv1236
	else
		wave/Z Qvector=root:Packages:Convert2Dto1D:Qvector
		wave/Z Dspacing=root:Packages:Convert2Dto1D:Dspacing
		wave/Z TwoTheta=root:Packages:Convert2Dto1D:TwoTheta
		wave/Z TwoThetaWidth=root:Packages:Convert2Dto1D:TwoThetaWidth
		wave/Z DspacingWidth=root:Packages:Convert2Dto1D:DspacingWidth
		wave/Z DistanceInmm=root:Packages:Convert2Dto1D:DistanceInmm
		wave/Z DistacneInmmWidth=root:Packages:Convert2Dto1D:DistacneInmmWidth
		wave/Z Intensity=root:Packages:Convert2Dto1D:Intensity
		wave/Z Error=root:Packages:Convert2Dto1D:Error
		wave/Z Qsmearing=root:Packages:Convert2Dto1D:Qsmearing
	endif
	Wave CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
	SVAR LoadedFile=root:Packages:Convert2Dto1D:FileNameToLoad
	SVAR UserSampleName=root:Packages:Convert2Dto1D:UserSampleName
	SVAR UserFileName=root:Packages:Convert2Dto1D:OutputDataName
	SVAR TempOutputDataname=root:Packages:Convert2Dto1D:TempOutputDataname
	SVAR TempOutputDatanameUserFor=root:Packages:Convert2Dto1D:TempOutputDatanameUserFor
	NVAR ExportDataOutOfIgor=root:Packages:Convert2Dto1D:ExportDataOutOfIgor
	NVAR StoreDataInIgor=root:Packages:Convert2Dto1D:StoreDataInIgor
	NVAR Use2DdataName=root:Packages:Convert2Dto1D:Use2DdataName
	NVAR DisplayDataAfterProcessing=root:Packages:Convert2Dto1D:DisplayDataAfterProcessing
	NVAR OverwriteDataIfExists=root:Packages:Convert2Dto1D:OverwriteDataIfExists
	NVAR UseQvector=root:Packages:Convert2Dto1D:UseQvector
	NVAR UseTheta=root:Packages:Convert2Dto1D:UseTheta
	NVAR UseDspacing=root:Packages:Convert2Dto1D:UseDspacing
	NVAR UseDistanceFromCenter=root:Packages:Convert2Dto1D:UseDistanceFromCenter
	NVAR UseSampleNameFnct=root:Packages:Convert2Dto1D:UseSampleNameFnct
	SVAR functionName = root:Packages:Convert2Dto1D:SampleNameFnct
	SVAR UserSampleName=root:Packages:Convert2Dto1D:UserSampleName
	
	
	variable ItemsInLst, i
	string OldNote
	string LocalUserFileName
	string UseName
	string LongUseName
	string OriginalUserName
	if (Use2DdataName)
		controlinfo/W=NI1A_Convert2Dto1Dpanel Select2DDataType
		if(cmpstr(S_Value,"BSL/SAXS")==0)
			NVAR BSLcurrentframe=$("root:Packages:NI1_BSLFiles:BSLcurrentframe")
			NVAR BSLfromframe=$("root:Packages:NI1_BSLFiles:BSLfromframe")
			NVAR BSLtoframe=$("root:Packages:NI1_BSLFiles:BSLtoframe")
			NVAR BSLaverage=$("root:Packages:NI1_BSLFiles:BSLaverage")
			NVAR BSLsumframes=$("root:Packages:NI1_BSLFiles:BSLsumframes")
			NVAR BSLsumseq=$("root:Packages:NI1_BSLFiles:BSLsumseq")

			if(BSLaverage)
				UseName=UserSampleName[0,9]+"_Average_"+CurOrient
			elseif(BSLsumframes||BSLsumseq)
				UseName=UserSampleName[0,9]+"_"+num2str(BSLfromframe)+"-"+num2str(BSLtoframe)+"_"+CurOrient
			else
				UseName=UserSampleName[0,9]+"_"+num2str(BSLcurrentframe)+"_"+CurOrient
			endif
		else
			//variable tempEnd=26-strlen(CurOrient)
			OriginalUserName = UserSampleName+"_"+CurOrient
			UseName=NI1A_TrimCleanDataName(UserSampleName, CurOrient)+"_"+CurOrient
		endif
	else
		if(UseSampleNameFnct)			//user provided function
			if(exists(functionName)==6)
				string tempStrName
				FUNCREF NI1A_UserNameStrProto UserStrNameFnct=$(functionName)
				tempStrName = UserStrNameFnct(CCDImageToConvert, UserSampleName)
				if(strlen(tempStrName)<1)		// nothing came back?
					Abort "Name function returned nothing"
				endif
				UserFileName = tempStrName
				OriginalUserName = UserFileName+"_"+CurOrient
				UseName=NI1A_TrimCleanDataName(UserFileName, CurOrient)+"_"+CurOrient		
				//setDataFolder OldDF1
			else
				Abort "No valid function returning string for data name was specified. Check the Function name" 
			endif
		else
			if(strlen(UserFileName)<1)	//user did not set the file name
				if(cmpstr(TempOutputDatanameUserFor,LoadedFile)==0 && strlen(TempOutputDataname)>0)		//this file output was already asked for user
					LocalUserFileName = TempOutputDataname
				else
					Prompt LocalUserFileName, "No name for this sample selected, data name is "+ LoadedFile
					DoPrompt /HELP="Input name for the data to be stored, max 17 characters" "Input name for the 1D data", LocalUserFileName
					if(V_Flag)
						abort
					endif
					TempOutputDataname = LocalUserFileName
					TempOutputDatanameUserFor = UserSampleName
				endif
				OriginalUserName = LocalUserFileName+"_"+CurOrient
				UseName=NI1A_TrimCleanDataName(LocalUserFileName, CurOrient)+"_"+CurOrient
			else
				UseName=NI1A_TrimCleanDataName(UserFileName, CurOrient)+"_"+CurOrient
			endif
		endif
	endif
	UseName=cleanupName(UseName, 1 )
	NVAR/Z USAXSWAXSselector = root:Packages:Convert2Dto1D:USAXSWAXSselector
	NVAR/Z USAXSSAXSselector = root:Packages:Convert2Dto1D:USAXSSAXSselector
	NVAR/Z USAXSBigSAXSselector = root:Packages:Convert2Dto1D:USAXSBigSAXSselector
	String DataFolderNameL
	if(NVAR_Exists(USAXSWAXSselector))
		if(USAXSWAXSselector)
			DataFolderNameL = "root:WAXS"
			LongUseName="root:WAXS:"+possiblyQuoteName(UseName)
		elseif(USAXSBigSAXSselector)
			DataFolderNameL = "root:SAXS"
			LongUseName="root:SAXS:"+possiblyQuoteName(UseName)
		else  //USAXSSAXSselector
			DataFolderNameL = "root:SAXS"
			LongUseName="root:SAXS:"+possiblyQuoteName(UseName)		
		endif
	else
		DataFolderNameL = "root:SAS"
		LongUseName="root:SAS:"+possiblyQuoteName(UseName)
	endif
	//split for code for line profile and sectors...
	if(stringmatch(CurOrient, "*LP*"))		//Line profile code goes here...***************
		//this seems to fail in cases when too much of the detector is covered by NaNs (masked).
		//Image line profile is giving NaNs as Std deviation... 
		//we need to "fix" that by not removing points with error of NaN, just replacing it with error 0.
		LineProfileError = (numtype(LineProfileError[p])==0) ? LineProfileError[p] : 0
		//OK, now if the error was NaN, it is 0. 	
		NI1A_RemoveInfNaNsFrom10Waves(LineProfileIntensity,LineProfileError,LineProfileQ,LineProfileQy,LineProfileYValsPix,LineProfileQz,LineProfileQx,LineProfiledQvalues,tempWv1235,tempWv1236 )	
		SVAR LineProf_CurveType=root:Packages:Convert2Dto1D:LineProf_CurveType	
		if(StoreDataInIgor)
				NewDataFolder/O/S $(DataFolderNameL)
				if(DataFolderExists(LongUseName) && !OverwriteDataIfExists)
					DoALert 1, "This data folder exists, overwrite?"
					if (V_Flag==2)
						Abort
					endif
				endif
				NewDataFolder/S/O $(LongUseName)
				string/g UserSampleName=	OriginalUserName
					//print possiblyquotename("r_"+UseName)
					Duplicate/O LineProfileIntensity, $("r_"+UseName)
					Duplicate/O LineProfileQ, $("q_"+UseName)
					Duplicate/O LineProfileError, $("s_"+UseName)
					Duplicate/O LineProfiledQvalues, $("w_"+UseName)
					Duplicate/O LineProfileQy, $("qy_"+UseName)
					Duplicate/O LineProfileQz, $("qz_"+UseName)	
					Duplicate/O  LineProfileAzAvalues , $("az_"+UseName)
					if(stringmatch(LineProf_CurveType, "GI*"))
						Duplicate/O LineProfileQx, $("qx_"+UseName)	
					endif		
				//and resort for users so these are relaibly acording to Q values
					Wave wv1= $("r_"+UseName)
					Wave wv2= $("q_"+UseName)
					Wave wv3= $("s_"+UseName)
					Wave wv4= $("qz_"+UseName)	
					Wave wv5= $("qy_"+UseName)
					Wave wv7= $("az_"+UseName)	
					note wv2, "Units=1/A;"
					note wv4, "Units=1/A;"
					note wv5, "Units=1/A;"
				if(stringmatch(LineProf_CurveType, "GI*"))
						Wave/Z wv6= $("qx_"+UseName)	
						note wv6, "Units=1/A;"
						Sort wv2, wv1, wv2, wv3, wv4, wv5, wv6, wv7
				elseif(stringmatch(LineProf_CurveType, "Ellipse"))
						Sort wv7, wv1, wv2, wv3, wv4, wv5, wv7
				else
						Sort wv2, wv1, wv2, wv3, wv4, wv5, wv7
				endif		
					
			endif
			if(ExportDataOutOfIgor)
				OldNote=note(LineProfileIntensity)
				ItemsInLst=ItemsInList(OldNote)
		
				make/T/O/N=(ItemsInLst) TextWv 		
				For (i=0;i<ItemsInLst;i+=1)
					TextWv[i]="#   "+stringFromList(i,OldNote)
				endfor
				Duplicate/O LineProfileQ, LineProfQ
				Duplicate/O LineProfileQy, LineProfQy
				if(stringmatch(LineProf_CurveType, "GI*"))
					Duplicate/O LineProfileQx, LineProfQx
					redimension/S LineProfQx
				endif
				if(stringmatch(LineProf_CurveType, "Ellipse"))
					Duplicate/O LineProfileAzAvalues, LineProfileAz
					redimension/S LineProfileAz
				endif
				Duplicate/O LineProfileQz, LineProfQz
				Duplicate/O LineProfileIntensity,LineProfIntensity
				Duplicate/O LineProfileError,LineProfError
				Redimension/S LineProfQ, LineProfQy, LineProfQz, LineProfIntensity, LineProfError
								
				Save/G/O/M="\r\n"/P=Convert2Dto1DOutputPath TextWv as (UseName+".dat")
				if(stringmatch(LineProf_CurveType, "GI*"))
					sort  LineProfQ, LineProfQ, LineProfQx, LineProfQy, LineProfQz, LineProfIntensity, LineProfError
					Save/A/W/J/M="\r\n"/P=Convert2Dto1DOutputPath LineProfQ, LineProfQx, LineProfQy, LineProfQz, LineProfIntensity, LineProfError as (UseName+".dat")			
				elseif(stringmatch(LineProf_CurveType, "Ellipse"))
					sort  LineProfileAz, LineProfileAz, LineProfQ, LineProfQy, LineProfQz, LineProfIntensity, LineProfError
					Save/A/W/J/M="\r\n"/P=Convert2Dto1DOutputPath LineProfQ, LineProfQy, LineProfQz,LineProfileAz, LineProfIntensity, LineProfError as (UseName+".dat")			
				else
					sort  LineProfQ, LineProfQ, LineProfQy, LineProfQz,  LineProfIntensity, LineProfError
					Save/A/W/J/M="\r\n"/P=Convert2Dto1DOutputPath LineProfQ, LineProfQy, LineProfQz, LineProfIntensity, LineProfError as (UseName+".dat")			
				endif		
				KillWaves/Z TextWv, LineProfQ, LineProfQy,LineProfQx, LineProfQz,LineProfileAz, LineProfIntensity, LineProfError
			endif

				SVAR LineProf_CurveType = root:Packages:Convert2Dto1D:LineProf_CurveType			
				if(stringmatch(LineProf_CurveType,"Horizontal Line")||stringmatch(LineProf_CurveType,"GI_Horizontal Line"))
					Wave Int=$("r_"+UseName)
					Wave Qvec=$("qy_"+UseName)
					Wave err=$("s_"+UseName)
					if(DisplayDataAfterProcessing)
						NI1A_DisplayLineoutAfterProc(int,Qvec,Err,1,1)
					endif
				elseif(stringmatch(LineProf_CurveType,"Vertical Line")||stringmatch(LineProf_CurveType,"GI_Vertical Line"))
					Wave Int=$("r_"+UseName)
					Wave Qvec=$("qz_"+UseName)
					Wave err=$("s_"+UseName)
					if(DisplayDataAfterProcessing)
						NI1A_DisplayLineoutAfterProc(int,Qvec,Err,1,1)
					endif
				elseif(stringmatch(LineProf_CurveType,"Ellipse"))
					Wave Int=$("r_"+UseName)
					Wave Qvec=$("az_"+UseName)
					Wave err=$("s_"+UseName)
					if(DisplayDataAfterProcessing)
						NI1A_DisplayLineoutAfterProc(int,Qvec,Err,1,4)
					endif
				else			//these are the others, use q value and display as log-log. 
					Wave Int=$("r_"+UseName)
					Wave Qvec=$("q_"+UseName)
					Wave err=$("s_"+UseName)
					if(DisplayDataAfterProcessing)
						NI1A_DisplayLineoutAfterProc(int,Qvec,Err,1,1)
						endif
				endif
				OldNote=note(Int)
				//DataType = "qrs", "trs", "drs", "distrs"
				Duplicate/Free Qvec, dQvec
				dQvec[1,numpnts(Qvec)-2] = Qvec[p+1]-Qvec[p-1]
				dQvec[0]=dQvec[1]
				dQvec[numpnts(Qvec)-1] = dQvec[numpnts(Qvec)-2] 
				NEXUS_WriteNx1DCanSASNika(UserSampleName, Int, Err, Qvec, dQvec, CurOrient, OldNote)

			KillWaves/Z tempWv1234
	else		//sectors profiles goes here. *****************
		NI1A_RemoveInfNaNsFrom10Waves(Intensity,Qvector,Error,Qsmearing,TwoTheta,TwoThetaWidth,Dspacing,DspacingWidth,DistanceInmm, DistacneInmmWidth )	
		if(StoreDataInIgor)
			NewDataFolder/O/S $(DataFolderNameL)
			if(DataFolderExists(LongUseName) && !OverwriteDataIfExists)
				DoALert 1, "This data folder exists, overwrite?"
				if (V_Flag==2)
					Abort
				endif
			endif
			NewDataFolder/S/O $(LongUseName)
			string/g UserSampleName=	OriginalUserName
			if (UseQvector)
				Duplicate/O Intensity, $("r_"+UseName)
				Duplicate/O Qvector, $("q_"+UseName)
				note $("q_"+UseName), "Units=1/A;"
				Duplicate/O Error, $("s_"+UseName)
				Duplicate/O Qsmearing, $("w_"+UseName)
			elseif(UseTheta)
				Duplicate/O Intensity, $("r_"+UseName)
				Duplicate/O TwoTheta, $("t_"+UseName)
				note $("t_"+UseName), "Units=degree;"
				Duplicate/O Error, $("s_"+UseName)
				Duplicate/O TwoThetaWidth, $("w_"+UseName)
			elseif(UseDspacing)
				Duplicate/O Intensity, $("r_"+UseName)
				Duplicate/O Dspacing, $("d_"+UseName)
				note $("d_"+UseName), "Units=A;"
				Duplicate/O Error, $("s_"+UseName)
				Duplicate/O DspacingWidth, $("w_"+UseName)		
			elseif(UseDistanceFromCenter)
				Duplicate/O Intensity, $("r_"+UseName)
				Duplicate/O DistanceInmm, $("m_"+UseName)
				note $("m_"+UseName), "Units=mm;"
				Duplicate/O Error, $("s_"+UseName)
				Duplicate/O DistacneInmmWidth, $("w_"+UseName)		
			else
				abort "Error - no output type selected"
			endif
			
		endif
		//Convert2Dto1DOutputPath
		if(ExportDataOutOfIgor)
			OldNote=note(Intensity)
			ItemsInLst=ItemsInList(OldNote)
			NVAR/Z SaveGSASdata=root:Packages:Convert2Dto1D:SaveGSASdata
			if(!NVAR_Exists(SaveGSASdata))
				variable/g SaveGSASdata=0
			endif
			
			variable refnum
			string FinalOutputName, HeaderSeparator
			HeaderSeparator = "#   "
			make/T/O/N=(ItemsInLst) TextWv 		
			if(!(UseTheta && SaveGSASdata))
				For (i=0;i<ItemsInLst;i+=1)
					TextWv[i]=HeaderSeparator+stringFromList(i,OldNote)
				endfor
				Save/G/O/M="\r\n"/P=Convert2Dto1DOutputPath TextWv as (UseName+".dat")
			endif
			if (UseQvector)
				Save/A/G/M="\r\n"/P=Convert2Dto1DOutputPath Qvector,Intensity,Error,Qsmearing as (UseName+".dat")
			elseif(UseTheta)
				if(SaveGSASdata)
					//this is ild GSA file for GSAS-I, change 2019-05 to xye file format... 
					//					//first create header...
					//					Redimension/N=2 TextWV
					//					Duplicate/O TwoTheta, TwoThetaCentidegrees
					//					TwoThetaCentidegrees*=100
					//					//create the text header... 
					//					String Header1="BANK 1 "+num2str(numpnts(TwoTheta))+" "+num2str(numpnts(TwoTheta))+" CONS "
					//					variable StarANgle=TwoThetaCentidegrees[0]
					//					variable StepSize=(TwoThetaCentidegrees(numpnts(TwoTheta)-1) - TwoThetaCentidegrees[0])/(numpnts(TwoTheta)-1)
					//					string TempHeader
					//					sprintf TempHeader, "%E %E", StarANgle, StepSize
					//					Header1+=TempHeader
					//					Header1+=" 0 0 FXYE"
					//					TextWv[0]=stringFromList(0,OldNote)+";"+stringFromList(1,OldNote)
					//					TextWV[1]=Header1
					//					Save/G/O/M="\r\n"/P=Convert2Dto1DOutputPath TextWv as (UseName+".GSA")
					//					Save/A=2/G/M="\r\n"/P=Convert2Dto1DOutputPath TwoThetaCentidegrees,Intensity,Error as (UseName+".GSA")
					//					KillWaves TwoThetaCentidegrees
					FinalOutputName = UseName+".xye"
					Open/Z=1 /R/P=Convert2Dto1DOutputPath refnum as FinalOutputName
					if(V_Flag==0)
						DoAlert 1, "The file with this name: "+FinalOutputName+ " in this location already exists, overwrite?"
						if(V_Flag!=1)
							abort
						endif
						close/A
						//user wants to delete the file
						OpenNotebook/V=0/P=Convert2Dto1DOutputPath/N=JunkNbk  FinalOutputName
						DoWindow/D /K JunkNbk
					endif
					close/A
					Duplicate Intensity, NoteTempY
					string OldNoteT1=note(Intensity)
					note/K NoteTempY
					note NoteTempY, OldNoteT1+"Exported="+date()+" "+time()+";"
					variable wvlgth = NumberByKey("Nika_Wavelength", OldNoteT1 , "=", ";")
					if (UseQvector)
						wave XWaveTmp = $("q_"+UseName)
						Duplicate/Free XWaveTmp, XWave
						XWave = 2 * 180/pi * asin(XWaveTmp * wvlgth /(4*pi))		
					elseif(UseTheta)
						wave XWave = $("t_"+UseName)
					elseif(UseDspacing)
						wave XWaveTmp = $("d_"+UseName)
						Duplicate/Free XWaveTmp, XWave
						XWave = 2 * 180/pi * (wvlgth / (2*XWaveTmp))
					else
						abort "GSAS xye output error - not suitabel data, need TwoTheta, d-spacing or q_ as x-wave"
					endif				
					make/T/O WaveNoteWave
					if (1)
						IN2G_PasteWnoteToWave("NoteTempY",WaveNoteWave ,HeaderSeparator)
						InsertPoints 0, 2, WaveNoteWave
						InsertPoints numpnts(WaveNoteWave), 2, WaveNoteWave
						WaveNoteWave[0] = "/*"
						WaveNoteWave[1] = HeaderSeparator+"wavelength = "+num2str(wvlgth)
						WaveNoteWave[numpnts(WaveNoteWave)-2] = "# 2Theta  Intensity  Error"	
						WaveNoteWave[numpnts(WaveNoteWave)-1] = "*/"	
						Save/G/M="\r\n"/P=Convert2Dto1DOutputPath WaveNoteWave as FinalOutputName
					endif
					Save/A=2/G/M="\r\n"/P=Convert2Dto1DOutputPath XWave,Intensity,Error as FinalOutputName			///P=Datapath
					KillWaves/Z WaveNoteWave, NoteTempY
				else
					Save/A/G/M="\r\n"/P=Convert2Dto1DOutputPath TwoTheta,Intensity,Error,TwoThetaWidth as (UseName+".dat")
				endif		
			elseif(UseDspacing)
				Save/A/G/M="\r\n"/P=Convert2Dto1DOutputPath Dspacing,Intensity,Error,DspacingWidth as (UseName+".dat")
			elseif(UseDistanceFromCenter)
				Save/A/G/M="\r\n"/P=Convert2Dto1DOutputPath DistanceInmm,Intensity,Error,DistacneInmmWidth as (UseName+".dat")
			else
				abort "Error - no output type selected"
			endif
			KillWaves TextWv
		endif

		OldNote=note(Intensity)
		//DataType = "qrs", "trs", "drs", "distrs"
		if (UseQvector)
			NEXUS_WriteNx1DCanSASNika(UserSampleName,  Intensity, Error, Qvector, Qsmearing, CurOrient, OldNote)
		elseif(UseTheta)
			NEXUS_WriteNx1DCanSASNika(UserSampleName,  Intensity, Error, TwoTheta, TwoThetaWidth, CurOrient, OldNote)
		elseif(UseDspacing)
			NEXUS_WriteNx1DCanSASNika(UserSampleName,  Intensity, Error, Dspacing, DspacingWidth, CurOrient, OldNote)
		elseif(UseDistanceFromCenter)
			NEXUS_WriteNx1DCanSASNika(UserSampleName, Intensity, Error, DistanceInmm, DistacneInmmWidth, CurOrient, OldNote)
		endif
		if(DisplayDataAfterProcessing)
			if (UseQvector)
				Wave Int=$("r_"+UseName)
				Wave Qvec=$("q_"+UseName)
				Wave err=$("s_"+UseName)
				NI1A_DisplayLineoutAfterProc(int,Qvec,Err,1,1)
			elseif(UseTheta)
				Wave Int=$("r_"+UseName)
				Wave TwoTheta=$("t_"+UseName)
				Wave err=$("s_"+UseName)
				NI1A_DisplayLineoutAfterProc(int,TwoTheta,Err,1,3)
			elseif(UseDspacing)
				Wave Int=$("r_"+UseName)
				Wave Dspacing=$("d_"+UseName)
				Wave err=$("s_"+UseName)
				NI1A_DisplayLineoutAfterProc(int,Dspacing,Err,1,2)
			elseif(UseDistanceFromCenter)
				Wave Int=$("r_"+UseName)
				Wave DistanceInmm=$("m_"+UseName)
				Wave err=$("s_"+UseName)
				NI1A_DisplayLineoutAfterProc(int,DistanceInmm,Err,1,5)
			else
				abort "Error - no output type selected"
			endif
		endif
	endif		//end of sectors part...
	//Movie part...
	SVAR Movie_Last1DdataSet=root:Packages:Convert2Dto1D:Movie_Last1DdataSet
	Movie_Last1DdataSet=LongUseName		//this is last 1D data set loaded... 
	NI1A_MovieRecordFrameIfReq(1)	
	
	setDataFolder OldDf
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function/T NI1A_TrimCleanDataName(InputName, CurOrient)
	string InputName, CurOrient
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR TrimFrontOfName=root:Packages:Convert2Dto1D:TrimFrontOfName
	NVAR TrimEndOfName=root:Packages:Convert2Dto1D:TrimEndOfName
	SVAR RemoveStringFromName = root:Packages:Convert2Dto1D:RemoveStringFromName
	string NewName, tempStr
	tempStr = ReplaceString(".", InputName, "")
	variable NumDots= strlen(InputName) - strlen(tempStr)
	NewName = InputName
	NewName = ReplaceString(RemoveStringFromName, NewName, "")
	variable MaxLengthAllowed = 26 - strlen(CurOrient)
	//OK, modify for Igor 8
	NVAR useIgor8LongNames = root:Packages:IrenaConfigFolder:Igor8UseLongNames
	if(IgorVersion()>7.99 && useIgor8LongNames)		//this is Igor 8 code and user wnts to us long names. In this case trimming of name is not necessary, unless asked for
			NewName= IN2G_CreateUserName(NewName,MaxLengthAllowed, 0, 11)	
	else
		if(TrimEndOfName)
			//NewName= NewName[0,MaxLengthAllowed]
			NewName= IN2G_CreateUserName(NewName,MaxLengthAllowed, 0, 11)
		else
			NewName= NewName[strlen(NewName)-MaxLengthAllowed,inf]
		endif
	endif
	return NewName
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_DisplayLineoutAfterProc(int,Qvec,Err,NumOfWavesToKeep,typeGraph)
	wave int,Qvec,Err
	variable NumOfWavesToKeep
	variable typeGraph	//1 for q, 2 for d, and 3 for twoTheta, 4 for azimuthal angle

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR UseBatchProcessing=root:Packages:Convert2Dto1D:UseBatchProcessing
	if(UseBatchProcessing)
		return 0
	endif
	
	if(typeGraph==1)
		DoWindow LineuotDisplayPlot_Q
		if(V_Flag)
			DoWindow/F LineuotDisplayPlot_Q
			CheckDisplayed /W=LineuotDisplayPlot_Q  $(NameOfWave(Int))
			if(!V_Flag) 
				appendToGraph Int vs Qvec 
			endif
		else
			//Display/K=1 /W=(348,368,828,587.75) Int vs Qvec as "LineuotDisplayPlot_Q"	
			Display/K=1 /W=(350,350,350+0.5*IN2G_GetGraphWidthHeight("width"),350+0.5*IN2G_GetGraphWidthHeight("height")) Int vs Qvec as "LineuotDisplayPlot_Q"	
			DoWIndow/C LineuotDisplayPlot_Q
			AutoPositionWindow/M=1/E/R=NI1A_Convert2Dto1DPanel  LineuotDisplayPlot_Q	
			ModifyGraph log=1
			Label left "Intensity"
			Label bottom "Q vector [A\\S-1\\M]"
			Doupdate
		endif		
	elseif(typeGraph==2)
		DoWindow LineuotDisplayPlot_D
		if(V_Flag)
			DoWindow/F LineuotDisplayPlot_D
			CheckDisplayed /W=LineuotDisplayPlot_D  $(NameOfWave(Int))
			if(!V_Flag) 
				appendToGraph Int vs Qvec 
			endif
		else
			//Display/K=1 /W=(348,368,828,587.75) Int vs Qvec as "LineuotDisplayPlot_D"	
			Display/K=1 /W=(350,350,350+0.5*IN2G_GetGraphWidthHeight("width"),350+0.5*IN2G_GetGraphWidthHeight("height")) Int vs Qvec as "LineuotDisplayPlot_D"	
			DoWIndow/C LineuotDisplayPlot_D
			AutoPositionWindow/M=1/E/R=NI1A_Convert2Dto1DPanel  LineuotDisplayPlot_D	
			ModifyGraph log=0
			Label left "Intensity"
			Label bottom "d spacing [A]"
			Doupdate
		endif		
	elseif(typeGraph==3)
		DoWindow LineuotDisplayPlot_T
		if(V_Flag)
			DoWindow/F LineuotDisplayPlot_T
			CheckDisplayed /W=LineuotDisplayPlot_T  $(NameOfWave(Int))
			if(!V_Flag) 
				appendToGraph Int vs Qvec 
			endif
		else
			//Display/K=1 /W=(348,368,828,587.75) Int vs Qvec as "LineuotDisplayPlot_T"	
			Display/K=1 /W=(350,350,350+0.5*IN2G_GetGraphWidthHeight("width"),350+0.5*IN2G_GetGraphWidthHeight("height")) Int vs Qvec as "LineuotDisplayPlot_T"	
			DoWIndow/C LineuotDisplayPlot_T
			AutoPositionWindow/M=1/E/R=NI1A_Convert2Dto1DPanel  LineuotDisplayPlot_T	
			ModifyGraph log=0
			Label left "Intensity"
			Label bottom "Two theta [degrees]"
			Doupdate
		endif		
	elseif(typeGraph==4)
		DoWindow LineuotDisplayPlot_T
		if(V_Flag)
			DoWindow/F LineuotDisplayPlot_T
			CheckDisplayed /W=LineuotDisplayPlot_T  $(NameOfWave(Int))
			if(!V_Flag) 
				appendToGraph Int vs Qvec 
			endif
		else
			//Display/K=1 /W=(348,368,828,587.75) Int vs Qvec as "LineuotDisplayPlot_Az"	
			Display/K=1 /W=(350,350,350+0.5*IN2G_GetGraphWidthHeight("width"),350+0.5*IN2G_GetGraphWidthHeight("height"))  Int vs Qvec as "LineuotDisplayPlot_Az"	
			DoWIndow/C LineuotDisplayPlot_T
			AutoPositionWindow/M=1/E/R=NI1A_Convert2Dto1DPanel  LineuotDisplayPlot_T	
			ModifyGraph log=0
			Label left "Intensity"
			Label bottom "Azimuthal angle"
			Doupdate
		endif		
	elseif(typeGraph==5)
		DoWindow LineuotDisplayPlot_T
		if(V_Flag)
			DoWindow/F LineuotDisplayPlot_T
			CheckDisplayed /W=LineuotDisplayPlot_T  $(NameOfWave(Int))
			if(!V_Flag) 
				appendToGraph Int vs Qvec 
			endif
		else
			//Display/K=1 /W=(348,368,828,587.75) Int vs Qvec as "LineuotDisplayPlot_Distacne"	
			Display/K=1 /W=(350,350,350+0.5*IN2G_GetGraphWidthHeight("width"),350+0.5*IN2G_GetGraphWidthHeight("height")) Int vs Qvec as "LineuotDisplayPlot_Distacne"	
			DoWIndow/C LineuotDisplayPlot_T
			AutoPositionWindow/M=1/E/R=NI1A_Convert2Dto1DPanel  LineuotDisplayPlot_T	
			ModifyGraph log=0
			Label left "Intensity"
			Label bottom "Distance from center [mm]"
			Doupdate
		endif		
	else
		Abort "error in NI1A_DisplayLineoutAfterProc"
	endif
	IN2G_LegendTopGrphFldr(10, 15,1,0)
	//Legend/C/N=text0/A=RT
	ModifyGraph mirror=1
	IN2G_ColorTopGrphRainbow()
#if Exists("Nika_Hook_AfterDisplayLineout")
	Nika_Hook_AfterDisplayLineout(int,Qvec,Err)
#endif

End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//
//Function NI1A_CCD21D_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
//	String ctrlName
//	Variable varNum
//	String varStr
//	String varName
//
//		if(cmpstr(ctrlName,"SampleToCCDdistance")==0)
//				//here goes what happens
//		endif
//
//
//End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//Function NI1A_setupData(updateLUT)
//		variable updateLUT
//
//		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//		wave QVectorWave=root:Packages:Convert2Dto1D:QVectorWave
//		wave CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
//		wave M_ROIMask=root:Packages:Convert2Dto1D:M_ROIMask
//		wave EmptyData=root:Packages:Convert2Dto1D:EmptyData
//		wave DarkCurrentWave=root:Packages:Convert2Dto1D:DarkField
//
//		Duplicate/O CCDImageToConvert, CorrectedDataWave
//		Redimension/S CorrectedDataWave
//		variable transmission=0.991
//		CorrectedDataWave=(1/transmission)*(CCDImageToConvert-DarkCurrentWave) - (EmptyData-DarkCurrentWave)
//
//		NI1A_CreateConversionLUT(updateLUT, QVectorWave, CorrectedDataWave,M_ROIMask )
//		killwaves/Z temp2D, CorrectedDataWave
//end
//

Function NI1A_CreateConversionLUT(updateLUT, QVectorWave, CCDImageToConvert,M_ROIMask )
	variable updateLUT
	wave QVectorWave, CCDImageToConvert,M_ROIMask
		
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	if(updateLUT)
		NI1A_CreateLUT("C")
	endif
		Wave LUT=root:Packages:Convert2Dto1D:LUT
		Wave HistWave=root:Packages:Convert2Dto1D:HistWave
		variable NumberOfPoints=200  //this is number of points in Q
	make/O/N=(NumberOfPoints) NewQwave, NewIntWave, NewIntErrorWave
	NewQwave=p*0.001
	NewIntWave=0
	NewIntErrorWave=0
	
	variable i, j, counter, numbins
	Duplicate/O LUT, tempInt
	tempInt = CCDImageToConvert
	IndexSort LUT, tempInt
	Duplicate/O tempInt, TempIntSqt
	TempIntSqt = tempInt^2
	counter = HistWave[0]
	For(j=1;j<NumberOfPoints;j+=1)
		numbins = HistWave[j]
		NewIntWave[j] = sum(tempInt, pnt2x(tempInt,Counter), pnt2x(tempInt,Counter+numbins))
		NewIntErrorWave[j] = sum(TempIntSqt, pnt2x(tempInt,Counter), pnt2x(tempInt,Counter+numbins))
		Counter+=numbins
	endfor
	NewIntWave/=HistWave
	NewIntErrorWave=sqrt(NewIntErrorWave-HistWave*NewIntWave*NewIntWave)/(HistWave-1)
	killwaves/Z tempInt, TempIntSqt, temp2D, tempQ, NewQwave
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1A_CreateMovie()	
	//here we setup user to create movies while reducting data
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR Movie_Use2DRAWdata=root:Packages:Convert2Dto1D:Movie_Use2DRAWdata
	NVAR Movie_Use2DProcesseddata=root:Packages:Convert2Dto1D:Movie_Use2DProcesseddata
	NVAR Movie_Use1DData=root:Packages:Convert2Dto1D:Movie_Use1DData
//	if(Movie_Use2DRAWdata+Movie_Use2DProcesseddata+Movie_Use1DData!=0)
//		Movie_Use2DRAWdata=0
//		Movie_Use2DProcesseddata=0
//		Movie_Use1DData=0
//	endif

	DoWIndow NI1A_CreateMoviesPanel
	if(!V_Flag)
		Execute("NI1A_CreateMoviesPanel()")
	else
		Dowindow/F NI1A_CreateMoviesPanel
	endif
	
	AutoPositionWindow/M=0 /R=NI1A_Convert2Dto1DPanel NI1A_CreateMoviesPanel


end


//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************

Window NI1A_CreateMoviesPanel() : Panel
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(455,63,762,443) as "Nika Create Movies panel"
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman",fsize= 18,fstyle= 3,textrgb= (0,0,65535)
	DrawText 69,27,"Create movie panel"

	SetDrawEnv fstyle= 3
	DrawText 10,45,"1. Load and process one data set"
	SetDrawEnv fstyle= 3
	DrawText 10,65,"2. Decide what to use for movie"
	
	CheckBox Movie_Use2DRAWdata,pos={10,75},size={80,16},proc=NI1A_MovieCheckProc,title="Use 2D RAW data ?", mode=1
	CheckBox Movie_Use2DRAWdata,variable= root:Packages:Convert2Dto1D:Movie_Use2DRAWdata, help={"Check to use RAW 2D data for the movie?"}
	CheckBox Movie_Use2DProcesseddata,pos={10,95},size={80,16},proc=NI1A_MovieCheckProc,title="Use 2D Calibrated?", mode=1
	CheckBox Movie_Use2DProcesseddata,variable= root:Packages:Convert2Dto1D:Movie_Use2DProcesseddata, help={"Check to use Processed (Calibrated) 2D data"}
	CheckBox Movie_Use1DData,pos={10,115},size={80,16},proc=NI1A_MovieCheckProc,title="Use 1D data?", mode=1
	CheckBox Movie_Use1DData,variable= root:Packages:Convert2Dto1D:Movie_Use1DData, help={"Check to use reduced 1D data"}

	CheckBox Movie_UseMain2DImage,pos={150,75},size={80,16},proc=NI1A_MovieCheckProc,title="Use main 2D img ?", mode=1
	CheckBox Movie_UseMain2DImage,variable= root:Packages:Convert2Dto1D:Movie_UseMain2DImage, help={"Check to usethe main 2D imagea for the movie?"}
	CheckBox Movie_UseUserHookFnct,pos={150,95},size={80,16},proc=NI1A_MovieCheckProc,title="Use user Hook fnct?", mode=1
	CheckBox Movie_UseUserHookFnct,variable= root:Packages:Convert2Dto1D:Movie_UseUserHookFnct, help={"Check to use if you want to write user hook function to  generate image for movie"}


	
	Button OpenMovieGraph title="Create Img/Graph",pos={30,133},size={220,20}, help={"Create Graph/Image if needed"}
	Button OpenMovieGraph proc=NI1A_MovieButtonProc

	SetDrawEnv fstyle= 3
	DrawText 10,170,"3. Modify the Image/graph "
	CheckBox Movie_AppendFileName,pos={30,175},size={80,16},proc=NI1A_MovieCheckProc,title="Append File Name as Legend?"
	CheckBox Movie_AppendFileName,variable= root:Packages:Convert2Dto1D:Movie_AppendFileName, help={"Check to append file name as legend"}
	CheckBox Movie_DisplayLogInt,pos={30,195},size={80,16},proc=NI1A_MovieCheckProc,title="Log Int (2D images only)?"
	CheckBox Movie_DisplayLogInt,variable= root:Packages:Convert2Dto1D:Movie_DisplayLogInt, help={"Check to append file name as legend"}

	SetDrawEnv fstyle= 3
	DrawText 10,240,"4. Create movie file "
	Button OpenMovieFile title="Open Movie file for writing",pos={30,250},size={180,20}
	Button OpenMovieFile proc=NI1A_MovieButtonProc, disable=(2*root:Packages:Convert2Dto1D:Movie_FileOpened)
	SetVariable Movie_FrameRate,pos={170,228},size={130,22}, title="Frame Rate", limits={1,60,0}
	SetVariable Movie_FrameRate variable=root:Packages:Convert2Dto1D:Movie_FrameRate

	SetDrawEnv fstyle= 3
	DrawText 10,285,"5. Append Images to movie file "
	Button Movie_AppendFrame title="Append current Frame",pos={30,290},size={220,20}
	Button Movie_AppendFrame proc=NI1A_MovieButtonProc
	CheckBox Movie_AppendAutomatically,pos={30,315},size={80,16},proc=NI1A_MovieCheckProc,title="Append Frames Automatically?"
	CheckBox Movie_AppendAutomatically,variable= root:Packages:Convert2Dto1D:Movie_AppendAutomatically, help={"Check to append frames as data are processed"}

	SetDrawEnv fstyle= 3
	DrawText 10,345,"6. Close movie file "

	Button Movie_CloseFile title="Close Movie File",pos={30,350},size={220,20}
	Button Movie_CloseFile proc=NI1A_MovieButtonProc

	
EndMacro

//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function NI1A_MovieCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR Movie_Use2DRAWdata=root:Packages:Convert2Dto1D:Movie_Use2DRAWdata
	NVAR Movie_Use2DProcesseddata=root:Packages:Convert2Dto1D:Movie_Use2DProcesseddata
	NVAR Movie_Use1DData=root:Packages:Convert2Dto1D:Movie_Use1DData
	NVAR Movie_FileOpened=root:Packages:Convert2Dto1D:Movie_FileOpened
	NVAR  Movie_UseMain2DImage = root:Packages:Convert2Dto1D:Movie_UseMain2DImage
	NVAR  Movie_UseUserHookFnct = root:Packages:Convert2Dto1D:Movie_UseUserHookFnct

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(stringmatch(cba.ctrlName,"Movie_Use2DRAWdata"))
				Movie_Use2DRAWdata = checked
				Movie_Use2DProcesseddata=!checked
				Movie_Use1DData=!checked
				Movie_UseMain2DImage = !checked
				Movie_UseUserHookFnct=!checked

				NI1A_MovieUpdateMain2DImage()
				NI1A_MovieCreateUpdate1DGraphF()
				NI1A_MovieCreateUpdateImageFnct()
				NI1A_MovieCallUserHookFunction()
			endif
			if(stringmatch(cba.ctrlName,"Movie_Use2DProcesseddata"))
				Movie_Use2DRAWdata = !checked
				Movie_Use2DProcesseddata=checked
				Movie_Use1DData=!checked
				Movie_UseMain2DImage = !checked
				Movie_UseUserHookFnct=!checked

				NI1A_MovieUpdateMain2DImage()
				NI1A_MovieCreateUpdate1DGraphF()
				NI1A_MovieCreateUpdateImageFnct()
				NI1A_MovieCallUserHookFunction()
			endif
			if(stringmatch(cba.ctrlName,"Movie_Use1DData"))
				Movie_Use2DRAWdata = !checked
				Movie_Use2DProcesseddata=!checked
				Movie_Use1DData=checked
				Movie_UseMain2DImage = !checked
				Movie_UseUserHookFnct=!checked
				NI1A_MovieCreateUpdate1DGraphF()
				NI1A_MovieCreateUpdateImageFnct()
			endif
			if(stringmatch(cba.ctrlName,"Movie_UseMain2DImage"))
				Movie_Use2DRAWdata = !checked
				Movie_Use2DProcesseddata=!checked
				Movie_Use1DData=!checked
				Movie_UseMain2DImage = checked
				Movie_UseUserHookFnct=!checked

				NI1A_MovieUpdateMain2DImage()
				NI1A_MovieCreateUpdate1DGraphF()
				NI1A_MovieCreateUpdateImageFnct()
				NI1A_MovieCallUserHookFunction()
			endif
			if(stringmatch(cba.ctrlName,"Movie_UseUserHookFnct"))
				Movie_Use2DRAWdata = !checked
				Movie_Use2DProcesseddata=!checked
				Movie_Use1DData=!checked
				Movie_UseMain2DImage = !checked
				Movie_UseUserHookFnct=checked

				NI1A_MovieUpdateMain2DImage()
				NI1A_MovieCreateUpdate1DGraphF()
				NI1A_MovieCreateUpdateImageFnct()
				NI1A_MovieCallUserHookFunction()
			endif
			if(stringmatch(cba.ctrlName,"Movie_AppendFileName"))
				NI1A_MovieUpdateMain2DImage()
				NI1A_MovieCreateUpdate1DGraphF()
				NI1A_MovieCreateUpdateImageFnct()
				NI1A_MovieCallUserHookFunction()
			endif
			if(stringmatch(cba.ctrlName,"Movie_DisplayLogInt"))
				NI1A_MovieUpdateMain2DImage()
				NI1A_MovieCreateUpdate1DGraphF()
				NI1A_MovieCreateUpdateImageFnct()
				NI1A_MovieCallUserHookFunction()
			endif
			if(stringmatch(cba.ctrlName,"Movie_AppendAutomatically"))
					if(checked && Movie_FileOpened)
						Button CreateMovie win=NI1A_Convert2Dto1DPanel, title="Creating Movie Auto",fColor=(16386,65535,16385)
					else
						Button CreateMovie win=NI1A_Convert2Dto1DPanel, title="Creating Movie Manual",fColor=(16386,65535,16385)
					endif
			endif
			
		
			DoWindow/F NI1A_CreateMoviesPanel
			
			break
	endswitch

	return 0
End
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function NI1A_MovieRecordFrameIfReq(OneDPlace)
	variable OneDPlace
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR FIleOpened=root:Packages:Convert2Dto1D:Movie_FileOpened
	if(!FIleOpened)
		return 0
	endif
	NVAR Movie_Use2DRAWdata=root:Packages:Convert2Dto1D:Movie_Use2DRAWdata
	NVAR Movie_Use2DProcesseddata=root:Packages:Convert2Dto1D:Movie_Use2DProcesseddata
	NVAR Movie_UseMain2DImage=root:Packages:Convert2Dto1D:Movie_UseMain2DImage
	NVAR Movie_UseUserHookFnct=root:Packages:Convert2Dto1D:Movie_UseUserHookFnct
	NVAR Movie_Use1DData=root:Packages:Convert2Dto1D:Movie_Use1DData
	
	if(OneDPlace==1&&Movie_Use1DData)
		NI1A_MovieCreateUpdate1DGraphF()
	elseif(OneDPlace==2&&(Movie_Use2DRAWdata||Movie_Use2DProcesseddata||Movie_UseMain2DImage))
		NI1A_MovieUpdateMain2DImage()
		NI1A_MovieCreateUpdateImageFnct()
	elseif(Movie_UseUserHookFnct)
		NI1A_MovieCallUserHookFunction()
	else
		return 0
	endif
	NI1A_MovieAppendTopImage(0)
end
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function NI1A_MovieCreateUpdate1DGraphF()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D:

	NVAR Movie_Use1DData=root:Packages:Convert2Dto1D:Movie_Use1DData
	SVAR Movie_Last1DdataSet=root:Packages:Convert2Dto1D:Movie_Last1DdataSet
	SVAR FileNameToLoad = root:Packages:Convert2Dto1D:FileNameToLoad
	SVAR UserSampleName=root:Packages:Convert2Dto1D:UserSampleName
	SVAR Movie_FileName=root:Packages:Convert2Dto1D:Movie_FileName
	NVAR Movie_AppendFileName=root:Packages:Convert2Dto1D:Movie_AppendFileName
	NVAR Movie_DisplayLogInt=root:Packages:Convert2Dto1D:Movie_DisplayLogInt

	if(!Movie_Use1DData)		//probably want to do 1D graph for Movie
		KillWIndow/Z NI1A_MovieCreate1DGraph
 		return 0
	endif

	if(!DataFolderExists(Movie_Last1DdataSet))
		abort "Data folder with the 1D data does not exist"
	endif
	setDataFolder $Movie_Last1DdataSet
	String IntName=IN2G_ReturnExistingWaveName(Movie_Last1DdataSet,"r_*")
	String Qname=IN2G_ReturnExistingWaveName(Movie_Last1DdataSet,"q_*")
	String Dname=IN2G_ReturnExistingWaveName(Movie_Last1DdataSet,"d_*")
	String TwoThetaName=IN2G_ReturnExistingWaveName(Movie_Last1DdataSet,"t_*")
	String Ename=IN2G_ReturnExistingWaveName(Movie_Last1DdataSet,"s_*")

	Wave/Z Intensity=$(IntName)
	Wave/Z Qvector=$(QName)
	Wave/Z TwoTheta=$(TwoThetaName)
	Wave/Z Dspacing=$(DName)
	
	if(WaveExists(Qvector))
		Wave XWave=$(QName)
	elseif(WaveExists(TwoTheta))
		Wave XWave=$(TwoThetaName)
	elseif(WaveExists(Dspacing))
		Wave XWave=$(Dname)
	else
		abort "X wave (Q, Two Theta or D spacing) does not exist"
	endif
	setDataFolder root:Packages:Convert2Dto1D:
	Duplicate/O Intensity, MovieIntensityWave
	Duplicate/O XWave, MovieXwave
	//now it exists, create image to use:
	DoWindow NI1A_MovieCreate1DGraph
	if(!V_Flag) 
		Display/K=1 MovieIntensityWave vs MovieXwave as  "Movie 1D graph"
		DoWindow/C NI1A_MovieCreate1DGraph
		ModifyGraph mirror=1
		Label left "Intensity [cm\\S-1\\M]"
		Label bottom "Scattering Vector [A\\S-1\\M]"
		AutoPositionWindow  /M=1 /R=NI1A_CreateMoviesPanel NI1A_MovieCreate1DGraph
	else
		DoWIndow/F NI1A_MovieCreate1DGraph
	endif

//		if(Movie_DisplayLogInt)
//			ModifyGraph /W=NI1A_MovieCreate1DGraph log=1
//		else
//			ModifyGraph /W=NI1A_MovieCreate1DGraph log=0
//		endif

	Movie_FileName = Movie_Last1DdataSet
	if(Movie_AppendFileName)
		if(! stringMatch(AnnotationList("NI1A_MovieCreate1DGraph"),"*MovieLegend;*"))
			Legend/C/N=MovieLegend/J/M/A=LT/W=NI1A_MovieCreate1DGraph "\{root:Packages:Convert2Dto1D:Movie_FileName}"
		endif
	else
		Legend/K/N=MovieLegend/W=NI1A_MovieCreate1DGraph
	endif
	DoUpdate
	setDataFolder OldDf		
end


//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function NI1A_MovieCreateUpdateImageFnct()

	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D:
	NVAR Movie_Use2DRAWdata=root:Packages:Convert2Dto1D:Movie_Use2DRAWdata
	NVAR Movie_Use2DProcesseddata=root:Packages:Convert2Dto1D:Movie_Use2DProcesseddata

	if(!Movie_Use2DRAWdata && !Movie_Use2DProcesseddata)		//probably want to do 1D graph for Movie
		KillWIndow/Z NI1A_MovieCreateImage
 		return 0
	endif

	if(Movie_Use2DRAWdata)
		Wave/Z RAWImageToDisplay = root:Packages:Convert2Dto1D:CCDImageToConvert 	//this contains RAW data ONLY
		if(!WaveExists(RAWImageToDisplay))
			Abort "The 2D image does not exist, please load test image in Nika first"
			KillWIndow/Z NI1A_MovieCreateImage
 		endif
		Duplicate/O RAWImageToDisplay, Movie2DImage
	else			//use Calibrated data
		Wave/Z CalibratedImageToDisplay = root:Packages:Convert2Dto1D:Calibrated2DDataSet 	//this contains calibrated data 
		if(!WaveExists(CalibratedImageToDisplay))
			Abort "The Calibrated 2D image does not exist, please load & convert test image in Nika first"
		endif
		Duplicate/O CalibratedImageToDisplay, Movie2DImage
	endif
	
	NVAR Movie_DisplayLogInt=root:Packages:Convert2Dto1D:Movie_DisplayLogInt
	if(Movie_DisplayLogInt)
		MatrixOp/O Movie2DImagetemp=log(Movie2DImage)
		Movie2DImage = Movie2DImagetemp
	endif
	//now it exists, create image to use:
	DoWindow NI1A_MovieCreateImage
	if(!V_Flag) 
		NewImage/K=1 Movie2DImage 
		DoWindow/C NI1A_MovieCreateImage
		DoWindow/T NI1A_MovieCreateImage, "Movie Image"
		ModifyImage  Movie2DImage ctab= {*,*,Terrain,0}		
		ModifyImage  Movie2DImage ctabAutoscale=0,lookup= $"NI1A_MovieCreateImage"
		AutoPositionWindow  /M=1 /R=NI1A_CreateMoviesPanel NI1A_MovieCreateImage
	else
		DoWIndow/F NI1A_MovieCreateImage
	endif
	SVAR FileNameToLoad = root:Packages:Convert2Dto1D:FileNameToLoad
	SVAR UserSampleName=root:Packages:Convert2Dto1D:UserSampleName
	SVAR Movie_FileName=root:Packages:Convert2Dto1D:Movie_FileName
	Movie_FileName = FileNameToLoad
	NVAR Movie_AppendFileName=root:Packages:Convert2Dto1D:Movie_AppendFileName
	if(Movie_AppendFileName)
		if(! stringMatch(AnnotationList("NI1A_MovieCreateImage"),"*MovieLegend;*"))
			Legend/C/N=MovieLegend/J/M/A=LT/W=NI1A_MovieCreateImage "\{root:Packages:Convert2Dto1D:Movie_FileName}"
		endif
	else
		Legend/K/N=MovieLegend/W=NI1A_MovieCreateImage
	endif
	DoUpdate
	setDataFolder OldDf
			
end


//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function NI1A_MovieUpdateMain2DImage()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D:
	NVAR Movie_UseMain2DImage=root:Packages:Convert2Dto1D:Movie_UseMain2DImage

	if(!Movie_UseMain2DImage)	
		return 0
	endif

	if(Movie_UseMain2DImage)
		DOWindow CCDImageToConvertFig
		if(V_Flag)
			DoWIndow/F CCDImageToConvertFig
			AutoPositionWindow  /M=1 /R=NI1A_CreateMoviesPanel CCDImageToConvertFig
		else	
			Abort "Main 2D windows does not exist"
		endif
	endif
	DoUpdate
	setDataFolder OldDf
			
end

//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function NI1A_MovieCallUserHookFunction()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D:
	NVAR Movie_UseUserHookFnct=root:Packages:Convert2Dto1D:Movie_UseUserHookFnct

	if(!Movie_UseUserHookFnct)	
		return 0
	endif

#if(exists("Movie_UserHookFunction")==6)
	Movie_UserHookFunction()
#else
	Movie_UseUserHookFnct=0
	Abort "User hook function does not exist, create Movie_UserHookFunction() which creates image you want to add to movie first"
#endif
	DoUpdate
	setDataFolder OldDf
			
end



//***********************************************************
//***********************************************************
//***********************************************************
//Function Movie_UserHookFunction()
//
//		DoWindow CCDImageToConvertFig
//		if(V_Flag)
//			DoWIndow/F CCDImageToConvertFig
//			AutoPositionWindow  /M=1 /R=NI1A_CreateMoviesPanel CCDImageToConvertFig
//		else	
//			Abort "Main 2D windows does not exist"
//		endif
//		print "called Movie_UserHookFunction function"
//
//end

//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function NI1A_MovieButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"OpenMovieFile"))
				NI1A_MovieOpenFile()
			endif
			if(stringmatch(ba.ctrlName,"Movie_CloseFile"))
				NI1A_MovieCloseFile()
			endif
			if(stringmatch(ba.ctrlName,"Movie_AppendFrame"))
				NI1A_MovieAppendTopImage(1)
			endif
			if(stringmatch(ba.ctrlName,"OpenMovieGraph"))
				NI1A_MovieUpdateMain2DImage()
				NI1A_MovieCreateUpdate1DGraphF()
				NI1A_MovieCreateUpdateImageFnct()
				NI1A_MovieCallUserHookFunction()
			endif

			DoWindow/F NI1A_CreateMoviesPanel
			
			
			break
	endswitch
	return 0
End
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function NI1A_MovieOpenFile()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR Movie_FrameRate=root:Packages:Convert2Dto1D:Movie_FrameRate
	NVAR Movie_AppendAutomatically=root:Packages:Convert2Dto1D:Movie_AppendAutomatically
	NVAR Movie_FileOpened=root:Packages:Convert2Dto1D:Movie_FileOpened
	
	NewMovie /F=(Movie_FrameRate)/I/Z
	if(V_Flag==-1)
		abort
	elseif(V_Flag!=0)
		abort "Error opening movie file" //user canceled or other error
	endif
	Movie_FileOpened=1
	Button OpenMovieFile win=NI1A_CreateMoviesPanel, title="Movie file opened", disable=2
	if(Movie_AppendAutomatically)
		Button CreateMovie win=NI1A_Convert2Dto1DPanel, title="Creating Movie Auto",fColor=(16386,65535,16385)
	else
		Button CreateMovie win=NI1A_Convert2Dto1DPanel, title="Creating Movie Manual",fColor=(16386,65535,16385)
	endif
end
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function NI1A_MovieCloseFile()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable DebugEnab
	DebuggerOptions
	DebugEnab = V_debugOnError 	//check for debug on error
	if (DebugEnab)					//if it is on,
		DebuggerOptions debugOnError=0	//turn it off
		Execute/P/Q/Z "DebuggerOptions debugOnError=1"	//make sure it gets turned back on
	endif
	CloseMovie
	Variable err = GetRTError(0)
	if (err != 0)
		String message = GetErrMessage(err)
		Printf "Error in Movie creation: %s\r", message
		err = GetRTError(1)						// Clear error state
		Print "Continuing execution"
	endif
	if (DebugEnab)
		DebuggerOptions debugOnError=1	//turn it back on
	endif
	Button OpenMovieFile win=NI1A_CreateMoviesPanel, title="Open Movie file for writing", disable=0
	Button CreateMovie win=NI1A_Convert2Dto1DPanel, title="Create Movie",fColor=(0,0,0)
	NVAR Movie_FileOpened=root:Packages:Convert2Dto1D:Movie_FileOpened
	Movie_FileOpened=0
end
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function NI1A_MovieAppendTopImage(Manually)
	variable manually
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR Movie_Use2DRAWdata=root:Packages:Convert2Dto1D:Movie_Use2DRAWdata
	NVAR Movie_Use2DProcesseddata=root:Packages:Convert2Dto1D:Movie_Use2DProcesseddata
	NVAR Movie_Use1DData=root:Packages:Convert2Dto1D:Movie_Use1DData
	NVAR  Movie_UseMain2DImage = root:Packages:Convert2Dto1D:Movie_UseMain2DImage
	NVAR  Movie_UseUserHookFnct = root:Packages:Convert2Dto1D:Movie_UseUserHookFnct
	NVAR Movie_FileOpened=root:Packages:Convert2Dto1D:Movie_FileOpened
	NVAR Movie_AppendAutomatically=root:Packages:Convert2Dto1D:Movie_AppendAutomatically

	if((Manually || Movie_AppendAutomatically) && Movie_FileOpened)
		DoWindow NI1A_MovieCreateImage
		if(V_Flag) 
			DoWIndow/F NI1A_MovieCreateImage
		endif
		DoWindow NI1A_MovieCreate1DGraph
		if(V_Flag) 
			DoWIndow/F NI1A_MovieCreate1DGraph
		endif
		if(Movie_UseMain2DImage)
			DoWindow CCDImageToConvertFig
			if(V_Flag) 
				DoWIndow/F CCDImageToConvertFig
			else
				Abort "Main 2D image does nto exist, it cfannoty be added to the movie" 
			endif
		endif
		if(Movie_UseUserHookFnct)
			//nothing needed here...
		endif		
		SVAR Movie_FileName=root:Packages:Convert2Dto1D:Movie_FileName
		
		AddMovieFrame
		Print "Added frame with data : "+Movie_FileName+" to movie"
	endif
end
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
