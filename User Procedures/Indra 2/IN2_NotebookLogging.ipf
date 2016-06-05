#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.10


//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/




//**********************************************************************************************

Function IN2N_CreateShowNtbkForLogging(show)
	variable show		//show can be 1 to show notebook if necessary...

	SVAR/Z nbl=root:Packages:Indra3:NotebookName
	if(!SVAR_Exists(nbl))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Indra3 
		String/G root:Packages:Indra3:NotebookName=""
		SVAR nbl=root:Packages:Indra3:NotebookName
		nbL="LogBook"
	endif
	
	string nbLL=nbl
	
//	Prompt nbLL, "Give me Name for the LogBook, 11 letters max"
//	DoPrompt "Input name for Logbook", nbLL
//	nbl=nbLL
//	nbl=CleanupName(nbl,0)
//	nbl=nbl[0,10]

	
	Silent 1
	if ((strsearch(WinList("*",";","WIN:16"),nbL,0)!=-1))		///Logbook exists 
		//DoWindow/F $nbl
	else
		NewNotebook/K=3/V=0/N=$nbl/F=1/V=1/W=(235.5,44.75,817.5,592.25) as nbl+":   Log of data evaluation"
//		DoWindow/C $nbl
		Notebook $nbl defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
		Notebook $nbl showRuler=1, rulerUnits=1, updating={1, 60}
		Notebook $nbl newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",10,0,(0,0,0)}
		Notebook $nbl ruler=Normal; Notebook $nbl  justification=1, rulerDefaults={"Arial",14,1,(0,0,0)}
		Notebook $nbl text="This is log of the data evaluation with USAXS macro set.\r"
		Notebook $nbl text="\r"
		Notebook $nbl ruler=Normal
//		IN2N_LogBookControlPanel()
		IN2N_InsertDateAndTime()
	endif

	if (show)		///Logbook want to show it...
		DoWindow/F $nbl
	endif
End
//**********************************************************************************************
Function IN2N_CreateSummaryNotebook(AutoExport)
	variable AutoExport	//set to 1 to automatically save
	String nbL="Summary"
	Prompt nbL, "Give me Name for the Summary Notebook, 11 letters max"
	DoPrompt "Summary notebook name?", nbL
	
	if (V_flag)
		abort
	endif
	
	nbl=CleanupName(nbl,0)
	nbl=nbl[0,10]
	
	Silent 1
	if (strsearch(WinList("*",";","WIN:16"),nbL,0)==0) 		///Logbook exists
		Abort "Notebook with this name exists, use another name please..."
	endif
	
	NewNotebook/N=$nbL/F=1/V=1/W=(235.5,44.75,817.5,592.25) as nbL+": Summary of data parameters"

		DoWindow/C $nbL
	Notebook $nbL defaultTab=36, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nbL showRuler=1, rulerUnits=1, updating={1, 60}
	Notebook $nbL newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Arial",10,0,(0,0,0)}
	Notebook $nbL ruler=Normal; Notebook $nbL  justification=1, rulerDefaults={"Arial",14,1,(0,0,0)}
	Notebook $nbL text="This is SUMMARY of the data evaluation with USAXS macro set.\r"
	Notebook $nbL text="\r"
	Notebook $nbL ruler=Normal
	
	IN2N_RecordSummary(nbL,"root:USAXS",33)
	
	if (AutoExport)
		//save here Save/G/M="\r\n"/P=ExportDatapath DSM_Qvec,DSM_Int, DSM_Error as filename1	
		SaveNotebook/I/S=4/P=ExportDatapath $nbL as "SummaryNotebook.rtf"
	endif
End
      
Function/S IN2N_RecordSummary(nbkName,dfStart, levels)
        string dfStart, nbkName
        Variable levels
               
        dfStart+=":"
        
        String dfSave, templist
             
        dfSave = GetDataFolder(1)
        templist = DataFolderDir(1)

        SetDataFolder $dfStart

    	  IN2N_AppendSummaryData(nbkName) 		//this calls routine which makes the record of parameters

        levels -= 1
        if (levels <= 0)
                return ""
        endif
        
        String subDF
        Variable index = 0
        do
                String temp
                temp = PossiblyQuoteName(GetIndexedObjName(dfStart, 4, index))     // Name of next data folder.

                if (strlen(temp) == 0)
                        break                                                                           // No more data folders.
                endif	     		  
                subDF = dfStart + temp
                IN2N_RecordSummary(nbkName,subDF,levels)     // Recurse.
                index += 1
        while(1)
        
        SetDataFolder(dfSave)
        return ""
End

//**********************************************************************************************
Function  IN2N_AppendSummaryData(nbkName)
	string nbkName
	string MyFolder=GetDataFolder(1)

          Notebook $nbkName selection={endOfFile, endOfFile}, text="****************************************************************      \r"
          SVAR/Z SpecComment
          if (SVAR_Exists(specComment))
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="sample:  \t\t"+ specComment + "\r"
          endif

          SVAR/Z FolderName
          if (SVAR_Exists(FolderName))
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="User sample name:  \t\t"+ FolderName + "\r"
          endif

		Notebook $nbkName selection={endOfFile, endOfFile}, text="Data location in Igor:  \t"+ GetDataFolder(1) + "\r\r"

       SVAR/Z SpecSourceFileName
         if (SVAR_exists(SpecSourceFileName))
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="Spec source file:  "+ SpecSourceFileName+"\r"
         endif
	NVAR/Z BeamCenter
         if (NVAR_exists(BeamCenter))
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="\t Beam Center:  \t\t"+ num2str(BeamCenter)+"\r"
         endif                                    
	NVAR/Z MaximumIntensity
          if (NVAR_exists(MaximumIntensity))
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="\t Intensity in maximum:  \t"+ num2str(MaximumIntensity)+"\r"
          endif       
	NVAR/Z PeakWidth
         if (NVAR_exists(PeakWidth))
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="\t Peak Width:  \t\t"+ num2str(PeakWidth*3600)+"\r"
          endif
       SVAR/Z UPDParameters
         if (SVAR_exists(UPDParameters))
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="UPD parameters:  \r"+ UPDParameters+"\r"
         endif
       SVAR/Z MeasurementParameters
         if (SVAR_exists(MeasurementParameters))
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="\r Measurement parameters: \r"
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="Energy:  \t"+ stringByKey("DCM_energy", MeasurementParameters,"=")+"\r"
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="Wavelength:  \t"+ stringByKey("Wavelength", MeasurementParameters,"=")+"\r"
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="SlitLength:  \t"+ stringByKey("SlitLength", MeasurementParameters,"=")+"\r"
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="SD Distance:  \t"+ stringByKey("SDDistance", MeasurementParameters,"=")+"\r"
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="Steps in Q: \t"+ stringByKey("NumberOfSteps", MeasurementParameters,"=")+"\r"
         endif


         SVAR/Z ListOfASBParameters
         if (SVAR_exists(ListOfASBParameters))
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="\r Calibration : \r"
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="Calibration method:  \t"+ stringByKey("Calibrate", ListOfASBParameters,"=")+"\r"
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="Blank used:  \t\t"+ stringByKey("Blank", ListOfASBParameters,"=")+"\r"
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="Omega Factor:  \t\t"+ stringByKey("OmegaFactor", ListOfASBParameters,"=")+"\r"
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="K factor:  \t\t"+ stringByKey("Kfactor", ListOfASBParameters,"=")+"\r"
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="Blank width:  \t\t"+ stringByKey("BlankWidthUsed", ListOfASBParameters,"=")+"\r"
          	Notebook $nbkName selection={endOfFile, endOfFile}, text="Sample thickness:  \t"+ stringByKey("SaThickness", ListOfASBParameters,"=")+"\r"
         endif
//          if (exists("Transmission")==2)
//          	Notebook $nbkName selection={endOfFile, endOfFile}, text="\t  \tTransmission:  "+ num2str(Transmission)+"\r"
//          endif   
//          if (exists("timeWritten")==2)
//          	Notebook $nbkName selection={endOfFile, endOfFile}, text="\tWritten on:  "+ timeWritten+"\r"
//          endif
end

//**********************************************************************************************

Function IN2N_CopyGraphInNotebook(color)
	variable color
	Silent 1
	string bucket11=WinName(0, 1)
	SVAR nbl=root:Packages:Indra3:NotebookName
	Notebook $nbl selection={endOfFile, endOfFile}
	Notebook $nbl scaling={50,50}, frame=1, picture={$bucket11,1,color}
	Notebook $nbl text="\r"
	Notebook $nbl text=IN2G_WindowTitle(bucket11)
	Notebook $nbl text="\r"
End

//**********************************************************************************************

Function IN2N_InsertDateAndTime()
	Silent 1
	string bucket11
	Variable/D now=datetime
	bucket11=Secs2Date(now,0)+",  "+Secs2Time(now,0) +"\r"
	SVAR nbl=root:Packages:Indra3:NotebookName
	Notebook $nbl selection={endOfFile, endOfFile}
	Notebook $nbl text=bucket11
end

//**********************************************************************************************

Function IN2N_LogBookControlPanel()
//Let's create panel to control changes in dark currents etc.
	Silent 1
	if (strlen(WinList("LogBookControl",";","WIN:64"))>0)
			DoWindow/K LogBookControl
	endif
	String PanelTitle= " LogBookControl "
	NewPanel /K=1 /W=(480.75,389,663,589.25) as " LogBookControl "
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,12800,52224)
	DrawText 16,24,"This is control of the"
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,12800,52224)
	DrawText 23,45,"Logging notebook"
	DrawText 9,72,"Use buttons to insert graphs"
	Button CopyGaphInNotebookPanelBW,pos={23,83},size={120,25},proc=IN2N_CopyGraphInNotebookPanelBW,title="Insert Graph BW"
	Button CopyGaphInNotebookPanelCLR,pos={23,119},size={120,25},proc=IN2N_CopyGraphInNbkPanelCLR,title="Insert Graph color"
	Button InsertDateAndTimePanel,pos={23,155},size={120,25},proc=IN2N_InsertDateAndTimePanel,title="Insert Date and time"
End

Function IN2N_CopyGraphInNotebookPanelBW(ctrlname) : Buttoncontrol			// calls the repeat function fit
	string ctrlname
	IN2N_CopyGraphInNotebook(0)
End
Function IN2N_CopyGraphInNbkPanelCLR(ctrlname) : Buttoncontrol			// calls the repeat function fit
	string ctrlname
	IN2N_CopyGraphInNotebook(1)
End
Function IN2N_InsertDateAndTimePanel(ctrlname) : Buttoncontrol			// calls the repeat function fit
	string ctrlname
	IN2N_InsertDateAndTime()
End