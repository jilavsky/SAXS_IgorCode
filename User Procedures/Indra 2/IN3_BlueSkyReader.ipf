#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=1.03

	//this is available ONLY, if JSONXOP is installed and json_functions.ipf is in User Procedures. 
#if(exists("JSONXOP_GetValue")==4)

//#include "json_functions"
static Constant JSON_ZFLAG_DEFAULT = 0 
static Constant JSON_QFLAG_DEFAULT = 1
static Constant JSON_INVALID   = -1
static Constant JSON_OBJECT    = 0
static Constant JSON_ARRAY     = 1
static Constant JSON_NUMERIC   = 2
static Constant JSON_STRING    = 3
static Constant JSON_BOOL      = 4
static Constant JSON_NULL      = 5


	// Add to menu if available. 
Menu "USAXS"
	"Bluesky Plots", IR3BS_BlueSkyPlot()
end
//1.03 Optimization & fixes January 2024, making it compatible to other catalogs also? 
//1.02 December 2023, Tiled ??? compatible, major source changes. 
//1.01 November 2022, Tiled 0.1.0a80 compatible, changed webGUI 
//1.00 original version, kind of works

//server address. 
//strconstant ServerAddress="http://wow.xray.aps.anl.gov:8010"
//strconstant ServerAddress="http://usaxscontrol:8020"
strconstant ServerAddress="http://usaxscontrol.xray.aps.anl.gov:8020"
//strconstant ServerAddress="https://tiled-demo.blueskyproject.io"
strconstant DefaultUSAXScatalog="idb_usaxs_retired_2023-12-05"		//set to name of default catalog, likely "usaxs" when in operations


//how to install tiled: https://github.com/BCDA-APS/tiled-template/blob/main/docs/create.md
//Igor JSON xop:  	https://www.wavemetrics.com/node/20976
//					https://docs.byte-physics.de/json-xop/getting_started.html#operations-and-functions
//Comments: 
//   https://github.com/jilavsky/SAXS_IgorCode/wiki/Reading-data-from-Tiled-server#traversing-to-catalog 
//1-9-2024 this is desription on how tiled addresses data and metadata:
	//The URLs are structured like 
	///api/v1/VERB/NOUN
	//
	//where VERB is something like /search, /metadata/, /array/full. 
	//
	//	The trouble with NOUN is, that it is Catalog/Application dependent and can look mor eor less as anyone dreams up. 
	//NOUN is fully up to the application, it would be 
	///{uuid} or 
	///{beamline}/{uuid} or 
	///raw/{beamline}/{uuid} or 
	///whatever/you/want.

//	This means, that to figure this all out, we need to traverse the catalogs and figure out the path... 

//	VERB = endpoint :
//	The first path segment after /api/v1 tells us which "endpoint" in Tiled we are reaching. 
//	The /search endpoint, previously called /node/search in older versions of Tiled, has never returned numerical data. 
//	It describes the contents of its "children"---optionally filtered and sorted---broken into "pages" if the number of children is large.
//
//	If you want to download the data itself as JSON, and not just the description+links we can from /search replace /search with /node/full
//
//	As you say, we don't want to download too much data needlessly. We can explicitly choose which fields in this JSON payload to download using the field query parameter.
//		https://tiled-demo.blueskyproject.io/api/v1/node/full/bmm/raw/f8c83910-4adb-4207-a465-9ff0ff0e9cd2/primary/data?format=json&field=dcm_energy&field=I0
//old stuff, may be wrong! : 
//This returns table of all parameters   http://usaxscontrol:8020/node/full/9idc_usaxs/08ba0941-1adb-499b-83e5-53a285a35abd/baseline/data
// 3/2/22 11:04 AM Presentation on Tiled. Daniel Alan, BNL
//						https://blueskyproject.io/tiled
// Video: https://confluence.slac.stanford.edu/display/RAWG/DOE+BES+5+Light+Source+%285LS%29+Remote+Access+Working+Group
// 	Here is good reference for queries;
//					https://github.com/BCDA-APS/bdp-tiled/blob/main/demo_client.ipynb
// See tilted hints document. 
//  http://usaxscontrol:8020/node/full/9idc_usaxs/16248ab5-1359-4242-8ec9-6fd66f8b5976/primary/data?format=json this gets out primary scan as json. 
// http://usaxscontrol:8020/node/search/?filter[lookup][condition][key]=9idc_usaxs&sort=
// documentation and testing http://usaxscontrol:8020/docs
// retruns json where 
// need to add this : "&filter[time_range][condition][timezone]=US/Central" into the querries to it works... 

//this is very useful list of examples how querries are built:
//https://github.com/BCDA-APS/bdp-tiled/blob/main/demo_client.ipynb
//there are querries which allow finding specific text (sample name?) 


// here is discussion/support group https://mattermost.hzdr.de/bluesky/channels/tiled

// Here is http solution to reduce amount of data getting back, which may eventually change
// 		https://github.com/bluesky/tiled/issues/99
//		https://jmespath.org
//	this is example how to downscale what is returned...  'https://tiled-demo.blueskyproject.io/entries/bmm?page[limit]=3&select_metadata=summary&fields=metadata'

///******************************************************************************************
///******************************************************************************************
///			BlueSky plotting tool, easy way to plot many data sets at once
///******************************************************************************************
///******************************************************************************************
Function IR3BS_BlueSkyPlot()

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IN2G_CheckScreenSize("width",1000)
	IN2G_CheckScreenSize("height",670)
	DoWIndow IR3BS_BlueSkyPlotPanel
	if(V_Flag)
		DoWindow/F IR3BS_BlueSkyPlotPanel
	else
		IR3BS_Init()
		IR3BS_BlueSkyPlotPanelFnct()
		//		setWIndow IR3BS_BlueSkyPlotPanel, hook(CursorMoved)=IR3D_PanelHookFunction
		//IR1_UpdatePanelVersionNumber("IR3BS_BlueSkyPlotPanel", IR3LversionNumber,1)
		//link it to top graph, if exists
		//IR3L_SetStartConditions()
	endif
	IR3BS_InitServer()
end
//**********************************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR3BS_InitServer()
	
	//get server info
	//1. check how many catalogs we have on this is bluesky server
	//string TempAddress = ServerAddress+"/api/v1/node/search/?fields=&sort="
	string TempAddress = ServerAddress+"/api/v1/search/?fields=&sort="
	variable jsonid, i
	string TempJSONAdd, tempStr
	string AllCatalogs=""
	SVAR ListOfCatalogs=root:Packages:Irena:BlueSkySamplePlot:ListOfCatalogs
	SVAR CatalogUsed=root:Packages:Irena:BlueSkySamplePlot:CatalogUsed
	
	ListOfCatalogs=""
	URLRequest/Z url=TempAddress
	if(V_Flag!=0)
		abort "Server not available"
	endif
	JSONXOP_Parse/Z(S_serverResponse)
	if(V_Flag!=0)
		abort "Cannot parse server response"
	endif
	jsonId = V_Value
	//print jsonID
	//JSONXOP_Dump jsonID
	//print S_Value	//	-- prints the file in history and works. 
	TempJSONAdd =  "/meta/count"
	variable NumCatalogs =  JSON_GetVariable(jsonID,TempJSONAdd)
	For(i=0;i<NumCatalogs;i+=1)
		TempJSONAdd =  "/data/"+num2str(i)+"/id"	
		AllCatalogs+=JSON_GetString(jsonID, TempJSONAdd)+";"
	endfor
	JSONXOP_Release jsonId
	//overwrite, fails on old catalog:
	//ListOfCatalogs=stringfromList(0,AllCatalogs)
	ListOfCatalogs=AllCatalogs
	//By now we know how many catalogs we have, but not enough to find data in generic catalog.  
	//set to USAXS default catalog, if we are looking for it. 	
	CatalogUsed = stringfromList(0,grepList(AllCatalogs,DefaultUSAXScatalog)) 
	if(strlen(CatalogUsed)<2)
		CatalogUsed = "---"
	endif
	//update panel, if exists
	DoWIndow IR3BS_BlueSkyPlotPanel
	if(V_flag)
		SVAR ListOfCatalogs=root:Packages:Irena:BlueSkySamplePlot:ListOfCatalogs
		SVAR CatalogUsed=root:Packages:Irena:BlueSkySamplePlot:CatalogUsed
		SVAR ScanTypeToUse = root:Packages:Irena:BlueSkySamplePlot:ScanTypeToUse
		PopupMenu CatalogUsed,value=#"root:Packages:Irena:BlueSkySamplePlot:ListOfCatalogs",mode=1, popvalue=CatalogUsed
		IR3BS_GetJSONScanData()
		PopupMenu ScanTypeToUse,value=#"root:Packages:Irena:BlueSkySamplePlot:ListOfScanTypes",mode=1, popvalue=ScanTypeToUse
	endif
end

//**********************************************************************************************************
//**********************************************************************************************************
FUnction IR3BS_Init()

	DfRef OldDf=GetDataFolderDFR()
	string ListOfVariables
	string ListOfStrings
	variable i
		
	if (!DataFolderExists("root:Packages:Irena:BlueSkySamplePlot"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:BlueSkySamplePlot
	endif
	SetDataFolder root:Packages:Irena:BlueSkySamplePlot					//go into the folder

	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="ListOfCatalogs;CatalogUsed;ListOfScanTypes;ScanTypeToUse;"
	ListOfStrings+="DetectorStr;XaxisStr;"
	ListOfStrings+="Prefix;"

	ListOfVariables="StartYear;StartMoth;StartDay;NumOfHours;AllDates;NumberOfScansToImport;"

	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	ListOfStrings="ListOfCatalogs;CatalogUsed;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		teststr =""
	endfor		
	NVAR StartYear
	StartYear = str2num(StringFromList(0, Secs2Date(DateTime,-2),"-"))
	NVAR StartMoth
	StartMoth = str2num(StringFromList(1, Secs2Date(DateTime,-2),"-"))
	NVAR StartDay
	StartDay =str2num(StringFromList(2, Secs2Date(DateTime,-2),"-"))
	NVAR NumOfHours
	NumOfHours=24
	NVAR NumberOfScansToImport
	if(NumberOfScansToImport<10)
		NumberOfScansToImport=10000
	endif
	SVAR ListOfScanTypes
	ListOfScanTypes = "tune_ar;tune_a2rp;tune_mr;tune_dx;tune_dy;all;"

	Make/O/T/N=(0,3) ListOfAvailableData, PrunedListOfAvailableData
	Make/O/N=(0) SelectionOfAvailableData 
	SetDataFolder oldDf

end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR3BS_BlueSkyPlotPanelFnct()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(5.25,43.25,605,820) as "BlueSky plotting tool"
	DoWIndow/C IR3BS_BlueSkyPlotPanel
	TitleBox MainTitle title="\Zr220BlueSky Data plotting tool",pos={140,1},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fColor=(0,0,52224)

	Button GetHelp,pos={480,10},size={80,15},fColor=(65535,32768,32768), proc=IR3L_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}

	SVAR ListOfCatalogs=root:Packages:Irena:BlueSkySamplePlot:ListOfCatalogs
	SVAR CatalogUsed=root:Packages:Irena:BlueSkySamplePlot:CatalogUsed
	CatalogUsed = stringFromList(0,ListOfCatalogs)
	PopupMenu CatalogUsed,pos={20,40},size={310,20},proc=IR3BS_PopMenuProc, title="Select Catalog",help={"Select one of available catalogs"}
	PopupMenu CatalogUsed,value=#"root:Packages:Irena:BlueSkySamplePlot:ListOfCatalogs",mode=1, popvalue=CatalogUsed

	
	SetVariable NumberOfScansToImport,pos={330,40},size={160,20}, proc=IR3BS_SetVarProc,title="Num of scans:", valueColor=(0,0,0),  limits={10,1000,50}
	Setvariable NumberOfScansToImport,fStyle=0, variable=root:Packages:Irena:BlueSkySamplePlot:NumberOfScansToImport, disable=0, frame=1, help={"This is Igor internal name for graph currently selected for controls"}
	
	//ListOfVariables="StartMoth;StartDay;NumOfHours;"
	SetVariable StartYear,pos={20,70},size={100,20}, proc=IR3BS_SetVarProc,title="\Zr120Year:", valueColor=(0,0,0)
	Setvariable StartYear,fStyle=0, variable=root:Packages:Irena:BlueSkySamplePlot:StartYear, disable=0, frame=1, help={"This is Igor internal name for graph currently selected for controls"}
	SetVariable StartMoth,pos={140,70},size={100,20}, proc=IR3BS_SetVarProc,title="\Zr120Month:", valueColor=(0,0,0)
	Setvariable StartMoth,fStyle=0, variable=root:Packages:Irena:BlueSkySamplePlot:StartMoth, disable=0, frame=1, help={"This is Igor internal name for graph currently selected for controls"}
	SetVariable StartDay,pos={260,70},size={100,20}, proc=IR3BS_SetVarProc,title="\Zr120Day:", valueColor=(0,0,0)
	Setvariable StartDay,fStyle=0, variable=root:Packages:Irena:BlueSkySamplePlot:StartDay, disable=0, frame=1, help={"This is Igor internal name for graph currently selected for controls"}
	SetVariable NumOfHours,pos={370,70},size={100,20}, proc=IR3BS_SetVarProc,title="\Zr120Hours:", valueColor=(0,0,0)
	Setvariable NumOfHours,fStyle=0, variable=root:Packages:Irena:BlueSkySamplePlot:NumOfHours, disable=0, frame=1, help={"This is Igor internal name for graph currently selected for controls"}

	Checkbox AllDates, variable=root:Packages:Irena:BlueSkySamplePlot:AllDates
	CheckBox AllDates title="All dates? ",pos={488,68},size={60,14},proc=IR3S_CheckProc

	SVAR ListOfScanTypes=root:Packages:Irena:BlueSkySamplePlot:ListOfScanTypes
	SVAR ScanTypeToUse=root:Packages:Irena:BlueSkySamplePlot:ScanTypeToUse
	PopupMenu ScanTypeToUse,pos={20,100},size={310,20},proc=IR3BS_PopMenuProc, title="Select Scan type",help={"Select one of available scan types"}
	PopupMenu ScanTypeToUse,value=#"root:Packages:Irena:BlueSkySamplePlot:ListOfScanTypes",mode=1, popvalue=ScanTypeToUse

	Button Update,pos={300,100},size={150,20}, proc=IR3BS_ButtonProc,title="Update", help={"Plot selected data in new graph"}

	ListBox BlueSkyList,pos={8,185},size={573,395} //, special={0,0,1 }		//this will scale the width of column, users may need to slide right using slider at the bottom. 
	ListBox BlueSkyList,listWave=root:Packages:Irena:BlueSkySamplePlot:PrunedListOfAvailableData
	ListBox BlueSkyList,selWave=root:Packages:Irena:BlueSkySamplePlot:SelectionOfAvailableData
	ListBox BlueSkyList,proc=IN3BS_ListBoxMenuProc, selRow= 0, editStyle= 0
	ListBox BlueSkyList widths={20,30,30}
	ListBox BlueSkyList userColumnResize=1,help={"Fill here list of samples, their positions, thickness etc. "}
	//ListBox BlueSkyList titleWave=root:Packages:SamplePlateSetup:LBTtitleWv, frame= 2
	//ListBox BlueSkyList widths={220,50,50,60,40,40,40,0}
	ListBox BlueSkyList  mode=9 		// mode=1 for single row selection, 4 multiple disjoint rows (shift only), mode=9 for shift conigous+ctrl disjoint.  

	//	//Plotting controls...
	//	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={260,170},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)

	Button importSelected,pos={20,600},size={120,20}, proc=IR3BS_ButtonProc,title="Import Selected", help={"Import selected rows for further processing"}
	Button importPlotSelected,pos={20,640},size={120,20}, proc=IR3BS_ButtonProc,title="Import & Plot Selected", help={"Import selected rows and plot"}

	Button SelectAll,pos={420,600},size={120,20}, proc=IR3BS_ButtonProc,title="Select all ", help={"Select all "}
	Button DeSelectAll,pos={420,640},size={120,20}, proc=IR3BS_ButtonProc,title="DeSelect all ", help={"Select all "}

end

//**************************************************************************************
//**************************************************************************************
//************************************************************************************************************
Function IN3BS_ListBoxMenuProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	Variable row = lba.row
	Variable col = lba.col
	WAVE/T/Z listWave = lba.listWave
	WAVE/Z selWave = lba.selWave
	string WinNameStr=lba.win
	string items
	variable i

	switch( lba.eventCode )
		case -1: // control being killed
			break
		case 1: // mouse down
  			//ListOfSelRows=IN3S_CreateListOfRows(selWave)
  			//firstSelectedRow = str2num(StringFromList(ItemsInList(ListOfSelRows)-1, ListOfSelRows))
  			//NoSelectedRows = ItemsInList(ListOfSelRows)
 
			if (lba.eventMod & 0x10)	// rightclick

			else	//left click, do something here... 

			endif
			break
		case 3: // double click
			//download the data
			IN3BS_ImportDataAndPlot(row,0, 0)
			break
		case 4: // cell selection

			break
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
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR3BS_ImportSelected(PlotAll)
	variable PlotAll

	Wave listWave=root:Packages:Irena:BlueSkySamplePlot:PrunedListOfAvailableData
	Wave selWave=root:Packages:Irena:BlueSkySamplePlot:SelectionOfAvailableData
	variable i
	For(i=0;i<dimsize(listWave,0);i+=1)
		if(selWave[i]>0)
			IN3BS_ImportDataAndPlot(i,1, PlotAll)
		endif
	endfor  
	if(PlotAll)
		IN2G_ColorTopGrphRainbow()
		IN2G_LegendTopGrphFldr(12, 20, 1, 0)
	endif
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IN3BS_ImportDataAndPlot(selRow, saveTheData, PlotAll)
	variable selRow, saveTheData, PlotAll
	
	string oldDf
	oldDf = getDataFolder(1)
	//Wave/T IDwave = root:Packages:Irena:BlueSkySamplePlot:IDwave
	Wave/T PrunedListOfAvailableData =  root:Packages:Irena:BlueSkySamplePlot:PrunedListOfAvailableData
	SVAR CatalogUsed=root:Packages:Irena:BlueSkySamplePlot:CatalogUsed		// this is name of catalog
	SVAR Prefix = root:Packages:Irena:BlueSkySamplePlot:Prefix				// use this instead of catalog used
	
	//string TempAddress = ServerAddress+"/api/v1/search/"+CatalogUsed+"/"
	string TempAddress = ServerAddress+"/api/v1/node/full/"+Prefix+"/"
				//this provides ONLY data and is very small... 
	//something to note. These return different parts of the data... Smaller or larger tree  
	TempAddress +=PrunedListOfAvailableData[selRow][3]+"/primary/data?format=json"		//	this results in 267 lines with /search and ONLY data with /node/full <<<< 
	//TempAddress +=PrunedListOfAvailableData[selRow][3]+"/primary?format=json"			// 	this results in 1300 lines with /search 
	//TempAddress +=PrunedListOfAvailableData[selRow][3]+"?format=json"					//	this results in giant json with 7.6k lines with /search 
	// 	selection above makes difference for data adresses.  
	//Identify the data and get the url for the arrays...
	URLRequest/Z url=TempAddress
	if(V_Flag!=0)
		abort "Server not available"
	endif
	JSONXOP_Parse/Z(S_serverResponse)
	if(V_Flag!=0)
		print S_serverResponse
		abort "Cannot parse server response"
	endif
	variable jsonId = V_Value
	//if we need to check who the json looks like, this will dumpt the json to history as formatted string
	//JSONXOP_Dump jsonId
	//JSONXOP_Dump /IND=3 jsonID 	//this adds indents so one can read the damned thing. 
	//print S_Value		//-- prints the file in history and works. 
	//JSONXOP_Release jsonId
	//abort

	//these were populated in IR3BS_GetJSONScanData() and should contain names of x and y axes. 

	wave/T Keys = JSON_GetKeys(jsonID, "")	//if we use /node/full, we get back only the data, no metadata... 
	if(numpnts(Keys)<2)
		JSONXOP_Release jsonId
		abort "Cannot parse response, server not returning meanigful data yet"
	endif	
	//print keys		gives   '_free_'[0]= {"PD_USAXS","a_stage_r","a_stage_r_user_setpoint","scaler0_time"}
	SVAR XaxisStr = root:Packages:Irena:BlueSkySamplePlot:XaxisStr
	SVAR DetectorStr = root:Packages:Irena:BlueSkySamplePlot:DetectorStr
	XaxisStr = Keys[1]
	DetectorStr = Keys[0]
	
	//wave maxSize=JSON_GetMaxArraySize(jsonID, "/"+DetKey)
	//data can these addressed like before with names ("id" or via numbers "0=time, 1=PD_USAXS, 3=a_stage_r
	//store data here and do something with them.
	wave DetFree = JSON_GetWave(jsonID, DetectorStr, ignoreErr=1)
	wave XdatFree = JSON_GetWave(jsonID, XaxisStr, ignoreErr=1)
	
	JSONXOP_Release jsonId
	
	//	if using /search then TempAddress we get only metadata, but not data, in that case we can do following:  
	// probe in metadata what is available and where, tehn load separately only data. 
	// requires multipke reqiests and is therefore much shorter. 
	// check the OneNote programming notes in Tiled, it is bit complciated.  
			//	variable  numDataBlocks = JSON_GetVariable(jsonID, "/meta/count")
			//	variable i
			//	string ListOfDataStreams=""
			//	For(i=0;i<numDataBlocks;i+=1)
			//		ListOfDataStreams+=JSON_GetString(jsonID, "/data/"+num2str(i)+"/id")+";"
			//		//print num2str(i)+"   =   "+JSON_GetString(jsonID, "/data/"+num2str(i)+"/id")
			//	endfor 
			//print ListOfDataStreams
			//next idenitfy which data stream number is which array we want and read using the full url:
			// get string from /data/X/links/full and append ?format=json to get json
			// now we get more or less clear ASCII table with values from 0 to points-1 and we need to read those using getWave. 
	
			//this works with use of string TempAddress = ServerAddress+"/api/v1/search/"+CatalogUsed+"/" which means, the json does nto contain the data. 
				//	variable tempIndex
				//	//get index for detectors we want 
				//	tempIndex = WhichListItem(DetectorStr, ListOfDataStreams)
				//	string AddressOfDetector = JSON_GetString(jsonID,"/data/"+num2str(tempIndex)+"/links/full")+"?format=json"
				//	tempIndex = WhichListItem(XaxisStr, ListOfDataStreams)
				//	string AddressOfXdata = JSON_GetString(jsonID,"/data/"+num2str(tempIndex)+"/links/full")+"?format=json"
				//	JSONXOP_Release jsonId
				//	//now get the data
				//	URLRequest/Z url=AddressOfDetector
				//	if(V_Flag!=0)
				//		abort "Server not available"
				//	endif
				//	JSONXOP_Parse/Z(S_serverResponse)
				//	if(V_Flag!=0)
				//		print S_serverResponse
				//		abort "Cannot parse server response"
				//	endif
				//	jsonId = V_Value
				//	wave DetFree = JSON_GetWave(jsonID, "", ignoreErr=1)
				//	JSONXOP_Release jsonId
				//
				//	URLRequest/Z url=AddressOfXdata
				//	if(V_Flag!=0)
				//		abort "Server not available"
				//	endif
				//	JSONXOP_Parse/Z(S_serverResponse)
				//	if(V_Flag!=0)
				//		print S_serverResponse
				//		abort "Cannot parse server response"
				//	endif
				//	jsonId = V_Value
				//	wave XdatFree = JSON_GetWave(jsonID, "", ignoreErr=1)
				//	JSONXOP_Release jsonId

	string tempScanName, DateTimeStr
	PauseUpdate
	if(saveTheData)	//store the data
		//create location for the data... 
		tempScanName=PrunedListOfAvailableData[selRow][0]
		DateTimeStr =PrunedListOfAvailableData[selRow][1]
		NewDataFolder/O/S root:ScanData
		NewDataFolder/O/S $(CleanupName(tempScanName+"_"+DateTimeStr, 0))
		Duplicate/O DetFree, Detector
		Duplicate/O XdatFree, Xdata
		if(PlotAll)
			DoWIndow BlueSkyGraph
			if(V_Flag)
				DoWIndow/F BlueSkyGraph
			else
				Display/K=1 as "Imported BlueSky data"
				DoWindow/C BlueSkyGraph
			endif
			AppendtoGraph Detector vs Xdata
			Label bottom XaxisStr
			Label left DetectorStr
			AutoPositionWindow/R=IR3BS_BlueSkyPlotPanel  BlueSkyGraph
		endif
		setDataFolder oldDf
	else	//just display them without saving
		Duplicate/O DetFree,Detector
		Duplicate/O XdatFree,Xdata
		Killwindow/Z BlueSkyGraph
		
		//display, for now this is simplistic way
		Display/K=1  Detector vs Xdata as PrunedListOfAvailableData[selRow][1]+"     "+PrunedListOfAvailableData[selRow][0]
		Label bottom XaxisStr
		Label left DetectorStr
		DoWindow/C BlueSkyGraph
		AutoPositionWindow/R=IR3BS_BlueSkyPlotPanel  BlueSkyGraph
	endif
	ResumeUpdate 
	
	setDataFolder oldDf
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR3BS_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	variable tempP
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
			
			if(stringmatch(sva.ctrlName,"StartMoth"))
				//NVAR LineThickness = root:Packages:Irena:MultiSamplePlot:LineThickness
			endif
					
			break
		case 3: // live update
			break
		case -1: // control being killed
			break
	endswitch
	DoWIndow/F IR3BS_BlueSkyPlotPanel
	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************
//************************************************************************************************************

Function IR3BS_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	variable i
	string FoldernameStr
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlname,"Update"))
				IR3BS_GetJSONScanData()
			endif
			if(stringmatch(ba.ctrlname,"importSelected"))
				IR3BS_ImportSelected(0)
			endif
			if(stringmatch(ba.ctrlname,"importPlotSelected"))
				IR3BS_ImportSelected(1)
			endif
			if(stringmatch(ba.ctrlname,"SelectAll"))
				Wave selWave=root:Packages:Irena:BlueSkySamplePlot:SelectionOfAvailableData
				selWave = 1
			endif
			if(stringmatch(ba.ctrlname,"DeSelectAll"))
				Wave selWave=root:Packages:Irena:BlueSkySamplePlot:SelectionOfAvailableData
				selWave = 0
			endif

			break
		case -1: // control being killed
			break
	endswitch
	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************
//************************************************************************************************************
FUnction IR3BS_InitCatalog()

	//here we do following:
	//1. Aks for Catalog selected using querry similar to https://tiled-demo.blueskyproject.io/api/v1/metadata/bmm
	//2  Pick FULL URL from returned Json and call that
	//3. Pick from data 0 the search URL and get the part behind the search, which is the Prefix of the database.  
	// in this example, we find: https://tiled-demo.blueskyproject.io/api/v1/search/bmm/raw
	// and we pick Prefix = "/bmm/raw" which points to where to expect the data. 
	setDataFolder root:Packages:Irena:BlueSkySamplePlot
	SVAR Prefix = root:Packages:Irena:BlueSkySamplePlot:Prefix
	SVAR CatalogUsed=root:Packages:Irena:BlueSkySamplePlot:CatalogUsed
	if(StringMatch(CatalogUsed, "---" ))
		Wave w1= root:Packages:Irena:BlueSkySamplePlot:SelectionOfAvailableData
		Wave/T wt2= root:Packages:Irena:BlueSkySamplePlot:PrunedListOfAvailableData
		Wave/T wt1= root:Packages:Irena:BlueSkySamplePlot:ListOfAvailableData
		redimension/N=0 w1, wt1, wt2
		abort 
	endif
	string TempAddress = ServerAddress+"/api/v1/metadata/"+CatalogUsed
	
	//print TempAddress
	URLRequest/Z url=TempAddress
	if(V_Flag!=0)
		abort "Server not available"
	endif
	JSONXOP_Parse/Z(S_serverResponse)
	if(V_Flag!=0)
		abort "Cannot parse server response"
	endif
	variable jsonId = V_Value
	//debug commands: 
	//print jsonID
	//JSONXOP_Dump/IND=3 jsonId
	//print "*********************AAAAAA*******************************"
	//print strlen(S_Value)		//-- prints the file in history and works. 
	//print S_Value				//-- prints the file in history and works. 
	
	string	strLocation = "/data/links/search"				//for one WITH select_metadata
	string NextURL = JSON_GetString(jsonID, strLocation,ignoreErr=1) 
	TempAddress = NextURL
	JSONXOP_Release jsonId

	//print TempAddress
	URLRequest/Z url=TempAddress
	if(V_Flag!=0)
		abort "Server not available"
	endif
	JSONXOP_Parse/Z(S_serverResponse)
	if(V_Flag!=0)
		abort "Cannot parse server response"
	endif
	jsonId = V_Value
	//JSONXOP_Dump/IND=3 jsonId
	//print "*********************AAAAAA*******************************"
	//print strlen(S_Value)		//-- prints the file in history and works. 
	//print S_Value				//-- prints the file in history and works. 

	strLocation = "/data/0/links/search"				//for one WITH select_metadata
	string FullPath = JSON_GetString(jsonID, strLocation,ignoreErr=1) 
	JSONXOP_Release jsonId
	//print FullPath
	//now remove the search and anything before it and we have the new perfix. 
	variable startPlace = WhichListItem("search", FullPath , "/" )
	variable allParts = ItemsInList(FullPath ,"/")
	variable i
	string PrefixLoc=""
	string tempStr=""
	for(i=startPlace+1 ; i<(allParts); i+=1)
		tempStr=StringFromList(i, FullPath, "/")		//this is path, but it could be UUID in some cases, which we need to remove
		//print strlen(tempStr)
		if(strlen(tempStr)<36)	//UUIDs are 36 characters long, Catalog name shouydl be shorter!
			PrefixLoc = PrefixLoc+"/"+tempStr
		endif
	endfor
	//print PrefixLoc
	Prefix = PrefixLoc

End
//**********************************************************************************************************
//**********************************************************************************************************
//************************************************************************************************************
FUnction IR3BS_GetJSONScanData()

	setDataFolder root:Packages:Irena:BlueSkySamplePlot
	//procedure, https://docs.byte-physics.de/json-xop/getting_started.html
	//read json file in string
	//parse in json
	//talk to json.
	//would be : JSONXOP_Parse(FetchURL("https://jsonplaceholder.typicode.com/todos/1"))
	//variable refnumStrFile
	//Open /R /T="json" refnumStrFile  as "PRG2:Users:ilavsky:Desktop:jsonExample.json"
	//print S_fileName
	//variable jsonId
	//string jsonStr
	//jsonStr = PadString("", 283392, 0x20 )
	//FBinRead refnumStrFile, jsonStr
	//Close refnumStrFile
	NVAR StartMonth=root:Packages:Irena:BlueSkySamplePlot:StartMoth
	NVAR StartDay=root:Packages:Irena:BlueSkySamplePlot:StartDay
	NVAR NumOfHours=root:Packages:Irena:BlueSkySamplePlot:NumOfHours
	NVAR StartYear=root:Packages:Irena:BlueSkySamplePlot:StartYear

	NVAR AllDates=root:Packages:Irena:BlueSkySamplePlot:AllDates

	SVAR ListOfCatalogs=root:Packages:Irena:BlueSkySamplePlot:ListOfCatalogs
	SVAR CatalogUsed=root:Packages:Irena:BlueSkySamplePlot:CatalogUsed
	SVAR Prefix = root:Packages:Irena:BlueSkySamplePlot:Prefix				//thsi si ~ Catalog used, but has other path behind the name. Repalce Catalogused with this. 

	SVAR ScanTypeToUse = root:Packages:Irena:BlueSkySamplePlot:ScanTypeToUse
	SVAR DetectorStr = root:Packages:Irena:BlueSkySamplePlot:DetectorStr
	SVAR Xaxis = root:Packages:Irena:BlueSkySamplePlot:XaxisStr
	NVAR NumberOfScansToImport=root:Packages:Irena:BlueSkySamplePlot:NumberOfScansToImport

	//SERVER/node/search/CATALOG?page[offset]=0&filter[time_range][condition][since]=FROM_START_TIME&filter[time_range][condition][until]=BEFORE_END_TIME&sort=time
	variable startTimeSec= date2secs((StartYear), (StartMonth), (StartDay)) - 2082844800 - Date2secs(-1,-1,-1) //convert to Python time and fix to UTC time which BS is using. 
	variable endTimeSec = startTimeSec + NumOfHours*60*60
	string TempAddress = ServerAddress+"/api/v1/search/"
	string StartTimeStr, EndTimeStr
	sprintf StartTimeStr, "%.15g" ,startTimeSec
	sprintf EndTimeStr, "%.15g" ,endTimeSec
	
	variable chunkToDownload = 250
	variable OffsetStart=0
	variable NumStepsNeeded = ceil(NumberOfScansToImport/chunkToDownload)
	variable TempNumberOfScansToImport
	variable i, done=0
	variable numDataSets, i2, j, Oldrecords=0
	string tempPlanName, tempMetadata
	KillWaves/Z IDwave, PlanNameWave, TimeWave
	make/O/N=(0)/T IDwave, PlanNameWave, MetadataStr
	make/O/N=(0)/D TimeWave						//must be double precision!
	//abort if no usable catalog is selected. 
	if(StringMatch(CatalogUsed, "---" ))
		Wave w1= root:Packages:Irena:BlueSkySamplePlot:SelectionOfAvailableData
		Wave/T wt2= root:Packages:Irena:BlueSkySamplePlot:PrunedListOfAvailableData
		Wave/T wt1= root:Packages:Irena:BlueSkySamplePlot:ListOfAvailableData
		redimension/N=0 w1, wt1, wt2
		abort 
	endif

	//variable timerRefNum=startMSTimer
	
	//need to split into smaller chunks (100) to download in pages.
	For(i2=0;i2<NumStepsNeeded;i2+=1)
		OffsetStart = i2*chunkToDownload
		//print "Downloading "+num2str(i2)+" set of "+num2str(chunkToDownload)+" data" 
		TempAddress = ServerAddress+"/api/v1/search/"			//this needs to be reset here... 
		if(AllDates)
			//TempAddress +=CatalogUsed+"?page[offset]=00&page[limit]="+num2str(NumberOfScansToImport)+"&sort=time"
			TempAddress +=Prefix+"/?page[offset]="+num2str(OffsetStart)+"&page[limit]="+num2str(chunkToDownload)+"&sort=time"
		else
			TempAddress +=Prefix+"/?page[offset]="+num2str(OffsetStart)+"&page[limit]="+num2str(chunkToDownload)+"&filter[time_range][condition][since]="+StartTimeStr+"&filter[time_range][condition][until]="+EndTimeStr
			if(!	StringMatch(ScanTypeToUse, "all"))
				TempAddress +="&filter[eq][condition][key]=plan_name"
				TempAddress +="&filter[eq][condition][value]=\""+ScanTypeToUse+"\""
			endif
			//&filter[scan_id][condition][scan_ids]=SCAN_ID
			TempAddress +="&filter[time_range][condition][timezone]=US/Central&sort=time"
			//note: sort=-time sorts in inverse chronological order. 
			//example
			//http://usaxscontrol:8020/api/v1/node/search/20idb_usaxs?page[offset]=0&page[limit]=100&filter[time_range][condition][since]=1671235200&filter[time_range][condition][until]=1671321600&filter[time_range][condition][timezone]=US/Central&sort=time
			//http://usaxscontrol:8020/api/v1/node/search/20idb_usaxs?page[offset]=100&page[limit]=100&filter[time_range][condition][since]=1671235200&filter[time_range][condition][until]=1671321600&filter[time_range][condition][timezone]=US/Central&sort=time
		endif
		TempAddress+="&fields=metadata&omit_links=true"		//this maps everything outside metadata to null, including links. Makes everything smaller and faster. . 
		//print TempAddress
		//example: http://usaxscontrol.xray.aps.anl.gov:8020/api/v1/search/idb_usaxs_retired_2023-12-05?page[offset]=0&page[limit]=250&filter[time_range][condition][since]=1678341600&filter[time_range][condition][until]=1678413600&filter[eq][condition][key]=plan_name&filter[eq][condition][value]=%22tune_ar%22&filter[time_range][condition][timezone]=US/Central&sort=time&fields=metadata&omit_links=true
		//this is example of what we are getting on 1-4-2024 when scoped down to metadata only and removed links: TempAddress+="&fields=metadata&omit_links=true" this is single scan document: 
				// {
				//   "data": [
				//      {
				//         "attributes": {
				//            "ancestors": [
				//               "idb_usaxs_retired_2023-12-05"
				//            ],
				//            "data_sources": null,
				//            "metadata": {
				//               "start": {
				//                  "EPICS_CA_MAX_ARRAY_BYTES": "1280000",
				//                  "EPICS_HOST_ARCH": "linux-x86_64",
				//                  "beamline_id": "APS 9-ID-C USAXS",
				//                  "datetime": "2023-03-09 00:04:36.101637",
				//                  "detectors": [
				//                     "PD_USAXS"
				//                  ],
				//                  "epics_libca": "/home/beams11/USAXS/micromamba/envs/bluesky_2023_1/lib/python3.10/site-packages/epics/clibs/linux64/libca.so",
				//                  "hints": {
				//                     "dimensions": [
				//                        [
				//                           [
				//                              "a_stage_r2p"
				//                           ],
				//                           "primary"
				//                        ]
				//                     ]
				//                  },
				//                  "login_id": "usaxs@usaxscontrol.xray.aps.anl.gov",
				//                  "motors": [
				//                     "a_stage_r2p"
				//                  ],
				//                  "num_intervals": 30,
				//                  "num_points": 31,
				//                  "pid": 1521928,
				//                  "plan_args": {
				//                     "args": [
				//                        "UsaxsMotorTunable(prefix='9idcLAX:pi:c0:m1', name='a_stage_r2p', parent='a_stage', settle_time=0.0, timeout=None, read_attrs=['user_readback', 'user_setpoint'], configuration_attrs=['user_offset', 'user_offset_dir', 'velocity', 'acceleration', 'motor_egu', 'width'])",
				//                        43.48869216238651,
				//                        55.48869216238651
				//                     ],
				//                     "detectors": [
				//                        "myScalerCH(prefix='9idcLAX:vsc:c0', name='scaler0', read_attrs=['channels', 'channels.chan04', 'channels.chan04.s', 'time'], configuration_attrs=['channels', 'channels.chan01', 'channels.chan01.chname', 'channels.chan01.preset', 'channels.chan01.gate', 'channels.chan04', 'channels.chan04.chname', 'channels.chan04.preset', 'channels.chan04.gate', 'count_mode', 'delay', 'auto_count_delay', 'freq', 'preset_time', 'auto_count_time', 'egu'])",
				//                        "UsaxsMotorTunable(prefix='9idcLAX:pi:c0:m1', name='a_stage_r2p', parent='a_stage', settle_time=0.0, timeout=None, read_attrs=['user_readback', 'user_setpoint'], configuration_attrs=['user_offset', 'user_offset_dir', 'velocity', 'acceleration', 'motor_egu', 'width'])"
				//                     ],
				//                     "num": 31,
				//                     "per_step": "None"
				//                  },
				//                  "plan_name": "tune_a2rp",
				//                  "plan_pattern": "inner_product",
				//                  "plan_pattern_args": {
				//                     "args": [
				//                        "UsaxsMotorTunable(prefix='9idcLAX:pi:c0:m1', name='a_stage_r2p', parent='a_stage', settle_time=0.0, timeout=None, read_attrs=['user_readback', 'user_setpoint'], configuration_attrs=['user_offset', 'user_offset_dir', 'velocity', 'acceleration', 'motor_egu', 'width'])",
				//                        43.48869216238651,
				//                        55.48869216238651
				//                     ],
				//                     "num": 31
				//                  },
				//                  "plan_pattern_module": "bluesky.plan_patterns",
				//                  "plan_type": "generator",
				//                  "proposal_id": "testing",
				//                  "purpose": "tuner",
				//                  "scan_id": 440,
				//                  "time": 1678341876.142742,
				//                  "tune_md": {
				//                     "initial_position": 49.48869216238651,
				//                     "time_iso8601": "2023-03-09 00:04:36.118210",
				//                     "width": 12.0
				//                  },
				//                  "tune_parameters": {
				//                     "initial_position": 49.48869216238651,
				//                     "num": 31,
				//                     "peak_choice": "com",
				//                     "width": 12.0,
				//                     "x_axis": "a_stage_r2p",
				//                     "y_axis": "PD_USAXS"
				//                  },
				//                  "uid": "27a3c3d2-b768-40fc-bcba-bfa013196448",
				//                  "versions": {
				//                     "apstools": "1.6.10",
				//                     "area_detector_handlers": "0.0.10",
				//                     "bluesky": "1.10.0",
				//                     "databroker": "1.2.5",
				//                     "epics": "3.5.0",
				//                     "epics_ca": "3.5.0",
				//                     "h5py": "3.8.0",
				//                     "matplotlib": "3.6.3",
				//                     "numpy": "1.23.5",
				//                     "ophyd": "1.7.0",
				//                     "pyRestTable": "2020.0.7",
				//                     "pymongo": "4.3.3",
				//                     "spec2nexus": "2021.2.5"
				//                  }
				//               },
				//               "stop": {
				//                  "exit_status": "success",
				//                  "num_events": {
				//                     "baseline": 2,
				//                     "primary": 31
				//                  },
				//                  "reason": "",
				//                  "run_start": "27a3c3d2-b768-40fc-bcba-bfa013196448",
				//                  "time": 1678341888.2595327,
				//                  "uid": "00e9f178-2191-4ac5-a92d-d971fabd1d3b"
				//               },
				//               "summary": {
				//                  "datetime": "2023-03-09T00:04:36.142742",
				//                  "duration": 12.116790771484375,
				//                  "plan_name": "tune_a2rp",
				//                  "scan_id": 440,
				//                  "stream_names": [
				//                     "aps_current_monitor",
				//                     "baseline",
				//                     "primary"
				//                  ],
				//                  "timestamp": 1678341876.142742,
				//                  "uid": "27a3c3d2-b768-40fc-bcba-bfa013196448"
				//               }
				//            },
				//            "sorting": null,
				//            "specs": null,
				//            "structure": null,
				//            "structure_family": "container"
				//         },
				//         "id": "27a3c3d2-b768-40fc-bcba-bfa013196448",
				//         "links": null,
				//         "meta": null
				//      }
				//   ],
				//   "error": null,
				//   "links": {
				//      "first": "http://usaxscontrol.xray.aps.anl.gov:8020/api/v1/search/idb_usaxs_retired_2023-12-05?page[offset]=0&page[limit]=1",
				//      "last": "http://usaxscontrol.xray.aps.anl.gov:8020/api/v1/search/idb_usaxs_retired_2023-12-05?page[offset]=267&page[limit]=1",
				//      "next": "http://usaxscontrol.xray.aps.anl.gov:8020/api/v1/search/idb_usaxs_retired_2023-12-05?page[offset]=1&page[limit]=1",
				//      "prev": null,
				//      "self": "http://usaxscontrol.xray.aps.anl.gov:8020/api/v1/search/idb_usaxs_retired_2023-12-05?page[offset]=0&page[limit]=1"
				//   },
				//   "meta": {
				//      "count": 267
				//   }
				//}
				//

		//NOW, scope down even more using JMESpath querry...
		//&select_metadata={detectors:start.detectors,motors:start.motors}
		//Note: select_metadata = Curly brackets,
		//detectors : start.detectors , mpotors:start.motors etc. 
		//NOTE: changes layout…   
		//http://usaxscontrol.xray.aps.anl.gov:8020/api/v1/search/idb_usaxs_retired_2023-12-05?page[offset]=0&page[limit]=250&filter[time_range][condition][since]=1678341600&filter[time_range][condition][until]=1678413600&filter[eq][condition][key]=plan_name
		//&filter[eq][condition][value]=%22tune_a2rp%22&filter[time_range][condition][timezone]=US/Central&sort=time&fields=metadata&omit_links=true&select_metadata={detectors:start.detectors,motors:start.motors}
		TempAddress+="&select_metadata={detectors:start.detectors,motors:start.motors,plan_name:start.plan_name,time:start.time}"		//this selects only specific metadata. 
		//this returns very small document:
			//{
			//   "data": [
			//      {
			//         "attributes": {
			//            "ancestors": [
			//               "idb_usaxs_retired_2023-12-05"
			//            ],
			//            "data_sources": null,
			//            "metadata": {
			//               "detectors": [
			//                  "PD_USAXS"
			//               ],
			//               "motors": [
			//                  "a_stage_r2p"
			//               ],
			//               "plan_name": "tune_a2rp",
			//               "time": 1678341876.142742
			//            },
			//            "sorting": null,
			//            "specs": null,
			//            "structure": null,
			//            "structure_family": "container"
			//         },
			//         "id": "27a3c3d2-b768-40fc-bcba-bfa013196448",
			//         "links": null,
			//         "meta": null
			//      }
			//   ],
			//   "error": null,
			//   "links": {
			//      "first": "http://usaxscontrol.xray.aps.anl.gov:8020/api/v1/search/idb_usaxs_retired_2023-12-05?page[offset]=0&page[limit]=1",
			//      "last": "http://usaxscontrol.xray.aps.anl.gov:8020/api/v1/search/idb_usaxs_retired_2023-12-05?page[offset]=267&page[limit]=1",
			//      "next": "http://usaxscontrol.xray.aps.anl.gov:8020/api/v1/search/idb_usaxs_retired_2023-12-05?page[offset]=1&page[limit]=1",
			//      "prev": null,
			//      "self": "http://usaxscontrol.xray.aps.anl.gov:8020/api/v1/search/idb_usaxs_retired_2023-12-05?page[offset]=0&page[limit]=1"
			//   },
			//   "meta": {
			//      "count": 267
			//   }
			//}

		print TempAddress
		URLRequest/Z url=TempAddress
		if(V_Flag!=0)
			abort "Server not available"
		endif
		JSONXOP_Parse/Z(S_serverResponse)
		if(V_Flag!=0)
			abort "Cannot parse server response"
		endif
		variable jsonId = V_Value
		//debug commands: 
		//print jsonID
		//JSONXOP_Dump/IND=3 jsonId
		//print "*********************AAAAAA*******************************"
		//print strlen(S_Value)		//-- prints the file in history and works. 
		//print S_Value				//-- prints the file in history and works. 
		//this list how many items are in that address, this is how many data sets were returned in the json. 
		//print JSON_GetArraySize(jsonID, "/data")	
		//this works for string keys in given location, not for single value
		//JSONXOP_GetKeys jsonId, "/data/0", keyWave
		//this reads value... Number: 
		//JSONXOP_GetValue/T jsonId, "/data/0/id"
		//print S_value
		
		//print JSON_GetType(jsonID, "/data/0/id")
			//	0 Object
			//	1 Array
			//	2 Numeric
			//	3 String
			//	4 Boolean
			//	5 Null
			
		//time conversion. Tiled uses January 1, 1970
		//print/D date2secs(1970,1,1)
		//while Igor is 1904. We need to add :  
	  	// date2secs(2022, 02, 20 ) - date2secs(1970,01,01)			//this converts to UTC, which is not needed anymore... : - Date2secs(-1,-1,-1)		
		//let's list those which are plan "tune_a2rp"
		numDataSets = JSON_GetArraySize(jsonID, "/data")
		Redimension/N=(Oldrecords+numDataSets) IDwave, PlanNameWave, TimeWave, MetadataStr
		j=Oldrecords
		For(i=0;i<numDataSets;i+=1)
			//tempAddress = "/data/"+num2str(i)+"/attributes/metadata/start/plan_name"		//for one without select_metadata
			tempAddress = "/data/"+num2str(i)+"/attributes/metadata/plan_name"				//for one WITH select_metadata
			tempPlanName = JSON_GetString(jsonID, tempAddress,ignoreErr=1) 
			//if(!StringMatch(tempPlanName, "documentation_run"))
			tempAddress = "/data/"+num2str(i)+"/id"
			IDwave[j] = JSON_GetString(jsonID, tempAddress,ignoreErr=1)
			PlanNameWave[j]=tempPlanName
			//tempAddress = "/data/"+num2str(i)+"/attributes/metadata/start/time"		//for one without select_metadata
			tempAddress = "/data/"+num2str(i)+"/attributes/metadata/time"				//for one WITH select_metadata
			//print/D JSON_GetVariable(jsonID, tempAddress)
			TimeWave[j] = JSON_GetVariable(jsonID, tempAddress,ignoreErr=1) + date2secs(1970,01,01)+ Date2secs(-1,-1,-1) 		//this is in Chicago time for User interface (+ Date2secs(-1,-1,-1))
			//now metadata which can be used to scope down the data. 
			MetadataStr[j] = ""
			//tempAddress = "/data/"+num2str(i)+"/attributes/metadata/start/detectors/0"		//for one without select_metadata
			tempAddress = "/data/"+num2str(i)+"/attributes/metadata/detectors/0"				//for one WITH select_metadata
			tempMetadata= JSON_GetString(jsonID, tempAddress,ignoreErr=1)
			MetadataStr[j]+="Detector="+tempMetadata+";"
			DetectorStr = tempMetadata
			//tempAddress = "/data/"+num2str(i)+"/attributes/metadata/start/motors/0"		//for one without select_metadata
			tempAddress = "/data/"+num2str(i)+"/attributes/metadata/motors/0"				//for one WITH select_metadata
			tempMetadata= JSON_GetString(jsonID, tempAddress,ignoreErr=1)
			MetadataStr[j]+="Axis="+tempMetadata+";"
			Xaxis = tempMetadata
			//tempAddress = "/data/"+num2str(i)+"/attributes/metadata/start/motors/0"		//for one without select_metadata
			//tempMetadata= JSON_GetString(jsonID, tempAddress,ignoreErr=1)
			//MetadataStr[j]+="Axis="+tempMetadata+";"
			j+=1
		endfor
		Oldrecords=j
		JSONXOP_Release jsonId
		if(numDataSets<(chunkToDownload-1))
			break
		endif
	endfor
	
	//variable microseconds = StopMSTimer(timerRefNum)
	//print microseconds
	//timerRefNum = startMSTimer
	//populate listbox
	wave/T ListOfAvailableData = root:Packages:Irena:BlueSkySamplePlot:ListOfAvailableData
	Wave SelectionOfAvailableData = root:Packages:Irena:BlueSkySamplePlot:SelectionOfAvailableData
	redimension/N=(j,4) ListOfAvailableData 
	redimension/N=(j) SelectionOfAvailableData 
	SelectionOfAvailableData = 0
	if(j>0)
		ListOfAvailableData[][0] = PlanNameWave[p]
		ListOfAvailableData[][1] = Secs2Date(TimeWave[p],-2)+"   "+Secs2Time(TimeWave[p],3)
		ListOfAvailableData[][2] = MetadataStr[p]
		ListOfAvailableData[][3] = IDwave[p]
	endif
		
	IR3BS_UdateListBoxScans()
	//microseconds = StopMSTimer(timerRefNum)
	//print microseconds
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR3BS_UdateListBoxScans()

	//populate listbox
	wave/T ListOfAvailableData = root:Packages:Irena:BlueSkySamplePlot:ListOfAvailableData
	Wave/T PrunedListOfAvailableData  =root:Packages:Irena:BlueSkySamplePlot:PrunedListOfAvailableData
	redimension/N=(0,4) PrunedListOfAvailableData
	Wave SelectionOfAvailableData = root:Packages:Irena:BlueSkySamplePlot:SelectionOfAvailableData
	//create list of scans available on server
	SVAR ListOfScanTypes=root:Packages:Irena:BlueSkySamplePlot:ListOfScanTypes
	SVAR ScanTypeToUse=root:Packages:Irena:BlueSkySamplePlot:ScanTypeToUse
	if(!stringmatch(ScanTypeToUse,"all"))
		Grep /A /E=(ScanTypeToUse)/GCOL=0  ListOfAvailableData as PrunedListOfAvailableData
	else
		Duplicate/O/T ListOfAvailableData, PrunedListOfAvailableData
	endif
	redimension/N=(DimSize(PrunedListOfAvailableData,0)) SelectionOfAvailableData 
	SelectionOfAvailableData = 0

end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR3S_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IR3BS_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(StringMatch(pa.ctrlName, "CatalogUsed" ))
				SVAR ListOfCatalogs=root:Packages:Irena:BlueSkySamplePlot:ListOfCatalogs
				SVAR CatalogUsed=root:Packages:Irena:BlueSkySamplePlot:CatalogUsed
				CatalogUsed = popStr
				IR3BS_InitCatalog()		//this locates the Catalog path
				IR3BS_GetJSONScanData()	//this updates the catalog data, if possible. 
			endif
			
			if(StringMatch(pa.ctrlName, "ScanTypeToUse" ))
				SVAR ListOfScanTypes=root:Packages:Irena:BlueSkySamplePlot:ListOfScanTypes
				SVAR ScanTypeToUse=root:Packages:Irena:BlueSkySamplePlot:ScanTypeToUse
				ScanTypeToUse = popStr
				IR3BS_UdateListBoxScans()
				//call update here... 
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

// package needs specific JSON functions

/// @addtogroup JSONXOP_GetArraySize
/// @{
/// @brief Get the number of elements in an array.
///
/// @param jsonID     numeric identifier of the JSON object
/// @param jsonPath   RFC 6901 compliant JSON Pointer
/// @param ignoreErr  [optional, default 0] set to ignore runtime errors
/// @returns a numeric variable with the number of elements the array at jsonPath
threadsafe static Function JSON_GetArraySize(jsonID, jsonPath, [ignoreErr])
	Variable jsonID
	String jsonPath
	Variable ignoreErr

	ignoreErr = ParamIsDefault(ignoreErr) ? JSON_ZFLAG_DEFAULT : !!ignoreErr

	JSONXOP_GetArraySize/Z=1/Q=(JSON_QFLAG_DEFAULT) jsonID, jsonPath
	if(V_flag)
		if(ignoreErr)
			return NaN
		endif

		AbortOnValue 1, V_flag
	endif

	return V_Value
End

/// @brief Get a text entity as string variable from a JSON object
///
/// @param jsonID     numeric identifier of the JSON object
/// @param jsonPath   RFC 6901 compliant JSON Pointer
/// @param ignoreErr  [optional, default 0] set to ignore runtime errors
/// @returns a string containing the entity
threadsafe static Function/S JSON_GetString(jsonID, jsonPath, [ignoreErr])
	Variable jsonID
	String jsonPath
	Variable ignoreErr

	ignoreErr = ParamIsDefault(ignoreErr) ? JSON_ZFLAG_DEFAULT : ignoreErr

	JSONXOP_GetValue/Z=1/Q=(JSON_QFLAG_DEFAULT)/T jsonID, jsonPath
	if(V_flag)
		if(ignoreErr)
			return ""
		endif

		AbortOnValue 1, V_flag
	endif

	return S_Value
End

/// @brief Get a numeric, boolean or null entity as variable from a JSON object
///
/// @param jsonID     numeric identifier of the JSON object
/// @param jsonPath   RFC 6901 compliant JSON Pointer
/// @param ignoreErr  [optional, default 0] set to ignore runtime errors
/// @returns a numeric variable containing the entity
threadsafe static Function JSON_GetVariable(jsonID, jsonPath, [ignoreErr])
	Variable jsonID
	String jsonPath
	Variable ignoreErr

	ignoreErr = ParamIsDefault(ignoreErr) ? JSON_ZFLAG_DEFAULT : ignoreErr

	JSONXOP_GetValue/Z=1/Q=(JSON_QFLAG_DEFAULT)/V jsonID, jsonPath
	if(V_flag)
		if(ignoreErr)
			return NaN
		endif

		AbortOnValue 1, V_flag
	endif

	return V_Value
End

/// @brief Get an array as numeric wave from a JSON object
///
/// @param jsonID     numeric identifier of the JSON object
/// @param jsonPath   RFC 6901 compliant JSON Pointer
/// @param ignoreErr  [optional, default 0] set to ignore runtime errors
/// @returns a free numeric double precision wave with the elements of the array
threadsafe static Function/WAVE JSON_GetWave(jsonID, jsonPath, [ignoreErr])
	Variable jsonID
	String jsonPath
	Variable ignoreErr

	ignoreErr = ParamIsDefault(ignoreErr) ? JSON_ZFLAG_DEFAULT : ignoreErr

	JSONXOP_GetValue/Z=1/Q=(JSON_QFLAG_DEFAULT)/WAVE=wv/FREE jsonID, jsonPath
	if(V_flag)
		if(ignoreErr)
			return $""
		endif

		AbortOnValue 1, V_flag
	endif

	return wv
End


/// @addtogroup JSONXOP_GetKeys
/// @{
/// @brief Get the name of all object members of the specified path
///
/// @param jsonID     numeric identifier of the JSON object
/// @param jsonPath   RFC 6901 compliant JSON Pointer
/// @param ignoreErr  [optional, default 0] set to ignore runtime errors
/// @param esc        [optional, 0 or 1] set to ignore RFC 6901 path escaping standards
/// @returns a free text wave with all elements as rows.
threadsafe static Function/WAVE JSON_GetKeys(jsonID, jsonPath, [esc, ignoreErr])
	Variable jsonID
	String jsonPath
	Variable esc, ignoreErr

	ignoreErr = ParamIsDefault(ignoreErr) ? JSON_ZFLAG_DEFAULT : !!ignoreErr

	if(ParamIsDefault(esc))
		JSONXOP_GetKeys/Z=1/Q=(JSON_QFLAG_DEFAULT)/FREE jsonID, jsonPath, result
	else
		esc = !!esc
		JSONXOP_GetKeys/Z=1/Q=(JSON_QFLAG_DEFAULT)/ESC=(esc)/FREE jsonID, jsonPath, result
	endif

	if(V_flag)
		if(ignoreErr)
			return $""
		endif

		AbortOnValue 1, V_flag
	endif

	return result
End

/// @addtogroup JSONXOP_GetMaxArraySize
/// @{
/// @brief Get the maximum element size for each dimension in an array
///
/// @param jsonID     numeric identifier of the JSON object
/// @param jsonPath   RFC 6901 compliant JSON Pointer
/// @param ignoreErr  [optional, default 0] set to ignore runtime errors
/// @returns a free numeric wave with the size for each dimension as rows
threadsafe static Function/WAVE JSON_GetMaxArraySize(jsonID, jsonPath, [ignoreErr])
	Variable jsonID
	String jsonPath
	Variable ignoreErr

	ignoreErr = ParamIsDefault(ignoreErr) ? JSON_ZFLAG_DEFAULT : !!ignoreErr

	JSONXOP_GetMaxArraySize/Z=1/Q=(JSON_QFLAG_DEFAULT)/FREE jsonID, jsonPath, w
	if(V_flag)
		if(ignoreErr)
			return $""
		endif

		AbortOnValue 1, V_flag
	endif

	return w
End
/// @}

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************




//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//
//Function JSONXOP_GetKeys_example1()
//
//    variable jsonId
//    string jsonStr
//
//    jsonStr = "{"
//    jsonStr += "\"Fridge\":{"
//    jsonStr += "\"Milk\":\"half empty\","
//    jsonStr += "\"Batteries\":2},"
//    jsonStr += "\"Freezer\":{"
//    jsonStr += "\"FishSticks\":15,"
//    jsonStr += "\"Straciatella\":\"Big Box\"}"
//    jsonStr += "}"
//
//    JSONXOP_Parse jsonStr
//    jsonId = V_value
//    JSONXOP_GetKeys jsonId, "/Freezer", keyWave
//    print "Keys at /Freezer:\r", keyWave
//    JSONXOP_Release jsonId
//End
//
//
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

//Function IR3S_ListBoxProc(lba) : ListBoxControl
//	STRUCT WMListboxAction &lba
//
//	Variable row = lba.row
//	Variable col = lba.col
//	WAVE/T/Z listWave = lba.listWave
//	WAVE/Z selWave = lba.selWave
//
//	switch( lba.eventCode )
//		case -1: // control being killed
//			break
//		case 1: // mouse down
//			break
//		case 3: // double click
//			break
//		case 4: // cell selection
//		case 5: // cell selection plus shift key
//			break
//		case 6: // begin edit
//			break
//		case 7: // finish edit
//			break
//		case 13: // checkbox clicked (Igor 6.2 or later)
//			break
//	endswitch
//
//	return 0
//End
//

#endif

// These are hints how to talk to the tiled servewr with examples. The document below may not be accessible from outside ANL, so it is here. 
// https://anl.app.box.com/s/hbt5v85b4pwt66gtp2782izxn0fg32uv
//# URI Hints for tiled
//
//Caution:  _These hints are for Bluesky catalogs served by **tiled** and may not be correct for other catalog types._
//
//The tiled server receives `GET` requests as URIs and returns JSON (or other as directed) results.  Below, these results are referred to as `RESULTS`.
//
//written: 2022-03-01
//
//- [URI Hints for tiled](#uri-hints-for-tiled)
//  - [Server information](#server-information)
//    - [Server root](#server-root)
//    - [Server overview](#server-overview)
//    - [Server documentation](#server-documentation)
//    - [What catalogs are available on this server?](#what-catalogs-are-available-on-this-server)
//  - [Catalog information](#catalog-information)
//  - [Filter catalog by range of dates](#filter-catalog-by-range-of-dates)
//    - [time representation in the filter](#time-representation-in-the-filter)
//    - [URI construction by the parts](#uri-construction-by-the-parts)
//      - [optional: pager](#optional-pager)
//      - [optional: Time zone filter](#optional-time-zone-filter)
//      - [optional: start time](#optional-start-time)
//      - [optional: end time](#optional-end-time)
//  - [Find run by `scan_id`](#find-run-by-scan_id)
//    - [What kind of catalog is it?](#what-kind-of-catalog-is-it)
//    - [run metadata](#run-metadata)
//    - [full metadata](#full-metadata)
//    - [Stream names](#stream-names)
//    - [Data formats](#data-formats)
//
//## Server information
//
//### Server root
//
//working with `http://usaxscontrol:8020`, calling this SERVER
//
//### Server overview
//
//```
//SERVER/
//```
//
//Returns JSON describing the supported return formats (and their aliases).
//
//### Server documentation
//
//```
//SERVER/docs
//```
//
//### What catalogs are available on this server?
//
//```
//SERVER/node/search/?fields=&sort=
//```
//
//JSON nodes:
//
//description        | URI
//-------------      | ---------------------
//number of catalogs | `RESULTS[INTEGER]["meta"]["count"]`
//catalog names      | `RESULTS[INTEGER]["id"]` _(where `INTEGER` is a number)_
//
//Information from a CATALOG is shown below.
//The first CATALOG in the list is obtained from: `RESULTS[0]["id"]`
//
//## Catalog information
//
//```
//SERVER/node/search/?filter[lookup][condition][key]=CATALOG&sort
//SERVER/node/search/CATALOG?page[offset]=0&sort=time
//```
//
//Not sure how helpful RESULTS from the first URI.  The second URI returns RESULTS with a full list of the available runs in the catalog.
//
//JSON nodes describe this information (and more):
//
//description | URI
//--- | ---
//runs | `RESULTS["data"][INTEGER]`  _(where `INTEGER` is a number)_
//run `id` codes | `RESULTS["data"][INTEGER]["id"]`
//type of run | `RESULTS["data"][INTEGER]["attributes"]["spec"][0]`
//run `scan_id` | `RESULTS["data"][INTEGER]["metadata"]["summary"]["scan_id"]`
//run `plan_name` | `RESULTS["data"][INTEGER]["metadata"]["summary"]["plan_name"]`
//run `uid` | `RESULTS["data"][INTEGER]["metadata"]["summary"]["uid"]`
//run `timestamp` | `RESULTS["data"][INTEGER]["metadata"]["summary"]["timestamp"]`
//run metadata (dictionary) | `RESULTS["data"][INTEGER]["metadata"]["start"]`
//
//Note: The run's `id` will be the same as the `uid` for Bluesky runs.  If the catalog is serving a directory of files, the `id` will be the name of the file (without the file extension).
//
//## Filter catalog by range of dates
//
//This is a URI to get a catalog (in JSON) for runs between two dates.  There are many parts to this URI so explanations of each of the parts follows.
//
//```
//SERVER/node/search/CATALOG?page[offset]=0&filter[time_range][condition][since]=FROM_START_TIME&filter[time_range][condition][until]=BEFORE_END_TIME&sort=time
//```
//
//The JSON results are just like [the full catalog](#catalog-information) but restricted to the time range.
//
//### time representation in the filter
//
//Dates are formatted in the URIs as floating point time representing the number of seconds since 1970-01-01 UTC.  For example:
//
//ISO8601 representation | floating point time
//---------------------- | -------------------:
//2022-02-20 00:00:00    | 1645336800.0
//2022-02-21             | 1645423200.0
//
//### URI construction by the parts
//
//To create a URI with filter options, start with this:
//
//```
//SEARCH/node/search/CATALOG?
//```
//
//Separate multiple options with a `&` (and **NO added whitespace**), such as:
//
//```
//SEARCH/node/search/CATALOG?OPTION1&OPTION2
//```
//
//#### optional: pager
//
//Use a pager to limit the number of results and the starting point for the results:
//
//Start with first results:
//
//```
//page[offset]=0
//```
//
//Only show up to 5 runs:
//
//```
//page[limit]=5
//```
//
//#### optional: Time zone filter
//
//You can append a time zone filter to the URI:
//
//```
//&filter[time_range][condition][timezone]=America%2FChicago
//```
//
//Not sure how it helps or if it is truly necessary.  (May be useful if the catalog contains runs from another time zone but the time stamps are all UTC anyway.)
//
//#### optional: start time
//
//Filter the catalog by runs with start times greater than or equal to a time representation:
//
//```
//filter[time_range][condition][since]=FROM_START_TIME
//```
//
//#### optional: end time
//
//Filter the catalog by runs with start times less than to a time representation:
//
//```
//filter[time_range][condition][until]=BEFORE_END_TIME
//```
//
//## Find run by `scan_id`
//
//Runs are retrieved from the tiled server by the `id`.  For Bluesky runs, this is the run's `uid`.
//
//First, get the run's `id:
//
//```
//SERVER/node/search/CATALOG?fields=&filter[scan_id][condition][scan_ids]=SCAN_ID&filter[scan_id][condition][duplicates]=latest&sort=time
//```
//
//The `ID` is obtained from `RESULTS[INTEGER]["id"]` (where `INTEGER` is a number).  Then, get the run's STREAM (such as `primary` data in the [default format](#data-formats). (JSON? for a web client, HTML for a web browser, Python data structure for the tiled python client):
//
//```
//SERVER/node/full/CATALOG/ID/STREAM/data
//```
//
//These are the URIs used by the tiled python client.  Guessing at why each is used.  (Look at the tiled source code and it might be obvious why each is used.)  An attempt at explanation is provided for each.
//
//### What kind of catalog is it?
//
//```
//SERVER/node/search/?filter[lookup][condition][key]=CATALOG&sort=
//```
//
//`RESULTS[0]["attributes"]["specs"][0]` says it is a `CatalogOfBlueskyRuns` (could be a different kind of catalog, so good to check it)
//
//### run metadata
//
//This URI gets metadata for _all_ runs in the catalog with a specific `scan_id`.
//
//```
//SERVER/node/search/CATALOG?fields=&filter[scan_id][condition][scan_ids]=SCAN_ID&filter[scan_id][condition][duplicates]=latest&sort=time
//```
//
//JSON nodes of interest:
//
//description | JSON node
//--- | ---
//run `id` | `RESULTS[INTEGER]["id"]`
//URI to run's metadata | `RESULTS[INTEGER]["links"]["self"]`
//
//**NOTE**: The node  `RESULTS[INTEGER]["links"]["self"]` yields JSON results that are very descriptive.  Contains information about the run's [streams](#stream-names).
//
//### full metadata
//
//```
//SERVER/node/search/CATALOG?page[offset]=0&page[limit]=1&filter[scan_id][condition][scan_ids]=205&filter[scan_id][condition][duplicates]=latest&sort=time
//```
//
//### Stream names
//
//As noted [above](#run-metadata), information about the run's streams.
//
//```
//SERVER/node/search/CATALOG/ID?fields=&sort=
//```
//
//description | JSON node
//--- | ---
//number of streams | `RESULTS["meta"]["count"]`
//stream names | `RESULTS[INTEGER]["id"]`
//
//### Data formats
//
//Results may be formatted by the tiled server using a variety of formats.  Add this to the URI (as an example to get data from a bluesky run's STREAM):
//
//```
//SERVER/node/full/CATALOG/ID/STREAM/data?format=FORMAT
//```
//
//where the formats (alphabetical order by name) include:
//
//FORMAT | description
//--- | ---
//`application/x-hdf5` | HDF5 (note: not NeXus structure)
//`csv` | comma-separated values table
//`html` | HTML table
//`json` | JSON (structured text, similar to a Python dictionary)
//`nc` | NetCDF
//`text` | text, might be same as `csv`
//`xlsx` | spreadsheet (for Excel, Open Office, Libre Office, ...)
//
//Only a subset of these might be possible for any URI so keep trying until something works.
