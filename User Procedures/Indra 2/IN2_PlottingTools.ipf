#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3			// Use modern global access method.
//#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.14



//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.14  removed unused functions

//*********************************************
Function IN2P_MakeLogLogGraphDecLim()

	variable X_start, X_end, Y_start, Y_end
	getAxis bottom
	X_start=10^floor(log(V_min))
	X_end=10^ceil(log(V_max))
	getAxis left
	Y_start=10^floor(log(V_min))
	Y_end=10^ceil(log(V_max))
	setAxis left, Y_start, Y_end
	setAxis bottom, X_Start, X_end

End

////**********************************************
//Function IN2P_ChangePlotSymbolType(modetype,qcolors)
//	variable modetype,qcolors
//	Prompt modetype, "Type of display", popup,"line and marker;markers;line"
//	Prompt qcolors,"Mixed Colors?",popup,"Colors;Grays;No"
//
//	Silent 1;pauseupdate
//	string markertypes="19;17;16;23;18;8;5;6;22;7;0;1;2;25;26;28;29;15;14;4;3"
//	string rcolortypes="65535;0;0;65535;52428;0;39321;52428;1;26214"
//	string gcolortypes="0;0;65535;43690;1;0;13101;52425;24548;26214"
//	string bcolortypes="0;65535;0;0;41942;0;1;1;52428;26214"
//	do
//		if(modetype==1)
//			modetype=4
//			break
//		endif
//		if(modetype==2)
//			modetype=3
//			break
//		endif
//		if(modetype==3)
//			modetype=0
//			break
//		endif
//		break
//	while(1)
//	string ListofWaves=TraceNameList("",";",1),Awavename
//	variable position1=strsearch(ListofWaves,";",0),position2=position1
//	variable markpos1=strsearch(markertypes,";",0), markpos2=markpos1
//	Awavename=ListofWaves[0,(position1-1)]
//	variable marktp=str2num(markertypes[0,(markpos1-1)])
//	variable red=Str2num(StringFromList(0,rcolortypes,";"))
//	variable green=Str2num(StringFromList(0,gcolortypes,";"))
//	variable blue=Str2num(StringFromList(0,bcolortypes,";"))
//	variable grey=0
//	//First
//	if(qcolors!=3)
//		if(qcolors==1)
//			ModifyGraph mode=modetype,msize=2,marker($Awavename)=marktp,rgb($Awavename)=(red,green,blue)
//		else
//			ModifyGraph mode=modetype,msize=2,marker($Awavename)=marktp,rgb($Awavename)=(grey,grey,grey)
//		endif
//	else
//		ModifyGraph mode=modetype,msize=2,marker($Awavename)=marktp
//	endif
//	//
//	variable length=strlen(ListofWaves)
//	variable counter=1
//	do
//		position1=position2
//		markpos1=markpos2
//		position2=strsearch(ListofWaves,";",(position1+1))
//		if(position2==-1)
//			break
//		endif
//		markpos2=strsearch(markertypes,";",(markpos1+1))
//		marktp=str2num(markertypes[(markpos1+1),(markpos2-1)])
//		if(counter<10)
//			red=Str2num(StringFromList(counter,rcolortypes,";"))
//			green=Str2num(StringFromList(counter,gcolortypes,";"))
//			blue=Str2num(StringFromList(counter,bcolortypes,";"))
//		else
//			red=(counter-9)*10000
//			green=(counter-9)*10000
//			blue=(counter-9)*10000
//		endif
//		grey=counter*10000
//		Awavename=ListofWaves[(position1+1),(position2-1)]
//		if(qcolors!=3)
//			if(qcolors==1)
//				ModifyGraph mode=modetype,msize=2,marker($Awavename)=marktp,rgb($Awavename)=(red,green,blue)
//			else
//				ModifyGraph mode=modetype,msize=2,marker($Awavename)=marktp,rgb($Awavename)=(grey,grey,grey)
//			endif
//		else
//			ModifyGraph mode=modetype,msize=2,marker($Awavename)=marktp
//		endif
//		counter+=1
//	while(position2!=(length-1))
//End
//*****************************************

Function IN2P_DrawLineOf3Slope()
	IN2P_DrawLineOfRequiredSlope(3,3,1,"-3")
End

//*****************************************

Function IN2P_DrawLineOf2Slope()
	IN2P_DrawLineOfRequiredSlope(2,2,1,"-2")
End
//*****************************************

Function IN2P_DrawLineOf4Slope()
	IN2P_DrawLineOfRequiredSlope(4,4,1,"-4")
End
//*****************************************
Function IN2P_DrawLineOfAnySlope()

	Variable lineslope,YourNumber,qlabel
	string label1
	Prompt lineslope, "Enter slope of line, or select Your number",Popup,"M1;M2;M3;M4;M5;M3.5;M4.5;M2.5;M1.5;Your Number;Vertical;Horizontal;5/3"
	Prompt YourNumber,"If Your number above selected, enter here a number for the slope:"
	Prompt qlabel,"Add a Label?",popup,"Power From Above;My own;No"
	Prompt label1,"If Yes, then here type your label?"

	DoPrompt "Draw line of any slope, select parameters", lineslope, Yournumber, qlabel, label1
	if (V_Flag)
			Abort
	endif
	Silent 1
	do
		if(lineslope==12)
			lineslope=0
			break
		endif
		if(lineslope==10)
			lineslope=YourNumber
			break
		endif
		if(lineslope==6)
			lineslope=3.5
			break
		endif
		if(lineslope==7)
			lineslope=4.5
			break
		endif
		if(lineslope==8)
			lineslope=2.5
			break
		endif
		if(lineslope==9)
			lineslope=1.5
			break
		endif
		if(lineslope==13)
			lineslope=5/3
			break
		endif
		break
	while(1)

	IN2P_DrawLineOfRequiredSlope(LineSlope,YourNumber,qLabel,label1)
end


Function IN2P_DrawLineOfRequiredSlope(LineSlope,YourNumber,qLabel,label1)
	Variable lineslope,YourNumber,qlabel
	string label1
	
	SetDrawEnv xcoord= bottom,ycoord= left,save
	variable X_start, Y_start
	getAxis bottom
	X_start=ceil((floor(log(V_max))+floor(log(V_min)))/2)
	getAxis left
	Y_start=ceil((ceil(log(V_max))+ceil(log(V_min)))/2)
	if(lineslope==11)														//Vertical
		drawline 10^(X_start),10^(Y_start),10^(X_start+1),10^(Y_start)
	else
		drawline 10^(X_start),10^(Y_start),10^(X_start+1),10^(Y_start-lineslope)
	endif
	if(qlabel==2)
		SetDrawEnv fname= "Times",fstyle= 1;DelayUpdate
		DrawText 10^(X_start),10^(Y_start-1),Label1
	else
		if(qlabel==1)//use power from above
			SetDrawEnv fname= "Times",fstyle= 1;DelayUpdate
			DrawText 10^(X_start),10^(Y_start-1),("-"+num2str(lineslope))
		endif
	endif
EndMacro

//******************************************************************************
Function IN2P_CommonUSAXSPlots()			//this function generates graph of standard USAXS plots
											//we'll work in special folder, so we can change waves as necessary

	IN2G_UniversalFolderScan("root:USAXS:", 5, "IN2G_CheckTheFolderName()")  //here we fix the folder names/sample names in wave notes if necessary
	
		String ScanTypeY,PlotType,ScanTypeX,ScanTypeError
		Prompt ScanTypeY, "Data type to plot on Y axis", popup, "SMR_Int;R_Int;DSM_Int;M_SMR_Int;M_DSM_Int;PD_Intensity;USAXS_PD;I0;FemtoPD;SizesVolumeDistribution;SizesNumberDistribution"
		Prompt PlotType, "Type of plot ?", popup, "Log-Log;LogY-LinX;LinY-LogX;Lin-Lin"

	DoPrompt "Common plots need input", ScanTypeY, PlotType
	if (V_Flag)
			Abort
	endif	
	
	if (cmpstr(ScanTypeY,"SMR_Int")==0)
		ScanTypeX="SMR_Qvec"
		ScanTypeError="SMR_Error"
	endif
	if (cmpstr(ScanTypeY,"R_Int")==0)
		ScanTypeX="R_Qvec"
		ScanTypeError="R_error"	
	endif
	if (cmpstr(ScanTypeY,"DSM_Int")==0)
		ScanTypeX="DSM_Qvec"
		ScanTypeError="DSM_Error"
	endif
	if (cmpstr(ScanTypeY,"M_SMR_Int")==0)
		ScanTypeX="M_SMR_Qvec"
		ScanTypeError="M_SMR_Error"	
	endif
	if (cmpstr(ScanTypeY,"M_DSM_Int")==0)
		ScanTypeX="M_DSM_Qvec"
		ScanTypeError="M_DSM_Error"	
	endif
	if (cmpstr(ScanTypeY,"PD_Intensity")==0)
		ScanTypeX="Qvec"
		ScanTypeError="PD_error"	
	endif
	if (cmpstr(ScanTypeY,"USAXS_PD")==0)
		ScanTypeX="ar_enc"
		ScanTypeError="none"
	endif
	if (cmpstr(ScanTypeY,"I0")==0)
		ScanTypeX="ar_enc"
		ScanTypeError="none"
	endif
	if (cmpstr(ScanTypeY,"FemtoPD")==0)
		ScanTypeX="ar_enc"
		ScanTypeError="none"
	endif
	if (cmpstr(ScanTypeY,"SizesNumberDistribution")==0)
		ScanTypeX="SizeDistDiameter"
		ScanTypeError="none"
	endif
	if (cmpstr(ScanTypeY,"SizesVolumeDistribution")==0)
		ScanTypeX="SizeDistDiameter"
		ScanTypeError="none"
	endif


	String SampleFolder, Bucket3	
	Prompt SampleFolder, "Select  data folder for sample", popup,  IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, ScanTypeY, 1)
	
	DoPrompt "Common plots needs input", SampleFolder	
	if (V_Flag)
		Abort
	endif
	Silent 1	

	SetDataFolder SampleFolder						//sets working directory to sample
  	String PathToFirstPlotY, PathToFirstPlotX, PathToFirstPlotError
  	NVAR FirstSampleMaxInt=$(SampleFolder+"MaximumIntensity")
  	WAVE WaveY=$(SampleFolder+ScanTypeY	)		//again names calling
 	WAVE WaveX=$(SampleFolder+ScanTypeX)
 	WAVE WaveErr=$(SampleFolder+ScanTypeError)

	KillWIndow/Z StandardPlot
 
 	PauseUpdate    //*************************Graph section**********************************
	Display/k=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("height"),60*IN2G_ScreenWidthHeight("width"),70*IN2G_ScreenWidthHeight("height"))  WaveY vs WaveX  as "Plot of any wave to any wave"
	DoWindow/C StandardPlot
	ModifyGraph mode=4,	margin(top)=100, mirror=1, minor=1
	showinfo												//shows info
	Label left ScanTypeY								//labels left axis
	Label bottom ScanTypeX							//labels bottom axis
	ShowTools/A											//show tools
	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
	
	if (stringmatch(ScanTypeX, "*Qvec*" ))
//		IN2G_AppendSizeTopWave("StandardPlot",WaveX, WaveY,0,0,30)
	endif
	if (cmpstr(ScanTypeError,"none")!=0)
		ErrorBars  $(stringFromList(0,TraceNameList("",";",0))), Y,wave=(WaveErr,WaveErr) 	
	endif

	if (cmpstr(PlotType,"Log-Log")==0)							//axis to log-log
		ModifyGraph log=1
	endif
	if (cmpstr(PlotType,"LinY-LogX")==0)							//axis to logx-liny
		ModifyGraph log(bottom)=1
	endif
	if (cmpstr(PlotType,"LogY-LinX")==0)							//axis to linx-logy
		ModifyGraph log(left)=1
	endif
		
	Button KillThisWindow pos={10,10}, size={100,25}, title="Kill window", proc=IN2G_KillGraphsAndTables
	Button ResetWindow pos={10,50}, size={100,25}, title="Reset window", proc=IN2G_ResetGraph
	Button AddAnotherWave pos={150,10}, size={150,25}, title="Add another data", proc=IN2P_AddAnotherWave
	IN2G_GenerateLegendForGraph(10,1,0)		//this generates the legend
	ResumeUpdate   //*************************Graph section**********************************
	ModifyGraph width=0, height=0
End
//******************************************************************************
//Proc PorodPlot(CurrentDataFolder,Power)
//	String CurrentDataFolder, ScanTypeBucketError, SampleBucket,ScanTypeBucketY,ScanTypeBucketX
//	variable Power
//	Prompt CurrentDataFolder, "Select sample data folder", popup, FindPathAndComments("root:", "SMR_Int", 33)
//	Prompt Power, "What power - USAXS:3 or SBUSAXS:4?)", popup, "3;4"
//	
//	if (Power==1)
//		Power=3
//	else
//		Power=4
//	endif
//
//	Silent 1	
//
//	SetDataFolder StringFromList(0,CurrentDataFolder, ",")							//sets working directory to sample
//  	String/G PathToFirstPlotY, PathToFirstPlotX, PathToFirstPlotError
//  	PathToFirstPlotY=StringFromList(0,CurrentDataFolder, ",")+"SMR_Int"			//again names calling
// 	PathToFirstPlotX=StringFromList(0,CurrentDataFolder, ",")+"SMR_Qvec"
// 	PathToFirstPlotError=StringFromList(0,CurrentDataFolder, ",")+"SMR_Error"
//
// 	Make/O/D/N=(numpnts($PathToFirstPlotY)) tempY, tempY3
//	Make/O/D/N=(numpnts($PathToFirstPlotX)) tempX
//	tempX=($PathToFirstPlotX)^Power
//	tempY=$PathToFirstPlotY
//	tempY3:=tempY*tempX
//
// 	
// 	PauseUpdate    //*************************Graph section**********************************
//
//	Display tempY3 vs tempX	as "Porod Plot"								//I like graphs
//	ModifyGraph mode=4,	width=0.5*GraphSize("width"),height=0.5*GraphSize("height"), margin(top)=100, mirror=1, minor=1
//	showinfo												//shows info
//	Label left "I*Q^"+num2str(Power)								//labels left axis
//	Label bottom "Q^"+num2str(Power)							//labels bottom axis
//	ShowTools/A											//show tools
//	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
//	getAxis bottom
//	cursor A, tempY3, BinarySearch(tempX, V_min)
//	cursor B, tempY3, BinarySearch(tempX, V_max)
//	DoUpdate
//	Button KillThisWindow pos={10,10}, size={100,25}, title="Kill window", proc=KillGraphsAndTables
//	Button ResetWindow pos={10,50}, size={100,25}, title="Reset window", proc=ResetGraph
//	Button AddAnotherWave pos={350,10}, size={150,25}, title="Add another data", proc=AddAnotherWavePorod
//	String/G LegendspecComment="\\s("+StringFromList(0,ScanTypeBucketY)+")\t"+StringFromList(0,ScanTypeBucketY)+"   "+specComment
//	Button FitLine pos={150,10}, size={100,25}, title="Fit line on selection", proc=FitPorodLine
//	Button SubtractBackground pos={150,50}, size={150,25}, title="Subtract background", proc=SubtractBackground
//	
//	Legend/N=Legend1/J/S=3/A=LB LegendspecComment
//	ResumeUpdate   //*************************Graph section**********************************
//	ModifyGraph width=0, height=0
//	
//		if(exists("root:NotebookName")==2)
//	if (strsearch(WinList("*",";","WIN:16"),root:NotebookName,0)==0)				//Logs data in Logbook
//		AppendAnyText("      ")
//		AppendAnyText("Created Porod plot for SMEARED data:      "+LegendspecComment)
//		
//	endif
//	endif
//End
//
//Proc  M_PorodPlot()		//This allows calling the macro from above and still passing some setting when repeating plot
//	M_PorodPlot1(,,1,1,0,0)
//end
//
//
//Proc M_PorodPlot1(CurrentDataFolder,Power,Qmax,IQmax,KursorA,KursorB)
//	String CurrentDataFolder, ScanTypeBucketError, SampleBucket,ScanTypeBucketY,ScanTypeBucketX
//	variable Power,Qmax,IQmax,KursorA,KursorB
//	Prompt CurrentDataFolder, "Select sample data folder", popup, FindPathAndComments("root:", "M_SMR_Int", 33)
//	Prompt Power, "What power - USAXS:3 or SBUSAXS:4?)", popup, "3;4"
//
//	if (Power==1)
//		Power=3
//	else
//		Power=4
//	endif
//	Silent 1	
//
//	SetDataFolder StringFromList(0,CurrentDataFolder, ",")							//sets working directory to sample
//  	String/G PathToFirstPlotY, PathToFirstPlotX, PathToFirstPlotError
//  	PathToFirstPlotY=StringFromList(0,CurrentDataFolder, ",")+"M_SMR_Int"			//again names calling
// 	PathToFirstPlotX=StringFromList(0,CurrentDataFolder, ",")+"SMR_Qvec"
// 	PathToFirstPlotError=StringFromList(0,CurrentDataFolder, ",")+"M_SMR_Error"
//
// 	Make/O/D/N=(numpnts($PathToFirstPlotY)) tempY, tempY3
//	Make/O/D/N=(numpnts($PathToFirstPlotX)) tempX
//	tempX=($PathToFirstPlotX)^Power
//	tempY=$PathToFirstPlotY
//	tempY3:=(tempY)*tempX
//
//	if (Qmax==1)
//		WaveStats tempX
//		Qmax=V_max
//	endif
//	if (IQmax==1)
//		WaveStats tempY3
//		IQmax=V_max
//	endif
//	if (KursorB==0)
//		KursorB=numpnts(tempY3)-1
//	endif
// 	
// 	PauseUpdate    //*************************Graph section**********************************
//
//	Display tempY3 vs tempX	as "Porod Plot"								//I like graphs
//	ModifyGraph mode=4,	width=0.5*GraphSize("width"),height=0.5*GraphSize("height"), margin(top)=100, mirror=1, minor=1
//	showinfo												//shows info
//	Label left "I*Q^"+num2str(Power)								//labels left axis
//	Label bottom "Q^"+num2str(Power)							//labels bottom axis
//	ShowTools/A											//show tools
//	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
////	getAxis bottom
////	cursor A, tempY3, BinarySearch(tempX, V_min)
////	cursor B, tempY3, BinarySearch(tempX, V_max)
//	DoUpdate
//	SetAxis left 0,IQmax
//	SetAxis bottom 0,Qmax
//	Cursor A, tempY3, KursorA
//	Cursor B, tempY3, KursorB
//	DoUpdate
//	Button KillThisWindow pos={10,10}, size={100,25}, title="Kill window", proc=KillGraphsAndTables
//	Button ResetWindow pos={10,50}, size={100,25}, title="Reset window", proc=ResetGraph
//	Button AddAnotherWave pos={320,10}, size={150,25}, title="Add another data", proc=AddAnotherWavePorod_M
//	String/G LegendspecComment="\\s("+StringFromList(0,ScanTypeBucketY)+")\t"+StringFromList(0,ScanTypeBucketY)+"   "+specComment
//	Button FitLine pos={150,10}, size={100,25}, title="Fit line on selection", proc=FitPorodLine
//	Button SubtractBackground pos={150,50}, size={150,25}, title="Subtract background", proc=SubtractBackground
//	Button ContinueNextSample pos={320,50}, size={150,25}, title="Evaluate another sample", proc=RepeatMacroButtonPorod_M	
//	
//	Legend/N=Legend1/J/S=3/A=LB LegendspecComment
//	ResumeUpdate   //*************************Graph section**********************************
//	ModifyGraph width=0, height=0
//	
//	if(exists("root:NotebookName")==2)
//	if (strsearch(WinList("*",";","WIN:16"),root:NotebookName,0)==0)				//Logs data in Logbook
//		AppendAnyText("      ")
//		AppendAnyText("Evaluated Porod plot for SB_USAXS data:      "+LegendspecComment)
//		
//	endif
//	endif
//End
// *********************** Function definitions *********************
//Function RepeatMacroButtonPorod_M(ctrlname) : Buttoncontrol			// calls the repeat function fit
//	string ctrlname
//		
//	if (strlen(WinList("PDcontrols",";","WIN:64"))>0)					//Kills the controls when not needed anymore
//			DoWindow/K PDcontrols
//	endif
//	variable KursorA=xcsr(A)
//	variable KursorB=xcsr(B)
//	GetAxis /Q left
//	variable IQmax=V_max
//	GetAxis /Q bottom
//	variable Qmax=V_max
//
//	String wName=WinName(0, 1)              // 1=graphs, 2=tables,4=layouts
//       dowindow /K $wName
//
//	string ToExecute= "M_PorodPlot1( , ,"+num2str(Qmax)+","+num2str(IQmax)+","+num2str(KursorA)+","+num2str(KursorB)+")"
//	execute ToExecute
//End
////********************************************
//
//Function SubtractBackground(ctrlname) : Buttoncontrol			
//	string ctrlname
//	execute "SubtractBackground2()"
//End
//
//
//Proc SubtractBackground2(background)			
//	variable background
//	tempY= tempY-background
//End
//
//Proc FitPorodLine(ctrlname) : Buttoncontrol			
//	string ctrlname
//	Variable PorodConst, PorodBackground
//	CurveFit line tempY3(xcsr(A),xcsr(B)) /X=tempX /D 
//	TextBox/C/N=PorodResults "Porod constant is:      "+num2str(W_coef[0])+",     Background is:"+num2str(W_coef[1])
//	
//	//***********************************Notebook logging**************************************
//	if(exists("root:NotebookName")==2)
//	if (strsearch(WinList("*",";","WIN:16"),root:NotebookName,0)==0)				//Logs data in Logbook
//		AppendAnyText("Porod constant is:      "+num2str(W_coef[0])+",     Background is:"+num2str(W_coef[1]))
//		
//	endif
//	endif
//End
//
//Function AddAnotherWavePorod(ctrlname) : Buttoncontrol			
//	string ctrlname
//	execute "AddAnotherWaveMacroPorod( )"
//End
//
//
//Function AddAnotherWavePorod_M(ctrlname) : Buttoncontrol			
//	string ctrlname
//	execute "AddAnotherWaveMacroPorod_M( )"
//End
////******************************************************************************
//Proc GuinierPlot(CurrentDataFolder)
//	String CurrentDataFolder, ScanTypeBucketError, SampleBucket,ScanTypeBucketY,ScanTypeBucketX
//	Prompt CurrentDataFolder, "Select sample data folder", popup, FindPathAndComments("root:", "SMR_Int", 33)
//	
//	Silent 1	
//
//	SetDataFolder StringFromList(0,CurrentDataFolder, ",")							//sets working directory to sample
//  	String/G PathToFirstPlotY, PathToFirstPlotX, PathToFirstPlotError
//  	PathToFirstPlotY=StringFromList(0,CurrentDataFolder, ",")+"SMR_Int"			//again names calling
// 	PathToFirstPlotX=StringFromList(0,CurrentDataFolder, ",")+"SMR_Qvec"
// 	PathToFirstPlotError=StringFromList(0,CurrentDataFolder, ",")+"SMR_Error"
//
// 	Make/D/O/N=(numpnts($PathToFirstPlotY)) tempY
//	tempY=ln($PathToFirstPlotY)
//	Make/D/O/N=(numpnts($PathToFirstPlotX)), tempX
//	tempX=($PathToFirstPlotX)^2
// 	
// 	PauseUpdate    //*************************Graph section**********************************
//
//	Display tempY vs tempX	as "Guinier Plot"								//I like graphs
//	ModifyGraph mode=4,	width=0.5*GraphSize("width"),height=0.5*GraphSize("height"),  margin(top)=100, mirror=1, minor=1
//	showinfo												//shows info
//	Label left "ln(I)"								//labels left axis
//	Label bottom "Q^2"							//labels bottom axis
//	ShowTools/A											//show tools
//	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
//	
//	Button KillThisWindow pos={10,10}, size={100,25}, title="Kill this window", proc=KillGraphsAndTables
//	Button ResetWindow pos={10,50}, size={100,25}, title="Reset this window", proc=ResetGraph
//	Button AddAnotherWave pos={150,10}, size={150,25}, title="Add another wave", proc=AddAnotherWave
//	Button FitLine pos={150,50}, size={150,25}, title="Fit line w/cursors", proc=FitLineWithCursorsBtn
//
//	String/G LegendspecComment="\\s("+StringFromList(0,ScanTypeBucketY)+")\t"+StringFromList(0,ScanTypeBucketY)+"   "+specComment
//	Legend/N=Legend1/J/S=3/A=LB LegendspecComment
//	ResumeUpdate   //*************************Graph section**********************************
//	ModifyGraph width=0, height=0
//End
//
//// ******************************************************************************************************************************************************
//Function FitLineWithCursorsBtn(ctrlname) : Buttoncontrol			
//	string ctrlname
//	
//	execute "FitLineWithCursors()"
//End

// ******************************************************************************************************************************************************
 
Function IN2P_AddAnotherWave(ctrlname) : Buttoncontrol
	String ctrlname

	String NewSampleFolder, Normalize, errorType		//, CurrentDataFolder, Bucket3, PathTo_temp,CurrentFolder, Bucket4
	
	string ScanTypeY,ScanTypeX
	ScanTypeY=WaveName("", 0, 1)
	ScanTypeX=WaveName("", 0, 2)
	string tempBuffer=WinRecreation("",0)[strsearch(WinRecreation("",0),"ErrorBars",0), strsearch(WinRecreation("",0),"ErrorBars",0)+100]
	if (stringmatch(tempBuffer,"*ErrorBars*")==0)
		tempBuffer=""
	endif
	tempBuffer=TempBuffer[strsearch(tempBuffer,"(",0),strsearch(tempBuffer,")",0)]
	ErrorType=stringFromList(ItemsInList(tempBuffer,":")-1,tempBuffer, ":")
	ErrorType=ErrorType[0,strlen(ErrorType)-2]

	Prompt NewSampleFolder, "Select  data folder for sample", popup, IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, ScanTypeY+"*", 1)
	Prompt Normalize, "Normalize to top of the first scan", popup, "not implemented yet;no;yes"		

	DoPrompt "Select data folder for data to add:", NewSampleFolder, Normalize
	if (V_Flag)
		Abort
	endif
	AppendToGraph $(NewSampleFolder+ScanTypeY) vs $(NewSampleFolder+ScanTypeX)	 							
	if (strlen(ErrorType)>0)
		ErrorBars $(StringFromList(ItemsInList(TraceNameList("",";",1))-1,TraceNameList("",";",1))), Y, wave=($(NewSampleFolder+ErrorType),$(NewSampleFolder+ErrorType))
	endif
	
	IN2G_GenerateLegendForGraph(10,1,1)

	Silent 1
 	 
	ModifyGraph/Z msize=1, mode=4, marker[0]=1, marker[1]=3,marker[2]=5, marker[3]=7,marker[4]=9, marker[5]=11,marker[6]=13, marker[7]=30,marker[8]=35
	ModifyGraph/Z rgb[0]=(0,0,0),rgb[1]=(65280,16320,16320),rgb[2]=(65280,50000,16320),rgb[3]=(16320,65280,65280), rgb[4]=(0,43520,65280),rgb[5]=(32640,65280,0),rgb[6]=(0,32640,0),rgb[7]=(0,16320,65280),rgb[8]=(65280,0,52240)
	ModifyGraph/Z rgb[9]=(0,0,0),rgb[10]=(65280,0,0),rgb[11]=(0,0,0),rgb[12]=(0,0,0), rgb[13]=(0,0,0),rgb[14]=(0,0,0),rgb[15]=(0,0,0),rgb[16]=(0,0,0),rgb[17]=(0,0,0)
	
End

 
//Proc AddAnotherWaveMacroPorod(SampleBucket,Power)
//	String SampleBucket, ScanTypeBucketY,ScanTypeBucketX,Normalize, CurrentDataFolder, Bucket3, PathTo_temp,CurrentFolder, Bucket4
//	Variable Power
//	Prompt SampleBucket, "Select  data folder for sample", popup, FindPathAndComments("root:", "SMR_Int", 33)
//	Prompt Power, "What power - USAXS:3 or SBUSAXS:4?)", popup, "3;4"
//
//	if (Power==1)
//		Power=3
//	else
//		Power=4
//	endif
//
//
//	ScanTypeBucketY="SMR_Int"
//	ScanTypeBucketX="SMR_Qvec"
//
//	Silent 1
//
//	string oldX, oldY
//	oldX=StringFromList(0,ScanTypeBucketX)
//	oldY=StringFromList(0,ScanTypeBucketY)
//					
//	CurrentFolder=GetDataFolder(1)
//	SetDataFolder StringFromList(0,SampleBucket, ",")
//
// 	Make/D/O/N=(numpnts($oldY)) tempY=$oldY
//	Make/D/O/N=(numpnts($oldX)) tempX=$oldX
//	tempY=tempY*(tempX)^Power
//	tempX=(tempX)^Power
//   	AppendToGraph tempY vs tempX								
// 	Textbox/S=3/A=LB "Added data are:    "+SpecComment
//
// 	 
//	ModifyGraph/Z mode=4, marker[0]=1, marker[1]=3,marker[2]=5, marker[3]=7,marker[4]=9, marker[5]=11,marker[6]=13, marker[7]=30,marker[8]=35
//	ModifyGraph/Z rgb[0]=(0,0,0),rgb[1]=(65280,16320,16320),rgb[2]=(65280,50000,16320),rgb[3]=(16320,65280,65280), rgb[4]=(0,43520,65280),rgb[5]=(32640,65280,0),rgb[6]=(0,32640,0),rgb[7]=(0,16320,65280),rgb[8]=(65280,0,52240)
//	ModifyGraph/Z rgb[9]=(0,0,0),rgb[10]=(65280,0,0),rgb[11]=(0,0,0),rgb[12]=(0,0,0), rgb[13]=(0,0,0),rgb[14]=(0,0,0),rgb[15]=(0,0,0),rgb[16]=(0,0,0),rgb[17]=(0,0,0)
//
//	 SetDataFolder $CurrentFolder
//
//End
//
//Proc AddAnotherWaveMacroPorod_M(SampleBucket,Power)
//	String SampleBucket, ScanTypeBucketY,ScanTypeBucketX,Normalize, CurrentDataFolder, Bucket3, PathTo_temp,CurrentFolder, Bucket4
//	Variable Power
//	Prompt SampleBucket, "Select  data folder for sample", popup, FindPathAndComments("root:", "M_SMR_Int", 33)
//	Prompt Power, "What power - USAXS:3 or SBUSAXS:4?)", popup, "3;4"
//
//	if (Power==1)
//		Power=3
//	else
//		Power=4
//	endif
//
//
//	ScanTypeBucketY="M_SMR_Int"
//	ScanTypeBucketX="SMR_Qvec"
//
//	Silent 1
//
//	string oldX, oldY
//	oldX=StringFromList(0,ScanTypeBucketX)
//	oldY=StringFromList(0,ScanTypeBucketY)
//					
//	CurrentFolder=GetDataFolder(1)
//	SetDataFolder StringFromList(0,SampleBucket, ",")
//
// 	Make/D/O/N=(numpnts($oldY)) tempY=$oldY
//	Make/D/O/N=(numpnts($oldX)) tempX=$oldX
//	tempY=tempY*(tempX)^Power
//	tempX=(tempX)^Power
//   	AppendToGraph tempY vs tempX								
// 	Textbox/S=3/A=LB "Added data are:    "+SpecComment
//
// 	 
//	ModifyGraph/Z mode=4, marker[0]=1, marker[1]=3,marker[2]=5, marker[3]=7,marker[4]=9, marker[5]=11,marker[6]=13, marker[7]=30,marker[8]=35
//	ModifyGraph/Z rgb[0]=(0,0,0),rgb[1]=(65280,16320,16320),rgb[2]=(65280,50000,16320),rgb[3]=(16320,65280,65280), rgb[4]=(0,43520,65280),rgb[5]=(32640,65280,0),rgb[6]=(0,32640,0),rgb[7]=(0,16320,65280),rgb[8]=(65280,0,52240)
//	ModifyGraph/Z rgb[9]=(0,0,0),rgb[10]=(65280,0,0),rgb[11]=(0,0,0),rgb[12]=(0,0,0), rgb[13]=(0,0,0),rgb[14]=(0,0,0),rgb[15]=(0,0,0),rgb[16]=(0,0,0),rgb[17]=(0,0,0)
//
//	 SetDataFolder $CurrentFolder
//
//End

//***********************************************************Generic plot not for fainharted
Function IN2P_GenericUSAXSPlots()

	IN2G_UniversalFolderScan("root:USAXS:", 5, "IN2G_CheckTheFolderName()")  //here we fix the folder names/sample names in wave notes if necessary
	
		String WorkingDataFolder
		Prompt WorkingDataFolder, "Select  data folder for sample", popup,IN2G_FindFolderWithWaveTypes("root:USAXS:", 7, "*", 1)+";"+IN2G_FindFolderWithWaveTypes("root:Others:", 5, "*", 1)+";"+IN2G_FindFolderWithWaveTypes("root:raw:", 5, "*", 1)
	
		DoPrompt "Generic USAXS Plot want to know:", WorkingDataFolder
		if (V_Flag)
			Abort
		endif
		SetDataFolder WorkingDataFolder							//sets working directory to sample

		String DataY,DataX,PlotType, DataError
		Prompt DataY, "Data type to plot on Y axis", popup, wavelist("*",";","")
		Prompt DataX, "Data type to plot on X axis", popup, wavelist("*",";","")
		Prompt DataError, "Data typefor error bars", popup, "none;"+wavelist("*",";","")
		Prompt PlotType, "Type of plot ?", popup, "Log-Log;Porod(-4);Porod(-3);LogY-LinX;LinY-LogX;Lin-Lin;IQ4vsQ;IQ3vsQ"
	
		DoPrompt "Select waves for Generic plot:", DataY, DataX, DataError, PlotType
		if (V_Flag)
			Abort
		endif
	
	string/G root:Packages:Indra3:GenericPlotType=PlotType
	string/G root:Packages:Indra3:GenericPlotDataY=DataY
	string/G root:Packages:Indra3:GenericPlotDataX=DataX
	string/G root:Packages:Indra3:GenericPlotDataError=DataError
	
	//********************generate new data if necessary
	Wave WaveY=$DataY
	Wave WaveX=$DataX
	
	Duplicate/O WaveY, root:Packages:Indra3:GenericPlotY
	Duplicate/O WaveX, root:Packages:Indra3:GenericPlotX
	
	Wave WaveYInPckgs= root:Packages:Indra3:GenericPlotY
	Wave WaveXInPckgs= root:Packages:Indra3:GenericPlotX
	
	if (cmpstr("none", DataError)!=0)
		Wave WaveError=$DataError
		Duplicate/O WaveError, root:Packages:Indra3:GenericPlotError
		Wave WaveErrorInPckgs=root:Packages:Indra3:GenericPlotError
	endif
	
	String GraphTitleString= "Plot of any wave to any wave"
	String LeftAxisLabel
	String BottomAxisLabel

		LeftAxisLabel=DataY
		BottomAxisLabel=DataX
	
	if (cmpstr(PlotType,"IQ4vsQ")==0)							//Porod IQ4 vs Q Plot for pinhole collimation
		//generate new waves
		WaveYInPckgs=WaveYInPckgs*WaveXInPckgs^4
		GraphTitleString= "IQ4 vs Q - pin hole"
		if (cmpstr(DataError,"none")!=0)
		 	WaveErrorInPckgs=WaveErrorInPckgs*WaveXInPckgs^4	
		endif
		LeftAxisLabel=DataY+"*"+DataX+"^4"
		BottomAxisLabel=DataX
	endif

	if (cmpstr(PlotType,"IQ3vsQ")==0)							//Porod IQ3 vs Q Plot for pinhole collimation
		//generate new waves
		WaveYInPckgs=WaveYInPckgs*WaveXInPckgs^3
		GraphTitleString= "IQ3 vs Q - slit smeared"
		if (cmpstr(DataError,"none")!=0)
		 	WaveErrorInPckgs=WaveErrorInPckgs*WaveXInPckgs^3	
		endif
		LeftAxisLabel=DataY+"*"+DataX+"^3"
		BottomAxisLabel=DataX
	endif

	
	if (cmpstr(PlotType,"Porod(-4)")==0)							//Porod Plot for pinhole collimation
		//generate new waves
		WaveXInPckgs=WaveXInPckgs^4
		WaveYInPckgs=WaveYInPckgs*WaveXInPckgs
		GraphTitleString= "Porod Plot for pin hole geometry"
		if (cmpstr(DataError,"none")!=0)
		 	WaveErrorInPckgs=WaveErrorInPckgs*WaveXInPckgs	
		endif
		LeftAxisLabel=DataY+"*"+DataX+"^4"
		BottomAxisLabel=DataX+"^4"
	endif

	if (cmpstr(PlotType,"Porod(-3)")==0)							//Porod Plot for pinhole collimation
		//generate new waves
		WaveXInPckgs=WaveXInPckgs^3
		WaveYInPckgs=WaveYInPckgs*WaveXInPckgs
		GraphTitleString= "Porod Plot for slit smear geometry"
		if (cmpstr(DataError,"none")!=0)
		 	WaveErrorInPckgs=WaveErrorInPckgs*WaveXInPckgs	
		endif
		LeftAxisLabel=DataY+"*"+DataX+"^3"
		BottomAxisLabel=DataX+"3"
	endif

	KillWIndow/Z GenericPlot
 	
 	PauseUpdate    //*************************Graph section**********************************
	Display/k=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("height"),60*IN2G_ScreenWidthHeight("width"),70*IN2G_ScreenWidthHeight("height")) WaveYInPckgs vs WaveXInPckgs	as GraphTitleString								//I like graphs
	DoWindow/C GenericPlot
	ModifyGraph mode=4,	margin(top)=100, mirror=1, minor=1
	showinfo												//shows info
	Label left LeftAxisLabel								//labels left axis
	Label bottom BottomAxisLabel							//labels bottom axis
	ShowTools/A											//show tools
	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
	 IN2G_GenerateLegendForGraph(10,1,0)

	if (cmpstr(DataError,"none")!=0)
		ErrorBars $(StringFromList(0, TraceNameList("",";",1))) Y,wave=(WaveErrorInPckgs,WaveErrorInPckgs) 	
	endif

	if (cmpstr(PlotType,"Log-Log")==0)								//axis to log-log
		ModifyGraph log=1
	endif
	if (cmpstr(PlotType,"LinY-LogX")==0)							//axis to logx-liny
		ModifyGraph log(bottom)=1
	endif
	if (cmpstr(PlotType,"LogY-LinX")==0)							//axis to linx-logy
		ModifyGraph log(left)=1
	endif
		
	Button KillThisWindow pos={10,10}, size={100,25}, title="Kill window", proc=IN2P_KillTopGraph
	Button ResetWindow pos={10,50}, size={100,25}, title="Reset window", proc= IN2G_ResetGraph
	Button AddAnotherWaveGeneric pos={150,10}, size={150,25}, title="Add another data", proc=IN2P_AddAnotherWaveGeneric
	Button FitLine pos={150,50}, size={150,25}, title="Fit line w/cursors", proc=IN2P_FitLineWithCursorsBtn
	
	ResumeUpdate   //*************************Graph section**********************************
	ModifyGraph msize=2,width=0, height=0
End

Function IN2P_KillTopGraph(ctrlname) :Buttoncontrol
	string ctrlname
       String wName=WinName(0, 1)              // 1=graphs, 2=tables,4=layouts
       dowindow /K $wName
	IN2G_CleanupFolderOfGenWaves("root:Packages:Indra3")				//lets cleanup the folder first
End
Function IN2P_FitLineWithCursorsBtn(ctrlname) :Buttoncontrol
	string ctrlname

	Execute ("IN2P_FitPowerLawWithCursors()")
End


Function IN2P_AddAnotherWaveGeneric(ctrlname) : Buttoncontrol			
	string ctrlname

	SVAR PlotType=root:Packages:Indra3:GenericPlotType
	SVAR DataY=root:Packages:Indra3:GenericPlotDataY
	SVAR DataX=root:Packages:Indra3:GenericPlotDataX
	SVAR DataError=root:Packages:Indra3:GenericPlotDataError
	SVAR PlotName=root:Packages:Indra3:GenericPlotName

	string ListOfFolders=IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, DataY+"*", 1)
	string NewDataFldr
	
	Prompt NewDataFldr, "Add Data from folder ?", popup, ListOfFolders
	
	DoPrompt "Add data to generic graph",  NewDataFldr
	if (V_Flag)
			Abort
	endif
	
	Wave SourceY= $(NewDataFldr+DataY)
	Wave SourceX= $(NewDataFldr+DataX)
	if (cmpstr(DataError,"none")!=0)
		Wave SourceError= $(NewDataFldr+DataError)
	endif
	
	string dfold=GetDataFolder(1)
	setDataFolder root:Packages:Indra3
	
	IN2G_CleanupFolderOfGenWaves("root:Packages:Indra3")				//lets cleanup the folder first
	
	string NewYWaveName=UniqueName("GenericYwave",1,0)
	string NewXWaveName=UniqueName("GenericXwave",1,0)
	string NewEWaveName=UniqueName("GenericEwave",1,0)
	
	Duplicate SourceY, $NewYWaveName
	Duplicate SourceX, $NewXWaveName
	if (cmpstr(DataError,"none")!=0)
		Duplicate SourceError, $NewEWaveName
		Wave NewDataError=$NewEWaveName
	endif
	Wave NewDataY=$NewYWaveName
	Wave NewDataX=$NewXWaveName
	
	if (cmpstr(PlotType,"IQ4vsQ")==0)							//Porod IQ4 vs Q Plot for pinhole collimation
		NewDataY=NewDataY*NewDataX^4
		if (cmpstr(DataError,"none")!=0)
		 	NewDataError=NewDataError*NewDataX^4	
		endif
	endif

	if (cmpstr(PlotType,"IQ3vsQ")==0)							//Porod IQ3 vs Q Plot for pinhole collimation
		NewDataY=NewDataY*NewDataX^3
		if (cmpstr(DataError,"none")!=0)
		 	NewDataError=NewDataError*NewDataX^3	
		endif
	endif

	
	if (cmpstr(PlotType,"Porod(-4)")==0)							//Porod Plot for pinhole collimation
		NewDataX=NewDataX^4
		NewDataY=NewDataY*NewDataX
		if (cmpstr(DataError,"none")!=0)
		 	NewDataError=NewDataError*NewDataX	
		endif
	endif

	if (cmpstr(PlotType,"Porod(-3)")==0)							//Porod Plot for pinhole collimation
		NewDataX=NewDataX^3
		NewDataY=NewDataY*NewDataX
		if (cmpstr(DataError,"none")!=0)
		 	NewDataError=NewDataError*NewDataX	
		endif
	endif

	AppendToGraph/W=GenericPlot NewDataY vs NewDataX
	if (cmpstr(DataError,"none")!=0)
	 	ErrorBars $NewYWaveName Y,wave=(NewDataError,NewDataError) 
	endif
	 
	ModifyGraph/Z mode=4, marker[0]=1, marker[1]=3,marker[2]=5, marker[3]=7,marker[4]=9, marker[5]=11,marker[6]=13, marker[7]=30,marker[8]=35
	ModifyGraph/Z rgb[0]=(0,0,0),rgb[1]=(65280,16320,16320),rgb[2]=(65280,50000,16320),rgb[3]=(16320,65280,65280), rgb[4]=(0,43520,65280),rgb[5]=(32640,65280,0),rgb[6]=(0,32640,0),rgb[7]=(0,16320,65280),rgb[8]=(65280,0,52240)
	ModifyGraph/Z rgb[9]=(0,0,0),rgb[10]=(65280,0,0),rgb[11]=(0,0,0),rgb[12]=(0,0,0), rgb[13]=(0,0,0),rgb[14]=(0,0,0),rgb[15]=(0,0,0),rgb[16]=(0,0,0),rgb[17]=(0,0,0)

	IN2G_GenerateLegendForGraph(10,1,1)
	ModifyGraph msize=2
	setDataFolder dfold
End
//*************************************************Functions
//Function KillGenericGraph(ctrlname) : Buttoncontrol			
//	string ctrlname
//	
//	variable bla=1
//	string TestFolder
//	SVAR GraphType=root:GraphType
//	string OldDataFolder=GetDataFolder(1)
//
//      String wName=WinName(0, 1)              // 1=graphs, 2=tables,4=layouts
//       dowindow /K $wName
//	
//	Do
//		TestFolder=stringByKey("FOLDER"+num2str(bla), GraphType,":",";")
//		SetDataFolder TestFolder
//		killwaves/Z PlotNewYwave, PlotNewXwave,PlotNewErrorwave 
//		variable i=1
//		string Xname, Yname, Ename
//		Do
//			Yname="PlotNewYwave"+num2str(i)
//			Xname="PlotNewXwave"+num2str(i)
//			Ename="PlotNewErrorwave"+num2str(i)
//			killwaves/Z $Yname, $Xname, $Ename 
//			i=i+1
//		while (i<12)
//      		bla+=1
//	while (strlen(stringByKey("FOLDER"+num2str(bla), GraphType,":",";"))!=0) 
//       
//      KillStrings/Z root:GraphType
//       
//      SetDataFolder(OldDataFolder)
//End
//
////**********************************
//

//
//
//// ******************************************************************Add more data*****************************************
//Proc AddAnotherWaveMacroGeneric(WorkingDataFolder)
//			String WorkingDataFolder
//			Prompt WorkingDataFolder, "Select  data folder for new data", popup,FindPathAndComments("root:", "USAXS_PD", 33)
//	
//		SetDataFolder StringFromList(0,WorkingDataFolder, ",")							//sets working directory to sample
//
//
//
//	String ScanTypeBucketY,ScanTypeBucketX, PlotType, ScanTypeBucketError, bucket1
//		 ScanTypeBucketY=stringByKey("YAXIS", root:GraphType,":",";")
//		 ScanTypeBucketX=stringByKey("XAXIS", root:GraphType,":",";")
//		 ScanTypeBucketError=stringByKey("ERROR", root:GraphType,":",";")
//		 PlotType=stringByKey("PLOTYPE", root:GraphType,":",";")
//	
//	variable numberOfWaves=1
//	
//	Do
//		numberOfWaves+=1
//		bucket1=stringByKey("FOLDER"+num2str(numberOfWaves), root:GraphType,":",";")
//	while (strlen(bucket1)!=0)
//	
//	root:GraphType=ReplaceStringByKey("FOLDER"+num2str(numberOfWaves), root:GraphType, GetDataFolder(1), ":",";")
//	Silent 1	
//	
//	//********************generate new data if necessary
//	string  PlotNewYwaveString="PlotNewYwave"+num2str(numberOfWaves)
//	string  PlotNewXwaveString="PlotNewXwave"+num2str(numberOfWaves)
//	
//	if (exists(ScanTypeBucketY)==1)
//		Make/D/O/N=(numpnts($ScanTypeBucketY)) $PlotNewYwaveString=$ScanTypeBucketY
//	else
//		Abort ("The Y data do not exist on the specified datafolder")
//	endif
//	if (exists(ScanTypeBucketX)==1)
//		Make/D/O/N=(numpnts($ScanTypeBucketX)) $PlotNewXwaveString=$ScanTypeBucketX
//	else
//		Abort ("The X data do not exist on the specified datafolder")
//	endif
//	
//	if (cmpstr(ScanTypeBucketError,"none")!=0)
//		if (exists(ScanTypeBucketError)==1)
//			string  PlotNewErrorwaveString="PlotNewErrorwave"+num2str(numberOfWaves)
//			Make/D/O/N=(numpnts($ScanTypeBucketError)) $PlotNewErrorwaveString=$ScanTypeBucketError
//		else
//			Abort ("The Error data do not exist in the specified datafolder")
//		endif	
//	endif		
//
//	if (cmpstr(PlotType,"IQ4vsQ")==0)							//Porod IQ4 vs Q Plot for pinhole collimation
//		//generate new waves
//		$PlotNewYwaveString=$PlotNewYwaveString*$PlotNewXwaveString^4
//		if (cmpstr(ScanTypeBucketError,"none")!=0)
//		 	$PlotNewErrorwaveString=$PlotNewErrorwaveString*$PlotNewXwaveString^4	
//		endif
//	endif
//
//	if (cmpstr(PlotType,"IQ3vsQ")==0)							//Porod IQ3 vs Q Plot for pinhole collimation
//		//generate new waves
//		$PlotNewYwaveString=$PlotNewYwaveString*$PlotNewXwaveString^3
//		if (cmpstr(ScanTypeBucketError,"none")!=0)
//		 	$PlotNewErrorwaveString=$PlotNewErrorwaveString*$PlotNewXwaveString^3	
//		endif
//	endif
//
//	
//	if (cmpstr(PlotType,"Porod(-4)")==0)							//Porod Plot for pinhole collimation
//		//generate new waves
//		$PlotNewXwaveString=$PlotNewXwaveString^4
//		$PlotNewYwaveString=$PlotNewYwaveString*$PlotNewXwaveString
//		if (cmpstr(ScanTypeBucketError,"none")!=0)
//		 	$PlotNewErrorwaveString=$PlotNewErrorwaveString*$PlotNewXwaveString	
//		endif
//	endif
//
//	if (cmpstr(PlotType,"Porod(-3)")==0)							//Porod Plot for pinhole collimation
//		//generate new waves
//		$PlotNewXwaveString=$PlotNewXwaveString^3
//		$PlotNewYwaveString=$PlotNewYwaveString*$PlotNewXwaveString
//		if (cmpstr(ScanTypeBucketError,"none")!=0)
//		 	$PlotNewErrorwaveString=$PlotNewErrorwaveString*$PlotNewXwaveString	
//		endif
//	endif
//
//
// 	PauseUpdate    //*************************Graph section**********************************
//	AppendToGraph $PlotNewYwaveString vs $PlotNewXwaveString					
//
//	ModifyGraph/Z msize=2, mode=4, marker[0]=1, marker[1]=3,marker[2]=5, marker[3]=7,marker[4]=9, marker[5]=11,marker[6]=13, marker[7]=30,marker[8]=35
//	ModifyGraph/Z rgb[0]=(0,0,0),rgb[1]=(65280,16320,16320),rgb[2]=(65280,50000,16320),rgb[3]=(16320,65280,65280), rgb[4]=(0,43520,65280),rgb[5]=(32640,65280,0),rgb[6]=(0,32640,0),rgb[7]=(0,16320,65280),rgb[8]=(65280,0,52240)
//	ModifyGraph/Z rgb[9]=(0,0,0),rgb[10]=(65280,0,0),rgb[11]=(0,0,0),rgb[12]=(0,0,0), rgb[13]=(0,0,0),rgb[14]=(0,0,0),rgb[15]=(0,0,0),rgb[16]=(0,0,0),rgb[17]=(0,0,0)
//
//	//**************Tags
//	variable setpoint=(0.5*numpnts($PlotNewXwaveString))
//	string WavenameQ="PlotNewYwave#"+num2str(numberOfWaves-1)
//	string tagname="Tag"+num2str(numberOfWaves)
//	Tag/N=$tagname/F=0/A=LT $PlotNewYwaveString, setpoint, "\Z09"+ScanTypeBucketY+"  "+GetDataFolder(1)+SpecComment
//	//******************Legend
//	string CommentWithPath=StringByKey("FOLDER1", root:GraphType)+"SpecComment"
//	string LabelString="\\Z09\\s(PlotNewYwave) \t"+StringByKey("FOLDER1", root:GraphType)+$CommentWithPath
//
//	variable tagnumber=2
//	Do
//	CommentWithPath=StringByKey("FOLDER"+num2str(tagnumber), root:GraphType)+"SpecComment"
//	LabelString+="\r\\s(PlotNewYwave"+num2str(tagnumber)+") \t"+StringByKey("FOLDER"+num2str(tagnumber), root:GraphType)+$CommentWithPath
//	tagnumber+=1
//	while (tagnumber<numberOfWaves+1)
//	Legend/K/N=text1
//	Legend/N=text1/J/F=0/A=LB LabelString
//	ModifyGraph/Z rgb[0]=(0,0,0),rgb[1]=(65280,16320,16320),rgb[2]=(65280,50000,16320),rgb[3]=(16320,65280,65280), rgb[4]=(0,43520,65280),rgb[5]=(32640,65280,0),rgb[6]=(0,32640,0),rgb[7]=(0,16320,65280),rgb[8]=(65280,0,52240)
//	ModifyGraph/Z rgb[9]=(0,0,0),rgb[10]=(65280,0,0),rgb[11]=(0,0,0),rgb[12]=(0,0,0), rgb[13]=(0,0,0),rgb[14]=(0,0,0),rgb[15]=(0,0,0),rgb[16]=(0,0,0),rgb[17]=(0,0,0)
//	
//End
//
////******************************************Fitting routines

Proc IN2P_FitLineWithCursors()

	string destwavename="fit_"+CsrWave(A)
	CurveFit line CsrWaveRef(A)(xcsr(A),xcsr(B)) /X=CsrXWaveRef(A) /D
	Tag/C/N=Curvefitres/F=0/A=MC $destwavename, 0.5*numpnts($destwavename), "\Z09Linear fit parameters are: \ry="+num2str(W_coef[0])+"+ x *"+num2str(W_coef[1])
end

Proc IN2P_FitPowerLawWithCursors()

	string olddf=GetDataFolder(1)
	
	if (!DataFolderExists("root:Packages:FittingData:"))
		NewDataFolder root:Packages:FittingData		//create Desmear folder, if it does not exist
	endif

	setDataFolder root:Packages:FittingData
	
	string name="MyFitWave"
	string LegendName="Curvefitres"
	
	variable freeDestNum=IN2P_FindFreeDestWaveNumber(name)
	name=name +num2istr(freeDestNum)
	LegendName=LegendName+num2istr(freeDestNum)
	Make/D/O/N=(numpnts($(getWavesDataFolder(CsrWaveRef(A),2)))) LogYFitData, $name
	$name=NaN
	Make/D/O/N=(numpnts($(getWavesDataFolder(CsrXWaveRef(A),2)))) LogXFitData
	LogXFitData=log($(getWavesDataFolder(CsrXWaveRef(A),2)))
	LogYFitData=log($(getWavesDataFolder(CsrWaveRef(A),2)))
	CurveFit line LogYFitData(xcsr(A),xcsr(B)) /X=LogXFitData /D=$name
		
	IN2P_LogPowerWithNaNsRetained($name)
	
	//here we will try to figure out, if the data are plotted wrt to leftor right axis...
	string YwvName=CsrWave(A)
	string AxType=StringByKey("AXISFLAGS", TraceInfo("",YwvName,0) )//this checks only for first occurence of the wave with this name
	//this needs to be made more clever, other axis and other occurenc es of the wave with the name...
	if (cmpstr(AxType,"/R")==0)
		Append/R $name vs CsrXWaveRef(A)
	else
		Append $name vs CsrXWaveRef(A)
	endif
	Modify lsize($name)=2
	String pw=num2str(K1),pr=num2str(10^K0),DIN=num2str((V_siga*10^K0)/2.3026),ca=num2str(pcsr(A)),cb=num2str(pcsr(B)),gf=num2str(V_Pr),DP=num2str(V_sigb)
	Tag/C/N=$LegendName/F=0/A=MC  $name, (pcsr(A)+pcsr(B))/2, "\Z10Power Law Slope= "+pw+"\Z10 ± "+DP+"\Z08\rPrefactor= "+pr+"\Z08 cm\S-1\M\Z08 ± "+DIN+"\Z08\rx Cursor A::B= "+ca+"\Z08 :: "+cb+"\Z08\rGoodness of fit= "+gf

	KillWaves/Z LogYFitData, LogXFitData

	SetDataFolder $olddf
end

Function IN2P_FindFreeDestWaveNumber(name)
	string name
	
	variable i=0
	Do
		if (exists(name+num2istr(i))==0)
			return i
		endif
	i+=1
	while (i<50)
end

Function IN2P_LogPowerWithNaNsRetained(MyFitWave)
	wave MyFitWave
	
	variable PointsNumber=numpnts(MyFitWave)
	variable i=0
	Do
		if (numtype(MyFitWave[i])==0)
			MyFitWave[i]=10^(MyFitWave[i])
		endif
	i+=1
	while (i<PointsNumber-1)
end