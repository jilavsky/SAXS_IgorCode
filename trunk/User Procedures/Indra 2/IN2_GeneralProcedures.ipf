#pragma rtGlobals=2		// Use modern global access method.
#pragma version = 1.75


//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

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
//Function IN2G_CheckForSlitSmearedRange(slitSmearedData,Qmax, SlitLength)
//   aborts execution with errro message if qmax < 3* slit length for slit smerared data
//
//Function IN2G_RebinLogData(Wx,Wy,NumberOfPoints,MinStep,[Wsdev,Wxwidth,W1, W2, W3, W4, W5])
//  Rebins data (x,y.etc) on log scale oiptionally with enforcing minimum step size. 
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
//
//IN2G_RemNaNsFromAWave(Wv1)	//removes NaNs from 1 wave
//assume same number of points in the waves
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

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*************************************************************************************************************************************
// Calculates the experiment size and returns it in bytes
// Last Modified 2012/07/09 by Jamie Boyd
Function IN2G_EstimateFolderSize (dataFolder)
	string dataFolder
	
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
Function myFindStartValueFunc(w,x1)
	Wave w		//this is {totalRange, NumSteps,MinStep}
	Variable x1	//this is startValue where we need to start with log stepping...
	variable LastMinStep = 10^(log(X1) + (log(X1+w[0])-log(X1))/w[1]) - 10^(log(X1))
	return abs(LastMinStep-w[2])
End

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
		if(grepString(StringFromList(i,ListOfWvs),WaveMatchStr))
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
	variable numItems=ItemsInList(FullPointerToWaveVarStr,":")
	
	string tempStr=RemoveFromList(StringFromList(numItems-1,FullPointerToWaveVarStr,":"), FullPointerToWaveVarStr , ":")
	if(DataFolderExists(tempStr))
		return tempStr
	else
		return ""
	endif
end


//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2G_FolderSelectPanel(SVARString, TitleString,StartingFolder,FolderOrFile,AllowNew,AllowDelete,AllowRename,AllowLiberal,ExecuteMyFunction)		
	string SVARString, TitleString, StartingFolder, ExecuteMyFunction	
	variable FolderOrFile, AllowNew,AllowDelete,AllowRename	,AllowLiberal		
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
	
	if(cmpstr(ctrlName,"DisplayWaves"))
	
	endif
	IN2G_FolderSelectRefFldrCont()
End

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2G_ColorTopGrphRainbow()

	String topGraph=WinName(0,1)
	Variable traceIndex, numTraces
	Variable i, iRed, iBlue, iGreen, io, w, Red, Blue, Green,  ColorNorm
	if( strlen(topGraph) )
		numTraces =  ItemsInList(TraceNameList(topGraph,";",3))
		if (numTraces > 0)
			w=numTraces/2
		        For(i=0;i<numTraces;i+=1)
	                      io = 0
		                iRed = exp(-(i-io)^2/w)
		                io = numTraces/2
		                iBlue = exp(-(i-io)^2/w)
		                io = numTraces
		                iGreen = exp(-(i-io)^2/w)
	     	                ColorNorm = sqrt(iRed^2 + iBlue^2 + iGreen^2)	
		                Red = 65535 * (iRed/ColorNorm)
		                Blue = 65535 * (iBlue/ColorNorm)
		                Green = 65535 * (iGreen/ColorNorm)
		               // print "("+num2str(Red)+","+num2str(Blue)+","+num2str(Green)+")"
					ModifyGraph/w=$(topGraph) rgb[i]=(Red,Blue,Green)
			    endfor
		endif
		//AutoPositionWindow/M=0/R=$topGraph KBColorizePanel
	endif

// 	       Variable i, NumTraces, iRed, iBlue, iGreen, io, w, Red, Blue, Green,  ColorNorm
// 	       GetWindow /Z kwTopWin, 
//              w = NumberOfWaves/2
//	        For(i=0;i<NumberOfWaves;i+=1)
//                      io = 0
//	                iRed = exp(-(i-io)^2/w)
//	                io = NumberOfWaves/2
//	                iBlue = exp(-(i-io)^2/w)
//	                io = NumberOfWaves
//	                iGreen = exp(-(i-io)^2/w)
//     	                ColorNorm = sqrt(iRed^2 + iBlue^2 + iGreen^2)	
//	                Red = 65535 * (iRed/ColorNorm)
//	                Blue = 65535 * (iBlue/ColorNorm)
//	                Green = 65535 * (iGreen/ColorNorm)
//	               // print "("+num2str(Red)+","+num2str(Blue)+","+num2str(Green)+")"
//			    ListOfGraphFormating=ReplaceStringByKey("rgb["+num2str(i)+"]",ListOfGraphFormating, "("+num2str(Red)+","+num2str(Blue)+","+num2str(Green)+")","=")
//		    endfor
// 
//		else

end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IN2G_FolderSelectListBoxProc(ctrlName,row,col,event)
	String ctrlName
	Variable row
	Variable col
	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
					//5=cell select with shift key, 6=begin edit, 7=end
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
		DoWIndow/K IN2G_FolderSelectPanelPanel
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
		DoWIndow/K IN2G_FolderSelectPanelPanel
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
	DoWIndow IN2G_FolderSelectPanelPanel
	if(V_Flag)
		DoWIndow/K IN2G_FolderSelectPanelPanel
	endif
	//PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(100,60,630,340) as TitleString
	DoWindow/C IN2G_FolderSelectPanelPanel
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
	ControlInfo $MyControlName
	variable NewStep=V_Value * NewStepFraction
	variable startS =strsearch(S_recreation,"{",strsearch(S_recreation,"limits",0))
	variable endS =strsearch(S_recreation,"}",strsearch(S_recreation,"limits",0))
	string oldMin=(stringFromList(0,S_recreation[startS+1,endS-1],","))
	string oldMax=(stringFromList(1,S_recreation[startS+1,endS-1],","))
	Execute("SetVariable "+MyControlName+",limits={"+oldMin+","+oldMax+","+num2str(NewStep)+"}")
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



Function/T IN2G_RemoveExtraQuote(str,starting,Ending)
	String str
	variable starting,Ending
	
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

	Variable id=strlen(oldpart)
	Variable i
	do
		i = strsearch(str,oldpart,0 )
		if (i>=0)
			str[i,i+id-1] = newpart
		endif
	while(i>=0)

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
	
	variable Error=(sqrt((A1^2*S2^4)+(S1^2*A2^4)+((A1^2+S1^2)*A2^2*S2^2))) / (A2*(A2^2-S2^2))
	
	return Error
end	

Function IN2G_ErrorsForMultiplication(A1,S1,A2,S2)
	variable A1, S1, A2, S2	//this function multiplies two numbers with errors
	
	variable Error=sqrt((A1*S2)^2+(A2*S1)^2+(S1*S2)^2)
	
	return Error
end	

Function IN2G_ErrorsForSubAndAdd(A1,S1,A2,S2)
	variable A1, S1, A2, S2	//this function subtracts A2 from A1 with errors
	
	variable Error=sqrt(S1^2+S2^2)
	
	return Error
end	


Function/T IN2G_DivideWithErrors(A1,S1,A2,S2)
	variable A1, S1, A2, S2	//this function divides A1 by A2 with errors
	
	variable Result=A1/A2
	variable Error=(sqrt((A1^2*S2^4)+(S1^2*A2^4)+((A1^2+S1^2)*A2^2*S2^2))) / (A2*(A2^2-S2^2))
	
	return num2str(Result)+";"+num2str(Error)
end	


Function/T IN2G_MulitplyWithErrors(A1,S1,A2,S2)
	variable A1, S1, A2, S2	//this function multiplies two numbers with errors
	
	variable Result=A1*A2
	variable Error=sqrt((A1*S2)^2+(A2*S1)^2+(S1*S2)^2)
	
	return num2str(Result)+";"+num2str(Error)
end	


Function/T IN2G_SubtractWithErrors(A1,S1,A2,S2)
	variable A1, S1, A2, S2	//this function subtracts A2 from A1 with errors
	
	variable Result=A1-A2
	variable Error=sqrt(S1^2+S2^2)
	
	return num2str(Result)+";"+num2str(Error)
end	

Function/T IN2G_SumWithErrors(A1,S1,A2,S2)
	variable A1, S1, A2, S2	//this function sums two numbers with errors
	
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
	
	string CurrentListOfrWaves=TraceNameList(GraphName,";",1)
	//here we store what traces are in the graph before	
	duplicate/O BotWave, root:Packages:USAXS:MyTopWave
	
	Wave NewTopWave=root:Packages:USAXS:MyTopWave
	
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
	
	string CurrentListOfrWaves=TraceNameList(GraphName,";",1)
	//here we store what traces are in the graph before	
	duplicate/O BotWave, root:Packages:USAXS:MyTopWave
	
	Wave NewTopWave=root:Packages:USAXS:MyTopWave
	
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
	
	string PanelName=WinName(0,64)
	DoWindow /K $PanelName
End

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_AutoscaleAxisFromZero(WindowName,which,where)		//this function autoscales axis from 0
	string WindowName, which, where
	
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
	TextToBeInserted=TextToBeInserted+"\r"
    SVAR/Z nbl=root:Packages:USAXS:NotebookName
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
	
	str=RemoveListItem(0, Str , ":")					//remove the "FOLDERS"
	variable i=0, imax=itemsInList(str,",")			//working parameters
	string strList="", tmpstr						//working parameters
	str=str[0,strlen(str)-3]						//remove  /r; at the end
	if(stringmatch(str,"*spec*"))					//here we have list of spec scans
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
		 //replace with replaceString, faster...	12/10/2010
		//		for(i=0;i<imax;i+=1)							
		//			strList+=StringFromList(i, str, ",")+";"		
		//		endfor 	
		strList = ReplaceString(",", str, ";" )+";"
		if(strlen(strList)==1)
			strList=""
		endif
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
	
	//String dfSave
	//dfSave=GetDataFolder(1)
	string MyList=""
	DFREF TestDFR=$(df)
	if (DataFolderRefStatus(TestDFR))
	//	SetDataFolder $df
		//DataFolderDir(mode [, dfr ] )
		MyList= IN2G_ConvertDataDirToList(DataFolderDir(item, TestDFR))	//here we convert the WAVES:wave1;wave2;wave3 into list
		return MyList
	//	SetDataFolder $dfSave
	else
		return ""
	//	MyList=""
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
	
	SVAR SpecFile=root:Packages:USAXS:PanelSpecScanSelected
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
	
	string ListOfWaves=WaveList("*",";",""), temp
	variable i=0, imax=ItemsInList(ListOfWaves)
	For(i=0;i<imax;i+=1)
		temp=stringFromList(i,listOfWaves)
		IN2G_AppendListToWaveNote(temp,Notetext)
	endfor
end

Function IN2G_AppendListToWaveNote(WaveNm,NewValue)		//this will replace or append new Keyword-list note to wave
	string WaveNm, NewValue
	
	Wave Wv=$WaveNm
	string Wnote=note(Wv)
	Wnote=NewValue				
	Note /K Wv
	Note Wv, Wnote
end


Function IN2G_AddListToWaveNote(WaveNm,NewValue)		//this will replace or append new Keyword-list note to wave
	string WaveNm, NewValue
	
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
	string GraphName=Winname(0,1)
	string PanelName=WinName(0,64)
	AutopositionWindow/M=0 /R=$GraphName $PanelName
end

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_AutoAlignPanelAndGraph()
	string GraphName=Winname(0,1)
	string PanelName=WinName(0,64)
	AutopositionWindow/M=0 /R=$PanelName $GraphName 
end


//**********************************************************************************************
//**********************************************************************************************

Function IN2G_CleanupFolderOfWaves()		//cleans waves from fit_ and W_ waves

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
        	
	if (strlen(WinList("UPD control",";","WIN:64"))>0)		//Kills the controls when not needed anymore
			DoWindow/K PDcontrols
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
	
      String wName=WinName(0, 1)              // 1=graphs, 2=tables,4=layouts
                dowindow /K $wName
	if (strlen(WinList("IN2A_UPDControlPanel",";","WIN:64"))>0)	//Kills the controls when not needed anymore
			DoWindow/K  IN2A_UPDControlPanel
	endif
End


Function IN2G_KillGraphsTablesEnd(ctrlname) :Buttoncontrol
	string ctrlname
	
      String wName=WinName(0, 1)              // 1=graphs, 2=tables,4=layouts
                dowindow /K $wName
	if (strlen(WinList("IN2A_UPDControlPanel",";","WIN:64"))>0)	//Kills the controls when not needed anymore
			DoWindow/K  IN2A_UPDControlPanel
	endif
       abort
End

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_KillTopGraph(ctrlname) :Buttoncontrol
	string ctrlname
       String wName=WinName(0, 1)              // 1=graphs, 2=tables,4=layouts

       dowindow /K $wName
End

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_KillWavesFromList(WvList)
	string WvList
	
	variable items=ItemsInList(WvList), i
	For (i=0;i<items;i+=1)
		KillWaves/Z $(StringFromList(i, WvList))
	endfor
end
//**********************************************************************************************
//**********************************************************************************************

Proc IN2G_BasicGraphStyle()
	PauseUpdate; Silent 1		// modifying window...
	ModifyGraph/Z margin(top)=100
	ModifyGraph/Z mode=4, gaps=0
	ModifyGraph/Z zColor[0]={PD_range,0,10,Rainbow}
	ModifyGraph/Z mirror=1
	ModifyGraph/Z font="Times New Roman"
	ModifyGraph/Z minor=1
	ModifyGraph/Z fSize=12
	Label/Z left "Intensity"
	Label/Z bottom "Ar encoder"
	Duplicate/O PD_range, root:Packages:USAXS:MyColorWave							//creates new color wave
	IN2A_MakeMyColors(PD_range,root:Packages:USAXS:MyColorWave)						//creates colors in it
 	ModifyGraph mode=4, zColor={root:Packages:USAXS:MyColorWave,0,10,Rainbow}, margin(top)=100, mirror=1, minor=1
	showinfo												//shows info
	ShowTools/A											//show tools
	Button KillThisWindow pos={10,10}, size={100,25}, title="Kill window", proc=IN2G_KillGraphsTablesEnd
	Button ResetWindow pos={10,40}, size={100,25}, title="Reset window", proc=IN2G_ResetGraph
	Button Reverseaxis pos={10,70}, size={100,25}, title="Reverse X axis", proc=IN2G_ReversXAxis
EndMacro

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_ScreenWidthHeight(what)			//keeps graphs the same size on all screens
	string what
	string temp

	variable ScreenRes = 72/ScreenResolution		//fixes Mac & PC small & larg fonts selection
	if (cmpstr(what,"width")==0)					//gets width of the screen
		temp= StringByKey("SCREEN1", IgorInfo(0))
		temp=stringFromList(3,  temp,",")
		return ScreenRes*str2num(temp)/100
	endif
	if (cmpstr(what,"height")==0)					//gets height of screen
		temp= StringByKey("SCREEN1", IgorInfo(0))
		temp=stringFromList(4,  temp,",")
		return ScreenRes*str2num(temp)/100
	endif
	return NaN
end

//**********************************************************************************************
//**********************************************************************************************
Function IN2G_SetPointWithCsrAToNaN(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname
	
	variable pointNumberToBeRemoved=xcsr(A)				//this part should be done always
		Wave FixMe=CsrWaveRef(A)
		FixMe[pointNumberToBeRemoved]=NaN
																//if we need to fix more waves, it can be done here
		cursor/P A, $CsrWave(A), pointNumberToBeRemoved+1		//set the cursor to the right so we do not scare user
End

Function IN2G_SetPointsBetweenCsrsToNaN(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname
	
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
	
	variable pointNumberToBeRemoved=xcsr(A)				//this part should be done always
		Wave FixMe=CsrWaveRef(A)
		FixMe[0, pointNumberToBeRemoved]=NaN
																//if we need to fix more waves, it can be done here
		cursor/P A, $CsrWave(A), pointNumberToBeRemoved+1		//set the cursor to the right so we do not scare user
End

Function IN2G_SetPointsLargerCsrBToNaN(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname
	
	variable pointNumberToBeRemoved=xcsr(B)				//this part should be done always
		Wave FixMe=CsrWaveRef(B)
		FixMe[pointNumberToBeRemoved, numpnts(FixMe)-1]=NaN
																//if we need to fix more waves, it can be done here
		cursor/P B, $CsrWave(B), pointNumberToBeRemoved-1		//set the cursor to the right so we do not scare user
End


Function IN2G_RemovePointWithCursorA(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname
	
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
		SetAxis/A										//rescales graph to automatic scaling
End

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_ReversXAxis(ctrlname) : Buttoncontrol
	string ctrlname
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
        
        dfSave = GetDataFolder(1)
  	
  	if (!DataFolderExists(startDF))
  		return ""
  	endif
  	
        SetDataFolder startDF
        
        templist = DataFolderDir(0)
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
        			 
        String dfSave
        String list = "", templist, tempWvName, TempWvList
        variable i, skipRest
        
        dfSave = GetDataFolder(1)
  	
  	if (!DataFolderExists(startDF))
  		return ""
  	endif
  	
        SetDataFolder startDF
        
        templist = DataFolderDir(0)
        skipRest=0
 	//first treat the empty folders... 
 	if(strlen(WaveList("*",";",""))>0 && cmpstr(WaveTypes,"*")==0)  //if the folder is NOT empty and matchstr="*", then we need to include this folder... 
 		if (LongShortType)
	            		list += startDF + ";"
				skipRest=1
	      	else
     		      		list += GetDataFolder(0) + ";"
      				skipRest=1
      		endif	
 	elseif(strlen(WaveList("*",";",""))>0)	//folder not empty, but need to test match strings... 
 		//and now the non-empty folders...
		 	// For(i=0;i<ItemsInList(WaveList("*",";",""));i+=1)
		 TempWvList = 	WaveList(WaveTypes,";","")
		  For(i=0;i<ItemsInList(TempWvList);i+=1)
			tempWvName = StringFromList(i, TempWvList ,";")
			 //   	 if (Stringmatch(WaveList("*",";",""),WaveTypes))
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
        
        dfSave = GetDataFolder(1)
  	if (!DataFolderExists(startDF))
  		return ""
  	endif
  	
        SetDataFolder startDF
        
        templist = DataFolderDir(0)
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
	
	variable i=0, imax=numpnts(Wv1)-1
	for (i=imax;i>=0;i-=1)
		if (numtype(Wv1[i])==2 || numtype(Wv2[i])==2)
			Deletepoints i, 1, Wv1, Wv2
		endif
	endfor
end
//**********************************************************************************************
//**********************************************************************************************
Function IN2G_RemoveNaNsFrom5Waves(Wv1,wv2,wv3,wv4,wv5)		//removes NaNs from 5 waves
	Wave Wv1, Wv2, Wv3, wv4,wv5					//assume same number of points in the waves
	
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
	
	variable i=0, imax=numpnts(Wv1)-1
	for (i=imax;i>=0;i-=1)
		if (numtype(Wv1[i])==2 || numtype(Wv2[i])==2 || numtype(Wv3[i])==2 || numtype(Wv4[i])==2 || numtype(Wv5[i])==2 || numtype(Wv6[i])==2)
			Deletepoints i, 1, Wv1, Wv2, Wv3,wv4,wv5, wv6
		endif
	endfor
end
//**********************************************************************************************
//**********************************************************************************************
Function IN2G_RemoveNaNsFrom4Waves(Wv1,wv2,wv3,wv4)		//removes NaNs from 4 waves
	Wave Wv1, Wv2, Wv3, wv4				//assume same number of points in the waves
	
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
	
	variable i=0, imax=numpnts(Wv1)-1
	for (i=imax;i>=0;i-=1)
		if (numtype(Wv1[i])==2)
			Deletepoints i, 1, Wv1
		endif
	endfor
end

//**********************************************************************************************
//**********************************************************************************************

Function IN2G_ReplaceNegValsByNaNWaves(Wv1,wv2,wv3)			//replaces Negative values in 3 waves by NaNs 
	Wave Wv1, Wv2, Wv3					//assume same number of points in the waves
	
	variable i=0, imax=numpnts(Wv1)-1
	for (i=imax;i>=0;i-=1)
		if (Wv1[i]<0 || Wv2[i]<0 || Wv3[i]<0)
			Deletepoints i, 1, Wv1, Wv2, Wv3
		endif
	endfor
end

//************************************************************************************************************************
//************************************************************************************************************************

Function IN2G_GenerateLegendForGraph(fntsize,WNoteName,RemoveRepeated)  //generates legend for graphs and kills the old one, fntsize is font size
	variable fntsize, WNoteName, RemoveRepeated							//WNoteName=1 use name from Wname  key in Wave Note
			//finds name of the old legend and generates new one with the same name, if the legend does not exists
			//it cretaes new one with name legend1
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
#if Exists("IR2C_LkUpDfltStr")
	NewLegend ="\\F"+IR2C_LkUpDfltStr("FontType")
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



Function/S IN2G_GetUniqueFileName(filename)
	string filename
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
	
	Wave WvwithNote=$waveNm
	string ListOfNotes=note(WvwithNote)
	
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
        
        templist = DataFolderDir(0)

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
	
	String dfSave
	dfSave=GetDataFolder(1)
	string/G root:Packages:USAXS:MyList=""
	SVAR MyList=root:Packages:USAXS:MyList
	
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

	SVAR List=root:Packages:USAXS:MyList
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
	
	if (cmpstr(which,"width")!=0 && cmpstr(which,"height")!=0)
		Abort "Error in IN2G_CheckScreenSize procedure. Major bug. Contact me: ilavsky@aps.anl.gov, please)"
	endif
	variable currentSizeInPixles=IN2G_ScreenWidthHeight(which)*100*ScreenResolution/72
	
	if (currentSizeInPixles<MinVal)
		if (cmpstr(which,"height")==0)
			Abort "Height of your screen is too small to run this code, please set your screen to larger number of pixles in height. On windows with 1024 x 768 screens autohide the task bar. Helps..."
		else
			Abort "Width of your screen is too small to run this code, please set your screen to larger number of pixles in width"
		endif
	endif
	
end

//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************
//*******************************************************************************************************

Function IN2G_InputPeriodicTable(ButonFunctionName, NewWindowName, NewWindowTitleStr, PositionLeft,PositionTop)
	string ButonFunctionName, NewWindowName, NewWindowTitleStr
	variable PositionLeft,PositionTop
	//PauseUpdate; Silent 1		// building window...
	Variable pleft=PositionLeft,ptop=PositionTop,pright=PositionLeft+380,pbottom=PositionTop+145			// these change panel size
	NewPanel/K=1 /W=(pleft,ptop,pright,pbottom)
	DoWindow/C/T $(NewWindowName),NewWindowTitleStr
	ModifyPanel cbRGB=(65280,48896,48896)
	SetDrawLayer UserBack
	Variable left=10,top=5										// this change position within panel		
	Button H,pos={left,top},size={20,15},proc=$(ButonFunctionName),title="H",fsize=9
	Button D,pos={left+20,top},size={20,15},proc=$(ButonFunctionName),title="D",fsize=9
	Button T,pos={left+40,top},size={20,15},proc=$(ButonFunctionName),title="T",fsize=9
	Button He,pos={left+340,top},size={20,15},proc=$(ButonFunctionName),title="He",fsize=9
	Button Li,pos={left,top+15},size={20,15},proc=$(ButonFunctionName),title="Li",fsize=9
	Button Be,pos={left+20,top+15},size={20,15},proc=$(ButonFunctionName),title="Be",fsize=9
	Button B,pos={left+240,top+15},size={20,15},proc=$(ButonFunctionName),title="B",fsize=9
	Button C,pos={left+260,top+15},size={20,15},proc=$(ButonFunctionName),title="C",fsize=9
	Button N,pos={left+280,top+15},size={20,15},proc=$(ButonFunctionName),title="N",fsize=9
	Button O,pos={left+300,top+15},size={20,15},proc=$(ButonFunctionName),title="O",fsize=9
	Button F,pos={left+320,top+15},size={20,15},proc=$(ButonFunctionName),title="F",fsize=9
	Button Ne,pos={left+340,top+15},size={20,15},proc=$(ButonFunctionName),title="Ne",fsize=9
	Button Na,pos={left,top+30},size={20,15},proc=$(ButonFunctionName),title="Na",fsize=9
	Button Mg,pos={left+20,top+30},size={20,15},proc=$(ButonFunctionName),title="Mg",fsize=9
	Button Al,pos={left+240,top+30},size={20,15},proc=$(ButonFunctionName),title="Al",fsize=9
	Button Si,pos={left+260,top+30},size={20,15},proc=$(ButonFunctionName),title="Si",fsize=9
	Button P,pos={left+280,top+30},size={20,15},proc=$(ButonFunctionName),title="P",fsize=9
	Button S,pos={left+300,top+30},size={20,15},proc=$(ButonFunctionName),title="S",fsize=9
	Button Cl,pos={left+320,top+30},size={20,15},proc=$(ButonFunctionName),title="Cl",fsize=9
	Button Ar,pos={left+340,top+30},size={20,15},proc=$(ButonFunctionName),title="Ar",fsize=9
	Button K,pos={left,top+45},size={20,15},proc=$(ButonFunctionName),title="K",fsize=9
	Button Ca,pos={left+20,top+45},size={20,15},proc=$(ButonFunctionName),title="Ca",fsize=9
	Button Sc,pos={left+40,top+45},size={20,15},proc=$(ButonFunctionName),title="Sc",fsize=9
	Button Ti,pos={left+60,top+45},size={20,15},proc=$(ButonFunctionName),title="Ti",fsize=9
	Button V,pos={left+80,top+45},size={20,15},proc=$(ButonFunctionName),title="V",fsize=9
	Button Cr,pos={left+100,top+45},size={20,15},proc=$(ButonFunctionName),title="Cr",fsize=9
	Button Mn,pos={left+120,top+45},size={20,15},proc=$(ButonFunctionName),title="Mn",fsize=9
	Button Fe,pos={left+140,top+45},size={20,15},proc=$(ButonFunctionName),title="Fe",fsize=9
	Button Co,pos={left+160,top+45},size={20,15},proc=$(ButonFunctionName),title="Co",fsize=9
	Button Ni,pos={left+180,top+45},size={20,15},proc=$(ButonFunctionName),title="Ni",fsize=9
	Button Cu,pos={left+200,top+45},size={20,15},proc=$(ButonFunctionName),title="Cu",fsize=9
	Button Zn,pos={left+220,top+45},size={20,15},proc=$(ButonFunctionName),title="Zn",fsize=9
	Button Ga,pos={left+240,top+45},size={20,15},proc=$(ButonFunctionName),title="Ga",fsize=9
	Button Ge,pos={left+260,top+45},size={20,15},proc=$(ButonFunctionName),title="Ge",fsize=9
	Button As,pos={left+280,top+45},size={20,15},proc=$(ButonFunctionName),title="As",fsize=9
	Button Se,pos={left+300,top+45},size={20,15},proc=$(ButonFunctionName),title="Se",fsize=9
	Button Br,pos={left+320,top+45},size={20,15},proc=$(ButonFunctionName),title="Br",fsize=9
	Button Kr,pos={left+340,top+45},size={20,15},proc=$(ButonFunctionName),title="Kr",fsize=9
	Button Rb,pos={left,top+60},size={20,15},proc=$(ButonFunctionName),title="Rb",fsize=9
	Button Sr,pos={left+20,top+60},size={20,15},proc=$(ButonFunctionName),title="Sr",fsize=9
	Button Y,pos={left+40,top+60},size={20,15},proc=$(ButonFunctionName),title="Y",fsize=9
	Button Zr,pos={left+60,top+60},size={20,15},proc=$(ButonFunctionName),title="Zr",fsize=9
	Button Nb,pos={left+80,top+60},size={20,15},proc=$(ButonFunctionName),title="Nb",fsize=9
	Button Mo,pos={left+100,top+60},size={20,15},proc=$(ButonFunctionName),title="Mo",fsize=9
	Button Tc,pos={left+120,top+60},size={20,15},proc=$(ButonFunctionName),title="Tc",fsize=9
	Button Ru,pos={left+140,top+60},size={20,15},proc=$(ButonFunctionName),title="Ru",fsize=9
	Button Rh,pos={left+160,top+60},size={20,15},proc=$(ButonFunctionName),title="Rh",fsize=9
	Button Pd,pos={left+180,top+60},size={20,15},proc=$(ButonFunctionName),title="Pd",fsize=9
	Button Ag,pos={left+200,top+60},size={20,15},proc=$(ButonFunctionName),title="Ag",fsize=9
	Button Cd,pos={left+220,top+60},size={20,15},proc=$(ButonFunctionName),title="Cd",fsize=9
	Button In,pos={left+240,top+60},size={20,15},proc=$(ButonFunctionName),title="In",fsize=9
	Button Sn,pos={left+260,top+60},size={20,15},proc=$(ButonFunctionName),title="Sn",fsize=9
	Button Sb,pos={left+280,top+60},size={20,15},proc=$(ButonFunctionName),title="Sb",fsize=9
	Button Te,pos={left+300,top+60},size={20,15},proc=$(ButonFunctionName),title="Te",fsize=9
	Button I,pos={left+320,top+60},size={20,15},proc=$(ButonFunctionName),title="I",fsize=9
	Button Xe,pos={left+340,top+60},size={20,15},proc=$(ButonFunctionName),title="Xe",fsize=9
	Button Cs,pos={left,top+75},size={20,15},proc=$(ButonFunctionName),title="Cs",fsize=9
	Button Ba,pos={left+20,top+75},size={20,15},proc=$(ButonFunctionName),title="Ba",fsize=9
	Button La,pos={left+40,top+75},size={20,15},proc=$(ButonFunctionName),title="La",fsize=9
	Button Hf,pos={left+60,top+75},size={20,15},proc=$(ButonFunctionName),title="Hf",fsize=9
	Button Ta,pos={left+80,top+75},size={20,15},proc=$(ButonFunctionName),title="Ta",fsize=9
	Button W,pos={left+100,top+75},size={20,15},proc=$(ButonFunctionName),title="W",fsize=9
	Button Re,pos={left+120,top+75},size={20,15},proc=$(ButonFunctionName),title="Re",fsize=9
	Button Os,pos={left+140,top+75},size={20,15},proc=$(ButonFunctionName),title="Os",fsize=9
	Button Ir,pos={left+160,top+75},size={20,15},proc=$(ButonFunctionName),title="Ir",fsize=9
	Button Pt,pos={left+180,top+75},size={20,15},proc=$(ButonFunctionName),title="Pt",fsize=9
	Button Au,pos={left+200,top+75},size={20,15},proc=$(ButonFunctionName),title="Au",fsize=9
	Button Hg,pos={left+220,top+75},size={20,15},proc=$(ButonFunctionName),title="Hg",fsize=9
	Button Tl,pos={left+240,top+75},size={20,15},proc=$(ButonFunctionName),title="Tl",fsize=9
	Button Pb,pos={left+260,top+75},size={20,15},proc=$(ButonFunctionName),title="Pb",fsize=9
	Button Bi,pos={left+280,top+75},size={20,15},proc=$(ButonFunctionName),title="Bi",fsize=9
	Button Po,pos={left+300,top+75},size={20,15},proc=$(ButonFunctionName),title="Po",fsize=9
	Button At,pos={left+320,top+75},size={20,15},proc=$(ButonFunctionName),title="At",fsize=9
	Button Rn,pos={left+340,top+75},size={20,15},proc=$(ButonFunctionName),title="Rn",fsize=9
	Button Fr,pos={left,top+90},size={20,15},proc=$(ButonFunctionName),title="Fr",fsize=9
	Button Ra,pos={left+20,top+90},size={20,15},proc=$(ButonFunctionName),title="Ra",fsize=9
	Button Ac,pos={left+40,top+90},size={20,15},proc=$(ButonFunctionName),title="Ac",fsize=9
	Button Ce,pos={left+80,top+105},size={20,15},proc=$(ButonFunctionName),title="Ce",fsize=9
	Button Pr,pos={left+100,top+105},size={20,15},proc=$(ButonFunctionName),title="Pr",fsize=9
	Button Nd,pos={left+120,top+105},size={20,15},proc=$(ButonFunctionName),title="Nd",fsize=9
	Button Pm,pos={left+140,top+105},size={20,15},proc=$(ButonFunctionName),title="Pm",fsize=9
	Button Sm,pos={left+160,top+105},size={20,15},proc=$(ButonFunctionName),title="Sm",fsize=9
	Button Eu,pos={left+180,top+105},size={20,15},proc=$(ButonFunctionName),title="Eu",fsize=9
	Button Gd,pos={left+200,top+105},size={20,15},proc=$(ButonFunctionName),title="Gd",fsize=9
	Button Tb,pos={left+220,top+105},size={20,15},proc=$(ButonFunctionName),title="Tb",fsize=9
	Button Dy,pos={left+240,top+105},size={20,15},proc=$(ButonFunctionName),title="Dy",fsize=9
	Button Ho,pos={left+260,top+105},size={20,15},proc=$(ButonFunctionName),title="Ho",fsize=9
	Button Er,pos={left+280,top+105},size={20,15},proc=$(ButonFunctionName),title="Er",fsize=9
	Button Tm,pos={left+300,top+105},size={20,15},proc=$(ButonFunctionName),title="Tm",fsize=9
	Button Yb,pos={left+320,top+105},size={20,15},proc=$(ButonFunctionName),title="Yb",fsize=9
	Button Lu,pos={left+340,top+105},size={20,15},proc=$(ButonFunctionName),title="Lu",fsize=9
	Button Th,pos={left+80,top+120},size={20,15},proc=$(ButonFunctionName),title="Th",fsize=9
	Button Pa,pos={left+100,top+120},size={20,15},proc=$(ButonFunctionName),title="Pa",fsize=9
	Button U,pos={left+120,top+120},size={20,15},proc=$(ButonFunctionName),title="U",fsize=9
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
