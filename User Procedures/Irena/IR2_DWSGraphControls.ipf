#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=1		// Use modern global access method.
#pragma version 1.01



// 1.01 changed way error bars are added and added SMR error bars capability.  




function IR2D_DWSStripQuoteFromQRSnames()
		SVAR Dtf=root:Packages:Irena:DWSplottingTool:DataFolderName
		SVAR IntDf=root:Packages:Irena:DWSplottingTool:IntensityWaveName
		SVAR QDf=root:Packages:Irena:DWSplottingTool:QWaveName
		SVAR EDf=root:Packages:Irena:DWSplottingTool:ErrorWaveName
		IntDf =ReplaceString("'", IntDf, "")
		QDf =ReplaceString("'", QDf, "")
		EDf =ReplaceString("'", EDf, "")
End



Function IR2D_DWSFixAxesInGraph()//keep

	NVAR GraphLeftAxisAuto=root:Packages:Irena:DWSplottingTool:GraphLeftAxisAuto
	NVAR GraphLeftAxisMin=root:Packages:Irena:DWSplottingTool:GraphLeftAxisMin
	NVAR GraphLeftAxisMax=root:Packages:Irena:DWSplottingTool:GraphLeftAxisMax
	NVAR GraphBottomAxisAuto=root:Packages:Irena:DWSplottingTool:GraphBottomAxisAuto
	NVAR GraphBottomAxisMin=root:Packages:Irena:DWSplottingTool:GraphBottomAxisMin
	NVAR GraphBottomAxisMax=root:Packages:Irena:DWSplottingTool:GraphBottomAxisMax
	SVAR ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
		GetAxis/Q left
		if (V_Flag)
			abort
		endif
	
	if (GraphLeftAxisAuto)	//autoscale left axis
		SetAxis/A left
		DoUpdate
		GetAxis /Q left
		GraphLeftAxisMin=V_min
		GraphLeftAxisMax=V_max
		ListOfGraphFormating=ReplaceNumberByKey("Axis left min",ListOfGraphFormating, GraphLeftAxisMin,"=")
		ListOfGraphFormating=ReplaceNumberByKey("Axis left max",ListOfGraphFormating, GraphLeftAxisMax,"=")

	else		//fixed left axis
		SetAxis left GraphLeftAxisMin,GraphLeftAxisMax

	endif
	
	if (GraphBottomAxisAuto)	//autoscale bottom axis
		SetAxis/A bottom
		DoUpdate
		GetAxis  /Q bottom
		GraphBottomAxisMin=V_min
		GraphBottomAxisMax=V_max
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom min",ListOfGraphFormating, GraphBottomAxisMin,"=")
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom max",ListOfGraphFormating, GraphBottomAxisMax,"=")
	else		//fixed bottom axis
		SetAxis bottom GraphBottomAxisMin,GraphBottomAxisMax

	endif
end


function IR2D_DWSAttachErrorBars()
	string tracelist,activetrace,folderpath,ewave
	tracelist=TraceNameList("",";",1)
	variable i=0,total=ItemsInList(tracelist)
	SVAR ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
	
		do
			activetrace =StringFromList(i, tracelist)
			activetrace=ReplaceString("'", activetrace, "" )
			folderpath =getwavesDataFolder(TraceNameToWaveRef("", activetrace),1)
			setdatafolder folderpath
			if(!NumberByKey("ErrorBars",ListOfGraphFormating,"="))
				Errorbars $activetrace OFF;delayUpdate	
			else
				if (Stringmatch (activetrace,"M_DSM_int*"))
					if (waveexists(M_DSM_Error))
						ErrorBars/T=0/L=1.2 $activetrace Y,wave=(M_DSM_Error,M_DSM_Error);DelayUpdate
					endif
				elseif (Stringmatch (activetrace,"*DSM_int*"))
					if (waveexists(DSM_Error))
						ErrorBars/T=0/L=1.2 $activetrace Y,wave=(DSM_Error,DSM_Error);DelayUpdate
					endif
				elseif (Stringmatch (activetrace,"M_SMR_int*"))
					if (waveexists(M_SMR_Error))
						ErrorBars/T=0/L=1.2 $activetrace Y,wave=(M_SMR_Error,M_SMR_Error);DelayUpdate
					endif
				elseif (Stringmatch (activetrace,"*SMR_int*"))
					if (waveexists(SMR_Error))
						ErrorBars/T=0/L=1.2 $activetrace Y,wave=(SMR_Error,SMR_Error);DelayUpdate
					endif
				elseif (Stringmatch (activetrace,"R*"))
					ewave="s"+activetrace[1,32]
					if (waveexists($ewave))
						ErrorBars/T=0/L=1.2 $activetrace Y,wave=($ewave,$ewave);DelayUpdate
					endif
				endif
			endif
			i+=1
		while (i<total)
end

function IR2D_DWSFormatGraph(addlabels)
	variable addlabels
	SVAR ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
	If (!exists(ListOfGraphFormating)==0)
		IR2D_InitializeDWSGraph()
	endif
	
	
	variable lines, markers,colors
	lines= NumberByKey("Graph use Lines", ListOfGraphFormating,"=",";")
	markers= NumberByKey("Graph use Symbols", ListOfGraphFormating,"=",";")
	colors= NumberByKey("Graph use Colors", ListOfGraphFormating,"=",";")
	//ModifyGraph log(bottom)=NumberByKey("log(bottom)", ListOfGraphFormating,"=",";")
	//ModifyGraph log(left)=NumberByKey("log(left)", ListOfGraphFormating,"=",";")
	//ModifyGraph axThick=NumberByKey("axthick", ListOfGraphFormating,"=",";")
	ModifyGraph msize=NumberByKey("msize", ListOfGraphFormating,"=",";")
	ModifyGraph lsize=NumberByKey("lsize", ListOfGraphFormating,"=",";")
	//if (lines==1)

	//ModifyGraph grid(bottom)=NumberByKey("grid(bottom)", ListOfGraphFormating,"=",";")
	//ModifyGraph grid(left)=NumberByKey("grid(left)", ListOfGraphFormating,"=",";")
	SVAR xname=root:Packages:Irena:DWSplottingTool:GraphXAxisName
	SVAR yname=root:Packages:Irena:DWSplottingTool:GraphyAxisName
	If(addlabels)	
		Label bottom xname
		Label left yname
	endif
		

	IR2D_DWSAttachLegend()//NumberByKey("Legend",ListOfGraphFormating,"="))
	//DWS_AttachErrorBars()
	//DWS_FixAxesInGraph()
	variable mode=0
	if (markers)
		mode=3*markers+lines
	endif
	if ((markers!=0)||(lines!=0))
		IR2D_ChangetoLineandPoints(mode,colors)
	endif

	
end


function IR2D_DWSAttachLegend()
	variable type;string size
	
	SVAR ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
	size=StringByKey("Graph legend Size",ListOfGraphFormating,"=")
	Type=NumberByKey("Legend",ListOfGraphFormating,"=")
	variable NumberofWaves=ItemsInList(tracenamelist("",";",1))
	variable counter=0
	string theFolder,TheText, TheText2
	string list=TraceNameList("",";",1)
	theText="\Z"+size
	theText2=theText
	if ((type==2) ||(type==4))
		do
	string tracename=StringFromList(counter, list,";")//getstrfromlist (list, counter,";")
	
			theFolder=GetWavesDataFolder(WaveRefIndexed("",counter ,1),0)
			theText=theText+ "\r\s("+tracename+")"
			theText=theText+thefolder//theFolder[0,(strlen(theFolder)-0)]
			counter+=1
		while(counter<Numberofwaves)
		TextBox/C/A=RT/N=FolderLegend theText	
	endif	
	
	counter=0
	IF ((type==3)||(type==4))
		do
			tracename= StringFromList(counter, list,";")//getstrfromlist (list, counter,";")
			theText2=theText2+ "\r\s("+tracename+")"
			theText2=theText2+tracename
			counter+=1
		while(counter<Numberofwaves)
		TextBox/C/A=RB/N=WaveLegend theText2	
	endif	
		
End

static Function IR2D_DWSFindString2num(index,strings,separator)
	variable index//starts at 0
	string strings,separator
	
	variable pos1=0,pos2=0
	string answer
	variable counter=0
	do
		pos2=strsearch(strings,";",pos1)
		answer=strings[pos1,(pos2-1)]
		pos1=pos2+1
		counter+=1
	while(counter<(index+1))
	return(str2num(answer))
end

function IR2D_ChangetoLineandPoints(modetype,qcolors)//keep
	variable qcolors,modetype
	Prompt modetype, "Type of display", popup,"Lines;Sticks;Dots;Markers;Lines &Markers"
	Prompt qcolors,"Mixed Colors?",popup,"Colors;Grays;No"
	
	//Silent 1;pauseupdate
	string markertypes="19;17;16;23;18;8;5;6;22;7;0;1;2;25;26;28;29;15;14;4;3;17;16;23;18;8;5;6;22;7;0;1;2;25;26;28;29;15;14;4;3"
	string rcolortypes="65535;0;0;65535;52428;0;39321;52428;1;26214;65535;0;0;65535;52428;0;39321;52428;1;26214"
	string gcolortypes="0;0;65535;43690;1;0;13101;52425;24548;26214;65535;0;0;65535;52428;0;39321;52428;1;26214"
	string bcolortypes="0;65535;0;0;41942;0;1;1;52428;26214;65535;0;0;65535;52428;0;39321;52428;1;26214"
	string ListofWaves=TraceNameList("",";",1),wavename
	variable position1=strsearch(ListofWaves,";",0),position2=position1
	variable markpos1=strsearch(markertypes,";",0), markpos2=markpos1
	wavename=ListofWaves[0,(position1-1)]
	variable marktp=str2num(markertypes[0,(markpos1-1)])
	variable red=IR2D_DWSFindString2num(0,rcolortypes,";")
	variable green=IR2D_DWSFindString2num(0,gcolortypes,";")
	variable blue=IR2D_DWSFindString2num(0,bcolortypes,";")
	variable grey=0

	if(qcolors!=3)
		if(qcolors==1)
		//print "mode = "+num2str(modetype)
			ModifyGraph mode=modetype,marker($wavename)=marktp,rgb($wavename)=(red,green,blue)
		else
			ModifyGraph mode=modetype,marker($wavename)=marktp,rgb($wavename)=(grey,grey,grey)
		endif
	else
		ModifyGraph mode=modetype,marker($wavename)=marktp
	endif
	//
	variable length=strlen(ListofWaves)
	variable counter=1
	do
		position1=position2
		markpos1=markpos2
		position2=strsearch(ListofWaves,";",(position1+1))
		if(position2==-1)
			break
		endif
		markpos2=strsearch(markertypes,";",(markpos1+1))
		marktp=str2num(markertypes[(markpos1+1),(markpos2-1)])
		if(counter<=17)
			red=IR2D_DWSFindString2num(counter,rcolortypes,";")
			green=IR2D_DWSFindString2num(counter,gcolortypes,";")
			blue=IR2D_DWSFindString2num(counter,bcolortypes,";")
		else
			red=(counter-17)*1000
			green=(counter-17)*1000
			blue=(counter-17)*1000
		endif
		grey=counter*10000
		wavename=ListofWaves[(position1+1),(position2-1)]
		if(qcolors!=3)
			if(qcolors==1)
				ModifyGraph mode=modetype,marker($wavename)=marktp,rgb($wavename)=(red,green,blue)
			else
				ModifyGraph mode=modetype,marker($wavename)=marktp,rgb($wavename)=(grey,grey,grey)
			endif
		else
			ModifyGraph mode=modetype,marker($wavename)=marktp
		endif
		counter+=1
	while(position2!=(length-1))
EndMacro




Function IR2D_DWSInputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string ListOfVariables, listofstrings
		variable i
		if (!DataFolderExists("root:Packages:SAS_Modeling"))		
			NewDataFolder/O root:Packages
			NewDataFolder/O root:Packages:SAS_Modeling
		endif
		SetDataFolder root:Packages:SAS_Modeling					
		ListOfStrings="DataFolderName"
		ListOfVariables="Orientation;fold;SmallMon"
		for(i=0;i<itemsInList(ListOfVariables);i+=1)	
			IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
		endfor		
		for(i=0;i<itemsInList(ListOfStrings);i+=1)	
			IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
		endfor		
	
	variable IsAllAllRight

	if ((cmpstr(ctrlName,"AddDataToGraph")==0)||(cmpstr(ctrlName,"newgraph")==0))
		//here goes what is done, when user pushes Graph button
		SVAR ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
		SVAR DFloc=root:Packages:Irena:DWSplottingTool:DataFolderName
		SVAR DFInt=root:Packages:Irena:DWSplottingTool:IntensityWaveName
		SVAR DFQ=root:Packages:Irena:DWSplottingTool:QWaveName
		SVAR DFE=root:Packages:Irena:DWSplottingTool:ErrorWaveName
		IsAllAllRight=1
		if (cmpstr(DFloc,"---")==0 || strlen(DFloc)<=0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFInt,"---")==0 || strlen(DFInt)<=0)
			IsAllAllRight=0
		endif
		//if (cmpstr(DFQ,"---")==0 || strlen(DFQ)<=0)//qwave selection not required will use x-wave scaling
			//IsAllAllRight=0
		//endif
		//if (IsAllAllRight)
			//IR1P_RecordDataForGraph()  dws Nov
		//else
		//	Abort "Data not selected properly"
	//	endif
		if (cmpstr(ctrlName,"newgraph")==0)
			IR2D_DWSCreateGraph(1)   //create  the graph
		else
			IR2D_DWSCreateGraph(0)
		endif					
	endif	
	
	if (cmpstr(ctrlName,"SaveGraph")==0)
		string top= StringFromList(0,WinList("*", ";", "WIN:1"))
		DoWindow/F $top
		string cmd= "DoIgorMenu  \"Control\", \"Window control\""
		execute/P cmd
	endif
	
	if (cmpstr(ctrlName,"Standard")==0)
		execute "IR2D_DWSStdGraph()"//(width,maxY,minY,BW,ylabel,xlabel,modetype,aspect)
	endif
	
	if (cmpstr(ctrlName,"Capture")==0)
		GetAxis /Q left
		SVAR ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
		NVAR GraphLeftAxisAuto=root:Packages:Irena:DWSplottingTool:GraphLeftAxisAuto
		NVAR GraphLeftAxisMin=root:Packages:Irena:DWSplottingTool:GraphLeftAxisMin
		NVAR GraphLeftAxisMax=root:Packages:Irena:DWSplottingTool:GraphLeftAxisMax
		NVAR GraphBottomAxisAuto=root:Packages:Irena:DWSplottingTool:GraphBottomAxisAuto
		NVAR GraphBottomAxisMin=root:Packages:Irena:DWSplottingTool:GraphBottomAxisMin
		NVAR GraphBottomAxisMax=root:Packages:Irena:DWSplottingTool:GraphBottomAxisMax
		GraphLeftAxisMin=V_min
		GraphLeftAxisMax=V_max
		ListOfGraphFormating=ReplaceNumberByKey("Axis left min",ListOfGraphFormating, GraphLeftAxisMin,"=")
		ListOfGraphFormating=ReplaceNumberByKey("Axis left max",ListOfGraphFormating, GraphLeftAxisMax,"=")
		GetAxis  /Q bottom
		GraphBottomAxisMin=V_min
		GraphBottomAxisMax=V_max
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom min",ListOfGraphFormating, GraphBottomAxisMin,"=")
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom max",ListOfGraphFormating, GraphBottomAxisMax,"=")
	endif	
	
	if (cmpstr(ctrlName,"Format")==0)
		IR2D_DWSFormatGraph(0)
	endif
	
	if (cmpstr(ctrlName,"Legends")==0)
		IR2D_DWSAttachLegend()
	endif
	
	if (cmpstr(ctrlName,"killLegends")==0)
			NVAR GraphLegendUseFolderNms=root:Packages:Irena:DWSplottingTool:GraphLegendUseFolderNms
			NVAR GraphLegendUseWaveNote=root:Packages:Irena:DWSplottingTool:GraphLegendUseWaveNote		
		if(GraphLegendUseFolderNms==0)
			TextBox/K/N=FolderLegend
		endif
		if (GraphLegendUseWaveNote==0)
			TextBox/K/N=waveLegend
		endif
		IR2D_DWSAttachLegend()
	endif
	
	if (cmpstr(ctrlName,"ChangeAx")==0)
		IR2D_DWSFixAxesInGraph()
	endif
	
	if (cmpstr(ctrlName,"Hermans1")==0)	
		SVAR DFLoc2=root:Packages:SAS_Modeling:DataFolderName
		setdatafolder DFLoc2
		NVAR Fold=root:Packages:SAS_Modeling:fold
		fold = 0
		execute "HermansPanel()"
	endif
	
	if (cmpstr(ctrlName,"Hermans")==0)	
		
		SVAR DFLoc1=root:Packages:Irena:DWSplottingTool:DataFolderName
		SVAR DFLoc2=root:Packages:SAS_Modeling:DataFolderName
		DFLoc2=DFloc1
		setdatafolder DFLoc2
		string rwave="AnisointensityCorr", xwave= "sa"
		NVAR Orientation =root:Packages:SAS_Modeling:Orientation
		NVAR Fold=root:Packages:SAS_Modeling:fold
		orientation = 0
		fold = 0
		execute "UNICAT_AzimuthalPanel()"
	endif
end
//static function IR2D_DWSAttachErrorBars()
//	string tracelist,activetrace,folderpath,ewave
//	tracelist=TraceNameList("",";",1)
//	variable i=0,total=ItemsInList(tracelist)
//	SVAR ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
//	
//		do
//			activetrace =StringFromList(i, tracelist)
//			activetrace=ReplaceString("'", activetrace, "" )
//			folderpath =getwavesDataFolder(TraceNameToWaveRef("", activetrace),1)
//			setdatafolder folderpath
//			if(!NumberByKey("ErrorBars",ListOfGraphFormating,"="))
//				Errorbars $activetrace OFF;delayUpdate	
//			else
//				if (Stringmatch (activetrace,"M_DSM_int*"))
//					if (waveexists(M_DSM_Error))
//						ErrorBars $activetrace Y,wave=(M_DSM_Error,M_DSM_Error);DelayUpdate
//					endif
//				elseif (Stringmatch (activetrace,"*DSM_int*"))
//					if (waveexists(DSM_Error))
//						ErrorBars $activetrace Y,wave=(DSM_Error,DSM_Error);DelayUpdate
//					endif
//				elseif (Stringmatch (activetrace,"R*"))
//					ewave="s"+activetrace[1,32]
//					if (waveexists($ewave))
//						ErrorBars $activetrace Y,wave=($ewave,$ewave);DelayUpdate
//					endif
//				endif
//			endif
//			i+=1
//		while (i<total)
//end


function IR2D_DWSPanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if (cmpstr(ctrlName,"GraphLegendSize")==0)
		//here goes what needs to be done, when we select this popup...
		NVAR GraphLegendSize=root:Packages:Irena:DWSplottingTool:GraphlegendSize
		GraphlegendSize=str2num(popStr)
		SVAR ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating	//this contains data formating
		ListOfGraphFormating=ReplaceStringByKey("Graph legend size", ListOfGraphFormating, popstr,"=")
		IR2D_DWSInputPanelButtonProc("Legends")
	endif
	
end


Function IR2D_DWSGenPlotCheckBox(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	string folder=getdatafolder(1)
	SVAR 	ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
	if (cmpstr("GraphLogX",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("log(bottom)",ListOfGraphFormating, num2str(checked),"=")
		ModifyGraph log(bottom)=checked	
	endif	
	if (cmpstr("GraphLogy",ctrlName)==0)
		ListOfGraphFormating=ReplaceStringByKey("log(left)",ListOfGraphFormating, num2str(checked),"=")
		ModifyGraph log(left)=checked
	endif	
	if (cmpstr("GraphErrors",ctrlName)==0)
		ListOfGraphFormating=ReplaceStringByKey("ErrorBars",ListOfGraphFormating, num2str(checked),"=")
		IR2D_DWSAttachErrorBars()
	endif	
	if (cmpstr("GraphLegend",ctrlName)==0)
		//anything needs to be done here?
		if(checked)
			NVAR GraphLegendUseFolderNms=root:Packages:Irena:DWSplottingTool:GraphLegendUseFolderNms
			NVAR GraphLegendUseWaveNote=root:Packages:Irena:DWSplottingTool:GraphLegendUseWaveNote
			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(checked+GraphLegendUseFolderNms+2*GraphLegendUseWaveNote),"=")
		else
			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(checked),"=")
		endif
	endif
	variable UseLegend
	if (cmpstr("GraphLegendUseFolderNms",ctrlName)==0)
		//anything needs to be done here?
		UseLegend=NumberByKey("Legend",ListOfGraphFormating,"=")
		if (UseLegend)
			NVAR GraphLegendUseFolderNms=root:Packages:Irena:DWSplottingTool:GraphLegendUseFolderNms
			NVAR GraphLegendUseWaveNote=root:Packages:Irena:DWSplottingTool:GraphLegendUseWaveNote
			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(1+GraphLegendUseFolderNms+2*GraphLegendUseWaveNote),"=")
		endif
		if(!checked)
			IR2D_DWSInputPanelButtonProc("KillLegends")
		else
			IR2D_DWSInputPanelButtonProc("Legends")
		endif
	endif
	if (cmpstr("GraphLegendUseWaveNote",ctrlName)==0)
		//anything needs to be done here?
		UseLegend=NumberByKey("Legend",ListOfGraphFormating,"=")
		if (UseLegend)
			NVAR GraphLegendUseFolderNms=root:Packages:Irena:DWSplottingTool:GraphLegendUseFolderNms
			NVAR GraphLegendUseWaveNote=root:Packages:Irena:DWSplottingTool:GraphLegendUseWaveNote
			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(1+GraphLegendUseFolderNms+2*GraphLegendUseWaveNote),"=")
		endif
		if(!checked)
			IR2D_DWSInputPanelButtonProc("KillLegends")
		else
			IR2D_DWSInputPanelButtonProc("Legends")
		endif
	endif
	
	if (cmpstr("GraphUseSymbols",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph use Symbols",ListOfGraphFormating, num2str(checked),"=")
		variable UseLinesAlso=NumberByKey("Graph use Lines",ListOfGraphFormating,"=",";")
		IR2D_DWSInputPanelButtonProc("Format")
	endif
		
	if (cmpstr("GraphUseLines",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph use lines",ListOfGraphFormating, num2str(checked),"=")
		IR2D_DWSInputPanelButtonProc("Format")
	endif

	if (cmpstr("GraphUseColors",ctrlName)==0)
		//anything needs to be done here?
		checked+=1
		ListOfGraphFormating=ReplaceStringByKey("Graph use colors",ListOfGraphFormating, num2str(checked),"=")	
		IR2D_DWSInputPanelButtonProc("Format")
	endif
	
	if (cmpstr("GraphLeftAxisAuto",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Axis left auto",ListOfGraphFormating, num2str(checked),"=")
		IR2D_DWSFixAxesInGraph()
	endif
	if (cmpstr("GraphBottomAxisAuto",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Axis bottom auto",ListOfGraphFormating, num2str(checked),"=")
		IR2D_DWSFixAxesInGraph()
	endif
	if (cmpstr("GraphXMajorGrid",ctrlName)==0)
		//anything needs to be done here?   
		NVAR GraphXMajorGrid=root:Packages:Irena:DWSplottingTool:GraphXMajorGrid
		NVAR GraphXMinorGrid=root:Packages:Irena:DWSplottingTool:GraphXMinorGrid
		if (GraphXMajorGrid)
			if(GraphXMinorGrid)
				ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "1","=")
			else
				ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "2","=")
			endif
		else
			ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "0","=")
			GraphXMinorGrid=0
		endif
		
	endif
	if (cmpstr("GraphXMinorGrid",ctrlName)==0)
		//anything needs to be done here?
		NVAR GraphXMajorGrid=root:Packages:Irena:DWSplottingTool:GraphXMajorGrid
		NVAR GraphXMinorGrid=root:Packages:Irena:DWSplottingTool:GraphXMinorGrid
		ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "0","=")
		if (GraphXMinorGrid)
			GraphXMajorGrid=1
			ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "1","=")
		else
			if(GraphXMajorGrid) 
				ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "2","=")
			endif
		endif
	endif
	if (cmpstr("GraphYMajorGrid",ctrlName)==0)
			NVAR GraphYMajorGrid=root:Packages:Irena:DWSplottingTool:GraphYMajorGrid
			NVAR GraphYMinorGrid=root:Packages:Irena:DWSplottingTool:GraphYMinorGrid
			if (GraphYMajorGrid)
				if(GraphYMinorGrid)
					ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "1","=")
				else
					ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "2","=")
				endif
			else
				ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "0","=")
				GraphYMinorGrid=0
			endif
		
	endif
	if (cmpstr("GraphYMinorGrid",ctrlName)==0)
		
		NVAR GraphYMajorGrid=root:Packages:Irena:DWSplottingTool:GraphYMajorGrid
		NVAR GraphYMinorGrid=root:Packages:Irena:DWSplottingTool:GraphYMinorGrid
		ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "0","=")
		if (GraphYMinorGrid)
			GraphYMajorGrid=1
			ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "1","=")
		else
			if(GraphYMajorGrid) 
				ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "2","=")
			endif
		endif
		
	endif
	
	ModifyGraph grid(bottom)=NumberByKey("grid(bottom)", ListOfGraphFormating,"=",";")
	ModifyGraph grid(left)=NumberByKey("grid(left)", ListOfGraphFormating,"=",";")
	setdatafolder folder
DoUpdate

end

function IR2D_DWSSetVarProc(ctrlName,varNum,varStr,varName)

	String ctrlName
	Variable varNum
	String varStr
	String varName
	string folder= getdatafolder(1)
	SVAR 	ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
	
	if (cmpstr("GraphXAxisName",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Label bottom",ListOfGraphFormating, varStr,"=")
		Label bottom StringbyKey("Label bottom", ListOfGraphFormating,"=",";")
	
	endif
	if (cmpstr("GraphYAxisName",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Label left",ListOfGraphFormating, varStr,"=")
		Label left StringbyKey("Label left", ListOfGraphFormating,"=",";")
	endif
	
	if (cmpstr("GraphLineWidth",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("lsize",ListOfGraphFormating, varNum,"=")
		IR2D_DWSInputPanelButtonProc("Format")
	endif
		if (cmpstr("TicRotation",ctrlName)==0)
		ModifyGraph tkLblRot(left)=varNum	
	endif
	
	if (cmpstr("GraphSymbolSize",ctrlName)==0)
		ListOfGraphFormating=ReplaceNumberByKey("msize",ListOfGraphFormating, varNum,"=")
		IR2D_DWSInputPanelButtonProc("Format")
	endif
	
	if (cmpstr("GraphAxisWidth",ctrlName)==0)	
		ListOfGraphFormating=ReplaceNumberByKey("axThick",ListOfGraphFormating, varNum,"=")
		ModifyGraph axThick=varnum
		variable fontsize=(14*(Varnum==1))+(16*(varnum==2))+(18*(varnum==3))+(20*(varnum==4))
		ModifyGraph fSize=fontsize
		ModifyGraph fSize=fontsize
		ModifyGraph fSize=fontsize
	endif
	if (cmpstr("GraphLeftAxisMin",ctrlName)==0)		
		ListOfGraphFormating=ReplaceNumberByKey("Axis left min",ListOfGraphFormating, varNum,"=")
		IR2D_DWSFixAxesInGraph()
	endif
	if (cmpstr("GraphLeftAxisMax",ctrlName)==0)		
		ListOfGraphFormating=ReplaceNumberByKey("Axis left max",ListOfGraphFormating, varNum,"=")
		IR2D_DWSFixAxesInGraph()
	endif
	if (cmpstr("GraphBottomAxisMin",ctrlName)==0)
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom min",ListOfGraphFormating, varNum,"=")
		IR2D_DWSFixAxesInGraph()
	endif
	if (cmpstr("GraphBottomAxisMax",ctrlName)==0)		
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom max",ListOfGraphFormating, varNum,"=")
		IR2D_DWSFixAxesInGraph()
	endif
	setdatafolder folder
end

//static Function IR2D_DWSFixAxesInGraph()//keep
//
//	NVAR GraphLeftAxisAuto=root:Packages:Irena:DWSplottingTool:GraphLeftAxisAuto
//	NVAR GraphLeftAxisMin=root:Packages:Irena:DWSplottingTool:GraphLeftAxisMin
//	NVAR GraphLeftAxisMax=root:Packages:Irena:DWSplottingTool:GraphLeftAxisMax
//	NVAR GraphBottomAxisAuto=root:Packages:Irena:DWSplottingTool:GraphBottomAxisAuto
//	NVAR GraphBottomAxisMin=root:Packages:Irena:DWSplottingTool:GraphBottomAxisMin
//	NVAR GraphBottomAxisMax=root:Packages:Irena:DWSplottingTool:GraphBottomAxisMax
//	SVAR ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
//		GetAxis/Q left
//		if (V_Flag)
//			abort
//		endif
//	
//	if (GraphLeftAxisAuto)	//autoscale left axis
//		SetAxis/A left
//		DoUpdate
//		GetAxis /Q left
//		GraphLeftAxisMin=V_min
//		GraphLeftAxisMax=V_max
//		ListOfGraphFormating=ReplaceNumberByKey("Axis left min",ListOfGraphFormating, GraphLeftAxisMin,"=")
//		ListOfGraphFormating=ReplaceNumberByKey("Axis left max",ListOfGraphFormating, GraphLeftAxisMax,"=")
//
//	else		//fixed left axis
//		SetAxis left GraphLeftAxisMin,GraphLeftAxisMax
//
//	endif
//	
//	if (GraphBottomAxisAuto)	//autoscale bottom axis
//		SetAxis/A bottom
//		DoUpdate
//		GetAxis  /Q bottom
//		GraphBottomAxisMin=V_min
//		GraphBottomAxisMax=V_max
//		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom min",ListOfGraphFormating, GraphBottomAxisMin,"=")
//		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom max",ListOfGraphFormating, GraphBottomAxisMax,"=")
//	else		//fixed bottom axis
//		SetAxis bottom GraphBottomAxisMin,GraphBottomAxisMax
//
//	endif
//end


Proc IR2D_DWSStdGraph(width,maxY,minY,BW,ylabel,xlabel,modetype,aspect,linewidth,markersize)
	variable/g root:Packages:Irena:DWSPFolder:gmaxy, root:Packages:Irena:DWSPFolder:gminY,root:Packages:Irena:DWSPFolder:gwidth, root:Packages:Irena:DWSPFolder:gBW,root:Packages:Irena:DWSPFolder:modetype,root:Packages:Irena:DWSPFolder:aspect,root:Packages:Irena:DWSPFolder:glinewidth,root:Packages:Irena:DWSPFolder:gmarkersize
	variable maxy=root:Packages:Irena:DWSPFolder:gmaxy,minY=root:Packages:Irena:DWSPFolder:gminY,width=root:Packages:Irena:DWSPFolder:gwidth,BW=root:Packages:Irena:DWSPFolder:gBW,modetype=root:Packages:Irena:DWSPFolder:modetype,aspect=root:Packages:Irena:DWSPFolder:aspect
	variable linewidth=root:Packages:Irena:DWSPFolder:glinewidth,markersize=root:Packages:Irena:DWSPFolder:gmarkersize
	string/g root:Packages:Irena:DWSPFolder:gylabel, root:Packages:Irena:DWSPFolder:gxlabel
	string ylabel=root:Packages:Irena:DWSPFolder:gylabel,xlabel=root:Packages:Irena:DWSPFolder:gxlabel
	prompt BW, "Graph Color",popup, "Color;Black & White;No Change"
	prompt maxy,"Enter max Y"
	prompt minY, "Enter min Y"
	prompt width, "Enter width in inches"
	Prompt aspect, "Enter aspect ratio (1.4)"
	Prompt modetype, "Type of display", popup,"Lines;Sticks;Dots;Markers;Lines &Markers;No change"
	Prompt ylabel,"Y axis Label", popup, "No Change;\f01\Z1610\S6\M\Z16 x SLD (Å\S-2\M\Z16);\F'Helvetica'\Z16\f01Intensity (cm\S-1\M\Z16);\F'Helvetica'\Z16\f01Intensity;\F'Helvetica'\Z16\f01Reflectivity;\F'Helvetica'\Z12\f01Relative Intensity;"
	Prompt xlabel,"X axis Label", popup, "No Change;\Z16Distance from Si (Å);\F'Helvetica'\Z16\f01q (Å\S-1\M\Z16);\F'Helvetica'\Z16\f01q(µm\S-1\M\Z16);\F'Helvetica'\Z16\f01Diameter (µm);\F'Helvetica'\Z12\f01q (Å\S-1\M\Z12)"
	prompt linewidth, "Line width"
	prompt markersize, "Marker size"
	silent 1
	root:Packages:Irena:DWSPFolder:gylabel=ylabel
	root:Packages:Irena:DWSPFolder:gxlabel=xlabel
	root:Packages:Irena:DWSPFolder:gmaxy=maxy;root:Packages:Irena:DWSPFolder:gminY=minY;root:Packages:Irena:DWSPFolder:modetype=modetype
	root:Packages:Irena:DWSPFolder:gwidth=width;root:Packages:Irena:DWSPFolder:aspect=aspect
	root:Packages:Irena:DWSPFolder:gBW=BW;root:Packages:Irena:DWSPFolder:glinewidth=linewidth;root:Packages:Irena:DWSPFolder:gmarkersize=markersize
		modetype=modetype-1
	If (width!=0)
		ModifyGraph width=width*72
	endif
	If (aspect!=0)
		ModifyGraph height={Aspect,aspect}
	endif
	ModifyGraph axThick=2;DelayUpdate
	If(!stringmatch(ylabel, "No Change" ))
		Label left ylabel
	endif
	If(!stringmatch(xlabel, "No Change" ))
		Label bottom xlabel
	endif
	
	If ((!maxy==0)&(miny==0))||(!miny==0)&(maxy==0))
		Doalert 0,"If you enter one axis limit, you must enter the other"
		abort
	endif
	If(modetype!=5)
		ModifyGraph mode=modetype
		IR2D_ChangetoLineandPoints((modetype),1)
	endif
	if((!miny==0)||(!maxy==0))
		SetAxis left minY, maxY
	endif
	//ModifyGraph mirror(bottom)=1;DelayUpdate
	
	if(stringmatch( AxisList(""), "*right*") )
			//SetAxis right 0,1;DelayUpdate
			ModifyGraph margin(top)=15,margin(right)=60, margin(left)=80
		else
			ModifyGraph mirror=1;DelayUpdate
	endif
	ModifyGraph tick=2
	If (markersize!=0)
		ModifyGraph msize=markersize
	endif
	if(linewidth!=0)
		ModifyGraph lsize=linewidth
	endif
	ModifyGraph mirror(bottom)=1
	ModifyGraph font="Helvetica"
	defaultfont helvetica
	//ModifyGraph fStyle=1,fSize=12
	
	ModifyGraph fStyle=1,fSize=10//font size and bold
	ModifyGraph margin(top)=15,margin(right)=25
	
	If (BW==2)
		ModifyGraph rgb=(0,0,0);DelayUpdate
	endif
	IF (maxy==0)
		Modifygraph width=0, height=0
	endif
endmacro



//
//
//
//Function IR2D_DWSCheckforLog()
//	SVAR 	ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
//		variable checkedbottom=str2num( stringbykey("log(bottom)",ListOfGraphFormating,"="))
//		DWS_GenPlotCheckBox("GraphLogx",checkedbottom)	
//		variable checkedleft=str2num( stringbykey("log(left)",ListOfGraphFormating,"="))
//		DWS_GenPlotCheckBox("GraphLogx",checkedleft)	
//		DWS_GenPlotCheckBox("GraphlogX",checkedbottom)	
//		DWS_GenPlotCheckBox("GraphlogY",checkedleft)	
//end
//
////Function DWS_GeneralPlotTool_Initialize()
////	IR1P_InitializeGenGraph()
////	SetDataFolder root:Packages:Irena:DWSplottingTool//root:Packages:SAS_Modeling:DataFolderName
////	string ListOfVariables="UseAniso;TicRotation;iwavesonly;DataFolderName"
////	variable i=0
////	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
////		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
////	endfor	
////	SVAR 	ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
////	NVAR errors=root:Packages:Irena:DWSplottingTool:GraphErrors
////	NVAR axwidth = root:Packages:Irena:DWSplottingTool:GraphAxisWidth
////	NVAR TicRotation=root:Packages:Irena:DWSplottingTool:TicRotation
////	NVAR foldernames=root:Packages:Irena:DWSplottingTool:GraphLegendUseFolderNms
////	SVAR xname=root:Packages:Irena:DWSplottingTool:GraphXAxisName
////	SVAR yname=root:Packages:Irena:DWSplottingTool:GraphyAxisName
////	SVAR DataFolderName=root:Packages:Irena:DWSplottingTool:DataFolderName
////	foldernames=1;errors=0;	TicRotation = 0;axwidth= 2
////	
////	xname="\F'Helvetica'\f01\Z14q (Å\S-1\M\Z14)";yname="\F'Helvetica'\f01\Z14Intensity (cm\S-1\M\Z14)"
////	ListOfGraphFormating=ReplaceStringByKey("Label left",ListOfGraphFormating,yname,"=")
////	ListOfGraphFormating=ReplaceStringByKey("Label bottom",ListOfGraphFormating, xname,"=")
////	ListOfGraphFormating=ReplaceStringByKey("ErrorBars",ListOfGraphFormating, "0","=")
////	ListOfGraphFormating=ReplaceStringByKey("Graph use Symbols",ListOfGraphFormating, "0","=")
////	
////	DataFolderName="root:"
////end
//
//function DWS_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
//	String ctrlName
//	Variable popNum
//	String popStr
//
//	string oldDf=GetDataFolder(1)
//	setDataFolder root:Packages:Irena:DWSplottingTool
//
//	if (cmpstr(ctrlName,"GraphLegendSize")==0)
//		//here goes what needs to be done, when we select this popup...
//		NVAR GraphLegendSize=root:Packages:Irena:DWSplottingTool:GraphlegendSize
//		GraphlegendSize=str2num(popStr)
//		SVAR ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating	//this contains data formating
//		ListOfGraphFormating=ReplaceStringByKey("Graph legend size", ListOfGraphFormating, popstr,"=")
//	endif
//	
//	NVAR UseIndra2Data=root:Packages:Irena:DWSplottingTool:UseIndra2Data
//	NVAR UseQRSData=root:Packages:Irena:DWSplottingTool:UseQRSdata
//	NVAR UseResults=root:Packages:Irena:DWSplottingTool:UseResults
//	NVAR UseAniso=root:Packages:Irena:DWSplottingTool:UseAniso
//	
//	if (cmpstr(ctrlName,"SelectDataFolder")==0)
//		SVAR Dtf=root:Packages:Irena:DWSplottingTool:DataFolderName
//		Dtf=popStr
//		PopupMenu IntensityDataName mode=1
//		PopupMenu QvecDataName mode=1
//		PopupMenu ErrorDataName mode=1
//		SVAR IntDf=root:Packages:Irena:DWSplottingTool:IntensityWaveName
//		SVAR QDf=root:Packages:Irena:DWSplottingTool:QWaveName
//		SVAR EDf=root:Packages:Irena:DWSplottingTool:ErrorWaveName
//		if (UseIndra2Data)
//			if(stringmatch(IR1P_ListOfWaves("Yaxis"), "*M_BKG_Int*") &&stringmatch(IR1P_ListOfWaves("Xaxis"), "*M_BKG_Qvec*")  &&stringmatch(IR1P_ListOfWaves("Error"), "*M_BKG_Error*") )			
//				IntDf="M_BKG_Int"
//				QDf="M_BKG_Qvec"
//				EDf="M_BKG_Error"
//				PopupMenu IntensityDataName value="M_BKG_Int;M_DSM_Int;DSM_Int"
//				PopupMenu QvecDataName value="M_BKG_Qvec;M_DSM_Qvec;DSM_Qvec"
//				PopupMenu ErrorDataName value="M_BKG_Error;M_DSM_Error;DCM_Error"
//			elseif(stringmatch(IR1P_ListOfWaves("Yaxis"), "*BKG_Int*") &&stringmatch(IR1P_ListOfWaves("Xaxis"), "*BKG_Qvec*")  &&stringmatch(IR1P_ListOfWaves("Error"), "*BKG_Error*") )			
//				IntDf="BKG_Int"
//				QDf="BKG_Qvec"
//				EDf="BKG_Error"
//				PopupMenu IntensityDataName value="BKG_Int;DSM_Int"
//				PopupMenu QvecDataName value="BKG_Qvec;DSM_Qvec"
//				PopupMenu ErrorDataName value="BKG_Error;DCM_Error"
//			elseif(stringmatch(IR1P_ListOfWaves("Yaxis"), "*M_DSM_Int*") &&stringmatch(IR1P_ListOfWaves("Xaxis"), "*M_DSM_Qvec*")  &&stringmatch(IR1P_ListOfWaves("Error"), "*M_DSM_Error*") )			
//				IntDf="M_DSM_Int"
//				QDf="M_DSM_Qvec"
//				EDf="M_DSM_Error"
//				PopupMenu IntensityDataName value="M_DSM_Int;DSM_Int"
//				PopupMenu QvecDataName value="M_DSM_Qvec;DSM_Qvec"
//				PopupMenu ErrorDataName value="M_DSM_Error;DSM_Error;---;"
//			else
//				if(!stringmatch(IR1P_ListOfWaves("Yaxis"), "*M_DSM_Int*") &&!stringmatch(IR1P_ListOfWaves("Xaxis"), "*M_DSM_Qvec*")  &&!stringmatch(IR1P_ListOfWaves("Error"), "*M_DSM_Error*") )			
//					IntDf="DSM_Int"
//					QDf="DSM_Qvec"
//					EDf="DSM_Error"
//					PopupMenu IntensityDataName value="DSM_Int"
//					PopupMenu QvecDataName value="DSM_Qvec"
//					PopupMenu ErrorDataName value="DSM_Error;---;"
//				endif
//				
//			endif
//		else
//			IntDf=""
//			QDf=""
//			EDf=""
//			PopupMenu IntensityDataName value="---"
//			PopupMenu QvecDataName  value="---"
//			PopupMenu ErrorDataName  value="---"
//		endif
//		if(UseQRSdata)
//			IntDf=""
//			QDf=""
//			EDf=""
//			PopupMenu IntensityDataName  value="---;"+IR1P_ListOfWaves("Yaxis")
//			PopupMenu QvecDataName  value="---;"+IR1P_ListOfWaves("Xaxis")
//			PopupMenu ErrorDataName  value="---;"+IR1P_ListOfWaves("Error")
//		endif
//		if(UseResults)
//			IntDf=""
//			QDf=""
//			EDf=""
//			PopupMenu IntensityDataName  value="---;"+IR1P_ListOfWaves("Yaxis")
//			PopupMenu QvecDataName  value="---;"+IR1P_ListOfWaves("Xaxis")
//			PopupMenu ErrorDataName  value="---;"+IR1P_ListOfWaves("Error")
//		endif
//
//		if(!UseQRSdata && !UseIndra2Data && !UseResults)
//			IntDf=""
//			QDf=""
//			EDf=""
//			PopupMenu IntensityDataName  value="---;"+IR1P_ListOfWaves("Yaxis")
//			PopupMenu QvecDataName  value="---;"+IR1P_ListOfWaves("Xaxis")
//			PopupMenu ErrorDataName  value="---;"+IR1P_ListOfWaves("Error")
//		endif
//		if(UseAniso)
//			IntDf="AnisoIntensityCorr"
//			QDf="sa"
//			EDf=""
//			PopupMenu IntensityDataName value="AnisoIntensityCorr"
//				PopupMenu QvecDataName value="sa"
//				PopupMenu ErrorDataName value="---"
//		endif
//		if (cmpstr(popStr,"---")==0)
//			IntDf=""
//			QDf=""
//			EDf=""
//			PopupMenu IntensityDataName  value="---"
//			PopupMenu QvecDataName  value="---"
//			PopupMenu ErrorDataName  value="---"
//		endif
//	endif
//	
//		SVAR IntDf=root:Packages:Irena:DWSplottingTool:IntensityWaveName
//		SVAR QDf=root:Packages:Irena:DWSplottingTool:QWaveName
//		SVAR EDf=root:Packages:Irena:DWSplottingTool:ErrorWaveName
//		NVAR UseQRSData=root:Packages:Irena:DWSplottingTool:UseQRSdata
//
//	if (cmpstr(ctrlName,"IntensityDataName")==0)
//		if (cmpstr(popStr,"---")!=0)
//			IntDf=popStr
//			if (UseQRSData && strlen(QDf)==0 && strlen(EDf)==0)
//				QDf="q"+popStr[1,inf]
//				EDf="s"+popStr[1,inf]
//				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:Irena:DWSplottingTool:QWaveName+\";---;\"+IR1P_ListOfWaves(\"Xaxis\")")
//				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:Irena:DWSplottingTool:ErrorWaveName+\";---;\"+IR1P_ListOfWaves(\"Error\")")
//			elseif(UseResults)// && strlen(QDf)==0 && strlen(EDf)==0)
//				QDf=IR1P_CheckRightResultsWvs(popStr)
//				EDf=""
//				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:Irena:DWSplottingTool:QWaveName+\";---;\"+IR1P_ListOfWaves(\"Xaxis\")")
//				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:Irena:DWSplottingTool:ErrorWaveName+\";---;\"+IR1P_ListOfWaves(\"Error\")")
//			endif
//		else
//			IntDf=""
//		endif
//	endif
//
//	if (cmpstr(ctrlName,"QvecDataName")==0)
//		//here goes what needs to be done, when we select this popup...
//		if (cmpstr(popStr,"---")!=0)
//			QDf=popStr
//			if (UseQRSData && strlen(IntDf)==0 && strlen(EDf)==0)
//				IntDf="r"+popStr[1,inf]
//				EDf="s"+popStr[1,inf]
//				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:Irena:DWSplottingTool:IntensityWaveName+\";---;\"+IR1P_ListOfWaves(\"Yaxis\")")
//				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:Irena:DWSplottingTool:ErrorWaveName+\";---;\"+IR1P_ListOfWaves(\"Error\")")
//			elseif(UseResults)// && strlen(QDf)==0 && strlen(EDf)==0)
//				IntDf=IR1P_CheckRightResultsWvs(popStr)
//				EDf=""
//				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:Irena:DWSplottingTool:IntensityWaveName+\";---;\"+IR1P_ListOfWaves(\"Yaxis\")")
//				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:Irena:DWSplottingTool:ErrorWaveName+\";---;\"+IR1P_ListOfWaves(\"Error\")")
//			endif
//		else
//			QDf=""
//		endif
//	endif
//	
//	if (cmpstr(ctrlName,"ErrorDataName")==0)
//		//here goes what needs to be done, when we select this popup...
//		if (cmpstr(popStr,"---")!=0)
//			EDf=popStr
//			if (UseQRSData && strlen(IntDf)==0 && strlen(QDf)==0)
//				IntDf="r"+popStr[1,inf]
//				QDf="q"+popStr[1,inf]
//				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:Irena:DWSplottingTool:IntensityWaveName+\";---;\"+IR1P_ListOfWaves(\"Yaxis\")")
//				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:Irena:DWSplottingTool:QWaveName+\";---;\"+IR1P_ListOfWaves(\"Xaxis\")")
//			endif
//		else
//			EDf=""		
//		endif
//	endif
//end
//
//Function DWS_GenPlotCheckBox(ctrlName,checked) : CheckBoxControl
//	String ctrlName
//	Variable checked
//	string folder=getdatafolder(1)
//	SVAR 	ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
//	if (cmpstr("GraphLogX",ctrlName)==0)
//		//anything needs to be done here?
//		ListOfGraphFormating=ReplaceStringByKey("log(bottom)",ListOfGraphFormating, num2str(checked),"=")
//		ModifyGraph log(bottom)=checked	
//	endif	
//	if (cmpstr("GraphLogy",ctrlName)==0)
//		ListOfGraphFormating=ReplaceStringByKey("log(left)",ListOfGraphFormating, num2str(checked),"=")
//		ModifyGraph log(left)=checked
//	endif	
//	if (cmpstr("GraphErrors",ctrlName)==0)
//		ListOfGraphFormating=ReplaceStringByKey("ErrorBars",ListOfGraphFormating, num2str(checked),"=")
//		DWS_AttachErrorBars()
//	endif	
//	if (cmpstr("GraphLegend",ctrlName)==0)
//		//anything needs to be done here?
//		if(checked)
//			NVAR GraphLegendUseFolderNms=root:Packages:Irena:DWSplottingTool:GraphLegendUseFolderNms
//			NVAR GraphLegendUseWaveNote=root:Packages:Irena:DWSplottingTool:GraphLegendUseWaveNote
//			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(checked+GraphLegendUseFolderNms+2*GraphLegendUseWaveNote),"=")
//		else
//			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(checked),"=")
//		endif
//	endif
//	variable UseLegend
//	if (cmpstr("GraphLegendUseFolderNms",ctrlName)==0)
//		//anything needs to be done here?
//		UseLegend=NumberByKey("Legend",ListOfGraphFormating,"=")
//		if (UseLegend)
//			NVAR GraphLegendUseFolderNms=root:Packages:Irena:DWSplottingTool:GraphLegendUseFolderNms
//			NVAR GraphLegendUseWaveNote=root:Packages:Irena:DWSplottingTool:GraphLegendUseWaveNote
//			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(1+GraphLegendUseFolderNms+2*GraphLegendUseWaveNote),"=")
//		endif
//	endif
//	if (cmpstr("GraphLegendUseWaveNote",ctrlName)==0)
//		//anything needs to be done here?
//		UseLegend=NumberByKey("Legend",ListOfGraphFormating,"=")
//		if (UseLegend)
//			NVAR GraphLegendUseFolderNms=root:Packages:Irena:DWSplottingTool:GraphLegendUseFolderNms
//			NVAR GraphLegendUseWaveNote=root:Packages:Irena:DWSplottingTool:GraphLegendUseWaveNote
//			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(1+GraphLegendUseFolderNms+2*GraphLegendUseWaveNote),"=")
//		endif
//	endif
//	
//	if (cmpstr("GraphUseSymbols",ctrlName)==0)
//		//anything needs to be done here?
//		ListOfGraphFormating=ReplaceStringByKey("Graph use Symbols",ListOfGraphFormating, num2str(checked),"=")
//		variable UseLinesAlso=NumberByKey("Graph use Lines",ListOfGraphFormating,"=",";")
//	endif
//		
//	if (cmpstr("GraphUseLines",ctrlName)==0)
//		//anything needs to be done here?
//		ListOfGraphFormating=ReplaceStringByKey("Graph use lines",ListOfGraphFormating, num2str(checked),"=")
//	endif
//
//	if (cmpstr("GraphUseColors",ctrlName)==0)
//		//anything needs to be done here?
//		checked+=1
//		ListOfGraphFormating=ReplaceStringByKey("Graph use colors",ListOfGraphFormating, num2str(checked),"=")	
//	endif
//	
//	if (cmpstr("GraphLeftAxisAuto",ctrlName)==0)
//		//anything needs to be done here?
//		ListOfGraphFormating=ReplaceStringByKey("Axis left auto",ListOfGraphFormating, num2str(checked),"=")
//	endif
//	if (cmpstr("GraphBottomAxisAuto",ctrlName)==0)
//		//anything needs to be done here?
//		ListOfGraphFormating=ReplaceStringByKey("Axis bottom auto",ListOfGraphFormating, num2str(checked),"=")
//	endif
//	if (cmpstr("GraphXMajorGrid",ctrlName)==0)
//		//anything needs to be done here?   
//		NVAR GraphXMajorGrid=root:Packages:Irena:DWSplottingTool:GraphXMajorGrid
//		NVAR GraphXMinorGrid=root:Packages:Irena:DWSplottingTool:GraphXMinorGrid
//		if (GraphXMajorGrid)
//			if(GraphXMinorGrid)
//				ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "1","=")
//			else
//				ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "2","=")
//			endif
//		else
//			ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "0","=")
//			GraphXMinorGrid=0
//		endif
//		
//	endif
//	if (cmpstr("GraphXMinorGrid",ctrlName)==0)
//		//anything needs to be done here?
//		NVAR GraphXMajorGrid=root:Packages:Irena:DWSplottingTool:GraphXMajorGrid
//		NVAR GraphXMinorGrid=root:Packages:Irena:DWSplottingTool:GraphXMinorGrid
//		ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "0","=")
//		if (GraphXMinorGrid)
//			GraphXMajorGrid=1
//			ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "1","=")
//		else
//			if(GraphXMajorGrid) 
//				ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "2","=")
//			endif
//		endif
//	endif
//	if (cmpstr("GraphYMajorGrid",ctrlName)==0)
//			NVAR GraphYMajorGrid=root:Packages:Irena:DWSplottingTool:GraphYMajorGrid
//			NVAR GraphYMinorGrid=root:Packages:Irena:DWSplottingTool:GraphYMinorGrid
//			if (GraphYMajorGrid)
//				if(GraphYMinorGrid)
//					ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "1","=")
//				else
//					ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "2","=")
//				endif
//			else
//				ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "0","=")
//				GraphYMinorGrid=0
//			endif
//		
//	endif
//	if (cmpstr("GraphYMinorGrid",ctrlName)==0)
//		
//		NVAR GraphYMajorGrid=root:Packages:Irena:DWSplottingTool:GraphYMajorGrid
//		NVAR GraphYMinorGrid=root:Packages:Irena:DWSplottingTool:GraphYMinorGrid
//		ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "0","=")
//		if (GraphYMinorGrid)
//			GraphYMajorGrid=1
//			ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "1","=")
//		else
//			if(GraphYMajorGrid) 
//				ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "2","=")
//			endif
//		endif
//		
//	endif
//	
//	ModifyGraph grid(bottom)=NumberByKey("grid(bottom)", ListOfGraphFormating,"=",";")
//	ModifyGraph grid(left)=NumberByKey("grid(left)", ListOfGraphFormating,"=",";")
//	setdatafolder folder
//DoUpdate
//
//end
//
//
//function DWS_SetVarProc(ctrlName,varNum,varStr,varName)
//
//	String ctrlName
//	Variable varNum
//	String varStr
//	String varName
//	string folder= getdatafolder(1)
//	SVAR 	ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
//	
//	if (cmpstr("GraphXAxisName",ctrlName)==0)
//		//anything needs to be done here?
//		ListOfGraphFormating=ReplaceStringByKey("Label bottom",ListOfGraphFormating, varStr,"=")
//		Label bottom StringbyKey("Label bottom", ListOfGraphFormating,"=",";")
//	
//	endif
//	if (cmpstr("GraphYAxisName",ctrlName)==0)
//		//anything needs to be done here?
//		ListOfGraphFormating=ReplaceStringByKey("Label left",ListOfGraphFormating, varStr,"=")
//		Label left StringbyKey("Label left", ListOfGraphFormating,"=",";")
//	endif
//	
//	if (cmpstr("GraphLineWidth",ctrlName)==0)
//		//anything needs to be done here?
//		ListOfGraphFormating=ReplaceNumberByKey("lsize",ListOfGraphFormating, varNum,"=")
//	endif
//		if (cmpstr("TicRotation",ctrlName)==0)
//		ModifyGraph tkLblRot(left)=varNum	
//	endif
//	
//	if (cmpstr("GraphSymbolSize",ctrlName)==0)
//		ListOfGraphFormating=ReplaceNumberByKey("msize",ListOfGraphFormating, varNum,"=")
//	endif
//	
//	if (cmpstr("GraphAxisWidth",ctrlName)==0)	
//		ListOfGraphFormating=ReplaceNumberByKey("axThick",ListOfGraphFormating, varNum,"=")
//		ModifyGraph axThick=varnum
//		variable fontsize=(14*(Varnum==1))+(16*(varnum==2))+(18*(varnum==3))+(20*(varnum==4))
//		ModifyGraph fSize=fontsize
//		ModifyGraph fSize=fontsize
//		ModifyGraph fSize=fontsize
//	endif
//		if (cmpstr("GraphLeftAxisMin",ctrlName)==0)		
//		ListOfGraphFormating=ReplaceNumberByKey("Axis left min",ListOfGraphFormating, varNum,"=")
//		DWS_Irena:DWSplottingToolInGraph()
//	endif
//	if (cmpstr("GraphLeftAxisMax",ctrlName)==0)		
//		ListOfGraphFormating=ReplaceNumberByKey("Axis left max",ListOfGraphFormating, varNum,"=")
//		DWS_Irena:DWSplottingToolInGraph()
//	endif
//	if (cmpstr("GraphBottomAxisMin",ctrlName)==0)
//		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom min",ListOfGraphFormating, varNum,"=")
//		DWS_Irena:DWSplottingToolInGraph()
//	endif
//	if (cmpstr("GraphBottomAxisMax",ctrlName)==0)		
//		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom max",ListOfGraphFormating, varNum,"=")
//		DWS_Irena:DWSplottingToolInGraph()
//	endif
//	setdatafolder folder
//end
//
//
//
//Function DWS_InputPanelButtonProc(ctrlName) : ButtonControl
//	String ctrlName
//
//	string ListOfVariables, listofstrings
//		variable i
//		if (!DataFolderExists("root:Packages:SAS_Modeling"))		
//			NewDataFolder/O root:Packages
//			NewDataFolder/O root:Packages:SAS_Modeling
//		endif
//		SetDataFolder root:Packages:SAS_Modeling					
//		ListOfStrings="DataFolderName"
//		ListOfVariables="Orientation;fold;SmallMon"
//		for(i=0;i<itemsInList(ListOfVariables);i+=1)	
//			DWS_CreateItem("variable",StringFromList(i,ListOfVariables))
//		endfor		
//		for(i=0;i<itemsInList(ListOfStrings);i+=1)	
//			DWS_CreateItem("string",StringFromList(i,ListOfStrings))
//		endfor		
//	
//	variable IsAllAllRight
//
//	if ((cmpstr(ctrlName,"AddDataToGraph")==0)||(cmpstr(ctrlName,"newgraph")==0))
//		//here goes what is done, when user pushes Graph button
//		SVAR ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
//		SVAR DFloc=root:Packages:Irena:DWSplottingTool:DataFolderName
//		SVAR DFInt=root:Packages:Irena:DWSplottingTool:IntensityWaveName
//		SVAR DFQ=root:Packages:Irena:DWSplottingTool:QWaveName
//		SVAR DFE=root:Packages:Irena:DWSplottingTool:ErrorWaveName
//		IsAllAllRight=1
//		if (cmpstr(DFloc,"---")==0 || strlen(DFloc)<=0)
//			IsAllAllRight=0
//		endif
//		if (cmpstr(DFInt,"---")==0 || strlen(DFInt)<=0)
//			IsAllAllRight=0
//		endif
//		//if (cmpstr(DFQ,"---")==0 || strlen(DFQ)<=0)//qwave selection not required will use x-wave scaling
//			//IsAllAllRight=0
//		//endif
//		//if (IsAllAllRight)
//			//IR1P_RecordDataForGraph()  dws Nov
//		//else
//		//	Abort "Data not selected properly"
//	//	endif
//		if (cmpstr(ctrlName,"newgraph")==0)
//			IR2D_DWSCreateGraph(1)   //create  the graph
//		else
//			IR2D_DWSCreateGraph(0)
//		endif					
//	endif	
//	
//	if (cmpstr(ctrlName,"SaveGraph")==0)
//		string top= StringFromList(0,WinList("*", ";", "WIN:1"))
//		DoWindow/F $top
//		string cmd= "DoIgorMenu  \"Control\", \"Window control\""
//		execute/P cmd
//	endif
//	
//	if (cmpstr(ctrlName,"Standard")==0)
//		execute "StdGraph()"//(width,maxY,minY,BW,ylabel,xlabel,modetype,aspect)
//	endif
//	
//	if (cmpstr(ctrlName,"Capture")==0)
//		GetAxis /Q left
//		SVAR ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
//		NVAR GraphLeftAxisAuto=root:Packages:Irena:DWSplottingTool:GraphLeftAxisAuto
//		NVAR GraphLeftAxisMin=root:Packages:Irena:DWSplottingTool:GraphLeftAxisMin
//		NVAR GraphLeftAxisMax=root:Packages:Irena:DWSplottingTool:GraphLeftAxisMax
//		NVAR GraphBottomAxisAuto=root:Packages:Irena:DWSplottingTool:GraphBottomAxisAuto
//		NVAR GraphBottomAxisMin=root:Packages:Irena:DWSplottingTool:GraphBottomAxisMin
//		NVAR GraphBottomAxisMax=root:Packages:Irena:DWSplottingTool:GraphBottomAxisMax
//		GraphLeftAxisMin=V_min
//		GraphLeftAxisMax=V_max
//		ListOfGraphFormating=ReplaceNumberByKey("Axis left min",ListOfGraphFormating, GraphLeftAxisMin,"=")
//		ListOfGraphFormating=ReplaceNumberByKey("Axis left max",ListOfGraphFormating, GraphLeftAxisMax,"=")
//		GetAxis  /Q bottom
//		GraphBottomAxisMin=V_min
//		GraphBottomAxisMax=V_max
//		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom min",ListOfGraphFormating, GraphBottomAxisMin,"=")
//		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom max",ListOfGraphFormating, GraphBottomAxisMax,"=")
//	endif	
//	
//	if (cmpstr(ctrlName,"Format")==0)
//		FormatGraph(0)
//	endif
//	
//	if (cmpstr(ctrlName,"Legends")==0)
//		DWS_AttachLegend()
//	endif
//	
//	if (cmpstr(ctrlName,"killLegends")==0)
//			NVAR GraphLegendUseFolderNms=root:Packages:Irena:DWSplottingTool:GraphLegendUseFolderNms
//			NVAR GraphLegendUseWaveNote=root:Packages:Irena:DWSplottingTool:GraphLegendUseWaveNote		
//		if(GraphLegendUseFolderNms==0)
//			TextBox/K/N=FolderLegend
//		endif
//		if (GraphLegendUseWaveNote==0)
//			TextBox/K/N=waveLegend
//		endif
//		DWS_AttachLegend()
//	endif
//	
//	if (cmpstr(ctrlName,"ChangeAx")==0)
//		DWS_Irena:DWSplottingToolInGraph()
//	endif
//	
//	if (cmpstr(ctrlName,"Hermans1")==0)	
//		SVAR DFLoc2=root:Packages:SAS_Modeling:DataFolderName
//		setdatafolder DFLoc2
//		NVAR Fold=root:Packages:SAS_Modeling:fold
//		fold = 0
//		execute "HermansPanel()"
//	endif
//	
//	if (cmpstr(ctrlName,"Hermans")==0)	
//		
//		SVAR DFLoc1=root:Packages:Irena:DWSplottingTool:DataFolderName
//		SVAR DFLoc2=root:Packages:SAS_Modeling:DataFolderName
//		DFLoc2=DFloc1
//		setdatafolder DFLoc2
//		string rwave="AnisointensityCorr", xwave= "sa"
//		NVAR Orientation =root:Packages:SAS_Modeling:Orientation
//		NVAR Fold=root:Packages:SAS_Modeling:fold
//		orientation = 0
//		fold = 0
//		execute "UNICAT_AzamuthalPanel()"
//	endif
//end
//
//
//
//Function DWS_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
//	String ctrlName
//	Variable checked	
//		NVAR UseIndra2Data=root:Packages:Irena:DWSplottingTool:UseIndra2Data
//		NVAR UseQRSData=root:Packages:Irena:DWSplottingTool:UseQRSData
//		NVAR UseResults=root:Packages:Irena:DWSplottingTool:UseResults
//		NVAR UseAniso=root:Packages:Irena:DWSplottingTool:UseAniso		
//		SVAR Dtf=root:Packages:Irena:DWSplottingTool:DataFolderName
//		SVAR IntDf=root:Packages:Irena:DWSplottingTool:IntensityWaveName
//		SVAR QDf=root:Packages:Irena:DWSplottingTool:QWaveName
//		SVAR EDf=root:Packages:Irena:DWSplottingTool:ErrorWaveName
//		SVAR xname=root:Packages:Irena:DWSplottingTool:GraphXAxisName
//		SVAR yname=root:Packages:Irena:DWSplottingTool:GraphyAxisName
//		xname="\F'Helvetica'\Z14q (A\S-1\M)"
//		yname="\F'Helvetica'\Z14Intensity (cm)\S-1"
//				
//		Dtf=" "
//		IntDf=" "
//		QDf=" "
//		EDf=" "
//		PopupMenu SelectDataFolder mode=1
//		PopupMenu IntensityDataName   mode=1, value="---"
//		PopupMenu QvecDataName    mode=1, value="---"
//		PopupMenu ErrorDataName    mode=1, value="---"
//		
//		string top= StringFromList(0,WinList("DWS_GraphPanel", ";", "WIN:1"))
//		If (stringmatch(top, "DWS_GraphPanel" ))
//		
//		//DoWindow/F $top
//		//string cmd= "DoIgorMenu  \"Control\", \"Window control\""
//	
//			Button Hermans,win =DWS_GraphPanel, disable=1  ,pos={220,495},size={100,20}
//			Button Hermans font="Times New Roman",fSize=10,proc=DWS_InputPanelButtonProc,title="Hermans"
//		endif
//	if (cmpstr(ctrlName,"UseIndra2Data")==0)
//		if (checked)
//			UseQRSData=0
//			UseResults=0
//			UseAniso=0
//		endif
//	endif
//	if (cmpstr(ctrlName,"UseQRSData")==0)
//		if (checked)
//			UseIndra2Data=0
//			UseResults=0
//			UseAniso=0
//		endif
//
//	endif
//	if (cmpstr(ctrlName,"UseResults")==0)//dws
//		DoAlert 0, "Currently not implimented\r see panel code"
//		if (checked)
//			UseIndra2Data=0
//			UseQRSData=0
//			UseAniso=0
//		endif		
//	endif
//	
//	if (cmpstr(ctrlName,"UseAniso")==0)//dws
//		DoAlert 0, "Currently not implimented\r see panel code"
//		Useaniso=checked
//		if (checked)
//			UseIndra2Data=0
//			UseQRSData=0
//			UseResults=0
//			Button Hermans,win =DWS_GraphPanel, disable=0   ,pos={220,495},size={100,20},font="Times New Roman",fSize=10,proc=DWS_InputPanelButtonProc,title="Hermans"
//		xname="\F'Helvetica'\Z14Azamuthal Angle (Deg)"
//		yname="\F'Helvetica'\Z14Intensity"
//		endif	
//	endif	
//end
//
//Function/T DWS_ListOfWaves(DataType)
//	string DataType			//data type   : Xaxis, Yaxis, Error
//	
//	NVAR UseIndra2Data=root:packages:Irena:DWSplottingTool:UseIndra2Data
//	NVAR UseQRSData=root:packages:Irena:DWSplottingTool:UseQRSData
//	NVAR UseResults=root:packages:Irena:DWSplottingTool:UseResults
//	NVAR UseAniso=root:packages:Irena:DWSplottingTool:UseAniso
//	Nvar iWavesOnly=root:packages:Irena:DWSplottingTool:iWavesOnly
//	SVAR FldrNm=root:Packages:Irena:DWSplottingTool:DataFolderName//seems like inconsistent choice of data folder
//	string result="", tempresult="", tempStringQ="", tempStringR="", tempStringS=""
//	
//	variable i,j
//		
//	if (UseIndra2Data)
//		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
//		tempresult=""
//		if(cmpstr(DataType,"Xaxis")==0)
//			if(stringMatch(result,"*DSM_Qvec*"))
//				for (i=0;i<ItemsInList(result);i+=1)
//					if (stringMatch(StringFromList(i,result),"*DSM_Qvec*"))
//						tempresult+=StringFromList(i,result)+";"
//					endif
//				endfor
//				For (j=0;j<ItemsInList(result);j+=1)
//					if (stringMatch(StringFromList(j,result),"*BKG_Qvec*"))
//						tempresult+=StringFromList(j,result)+";"
//					endif
//				endfor
//			endif
//		elseif (cmpstr(DataType,"Yaxis")==0)
//			if(stringMatch(result,"*DSM_Int*"))
//				for (i=0;i<ItemsInList(result);i+=1)
//					if (stringMatch(StringFromList(i,result),"*DSM_Int*"))
//						tempresult+=StringFromList(i,result)+";"
//					endif
//				endfor
//				For (j=0;j<ItemsInList(result);j+=1)
//					if (stringMatch(StringFromList(j,result),"*BKG_Int*"))
//						tempresult+=StringFromList(j,result)+";"
//					endif
//				endfor
//			endif
//		else// (cmpstr(DataType,"Error")==0)
//			if(stringMatch(result,"*DSM_Error*"))
//				for (i=0;i<ItemsInList(result);i+=1)
//					if (stringMatch(StringFromList(i,result),"*DSM_Error*"))
//						tempresult+=StringFromList(i,result)+";"
//					endif
//				endfor
//				For (j=0;j<ItemsInList(result);j+=1)
//					if (stringMatch(StringFromList(j,result),"*BKG_Error*"))
//						tempresult+=StringFromList(j,result)+";"
//					endif
//				endfor
//			endif
//		endif
//			result=tempresult
//	elseif(UseQRSData) 
//		result=""			//IN2G_CreateListOfItemsInFolder(FldrNm,2)
//		tempStringQ=IR1_ListOfWavesOfType("q",IN2G_CreateListOfItemsInFolder(FldrNm,2))
//		tempStringR=IR1_ListOfWavesOfType("r",IN2G_CreateListOfItemsInFolder(FldrNm,2))
//		tempStringS=IR1_ListOfWavesOfType("s",IN2G_CreateListOfItemsInFolder(FldrNm,2))
//		
//		if (cmpstr(DataType,"Yaxis")==0)
//			For (j=0;j<ItemsInList(tempStringR);j+=1)
//				if (stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringR)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringR)[1,inf]+";*"))
//					result+=StringFromList(j,tempStringR)+";"
//				endif
//			endfor
//		elseif(cmpstr(DataType,"Xaxis")==0)
//			For (j=0;j<ItemsInList(tempStringQ);j+=1)
//				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringQ)[1,inf]+";*"))
//					result+=StringFromList(j,tempStringQ)+";"
//				endif
//			endfor
//		else
//			For (j=0;j<ItemsInList(tempStringS);j+=1)
//				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringS)[1,inf]+";*") && stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringS)[1,inf]+";*"))
//					result+=StringFromList(j,tempStringS)+";"
//				endif
//			endfor
//		endif
//	elseif (UseResults)
//		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
//		tempresult=""
//		string tempstr
//		if(cmpstr(DataType,"Xaxis")==0)
//			For (j=0;j<ItemsInList(result);j+=1)
//			tempstr= StringFromList(j,result)
//				if (stringMatch(tempstr,"UnifiedFitQvector*") || stringMatch(tempstr,"SizesFitQvector*")|| stringMatch(tempstr,"SizesDistDiameter*") ||stringMatch(tempstr,"ModelingDiameters*") || stringMatch(tempstr,"FractFitQvector*") || stringMatch(tempstr,"ModelingQvector*"))
//					tempresult+=tempstr+";"
//				endif
//			endfor		
//		elseif (cmpstr(DataType,"Yaxis")==0)
//			For (j=0;j<ItemsInList(result);j+=1)
//			tempstr= StringFromList(j,result)
//				if (stringMatch(tempstr,"UnifiedFitIntensity*") || stringMatch(tempstr,"SizesFitIntensity*") || stringMatch(tempstr,"SizesVolumeDistribution*")|| stringMatch(tempstr,"SizesNumberDistribution*") ||stringMatch(tempstr,"ModelingNumberDistribution*")||stringMatch(tempstr,"ModelingVolumeDistribution*") || stringMatch(tempstr,"FractFitIntensity*") || stringMatch(tempstr,"ModelingIntensity*"))
//					tempresult+=tempstr+";"
//				endif
//			endfor		
//		else		//error
//			result = "---"
//		endif
//		result = tempresult
//	elseif (UseAniso)
//		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
//		tempresult=""
//		
//		if(cmpstr(DataType,"Xaxis")==0)
//			For (j=0;j<ItemsInList(result);j+=1)
//			tempstr= StringFromList(j,result)
//				if (stringMatch(tempstr,"sa") )
//					tempresult+=tempstr+";"
//				endif
//			endfor		
//		elseif (cmpstr(DataType,"Yaxis")==0)
//			For (j=0;j<ItemsInList(result);j+=1)
//			tempstr= StringFromList(j,result)
//				if (stringMatch(tempstr,"Anis*"))
//					tempresult+=tempstr+";"
//				endif
//			endfor		
//		else		//error
//			result = "---"
//		endif
//		result = tempresult
//	elseif(iWavesonly)
//		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
//		tempresult=""
//			For (j=0;j<ItemsInList(result);j+=1)
//			tempstr= StringFromList(j,result)
//				if (stringMatch(tempstr,"i*") )
//					tempresult+=tempstr+";"
//				endif
//			endfor	
//		result = tempresult
//	else
//		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
//	endif
//	return result
//end
//
//Function/T DWS_GenStringOfFolders(fullpath)//need to add full path
//	variable fullpath
//		
//	NVAR UseIndra2Structure=root:packages:Irena:DWSplottingTool:UseIndra2Data
//	NVAR UseQRSStructure=root:packages:Irena:DWSplottingTool:UseQRSData
//	NVAR UseResults=root:packages:Irena:DWSplottingTool:UseResults
//	NVAR UseAniso=root:packages:Irena:DWSplottingTool:UseAniso
//	NVAR iWavesOnly=root:packages:Irena:DWSplottingTool:iWavesOnly
//	string ListOfQFolders=""
//	string result=""
//	if (UseIndra2Structure)
//		result=DWS_FindFolderWithWaveTypes("root:USAXS:", 10, "*DSM*", fullpath)
//	endif
//	if (UseQRSStructure)
//		ListOfQFolders=DWS_FindFolderWithWaveTypes("root:", 10, "q*", fullpath)
//		result+=ListOfQFolders//ReturnListQRSFolders(ListOfQFolders)
//	endif
//	if (UseAniso)
//		ListOfQFolders=IN2G_FindFolderWithWaveTypes("root:", 10, "Anis*", fullpath)
//		result+=ListOfQFolders//ReturnListResultsFolders(ListOfQFolders)
//	endif
//	if(useResults)
//			ListOfQFolders+=IN2G_FindFolderWithWaveTypes("root:", 10, "UnifiedFitIntensity*", fullpath)
//			ListOfQFolders+=IN2G_FindFolderWithWaveTypes("root:", 10, "SizesDistributionVolume", fullpath)
//			ListOfQFolders+=IN2G_FindFolderWithWaveTypes("root:", 10, "ModelingVolumeDistribution*", fullpath)
//			ListOfQFolders+=IN2G_FindFolderWithWaveTypes("root:", 10, "FractFitIntensity*", fullpath)		
//		result+=ReturnListResultsFolders(ListOfQFolders)
//	endif
//	if (iWavesOnly)
//		result+=DWS_FindFolderWithWaveTypes("root:", 10, "i*", fullpath)
//	endif
//	if ((!UseQRSStructure&!UseAniso&!iWavesOnly&!useResults&!UseIndra2Structure))
//		result=IN2G_FindFolderWithWaveTypes("root:", 10, "*", fullpath)
//	endif
//	return result
//end
//