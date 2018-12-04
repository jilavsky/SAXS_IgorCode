#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.06

//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/


//1.06 Modified Screen Size check to match the needs
//1.05 added getHelp button calling to www manual
//1.04 modified to point to USAXS_data on USAXS computers
//1.03 modified call to hook function
//1.02 adds ability to use mask for calculation of Flood field. 
//1.01 added license for ANL



Function NI1_Create2DSensitivityFile()
	
	NI1A_Initialize2Dto1DConversion()
	NI1A_InitializeCreate2DSensFile()
	IN2G_CheckScreenSize("height",530)
	NI1_CreateFloodField()

end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_CreateFloodField()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	KillWIndow/Z NI1_CreateFloodFieldPanel
 	SVAR FloodFileType=root:Packages:Convert2Dto1D:FloodFileType
	SVAR ColorTableName=root:Packages:Convert2Dto1D:ColorTableName
	NVAR ImageRangeMaxLimit=root:Packages:Convert2Dto1D:ImageRangeMaxLimit
	NVAR ImageRangeMinLimit=root:Packages:Convert2Dto1D:ImageRangeMinLimit
	NVAR AddFlat=root:Packages:Convert2Dto1D:AddFlat
	
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(22,58,450,560) as "Create FLOOD panel"
	Dowindow/C NI1_CreateFloodFieldPanel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 19,fstyle= 1,textrgb= (0,0,65280)
	DrawText 30,30,"Prepare pix 2D sensitivity (flood) file"
	DrawText 18,92,"Select data set to use:"
	DrawText 10,432,"Processing: pix2D = 2DImage / MaximumValue"
	DrawText 10,449,"or: pix2D = (2DImage + offset) / (MaximumValue + offset)"

	Button SelectPathToData,pos={27,44},size={150,20},proc=NI1_FloodButtonProc,title="Select path to data"
	Button SelectPathToData,help={"Sets path to data where flood image is"}
	PopupMenu FloodFileType,pos={207,44},size={101,21},proc=NI1M_FloodPopMenuProc,title="File type:"
	PopupMenu FloodFileType,help={"Select image type of data to be used"}
	PopupMenu FloodFileType,mode=1,popvalue=FloodFileType,value= #"root:Packages:Convert2Dto1D:ListOfKnownExtensions"
	Button GetHelp,pos={335,105},size={80,15},fColor=(65535,32768,32768), proc=NI1_FloodButtonProc,title="Get Help", help={"Open www manual page for this tool"}

	ListBox CCDDataSelection,pos={17,95},size={300,150}//,proc=NI1M_ListBoxProc
	ListBox CCDDataSelection,help={"Select CCD file for which you want to create mask"}
	ListBox CCDDataSelection,listWave=root:Packages:Convert2Dto1D:ListOfCCDDataInFloodPath
	ListBox CCDDataSelection,row= 0,mode= 1,selRow= 0

	Button CreateROIWorkImage,pos={200,255},size={160,20},proc=NI1_FloodButtonProc,title="Make Image"
	Button AppendROIWorkImage,pos={10,255},size={150,20},proc=NI1_FloodButtonProc,title="Append file to Image"
//AddFlat;FlatValToAdd;MaximumValueFlood
	CheckBox AddFlat title="Add value to each pixel?",pos={20,290}
	CheckBox AddFlat proc=NI1M_FloodCheckProc,variable=AddFlat
	CheckBox AddFlat help={"Add  offset to all points?"}
	SetVariable FlatValToAdd,pos={180,290},size={200,16},title="Offset value =   ", disable=!AddFlat, proc=NI1M_SetVarProc
	SetVariable FlatValToAdd,help={"Add 1 to each point (to avoid problems with point with intensity=0)"}
	SetVariable FlatValToAdd,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:FlatValToAdd


	CheckBox Flood_UseMask title="Use mask?",pos={20,315}
	CheckBox Flood_UseMask proc=NI1M_FloodCheckProc,variable=root:Packages:Convert2Dto1D:Flood_UseMask
	CheckBox Flood_UseMask help={"Add flat offset to all points?"}


	SetVariable MaximumValueFlood,pos={22,340},size={300,16},title="Maximum value found in image      ", proc=NI1M_SetVarProc
	SetVariable MaximumValueFlood,help={"This is maximum value found in your image. Change if needed."}
	SetVariable MaximumValueFlood,limits={-Inf,Inf,0},value= root:Packages:Convert2Dto1D:MaximumValueFlood
	SetVariable MinimumValueFlood,pos={22,365},size={300,16},title="Minimum value found in image      ", proc=NI1M_SetVarProc
	SetVariable MinimumValueFlood,help={"This is minimum value found in your image"}, noedit=1
	SetVariable MinimumValueFlood,limits={-Inf,Inf,0},value= root:Packages:Convert2Dto1D:MinimumValueFlood

	SetVariable ExportFloodFileName,pos={22,390},size={355,16},title="Save as (\"_flood\" will be added) :  "
	SetVariable ExportFloodFileName,help={"Name for the new flood file. Will be tiff file in the same place where the source data came from."}
	SetVariable ExportFloodFileName,limits={-Inf,Inf,0},value= root:Packages:Convert2Dto1D:ExportFloodFileName

	Button DisplayFloodField,pos={10,460},size={180,20},proc=NI1M_saveFloodCopyProc,title="Display 2D pix sens file (flood)"
	Button DisplayFloodField,help={"Displays current ROI "}
	Button SaveFloodField,pos={200,460},size={180,20},proc=NI1M_saveFloodCopyProc,title="Save 2D pix sens file (flood)"
	Button SaveFloodField,help={"Saves current ROI as file outside Igor and also sets it as current Flood field"}
	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1M_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			NI1M_CalculateFloodField(0)
			//update ranges on the images:
			NVAR MaximumValueFlood= root:Packages:Convert2Dto1D:MaximumValueFlood
			NVAR MinimumValueFlood= root:Packages:Convert2Dto1D:MinimumValueFlood
			ModifyImage/W=CCDImageForFlood FloodFieldImgOriginal ctab= {MinimumValueFlood,MaximumValueFlood,,0}
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1M_saveFloodCopyProc(ctrlName) : ButtonControl
	String ctrlName
		
	if(StringMatch(ctrlName,"saveFloodField"))
		NI1M_CalculateFloodField(1)
	endif
	if(StringMatch(ctrlName,"DisplayFloodField"))
		NI1M_CalculateFloodField(0)
	endif
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1M_CalculateFloodField(AndSave)
	variable AndSave
	
	string OldDf=GetDataFolder(1)
	setDataFOlder root:Packages:Convert2Dto1D
	NVAR AddFlat=root:Packages:Convert2Dto1D:AddFlat
	NVAR FlatValToAdd= root:Packages:Convert2Dto1D:FlatValToAdd
	NVAR MaximumValueFlood= root:Packages:Convert2Dto1D:MaximumValueFlood
	NVAR MinimumValueFlood= root:Packages:Convert2Dto1D:MinimumValueFlood
	WAVE/Z FloodFieldImg=root:Packages:Convert2Dto1D:FloodFieldImg
	NVAR Flood_UseMask=root:Packages:Convert2Dto1D:Flood_UseMask


	if(WaveExists(FloodFieldImg)==0)
		Abort "Something is wrong here"
	endif
	IF(Flood_UseMask)
		Wave/Z Mask = root:Packages:Convert2Dto1D:M_ROIMask
		if(!WaveExists(Mask))
			Abort "Mask not found"
		endif
	endif
	
	variable temp
	Duplicate/O FloodFieldImg, a2DPixSensTemp
	if(AddFlat)
		temp = MaximumValueFlood+FlatValToAdd
		a2DPixSensTemp = (FloodFieldImg + FlatValToAdd)/temp
	else
		a2DPixSensTemp = FloodFieldImg/MaximumValueFlood
	endif
	IF(Flood_UseMask)
		MatrixOp/O a2DPixSensTemp = a2DPixSensTemp * Mask/Mask
	endif
	
	DoWindow FloodFieldImageTemporary
	if(V_Flag)
		DoWindow /F FloodFieldImageTemporary
	else
		NewImage/K=1/N=FloodFieldImageTemporary a2DPixSensTemp 
	endif
	AutoPositionWindow/E/M=1/R=CCDImageForFlood FloodFieldImageTemporary
	NI1A_TopCCDImageUpdateColors(1)

	if(AndSave)
		SVAR  ExportFloodFileName=root:Packages:Convert2Dto1D:ExportFloodFileName
		if (strlen(ExportFloodFileName)==0)
			abort "No name specified"
		endif
		string tempExportFloodFileName
		tempExportFloodFileName = ExportFloodFileName+"_flood.tif"
		PathInfo Convert2Dto1DFloodPath
		if(V_Flag==0)
			abort "Flood path does not exist, select path first"
		endif
		string ListOfFilesThere
		ListOfFilesThere=IndexedFile(Convert2Dto1DFloodPath,-1,".tif")
		if(stringMatch(ListOfFilesThere,"*"+tempExportFloodFileName+"*"))
			DoAlert 1, "Flood file with this name exists, overwrite?"
			if(V_Flag!=1)
				abort
			endif	
		endif
		ImageSave/P=Convert2Dto1DFloodPath/F/T="TIFF"/O a2DPixSensTemp tempExportFloodFileName
		NI1_UpdateFloodListBox()
		NI1A_UpdateMainMaskListBox()
		KillWIndow/Z FloodFieldImage
 		Duplicate/O a2DPixSensTemp, Pixel2Dsensitivity
		SVAR CurrentPixSensFile=root:Packages:Convert2Dto1D:CurrentPixSensFile
		CurrentPixSensFile = tempExportFloodFileName
		redimension/S Pixel2Dsensitivity
		KillWIndow/Z CCDImageForFlood
 		KillWIndow/Z FloodFieldImageTemporary
 
		NVAR InvertImages=root:Packages:Convert2Dto1D:InvertImages
		DoWindow Pixel2DSensitivityImage
		if(V_Flag)
			DoWIndow /K Pixel2DSensitivityImage
		endif
		if(InvertImages)
			NewImage/F/K=1/N=Pixel2DSensitivityImage Pixel2Dsensitivity
			DoWindow/C Pixel2DSensitivityImage
		else	
			NewImage/K=1/N=Pixel2DSensitivityImage Pixel2Dsensitivity
			DoWindow/C Pixel2DSensitivityImage
		endif
		DoWIndow NI1A_Convert2Dto1DPanel
		if(V_Flag)
				AutoPositionWindow/E/M=0/R=NI1A_Convert2Dto1DPanel Pixel2DSensitivityImage
		endif
		NI1A_TopCCDImageUpdateColors(1)
		KillWaves/Z a2DPixSensTemp
	endif
	SetDataFolder OldDf

	
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1M_FloodCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	if(cmpstr(ctrlName,"AddFlat")==0)
		NVAR AddFlat=root:Packages:Convert2Dto1D:AddFlat
		SetVariable FlatValToAdd,win=NI1_CreateFloodFieldPanel, disable=!AddFlat
		NI1M_CalculateFloodField(0)
	endif
	if(cmpstr(ctrlName,"Flood_UseMask")==0)
		NVAR Flood_UseMask=root:Packages:Convert2Dto1D:Flood_UseMask
		NI1M_UpdateCalculations()
	endif
	
	
	
	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1M_FloodPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	if(cmpstr(ctrlName,"FloodFileType")==0)
		//set appropriate extension
		SVAR FloodFileType=root:Packages:Convert2Dto1D:FloodFileType
		FloodFileType = popStr
		if(cmpstr(popStr,"GeneralBinary")==0)
			NI1_GBLoaderPanelFnct()
		endif
		if(cmpstr(popStr,"Pilatus")==0)
			NI1_PilatusLoaderPanelFnct()
		endif
		NI1_UpdateFloodListBox()
	endif
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1_UpdateFloodListBox()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

		Wave/T  ListOfCCDDataInFloodPath=root:Packages:Convert2Dto1D:ListOfCCDDataInFloodPath
		Wave SelectionsofCCDDataInFloodDPath=root:Packages:Convert2Dto1D:SelectionsofCCDDataInFloodDPath
		SVAR FloodFileType=root:Packages:Convert2Dto1D:FloodFileType
		string RealExtension				//for starnge extensions
		if(cmpstr(FloodFileType,".tif")==0)
			RealExtension=FloodFileType
		else
			RealExtension="????"
		endif
		string ListOfAvailableCompounds
		PathInfo Convert2Dto1DFloodPath
		if(V_Flag==0)
			abort
		endif

		ListOfAvailableCompounds=IndexedFile(Convert2Dto1DFloodPath,-1,RealExtension)
		redimension/N=(ItemsInList(ListOfAvailableCompounds)) ListOfCCDDataInFloodPath
		redimension/N=(ItemsInList(ListOfAvailableCompounds)) SelectionsofCCDDataInFloodDPath
		variable i
		ListOfCCDDataInFloodPath=NI1A_CleanListOfFilesForTypes(ListOfCCDDataInFloodPath,FloodFileType,"")
		For(i=0;i<ItemsInList(ListOfAvailableCompounds);i+=1)
			ListOfCCDDataInFloodPath[i]=StringFromList(i, ListOfAvailableCompounds)
		endfor
		sort ListOfCCDDataInFloodPath, ListOfCCDDataInFloodPath, SelectionsofCCDDataInFloodDPath		//, NumbersOfCompoundsOutsideIgor
		SelectionsofCCDDataInFloodDPath=0

		ListBox CCDDataSelection win=NI1_CreateFloodFieldPanel,listWave=root:Packages:Convert2Dto1D:ListOfCCDDataInFloodPath
		ListBox CCDDataSelection win=NI1_CreateFloodFieldPanel ,row= 0,mode= 1,selRow= 0
		DoUpdate
	setDataFolder OldDf
end	


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_FloodButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	if(cmpstr(ctrlName,"GetHelp")==0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Nika/FloodField.html")
	endif
	if( CmpStr(ctrlName,"CreateROIWorkImage") == 0 )
		//create image for working here...
		NI1_FloodCreateAppendImage(0)
	endif
	if( CmpStr(ctrlName,"AppendROIWorkImage") == 0 )
		//create image for working here...
		NI1_FloodCreateAppendImage(1)
	endif
	if( CmpStr(ctrlName,"SelectPathToData") == 0 )
		//check if we are running on USAXS computers
		GetFileFOlderInfo/Q/Z "Z:USAXS_data:"
		if(V_isFolder)
			//OK, this computer has Z:USAXS_data 
			PathInfo Convert2Dto1DFloodPath
			if(V_flag==0)
				NewPath/Q  Convert2Dto1DFloodPath, "Z:USAXS_data:"
				pathinfo/S Convert2Dto1DFloodPath
			endif
		endif
		//PathInfo/S Convert2Dto1DMaskPath
		NewPath/C/O/M="Select path to your data, FLOOD will be saved there too" Convert2Dto1DFloodPath
		NI1_UpdateFloodListBox()
	endif
	//following function happen only when graph exists...
	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_FloodCreateAppendImage(AppendImg)
	variable AppendImg

	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D
	Wave/T  ListOfCCDDataInFloodPath=root:Packages:Convert2Dto1D:ListOfCCDDataInFloodPath
	controlInfo /W=NI1_CreateFloodFieldPanel CCDDataSelection
	variable selection = V_Value
	if(selection<0)
		setDataFolder OldDf
		abort
	endif
	KillWIndow/Z CCDImageForFlood
 	SVAR FileNameToLoad
	FileNameToLoad=ListOfCCDDataInFloodPath[selection]
	SVAR FloodFileType=root:Packages:Convert2Dto1D:FloodFileType
	variable ImgExisted
	String infostr
	//need to communicate to Nexus reader what we are loading and this seems the only way to do so
	string/g ImageBeingLoaded
	ImageBeingLoaded = ""
	//awful workaround end
	
	if(AppendImg)
		Wave/Z FloodFieldImgOriginal
		if(!WaveExists(FloodFieldImgOriginal))
			DoAlert 0, "Old Flood Image does not exists, cannot append, will create new one"
			ImgExisted=0
		else
			ImgExisted=1
		endif
		NI1A_UniversalLoader("Convert2Dto1DFloodPath",FileNameToLoad,FloodFileType,"FloodFieldImg")
		wave FloodFieldImg
		//allow user function modification to the image through hook function...
#if Exists("ModifyImportedImageHook")
	ModifyImportedImageHook(FloodFieldImg)
#endif
//		infostr = FunctionInfo("ModifyImportedImageHook")
//		if (strlen(infostr) >0)
//			Execute("ModifyImportedImageHook(FloodFieldImg)")
//		endif
		//end of allow user modification of imported image through hook function
		redimension/S FloodFieldImg
		if(ImgExisted)
			FloodFieldImg+=FloodFieldImgOriginal
			KillWaves/Z FloodFieldImgSaved
		endif	
	else
		NI1A_UniversalLoader("Convert2Dto1DFloodPath",FileNameToLoad,FloodFileType,"FloodFieldImg")
		wave FloodFieldImg
		//allow user function modification to the image through hook function...
#if Exists("ModifyImportedImageHook")
	ModifyImportedImageHook(FloodFieldImg)
#endif
//		infostr = FunctionInfo("ModifyImportedImageHook")
//		if (strlen(infostr) >0)
//			Execute("ModifyImportedImageHook(FloodFieldImg)")
//		endif
		//end of allow user modification of imported image through hook function
		redimension/S FloodFieldImg
	endif
	Duplicate/O FloodFieldImg, FloodFieldImgOriginal

	NVAR InvertImages=root:Packages:Convert2Dto1D:InvertImages
	if(InvertImages)
		NewImage/F/K=1/N=CCDImageForFlood FloodFieldImgOriginal
	else	
		NewImage/K=1/N=CCDImageForFlood FloodFieldImgOriginal
	endif
	NVAR Flood_UseMask=root:Packages:Convert2Dto1D:Flood_UseMask
	IF(Flood_UseMask)
		Wave/Z Mask = root:Packages:Convert2Dto1D:M_ROIMask
		if(!WaveExists(Mask))
			DoAlert 0, "Mask file not found, application of the mask was skipped. Load Mask through main panel and try again"
			Flood_UseMask=0
		else
			MatrixOp/O FloodFieldImg = FloodFieldImgOriginal * Mask/Mask	
		endif
	else
		FloodFieldImg = FloodFieldImgOriginal
	endif

	DoWindow/C CCDImageForFlood
	AutoPositionWindow/E/M=0/R=NI1_CreateFloodFieldPanel CCDImageForFlood

	wavestats/Q FloodFieldImg
	
	NVAR MaximumValueFlood=root:Packages:Convert2Dto1D:MaximumValueFlood
	MaximumValueFlood=V_max
	NVAR MinimumValueFlood=root:Packages:Convert2Dto1D:MinimumValueFlood
	MinimumValueFlood=V_min

	ModifyImage FloodFieldImgOriginal ctab= {V_min,V_max,Terrain,0}


	NVAR AddFlat=root:Packages:Convert2Dto1D:AddFlat
	NVAR FlatValToAdd= root:Packages:Convert2Dto1D:FlatValToAdd
	if(MinimumValueFlood<=0)
		AddFlat=1
		FlatValToAdd=1
	else
		AddFlat=0
		FlatValToAdd=0	
	endif
	NI1M_FloodCheckProc("AddFlat",AddFlat)
	SVAR ExportFloodFileName=root:Packages:Convert2Dto1D:ExportFloodFileName
	ExportFloodFileName = FileNameToLoad

	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1M_UpdateCalculations()

	Wave/Z FloodFieldImg=root:Packages:Convert2Dto1D:FloodFieldImg
	Wave/Z FloodFieldImgBackup=root:Packages:Convert2Dto1D:FloodFieldImgBackup
	
	if(!WaveExists(FloodFieldImg)||!WaveExists(FloodFieldImgBackup))
		return 0
	endif
	NVAR Flood_UseMask=root:Packages:Convert2Dto1D:Flood_UseMask
	IF(Flood_UseMask)
		Wave/Z Mask = root:Packages:Convert2Dto1D:M_ROIMask
		if(!WaveExists(Mask))
			DoAlert 0, "Mask file not found, application of the mask was skipped. Load Mask through main panel and try again"
			Flood_UseMask=0
		else
			MatrixOp/O FloodFieldImg = FloodFieldImgBackup * Mask/Mask	
		endif
	else
		FloodFieldImg = FloodFieldImgBackup
	endif

	wavestats/Q FloodFieldImg
	NVAR MaximumValueFlood=root:Packages:Convert2Dto1D:MaximumValueFlood
	MaximumValueFlood=V_max
	NVAR MinimumValueFlood=root:Packages:Convert2Dto1D:MinimumValueFlood
	MinimumValueFlood=V_min
	NVAR AddFlat=root:Packages:Convert2Dto1D:AddFlat
	NVAR FlatValToAdd= root:Packages:Convert2Dto1D:FlatValToAdd
	if(MinimumValueFlood<=0)
		AddFlat=1
		FlatValToAdd=1
	else
		AddFlat=0
		FlatValToAdd=0	
	endif


end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_InitializeCreate2DSensFile()

	string OldDf=GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:Convert2Dto1D

	string ListOfVariables
	string ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="AddFlat;FlatValToAdd;MaximumValueFlood;MinimumValueFlood;Flood_UseMask;"

	ListOfStrings="FloodFileName;FloodFileType;ExportFloodFileName;"
	
	Wave/Z/T ListOfCCDDataInFloodPath
	if (!WaveExists(ListOfCCDDataInFloodPath))
		make/O/T/N=0 ListOfCCDDataInFloodPath
	endif
	Wave/Z SelectionsofCCDDataInFloodDPath
	if(!WaveExists(SelectionsofCCDDataInFloodDPath))
		make/O/N=0 SelectionsofCCDDataInFloodDPath
	endif

	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	SVAR FloodFileType=root:Packages:Convert2Dto1D:FloodFileType
	IF (STRLEN(FloodFileType)<1)
		FloodFileType=".tif"
	endif

end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
