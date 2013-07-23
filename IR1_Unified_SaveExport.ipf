#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.01

//*************************************************************************\
//* Copyright (c) 2005 - 2013, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.01 added license for ANL



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1A_ExportASCIIResults()

	//here we need to copy the export results out of Igor
	//before that we need to also attach note to teh waves with the results
	
	string OldDf=getDataFOlder(1)
	setDataFolder root:Packages:Irena_UnifFit
	
	Wave OriginalQvector=root:Packages:Irena_UnifFit:OriginalQvector
	Wave OriginalIntensity=root:Packages:Irena_UnifFit:OriginalIntensity
	Wave OriginalError=root:Packages:Irena_UnifFit:OriginalError
	Wave UnifiedFitIntensity=root:Packages:Irena_UnifFit:UnifiedFitIntensity
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	
	Duplicate/O OriginalQvector, tempOriginalQvector
	Duplicate/O OriginalIntensity, tempOriginalIntensity
	Duplicate/O OriginalError, tempOriginalError
	Duplicate/O UnifiedFitIntensity, tempUnifiedFitIntensity
	string ListOfWavesForNotes="tempOriginalQvector;tempOriginalIntensity;tempOriginalError;tempUnifiedFitIntensity;"
	
	IR1A_AppendWaveNote(ListOfWavesForNotes)

	string Comments="Record of Data evaluation with Irena SAS modeling macros using UNIFIED fit model;"
	Comments+="For details on method see: http://www.eng.uc.edu/~gbeaucag/PDFPapers/Beaucage2.pdf, Beaucage1.pdf, and ma970373t.pdf;"
	Comments+="Intensity is modelled using formula: Ii(q) = Gi exp(-q^2Rgi^2/3) + exp(-q^2Rg(i-1)^2/3)Bi {[erf(q Rgi/sqrt(6))]^3/q}^Pi;where i is level number;"
	Comments+="Note that there are variations on this formula if corelations and mass fractal are assumed, please check references;"
	Comments+=note(tempUnifiedFitIntensity)+"Q[A]\tExperimental intensity[1/cm]\tExperimental error\tUnified Fit model intensity[1/cm]\r"
	variable pos=0
	variable ComLength=strlen(Comments)
	
	Do 
	pos=strsearch(Comments, ";", pos+5)
	Comments=Comments[0,pos-1]+"\r$\t"+Comments[pos+1,inf]
	while (pos>0)

	string filename1
	filename1=StringFromList(ItemsInList(DataFolderName,":")-1, DataFolderName,":")+"_SAS_model.txt"
	variable refnum

	Open/D/T=".txt"/M="Select file to save data to" refnum as filename1
	filename1=S_filename
	if (strlen(filename1)==0)
		abort
	endif
	
	String nb = "Notebook0"
	NewNotebook/N=$nb/F=0/V=0/K=0/W=(5.25,40.25,558,408.5) as "ExportData"
	Notebook $nb defaultTab=20, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb font="Arial", fSize=10, fStyle=0, textRGB=(0,0,0)
	Notebook $nb text=Comments	
	
	
	SaveNotebook $nb as filename1
	DoWindow /K $nb
	Save/A/G/M="\r\n" tempOriginalQvector,tempOriginalIntensity,tempOriginalError,tempUnifiedFitIntensity as filename1	 
	


	Killwaves/Z tempOriginalQvector,tempOriginalIntensity,tempOriginalError,tempUnifiedFitIntensity
	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_AppendWaveNote(ListOfWavesForNotes)
	string ListOfWavesForNotes
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_UnifFit

	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels

	NVAR SASBackground=root:Packages:Irena_UnifFit:SASBackground
	NVAR SASBackgroundError=root:Packages:Irena_UnifFit:SASBackgroundError
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	string ExperimentName=IgorInfo(1)
	variable i
	For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)

		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"IgorExperimentName",ExperimentName)
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"DataFolderinIgor",DataFolderName)
		
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"DistributionTypeModelled", "Unified Fit")	
		
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"NumberOfModelledLevels",num2str(NumberOfLevels))

		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"SASBackground",num2str(SASBackground))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"SASBackgroundError",num2str(SASBackgroundError))
	endfor

	For(i=1;i<=NumberOfLevels;i+=1)
		IR1A_AppendWNOfDist(i,ListOfWavesForNotes)
	endfor

	setDataFolder oldDF

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_AppendWNOfDist(level,ListOfWavesForNotes)
	variable level
	string ListOfWavesForNotes
	

	
	NVAR Rg=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Rg")
	NVAR G=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"G")
	NVAR P=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"P")
	NVAR B=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"B")
	NVAR ETA=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"ETA")
	NVAR PACK=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PACK")
	NVAR RgCO=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgCO")
	NVAR RgError=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgError")
	NVAR GError=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"GError")
	NVAR PError=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PError")
	NVAR BError=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"BError")
	NVAR ETAError=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"ETAError")
	NVAR PACKError=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"PACKError")
	NVAR RgCOError=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"RgCOError")
	NVAR K=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"K")
	NVAR Corelations=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Corelations")
	NVAR MassFractal=$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"MassFractal")
	NVAR Invariant =$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"Invariant")
	NVAR SurfaceToVolumeRatio =$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"SurfaceToVolRat")
	NVAR LinkRgCO =$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"LinkRgCO")
	NVAR DegreeOfAggreg =$("root:Packages:Irena_UnifFit:Level"+num2str(level)+"DegreeOfAggreg")


	variable i
	For(i=0;i<ItemsInList(ListOfWavesForNotes);i+=1)
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"Rg",num2str(Rg))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"RgError",num2str(RgError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"G",num2str(G))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"GError",num2str(GError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"P",num2str(P))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"PError",num2str(PError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"B",num2str(B))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"BError",num2str(BError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"ETA",num2str(ETA))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"ETAError",num2str(ETAError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"PACK",num2str(PACK))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"PACKError",num2str(PACKError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"RgCO",num2str(RGCO))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"RgCOError",num2str(RGCOError))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"K",num2str(K))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"Corelations",num2str(Corelations))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"MassFractal",num2str(MassFractal))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"Invariant",num2str(Invariant))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"SurfaceToVolumeRatio",num2str(SurfaceToVolumeRatio))

		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"LinkRgCO",num2str(LinkRgCO))
		IN2G_AppendorReplaceWaveNote(stringFromList(i,ListOfWavesForNotes),"Level"+num2str(level)+"DegreeOfAggreg",num2str(DegreeOfAggreg))
	endfor
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1A_CopyDataBackToFolder(StandardOrUser, [Saveme])
	string StandardOrUser, SaveMe
	//here we need to copy the final data back to folder
	//before that we need to also attach note to teh waves with the results
	if(ParamIsDefault(SaveMe ))
		SaveMe="NO"
	ENDIF
	string OldDf=getDataFOlder(1)
	setDataFolder root:Packages:Irena_UnifFit
	
	string UsersComment="Unified Fit results from "+date()+"  "+time()
	
	Prompt UsersComment, "Modify comment to be included with these results"
	if(!stringmatch(SaveMe,"Yes"))
		DoPrompt "Copy data back to folder comment", UsersComment
		if (V_Flag)
			abort
		endif
	endif
	Wave UnifiedFitIntensity=root:Packages:Irena_UnifFit:UnifiedFitIntensity
	Wave UnifiedFitQvector=root:Packages:Irena_UnifFit:UnifiedFitQvector
	
	NVAR NumberOfLevels=root:Packages:Irena_UnifFit:NumberOfLevels
	SVAR DataFolderName=root:Packages:Irena_UnifFit:DataFolderName
	NVAR ExportLocalFits=root:Packages:Irena_UnifFit:ExportLocalFits
	variable/G LastSavedUnifOutput
	
	Duplicate/O UnifiedFitIntensity, tempUnifiedFitIntensity
	Duplicate/O UnifiedFitQvector, tempUnifiedFitQvector
	string ListOfWavesForNotes="tempUnifiedFitIntensity;tempUnifiedFitQvector;"
	
	IR1A_AppendWaveNote(ListOfWavesForNotes)
	
	setDataFolder $DataFolderName
	string tempname 
	variable ii=0, i
	For(ii=0;ii<1000;ii+=1)
		tempname="UnifiedFitIntensity_"+num2str(ii)
		if (checkname(tempname,1)==0)
			break
		endif
	endfor
	LastSavedUnifOutput=ii
	Duplicate /O tempUnifiedFitIntensity, $tempname
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)

	tempname="UnifiedFitQvector_"+num2str(ii)
	Duplicate /O tempUnifiedFitQvector, $tempname
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	
	//and now local fits also
	if(ExportLocalFits)
		For(i=1;i<=NumberOfLevels;i+=1)
			Wave FitIntPowerLaw=$("root:Packages:Irena_UnifFit:FitLevel"+num2str(i)+"Porod")
			Wave FitIntGuinier=$("root:Packages:Irena_UnifFit:FitLevel"+num2str(i)+"Guinier")
			Wave LevelUnified=$("root:Packages:Irena_UnifFit:Level"+num2str(i)+"Unified")
			tempname="UniLocalLevel"+num2str(i)+"Unified_"+num2str(ii)
			Duplicate /O LevelUnified, $tempname
			IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
			IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
			IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
			tempname="UniLocalLevel"+num2str(i)+"Pwrlaw_"+num2str(ii)
			Duplicate /O FitIntPowerLaw, $tempname
			IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
			IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
			IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
			tempname="UniLocalLevel"+num2str(i)+"Guinier_"+num2str(ii)
			Duplicate /O FitIntGuinier, $tempname
			IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
			IN2G_AppendorReplaceWaveNote(tempname,"Units","A-1")
			IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
		endfor
	endif
	setDataFolder root:Packages:Irena_UnifFit

	Killwaves/Z tempUnifiedFitIntensity,tempUnifiedFitQvector
	setDataFolder OldDf
end
