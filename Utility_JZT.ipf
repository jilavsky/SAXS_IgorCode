#pragma rtGlobals=2		// Use modern global access method.
#pragma ModuleName=JZTutil
#pragma IgorVersion = 6.11
#pragma version = 3.91
// #pragma hide = 1

Menu "Graph"
	"Append Multiple Graphs to a Layout",AppendGraph2LayoutN(NaN,"","")
End
Menu "Layout"
	"Append Multiple Graphs to a Layout",AppendGraph2LayoutN(NaN,"","")
End
Menu "Data"
//	"Generic Wave Note Info",/Q,GenericWaveNoteInfo($"","")
	"Generic Wave Note Info", GenericWaveNoteInfo($"","")
End


StrConstant ELEMENT_Symbols = "H;He;Li;Be;B;C;N;O;F;Ne;Na;Mg;Al;Si;P;S;Cl;Ar;K;Ca;Sc;Ti;V;Cr;Mn;Fe;Co;Ni;Cu;Zn;Ga;Ge;As;Se;Br;Kr;Rb;Sr;Y;Zr;Nb;Mo;Tc;Ru;Rh;Pd;Ag;Cd;In;Sn;Sb;Te;I;Xe;Cs;Ba;La;Ce;Pr;Nd;Pm;Sm;Eu;Gd;Tb;Dy;Ho;Er;Tm;Yb;Lu;Hf;Ta;W;Re;Os;Ir;Pt;Au;Hg;Tl;Pb;Bi;Po;At;Rn;Fr;Ra;Ac;Th;Pa;U;Np;Pu;Am;Cm;Bk;Cf;Es;Fm;Md;No;Lr;Rf;Db;Sg;Bh;Hs;Mt;Ds;Rg;Cn;;Fl;;Lv"
Static Constant Smallest32bitFloat = 1.40129846432482e-45			// see DefaultZeroThresh(ww) below for use and finding
Static Constant Smallest64bitFloat = 4.94065645841247e-324


// Sections:
//	1	function for optionally showing menus, e.g. MenuItemIfWaveClassExists(), and others
//	2	macros to put labels on lower left/right of plots to identify where they came from
//	3	tool for putting multiple graph on one page
//	4	String ranges, deals with "1,4,5-20",  for handling a non-consecutive range of integers, This one is good
//	5	Progress panels
//	6	Generic XML support
//	7	WaveListClass() & WaveInClass(), used for handling the "waveClass=ccccc;" in wave notes
//		  also AddClassToWaveNote(), ExcludeWavesInClass(), IncludeOnlyWavesInClass()
//		  IncludeOnlyWavesInClass(), removes waves from the list if they are not of correct class
//		  FoldersWithWaveClass(), returns list of sub-folders with wave of a certain class
//		  TraceNamesInClass(), like TraceNameList(), but limit result to a list of wave classes
//	8	Contains lots of utility stuff
//		RecompileAllProcedures(), FORCE ALL procedures to recompile
//		FixUpFolderName(fldr), return foldr name with the needed ":", so fldr+"wavename" is valid
//		WavesWithMatchingKeyVals(), further filter a list of waves, look for those with matching key=value pairs
//		keyInList(), MergeKeywordLists(), & keysInList() "key=value" list utilities
//		joinLists(a,b,[sep]) returns lists a & b joined together in one list
//		OnlyWavesThatAreDisplayed(), removes waves that are not displayed from a list of wave
//		AxisLabelFromGraph(), gets the axis label
//		FindGraphsWithWave() & FindGizmosWithWave(), FindTablesWithWave() finds an existing graph or gizmo with a particular wave
//		DisplayTableOfWave(...), display table taking into account any col/row labels
//		getListOfTypesInFile(), returns file type (using the $filetype) in my old standard files (trying to start only using xml)
//		DrawMarker(), draw a marker
//		xy2saturatedColors(), computes saturated colors for and RGB wheel on an xy graph
//		reverseList(), reverses a list, handy for prompt,popups
//		monotonic(a), checks if a wave is monotonic
//		isdigit(c) & isletter(c), handy utilities
//		angleVec2Vec(a,b), finds angle between two vectors (degree)
//		perp2Vector(a), returns a free vector that is perpendicular to a, the direction around a is unspecified.
//		rotationAngleOfMat(rot)  finds the total rotation angle of a matrix 'rot'
//		isRotationMat(mat,[tol]), returns true if mat is a rotation matrix
//		axisOfMatrix(mat,axis,[squareUp]), find axis and angle from the rotation matrix mat
//		SquareUpMatrix(rot), turns rot from almost a rotation matrix to a true rotation matrix
//		smallestNonZeroValue(vec,[tol]), returns the abs( smallest non-zero element ), e.g. {0, -0.1, 3} returns 0.1
//		MedianOfWave(), returns median (or other percentile) of a wave, useful for picking scaling ranges
//		roundSignificant(val,N), returns val rounded to N places
//		placesOfPrecision(a), returns number of places of precision in a
//		ValErrStr(val,err), returns string  "val ± err" formatted correctly
//		normalize(a), normalizes a if it is a vector or square matrix
//		isPositiveInts(ww), returns 1 only if ww is positive ints, useful for determining if ww are counts
//		OrderValues(x0,x1), x0 and x1 are optionally swapped so that x0<x1 (x0 & x1 are passed by reference)
//		GetCursorRangeFromGraph(), get the cursor range from a graph (returns key=value string)
//		FWHM of fitted peaks: GaussianFWHM(W_coef), LorentzianFWHM(W_coef)
//		Area of fitted peaks: LorentzianIntegral(W_coef), GaussianIntegral(W_coef), Gaussian2DIntegral(W_coef)
//		computeCOM(), compute the Center of Mass
//		PowerIntegerScale(), rescale a waves values by ^n or ^(1/n), preserves sign for non-complex values
//		FitErrorString(FitError,FitQuitReason), return a string representation of the fitting error
//		Posix2HFS, a replacement for PosixToHFS(), (using ParseFilePath() for HFSToPosix()) we no longer need HFSAndPosix.xop
//		cpuFrequency(), systemUserName(), sytemHostname(), localTimeZoneName(), getEnvironment(), returns system info
//		TrimFrontBackWhiteSpace(str), TrimLeadingWhiteSpace(str), TrimTrailingWhiteSpace(str), trims whitespace
//		IgorFileTypeString() gives descriptive string from the NUMTYPE from WaveInfo()
//		GenericWaveNoteInfo(), returns wave note info
//		StopAllTimers(), stops all the Igor timers
//		dateStr2ISO8601Str(), convert a date to an ISO 8601 format
//		ISOtime2niceStr(iso), convert ISO8601 string to a nice format for graph annotations
//		ISOtime2IgorEpoch(iso), convert ISO8601 string to an Igor Epoch (error returns NaN), if TZ present, then returns epoch in UTC
//		epoch2ISOtime(seconds), convert an Igor epoch (in seconds) to an ISO8601 format string
//		AskForUserForDateTime(epoch), puts up a dialog to select a date & time, returns the epoch
//		ElapsedTime2Str(seconds,[showSec,fracDigits]), convert seconds to a nice time interval string
//		vec2str(), convert a vector to a string
//		str2vec(), convert a string to a free vector
//		encodeMatAsStr(mat,[places]), convert mat to a string interpretable by decodeMatFromStr(), used for wave notes
//		decodeMatFromStr(str), returns a FREE wave defined by str, inverse of encodeMatAsStr()
//		cmplx2str(zz,[places,mag]), convert complex number to a printable string
//		str2cmplx(str), 	this is like str2num, but for complex
//		ReplaceCharacters(chars,inStr,replacement)  replace all occurance of a character in chars[] with replacement
//		nice printing of vecs & mats: printWave() and associated functions: {printvec(),printmat(),printmatOneListReal(),printmatOneListComplex()}
//		SetAspectToSquarePixels(), Used to square up a graph window
//		SquareUpGizmo(gName), Used to square up a graph gizmo
//		num2Ordinal(n), converts integer n to ordinal string, e.g. 1 --> "1st"
//		ChangeStrEnding(oldEnd, inStr, newEnd)  if inStr ends in oldEnd, replace oldEnd with newEnd
//		SIprefix2factor(prefix)  get the factor for an SI prefix
//		ConvertUnits2meters(unit,[defaultLen])  returns conversion factor from unit to meters
//		ConvertTemperatureUnits(Tin,unitIn,unitOut)  returns Temperature in units of (unitOut)
//		ConvertNumWithUnitsLength(in,outUnit,[rnd,space])  can convert "2in" to "0.0508 m"
//		SplitNumAndUnits(in)  take string such as "-9.3e2 mi" --> "-9.3e2;mi",  or "2 nm^-1" --> "2;nm^-1"
//		RomanNumeral(j) converts a number to a Roman Numeral string, NO upper limit, so watch out for string length
//		RomanNumeral2Int(str) convert a Roman Numeral string to an integer
//	9	Old legacy or deprecated functions



//  ======================================================================================  //
//  =========================== Start of Option Menu Functions ===========================  //

// generic, used for lots of Menus
Function/S MenuItemIfWaveClassExists(item,classes,optionsStr,[invisible,all])
	String item						// string that you want to appear in menu
	String classes					// semi-colon separated list of wave classes, can use "*" in classes
	String optionsStr				// options that are found in WaveList function optionsStr
	Variable invisible			// controls menu item when conditions not met: true -> menu item absent, false or absent -> menu item grayed out
	Variable all					// when all is TRUE, then all of the classes in waveClassList must be present, not just one
	invisible = ParamIsDefault(invisible) ? 0 : invisible
	invisible = numtype(invisible) ? 0 : invisible
	all = ParamIsDefault(all) ? 0 : !(!all)
	all = numtype(all) ? 0 : all
	String list = WaveListClass(classes,"*",optionsStr,all=all)
	if (invisible)
		return SelectString(strlen(list),"",item)
	endif
	return SelectString(strlen(list),"(","")+item
End

// menu active only if top graph is an image
Function/S MenuItemIfTopGraphImage(item)
	String item
	if (strlen(ImageNameList("",""))<1)
		return "("+item					// top graph does not contain an image, so disable menu item
	endif
	return item
End

// menu active only if a graph is displayed, useful when using a Cursor on the graph
Function/S MenuItemIfAnyGraphExists(item,[visible])
	String item
	Variable visible						// default is to ONLY show visible graphs, use visible=0 to include both
	visible = ParamIsDefault(visible) || numtype(visible) ? 1 : visible
	String optStr = SelectString(visible, "WIN:1", "WIN:1,VISIBLE:1")
	if (strlen(WinList("*",";",optStr))<1)
		return "("+item					// top graph does not contain an image, so disable menu item
	endif
	return item
End

// for menus, enable menu item when a particular wave class is present on the graphName
Function/S MenuItemsWaveClassOnGraph(item,classes,graphName,[csr])
	String item					// item name to return, or "(item" to disable
	String classes					// list of classes to check for (semi-colon separated)
	String graphName				// name of graph, use "" for top graph
	String csr						// requires cursor csr, can be one of "A", "B", ..., "J"
	csr = SelectString(ParamIsDefault(csr),csr,"")	// default to none

	if (strlen(ImageNameList(graphName,";")+TraceNameList(graphName,";",3))<1)
		return "("+item									// no images or graphs displayed
	elseif (strlen(csr) && strlen(CsrInfo($csr,graphName))<1)
		return "("+item									// cursor csr is NOT on graph
	endif

	Variable i
	String list = ImageNameList(graphName,";")	// first check the images
	for (i=0;i<ItemsInList(list);i+=1)
		Wave ww = ImageNameToWaveRef(graphName, StringFromList(i,list))
		if (WaveInClass(ww,classes))
			return item
		endif
	endfor

	list = TraceNameList(graphName,";",3)		// second check ordinary traces and contours
	for (i=0;i<ItemsInList(list);i+=1)
		Wave ww = TraceNameToWaveRef(graphName, StringFromList(i,list))
		if (WaveInClass(ww,classes))
			return item
		endif
	endfor
	return "("+item						// top graph does not contain a wave of desired class
End
//Function/S MenuItemsWaveClassOnGraph(item,classes,graphName)
//	String item					// item name to return, or "(item" to disable
//	String classes					// list of classes to check for (semi-colon separated)
//	String graphName				// name of graph, use "" for top graph
//
//	Variable i
//	String list = imageNameList("",";")	// first check the images
//	for (i=0;i<ItemsInList(list);i+=1)
//		Wave ww = ImageNameToWaveRef(graphName, StringFromList(i,list))
//		if (WaveInClass(ww,classes))
//			return item
//		endif
//	endfor
//
//	list = TraceNameList("",";",3)		// second check ordinary traces and contours
//	for (i=0;i<ItemsInList(list);i+=1)
//		Wave ww = TraceNameToWaveRef(graphName, StringFromList(i,list))
//		if (WaveInClass(ww,classes))
//			return item
//		endif
//	endfor
//	return "("+item						// top graph does not contain a wave of desired class
//End


// This is for when we want to check if any folder under the current folder contains wave with a certain class
Function/S MenuItemFolderWithClassExists(item,classes,optionsStr,[invisible,all])
	String item						// string that you want to appear in menu
	String classes					// semi-colon separated list of wave classes, can use "*" in classes
	String optionsStr				// options that are found in WaveList function optionsStr
	Variable invisible			// controls menu item when conditions not met: true -> menu item absent, false or absent -> menu item grayed out
	Variable all					// when all is TRUE, then all of the classes in waveClassList must be present, not just one
	invisible = ParamIsDefault(invisible) ? 0 : invisible
	invisible = numtype(invisible) ? 0 : invisible
	all = ParamIsDefault(all) ? 0 : !(!all)
	all = numtype(all) ? 0 : all

	String list = WaveListClass(classes,"*",optionsStr,all=all)	// check current folder
	if (strlen(list)<1)
		list = FoldersWithWaveClass("",classes,"*",optionsStr,all=all)
	endif
	if (invisible)
		return SelectString(strlen(list),"",item)
	endif
	return SelectString(strlen(list),"(","")+item
End


// This is really useful with an  Execute/P ... command
// e.g.  MenuItemIfWindowAbsent("Include ABC Support","ABC.ipf","WIN:128"), Execute/P "INSERTINCLUDE  \"ABC\"";Execute/P "COMPILEPROCEDURES "
Function/S MenuItemIfWindowAbsent(item,win,options)		// Shows menu item if win NOT present
	String item			// the string that appears in the menu
	String win			// may contains wildcard
	String options		// options that are in WinList()
	Variable present = (strlen(WinList(win,"",options)))>0
	return SelectString(present,"","(")+item
End
//
Function/S MenuItemIfWindowHidden(item,win)		// Shows menu item if win NOT present
	String item
	String win
	GetWindow/Z $win, hide
	return SelectString(V_flag,"(","")+item
End
//Function/S MenuItemIfWindowAbsent(item,win)		// Shows menu item if win NOT present
//	String item
//	String win
//
//	GetWindow/Z $win, hide
//	return SelectString(V_flag,"(","")+item
//End

// only show menu item when a single specific wave exists
Function/S MenuItemIfWaveExists(item,wname)
	String item
	String wname

	Variable there = Exists(wname)==1
	return SelectString(there,"(","")+item
End

// useful when just looking for a type of wave, no class information
Function/S MenuItemIfWavesExists(item,matchStr,optionsStr,[invisible])
	String item						// string that you want to appear in menu
	String matchStr
	String optionsStr				// options that are found in WaveList function optionsStr
	Variable invisible				// controls menu item when conditions not met: true -> menu item absent, false or absent -> menu item grayed out
	invisible = ParamIsDefault(invisible) ? 0 : invisible
	invisible = numtype(invisible) ? 0 : invisible
	String list = WaveList(matchStr,";",optionsStr)
	if (invisible)
		return SelectString(strlen(list),"",item)
	endif
	return SelectString(strlen(list),"(","")+item
End

// useful when working with a specific window, particularly with a Panel
Function/S MenuItemIfWinExists(item,win,optionsStr)
	String item								// menu item text
	String win								// win name (can contain a wild card)
	String optionsStr						// optionsStr from WinList()
	if (strlen(WinList(win,"",optionsStr))<1)
		return "("+item					// win not found, so disable menu item
	endif
	return item
End

// only show menu item when a funcName exists with specified values in optStr
//	e.g.  MenuItemIfFunctionExists("Write Detector values to EPICS...","EPICS_put_PV_num")
Function/S MenuItemIfFunctionExists(item,funcName,[optStr])
	String item
	String funcName
	String optStr					// key-values must match result of FunctionInfo() "key:value;"
	optStr = SelectString(ParamIsDefault(optStr),optStr,"")
	// optStr example is:  "PROCWIN:Procedure;RETURNTYPE:3;"

	String keyVals = FunctionInfo(funcName)
	if (strlen(keyVals)<1)		// no function info, add "("
		return "("+item
	endif

	if (strlen(optStr)>1)		// an optStr was passed, check for matching
		String key, value
		Variable i, N=ItemsInList(optStr)
		for (i=0;i<N;i+=1)
			key = StringFromList(0, StringFromList(i,optStr),":")
			value = StringByKey(key,optStr)
			if (!StringMatch(StringByKey(key,keyVals), value))
				return "("+item
			endif
		endfor
	endif

	return item						// either no optStr, or all key:values in optStr match
End

//  ============================ End of Option Menu Functions ============================  //
//  ======================================================================================  //


//  ======================================================================================  //
//  ============================== Start of Corner Labels ================================  //

// Puts text on the lower right corner showing when the layout was made, and on the lower left showing where it came from
Proc Layout_Corner_Labels_Style_()		// This is needed to make it show up in the "Layout Macros" menu
	Add_Corner_Labels_To_Layout()
End
Proc Add_Corner_Labels_To_Layout() : LayoutStyle
	PauseUpdate; Silent 1		// modifying window...
	Textbox/C/N=stamp0/F=0/A=RB/X=0.1/Y=0.1 "\\Z06\\{\"%s %s\",date(), time()}"
	Textbox/C/N=stamp1/F=0/A=LB/X=0.1/Y=0.1 "\\Z06\\{\"%s\",JZTutil#CornerStampWindow()}"
EndMacro
//
Static Function/S CornerStampWindow()
	String win=WinName(0,127+GIZMO_WIN_BIT,1)// Graph, Table, Layout, Notebook,Panel, or XOP window
	String gwin=""

	switch(WinType(win))
		case 3:						// a layout, find the first graph on this layout
			String list="x"
			Variable i
			for (i=0; strlen(gwin)==0 && strlen(list); i+=1)		// get first graph name
				list = LayoutInfo(win,num2istr(i))
				if (stringmatch(StringByKey("TYPE",list),"Graph"))
					gwin = StringByKey("NAME",list)
				endif
			endfor
			break
		case 1:						// a graph, gwin is win
		case 2:						// a table, gwin is win
		case GIZMO_WIN_TYPE:	// from an XOP, probably a gizmo
			gwin = win
			break
		default:						// only layout or graph
			gwin = ""
	endswitch
	gwin = SelectString(strlen(gwin),"",":")+gwin

	PathInfo home					// creates String s_path
	return S_path+IgorInfo(1)+gwin
End


// Puts text on the lower right corner showing when the graph was made, and on the lower left showing where it came from
Proc Add_Corner_Labels_To_Graph() : GraphStyle
	AddCornerLabelsToGraph()
EndMacro
Function AddCornerLabelsToGraph([outside,size])
	Variable outside
	Variable size					// font size
	outside = ParamIsDefault(outside)||numtype(outside) ? 0 : !(!outside)
	Variable defSize = outside ? 4 : 6
	size = ParamIsDefault(size) ? defSize : size
	size = size==limit(size,4,48) ? size : defSize
	if (strlen(WinList("*",";","WIN:1"))<1)
		return 1
	endif
	Variable bottom=0
	if (outside)
		GetWindow kwTopWin , psize
		Variable pBottom=V_bottom
		Variable pheight = V_bottom-V_top
		GetWindow kwTopWin , gsize
		Variable gBottom=V_bottom
		bottom = -floor(100*(gBottom-pBottom)/pheight)
	endif
	String str
	sprintf str,"%02d",size
	Textbox/C/N=stamp0/F=0/A=RB/X=0.2/Y=(bottom)/E=2 "\\Z"+str+"\\{\"%s %s\",date(), time()}"
	Textbox/C/N=stamp1/F=0/A=LB/X=0.2/Y=(bottom)/E=2 "\\Z"+str+"\\{\"%s\",JZTutil#CornerStampWindow()}"
	return 0
End

//  ================================ End of Corner Labels ================================  //
//  ======================================================================================  //


//  ======================================================================================  //
//  ========================== Start of Multiple Graphs on Page ==========================  //

// Put up multigraph layouts.  Each time you call this, it adds another graph to the layout
Window AppendMultiGraph2LayoutN() : Layout			// this is needed to make it appear in the "Layout Macros" menu
	AppendGraph2LayoutN(NaN,"","")
End
// Append a graph to a multiple graph layout.  This is for making multi-graph layouts
Function/S AppendGraph2LayoutN(Nmax,orientation,gName)
	Variable Nmax									// requested maximum number of graphs in the layout, one of Nlist
	String orientation								// this must be "portrait" or "landscape"
	String gName									// name of graph to append, if empty string, DoPrompt

	if (!stringmatch("portrait",orientation) && !stringmatch("landscape",orientation))
		orientation = ""
	endif

	String Nlist = "1;2;3;4;6;8;9;12;16;20"		// list of allowed values for Nmax
	Make/N=(ItemsInList(Nlist))/FREE Nvals=str2num(StringFromList(p,Nlist))
	Variable m=BinarySearchInterp(Nvals,Nmax)
	Nmax = (m>=0) ? Nvals[ceil(m)] : -1			// Nmax is now one of Nlist, or Nmax is -1

	Variable printIt=0
	String lname
	if (strlen(gName)<1 || Nmax<0)
		if (Nmax<0)
			lname = StringFromList(0,WinList("Layout*",";","WIN:4"))
			Nmax = NumberByKey("Nmax",GetUserData(lname,"","AppendGraph2Layout"),"=")
			Nmax = numtype(Nmax) ? -1 : Nmax
		endif
		Nmax = Nmax<0 ? 12 : Nmax				// 12 is default for absurd inputs
		Nmax = WhichListItem(num2istr(Nmax),Nlist)+1
		Prompt gName, "Graph to add to layout",popup,NOTonLayout(lname,WinList("*",";","WIN:1"))
		Prompt Nmax,"number of graphs/layout",popup,Nlist
		DoPrompt "Pick a Graph",gName,Nmax
		if (V_flag)
			return ""
		endif
		Nmax = str2num(StringFromList(Nmax-1,Nlist))
		printIt = 1
	endif
	if (strlen(gName)<1)
		DoAlert 0, "no graph to add"
		return ""
	endif

	lname = StringFromList(0,WinList("Layout"+num2istr(Nmax)+"_*",";","WIN:4"))		// get layout to append to
	if (strlen(LayoutInfo(lname,gName))>1)
		return lname								// graph is on layout, all done
	endif
	// check if this layout is full
	Variable i,N,NL = NumberByKey("NUMOBJECTS", LayoutInfo(lname,"Layout"))
	for (i=0,N=0;i<NL;i+=1)					// check each object in the layout
		N += stringmatch(StringByKey("TYPE",LayoutInfo("", num2istr(i))),"Graph")	// increlement if obj is graph
	endfor
	if (N>=Nmax)									// this layout is full, force creation of a new one
		lname = ""
	endif
	if (strlen(lname)<1)
		if (strlen(orientation)<1)					// orientation was not passed, ask now
			orientation = SelectString(Nmax==8,"Landscape","Portrait")
			Prompt orientation, "page orientation",popup,"Portrait;Landscape"
			DoPrompt "Pick a Graph",orientation
			if (V_flag)
				return ""
			endif
			printIt = 1
		endif
		lname = UniqueName("Layout"+num2istr(Nmax)+"_",8,0)		// need to make a newlayout
		NewLayout/P=$orientation
		ModifyLayout mag=0.5, units=0, frame=0
		DoWindow/C $lname
		SetWindow kwTopWin ,userdata(AppendGraph2Layout)=ReplaceNumberByKey("Nmax","",Nmax,"=")
	endif

	String page = StringByKey("PAGE", LayoutInfo(lname,"Layout"))	// get page size to determing landscape or portrait
	Variable aspect = (str2num(StringFromList(3,page,","))-str2num(StringFromList(1,page,",")))	// aspect = height/width
	aspect /= (str2num(StringFromList(2,page,","))-str2num(StringFromList(0,page,",")))
	orientation = SelectString(aspect>1,"landscape","portrait")
	String rc = StringByKey(num2istr(Nmax),"1:1,1;2:2,1;3:3,1;4:2,2;6:3,2;8:4,2;9:3,3;12:4,3;16:4,4;20:4,5")
	Variable rows=str2num(StringFromList(0,rc,","))
	Variable columns=str2num(StringFromList(1,rc,","))
	if (stringmatch("landscape",orientation))		// swap rows and columns for Landscape orientation
		Variable swap = rows
		rows = columns
		columns = swap
	endif
	AppendLayoutObject/F=0/W=$lname graph $gName
	String cmd
	sprintf cmd, "Tile /A=(%d,%d)/O=1",rows,columns
	Execute cmd
	RemoveLayoutObjects/W=$lname/Z stamp0,stamp1	// make sure that text boxes are written last, so they show
	Textbox/C/N=stamp0/W=$lname/F=0/A=RB/X=0.1/Y=0.1 "\\Z06\\{\"%s %s\",date(), time()}"
	Textbox/C/N=stamp1/W=$lname/F=0/A=LB/X=0.1/Y=0.1 "\\Z06\\{\"%s\", JZTutil#CornerStampWindow()}"

	if (printIt && (strlen(GetRTStackInfo(2))<1))
		printf "\tAppendGraph2LayoutN(%d,\"%s\",\"%s\")\r",Nmax,orientation,gName
	endif
	return lname
End
//
Static Function/T NOTonLayout(lname,listIN)
	String lname				// name of Layout
	String listIN				// list of things to check, remove items that are on layout

	if (strlen(lname)<1)	// no Layout, none of list are on it
		return listIN
	endif

	String item, listOUT=""
	Variable i, N=ItemsInList(listIN)
	for (i=0;i<N;i+=1)
		item = StringFromList(i,listIN)
		if (strlen(LayoutInfo(lname,item))<1)
			listOUT += item+";"
		endif
	endfor
	return listOUT
End
//
//Function xxx(Nmax)		// a test routine for AppendGraph2LayoutN()
//	Variable Nmax
//	Make/N=100/O y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12
//	SetScale/I x 0,10,"", y0,y1,y2,y3,y4,y5,y6,y7,y8,y9,y10,y11,y12
//	y0 = 0.2*x -1
//	y1 = sin(x/2) ; y2 = sin(x) ; y3 = sin(2*x) ; y4 = sin(3*x) ; y5 = sin(4*x)
//	y5 = cos(x/2) ; y6 = cos(x) ; y7 = cos(2*x) ; y8 = cos(3*x) ; y9 = cos(4*x)
//	y10 = exp(x/10)/3  ;  y11 = exp(-x/4)  ;  y12 = 2*exp(-x/2)-1
//	Variable i
//	String win
//	for (i=0;i<=12;i+=1)
//		win = "Graph"+num2istr(i)
//		if (strlen(WinList(win,"","WIN:1"))<1)
//			Display/K=1 $("y"+num2istr(i))
//			DoWindow/C $win
//			ModifyGraph tick=2, minor=1, standoff=0, mirror=1
//			ModifyGraph axOffset(left)=-4.7,axOffset(bottom)=-1.5
//		endif
//		AppendGraph2LayoutN(Nmax,"",win)
//	endfor
//End

//  =========================== End of Multiple Graphs on Page ===========================  //
//  ======================================================================================  //


//  ======================================================================================  //
//  =============================== Start of String Ranges ===============================  //

// This section is for dealing with random or usually non contiguous sequence of integers
// i.e.  you took data in scans 1-30, but scans 17, and 25 were no good.  So the valid range is "1-16,18-24,26-30"
//  or perhaps you want to combine scans "3,7,9"  The following routines handle those situations in a simple fashion.

ThreadSafe Function isValidRange(range)	// returns 1 if range is a valid string range
	String range								// note, "1-Inf" is a valid sub range, but "-Inf-6" is not

	range = ReplaceString(" ",range,"")
	String subRange
	Variable i, m, N=ItemsInList(range,","), first,last, step,prev=-Inf
	for (i=0;i<N;i+=1)						// check each item for validity
		subRange = StringFromList(i,range,",")
		first = str2num(subRange)
		if (numtype(first))					// this sub range is not even numeric or is Inf
			return 0
		elseif (first<=prev)				// start of this sub range is not after previous one
			return 0
		endif

		m = strsearch(subRange,"-",1)	// occurance of first "-", after first character
		if (m<0)									// a single number, a simple sub range
			prev = first
			continue
		endif
		last = str2num(subRange[m+1,Inf])
		step = str2num(StringFromList(1,subRange,":"))
		step = numtype(step)==2 ? 1 : step	// no step found, default to 1

		if (!(last>=first) || step<=0)	// must have first<=last and positive non-zero step
			return 0
		endif
		prev = floor((last-first)/step)*step+first	// last number in this sub range
	endfor
	return 1
End

ThreadSafe Function NextInRange(range,last)	// given a string like "2-5,7,9-12,50" get the next number in this compound range
										// the range is assumed to be monotonic, it returns NaN if no more values
	String range					// list defining the range
	Variable last					// last number obtained from this range, use -Inf to get start of range, it returns the next

	// find first item in the list that should use next
	String item,item0,item1
	Variable m,i,j,step,ret
	Variable first						// first value in an item
	do
		item = StringFromList(j,range,",")
		first = str2num(item)
		// do we need to check for NaN in first?

		if (numtype(first))
			return NaN
		elseif (last<first)				// skipping to the next item
			return first
		endif

		// if last>=first, check to see if item is a '2-5' type range
		m=-1							// remove any leading white space from item
		do
			m += 1
		while (char2num(item[m])<=32)
		item = item[m,strlen(item)-1]

		//check if a step size is specified
		item1=StringFromList(1,item,":")
		item0 = StringFromList(0,item,":") // now item0 may be a "2-5" type range or a single number
		step = str2num(item1)
		step = numtype(step)==2 ? 1 : step
		if (!(step>0))								// step must be > 0
			return NaN
		endif

		i = strsearch(item0,"-",1)		// location of first '-' after the first character
		if (i<0)							// only a single number, not a dash type range, keep looking
			j += 1
			continue
		endif
		// check to see if last was in the range of item, but not the last value
		if (last>=str2num(item0) && last<str2num(item0[i+1,Inf]))
			if(step ==1)
				return last+1
			else	// a little more math if step > 1
				if(mod(last - first, step) ==0) // an exact member of the sequence
					ret = last + step
				else
					ret = first + ceil((last - first)/step)*step
				endif
				if(ret <= str2num(item0[i+1,Inf]) ) // return only if the result is no greater than the end of the range, e.g. in the case of NextInRange("2-7:2",6)
					return ret
				endif
			endif
		endif
		j += 1
	while(strlen(item)>0)
	return NaN
End
//Function TestNextInRange(range)
//	String range
//	range = SelectString(strlen(range) ,"-16,-7--3,-1-2,5,50-54,99",range)
//	Variable i = -Inf
//	printf "for range = {%s},   ", range
//	do
//		i = NextInRange(range,i)
//		if (numtype(i))
//			break
//		endif
//		printf "%d  ", i
//	while (!numtype(i))
//	print ""
//End

ThreadSafe Function PointInRange(i,range)	// return the ith number in range, first number is i==0
	Variable i								// index to number in range
	String range							// a string range

	Variable N=ItemsInRange(range)
	i = round(i)
	if (numtype(i) || i<0 || i>=N)		// check for valid index
		return NaN
	endif
	Variable j, m=-Inf
	for (j=0;j<=i;j+=1)					// this is not the fastest, but it is simple
		m = NextInRange(range,m)
	endfor
	return m
End

ThreadSafe Function ItemsInRange(range)	// given a string like "2-5,7,9-12,50" get the total number of values in the range
	String range				// list defining the range
								// the range is assumed to be monotonic, it returns NaN on error
	String item							// each of the comma sepated items
	String item0, item1
	Variable len=0						// the result, number of values represented
	Variable m,i,j,step,N=ItemsInList(range,",")

	for (j=0;j<N;j+=1)				// loop over each item
		item = StringFromList(j,range,",")

		m=-1							// remove any leading white space from item
		do
			m += 1
		while (char2num(item[m])<=32)
		item = item[m,strlen(item)-1]

		item1 = StringFromList(1,item,":")	// stepsize, if specified with ":"
		item0 = StringFromList(0,item,":")	// start-end of range is specified before ":"
		step = str2num(item1)
		step = numtype(step)==2 ? 1 : step
		if (!(step>0))								// step must be > 0
			return NaN
		endif

		i = strsearch(item0,"-",1)		// location of first '-' after the first character
		if (i<0)							// only a single number, not a dash type range, keep looking
			len += 1
		else							// item0 is a dash type 
			len += ceil((str2num(item0[i+1,Inf])-str2num(item0)+1)/step)
		endif
	endfor
	return len
End
//	print ItemsInRange("-16,-7--3,-1-2,5,50-54,99")
//  17
//	print ItemsInRange("1-5")
//  5


//Function firstInRange(range)
//	String range
//	return str2num(range)
//End
//

ThreadSafe Function lastInRange(range)		// returns the last number in the range, lastInRange("3,5,9-20") returns 20
	String range
	Variable i,last,first,step
	String item0, item1

	i = strsearch(range,",",Inf,1)
	if (i>=0)									// remove previous comma separated items
		range = range[i+1,Inf]
	endif
	range = ReplaceString(" ",range,"")		// spaces do not count
	range = ReplaceString("\t",range,"")	// tabs do not count

	item1 = StringFromList(1,range,":")	// stepsize, if specified with ":"
	item0 = StringFromList(0,range,":")	// start-end of range is specified before ":"
	step = str2num(item1)
	step = numtype(step)==2 ? 1 : step
	if (!(step>0))									// step must be > 0
		return NaN
	endif

	i = strsearch(item0,"-",Inf,1)
	if (char2num(item0[i-1])==45)		// a double dash, we have a minus sign
		i -= 1
	endif
	i += i>0 ? 1 : 0							// increment i to skip over dash unless there is no dash in string, i<0 means no dash present
	last = str2num(item0[i,Inf])
	first = str2num(item0)
	return floor((last-first)/step)*step+first
End

ThreadSafe Function isInRange(range,m)// returns TRUE if m is a number in range
	String range							// list defining the range
	Variable m								// number of interest, is m part of range?

	String item							// each of the comma sepated items
	Variable i,j,N=ItemsInList(range,",")
	String item0, item1
	Variable step
	
	for (j=0;j<N;j+=1)					// loop over each comma separated item
		item = StringFromList(j,range,",")
		item = TrimLeadingWhiteSpace(item)
		i = strsearch(item,"-",1)		// location of first '-' after the first character
		if (i<0)							// only a single number, not a dash type range, keep looking
			if (m==str2num(item))
				return 1					// this number is m
			endif
		else								// item is a dash type
			item1 = StringFromList(1,item,":")	// stepsize, if specified with ":"
			item0 = StringFromList(0,item,":")	// everything else before ":"
			step = str2num(item1)
			step = numtype(step)==2 ? 1 : step
			if (!(step>0))								// step must be > 0
				return 0
			endif

			if (m>=str2num(item0) && m<=str2num(item0[i+1,Inf]))  //  m is in this continuous range
				return (mod((m - str2num(item0)), step)== 0)  // true only if (m - first) can be divided by step
			endif
		endif
	endfor
	return 0
End

Function/T subRangeOfRange(fullRange,jlo,jhi)
	// returns new string range containing only values in [jlo,jhi]
	String fullRange							// original string range
	Variable jlo,jhi							// want new range to go from jlo ... jhi
	jlo = round(jlo)
	jhi = round(jhi)

	String item, subRange=""
	Variable i, delta, ifirst, ilast, stride
	for (i=0; 1; i+=1)
		item = StringFromList(i,fullRange,",")
		ifirst = str2num(item)
		ilast = lastInRange(item)
		if (numtype(ifirst+ilast))		// finished all the simple ranges
			break
		elseif (ilast < jlo)				// starting point is further on, try next item
			continue
		elseif (ifirst > jhi)				// any further simple ranges are past jhi, done
			break
		endif

		stride = str2num(StringFromList(1,item,":"))
		stride = stride > 0 ? stride : 1
		if (strlen(subRange)==0)
			delta = max(ceil((jlo-ifirst)/stride),0)
			jlo = ifirst + stride*delta	// first point equal or greater than jlo in item
			subRange = num2istr(jlo)		// start to build the first piece of subRange
			if (jhi >= ilast && ilast>ifirst)	// add all of this simple range
				subRange += "-"+num2istr(ilast)
				subRange += SelectString(stride>1, "", ":"+num2istr(stride) )	// add the :stride
			elseif (ilast>ifirst)			// can only use part of this simple range
				jhi = ifirst + stride*floor((jhi-ifirst)/stride)	// last point less than or equal to jhi in item
				subRange += "-"+num2istr(jhi)
				subRange += SelectString(stride>1, "", ":"+num2istr(stride) )	// add the :stride
			endif
		elseif (ilast <= jhi)				// jhi is past this simple range, just append item to subRange
			subRange += ","+item
		else										// ilast (from item) is in this item (this is the last simple range)
			jhi = ifirst + stride*floor((jhi-ifirst)/stride)	// last point less than or equal to jhi in item
			subRange += ","+num2istr(ifirst)	// start to build the first piece of subRange
			if (jhi > ifirst)					// something to add to subRange
				subRange += "-"+num2istr(jhi)
				subRange += SelectString(stride>1, "", ":"+num2istr(stride) )	// add the :stride
			endif
		endif
	endfor

	return subRange
End
//	Function test()
//		Variable bad
//		bad = bad || test1("1-100,105-140",10,20, "10-20")
//		bad = bad || test1("1-100,105-140",99,107, "99-100,105-107")
//		bad = bad || test1("1-15",10,20, "10-15")
//		bad = bad || test1("-10-100,105-140",99,107, "99-100,105-107")
//		bad = bad || test1("-10-100,105-140",-5,107, "-5-100,105-107")
//		bad = bad || test1("-10-100,105-140",-50,107, "-10-100,105-107")
//		bad = bad || test1("10-100,105-140",10,20, "10-20")
//		bad = bad || test1("10-100,105-140",5,20, "10-20")
//		bad = bad || test1("-10-100,105-140",-50,500, "-10-100,105-140")
//		bad = bad || test1("1-100,105-140",-50,107, "1-100,105-107")
//		bad = bad || test1("1-100,105-140",5,107, "5-100,105-107")
//		bad = bad || test1("1-100,105-140",5,500, "5-100,105-140")
//		bad = bad || test1("1-100,105-140,490-510",5,500, "5-100,105-140,490-500")
//	
//		bad = bad || test1("0-100:2",10,20, "10-20:2")
//		bad = bad || test1("0-100:2",-10,20, "0-20:2")
//		bad = bad || test1("0-100:2",-10,100, "0-100:2")
//		bad = bad || test1("0-100:2",-10,101, "0-100:2")
//		bad = bad || test1("0-100:2,105-140",98,107, "98-100:2,105-107")
//		bad = bad || test1("1-100:2,105-140",95,107, "95-99:2,105-107")
//		print SelectString(bad,"all OK", "ERROR")
//	End
//	Static Function test1(fullRange,jlo,jhi, answer)
//		String fullRange
//		Variable jlo,jhi
//		String answer
//		String subRange = subRangeOfRange(fullRange,jlo,jhi)
//		Variable bad = !StringMatch(subRange,answer)
//		if (bad)
//			printf "%ssubRangeOfRange(\"%s\", %d, %d) --> \"%s\"\r",SelectString(bad, "    ", "*** "), fullRange,jlo,jhi,subRange
//		endif
//		return bad
//	End



// Caution expandRange("1-100000",";") will produce a very long string!  Use NextInRange() to avoid this problem
ThreadSafe Function/S expandRange(range,sep)	// expand a string like "2-5,7,9-12,50" to "2,3,4,5,7,9,10,11,12,50"
	String range					// series of numberseparated by commas and dashes, white is space igaored
	String sep						// separates final list, usually ";"
	if (strsearch(range,"Inf",0,2)>=0)	// cannot put an infinite number of characters into a string
		return ""
	endif
	if (strlen(sep)<1)				// sep defaults to ';'
		sep = ";"
	endif
	Variable i1,i2,i
	String str,out=""
	Variable N=ItemsInList(range,",")
	if (N<1)
		return ""
	endif
	Variable j=0, step
	String item1,item0
	do
		str = StringFromList(j, range, ",")
		Variable m=-1				// remove any leading white space
		do
			m += 1
		while (char2num(str[m])<=32)
		str = str[m,strlen(str)-1]

		// now check str to see if it is a range like "20-23" or "20-30:5"
		item1 = StringFromList(1,str,":")	// stepsize, if specified with ":"
		item0 = StringFromList(0,str,":")	// start-end of range is specified before ":"
		step = str2num(item1)
		step = numtype(step)==2 ? 1 : step
		if (!(step>0))								// step must be > 0
			return ""
		endif
		
		i1 = str2num(item0)                        // i1 is the start of the range
		i = strsearch(item0,"-",strlen(num2str(i1)))		// position of "-" after first number
		if (i>0)
			i2 = str2num(item0[i+1,inf])  // i2 is the specified end of the range
			i = i1
			do
				out += num2str(i)+sep
				i += step
			while (i<=i2)
		else
			out += num2str(i1)+sep
		endif
		j += 1
	while (j<N)

	i = strlen(out)-1
	if (char2num(out[i])==char2num(sep))  // remove the trailing sep character
		out = out[0,i-1]
	endif
	return out
End

// This is the inverse of expandRange()
ThreadSafe Function/S compressRange(range,sep) 	// take a range like "1;2;3;4;5;9;10;11" change it to "1-5,9-11"
	String range
	String sep							// sep is the separator used, will be replaced with commas and dashes

	String comp=""						// the compressed string
	String num
	Variable j,first,last,i=0,aa,bb,cc,step,in_subrange,write_subrange,writeend
	Variable N=ItemsInList(range,sep)
	if (N<1)
		return ""
	endif
	range = SortList(range,sep,2)				// make list monotonic
	
	if(N<3)  	// make no change if list has 1 or 2 elements
		comp = ","+ReplaceString(sep,range,",")			// change all sep to ","
		if (StringMatch(comp[strlen(comp)-1],",")>=0)	// remove a possible trailing ","
			comp = comp[0,strlen(comp)-2]
		endif
	else	// if list has more than 3 elements
		in_subrange = 0
		write_subrange = 0
		writeend = 0
		last = str2num(StringFromList(0,range,sep)) - 2
		for(i=2;i<N;i+=1)
			aa = str2num(StringFromList(i-2,range,sep))
			bb = str2num(StringFromList(i-1,range,sep))
			cc = str2num(StringFromList(i,range,sep))
			//if((cc-bb) == (bb-aa) && aa>last) // if the 3 consecutive numbers are equally spaced, and aa is not part of previous subrange
			if((cc-bb) == (bb-aa)) // if the 3 consecutive numbers are equally spaced
				if(!in_subrange && aa>last)  // no existing subrange, and aa is not part of previous subrange, then start a new one
					first = aa
					step = bb-aa
					last = cc
					in_subrange = 1
				elseif(!in_subrange && aa==last) // no existing subrange, but aa is the end of the previous subrange, then write down the subrange
					write_subrange = 1
				else  // already have an active subrange
					last = cc
				endif
				if(i==(N-1) && in_subrange) // if hit the last number while still in a subrange, then just write it down.
					write_subrange = 1
				elseif(i==(N-1)) // if hit the last number, and there's no active subrange, then write down the last two numbers
					writeend = 2
				endif
			else  // if the3 are not equally spaced
				if(in_subrange) // already started a subrange, then close it out
					in_subrange = 0
				elseif(aa==last) // no active subrange, but aa is the end of previous subrange, then write down the subrange
					write_subrange = 1
				else  // no active or recent subrange at all, then write down single item aa
					comp += ","+num2str(aa) 
				endif
				if(i == (N-1)) // if hitting the last number, then write down single elements cc or bb&cc
					if(bb == last)  // if bb is the end of the recently-closed subrange
						writeend = 1
						write_subrange = 1
					else    // if no active or recent subrange
						writeend = 2
					endif
				endif
			endif
			if(write_subrange)
				if(step ==1)
					comp += ","+num2str(first)+"-"+num2str(last)
				elseif (step==0)
					comp += ","+num2str(first)
				else
					comp += ","+num2str(first)+"-"+num2str(last)+":"+num2str(step)
				endif
				write_subrange = 0
			endif
			switch(writeend)
				case 1:
					comp += ","+num2str(cc) 
					break
				case 2:
					comp += ","+num2str(bb) + ","+num2str(cc) 
			endswitch
		endfor
	endif
	
	//remove the leading ","
	if(strlen(comp)>0)
		comp = comp[1,Inf]
	endif
	return comp
End
//Function test_compressRange()
//	String range
//	range = ""
//	printf "'%s' ---> '%s'\r",range, compressRange(range,";")
//	range = "1;2;3;4;5;9;10;11"
//	printf "'%s' ---> '%s'\r",range, compressRange(range,";")
//	range = "4"
//	printf "'%s' ---> '%s'\r",range, compressRange(range,";")
//	range = "4;7"
//	printf "'%s' ---> '%s'\r",range, compressRange(range,";")
//	range = "-10;-9;-8;-7;-6;-5;-3;-2;-1;0;1;2;7;9;22"
//	printf "'%s' ---> '%s'\r",range, compressRange(range,";")
//	range = "7;6;4;5;2;3"
//	printf "'%s' ---> '%s'\r",range, compressRange(range,";")
//	range = "-1;1;0;-3;2;-2"
//	printf "'%s' ---> '%s'\r",range, compressRange(range,";")
//	range = "1;1;1;10;10;10;20;21;22;"
//	printf "'%s' ---> '%s'\r",range, compressRange(range,";")
//End

////// not used ////////////// not yet compatible with "1-9:3" format /////////////
ThreadSafe Function/T compactRange(in) // take a range and return the most compact way of describing that range, e.g.  "1,2,3,4,6" -> "1-4,6"
	String in							// list defining the starting range, in is assumed to be monotonic
	String out=""						// list defining the minimalized output range

	Variable i,j0,j1					// i's come from in, j's refer to out
	i = str2num(in)
	if (numtype(i)==2)
		return ""
	endif

	String item						// one comma separated item
	Variable pitem					// index of item
	j0 = i
	j1 = i
	for (pitem=0,item=StringFromList(0,in,","); strlen(item); pitem+=1,item=StringFromList(pitem,in,","))	// for each comma separated item
		i = str2num(item)
		if ((i-j1)>1)					// this item is more then 1 from the last j, add to out
			if (j0==j1)				// a single number range
				out += num2istr(j0)+","
			else						// more then one in a dash range
				out += num2istr(j0)+"-"+num2istr(j1)+","
			endif
			j0 = i
		endif
		j1 = lastInRange(item)
	endfor
	if (j0==j1)						// a single number range
		out += num2istr(j0)
	else								// more then one in a dash range
		out += num2istr(j0)+"-"+num2istr(j1)
	endif
	return out
End

//  ================================ End of String Ranges ================================  //
//  ======================================================================================  //


//  ======================================================================================  //
//	 =============================== Start of Progress Panel =============================== //

Function/T ProgressPanelStart(percentName,[stop,showTime,status,wname,part,total])	// display a progress bar
//	if the user does a "DoUpdate/W=$wname", then V_flag will be set to 2 if the stop button was pushed
	String percentName									// name of global value to use, if not a global variable then set value to 0
	Variable stop											// if true, include a stop button
	Variable showTime									// if true, include the ending time on panel
	String status											// if passed, make room for a status line and set it to status
	String wname											// if Progress window named wname exists, exit without doing anything
	Variable part,total									// if entered, currently doing part 'part' of 'total' parts, used with wname, part starts at 0
	stop = ParamIsDefault(stop) ? 0 : stop
	stop = NumberByKey("IGORVERS",IgorInfo(0))>=6.10 ? stop : 0	// stop feature requires version 6.10 or above
	showTime = ParamIsDefault(showTime) ? 0 : showTime
	part = ParamIsDefault(part) ? 0 : part
	total = ParamIsDefault(total) ? 1 : total
	Variable showStatus=1
	if (ParamIsDefault(status))
		status = ""
		showStatus = 0
	endif
	if (ParamIsDefault(wname))
		wname = ""
	endif

	if (WinType(wname)!=7 || strlen(wname)==0)	// passed wname is not a panel, create new one
		Variable right = stop ? 695 : 630,  bottom=117, new=0
		bottom += showTime ? 20 : 0
		bottom += showStatus ? 20 : 0
		NewPanel/K=1/W=(330,87,right,bottom)/N=Progress
		wname = S_name									// save the name of the window
		new = 1
	endif

	if (!new)												// panel already exists
		DoWindow/F $wname								// do not create any buttons or display fields, just bring to front
		return wname
	endif

	// create a new panel
	ValDisplay progressValdisp, win=$wname, pos={5,5},size={288,25},font="Helvetica",fSize=18,format="%d%%"
	ValDisplay progressValdisp, win=$wname, limits={0,100,0},barmisc={0,50},highColor= (19368,32650,65196)
	if (exists(percentName)==2)						// the global exists, use it
		NVAR percent = $percentName
		percent = limit(percent,0,100)
		ValDisplay progressValdisp,win=$wname, value= #percentName
		SetWindow $wname userdata(percent)=num2str(percent)
	else													// no global, just set to zero
		ValDisplay progressValdisp,win=$wname, value= #"0"
		SetWindow $wname userdata(percent)="0"
	endif

	if (stop)
		Button stopButton,pos={299,4},size={50,20},title="Break"
	endif

	Variable top=29
	if (showStatus)
		TitleBox statusTitle,pos={1,top},size={213,16},fSize=12,frame=0,title=status
		top += 20
	endif
	if (showTime)
		TitleBox timeTitle,pos={1,top},size={213,16},fSize=12,frame=0,title=" "
	endif

#if NumberByKey("IGORVERS",IgorInfo(0))>=6.10
	DoUpdate/W=$wname/E=1							// mark as a progress window
#else
	DoUpdate
#endif
	String str = ""
	sprintf str,"%.3f",stopMSTimer(-2)*1e-6
	SetWindow $wname userdata(startTimeSec)=str
	SetWindow $wname userdata(lastTimeSec)=str		// last time updated
	sprintf str,"%.3f",stopMSTimer(-2)*1e-6 - DateTime
	SetWindow $wname userdata(epoch)=str			// needed to get correct time of day
	SetWindow $wname userdata(showTime)=num2istr(showTime)
	SetWindow $wname userdata(status)=status
	SetWindow $wname userdata(stop)=num2istr(stop)
	SetWindow $wname userdata(startingFunc)=GetRTStackInfo(2)
	SetWindow $wname userdata(part)=num2str(part)
	SetWindow $wname userdata(total)=num2str(total)
//printf "starting function = '%s'\r",GetRTStackInfo(2)
	return wname
End
//
Function ProgressPanelUpdate(wname,percent,[status,resetClock])	// update a progress bar
	String wname											// window name
	Variable percent										// percent done (% !!)
	String status											// if passed, update the status line
	Variable resetClock									// reset start time to now if TRUE

	Variable newStatus = !ParamIsDefault(status)
	if (newStatus)
		SetWindow $wname userdata(status)=status
	else
		status = GetUserData(wname,"","status")
	endif

	Variable part = str2num(GetUserData(wname,"","part"))
	Variable total = str2num(GetUserData(wname,"","total"))
	percent = 100*part/total + percent/total			// percent ot total done

	String str
	if (resetClock)
		sprintf str,"%.3f",stopMSTimer(-2)*1e-6
		SetWindow $wname userdata(startTimeSec)=str	// reset all times to now
		SetWindow $wname userdata(lastTimeSec)=str
	endif

	ValDisplay progressValdisp,win=$wname, value= #num2istr(floor(limit(percent,0,100)))
	Variable showTime = str2num(GetUserData(wname,"","showTime"))
	if (showTime && percent>0)
		Variable start = str2num(GetUserData(wname,"","startTimeSec"))
		Variable last = str2num(GetUserData(wname,"","lastTimeSec"))
		Variable now = stopMSTimer(-2)*1e-6
		if (now-last > 2)
			Variable epoch = str2num(GetUserData(wname,"","epoch"))
			Variable remain = (now-start) * (100-percent)/percent
			Variable ifmt = (remain < 6*60)
			sprintf str, "should end in %s,   at    %s",Secs2Time(remain,4+ifmt),Secs2Time(now+remain-epoch,ifmt)
			str += SelectString(remain > 24*3600,"","  on  "+Secs2Date(now+remain,2))	// more than 1 day
			TitleBox timeTitle, win=$wname, title=str
			sprintf str,"%.3f",now
			SetWindow $wname userdata(lastTimeSec)=str		// last time updated, is now
		endif
	endif
	if (strlen(status) || newStatus)
		TitleBox statusTitle, win=$wname, title=status
	endif
	if (strlen(wname))
		DoWindow/F $wname								// keep progress window in front
	endif

	Variable done=0
#if NumberByKey("IGORVERS",IgorInfo(0))>=6.10
	DoUpdate/W=$wname									// update only progress window
	done = V_Flag == 2									// stop button on progress window was pushed
#else
	DoUpdate												// update all windows, no stop button
#endif
	return done
End
//
Function SecondsInProgressPanel(wname)				// total time in the Progress Panel
	String wname											// window name
	Variable start = str2num(GetUserData(wname,"","startTimeSec"))
	return (stopMSTimer(-2)*1e-6 - start)
End

Function ProgressPanelKill(wname)					// kills a progress bar, will not kill it if  it was created by a routine higher up in the current stack
	String wname											// window name

	String stackList=GetRTStackInfo(0)
	String startingFunc=GetUserData(wname,"","startingFunc")
	Variable i = WhichListItem(startingFunc,stackList)
	Variable seconds = SecondsInProgressPanel(wname)
	if (i<0 || i >= ItemsInList(stackList)-2)
		DoWindow/K $wname
	endif
	return seconds
End
//
Function ProgressPanelNewPart(wname,part,total)	// update part and/or total in the progress window, only updates vlaues if they are valid
	String wname											// window name
	Variable part,total									// if entered, currently doing part 'part' of 'total' parts, used with wname, part starts at 0

	if (WinType(wname)!=7)							// window not a panel
		return 1
	endif
	if (part>=0)											// part is valid, update it
		SetWindow $wname userdata(part)=num2str(part)
	endif
	part = numtype(part) ? 0 : part
	if (part<total)											// total is valid update it
		SetWindow $wname userdata(total)=num2str(total)
	endif
	return 0
End


//Function/T ProgressPanelStart(percentName,[stop,showTime])	// display a progress bar
////	if the user does a "DoUpdate/W=$wname", then V_flag will be set to 2 if the stop button was pushed
//	String percentName									// name of global value to use, if not a global variable then set value to 0
//	Variable stop											// if true, include a stop button
//	Variable showTime									// if true, include the ending time on panel
//	stop = ParamIsDefault(stop) ? 0 : stop
//	stop = NumberByKey("IGORVERS",IgorInfo(0))>=6.10 ? stop : 0	// stop feature requires version 6.10 or above
//	showTime = ParamIsDefault(showTime) ? 0 : showTime
//
//	Variable right = stop ? 695 : 630,  bottom = showTime ? 137 : 117
//	NewPanel/K=1/W=(330,87,right,bottom)/N=Progress
//	String wname = S_name								// save the name of the window
//	ValDisplay progressValdisp, win=$wname, pos={5,5},size={288,25},font="Helvetica",fSize=18,format="%d%%"
//	ValDisplay progressValdisp, win=$wname, limits={0,100,0},barmisc={0,50},highColor= (19368,32650,65196)
//	if (exists(percentName)==2)						// the global exists, use it
//		NVAR percent = $percentName
//		percent = limit(percent,0,100)
//		ValDisplay progressValdisp,win=$wname, value= #percentName
//	else													// no global, just set to zero
//		ValDisplay progressValdisp,win=$wname, value= #"0"
//	endif
//
//	if (stop)
//		Button stopButton,pos={299,4},size={50,20},title="Break"
//	endif
//	if (showTime)
//		TitleBox timeTitle,pos={1,29},size={213,16},fSize=12,frame=0,title=" "
//	endif
//#if NumberByKey("IGORVERS",IgorInfo(0))>=6.10
//	DoUpdate/W=$wname/E=1							// mark as a progress window
//#else
//	DoUpdate
//#endif
//
//	String str = num2istr(DateTime)
//	SetWindow $wname userdata(startTimeSec)=str
//	SetWindow $wname userdata(lastTimeSec)=str		// last time updated
//	SetWindow $wname userdata(showTime)=num2istr(showTime)
//	SetWindow $wname userdata(stop)=num2istr(stop)
//	SetWindow $wname userdata(percent)=num2str(percent)
//	return wname
//End
////
//Function ProgressPanelUpdate(wname,percent)		// update a progress bar
//	String wname											// window name
//	Variable percent										// percent done (% !!)
//
//	ValDisplay progressValdisp,win=$wname, value= #num2istr(floor(limit(percent,0,100)))
//	Variable showTime = str2num(GetUserData(wname,"","showTime"))
//	if (showTime && percent>0)
//		Variable start = str2num(GetUserData(wname,"","startTimeSec"))
//		Variable last = str2num(GetUserData(wname,"","lastTimeSec"))
//		Variable now = DateTime
//		if (now-last > 2)
//			Variable remain = (now-start) * (100-percent)/percent
//			String str
//			if (remain < 5*60)							// under 10 min
//				sprintf str, "should end in %s,   at    %s",Secs2Time(remain,5),Secs2Time(now+remain,1)
//			else
//				sprintf str, "should end in %s,   at    %s",Secs2Time(remain,4),Secs2Time(now+remain,0)
//			endif
//			str += SelectString(remain > 24*3600,"","  on  "+Secs2Date(now+remain,2))	// more than 1 day
//			TitleBox timeTitle,title=str
//			SetWindow $wname userdata(lastTimeSec)=num2istr(now)	// last time updated, is now
//		endif
//	endif
//
//	Variable done=0
//#if NumberByKey("IGORVERS",IgorInfo(0))>=6.10
//	DoUpdate/W=$wname									// update only progress window
//	done = V_Flag == 2									// stop button on progress window was pushed
//#else
//	DoUpdate												// update all windows, no stop button
//#endif
//	return done
//End
//

//Function testProgress()
//	String progressWin = ProgressPanelStart("",stop=1,showTime=1,status="starting")	// display a progress bar
//	Variable i,N=300
//	for (i=0;i<N;i+=1)
//		if (mod(i,100)==0)
//			if (ProgressPanelUpdate(progressWin,i/N*100,status="on number "+num2istr(i)))	// update progress bar
//				break											//   and break out of loop
//			endif
//		else
//			if (ProgressPanelUpdate(progressWin,i/N*100))	// update progress bar
//				break											//   and break out of loop
//			endif
//		endif
//	endfor
//	printf "total execution time = %s\r",Secs2Time(SecondsInProgressPanel(progressWin),5,0)
//	ProgressPanelUpdate(progressWin,i/N*100,status="done")
//	Sleep/S 1
//	DoWindow/K $progressWin
//End
//  =============================== End of Progress Panel ================================  //
//  ======================================================================================  //


//  ======================================================================================  //
//  ================================ Start of Generic XML ================================  //
//
//	XML support	 (occurance optionally allows selecting the the occuranceth instance of xmltag), note vectors usually delimited by a space
//
//	XMLNodeList(buf)											returns a list with all top level nodes in buf
//	XMLtagContents(xmltag,buf,[occurance])			returns the contents of xmltag
//	XMLtagContents2List(xmltag,buf,[occurance,delimiters])	returns the contents of xmltag as a list, useful for vectors in the contents
//	XMLattibutes2KeyList(xmltag,buf)					return a list with all of the attribute value pairs for xmltag
//	XMLremoveComments(str)									remove all xml comments from str
//
//	for XMLtagContents() and XMLattibutes2KeyList()
// when there are MANY occurances of xmltag, do not use occurance, but rather:
//	Variable start=0
//	String feed
//	do
//		feed = XMLtagContents("feed",buf, start=start)
//		other code goes here ...
//	while(strlen(feed))

ThreadSafe Function/T XMLNodeList(buf)			// returns a list of node names at top most level in buf
	String buf
	String name,nodes=""
	Variable i0=0, i1,i2
	do
		i0 = strsearch(buf,"<",i0)					// find start of a tag
		if (i0<0)
			break
		endif
		i1 = strsearch(buf," ",i0)					// find end of tag name using i1 or i2, end will be in i1
		i1 = i1<0 ? Inf : i1
		i2 = strsearch(buf,">",i0)
		i2 = i2<0 ? Inf : i2
		i1 = min(i1,i2)
		if (numtype(i1) || (i1-i0-1)<1)
			break
		endif
		name = ReplaceString(";",buf[i0+1,i1-1],"_")// name cannot contain semi-colons
		nodes += name+";"

		i2 = strsearch(buf,"</"+name+">",i0)		// find the closer for this tag, check for '</name>'
		if (i2<0)
			i0 = strsearch(buf,">",i1+1)				// no '</name>', just a simple node
		else
			i0 = i2 + strlen(name) + 3				// first character after '</name>'
		endif
	while(i0>0)
	return nodes
End


ThreadSafe Function/T XMLtagContents(xmltag,buf,[occurance,start])
	String xmltag
	String buf
	Variable occurance									// use 0 for first occurance, 1 for second, ...
	Variable &start										// offset in buf, start searching at buf[start], new start is returned
																// both occurance and start may be used together, but usually you only want to use one of them
	occurance = ParamIsDefault(occurance) ? 0 : occurance
	Variable startLocal = ParamIsDefault(start) ? 0 : start
	startLocal = numtype(startLocal) || startLocal<1 ? 0 : round(startLocal)

	Variable i0,i1
	if (startLocal>0)
		i0 = startOfxmltag(xmltag,buf[startLocal,Inf],occurance) + startLocal
	else
		i0 = startOfxmltag(xmltag,buf,occurance)
	endif
	if (i0<0)
		return ""
	endif
	i0 = strsearch(buf,">",i0)						// character after '>' in intro
	if (i0<0)												// this is an ERROR
		return ""
	endif
	i0 += 1													// start of contents

	i1 = strsearch(buf,"</"+xmltag+">",i0)-1	// character just before closing '<tag>'
	startLocal = strsearch(buf,">",i1)+1			// character just after closing '<tag>'

	if (i1<i0 || i1<0)
		if (!ParamIsDefault(start))
			start = -1
		endif
		return ""
	endif

	if (!ParamIsDefault(start))
		start = startLocal
	endif

	return buf[i0,i1]
End


ThreadSafe Function/T XMLtagContents2List(xmltag,buf,[occurance,delimiters]) //reads a tag contensts and converts it to a list
	String xmltag
	String buf
	Variable occurance				// use 0 for first occurance, 1 for second, ...
	String delimiters					// characters that might be used for delimiters (NOT semi-colon), default is space, tab, cr, or nl = " \t\r\n"
	occurance = ParamIsDefault(occurance) ? 0 : occurance
	if (ParamIsDefault(delimiters) || strlen(delimiters)==0)
		delimiters = " \t\r\n"							// the usual white-space characters
	endif

	String str = XMLtagContents(xmltag,buf,occurance=occurance)
	str = ReplaceString(";",str,"_")				// cannot have any semi-colons in input string

	Variable i
	for (i=0;i<strlen(delimiters);i+=1)
		str = ReplaceString(delimiters[i],str,";")		// replace every occurance of a character in delimiters with a semi-colon
	endfor

	do
		str = ReplaceString(";;",str,";")			// replace all multiple semi-colons with a single semi-colon
	while(strsearch(str,";;",0)>=0)

	if (char2num(str[0])==char2num(";"))			// remove any leaing semi-colon
		str = str[1,Inf]
	endif
	return str
End


ThreadSafe Function/T XMLattibutes2KeyList(xmltag,buf,[occurance,start])// return a list with all of the attribute value pairs for xmltag
	String xmltag											// name of tag to find
	String buf												// buf containing xml
	Variable occurance									// use 0 for first occurance, 1 for second, ...
	Variable &start										// offset in buf, start searching at buf[start], new start is returned
																// both occurance and start may be used together, but usually you only want to use one of them
	occurance = ParamIsDefault(occurance) ? 0 : occurance
	Variable startLocal = ParamIsDefault(start) ? 0 : start
	startLocal = numtype(startLocal) || startLocal<1 ? 0 : round(startLocal)

	Variable i0,i1
	if (startLocal>0)
		i0 = startOfxmltag(xmltag,buf[startLocal,Inf],occurance) + startLocal
	else
		i0 = startOfxmltag(xmltag,buf,occurance)
	endif
	if (i0<0)
		return ""
	endif
	i0 += strlen(xmltag)+2								// start of attributes
	i1 = strsearch(buf,">",i0)-1						// end of attributes
	String key, value, keyVals=""

	if (i1 < i0)											// this is an ERROR
		startLocal = -1
	else
		startLocal = i1 + 2								// character just after closing '>'
		// parse buf into key=value pairs
		buf = buf[i0,i1]
		buf = ReplaceString("\t",buf," ")
		buf = ReplaceString("\r",buf," ")
		buf = ReplaceString("\n",buf," ")
		buf = TrimFrontBackWhiteSpace(buf)
		i0 = 0
		do
			i1 = strsearch(buf,"=",i0,0)
			key = TrimFrontBackWhiteSpace(buf[i0,i1-1])
			i0 = strsearch(buf,"\"",i1,0)+1				// character after the first double quote around value
			i1 = strsearch(buf,"\"",i0,0)-1				// character before the second double quote around value
			value = buf[i0,i1]
			if (strlen(key)>0)
				keyVals = ReplaceStringByKey(key,keyVals,value,"=")
			endif
			i0 = strsearch(buf," ",i1,0)					// find space separator, set up for next key="val" pair
		while(i0>0 && strlen(key))
	endif

	if (!ParamIsDefault(start))							// set start if it was passed
		start = startLocal
	endif
	return keyVals
End


ThreadSafe Function/T XMLremoveComments(str)	// remove all xml comments from str
	String str
	Variable i0,i1
	do
		i0 = strsearch(str,"<!--",0)					// start of a comment
		i1 = strsearch(str,"-->",0)					// end of a comment
		if (i0<0 || i1<=i0)
			break
		endif
		str[i0,i1+2] = ""									// snip out comment
	while(1)
	return str
End
//
ThreadSafe Static Function startOfxmltag(xmltag,buf,occurance)	// returns the index into buf pointing to the start of xmltag
	String xmltag, buf
	Variable occurance									// use 0 for first occurance, 1 for second, ...

	Variable i0,i1, i, start
	for (i=0,i0=0;i<=occurance;i+=1)
		start = i0
		i0 = strsearch(buf,"<"+xmltag+" ",start)	// find start of a tag with attributes
		i1 = strsearch(buf,"<"+xmltag+">",start)	// find start of a tag without attributes
		i0 = i0<0 ? Inf : i0
		i1 = i1<0 ? Inf : i1
		i0 = min(i0,i1)
		i0 += (i<occurance) ? strlen(xmltag)+2 : 0	// for more, move starting point forward
	endfor
	i0 = numtype(i0) || i0<0 ? -1 : i0
	return i0
End

//  ================================= End of Generic XML =================================  //
//  ======================================================================================  //


//  ======================================================================================  //
//  ============================ Start WaveClass in Wave Note ============================  //

// return a list of waves in current folder having a "waveClass" that is a member of the list waveClassList
// The waveClassList, is a semicolon separated list, and the members can have wildcards. e.g. "speImage*"
// The class of a wave is given by a key=value pair in the wavenote:      "key1=val1;waveClass=class1,class2,class3;key5=val5;"
// This is similar to WaveList(), but with a finer selection
//
// returns true if any one of the classes of ww matches one of the classes in waveClassList
// note that the items in waveClassList can have wild cards
Function/T WaveListClass(waveClassList,search,options,[all,win,fldr])
	String waveClassList				// a list of acceptable wave classes (semicolon separated)
	String search						// same as first argument in WaveList()
	String options						// same as last argument in WaveList()
	Variable all						// when all is TRUE, then all of the classes in waveClassList must be present, not just one
	String win							// when present, only provide waves also displayed in win
	String fldr							// name of data folder to check, default is current folder
	all = ParamIsDefault(all) ? 0 : !(!all)
	all = numtype(all) ? 0 : all
	win = SelectString(ParamIsDefault(win),win,"")
	fldr = SelectString(ParamIsDefault(fldr),fldr,"")
	if (strlen(fldr))
		fldr += SelectString(StringMatch(fldr,"*:"),":","")	// ensure fldr ends with ":"
		fldr = SelectString(strsearch(fldr,"root:",0) && strsearch(fldr,":",0),"",":")+fldr	// add leading ":" unless "root:..."
		if (!DataFolderExists(fldr))	// if requested folder does not exist, just return
			return ""
		endif
	endif

	String fldrSav=GetDataFolder(1)
	SetDataFolder fldr
	String in = WaveList(search,";",options), name, out=""
	SetDataFolder fldrSav

	Variable m, displayed=1
	for (m=0, name=StringFromList(0,in); strlen(name); m+=1,name=StringFromList(m,in))
		name = fldr+name
		if (strlen(win))
			CheckDisplayed/W=$win $name
			displayed = !(!V_flag)
		endif
		if (displayed && WaveInClass($name,waveClassList,all=all))
			out += name+";"
		endif
	endfor
	return out
End


// removes waves from inList that are also in includeClassList
Function/T IncludeOnlyWavesInClass(inList,includeClassList)
	String inList						// a list of input waves (semicolon separated)
	String includeClassList				// a list of classes to exclude (semicolon separated)

	if (strlen(inList)<1)				// nothing
		return ""
	endif
	String out=""
	String name
	Variable m, use
	for (m=0, name=StringFromList(0,inList); strlen(name); m+=1,name=StringFromList(m,inList))
		Wave ww=$name
		if (WaveExists(ww))
			if (WaveInClass(ww,includeClassList))	// keep this wave
				out += name+";"
			endif
		endif
	endfor
	return out
End


// returns true if any one of the classes of ww matches one of the classes in waveClassList
// note that the items in waveClassList can have wild cards
ThreadSafe Function WaveInClass(ww,waveClassList,[all])
	Wave ww						// Wave to check
	String waveClassList			// a list of acceptable wave classes (semicolon separated)
	Variable all					// when all is TRUE, then all of the classes in waveClassList must be present, not just one
	if (!WaveExists(ww))
		return 0
	elseif (strlen(waveClassList)==1 && char2num(waveClassList)==42)		// just a "*" matches everything
		return 1
	elseif (strlen(waveClassList)<1)
		return 1
	endif

	waveClassList = ReplaceString(",",waveClassList,";")
	all = ParamIsDefault(all) ? 0 : !(!all)
	all = numtype(all) ? 0 : all
	String class = StringByKey("waveClass",note(ww),"=")	// class list stored in wave note (comma separated)
	String matchClass, wavClass
	Variable m, i,Nc, Nclasses=ItemsInList(waveClassList)
	Variable Nmatch=(all ? Nclasses : 1)						// number of classes I have to match
	for (m=0,Nc=0; m<Nclasses; m+=1)						// check each item in waveClassList
		matchClass = StringFromList(m,waveClassList)
		for (i=0;i<ItemsInList(class,",");i+=1)
			wavClass = StringFromLIst(i,class,",")				// class item from the wave
			Nc += stringmatch(wavClass, matchClass)			// note that matchClass can have wild cards
			if (Nc>=Nmatch)
				return 1
			endif
		endfor
	endfor
	return 0
End


// Adds a class to a waveClass
ThreadSafe Function/T AddClassToWaveNote(wnote,addClass)
	String wnote									// existing wavenote with key=value parirs
	String addClass								// class is a comma separated list of wave classes (or just one)

	String waveClasses=StringByKey("waveClass",wnote,"=")	// get current list of wave classes
	String oneClass								// one of the classes from addClass
	Variable i
	for (i=0;i<ItemsInList(addClass,",");i+=1)
		oneClass = StringFromList(i,addClass)
		if (WhichListItem(oneClass,waveClasses,",")<0)					// addClass not in waveClasses, add it
			waveClasses = AddListItem(oneClass,waveClasses,",",Inf)
		endif
	endfor
	wnote = ReplaceStringByKey("waveClass",wnote,waveClasses,"=")	// fix up wave note
	return wnote
End


// removes waves from inList that are also in excludeClassList
ThreadSafe Function/T ExcludeWavesInClass(inList,excludeClassList)
	String inList						// a list of input waves (semicolon separated)
	String excludeClassList			// a list of classes to exclude (semicolon separated)

	if (strlen(inList)<1)				// nothing
		return ""
	endif
	String out=""
	String name
	Variable m, use
	for (m=0, name=StringFromList(0,inList); strlen(name); m+=1,name=StringFromList(m,inList))
		Wave ww=$name
		if (WaveExists(ww))
			if (!WaveInClass(ww,excludeClassList))	// keep this wave
				out += name+";"
			endif
		endif
	endfor
	return out
End


// returns list of folders containing waves with waveClassList
Function/T FoldersWithWaveClass(fldrPath,waveClassList,search,options,[all,win,fullPath])
	String fldrPath					// folder in which to look, defaults to current folder
	String waveClassList			// a list of acceptable wave classes (semicolon separated)
	String search						// same as first argument in WaveList()
	String options						// same as last argument in WaveList()
	Variable all						// when all is TRUE, then all of the classes in waveClassList must be present, not just one
	String win							// when present, only provide waves also displayed in win
	Variable fullPath					// flag, when true, returned list has full path
	all = ParamIsDefault(all) ? 0 : !(!all)
	all = numtype(all) ? 0 : all
	win = SelectString(ParamIsDefault(win),win,"")
	fullPath = ParamIsDefault(fullPath) || numtype(fullPath) ? 0 : !(!fullPath)
	fldrPath = SelectString(strlen(fldrPath),":",fldrPath)
	fldrPath = FixUpFolderName(fldrPath)	// add necessary ":"

	DFREF DFR = $fldrPath
	Variable Nlist = CountObjectsDFR(DFR,4)
	String name, flist, list=""
	Variable i
	for (i=0;i<Nlist;i+=1)		// check each folder in fldrPath
		name = GetIndexedObjNameDFR(DFR,4,i)
		if (ItemsInList(WaveListClass(waveClassList,search,options,all=all,win=win,fldr=fldrPath+name)))
			list += SelectString(fullPath,"",fldrPath) + name + ";"
		endif
	endfor
	return list
End


Function/T TraceNamesInClass(waveClassList,win,[optionsFlag])
	// like TraceNameList(), but limit result to a list of wave classes
	// returns a list of acceptable trace names, use TraceNameToWaveRef() to get wave ref.
	String waveClassList			// list of classes, semi-colon separated
	String win
	Variable optionsFlag
	optionsFlag = ParamIsDefault(optionsFlag) || numtype(optionsFlag) ? 1 : optionsFlag	// only normal graph traces (exclude contours & hidden)
	String listAll=TraceNameList(win,";",optionsFlag), list="", trName

	Variable i, N=ItemsInlist(listAll)
	for (i=0;i<N;i+=1)			// for each trace, check if it is in waveClassList
		trName = StringFromList(i,listAll)
		Wave ww = TraceNameToWaveRef(win, trName)
		list += SelectString(WaveInClass(ww,waveClassList), "", trName+";")
	endfor
	return list
End

//  ============================= End WaveClass in Wave Note =============================  //
//  ======================================================================================  //


//  ======================================================================================  //
//  ====================== Start of some general utility functions =======================  //


Proc RecompileAllProcedures()						// FORCE ALL procedures to recompile,  This must be a Proc or Macro (NOT Function)
	SetIgorOption poundDefine=DOESNTMATTER		// mark all procedures as needing compile 
	SetIgorOption poundUnDefine=DOESNTMATTER	// don't leave this defined.
	Execute/P/Q/Z "COMPILEPROCEDURES "				// re-compile (all)
	// print "ran RecompileAllProcedures"
End


Function/T FixUpFolderName(fldr)		// return foldr name with the needed ":", so fldr+"wavename" is valid
	String fldr
	if (strlen(fldr)<1)
		return ""
	endif

	if (strsearch(fldr,"root:",0,2) != 0)				// if it does not start with "root:" then it must start with ":"
		fldr = SelectString(strsearch(fldr,":",0), "", ":") + fldr
	endif
	Variable i = strlen(fldr)-1
	if (i>0 && char2num(fldr[i])!=char2num(":"))	// it must end with a ":"
		fldr += ":"
	endif
	return fldr
End


Function/T WavesWithMatchingKeyVals(inList,keyVals)
	String inList						// a list of input waves (semicolon separated)
	String keyVals						// key value pairs that must match for acceptance (optional)

	if (strlen(inList)<1)				// nothing
		return ""
	elseif (strlen(keyVals)<1)		// nothing to do
		return inList
	endif

	String out=""
	String name, item, key,val
	Variable m, i
	for (m=0, name=StringFromList(0,inList); strlen(name); m+=1,name=StringFromList(m,inList))
		Wave ww=$name
		if (WaveExists(ww))
			for (i=0;i<ItemsInlist(keyVals);i+=1)
				item = StringFromList(i,keyVals)
				key = StringFromList(0,item,"=")
				val = StringFromList(1,item,"=")
				if (StringMatch(StringByKey(key,note(ww),"="), val))
					out += name+";"
				endif
			endfor
		endif
	endfor
	return out
End


Function/T OnlyWavesThatAreDisplayed(inList,[not])
	String inList						// a list of input waves (semicolon separated)
	Variable not						// if TRUE, then only return wave from inList that are NOT displayed
	not = ParamIsDefault(not) ? 0 : !(!not)

	if (strlen(inList)<1)				// nothing
		return ""
	endif
	String out=""
	String name, item
	Variable m, i, use
	for (m=0, name=StringFromList(0,inList); strlen(name); m+=1,name=StringFromList(m,inList))
		Wave ww=$name
		if (WaveExists(ww))
			use = strlen(FindGraphsWithWave(ww)) > 0
			use = not ? !use : use
			out += SelectString(use,"",name+";")
		endif
	endfor
	return out
End


ThreadSafe Function keyInList(key,keyWordList,keySepStr,listSepStr)	// returns true if key=value pair is in the keyWordList
	String key						// string with key
	String keyWordList			// list of keyword=value pairs
	String keySepStr				// separates key and value, defaults to colon
	String listSepStr				// separates key value pairs, defaults to semicolon
	keySepStr = SelectString(strlen(keySepStr),":",keySepStr)	// default to colon
	listSepStr = SelectString(strlen(listSepStr),";",listSepStr)	// default to semicolon

	String find=key+keySepStr								// find this
	if (strsearch(keyWordList,find,0)==0)				// check if it is at the start
		return 1												// found key=value is first pair
	endif
	if ( strsearch(keyWordList,listSepStr+find,0)>0)		// check if key is after first key=value pair
		return 1												// found key=value is a later pair
	endif
	return 0													// no key=value found
End


//	Merges two key=value lists, if priority=0, then list0 has priority, if priority=1 then list1
ThreadSafe Function/S MergeKeywordLists(list0,list1,priority,keySepStr,listSepStr,[keys])
	String list0,list1
	Variable priority				// 0 or 1
	String keySepStr				// separates key and value, defaults to colon
	String listSepStr				// separates key value pairs, defaults to semicolon
	String keys						// an optional list of keys to transfer ("" or "*" means use all)
										// when keys is used, list0 is added to from list1
	keySepStr = SelectString(strlen(keySepStr),":",keySepStr)	// default to colon
	listSepStr = SelectString(strlen(listSepStr),";",listSepStr)	// default to semicolon
	keys = SelectString(ParamIsDefault(keys),keys,"")					// defaults to all
	Variable check_keys = (strlen(keys)>0) && (strsearch(keys,"*",0)!=0)
	String item, key,value
	Variable i,N=ItemsInList(list1)
	for (i=0;i<N;i+=1)				// for each keyword=value pair in list1
		item = StringFromList(i,list1,listSepStr)
		key = StringFromList(0,item,keySepStr)
		value = StringFromList(1,item,keySepStr)
		if (check_keys)
			if (WhichListItem(key,keys)<0)	// checking keys, but key not in list, so skip
				continue
			endif
		endif
		if (keyInList(key,list0,keySepStr,listSepStr) && priority==0)
			continue				// skip because key already in list0, and list0 has priority
		endif
		list0 = ReplaceStringByKey(key,list0,value,keySepStr,listSepStr)
	endfor
	return list0
End


//	returns a list containing only the keys from keyVals, keySepStr defaults to ":", listSepStr to ";"
ThreadSafe Function/S keysInList(keyVals,keySepStr,listSepStr)
	String keyVals					// a key=val; list
	String keySepStr
	String listSepStr
	listSepStr = SelectString(strlen(listSepStr),";",listSepStr)
	keySepStr = SelectString(strlen(keySepStr),":",keySepStr)

	Variable i0,i, N=	ItemsInList(keyVals,listSepStr)
	String key, out=""
	for (i=0;i<N;i+=1)
		key = StringFromList(i,keyVals,listSepStr)
		i0 = strsearch(key,keySepStr,0)
		if (i0==-1)
			out += key+listSepStr
		elseif(i0>0)
			out += key[0,i0-1]+listSepStr
		endif
	endfor
	return out
End


Function/T joinLists(a,b,[sep])
	// join two lists using separator sep.  This takes care of terminated or un-terminated lists
	String a,b			// two list with sep as separator
	String sep			// defaults to ";"
	sep = SelectString(ParamIsDefault(sep), sep, ";")	// not given, use ";"
	sep = SelectString(strlen(sep)<1, sep, ";")			// empty string, use ";"
	if (strlen(a)<1)			// a is empty, just b
		return b
	elseif (strlen(b)<1)	// b is empty, just a
		return a
	else							// join a & b
		return RemoveEnding(a,sep)+ sep + b
	endif
End


Function/T AxisLabelFromGraph(gName,w,axis)	// returns specified axis label for the top graph containing the wave
	String gName										// name of graph, use "" for the top graph
	Wave w											// if w does not exist, use the first wave (image or trace) in the graph gName
	String axis										// use "HORIZONTAL" or "VERTICAL" for the x and y axes

	if (strlen(WinList("*", "", "WIN:1"))<1)
		return ""
	endif
	if (!WaveExists(w))								// find top wave
		Wave w = ImageNameToWaveRef(gName,StringFromList(0,ImageNameList(gName,";")))
		if (!WaveExists(w))
			Wave w = TraceNameToWaveRef(gName,StringFromList(0,TraceNameList(gName,";",1)))
		endif
		if (!WaveExists(w))
			return ""
		endif
	endif
	gName = SelectString(strlen(gName),StringFromList(0,FindGraphsWithWave(w)),gName)
	String infoStr=""
	if (WaveExists(w))
		infoStr=ImageInfo(gName,NameOfWave(w),0)
		if (strlen(infoStr)<1)
			infoStr = TraceInfo(gName,NameOfWave(w),0)
		endif
	endif
	if (cmpstr(axis,"VERTICAL",1)==0)			// return label for vertical axis used by wave w
		axis = AxisLabelFromGraph(gName,w,StringByKey("YAXIS",infoStr))
		return axis
	elseif (cmpstr(axis,"HORIZONTAL",1)==0)	// return label for horzontal axis used by wave w
		axis = AxisLabelFromGraph(gName,w,StringByKey("XAXIS",infoStr))
		return axis
	endif

	String recreation=WinRecreation(gName,0)
	String str = "\tLabel "+axis
	Variable i0,i1
	i0 = strsearch(recreation,str,0,2)
	if (i0<0)
		return ""
	endif
	i0 += strlen(str)+1
	i1 = strsearch(recreation[i0,Inf],"\r",0,2)-1 + i0

	str=recreation[i0+1,i1-1]						// strip off leading and trailing double quotes
	str = ReplaceString("\\\\",str,"\\")
	return str
End



Function/S FindGraphsWithWave(w)	// find the graph window which contains the specified wave
	Wave w
	if (!WaveExists(w))
		return ""
	endif
	String name0=GetWavesDataFolder(w,2), out=""
	String win,wlist = WinList("*",";","WIN:1"), clist, cwin
	Variable i,m,Nm=ItemsInList(wlist)
	for (m=0;m<Nm;m+=1)
		win = StringFromList(m,wlist)
		CheckDisplayed/W=$win w
		if (V_flag>0)
			out += win+";"
		else
			clist = ChildWindowList(win)
			for (i=0;i<ItemsInLIst(clist);i+=1)
				cwin = StringFromList(i,clist)
				CheckDisplayed/W=$(win+"#"+cwin) w
				if (V_flag>0)
					out += win+"#"+cwin+";"
					break
				endif
			endfor
		endif
	endfor
	return out
End


Function/T FindGizmosWithWave(w)	// find list of Gizmos that contain the specified wave
	Wave w
	if (!WaveExists(w) || exists("NewGizmo")!=4)
		return ""
	endif

#if (IgorVersion()<7)
	Execute "GetGizmo/Z gizmoNameList"
	String gList=StrVarOrDefault("S_GizmoNames","")
	KillStrings/Z S_GizmoNames
#else
	GetGizmo/Z gizmoNameList
	String gList = SelectString(strlen(S_GizmoNames)>0, "", S_GizmoNames)
#endif
	String gName, objetAll, list=""
	Variable i, m, N=ItemsInList(gList)
	for (i=0;i<N;i+=1)
		gName=StringFromList(i,gList)				// check each gizmo that is displayed
#if (IgorVersion()<7)
		Execute "GetGizmo/Z/N="+gName+" objectList"
		KillStrings/Z S_gizmoObjectList
#else
		GetGizmo/Z/N=$gName objectList
#endif
		Wave/T TW_gizmoObjectList=TW_gizmoObjectList
		objetAll = ""
		for (m=0;m<numpnts(TW_gizmoObjectList);m+=1)
			objetAll += TW_gizmoObjectList[m]+";"
		endfor
		objetAll = ReplaceString("=",objetAll,";")
		objetAll = ReplaceString(",",objetAll,";")
		objetAll = ReplaceString("}",objetAll,";")
		objetAll = ReplaceString("{",objetAll,";")
		objetAll = ReplaceString("\r",objetAll,";")
		objetAll = ReplaceString("\n",objetAll,";")
		if (strsearch(objetAll,";"+GetWavesDataFolder(w,2)+";",0,2)>=0)
			list += gName+";"
		endif
	endfor
	KillWaves/Z TW_gizmoObjectList
	return list
End



Function/T FindTablesWithWave(w)	// find the table windows which contains the specified wave
	Wave w
	if (!WaveExists(w))
		return ""
	endif
	String name0=GetWavesDataFolder(w,2), out=""
	String win,wlist = WinList("*",";","WIN:2"), clist, cwin
	Variable i,m,Nm=ItemsInList(wlist)
	for (m=0;m<Nm;m+=1)
		win = StringFromList(m,wlist)
		CheckDisplayed/W=$win w
		if (V_flag>0)
			out += win+";"
		else
			clist = ChildWindowList(win)
			for (i=0;i<ItemsInLIst(clist);i+=1)
				cwin = StringFromList(i,clist)
				CheckDisplayed/W=$(win+"#"+cwin) w
				if (V_flag>0)
					out += win+"#"+cwin+";"
					break
				endif
			endfor
		endif
	endfor
	return out
End



Function/WAVE DisplayTableOfWave(ww,[classes,promptStr,names,options,colWid,top,left,maxRows,maxCols])
	// put up a table of a 2D wave
	Wave ww						// the ZonesWave wave (4 columns)
	String classes				// can use commas or semicolons and *
	String promptStr			// string for use in prompts
	String names				// name wildcards as used in WaveList()
	String options				// WaveList() options (e.g. "DIMS:2")
	Variable colWid			// fixed column width (points)
	Variable top,left			// top left corner of table
	Variable maxRows			// maximum number of rows to show
	Variable maxCols			// maximum number of columns to show
	classes = SelectString(ParamIsDefault(classes),classes,"*")
	promptStr = SelectString(ParamIsDefault(promptStr),promptStr,"Select a Wave for Table")
	names = SelectString(ParamIsDefault(names),names,"*")
	options = SelectString(ParamIsDefault(options),options,"")
	colWid = ParamIsDefault(colWid) || colWid<=1 || numtype(colWid) ? 80 : colWid
	top = ParamIsDefault(top) || numtype(top) ? 44 : limit(top,44,500)
	left = ParamIsDefault(left) || numtype(left) ? 5 : limit(left,0,784)
	maxRows = ParamIsDefault(maxRows) || numtype(maxRows) ? 90 : limit(maxRows,3,200)
	maxCols = ParamIsDefault(maxCols) || numtype(maxCols) ? 15 : limit(maxCols,3,30)
	if (!WaveExists(ww))
		String list=WaveListClass(classes,names,options)
		if(ItemsInList(list)==1)
			Wave ww = $StringFromList(0,list)
		elseif (ItemsInList(list)>1)
			String name
			Prompt name,promptStr+" Wave",popup,list
			DoPrompt promptStr,name
			if (!V_flag)
				Wave ww= $name
			endif
		endif
	endif
	if (!WaveExists(ww))
		return $""
	endif
	String win=StringFromList(0,FindTablesWithWave(ww))	// find an existing table windows containing ww
	if (strlen(win))
		DoWindow/F $win								// Table already exists, just bring it to front
		return ww
	endif

	String fontName=GetDefaultFont("")
	Variable fontSize = 12

	Variable i, Nr=DimSize(ww,0), Nc=DimSize(ww,1), hasColLabels, hasRowLabels
	for (i=0,hasColLabels=0; i<Nc; i+=1)
		hasColLabels = hasColLabels || strlen(GetDimLabel(ww,1,i))
	endfor
	for (i=0,hasRowLabels=0; i<Nr; i+=1)
		hasRowLabels = max(hasRowLabels, FontSizeStringWidth(fontName,fontSize,0,GetDimLabel(ww,0,i)))
	endfor
	Nr = min(maxRows,Nr)							// limit display to maxRows rows
	Nc = min(maxCols,Nc)							// limit display to maxCols columns

	String screen1=StringByKey("SCREEN1",IgorInfo(0))
	i = strsearch(screen1,"RECT=",0)
	String rect = StringByKey("RECT",screen1[i,Inf],"=")
	Variable scrWidth=str2num(StringFromList(2,rect,",")), scrHeight=str2num(StringFromList(3,rect,","))
	scrWidth = numtype(scrWidth) || scrWidth<800 ? 1000 : scrWidth
	scrHeight = numtype(scrHeight) || scrHeight<600 ? 600 : scrHeight

	Variable width = 53 + colWid*Nc, lwidth=0
	Variable height = 86 + (FontSizeHeight(fontName,fontSize,0))*Nr
	if (hasColLabels || hasRowLabels)
		lwidth = max(hasRowLabels+3, 20)
		width += lwidth
		height +=  Nr*4
	endif
	width = min(scrWidth-2*left, width)
	height =  min(scrHeight-top-5, height)

	if (lwidth)											// Make the table /W=(left,top,right,bottom)
		Edit/W=(left,top,left+width,top+height)/K=1 ww.ld
		ModifyTable width(ww.l)=lwidth
	else
		Edit/W=(left,top,left+width,top+height)/K=1 ww
	endif
	ModifyTable font=fontName, size=fontSize, format(Point)=1,width(Point)=36, width(ww.d)=colWid
	return ww
End



// make a function getFiletype that goes to a file and determines it's filetype, this applies to old $tag type files
Function/T getListOfTypesInFile(fname,path)
	String fname									// full path name to file with tagged geometry values
	String path									// name of Igor path

	Variable refNum
	Open/M="file containing tagged values"/P=$path/R/Z=2 refNum as fname
	if (strlen(S_fileName)<1 || !refNum)
		return ""
	endif
	String line
	FReadLine refNum, line
	Close refNum
	if (!stringmatch(line[0],"$"))				// if it does not start with a '$' then forget it.
		return ""
	endif

	Variable i
	i = strlen(line)
	i -= char2num(line[i-1])<32 ? 1 : 0
	i -= char2num(line[i-2])<32 ? 1 : 0
	line = line[0,i-1]							// trim off any c/r or new lines
	i = strsearch(line,"//",0)					// remove comment
	if (i>0)
		line = line[0,i-1]
	endif
	line = ReplaceString("\t",line," ")			// change all tabs to spaces
	line += " "										// ensure a space terminator

	if (strsearch(line,"$filetype ",0)!=0)		// does not starts with $filetype, pass back the tag
		i = strsearch(line," ",0)
		return line[1,i-1]
	endif
	line = line[9,Inf]								// strip off the $filetype tag

	// now get the value
	for (i=0;i<strlen(line) && char2num(line[i])<=32;i+=1)
	endfor
	line = line[i,Inf]								// trim off leading spaces

	for (i=strlen(line)-1;i>=0 && char2num(line[i])<=32;i-=1)
	endfor
	line = line[0,i]

	line = ReplaceString(",",line,";")			// change all commas, and spaces to semi-colons
	line = ReplaceString(" ",line,";")
	return line
End


Function DrawMarker(x0,y0,dx,dy,style,[color,thick,dash,win,layer,grpName])
	Variable x0,y0,dx,dy
	String style
	String color						// one of "red", "blue", "green", "yellow", "magenta", "cyan", or a triplet like "1,1,0" or "65535,0,0"
	Variable thick						// line thickness, defaults to 0.50 (thin)
	Variable dash
	String win							// optional name of window
	String layer						// Drawing layer to use.  Default is "UserFront"
	String grpName						// name of group of draw commands
	if (numtype(x0+y0+dx+dy) || dx<=0 || dy<=0)
		return 1
	endif
	if (ParamIsDefault(color))
		color = SelectString(stringmatch(style,"BoxWithTicks"),"black","30583,30583,30583")	// special default color for BoxWithTicks
	endif
//	color = SelectString(ParamIsDefault(color),color,"black")	// default color to black
//	color = SelectString(ParamIsDefault(color) && stringmatch(style,"BoxWithTicks"),color,"30583,30583,30583")	// special default color for BoxWithTicks
	thick = ParamIsDefault(thick) ? 0.5 : thick
	dash = ParamIsDefault(dash) ? 0 : dash
	if (ParamIsDefault(win))
		win = ""
	endif
	if (ParamIsDefault(layer))
		layer = "UserFront"
	endif
	String layerList = "ProgBack;UserBack;ProgAxes;UserAxes;ProgFront;UserFront"
	layer = SelectString(strlen(layer),"UserFront",layer)
	if (WhichListItem(layer,layerList)<0)
		printf "ERROR -- layer = '%s' is invlaid, must be one of '%s'\r",layer,layerList
		return 1
	endif

	String rgb = StringByKey(color,"red:1,0,0;blue:0,0,1;green:0,1,0;yellow:1,1,0;magenta:1,0,1;cyan:0,1,1;black:0,0,0;white:1,1,1")	// name -> numbers
	rgb = SelectString(strlen(rgb),color,rgb)
	Variable r=str2num(StringFromList(0,rgb,",")), g=str2num(StringFromList(1,rgb,",")), b=str2num(StringFromList(2,rgb,","))
	r = !(r>=0) ? 0 : r											// default invalid to black
	g = !(g>=0) ? 0 : g
	b = !(b>=0) ? 0 : b
	if (r+g+b<=3)												// if numbers are all small change from [0,1] -> [0,65535]
		r *= 65535
		g *= 65535
		b *= 65535
	endif

	style = SelectString(strlen(style),"cross",style)			// defaults to Cross
	String list = ImageInfo(win,"",0)
	if (strlen(list)<1)											// perhaps no image, only a graph
		list = TraceInfo(win,StringFromList(0,TraceNameList(win,";",1+4)),0)
	endif
	String xaxis=StringByKey("XAXIS",list), yaxis=StringByKey("YAXIS",list)
	String aList = AxisList(win)
	aList = RemoveFromList(yaxis,aList)
	if (strlen(xaxis)<1)										// I am getting desperate, last thing to try
		Variable i
		for (i=0;i<ItemsInList(aList);i+=1)
			xaxis = StringFromList(i,aList)
			if (strsearch(xaxis,"bottom",0,2)>=0)
				break
			elseif (strsearch(xaxis,"top",0,2)>=0)
				break
			endif
		endfor
	endif
	if (strlen(yaxis)<1)										// I am getting desperate, last thing to try
		aList = RemoveFromList(xaxis,aList)
		for (i=0;i<ItemsInList(aList);i+=1)
			yaxis = StringFromList(i,aList)
			if (strsearch(yaxis,"left",0,2)>=0)
				break
			elseif (strsearch(yaxis,"right",0,2)>=0)
				break
			endif
		endfor
	endif

	dy = abs(dy/2)		// change FW to HW
	dx = abs(dx/2)

	if (strlen(grpName))
		grpName = CleanupName(grpName,0)
		grpName = ReplaceString("__",grpName,"_")
		if (char2num(grpName)==char2num("_"))
			grpName = "M"+grpName
		endif
	else
		init_UtiltyJZT()
		NVAR markerIndex = root:Packages:UtilityJZT:markerIndex
		grpName = "M"+num2istr(markerIndex)
		markerIndex += 1
	endif

	SetDrawLayer/W=$win $layer
	SetDrawEnv/W=$win gstart, gname=$grpName

	Variable err = 0
	if (stringmatch(style,"cross gap"))
		SetDrawEnv/W=$win  xcoord= $xaxis,ycoord= $yaxis,linefgc=(r,g,b), linethick= thick, dash=dash
		DrawLine/W=$win  x0,(y0-dy),x0,(y0-0.1*dy)
		SetDrawEnv/W=$win  xcoord= $xaxis,ycoord= $yaxis,linefgc=(r,g,b), linethick= thick, dash=dash
		DrawLine/W=$win  x0,(y0+0.1*dy),x0,(y0+dy)
		SetDrawEnv/W=$win xcoord= $xaxis,ycoord= $yaxis,linefgc=(r,g,b), linethick= thick, dash=dash
		DrawLine/W=$win (x0-dx),y0,(x0-0.1*dx),y0
		SetDrawEnv/W=$win xcoord= $xaxis,ycoord= $yaxis,linefgc=(r,g,b), linethick= thick, dash=dash
		DrawLine/W=$win (x0+0.1*dx),y0,(x0+dx),y0
	elseif (stringmatch(style,"cross"))
		SetDrawEnv/W=$win  xcoord= $xaxis,ycoord= $yaxis,linefgc=(r,g,b), linethick= thick, dash=dash
		DrawLine/W=$win  (x0),(y0-dy),x0,(y0+dy)
		SetDrawEnv/W=$win xcoord= $xaxis,ycoord= $yaxis,linefgc=(r,g,b), linethick= thick, dash=dash
		DrawLine/W=$win (x0-dx),y0,(x0+dx),y0
	elseif (stringmatch(style,"X"))
		SetDrawEnv/W=$win xcoord= $xaxis,ycoord= $yaxis,linefgc=(r,g,b), linethick= thick, dash=dash
		DrawLine/W=$win (x0-dx),(y0-dy),(x0+dx),(y0+dy)
		SetDrawEnv/W=$win xcoord= $xaxis,ycoord= $yaxis,linefgc=(r,g,b), linethick= thick, dash=dash
		DrawLine/W=$win (x0+dx),(y0-dy),(x0-dx),(y0+dy)
	elseif (stringmatch(style,"BoxWithTicks"))
		Variable hw							// half width of box in pixels, usually ~10
		SetDrawEnv/W=$win xcoord= $xaxis,ycoord= $yaxis,fillpat= 0, linethick= thick, dash=dash
		DrawRect x0-dx,y0-dy,x0+dx,y0+dy
		SetDrawEnv/W=$win xcoord= $xaxis,ycoord= $yaxis,linefgc=(r,g,b), linethick= thick, dash=dash
		DrawLine/W=$win x0,y0-dy,x0,y0-dy/2
		SetDrawEnv/W=$win xcoord= $xaxis,ycoord= $yaxis,linefgc=(r,g,b), linethick= thick, dash=dash
		DrawLine/W=$win x0,y0+dy/2,x0,y0+dy
		SetDrawEnv/W=$win xcoord= $xaxis,ycoord= $yaxis,linefgc=(r,g,b), linethick= thick, dash=dash
		DrawLine/W=$win x0-dx,y0,x0-dx/2,y0
		SetDrawEnv/W=$win xcoord= $xaxis,ycoord= $yaxis,linefgc=(r,g,b), linethick= thick, dash=dash
		DrawLine/W=$win x0+dx/2,y0,x0+dx,y0
	else
		err = 1
	endif
	SetDrawEnv/W=$win gstop
	SetDrawLayer/W=$win UserFront
	return err
End



// make saturated color RGB from point (dx,dy) on circle of radius rmax. RGB scaled to rgbMax
ThreadSafe Function xy2saturatedColors(dx,dy,rmax,rgbMax,rgb)
	Variable dx,dy												// x,y location on the pole figure
	Variable rmax												// max radius (default is 1)
	Variable rgbMax											// scale for RGB values, usually 1 or 65535
	Wave rgb													// set rgb to scale [0,rgbMax]
	if (numtype(dx+dy+rgbMax+rmax) || !(rgbMax>0) || !(rmax>0))
		rgb = NaN
		return NaN
	endif

	Variable rad = min(1,sqrt(dx*dx + dy*dy)/rmax)		// r/rmax, but does not exceed 1
	Variable hue = mod(atan2(dy,dx)*180/PI+360,360)	// angle in range [0,360)
	Variable huei = mod(floor(hue/60),6)					// {0, 1, 2, 3, 4, 5, 6}
	Variable pp,qq,tt, f
	f = hue/60 - floor(hue/60)
	pp = (1-rad)*rgbMax
	qq = (1-f*rad)*rgbMax
	tt = (1-(1-f)*rad)*rgbMax
	Variable r, g, b
	if (huei==0)
		r = rgbMax
		g = tt
		b = pp
	elseif(huei==1)
		r = qq
		g = rgbMax
		b = pp
	elseif(huei==2)
		r = pp
		g = rgbMax
		b = tt
	elseif(huei==3)
		r = pp
		g = qq
		b = rgbMax
	elseif(huei==4)
		r = tt
		g = pp
		b = rgbMax
	elseif(huei==5)
		r = rgbMax
		g = pp
		b = qq
	endif
	rgb = {r,g,b}
	rgb = limit(rgb,0,rgbMax)
	return hue						// return hue angle (degree)
End
//Function test_xy2saturatedColors()
//	Variable angle, dx, dy, rgbMax=65535, rmax=1
//	Make/N=3/D/FREE rgbi
//	Make/N=(361,3)/O rgbAll
//	SetScale/P x 0,1,"", rgbAll
//	for (angle=0;angle<361;angle+= 1)
//		dx=cos(angle*PI/180)
//		dy=sin(angle*PI/180)
//		xy2saturatedColors(dx,dy,rmax,rgbMax,rgbi)
//		rgbAll[angle][] = rgbi[q]
//	endfor
//	rgbAll = abs(rgbAll) < 1e-10 ? 0 : rgbAll
//End



ThreadSafe Function/T reverseList(in,[sep])	// reverse the order of items in a list
	String in										// original list
	String sep										// separator between items
	if (ParamIsDefault(sep))
		sep = ";"
	endif
	String out=""
	Variable i, N=ItemsInList(in,sep)

	for (i=0;i<N;i+=1)
		out = AddListItem(StringFromList(i,in,sep),out,sep,0)
	endfor
	return out
End



ThreadSafe Function monotonic(a,[printIt])
	// determines whether values of a particular wave are monotonic increasing (if any NaN, returns false)
	Wave a		// the wave
	Variable printIt
	printIt = ParamIsDefault(printIt) ? 0 : printIt
	printIt = numtype(printIt) ? 0 : !(!printIt)

	if (!WaveExists(a))
		if (printIt)
			print "ERROR -- monotonic(), wave not found"
		endif
		return NaN
	elseif (numpnts(a)<=0)
		if (printIt)
			print "ERROR -- monotonic(), wave is empty"
		endif
		return NaN
	elseif (WaveDims(a)>1)
		if (printIt)
			print "ERROR -- monotonic(), wave is not 1D"
		endif
		return NaN
	endif
	MatrixOP/FREE delta = a - rotateRows(a,1)
	delta[0] = 0
	WaveStats/M=1/Q delta
	return !(V_min<0 || V_numNans)
End
//	Variable n=numpnts(a)
//	Variable i=1
//	do
//		if (a[i-1]>a[i])
//			return 0
//		endif
//		i += 1
//	while (i<n)
//	return 1


ThreadSafe Function isdigit(c)				// returns 1 if c is a digit, 0-9 (otherwise returns 0)
	String c
	Variable i=char2num(c)
	return (48<=i && i<=57)
End


ThreadSafe Function isletter(c)				// returns 1 if c is an upper or lower case letter (otherwise returns 0)
	String c
	Variable i=char2num(c)
	return (65<=i && i<=90) || (97<=i && i<=122)
End


ThreadSafe Function angleVec2Vec(a,b)		// return the angle between two vectors (degree)
	Wave a,b
	Variable dot = MatrixDot(a,b) / (norm(a)*norm(b))
	dot = limit(dot,-1,1)						// ensure that the acos will exist
	return acos(dot)*180/PI
End


ThreadSafe Function/WAVE perp2Vector(a)
	// returns a new vector that is perpendicular to a, the direction around a is unspecified.
	Wave a
	Variable i,j, imin=abs(a[0])<abs(a[1]) ? 0 : 1
	imin = abs(a[2])<abs(a[imin]) ? 2 : imin
	i = mod(imin+2,3)
	j = mod(imin+1,3)
	Make/N=(3,3)/D/FREE mat=0
	mat[i][j] = 1						//	see:  https://en.wikipedia.org/wiki/Cross_product
	mat[j][i] = -1
	MatrixOP/FREE cr = Normalize(mat x a)
	return cr
End


ThreadSafe Function rotationAngleOfMat(rot)	// returns the total rotation angle of a matrix 'rot'
	Wave rot											// the rotation matrix
	Variable trace = MatrixTrace(rot)		// trace = 1 + 2*cos(theta)
	Variable cosine = (trace-1)/2			// cosine of the rotation angle
	cosine = (cosine>1) ? (2-cosine) : cosine
	return acos(cosine)*180/PI				// rotation angle in degrees
End


ThreadSafe Function isRotationMat(mat,[tol])	// true if mat is a rotation matrix
	Wave mat
	Variable tol							// positive threshold for zero
	if (!WaveExists(mat))
		return 0								// mat does not exist
	elseif (DimSize(mat,0)<2 || (DimSize(mat,0) != DimSize(mat,1)))
		return 0								// mat not a square matrix, at least 2x2
	endif 
	tol = ParamIsDefault(tol) || numtype(tol) || tol<=0 ? NaN : tol
	if (numtype(tol))
		tol = WaveType(mat) & 0x04 ? 1e-13 : 1e-6
	endif
	MatrixOP/FREE err = sum(abs((mat x (mat^t)) - Identity(3)))
	return (err[0]<tol)
End


// compute angle and axis of a rotation matrix
// Aug 2, 2007, this was giving the wrong sign for the rotation, so I reversed the "curl" in defn of axis.  JZT
//		changed "axis[0] = rot[1][2] - rot[2][1]"   -->   "axis[0] = rot[2][1] - rot[1][2]"
ThreadSafe Function axisOfMatrix(mat,axis,[squareUp])
	// returns total rotation angle (deg), and sets axis to the axis of the total rotation
	Wave mat									// should be a rotation matrix
	Wave axis								// axis of the rotation (angle is returned)
	Variable squareUp						// optionally square up mat (default is NOT square up)
	squareUp = ParamIsDefault(squareUp) ? NaN : squareUp
	squareUp = numtype(squareUp) ? 0 : !(!squareUp)

	Make/N=(3,3)/FREE/D rot=mat
	if (squareUp)
		if (SquareUpMatrix(rot))
			axis = NaN								// default for error
			return NaN
		endif
	else
		MatrixOp/FREE sumd = sum(Abs((mat x mat^t) - Identity(3)))
		if (sumd[0]<0 || sumd[0]>1e-4)		// not close enough to a rotation mat, an error
			axis = NaN								// default for error
			return NaN
		endif
	endif

	Variable cosine = (MatrixTrace(rot)-1)/2	// trace = 1 + 2*cos(theta)
	cosine = limit(cosine,-1,1)
	if (cosine<= -1)								// special for 180¡ rotation,
		axis[0] = sqrt((rot[0][0]+1)/2)
		axis[1] = sqrt((rot[1][1]+1)/2)
		axis[2] = sqrt((rot[2][2]+1)/2)		// always assume z positive
		axis[0] = (rot[0][2]+rot[2][0])<0 ? -axis[0] : axis[0]
		axis[1] = (rot[1][2]+rot[2][1])<0 ? -axis[1] : axis[1]
		if (numtype(sum(axis)))				// this is for very special cases such as diag = {1,-1,-1}
			WaveStats/M=1/Q axis
			axis = p==V_maxloc
		endif
	else												// rotaion < 180¡, usual formula works
		axis[0] = rot[2][1] - rot[1][2]
		axis[1] = rot[0][2] - rot[2][0]
		axis[2] = rot[1][0] - rot[0][1]
		axis /= 2
	endif
	normalize(axis)
	return acos(cosine)*180/PI				// rotation angle in degrees
End


// Oct 5, 2014, used new proper method for changing rot to an exact rotation matrix
ThreadSafe Function SquareUpMatrix(rot)
	// see http://en.wikipedia.org/wiki/Kabsch_algorithm
	Wave rot
	MatrixSVD/U=0/V=0/Z rot
	if (V_flag)
		return 1
	endif
	Wave M_V=M_U			// 3x3 column-orthonormal matrix
	Wave M_WT=M_VT			// transpose of NxN orthonormal matrix

	// A = M_V x W_S x M_WT		// from wikipedia
	MatrixOp/FREE deter = Det(M_WT^t x M_V^t)
	Make/N=(3,3)/FREE/D Idet=(p==q)
	Idet[2][2] = sign(deter[0])

	MatrixOp/FREE rr = (M_WT^t x Idet x M_V^t)^t
	rot = rr
	KillWaves/Z W_W, M_U, M_VT
	return 0
End


ThreadSafe Function smallestNonZeroValue(vec,[tol])
	// returns the abs( smallest non-zero element ), this routine ignores NaN's
	// {0, 0.1, 3} returns 0.1,  {0, -0.1, 3} returns 0.1
	//  This is useful if you want to display {0, 0.1, 3} as integers, then dividing gives {0, 1, 30}
	Wave vec								// a vector or matrix of any dimension
	Variable tol						// positive threshold for zero

	if (!WaveExists(vec))
		return NaN						// vec does not exist
	elseif (numpnts(vec)<1)
		return NaN
	endif
	tol = ParamIsDefault(tol) || numtype(tol) || tol<=0 ? NaN : tol
	if (numtype(tol))
		tol = WaveType(vec) & 0x04 ? 1e-13 : 1e-6
	endif
	MatrixOP/FREE temp = abs(vec)
	temp = temp < tol ? NaN : temp
	return WaveMin(temp)
End


ThreadSafe Function MedianOfWave(wwIN,f,[x1,x2,p1,p2])
	//	return median (or other percentile) of a wave, useful for picking min/max range for a color scale
	Wave wwIN
	Variable f					// fraction (e.g. percentile) in range [0,1], use f=0.5 for usual median
	Variable x1, x2			// range of interest (x-values) (cannot specify both x1 & p1)
	Variable p1, p2			// range of interest (point-values)
	if (!WaveExists(wwIN) || WaveDims(wwIN)!=1 || numtype(f) || f<0 || f>1)
		return NaN
	endif
	Variable setLo = (ParamIsDefault(x1) ? 0 : 2) + (ParamIsDefault(p1) ? 0 : 1)
	Variable setHi = (ParamIsDefault(x2) ? 0 : 2) + (ParamIsDefault(p2) ? 0 : 1)
	if (setLo>2 || setHi>2)
		return NaN								// cannot specify both x and point for a range
	endif

	Variable N=numpnts(wwIN), x0=DimOffset(wwIN,0), dx=DimDelta(wwIN,0)
	Variable pLo=0, pHi=N-1				// init pLo,pHi to full range
	pLo = setLo==1 ? p1 : pLo				// p1 given
	pHi = setHi==1 ? p2 : pHi				// p2 given
	pLo = setLo==2 ? (x1-x0)/dx : pLo	// x1 given, convert to p1
	pHi = setHi==2 ? (x2-x0)/dx : pHi	// x2 given, convert to p2
	if (numtype(pLo+pHi)==2)				// cannot deal with NaN's, probably from bad input
		return NaN
	endif
	pLo = limit(round(pLo),0,N-1)		// trim to allowed point range, and force to integer
	pHi = limit(round(pHi),0,N-1)
	Variable Nrange = (pHi-pLo+1)		// number of points in the sub-range
	if (Nrange < 1)							// nothing in range
		return NaN
	elseif (Nrange==1)
		return wwIN[0]							// trivial result
	endif

	Duplicate/R=[pLo,pHi]/FREE wwIN, temp
	Sort temp, temp							// Sort range of wwIN
	WaveStats/M=1/Q temp
	if (V_npnts<1)
		return NaN
	endif
	return temp[f*(V_npnts-1)]			// note that V_npnts*f need not be an integer
End
//
//Function test_MedianOfWave(bitFlag)
//	Variable bitFlag
//
//	Variable p1, p2
//	printf "\t0.5\t\t0\t\t\t1\t\t\t w\r"
//
//	if (bitFlag & 1)
//		Make/FREE tw={7}
//		printf "%4.2f,   %4.2f,   %4.2f,\t\t%s\r",MedianOfWave(tw,0.5),MedianOfWave(tw,0),MedianOfWave(tw,1),vec2str(tw)
//	endif
//	if (bitFlag & 2)
//		Make/FREE tw={4.1,2.1}
//		printf "%4.2f,   %4.2f,   %4.2f,\t\t%s\r",MedianOfWave(tw,0.5),MedianOfWave(tw,0),MedianOfWave(tw,1),vec2str(tw)
//	endif
//	if (bitFlag & 4)
//		Make/FREE tw={4.1,2.1,4}
//		printf "%4.2f,   %4.2f,   %4.2f,\t\t%s\r",MedianOfWave(tw,0.5),MedianOfWave(tw,0),MedianOfWave(tw,1),vec2str(tw)
//	endif
//
//	Make/FREE tw={1,2,3,4,5,0,6,7,8,9}
//	if (bitFlag & 8)
//		printf "%4.2f,   %4.2f,   %4.2f,\t\t%s\r",MedianOfWave(tw,0.5),MedianOfWave(tw,0),MedianOfWave(tw,1),vec2str(tw)
//	endif
//	if (bitFlag & 16)
//		p1=1; p2=10
//		Make/N=(min(p2,numpnts(tw)-1)-p1+1)/FREE tw12
//		tw12 = tw[p+p1]
//		printf "%4.2f,   %4.2f,   %4.2f,\t\t%s, p1=%d, p2=%d\r",MedianOfWave(tw,0.5,p1=p1,p2=p2),MedianOfWave(tw,0,p1=p1,p2=p2),MedianOfWave(tw,1,p1=p1,p2=p2),vec2str(tw12), p1,p2
//	endif
//	if (bitFlag & 32)
//		p1=2; p2=6
//		Make/N=(min(p2,numpnts(tw)-1)-p1+1)/FREE tw12
//		tw12 = tw[p+p1]
//		printf "%4.2f,   %4.2f,   %4.2f,\t\t%s, p1=%d, p2=%d\r",MedianOfWave(tw,0.5,p1=p1,p2=p2),MedianOfWave(tw,0,p1=p1,p2=p2),MedianOfWave(tw,1,p1=p1,p2=p2),vec2str(tw12), p1,p2
//	endif
//
//	if (bitFlag & 64)
//		p1=12; p2=6
//		printf "%4.2f,   %4.2f,   %4.2f,\t\t%s, p1=%d, p2=%d\r",MedianOfWave(tw,0.5,p1=p1,p2=p2),MedianOfWave(tw,0,p1=p1,p2=p2),MedianOfWave(tw,1,p1=p1,p2=p2),vec2str(tw), p1,p2
//	endif
//End



// This routine is much faster than going through an [sprintf str,"%g",val] conversion
ThreadSafe Function roundSignificant(val,N)	// round val to N significant figures
	Variable val			// input value to round
	Variable N			// number of significant figures

	if (val==0 || numtype(val))
		return val
	endif
	Variable is,tens
	is = sign(val) 
	val = abs(val)
	tens = 10^(N-floor(log(val))-1)
	return is*round(val*tens)/tens
End

ThreadSafe Function placesOfPrecision(a)	// number of significant figures in a number (at most 16)
	Variable a
	a = roundSignificant(abs(a),17)
	Variable i
	for (i=1;i<18;i+=1)
		if (abs(a-roundSignificant(a,i))/a<1e-15)
			break
		endif
	endfor
	return i
End


ThreadSafe Function/T ValErrStr(val,err,[sp])	// returns string  "val ± err"
	Variable val								// value
	Variable err								// err in value
	Variable sp								// optionally put spaces around the ±
	sp = ParamIsDefault(sp) ? 0 : !(!sp)
	sp = numtype(sp) ? 0 : sp
	err = numtype(err) ? 0 : abs(err)

	Variable n = ceil(log(abs(val/err)))+1// number of places of precision to show
	n = numtype(n) ? 6  : n					// default precision is 6
	n = limit(n,1,15)

	String vfmt, evfmt, str
	vfmt = "%."+num2istr(n)+"g"			// format for value
	String pm = SelectString(sp,"±"," ± ")
	evfmt = vfmt + pm + SelectString(n>=2,"%.1g","%.2g")

	if (err>0)
		sprintf str,evfmt,val,err				// have a valid err, show it
	else
		sprintf str,vfmt,val					// no valid err, just show value
	endif
	return str
End



ThreadSafe Function normalize(a)	// normalize a and return the initial magnitude
	Wave a
	Variable norm_a
	if (WaveDims(a)==1)											// for a 1-d wave, normalize the vector
		norm_a = norm(a)
	elseif(WaveDims(a)==2 && DimSize(a,0)==DimSize(a,1))	// for an (n x n) wave, divide by the determinant
		norm_a = MatrixDet(a)^(1/DimSize(a,0))
	endif
	if (norm_a==0 || numtype(norm_a))
		return 0
	endif

	if (WaveType(a)&1)											// for a complex wave
		FastOp/C a = (1/norm_a)*a								//	a /= norm_a
	else
		FastOp a = (1/norm_a)*a									//	a /= norm_a
	endif
	return norm_a
End
//Function normalize(a)	// normalize a and return the initial magnitude
//	Wave a
//	Variable norm_a = norm(a)
//	a /= norm_a
//	return norm_a
//End



// returns 1 if ww is only positive integers (or 0), tolerance to an int is tol
//	This is useful for determining if ww are counts (only positive ints)
ThreadSafe Function isPositiveInts(ww,[tol])
	Wave ww
	Variable tol							// tolerance for deciding if a number is an integer
	tol = ParamIsDefault(tol) ? 0.0001 : tol
	if (numtype(tol) || tol <0)
		return 0
	elseif (WaveType(ww,1) != 1)		// check if a numeric wave, NOT counts
		return 0
	elseif (WaveMin(ww)<0)				// found negatives, NOT counts
		return 0
	elseif (WaveType(ww) & 0x38)		// an integer type, IS counts
		return 1
	elseif (WaveType(ww) & 0x01)		// complex, NOT counts
		return 0
	endif

	// so ww is a float type, check if all integers
	MatrixOp/FREE tw = ReplaceNaNs(ww,0)	// ensure no NaN, (Inf is passed)
	MatrixOp/FREE test = sum(greater(abs(round(tw)-tw),tol))
	return test[0]<1					// if test[0] is 0, then all are ints
End


ThreadSafe Function OrderValues(x0,x1)
	// on return, x0 and x1 are optionally swapped so that x0<x1
	Variable &x0, &x1
	if (x0 > x1)
		Variable swap
		swap = x0
		x0 = x1
		x1 = swap
	endif
End


// return the cursor range from a graph as a cmplx(lo,hi) (cmplx(NaN,NaN) on failure)
Function/S GetCursorRangeFromGraph(gName)
	String gName				// name of graph, use "" for top graph

	String infoA=CsrInfo(A,gName), infoB=CsrInfo(B,gName)
	if (strlen(infoA)<1 || strlen(infoB)<1)
		return ""
	endif

	String trName=StringByKey("TNAME",infoA)
	Wave yData=TraceNameToWaveRef(gName, trName )
	if (!WaveExists(yData))
		return ""
	endif
	Wave xData=XWaveRefFromTrace(gName,trName)

	Variable pLo=pcsr(A,gName), pHi=pcsr(B,gName) 
	Variable xLo=hcsr(A,gName), xHi=hcsr(B,gName) 
	if (numtype(xlo+xhi+pLo+pHi))
		return ""
	endif
	OrderValues(pLo,pHi)
	OrderValues(xLo,xHi)

	String out=""
	out = ReplaceStringByKey("yData",out,trName,"=")
	if (WaveExists(xData))
		out = ReplaceStringByKey("xData",out,GetWavesDataFolder(xData,2),"=")
	endif
	out = ReplaceNumberByKey("pLo",out,pLo,"=")
	out = ReplaceNumberByKey("pHi",out,pHi,"=")
	out = ReplaceNumberByKey("xLo",out,xLo,"=")
	out = ReplaceNumberByKey("xHi",out,xHi,"=")
	return out
End
//Function/C GetCursorRangeFromGraph(gName,Xvals)
//	String gName				// name of graph, use "" for top graph
//	Variable Xvals				// True=Xvalues, False=Point values
//
//	String infoA=CsrInfo(A,gName), infoB=CsrInfo(B,gName)
//	if (strlen(infoA)<1 || strlen(infoB)<1)
//		return cmplx(NaN,NaN)
//	endif
//
//	Variable lo,hi				// the output values
//
//	if (Xvals)
//		lo = hcsr(A,gName)
//		hi = hcsr(B,gName)
//	else
//		lo = pcsr(A,gName)
//		hi = pcsr(B,gName)
//	endif
//	if (numtype(lo+hi))
//		return cmplx(NaN,NaN)
//	endif
//
//	if (lo>hi)					// in case order is reversed
//		Variable swap=lo
//		lo = hi
//		hi = swap
//	endif
//	return cmplx(lo,hi)
//End


// These next three functions convert Igor Peak fitting parameters to useful numbers
ThreadSafe Function GaussianFWHM(W_coef)			// FWHM of a Gaussian Peak
	// y = K0+K1*exp(-((x-K2)/K3)^2)
	Wave W_coef
	if (WaveType(W_coef,1)==1)							// W_coef exists, and it is numeric
		return 2*W_coef[3]*sqrt(ln(2))
	endif
	return NaN
End


ThreadSafe Function LorentzianFWHM(W_coef)			// FWHM of a Lorentzian Peak
	// y = K0+K1/((x-K2)^2+K3)
	Wave W_coef
	if (WaveType(W_coef,1)==1)							// W_coef exists, and it is numeric
		return 2*sqrt(W_coef[3])
	endif
	return NaN
End


ThreadSafe Function LorentzianIntegral(W_coef)	// peak integral from a Lorentzian fit
	// y = K0+K1/((x-K2)^2+K3)
	Wave W_coef
	if (WaveType(W_coef,1)==1)							// W_coef exists, and it is numeric
		return PI*W_coef[1]/sqrt(W_coef[3])
	endif
	return NaN
End

ThreadSafe Function GaussianIntegral(W_coef)		// peak integral from a Gaussian fit
	// y = K0+K1*exp(-((x-K2)/K3)^2)
	Wave W_coef
	if (WaveType(W_coef,1)==1)							// W_coef exists, and it is numeric
		return W_coef[1] * abs(W_coef[3]) * sqrt(PI)
	endif
	return NaN
End

ThreadSafe Function Gaussian2DIntegral(W_coef)	// peak integral from a 2D-Gaussian fit
	// z = K0+K1*exp((-1/(2*(1-K6^2)))*(((x-K2)/K3)^2 + ((y-K4)/K5)^2 - (2*K6*(x-K2)*(y-K4)/(K3*K5))))
	Wave W_coef
	if (WaveType(W_coef,1)==1)							// W_coef exists, and it is numeric
		Variable K1=W_coef[1], K3=W_coef[3], K6=W_coef[6], K5=W_coef[5]
		return 2*PI * K1 * abs(K3*K5) * sqrt(1-K6^2)
	endif
	return NaN
End



ThreadSafe Function computeCOM(ywave,xwave,[pLo,pHi])	// computes center of mass,  xwave is optional (use $"" if no xwave)
	Wave ywave,xwave
	Variable pLo,pHi										// optional range to check
	Variable com=NaN
	if (WaveType(ywave,1)!=1)							// ywave must exist, and must be numeric
		return NaN
	endif
	Variable N=DimSize(ywave,0)
	pLo = ParamIsDefault(pLo) || numtype(pLo) ? 0 : pLo
	pHi = ParamIsDefault(pHi) || numtype(pHi) ? N-1 : pHi

	MatrixOP/FREE yy = ReplaceNaNs(ywave,0)

	if (pLo>0)
		yy[0,pLo-1] = 0
	endif
	if (pHi < (N-1))
		yy[pHi,N-1] = 0
	endif
	if (WaveExists(xwave))
		yy = numtype(xwave) ? 0 : yy
		MatrixOP/FREE comW = sum(ReplaceNaNs(yy*xwave,0)) / sum(yy))
		com = comW[0]
	else
		Variable syy = sum(yy)
		CopyScales ywave,yy
		yy *= x
		com = sum(yy)/syy
	endif
	return com
End



Function/S FitErrorString(FitError,FitQuitReason)
	Variable FitError,FitQuitReason			// values of V_FitError  &  V_FitQuitReason

	if (FitError==0 && FitQuitReason==0)
		return ""
	endif

	String out=""
	out += SelectString(FitError & 2,"","Singular matrix; ")
	out += SelectString(FitError & 4,"","Out of memory; ")
	out += SelectString(FitError & 8,"","Function returned NaN or INF; ")
	out += SelectString(FitError & 16,"","Fit function requested stop; ")
	out += SelectString(FitError & 32,"","Reentrant curve fitting; ")
	out += StringFromList(FitQuitReason,";the iteration limit was reached;the user stopped the fit;the limit of passes without decreasing chi-square was reached;")
	out = SelectString(strlen(out),"Unspecified Fit Error",out)
	return out
End



Function/Wave PowerIntegerScale(image,power)	// scale the values of image by ^(power) AND for real values preserve the sign
	Wave image					// assumed to be an image, but works for waves of dimension of 1,2, & 3
	Variable power				// must be > 0, uses integer power or integer roots

	String wname, scaling
	Variable ipower
	if (numtype(power) || WaveType(image,1)!=1)
		return $""				// really bad input, power must be a number & image a numeric wave
	elseif (power>1)
		ipower = round(power)
		power = ipower
		wname = GetWavesDataFolder(image,2)+"_pow"+num2istr(ipower)
		sprintf scaling, "^%d",ipower
	elseif (power<1 && power>0)
		ipower = round(1/power)
		power = 1/ipower
		wname = GetWavesDataFolder(image,2)+"_root"+num2istr(ipower)
		sprintf scaling, "^(1/%d)",ipower
	else
		return $""				// power must be > 0
	endif
	if (numtype(ipower+power) || WaveType(image,1)!=1)
		return $""
	endif

	Variable type=WaveType(image)
	Variable itype = (type & 0x06) ? type : 0x02	// if a float or complex then the same type, otherwise single precision outout
	Make/N=(2)/Y=(itype)/O $wname/WAVE=imagePow
	if (type & 0x01)			// for complex images
		MatrixOp/O/C imagePow = powC(abs(image),power)	// don't try to fix sign for complex values
	else
		MatrixOp/O imagePow = powR(abs(image),power) * (2.0* greater(image,0.0) - 1.0)
	endif
	Redimension/Y=(itype) imagePow						// otherwise the MatrixOp always retrurn double
	CopyScales image, imagePow
	SetScale d 0,0,WaveUnits(imagePow,-1)+scaling, imagePow
	Note/K imagePow, ReplaceStringByKey("valueScaling",note(image),scaling,"=")
	return imagePow 
End



Function/T Posix2HFS(posixName,[printIt])	// This is a replacement for PosixToHFS()
	// Since we can replace HFSToPosix() with ParseFilePath(), we no longer need HFSAndPosix.xop
	String posixName
	Variable printIt									// normally returns "" on error, but this causes more printout
	printIt = ParamIsDefault(printIt) ? (strlen(GetRTStackInfo(2))==0) : printIt
	printIt = numtype(printIt) ? 0 : !(!printIt)

	String cmd
	sprintf cmd, "(POSIX file \"%s\") as Unicode text",posixName
	ExecuteScriptText/Z cmd
	if (V_flag)
		if (printIt)
			printf "failure in Posix2HFS(\"%s\")\t\tcmd = '%s'\r",posixName,cmd
			print S_value
		endif
		return ""										// there is no valid file path
	endif
	return S_value[1,strlen(S_value)-2]		// strip off leading & trailing double-quotes
End


Function cpuFrequency()		// return the cpu frequency (Hz)
	if (!stringmatch(StringByKey("OS",IgorInfo(3)),"Macintosh OS X"))
		print "Only know how to get cpu speed from a Mac"
		// DoAlert 0, "Only know how to get cpu speed from a Mac"
		return NaN								// cannot get answer
	endif
	String cmd
	sprintf cmd "do shell script \"sysctl hw.cpufrequency\""
	ExecuteScriptText cmd						//returns something like: 	"hw.cpufrequency: 2000000000"
	Variable freq = NumberByKey("hw.cpufrequency",ReplaceString("\"",S_value,""))
	if (numtype(freq))
		DoAlert 0, "Unable to get cpu frequency, message is '"+S_value+"'"
	endif
	return freq
End

Function/T systemUserName()		// return unix username
	if (!stringmatch(StringByKey("OS",IgorInfo(3)),"Macintosh OS X"))
		print "Only know how to get user name from a Mac"
		return ""								// cannot get answer
	endif
	String cmd
	sprintf cmd "do shell script \"whoami\""
	ExecuteScriptText cmd					//returns the user name in double quotes
	Variable i=strlen(S_value)-2
	String userName=S_value[1,i]
	if (i<=0)									// no name,
		DoAlert 0, "Unable to get user name, message is '"+S_value+"'"
	endif
	return userName
End

Function/T sytemHostname()				// returns the hostname as a string e.g. bob.xray.aps.anl.gov  (not ip address)
	if (!stringmatch(StringByKey("OS",IgorInfo(3)),"Macintosh OS X"))
		DoAlert 0, "Only know how to get hostname from a Mac"
		return ""								// cannot get answer
	endif
	ExecuteScriptText "do shell script \"hostname\""		//returns something like:	"bob.xray.aps.anl.gov"
	String hostname = ReplaceString("\"",S_value,"")
	return ReplaceString("\"",S_value,"")
End

Function/T localTimeZoneName()
	if (!stringmatch(StringByKey("OS",IgorInfo(3)),"Macintosh OS X"))
		print "Only know how to get Time Zone name from a Mac"
		return ""									// cannot get answer
	endif
	ExecuteScriptText "do shell script \"date +'%Z'\""			//returns something like: 	"CST"
	if (strlen(S_value)>5)
		DoAlert 0, "Unable to get local Time Zone name, message is '"+S_value+"'"
	endif
	return ReplaceString("\"",S_value,"")
	return S_value
End


// Get a list of system environment variables, semi-colon separated
#if (stringmatch(IgorInfo(2),"Macintosh"))
Function/T getEnvironment()
	String cmd
	sprintf cmd "do shell script \"source ~/.bash_profile ; env\""
	ExecuteScriptText cmd
	Variable N=strlen(S_value)
	if (char2num(S_value[0]) == 34)			// strip leading double quote
		S_value = S_value[1,N-1]
		N -= 1
	endif
	if (char2num(S_value[N-1]) == 34)		// strip trailing double quote
		S_value = S_value[0,N-2]
	endif
	if (strsearch(S_value, ";", 0)>=0)
		DoAlert 0, "env has semi-colon"
		return ""
	endif
	S_value = ReplaceString("\r",S_value,";")
	return S_value
End
#else
Function/T getEnvVariables()
	return ""
End
#endif



//		These three functions have been moved here from from LoadJZTtaggedData.ipf, BeamProcedures, LoadEPICSscans.ipf, and oldJZTdataLoad.ipf.
//			spec.ipf uses its own version of these so it is stand-alone
//
ThreadSafe Function/T TrimFrontBackWhiteSpace(str)
	String str
	str = TrimLeadingWhiteSpace(str)
	str = TrimTrailingWhiteSpace(str)
	return str
End
//
ThreadSafe Function/T TrimLeadingWhiteSpace(str)
	String str
	Variable i, N=strlen(str)
	for (i=0;char2num(str[i])<=32 && i<N;i+=1)	// find first non-white space
	endfor
	return str[i,Inf]
End
//
ThreadSafe Function/T TrimTrailingWhiteSpace(str)
	String str
	Variable i
	for (i=strlen(str)-1; char2num(str[i])<=32 && i>=0; i-=1)	// find last non-white space
	endfor
	return str[0,i]
End


ThreadSafe Function/T IgorFileTypeString(itype)		// string associated with NUMTYPE from WaveInfo() function, or a WaveType() function
	Variable itype
	//	1:	Complex, added to one of the following:
	//	2:	32-bit (single precision) floating point
	//	4:	64-bit (double precision) floating point
	//	8:	8-bit signed integer
	//	16:	16-bit signed integer
	//	32:	32-bit signed integer
	//	64:	Unsigned, added to 8, 16 or 32 if wave is unsigned

	if (itype>127)
		return ""
	endif
	Variable s
	String stype=""

	stype += SelectString(itype&1,"","complex ")
	stype += SelectString(itype&2,"","single precision float (32-bit)")
	stype += SelectString(itype&4,"","double precision float (64-bit)")
	if (itype & 6)						// done with floating point type
		s = !!(itype&2) + !!(itype&4)
		stype = SelectString(s>1,stype,"")
		return stype
	endif

	s = !!(itype&8) + !!(itype&16) + !!(itype&32)
	if (strlen(stype) || s>1)
		return ""
	endif

	stype = SelectString(itype&64,"signed ","unsigned ")
	stype += SelectString(itype&8,"","8-bit integer ")
	stype += SelectString(itype&16,"","16-bit integer ")
	stype += SelectString(itype&32,"","32-bit integer ")
	return stype
End



Function/T GenericWaveNoteInfo(ww,key,[class,options,type])
	Wave ww
	String key
	String class							// default is all classes
	String options							// default is no options
	String type								// name of wave type (used in prompt), e.g. "image"
	class = SelectString(ParamIsDefault(class),class,"")
	options = SelectString(ParamIsDefault(options),options,"")
	type = SelectString(ParamIsDefault(type),type,"wave")

	Variable printIt = 0
	String wName, wList = WaveListClass(class,"*",options)
	if (!WaveExists(ww) && ItemsInList(wList)==1)
		Wave ww = $StringFromList(0,wList)
		printIt = 1
	endif
	if (!WaveExists(ww))
		String item=""
		Prompt wName,type+" to use", popup, wList
		DoPrompt "pick "+type, wName
		if(V_flag)
			return ""
		endif
		Wave ww=$wName
		printIt = 1
	endif
	wName = NameOfWave(ww)
	if (!WaveExists(ww))
		return ""
	endif
	String list = note(ww)

	FUNCREF MoreWaveNoteInfoProto more = $"MoreWaveNoteInfo"
	list = more(ww,list)

	if (strlen(key)>1)
		item = StringByKey(key,list,"=")
		if (strlen(item)>1 && numtype(str2num(item)) && printIt)
			printf "from '%s',  %s = '%s'\r",wName,key,item
		endif
	else
		Prompt item,"item",popup,list
		DoPrompt "info about "+wName, item
		if(V_flag)
			return ""
		endif
		key = StringFromList(0,item,"=")
		item = StringFromList(1,item,"=")
		printf "from '%s',  %s = %s\r",wName,key,item
	endif
	return item
End
//
Function/T MoreWaveNoteInfoProto(ww,list)		// additions to the list, only called by GenericWaveNoteInfo() in Utility_JZT.ipf
	Wave ww
	String list
	return list
End


Function StopAllTimers()
	Variable i
	String str=""
	for(i=0;i<=9;i+=1)
		str += SelectString(stopMSTimer(i),"",num2istr(i)+" ")
	endfor
	if (strlen(str))
		printf "timers %s were running\r",str
	endif
End


ThreadSafe Function/T dateStr2ISO8601Str(dateStr,[timeStr,zoneHr,zoneMin])	// convert input date string and converts to ISO8601 format
	String dateStr								// something like "4/2/2010" or "2010-4-2"
	String timeStr
	Variable zoneHr, zoneMin				// the time zone in hours or minutes, OPTIONAL, (you can also use hour=6.5)
	timeStr = SelectString(ParamIsDefault(timeStr),timeStr,"")

	Variable d1,d2,d3, dateSec
	dateStr = ReplaceString("-",dateStr,"/")
	sscanf dateStr,"%d/%d/%d",d1,d2,d3
	if (V_flag!=3)
		return ""								// failed to find date like string
	endif
	String outStr="", zoneStr=""
	if (d1>1903)								// assume year/month/day
		sprintf outStr,"%04d-%02d-%02d",d1,d2,d3
	else											// assume month/day/year
		sprintf outStr,"%04d-%02d-%02d",d3,d1,d2
	endif

	if (strlen(timeStr))					// time was also passed
		Variable hour,minute,second
		sscanf timeStr,"%d:%d:%d",hour,minute,second
		if (V_flag<2)							// invalid time of day
			return ""
		elseif(V_flag==2)
			second = 0							// no seconds given, assume 0
		endif
		Variable add12=(strsearch(timeStr,"p",0)>0) && (hour<12)
		hour += add12 ? 12 : 0
		outStr += "T"+Secs2Time(hour*3600+minute*60+second,3)
	endif

	hour = ParamIsDefault(zoneHr) ? 0 : zonehr	// decode the the time zone
	minute = round(ParamIsDefault(zoneMin) ? 0 : zoneMin)
	second = hour*3600 + 60*minute
	if (abs(second)>24*3600)				// time zone > 24h????
		return ""
	endif
	if ((!ParamIsDefault(zoneHr) || !ParamIsDefault(zoneMin)) && numtype(second)==0)	// have a time zone
		if (mod(second/3600,1))			// have minutes
			zoneStr = Secs2Time(abs(second),2)
			zoneStr = SelectString(second<0,"+","-")+zoneStr
		else
			sprintf zoneStr,"%+03d",round(second/3600)
		endif
	endif
	outStr += zoneStr

	return outStr
End


ThreadSafe Function ISOtime2IgorEpoch(iso,[NOTZ])	// convert ISO8601 string to an Igor Epoch (error returns NaN)
	// if no timezone info present, then the result is independent of timezone
	// if timezone info present, then returned seconds are in UTC
	// valid timezones are of the form: "+01", "+0130", "-01:30", "Z" (only Z, not other letters)
	// to get the old behavior, use new ISOtime2IgorEpoch(iso, NOTZ=1) instead
	String iso									// format     2013-10-02T01:22:35-06:00  (the seconds are optional, the time zone is optional)
	Variable NOTZ								// if True, then ignore any time zone info, just use local (this is like the old version)
	NOTZ = ParamIsDefault(NOTZ) || numtype(NOTZ) ? 0 : NOTZ		// default is interpret timezone info

	Variable year,month,day, hr,mn,se

	sscanf iso,"%4d-%2d-%2dT%2d:%2d:%2d", year,month,day,hr,mn,se
	Variable N=V_flag, UTC
	if (N<3)
		return NaN
	endif
	UTC = date2secs(year, month, day )
	UTC += N>=4 ? hr*3600 : 0
	UTC += N>=5 ? mn*60 : 0
	UTC += N>=6 ? se : 0

	Variable i0
	i0 = strsearch(iso,"T",i0)+1
	if (N==3 || NOTZ || i0<1)				// no timezone info, done
		return UTC
	endif

	if (isletter(iso[strlen(iso)-1]))
		if (cmpstr(iso[strlen(iso)-1],"Z"))
			return NaN							// the only allowed letter timezone is "Z"
		endif
	endif
	Variable ip,im,i1
	ip = strsearch(iso,"+",i0)
	im = strsearch(iso,"-",i0)
	i1 = max(ip,im)
	if (i1<0)
		return UTC								// not timezone info, done
	endif
	String tzStr=iso[i1,Inf]

	Variable tzH=0,tzM=0, tzLen=strlen(tzStr)
	if (tzLen==6)
		sscanf tzStr,"%3d:%2d", tzH,tzM
	elseif (tzLen==5)
		sscanf tzStr,"%3d%2d", tzH,tzM
	elseif (tzLen==3)
		sscanf tzStr,"%3d", tzH
	endif
	tzM *= im>0 ? -1 : 1
	tzH += (V_flag==2) ? tzM/60 : 0

	UTC -= tzH*3600
	return UTC
End


ThreadSafe Function/T ISOtime2niceStr(iso)	// convert ISO8601 string to a nice format for graph annotations
	String iso									// format     2013-10-02T01:22:35  (the seconds are optional)

	Variable year=NaN,month=NaN,day=NaN, hr=NaN,mn=NaN,se=NaN
	sscanf iso,"%4d-%2d-%2dT%2d:%2d:%2d", year,month,day,hr,mn,se
	Variable N = V_flag

	if (N<3 || numtype(year+month+day))
		return ""
	endif
	Variable epoch = date2secs(year, month, day )
	String out = Secs2Date(epoch,2)
	if (N>=5)
		epoch += hr*3600
		epoch += mn*60
		se = (N>=6) ? se : 0
		epoch += se
		Variable fmt = (N>=6) ? 1 : 0
		out += SelectString(numtype(epoch),"  "+Secs2Time(epoch,fmt),"")
	endif
	return out
End

ThreadSafe Function/T epoch2ISOtime(epoch,[localTZ])	// convert an Igor epoch (in seconds) to an ISO8601 format
	Variable epoch
	Variable localTZ											// flag if true, then add offset for local time zone
	localTZ = ParamIsDefault(localTZ) || numtype(localTZ) ? 0 : localTZ

	Variable s = mod(epoch,60)							// number of seconds
	Variable frac=roundSignificant(mod(epoch,1),5)// fractional seconds
	Variable places=placesOfPrecision(frac)			// places of precision in frac

	String out=Secs2Date(epoch,-2)+"T"					// date part with "T"
	if (s==0 && frac==0)
		out += Secs2Time(epoch,2)							// no seconds, just hr:min
	elseif (frac==0)
		out += Secs2Time(epoch,3)							// seconds, but no fracitonal seconds
	else
		out += Secs2Time(epoch,3,places)				// fractional seconds
	endif

	if (localTZ)												// add time zone info
		Variable tz = date2secs(-1,-1,-1)
		if (tz==0)
			out += "Z"
		else
			String str, ssign=SelectString(tz>0,"-","+")	
			tz = abs(tz)										// sign already taken care of by ssign
			Variable hr = trunc(tz/3600)
			Variable minutes = round(mod(tz/60,60))
			sprintf str,"%02d", tz/3600
			out += ssign+str
			if (minutes)			// minutes too
				sprintf str,":%02d",minutes
				out += str
			endif
		endif
	endif
	return out
End


Function AskForUserForDateTime(epoch)
	// puts up a dialog to select a date & time, returns the epoch (NaN on error or Cancel)
	// return NaN for invalid dates (e.g. Apr 31, or Feb 29 2005)
	Variable epoch
	epoch = (numtype(epoch) || epoch<=0) ? DateTime : epoch

	Variable day,month,year
	sscanf Secs2Date(epoch,-2), "%4d-%2d-%2d",year,month,day

	Variable midnight = epoch-date2secs(year,month,day)		// seconds since midnight(year,month,day)
	Variable hour=floor(midnight/3600), minute=floor(mod(midnight/60,60)), second=floor(mod(midnight,30))

	Prompt day,"Date", popup, expandRange("1-31",";")
	Prompt month,"Month", popup, "January;February;March;April;May;June;July;August;September;October;November;December"
	Prompt year,"Year", popup, expandRange("1995-2025",";")
	Prompt hour,"Hours [0-23]",popup,expandRange("0-23",";")
	Prompt minute,"Minutes [0-59]",popup,expandRange("0-59",";")
	Prompt second,"Seconds [0-59]",popup,expandRange("0-59",";")
	year -= 1994
	hour += 1
	minute += 1
	second += 1
	DoPrompt "Date/Time",day,hour,month,minute,year,second
	if (V_flag)
		return NaN
	endif
	year += 1994
	hour -= 1
	minute -= 1
	second -= 1

	Variable err=0
	switch(month)
		case 2:			// February is special 28 days except leap year
			err = err || (mod(year,4) && day>28)		// on non-leap year, Feb only to 28
			err = err || (mod(year,4)==0 && day>29)	// on leap year, Feb goes to 29
		case 4:			// April, these four months have 30 days
		case 6:			// June
		case 9:			// September
		case 11:			// November
			err = err || day>30
	endswitch
	epoch = err ? NaN : date2secs(year,month,day) + 3600*hour + 60*minute + second
	return epoch
End


Function/T ElapsedTime2Str(seconds,[showSec,fracDigits])	// convert seconds to a nice time interval string
	Variable seconds
	Variable showSec
	Variable fracDigits

	if (ParamIsDefault(showSec) && ParamIsDefault(fracDigits))
		if (seconds < 5*60)
			showSec = 1
		endif
		if (seconds < 2)
			fracDigits = 2
		elseif (seconds < 60)
			fracDigits = 1
		else
			fracDigits = 0
		endif
	else
		showSec = ParamIsDefault(showSec) || numtype(showSec) ? 0 : showSec
		fracDigits = ParamIsDefault(fracDigits) || numtype(fracDigits) ? 0 : fracDigits
		fracDigits = fracDigits<=0 || showSec<5 ? 0 : round(fracDigits)
	endif
	showSec = showSec ? 5 : 4

	Variable years=trunc(seconds/(365*24*3600))	// integer number of years (365.0 days/year)
	seconds -= years * (365*24*3600)
	Variable weeks=trunc(seconds/(7*24*3600))		// integer number of weeks (<= 52)
	seconds -= weeks * (7*24*3600)
	Variable days=trunc(seconds/(24*3600))			// integer number of days (<= 7)
	seconds -= days * (24*3600)

	String str=""
	if (years>0)
		str += num2istr(years)+" yr,  "
	endif
	if (weeks>0)
		str += num2istr(weeks)+" wk,  "
	endif
	if (days>0)
		str += num2istr(days)+" d,  "
	endif
	if (seconds>0)
		str += Secs2Time(seconds,showSec,fracDigits)
	endif
	str = RemoveEnding(str,",  ")
	return str
End



ThreadSafe Function/T vec2str(w1,[places,fmt,maxPrint,bare,zeroThresh,sep])		// convert vector to s string suitable for printing, does not include name
	Wave w1										// 1d wave to print
	Variable places							// number of places, for default, use negative or NaN
	String fmt									// optional format for on number, this OVERRIDES places
	Variable maxPrint							// maximum number of elements to print, defaults to 20
	Variable bare								// if bare is TRUE, then suppress the "{}" in the output
	Variable zeroThresh						// |values| < zeroThresh show as a "0", in many vectors 1e-15 is really zero
	String sep									// optional separator, default is ",  "   a comma and 2 spaces

	maxPrint = ParamIsDefault(maxPrint) ? 20 : maxPrint
	maxPrint = maxPrint>0 ? maxPrint : 20
	places = ParamIsDefault(places) ? -1 : places
	fmt = SelectString(ParamIsDefault(fmt),fmt,"")
	bare = ParamIsDefault(bare) ? 0 : !(!bare)
	zeroThresh = ParamIsDefault(zeroThresh) || numtype(zeroThresh) || zeroThresh<=0 ? NaN : zeroThresh
	sep = SelectString(ParamIsDefault(sep),sep,",  ")

	if (!WaveExists(w1))
		return SelectString(bare,"{}","")
	endif

//	Wave/T tw=$GetWavesDataFolder(w1,2)
//	Wave/C cw=$GetWavesDataFolder(w1,2)
	Variable waveIsComplex = WaveType(w1) %& 0x01
	Variable numeric = (WaveType(w1)!=0)

	if (strlen(fmt))
		// fmt was passed, do not reset it
	elseif (waveIsComplex)
		Wave/C cw=w1
		places = places>=0 ? min(20,places) : 5	// default to 5 for unacceptable values
		sprintf fmt,"(%%.%dg, %%.%dg)",places,places
	elseif (numeric)
		places = places>=0 ? min(20,places) : 5	// default to 5 for unacceptable values
		sprintf fmt,"%%.%dg",places
	elseif (places>0)										// must be text, and a maximum length given
		Wave/T tw=w1
		sprintf fmt, "\"%d%%s\"",places
	else														// must be text with no preferred length
		Wave/T tw=w1
		fmt = "\"%%s\""
	endif

	Duplicate/FREE w1, wInternal
	if (numeric)
		if (!zeroThresh || numtype(zeroThresh))
			zeroThresh = DefaultZeroThresh(w1)
		endif
		wInternal = abs(wInternal)<zeroThresh ? 0 : wInternal
	endif

	Variable i=0, n
	n = numpnts(wInternal)
	maxPrint = min(n,maxPrint)
	String str, out=SelectString(bare,"{","")

	do
		if (waveIsComplex)						// a complex wave
			sprintf str,fmt, real(cw[i]),imag(cw[i])
		elseif (numeric && (!waveIsComplex))	// a simple number wave
			sprintf str,fmt, wInternal[i]
		elseif (!numeric)							// a text wave
			sprintf str,"\"%s\"", tw[i]
		endif
		out += str
		if (i<(n-1))
			sprintf str,sep
			out += str
		endif
		i += 1
	while (i<maxPrint)
	if (n>maxPrint)
		sprintf str,"...}\ronly printed %d of %d values\r",maxPrint,n
		out += str
	else
		out += SelectString(bare,"}","")
	endif
	return out
End
//
ThreadSafe Static Function DefaultZeroThresh(ww)
	Wave ww
	switch(WaveType(ww) & 0x3E)
		case 0x02:						// 32 bit float
			return Smallest32bitFloat
		case 0x04:						// 64 bit float
			return Smallest64bitFloat
		default:							// all integer types
			return 0
	endswitch
End
//Function FindSmallestFloatMachine()
//	Variable last
//	Make/N=1/D/FREE double=1
//	do
//		last = double[0]
//		double[0] /= 2
//	while(double[0]!=0)
//	print/d last
//
//	Variable mult=0.9999999, factor=mult
//	double[0] = last
//	do
//		last = double[0]
//		double[0] *= factor
//		factor *= mult
//	while(double[0]!=0)
//	print/d last
//
//	print " "
//	Make/N=1/FREE single=1
//	do
//		last = single[0]
//		single[0] /= 2
//	while(single[0]!=0)
//	print/d last
//
//	factor=mult
//	single[0] = last
//	do
//		last = single[0]
//		single[0] *= factor
//		factor *= mult
//	while(single[0]!=0)
//	print/d last
//End


ThreadSafe Function/WAVE str2vec(str,[sep])// returns a free vector based on the string
	String str
	String sep											// optional separator, if not included will figure it out
	sep = SelectString(ParamIsDefault(sep),sep,"")

	if (strlen(str)<1)
		return $""
	elseif (strlen(sep)>1)							// sep can only be 1 character long
		return $""
	endif

	Variable i0=strsearch(str,"{",0), i1=strsearch(str,"}",0)
	if (i1>(i0+1) && i0>=0)						// vec is in {...} form, remove leading "{" and trailing "}"
		str = str[i0+1,i1-1]
	endif

	if (strlen(sep)==0)								// determine the separator and set it so semi-colon
		if (strsearch(str,";",0)>=0)
			str = ReplaceString(",",str,";")	// change comma separators to semi-colons, this represents a mixture of separators
		elseif (strsearch(str,",",0)>=0)
			str = ReplaceString(",",str,";")	// change comma separators to semi-colons
		elseif (strsearch(str,"\t",0)>=0)
			str = ReplaceString("\t",str,";")	// change tab separators to semi-colons
		else												// assume space separators
			str = TrimFrontBackWhiteSpace(str)	// remove leading & trailing white space
			do
				str = ReplaceString("  ",str," ")	// change all multi-space runs to single spaces
			while (strsearch(str,"  ",0)>=0)
			str = ReplaceString(" ",str,";")	// change space separators to semi-colons
		endif
		sep = ";"
	endif

	Variable N=ItemsInList(str,sep)				// number of values in str
	Make/N=(N)/FREE/D ww
	ww = str2num(StringFromList(p,str,sep))
	return ww
End
//
//	Function test_str2vec(str,[sep])			// try test_str2vec("1  3 2",sep="  ")
//		String str
//		String sep
//	
//		if (ParamIsDefault(sep))
//			Wave vec = str2vec(str)
//		else
//			Wave vec = str2vec(str,sep=sep)
//		endif
//		printf "'%s' --> %s\r",str,vec2str(vec)
//	End


// The routines encodeMatAsStr() and decodeMatFromStr() are NOT intended for viewing by user, but for a wave note
ThreadSafe Function/T encodeMatAsStr(mat,[places,vsep])	// write a string interpretable by decodeMatFromStr
	Wave mat
	Variable places		// defaults to 15 places of precisiont
	String vsep				// optional separator between vectors, use "," for Igor readable strings (the default)
	places = ParamIsDefault(places) || !(places>0) ? 15 : places
	vsep = SelectString(ParamIsDefault(vsep),vsep,",")

	Variable i, Nr=DimSize(mat,0), Nc=DimSize(mat,1)
	if (Nc<1)
		return vec2str(mat,places=places,sep=",")
	endif

	Make/N=(Nr)/D/FREE vec
	String str="{"
	for (i=0;i<Nc;i+=1)
		vec = mat[p][i]
		str += SelectString(i,"",vsep)			// no separator before first vector
		str += vec2str(vec,places=places,sep=",")
	endfor
	str += "}"
	return str
End


// This is also may be used as a replacement for str2recip() in LatticeSym.ipf
ThreadSafe Function/WAVE decodeMatFromStr(strIn)	// returns a FREE wave defined by str
	// strIn looks something like "{{1.3,0,0},{0,1.3,0},{0,0,1.3},{3.14,2,19.666}}"
	//    or "{1.3,0,0}{0,1.3,0}{0,0,1.3}" is also OK
	String strIn
	strIn = ReplaceString(" ",strIn,"")		// remove all spaces
	strIn = ReplaceString("\t",strIn,"")		//   and tabs
	strIn = ReplaceString("},{",strIn,";")	// use ';' to separate the column vectors
	strIn = ReplaceString("}{",strIn,";")		//   accept either "},{" or "}{"
	strIn = ReplaceString("{",strIn,"")		// remove leading "{"
	strIn = ReplaceString("}",strIn,"")		//   and remove and trailing "}"

	String str=StringFromList(0,strIn)
	Variable ic, Nr=ItemsInList(str,","), Nc=ItemsInList(strIn)	// number of rows, columns
	if (!(Nr*Nc>0))
			return $""									// Nr & Nc must both be non-zero
	endif
	Make/N=(Nr,Nc)/D/FREE mat=NaN				// mat is the result, fill it
	for (ic=0;ic<Nc;ic+=1)
		Wave vec = str2vec(StringFromList(ic,strIn))
		if (!(numpnts(vec)==Nr))					// every vector should have length of Nr
			return $""
		endif
		mat[][ic] = vec[p]
	endfor
	if (Nc==1)
		Redimension/N=(Nr) mat
	endif
	return mat
End


ThreadSafe Function/T cmplx2str(zz,[places,pow])		// convert complex number to a printable string
	Variable/C zz
	Variable places
	Variable pow						// optional parameter for magnitude, adds |zz|^pow
	places = ParamIsDefault(places) ? NaN : places
	places = round(places)
	pow = ParamIsDefault(pow) ? 0 : pow
	pow = numtype(pow) ? 0 : pow

	Variable powValue=NaN
	String str, fmt1="%g", fmt="(%g, %g)", powStr=""
	if (places == limit(places,0,20))
		fmt1 = "%."+num2istr(places)+"g"
	endif
	if (pow)
		powStr = SelectString(pow==1, "^"+num2str(pow), "")
		powValue = sqrt(magsqr(zz))^pow
		sprintf fmt,"|(%s, %s)|%%s = %s",fmt1,fmt1,fmt1
		sprintf str,fmt,real(zz),imag(zz),powStr,powValue
	else
		sprintf fmt,"(%s, %s)",fmt1,fmt1
		sprintf str,fmt,real(zz),imag(zz)
	endif

	return str
End


ThreadSafe Function/C str2cmplx(str)	// this is like str2num, but for complex
	String str

	str = ReplaceCharacters("()[]{}",str,"")
	str = ReplaceCharacters(",;:",str," ")
	Variable rr,ii
	sscanf str,"%g %g",rr,ii
	if (V_flag==2)
		return cmplx(rr,ii)
	endif
	return cmplx(NaN,NaN)					// fail
End


ThreadSafe Function/T ReplaceCharacters(chars,inStr,replacement)
	// replace all occurances of a character in chars[] with replacement
	String chars			// look for each of the characters in chars
	String inStr			// input string
	String replacement	// replace every occurance of chars[i] with this

	Variable i, N=strlen(chars)
	for (i=0;i<N;i+=1)
		inStr = ReplaceString(chars[i],inStr,replacement)	
	endfor
	return inStr
End


//  ====================================================================================  //
//  ============================== Start of Wave Printing ==============================  //

ThreadSafe Function printWave(w1,[name,brief,fmt,zeroThresh])	// print a wave (vector or matrix) to history
	Wave w1
	String name									// optional user supplied name to use
	Variable brief								// print in briefer form
	String fmt									// optional format for on number
	Variable zeroThresh						// |values| < zeroThresh show as a "0", in many vectors 1e-15 is really zero
	if (ParamIsDefault(name))
		name = NameOfWave(w1)
	endif
	brief = ParamIsDefault(brief) ? 0 : !(!brief)
	fmt = SelectString(ParamIsDefault(fmt),fmt,"")
	zeroThresh = ParamIsDefault(zeroThresh) || numtype(zeroThresh) || zeroThresh<=0 ? NaN : zeroThresh
	if (!WaveExists(w1))
		print "in 'printWave', wave does not exist"
		return 1
	endif

	if (DimSize(w1, 1)<=1)					// for vectors
		printvec(w1,name=name,fmt=fmt,zeroThresh=zeroThresh)
	elseif (DimSize(w1, 2)==0)			// for 2-d matrix
		if (DimSize(w1,0)<=1 || DimSize(w1,1)<=1)
			printvec(w1,name=name,zeroThresh=zeroThresh)
		else
			return printmat(w1,name=name,brief=brief,fmt=fmt,zeroThresh=zeroThresh)
		endif
	else
		print "cannot yet handle dimensions 3 or 4"
	endif
	return 0
End
//
ThreadSafe Static Function printvec(w1,[name,fmt,zeroThresh])	// print a vector to screen
	Wave w1
	String name									// optional user supplied name to use
	String fmt									// optional format for on number
	Variable zeroThresh						// |values| < zeroThresh show as a "0", in many vectors 1e-15 is really zero
	if (ParamIsDefault(name))
		name = NameOfWave(w1)
	endif
	fmt = SelectString(ParamIsDefault(fmt),fmt,"")
	zeroThresh = ParamIsDefault(zeroThresh) || numtype(zeroThresh) || zeroThresh<=0 ? NaN : zeroThresh

	if (strlen(name))
		printf "%s = %s\r", name,vec2str(w1, fmt=fmt, zeroThresh=zeroThresh)
	else
		printf "%s\r", vec2str(w1, fmt=fmt, zeroThresh=zeroThresh)
	endif
End
//
ThreadSafe Static Function printmat(m1,[name,brief,fmt,rowMax,zeroThresh])
	Wave m1
	String name									// optional user supplied name to use
	Variable brief								// print in briefer form
	String fmt									// optional format for on number
	Variable rowMax							// maximum number of rows to print
	Variable zeroThresh						// |values| < zeroThresh show as a "0", in many vectors 1e-15 is really zero
	if (ParamIsDefault(name))
		name = NameOfWave(m1)
	endif
	brief = ParamIsDefault(brief) ? 0 : !(!brief)
	fmt = SelectString(ParamIsDefault(fmt),fmt,"")
	rowMax = ParamIsDefault(rowMax) ? 50 : rowMax
	rowMax = (rowMax>0) ? rowMax : 50
	zeroThresh = ParamIsDefault(zeroThresh) || numtype(zeroThresh) || zeroThresh<=0 ? NaN : zeroThresh
	if (DimSize(m1,1)==0 || DimSize(m1,2)!=0)	// for 2-d matrix only
		print "Can only print 2-d matricies with printmat"
		// DoAlert 0, "Can only print 2-d matricies with printmat"
		return 1
	endif

	if (brief && strlen(name))
		printf "%s:\r",name
	endif
	Variable Nrow=DimSize(m1,0), row
	Nrow = min(Nrow,rowMax)
	for (row=0;row<Nrow;row+=1)
		if (WaveType(m1) %& 0x01)			// true for complex numbers
			print printmatOneListComplex(m1,row, name=name, brief=brief, fmt=fmt, zeroThresh=zeroThresh)
		else
			print printmatOneListReal(m1,row, name=name, brief=brief, fmt=fmt, zeroThresh=zeroThresh)
		endif
	endfor
	if (DimSize(m1,0)>Nrow)
		print "      ."
		print "      ."
		printf "      .\t\t printed only %d of the %d rows\r",Nrow,DimSize(m1,1)
	endif
//	if (DimSize(mw,0)>Nrow || DimSize(mw,1)>Nrow)
//		printf "Only printed part of the (%d x %d) matrix\r",DimSize(mw,0),DimSize(mw,1)
//	endif
	return 0
End
//
ThreadSafe Static Function/T printmatOneListReal(m1,row,[name,brief,fmt,zeroThresh])// print one line for real (not complex) matricies
	Wave m1
	Variable row								// row number (starts with 0)
	String name									// optional user supplied name to use
	Variable brief								// print in briefer form
	String fmt									// optional format for on number
	Variable zeroThresh						// |values| < zeroThresh show as a "0", in many vectors 1e-15 is really zero
	if (ParamIsDefault(name))
		name = NameOfWave(m1)
	endif
	brief = ParamIsDefault(brief) || numtype(brief) ? 0 : !(!brief)
	fmt = SelectString(ParamIsDefault(fmt)|| strlen(fmt)<1,fmt,"%g")
	zeroThresh = ParamIsDefault(zeroThresh) || numtype(zeroThresh) || zeroThresh<=0 ? NaN : zeroThresh
	if (!zeroThresh || numtype(zeroThresh))
		zeroThresh = DefaultZeroThresh(m1)
	endif

	Duplicate/FREE m1, mInternal
	mInternal = abs(m1)<zeroThresh ? 0 : m1
	if (brief)
		fmt = fmt + "    "
	else
		fmt = "%s[%d][%d] = "+fmt+";    "
	endif

	String line="", str
	Variable j, Ncol=DimSize(m1,1)
	for (j=0;j<Ncol;j+=1)
		if (strlen(line)>100)
			line += "  ..."
			break
		elseif (brief)
			sprintf str, fmt,mInternal[row][j]
		else
			sprintf str, fmt,name,row,j,mInternal[row][j]
		endif
		line += str
	endfor
	line = line[0,strlen(line)-4-1]		// strip off trailing 4 spaces
	return line
End
//
ThreadSafe Static Function/T printmatOneListComplex(m1,row,[name,brief,fmt,zeroThresh])// print one line for complex (not real) matricies
	Wave/C m1
	Variable row								// row number (starts with 0)
	String name									// optional user supplied name to use
	Variable brief								// print in briefer form
	String fmt									// optional format for on number
	Variable zeroThresh						// |values| < zeroThresh show as a "0", in many vectors 1e-15 is really zero
	if (ParamIsDefault(name))
		name = NameOfWave(m1)
	endif
	brief = ParamIsDefault(brief) || numtype(brief) ? 0 : !(!brief)
	fmt = SelectString(ParamIsDefault(fmt),fmt,"%g,%g")
	zeroThresh = ParamIsDefault(zeroThresh) || numtype(zeroThresh) || zeroThresh<=0 ? NaN : zeroThresh

	if (!zeroThresh || numtype(zeroThresh))
		zeroThresh = DefaultZeroThresh(m1)
	endif

	Make/N=(DimSize(m1,0))/D/FREE rInternal,iInternal
	rInternal = real(m1)
	iInternal = imag(m1)
	rInternal = abs(rInternal)<zeroThresh ? 0 : rInternal
	iInternal = abs(iInternal)<zeroThresh ? 0 : iInternal

	if (brief)
		fmt = "("+fmt+")    "
	else
		fmt = "%s[%d][%d] = ("+fmt+");    "
	endif

	String line="", str
	Variable j, Ncol=DimSize(m1,1)
	for (j=0;j<Ncol;j+=1)
		if (strlen(line)>100)
			line += "  ..."
			break
		elseif (brief)
			sprintf str, fmt,rInternal[row][j],iInternal[row][j]
		else
			sprintf str, fmt,name,row,j,rInternal[row][j],iInternal[row][j]
		endif
		line += str
	endfor
	line = line[0,strlen(line)-4-1]		// strip off trailing 4 spaces
	return line
End

//  =============================== End of Wave Printing ===============================  //
//  ====================================================================================  //



//  ====================================================================================  //
//  ============================== Start of Square Pixels ==============================  //
Function SetAspectToSquarePixels(gName)
	// Used to square up a graph window
	String gName										// name of the graph, use "" for the top graph
	Variable printIt = strlen(GetRTStackInfo(2))<=0
	if (strlen(gName)<1)
		gName = StringFromList(0,WinList("*",";","WIN:1"))
	endif
	if (WinType(gName)!=1)
		if (printIt)
			DoAlert 0, "ERROR, in SetAspectToSquarePixels(), '"+gName+"' is not an graph"
		endif
		return NaN										// if no image on graph, do not try to set aspect ratio
	endif

	GetAxis/W=$gName/Q bottom
	if (V_flag)											// if no bottom, try top
		GetAxis/W=$gName/Q top
	endif
	if (V_flag)
		if (printIt)
			DoAlert 0, "ERROR, SetAspectToSquarePixels(), unable to get size of vertical axis"
		endif
		return NaN
	endif
	Variable width = abs(V_max-V_min)

	GetAxis/W=$gName/Q left
	if (V_flag)											// if no left, try right
		GetAxis/W=$gName/Q right
	endif
	if (V_flag)
		if (printIt)
			DoAlert 0, "ERROR, SetAspectToSquarePixels(), unable to get size of horizontal axis"
		endif
		return NaN
	endif
	Variable height = abs(V_max-V_min)

	Variable aspect = height / width
	//	printf "size ,  width = %g,  height = %g,   aspect = height/width = %g\r",width,height,aspect
	if (numtype(aspect) || aspect<=0)
		return NaN
	elseif (aspect<1)
		ModifyGraph/W=$gName height={Aspect,aspect}, width=0
	elseif (aspect>=1)
		ModifyGraph/W=$gName width={Aspect,1/aspect}, height=0
	endif

	return aspect
End


Function SquareUpGizmo(gName)
	// Used to square up a graph gizmo
	String gName
	if(exists("NewGizmo")!=4)				// Do nothing if the Gizmo XOP is not available.
		DoAlert 0, "Gizmo XOP must be installed"
		return 1
	elseif (strlen(gName)<1)
#if (IgorVersion()<7)
		Execute "GetGizmo gizmoName"
		gName = StrVarOrDefault("S_GizmoName","")
		KillStrings/Z S_GizmoName
#else
		GetGizmo gizmoName
		gName = S_GizmoName
#endif
	endif
	if (strlen(gName)<1)
		return 1
	endif

#if (IgorVersion()<7)
	Execute "GetGizmo winPixels"			// get window position & size
	NVAR V_left=V_left, V_top=V_top, V_bottom=V_bottom
#else
	GetGizmo winPixels						// get window position & size
#endif
	Variable height=V_bottom-V_top, top=max(44,V_top)
	MoveWindow/W=$gName V_left, top, V_left+height, V_top+height
	KillVariables/Z V_left, V_right, V_top, V_bottom
End

//  =============================== End of Square Pixels ===============================  //
//  ====================================================================================  //

ThreadSafe Function/T num2Ordinal(n)
	// converts integer n to ordinal string, e.g. 1 --> "1st"
	// if n is not an integer then just append "th"
	Variable n		// an integer
	String ending=StringFromList(abs(n),"th;st;nd;rd;")
	ending = SelectString(strlen(ending),"th",ending)
	if (numtype(n))
		ending = ""
	elseif (abs(round(n)-n)>1e-5)
		ending = "th"
	else
		n = round(n)
	endif
	return num2str(n)+ending
End


ThreadSafe Function/T ChangeStrEnding(oldEnd, inStr, newEnd)
	// if inStr ends in oldEnd, replace oldEnd with newEnd
	// if oldEnd =="", always add newEnd
	// if newEnd=="", removes oldEnd
	String oldEnd					// existing ending to replace
	String inStr					// given string
	String newEnd					// replace oldEnd with this
	if (StringMatch(inStr,"*"+oldEnd))
		inStr = RemoveEnding(inStr,oldEnd)+newEnd
	endif
	return inStr
End


ThreadSafe Function SIprefix2factor(prefix)
	String prefix
	// return the product of the prefixes, e.g. "mp" returns 1e-15
	// white space (anything <= a space) is ignored.
	// for bad prefix values, (e.g. "v" or "3") returns NaN
	// Note, internally I use "o" instead of "µ" since the NumberByKey() routine does not work with a key="µ"
	// also note that all prefixes are case sensitive except for "H" and "K", which can be either upper or lower.
	//		deci	= "d" = 0.1
	//		centi	= "c" = 0.01
	//		milli	= "m" = 1e-3
	//		micro	= "µ" = 1e-6
	//		nano	= "n" = 1e-9
	//		pico	= "p" = 1e-12
	//		femto	= "f" = 1e-15
	//		atto	= "a" = 1e-18
	//		zepto	= "z" = 1e-21
	//		yocto	= "y" = 1e-24
	//
	//		hecto	= "H" = 100  (or "h")
	//		kilo	= "K" = 1e3  (or "k")
	//		Mega	= "M" = 1e6
	//		Giga	= "G" = 1e9
	//		Tera	= "T" = 1e12
	//		Peta	= "P" = 1e15
	//		Exa	= "E" = 1e18
	//		Zeta	= "Z" = 1e21
	//		Yotta	= "Y" = 1e24

	if (strsearch(prefix,"o",0)>=0)				// need to check for "o", which is also invalid
		return NaN
	endif
	prefix = ReplaceString("µ",prefix,"o")	// NumberByKey() routine does not work with a key="µ", so use internally use "o" instead

	String keyVals="d:0.1;c:0.01;m:1e-3;o:1e-6;n:1e-9;p:1e-12;f:1e-15;a:1e-18;z:1e-21;y:1e-24;"
	keyVals += "h:100;H:100;k:1e3;K:1e3;M:1e6;G:1e9;T:1e12;P:1e15;E:1e18;Z:1e21;Y:1e24;"

	Variable i, value
	String ch
	for (i=0,value=1; i<strlen(prefix); i+=1)
		ch = prefix[i]
		if (char2num(ch)>32)
			value *= NumberByKey(ch,keyVals,":",";",1)
		endif
	endfor
	return value
End
//	Function test_SIprefix2factor()
//		String chars=" dcmµnpfazyHhKkMGTPEZYv"
//		Variable i
//		for (i=0;i<strlen(chars);i+=1)
//			printf " '%s'  %g\r",chars[i],SIprefix2factor(chars[i])
//		endfor
//		print " "
//		print "following should be 1's"
//		printf "%g, %g, %g, %g, %g, ", SIprefix2factor("cH"), SIprefix2factor("mk"), SIprefix2factor("µM"), SIprefix2factor("nG"), SIprefix2factor("pT")
//		printf "%g, %g, %g, %g\r", SIprefix2factor("fP"), SIprefix2factor("aE"), SIprefix2factor("zZ"), SIprefix2factor("yY")
//	End


ThreadSafe Function ConvertUnits2meters(unit,[defaultLen])
	// returns conversion factor from unit to meters
	String unit
	Variable defaultLen
	defaultLen = ParamIsDefault(defaultLen) ? NaN : defaultLen

	unit = ReplaceString(" ",unit,"")			// no spaces

	// check for powers  "^N"
	Variable ipow=strsearch(unit,"^",0), power=1
	if (ipow>=0)										// found a power
		power = str2num(unit[ipow+1,Inf])		// number after "^"
		unit = unit[0,ipow-1]						// string before "^"
	endif

	// fix spellings
	unit = ChangeStrEnding("metre",unit,"meter")	// British spelling
	unit = ChangeStrEnding("feet",unit,"foot")
	unit = ChangeStrEnding("inches",unit,"inch")
	unit = ChangeStrEnding("fermi",unit,"fm")
	unit = ChangeStrEnding("Ã…",unit,"")		// funny encoding of Angstrom symbol
	unit = ChangeStrEnding("Ang",unit,"")	// lots of ways to write Angstrom
	unit = ChangeStrEnding("Angstrom",unit,"")
	unit = ChangeStrEnding("micrometer",unit,"µm")
	unit = ChangeStrEnding("micron",unit,"µm")
	unit = ChangeStrEnding("micro",unit,"µ")
	unit = RemoveEnding(unit,"s")				// remove any trailing "s"

	String prefix
	Variable value=NaN, i = max(0,strlen(unit)-1)
	if (strsearch(unit,"m",i)==i)				// ends in 'm', means meters
		value = 1
		prefix = unit[0,strlen(unit)-2]
	elseif(StringMatch(unit,"*"))	 			// the Angstrom
		value = 1e-10
		prefix = unit[0,strlen(unit)-2]
	elseif(StringMatch(unit,"*CuXunit") || StringMatch(unit,"*CuXU"))	// the Cu X-unit
		value = 1.00207697e-13 
		i = StringMatch(unit,"*CuXU") ? 5 : 8
		prefix = unit[0,strlen(unit)-8]
	elseif(StringMatch(unit,"*MoXunit") || StringMatch(unit,"*MoXU")) // the Mo X-unit
		value = 1.00209952e-13 
		i = StringMatch(unit,"*MoXU") ? 5 : 8
		prefix = unit[0,strlen(unit)-8]
	elseif(StringMatch(unit,"*Xunit") || StringMatch(unit,"*XU"))		// the X-unit (just average of Mo & Cu)
		value = 1.002088e-13
		i = StringMatch(unit,"*XU") ? 3 : 6
		prefix = unit[0,strlen(unit)-i]
	elseif(StringMatch(unit,"*pc") || StringMatch(unit,"*parsec"))
		value = 3.08568025e16
		i = StringMatch(unit,"*parsec") ? 7 : 3
		prefix = unit[0,strlen(unit)-i]
	elseif(StringMatch(unit,"*ly") || StringMatch(unit,"*lightYear"))
		value = 9.4605284e15
		i = StringMatch(unit,"*lightYear") ? 10 : 3
		prefix = unit[0,strlen(unit)-i]
	elseif(StringMatch(unit,"*au") || StringMatch(unit,"*astronomicalunit"))
		value = 149597870700
		i = StringMatch(unit,"*au") ? 3 : 17
		prefix = unit[0,strlen(unit)-i]
	elseif(StringMatch(unit,"*a0") || StringMatch(unit,"*ao") || StringMatch(unit,"*BohrRadiu"))
		value = 0.52917721092e-10
		i = StringMatch(unit,"*BohrRadiu") ? 10 : 3		// the "s" got trimmed off!
		prefix = unit[0,strlen(unit)-i]
	elseif(StringMatch(unit,"*Plank") || StringMatch(unit,"*PlanckLength"))
		value = 1.616199e-35
		i = StringMatch(unit,"*Plank") ? 6 : 13
		prefix = unit[0,strlen(unit)-i]
	elseif(StringMatch(unit,"*in") || StringMatch(unit,"*inch"))	 	// a few english units just for fun
		value = 25.4e-3
		i = StringMatch(unit,"*inch") ? 5 : 3
		prefix = unit[0,strlen(unit)-i]
	elseif(StringMatch(unit,"*ft") || StringMatch(unit,"*foot") || StringMatch(unit,"*feet"))
		value = 12*25.4e-3
		i = StringMatch(unit,"*ft") ? 3 : 5
		prefix = unit[0,strlen(unit)-i]
	elseif(StringMatch(unit,"*nauticalmile"))
		value = 1852
		prefix = unit[0,strlen(unit)-13]
	elseif(StringMatch(unit,"*mi") || StringMatch(unit,"*mile"))
		value = 5280*12*25.4e-3
		i = StringMatch(unit,"*mile") ? 5 : 3
		prefix = unit[0,strlen(unit)-i]
	elseif(StringMatch(unit,"*yd") || StringMatch(unit,"*yard"))
		value = 3*12*25.4e-3
		i = StringMatch(unit,"*yard") ? 5 : 3
		prefix = unit[0,strlen(unit)-i]
	elseif(StringMatch(unit,"*mil"))			// 0.001 inch
		value = 25.4e-6
		prefix = unit[0,strlen(unit)-4]
	elseif(StringMatch(unit,"*fathom"))		// 6 feet
		value = 6*12*25.4e-3
		prefix = unit[0,strlen(unit)-7]
	elseif(StringMatch(unit,"*chain"))			// 66 feet
		value = 66*12*25.4e-3
		prefix = unit[0,strlen(unit)-6]
	elseif(StringMatch(unit,"*rod"))			// 16.5 feet
		value = 16.5*12*25.4e-3
		prefix = unit[0,strlen(unit)-4]
	elseif(StringMatch(unit,"*league"))		// 3 miles
		value = 3*5280*12*25.4e-3
		prefix = unit[0,strlen(unit)-7]
	elseif(StringMatch(unit,"*furlong"))		// 660 feet
		value = 660*12*25.4e-3
		prefix = unit[0,strlen(unit)-8]
	elseif(StringMatch(unit,"*cubit"))			// a rough number
		value = 0.525
		prefix = unit[0,strlen(unit)-6]
	elseif(StringMatch(unit,"*point"))			// 1/72 inch
		value = 25.4e-3 / 72
		prefix = unit[0,strlen(unit)-6]
	elseif(StringMatch(unit,"*pica"))			// 1/72 foot
		value = 12*25.4e-3 / 72
		prefix = unit[0,strlen(unit)-5]
	elseif(StringMatch(unit,"*Li"))				// Chinese mile is 500m
		value = 500
		prefix = unit[0,strlen(unit)-3]
	else
		return defaultLen								// cannot find base value
	endif

	value *= SIprefix2factor(prefix)
	return (power==1) ? value : (value ^ power)
End


Function/T ConvertNumWithUnitsLength(in,outUnit,[rnd,space])
	// converts string like "2in" to "0.0508 m"
	// ConvertNumWithUnitsLength("2 in","cm") --> "5.08 cm"
	// if you know the units and just want to conver a number, use ConvertUnits2meters()
	String in				// input string e.g. "2 in" or "1nm^-2"...
	String outUnit			// desired final unit, e.g. "cm" or "Angstrom^-2"
	Variable rnd			// if rnd True, use same number of places in final as input (default=False)
	Variable space			// flag, if True put space between number and unit (default=True)
	rnd = ParamIsDefault(rnd) ? NaN : rnd
	rnd = numtype(rnd) ? 0 : !(!rnd)
	space = ParamIsDefault(space) ? 1 : !(!space)

	String list = SplitNumAndUnits(in)
	Variable val = str2num(StringFromList(0,list))
	String inUnit = StringFromList(1,list)
	if (strlen(inUnit)<1 || numtype(val))
		return ""
	endif
	String powIn,powOut				// check that units have same power
	Variable i = strsearch(inUnit,"^",strlen(inUnit)-1,1)
	i = i<0 ? Inf : i
	powIn = inUnit[i,Inf]
	i = strsearch(outUnit,"^",strlen(outUnit)-1,1)
	i = i<0 ? Inf : i
	powOut = outUnit[i,Inf]
	if (cmpstr(powIn, powOut))
		return ""
	endif

	Variable places = rnd ? placesOfPrecision(val)+1 : 16
	places = limit(places,1,16)
	val *= ConvertUnits2meters(inUnit)/ConvertUnits2meters(outUnit)

	String out, sspace=SelectString(space,""," ")
	String fmt="%."+num2istr(places)+"g"+sspace+"%s"
	sprintf out, fmt,val,outUnit
	return out
End


Function/T SplitNumAndUnits(in)
	// take string such as "-9.3e2mi" --> "-9.3e2;mi",  or "2 nm^-1" --> "2;nm^-1"
	// this is useful with ConvertNumWithUnitsLength() above
	String in

	in = ReplaceString(" ",in,"")
	in = ReplaceString("\t",in,"")
	Variable i,N=strlen(in)
	i = strsearch(in,"^",N-1,1)-1
	i = i<0 ? N-1 : i
	for ( ;i>=0;i-=1)
		if (strsearch("01234567890.,",in[i],0)>=0)
			i += 1
			break
		endif
	endfor
	String unit = in[i,N-1]
	String num = in[0,i-1]
	num = RemoveEnding(num,".")
	num = RemoveEnding(num,",")
	return num+";"+unit
End


ThreadSafe Function ConvertTemperatureUnits(Tin,unitIn,unitOut)	// returns Temperature in units of (unitOut)
	// ConvertTemperatureUnits(400,"K","F") --> "260.33"
	// work for Celsius, Kelvin, Fahrenheit, Rankine, & Plank units
	// for Plank Temperature, see: http://en.wikipedia.org/wiki/Planck_temperature
	String unitIn, unitOut			// input and output units, NO defaults allowed
	Variable Tin						// input temperature in units of (unitIn)

	unitIn = ReplaceString("Temperature",unitIn,"")
	unitOut = ReplaceString("Temperature",unitOut,"")
	unitIn = ReplaceString("Temp",unitIn,"")
	unitOut = ReplaceString("Temp",unitOut,"")

	unitIn = ReplaceString("Kelvin",unitIn,"K")// use single letter abreviations
	unitOut = ReplaceString("Kelvin",unitOut,"K")
	unitIn = ReplaceString("Celsius",unitIn,"C")
	unitOut = ReplaceString("Celsius",unitOut,"C")
	unitIn = ReplaceString("Fahrenheit",unitIn,"F")
	unitOut = ReplaceString("Fahrenheit",unitOut,"F")
	unitIn = ReplaceString("Rankine",unitIn,"R")
	unitOut = ReplaceString("Rankine",unitOut,"R")
	unitIn = ReplaceString("Plank",unitIn,"P")// Plank Temperature
	unitOut = ReplaceString("Plank",unitOut,"P")

	unitIn = ReplaceString(" ",unitIn,"")			// no spaces
	unitIn = ReplaceString("¡",unitIn,"")			// no degree signs
	unitIn = RemoveEnding(unitIn,"s")				// and no trailing 's'

	unitOut = ReplaceString(" ",unitOut,"")		// no spaces
	unitOut = ReplaceString("¡",unitOut,"")		// no degree signs
	unitOut = RemoveEnding(unitOut,"s")			// and no trailing 's'

	if (strlen(unitIn)<1 || strlen(unitOut)<1)
		return NaN
	endif

	Variable T_Plank = 1.416833e32					// Plank Temperature (K)
	Variable Tout, Kelvin, n
	if (strlen(unitIn)>1)
		n = strlen(unitIn)
		Tin *= SIprefix2factor(unitIn[0,n-2])
		unitIn = unitIn[n-1]							// the last character
	endif
	strswitch(unitIn)										// first convert Tin to Kelvin
		case "F":
			Kelvin = (Tin - 32) * 5/9 + 273.15
			break
		case "R":
			Kelvin = Tin * 5/9
			break
		case "C":
			Kelvin = Tin + 273.15
			break
		case "K":
			Kelvin = Tin
			break
		case "P":
			Kelvin = Tin / T_Plank
			break
		default:
			return NaN
		endswitch

	Variable factor=1
	if (strlen(unitOut)>1)
		n = strlen(unitOut)
		factor = SIprefix2factor(unitOut[0,n-2])
		unitOut = unitOut[n-1]							// the last character
	endif
	strswitch(unitOut)									// convert Kelvin to unitOut
		case "F":
			Tout = (Kelvin-273.15)*9/5 + 32
			break
		case "R":
			Tout = Kelvin * 9/5
			break
		case "C":
			Tout = Kelvin - 273.15
			break
		case "K":
			Tout = Kelvin
			break
		case "P":
			Tout = Kelvin / T_Plank
			break
		default:
			return NaN
		endswitch
	Tout /= factor

	return Tout
End


ThreadSafe Function/T RomanNumeral(j)	// convert integer j to a Roman Numeral String, NO upper limit, so watch out for string length
	Variable j

	String str = SelectString(j<0,"","-")		// start str with the sign
	j = round(abs(j))

	if (j<1 || numtype(j))					// retrns "" for zero, ±Inf, NaN
		str = ""
	elseif (j>=1000)
		str += "M"+RomanNumeral(j-1000)	// add an M & remove 1000
	elseif (j>=900)
		str += "CM"+RomanNumeral(j-900)	// add a CM & remove 900
	elseif (j>=500)
		str += "D"+RomanNumeral(j-500)	// add a D & remove 500
	elseif (j>=400)
		str += "CD"+RomanNumeral(j-400)	// add a CD & remove 400
	elseif (j>=100)
		str += "C"+RomanNumeral(j-100)	// add a C & remove 100
	elseif (j>=90)
		str += "XC"+RomanNumeral(j-90)	// add a XC & remove 90
	elseif (j>=50)
		str += "L"+RomanNumeral(j-50)	// add a L & remove 50
	elseif (j>=40)
		str += "XL"+RomanNumeral(j-40)	// add a XL & remove 40
	elseif (j>=10)
		str += "X"+RomanNumeral(j-10)	// add a X & remove 10
	elseif (j>=9)
		str += "IX"+RomanNumeral(j-9)	// add a IX & remove 9
	elseif (j>=5)
		str += "V"+RomanNumeral(j-5)		// add a V & remove 5
	elseif (j>=4)
		str += "IV"+RomanNumeral(j-4)	// add a IV & remove 4
	elseif (j>=1)
		str += "I"+RomanNumeral(j-1)		// add a I & remove 1
	endif
	return str
End


ThreadSafe Function RomanNumeral2Int(str)	// convert a Roman Numeral string to an integer
	String str
	if (strlen(str)<1)						// empty strings return NaN, there is no zero
		return NaN
	endif
	str = UpperStr(str )

	Variable iM=char2num("M"),iC=char2num("C"),iX=char2num("X"),iI=char2num("I")
	Variable j, isign=1
	if (char2num(str)==char2num("-"))
		str = str[1,Inf]						// strip off leading "-", and set isign to -1
		isign = -1
	endif

	for (;char2num(str[0])==iM;)			// fournd all leading "M", add 1000
		str = str[1,Inf]
		j += 1000
	endfor

	if (strsearch(str,"CM",0)==0)		// fournd a leading "CM", add 900
		str = str[2,Inf]
		j += 900
	endif
	if (strsearch(str,"D",0)==0)			// fournd a leading "D", add 500
		str = str[1,Inf]
		j += 500
	endif
	if (strsearch(str,"CD",0)==0)		// fournd a leading "CD", add 400
		str = str[2,Inf]
		j += 400
	endif
	for (;char2num(str[0])==iC;)			// fournd all leading "C", add 100
		str = str[1,Inf]
		j += 100
	endfor

	if (strsearch(str,"XC",0)==0)		// fournd a leading "XC", add 90
		str = str[2,Inf]
		j += 90
	endif
	if (strsearch(str,"L",0)==0)			// fournd a leading "L", add 50
		str = str[1,Inf]
		j += 50
	endif
	if (strsearch(str,"XL",0)==0)		// fournd a leading "XL", add 40
		str = str[2,Inf]
		j += 40
	endif
	for (;char2num(str[0])==iX;)			// fournd all leading "X", add 10
		str = str[1,Inf]
		j += 10
	endfor

	if (strsearch(str,"IX",0)==0)		// fournd a leading "IX", add 9
		str = str[2,Inf]
		j += 9
	endif
	if (strsearch(str,"V",0)==0)			// fournd a leading "V", add 5
		str = str[1,Inf]
		j += 5
	endif
	if (strsearch(str,"IV",0)==0)		// fournd a leading "IV", add 4
		str = str[2,Inf]
		j += 4
	endif
	for (;char2num(str[0])==iI;)			// fournd all leading "I", add 1
		str = str[1,Inf]
		j += 1
	endfor

	j = strlen(str) ? NaN : j*isign		// check that str is all used up & fix sign
	return j
End

//  ======================= End of some general utility functions ========================  //
//  ======================================================================================  //


Function init_UtiltyJZT()
	if (DataFolderExists("root:Packages:UtilityJZT"))
		return 0
	endif
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:UtilityJZT

	if (exists("root:Packages:UtilityJZT:markerIndex")!=2)
		Variable/G root:Packages:UtilityJZT:markerIndex = 0
	endif
	return 0
End



//  ======================================================================================  //
//  ======================== Start of legacy deprecated functions ========================  //

// use new ISOtime2IgorEpoch(iso, NOTZ=1) instead
//ThreadSafe Function ISOtime2IgorEpoch(iso)	// convert ISO8601 string to an Igor Epoch (error returns NaN)
//	String iso									// format     2013-10-02T01:22:35  (the seconds are optional)
//
//	Variable year=NaN,month=NaN,day=NaN, hr=NaN,mn=NaN,se=NaN
//	sscanf iso,"%4d-%2d-%2dT%2d:%2d:%2d", year,month,day,hr,mn,se
//	Variable N=V_flag
//
//	if (N<3 || numtype(year+month+day))
//		return NaN
//	endif
//	Variable epoch=date2secs(year, month, day )
//	if (N>=5)
//		epoch += hr*3600
//		epoch += mn*60
//		se = (N>=6) ? se : 0
//		epoch += se
//	endif
//	return epoch
//End


Function/S CornerStamp1_()		// ONLY for backwards compatibility, DEPRECATED, use JZTutil#CornerStampWindow()
	PathInfo home
	return S_path+IgorInfo(1)
End

Static Function isWaveOnGraph(w,win)				// DEPRECATED use CheckDisplayed directly
	Wave w
	String win
	CheckDisplayed/W=$win w
	return (V_flag>0)
End
//Function isWaveOnGraph(w,win)
//	Wave w
//	String win
//	if (!WaveExists(w))
//		return 0
//	endif
//	String name, name0=GetWavesDataFolder(w,2)
//	String ilist
//	Variable i,Ni
//		ilist = ImageNameList(win,";")		// list of images in this window
//		Ni = ItemsInList(ilist)
//		if (strsearch(win,"#",0)<0)
//			for (i=0;;i+=1)					// first check for graphs (x or y trace)
//				Wave wi = WaveRefIndexed(win,i,3)
//				if (!WaveExists(wi))
//					break
//				endif
//				if (stringmatch(GetWavesDataFolder(wi,2),name0))
//					return 1
//				endif
//			endfor
//		endif
//		for (i=0;i<ItemsInList(ilist);i+=1)// next check all the images
//			name = GetWavesDataFolder(ImageNameToWaveRef(win,StringFromList(i,ilist)),2)
//			if (stringmatch(name,name0))
//				return 1
//			endif
//		endfor
//	return 0
//End

ThreadSafe Function compareWaves(a,b)		// DEPRECATED,  just use EqualWaves(a,b,1)
	WAVE a,b
	return EqualWaves(a,b,1)
End
//ThreadSafe Function compareWaves(a,b)
//	WAVE a,b
//	Variable n=numpnts(a)
//	Variable i
//	if (n!=numpnts(b))
//		return 0
//	endif
//	for (i=0;i<n;i+=1)
//		if (numtype(a[i]))
//			if (numtype(a[i])!=numtype(b[i]))
//				return 0
//			endif
//		elseif (a[i]!=b[i])
//			return 0
//		endif
//	endfor
//	return 1
//End


// do not use num2sexigesmal() anymore, for new code use Secs2Time() directly.
ThreadSafe Function/S num2sexigesmal(seconds,places)	// convert seconds into a hh:mm:ss.sss   string
	Variable seconds
	Variable places
	return Secs2Time(seconds,5,places)
End


// DO NOT use this anymore.  In your code, do the test directly with:
//
//	if (strlen(GetRTStackInfo(2))<1)	// do this if this routine is at top level
//		// code goes here
//	endif
//
//
// returns 1 if the  calling function was invoked from a  menu item or command line (otherwise 0)
Function topOfStack()
	return strlen(GetRTStackInfo(2))<1
End

//Function abc()
//	String cmd, pathStr="\\\"/Users/tischler/data/Sector 34/July 4, 2006/EW5/recon/\\\""
//	print PathStr
//	sprintf cmd, "do shell script \"ls %s\"",pathStr
//	ExecuteScriptText cmd
//	print cmd
//	print S_value[0,72]
//End

//  ========================= End of legacy deprecated functions =========================  //
//  ======================================================================================  //
