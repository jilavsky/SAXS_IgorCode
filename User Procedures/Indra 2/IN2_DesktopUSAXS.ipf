#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3			// Use modern global access method.
//#pragma rtGlobals=1		// Use modern global access method.
#pragma version=0.3


//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//0.3 remove unused functions

// This is  version 1 of Igor Pro macros for reduction of desktop USAXS (Osmotic/Rigaku) data to pass them into Indra 2 package.
// Note, this is BETA version 2
// The code is open source and provided with No warranties.
// The code at this time is not to be distributed and is provided by author, Jan Ilavsky (ilavsky@aps.anl.gov) for evaluation and development purposes ONLY.
// To use this code, you will need also Indra 2 package and Irena package, all available for free from my web site: www.uni.aps.anl.gov/~ilavsky
// Since this program is provided for free and ONLY by author, if you paid for this program or did not receive it from author, please report this immediately to the author. 

// To use: e-mail author : ilavsky@aps.anl.gov

// Known issues:
/// 	The calibration is probably right, but has not been tested. 
//	probably still problem and error estimate from USAXS is still high... 
//	add also wave notes, so the damn thing knows who and what... 
//	this is very cumbersome, need beteer interface...
// 	Indra 2 package needs to be modified - it seems to have probelms with sample-to-detector distance for desktop USAXS and few other issues...


//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************

Function  IN2U_LoadDesktopData()
	
	IN2U_Initialize()

	DoWindow IN2U_MainDektpUSAXSPanel
	if(V_Flag)
		DoWindow/F IN2U_MainDektpUSAXSPanel
	else
		Execute("IN2U_MainDektpUSAXSPanel()")
	endif


end
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************

Window IN2U_MainDektpUSAXSPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(48,60,426,612) as "Load Desktop USAXS data "
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1
	DrawText 2,22,"Load Desktop USAXS dat and check parameters"
	Button SelectDataPath,pos={13,40},size={130,20},proc=IN2U_ButtonProc,title="Select data path"
	Button SelectDataPath,help={"Select data path to the data"}
	Button SelectDataPath,font="Times New Roman",fSize=10
	SetVariable DataPathString,pos={2,73},size={373,16},title="Data path :"
	SetVariable DataPathString,help={"This is currently selected data path where Igor looks for the data"}
	SetVariable DataPathString,fSize=12, frame=0
	SetVariable DataPathString,limits={-inf,inf,0},value= root:Packages:DesktopUSAXSImport:DataPathName,noedit= 1
	SetVariable DataExtensionString,pos={207,44},size={150,16},proc=IN2U_SetVarProc,title="Data extension:"
	SetVariable DataExtensionString,help={"Insert extension string to mask data of only some type (dat, txt, ...)"}
	SetVariable DataExtensionString,fSize=12, variable=root:Packages:DesktopUSAXSImport:DataExtension

	ListBox ListOfAvailableData,pos={3,95},size={270,170}
	ListBox ListOfAvailableData,help={"Select files from this location you want to import"}
	ListBox ListOfAvailableData,listWave=root:Packages:DesktopUSAXSImport:WaveOfFiles
	ListBox ListOfAvailableData,selWave=root:Packages:DesktopUSAXSImport:WaveOfSelections
	ListBox ListOfAvailableData,mode= 9

	Button Preview,pos={290,100},size={80,20},proc=IN2U_ButtonProc,title="Preview"
	Button Preview,help={"Preview selected file."},font="Times New Roman",fSize=10
	Button ReadHeader,pos={290,130},size={80,20},proc=IN2U_ButtonProc,title="Read Header"
	Button ReadHeader,help={"Test how if import can be succesful and how many waves are found"}
	Button ReadHeader,font="Times New Roman",fSize=10
	Button GetHelp,pos={290,160},size={80,20},proc=IN2U_ButtonProc,title="Help"
	Button GetHelp,help={"Get notebook with use description"},font="Times New Roman",fSize=10

	CheckBox UseFileNameAsUSAXSName,pos={25,270},size={100,14},title="Use file name as USAXS name?"
	CheckBox UseFileNameAsUSAXSName,help={"Check if you want to use file name as USAXS name instead of file name"}
	CheckBox UseFileNameAsUSAXSName,variable= root:Packages:DesktopUSAXSImport:UseFileNameAsUSAXSName

	SetVariable Description,pos={5,290},size={320,19},title="Sample description : "
	SetVariable Description,help={"This is the description of sample in the file"}
	SetVariable Description,fSize=12
	SetVariable Description,value= root:Packages:DesktopUSAXSImport:Description
	SetVariable UserName,pos={5,310},size={320,19},title="User name : "
	SetVariable UserName,help={"This is the user name in the file"},fSize=12
	SetVariable UserName,value= root:Packages:DesktopUSAXSImport:UserName

	SetVariable Wavelength,pos={5,330},size={320,19},title="Wavelength [A] : ", limits={0,10,0}
	SetVariable Wavelength,help={"This is Wavelength of used radiation in A"},fSize=12,proc=IN2U_SetVarProc
	SetVariable Wavelength,value= root:Packages:DesktopUSAXSImport:Wavelength
	SetVariable energy,pos={5,355},size={320,19},title="X-ray energy [keV]: "
	SetVariable energy,help={"X-ray energy use"},fSize=12,proc=IN2U_SetVarProc
	SetVariable energy,limits={5,25,0},value= root:Packages:DesktopUSAXSImport:energy
	PopupMenu BragUnits,pos={50,380},size={163,21},proc=IN2U_PopMenuProc_Fldr,title="Brag Angle units: "
	PopupMenu BragUnits,help={"Select units used for brag angle"}
	PopupMenu BragUnits,mode=1+WhichListItem(root:Packages:DesktopUSAXSImport:BragUnits, "Rad;arc sec;Arc Sec;Deg;Q[A^-1]"),value= #"\"Rad;arc sec;Arc Sec;Deg;Q[A^-1]\""
	SetVariable Thickness,pos={5,405},size={320,19},title="Sample thickness in [mm]: "
	SetVariable Thickness,help={"Sample thickness in mm, needed for absolute calibration!"}
	SetVariable Thickness,fSize=12
	SetVariable Thickness,limits={0.001,3000,0},value= root:Packages:DesktopUSAXSImport:Thickness

	SetVariable CurrentDataFile,pos={6,430},size={320,19},title="Data file loaded : "
	SetVariable CurrentDataFile,help={"This is name of loaded file"},fSize=12
	SetVariable CurrentDataFile,frame=0
	SetVariable CurrentDataFile,value= root:Packages:DesktopUSAXSImport:FileNameString,noedit= 1

	CheckBox ReduceNumPnts,pos={5,455},size={100,14},proc=IN2U_CheckProc,title="Reduce Num of points?"
	CheckBox ReduceNumPnts,help={"Check if you want to reduce number of points for the data in log binning"}
	CheckBox ReduceNumPnts,variable= root:Packages:DesktopUSAXSImport:ReduceNumberPnts
	SetVariable NewNumPnts,pos={10,485},size={320,20},disable=1,title="New num of points (approx): "
	SetVariable NewNumPnts,help={"New number of points. Approximate (will likely be larger)"}
	SetVariable NewNumPnts,fSize=14
	SetVariable NewNumPnts,limits={100,3000,0},value= root:Packages:DesktopUSAXSImport:NewNumPnts
	SetVariable NewNumPnts,disable=!(root:Packages:DesktopUSAXSImport:ReduceNumberPnts)

	Button LoadDataBtn,pos={100,520},size={165,20},proc=IN2U_ButtonProc,title="Load Selected Data"
	Button LoadDataBtn,help={"Click to load all selected data"}
	
	IN2U_UpdateListOfFilesInWvs()
EndMacro
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************

Function IN2U_ButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(cmpstr(ctrlName,"SelectDataPath")==0)
		IN2U_SelectDataPath()	
		IN2U_UpdateListOfFilesInWvs()
	endif
	if(cmpstr(ctrlName,"ReadHeader")==0)
		IN2U_TestReadHeader()
	endif
	if(cmpstr(ctrlName,"Preview")==0)
		IN2U_TestImportNotebook()
	endif
	if(cmpstr(ctrlName,"LoadDataBtn")==0)
		IN2U_LoadSelectedData()
	endif
	if(cmpstr(ctrlName,"GetHelp")==0)
		DoWIndow HelpForDesktopUSAXSnbk
		if(!V_Flag)
			Execute("HelpForDesktopUSAXS()")
		else
			DoWindow/F HelpForDesktopUSAXSnbk
		endif
	endif
//	if(cmpstr(ctrlName,"ImportData")==0)
//		IR1I_ImportDataFnct()
//	endif
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IN2U_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	if (cmpstr(ctrlName,"DataExtensionString")==0)
		IN2U_UpdateListOfFilesInWvs()
	endif
	if (cmpstr(ctrlName,"Wavelength")==0)
		NVAR Wavelength=root:Packages:DesktopUSAXSImport:Wavelength
		NVAR energy=root:Packages:DesktopUSAXSImport:energy
		energy = 12.398424437/wavelength
	endif
	if (cmpstr(ctrlName,"energy")==0)
		NVAR Wavelength=root:Packages:DesktopUSAXSImport:Wavelength
		NVAR energy=root:Packages:DesktopUSAXSImport:energy
		Wavelength = 12.398424437/energy
	endif
	
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function IN2U_SelectDataPath()

	NewPath /M="Select path to data to be imported" /O DesktopUSAXSDataPath
	if (V_Flag!=0)
		abort
	endif 
	PathInfo DesktopUSAXSDataPath
	SVAR DataPathName=root:Packages:DesktopUSAXSImport:DataPathName
	DataPathName = S_Path
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IN2U_UpdateListOfFilesInWvs()

	SVAR DataPathName = root:Packages:DesktopUSAXSImport:DataPathName
	SVAR DataExtension  = root:Packages:DesktopUSAXSImport:DataExtension
	Wave/T WaveOfFiles      = root:Packages:DesktopUSAXSImport:WaveOfFiles
	Wave WaveOfSelections = root:Packages:DesktopUSAXSImport:WaveOfSelections
	string ListOfAllFiles
	string LocalDataExtension
	variable i, imax
	LocalDataExtension = DataExtension
	if (cmpstr(LocalDataExtension[0],".")!=0)
		LocalDataExtension = "."+LocalDataExtension
	endif
	PathInfo DesktopUSAXSDataPath
	if(V_Flag && strlen(DataPathName)>0)
		if (strlen(LocalDataExtension)<=1)
			ListOfAllFiles = IndexedFile(DesktopUSAXSDataPath,-1,"????")
		else		
			ListOfAllFiles = IndexedFile(DesktopUSAXSDataPath,-1,LocalDataExtension)
		endif
		imax = ItemsInList(ListOfAllFiles,";")
		Redimension/N=(imax) WaveOfSelections
		Redimension/N=(imax) WaveOfFiles
		for (i=0;i<imax;i+=1)
			WaveOfFiles[i] = stringFromList(i, ListOfAllFiles,";")
		endfor
	else
		Redimension/N=0 WaveOfSelections
		Redimension/N=0 WaveOfFiles
	endif 
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function IN2U_LoadSelectedData()

	Wave/T WaveOfFiles      = root:Packages:DesktopUSAXSImport:WaveOfFiles
	Wave WaveOfSelections = root:Packages:DesktopUSAXSImport:WaveOfSelections
	variable i
	string curFlnm
	For(i=0;i<numpnts(WaveOfFiles);i+=1)
		if(WaveOfSelections[i]>=1)
			curFlnm=WaveOfFiles[i]
			IN2U_LoadSingleDesktopData(curFlnm)
		endif
	endfor
end
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************

Function  IN2U_LoadSingleDesktopData(FileNameString)
	string FileNameString
	
//	variable refnum
//	if(strlen(FileNameString)<1)
//		open/R/D/P=DesktopUSAXSDataPath/T=".dat"/M="Find file to load" refnum as FileNameString
//		//close refnum
//		FileNameString = stringFromList(ItemsInList(S_FileName,":")-1,S_FileName,":")
//	endif
//
	string NewFldrName
	
	NVAR ReduceNumberPnts=root:Packages:DesktopUSAXSImport:ReduceNumberPnts
//	IN2U_ReadDesktopUSAXSFile(FileNameString)
	IN2U_ReadDesktopUSAXSFileHeader(FileNameString)

	IN2U_LoadOneDesktopUSAXSDataSet(FileNameString)
	if(ReduceNumberPnts)
		IN2U_ReduceNumPnts()
	endif
	NewFldrName=IN2U_SaveCurrentlyLoadedDataSet()
	IN2U_ConvCurrentlyLoadedDataSet(NewFldrName)

end




//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************



//Function IN2U_CreateDesktopuSAXSPath()
//
//	NewPath /C/M="Find path with Desktop USAXS data" /O DesktopUSAXSDataPath  
//end

//Function/S IN2U_RemoveCR(stringWithCR)
//	string StringWithCR
//	
//	variable strlength=strlen(StringWithCR)
//		if(cmpstr(StringWithCR[strlength-1,inf],"\r")==0)
//			return stringWithCR[0,strlength-2]
//		else
//			return stringWithCR
//		endif
//end
//

//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************

Function IN2U_ReadDesktopUSAXSFileHeader(LFileNameString)
	string LFileNameString
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:DesktopUSAXSImport

	variable refNum
	open/R/P=DesktopUSAXSDataPath/T=".dat" refnum as LFileNameString
	if(strlen(S_fileName)==0)
		abort
	endif
	
	//now define working variables & strings...
	SVAR FileNameString
	FileNameString = LFileNameString

	SVAR UserName
	string LUserName=IN2U_findTagInFile(refNum,"User Name") 
	if(strlen(LUserName)>0)
		UserName = LUserName		//user name found, let's change it to thie new one...
	endif
	
	SVAR Description
	string LDescription=IN2U_findTagInFile(refNum,"Description") 
	if(strlen(LDescription)>0)
		Description = LDescription
	else
		Description = FileNameString
	endif
	
	string LSampleUnits
	LSampleUnits=IN2U_findTagInFile(refNum,"Sample units")
	SVAR SampleThicknessUnits
	if(strlen(LSampleUnits)>0)
		SampleThicknessUnits = LSampleUnits
	endif

	NVAR Thickness
	variable LThickness=str2num(IN2U_findTagInFile(refNum,"Thickness"))
	if(numtype(Lthickness)==0 && Lthickness >0)
		thickness=LThickness
		if(stringmatch(SampleThicknessUnits, "*cm*"))
			thickness=thickness*10
		elseif(stringmatch(SampleThicknessUnits, "*inch*"))
			thickness=thickness*25.4
		else	//should be in mm
			thickness=thickness	
		endif
	else
		if(Thickness==0)
			thickness=1
		endif
	endif
	
	NVAR Wavelength
	NVAR energy
	variable LWavelength=str2num(IN2U_findTagInFile(refNum,"Wavelength"))
	if(numtype(LWavelength)==0 && LWavelength>0)
		Wavelength=LWavelength
	else
		if(Wavelength<=0)
			Wavelength=1.540593226
		endif
	endif
	energy = 12.398424437/wavelength
	
	
	variable LBackground
	LBackground=str2num(IN2U_findTagInFile(refNum,"Background"))
	NVAR Background
	if(numtype(LBackground)==0 && LBackground>=0)
		Background = LBackground
	endif

	string LBragUnits
	LBragUnits=IN2U_findTagInFile(refNum,"Brag Units")
	SVAR BragUnits
	if(strlen(LBragUnits)>0)
		BragUnits = LBragUnits
	else
		if(strlen(BragUnits)==0)
			BragUnits="Arc Sec"		//need some default...
		endif
	endif
	
	
	NVAR CountTime
	CountTime=str2num(IN2U_findTagInFile(refNum,"Real Time"))
	NVAR StartAngle1
	StartAngle1=str2num(IN2U_findTagInFile(refNum,"Start Angle Range 1"))
	NVAR StopAngle1
	StopAngle1=str2num(IN2U_findTagInFile(refNum,"Stop Angle Range 1"))
	NVAR StepSize1
	StepSize1=str2num(IN2U_findTagInFile(refNum,"Step Size Range 1"))
	NVAR StopAngle2
	StopAngle2=str2num(IN2U_findTagInFile(refNum,"Stop Angle Range 2"))
	NVAR StepSize2
	StepSize2=str2num(IN2U_findTagInFile(refNum,"Step Size Range 2"))
	NVAR StopAngle3
	StopAngle3=str2num(IN2U_findTagInFile(refNum,"Stop Angle Range 3"))
	NVAR StepSize3
	StepSize3=str2num(IN2U_findTagInFile(refNum,"Step Size Range 3"))

		

	//all needed values from header read..
	Close refnum
	setDataFolder OldDf
end


//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
Function IN2U_LoadOneDesktopUSAXSDataSet(LFileNameString)
	string LFileNameString
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:DesktopUSAXSImport

//	variable refNum
//	open/R/P=DesktopUSAXSDataPath/T=".dat" refnum as LFileNameString
//	if(strlen(S_fileName)==0)
//		abort
//	endif


//	NVAR/Z ReduceNumPnts
//	if(!NVAR_Exists(ReduceNumPnts))
//		variable/g ReduceNumberPnts=1
//	endif
//	NVAR/Z NewNumPnts
//	if(!NVAR_Exists(NewNumPnts))
//		variable/g NewNumPnts=200
//	endif
//	
//	//get wavelength... 
//	NVAR/Z energy
//	SVAR/Z TubeType=root:Packages:DesktopUSAXSImport:TubeType
//	if(!SVAR_Exists(TubeType))
//		string/g TubeType="Cu, 1.54A"
//	endif
//	if(!NVAR_Exists(energy))
//		variable/g energy
//		if (stringmatch(TubeType, "Cu, 1.54A"))
//			energy = 8.04778
//		elseif(stringmatch(TubeType, "Mo, 0.71A"))
//			energy = 17.47934
//		else
//			energy = 8.04778		//default to Cu
//		endif
//	endif
//
//	//get user input
//	Execute("IN2U_CheckDektpUSAXSParams()")
//	PauseForUser IN2U_CheckDektpUSAXSParams
//
//	
	SVAR BragUnits
	KillWaves/Z wave0,wave1,wave2,wave3,wave4,wave5
	KillWaves/Z Angle,Realtime,Counts,Rate,Factor,ScaledRate
	LoadWave/Q/N/G/P=DesktopUSAXSDataPath  LFileNameString
	Rename wave0 Angle
	Rename wave1 Realtime
	Rename wave2 Counts
	Rename wave3 Rate
	Rename wave4 Factor
	Rename wave5 ScaledRate
	Wave Angle
	//Fix Angle to degrees
	if(cmpstr(BragUnits,"arc sec" )==0)
		Angle = Angle/3600
	elseif(cmpstr(BragUnits,"Rad" )==0)		
		Angle = Angle/0.0174532925			//converts rads to deg - 1 degree = 0.0174532925 rad
	elseif(cmpstr(BragUnits,"Deg" )==0)	
		Angle = Angle    					
	elseif(cmpstr(BragUnits,"Q[A^-1]" )==0)	
		DoAlert 0, "not finished Conversion to angle in IN2U_ReadDesktopUSAXSFile"
		abort
		Angle = Angle    					//Q unit - in inverse angstroems... Need to fix
	else
		Angle = Angle    					//No units default to degrees??
	endif

	SVAR SourceFileName=root:Packages:DesktopUSAXSImport:SourceFileName
	SourceFileName=LFileNameString

	setDataFolder OldDf

end

//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************


Function IN2U_CheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if(stringmatch(ctrlName,"ReduceNumPnts"))
		setVariable NewNumPnts, win=IN2U_MainDektpUSAXSPanel, disable=!checked
	endif
End
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************


Function IN2U_PopMenuProc_Fldr(ctrlName,popNum,popStr) : PopupMenuControl		//sets folder to raw subfolder if selected
	String ctrlName
	Variable popNum
	String popStr
	
	if (stringmatch(ctrlName, "TubeType"))
		NVAR energy = root:Packages:DesktopUSAXSImport:energy
		SVAR TubeType=root:Packages:DesktopUSAXSImport:TubeType
		if (stringmatch(popStr, "Cu, 1.54A"))
			setVariable energy, win=IN2U_CheckDektpUSAXSParams, noedit=1
			energy = 12.398424437/1.540593226
		elseif(stringmatch(popStr, "Mo, 0.71A"))
			setVariable energy, win=IN2U_CheckDektpUSAXSParams, noedit=1
			energy = 17.47934
		else
			setVariable energy, win=IN2U_CheckDektpUSAXSParams, noedit=0
		endif
		TubeType = popStr
	endif

	if (stringmatch(ctrlName, "TubeType"))
		SVAR BragUnits=root:Packages:DesktopUSAXSImport:BragUnits
		BragUnits = popStr
	endif
End

//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************




Function IN2U_ReduceNumPnts()

	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:DesktopUSAXSImport:
	NVAR ReduceNumberPnts=root:Packages:DesktopUSAXSImport:ReduceNumberPnts
	NVAR NewNumPnts=root:Packages:DesktopUSAXSImport:NewNumPnts
	wave Angle
	wave RealTime
	wave Counts
	wave Rate
	wave Factor
	wave ScaledRate
	
	if(!ReduceNumberPnts)
		return 0
	endif
	
	setDataFolder root:
	NewDataFolder/O/S Packages
	NewDataFolder/O/S DesktopTemp
		//here we need to reduce the data into sensible units... But what do we do with ranges? 
		//first figure out new angles... Log spaced
		variable AngleStep, maxAngleValue, minAngleValue
		wavestats/Q angle
		maxAngleValue=V_max
		minAngleValue=V_min
		AngleStep = (V_max-V_min)/V_npnts
		//when do we leave the peak area? 
		variable PeakAreaPntMax=BinarySearch(Angle, (-1*minAngleValue) )
		PeakAreaPntMax=floor(PeakAreaPntMax)+1
		//now need ot get the right number of points. Will  merge progressively larger number of points... 
		variable NumPointsLeftToReduce = numpnts(Angle) - PeakAreaPntMax
		variable AveRatioToReduce = ( NumPointsLeftToReduce / (NewNumPnts-PeakAreaPntMax))		//average number of points reduction, real be twice as much... 
	//	variable binOldPoints = floor(NumPointsLeftToReduce/(2*AveRatioToReduce)) -1							//this is how many points will be binned 1x, 2x, 3x, etc...
		
		variable corrNewNumPnts = NewNumPnts					//how many points we will need... 

		variable binNewPoints = round( (corrNewNumPnts - PeakAreaPntMax) / (2*AveRatioToReduce))//+ floor(AveRatioToReduce)				//this is how many points will be binned 1x, 2x, 3x, etc...
		
		Make/O/N=(corrNewNumPnts+binNewPoints) NewAngle, NewRealTime, NewCounts, NewRate, NewFactor,NewScaledRate
		//first PeakAreaPntMax must be the same as in the other wave...
		NewAngle[0,PeakAreaPntMax] = Angle[p]
		NewCounts[0,PeakAreaPntMax] = Counts[p]
		NewRealTime[0,PeakAreaPntMax] = RealTime[p]
		NewRate[0,PeakAreaPntMax] = Rate[p]
		NewFactor[0,PeakAreaPntMax] = Factor[p]
		NewScaledRate[0,PeakAreaPntMax] = ScaledRate[p]

		variable i, j, jj, imax=numpnts(NewAngle)
		variable curMinAngle, curmaxAngle, curMinAnglePnt, curMaxAnglePnt, curOldPoint, curNewPoint
		
		curNewPoint = PeakAreaPntMax		//first point to fill...
		curOldPoint = PeakAreaPntMax			//first point to use...
		variable binByPnts=0
		
		For(i=0;i<(2*AveRatioToReduce)+2;i+=1)				//goes through left points on new wave to fill in.
			binByPnts+=1
			For(j=0;j<binNewPoints;j+=1)			//this this is num of old points to summ
				curNewPoint+=1
				curOldPoint+=1
				NewAngle[curNewPoint]=0
				NewCounts[curNewPoint]=0
				NewRealTime[curNewPoint]=0
				NewRate[curNewPoint]=0
				NewFactor[curNewPoint]=0
				NewScaledRate[curNewPoint]=0
					For(jj=0;jj<binByPnts;jj+=1)
						NewAngle[curNewPoint]+=Angle[curOldPoint+jj]
						NewCounts[curNewPoint]+=Counts[curOldPoint+jj] * Factor[curOldPoint+jj]
						NewRealTime[curNewPoint]+=RealTime[curOldPoint+jj]
						NewRate[curNewPoint]+=Rate[curOldPoint+jj] * Factor[curOldPoint+jj]
						NewFactor[curNewPoint]=Factor[curOldPoint+jj]
						NewScaledRate[curNewPoint]+=ScaledRate[curOldPoint+jj]
					endfor
				NewAngle[curNewPoint] = NewAngle[curNewPoint] / binByPnts
				NewCounts[curNewPoint]= (NewCounts[curNewPoint] / binByPnts) / NewFactor[curNewPoint]
				NewRealTime[curNewPoint]=NewRealTime[curNewPoint]/binByPnts
				NewRate[curNewPoint]=(NewRate[curNewPoint]/binByPnts) / NewFactor[curNewPoint]
				NewFactor[curNewPoint]=NewFactor[curNewPoint]
				NewScaledRate[curNewPoint]=NewScaledRate[curNewPoint]/binByPnts

				curOldPoint+=binByPnts-1
			endfor			
		
		endfor
		
		variable endOfData=BinarySearch(NewAngle, Angle[numpnts(Angle)-2] ) + 1
		variable NumPntsToDeleet= numpnts(NewAngle) - endOfData
		DeletePoints endOfData, NumPntsToDeleet, NewAngle, NewCounts, NewRealTime, NewRate, NewFactor, NewScaledRate
		
		Duplicate/O  NewAngle, $("root:Packages:DesktopUSAXSImport:Angle")
		Duplicate/O 	NewCounts, $("root:Packages:DesktopUSAXSImport:Counts")
		Duplicate/O 	NewRealTime, $("root:Packages:DesktopUSAXSImport:RealTime")
		Duplicate/O 	NewRate, $("root:Packages:DesktopUSAXSImport:Rate")
		Duplicate/O 	NewFactor, $("root:Packages:DesktopUSAXSImport:Factor")
		Duplicate/O 	NewScaledRate, $("root:Packages:DesktopUSAXSImport:ScaledRate")
		
	
	setDataFolder OldDf
//	KillDataFolder root:Packages:DesktopTemp
end

//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************



Function/T IN2U_findTagInFile(fileRef,tagStr)        // returns the 'value'  string associated with the tag
        Variable fileRef                                // ref to an opened file
        String tagStr                           // the tag to search for


        String line
        Variable i,c, tagLen=strlen(tagStr)
        FSetPos fileRef,0
        do
                FReadLine fileRef, line
                i = strsearch(line,tagStr,0,2)
              ///  i = (i==0 && char2num(line[tagLen])>32) ? -1 : i                // in case tag is  a substring of line
              if(i>=0)
              	line=ReplaceString("\r", line, ";")
              	return StringByKey(tagStr, line , ":" , ";")
              endif
        while (i<0 && strlen(line)>0)
        return ""
end


//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************



Function/T IN2U_SaveCurrentlyLoadedDataSet()

	string OldDf=GetDataFolder(1)
	if(!DataFolderExists("root:Packages:DesktopUSAXSImport"))
		abort
	endif
	setDataFolder root:Packages:DesktopUSAXSImport
	Wave Angle
	Wave RealTime
	Wave Counts
	Wave Rate
	Wave Factor
	Wave ScaledRate
//	NVAR LThickness=Thickness
//	NVAR LBackground=Background
//	NVAR LCountTime=CountTime
//	SVAR LUserName=UserName
//	SVAR LDescription=Description
	SVAR LSourceFileName=SourceFileName
//	NVAR LdetectorSize=detectorSize
//	NVAR LdetectorDistance=detectorDistance
//	NVAR Lenergy=energy


	//folders 
	NewDataFolder/O/S root:raw
	string NewFldrName=cleanupName(LSourceFileName[0,strlen(LSourceFileName)-5],1)

	if(DataFolderExists(NewFldrName))
		DoAlert 2, "Raw Data folder for this file (with this name) exists, Overwrite (Yes), Let code modify the Name (No), or Cancle?"
		if(V_Flag==3)
			abort
		endif
		if(V_Flag==2)
			NewFldrName=UniqueName(NewFldrName, 11, 0  )
		endif
	endif
	
	NewDataFolder /O/S $(NewFldrName)
	NewFldrName=possiblyQuoteName(NewFldrName)
	
	Duplicate /O Angle, $("root:raw:"+NewFldrName+":Angle")
	Duplicate /O ScaledRate, $("root:raw:"+NewFldrName+":ScaledRate")
	Duplicate /O RealTime, $("root:raw:"+NewFldrName+":RealTime")
	Duplicate /O Counts, $("root:raw:"+NewFldrName+":Counts")
	Duplicate /O Factor, $("root:raw:"+NewFldrName+":Factor")
	Duplicate /O Rate, $("root:raw:"+NewFldrName+":Rate")

	string ListOfVariables
	string ListOfStrings, tempNm
	variable i
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="DetectorSize;DetectorDistance;Energy;Wavelength;"
	ListOfVariables+="Thickness;CountTime;StartAngle1;StopAngle1;StopAngle2;StopAngle3;"
	ListOfVariables+="StepSize1;StepSize2;StepSize3;ReduceNumberPnts;Background;NewNumPnts;"

	ListOfStrings="UserComment;UserName;DataPathName;SourceFileName;Description;"
	ListOfStrings+="DataExtension;FileNameString;UserName;SampleThicknessUnits;BragUnits;"
	
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		tempNm=StringFromList(i,ListOfVariables)
		NVAR TempVar = $("root:Packages:DesktopUSAXSImport:"+tempNm)
		variable/g $(tempNm)=tempVar
		IN2G_AppendNoteToAllWaves(tempNm,num2str(TempVar))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		tempNm=StringFromList(i,ListOfStrings)
		SVAR TempStr = $("root:Packages:DesktopUSAXSImport:"+tempNm)
		string/g $(tempNm)=TempStr
		IN2G_AppendNoteToAllWaves(tempNm,TempStr)
	endfor	
	setDataFolder OldDf
	
	return NewFldrName
	
end

//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************




Function IN2U_ConvCurrentlyLoadedDataSet(DataFolderName)
	string DataFolderName

	string OldDf=GetDataFolder(1)
	if(!DataFolderExists("root:raw:"+DataFolderName))
		abort
	endif
	setDataFolder $("root:raw:"+DataFolderName)
	Wave Angle
	Wave RealTime
	Wave Counts
	Wave Rate
	Wave Factor
	Wave ScaledRate
	NVAR Thickness
	NVAR Background
	NVAR CountTime
	SVAR UserName
	SVAR Description
	SVAR SourceFileName
	NVAR detectorSize
	NVAR detectorDistance
	NVAR energy
	NVAR UseFileNameAsUSAXSName = root:Packages:DesktopUSAXSImport:UseFileNameAsUSAXSName
	
	//folders 
	NewDataFolder/O/S root:USAXS
	string NewFldrName
	if(strlen(Description)>1)
		NewFldrName=cleanupName(Description,1)
	else
		NewFldrName=""
	endif
	if(strlen(NewFldrName)<2 || UseFileNameAsUSAXSName)		//OK, probrbaly no user defined anem in the file... Use DataFolderName also...
		NewFldrName = IN2G_RemoveExtraQuote(DataFolderName,1,1)
	endif
	if(DataFolderExists(NewFldrName))
		DoAlert 2, "USAXS Data folder with this name exists, Overwrite, Change Name, Cancle?"
		if(V_Flag==3)
			abort
		endif
		if(V_Flag==2)
			NewFldrName=UniqueName(NewFldrName, 11, 0  )
		endif
	endif
	
	NewDataFolder /O $(NewFldrName)
	NewFldrName=possiblyQuoteName(NewFldrName)
	
	setDataFolder $("root:raw:"+DataFolderName)
	Duplicate /O Angle, $("root:USAXS:"+NewFldrName+":Ar_encoder")
	Duplicate /O Rate, $("root:USAXS:"+NewFldrName+":USAXS_PD")
	Duplicate /O Angle, $("root:USAXS:"+NewFldrName+":MeasTime")
	Duplicate /O Angle, $("root:USAXS:"+NewFldrName+":PD_range")
	Duplicate /O Angle, $("root:USAXS:"+NewFldrName+":Monitor")


	Wave Encoder=$("root:USAXS:"+NewFldrName+":Ar_encoder")
	Encoder=-1*Encoder
	Wave FudgeTime=$("root:USAXS:"+NewFldrName+":MeasTime")
	FudgeTime=RealTime
	Wave PD_Range=$("root:USAXS:"+NewFldrName+":PD_range")
	
	//fix PD_Range and get the conversion factors
	variable rng5=0, rng4=0,rng3=0,rng2=0,rng1=0, curvalue=0, curIndex=6
	variable i,j, found=0
	make/N=0/O RangeVals, RangeValsIndex
	For(i=numpnts(Rate)-1;i>=0;i-=1)
		if(abs(Factor[i]-curvalue)<0.001)
			PD_range[i]=curIndex
		else
			For(j=0;j<(numpnts(RangeVals));j+=1)
				if(abs(RangeVals[j]-Factor[i])<0.001)
					PD_range[i]=RangeValsIndex[j]
					found=1
					break
				else
					found=0
				endif
			endfor
			if(!found)
				Redimension/N=(numpnts(RangeVals)+1) RangeVals,RangeValsIndex
				RangeVals[numpnts(RangeVals)-1] = Factor[i]
				curvalue = Factor[i]
				curIndex=curIndex-1
				RangeValsIndex[numpnts(RangeVals)-1]=curIndex
				PD_range[i]=curIndex
			endif
		endif
	endfor
	redimension/N=5 RangeVals
	rng5=1/RangeVals[0]
	rng4=1/RangeVals[1]
	rng3=1/RangeVals[2]
	rng2=1/RangeVals[3]
	rng1=1/RangeVals[4]

	Wave Monitor = $("root:USAXS:"+NewFldrName+":Monitor")
	Monitor = 1e16
	variable NumPoints = numpnts(Angle)
	SetDataFolder $("root:USAXS:"+NewFldrName)

//	variable energy = 12.398424437/1.540593226		//CuKalpha1
	variable/g SampleThickness = Thickness
	string/g SpecComment = Description
	string/g SpecSourceFileName = SourceFileName
	string/g SpecCommand="uascan ar 10.5848 10.5818 -1.4215 0.0002  104.58 "+num2str(detectorDistance)+" 0 195 1.2 "+num2str(NumPoints)+" 5"
	//uascan  ar 10.5848 10.5818 -1.4215 0.0002  104.58 440 0 195 1.2 150 5
//	NVAR detectorSize
//	NVAR detectorDistance
//	NVAR energy

	string/g MeasurementParameters=""
	MeasurementParameters="DCM_energy="+num2str(energy)+";UPD2mode=2;UPD2range=4;UPD2vfc=1;UPD2gain=1;UPD2selected=1;UPD2gain1="+num2str(rng1)+";"
	MeasurementParameters+="UPD2bkg1=0;UPD2bkgErr1=0;UPD2gain2="+num2str(rng2)+";UPD2bkg2=0;UPD2bkgErr2=0;UPD2gain3="+num2str(rng3)+";"
	MeasurementParameters+="UPD2bkg3=0;UPD2bkgErr3=0;UPD2gain4="+num2str(rng4)+";UPD2bkg4=0;UPD2bkgErr4=0;UPD2gain5="+num2str(rng5)+";"
	MeasurementParameters+="UPD2bkg5=0;UPD2bkgErr5=0;thickness="+num2str(Thickness)+";ARenc_0=0;SAD=10;SDD="+num2str(detectorDistance)+";"
	string/g UPDParameters=""
	UPDParameters="Vfc=1;Gain1="+num2str(rng1)+";Gain2="+num2str(rng2)+";Gain3="+num2str(rng3)+";Gain4="+num2str(rng4)+";Gain5="+num2str(rng5)+";Bkg1=0;"
	UPDParameters+="Bkg2=0;Bkg3=0;Bkg4=0;Bkg5=0;Bkg1Err=0;Bkg2Err=0;Bkg3Err=0;Bkg4Err=0;Bkg5Err=0;I0AmpDark=0;"
	//check for PD size... 
	
	string/g PathToRawData
	PathToRawData=("root:raw:"+DataFolderName)
	NVAR/Z PhotoDiodeSize = root:Packages:Indra3:PhotoDiodeSize
	if(!NVAR_Exists(PhotoDiodeSize))
		setDataFolder root:
		NewDataFolder/O/S Packages
		NewDataFolder/O/S USAXS
		variable/g PhotoDiodeSize
	endif
	PhotoDiodeSize = detectorSize
	
	setDataFolder OldDf
	
end

//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************


//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
Function IN2U_Initialize()

	string OldDf=GetDataFolder(1)
	newDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:DesktopUSAXSImport



	string ListOfVariables
	string ListOfStrings
	variable i
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="DetectorSize;DetectorDistance;Energy;Wavelength;UseFileNameAsUSAXSName;"
	ListOfVariables+="Thickness;CountTime;StartAngle1;StopAngle1;StopAngle2;StopAngle3;"
	ListOfVariables+="StepSize1;StepSize2;StepSize3;ReduceNumberPnts;Background;NewNumPnts;"

	ListOfStrings="UserComment;UserName;DataPathName;SourceFileName;Description;"
	ListOfStrings+="DataExtension;FileNameString;UserName;SampleThicknessUnits;BragUnits;"
	
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	
	make/O/T/N=0 WaveOfFiles
	make/O/N=0 WaveOfSelections
	
//	
//	NVAR DetectorSize
//	if(!NVAR_Exists(DetectorSize))
//		variable/G DetectorSize = 30
//	endif
//	NVAR/Z DetectorDistance
//	if(!NVAR_Exists(DetectorDistance))
//		variable/G DetectorDistance = 218
//	endif
//	NVAR/Z energy
//	if(!NVAR_Exists(energy))
//		variable/G energy =  8.04778
//	endif
	NVAR DetectorSize
	NVAR DetectorDistance
	if(DetectorSize<=0 || DetectorDistance<=0)
		IN2U_GetParameters()
	endif
	NVAR NewNumPnts
	if(NewNumPnts<=0)
		NewNumPnts=200
	endif
	//need to set Guass as fitting function:   
	//Added for David Londono 2020-02-10
	variable/g root:Packages:Indra3:UseGauss
	variable/g root:Packages:Indra3:UseModifiedGauss
	variable/g root:Packages:Indra3:UseLorenz
	NewDataFolder/O root:Packages:Indra3
	NVAR UseGauss = root:Packages:Indra3:UseGauss
	NVAR UseModGauss = root:Packages:Indra3:UseModifiedGauss
	NVAR UseLor = root:Packages:Indra3:UseLorenz
	UseGauss = 1
	UseModGauss = 0
	UseLor = 0
	//end of fix to use Gauss 
	setDataFolder OldDf
end


//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************

Function IN2U_GetParameters()
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:DesktopUSAXSImport
	NVAR DetectorSize
	NVAR DetectorDistance
	variable LDetectorSize=30
	variable LDetectorDistance=218
	Prompt LDetectorSize, "Input detector size in mm"
	Prompt LDetectorDistance, "Input detector distance in mm"
	DoPrompt "Check USAXS parameters", LDetectorSize, LDetectorDistance
	if(V_Flag)
		abort
	endif
	DetectorSize=LDetectorSize
	DetectorDistance=LDetectorDistance
		
	setDataFolder OldDf

end
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************
//***********************************************************************************************************


Function IN2U_TestImportNotebook()

	Wave/T WaveOfFiles      = root:Packages:DesktopUSAXSImport:WaveOfFiles
	Wave WaveOfSelections = root:Packages:DesktopUSAXSImport:WaveOfSelections
	variable i, imax, firstSelectedPoint, maxWaves
	string SelectedFile
	imax = numpnts(WaveOfSelections)
	firstSelectedPoint = NaN
	For(i=0;i<numpnts(WaveOfSelections);i+=1)
		if(WaveOfSelections[i]==1)
			firstSelectedPoint = i
			break
		endif
	endfor
	if (numtype(firstSelectedPoint)==2)
		abort
	endif
	selectedfile = WaveOfFiles[firstSelectedPoint]
	
	
	//LoadWave/Q/A/G/P=DesktopUSAXSDataPath  selectedfile
	KillWIndow/Z FilePreview
 	OpenNotebook /K=1 /N=FilePreview /P=DesktopUSAXSDataPath /R /V=1 selectedfile
	MoveWindow /W=FilePreview 350, 5, 700, 400	
end

//***********************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IN2U_TestReadHeader()
	
	Wave/T WaveOfFiles      = root:Packages:DesktopUSAXSImport:WaveOfFiles
	Wave WaveOfSelections = root:Packages:DesktopUSAXSImport:WaveOfSelections

	variable i, imax, firstSelectedPoint, maxWaves
	string SelectedFile
	imax = numpnts(WaveOfSelections)
	firstSelectedPoint = NaN
	For(i=0;i<numpnts(WaveOfSelections);i+=1)
		if(WaveOfSelections[i]==1)
			firstSelectedPoint = i
			break
		endif
	endfor
	if (numtype(firstSelectedPoint)==2)
		abort
	endif
	selectedfile = WaveOfFiles[firstSelectedPoint]

	IN2U_ReadDesktopUSAXSFileHeader(selectedfile)	

	SVAR tempS=root:Packages:DesktopUSAXSImport:BragUnits
	PopupMenu BragUnits,win=IN2U_MainDektpUSAXSPanel, mode=1+WhichListItem(tempS, "Rad;arc sec;Arc Sec;Deg;Q[A^-1];"),value= #"\"Rad;arc sec;Arc Sec;Deg;Q[A^-1]\""
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Window HelpForDesktopUSAXS()
	String nb = "HelpForDesktopUSAXSnbk"
	NewNotebook/N=$nb/F=1/V=1/K=1/W=(327,44,824.25,491.75) 
	Notebook $nb defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",10,0,(0,0,0)}
	Notebook $nb newRuler=Top, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",12,1,(0,0,0)}
	Notebook $nb ruler=Top, text="Help for \"Load Desktop USAXS data\" tool\r"
	Notebook $nb ruler=Normal
	Notebook $nb text="This tool is for loading NEW data structure from Osmic/Rigaku desktop USAXS instrument. This is beta ver"
	Notebook $nb text="sion and there are likely to be bugs. \r"
	Notebook $nb text="\r"
	Notebook $nb text="Process:\r"
	Notebook $nb text="1. Select data path using the button (top left corner). You can limit data showing only to some extensio"
	Notebook $nb text="n using the field right top. \".dat\" or just \"dat\" works the same.\r"
	Notebook $nb text="\tData path is displayed below the button and the selection window should be populated by selection of fi"
	Notebook $nb text="les.\r"
	Notebook $nb text="\r"
	Notebook $nb text="2. You can preview selected file (opens in notebook which you CANNOT edit) and test how the header is re"
	Notebook $nb text="ad. Note, if there is no file selected in the selection window, these buttons do nothing. If more than o"
	Notebook $nb text="ne file is selected, only the first is opened/tested. \r"
	Notebook $nb text="\tValues not found in header are replaced by default values.\r"
	Notebook $nb text="\tReview the list and see, if all values/strings were imported correctly. If some are missing, select pro"
	Notebook $nb text="per value - or fill in what you need.  \r"
	Notebook $nb text="\r"
	Notebook $nb text="3. choose, if you want to reduce number of points - the points are reduced logarithmically. No points ar"
	Notebook $nb text="e removed at low q, and as q increases number of points are averaged together. Note, that thjis cahnges "
	Notebook $nb text="resolution function of the instrument. \r"
	Notebook $nb text="\r"
	Notebook $nb text="4. Select files to load, click on \"Load selected data\" button. Files will be loaded and converted to USA"
	Notebook $nb text="XS data automatically. \r"
	Notebook $nb text="\r"
	Notebook $nb text="Note:   \tHeader of each file is read first and if value exists there, it is used. If value is not found "
	Notebook $nb text="in the header, previous (NOT the default) are used. \r"
	Notebook $nb text="\tThere is, however, one exception. If no sample name is found in the file file name is used as sample de"
	Notebook $nb text="scription. \r"
	Notebook $nb text="\r"
	Notebook $nb text="*****************\r"
	Notebook $nb text="Now continue with \"Create R wave\" and then \"Subtract Blank from Sample\""
end