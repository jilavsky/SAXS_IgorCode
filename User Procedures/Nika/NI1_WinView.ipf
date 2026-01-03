#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method.

#pragma version=1.87
#pragma ModuleName=WinViewProc

static StrConstant ksControllerTypes = "new120 (TYPE II);old120 (TYPE I);ST130;ST121;ST138;DC131 (Pentamax);ST133 (MicroMAX/SpectroMAX);ST135 (GPIB);VICCD;ST116 (GPIB);OMA3 (GPIB);OMA4"


Function/S NI1_WinViewReadROI(fileName, i0, i1, j0, j1)
	string fileName 
	variable i0, i1, j0, j1 
	// fully qualified name of file to open (will not prompt)
	// pixel range of ROI (if i1 or j1<0 then use whole image)

	string wnote = NI1_WinViewReadHeader(fileName) 
	// wave note to add to file read in
	if(!strlen(wnote))
		return ""
	endif
	variable xdim  = NumberByKey("xdim", wnote, "=")
	variable ydim  = NumberByKey("ydim", wnote, "=")
	variable itype = NumberByKey("numType", wnote, "=")
	i1 = (i1 < 1) ? xdim - 1 : i1 // -1 flags use whole range
	j1 = (j1 < 1) ? ydim - 1 : j1

	string inWaveName = NI1_WinViewLoadROI(fileName, itype, xdim, i0, i1, j0, j1) 
	// name of ROI read in
	if(strlen(inWaveName) < 1)
		return "" // nothing read in
	endif

	//	String wName = OnlyFileName(fileName)				// rename image based on the file name
	string separator = SelectString(stringmatch(IgorInfo(2), "Macintosh"), "\\", ":")
	string wName     = ParseFilePath(3, fileName, separator, 0, 0)
	wName = CleanupName(wName, 0) // wave name based on the file name

	if(exists(wName)) // if wave already exists, create unique name
		wName = wName + "_"
		wName = UniqueName(wName, 1, 1)
	endif
	Rename $inWaveName, $wName
	WAVE image = $wName
	SetScale/P x, 0, 1, "pixel", image
	SetScale/P y, 0, 1, "pixel", image
	wnote = ReplaceStringByKey("waveClass", wnote, "speImage", "=")
	Note/K image, wnote
	//	if (strlen(wnote)>1)
	//		Note/K  image
	//		Note image, wnote
	//	endif
	return GetWavesDataFolder(image, 2)
End


Function/S NI1_WinViewReadHeader(fileName)
	string fileName 
	// fully qualified name of file to open (will not prompt)

	variable fid // file id (file is assumed already opened)
	Open/Z/M=".spe file"/R/T="????" fid as fileName // this acutally opens file
	if(V_flag)
		return "" // could not open file
	endif
	fileName = S_fileName
	FStatus fid
	if(V_logEOF < 4100)
		Close fid // file too short to be interpreted
		return ""
	endif

	NewDataFolder/O root:Packages
	Make/N=2104/U/B/O root:Packages:WinViewHeaderExtra // additional 4100-1996=2104 bytes, to reach start of image
	WAVE buffer = root:Packages:WinViewHeaderExtra

	STRUCT speHeader header // structure containing all of header
	FBinRead/B=3 fid, header // read header in one gulp
	FBinRead/B=0 fid, buffer
	Close fid
	// printf "in header, version = '%s'\r",header.version
	string/G root:Packages:WinViewHeaderStruct
	SVAR WinViewHeaderStruct = root:Packages:WinViewHeaderStruct
	StructPut/S/B=2 header, WinViewHeaderStruct

	string wnote = "" // wave note to add to file read in
	wnote = ReplaceStringByKey("imageFileName", wnote, ParseFilePath(0, fileName, ":", 1, 0), "=")
	wnote = ReplaceStringByKey("imageFilePath", wnote, ParseFilePath(1, fileName, ":", 1, 0), "=")
	string flatFile = "", bkgFile = ""
	flatFile = header.flatFile1
	if(strlen(flatFile) >= 60)
		flatFile += header.flatFile2
	endif

	bkgFile = header.bkgFile1
	if(strlen(bkgFile) >= 60)
		bkgFile += header.bkgFile2
	endif

	string str = UniqueName("userStrings", 1, 0) // change the header.userStrj into strings
	Make/T/N=5/O $str
	WAVE/T userString = $str
	userString[0] = header.userStr0
	userString[1] = header.userStr1
	userString[2] = header.userStr2
	userString[3] = header.userStr3
	userString[4] = header.userStr4
	if(header.bkgApplied)
		wnote   = ReplaceNumberByKey("bkgApplied", wnote, 1, "=")
		bkgFile = NI1_OnlyWinFileName(bkgFile)
		if(strlen(bkgFile) > 0)
			wnote = ReplaceStringByKey("bkgFile", wnote, bkgFile, "=")
		endif
	endif

	wnote = ReplaceStringByKey("num_Type", wnote, NI1_WinViewFileTypeString(header.datatype), "=")
	wnote = ReplaceNumberByKey("numType", wnote, header.datatype, "=")
	wnote = ReplaceNumberByKey("xdim", wnote, header.xdim, "=")       // x size of image in file
	wnote = ReplaceNumberByKey("ydim", wnote, header.ydim, "=")       // y size of image in file
	wnote = ReplaceNumberByKey("xDimDet", wnote, header.xDimDet, "=") // detector x dimension of chip
	wnote = ReplaceNumberByKey("yDimDet", wnote, header.yDimDet, "=") // detector y dimension of chip
	if(strlen(header.edate))
		wnote = ReplaceStringByKey("dateExposed", wnote, header.edate, "=") // date that exposure was taken
	endif
	if(header.ehour != 0 || header.eminute != 0)
		str   = num2istr(header.ehour) + ":" + num2istr(header.eminute)
		wnote = ReplaceStringByKey("timeExposed", wnote, str, "=") // time that exposure was taken
	endif

	if(header.flatFieldApplied) // a flat field was applied
		wnote    = ReplaceNumberByKey("flatFieldApplied", wnote, 1, "=")
		flatFile = NI1_OnlyWinFileName(flatFile)
		if(strlen(flatFile) > 0)
			wnote = ReplaceStringByKey("flatFile", wnote, bkgFile, "=")
		endif
	endif
	wnote = ReplaceNumberByKey("exposure", wnote, header.exposure, "=")            // exposure duration
	wnote = ReplaceNumberByKey("ADCrate", wnote, header.ADCrate, "=")
	wnote = ReplaceNumberByKey("ADCtype", wnote, header.ADCtype, "=")
	wnote = ReplaceNumberByKey("ADCresolution", wnote, header.ADCresolution, "=")
	wnote = ReplaceNumberByKey("geo_rotate", wnote, !!(header.geometric & 1), "=") // geometric 1==rotate, 2==reverse, 4==flip
	wnote = ReplaceNumberByKey("geo_reverse", wnote, !!(header.geometric & 2), "=")
	wnote = ReplaceNumberByKey("geo_flip", wnote, !!(header.geometric & 4), "=")

	variable i, j
	i     = header.controllerType - 1 // controller type
	wnote = AddListItem("controllerType=" + StringFromList(i, ksControllerTypes), wnote)

	header.NumROI = max(header.NumROI, 1) // zero means one
	if(header.NumROI > 1)
		Abort "this file contains multiple ROI's"
		wnote = ReplaceNumberByKey("NumROI", wnote, header.NumROI, "=")
	endif
	if(header.NumROI <= 1)
		wnote = ReplaceNumberByKey("startx", wnote, header.ROIinfo[0].startx, "=")
		wnote = ReplaceNumberByKey("endx", wnote, header.ROIinfo[0].endx, "=")
		wnote = ReplaceNumberByKey("groupx", wnote, header.ROIinfo[0].groupx, "=")
		wnote = ReplaceNumberByKey("starty", wnote, header.ROIinfo[0].starty, "=")
		wnote = ReplaceNumberByKey("endy", wnote, header.ROIinfo[0].endy, "=")
		wnote = ReplaceNumberByKey("groupy", wnote, header.ROIinfo[0].groupy, "=")
	else
		for(i = 0; i < header.NumROI; i += 1)
			str   = "_" + num2istr(i + 1)
			wnote = ReplaceNumberByKey("startx" + str, wnote, header.ROIinfo[i].startx, "=")
			wnote = ReplaceNumberByKey("endx" + str, wnote, header.ROIinfo[i].endx, "=")
			wnote = ReplaceNumberByKey("groupx" + str, wnote, header.ROIinfo[i].groupx, "=")
			wnote = ReplaceNumberByKey("starty" + str, wnote, header.ROIinfo[i].starty, "=")
			wnote = ReplaceNumberByKey("endy" + str, wnote, header.ROIinfo[i].endy, "=")
			wnote = ReplaceNumberByKey("groupy" + str, wnote, header.ROIinfo[i].groupy, "=")
		endfor
	endif

	string item
	for(j = 0; j < 5; j += 1) // go through each userString[j] and add to note
		str = userString[j]
		i   = strsearch(str, "VAL ", 0) // strip off the PV name, yum:userStringCalc1.SVAL
		if(!strsearch(userString[0], "yum:", 0) && i > 0) // special for microdiffraction on 33ID-E
			str = str[i + 4, Inf]
		endif
		for(item = StringFromList(0, str), i = 0; strlen(item); i += 1, item = StringFromList(i, str))
			wnote = AddListItem(item, wnote) // add each semicolon separated part of userString[j] to note
		endfor
	endfor
	KillWaves/Z userString

	// this section is special for PM500's,  if Y1 & Z1 present, then add H1 & F1 (ditto for Y2 & Z2)
	variable Y1, Z1, H1, F1, Y2, Z2, H2, F2
	Y1 = NumberByKey("Y1", wnote, "=")
	Z1 = NumberByKey("Z1", wnote, "=")
	H1 = NumberByKey("H1", wnote, "=")
	F1 = NumberByKey("F1", wnote, "=")
	Y2 = NumberByKey("Y2", wnote, "=")
	Z2 = NumberByKey("Z2", wnote, "=")
	H2 = NumberByKey("H2", wnote, "=")
	F2 = NumberByKey("F21", wnote, "=")
	variable cosTheta = NumVarOrDefault("root:Packages:geometry:cosThetaWire", cos(PI / 4))
	variable sinTheta = NumVarOrDefault("root:Packages:geometry:sinThetaWire", sin(PI / 4))
	if(numtype(Y1 + Z1) == 0 && numtype(H1) == 2 && numtype(F1) == 2) // Y1&Z1 exist, H1&F1 do not
		H1    = Y1 * sinTheta + Z1 * cosTheta
		F1    = -Y1 * cosTheta + Z1 * sinTheta
		wnote = ReplaceNumberByKey("H1", wnote, H1, "=")
		wnote = ReplaceNumberByKey("F1", wnote, F1, "=")
	endif
	if(numtype(Y2 + Z2) == 0 && numtype(H2) == 2 && numtype(F2) == 2) // Y2&Z2 exist, H2&F2 do not
		H2    = Y2 * sinTheta + Z2 * cosTheta
		F2    = -Y2 * cosTheta + Z2 * sinTheta
		wnote = ReplaceNumberByKey("H2", wnote, H2, "=")
		wnote = ReplaceNumberByKey("F2", wnote, F2, "=")
	endif
	//
	//	printf "for file '"+fileName+"'"
	//	if (header.bkgApplied && (strlen(bkgFile)>0))
	//		printf ",             background file = '%s'\r",  bkgFile
	//	else
	//		printf "\r"
	//	endif
	//	printf "xdim = %d      ydim = %d      ", header.xdim,header.ydim
	//	i = header.xdim * header.ydim
	//	printf "total length = %d x %d  = %d points\r", header.xdim,header.ydim,i
	//	print "number type is  '"+WinViewFileTypeString(header.datatype)+"'"
	return wnote
End

Function/S NI1_WinViewWriteHeader(fileName, header)
	string            fileName 
	STRUCT speHeader &header   
	// fully qualified name of file to open (will not prompt)
	// structure containing all of header

	variable fid // file id (file is assumed already opened)
	Open/M="new .spe file"/T="????" fid as fileName // this acutally opens file
	fileName = S_fileName
	if(strlen(fileName) < 1) // no file opened
		return ""
	endif
	FBinWrite/B=3 fid, header // writes structure part of header

	if(exists("root:PackagesWinViewHeaderExtra"))
		WAVE buffer = root:PackagesWinViewHeaderExtra
		FBinWrite/B=0 fid, buffer // writes 1100 more bytes of zero, to fill to 4100
	else
		string wName = UniqueName("buffer", 1, 0) // header is 1996 long, image starts at byte 4100
		Make/N=2104/U/B $wName // so need an additional 2104
		WAVE buffer = $wName
		buffer = 0
		FBinWrite/B=0 fid, buffer // writes 1100 more bytes of zero, to fill to 4100
		KillWaves/Z buffer
	endif
	Close fid
	return fileName
End

Structure speHeader // version 1.6 spe header
	uint16 dioden //     0
	int16 avgexp //     2
	int16 msecExpose //     4
	uint16 xDimDet //     6, Detector x dimension of chip
	int16 mode //     8
	float exposure //   10, exposure in seconds
	int16 asyavg //   14
	int16 asyseq //   16
	uint16 yDimDet //   18, Detector y dimension of chip
	char edate[10] //   20, DDMonYYYY, null terminated
	uint16 ehour //   30, experiment time hours
	uint16 eminute //   32, experiment time minutes
	int16 noscan //   34
	int16 fastacc //   36
	int16 esecond //   38, experiment time seconds
	int16 DetType //   40
	uint16 xdim //   42, actual # of pixels on x axis
	int16 stdiode //   44
	float nanox //   46
	float calibdio[10] //   50
	char fastfile[16] //   90
	int16 asynen // 106
	uint16 datatype // 108, image data type, 0=float, 1=long, 2=int, 3=uint
	float calibnan[10] // 110
	uint16 bkgApplied // 150, true if a background file was substracted
	int16 astdiode // 152
	uint16 minblk // 154
	uint16 numinblk // 156
	double calibpol[4] // 158
	uint16 ADCrate // 190, ADC rate
	uint16 ADCtype // 192, ADC type
	uint16 ADCresolution // 194, ADC resolution
	uint16 ADCbitAdjust // 196
	uint16 gain // 198
	char userStr0[80] // 200, experiment remarks
	char userStr1[80] // 280
	char userStr2[80] // 380
	char userStr3[80] // 440
	char userStr4[80] // 520
	uint16 geometric // 600, 1==rotate, 2==reverse, 4==flip
	char xlabel[16] // 602
	uint16 cleans // 618
	uint16 NumSkpPerCln // 620
	char califile[16] // 622
	char bkgdfile[16] // 638
	int16 srccmp // 654
	uint16 ydim // 656, actual # of pixels on y axis
	int16 scramble // 658
	int32 lexpos // 660, long exposure in millisec, used if exposure=-1
	int32 lnoscan // 664
	int32 lavgexp // 668
	char stripfil[16] // 672
	char version[16] // 688, version & date: 01.000 02/01/90"
	int16 controllerType // 704		1 = new 120 (Type II)
	//												2 = old120 (Type I)
	//												3 = ST130
	//												4 = ST121
	//												5 = ST138
	//												6 = DC131 (PentaMAX)
	//												7 = ST133 (MicroMAX/SpectroMAX)
	//												8 = ST135 (GPIB)
	//												9 = VICCD
	//												10 = ST116 (GPIB)
	//												11 = OMA3 (GPIB)
	//												12 = OMA4
	int16 flatFieldApplied // 706, set to 1 if flat field was applied
	double dummy10[100] //		uses up 800 bytes
	uint16 dummy11 //		uses up 2 bytes
	int16 NumROI // 1510
	STRUCT speROIinfoblk ROIinfo[10] // 1512
	char flatFile1[60] // 1652, 120 long, break into two parts
	char flatFile2[60]
	char bkgFile1[60] // 1752, 120 long, break into two parts
	char bkgFile2[60]
	char blemishFile1[60]
	char blemishFile2[60]
	float softwave_version
EndStructure
//
Structure speROIinfoblk // the ROIinfoblk used with version 1.6 spe header
	uint16 startx // left x start value
	uint16 endx // right x value.
	uint16 groupx // amount x is binned/grouped in hw
	uint16 starty // top y start value
	uint16 endy // bottom y value
	uint16 groupy // amount y is binned/grouped in hw
EndStructure
//
//
Function NI1_WinViewList2Header(list, header) 
	string            list   
	STRUCT speHeader &header 
	// take list of values (from wnote) put into header
	// list with the values used to fill header
	// structure containing all of header

	string WinViewHeaderStruct = StrVarOrDefault("root:Packages:WinViewHeaderStruct", "")
	StructGet/S/B=2 header, WinViewHeaderStruct

	header.version        = "2.5.12 Sept2002"
	header.exposure       = NumberByKey("exposure", list, "=")
	header.xDimDet        = NumberByKey("xDimDet", list, "=")
	header.yDimDet        = NumberByKey("yDimDet", list, "=")
	header.ehour          = str2num(StringByKey("timeExposed", list, "="))
	header.eminute        = str2num(StringFromList(1, StringByKey("timeExposed", list, "="), ":"))
	header.ehour          = header.ehour == 65535 ? 0 : header.ehour
	header.eminute        = header.eminute == 65535 ? 0 : header.eminute
	header.edate          = StringByKey("dateExposed", list, "=")
	header.xdim           = NumberByKey("xdim", list, "=")
	header.ydim           = NumberByKey("ydim", list, "=")
	header.geometric      = NumberByKey("geo_rotate", list, "=")
	header.geometric     += 2 * NumberByKey("geo_reverse", list, "=")
	header.geometric     += 4 * NumberByKey("geo_flip", list, "=")
	header.datatype       = NumberByKey("numType", list, "=")
	header.ADCrate        = NumberByKey("ADCrate", list, "=")
	header.ADCtype        = NumberByKey("ADCtype", list, "=")
	header.ADCresolution  = NumberByKey("ADCresolution", list, "=")
	header.controllerType = WhichListItem(StringByKey("controllerType", list, "="), ksControllerTypes) + 1

	variable c
	string bkgFile = StringByKey("bkgFile", list, "="), flatFile = StringByKey("flatFile", list, "=")
	header.bkgApplied = NumberByKey("bkgApplied", list, "=") == 1
	if(header.bkgApplied)
		header.bkgFile1 = bkgFile[0, 59]
		c               = char2num(bkgFile[60, 60])
		if(strlen(bkgFile) > 59)
			header.bkgFile1[59] = c
			header.bkgFile2     = bkgFile[61, 119]
		endif
	endif
	header.flatFieldApplied = NumberByKey("flatFieldApplied", list, "=") == 1
	if(header.flatFieldApplied)
		header.flatFile1 = flatFile[0, 59]
		c                = char2num(flatFile[60, 60])
		if(strlen(flatFile) > 59)
			header.flatFile1[59] = c
			header.flatFile2     = flatFile[61, 119]
		endif
	endif

	header.NumROI            = 1 // only implemented for one image
	header.ROIinfo[0].startx = NumberByKey("startx", list, "=")
	header.ROIinfo[0].endx   = NumberByKey("endx", list, "=")
	header.ROIinfo[0].groupx = NumberByKey("groupx", list, "=")
	header.ROIinfo[0].starty = NumberByKey("starty", list, "=")
	header.ROIinfo[0].endy   = NumberByKey("endy", list, "=")
	header.ROIinfo[0].groupy = NumberByKey("groupy", list, "=")

	string str
	str             = ReplaceStringByKey("X1", "", StringByKey("X1", list, "="), "=")
	str             = ReplaceStringByKey("Y1", str, StringByKey("Y1", list, "="), "=")
	str             = ReplaceStringByKey("Z1", str, StringByKey("Z1", list, "="), "=")
	header.userStr0 = str

	if(numtype(NumberByKey("X2", list, "=")) && !numtype(NumberByKey("depthSi", list, "=")))
		str = ReplaceStringByKey("yc", "", StringByKey("yc", list, "="), "=")
		str = ReplaceStringByKey("depthSi", str, StringByKey("depthSi", list, "="), "=")
		str = ReplaceStringByKey("depth0", str, StringByKey("depth0", list, "="), "=")
	else
		str = ReplaceStringByKey("X2", "", StringByKey("X2", list, "="), "=")
		str = ReplaceStringByKey("Y2", str, StringByKey("Y2", list, "="), "=")
		str = ReplaceStringByKey("Z2", str, StringByKey("Z2", list, "="), "=")
	endif
	header.userStr1 = str

	str             = ReplaceStringByKey("cnt1", "", StringByKey("cnt1", list, "="), "=")
	str             = ReplaceStringByKey("cnt2", str, StringByKey("cnt2", list, "="), "=")
	str             = ReplaceStringByKey("cnt3", str, StringByKey("cnt3", list, "="), "=")
	header.userStr2 = str

	str             = ReplaceStringByKey("taper", "", StringByKey("taper", list, "="), "=")
	str             = ReplaceStringByKey("keV", str, StringByKey("keV", list, "="), "=")
	str             = ReplaceStringByKey("x'", str, StringByKey("x'", list, "="), "=")
	header.userStr3 = str

	str             = ReplaceStringByKey("CCDy", "", StringByKey("CCDy", list, "="), "=")
	str             = ReplaceStringByKey("mA", str, StringByKey("mA", list, "="), "=")
	str             = ReplaceStringByKey("gap", str, StringByKey("gap", list, "="), "=")
	header.userStr4 = str
	return 0
End


Function/S NI1_WinViewLoadROI(fileName, itype, xdim, i0, i1, j0, j1)
	string   fileName 
	variable itype    
	variable xdim 
	variable i0, i1, j0, j1 
	// fully qualified name of file to open (will not prompt)
	// WinView file type
	//  0	"float (4 byte)"
	//  1	"long integer (4 byte)"
	//  2	"integer (2 byte)"
	//  3	"unsigned integer (2 byte)"
	//  4	"string/char (1 byte)"
	//  5	"double (8 byte)"
	//  6	"signed int8 (1 byte)"
	//  7	"unsigned int8 (1 byte)"
	// x size of whole array
	// pixel range of ROI
	// for whole image use 0,xdim,0,ydim
	if(!(itype >= 0) || !(xdim > 0)) // invalid values, so read them from file
		variable fid // file id
		Open/Z/M=".spe file"/R/T="????" fid as fileName // this acutally opens file
		if(V_flag)
			return "" // could not open file
		endif
		FStatus fid
		if(V_logEOF < 4100) // file is too short, do nothing
			Close fid
			return ""
		endif
		FSetPos fid, 42
		FBinRead/B=3/F=2/U fid, xdim // xdim is at byte 42
		FSetPos fid, 108
		FBinRead/B=3/F=2/U fid, itype // itype is at byte 108
		Close fid
	endif

	variable bytes = 1 // length of image nuber type in bytes
	switch(itype)
		case 5:
			bytes *= 2
		case 0:
		case 1:
			bytes *= 2
		case 2:
		case 3:
			bytes *= 2
	endswitch

	i0 = max(round(i0), 0)
	i1 = max(round(i1), 0)
	j0 = max(round(j0), 0)
	j1 = max(round(j1), 0)
	variable nx = i1 - i0 + 1
	variable ny = j1 - j0 + 1
	if(nx < 1 || ny < 1) // nothing to read
		return ""
	endif
	variable skip = 4100 + bytes * j0 * xdim // offset (bytes) to start of roi, 4100 is to start of image
	skip += ny == 1 ? bytes * i0 : 0
	//	if (ny==1)
	//		skip += bytes*i0
	//	endif
	variable fType = NI1_iType2fType(itype) // Igor number type
	string command
	if(ny > 1)
		sprintf command, "GBLoadWave/Q/B/T={%d,%d}/S=%d/W=1/U=%ld \"%s\"", fType, fType, skip, xdim * ny, fileName
	else
		sprintf command, "GBLoadWave/Q/B/T={%d,%d}/S=%d/W=1/U=%ld \"%s\"", fType, fType, skip, nx * ny, fileName
	endif
	command += " ; Variable/G WinView_Nwaves=V_flag"
	Execute command
	NVAR WinView_Nwaves = WinView_Nwaves
	if(WinView_Nwaves < 1)
		return "" // nothing loaded
	endif
	SVAR   S_waveNames = S_waveNames
	string wName       = S_waveNames[0, strsearch(S_waveNames, ";", 0) - 1]
	WAVE   wav         = $wName

	if(nx < xdim && ny > 1) // compress up in the x direction
		variable i
		variable next   = 0 // points to starting point in reduced array to store
		variable ystart = 0 // points to start of this y-value
		for(i = 0; i < ny; i += 1) // loop over each y-value of the array
			wav[next, next + nx - 1] = wav[p - next + ystart + i0] // move x range to next next point in array
			ystart += xdim; // points to start next y-value
			next += nx; // points to the next place in reduced array
		endfor
	endif

	Redimension/N=(nx, ny) wav
	return GetWavesDataFolder(wav, 2)
End

// return a list of waves in current folder having a "waveClass" that is a member of the list waveClassList
// The waveClassList, is a semicolon separated list, and the members can have wildcards. e.g. "speImage*"
// The class of a wave is given by a key=value pair in the wavenote:      "key1=val1;waveClass=class1,class2,class3;key5=val5;"
// This is similar to WaveList(), but with a finer selection
Function/S NI1_WaveListClass(waveClassList, search, options)
	string waveClassList 
	string search        
	string options   
	// a list of acceptable wave classes (semicolon separated)
	// same as first argument in WaveList()
	// same as last argument in WaveList()

	string in = WaveList(search, ";", options), out = ""
	string   name
	variable m
	for(m = 0, name = StringFromList(0, in); strlen(name); m += 1, name = StringFromList(m, in))
		if(NI1_WaveInClass($name, waveClassList))
			out += name + ";"
		endif
	endfor
	return out
End

// returns true if any one of the classes of ww matches one of the classes in waveClassList
// note that the items in waveClassList can have wild cards
Function NI1_WaveInClass(ww, waveClassList)
	WAVE   ww           
	string waveClassList 
 	// Wave to check
	// a list of acceptable wave classes (semicolon separated)
	if(!WaveExists(ww) || strlen(waveClassList) < 1)
		return 0
	endif
	string class = StringByKey("waveClass", note(ww), "=") // class list stored in wave note (comma separated)
	string wavClass, matchClass
	variable m, i
	for(m = 0; m < ItemsInList(waveClassList); m += 1) // check each item in waveClassList
		matchClass = StringFromList(m, waveClassList)
		for(i = 0; i < ItemsInList(class, ","); i += 1)
			wavClass = StringFromLIst(i, class, ",") // class item from the wave
			if(stringmatch(wavClass, matchClass)) // note that matchClass can have wild cards
				return 1
			endif
		endfor
	endfor
	return 0
End

Function NI1_WinViewInfo(image, key)
	WAVE   image
	string key

	string   imageName
	variable i
	if(!WaveExists(image))
		string item = ""
		Prompt imageName, "image to use", popup, NI1_WaveListClass("speImage*", "*", "DIMS:2")
		DoPrompt "pick an image", imageName
		if(V_flag)
			return NaN
		endif
		WAVE image = $imageName
	endif
	imageName = NameOfWave(image)
	if(!WaveExists(image))
		return NaN
	endif
	string list = note(image)
	//	 possibly extend list to include H and F (from Y and Z)
	variable Y, Z, H, F
	Y = NumberByKey("Y1", list, "=")
	Z = NumberByKey("Z1", list, "=")
	H = NumberByKey("H1", list, "=") // get H & F to test for their existance
	F = NumberByKey("F1", list, "=")
	if(!numtype(Y + Z) && numtype(H + F)) // if Y1 & Z1 exist, and H1 & F1 do not
		H    = (Z + Y) / sqrt(2)
		F    = (Z - Y) / sqrt(2)
		list = ReplaceNumberByKey("H1", list, H, "=")
		list = ReplaceNumberByKey("F1", list, F, "=")
	endif

	Y = NumberByKey("Y2", list, "=")
	Z = NumberByKey("Z2", list, "=")
	H = NumberByKey("H2", list, "=")
	F = NumberByKey("F2", list, "=")
	if(!numtype(Y + Z) && numtype(H + F)) // if Y2 & Z2 exist, and H2 & F2 do not
		H    = (Z + Y) / sqrt(2)
		F    = (Z - Y) / sqrt(2)
		list = ReplaceNumberByKey("H2", list, H, "=")
		list = ReplaceNumberByKey("F2", list, F, "=")
	endif

	if(strlen(key) > 1)
		item = StringByKey(key, list, "=")
		if(strlen(item) > 1 && numtype(str2num(item)))
			printf "for '%s',  %s = '%s'\r", imageName, key, item
		endif
	else
		Prompt item, "item", popup, list
		DoPrompt "info about " + imageName, item
		if(V_flag)
			return NaN
		endif
		key  = StringFromList(0, item, "=")
		item = StringFromList(1, item, "=")
		printf "for '%s',  %s = %s\r", imageName, key, item
	endif
	return str2num(item)
End


Function/S NI1_OnlyWinFileName(full)
	string full

	string name = full
	variable ii

	ii = -1
	do
		ii = strsearch(name, ":", 0) // remove the path part
		if(ii >= 0)
			name = name[ii + 1, Inf]
		endif
	while(ii > 0)

	ii = -1
	do
		ii = strsearch(name, "\\", 0) // remove the path part
		if(ii >= 0)
			name = name[ii + 1, Inf]
		endif
	while(ii >= 0)

	return name
End


Function/S NI1_WinViewFileTypeString(itype)
	variable itype

	string stype = ""
	if(itype == 0)
		stype = "float (4 byte)"
	endif
	if(itype == 1)
		stype = "long integer (4 byte)"
	endif
	if(itype == 2)
		stype = "integer (2 byte)"
	endif
	if(itype == 3)
		stype = "unsigned integer (2 byte)"
	endif
	if(itype == 4)
		stype = "string/char (1 byte)"
	endif
	if(itype == 5)
		stype = "double (8 byte)"
	endif
	if(itype == 6)
		stype = "signed int8 (1 byte)"
	endif
	if(itype == 7)
		stype = "unsigned int8 (1 byte)"
	endif
	if(strlen(stype) < 1)
		stype = "unknown number type"
	endif
	return stype
End

Function NI1_iType2fType(itype) 
	variable itype
	// converts winview number type to Igor number type

	//fType   in Igor
	//	2		single-precision floating point
	//	4		double-precision floating point
	//	32		32 bit signed integer
	//	16		16 bit signed integer
	//	8		8 bit signed integer
	//	32+64	32 bit signed integer
	//	16+64	16 bit signed integer
	//	8+64		8 bit signed integer
	//
	//
	//		for .spe itype==
	//  0	"float (4 byte)"
	//  1	"long integer (4 byte)"
	//  2	"integer (2 byte)"
	//  3	"unsigned integer (2 byte)"
	//  4	"string/char (1 byte)"
	//  5	"double (8 byte)"
	//  6	"signed int8 (1 byte)"
	//  7	"unsigned int8 (1 byte)"

	variable ftype = -1
	if(itype == 0)
		ftype = 2
	endif
	if(itype == 1)
		ftype = 32
	endif
	if(itype == 2)
		ftype = 16
	endif
	if(itype == 3)
		ftype = 16 + 64
	endif
	if(itype == 4)
		ftype = 8 + 64
	endif
	if(itype == 5)
		ftype = 4
	endif
	if(itype == 6)
		ftype = 8
	endif
	if(itype == 7)
		ftype = 8 + 64
	endif
	if(ftype < 0)
		DoAlert 0, "unknown number type"
	endif
	return ftype
End

Function NI1_igorType2WinView(itype) 
	variable itype 
	// convert Igor WaveType() to WinView number types
	// an igor number type from WaveType()
	switch(itype)
		case 0x02: // 4 byte float
			return 0
		case 0x04: // double (8 byte)
			return 5
		case 0x08: // signed int8 (1 byte)
			return 6
		case 0x10: // integer (2 byte)
			return 2
		case 0x20: // long integer (4 byte)
			return 1
		case 0x48: // unsigned int8 (1 byte)
			return 7
		case 0x50: // unsigned integer (2 byte)
			return 3
	endswitch
	return NaN // invalid wave type (complex, unsigned floats, unsigned long)
End

