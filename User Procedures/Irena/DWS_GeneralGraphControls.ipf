#pragma rtGlobals=1		// Use modern global access method.


Function CheckforLog()
	SVAR 	ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
		variable checkedbottom=str2num( stringbykey("log(bottom)",ListOfGraphFormating,"="))
		DWS_GenPlotCheckBox("GraphLogx",checkedbottom)	
		variable checkedleft=str2num( stringbykey("log(left)",ListOfGraphFormating,"="))
		DWS_GenPlotCheckBox("GraphLogx",checkedleft)	
		DWS_GenPlotCheckBox("GraphlogX",checkedbottom)	
		DWS_GenPlotCheckBox("GraphlogY",checkedleft)	
end

Function DWS_GeneralPlotTool_Initialize()
	IR1P_InitializeGenGraph()
	SetDataFolder root:Packages:GeneralplottingTool//root:Packages:SAS_Modeling:DataFolderName
	string ListOfVariables="UseAniso;TicRotation;iwavesonly;DataFolderName"
	variable i=0
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor	
	SVAR 	ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	NVAR errors=root:Packages:GeneralplottingTool:GraphErrors
	NVAR axwidth = root:Packages:GeneralplottingTool:GraphAxisWidth
	NVAR TicRotation=root:Packages:GeneralplottingTool:TicRotation
	NVAR foldernames=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
	SVAR xname=root:Packages:GeneralplottingTool:GraphXAxisName
	SVAR yname=root:Packages:GeneralplottingTool:GraphyAxisName
	SVAR DataFolderName=root:Packages:GeneralplottingTool:DataFolderName
	foldernames=1;errors=0;	TicRotation = 0;axwidth= 2
	
	xname="\F'Helvetica'\f01\Z14q (�\S-1\M\Z14)";yname="\F'Helvetica'\f01\Z14Intensity (cm\S-1\M\Z14)"
	ListOfGraphFormating=ReplaceStringByKey("Label left",ListOfGraphFormating,yname,"=")
	ListOfGraphFormating=ReplaceStringByKey("Label bottom",ListOfGraphFormating, xname,"=")
	ListOfGraphFormating=ReplaceStringByKey("ErrorBars",ListOfGraphFormating, "0","=")
	ListOfGraphFormating=ReplaceStringByKey("Graph use Symbols",ListOfGraphFormating, "0","=")
	
	DataFolderName="root:"
end

function DWS_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool

	if (cmpstr(ctrlName,"GraphLegendSize")==0)
		//here goes what needs to be done, when we select this popup...
		NVAR GraphLegendSize=root:Packages:GeneralplottingTool:GraphlegendSize
		GraphlegendSize=str2num(popStr)
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating	//this contains data formating
		ListOfGraphFormating=ReplaceStringByKey("Graph legend size", ListOfGraphFormating, popstr,"=")
	endif
	
	NVAR UseIndra2Data=root:Packages:GeneralplottingTool:UseIndra2Data
	NVAR UseQRSData=root:Packages:GeneralplottingTool:UseQRSdata
	NVAR UseResults=root:Packages:GeneralplottingTool:UseResults
	NVAR UseAniso=root:Packages:GeneralplottingTool:UseAniso
	
	if (cmpstr(ctrlName,"SelectDataFolder")==0)
		SVAR Dtf=root:Packages:GeneralplottingTool:DataFolderName
		Dtf=popStr
		PopupMenu IntensityDataName mode=1
		PopupMenu QvecDataName mode=1
		PopupMenu ErrorDataName mode=1
		SVAR IntDf=root:Packages:GeneralplottingTool:IntensityWaveName
		SVAR QDf=root:Packages:GeneralplottingTool:QWaveName
		SVAR EDf=root:Packages:GeneralplottingTool:ErrorWaveName
		if (UseIndra2Data)
			if(stringmatch(IR1P_ListOfWaves("Yaxis"), "*M_BKG_Int*") &&stringmatch(IR1P_ListOfWaves("Xaxis"), "*M_BKG_Qvec*")  &&stringmatch(IR1P_ListOfWaves("Error"), "*M_BKG_Error*") )			
				IntDf="M_BKG_Int"
				QDf="M_BKG_Qvec"
				EDf="M_BKG_Error"
				PopupMenu IntensityDataName value="M_BKG_Int;M_DSM_Int;DSM_Int"
				PopupMenu QvecDataName value="M_BKG_Qvec;M_DSM_Qvec;DSM_Qvec"
				PopupMenu ErrorDataName value="M_BKG_Error;M_DSM_Error;DCM_Error"
			elseif(stringmatch(IR1P_ListOfWaves("Yaxis"), "*BKG_Int*") &&stringmatch(IR1P_ListOfWaves("Xaxis"), "*BKG_Qvec*")  &&stringmatch(IR1P_ListOfWaves("Error"), "*BKG_Error*") )			
				IntDf="BKG_Int"
				QDf="BKG_Qvec"
				EDf="BKG_Error"
				PopupMenu IntensityDataName value="BKG_Int;DSM_Int"
				PopupMenu QvecDataName value="BKG_Qvec;DSM_Qvec"
				PopupMenu ErrorDataName value="BKG_Error;DCM_Error"
			elseif(stringmatch(IR1P_ListOfWaves("Yaxis"), "*M_DSM_Int*") &&stringmatch(IR1P_ListOfWaves("Xaxis"), "*M_DSM_Qvec*")  &&stringmatch(IR1P_ListOfWaves("Error"), "*M_DSM_Error*") )			
				IntDf="M_DSM_Int"
				QDf="M_DSM_Qvec"
				EDf="M_DSM_Error"
				PopupMenu IntensityDataName value="M_DSM_Int;DSM_Int"
				PopupMenu QvecDataName value="M_DSM_Qvec;DSM_Qvec"
				PopupMenu ErrorDataName value="M_DSM_Error;DSM_Error;---;"
			else
				if(!stringmatch(IR1P_ListOfWaves("Yaxis"), "*M_DSM_Int*") &&!stringmatch(IR1P_ListOfWaves("Xaxis"), "*M_DSM_Qvec*")  &&!stringmatch(IR1P_ListOfWaves("Error"), "*M_DSM_Error*") )			
					IntDf="DSM_Int"
					QDf="DSM_Qvec"
					EDf="DSM_Error"
					PopupMenu IntensityDataName value="DSM_Int"
					PopupMenu QvecDataName value="DSM_Qvec"
					PopupMenu ErrorDataName value="DSM_Error;---;"
				endif
				
			endif
		else
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName value="---"
			PopupMenu QvecDataName  value="---"
			PopupMenu ErrorDataName  value="---"
		endif
		if(UseQRSdata)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1P_ListOfWaves("Yaxis")
			PopupMenu QvecDataName  value="---;"+IR1P_ListOfWaves("Xaxis")
			PopupMenu ErrorDataName  value="---;"+IR1P_ListOfWaves("Error")
		endif
		if(UseResults)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1P_ListOfWaves("Yaxis")
			PopupMenu QvecDataName  value="---;"+IR1P_ListOfWaves("Xaxis")
			PopupMenu ErrorDataName  value="---;"+IR1P_ListOfWaves("Error")
		endif

		if(!UseQRSdata && !UseIndra2Data && !UseResults)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1P_ListOfWaves("Yaxis")
			PopupMenu QvecDataName  value="---;"+IR1P_ListOfWaves("Xaxis")
			PopupMenu ErrorDataName  value="---;"+IR1P_ListOfWaves("Error")
		endif
		if(UseAniso)
			IntDf="AnisoIntensityCorr"
			QDf="sa"
			EDf=""
			PopupMenu IntensityDataName value="AnisoIntensityCorr"
				PopupMenu QvecDataName value="sa"
				PopupMenu ErrorDataName value="---"
		endif
		if (cmpstr(popStr,"---")==0)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---"
			PopupMenu QvecDataName  value="---"
			PopupMenu ErrorDataName  value="---"
		endif
	endif
	
		SVAR IntDf=root:Packages:GeneralplottingTool:IntensityWaveName
		SVAR QDf=root:Packages:GeneralplottingTool:QWaveName
		SVAR EDf=root:Packages:GeneralplottingTool:ErrorWaveName
		NVAR UseQRSData=root:Packages:GeneralplottingTool:UseQRSdata

	if (cmpstr(ctrlName,"IntensityDataName")==0)
		if (cmpstr(popStr,"---")!=0)
			IntDf=popStr
			if (UseQRSData && strlen(QDf)==0 && strlen(EDf)==0)
				QDf="q"+popStr[1,inf]
				EDf="s"+popStr[1,inf]
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:GeneralplottingTool:QWaveName+\";---;\"+IR1P_ListOfWaves(\"Xaxis\")")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:GeneralplottingTool:ErrorWaveName+\";---;\"+IR1P_ListOfWaves(\"Error\")")
			elseif(UseResults)// && strlen(QDf)==0 && strlen(EDf)==0)
				QDf=IR1P_CheckRightResultsWvs(popStr)
				EDf=""
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:GeneralplottingTool:QWaveName+\";---;\"+IR1P_ListOfWaves(\"Xaxis\")")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:GeneralplottingTool:ErrorWaveName+\";---;\"+IR1P_ListOfWaves(\"Error\")")
			endif
		else
			IntDf=""
		endif
	endif

	if (cmpstr(ctrlName,"QvecDataName")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			QDf=popStr
			if (UseQRSData && strlen(IntDf)==0 && strlen(EDf)==0)
				IntDf="r"+popStr[1,inf]
				EDf="s"+popStr[1,inf]
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:GeneralplottingTool:IntensityWaveName+\";---;\"+IR1P_ListOfWaves(\"Yaxis\")")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:GeneralplottingTool:ErrorWaveName+\";---;\"+IR1P_ListOfWaves(\"Error\")")
			elseif(UseResults)// && strlen(QDf)==0 && strlen(EDf)==0)
				IntDf=IR1P_CheckRightResultsWvs(popStr)
				EDf=""
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:GeneralplottingTool:IntensityWaveName+\";---;\"+IR1P_ListOfWaves(\"Yaxis\")")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:GeneralplottingTool:ErrorWaveName+\";---;\"+IR1P_ListOfWaves(\"Error\")")
			endif
		else
			QDf=""
		endif
	endif
	
	if (cmpstr(ctrlName,"ErrorDataName")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			EDf=popStr
			if (UseQRSData && strlen(IntDf)==0 && strlen(QDf)==0)
				IntDf="r"+popStr[1,inf]
				QDf="q"+popStr[1,inf]
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:GeneralplottingTool:IntensityWaveName+\";---;\"+IR1P_ListOfWaves(\"Yaxis\")")
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:GeneralplottingTool:QWaveName+\";---;\"+IR1P_ListOfWaves(\"Xaxis\")")
			endif
		else
			EDf=""		
		endif
	endif
end

Function DWS_GenPlotCheckBox(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	string folder=getdatafolder(1)
	SVAR 	ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
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
		DWS_AttachErrorBars()
	endif	
	if (cmpstr("GraphLegend",ctrlName)==0)
		//anything needs to be done here?
		if(checked)
			NVAR GraphLegendUseFolderNms=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
			NVAR GraphLegendUseWaveNote=root:Packages:GeneralplottingTool:GraphLegendUseWaveNote
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
			NVAR GraphLegendUseFolderNms=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
			NVAR GraphLegendUseWaveNote=root:Packages:GeneralplottingTool:GraphLegendUseWaveNote
			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(1+GraphLegendUseFolderNms+2*GraphLegendUseWaveNote),"=")
		endif
	endif
	if (cmpstr("GraphLegendUseWaveNote",ctrlName)==0)
		//anything needs to be done here?
		UseLegend=NumberByKey("Legend",ListOfGraphFormating,"=")
		if (UseLegend)
			NVAR GraphLegendUseFolderNms=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
			NVAR GraphLegendUseWaveNote=root:Packages:GeneralplottingTool:GraphLegendUseWaveNote
			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(1+GraphLegendUseFolderNms+2*GraphLegendUseWaveNote),"=")
		endif
	endif
	
	if (cmpstr("GraphUseSymbols",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph use Symbols",ListOfGraphFormating, num2str(checked),"=")
		variable UseLinesAlso=NumberByKey("Graph use Lines",ListOfGraphFormating,"=",";")
	endif
		
	if (cmpstr("GraphUseLines",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph use lines",ListOfGraphFormating, num2str(checked),"=")
	endif

	if (cmpstr("GraphUseColors",ctrlName)==0)
		//anything needs to be done here?
		checked+=1
		ListOfGraphFormating=ReplaceStringByKey("Graph use colors",ListOfGraphFormating, num2str(checked),"=")	
	endif
	
	if (cmpstr("GraphLeftAxisAuto",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Axis left auto",ListOfGraphFormating, num2str(checked),"=")
	endif
	if (cmpstr("GraphBottomAxisAuto",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Axis bottom auto",ListOfGraphFormating, num2str(checked),"=")
	endif
	if (cmpstr("GraphXMajorGrid",ctrlName)==0)
		//anything needs to be done here?   
		NVAR GraphXMajorGrid=root:Packages:GeneralplottingTool:GraphXMajorGrid
		NVAR GraphXMinorGrid=root:Packages:GeneralplottingTool:GraphXMinorGrid
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
		NVAR GraphXMajorGrid=root:Packages:GeneralplottingTool:GraphXMajorGrid
		NVAR GraphXMinorGrid=root:Packages:GeneralplottingTool:GraphXMinorGrid
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
			NVAR GraphYMajorGrid=root:Packages:GeneralplottingTool:GraphYMajorGrid
			NVAR GraphYMinorGrid=root:Packages:GeneralplottingTool:GraphYMinorGrid
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
		
		NVAR GraphYMajorGrid=root:Packages:GeneralplottingTool:GraphYMajorGrid
		NVAR GraphYMinorGrid=root:Packages:GeneralplottingTool:GraphYMinorGrid
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


function DWS_SetVarProc(ctrlName,varNum,varStr,varName)

	String ctrlName
	Variable varNum
	String varStr
	String varName
	string folder= getdatafolder(1)
	SVAR 	ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	
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
	endif
		if (cmpstr("TicRotation",ctrlName)==0)
		ModifyGraph tkLblRot(left)=varNum	
	endif
	
	if (cmpstr("GraphSymbolSize",ctrlName)==0)
		ListOfGraphFormating=ReplaceNumberByKey("msize",ListOfGraphFormating, varNum,"=")
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
		DWS_FixAxesInGraph()
	endif
	if (cmpstr("GraphLeftAxisMax",ctrlName)==0)		
		ListOfGraphFormating=ReplaceNumberByKey("Axis left max",ListOfGraphFormating, varNum,"=")
		DWS_FixAxesInGraph()
	endif
	if (cmpstr("GraphBottomAxisMin",ctrlName)==0)
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom min",ListOfGraphFormating, varNum,"=")
		DWS_FixAxesInGraph()
	endif
	if (cmpstr("GraphBottomAxisMax",ctrlName)==0)		
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom max",ListOfGraphFormating, varNum,"=")
		DWS_FixAxesInGraph()
	endif
	setdatafolder folder
end



Function DWS_InputPanelButtonProc(ctrlName) : ButtonControl
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
			DWS_CreateItem("variable",StringFromList(i,ListOfVariables))
		endfor		
		for(i=0;i<itemsInList(ListOfStrings);i+=1)	
			DWS_CreateItem("string",StringFromList(i,ListOfStrings))
		endfor		
	
	variable IsAllAllRight

	if ((cmpstr(ctrlName,"AddDataToGraph")==0)||(cmpstr(ctrlName,"newgraph")==0))
		//here goes what is done, when user pushes Graph button
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
		SVAR DFloc=root:Packages:GeneralplottingTool:DataFolderName
		SVAR DFInt=root:Packages:GeneralplottingTool:IntensityWaveName
		SVAR DFQ=root:Packages:GeneralplottingTool:QWaveName
		SVAR DFE=root:Packages:GeneralplottingTool:ErrorWaveName
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
			DWS_CreateGraph(1)   //create  the graph
		else
			DWS_CreateGraph(0)
		endif					
	endif	
	
	if (cmpstr(ctrlName,"SaveGraph")==0)
		string top= StringFromList(0,WinList("*", ";", "WIN:1"))
		DoWindow/F $top
		string cmd= "DoIgorMenu  \"Control\", \"Window control\""
		execute/P cmd
	endif
	
	if (cmpstr(ctrlName,"Standard")==0)
		execute "StdGraph()"//(width,maxY,minY,BW,ylabel,xlabel,modetype,aspect)
	endif
	
	if (cmpstr(ctrlName,"Capture")==0)
		GetAxis /Q left
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
		NVAR GraphLeftAxisAuto=root:Packages:GeneralplottingTool:GraphLeftAxisAuto
		NVAR GraphLeftAxisMin=root:Packages:GeneralplottingTool:GraphLeftAxisMin
		NVAR GraphLeftAxisMax=root:Packages:GeneralplottingTool:GraphLeftAxisMax
		NVAR GraphBottomAxisAuto=root:Packages:GeneralplottingTool:GraphBottomAxisAuto
		NVAR GraphBottomAxisMin=root:Packages:GeneralplottingTool:GraphBottomAxisMin
		NVAR GraphBottomAxisMax=root:Packages:GeneralplottingTool:GraphBottomAxisMax
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
		FormatGraph(0)
	endif
	
	if (cmpstr(ctrlName,"Legends")==0)
		DWS_AttachLegend()
	endif
	
	if (cmpstr(ctrlName,"killLegends")==0)
			NVAR GraphLegendUseFolderNms=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
			NVAR GraphLegendUseWaveNote=root:Packages:GeneralplottingTool:GraphLegendUseWaveNote		
		if(GraphLegendUseFolderNms==0)
			TextBox/K/N=FolderLegend
		endif
		if (GraphLegendUseWaveNote==0)
			TextBox/K/N=waveLegend
		endif
		DWS_AttachLegend()
	endif
	
	if (cmpstr(ctrlName,"ChangeAx")==0)
		DWS_FixAxesInGraph()
	endif
	
	if (cmpstr(ctrlName,"Hermans1")==0)	
		SVAR DFLoc2=root:Packages:SAS_Modeling:DataFolderName
		setdatafolder DFLoc2
		NVAR Fold=root:Packages:SAS_Modeling:fold
		fold = 0
		execute "HermansPanel()"
	endif
	
	if (cmpstr(ctrlName,"Hermans")==0)	
		
		SVAR DFLoc1=root:Packages:GeneralPlottingTool:DataFolderName
		SVAR DFLoc2=root:Packages:SAS_Modeling:DataFolderName
		DFLoc2=DFloc1
		setdatafolder DFLoc2
		string rwave="AnisointensityCorr", xwave= "sa"
		NVAR Orientation =root:Packages:SAS_Modeling:Orientation
		NVAR Fold=root:Packages:SAS_Modeling:fold
		orientation = 0
		fold = 0
		execute "UNICAT_AzamuthalPanel()"
	endif
end



Function DWS_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked	
		NVAR UseIndra2Data=root:Packages:GeneralplottingTool:UseIndra2Data
		NVAR UseQRSData=root:Packages:GeneralplottingTool:UseQRSData
		NVAR UseResults=root:Packages:GeneralplottingTool:UseResults
		NVAR UseAniso=root:Packages:GeneralplottingTool:UseAniso		
		SVAR Dtf=root:Packages:GeneralplottingTool:DataFolderName
		SVAR IntDf=root:Packages:GeneralplottingTool:IntensityWaveName
		SVAR QDf=root:Packages:GeneralplottingTool:QWaveName
		SVAR EDf=root:Packages:GeneralplottingTool:ErrorWaveName
		SVAR xname=root:Packages:GeneralplottingTool:GraphXAxisName
		SVAR yname=root:Packages:GeneralplottingTool:GraphyAxisName
		xname="\F'Helvetica'\Z14q (A\S-1\M)"
		yname="\F'Helvetica'\Z14Intensity (cm)\S-1"
				
		Dtf=" "
		IntDf=" "
		QDf=" "
		EDf=" "
		PopupMenu SelectDataFolder mode=1
		PopupMenu IntensityDataName   mode=1, value="---"
		PopupMenu QvecDataName    mode=1, value="---"
		PopupMenu ErrorDataName    mode=1, value="---"
		
		string top= StringFromList(0,WinList("DWS_GraphPanel", ";", "WIN:1"))
		If (stringmatch(top, "DWS_GraphPanel" ))
		
		//DoWindow/F $top
		//string cmd= "DoIgorMenu  \"Control\", \"Window control\""
	
			Button Hermans,win =DWS_GraphPanel, disable=1  ,pos={220,495},size={100,20}
			Button Hermans font="Times New Roman",fSize=10,proc=DWS_InputPanelButtonProc,title="Hermans"
		endif
	if (cmpstr(ctrlName,"UseIndra2Data")==0)
		if (checked)
			UseQRSData=0
			UseResults=0
			UseAniso=0
		endif
	endif
	if (cmpstr(ctrlName,"UseQRSData")==0)
		if (checked)
			UseIndra2Data=0
			UseResults=0
			UseAniso=0
		endif

	endif
	if (cmpstr(ctrlName,"UseResults")==0)//dws
		DoAlert 0, "Currently not implimented\r see panel code"
		if (checked)
			UseIndra2Data=0
			UseQRSData=0
			UseAniso=0
		endif		
	endif
	
	if (cmpstr(ctrlName,"UseAniso")==0)//dws
		DoAlert 0, "Currently not implimented\r see panel code"
		Useaniso=checked
		if (checked)
			UseIndra2Data=0
			UseQRSData=0
			UseResults=0
			Button Hermans,win =DWS_GraphPanel, disable=0   ,pos={220,495},size={100,20},font="Times New Roman",fSize=10,proc=DWS_InputPanelButtonProc,title="Hermans"
		xname="\F'Helvetica'\Z14Azamuthal Angle (Deg)"
		yname="\F'Helvetica'\Z14Intensity"
		endif	
	endif	
end

Function/T DWS_ListOfWaves(DataType)
	string DataType			//data type   : Xaxis, Yaxis, Error
	
	NVAR UseIndra2Data=root:packages:GeneralplottingTool:UseIndra2Data
	NVAR UseQRSData=root:packages:GeneralplottingTool:UseQRSData
	NVAR UseResults=root:packages:GeneralplottingTool:UseResults
	NVAR UseAniso=root:packages:GeneralplottingTool:UseAniso
	Nvar iWavesOnly=root:packages:GeneralplottingTool:iWavesOnly
	SVAR FldrNm=root:Packages:GeneralplottingTool:DataFolderName//seems like inconsistent choice of data folder
	string result="", tempresult="", tempStringQ="", tempStringR="", tempStringS=""
	
	variable i,j
		
	if (UseIndra2Data)
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
		tempresult=""
		if(cmpstr(DataType,"Xaxis")==0)
			if(stringMatch(result,"*DSM_Qvec*"))
				for (i=0;i<ItemsInList(result);i+=1)
					if (stringMatch(StringFromList(i,result),"*DSM_Qvec*"))
						tempresult+=StringFromList(i,result)+";"
					endif
				endfor
				For (j=0;j<ItemsInList(result);j+=1)
					if (stringMatch(StringFromList(j,result),"*BKG_Qvec*"))
						tempresult+=StringFromList(j,result)+";"
					endif
				endfor
			endif
		elseif (cmpstr(DataType,"Yaxis")==0)
			if(stringMatch(result,"*DSM_Int*"))
				for (i=0;i<ItemsInList(result);i+=1)
					if (stringMatch(StringFromList(i,result),"*DSM_Int*"))
						tempresult+=StringFromList(i,result)+";"
					endif
				endfor
				For (j=0;j<ItemsInList(result);j+=1)
					if (stringMatch(StringFromList(j,result),"*BKG_Int*"))
						tempresult+=StringFromList(j,result)+";"
					endif
				endfor
			endif
		else// (cmpstr(DataType,"Error")==0)
			if(stringMatch(result,"*DSM_Error*"))
				for (i=0;i<ItemsInList(result);i+=1)
					if (stringMatch(StringFromList(i,result),"*DSM_Error*"))
						tempresult+=StringFromList(i,result)+";"
					endif
				endfor
				For (j=0;j<ItemsInList(result);j+=1)
					if (stringMatch(StringFromList(j,result),"*BKG_Error*"))
						tempresult+=StringFromList(j,result)+";"
					endif
				endfor
			endif
		endif
			result=tempresult
	elseif(UseQRSData) 
		result=""			//IN2G_CreateListOfItemsInFolder(FldrNm,2)
		tempStringQ=IR1_ListOfWavesOfType("q",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		tempStringR=IR1_ListOfWavesOfType("r",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		tempStringS=IR1_ListOfWavesOfType("s",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		
		if (cmpstr(DataType,"Yaxis")==0)
			For (j=0;j<ItemsInList(tempStringR);j+=1)
				if (stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringR)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringR)[1,inf]+";*"))
					result+=StringFromList(j,tempStringR)+";"
				endif
			endfor
		elseif(cmpstr(DataType,"Xaxis")==0)
			For (j=0;j<ItemsInList(tempStringQ);j+=1)
				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringQ)[1,inf]+";*"))
					result+=StringFromList(j,tempStringQ)+";"
				endif
			endfor
		else
			For (j=0;j<ItemsInList(tempStringS);j+=1)
				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringS)[1,inf]+";*") && stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringS)[1,inf]+";*"))
					result+=StringFromList(j,tempStringS)+";"
				endif
			endfor
		endif
	elseif (UseResults)
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
		tempresult=""
		string tempstr
		if(cmpstr(DataType,"Xaxis")==0)
			For (j=0;j<ItemsInList(result);j+=1)
			tempstr= StringFromList(j,result)
				if (stringMatch(tempstr,"UnifiedFitQvector*") || stringMatch(tempstr,"SizesFitQvector*")|| stringMatch(tempstr,"SizesDistDiameter*") ||stringMatch(tempstr,"ModelingDiameters*") || stringMatch(tempstr,"FractFitQvector*") || stringMatch(tempstr,"ModelingQvector*"))
					tempresult+=tempstr+";"
				endif
			endfor		
		elseif (cmpstr(DataType,"Yaxis")==0)
			For (j=0;j<ItemsInList(result);j+=1)
			tempstr= StringFromList(j,result)
				if (stringMatch(tempstr,"UnifiedFitIntensity*") || stringMatch(tempstr,"SizesFitIntensity*") || stringMatch(tempstr,"SizesVolumeDistribution*")|| stringMatch(tempstr,"SizesNumberDistribution*") ||stringMatch(tempstr,"ModelingNumberDistribution*")||stringMatch(tempstr,"ModelingVolumeDistribution*") || stringMatch(tempstr,"FractFitIntensity*") || stringMatch(tempstr,"ModelingIntensity*"))
					tempresult+=tempstr+";"
				endif
			endfor		
		else		//error
			result = "---"
		endif
		result = tempresult
	elseif (UseAniso)
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
		tempresult=""
		
		if(cmpstr(DataType,"Xaxis")==0)
			For (j=0;j<ItemsInList(result);j+=1)
			tempstr= StringFromList(j,result)
				if (stringMatch(tempstr,"sa") )
					tempresult+=tempstr+";"
				endif
			endfor		
		elseif (cmpstr(DataType,"Yaxis")==0)
			For (j=0;j<ItemsInList(result);j+=1)
			tempstr= StringFromList(j,result)
				if (stringMatch(tempstr,"Anis*"))
					tempresult+=tempstr+";"
				endif
			endfor		
		else		//error
			result = "---"
		endif
		result = tempresult
	elseif(iWavesonly)
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
		tempresult=""
			For (j=0;j<ItemsInList(result);j+=1)
			tempstr= StringFromList(j,result)
				if (stringMatch(tempstr,"i*") )
					tempresult+=tempstr+";"
				endif
			endfor	
		result = tempresult
	else
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
	endif
	return result
end

Function/T DWS_GenStringOfFolders(fullpath)//need to add full path
	variable fullpath
		
	NVAR UseIndra2Structure=root:packages:GeneralplottingTool:UseIndra2Data
	NVAR UseQRSStructure=root:packages:GeneralplottingTool:UseQRSData
	NVAR UseResults=root:packages:GeneralplottingTool:UseResults
	NVAR UseAniso=root:packages:GeneralplottingTool:UseAniso
	NVAR iWavesOnly=root:packages:GeneralPlottingTool:iWavesOnly
	string ListOfQFolders=""
	string result=""
	if (UseIndra2Structure)
		result=DWS_FindFolderWithWaveTypes("root:USAXS:", 10, "*DSM*", fullpath)
	endif
	if (UseQRSStructure)
		ListOfQFolders=DWS_FindFolderWithWaveTypes("root:", 10, "q*", fullpath)
		result+=ListOfQFolders//ReturnListQRSFolders(ListOfQFolders)
	endif
	if (UseAniso)
		ListOfQFolders=IN2G_FindFolderWithWaveTypes("root:", 10, "Anis*", fullpath)
		result+=ListOfQFolders//ReturnListResultsFolders(ListOfQFolders)
	endif
	if(useResults)
			ListOfQFolders+=IN2G_FindFolderWithWaveTypes("root:", 10, "UnifiedFitIntensity*", fullpath)
			ListOfQFolders+=IN2G_FindFolderWithWaveTypes("root:", 10, "SizesDistributionVolume", fullpath)
			ListOfQFolders+=IN2G_FindFolderWithWaveTypes("root:", 10, "ModelingVolumeDistribution*", fullpath)
			ListOfQFolders+=IN2G_FindFolderWithWaveTypes("root:", 10, "FractFitIntensity*", fullpath)		
		result+=ReturnListResultsFolders(ListOfQFolders)
	endif
	if (iWavesOnly)
		result+=DWS_FindFolderWithWaveTypes("root:", 10, "i*", fullpath)
	endif
	if ((!UseQRSStructure&!UseAniso&!iWavesOnly&!useResults&!UseIndra2Structure))
		result=IN2G_FindFolderWithWaveTypes("root:", 10, "*", fullpath)
	endif
	return result
end

