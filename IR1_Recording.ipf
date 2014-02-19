#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.03


//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.03 DWS changes
//2.02 Dale added some Porod note taking for Unified fit model. 
//2.01 added license for ANL


//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from www.uni.aps.anl.gov/~ilavsky
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky, January 2002

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov


//this file contains functions related to the recording in the notebook... The recordnig is done 
//only before and after fitting - at this time.


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1S_RecordResults(CalledFromWere)
	string CalledFromWere	//before or after - that means fit...

	string OldDF=GetDataFolder(1)
	setdataFolder root:Packages:SAS_Modeling

	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions

	NVAR SASBackground=root:Packages:SAS_Modeling:SASBackground
	NVAR FitSASBackground=root:Packages:SAS_Modeling:FitSASBackground

	SVAR DataAreFrom=root:Packages:SAS_Modeling:DataFolderName
	SVAR Dist1ShapeModel=root:Packages:SAS_Modeling:Dist1ShapeModel
	SVAR Dist1DistributionType=root:Packages:SAS_Modeling:Dist1DistributionType
	SVAR Dist2ShapeModel=root:Packages:SAS_Modeling:Dist2ShapeModel
	SVAR Dist2DistributionType=root:Packages:SAS_Modeling:Dist2DistributionType
	SVAR Dist3ShapeModel=root:Packages:SAS_Modeling:Dist3ShapeModel
	SVAR Dist3DistributionType=root:Packages:SAS_Modeling:Dist3DistributionType
	SVAR Dist4ShapeModel=root:Packages:SAS_Modeling:Dist4ShapeModel
	SVAR Dist4DistributionType=root:Packages:SAS_Modeling:Dist4DistributionType
	SVAR Dist5ShapeModel=root:Packages:SAS_Modeling:Dist5ShapeModel
	SVAR Dist5DistributionType=root:Packages:SAS_Modeling:Dist5DistributionType
	
	NVAR Dist1Contrast=root:Packages:SAS_Modeling:Dist1Contrast
	NVAR Dist2Contrast=root:Packages:SAS_Modeling:Dist2Contrast
	NVAR Dist3Contrast=root:Packages:SAS_Modeling:Dist3Contrast
	NVAR Dist4Contrast=root:Packages:SAS_Modeling:Dist4Contrast
	NVAR Dist5Contrast=root:Packages:SAS_Modeling:Dist5Contrast
	
	NVAR Dist1Mean=root:Packages:SAS_Modeling:Dist1Mean
	NVAR Dist1Median=root:Packages:SAS_Modeling:Dist1Median
	NVAR Dist1Mode=root:Packages:SAS_Modeling:Dist1Mode
	NVAR Dist2Mean=root:Packages:SAS_Modeling:Dist2Mean
	NVAR Dist2Median=root:Packages:SAS_Modeling:Dist2Median
	NVAR Dist2Mode=root:Packages:SAS_Modeling:Dist2Mode
	NVAR Dist3Mean=root:Packages:SAS_Modeling:Dist3Mean
	NVAR Dist3Median=root:Packages:SAS_Modeling:Dist3Median
	NVAR Dist3Mode=root:Packages:SAS_Modeling:Dist3Mode
	NVAR Dist4Mean=root:Packages:SAS_Modeling:Dist4Mean
	NVAR Dist4Median=root:Packages:SAS_Modeling:Dist4Median
	NVAR Dist4Mode=root:Packages:SAS_Modeling:Dist4Mode
	NVAR Dist5Mean=root:Packages:SAS_Modeling:Dist5Mean
	NVAR Dist5Median=root:Packages:SAS_Modeling:Dist5Median
	NVAR Dist5Mode=root:Packages:SAS_Modeling:Dist5Mode
	NVAR Dist1FWHM=root:Packages:SAS_Modeling:Dist1FWHM
	NVAR Dist2FWHM=root:Packages:SAS_Modeling:Dist2FWHM
	NVAR Dist3FWHM=root:Packages:SAS_Modeling:Dist3FWHM
	NVAR Dist4FWHM=root:Packages:SAS_Modeling:Dist4FWHM
	NVAR Dist5FWHM=root:Packages:SAS_Modeling:Dist5FWHM
	
	IR1_CreateLoggbook()		//this creates the logbook
	SVAR nbl=root:Packages:SAS_Modeling:NotebookName

	IR1L_AppendAnyText("     ")
	if (cmpstr(CalledFromWere,"before")==0)
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Parameters before starting Fitting on the data from: "+DataAreFrom)
		IR1_InsertDateAndTime(nbl)
		IR1L_AppendAnyText(" ")
		IR1L_AppendAnyText("Started on       \t"+ Date()+"    "+time())
		IR1L_AppendAnyText("Number of modelled distributions: "+num2str(NumberOfDistributions))
	else			//after
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Results of the Fitting on the data from: "+DataAreFrom)	
		IR1_InsertDateAndTime(nbl)
		IR1L_AppendAnyText(" ")
		IR1L_AppendAnyText("Finished on       \t"+ Date()+"    "+time())
		IR1L_AppendAnyText("Number of fitted distributions: "+num2str(NumberOfDistributions))
		IR1L_AppendAnyText("Fitting results: ")
	endif
	IR1L_AppendAnyText("SAS background = "+num2str(SASBackground)+", was fitted? = "+num2str(FitSASBackground)+"       (yes=1/no=0)")
	variable i
	For (i=1;i<=NumberOfDistributions;i+=1)
		IR1L_AppendAnyText("***********  Distribution "+num2str(i))
		SVAR tempShape=$("Dist"+num2str(i)+"ShapeModel")
			IR1L_AppendAnyText("Particle shape:     \t"+tempShape)
		SVAR tempDistType=$("Dist"+num2str(i)+"DistributionType")
			IR1L_AppendAnyText("Distribution type:  \t"+tempDistType)
		NVAR tempVal =$("Dist"+num2str(i)+"Contrast")
			IR1L_AppendAnyText("Contrast       \t"+ num2str(tempVal))
			
		NVAR tempVal =$("Dist"+num2str(i)+"VolFraction")
		NVAR tempValError =$("Dist"+num2str(i)+"VolFractionError")
		NVAR fitTempVal=$("Dist"+num2str(i)+"FitVol")
			IR1L_AppendAnyText("Volume      \t"+ num2str(tempVal)+"       ,  \tfitted? = "+num2str(fitTempVal)+"   , error = "+num2str(tempValError))
		NVAR tempVal =$("Dist"+num2str(i)+"Location")
		NVAR tempValError =$("Dist"+num2str(i)+"LocationError")
		NVAR fitTempVal=$("Dist"+num2str(i)+"FitLocation")
			IR1L_AppendAnyText("Location       \t"+ num2str(tempVal)+"       ,  \tfitted? = "+num2str(fitTempVal)+"   , error = "+num2str(tempValError))

		if (cmpstr(tempDistType,"LogNormal")==0 || cmpstr(tempDistType,"Gauss")==0)		
			NVAR tempVal =$("Dist"+num2str(i)+"Scale")
			NVAR tempValError =$("Dist"+num2str(i)+"ScaleError")
			NVAR fitTempVal=$("Dist"+num2str(i)+"FitScale")
				IR1L_AppendAnyText("Scale      \t"+ num2str(tempVal)+"       ,  \tfitted? = "+num2str(fitTempVal)+"   , error = "+num2str(tempValError))
		endif
		if (cmpstr(tempDistType,"LogNormal")==0)		
			NVAR tempVal =$("Dist"+num2str(i)+"Shape")
			NVAR tempValError =$("Dist"+num2str(i)+"ShapeError")
			NVAR fitTempVal=$("Dist"+num2str(i)+"FitShape")
				IR1L_AppendAnyText("Shape       \t"+ num2str(tempVal)+"       ,  \tfitted? = "+num2str(fitTempVal)+"   , error = "+num2str(tempValError))
		endif
		
		NVAR UseInterference=$("Dist"+num2str(i)+"UseInterference")
		if(UseInterference)
			NVAR InterferencePhi=$("Dist"+num2str(i)+"InterferencePhi")
			NVAR InterferenceEta=$("Dist"+num2str(i)+"InterferenceEta")
			NVAR InterferencePhiError=$("Dist"+num2str(i)+"InterferencePhiError")
			NVAR InterferenceEtaError=$("Dist"+num2str(i)+"InterferenceEtaError")
			NVAR FitInterferencePhi=$("Dist"+num2str(i)+"FitInterferencePhi")
			NVAR FitInterferenceETA=$("Dist"+num2str(i)+"FitInterferenceETA")
				IR1L_AppendAnyText("Used Interferences")
				IR1L_AppendAnyText("ETA       \t"+ num2str(InterferenceEta)+"       ,  \tfitted? = "+num2str(FitInterferenceETA)+"   , error = "+num2str(InterferenceEtaError))
				IR1L_AppendAnyText("Phi/PACK \t"+ num2str(InterferencePhi)+"       ,  \tfitted? = "+num2str(FitInterferencePhi)+"   , error = "+num2str(InterferencePhiError))
		endif
		
		NVAR tempVal =$("Dist"+num2str(i)+"Mean")
			IR1L_AppendAnyText("Mean       \t"+ num2str(tempVal))
		NVAR tempVal =$("Dist"+num2str(i)+"Median")
			IR1L_AppendAnyText("Median       \t"+ num2str(tempVal))
		NVAR tempVal =$("Dist"+num2str(i)+"Mode")
			IR1L_AppendAnyText("Mode       \t"+ num2str(tempVal))
		NVAR tempVal =$("Dist"+num2str(i)+"FWHM")
			IR1L_AppendAnyText("FWHM       \t"+ num2str(tempVal))

			IR1L_AppendAnyText("  ")
	endfor
	
	if (cmpstr(CalledFromWere,"after")==0)
		IR1L_AppendAnyText("Fit has been reached with following parameters")
		IR1_InsertDateAndTime(nbl)
		NVAR AchievedChisq
		IR1L_AppendAnyText("Chi-Squared \t"+ num2str(AchievedChisq))

		DoWindow /F IR1_LogLogPlotLSQF
		if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
			IR1L_AppendAnyText("Points selected for fitting \t"+ num2str(pcsr(A)) + "   to \t"+num2str(pcsr(B)))
		else
			IR1L_AppendAnyText("Whole range of data selected for fitting")
		endif
		IR1L_AppendAnyText(" ")
	endif			//after

	setdataFolder oldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1L_AppendAnyText(TextToBeInserted)		//this function checks for existance of notebook
	string TextToBeInserted						//and appends text to the end of the notebook
	Silent 1
	TextToBeInserted=TextToBeInserted+"\r"
    SVAR/Z nbl=root:Packages:SAS_Modeling:NotebookName
	if(SVAR_exists(nbl))
		if (strsearch(WinList("*",";","WIN:16"),nbl,0)!=-1)				//Logs data in Logbook
			Notebook $nbl selection={endOfFile, endOfFile}
			Notebook $nbl text=TextToBeInserted
		endif
	endif
end

Function IR1L_AppendAnyPorodText(TextToBeInserted)		//**DWS
	string TextToBeInserted						//and appends text to the end of the notebook
	Silent 1
	TextToBeInserted=TextToBeInserted+"\r"
    SVAR/Z nbl=root:Packages:Irena_AnalUnifFit:PorodNotebookName
	if(SVAR_exists(nbl))
		if (strsearch(WinList("*",";","WIN:16"),nbl,0)==-1)				//Create PorodAnalysisResults notebook if necessary
			IR1_CreatePorodLogbook()		
		endif
		Notebook $nbl selection={endOfFile, endOfFile}
		Notebook $nbl text=TextToBeInserted		
	endif
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1_CreateLoggbook()

	SVAR/Z nbl=root:Packages:SAS_Modeling:NotebookName
	if(!SVAR_Exists(nbl))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:SAS_Modeling 
		String/G root:Packages:SAS_Modeling:NotebookName=""
		SVAR nbl=root:Packages:SAS_Modeling:NotebookName
		nbL="SAS_FitLog"
	endif
	
	string nbLL=nbl
	
	Silent 1
	if (strsearch(WinList("*",";","WIN:16"),nbL,0)!=-1) 		///Logbook exists
		DoWindow/B $nbl
	else
		NewNotebook/K=3/V=0/N=$nbl/F=1/V=1/W=(235.5,44.75,817.5,592.25) as nbl+": Irena Log"
		Notebook $nbl defaultTab=144, statusWidth=238, pageMargins={72,72,72,72}
		Notebook $nbl showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nbl newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={2.5*72, 3.5*72 + 8192, 5*72 + 3*8192}, rulerDefaults={"Arial",10,0,(0,0,0)}
		Notebook $nbl ruler=Normal; Notebook $nbl  justification=1, rulerDefaults={"Arial",14,1,(0,0,0)}
		Notebook $nbl text="This is log results of processing SAS data with Irena package.\r"
		Notebook $nbl text="\r"
		Notebook $nbl ruler=Normal
		IR1_InsertDateAndTime(nbl)
	endif

end

Function IR1_CreatePorodLogbook()//***DWS

	SVAR/Z nb=root:Packages:Irena_AnalUnifFit:PorodNotebookName
	if(!SVAR_Exists(nb))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena_AnalUnifFit
		String/G root:Packages:Irena_AnalUnifFit:PorodNotebookName=""
		SVAR nb=root:Packages:Irena_AnalUnifFit:PorodNotebookName
		nb="PorodAnalysisResults"
	endif
	Silent 1
	if (strsearch(WinList("*",";","WIN:16"),nb,0)!=-1) 		///Logbook exists
		DoWindow/B $nb
	else


	NewNotebook/N=$nb/F=1/V=1/K=3/W=(83,131,1766,800) as "PorodAnalysisResults"
	Notebook $nb defaultTab=144, statusWidth=238
	Notebook $nb showRuler=1, rulerUnits=1, updating={1, 60}
	Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={180,252+1*8192,360+3*8192}, rulerDefaults={"Arial",10,0,(0,0,0)}
	Notebook $nb newRuler=logbookRuler, justification=0, margins={0,0,1578}, spacing={0,0,0}, tabs={204+1*8192,258+1*8192,319+1*8192,388+1*8192,432+1*8192,503+1*8192,580+1*8192,665+1*8192,746+1*8192,839+1*8192,912+1*8192,980+1*8192,1035+1*8192,1097+1*8192,1167+1*8192,1268+1*8192,1377+1*8192,1476+1*8192}, rulerDefaults={"Arial",14,1,(0,0,0)}
	Notebook $nb ruler=logbookRuler, fSize=10
	Notebook $nb text="rWave\tMethod\tLvl\tIrenaLvls\tUseCsrs\tB[cm-1A-4]\tQv[Cm-1A-3 ]\tpiB/Q[m2/cm3]\tMinDens[g/cm3]\tMajDens[g/cm3]\tS"
	Notebook $nb text="amDens[g/cm3]\tphimin\tSv[m2/cm3]\tSm[m2/g]\tMinChord[A]\tMajChord[A]\t10^-10xSLmin[cm/g]\t10^-10xSLmaj[cm/g]\r"
	Notebook $nb fSize=-1
	Notebook $nb text="rWv\tMeth\tLvl\tLvls\tCsrs\tB\tQv\tpiBoQ\tMinDen\tMajDen\tSamDen\tphimin\tSv\tSm\tMinCh\tMajCh\tSLmin \tSLmaj\r"
	Notebook $nb text="\r"

	
	endif
end
	
	

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1_PullUpLoggbook()

	if(!DataFolderExists("root:Packages:SAS_Modeling"))
		abort "Notebook does not exist, folder does not exist,nothing exists... Did not initialize properly"
	endif

	SVAR/Z nbl=root:Packages:SAS_Modeling:NotebookName
	if(!Svar_Exists(nbL))
		abort "Notebook does not exist, folder does not exist,nothing exists... Did not initialize properly"
	endif
	string nbLL=nbl
//	string nbLL="SAS_FitLog"
	Silent 1
	if (strsearch(WinList("*",";","WIN:16"),nbLL,0)!=-1) 		///Logbook exists
		DoWindow/F $nbLL
	endif

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1_InsertDateAndTime(nbl)
	string nbl
	
	Silent 1
	string bucket11
	Variable/D now=datetime
	bucket11=Secs2Date(now,0)+",  "+Secs2Time(now,0) +"\r"
	//SVAR nbl=root:Packages:SAS_Modeling:NotebookName
	Notebook $nbl selection={endOfFile, endOfFile}
	Notebook $nbl text=bucket11
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

