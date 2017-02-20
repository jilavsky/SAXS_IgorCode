#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.01

//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.01 added license for ANL



Window ExportToXLSFilePanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(562.2,177.8,1099.2,518)
	ModifyPanel cbRGB=(0,52224,52224)
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 48,34,"Export Unified Results to Tab Delimited Excel-Type File"
	DrawText 4,112,"1) "
	DrawText 223,106,"2) Iterate"
	DrawText 9,209,"3) Finally Open with 1) and save copy"
	SetDrawEnv linethick= 2
	DrawLine 16,222,517,222
	DrawText 25,267,"1) Erase Old Notebook (above)"
	DrawText 24,327,"3) Finally Open with 1) and Save Copy"
	SetDrawEnv fsize= 18,fstyle= 1
	DrawText 225,248,"Auto Save All"
	Button Add_New_Results_to_XLS,pos={290,78},size={172,45},proc=IR1A_InputPanelButtonXLSProc,title="Select Fit Result to add"
	PopupMenu SelectDataFolderXLS,pos={192,45},size={336,24},proc=IR1A_PanelPopupControlXLS,title="Data: "
	PopupMenu SelectDataFolderXLS,help={"Select folder containing your SAS data"}
	PopupMenu SelectDataFolderXLS,mode=17,popvalue="---",value= #"\"---;\"+IR1_GenStringOfFolders(root:Packages:Irena_UnifFit:UseIndra2Data,0,0,0)"
	Button Add_Last_Results_to_XLS01,pos={291,131},size={172,45},proc=IR1A_InputPanelButtonXLSProc,title="Add last Results to XLS"
	Button Start_Erase_XLS_Notebook,pos={19,91},size={195,33},proc=IR1A_InputPanelButtonXLSProc,title="Erase Old Notebook (BtoFront)"
	Button AutoSaveXLS,pos={306,261},size={172,45},proc=IR1A_InputPanelButtonXLSProc,title="2) Auto Save All Latest Fits"
EndMacro

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_InputPanelButtonXLSProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
	
	if (cmpstr(ctrlName,"AutoSaveXLS")==0)
		AutoSaveXLSResults()
	endif
	
	if (cmpstr(ctrlName,"Add_New_Results_to_XLS")==0)
		//here goes what is done, when user pushes Graph button
		SVAR DFloc=root:Packages:Irena_UnifFit:DataFolderName
		//SVAR DFInt=root:Packages:Irena_UnifFit:IntensityWaveName
		//SVAR DFQ=root:Packages:Irena_UnifFit:QWaveName
		//SVAR DFE=root:Packages:Irena_UnifFit:ErrorWaveName
		variable IsAllAllRight=1
		if (cmpstr(DFloc,"---")==0)
			IsAllAllRight=0
		endif
		
		if (IsAllAllRight)
			IR1A_RecoverOldParametersXLS()
			//IR1A_FixTabsInPanel()
			//IR1_GraphMeasuredData()
			NVAR ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
			//IR1A_DisplayLocalFits(ActiveTab)
			//IR1A_AutoUpdateIfSelected()
			//MoveWindow /W=IR1_logLogPlot 285,37,760,337
			//MoveWindow /W=IR1_IQ4_Q_Plot 285,360,760,600
		else
			Abort "Data not selected properly"
		endif
	endif
	
	if (cmpstr(ctrlName,"Add_Last_Results_to_XLS01")==0)
		//here goes what is done, when user pushes Add last results button
		SVAR DFloc=root:Packages:Irena_UnifFit:DataFolderName
		//SVAR DFInt=root:Packages:Irena_UnifFit:IntensityWaveName
		//SVAR DFQ=root:Packages:Irena_UnifFit:QWaveName
		//SVAR DFE=root:Packages:Irena_UnifFit:ErrorWaveName
		IsAllAllRight=1
		if (cmpstr(DFloc,"---")==0)
			IsAllAllRight=0
		endif
		
		if (IsAllAllRight)
			//**********************************
			IR1A_ExportASCII_ToXLS_notebook()
		else
			Abort "Data not selected properly"
		endif
	endif
	
	
	if(cmpstr(ctrlName,"Start_Erase_XLS_Notebook")==0)
		//Erase the old notebook that is it if it exists
		DoWindow/F NotebookXLS
	endif

	
	setDataFolder oldDF
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


//Function IR1A_XLS_Output_PanelButtonProc(ctrlName) : ButtonControl
//	String ctrlName
//
//	string oldDf=GetDataFolder(1)
//	setDataFolder root:Packages:Irena_UnifFit
//
//	if (cmpstr(ctrlName,"Add_NewData_to_XLS")==0)
//		//here goes what is done, when user pushes "Add new fit results to XLS" button
//		SVAR DFloc=root:Packages:Irena_UnifFit:DataFolderName
//		//SVAR DFInt=root:Packages:Irena_UnifFit:IntensityWaveName
//		//SVAR DFQ=root:Packages:Irena_UnifFit:QWaveName
//		//SVAR DFE=root:Packages:Irena_UnifFit:ErrorWaveName
//		variable IsAllAllRight=1
//		if (cmpstr(DFloc,"---")==0)
//			IsAllAllRight=0
//		endif
//
//print "hello out there again"
//		if (IsAllAllRight)
//			IR1A_RecoverOldParametersXLS()
//			//IR1A_FixTabsInPanel()
//			//IR1_GraphMeasuredData()
//			NVAR ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
//			//IR1A_DisplayLocalFits(ActiveTab)
//			//IR1A_AutoUpdateIfSelected()
//			//MoveWindow /W=IR1_logLogPlot 285,37,760,337
//			//MoveWindow /W=IR1_IQ4_Q_Plot 285,360,760,600
//		else
//			Abort "Data not selected properly"
//		endif
//	endif
//	
//	setDataFolder oldDF
//end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_RecoverOldParametersXLS()
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR SASBackgroundError=root:Packages:Irena_UnifFit:SASBackgroundError
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	

	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString
	if (stringmatch(ListOfWaves, "*UnifiedFitIntensity*" ))
		string ListOfSolutions=""
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*UnifiedFitIntensity*"))
				tempString=stringFromList(i,ListOfWaves)
				Wave tempwv=$(DataFolderName+tempString)
				tempString=stringByKey("UsersComment",note(tempwv),"=")
				ListOfSolutions+=stringFromList(i,ListOfWaves)+"*  "+tempString+";"
			endif
		endfor
		DataExists=1
		string ReturnSolution=""
		Prompt ReturnSolution, "Select solution to Save in XLS", popup,  ListOfSolutions+";No Solutions Found"
		DoPrompt "Previous solutions found, select one to Save in XLS", ReturnSolution
		if (V_Flag)
			abort
		endif
	endif

	if (DataExists==1 && cmpstr("No Solutions Found", ReturnSolution)!=0)
		ReturnSolution=ReturnSolution[0,strsearch(ReturnSolution, "*", 0 )-1]
		Wave/Z OldDistribution=$(DataFolderName+ReturnSolution)

		string OldNote=note(OldDistribution)
		NumberOfLevels=NumberByKey("NumberOfModelledLevels", OldNote,"=")
		SASBackground =NumberByKey("SASBackground", OldNote,"=")
		SASBackgroundError =NumberByKey("SASBackgroundError", OldNote,"=")
		For(i=1;i<=NumberOfLevels;i+=1)		
			IR1A_RecoverOneLevelParamXLS(i,OldNote)	
		endfor
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_RecoverOneLevelParamXLS(i,OldNote)	
	variable i
	string OldNote

	
	NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Rg")
	NVAR G=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"G")
	NVAR P=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"P")
	NVAR B=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"B")
	NVAR ETA=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"ETA")
	NVAR PACK=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"PACK")
	NVAR RgCO=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"RgCO")
	NVAR RgError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"RgError")
	NVAR GError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"GError")
	NVAR PError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"PError")
	NVAR BError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"BError")
	NVAR ETAError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"ETAError")
	NVAR PACKError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"PACKError")
	NVAR RgCOError=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"RgCOError")
	NVAR K=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"K")
	NVAR Corelations=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Corelations")
	NVAR MassFractal=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"MassFractal")
	NVAR Invariant =$("Level"+num2str(i)+"Invariant")
	NVAR SurfaceToVolumeRatio =$("Level"+num2str(i)+"SurfaceToVolRat")

	Rg=NumberByKey("Level"+num2str(i)+"Rg", OldNote,"=")
	RgError=NumberByKey("Level"+num2str(i)+"RgError", OldNote,"=")
	G=NumberByKey("Level"+num2str(i)+"G", OldNote,"=")
	GError=NumberByKey("Level"+num2str(i)+"GError", OldNote,"=")
	P=NumberByKey("Level"+num2str(i)+"P", OldNote,"=")
	PError=NumberByKey("Level"+num2str(i)+"PError", OldNote,"=")
	B=NumberByKey("Level"+num2str(i)+"B", OldNote,"=")
	BError=NumberByKey("Level"+num2str(i)+"BError", OldNote,"=")
	ETA=NumberByKey("Level"+num2str(i)+"ETA", OldNote,"=")
	ETAError=NumberByKey("Level"+num2str(i)+"ETAError", OldNote,"=")
	PACK=NumberByKey("Level"+num2str(i)+"PACK", OldNote,"=")
	PACKError=NumberByKey("Level"+num2str(i)+"PACKError", OldNote,"=")
	RgCO=NumberByKey("Level"+num2str(i)+"RgCO", OldNote,"=")
	RgCOError=NumberByKey("Level"+num2str(i)+"RgCOError", OldNote,"=")
	K=NumberByKey("Level"+num2str(i)+"K", OldNote,"=")
	Corelations=NumberByKey("Level"+num2str(i)+"Corelations", OldNote,"=")
	MassFractal=NumberByKey("Level"+num2str(i)+"MassFractal", OldNote,"=")
	Invariant=NumberByKey("Level"+num2str(i)+"Invariant", OldNote,"=")
	SurfaceToVolumeRatio=NumberByKey("Level"+num2str(i)+"SurfaceToVolumeRatio", OldNote,"=")
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_PanelPopupControlXLS(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit

	if (cmpstr(ctrlName,"SelectDataFolderXLS")==0)
		//here we do what needs to be done when we select data folder
		SVAR Dtf=root:Packages:Irena_UnifFit:DataFolderName
		Dtf=popStr
		//PopupMenu IntensityDataName mode=1
		//PopupMenu QvecDataName mode=1
		//PopupMenu ErrorDataName mode=1
	endif
	
	setDataFolder oldDF

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_ExportASCII_ToXLS_notebook()

	//here we need to copy the export results out of Igor
	//before that we need to also attach note to teh waves with the results
	
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit//:XLS_Export
	
	//Wave OriginalQvector=root:Packages:Irena_UnifFit:OriginalQvector
	//Wave OriginalIntensity=root:Packages:Irena_UnifFit:OriginalIntensity
	//Wave OriginalError=root:Packages:Irena_UnifFit:OriginalError
	//Wave UnifiedFitIntensity=root:Packages:Irena_UnifFit:UnifiedFitIntensity
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	//SVAR XLS_ExportString=root:Packages:Irena_UnifFit:XLS_Export
	
	//Duplicate/O OriginalQvector, tempOriginalQvector
	//Duplicate/O OriginalIntensity, tempOriginalIntensity
	//Duplicate/O OriginalError, tempOriginalError
	//Duplicate/O UnifiedFitIntensity, tempUnifiedFitIntensity
	//string ListOfWavesForNotes="tempOriginalQvector;tempOriginalIntensity;tempOriginalError;tempUnifiedFitIntensity;"
	
	//IR1A_AppendWaveNote(ListOfWavesForNotes)

	//string Comments=""//Record of Data evaluation with Irena SAS modeling macros using UNIFIED fit model;"
	//Comments+="For details on method see: http://www.eng.uc.edu/~gbeaucag/PDFPapers/Beaucage2.pdf, Beaucage1.pdf, and ma970373t.pdf;"
	//Comments+="Intensity is modelled using formula: Ii(q) = Gi exp(-q^2Rgi^2/3) + exp(-q^2Rg(i-1)^2/3)Bi {[erf(q Rgi/sqrt(6))]^3/q}^Pi;where i is level number;"
	//Comments+="Note that there are variations on this formula if corelations and mass fractal are assumed, please check references;"
	//Comments+=note(tempUnifiedFitIntensity)//+"Qvector[A]\tExperimental intensity[1/cm]\tExperimental error\tUnified Fit model intensity[1/cm]\r"
	//variable pos=0
	//variable ComLength=strlen(Comments)
	//Will write Level 1 G Sg Rg sRg B sB P sP eta seta pack spack Level 2 G Sg Rg sRg B sB P sP eta seta pack spack Level 3 Level 4  etc
	
	String nb = "NotebookXLS"
	//Make notebook and Write titles if it doesn't exist
	variable count=1
	if(WinType("NotebookXLS")==0)//if there is no existing notebook by this name
		NewNotebook/N=$nb/F=0/V=0/K=0/W=(5.25,40.25,558,408.5) as "XLS_Export_Notebook"
		Notebook $nb text="Filename	NumberOfLevels	"
		Do 
			Notebook $nb text="Level"+num2str(count)+"G"+"\t"
			Notebook $nb text="Level"+num2str(count)+"GError"+"\t"
			
			Notebook $nb text="Level"+num2str(count)+"Rg"+"\t"
			Notebook $nb text="Level"+num2str(count)+"RgError"+"\t"
			
			Notebook $nb text="Level"+num2str(count)+"B"+"\t"
			Notebook $nb text="Level"+num2str(count)+"BError"+"\t"
			
			Notebook $nb text="Level"+num2str(count)+"P"+"\t"
			Notebook $nb text="Level"+num2str(count)+"PError"+"\t"
			
			Notebook $nb text="Level"+num2str(count)+"RgCO"+"\t"
			Notebook $nb text="Level"+num2str(count)+"RgCOError"+"\t"
			
			Notebook $nb text="Level"+num2str(count)+"Eta"+"\t"
			Notebook $nb text="Level"+num2str(count)+"EtaError"+"\t"
			
			Notebook $nb text="Level"+num2str(count)+"Pack"+"\t"
			Notebook $nb text="Level"+num2str(count)+"PackError"+"\t"
			
			Notebook $nb text="Level"+num2str(count)+"Mass Frac?"+"\t"
			Notebook $nb text="Level"+num2str(count)+"S/V"+"\t"
			Notebook $nb text="Level"+num2str(count)+"DOA"+"\t"
			
			count+=1
		while (count<(NumberOfLevels+1))
		Notebook $nb text="\r"
	endif
	
	count=1
	string varname
	string filename1
	filename1=StringFromList(ItemsInList(DataFolderName,":")-1, DataFolderName,":")
	Notebook $nb text=filename1+"\t"+num2str(NumberOfLevels)+"\t"
	Do 
		varname=("Level"+num2str(count)+"G")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"GError")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		varname=("Level"+num2str(count)+"Rg")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"RgError")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		varname=("Level"+num2str(count)+"B")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"BError")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		varname=("Level"+num2str(count)+"P")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"PError")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		varname=("Level"+num2str(count)+"RgCO")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"RgCOError")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		varname=("Level"+num2str(count)+"Eta")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"EtaError")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		varname=("Level"+num2str(count)+"Pack")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"PackError")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		varname=("Level"+num2str(count)+"MassFractal")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"SurfacetoVolRat")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		varname=("Level"+num2str(count)+"DegreeofAggreg")
		Nvar value=$varname
		Notebook $nb text=num2str(value)+"\t"
		
		count+=1
	while (count<(NumberOfLevels+1))
	Notebook $nb text="\r"

	
	//variable refnum

	//Open/D/T=".txt"/M="Select file to save data to" refnum as filename1
	//filename1=S_filename
	//if (strlen(filename1)==0)
	//	abort
	//endif
	
	
	
	
	//SaveNotebook $nb as filename1
	//DoWindow /K $nb
	//Save/A/G/M="\r\n" tempOriginalQvector,tempOriginalIntensity,tempOriginalError,tempUnifiedFitIntensity as filename1	 
	


	//Killwaves tempOriginalQvector,tempOriginalIntensity,tempOriginalError,tempUnifiedFitIntensity
	setDataFolder OldDf
end


//************************************************************************************************
//AutoSave
//************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function AutoSaveXLSResults()
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit
	nvar UseIndra2Data
	string FolderNames=IN2G_NewFindFolderWithWaveTypes("root:", 10, "*", 1)
	//Here you do the save to a notebook
	variable counter=0
	SVAR DataFolderName
	string Dtf
	string DFloc
	NVAR ActiveTab
	//variable IsAlAllRight
	do
		DataFolderName=stringfromlist(counter,FolderNames)
		Dtf=DataFolderName
		//At this point I have the folder so step 2a is done, SELECT DATA FOLDER
		//Next I need to find the last solution if there is one, i.e. this could be none or last
		//STEP 2b FIND NEWEST SOLUTION
		DFloc=DataFolderName
		IR1A_RecoLastFitParametersXLS()
		//ActiveTab=root:Packages:Irena_UnifFit:ActiveTab
		
		//Next Save in the xls notebook
		//DFloc=DataFolderName
		//IsAllAllRight=1
		//if (cmpstr(DFloc,"---")==0)
		//	IsAllAllRight=0
		//endif
		
		//if (IsAllAllRight)
			//**********************************
		IR1A_ExportASCII_ToXLS_notebook()
		//else
		//	Abort "Data not selected properly"
		//endif
		counter+=1
	while(counter<(itemsInList(FolderNames,";")))
	
	//Then reset the conditions
	setDataFolder oldDF
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_RecoLastFitParametersXLS()
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR SASBackgroundError=root:Packages:Irena_UnifFit:SASBackgroundError
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	
	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString
	if (stringmatch(ListOfWaves, "*UnifiedFitIntensity*" ))
		string ListOfSolutions=""
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*UnifiedFitIntensity*"))
				tempString=stringFromList(i,ListOfWaves)
				Wave tempwv=$(DataFolderName+tempString)
				tempString=stringByKey("UsersComment",note(tempwv),"=")
				ListOfSolutions+=stringFromList(i,ListOfWaves)+"*  "+tempString+";"
			endif
		endfor
		DataExists=1
		//Return the last solution so number in list minus 1
		string ReturnSolution=stringFromList((itemsInList(ListOfSolutions)-1),ListOfSolutions)
		//Prompt ReturnSolution, "Select solution to Save in XLS", popup,  ListOfSolutions+";No Solutions Found"
		//DoPrompt "Previous solutions found, select one to Save in XLS", ReturnSolution
		//if (V_Flag)
		//	abort
		//endif
	else//This is if there is no solution
		string ReturnString="No Solutions Found"
	endif

	if (DataExists==1 && cmpstr("No Solutions Found", ReturnSolution)!=0)
		ReturnSolution=ReturnSolution[0,strsearch(ReturnSolution, "*", 0 )-1]
		Wave/Z OldDistribution=$(DataFolderName+ReturnSolution)

		string OldNote=note(OldDistribution)
		NumberOfLevels=NumberByKey("NumberOfModelledLevels", OldNote,"=")
		SASBackground =NumberByKey("SASBackground", OldNote,"=")
		SASBackgroundError =NumberByKey("SASBackgroundError", OldNote,"=")
		For(i=1;i<=NumberOfLevels;i+=1)		
			IR1A_RecoverOneLevelParamXLS(i,OldNote)	
		endfor
	endif
end