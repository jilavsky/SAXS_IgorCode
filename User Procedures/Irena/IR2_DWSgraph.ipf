#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.00

constant IR1D_DWSversionNumber = 1.00			//Data plotting II version 

//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.00 modified to have ponel scaling

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

///////		***************        Plotting tool II    ******************

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2D_DWSPlotToolMain()
	IN2G_CheckScreenSize("height",670)
	IR2D_DWSPlotToolInit()	
	IR2D_DWSPlotTool()
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("IR2D_DWSGraphPanel", IR1D_DWSversionNumber,1)
	
end


Function IR2D_DWSMainCheckVersion()	
	DoWindow IR2D_DWSGraphPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR2D_DWSGraphPanel", IR1D_DWSversionNumber))
			DoAlert /T="The Plotting tool II panel was created by old version of Irena " 1, "Plotting tool II may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				Execute/P("IR2D_DWSPlotToolMain()")
			else		//at least reinitialize the variables so we avoid major crashes...
				IR2D_DWSPlotToolInit()
			endif
		endif
	endif
end




Function IR2D_DWSPlotTool()
	KillWIndow/Z IR2D_DWSGraphPanel
	NewPanel /K=1/N=IR2D_DWSGraphPanel /W=(50,43.25,430.75,570) as "General Plotting tool"
	TitleBox MainTitle title="\Zr200Plotting tool input panel",pos={10,0},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={340,24},anchor=MC,fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={300,3},pos={16,199},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox FakeLine2 title=" ",fixedSize=1,size={300,3},pos={16,280},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox FakeLine3 title=" ",fixedSize=1,size={300,3},pos={16,330},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox FakeLine4 title=" ",fixedSize=1,size={300,3},pos={16,380},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox FakeLine5 title=" ",fixedSize=1,size={300,3},pos={16,430},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info1 title="\Zr150Data input",pos={5,25},frame=0,fstyle=1,anchor=LC, fixedSize=1,size={120,20}
	TitleBox Info2 title="\Zr150Legends",pos={5,285},frame=0,fstyle=1,anchor=LC, fixedSize=1,size={80,20}
	
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("Irena:DWSplottingTool","IR2D_DWSGraphPanel","M_DSM_Int;DSM_Int;M_SMR_Int;SMR_Int","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,0)

	//need to add controls below for aniso and  irina to work.  Also remove abov e 5 lines.
	Button newgraph,pos={5,165},size={80,20}, proc=IR2D_DWSInputPanelButtonProc,title="New Graph"
	Button AddDataToGraph,pos={90,165},size={80,20}, proc=IR2D_DWSInputPanelButtonProc,title="Add data"
	Button SaveGraph,pos={265,165},size={80,20}, proc=IR2D_DWSInputPanelButtonProc,title="Save Graph"
	Button Standard,pos={175,165},size={85,20}, proc=IR2D_DWSInputPanelButtonProc,title="Standard"
	
//graph controls
	CheckBox GraphLogX pos={60,210},title="Log X axis?", variable=root:Packages:Irena:DWSplottingTool:GraphLogX
	CheckBox GraphLogX proc=IR2D_DWSGenPlotCheckBox
	CheckBox GraphLogY pos={140,210},title="Log Y axis?", variable=root:Packages:Irena:DWSplottingTool:GraphLogY
	CheckBox GraphLogY proc=IR2D_DWSGenPlotCheckBox
	CheckBox GraphErrors pos={240,210},title="Error bars?", variable=root:Packages:Irena:DWSplottingTool:GraphErrors
	CheckBox GraphErrors proc=IR2D_DWSGenPlotCheckBox

	SetVariable GraphXAxisName pos={60,235},size={300,20},proc=IR2D_DWSSetVarProc,title="X axis title"
	SetVariable GraphXAxisName value= root:Packages:Irena:DWSplottingTool:GraphXAxisName, help={"Input horizontal axis title. Use Igor formating characters for special symbols."}	
	SetVariable GraphYAxisName pos={60,255},size={300,20},proc=IR2D_DWSSetVarProc,title="Y axis title"
	SetVariable GraphYAxisName value= root:Packages:Irena:DWSplottingTool:GraphYAxisName, help={"Input vertical axis title. Use Igor formating characters for special symbols."}		

//legends
	NVAR GraphLegendSize=root:Packages:Irena:DWSplottingTool:GraphlegendSize
	CheckBox GraphLegendUseFolderNms pos={80,285},title="Folder Names", variable=root:Packages:Irena:DWSplottingTool:GraphLegendUseFolderNms
	CheckBox GraphLegendUseFolderNms proc=IR2D_DWSGenPlotCheckBox, help={"Use folder names in Legend?"}	
	CheckBox GraphLegendUseWaveNote pos={180,285},title="Wave Names", variable=root:Packages:Irena:DWSplottingTool:GraphLegendUseWaveNote
	CheckBox GraphLegendUseWaveNote proc=IR2D_DWSGenPlotCheckBox, help={"Wave Names"}	
	PopupMenu GraphLegendSize,pos={15,305},size={180,20},proc=IR2D_DWSPanelPopupControl,title="Legend font size", help={"Select font size for legend to be used."}
	PopupMenu GraphLegendSize,mode=1,value= "06;08;10;12;14;16;18;20;22;24;", popvalue=num2str(GraphLegendSize)//"10"
//	Button Legends,pos={230,305},size={120,20}, proc=IR2D_DWSInputPanelButtonProc,title="Add/modify Legend"
//	Button KillLegends,pos={140,305},size={70,20}, proc=IR2D_DWSInputPanelButtonProc,title="Kill Legend"

	
	
	
	//Graph Line & symbols
	CheckBox GraphUseSymbols pos={60,340},title="Use symbols?", variable=root:Packages:Irena:DWSplottingTool:GraphUseSymbols
	CheckBox GraphUseSymbols proc=IR2D_DWSGenPlotCheckBox, help={"Use symbols and vary them for the data?"}
	CheckBox GraphUseLines pos={60,360},title="Use lines?", variable=root:Packages:Irena:DWSplottingTool:GraphUseLines
	CheckBox GraphUseLines proc=IR2D_DWSGenPlotCheckBox, help={"Use lines them for the data?"}
	SetVariable GraphSymbolSize pos={150,340},size={90,20},proc=IR2D_DWSSetVarProc,title="Symbol size", limits={1,20,1}
	SetVariable GraphSymbolSize value= root:Packages:Irena:DWSplottingTool:GraphSymbolSize, help={"Symbol size same for all."}		
	SetVariable GraphLineWidth pos={150,360},size={90,20},proc=IR2D_DWSSetVarProc,title="Line width  ", limits={1,4,1}
	SetVariable GraphLineWidth value= root:Packages:Irena:DWSplottingTool:GraphLineWidth, help={"Line width, same for all."}		
	CheckBox GraphUseColors pos={270,340},title="Black&White", variable=root:Packages:Irena:DWSplottingTool:GraphUseColors
	CheckBox GraphUseColors proc=IR2D_DWSGenPlotCheckBox, help={"colors"}	
//	Button Format,pos={270,355},size={70,20}, proc=IR2D_DWSInputPanelButtonProc,title="Change Mode"
	
	//Bottom Axis format
	CheckBox GraphXMajorGrid pos={60,390},title="X Major Grid", variable=root:Packages:Irena:DWSplottingTool:GraphXMajorGrid
	CheckBox GraphXMajorGrid proc=IR2D_DWSGenPlotCheckBox, value=1,help={"Check to add major grid lines to horizontal axis"}
	CheckBox GraphXMinorGrid pos={160,390},title="X Minor Grid?", variable=root:Packages:Irena:DWSplottingTool:GraphXMinorGrid
	CheckBox GraphXMinorGrid proc=IR2D_DWSGenPlotCheckBox, help={"Check to add minor grid lines to horizontal axis. May not display if graph would be too crowded."}

	//left axis format	
	CheckBox GraphYMajorGrid pos={60,410},title="Y Major Grid", variable=root:Packages:Irena:DWSplottingTool:GraphYMajorGrid
	CheckBox GraphYMajorGrid proc=IR2D_DWSGenPlotCheckBox,value=1, help={"Check to add major grid lines to vertical axis"}
	CheckBox GraphYMinorGrid pos={160,410},title="Y Minor Grid", variable=root:Packages:Irena:DWSplottingTool:GraphYMinorGrid
	CheckBox GraphYMinorGrid proc=IR2D_DWSGenPlotCheckBox, help={"Check to add minor grid lines to vertical axis. May not display if graph would be too crowded."}

	SetVariable GraphAxisWidth pos={260,390},size={90,20},proc=IR2D_DWSSetVarProc,title="Axis width:", limits={1,5,1}
	SetVariable GraphAxisWidth value= root:Packages:Irena:DWSplottingTool:GraphAxisWidth
	
	SetVariable TicRotation pos={250,410},size={100,20},proc=IR2D_DWSSetVarProc,title="Tic Rotation:", limits={0,90,90}
	SetVariable TicRotation, value= root:Packages:Irena:DWSplottingTool:TicRotation
	
	
	//Axis ranges	
	CheckBox GraphLeftAxisAuto pos={80,435},title="Y axis autoscale?", variable=root:Packages:Irena:DWSplottingTool:GraphLeftAxisAuto
	CheckBox GraphLeftAxisAuto proc=IR2D_DWSGenPlotCheckBox, help={"Autoscale Y (left) axis using data range?"}	
	CheckBox GraphBottomAxisAuto pos={250,435},title="X axis autoscale?", variable=root:Packages:Irena:DWSplottingTool:GraphBottomAxisAuto
	CheckBox GraphBottomAxisAuto proc=IR2D_DWSGenPlotCheckBox, help={"Autoscale X (bottom) axis using data range?"}	
	
	NVAR LeftAxisMin=root:Packages:Irena:DWSplottingTool:GraphLeftAxisMin
	NVAR LeftAxisMax=root:Packages:Irena:DWSplottingTool:GraphLeftAxisMax
	NVAR BottomAxisMin=root:Packages:Irena:DWSplottingTool:GraphBottomAxisMin
	NVAR BottomAxisMax=root:Packages:Irena:DWSplottingTool:GraphBottomAxisMax
	
	
	SetVariable GraphLeftAxisMin pos={80,455},size={140,20},proc=IR2D_DWSSetVarProc,title="Min: ", limits={0,inf,1e-6+LeftAxisMin}
	SetVariable GraphLeftAxisMin value= root:Packages:Irena:DWSplottingTool:GraphLeftAxisMin, format="%4.4e",help={"Minimum on Y (left) axis"}		
	SetVariable GraphLeftAxisMax pos={80,475},size={140,20},proc=IR2D_DWSSetVarProc,title="Max:", limits={0,inf,1e-6+LeftAxisMax}
	SetVariable GraphLeftAxisMax value= root:Packages:Irena:DWSplottingTool:GraphLeftAxisMax, format="%4.4e", help={"Maximum on Y (left) axis"}		

	
	SetVariable GraphBottomAxisMin pos={230,455},size={140,20},proc=IR2D_DWSSetVarProc,title="Min: ", limits={0,inf,1e-6+BottomAxisMin}
	SetVariable GraphBottomAxisMin value= root:Packages:Irena:DWSplottingTool:GraphBottomAxisMin, format="%4.4e", help={"Minimum on X (bottom) axis"}			
	SetVariable GraphBottomAxisMax pos={230,475},size={140,20},proc=IR2D_DWSSetVarProc,title="Max:", limits={0,inf,1e-6+BottomAxisMax}
	SetVariable GraphBottomAxisMax value= root:Packages:Irena:DWSplottingTool:GraphBottomAxisMax, format="%4.4e", help={"Maximum on X (bottom) axis"}		
	
	Button Capture,pos={10,450},size={60,20}, proc=IR2D_DWSInputPanelButtonProc,title="Capture"
	Button ChangeAx,pos={10,475},size={60,20}, proc=IR2D_DWSInputPanelButtonProc,title="Change"
//	NVAR anisocheck =root:packages:Irena:DWSplottingTool:UseAniso
//	IF(anisocheck==1)
//		Button Hermans,win =IR2D_DWSGraphPanel, disable=0  ,pos={220,495},size={100,20}
//		Button Hermans  proc=IR2D_DWSInputPanelButtonProc,title="Hermans"
//	endif
	
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************************

Function IR2D_DWSPlotToolInit()
	IR2D_InitializeDWSGraph()
	SetDataFolder root:Packages:Irena:DWSplottingTool
	string ListOfVariables="UseAniso;TicRotation;iwavesonly;"
	variable i=0
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor	
	SVAR 	ListOfGraphFormating=root:packages:Irena:DWSPlottingTool:ListOfGraphFormating
	NVAR errors=root:packages:Irena:DWSPlottingTool:GraphErrors
	NVAR axwidth = root:packages:Irena:DWSPlottingTool:GraphAxisWidth
	NVAR TicRotation=root:packages:Irena:DWSPlottingTool:TicRotation
	NVAR foldernames=root:packages:Irena:DWSPlottingTool:GraphLegendUseFolderNms
	SVAR xname=root:packages:Irena:DWSPlottingTool:GraphXAxisName
	SVAR yname=root:packages:Irena:DWSPlottingTool:GraphyAxisName
	SVAR DataFolderName=root:packages:Irena:DWSPlottingTool:DataFolderName
	foldernames=1;errors=0;	TicRotation = 0;axwidth= 2
	
	xname="\F'Helvetica'\f01\Z14q (\S-1\M\Z14)";yname="\F'Helvetica'\f01\Z14Intensity (cm\S-1\M\Z14)"
	ListOfGraphFormating=ReplaceStringByKey("Label left",ListOfGraphFormating,yname,"=")
	ListOfGraphFormating=ReplaceStringByKey("Label bottom",ListOfGraphFormating, xname,"=")
	ListOfGraphFormating=ReplaceStringByKey("ErrorBars",ListOfGraphFormating, "0","=")
	ListOfGraphFormating=ReplaceStringByKey("Graph use Symbols",ListOfGraphFormating, "0","=")
	
	DataFolderName="root:"
end


//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************************
//		Initialize procedure, as usually
//**************************************************************************************************

Function IR2D_InitializeDWSGraph()			//initialize general plotting tool.

	string oldDf=GetDataFolder(1)
	string ListOfVariables
	string ListOfStrings
	variable i
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:Irena
	NewDataFolder/O root:Packages:Irena:DWSplottingTool
	NewDataFolder/O root:Packages:Irena:DWSPFolder

	SetDataFolder root:Packages:Irena:DWSplottingTool					//go into the folder

//	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="ListOfDataFolderNames;ListOfDataWaveNames;ListOfGraphFormating;ListOfDataOrgWvNames;ListOfDataFormating;SelectedDataToModify;"
	ListOfStrings+="GraphXAxisName;GraphYAxisName;SelectedDataToRemove;GraphLegendPosition;ModifyIntName;ModifyQname;ModifyErrName;"
	ListOfStrings+="ListOfRemovedPoints;FittingSelectedFitFunction;FittingFunctionDescription;"
	ListOfStrings+="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"

	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;DisplayTimeAndDate;"
	ListOfVariables+="GraphLogX;GraphLogY;GraphErrors;GraphXMajorGrid;GraphXMinorGrid;GraphYMajorGrid;GraphYMinorGrid;"
	ListOfVariables+="GraphLegend;GraphUseColors;GraphUseSymbols;GraphXMirrorAxis;GraphYMirrorAxis;GraphLineWidth;"
	ListOfVariables+="GraphUseSymbolSet1;GraphUseSymbolSet2;GraphLegendUseWaveNote;"
	ListOfVariables+="GraphLegendUseFolderNms;GraphLegendShortNms;GraphLeftAxisAuto;GraphLeftAxisMin;GraphLeftAxisMax;"
	ListOfVariables+="GraphBottomAxisAuto;GraphBottomAxisMin;GraphBottomAxisMax;GraphAxisStandoff;"
	ListOfVariables+="GraphUseLines;GraphSymbolSize;GraphVarySymbols;GraphVaryLines;GraphAxisWidth;"
	ListOfVariables+="GraphWindowWidth;GraphWindowHeight;GraphTicksIn;GraphLegendSize;GraphLegendFrame;"
	ListOfVariables+="ModifyDataBackground;ModifyDataMultiplier;ModifyDataQshift;ModifyDataErrorMult;"
	ListOfVariables+="TrimPointLargeQ;TrimPointSmallQ;FittingParam1;FittingParam2;FittingParam3;FittingParam4;FittingParam5;"
	ListOfVariables+="FitUseErrors;Xoffset;Yoffset;"
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR testS=$(StringFromList(i,ListOfStrings))
		testS=""
	endfor	
	SVAR ListOfGraphFormating
	SVAR FittingSelectedFitFunction
	FittingSelectedFitFunction = "---"
	
	ListOfVariables="GraphErrors;GraphXMajorGrid;GraphXMinorGrid;GraphYMajorGrid;GraphYMinorGrid;"
	ListOfVariables+="GraphLegend;GraphUseColors;GraphUseSymbols;GraphXMirrorAxis;GraphYMirrorAxis;GraphLineWidth;"
	ListOfVariables+="GraphLegendUseFolderNms;GraphAxisStandoff;GraphLegendShortNms;"
	ListOfVariables+= "ModifyDataBackground;ModifyDataQshift;"
	ListOfVariables+="GraphUseSymbolSet2;"
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR testV=$(StringFromList(i,ListOfVariables))
		testV=0
	endfor		
	ListOfVariables="GraphLogX;GraphLogY;GraphUseLines;GraphSymbolSize;DisplayTimeAndDate;"
	ListOfVariables+="GraphLeftAxisAuto;GraphLeftAxisMin;GraphLeftAxisMax;"
	ListOfVariables+="GraphBottomAxisAuto;GraphBottomAxisMin;GraphBottomAxisMax;GraphAxisWidth;"
	ListOfVariables+="ModifyDataMultiplier;ModifyDataErrorMult;"
	ListOfVariables+="FitUseErrors;"
	ListOfVariables+="GraphUseSymbolSet1;"
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR testV=$(StringFromList(i,ListOfVariables))
		testV=1
	endfor
	NVAR GraphWindowWidth
	NVAR GraphLegendSize
	NVAR GraphWindowHeight		
	if(GraphWindowWidth==0)
		string ScreenWidthStr=stringFromList(3,  StringByKey("SCREEN1", IgorInfo(0)),",")
		string ScreenHeightStr=stringFromList(4,  StringByKey("SCREEN1", IgorInfo(0)),",")
		//variable ScreenSizeV= IgorInfo(0)
		GraphWindowWidth=(str2num(ScreenWidthStr))/2
		GraphWindowHeight=(str2num(ScreenHeightStr))/2
		GraphLegendSize=10
	endif
	SVAR GraphLegendPosition
	NVAR GraphLegendFrame
	if (strlen(GraphLegendPosition)<2)
		GraphLegendPosition="MC"
		GraphLegendFrame=1
	endif	
	NVAR GraphLineWidth
	GraphLineWidth=1
	
	if (!DataFolderExists("root:Packages:plottingToolsStyles"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:plottingToolsStyles
	endif
	SetDataFolder root:Packages:plottingToolsStyles					//go into the folder

	String/g LogLog
	SVAR LogLog
	LogLog="log(bottom)=1;log(left)=1;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q [A\S-1\M];Label left=Intensity [cm\S-1\M];"
	LogLog+="DataY=Y;DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;Axis left min=0;Axis left max=0;Axis bottom min=0;Axis bottom max=0;"
	LogLog+="standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width=450;Graph Window Height=400;"
	LogLog+="mode[0]=4;mode[1]=4;mode[2]=4;mode[3]=4;mode[4]=4;Graph use Colors=1;mode[5]=4;mode[6]=4;mode[7]=4;mode[8]=4;mode[9]=4;Graph vary Lines=1;"
	LogLog+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
	LogLog+="marker[0]=19;marker[1]=16;marker[2]=17;marker[3]=23;marker[4]=26;marker[5]=29;marker[6]=18;marker[7]=15;marker[8]=14;"
	LogLog+="rgb[0]=(65280,0,0);rgb[1]=(0,0,65280);rgb[2]=(0,65280,0);rgb[3]=(32680,32680,0);rgb[4]=(0,32680,32680);rgb[5]=(32680,0,32680);"
	LogLog+="rgb[6]=(32680,32680,32680);rgb[7]=(65280,32680,32680);rgb[8]=(32680,32680,65280);rgb[9]=(65280,0,0);rgb[10]=(0,0,65280);"
	LogLog+="rgb[11]=(32680,32680,65280);rgb[12]=(0,65280,0);rgb[13]=(32680,32680,0);rgb[14]=(0,32680,32680);rgb[15]=(32680,0,32680);"
	LogLog+="rgb[16]=(32680,32680,32680);rgb[17]=(65280,32680,32680);rgb[18]=(32680,32680,65280);"
	LogLog+="lStyle[0]=0;lStyle[1]=1;lStyle[2]=2;lStyle[3]=3;lStyle[4]=4;lStyle[5]=5;lStyle[6]=6;lStyle[7]=7;lStyle[8]=8;"
	LogLog+="Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	
	string/g VolumeDistribution
	SVAR VolumeDistribution
	VolumeDistribution="log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=Diameter [A];Label left=Volume distribution (f(D));DataY=Y;"
	VolumeDistribution+="DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;Axis left min=1.37359350144832e-06;Axis left max=0.0110271775364775;Axis bottom min=10;"
	VolumeDistribution+="Axis bottom max=5000;standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width=450;Graph Window Height=400;"
	VolumeDistribution+="mode[0]=4;mode[1]=4;mode[2]=4;mode[3]=4;mode[4]=4;Graph use Colors=1;mode[5]=4;mode[6]=4;mode[7]=4;mode[8]=4;mode[9]=4;Graph vary Lines=1;"
	VolumeDistribution+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;marker[0]=8;marker[1]=17;marker[2]=5;marker[3]=12;marker[4]=16;"
	VolumeDistribution+="marker[5]=29;marker[6]=18;marker[7]=15;marker[8]=14;rgb[0]=(65280,0,0);rgb[1]=(0,0,65280);rgb[2]=(0,65280,0);rgb[3]=(32680,32680,0);rgb[4]=(0,32680,32680);"
	VolumeDistribution+="rgb[5]=(32680,0,32680);rgb[6]=(32680,32680,32680);rgb[7]=(65280,32680,32680);rgb[8]=(32680,32680,65280);rgb[9]=(65280,0,0);rgb[10]=(0,0,65280);"
	VolumeDistribution+="rgb[11]=(32680,32680,65280);rgb[12]=(0,65280,0);rgb[13]=(32680,32680,0);rgb[14]=(0,32680,32680);rgb[15]=(32680,0,32680);"
	VolumeDistribution+="rgb[16]=(32680,32680,32680);rgb[17]=(65280,32680,32680);rgb[18]=(32680,32680,65280);lStyle[0]=0;lStyle[1]=1;lStyle[2]=2;lStyle[3]=3;lStyle[4]=4;lStyle[5]=5;lStyle[6]=6;lStyle[7]=7;lStyle[8]=8;"	
	VolumeDistribution+="Legend=2;GraphLegendShortNms=0;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	
	ListOfGraphFormating="log(bottom)=1;log(left)=1;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q [A\S-1\M];Label left=Intensity [cm\S-1\M];"
	ListOfGraphFormating+="DataY=Y;DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;Axis left min=0;Axis left max=0;Axis bottom min=0;Axis bottom max=0;"
	ListOfGraphFormating+="standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width=450;Graph Window Height=400;"
	ListOfGraphFormating+="mode[0]=4;mode[1]=4;mode[2]=4;mode[3]=4;mode[4]=4;Graph use Colors=1;mode[5]=4;mode[6]=4;mode[7]=4;mode[8]=4;mode[9]=4;Graph vary Lines=1;"
	ListOfGraphFormating+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
	ListOfGraphFormating+="marker[0]=19;marker[1]=16;marker[2]=17;marker[3]=23;marker[4]=26;marker[5]=29;marker[6]=18;marker[7]=15;marker[8]=14;"
	ListOfGraphFormating+="rgb[0]=(65280,0,0);rgb[1]=(0,0,65280);rgb[2]=(0,65280,0);rgb[3]=(32680,32680,0);rgb[4]=(0,32680,32680);rgb[5]=(32680,0,32680);"
	ListOfGraphFormating+="rgb[6]=(32680,32680,32680);rgb[7]=(65280,32680,32680);rgb[8]=(32680,32680,65280);rgb[9]=(65280,0,0);rgb[10]=(0,0,65280);"
	ListOfGraphFormating+="rgb[11]=(32680,32680,65280);rgb[12]=(0,65280,0);rgb[13]=(32680,32680,0);rgb[14]=(0,32680,32680);rgb[15]=(32680,0,32680);"
	ListOfGraphFormating+="rgb[16]=(32680,32680,32680);rgb[17]=(65280,32680,32680);rgb[18]=(32680,32680,65280);"
	ListOfGraphFormating+="lStyle[0]=0;lStyle[1]=1;lStyle[2]=2;lStyle[3]=3;lStyle[4]=4;lStyle[5]=5;lStyle[6]=6;lStyle[7]=7;lStyle[8]=8;"
	ListOfGraphFormating+="Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	 
	SetDataFolder OldDf 					//go into the folder

end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
function IR2D_DWSCreateGraph(new)
		variable new
		SVAR Dtf=root:Packages:Irena:DWSplottingTool:DataFolderName
		SVAR IntDf=root:Packages:Irena:DWSplottingTool:IntensityWaveName
		SVAR QDf=root:Packages:Irena:DWSplottingTool:QWaveName
		SVAR EDf=root:Packages:Irena:DWSplottingTool:ErrorWaveName
		SVAR ListOfGraphFormating=root:Packages:Irena:DWSplottingTool:ListOfGraphFormating
		variable lines, markers
		lines= NumberByKey("Graph use Lines", ListOfGraphFormating,"=",";")
		markers= NumberByKey("Graph use Symbols", ListOfGraphFormating,"=",";")
		if(!DataFolderExists(Dtf))
			abort
		endif
		setdatafolder Dtf
		IR2D_DWSStripQuoteFromQRSnames()
		
	if((new)||(cmpstr(WinList("*",";","WIN:1"), "" )==0))
		If(stringmatch (QDf,""))
			Display/N=GeneralGraph/K=1/W=(400,0,700,350 ) $IntDf as  "Plotting tool II Graph"
		Else
			Display/N=GeneralGraph/K=1/W=(400,0,700,350 ) $IntDf vs $QDf as  "Plotting tool II Graph"	
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
		IR2D_DWSFixAxesInGraph()
		IR2D_DWSFormatGraph(1)
	endif
	if (NumberByKey("ErrorBars", ListOfGraphFormating,"=",";")==1)
		IR2D_DWSAttachErrorBars()
	endif
end


