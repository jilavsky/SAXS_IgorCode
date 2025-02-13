#pragma rtGlobals=1		// Use modern global access method.

menu "Plot&fit"
	"-"
	Submenu "Major Tools"
		"DWS Plotting tool/1",DWS_GeneralPlotTool()
		"Background Subtraction Tool/2",DWS_DataManipulationPanel()
	end
end

Function MoveSelectionTools(XPOS, YPOS)//works with IR2C_AddDataControls
	Variable XPOS, YPOS
	String Checkboxes=ControlNameList("", ";" ,"Use*")
	print checkboxes
	IF(-1!=strsearch(checkboxes, "UseQRSData",0,2))
		CheckBox UseQRSData pos={XPOS,YPOS}
	Elseif(-1!=strsearch(checkboxes, "UseIndra2Data",0,2))
		CheckBox UseIndra2Data pos={XPOS,YPOS+13}
	Elseif(-1!=strsearch(checkboxes, "UseResults",0,2))
		CheckBox UseResults pos={XPOS+100,YPOS}
	elseif (-1!=strsearch(checkboxes, "UseUserDefinedData",0,2))
		CheckBox UseUserDefinedData pos={XPOS+100,YPOS+13}
	endif
	YPOS=YPOS+5
	PopupMenu SelectDataFolder pos={XPOS,YPOS+23}
	PopupMenu IntensityDataName pos={XPOS,YPOS+73}
	PopupMenu QvecDataName pos={XPOS,YPOS+48}
	PopupMenu ErrorDataName pos={XPOS,YPOS+98}	
	PopupMenu QvecDataName title="X Wave"
	PopupMenu IntensityDataName title="Y Wave"
	PopupMenu ErrorDataName title="S Wave"
	PopupMenu SelectDataFolder title="Folder"
end

function LocateValue(waven, value,Start,LessEqualGreater)		
	string waven
	variable value,LessEqualGreater,start
	Variable N,i,result
	wave w=$waven
	N=numpnts(w)
	for(i=start;i<N;i+=1)
	
		If(LessEqualGreater==0)			
				result =(w[i]<value	)		
			elseif(LessEqualGreater==1)	
				result =(w[i]==value)
			else
				result= (w[i]>value)
		endif
	
		If(result==1)
			return i
			break							
		endif										
	endfor
end


Function/s Findtrace(type)//"top","bottom" or "tracename"
	string type
	string tracename,tracelist
	tracelist=TraceNameList("", ";", 1 )
		if (stringmatch(type, "top" ))
			tracename=StringFromList(ItemsInList(tracelist)-1, tracelist,";")
		elseif (stringmatch(type, "bottom" ))
			tracename=StringFromList(0, tracelist,";")
		Else//finds a specific trace
			tracename=StringFromList(WhichListItem(type, tracelist), tracelist)//returns null if not present
		Endif
	return tracename
end

		
Function DWS_GeneralPlotTool()
	IN2G_CheckScreenSize("height",670)
	DWS_GeneralPlotTool_Initialize()	
	dowindow/K DWS_GraphPanel
	NewPanel /K=1/N=DWS_GraphPanel /W=(50,43.25,430.75,570) as "General Plotting tool"
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman",fsize= 18,fstyle= 3,textrgb= (0,0,52224)
	DrawText 57,22,"Plotting tool input panel"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,199,339,199
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 8,49,"Data input"
	
	CheckBox UseAniso,pos={230,39},size={141,14},proc=DWS_InputPanelCheckboxProc,title="Use Aniso results"
	CheckBox UseAniso,variable= root:packages:GeneralplottingTool:UseAniso, help={"Check, if you want to use results of Anisotropic results"}
	
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("GeneralplottingTool","DWS_GraphPanel","M_DSM_Int;DSM_Int;M_SMR_Int;SMR_Int","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,0)

	//need to add controls below for aniso and  irina to work.  Also remove abov e 5 lines.
	//Experimental data input
//	CheckBox UseIndra2Data,pos={110,25},size={141,14},proc=DWS_InputPanelCheckboxProc,title="Use Indra 2 data"
//	CheckBox UseIndra2Data,variable= root:packages:GeneralplottingTool:UseIndra2data, help={"Check, if you are using Indra 2 produced data with the orginal names, uncheck if the names of data waves are different"}
//	CheckBox UseQRSData,pos={110,39},size={141,14},proc=DWS_InputPanelCheckboxProc,title="Use QRS data"
//	CheckBox UseQRSData,variable= root:packages:GeneralplottingTool:UseQRSdata, help={"Check, if you are using QRS names, uncheck if the names of data waves are different"}
	//CheckBox UseResults,pos={350,25},size={141,14},proc=DWS_InputPanelCheckboxProc,title="Use Irena 1 results"
	//CheckBox UseResults,variable= root:packages:GeneralplottingTool:UseResults, help={"Check, if you want to use results of Irena 1 macros"}	
	//PopupMenu SelectDataFolder,pos={8,56},size={180,21},title="Data folder:",proc=DWS_PanelPopupControl//IR1D_PanelPopupControl
	//PopupMenu SelectDataFolder,mode=1,popvalue="---",value= #"\"---;\"+DWS_GenStringOfFolders(1)"
	//PopupMenu QvecDataName,pos={9,80},size={179,21},proc=DWS_PanelPopupControl,title="Wave with X axis data  ", help={"Select wave with data to be used on X axis (Q, diameters, etc)"}
	//PopupMenu QvecDataName,mode=1,popvalue="---",value= #"\"---;\"+DWS_ListOfWaves(\"Xaxis\")"
	//PopupMenu IntensityDataName,pos={8,106},size={180,21},proc=DWS_PanelPopupControl,title="Wave with Y axis data  ", help={"Select wave with data to be used on Y data (Intensity, distributions)"}
	//PopupMenu IntensityDataName,mode=1,popvalue="---",value= #"\"---;\"+DWS_ListOfWaves(\"Yaxis\")"
	//PopupMenu ErrorDataName,pos={10,133},size={178,21},proc=DWS_PanelPopupControl,title="Wave with Error data   ", help={"Select wave with error data"}
	//PopupMenu ErrorDataName,mode=1,popvalue="---",value= #"\"---;\"+DWS_ListOfWaves(\"Error\")"
	Button newgraph,pos={5,165},size={80,20},font="Times New Roman",fSize=10,proc=DWS_InputPanelButtonProc,title="New Graph"
	Button AddDataToGraph,pos={90,165},size={80,20},font="Times New Roman",fSize=10,proc=DWS_InputPanelButtonProc,title="Add data"
	Button SaveGraph,pos={265,165},size={80,20},font="Times New Roman",fSize=10,proc=DWS_InputPanelButtonProc,title="Save Graph"
	Button Standard,pos={175,165},size={85,20},font="Times New Roman",fSize=10,proc=DWS_InputPanelButtonProc,title="Standard"
	
//graph controls
	CheckBox GraphLogX pos={60,210},title="Log X axis?", variable=root:Packages:GeneralplottingTool:GraphLogX
	CheckBox GraphLogX proc=DWS_GenPlotCheckBox
	CheckBox GraphLogY pos={140,210},title="Log Y axis?", variable=root:Packages:GeneralplottingTool:GraphLogY
	CheckBox GraphLogY proc=DWS_GenPlotCheckBox
	CheckBox GraphErrors pos={240,210},title="Error bars?", variable=root:Packages:GeneralplottingTool:GraphErrors
	CheckBox GraphErrors proc=DWS_GenPlotCheckBox

	SetVariable GraphXAxisName pos={60,235},size={300,20},proc=DWS_SetVarProc,title="X axis title"
	SetVariable GraphXAxisName value= root:Packages:GeneralplottingTool:GraphXAxisName, help={"Input horizontal axis title. Use Igor formating characters for special symbols."}	
	SetVariable GraphYAxisName pos={60,255},size={300,20},proc=DWS_SetVarProc,title="Y axis title"
	SetVariable GraphYAxisName value= root:Packages:GeneralplottingTool:GraphYAxisName, help={"Input vertical axis title. Use Igor formating characters for special symbols."}		

	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,280,339,280
//legends
	DrawText 60,298,"Legends:"
	CheckBox GraphLegendUseFolderNms pos={120,285},title="Folder Names", variable=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
	CheckBox GraphLegendUseFolderNms proc=DWS_GenPlotCheckBox, help={"Use folder names in Legend?"}	
	CheckBox GraphLegendUseWaveNote pos={220,285},title="Wave Names", variable=root:Packages:GeneralplottingTool:GraphLegendUseWaveNote
	CheckBox GraphLegendUseWaveNote proc=DWS_GenPlotCheckBox, help={"Wave Names"}	
	PopupMenu GraphLegendSize,pos={60,305},size={180,20},proc=DWS_PanelPopupControl,title="Legend font size", help={"Select font size for legend to be used."}
	PopupMenu GraphLegendSize,mode=1,value= "06;08;10;12;14;16;18;20;22;24;", popvalue="10"
	Button Legends,pos={270,305},size={70,20},font="Times New Roman",fSize=10,proc=DWS_InputPanelButtonProc,title="Add Legend"
		Button KillLegends,pos={200,305},size={70,20},font="Times New Roman",fSize=10,proc=DWS_InputPanelButtonProc,title="Kill Legend"

	
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,330,339,330
	
	
	//Graph Line & symbols
	CheckBox GraphUseSymbols pos={60,340},title="Use symbols?", variable=root:Packages:GeneralplottingTool:GraphUseSymbols
	CheckBox GraphUseSymbols proc=DWS_GenPlotCheckBox, help={"Use symbols and vary them for the data?"}
	CheckBox GraphUseLines pos={60,360},title="Use lines?", variable=root:Packages:GeneralplottingTool:GraphUseLines
	CheckBox GraphUseLines proc=DWS_GenPlotCheckBox, help={"Use lines them for the data?"}
	SetVariable GraphSymbolSize pos={150,340},size={90,20},proc=DWS_SetVarProc,title="Symbol size", limits={1,20,1}
	SetVariable GraphSymbolSize value= root:Packages:GeneralplottingTool:GraphSymbolSize, help={"Symbol size same for all."}		
	SetVariable GraphLineWidth pos={150,360},size={90,20},proc=DWS_SetVarProc,title="Line width  ", limits={1,4,1}
	SetVariable GraphLineWidth value= root:Packages:GeneralplottingTool:GraphLineWidth, help={"Line width, same for all."}		
	CheckBox GraphUseColors pos={270,340},title="Black&White", variable=root:Packages:GeneralplottingTool:GraphUseColors
	CheckBox GraphUseColors proc=DWS_GenPlotCheckBox, help={"colors"}	
	Button Format,pos={270,355},size={70,20},font="Times New Roman",fSize=10,proc=DWS_InputPanelButtonProc,title="Change Mode"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,380,339,380
	
	//Bottom Axis format
	CheckBox GraphXMajorGrid pos={60,390},title="X Major Grid", variable=root:Packages:GeneralplottingTool:GraphXMajorGrid
	CheckBox GraphXMajorGrid proc=DWS_GenPlotCheckBox, value=1,help={"Check to add major grid lines to horizontal axis"}
	CheckBox GraphXMinorGrid pos={160,390},title="X Minor Grid?", variable=root:Packages:GeneralplottingTool:GraphXMinorGrid
	CheckBox GraphXMinorGrid proc=DWS_GenPlotCheckBox, help={"Check to add minor grid lines to horizontal axis. May not display if graph would be too crowded."}

	//left axis format	
	CheckBox GraphYMajorGrid pos={60,410},title="Y Major Grid", variable=root:Packages:GeneralplottingTool:GraphYMajorGrid
	CheckBox GraphYMajorGrid proc=DWS_GenPlotCheckBox,value=1, help={"Check to add major grid lines to vertical axis"}
	CheckBox GraphYMinorGrid pos={160,410},title="Y Minor Grid", variable=root:Packages:GeneralplottingTool:GraphYMinorGrid
	CheckBox GraphYMinorGrid proc=DWS_GenPlotCheckBox, help={"Check to add minor grid lines to vertical axis. May not display if graph would be too crowded."}

	SetVariable GraphAxisWidth pos={260,390},size={90,20},proc=DWS_SetVarProc,title="Axis width:", limits={1,5,1}
	SetVariable GraphAxisWidth value= root:Packages:GeneralplottingTool:GraphAxisWidth
	
	SetVariable TicRotation pos={250,410},size={100,20},proc=DWS_SetVarProc,title="Tic Rotation:", limits={0,90,90}
	SetVariable TicRotation, value= root:Packages:GeneralplottingTool:TicRotation
	
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,430,339,430
	
	//Axis ranges	
	CheckBox GraphLeftAxisAuto pos={80,435},title="Y axis autoscale?", variable=root:Packages:GeneralplottingTool:GraphLeftAxisAuto
	CheckBox GraphLeftAxisAuto proc=DWS_GenPlotCheckBox, help={"Autoscale Y (left) axis using data range?"}	
	CheckBox GraphBottomAxisAuto pos={250,435},title="X axis autoscale?", variable=root:Packages:GeneralplottingTool:GraphBottomAxisAuto
	CheckBox GraphBottomAxisAuto proc=DWS_GenPlotCheckBox, help={"Autoscale X (bottom) axis using data range?"}	
	
	NVAR LeftAxisMin=root:Packages:GeneralplottingTool:GraphLeftAxisMin
	NVAR LeftAxisMax=root:Packages:GeneralplottingTool:GraphLeftAxisMax
	NVAR BottomAxisMin=root:Packages:GeneralplottingTool:GraphBottomAxisMin
	NVAR BottomAxisMax=root:Packages:GeneralplottingTool:GraphBottomAxisMax
	
	
	SetVariable GraphLeftAxisMin pos={80,455},size={140,20},proc=DWS_SetVarProc,title="Min: ", limits={0,inf,1e-6+LeftAxisMin}
	SetVariable GraphLeftAxisMin value= root:Packages:GeneralplottingTool:GraphLeftAxisMin, format="%4.4e",help={"Minimum on Y (left) axis"}		
	SetVariable GraphLeftAxisMax pos={80,475},size={140,20},proc=DWS_SetVarProc,title="Max:", limits={0,inf,1e-6+LeftAxisMax}
	SetVariable GraphLeftAxisMax value= root:Packages:GeneralplottingTool:GraphLeftAxisMax, format="%4.4e", help={"Maximum on Y (left) axis"}		

	
	SetVariable GraphBottomAxisMin pos={230,455},size={140,20},proc=DWS_SetVarProc,title="Min: ", limits={0,inf,1e-6+BottomAxisMin}
	SetVariable GraphBottomAxisMin value= root:Packages:GeneralplottingTool:GraphBottomAxisMin, format="%4.4e", help={"Minimum on X (bottom) axis"}			
	SetVariable GraphBottomAxisMax pos={230,475},size={140,20},proc=DWS_SetVarProc,title="Max:", limits={0,inf,1e-6+BottomAxisMax}
	SetVariable GraphBottomAxisMax value= root:Packages:GeneralplottingTool:GraphBottomAxisMax, format="%4.4e", help={"Maximum on X (bottom) axis"}		
	
	Button Capture,pos={10,450},size={60,20},font="Times New Roman",fSize=10,proc=DWS_InputPanelButtonProc,title="Capture"
	Button ChangeAx,pos={10,475},size={60,20},font="Times New Roman",fSize=10,proc=DWS_InputPanelButtonProc,title="Change"
	NVAR anisocheck =root:packages:GeneralplottingTool:UseAniso
	IF(anisocheck==1)
		Button Hermans,win =DWS_GraphPanel, disable=0  ,pos={220,495},size={100,20}
		Button Hermans font="Times New Roman",fSize=10,proc=DWS_InputPanelButtonProc,title="Hermans"
	endif
	
end

Function DWS_DataManipulationPanel()
		IN2G_CheckScreenSize("height",670)
	DoWindow DWS_DataManipulationPanel
	if(V_Flag)
		DoWindow/K DWS_DataManipulationPanel
	endif
	IR1D_InitDataManipulation()
	setdatafolder root:Packages:SASDataModification
	variable/g Data1_Thickness
	make/o/N=2 xavedata,yavedata
	xavedata={ .001, .1}
	yavedata={ 1e4, .01}
	PlotData("yavedata","xavedata", "")
end



Function plotdata(rwavename,qwavename, text)
	string rwavename,qwavename, text
	wave rwave=$rwavename
	wave qwave=$qwavename			
	NVAR UseIndra2Data=root:Packages:SASDataModification:UseIndra2Data
	NVAR UseQRSData=root:Packages:SASDataModification:UseQRSdata
	NVAR Data1_Thickness=root:Packages:SASDataModification:Data1_Thickness
	UseQRSdata=1
	UseIndra2Data=0
	variable thickness
	Data1_Thickness=thickness
	dowindow/K LoaderGraph
	Display/K=1/N=LoaderGraph/W=(50, 50, 300, 300 ) rwave vs qwave
	ModifyGraph font="Helvetica", width=350, height=300, lblMargin(left)=6
	DoWindow /T LQD, "LoaderGraph"
	ControlBar /T 310
	
	String PckgDataFolder="LoaderGraph"
	String PanelWindowName="LoaderGraph"
	String AllowedIrenaTypes=""//"DSM_Int;SMR_Int;"
	String AllowedResultsTypes=""//"SizesNumberDistribution;SizesVolumeDistribution;"
	String AllowedUserTypes=""//"*_par;" or "r*;"	
	String UserNameString=""//"_par" or "qrs"
	String XUserTypeLookup=""//"r*:q*;"	
	String EUserTypeLookup=""//"s*;"
	variable RequireErrorWaves=0
	variable  AllowModelData=0	
	IR2C_AddDataControls(PckgDataFolder,PanelWindowName,AllowedIrenaTypes, AllowedResultsTypes, AllowedUserTypes, UserNameString, XUserTypeLookup,EUserTypeLookup, RequireErrorWaves,AllowModelData)	
	MoveSelectionTools(2,2)
	
	variable YPOS=130//Data Selection
	Button AverageCursors,pos={0,YPOS},size={60,16},font="Times New Roman",fSize=10,proc=DWS_LoaderButtonProc,title="AveCsrs"
	Button Subtract,pos={260,YPOS},size={60,16},font="Times New Roman",fSize=10,proc=DWS_LoaderButtonProc,title="Subtract"
	//Button Normalize,pos={120,5},size={60,16},font="Times New Roman",fSize=10,proc=DWS_LoaderButtonProc,title="Normilize"
	SetVariable Data1_Background, pos={65,YPOS}, size={80,20},title="bkg", proc=DWS_setvarDataManip
	SetVariable Data1_Background, value= root:Packages:SASDataModification:Data1_Background
	SetVariable Data1_Thickness, pos={150,YPOS}, size={100,20},title="Thick(cm)", proc=DWS_setvarDataManip
	SetVariable Data1_Thickness, value= root:Packages:SASDataModification:Data1_Thickness
	YPOS =150
	Button Plotdata,pos={0,YPOS},size={60,16},font="Times New Roman",fSize=10,proc=DWS_LoaderButtonProc,title="PlotDATA"		
	Button RestoreRwave,pos={65,YPOS},size={60,16},font="Times New Roman",fSize=10,proc=DWS_LoaderButtonProc,title="Restore"
	Button LoadLQD,pos={130,YPOS},size={60,16},font="Times New Roman",fSize=10,proc=DWS_LoaderButtonProc,title="Load Waves"	
	Button RemoveTrace,pos={190,YPOS},size={65,16},font="Times New Roman",fSize=10,proc=DWS_LoaderButtonProc,title="RemoveTrace"	

	YPOS=183//Background Selections
	PopupMenu SelectDataFolder2,pos={8,YPOS},size={100,15},fSize=10,proc=IR1D_PanelPopupControl,title="Bkg:", help={"Background"}
	PopupMenu SelectDataFolder2,mode=1,popvalue="---",value= #"\"---;\"+IR1_GenStringOfFolders(root:Packages:SASDataModification:UseIndra2Data, root:Packages:SASDataModification:UseQRSData,2,1)"
	PopupMenu QvecDataName2,pos={9,YPOS+25},size={25,15},fSize=10,proc=IR1D_PanelPopupControl,title="Q"
	PopupMenu QvecDataName2,mode=1,popvalue="---",value= #"\"---;\"+IR1_ListOfWaves(\"DSM_Qvec\",\"SASDataModification\",1)"
	PopupMenu IntensityDataName2,pos={8,YPOS+50},size={100,15},fSize=10,proc=IR1D_PanelPopupControl,title="R"
	PopupMenu IntensityDataName2,mode=1,popvalue="---",value= #"\"---;\"+IR1_ListOfWaves(\"DSM_Int\",\"SASDataModification\",1)"
	PopupMenu ErrorDataName2,pos={10,YPOS+75},size={100,21},fSize=10,proc=IR1D_PanelPopupControl,title="S"
	PopupMenu ErrorDataName2,mode=1,popvalue="---",value= #"\"---;\"+IR1_ListOfWaves(\"DSM_Error\",\"SASDataModification\",1)"

	Button PlotBkg,pos={0,YPOS+100},size={60,16},font="Times New Roman",fSize=10,proc=DWS_LoaderButtonProc,title="Plot Bkg"	
	Button SubtractBkg,pos={65,YPOS+100},size={80,16},font="Times New Roman",fSize=10,proc=DWS_LoaderButtonProc,title="Subtract Bkg"	
	

	TextBox/C/N=text0/A=MC text
	ModifyGraph log=1, tick=2,axThick=2,msize=1,mrkThick=3, mode=3,marker=19
	ModifyGraph grid=2,mirror=1,minor(bottom)=1,fStyle=1,fSize=18,logLabel(left)=0
	ModifyGraph font="Helvetica", width=350, height=300, lblMargin(left)=6
	ModifyGraph rgb($rwavename)=(0,0,0),mode($rwavename)=3
	Label left "\\Z18\\f01\\F'Helvetica'Intensity (cm\\S-1\\M\\Z18\\f01)"
	Label bottom "\\Z18\\f01\\F'Helvetica'q (A\\S-1\\M\\Z18\\f01)"
	string n=num2str(numpnts(rwave))
	execute("cursor b,"+rwavename+","+n)
	n=num2str(numpnts(rwave)-10)
	execute("cursor a,"+rwavename+","+n)
	ShowInfo
	textBox/K/N=text0
	
end

Function DWS_LoaderButtonProc(ctrlName) : ButtonControl
	String ctrlName
	SVAR BKGFolder=root:Packages:SASDataModification:DataFolderName2
	SVAR BKGIntensityWavename=root:Packages:SASDataModification:IntensityWaveName2
	SVAR BKGQWavename=root:Packages:SASDataModification:QWavename2
		
	SVAR FolderName=root:Packages:SASDataModification:DataFolderName
	SVAR RWaveName=root:Packages:SASDataModification:IntensityWaveName
	SVAR QWaveName=root:Packages:SASDataModification:QWavename		
			
	NVAR Data1_Background=root:Packages:SASDataModification:Data1_Background
	NVAR Data1_IntMultiplier=root:Packages:SASDataModification:Data1_IntMultiplier	
	NVAR Data1_Thickness=root:Packages:SASDataModification:Data1_Thickness	

	string thefolder,thetext="",list,n,tracename
	variable counter = 0,NumberofWaves,background,start
	string wavenote, cmd
	setdatafolder BKGFolder
	wave  BKGIntensityWave=$replacestring("'",BKGIntensityWavename,"")
	wave BkgQWave=$replacestring("'",BKGQWavename,"")
	if (datafolderexists(foldername))
		setdatafolder foldername	
		wave RWave=$replacestring("'",Rwavename,"")
		wave QWave=$replacestring("'",Qwavename,"")
	endif
	NVAR qshift=root:Packages:SASDataModification:qshift
	
	IF(cmpstr(ctrlName,"RemoveTrace")==0)
		string tracelist=TraceNameList("LoaderGraph", ";", 1 )
		 tracename=StringFromList(0, tracelist,";")
		If (!stringmatch(tracename, "" ))
			tracename=StringFromList(1, tracelist,";")
			RemoveFromGraph $tracename
		else
			Legend/K/N=text1
			string boxname="CF_"+Rwavename
			TextBox/K/N=$boxname
		endif
		Legend/K/N=text1
	endif

	IF(cmpstr(ctrlName,"AverageCursors")==0)
		Wave w = CsrWaveRef(A)
		wave ww=CsrWaveRef(B)
		setdatafolder BKGfolder	
		if ((!WaveExists(w))||(!WaveExists(ww)))
			Doalert 0, "Cursor is not on graph"
			abort
		endif			
		WaveStats/r=[pcsr(A,"LoaderGraph"),pcsr(B,"LoaderGraph")]w
		Background=V_avg
		Data1_Background=Background
		Data1_IntMultiplier=1/Background
		setdatafolder root:Packages:SASDataModification
		make/o/N=2 xavedata,yavedata
		yavedata=Background
		 wave q = CsrXWaveRef(A  ,"LoaderGraph")
		xavedata={ q(pcsr(A,"LoaderGraph")), q[pcsr(B,"LoaderGraph")]}
		appendtograph  yavedata vs xavedata///n="IR1D_DataManipulationGraph"
		ModifyGraph lsize(yavedata)=3,rgb(yavedata)=(0,0,0)
	endif
	

	
	IF(cmpstr(ctrlName,"RestoreRwave")==0)//dws
		setdatafolder FolderName
		NVAR Thickness
		NVAR Thickness_orig		
		//wave RWave=$RWaveName
		wave R_orig
		Rwave=R_orig
		Thickness=Thickness_orig
		Data1_Thickness=Thickness_orig
	endif	
	

	
	IF(cmpstr(ctrlName,"PlotData")==0)	
		setdatafolder  FolderName
		NVAR Thickness
		Data1_Thickness	=thickness
		//wave RWave=$Rwavename	
		//wave QWave=$Qwavename	
		wave R_orig
		IF (!waveexists(R_orig))
			Duplicate RWave, R_orig
		endif			
		Appendtograph RWave vs QWave	
		list=TraceNameList("",";",1)
		NumberofWaves=ItemsInList(tracenamelist("",";",1))
		//do
		//	tracename=StringFromList(counter, list,";")//getstrfromlist (list, counter,";")
		//	theFolder=GetWavesDataFolder(WaveRefIndexed("",counter ,1),0)
		//	theText=theText+ "\r\s("+tracename+")"
		//	theText=theText+thefolder//theFolder[0,(strlen(theFolder)-0)]
			//counter+=1
		//while(counter<Numberofwaves)
		//TextBox/C/A=RT/N=FolderLegend theText	
		n=num2str(numpnts(RWave))
		execute("cursor b,"+PossiblyQuoteName(RWaveName )+","+n)
		n=num2str(numpnts(RWave)-20)
		execute("cursor a,"+PossiblyQuoteName(RWaveName )+","+n)
			Legend/C/N=text1
		ModifyGraph log=1

	endif
	
	IF(cmpstr(ctrlName,"PlotBkg")==0)//dws
		setdatafolder BKGfolder
		//wave BKGIntensityWave=$BKGIntensityWavename
				
		Appendtograph BKGIntensityWave vs BKGQWave	
		list=TraceNameList("",";",1)
		NumberofWaves=ItemsInList(tracenamelist("",";",1))
	//	do
		//	tracename=StringFromList(counter, list,";")//getstrfromlist (list, counter,";")
		//	theFolder=GetWavesDataFolder(WaveRefIndexed("",counter ,1),0)
		//	theText=theText+ "\r\s("+tracename+")"
		//	theText=theText+thefolder//theFolder[0,(strlen(theFolder)-0)]
		//	counter+=1
	//	while(counter<Numberofwaves)
	//	TextBox/C/A=RT/N=FolderLegend theText	
		n=num2str(numpnts(BKGIntensityWave))
		print n
		execute("cursor b,"+BKGIntensityWavename+","+n)
		n=num2str(numpnts(BKGIntensityWave)-20)
		execute("cursor a,"+BKGIntensityWavename+","+n)		
	endif
	
	IF(cmpstr(ctrlName,"SubtractBkg")==0)//dws		
		 Setdatafolder Foldername
		RWave-=BKGIntensityWave
	endif
	
	IF(cmpstr(ctrlName,"Subtract")==0)//dws
		setdatafolder FolderName

		Rwave-=Data1_Background
		//wavenote=note(Rwave)
		//execute ("Note/K "+ Rwavename)
		wavenote="    ;BackgroundSubtracted="+num2str(Data1_Background)+";"	
		 cmd="Note "+possiblyquotename(RWaveName)+",\""+wavenote+"\""
		print cmd
		execute (cmd)
	endif
	
	IF(cmpstr(ctrlName,"LoadLQD")==0)//dws
		execute("load1dLANL_SANS()")
	endif
	
end




Function DWS_setvarDataManip(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	string ,wavenote,cmd
	NVAR Data1_Background=root:Packages:SASDataModification:Data1_Background
	NVAR Data1_Thickness=root:Packages:SASDataModification:Data1_Thickness
	SVAR FolderName=root:Packages:SASDataModification:DataFolderName
	SVAR RWaveName=root:Packages:SASDataModification:IntensityWaveName
	if(cmpstr(ctrlName,"Data1_Background")==0)
		setdatafolder FolderName
		wave RWave=$RWaveName
		Rwave-=Data1_Background
		Wavenote="    ;BackgroundSubtracted="+num2str(Data1_Background)+";"	
		cmd="Note "+RWaveName+",\""+wavenote+"\""
		execute (cmd)
	endif 
	
	if(cmpstr(ctrlName,"Data1_Thickness")==0)
		setdatafolder FolderName
		wave RWave=$RWaveName
		NVAR Thickness
		Thickness=Data1_Thickness
		Rwave/=Data1_Thickness	
		 Wavenote="    ;Thickness="+num2str(Data1_Thickness)+";"	
		cmd="Note "+RWaveName+",\""+wavenote+"\""
		execute (cmd)
	endif
	if(cmpstr(ctrlName,"qshift")==0)
		DWS_LoaderButtonProc("shifq")	
	endif
	
End
function StripQuoteFromQRSnames()
	SVAR Dtf=root:Packages:GeneralplottingTool:DataFolderName
		SVAR IntDf=root:Packages:GeneralplottingTool:IntensityWaveName
		SVAR QDf=root:Packages:GeneralplottingTool:QWaveName
		SVAR EDf=root:Packages:GeneralplottingTool:ErrorWaveName
		IntDf =ReplaceString("'", IntDf, "")
		QDf =ReplaceString("'", QDf, "")
		EDf =ReplaceString("'", EDf, "")
End


function DWS_CreateGraph(new)
		variable new
		SVAR Dtf=root:Packages:GeneralplottingTool:DataFolderName
		SVAR IntDf=root:Packages:GeneralplottingTool:IntensityWaveName
		SVAR QDf=root:Packages:GeneralplottingTool:QWaveName
		SVAR EDf=root:Packages:GeneralplottingTool:ErrorWaveName
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
		variable lines, markers
		lines= NumberByKey("Graph use Lines", ListOfGraphFormating,"=",";")
		markers= NumberByKey("Graph use Symbols", ListOfGraphFormating,"=",";")
		setdatafolder Dtf
		StripQuoteFromQRSnames()
		
	if((new)||(cmpstr(WinList("*",";","WIN:1"), "" )==0))
		If(stringmatch (QDf,""))
			Display/N=GeneralGraph/K=1/W=(400,0,700,350 ) $IntDf as  "General Graph"
		Else
			Display/N=GeneralGraph/K=1/W=(400,0,700,350 ) $IntDf vs $QDf as  "General Graph"	
		endif		
		ModifyGraph grid=2,tick=2,minor=1,font="Times",zero(left)=1,standoff=0, mirror=1,tick=2,mirror=1,fStyle=1,fSize=12,standoff=0;DelayUpdate
		ModifyGraph axThick=2
		ShowInfo;ShowTools
			ModifyGraph log(bottom)=NumberByKey("log(bottom)", ListOfGraphFormating,"=",";")
		ModifyGraph log(left)=NumberByKey("log(left)", ListOfGraphFormating,"=",";")
		ModifyGraph axThick=NumberByKey("axthick", ListOfGraphFormating,"=",";")
		ModifyGraph msize=NumberByKey("msize", ListOfGraphFormating,"=",";")
		ModifyGraph lsize=NumberByKey("lsize", ListOfGraphFormating,"=",";")
	else
		If(stringmatch (QDf,""))
			AppendToGraph $IntDf
		else
			AppendToGraph $IntDf vs $QDf
		endif
	endif
	if (new)
		markers=0+ ((Lines==0)*(markers==1)*3)+((Lines==1)*(markers==1)*4)
	
		string tracelist, activetrace;variable total
		tracelist=TraceNameList("",";",1)
		total=ItemsInList(tracelist)
		activetrace =StringFromList(total-1, tracelist)
	//activetrace=TraceNameToWaveRef( "",activetrace )   ///actual wave name here
		ModifyGraph mode($activetrace)=markers
		DWS_FixAxesInGraph()
		formatgraph(1)
	endif
	if (NumberByKey("ErrorBars", ListOfGraphFormating,"=",";")==1)
		DWS_AttachErrorBars()
	endif
end

function formatgraph(addlabels)
	variable addlabels
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	If (!exists(ListOfGraphFormating)==0)
		DWS_GeneralPlotTool_Initialize()
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
	SVAR xname=root:Packages:GeneralplottingTool:GraphXAxisName
	SVAR yname=root:Packages:GeneralplottingTool:GraphyAxisName
	If(addlabels)	
		Label bottom xname
		Label left yname
	endif
		

	DWS_AttachLegend()//NumberByKey("Legend",ListOfGraphFormating,"="))
	//DWS_AttachErrorBars()
	//DWS_FixAxesInGraph()
	variable mode=0
	if (markers)
		mode=3*markers+lines
	endif
	if ((markers!=0)||(lines!=0))
		ChangetoLineandPoints(mode,colors)
	endif

	
end

function DWS_AttachErrorBars()
	string tracelist,activetrace,folderpath,ewave
	tracelist=TraceNameList("",";",1)
	variable i=0,total=ItemsInList(tracelist)
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	
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
						ErrorBars $activetrace Y,wave=(M_DSM_Error,M_DSM_Error);DelayUpdate
					endif
				elseif (Stringmatch (activetrace,"*DSM_int*"))
					if (waveexists(DSM_Error))
						ErrorBars $activetrace Y,wave=(DSM_Error,DSM_Error);DelayUpdate
					endif
				elseif (Stringmatch (activetrace,"R*"))
					ewave="s"+activetrace[1,32]
					if (waveexists($ewave))
						ErrorBars $activetrace Y,wave=($ewave,$ewave);DelayUpdate
					endif
				endif
			endif
			i+=1
		while (i<total)
end



function DWS_AttachLegend()
	variable type;string size
	
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
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



Function DWS_FixAxesInGraph()//keep

	NVAR GraphLeftAxisAuto=root:Packages:GeneralplottingTool:GraphLeftAxisAuto
	NVAR GraphLeftAxisMin=root:Packages:GeneralplottingTool:GraphLeftAxisMin
	NVAR GraphLeftAxisMax=root:Packages:GeneralplottingTool:GraphLeftAxisMax
	NVAR GraphBottomAxisAuto=root:Packages:GeneralplottingTool:GraphBottomAxisAuto
	NVAR GraphBottomAxisMin=root:Packages:GeneralplottingTool:GraphBottomAxisMin
	NVAR GraphBottomAxisMax=root:Packages:GeneralplottingTool:GraphBottomAxisMax
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
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


Function DWS_CreateItem(TheSwitch,NewName)
	string TheSwitch, NewName
//this function creates strings or variables with the name passed
	if (cmpstr(TheSwitch,"string")==0)
		SVAR/Z test=$NewName
		if (!SVAR_Exists(test))
			string/g $NewName
		endif
	endif
	if (cmpstr(TheSwitch,"variable")==0)
		NVAR/Z testNum=$NewName
		if (!NVAR_Exists(testNum))
			variable/g $NewName
		endif
	endif
end

function ChangetoLineandPoints(modetype,qcolors)//keep
	variable qcolors,modetype
	Prompt modetype, "Type of display", popup,"Lines;Sticks;Dots;Markers;Lines &Markers"
	Prompt qcolors,"Mixed Colors?",popup,"Colors;Grays;No"
	
	Silent 1;pauseupdate
	string markertypes="19;17;16;23;18;8;5;6;22;7;0;1;2;25;26;28;29;15;14;4;3;17;16;23;18;8;5;6;22;7;0;1;2;25;26;28;29;15;14;4;3"
	string rcolortypes="65535;0;0;65535;52428;0;39321;52428;1;26214;65535;0;0;65535;52428;0;39321;52428;1;26214"
	string gcolortypes="0;0;65535;43690;1;0;13101;52425;24548;26214;65535;0;0;65535;52428;0;39321;52428;1;26214"
	string bcolortypes="0;65535;0;0;41942;0;1;1;52428;26214;65535;0;0;65535;52428;0;39321;52428;1;26214"
	string ListofWaves=TraceNameList("",";",1),wavename
	variable position1=strsearch(ListofWaves,";",0),position2=position1
	variable markpos1=strsearch(markertypes,";",0), markpos2=markpos1
	wavename=ListofWaves[0,(position1-1)]
	variable marktp=str2num(markertypes[0,(markpos1-1)])
	variable red=FindString2num(0,rcolortypes,";")
	variable green=FindString2num(0,gcolortypes,";")
	variable blue=FindString2num(0,bcolortypes,";")
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
			red=FindString2num(counter,rcolortypes,";")
			green=FindString2num(counter,gcolortypes,";")
			blue=FindString2num(counter,bcolortypes,";")
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


Function/S DWS_FindFolderWithWaveTypes(startDF, levels, WaveTypes, LongShortType)
         String startDF, WaveTypes                  // startDF requires trailing colon.
        Variable levels, LongShortType		//set 1 for long type and 0 for short type return
        			//returns the list of folders with specCommand with "uascan" in it - may not work yet for sbuascan 
        String dfSave
        String list = "", templist
        
        dfSave = GetDataFolder(1)
  	
  	if (!DataFolderExists(startDF))
  		return ""
  	endif
  	
        SetDataFolder startDF
        
        templist = DataFolderDir(0)

    	 if (Stringmatch(WaveList("*",";",""),WaveTypes))
		if (LongShortType)
	            		list += startDF + ";"
	      	else
     		      		list += GetDataFolder(0) + ";"
      		endif
        endif
        
        levels -= 1
        if (levels <= 0)
                return list
        endif
        
        String subDF
        Variable index = 0
        do
                String temp
                temp = PossiblyQuoteName(GetIndexedObjName(startDF, 4, index))     	// Name of next data folder.
                if (strlen(temp) == 0)
                        break                                                                           			// No more data folders.
                endif
     	              subDF = startDF + temp + ":"
            		 list +=DWS_FindFolderWithWaveTypes(subDF, levels, "*"+WaveTypes, LongShortType)       	// Recurse.
                index += 1
        while(1)        
        SetDataFolder(dfSave)
        return list
End





Macro StdGraph(width,maxY,minY,BW,ylabel,xlabel,modetype,aspect,linewidth,markersize)
	variable/g root:P:gmaxy, root:P:gminY,root:P:gwidth, root:P:gBW,root:P:modetype,root:P:aspect,root:P:glinewidth,root:P:gmarkersize
	variable maxy=root:P:gmaxy,minY=root:P:gminY,width=root:P:gwidth,BW=root:P:gBW,modetype=root:P:modetype,aspect=root:P:aspect
	variable linewidth=root:P:glinewidth,markersize=root:P:gmarkersize
	string/g root:P:gylabel, root:P:gxlabel
	string ylabel=root:P:gylabel,xlabel=root:P:gxlabel
	prompt BW, "Graph Color",popup, "Color;Black & White;No Change"
	prompt maxy,"Enter max Y"
	prompt minY, "Enter min Y"
	prompt width, "Enter width in inches"
	Prompt aspect, "Enter aspect ratio (1.4)"
	Prompt modetype, "Type of display", popup,"Lines;Sticks;Dots;Markers;Lines &Markers;No change"
	Prompt ylabel,"Y axis Label", popup, "No Change;\f01\Z1610\S6\M\Z16 x SLD (�\S-2\M\Z16);\F'Helvetica'\Z16\f01Intensity (cm\S-1\M\Z16);\F'Helvetica'\Z16\f01Intensity;\F'Helvetica'\Z16\f01Reflectivity;\F'Helvetica'\Z12\f01Relative Intensity;"
	Prompt xlabel,"X axis Label", popup, "No Change;\Z16Distance from Si (�);\F'Helvetica'\Z16\f01q (�\S-1\M\Z16);\F'Helvetica'\Z16\f01q(�m\S-1\M\Z16);\F'Helvetica'\Z16\f01Diameter (�m);\F'Helvetica'\Z12\f01q (�\S-1\M\Z12)"
	prompt linewidth, "Line width"
	prompt markersize, "Marker size"
	silent 1
	root:P:gylabel=ylabel
	root:P:gxlabel=xlabel
	root:P:gmaxy=maxy;root:P:gminY=minY;Root:P:modetype=modetype
	root:P:gwidth=width;root:P:aspect=aspect
	root:P:gBW=BW;root:P:glinewidth=linewidth;root:P:gmarkersize=markersize
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
		ChangetoLineandPoints((modetype),1)
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


function logspacing(qwave)
	wave qwave
	duplicate/o qwave, tempqwave
	variable pts=numpnts(tempqwave)
	variable logqmax=log(tempqwave(pts-1))
	if (tempqwave[0]==0)
		tempqwave[0]=tempqwave[1]
	endif
	variable logqmin=log(tempqwave[0])
	tempqwave=logqmin+((logqmax-logqmin)/(pts-1))*p
	tempqwave=10^tempqwave	
	qwave=tempqwave
	killwaves/z tempqwave
end

Function FindString2num(index,strings,separator)
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