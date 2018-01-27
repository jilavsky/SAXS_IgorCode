#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.46
#pragma ModuleName=ImageDisplayScaling
// Routines for rescaling the color table for images, by Jon Tischler, Oak Ridge National Lab
// TischlerJZ@ornl.gov
//
// to use these macros in your Igor experiment, put this file in the "User Procedures" folder
// in the "Igor Pro Folder", and uncomment the following line and put it in the top of the procedure
//folder
//
//#include "ImageDisplayScaling"

Menu "Graph"
	MenuItemIfTopGraphImage("Set Aspect Ratio to Get Square Pixels"),SetAspectToSquarePixels("")
End

Menu "GraphMarquee", dynamic
	"-"
	MarqueeImageMenuItem("5%-95% scaling"),/Q, fivePercentScaling()
	help={"reset the z scaling of the image based on pixel range of this marquee, excluding the top and bottom 5%"}
	MarqueeImageMenuItem("full range scaling"),/Q, fullRangeScaling("")
	help={"reset the z scaling of the image based on pixel range of this marquee"}
	MarqueeImageMenuItem("Statistics"),/Q,statsOfROI()
	help={"write to the history some statistics about the pixels within this marquee"}
	"Make Marquee Match Plot Aspect",/Q,MatchMarqueeAspect()
	help={"resize this marquee so that its aspect ration matches that of the plot, used before an expand or shrink"}
End
//
Function/S MarqueeImageMenuItem(item)
	String item
	if (strlen(ImageNameList("",";"))<1)
		return "("+item
	endif
	return item
End
//
Function/S MenuItemIfWaveClassExists(item,classes,options)
	String item
	String classes
	String options
	String list = NI1_WaveListClass(classes,"*",options)
//	String list = WaveListClass(classes,"*","DIMS:2")
	return SelectString(strlen(list),"(","")+item
End
//Menu "GraphMarquee"
//	"-"
//	"5%-95% scaling",/Q,fivePercentScaling()	
//	help={"reset the z scaling of the image based on pixel range of this marquee, excluding the top and bottom 5%"}
//	"full range scaling",/Q,fullRangeScaling()
//	help={"reset the z scaling of the image based on pixel range of this marquee"}
//	"Statistics",/Q,statsOfROI()
//	help={"write to the history some statistics about the pixels within this marquee"}
//	"Make Marquee Match Plot Aspect",/Q,MatchMarqueeAspect()
//	help={"resize this marquee so that its aspect ration matches that of the plot, used before an expand or shrink"}
//End

Function/S MenuItemIfTopGraphImage(item)
	String item
	if (strlen(ImageNameList("",""))<1)
		return "("+item					// top graph does not contain an image, so disable menu item
	endif
	return item
End


// for menus, enable menu item when a particular wave class is present on the graphName
Function/S MenuItemsWaveClassOnGraph(item,classes,graphName)
	String item					// item name to return, or "(item" to disable
	String classes					// list of classes to check for (semi-colon separated)
	String graphName				// name of graph, use "" for top graph

	Variable i
	String list = imageNameList("",";")	// first check the images
	for (i=0;i<ItemsInList(list);i+=1)
		Wave ww = ImageNameToWaveRef(graphName, StringFromList(i,list))
		if (NI1_WaveInClass(ww,classes))
			return item
		endif
	endfor

	list = TraceNameList("",";",3)		// second check ordinary traces and contours
	for (i=0;i<ItemsInList(list);i+=1)
		Wave ww = TraceNameToWaveRef(graphName, StringFromList(i,list))
		if (NI1_WaveInClass(ww,classes))
			return item
		endif
	endfor
	return "("+item						// top graph does not contain a wave of desired class
End



Function SetAspectToSquarePixels(gName)	// set the aspect ratio of a graph so that the pixels are square, returns the aspect ratio
	String gName													// name of the graph, use "" for the top graph

	Variable printIt = (ItemsInList(GetRTStackInfo(0))<2)
	if (strlen(gName)<1)
		gName = StringFromList(0,WinList("*",";","WIN:1"))
//		gName = StringFromList(0,ImageNameList(gName,""))
	endif
	if (WinType(gName)!=1)
		if (printIt)
			DoAlert 0, "ERROR, in SetAspectToSquarePixels(), '"+gName+"' is not an image"
		endif
		return NaN												// if no image on graph, do not try to set aspect ratio
	endif
	GetAxis/Q/W=$gName left
	Variable height = abs(V_max-V_min)
	if (V_flag)													// if no left, use the right
		GetAxis/Q/W=$gName right
		if (V_flag)
			if (printIt)
				DoAlert 0, "ERROR, SetAspectToSquarePixels(), unable to get size of vertical axis"
			endif
			return NaN
		endif
		height = abs(V_max-V_min)
	endif
	GetAxis/Q/W=$gName bottom
	Variable aspectRatio = height/abs(V_max-V_min)			// height / width
	if (V_flag)													// if no bottom, use the top
		GetAxis/Q/W=$gName top
		if (V_flag)
			if (printIt)
				DoAlert 0, "ERROR, SetAspectToSquarePixels(), unable to get size of horizontal axis"
			endif
			return NaN
		endif
		 aspectRatio = height/abs(V_max-V_min)
	endif
	if (!(aspectRatio>0 && aspectRatio<Inf))					// valid aspect ratios are in range (0, Inf)
		return NaN
	endif
	if (aspectRatio<1)
		ModifyGraph/W=$gName height={Aspect,aspectRatio}, width=0
	else
		ModifyGraph/W=$gName width={Aspect,1/aspectRatio}, height=0
	endif
	return aspectRatio
End
//Function SetAspectToSquarePixels()							// set the aspect ratio of a graph so that the pixels are square, returns the aspect ratio
//	if (strlen(ImageNameList("",""))<1)
//		return NaN												// if no image on graph, do not try to set aspect ratio
//	endif
//	GetAxis/Q left
//	Variable height = abs(V_max-V_min)
//	if (V_flag)													// if no left, use the right
//		GetAxis/Q right
//		height = abs(V_max-V_min)
//	endif
//	GetAxis/Q bottom
//	Variable aspectRatio = height/abs(V_max-V_min)			// height / width
//	if (V_flag)													// if no bottom, use the top
//		GetAxis/Q top
//		 aspectRatio = height/abs(V_max-V_min)
//	endif
//	if (!(aspectRatio>0 && aspectRatio<Inf))					// valid aspect ratios are in range (0, Inf)
//		return NaN
//	endif
//	if (aspectRatio<1)
//		ModifyGraph height={Aspect,aspectRatio}, width=0
//	else
//		ModifyGraph width={Aspect,1/aspectRatio}, height=0
//	endif
//	return aspectRatio
//End




Structure box
	Variable xlo,xhi, ylo,yhi		// edges of a box
EndStructure

Function fivePercentScaling()
	// change range of current color table to span [5%-95%] of the values in the marquee
	String imageName = StringFromList(0,ImageNameList("",";"))
	Wave image = ImageNameToWaveRef("",imageName)

	STRUCT box b
	if (pointRangeOfMarquee("",imageName,b))
		return 1
	endif

	String wName = UniqueName("roi",1,0)
	Make/N=(DimSize(image,0),DimSize(image,1))/B/U $wName
	Wave roi = $wName
	roi = 1
	roi[b.xlo,b.xhi][b.ylo,b.yhi] = 0

	ImageHistogram/R=roi/I image
	Wave W_ImageHist=W_ImageHist
	Integrate W_ImageHist
	Variable nn = W_ImageHist[Inf]
	W_ImageHist /= nn
	Variable lo, hi
	lo = BinarySearchInterp(W_ImageHist,0.05)
	hi = BinarySearchInterp(W_ImageHist,0.95)
	lo = (numtype(lo)==2) ?0 : lo
	hi = (numtype(lo)==2) ? numpnts(hist)-1 : hi
	lo = pnt2x(W_ImageHist,lo)
	hi = pnt2x(W_ImageHist,hi)

	ModifyOnly_ctab_range("",imageName,lo,hi)
	KillWaves/Z W_ImageHist, roi
End

// change range of current color table to exactly span the range of values in the marquee
Function fullRangeScaling(gName)
	String gName				// graph name, use "" for the top graph
	String imageName = StringFromList(0,ImageNameList(gName,";"))
	Wave image = ImageNameToWaveRef(gName,imageName)

	Variable lo,hi
	String color = get_ctab_range(gName,imageName,lo,hi)
	Variable sym = WhichListItem(color,"RedWhiteBlue;RedWhiteBlue256;BlueRedGreen;RedWhiteGreen")>=0 && -lo==hi	// a symmtric scaling, preserve symmetry

	STRUCT box b
	if (pointRangeOfMarquee("",imageName,b)==0)
		ImageStats/M=1/G={b.xlo,b.xhi,b.ylo,b.yhi} image
	else
		ImageStats/M=1 image
	endif
	lo = V_min  ;  hi = V_max
	if (sym)
		hi = max(abs(V_min),abs(V_max))
		lo = -hi
	endif
	ModifyOnly_ctab_range(gName,imageName,lo,hi)
End

Function/T statsOfROI()		// print out the statics of a Marquee
	String imageName = StringFromList(0,ImageNameList("",";"))
	Wave image = ImageNameToWaveRef("",imageName)
	STRUCT box b
	if (pointRangeOfMarquee("",imageName,b))
		return ""
	endif
	if (pointRangeOfMarquee("",imageName,b)==0)
		ImageStats/G={b.xlo,b.xhi,b.ylo,b.yhi} image
	else
		ImageStats image
	endif
	Variable saturated=0, type = NumberByKey("NUMTYPE",WaveInfo(image,0))
	saturated = (type==80) ? 65535 : saturated		// unsigned 16 bit int
	saturated = (type==16) ? 32767 : saturated		// signed 16 bit int
	saturated = (type==74) ? 255 : saturated			// unsigned 8 bit int
	saturated = (type==8) ? 127 : saturated			// signed 8 bit int
	if (saturated)
		String wName = UniqueName("mat",1,0)
		Variable i0=b.xlo,i1=b.xhi,j0=b.ylo,j1=b.yhi
		Make/N=(i1-i0+1,j1-j0+1)/B $wName
		Wave roi=$wName
		roi = image[p+i0][q+j0]>=saturated
		saturated = sum(roi)
		KillWaves/Z roi
	endif

	if (ItemsInList(GetRTStackInfo(0))<2)
		Variable N=(b.xhi-b.xlo+1)*(b.yhi-b.ylo+1)
		printf "for  '%s'[%d,%d][%d,%d]\r",imageName,b.xlo,b.xhi,b.ylo,b.yhi
		printf "	min at [%d,%d] = %g,   max at [%d,%d] = %g\r",V_minRowLoc,V_minColLoc,V_min,V_maxRowLoc,V_maxColLoc,V_max
		printf "	avg = %g, with an std dev = %g,   and an avg deviation = %g\r",V_avg,V_sdev,V_adev
		if (N==V_npnts)
			printf "	All %d points are valid, with an rms = %g\r",V_npnts,V_rms
		else
			printf "	There are %d valid points (out of %d), with an rms = %g\r",V_npnts,N,V_rms
		endif
		if (saturated)
			printf "	There are %d saturated pixels\r",saturated
		endif
	endif
	String str=""
	str = ReplaceNumberByKey("V_adev",str,V_adev,"=")
	str = ReplaceNumberByKey("V_avg",str,V_avg,"=")
	str = ReplaceNumberByKey("V_kurt",str,V_kurt,"=")
	str = ReplaceNumberByKey("V_min",str,V_min,"=")
	str = ReplaceNumberByKey("V_minColLoc",str,V_minColLoc,"=")
	str = ReplaceNumberByKey("V_minRowLoc",str,V_minRowLoc,"=")
	str = ReplaceNumberByKey("V_max",str,V_max,"=")
	str = ReplaceNumberByKey("V_maxColLoc",str,V_maxColLoc,"=")
	str = ReplaceNumberByKey("V_maxRowLoc",str,V_maxRowLoc,"=")
	str = ReplaceNumberByKey("V_npnts",str,V_npnts,"=")
	str = ReplaceNumberByKey("V_rms",str,V_rms,"=")
	str = ReplaceNumberByKey("V_sdev",str,V_sdev,"=")
	str = ReplaceNumberByKey("V_skew",str,V_skew,"=")
	str = ReplaceNumberByKey("N_saturated",str,saturated,"=")
	return str
End
//Function/T statsOfROI()		// print out the statics of a Marquee
//	String imageName = StringFromList(0,ImageNameList("",";"))
//	Wave image = ImageNameToWaveRef("",imageName)
//	STRUCT box b
//	if (pointRangeOfMarquee("",imageName,b))
//		return ""
//	endif
//	if (pointRangeOfMarquee("",imageName,b)==0)
//		ImageStats/G={b.xlo,b.xhi,b.ylo,b.yhi} image
//	else
//		ImageStats image
//	endif
//
//	if (ItemsInList(GetRTStackInfo(0))<2)
//		Variable N=(b.xhi-b.xlo+1)*(b.yhi-b.ylo+1)
//		printf "for  '%s'[%d,%d][%d,%d]\r",imageName,b.xlo,b.xhi,b.ylo,b.yhi
//		printf "	min at [%d,%d] = %g,   max at [%d,%d] = %g\r",V_minRowLoc,V_minColLoc,V_min,V_maxRowLoc,V_maxColLoc,V_max
//		printf "	avg = %g, with an std dev = %g,   and an avg deviation = %g\r",V_avg,V_sdev,V_adev
//		if (N==V_npnts)
//			printf "	All %d points are valid, with an rms = %g\r",V_npnts,V_rms
//		else
//			printf "	There are %d valid points (out of %d), with an rms = %g\r",V_npnts,N,V_rms
//		endif
//	endif
//	String str=""
//	str = ReplaceNumberByKey("V_adev",str,V_adev,"=")
//	str = ReplaceNumberByKey("V_avg",str,V_avg,"=")
//	str = ReplaceNumberByKey("V_kurt",str,V_kurt,"=")
//	str = ReplaceNumberByKey("V_min",str,V_min,"=")
//	str = ReplaceNumberByKey("V_minColLoc",str,V_minColLoc,"=")
//	str = ReplaceNumberByKey("V_minRowLoc",str,V_minRowLoc,"=")
//	str = ReplaceNumberByKey("V_max",str,V_max,"=")
//	str = ReplaceNumberByKey("V_maxColLoc",str,V_maxColLoc,"=")
//	str = ReplaceNumberByKey("V_maxRowLoc",str,V_maxRowLoc,"=")
//	str = ReplaceNumberByKey("V_npnts",str,V_npnts,"=")
//	str = ReplaceNumberByKey("V_rms",str,V_rms,"=")
//	str = ReplaceNumberByKey("V_sdev",str,V_sdev,"=")
//	str = ReplaceNumberByKey("V_skew",str,V_skew,"=")
//	return str
//End

Static Function ModifyOnly_ctab_range(gName,imageName,lo,hi)
	// modify the range of the current color table, does not change the color table, or reverse
	String gName				// optional graph name
	String imageName			// name of particular image on graph
	Variable lo,hi				// range of color table to set (if NaN, then use auto-scale)

	String infoStr = ImageInfo(gName,imageName,0)
	String ctab = StringByKey("ctab",StringByKey("RECREATION",infoStr),"=")
	String colorTable = StringFromList(2,ctab,",")
	Variable colorRev = str2num(StringFromList(3,ctab,","))

	if (numtype(lo) && !numtype(hi))
		ModifyImage/W=$gName $imageName ctab= {*,hi,$colorTable,colorRev}
	elseif (!numtype(lo) && numtype(hi))
		ModifyImage/W=$gName $imageName ctab= {lo,*,$colorTable,colorRev}
	elseif (numtype(lo) && numtype(hi))
		ModifyImage/W=$gName $imageName ctab= {*,*,$colorTable,colorRev}
	else
		ModifyImage/W=$gName $imageName ctab= {lo,hi,$colorTable,colorRev}
	endif
End

Function/T get_ctab_range(gName,imageName,lo,hi)
	// modify the range of the current color table, does not change the color table, or reverse
	String gName				// optional graph name
	String imageName			// name of particular image on graph
	Variable &lo,&hi			// range of color table to set
	String infoStr = ImageInfo(gName,imageName,0)
	String ctab = StringByKey("ctab",StringByKey("RECREATION",infoStr),"=")
	ctab = ctab[strsearch(ctab, "{",0)+1,Inf]
	lo = str2num(StringFromList(0,ctab,","))
	hi = str2num(StringFromList(1,ctab,","))
	return StringFromList(2,ctab,",")
End


Function MatchMarqueeAspect()
	// change the size of a marquee to match the aspect ratio of the plot (gives square pixels if you zoom)
	GetWindow kwTopWin psize
	Variable aspectPlot, aspectMarquee, add
	aspectPlot = (V_bottom-V_top) / (V_right-V_left)			// aspect > 1 --> tall skinny
	GetMarquee/Z
	aspectMarquee = (V_bottom-V_top) / (V_right-V_left)
	if (aspectMarquee > aspectPlot)								// make marquee wider, increase width symmetrically
		add = ((V_bottom-V_top)/aspectPlot+V_left-V_right)/2
		V_left -= add
		V_right += add
	else															// make marquee taller, increase height symmetrically
		add = (aspectPlot*(V_right-V_left)+V_top-V_bottom)/2
		V_top -= add
		V_bottom += add
	endif
	SetMarquee V_left,V_top,V_right,V_bottom
End
//Function MatchMarqueeAspect()
//	// change the size of a marquee to match the aspect ratio of the plot (gives square pixels if you zoom)
//	GetWindow kwTopWin psize
//	Variable aspectPlot = (V_bottom-V_top) / (V_right-V_left)		// aspect > 1 --> tall skinny
//	GetMarquee/Z
//	Variable aspectMarquee = (V_bottom-V_top) / (V_right-V_left)
//	if (aspectMarquee > aspectPlot)								// make marquee wider, change V_right
//		V_right = (V_bottom-V_top)/aspectPlot + V_left
//	else															// make marquee taller, change V_bottom
//		V_bottom = aspectPlot*(V_right-V_left) + V_top
//	endif
//	SetMarquee V_left,V_top,V_right,V_bottom
//End


Function pointRangeOfMarquee(gName,imageName,b)
	String gName
	String imageName
	STRUCT box &b

	Wave image = ImageNameToWaveRef(gName,imageName)
	String infoStr = ImageInfo("",imageName,0)
	GetMarquee/Z $StringByKey("YAXIS",infoStr), $StringByKey("XAXIS",infoStr)
	if (!V_flag)						// box not set, bad marquee
		b.xlo=NaN ; b.xhi=NaN ; b.ylo=NaN ; b.yhi=NaN
		return 1
	endif

	Variable Nx=DimSize(image,0), Ny=DimSize(image,1)
	V_left = round(V_left-DimOffset(image,0))/DimDelta(image,0)
	V_right = round((V_right-DimOffset(image,0))/DimDelta(image,0))
	V_top = round((V_top-DimOffset(image,1))/DimDelta(image,1))
	V_bottom = round((V_bottom-DimOffset(image,1))/DimDelta(image,1))
	V_left = limit(V_left,0,Nx-1)
	V_right = limit(V_right,0,Nx-1)
	V_top = limit(V_top,0,Ny-1)
	V_bottom = limit(V_bottom,0,Ny-1)

	b.xlo=min(V_left,V_right)		;	b.xhi=max(V_left,V_right)
	b.ylo=min(V_top,V_bottom)	;	b.yhi=max(V_top,V_bottom)
	return 0
End

