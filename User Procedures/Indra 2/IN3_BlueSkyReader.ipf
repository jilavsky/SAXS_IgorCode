#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=1.01
	//this is available ONLY, if JSONXOP is installed and json_functions.ipf is in User Procedures. 
#if(exists("JSONXOP_GetValue")==4)
#include "json_functions"

	// Add to menu if available. 
Menu "USAXS"
	"Bluesky Plots", IR3BS_BlueSkyPlot()
end


//1.01 November 2022, Tiled 0.1.0a80 compatible, changed webGUI 
//1.00 original version, kind of works
//server address. 
strconstant ServerAddress="http://usaxscontrol:8000"
//strconstant ServerAddress="http://wow.xray.aps.anl.gov:8010"

//some notes. See end of this file for how to talk to the server instructions
//getting data from usaxscontrol seem to be issue. 
//http://usaxscontrol:8000/node/full/9idc_usaxs%2F1e6c2ad1-055e-40e5-bbc0-7209317a2717?format=application%2Fx-hdf5
//fails with Internal Server Error and asking for json does not work. Need to figure out how to get data from server.  
// See tilted hints document. 
//  http://usaxscontrol:8000/node/full/9idc_usaxs/16248ab5-1359-4242-8ec9-6fd66f8b5976/primary/data?format=json this gets out primary scan as json. 
// http://usaxscontrol:8000/node/search/?filter[lookup][condition][key]=9idc_usaxs&sort=
// documentation and testing http://usaxscontrol:8000/docs
// retruns json where 
// need to add this : "&filter[time_range][condition][timezone]=US/Central" into the querries to it works... 


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
	string TempAddress = ServerAddress+"/api/v1/node/search/?fields=&sort="
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
	CatalogUsed = stringfromList(0,grepList(AllCatalogs,"20idb_usaxs"))
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
	//string 	ServerType =JSON_GetString(jsonID, tempAddress)

	// TempAddress = ServerAddress+"/node/search/?filter[lookup][condition][key]=9idc_usaxs&sort="

//		tempPlanName = JSON_GetString(jsonID, tempAddress) 

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
		
	//time conversion. Python uses January 1, 1970
	//print/D date2secs(1970,1,1)
	//while Igor is 1904. We need to add :  
  	// date2secs(2022, 02, 20 ) - date2secs(1970,01,01) - Date2secs(-1,-1,-1)
  	// converting date - offset change - correction to UTC

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
//	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"

	ListOfVariables="StartYear;StartMoth;StartDay;NumOfHours;AllDates;NumberOfScansToImport;"
//	ListOfVariables="UseIndra2Data;UseQRSdata;UseResults;"

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
	StartYear =2022
	NVAR StartMoth
	StartMoth = 2
	NVAR StartDay
	StartDay =20
	NVAR NumOfHours
	NumOfHours=24
	NVAR NumberOfScansToImport
	if(NumberOfScansToImport<10)
		NumberOfScansToImport=1000
		
	endif
//	ListOfStrings="DataMatchString;FolderSortString;FolderSortStringAll;"
//	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
//		SVAR teststr=$(StringFromList(i,ListOfStrings))
//		if(strlen(teststr)<1)
//			teststr =""
//		endif
//	endfor		
//	ListOfStrings="DataStartFolder;"
//	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
//		SVAR teststr=$(StringFromList(i,ListOfStrings))
//		if(strlen(teststr)<1)
//			teststr ="root:"
//		endif
//	endfor		
//	SVAR FolderSortStringAll
//	FolderSortStringAll = "Alphabetical;Reverse Alphabetical;_xyz;_xyz.ext;Reverse _xyz;Reverse _xyz.ext;Sxyz_;Reverse Sxyz_;_xyzmin;_xyzC;_xyzpct;_xyz_000;Reverse _xyz_000;"
//	SVAR DataSubTypeUSAXSList
//	DataSubTypeUSAXSList="DSM_Int;SMR_Int;R_Int;Blank_R_Int;USAXS_PD;Monitor;"
//	SVAR DataSubTypeResultsList
//	DataSubTypeResultsList="Size"
//	SVAR DataSubType
//	DataSubType="DSM_Int"
		

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
								//	TitleBox FakeLine2 title=" ",fixedSize=1,size={330,3},pos={16,428},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	//string UserDataTypes=""
	//string UserNameString=""
	//string XUserLookup=""
	//string EUserLookup=""
	//IR2C_AddDataControls("Irena:MultiSamplePlot","IR3BS_BlueSkyPlotPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1, DoNotAddControls=1)
	Button GetHelp,pos={480,10},size={80,15},fColor=(65535,32768,32768), proc=IR3L_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	//IR3C_MultiAppendControls("Irena:MultiSamplePlot","IR3BS_BlueSkyPlotPanel", "IR3L_DoubleClickAction","",0,1)


	SVAR ListOfCatalogs=root:Packages:Irena:BlueSkySamplePlot:ListOfCatalogs
	SVAR CatalogUsed=root:Packages:Irena:BlueSkySamplePlot:CatalogUsed
	PopupMenu CatalogUsed,pos={20,40},size={310,20},proc=IR3BS_PopMenuProc, title="Select Catalog",help={"Select one of available catalogs"}
	PopupMenu CatalogUsed,value=#"root:Packages:Irena:BlueSkySamplePlot:ListOfCatalogs",mode=1, popvalue=CatalogUsed

	Checkbox AllDates, variable=root:Packages:Irena:BlueSkySamplePlot:AllDates
	CheckBox AllDates title="All data? ",pos={220,42},size={60,14},proc=IR3S_CheckProc
	
	SetVariable NumberOfScansToImport,pos={300,40},size={200,20}, proc=IR3BS_SetVarProc,title="Num of scans:", valueColor=(0,0,0),  limits={10,1000,50}
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
			IN3BS_ImportDataAndPlot(row,0)
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
Function IR3BS_ImportSelected()

	Wave listWave=root:Packages:Irena:BlueSkySamplePlot:PrunedListOfAvailableData
	Wave selWave=root:Packages:Irena:BlueSkySamplePlot:SelectionOfAvailableData
	variable i
	For(i=0;i<dimsize(listWave,0);i+=1)
		if(selWave[i]>0)
			IN3BS_ImportDataAndPlot(i,1)
		endif
	endfor  
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function IN3BS_ImportDataAndPlot(selRow, saveTheData)
	variable selRow, saveTheData
	
	string oldDf
	oldDf = getDataFolder(1)
	//Wave/T IDwave = root:Packages:Irena:BlueSkySamplePlot:IDwave
	Wave/T PrunedListOfAvailableData =  root:Packages:Irena:BlueSkySamplePlot:PrunedListOfAvailableData
	SVAR CatalogUsed=root:Packages:Irena:BlueSkySamplePlot:CatalogUsed
	//http://usaxscontrol:8000/node/full/9idc_usaxs/16248ab5-1359-4242-8ec9-6fd66f8b5976/primary/data?format=json
	
	string TempAddress = ServerAddress+"/api/v1/node/full/"+CatalogUsed+"/"
	TempAddress +=PrunedListOfAvailableData[selRow][2]+"/primary/data?format=json"
	//print TempAddress
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
	//JSONXOP_Dump jsonId
	//print S_Value		//-- prints the file in history and works. 
	wave/T Keys = JSON_GetKeys(jsonID, "")
	if(numpnts(Keys)<2)
		JSONXOP_Release jsonId
		abort "Cannot parse response, server not returning meanigful data yet"
	endif
	string DetKey = Keys[0]
	string XdataKey = Keys[1]
	//wave maxSize=JSON_GetMaxArraySize(jsonID, "/"+DetKey)
	wave DetFree = JSON_GetWave(jsonID, "/"+DetKey)
	wave XdatFree = JSON_GetWave(jsonID, "/"+XdataKey)
	JSONXOP_Release jsonId
	//store data here and do something with them.
	string tempScanName, DateTimeStr
	if(saveTheData)	//store the data
		//create location for the data... 
		tempScanName=PrunedListOfAvailableData[selRow][0]
		DateTimeStr =PrunedListOfAvailableData[selRow][1]
		NewDataFolder/O/S root:ScanData
		NewDataFolder/O/S $(CleanupName(tempScanName+"_"+DateTimeStr, 0))
		Duplicate/O DetFree, Detector
		Duplicate/O XdatFree, Xdata
		setDataFolder oldDf
	else	//just display tyhem without saving
		Duplicate/O DetFree,Detector
		Duplicate/O XdatFree,Xdata
		Killwindow/Z BlueSkyGrpah
		
		//display, for now this is simplistic way
		Display/K=1  Detector vs Xdata as PrunedListOfAvailableData[selRow][1]+"     "+PrunedListOfAvailableData[selRow][0]
		Label bottom XdataKey
		Label left DetKey
		DoWindow/C BlueSkyGrpah
		AutoPositionWindow/R=IR3BS_BlueSkyPlotPanel  BlueSkyGrpah
	endif
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
				IR3BS_ImportSelected()
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
	NVAR NumberOfScansToImport=root:Packages:Irena:BlueSkySamplePlot:NumberOfScansToImport
	if(NumberOfScansToImport>300)
		NumberOfScansToImport=300		//limitation of Tiled 0.1.a80
	endif
	

	//SERVER/node/search/CATALOG?page[offset]=0&filter[time_range][condition][since]=FROM_START_TIME&filter[time_range][condition][until]=BEFORE_END_TIME&sort=time
	variable startTimeSec= date2secs((StartYear), (StartMonth), (StartDay)) - 2082844800	//convert to Python time 
	variable endTimeSec = startTimeSec + NumOfHours*60*60
	string TempAddress = ServerAddress+"/api/v1/node/search/"
	string StartTimeStr, EndTimeStr
	sprintf StartTimeStr, "%.15g" ,startTimeSec
	sprintf EndTimeStr, "%.15g" ,endTimeSec
	
	if(AllDates)
		TempAddress +=CatalogUsed+"?page[offset]=00&page[limit]="+num2str(NumberOfScansToImport)+"&sort=time"
	else
		TempAddress +=CatalogUsed+"?page[offset]=00&page[limit]="+num2str(NumberOfScansToImport)+"&filter[time_range][condition][since]="+StartTimeStr+"&filter[time_range][condition][until]="+EndTimeStr
		TempAddress +="&filter[time_range][condition][timezone]=US/Central&sort=time"
	endif
	//this fails on IP8:
	//TempAddress +=StringFromList(0, ListOfCatalogs)+"?page[offset]=00&page[limit]=1000&filter[time_range][condition][since]="+num2str(startTimeSec, "%.15g")+"&filter[time_range][condition][until]="+num2str(endTimeSec, "%.15g")+"&sort=time"
	// default pagse limit is 100 -  page[offset]=0&page[limit]=1000 loads first 1000 scans. 
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
	//print jsonID
	//JSONXOP_Dump refNumJson
	//print S_Value		-- prints the file in history and works. 

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
		
	//time conversion. Python uses January 1, 1970
	//print/D date2secs(1970,1,1)
	//while Igor is 1904. We need to add :  
  	// date2secs(2022, 02, 20 ) - date2secs(1970,01,01) - Date2secs(-1,-1,-1)

	
	//let's list those which are plan "tune_a2rp"
	variable numDataSets, i, j
	string tempPlanName
	numDataSets = JSON_GetArraySize(jsonID, "/data")
	KillWaves/Z IDwave, PlanNameWave, TimeWave
	make/O/N=(numDataSets)/T IDwave, PlanNameWave
	make/O/N=(numDataSets)/D TimeWave			//must be double precision!
	j=0
	For(i=0;i<numDataSets;i+=1)
		tempAddress = "/data/"+num2str(i)+"/attributes/metadata/start/plan_name"
		tempPlanName = JSON_GetString(jsonID, tempAddress,ignoreErr=1) 
		//if(!StringMatch(tempPlanName, "documentation_run"))
		tempAddress = "/data/"+num2str(i)+"/id"
		IDwave[j] = JSON_GetString(jsonID, tempAddress,ignoreErr=1)
		PlanNameWave[j]=tempPlanName
		tempAddress = "/data/"+num2str(i)+"/attributes/metadata/start/time"
		//print/D JSON_GetVariable(jsonID, tempAddress)
		TimeWave[j] = JSON_GetVariable(jsonID, tempAddress,ignoreErr=1) + date2secs(1970,01,01) + Date2secs(-1,-1,-1)
		j+=1
		//endif
	endfor
	JSONXOP_Release jsonId
	
	//populate listbox
	wave/T ListOfAvailableData = root:Packages:Irena:BlueSkySamplePlot:ListOfAvailableData
	Wave SelectionOfAvailableData = root:Packages:Irena:BlueSkySamplePlot:SelectionOfAvailableData
	redimension/N=(j,3) ListOfAvailableData 
	redimension/N=(j) SelectionOfAvailableData 
	SelectionOfAvailableData = 0
	if(j>0)
		ListOfAvailableData[][0] = PlanNameWave[p]
		ListOfAvailableData[][1] = Secs2Date(TimeWave[p],-2)+"   "+Secs2Time(TimeWave[p],3)
		ListOfAvailableData[][2] = IDwave[p]
	endif
	
	//create list of scans available on server
	SVAR ListOfScanTypes=root:Packages:Irena:BlueSkySamplePlot:ListOfScanTypes
	SVAR ScanTypeToUse=root:Packages:Irena:BlueSkySamplePlot:ScanTypeToUse
	ListOfScanTypes = ""
	ScanTypeToUse = ""
	For(i=0;i<DimSize(ListOfAvailableData,0);i+=1)
		if(!StringMatch(ListOfScanTypes,"*"+ListOfAvailableData[i][0]+";*"))
			ListOfScanTypes +=ListOfAvailableData[i][0]+";"
		endif
	endfor
	if(strlen(ScanTypeToUse)<1 && DimSize(ListOfAvailableData,0)>0)
		ScanTypeToUse = StringFromList(0, ListOfScanTypes)
	endif
	
	IR3BS_UdateListBoxScans()
	
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function IR3BS_UdateListBoxScans()

	//populate listbox
	wave/T ListOfAvailableData = root:Packages:Irena:BlueSkySamplePlot:ListOfAvailableData
	Wave/T PrunedListOfAvailableData  =root:Packages:Irena:BlueSkySamplePlot:PrunedListOfAvailableData
	redimension/N=(0,3) PrunedListOfAvailableData
	Wave SelectionOfAvailableData = root:Packages:Irena:BlueSkySamplePlot:SelectionOfAvailableData
	//create list of scans available on server
	SVAR ListOfScanTypes=root:Packages:Irena:BlueSkySamplePlot:ListOfScanTypes
	SVAR ScanTypeToUse=root:Packages:Irena:BlueSkySamplePlot:ScanTypeToUse

	Grep /A /E=(ScanTypeToUse)/GCOL=0  ListOfAvailableData as PrunedListOfAvailableData
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
				IR3BS_GetJSONScanData()
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
//working with `http://usaxscontrol:8000`, calling this SERVER
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
