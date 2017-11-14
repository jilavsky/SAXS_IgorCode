#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=2		// Use modern global access method.
#pragma IgorVersion = 4.0
#pragma version = 2.2
#pragma ModuleName=specProc
//#include "Utility_JZT"

Constant Epoch_spec_Igor = 2082844800			// add this number of spec EPOCH to get Igor EPOCH, i.e. print Secs2Date(EPOCH+Epoch_spec_Igor,1)
                                                                             //Secs2time(EPOCH+Epoch_spec_Igor-3600*5,1)  Will give time using Central US Time

// written by Jon Tischler.
// last modified October 16, 2003
//		with thanks to Jan Ilavsky and Andrei Tkachuk for comments & bug reports
//
// For users who wish to include additional information from the data file in
// igor, create a macro named "extraSpecRead".  An example is in "specMore.ipf"
//	 with vers 2.8, these can now be functions or macros
//
//  some values are in keyed strings (specMotors & EPICS_PVs)
//  they can be retrieved by using lines like:
//		print NumberByKey("Gamma", specMotors)			Gamma, gamma, or GAMMA all work
// or		print NumberByKey("DCM_energy", EPICS_PVs)
//  of course, the best way is to just use the specInfo(scanNum,key) or specInfoT(scanNum,key)
//
//	Feb 22, 2004, changed specXwave & specYwave to xAxisName & yAxisName
//			note that yAxisName & AxisName can be ";" separated lists, but multi-wave
//			plotting is not yet supported
//
//	Jun 26, 2004, added support for the use of an mca style dump of one variable


Menu "Data"
	"-"
	Submenu "spec"
		"List all scans from a file",  List_spec_Scans("","","")
		help = {"Open a spec file and list info about each scan."}
		"Display range of scans, maybe load too", DisplayRangeOfSpecScans("","","","")
		help = {"Display a range of spec scans.  If scan not in Igor, then first load the data."}
		"Display one scan, maybe load too", Display_any_spec_Scan(0,"","","")
		help = {"Display a spec scan.  If scan not in Igor, then first load the data."}
		"FTP data from unix", FTPdata("")
		help = {"FTP data from UNIX server"}
		"Get info about a loaded scan", specInformation(0)
		help = {"print information about a loaded spec scan."}
		"read in a scan", specRead("",NaN,"")
		help = {"Read a spec scan from a file and store in current datafolder."}
	End
End
Menu "Load Waves"
	"Load range of 'spec' Scans", LoadRangeOfSpecScans("","","")
	help = {"Read a range of spec scans from a file and store in current datafolder."}
	"Load one 'spec' Scan", specRead("",NaN,"")
	help = {"Read one spec scan from a file and store in current datafolder."}
	"Display range of scans, maybe load too", DisplayRangeOfSpecScans("","","","")
	help = {"Display many spec scans.  If scan not in Igor, then first load the data."}
	"Display a scan, maybe load too", Display_any_spec_Scan(0,"","","")
	help = {"Display a spec scan.  If scan not in Igor, then first load the data."}
	"FTP data from unix", FTPdata("")
	help = {"FTP data from UNIX server"}
End


Function DisplayRangeOfSpecScans(range,fileName,path,overlay)
	// Calls the correct routine to display many types of scans.
	// It also will read in the data if necessary
	// it returns number of scans processed, or 0 if failed
	String range								// range of spec scans, ie "3-7,11,13,17-20"
	String fileName
	String path
	String overlay

	specInitPackage()						// create Packages:spec folder
	if (strlen(range)<1 || (cmpstr(overlay,"new") && cmpstr(overlay,"append")))
		if (cmpstr(overlay,"append"))
			overlay="new"
		endif
		if (strlen(fileName)<1)
			fileName=StrVarOrDefault("root:Packages:spec:specDefaultFile","")
		endif

		if (strlen(path)<1)
			path=StrVarOrDefault("root:Packages:spec:specDefaultPath","raw")
		endif
		Prompt range, "range of scans to show, use '-' and ','"
		Prompt fileName, "name of file"
		Prompt path, "path for raw data", popup, PathList("*", ";", "")
		Prompt overlay, "new plot", popup "new;append;"
		DoPrompt "display a scan", range,fileName,path,overlay
		if (V_flag)							// cancelled
			return 0
		endif
	endif
	if (strlen(range)<1)
		DoAlert 0, "no scan range given, nothing done"
		return 0
	endif

	range = expandRange(range)
	Variable N=ItemsInList(range)

	// check if all have been already read in
	Variable allIn=1
	Variable i
	for (i=0;i<N;i+=1)
		if (!cmpstr(Find_specDataFolder(str2num(StringFromList(i,range))),"bad dir"))	// not loaded
			allIn = 0
			break
		endif
	endfor
	String scanList=""
	if (!allIn)				// everything is already read in
		scanList = specScansList(fileName,path,"all")
		fileName=StrVarOrDefault("root:Packages:spec:specDefaultFile","")
		// check that all of the scans are in the file, or loaded
		if (char2num(scanList[0])!=char2num(";"))	// ensure a leading ';'
			scanList = ";"+scanList
		endif

		// check each item in range, to see if it is also in scanList, or loaded
		String scan
		Variable sn
		for (i=0;i<N;i+=1)
			scan = StringFromList(i,range)
			sn = str2num(scan)
			if (strsearch(scanList,";"+scan+" ",0 )<0 && !cmpstr(Find_specDataFolder(sn),"bad dir"))	// not loaded or in file
				DoAlert 0, "scan "+scan+" not found in file "+fileName+"   and not loaded"
				return 0
			endif
		endfor
		// everything in range is in the file
	endif

	String overlay0=overlay, overlay_i
	if (strlen(WinList("*","","WIN:1"))==0 && stringmatch(overlay,"append"))
		overlay0 = "new"
//		Display
	endif
	Variable j0,j1
	for (i=0;i<N;i+=1)							// now process each of the scans in the list
		overlay_i = SelectString(i,overlay0,overlay)
		sn = str2num(StringFromList(i,range))
		j0 = strsearch(scanList,";"+StringFromList(i,range)+" ",0 )+1
		j1 = strsearch(scanList,";",j0)-1		// scanList[j0,j1] contains the name
		if (strsearch(scanList[j0,j1],"laserscan",0 )>=0)	// a laserscan, special
			String str
			sprintf str, "Fix_LoadLaserScan(%d,\"%s\",\"%s\",\"%s\")" ,sn,fileName,path,overlay_i
			Execute str							// Fix_LoadLaserScan(scanNum,fileName,path)
		else
			if (!cmpstr(Find_specDataFolder(sn),"bad dir"))	// data folder does not exist, read it
				specRead(fileName,sn,path)
			endif
			DisplaySpecScan(sn,overlay_i)		// a default spec scan types
		endif

	endfor
	return N
End



Function Display_any_spec_Scan(scanNum,fileName,path,overlay)
	// Calls the correct routine to display many types of scans.
	// It also will read in the data if necessary
	// it return scan number displayed (0 if failed)
	Variable scanNum							// spec scan number
	String fileName
	String path
	String overlay

	specInitPackage()						// create Packages:spec folder
	Prompt scanNum, "scan number (if < 1, you will get a list choices)"
	Prompt fileName, "name of file"
	Prompt path, "path for raw data", popup, PathList("*", ";", "")
	Prompt overlay, "new plot", popup "new;append;"
	if (scanNum<1 || (cmpstr(overlay,"new") && cmpstr(overlay,"append")))
		scanNum = numtype(scanNum) ? 0 : scanNum
		if (cmpstr(overlay,"append"))
			overlay="new"
		endif
		if (strlen(fileName)<1)
			fileName=StrVarOrDefault("root:Packages:spec:specDefaultFile","")
		endif

		if (strlen(path)<1)
			path=StrVarOrDefault("root:Packages:spec:specDefaultPath","raw")
		endif
		DoPrompt "display a scan", scanNum,fileName,path,overlay
		if (V_flag)							// cancelled
			return 0
		endif
	endif

	String scanList = specScansList(fileName,path,"all")
	fileName=StrVarOrDefault("root:Packages:spec:specDefaultFile","")
	Variable N=ItemsInList(scanList)
	Variable i

	if (scanNum<1)							// put up the pop-up menus
		String tempA__list_ = prefixChooseScans(specScansList(fileName,path,"ascan"))
		String tempB__list_ = prefixChooseScans(specScansList(fileName,path,"hklscan"))
		String tempC__list_ = prefixChooseScans(specScansList(fileName,path,"tscan"))
		String tempD__list_ = prefixChooseScans(specScansList(fileName,path,"laserscan"))
		String tempE__list_ = prefixChooseScans(specScansList(fileName,path,"slewscan"))
		String tempF__list_ = prefixChooseScans(specScansList(fileName,path,"Escan"))
		if (strlen(tempF__list_)==1)
			tempF__list_ = ""
		endif
		tempF__list_ += prefixChooseScans(specScansList(fileName,path,"eVscan"))
		String tempG__list_ = prefixChooseScans(specScansList(fileName,path,"shootCCD"))

		// and other
		String tempO__list_ = scanList
		String str
		Variable ii
		i = 0
		do
			str = StringFromList(i, tempA__list_ )
			ii = WhichListItem(str , tempO__list_ )
			tempO__list_ = RemoveListItem(ii, tempO__list_)
			i += 1
		while (strlen(str)>0)
		i = 0
		do
			str = StringFromList(i, tempB__list_ )
			ii = WhichListItem(str , tempO__list_ )
			tempO__list_ = RemoveListItem(ii, tempO__list_)
			i += 1
		while (strlen(str)>0)
		i = 0
		do
			str = StringFromList(i, tempC__list_ )
			ii = WhichListItem(str , tempO__list_ )
			tempO__list_ = RemoveListItem(ii, tempO__list_)
			i += 1
		while (strlen(str)>0)
		i = 0
		do
			str = StringFromList(i, tempD__list_ )
			ii = WhichListItem(str , tempO__list_ )
			tempO__list_ = RemoveListItem(ii, tempO__list_)
			i += 1
		while (strlen(str)>0)
		i = 0
		do
			str = StringFromList(i, tempE__list_ )
			ii = WhichListItem(str , tempO__list_ )
			tempO__list_ = RemoveListItem(ii, tempO__list_)
			i += 1
		while (strlen(str)>0)
		i = 0
		do
			str = StringFromList(i, tempF__list_ )
			ii = WhichListItem(str , tempO__list_ )
			tempO__list_ = RemoveListItem(ii, tempO__list_)
			i += 1
		while (strlen(str)>0)
		i = 0
		do
			str = StringFromList(i, tempG__list_ )
			ii = WhichListItem(str , tempO__list_ )
			tempO__list_ = RemoveListItem(ii, tempO__list_)
			i += 1
		while (strlen(str)>0)
		tempO__list_ = prefixChooseScans(tempO__list_)

		Variable sA,sB,sC,sD,sE,sF,sG,sO
		Prompt sA,"ascan", popup, tempA__list_
		Prompt sB,"hklscan", popup, tempB__list_
		Prompt sC,"tscan", popup, tempC__list_
		Prompt sD,"laserscan", popup, tempD__list_
		Prompt sE,"slewscan", popup, tempE__list_
		Prompt sF,"energy_scans", popup, tempF__list_
		Prompt sG,"CCD scans", popup, tempG__list_
		Prompt sO,"other scans", popup, tempO__list_
		DoPrompt "pick scan",sA,sB,sC,sD,sE,sF,sG,sO
		if (V_flag)							// cancelled
			return 0
		endif
		do					// pick the first if that works
		if (sA>1)
			tempA__list_ = StringFromList(sA-1, tempA__list_ )
			break
		endif
		if (sB>1)
			tempA__list_ = StringFromList(sB-1, tempB__list_ )
			break
		endif
		if (sC>1)
			tempA__list_ = StringFromList(sC-1, tempC__list_ )
			break
		endif
		if (sD>1)
			tempA__list_ = StringFromList(sD-1, tempD__list_ )
			break
		endif
		if (sE>1)
			tempA__list_ = StringFromList(sE-1, tempE__list_ )
			break
		endif
		if (sF>1)
			tempA__list_ = StringFromList(sF-1, tempF__list_ )
			break
		endif
		if (sG>1)
			tempA__list_ = StringFromList(sG-1, tempG__list_ )
			break
		endif
		if (sO>1)
			tempA__list_ = StringFromList(sO-1, tempO__list_ )
			break
		endif
		tempA__list_ = ""
		while(0)
		scanNum = str2num(tempA__list_)
	endif
	if (scanNum<1)							// no scan selected
		return 0
	endif

	String scan
	i = 0
	do
		scan = StringFromList(i, scanList)
		if (str2num(scan)==scanNum)
			break
		endif
		i += 1
	while (i<=N)
	if (i>N)
		return 0							// did not find scan number
	endif

	if (strsearch(scan,"laserscan",0)>=0)
		sprintf str, "Fix_LoadLaserScan(%d,\"%s\",\"%s\",\"%s\")" ,scanNum,fileName,path,overlay
		Execute str							// Fix_LoadLaserScan(scanNum,fileName,path)
		return scanNum
	endif
	DisplaySpecScan(scanNum,overlay)		// for default spec scan types
	return scanNum
EndMacro
Function/T prefixChooseScans(str)
	String str
	if (strlen(str))
		str = "-choose-;"+str
	else
		str = "-"
	endif
	return str
End



Function DisplaySpecScan(scanNum,overlay)
	Variable scanNum
	String overlay											// ="new"
	Variable interactive=0
	
//----------------------added Andrei Tkachuk Oct18, 2003	
	Variable oldPrefState
	Preferences 1; oldPrefState=V_flag		// remember prefs setting      
//---------------------------------------------------------------		

	specInitPackage()										// create Packages:spec folder
	if (scanNum<1 || (cmpstr(overlay,"new") && cmpstr(overlay,"append")))
		Prompt scanNum, "scan number"
		Prompt overlay, "new plot", popup "new;append;"
		scanNum = (scanNum>0) ? scanNum : NumVarOrDefault("root:Packages:spec:lastScan", 0)+1
		if (cmpstr(overlay,"append"))
			overlay="new"
		endif
		DoPrompt "choose a scan", scanNum, overlay
		if (V_flag)
			return 0
		endif
		interactive = 1
	endif

	String fldrSav=GetDataFolder(1)
	String folderName = Find_specDataFolder(scanNum)	// get the folder for the spec scan
	if (!cmpstr(folderName,"bad dir"))					// data folder does not exist
		folderName = ":spec"+num2istr(scanNum)			// set folderName for readin
		if (!cmpstr("spec"+num2istr(scanNum),GetDataFolder(0)))	// already there
			folderName = ":"
		endif
	endif

	if (DataFolderExists(folderName)==0)					// data is not there, ask to read it in
		V_flag=1
		if (interactive)
			DoAlert 1, "data not found, read it in?"
		endif
		if (V_Flag==1)
			V_Flag = 0
			specRead("",scanNum,"")
			if (V_flag)
				Abort "specRead failed"
			endif
		else
			DoAlert 0, "data not found, nothing done"
		endif
	endif

	SetDataFolder folderName

	String list = WaveList("*", ",", "")
	Variable n = ItemsInList(list,",")-1
	String xname = StringFromList(0,list,",")
	String yname = StringFromList(n,list,",")
	if ((cmpstr("I0",yname)==0) && (n>=2))
		yname = StringFromList(n-1,list, ",")
	endif

//	Feb 22, 2004, changed specXwave & specYwave to xAxisName & yAxisName
	xname = StrVarOrDefault("xAxisName",xname)
	yname = StrVarOrDefault("yAxisName",yname)
	if (!strlen(xname+yname))
		xname = StrVarOrDefault("specXwave",xname)	// these two lines left in for
		yname = StrVarOrDefault("specYwave",yname)	// backwards compatibility
	endif
	xname = StringFromList(0,xname)			// only support one x wave here
	yname = StringFromList(0,yname)			// only support one y wave here
	String yerrName = yname+"_err"

	if (cmpstr("append",overlay)==0)
		if (exists(xname)!=1)
			AppendToGraph $yname
		else
			AppendToGraph $yname vs $xname
		endif
		if (exists(yerrName)==1)
			ErrorBars $yname Y,wave=($yerrName,$yerrName)
		endif
		SetDataFolder fldrSav
		return 0
	endif

	if (exists(xname)!=1)
		Display $yname
	else
		Display $yname vs $xname
	endif
	String gname="Graph_"+num2istr(scanNum)
	if (!exists(gname) && strlen(WinList(gname,"",""))<1)
		DoWindow/C $gname
	endif
	if (exists(yerrName)==1)
		ErrorBars $yname Y,wave=($yerrName,$yerrName)
	endif
	String text2write = "\Z14\[0"
	text2write += GetWavesDataFolder(WaveRefIndexed(winname (0,1),0,1),0)
	if (exists(":specComment"))
		SVAR specComment=:specComment
		text2write += ",  "+specComment
	endif
	String OrigFile = StringByKey("DATAFILE",note($yname),"=")
	if (strlen(OrigFile)>0)
		text2write += "\r\Z09"+OrigFile+"\M"
	endif
	if (exists(":timeWritten"))
		SVAR timeWritten=:timeWritten
		text2write += "\r\Z09"+timeWritten+"\M"
	endif
	if (exists(":specCommand"))
		SVAR specCommand=:specCommand
		text2write += "\r\Z09"+specCommand+"\M"
	endif
//	Variable showXunits = (strlen(WaveUnits($xname,1))>0) - 1
	Variable showXunits = -1
	if (exists(xname)==1)
		showXunits = (strlen(WaveUnits($xname,1))>0) - 1
		showXunits = cmpstr(WaveUnits($xname,1),"°") ? showXunits : 1
	endif
	Variable showYunits = (strlen(WaveUnits($yname,1))>0)

	SetDataFolder fldrSav
	if (cmpstr(yname,"I00")==0)
		yname = "I\\Boo\M"
	endif
	if (cmpstr(yname,"I0")==0 || cmpstr(yname,"Monitor")==0)
		yname = "I\\Bo\M"
	endif
	Label left yname + SelectString(showYunits," \\E","  (\\U)")
	if (cmpstr(xname,"ttheta")==0 || cmpstr(xname,"Two_Theta")==0 || cmpstr(xname,"2theta")==0)
		xname = "2\\F'Symbol'θ\\]0"
	endif
	if (cmpstr(xname,"Time_")==0)
		xname = "time"
	endif
	xname = WordToGreek(xname)		// substitute Igor greek for name of greek letter
	Label bottom xname + SelectString(showXunits," \\E","  (\\U)","\\U")
	SetAxis/A/E=1 left
	Variable i = exists("specGraphGenericStyle")
	if (i==5 || i==6)								// if macro or userfunc exists, fix up plot
		Execute "specGraphGenericStyle()"
	elseif (exists("JonsStyle_")==5)				// if macro exists, fix up plot
		Execute "JonsStyle_()"
	endif
	Textbox/F=0/S=3/A=LT/B=1 text2write
	i = exists("addMoreAnnotation2specPlot")
	if (i==5 || i==6)
		Execute "addMoreAnnotation2specPlot("+num2istr(scanNum)+")"
	endif

	NVAR lastScan=root:Packages:spec:lastScan
	lastScan = scanNum
//----------------------added Andrei Tkachuk Oct18, 2003		
	Preferences oldPrefState		// put prefs back, like a macro would
//------------------------------------------------	

End





Function LoadRangeOfSpecScans(range,fileName,path)
	// load a range of spec scans
	// it returns number of scans processed, or 0 if failed
	String range								// range of spec scans, ie "3-7,11,13,17-20"
	String fileName
	String path

	specInitPackage()						// create Packages:spec folder
	if (strlen(range)<1)
		if (strlen(fileName)<1)
			fileName=StrVarOrDefault("root:Packages:spec:specDefaultFile","")
		endif
		if (strlen(path)<1)
			path=StrVarOrDefault("root:Packages:spec:specDefaultPath","raw")
		endif
		Prompt range, "range of scans to show, use '-' and ','"
		Prompt fileName, "name of file"
		Prompt path, "path for raw data", popup, PathList("*", ";", "")
		DoPrompt "display a scan", range,fileName,path
		if (V_flag)							// cancelled
			return 0
		endif
	endif
	if (strlen(range)<1)
		DoAlert 0, "no scan range given, nothing done"
		return 0
	endif

	range = expandRange(range)
	String scanList = specScansList(fileName,path,"all")
	fileName=StrVarOrDefault("root:Packages:spec:specDefaultFile","")
	Variable N=ItemsInList(range)
	String scan
	Variable i

	// check that all of the scans are in the file
	if (char2num(scanList[0])!=char2num(";"))	// no leading ';'
		scanList = ";"+scanList
	endif
	for (i=0;i<N;i+=1)						// check each item in range, to see if it is also in scanList
		scan = StringFromList(i,range)
		if (strsearch(scanList,";"+scan+" ",0 )<0)
			DoAlert 0, "scan "+scan+" not found in file "+fileName
			return 0
		endif
	endfor
	// everything in range is in the file

	for (i=0;i<N;i+=1)						// now process each of the scans in the list
		specRead(fileName,str2num(StringFromList(i,range)),path)
	endfor
	return N
End


Function specRead(fileName,scanNum,path)
		// read in data from a spec data file
		// scanNum must be >= 1.
		// the global variable V_flag is no longer set, error codes are returned
		// as arguments.  The values are:
		//		
		//		0=(no error)
		//		1=(scan number cannot be < 1)
		//		2=(the data folder already exists)
		//		3=(Scan not found)
		//		4=(file position given, but it is not start of scan!)
		//		5=file reference is invalid
		//
		// For users who wish to include additional information from the data
		// file in igor, create a macro named "extraSpecRead".  An example is
		// in "specMore.ipf"
	String fileName
	Variable scanNum
	String path

	Prompt fileName, "name of file"
	Prompt scanNum, "scan number"
	Prompt path, "path for raw data", popup, PathList("*", ";", "")

	Variable promptUser=0
	if (strlen(fileName)<1)
		promptUser += 1
		fileName=StrVarOrDefault("root:Packages:spec:specDefaultFile","")
	endif
	if (numtype(scanNum) || scanNum<1)
		scanNum=NumVarOrDefault("root:Packages:spec:lastScan", 0)+1
		promptUser += 2
	endif
	if (strlen(path)<1)
		promptUser += 4
		path=StrVarOrDefault("root:Packages:spec:specDefaultPath","home")
	endif
	Variable V_flag=0
	switch(promptUser)					// prompt for needed items
		case 0:							// no prompt needed
			break
		case 1:
			DoPrompt "read in a spec scan", fileName
			break
		case 2:
			DoPrompt "read in a spec scan", scanNum
			break
		case 3:
			DoPrompt "read in a spec scan", fileName, scanNum
			break
		case 4:
			DoPrompt "read in a spec scan", path
			break
		case 5:
			DoPrompt "read in a spec scan", fileName, path
			break
		case 6:
			DoPrompt "read in a spec scan", scanNum, path
			break
		default:							// just prompt for everything
			DoPrompt "read in a spec scan", fileName, scanNum, path
			break
	endswitch
	if (V_flag)							// cancelled after prompt
		return 0
	endif

	Variable fileVar						// file ref number
	String line							// line of input from file
	Variable i
	String str=""
	Variable err_flag = 0				// set to no error

	String fldrSav= GetDataFolder(1)
	if (scanNum<1)
		Print "scan number cannot < 1"
		return 0
	endif
	specInitPackage()					// create Packages:spec folder
	String S_fileName

//	Open /R/T="TEXT"/P=$path/M="spec data file"/Z fileVar as fileName
	Open /Z/R/P=$path/M="spec data file" fileVar as fileName
	if (V_flag)
//		Open /R/T="TEXT"/M="spec data file" fileVar as fileName
		Open /R/M="spec data file" fileVar as fileName
	endif
	FStatus(fileVar)

	SVAR DefaultFile=root:Packages:spec:specDefaultFile
	SVAR DefaultPath=root:Packages:spec:specDefaultPath
	DefaultFile = SelectString(strlen(StringByKey("PATH",S_info)),S_path+S_fileName,S_fileName)
	DefaultPath = path

	check_fileID(fileVar)				// update specScanPositions if needed
	SVAR specScanPositions=root:Packages:spec:specScanPositions
	NVAR firstScanNumInFile=root:Packages:spec:firstScanNumInFile
	V_filepos = str2num(StringFromList(scanNum-firstScanNumInFile,specScanPositions))
	if (numtype(V_filepos))
		Close fileVar
		Print "Scan not found"
		return 3
	endif
	FSetPos fileVar, V_filepos			// reset file position to previous position

	err_flag = specReadFromSline(fileVar,V_filePos)	// now read in the data

	SetDataFolder fldrSav
	Close fileVar

	switch(err_flag)						// select response to error code
		case 2:
			Print "the data folder already exists"
			break
		case 4:
			Print "File position given, but it is not the start a of scan!"
			break
		case 5:
			Print "File reference is invalid"
			break
	endswitch
	return err_flag
End


Function specReadFromSline(fileVar,FilePosScan)
		// actually reads in a scan from a spec data file
		// FilePosScan is the position in the file of the start of the spec scan (begining of #S line)
		// if FilePosScan==0, then assume that file is already positioned at start of scan
		// the global V_flag is NO LONGER set, use the returned value
		//		
		//		0=(no error)
		//		1=(scan number cannot be 0)
		//		2=(the data folder already exists)
		//		3=(Scan not found)
		//		4=(file position given, but it is not start of scan!)
		//		5=file reference is invalid
		//
		// For users who wish to include additional information from the data
		// file in igor, create a macro named "extraSpecRead".  An example is
		// in "specMore.ipf"
	Variable fileVar			// file ref number
	Variable FilePosScan	// position in file should be positioned at #S

	Variable scanNum			// spec scan number
	String line				// line of input from file
	String line1,line2
	String hunt				// string to hunt for
	Variable i
	Variable newHeader		// flags need to recheck the file header
	String str=""

	FStatus fileVar								// find out where file is now
	if (V_Flag==0)								// fileVar is invalid
		return 5
	endif
	Variable FilePos = V_filePos
	Variable FilePosStart = V_filePos			// position when this routine entered

	String fldrSav= GetDataFolder(1)
	if (FilePosScan<1)
		FilePosScan = V_filePos					// since FilePosScan<1, assume already at start of scan
	endif

	// file header stuff starts here
	FSetPos fileVar, 0							// reset file position to start of header
	Wave/T angleNames=root:Packages:spec:angleNames
	Wave/T EPICSnames=root:Packages:spec:EPICSnames
	Variable epoch, TZ
	String dataNote=""							// wave note for the scan data put into waves
	String wnote=check_fileID(fileVar)			// desired wavenote for identification purposes
	epoch = NumberByKey("epoch",wnote,"=",";")	// the epoch is already in wnote
	str = StringByKey("origFile",wnote,"=",";")// the original filename is already in wnote
	if (strlen(str)>1)
		str = ChangePartsOfString(str,"=","/") 	// ensure no "=" in file name
		dataNote = "DATAFILE="+ str+";"		// add original file name to data wave note
	endif
	if (numtype(epoch)==0)
		dataNote += "EPOCH="+ num2istr(epoch)+";" // add epoch of data file to data wave note
	endif
	TZ = NumberByKey("TZ",wnote,"=",";")	// the Time Zone is already in wnote
	if (numtype(TZ)==0)
		dataNote += "TZ="+ num2str(TZ)+";" 	// add time zone of data file to data wave note
	endif
	if (WaveExists(angleNames))				// check to see if angleNames is up to date
		i = strlen(wnote)
		str = note(angleNames)
		newHeader = newHeader || cmpstr(wnote,str[0,i-1])
	else
		newHeader = 1
	endif
	if (WaveExists(EPICSnames))				// check to see if EPICSnames is up to date
		i = strlen(wnote)
		str = note(EPICSnames)
		newHeader = newHeader || cmpstr(wnote,str[0,i-1])
	else
		newHeader = 1
	endif

	if (newHeader)
		FSetPos fileVar, 0						// reset file position to start of header
		Variable NangleNames=0					// number of #O lines that contain spec motor names
		do											// save names of spec motors listed in #On lines
			hunt = "#O"+num2istr(NangleNames)+" "
			line1 = FindDataLineType(fileVar,hunt,1)
			if (strlen(line1)>2)
				if (NangleNames==0)
					Make/N=1/O/T root:Packages:spec:angleNames	// each line is a list of motors names
					Note angleNames, wnote
				endif
				Redimension/N=(NangleNames+1) angleNames
				angleNames[NangleNames] = line1[strlen(hunt),inf]
				NangleNames += 1
			endif
				FSetPos fileVar, 0				// reset file position to start of header
		while(strlen(line1)>2)

		Variable NEPICSnames=0					// number of #H lines that contain EPICS PV names
		do											// save names of EPICS PV's listed in #Hn lines
			hunt = "#H"+num2istr(NEPICSnames)+" "
			line1 = FindDataLineType(fileVar,hunt,1)
			if (strlen(line1)>2)
				if (NEPICSnames==0)
					Make/N=1/O/T root:Packages:spec:EPICSnames	// each line is a list of motors names
					Note EPICSnames, wnote
				endif
				Redimension/N=(NEPICSnames+1) EPICSnames
				EPICSnames[NEPICSnames] = line1[strlen(hunt),inf]
				NEPICSnames += 1
			endif
			FSetPos fileVar, 0					// reset file position to start of header
		while(strlen(line1)>2)

	endif
	// end of file header stuff

	FSetPos fileVar, FilePosScan				// set file position to start of scan
	FReadLine fileVar, line
	if (cmpstr(line[0,1],"#S"))				// we are not at start of scan, ERROR
		SetDataFolder fldrSav
		FSetPos fileVar, FilePosStart			// reset file position to original position
		return 4
	endif
	scanNum = str2num(line[2,20]	)			// set scanNum to the scan number
	dataNote += "SCAN_N="+ num2istr(scanNum)+";" // add scan number to data wave note

	FStatus fileVar								// this section special for reading #P0
	FilePos = V_filePos							// FilePos is the beginning ot this scan

	String folderName = "spec"+num2istr(scanNum)
	if (DataFolderExists(folderName))
		SetDataFolder fldrSav
		FSetPos fileVar, FilePosStart			// reset file position to original position
		return 2
	endif
	NewDataFolder /S $folderName
	SVAR specDataFolder = root:Packages:spec:specDataFolder
	specDataFolder = GetDataFolder(1)			// this is the folder to realy save
	Variable i1
	i = 0
	do
		i1 = i
		i = strsearch(specDataFolder,":",i1+1)
	while(i>0 && i<(strlen(specDataFolder)-1))
	i1 = (i1==0) ? strlen(specDataFolder)-1 : i1
	specDataFolder = specDataFolder[0,i1]		// this is now the folder one up from where we are
	line = ZapControlCodes(line)					// write spec command line
	i = strsearch(line," ",3)+1
	line = TrimLeadingWhiteSpace(line[i,inf])	// remove '#S ' and any other white space
	if (strlen(line)>2)
		String/G specCommand = line
	endif

	line1 = FindDataLineType(fileVar,"#D ",1) // write date data taken
	line1 = ZapControlCodes(line1)
	if (strlen(line1)>2)
		i = specDate2seconds(line1)
		if (numtype(i)==0)
			dataNote += "SECONDS="+ num2istr(i)+";"	// add igor seconds when data measuredd to data wave note
			dataNote += "DATE="+Secs2Date(i,2)+";"	// add date-time data measuredd to data wave note
			dataNote += "HOUR="+Secs2Time(i,3)+";"	// add time of day for scan, in 24hr format (No AM or PM)
		endif
		line1 = line1[3,inf]
		String/G timeWritten = line1[4,inf]
	endif
	FSetPos fileVar, FilePos					// reset file position to start of scan

	i=0
	do
		line1 = FindDataLineType(fileVar,"#C ",1) // write any comment lines
		line1 = ZapControlCodes(line1)
		if (strlen(line1)>2)
			str = "specComment"
			if (i>0)
				str += num2istr(i)
			endif
			String/G $str = line1[3,inf]		// remove leading "#C "

			dataNote += "COMMENT"				// add comments to data wave note
			if (i>0)
				dataNote += num2istr(i)
			endif
			line1 = ChangePartsOfString(line1,"=","_") // ensure no "=" in comment
			line1 = ChangePartsOfString(line1,";","_") // ensure no ";" in comment
			dataNote += "="+ line1[3,inf] +";"
		endif
		i += 1
	while (strlen(line1)>2)
	FSetPos fileVar, FilePos					// reset file position to start of scan

	line1 = FindDataLineType(fileVar,"#Q ",1)
	if (strlen(line1)>2)
		line1 = line1[strlen("#Q "),inf]
		SetValuesIntoList("H  K  L",line1,"specValues")
	endif
	FSetPos fileVar, FilePos					// reset file position to start of scan

	line1 = FindDataLineType(fileVar,"#G1 ",1)
	if (strlen(line1)>2)
		line1 = line1[strlen("#G1 "),inf]
		line2 = "a_lat  b_lat  c_lat  alpha_lat  beta_lat  gamma_lat"
		line2 += "  a_recip  b_recip  c_recip  alpha_recip  beta_recip  gamma_recip"
		line2 += "  H0  K0  L0  H1  K1  L1"
		SetValuesIntoList(line2,line1,"specValues")
	endif
	FSetPos fileVar, FilePos					// reset file position to start of scan

	if  (exists("specValues")==2 && !numtype(TZ))
		SVAR specValues=specValues				// add the time zone to the specValues too
		specValues = ReplaceNumberByKey("TZ",specValues,TZ)
	endif

	line1 = FindDataLineType(fileVar,"#I ",1)	// write any ? line
	if (strlen(line1)>2)
		line1 = line1[3,inf]
		SetBValues("I_factor",line1)
	endif
	FSetPos fileVar, FilePos					// reset file position to start of scan

	NangleNames = numpnts(angleNames)
	i = 0
	do												// save the spec motors
		hunt = "#P"+num2istr(i)+" "
		line1 = FindDataLineType(fileVar,hunt,1)
		if (strlen(line1)>2)
			line1 = line1[strlen(hunt),inf]
			SetValuesIntoList(angleNames[i],line1,"specMotors")
		endif
		i += 1
	while(i<NangleNames)
	FSetPos fileVar, FilePos					// reset file position to start of scan

	NEPICSnames = numpnts(EPICSnames)
	i = 0
	do												// save the EPICS PV's
		hunt = "#V"+num2istr(i)+" "
		line1 = FindDataLineType(fileVar,hunt,1)
		if (strlen(line1)>2)
			line1 = line1[strlen(hunt),inf]
			if ((epoch<963300000) && (i==39))	// used to fix old bug
				line1 = line1[1,inf]
			endif
			SetValuesIntoList(EPICSnames[i],line1,"EPICS_PVs")
		endif
		i += 1
	while(i<NEPICSnames)
	FSetPos fileVar, FilePos					// reset file position to start of scan

	line1 = FindDataLineType(fileVar,"#BL ",1)	// write any ?? lines
	if (strlen(line1)>2)
		line1 = line1[4,inf]
		line2 = FindDataLineType(fileVar,"#B ",1)
		line2=line2[3,inf]
		SetBValues(line1,line2)
	endif
	FSetPos fileVar, FilePos					// reset file position to start of scan

	i = exists("extraSpecRead")
	if (i==5 || i==6)							// if macro or userfunc exists, write more user specified lines
		sprintf str, "extraSpecRead(%ld)" ,fileVar
		Execute str								// extraSpecRead(fileVar)
	endif

	FSetPos fileVar, FilePos					// reset file position to start of scan
	line = FindDataStart(fileVar)				// find start of data in the scan
	line = line[3,inf]							// trim off the "#L "

	line = ReduceSpaceRunsInString(line,2)
	line = ChangePartsOfString(line,"  ",";")
	line = ChangePartsOfString(line," ","_")// change remaining spaces to "_"

	line += ";"
	line = ZapControlCodes(line)

	i = 0
	String name=""
	String nameList=""
	do											// ensure that all waves are valid Igor names
		name = StringFromList(i,line, ";")
		if (strlen(name)>0)
			nameList += ValidIgorWaveName(name)+";"
		endif
		i += 1
	while (strlen(name)>0)
//	Feb 22, 2004, changed specXwave & specYwave to xAxisName & yAxisName
//	String/G specXwave=StringFromList(0, nameList)	// useful for plotting the data
//	String/G specYwave=StringFromList(ItemsInList(nameList)-1, nameList)
	String/G xAxisName=StringFromList(0, nameList)	// useful for plotting the data
	String/G yAxisName=StringFromList(ItemsInList(nameList)-1, nameList)
	if (ItemsInList(nameList)==1)
		xAxisName = ""
	endif

	printf "#%d   %s",scanNum,nameList
	FStatus fileVar									// save current position in file
	if (itemsInList(nameList)==1)
		i = Read1DataBlock(fileVar,StringFromList(0,nameList))
	else
		i = ReadDataColumns(fileVar,nameList)
	endif

	// correct for wrapping in the seconds counter (negative seconds are when more than 2^31 clocks)
	if (WhichListItem("seconds",nameList)>0)
		Wave seconds=seconds
		seconds = UnWrapNegSeconds(seconds[p])	// note:  assume 1MHz clock!!!
	endif


	nameList = TagDuplicateItemsInList(nameList,";"," ")	// add space before duplicate names
	nameList = RemoveItemsWithPrefix(nameList,";"," ")	// and remove names with leading space
	printf "     %d columns      %d points\r",ItemsInList(nameList,";"), i
	if (stringmatch(xAxisName,"H"))				// an hkl, scan pick pick h,k, or l that changes the most
		Variable dhkl, dtemp
		Wave hkl=H
		dhkl = max(dhkl,abs(hkl[i-1]-hkl[0]))	// range of H
		Wave hkl=K
		dtemp = max(dhkl,abs(hkl[i-1]-hkl[0]))	// if range of K is bigger than range of H, use K
		if (dtemp>dhkl)
				xAxisName="K"
				dhkl = dtemp
		endif
		Wave hkl=L
		dtemp = max(dhkl,abs(hkl[i-1]-hkl[0]))	// if range of L is bigger than range of H or K, use L
		if (dtemp>dhkl)
				xAxisName="L"
				dhkl = dtemp
		endif
	endif
	i = 0
	do											// add dataNote to wavenote of each wave
		str = StringFromList(i,nameList)
		if (strlen(str)<1)
			break
		endif
		Note $str, dataNote
		i += 1
	while (1)
	AddStandardWaveScaling(nameList)
	i = exists("extraSpecUserReadProcess")
	if (i==5 || i==6)							// if macro or userfunc exists, do something to the data
		Execute "extraSpecUserReadProcess()"
	endif
	i = exists("extraSpecReadProcess")			// if macro or userfunc exists, do something to the data
	if (i==5 || i==6)
		if (exists("root:Packages:spec:extraProcess")!=2)
			Variable extra_process
			Prompt extra_process,"do extra processing", popup, "false;true"
			DoPrompt "",extra_process
			Variable/G root:Packages:spec:extraProcess = extra_process - 1
		endif
		NVAR extraProcess=root:Packages:spec:extraProcess
		sprintf str, "extraSpecReadProcess(%d)" ,extraProcess
		Execute str								// extraSpecReadProcess(extraProcess)
	endif
	i = exists("User_MoreProcess")			// if macro or userfunc exists, write more user specified lines
	if (i==5 || i==6)
		sprintf str, "User_MoreProcess(%ld)" ,fileVar
		Execute str								// User_MoreProcess(fileVar)
	endif

	SetDataFolder fldrSav
	NVAR lastScan=root:Packages:spec:lastScan
	lastScan = scanNum
	FSetPos fileVar, FilePosStart				// reset file position to original position
	return 0										// return OK
End


Static Function UnWrapNegSeconds(sec)		// this is needed because more than 2^31 clock ticks show as negative seconds
	Variable sec
	if (sec >=0)
		return sec
	endif
	String str
	sprintf str,"%u",sec*1e6					// assumed 1MHz clock
	return str2num(str)/1e6
End


Function/T check_fileID(fileVar) 
	// make the file ID, and ensure that list of scan positions is up to date 
	// returns the file ID string
	Variable fileVar								// file ref number
	String idStr									// desired string for ID purposes
	idStr=make_fileID(fileVar)					// create the id string
	if (cmpstr(idStr,StrVarOrDefault("root:Packages:spec:specScanPositionsID","x")))
		// make the list of positions for each scan in this file
		FStatus fileVar
		FSetPos fileVar, 0						// reset file position to start of header
		String/G root:Packages:spec:specScanPositions=ListPosOfLineTypes(fileVar,"#S ")
		String/G root:Packages:spec:specScanPositionsID=idStr
		SVAR specScanPositions=root:Packages:spec:specScanPositions
		Variable scanNum
		String line
		FSetPos fileVar, str2num(StringFromList(0,specScanPositions))	// position to the first scan
		FReadLine fileVar, line
		scanNum = cmpstr(line[0,1],"#S") ? NaN : str2num(line[2,20])	// first scan number in the file
		Variable /G root:Packages:spec:firstScanNumInFile=scanNum
		FSetPos fileVar, V_filepos				// reset file position to previous position
	endif
	return idStr
End

Function/T make_fileID(fileVar) // returns a string that is unique to this file
	Variable fileVar								// file ref number

	String idStr									// desired string for ID purposes
	FStatus fileVar
	Variable fpos0=V_filePos
	String line
	Variable epoch=NaN

	idStr="fileName="+S_fileName+";path="+S_path+";length="+num2istr(V_logEOF)
	line = FindDataLineType(fileVar,"#F",0)	// look for #F, the original file specification
	line = ZapControlCodes(line[3,inf])
	idStr += ";origFile="+line
	FSetPos fileVar, 0							// reset file position to start of header
	line = FindDataLineType(fileVar,"#E",1)	// look for #E, the starting epoch of the file
	if (strlen(line)>2)
		epoch = str2num(line[2,inf])
	endif
	idStr += ";epoch="+SelectString(numtype(epoch),num2istr(epoch),"NaN")

	if (numtype(epoch)==0)						// valid epoch was found
		FSetPos fileVar, 0						// reset file position to start of header
		line = FindDataLineType(fileVar,"#D",1)// look for #D, the starting date of the file
		if (strlen(line)>2)
			Variable seconds, TZ				// TZ is time zone shift in hours
			TZ = (specDate2seconds(line) - epoch)/3600		// number of hours between date and epoch
			TZ = mod(TZ,24)						// throw out excess number of days
			TZ = (TZ>12) ? TZ-24 : TZ			// make fraction of a day wrap at 12; ie -5, not 19
			idStr += ";TZ="+num2str(TZ)
		endif
	endif

	FSetPos fileVar, fpos0
	return idStr
End



Function AddStandardWaveScaling(nameList)
	// Add standard units to spec waves.  This is just a guess (hopefully a good one)
	String nameList			// list of wave names, one for each column

	String unitList="delta_:°;phi_:°;mu_:°;nu_:°;kappa_:°;keta_:°;eta_:°;kphi_:°;chi_:°"
	unitList += ";Delta_:°"
	unitList += ";H:rlu;K:rlu;L:rlu;seconds:s;Epoch:s;Xburleigh:µm;Yburleigh:µm;Zburleigh:µm"
	unitList += "Two_Theta:°;2theta:°;Theta:°;Chi:°;Phi:°;anal-2th:°;anal-th"
	String name
	Variable i = 0
	do
		name = StringFromList(i,nameList, ";")
		if (strlen(name)>0)
			SetScale d 0,0,StringByKey(name,unitList), $name
		endif
		i += 1
	while (strlen(name)>0)
End


//	Jun 26, 2004, added support for the use of an mca style dump of one variable
Function Read1DataBlock(fileVar,name)
	// with the file positioned at the beginning of a set of columns, read them into waves
	Variable fileVar			// file ref number
	String name				// wave names for this block

	if (strlen(name)<1)
		return 0
	endif

	String line
	Variable sizeIncrement = 100
	Variable waveLength = sizeIncrement
	Variable scanLen									// count up number of points in scan

	Make/N=(waveLength) $name						// start with a size of waveLength
	Wave wn = $name
	wn = NaN

	scanLen = 0
	do
		FReadLine fileVar, line
		if  (strlen(line)<=1)						// check for end of file, blank line, or end of data
			break
		endif
		if ((scanLen+sizeIncrement)>waveLength)	// need to extend size of input waves
			waveLength += sizeIncrement
			Redimension/N=(waveLength) wn
			wn[waveLength-sizeIncrement,waveLength-1]=NaN
		endif

		Variable val, i =  0
		do												// put values on the line into the wave
			val = str2num(line[i,Inf])
			if (!numtype(val))
				wn[scanLen] = val
				scanLen += 1							// found a good value, increment scan length
				i = strsearch(line," ",i+1)+1		// position for next value
			else
				break
			endif
		while(i>0)
	while(1)
	Redimension/N=(scanLen) wn
	return scanLen
End


Function ReadDataColumns(fileVar,nameList)
	// with the file positioned at the beginning of a set of columns, read them into waves
	Variable fileVar			// file ref number
	String nameList			// list of wave names, one for each column

	String line
	Variable ncols = ItemsInList(nameList,";")
	Variable sizeIncrement = 100
	Variable waveLength = sizeIncrement
	Variable scanLen								// count up number of points in scan
	String cmd, name=""							// for names of each data waves
	String waveList								// nameList but without duplicate names
	nameList = TagDuplicateItemsInList(nameList,";"," ")	// add space before duplicate names
	waveList = RemoveItemsWithPrefix(nameList,";"," ")

	Variable i = 0
	do
		name = StringFromList(i,waveList, ";")
		if (strlen(name)>0)
			cmd = "Make/N="+num2istr(waveLength)+" "+name	// start with a size of waveLength
			Execute cmd
			cmd = name+" = NaN"
			Execute cmd
		endif
		i += 1
	while (strlen(name)>0)

	scanLen = 0
	do
		FReadLine fileVar, line
		if ((strlen(line)<=1) || (char2num(line[0,0])==35))		// check for end of file, blank line, or end of data
			if (!strsearch(line,"#C",0))		// skip comment lines during the scan (a request from Pete).
				continue							// comments start with '#C'
			endif
			break									// 35 is ASCII '#',  any other # indicates end of scan
		endif
		scanLen += 1								// found a good line, increment scan length

		if (scanLen>waveLength)					// need to extend size of input waves
			waveLength += sizeIncrement
			i = 0
			name=""								// increase size of the data waves
			do
				name = StringFromList(i,waveList, ";")
				if (strlen(name)>0)
					cmd = "Redimension/N="+num2istr(waveLength)+" "+name
					Execute cmd
					cmd = name+"["+num2istr(waveLength-sizeIncrement)+","+num2istr(waveLength-1)+"]=NaN"
					Execute cmd
				endif
				i += 1
			while (strlen(name)>0)
		endif

		AssignOneLine(line,scanLen-1,ncols,nameList)
	while(1)

	i = 0											// make the data waves correct length
	do
		name = StringFromList(i,waveList, ";")
		if (strlen(name)>0)
			cmd = "Redimension/N="+num2istr(scanLen)+" "+name
			Execute cmd
		endif
		i += 1
	while (strlen(name)>0)
	return scanLen
End


Function/T FindDataStart(fileVar)
	Variable fileVar			// file ref number

	String line
	Variable i=0
	Variable foundStart=0
	do
		FReadLine fileVar, line
		foundStart = strsearch(line, "#L", 0)==0
		i += 1
	while ((!foundStart) && (i<100))

	if (i>=100)
		print "start of data not found"
	endif

	return line
End


Function/T FindDataLineType(fileVar,search,short)
	// search file starting with current position for line starting with 'search'
	Variable fileVar			// file ref number
	String search				// string to search for at start of line
	Variable short			// if 1, do not search past '#L', if 0, search to next '#S'

	Variable notSline = cmpstr(search[0,1],"#S") != 0
	if (!notSline)			// short searches do not make sense for '#S' lines
		short = 0
	endif
	String lineTerm=""							// line terminator to use
	String line

	String buffer=" "							// set up large buffer for reading data file
	Variable bufSize
	bufSize = (notSline) ? 5e3 : 5e5 			// use big buffers to find #S lines
	Variable Nread=strlen(search)+bufSize+2
	buffer = PadString(buffer, Nread, 0)		// buffer is now created

	FStatus fileVar
	Variable fpos00=V_filePos					// starting point in file
	Variable fpos0=max(V_filePos-1,0)			// where we start to search from
	Variable j=-bufSize							// j is current point in file to read from
	Variable more=1								// flags that there is more yet to check
	Variable i									// used as index into buffer
	Variable iL,iS								// index to #L and #S
	Variable ii=0									// counts number of buffers loaded
	do
		j += bufSize
		FSetPos fileVar, (j+fpos0)
		FStatus fileVar
		if ((V_logEOF-V_filePos)<Nread)		// not enough data to fill buffer
			buffer = " "
			buffer = PadString(buffer,V_logEOF-V_filePos, 0)
			more = 0
		endif
		FBinRead fileVar, buffer				// read next buffer full of data
		if (ii==0)
			if (strsearch(buffer,"\n", 0) >= 0)
				lineTerm = "\n"
			else
				lineTerm = "\r"
			endif
			search = lineTerm+search			// search must occur at start of a line
		endif
		if ((j+fpos0)==0)
			i = strsearch(buffer, search[1,inf], 0)	// check, no <cr> at start of file
			if (i>0)
				i = strsearch(buffer, search, 0)	// not at byte 0, so include <cr>
			endif
		else
			i = strsearch(buffer, search, 0)	// check
		endif
		iL = strsearch(buffer, lineTerm+"#L", 0)
		iS = strsearch(buffer, lineTerm+"#S", 0)
		more = more && (iS<0)					// if found #S, then no more
		more = more && !((iL>=0) && short)	// do not continue past #L when short==1
		ii += 1
	while ((i<0) && more)						// continue if not found and more data in file

	if ((i<0) || (short && (iL>=0) && (iL<i)) || (short && (iS>=0) && (iS<i)) || ((iS>=0) && (iS<i)))
		FSetPos fileVar, fpos00					// return to starting point, and return empty string
		return ""
	endif

	// if it reached here, then 'search' has been found and it is good
	i = (fpos0+j+i>0) ? i+1 : i
	FSetPos fileVar, (fpos0+j+i)				// position to start of 'search'
	FReadLine fileVar, line						// read the line so it can be passed back
	return line
End



Function/T FindScanNum(fileVar,scanNum)		// search for start of scan
	Variable fileVar		// file ref number
	Variable scanNum		// scan number to find

	if (scanNum<0)
		return ""
	endif
	String search = "#S "+num2istr(scanNum)

	String buffer=" "							// set up large buffer for reading data file
	Variable bufSize=5e5
	Variable Nread=strlen(search)+bufSize
	buffer = PadString(buffer, Nread, 0)

	FStatus fileVar
	Variable fpos0=V_filePos
	Variable more=1,i,j=-bufSize

	do
		j += bufSize
		FSetPos fileVar, (j+fpos0)
		FStatus fileVar
		if ((V_logEOF-V_filePos)<Nread)		// not enough data to fill buffer
			buffer = ""
			buffer = PadString(buffer,V_logEOF-V_filePos, 0)
			more = 0
		endif
		FBinRead fileVar, buffer				// read next buffer full of data
		i = strsearch(buffer, search, 0)		// check
	while ((i<0) && more)						// continue if not found and more data in file

	if (i<0)										// not found
		return ""
	endif

	FSetPos fileVar, (i+j+fpos0)
	String line=" "
	FReadLine fileVar, line
	return line
End


Function/T ListPosOfLineTypes(fileVar,search)	// returns file pos of all lines containing 'search'
	Variable fileVar			// file ref number
	String search				// characters to search for, usually "#S"

	String PosList=""		// list of positions in file
	String buffer=" "		// set up large buffer for reading data file
	Variable bufSize=5e5
	Variable Nread=strlen(search)+bufSize
	buffer = PadString(buffer, Nread, 0)

	FStatus fileVar
	Variable fpos0=V_filePos
	Variable more=1,i,j=-bufSize

	do
		j += bufSize
		FSetPos fileVar, (j+fpos0)
		FStatus fileVar
		if ((V_logEOF-V_filePos)<Nread)		// not enough data to fill buffer
			buffer = ""
			buffer = PadString(buffer,V_logEOF-V_filePos, 0)
			more = 0
		endif
		FBinRead fileVar, buffer				// read next buffer full of data
		i = -1
		do
			i = strsearch(buffer, search, i+1)// check
			if (i>=0)
				PosList += num2istr(i+j+fpos0)+";"
			endif
		while (i>=0)
	while ((i<0) && more)						// continue if not found and more data in file
	return PosList
End


Function AssignOneLine(line,point,ncols,list)
	String line			// ="6398.5 11773 5 3.16608e+06 1447 305824 0 0 0 1.49217e+06 339"
	Variable point
	Variable ncols
	String list

	String name			// name of data wave
	Variable i=0
	Variable j = 0

	do
		name = StringFromList(i,list, ";")

		// loop over any leading white space (i.e. if line[j+1]<" ", incrment j
		j -= 1										// because loop always gives extra incrment
		do
			j += 1
		while (char2num(line[j])<=32)			// check character

		if (char2num(name[0])>32)				// do not actually save if name starts with a space
			Wave w=$name
			w[point] = str2num(line[j,inf])
		endif
		j = strsearch(line," ",j)				// j is now position of next space
		i += 1
	while(i<ncols)
End


Function SetValuesIntoList(names,values,destination)
	// given a list of names and a list of values, append as key=value to string
	String names,values,destination

	String/G $destination
	SVAR dest=$destination

	names = ZapControlCodes(names)
	names = ReduceSpaceRunsInString(names,2)
	names = TrimLeadingWhiteSpace(names)
	names = ChangePartsOfString(names,"  ",";")		// double space is name separator
	values = ZapControlCodes(values)
	values = ChangePartsOfString(values," ",";")
	String vname
	Variable val
	Variable i = 0
	do
		vname = StringFromList(i,names, ";")
		if ((strlen(vname)>0) && cmpstr(vname,"?"))	// was 1, I hope this works, used to get H, K, L
			val = str2num(StringFromList(i,values, ";"))
			if ( (stringmatch(vname, "--")==0) && (numtype(val)==0) )	// only valid names & values
				dest = ReplaceNumberByKey(vname, dest, val)
			endif
		endif
		i += 1
	while(strlen(vname)>0)								// was 1, I hope this works, used to get H, K, L
End


Function SetBValues(line1,line2)
	String line1,line2

	line1 = ZapControlCodes(line1)					// This is list of names
	line1 = ReduceSpaceRunsInString(line1,1)
	line1 = TrimLeadingWhiteSpace(line1)
	line1 = ChangePartsOfString(line1," ",";")

	line2 = ZapControlCodes(line2)					// This is list of values
	line2 = ChangePartsOfString(line2," ",";")
	String vname,val
	String cmd
	Variable i = 0
	do
		vname = StringFromList(i,line1, ";")
		if (strlen(vname)>1 && !stringmatch(vname, "--"))	// skip variables named "-"
			vname = ValidIgorVarName(vname)			// ensure valid name
			val = StringFromList(i,line2, ";")
			cmd = "Variable/G "+vname+" = "+val
			Execute cmd
		endif
		i += 1
	while(strlen(vname)>1)
End



Function specDate2seconds(dstring)
	String dstring

	Variable imon
	String mon
	Variable day,hh,mm,ss,year
	sscanf dstring, "#D %*s %s %d %d:%d:%d %d",mon,day,hh,mm,ss,year
	if (V_flag != 6)
		return NaN
	endif

	imon = WhichListItem(mon,"Jan;Feb;Mar;Apr;May;Jun;Jul;Aug;Sep;Oct;Nov;Dec")
	if (imon<0)
		return NaN
	endif
	return date2secs(year,imon+1,day) + ss + 60*(mm+60*hh)
End




Function/T TagDuplicateItemsInList(listStr,separator,prefix)
	//  tag any duplicate items in list with prefix
	String listStr
	String separator
	String prefix				// string to prepend to duplicate items

	String item
	Variable n=ItemsInList(listStr, separator)
	Variable index,i

	Variable j=0
	do
		item = StringFromList(j,listStr,separator)			// check for duplicates of this item
		index = FindListItem(item,liststr,separator, 0)	// index to item in list
		i = FindListItem(item,liststr,separator, index+1)	// index to duplicate in list
		if (i>0)													// found a duplicate
			listStr[i,i] = prefix+listStr[i]					// prepend prefix
		else
			j += 1													// increment if no duplicates
		endif
	while (j<(n-1))
	return listStr
End



Function/T RemoveItemsWithPrefix(listStr,separator,prefix)
	//  remove all items in list starting with prefix
	String listStr
	String separator
	String prefix				// string to prepend to duplicate items

	String item
	Variable n				// number of items in list
	Variable i=0
	do
		item = StringFromList(i,listStr,separator)			// check for prefix on this item
		if (strsearch(item,prefix,0)==0)						// item starts with prefix
			listStr = RemoveFromList(item, listStr, separator)
		else
			i += 1
		endif
		n=ItemsInList(listStr, separator)
	while (i<n)
	return listStr
End



Function/T ReduceSpaceRunsInString(str,minRun)
	String str
	Variable minRun

	String spaces = PadString("  ", 256, 0x20)	// spaces contains 256 spaces
	String new = spaces[0,minRun-1]				// replacement string
	Variable i = strlen(spaces)-1
	do
		str = ChangePartsOfString(str,spaces[0,i],new)
		i -= 1
	while(i>=minRun)
	return str
End


Function/T ChangePartsOfString(str,delim,new)
	String str
	String delim
	String new

	Variable id=strlen(delim)
	Variable i
	do
		i = strsearch(str,delim,0 )
		if (i>=0)
			str[i,i+id-1] = new
		endif
	while(i>=0)

	return str
End



Function/T ZapControlCodes(str)			// remove parts of string with ASCII code < 32
	String str
	Variable i = 0
	do
		if (char2num(str[i,i])<32)
			str[i,i+1] = str[i+1,i+1]
		endif
		i += 1
	while(i<strlen(str))
	return str
End



Function/T ValidIgorWaveName(name)
	// if necessary converts name to a valid Igor wave name
	String name

	if (cmpstr("2theta", name)==0)		// special for 2theta
		return "ttheta"
	endif

	name = CleanupName(name, 0)
	if (CheckName(name, 1))
		name = name+"_"
	endif
	if (WaveExists($name))
		name = name+"_1"
	endif
	if (CheckName(name, 1))
		Abort "cannot form legal wave name from '"+name+"'"
		return ""
	endif

	return name
End



Function/T ValidIgorVarName(name)
	// if necessary converts name to a valid Igor variable name
	String name

	if (cmpstr("2theta", name)==0)		// special for 2theta
		return "ttheta"
	endif

	name = CleanupName(name, 0)
	if (CheckName(name, 3) || CheckName(name, 4) )
		name = name+"_"
	endif

	if (exists(name)==2)
		name = name+"_1"
	endif
	if (CheckName(name, 3) || CheckName(name, 4))
		Abort "cannot form legal variable name from '"+name+"'"
		return ""
	endif

	return name
End



Function/T WordToGreek(str)
	String str

	if (cmpstr(str,"alpha")==0)
		str = "\\F'Symbol'α\\]0"
	endif
	if (cmpstr(str,"beta")==0)
		str = "\\F'Symbol'β\\]0"
	endif
	if (cmpstr(str,"gamma")==0)
		str = "\\F'Symbol'γ\\]0"
	endif
	if (cmpstr(str,"delta")==0)
		str = "\\F'Symbol'δ\\]0"
	endif
	if (cmpstr(str,"lambda")==0)
		str = "\\F'Symbol'λ\\]0"
	endif
	if (cmpstr(str,"chi")==0)
		str = "\\F'Symbol'χ\\]0"
	endif
	if (cmpstr(str,"phi")==0)
		str = "\\F'Symbol'φ\\]0"
	endif
	if (cmpstr(str,"theta")==0)
		str = "\\F'Symbol'θ\\]0"
	endif
	if (cmpstr(str,"2theta")==0)
		str = "\\F'Symbol'2θ\\]0"
	endif

	return str
End



threadsafe override  Function/T TrimLeadingWhiteSpace(str)	// remove any leading white space from str
	String str
	Variable i
	i = -1
	do
		i += 1
	while (char2num(str[i])<=32)
	return str[i,strlen(str)-1]
End


Function/T TrimTraiingWhiteSpace(str)	// remove any trailing white space from str
	String str
	Variable i
	i = strlen(str)
	do
		i -= 1
	while (char2num(str[i])<=32)
	return str[0,i]
End


Static Function/T expandRange(range)
	String range

	Variable i1,i2,i
	String str,out=""
	Variable N=ItemsInList(range,",")
	Variable j=0
	do
		str = StringFromList(j, range, ",")
		Variable m=-1				// remove any leading white space
		do
			m += 1
		while (char2num(str[m])<=32)
		str = str[m,strlen(str)-1]

		// now check str to see if it is a range like "20-23"
		i1 = str2num(str)
		i = strsearch(str,"-",strlen(num2str(i1)))		// position of "-" after first number
		if (i>0)
			i2 = str2num(str[i+1,inf])
			i = i1
			do
				out += num2str(i)+";"
				i += 1
			while (i<=i2)
		else
			out += num2str(i1)+";"
		endif
		j += 1
	while (j<N)
	return out
End



Function/T Find_specDataFolder(scanNum)
	// returns folder with spec scan, "bad dir" flags failure
	Variable scanNum
	String folderName=""

	if (!cmpstr("spec"+num2istr(scanNum),GetDataFolder(0)))	// check if already in folder
		return ""														// we are already inside the spec folder
	endif

	folderName = ":spec"+num2istr(scanNum)+":"					// first check current level
	if (DataFolderExists(folderName))
		return folderName
	endif

	SVAR specDataFolder= root:Packages:spec:specDataFolder
	folderName = specDataFolder+"spec"+num2istr(scanNum)+":"	// check if spec scan in usual place
	if (DataFolderExists(folderName))
		return folderName
	endif

	return "bad dir"													// give up, "bad dir" flags failure
End


//
//		This is the spec info routines
//

Function specInfo(scanNum,key)
	Variable scanNum
	String key			// pv name to retrieve
		// retrieve a specific PV or motor position from a loaded spec data file
		// set global variable V_flag > 0 if there is an error (0=no error)
		// values for V_flag are:
		//		0=(no error)
		//		1=(scan number must be >0)
		//		2=(Scan not found)
		//		3=(Scan information not found)
		//		4=(value is a string, not a number)

	Variable/G V_flag = 0
	if (scanNum<1 || numtype(scanNum))
//		Print "scan number must be >0"
		V_flag = 1
		return NaN
	endif

	String folderName = Find_specDataFolder(scanNum)	// get the folder for the spec scan
	if (!cmpstr(folderName,"bad dir"))
				V_flag = 2									// data folder does not exist
				return NaN									// finally give up
	endif

	String list=""
	if (exists(folderName+"specMotors")==2)
		SVAR specMotors=$(folderName+"specMotors")
		list += specMotors
	endif
	if (exists(folderName+"EPICS_PVs")==2)
		SVAR EPICS_PVs=$(folderName+"EPICS_PVs")
		list += EPICS_PVs
	endif
	if (exists(folderName+"specValues")==2)
		SVAR spec_Values=$(folderName+"specValues")
		list += spec_Values
	endif

	String str = StringByKey(key, list)

	if (strlen(str)>0)		// found something in the list
		Variable value=str2num(str)
		if (numtype(value))
			V_flag = 4
//			Print "value = '"+str+"',  which is not a number"
		else
			return value
		endif
	else
		V_flag = 3
//		Print "key = '"+key+"'  not found"
	endif

	return NaN
End

Function/T specInfoT(scanNum,key)
	Variable scanNum
	String key			// pv name to retrieve
		// retrieve a specific PV or motor position from a loaded spec data file
		// set global variable V_flag > 0 if there is an error (0=no error)
		// values for V_flag are:
		//		0=(no error)
		//		1=(scan number must be >0)
		//		2=(Scan not found)
		//		3=(Scan information not found)
		//		4=(value is a string, not a number)

	Variable/G V_flag = 0
	if (scanNum<1 || numtype(scanNum))
//		Print "scan number must be >0"
		V_flag = 1
		return ""
	endif

	String folderName = Find_specDataFolder(scanNum)	// get the folder for the spec scan
	if (!cmpstr(folderName,"bad dir"))
				V_flag = 2									// data folder does not exist
				return ""										// finally give up
	endif
	if (exists(folderName+key)==2)
		SVAR spec_str=$(folderName+key)
		return spec_str
	endif
	if (exists(folderName+"spec"+key)==2)
		SVAR spec_str=$(folderName+"spec"+key)
		return spec_str
	endif

	String list=""
	if (exists(folderName+"specMotors")==2)
		SVAR specMotors=$(folderName+"specMotors")
		list += specMotors
	endif
	if (exists(folderName+"EPICS_PVs")==2)
		SVAR EPICS_PVs=$(folderName+"EPICS_PVs")
		list += EPICS_PVs
	endif
	if (exists(folderName+"specValues")==2)
		SVAR spec_Values=$(folderName+"specValues")
		list += spec_Values
	endif

	return StringByKey(key, list)
End



Function specInformation(scanNum)
		// retrieve information about a loaded spec data file
		// returns > 0 if there is an error (0=no error)
		// error values are:
		//		
		//		0=(no error)
		//		1=(scan number must be >0)
		//		2=(data folder does not exist)
		//
	Variable scanNum
	if (scanNum<1 || numtype(scanNum))
		scanNum=NumVarOrDefault("root:Packages:spec:lastScan", 1)
		Prompt scanNum,"spec scan number"
		DoPrompt "give a scan number", scanNum
		if (V_flag)											// cancelled after prompt
			return 1
		endif
	endif
	if (scanNum<1 || numtype(scanNum))
		Print "scan number must be >0"
		return 1
	endif

	String folderName = Find_specDataFolder(scanNum)	// get the folder for the spec scan
	if (!cmpstr(folderName,"bad dir"))
				Print "the data folder does not exist"
				return 2										// finally give up
	endif

	String miscString_temp__ = "-none-;"
	String motorString_temp__ = "-none-;"
	String pvString_temp1__ = "-none-;"
	String pvString_temp2__ = "-none-;"
	String pvString_temp3__ = "-none-;"

	if (exists(folderName+"specCommand")==2)
		SVAR specCommand= $(folderName+"specCommand")
		miscString_temp__ += specInfoNoLeadingSpace(specCommand) + ";"
	endif
	if (exists(folderName+"specComment")==2)
		SVAR specComment= $(folderName+"specComment")
		miscString_temp__ += specInfoNoLeadingSpace(specComment) + ";"
	endif
	if (exists(folderName+"timeWritten")==2)
		SVAR timeWritten= $(folderName+"timeWritten")
		miscString_temp__ += specInfoNoLeadingSpace(timeWritten) + ";"
	endif
	if (exists(folderName+"specValues")==2)
		SVAR specValues= $(folderName+"specValues")
		miscString_temp__ += specValues
		miscString_temp__ = ChangePartsOfString(miscString_temp__,":","   ")
	endif

	if (exists(folderName+"specMotors")==2)
		SVAR specMotors= $(folderName+"specMotors")
		motorString_temp__ += specMotors
		motorString_temp__ = specInfoRemoveCrapPVs(motorString_temp__)
		motorString_temp__ = ChangePartsOfString(motorString_temp__,":","   ")
	endif

	if (exists(folderName+"EPICS_PVs")==2)
		SVAR EPICS_PVs= $(folderName+"EPICS_PVs")
		String str = EPICS_PVs
		Variable i=specInfoBreakPoint(str,"Mirr")
		Variable j=specInfoBreakPoint(str,"darkRing")
		if (j<=i)
			j = strlen(str)
		endif
		pvString_temp1__ += str[0,i-1]
		pvString_temp1__ = specInfoRemoveCrapPVs(pvString_temp1__)
		pvString_temp1__ = ChangePartsOfString(pvString_temp1__,":","   ")
		pvString_temp2__ += str[i,j-1]
		pvString_temp2__ = specInfoRemoveCrapPVs(pvString_temp2__)
		pvString_temp2__ = ChangePartsOfString(pvString_temp2__,":","   ")
		pvString_temp3__ += str[j,strlen(str)]
		pvString_temp3__ = specInfoRemoveCrapPVs(pvString_temp3__)
		pvString_temp3__ = ChangePartsOfString(pvString_temp3__,":","   ")
	endif

	String misc="-none-",motor="-none-",PV1="-none-",PV2="-none-",PV3="-none-"
	Prompt misc "spec info",popup, miscString_temp__
	Prompt motor "spec motors",popup, motorString_temp__
	Prompt PV1 "Front end EPICS PV's",popup, pvString_temp1__
	Prompt PV2 "Station EPICS PV's",popup, pvString_temp2__
	Prompt PV3 "Local EPICS PV's",popup, pvString_temp3__
	DoPrompt "pick",misc,motor,PV1,PV2,PV3

	sprintf str, "   for scan %d,   ",scanNum
	if (cmpstr(misc,"-none-"))
		print str,misc
	endif
	if (cmpstr(motor,"-none-"))
		print str,motor
	endif
	if (cmpstr(PV1,"-none-"))
		print str,PV1
	endif
	if (cmpstr(PV2,"-none-"))
		print str,PV2
	endif
	if (cmpstr(PV3,"-none-"))
		print str,PV3
	endif
	return 0
End
Function specInfoBreakPoint(str,search)
	String str,search
	Variable i,j=0
	do
		i = j
		j = strsearch(str, search, i+1)
	while (j>0)
	return strsearch(str, ";", i+1)+1
End
Function/T specInfoRemoveCrapPVs(list)
	String list
	String key
	String crap = "F1_thick;"
	crap += "H20_L5_TL;H20_L5_BR;H20_F1;H20_mask;H20_window;H20_beamStop;"
	crap += "Vac_OK;Vac_L5_OK;Vac_L5_IG;Vac_L5_IPP;Vac_FOE_IPP;Vac_PC1_IPP;Vac_PC2_IPP;Vac_DCM_OK;"
	crap += "Vac_DCM_CG;Vac_DCM_IG;Vac_DCM_IPP;Vac_Mirr2_IPP;Vac_P5_IG;Vac_P5_IPP;Vac_PC3_IPP;Vac_App_CG;"
	crap += "Vac_L5_IPV;Vac_PC1_IPV;Vac_PC2_IPV;Vac_DCM_IPV;Vac_PC3_IPV;"
	crap += "D2_VDC;D2_gain;D2_time;D2_bias;D2_suppr;D2_dark;D2_Amps;"
	crap += "SOE540_i0;SOE540_i1;SOE540_i2;SOE540_i3;SOE540_i4;SOE540_i5;SOE540_i6;SOE540_i7;"
	crap += "SOE540_i8;SOE540_i9;SOE540_i10;SOE540_i11;SOE540_i12;SOE540_i13;SOE540_i14;SOE540_i15;"
	crap += "SOE540_o0;SOE540_o1;SOE540_o2;SOE540_o3;"
	crap += "SOEk2k_1;SOEk2k_2;SOEk2k_3;SOEk2k_4;SOEk2k-5;SOEk2k_6;SOEk2k_7;SOEk2k_8;SOEk2k_9;SOEk2k_10;"
	crap += "LN2_flow;LN2_density;LN2_bath;LN2_buffer;"
	crap += "FB_th_r;FB_th_sp;FB_o1_r;FB_o1_sp;jfk_sclr_auto;mrEnc;arEnc;"
	crap += "UPDmode;UPDrange;UPDvfc;UPDgain1;UPDbkg1;UPDgain2;UPDbkg2;UPDgain3;UPDbkg3;UPDgain4;UPDbkg4;"

	crap += "m1y;m2y;m2r;msx;msy;mx;my;msr;a1y;a2y;a2r;asx;asy;ax;ay;"
	crap += "az;sx;sy;sr2;dx;dy;sr;sa;asr;slit4t;slit4l;slit4b;slit4r;sgr;sga;sgx;"
	crap += "sgy;mr;m1t;m2t;mst;ar;a1t;a2t;ast;"

	crap += "HSC1t;HSC1l;HSC1b;HSC1r;HSC2t;HSC2l;HSC2b;HSC2r;HSC3t;HSC3l;HSC3b;HSC3r;HSC4t;HSC4l;HSC4b;HSC4r;"
//	crap += "HSC1h;HSC1v;HSC1h0;HSC1v0;HSC2h;HSC2v;HSC2h0;HSC2v0;HSC3h;HSC3v;HSC3h0;HSC3v0"

	Variable N=ItemsInList(crap, ";")
	Variable i=0
	do
		key = StringFromList(i, crap)
		list = RemoveByKey(key, list,":",";")
		i += 1
	while (i<N)
	return list
End
Function/T specInfoNoLeadingSpace(str)
	String str
	Variable i=-1
	do
		i += 1
	while (!cmpstr(str[i,i]," "))
	return str[i,strlen(str)]
End




//
//	rountines to search a file and list all spec scans in a file
//

Function List_spec_Scans(fileName,path,scanType)
	// lists to the history all of the scans of a certain type from a spec data file
	String fileName, path, scanType

	if (strlen(fileName)<1 || strlen(path)<1 || strlen(scanType)<1)
		String types="all;ascan;a2scan;hklscan;tscan;laserscan;slewscan;Escan;other"
		Prompt fileName, "name of file"
		Prompt path, "path for raw data", popup, PathList("*", ";", "")
		Prompt scanType, "type of spec scans to list", popup, types
		if (strlen(fileName)<1)
			fileName=StrVarOrDefault("root:Packages:spec:specDefaultFile","")
		endif
		if (strlen(path)<1)
			path=StrVarOrDefault("root:Packages:spec:specDefaultPath","raw")
		endif
		if (strlen(scanType)<1)
			scanType="all"
		endif
		DoPrompt "list scan info from a file", fileName,path,scanType
		if (V_flag)
			return 1									// cancelled after prompt
		endif
	endif
	if (!cmpstr(scanType,"other"))
		Prompt scanType, "enter a wild card type string to match"
		DoPrompt "scan type to find", scanType
		if (V_flag)									// cancelled after prompt
			return 1
		endif
	endif

	Variable fileVar									// file ref number
	Open /R/P=$path/Z=1 fileVar as fileName		// test for existence
	if (fileVar)
		Close fileVar
	endif
	if (strlen(S_fileName)<1)
		Open /R/P=$path/M="spec data file"/D fileVar as fileName
	endif
	fileName = S_fileName

	String scanList=specScansList(fileName,"",scanType)
	String line
	SVAR DefaultFile=root:Packages:spec:specDefaultFile

	// get file header stuff
	Open /R/P=$path/M="spec data file" fileVar as fileName
	fileName=DefaultFile
	FStatus(fileVar)
	Variable FilePos = V_filePos
	line = FindDataLineType(fileVar,"#D ",1) 	// find when file was started
	line = ZapControlCodes(line)
	FSetPos fileVar, FilePos						// reset file position to start of header
	Close fileVar
	// end of file header stuff

	if (strlen(scanList)<2)							// no scans of this type found
		printf "For file '%s'  started   %s,  no '%s' type scans found :\r",fileName,line[3,inf],scanType
		return 1
	endif

	printf "\rFor file '%s'  started   %s :\r",fileName,line[3,inf]
	Variable i=0
	do
		line = StringFromList(i, scanList)
		printf "   %s\r",line
		i += 1
	while(strlen(line)>1)
	return 0
End


Function/T specScansList(fileName,path,scanType)
	// return a list of all of the scans of a certain type from a spec data file
	// scanType is the spec scan name, "all;ascan;hklscan;laserscan;" or a wild 
	// carded version of one
	String fileName		// =StrVarOrDefault("root:Packages:spec:specDefaultFile","")
	String path			// =StrVarOrDefault("root:Packages:spec:specDefaultPath","home")
	String scanType		// ="all"

	if (cmpstr("all",scanType)==0)
		scanType="*"
	else
		scanType = "  "+scanType+" *"
	endif
	Variable fileVar									// file ref number
	String line										// line of input from file
	String scanList=""
	Variable scanNum

	Open /R/P=$path/Z fileVar as fileName
	if (V_flag)
		Open /R/M="spec data file" fileVar as fileName
	endif
	if (!fileVar)
		return ""
	endif
	FStatus(fileVar)

	S_fileName = SelectString(strlen(StringByKey("PATH",S_info)),S_path+S_fileName,S_fileName)
	String /G root:Packages:spec:specDefaultFile=S_fileName	// update defaults
	String /G root:Packages:spec:specDefaultPath=path

	// use saved list of scan positions, but check first
	check_fileID(fileVar)							// update specScanPositions if needed
	SVAR posList=root:Packages:spec:specScanPositions	// file positions of all scans

	if (strlen(posList)<1)
		return ""
	endif

	Variable i = 0
	Variable N=ItemsInList(posList)
	do
		FSetPos fileVar, str2num(StringFromList(i,posList))+3	// position just after '#S '
		FReadLine fileVar, line
		line = ZapControlCodes(line)
		scanNum = str2num(line)
		if (stringmatch(line,num2istr(scanNum)+scanType))
			scanList += line+";"
		endif
		i += 1
	while(i<N)
	Close fileVar
	return scanList
End





Function FTPdata(fileName)	// FTP data from a UNIX server to the local computer
	String fileName			// file name part of file spec (not full path name here

	specInitPackage()		// ensure strings and variable exist
	SVAR userName = root:Packages:spec:userName						// default user name on unis
	SVAR passwd = root:Packages:spec:passwd							// default password on unix
	SVAR u_path = root:Packages:spec:unixPath						// default unix path to file
	SVAR specDefaultFile = root:Packages:spec:specDefaultFile	// specDefaultFile
	fileName=StringFromList(ItemsInList(fileName,":")-1,fileName,":")
	if (strlen(fileName)<1 || strlen(userName)<1 || strlen(passwd)<1 || strlen(u_path)<1 || stringMatch(u_path,"*home//*"))
		if (strlen(fileName)<1)
			fileName=StrVarOrDefault("root:Packages:spec:specDefaultFile","")
			fileName=StringFromList(ItemsInList(fileName,":")-1,fileName,":")	// only filename part
		endif
		String user_name=userName, password=passwd, unixPath=u_path
		Prompt fileName, "name of file (not full path name)"
		Prompt user_name, "user name for FTP"
		Prompt password, "password for FTP"
		Prompt unixPath, "unix path to data for FTP"
		DoPrompt "info for FTP", fileName,user_name,password,unixPath
		if (V_flag)														// cancelled the dialog
			return 1
		endif
		Variable i,ii
		userName = user_name											// update default user name
		passwd=password													// update default password
		if (stringMatch(unixPath, "*home//*"))						//   a double slash after home means insert user name
			i=strsearch(unixPath,"home//",0)
			unixPath[i,i+5] = "home/"+userName+"/"
		endif
		u_path = unixPath												// update default unix path to file
		fileName=StringFromList(ItemsInList(fileName,":")-1,fileName,":")
		i = strlen(StringFromList(ItemsInList(specDefaultFile,":")-1,specDefaultFile,":"))	// length of filename part
		ii = strlen(specDefaultFile)
		specDefaultFile[ii-i,ii] = fileName							// update filename part of specDefaultFile
	endif

	if (strlen(PathList("raw",";",""))<2)							// path 'raw' does not exist, create it
		NewPath raw
	endif
	FTPDownload /O/P=raw /S=1 /T=0 /U=userName /W=passwd /V=3 "ftp://"+u_path+fileName, fileName
	return V_flag					// returns 1=error,  0=OK
EndMacro










Function specInitPackage()
	NewDataFolder /O root:Packages
	NewDataFolder /O root:Packages:spec
	if (exists("root:Packages:spec:lastScan")!=2)
		// last scan number read
		Variable /G root:Packages:spec:lastScan=0		// init lastscan to 0
	endif
	if (exists("root:Packages:spec:extraProcess")!=2)
		Variable /G root:Packages:spec:extraProcess=0	// init lastscan to 0
	endif
	if (exists("root:Packages:spec:specDefaultFile")!=2)
		// name of last spec data file read
		String /G root:Packages:spec:specDefaultFile=""
	endif
	if (exists("root:Packages:spec:specDefaultPath")!=2)
		// operating system path where spec data files exist for reading
		String /G root:Packages:spec:specDefaultPath="home"
	endif
	if (exists("root:Packages:spec:specDataFolder")!=2)
		// igor data folder currently used to store spec scans
		String /G root:Packages:spec:specDataFolder="root:raw:"
	endif
	if (exists("root:Packages:spec:specScanPositions")!=2)
		// offsets in data file to #S lines
		String /G root:Packages:spec:specScanPositions=""
		String /G root:Packages:spec:specScanPositionsID="x_"
		Variable /G root:Packages:spec:firstScanNumInFile=1
	endif
	if (exists("root:Packages:spec:specScanPositionsID")!=2)
		// ID for checking validity of specScanPositions
		String /G root:Packages:spec:specScanPositions=""
		String /G root:Packages:spec:specScanPositionsID="x_"
		Variable /G root:Packages:spec:firstScanNumInFile=1
	endif
	if (exists("root:Packages:spec:firstScanNumInFile")!=2)
		// number of first scan in file (usually 1)
		String /G root:Packages:spec:specScanPositions=""
		String /G root:Packages:spec:specScanPositionsID="x_"
		Variable /G root:Packages:spec:firstScanNumInFile=1
	endif
	if (exists("root:Packages:spec:angleNames")!=1)
		// names of spec motors in header
		Make/N=1/O/T root:Packages:spec:angleNames
	endif
	if (exists("root:Packages:spec:EPICSnames")!=1)
		// names of EPICS PV names in header
		Make/N=1/O/T root:Packages:spec:EPICSnames
	endif

	if (exists("root:Packages:spec:userName")!=2)		// these 3 strings used for FTP
		String /G root:Packages:spec:userName=""
	endif
	if (exists("root:Packages:spec:passwd")!=2)
		String /G root:Packages:spec:passwd=""
	endif
	if (exists("root:Packages:spec:unixPath")!=2)
		SVAR userName=root:Packages:spec:userName
		String /G root:Packages:spec:unixPath="tex.uni.aps.anl.gov/home/"+userName+"/data/"
	endif

	// if there is an init for specMore, do it now too
	if (exists("specMoreInit")==5 || exists("specMoreInit")==6)
		Execute "specMoreInit()"
	endif
End

