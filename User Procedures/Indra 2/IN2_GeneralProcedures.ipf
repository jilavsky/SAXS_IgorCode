#pragma rtGlobals=2		// Use modern global access method.
#pragma version = 2.21
#pragma IgorVersion = 7.05

//control constants
constant IrenaDebugLevel=1
//1 for little debug
//5 to get name of each function entered. For now in general Procedures. using IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
constant RequiredMinScreenHeight=790
constant RequiredMinScreenWidth = 1200 
constant MaxGraphWidthAllowed = 1920
constant MaxGraphHeightAllowed = 1050
constant FillGraphVerticalRatio = 0.9
constant FillGraphHorizontalRatio = 0.8
Constant TypicalPanelHorizontalSize = 350

   //For releases uncomment the next line and set to correct version number:
//Strconstant ManualVersionString = "en/1.4/"					//1.4 is December2018 release
//Strconstant ManualVersionString = "en/1.4.1/"		//this was for February2020 release. 
   //For development version uncomment next line, it points to latest (development) version of manuals:
Strconstant ManualVersionString = "en/latest/"		//thsi is for beta version, so it sees current version of manual. 
strconstant strConstVerCheckwwwAddress="https://usaxs.xray.aps.anl.gov/staff/jan-ilavsky/IrenaNikaRecords/VersionCheck.php?"
		//this is probably useless... strconstant strConstVerCheckwwwAddress="http://usaxs.xray.aps.anl.gov/staff/ilavsky/IrenaNikaRecords/VersionCheck.php?"
//constant useUserFileNames = 0			//this controls, if IN2G_ReturnUserSampleName(FolderPathToData) returns folder name (=0) or SmapleName (string, if exists, =1)
//replaced with root:Packages:IrenaConfigFolder:UseUserNameString
// Names handling: 
//  IN2G_ReturnUserSampleName(FolderPathToData) returns name, either folder name or content of UserName string
//  IN2G_CreateUserName(NameIn,MaxShortLength, MakeUnique, FolderWaveStrNum) returns name for specific element
//  On Igor 7 always less than 31 characters. On Igor 8 optionally more, based on constats above.  
//  
//*************************************************************************\
//* Copyright (c) 2005 - 2020, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/
//
//2.21 added bunch of formating tools for graphs:
		//IN2G_OffsetTopGrphTraces(LogXAxis, XOffset ,LogYAxis, YOffset)
		//IN2G_LegendTopGrphFldr(FontSize, MaxItems, UseFolderName, UseWavename)
		//IN2G_VaryLinesTopGrphRainbow(LineThickness, varyLines)
		//IN2G_VaryMarkersTopGrphRainbow(UseOpenSYmbols, SymbolSize, SameSymbol)
		//IN2G_ColorTopGrphRainbow()
//2.20 modified IN2G_ConvertDataDirToList to IN2G_ConvertDataDirToListNew and used that. This will break list of spe scans for step scanning and needs to be fixed.
//2.19 Added IN2G_CleanStringForgrep(stringIn) which is used to comment out special characters used in grep, so they can be used as part of names... 
//2.18 modified IN2G_PanelResizePanelSize(s) to move panels in the view if they are due to change of resolution left outside of the view. This may not work well on dual monitor systems, though... 
//2.17 added create ColorScale for USAXS graphs. 
//2.16 Fix IN2G_PanelResizePanelSize to return 0 when handled, seems needed to prevent GUI problems. 
//2.15 minor modification of some functions to speed it up a bit... Added long names warning. 
//2.14 added function IN2G_ReturnUnitsForYAxis(Ywave) which creates units string for Intensity vs Q Intensity axis based on wave note. 
//2.13 Get the Igor8 long files names support sorted out. 
//2.12 redirect to new VersionCheck location.
//2.11 Added IN2G_CreateUserName(NameIn,MaxShortLength, MakeUnique, FolderWaveStrNum) to handle names of different lengts
//		modified IN2G_LegendTopGrphFldr to have max number of items in legend to keep the list under controls. Most code uses 15 at this time. And control if use of folder, wave, or both names. 
//		modified IN2G_ColorTopGrphRainbow to have basic colors for few waves (up to 4). Then colorization as expected.   
//2.10 Modifed startup panel controls to better handle rescaling panels on startup. 
//2.09 fixed errror when both Nika and Irena check for update at the smae time and MeesageFromAuthor is already opened. 
//2.08 Nika removed DoubleClickConverts=root:Packages:Convert2Dto1D:DoubleClickConverts as it is not needed anymore. 
//2.07 ManualVersionNumber modifications for beta versions and release versions. 
//2.06 added IN2G_GetAndDisplayUpdateMessage()
//2.05 added now function to set graph size and more controls for it (constants). IN2G_GetGraphWidthHeight
//2.04 added function to convert Q wave to log-Q wave (IN2G_ConvertTologspacing)
//2.03 added recording to web site with version check. 
//2.02 added overwrite for screen size abort. 
//2.01 added IN2G_ReturnUserSampleName(FolderPathToData)  which returns sample name... 
//2.00 added saving of color table for Nika, requested feature. 
//1.99 added IN2G_ResetPanelSize(PanelName) to rescale panels back to "user size" selected in current Igor experiment. 
//1.98 more changes to screen check, modified the function called by AfterCompileHook functions to provide proper user input for small screens
//1.97 trying to fix checking for small displays on WIndows.
//1.96 added IN2G_OpenNikaWebManual(WhichSpecificPage)
//1.95 added CheckForNewVersion(WhichPackage) which returns - from GitHub - current version of Irena, Nika, Indra (selected by WHichPackage)
//1.94 removed IN2G_PrintDebugWhichProCalled, sped up all code using it. 
//1.93 fix screenresolution check for high res displays
//1.92 added IN2G_CheckForGraphicsSetting() for AfterCompiledHook( ) functions. 
//1.91 add Function/T IN2G_RemoveInvisibleFiles(ListIn)
//1.90 fixed IN2G_ConvertDataDirToList not to fail on qrs data sets which contain "spec" as string in the names. 
//1.89 added IN2G_ListIgorProcFiles(), IN2G_FindVersionOfSingleFile, IN2G_DownloadFile
//1.88 fixes for panel scaling. 
//1.87 added log intensity interpolation function
//1.86 fixes for Package preferences
//1,85 added IN2G_PanelAppendSizeRecordNote, moved whole package preferences to this package and removd use of Nika preferneces. MOved panel scaling here. 
//1.84 added IN2G_ConvertPointToPix and IN2G_ConvertPixToPoint
//1.83 moved structure IrenaPanelDefaults from Irena since it is shared...GUI controls. 
//1.82 added IN2G_CloneWindow function
//1.81 added IN2G_PrintDebugStatement, fixed some unresolved dependencies. 
//1.80 added conversions between TTH, Q, and D in form of following functions: IN2G_COnvertQtoD etc. All take Thing to convert (e.g. Q) and wavelength (for uniformity, not used for Q-D). 
//     also added InsertSUbwindow to GraphMarquee and Color Traces to Graph menu. Added some xml functions I needed.  
//1.79 added IN2G_LegendTopGrphFldr(FontSize)
//1.78 added Function/S IN2G_CreateUniqueFolderName(InFolderName)	//takes folder name and returns unique version if needed
//       added IN2G_RemoveNaNsFrom7Waves
//1.77 minor change in CheckScreenSize function
//1.76 removed Exectue as prep for Igor 7
//1.75 removed wave/d, Function/d and variable/d. Obsolete
//1.74 added IN2G_EstimateFolderSize(FolderName)
//1.73 added IN2G_CheckForSlitSmearedRange() which checks if the slit smearing Qmax > 3*Slit length
//1.72 updated log rebinning search for parameters using Optimize. Much better... 
//1.71 added new log-rebinning routine using IgorExchange version of the code. Need to update other code topp use it. Modified to use standard error of mean. 
//1.70 added ANL copyright
//1.69 modified IN2G_roundToUncertainity to handle very small numbers. 
//1.86 added for log rebining functions tool to find start value to match minimum step. 
//1.67 added ZapNonLetterNumStart(strIN) which removes any non letter, non number start of the string for ASCII importer.
//1.66 Spline smoothing changed to use FREE waves. Changed direction of panel content move buttnos. 
//1.65 changed back to rtGlobals=2, need to check code much more to make it 3
//1.64 added checkbox, checkbox procedure and scrolling hook function for panels, fixed another indexes running out
//1.63 changed to rtGlobals=3
//1.62 added IN2G_roundToUncertainity(val, uncert,N)	 to prepare presentation of results with uncertainities for graphs and notebooks
//1.61 fixed IN2G_ReturnExistingWaveName to work wityh liberal names
//1.60 added IN2G_ReturnExistingWaveNameGrep
//1.59 added IN2G_ColorTopGrphRainbow()
//1.58 adds function to find different elements between two text waves
//1.57 speed up some of the functions
//1.56 added removeNaNs from 6 waves
//1.55 removed CursorMovedHook function and converted when needed to WindowHookFunctions
//1.54 optimization of some proceudres to gain speed. 12/10/2010, changed IN2G_FindFolderWithWaveTypes, 

//This is file containing genrally useful functions, which are used by two major packages - Indra 2 and Irena,
// and various other Igor projects I wrote. This file should bve fully backward compatible, please check that you have 
//the appropriate version available. If not, please get latest version from www.uni.aps.anl.gov/~ilavsky or
// e-mail me: ilavsky@aps.anl.gov.

//This is list of procedures with short description. 
//
//IN2G_ConvertTologspacing (qwave) converts Q wave in range of Qmin-Qmax to log spacing
//
//IN2G_ListIgorProcFiles()
//		lists procedure files for version checking. 
//IN2G_FindVersionOfSingleFile, IN2G_DownloadFile
//		functions supporting version checking
//
//IN2G_CreateUserName(NameIn,MaxShortLength, MakeUnique, FolderWaveStrNum)    returns string of length which user wants - and is Igor 8 aware, 
//			FolderWaveStrNum - 11 for folder, 1 for wave, 3 for string 4 for number
//
//Function/S IN2G_CreateUniqueFolderName(InFolderName)	//takes folder name and returns unique version if needed
//	string InFolderName										//this will take root:Packages:SomethingHere and will make SomethingHere unique if necessary. 
//Function IN2G_CheckForSlitSmearedRange(slitSmearedData,Qmax, SlitLength)
//   aborts execution with errro message if qmax < 3* slit length for slit smerared data
//
//Functions IN2G_startOfxmltag and IN2G_XMLtagContents are for reading xml files as text. From Jon Tischler. 
//
//Function IN2G_num2StrFull creates string with many more digits than built in function. From Jon Tischler. 
//
//IN2G_CloneWindow will clone current window (Graph or Table) and save separately the data and create a new graph. 
//   	Can be used when user wants to preserve existing Graph or Table for future use and is worried that Irena/Nika will destroy the data at some point. 
//
//Function IN2G_RebinLogData(Wx,Wy,NumberOfPoints,MinStep,[Wsdev,Wxwidth,W1, W2, W3, W4, W5])
//  Rebins data (x,y.etc) on log scale optionally with enforcing minimum step size. 
//
//Function IN2G_ScrollHook(info)
//  Should make panels scrollable, will need to test. 
//
//IN2G_AppendAnyText
//	checks for definitions and existence of logbook and appends the text to the end of the logbook
//	
//IN2G_AppendNoteToAllWaves(key,value)
//	appends (or replaces) key:value (str) pair to all waves in the folder
//	
// IN2G_AppendNoteToListOfWaves(ListOfWaveNames, Key,notetext)	
//	appends (or replaces) key:value (str) pair to waves listed in ListOfWaveNames and present in the folder
//
// IN2G_ReturnExistingWaveName(FolderNm,WaveMatchStr)
// IN2G_ReturnExistingWaveNameGrep(FolderNm,RegEx)
//	text function which returns either full string for wave name, if it exists in the folder probed or empty string if wave does not exist.
//
//IN2G_AppendorReplaceWaveNote(WaveNm,Key,Value)
//	Appends or replaces in note for wave $Wavename the key:Value
//
//IN2G_AppendStringToWaveNote(WaveNm,Str)		
//	this will append or replace new string with Keyword-list note to wave
//	
//IN2G_AutoAlignGraphAndPanel
//	Aligns next to each other graph (left) and panel (right)
//IN2G_AutoAlignPanelAndGraph()
//  Aligns next to each other panel (left) and graph(right)
//	
//IN2G_BasicGraphStyle
//	My basic graph style used in these macros. May be made later platform specific...
//	
//IN2G_CleanupFolderOfWaves
//	Deletes waves with names starting on fit_ and W_, which are used by Igor fitting routines
//	
//IN2G_CleanStringForgrep(stringIn)	
// Comments out special grep characters so they can be used in names. 
//
//IN2G_ConvertDataDirToList(str)
//	Converts string returned by FolderDirectory function into list of folders. Meant for directories of specXX types...
//	
//IN2G_CreateListOfItemsInFolder(datafolder, itemtype)
//	Generates list of items in directory specified. 1-directories, 2-waves, 4 - variables, 8- strings
//	
//
//IN2G_FindFolderWithWaveTypes(startDF, levels, WaveTypes, LongShortType)
//	Returns list of folders with waves of given type. Long (1) type is full path, short (0) is  only folder names.

//IN2G_NewFindFolderWithWaveTypes(startDF, levels, WaveTypes, LongShortType)
//	Returns list of folders with waves of given type. Long (1) type is full path, short (0) is  only folder names. For one type, but should be faster then the old one... May behave differently.

//	 
//IN2G_FindFolderWithWvTpsList(startDF, levels, WaveTypes, LongShortType)
//	Returns list of folders with waves of given type - but takes list of wave types, separated by ";" or ",". Long (1) type is full path, short (0) is  only folder names.

//	 
//IN2G_FixTheFileName
//	Fixes file names from known info in the folder. May need tweaking for this version of Indra.
//
//IN2G_GetMeListOfEPICSKeys
//	Returns list of "useful" - UPD related - keywords used by spec...
//	
//IN2G_GetMeMostLikelyEPICSKey(str)
//	Returns list of EPICS keywords closest to str.
//	
//IN2G_KillAllGraphsAndTables
//	Kills all of the graphs and tables.
//	
//IN2G_KillGraphsAndTables
//	Kills top graph and, if exists, panel for UPD control.
//	
//IN2G_KillTopGraph
//	Name says it all...
//	
//IN2G_RemovePointWithCursorA
//	Sets point with cursor A to NaN, for R  wave creation also sets USAXS_PD point to NaN, to work with change of UPD parameters.
//
//IN2G_ReplaceColons(str)
//	Returns string with : replaced by _. 
//
//IN2G_ReplaceOrChangeList(MyList,Key,NewValue)
//	Returns MyList after replacing - or appending if needed - pair Key:NewValue
//
//IN2G_ResetGraph
//	Basically ctrl-A for graph. Users convenience...
//	
//IN2G_ReversXAxis
//	Guess what...
//	
//IN2G_ScreenWidthHeight(width/height)
//	Returns number such, that - independent on platform and screen resolution - the size of graph can be set in %. Use after multiplying by proper % size (60 for 60%).
//	
//IN2G_WindowTitle(WindowsName)
//	Returns WindowTitle of the WindowName.
//
//IN2G_RemoveNaNsFrom3Waves(Wv1,wv2,wv3)
//	Removes NaNs from 3 waves, used to clean NaNs from waves before desmearing etc.
//
//IN2G_RemoveNaNsFrom2Waves(Wv1,wv2)
//	Removes NaNs from 2 waves, used to clean NaNs from waves before desmearing etc.
//
//IN2G_RemoveNaNsFrom5Waves(Wv1,wv2,wv3,wv4,wv5)
//	Removes NaNs from 5 waves, used to clean NaNs from waves before desmearing etc.
// available also for 6, and 7 waves with similar names. IN2G_RemoveNaNsFrom7Waves
//
//IN2G_RemNaNsFromAWave(Wv1)	//removes NaNs from 1 wave
//assume same number of points in the waves
//
//IN2G_LogInterpolateIntensity(NewQ,OldQ,Intensity)		
//	Log interpolate Inteity to new Q points while fixing negative values. 
//
//IN2G_ReplaceNegValsByNaNWaves(Wv1,wv2,wv3)		
//	Replaces Negative values in 3 waves by NaNs , assume same number of points
//
//IN2G_GenerateLegendForGraph()
//	generates legend for graph and kills the old one. It uses wave names and waves notes to generate the 
//	proper label. Very useful...
//
//IN2G_ColorTopGrphRainbow()
//    Colors top graph with rainbow colors
//these are similarly useful graph formating macros:
//IN2G_OffsetTopGrphTraces(LogXAxis, XOffset ,LogYAxis, YOffset)
//IN2G_LegendTopGrphFldr(FontSize, MaxItems, UseFolderName, UseWavename)
//IN2G_VaryLinesTopGrphRainbow(LineThickness, varyLines)
//IN2G_VaryMarkersTopGrphRainbow(UseOpenSYmbols, SymbolSize, SameSymbol)
//
//IN2G_LegendTopGrphFldr(FontSize)
//		Appedn legend containing the last folder name and wave name 
//
//IN2G_CleanupFolderOfGenWaves(fldrname)		
//cleans waves from waves created by generic plot
//
//IN2G_CheckFldrNmSemicolon(FldrName,Include)	
//this function returns string - probably path
//with ending semicolon included or not, depending on Include being 1 (include) and 0 (do not include)	
//
// IN2G_AutoscaleAxisFromZero(which,where)		
//this function autoscales axis from 0, which is "bottom", "left" etc., where is "up" or "down"
//
//IN2G_SetPointWithCsrAToNaN(ctrlname) : Buttoncontrol
//this function sets point with Csr A to Nan
//
//Function IN2G_AppendListToAllWavesNotes(notetext)	
//this function appends or replaces List to wave note  
//
//Function IN2G_WriteSetOfData(which)		
//this procedure saves selected data from current folder
//
//Function IN2G_PasteWnoteToWave(waveNm, textWv)
//this function pastes the content of wave named waveNm into textwave textWv, redimensiones as needed
//used to append the data to exported columns to the end
//
//Function IN2G_UniversalFolderScan(startDF, levels, FunctionName)
//runs Function called in stgring FunctionName in each subfolder of the startDF
//e.g. IN2G_UniversalFolderScan("root:USAXS:", 5, "IN2G_CheckTheFolderName()")
//
//Function IN2G_CheckTheFolderName()
// this function checks the current folder name and compares it with string in the folder
//and then fixes the pointers in the wavenotes
//
//IN2G_TrimExportWaves(Q,I,E)	
//this function trims export I, Q, E waves as required
//curently the two trims are - remove points with Q<0.0002 and with negative intensities
//this function is not used for export of R wave
//
//IN2G_CreateListOfScans(df) 
//this function together with the next behind it creates list of folders in any folder with SpecComments appended, used with 
//converting the scans
//
//Function IN2G_KillWavesFromList(WvList)
//this function kills all waves from list, use ; as list separator, no check for this is done
//
//Function IN2G_KillPanel(ctrlName) : ButtonControl
//this procedure kills panel which it is called from, so I can continue in paused for user procedure
//
//Function IN2G_AppendSizeTopWave(GraphName,BotWave, LeftWave, AxisPosition, LabelPosX, LabelPosY)
//Function IN2G_AppendGuinierTopWave(GraphName,BotWave, LeftWave,AxisPos,LabelX,LabelY)
//this function appends to the log-log graph size indicator. Assume that BotWave is Q vector in A-1
//appends LeftWave to top size axis. Use carefully, will screw up if bottom axis is scaled using axis dialog.

//Math functions for size distributions. All have same basic structure
//Parameters:
//	FD - volumetric size distribution (f(D)
//	Ddist - diameter distribution
//	MinPoint, MaxPoint - point numbers between which integrate (point numbers, not diameters)
//	removeNegs - set ot 1 to set negative diameters to 0, 0 to include them as negative numbers
//Volume Fraction Result is dimensionless
//Function IN2G_VolumeFraction(FD,Ddist,MinPoint,MaxPoint, removeNegs)
//
//Number density Result is in 1/A3
//Function IN2G_NumberDensity(FD,Ddist,MinPoint,MaxPoint, removeNegs)
//
//Specific Surface Result is in A2/A3
//Function IN2G_SpecificSurface(FD,Ddist,MinPoint,MaxPoint, removeNegs)
//
//Volume weighted mean diameter
//Function IN2G_VWMeanDiameter(FD,Ddist,MinPoint,MaxPoint, removeNegs)
//
//Number weighted mean diameter
//Function IN2G_NWMeanDiameter(FD,Ddist,MinPoint,MaxPoint, removeNegs)
//
//Volume weighted Standard deviation
//Function IN2G_VWStandardDeviation(FD,Ddist,MinPoint,MaxPoint, removeNegs)
//
//Number weighted Standard deviation
//Function IN2G_NWStandardDeviation(FD,Ddist,MinPoint,MaxPoint, removeNegs)
//
//Function/T IN2G_DivideWithErrors(A1,S1,A2,S2)		divides A1 by A2 ...A1/A2
//Function/T IN2G_MulitplyWithErrors(A1,S1,A2,S2)		A1*A2
//Function/T IN2G_SubtractWithErrors(A1,S1,A2,S2)		A1-A2
//Function/T IN2G_SumWithErrors(A1,S1,A2,S2)			A1+A2
//these functions do math with errors... Return string with first element result and second element error
//Function IN2G_ErrorsForDivision(A1,S1,A2,S2)
//Function IN2G_ErrorsForMultiplication(A1,S1,A2,S2)
//Function IN2G_ErrorsForSubAndAdd(A1,S1,A2,S2)
//these functions return the errors for numerical procedures
//
//Function IN2G_CreateItem(TheSwitch,NewName)
//this function creates strings or variables with the name passed
// TheSwitch =string or variable, NewName is the name for variable or string
//
//Function IN2G_IntegrateXY(xWave, yWave)
//copy of the integration XY proc from Wavemetrics, replaces yWave with it's increasing integral
//Function CursorMovedHook(info)   <<<<< removed in version 1.55 May 8, 2011 to avoid conflicts 
//this function makes various graphs in both Indra and Irena "live"
//
//IN2G_ChangePartsOfString(str,oldpart,newpart)
// this is small function which replaces part of the string (delimiter) with another one (new delimiter) 
//addopted from John Tishler
//IN2G_RemoveExtraQuote(str,starting,Ending)
//this is used to remove extra ' from parts of liberal names so they can be modified and used...
//
//Function IN2G_CheckScreenSize(which,MinVal),     which = height, width, MinVal is in pixles
//this checks for screen size and if the screen is smaller, aborts and returns error message
//  
//
//Function IR1G_UpdateSetVarStep(MyControlName,NewStepFraction)
// changes control step to fraction of the current value
//	
//Function IN2G_FolderSelectPanel(SVARString, TitleString,StartingFolder,FolderOrFile,AllowNew,AllowDelete,AllowRename,AllowLiberal)		
	// 	This is universal widget for programmers to call when user needs to select folder and possibly string/wave/variable name 
	//	User is allowed to manipulate folders and see their content, with functionality close to standard OS widgets
	//
	//	Help:
	//	SVARString 		full name of string (will be created, including folders, if necessary) which will have result in it
	//	TitleString 		Title of the panel which is used, so it can be customized.
	//	StartingFolder	if set to "" current folder is used, otherwise the first folder displayed will be set to this folder (if exists, if not, set to current)
	//
	// 	FolderOrFile 		set  to  0 to get back only folder path
	//					set to 1 if you want folder path and item (string/var/wave) name back. Uniqueness not required. 
	//					set to 2 to get path and UNIQUE item (string/var/wave) name
	//					Path starts from root: folder always!!!
	//	AllowNew		set to 1 to allow user to create new folder
	//	AllowDelete		set to 1 to allow user to delete folder
	//	AllowRename	set to 1 to allow user to rename existing folder

//Function IN2G_InputPeriodicTable(ButonFunctionName, NewWindowName, NewWindowTitleStr, PositionLeft,PositionTop)
//	string ButonFunctionName, NewWindowName, NewWindowTitleStr
//	variable PositionLeft,PositionTop
//	creates periodic table with buttons with element names. 
//	ButonFunctionName is string with button control function, which will be run, when the button is pressed. 
//	NewWindowName is the name of the window to be created (check yourself for uniquness), no spaces here!!!
//	NewWindowTitleStr is title string, spaces are OK
//	PositionLeft,PositionTop  are positions of teh left top corner to position it WRT another windows... 
//
//
//
//Function IN2G_SplineSmooth(n1,n2,xWv,yWv,dyWv,S,AWv,CWv)
//	variable n1,n2,S
//	Wave/Z xWv,yWv,dyWv,AWv,CWv
// 	CWv is optional parameter, if not needed use $"" as input and the function will not complain
// Input data
//	n1, n2 range of data (point numbers) between which to smooth data. Order independent.
//	xWv,yWv,dyWv  input waves. No changes to these waves are made
// 	S - smoothing factor. Range between 1 and 10^32 or so, varies wildly, often around 10^10
//	AWv,CWv	output waves. AWv contains values for points from yWv, CWv contains values needed for interpolation
// 	AWv and CWv are redimensioned to length of yWv and converted to real double precision
// Does the spline smoothing of data. Note, for SAS data you should do smoothing on log(Intensity) vs log(Q)
// move temporary log(intensity) to positive values by adding log(int) minimum...  
// Error: 	Error_log= Int_log*( 1/(Int_Log) - 1/(log(Int+Error)))
//
//
//
//Function/T IN2G_FixWindowsPathAsNeed(PathString,DoubleSingleQuotes, EndingQuotes)
//	string PathString			path from Igor Info on windows: c:program files:Wavemetrics:Igor Pro Folder
//	variable DoubleSingleQuotes, EndingQuotes	//DoubleSingleQuotes = 1 for single, 2 for double, EndingQuotes=1 for ending separator and 0 for none...
//
// IN2G_roundToUncertainity(val, uncert,N)
// returns val rounded to uncertainity with N number of singificant digits. 
// returns string with "val +/- Uncert" 
//
// IN2G_roundSignificant(val,N)
// returns val rounded to number of singificant digits
//
// IN2G_roundDecimalPlaces(val,N)
//returns val rounded to N decimal places (if needed)
//
//Function IN2G_GenerateSASErrors(IntWave,ErrWave,Pts_avg,Pts_avg_multiplier, IntMultiplier,MultiplySqrt,Smooth_Points)
//	wave IntWave,ErrWave
//	variable Pts_avg,Pts_avg_multiplier, IntMultiplier,MultiplySqrt,Smooth_Points
	//this function will generate some kind of SAXS errors using many different methods... 
	// formula E = IntMultiplier * R + MultiplySqrt * sqrt(R)
	// E += Pts_avg_multiplier * abs(smooth(R over Pts_avg) - R)
	// min number of points is 3
	//smooth final error wave, note minimum number of points to use is 2
//
//Function IN2G_printvec(w)
//	prints wave into history area with more sensible format...
//
// IN2G_FindNewTextElements(w1,w2,reswave)   finds different elements between the two text waves, returns reswave with the elements which are NOT 
//    common to the two waves w1 and w2. Takes TEXT waves, reswave is redimensioned 
//IN2G_ConvertPointToPix and IN2G_ConvertPixToPoint
//		convert points to pixels on current platform so scaling panels can be done platform independent. 
//

//*****************************************************************************************************************
//*****************************************************************************************************************
Menu "Macros"
	"Color waves.../1", IN2G_ColorTraces() //Ctrl+1  
End

Menu "GraphMarquee"
       "Insert subwindow", IN2G_CreateSubwindowAtMarqee()
 //      "Clone this window with data", IN2G_CloneWindow()
End


//************************************************************************************************
//************************************************************************************************

Function/T IN2G_CreateUserName(NameIn,I7MaxShortLength, MakeUnique, FolderWaveStrNum)
	string NameIn
	variable I7MaxShortLength, MakeUnique, FolderWaveStrNum
	//FolderWaveStrNum - 11 for folder, 1 for wave, 3 for string 4 for number
	
	NVAR useIgor8LongNames = root:Packages:IrenaConfigFolder:Igor8UseLongNames
	NVAR/Z Igor7LongNamesWarning = root:Packages:IrenaConfigFolder:Igor7LongNamesWarning
	string resultStr
	resultStr =  IN2G_RemoveExtraQuote(NameIn,1,1)
	if(strlen(resultStr)>I7MaxShortLength)
		if((IgorVersion()>7.99 && !useIgor8LongNames) || IgorVersion()<7.99)
			if(!NVAR_Exists(Igor7LongNamesWarning))
				variable/g root:Packages:IrenaConfigFolder:Igor7LongNamesWarning
				NVAR Igor7LongNamesWarning = root:Packages:IrenaConfigFolder:Igor7LongNamesWarning
				Igor7LongNamesWarning = 1
				if(IgorVersion()<7.99)
					DoAlert /T="Long name use detected" 0, "Igor 7 has 32 characters limit for names. Your name "+resultStr+" is "+num2str(strlen(resultStr))+" long. It will be truncated. Consider upgrading to Igor 8 where names can be up to 256 characters long."
				elseif(IgorVersion()>7.99 && !useIgor8LongNames)
					DoAlert /T="Long name use detected" 0, "Name "+resultStr+" is "+num2str(strlen(resultStr))+" chars long. Current Nika/Indra/Irena setting is "+num2str(I7MaxShortLength)+" char max. Names will be truncated. Allow lengths up to 256 characters long using \"Config fonts, uncertainties, names\"."
				endif
			endif
		endif
	endif			
	if(useIgor8LongNames && IgorVersion()>7.99)		//Igor 8 and user wants long names 
		resultStr = resultStr 
	else			//create a short name
		resultStr = resultStr[0,I7MaxShortLength-1]
	endif
	if (FolderWaveStrNum == 3 || FolderWaveStrNum == 4 )		// 1 for waves, 11 for folders, 3 and 4 for strings and variables
		resultStr = CleanupName(resultStr, 1)						// variables and strings must have only non liberal names anyway... 
	endif
	if (CheckName(resultStr,FolderWaveStrNum) != 0)				// 1 for waves, 11 for folders, 3 and 4 for strings and variables
		resultStr = CleanupName(resultStr, 1)						// Make sure it's valid for folders and waves
	endif
	if(MakeUnique&&(CheckName(resultStr,FolderWaveStrNum) != 0))
		resultStr = UniqueName(resultStr, 1, 0) 					// Make sure it's unique in the current folder
	endif
	
	return resultStr
end

//************************************************************************************************
//************************************************************************************************

Function/T IN2G_CleanStringForgrep(stringIn)	
	string stringIn
	
	string stringOut="", SingleChar
	string EscapeCharacters="[].^(){},"
	variable i
	for(i=0;i<strlen(stringIn);i+=1)
		SingleChar = stringIn[i]
		if(StringMatch(EscapeCharacters, "*"+SingleChar+"*" ))
			stringOut+="\\"+SingleChar
		else
			stringOut+=SingleChar
		endif
		
	endfor
	
	return stringOut
end
//************************************************************************************************
//************************************************************************************************
Function/T IN2G_ReturnUserSampleName(FolderPathToData)
	string FolderPathToData
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if(!(DataFolderExists(FolderPathToData)))
		return ""
	endif
	//OK, folder exists. Now does it have user string name, potentially long name?
	//global useUserFileNames = 1 if we want to use this string and 0 if not... 
	NVAR useUserFileNames = root:Packages:IrenaConfigFolder:UseUserNameString
	string UserSampleName
	SVAR/Z StringName = $(FolderPathToData+"UserSampleName")
	if(SVAR_Exists(StringName)&&useUserFileNames)
		if(Strlen(StringName)>0)
			return StringName
		endif
	endif
	//OK, string/long name does not exist, let's pick the folder name
	UserSampleName = StringFromList(ItemsInList(FolderPathToData, ":")-1, FolderPathToData, ":")
	UserSampleName = IN2G_RemoveExtraQuote(UserSampleName,1,1)
	return UserSampleName
end


//**************************************************************** 
//**************************************************************** 
//
//function IN2G_ConvertTologspacing(qwave)//DWS 2017  best moved to a utility .ipf
//	wave qwave
//	duplicate/Free qwave, tempqwave
//	variable pts=numpnts(tempqwave)
//	variable logqmax=log(tempqwave(pts-1))
//	if (tempqwave[0]==0)
//		tempqwave[0]=tempqwave[1]
//	endif
//	variable logqmin=log(tempqwave[0])
//	tempqwave=logqmin+((logqmax-logqmin)/(pts-1))*p
//	tempqwave=10^tempqwave	
//	qwave=tempqwave
//end


Function IN2G_ConvertTologspacing(WaveToRebin,MinStep)
		Wave WaveToRebin
		Variable  MinStep

		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		//assume WaveToRebin is linearly binned... 
		if(WaveToRebin[1]-WaveToRebin[0]< MinStep)
				return 0			//nothing to do. Cannot be changed. 
		endif
		variable OldNumPnts=numpnts(WaveToRebin)
		variable StartX, EndX, CorrectStart, logStartX, logEndX
		if(WaveToRebin[0]<=0)				//log scale cannot start at 0, so let's pick something close to what user wanted...  
			WaveToRebin[0] = WaveToRebin[1]/2
		endif
		CorrectStart = WaveToRebin[0]
		if(MinStep>0)
			StartX = IN2G_FindCorrectLogScaleStart(WaveToRebin[0],WaveToRebin[numpnts(WaveToRebin)-1],OldNumPnts,MinStep)
		else
			StartX = CorrectStart
		endif
		Endx = StartX +abs(WaveToRebin[numpnts(WaveToRebin)-1] - WaveToRebin[0])
		make/O/D/FREE/N=(OldNumPnts) tempNewLogDist
		logstartX=log(startX)
		logendX=log(endX)
		tempNewLogDist = logstartX + p*(logendX-logstartX)/numpnts(tempNewLogDist)
		tempNewLogDist = 10^(tempNewLogDist)
		startX = tempNewLogDist[0]
		tempNewLogDist += CorrectStart - StartX
		WaveToRebin = tempNewLogDist
end		

//**************************************************************** 
//**************************************************************** 
Function IN2G_SubmitCheckRecordToWeb(WhichPackage)
	string WhichPackage
	
	string Accesskey="IrenaNikaVersionCheck"
	string PackagesInstalled=WhichPackage
	string IgorVersionStr=IgorInfo(2)+" "+num2str(IgorVersion())
	string DataPath=SpecialDirPath("Igor Pro User Files", 0, 0, 0 )
	
	string pathtourl=""
	pathtourl = strConstVerCheckwwwAddress
	pathtourl += "key="+Accesskey+"&"
	pathtourl += "packages="+PackagesInstalled+"&"
	pathtourl += "igor_version="+IgorVersionStr+"&"
	pathtourl += "path="+DataPath	
	pathtourl = ReplaceString(" ", pathtourl, "%20")
	//print pathtourl
	URLRequest /TIME=2/Z url=pathtourl
	//print V_Flag
	//print V_responseCode
	//print S_serverResponse
end
//**************************************************************** 
//**************************************************************** 
Function IN2G_CheckForGraphicsSetting(DisplayResult) 
	variable DisplayResult
	//checks for resolution and if needed on Windows prints help to users
	variable CurHeight=	 floor(IN2G_ScreenWidthHeight("height")*100)			//needs to be corrected 
	variable Curwidth =	 floor(IN2G_ScreenWidthHeight("width")*100	)		//needs to be corrected 
	NVAR/Z LastCheck = root:Packages:IrenaNikaLastCompile
	string Message   

	//constant RequiredMinScreenHeight=790
	//constant  RequiredMinScreenWidth = 1200  
	if(!NVAR_Exists(LastCheck))
		NewDataFolder/O root:Packages
		variable/g root:Packages:IrenaNikaLastCompile
		NVAR LastCheck = root:Packages:IrenaNikaLastCompile 
	endif
	if((datetime - LastCheck > 20) || DisplayResult)		//more than 20 seconds from last compile
		if(stringMatch(IgorInfo(2),"Windows"))
			if(CurHeight<RequiredMinScreenHeight || Curwidth<RequiredMinScreenWidth) 
					//screen area too small, need to maximize Igor, may be at full screen this will work...
					//check if this is maximized already, if not, maximize and check again...
					GetWindow  kwFrameOuter  wsizeDC 
					if(V_left!=2 || V_right!=2 || V_top!=2 || V_bottom!=2)		//NOT maximized...
						print "Igor Pro screen area in window was too small, we needed to maximize it for test purpose. That's why Igor flashed on screen..."
						movewindow /F 2, 2, 2, 2
						DoUpdate 
						CurHeight=	 floor(IN2G_ScreenWidthHeight("height")*100)			//needs to be corrected 
						Curwidth =	 floor(IN2G_ScreenWidthHeight("width")*100	)		//needs to be corrected 
						MoveWindow/F 1, 1, 1, 1
					endif
			endif
			if(CurHeight<RequiredMinScreenHeight || Curwidth<RequiredMinScreenWidth)  
						//still too small, error message for user...
						print "********************************************************************************************************************************************************************"
						print "If you see this, Igor has too small screen area available for Irena/Nika/Indra panels and graphs. Following are instructions how to fix this, please, read :"
						print "Igor 7 \"pixels\" are scaled by screen resolution (DPI setting) set in system settings for displayed graphics (fonts, icons, etc.)."
						print "Therefore even seemingly displays with large number of physical pixels (high resolution displays) may not be large enough for Irena/Nika/Indra panels. "   
						print "Keep in minda, that it is the COMBINATION of display resolution (number of pixels) and screen resolution (DPI) which is important here."
						print "     You need to adjust your display settings to provide more area for the panels and graphs :" 
						print "*** Windows 10 :  Right click on Windows Desktop, select \"Display Settings\" and set slider in \"Change the size of text, apps, and other items\" (this changes DPI) "
						print "to smaller number, possibly down to 100% (= 96 DPI). Alternatively, you can also increase the display resolution (increase the number of pixels displayed). POSSIBLY BOTH! "
						print "You probably do NOT need to reboot. Note, it is the COMBINATION of display and screen resolutions (number of pixels and DPI settings) which matters."
						print "*** Windows 7  :  Right click on Windows Desktop, select \"Screen resolution\". You MAY be able to increase the display resolution (number of pixels system is using)."
						print "You may also need to click \"Make text and other items larger or smaller\" and in the next dialog you may need to select Smaller font size (DPI), possibly even 100% (96DPI)."
						print "This changes screen resolution (DPI settings). >>>>> And yes, it is confusing and terminology varies between Windows 7 and 10, I know... <<< " 
						print "You probably DO NEED to reboot. Note, it is the COMBINATION of display and screen resolutions (number of pixels and DPI settings) which matters."
						print " ----   You may need to test various display settings (DPI) and screen resolutions to have everything usable. ---- "
						print "There is extensive documentation in Igor which you can locate by running following command : DisplayHelpTopic \"High-Resolution Displays\", in the command line below. "
						print "*****************************************************************************************************************************************************************"
						print "To re-check the available area after making changes, use command \"Check Igor display size\", in USAXS, SAS2D, or SAS>\"Help, About, Manuals, Remove Irena\" menu."
						print "  ! ! ! !  If you do not fix this, some tools will NOT work.   ! ! ! ! "
						print "********************************************************************************************************************************************************************"
						Message = "Screen size available to Igor is too small, some Irena/Nika panels require up to "+num2str(RequiredMinScreenWidth)+"x"+num2str( RequiredMinScreenHeight)+" (w x h). "
						Message +="Your screen is "+num2str(floor(Curwidth))+"x"+num2str(floor(CurHeight))+". Please see history area for instructions how to fix this. If you do not fix this, some tools will not work. "
						DoAlert /T="Insufficient screen size found" 0, Message
			elseif(DisplayResult)
				Message ="Your display size is "+num2str(floor(Curwidth))+"x"+num2str(floor(CurHeight))+". "
				DoAlert /T="Screen size available to Igor" 0, Message
			else
				// print "Found display area "+num2str(floor(Curwidth))+"x"+num2str(floor(CurHeight))+". This should be sufficient for Irena/Nika/Indra package use. "
			endif   
		else					//Mac
			if(CurHeight<RequiredMinScreenHeight || Curwidth<RequiredMinScreenWidth) 
					print "********************************************************************************************************************************************************************"
					print "If you see this, Igor has too small screen area available for Irena/Nika/Indra panels and graphs. Following are instructions how to fis this, please, read : "
					print "On Macs you need to increase display resolution (increase number of pixels). If this is the highest resolution your monitor can do, you may need to get higher resolution monitor."
					print "*****************************************************************************************************************************************************************"
					print "To check the available area without restarting Igor Pro, use command \"Check Igor display size\", in USAXS, SAS2D, or SAS>\"Help, About, Manuals, Remove Irena\" menu."
					print "  ! ! ! !  If you do not fix this, some tools will NOT work.   ! ! ! ! "
					print "********************************************************************************************************************************************************************"
				Message = "Screen size available to Igor is too small, some Irena/Nika panels require up to "+num2str(RequiredMinScreenWidth)+"x"+num2str( RequiredMinScreenHeight)+" (w x h). "
				Message +="Your screen is "+num2str(floor(Curwidth))+"x"+num2str(floor(CurHeight))+". Please see history area for instructions how to fix this. If you do not fix this, some tools will not work. "
				DoAlert /T="Insufficient screen size found" 0, Message
			elseif(DisplayResult)
				Message ="Your display size is "+num2str(floor(Curwidth))+"x"+num2str(floor(CurHeight))+". "
				DoAlert /T="Screen size available to Igor" 0, Message
			else
				//print "Found display area "+num2str(floor(Curwidth))+"x"+num2str(floor(CurHeight))+". This should be sufficient for Irena/Nika/Indra package use. "
			endif  
		endif 
	endif
	LastCheck =  datetime
end

//**************************************************************** 
//**************************************************************** 
Function/T IN2G_RemoveInvisibleFiles(ListIn)
		string ListIn
		string ListOut
		//remove various invisible files and any other useless stuff... 
		//ListOut = GrepList(ListIn, "^[^.].*$" )
		ListOut = GrepList(ListIn, "^\." ,1 )
		ListOut = GrepList(ListOut, ".plist" ,1 )
		ListOut = GrepList(ListOut, ".DS_Store" ,1 )
		ListOut = RemoveFromList("EagleFiler Metadata.plist", ListOut)
		
		return ListOut
end
//**************************************************************** 
//**************************************************************** 
Function IN2G_OpenWebManual(WhichSpecificPage)
		String WhichSpecificPage
		BrowseURL "http://saxs-igorcodedocs.readthedocs.io/"+ManualVersionString+WhichSpecificPage
end
//**************************************************************** 
//**************************************************************** 
//************************************************************** 
//**************************************************************** 
Function IN2G_FindFileVersion(FilenameStr)
	string FilenameStr
	
	Wave/T PathToFIles= root:Packages:UseProcedureFiles:PathToFIles
	Wave/T FileNames=root:Packages:UseProcedureFiles:FileNames
	Wave FileVersions =root:Packages:UseProcedureFiles:FileVersions
	variable i, imax=Numpnts(FileNames), versionFound
	string tempname
	versionFound=-1
	For(i=0;i<imax;i+=1)
		tempname = FileNames[i]
		if(stringmatch(tempname,FileNameStr))
			versionFound = FileVersions[i]
			return versionFound
		endif
	endfor
	return -1
end

//**************************************************************** 
//**************************************************************** 
Function IN2G_ListIgorProcFiles()
	GetFileFolderInfo/Q/Z/P=Igor "Igor Procedures"	
	if(V_Flag==0)
		IN2G_ListProcFiles(S_Path,1 )
	endif
	GetFileFolderInfo/Q/Z IN2G_GetIgorUserFilesPath()+"Igor Procedures:"
	if(V_Flag==0)
		IN2G_ListProcFiles(IN2G_GetIgorUserFilesPath()+"Igor Procedures:",0)
	endif
	KillPath/Z tempPath
end
 //**************************************************************** 
//**************************************************************** 
//**************************************************************** 
//**************************************************************** 
static Function IN2G_ListProcFiles(PathStr, resetWaves)
	string PathStr
	variable resetWaves
	String abortMessage	//HR Used if we have to abort because of an unexpected error
	string OldDf=GetDataFolder(1)
	//create location for the results waves...
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:UseProcedureFiles
	//if this is top call to the routine we need to wipe out the waves so we remove old junk
	string CurFncName=GetRTStackInfo(1)
	string CallingFncName=GetRTStackInfo(2)
	variable runningTopLevel=0
	if(!stringmatch(CurFncName,CallingFncName))
		runningTopLevel=1
	endif
	if(resetWaves)
			Make/O/N=0/T FileNames		
			Make/O/N=0/T PathToFiles
			Make/O/N=0 FileVersions
	endif
	//if this was first call, now the waves are gone.
	//and now we need to create the output waves
	Wave/Z/T FileNames
	Wave/Z/T PathToFiles
	Wave/Z FIleVersions
	If(!WaveExists(FileNames) || !WaveExists(PathToFiles) || !WaveExists(FIleVersions))
		Make/O/T/N=0 FileNames, PathToFIles
		Make/O/N=0 FileVersions
		Wave/T FileNames
		Wave/T PathToFiles
		Wave FileVersions
		//I am not sure if we really need all of those declarations, but, well, it should not hurt...
	endif 
	//this is temporary path to the place we are looking into now...  
	NewPath/Q/O tempPath, PathStr
	if (V_flag != 0)		//HR Add error checking to prevent infinite loop
		sprintf abortMessage, "Unexpected error creating a symbolic path pointing to \"%s\"", PathStr
		Print abortMessage	// To make debugging easier
		Abort abortMessage
	endif
	//list al items in this path
	string ItemsInTheFolder= IndexedFile(tempPath,-1,"????")+IndexedDir(tempPath, -1, 0 )
	//HR If there is a shortcut in "Igor Procedures", ItemsInTheFolder will include something like "HDF5 Browser.ipf.lnk". Windows shortcuts are .lnk files.	
	//remove all . files. 
	ItemsInTheFolder = GrepList(ItemsInTheFolder, "^\." ,1)
	//Now we removed all junk files on Macs (starting with .)
	//now lets check what each of these files are and add to the right lists or follow...
	variable i, imax=ItemsInList(ItemsInTheFolder)
	string tempFileName, tempScraptext, tempPathStr
	variable IamOnMac, isItXOP
	if(stringmatch(IgorInfo(2),"Windows"))
		IamOnMac=0
	else
		IamOnMac=1
	endif
	For(i=0;i<imax;i+=1)
		tempFileName = stringfromlist(i,ItemsInTheFolder)
		GetFileFolderInfo/Z/Q/P=tempPath tempFileName
		isItXOP = IamOnMac * stringmatch(tempFileName, "*xop*" )
		
		if(V_isAliasShortcut)
			//HR If tempFileName is "HDF5 Browser.ipf.lnk", or any other shortcut to a file, S_aliasPath is a path to a file, not a folder.
			//HR Thus the "NewPath tempPath" command will fail.
			//HR Thus tempPath will retain its old value, causing you to recurse the same folder as before, resulting in an infinite loop.
			
			//is alias, need to follow and look further. Use recursion...
			if(strlen(S_aliasPath)>3)		//in case user has stale alias, S_aliasPath has 0 length. Need to skip this pathological case. 
				//HR Recurse only if S_aliasPath points to a folder. I don't really know what I'm doing here but this seems like it will prevent the infinite loop.
				GetFileFolderInfo/Z/Q/P=tempPath S_aliasPath	
				isItXOP = IamOnMac * stringmatch(S_aliasPath, "*xop*" )
				if (V_flag==0 && V_isFolder&&!isItXOP)		//this is folder, so all items in the folder are included... Except XOP is folder too... 
					IN2G_ListProcFiles(S_aliasPath, 0)
				elseif(V_flag==0 && (!V_isFolder || isItXOP))	//this is link to file. Need to include the info on the file...
					//*************
					Redimension/N=(numpnts(FileNames)+1) FileNames, PathToFiles,FileVersions
					tempFileName =stringFromList(ItemsInList(S_aliasPath,":")-1, S_aliasPath,":")
					tempPathStr = RemoveFromList(tempFileName, S_aliasPath,":")
					FileNames[numpnts(FileNames)] = tempFileName
					PathToFiles[numpnts(FileNames)] = tempPathStr
					NewPath/Q/O tempPath, tempPathStr
					//try to get version from #pragma version = ... This seems to be the most robust way I found...
					if(stringmatch(tempFileName, "*.ipf"))
						//Grep/P=$(PathStr)/Z/Q/LIST/E="(?i)^#pragma[ ]*version[ ]*=[ ]*" tempFileName 
						Grep/P=tempPath/Z/Q/LIST/E="(?i)^#pragma[ ]*version[ ]*=[ ]*" tempFileName 
						//print S_Value
						//Grep/P=tempPath/E="(?i)^#pragma[ ]*version[ ]*=[ ]*" tempFileName as "Clipboard"
						//sleep/s (0.02)
						tempScraptext = S_Value //GetScrapText()
						if(strlen(tempScraptext)>10)		//found line with #pragma version"
							tempScraptext = replaceString("#pragma",tempScraptext,"")	//remove #pragma
							tempScraptext = replaceString("version",tempScraptext,"")		//remove version
							tempScraptext = replaceString("=",tempScraptext,"")			//remove =
							tempScraptext = replaceString("\t",tempScraptext,"  ")			//remove optional tabulators, some actually use them. 
							tempScraptext = removeending(tempScraptext," \r")			//remove optional tabulators, some actually use them. 
							//forget about the comments behind the text. 
		                                       //str2num is actually quite clever in this and converts start of the string which makes sense. 
							FileVersions[numpnts(FileNames)]=str2num(tempScraptext)
						else             //no version found, set to NaN
							FileVersions[numpnts(FileNames)]=NaN
						endif
					else                    //no version for non-ipf files
						FileVersions[numpnts(FileNames)]=NaN
					endif
				//************


				endif
			endif
			//and now when we got back, fix the path definition to previous or all will crash...
			NewPath/Q/O tempPath, PathStr
			if (V_flag != 0)		//HR Add error checking to prevent infinite loop
				sprintf abortMessage, "Unexpected error creating a symbolic path pointing to \"%s\"", PathStr
				Print abortMessage	// To make debugging easier
				Abort abortMessage
			endif
		elseif(V_isFolder&&!isItXOP)	
			//is folder, need to follow into it. Use recursion.
			IN2G_ListProcFiles(PathStr+tempFileName+":", 0)
			//and fix the path back or all will fail...
			NewPath/Q/O tempPath, PathStr
			if (V_flag != 0)		//HR Add error checking to prevent infinite loop
				sprintf abortMessage, "Unexpected error creating a symbolic path pointing to \"%s\"", PathStr
				Print abortMessage	// To make debugging easier
				Abort abortMessage
			endif
		elseif(V_isFile||isItXOP)
			//this is real file. Store information as needed. 
			Redimension/N=(numpnts(FileNames)+1) FileNames, PathToFiles,FileVersions
			FileNames[numpnts(FileNames)-1] = tempFileName
			PathToFiles[numpnts(FileNames)-1] = PathStr
			//try to get version from #pragma version = ... This seems to be the most robust way I found...
			if(stringmatch(tempFileName, "*.ipf"))
				//Grep/P=$(PathStr)/Z/Q/LIST/E="(?i)^#pragma[ ]*version[ ]*=[ ]*" tempFileName 
				Grep/P=tempPath/Z/Q/LIST/E="(?i)^#pragma[ ]*version[ ]*=[ ]*" tempFileName 
				//print S_Value
				//Grep/P=tempPath/E="(?i)^#pragma[ ]*version[ ]*=[ ]*" tempFileName as "Clipboard"
				//sleep/s(0.02)
				//if(SVAR_Exists(S_Value))
					tempScraptext = S_Value			//GetScrapText()
					if(strlen(tempScraptext)>10)		//found line with #pragma version"
						tempScraptext = replaceString("#pragma",tempScraptext,"")	//remove #pragma
						tempScraptext = replaceString("version",tempScraptext,"")		//remove version
						tempScraptext = replaceString("=",tempScraptext,"")			//remove =
						tempScraptext = replaceString("\t",tempScraptext,"  ")			//remove optional tabulators, some actually use them. 
						//forget about the comments behind the text. 
	                                       //str2num is actually quite clever in this and converts start of the string which makes sense. 
						FileVersions[numpnts(FileNames)-1]=str2num(tempScraptext)
					else             //no version found, set to NaN
						FileVersions[numpnts(FileNames)-1]=NaN
					endif
				//else
				//		FileVersions[numpnts(FileNames)-1]=NaN
				//endif
			else                    //no version for non-ipf files
				FileVersions[numpnts(FileNames)-1]=NaN
			endif 
		endif
	endfor
//	if(runningTopLevel)
//		//some output here...
//		print "Found   "+num2str(numpnts(FileNames))+"  files in   "+PathStr+" folder, its subfolders and linked folders and subfolders"
//		KillPath/Z tempPath
//	endif
 
	setDataFolder OldDf
end


//***********************************
//***********************************
//***********************************
//***********************************
static Function /S IN2G_Windows2IgorPath(pathIn)
	String pathIn
	String pathOut = ParseFilePath(5, pathIn, ":", 0, 0)
	return pathOut
End
//***********************************
//***********************************
//***********************************
//***********************************

static Function/S IN2G_GetIgorUserFilesPath()
	// This should be a Macintosh path but, because of a bug prior to Igor Pro 6.20B03
	// it may be a Windows path.
	String path = SpecialDirPath("Igor Pro User Files", 0, 0, 0)
	path = IN2G_Windows2IgorPath(path)
	return path
End

//***********************************
//***********************************

//**************************************************************** 
//**************************************************************** 
//**************************************************************** 
//**************************************************************** 

Function IN2G_FindVersionOfSingleFile(tempFileName,PathStr)
	string tempFileName, PathStr
		
		string tempScraptext, oldScrap
				//oldScrap = GetScrapText()
				//Grep/P=$(PathStr)/Z/E="(?i)^#pragma[ ]*version[ ]*=[ ]*" tempFileName as "Clipboard"
		Grep/P=$(PathStr)/Z/Q/LIST/E="(?i)^#pragma[ ]*version[ ]*=[ ]*" tempFileName 
				//print S_Value
				///sleep/s (0.02)
		tempScraptext = S_Value //GetScrapText()
		if(strlen(tempScraptext)>10)		//found line with #pragma version"
			tempScraptext = replaceString("#pragma",tempScraptext,"")	//remove #pragma
			tempScraptext = replaceString("version",tempScraptext,"")		//remove version
			tempScraptext = replaceString("=",tempScraptext,"")			//remove =
			tempScraptext = replaceString("\t",tempScraptext,"  ")			//remove optional tabulators, some actually use them. 
			tempScraptext = RemoveEnding(tempScraptext,"\r")			//remove optional tabulators, some actually use them. 
					//forget about the comments behind the text. 
					//PutScrapText oldScrap
         			//str2num is actually quite clever in this and converts start of the string which makes sense. 
			return str2num(tempScraptext)
		else             //no version found, set to NaN
					//PutScrapText oldScrap
			return NaN
		endif

end

//****************************************************************************************
//**************************************************************************************
Function IN2G_CheckPlatformGUIFonts()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR/Z Platform = root:Packages:Irena_Platform
	if(!SVAR_Exists(Platform))
		string/g root:Packages:Irena_Platform
		SVAR Platform = root:Packages:Irena_Platform
		Platform = ""
	endif
	string oldPlatform = Platform
	string CurPlatform = IgorInfo(2)
	string CurExpName=IgorInfo(1)
	if(!stringMatch(Platform, CurPlatform) || stringMatch(CurExpName,"Untitled"))			//different platform or new experiment. 
		IN2G_ReadIrenaGUIPackagePrefs(0)
	endif
	Platform = CurPlatform
end

//***********************************************************
//***********************************************************
structure IrenaPanelDefaults
	uint32 version					// Preferences structure version number. 100 means 1.00.
	uchar LegendFontType[50]		//50 characters for legend font name
	uchar PanelFontType[50]		//50 characters for panel font name
	uint32 defaultFontSize		//font size as integer
	uint32 LegendSize				//font size as integer
	uint32 TagSize					//font size as integer
	uint32 AxisLabelSize			//font size as integer
	int16 LegendUseFolderName	//font size as integer
	int16 LegendUseWaveName		//font size as integer
	variable LastUpdateCheck
	uint32 Uncertainity			//Nika specific - Uncertainity choice - 0 is Old, 1 is Std dev, and 2 is SEM
	variable LastUpdateCheckIrena
	variable LastUpdateCheckNika
	int16 DoNotRestorePanelSizes //do not restore panel sizes
	uchar NikaColorTable[20]		//20 characters for legend font name
	uint32 Igor8UseLongNames		// Use long names in gor 8+.
	uint32 UseUserNameString		// Use UserSampleName instead of folder names.
	uint32 reserved[77]			// Reserved for future use
	
endstructure
//***********************************************************
//***********************************************************

Function IN2G_ConfigMain()		//call configuration routine

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//this is main configuration utility... 
	IN2G_InitConfigMain()
	//DoWindow IR2C_MainConfigPanel
	DoWindow IN2G_MainConfigPanel
	if(!V_Flag)
		Execute ("IN2G_MainConfigPanelProc()")
	else
		DoWindow/F IN2G_MainConfigPanelProc
	endif
	IN2G_ReadIrenaGUIPackagePrefs(1)
end

//***********************************************************
//***********************************************************


Function IN2G_InitConfigMain()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//initialize lookup parameters for user selected items.
	string OldDf=getDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:IrenaConfigFolder
	
	string ListOfVariables
	string ListOfStrings
	//here define the lists of variables and strings needed, separate names by ;...
	ListOfVariables="LegendSize;TagSize;AxisLabelSize;LegendUseFolderName;LegendUseWaveName;DefaultFontSize;LastUpdateCheck;"
	ListOfVariables+="SelectedUncertainity;LastUpdateCheckNika;LastUpdateCheckIrena;DoNotRestorePanelSizes;"
	ListOfVariables+="Igor8UseLongNames;UseUserNameString;"
	ListOfStrings="FontType;ListOfKnownFontTypes;DefaultFontType;"
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	//Now set default values
	String VariablesDefaultValues
	String StringsDefaultValues
	if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
		VariablesDefaultValues="LegendSize:8;TagSize:8;AxisLabelSize:8;LegendUseFolderName:0;LegendUseWaveName:0;"
	else
		VariablesDefaultValues="LegendSize:10;TagSize:10;AxisLabelSize:10;LegendUseFolderName:0;LegendUseWaveName:0;"
	endif
	StringsDefaultValues="FontType:"+StringFromList(0, IN2G_CreateUsefulFontList() ) +";"

	variable CurVarVal
	string CurVar, CurStr, CurStrVal
	For(i=0;i<ItemsInList(VariablesDefaultValues);i+=1)
		CurVar = StringFromList(0,StringFromList(i, VariablesDefaultValues),":")
		CurVarVal = numberByKey(CurVar, VariablesDefaultValues)
		NVAR temp=$(CurVar)
		if(temp==0)
			temp = CurVarVal
		endif
	endfor
	For(i=0;i<ItemsInList(StringsDefaultValues);i+=1)
		CurStr = StringFromList(0,StringFromList(i, StringsDefaultValues),":")
		CurStrVal = stringByKey(CurStr, StringsDefaultValues)
		SVAR tempS=$(CurStr)
		if(strlen(tempS)<1)
			tempS = CurStrVal
		endif
	endfor
	
	SVAR ListOfKnownFontTypes=ListOfKnownFontTypes
	ListOfKnownFontTypes=IN2G_CreateUsefulFontList()
	//Nika needs to be handled here also...
	SetDataFolder root:
	SetDataFolder root:Packages
	NewDataFolder/O/S root:Packages:Convert2Dto1D
	ListOfVariables="DoubleClickConverts;ErrorCalculationsUseOld;ErrorCalculationsUseStdDev;ErrorCalculationsUseSEM"
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		

	setDataFolder OldDf
end
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************

Function/S IN2G_CreateUsefulFontList()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string SystemFontList=FontList(";")
	string PreferredFontList="Tahoma;Times;Arial$;Geneva;Palatino;Book Antiqua;"
	PreferredFontList+="Courier;Vardana;Monaco;Courier CE;System;Verdana;"
	
	variable i
	string UsefulList="", tempList=""
	For(i=0;i<ItemsInList(PreferredFontList);i+=1)
		tempList=GrepList(SystemFontList, stringFromList(i,PreferredFontList)) 
		if(strlen(tempList)>0)
			UsefulList+=tempList
		endif
	endfor
	return UsefulList
end

//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function IN2G_SaveIrenaGUIPackagePrefs(KillThem)
	variable KillThem
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	struct  IrenaPanelDefaults Defs
	IN2G_InitConfigMain()
	SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
	NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
	NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
	NVAR TagSize=root:Packages:IrenaConfigFolder:TagSize
	NVAR AxisLabelSize=root:Packages:IrenaConfigFolder:AxisLabelSize
	NVAR LegendUseFolderName=root:Packages:IrenaConfigFolder:LegendUseFolderName
	NVAR LegendUseWaveName=root:Packages:IrenaConfigFolder:LegendUseWaveName
	NVAR LastUpdateCheckIrena=root:Packages:IrenaConfigFolder:LastUpdateCheckIrena
	NVAR LastUpdateCheckNika=root:Packages:IrenaConfigFolder:LastUpdateCheckNika
	NVAR LastUpdateCheck=root:Packages:IrenaConfigFolder:LastUpdateCheck
	NVAR SelectedUncertainity = root:Packages:IrenaConfigFolder:SelectedUncertainity
	NVAR DoNotRestorePanelSizes = root:Packages:IrenaConfigFolder:DoNotRestorePanelSizes
	NVAR Igor8UseLongNames=root:Packages:IrenaConfigFolder:Igor8UseLongNames
	NVAR UseUserNameString=root:Packages:IrenaConfigFolder:UseUserNameString
	SVAR FontType=root:Packages:IrenaConfigFolder:FontType
	SVAR/Z ColorTableName = root:Packages:Convert2Dto1D:ColorTableName
	if(!SVAR_Exists(ColorTableName))
		NewDataFOlder/O root:Packages:Convert2Dto1D
		string/g root:Packages:Convert2Dto1D:ColorTableName
		SVAR ColorTableName = root:Packages:Convert2Dto1D:ColorTableName
	endif

	Defs.Version					=		3
	Defs.PanelFontType	 		= 		DefaultFontType
	Defs.defaultFontSize 		= 		DefaultFontSize 
	Defs.LegendSize 			= 		LegendSize
	Defs.TagSize 				= 		TagSize
	Defs.AxisLabelSize 		= 		AxisLabelSize
	Defs.LegendUseFolderName = 		LegendUseFolderName
	Defs.LegendUseWaveName 	= 		LegendUseWaveName
	Defs.LegendFontType		= 		FontType
	Defs.LastUpdateCheck		=		LastUpdateCheck
	Defs.LastUpdateCheckIrena	=	LastUpdateCheckIrena
	Defs.LastUpdateCheckNika	=		LastUpdateCheckNika
	Defs.Uncertainity  		= 		SelectedUncertainity
	Defs.DoNotRestorePanelSizes = DoNotRestorePanelSizes
	Defs.NikaColorTable	 = 		ColorTableName
	Defs.Igor8UseLongNames	 = 	Igor8UseLongNames
	Defs.UseUserNameString	 = 	UseUserNameString
	
	if(KillThem)
		SavePackagePreferences /Kill   "IrenaNika" , "IrenaNikaDefaultPanelControls.bin", 0 , Defs		//does not work below 6.10
	else
		SavePackagePreferences /FLSH=1   "IrenaNika" , "IrenaNikaDefaultPanelControls.bin", 0 , Defs
	endif
end
//***********************************************************
//***********************************************************

Function IN2G_ReadIrenaGUIPackagePrefs(ForceRead)
	variable ForceRead
	//debugger
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	struct  IrenaPanelDefaults Defs 
	IN2G_InitConfigMain()
	//keep checking only rarely. 
	NVAR/Z LastDefaultsCheck=root:Packages:IrenaConfigFolder:LastDefaultsCheck
	if(!NVAR_Exists	(LastDefaultsCheck))
		variable/g root:Packages:IrenaConfigFolder:LastDefaultsCheck
		NVAR LastDefaultsCheck=root:Packages:IrenaConfigFolder:LastDefaultsCheck
		LastDefaultsCheck = 0
	endif
	if((DateTime - LastDefaultsCheck)>(60*60)||ForceRead)
		LastDefaultsCheck = DateTime
		SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
		NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
		NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
		NVAR TagSize=root:Packages:IrenaConfigFolder:TagSize
		NVAR AxisLabelSize=root:Packages:IrenaConfigFolder:AxisLabelSize
		NVAR LegendUseFolderName=root:Packages:IrenaConfigFolder:LegendUseFolderName
		NVAR LegendUseWaveName=root:Packages:IrenaConfigFolder:LegendUseWaveName
		NVAR LastUpdateCheck=root:Packages:IrenaConfigFolder:LastUpdateCheck
		SVAR FontType=root:Packages:IrenaConfigFolder:FontType
		NVAR LastUpdateCheckIrena=root:Packages:IrenaConfigFolder:LastUpdateCheckIrena
		NVAR LastUpdateCheckNika=root:Packages:IrenaConfigFolder:LastUpdateCheckNika
		NVAR SelectedUncertainity = root:Packages:IrenaConfigFolder:SelectedUncertainity
		NVAR DoNotRestorePanelSizes=root:Packages:IrenaConfigFolder:DoNotRestorePanelSizes
		NVAR Igor8UseLongNames=root:Packages:IrenaConfigFolder:Igor8UseLongNames
		NVAR UseUserNameString=root:Packages:IrenaConfigFolder:UseUserNameString
		variable PanelUp=0
		DOWindow IN2G_MainConfigPanel  
		if(V_Flag)
			PanelUp=1
		endif
		variable DoWarning=0, pOld, pStdDev, pSEM
		LoadPackagePreferences /MIS=1   "IrenaNika" , "IrenaNikaDefaultPanelControls.bin", 0 , Defs
		if(V_Flag==0)		
			//print Defs
			//print "Read Irena Panels and graphs preferences from local machine and applied them. "
			//print "Note that this may have changed font size and type selection originally saved with the existing experiment."
			//print "To change them please use \"Configure default fonts and names\""
			if(Defs.Version==1 || Defs.Version==2)		//Lets declare the one we know as 1
				//NI1_ReadNikaGUIPackagePrefs()				//read the old Nika preferences, if exist.... 
				DefaultFontType=Defs.PanelFontType
				DefaultFontSize = Defs.defaultFontSize
				LastUpdateCheck = Defs.LastUpdateCheck
				if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
					DefaultGUIFont /Win   all= {DefaultFontType, DefaultFontSize, 0 }
				else
					DefaultGUIFont /Mac   all= {DefaultFontType, DefaultFontSize, 0 }
				endif
				//and now recover the stored other parameters, no action on these...
				 LegendSize=Defs.LegendSize
				 TagSize=Defs.TagSize
				 AxisLabelSize=Defs.AxisLabelSize
				 LegendUseFolderName=Defs.LegendUseFolderName
				 LegendUseWaveName=Defs.LegendUseWaveName
				 FontType=Defs.LegendFontType
		 		 SelectedUncertainity = 0
				 LastUpdateCheckIrena = LastUpdateCheck
				 LastUpdateCheckNika  = LastUpdateCheck
			elseif(Defs.Version==3)
				DefaultFontType=Defs.PanelFontType
				if(strlen(DefaultFontType)<4)
					DefaultFontType="_IgorSmall"
				endif
				DefaultFontSize = Defs.defaultFontSize
				if(DefaultFontSize<6)
					DefaultFontSize=10
				endif
				LastUpdateCheck = Defs.LastUpdateCheckIrena
				LastUpdateCheckIrena = Defs.LastUpdateCheckIrena
				LastUpdateCheckNika = Defs.LastUpdateCheckNika
		 		SelectedUncertainity = Defs.Uncertainity 
				if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
					DefaultGUIFont /Win   all= {DefaultFontType, DefaultFontSize, 0 }
				else
					DefaultGUIFont /Mac   all= {DefaultFontType, DefaultFontSize, 0 }
				endif
				//and now recover the stored other parameters, no action on these...
				 LegendSize=Defs.LegendSize
				 TagSize=Defs.TagSize
				 AxisLabelSize=Defs.AxisLabelSize
				 LegendUseFolderName=Defs.LegendUseFolderName
				 LegendUseWaveName=Defs.LegendUseWaveName
				 FontType=Defs.LegendFontType
				 DoNotRestorePanelSizes = Defs.DoNotRestorePanelSizes
				 if(numtype(Defs.Igor8UseLongNames)==0)
				 	Igor8UseLongNames = Defs.Igor8UseLongNames
				 else
				 	Igor8UseLongNames = 0
				 	print "Set Igor8UseLongNames to 0" 
				 endif	
				 if(numtype(Defs.UseUserNameString)==0)
				 	UseUserNameString = Defs.UseUserNameString
				 else
				 	UseUserNameString = 0
				 	print "Set UseUserNameString to 0" 
				 endif	
				 
				//Nika uncertainity
				NVAR/z ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
				NVAR/z ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
				NVAR/z ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
				string OldDf=GetDataFolder(1)
				if(!NVAR_Exists(ErrorCalculationsUseOld))
					setDataFolder root:
					NewDataFolder/S/O Packages
					NewDataFolder/S/O Convert2Dto1D
					variable/g ErrorCalculationsUseOld, ErrorCalculationsUseStdDev, ErrorCalculationsUseSEM
					NVAR ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
					NVAR ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
					NVAR ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
					setDataFolder OldDf
				endif
				pOld = ErrorCalculationsUseOld
				pStdDev = ErrorCalculationsUseStdDev
				pSEM = ErrorCalculationsUseSEM
				if(SelectedUncertainity==0)
					ErrorCalculationsUseOld=1
					ErrorCalculationsUseStdDev=0
					ErrorCalculationsUseSEM=0
				elseif(SelectedUncertainity==1)
					ErrorCalculationsUseOld=0
					ErrorCalculationsUseStdDev=1
					ErrorCalculationsUseSEM=0
				elseif(SelectedUncertainity==2)
					ErrorCalculationsUseOld=0
					ErrorCalculationsUseStdDev=0
					ErrorCalculationsUseSEM=1
				endif
				if(ErrorCalculationsUseOld && !pOld)
					print "Nika users : Uncertainty calculation method has changed to \"Old method (see manual for description)\""
				elseif(ErrorCalculationsUseStdDev && !pStdDev)
					print "Nika users : Uncertainty calculation method has changed to \"Standard deviation (see manual for description)\""
				elseif(ErrorCalculationsUseSEM && !pSEM)
					print "Nika users : Uncertainty calculation method has changed to \"Standard error of mean (see manual for description)\""
				endif
				SVAR/Z ColorTableName = root:Packages:Convert2Dto1D:ColorTableName
				if(!SVAR_Exists(ColorTableName))
					setDataFolder root:
					NewDataFolder/S/O Packages
					NewDataFolder/S/O Convert2Dto1D
					string/g ColorTableName
					SVAR ColorTableName = root:Packages:Convert2Dto1D:ColorTableName
					setDataFolder OldDf
				endif
				ColorTableName	= Defs.NikaColorTable	
				DoWIndow NI1A_Convert2Dto1DPanel
				if(V_Flag)
					PopupMenu ColorTablePopup,win=NI1A_Convert2Dto1DPanel,popvalue=ColorTableName
#if(Exists("NI1A_TopCCDImageUpdateColors")==6)					
					NI1A_TopCCDImageUpdateColors(1)
#endif
				endif
			else
				if(PanelUp==0)
					DoAlert 1, "Old version of GUI and Graph Fonts (font size and type preference) found. Do you want to update them now? These are set once on a computer and can be changed in \"Configure default fonts and names\"" 
					if(V_Flag==1)
						Execute("IN2G_MainConfigPanelProc() ")
					else
					//	SavePackagePreferences /Kill   "Irena" , "IrenaDefaultPanelControls.bin", 0 , Defs	//does not work below 6.10
					endif
				endif
			endif
		else 		//problem loading package defaults
			string defFnt
			variable defFntSize
			if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
				defFnt=stringFromList(0,IN2G_CreateUsefulFontList())
				defFntSize=12
			else
				defFnt="Geneva"
				defFntSize=9
			endif
			SVAR ListOfKnownFontTypes=root:Packages:IrenaConfigFolder:ListOfKnownFontTypes
			SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
			DefaultFontType = defFnt
			NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
			DefaultFontSize = defFntSize
			IN2G_ChangePanelCOntrolsStyle()
			IN2G_SaveIrenaGUIPackagePrefs(0)
			DoAlert 1, "GUI and Graph defaults (font size and type preferences) not found. They were set to defaults. Do you want to set check now? These are set once on a computer and can be changed in \"Configure default fonts and names\" dialog" 
			if(V_Flag==1)
				Execute("IN2G_MainConfigPanelProc() ")
			endif	
		endif
	else
			//we read the parameters in the last hour. That shoudl be enough... 
	endif
end
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************

Proc IN2G_MainConfigPanelProc() 
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DoWIndow IN2G_MainConfigPanel
	if(V_Flag)
		DoWIndow/F IN2G_MainConfigPanel
	else
		PauseUpdate; Silent 1		// building window...
		NewPanel /K=1/W=(282,48,707,500) as "Configure Irena/Nika default fonts and names"
		DoWindow /C IN2G_MainConfigPanel
		SetDrawLayer UserBack
		SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,52224)
		DrawText 10,25,"Panels and graphs default fonts and names"
		SetDrawEnv fsize= 14,fstyle= 3, textrgb= (63500,4369,4369)
		DrawText 30,53,"Panel and controls font type & size (preference)"
		SetDrawEnv fsize= 14,fstyle= 3,textrgb= (63500,4369,4369)
		DrawText 30,150,"Graph text elements"
		SetDrawEnv fsize= 14,fstyle= 3,textrgb= (63500,4369,4369)
		DrawText 30,310,"Nika specific controls (if you need them)"
	//	SVAR ListOfKnownFontTypes=root:Packages:IrenaConfigFolder:ListOfKnownFontTypes
	
		PopupMenu DefaultFontType,pos={35,65},size={113,21},proc=IN2G_PopMenuProc,title="Panel Controls Font"
		PopupMenu DefaultFontType,mode=(1+WhichListItem(root:Packages:IrenaConfigFolder:DefaultFontType, root:Packages:IrenaConfigFolder:ListOfKnownFontTypes))
		PopupMenu DefaultFontType, popvalue=root:Packages:IrenaConfigFolder:DefaultFontType,value= #"IN2G_CreateUsefulFontList()"
		PopupMenu DefaultFontSize,pos={35,95},size={113,21},proc=IN2G_PopMenuProc,title="Panel Controls Font Size"
		PopupMenu DefaultFontSize,mode=(1+WhichListItem(num2str(root:Packages:IrenaConfigFolder:DefaultFontSize), "8;9;10;11;12;14;16;18;20;24;26;30;"))
		PopupMenu DefaultFontSize popvalue=num2str(root:Packages:IrenaConfigFolder:DefaultFontSize),value= #"\"8;9;10;11;12;14;16;18;20;24;26;30;\""
		Button DefaultValues title="Default",pos={290,70},size={120,20}
		Button DefaultValues proc=IN2G_KillPrefsButtonProc

		CheckBox DoNotRestorePanelSizes,pos={220,100},size={80,16},noproc,title="DO NOT restore Panel Sizes ?"
		CheckBox DoNotRestorePanelSizes,variable= root:Packages:IrenaConfigFolder:DoNotRestorePanelSizes, help={"Check to avoid having Panel sizes restored"}

	
		PopupMenu LegendSize,pos={35,165},size={113,21},proc=IN2G_PopMenuProc,title="Legend Size"
		PopupMenu LegendSize,mode=(1+WhichListItem(num2str(root:Packages:IrenaConfigFolder:LegendSize), "8;9;10;11;12;14;16;18;20;24;26;30;"))
		PopupMenu LegendSize, popvalue=num2str(root:Packages:IrenaConfigFolder:LegendSize),value= #"\"8;9;10;11;12;14;16;18;20;24;26;30;\""
	//LegendUseFolderName:1;LegendUseWaveName
		CheckBox LegendUseFolderName,pos={195,165},size={25,16},noproc,title="Legend use Folder Names?"
		CheckBox LegendUseFolderName,variable= root:Packages:IrenaConfigFolder:LegendUseFolderName, help={"Check to use folder names in legends?"}
		CheckBox LegendUseWaveName,pos={195,205},size={25,16},noproc,title="Legend use Wave Names?"
		CheckBox LegendUseWaveName,variable= root:Packages:IrenaConfigFolder:LegendUseWaveName, help={"Check to use wave names in legends?"}
		PopupMenu TagSize,pos={49,195},size={96,21},proc=IN2G_PopMenuProc,title="Tag Size"
		PopupMenu TagSize,mode=(1+WhichListItem(num2str(root:Packages:IrenaConfigFolder:TagSize), "8;9;10;11;12;14;16;18;20;24;26;30;"))
		PopupMenu TagSize,popvalue=num2str(root:Packages:IrenaConfigFolder:TagSize),value= #"\"8;9;10;11;12;14;16;18;20;24;26;30;\""
		PopupMenu AxisLabelSize,pos={46,225},size={103,21},proc=IN2G_PopMenuProc,title="Label Size"
		PopupMenu AxisLabelSize,mode=(1+WhichListItem(num2str(root:Packages:IrenaConfigFolder:AxisLabelSize), "8;9;10;11;12;14;16;18;20;24;26;30;"))
		PopupMenu AxisLabelSize,popvalue=num2str(root:Packages:IrenaConfigFolder:AxisLabelSize),value= #"\"8;9;10;11;12;14;16;18;20;24;26;30;\""
		PopupMenu FontType,pos={48,255},size={114,21},proc=IN2G_PopMenuProc,title="Font type"
		PopupMenu FontType,mode=(1+WhichListItem(root:Packages:IrenaConfigFolder:FontType, root:Packages:IrenaConfigFolder:ListOfKnownFontTypes))
		PopupMenu FontType,popvalue=root:Packages:IrenaConfigFolder:FontType,value= #"root:Packages:IrenaConfigFolder:ListOfKnownFontTypes"
		//Long names handling
		CheckBox Igor8UseLongNames,pos={210,340},size={80,16},noproc,title="Use long names (Igor 8+) ?"
		CheckBox Igor8UseLongNames,variable= root:Packages:IrenaConfigFolder:Igor8UseLongNames, help={"Check to use long names in igor 8+?"}
		CheckBox UseUserNameString,pos={210,370},size={80,16},noproc,title="Use UserNameString ?"
		CheckBox UseUserNameString,variable= root:Packages:IrenaConfigFolder:UseUserNameString, help={"Check to use usernameString notfolder for GUI "}

		//Nika
		//CheckBox DoubleClickConverts,pos={250,340},size={80,16},noproc,title="Double click converts ?", mode=0
		//CheckBox DoubleClickConverts,variable= root:Packages:Convert2Dto1D:DoubleClickConverts, help={"Check to convert files on double click in Files selection"}
		CheckBox ErrorCalculationsUseOld,pos={10,340},size={80,16},proc=IN2G_ConfigErrorsCheckProc,title="Use Old Uncertainity ?", mode=1
		CheckBox ErrorCalculationsUseOld,variable= root:Packages:Convert2Dto1D:ErrorCalculationsUseOld, help={"Check to use Error estimates for before version 1.42?"}
		CheckBox ErrorCalculationsUseStdDev,pos={10,370},size={80,16},proc=IN2G_ConfigErrorsCheckProc,title="Use Std Devfor Uncertainity?", mode=1
		CheckBox ErrorCalculationsUseStdDev,variable= root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev, help={"Check to use Standard deviation for Error estimates "}
		CheckBox ErrorCalculationsUseSEM,pos={10,400},size={80,16},proc=IN2G_ConfigErrorsCheckProc,title="Use SEM for Uncertainity?", mode=1
		CheckBox ErrorCalculationsUseSEM,variable= root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM, help={"Check to use Standard error of mean for Error estimates"}
		Button OKButton title="OK",pos={290,420},size={120,20}
		Button OKButton proc=IN2G_KillPrefsButtonProc
	endif

EndMacro
//***********************************************************
//***********************************************************
//***********************************************************
Function IN2G_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if (cmpstr(ctrlName,"LegendSize")==0)
		NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
		LegendSize = str2num(popStr)
	endif
	if (cmpstr(ctrlName,"TagSize")==0)
		NVAR TagSize=root:Packages:IrenaConfigFolder:TagSize
		TagSize = str2num(popStr)
	endif
	if (cmpstr(ctrlName,"AxisLabelSize")==0)
		NVAR AxisLabelSize=root:Packages:IrenaConfigFolder:AxisLabelSize
		AxisLabelSize = str2num(popStr)
	endif
	if (cmpstr(ctrlName,"FontType")==0)
		SVAR FontType=root:Packages:IrenaConfigFolder:FontType
		FontType = popStr
	endif
	if (cmpstr(ctrlName,"DefaultFontType")==0)
		SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
		DefaultFontType = popStr
		IN2G_ChangePanelControlsStyle()
	endif
	if (cmpstr(ctrlName,"DefaultFontSize")==0)
		NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
		DefaultFontSize = str2num(popStr)
		IN2G_ChangePanelControlsStyle()
	endif
	IN2G_SaveIrenaGUIPackagePrefs(0)
End

//***********************************************************
//***********************************************************
Function IN2G_ConfigErrorsCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	NVAR ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
	NVAR ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
	NVAR ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
	NVAR SelectedUncertainity=root:Packages:IrenaConfigFolder:SelectedUncertainity

	switch( cba.eventCode )
		case 2: // mouse up
			IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
			Variable checked = cba.checked
			if(stringmatch(cba.ctrlName,"ErrorCalculationsUseOld"))
				ErrorCalculationsUseOld = checked
				ErrorCalculationsUseStdDev=!checked
				ErrorCalculationsUseSEM=!checked
				SelectedUncertainity=0
			endif
			if(stringmatch(cba.ctrlName,"ErrorCalculationsUseStdDev"))
				ErrorCalculationsUseOld = !checked
				ErrorCalculationsUseStdDev=checked
				ErrorCalculationsUseSEM=!checked
				SelectedUncertainity=1
			endif
			if(stringmatch(cba.ctrlName,"ErrorCalculationsUseSEM"))
				ErrorCalculationsUseOld = !checked
				ErrorCalculationsUseStdDev=!checked
				ErrorCalculationsUseSEM=checked
				SelectedUncertainity=2
			endif
			break
	endswitch

	return 0
End
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
Function IN2G_KillPrefsButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
			// click code here
			if(stringmatch(ba.ctrlName,"OKBUtton"))
				IN2G_SaveIrenaGUIPackagePrefs(0)
 				KillWIndow/Z IN2G_MainConfigPanel
			elseif(stringmatch(ba.ctrlName,"DefaultValues"))
				string defFnt
				variable defFntSize
				if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
					defFnt=stringFromList(0,IN2G_CreateUsefulFontList())
					defFntSize=12
				else
					defFnt="Geneva"
					defFntSize=9
				endif
				SVAR ListOfKnownFontTypes=root:Packages:IrenaConfigFolder:ListOfKnownFontTypes
				SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
				DefaultFontType = defFnt
				NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize
				DefaultFontSize = defFntSize
				IN2G_ChangePanelCOntrolsStyle()
				IN2G_SaveIrenaGUIPackagePrefs(0)
				PopupMenu DefaultFontType,win=IN2G_MainConfigPanel, mode=(1+WhichListItem(defFnt, ListOfKnownFontTypes))
				PopupMenu DefaultFontSize,win=IN2G_MainConfigPanel, mode=(1+WhichListItem(num2str(defFntSize), "8;9;10;11;12;14;16;18;20;24;26;30;"))
			endif
			break
	endswitch
	return 0
End

//***********************************************************
//***********************************************************
//***********************************************************

//***********************************************************
//***********************************************************
Function/S IN2G_LkUpDfltStr(StrName)
	string StrName

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string result
	string OldDf=getDataFolder(1)
	SetDataFolder root:
	if(!DataFolderExists("root:Packages:IrenaConfigFolder"))
		IN2G_InitConfigMain()
	endif
	SetDataFolder root:Packages
	setDataFolder root:Packages:IrenaConfigFolder
	SVAR /Z curString = $(StrName)
	if(!SVAR_exists(curString))
		IN2G_InitConfigMain()
		SVAR curString = $(StrName)
	endif	
	result = 	"'"+curString+"'"
	setDataFolder OldDf
	return result
end
//***********************************************************
//***********************************************************

Function/S IN2G_LkUpDfltVar(VarName)
	string VarName

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string result
	string OldDf=getDataFolder(1)
	SetDataFolder root:
	if(!DataFolderExists("root:Packages:IrenaConfigFolder"))
		IN2G_InitConfigMain()
	endif
	SetDataFolder root:Packages
	setDataFolder root:Packages:IrenaConfigFolder
	NVAR /Z curVariable = $(VarName)
	if(!NVAR_exists(curVariable))
		IN2G_InitConfigMain()
		NVAR curVariable = $(VarName)
	endif	
	if(curVariable>=10)
		result = num2str(curVariable)
	else
		result = "0"+num2str(curVariable)
	endif
	setDataFolder OldDf
	return result
end
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************

Function IN2G_ChangePanelControlsStyle()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR DefaultFontType=root:Packages:IrenaConfigFolder:DefaultFontType
	NVAR DefaultFontSize=root:Packages:IrenaConfigFolder:DefaultFontSize

	if (stringMatch(IgorInfo(2),"*Windows*"))		//Windows
		DefaultGUIFont /Win   all= {DefaultFontType, DefaultFontSize, 0 }
	else
		DefaultGUIFont /Mac   all= {DefaultFontType, DefaultFontSize, 0 }
	endif

end
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
//***********************************************************
////***********************************************************
//***********************************************************

Function IN2G_PanelResizePanelSize(s)
	STRUCT WMWinHookStruct &s
		//add to the end of panel forming macro these two lines:
		//	IR1_PanelAppendSizeRecordNote()
		//	SetWindow kwTopWin,hook(ResizePanelControls)=IR1_PanelResizeFontSize
		//for font scaling in Titlebox use "\ZrnnnText is here" - scales font by nnn%. Do not use fixed font then. 
	if ( s.eventCode == 6 && (WinType(s.winName)==7))	// resized and is panel, not usable for others. 
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		GetWindow $(s.winName), note
		//string OrigInfo=StringByKey("PanelSize", S_Value, "=", ";")
		string OrigInfo=S_Value
		if(strlen(OrigInfo)<20)				//too short for anything meaningful
			return 0
		endif
		//print s
		GetWindow $s.winName wsize					 
		//wsizeRM?, wsizeDC returns pixels, wsize is in points.
		//MoveWindow is in points <<<<<< !!!!!!!   
		//ModifyControl pos is in pixels, size is in pixels
		//convert using: WidthPoints= WidthPixels * PanelResolution(panelName)/ScreenResolution
		//John Weeks, WM
		//1) Use GetWindow wsize to get window coordinates, not wsizeDC
		//2) For use with MoveWindow, (which wants points, unless you use /I or /M) just use those coordinates.
		//3) For use with NewPanel and for positioning and sizing controls, scale the coordinates using screenResolution/PanelResolution("winname")
		Variable left = V_left
		Variable right = V_right 
		Variable top = V_top
		Variable bottom = V_bottom
		variable horScale, verScale, OriginalWidth, OriginalHeight, CurHeight, CurWidth
		variable moveLeft, MoveRight, MoveTop, moveBottom 			//these need to be in points!! What a mess...
		//variable moveConvFac=PanelResolution(s.winName)/ScreenResolution
		variable OriginalResolution=NumberByKey("Resolution", OrigInfo, ":", ";")
		//SCREEN1:DEPTH=32,RECT=0,0,3840
		string ScreenInfo=StringByKey("SCREEN1", IgorInfo(0)  , ":", ";")+","
		ScreenInfo = RemoveListItem(0, ScreenInfo, ",")
		variable ScreenWidth=str2num(stringFromList(2,StringByKey("RECT", ScreenInfo, "=", ";"),","))
		variable ScreenHeight=str2num(stringFromList(3,StringByKey("RECT", ScreenInfo, "=", ";"),","))
		if(numtype(OriginalResolution)!=0)
			if(StringMatch(IgorInfo(2), "Windows" )) 
				OriginalResolution = 96
			else	//Windows 
				OriginalResolution = 72
			endif
		endif 
		variable moveConvFac=screenResolution/OriginalResolution
		OriginalWidth = NumberByKey("PanelWidth", OrigInfo, ":", ";")		//pixels
		OriginalHeight = NumberByKey("PanelHeight", OrigInfo, ":", ";")	//pixels
		CurWidth = abs(right-left) 													//with DC is pixels
		CurHeight = abs(bottom-top)													//with DC is pixels
		if(CurWidth<OriginalWidth && CurHeight<OriginalHeight)
			moveLeft = left//*moveConvFac
			MoveTop  = top//*moveConvFac
			MoveRight = (left+OriginalWidth)//*moveConvFac
			moveBottom = (top+OriginalHeight)//*moveConvFac
			horScale = 1*moveConvFac
			verScale = 1*moveConvFac
		elseif(CurWidth<OriginalWidth && CurHeight>=OriginalHeight)		
			//MoveWindow left, top, left+OriginalWidth, top+CurHeight
			moveLeft = left//*moveConvFac
			MoveTop  = top//*moveConvFac
			MoveRight = (left+OriginalWidth)//*moveConvFac
			moveBottom = (top+CurHeight)//*moveConvFac
			horScale = 1*moveConvFac
			verScale = CurHeight / (OriginalHeight)	*moveConvFac
		elseif(CurWidth>=OriginalWidth && CurHeight<OriginalHeight)
			//MoveWindow left, top, left+CurWidth, top+OriginalHeight
			moveLeft = left//*moveConvFac
			MoveTop = top//*moveConvFac
			MoveRight = (left+CurWidth)//*moveConvFac
			moveBottom = (top+OriginalHeight)//*moveConvFac
			verScale = 1 *moveConvFac
			horScale = curWidth/OriginalWidth*moveConvFac
		else
			moveLeft = left//*moveConvFac
			MoveTop = top//*moveConvFac
			MoveRight = (right)//*moveConvFac
			moveBottom = (bottom)//*moveConvFac
			verScale = CurHeight /OriginalHeight *moveConvFac
			horScale = curWidth/OriginalWidth *moveConvFac
		endif
		//MoveWindow/W=$(s.winName) moveLeft, MoveTop, MoveRight, moveBottom
		//	print "Moved to "+num2str(moveLeft) +", "+num2str(MoveTop) +", "+num2str(MoveRight) +", "+num2str(moveBottom)
		MoveWindow/W=$(s.winName) moveLeft, MoveTop, MoveRight, moveBottom
		//make sure the window is in the existing field fo view if user changed drastically scrfeen resolution... 
		if(MoveLeft>0.8*ScreenWidth || MoveTop>0.8*ScreenHeight)
			moveLeft = 0.8*ScreenWidth
			MoveTop = 0.8*ScreenHeight
			MoveWindow/W=$(s.winName) moveLeft, MoveTop, -1, -1

		endif		
		
		variable scale= min(horScale, verScale )
		string FontName = IN2G_LkUpDfltStr("DefaultFontType")  //returns font with ' in the beggining and end as needed for Graph formating
		FontName = ReplaceString("'", FontName, "") 				//remove the thing....
		FontName = StringFromList(0,GrepList(FontList(";"), FontName))		//check that similar font exists, if more found use the first one. 
		if(strlen(FontName)<3)											//if we did tno find the font, use default. 
			FontName="_IgorSmall"
		endif
		DefaultGUIFont /W=$(s.winName) all= {FontName, ceil(scale*str2num(IN2G_LkUpDfltVar("defaultFontSize"))), 0 }
		DefaultGUIFont /W=$(s.winName) button= {FontName, ceil(scale*str2num(IN2G_LkUpDfltVar("defaultFontSize"))), 0 }
		DefaultGUIFont /W=$(s.winName) checkbox= {FontName, ceil(scale*str2num(IN2G_LkUpDfltVar("defaultFontSize"))), 0 }
		DefaultGUIFont /W=$(s.winName) tabcontrol= {FontName, ceil(scale*str2num(IN2G_LkUpDfltVar("defaultFontSize"))), 0 }
		DefaultGUIFont /W=$(s.winName) popup= {FontName, ceil(scale*str2num(IN2G_LkUpDfltVar("defaultFontSize"))), 0 }
		DefaultGUIFont /W=$(s.winName) panel= {FontName, ceil(scale*str2num(IN2G_LkUpDfltVar("defaultFontSize"))), 0 }
		variable i, j
		variable OrigCntrlV_left, OrigCntrlV_top, NewCntrolV_left, NewCntrlV_top
		variable OrigWidth, OrigHeight, NewWidth, NewHeight, OrigBodyWidth
		string ControlsRecords=""
		string ListOfPanels=s.winName+";"
		string TmpNm="", tmpName1
		string controlslist=""
		string tmpPanelName
		string SubwindowList=ChildWindowList(s.winName)		//do we have subwindows? 
		if(Strlen(SubwindowList)>0)
			ListOfPanels+=SubwindowList
		endif
		controlslist = ControlNameList(s.winName, ";")
		For(i=0;i<ItemsInList(controlslist, ";");i+=1)
			TmpNm = StringFromList(i, controlslist, ";")			
			OrigCntrlV_left=NumberByKey(TmpNm+"Left", OrigInfo, ":", ";")
			OrigCntrlV_top=NumberByKey(TmpNm+"Top", OrigInfo, ":", ";")
			OrigWidth=NumberByKey(TmpNm+"Width", OrigInfo, ":", ";")
			OrigHeight=NumberByKey(TmpNm+"Height", OrigInfo, ":", ";")
			NewCntrolV_left=OrigCntrlV_left* horScale 
			NewCntrlV_top = OrigCntrlV_top * verScale
			NewWidth = OrigWidth * horScale
			NewHeight = OrigHeight * verScale
			ModifyControl $(TmpNm) pos = {NewCntrolV_left,NewCntrlV_top}, size={NewWidth,NewHeight}, win=$(s.winName) 
			//special cases...
			ControlInfo/W=$(s.winName) $(TmpNm)
			if(abs(V_Flag)==5 ||abs(V_Flag)==3)		//SetVariable
				OrigBodyWidth=NumberByKey(TmpNm+"bodyWidth", OrigInfo, ":", ";")
				if(numtype(OrigBodyWidth)==0)
					ModifyControl $(TmpNm)  bodywidth =horScale*OrigBodyWidth, win=$(s.winName) 
				endif
			endif
		endfor
		For(j=1;j<ItemsInList(ListOfPanels,";");j+=1)
				tmpPanelName = StringFromList(j, ListOfPanels,";")
				tmpName1 = StringFromList(0, ListOfPanels,";")+"#"+StringFromList(j, ListOfPanels,";")
				setActiveSubwindow $tmpName1
				controlslist = ControlNameList(tmpName1, ";")		
				For(i=0;i<ItemsInList(controlslist, ";");i+=1)
					TmpNm = StringFromList(i, controlslist, ";")			
					OrigCntrlV_left=NumberByKey(tmpPanelName+TmpNm+"Left", OrigInfo, ":", ";")
					OrigCntrlV_top=NumberByKey(tmpPanelName+TmpNm+"Top", OrigInfo, ":", ";")
					OrigWidth=NumberByKey(tmpPanelName+TmpNm+"Width", OrigInfo, ":", ";")
					OrigHeight=NumberByKey(tmpPanelName+TmpNm+"Height", OrigInfo, ":", ";")
					NewCntrolV_left=OrigCntrlV_left* horScale 
					NewCntrlV_top = OrigCntrlV_top * verScale
					NewWidth = OrigWidth * horScale
					NewHeight = OrigHeight * verScale
					ModifyControl $(TmpNm) win=$(tmpName1),pos = {NewCntrolV_left,NewCntrlV_top}, size={NewWidth,NewHeight}
					//special cases...
					ControlInfo/W=$(tmpName1) $(TmpNm)
					if(abs(V_Flag)==5 ||abs(V_Flag)==3)		//SetVariable
						OrigBodyWidth=NumberByKey(tmpPanelName+TmpNm+"bodyWidth", OrigInfo, ":", ";")
						if(numtype(OrigBodyWidth)==0)
							ModifyControl $(TmpNm)  bodywidth =horScale*OrigBodyWidth, win=$(tmpName1)
						endif
					endif
				endfor
				SetActiveSubwindow $(StringFromList(0, ListOfPanels,";"))
		endfor
		//Better way, let's lets store it in preferences...
		STRUCT IrenaNikaPanelSizePos PrefsPos
		PrefsPos.version = kPrefsVersion
		PrefsPos.panelCoords[0] = MoveRight-moveLeft		//width
		PrefsPos.panelCoords[1] = moveBottom-MoveTop		//height
		PrefsPos.panelCoords[2] = moveLeft					//left
		PrefsPos.panelCoords[3] = MoveTop						//top
		PrefsPos.panelCoords[4] = MoveRight					//right
		PrefsPos.panelCoords[5] = moveBottom					//bottom
		string Prefname=s.winName+".bin"
		SavePackagePreferences/FLSH=1 kPackageName, Prefname, kPrefsRecordID, PrefsPos	
		return 1
	else
		return 0	
	endif
end


//***********************************************************
//***********************************************************
// Structure definition for panel position and size restore... 
	static Constant kPrefsVersion = 100
	static StrConstant kPackageName = "Irena Nika SAS packages"
	static Constant kPrefsRecordID = 0

Structure IrenaNikaPanelSizePos
	uint32	version		// Preferences structure version number. 100 means 1.00.
	double panelCoords[6]	// width, height, left, top, right, bottom
	uint32 reserved[100]	// Reserved for future use
EndStructure

//***********************************************************
//***********************************************************
Function IN2G_ResetSizesForALlPanels(WindowProcNames)
	string WindowProcNames			//contains list of panels of this package
	//this function is used after compile and will reset all panels to proper size...
	variable i
	string PanelName
	For(i=0;i<ItemsInList(WindowProcNames);i+=1)
		PanelName = StringFromList(0,(StringFromList(i, WindowProcNames, ";")+"="),"=")
		DoWindow $PanelName 
		if(V_Flag)
			//Execute/P/Q("IN2G_ResetPanelSize(\""+PanelName+"\", 0)")
			//debugger
			IN2G_ResetPanelSize(PanelName, 0)
			DoWIndow/F $(PanelName)
			STRUCT WMWinHookStruct s
			s.eventcode=6
			s.winName=panelName
			IN2G_PanelResizePanelSize(s)
		endif 
	endfor
end
//***********************************************************
//***********************************************************

Function IN2G_ResetPanelSize(PanelNameLocal, setSizeIfNeeded)
	string PanelNameLocal
	variable setSizeIfNeeded

	NVAR/Z DoNotRestorePanelSizes=root:Packages:IrenaConfigFolder:DoNotRestorePanelSizes
	if(!NVAR_Exists(DoNotRestorePanelSizes))
		NewDataFOlder/O root:Packages
		NewDataFOlder/O root:Packages:IrenaConfigFolder
		variable/g root:Packages:IrenaConfigFolder:DoNotRestorePanelSizes
		NVAR DoNotRestorePanelSizes=root:Packages:IrenaConfigFolder:DoNotRestorePanelSizes
	endif

	string packageFileName = PanelNameLocal+".bin"
	STRUCT IrenaNikaPanelSizePos PrefsPos
	LoadPackagePreferences kPackageName, packageFileName, kPrefsRecordID, PrefsPos
	variable Left, Top, right, bottom, width, height
	string PanelNameOld
	if(PrefsPos.version!=kPrefsVersion)
		print "Preferences for panel "+PanelNameLocal+" not found or wrong version found..."
	endif
	width 	= 	PrefsPos.panelCoords[0]
	height	=	PrefsPos.panelCoords[1]
	Left		=	PrefsPos.panelCoords[2]
	Top		=	PrefsPos.panelCoords[3]
	right		=	PrefsPos.panelCoords[4]
	bottom	=	PrefsPos.panelCoords[5]
	variable FoundValidPrefs=0
	if(width>100 && height>100 && Left < right && top < bottom && PrefsPos.version==kPrefsVersion)
		FoundValidPrefs = 1
	endif
	//separate scaling for large panels
	variable WidthScale=50
	variable HeightScale = 70
	if(stringmatch(PanelNameLocal,"IR3D_DataMergePanel"))
		WidthScale = 95
		HeightScale = 90
	endif
	
	GetWindow $PanelNameLocal wsize				
	if(Width> IN2G_ScreenWidthHeight("Width")*WidthScale)
		Width = IN2G_ScreenWidthHeight("Width")*WidthScale
	endif
	if(Height> IN2G_ScreenWidthHeight("Height")*HeightScale)
		Height = IN2G_ScreenWidthHeight("Height")*HeightScale
	endif
	variable keys= GetKeyState(0)
	if(keys>0 || FoundValidPrefs<1 || DoNotRestorePanelSizes)		//ANY modifier key was pressed or no/incorrect pref file was found, reset the size
			GetWindow $PanelNameLocal wsize
			MoveWindow/W=$PanelNameLocal V_left, V_top, V_right, V_bottom
			PrefsPos.version = kPrefsVersion
			PrefsPos.panelCoords[0] = V_right-V_left		//width
			PrefsPos.panelCoords[1] = V_bottom-V_top		//height
			PrefsPos.panelCoords[2] = V_left					//left
			PrefsPos.panelCoords[3] = V_top					//top 
			PrefsPos.panelCoords[4] = V_right					//right
			PrefsPos.panelCoords[5] = V_bottom				//bottom
			if(setSizeIfNeeded)
				SavePackagePreferences/FLSH=1 kPackageName, packageFileName, kPrefsRecordID, PrefsPos
			endif
	else
			MoveWindow/W=$PanelNameLocal Left, Top, Left+Width, Top+Height
	endif
	 
	
end
//***********************************************************//*****************************************************************************************************************
//*****************************************************************************************************************
Function IN2G_PanelAppendSizeRecordNote(panelName)
	string panelName
	string PanelRecord=""
	//find size of the panel
	DoWIndow $panelName
	if(V_Flag==0)
		return 0
	endif
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//store main window size
	GetWindow $panelName wsize 		//this value is in pixels
	variable PLatform=0		//0 Mac, 1 Windows
	if(StringMatch(IgorInfo(2), "Windows"))
		PLatform = 1
	endif
	//John Weeks, WM
	//1) Use GetWindow wsize to get window coordinates, not wsizeDC
	//2) For use with MoveWindow, (which wants points, unless you use /I or /M) just use those coordinates.
	//3) For use with NewPanel and for positioning and sizing controls, scale the coordinates using screenResolution/PanelResolution("winname")
	PanelRecord+="PanelLeft:"+num2str(V_left)+";PanelWidth:"+num2str(V_right-V_left)+";PanelTop:"+num2str(V_top)+";PanelHeight:"+num2str(V_bottom-V_top)+";Resolution:"+num2str(ScreenResolution)+";"	
	if(PLatform)	//WIndows
		Button ResizeButton title=" \\W532",size={18,18}, win=$panelName, pos={IN2G_ConvertPointToPix(panelName, V_right-V_left-10),IN2G_ConvertPointToPix(panelName, V_bottom-V_top-10)}, disable=2
	else
		Button ResizeButton title=" \\W532",size={18,18}, win=$panelName, pos={IN2G_ConvertPointToPix(panelName, V_right-V_left-18),IN2G_ConvertPointToPix(panelName, V_bottom-V_top-18)}, disable=2
	endif
	GetWindow $panelName, note				//store existing note. 
	string ExistingNote=S_Value
	variable i, j
	string ControlsRecords=""
	string ListOfPanels=panelName+";"
	string TmpNm=""
	string controlslist=""
	string tmpPanelName, tmpName1
	string SubwindowList=ChildWindowList(panelName )		//do we have subwindows? 
	if(Strlen(SubwindowList)>0)
		ListOfPanels+=SubwindowList
	endif
	controlslist = ControlNameList("", ";")		
	For(i=0;i<ItemsInList(controlslist, ";");i+=1)
		TmpNm = StringFromList(i, controlslist, ";")
		ControlInfo $(TmpNm)				//Dimensions and position of the named control in pixels
		//V_Height, V_Width, V_top, V_left
		ControlsRecords+=TmpNm+"Left:"+num2str(V_left)+";"+TmpNm+"Width:"+num2str(V_width)+";"+TmpNm+"Top:"+num2str(V_top)+";"+TmpNm+"Height:"+num2str(V_Height)+";"
		//special cases...
		if(abs(V_Flag)==5||abs(V_Flag)==3)		//SetVariable
			ControlsRecords+=TmpNm+"bodyWidth:"+StringByKey("bodyWidth", S_recreation, "=",",")+";"
		endif
	endfor
	For(j=1;j<ItemsInList(ListOfPanels,";");j+=1)
			tmpPanelName = StringFromList(j, ListOfPanels,";")
			tmpName1 = StringFromList(0, ListOfPanels,";")+"#"+StringFromList(j, ListOfPanels,";")
			setActiveSubwindow $tmpName1
			controlslist = ControlNameList(tmpName1, ";")		
			For(i=0;i<ItemsInList(controlslist, ";");i+=1)
				TmpNm = StringFromList(i, controlslist, ";")
				ControlInfo $(TmpNm)
				ControlsRecords+=tmpPanelName+TmpNm+"Left:"+num2str(V_left)+";"+tmpPanelName+TmpNm+"Width:"+num2str(V_width)+";"+tmpPanelName+TmpNm+"Top:"+num2str(V_top)+";"+tmpPanelName+TmpNm+"Height:"+num2str(V_Height)+";"
				//special cases...
				if(abs(V_Flag)==5||abs(V_Flag)==3)		//SetVariable
					ControlsRecords+=tmpPanelName+TmpNm+"bodyWidth:"+StringByKey("bodyWidth", S_recreation, "=",",")+";"
				endif
			endfor
			SetActiveSubwindow ##
	endfor
	if(!StringMatch(ExistingNote, "*;"))
		ExistingNote+=";"
	endif
	SetWindow $panelName, note=ExistingNote+PanelRecord+ControlsRecords
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function IN2G_ConvertPointToPix(PanelName, PointsIn)
	string PanelName
	variable PointsIn
	variable PixsOut
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PixsOut = PointsIn* ScreenResolution/PanelResolution(PanelName)
	return PixsOut
end
Function IN2G_ConvertPixToPoint(PanelName, PixsIn)
	string PanelName
	variable PixsIn
	variable PointsOut
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PointsOut = PixsIn/(ScreenResolution/PanelResolution(PanelName))
	return PointsOut
end
#if Exists("PanelResolution") != 3
Static Function PanelResolution(wName)	// For compatibility with Igor 7
	String wName
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	return 72
End
#endif

//*****************************************************************************************************************
//*****************************************************************************************************************
Function IN2G_PrintDebugStatement(CurrentDebugLevel, DebugLevel,DebugStatement)
	variable CurrentDebugLevel, DebugLevel
	string DebugStatement
	
	if(CurrentDebugLevel>=DebugLevel)
		string Location=GetRTStackInfo(3)
		print Secs2Date(DateTime,2)	+Secs2Time(DateTime,3)+"  :  "+Location +" : "+ DebugStatement
	endif

end
//*****************************************************************************************************************
////*****************************************************************************************************************
//Function IN2G_PrintDebugWhichProCalled(FunctionName)
//	string FunctionName
//	if(IrenaDebugLevel==5)
//		
//		print Secs2Date(DateTime,2)	+Secs2Time(DateTime,3)+"  :  now in "+GetRTStackInfo(1)	
//	endif
//end
//
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IN2G_CloneWindow()
	string NewWindowName
	string topWindow=WinName(0,1)
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IN2G_CloneWindow2()
		
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//this is from IgorExchange: http://www.igorexchange.com/node/1469
static Function IN2G_CloneWindow2([win,name,times])
	String win
	String name // The new name for the window and data folder. 
	Variable times // The number of clones to make.  Clones beyond the first will have _2, _3, etc. appended to their names.   
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String curr_folder=GetDataFolder(1)
	setDataFolder root:
	if(ParamIsDefault(win))
		win=WinName(0,1)
	endif
	if(ParamIsDefault(name))
		name=UniqueName(win,6,0)
		name=UniqueName(name,7,0)
		name=UniqueName(name,11,0)
	else
		name=CleanupName(name,0)
		name=UniqueName(name,6,0)
		name=UniqueName(name,7,0)
		name=UniqueName(name,11,0)
	endif
	times=ParamIsDefault(times) ? 1 : times
	NewDataFolder /O/S root:$name
	String win_rec=WinRecreation(win,0)
	String traces=TraceNameList(win,";",3)
	string tempName, trace, AddOn
	Variable i,j
	for(i=0;i<ItemsInList(traces);i+=1)
		trace=StringFromList(i,traces)
		tempName = trace
		if(StringMatch(trace, "#"))			//we have wave with multiplier
			tempName = ReplaceString("'", trace, "")		//removes ' from liberal names
			tempName = ReplaceString("#", trace, "_")		//replaces # for cases when waves of same names are used
			tempName = PossiblyQuoteName(tempName )
		endif
		Wave TraceWave=TraceNameToWaveRef(win,trace)
		Duplicate /o TraceWave $(tempName)
		win_rec = ReplaceString(trace, win_rec, tempName)
		//main wave dealt with
		Wave /Z TraceXWave=XWaveRefFromTrace(win,trace)
		tempName = NameOfWave(TraceXWave)
		if(waveexists(TraceXWave))
			tempName = ReplaceString("'", trace, "")		//remvoes ' from liberal names
			tempName = ReplaceString("#", trace, "_")		//replaces # for cases when waves of same names are used
			tempName = PossiblyQuoteName(tempName )		
			Duplicate /o TraceXWave $NameOfWave(TraceXWave)
		endif
	endfor
 
	// Copy error bars if they exist.  Won't work with subrange display syntax.  
	for(i=0;i<ItemsInList(win_rec,"\r");i+=1)
		String line=StringFromList(i,win_rec,"\r")
		if(StringMatch(line,"*ErrorBars*"))
			String errorbar_names
			sscanf line,"%*[^=]=(%[^)])",errorbar_names
			for(j=0;j<2;j+=1)
				String errorbar_path=StringFromList(j,errorbar_names,",")
				sscanf errorbar_path,"%[^[])",errorbar_path
				String errorbar_name=StringFromList(ItemsInList(errorbar_path,":")-1,errorbar_path,":")
				Duplicate /o $("root:"+errorbar_path) $errorbar_name
			endfor
		endif
	endfor
 
	for(i=1;i<=times;i+=1)
		Execute /Q win_rec
		if(i==1)
			DoWindow /C $name
		else
			DoWindow /C $(name+"_"+num2str(i))
		endif
		ReplaceWave allInCDF
	endfor
	SetDataFolder $curr_folder
End


//*****************************************************************************************************************
//*****************************************************************************************************************
 
//Macro IN2G_ColorWaves()
//	Variable rev = 1
//	String colorTable = "RainbowCycle"
//	IN2G_ColorTraces(rev, colorTable)
//End
// 
Function IN2G_ColorTraces( )
//% V1.5
	Variable rev = 1
	String colorTable = "RainbowCycle"
 
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String list = TraceNameList( "", ";", 1 )
	Variable numItems = ItemsInList( list )
	if ( numItems == 0 )
		return 0
	endif
 
	ColorTab2Wave $colorTable
	Wave M_colors	
 
	Variable index, traceindex
	for( index = 0; index < numItems; index += 1 )			
		Variable row = ( index/numItems )*DimSize( M_Colors, 0 )
		traceindex = ( rev == 0 ? index : numItems - index )
		Variable red = M_Colors[ row ][ 0 ], green = M_Colors[ row ][ 1 ], blue = M_Colors[ row ][ 2 ]
		ModifyGraph/Z rgb[ traceindex ] = ( red, green, blue )
	endfor
 
	KillWaves/Z M_colors
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2G_CreateSubwindowAtMarqee()
       GetMarquee/K
       Variable left= V_left, right= V_right, top= V_top, bottom= V_bottom

			IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
       GetWindow kwTopWin, gsize
       String slashw
       sprintf slashw,"/W=(%g,%g,%g,%g)",left/V_right,top/V_bottom,right/V_right,bottom/V_bottom

       String wName
       Prompt wName,"Graph or table to insert",popup, WinList("*", ";","WIN:3")
       DoPrompt "pick a window",wName
       if( V_Flag )
               return 0
       endif

       String rm= WinRecreation(wName,0)
       Variable swpos= StrSearch(rm,"/W",0)
       Variable swend= StrSearch(rm,")",swpos)

       rm[swpos,swend]="/HOST=#"+slashw

       // here we try to insert a return before stuff that doesn't apply to the inset gets executed
       Variable i,quitpos= -1
       String quitstrs= "ShowInfo;ShowTools;ControlBar;NewPanel"
       for(i=0;;i+=1)
               String quitstr= StringFromList(i,quitstrs)
               if( strlen(quitstr) == 0 )
                       break
               endif
               quitpos=  StrSearch(rm,quitstr,0)
               if( quitpos != -1 )
                       break;
               endif
       endfor
       if( quitpos != -1 )
               rm[quitpos]= "return;"
       endif
       Execute rm
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function IN2G_ConvertQtoD(Qval,wavelength)	//D is in A, Q in A^-1
	variable Qval,wavelength
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	return 2*pi/Qval
end
Function IN2G_ConvertDtoQ(Dval,wavelength)		//D is in A, Q in A^-1
	variable Dval,wavelength
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	return 2*pi/Dval
end
Function IN2G_ConvertTTHtoQ(TTH,wavelength)		//TTH is in degrees, Q in A^-1	
	variable TTH,wavelength
	//q = 4pi sin(theta)/lambda
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	return 4*pi*sin(TTH*pi/360)/wavelength
end
Function IN2G_ConvertQtoTTH(Qval,wavelength)		//TTH is in degrees, Q in A^-1
	variable Qval,wavelength
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	return 114.592 * asin(Qval* wavelength / (4*pi))
end
Function IN2G_ConvertDtoTTH(Dval,wavelength)		//D is in A, TTH is degrees
	variable Dval,wavelength
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	return 114.592 * asin((2 * pi / Dval)* wavelength / (4*pi))
end
Function IN2G_ConvertTTHtoD(TTH,wavelength)		//TTH is in degrees, D in A
	variable TTH,wavelength
	//q = 4pi sin(theta)/lambda
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	return wavelength/(2*sin(TTH*pi/360))
end
//*****************************************************************************************************************
//*************************************************************************************************************************************

Function/T IN2G_num2StrFull(val)
	Variable val
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable i = IN2G_placesOfPrecision(val)
	Variable absVal = abs(val)
	i = (absVal>=10 && absVal<1e6) ? max(i,1+floor(log(absVal))) : i
	String str, fmt
	sprintf fmt, "%%.%dg",i
	sprintf str,fmt,val
	return str
End

//*****************************************************************************************************************
//*************************************************************************************************************************************
static Function IN2G_placesOfPrecision(a)	// number of significant figures in a number (at most 16)
	Variable a
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	a = IN2G_roundSignificant(abs(a),17)
	Variable i
	for (i=1;i<18;i+=1)
		if (abs(a-IN2G_roundSignificant(a,i))/a<1e-15)
			break
		endif
	endfor
	return i
End

//*****************************************************************************************************************
//*************************************************************************************************************************************

ThreadSafe Function/T IN2G_XMLtagContents(xmltag,buf,[occurance,start])
	String xmltag
	String buf
	Variable occurance									// use 0 for first occurance, 1 for second, ...
	Variable &start										// offset in buf, start searching at buf[start], new start is returned
																// both occurance and start may be used together, but usually you only want to use one of them
	occurance = ParamIsDefault(occurance) ? 0 : occurance
	Variable startLocal = ParamIsDefault(start) ? 0 : start
	startLocal = numtype(startLocal) || startLocal<1 ? 0 : round(startLocal)

	Variable i0,i1
	if (startLocal>0)
		i0 = IN2G_startOfxmltag(xmltag,buf[startLocal,Inf],occurance) + startLocal
	else
		i0 = IN2G_startOfxmltag(xmltag,buf,occurance)
	endif
	if (i0<0)
		return ""
	endif
	i0 = strsearch(buf,">",i0)						// character after '>' in intro
	if (i0<0)												// this is an ERROR
		return ""
	endif
	i0 += 1													// start of contents

	i1 = strsearch(buf,"</"+xmltag+">",i0)-1	// character just before closing '<tag>'
	startLocal = strsearch(buf,">",i1)+1			// character just after closing '<tag>'

	if (i1<i0 || i1<0)
		if (!ParamIsDefault(start))
			start = -1
		endif
		return ""
	endif

	if (!ParamIsDefault(start))
		start = startLocal
	endif

	return buf[i0,i1]
End

//*****************************************************************************************************************
//*************************************************************************************************************************************
Strconstant ListOfPackageNames ="Irena;Nika;Indra;"
Strconstant WebAddressForConfFile ="https://raw.githubusercontent.com/jilavsky/SAXS_IgorCode/master/"
Strconstant NameOfConfFile ="IgorInstallerConfig.xml"
Strconstant NameOfUpdateMessageFile ="UpdateMessage.ifn"


Function IN2G_CheckForNewVersion(WhichPackage)
	string WhichPackage
	
	variable NewVerNumber 
	string FileContent, CurrentReleaseName
	Make/T/Free/N=0 ListOfReleases
	
	string ConfigFileURL=WebAddressForConfFile+NameOfConfFile
	URLRequest/Z/TIME=5 url=ConfigFileURL
	if (V_Flag != 0)
		print "Could not get configuration file from server."
		NewVerNumber = NaN
		return NewVerNumber
	endif
	FileContent =  S_serverResponse
	FileContent=IN2G_XMLremoveComments(FileContent)		//get rid of comments, confuse rest of the code... 
	string InstallerText=IN2G_XMLtagContents("IgorInstaller",FileContent)	//if nothing, wrong format
	if(strlen(InstallerText)<10)	//no real content
		print "Bad content of file with configuration."
		NewVerNumber = NaN
		return NewVerNumber
	endif
	CurrentReleaseName = IN2G_GetCurrentRelease(InstallerText)
	IN2G_ListReleases(FileContent, ListOfReleases)
	variable i, indx
	For(i=0;i<DimSize(ListOfReleases,0);i+=1)
		if(StringMatch(ListOfReleases[i][0],CurrentReleaseName))
			indx=i
			break
		endif
	endfor
	//print ListOfReleases[indx][2]
	NewVerNumber = NumberByKey(WhichPackage, ListOfReleases[indx][2], "=", ";")
	return NewVerNumber
end

//  ======================================================================================  //
//  ======================================================================================  //

Function IN2G_GetAndDisplayUpdateMessage()
		//checks for update message and if available, gets it and presents to user. 
	DoWIndow MessageFromAuthor
	if(V_Flag)		//message already exists...
		return 0
	endif
			string FileContent
	string ConfigFileURL=WebAddressForConfFile+NameOfUpdateMessageFile
	URLRequest/Z/TIME=2 url=ConfigFileURL
	if (V_Flag != 0)
		print "Could not get Update message file from server."
		return 0
	endif
	FileContent =  S_serverResponse
	variable refNum
	NewPath/O/C/Q TempUserUpdateMessage, SpecialDirPath("Temporary",0,0,0)
	Open/P=TempUserUpdateMessage  refNum as NameOfUpdateMessageFile
	FBinWrite refNum, FileContent
	Close refNum
	OpenNotebook/k=1/N=MessageFromAuthor/P=TempUserUpdateMessage/Z NameOfUpdateMessageFile
   return 1
end
//  ======================================================================================  //
//  ======================================================================================  //
Function/T IN2G_ListReleases(str, Releasetw)
	string str
	wave/T Releasetw
	
	Redimension/N=(0,3) Releasetw
	variable rel_i, beta_i
	rel_i = 0
	string InstallerConfigStr, ListOfReleases
	InstallerConfigStr = IN2G_XMLtagContents("InstallerConfig",str)
	ListOfReleases = IN2G_XMLNodeList(InstallerConfigStr)		//all nodes on this level
	ListOfReleases = GrepList(ListOfReleases, "release")		//just the ones called release
	string ReleaseAttribs, ReleaseStr, ListOfTags, TagList, Curtag
	variable i, j
	for(i=0;i<ItemsInList(ListOfReleases);i+=1)
		ReleaseAttribs = IN2G_XMLattibutes2KeyList("release",InstallerConfigStr,occurance=i)
		ReleaseStr = IN2G_XMLtagContents("release",InstallerConfigStr,occurance=i)
		ListOfTags = IN2G_XMLNodeList(ReleaseStr)
		TagList=IN2G_ReadReleaseContent(ReleaseStr)
		rel_i+=1
		redimension/N=(rel_i,3) Releasetw
		Releasetw[rel_i-1][0]=StringByKey("name", ReleaseAttribs,"=")
		if(Stringmatch(StringByKey("beta", ReleaseAttribs,"="),"true"))
			Releasetw[rel_i-1][1]= "beta"
		else
			Releasetw[rel_i-1][1]= "normal"
		endif 
		Releasetw[rel_i-1][2]=TagList
	endfor
end
//**************************************************************** 
Function/T IN2G_ReadReleaseContent(Str)
	string Str
		
	string Content=""
	variable i, j
	string tempStr, tmpList
	string ListOfTags=IN2G_XMLNodeList(Str)
	string ListOfPackages, ListOfOtherStuff
	ListOfOtherStuff = GrepList(ListOfTags, "Package",1)
	ListOfPackages = GrepList(ListOfTags,"Package")
	For(i=0;i<ItemsInList(ListOfPackages);i+=1)
		tempStr=IN2G_XMLtagContents(stringFromList(i,ListOfPackages),Str, occurance=i)
		Content+=IN2G_ReadPackageContent(tempStr)
	endfor	

	For(i=0;i<ItemsInList(ListOfOtherStuff);i+=1)
		tempStr=IN2G_XMLtagContents(stringFromList(i,ListOfOtherStuff),Str)
		Content+=StringFromList(i,ListOfOtherStuff)+"="+tempStr+";"
	endfor	
	return Content
end
//**************************************************************** 
Function/T IN2G_ReadPackageContent(Str)
	string Str
		
	string Content=""
	variable i, j
	string tempStr, tmpList, PackageName
	string ListOfTags=IN2G_XMLNodeList(Str)
	string ListOfOtherStuff=RemoveFromList("name", ListOfTags)
	ListOfOtherStuff=RemoveFromList("version", ListOfOtherStuff)
	PackageName=IN2G_XMLtagContents("name",Str)
	Content+=PackageName+"="+IN2G_XMLtagContents("version",Str)+";"

	For(i=0;i<ItemsInList(ListOfOtherStuff);i+=1)
		tempStr=IN2G_XMLtagContents(stringFromList(i,ListOfOtherStuff),Str)
		Content+=PackageName+"_"+StringFromList(i,ListOfOtherStuff)+"="+tempStr+";"
	endfor	
	return Content
end


//*****************************************************************************************************************
//*************************************************************************************************************************************

ThreadSafe Function IN2G_startOfxmltag(xmltag,buf,occurance)	// returns the index into buf pointing to the start of xmltag
	String xmltag, buf
	Variable occurance									// use 0 for first occurance, 1 for second, ...

	Variable i0,i1, i, start
	for (i=0,i0=0;i<=occurance;i+=1)
		start = i0
		i0 = strsearch(buf,"<"+xmltag+" ",start)	// find start of a tag with attributes
		i1 = strsearch(buf,"<"+xmltag+">",start)	// find start of a tag without attributes
		i0 = i0<0 ? Inf : i0
		i1 = i1<0 ? Inf : i1
		i0 = min(i0,i1)
		i0 += (i<occurance) ? strlen(xmltag)+2 : 0	// for more, move starting point forward
	endfor
	i0 = numtype(i0) || i0<0 ? -1 : i0
	return i0
End
//  ======================================================================================  //
Function/T IN2G_XMLattibutes2KeyList(xmltag,buf,[occurance,start])// return a list with all of the attribute value pairs for xmltag
	String xmltag											// name of tag to find
	String buf												// buf containing xml
	Variable occurance									// use 0 for first occurance, 1 for second, ...
	Variable &start										// offset in buf, start searching at buf[start], new start is returned
																// both occurance and start may be used together, but usually you only want to use one of them
	occurance = ParamIsDefault(occurance) ? 0 : occurance
	Variable startLocal = ParamIsDefault(start) ? 0 : start
	startLocal = numtype(startLocal) || startLocal<1 ? 0 : round(startLocal)

	Variable i0,i1
	if (startLocal>0)
		i0 = IN2G_startOfxmltag(xmltag,buf[startLocal,Inf],occurance) + startLocal
	else
		i0 = IN2G_startOfxmltag(xmltag,buf,occurance)
	endif
	if (i0<0)
		return ""
	endif
	i0 += strlen(xmltag)+2								// start of attributes
	i1 = strsearch(buf,">",i0)-1						// end of attributes
	String key, value, keyVals=""

	if (i1 < i0)											// this is an ERROR
		startLocal = -1
	else
		startLocal = i1 + 2								// character just after closing '>'
		// parse buf into key=value pairs
		buf = buf[i0,i1]
		buf = ReplaceString("\t",buf," ")
		buf = ReplaceString("\r",buf," ")
		buf = ReplaceString("\n",buf," ")
		buf = IN2G_TrimFrontBackWhiteSpace(buf)
		i0 = 0
		do
			i1 = strsearch(buf,"=",i0,0)
			key = IN2G_TrimFrontBackWhiteSpace(buf[i0,i1-1])
			i0 = strsearch(buf,"\"",i1,0)+1				// character after the first double quote around value
			i1 = strsearch(buf,"\"",i0,0)-1				// character before the second double quote around value
			value = buf[i0,i1]
			if (strlen(key)>0)
				keyVals = ReplaceStringByKey(key,keyVals,value,"=")
			endif
			i0 = strsearch(buf," ",i1,0)					// find space separator, set up for next key="val" pair
		while(i0>0 && strlen(key))
	endif

	if (!ParamIsDefault(start))							// set start if it was passed
		start = startLocal
	endif
	return keyVals
End
//**************************************************************** 
ThreadSafe Function/T IN2G_TrimFrontBackWhiteSpace(str)
	String str
	str = IN2G_TrimLeadingWhiteSpace(str)
	str = IN2G_TrimTrailingWhiteSpace(str)
	return str
End
ThreadSafe Function/T IN2G_TrimLeadingWhiteSpace(str)
	String str
	Variable i, N=strlen(str)
	for (i=0;char2num(str[i])<=32 && i<N;i+=1)	// find first non-white space
	endfor
	return str[i,Inf]
End
ThreadSafe Function/T IN2G_TrimTrailingWhiteSpace(str)
	String str
	Variable i
	for (i=strlen(str)-1; char2num(str[i])<=32 && i>=0; i-=1)	// find last non-white space
	endfor
	return str[0,i]
End

//**************************************************************** 
ThreadSafe Function/T IN2G_XMLNodeList(buf)			// returns a list of node names at top most level in buf
	String buf
	String name,nodes=""
	Variable i0=0, i1,i2
	do
		i0 = strsearch(buf,"<",i0)					// find start of a tag
		if (i0<0)
			break
		endif
		i1 = strsearch(buf," ",i0)					// find end of tag name using i1 or i2, end will be in i1
		i1 = i1<0 ? Inf : i1
		i2 = strsearch(buf,">",i0)
		i2 = i2<0 ? Inf : i2
		i1 = min(i1,i2)
		if (numtype(i1) || (i1-i0-1)<1)
			break
		endif
		name = ReplaceString(";",buf[i0+1,i1-1],"_")// name cannot contain semi-colons
		nodes += name+";"

		i2 = strsearch(buf,"</"+name+">",i0)		// find the closer for this tag, check for '</name>'
		if (i2<0)
			i0 = strsearch(buf,">",i1+1)				// no '</name>', just a simple node
		else
			i0 = i2 + strlen(name) + 3				// first character after '</name>'
		endif
	while(i0>0)
	return nodes
End
//**************************************************************** 
Function/T IN2G_GetCurrentRelease(str)
	string str
	string VersionCheckStr
	VersionCheckStr = IN2G_XMLtagContents("VersionCheck",str)
	return IN2G_XMLtagContents("current_release",VersionCheckStr)
end

//**************************************************************** 
ThreadSafe Function/T IN2G_XMLremoveComments(str)	// remove all xml comments from str
	String str
	Variable i0,i1
	do
		i0 = strsearch(str,"<!--",0)					// start of a comment
		i1 = strsearch(str,"-->",0)					// end of a comment
		if (i0<0 || i1<=i0)
			break
		endif
		str[i0,i1+2] = ""									// snip out comment
	while(1)
	return str
End
//

//*****************************************************************************************************************
//*************************************************************************************************************************************
// Calculates the experiment size and returns it in bytes
// Last Modified 2012/07/09 by Jamie Boyd
Function IN2G_EstimateFolderSize (dataFolder)
	string dataFolder
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable expSize
	// this folder
	variable iObj, nObjs = CountObjects(dataFolder, 1), aWaveType
	for (iObj =0; iObj < nObjs; iObj +=1, expSize += 320)
		WAVE aWave = $dataFolder + GetIndexedObjName(dataFolder, 1, iObj )
		aWaveType = WaveType (aWave)
		if ((aWaveType & 0x2) || (aWaveType & 0x20)) // 32 bit int or 32 bit float
			expSize += 4 * NumPnts (aWave) * SelectNumber((aWaveType & 0x1) , 1,2)
		elseif(aWaveType & 0x4) // 64 bit float
			expSize += 8 * NumPnts (aWave) * SelectNumber((aWaveType & 0x1) , 1,2)
		elseif(aWaveType & 0x8) // 8 bit int
			expSize += NumPnts (aWave) * SelectNumber((aWaveType & 0x1) , 1,2)
		elseif(aWaveType & 0x10) // 16 bit int
			expSize += 2 * NumPnts (aWave) * SelectNumber((aWaveType & 0x1) ,1,2)
		endif
	endfor
	// subfolders
	nObjs = CountObjects(dataFolder, 4)
	for (iObj =0; iObj < nObjs; iObj += 1)
		expSize += IN2G_EstimateFolderSize ( dataFolder + possiblyquoteName(GetIndexedObjName (dataFolder, 4, iObj)) + ":")
	endfor
	return expSize
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IN2G_CheckForSlitSmearedRange(slitSmearedData,Qmax, SlitLength,[userMessage])
	variable slitSmearedData,Qmax, SlitLength
	string userMessage
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable isUM= ParamIsDefault(userMessage)
	
	if(slitSmearedData)
		if(Qmax<3* SlitLength)
			if(isUM)
				abort "For slit smeared data you need to model/fit to Qmax at least 3* Slit length" 
			else
				abort "For slit smeared data you need to model/fit to Qmax at least 3* Slit length."+userMessage 
			endif
		endif
	endif

end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//This routine will rebin data on log scale. It will produce new Wx and Wy with new NumberOfPoints
//If MinStep > 0 it will try to set the values so the minimum step on log scale is MinStep
//optional Wsdev is standard deviation for each Wy value, it will be propagated through - sum(sdev^2)/numpnts in each bin. 
//optional Wxwidth will generate width of each new bin in x. NOTE: the edge is half linear distance between the two points, no log  
//skewing is done for edges. Therefore the width is really half of the distance between p-1 and p+1 points.  
//optional W1-5 will be averaged for each bin , so this is way to propagate other data one may need to. 
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IN2G_RebinLogData(Wx,Wy,NumberOfPoints,MinStep,[Wsdev,Wxsdev, Wxwidth,W1, W2, W3, W4, W5])
		Wave Wx, Wy
		Variable NumberOfPoints, MinStep
		Wave Wsdev,Wxsdev
		Wave Wxwidth
		Wave W1, W2, W3, W4, W5
		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		variable CalcSdev, CalcWidth, CalcW1, CalcW2, CalcW3, CalcW4, CalcW5, CalcXSdev
		CalcSdev = ParamIsDefault(Wsdev) ?  0 : 1
		CalcXSdev = ParamIsDefault(Wxsdev) ?  0 : 1
		CalcWidth = ParamIsDefault(Wxwidth) ?  0 : 1
		CalcW1 = ParamIsDefault(W1) ?  0 : 1
		CalcW2 = ParamIsDefault(W2) ?  0 : 1
		CalcW3 = ParamIsDefault(W3) ?  0 : 1
		CalcW4 = ParamIsDefault(W4) ?  0 : 1
		CalcW5 = ParamIsDefault(W5) ?  0 : 1
		
		variable OldNumPnts=numpnts(Wx)
		if(3*NumberOfPoints>OldNumPnts)
			print "User requested rebinning of data, but old number of points is less than 3*requested number of points, no rebinning done"
			return 0
		endif
		variable StartX, EndX, iii, isGrowing, CorrectStart, logStartX, logEndX
		if(Wx[0]<=0)				//log scale cannot start at 0, so let's pick something close to what user wanted...  
			Wx[0] = Wx[1]/2
		endif
		CorrectStart = Wx[0]
		if(MinStep>0)
			StartX = IN2G_FindCorrectLogScaleStart(Wx[0],Wx[numpnts(Wx)-1],NumberOfPoints,MinStep)
		else
			StartX = CorrectStart
		endif
		Endx = StartX +abs(Wx[numpnts(Wx)-1] - Wx[0])
		isGrowing = (Wx[0] < Wx[numpnts(Wx)-1]) ? 1 : 0
		make/O/D/FREE/N=(NumberOfPoints) tempNewLogDist, tempNewLogDistBinWidth
		logstartX=log(startX)
		logendX=log(endX)
		tempNewLogDist = logstartX + p*(logendX-logstartX)/numpnts(tempNewLogDist)
		tempNewLogDist = 10^(tempNewLogDist)
		startX = tempNewLogDist[0]
		tempNewLogDist += CorrectStart - StartX
	
 		tempNewLogDistBinWidth[1,numpnts(tempNewLogDist)-2] = tempNewLogDist[p+1] - tempNewLogDist[p-1]
 		tempNewLogDistBinWidth[0] = tempNewLogDistBinWidth[1]
 		tempNewLogDistBinWidth[numpnts(tempNewLogDist)-1] = tempNewLogDistBinWidth[numpnts(tempNewLogDist)-2]
		make/O/D/FREE/N=(NumberOfPoints) Rebinned_WvX, Rebinned_WvY, Rebinned_Wv1, Rebinned_Wv2,Rebinned_Wv3, Rebinned_Wv4, Rebinned_Wv5, Rebinned_Wsdev, Rebinned_Wxsdev
		Rebinned_WvX=0
		Rebinned_WvY=0
		Rebinned_Wv1=0	
		Rebinned_Wv2=0	
		Rebinned_Wv3=0	
		Rebinned_Wv4=0	
		Rebinned_Wv5=0	
		Rebinned_Wsdev=0	
		Rebinned_Wxsdev=0	

		variable i, j
		variable cntPoints, BinHighEdge
		//variable i will be from 0 to number of new points, moving through destination waves
		j=0		//this variable goes through data to be reduced, therefore it goes from 0 to numpnts(Wx)
		For(i=0;i<NumberOfPoints;i+=1)
			cntPoints=0
			BinHighEdge = tempNewLogDist[i]+tempNewLogDistBinWidth[i]/2
			if(isGrowing)
				Do
					Rebinned_WvX[i] 	+= Wx[j]
					Rebinned_WvY[i]	+= Wy[j]
					if(CalcW1)
						Rebinned_Wv1[i]	+= W1[j]
					endif
					if(CalcW2)
						Rebinned_Wv2[i]	+= W2[j]
					endif
					if(CalcW3)
						Rebinned_Wv3[i]	+= W3[j]
					endif
					if(CalcW4)
						Rebinned_Wv4[i] 	+= W4[j]
					endif
					if(CalcW5)
						Rebinned_Wv5[i] 	+= W5[j]
					endif
					if(CalcSdev)
						Rebinned_Wsdev[i] += Wsdev[j]^2
					endif
					if(CalcXSdev)
						Rebinned_WXsdev[i] += WXsdev[j]^2
					endif
					cntPoints+=1
					j+=1
				While(Wx[j-1]<BinHighEdge && j<OldNumPnts)
			else
				Do
					Rebinned_WvX[i] 	+= Wx[j]
					Rebinned_WvY[i]	+= Wy[j]
					if(CalcW1)
						Rebinned_Wv1[i]	+= W1[j]
					endif
					if(CalcW2)
						Rebinned_Wv2[i]	+= W2[j]
					endif
					if(CalcW3)
						Rebinned_Wv3[i]	+= W3[j]
					endif
					if(CalcW4)
						Rebinned_Wv4[i] 	+= W4[j]
					endif
					if(CalcW5)
						Rebinned_Wv5[i] 	+= W5[j]
					endif
					if(CalcSdev)
						Rebinned_Wsdev[i] += Wsdev[j]^2
					endif
					if(CalcXSdev)
						Rebinned_WXsdev[i] += WXsdev[j]^2
					endif
					cntPoints+=1
					j+=1
				While((Wx[j-1]>BinHighEdge) && (j<OldNumPnts))
			endif
			Rebinned_WvX[i]/=cntPoints	 
			Rebinned_WvY[i]/=cntPoints
			if(CalcW1)
				Rebinned_Wv1[i]/=cntPoints
			endif
			if(CalcW2)
				Rebinned_Wv2[i]/=cntPoints
			endif
			if(CalcW3)
				Rebinned_Wv3[i]/=cntPoints
			endif
			if(CalcW4)
				Rebinned_Wv4[i]/=cntPoints
			endif
			if(CalcW5)
				Rebinned_Wv5[i]/=cntPoints
			endif
			if(CalcSdev)
				Rebinned_Wsdev[i]=sqrt(Rebinned_Wsdev[i])/(cntPoints)	 
			endif
			if(CalcXSdev)
				Rebinned_Wxsdev[i]=sqrt(Rebinned_Wxsdev[i])/(cntPoints)	 
			endif
		endfor

	Redimension/N=(numpnts(Rebinned_WvX))/D Wx, Wy
	Wx=Rebinned_WvX
	Wy=Rebinned_WvY

	if(CalcW1)
		Redimension/N=(numpnts(Rebinned_WvX))/D W1
		W1=Rebinned_Wv1
	endif
	if(CalcW2)
		Redimension/N=(numpnts(Rebinned_WvX))/D W2
		W2=Rebinned_Wv2
	endif
	if(CalcW3)
		Redimension/N=(numpnts(Rebinned_WvX))/D W3
		W3=Rebinned_Wv3
	endif
	if(CalcW4)
		Redimension/N=(numpnts(Rebinned_WvX))/D W4
		W4=Rebinned_Wv4
	endif
	if(CalcW5)
		Redimension/N=(numpnts(Rebinned_WvX))/D W5
		W5=Rebinned_Wv5
	endif

	if(CalcSdev)
		Redimension/N=(numpnts(Rebinned_WvX))/D Wsdev
		Wsdev = Rebinned_Wsdev
	endif
	if(CalcxSdev)
		Redimension/N=(numpnts(Rebinned_WvX))/D Wxsdev
		Wxsdev = Rebinned_Wxsdev
	endif
	
	if(CalcWidth)
		Redimension/N=(numpnts(Rebinned_WvX))/D Wxwidth
		Wxwidth = tempNewLogDistBinWidth
	endif
end		
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IN2G_FindCorrectLogScaleStart(StartValue,EndValue,NumPoints,MinStep)
	variable StartValue,EndValue,NumPoints,MinStep
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Make/Free/N=3 w
	w={EndValue-StartValue, NumPoints,MinStep}
	Optimize /H=100/L=1e-5/I=100/T=(MinStep/50)/Q myFindStartValueFunc, w
	//Test this works?
//	variable startX=log(V_minloc)
//	variable endX=log(V_minloc+range)
//	variable LastMinStep = 10^(startX + (endX-startX)/NumPoints) - 10^(startX)
//	print LastMinStep
	return V_minloc
end
//**********************************************************************************************************
//**********************************************************************************************************
Function myFindStartValueFunc(w,x1)
	Wave w		//this is {totalRange, NumSteps,MinStep}
	Variable x1	//this is startValue where we need to start with log stepping...
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable LastMinStep = 10^(log(X1) + (log(X1+w[0])-log(X1))/w[1]) - 10^(log(X1))
	return abs(LastMinStep-w[2])
End
//**********************************************************************************************************
//**********************************************************************************************************

//Function IN2G_FindCorrectLogScaleStart(StartValue,EndValue,NumPoints,MinStep)
//	variable StartValue,EndValue,NumPoints,MinStep
//	//find Start/end values for log scale so the step betwen first and second point is MinStep
//	variable TotalValueDiff=abs(EndValue-StartValue)
//	variable startX, endX, LastMinStep, LastStartValue, calcStep
//	variable difer, NumIterations
//	if(StartValue<=1e-8)
//		StartValue=0.01
//	endif
//	startX=log(StartValue)
//	endX=log(StartValue+TotalValueDiff)
//	LastMinStep = 10^(startX + (endX-startX)/NumPoints) - 10^(startX)
//	LastStartValue = StartValue
//	NumIterations = 0
//	if(LastMinStep>MinStep)		//need to increase the start value
//		LastStartValue-=TotalValueDiff/(2*NumPoints)
//		Do
//			LastStartValue+=TotalValueDiff/(2*NumPoints)
//			startX = log(LastStartValue)
//			endX = log(LastStartValue+TotalValueDiff)
//			calcStep= 10^(startX + (endX-startX)/NumPoints) - 10^(startX)
//			NumIterations+=1
//		while((calcStep<MinStep) && (NumIterations<500))
//		if(NumIterations>=500)
//			abort "Cannot find correct minstep for log distribution" 
//		endif
//		return LastStartValue
//	else								//need to decrease start value
//		LastStartValue+=TotalValueDiff/(2*NumPoints)
//		Do
//			LastStartValue-=TotalValueDiff/(2*NumPoints)
//			startX = log(LastStartValue)
//			endX = log(LastStartValue+TotalValueDiff)
//			calcStep = 10^(startX + (endX-startX)/NumPoints) - 10^(startX)
//		while((calcStep>MinStep)&&(LastStartValue>0) && (NumIterations<500))
//		if(NumIterations>=500)
//			abort "Cannot find correct minstep for log distribution" 
//		endif
//		return LastStartValue
//	endif
//end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//Function IN2G_FindCorrectStart(StartValue,EndValue,NumPoints,MinStep)
//	variable StartValue,EndValue,NumPoints,MinStep
//	
//	variable AngleDiff=abs(EndValue-StartValue)
//	variable startX, endX, LastMinStep, LastStartAngle, calcStep
//	variable difer		//=10^(startX + (endX-startX)/NumPoints) - 10^(startX)
//	if(StartValue<=0.01)
//		StartValue=1
//	endif
//	startX=log(StartValue)
//	endX=log(StartValue+AngleDiff)
//	LastMinStep = 10^(startX + (endX-startX)/NumPoints) - 10^(startX)
//	LastStartAngle = StartValue
//	if(LastMinStep<MinStep)		//need to decrease the start angle
//		Do
//			LastStartAngle+=0.1
//			startX = log(LastStartAngle)
//			endX = log(LastStartAngle+AngleDiff)
//			calcStep= 10^(startX + (endX-startX)/NumPoints) - 10^(startX)
//		while((calcStep<MinStep)&&(LastStartAngle<300))
//		return LastStartAngle
//	else			//need to increase start angle
//		Do
//			LastStartAngle-=LastStartAngle/20
//			startX = log(LastStartAngle)
//			endX = log(LastStartAngle+AngleDiff)
//			calcStep = 10^(startX + (endX-startX)/NumPoints) - 10^(startX)
//		while((calcStep>MinStep)&&(LastStartAngle>0))
//		return LastStartAngle
//	endif
//end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//FUNCTIONS AND PROCEDURES FOR USE IN ALL INDRA 2 MACROS	
Function ING2_AddScrollControl()
	//string WindowName
	getWindow kwTopWin, wsizeDC
	//CheckBox ScrollWidown title="\\W614",proc=IN2G_ScrollWindowCheckProc, pos={V_right-75,2}
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Button ScrollButtonUp title="\\W617",pos={(V_right-V_left)-17,2},size={15,15}, proc=IN2G_ScrollButtonProc
	Button ScrollButtonDown title="\\W623",pos={(V_right-V_left)-17,17},size={15,15}, proc=IN2G_ScrollButtonProc
end
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IN2G_MoveControlsPerRequest(WIndowName, HowMuch)
	variable HowMuch
	string WIndowName			
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String controls = ControlNameList(WIndowName)
	controls = RemoveFromList("ScrollButtonDown", controls )
	controls = RemoveFromList("ScrollButtonUp", controls )
	ModifyControlList controls, win=$WIndowName, pos+={0,HowMuch}	
	//now have to deal with special cases, in the case of Data manipulation we have two subwindows
//	if(stringmatch(WindowName,"IR1D_DataManipulationPanel"))
//		variable OriginalHeight, NewTop, NewBottom, NewTop2, NewBottom2
//		GetWindow IR1D_DataManipulationPanel#Top wsize
//		OriginalHeight = V_Bottom-V_top
//		NewTop = V_top+HowMuch
//		NewBottom = V_bottom+HowMuch
////		if(NewTop<0)
////			NewTop=0
////			NewBottom = OriginalHeight
////		endif
//		MoveSubwindow/W=IR1D_DataManipulationPanel#Top fnum=(V_left, NewTop, V_right, NewBottom )
//		//GetWindow IR1D_DataManipulationPanel#Bot wsize
//		NewTop2 = NewTop+OriginalHeight+3
//		NewBottom2 = NewBottom+OriginalHeight+3
//		MoveSubwindow/W=IR1D_DataManipulationPanel#Bot fnum=(V_left, NewTop2, V_right, NewBottom2 )
//	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2G_FindNewTextElements(w1,w2,reswave)
	Wave/t w1,w2,reswave
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//comment, up to 1e4 points seems reasonably fast (0.2sec), then gets really slow, 1e5 is 14 seconds. 
	make/n=(numpnts(w1) + numpnts(w2))/free/t total
	total[] = w1[p]
	total[numpnts(w1), numpnts(total)-1] = w2[p - numpnts(w1)]

	sort total, total
	make/n=(numpnts(total))/I/free sorter
	redimension/n=(numpnts(total) + 1) total
	sorter = selectnumber(stringmatch(total[p], total[p+1]), 0, 1)
	redimension/n=(numpnts(total) -1) total
	duplicate/free sorter, sorter2

	sorter2 = sorter[p -1] == 1? 1:sorter(p)

	sort sorter2, sorter2, total
	findvalue/I=1/z sorter2
	deletepoints V_value, numpnts(total), total
	duplicate/O/T total, reswave

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function/T IN2G_ReturnExistingWaveName(FolderNm,WaveMatchStr)
	string FolderNm,WaveMatchStr
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if(!DataFolderExists(FolderNm))
		return ""
	endif
	string OldDf=GetDataFolder(1)
	setDataFolder FolderNm
	string ListOfWvs=IN2G_ConvertDataDirToList(DataFolderDir(2))
	setDataFolder OldDf
	string WaveNmFound=""
	variable i
	For(i=0;i<itemsInList(ListOfWvs);i+=1)
		if(stringmatch(StringFromList(i,ListOfWvs),WaveMatchStr))
			WaveNmFound = StringFromList(i,ListOfWvs)
			return possiblyquotename(WaveNmFound)
		endif
	endfor
	return WaveNmFound
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function/T IN2G_ReturnExistingWaveNameGrep(FolderNm,WaveMatchStr)
	string FolderNm,WaveMatchStr
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if(!DataFolderExists(FolderNm))
		return ""
	endif
	string OldDf=GetDataFolder(1)
	setDataFolder FolderNm
	string ListOfWvs=IN2G_ConvertDataDirToList(DataFolderDir(2))
	setDataFolder OldDf
	string WaveNmFound=""
	variable i
	For(i=0;i<itemsInList(ListOfWvs);i+=1)
		if(grepString(StringFromList(i,ListOfWvs),"(?i)"+WaveMatchStr))
			WaveNmFound = StringFromList(i,ListOfWvs)
			return WaveNmFound
		endif
	endfor
	return WaveNmFound
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IN2G_CreateAndSetArbFolder(folderPathStr)
	string folderPathStr
	//takes folder path string, if it starts with root: cretaes all folders as necessary, if not then creates folder from current location.
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i, istart=0
	if(stringmatch(stringFromList(0,folderPathStr,":"),"root"))
		setDataFolder root:
		istart=1
	endif
	For(i=istart;i<ItemsInList(folderPathStr,":");i+=1)
		NewDataFolder/O/S $(IN2G_RemoveExtraQuote(StringFromList(i,folderPathStr,":"),1,1))
	endfor
	
end	
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2G_printvec(w)		// print a vector to screen
	Wave w
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String name=NameOfWave(w)
	Wave/T tw=$GetWavesDataFolder(w,2)
	Wave/C cw=$GetWavesDataFolder(w,2)
	Variable waveIsComplex = WaveType(w) %& 0x01
	Variable numeric = (WaveType(w)!=0)
	Variable i=0, n
	n = numpnts(w)
	printf "%s = {", name
	do
		if (waveIsComplex)						// a complex wave
			printf "(%g, %g)", real(cw[i]),imag(cw[i])
		endif
		if (numeric %& (!waveIsComplex))		// a simple number wave
			printf "%g", w[i]
		endif
		if (!numeric)							// a text wave
			printf "'%s'", tw[i]
		endif
		if (i<(n-1))
			printf ",  "
		endif
		i += 1
	while (i<n)
	printf "}\r"
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2G_GenerateSASErrors(IntWave,ErrWave,Pts_avg,Pts_avg_multiplier, IntMultiplier,MultiplySqrt,Smooth_Points)
	wave IntWave,ErrWave
	variable Pts_avg,Pts_avg_multiplier, IntMultiplier,MultiplySqrt,Smooth_Points
	//this function will generate some kind of SAXS errors using many differnt methods... 
	// formula E = IntMultiplier * R + MultiplySqrt * sqrt(R)
	// E += Pts_avg_multiplier * abs(smooth(R over Pts_avg) - R)
	// min number of poitns is 3
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if (Pts_avg<3)
		Pts_avg=3
	endif
	redimension/D/N=(numpnts(IntWave)) ErrWave		//make sure erorr wave has right dimension..
	ErrWave = IntMultiplier * IntWave + MultiplySqrt * (sqrt(IntWave))
	if(Pts_avg_multiplier>0)
		Duplicate/O IntWave, tempErrors_Smooth
		smooth /E=3 Pts_avg, tempErrors_Smooth
		ErrWave += Pts_avg_multiplier * abs(tempErrors_Smooth - IntWave)
		Killwaves/Z tempErrors_Smooth
		//there are end effects here... As result the Pts_avg/2 from start and at end are wrong... replace with Pts_avg/2+1 point
		variable i, num2replace, NumPntsN
		NumPntsN = numpnts(IntWave)-1
		num2replace = floor(Pts_avg/2) 
		For (i=0;i<=(num2replace);i+=1)
			ErrWave[i] = ErrWave[num2replace+1]
			ErrWave[NumPntsN-i] = ErrWave[NumPntsN - (num2replace+1)]		
		endfor
	endif
	if(Smooth_Points>1)
		Smooth/E=3 /B Smooth_Points, ErrWave
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function/S IN2G_roundToUncertainity(val, uncert,N)		//returns properlly formated "Val +/- Uncert" string
	variable val, uncert,N
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	uncert = IN2G_roundSignificant(uncert,N)  		//this rounds uncert to N sig. digits
	variable decPlaces, allPlaces
	string tempStr, tmpExpStr
	variable tempVar, tmpExpNum
	if (uncert<1)		//only decimal places in uncertainity
		sprintf tempStr, "%g", uncert
		if(stringmatch(tempStr,"*e-*"))
			tmpExpStr = tempStr[strsearch(tempStr, "e-", 0),inf]
			tmpExpNum = str2num("1"+tmpExpStr)
			decPlaces = strlen(tempStr[0,strsearch(tempStr, "e-", 0)-1])-1
			val = IN2G_roundDecimalPlaces(val/tmpExpNum,decPlaces)
			val*=tmpExpNum	
		else
			decPlaces = strlen(tempStr)-2
			val = IN2G_roundDecimalPlaces(val,decPlaces)		
		endif
	elseif(uncert>=1)
		if((ceil(uncert)-uncert)==0)		//the rounded uncertinity is integer
			decPlaces=0
			tempVar = floor(log(uncert))
			val = 10^tempVar * round(val/(10^tempVar))
		else			//it has decimal places...
			sprintf tempStr, "%g", uncert		//all of the numbers
			tempVar = floor(log(floor(uncert)))+2 	//numbers before decimal point
			tempVar = strlen(tempStr) - tempVar
			val = IN2G_roundDecimalPlaces(val,tempVar)
			decPlaces=tempVar
		endif
	endif
	string ValStr, UncertStr
	if(val<1e6&&val>1e-4)
		sprintf ValStr, "%."+num2str(decPlaces)+"f" ,val
	else
		sprintf ValStr, "%g" ,val
	endif
	sprintf UncertStr, "%g" ,uncert
	return ValStr+" +/- "+UncertStr
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2G_roundSignificant(val,N)        // round val to N significant figures
        Variable val                    // input value to round
        Variable N                      // number of significant figures

			IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
        if (val==0 || numtype(val))
                return val
        endif
        Variable is,tens
        is = sign(val)
        val = abs(val)
        tens = 10^(N-floor(log(val))-1)
        return is*round(val*tens)/tens
End
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2G_roundDecimalPlaces(val,N)        // round val to N decimal places, if needed
        Variable val                    // input value to round
        Variable N                      // number of significant figures


			IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
        if (val==0 || numtype(val))
                return val
        endif
        Variable is,tens
        is = sign(val)
        val = abs(val)
        tens = floor(0.5+val*10^N)
        return is*tens/10^N
End


//*****************************************************************************************************************
//*****************************************************************************************************************

Function/T IN2G_FixWindowsPathAsNeed(PathString,DoubleSingleQuotes, EndingQuotes)
	string PathString
	variable DoubleSingleQuotes, EndingQuotes	//1 for single, 2 for double
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string Separator
	if(DoubleSingleQuotes==1)
		Separator="\\"
	else
		Separator="\\\\"
	endif
	variable i
	string tempCommand=StringFromList(0,PathString,":")+":"+Separator
		For (i=1;i<ItemsInList(PathString,":")-1;i+=1)
			tempCommand+=StringFromList(i,PathString,":")+Separator
		endfor
			tempCommand+=StringFromList(ItemsInList(PathString,":")-1,PathString,":")
		if(EndingQuotes)
			tempCommand+=Separator	
		endif
	return tempCommand
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function/S IN2G_ExtractFldrNmFromPntr(FullPointerToWaveVarStr)
	string FullPointerToWaveVarStr
	//returns only the folder part of full pointer to wave/string/variable returned by IN2G_FolderSelectPanel
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable numItems=ItemsInList(FullPointerToWaveVarStr,":")
	
	string tempStr=RemoveFromList(StringFromList(numItems-1,FullPointerToWaveVarStr,":"), FullPointerToWaveVarStr , ":")
	if(DataFolderExists(tempStr))
		return tempStr
	else
		return ""
	endif
end

////*****************************************************************************************************************
////*****************************************************************************************************************

Function IN2G_ColorTopGrphRainbow()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String topGraph=WinName(0,1)
	Variable traceIndex, numTraces
	Variable i, iRed, iBlue, iGreen, io, w, Red, Blue, Green,  ColorNorm
	if( strlen(topGraph) )
		numTraces =  ItemsInList(TraceNameList(topGraph,";",3))
		//print TraceNameList(topGraph,";",3)
		if (numTraces > 4)
		    variable r,g,b,scale
		    colortab2wave Rainbow
		    wave M_colors
			 For(i=0;i<numTraces;i+=1)
			        scale =  (numTraces-i)  / (numTraces-1) * dimsize(M_colors,0)
			        r = M_colors[scale][0]
			        g = M_colors[scale][1]
			        b = M_colors[scale][2]
			       ModifyGraph/Z/W=$(topGraph) rgb[i]=( r, g, b )
			 endfor
		else
			ModifyGraph/Z/W=$(topGraph) rgb[0]=(65535,0,0),rgb[1]=(0,0,65535),rgb[2]=(0,65535,0),rgb[3]=(0,0,0)
		endif
	endif
end
////*****************************************************************************************************************
////*****************************************************************************************************************

Function IN2G_VaryMarkersTopGrphRainbow(UseOpenSYmbols, SymbolSize, SameSymbol)
	variable UseOpenSYmbols, SymbolSize, SameSymbol

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String topGraph=WinName(0,1)
	Variable traceIndex, numTraces
	Variable i
	make/Free/N=10 ClosedSymb, OpenSymb
	ClosedSymb = {19,16,17, 23, 26, 29 ,18, 15, 14, 52,60}
	OpenSymb = {8, 5, 6, 22, 25, 28, 7, 4, 3, 56, 61}
	if(strlen(topGraph))
		numTraces =  ItemsInList(TraceNameList(topGraph,";",3))
		//print TraceNameList(topGraph,";",3)
		if(SameSymbol)
			ModifyGraph/W=$(topGraph) marker = 8, msize[i]=SymbolSize		
		else
			if (UseOpenSYmbols)
				For(i=0;i<numTraces;i+=1)
			   	    ModifyGraph/Z/W=$(topGraph) marker[i]=OpenSymb[i-10*floor(i/10)], msize[i]=SymbolSize
				endfor	
			else		//symbol set1
				For(i=0;i<numTraces;i+=1)
			   	    ModifyGraph/Z/W=$(topGraph) marker[i]=ClosedSymb[i-10*floor(i/10)], msize[i]=SymbolSize
				endfor
			endif
		endif
	endif
end
////*****************************************************************************************************************
////*****************************************************************************************************************

Function IN2G_VaryLinesTopGrphRainbow(LineThickness, varyLines)
	variable LineThickness, varyLines

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String topGraph=WinName(0,1)
	Variable traceIndex, numTraces
	Variable i
	if(strlen(topGraph))
		numTraces =  ItemsInList(TraceNameList(topGraph,";",3))
		//print TraceNameList(topGraph,";",3)
		if(varyLines)
			For(i=0;i<numTraces;i+=1)
		   	   ModifyGraph/Z/W=$(topGraph) lstyle[i]=i-18*floor(i/18), lsize[i]=LineThickness
			endfor	
		else
			ModifyGraph/W=$(topGraph) lstyle = 0 , lsize=0
		endif
	endif
end
////*****************************************************************************************************************
////*****************************************************************************************************************

Function IN2G_OffsetTopGrphTraces(LogXAxis, XOffset ,LogYAxis, YOffset)
	variable LogXAxis, XOffset ,LogYAxis, YOffset

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String topGraph=WinName(0,1)
	Variable traceIndex, numTraces
	Variable i
	if(strlen(topGraph))
		ModifyGraph/Z/W=$(topGraph) muloffset = {0,0}, offset={0,0}
		numTraces =  ItemsInList(TraceNameList(topGraph,";",3))
		For(i=0;i<numTraces;i+=1)
			if(LogXAxis)
				if(LogYAxis)		//both log axes...
					ModifyGraph/Z/W=$(topGraph) muloffset[i] = {XOffset^i,YOffset^i}
				else //X log, y lin
					ModifyGraph/Z/W=$(topGraph) muloffset[i] = {XOffset^i,0}, offset[i] = {0,i*YOffset}
				endif
			else
				if(LogYAxis)		//y log, x lin...
					ModifyGraph/Z/W=$(topGraph) offset[i] = {i*XOffset,0}, muloffset[i] = {0,YOffset^i}
				else			//both lin	
			 	  ModifyGraph/Z/W=$(topGraph) offset[i] = {i*XOffset,i*YOffset}
			 	endif
		 	endif
		endfor
	endif
end
///******************************************************************************************
///******************************************************************************************
Function IN2G_LegendTopGrphFldr(FontSize, MaxItems, UseFolderName, UseWavename)
	variable FontSize, MaxItems, UseFolderName, UseWavename

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String topGraph=WinName(0,1)
	string Traces=TraceNameList(topGraph, ";", 1 )
	string legendStr="", tmpStr
	if(Fontsize<10)
		legendStr="\Z0"+num2str(floor(FontSize))	
	else
		legendStr="\Z"+num2str(floor(FontSize))	
	endif
	variable i, imax, test2
	imax=ItemsInList(Traces , ";")
	variable stepI=1
	if(imax>MaxItems)
			stepI = ceil(imax/MaxItems)
	endif
	For(i=0;i<imax;i+=stepI)
		tmpStr = StringFromList(i,traces)
		if(UseFolderName && UseWavename)
			legendStr+="\\s("+tmpStr+") "+GetWavesDataFolder(TraceNameToWaveRef(topGraph, tmpStr),0)+":"+tmpStr
		elseif(UseFolderName && !UseWavename)
			legendStr+="\\s("+tmpStr+") "+GetWavesDataFolder(TraceNameToWaveRef(topGraph, tmpStr),0)
		elseif(!UseFolderName && UseWavename)
			legendStr+="\\s("+tmpStr+") "+":"+tmpStr
		endif
		if (i<imax-stepI)
			legendStr+="\r"
		endif
	endfor
	if(i!=(imax+stepI-1))	//append the very last one if not done yet... 
		i=imax-1
		legendStr+="\r"
		tmpStr = StringFromList(i,traces)
		if(UseFolderName && UseWavename)
			legendStr+="\\s("+tmpStr+") "+GetWavesDataFolder(TraceNameToWaveRef(topGraph, tmpStr),0)+":"+tmpStr
		elseif(UseFolderName && !UseWavename)
			legendStr+="\\s("+tmpStr+") "+GetWavesDataFolder(TraceNameToWaveRef(topGraph, tmpStr),0)
		elseif(!UseFolderName && UseWavename)
			legendStr+="\\s("+tmpStr+") "+":"+tmpStr
		endif
	endif	
	Legend/C/N=text0/A=LB legendStr
end

//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2G_FolderSelectPanel(SVARString, TitleString,StartingFolder,FolderOrFile,AllowNew,AllowDelete,AllowRename,AllowLiberal,ExecuteMyFunction)		
	string SVARString, TitleString, StartingFolder, ExecuteMyFunction	
	variable FolderOrFile, AllowNew,AllowDelete,AllowRename	,AllowLiberal		
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//		Jan Ilavsky, 12/13/2003 version 1
	// 	This is universal widget for programmers to call when user needs to select folder and possibly string/wave/variable name 
	//	User is allowed to manipulate folders and see their content, with functionality close to standard OS widgets
	//
	//	Help:
	//	SVARString 		full name of string (will be created, including folders, if necessary) which will have result in it
	//	TitleString 		Title of the panel which is used, so it can be customized.
	//	StartingFolder	if set to "" current folder is used, otherwise the first folder displayed will be set to this folder (if exists, if not, set to current)
	//
	// 	FolderOrFile 		set  to  0 to get back only folder path
	//					set to 1 if you want folder path and item (string/var/wave) name back. Uniqueness not required. 
	//					set to 2 to get path and UNIQUE item (string/var/wave) name
	//					Path starts from root: folder always!!!
	//	AllowNew		set to 1 to allow user to create new folder
	//	AllowDelete		set to 1 to allow user to delete folder
	//	AllowRename	set to 1 to allow user to rename existing folder
	//	ExecuteMyFunction	string with function to call when user is done. Set to "" if no function (just kill this panel) should be called.
	//
	// 	a panel with this name:      IN2G_FolderSelectPanelPanel     , is used. Only one can exist at a time... Existing will be killed...
	// 	to use properly, call this function:
	//				IN2G_FolderSelectPanel("root:Packages:HereIsTheResult", "This is panel title for user to know what I want","root:xxxx",1,1,1,1)
	//		to get folder path and name,   or
	//				IN2G_FolderSelectPanel("root:Packages:HereIsTheResult", "This is panel title for user to know what I want","root:xxxx",0,1,1,1)
	//		to get path to folder only
	//	 and then do
	//		           PauseForUser  IN2G_SelectFolderPanelPanel
	//					note !!!!  this disables the double clicking selection, you need to use buttons...
	//	when done find result in the 
	//				SVAR StringWithResult=$(SVARString)    {in this example :SVAR StringWithResult=$("root:Packages:HereIsTheResult")}
	//	should work for Igor 4 and Igor 5 with minor differences (button colors do not work in Igor 4)
	//
	//	Note, that following string: 			SVAR LastFolder=root:Packages:FolderSelectPanel:LastFolder
	//	is used to store last folder the tool was in before it was finished/canceled and hopefully also killed. This can be use to return user in the same place...
	//
	//	Note, that if user hits Cancel, the panel is killed AND the string variable is left set to "", so to check for user cancel check the strlen()...
	//
	// Example of use:
	// 	IN2G_FolderSelectPanel("root:Packages:ControlString","Select this particular path","root:",1,1,1,1,"YourContinueFunction()")

	
	string OldDf=GetDataFolder(1)
	IN2G_FolderSelectInitialize(OldDf,SVARString,StartingFolder,FolderOrFile,AllowLiberal,ExecuteMyFunction)
	IN2G_FolderSelectRefreshList()
	IN2G_FolderSelectRefFldrCont()
	IN2G_FolderSelectPanelW(TitleString,FolderOrFile,AllowNew,AllowDelete,AllowRename)
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IN2G_FolderSelectInitialize(OldDf,SVARStringL,StartingFolder,FolderOrFileL,AllowLiberalL,ExecuteMyFunctionL)
	string OldDf,SVARStringL,StartingFolder,ExecuteMyFunctionL
	variable FolderOrFileL,AllowLiberalL

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i, imax=ItemsInList(SVARStringL,":")
	For(i=0;i<imax-1;i+=1)
		if (cmpstr(StringFromList(i,SVARStringL,":"),"root")==0)
			setDataFolder root:
		else
			NewDataFolder/O/S $(StringFromList(i,SVARStringL,":"))
		endif	
	endfor
	string/g $(SVARStringL)
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:FolderSelectPanel
	string/g CurrentFolder=OldDf
	if (strlen(StartingFolder)>0 && DataFOlderExists(StartingFolder))
		CurrentFolder=StartingFolder
	endif
	string/g NewName
	string/g SVARString=SVARStringL
	string/g ExecuteMyFunction=ExecuteMyFunctionL
	string/g LastFolder
	variable/g DisplayWaves
	variable/g AllowLiberal=AllowLiberalL
	variable/g DisplayStrings
	variable/g DisplayVariables
	variable/g FolderOrFile=FolderOrFileL
	SVAR/Z testString=$(SVARString)
	if(!SVAR_Exists(testString))
		Abort "There was problem with definition of pointer"
	endif
	make/O/T/N=1 ListOfSubfolders, ListWithFolderContent
	ListOfSubfolders[0]="Up dir"
end
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IN2G_FolderSelectRefreshList()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=GetDataFolder(1)
	SVAR CurrentFolder=root:Packages:FolderSelectPanel:CurrentFolder
	Wave/T ListOfSubfolders=root:Packages:FolderSelectPanel:ListOfSubfolders
	if (cmpstr(CurrentFolder[strlen(CurrentFolder)-1],":")!=0)
		CurrentFolder+=":"
	endif
	string tempStr=CurrentFolder
	variable StartIndex=0
	variable NumItems
	setDataFolder tempStr
	string CurrentList=stringByKey("FOLDERS",DataFolderDir(1),":")
	variable i, imax=ItemsInList(CurrentList,",")
	if(cmpstr(tempStr,"root:")==0)
		NumItems=imax
	else
		NumItems=imax+1
	endif
	redimension/N=(NumItems) ListOfSubfolders
	if(cmpstr(tempStr,"root:")!=0)
		ListOfSubfolders[0] ="Up dir"
		StartIndex=1
	endif
		FOr(i=0;i<imax;i+=1)
		ListOfSubfolders[i+StartIndex] =StringFromList(i,CurrentList,",")
	endfor
	DoWIndow IN2G_FolderSelectPanelPanel
	if(V_Flag)
		ListBox ListOfSubfolders,selRow=-1, row=0, win=IN2G_FolderSelectPanelPanel
		DoUpdate
	endif
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IN2G_FolderSelectRefFldrCont()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=GetDataFolder(1)
	SVAR CurrentFolder=root:Packages:FolderSelectPanel:CurrentFolder
	SVAR LastFolder=root:Packages:FolderSelectPanel:LastFolder
	Wave/T ListWithFolderContent=root:Packages:FolderSelectPanel:ListWithFolderContent
	NVAR DisplayWaves=root:Packages:FolderSelectPanel:DisplayWaves
	NVAR DisplayStrings=root:Packages:FolderSelectPanel:DisplayStrings
	NVAR DisplayVariables=root:Packages:FolderSelectPanel:DisplayVariables
	if (cmpstr(CurrentFolder[strlen(CurrentFolder)-1],":")!=0)
		CurrentFolder+=":"
	endif
	string tempStr=CurrentFolder
	setDataFolder tempStr
	string CurrentListW=""
	string CurrentListV=""
	string CurrentListS=""
	string CurrentList=""
	if (DisplayWaves)
		 CurrentListW=stringByKey("WAVES",DataFolderDir(2),":")
		 if(strlen(CurrentListW)>0)
		 	CurrentListW="Waves..............,"+CurrentListW+","
		 endif
	endif
	if (DisplayVariables)
		 CurrentListV=stringByKey("VARIABLES",DataFolderDir(4),":")
		 if(strlen(CurrentListV)>0)
		 	CurrentListV="Variables..............,"+CurrentListV+","
		 endif
	endif
	if (DisplayStrings)
		 CurrentListS=stringByKey("STRINGS",DataFolderDir(8),":")
		 if(strlen(CurrentListS)>0)
		 	CurrentListS="Strings..............,"+CurrentListS+","
		 endif
	endif
	CurrentList=CurrentListW+CurrentListV+CurrentListS
	variable i, imax=ItemsInList(CurrentList,",")
	redimension/N=(imax) ListWithFolderContent
	For(i=0;i<imax;i+=1)
		ListWithFolderContent[i] =StringFromList(i,CurrentList,",")
	endfor
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2G_FolderSelectCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if(cmpstr(ctrlName,"DisplayWaves"))
	
	endif
	IN2G_FolderSelectRefFldrCont()
End


Function IN2G_FolderSelectListBoxProc(ctrlName,row,col,event)
	String ctrlName
	Variable row
	Variable col
	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
					//5=cell select with shift key, 6=begin edit, 7=end
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR CurrentFolder=root:Packages:FolderSelectPanel:CurrentFolder
	SVAR LastFolder=root:Packages:FolderSelectPanel:LastFolder
	SVAR NewName=root:Packages:FolderSelectPanel:NewName
	NVAR FolderOrFile=root:Packages:FolderSelectPanel:FolderOrFile
	NVAR AllowLiberal=root:Packages:FolderSelectPanel:AllowLiberal
	Wave/T ListOfSubfolders=root:Packages:FolderSelectPanel:ListOfSubfolders
	Wave/T ListWithFolderContent=root:Packages:FolderSelectPanel:ListWithFolderContent

	string OldDf=GetDataFolder(1)

	if(cmpstr(ctrlName,"ListOfSubfolders")==0)
		if(event==3)
			ControlInfo ListOfSubfolders
			if (stringmatch(ListOfSubfolders[V_value], "*Up dir*" ))
				CurrentFolder=RemoveFromList(stringFromList(ItemsInList(CurrentFolder,":")-1,CurrentFolder,":"), CurrentFolder , ":") 
				if (strlen(CurrentFolder)<=1)
					CurrentFolder="root:"
				endif
			else
				CurrentFolder=CurrentFolder+possiblyQUoteName(ListOfSubfolders[V_value])
				LastFolder=CurrentFolder
			endif
			SetVariable DisplayValue,disable=1,win=IN2G_FolderSelectPanelPanel
			Button EditStrOrVar, disable=1,win=IN2G_FolderSelectPanelPanel
			IN2G_FolderSelectRefreshList()
			IN2G_FolderSelectRefFldrCont()
		endif
	endif
	if(cmpstr(ctrlName,"ListOfFolderContent")==0 && FolderOrFile>0)
		if(event==2)
			setDataFolder CurrentFolder
			ControlInfo ListOfFolderContent
			string tempName
			if (strlen(ListWithFolderContent[V_value])>0)
				tempName = ListWithFolderContent[V_value]
			endif
			variable objType=exists(tempName)
			if (objType==2)
				SetVariable DisplayValue,disable=0,noedit=1,frame=0,value=$(CurrentFolder+tempName), win=IN2G_FolderSelectPanelPanel
				Button EditStrOrVar, disable=0,win=IN2G_FolderSelectPanelPanel
			else
				SetVariable DisplayValue,disable=1,win=IN2G_FolderSelectPanelPanel
				Button EditStrOrVar, disable=1,win=IN2G_FolderSelectPanelPanel
			endif
			if(objType==1)
				Button EditStrOrVar, disable=0,win=IN2G_FolderSelectPanelPanel
			endif
		
		endif

		if(event==3)
			variable isOK=0
			setDataFolder CurrentFolder
			ControlInfo ListOfFolderContent
			if (strlen(ListWithFolderContent[V_value])>0)
				NewName = ListWithFolderContent[V_value]
				if (AllowLiberal)		//liberal names allowed, check for wave name (can be liberal)
					if (CheckName(NewName,1)==0)
						isOK=1
					else
						isOK=0
					endif
				else					//liberal names not allowed, check for variable (cannot be liberal)
					if (CheckName(NewName,3)==0)
						isOK=1
					else
						isOK=0
					endif
				endif
				if (!isOK)
						if (FolderOrFile>1)
							Button Done, title="NotUnique",disable=2,fColor=(0,0,0),win=IN2G_FolderSelectPanelPanel
						else
							Button Done, title="Done/NotUnique",disable=0,fColor=(65280,48896,48896),win=IN2G_FolderSelectPanelPanel
						endif
				else
						Button Done, title="Done",disable=0,fColor=(0,0,0),win=IN2G_FolderSelectPanelPanel
				endif  			
			endif
		endif
	endif
	setDataFOlder OldDf
	return 0
End
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2G_FolderSelectButtonProc(ctrlName) : ButtonControl
	String ctrlName

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		string OldDf=GetDataFolder(1)
		SVAR CurrentFolder=root:Packages:FolderSelectPanel:CurrentFolder
		SVAR LastFolder=root:Packages:FolderSelectPanel:LastFolder
		Wave/T ListOfSubfolders=root:Packages:FolderSelectPanel:ListOfSubfolders
		Wave/T ListWithFolderContent=root:Packages:FolderSelectPanel:ListWithFolderContent
		string NewName
		string KillNameFldr



	if(cmpstr(ctrlName,"EditStrOrVar")==0)
			setDataFolder CurrentFolder
			ControlInfo ListOfFolderContent
			string tempName
			if (strlen(ListWithFolderContent[V_value])>0)
				tempName = ListWithFolderContent[V_value]
			endif
			variable objType=exists(tempName)
			if (objType==2)			//string or variable
				SetVariable DisplayValue,noedit=0, frame=1, win=IN2G_FolderSelectPanelPanel
			elseif(objType==1)		//wave
				edit/K=1 $(tempName)
			endif
	endif
	if(cmpstr(ctrlName,"CreateNewFolder")==0)
		Prompt NewName, "Input name for new folder, up to 28 characters and \"   \" around the test"
		DoPrompt "Get New Folder Name", NewName
		if(V_Flag)
			abort
		endif
		NewName=possiblyQuoteName(NewName[0,31])
		setDataFOlder CurrentFolder
		NewDataFolder/O/S $(CurrentFolder+NewName)
		CurrentFolder=GetDataFolder(1)
		LastFolder=CurrentFolder
		IN2G_FolderSelectRefreshList()
		IN2G_FolderSelectRefFldrCont()
		IN2G_FolderSelectSetVarProc("NewName",1,"","")		//this fixes the button "done" into appropriate state
	endif
	if(cmpstr(ctrlName,"DeleteFolder")==0)
		DoAlert 1, "Deleting folder is unrecoverable, are you sure that you want to do this? You can loose data..."
		if(V_Flag==1)
			ControlInfo ListOfSubfolders
			KillNameFldr=possiblyQuoteName(ListOfSubfolders[V_value])
			if(cmpstr(KillNameFldr,"'Up dir'")==0)
				abort
			endif
			if (DataFOlderExists (CurrentFolder+KillNameFldr))
				KillDataFOlder $(CurrentFolder+KillNameFldr)
			endif
			IN2G_FolderSelectRefreshList()
			IN2G_FolderSelectRefFldrCont()
			IN2G_FolderSelectSetVarProc("NewName",1,"","")		//this fixes the button "done" into appropriate state
		endif
	endif
	if(cmpstr(ctrlName,"OpenFolder")==0)
			ControlInfo ListOfSubfolders
			if (V_value<0)
				abort
			endif
			if (stringmatch(ListOfSubfolders[V_value], "*Up dir*" ))
				CurrentFolder=RemoveFromList(stringFromList(ItemsInList(CurrentFolder,":")-1,CurrentFolder,":"), CurrentFolder , ":") 
				if (strlen(CurrentFolder)<=1)
					CurrentFolder="root:"
				endif
			else
				CurrentFolder=CurrentFolder+possiblyQUoteName(ListOfSubfolders[V_value])
				LastFolder=CurrentFolder
		endif
			IN2G_FolderSelectRefreshList()
			IN2G_FolderSelectRefFldrCont()
			IN2G_FolderSelectSetVarProc("NewName",1,"","")		//this fixes the button "done" into appropriate state
	endif
	if(cmpstr(ctrlName,"RenameFolder")==0)
			ControlInfo ListOfSubfolders
			KillNameFldr=possiblyQuoteName(ListOfSubfolders[V_value])
			Prompt NewName, "Input new name for the selected folder, up to 28 characters and \"   \" around the test"
			DoPrompt "Get New Folder Name", NewName
			if(V_Flag)
				abort
			endif
	//		NewName=possiblyQuoteName(NewName[0,29])
			NewName=(NewName[0,29])
			RenameDataFolder $(CurrentFolder+KillNameFldr), $(NewName)
			IN2G_FolderSelectRefreshList()
			IN2G_FolderSelectRefFldrCont()
			IN2G_FolderSelectSetVarProc("NewName",1,"","")		//this fixes the button "done" into appropriate state
	endif

	if(cmpstr(ctrlName,"Done")==0)
		SVAR SVARString=root:Packages:FolderSelectPanel:SVARString
		SVAR WHereToPutRes=$SVARString
		NVAR FolderOrFile=root:Packages:FolderSelectPanel:FolderOrFile
		SVAR NewNameStr=root:Packages:FolderSelectPanel:NewName
		SVAR ExecuteMyFunction=root:Packages:FolderSelectPanel:ExecuteMyFunction
		if(FolderOrFile)
			WHereToPutRes=CurrentFolder+possiblyQuoteName(NewNameStr)
		else
			WHereToPutRes=CurrentFolder	
		endif
		LastFolder=CurrentFolder
		KillWIndow/Z IN2G_FolderSelectPanelPanel
		if (strlen(ExecuteMyFunction)>0)
			Execute(ExecuteMyFunction)
		endif
	endif
	if(cmpstr(ctrlName,"CancelBtn")==0)
		SVAR SVARString=root:Packages:FolderSelectPanel:SVARString
		SVAR WHereToPutRes=$SVARString
		NVAR FolderOrFile=root:Packages:FolderSelectPanel:FolderOrFile
		SVAR NewNameStr=root:Packages:FolderSelectPanel:NewName
		LastFolder=CurrentFolder
		WHereToPutRes=""	
		KillWIndow/Z IN2G_FolderSelectPanelPanel
	endif


	setDataFolder OldDf
End
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2G_FolderSelectSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR AllowLiberal=root:Packages:FolderSelectPanel:AllowLiberal

	if(cmpstr("NewName",ctrlName)==0)
		SVAR CurrentFolder=root:Packages:FolderSelectPanel:CurrentFolder
		SVAR NewName=root:Packages:FolderSelectPanel:NewName
		NVAR FolderOrFile=root:Packages:FolderSelectPanel:FolderOrFile
		string OldDf=GetDataFolder(1)
		variable isOK=0
		setDataFolder CurrentFolder
		NewName = (cleanupName((NewName)[0,31],AllowLiberal))
//		NewName = (possiblyQuoteName(NewName))
				if (AllowLiberal)		//liberal names allowed, check for wave name (can be liberal)
					if (CheckName(NewName,1)==0)
						isOK=1
					else
						isOK=0
					endif
				else					//liberal names not allowed, check for variable (cannot be liberal)
					if (CheckName(NewName,3)==0)
						isOK=1
					else
						isOK=0
					endif
				endif
		if (!isOK)
				if (FolderOrFile>1)
					Button Done, title="NotUnique",disable=2,fColor=(0,0,0),win=IN2G_FolderSelectPanelPanel
				else
					Button Done, title="Done/NotUnique",disable=0,fColor=(65280,48896,48896),win=IN2G_FolderSelectPanelPanel
				endif
		else
				Button Done, title="Done",fColor=(0,0,0),disable=0,win=IN2G_FolderSelectPanelPanel
		endif  
		setDataFolder oldDf
	endif
End
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IN2G_FolderSelectPanelW(TitleString,FolderOrFile,AllowNew,AllowDelete,AllowRename)
	string TitleString
	variable FolderOrFile,AllowNew,AllowDelete,AllowRename
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	KillWIndow/Z IN2G_FolderSelectPanelPanel
 	//PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(100,60,630,340)/N=IN2G_FolderSelectPanelPanel as TitleString
	//DoWindow/C IN2G_FolderSelectPanelPanel
	TitleBox Title title="   "+TitleString+"   ",disable=2,frame=0,pos={1,3}
	TitleBox Title font="Arial Black",fSize=11,fColor=(0,0,0), labelBack=(56576,56576,56576)
	SetVariable CurrentFolder,pos={3,25},size={500,19},disable=2, title="Current Folder: "
	SetVariable CurrentFolder,labelBack=(56576,56576,56576),fSize=12,frame=0,help={"Name of currently selected folder"}
	SetVariable CurrentFolder,limits={0,0,0},value= root:Packages:FolderSelectPanel:CurrentFolder
	if (FolderOrFile)
		SetVariable NewName,pos={3,45},size={500,19},title="Current  Name: ", proc=IN2G_FolderSelectSetVarProc
		SetVariable NewName,help={"Name of new wave/variable/string"}, frame=1,labelBack=(56576,56576,56576)
		SetVariable NewName,value= root:Packages:FolderSelectPanel:NewName,fSize=12
	endif
	ListBox ListOfSubfolders,pos={3,70},size={250,130},proc=IN2G_FolderSelectListBoxProc
	ListBox ListOfSubfolders,listWave=root:Packages:FolderSelectPanel:ListOfSubfolders
	ListBox ListOfSubfolders,mode= 1,editStyle= 1,help={"Double clisk on folder to go to, select folder and click on Delete/Rename/Open folder buttons"}

	CheckBox DisplayWaves title="Show waves?",proc=IN2G_FolderSelectCheckProc, pos={260,70}
	CheckBox DisplayWaves variable=root:Packages:FolderSelectPanel:DisplayWaves
	CheckBox DisplayWaves help={"Check here to display waves in the currently selected folder below"}	
	CheckBox DisplayStrings title="Strings?",proc=IN2G_FolderSelectCheckProc, pos={365,70}
	CheckBox DisplayStrings variable=root:Packages:FolderSelectPanel:DisplayStrings
	CheckBox DisplayStrings help={"Check here to display string in the currently selected folder below"}	
	CheckBox DisplayVariables title="Variables?",proc=IN2G_FolderSelectCheckProc, pos={440,70}
	CheckBox DisplayVariables variable=root:Packages:FolderSelectPanel:DisplayVariables
	CheckBox DisplayVariables help={"Check here to display variables in the currently selected folder below"}	
	
	ListBox ListOfFolderContent,pos={255,90},size={265,110},proc=IN2G_FolderSelectListBoxProc
	ListBox ListOfFolderContent,listWave=root:Packages:FolderSelectPanel:ListWithFolderContent
	ListBox ListOfFolderContent,mode= 1, frame=1, editStyle= 1,help={"Content of folder selected above, to move around use buttons, double click may not work... "}

	if(AllowNew)
		Button CreateNewFolder,pos={10,225},size={100,20},proc=IN2G_FolderSelectButtonProc,title="New fldr"
		Button CreateNewFolder,help={"Click to create new folder in the current folder displayed in the blue field"},fSize=10
	endif
	if(AllowDelete)
		Button DeleteFolder,pos={10,250},size={100,20},proc=IN2G_FolderSelectButtonProc,title="Delete fldr"
		Button DeleteFolder,help={"Click to delete existing folder selected in the box above"},fSize=10
	endif
	Button OpenFolder,pos={120,225},size={100,20},proc=IN2G_FolderSelectButtonProc,title="Open fldr"
	Button OpenFolder,help={"Click to open folder selected in the box above"}, font="Times New Roman",fSize=10
	if(AllowRename)
		Button RenameFolder,pos={120,250},size={100,20},proc=IN2G_FolderSelectButtonProc,title="Rename fldr"
		Button RenameFolder,help={"Click to rename existing folder selected in the box above"},fSize=10
	endif
	SetVariable DisplayValue,pos={20,205},size={400,19},title="Value : ", proc=IN2G_FolderSelectSetVarProc
	SetVariable DisplayValue,fSize=10,frame=0,help={"Value of selected variable or string"}, limits={-inf,inf,0}, noedit=1,disable=1
	//SetVariable DisplayValue,value= "  "
	Button EditStrOrVar,pos={420,205},size={100,20},proc=IN2G_FolderSelectButtonProc,title="Edit",disable=1
	Button EditStrOrVar,help={"Click to edit value of selected string, variable, or wave"},fSize=10
	Button CancelBtn,pos={240,250},size={100,20},proc=IN2G_FolderSelectButtonProc,title="Cancel",fSize=10
	Button CancelBtn,help={"Click to here to Cancel. "}
	Button Done,pos={360,250},size={150,20},proc=IN2G_FolderSelectButtonProc,title="Done/Continue",fSize=10
	Button Done,help={"Click to here to continue. If the W/S/V name selected exists and it is allowed this button is RED, if it is not allowed button is greyed. "}
	DoUpdate
	IN2G_FolderSelectSetVarProc("NewName",1,"","")
EndMacro
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_UpdateSetVarStep(MyControlName,NewStepFraction)
	string MyControlName
	variable NewStepFraction
	//updates setVar step. Needs setVarName, and fraction of current value to be new step
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	ControlInfo $MyControlName
	variable StepFraction=NewStepFraction
	variable keys= GetKeyState(0)
	if(keys>0)	//any modifier key pressed, make smaller steps
		StepFraction=NewStepFraction*0.1
	endif
	variable NewStep=V_Value * StepFraction
	variable startS =strsearch(S_recreation,"{",strsearch(S_recreation,"limits",0))
	variable endS =strsearch(S_recreation,"}",strsearch(S_recreation,"limits",0))
	variable oldMin=str2num((stringFromList(0,S_recreation[startS+1,endS-1],",")))
	variable oldMax=str2num((stringFromList(1,S_recreation[startS+1,endS-1],",")))
	SetVariable $(MyControlName),limits={oldMin,oldMax,(NewStep)}
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



Function/T IN2G_RemoveExtraQuote(str,starting,Ending)
	String str
	variable starting,Ending
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if (starting)
		if(cmpstr(str[0],"'")==0)
			str = str[1,inf]
		endif
	endif
	if (ending)
		if(cmpstr(str[strlen(str)-1],"'")==0)
			str = str[0,strlen(str)-2]
		endif
	endif
	return str
End

//*****************************************************************************************************************
//*****************************************************************************************************************



Function/T IN2G_ChangePartsOfString(str,oldpart,newpart)
	String str
	String oldpart
	String newpart

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable id=strlen(oldpart)
	Variable i
	do
		i = strsearch(str,oldpart,0 )
		if (i>=0)
			str[i,i+id-1] = newpart
		endif
	while(i>=0)
	//replaceString would be better????
	return str
End


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


//Function CursorMovedHook(info)
//		string info
//	//	print info     GRAPH:IR1_OneSampleEvaluationGraph;CURSOR:A;
//	//                     TNAME:TotalNumberDist;MODIFIERS:0;ISFREE:0;POINT:88;  
//
//	if (cmpstr(StringByKey("Graph", info), "IR1_OneSampleEvaluationGraph")==0)
//		NVAR GR1_AutoUpdate=root:Packages:SAS_Modeling:GR1_AutoUpdate
//		if (GR1_AutoUpdate)
//			Execute("IR1G_CalculateStatistics()")
//		endif
//	endif
//
//	if (cmpstr(StringByKey("Graph", info), "CheckGraph1")==0)
//		string/g root:Packages:DesmearWorkFolder:CsrMoveInfo
//		SVAR CsrMoveInfo=root:Packages:DesmearWorkFolder:CsrMoveInfo
//		CsrMoveInfo=info
//		Execute("IN2D_CursorMoved()")
//	endif
//	if (cmpstr(StringByKey("Graph", info), "CheckTheBackgroundExtns")==0)
//		string/g root:Packages:Irena_desmearing:CsrMoveInfo
//		SVAR CsrMoveInfo=root:Packages:Irena_desmearing:CsrMoveInfo
//		CsrMoveInfo=info
//		Execute("IR1B_CursorMoved()")
//	endif
//	
//	if (cmpstr(StringByKey("Graph", info), "BckgSubtCheckGraph1")==0)
//		string/g root:Packages:SubtrBckgWorkFldr:CsrMoveInfo
//		SVAR CsrMoveInfo=root:Packages:SubtrBckgWorkFldr:CsrMoveInfo
//		CsrMoveInfo=info
//		Execute("IN2Q_CursorMoved()")
//	endif
//	if (cmpstr(StringByKey("Graph", info), "HES_PorodGraphWindow")==0)
//	//	string/g root:CsrMoveInfo
//	//	SVAR CsrMoveInfo=root:CsrMoveInfo
//	//	CsrMoveInfo=info
//		Execute("HES_FitPorodLine()")
//	endif
//	
//end



//**********************************************************************************************
//**********************************************************************************************

Function IN2G_IntegrateXY(xWave, yWave)
	Wave xWave, yWave						// input/output X, Y waves
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable yp,ypm1,sum=0
	Variable pt=1,n=numpnts(yWave)
	ypm1=yWave[0]
	yWave[0]= 0
	do
		yp= yWave[pt]
		sum +=  0.5*(yp + ypm1) * (xWave[pt] - xWave[pt-1])
		yWave[pt]= sum
		ypm1= yp
		pt+=1
	while( pt<n )
End

//**********************************************************************************************
//**********************************************************************************************
Function IN2G_CreateItem(TheSwitch,NewName)
	string TheSwitch, NewName
//this function creates strings or variables with the name passed
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if(strlen(NewName)<1)
		return 0
	endif
	if (cmpstr(TheSwitch,"string")==0)
		SVAR/Z test=$NewName
		if (!SVAR_Exists(test))
			string/g $NewName
			SVAR testS=$NewName
			testS=""
		endif
	endif
	if (cmpstr(TheSwitch,"variable")==0)
		NVAR/Z testNum=$NewName
		if (!NVAR_Exists(testNum))
			variable/g $NewName
			NVAR testV=$NewName
			testV=0
		endif
	endif
end
//**********************************************************************************************
//**********************************************************************************************
Function IN2G_ErrorsForDivision(A1,S1,A2,S2)
	variable A1, S1, A2, S2	//this function divides A1 by A2 with errors
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable Error=(sqrt((A1^2*S2^4)+(S1^2*A2^4)+((A1^2+S1^2)*A2^2*S2^2))) / (A2*(A2^2-S2^2))
	
	return Error
end	

Function IN2G_ErrorsForMultiplication(A1,S1,A2,S2)
	variable A1, S1, A2, S2	//this function multiplies two numbers with errors
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable Error=sqrt((A1*S2)^2+(A2*S1)^2+(S1*S2)^2)
	
	return Error
end	

Function IN2G_ErrorsForSubAndAdd(A1,S1,A2,S2)
	variable A1, S1, A2, S2	//this function subtracts A2 from A1 with errors
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable Error=sqrt(S1^2+S2^2)
	
	return Error
end	


Function/T IN2G_DivideWithErrors(A1,S1,A2,S2)
	variable A1, S1, A2, S2	//this function divides A1 by A2 with errors
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable Result=A1/A2
	variable Error=(sqrt((A1^2*S2^4)+(S1^2*A2^4)+((A1^2+S1^2)*A2^2*S2^2))) / (A2*(A2^2-S2^2))
	
	return num2str(Result)+";"+num2str(Error)
end	


Function/T IN2G_MulitplyWithErrors(A1,S1,A2,S2)
	variable A1, S1, A2, S2	//this function multiplies two numbers with errors
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable Result=A1*A2
	variable Error=sqrt((A1*S2)^2+(A2*S1)^2+(S1*S2)^2)
	
	return num2str(Result)+";"+num2str(Error)
end	


Function/T IN2G_SubtractWithErrors(A1,S1,A2,S2)
	variable A1, S1, A2, S2	//this function subtracts A2 from A1 with errors
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable Result=A1-A2
	variable Error=sqrt(S1^2+S2^2)
	
	return num2str(Result)+";"+num2str(Error)
end	

Function/T IN2G_SumWithErrors(A1,S1,A2,S2)
	variable A1, S1, A2, S2	//this function sums two numbers with errors
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable Result=A1+A2
	variable Error=sqrt(S1^2+S2^2)
	
	return num2str(Result)+";"+num2str(Error)
end	



//**********************************************************************************************
//**********************************************************************************************

Function IN2G_AppendSizeTopWave(GraphName,BotWave, LeftWave,AxisPos,LabelX,LabelY)
	Wave BotWave, LeftWave
	String GraphName
	Variable AxisPos,LabelX,LabelY
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string CurrentListOfrWaves=TraceNameList(GraphName,";",1)
	//here we store what traces are in the graph before	
	duplicate/O BotWave, root:Packages:Indra3:MyTopWave
	
	Wave NewTopWave=root:Packages:Indra3:MyTopWave
	
	NewTopWave=2*pi/NewTopWave
	
	ModifyGraph/W=$GraphName mirror(bottom)=0
	AppendtoGraph/T=SizeAxis/W=$GraphName LeftWave vs NewTopWave
	SetAxis/W=$GraphName /A/R SizeAxis
	ModifyGraph/W=$GraphName log(SizeAxis)=1
	
	string NewListOfWaves=TraceNameList(GraphName,";",1)
	//New list of waves in the graph
	string NewWaveName=StringFromList(ItemsInList(NewListOfWaves)-1, NewListOfWaves)
	
	ModifyGraph/W=$GraphName mode($NewWaveName)=2
	Label/W=$GraphName SizeAxis "\Z09 2*pi/Q [A]"
	ModifyGraph/W=$GraphName tick(SizeAxis)=2
	ModifyGraph/W=$GraphName lblPos(SizeAxis)=LabelY,freePos(SizeAxis)=AxisPos, lblLatPos(SizeAxis)=LabelX
end
//**********************************************************************************************
//**********************************************************************************************

Function IN2G_AppendGuinierTopWave(GraphName,BotWave, LeftWave,AxisPos,LabelX,LabelY)
	Wave BotWave, LeftWave
	String GraphName
	Variable AxisPos,LabelX,LabelY
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string CurrentListOfrWaves=TraceNameList(GraphName,";",1)
	//here we store what traces are in the graph before	
	duplicate/O BotWave, root:Packages:Indra3:MyTopWave
	
	Wave NewTopWave=root:Packages:Indra3:MyTopWave
	
	NewTopWave=(2*pi)^2/NewTopWave
	
	ModifyGraph/W=$GraphName mirror(bottom)=0
	AppendtoGraph/T=SizeAxis/W=$GraphName LeftWave vs NewTopWave
	SetAxis/W=$GraphName /A/R SizeAxis
	ModifyGraph/W=$GraphName log(SizeAxis)=1
	
	string NewListOfWaves=TraceNameList(GraphName,";",1)
	//New list of waves in the graph
	string NewWaveName=StringFromList(ItemsInList(NewListOfWaves)-1, NewListOfWaves)
	
	ModifyGraph/W=$GraphName mode($NewWaveName)=2
	Label/W=$GraphName SizeAxis "\Z09 (2*pi/Q)^2 [A^2]"
	ModifyGraph/W=$GraphName tick(SizeAxis)=2
	ModifyGraph/W=$GraphName lblPos(SizeAxis)=LabelY,freePos(SizeAxis)=AxisPos, lblLatPos(SizeAxis)=LabelX
end

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_KillPanel(ctrlName) : ButtonControl
	String ctrlName

	//this procedure kills panel which it is called from, so I can continue in
	//paused for user procedure
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string PanelName=WinName(0,64)
	DoWindow /K $PanelName
End

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_AutoscaleAxisFromZero(WindowName,which,where)		//this function autoscales axis from 0
	string WindowName, which, where
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if (cmpstr(where,"up")==0)
		SetAxis/W=$(WindowName) /A/E=0 $which
		DoUpdate
		GetAxis/W=$(WindowName)/Q $(which)
		SetAxis/W=$(WindowName) $(which) 0, V_max
	else
		SetAxis/W=$(WindowName) /A/E=0 $(which)
		DoUpdate
		GetAxis/W=$(WindowName) /Q $(which)
		SetAxis/W=$(WindowName) $(which) V_min, 0	
	endif
end


Function/S IN2G_CheckFldrNmSemicolon(FldrName,Include)	//this function returns string - probably path
	string FldrName		//with ending semicolon included or not, depending on Include being 1 (include) 
	variable Include		//and 0 (do not include)
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if (Include==0)	//do not include :
		if (cmpstr(":", FldrName[StrLen(FldrName)-1])==0)
			return FldrName[0, StrLen(FldrName)-2]		// : is there, remove
		else
			return FldrName							// : is not  there, do not change
		endif
	else				//include :
		if (cmpstr(":", FldrName[StrLen(FldrName)-1])==0)
			return FldrName							// : is there, return
		else
			return FldrName+":"					//is not there , add
		endif	
	endif
end 


Function IN2G_CleanupFolderOfGenWaves(fldrname)		//cleans waves from waves created by generic plot
	string fldrname
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string dfold=GetDataFolder(1)
	setDataFolder fldrname
	string ListOfWaves=WaveList("Generic*",";","")+WaveList("MyFitWave*",";",""), temp
	variable i=0, imax=ItemsInList(ListOfWaves)
	For(i=0;i<imax;i+=1)
		temp=StringFromList(i,ListOfWaves)
		KillWaves/Z $temp
	endfor
	setDataFolder dfold
end


//**********************************************************************************************
//**********************************************************************************************
	
Function IN2G_AppendAnyText(TextToBeInserted)	//this function checks for existance of notebook
	string TextToBeInserted						//and appends text to the end of the notebook
	Silent 1
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	TextToBeInserted=TextToBeInserted+"\r"
    SVAR/Z nbl=root:Packages:Indra3:NotebookName
	if(SVAR_exists(nbl))
		if (strsearch(WinList("*",";","WIN:16"),nbl,0)!=-1)				//Logs data in Logbook
			Notebook $nbl selection={endOfFile, endOfFile}
			Notebook $nbl text=TextToBeInserted
		endif
	endif
end

//**********************************************************************************************
//**********************************************************************************************

Function/S IN2G_WindowTitle(WindowName)		//this function returns the title of the Window 
             String WindowName						//wwith WindowName
      
	Silent 1
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
             String RecMacro
             Variable AsPosition, TitleEnd
             String TitleString
      
             if (strlen(WindowName) == 0)
                     WindowName=WinName(0,1)         // Name of top graph window
             endif
      
             if (wintype(WindowName) == 0)
                     return ""                       // No window by that name
             endif
      
             RecMacro = WinRecreation(WindowName, 0)
             AsPosition = strsearch(RecMacro, " as \"", 0)
             if (AsPosition < 0)
                     TitleString = WindowName        // No title, return name
             else
                     AsPosition += 5                 // Found " as ", get following
                                                     //  quote mark
                     TitleEnd = strsearch(RecMacro, "\"", AsPosition)
                     TitleString = RecMacro[AsPosition, TitleEnd-1]
             endif
      
             return TitleString
     end

//**********************************************************************************************
//**********************************************************************************************

Function/T IN2G_ConvertDataDirToList(Str)		//converts   FOLDERS:spec1,spec2,spec3,spec4; type fo strring into list
	string str
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	str=RemoveListItem(0, Str , ":")					//remove the "FOLDERS"
	variable i=0, imax=itemsInList(str,",")			//working parameters
	string strList="", tmpstr						//working parameters
	str=str[0,strlen(str)-3]						//remove  /r; at the end
	if(stringmatch(str,"*,spec*"))					//here we have list of spec scans
		for(i=0;i<imax;i+=1)
			tmpstr=StringFromList(i, str, ",")							
			strList+=tmpstr[4,inf] +";"		
		endfor
		strList=SortList(strList,";",2)
		str=""
		for(i=0;i<imax;i+=1)							
			str+="spec"+StringFromList(i, strList, ";")+";"		
		endfor						
		strList=str				
 	else
		strList = ReplaceString(",", str, ";" )+";"
		if(strlen(strList)==1)
			strList=""
		endif
 	endif
 					
	return strList
end
//**********************************************************************************************
//**********************************************************************************************

Function/T IN2G_ConvertDataDirToListNew(Str)		//converts   FOLDERS:spec1,spec2,spec3,spec4; type fo strring into list
	string str
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	str=RemoveListItem(0, Str , ":")					//remove the "FOLDERS"
	variable i=0, imax=itemsInList(str,",")			//working parameters
	string strList="", tmpstr						//working parameters
	str=str[0,strlen(str)-3]						//remove  /r; at the end
	strList = ReplaceString(",", str, ";" )+";"
	if(strlen(strList)==1)
		strList=""
	endif				
	return strList
end


//**********************************************************************************************
//**********************************************************************************************

//Function/T IN2G_CreateListOfItemsInFolder(df,item)			//Generates list of items in given folder
//	String df
//	variable item										//1-directories, 2-waves, 4 - variables, 8- strings
//	
//	String dfSave
//	dfSave=GetDataFolder(1)
//	string MyList=""
//	
//	if (DataFolderExists(df))
//		SetDataFolder $df
//		MyList= IN2G_ConvertDataDirToList(DataFolderDir(item))	//here we convert the WAVES:wave1;wave2;wave3 into list
//		SetDataFolder $dfSave
//	else
//		MyList=""
//	endif
//	return MyList
//end
//**********************************************************************************************
//**********************************************************************************************

Function/T IN2G_CreateListOfItemsInFolder(df,item)			//Generates list of items in given folder
	String df
	variable item										//1-directories, 2-waves, 4 - variables, 8- strings
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string MyList=""
	DFREF TestDFR=$(df)
	if (DataFolderRefStatus(TestDFR))
		//MyList= IN2G_ConvertDataDirToList(DataFolderDir(item, TestDFR))				//here we convert the WAVES:wave1;wave2;wave3 into list
		MyList= IN2G_ConvertDataDirToListNew(DataFolderDir(item, TestDFR))				// this one does not handle now specNumber lists... 	
		return MyList
	else
		return ""
	endif
end

////**********************************************************************************************
////**********************************************************************************************
//Function/T IN2G_CreateListOfItemsInFldrDFR(dfDFR,item)			//Generates list of items in given folder
//	DFREF dfDFR
//	variable item										//1-directories, 2-waves, 4 - variables, 8- strings
//	
//	//String dfSave
//	//dfSave=GetDataFolder(1)
//	string MyList=""
//	//DFREF TestDFR=$(df)
//	if (DataFolderRefStatus(TestDFR))
//	//	SetDataFolder $df
//		//DataFolderDir(mode [, dfr ] )
//		MyList= IN2G_ConvertDataDirToList(DataFolderDir(item, TestDFR))	//here we convert the WAVES:wave1;wave2;wave3 into list
//		return MyList
//	//	SetDataFolder $dfSave
//	else
//		return ""
//	//	MyList=""
//	endif
//end

//**********************************************************************************************
//**********************************************************************************************

Function/T IN2G_GetMeListOfEPICSKeys()		//returns list of useful keywords for UPD table panel
		
	String dfSave, result="", tempstring="", KeyWordResult=""
	dfSave=GetDataFolder(1)
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR SpecFile=root:Packages:Indra3:PanelSpecScanSelected
	SetDataFolder $SpecFile
	SVAR EPICS_PVs=EPICS_PVs
	result="DCM_energy:"+StringByKey("DCM_energy",EPICS_PVs)+";"
	result+= EPICS_PVs[strsearch(EPICS_PVs,"UPD",0), inf]
	result+= "I0AmpDark;I0AmpGain;"			//added to pass throug some of the IO new stuff...

	SetDataFolder $dfSave
	variable i=0, imax=ItemsInList(result,";" )
	for(i=0;i<imax;i+=1)	
		tempstring=StringFromList(i, result, ";")	
		KeyWordResult+=StringFromList(0, tempstring,":")+";"						
	endfor											
	return KeyWordResult
end

//**********************************************************************************************
//**********************************************************************************************

Function/T IN2G_GetMeMostLikelyEPICSKey(str)		//this returns the most likely EPICS key - closest to str
	string str
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	str="*"+str+"*"
	String result="", tempstring=""
	Variable pos=0, i=0
	tempstring=IN2G_GetMeListOfEPICSKeys()	
	For (i=0;i<ItemsInList(tempstring);i+=1)
		if (stringmatch(StringFromList(i,tempstring), str ))
			result+=StringFromList(i,tempstring)+";"
		endif
	endfor
	return result
end

//**********************************************************************************************
//**********************************************************************************************

//Function/T IN2G_ReplaceColons(str)	//replaces colons in the string with _
//	string str
//	
//	variable i=0, imax=ItemsInList(str,":")
//	string str2=""
//	
//	For(i=0;i<imax;i+=1)
//		str2+=StringFromList(i, str,":")+"_"
//	endfor
//	return str2
//end

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_AppendListToAllWavesNotes(notetext)	//this function appends or replaces note (key/note) 
	string notetext							//to all waves in the folder
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string ListOfWaves=WaveList("*",";",""), temp
	variable i=0, imax=ItemsInList(ListOfWaves)
	For(i=0;i<imax;i+=1)
		temp=stringFromList(i,listOfWaves)
		IN2G_AppendListToWaveNote(temp,Notetext)
	endfor
end

Function IN2G_AppendListToWaveNote(WaveNm,NewValue)		//this will replace or append new Keyword-list note to wave
	string WaveNm, NewValue
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Wave Wv=$WaveNm
	string Wnote=note(Wv)
	Wnote=NewValue				
	Note /K Wv
	Note Wv, Wnote
end


Function IN2G_AddListToWaveNote(WaveNm,NewValue)		//this will replace or append new Keyword-list note to wave
	string WaveNm, NewValue
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Wave Wv=$WaveNm
	string Wnote=note(Wv)
	Wnote+=NewValue				//fix 2008/08 changed to add new note, not kill it... 
	Note /K Wv
	Note Wv, Wnote
end

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_AppendNoteToListOfWaves(ListOfWaveNames, Key,notetext)	//this function appends or replaces note (key/note) 
	string ListOfWaveNames, Key, notetext							//to ListOfWaveNames waves in the folder
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string ListOfWaves=ListOfWaveNames, temp
	variable i=0, imax=ItemsInList(ListOfWaves)
	For(i=0;i<imax;i+=1)
		temp=stringFromList(i,listOfWaves)
		IN2G_AppendorReplaceWaveNote(temp,Key,Notetext)
	endfor
end

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_AppendNoteToAllWaves(Key,notetext)	//this function appends or replaces note (key/note) 
	string Key, notetext							//to all waves in the folder
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string ListOfWaves=WaveList("*",";",""), temp
	variable i=0, imax=ItemsInList(ListOfWaves)
	For(i=0;i<imax;i+=1)
		temp=stringFromList(i,listOfWaves)
		IN2G_AppendorReplaceWaveNote(temp,Key,Notetext)
	endfor
end

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_AppendorReplaceWaveNote(WaveNm,KeyWrd,NewValue)		//this will replace or append new Keyword-list note to wave
	string WaveNm, KeyWrd, NewValue
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Wave/Z Wv=$WaveNm
	if(WaveExists(Wv))
		string Wnote=note(Wv)
		Wnote=ReplaceStringByKey(KeyWrd, Wnote, NewValue,"=")
		Note /K Wv
		Note Wv, Wnote
	endif
end

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_AppendStringToWaveNote(WaveNm,Str)		//this will append new string with Keyword-list note to wave
	string WaveNm, Str
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Wave Wv=$WaveNm
	string Wnote=note(Wv)
	string tempCombo
	string tempKey
	string tempVal
	variable i=0, imax=ItemsInList(Str,";")
	For (i=0;i<imax;i+=1)
		tempCombo=StringFromList(i,Str,";")
		tempKey=StringFromList(0,tempCombo,"=")
		tempVal=StringFromList(1,tempCombo,"=")
		Wnote=ReplaceStringByKey(TempKey, Wnote, tempVal,"=")
	endfor
	Note /K Wv
	Note Wv, Wnote
end

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_AutoAlignGraphAndPanel()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string GraphName=Winname(0,1)
	string PanelName=WinName(0,64)
	AutopositionWindow/M=0 /R=$GraphName $PanelName
end

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_AutoAlignPanelAndGraph()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string GraphName=Winname(0,1)
	string PanelName=WinName(0,64)
	AutopositionWindow/M=0 /R=$PanelName $GraphName 
end


//**********************************************************************************************
//**********************************************************************************************

Function IN2G_CleanupFolderOfWaves()		//cleans waves from fit_ and W_ waves

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string ListOfWaves=WaveList("W_*",";","")+WaveList("fit_*",";",""), temp
	variable i=0, imax=ItemsInList(ListOfWaves)
	For(i=0;i<imax;i+=1)
		temp=StringFromList(i,ListOfWaves)
		KillWaves/Z $temp
	endfor
end


//**********************************************************************************************
//**********************************************************************************************

Function/S IN2G_FixTheFileName()		//this will not work so simple, we need to remove symbols not allowed in operating systems
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string filename=GetDataFolder(1)
	SVAR SourceSPECDataFile=SpecSourceFileName
	SVAR specDefaultFile=root:specDefaultFile
	filename=RemoveFromList("root",filename,":")
	variable bla=ItemsInList(filename,":"), i=0
	string fixedfilename=StringFromList (0, SourceSPECDataFile, ".")
	Do 
		fixedfilename=fixedfilename +"_"+StringFromList(i, filename, ":")
		i=i+1
	while (i<bla)
	return fixedfilename
end

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_KillAllGraphsAndTables(ctrlname) :Buttoncontrol
//      this function kills (without saving) all existing
//      graphs, tables, and layouts.  It returns the number
//      of windows that were killed (if you are interested).
//      So you can use it as:
//              print KillGraphsAndTables()
//      or just,
//              KillGraphsAndTables()
	string ctrlname
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
        	
	if (strlen(WinList("UPD control",";","WIN:64"))>0)		//Kills the controls when not needed anymore
			KillWIndow/Z PDcontrols
	endif

        String wName=WinName(0, 71)              // 1=graphs, 2=tables,4=layouts, 64=panels = 71
        Variable n=0
        if (strlen(wName)<1)
                return n
        endif
        do
                dowindow /K $wName
                n += 1
                wName=WinName(0, 7)
        while (strlen(wName)>0)
        return n
End

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_KillGraphsAndTables(ctrlname) :Buttoncontrol
	string ctrlname
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
      String wName=WinName(0, 1)              // 1=graphs, 2=tables,4=layouts
                dowindow /K $wName
	if (strlen(WinList("IN2A_UPDControlPanel",";","WIN:64"))>0)	//Kills the controls when not needed anymore
			KillWIndow/Z  IN2A_UPDControlPanel
	endif
End


Function IN2G_KillGraphsTablesEnd(ctrlname) :Buttoncontrol
	string ctrlname
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
      String wName=WinName(0, 1)              // 1=graphs, 2=tables,4=layouts
                dowindow /K $wName
	if (strlen(WinList("IN2A_UPDControlPanel",";","WIN:64"))>0)	//Kills the controls when not needed anymore
			KillWIndow/Z  IN2A_UPDControlPanel
	endif
       abort
End

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_KillTopGraph(ctrlname) :Buttoncontrol
	string ctrlname
       String wName=WinName(0, 1)              // 1=graphs, 2=tables,4=layouts

		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
       dowindow /K $wName
End

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_KillWavesFromList(WvList)
	string WvList
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable items=ItemsInList(WvList), i
	For (i=0;i<items;i+=1)
		KillWaves/Z $(StringFromList(i, WvList))
	endfor
end
//**********************************************************************************************
//**********************************************************************************************

Proc IN2G_BasicGraphStyle()
	PauseUpdate; Silent 1		// modifying window...
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	ModifyGraph/Z margin(top)=100
	ModifyGraph/Z mode=4, gaps=0
	ModifyGraph/Z zColor[0]={PD_range,0,10,Rainbow}
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Times New Roman"
	ModifyGraph/Z minor=1
	ModifyGraph/Z fSize=12
	Label/Z left "Intensity"
	Label/Z bottom "Ar encoder"
	Duplicate/O PD_range, root:Packages:Indra3:MyColorWave							//creates new color wave
	IN2G_MakeMyColors(PD_range,root:Packages:Indra3:MyColorWave)						//creates colors in it
 	ModifyGraph mode=4, zColor={root:Packages:Indra3:MyColorWave,0,10,Rainbow}, margin(top)=100, mirror=1, minor=1
	showinfo												//shows info
	ShowTools/A											//show tools
	Button KillThisWindow pos={10,10}, size={100,25}, title="Kill window", proc=IN2G_KillGraphsTablesEnd
	Button ResetWindow pos={10,40}, size={100,25}, title="Reset window", proc=IN2G_ResetGraph
	Button Reverseaxis pos={10,70}, size={100,25}, title="Reverse X axis", proc=IN2G_ReversXAxis
EndMacro

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************


Function IN2G_MakeMyColors(PDrange,NewColors)		//makes color wave for 
 	Wave PDrange, NewColors
 	
 	variable i=0
 	
 	NewColors = (PDrange[p]==1) ? 0   : NewColors[p]
 	NewColors = (PDrange[p]==2) ? 4.5 : NewColors[p]
 	NewColors = (PDrange[p]==3) ? 7.7 : NewColors[p]
 	NewColors = (PDrange[p]==4) ? 1.3 : NewColors[p]
 	NewColors = (PDrange[p]==5) ? 10  : NewColors[p]
 	
// 	Do
// 		if (PDrange[i]==1)		//range 1 color
// 			NewColors[i]=0
//		endif 	
// 		if (PDrange[i]==2)		//range 2 color
// 			NewColors[i]=4.5
//		endif 	
// 		if (PDrange[i]==3)		//range 3 color
// 			NewColors[i]=7.7
//		endif 	
// 		if (PDrange[i]==4)		//range 4 color
// 			NewColors[i]=1.3
//		endif 	
// 		if (PDrange[i]==5)		//range 5 color
// 			NewColors[i]=10
//		endif 	
// 	
// 	i+=1
// 	while(i<numpnts(PDrange)) 	
 end


//**********************************************************************************************
//**********************************************************************************************

Function IN2G_ScreenWidthHeight(what)			//keeps graphs the same size on all screens
	string what
	string temp

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable height
	variable width
	variable TopHeight = 20 //height of top bar and frame, best guess...
	variable ScreenRes = screenresolution/panelresolution("")
	TopHeight = TopHeight *screenresolution/96

	if(stringmatch(IgorInfo(2),"Windows"))
		//For Igor above 7.03 we can get the TopHeight from measureement...
		if(NumberByKey("IGORVERS", IgorInfo(0))>7.02)		//this would crash anything before 7.03
			GetWindow kwCmdHist wsize
			variable SmallHeight = V_bottom-V_top
			GetWindow kwCmdHist wsizeOuter
			variable LargeHeight = V_bottom-V_top
			TopHeight = LargeHeight - SmallHeight 
		endif
		GetWindow kwFrameInner  wsize 
		 height = ((V_bottom - V_top)-TopHeight)* ScreenRes
		 width = (V_right - V_left)*ScreenRes
		if (cmpstr(what,"width")==0)					//gets width of the screen
			return width/100						// /100 needed by graphs which use that value
		endif
		if (cmpstr(what,"height")==0)					//gets height of screen
			return height/100						// /100 needed by graphs which use that value
		endif
	else
		if (cmpstr(what,"width")==0)					//gets width of the screen
			temp= StringByKey("SCREEN1", IgorInfo(0))
			temp=stringFromList(3,  temp,",")
			return str2num(temp)/100						// /100 needed by graphs which use that value
		endif
		if (cmpstr(what,"height")==0)					//gets height of screen
			temp= StringByKey("SCREEN1", IgorInfo(0))
			temp=stringFromList(4,  temp,",")
			return str2num(temp)/100						// /100 needed by graphs which use that value
		endif
	endif
	return NaN
end

//**********************************************************************************************
//**********************************************************************************************
Function IN2G_GetGraphWidthHeight(what)			//keeps graphs the same size on all screens
	string what
	string temp

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable height
	variable width
	variable TempRetVal
	variable TopHeight = 20 //height of top bar and frame, best guess...
	variable ScreenRes = screenresolution/panelresolution("")
	TopHeight = TopHeight *screenresolution/96
	//constant MaxGraphWidthAllowed = 1200
	//constant MaxGraphHeightAllowed = 900
	//FillGraphVerticalRatio
	//FillGraphHorizontalRatio

	if(stringmatch(IgorInfo(2),"Windows"))
		//For Igor above 7.03 we can get the TopHeight from measureement...
		if(NumberByKey("IGORVERS", IgorInfo(0))>7.02)		//this would crash anything before 7.03
			GetWindow kwCmdHist wsize
			variable SmallHeight = V_bottom-V_top
			GetWindow kwCmdHist wsizeOuter
			variable LargeHeight = V_bottom-V_top
			TopHeight = LargeHeight - SmallHeight 
		endif
		GetWindow kwFrameInner  wsize
		 height = ((V_bottom - V_top)-TopHeight)* ScreenRes
		 width = (V_right - V_left)*ScreenRes
		if (cmpstr(what,"width")==0)					//gets width of the screen
			TempRetVal = width
			if(TempRetVal>MaxGraphWidthAllowed)
				TempRetVal = MaxGraphWidthAllowed
			endif
			return (TempRetVal*FillGraphHorizontalRatio/ScreenRes)-TypicalPanelHorizontalSize	
		endif
		if (cmpstr(what,"height")==0)					//gets height of screen
			TempRetVal = height
			if(TempRetVal>MaxGraphHeightAllowed)
				TempRetVal = MaxGraphHeightAllowed
			endif
			return TempRetVal* FillGraphVerticalRatio/ScreenRes
		endif
	else
		if (cmpstr(what,"width")==0)					//gets width of the screen
			temp= StringByKey("SCREEN1", IgorInfo(0))
			temp=stringFromList(3,  temp,",")
			//return str2num(temp)/100						// /100 needed by graphs which use that value
			TempRetVal = str2num(temp)
			if(TempRetVal>MaxGraphWidthAllowed)
				TempRetVal = MaxGraphWidthAllowed
			endif
			return (TempRetVal*FillGraphHorizontalRatio)-TypicalPanelHorizontalSize
		endif
		if (cmpstr(what,"height")==0)					//gets height of screen
			temp= StringByKey("SCREEN1", IgorInfo(0))
			temp=stringFromList(4,  temp,",")
			TempRetVal = str2num(temp)
			if(TempRetVal>MaxGraphHeightAllowed)
				TempRetVal = MaxGraphHeightAllowed
			endif
			return TempRetVal*FillGraphVerticalRatio
		endif
	endif
	return NaN
end


//**********************************************************************************************
//**********************************************************************************************
Function IN2G_SetPointWithCsrAToNaN(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable pointNumberToBeRemoved=xcsr(A)				//this part should be done always
		Wave FixMe=CsrWaveRef(A)
		FixMe[pointNumberToBeRemoved]=NaN
																//if we need to fix more waves, it can be done here
		cursor/P A, $CsrWave(A), pointNumberToBeRemoved+1		//set the cursor to the right so we do not scare user
End

Function IN2G_SetPointsBetweenCsrsToNaN(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable pointNumberStart=xcsr(A)				//this part should be done always
	variable pointNumberEnd=xcsr(B)	
		Wave FixMe=CsrWaveRef(A)
		if (pointNumberStart<pointNumberEnd)
			FixMe[pointNumberStart, pointNumberEnd]=NaN
		else
			FixMe[pointNumberEnd,pointNumberStart]=NaN
		endif													//if we need to fix more waves, it can be done here
		cursor/P B, $CsrWave(B), pointNumberEnd+1
		cursor/P A, $CsrWave(A), pointNumberStart-1		//set the cursor to the right so we do not scare user
End

Function IN2G_SetPointsSmallerCsrAToNaN(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable pointNumberToBeRemoved=xcsr(A)				//this part should be done always
		Wave FixMe=CsrWaveRef(A)
		FixMe[0, pointNumberToBeRemoved]=NaN
																//if we need to fix more waves, it can be done here
		cursor/P A, $CsrWave(A), pointNumberToBeRemoved+1		//set the cursor to the right so we do not scare user
End

Function IN2G_SetPointsLargerCsrBToNaN(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable pointNumberToBeRemoved=xcsr(B)				//this part should be done always
		Wave FixMe=CsrWaveRef(B)
		FixMe[pointNumberToBeRemoved, numpnts(FixMe)-1]=NaN
																//if we need to fix more waves, it can be done here
		cursor/P B, $CsrWave(B), pointNumberToBeRemoved-1		//set the cursor to the right so we do not scare user
End


Function IN2G_RemovePointWithCursorA(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if (strlen(CsrWave(A))==0)
		Abort "cursor A is not in the graph...nothing to do..."
	endif
	variable pointNumberToBeRemoved=xcsr(A)
	if (strlen(CsrWave(B))!=0)
//		if (cmpstr("RemovePointDSM",ctrlname)!=0)
			DoAlert 0, "Remove cursor B [square] before proceeding"
			//Abort
//		endif
	else
				//this part should be done always
		Wave FixMe=CsrWaveRef(A)
		FixMe[pointNumberToBeRemoved]=NaN
				//if we need to fix more waves, it can be done here

		if (cmpstr(ctrlname,"RemovePointR")==0)				//This is from R wave creation, set PD_intensity to NaN test for ctrlname (where we call you from?)
			Wave USAXS_PD 								//here fix other waves
			USAXS_PD[pointNumberToBeRemoved]=NaN
		endif
		cursor/P A, $CsrWave(A), pointNumberToBeRemoved+1		//set the cursor to the right so we do not scare user
	endif
End

//**********************************************************************************************
//**********************************************************************************************

//Function/T IN2G_ReplaceOrChangeList(MyList,KeyWrd,NewValue)		//this will replace or append new Keyword-list combo to MyList
//	string MyList, KeyWrd, NewValue
//	if (stringmatch(MyList, "*;"+KeyWrd+":*" ))
//		MyList=ReplaceStringByKey(KeyWrd, MyList, Newvalue  , ":"  , "=")	//key exists, replace
//	else
//		MyList+=KeyWrd+":"+NewValue+";"								//key does not exist, append
//	endif
//	return MyList
//end

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_ResetGraph(ctrlname) : Buttoncontrol
	string ctrlname
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		SetAxis/A										//rescales graph to automatic scaling
End

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_ReversXAxis(ctrlname) : Buttoncontrol
	string ctrlname
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SetAxis/A/R bottom									//reverse X axis
End

//**********************************************************************************************
//**********************************************************************************************

//Function/T IN2G_AppendOrReplaceList(List,Key,Value,sep)	//replace or append to list
//	string List, Key, Value,sep
//	if (stringmatch(List, "*"+Key+"*" ))		//Lets fix the ASBParameters in Packages/USAXS 
//		List=ReplaceStringByKey(Key, List, Value, sep, ";")		//key exists, replace
//	else
//		List+=Key+sep+Value+";"										//key does not exist, append
//	endif
//	return List
//	
//end

//**********************************************************************************************
//**********************************************************************************************

Function/S IN2G_FindFolderWithWvTpsList(startDF, levels, WaveTypes, LongShortType)
        String startDF, WaveTypes                  // startDF requires trailing colon.
        Variable levels, LongShortType		//set 1 for long type and 0 for short type return
        			//returns the list of folders with specCommand with "uascan" in it - may not work yet for sbuascan 
        String dfSave
        String list = "", templist, tempWvName, tempWaveType
        variable i, skipRest, j
			IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	        
        dfSave = GetDataFolder(1)
  	
  	if (!DataFolderExists(startDF))
  		return ""
  	endif
  	
        SetDataFolder startDF
        
       // templist = DataFolderDir(0)
        templist = DataFolderDir(1)
        skipRest=0
        string AllWaves = ";"+WaveList("*",";","")
//	For(i=0;i<ItemsInList(WaveList("*",";",""));i+=1)
//		tempWvName = StringFromList(i, WaveList("*",";","") ,";")
//	 //   	 if (Stringmatch(WaveList("*",";",""),WaveTypes))
		For(j=0;j<ItemsInList(WaveTypes);j+=1)

			if(skipRest || strlen(AllWaves)<2)
				//nothing needs to be done
			else
				tempWaveType = stringFromList(j,WaveTypes)
			    	 if (Stringmatch(AllWaves,"*;"+tempWaveType+";*") && skipRest==0)
					if (LongShortType)
				            		list += startDF + ";"
							skipRest=1
				      	else
			     		      		list += GetDataFolder(0) + ";"
		      					skipRest=1
			      		endif
		        	endif
		      //  endfor
	        endif
   	     endfor
        levels -= 1
        if (levels <= 0)
                return list
        endif
        
        String subDF
        Variable index = 0
        do
                String temp
                temp = PossiblyQuoteName(GetIndexedObjName(startDF, 4, index))     	// Name of next data folder.
                if (strlen(temp) == 0)
                        break                                                                           			// No more data folders.
                endif
     	              subDF = startDF + temp + ":"
            		 list += IN2G_FindFolderWithWvTpsList(subDF, levels, WaveTypes, LongShortType)       	// Recurse.
                index += 1
        while(1)
        
        SetDataFolder(dfSave)
        return list
End
//**********************************************************************************************
//**********************************************************************************************

Function/S IN2G_FindFolderWithWaveTypes(startDF, levels, WaveTypes, LongShortType)
        String startDF, WaveTypes                  // startDF requires trailing colon.
        Variable levels, LongShortType		//set 1 for long type and 0 for short type return
        //12/18/2010, JIL, trying to speed this up and fix this... 
        //Empty folders shoudl be skipped. If mask string is "*", then any non-empty folder should be included... 
        			 
			IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
        String dfSave
        String list = "", templist, tempWvName, TempWvList
        variable i, skipRest
        
        dfSave = GetDataFolder(1)
  	
		  	if (!DataFolderExists(startDF))
		  		return ""
		  	endif
  	
        SetDataFolder startDF
        
        //templist = DataFolderDir(0)
        templist = DataFolderDir(1)
        skipRest=0
		 	//first treat the empty folders... 
		 	string AllWaves=WaveList("*",";","")
	 		if(strlen(AllWaves)>0 && cmpstr(WaveTypes,"*")==0)  //if the folder is NOT empty and matchstr="*", then we need to include this folder... 
	 			if (LongShortType)
		            		list += startDF + ";"
					skipRest=1
		      	else
	     		      	list += GetDataFolder(0) + ";"
	      				skipRest=1
	      		endif	
		 	elseif(strlen(AllWaves)>0)									//folder not empty, but need to test match strings... 
			  TempWvList = 	WaveList(WaveTypes,";","")
			  For(i=0;i<ItemsInList(TempWvList);i+=1)
					tempWvName = StringFromList(i, TempWvList ,";")
					if (Stringmatch(tempWvName,WaveTypes))
						if (LongShortType)
					           	list += startDF + ";"
									break
					      	else
				     		      list += GetDataFolder(0) + ";"
			      				break
				      		endif
			        	endif
			        //	endif
		        endfor
		 else		//folder empty, nothing to do...
		 
	 	 endif
 
        levels -= 1
        if (levels <= 0)
                return list
        endif
        
        String subDF
        Variable index = 0
        do
                String temp
                temp = PossiblyQuoteName(GetIndexedObjName(startDF, 4, index))     	// Name of next data folder.
                if (strlen(temp) == 0)
                        break                                                                           			// No more data folders.
                endif
     	              subDF = startDF + temp + ":"
            		 list += IN2G_FindFolderWithWaveTypes(subDF, levels, WaveTypes, LongShortType)       	// Recurse.
                index += 1
        while(1)
        
        SetDataFolder(dfSave)
        return list
End
//**********************************************************************************************
//**********************************************************************************************

Function/S IN2G_NewFindFolderWithWaveTypes(startDF, levels, WaveTypes, LongShortType)
        String startDF, WaveTypes                  // startDF requires trailing colon.
        Variable levels, LongShortType		//set 1 for long type and 0 for short type return
        			 
        String dfSave
        String list = "", templist, tempWvName
        variable i, skipRest
        
			IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
        dfSave = GetDataFolder(1)
  	if (!DataFolderExists(startDF))
  		return ""
  	endif
  	
        SetDataFolder startDF
        
        //templist = DataFolderDir(0)
        templist = DataFolderDir(1)
 //		new method?
 		if (Stringmatch(WaveList("*",";",""),WaveTypes))
			if (LongShortType)
		      		if(!stringmatch(startDf, "*:Packages*" ))		
		            		list += startDF + ";"
	     		      	endif
		      	else
	     		      		list += GetDataFolder(0) + ";"
	      		endif
        	endif

 
        levels -= 1
        if (levels <= 0)
                return list
        endif
        
        String subDF
        Variable index = 0
        do
                String temp
                temp = PossiblyQuoteName(GetIndexedObjName(startDF, 4, index))     	// Name of next data folder.
                if (strlen(temp) == 0)
                        break                                                                           			// No more data folders.
                endif
     	              subDF = startDF + temp + ":"
            		 list += IN2G_NewFindFolderWithWaveTypes(subDF, levels, WaveTypes, LongShortType)       	// Recurse.
                index += 1
        while(1)
        
        SetDataFolder(dfSave)
        return list
End

//**********************************************************************************************
//**********************************************************************************************
Function IN2G_RemoveNaNsFrom3Waves(Wv1,wv2,wv3)							//removes NaNs from 3 waves
	Wave Wv1, Wv2, Wv3					//assume same number of points in the waves
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i=0, imax=numpnts(Wv1)-1
	for (i=imax;i>=0;i-=1)
		if (numtype(Wv1[i])==2 || numtype(Wv2[i])==2 || numtype(Wv3[i])==2)
			Deletepoints i, 1, Wv1, Wv2, Wv3
		endif
	endfor
end
//**********************************************************************************************
//**********************************************************************************************
Function IN2G_RemoveNaNsFrom2Waves(Wv1,wv2)							//removes NaNs from 3 waves
	Wave Wv1, Wv2					//assume same number of points in the waves
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i=0, imax=numpnts(Wv1)-1
	for (i=imax;i>=0;i-=1)
		if (numtype(Wv1[i])==2 || numtype(Wv2[i])==2)
			Deletepoints i, 1, Wv1, Wv2
		endif
	endfor
end
//**********************************************************************************************
//**********************************************************************************************
Function IN2G_RemoveNaNsFrom1Wave(Wv1)							//removes NaNs from 3 waves
	Wave Wv1				//assume same number of points in the waves
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i=0, imax=numpnts(Wv1)-1
	for (i=imax;i>=0;i-=1)
		if (numtype(Wv1[i])==2)
			Deletepoints i, 1, Wv1
		endif
	endfor
end
//**********************************************************************************************
//**********************************************************************************************
Function IN2G_RemoveNaNsFrom5Waves(Wv1,wv2,wv3,wv4,wv5)		//removes NaNs from 5 waves
	Wave Wv1, Wv2, Wv3, wv4,wv5					//assume same number of points in the waves
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i=0, imax=numpnts(Wv1)-1
	for (i=imax;i>=0;i-=1)
		if (numtype(Wv1[i])==2 || numtype(Wv2[i])==2 || numtype(Wv3[i])==2 || numtype(Wv4[i])==2 || numtype(Wv5[i])==2)
			Deletepoints i, 1, Wv1, Wv2, Wv3,wv4,wv5
		endif
	endfor
end
//**********************************************************************************************
//**********************************************************************************************
Function IN2G_RemoveNaNsFrom6Waves(Wv1,wv2,wv3,wv4,wv5,wv6)		//removes NaNs from 6 waves
	Wave Wv1, Wv2, Wv3, wv4,wv5, wv6					//assume same number of points in the waves
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i=0, imax=numpnts(Wv1)-1
	for (i=imax;i>=0;i-=1)
		if (numtype(Wv1[i])==2 || numtype(Wv2[i])==2 || numtype(Wv3[i])==2 || numtype(Wv4[i])==2 || numtype(Wv5[i])==2 || numtype(Wv6[i])==2)
			Deletepoints i, 1, Wv1, Wv2, Wv3,wv4,wv5, wv6
		endif
	endfor
end
//**********************************************************************************************
//**********************************************************************************************
Function IN2G_RemoveNaNsFrom7Waves(Wv1,wv2,wv3,wv4,wv5,wv6, wv7)		//removes NaNs from 6 waves
	Wave Wv1, Wv2, Wv3, wv4,wv5, wv6	, wv7				//assume same number of points in the waves
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i=0, imax=numpnts(Wv1)-1
	for (i=imax;i>=0;i-=1)
		if (numtype(Wv1[i])==2 || numtype(Wv2[i])==2 || numtype(Wv3[i])==2 || numtype(Wv4[i])==2 || numtype(Wv5[i])==2 || numtype(Wv6[i])==2 || numtype(Wv7[i])==2)
			Deletepoints i, 1, Wv1, Wv2, Wv3,wv4,wv5, wv6, wv7
		endif
	endfor
end
//**********************************************************************************************
//**********************************************************************************************
Function IN2G_RemoveNaNsFrom10Waves(Wv1,wv2,wv3,wv4,wv5,wv6, wv7, wv8, wv9, wv10)		//removes NaNs from 6 waves
	Wave Wv1, Wv2, Wv3, wv4,wv5, wv6	, wv7, wv8, wv9, wv10				//assume same number of points in the waves
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i=0, imax=numpnts(Wv1)-1
	for (i=imax;i>=0;i-=1)
		if (numtype(Wv1[i])==2 || numtype(Wv2[i])==2 || numtype(Wv3[i])==2 || numtype(Wv4[i])==2 || numtype(Wv5[i])==2 || numtype(Wv6[i])==2 || numtype(Wv7[i])==2 || numtype(Wv8[i])==2 || numtype(Wv9[i])==2 || numtype(Wv10[i])==2)
			Deletepoints i, 1, Wv1, Wv2, Wv3,wv4,wv5, wv6, wv7, wv8, wv9, wv10	
		endif
	endfor
end
//**********************************************************************************************
//**********************************************************************************************
Function IN2G_RemoveNaNsFrom4Waves(Wv1,wv2,wv3,wv4)		//removes NaNs from 4 waves
	Wave Wv1, Wv2, Wv3, wv4				//assume same number of points in the waves
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i=0, imax=numpnts(Wv1)-1
	for (i=imax;i>=0;i-=1)
		if (numtype(Wv1[i])==2 || numtype(Wv2[i])==2 || numtype(Wv3[i])==2 || numtype(Wv4[i])==2)
			Deletepoints i, 1, Wv1, Wv2, Wv3,wv4
		endif
	endfor
end
//**********************************************************************************************
//**********************************************************************************************
Function IN2G_RemNaNsFromAWave(Wv1)	//removes NaNs from 1 wave
	Wave Wv1			//assume same number of points in the waves
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i=0, imax=numpnts(Wv1)-1
	for (i=imax;i>=0;i-=1)
		if (numtype(Wv1[i])==2)
			Deletepoints i, 1, Wv1
		endif
	endfor
end
//**********************************************************************************************
//**********************************************************************************************
Function IN2G_LogInterpolateIntensity(NewQ,NewIntensity, OldQ,Intensity)		//Interrpolate Intensity on log scale
	Wave NewQ,NewIntensity,OldQ,Intensity			//assume same number of points in the waves
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Duplicate/Free Intensity,TmpInt
	wavestats/Q TmpInt
	variable Offset
	if(V_min<1e-30)
		Offset=3*abs(V_min)
	else
		Offset = 0
	endif
	TmpInt = TmpInt[p]+Offset
	TmpInt = log(TmpInt)
	NewIntensity = interp(NewQ,OldQ, TmpInt)
	NewIntensity = 10^NewIntensity
	NewIntensity = NewIntensity[p]-Offset
end
	
//**********************************************************************************************
//**********************************************************************************************

Function IN2G_ReplaceNegValsByNaNWaves(Wv1,wv2,wv3)			//replaces Negative values in 3 waves by NaNs 
	Wave Wv1, Wv2, Wv3					//assume same number of points in the waves
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i=0, imax=numpnts(Wv1)-1
	for (i=imax;i>=0;i-=1)
		if (Wv1[i]<0 || Wv2[i]<0 || Wv3[i]<0)
			Deletepoints i, 1, Wv1, Wv2, Wv3
		endif
	endfor
end

//************************************************************************************************************************
//************************************************************************************************************************
Function/S IN2G_ReturnUnitsForYAxis(Ywave)
	wave Ywave
	//this function creates string with units for Y wave for graphs. Uses units string in wave note, if exists
	string OldNote=note(Ywave)
	string Yunits=""
	if(stringmatch(nameofWave(Ywave),"*Intensity*"))
		Yunits = "cm\\S-1\\M"			//this is default for intensity
	endif
	if(strlen(StringByKey("Units", OldNote,"="))>0)			//we have units string
		strswitch(StringByKey("Units", OldNote,"="))			// string switch
			case "cm2/g":			// execute if case matches expression
				Yunits = "cm\\S2\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"/g\\M"
				break		// exit from switch
			case "cm2/cm3":			// execute if case matches expression
				Yunits = "cm\\S2\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"/cm\\S3\\M"
				break					// exit from switch
			default:					// optional default expression executed
				Yunits = "Arbitrary"
		endswitch
		
	endif
	return Yunits
end
//************************************************************************************************************************
//************************************************************************************************************************

Function IN2G_GenerateLegendForGraph(fntsize,WNoteName,RemoveRepeated)  //generates legend for graphs and kills the old one, fntsize is font size
	variable fntsize, WNoteName, RemoveRepeated							//WNoteName=1 use name from Wname  key in Wave Note
			//finds name of the old legend and generates new one with the same name, if the legend does not exists
			//it cretaes new one with name legend1
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable NumberOfWaves=ItemsInList(TraceNameList("",";",1))
	if (NumberOfWaves==0)
		return 0
	endif
	variable i=0, HashPosition=-1
	string LegendName=""
	if (strsearch(Winrecreation("",0),"Legend/N=",0)<1)
		LegendName="Legend1"
	else
		LegendName=WinRecreation("",0)[strsearch(Winrecreation("",0),"Legend/N=",0)+9, strsearch(WinRecreation("",0),"Legend/N=",0)+25]
		LegendName=StringFromList(0,LegendName, "/")
	endif
	string fntsizeStr
	if (fntsize<10)
		fntsizeStr="0"+num2str(fntsize)
	else
		fntsizeStr=num2str(fntsize)
	endif
	variable repeated=0
	string NewLegend=""
#if Exists("IN2G_LkUpDfltStr")
	NewLegend ="\\F"+IN2G_LkUpDfltStr("FontType")
#endif	
	NewLegend +="\\Z"+fntsizeStr
	
	Do
		HashPosition=strsearch(stringFromList(i,TraceNameList("",";",1)),"#   ",0)
//		if (RemoveRepeated)
//			if (HashPosition>0)
//				repeated=1
//			endif
//		endif	
//		if (!repeated)
			NewLegend+="\\s("+stringFromList(i,TraceNameList("",";",1))+")\t"
			if (WNoteName)
				NewLegend+=StringByKey("Wname", note(WaveRefIndexed("",i,1)),"=")
			else
				if (HashPosition>=0)
					NewLegend+=stringFromList(i,TraceNameList("",";",1))[0,HashPosition-1]
				else
					NewLegend+=stringFromList(i,TraceNameList("",";",1))	
				endif
			endif 
			NewLegend+="   "+StringByKey("UserSampleName", note(WaveRefIndexed("",i,1)),"=")
			NewLegend+="  Units:  "+StringByKey("Units", note(WaveRefIndexed("",i,1)),"=")
		i+=1
			if (i<NumberOfWaves)
				NewLegend+="\r"
			endif
//		endif
	while (i<NumberOfWaves)
	
	Legend/N=$LegendName/K
	Legend/J/N=$LegendName/J/S=3/A=LB/F=0/B=1 NewLegend
end

//*************************************************************************************************
//*************************************************************************************************


Function IN2G_WriteSetOfData(which)		//this procedure saves selected data from current folder
	string which
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	
//	Proc ExportDSMWaves()
	if (cmpstr(which,"DSM")==0)
		filename1 = filename+".dsm"
		if (exists("DSM_Int")==1)
				Wave DSM_Qvec
				Wave DSM_Int
				Wave DSM_Error
				Duplicate/O DSM_Qvec, Exp_Qvec
				Duplicate/O DSM_Int, Exp_Int
				Duplicate/O DSM_Error, Exp_Error
				IN2G_TrimExportWaves(Exp_Qvec,Exp_Int, Exp_Error)
			
			IN2G_PasteWnoteToWave("DSM_Int", WaveNoteWave,"#   ")
			if (cmpstr(IncludeData,"within")==0)
				Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave,Exp_Qvec,Exp_Int, Exp_Error as filename1
//				Save/A/G/M="\r\n"/P=ExportDatapath Exp_Qvec,Exp_Int, Exp_Error as filename1				///P=Datapath
			else
				Save/I/G/M="\r\n"/P=ExportDatapath Exp_Qvec,Exp_Int, Exp_Error as filename1				///P=Datapath			
				filename1 = filename1[0, strlen(filename1)-5]+"_dsm.txt"											//here we include description of the 
				Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
			endif		
		endif
	endif
//	Proc ExportBKGWaves()
	if (cmpstr(which,"BKG")==0)
		filename1 = filename+".bkg"
		if (exists("BKG_Int")==1)
				Wave BKG_Qvec
				Wave BKG_Int
				Wave BKG_Error
				Duplicate/O BKG_Qvec, Exp_Qvec
				Duplicate/O BKG_Int, Exp_Int
				Duplicate/O BKG_Error, Exp_Error
				IN2G_TrimExportWaves(Exp_Qvec,Exp_Int, Exp_Error)
			
			IN2G_PasteWnoteToWave("BKG_Int", WaveNoteWave,"#   ")
			if (cmpstr(IncludeData,"within")==0)
				Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave,Exp_Qvec,Exp_Int, Exp_Error as filename1
			else
				Save/I/G/M="\r\n"/P=ExportDatapath Exp_Qvec,Exp_Int, Exp_Error as filename1				///P=Datapath			
				filename1 = filename1[0, strlen(filename1)-5]+"_bkg.txt"											//here we include description of the 
				Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
			endif		
		endif
	endif
//	Proc ExportM_BKGWaves()
	if (cmpstr(which,"M_BKG")==0)
		filename1 = filename+"_m.bkg"
		if (exists("BKG_Int")==1)
				Wave M_BKG_Qvec
				Wave M_BKG_Int
				Wave M_BKG_Error
				Duplicate/O M_BKG_Qvec, Exp_Qvec
				Duplicate/O M_BKG_Int, Exp_Int
				Duplicate/O M_BKG_Error, Exp_Error
				IN2G_TrimExportWaves(Exp_Qvec,Exp_Int, Exp_Error)
			
			IN2G_PasteWnoteToWave("M_BKG_Int", WaveNoteWave,"#   ")
			if (cmpstr(IncludeData,"within")==0)
				Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave,Exp_Qvec,Exp_Int, Exp_Error as filename1
			else
				Save/I/G/M="\r\n"/P=ExportDatapath Exp_Qvec,Exp_Int, Exp_Error as filename1				///P=Datapath			
				filename1 = filename1[0, strlen(filename1)-5]+"_mbkg.txt"											//here we include description of the 
				Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
			endif		
		endif
	endif
	
//	Proc ExportSMRWaves()
	if (cmpstr(which,"SMR")==0)
		filename1 = filename+".smr"
		if (exists("SMR_Int")==1)
				Wave SMR_Qvec
				Wave SMR_Int
				Wave SMR_Error
				Duplicate/O SMR_Qvec, Exp_Qvec
				Duplicate/O SMR_Int, Exp_Int
				Duplicate/O SMR_Error, Exp_Error
				IN2G_TrimExportWaves(Exp_Qvec,Exp_Int, Exp_Error)
		
			IN2G_PasteWnoteToWave("SMR_Int", WaveNoteWave,"#   ")
			if (cmpstr(IncludeData,"within")==0)
				Save/I/G/M="\r\n" /P=ExportDatapath WaveNoteWave,Exp_Qvec,Exp_Int, Exp_Error as filename1
//				Save/A/G/M="\r\n"/P=ExportDatapath Exp_Qvec,Exp_Int, Exp_Error as filename1				///P=Datapath
			else
				Save/I/G/M="\r\n"/P=ExportDatapath Exp_Qvec,Exp_Int, Exp_Error as filename1				///P=Datapath
				filename1 = filename1[0, strlen(filename1)-5]+"_smr.txt"											//here we include description of the 
				Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
			endif	
		endif
	endif

//	Proc ExportM_SMRWaves()
	if (cmpstr(which,"M_SMR")==0)
		filename1 = filename+"_m.smr"
		if (exists("M_SMR_Int")==1)
				Wave SMR_Qvec
				Wave M_SMR_Int
				Wave M_SMR_Error
				Duplicate/O SMR_Qvec, Exp_Qvec
				Duplicate/O M_SMR_Int, Exp_Int
				Duplicate/O M_SMR_Error, Exp_Error
				IN2G_TrimExportWaves(Exp_Qvec,Exp_Int, Exp_Error)

			IN2G_PasteWnoteToWave("M_SMR_Int", WaveNoteWave,"#   ")
			if (cmpstr(IncludeData,"within")==0)
				Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave,Exp_Qvec,Exp_Int, Exp_Error  as filename1
//				Save/A/G/M="\r\n"/P=ExportDatapath Exp_Qvec,Exp_Int, Exp_Error as filename1				///P=Datapath		
			else
				Save/I/G/M="\r\n"/P=ExportDatapath Exp_Qvec,Exp_Int, Exp_Error as filename1				///P=Datapath		
				filename1 = filename1[0, strlen(filename1)-5]+"_msmr.txt"											//here we include description of the 
				Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
			endif
		endif
	endif
	
//	Proc ExportM_DSMWaves()
	if (cmpstr(which,"M_DSM")==0)
		filename1 = filename+"_m.dsm"
		if (exists("M_DSM_Int")==1)
				Wave M_DSM_Qvec
				Wave M_DSM_Int
				Wave M_DSM_Error
				Duplicate/O M_DSM_Qvec, Exp_Qvec
				Duplicate/O M_DSM_Int, Exp_Int
				Duplicate/O M_DSM_Error, Exp_Error
				IN2G_TrimExportWaves(Exp_Qvec,Exp_Int, Exp_Error)

			IN2G_PasteWnoteToWave("M_DSM_Int", WaveNoteWave,"#   ")
			if (cmpstr(IncludeData,"within")==0)
				Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave,Exp_Qvec,Exp_Int, Exp_Error  as filename1
//				Save/G/M="\r\n"/P=ExportDatapath Exp_Qvec,Exp_Int, Exp_Error as filename1				///P=Datapath	
			else
				Save/I/G/M="\r\n"/P=ExportDatapath Exp_Qvec,Exp_Int, Exp_Error as filename1				///P=Datapath	
				filename1 = filename1[0, strlen(filename1)-5]+"_mdsm.txt"											//here we include description of the 
				Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
			endif
			
		endif
	endif
		
//	Proc ExportRWaves()
	if (cmpstr(which,"R")==0)
		filename1 = filename+".R"
		if (exists("R_Int")==1)
			Wave Qvec
			Wave R_Int
			Wave R_Error
			IN2G_PasteWnoteToWave("R_Int", WaveNoteWave,"#   ")
			if (cmpstr(IncludeData,"within")==0)
				Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave, Qvec, R_Int, R_Error  as filename1
//				Save/A/G/M="\r\n"/P=ExportDatapath Qvec,R_Int,R_error as filename1			///P=Datapath
			else
				Save/I/G/M="\r\n"/P=ExportDatapath Qvec,R_Int,R_error as filename1			///P=Datapath
				filename1 = filename1[0, strlen(filename1)-3]+"_R.txt"											//here we include description of the 
				Save/I/G/M="\r\n"/P=ExportDatapath WaveNoteWave as filename1		//samples with this name
			endif
		endif
	endif
	
	KillWaves/Z WaveNoteWave, Exp_Qvec, Exp_Int, Exp_Error
end

Function/S IN2G_FixTheFileName2()
	WAVE USAXS_PD
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if (WaveExists(USAXS_PD))
		string SourceSPECDataFile=stringByKey("DATAFILE",Note(USAXS_PD),"=")
		string intermediatename=StringFromList (0, SourceSPECDataFile, ".")+"_"+GetDataFolder(0)
		return IN2G_ZapControlCodes(intermediatename)
	else
		return "noname"
	endif
end

Function/T IN2G_ZapControlCodes(str)
	String str
	Variable i = 0
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	do
		if (char2num(str[i,i])<32)
			str[i,i+1] = str[i+1,i+1]
		endif
		i += 1
	while(i<strlen(str))
	i=0
	do
		if (char2num(str[i,i])==39)
			str[i,i+1] = str[i+1,i+1]
		endif
		i += 1
	while(i<strlen(str))
	return str
End

Function/T ZapNonLetterNumStart(strIN)
	string strIN
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable i = 0
	//a = 97, A=65
	//z =122, Z=90
	//0 = 48
	//9 = 57
	variable tV
	do
		tV = char2num(strIN[0])
		if (tv<48 || (tv>57 && tv<65) || (tv>90 && tv<97) || tv>122)			
			strIN = strIN[1,strlen(strIn)-1]
		else
			break
		endif
	while(strlen(strIN)>0)
	return strIN
end
//***********************************************************************************************
//************************************************************************************************

Function/S IN2G_CreateUniqueFolderName(InFolderName)	//takes folder name and returns unique version if needed
	string InFolderName			//thsi is root:Packages:SomethingHere, will make SomethingHere unique. 
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OutFoldername, tmpFldr
	OutFoldername =InFolderName 
	if(DataFolderExists(InFolderName))
		string OldDf
		OldDf=GetDataFolder(1)
		variable NumParts, i
		NumParts = ItemsInList(InFolderName  , ":")
		setDataFolder root:
		for(i=1;i<NumParts-1;i+=1)
			tmpFldr = IN2G_RemoveExtraQuote(StringFromList(i, InFolderName,":"),1,1)
			SetDataFolder tmpFldr
		endfor
		OutFoldername = GetDataFolder(1)
		OutFoldername+=UniqueName(StringFromList(NumParts-1, InFolderName,":"), 11, 0)
		setDataFolder OldDf
	endif
	return OutFoldername
end
//***********************************************************************************************
//************************************************************************************************

Function/S IN2G_GetUniqueFileName(filename)
	string filename
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string FileList= IndexedFile(ExportDatapath,-1,"????" )
	variable i
	string filename1=filename
	if (stringmatch(FileList, "*"+filename1+"*"))
		i=0
		do
			filename1= filename+"_"+num2str(i)
		i+=1
		while(stringmatch(FileList, "*"+filename1+"*"))
	endif
	return filename1
end

//***********************************************************************************************
//************************************************************************************************

Function IN2G_TrimExportWaves(Q,I,E)	//this function trims export I, Q, E waves as required
	Wave Q
	Wave I
	Wave E
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//here we trim for small Qs
	
	variable ic=0, imax=numpnts(Q)
	
	for(ic=imax;ic>=0;ic-=1)							// herew e remove points with Q<0.0002
		if (Q[ic]<0.0002)
			DeletePoints ic,1, Q, I, E
		endif								
	endfor											
	for(ic=imax;ic>=0;ic-=1)							// and here we remove points with negative intensities
		if (I[ic]<0)
			DeletePoints ic,1, Q, I, E
		endif								
	endfor											
	
end
//************************************************************************************************
//************************************************************************************************
Function IN2G_PasteWnoteToWave(waveNm, textWv,separator)	
	string waveNm, separator
	Wave/T TextWv
	//this function pastes the content of Wave note from waveNm to textWv
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Wave WvwithNote=$waveNm
	string ListOfNotes=note(WvwithNote)
	//remove empty lines
	ListOfNotes=ReplaceString(";;", ListOfNotes, ";") 
	ListOfNotes=ReplaceString("\r", ListOfNotes, ";") 
	ListOfNotes=ReplaceString("\r\n", ListOfNotes, ";") 
	ListOfNotes=ReplaceString("\n", ListOfNotes, ";") 

	
	variable ItemsInLst=ItemsInList(ListOfNotes), i=0	
	Redimension /N=(ItemsInLst) TextWv 
	
	For (i=0;i<ItemsInLst;i+=1)
		TextWv[i]=Separator+stringFromList(i,ListOfNotes)
	endfor
end

//************************************************************************************************
//************************************************************************************************


Function IN2G_UniversalFolderScan(startDF, levels, FunctionName)
        String startDF, FunctionName                  	// startDF requires trailing colon.
        Variable levels							//set 1 for long type and 0 for short type return
        			 
			IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
        //fix if the startDF does not have trailing colon
        if (strlen(startDF)>1)
        	if (stringmatch(":", startDF[strlen(StartDF)-1,strlen(StartDF)-1] )!=1)
        		StartDf=StartDF+":"
        	endif
        endif			 
        String dfSave
        String list = "", templist
        
        dfSave = GetDataFolder(1)
        if (!DataFolderExists(startDF))
        	return 0
        endif
        SetDataFolder startDF
        
        templist = DataFolderDir(1)

    	 //here goes the function which needs to be called
    	  Execute(FunctionName)
    	  
        levels -= 1
        if (levels <= 0)
                return 1
        endif
        
        String subDF
        Variable index = 0
        do
                String temp
                temp = PossiblyQuoteName(GetIndexedObjName(startDF, 4, index))     	// Name of next data folder.
                if (strlen(temp) == 0)
                        break                                                                           			// No more data folders.
                endif
     	              subDF = startDF + temp + ":"
            		 IN2G_UniversalFolderScan(subDF, levels, FunctionName)		      	// Recurse.
                index += 1
        while(1)
        
        SetDataFolder(dfSave)
        return 1
End

//************************************************************************************************
//************************************************************************************************

Function IN2G_CheckTheFolderName()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR/Z FolderName
	if (!SVAR_Exists(FolderName))	
		string/g FolderName=GetDataFolder(0)+";"+GetDataFolder(1)
	endif

	string CurrentFldrNameShort=getDataFolder(0)
	string CurrentFldrNameLong=GetDataFolder(1)

	if (cmpstr(CurrentFldrNameShort,stringFromList(0,FolderName))!=0)
	//	print "Short name changed :"+CurrentFldrNameShort
		FolderName=RemoveListItem(0,FolderName)
		FolderName=CurrentFldrNameShort+";"+FolderName
		IN2G_AppendNoteToAllWaves("UserSampleName",CurrentFldrNameShort)
	endif
	if (cmpstr(CurrentFldrNameLong,stringFromList(1,FolderName))!=0)
	//	print "Long name changed :"+CurrentFldrNameLong
		IN2G_AppendAnyText("Folder name change. \rOld: "+stringFromList(1,FolderName)+"   , new:  "+CurrentFldrNameLong)
		FolderName=RemoveListItem(1,FolderName)
		FolderName=FolderName+CurrentFldrNameLong
		IN2G_AppendNoteToAllWaves("USAXSDataFolder",CurrentFldrNameLong) 
	endif
end

//***********************************************************************************************
//***********************************************************************************************

Function/T IN2G_CreateListOfScans(df)			//Generates list of items in given folder
	String df
//	String Type
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String dfSave
	dfSave=GetDataFolder(1)
	string/G root:Packages:Indra3:MyList=""
	SVAR MyList=root:Packages:Indra3:MyList
	
	if (DataFolderExists(df))
		SetDataFolder $df
		IN2G_UniversalFolderScan(GetDataFolder(1), 5, "IN2G_AppendScanNumAndComment()")	//here we convert the WAVES:wave1;wave2;wave3 into list
		SetDataFolder $dfSave
	else
		MyList=""
	endif
	return MyList
end
//***********************************************************************************************
//***********************************************************************************************
Function IN2G_AppendScanNumAndComment()

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR List=root:Packages:Indra3:MyList
	SVAR/Z SpecComment
	if (SVAR_Exists(SpecComment))
		List+=GetDataFolder(0)+"     "+SpecComment+";"
	endif
end

//***********************************************************************************************
//***********************************************************************************************

//Little math for the SAS results

//Volume Fraction Result is dimensionless
Function IN2G_VolumeFraction(FD,Ddist,MinPoint,MaxPoint, removeNegs)
	Wave FD, Ddist
	Variable MinPoint, MaxPoint, removeNegs
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable temp
	if (MaxPoint<MinPoint)	//lets make sure the min is min and max is max
		temp=MaxPoint
		MaxPoint=MinPoint
		MinPoint=temp
	endif
	
	variable FDlength=numpnts(FD)
	variable DdistLength=numpnts(Ddist)

	if (FDlength!=Ddistlength)
		abort 			//if the waves with data do not have the same length, this makes no sense
	endif

	if (MinPoint<0)
		abort 			//again, no sense, you cannot have minPoint smaller than 0
	endif
	
	if (MaxPoint>FDlength-1)
		abort			//you cannot ask for data beyond the range of waves
	endif
	
	variable VolumeFraction=0
	variable i=0
	variable binwidth=0
	
	For (i=MinPoint;i<=MaxPoint; i+=1)
		if(i<(Ddistlength-1))				//here we check for the last point so we calcualte properly the bin width
			binwidth=(Ddist[i+1]-Ddist[i])
		else
			binwidth=Ddist[i]*((Ddist[i]/Ddist[i-1])-1)		//last point bin width (Pete's suggestion)
		endif
		if (removeNegs)								//if we set this input param to 1, negative FD are replaced by 0 
			if (FD[i]>=0)
				VolumeFraction+=FD[i]*binwidth
			endif
		else											//OK, include negative FDs
			VolumeFraction+=FD[i]*binwidth
		endif
	endfor

	return VolumeFraction
end
//*******************************************************************
//*******************************************************************
//*******************************************************************
//*******************************************************************

//Number density Result is in 1/A3
Function IN2G_NumberDensity(FD,Ddist,MinPoint,MaxPoint, removeNegs)
	Wave FD, Ddist
	Variable MinPoint, MaxPoint, removeNegs
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable temp
	if (MaxPoint<MinPoint)	//lets make sure the min is min and max is max
		temp=MaxPoint
		MaxPoint=MinPoint
		MinPoint=temp
	endif
	
	variable FDlength=numpnts(FD)
	variable DdistLength=numpnts(Ddist)

	if (FDlength!=Ddistlength)
		abort 			//if the waves with data do not have the same length, this makes no sense
	endif

	if (MinPoint<0)
		abort 			//again, no sense, you cannot have minPoint smaller than 0
	endif
	
	if (MaxPoint>FDlength-1)
		abort			//you cannot ask for data beyond the range of waves
	endif
	
	variable NumberDensity=0
	variable i=0
	variable binwidth=0
	
	For (i=MinPoint;i<=MaxPoint; i+=1)
		if(i<(Ddistlength-1))				//here we check for the last point so we calcualte properly the bin width
			binwidth=(Ddist[i+1]-Ddist[i])
		else
			binwidth=Ddist[i]*((Ddist[i]/Ddist[i-1])-1)		//last point bin width (Pete's suggestion)
		endif
		if (removeNegs)								//if we set this input param to 1, negative FD are replaced by 0 
			if (FD[i]>=0)
				NumberDensity+=(FD[i]*binwidth)/((pi/6)*(Ddist[i])^3)
			endif
		else											//OK, include negative FDs
			NumberDensity+=(FD[i]*binwidth)/((pi/6)*(Ddist[i])^3)
		endif
	endfor

	return NumberDensity
end

//*******************************************************************
//*******************************************************************
//*******************************************************************
//*******************************************************************

//Specific Surface Result is in A2/A3
Function IN2G_SpecificSurface(FD,Ddist,MinPoint,MaxPoint, removeNegs)
	Wave FD, Ddist
	Variable MinPoint, MaxPoint, removeNegs
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable temp
	if (MaxPoint<MinPoint)	//lets make sure the min is min and max is max
		temp=MaxPoint
		MaxPoint=MinPoint
		MinPoint=temp
	endif
	
	variable FDlength=numpnts(FD)
	variable DdistLength=numpnts(Ddist)

	if (FDlength!=Ddistlength)
		abort 			//if the waves with data do not have the same length, this makes no sense
	endif

	if (MinPoint<0)
		abort 			//again, no sense, you cannot have minPoint smaller than 0
	endif
	
	if (MaxPoint>FDlength-1)
		abort			//you cannot ask for data beyond the range of waves
	endif
	
	variable SpecificSurface=0
	variable i=0
	variable binwidth=0
	
	For (i=MinPoint;i<=MaxPoint; i+=1)
		if(i<(Ddistlength-1))				//here we check for the last point so we calcualte properly the bin width
			binwidth=(Ddist[i+1]-Ddist[i])
		else
			binwidth=Ddist[i]*((Ddist[i]/Ddist[i-1])-1)		//last point bin width (Pete's suggestion)
		endif
		if (removeNegs)								//if we set this input param to 1, negative FD are replaced by 0 
			if (FD[i]>=0)
				SpecificSurface+=(6*FD[i]*binwidth)/(Ddist[i])
			endif
		else											//OK, include negative FDs
			SpecificSurface+=(6*FD[i]*binwidth)/(Ddist[i])
		endif
	endfor

	return SpecificSurface
end
//*******************************************************************
//*******************************************************************
//*******************************************************************
//*******************************************************************


//Volume weighted mean diameter
Function IN2G_VWMeanDiameter(FD,Ddist,MinPoint,MaxPoint, removeNegs)
	Wave FD, Ddist
	Variable MinPoint, MaxPoint, removeNegs
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable temp
	if (MaxPoint<MinPoint)	//lets make sure the min is min and max is max
		temp=MaxPoint
		MaxPoint=MinPoint
		MinPoint=temp
	endif
	
	variable FDlength=numpnts(FD)
	variable DdistLength=numpnts(Ddist)

	if (FDlength!=Ddistlength)
		abort 			//if the waves with data do not have the same length, this makes no sense
	endif

	if (MinPoint<0)
		abort 			//again, no sense, you cannot have minPoint smaller than 0
	endif
	
	if (MaxPoint>FDlength-1)
		abort			//you cannot ask for data beyond the range of waves
	endif
	
	variable VWMeanDiameter=0
	variable i=0
	variable binwidth=0
	
	For (i=MinPoint;i<=MaxPoint; i+=1)
		if(i<(Ddistlength-1))				//here we check for the last point so we calcualte properly the bin width
			binwidth=(Ddist[i+1]-Ddist[i])
		else
			binwidth=Ddist[i]*((Ddist[i]/Ddist[i-1])-1)		//last point bin width (Pete's suggestion)
		endif
		if (removeNegs)								//if we set this input param to 1, negative FD are replaced by 0 
			if (FD[i]>=0)
				VWMeanDiameter+=(FD[i]*binwidth*Ddist[i])
			endif
		else											//OK, include negative FDs
			VWMeanDiameter+=(FD[i]*binwidth*Ddist[i])
		endif
	endfor

	VWMeanDiameter/=IN2G_VolumeFraction(FD,Ddist,MinPoint,MaxPoint, removeNegs)

	return VWMeanDiameter
end
//*******************************************************************
//*******************************************************************
//*******************************************************************
//*******************************************************************

//Number weighted mean diameter
Function IN2G_NWMeanDiameter(FD,Ddist,MinPoint,MaxPoint, removeNegs)
	Wave FD, Ddist
	Variable MinPoint, MaxPoint, removeNegs
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable temp
	if (MaxPoint<MinPoint)	//lets make sure the min is min and max is max
		temp=MaxPoint
		MaxPoint=MinPoint
		MinPoint=temp
	endif
	
	variable FDlength=numpnts(FD)
	variable DdistLength=numpnts(Ddist)

	if (FDlength!=Ddistlength)
		abort 			//if the waves with data do not have the same length, this makes no sense
	endif

	if (MinPoint<0)
		abort 			//again, no sense, you cannot have minPoint smaller than 0
	endif
	
	if (MaxPoint>FDlength-1)
		abort			//you cannot ask for data beyond the range of waves
	endif
	
	variable NWMeanDiameter=0
	variable i=0
	variable binwidth=0
	
	For (i=MinPoint;i<=MaxPoint; i+=1)
		if(i<(Ddistlength-1))				//here we check for the last point so we calcualte properly the bin width
			binwidth=(Ddist[i+1]-Ddist[i])
		else
			binwidth=Ddist[i]*((Ddist[i]/Ddist[i-1])-1)		//last point bin width (Pete's suggestion)
		endif
		if (removeNegs)								//if we set this input param to 1, negative FD are replaced by 0 
			if (FD[i]>=0)
				NWMeanDiameter+=(FD[i]*binwidth*Ddist[i])/((pi/6)*Ddist[i]^3)
			endif
		else											//OK, include negative FDs
			NWMeanDiameter+=(FD[i]*binwidth*Ddist[i])/((pi/6)*Ddist[i]^3)
		endif
	endfor

	NWMeanDiameter/=IN2G_NumberDensity(FD,Ddist,MinPoint,MaxPoint, removeNegs)

	return NWMeanDiameter
end
//*******************************************************************
//*******************************************************************
//*******************************************************************
//*******************************************************************

//Volume weighted Standard deviation
Function IN2G_VWStandardDeviation(FD,Ddist,MinPoint,MaxPoint, removeNegs)
	Wave FD, Ddist
	Variable MinPoint, MaxPoint, removeNegs
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable temp
	if (MaxPoint<MinPoint)	//lets make sure the min is min and max is max
		temp=MaxPoint
		MaxPoint=MinPoint
		MinPoint=temp
	endif
	
	variable FDlength=numpnts(FD)
	variable DdistLength=numpnts(Ddist)

	if (FDlength!=Ddistlength)
		abort 			//if the waves with data do not have the same length, this makes no sense
	endif

	if (MinPoint<0)
		abort 			//again, no sense, you cannot have minPoint smaller than 0
	endif
	
	if (MaxPoint>FDlength-1)
		abort			//you cannot ask for data beyond the range of waves
	endif
	
	variable VWStandardDeviation=0
	variable i=0
	variable binwidth=0
	
	For (i=MinPoint;i<=MaxPoint; i+=1)
		if(i<(Ddistlength-1))				//here we check for the last point so we calcualte properly the bin width
			binwidth=(Ddist[i+1]-Ddist[i])
		else
			binwidth=Ddist[i]*((Ddist[i]/Ddist[i-1])-1)		//last point bin width (Pete's suggestion)
		endif
		if (removeNegs)								//if we set this input param to 1, negative FD are replaced by 0 
			if (FD[i]>=0)
				VWStandardDeviation+=(FD[i]*binwidth*Ddist[i]^2)
			endif
		else											//OK, include negative FDs
			VWStandardDeviation+=(FD[i]*binwidth*Ddist[i]^2)
		endif
	endfor

	VWStandardDeviation/=IN2G_VolumeFraction(FD,Ddist,MinPoint,MaxPoint, removeNegs)
	VWStandardDeviation-=(IN2G_VWMeanDiameter(FD,Ddist,MinPoint,MaxPoint, removeNegs))^2
	VWStandardDeviation=sqrt(VWStandardDeviation)

	return VWStandardDeviation
end

//*******************************************************************
//*******************************************************************
//*******************************************************************
//*******************************************************************

//Number weighted Standard deviation
Function IN2G_NWStandardDeviation(FD,Ddist,MinPoint,MaxPoint, removeNegs)
	Wave FD, Ddist
	Variable MinPoint, MaxPoint, removeNegs
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable temp
	if (MaxPoint<MinPoint)	//lets make sure the min is min and max is max
		temp=MaxPoint
		MaxPoint=MinPoint
		MinPoint=temp
	endif
	
	variable FDlength=numpnts(FD)
	variable DdistLength=numpnts(Ddist)

	if (FDlength!=Ddistlength)
		abort 			//if the waves with data do not have the same length, this makes no sense
	endif

	if (MinPoint<0)
		abort 			//again, no sense, you cannot have minPoint smaller than 0
	endif
	
	if (MaxPoint>FDlength-1)
		abort			//you cannot ask for data beyond the range of waves
	endif
	
	variable NWStandardDeviation=0
	variable i=0
	variable binwidth=0
	
	For (i=MinPoint;i<=MaxPoint; i+=1)
		if(i<(Ddistlength-1))				//here we check for the last point so we calcualte properly the bin width
			binwidth=(Ddist[i+1]-Ddist[i])
		else
			binwidth=Ddist[i]*((Ddist[i]/Ddist[i-1])-1)		//last point bin width (Pete's suggestion)
		endif
		if (removeNegs)								//if we set this input param to 1, negative FD are replaced by 0 
			if (FD[i]>=0)
				NWStandardDeviation+=(FD[i]*binwidth*Ddist[i]^2)/((pi/6)*Ddist[i]^3)
			endif
		else											//OK, include negative FDs
			NWStandardDeviation+=(FD[i]*binwidth*Ddist[i]^2)/((pi/6)*Ddist[i]^3)
		endif
	endfor

	NWStandardDeviation/=IN2G_NumberDensity(FD,Ddist,MinPoint,MaxPoint, removeNegs)
	NWStandardDeviation-=(IN2G_NWMeanDiameter(FD,Ddist,MinPoint,MaxPoint, removeNegs))^2
	NWStandardDeviation=sqrt(NWStandardDeviation)

	return NWStandardDeviation
end

//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
Function IN2G_CheckScreenSize(which,MinVal)
	string which
	variable MinVal
	//this checks for screen size and if the screen is smaller, aborts and returns error message
	// which = height, width, 
	//MinVal is in pixles
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	if (cmpstr(which,"width")!=0 && cmpstr(which,"height")!=0)
		Abort "Error in IN2G_CheckScreenSize procedure. Major bug. Contact me: ilavsky@aps.anl.gov, please)"
	endif
	variable currentSizeInPixles=IN2G_ScreenWidthHeight(which)*100			//needs to be corrected 
	NVAR/Z PreventIrenaNikaScreenSizeCheck = root:Packages:PreventIrenaNikaScreenSizeCheck
	variable PreventCheck = 0
	if(NVAR_exists(PreventIrenaNikaScreenSizeCheck))
		PreventCheck=PreventIrenaNikaScreenSizeCheck
	endif
	if(!PreventCheck)
		if (currentSizeInPixles<MinVal)
			if (cmpstr(which,"height")==0)
				print "Height of your screen is too small. If you want to prevent checking screen size (it may make your system not usable)"
				print " run following function in command line: PreventIrenaNikaScreenSizeCheck(1)"
				print " to restore screen size check back, run PreventIrenaNikaScreenSizeCheck(0)"
				Abort "Height of your screen is too small for this panel. You have : "+num2str(floor(currentSizeInPixles))+", you need : "+num2str(floor(MinVal))+". On Windows you may : maximize the Igor widnow, reduce dpi setting (% scaling in Display settings), or increase display resolution. On Mac increase display resolution."
			else
				print "Width of your screen is too small. If you want to prevent checking screen size (it may make your system not usable)"
				print " run following function in command line: PreventIrenaNikaScreenSizeCheck(1)"
				print " to restore screen size check back, run PreventIrenaNikaScreenSizeCheck(0)"
				Abort "Width of your screen is too small for this panel. You have : "+num2str(floor(currentSizeInPixles))+", you need : "+num2str(floor(MinVal))+". On Windows you may : maximize the Igor window, reduce dpi setting (% scaling in Display settings) or increase display resolution. On Mac increase display resolution."
			endif
		endif
	endif
end

Function PreventIrenaNikaScreenSizeCheck(YesNo)
	Variable yesNo
	
	variable/g root:Packages:PreventIrenaNikaScreenSizeCheck=yesNo
	
end
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************

Function IN2G_InputPeriodicTable(ButonFunctionName, NewWindowName, NewWindowTitleStr, PositionLeft,PositionTop)
	string ButonFunctionName, NewWindowName, NewWindowTitleStr
	variable PositionLeft,PositionTop
	//PauseUpdate; Silent 1		// building window...
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable pleft=PositionLeft,ptop=PositionTop,pright=PositionLeft+380,pbottom=PositionTop+145			// these change panel size
	NewPanel/K=1 /W=(pleft,ptop,pright,pbottom)
	DoWindow/C/T $(NewWindowName),NewWindowTitleStr
	ModifyPanel cbRGB=(65280,48896,48896)
	SetDrawLayer UserBack
	Variable left=10,top=5										// this change position within panel		
	Button H,pos={left,top},size={20,15},proc=$(ButonFunctionName),title="\Zr090H" 
	Button D,pos={left+20,top},size={20,15},proc=$(ButonFunctionName),title="\Zr090D" 
	Button T,pos={left+40,top},size={20,15},proc=$(ButonFunctionName),title="\Zr090T" 
	Button He,pos={left+340,top},size={20,15},proc=$(ButonFunctionName),title="\Zr090He" 
	Button Li,pos={left,top+15},size={20,15},proc=$(ButonFunctionName),title="\Zr090Li" 
	Button Be,pos={left+20,top+15},size={20,15},proc=$(ButonFunctionName),title="\Zr090Be" 
	Button B,pos={left+240,top+15},size={20,15},proc=$(ButonFunctionName),title="\Zr090B" 
	Button C,pos={left+260,top+15},size={20,15},proc=$(ButonFunctionName),title="\Zr090C" 
	Button N,pos={left+280,top+15},size={20,15},proc=$(ButonFunctionName),title="\Zr090N" 
	Button O,pos={left+300,top+15},size={20,15},proc=$(ButonFunctionName),title="\Zr090O" 
	Button F,pos={left+320,top+15},size={20,15},proc=$(ButonFunctionName),title="\Zr090F" 
	Button Ne,pos={left+340,top+15},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ne" 
	Button Na,pos={left,top+30},size={20,15},proc=$(ButonFunctionName),title="\Zr090Na" 
	Button Mg,pos={left+20,top+30},size={20,15},proc=$(ButonFunctionName),title="\Zr090Mg" 
	Button Al,pos={left+240,top+30},size={20,15},proc=$(ButonFunctionName),title="\Zr090Al" 
	Button Si,pos={left+260,top+30},size={20,15},proc=$(ButonFunctionName),title="\Zr090Si" 
	Button P,pos={left+280,top+30},size={20,15},proc=$(ButonFunctionName),title="\Zr090P" 
	Button S,pos={left+300,top+30},size={20,15},proc=$(ButonFunctionName),title="\Zr090S" 
	Button Cl,pos={left+320,top+30},size={20,15},proc=$(ButonFunctionName),title="\Zr090Cl" 
	Button Ar,pos={left+340,top+30},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ar" 
	Button K,pos={left,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090K" 
	Button Ca,pos={left+20,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ca" 
	Button Sc,pos={left+40,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Sc" 
	Button Ti,pos={left+60,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ti" 
	Button V,pos={left+80,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090V" 
	Button Cr,pos={left+100,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Cr" 
	Button Mn,pos={left+120,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Mn" 
	Button Fe,pos={left+140,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Fe" 
	Button Co,pos={left+160,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Co" 
	Button Ni,pos={left+180,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ni" 
	Button Cu,pos={left+200,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Cu" 
	Button Zn,pos={left+220,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Zn" 
	Button Ga,pos={left+240,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ga" 
	Button Ge,pos={left+260,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ge" 
	Button As,pos={left+280,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090As" 
	Button Se,pos={left+300,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Se" 
	Button Br,pos={left+320,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Br" 
	Button Kr,pos={left+340,top+45},size={20,15},proc=$(ButonFunctionName),title="\Zr090Kr" 
	Button Rb,pos={left,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Rb" 
	Button Sr,pos={left+20,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Sr" 
	Button Y,pos={left+40,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Y" 
	Button Zr,pos={left+60,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Zr" 
	Button Nb,pos={left+80,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Nb" 
	Button Mo,pos={left+100,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Mo" 
	Button Tc,pos={left+120,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Tc" 
	Button Ru,pos={left+140,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ru" 
	Button Rh,pos={left+160,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Rh" 
	Button Pd,pos={left+180,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Pd" 
	Button Ag,pos={left+200,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ag" 
	Button Cd,pos={left+220,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Cd" 
	Button In,pos={left+240,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090In" 
	Button Sn,pos={left+260,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Sn" 
	Button Sb,pos={left+280,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Sb" 
	Button Te,pos={left+300,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Te" 
	Button I,pos={left+320,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090I" 
	Button Xe,pos={left+340,top+60},size={20,15},proc=$(ButonFunctionName),title="\Zr090Xe" 
	Button Cs,pos={left,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Cs" 
	Button Ba,pos={left+20,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ba" 
	Button La,pos={left+40,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090La" 
	Button Hf,pos={left+60,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Hf" 
	Button Ta,pos={left+80,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ta" 
	Button W,pos={left+100,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090W" 
	Button Re,pos={left+120,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Re" 
	Button Os,pos={left+140,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Os" 
	Button Ir,pos={left+160,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ir" 
	Button Pt,pos={left+180,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Pt" 
	Button Au,pos={left+200,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Au" 
	Button Hg,pos={left+220,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Hg" 
	Button Tl,pos={left+240,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Tl" 
	Button Pb,pos={left+260,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Pb" 
	Button Bi,pos={left+280,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Bi" 
	Button Po,pos={left+300,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Po" 
	Button At,pos={left+320,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090At" 
	Button Rn,pos={left+340,top+75},size={20,15},proc=$(ButonFunctionName),title="\Zr090Rn" 
	Button Fr,pos={left,top+90},size={20,15},proc=$(ButonFunctionName),title="\Zr090Fr" 
	Button Ra,pos={left+20,top+90},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ra" 
	Button Ac,pos={left+40,top+90},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ac" 
	Button Ce,pos={left+80,top+105},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ce" 
	Button Pr,pos={left+100,top+105},size={20,15},proc=$(ButonFunctionName),title="\Zr090Pr" 
	Button Nd,pos={left+120,top+105},size={20,15},proc=$(ButonFunctionName),title="\Zr090Nd" 
	Button Pm,pos={left+140,top+105},size={20,15},proc=$(ButonFunctionName),title="\Zr090Pm" 
	Button Sm,pos={left+160,top+105},size={20,15},proc=$(ButonFunctionName),title="\Zr090Sm" 
	Button Eu,pos={left+180,top+105},size={20,15},proc=$(ButonFunctionName),title="\Zr090Eu" 
	Button Gd,pos={left+200,top+105},size={20,15},proc=$(ButonFunctionName),title="\Zr090Gd" 
	Button Tb,pos={left+220,top+105},size={20,15},proc=$(ButonFunctionName),title="\Zr090Tb" 
	Button Dy,pos={left+240,top+105},size={20,15},proc=$(ButonFunctionName),title="\Zr090Dy" 
	Button Ho,pos={left+260,top+105},size={20,15},proc=$(ButonFunctionName),title="\Zr090Ho" 
	Button Er,pos={left+280,top+105},size={20,15},proc=$(ButonFunctionName),title="\Zr090Er" 
	Button Tm,pos={left+300,top+105},size={20,15},proc=$(ButonFunctionName),title="\Zr090Tm" 
	Button Yb,pos={left+320,top+105},size={20,15},proc=$(ButonFunctionName),title="\Zr090Yb" 
	Button Lu,pos={left+340,top+105},size={20,15},proc=$(ButonFunctionName),title="\Zr090Lu" 
	Button Th,pos={left+80,top+120},size={20,15},proc=$(ButonFunctionName),title="\Zr090Th" 
	Button Pa,pos={left+100,top+120},size={20,15},proc=$(ButonFunctionName),title="\Zr090Pa" 
	Button U,pos={left+120,top+120},size={20,15},proc=$(ButonFunctionName),title="\Zr090U" 
End


//**************************
// Smoothing function by Jan Ilavsky, February 24 2004. 
//*******************Conversion of Pete Jemian's smoothing C code   * SplineSmooth.c */
// coded acording to "Smoothing by Spline Functions"
//	Christian H. Reisnch
//	Numerische Mathematik 10 (1967) 177 - 183.
//
//description:
//SplineSmooth fits a natural smoothing spline to "noisy" data with
//specified standard deviations.  The natural end conditions mean that
//the curvature (array c) is zero on each end.  The smoothing is in
//the least squares sense such that:
//SUM[i=n1..n2]( s >= (( Spline(x[i]) - y[i])/dy[i] )^2 )
//where equality holds unless f describes a straight line.  
//
//input:
//	n1, n2:	indices of first and last data points, n2 > n1, the code will fix if n1>n2
//	x, y, dy:	arrays of abcissa, ordinate, & standard deviation
//						of ordinate.  The components of array x must be
//						strictly increasing.
//	s:			non-negative smoothing parameter.
//					S = zero yields a cubic spline fit.
//					S = infinty yields a straight line (least squares) fit.
//output:
//	a, c:	arrays of spline coefficients
//						spline(xx) = b*a[klo] + d*a[khi] +
//							((b*b*b-b)*c[klo]+(d*d*d-d)*c[khi])*(h*h)/6.0;
//					and		b = (x[khi]-xx)/h;
//					and		d = (xx-x[klo])/h;
//					where		h = x[khi] - x[klo];
//					when		x[klo] <= xx < x[khi];
//					and		n1 <= i < n2;
//		Note:
//			if (xx == x[n2]) 
//				spline(xx) = a[n2];
//			In effect, vector a contains the new "y" values for normal splines
//			and vector c contains the associated curvatures.
//

//Function used to test:	
//	Wave DSM_Qvec
//	Wave DSM_Int
//	Wave DSM_Error
//	Wave DSM_Int_smooth
//	Wave CWave
//	
//	Duplicate/O DSM_Int, DSM_Int_log, DSM_Error_log
//	Duplicate/O DSM_Qvec, DSM_Qvec_log
//	
//	DSM_Qvec_log = log( DSM_Qvec)
//	DSM_Int_log= log(DSM_Int)
//	variable scaleMe
//	wavestats/Q DSM_Int_log
//	scaleMe = 2*(-V_min)
//	DSM_Int_log+= scaleMe
//	DSM_Error_log= DSM_Int_log*( 1/(DSM_Int_Log) - 1/(log(DSM_Int+DSM_Error)))
//	
//	IN2G_SplineSmooth(0,113,DSM_Qvec_log,DSM_Int_Log,DSM_Error_Log,param,DSM_Int_Smooth,$"")
//	
//	DSM_Int_smooth-=scaleMe
//	DSM_Int_smooth = 10^DSM_Int_smooth
//end
//**********************************************************************	*/
Function IN2G_SplineSmooth(n1,n2,xWv,yWv,dyWv,S,AWv,CWv)
	variable n1,n2,S
	Wave/Z xWv,yWv,dyWv,AWv,CWv
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		// CWv is optional parameter, if not needed use $"" as input and the function will not complain
		// Input data
		//	n1, n2 range of data (point numbers) between which to smooth data. Order independent.
		//	xWv,yWv,dyWv  input waves. No changes to these waves are made
		// 	S - smoothing factor. Range between 1 and 10^32 or so, varies wildly, often around 10^10
		//	AWv,CWv	output waves. AWv contains values for points from yWv, CWv contains values needed for interpolation
		// 	AWv and CWv are redimensioned to length of yWv and converted to real double precision
		if((numpnts(xWv) != numpnts(yWv)) || (numpnts(xWv) !=numpnts(dyWv)))
			abort "Input waves in IN2G_SplineSmooth require same length"
		endif 
		if((n1>n2)) 
			variable tempn=n1
			n1=n2
			n2=tempn
		endif
		if((n1>n2) || (n1<0) || (n2>=numpnts(xWv)))
			abort "Data range selection in IN2G_SplineSmooth is wrong, input range out of input wave length"
		endif
		string OldDf=GetDataFolder(1)
		NewDataFolder/O/S root:Packages
		NewDataFolder/O/S root:Packages:SmoothData
		variable i,m1,m2,e,f,f2,g,h,pv, WaveCWvExisted
		if(WaveExists(CWv))
			WaveCWvExisted=1
		else
			make/O CWv
			WaveCWvExisted=0
		endif
		Redimension/R/D/N=(numpnts(yWv)) AWv,CWv
		Make/O/D/Free/N=(n2+1) bWv, dWv		//the first n1 indexes will not be used
		m1=n1-1
		m2=n2+1
		Make/O/D/Free/N=(m2+1) rWv, r1Wv, r2Wv, tWv, t1Wv, uWv, vWv
		rWv=0
		bWv=0
		dWv=0
		r1Wv=0
		r2Wv=0
		uWv=0
		tWv=0
		t1Wv=0
		vWv=0
		pv=0
		
		m1=n1+2
		m2=n2-2
		h=xWv[m1] - xWv[n1]
		if (h<0)
			SetDataFolder OldDf
			Abort "Array x not strictly increasing in SplineSmooth"
		endif
		f=(yWv[m1]-yWv[n1])/h
		For(i=m1;i<=m2;i+=1)
			g=h
			h=xWv[i+1] - xWv[i]
			if(h<=0)
				SetDataFolder OldDf
				Abort "Array x not strictly increasing in SplineSmooth"
			endif
			e=f
			f = (yWv[i+1]-yWv[i])/h
			aWv[i]=f - e
			tWv[i]=2*(g+h)/3
			t1Wv[i]=h/3
			r2Wv[i]=dyWv[i-1]/g
			rWv[i]=dyWv[i+1]/h
			r1Wv[i]=-dyWv[i] * (1/g + 1/h)
		endfor
		bWv[m1,m2] = rWv^2 + r1Wv^2 + r2Wv^2
		cWv[m1,m2] = rWv[p] * r1Wv[p+1] + r1Wv[p] * r2Wv[p+1]
		dWv[m1,m2] = rWv[p] * r2Wv[p+2]
		f2 = -S
		Do
			For(i=m1;i<=m2;i+=1)
				r1Wv[i-1] = f * rWv[i-1]
				r2Wv[i-2] = g * rWv[i-2]
				rWv[i] = 1/(pv * bWv[i] + tWv[i] - f * r1Wv[i-1] - g * r2Wv[i-2])
				uWv[i] = aWv[i] - r1Wv[i-1] * uWv[i-1] - r2Wv[i-2] * uWv[i-2]
				f = pv * cWv[i] + t1Wv[i] - h * r1Wv[i-1]
				g = h
				h = pv * dWv[i]
			endfor
			For(i=m2;i>=m1;i-=1)
			uWv[i] = rWv[i] * uWv[i] - r1Wv[i] * uWv[i+1] - r2Wv[i] * uWv[i+2]
			endfor
			e = 0
			h = 0
			For(i=n1;i<=m2;i+=1)
				g =h
				h = (uWv[i+1] - uWv[i]) / (xWv[i+1] - xWv[i])
				vWv[i] = (h - g) * (DyWv[i])^2
				e += vWv[i] * (h - g)
			endfor
			g = -h * (dyWv[n2])^2
			vWv[n2] = g
			e -= g * h
			g = f2
			f2 = e * pv * pv
			if((f2>=S) || (f2<=g))
				break		//normal terminating conditions
			endif
			f = 0 
			h = (vWv[m1] - vWv[n1]) / (xWv[m1] - xWv[n1])
			For(i=m1;i<=m2;i+=1)
				g = h
				h = (vWv[i+1] - vWv[i]) / (xWv[i+1] - xWv[i])
				g = h - g -r1Wv[i-1] * rWv[i] - r2Wv[i-2] * rWv[i-2]
				f = f + g * rWv[i] * g
				rWv[i] = g
			endfor
			h = e - pv*f
			if (h>0)
				pv += (S - f2)/((sqrt(s/e)+pv)*h)
			endif
		while (h>0)
		aWv = yWv - pv*vWv		//* new knots */
		if(n1>0)
			aWv[0,n1]=Nan
		endif
		if(n2<numpnts(aWv)-1)
			aWv[n2, ]=NaN
		endif
		if(WaveCWvExisted)
			cWv = uWv				//* new curvatures */
			if(n1>0)
				cWv[0,n1]=Nan
			endif
			if(n2<numpnts(aWv)-1)
				cWv[n2, ]=NaN
			endif
		else
			KillWaves/Z cWv
		endif
		KillWaves/Z bWv, dWv, rWv, r1Wv, r2Wv, tWv, t1Wv, uWv, vWv
		setDataFolder OldDf
end
//*******************************************************************
//*******************************************************************
//*******************************************************************
//*******************************************************************

Function IN2G_ScrollButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"ScrollButtonUp"))
				IN2G_MoveControlsPerRequest(ba.win,60)
			endif
			if(stringmatch(ba.ctrlName,"ScrollButtonDown"))
				IN2G_MoveControlsPerRequest(ba.win, -60)
			endif			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//*******************************************************************
//*******************************************************************
//*******************************************************************
//*******************************************************************
