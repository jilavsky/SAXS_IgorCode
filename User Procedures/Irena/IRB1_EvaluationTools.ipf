#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.0
#pragma IgorVersion = 8.03


//*************************************************************************\
//* Copyright (c) 2005 - 2021, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/
//functions for bioSAXS community
//
//version summary 
//1.0	September2020 release
//0.5 Jully 2020 version, first working version.  
//0.1  early version, June 2020

constant IRB1_ConcSeriesversion = 0.5

//Contains these main parts:
//		Concentration series extrapolation.



//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//					Concentration series extrapolation
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IRB1_ConcSeriesExtrapolation()
	IN2G_CheckScreenSize("width",1200)
	DoWIndow IRB1_ConcSeriesPanel
	if(V_Flag)
		DoWindow/F IRB1_ConcSeriesPanel
	else
		IRB1_ConcSerInitialize()
		IRB1_ConcSerPanelFnct()
		IR3C_MultiUpdListOfAvailFiles("Irena:ConcSerExtrap")
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("IRB1_ConcSeriesPanel", IRB1_ConcSeriesversion,1)
	endif
end
//************************************************************************************************************
//************************************************************************************************************




//************************************************************************************************************
//************************************************************************************************************
Function IRB1_ConcSerPanelFnct()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(2.25,43.25,1195,800) as "Concentration series"
	DoWIndow/C IRB1_ConcSeriesPanel
	TitleBox MainTitle title="Concentration series",pos={140,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:ConcSerExtrap","IRB1_ConcSeriesPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	IR3C_MultiAppendControls("Irena:ConcSerExtrap","IRB1_ConcSeriesPanel", "IRB1_ConcSeriesAppendOneDataSet","",1,0)
	TitleBox Dataselection pos={10,25}
	ListBox DataFolderSelection pos={4,135},size={250,540}, proc=IRB1_ConcSeriesListBoxProc
	CheckBox UseIndra2Data disable=3
	CheckBox UseResults disable=3
	CheckBox UseQRSData disable=1
	NVAR UseQRSData = root:Packages:Irena:ConcSerExtrap:UseQRSData
	NVAR UseResults = root:Packages:Irena:ConcSerExtrap:UseResults
	NVAR UseIndra2Data = root:Packages:Irena:ConcSerExtrap:UseIndra2Data
	UseResults = 0
	UseIndra2Data = 0
	UseQRSData = 1
	Button GetHelp,pos={430,20},size={80,15},fColor=(65535,32768,32768), proc=IRB1_ConcSeriesButtonProc,title="Get Help", help={"Open www manual page for this tool"}


	SetVariable DataQEnd,pos={350,50},size={190,15}, title="Q max for fitting    " , proc=IRB1_ConcSerSetVarProc
	Setvariable DataQEnd, variable=root:Packages:Irena:ConcSerExtrap:DataQEnd, limits={0,2,0}, help={"Q value for high-q end of data for processing"}
	SetVariable DataQstart,pos={350,75},size={190,15},title="Q min for fitting     ", proc=IRB1_ConcSerSetVarProc
	Setvariable DataQstart, variable=root:Packages:Irena:ConcSerExtrap:DataQstart, limits={0,2,0}, help={"Q value for low-q end of data for processing"}
	
//	NumberOfConcentrations
	PopupMenu NumberOfConcentrations, pos={350,100},size={100,14},title="Num of Conc?  ", proc=IRB1_ConcSerPopMenuProc,value="3;4;5;", help={"number of concentrations in series (3-5)"}

	Checkbox UseSameBufferForAll, pos={290,135},size={76,14},title="Same buffer for all?", proc=IRB1_ConcSeriesCheckProc, variable=root:Packages:Irena:ConcSerExtrap:UseSameBufferForAll, help={"Same buffer = only one for all data"}
	Checkbox UseProtein, pos={455,127},size={76,14},title="Protein?", proc=IRB1_ConcSeriesCheckProc, variable=root:Packages:Irena:ConcSerExtrap:UseProtein, help={"Using Protein? Calclautes buffer scaling"}
	Checkbox UseNucleicAcid, pos={455,144},size={76,14},title="Nucl. Acid?", proc=IRB1_ConcSeriesCheckProc, variable=root:Packages:Irena:ConcSerExtrap:UseNucleicAcid, help={"Using nucelic acid? Calculates buffer scaling. "}

	SetVariable Sample1Name,pos={265,170},size={280,15}, noproc,title="Sam1", noedit=1, frame=1
	Setvariable Sample1Name, variable=root:Packages:Irena:ConcSerExtrap:Sample1Name, help={"Name of sample 1"}
	SetVariable Buffer1Name,pos={265,195},size={280,15}, noproc,title="Buf 1", noedit=1, frame=1
	Setvariable Buffer1Name, variable=root:Packages:Irena:ConcSerExtrap:Buffer1Name, help={"Name of buffer 1"}
	SetVariable InputSample1Conc,pos={255,220},size={150,15}, proc=IRB1_ConcSerSetVarProc ,title="Sam1 Conc Inp = ", frame=1, bodywidth=50, help={"Estimated Sample 1 concentration"}
	Setvariable InputSample1Conc, variable=root:Packages:Irena:ConcSerExtrap:InputSample1Conc, limits={0,100,0}, format="%4.2f"
	SetVariable Sample1Conc,pos={440,220},size={105,15}, noproc,title="fit: ", frame=0, bodywidth=55, format="%6.5f", help={"Copied or fitted sample 1 concetration. Result"}
	Setvariable Sample1Conc, variable=root:Packages:Irena:ConcSerExtrap:Sample1Conc, limits={0,100,0}, noedit=1, help={"Estimated Buffer 1 scaling"}
	SetVariable InputBuffer1Scale,pos={255,240},size={150,15}, noproc,title="Buf 1 Conc Inp = ", frame=1, bodywidth=50
	Setvariable InputBuffer1Scale, variable=root:Packages:Irena:ConcSerExtrap:InputBuffer1Scale, limits={0,2,0}, format="%4.3f", help={"Optimized buffer 1 scaling"}
	SetVariable Buffer1Scale,pos={450,240},size={95,15}, noproc,title="fit: ", frame=0, bodywidth=55, format="%6.5f"
	Setvariable Buffer1Scale, variable=root:Packages:Irena:ConcSerExtrap:Buffer1Scale, limits={0,2,0}, noedit=1
	Checkbox FitSample1Conc, pos={420,220},size={76,14},title="Fit?", proc=IRB1_ConcSeriesCheckProc, variable=root:Packages:Irena:ConcSerExtrap:FitSample1Conc
	Checkbox FitBuffer1Scale, pos={420,240},size={76,14},title="Fit?", proc=IRB1_ConcSeriesCheckProc, variable=root:Packages:Irena:ConcSerExtrap:FitBuffer1Scale

	SetVariable Sample2Name,pos={265,270},size={280,15}, noproc,title="Sam2", noedit=1, frame=1, help={"Name of sample 2"}
	Setvariable Sample2Name, variable=root:Packages:Irena:ConcSerExtrap:Sample2Name
	SetVariable Buffer2Name,pos={265,295},size={280,15}, noproc,title="Buf 2", noedit=1, frame=1, help={"Name of buffer 2"}
	Setvariable Buffer2Name, variable=root:Packages:Irena:ConcSerExtrap:Buffer2Name
	SetVariable InputSample2Conc,pos={255,320},size={150,15}, proc=IRB1_ConcSerSetVarProc,title="Sam2 Conc Inp = ", frame=1, bodywidth=50
	Setvariable InputSample2Conc, variable=root:Packages:Irena:ConcSerExtrap:InputSample2Conc, limits={0,100,0}, format="%4.2f", help={"Estimated concentration fo sample 2"}
	SetVariable Sample2Conc,pos={450,320},size={95,15}, noproc,title="fit: ", frame=0, bodywidth=55, format="%6.5f", help={"Optimized concentration of sample 2."}
	Setvariable Sample2Conc, variable=root:Packages:Irena:ConcSerExtrap:Sample2Conc, limits={0,100,0}, noedit=1
	SetVariable InputBuffer2Scale,pos={255,340},size={150,15}, noproc,title="Buf 2 Conc Inp = ", frame=1, bodywidth=50, help={"Estimated buffer 2 scaling."}
	Setvariable InputBuffer2Scale, variable=root:Packages:Irena:ConcSerExtrap:InputBuffer2Scale, limits={0,1000,0}, format="%4.3f"
	SetVariable Buffer2Scale,pos={450,340},size={95,15}, noproc,title="fit: ", frame=0, bodywidth=55, format="%6.5f", help={"Optimized buffer 2 scaling. "}
	Setvariable Buffer2Scale, variable=root:Packages:Irena:ConcSerExtrap:Buffer2Scale, limits={0,1000,0}, noedit=1
	Checkbox FitSample2Conc, pos={420,320},size={76,14},title="Fit?", proc=IRB1_ConcSeriesCheckProc, variable=root:Packages:Irena:ConcSerExtrap:FitSample2Conc
	Checkbox FitBuffer2Scale, pos={420,340},size={76,14},title="Fit?", proc=IRB1_ConcSeriesCheckProc, variable=root:Packages:Irena:ConcSerExtrap:FitBuffer2Scale


	SetVariable Sample3Name,pos={265,370},size={280,15}, noproc,title="Sam3", noedit=1, frame=1, help={"Name of Sample 3"}
	Setvariable Sample3Name, variable=root:Packages:Irena:ConcSerExtrap:Sample3Name
	SetVariable Buffer3Name,pos={265,395},size={280,15}, noproc,title="Buf 3", noedit=1, frame=1, help={"Name of buffer 3."}
	Setvariable Buffer3Name, variable=root:Packages:Irena:ConcSerExtrap:Buffer3Name
	SetVariable InputSample3Conc,pos={255,420},size={150,15}, proc=IRB1_ConcSerSetVarProc,title="Sam3 Conc Inp = ", frame=1, bodywidth=50
	Setvariable InputSample3Conc, variable=root:Packages:Irena:ConcSerExtrap:InputSample3Conc, limits={0,100,0}, format="%4.2f", help={"Estimated sample 3 concentration. "}
	SetVariable Sample3Conc,pos={450,420},size={95,15}, noproc,title="fit: ", frame=0, bodywidth=55, format="%6.5f"
	Setvariable Sample3Conc, variable=root:Packages:Irena:ConcSerExtrap:Sample3Conc, limits={0,100,0}, noedit=1, help={"Optimized sample 3 concentration. "}
	SetVariable InputBuffer3Scale,pos={255,440},size={150,15}, noproc,title="Buf 3 Conc Inp = ", frame=1, bodywidth=50
	Setvariable InputBuffer3Scale, variable=root:Packages:Irena:ConcSerExtrap:InputBuffer3Scale, limits={0,2,0}, format="%4.3f", help={"Estimated buffer 3 scaling"}
	SetVariable Buffer3Scale,pos={450,440},size={95,15}, noproc,title="fit: ", frame=0, bodywidth=55, format="%6.5f"
	Setvariable Buffer3Scale, variable=root:Packages:Irena:ConcSerExtrap:Buffer3Scale, limits={0,2,0}, noedit=1, help={"Optimized buffer 3 scaling. "}
	Checkbox FitSample3Conc, pos={420,420},size={76,14},title="Fit?", proc=IRB1_ConcSeriesCheckProc, variable=root:Packages:Irena:ConcSerExtrap:FitSample3Conc
	Checkbox FitBuffer3Scale, pos={420,440},size={76,14},title="Fit?", proc=IRB1_ConcSeriesCheckProc, variable=root:Packages:Irena:ConcSerExtrap:FitBuffer3Scale


	SetVariable Sample4Name,pos={265,470},size={280,15}, noproc,title="Sam4", noedit=1, frame=1, help={"Name of Sample 4"}
	Setvariable Sample4Name, variable=root:Packages:Irena:ConcSerExtrap:Sample4Name
	SetVariable Buffer4Name,pos={265,495},size={280,15}, noproc,title="Buf 4", noedit=1, frame=1, help={"Name of buffer 4"}
	Setvariable Buffer4Name, variable=root:Packages:Irena:ConcSerExtrap:Buffer4Name
	SetVariable InputSample4Conc,pos={255,520},size={150,15}, proc=IRB1_ConcSerSetVarProc,title="Sam4 Conc Inp = ", frame=1, bodywidth=50
	Setvariable InputSample4Conc, variable=root:Packages:Irena:ConcSerExtrap:InputSample4Conc, limits={0,100,0}, format="%4.2f", help={"Estimated sample 4 concentration. "}
	SetVariable Sample4Conc,pos={450,520},size={95,15}, noproc,title="fit: ", frame=0, bodywidth=55, format="%6.5f"
	Setvariable Sample4Conc, variable=root:Packages:Irena:ConcSerExtrap:Sample4Conc, limits={0,100,0}, noedit=1
	SetVariable InputBuffer4Scale,pos={255,540},size={150,15}, noproc,title="Buf 4 Conc Inp = ", frame=1, bodywidth=50, help={"Estimated buffer 4 scaling"}
	Setvariable InputBuffer4Scale, variable=root:Packages:Irena:ConcSerExtrap:InputBuffer4Scale, limits={0,2,0}, format="%4.3f"
	SetVariable Buffer4Scale,pos={450,540},size={95,15}, noproc,title="fit: ", frame=0, bodywidth=55, format="%6.5f"
	Setvariable Buffer4Scale, variable=root:Packages:Irena:ConcSerExtrap:Buffer4Scale, limits={0,2,0}, noedit=1, help={"Optimized buffer 4 scaling. "}
	Checkbox FitSample4Conc, pos={420,520},size={76,14},title="Fit?", proc=IRB1_ConcSeriesCheckProc, variable=root:Packages:Irena:ConcSerExtrap:FitSample4Conc
	Checkbox FitBuffer4Scale, pos={420,540},size={76,14},title="Fit?", proc=IRB1_ConcSeriesCheckProc, variable=root:Packages:Irena:ConcSerExtrap:FitBuffer4Scale


	SetVariable Sample5Name,pos={265,570},size={280,15}, noproc,title="Sam5", noedit=1, frame=1, help={"Name of Sample 5"}
	Setvariable Sample5Name, variable=root:Packages:Irena:ConcSerExtrap:Sample5Name
	SetVariable Buffer5Name,pos={265,595},size={280,15}, noproc,title="Buf 5", noedit=1, frame=1, help={"Name of buffer 5"}
	Setvariable Buffer5Name, variable=root:Packages:Irena:ConcSerExtrap:Buffer5Name
	SetVariable InputSample5Conc,pos={255,620},size={150,15}, proc=IRB1_ConcSerSetVarProc,title="Sam5 Conc Inp = ", frame=1, bodywidth=50
	Setvariable InputSample5Conc, variable=root:Packages:Irena:ConcSerExtrap:InputSample5Conc, limits={0,100,0}, format="%4.2f", help={"Estimated sample 5 concentration. "}
	SetVariable Sample5Conc,pos={450,620},size={95,15}, noproc,title="fit: ", frame=0, bodywidth=55, format="%6.5f"
	Setvariable Sample5Conc, variable=root:Packages:Irena:ConcSerExtrap:Sample5Conc, limits={0,100,0}, noedit=1, help={"Optimized sample 5 concentration. "}
	SetVariable InputBuffer5Scale,pos={255,640},size={150,15}, noproc,title="Buf 5 Conc Inp = ", frame=1, bodywidth=50
	Setvariable InputBuffer5Scale, variable=root:Packages:Irena:ConcSerExtrap:InputBuffer5Scale, limits={0,2,0}, format="%4.3f", help={"Estimated buffer 5 scaling"}
	SetVariable Buffer5Scale,pos={450,640},size={95,15}, noproc,title="fit: ", frame=0, bodywidth=55, format="%6.5f"
	Setvariable Buffer5Scale, variable=root:Packages:Irena:ConcSerExtrap:Buffer5Scale, limits={0,2,0}, noedit=1, help={"Optimized buffer 5 scaling. "}
	Checkbox FitSample5Conc, pos={420,620},size={76,14},title="Fit?", proc=IRB1_ConcSeriesCheckProc, variable=root:Packages:Irena:ConcSerExtrap:FitSample5Conc
	Checkbox FitBuffer5Scale, pos={420,640},size={76,14},title="Fit?", proc=IRB1_ConcSeriesCheckProc, variable=root:Packages:Irena:ConcSerExtrap:FitBuffer5Scale


	Button PlotData,pos={560,670},size={190,20}, proc=IRB1_ConcSerButtonProc,title="Plot Data", help={"Plot input data"}
	Button CalculateInputData,pos={760,670},size={190,20}, proc=IRB1_ConcSerButtonProc,title="Subtract & Plot", help={"Calculate Data based on input values"}
	Button OptimizeValues,pos={960,670},size={200,20}, proc=IRB1_ConcSerButtonProc,title="Optimize, Subtract, & Extrapolate", help={"Calculate Data based on input values"}

	SetVariable OptimizedPenalty,pos={990,700},size={150,15}, noproc,title="Fitting error =", frame=0, noedit=1, bodywidth=50
	Setvariable OptimizedPenalty, variable=root:Packages:Irena:ConcSerExtrap:OptimizedPenalty, limits={0,100,0}, format="%4.2f", help={"Achieved fitting error "}
	SetVariable RollOverQValue,pos={990,730},size={150,15}, proc=IRB1_ConcSerSetVarProc,title="Roll Over Q [1/A] = ", frame=1, bodywidth=50
	Setvariable RollOverQValue, variable=root:Packages:Irena:ConcSerExtrap:RollOverQValue, limits={0.01,2,0}, format="%4.2f", help={"Q value at which highest conc is used for extrapolated data. "}


	SetVariable CalculatedOutputFldrName,pos={560,700},size={400,15}, noproc,title="Output Sample Name", frame=1, help={"Name for output data"}
	Setvariable CalculatedOutputFldrName, variable=root:Packages:Irena:ConcSerExtrap:CalculatedOutputFldrName
	Button NotebookOutput,pos={560,730},size={190,20}, proc=IRB1_ConcSerButtonProc,title="Record to Notebook", help={"Create record of results in notebook"}
	Button SaveDataButton,pos={760,730},size={190,20}, proc=IRB1_ConcSerButtonProc,title="Save Data", help={"Save extrapolated data"}

//
//	///*** end of tabs... 
	Display /W=(560,10,1180,650) /HOST=# /N=LogLogDataDisplay
	SetActiveSubwindow ##
	TitleBox Instructions1 title="\Zr100Right click to add data",size={330,15},pos={4,680},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions2 title="\Zr100Select material, buffer(s), set concentrations",size={330,15},pos={4,695},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions3 title="\Zr100Plot data -> SUbtract & plot -> select Q range",size={330,15},pos={4,710},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions4 title="\Zr100Optimize & Extrapolate, try few times, check Fit error",size={330,15},pos={4,725},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions5 title="\Zr100Change Output name if needed, Save",size={330,15},pos={4,740},frame=0,fColor=(0,0,65535),labelBack=0
//	TitleBox Instructions6 title="\Zr100Optimize & Extrapolate, Save",size={330,15},pos={4,755},frame=0,fColor=(0,0,65535),labelBack=0

	IRB1_ConcSerFixPanelControls()
end


//************************************************************************************************************
//************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//************************************************************************************************************
Function IRB1_ConcSeriesListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	Variable row = lba.row
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	string WinNameStr=lba.win
	string FoldernameStr
	Variable isData1or2
	string DoubleClickFunctionName
	string ControlMouseDownFunctionName
	string items
	string TopPanel=WinName(0, 64)
	SVAR ControlProcsLocations=root:Packages:IrenaControlProcs:ControlProcsLocations
	string CntrlLocation=StringByKey(WinNameStr, ControlProcsLocations,":",";")
	SVAR DataMatchString = $("root:Packages:Irena:ConcSerExtrap:DataMatchString")
	NVAR InvertGrepSearch = $("root:Packages:Irena:ConcSerExtrap:InvertGrepSearch")
	variable oldSets

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
  
			if (lba.eventMod & 0x10)	// rightclick
				items = "Assign Sample1;Assign Sample2;Assign Sample3;Assign Sample4;Assign Sample5;"
				items += "Assign Buffer1;Assign Buffer2;Assign Buffer3;Assign Buffer4;Assign Buffer5;"
				items += "Refresh Content;Match \"avg\";Remove Match;"	
				PopupContextualMenu items
				// V_flag is index of user selected item    
				SVAR DataStartFolder = root:Packages:Irena:ConcSerExtrap:DataStartFolder
				NVAR UseSameBufferForAll = root:Packages:Irena:ConcSerExtrap:UseSameBufferForAll
				NVAR NumberOfConcentrations = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
				switch (V_flag)
					case 1:	// "Assign Sample 1"
						SVAR SaName=root:Packages:Irena:ConcSerExtrap:Sample1Name
						SVAR SaNameFull=root:Packages:Irena:ConcSerExtrap:Sample1NameFull
						SaName = stringFromList(ItemsInList(listWave[row],":")-1, listWave[row],":")
						SaNameFull = DataStartFolder+listWave[row]
						break;
					case 2:	// "Assign Sample 2"
						SVAR SaName=root:Packages:Irena:ConcSerExtrap:Sample2Name
						SVAR SaNameFull=root:Packages:Irena:ConcSerExtrap:Sample2NameFull
						SaName = stringFromList(ItemsInList(listWave[row],":")-1, listWave[row],":")
						SaNameFull = DataStartFolder+listWave[row]
						break;
					case 3:	// "Assign Sample 3"
						SVAR SaName=root:Packages:Irena:ConcSerExtrap:Sample3Name
						SVAR SaNameFull=root:Packages:Irena:ConcSerExtrap:Sample3NameFull
						SaName = stringFromList(ItemsInList(listWave[row],":")-1, listWave[row],":")
						SaNameFull = DataStartFolder+listWave[row]
						break;
					case 4:	// "Assign Sample 4"
						SVAR SaName=root:Packages:Irena:ConcSerExtrap:Sample4Name
						SVAR SaNameFull=root:Packages:Irena:ConcSerExtrap:Sample4NameFull
						SaName = stringFromList(ItemsInList(listWave[row],":")-1, listWave[row],":")
						SaNameFull = DataStartFolder+listWave[row]
						if(NumberOfConcentrations<4)
							NumberOfConcentrations = 4
							IRB1_ConcSerFixPanelControls()
						endif
						break;
					case 5:	// "Assign Sample 5"
						SVAR SaName=root:Packages:Irena:ConcSerExtrap:Sample5Name
						SVAR SaNameFull=root:Packages:Irena:ConcSerExtrap:Sample5NameFull
						SaName = stringFromList(ItemsInList(listWave[row],":")-1, listWave[row],":")
						SaNameFull = DataStartFolder+listWave[row]
						if(NumberOfConcentrations<5)
							NumberOfConcentrations = 5
							IRB1_ConcSerFixPanelControls()
						endif
						break;
					case 6:	// "Assign Buffer 1"
						SVAR SaName=root:Packages:Irena:ConcSerExtrap:Buffer1Name
						SVAR SaNameFull=root:Packages:Irena:ConcSerExtrap:Buffer1NameFull
						SaName = stringFromList(ItemsInList(listWave[row],":")-1, listWave[row],":")
						SaNameFull = DataStartFolder+listWave[row]
						break;
					case 7:	// "Assign Buffer 2"
						SVAR SaName=root:Packages:Irena:ConcSerExtrap:Buffer2Name
						SVAR SaNameFull=root:Packages:Irena:ConcSerExtrap:Buffer2NameFull
						SaName = stringFromList(ItemsInList(listWave[row],":")-1, listWave[row],":")
						SaNameFull = DataStartFolder+listWave[row]
						UseSameBufferForAll = 0
						IRB1_ConcSerFixPanelControls()
						break;
					case 8:	// "Assign Buffer 3"
						SVAR SaName=root:Packages:Irena:ConcSerExtrap:Buffer3Name
						SVAR SaNameFull=root:Packages:Irena:ConcSerExtrap:Buffer3NameFull
						SaName = stringFromList(ItemsInList(listWave[row],":")-1, listWave[row],":")
						SaNameFull = DataStartFolder+listWave[row]
						UseSameBufferForAll = 0
						IRB1_ConcSerFixPanelControls()
						break;
					case 9:	// "Assign Buffer 4"
						SVAR SaName=root:Packages:Irena:ConcSerExtrap:Buffer4Name
						SVAR SaNameFull=root:Packages:Irena:ConcSerExtrap:Buffer4NameFull
						SaName = stringFromList(ItemsInList(listWave[row],":")-1, listWave[row],":")
						SaNameFull = DataStartFolder+listWave[row]
						UseSameBufferForAll = 0
						IRB1_ConcSerFixPanelControls()
						break;
					case 10:	// "Assign Buffer 5"
						SVAR SaName=root:Packages:Irena:ConcSerExtrap:Buffer5Name
						SVAR SaNameFull=root:Packages:Irena:ConcSerExtrap:Buffer5NameFull
						SaName = stringFromList(ItemsInList(listWave[row],":")-1, listWave[row],":")
						SaNameFull = DataStartFolder+listWave[row]
						UseSameBufferForAll = 0
						IRB1_ConcSerFixPanelControls()
						break;
//					case 2:	//Match avg
//						DataMatchString="avg"
//						InvertGrepSearch = 0
//						ControlInfo/W=$(TopPanel) ListOfAvailableData
//						 oldSets=V_startRow
//						IR3C_MultiUpdListOfAvailFiles(CntrlLocation)
//						ListBox DataFolderSelection,win=$(TopPanel),row=V_startRow
//						break;
//					case 4:	//Match sub
//						DataMatchString="sub"
//						InvertGrepSearch = 0
//						ControlInfo/W=$(TopPanel) ListOfAvailableData
//						 oldSets=V_startRow
//						IR3C_MultiUpdListOfAvailFiles(CntrlLocation)
//						ListBox DataFolderSelection,win=$(TopPanel),row=V_startRow
//						break;
//					case 5:	//Match sub
//						DataMatchString="sub|avg|ave"
//						InvertGrepSearch = 1
//						ControlInfo/W=$(TopPanel) ListOfAvailableData
//						 oldSets=V_startRow
//						IR3C_MultiUpdListOfAvailFiles(CntrlLocation)
//						ListBox DataFolderSelection,win=$(TopPanel),row=V_startRow
//						break;
//					case 6:	//remove Match
//						DataMatchString=""
//						InvertGrepSearch = 0
//						ControlInfo/W=$(TopPanel) ListOfAvailableData
//						 oldSets=V_startRow
//						IR3C_MultiUpdListOfAvailFiles(CntrlLocation)
//						ListBox DataFolderSelection,win=$(TopPanel),row=V_startRow
//						break;

					default :	// "Sort"
						//DataSelSortString = StringFromList(V_flag-1, items)
						//PopupMenu SortOptionString,win=$(TopPanel), mode=1,popvalue=DataSelSortString
						//IR3C_SortListOfFilesInWvs(TopPanel)	
						break;
					endswitch
				
			else
				SVAR ControlMouseDownFunction = root:Packages:IrenaControlProcs:ControlMouseDownFunction
				ControlMouseDownFunctionName=StringByKey(WinNameStr, ControlMouseDownFunction,":",";" )
				if(numpnts(listWave)<(row+1))
					return 0
				endif		
				FoldernameStr=listWave[row]
				if(strlen(ControlMouseDownFunctionName)>0)
					Execute(ControlMouseDownFunctionName+"(\""+FoldernameStr+"\")")
				endif
			endif
			break
		case 3: // double click
			SVAR ControlDoubleClickFunction = root:Packages:IrenaControlProcs:ControlDoubleClickFunction
			DoubleClickFunctionName=StringByKey(WinNameStr, ControlDoubleClickFunction,":",";" )
			FoldernameStr=listWave[row]
			if(strlen(DoubleClickFunctionName)>0)
				Execute(DoubleClickFunctionName+"(\""+FoldernameStr+"\")")
			endif
			break
		case 4: // cell selection
		case 5: // cell selection plus shift key
			break
		case 6: // begin edit
			break
		case 7: // finish edit
			break
		case 13: // checkbox clicked (Igor 6.2 or later)
			break
	endswitch

	return 0
End
//************************************************************************************************************
//************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************



Function IRB1_ConcSeriesButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
//			if(stringMatch(ba.ctrlName,"ScaleRangeOfData"))
//				IRB1_DataManScaleMany()
//			endif
			if(stringmatch(ba.ctrlName,"GetHelp"))
				IN2G_OpenWebManual("Irena/bioSAXS.html#concentration-series")				//fix me!!			
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IRB1_ConcSerPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(stringMatch(pa.ctrlName,"NumberOfConcentrations"))
				NVAR NumberOfConcentrations=root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
				NumberOfConcentrations = str2num(popStr)
				IRB1_ConcSerFixPanelControls()
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************

Function IRB1_ConcSerFixPanelControls()
	DoWIndow IRB1_ConcSeriesPanel
	if(V_Flag)
		DoWIndow/F IRB1_ConcSeriesPanel
		
		NVAR UseSameBufferForAll = root:Packages:Irena:ConcSerExtrap:UseSameBufferForAll
		NVAR NumberOfConcentrations = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations

		PopupMenu NumberOfConcentrations, mode=(NumberOfConcentrations-2)
		Setvariable Buffer2Name, disable=(UseSameBufferForAll)	

		Setvariable Buffer3Name, disable=(UseSameBufferForAll)	
		
		Setvariable Sample4Name, disable=(NumberOfConcentrations<4)	
		Setvariable Buffer4Name, disable=(UseSameBufferForAll||NumberOfConcentrations<4)	
		SetVariable InputSample4Conc, disable=(NumberOfConcentrations<4)
		SetVariable Sample4Conc, disable=(NumberOfConcentrations<4)
		SetVariable Buffer4Scale, disable=(NumberOfConcentrations<4)
		SetVariable InputBuffer4Scale, disable=(NumberOfConcentrations<4)
		Checkbox FitSample4Conc, disable=(NumberOfConcentrations<4)
		Checkbox FitBuffer4Scale, disable=(NumberOfConcentrations<4)
		
		

		Setvariable Sample5Name, disable=(NumberOfConcentrations<5)	
		Setvariable Buffer5Name, disable=(UseSameBufferForAll||NumberOfConcentrations<5)	
		SetVariable InputSample5Conc, disable=(NumberOfConcentrations<5)
		SetVariable Sample5Conc, disable=(NumberOfConcentrations<5)
		SetVariable Buffer5Scale, disable=(NumberOfConcentrations<5)
		SetVariable InputBuffer5Scale, disable=(NumberOfConcentrations<5)
		Checkbox FitSample5Conc, disable=(NumberOfConcentrations<5)
		Checkbox FitBuffer5Scale, disable=(NumberOfConcentrations<5)
	endif

end
///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************

Function IRB1_ConcSeriesCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(stringMatch(cba.ctrlName,"UseSameBufferForAll"))
				IRB1_ConcSerFixPanelControls()
			endif
			if(stringMatch(cba.ctrlName,"UseProtein"))
				NVAR UseProtein=root:Packages:Irena:ConcSerExtrap:UseProtein
				NVAR UseNucleicAcid=root:Packages:Irena:ConcSerExtrap:UseNucleicAcid
				if(cba.checked)
					UseNucleicAcid = 0
				endif
			endif
			if(stringMatch(cba.ctrlName,"UseNucleicAcid"))
				NVAR UseProtein=root:Packages:Irena:ConcSerExtrap:UseProtein
				NVAR UseNucleicAcid=root:Packages:Irena:ConcSerExtrap:UseNucleicAcid
				if(cba.checked)
					UseProtein = 0
				endif
			endif
			if(stringMatch(cba.ctrlName,"FitSample*Conc"))
				NVAR Fit1=root:Packages:Irena:ConcSerExtrap:FitSample1Conc
				NVAR Fit2=root:Packages:Irena:ConcSerExtrap:FitSample2Conc
				NVAR Fit3=root:Packages:Irena:ConcSerExtrap:FitSample3Conc
				NVAR Fit4=root:Packages:Irena:ConcSerExtrap:FitSample4Conc
				NVAR Fit5=root:Packages:Irena:ConcSerExtrap:FitSample5Conc
				NVAR Val1=root:Packages:Irena:ConcSerExtrap:InputSample1Conc
				NVAR Val2=root:Packages:Irena:ConcSerExtrap:InputSample2Conc
				NVAR Val3=root:Packages:Irena:ConcSerExtrap:InputSample3Conc
				NVAR Val4=root:Packages:Irena:ConcSerExtrap:InputSample4Conc
				NVAR Val5=root:Packages:Irena:ConcSerExtrap:InputSample5Conc
				NVAR NumberOfConcentrations=root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
				if(checked)
					//here we need to make sure, the max concentration is unchecked as that one will not be optimized. 
					switch(NumberOfConcentrations)	// numeric switch
						case 3:	// execute if case matches expression
							if(Fit1+Fit2+Fit3>2)	//too many concentrations fitted.
								make/Free/N=3 tempWv
								tempWv={Val1,Val2,Val3}
								Wavestats/Q tempWv
								NVAR FitMax=$("root:Packages:Irena:ConcSerExtrap:FitSample"+num2str(V_maxLoc+1)+"Conc")
								print "Too many Fitted concentrations, unchecked Fit concetration for larges valeu"
								FitMax = 0
							endif
							break		// exit from switch
						case 4:	// execute if case matches expression
							if(Fit1+Fit2+Fit3+Fit4>3)	//too many concentrations fitted.
								make/Free/N=4 tempWv
								tempWv={Val1,Val2,Val3,Val4}
								Wavestats/Q tempWv
								NVAR FitMax=$("root:Packages:Irena:ConcSerExtrap:FitSample"+num2str(V_maxLoc+1)+"Conc")
								print "Too many Fitted concentrations, unchecked Fit concetration for larges valeu"
								FitMax = 0
							endif
							break
						case 5:	// execute if case matches expression
							if(Fit1+Fit2+Fit3+Fit4+Fit5>2)	//too many concentrations fitted.
								make/Free/N=5 tempWv
								tempWv={Val1,Val2,Val3,Val4,Val5}
								Wavestats/Q tempWv
								NVAR FitMax=$("root:Packages:Irena:ConcSerExtrap:FitSample"+num2str(V_maxLoc+1)+"Conc")
								print "Too many Fitted concentrations, unchecked Fit concetration for larges valeu"
								FitMax = 0
							endif
							 
							break
						default:			// optional default expression executed
							
							
					endswitch
				endif
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************

Function IRB1_ConcSerButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringMatch(ba.ctrlName,"PlotData"))
				IRB1_ConcSerCopyData()
				IR1B_ConcSerSetOutputName()
				//add the data to plot
				IRB1_ConcSerAddDataToPlot(1)
			endif
			if(stringMatch(ba.ctrlName,"CalculateInputData"))
				IRB1_ConcSerRecalculateData(1,0,1)
				//add the data to plot
				IRB1_ConcSerAddDataToPlot(2)
				NVAR OptimizedPenalty 	= root:Packages:Irena:ConcSerExtrap:OptimizedPenalty
				OptimizedPenalty = 0
			endif
			if(stringMatch(ba.ctrlName,"OptimizeValues"))
				NVAR OptimizedPenalty 	= root:Packages:Irena:ConcSerExtrap:OptimizedPenalty
				OptimizedPenalty = 0
				IRB1_ConcSerOptimizeParams()
				IRB1_ConcSerExtrapolate()
				IRB1_ConcSerAddDataToPlot(3)
			endif
			if(stringMatch(ba.ctrlName,"SaveDataButton"))
				IR1B_ConcSerSaveOutputData()
			endif
			if(stringMatch(ba.ctrlName,"NotebookOutput"))
				IRB1_NotebookRecord()
			endif
			
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
///**************************************************************************************************
///**************************************************************************************************
Function IR1B_ConcSerSetOutputName()
	SVAR CalculatedOutputFldrName = root:Packages:Irena:ConcSerExtrap:CalculatedOutputFldrName
	variable MaxIntIndex=IR1B_ConcSerFindMaxConc()
	SVAR SaName = $("root:Packages:Irena:ConcSerExtrap:Sample"+num2str(MaxIntIndex)+"Name")	//this is pointer to folder, set by IRB1_ConcSerCopyData()
	string TempName=ReplaceString("_avg", SaName, "") 
	CalculatedOutputFldrName = TempName+"_zConc"
end
///**************************************************************************************************
///**************************************************************************************************
Function IR1B_ConcSerSaveOutputData()
	DFref oldDf= GetDataFolderDFR()
	setDataFolder root:Packages:Irena:ConcSerExtrap

	Wave/Z ExtInt = root:Packages:Irena:ConcSerExtrap:ExtrapolatedIntensity
	if(!WaveExists(ExtInt))
		print "No data to save found" 
		abort
	endif
	Wave ExtQ = root:Packages:Irena:ConcSerExtrap:ExtrapolatedQ
	Wave ExtErr = root:Packages:Irena:ConcSerExtrap:ExtrapolatedE


	SVAR CalculatedOutputFldrName = root:Packages:Irena:ConcSerExtrap:CalculatedOutputFldrName
	//CalculatedOutputFldrName = CleanupName(CalculatedOutputFldrName, 1, maxBytes ])
	variable MaxIntIndex=IR1B_ConcSerFindMaxConc()
	SVAR SaNameFull = $("root:Packages:Irena:ConcSerExtrap:Sample"+num2str(MaxIntIndex)+"NameFull")	//this is pointer to folder, set by IRB1_ConcSerCopyData()
	string NewFolderName
	string ParentFolderName = RemoveListItem(ItemsInList(SaNameFull ,":")-1, SaNameFull, ":")
	NewFolderName = ParentFolderName+CalculatedOutputFldrName
	//create the folder
	setDataFolder $(ParentFolderName)
	if(DataFolderExists(CalculatedOutputFldrName))
		DoAlert /T="Data Folder exists" 1, "Data Folder "+CalculatedOutputFldrName+" exists in this location, do you want to overwrite the data there?"
		if(V_Flag!=1)
			setDataFolder oldDf
			abort
		endif
		setDataFOlder $(CalculatedOutputFldrName)
	else
		NewDataFolder/S $(CalculatedOutputFldrName)
	endif
	//copy the data...
	string tempName
	tempName = "q_"+CalculatedOutputFldrName
	Duplicate/O ExtQ, $(tempName)
	wave NewQ=$(tempName)
	tempName = "r_"+CalculatedOutputFldrName
	Duplicate/O ExtInt, $(tempName)
	wave NewInt=$(tempName)
	tempName = "s_"+CalculatedOutputFldrName
	Duplicate/O ExtErr, $(tempName)
	wave NewErr=$(tempName)
	//TODO: add to wavenote what was done... 
	string oldNote, NewNote
	oldNote =note(NewInt)
	NewNote = "Zero Concentration extrapolation done;"  
	NVAR NumberOfConcentrations = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
	variable i
	For(i=1;i<=	NumberOfConcentrations;i+=1)
		SVAR Sample=$("root:Packages:Irena:ConcSerExtrap:Sample"+num2str(i)+"Name")
		NVAR SampleConc = $("root:Packages:Irena:ConcSerExtrap:Sample"+num2str(i)+"Conc")
		NewNote+="Sample"+num2str(i)+"Name="+Sample+";"
		NewNote+="Sample"+num2str(i)+"Concentration="+Num2str(SampleConc)+";"
	endfor
	NVAR UseSameBufferForAll 	= root:Packages:Irena:ConcSerExtrap:UseSameBufferForAll
	if(UseSameBufferForAll)
		SVAR Buffer=$("root:Packages:Irena:ConcSerExtrap:Buffer1Name")
		NVAR BufferScale = $("root:Packages:Irena:ConcSerExtrap:Buffer1Scale")
		NewNote+="BufferName="+Buffer+";"
		NewNote+="BufferScale="+Num2str(BufferScale)+";"
	else
		For(i=1;i<=	NumberOfConcentrations;i+=1)
			SVAR Buffer=$("root:Packages:Irena:ConcSerExtrap:Buffer"+num2str(i)+"Name")
			NVAR BufferScale = $("root:Packages:Irena:ConcSerExtrap:Buffer"+num2str(i)+"Scale")
			NewNote+="Buffer"+num2str(i)+"Name="+Buffer+";"
			NewNote+="Buffer"+num2str(i)+"Scale="+Num2str(BufferScale)+";"
		endfor
	endif
	Note/K  NewInt, oldNote+NewNote 
	Note/K  NewQ, oldNote+NewNote 
	Note/K  NewErr, oldNote+NewNote 
	setDataFolder oldDf
end


///**************************************************************************************************
///**************************************************************************************************

Function IRB1_ConcSerAddDataToPlot(WhichData)
	variable WhichData			//set to 0 to remove data, 1 for original, 2 for processed, 3 extrapolated. 
	DFref oldDf= GetDataFolderDFR()
	setDataFolder root:Packages:Irena:ConcSerExtrap
	DoWIndow IRB1_ConcSeriesPanel
	NVAR NumberOfConcentrations = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
	NVAR UseSameBufferForAll 	= root:Packages:Irena:ConcSerExtrap:UseSameBufferForAll
	variable i
	if(V_Flag)
		if(WhichData==0)			//remove all data
			IN2G_RemoveDataFromGraph(topGraphStr = "IRB1_ConcSeriesPanel#LogLogDataDisplay")	
			setDataFolder oldDf
			return 0
		elseif(WhichData==1)				//original
			//remove all processed data first. 
			For(i=1;i<=5;i+=1)
				RemoveFromGraph /W=IRB1_ConcSeriesPanel#LogLogDataDisplay /Z $("CorrectedIntensity"+num2str(i))
				KillWaves/Z $("CorrectedIntensity"+num2str(i)), $("CorrectedQ"+num2str(i)), $("CorrectedE"+num2str(i))
			endfor
			RemoveFromGraph /W=IRB1_ConcSeriesPanel#LogLogDataDisplay /Z $("ExtrapolatedIntensity")
			KillWaves/Z ExtrapolatedIntensity, ExtrapolatedQ, ExtrapolatedE		
			AppendOrigData()
		elseif(WhichData==2)					//processed
			RemoveFromGraph /W=IRB1_ConcSeriesPanel#LogLogDataDisplay /Z $("ExtrapolatedIntensity")
			AppendOrigData()
			AppendSubtractedData()
		elseif(WhichData==3)					//extrapolated
			AppendOrigData()
			AppendSubtractedData()
			Wave ExtrapolatedIntensity=root:Packages:Irena:ConcSerExtrap:ExtrapolatedIntensity
			Wave ExtrapolatedQ=root:Packages:Irena:ConcSerExtrap:ExtrapolatedQ
			Wave ExtrapolatedE=root:Packages:Irena:ConcSerExtrap:ExtrapolatedE
			Wave FittingRangeMarker=root:Packages:Irena:ConcSerExtrap:FittingRangeMarker
			Wave ExtensionRangeColor=root:Packages:Irena:ConcSerExtrap:ExtensionRangeColor
			CheckDisplayed /W=IRB1_ConcSeriesPanel#LogLogDataDisplay $(NameOfWave(ExtrapolatedIntensity))
			if(V_Flag==0)
				AppendToGraph /W=IRB1_ConcSeriesPanel#LogLogDataDisplay /R ExtrapolatedIntensity vs ExtrapolatedQ
			endif	
			ModifyGraph /W=IRB1_ConcSeriesPanel#LogLogDataDisplay mode(ExtrapolatedIntensity)=4,zmrkNum(ExtrapolatedIntensity)={FittingRangeMarker}
			ModifyGraph /W=IRB1_ConcSeriesPanel#LogLogDataDisplay msize(ExtrapolatedIntensity)=3, zColor(ExtrapolatedIntensity)={ExtensionRangeColor,0,1,PlanetEarth,0}
		endif
		if(WhichData>0)	
			DoUpdate /W=IRB1_ConcSeriesPanel#LogLogDataDisplay
			ModifyGraph /W=IRB1_ConcSeriesPanel#LogLogDataDisplay log=1
			ModifyGraph /W=IRB1_ConcSeriesPanel#LogLogDataDisplay mirror(bottom)=1
			SetAxis /W=IRB1_ConcSeriesPanel#LogLogDataDisplay /A /N=1 left
			SetAxis /W=IRB1_ConcSeriesPanel#LogLogDataDisplay /A /N=1 bottom
			IN2G_MakeGrphLimitsNice(topGraphStr = "IRB1_ConcSeriesPanel#LogLogDataDisplay")
			IN2G_ColorTopGrphRainbow(topGraphStr = "IRB1_ConcSeriesPanel#LogLogDataDisplay")
			IN2G_LegendTopGrphFldr(10, 10, 0, 1, topGraphStr = "IRB1_ConcSeriesPanel#LogLogDataDisplay")	//FontSize, MaxItems, UseFolderName, UseWavename	
			Label /W=IRB1_ConcSeriesPanel#LogLogDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Measured Intensity"
			GetAxis /W=IRB1_ConcSeriesPanel#LogLogDataDisplay /Q right
			if(V_Flag==0)
				Label /W=IRB1_ConcSeriesPanel#LogLogDataDisplay right "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Corrected Intensity"
				SetAxis /W=IRB1_ConcSeriesPanel#LogLogDataDisplay /A/N=2 right
			endif
			Label /W=IRB1_ConcSeriesPanel#LogLogDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q[A\\S-1\\M"+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
			CheckDisplayed /W=IRB1_ConcSeriesPanel#LogLogDataDisplay $(NameOfWave(ExtrapolatedIntensity))
			if(V_Flag)
				ModifyGraph/W=IRB1_ConcSeriesPanel#LogLogDataDisplay lstyle(ExtrapolatedIntensity)=3,lsize(ExtrapolatedIntensity)=3,rgb(ExtrapolatedIntensity)=(0,0,0)
			endif
			//set cursors
			NVAR DataQEnd = root:Packages:Irena:ConcSerExtrap:DataQEnd
			NVAR DataQstart = root:Packages:Irena:ConcSerExtrap:DataQstart
			Wave FirstQ = $("root:Packages:Irena:ConcSerExtrap:OrigSamQ1")
			Wave FirstInt = $("root:Packages:Irena:ConcSerExtrap:OrigSamIntensity1")
			if(DataQEnd>0 && DataQstart>0)	//intialized, something is there... 
				if(DataQEnd<DataQstart)
					variable tmpQ=DataQstart
					DataQstart = DataQEnd
					DataQEnd = tmpQ
				endif
			else	//not initialized, need to set these. 
				DataQEnd = FirstQ[numpnts(FirstQ)-2] 
				DataQstart = FirstQ[2] 
			endif
			if(strlen(csrWave(A,"IRB1_ConcSeriesPanel#LogLogDataDisplay"))<1 || strlen(csrWave(B,"IRB1_ConcSeriesPanel#LogLogDataDisplay"))<1) 
				SetWindow IRB1_ConcSeriesPanel hook(ConcSerCursorMoved) = $""
				cursor /W=IRB1_ConcSeriesPanel#LogLogDataDisplay B, $(nameofwave(FirstInt)), BinarySearch(FirstQ, DataQEnd )
				cursor /W=IRB1_ConcSeriesPanel#LogLogDataDisplay A, $(nameofwave(FirstInt)), BinarySearch(FirstQ, DataQstart )
				SetWindow IRB1_ConcSeriesPanel hook(ConcSerCursorMoved) = IRB1_ConcSerGraphWindowHook
			endif
		endif
	endif
	setDataFolder oldDf
end

//**********************************************************************************************************
//**********************************************************************************************************
static Function AppendOrigData()

	NVAR NumberOfConcentrations = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
	NVAR UseSameBufferForAll 	= root:Packages:Irena:ConcSerExtrap:UseSameBufferForAll
	variable i
	For(i=1;i<(NumberOfConcentrations+1);i+=1)
			Wave/Z OrigInt = $("root:Packages:Irena:ConcSerExtrap:OrigSamIntensity"+num2str(i))
			if(!WaveExists(OrigInt))
				abort "Data do not exist, are data selected correctly?"
			endif
			Wave OrigQ = $("root:Packages:Irena:ConcSerExtrap:OrigSamQ"+num2str(i))
			Wave OrigE = $("root:Packages:Irena:ConcSerExtrap:OrigSamErr"+num2str(i))
			CheckDisplayed /W=IRB1_ConcSeriesPanel#LogLogDataDisplay $(nameofWave(OrigInt))
			if(V_flag==0)
				AppendToGraph /W=IRB1_ConcSeriesPanel#LogLogDataDisplay OrigInt vs OrigQ				
				//ErrorBars /W=IRB1_ConcSeriesPanel#LogLogDataDisplay OrigInt Y,wave=(OrigE,OrigE)		
			endif
	endfor
	variable MaxBuff=1
	if(!UseSameBufferForAll)
		MaxBuff= NumberOfConcentrations
	endif	
	For(i=1;i<(MaxBuff+1);i+=1)
		Wave OrigInt = $("root:Packages:Irena:ConcSerExtrap:OrigBuffIntensity"+num2str(i))
		Wave OrigQ = $("root:Packages:Irena:ConcSerExtrap:OrigBuffQ"+num2str(i))
		Wave OrigE = $("root:Packages:Irena:ConcSerExtrap:OrigBuffErr"+num2str(i))
		CheckDisplayed /W=IRB1_ConcSeriesPanel#LogLogDataDisplay $(nameofWave(OrigInt)) 
		if(V_flag==0)
			AppendToGraph /W=IRB1_ConcSeriesPanel#LogLogDataDisplay OrigInt vs OrigQ				
		endif
	endfor
	
end

//**********************************************************************************************************
//**********************************************************************************************************
static Function AppendSubtractedData()

	NVAR NumberOfConcentrations = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
	NVAR UseSameBufferForAll 	= root:Packages:Irena:ConcSerExtrap:UseSameBufferForAll
	variable i
	For(i=1;i<=NumberOfConcentrations;i+=1)
		Wave CorrectedInt=$("root:Packages:Irena:ConcSerExtrap:CorrectedIntensity"+num2str(i))
		Wave CorrectedQ=$("root:Packages:Irena:ConcSerExtrap:CorrectedQ"+num2str(i))
		CheckDisplayed /W=IRB1_ConcSeriesPanel#LogLogDataDisplay $(NameOfWave(CorrectedInt))
		if(V_Flag==0)
			AppendToGraph /W=IRB1_ConcSeriesPanel#LogLogDataDisplay /R CorrectedInt vs CorrectedQ
		endif
	endfor	

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IRB1_ConcSerGraphWindowHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	switch(s.eventCode) 
		case 0:				// Activate
			// Handle activate
			break

		case 1:				// Deactivate
			// Handle deactivate
			break
		case 7:				//coursor moved
			IRB1_ConcSerCursorsSync(s.traceName,s.cursorName,s.pointNumber)
			hookResult = 1
		// And so on . . .
	endswitch

	return hookResult	// 0 if nothing done, else 1
End

//**********************************************************************************************************
//**********************************************************************************************************

Function IRB1_ConcSerCursorsSync(traceName,CursorName,PointNumber)
	string traceName,CursorName
	variable PointNumber

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR DataQEnd = root:Packages:Irena:ConcSerExtrap:DataQEnd
	NVAR DataQstart = root:Packages:Irena:ConcSerExtrap:DataQstart
	Wave IntWaveA=csrWaveref(A,"IRB1_ConcSeriesPanel#LogLogDataDisplay") 
	Wave IntWaveB=csrWaveref(B,"IRB1_ConcSeriesPanel#LogLogDataDisplay") 
	Wave QWaveA=csrXWaveref(A,"IRB1_ConcSeriesPanel#LogLogDataDisplay") 
	Wave QWaveB=csrXWaveref(B,"IRB1_ConcSeriesPanel#LogLogDataDisplay") 
	DataQstart = QWaveA[pcsr(A , "IRB1_ConcSeriesPanel#LogLogDataDisplay")]
	DataQEnd = QWaveB[pcsr(B , "IRB1_ConcSeriesPanel#LogLogDataDisplay")]
	if(DataQEnd<DataQstart)
		variable tmpQ=DataQstart
		DataQstart = DataQEnd
		DataQEnd = tmpQ
	endif

end
///**************************************************************************************************
///**************************************************************************************************
static Function IRB1_ConcSeriesSyncConcs(resetConcentrations)
	variable resetConcentrations
	//copy input parameters to fitted parameters...
	NVAR NumberOfConcentrations = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
	NVAR Val1=root:Packages:Irena:ConcSerExtrap:InputSample1Conc
	NVAR Val2=root:Packages:Irena:ConcSerExtrap:InputSample2Conc
	NVAR Val3=root:Packages:Irena:ConcSerExtrap:InputSample3Conc
	NVAR Val4=root:Packages:Irena:ConcSerExtrap:InputSample4Conc
	NVAR Val5=root:Packages:Irena:ConcSerExtrap:InputSample5Conc
	NVAR SamC1=root:Packages:Irena:ConcSerExtrap:Sample1Conc
	NVAR SamC2=root:Packages:Irena:ConcSerExtrap:Sample2Conc
	NVAR SamC3=root:Packages:Irena:ConcSerExtrap:Sample3Conc
	NVAR SamC4=root:Packages:Irena:ConcSerExtrap:Sample4Conc
	NVAR SamC5=root:Packages:Irena:ConcSerExtrap:Sample5Conc
	if(resetConcentrations)
		SamC1 = Val1
		SamC2 = Val2
		SamC3 = Val3
		SamC4 = Val4
		SamC5 = Val5
	endif
	if(NumberOfConcentrations<4)
		SamC4 = 0
		Val4 = 0
	endif
	if(NumberOfConcentrations<5)
		SamC5 = 0
		Val5 = 0
	endif
	//now buffers	
	NVAR Val1=root:Packages:Irena:ConcSerExtrap:InputBuffer1Scale
	NVAR Val2=root:Packages:Irena:ConcSerExtrap:InputBuffer2Scale
	NVAR Val3=root:Packages:Irena:ConcSerExtrap:InputBuffer3Scale
	NVAR Val4=root:Packages:Irena:ConcSerExtrap:InputBuffer4Scale
	NVAR Val5=root:Packages:Irena:ConcSerExtrap:InputBuffer5Scale
	NVAR SamC1=root:Packages:Irena:ConcSerExtrap:Buffer1Scale
	NVAR SamC2=root:Packages:Irena:ConcSerExtrap:Buffer2Scale
	NVAR SamC3=root:Packages:Irena:ConcSerExtrap:Buffer3Scale
	NVAR SamC4=root:Packages:Irena:ConcSerExtrap:Buffer4Scale
	NVAR SamC5=root:Packages:Irena:ConcSerExtrap:Buffer5Scale
	if(resetConcentrations)
		SamC1 = Val1
		SamC2 = Val2
		SamC3 = Val3
		SamC4 = Val4
		SamC5 = Val5
	endif
	if(NumberOfConcentrations<4)
		SamC4 = 0
		Val4 = 0
	endif
	if(NumberOfConcentrations<5)
		SamC5 = 0
		Val5 = 0
	endif
	
end

///**************************************************************************************************
///**************************************************************************************************

Function IRB1_ConcSerRecalculateData(resetConcentrations,fittingData, FullRange)
	variable resetConcentrations, fittingData, FullRange
	//this will recalculate original data into background and scale corrected data 
	//FullRange = 1 means full Q range (to Q=0 mainly)
	DFref oldDf= GetDataFolderDFR()
	setDataFolder root:Packages:Irena:ConcSerExtrap
	NVAR NumberOfConcentrations = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
	NVAR UseSameBufferForAll 	= root:Packages:Irena:ConcSerExtrap:UseSameBufferForAll
	NVAR DataQEnd = root:Packages:Irena:ConcSerExtrap:DataQEnd
	NVAR DataQstart = root:Packages:Irena:ConcSerExtrap:DataQstart
	//copy input parameters to fitted parameters...
	if(resetConcentrations)
		IRB1_ConcSeriesSyncConcs(resetConcentrations)
	endif
	NVAR Val1=root:Packages:Irena:ConcSerExtrap:InputSample1Conc
	NVAR Val2=root:Packages:Irena:ConcSerExtrap:InputSample2Conc
	NVAR Val3=root:Packages:Irena:ConcSerExtrap:InputSample3Conc
	NVAR Val4=root:Packages:Irena:ConcSerExtrap:InputSample4Conc
	NVAR Val5=root:Packages:Irena:ConcSerExtrap:InputSample5Conc
	variable MaxConc=max(Val1, Val2, Val3, Val4, Val5 )
	variable i, startPoint, endPoint
	Wave TempQ1=$("root:Packages:Irena:ConcSerExtrap:OrigSamQ"+num2str(1))
	if(FullRange)		//this calculates extended data to full Q range of the data.
		startPoint = 0
		endPoint = numpnts(TempQ1)-1
	else
		startPoint = BinarySearch(TempQ1, DataQstart )
		endPoint = BinarySearch(TempQ1, DataQEnd)
	endif
	//CorrIntensity = Conc/ConcMax *(Iconc - BuffConc*Ibuff) 
	For(i=1;i<=NumberOfConcentrations;i+=1)
		Wave OrigInt=$("root:Packages:Irena:ConcSerExtrap:OrigSamIntensity"+num2str(i))
		Wave OrigQ=$("root:Packages:Irena:ConcSerExtrap:OrigSamQ"+num2str(i))
		Wave OrigE=$("root:Packages:Irena:ConcSerExtrap:OrigSamErr"+num2str(i))
		if(UseSameBufferForAll)
			Wave OrigBufInt=$("root:Packages:Irena:ConcSerExtrap:OrigBuffIntensity"+num2str(1))
			Wave OrigBufQ=$("root:Packages:Irena:ConcSerExtrap:OrigBuffQ"+num2str(1))
			Wave OrigBufE=$("root:Packages:Irena:ConcSerExtrap:OrigBuffErr"+num2str(1))
		else
			Wave OrigBufInt=$("root:Packages:Irena:ConcSerExtrap:OrigBuffIntensity"+num2str(i))
			Wave OrigBufQ=$("root:Packages:Irena:ConcSerExtrap:OrigBuffQ"+num2str(i))
			Wave OrigBufE=$("root:Packages:Irena:ConcSerExtrap:OrigBuffErr"+num2str(i))
		endif
		NVAR BufScale= $("root:Packages:Irena:ConcSerExtrap:Buffer"+num2str(i)+"Scale")
		NVAR SampleConc= $("root:Packages:Irena:ConcSerExtrap:Sample"+num2str(i)+"Conc")
		//if(!fittingData)this was causing point errors as sizes got out of sync somehow... 
		Duplicate/O/R=[startPoint,endPoint] OrigInt, $("CorrectedIntensity"+num2str(i))
		Duplicate/O/R=[startPoint,endPoint] OrigQ, $("CorrectedQ"+num2str(i))
		Duplicate/O/R=[startPoint,endPoint] OrigE, $("CorrectedErr"+num2str(i))
		//endif
		Duplicate/Free/R=[startPoint,endPoint] OrigInt, IntCopy
		Duplicate/Free/R=[startPoint,endPoint] OrigQ, QCopy
		Duplicate/Free/R=[startPoint,endPoint] OrigE, ErrCopy
		Duplicate/Free/R=[startPoint,endPoint] OrigBufInt, BufIntCopy
		Duplicate/Free/R=[startPoint,endPoint] OrigBufE, BufErrCopy
		//Duplicate/Free/R=[startPoint,endPoint] OrigBufQ, BufQCopy
		//interpolate buffer on the same Q points as main data have, just in case. Linear interpolations good enough
		BufIntCopy = interp(QCopy, OrigBufQ, OrigBufInt)
		Wave CorrectedInt=$("root:Packages:Irena:ConcSerExtrap:CorrectedIntensity"+num2str(i))
		Wave CorrectedErr=$("root:Packages:Irena:ConcSerExtrap:CorrectedErr"+num2str(i))
		CorrectedInt =  MaxConc / SampleConc * (IntCopy - BufScale * BufIntCopy)
		CorrectedErr =  MaxConc / SampleConc * sqrt(ErrCopy^2 + (BufScale * BufErrCopy)^2)
	endfor
	setDataFolder oldDf
end
///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************

Function IRB1_ConcSerExtrapolate()

	DFref oldDf= GetDataFolderDFR()
	setDataFolder root:Packages:Irena:ConcSerExtrap
	NVAR NConc = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
	IRB1_ConcSerRecalculateData(0,0,1)
	
	Wave Int1=$("root:Packages:Irena:ConcSerExtrap:CorrectedIntensity"+num2str(1))
	Wave Q1=$("root:Packages:Irena:ConcSerExtrap:CorrectedQ"+num2str(1))
	Wave E1=$("root:Packages:Irena:ConcSerExtrap:CorrectedErr"+num2str(1))

	Duplicate/O Int1, ExtrapolatedIntensity, FittingRangeMarker, ExtensionRangeColor
	Duplicate/O Q1, ExtrapolatedQ
	Duplicate/O E1, ExtrapolatedE

	variable MaxConcIndx=IR1B_ConcSerFindMaxConc()
	NVAR RollOverQValue=root:Packages:Irena:ConcSerExtrap:RollOverQValue
	variable RollOverPoint=BinarySearch(Q1, RollOverQValue )

	
	variable i, j
	make/Free/N=(NConc) TempIntFit, TempConcFit, tempEFit
	FOr(j=0;j<(RollOverPoint+5);j+=1)
		for(i=1;i<=NConc;i+=1)
			Wave IntTemp=$("root:Packages:Irena:ConcSerExtrap:CorrectedIntensity"+num2str(i))
			Wave ETemp=$("root:Packages:Irena:ConcSerExtrap:CorrectedErr"+num2str(i))
			NVAR SamC =$("root:Packages:Irena:ConcSerExtrap:Sample"+num2str(i)+"Conc")
			TempIntFit[i-1] = IntTemp[j]
			tempEFit [i-1] = ETemp[j]
			TempConcFit [i-1] = SamC
		endfor
		CurveFit/Q line TempIntFit /X=TempConcFit /W=tempEFit /I=1 /D 
		Wave  W_coef
		Wave  W_sigma
		ExtrapolatedIntensity[j] = W_coef[0]
		ExtrapolatedE[j] = W_sigma[0]
	endfor
	//splice together low-q from this calculation and high-q from max concentration... 
	Wave IntMaxC=$("root:Packages:Irena:ConcSerExtrap:CorrectedIntensity"+num2str(MaxConcIndx))
	ExtrapolatedIntensity[RollOverPoint, ] = IntMaxC[p]
	//need to create marker for fitting range
	//these are for markers to show where we did fit the data. 
	NVAR DataQEnd = root:Packages:Irena:ConcSerExtrap:DataQEnd
	NVAR DataQstart = root:Packages:Irena:ConcSerExtrap:DataQstart
	variable MarkerstartPoint, MarkerendPoint
	MarkerstartPoint = BinarySearch(Q1, DataQstart )
	MarkerendPoint = BinarySearch(Q1, DataQEnd)
	FittingRangeMarker=NaN
	ExtensionRangeColor = 0
	FittingRangeMarker[MarkerstartPoint,MarkerendPoint]=8
	FittingRangeMarker[MarkerstartPoint,MarkerendPoint]=8
	ExtensionRangeColor[RollOverPoint, ] = 1
	setDataFolder oldDf
end

///**************************************************************************************************
///**************************************************************************************************
static Function IR1B_ConcSerFindMaxConc()
	NVAR SamC1=root:Packages:Irena:ConcSerExtrap:InputSample1Conc
	NVAR SamC2=root:Packages:Irena:ConcSerExtrap:InputSample2Conc
	NVAR SamC3=root:Packages:Irena:ConcSerExtrap:InputSample3Conc
	NVAR SamC4=root:Packages:Irena:ConcSerExtrap:InputSample4Conc
	NVAR SamC5=root:Packages:Irena:ConcSerExtrap:InputSample5Conc
	make/Free/N=5 TempConcWv
	TempConcWv = {SamC1,SamC2,SamC3,SamC4,SamC5}
	Wavestats/Q TempConcWv
	variable MaxConcIndx=V_maxLoc+1
	variable MaxConcValue=max(SamC1,SamC2,SamC3,SamC4,SamC5)
	return MaxConcIndx
end

///**************************************************************************************************
///**************************************************************************************************
Function IRB1_ConcSerOptimizeParams()

	DFref oldDf= GetDataFolderDFR()
	setDataFolder root:Packages:Irena:ConcSerExtrap

	NVAR NumberOfConcentrations = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
	NVAR NumberOfConcentrations = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
	variable i
	Make/N=0/O MyPWave
	make/N=(0,2)/O MyXLimitWave
	variable TempPnt=0
	For(i=1;i<=NumberOfConcentrations;i+=1)
		NVAR FitConc = $("root:Packages:Irena:ConcSerExtrap:FitSample"+num2str(i)+"Conc")
		NVAR FitBuff = $("root:Packages:Irena:ConcSerExtrap:FitBuffer"+num2str(i)+"Scale")
		NVAR SamC=$("root:Packages:Irena:ConcSerExtrap:Sample"+num2str(i)+"Conc")
		NVAR BufferScale=$("root:Packages:Irena:ConcSerExtrap:Buffer"+num2str(i)+"Scale")		
		if(FitConc)
			TempPnt = numpnts(MyPWave)
			redimension/N=(TempPnt+1) MyPWave
			redimension/N=(TempPnt+1,2) MyXLimitWave
			MyPWave[TempPnt]= SamC
			MyXLimitWave[TempPnt][0]= 0.9*SamC
			MyXLimitWave[TempPnt][1]= 1.1*SamC
		endif
		if(FitBuff)
			TempPnt = numpnts(MyPWave)
			redimension/N=(TempPnt+1) MyPWave
			redimension/N=(TempPnt+1,2) MyXLimitWave
			MyPWave[TempPnt]= BufferScale
			MyXLimitWave[TempPnt][0]= 0.85
			MyXLimitWave[TempPnt][1]= 1.0
		endif	
	endfor
	if(numpnts(MyPWave)>1)
		make/O/N=(numpnts(MyPWave),3) stepWave
		stepWave[][0]=0.1
		stepWave[][1]=0.001
		stepWave[][2]=1
		Duplicate/O MyPWave, MyXWave
		print "Optimizing using simulated annealing, this may take little bit of time... " 
		variable timerRefNum = StartMSTimer
		Optimize /Q/I=10000/XSA=MyXLimitWave/X=MyXWave/SSA=stepWave/M = {3,0}  IRB1_ConcSerOptimizeMe, MyPWave
		variable microSeconds = StopMSTimer(timerRefNum)
		Print microSeconds/1e6, "Simulated annealing was seconds per optimization"
		print "Now Optimizing using gradient method, this shoudl be fast..." 
		//now try adding very localized search around...
		stepWave[][0]=0.1
		stepWave[][1]=0.0001
		stepWave[][2]=1
		MyXLimitWave[][0] = 0.98*MyXWave[p]
		MyXLimitWave[][1] = 1.02*MyXWave[p]
		Optimize /Q/I=100/XSA=MyXLimitWave/X=MyXWave/SSA=stepWave/M = {0,0}  IRB1_ConcSerOptimizeMe, MyPWave
		//restore parameters from the MyXWave which returns optimum values... 
		NVAR OptimizedPenalty=root:Packages:Irena:ConcSerExtrap:OptimizedPenalty
		OptimizedPenalty = V_min
		TempPnt = 0
		For(i=1;i<=NumberOfConcentrations;i+=1)
			NVAR FitConc = $("root:Packages:Irena:ConcSerExtrap:FitSample"+num2str(i)+"Conc")
			NVAR FitBuff = $("root:Packages:Irena:ConcSerExtrap:FitBuffer"+num2str(i)+"Scale")
			NVAR SamC=$("root:Packages:Irena:ConcSerExtrap:Sample"+num2str(i)+"Conc")
			NVAR BufferScale=$("root:Packages:Irena:ConcSerExtrap:Buffer"+num2str(i)+"Scale")		
			if(FitConc)
				SamC = MyXWave[TempPnt]
				TempPnt +=1
			endif
			if(FitBuff)
				BufferScale = MyXWave[TempPnt]
				TempPnt +=1
			endif	
		endfor
	elseif(numpnts(MyPWave)>1)
		setDataFolder oldDf
		Abort "Cannot optimize just one parameter"
	else
		print "No optimization requested using Input data only"
	endif	
	IRB1_ConcSerRecalculateData(0,0,1)
	setDataFolder oldDf
end


///**************************************************************************************************
///**************************************************************************************************
Function IRB1_ConcSerOptimizeMe(w,xw)
	Wave w
	Wave xw
	//this is function, which will be optimized to get best fit. 
	//setup parameters. unwrap from above routine...
	NVAR NumberOfConcentrations = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
	variable TempPnt=0
	variable i
	For(i=1;i<=NumberOfConcentrations;i+=1)
		NVAR FitConc = $("root:Packages:Irena:ConcSerExtrap:FitSample"+num2str(i)+"Conc")
		NVAR FitBuff = $("root:Packages:Irena:ConcSerExtrap:FitBuffer"+num2str(i)+"Scale")
		NVAR SamC=$("root:Packages:Irena:ConcSerExtrap:Sample"+num2str(i)+"Conc")
		NVAR BufferScale=$("root:Packages:Irena:ConcSerExtrap:Buffer"+num2str(i)+"Scale")		
		if(FitConc)
			SamC = xw[TempPnt]
			TempPnt +=1
		endif
		if(FitBuff)
			BufferScale = xw[TempPnt]
			TempPnt +=1
		endif	
	endfor
	//calculate new data
	IRB1_ConcSerRecalculateData(0,1,0)
	//calculate & return penalty
	variable penalty = IRB1_ConcSerCalcMatchQuality()
	//print xw
	//print penalty
	return penalty
end
///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************

Function IRB1_ConcSerCalcMatchQuality()
	//this is penalty function, so it calculates difference between the curves. 
	//there are three components here. 
	//1. chi-square chi^2 = sum[(deviation / std )^2]
	//sum of squares of differences from max concentration normalized by uncertainty
	//2. nNum = number of negative values over all intensities
	//3. nNum2 = Lower concentrations have smaller buffer scaling value. 
	//total penalty is 
	//err = sum(sum(mt2))+ nNum*10 + nNum2 * 100;
	
	//find max concentration
	NVAR SamC1=root:Packages:Irena:ConcSerExtrap:Sample1Conc
	NVAR SamC2=root:Packages:Irena:ConcSerExtrap:Sample2Conc
	NVAR SamC3=root:Packages:Irena:ConcSerExtrap:Sample3Conc
	NVAR SamC4=root:Packages:Irena:ConcSerExtrap:Sample4Conc
	NVAR SamC5=root:Packages:Irena:ConcSerExtrap:Sample5Conc
	NVAR BufferScale1=root:Packages:Irena:ConcSerExtrap:Buffer1Scale
	NVAR BufferScale2=root:Packages:Irena:ConcSerExtrap:Buffer2Scale
	NVAR BufferScale3=root:Packages:Irena:ConcSerExtrap:Buffer3Scale
	NVAR BufferScale4=root:Packages:Irena:ConcSerExtrap:Buffer4Scale
	NVAR BufferScale5=root:Packages:Irena:ConcSerExtrap:Buffer5Scale
	make/N=5/Free TempConc={SamC1, SamC2, SamC3, SamC4, SamC5} 	
	make/N=5/Free TempBuffScale={BufferScale1, BufferScale2, BufferScale3, BufferScale4, BufferScale5} 	

	variable MaxIntIndex=IR1B_ConcSerFindMaxConc()

	Wave MaxInt=$("root:Packages:Irena:ConcSerExtrap:CorrectedIntensity"+num2str(MaxIntIndex))
	Wave MaxQ=$("root:Packages:Irena:ConcSerExtrap:CorrectedQ"+num2str(MaxIntIndex))
	Wave MaxE=$("root:Packages:Irena:ConcSerExtrap:CorrectedErr"+num2str(MaxIntIndex))
	Duplicate/Free MaxInt, ChiSqWave//, ErrorWv
	ChiSqWave = 0
	//next calculate differences... 
	NVAR NumberOfConcentrations = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
	variable i
	For(i=1;i<=NumberOfConcentrations;i+=1)
		if(i==MaxIntIndex)
			//do nothing, this would add simply 0 in there.. 
		else
			Wave CalcInt=$("root:Packages:Irena:ConcSerExtrap:CorrectedIntensity"+num2str(i))
			Wave CalcQ=$("root:Packages:Irena:ConcSerExtrap:CorrectedQ"+num2str(i))
			Wave CalcE=$("root:Packages:Irena:ConcSerExtrap:CorrectedErr"+num2str(i))
			//ErrorWv = MaxE^2+CalcE^2		//keep it square
			ChiSqWave += (CalcInt-MaxInt)^2/(MaxE^2+CalcE^2)
		endif
	endfor
	variable Penalty1=sum(ChiSqWave)
	//number of negative values over all intensities
	variable Penalty2=0
	For(i=1;i<=NumberOfConcentrations;i+=1)
		Wave CalcInt=$("root:Packages:Irena:ConcSerExtrap:CorrectedIntensity"+num2str(i))
		Duplicate/Free CalcInt, TempWv
		TempWv = TempWv[p]<0 ? 1 : 0
		Penalty2+=sum(TempWv)	
	endfor
	//3. nNum2 = Lower concentrations have smaller buffer scaling value. 
	variable Penalty3=0
	Sort TempConc, TempConc, TempBuffScale	
	For(i=0;i<4;i+=1)
		if(TempBuffScale[i]>TempBuffScale[i+1])
			Penalty3+=1
		endif
	endfor	
	return Penalty1 + 10* Penalty2 + 100*Penalty3
end

///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************

Function IRB1_ConcSerCopyData()
	DFref oldDf= GetDataFolderDFR()
	setDataFolder root:Packages:Irena:ConcSerExtrap
	//copy data to temp folder. 
	//this simply creates copies of new data... Nothing else. 
	NVAR NumberOfConcentrations = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
	NVAR UseSameBufferForAll 	= root:Packages:Irena:ConcSerExtrap:UseSameBufferForAll
	NVAR OptimizedPenalty 	= root:Packages:Irena:ConcSerExtrap:OptimizedPenalty
	OptimizedPenalty = 0
	//locate and copy the waves here... 
	string QWavename, IntensityWaveName, ErrorWaveName
	variable i
	KillWaves/Z OrigSamIntensity1, OrigSamIntensity2, OrigSamIntensity3, OrigSamIntensity4, OrigSamIntensity5
	KillWaves/Z OrigSamQ1, OrigSamQ2, OrigSamQ3, OrigSamQ4, OrigSamQ5
	KillWaves/Z OrigSamErr1, OrigSamErr2, OrigSamErr3, OrigSamErr4, OrigSamErr5
	For(i=1;i<(NumberOfConcentrations+1);i+=1)
		SVAR SaNamefull = $("root:Packages:Irena:ConcSerExtrap:Sample"+num2str(i)+"NameFull")	//this is pointer to folder
		//this needs to be set properly, so we get names of the waves
		SVAR DfName 		= root:Packages:Irena:ConcSerExtrap:DataFolderName
		DfName = SaNamefull
		QWavename = stringFromList(0,IR2P_ListOfWaves("Xaxis","", "IRB1_ConcSeriesPanel"))
		IntensityWaveName = stringFromList(0,IR2P_ListOfWaves("Yaxis","*", "IRB1_ConcSeriesPanel"))
		ErrorWaveName = stringFromList(0,IR2P_ListOfWaves("Error","*", "IRB1_ConcSeriesPanel"))
		Wave/Z RWaveInt = $(DfName+IntensityWaveName)
		Wave/Z QWaveInt = $(DfName+QWavename)
		Wave/Z SWaveInt = $(DfName+ErrorWaveName)
		
		if(!WaveExists(RWaveInt)||!WaveExists(QWaveInt))
			setDataFolder oldDf
			Abort "Cannot locate original data"
		endif
		Duplicate/O RWaveInt, $("OrigSamIntensity"+num2str(i))
		Duplicate/O QWaveInt, $("OrigSamQ"+num2str(i))
		if(WaveExists(SWaveInt))
			Duplicate/O SWaveInt, $("OrigSamErr"+num2str(i))
		else	//make 4% intensity error. 
			Duplicate/O RWaveInt, $("OrigSamErr"+num2str(i))
			Wave Errtemp=$("OrigSamErr"+num2str(i))
			Errtemp *=0.04									
		endif
	endfor 
	//now, buffers... 
	KillWaves/Z OrigBuffIntensity1, OrigBuffIntensity2, OrigBuffIntensity3, OrigBuffIntensity4, OrigBuffIntensity5
	KillWaves/Z OrigBuffQ1, OrigBuffQ2, OrigBuffQ3, OrigBuffQ4, OrigBuffQ5
	KillWaves/Z OrigBuffErr1, OrigBuffErr2, OrigBuffErr3, OrigBuffErr4, OrigBuffErr5
	variable MaxBuff=1
	if(!UseSameBufferForAll)
		MaxBuff= NumberOfConcentrations
	endif	
	For(i=1;i<(MaxBuff+1);i+=1)
		SVAR SaNamefull = $("root:Packages:Irena:ConcSerExtrap:Buffer"+num2str(i)+"NameFull")	//this is pointer to folder
		//this needs to be set properly, so we get names of the waves
		SVAR DfName 		= root:Packages:Irena:ConcSerExtrap:DataFolderName
		DfName = SaNamefull
		QWavename = stringFromList(0,IR2P_ListOfWaves("Xaxis","", "IRB1_ConcSeriesPanel"))
		IntensityWaveName = stringFromList(0,IR2P_ListOfWaves("Yaxis","*", "IRB1_ConcSeriesPanel"))
		ErrorWaveName = stringFromList(0,IR2P_ListOfWaves("Error","*", "IRB1_ConcSeriesPanel"))
		Wave/Z RWaveInt = $(DfName+IntensityWaveName)
		Wave/Z QWaveInt = $(DfName+QWavename)
		Wave/Z SWaveInt = $(DfName+ErrorWaveName)
		
		if(!WaveExists(RWaveInt)||!WaveExists(QWaveInt))
			setDataFolder oldDf
			Abort "Cannot locate original data"
		endif
		Duplicate/O RWaveInt, $("OrigBuffIntensity"+num2str(i))
		Duplicate/O QWaveInt, $("OrigBuffQ"+num2str(i))
		if(WaveExists(SWaveInt))
			Duplicate/O SWaveInt, $("OrigBuffErr"+num2str(i))
		else	//make 4% intensity error. 
			Duplicate/O RWaveInt, $("OrigBuffErr"+num2str(i))
			Wave Errtemp=$("OrigBuffErr"+num2str(i))
			Errtemp *=0.04									
		endif
	endfor 
	
	setDataFolder oldDf
end

///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************
///**************************************************************************************************

Function IRB1_ConcSerSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval

			NVAR UseProtein=root:Packages:Irena:ConcSerExtrap:UseProtein
			NVAR UseNucleicAcid=root:Packages:Irena:ConcSerExtrap:UseNucleicAcid
			//empirical value = 1.0 - const * conc(mg/ml) / 1000; const = 0.73 for protein and 0.54 for nucleic acids.
			if(StringMatch(sva.ctrlName, "InputSample1Conc" ))
				NVAR InputBuffer1Scale = root:Packages:Irena:ConcSerExtrap:InputBuffer1Scale
				if(UseProtein)
					InputBuffer1Scale = 1.0 - (0.73 * dval / 1000)
				elseif(UseNucleicAcid)
					InputBuffer1Scale = 1.0 - (0.54 * dval / 1000)
				else
					InputBuffer1Scale = 1
				endif
			endif
			if(StringMatch(sva.ctrlName, "InputSample2Conc" ))
				NVAR InputBuffer2Scale = root:Packages:Irena:ConcSerExtrap:InputBuffer2Scale
				if(UseProtein)
					InputBuffer2Scale = 1.0 - (0.73 * dval / 1000)
				elseif(UseNucleicAcid)
					InputBuffer2Scale = 1.0 - (0.54 * dval / 1000)
				else
					InputBuffer2Scale = 1
				endif
			endif
			if(StringMatch(sva.ctrlName, "InputSample3Conc" ))
				NVAR InputBuffer3Scale = root:Packages:Irena:ConcSerExtrap:InputBuffer3Scale
				if(UseProtein)
					InputBuffer3Scale = 1.0 - (0.73 * dval / 1000)
				elseif(UseNucleicAcid)
					InputBuffer3Scale = 1.0 - (0.54 * dval / 1000)
				else
					InputBuffer3Scale = 1
				endif
			endif
			if(StringMatch(sva.ctrlName, "InputSample4Conc" ))
				NVAR InputBuffer4Scale = root:Packages:Irena:ConcSerExtrap:InputBuffer4Scale
				if(UseProtein)
					InputBuffer4Scale = 1.0 - (0.73 * dval / 1000)
				elseif(UseNucleicAcid)
					InputBuffer4Scale = 1.0 - (0.54 * dval / 1000)
				else
					InputBuffer4Scale = 1
				endif
			endif
			if(StringMatch(sva.ctrlName, "InputSample5Conc" ))
				NVAR InputBuffer5Scale = root:Packages:Irena:ConcSerExtrap:InputBuffer5Scale
				if(UseProtein)
					InputBuffer5Scale = 1.0 - (0.73 * dval / 1000)
				elseif(UseNucleicAcid)
					InputBuffer5Scale = 1.0 - (0.54 * dval / 1000)
				else
					InputBuffer5Scale = 1
				endif
			endif
			string csrWavname
			if(StringMatch(sva.ctrlName, "DataQEnd" ))
				Wave/Z Int1 = root:Packages:Irena:ConcSerExtrap:OrigSamIntensity1
				Wave/Z QWv1 = root:Packages:Irena:ConcSerExtrap:OrigSamQ1
				CheckDisplayed /W=IRB1_ConcSeriesPanel#LogLogDataDisplay Int1
				if(V_Flag)
					csrWavname = CsrWave(B , "IRB1_ConcSeriesPanel#LogLogDataDisplay" , 1)
					if(strlen(csrWavname)>0)
						Cursor /W=IRB1_ConcSeriesPanel#LogLogDataDisplay B  $(csrWavname)  BinarySearch(QWv1, dval) 
					else
						Cursor /W=IRB1_ConcSeriesPanel#LogLogDataDisplay B  OrigSamIntensity1  BinarySearch(QWv1, dval) 
					endif
				endif
			endif
			if(StringMatch(sva.ctrlName, "DataQstart" ))
				Wave/Z Int1 = root:Packages:Irena:ConcSerExtrap:OrigSamIntensity1
				Wave/Z QWv1 = root:Packages:Irena:ConcSerExtrap:OrigSamQ1
				CheckDisplayed /W=IRB1_ConcSeriesPanel#LogLogDataDisplay Int1
				if(V_Flag)
					csrWavname = CsrWave(A , "IRB1_ConcSeriesPanel#LogLogDataDisplay" , 1)
					if(strlen(csrWavname)>0)
						Cursor /W=IRB1_ConcSeriesPanel#LogLogDataDisplay A  $(csrWavname)  BinarySearch(QWv1, dval) 
					else
						Cursor /W=IRB1_ConcSeriesPanel#LogLogDataDisplay A  OrigSamIntensity1  BinarySearch(QWv1, dval) 
					endif
				endif
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**************************************************************************************
Function IRB1_ConcSeriesAppendOneDataSet(FolderNameStr)
	string FolderNameStr
	
//	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//	DfRef OldDf=GetDataFolderDFR()
//	SetDataFolder root:Packages:Irena:BioSAXSDataMan					//go into the folder
//	//IR3D_SetSavedNotSavedMessage(0)
//	//figure out if we are doing averaging or buffer subtraction
//	ControlInfo /W=IRB1_DataManipulationPanel ProcessingTabs
//	variable UsingAveraging=0
//	variable Subtracting=0
//	variable Scaling=0
//	if(V_Value==0)
//		UsingAveraging=1
//	elseif(V_Value==1)
//		Subtracting=1			//buffer subtraction
//	elseif(V_Value==2)
//		Scaling=1					//scaling data		
//	endif
//	SVAR DataStartFolder=root:Packages:Irena:BioSAXSDataMan:DataStartFolder
//	SVAR DataFolderName=root:Packages:Irena:BioSAXSDataMan:DataFolderName
//	SVAR IntensityWaveName=root:Packages:Irena:BioSAXSDataMan:IntensityWaveName
//	SVAR QWavename=root:Packages:Irena:BioSAXSDataMan:QWavename
//	SVAR ErrorWaveName=root:Packages:Irena:BioSAXSDataMan:ErrorWaveName
//	SVAR dQWavename=root:Packages:Irena:BioSAXSDataMan:dQWavename
//	NVAR UseIndra2Data=root:Packages:Irena:BioSAXSDataMan:UseIndra2Data
//	NVAR UseQRSdata=root:Packages:Irena:BioSAXSDataMan:UseQRSdata
//	//these are variables used by the control procedure
//	NVAR UseResults=  root:Packages:Irena:BioSAXSDataMan:UseResults
//	NVAR UseUserDefinedData=  root:Packages:Irena:BioSAXSDataMan:UseUserDefinedData
//	NVAR UseModelData = root:Packages:Irena:BioSAXSDataMan:UseModelData
//
//	SVAR AverageOutputFolderString = root:Packages:Irena:BioSAXSDataMan:AverageOutputFolderString
//	SVAR SubtractedOutputFldrName=root:Packages:Irena:BioSAXSDataMan:SubtractedOutputFldrName
//	SVAR UserSourceDataFolderName=root:Packages:Irena:BioSAXSDataMan:UserSourceDataFolderName
//	UseResults = 0
//	UseUserDefinedData = 0
//	UseModelData = 0
//	//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
//	string tempStr
//	if(ItemsInList(FolderNameStr, ":")>1)
//		tempStr=StringFromList(ItemsInList(FolderNameStr, ":")-1, FolderNameStr, ":")
//	else
//		tempStr = FolderNameStr
//	endif
//	AverageOutputFolderString = RemoveListItem(ItemsInList(tempStr,"_")-1, tempStr, "_") +"avg"
//	IR3C_SelectWaveNamesData("Irena:BioSAXSDataMan", FolderNameStr)			//this routine will preset names in strings as needed,
//	Wave/Z SourceIntWv=$(DataFolderName+IntensityWaveName)
//	Wave/Z SourceQWv=$(DataFolderName+QWavename)
//	Wave/Z SourceErrorWv=$(DataFolderName+ErrorWaveName)
//	Wave/Z SourcedQWv=$(DataFolderName+dQWavename)
//	if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv)||!WaveExists(SourceErrorWv))
//		Abort "Data selection failed for Data"
//	endif
//	if(Subtracting)		//subtracting buffer from ave data or scaling data, in each case, must remove the existing files. 
//		//preset for user output name for merged data
//		UserSourceDataFolderName = StringFromList(ItemsInList(FolderNameStr, ":")-1, FolderNameStr, ":")
//		if(StringMatch(UserSourceDataFolderName, "*_ave"))
//			SubtractedOutputFldrName = ReplaceString("_ave", UserSourceDataFolderName, "_sub")
//		elseif(StringMatch(UserSourceDataFolderName, "*_avg"))
//			SubtractedOutputFldrName = ReplaceString("_avg", UserSourceDataFolderName, "_sub")
//		else
//			SubtractedOutputFldrName = RemoveEnding(UserSourceDataFolderName, ":") +"_sub"	
//		endif
//		//remove, if needed, all data from graph
//		IN2G_RemoveDataFromGraph(topGraphStr = "IRB1_DataManipulationPanel#LogLogDataDisplay")
//		//append Buffer data if exist...
//		Wave/Z q_BufferData = q_BufferData
//		Wave/Z r_BufferData = r_BufferData
//		Wave/Z s_BufferData = s_BufferData
//		if(WaveExists(r_BufferData) || WaveExists(q_BufferData) || WaveExists(s_BufferData))
//			//and check the data are in the graph, else it willconfuse user. 
//			CheckDisplayed /W=IRB1_DataManipulationPanel#LogLogDataDisplay r_BufferData
//			if(V_Flag!=1)
//				AppendToGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay  r_BufferData  vs q_BufferData
//				ErrorBars/T=2/L=2 /W=IRB1_DataManipulationPanel#LogLogDataDisplay r_BufferData Y,wave=(s_BufferData,s_BufferData)
//				ModifyGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay lstyle(r_BufferData)=3,lsize(r_BufferData)=3,rgb(r_BufferData)=(0,0,0)	
//			endif
//		endif
//	endif
//	if(Scaling)
//		//remove, if needed, all data from graph
//		IN2G_RemoveDataFromGraph(topGraphStr = "IRB1_DataManipulationPanel#LogLogDataDisplay")
//	endif
//	CheckDisplayed /W=IRB1_DataManipulationPanel#LogLogDataDisplay SourceIntWv
//	if(!V_flag)
//		AppendToGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay  SourceIntWv  vs SourceQWv
//		ModifyGraph /W=IRB1_DataManipulationPanel#LogLogDataDisplay log=1, mirror=1
//		Label /W=IRB1_DataManipulationPanel#LogLogDataDisplay left "Intensity 1"
//		Label /W=IRB1_DataManipulationPanel#LogLogDataDisplay bottom "Q [A\\S-1\\M]"
//		ErrorBars /W=IRB1_DataManipulationPanel#LogLogDataDisplay $(NameOfWave(SourceIntWv)) Y,wave=(SourceErrorWv,SourceErrorWv)
//	endif
//	if(Scaling)		//in this case we can safely process data or user looks at graph with no change. 
//		IRB1_DataManScaleDataOne()
//	endif
//	
//	IN2G_ColorTopGrphRainbow(topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
//	IN2G_LegendTopGrphFldr(12, 20, 1, 0, topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
//	NVAR DisplayErrorBars = root:Packages:Irena:BioSAXSDataMan:DisplayErrorBars
//	IN2G_ShowHideErrorBars(DisplayErrorBars, topGraphStr="IRB1_DataManipulationPanel#LogLogDataDisplay")
	SetDataFolder oldDf
end
//**********************************************************************************************************

static Function IRB1_NotebookRecord()

	IR1_CreateResultsNbk()
	SVAR nbl=root:Packages:Irena:ResultsNotebookName
	DoWindow/F $nbl

	
	//DFref oldDf= GetDataFolderDFR()
	IR1_AppendAnyText("\r Results of Concentration Series Extrapolation\r",1)	
	IR1_AppendAnyText("Date & time: \t"+Date()+"   "+time(),0)	
	IR1_AppendAnyText("  ",0)

	variable i
	string TempStr
	NVAR NumberOfConcentrations = root:Packages:Irena:ConcSerExtrap:NumberOfConcentrations
	NVAR UseSameBufferForAll = root:Packages:Irena:ConcSerExtrap:UseSameBufferForAll
	For(i=1;i<=NumberOfConcentrations;i+=1)
		SVAR SampleName = $("root:Packages:Irena:ConcSerExtrap:Sample"+num2str(i)+"NameFull")
		if(UseSameBufferForAll)
			SVAR BufferName = $("root:Packages:Irena:ConcSerExtrap:Buffer"+num2str(1)+"NameFull")
		else
			SVAR BufferName = $("root:Packages:Irena:ConcSerExtrap:Buffer"+num2str(i)+"NameFull")
		endif
		NVAR InputBufferScale = $("root:Packages:Irena:ConcSerExtrap:InputBuffer"+num2str(i)+"Scale")
		NVAR FittedBufferScale = $("root:Packages:Irena:ConcSerExtrap:Buffer"+num2str(i)+"Scale")
		NVAR InputSampleConc = $("root:Packages:Irena:ConcSerExtrap:InputSample"+num2str(i)+"Conc")
		NVAR FittedSampleConc = $("root:Packages:Irena:ConcSerExtrap:Sample"+num2str(i)+"Conc")
		NVAR FittingSampleConc = $("root:Packages:Irena:ConcSerExtrap:FitSample"+num2str(i)+"Conc")
		NVAR FittingBufferScale = $("root:Packages:Irena:ConcSerExtrap:FitBuffer"+num2str(i)+"Scale")
		//record to notebook
		IR1_AppendAnyText("Sample / Buffer "+num2str(i),0)
		IR1_AppendAnyText("Sample name   \t\t:  \t"+SampleName,0)
		IR1_AppendAnyText("Buffer name    \t\t\t:  \t"+BufferName,0)
		IR1_AppendAnyText("Input sample conc.  \t\t= "+num2str(InputSampleConc),0)
		IR1_AppendAnyText("Input buffer scale  \t\t= "+num2str(InputBufferScale),0)
		if(FittingSampleConc)
			TempStr =  "Yes" 
		else
		 	TempStr =  "No"
		endif
		IR1_AppendAnyText("Fitting sample conc.  \t:\t"+TempStr,0)
		if(FittingBufferScale)
			TempStr =  "Yes" 
		else
		 	TempStr =  "No"
		endif
		IR1_AppendAnyText("Fitting buffer scale   \t\t:\t"+TempStr,0)
		IR1_AppendAnyText("Final sample conc.   \t\t= "+num2str(FittedSampleConc),0)
		IR1_AppendAnyText("Final buffer scale   \t\t= "+num2str(FittedBufferScale),0)
		IR1_AppendAnyText("  ",0)
	endfor	
	SVAR CalculatedOutputFldrName = root:Packages:Irena:ConcSerExtrap:CalculatedOutputFldrName
	IR1_AppendAnyText("Save data folder set to  \t:  \t"+CalculatedOutputFldrName,0)
	IR1_AppendAnyText("  ",0)
	IN2G_DuplGraphInPanelSubwndw("IRB1_ConcSeriesPanel#LogLogDataDisplay")	//duplicates the graph
	DoWIndow LogLogDataDisplay
	if(V_Flag)
		//succesful, need to scale it 
		MoveWindow /W=LogLogDataDisplay 20, 20, 620, 620
		string bucket11="LogLogDataDisplay"
		Notebook $nbl selection={endOfFile, endOfFile}
		Notebook $nbl scaling={50,50}, frame=1, picture={$bucket11,1,1}
		IR1_AppendAnyText("  ",0)
		IR1_AppendAnyText("Results of Concentration series extrapolation",0)
		IR1_AppendAnyText("Dotted line - extrapolated data to 0 concentration",0)
		IR1_AppendAnyText("Circles - points used for optimization/fitting",0)
		IR1_AppendAnyText("Black - points calculated from extrapolation",0)
		IR1_AppendAnyText("Blue  - points from highest conc. scaled as needed",0)
		IR1_AppendAnyText("**********************************************************",0)
		IR1_AppendAnyText("  ",0)
		KillWindow/Z LogLogDataDisplay
	endif
	
end
//**********************************************************************************************************
//**********************************************************************************************************

Function IRB1_ConcSerInitialize()	

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DfRef OldDf=GetDataFolderDFR()
	string ListOfVariables
	string ListOfStrings
	variable i
		
	if (!DataFolderExists("root:Packages:Irena:ConcSerExtrap"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:ConcSerExtrap
	endif
	SetDataFolder root:Packages:Irena:ConcSerExtrap					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;DataUnits;"
	ListOfStrings+="DataStartFolder;DataMatchString;BufferMatchString;FolderSortString;FolderSortStringAll;"
	ListOfStrings+="Sample1Name;Sample2Name;Sample3Name;Sample4Name;Sample5Name;"
	ListOfStrings+="Buffer1Name;Buffer2Name;Buffer3Name;Buffer4Name;Buffer5Name;"
	ListOfStrings+="Sample1NameFull;Sample2NameFull;Sample3NameFull;Sample4NameFull;Sample5NameFull;"
	ListOfStrings+="Buffer1NameFull;Buffer2NameFull;Buffer3NameFull;Buffer4NameFull;Buffer5NameFull;"
	ListOfStrings+="CalculatedOutputFldrName;"

	ListOfVariables="UseIndra2Data1;UseQRSdata1;DisplayErrorBars;"
	ListOfVariables+="OptimizedPenalty;RollOverQValue;"
	ListOfVariables+="UseSameBufferForAll;DataQEnd;DataQstart;NumberOfConcentrations;UseProtein;UseNucleicAcid;"
	ListOfVariables+="InputBuffer1Scale;InputBuffer2Scale;InputBuffer3Scale;InputBuffer4Scale;InputBuffer5Scale;"
	ListOfVariables+="Buffer1Scale;Buffer2Scale;Buffer3Scale;Buffer4Scale;Buffer5Scale;"
	ListOfVariables+="Sample1Conc;Sample2Conc;Sample3Conc;Sample4Conc;Sample5Conc;"
	ListOfVariables+="InputSample1Conc;InputSample2Conc;InputSample3Conc;InputSample4Conc;InputSample5Conc;"
	ListOfVariables+="FitSample1Conc;FitSample2Conc;FitSample3Conc;FitSample4Conc;FitSample5Conc;"
	ListOfVariables+="FitBuffer1Scale;FitBuffer2Scale;FitBuffer3Scale;FitBuffer4Scale;FitBuffer5Scale;"

	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	


	ListOfVariables = "Buffer1Scale;Buffer2Scale;Buffer3Scale;Buffer4Scale;Buffer5Scale;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if(testVar<0.1)
			testVar=1
		endif
	endfor

	ListOfVariables = "Sample1Conc;Sample2Conc;Sample3Conc;Sample4Conc;Sample5Conc;InputSample1Conc;InputSample2Conc;InputSample3Conc;InputSample4Conc;InputSample5Conc;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if(testVar<0.01)
			testVar=1
		endif
	endfor

	NVAR NumberOfConcentrations
	if(NumberOfConcentrations<3)
		NumberOfConcentrations=3
	endif
	NVAR RollOverQValue
	if(RollOverQValue<0.01)
		RollOverQValue=0.09
	endif
	For(i=1;i<=5;i+=1)
		KillWaves/Z $("CorrectedIntensity"+num2str(i)), $("CorrectedQ"+num2str(i)), $("CorrectedE"+num2str(i))
	endfor
	KillWaves/Z ExtrapolatedIntensity, ExtrapolatedQ, ExtrapolatedE
	KillWaves/Z CorrectedIntensity1, CorrectedQ1, CorrectedE1
	KillWaves/Z CorrectedIntensity2, CorrectedQ2, CorrectedE2
	KillWaves/Z CorrectedIntensity3, CorrectedQ3, CorrectedE3
	KillWaves/Z CorrectedIntensity4, CorrectedQ4, CorrectedE4
	KillWaves/Z CorrectedIntensity5, CorrectedQ5, CorrectedE5

	SetDataFolder oldDf

end
//**************************************************************************************
//**************************************************************************************
