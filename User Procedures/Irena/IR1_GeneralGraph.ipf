#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.32
//#include  <TransformAxis1.2>
Constant IR1PversionNumber=2.32

//*************************************************************************\
//* Copyright (c) 2005 - 2018, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.32 modified IR1P_AttachLegend to limit max number of items in Legend
//2.31 modified graph size control to use IN2G_GetGraphWidthHeight and associated settings. Should work on various display sizes. 
//2.30 removed unused functions, rmeoved use of TransformAxis and replaced with Free axis and hokk function. Better. 
//2.29 added getHelp button calling to www manual
//2.28 fixed Gizmo for Igor 7, this should be improved later, but at this time this needs to work for both Igor 6 and 7
//2.27 added more styles and changed few defaults for them. 
//2.26 fixes for panel scaling
//2.25 fixed export option for graphics which changed in Igor 7
//2.24 fixed legend for VOlume fraction
//2.23 changed offset limits to enable negative offsets. Useful. 
//2.22 fixed Guinier style definition... Weird, cannot find bug but it was setting legend parameters to NaNs. Copied same stuff from other style and it works??? 
//2.21 chaged units for common system cm-1sr-1
//2.20 added Int*Q^3 as plotting option. 
//2.19 minor fix for Change Graph details panel visibility
//2.18 added infinite number of colors and symbols to Vary Colors/symbols. (repeating set of 10). Cleaned up old crud in code. removed KBColorizeTraces, not needed anymore. 
//2.17 added IR2S_SortListOfAvailableFldrs() to call to scripting tool
//2.16 fixed forgotten Style storing path, which was still saving styles to ProgramFiles area. Permissions problem on some systems. Fixed and moving file to new location.
//        fixed Scripting tool problem when the controsl could get stale between thw Plotting tool and scripting tool panels.  
//2.15 added contour plot and basic controls. 
//2.14 Modified to handle different units for Intensity calibration. Addec control in Change Graph details panel. 
//2.13 Added vertical scrolling
//2.12 fix in Scripting tool call which caused problems when starting with no data type chosen. Defaults properly to qrs now. 
//2.11 Updated way the Gizmo procedures are handled, will load only when Gizmo panel is opened. 
//2.10 changed default size of graph from 450x400 to 50% x 50% of Screen1 size
//2.09 major improvements in Gizmo 3D plotting, not finished yet, but likely useable. 
//2.08 Loaded KBColorizeTraces as default and removed IR1_PlotStyleMngr.ipf.
//2.07 added GIZMO capabilities and some GUI fixes.
//2.06 Graph3D modifications and fixes. 
//2.05 modified coloring scheme and added rainbow and BW options
//2.04 added scripting tool capabilities, added version check and forced restart when needed. 
//2.03 changed to use optimized IR2P_ListOfWavesOfType function
//2.02 added license for ANL

//2.01 fixed bugs when screens were coming up behind the main panel. 

//This is General graphing procedure. I'll try to make useful tool for graphing any data in SAS.
//This is difficult problem, since the variability of the problem is enormous. So there will be limits,
//but I want to make it so the user does not have to know much of Igor to create useful plots and at 
//the same time I want to make sure user can use recreation macros. Therefore we cannot copy, move
//or modify data, we have to use the data as they are in the users folders...

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//this does all....
Function IR1P_GeneralPlotTool()

	IN2G_CheckScreenSize("height",670)

	String ListOfWindowsToClose="GizmoControlPanel;Irena_Gizmo;GeneralGraph;PlotingToolWaterfallGrph;IR1P_ControlPanel;IR1P_RemoveDataPanel;"
	ListOfWindowsToClose+="PlotingToolWaterfallGrph;IR1P_ModifyDataPanel;IR1P_FittingDataPanel;IR1P_ChangeGraphDetailsPanel;PlotingToolContourGrph;"
	
	variable i
	For(i=0;i<ItemsInList(ListOfWindowsToClose);i+=1)
		KillWIndow/Z $(StringFromList(i,ListOfWindowsToClose,";"))
	endfor
	IR1P_InitializeGenGraph()
	IR1P_ControlPanelFunc()
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("IR1P_ControlPanel", IR1PversionNumber,1)

end

//**************************************************************************************************
//		Create control panel as necessary for general plot tool
//**************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR1P_MainCheckVersion()	
	DoWindow IR1P_ControlPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR1P_ControlPanel", IR1PversionNumber))
			DoAlert /T="The Ploting tool I panel was created by old version of Irena " 1, "Ploting tool may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				//Execute/P("IR1P_GeneralPlotTool()")
				IR1P_GeneralPlotTool()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR1P_InitializeGenGraph()
			endif
		endif
	endif
end


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************


Function IR1P_ControlPanelFunc() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,402,690)/N=IR1P_ControlPanel as "General Plotting tool"
	TitleBox MainTitle title="\Zr200Plotting tool input panel",pos={20,0},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={350,24},anchor=MC,fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,200},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info1 title="\Zr140Data input",pos={10,30},frame=0,fstyle=1, fixedSize=1,size={80,20},fColor=(0,0,52224)
	string UserDataTypes="Isas;"
	string UserNameString="CanSAS"
	string XUserLookup="Isas:Qsas;"
	string EUserLookup="Isas:Idev;"

	IR2C_AddDataControls("GeneralplottingTool","IR1P_ControlPanel","M_DSM_Int;DSM_Int;M_SMR_Int;SMR_Int","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,0)
	Button ScriptingTool,pos={302,138},size={95,20}, proc=IR1P_InputPanelButtonProc,title="Scripting tool", help={"Start scripting tool to add multiple data at once"}
	Button AddDataToGraph,pos={2,158},size={95,20}, proc=IR1P_InputPanelButtonProc,title="Add data", help={"Click to add data into the list of data to be displayed in the graph"}
	Button RemoveData,pos={102,158},size={95,20}, proc=IR1P_InputPanelButtonProc,title="Remove data", help={"Click to remove data  from the list of data to be displayed in the graph"}
	Button CreateGraph,pos={202,158},size={95,20}, proc=IR1P_InputPanelButtonProc,title="(Re)Graph (2D)", help={"Click to create graph or regraph with newly added data"}
	Button ResetAll,pos={302,158},size={95,20}, proc=IR1P_InputPanelButtonProc,title="Kill Graph, Reset", help={"Click here to kill graph and reset this tool (remove all data sets from graph)"}
	Button Create3DGraph,pos={202,178},size={95,20}, proc=IR1P_InputPanelButtonProc,title="(Re)Graph (3D,Wf)", help={"Click to create 3D graph or regraph with newly added data"}
	Button CreateMovie,pos={2,178},size={95,20}, proc=IR1P_InputPanelButtonProc,title="Create Movie", help={"Click to create movie from 2D or 3D graph"}
	Button CreateGizmoGraph,pos={102,178},size={95,20}, proc=IR1P_InputPanelButtonProc,title="Gizmo (3D)", help={"Click to create 3D graph using Gizmo"}
	Button CreateContourPlot,pos={302,178},size={95,20}, proc=IR1P_InputPanelButtonProc,title="Contour plot", help={"Create contour plot"}
	Button GetHelp,pos={305,105},size={80,15},fColor=(65535,32768,32768), proc=IR1P_InputPanelButtonProc,title="Get Help", help={"Open www manual page for this tool"}

//graph controls
	PopupMenu GraphType,pos={1,210},size={178,21},proc=IR1P_PanelPopupControl,title="Graph style", help={"Select graph type to create, needed data types will be created if necessary"}
	PopupMenu GraphType,mode=1,value= #"\"NewUserStyle;\"+IN2G_CreateListOfItemsInFolder(\"root:Packages:plottingToolsStyles\",8)"
	Button CreateNewStyle,pos={30,240},size={150,17}, proc=IR1P_InputPanelButtonProc,title="Save new graph style", help={"Click to add new graph style into the list of available graphs"}
	Button ManageStyles,pos={30,265},size={150,17}, proc=IR1P_InputPanelButtonProc,title="Manage Graph styles", help={"Manage graph styles (styles)."}

	Button ModifyData,pos={210,205},size={150,17}, proc=IR1P_InputPanelButtonProc,title="Modify data", help={"Click to open dialog to modify the data. USE CAUTION - THIS CAN HAVE BAD SIDE EFFECTS for your data!!!!"}
	Button SetGraphDetails,pos={210,223},size={150,17}, proc=IR1P_InputPanelButtonProc,title="Change graph details", help={"Click to open dialog to modify graph minor details."}
	Button GraphFitting,pos={210,241},size={150,17}, proc=IR1P_InputPanelButtonProc,title="Fitting", help={"Click to pull out panel with fitting tools."}
	Button StoreGraphs,pos={210,258},size={150,17}, proc=IR1P_InputPanelButtonProc,title="Store and recall graphs", help={"Store and restore graphs for future use."}
	Button MoreTools,pos={210,276},size={150,17}, proc=IR1P_InputPanelButtonProc,title="More ...", help={"More handy tools."}

	PopupMenu XAxisDataType,pos={10,300},size={178,21},proc=IR1P_PanelPopupControl,title="X axis data", help={"Select data to be displayed on X axis, needed data types will be created if necessary"}
	PopupMenu XAxisDataType,mode=1,popvalue="X",value= "X;X^2;X^3;X^4;"
	PopupMenu YAxisDataType,pos={220,300},size={178,21},proc=IR1P_PanelPopupControl,title="Y axis data", help={"Select data to be displayed on Y axis, needed data types will be created if necessary"}
	PopupMenu YAxisDataType,mode=1,popvalue="I",value= "Y;Y^2;Y^3;Y^4;Y*X^4;Y*X^3;Y*X^2;1/Y;sqrt(1/Y);ln(Y);ln(Y*X);ln(Y*X^2);"

	CheckBox GraphLogX pos={12,330},title="Log X axis?", variable=root:Packages:GeneralplottingTool:GraphLogX
	CheckBox GraphLogX proc=IR1P_GenPlotCheckBox, help={"Select to modify horizontal axis to log scale, uncheck for linear scale"}
	CheckBox GraphXMajorGrid pos={12,350},title="Major Grid X axis?", variable=root:Packages:GeneralplottingTool:GraphXMajorGrid
	CheckBox GraphXMajorGrid proc=IR1P_GenPlotCheckBox, help={"Check to add major grid lines to horizontal axis"}
	CheckBox GraphXMinorGrid pos={12,370},title="Minor Grid X axis?", variable=root:Packages:GeneralplottingTool:GraphXMinorGrid
	CheckBox GraphXMinorGrid proc=IR1P_GenPlotCheckBox, help={"Check to add minor grid lines to horizontal axis. May not display if graph would be too crowded."}
	CheckBox GraphXMirrorAxis pos={12,390},title="Mirror X axis?", variable=root:Packages:GeneralplottingTool:GraphXMirrorAxis
	CheckBox GraphXMirrorAxis proc=IR1P_GenPlotCheckBox, help={"Check to add mirror axis to horizontal axis"}


	CheckBox GraphLogY pos={220,330},title="Log Y axis?", variable=root:Packages:GeneralplottingTool:GraphLogY
	CheckBox GraphLogY proc=IR1P_GenPlotCheckBox, help={"Select to modify vertical axis to log scale, uncheck for linear scale"}
	CheckBox GraphYMajorGrid pos={220,350},title="Major Grid Y axis?", variable=root:Packages:GeneralplottingTool:GraphYMajorGrid
	CheckBox GraphYMajorGrid proc=IR1P_GenPlotCheckBox, help={"Check to add major grid lines to vertical axis"}
	CheckBox GraphYMinorGrid pos={220,370},title="Minor Grid Y axis?", variable=root:Packages:GeneralplottingTool:GraphYMinorGrid
	CheckBox GraphYMinorGrid proc=IR1P_GenPlotCheckBox, help={"Check to add minor grid lines to vertical axis. May not display if graph would be too crowded."}
	CheckBox GraphYMirrorAxis pos={220,390},title="Mirror Y axis?", variable=root:Packages:GeneralplottingTool:GraphYMirrorAxis
	CheckBox GraphYMirrorAxis proc=IR1P_GenPlotCheckBox, help={"Check to add mirror  axis to vertical axis."}

	SetVariable GraphXAxisName pos={20,415},size={340,20},proc=IR1P_SetVarProc,title="X axis title"
	SetVariable GraphXAxisName variable= root:Packages:GeneralplottingTool:GraphXAxisName, help={"Input horizontal axis title. Use Igor formating characters for special symbols."}	
	SetVariable GraphYAxisName pos={20,435},size={340,20},proc=IR1P_SetVarProc,title="Y axis title"
	SetVariable GraphYAxisName variable= root:Packages:GeneralplottingTool:GraphYAxisName, help={"Input vertical axis title. Use Igor formating characters for special symbols."}		

	SetVariable Xoffset pos={20,460},size={100,20},limits={-inf,inf,1},proc=IR1P_SetVarProc,title="X offset"
	SetVariable Xoffset variable= root:Packages:GeneralplottingTool:Xoffset, help={"Offset data in graph? For log axis multiplier, for lin axis addition"}	
	SetVariable Yoffset pos={220,460},size={100,20},limits={-inf,inf,1},proc=IR1P_SetVarProc,title="Y offset"
	SetVariable Yoffset variable= root:Packages:GeneralplottingTool:Yoffset, help={"Offset data in graph? For log axis multiplier, for lin axis addition"}	

	CheckBox GraphLegend pos={20,485},title="Append Legend?", variable=root:Packages:GeneralplottingTool:GraphLegend
	CheckBox GraphLegend proc=IR1P_GenPlotCheckBox, help={"Append legend to the graph?"}	
	CheckBox GraphErrors pos={230,485},title="Errors bars?", variable=root:Packages:GeneralplottingTool, help={"Display Errors?"}
	CheckBox GraphErrors proc=IR1P_GenPlotCheckBox

	//Graph Line & symbols
	CheckBox GraphUseSymbols pos={20,505},title="Use symbols?", variable=root:Packages:GeneralplottingTool:GraphUseSymbols
	CheckBox GraphUseSymbols proc=IR1P_GenPlotCheckBox, help={"Use symbols and vary them for the data?"}
	CheckBox GraphUseLines pos={20,525},title="Use lines?", variable=root:Packages:GeneralplottingTool:GraphUseLines
	CheckBox GraphUseLines proc=IR1P_GenPlotCheckBox, help={"Use lines them for the data?"}
	SetVariable GraphLineWidth pos={180,525},size={100,20},proc=IR1P_SetVarProc,title="Line width", limits={1,20,1}
	SetVariable GraphLineWidth value= root:Packages:GeneralplottingTool:GraphLineWidth, help={"Line width, same for all."}		
	SetVariable GraphSymbolSize pos={180,505},size={100,20},proc=IR1P_SetVarProc,title="Symbol size", limits={1,20,1}
	SetVariable GraphSymbolSize value= root:Packages:GeneralplottingTool:GraphSymbolSize, help={"Symbol size same for all."}		

	CheckBox GraphUseColors pos={20,545},title="Vary clrs?", variable=root:Packages:GeneralplottingTool:GraphUseColors
	CheckBox GraphUseColors proc=IR1P_GenPlotCheckBox, help={"Vary colors for the data?"}	
	CheckBox GraphUseRainbow pos={95,545},title="Rainbow?", variable=root:Packages:GeneralplottingTool:GraphUseRainbow
	CheckBox GraphUseRainbow proc=IR1P_GenPlotCheckBox, help={"Vary colors for the data as rainbow?"}	
	CheckBox GraphUseBW pos={160,545},title="BW?", variable=root:Packages:GeneralplottingTool:GraphUseBW
	CheckBox GraphUseBW proc=IR1P_GenPlotCheckBox, help={"Black and white instead of red?"}	
	CheckBox GraphVarySymbols pos={220,545},title="Vary Symbols?", variable=root:Packages:GeneralplottingTool:GraphVarySymbols
	CheckBox GraphVarySymbols proc=IR1P_GenPlotCheckBox, help={"Vary symbols for the data?"}	
	CheckBox GraphVaryLines pos={310,545},title="Vary lines?", variable=root:Packages:GeneralplottingTool:GraphVaryLines
	CheckBox GraphVaryLines proc=IR1P_GenPlotCheckBox, help={"Vary Lines for the data?"}	


	//Axis ranges
	NVAR GraphLeftAxisMin = root:Packages:GeneralplottingTool:GraphLeftAxisMin
	NVAR GraphLeftAxisMax = root:Packages:GeneralplottingTool:GraphLeftAxisMax
	NVAR GraphBottomAxisMin = root:Packages:GeneralplottingTool:GraphBottomAxisMin
	NVAR GraphBottomAxisMax = root:Packages:GeneralplottingTool:GraphBottomAxisMax
	CheckBox GraphLeftAxisAuto pos={180,565},title="Y axis autoscale?", variable=root:Packages:GeneralplottingTool:GraphLeftAxisAuto
	CheckBox GraphLeftAxisAuto proc=IR1P_GenPlotCheckBox, help={"Autoscale Y (left) axis using data range?"}	
	SetVariable GraphLeftAxisMin pos={180,585},size={140,20},proc=IR1P_SetVarProc,title="Min: ", limits={0,inf,1e-6+GraphLeftAxisMin}
	SetVariable GraphLeftAxisMin value= root:Packages:GeneralplottingTool:GraphLeftAxisMin, format="%4.4e",help={"Minimum on Y (left) axis"}		
	SetVariable GraphLeftAxisMax pos={180,605},size={140,20},proc=IR1P_SetVarProc,title="Max:", limits={0,inf,1e-6+GraphLeftAxisMax}
	SetVariable GraphLeftAxisMax value= root:Packages:GeneralplottingTool:GraphLeftAxisMax, format="%4.4e", help={"Maximum on Y (left) axis"}		

	CheckBox GraphBottomAxisAuto pos={20,565},title="X axis autoscale?", variable=root:Packages:GeneralplottingTool:GraphBottomAxisAuto
	CheckBox GraphBottomAxisAuto proc=IR1P_GenPlotCheckBox, help={"Autoscale X (bottom) axis using data range?"}	
	SetVariable GraphBottomAxisMin pos={20,585},size={140,20},proc=IR1P_SetVarProc,title="Min: ", limits={0,inf,1e-6+GraphBottomAxisMin}
	SetVariable GraphBottomAxisMin value= root:Packages:GeneralplottingTool:GraphBottomAxisMin, format="%4.4e", help={"Minimum on X (bottom) axis"}		
	SetVariable GraphBottomAxisMax pos={20,605},size={140,20},proc=IR1P_SetVarProc,title="Max:", limits={0,inf,1e-6+GraphBottomAxisMax}
	SetVariable GraphBottomAxisMax value= root:Packages:GeneralplottingTool:GraphBottomAxisMax, format="%4.4e", help={"Maximum on X (bottom) axis"}		
	
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************************
//		Control procedures for the General plotting tool 
//**************************************************************************************************

Function/T IR1P_ListOfWaves(DataType)
	string DataType			//data type   : Xaxis, Yaxis, Error
	
	NVAR UseIndra2Data=root:packages:GeneralplottingTool:UseIndra2Data
	NVAR UseQRSData=root:packages:GeneralplottingTool:UseQRSData
	NVAR UseResults=root:packages:GeneralplottingTool:UseResults

	string result="", tempresult="", tempStringQ="", tempStringR="", tempStringS=""
	SVAR FldrNm=$("root:Packages:GeneralplottingTool:DataFolderName")
	variable i,j
		
	if (UseIndra2Data)
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
		tempresult=""
		if(cmpstr(DataType,"Xaxis")==0)
		//	if(stringMatch(result,"*DSM_Qvec*"))
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
				For (j=0;j<ItemsInList(result);j+=1)
					if (stringMatch(StringFromList(j,result),"*SMR_Qvec*"))
						tempresult+=StringFromList(j,result)+";"
					endif
				endfor
		//	endif
		elseif (cmpstr(DataType,"Yaxis")==0)
		//	if(stringMatch(result,"*DSM_Int*"))
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
				For (j=0;j<ItemsInList(result);j+=1)
					if (stringMatch(StringFromList(j,result),"*SMR_Int*"))
						tempresult+=StringFromList(j,result)+";"
					endif
				endfor
		//	endif
		else // (cmpstr(DataType,"Error")==0)
			//if(stringMatch(result,"*DSM_Error*"))
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
				For (j=0;j<ItemsInList(result);j+=1)
					if (stringMatch(StringFromList(j,result),"*SMR_Error*"))
						tempresult+=StringFromList(j,result)+";"
					endif
				endfor
			//endif
		endif
		result=tempresult
	elseif(UseQRSData) 
		result=""			//IN2G_CreateListOfItemsInFolder(FldrNm,2)
		tempStringQ=IR2P_ListOfWavesOfType("q",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		tempStringR=IR2P_ListOfWavesOfType("r",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		tempStringS=IR2P_ListOfWavesOfType("s",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		
		if (cmpstr(DataType,"Yaxis")==0)
			For (j=0;j<ItemsInList(tempStringR);j+=1)
				if (stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringR)[1,inf]+";*"))// && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringR)[1,inf]+";*"))
					result+=StringFromList(j,tempStringR)+";"
				endif
			endfor
		elseif(cmpstr(DataType,"Xaxis")==0)
			For (j=0;j<ItemsInList(tempStringQ);j+=1)
				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*"))// && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringQ)[1,inf]+";*"))
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
	else
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
	endif
	
	return result
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function/T ReturnListResultsFolders(ListOfQFolders)
	string ListOfQFolders
	
	string result=""
	variable i
	For(i=0;i<ItemsInList(ListOfQFolders);i+=1)
		if(!stringmatch(result, "*"+stringFromList(i,ListOfQFolders)+"*"))
			result+=stringFromList(i,ListOfQFolders)+";"
		endif
	
	endfor
	
	return result

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function IR1P_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool
	
	variable IsAllAllRight
	if(cmpstr(ctrlName,"GetHelp")==0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Irena/Plotting.html")
	endif

	if (cmpstr(ctrlName,"AddDataToGraph")==0)
		//here goes what is done, when user pushes Graph button
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
		if (cmpstr(DFQ,"---")==0 || strlen(DFQ)<=0)
			IsAllAllRight=0
		endif
//		if (cmpstr(DFE,"---")==0) //commented out, so data without error bars can be displayed
//			IsAllAllRight=0
//		endif
		
		if (IsAllAllRight)
			IR1P_RecordDataForGraph()
			//print "Added "+DFloc+" to Ploting tool"
		else
			Abort "Data not selected properly"
		endif
		//print GetRTStackInfo(2)
		if(!stringmatch(GetRTStackInfo(2),"IR2S_CallWithPlottingToolII"))	//calling from Scripting tool...
			IR1P_CreateGraph()					//create or update the graph
			DoWIndow/F IR1P_ControlPanel
		endif
	endif
	if (cmpstr(ctrlName,"CreateGraph")==0)
		//here goes what is done, when user pushes Graph button
		IsAllAllRight=1

		if (IsAllAllRight)
			IR1P_CreateGraph()
		else
			Abort "Data not selected properly"
		endif
		DoWIndow/F IR1P_ControlPanel
	endif
	if (cmpstr(ctrlName,"Create3DGraph")==0)
		//here goes what is done, when user pushes Graph button
		IsAllAllRight=1

		if (IsAllAllRight)
			IR1P_Create3DGraph()
		else
			Abort "Data not selected properly"
		endif
		DoWIndow/F IR1P_ControlPanel
	endif
	if (cmpstr(ctrlName,"CreateContourPlot")==0)
		//here goes what is done, when user pushes Graph button
		IsAllAllRight=1
		if (IsAllAllRight)
			IR1P_CreateCountourGraph()
		else
			Abort "Data not selected properly"
		endif
		DoWIndow/F IR1P_ControlPanel
	endif


	if (cmpstr(ctrlName,"CreateGizmoGraph")==0)
		//here goes what is done, when user pushes Graph button
		IsAllAllRight=1

		if (IsAllAllRight)
			IR1P_GizmoCreate3DGizmoGraph()
		else
			Abort "Data not selected properly"
		endif
		DoWIndow/F IR1P_ControlPanel
	endif

	if (cmpstr(ctrlName,"GizmoGenerateDataAndGraph")==0)
		//here goes what is done, when user pushes Graph button
		IR1P_GizmoCreateDataAndGraph(1)
	endif
	if (cmpstr(ctrlName,"GizmoReGraph")==0)
		//here goes what is done, when user pushes Graph button
		IR1P_GizmoCreateDataAndGraph(0)
	endif
	
	
	if (cmpstr(ctrlName,"UpdateGizmo")==0)
		//here goes what is done, when user pushes Graph button
		IR1P_GizmoFormatGraph()
	endif


	if (cmpstr(ctrlName,"RemoveData")==0)
		//here goes what is done, when user pushes Graph button
		IR1P_RemoveDataFn()
	endif
	if (cmpstr(ctrlName,"CreateMovie")==0)
		//here goes what is done, when user pushes Graph button
		IR1P_MovieSetup()
	endif	
	if (cmpstr(ctrlName,"CreateNewStyle")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_CreateNewUserStyle()
		DoWIndow/F IR1P_ControlPanel
	endif
	if (cmpstr(ctrlName,"ResetAll")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_ResetTool()
		DoWIndow/F IR1P_ControlPanel
	endif
	if (cmpstr(ctrlName,"SetGraphDetails")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_ChangeGraphDetailsFn()
	endif
	if (cmpstr(ctrlName,"MoreTools")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_MoreToolsFn()
	endif


	if (cmpstr(ctrlName,"ScriptingTool")==0)
			IR2S_ScriptingTool()
			AutopositionWindow /M=1/R=IR1P_ControlPanel IR2S_ScriptingToolPnl
			NVAR GUseIndra2data=root:Packages:GeneralplottingTool:UseIndra2Data
			NVAR GUseQRSdata=root:Packages:GeneralplottingTool:UseQRSdata
			NVAR GUseResults=root:Packages:GeneralplottingTool:UseResults
			NVAR STUseIndra2Data=root:Packages:Irena:ScriptingTool:UseIndra2Data
			NVAR STUseQRSData = root:Packages:Irena:ScriptingTool:UseQRSdata
			NVAR STUseResults = root:Packages:Irena:ScriptingTool:UseResults
			STUseIndra2Data = GUseIndra2data
			STUseQRSData = GUseQRSdata
			STUseResults = GUseResults
			if(STUseIndra2Data+STUseQRSData+STUseResults!=1)
				//DoAlert 0, "At this time this scripting can be used ONLY for QRS, Irena results and Indra2 data. Defaulting to QRS."
				STUseQRSData=1
				GUseQRSdata=1
				STRUCT WMCheckboxAction CB_Struct
				CB_Struct.eventcode = 2
				CB_Struct.ctrlName = "UseQRSdata"
				CB_Struct.checked = 1
				CB_Struct.win = "IR1P_ControlPanel"
				STUseIndra2Data = 0
				GUseIndra2data = 0
				STUseResults = 0
				GUseResults = 0
				IR2C_InputPanelCheckboxProc(CB_Struct)		
			endif
			IR2S_UpdateListOfAvailFiles()
			IR2S_SortListOfAvailableFldrs()
			IR2S_CheckProc("Something",0)
	endif

	if (cmpstr(ctrlName,"ModifyData")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_ModifyDataFn()
	endif
	if (cmpstr(ctrlName,"GraphFitting")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_FittingDataFn()
	endif
	if (cmpstr(ctrlName,"ManageStyles")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_ManageStyles()
	endif
	if (cmpstr(ctrlName,"StoreGraphs")==0)
		//here goes what is done, when user pushes Graph button
			IR1P_StoreGraphs()
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_RemoveDataFn()
	//here we create new panel with some more controls...
	
	KillWIndow/Z IR1P_RemoveDataPanel
	Execute ("IR1P_RemoveDataPanel()")

end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//creates modify data panel. For now empty
Function IR1P_ModifyDataFn()
	//here we create new panel with some more controls...
	
	NVAR ModifyDataBackground=root:Packages:GeneralplottingTool:ModifyDataBackground
	NVAR ModifyDataMultiplier=root:Packages:GeneralplottingTool:ModifyDataMultiplier
	NVAR ModifyDataQshift=root:Packages:GeneralplottingTool:ModifyDataQshift
	NVAR ModifyDataErrorMult=root:Packages:GeneralplottingTool:ModifyDataErrorMult
	NVAR TrimPointSmallQ=root:Packages:GeneralplottingTool:TrimPointSmallQ
	NVAR TrimPointLargeQ=root:Packages:GeneralplottingTool:TrimPointLargeQ
	SVAR ListOfRemovedPoints=root:Packages:GeneralplottingTool:ListOfRemovedPoints
	
	TrimPointSmallQ=0
	TrimPointLargeQ=inf
	ModifyDataBackground=0
	ModifyDataMultiplier=1
	ModifyDataQshift=0
	ModifyDataErrorMult=1
	ListOfRemovedPoints=""
	
	KillWIndow/Z IR1P_ModifyDataPanel
	Execute ("IR1P_ModifyDataPanel()")
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_FittingDataFn()
	//here we create new panel with some more controls...
	
	KillWIndow/Z IR1P_FittingDataPanel

	Execute ("IR1P_FittingDataPanel()")
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//another of modify data panel macros
Window IR1P_FittingDataPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(63,128.75,375,425.75) as "IR1P_FittingDataPanel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 5,23,"Standard fitts to the data in the graph"
	SetDrawEnv textrgb= (65280,0,0)
	DrawText 16,42,"Set cursors to a data set to range of data"
	SetDrawEnv textrgb= (65280,0,0)
	DrawText 16,58,"Select function etc."
	SetDrawEnv fsize= 12,fstyle= 1,textrgb= (0,0,65280)
	DrawText 16,135,"Input starting guesses for parameters"
	
	PopupMenu SelectFitFunction,pos={10,66},size={178,20},proc=IR1P_PanelPopupControlFitting,title="Function", help={"Select fitting function to use to fit on the data"}
	PopupMenu SelectFitFunction,mode=1,value= "---;Line;Porod in loglog;Guinier in loglog;Area under curve;", popvalue = root:Packages:GeneralplottingTool:FittingSelectedFitFunction

	SetVariable FittingFunctionDescription pos={3,96},size={310,20},title="Fitted formula", limits={-inf,inf,0},noedit=1, frame=0 //,proc=IR1P_SetVarProc
	SetVariable FittingFunctionDescription value= root:Packages:GeneralplottingTool:FittingFunctionDescription, help={"Fitted formula spelled out"}		
	CheckBox FitUseErrors pos={220,66},title="Use errors?", variable=root:Packages:GeneralplottingTool:FitUseErrors
	CheckBox FitUseErrors noproc, help={"Use error for fitting?"}	
	
	Button GuessFitParam pos={10,230}, size={120,20},  proc=IRP_ButtonProc3,title="Guess fit param", help={"Will guess starting parameters for fitting."}
	Button DoFitting pos={10,260}, size={120,20},  proc=IRP_ButtonProc3,title="Fit", help={"Do the fitting on data between cursors. Will generate error if cursors are not on the same wave."}
	Button RemoveTagsAndFits pos={150,260}, size={120,20},  proc=IRP_ButtonProc3,title="Remove Tags and Fits", help={"Remove the fit curves and tag from previous fits"}

	IR1P_ModifyFittingPanel(root:Packages:GeneralplottingTool:FittingSelectedFitFunction)
EndMacro


//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_PanelPopupControlFitting(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool

	if (cmpstr(ctrlName,"SelectFitFunction")==0)		
		IR1P_ModifyFittingPanel(popStr)
	endif
	
	setDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_ModifyFittingPanel(popStr)
	string popStr
	//here we need to modify fitting panel for the appropriate fitting function as well as save the fitting function in string
	
	SVAR FittingSelectedFitFunction = root:Packages:GeneralplottingTool:FittingSelectedFitFunction 
	FittingSelectedFitFunction  = popStr

	SVAR FittingFunctionDescription = root:Packages:GeneralplottingTool:FittingFunctionDescription 
	NVAR FittingParam1 = root:Packages:GeneralplottingTool:FittingParam1 	//background
	NVAR FittingParam2 = root:Packages:GeneralplottingTool:FittingParam2 	//first fitting param.
	// Porod constant, 
	NVAR FittingParam3 = root:Packages:GeneralplottingTool:FittingParam3 
	NVAR FittingParam4 = root:Packages:GeneralplottingTool:FittingParam4 
	NVAR FittingParam5 = root:Packages:GeneralplottingTool:FittingParam5 
	
	SetVariable FittingParam1, disable = 1, win=IR1P_FittingDataPanel
	SetVariable FittingParam2, disable = 1, win=IR1P_FittingDataPanel
	SetVariable FittingParam3, disable = 1, win=IR1P_FittingDataPanel
	SetVariable FittingParam4, disable = 1, win=IR1P_FittingDataPanel
	SetVariable FittingParam5, disable = 1, win=IR1P_FittingDataPanel
	
	if(cmpstr(popStr,"Line")==0)
		//here goes modifications for line
		FittingFunctionDescription = "Int = a * Q + background"
	endif
	if(cmpstr(popStr,"Porod in loglog")==0)
		//here goes modifications for line
		FittingFunctionDescription = "Int = PC * Q^(-4) + background"
		SetVariable FittingParam1 pos={10,140},size={210,20},title="Background      ", limits={-inf,inf,1}, disable=0, win=IR1P_FittingDataPanel
		SetVariable FittingParam1 value= root:Packages:GeneralplottingTool:FittingParam1, format="%4.4e", help={"Fitted formula spelled out"}		
		SetVariable FittingParam2 pos={10,160},size={210,20},title="Porod const.     ", limits={-inf,inf,1}, disable=0, win=IR1P_FittingDataPanel
		SetVariable FittingParam2 value= root:Packages:GeneralplottingTool:FittingParam2, format="%4.4e", help={"Fitted formula spelled out"}		
		if (FittingParam2==0)
			FittingParam2=1
		endif
	endif
	if(cmpstr(popStr,"Guinier in loglog")==0)
		//here goes modifications for line
		FittingFunctionDescription = "Int = G*exp(-q^2*Rg^2/3))"
		SetVariable FittingParam1 pos={10,140},size={210,20},title="G      ", limits={0,inf,1}, disable=0, win=IR1P_FittingDataPanel
		SetVariable FittingParam1 value= root:Packages:GeneralplottingTool:FittingParam1, format="%4.4e", help={"Guinier fit prefactor (G)"}		
		SetVariable FittingParam2 pos={10,160},size={210,20},title="Rg        ", limits={0,inf,1}, disable=0, win=IR1P_FittingDataPanel
		SetVariable FittingParam2 value= root:Packages:GeneralplottingTool:FittingParam2, format="%4.4e", help={"Guinier fit Rg"}		
		if (FittingParam2==0)
			FittingParam2=100
		endif
		if (FittingParam1==0)
			FittingParam1=10
		endif
	endif

	if(cmpstr(popStr,"Area under curve")==0)
		//here goes modifications for line
		FittingFunctionDescription = "For size distributions, Vol/Num of scatterers"
	endif

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_GuessFitParam()

	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool:
	SVAR FittingSelectedFitFunction = root:Packages:GeneralplottingTool:FittingSelectedFitFunction 
	SVAR FittingFunctionDescription = root:Packages:GeneralplottingTool:FittingFunctionDescription 
	NVAR FittingParam1 = root:Packages:GeneralplottingTool:FittingParam1 	//background, G in guinier
	NVAR FittingParam2 = root:Packages:GeneralplottingTool:FittingParam2 	//first fitting param.
	// Porod constant, Rg in Guinier
	NVAR FittingParam3 = root:Packages:GeneralplottingTool:FittingParam3 
	NVAR FittingParam4 = root:Packages:GeneralplottingTool:FittingParam4 
	NVAR FittingParam5 = root:Packages:GeneralplottingTool:FittingParam5 
	
	NVAR FitUseErrors=root:Packages:GeneralplottingTool:FitUseErrors
	//this contains the fitting function

	//now lets make checkbox for 
	Wave/Z ErrorWave=$(IR1P_FindErrorWaveForCursor())
	if(WaveExists(ErrorWave))
		CheckBox FitUseErrors disable=0, win=IR1P_FittingDataPanel
		FitUseErrors=1
	else
		CheckBox FitUseErrors disable=1, win=IR1P_FittingDataPanel
		FitUseErrors=0
	endif	
	//check that cursors are set and set on the same wave or give error
	
	Wave/Z CursorAWave = CsrWaveRef(A, "GeneralGraph")
	Wave/Z CursorBWave = CsrWaveRef(B, "GeneralGraph")
	if(!WaveExists(CursorAWave) || !WaveExists(CursorBWave) || cmpstr(NameOfWave(CursorAWave),NameOfWave(CursorBWave))!=0)
		Abort "The cursors are not set properly - they are not in the graph or not on the same wave"
	endif
	Wave CursorAXWave= CsrXWaveRef(A, "GeneralGraph")

	if(cmpstr(FittingSelectedFitFunction,"Porod in loglog")==0)
		if (pcsr(B)>pcsr(A))
			FittingParam2=CursorAWave[pcsr(A)]/(CursorAXWave[pcsr(A)]^(-4))
			FittingParam1=CursorAwave[pcsr(B)]
		else
			FittingParam2=CursorAWave[pcsr(B)]/(CursorAXWave[pcsr(B)]^(-4))
			FittingParam1=CursorAwave[pcsr(A)]		
		endif
	endif

	if(cmpstr(FittingSelectedFitFunction,"Guinier in loglog")==0)
		if (pcsr(B)>pcsr(A))
			FittingParam1=CursorAWave[pcsr(A)]
			FittingParam2=1/((CursorAXwave[pcsr(B)] + 7*CursorAXwave[pcsr(A)])/8)	
		else
			FittingParam1=CursorAWave[pcsr(B)]
			FittingParam2=1/((CursorAXwave[pcsr(A)] + 7*CursorAXwave[pcsr(B)])/8)	
		endif
	endif	

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_DoFitting()

	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool:
	SVAR FittingSelectedFitFunction = root:Packages:GeneralplottingTool:FittingSelectedFitFunction 
	SVAR FittingFunctionDescription = root:Packages:GeneralplottingTool:FittingFunctionDescription 
	NVAR FittingParam1 = root:Packages:GeneralplottingTool:FittingParam1 	//background, G in Guinier,
	NVAR FittingParam2 = root:Packages:GeneralplottingTool:FittingParam2 	//first fitting param.
	// Porod constant, Rg in Guinier,
	NVAR FittingParam3 = root:Packages:GeneralplottingTool:FittingParam3 
	NVAR FittingParam4 = root:Packages:GeneralplottingTool:FittingParam4 
	NVAR FittingParam5 = root:Packages:GeneralplottingTool:FittingParam5 
	
	NVAR FitUseErrors=root:Packages:GeneralplottingTool:FitUseErrors
	//this contains the fitting function
	
	//check that cursors are set and set on the same wave or give error
	
	Wave/Z CursorAWave = CsrWaveRef(A, "GeneralGraph")
	Wave/Z CursorBWave = CsrWaveRef(B, "GeneralGraph")
	if(!WaveExists(CursorAWave) || !WaveExists(CursorBWave) || cmpstr(NameOfWave(CursorAWave),NameOfWave(CursorBWave))!=0)
		Abort "The cursors are not set properly - they are not in the graph or not on the same wave"
	endif
	Wave CursorAXWave= CsrXWaveRef(A, "GeneralGraph")
	string TagName= UniqueName("IR1P_TagName",14,0,"GeneralGraph")
	string TagText

	Wave/Z  FitWave= $("fit_"+NameOfWave(CursorAWave))
	KillWaves/Z FitWave
	string FitWaveName= UniqueName("IR1P_FitWave",1,0)
	Wave/Z  FitXWave= $("fitX_"+NameOfWave(CursorAWave))
	KillWaves/Z FitXWave
	string FitXWaveName= UniqueName("IR1P_FitWaveX",1,0)

	Make/D/N=0/O W_coef, LocalEwave
	Make/D/T/N=0/O T_Constraints
	Wave/Z W_sigma
	//find the error wave and make it available, if exists
	Wave/Z ErrorWave=$(IR1P_FindErrorWaveForCursor())
	Variable V_FitError=0			//This should prevent errors from being generated

	
	if(cmpstr(FittingSelectedFitFunction,"Line")==0)
		//do line fitting
		if (FitUseErrors && WaveExists(ErrorWave))
			CurveFit line CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /W=ErrorWave /I=1
		else
			CurveFit line CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D		
		endif
		TagText = "Fitted line y=a + bx.\r a = "+num2str(W_coef[0])+"\r b = "+num2str(W_coef[1])+"\r chi-square = "+num2str(V_chisq)
		Tag/C/W=GeneralGraph/N=$(TagName)/L=2 $NameOfWave(CursorAWave), ((pcsr(A) + pcsr(B))/2),TagText	
	endif
	if(cmpstr(FittingSelectedFitFunction,"Area under curve")==0)	
		if(!(strlen(CsrWave(A,"GeneralGraph"))>0) || !(strlen(CsrWave(B,"GeneralGraph"))>0) )
			abort "Cursors not set"
		endif		
		if(cmpstr(CsrWave(A,"GeneralGraph"),CsrWave(B,"GeneralGraph"))!=0) 
			abort "Cursors not set on the same waves"
		endif		
		//print CsrWaveRef(A,"GeneralGraph")
		wave MyXWave=CsrXWaveRef(A,"GeneralGraph")
	
		Wave MyYWave=CsrWaveRef(A,"GeneralGraph")
		variable volume
		volume = areaXY(MyXWave,MyYWave, MyXWave[pcsr(A)],MyXWave[pcsr(B)])
		Tag/C/W=GeneralGraph/N=$(TagName)/L=2 $NameOfWave(CursorAWave), ((pcsr(A) + pcsr(B))/2),"Volume/Number of scatterers = "+num2str(volume)
	endif
	if(cmpstr(FittingSelectedFitFunction,"Porod in loglog")==0)
		//do line fitting
		Redimension /N=2 W_coef
		Redimension/N=1 T_Constraints
		T_Constraints[0] = {"K1 > 0"}
		W_coef = {FittingParam2,FittingParam1}
		V_FitError=0			//This should prevent errors from being generated
		if (FitUseErrors && WaveExists(ErrorWave))
			FuncFit PorodInLogLog W_coef CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /C=T_Constraints /W=ErrorWave /I=1
		else
			FuncFit PorodInLogLog W_coef CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /C=T_Constraints			
		endif
		if (V_FitError!=0)	//there was error in fitting
			RemoveFromGraph $("fit_"+NameOfWave(CursorAWave))
			beep
			Abort "Fitting error, check starting parameters and fitting limits" 
		endif
		Wave W_sigma
		TagText = "Fitted Porod  "+FittingFunctionDescription+" \r PC = "+num2str(W_coef[0])+"\r Background = "+num2str(W_coef[1])
		if (FitUseErrors && WaveExists(ErrorWave))
			TagText+="\r chi-square = "+num2str(V_chisq)
		endif
		Tag/C/W=GeneralGraph/N=$(TagName)/L=2 $NameOfWave(CursorAWave), ((pcsr(A) + pcsr(B))/2),TagText	
		FittingParam2=W_coef[0]
		FittingParam1=W_coef[1]
	endif

	if(cmpstr(FittingSelectedFitFunction,"Guinier in loglog")==0)

		Redimension /N=2 W_coef, LocalEwave
		Redimension/N=2 T_Constraints
		T_Constraints[0] = {"K1 > 0"}
		T_Constraints[1] = {"K0 > 0"}

		W_coef[0]=FittingParam1 	//G
		W_coef[1]=FittingParam2	//Rg

		LocalEwave[0]=(FittingParam1/20)
		LocalEwave[1]=(FittingParam2/20)

		V_FitError=0			//This should prevent errors from being generated
		if (FitUseErrors && WaveExists(ErrorWave))
			FuncFit IR1_GuinierFit W_coef CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /C=T_Constraints /W=ErrorWave /I=1//E=LocalEwave 
		else
			FuncFit IR1_GuinierFit W_coef CursorAWave[pcsr(A),pcsr(B)] /X=CursorAXWave /D /C=T_Constraints //E=LocalEwave 
		endif
		if (V_FitError!=0)	//there was error in fitting
			RemoveFromGraph $("fit_"+NameOfWave(CursorAWave))
			beep
			Abort "Fitting error, check starting parameters and fitting limits" 
		endif
		Wave W_sigma
		TagText = "Fitted Guinier  "+FittingFunctionDescription+" \r G = "+num2str(W_coef[0])+"\r Rg = "+num2str(W_coef[1])
		if (FitUseErrors && WaveExists(ErrorWave))
			TagText+="\r chi-square = "+num2str(V_chisq)
		endif
		Tag/C/W=GeneralGraph/N=$(TagName)/L=2 $NameOfWave(CursorAWave), ((pcsr(A) + pcsr(B))/2),TagText	
		
		FittingParam1=W_coef[0] 	//G
		FittingParam2=W_coef[1]	//Rg

	endif	


	//rename fit wave and modify their appearance...
	Wave/Z  FitWave= $(("fit_"+NameOfWave(CursorAWave))[0,30])
	Wave/Z  FitXWave= $(("fitX_"+NameOfWave(CursorAWave))[0,30])
	
	if (WaveExists(FitWave))
		Rename FitWave, $(FitWaveName)	
	endif
	if (WaveExists(FitXWave))
		Rename FitXWave, $(FitXWaveName)	
	endif
	ModifyGraph/Z lstyle(IR1P_FitWave0)=5,rgb(IR1P_FitWave0)=(0,15872,65280), lsize(IR1P_FitWave0)=3
	ModifyGraph/Z lstyle(IR1P_FitWave1)=7,rgb(IR1P_FitWave1)=(0,65280,33024), lsize(IR1P_FitWave1)=3
	ModifyGraph/Z lstyle(IR1P_FitWave2)=9,rgb(IR1P_FitWave2)=(65280,0,52224), lsize(IR1P_FitWave2)=3
	ModifyGraph/Z lstyle(IR1P_FitWave3)=1,rgb(IR1P_FitWave3)=(65280,65280,0), lsize(IR1P_FitWave3)=3
	ModifyGraph/Z lstyle(IR1P_FitWave4)=14,rgb(IR1P_FitWave4)=(0,52224,0), lsize(IR1P_FitWave4)=3
	ModifyGraph/Z lstyle(IR1P_FitWave5)=12,rgb(IR1P_FitWave5)=(65280,0,0), lsize(IR1P_FitWave5)=3
	ModifyGraph/Z lstyle(IR1P_FitWave6)=2,rgb(IR1P_FitWave6)=(16384,28160,65280), lsize(IR1P_FitWave6)=3
	ModifyGraph/Z lstyle(IR1P_FitWave7)=11,rgb(IR1P_FitWave7)=(65280,0,52224), lsize(IR1P_FitWave7)=3	
	setDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function/T IR1P_FindErrorWaveForCursor()

	//find the error wave if exists
	SVAR ListOfDataWaveNames= root:Packages:GeneralplottingTool:ListOfDataWaveNames
	if (strlen(CsrWave(A))==0 && strlen(CsrWave(B))==0)
		return ""
	endif
	string PathToIntWave=GetWavesDataFolder(CsrWaveRef(A, "GeneralGraph"), 2 )	
	string PathToErrorWave
	variable ii, iimax
	iimax = ItemsInList(ListOfDataWaveNames , ";")/3
	For(ii=0;ii<iimax;ii+=1)
		if (cmpstr(StringByKey("IntWave"+num2str(ii), ListOfDataWaveNames , "=" ,";"),PathToIntWave)==0)
			PathToErrorWave = StringByKey("EWave"+num2str(ii), ListOfDataWaveNames , "=" ,";")
		endif
	endfor 
	return PathToErrorWave
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_RemoveTagsAndFits()


	string TagName= UniqueName("IR1P_TagName",14,0,"GeneralGraph")
	string FitWaveName= UniqueName("IR1P_FitWave",1,0)
	string tempTagname, tempFItWaveName, tempFItXWaveName
	variable lastTag, lastFitWv
	if (numtype(str2num(TagName[strlen(TagName)-3,inf]))==0)
		lastTag=str2num(TagName[strlen(TagName)-3,inf])
	elseif(numtype(str2num(TagName[strlen(TagName)-2,inf]))==0)
		lastTag=str2num(TagName[strlen(TagName)-2,inf])
	elseif(numtype(str2num(TagName[strlen(TagName)-1,inf]))==0)
		lastTag=str2num(TagName[strlen(TagName)-1,inf])
	endif
	lastTag = lastTag -1

	if (numtype(str2num(FitWaveName[strlen(FitWaveName)-3,inf]))==0)
		lastFitWv=str2num(FitWaveName[strlen(FitWaveName)-3,inf])
	elseif(numtype(str2num(FitWaveName[strlen(FitWaveName)-2,inf]))==0)
		lastFitWv=str2num(FitWaveName[strlen(FitWaveName)-2,inf])
	elseif(numtype(str2num(FitWaveName[strlen(FitWaveName)-1,inf]))==0)
		lastFitWv=str2num(FitWaveName[strlen(FitWaveName)-1,inf])
	endif
	lastFitWv = lastFitWv -1
	
	variable i
	For(i=0;i<=lastTag;i+=1)
		tempTagname = "IR1P_TagName" + num2str(i)
		Tag/W=GeneralGraph/N=$(tempTagname)	/K	
	endfor
	For(i=0;i<=lastFitWv;i+=1)
		tempFItWaveName = "IR1P_FitWave" + num2str(i)
		RemoveFromGraph /W=GeneralGraph /Z $tempFItWaveName
		Wave/Z KillMe=$tempFItWaveName
		KillWaves/Z KillMe
		tempFItXWaveName = "IR1P_FitWaveX" + num2str(i)
		Wave/Z KillMeX=$tempFItXWaveName
		KillWaves/Z KillMeX
	endfor
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//another of modify data panel macros
Window IR1P_ModifyDataPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(63,128.75,375,490) as "IR1P_ModifyDataPanel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 13,23,"Here you can modify the data in the graph"
	SetDrawEnv textrgb= (65280,0,0)
	DrawText 13,44,"This WILL CHANGE your data"
	SetDrawEnv textrgb= (65280,0,0)
	DrawText 13,101,"Make sure you understand possible sideffects"
	SetDrawEnv textrgb= (65280,0,0)
	DrawText 13,63,"Backup is saved with \"name\"+_bckup "
	SetDrawEnv textrgb= (65280,0,0)
	DrawText 13,82,"And if different, ploted data types are recreated "
	
	PopupMenu ModifyDataList,pos={10,110},size={178,20},proc=IR1P_PanelPopupControl,title="Data", help={"Select data to modify"}
	PopupMenu ModifyDataList,mode=1,value= IR1P_ListWavesInGraphListModify()

	SetVariable ModifyDataMultiplier pos={10,145},size={200,20},proc=IR1P_SetVarProc,title="Int Scaling factor", limits={1e-40,inf,0.1}
	SetVariable ModifyDataMultiplier value= root:Packages:GeneralplottingTool:ModifyDataMultiplier, format="%4.4e", help={"Scaling factor (multiplier) for Intensity"}		
	SetVariable ModifyDataBackground pos={10,170},size={200,20},proc=IR1P_SetVarProc,title="Int Subtract background", limits={-inf,inf,0.1}
	SetVariable ModifyDataBackground value= root:Packages:GeneralplottingTool:ModifyDataBackground, format="%4.4e", help={"Flat bacground to be subtracted from Intensity"}		
	SetVariable ModifyDataQshift pos={10,195},size={200,20},proc=IR1P_SetVarProc,title="Shift Q      ", limits={-inf,inf,0.1}
	SetVariable ModifyDataQshift value= root:Packages:GeneralplottingTool:ModifyDataQshift, format="%4.4e", help={"Shift (add to) Q "}		
	SetVariable ModifyDataErrorMult pos={10,220},size={200,20},proc=IR1P_SetVarProc,title="Multiply error bars by", limits={1e-40,inf,0.1}
	SetVariable ModifyDataErrorMult value= root:Packages:GeneralplottingTool:ModifyDataErrorMult, format="%4.4e", help={"Multiply errors by this number"}		

	Button RemoveSmallData pos={10,245}, size={120,20},  proc=IRP_ButtonProc3,title="Remove Q<Csr(A)", help={"Remove data with Q smaller than where cursor A (rounded) is"}
	Button RemoveLargeData pos={160,245}, size={120,20},  proc=IRP_ButtonProc3,title="Remove Q>Csr(B)", help={"Remove data with Q smaller than where cursor A (rounded) is"}
	Button RemoveOneDataPnt pos={80,270}, size={120,20},  proc=IRP_ButtonProc3,title="Remove point (Csr(A))", help={"Remove one data point using cursor A (rounded) is"}

	Button CancelModify pos={80,300}, size={100,20},  proc=IRP_ButtonProc3,title="Cancel", help={"Reset curent modifcation to the data to original"}
	Button RecoverBackup pos={80,330}, size={120,20},  proc=IRP_ButtonProc3,title="Recover backup", help={"Recover ORIGINAL data from backup"}
EndMacro
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Window IR1P_RemoveDataPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(63,128.75,375,425.75) as "IR1P_RemoveDataPanel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 5,23,"Remove the data from the graph"

	PopupMenu RemoveDataList,pos={10,40},size={178,20},proc=IR1P_PanelPopupControl,title="Data", help={"Select data to remove"}
	PopupMenu RemoveDataList,mode=1,value= IR1P_ListWavesInGraphList(), help={"Select data to remove from graph"}
	Button RemoveDataBtn,  size={100,20},pos={60,80}, proc=IR1P_InputPanelButtonProc1,title="Remove"
	Button RemoveDataBtn,  help={"Click here to remove the selected data set from the graph"}
EndMacro


 
Function IR1P_InputPanelButtonProc1(ctrlName) : ButtonControl
	String ctrlName

	if (cmpstr(ctrlName,"RemoveDataBtn")==0)
		//here we need to remove the data in the popup from lists...
		IR1P_RemoveDataFromList()
		IR1P_SynchronizeListAndVars()
		IR1P_UpdateGenGraph()
	endif

end

Function IR1P_RemoveDataFromList()

	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	SVAR ListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	SVAR SelectedDataToRemove=root:Packages:GeneralplottingTool:SelectedDataToRemove
	
	variable i, j, imax
	i = 0
	j = 0
	string NewListOfDataFolderNames=""
	string NewListOfDataWaveNames=""
	string NewListOfDataOrgWvnames=""
	imax=ItemsInList(ListOfDataWaveNames , ";")/3
	For(i=0;i<imax;i+=1)
		if(cmpstr(StringByKey("IntWave"+num2str(i), ListOfDataWaveNames , "=", ";"), SelectedDataToRemove)!=0)
			NewListOfDataFolderNames+=StringFromList(i,ListOfDataFolderNames, ";")+";"
			NewListOfDataWaveNames=ReplaceStringByKey("IntWave"+num2str(j), NewListOfDataWaveNames, StringByKey("IntWave"+num2str(i), ListOfDataWavenames ,"=" ,";"),"=",";")
			NewListOfDataWaveNames=ReplaceStringByKey("QWave"+num2str(j), NewListOfDataWaveNames, StringByKey("QWave"+num2str(i), ListOfDataWavenames ,"=" ,";"),"=",";")
			NewListOfDataWaveNames=ReplaceStringByKey("EWave"+num2str(j), NewListOfDataWaveNames, StringByKey("EWave"+num2str(i), ListOfDataWavenames ,"=" ,";"),"=",";")
			NewListOfDataOrgWvNames=ReplaceStringByKey("IntWave"+num2str(j), NewListOfDataOrgWvNames, StringByKey("IntWave"+num2str(i), ListOfDataWavenames ,"=" ,";"),"=",";")
			NewListOfDataOrgWvNames=ReplaceStringByKey("QWave"+num2str(j), NewListOfDataOrgWvNames, StringByKey("QWave"+num2str(i), ListOfDataWavenames ,"=" ,";"),"=",";")
			NewListOfDataOrgWvNames=ReplaceStringByKey("EWave"+num2str(j), NewListOfDataOrgWvNames, StringByKey("EWave"+num2str(i), ListOfDataWavenames ,"=" ,";"),"=",";")
			j+=1
		endif
	endfor	
	ListOfDataFolderNames=NewListOfDataFolderNames
	ListOfDataWaveNames=NewListOfDataWavenames
	ListOfDataOrgWvNames=NewListOfDataOrgWvNames
	
	PopupMenu RemoveDataList,mode=1,value= IR1P_ListWavesInGraphList(), win =IR1P_RemoveDataPanel
	SVAR SelectedDataToRemove=root:Packages:GeneralplottingTool:SelectedDataToRemove
	SelectedDataToRemove=StringFromList(0,IR1P_ListWavesInGraphList())
end
 
Function/T IR1P_ListWavesInGraphList()

	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	variable i, NumOfListedData
	string result="---;"
	NumOfListedData=ItemsInList(ListOfDataWaveNames , ";")/3		//this should return number of waves listed
	if (NumOfListedData>0)
		For(i=0;i<NumOfListedData;i+=1)
			result+=StringByKey("IntWave"+num2str(i), ListOfDataWaveNames , "=" , ";")+";"
		endfor
	else
		result="---"
	endif
	return result
end

Function/T IR1P_ListWavesInGraphListModify()

	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	variable i, NumOfListedData
	string result="---;"
	NumOfListedData=ItemsInList(ListOfDataWaveNames , ";")/3		//this should return number of waves listed
	if (NumOfListedData>0)
		For(i=0;i<NumOfListedData;i+=1)
			result+=StringByKey("IntWave"+num2str(i), ListOfDataWaveNames , "=" , ";")+";"
		endfor
	else
		result="---"
	endif
	return result
end



//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_MoreToolsFn()
	//here we create new panel with some more controls...
	
	KillWIndow/Z IR1P_MoreToolsPanel
	Execute ("IR1P_MoreToolsPanel()")
	
end
//and macro for this job...
//**********************************************************************************************************
//**********************************************************************************************************
Window IR1P_MoreToolsPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(473,73,785,400) as "IR1P_MoreToolsPanel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,textrgb= (0,0,65280)
	DrawText 5,22,"Some more handy tools are here..."
	SetDrawEnv fsize= 14,textrgb= (0,0,65280)
	DrawText 5,43,"These settings are NOT saved in user styles"
	SetDrawEnv fsize= 14,textrgb= (0,0,65280)
	DrawText 5,64,"and will not be recreated by the tool"
	SetDrawEnv fsize= 14,textrgb= (0,0,65280)
	DrawText 6,85,"1.   "
	Button AddDspacingTransAxis,pos={36.00,67.00},size={177.00,20.00},proc=IR1P_MoreToolsButtonProc,title="Add/remove d-spacing free axis"
	Button AddDspacingTransAxis,help={"Add/Remove to graqh axis which will display d spacing in nm"}
EndMacro

//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_MoreToolsButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(StringMatch(ba.ctrlName, "AddDspacingTransAxis"))
				IR1P_AddTransAxisQtoD()
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************
//Function IR1P_TransAxisdfromQ(w, x)
//	Wave/Z w
//	Variable x
//	return 2*pi/x
//end

Function IR1P_TransAxisdfromQ(s)
	STRUCT WMAxisHookStruct &s

	GetAxis/Q/W=$s.win $s.mastName	// get master (left) axis' range in V_min, V_Max

	s.max=pi/V_max / 10
	s.min=pi/V_min / 10
	s.units="nm"
	return 0
End


//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_AddTransAxisQtoD()
	
	DoWIndow/Z GeneralGraph
	if(V_Flag)
		GetAxis /W=GeneralGraph /Q d_axis 
		if(V_Flag)		//why in the world this is set to 1 when the axis DOES NOT exist??? 		
			//ModifyGraph mirror(bottom)=0	
			NewFreeAxis/W=GeneralGraph/T d_axis
			ModifyFreeAxis/W=GeneralGraph d_axis, master=bottom, hook=IR1P_TransAxisdfromQ
			Label/W=GeneralGraph d_axis "Dimension (π/q) [nm]"
			ModifyGraph/W=GeneralGraph log=NumberByKey("log(x)",AxisInfo("GeneralGraph", "bottom" ),"=")
			ModifyGraph/W=GeneralGraph tickExp(d_axis)=1,tickUnit(d_axis)=1,linTkLabel(d_axis)=1
			//ModifyGraph/W=GeneralGraph lblPos(d_axis)=50,lblLatPos=0
			ModifyGraph/W=GeneralGraph lblPosMode(d_axis)=4,lblPos(d_axis)=45,lblLatPos=0
		else
			KillFreeAxis/W=GeneralGraph d_axis
		endif


//		GetAxis /W=GeneralGraph /Q MT_bottom 
//		if(V_Flag)		//why in the world this is set to 1 when teh axcis DOES NOT exist??? 
//			SetupTransformMirrorAxis("GeneralGraph", "bottom", "IR1P_TransAxisdfromQ", $"", 5, 1, 5, 1)
//		endif
//		TicksForTransformAxis("GeneralGraph", "bottom", 5, 1, 1, "MT_bottom", 1,0)
//		ModifyGraph mirror(bottom)=0,mirror(MT_bottom)=0
//		Label MT_bottom "Dimension (2pi/q) [A]"
//		ModifyGraph lblPosMode(MT_bottom)=2,lblMargin(MT_bottom)=5
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//this creates panel for nit-picking users, dissatisfied with everything...

Function IR1P_ChangeGraphDetailsFn()
	//here we create new panel with some more controls...
	
	KillWIndow/Z IR1P_ChangeGraphDetailsPanel
	Execute ("IR1P_ChangeGraphDetailsPanel()")
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//and macro for this job...
Window IR1P_ChangeGraphDetailsPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(63,128.75,400,455.75) as "IR1P_ChangeGraphDetailsPanel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,textrgb= (0,0,65280)
	DrawText 5,23,"Here you can change details of graph formating"
	SetDrawEnv fsize= 14,textrgb= (0,0,65280)
	DrawText 5,23,"Here you can change details of graph formating"
	SetDrawEnv fsize= 14,textrgb= (0,0,65280)
	DrawText 14,44,"For details on terminology check Igor manual"
	SetDrawEnv fsize= 14,textrgb= (0,0,65280)
	DrawText 15,65,"These details should be saved in user styles"

	CheckBox GraphAxisStandoff pos={10,80},title="Axes standoff?", variable=root:Packages:GeneralplottingTool:GraphAxisStandoff
	CheckBox GraphAxisStandoff proc=IR1P_GenPlotCheckBox, help={"Standoff axes from start?"}	
	CheckBox GraphTicksIn pos={120,80},title="Ticks In?", variable=root:Packages:GeneralplottingTool:GraphTicksIn
	CheckBox GraphTicksIn proc=IR1P_GenPlotCheckBox, help={"Ticks in the graph pointing in?"}	
	SetVariable GraphAxisWidth pos={10,105},size={140,20},proc=IR1P_SetVarProc,title="Axis width:", limits={1,25,1}
	SetVariable GraphAxisWidth value= root:Packages:GeneralplottingTool:GraphAxisWidth, help={"Axis width selection."}		
	SetVariable GraphWindowWidth pos={10,125},size={140,20},proc=IR1P_SetVarProc,title="Graph width:", limits={100,1000,50}
	SetVariable GraphWindowWidth value= root:Packages:GeneralplottingTool:GraphWindowWidth, help={"Set the width of the graph."}		
	SetVariable GraphWindowHeight pos={10,145},size={140,20},proc=IR1P_SetVarProc,title="Graph height:", limits={100,1000,50}
	SetVariable GraphWindowHeight value= root:Packages:GeneralplottingTool:GraphWindowHeight, help={"Set the height of the graph."}		
	PopupMenu GraphLegendSize,pos={10,165},size={180,20},proc=IR1P_PanelPopupControl,title="Legend font size", help={"Select font size for legend to be used."}
	PopupMenu GraphLegendSize,mode=1,value= "06;08;10;12;14;16;18;20;22;24;", popvalue="10"
	PopupMenu GraphLegendPosition,pos={10,190},size={180,20},proc=IR1P_PanelPopupControl,title="Legend position", help={"Select position for legend in the graph."}
	PopupMenu GraphLegendPosition,mode=1,value= "Left Top;Right Top;Left Bottom;Right Bottom;Middle Center;Left Center;Right Center;Middle Top;Middle Bottom;", popvalue="---"

	SetVariable GraphLegendMaxItems pos={155,168},size={140,20},proc=IR1P_SetVarProc,title="Legend Max Items:", limits={10,100,10}
	SetVariable GraphLegendMaxItems value= root:Packages:GeneralplottingTool:GraphLegendMaxItems, help={"Approximate maximum number of items in Legend (100 is Igor max)."}		

	CheckBox GraphLegendFrame pos={10,220},title="Legend frame?", variable=root:Packages:GeneralplottingTool:GraphLegendFrame
	CheckBox GraphLegendFrame proc=IR1P_GenPlotCheckBox, help={"Check to have frame around the legend?"}	
	CheckBox GraphLegendUseFolderNms pos={10,240},title="Use folders in Legend?", variable=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
	CheckBox GraphLegendUseFolderNms proc=IR1P_GenPlotCheckBox, help={"Use folder names in Legend?"}	
	CheckBox GraphLegendUseWaveNote pos={10,260},title="Use wave note in Legend?", variable=root:Packages:GeneralplottingTool:GraphLegendUseWaveNote
	CheckBox GraphLegendUseWaveNote proc=IR1P_GenPlotCheckBox, help={"Use text from wave notes in Legend?"}	
	CheckBox GraphLegendShortNms pos={10,280},title="Only last folder in Legend?", variable=root:Packages:GeneralplottingTool:GraphLegendShortNms
	CheckBox GraphLegendShortNms proc=IR1P_GenPlotCheckBox, help={"Check to have legend use only last folder name."}	

	CheckBox CheckYAxisUnits pos={170,220},title="Do not check Y data units?", variable=root:Packages:GeneralplottingTool:DoNotCheckYAxisUnits
	CheckBox CheckYAxisUnits proc=IR1P_GenPlotCheckBox, help={"Check to skip checking the units for Y wave. Will not warn when different are loaded"}	


	CheckBox DisplayTimeAndDate pos={170,280},title="Date & time stamp?", variable=root:Packages:GeneralplottingTool:DisplayTimeAndDate
	CheckBox DisplayTimeAndDate proc=IR1P_GenPlotCheckBox, help={"Display date and time in the lower right corner"}	


	CheckBox GraphUseSymbolSet1 pos={10,300},title="Use closed symbols?", proc=IR1P_GenPlotCheckBox, variable=root:Packages:GeneralplottingTool:GraphUseSymbolSet1, help={"Check to have symbols to be set 1 (closed symbols)"}	
	CheckBox GraphUseSymbolSet2 pos={170,300},title="Use open symbols?", proc=IR1P_GenPlotCheckBox,variable=root:Packages:GeneralplottingTool:GraphUseSymbolSet2,  help={"Check to have symbols to be set 2 (open symbols)."}	
EndMacro
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//resets all intol fresh start
Function IR1P_ResetTool()
	//kill graph and reset the strings for new start

	KillWIndow/Z GeneralGraph
	KillWIndow/Z PlotingToolWaterfallGrph
	
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	SVAR ListOfDataFormating=root:Packages:GeneralplottingTool:ListOfDataFormating
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	SVAR ListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames

	ListOfDataOrgWvNames=""
	ListOfDataFolderNames=""
	ListOfDataWaveNames=""
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//Checkbox procedure
//Function IR1P_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
//	String ctrlName
//	Variable checked
//
//	string oldDf=GetDataFolder(1)
//	setDataFolder root:Packages:GeneralplottingTool
//
//	if (cmpstr(ctrlName,"UseIndra2Data")==0)
//		//here we control the data structure checkbox
//		NVAR UseIndra2Data=root:Packages:GeneralplottingTool:UseIndra2Data
//		NVAR UseQRSData=root:Packages:GeneralplottingTool:UseQRSData
//		NVAR UseResults=root:Packages:GeneralplottingTool:UseResults
////		UseIndra2Data=checked
//		if (checked)
//			UseQRSData=0
//			UseResults=0
//		endif
////		Checkbox UseIndra2Data, value=UseIndra2Data
////		Checkbox UseQRSData, value=UseQRSData
//		SVAR Dtf=root:Packages:GeneralplottingTool:DataFolderName
//		SVAR IntDf=root:Packages:GeneralplottingTool:IntensityWaveName
//		SVAR QDf=root:Packages:GeneralplottingTool:QWaveName
//		SVAR EDf=root:Packages:GeneralplottingTool:ErrorWaveName
//			Dtf=" "
//			IntDf=" "
//			QDf=" "
//			EDf=" "
//			PopupMenu SelectDataFolder mode=1
//			PopupMenu IntensityDataName   mode=1, value="---"
//			PopupMenu QvecDataName    mode=1, value="---"
//			PopupMenu ErrorDataName    mode=1, value="---"
//	endif
//	if (cmpstr(ctrlName,"UseQRSData")==0)
//		//here we control the data structure checkbox
//		NVAR UseQRSData=root:Packages:GeneralplottingTool:UseQRSData
//		NVAR UseIndra2Data=root:Packages:GeneralplottingTool:UseIndra2Data
//		NVAR UseResults=root:Packages:GeneralplottingTool:UseResults
////		UseQRSData=checked
//		if (checked)
//			UseIndra2Data=0
//			UseResults=0
//		endif
////		Checkbox UseIndra2Data, value=UseIndra2Data
////		Checkbox UseQRSData, value=UseQRSData
//		SVAR Dtf=root:Packages:GeneralplottingTool:DataFolderName
//		SVAR IntDf=root:Packages:GeneralplottingTool:IntensityWaveName
//		SVAR QDf=root:Packages:GeneralplottingTool:QWaveName
//		SVAR EDf=root:Packages:GeneralplottingTool:ErrorWaveName
//			Dtf=" "
//			IntDf=" "
//			QDf=" "
//			EDf=" "
//			PopupMenu SelectDataFolder mode=1
//			PopupMenu IntensityDataName   mode=1, value="---"
//			PopupMenu QvecDataName    mode=1, value="---"
//			PopupMenu ErrorDataName    mode=1, value="---"
//	endif
//	if (cmpstr(ctrlName,"UseResults")==0)
//		//here we control the data structure checkbox
//		NVAR UseQRSData=root:Packages:GeneralplottingTool:UseQRSData
//		NVAR UseIndra2Data=root:Packages:GeneralplottingTool:UseIndra2Data
//		NVAR UseResults=root:Packages:GeneralplottingTool:UseResults
////		UseQRSData=checked
//		if (checked)
//			UseIndra2Data=0
//			UseQRSData=0
//		endif
////		Checkbox UseIndra2Data, value=UseIndra2Data
////		Checkbox UseQRSData, value=UseQRSData
//		SVAR Dtf=root:Packages:GeneralplottingTool:DataFolderName
//		SVAR IntDf=root:Packages:GeneralplottingTool:IntensityWaveName
//		SVAR QDf=root:Packages:GeneralplottingTool:QWaveName
//		SVAR EDf=root:Packages:GeneralplottingTool:ErrorWaveName
//			Dtf=" "
//			IntDf=" "
//			QDf=" "
//			EDf=" "
//			PopupMenu SelectDataFolder mode=1
//			PopupMenu IntensityDataName   mode=1, value="---"
//			PopupMenu QvecDataName    mode=1, value="---"
//			PopupMenu ErrorDataName    mode=1, value="---"
//	endif
//end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//popup procedure
Function IR1P_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool

	NVAR UseIndra2Data=root:Packages:GeneralplottingTool:UseIndra2Data
	NVAR UseQRSData=root:Packages:GeneralplottingTool:UseQRSdata
	NVAR UseResults=root:Packages:GeneralplottingTool:UseResults
	SVAR Dtf=root:Packages:GeneralplottingTool:DataFolderName
	SVAR IntDf=root:Packages:GeneralplottingTool:IntensityWaveName
	SVAR QDf=root:Packages:GeneralplottingTool:QWaveName
	SVAR EDf=root:Packages:GeneralplottingTool:ErrorWaveName
	NVAR UseQRSData=root:Packages:GeneralplottingTool:UseQRSdata

	if (cmpstr(ctrlName,"GraphType")==0)
		//here goes what needs to be done, when we select this popup...
		//reformat the graph and make sure the right data exist and are in the graph.
		IR1P_ApplySelectedStyle(popStr)
	endif
	if (cmpstr(ctrlName,"XAxisDataType")==0)
		//here goes what needs to be done, when we select this popup...
		//reformat the graph and make sure the right data exist and are in the graph.
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating	//this contains data formating
		ListOfGraphFormating=ReplaceStringByKey("DataX", ListOfGraphFormating, popstr,"=")
		popupMenu GraphType, mode=1
		IR1P_UpdateAxisName("X",popstr)
		IR1P_UpdateGenGraph()
	endif
	if (cmpstr(ctrlName,"YAxisDataType")==0)
		//here goes what needs to be done, when we select this popup...
		//reformat the graph and make sure the right data exist and are in the graph.
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating	//this contains data formating
		ListOfGraphFormating=ReplaceStringByKey("DataY", ListOfGraphFormating, popstr,"=")
		ListOfGraphFormating=ReplaceStringByKey("DataE", ListOfGraphFormating, popstr,"=")
		popupMenu GraphType, mode=1
		IR1P_UpdateAxisName("Y",popstr)
		IR1P_UpdateGenGraph()
	endif
	if (cmpstr(ctrlName,"RemoveDataList")==0)
		//here goes what needs to be done, when we select this popup...
		SVAR SelectedDataToRemove=root:Packages:GeneralplottingTool:SelectedDataToRemove
		SelectedDataToRemove=popStr
	endif
	if (cmpstr(ctrlName,"ModifyDataList")==0)
		//here goes what needs to be done, when we select this popup...
		SVAR SelectedDataToModify=root:Packages:GeneralplottingTool:SelectedDataToModify
		SelectedDataToModify=popStr
		IR1P_CopyModifyData()
	endif
	if (cmpstr(ctrlName,"GraphLegendSize")==0)
		//here goes what needs to be done, when we select this popup...
		NVAR GraphLegendSize=root:Packages:GeneralplottingTool:GraphlegendSize
		GraphlegendSize=str2num(popStr)
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating	//this contains data formating
		ListOfGraphFormating=ReplaceStringByKey("Graph legend size", ListOfGraphFormating, popstr,"=")
		IR1P_UpdateGenGraph()
	endif
	if (cmpstr(ctrlName,"GraphLegendPosition")==0)
		//here goes what needs to be done, when we select this popup...
		SVAR GraphLegendPosition=root:Packages:GeneralplottingTool:GraphlegendPosition
		string PosShortcut
		if (cmpstr(popStr,"Left Top")==0)
			PosShortcut="LT"
		elseif (cmpstr(popStr,"Right Top")==0)
			PosShortcut="RT"
		elseif (cmpstr(popStr,"Left Bottom")==0)
			PosShortcut="LB"
		elseif (cmpstr(popStr,"Right Bottom")==0)
			PosShortcut="RB"
		elseif (cmpstr(popStr,"Middle Center")==0)
			PosShortcut="MC"
		elseif (cmpstr(popStr,"Left Center")==0)
			PosShortcut="LC"
		elseif (cmpstr(popStr,"Right Center")==0)
			PosShortcut="RC"
		elseif (cmpstr(popStr,"Middle Top")==0)
			PosShortcut="MT"
		elseif (cmpstr(popStr,"Middle Bottom")==0)
			PosShortcut="MB"
		endif
		//Left Top;Right Top;Left Bottom;Right Bottom;Middle Center;Left Center;Righ Center;Middle Top;Middle Bottom;
		GraphlegendPosition=PosShortcut
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating	//this contains data formating
		ListOfGraphFormating=ReplaceStringByKey("Graph legend Position", ListOfGraphFormating, PosShortcut,"=")
		IR1P_UpdateGenGraph()
	endif
	DoWIndow IR1P_ChangeGraphDetailsPanel
	if(V_Flag)
		DoWIndow/F IR1P_ChangeGraphDetailsPanel
	endif
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function/T IR1P_CheckRightResultsWvs(KnownWv)
	string KnownWv
	
	string result=""
	if(stringmatch(KnownWv,"UnifiedFitQvector_*"))
		result="UnifiedFitIntensity_"+KnownWv[18,inf]
	endif
	if(stringmatch(KnownWv,"UnifiedFitIntensity_*"))
		result="UnifiedFitQvector_"+KnownWv[20,inf]
	endif

	if(stringmatch(KnownWv,"SizesFitIntensity_*"))
		result="SizesFitQvector_"+KnownWv[18,inf]
	endif
	if(stringmatch(KnownWv,"SizesFitQvector_*"))
		result="SizesFitIntensity_"+KnownWv[16,inf]
	endif

	if(stringmatch(KnownWv,"SizesDistDiameter_*"))
		result="SizesVolumeDistribution_"+KnownWv[18,inf]
	endif
	if(stringmatch(KnownWv,"SizesVolumeDistribution_*"))
		result="SizesDistDiameter_"+KnownWv[24,inf]
	endif
	if(stringmatch(KnownWv,"SizesNumberDistribution_*"))
		result="SizesDistDiameter_"+KnownWv[24,inf]
	endif

	if(stringmatch(KnownWv,"ModelingIntensity_*"))
		result="ModelingQvector_"+KnownWv[18,inf]
	endif
	if(stringmatch(KnownWv,"ModelingQvector_*"))
		result="ModelingIntensity_"+KnownWv[16,inf]
	endif

	if(stringmatch(KnownWv,"ModelingDiameters_*"))
		result="ModelingVolumeDistribution_"+KnownWv[18,inf]
	endif
	if(stringmatch(KnownWv,"ModelingVolumeDistribution_*"))
		result="ModelingDiameters_"+KnownWv[27,inf]
	endif
	if(stringmatch(KnownWv,"ModelingNumberDistribution_*"))
		result="ModelingDiameters_"+KnownWv[27,inf]
	endif

	if(stringmatch(KnownWv,"FractFitIntensity_*"))
		result="FractFitQvector_"+KnownWv[18,inf]
	endif
	if(stringmatch(KnownWv,"FractFitQvector_*"))
		result="FractFitIntensity_"+KnownWv[16,inf]
	endif


	return result
end



Function IR1P_UpdateAxisName(which,WhatTypeSelected)
	string which,WhatTypeSelected
	

	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating	//this contains data formating
	SVAR GraphXAxisName=root:Packages:GeneralplottingTool:GraphXAxisName
	SVAR GraphYAxisName=root:Packages:GeneralplottingTool:GraphYAxisName
	SVAR ListOfDataFormating=root:Packages:GeneralplottingTool:ListOfDataFormating
	string Units=stringbykey("Units",ListOfDataFormating,"=",";")
	string NewLabel
	
	if (cmpstr(which,"X")==0)
		if(cmpstr(WhatTypeSelected,"X")==0)
			NewLabel="q [A\S-1\M]"
		elseif(cmpstr(WhatTypeSelected,"X^2")==0)
			NewLabel="q\S2\M [A\S-2\M]"
		elseif(cmpstr(WhatTypeSelected,"X^3")==0)
			NewLabel="q\S3\M [A\S-3\M]"
		elseif(cmpstr(WhatTypeSelected,"X^4")==0)
			NewLabel="q\S4\M [A\S-4\M]"
		else
			NewLabel=""
		endif
		
		ListOfGraphFormating=ReplaceStringByKey("Label bottom", ListOfGraphFormating, NewLabel,"=")
		GraphXAxisName=NewLabel
			
	elseif (cmpstr(which,"Y")==0)
			if(strlen(Units)<1)
				Units="cm\S2\M/cm\S3\M"
			else
				Units=ReplaceString("cm2/g", Units, "cm\S2\Mg\S-1\Msr\S-1\M")
				Units=ReplaceString("cm2/cm3", Units, "cm\S-1\Msr\S-1\M")
			endif

		if(cmpstr(WhatTypeSelected,"Y")==0)
			NewLabel="Intensity ["+Units+"]"
		elseif(cmpstr(WhatTypeSelected,"Y^2")==0)
			NewLabel="Intensity\S2\M [("+Units+")\S2\M]"
		elseif(cmpstr(WhatTypeSelected,"Y^3")==0)
			NewLabel="Intensity\S3\M [("+Units+")\S3\M]"
		elseif(cmpstr(WhatTypeSelected,"Y^4")==0)
			NewLabel="Intensity\S4\M [("+Units+")\S4\M]"
		elseif(cmpstr(WhatTypeSelected,"1/Y")==0)
			NewLabel="Intensity\S-1\M [("+Units+")\S-1\M]"
		elseif(cmpstr(WhatTypeSelected,"sqrt(1/Y)")==0)
			NewLabel="sqrt(Intensity\S-1\M) [sqrt("+Units+")]"
		elseif(cmpstr(WhatTypeSelected,"ln(Y*X^2)")==0)
			NewLabel="ln(Intensity * q\S2\M)"
		elseif(cmpstr(WhatTypeSelected,"ln(Y)")==0)
			NewLabel="ln(Intensity)"
		elseif(cmpstr(WhatTypeSelected,"ln(Y*X)")==0)
			NewLabel="ln(Intensity * q)"
		elseif(cmpstr(WhatTypeSelected,"Y*X^2")==0)
			NewLabel="Intensity * q\S2\M ["+Units+" * A\S-2\M]"
		elseif(cmpstr(WhatTypeSelected,"Y*X^4")==0)
			NewLabel="Intensity * q\S4\M ["+Units+" * A\S-4\M]"
		elseif(cmpstr(WhatTypeSelected,"Y*X^3")==0)
			NewLabel="Intensity * q\S3\M ["+Units+" * A\S-3\M]"
		else
			NewLabel=""
		endif
		
		
		ListOfGraphFormating=ReplaceStringByKey("Label left", ListOfGraphFormating, NewLabel,"=")
		GraphYAxisName=NewLabel
		
	endif
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************************
//		Initialize procedure, as usually
//**************************************************************************************************

Function IR1P_InitializeGenGraph()			//initialize general plotting tool.

	string oldDf=GetDataFolder(1)
	string ListOfVariables
	string ListOfStrings
	variable i
	//And these are needed in GeneralplottingTool folder
	if (!DataFolderExists("root:Packages:GeneralplottingTool"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:GeneralplottingTool
	endif

	SetDataFolder root:Packages:GeneralplottingTool					//go into the folder

//	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="ListOfDataFolderNames;ListOfDataWaveNames;ListOfGraphFormating;ListOfDataOrgWvNames;ListOfDataFormating;SelectedDataToModify;"
	ListOfStrings+="GraphXAxisName;GraphYAxisName;SelectedDataToRemove;GraphLegendPosition;ModifyIntName;ModifyQname;ModifyErrName;"
	ListOfStrings+="ListOfRemovedPoints;FittingSelectedFitFunction;FittingFunctionDescription;"
	ListOfStrings+="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;ContGraph3DColorScale;"

	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;DisplayTimeAndDate;"
	ListOfVariables+="GraphLogX;GraphLogY;GraphErrors;GraphXMajorGrid;GraphXMinorGrid;GraphYMajorGrid;GraphYMinorGrid;"
	ListOfVariables+="GraphLegend;GraphUseColors;GraphUseRainbow;GraphUseBW;GraphUseSymbols;GraphXMirrorAxis;GraphYMirrorAxis;GraphLineWidth;"
	ListOfVariables+="GraphUseSymbolSet1;GraphUseSymbolSet2;GraphLegendUseWaveNote;"
	ListOfVariables+="GraphLegendUseFolderNms;GraphLegendShortNms;GraphLegendMaxItems;GraphLeftAxisAuto;GraphLeftAxisMin;GraphLeftAxisMax;"
	ListOfVariables+="GraphBottomAxisAuto;GraphBottomAxisMin;GraphBottomAxisMax;GraphAxisStandoff;"
	ListOfVariables+="GraphUseLines;GraphSymbolSize;GraphVarySymbols;GraphVaryLines;GraphAxisWidth;"
	ListOfVariables+="GraphWindowWidth;GraphWindowHeight;GraphTicksIn;GraphLegendSize;GraphLegendFrame;"
	ListOfVariables+="ModifyDataBackground;ModifyDataMultiplier;ModifyDataQshift;ModifyDataErrorMult;"
	ListOfVariables+="TrimPointLargeQ;TrimPointSmallQ;FittingParam1;FittingParam2;FittingParam3;FittingParam4;FittingParam5;"
	ListOfVariables+="FitUseErrors;Xoffset;Yoffset;DoNotCheckYAxisUnits;"
	//3D graphs special controls
	ListOfVariables+="Graph3DClrMin;Graph3DClrMax;Graph3DAngle;Graph3DAxLength;Graph3DLogColors;Graph3DColorsReverse;"
	ListOfVariables+="GizmoNumLevels;GizmoUseLogColors;GizmoDisplayGrids;GizmoDisplayLabels;GizmoEstimatedVoronoiTime;"
	ListOfStrings+="Graph3DColorScale;Graph3DVisibility;"
	//Contour special controls
	ListOfVariables+="ContMinValue;ContMaxValue;ContNumCountours;ContDisplayContValues;ContLogContours;ContUseOnlyRedColor;ContSmoothOverValue;"
	//Movie special controls
	ListOfVariables+="MovieUse2Dgraph;MovieUse3DGraph;MovieReplaceData;MovieFrameRate;MovieFileOpened;MovieDisplayDelay;"
	ListOfStrings+=""

	SVAR/Z GizmoYaxisLegend
	if(!Svar_Exists(GizmoYaxisLegend))
		string/g GizmoYaxisLegend
	endif
	SVAR GizmoYaxisLegend
	if(strlen(GizmoYaxisLegend)<1)
		GizmoYaxisLegend=""
	endif
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
	SVAR ContGraph3DColorScale
	if(strlen(ContGraph3DColorScale)<1)
		ContGraph3DColorScale="none"
	endif
	
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
		//string ScreenWidthStr=stringFromList(3,  StringByKey("SCREEN1", IgorInfo(0)),",")
		//string ScreenHeightStr=stringFromList(4,  StringByKey("SCREEN1", IgorInfo(0)),",")
		//variable ScreenSizeV= IgorInfo(0)
		//GraphWindowWidth=(str2num(ScreenWidthStr))/2
		//GraphWindowHeight=(str2num(ScreenHeightStr))/2
		GraphWindowWidth=IN2G_GetGraphWidthHeight("width")
		GraphWindowHeight=IN2G_GetGraphWidthHeight("height")
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
	NVAR GizmoNumLevels
	if(GizmoNumLevels<5)
		GizmoNumLevels=100
	endif
	
	NVAR ContNumCountours
	if(ContNumCountours<10)
		ContNumCountours=11
	endif
       NVAR Graph3DAngle
       if(Graph3DAngle<10||numtype(Graph3DAngle)!=0)
    		  Graph3DAngle = 30
       endif
       NVAR Graph3DAxLength
       if(Graph3DAxLength<0.1||numtype(Graph3DAxLength)!=0)
	       Graph3DAxLength = 0.3
	 endif
	SVAR Graph3DColorScale
	if(strlen(Graph3DColorScale)<2)
		Graph3DColorScale="Rainbow"
	endif	 
	SVAR Graph3DVisibility
	if(strlen(Graph3DVisibility)<2)
		Graph3DVisibility="True"
	endif	 
	NVAR MovieFrameRate
	if(MovieFrameRate<1)
		MovieFrameRate=10
	endif
	NVAR MovieDisplayDelay
	if(MovieDisplayDelay<=0)
		MovieDisplayDelay=0.5
	endif
	NVAR GraphLegendMaxItems
	if(GraphLegendMaxItems<10 || GraphLegendMaxItems>100)
		GraphLegendMaxItems = 30
	endif

	if (!DataFolderExists("root:Packages:plottingToolsStyles"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:plottingToolsStyles
	endif
	SetDataFolder root:Packages:plottingToolsStyles					//go into the folder

	String/g LogLog
	SVAR LogLog
	LogLog="log(bottom)=1;log(left)=1;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q [A\S-1\M];Label left=Intensity [cm\S-1\M];"
	LogLog+="DataY=Y;DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;Axis left min=0;Axis left max=0;Axis bottom min=0;Axis bottom max=0;"
	LogLog+="standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width="+Num2str(GraphWindowWidth)+";Graph Window Height="+num2str(GraphWindowHeight)+";"//Graph Window Width=450;Graph Window Height=400
	LogLog+="Graph Use Rainbow=1;Graph Use BW=0;Graph use Colors=0;Graph vary Lines=1;"	
	LogLog+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
	LogLog+="Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	LogLog+="Graph3D Clr Min=0;Graph3D Clr Max=1;Graph3D Angle=30;Graph3D Ax Length=0.3;Graph3D Log Colors=0;Graph3D Colors Reverse=0;"
	LogLog+="Graph3D Color Scale=Rainbow;Graph3D Visibility=True;"

	String/g d_Intensity
	SVAR d_Intensity
	d_Intensity="log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=d [A];Label left=Intensity [arbitrary];"
	d_Intensity+="DataY=Y;DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;Axis left min=0;Axis left max=0;Axis bottom min=0;Axis bottom max=0;"
	d_Intensity+="standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width="+Num2str(GraphWindowWidth)+";Graph Window Height="+num2str(GraphWindowHeight)+";"//Graph Window Width=450;Graph Window Height=400
	d_Intensity+="Graph Use Rainbow=1;Graph Use BW=0;Graph use Colors=0;Graph vary Lines=1;"	
	d_Intensity+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
	d_Intensity+="Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	d_Intensity+="Graph3D Clr Min=0;Graph3D Clr Max=1;Graph3D Angle=30;Graph3D Ax Length=0.3;Graph3D Log Colors=0;Graph3D Colors Reverse=0;"
	d_Intensity+="Graph3D Color Scale=Rainbow;Graph3D Visibility=True;"

	String/g q_Intensity
	SVAR q_Intensity
	q_Intensity="log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q [A\S-1\M];Label left=Intensity [arbitrary];"
	q_Intensity+="DataY=Y;DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;Axis left min=0;Axis left max=0;Axis bottom min=0;Axis bottom max=0;"
	q_Intensity+="standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width="+Num2str(GraphWindowWidth)+";Graph Window Height="+num2str(GraphWindowHeight)+";"//Graph Window Width=450;Graph Window Height=400
	q_Intensity+="Graph Use Rainbow=1;Graph Use BW=0;Graph use Colors=0;Graph vary Lines=1;"	
	q_Intensity+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
	q_Intensity+="Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	q_Intensity+="Graph3D Clr Min=0;Graph3D Clr Max=1;Graph3D Angle=30;Graph3D Ax Length=0.3;Graph3D Log Colors=0;Graph3D Colors Reverse=0;"
	q_Intensity+="Graph3D Color Scale=Rainbow;Graph3D Visibility=True;"

	String/g tth_Intesity
	SVAR tth_Intesity
	tth_Intesity="log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=Theta [degrees];Label left=Intensity [arbitrary];"
	tth_Intesity+="DataY=Y;DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;Axis left min=0;Axis left max=0;Axis bottom min=0;Axis bottom max=0;"
	tth_Intesity+="standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width="+Num2str(GraphWindowWidth)+";Graph Window Height="+num2str(GraphWindowHeight)+";"//Graph Window Width=450;Graph Window Height=400
	tth_Intesity+="Graph Use Rainbow=1;Graph Use BW=0;Graph use Colors=0;Graph vary Lines=1;"	
	tth_Intesity+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
	tth_Intesity+="Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	tth_Intesity+="Graph3D Clr Min=0;Graph3D Clr Max=1;Graph3D Angle=30;Graph3D Ax Length=0.3;Graph3D Log Colors=0;Graph3D Colors Reverse=0;"
	tth_Intesity+="Graph3D Color Scale=Rainbow;Graph3D Visibility=True;"
	
	string/g VolumeDistribution
	SVAR VolumeDistribution
	VolumeDistribution="log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=Dimension [A];Label left=Volume fraction [1/A];DataY=Y;"
	VolumeDistribution+="DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;Axis left min=1.37359350144832e-06;Axis left max=0.0110271775364775;Axis bottom min=10;"
	VolumeDistribution+="Axis bottom max=5000;standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width="+Num2str(GraphWindowWidth)+";Graph Window Height="+num2str(GraphWindowHeight)+";"
	VolumeDistribution+="Graph use Colors=0;Graph Use Rainbow=1;Graph Use BW=0;"
	VolumeDistribution+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
	VolumeDistribution+="Legend=2;GraphLegendShortNms=0;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	VolumeDistribution+="Graph3D Clr Min=0;Graph3D Clr Max=1;Graph3D Angle=30;Graph3D Ax Length=0.3;Graph3D Log Colors=0;Graph3D Colors Reverse=0;"
	VolumeDistribution+="Graph3D Color Scale=Rainbow;Graph3D Visibility=True;"

	string/g NumberDistribution
	SVAR NumberDistribution
	NumberDistribution="log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=Dimension [A];Label left=Number of particles [1/(cm3*A)];DataY=Y;"
	NumberDistribution+="DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;Axis left min=1.37359350144832e-06;Axis left max=0.0110271775364775;Axis bottom min=10;"
	NumberDistribution+="Axis bottom max=5000;standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width="+Num2str(GraphWindowWidth)+";Graph Window Height="+num2str(GraphWindowHeight)+";"
	NumberDistribution+="Graph use Colors=0;Graph Use Rainbow=1;Graph Use BW=0;"
	NumberDistribution+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
	NumberDistribution+="Legend=2;GraphLegendShortNms=0;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	NumberDistribution+="Graph3D Clr Min=0;Graph3D Clr Max=1;Graph3D Angle=30;Graph3D Ax Length=0.3;Graph3D Log Colors=0;Graph3D Colors Reverse=0;"
	NumberDistribution+="Graph3D Color Scale=Rainbow;Graph3D Visibility=True;"

	string/g PDDF
	SVAR PDDF
	PDDF="log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=Distance [A];Label left=p(r);DataY=Y;DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;"
	PDDF+="Axis left min=-7.75876036780322e-07;Axis left max=7.4190884970254e-05;Axis bottom min=0;Axis bottom max=300;standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;"
	PDDF+="Graph Window Width="+Num2str(GraphWindowWidth)+";Graph Window Height="+num2str(GraphWindowHeight)+";Graph use Colors=1;Graph vary Lines=1;"
	PDDF+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;;"
	PDDF+="Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	PDDF+="Graph Use Rainbow=0;Graph Use BW=0;"	
	PDDF+="Graph3D Clr Min=0;Graph3D Clr Max=1;Graph3D Angle=30;Graph3D Ax Length=0.3;Graph3D Log Colors=0;Graph3D Colors Reverse=0;"
	PDDF+="Graph3D Color Scale=Rainbow;Graph3D Visibility=True;"


	string/g Porod
	SVAR Porod
	Porod= "log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q\S4\M [A\S-4\M];Label left=Intensity * q\S4\M [cm\S-1\M * A\S-4\M];DataY=Y*X^4;DataX=X^4;"
	Porod+= "DataE=Y*X^4;Axis left auto=1;Axis bottom auto=1;Axis left min=6.05481104002939e-09;Axis left max=0.0596273984790896;Axis bottom min=1.43458344252644e-16;Axis bottom max=0.0256131682633957;standoff=0;"
  	Porod+= "Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width="+Num2str(GraphWindowWidth)+";Graph Window Height="+num2str(GraphWindowHeight)+";Graph use Colors=1;"
  	Porod+= "Graph vary Lines=1;Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
 	Porod+= "Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	Porod+="Graph Use Rainbow=0;Graph Use BW=0;"	
	Porod+="Graph3D Clr Min=0;Graph3D Clr Max=1;Graph3D Angle=30;Graph3D Ax Length=0.3;Graph3D Log Colors=0;Graph3D Colors Reverse=0;"
	Porod+="Graph3D Color Scale=Rainbow;Graph3D Visibility=True;"

	string/g Debye_Bueche
	SVAR Debye_Bueche
	Debye_Bueche= "log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q\S2\M [A\S-2\M];Label left=sqrt(Intensity\S-1\M) [cm\S-0.5\M];DataY=sqrt(1/Y);DataX=X^2;DataE=sqrt(1/Y);"
	Debye_Bueche+= "Axis left auto=1;Axis bottom auto=1;Axis left min=0.000153926221956687;Axis left max=0.655403445936652;Axis bottom min=0.000109441353003394;Axis bottom max=0.400051428609657;standoff=0;"
  	Debye_Bueche+= "Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width="+Num2str(GraphWindowWidth)+";Graph Window Height="+num2str(GraphWindowHeight)+";Graph use Colors=1;"
  	Debye_Bueche+= "Graph vary Lines=1;Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
  	Debye_Bueche+= "Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	Debye_Bueche+="Graph Use Rainbow=0;Graph Use BW=0;"	
	Debye_Bueche+="Graph3D Clr Min=0;Graph3D Clr Max=1;Graph3D Angle=30;Graph3D Ax Length=0.3;Graph3D Log Colors=0;Graph3D Colors Reverse=0;"
	Debye_Bueche+="Graph3D Color Scale=Rainbow;Graph3D Visibility=True;"

	string/g Guinier
	SVAR Guinier
	Guinier="log(bottom)=0;log(left)=1;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q\S2\M [A\S-2\M];Label left=Intensity [cm\S-1\M];DataY=Y;DataX=X^2;DataE=Y;Axis left auto=1;"
	Guinier+="Axis bottom auto=1;Axis left min=5.41957359517844;Axis left max=1.78135123888276e+15;Axis bottom min=0.000109441353003394;Axis bottom max=0.400051428609657;standoff=0;"
  	Guinier+= "Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width="+Num2str(GraphWindowWidth)+";Graph Window Height="+num2str(GraphWindowHeight)+";Graph use Colors=1;"
  	Guinier+= "Graph vary Lines=1;Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
  	Guinier+= "Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	Guinier+="Graph Use Rainbow=0;Graph Use BW=0;"	
	Guinier+="Graph3D Clr Min=0;Graph3D Clr Max=1;Graph3D Angle=30;Graph3D Ax Length=0.3;Graph3D Log Colors=0;Graph3D Colors Reverse=0;"
	Guinier+="Graph3D Color Scale=Rainbow;Graph3D Visibility=True;"

	string/g Kratky
	SVAR Kratky
 	Kratky="log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q [A\S-1\M];Label left=Intensity * q\S2\M [cm\S-1\M * A\S-2\M];DataY=Y*X^2;DataX=X;DataE=Y*X^2;"
 	Kratky+="Axis left auto=1;Axis bottom auto=1;Axis left min=0.260499250084115;Axis left max=5.25105256354487;Axis bottom min=0.000109441353003394;Axis bottom max=0.400051428609657;standoff=0;Graph use Lines=1;"
   Kratky+="Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width="+Num2str(GraphWindowWidth)+";Graph Window Height="+num2str(GraphWindowHeight)+";Graph use Colors=1;"
 	Kratky+="Graph vary Lines=1;Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
   Kratky+="Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	Kratky+="Graph Use Rainbow=0;Graph Use BW=0;"	
	Kratky+="Graph3D Clr Min=0;Graph3D Clr Max=1;Graph3D Angle=30;Graph3D Ax Length=0.3;Graph3D Log Colors=0;Graph3D Colors Reverse=0;"
	Kratky+="Graph3D Color Scale=Rainbow;Graph3D Visibility=True;"


	string/g Zimm
	SVAR Zimm
	Zimm="log(bottom)=0;log(left)=0;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q\S2\M [A\S-2\M];Label left=Intensity\S-1\M [cm];DataY=1/Y;DataX=X^2;DataE=1/Y;Axis left auto=1;"
	Zimm+="Axis bottom auto=1;Axis left min=0.0266669243574142;Axis left max=6.07712268829346;Axis bottom min=0.000145193684147671;Axis bottom max=1.37456679344177;standoff=0;Graph use Lines=1;"
  	Zimm+="Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width="+Num2str(GraphWindowWidth)+";Graph Window Height="+num2str(GraphWindowHeight)+";Graph use Colors=1;"
	Zimm+="Graph vary Lines=1;Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
 	Zimm+="Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	Zimm+="Graph Use Rainbow=0;Graph Use BW=0;"	
	Zimm+="Graph3D Clr Min=0;Graph3D Clr Max=1;Graph3D Angle=30;Graph3D Ax Length=0.3;Graph3D Log Colors=0;Graph3D Colors Reverse=0;"
	Zimm+="Graph3D Color Scale=Rainbow;Graph3D Visibility=True;"

	
	ListOfGraphFormating="log(bottom)=1;log(left)=1;grid(left)=2;grid(bottom)=2;mirror(bottom)=1;mirror(left)=1;Label bottom=q [A\S-1\M];Label left=Intensity [cm\S-1\M];"
	ListOfGraphFormating+="DataY=Y;DataX=X;DataE=Y;Axis left auto=1;Axis bottom auto=1;Axis left min=0;Axis left max=0;Axis bottom min=0;Axis bottom max=0;"
	ListOfGraphFormating+="standoff=0;Graph use Lines=1;Graph use Symbols=1;msize=1;lsize=1;axThick=2;Graph Window Width="+Num2str(GraphWindowWidth)+";Graph Window Height="+num2str(GraphWindowHeight)+";"
	ListOfGraphFormating+="Graph use Colors=0;Graph vary Lines=1;"
	ListOfGraphFormating+="Graph Legend Size=10;Graph Legend Position=LB;Graph Legend Frame=1;Graph Vary Symbols=1;"
	ListOfGraphFormating+="Legend=2;GraphLegendShortNms=1;tick=0;GraphUseSymbolSet1=1;GraphUseSymbolSet2=0;DisplayTimeAndDate=1;Xoffset=0;Yoffset=0;"
	ListOfGraphFormating+="Graph Use Rainbow=1;Graph Use BW=0;"	
	ListOfGraphFormating+="Graph3D Clr Min=0;Graph3D Clr Max=1;Graph3D Angle=30;Graph3D Ax Length=0.3;Graph3D Log Colors=0;Graph3D Colors Reverse=0;"
	ListOfGraphFormating+="Graph3D Color Scale=Rainbow;Graph3D Visibility=True;"

	SetDataFolder root:Packages:GeneralplottingTool					//go into the folder

end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************


Function PorodInLogLog(w,Q) : FitFunc
	Wave w
	Variable Q

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(Q) = PorodConst * Q^4 + Background
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ Q
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = PorodConst
	//CurveFitDialog/ w[1] = Background

	return w[0] * Q^(-4) + w[1]
End


//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IRP_ErrorsForPowers(Value, Error, Power)
		variable Value, Error, Power
		
		variable errorResult
		errorResult =  ( (Value+Error)^Power - (Value)^Power )^2  + ( (Value-Error)^Power - (Value)^Power )^2
		errorResult = 0.5 *errorResult
		errorResult = sqrt(errorResult)
		return errorResult
end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IRP_ErrorsForLn(Value, Error)
		variable Value, Error
		
		variable errorResult, tempCalc
		errorResult =  (ln(1+Error/Value))^2
		tempCalc = Error/Value
		if (tempCalc<0.9)
			errorResult +=  (ln(1-Error/Value))^2
		else
			errorResult +=  1+(ln(1+Error/Value))^2
		endif
		errorResult = 0.5 *errorResult
		errorResult = sqrt(errorResult)
		return errorResult
end


//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IRP_ErrorsForInverse(Value, Error)
		variable Value, Error
		
		variable errorResult
		errorResult =  ( 1/(Value+Error) - 1/(Value) )^2  + ( 1/(Value-Error) - 1/(Value))^2
		errorResult = 0.5 *errorResult
		errorResult = sqrt(errorResult)
		return errorResult
end



//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IRP_ErrorsForSQRT(Value, Error)
		variable Value, Error
		
		variable errorResult
		errorResult =  (sqrt(Value+Error) - sqrt(Value) )^2  
		if ((Value-Error)>0)
			errorResult +=  ( sqrt(Value-Error) - sqrt(Value))^2
		else
			errorResult +=  + ( sqrt(Value+Error) - sqrt(Value))^2
		endif

		errorResult = 0.5 *errorResult
		errorResult = sqrt(errorResult)
		return errorResult
end



//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************



Function IR1P_StoreGraphs()

	KillWIndow/Z IR1P_StoreGraphsCtrlPnl

	IR1P_StoreGraphInit()
	Execute("IR1P_StoreGraphsCtrlPnl()")
end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_StoreGraphInit()

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages
	NewDataFolder/O root:Packages:StoredGraphs
	setDataFolder root:Packages:GeneralplottingTool
	
	string ListOfVariables, ListOfStrings
	ListOfVariables=""

	ListOfStrings="NewStoredGraphName;"
	
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	
	Make/O/N=0/T ListOfStoredGraphs
	
	IR1P_UpdateListOfStoredGraphs()
	
	setDataFolder OldDf
end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_UpdateListOfStoredGraphs()
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool
	Wave/T ListOfStoredGraphs=root:Packages:GeneralplottingTool:ListOfStoredGraphs
	
	string TempList=IN2G_CreateListOfItemsInFolder("root:Packages:StoredGraphs", 8)
	variable i
	redimension/N=(ItemsInList(TempList)) ListOfStoredGraphs
	For(i=0;i<ItemsInList(TempList);i+=1)
		ListOfStoredGraphs[i]=StringFromList(i,TempList)
	endfor
	setDataFolder OldDf		
end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_StoreGraphsButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(cmpstr(ctrlName,"SaveTiffFile")==0)
		DoWindow/F GeneralGraph
		SavePICT/E=-7/B=288
	endif
	if(cmpstr(ctrlName,"SaveJPGFile")==0)
		DoWindow/F GeneralGraph
		SavePICT/E=-6/B=288
	endif
	if(cmpstr(ctrlName,"SaveIgorRecMacro")==0)
		//here we need to create tiff file of the current generalGraph and save it
		DoWindow GeneralGraph
		if(V_Flag)
			DoWindow/F GeneralGraph
			Execute/P ("DoIgorMenu \"Control\", \"Window control\"")
		else
			abort
		endif
	endif

	if(cmpstr(ctrlName,"SaveIrena1Macro")==0)
		IR1P_SaveIrena1Macro()
	endif
	if(cmpstr(ctrlName,"LoadIrena1Macro")==0)
		IR1P_LoadIrena1Macro()
	endif
	if(cmpstr(ctrlName,"DeleteIrena1Macro")==0)
		IR1P_KillIrena1Macro()
	endif
End

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
Function IR1P_KillIrena1Macro()

	string OldDf=GetDataFolder(1)
	Wave/T ListOfStoredGraphs=root:Packages:GeneralplottingTool:ListOfStoredGraphs	
	string StringToLoad=""
	variable i
	ControlInfo /W=IR1P_StoreGraphsCtrlPnl ListOfGraphs
	StringToLoad = ListOfStoredGraphs[V_Value]
	setDataFolder root:Packages:StoredGraphs
	SVAR tempStr=$(StringToLoad)
	KillStrings tempStr 
	setDataFOlder oldDf
	IR1P_UpdateListOfStoredGraphs()
end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_LoadIrena1Macro()

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	SVAR ListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	SVAR ListOfDataFormating=root:Packages:GeneralplottingTool:ListOfDataFormating
	Wave/T ListOfStoredGraphs=root:Packages:GeneralplottingTool:ListOfStoredGraphs
	
	string StringToLoad=""
	variable i
	ControlInfo /W=IR1P_StoreGraphsCtrlPnl ListOfGraphs
	StringToLoad = ListOfStoredGraphs[V_Value]
	setDataFolder root:Packages:StoredGraphs
	SVAR tempStr=$(StringToLoad)
	ListOfDataFolderNames=StringByKey("ListOfDataFolderNames", tempStr , "@"  , ">>>")
	ListOfDataWaveNames=StringByKey("ListOfDataWaveNames", tempStr , "@"  , ">>>")
	ListOfGraphFormating=StringByKey("ListOfGraphFormating", tempStr , "@"  , ">>>")
	ListOfDataOrgWvNames=StringByKey("ListOfDataOrgWvNames", tempStr , "@"  , ">>>")
	ListOfDataFormating=StringByKey("ListOfDataFormating", tempStr , "@"  , ">>>")
	
	setDataFOlder oldDf
	IR1P_SynchronizeListAndVars()
	IR1P_CreateGraph()
end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_SaveIrena1Macro()

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:GeneralplottingTool
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	SVAR ListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	SVAR ListOfDataFormating=root:Packages:GeneralplottingTool:ListOfDataFormating
	SVAR NewStoredGraphName=root:Packages:GeneralplottingTool:NewStoredGraphName
	if(strlen(NewStoredGraphName)<=0)
		Abort "Input name first, please"
	endif

	string StringToSave=""
	StringToSave+="ListOfDataFolderNames@"+ListOfDataFolderNames+">>>"
	StringToSave+="ListOfDataWaveNames@"+ListOfDataWaveNames+">>>"
	StringToSave+="ListOfGraphFormating@"+ListOfGraphFormating+">>>"
	StringToSave+="ListOfDataOrgWvNames@"+ListOfDataOrgWvNames+">>>"
	StringToSave+="ListOfDataFormating@"+ListOfDataFormating+">>>"
	setDataFolder root:Packages:StoredGraphs
	string/g $(NewStoredGraphName)
	SVAR tempStr=$(NewStoredGraphName)
	tempStr = StringToSave
	setDataFOlder oldDf	
	IR1P_UpdateListOfStoredGraphs()
end

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_StoreGraphSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	if(cmpstr("NewGraphMacroName",ctrlName)==0)
		SVAR NewStoredGraphName=root:Packages:GeneralplottingTool:NewStoredGraphName
		string OldDf=GetDataFolder(1)
		setDataFolder root:Packages:StoredGraphs
		NewStoredGraphName=cleanupName(NewStoredGraphName,0)
		if(CheckName(NewStoredGraphName, 4)!=0)
			NewStoredGraphName = UniqueName(NewStoredGraphName,4,0)
		endif
		setDataFOlder OldDf	
	endif
End

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
Window IR1P_StoreGraphsCtrlPnl() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(99,127.25,458.25,550.25) as "IR1P_StoreGraphsCtrlPnl"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 3,textrgb= (0,0,65280)
	DrawText 60,25,"Save and store graphs"
	SetDrawEnv fstyle= 1,textrgb= (0,0,65280)
	DrawText 72,52,"To save graph to separate file:"
	SetDrawEnv fstyle= 1,textrgb= (0,0,65280)
	DrawText 68,99,"To save IGOR recreation macro:"
	SetDrawEnv fstyle= 1,textrgb= (0,0,65280)
	DrawText 63,153,"To save Irena Plotting tool graph:"
	SetDrawEnv fstyle= 1,textrgb= (0,0,65280)
	DrawText 61,226,"To load Irena Plotting tool graph:"
	Button SaveTiffFile,pos={8,56},size={150,20}, proc=IR1P_StoreGraphsButtonProc,title="Save tiff file", help={"Use this button to export TIFF file with 300 dpi resolution of current graph"}
	Button SaveJPGFile,pos={177,55},size={150,20}, proc=IR1P_StoreGraphsButtonProc,title="Save jpg file", help={"Use this button to export JPG file with 300 dpi resolution of current graph"}
	Button SaveIgorRecMacro,pos={44,109},size={220,20}, proc=IR1P_StoreGraphsButtonProc,title="Save Igor recreation macro", help={"Use this button to create Igor recreation macro"}
	Button SaveIrena1Macro,pos={116,181},size={220,20}, proc=IR1P_StoreGraphsButtonProc,title="Store Irena plotting tool graph", help={"Use this button to store Irena plotting tool recreation macro"}
	SetVariable NewGraphMacroName,pos={4,160},size={350,16},proc=IR1P_StoreGraphSetVarProc,title="Name for Saved Graph: ", help={"New Irena plotting tool macro name"}
	SetVariable NewGraphMacroName,value= root:Packages:GeneralplottingTool:NewStoredGraphName
	ListBox ListOfGraphs,pos={10,233},size={330,120}, mode=1
	ListBox ListOfGraphs,listWave=root:Packages:GeneralplottingTool:ListOfStoredGraphs, help={"Here are listed stored Irena plotting tool recreation macros"}
//	ListBox ListOfGraphs,selWave=root:Packages:GeneralplottingTool:ListOfStoredGraphsControl
	Button LoadIrena1Macro,pos={41,363},size={260,20}, proc=IR1P_StoreGraphsButtonProc,title="Load selected Plotting tool stored graph", help={"Use this button to load stored Irena plotting tool macros"}
	Button DeleteIrena1Macro,pos={40,393},size={260,20}, proc=IR1P_StoreGraphsButtonProc,title="Delete selected Plotting tool stored graph", help={"Use this button to load delete Irena plotting tool macros"}
EndMacro

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_GizmoCreate3DGizmoGraph()

	if(!IR1P_GizmoFunctionality())
		Abort "The graphic card of your system is insufficient for Gizmo functionality. You need to get better graphic card before using Gizmo."
	endif

	IR1P_GizmoCreatePanel()
	NVAR GizmoEstimatedVoronoiTime=root:Packages:GeneralplottingTool:GizmoEstimatedVoronoiTime
	GizmoEstimatedVoronoiTime = IR1P_GuessVoronoiTime()
end
//*************************************************************************************************************
//*************************************************************************************************************
Function IR1P_GizmoFunctionality()
	KillWIndow/Z testGizmo
#if(IgorVersion()<6.99)		//Igor 6
	Execute("NewGizmo/i/Z/N=testGizmo")
#else
	NewGizmo /I /N=testGizmo /K=1
#endif
	DoWIndow testGizmo
	if(V_Flag)
		KillWIndow/Z testGizmo
		//print "GC OK"
		return 1
	else
		print "Get better Graphic card, Gizmo on this Graphic card is not possible"
		return 0
	endif
end
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_GizmoCreatePanel()
//GizmoNumLevels
	DoWindow GizmoControlPanel
	if(V_Flag)
		DoWindow/F GizmoControlPanel
	else
	
		NewPanel /K=1/N=GizmoControlPanel/W=(402,44,782,319) as "Irena 3D Plot panel"
		//DoWindow/C IR1P_CreateGizmoPanel
		//ShowTools/A
		SetDrawLayer UserBack
		SetDrawEnv fsize= 14,fstyle= 3,textrgb= (0,0,65535)
		DrawText 87,28,"Irena \"Gizmo\" 3D plot panel"
		SetVariable GizmoNumLevels,pos={13,37},size={200,15},title="Number of q points", help={"Number of points in Q rto be calculated"}
		SetVariable GizmoNumLevels,value= root:Packages:GeneralplottingTool:GizmoNumLevels, limits={10,500,25}
		SetVariable GizmoNumLevels proc=IR1P_GizmoSetVarProc
		SetVariable GizmoEstimatedVoronoiTime,pos={13,60},size={300,15},title="Estimated Calculation time [sec]   ", help={"Wild guess how long the Data preparation will take"}
		SetVariable GizmoEstimatedVoronoiTime,value= root:Packages:GeneralplottingTool:GizmoEstimatedVoronoiTime
		SetVariable GizmoEstimatedVoronoiTime noedit=1,fstyle=2,valueColor=(65535,0,0),limits={-inf,inf,0}, frame=0

	
		Button GizmoGenerateDataAndGraph,pos={62,80},size={200,15},title="Create 3D data and plot", proc=IR1P_InputPanelButtonProc, help={"Create/Recreate the data and create plot"}
		Button GizmoReGraph,pos={62,100},size={200,15},title="Recreate 3D plot", proc=IR1P_InputPanelButtonProc,help={"Use old data iof available without recreating them. Create plot. Fast. "}
	
		CheckBox GizmoDisplayGridLines title="Grid lines?",proc=IR1P_GizmoCheckProc, pos={10,130}, help={"Display grid lines"}
		CheckBox GizmoDisplayGridLines variable=root:Packages:GeneralplottingTool:GizmoDisplayGrids
		CheckBox GizmoDisplayLabels title="Axes lables?",proc=IR1P_GizmoCheckProc, pos={10,150},help={"Display legends, uses legends from main tool"}
		CheckBox GizmoDisplayLabels variable=root:Packages:GeneralplottingTool:GizmoDisplayLabels
	
		SetVariable GizmoYaxisLegend,pos={120,150},size={250,15},title="Data order legend", help={"Text to be used on data order axis"}
		SetVariable GizmoYaxisLegend,value= root:Packages:GeneralplottingTool:GizmoYaxisLegend, limits={-inf,inf,0}
		SetVariable GizmoYaxisLegend proc=IR1P_GizmoSetVarProc
	
		PopupMenu ColorTable,pos={15,180},size={180,20},title="Colors:", proc=IR1P_Gizmo_PopMenuProc, help={"Select color table"}
		SVAR Graph3DColorScale=root:Packages:GeneralplottingTool:Graph3DColorScale
		PopupMenu ColorTable,mode=1,popvalue=Graph3DColorScale,value= #"CTabList()", bodyWidth=150
	
		Button UpdateGizmo,pos={62,240},size={200,20},title="Sync w/Main panel", proc=IR1P_InputPanelButtonProc, help={"update to reflect changes made in main panel, such as zoom etc. "}
		// add Gizmo procedures
		//#include <All Gizmo Procedures>
		Execute/P "INSERTINCLUDE <All Gizmo Procedures>"
		Execute/P "COMPILEPROCEDURES "
		
	endif
	SetWindow GizmoControlPanel, hook(GizmoHook)= IR1P_GizmoHookFunction
	AutoPositionWindow/M=0/R=IR1P_ControlPanel GizmoControlPanel
	DoWIndow Irena_Gizmo
	if(V_Flag)
		AutoPositionWindow/M=1/R=GizmoControlPanel  Irena_Gizmo
	endif
end
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_Gizmo_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			SVAR Graph3DColorScale = root:Packages:GeneralplottingTool:Graph3DColorScale
			Graph3DColorScale = popStr
			IR1P_GizmoFormatGraph()	
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************


Function IR1P_GizmoSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			if(stringmatch(sva.ctrlName,"GizmoNumLevels"))
				NVAR GizmoEstimatedVoronoiTime=root:Packages:GeneralplottingTool:GizmoEstimatedVoronoiTime
				GizmoEstimatedVoronoiTime = IR1P_GuessVoronoiTime()
			endif
			if(stringmatch(sva.ctrlName,"GizmoYaxisLegend"))
				IR1P_GizmoFormatGraph()	
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************
Function IR1P_GizmoCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	DoWIndow Irena_Gizmo
	if(!V_Flag)
		return 0	//no Gizmo plot to fix at this time
	endif
	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			string ctrlName= cba.ctrlName
			if(stringmatch(ctrlName,"GizmoDisplayGridLines"))
				if(checked)
					PauseUpdate
					Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=GPISurfaceData property={ lineColorType,1}")
					Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=GPISurfaceData property={ lineColor,0,0,0,1}")
					Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=GPISurfaceData property={ fillMode,3}	")
					DoUpdate
				else
					Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=GPISurfaceData property={ fillMode,2}")
				endif
			endif
			if(stringmatch(ctrlName,"GizmoDisplayLabels"))
				SVAR GraphXAxisName = root:Packages:GeneralplottingTool:GraphXAxisName
				SVAR GraphYAxisName = root:Packages:GeneralplottingTool:GraphYAxisName
				if(checked)
						PauseUpdate
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={0,axisLabel,1}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={8,axisLabel,1}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={2,axisLabel,1}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={0,axisLabelCenter,-0.5}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={8,axisLabelCenter,-0.5}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={2,axisLabelCenter,-0.5}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={0,axisLabelDistance,0.2}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={8,axisLabelDistance,0.2}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={2,axisLabelDistance,0.2}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={0,axisLabelScale,0.5}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={8,axisLabelScale,0.5}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={2,axisLabelScale,0.5}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={0,axisLabelRGBA,0,0,0,1}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={8,axisLabelRGBA,0,0,0,1}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={2,axisLabelRGBA,0,0,0,1}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={0,axisLabelText,\""+GraphXAxisName+"\"}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={8,axisLabelText,\""+"Data order"+"\"}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={2,axisLabelText,\""+GraphYAxisName+"\"}")
						DoUpdate
				else
						PauseUpdate
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={0,axisLabelText,\"\"}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={8,axisLabelText,\" \"}")
						Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={2,axisLabelText,\" \"}")
						DoUpdate
				endif
			endif
				
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************

Function IR1P_GizmoCreateDataAndGraph(ForceUpdate)
		variable ForceUpdate
		//gizmo
		Wave/Z GizmoWaveDataIntp=root:Packages:GeneralplottingTool:Waterfall:GizmoWaveDataIntp
		variable ForceUpdateL
		
		if(ForceUpdate||!WaveExists(GizmoWaveDataIntp))
			print "Creating data for Gizmo 3D plot, this will take a while"
			IR1P_CreateDataToPlot()			
			IR1P_genGraphCreateDataGizmo()
		endif

		//create Gizmo if it does not exist and update it...
		Dowindow Irena_Gizmo
		if(!V_Flag)
			Execute("IR1P_genGraphGizmo()")
			//DoWindow/C/T Irena_Gizmo,"Irena 3D plot"
			//ZoomAndPanPanel()
			//attach hook function which removes All Gizmo Procedures when window is killed.
		else
			Dowindow/F Irena_Gizmo
			
		endif	
//		DoWIndow Irena_Gizmo
//		if(V_Flag)
//			print "Gizmo Plot Irena_Gizmo exists"
//			SetWindow Irena_Gizmo, hook(GizmoHook)= IR1P_GizmoHookFunction
//		endif
		IR1P_GizmoFormatGraph()

end


Function IR1P_GizmoHookFunction(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	switch(s.eventCode)
//		case 0:				// Activate
//			// Handle activate
//			break
//		case 1:				// Deactivate
//			// Handle deactivate
//			break
		case 2:				// Deactivate
			Execute/P "DELETEINCLUDE <All Gizmo Procedures>"
			Execute/P "COMPILEPROCEDURES "
			break
		// And so on . . .
	endswitch

	return hookResult		// 0 if nothing done, else 1
End

		// add Gizmo procedures
		//#include <All Gizmo Procedures>

end
//*************************************************************************************************************
//*************************************************************************************************************
//*************************************************************************************************************


Function IR1P_genGraphCreateDataGizmo()
	//create data for the waterfall...

	NewDataFolder/O/S root:Packages:GeneralplottingTool:Waterfall
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	NVAR Graph3DClrMin = root:Packages:GeneralplottingTool:Graph3DClrMin
	NVAR Graph3DClrMax = root:Packages:GeneralplottingTool:Graph3DClrMax
	NVAR GraphLogX=root:Packages:GeneralplottingTool:GraphLogX
	NVAR GraphLogY=root:Packages:GeneralplottingTool:GraphLogY
	NVAR GizmoNumLevels=root:Packages:GeneralplottingTool:GizmoNumLevels

	variable NumberOfWaves,i
      print "This tool is currently under developemnt, so consider this beta version of operations"
      print "If the Igor now freezes and runs for long time, it is because you have too many points in the plot and"
      print "the calculations needed for Gizmo just take too long time. Wait (it can take 10 minutes on my test case!)" 		
	NumberOfWaves=ItemsInList(ListOfDataFolderNames)
	if(NumberOfWaves<2)
		abort "Not enough data in the tool, need at least 3 data sets"
	endif
	variable NumberOfQPoints=0
	For(i=0;i<NumberOfWaves;i+=1)
		Wave QWv=$(StringByKey("QWave"+num2str(i), ListOfDataWaveNames  , "="))
		NumberOfQPoints+=numpnts(QWv)
	endfor
	//now we have total number of points user placeds in the graph...
	
	Make/O/N=(NumberOfQPoints,3) GizmoWaveData
	//next need to fill this with the points as below, [0] is q, [1] is order number [2] is Intensity
//•triplet [][0]=PlottingTool_q[p]
//•triplet [][1]=0
//•triplet [][2]=PlottingTool_Int_M[p][0]
	Make/O/Free/N=0 IntWvTmp, OrderTmp, QWvTmp
	variable j
	For(i=0;i<NumberOfWaves;i+=1)
		Wave IntWv=$(StringByKey("IntWave"+num2str(i), ListOfDataWaveNames  , "="))
		Wave QWv=$(StringByKey("QWave"+num2str(i), ListOfDataWaveNames  , "="))
		//Wave/Z EWv=$(StringByKey("EWave"+num2str(i), ListOfDataWaveNames  , "="))
		//duplicate and clean up of negative intensities and Q=0 points...
		Duplicate/Free/O IntWv, IntWvClean
		Duplicate/Free/O QWv, QWvClean
		for(j=numpnts(QWv)-1;j>=0;j-=1)
			if(IntWvClean[j]<=0 && QWvClean[j]<=0)
				DeletePoints j, 1, IntWvClean, QWvClean
			endif
		endfor
		
		Concatenate /NP /O  {QWvTmp, QWvClean}, QWvTmp2
		Duplicate/O/Free IntWvClean, OrderTmp2
		OrderTmp2 = i
		Concatenate /NP /O  {IntWvTmp, IntWvClean}, IntWvTmp2
		Concatenate /NP /O  {OrderTmp, OrderTmp2}, OrderTmp2
		Duplicate/O/Free OrderTmp2, OrderTmp
		Duplicate/O/Free IntWvTmp2, IntWvTmp
		Duplicate/O/Free QWvTmp2, QWvTmp		
	endfor
		if(GraphLogX)
			QWvTmp = log(QWvTmp[p])
		endif
		if(GraphLogY)
			IntWvTmp = log(IntWvTmp[p])
		endif
		GizmoWaveData[][2]=IntWvTmp[p]
		GizmoWaveData[][1]=OrderTmp[p]
		GizmoWaveData[][0]=QWvTmp[p]
		variable Indx1min, Indx1max, Indx1Step
		wavestats/q QWvTmp
			Indx1min=V_min
			Indx1max=V_max
		Indx1Step = (Indx1max - Indx1min)/GizmoNumLevels
		//GuessVoronoiTime()
		//variable runTime=ticks
		ImageInterpolate/S ={Indx1min,Indx1Step,Indx1max,0,1,NumberOfWaves+1} Voronoi GizmoWaveData
		//print (ticks-runTime)/60		
		Wave M_InterpolatedImage = root:Packages:GeneralplottingTool:Waterfall:M_InterpolatedImage
		Duplicate /O M_InterpolatedImage, GizmoWaveDataIntp
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function IR1P_GuessVoronoiTime()

	//	t=k1*(Ninp^2)+k3*Ninp*(Nx*Ny)
	//count Ninp
	variable NumberOfWaves,i, Ninp, Nx, Ny
	Ninp=0
	Nx=0
	Ny=0
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	NumberOfWaves=ItemsInList(ListOfDataFolderNames)
	if(NumberOfWaves<2)
		return 0
	endif
	For(i=0;i<NumberOfWaves;i+=1)
		Wave QWv=$(StringByKey("QWave"+num2str(i), ListOfDataWaveNames  , "="))
		Ninp+=numpnts(QWv)
		Ny+=1
	endfor
	//count Nx * Ny
	NVAR GizmoNumLevels=root:Packages:GeneralplottingTool:GizmoNumLevels	//useless, actually...
	Nx=GizmoNumLevels
	
	variable TriangK=2.111e-08
	variable CalcK=4.50514e-08
	variable result=TriangK*Ninp^2 + CalcK*Ninp*Nx*Ny
	
//	print Ninp
//	print Nx
//	print Ny
//	print result
	return result

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

//**********************************************************************************************************
Function IR1P_GizmoFormatGraph()
	//this zooms axes
	DoWIndow Irena_Gizmo
	if(!V_Flag)
		return 0	//no widnow to control
	endif
	
	IR1P_GizmoSetAxesValues()
	//here we deal with the legends and grids
	NVAR GizmoDisplayGridLines = root:Packages:GeneralplottingTool:GizmoDisplayGrids
	if(GizmoDisplayGridLines)
		PauseUpdate
		Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=GPISurfaceData property={ lineColorType,1}")
		Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=GPISurfaceData property={ lineColor,0,0,0,1}")
		Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=GPISurfaceData property={ fillMode,3}	")
		DoUpdate
	else
		Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=GPISurfaceData property={ fillMode,2}")
	endif
	NVAR GizmoDisplayLabels = root:Packages:GeneralplottingTool:GizmoDisplayLabels
	SVAR GraphXAxisName = root:Packages:GeneralplottingTool:GraphXAxisName
	SVAR GraphYAxisName = root:Packages:GeneralplottingTool:GraphYAxisName
	SVAR GizmoYaxisLegend=root:Packages:GeneralplottingTool:GizmoYaxisLegend
	if(GizmoDisplayLabels)
			PauseUpdate
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={0,axisLabel,1}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={8,axisLabel,1}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={2,axisLabel,1}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={0,axisLabelCenter,-0.5}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={8,axisLabelCenter,-0.5}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={2,axisLabelCenter,-0.5}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={0,axisLabelDistance,0.2}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={8,axisLabelDistance,0.2}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={2,axisLabelDistance,0.2}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={0,axisLabelScale,0.5}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={8,axisLabelScale,0.5}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={2,axisLabelScale,0.5}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={0,axisLabelRGBA,0,0,0,1}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={8,axisLabelRGBA,0,0,0,1}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={2,axisLabelRGBA,0,0,0,1}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={0,axisLabelText,\""+GraphXAxisName+"\"}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={8,axisLabelText,\""+GizmoYaxisLegend+"\"}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={2,axisLabelText,\""+GraphYAxisName+"\"}")
			DoUpdate
	else
			PauseUpdate
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={0,axisLabelText,\"\"}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={8,axisLabelText,\" \"}")
			Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=axes0,property={2,axisLabelText,\" \"}")
			DoUpdate
	endif
	SVAR Graph3DColorScale = root:Packages:GeneralplottingTool:Graph3DColorScale
	Execute("ModifyGizmo/N=Irena_Gizmo ModifyObject=GPISurfaceData property={ surfaceCTab,"+Graph3DColorScale+"}")

end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function IR1P_GizmoSetAxesValues()

		NVAR GraphLeftAxisAuto =root:Packages:GeneralplottingTool:GraphLeftAxisAuto
		NVAR ZMin = root:Packages:GeneralplottingTool:GraphLeftAxisMin
		NVAR Zmax =root:Packages:GeneralplottingTool:GraphLeftAxisMax
		NVAR GraphBottomAxisAuto = root:Packages:GeneralplottingTool:GraphBottomAxisAuto
		NVAR Xmin = root:Packages:GeneralplottingTool:GraphBottomAxisMin
		NVAR Xmax = root:Packages:GeneralplottingTool:GraphBottomAxisMax
		NVAR GraphLogX = root:Packages:GeneralplottingTool:GraphLogX
		NVAR GraphLogY = root:Packages:GeneralplottingTool:GraphLogY
		variable XmaxL, XminL, YmaxL, YminL, ZminL, ZmaxL
		if(GraphLogX)
			XmaxL=log(Xmax)
			XminL=log(Xmin)
		else
			XmaxL=(Xmax)
			XminL=(Xmin)
		endif
		if(GraphLogY)
			ZmaxL=log(Zmax)
			ZminL=log(Zmin)
		else
			ZmaxL=(Zmax)
			ZminL=(Zmin)
		endif
		Execute("ModifyGizmo/N=Irena_Gizmo setOuterBox={"+num2str(XminL)+","+num2str(XmaxL)+",0,1,"+num2str(ZminL)+","+num2str(ZmaxL)+"}")
		if(!GraphBottomAxisAuto && GraphLeftAxisAuto )
			Execute("ModifyGizmo/N=Irena_Gizmo scalingOption=60")			//60 autoscale Y and Z
		elseif(GraphBottomAxisAuto && !GraphLeftAxisAuto)
			Execute("ModifyGizmo/N=Irena_Gizmo scalingOption=15")			//15 is autoscale X and Y
		elseif(!GraphBottomAxisAuto && !GraphLeftAxisAuto)
			Execute("ModifyGizmo/N=Irena_Gizmo scalingOption=12")			//12 is autorange only y axis
		elseif(GraphBottomAxisAuto && GraphLeftAxisAuto)
			Execute("ModifyGizmo/N=Irena_Gizmo ScalingMode=2")
		endif	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Window IR1P_genGraphGizmo() : GizmoPlot
	PauseUpdate; Silent 1	// Building Gizmo 6 window...

	// Do nothing if the Gizmo XOP is not available.
	if(exists("NewGizmo")!=4)
		DoAlert 0, "Gizmo XOP must be installed"
		return
	endif

	NewGizmo/K=1/N=Irena_Gizmo/T="Irena 3D plot" /W=(393,556,936,955)
	ModifyGizmo startRecMacro
	AppendToGizmo Surface=root:Packages:GeneralplottingTool:Waterfall:GizmoWaveDataIntp,name=GPISurfaceData
	ModifyGizmo ModifyObject=GPISurfaceData property={ srcMode,0}
	ModifyGizmo ModifyObject=GPISurfaceData property={ surfaceCTab,Rainbow}
	AppendToGizmo Axes=boxAxes,name=axes0
	ModifyGizmo ModifyObject=axes0,property={-1,axisScalingMode,1}
	ModifyGizmo ModifyObject=axes0,property={-1,axisColor,0,0,0,1}
	ModifyGizmo ModifyObject=axes0,property={0,ticks,3}
	ModifyGizmo ModifyObject=axes0,property={8,ticks,3}
	ModifyGizmo ModifyObject=axes0,property={2,ticks,3}
	ModifyGizmo modifyObject=axes0 property={Clipped,0}
	ModifyGizmo setDisplayList=0, object=GPISurfaceData
	ModifyGizmo setDisplayList=1, object=axes0
	ModifyGizmo SETQUATERNION={0.554881,0.238598,0.253314,0.755651}
	ModifyGizmo autoscaling=1
	ModifyGizmo currentGroupObject=""
	ModifyGizmo compile

	//ModifyGizmo showInfo
	//ModifyGizmo infoWindow={475,322,828,507}
	ModifyGizmo bringToFront
	ModifyGizmo userString={wmgizmo_df,"Irena_Gizmo_Plot"}
	ModifyGizmo endRecMacro

	
End



//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_ManageStyles()

	IR1P_InitExportStyles()
	
	KillWIndow/Z IR1P_StylesManagementPanel
	Execute ("IR1P_StylesManagementPanel()")

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Window IR1P_StylesManagementPanel() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(63,50,380,470) as "IR1P_StylesManagementPanel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 1,textrgb= (0,0,65280)
	DrawText 83,23,"Manage styles"
	SetDrawEnv fsize= 14, textrgb= (65280,0,0)
	DrawText 53,44,"Use shift to select multiple set"
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,0)
	DrawText 8,65,"Styles within Igor"
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,0)
	DrawText 170,65,"Styles outside Igor"

	ListBox ListOfInternalStyles pos={10,80}, editStyle= 0, listWave= root:Packages:GeneralplottingTool:WaveOfStylesInIgor, mode=4
	ListBox ListOfInternalStyles size = {130,160}, selwave = root:Packages:GeneralplottingTool:NumbersOfStylesInIgor

	ListBox ListOfExternalStyles pos={170,80}, editStyle= 0, listWave= root:Packages:GeneralplottingTool:WaveOfStylesOutsideIgor, mode=4
	ListBox ListOfExternalStyles size = {130,160}, selwave = root:Packages:GeneralplottingTool:NumbersOfStylesOutsideIgor

	Button DeleteInternalStyle pos={20,260}, size={75,20}, proc=IRP_ButtonProcStyles,title="Delete", help={"Delete internal styles"}
	Button DeleteExternalStyle pos={200,260}, size={75,20}, proc=IRP_ButtonProcStyles,title="Delete", help={"Delete external styles"}

	Button RenameInternalStyle pos={5,290}, size={125,20}, proc=IRP_ButtonProcStyles,title="Rename/Duplicate", help={"Rename ONE internal style"}
	Button RenameExternalStyle pos={180,290}, size={125,20}, proc=IRP_ButtonProcStyles,title="Rename/Duplicate", help={"Rename ONE external style"}

	Button CopyOutOfIgor pos={110,320}, size={95,20}, proc=IRP_ButtonProcStyles,title="  ---  Copy   --->>>", help={"Copy style from Igor experiment out"}
	Button CopyIntoIgor pos={110,350}, size={95,20}, proc=IRP_ButtonProcStyles,title="  <<<---  Copy   ---   ", help={"Copy style into Igor experiment out"}

EndMacro
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IRP_ButtonProcStyles(ctrlName) : ButtonControl
	String ctrlName
	
	if(cmpstr(ctrlName,"DeleteInternalStyle")==0)
		IR1P_DeleteInternalStyle()
	endif
	if(cmpstr(ctrlName,"DeleteExternalStyle")==0)
		IR1P_DeleteExternalStyle()
	endif
	if(cmpstr(ctrlName,"RenameInternalStyle")==0)
		IR1P_RenameDuplicateIntStyle()
	endif
	if(cmpstr(ctrlName,"RenameExternalStyle")==0)
		IR1P_RenameDuplicateExtStyle()
	endif
	if(cmpstr(ctrlName,"CopyOutOfIgor")==0)
		IR1P_CopyStyleOut()
	endif
	if(cmpstr(ctrlName,"CopyIntoIgor")==0)
		IR1P_CopyStyleIn()
	endif
	
	IR1P_InitExportStyles()		//this refreshes the listBoxes...
	
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_CopyStyleOut()
	
	setDataFolder root:Packages:GeneralplottingTool
	Wave/T WaveOfStylesInIgor
	Wave NumbersOfStylesinIgor
	variable i
	string ExportName, Overwrite, testName, NbkNm
	NbkNm = "TestNbk"
	For(i=0;i<numpnts(NumbersOfStylesinIgor);i+=1)
		SVAR InStyle=$("root:Packages:plottingToolsStyles:"+PossiblyQuoteName(WaveOfStylesInIgor[i]))
		ExportName=WaveOfStylesInIgor[i]+".dat"
		if (NumbersOfStylesInIgor[i])
			//check that notebook does not exist
			close/A
			OpenNotebook /Z/P=plottingToolStyles /V=0 /N=TestNbk ExportName
			if (V_Flag==0)	//notebook opened, therefore it exists
				Prompt Overwrite, "The style exists, do you want to ovewrite it?", popup, "Yes;No"
				DoPrompt "Overwrite the existing style", Overwrite
				if (V_Flag)
					abort
				endif
				if (cmpstr(Overwrite,"Yes")==0)
					DoWindow /D/K testNbk
				else
					DoWindow /K testNbk
					ExportName = ExportName[0,strlen(ExportName)-5]
					Prompt ExportName, "Change name of style being exported"
					DoPrompt "Change name for exported style", ExportName
					if (V_Flag)
						abort
					endif
					ExportName=ExportName+".dat"
				endif
			endif
			NewNotebook /F=0 /V=0/N=$NbkNm 
			Notebook $NbkNm selection={endOfFile, endOfFile}
			Notebook $NbkNm text=InStyle
			SaveNotebook /S=3/O/P=plottingToolStyles $NbkNm as ExportName
			DoWindow /K testNbk
		endif
	endfor
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_CopyStyleIn()
	setDataFolder root:Packages:GeneralplottingTool
	Wave/T WaveOfStylesOutsideIgor
	Wave NumbersOfStylesOutsideIgor
	variable i, IsUnique
	string testNm, InternalNewStyle, Overwrite
	For(i=0;i<numpnts(NumbersOfStylesOutsideIgor);i+=1)
		testNm=WaveOfStylesOutsideIgor[i]+".dat"
		if (NumbersOfStylesOutsideIgor[i])
			//OpenNotebook /P=plottingToolStyles /V=0 /N=testNbk testNm
			LoadWave/J/Q/P=plottingToolStyles/K=2/N=ImportData/V={"\t"," $",0,1} testNm
			Wave/T LoadedData=root:Packages:GeneralplottingTool:ImportData0
			InternalNewStyle = WaveofStylesOutsideIgor[i]
			setDataFolder root:Packages:plottingToolsStyles
			InternalNewStyle = CleanupName(InternalNewStyle,0)
			IsUnique=CheckName(InternalNewStyle,4)
			setDataFolder root:Packages:GeneralplottingTool
			if (IsUnique!=0)
				Prompt Overwrite, "This style exists, overwrite?", popup, "Yes;No"
				DoPrompt "User select overwrite", Overwrite
				if(V_Flag)
					abort
				endif 
				if (cmpstr(Overwrite,"No")==0)
					Prompt InternalNewStyle, "Select new name for this style"
					DoPrompt "User change name of existing style", InternalNewStyle
					if(V_Flag)
						abort
					endif
					InternalNewStyle=CleanupName(InternalNewStyle,1)
				endif
			endif	
			string/g $("root:Packages:plottingToolsStyles:"+InternalNewStyle)
			SVAR NewStyle=$("root:Packages:plottingToolsStyles:"+InternalNewStyle)
			NewStyle = LoadedData[0]
			KillWaves/Z LoadedData
		endif
	endfor
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_DeleteInternalStyle()
	
	setDataFolder root:Packages:GeneralplottingTool
	Wave/T WaveOfStylesInIgor
	Wave NumbersOfStylesinIgor
	variable i
	For(i=0;i<numpnts(NumbersOfStylesinIgor);i+=1)
		SVAR test=$("root:Packages:plottingToolsStyles:"+PossiblyQuoteName(WaveOfStylesInIgor[i]))
		if (NumbersOfStylesinIgor[i])
			killstrings test
		endif
	endfor
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_DeleteExternalStyle()
	setDataFolder root:Packages:GeneralplottingTool
	Wave/T WaveOfStylesOutsideIgor
	Wave NumbersOfStylesOutsideIgor
	variable i
	string testNm
	For(i=0;i<numpnts(NumbersOfStylesOutsideIgor);i+=1)
		testNm=WaveOfStylesOutsideIgor[i]+".dat"
		if (NumbersOfStylesOutsideIgor[i])
			OpenNotebook /P=plottingToolStyles /V=0 /N=testNbk testNm
			DoWindow /D/K testNbk
		endif
	endfor
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_RenameDuplicateExtStyle()
	
	setDataFolder root:Packages:GeneralplottingTool
	Wave/T WaveOfStylesOutsideIgor
	Wave NumbersOfStylesOutsideIgor
	variable i
	string renameStr="rename"
	string NewName, testNm, newNameWIthExt
	string NbkNm="testNbk"
	For(i=0;i<numpnts(NumbersOfStylesOutsideIgor);i+=1)
		testNm=WaveOfStylesOutsideIgor[i]+".dat"
		if (NumbersOfStylesOutsideIgor[i])
			Prompt NewName, "Input new name for style "+WaveOfStylesOutsideIgor[i]
			Prompt RenameStr, "Rename or duplicate?", popup, "Rename;duplicate"
			NewName=WaveOfStylesOutsideIgor[i]
			DoPrompt "Input New Name", NewName, RenameStr
			if (V_Flag)
				abort
			endif
			OpenNotebook /P=plottingToolStyles /V=0 /N=$NbkNm testNm
			newNameWIthExt = NewName+".dat"
			if (cmpstr(NewNameWithExt,testNm)==0)
				abort
			endif
			SaveNotebook /S=3/O/P=plottingToolStyles $NbkNm as newNameWIthExt
			if (cmpstr(RenameStr,"Rename")==0)
				DoWindow /D/K testNbk
			else
				DoWindow /K testNbk
			endif
		endif
	endfor
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_RenameDuplicateIntStyle()
	
	setDataFolder root:Packages:GeneralplottingTool
	Wave/T WaveOfStylesInIgor
	Wave NumbersOfStylesinIgor
	variable i
	string renameStr="rename"
	string NewName
	For(i=0;i<numpnts(NumbersOfStylesinIgor);i+=1)
		SVAR test=$("root:Packages:plottingToolsStyles:"+PossiblyQuoteName(WaveOfStylesInIgor[i]))
		if (NumbersOfStylesinIgor[i])
			Prompt NewName, "Input new name for style "+WaveOfStylesInIgor[i]
			Prompt RenameStr, "Rename or duplicate?", popup, "Rename;duplicate"
			NewName=WaveOfStylesInIgor[i]
			DoPrompt "Input New Name", NewName, RenameStr
			if (V_Flag)
				abort
			endif
			NewName=PossiblyQuoteName(NewName)
			string FullNewName
			FullNewName = "root:Packages:plottingToolsStyles:"+NewName
			string/g $FullNewName
			SVAR NewStyleString=$FullNewName
			NewStyleString = test
			if (cmpstr(RenameStr,"Rename")==0)
				killstrings test
			endif
		endif
	endfor
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_InitExportStyles()

	//create if does not exist the internal place for styles
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:GeneralplottingTool
	NewDataFolder/O root:Packages:plottingToolsStyles
	//now list what is there in appropriate waves
	string ListOfStyles=IN2G_CreateListOfItemsInFolder("root:Packages:plottingToolsStyles", 8)
	Make/O/T/N=(ItemsInList(ListOfStyles)) WaveOfStylesInIgor
	Make/O/N=(ItemsInList(ListOfStyles)) NumbersOfStylesinIgor
	variable i
	For(i=0;i<ItemsInList(ListOfStyles);i+=1)
		WaveOfStylesInIgor[i]=StringFromList(i, ListOfStyles)
	endfor

	sort WaveOfStylesInIgor, WaveOfStylesInIgor
	//above handles files within Igor	
	//Now outside - first new location as of 7/14/2013 in Users area. 
	string IgorPathStr=SpecialDirPath("Igor Pro User Files", 0, 0, 0 )
	string/g StylePath=IgorPathStr+"User Procedures:Irena_Saved_styles"
	NewPath/C/O/Q plottingToolStyles, StylePath
	//now, if located in old place, we need to move the styles...
	PathInfo Igor
	string oldIgorPathStr = S_Path	
	string tempFileName, tmpNbkName
	tmpNbkName="tmpNbk123"
	NewPath/O/Q/Z OldPlottingToolStyles, oldIgorPathStr+"User Procedures:Irena_Saved_styles"
	if(V_Flag==0)	//path exists... 
		string ListOfOldExternalStyles=IndexedFile(OldPlottingToolStyles,-1,".dat")
		For(i=0;i<ItemsInList(ListOfOldExternalStyles);i+=1)
			tempFileName = StringFromList(0,StringFromList(i, ListOfOldExternalStyles),".")+".dat"
			OpenNotebook /P=OldPlottingToolStyles /V=0 /N=tmpNbkName tempFileName
			//check if such stype exists and handle name change..
			OpenNotebook /Z/P=plottingToolStyles /V=0 /N=TestNbk tempFileName
			if (V_Flag==0)	//notebook opened, therefore it exists
				tempFileName=tempFileName+"_moved"
			endif
			//OK, now the name should be unique, unless use has perverse naming system
			SaveNotebook /S=3/O/P=plottingToolStyles tmpNbkName as tempFileName
			DoWindow /D/K tmpNbkName
		endfor	
	endif
	KillPath /Z OldPlottingToolStyles
	//by now, if there were styles in the old location, they have been moved to new location. 
	string ListOfExternalStyles=IndexedFile(plottingToolStyles,-1,".dat")

	Make/O/T/N=(ItemsInList(ListOfExternalStyles)) WaveOfStylesOutsideIgor
	Make/O/N=(ItemsInList(ListOfExternalStyles)) NumbersOfStylesOutsideIgor
	For(i=0;i<ItemsInList(ListOfExternalStyles);i+=1)
		WaveOfStylesOutsideIgor[i]=StringFromList(0,StringFromList(i, ListOfExternalStyles),".")
	endfor
	sort WaveOfStylesOutsideIgor, WaveOfStylesOutsideIgor
end


//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
