#pragma rtGlobals=1.01		// Use modern global access method.
#pragma version=1.03

//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.03 attempted to fix problem with using x or right hand side - not acceptable for 6.30 and higher versions. 
//1.02 added return 0 for failed loads
//1.01 added license for ANL

//Menu "Load Waves"
//	"Load MAR345 Image", DoReadMAR345("", "") 
//	help = {"Load a MAR345 image plate file into the current datafolder"}
//End

Function DoReadMAR345(theFilename, inWaveName)
	String	theFilename
	String inWaveName
	
	Variable	marFile
	
	String		savedDF = GetDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:MAR345

  	if ( strlen(theFilename) == 0 )
		Open/D/T="????"/R/M="Select a MAR345 image" marFile
		if(strlen(S_filename)==0)
			abort
		endif
		theFilename = S_filename
	endif

	Open/R/Z marFile as theFilename
	switch(V_flag)
		case 0:
			// OK
			break
		case -1:
			// Cancel
			return	0
		default:	
			Abort "Error opening file " + theFilename + ": " + num2str(V_flag) + ".\rCheck the file name."
	endswitch
	
	Make/O/N=9	headerData
	
	SetDimLabel 0, 0, nx, headerData
	SetDimLabel 0, 1, ny, headerData
	SetDimLabel 0, 2, overflows, headerData
	SetDimLabel 0, 3, pixelx, headerData
	SetDimLabel 0, 4, pixely, headerData
	SetDimLabel 0, 5, wavelength, headerData
	SetDimLabel 0, 6, distance, headerData
	SetDimLabel 0, 7, phi, headerData
	SetDimLabel 0, 8, oscillationRange, headerData
		
	ReadMAR345_Header(marFile, headerData)
	ReadMAR345_Data(marFile, theFilename, headerData, savedDF, inWaveName)
	
	KillWaves headerData

	Close marFile
	
	SetDataFolder savedDF
End

Function ReadMAR345_Header(marFile, headerData)
	Variable	marFile
	Wave		headerData
	
	Make/O/I/N=16 rawHeader
	
	SetDimLabel 0, 0, BOM, rawHeader
	SetDimLabel 0, 1, nPixels, rawHeader
	SetDimLabel 0, 2, overflows, rawHeader
	
	SetDimLabel 0, 6, pixelx, rawHeader
	SetDimLabel 0, 7, pixely, rawHeader
	SetDimLabel 0, 8, wavelength, rawHeader
	SetDimLabel 0, 9, distance, rawHeader
	SetDimLabel 0, 10, phi1, rawHeader
	SetDimLabel 0, 11, phi2, rawHeader
	
	FBinRead/B=3/F=3 marFile, rawHeader

	if (rawHeader[%BOM] != 1234)
		// byte-order marker
		Abort "Badly formatted file."
	endif	
	
	// nx = ny 
	headerData[%nx] = rawHeader[%nPixels]
	headerData[%ny] = rawHeader[%nPixels]
	
	headerData[%overflows] = rawHeader[%overflows]
	
	// pixel size
	if (rawHeader[%pixelx] <= 0)
		rawHeader[%pixelx] = rawHeader[%pixely]
	endif
	if (rawHeader[%pixely] <= 0)
		rawHeader[%pixely] = rawHeader[%pixelx]
	endif
	headerData[%pixelx] = rawHeader[%pixelx] / 1e3
	headerData[%pixely] = rawHeader[%pixely] / 1e3
	
	headerData[%wavelength] = rawHeader[%wavelength] / 1e6
	headerData[%distance] = rawHeader[%distance] / 1e3
	headerData[%phi] = rawHeader[%phi1] / 1e3
	headerData[%oscillationRange] = (rawHeader[%phi2] - rawHeader[%phi1]) / 1e3
	
	KillWaves rawHeader
	
	// skip remainder of header
	FSetPos marFile, 4096

End

Function ReadMAR345_Data(marFile, theFilename, headerData, inDF, inWaveName)
	Variable	marFile
	String		theFilename
	Wave		headerData
	String		inDF
	String		inWaveName

	Make/O/I/N=(2*headerData[%overflows]) mar345overflow
	FBinRead/B=3/F=3 marFile, mar345overflow
	
	Variable nx, ny
	Variable PACK = 2
	do
		String	str
		FReadLine marFile, str
		sscanf str, "CCP4 packed image, X: %04d, Y: %04d", nx, ny
		if (V_flag == 2) 
			PACK = 1
			break
		endif
		sscanf str, "CCP4 packed image V%d, X: %04d, Y: %04d", PACK, nx, ny
		if (V_flag == 3) 
			break
		endif
	while (1)
	
	if (PACK > 1)
		KillWaves mar345	
		if (headerData[%overflows] > 0)
			KillWaves mar345overflow
		endif
		Abort "Bad image format"
	endif
	
	FStatus marFile
	Make/B/O/N=(V_logEOF - V_filePos) raw
	FBinRead/F=1 marFile, raw
	
	if (cmpstr(inWaveName, "") == 0)
		inWaveName = ParseFilePath(0, theFilename, ":", 1, 0)
	endif
	if (exists("ccp4unpack")==3)
		//Execute("ccp4unpack/O /V=mar345overflow nx, ny, raw as $(inDF + inWaveName)")
		Execute("ccp4unpack/O /V=mar345overflow nx, ny, raw as "+inDF + inWaveName)
	else
		Abort "XOP to read Mar data does not exist"
	endif
	//ccp4unpack/O /V=mar345overflow nx, ny, raw as $(inDF + inWaveName)
	
	KillWaves mar345overflow
	KillWaves raw
End


Function ReadMAR345_Data_NEWER(marFile, theFilename, headerData)
	Variable	marFile
	String		theFilename
	Wave		headerData

	Variable pixels = headerData[%nx] * headerData[%ny]
	
	Make/O/W/N=(pixels) $"TEST"
	Wave mar345 = $"TEST"
	
	if (headerData[%overflows] > 0)
		Make/O/I/N=(2*headerData[%overflows]) $("TEST_over")
		Wave mar345_over = $("TEST_over")
		FBinRead/B=3/F=3 marFile, mar345_over
	endif
	
	Variable nx, ny
	Variable PACK = 2
	do
		String	str
		FReadLine marFile, str
		sscanf str, "CCP4 packed image, X: %04d, Y: %04d", nx, ny
		if (V_flag == 2) 
			PACK = 1
			break
		endif
		sscanf str, "CCP4 packed image V%d, X: %04d, Y: %04d", PACK, nx, ny
		if (V_flag == 3) 
			break
		endif
	while (1)
	
	if (PACK > 1)
		KillWaves mar345	
		if (headerData[%overflows] > 0)
			KillWaves mar345_over
		endif
		Abort "Bad image format"
	endif
	
	Make/I/U/O/N=2 register
	SetDimLabel 0, 0, in, register
	SetDimLabel 0, 1, next, register

	register[%in] = 0
	Variable inCount = 0
	Variable get = 6
	Variable init = 1
	
	nx = headerData[%nx]
	
	Variable n = 0
	Variable nRaw = 0
	FStatus marFile
	Make/B/U/O/N=(V_logEOF - V_filePos) raw
	FBinRead/U/F=1 marFile, raw			
	
//	Make/I/U/O bitshift = {1,2,4,8,16,32,64,128,256,512,1024,2048}
	Make/I/U/O/N=32 bitshift = 2^x
	Make/B/U/O decode = { 0, 4, 5, 6, 7, 8, 16, 32 }
	
	Variable pixel
	for (pixel = 0; pixel < pixels;)
		register[%next] = 0
		Variable need = get
		for (;need;)
			if (inCount == 0)
//				FBinRead/U/F=1 marFile, in			
				register[%in] = raw[nRaw]
				nRaw += 1
				inCount = 8
			endif
			if (need > inCount)
//				next = next | (in * bitshift[get - need])
				register[%next] = register[%next] | shiftLeft(register[%in], get - need)
				need -= inCount
				register[%in] = 0
				inCount = 0
			else
//				next = next | ((in & (bitshift[need] - 1)) * bitshift[get - need])
//				in = (in / bitshift[need]) & 0xFF
				register[%next] = register[%next] | shiftLeft(register[%in] & (bitshift[need] - 1), get - need)
				register[%in] = shiftRight(register[%in], need) // & 0xFF
				inCount -= need
				break
			endif
		endfor
		
		Variable pixCount
		// Decode bits 0-5
		if (init)
			pixCount = bitshift[register[%next] & 7]
			get = decode[shiftRight(register[%next], 3) & 7]
			init = 0
		else
			// Decode a pixel

			// Sign-extend?

			if (get)
				register[%next] = register[%next] | -(register[%next] & bitshift[get - 1])
			endif		

//			if (get && next & bitshift[get - 1] != 0)
//				next -= bitshift[get]
//				next *= -1
//			endif		
			
			// Calculate the final pixel value
mar345[n] = register[%next] & 0x0FFFF

		if (0)
			if (pixel > nx)
				Variable A, B, C, D	
				
				A = mar345[n - 1 - nx]
				B = mar345[n     - nx]
				C = mar345[n + 1 - nx]
				D = mar345[n - 1     ]
				
//				Variable stuff = A + B + C + D
				Variable stuff = (A & 0x07FFF) + (B & 0x07FFF) + (C & 0x07FFF) + (D & 0x07FFF)
				stuff -= (A & 0x08000) + (B & 0x08000) + (C & 0x08000) + (D & 0x08000)
				mar345[n] = (register[%next] + (stuff + 2) / 4) & 0x0FFFF
			elseif (pixel)
				mar345[n] = mar345[n - 1] + register[%next] & 0x0FFFF
			else
				mar345[n] = register[%next] & 0x0FFFF
			endif
		endif
			
			pixel += 1
			n += 1
			pixCount -= 1
			
			// New set?
			if (pixCount == 0)
				init = 1
				get = 6
			endif
			
		endif
	
	endfor
	
	Redimension/N=(headerData[%nx],headerData[%ny]) mar345

End

Function ReadMAR345_Data_NEW(marFile, theFilename, headerData)
	Variable	marFile
	String		theFilename
	Wave		headerData

	Variable pixels = headerData[%nx] * headerData[%ny]
	
	Make/O/W/N=(pixels) $"TEST"
	Wave mar345 = $"TEST"
	
	if (headerData[%overflows] > 0)
		Make/O/I/N=(2*headerData[%overflows]) $("TEST_over")
		Wave mar345_over = $("TEST_over")
		FBinRead/B=3/F=3 marFile, mar345_over
	endif
	
	Variable nx, ny
	Variable PACK = 2
	do
		String	str
		FReadLine marFile, str
		sscanf str, "CCP4 packed image, X: %04d, Y: %04d", nx, ny
		if (V_flag == 2) 
			PACK = 1
			break
		endif
		sscanf str, "CCP4 packed image V%d, X: %04d, Y: %04d", PACK, nx, ny
		if (V_flag == 3) 
			break
		endif
	while (1)
	
	if (PACK > 1)
		KillWaves mar345	
		if (headerData[%overflows] > 0)
			KillWaves mar345_over
		endif
		Abort "Bad image format"
	endif
	
	nx = headerData[%nx]
	
	FStatus marFile
	Make/B/U/O/N=(V_logEOF - V_filePos) raw
	FBinRead/U/F=1 marFile, raw			
	
	Make/B/U/O bitshift = {1,2,4,8,16,32,64,128,256}
	Make/B/U/O decode = { 0, 4, 5, 6, 7, 8, 16, 32 }
	Make/I/O/N=33  setbits
	setbits[ 0] = 0x00000000
	setbits[ 1] = 0x00000001
	setbits[ 2] = 0x00000003
	setbits[ 3] = 0x00000007
	setbits[ 4] = 0x0000000F
	setbits[ 5] = 0x0000001F
	setbits[ 6] = 0x0000003F
	setbits[ 7] = 0x0000007F
	setbits[ 8] = 0x000000FF
	setbits[ 9] = 0x000001FF
	setbits[10] = 0x000003FF
	setbits[11] = 0x000007FF
	setbits[12] = 0x00000FFF
	setbits[13] = 0x00001FFF
	setbits[14] = 0x00003FFF
	setbits[15] = 0x00007FFF
	setbits[16] = 0x0000FFFF
	setbits[17] = 0x0001FFFF
	setbits[18] = 0x0003FFFF
	setbits[19] = 0x0007FFFF
	setbits[20] = 0x000FFFFF
	setbits[21] = 0x001FFFFF
	setbits[22] = 0x003FFFFF
	setbits[23] = 0x007FFFFF
	setbits[24] = 0x00FFFFFF
	setbits[25] = 0x01FFFFFF
	setbits[26] = 0x03FFFFFF
	setbits[27] = 0x07FFFFFF
	setbits[28] = 0x0FFFFFFF
	setbits[29] = 0x1FFFFFFF
	setbits[30] = 0x3FFFFFFF
	setbits[31] = 0x7FFFFFFF
	setbits[32] = 0xFFFFFFFF
	
	Variable	valids = 0
	Variable	spillbits = 0
	Variable	bitwindow = 0
	Variable	spill = 0
	Variable	nRaw = 0
	
	Variable pixel
	for (pixel = 0; pixel < pixels;)
		if (valids < 6)
			if (spillbits > 0)
				bitwindow = bitwindow | shiftLeft(spill, valids)
				valids += spillbits
				spillbits = 0
			else
				spill = raw[nRaw]
				nRaw += 1
				spillbits = 8
			endif
		else
			Variable	pixnum = bitshift[bitwindow & setbits[3]]
			Variable	bitnum
			
			bitwindow = shiftRight(bitwindow,3)
			bitnum = decode[bitwindow & setbits[3]]
			bitwindow = shiftRight(bitwindow,3)
			valids -= 6

			for (;(pixnum > 0) && (pixel < pixels);)
				if (valids < bitnum)
					if (spillbits > 0)
						bitwindow = bitwindow | shiftLeft(spill, valids)
						if ((32 - valids) > spillbits)
							valids += spillbits
							spillbits = 0
						else
							Variable	usedbits = 32 - valids
							spill = shiftRight(spill, usedbits)
							spillbits -= usedbits
							valids = 32
						endif
					else
						spill = raw[nRaw]
						nRaw += 1
						spillbits = 8
					endif
				else
					Variable	nextint
					
					pixnum -= 1
					if (bitnum == 0)
						nextint = 0
					else
						nextint = bitwindow & setbits[bitnum]
						valids -= bitnum
						bitwindow = shiftRight(bitwindow, bitnum)
						if ((nextint & bitshift[bitnum - 1]) != 0)
						// flip sign
//							nextint = nextint | ~setbits[bitnum]
							nextint -= bitshift[bitnum]
						endif
					endif
					if (pixel > nx)
						mar345[pixel] = nextint + (mar345[pixel-1] + mar345[pixel-nx+1] + mar345[pixel-nx] + mar345[pixel-nx-1] + 2) / 4
					elseif (pixel != 0)
						mar345[pixel] = mar345[pixel-1] + nextint
					else
						mar345[pixel] = nextint
					endif
					pixel += 1
				endif
			endfor
		endif
	endfor
	
	Redimension/N=(headerData[%nx],headerData[%ny]) mar345

End

Function shiftLeft(value, bits)
	Variable	value
	Variable	bits
	
	Wave	bitshift
	Wave	setbits
//	return (value & setbits[32 - bits]) * bitshift[bits]
	return (value * bitshift[bits]) & setbits[32 - bits]
End

Function shiftRight(value, bits)
	Variable	value
	Variable	bits
	
	Wave	bitshift
	Wave	setbits
//	return trunc(value / bitshift[bits]) & setbits[32 - bits]
	return trunc(value / bitshift[bits])
End



//*******************************************************************************************************

Function ReadMAR345UsingFit2D(FileNameToLoad, NewWaveName,FileType,PathName)
		string FileNameToLoad, NewWaveName, FileType, PathName
	
		NI1_GetFit2DLocation()

		string command
		string TempFileName
		string cmdDel
		string realName
		string FlnmToLoad
		variable success 
		//PathInfo igor
      if (stringmatch(IgorInfo(2),"Windows"))       // this section for Mac
		TempFileName=SpecialDirPath("Temporary", 0, 1, 0 )+"tempjunk:junk.tif"
		NewPath/C/O TempFilepath, SpecialDirPath("Temporary", 0, 1, 0 )+"tempjunk:"
 		command=NI1_WriteFit2DBatchFile(FileNameToLoad,FileType)
		command = ReplaceString("\\", command,"\\\\")
		string cmdf="ExecuteScriptText \"\\\""+command+"\\\"\""
		Execute(cmdf)
		variable refnum, timePassed, timeStart, i
		timeStart = ticks
		realName=StringFromList(ItemsInList(FileNameToLoad,":")-1,FileNameToLoad,":")
		FlnmToLoad=realName //RemoveEnding(removeEnding(realName,".mar2300"),".mar3450")
		pathinfo TempFilepath
		FileNameToLoad=IN2G_FixWindowsPathAsNeed(S_path,2, 1)+realName
		variable testLength=0
		Do
			GetFileFolderInfo/Z/Q/P=TempFilepath FlnmToLoad+".chi"	//modified to test for existence of second chi type file...
			if(testLength==V_logEOF && V_Flag==0)
				break
			endif
			timePassed = (ticks - timeStart)/60
			if(timePassed>60)
				abort "Fit2D data file not delivered in 60 seconds, something is wrong"
			endif
			testLength=V_logEOF
			sleep/s 0.2
		while(1)
		timePassed = (ticks - timeStart)/60
		print "waited for fit2d : "+num2str(timePassed)+" seconds"
		//ExecuteScriptText  "\"C:\\Program Files\\WaveMetrics\\Igor Pro Folder\\tempjunk\\RunFit2DBatch.bat\""
		//OK tiff file is now in temp junk folder...
		//now lets load it.
		success = NI1A_UniversalLoader("TempFilepath",FlnmToLoad,"tiff",NewWaveName)
		//DeleteFile /P=TempFilepath   RemoveEnding(removeEnding(realName,".mar2300"),".mar3450")+".tif"
		cmdDel="DeleteFile /P=TempFilepath   \""+FlnmToLoad+".tif\""
		execute/Q/P cmdDel
		cmdDel="DeleteFile /P=TempFilepath   \""+FlnmToLoad+".chi\""
		execute/Q/P cmdDel
	else		//Mac
		TempFileName=SpecialDirPath("Temporary", 0, 1, 0 )+"tempjunk/junk.tif"
		NewPath/C/O TempFilepath, SpecialDirPath("Temporary", 0, 0, 0 )+"tempjunk:"
  		command=NI1_WriteFit2DBatchFile(FileNameToLoad,FileType)
	       command = ReplaceString("\"",command,"\\\"")        // change spaces
             String cmd
             sprintf cmd, "do shell script \"%s\"", command
             print cmd
             ExecuteScriptText/Z cmd
		realName=StringFromList(ItemsInList(FileNameToLoad,":")-1,FileNameToLoad,":")
		FlnmToLoad=realName 

		success = NI1A_UniversalLoader(PathName,FlnmToLoad,"tiff",NewWaveName)
		//DeleteFile /P=TempFilepath   RemoveEnding(removeEnding(realName,".mar2300"),".mar3450")+".tif"
		cmdDel="DeleteFile /P="+PathName+"  \""+FlnmToLoad+".tif\""
		print  cmdDel
		execute/Q/P cmdDel
		cmdDel="DeleteFile /P="+PathName+"  \""+FlnmToLoad+".chi\""
		execute/Q/P cmdDel
	
	endif
	return success
end

Function/T NI1_WriteFit2DBatchFile(FileNameToLoad,FileType)
	string FileNameToLoad, FileType

	SVAR Fit2Dlocation=root:Packages:Convert2Dto1D:Fit2Dlocation
	string command, commandStart, ExecuteCmd, commandStart1
	string tempCommand, JunkFolderLocation, strTem1
	variable i

	
	string nb = "RunFit2DBatch"
	NewNotebook/V=1/N=$nb/F=0/V=1/K=0/W=(277.5,81.5,644.25,487.25) 
	Notebook $nb defaultTab=20, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb font="Arial", fSize=10, fStyle=0, textRGB=(0,0,0)

       if (stringmatch(IgorInfo(2),"Windows"))       // this section for Windows
		tempCommand=SpecialDirPath("Temporary", 0, 1, 0 )+"tempjunk\\"
		commandStart1 = "cd "+tempCommand
		commandStart="\""+	Fit2Dlocation+"\" "
		commandStart += "-dim8192x8192 -key -nographics -mac\""
		JunkFolderLocation=tempCommand
		ExecuteCmd = tempCommand+"RunFit2DBatch.bat"
		tempCommand+="Fit2DNika.mac"
		command = commandStart+"Fit2DNika.mac"+"\""
	
		command = ReplaceString("\\\\", command, "\\" )

		Notebook $nb text=commandStart1+"\r"						//change dir
		Notebook $nb text=command+"\r"						//run it
	else //Mac
		//strTem1=NI1_convertToPOSIXpath(ParseFilePath(1, FileNameToLoad, ":", 1, 0))
		strTem1=NI1_convertToPOSIXpath(ParseFilePath(1, FileNameToLoad, ":", 1, 0),0)
		tempCommand=SpecialDirPath("Temporary", 0, 1, 0 )+"tempjunk/"
		JunkFolderLocation=tempCommand
		//command="\""+	Fit2Dlocation+"\" "
		command=	"cd \""+strTem1 +"\" ;"+NI1_convertToPOSIXpath(Fit2Dlocation,1)
		command += " -dim8192x8192 -key -nographics -mac\""
		command += tempCommand+"Fit2DNika.mac\""
	//	ExecuteCmd = SpecialDirPath("Temporary", 0, 1, 0 )+"tempjunk/"+"RunFit2DBatch.bat"
		ExecuteCmd = command
print 	ExecuteCmd	
	//	Notebook $nb text=command+"\r"						//run it
	endif

	string MarType=""
	if(cmpstr(FileType,"ADSC/Fit2D")==0)
		MarType="ADSC Detector Format"
//	ADSC		ADSC Detector Format : Keyword-value header and binary data
	elseif(cmpstr(FileType,"Bruker/Fit2D")==0)
		MarType="Bruker Format"
//	Bruker		Bruker format : Bruker area detector frame data format
	elseif(cmpstr(FileType,"BSL/Fit2D")==0)
		MarType="BSL Format"
//	BSL			BSL format : Daresbury SAXS format, based on Hmaburg format
	elseif(cmpstr(FileType,"Diffract/Fit2D")==0)
		MarType="Compressed diffraction data"
//	Diffract		Compressed diffraction data : Compressed diffraction data
	elseif(cmpstr(FileType,"DIP2000/Fit2D")==0)
		MarType="DIP-2000 (Mac science)"
//	DIP2000		DIP-2000 (Mac science) : 2500*2500 Integer*2 special format
	elseif(cmpstr(FileType,"ESRF/Fit2D")==0)
		MarType="ESRF Data format"
//	ESRF		ESRF Data format : ESRF binary, self describing format
	elseif(cmpstr(FileType,"Fit2D/Fit2D")==0)
		MarType="Fit2D standard format"
//	Fit2D		Fit2D standard format: Self describing readable binary
	elseif(cmpstr(FileType,"BAS/Fit2D")==0)
		MarType="FUJI BAS-2000"
//	BAS		FUJI BAS-2000 : Fuji image plate scanners (aslo BAS-1500)
	elseif(cmpstr(FileType,"GAS/Fit2D")==0)
		MarType="GAS 2-D Detector (ESRF)"
//	GAS		GAS 2-D Detector (ESRF) : Raw format used on the beam-lines
	elseif(cmpstr(FileType,"HAMA/Fit2D")==0)
		MarType="HAMAMATSU PHOTONICS"
//	HAMA		HAMAMATSU PHOTONICS : C4880 CCD detector format
	elseif(cmpstr(FileType,"IMGQ/Fit2D")==0)
		MarType="IMAGEQUANT"
//	IMGQ		IMAGEQUANT : Imagequant TIFF based format (molecular dynamics)
	elseif(cmpstr(FileType,"KLORA/Fit2D")==0)
		MarType="KLORA"
//	KLORA		KLORA : Simplified sub-set of "EDF" written by Jorg Klora
	elseif(cmpstr(FileType,"MarIP/Fit2D")==0)
		//MarType="MAR RESEARCH FORMAT"
		MarType="NEW MAR CODE"
//	MarIP		MAR RESEARCH FORMAT : "image" format for on-line IP systems
	elseif(cmpstr(FileType,"MarPck/Fit2D")==0)
		MarType="MAR-PCK FORMAT"
//	MarPck		MAR-PCK FORMAT : Compressed old Mar format
//	elseif(cmpstr(FileType,"Bruker/Fit2D")==0)
//		MarType="Bruker Format"
//	MarIP		NEW MAR CODE : Same as MAR RESEARCH FORMAT
	elseif(cmpstr(FileType,"PDS/Fit2D")==0)
		MarType="PDS FORMAT"
//	PDS		PDS FORMAT : Powder diffraction standard format file
	elseif(cmpstr(FileType,"PHOTOM/Fit2D")==0)
		MarType="PHOTOMETRICS CCD FORMAT"
//	PHOTOM		PHOTOMETRICS CCD FORMAT : X-ray image intensifier system
	elseif(cmpstr(FileType,"PMC/Fit2D")==0)
		MarType="PMC Format"
//	PMC		PMC Format : Photometrics Compressed XRII/CCD data
	elseif(cmpstr(FileType,"PRINC/Fit2D")==0)
		MarType="PRINCETON CCD FORMAT"
//	PRINC		PRINCETON CCD FORMAT :X-ray image intensifier system
	elseif(cmpstr(FileType,"RIGK/Fit2D")==0)
		MarType="RIGAKU R-AXIS"
//	RIGK		RIGAKU R-AXIS : Riguka image plate scanner format
//	elseif(cmpstr(FileType,"Bruker/Fit2D")==0)
//		MarType="Bruker Format"
	endif
//	string FlnmToLoad=RemoveEnding(removeEnding(StringFromList(ItemsInList(FileNameToLoad,":")-1,FileNameToLoad,":"),".mar2300"),".mar3450")
	string FlnmToLoad=StringFromList(ItemsInList(FileNameToLoad,":")-1,FileNameToLoad,":")	//RemoveEnding(removeEnding(StringFromList(ItemsInList(FileNameToLoad,":")-1,FileNameToLoad,":"),".mar2300"),".mar3450")
	SaveNotebook /O/P=TempFilepath RunFit2DBatch as "RunFit2DBatch.bat"
	KillWIndow/Z RunFit2DBatch

	nb = "RunFit2D"
	NewNotebook/V=1/N=$nb/F=0/V=1/K=0/W=(277.5,81.5,644.25,487.25) 
	Notebook $nb defaultTab=20, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb font="Arial", fSize=10, fStyle=0, textRGB=(0,0,0)
	Notebook $nb text="INPUT"+"\r"						//switch Fit2D into input mode
	//Notebook $nb text="MAR RESEARCH"+"\r"			//it will be Mar packed data file
	Notebook $nb text=MarType+"\r"						//it will be Mar packed data file
//	Notebook $nb text=IN2G_FixWindowsPathAsNeed(FileNameToLoad,2, 0)+"\r"		//file name to load...
//print FileNameToLoad	
//	FileNameToLoad=IN2G_FixWindowsPathAsNeed(S_path,2, 1)+realName
       if (stringmatch(IgorInfo(2),"Windows"))       // this section for Windows
		FileNameToLoad=ParseFilePath(5, FileNameToLoad, "\\", 0, 0)
		//print FileNameToLoad
	else
		FileNameToLoad=ParseFilePath(0, FileNameToLoad, ":", 1, 0)
	endif
	Notebook $nb text=FileNameToLoad+"\r"		//file name to load...
	Notebook $nb text="OUTPUT"+"\r"						//output mode
	Notebook $nb text="TIFF"+"\r"						//tiff file
//	Notebook $nb text=JunkFolderLocation+RemoveEnding(RemoveEnding(StringFromList(ItemsInList(FileNameToLoad,":")-1,FileNameToLoad,":"),"mar2300"),"mar3450")+"tif\r"						//project name

       if (stringmatch(IgorInfo(2),"Windows"))       // this section for Windows
		Notebook $nb text=JunkFolderLocation+FlnmToLoad+".tif\r"						//project name
	else
		Notebook $nb text=FlnmToLoad+".tif\r"						//project name
	endif
	Notebook $nb text="NO"+"\r"						//project name .. seems 
	Notebook $nb text="2"+"\r"						//project name
	Notebook $nb text="0.0"+"\r"						//project name
	Notebook $nb text="65535.00"+"\r"						//project name
	//write another file to test first one is finished...
	Notebook $nb text="OUTPUT"+"\r"						//output mode
	Notebook $nb text="CHIPLOT"+"\r"						//tiff file
       if (stringmatch(IgorInfo(2),"Windows"))       // this section for Windows
		Notebook $nb text=JunkFolderLocation+FlnmToLoad+".chi\r"						//project name
	else
		Notebook $nb text=FlnmToLoad+".chi\r"						//project name
	endif
	Notebook $nb text="Yes"+"\r"						//project name
	Notebook $nb text="1"+"\r"						//project name
	Notebook $nb text="Yes"+"\r"						//project name
	//end of added lines...
	Notebook $nb text="EXIT"+"\r"						//project name
	Notebook $nb text="YES"+"\r"						//project name

	close/A
	SaveNotebook /O/P=TempFilepath RunFit2D as "Fit2DNika.mac"
	KillWIndow/Z RunFit2D
	return ExecuteCmd	
end

Function NI1_GetFit2DLocation()

	SVAR Fit2Dlocation=root:Packages:Convert2Dto1D:Fit2Dlocation
	variable refnum
	variable i
	Open/R/Z refnum as Fit2Dlocation
	close /A
	string tempCommand=""
	if(V_Flag!=0)		//not intialized
		if(cmpstr(IgorInfo(2),"Windows")==0)
			Open/R/D/M="Find Fit2D program"/T=".exe" refnum
			close /A
			tempCommand=""
			//tempCommand=IN2G_FixWindowsPathAsNeed(S_fileName,2, 0)
			tempCommand=parseFilePath(5,S_fileName,"*",0,0)		//fix, 7/7/09 JIL 
			Fit2Dlocation= tempCommand
			Open/R/Z refnum as Fit2Dlocation
			close /A
			if(V_Flag!=0)	
				Abort "Fit2d program not found, try again and pass valid Fit2D file!!!"
			endif
		else //Mac
			Open/R/D/M="Find Fit2D program"/T="????" refnum
			close /A
			tempCommand=""
			tempCommand=(S_fileName)  		//IN2G_FixWindowsPathAsNeed(S_fileName,2, 0)
			Fit2Dlocation= tempCommand
			Open/R/Z refnum as Fit2Dlocation
			close /A
			if(V_Flag!=0)	
				Abort "Fit2d program not found, try again and pass valid Fit2D file!!!"
			endif
	
		endif
	endif
end


Function/T NBI1_getPOSIXpath(pathName)
       String pathName                                                 // path name that I want the directory of
       PathInfo $pathName

       if (!stringmatch(IgorInfo(2),"Macintosh"))      // this section for Mac
               return ""
       endif

       PathInfo $pathName
       String script = "get POSIX path of file \"" + S_path + "\""
       ExecuteScriptText/Z script
       if (V_Flag)
               return ""
       endif
       String POSIXpath = S_value[1,StrLen(S_value)-2] // trim quotes
       POSIXpath = ReplaceString(" ",POSIXpath,"\\\\ ")        // change spaces to escaped spaces
       return POSIXpath
End


Function/T NI1_convertToPOSIXpath(pathNameStr, doubleEscape)
       String pathNameStr                                                 // path name that I want the directory of
	variable doubleEscape							//set to 1 to have spaces repalced by \\
	
       if (!stringmatch(IgorInfo(2),"Macintosh"))      // this section for Mac
               return ""
       endif

       String script = "get POSIX path of file \"" + pathNameStr + "\""
       ExecuteScriptText/Z script
       if (V_Flag)
               return ""
       endif
       String POSIXpath = S_value[1,StrLen(S_value)-2] // trim quotes
      if(doubleEscape)
     		  POSIXpath = ReplaceString(" ",POSIXpath,"\\\\ ")        // change spaces to escaped spaces
      endif
       return POSIXpath
End

//function testStertScript(Fit2Dlocation)
//	string Fit2Dlocation
//	
//               String cmd
//         //      cmd  = "open application "+Fit2Dlocation
//             	sprintf cmd, "do shell script \"%s\"", Fit2Dlocation
//             	print cmd
//               ExecuteScriptText/Z cmd
//	
//	
//end

//This is an example:



////      returns the directory of the path in a semi-colon separated list
////(works for both Mac & Windows)
// Function/T NI1_directory(pathName)
//       String pathName                                                 // path name that I want the directory of
//       PathInfo $pathName
//
//       String list=""
//       if (stringmatch(IgorInfo(2),"Macintosh"))       // this section for Mac
//               PathInfo $pathName
//               String script = "get POSIX path of file \"" + S_path + "\""
//               ExecuteScriptText/Z script
//               if (V_Flag)
//                       return ""
//               endif
//               String POSIXpath = S_value[1,StrLen(S_value)-2] // trim quotes
//               POSIXpath = ReplaceString(" ",POSIXpath,"\\\\ ")        // change spaces to escaped spaces
//               String cmd
//               sprintf cmd, "do shell script \"ls %s\"",POSIXpath
//               print cmd
////              sprintf cmd, "do shell script \"ls \\\"%s\\\"\"",POSIXpath
//               ExecuteScriptText/Z cmd
//               if (V_Flag==0)
//                       // print POSIXpath, "        ",cmd
//                       list = S_value
//                       Variable i=strlen(list)
//                       list = list[1,i-2]                                              // remove leading and trailing double quote
//                       list = ReplaceString("\r", list, ";" )          // change to a semicolon separated list
//               else
//                       print " the 'ls' command failed, you may want to add anther mount point to the directory() function to speed things up"
//                       list = IndexedFile($pathName,-1,".SPE")
//               endif
//       else                                                                                    // this sectio for Windows
//               list = IndexedFile($pathName,-1,".SPE")         // list = IndexedFile ($pathName,-1,"????")
//
//       endif
//       return list
//End
//
//
////			testStertScript(Fit2Dlocation)
//	//		abort
