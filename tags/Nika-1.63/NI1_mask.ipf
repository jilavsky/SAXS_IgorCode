#pragma rtGlobals=1		// Use modern global access method.
#pragma version =1.16


//*************************************************************************\
//* Copyright (c) 2005 - 2010, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.16 added double click option to ListBox and added shift to accomodate tools when Start MASK draw is selected. 
//1.15 update for reversed color tables
//1.14 adds Nexus file format proper filter
//1.13 adds storing _mask file in hdf (5)., fixed low intensity masking... Did it ever work? 
//1.12 added mutlithread and MatrixOp/NTHR=1 where seemed possible to use multile cores
//1.11 added license for ANL



Function NI1M_CreateMask()
	//this function helps user to create mask
	
	NI1A_Initialize2Dto1DConversion()
	
	NI1M_CreateImageROIPanel()

end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1M_CreateImageROIPanel()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	DoWindow NI1M_ImageROIPanel
	if( V_Flag==1 )
		DoWindow/K NI1M_ImageROIPanel
	endif

	SVAR CCDFileExtension=root:Packages:Convert2Dto1D:CCDFileExtension
	SVAR ColorTableName=root:Packages:Convert2Dto1D:ColorTableName
	NVAR ImageRangeMaxLimit=root:Packages:Convert2Dto1D:ImageRangeMaxLimit
	NVAR ImageRangeMinLimit=root:Packages:Convert2Dto1D:ImageRangeMinLimit
	NVAR MaskOffLowIntPoints=root:Packages:Convert2Dto1D:MaskOffLowIntPoints
	NVAR LowIntToMaskOff=root:Packages:Convert2Dto1D:LowIntToMaskOff
	
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(22,58,450,560) as "Create MASK panel"
	Dowindow/C NI1M_ImageROIPanel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 19,fstyle= 1,textrgb= (0,0,65280)
	DrawText 62,30,"Prepare mask file"
	DrawText 18,92,"Select data set to use:"

	Button SelectPathToData,pos={27,44},size={150,20},proc=NI1M_RoiDrawButtonProc,title="Select path to data"
	Button SelectPathToData,help={"Adds drawing tools to top image graph. Use rectangle, circle or polygon."}
	PopupMenu CCDFileExtension,pos={207,44},size={101,21},proc=NI1M_MaskPopMenuProc,title="File type:"
	PopupMenu CCDFileExtension,help={"Select image type of data to be used"}
	PopupMenu CCDFileExtension,mode=1,popvalue=CCDFileExtension,value= #"root:Packages:Convert2Dto1D:ListOfKnownExtensions"

	ListBox CCDDataSelection,pos={17,95},size={300,150}//,proc=NI1M_ListBoxProc
	ListBox CCDDataSelection,help={"Select CCD file for which you want to create mask"}
	ListBox CCDDataSelection,listWave=root:Packages:Convert2Dto1D:ListOfCCDDataInCCDPath
	ListBox CCDDataSelection,row= 0,mode= 1,selRow= 0, proc=NI1_PrepMaskListBoxProc

	Button CreateROIWorkImage,pos={150,260},size={100,20},proc=NI1M_RoiDrawButtonProc,title="Make Image"

	Button LoadExistingMask,pos={265,260},size={150,20},proc=NI1M_RoiDrawButtonProc,title="Load Existing mask"
	Button LoadExistingMask,help={"Loads saved _mask file so it can be eddited more"}


	CheckBox MaskDisplayLogImage title="Display log image?",pos={20,260}
	CheckBox MaskDisplayLogImage proc=NI1M_MaskCheckProc,variable=MaskDisplayLogImage
	CheckBox MaskDisplayLogImage help={"Display data in the image as log intensity?"}

	Slider ImageRangeMin,pos={15,288},size={150,16},proc=NI1M_SliderProc
	Slider ImageRangeMin,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0},variable= root:Packages:Convert2Dto1D:ImageRangeMin,live= 0,side= 2,vert= 0,ticks= 0
	Slider ImageRangeMax,pos={15,308},size={150,16},proc=NI1M_SliderProc
	Slider ImageRangeMax,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0},variable= root:Packages:Convert2Dto1D:ImageRangeMax,live= 0,side= 2,vert= 0,ticks= 0
	PopupMenu ColorTablePopup,pos={30,330},size={107,21},proc=NI1M_MaskPopMenuProc,title="Colors"
	PopupMenu ColorTablePopup,mode=1,popvalue=ColorTableName,value= #"\"Grays;Rainbow;YellowHot;BlueHot;BlueRedGreen;RedWhiteBlue;PlanetEarth;Terrain;\""

	Button StartROI,pos={187,300},size={150,20},proc=NI1M_RoiDrawButtonProc,title="Start MASK Draw"
	Button StartROI,help={"Adds drawing tools to top image graph. Use rectangle, circle or polygon."}
	Button FinishROI,pos={187,330},size={150,20},proc=NI1M_RoiDrawButtonProc,title="Finish MASK"
	Button FinishROI,help={"Click after you are finished editing the ROI"}
	Button clearROI,pos={22,470},size={150,20},proc=NI1M_RoiDrawButtonProc,title="Erase MASK"
	Button clearROI,help={"Erases previous ROI. Not undoable."}
	Button saveROICopy,pos={200,470},size={150,20},proc=NI1M_saveRoiCopyProc,title="Save MASK"
	Button saveROICopy,help={"Saves current ROI as file outside Igor and also sets it as current mask"}
	SetVariable ExportMaskFileName,pos={5,445},size={355,16},title="Save as (\"_mask\" will be added) :"
	SetVariable ExportMaskFileName,help={"Name for the new mask file. Will be tiff file in the same place where the source data came from."}
	SetVariable ExportMaskFileName,limits={-Inf,Inf,0},value= root:Packages:Convert2Dto1D:ExportMaskFileName
	SetVariable RemoveFirstNColumns,pos={5,360},size={190,16},proc=NI1M_Mask_SetVarProc,title="Mask first columns :"
	SetVariable RemoveFirstNColumns,help={"Mask first N columns, remove mask manually"}
	SetVariable RemoveFirstNColumns,value= root:Packages:Convert2Dto1D:RemoveFirstNColumns
	SetVariable RemoveLastNColumns,pos={5,385},size={190,16},proc=NI1M_Mask_SetVarProc,title="Mask last columns :"
	SetVariable RemoveLastNColumns,help={"Mask last N columns, remove mask manually"}
	SetVariable RemoveLastNColumns,value= root:Packages:Convert2Dto1D:RemoveLastNColumns
	SetVariable RemoveFirstNRows,pos={206,360},size={190,16},proc=NI1M_Mask_SetVarProc,title="Mask first rows :"
	SetVariable RemoveFirstNRows,help={"Mask first N rows, remove mask manually"}
	SetVariable RemoveFirstNRows,value= root:Packages:Convert2Dto1D:RemoveFirstNRows
	SetVariable RemoveLastNRows,pos={206,385},size={190,16},proc=NI1M_Mask_SetVarProc,title="Mask last rows :"
	SetVariable RemoveLastNRows,help={"Mask last N rows, remove mask manually"}
	SetVariable RemoveLastNRows,value= root:Packages:Convert2Dto1D:RemoveLastNRows

	CheckBox MaskOffLowIntPoints title="Mask low Intensity points?",pos={10,410}
	CheckBox MaskOffLowIntPoints proc=NI1M_MaskCheckProc,variable=MaskOffLowIntPoints
	CheckBox MaskOffLowIntPoints help={"Mask of points with Intensity lower than selected threshold?"}
	SetVariable LowIntToMaskOff,pos={206,410},size={190,16},proc=NI1M_Mask_SetVarProc,title="Threshold Intensity :"
	SetVariable LowIntToMaskOff,help={"Intensity <= this thereshold"}, disable=!(MaskOffLowIntPoints)
	SetVariable LowIntToMaskOff,value= root:Packages:Convert2Dto1D:LowIntToMaskOff
	
	

	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************



Function NI1_PrepMaskListBoxProc(ctrlName,row,col,event) : ListBoxControl
	String ctrlName
	Variable row
	Variable col
	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
					//5=cell select with shift key, 6=begin edit, 7=end
	Variable i
	if(cmpstr(ctrlName,"CCDDataSelection")==0)
		if(event==3)		//double click
				NI1M_RoiDrawButtonProc("CreateROIWorkImage")
		endif
	endif
	return 0
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//***************************************** **************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1M_MaskCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D


	if(cmpstr(ctrlName,"MaskDisplayLogImage")==0)
		DoWindow CCDImageForMask
		if(!V_Flag)
			abort
		else
			DoWindow/F CCDImageForMask	
		endif
		NVAR MaskDisplayLogImage=root:Packages:Convert2Dto1D:MaskDisplayLogImage
		wave OriginalCCD=root:Packages:Convert2Dto1D:OriginalCCD
		duplicate/O OriginalCCD, MaskCCDImage
		redimension/S MaskCCDImage
		if(MaskDisplayLogImage)
			MaskCCDImage=log(OriginalCCD)
		else
			MaskCCDImage=OriginalCCD
		endif
		AutoPositionWindow/E/M=0/R=NI1M_ImageROIPanel CCDImageForMask
		
		NVAR ImageRangeMin=root:Packages:Convert2Dto1D:ImageRangeMin
		NVAR ImageRangeMax=root:Packages:Convert2Dto1D:ImageRangeMax
		NVAR ImageRangeMinLimit=root:Packages:Convert2Dto1D:ImageRangeMinLimit
		NVAR ImageRangeMaxLimit=root:Packages:Convert2Dto1D:ImageRangeMaxLimit
	
		wavestats/Q MaskCCDImage
		ImageRangeMin = V_min
		ImageRangeMax = V_max
		ImageRangeMinLimit = V_min
		ImageRangeMaxLimit = V_max
	
		Slider ImageRangeMin,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}, win=NI1M_ImageROIPanel
		Slider ImageRangeMax,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}, win=NI1M_ImageROIPanel
		NI1M_MaskUpdateColors()
	
	endif

	if(cmpstr(ctrlName,"MaskOffLowIntPoints")==0)
		DoWindow CCDImageForMask
		if(!V_Flag)
			abort
		else
			DoWindow/F CCDImageForMask	
		endif
		SetVariable LowIntToMaskOff, win=NI1M_ImageROIPanel, disable=!(checked)
		NI1M_MaskUpdateColors()
	endif

	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1M_saveRoiCopyProc(ctrlName) : ButtonControl
	String ctrlName
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D
	WAVE/Z ww=root:Packages:Convert2Dto1D:OriginalCCD
	if(WaveExists(ww)==0)
		Abort "Something is wrong here"
	endif
	NVAR MaskOffLowIntPoints = root:Packages:Convert2Dto1D:MaskOffLowIntPoints
	NVAR LowIntToMaskOff = root:Packages:Convert2Dto1D:LowIntToMaskOff

	String MaskLowIntInfo="MaskOffLowIntPoints:"+num2str(MaskOffLowIntPoints)+";LowIntToMaskOff:"+num2str(LowIntToMaskOff)+">"

	GraphNormal/W=CCDImageForMask
	HideTools/W=CCDImageForMask/A
	SetDrawLayer/W=CCDImageForMask UserFront
	DoWindow/F NI1M_ImageROIPanel


	DrawAction /L=ProgFront /W=CCDImageForMask commands
	string CommandStr=MaskLowIntInfo+S_recreation
	ImageGenerateROIMask/E=1/I=0 MaskCCDImage		//sets mask to 0
	Wave M_ROIMask
	note M_ROIMask ,  CommandStr
	//SVAR FileNameToLoad
	NVAR MaskOffLowIntPoints=root:Packages:Convert2Dto1D:MaskOffLowIntPoints
	NVAR LowIntToMaskOff=root:Packages:Convert2Dto1D:LowIntToMaskOff
	NVAR MaskDisplayLogImage=root:Packages:Convert2Dto1D:MaskDisplayLogImage
	variable TempLowIntToMsk=LowIntToMaskOff
	if(MaskDisplayLogImage)
		TempLowIntToMsk=log(LowIntToMaskOff)
	endif
	if(MaskOffLowIntPoints)
		wave MaskCCDImage
	//	MatrixOP/O/NTHR=1 LowIntPointmask = greater(MaskCCDImage -LowIntToMaskOff, 0)		
	//	MatrixOP/O/NTHR=1 M_ROIMask =M_ROIMask * greater(MaskCCDImage, LowIntToMaskOff)		
		MatrixOP/O/NTHR=1 M_ROIMask =M_ROIMask * greater(MaskCCDImage -TempLowIntToMsk,0)
	endif
	redimension/B/U M_ROIMask

	SVAR  CurrentMaskFileName=root:Packages:Convert2Dto1D:CurrentMaskFileName
	SVAR ExportMaskFileName=root:Packages:Convert2Dto1D:ExportMaskFileName
	if (strlen(ExportMaskFileName)==0)
		abort "No name specified"
	endif
	CurrentMaskFileName = ExportMaskFileName+"_mask.hdf"
	PathInfo Convert2Dto1DMaskPath
	if(V_Flag==0)
		abort "Mask path does not exiist, select path first"
	endif
	string ListOfFilesThere
	ListOfFilesThere=IndexedFile(Convert2Dto1DMaskPath,-1,".hdf")
	if(stringMatch(ListOfFilesThere,"*"+CurrentMaskFileName+"*"))
		DoAlert 1, "Mask file with this name exists, overwrite?"
		if(V_Flag!=1)
			abort
		endif	
	endif
	//SVAR CCDFileExtension=root:Packages:Convert2Dto1D:CCDFileExtension
	//if(cmpstr(CCDFileExtension,".tif")==0)
//	ImageSave/P=Convert2Dto1DMaskPath/D=16/T="TIFF"/O M_ROIMask CurrentMaskFileName
	NI1M_SaveHDFNikaMaskFile(CurrentMaskFileName, "Convert2Dto1DMaskPath",M_ROIMask)
	//else
	//	ABort "Cannot save anything else than tiff files yet"
	//endif
	
	NI1M_UpdateMaskListBox()
	NI1A_UpdateMainMaskListBox()
	SetDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1M_SaveHDFNikaMaskFile(fileNameString, PathNameString,ImageToSaveName)
	string fileNameString, PathNameString
	wave ImageToSaveName
#if(exists("HDF5OpenFile")==4)
	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D
	
	variable fileID, groupID, NXentryID
	HDF5CreateFile  /O /P=$(PathNameString)  /Z fileID  as fileNameString
	HDF5SaveData /IGOR=16   ImageToSaveName , fileID  	//16 sets the bit 4 so we save only wave note...
	//now create positioners...
	HDF5CloseFile  fileID 	
#else
		DoALert 0, "Hdf5 xop not installed, please, run installed version 1.10 and higher and install xops"
#endif 

end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1M_RoiDrawButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	if( CmpStr(ctrlName,"CreateROIWorkImage") == 0 )
		//create image for working here...
		NI1M_MaskCreateImage()
	endif
	if( CmpStr(ctrlName,"LoadExistingMask") == 0 )
		//Add existing mask so it can be eddited further....
		NI1M_LoadOldHdfImage()
	endif



	if( CmpStr(ctrlName,"SelectPathToData") == 0 )
		NewPath/C/O/M="Select path to your data, MASK will be saved there too" Convert2Dto1DMaskPath
		NI1M_UpdateMaskListBox()
	endif
	//following function happen only when graph exists...
	DoWindow CCDImageForMask
	if( V_Flag == 0 )
		return 0
	endif
	if( CmpStr(ctrlName,"StartROI") == 0 )
		ShowTools/W=CCDImageForMask/A rect
		SetDrawLayer/W=CCDImageForMask ProgFront
		Wave w= $NI1M_GetImageWave("CCDImageForMask")		// the target matrix
		String iminfo= ImageInfo("CCDImageForMask", NameOfWave(w), 0)
		String xax= StringByKey("XAXIS",iminfo)
		String yax= StringByKey("YAXIS",iminfo)
		SetDrawEnv/W=CCDImageForMask linefgc= (3,52428,1),fillpat= 5,fillfgc= (0,0,0),xcoord=$xax,ycoord=$yax,save
		DoWindow/F  CCDImageForMask 
		AutoPositionWindow/M=0 /R=NI1M_ImageROIPanel CCDImageForMask 
		GetWindow CCDImageForMask wsize
		//print V_left, V_top, V_right, V_bottom
		MoveWindow/W=CCDImageForMask V_left+33, V_top, V_right+33, V_bottom
		DoWindow/F CCDImageForMask
	endif
	if( CmpStr(ctrlName,"FinishROI") == 0 )
		GraphNormal/W=CCDImageForMask
		HideTools/W=CCDImageForMask/A
		SetDrawLayer/W=CCDImageForMask UserFront
		DoWindow/F NI1M_ImageROIPanel
	endif
	if( CmpStr(ctrlName,"clearROI") == 0 )
		GraphNormal/W=CCDImageForMask
		SetDrawLayer/W=CCDImageForMask/K ProgFront
		SetDrawLayer/W=CCDImageForMask UserFront
		DoWindow/F NI1M_ImageROIPanel
	endif
	
	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1M_LoadOldHdfImage()

#if(exists("HDF5OpenFile")==4)
	DoWindow CCDImageForMask
	if(!V_Flag)
		Abort "First create image with some data to use, this button only adds _mask file there to be further edited"
	endif

	string OldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	Wave/T  ListOfCCDDataInCCDPath=root:Packages:Convert2Dto1D:ListOfCCDDataInCCDPath
	controlInfo /W=NI1M_ImageROIPanel CCDDataSelection
	variable selection = V_Value
	if(selection<0)
		setDataFolder OldDf
		abort
	endif
	SVAR FileNameToLoad
	FileNameToLoad=ListOfCCDDataInCCDPath[selection]
	if(!stringmatch(FileNameToLoad,"*_mask.hdf"))
		setDataFolder OldDf
		abort "This is NOT _mask.hdf file, only file created by Nika package with _mask.hdf at the end can be used to load old mask data"
	endif
//	ImageLoad/P=Convert2Dto1DMaskPath/T=tiff/O/N=OldMaskFile FileNameToLoad
	variable refnum
//	Open /M="Select old \"..._mask.hdf\" file created by this tool" /P=Convert2Dto1DMaskPath /T=".hdf" /D/R refnum as FileNameToLoad
//	close refnum
	pathInfo Convert2Dto1DMaskPath
	string FullFileName=S_Path+FileNameToLoad
	variable fileID
	HDF5OpenFile   /Z fileID  as FullFileName
	string OldRecMacro=""
	HDF5LoadData /O/A="IGORWaveNote" fileID, "M_ROIMask"  	//16 sets the bit 4 so we save only wave note...
	Wave/T IGORWaveNote
	HDF5CloseFile  fileID 
	DoWIndow /F CCDImageForMask
	ShowTools/W=CCDImageForMask/A rect
	SetDrawLayer/W=CCDImageForMask ProgFront
	String iminfo= ImageInfo("CCDImageForMask", NameOfWave(w), 0)
	String xax= StringByKey("XAXIS",iminfo)
	String yax= StringByKey("YAXIS",iminfo)
	SetDrawEnv/W=CCDImageForMask linefgc= (3,52428,1),fillpat= 5,fillfgc= (0,0,0),xcoord=$xax,ycoord=$yax,save
	string RecMacro=StringFromList(1,IGORWaveNote[0],">")
	string MaskLowIntInfo = StringFromList(0,IGORWaveNote[0],">")
//	CheckBox MaskOffLowIntPoints proc=NI1M_MaskCheckProc,variable=root:Packages:Convert2Dto1D:MaskOffLowIntPoints
//	SetVariable LowIntToMaskOff,value= root:Packages:Convert2Dto1D:LowIntToMaskOff
	NVAR MaskOffLowIntPoints = root:Packages:Convert2Dto1D:MaskOffLowIntPoints
	NVAR LowIntToMaskOff = root:Packages:Convert2Dto1D:LowIntToMaskOff
	MaskOffLowIntPoints = numberByKey("MaskOffLowIntPoints",MaskLowIntInfo)
	LowIntToMaskOff = numberByKey("LowIntToMaskOff",MaskLowIntInfo)
	NI1M_MaskCheckProc("MaskOffLowIntPoints",MaskOffLowIntPoints)
	variable i
	For(i=0;i<ItemsInList(RecMacro,"\r");i+=1)
		execute (StringFromList(i,RecMacro,"\r")) 
	endfor
	
	setDataFolder OldDf
#else
		DoALert 0, "Hdf5 xop not installed, please, run installed version 1.10 and higher and install xops"
#endif 
	
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function/S NI1M_GetImageWave(grfName)
	String grfName							// use zero len str to speicfy top graph

	String s= ImageNameList(grfName, ";")
	Variable p1= StrSearch(s,";",0)
	if( p1<0 )
		return ""			// no image in top graph
	endif
	s= s[0,p1-1]
	Wave w= ImageNameToWaveRef(grfName, s)
	return GetWavesDataFolder(w,2)		// full path to wave including name
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1M_MaskCreateImage()

	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D
	Wave/T  ListOfCCDDataInCCDPath=root:Packages:Convert2Dto1D:ListOfCCDDataInCCDPath
	controlInfo /W=NI1M_ImageROIPanel CCDDataSelection
	variable selection = V_Value
	if(selection<0)
		setDataFolder OldDf
		abort
	endif
	DoWindow CCDImageForMask
	if(V_Flag)
		DoWindow/K CCDImageForMask
	endif
	SVAR FileNameToLoad
	FileNameToLoad=ListOfCCDDataInCCDPath[selection]
	SVAR CCDFileExtension=root:Packages:Convert2Dto1D:CCDFileExtension
//	if(cmpstr(CCDFileExtension,".tif")==0)
//		ImageLoad/P=Convert2Dto1DMaskPath/T=tiff/O/N=OriginalCCD FileNameToLoad+CCDFileExtension
//	else
//		Abort "Can load only tiff images at this time"
//	endif
	NI1A_UniversalLoader("Convert2Dto1DMaskPath",FileNameToLoad,CCDFileExtension,"OriginalCCD")
	NVAR MaskDisplayLogImage=root:Packages:Convert2Dto1D:MaskDisplayLogImage
	wave OriginalCCD
	//allow user function modification to the image through hook function...
		String infostr = FunctionInfo("ModifyImportedImageHook")
		if (strlen(infostr) >0)
			Execute("ModifyImportedImageHook(OriginalCCD)")
		endif
	//end of allow user modification of imported image through hook function
	duplicate/O OriginalCCD, MaskCCDImage
	redimension/S MaskCCDImage
	if(MaskDisplayLogImage)
		MaskCCDImage=log(OriginalCCD)
	else
		MaskCCDImage=OriginalCCD
	endif
	NVAR InvertImages=root:Packages:Convert2Dto1D:InvertImages
	if(InvertImages)
		NewImage/F/K=1 MaskCCDImage
	else	
		NewImage/K=1 MaskCCDImage
	endif
	DoWindow/C CCDImageForMask
	AutoPositionWindow/E/M=0/R=NI1M_ImageROIPanel CCDImageForMask
	SVAR ExportMaskFileName=root:Packages:Convert2Dto1D:ExportMaskFileName
	ExportMaskFileName = StringFromList(0,FileNameToLoad,".")
	
	NVAR ImageRangeMin=root:Packages:Convert2Dto1D:ImageRangeMin
	NVAR ImageRangeMax=root:Packages:Convert2Dto1D:ImageRangeMax
	NVAR ImageRangeMinLimit=root:Packages:Convert2Dto1D:ImageRangeMinLimit
	NVAR ImageRangeMaxLimit=root:Packages:Convert2Dto1D:ImageRangeMaxLimit

	wavestats/Q MaskCCDImage
	ImageRangeMin = V_min
	ImageRangeMax = V_max
	ImageRangeMinLimit = V_min
	ImageRangeMaxLimit = V_max

	Slider ImageRangeMin,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}, win=NI1M_ImageROIPanel
	Slider ImageRangeMax,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}, win=NI1M_ImageROIPanel
	NI1M_MaskUpdateColors()
	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1M_UpdateMaskListBox()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

		Wave/T  ListOfCCDDataInCCDPath=root:Packages:Convert2Dto1D:ListOfCCDDataInCCDPath
		Wave SelectionsofCCDDataInCCDPath=root:Packages:Convert2Dto1D:SelectionsofCCDDataInCCDPath
		SVAR CCDFileExtension=root:Packages:Convert2Dto1D:CCDFileExtension
		SVAR EmptyDarkNameMatchStr=root:Packages:Convert2Dto1D:EmptyDarkNameMatchStr
		string RealExtension				//for starnge extensions
		if(cmpstr(CCDFileExtension,".tif")==0)
			RealExtension=CCDFileExtension
		elseif(cmpstr(CCDFileExtension,".hdf")==0)
			RealExtension=CCDFileExtension
		elseif(cmpstr(CCDFileExtension,"Nexus")==0)
			RealExtension=".hdf"
		else
			RealExtension="????"
		endif
		string ListOfAvailableCompounds
		PathInfo Convert2Dto1DMaskPath
		if(V_Flag==0)
			abort
		endif
		
		ListOfAvailableCompounds=IndexedFile(Convert2Dto1DMaskPath,-1,RealExtension)
		if(cmpstr(RealExtension,"hdf"))
			ListOfAvailableCompounds+=IndexedFile(Convert2Dto1DMaskPath,-1,".h5")
			ListOfAvailableCompounds+=IndexedFile(Convert2Dto1DMaskPath,-1,".hdf5")
		endif
			if(strlen(ListOfAvailableCompounds)<2)	//none found
				ListOfAvailableCompounds="--none--;"
			endif
		redimension/N=(ItemsInList(ListOfAvailableCompounds)) ListOfCCDDataInCCDPath
		redimension/N=(ItemsInList(ListOfAvailableCompounds)) SelectionsofCCDDataInCCDPath
		variable i
		ListOfCCDDataInCCDPath=NI1A_CleanListOfFilesForTypes(ListOfCCDDataInCCDPath,CCDFileExtension, EmptyDarkNameMatchStr)
		For(i=0;i<ItemsInList(ListOfAvailableCompounds);i+=1)
			ListOfCCDDataInCCDPath[i]=StringFromList(i, ListOfAvailableCompounds)
		endfor
		sort ListOfCCDDataInCCDPath, ListOfCCDDataInCCDPath, SelectionsofCCDDataInCCDPath		//, NumbersOfCompoundsOutsideIgor
		SelectionsofCCDDataInCCDPath=0
		
		DoWIndow NI1M_ImageROIPanel
		if(V_Flag)
			ListBox CCDDataSelection win=NI1M_ImageROIPanel,listWave=root:Packages:Convert2Dto1D:ListOfCCDDataInCCDPath
			ListBox CCDDataSelection win=NI1M_ImageROIPanel,row= 0,mode= 1,selRow= 0
			DoUpdate
		endif
	setDataFolder OldDf
end	

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1M_MaskPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	if(cmpstr(ctrlName,"CCDFileExtension")==0)
		//set appropriate extension
		SVAR CCDFileExtension=root:Packages:Convert2Dto1D:CCDFileExtension
//		if (cmpstr(popStr,"tif")==0)
//			CCDFileExtension=".tif"
//		elseif (cmpstr(popStr,"Mar3450")==0)
//			CCDFileExtension=".Mar3450"
//		elseif (cmpstr(popStr,"BrukerCCD")==0)
//			CCDFileExtension="BrukerCCD"
//		elseif (cmpstr(popStr,"any")==0)
//			CCDFileExtension="????"
//		endif
		CCDFileExtension = popStr
		NI1M_UpdateMaskListBox()
		if(cmpstr(popStr,"GeneralBinary")==0)
			NI1_GBLoaderPanelFnct()
		endif
		if(cmpstr(popStr,"Pilatus")==0)
			NI1_PilatusLoaderPanelFnct()
		endif
	endif
	if(cmpstr(ctrlName,"ColorTablePopup")==0)
		SVAR ColorTableName=root:Packages:Convert2Dto1D:ColorTableName
		ColorTableName = popStr
		NI1M_MaskUpdateColors()
	endif
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1M_SliderProc(ctrlName,sliderValue,event) //: SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	if(event %& 0x1)	// bit 0, value set

	endif
	if(cmpstr(ctrlName,"ImageRangeMin")==0)
		NI1M_MaskUpdateColors()
	endif
	if(cmpstr(ctrlName,"ImageRangeMax")==0)
		NI1M_MaskUpdateColors()
	endif
	return 0
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1M_MaskUpdateColors()
	DoWindow CCDImageForMask
	if(V_Flag)
		NVAR ImageRangeMin= root:Packages:Convert2Dto1D:ImageRangeMin
		NVAR ImageRangeMax = root:Packages:Convert2Dto1D:ImageRangeMax
		SVAR ColorTableName=root:Packages:Convert2Dto1D:ColorTableName
		string ColorTableNameL
		variable ReverseColorTable
		if(stringmatch(ColorTableName,"*_R"))
			ColorTableNameL = RemoveEnding(ColorTableName,"_R")
			ReverseColorTable = 1
		else
			ColorTableNameL = ColorTableName
			ReverseColorTable = 0
		endif
		ModifyImage/W=CCDImageForMask MaskCCDImage ctab= {ImageRangeMin,ImageRangeMax,$ColorTableNameL,ReverseColorTable}

		//now deal with the masking of low values... 
		Wave MaskCCDImage=root:Packages:Convert2Dto1D:MaskCCDImage
		NVAR LowIntToMaskOff=root:Packages:Convert2Dto1D:LowIntToMaskOff
		NVAR MaskDisplayLogImage=root:Packages:Convert2Dto1D:MaskDisplayLogImage
		NVAR MaskOffLowIntPoints=root:Packages:Convert2Dto1D:MaskOffLowIntPoints
		
		CheckDisplayed /W=CCDImageForMask  UnderLevelImage
		if(V_Flag)
			removeimage/W=CCDImageForMask UnderLevelImage
		endif
		if(MaskOffLowIntPoints)
			MatrixOp/O/NTHR=1 UnderLevelImage= MaskCCDImage
			AppendImage/T/W=CCDImageForMask UnderLevelImage
			variable tempLimit=LowIntToMaskOff
			if(tempLimit<1)
				tempLimit=1
			endif
			if(MaskDisplayLogImage)
				tempLimit=log(tempLimit)
			endif
			ModifyImage/W=CCDImageForMask UnderLevelImage ctab= {tempLimit,tempLimit,Terrain,0}
			ModifyImage/W=CCDImageForMask UnderLevelImage minRGB=(65535,65535,65535),maxRGB=NaN
		else
			killWaves /Z  UnderLevelImage
		endif

	endif

end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1M_Mask_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	wave OriginalCCD=root:Packages:Convert2Dto1D:OriginalCCD
	String iminfo
	String xax
	String yax
	
	if(cmpstr("RemoveFirstNColumns",ctrlName)==0)
		SetDrawLayer/W=CCDImageForMask ProgFront
		Wave w= $NI1M_GetImageWave("CCDImageForMask")		// the target matrix
		iminfo= ImageInfo("CCDImageForMask", NameOfWave(w), 0)
		xax= StringByKey("XAXIS",iminfo)
		yax= StringByKey("YAXIS",iminfo)
		SetDrawEnv/W=CCDImageForMask linefgc= (3,52428,1),fillpat= 5,fillfgc= (0,0,0),xcoord=$xax,ycoord=$yax,save
		DrawRect /W=CCDImageForMask 0, 0, varNum, DimSize(OriginalCCD, 1 )
	endif
	if(cmpstr("RemoveLastNColumns",ctrlName)==0)
		SetDrawLayer/W=CCDImageForMask ProgFront
		Wave w= $NI1M_GetImageWave("CCDImageForMask")		// the target matrix
		iminfo= ImageInfo("CCDImageForMask", NameOfWave(w), 0)
		xax= StringByKey("XAXIS",iminfo)
		yax= StringByKey("YAXIS",iminfo)
		SetDrawEnv/W=CCDImageForMask linefgc= (3,52428,1),fillpat= 5,fillfgc= (0,0,0),xcoord=$xax,ycoord=$yax,save
		DrawRect /W=CCDImageForMask (DimSize(OriginalCCD, 0)-varNum),0,DimSize(OriginalCCD, 0), DimSize(OriginalCCD, 1 )
	endif
	if(cmpstr("RemoveFirstNrows",ctrlName)==0)
		SetDrawLayer/W=CCDImageForMask ProgFront
		Wave w= $NI1M_GetImageWave("CCDImageForMask")		// the target matrix
		iminfo= ImageInfo("CCDImageForMask", NameOfWave(w), 0)
		xax= StringByKey("XAXIS",iminfo)
		yax= StringByKey("YAXIS",iminfo)
		SetDrawEnv/W=CCDImageForMask linefgc= (3,52428,1),fillpat= 5,fillfgc= (0,0,0),xcoord=$xax,ycoord=$yax,save
		DrawRect /W=CCDImageForMask 0, 0, DimSize(OriginalCCD, 0 ), varNum
	endif
	if(cmpstr("RemoveLastNRows",ctrlName)==0)
		SetDrawLayer/W=CCDImageForMask ProgFront
		Wave w= $NI1M_GetImageWave("CCDImageForMask")		// the target matrix
		iminfo= ImageInfo("CCDImageForMask", NameOfWave(w), 0)
		xax= StringByKey("XAXIS",iminfo)
		yax= StringByKey("YAXIS",iminfo)
		SetDrawEnv/W=CCDImageForMask linefgc= (3,52428,1),fillpat= 5,fillfgc= (0,0,0),xcoord=$xax,ycoord=$yax,save
		DrawRect /W=CCDImageForMask 0,(DimSize(OriginalCCD, 1)-varNum),DimSize(OriginalCCD, 0), DimSize(OriginalCCD, 1 )
	endif
	
	if(cmpstr("LowIntToMaskOff",ctrlName)==0)
		NI1M_MaskUpdateColors()
	endif
	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
