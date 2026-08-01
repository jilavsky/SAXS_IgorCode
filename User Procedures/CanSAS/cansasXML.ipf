#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=1		// rtGlobals=3 requires IgorPro 6.3+
#pragma version=1.12

// file:	cansasXML.ipf
// author:	Pete R. Jemian <jemian@anl.gov>
// SVN date:	$Date: 2013-03-29 00:00:46 -0500 (Fri, 29 Mar 2013) $
// SVN rev.:	$Revision: 313 $
// SVN URL:	$HeadURL: http://www.cansas.org/svn/1dwg/tags/v1.1/IgorPro/cansasXML.ipf $
// SVN ID:	$Id: cansasXML.ipf 313 2013-03-29 05:00:46Z prjemian $
// purpose:  implement an IgorPro file reader to read the canSAS 1-D reduced SAS data in XML files
//			adhering to either the cansas1d/1.0 or cansas1d/1.1 standards
// readme:    http://www.cansas.org/formats/canSAS1d/1.1/doc/binding-igorpro.html
// URL:	http://www.cansas.org/formats/canSAS1d/1.1/doc/
//
// requires:	IgorPro (http://www.wavemetrics.com/)
// provides:  CS_XmlReader(String fileName)
//				all other functions in this file should not be relied upon
//
// Copyright (c) 2013, UChicago Argonne, LLC
// This file is distributed subject to a Software License Agreement found in the file LICENSE that is included with this distribution.

//  ================  ================  =================  ==========
//  #pragma version   canSAS1d version  namespace          released
//  ================  ================  =================  ==========
//  1.12              v1.1              urn:cansas1d:1.1   2013-04-01
//  1.11              v1.0              cansas1d/1.0       2009-09-25
//  ================  ================  =================  ==========

// ==================================================================
// CS_XmlReader("../examples/bimodal-test1.xml")
// CS_XmlReader("../examples/1998spheres.xml")
// CS_XmlReader("../examples/xg009036_001.xml")
// CS_XmlReader("../examples/s81-polyurea.xml")
// CS_XmlReader("../examples/cs_af1410.xml")
//  testCollette();  prjTest_cansas1d()
// ==================================================================

Function CS_XmlReader(fileName)
	//
	// open a canSAS 1-D reduced SAS XML data file
	//	returns:
	//		0 : successful
	//		-1: XML file not found
	//		-2: root element is not <SASroot> with valid canSAS namespace
	//		-3: <SASroot> version  is not 1.0 or 1.1
	//		-4: no <SASentry> elements
	//		-5: XMLutils XOP needs upgrade
	//		-6: XMLutils XOP not found
	//
	String fileName
	String origFolder
	String workingFolder = "root:Packages:CS_XMLreader"
	VARIABLE returnCode

	//
	// set up a work folder within root:Packages
	// Clear out any progress/results from previous activities
	//
	origFolder = GetDataFolder(1)
	SetDataFolder root:					// start in the root data folder
	NewDataFolder/O  root:Packages		// good practice
	KillDataFolder/Z  $workingFolder		// clear out any previous work
	NewDataFolder/O/S  $workingFolder	// Do all our work in root:XMLreader

	//
	// Try to open the named XML file (clean-up and return if failure)
	//
	String/G errorMsg, xmlFile
	xmlFile = fileName
	string xmlStr = IN2G_XMLreadFile(fileName)
	if(strlen(xmlStr)==0)
		errorMsg = fileName + " either not found or cannot be opened for reading"
		PRINT errorMsg
		SetDataFolder $origFolder
		RETURN(-1)						// could not find file
	endif

	// check for canSAS namespace string, returns "" if not valid or not found
	// ns, nsPre and nsStr are globals because every CS_ helper below reads them by SVAR
	String/G ns = CS_getDefaultNamespace(xmlStr)
	SVAR ns = root:Packages:CS_XMLreader:ns
	if(strlen(ns) == 0 )
		errorMsg = "root element is not <SASroot> with valid canSAS namespace"
		PRINT errorMsg
		SetDataFolder $origFolder
		RETURN(-2)						// root element is not <SASroot> with valid canSAS namespace
	endif
	String/G nsPre, nsStr
	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr

	nsPre = "cs:"
	nsStr = "cs=" + ns

	STRSWITCH(ns)
	CASE "cansas1d/1.0":							// version 1.0 of the canSAS 1-D reduced SAS data standard
	CASE "urn:cansas1d:1.1":						// version 1.1 of the canSAS 1-D reduced SAS data standard
		PRINT fileName, "\t\t identified as: " + ns + " XML file"
		returnCode = CS_1i_parseXml(xmlStr)			//  This is where the action happens!
		if(returnCode != 0)
			if(strlen(errorMsg) == 0)
				errorMsg = "error while parsing the XML"
			endif
			PRINT errorMsg
			SetDataFolder $origFolder
			RETURN(returnCode)			// error while parsing the XML
		endif
		BREAK
	CASE "cansas1d/2.0a":						// unsupported
	DEFAULT:							// optional default expression executed
		errorMsg = fileName + ": <SASroot>, namespace (" + ns + ") is not supported"
		PRINT errorMsg
		SetDataFolder $origFolder
		RETURN(-3)						// attribute list must include version="1.0"
	ENDSWITCH

	IN2G_XMLcloseFile()

	SetDataFolder root:Packages:CS_XMLreader
	KillWaves/Z M_listXPath, SASentryList
	SetDataFolder $origFolder
	RETURN(0)							// execution finished OK
End

Function/S CS_getDefaultNamespace(xmlStr)
	string xmlStr
	// Test here (by guessing) for the various known namespaces.
	// The namespace is taken from the root element's default xmlns declaration, falling
	// back to the URI half of its schemaLocation attribute, and it is only accepted if it
	// is one of the canSAS 1-D namespaces this reader understands.
	VARIABLE item
	// list of all the canSAS 1-D namespaces this reader understands
	STRING nsList = "cansas1d/1.0;urn:cansas1d:1.1;"
	STRING candidate

	string attrs = IN2G_XMLlistAttr(xmlStr, "/SASroot", "")
	if(strlen(attrs)==0)
		RETURN ""					// the root element is not <SASroot>
	endif
	string declared = StringByKey("xmlns", attrs, "=", ";", 0)
	string schemaLoc = IN2G_TrimFrontBackWhiteSpace(StringByKey("schemaLocation", attrs, "=", ";", 0))

	for(item=0; item<ItemsInList(nsList); item+=1)		// loop over all possible namespaces
		candidate = StringFromList(item, nsList)
		if(CmpStr(declared, candidate) == 0)
			RETURN candidate		// found it, declared as the default namespace
		endif
		if(StringMatch(schemaLoc, candidate + "*"))
			RETURN candidate		// found it, named in schemaLocation
		endif
	endfor

	RETURN ""
End

// ==================================================================

Function CS_1i_parseXml(xmlStr)
	String xmlStr
	SVAR errorMsg, xmlFile
	STRING/G Title, Title_folder
	VARIABLE i, j, index, SASdata_index, returnCode = 0

	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr

	// locate all the SASentry elements
	string xpath = "/cs:SASroot//cs:SASentry"
	string listXPath = IN2G_XMLlistXpath(xmlStr, xpath, nsStr)
	CS_XMLxpathList2Wave(listXPath)
	WAVE/T M_listXPath
	STRING		SASentryPath
	DUPLICATE/O/T	M_listXPath, SASentryList

	for(i=0; i<DimSize(SASentryList, 0); i+=1)
		SASentryPath = "/cs:SASroot/cs:SASentry["+num2str(i+1)+"]"
		SetDataFolder root:Packages:CS_XMLreader
		
		title =  CS_1i_locateTitle(xmlStr, SASentryPath)
		Title_folder = CS_cleanFolderName(Title)
		NewDataFolder/O/S  $Title_folder

		xpath = SASentryPath + "//cs:SASdata"
		listXPath = IN2G_XMLlistXpath(xmlStr, xpath, nsStr)
		CS_XMLxpathList2Wave(listXPath)
		WAVE/T M_listXPath
		if(DimSize(M_listXPath, 0) == 1)
			CS_1i_getOneSASdata(xmlStr, Title, SASentryPath+"/cs:SASdata")
			CS_1i_collectMetadata(xmlStr, SASentryPath)
		else
			for(j = 0; j<DimSize(M_listXPath, 0); j+=1)
				// Could make this new behavior optional
				STRING SASdata_item = "SASdata_" + num2str(j)
				STRING SASdata_node = SASentryPath+"/cs:SASdata["+num2str(j+1)+"]"
				// Preferred name obtained from the SASentry/SASdata/@name attribute, if present
				STRING SASdata_name = IN2G_XMLstrFmXpath(xmlStr,  SASdata_node + "/@name", nsStr, "")
				if(strlen(SASdata_name) == 0)
					if(DimSize(M_listXPath, 0) == 1)
						// Alternative if only one SASdata block is to use the SASentry/Title
						SASdata_name = IN2G_XMLstrFmXpath(xmlStr,  SASentryPath+"/cs:Title", nsStr, "")
					else
						// the original behavior: SASdata_0, SASdata_1, ...
						SASdata_name = SASdata_item
					endif
					// the original behavior: SASdata_0, SASdata_1, ...
					SASdata_name = SASdata_item
				endif
				STRING SASdataFolder = CS_cleanFolderName(SASdata_name)
				NewDataFolder/O/S  $SASdataFolder
				CS_1i_getOneSASdata(xmlStr, Title, SASdata_node)
				CS_1i_collectMetadata(xmlStr, SASentryPath)
				SetDataFolder ::			// back up to parent directory
			endfor
		endif

		// TODO: process any transmission spectra
		string ns = CS_getDefaultNamespace(xmlStr)
		if(cmpstr(ns,  "urn:cansas1d:1.1") == 0)
			xpath = SASentryPath + "//cs:SAStransmission_spectrum"
			listXPath = IN2G_XMLlistXpath(xmlStr, xpath, nsStr)
			CS_XMLxpathList2Wave(listXPath)
			WAVE/T M_listXPath
			print "Searching for SAStransmission_spectrum groups"
			print DimSize(M_listXPath, 0) , M_listXPath
			// ...
		endif
		
		KillWaves/Z M_listXPath
	endfor

	SetDataFolder root:Packages:CS_XMLreader
	KillWaves/Z M_listXPath, SASentryList
	RETURN(returnCode)
End

// ==================================================================

Function/S CS_cleanFolderName(proposal)
	STRING proposal
	STRING result
	result = CleanupName(proposal, 0)
	if( CheckName(result, 11) != 0 )
		result = UniqueName(result, 11, 0)
	endif
	RETURN result
End

// ==================================================================

Function CS_1i_getOneSASdata(xmlStr, Title, SASdataPath)
	String xmlStr, Title, SASdataPath
	
	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr
	VARIABLE i
	STRING SASdata_name, suffix = ""

	//grab the data and put it in the working data folder
	CS_1i_GetReducedSASdata(xmlStr, SASdataPath)

	//start the metadata
	MAKE/O/T/N=(0,2) metadata

	SVAR xmlFile = root:Packages:CS_XMLreader:xmlFile
	CS_appendMetaData(xmlStr, "xmlFile", "", xmlFile)

	SVAR ns = root:Packages:CS_XMLreader:ns
	CS_appendMetaData(xmlStr, "namespace", "", ns)
	CS_appendMetaData(xmlStr, "Title", "", Title)
	
	string xpath = SASdataPath + "/..//cs:Run"
	string listXPath = IN2G_XMLlistXpath(xmlStr, xpath, nsStr)
	CS_XMLxpathList2Wave(listXPath)
	WAVE/T M_listXPath
	for(i=0; i<DimSize(M_listXPath, 0); i+=1)
		if( DimSize(M_listXPath, 0) > 1 )
			suffix = "_" + num2str(i)
		endif
		CS_appendMetaData(xmlStr, "Run" + suffix,  SASdataPath + "/../cs:Run["+num2str(i+1)+"]", "")
		CS_appendMetaData(xmlStr, "Run/@name" + suffix,  SASdataPath + "/../cs:Run["+num2str(i+1)+"]/@name", "")
	endfor

	SASdata_name = TrimWS(IN2G_XMLstrFmXpath(xmlStr,  SASdataPath + "/@name", nsStr, ""))
	CS_appendMetaData(xmlStr, "SASdata/@name", "", SASdata_name)

	KillWaves/Z M_listXPath
End

// ==================================================================

Function CS_1i_getOneVector(xmlStr, prefix, XML_name, Igor_name)
	String xmlStr, prefix, XML_name, Igor_name
	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr

	// The point count comes from the number of matching nodes, not from splitting the
	// joined text: an empty element such as <Idev/> contributes an empty value and would
	// otherwise be lost.
	string xpath = prefix + XML_name
	variable nPoints = ItemsInList(IN2G_XMLlistXpath(xmlStr, xpath, nsStr), ";")
	if(nPoints < 1)
		return 0							// this vector is simply not present in the file
	endif

	// Collect every node on this path at once. ";" is a literal separator here, so the
	// same character is used to split the result back apart.
	string content = IN2G_XMLwaveFmXpath(xmlStr, xpath, nsStr, ";")
	MAKE/O/D/N=(nPoints) $Igor_name
	WAVE vect = $Igor_name
	vect = NaN
	CS_ListToNumWave(content, vect)
End

// ==================================================================
// Fill wv from a ";" separated list of numbers. This walks the string once instead of
// calling StringFromList per item, which would be quadratic on files with many points.
// ==================================================================

Function CS_ListToNumWave(list, wv)
	String list
	WAVE wv

	Variable n = numpnts(wv), len = strlen(list)
	Variable i = 0, i0 = 0, i1
	do
		if(i>=n || i0>=len)
			break
		endif
		i1 = strsearch(list, ";", i0)
		if(i1<0)
			i1 = len
		endif
		wv[i] = str2num(list[i0, i1-1])
		i += 1
		i0 = i1+1
	while(1)
End

// ==================================================================

Function CS_1i_GetReducedSASdata(xmlStr, SASdataPath)
	String xmlStr, SASdataPath
	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr
	STRING prefix = ""
	VARIABLE pos

	VARIABLE cansasStrict = 1		// !!!software developer's choice!!!
	if(cansasStrict)		// only get known canSAS data vectors
		prefix = SASdataPath + "//cs:"
		// load ALL nodes of each vector (if exists) at the same time
		CS_1i_getOneVector(xmlStr, prefix, "Q", 		"Qsas")
		CS_1i_getOneVector(xmlStr, prefix, "I", 		"Isas")
		CS_1i_getOneVector(xmlStr, prefix, "Idev", 		"Idev")
		CS_1i_getOneVector(xmlStr, prefix, "Qdev",		"Qdev")
		CS_1i_getOneVector(xmlStr, prefix, "dQw", 	"dQw")
		CS_1i_getOneVector(xmlStr, prefix, "dQl", 		"dQl")
		CS_1i_getOneVector(xmlStr, prefix, "Qmean",	"Qmean")
		CS_1i_getOneVector(xmlStr, prefix, "Shadowfactor", 	"Shadowfactor")
		// check them for common length
	else				// search for _ANY_ data vectors
		// find the names of all the data columns and load them as vectors
	 	// this gets tricky if we want to avoid namespace references
		string xpath = SASdataPath+"//cs:Idata[1]/*"
		string listXPath = IN2G_XMLlistXpath(xmlStr, xpath, nsStr)
		CS_XMLxpathList2Wave(listXPath)
		WAVE/T M_listXPath
		STRING xmlElement, xPathStr
		STRING igorWave
		VARIABLE j
		for(j = 0; j<DimSize(M_listXPath, 0); j+=1)	// loop over all columns in SASdata/Idata[1]
			xmlElement = M_listXPath[j][1]
			STRSWITCH(xmlElement)
				CASE "Q":		// IgorPro does not allow a variable named Q
				CASE "I":			// or I
					igorWave = xmlElement + "sas"
					BREAK
				DEFAULT:
					igorWave = xmlElement		// can we trust this one?
			ENDSWITCH
			//
			//  Could there be a problem with a foreign namespace here?
			prefix = SASdataPath+"//cs:Idata/"						// ALL Idata elements
			xmlElement = "cs:" + M_listXPath[j][1]					// just this column
			CS_1i_getOneVector(xmlStr, prefix, xmlElement, igorWave)		// loads ALL rows (Idata) of the column at the same time
		endfor
		// check them for common length
	endif
  
	//get rid of any mess
	KILLWAVES/z M_listXPath
End

// ==================================================================

Function CS_1i_collectMetadata(xmlStr, sasEntryPath)
	String xmlStr, sasEntryPath
	VARIABLE i, j
	WAVE/T metadata
	STRING suffix = "", preMeta = "", preXpath = ""
	STRING value, detailsPath, detectorPath, notePath

	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr

	// collect some metadata
	// first, fill a table with keywords, and XPath locations, 3rd column will be values

	// handle most <SASsample> fields
	CS_appendMetaData(xmlStr, "SASsample/@name",				sasEntryPath + "/cs:SASsample/@name", "")
	CS_appendMetaData(xmlStr, "SASsample/ID",					sasEntryPath + "/cs:SASsample/cs:ID", "")
	CS_appendMetaData(xmlStr, "SASsample/thickness",				sasEntryPath + "/cs:SASsample/cs:thickness", "")
	CS_appendMetaData(xmlStr, "SASsample/thickness/@unit",  		sasEntryPath + "/cs:SASsample/cs:thickness/@unit", "")
	CS_appendMetaData(xmlStr, "SASsample/transmission",			sasEntryPath + "/cs:SASsample/cs:transmission", "")
	CS_appendMetaData(xmlStr, "SASsample/temperature",			sasEntryPath + "/cs:SASsample/cs:temperature", "")
	CS_appendMetaData(xmlStr, "SASsample/temperature/@unit",	   sasEntryPath + "/cs:SASsample/cs:temperature/@unit", "")
	CS_appendMetaData(xmlStr, "SASsample/position/x",			   sasEntryPath + "/cs:SASsample/cs:position/cs:x", "")
	CS_appendMetaData(xmlStr, "SASsample/position/x/@unit", 	   sasEntryPath + "/cs:SASsample/cs:position/cs:x/@unit", "")
	CS_appendMetaData(xmlStr, "SASsample/position/y",			   sasEntryPath + "/cs:SASsample/cs:position/cs:y", "")
	CS_appendMetaData(xmlStr, "SASsample/position/y/@unit", 	   sasEntryPath + "/cs:SASsample/cs:position/cs:y/@unit", "")
	CS_appendMetaData(xmlStr, "SASsample/position/z",			   sasEntryPath + "/cs:SASsample/cs:position/cs:z", "")
	CS_appendMetaData(xmlStr, "SASsample/position/z/@unit", 	   sasEntryPath + "/cs:SASsample/cs:position/cs:z/@unit", "")
	CS_appendMetaData(xmlStr, "SASsample/orientation/roll", 		   sasEntryPath + "/cs:SASsample/cs:orientation/cs:roll", "")
	CS_appendMetaData(xmlStr, "SASsample/orientation/roll/@unit",	   sasEntryPath + "/cs:SASsample/cs:orientation/cs:roll/@unit", "")
	CS_appendMetaData(xmlStr, "SASsample/orientation/pitch",	   sasEntryPath + "/cs:SASsample/cs:orientation/cs:pitch", "")
	CS_appendMetaData(xmlStr, "SASsample/orientation/pitch/@unit",     sasEntryPath + "/cs:SASsample/cs:orientation/cs:pitch/@unit", "")
	CS_appendMetaData(xmlStr, "SASsample/orientation/yaw",  		   sasEntryPath + "/cs:SASsample/cs:orientation/cs:yaw", "")
	CS_appendMetaData(xmlStr, "SASsample/orientation/yaw/@unit",	   sasEntryPath + "/cs:SASsample/cs:orientation/cs:yaw/@unit", "")
	// <SASsample><details> might appear multiple times, too!
	string xpath = sasEntryPath+"/cs:SASsample//cs:details"
	string listXPath = IN2G_XMLlistXpath(xmlStr, xpath, nsStr)
	CS_XMLxpathList2Wave(listXPath)
	WAVE/T M_listXPath
	DUPLICATE/O/T   M_listXPath, detailsList
	suffix = ""
	for(i = 0; i<DimSize(detailsList, 0); i+=1)
		if(DimSize(detailsList, 0) > 1)
			suffix = "_" + num2str(i)
		endif
		detailsPath = sasEntryPath+"/cs:SASsample/cs:details["+num2str(i+1)+"]"
		CS_appendMetaData(xmlStr, "SASsample/details"+suffix+"/@name", 	detailsPath + "/@name", "")
		CS_appendMetaData(xmlStr, "SASsample/details"+suffix,	 	detailsPath, "")
	endfor


	// <SASinstrument>
	CS_appendMetaData(xmlStr, "SASinstrument/name",		sasEntryPath + "/cs:SASinstrument/cs:name", "")
	CS_appendMetaData(xmlStr, "SASinstrument/@name",	sasEntryPath + "/cs:SASinstrument/@name", "")

	// <SASinstrument><SASsource>
	preMeta = "SASinstrument/SASsource"
	preXpath = sasEntryPath + "/cs:SASinstrument/cs:SASsource"
	CS_appendMetaData(xmlStr, preMeta + "/@name",			   preXpath + "/@name", "")
	CS_appendMetaData(xmlStr, preMeta + "/radiation",		   preXpath + "/cs:radiation", "")
	CS_appendMetaData(xmlStr, preMeta + "/beam/size/@name", 	   preXpath + "/cs:beam_size/@name", "")
	CS_appendMetaData(xmlStr, preMeta + "/beam/size/x",		   preXpath + "/cs:beam_size/cs:x", "")
	CS_appendMetaData(xmlStr, preMeta + "/beam/size/x@unit",	   preXpath + "/cs:beam_size/cs:x/@unit", "")
	CS_appendMetaData(xmlStr, preMeta + "/beam/size/y",		   preXpath + "/cs:beam_size/cs:y", "")
	CS_appendMetaData(xmlStr, preMeta + "/beam/size/y@unit",	   preXpath + "/cs:beam_size/cs:y/@unit", "")
	CS_appendMetaData(xmlStr, preMeta + "/beam/size/z",		   preXpath + "/cs:beam_size/cs:z", "")
	CS_appendMetaData(xmlStr, preMeta + "/beam/size/z@unit",	   preXpath + "/cs:beam_size/cs:z/@unit", "")
	CS_appendMetaData(xmlStr, preMeta + "/beam/shape",		   preXpath + "/cs:beam_shape", "")
	CS_appendMetaData(xmlStr, preMeta + "/wavelength",		   preXpath + "/cs:wavelength", "")
	CS_appendMetaData(xmlStr, preMeta + "/wavelength/@unit",	   preXpath + "/cs:wavelength/@unit", "")
	CS_appendMetaData(xmlStr, preMeta + "/wavelength_min",  	   preXpath + "/cs:wavelength_min", "")
	CS_appendMetaData(xmlStr, preMeta + "/wavelength_min/@unit",	   preXpath + "/cs:wavelength_min/@unit", "")
	CS_appendMetaData(xmlStr, preMeta + "/wavelength_max",  	   preXpath + "/cs:wavelength_max", "")
	CS_appendMetaData(xmlStr, preMeta + "/wavelength_max/@unit",	   preXpath + "/cs:wavelength_max/@unit", "")
	CS_appendMetaData(xmlStr, preMeta + "/wavelength_spread",	   preXpath + "/cs:wavelength_spread", "")
	CS_appendMetaData(xmlStr, preMeta + "/wavelength_spread/@unit",    preXpath + "/cs:wavelength_spread/@unit", "")

	// <SASinstrument><SAScollimation> might appear multiple times
	xpath = sasEntryPath+"/cs:SASinstrument//cs:SAScollimation"
	listXPath = IN2G_XMLlistXpath(xmlStr, xpath, nsStr)
	CS_XMLxpathList2Wave(listXPath)
	WAVE/T M_listXPath
	DUPLICATE/O/T   M_listXPath, SAScollimationList
	STRING collimationPath
	for(i = 0; i<DimSize(SAScollimationList, 0); i+=1)
		preMeta = "SASinstrument/SAScollimation"
		if(DimSize(SAScollimationList, 0) > 1)
			preMeta += "_" + num2str(i)
		endif
		collimationPath = sasEntryPath+"/cs:SASinstrument/cs:SAScollimation["+num2str(i+1)+"]"
		CS_appendMetaData(xmlStr, preMeta + "/@name",		    collimationPath + "/@name", "")
		CS_appendMetaData(xmlStr, preMeta + "/length",		    collimationPath + "/cs:length", "")
		CS_appendMetaData(xmlStr, preMeta + "/length_unit",	    collimationPath + "/cs:length/@unit", "")
		for(j = 0; j<DimSize(M_listXPath, 0); j+=1)	// aperture may be repeated!
			if(DimSize(M_listXPath, 0) == 1)
				preMeta = "SASinstrument/SAScollimation/aperture"
			else
				preMeta = "SASinstrument/SAScollimation/aperture_" + num2str(j)
			endif
			preXpath = collimationPath + "/cs:aperture["+num2str(j+1)+"]"
			CS_appendMetaData(xmlStr, preMeta + "/@name",	      preXpath + "/@name", "")
			CS_appendMetaData(xmlStr, preMeta + "/type",	      preXpath + "/cs:type", "")
			CS_appendMetaData(xmlStr, preMeta + "/size/@name",     preXpath + "/cs:size/@name", "")
			CS_appendMetaData(xmlStr, preMeta + "/size/x",	      preXpath + "/cs:size/cs:x", "")
			CS_appendMetaData(xmlStr, preMeta + "/size/x/@unit",   preXpath + "/cs:size/cs:x/@unit", "")
			CS_appendMetaData(xmlStr, preMeta + "/size/y",	      preXpath + "/cs:size/cs:y", "")
			CS_appendMetaData(xmlStr, preMeta + "/size/y/@unit",   preXpath + "/cs:size/cs:y/@unit", "")
			CS_appendMetaData(xmlStr, preMeta + "/size/z",	      preXpath + "/cs:size/cs:z", "")
			CS_appendMetaData(xmlStr, preMeta + "/size/z/@unit",   preXpath + "/cs:size/cs:z/@unit", "")
			CS_appendMetaData(xmlStr, preMeta + "/distance",       preXpath + "/cs:distance", "")
			CS_appendMetaData(xmlStr, preMeta + "/distance/@unit", preXpath + "/cs:distance/@unit", "")
		endfor
	endfor

	// <SASinstrument><SASdetector> might appear multiple times
	xpath = sasEntryPath+"/cs:SASinstrument//cs:SASdetector"
	listXPath = IN2G_XMLlistXpath(xmlStr, xpath, nsStr)
	CS_XMLxpathList2Wave(listXPath)
	WAVE/T M_listXPath
	DUPLICATE/O/T   M_listXPath, SASdetectorList
	for(i = 0; i<DimSize(SASdetectorList, 0); i+=1)
		preMeta = "SASinstrument/SASdetector"
		if(DimSize(SASdetectorList, 0) > 1)
			preMeta += "_" + num2str(i)
		endif
		detectorPath = sasEntryPath+"/cs:SASinstrument/cs:SASdetector["+num2str(i+1)+"]"
		CS_appendMetaData(xmlStr, preMeta + "/@name",			 detectorPath + "/cs:name", "")
		CS_appendMetaData(xmlStr, preMeta + "/SDD",				 detectorPath + "/cs:SDD", "")
		CS_appendMetaData(xmlStr, preMeta + "/SDD/@unit",			 detectorPath + "/cs:SDD/@unit", "")
		CS_appendMetaData(xmlStr, preMeta + "/offset/@name",		 detectorPath + "/cs:offset/@name", "")
		CS_appendMetaData(xmlStr, preMeta + "/offset/x", 		 detectorPath + "/cs:offset/cs:x", "")
		CS_appendMetaData(xmlStr, preMeta + "/offset/x/@unit",		 detectorPath + "/cs:offset/cs:x/@unit", "")
		CS_appendMetaData(xmlStr, preMeta + "/offset/y", 		 detectorPath + "/cs:offset/cs:y", "")
		CS_appendMetaData(xmlStr, preMeta + "/offset/y/@unit",		 detectorPath + "/cs:offset/cs:y/@unit", "")
		CS_appendMetaData(xmlStr, preMeta + "/offset/z", 		 detectorPath + "/cs:offset/cs:z", "")
		CS_appendMetaData(xmlStr, preMeta + "/offset/z/@unit",		 detectorPath + "/cs:offset/cs:z/@unit", "")

		CS_appendMetaData(xmlStr, preMeta + "/orientation/@name",	 detectorPath + "/cs:orientation/@name", "")
		CS_appendMetaData(xmlStr, preMeta + "/orientation/roll", 	 detectorPath + "/cs:orientation/cs:roll", "")
		CS_appendMetaData(xmlStr, preMeta + "/orientation/roll/@unit",	 detectorPath + "/cs:orientation/cs:roll/@unit", "")
		CS_appendMetaData(xmlStr, preMeta + "/orientation/pitch",	 detectorPath + "/cs:orientation/cs:pitch", "")
		CS_appendMetaData(xmlStr, preMeta + "/orientation/pitch/@unit",   detectorPath + "/cs:orientation/cs:pitch/@unit", "")
		CS_appendMetaData(xmlStr, preMeta + "/orientation/yaw",  	 detectorPath + "/cs:orientation/cs:yaw", "")
		CS_appendMetaData(xmlStr, preMeta + "/orientation/yaw/@unit",	 detectorPath + "/cs:orientation/cs:yaw/@unit", "")

		CS_appendMetaData(xmlStr, preMeta + "/beam_center/@name",	 detectorPath + "/cs:beam_center/@name", "")
		CS_appendMetaData(xmlStr, preMeta + "/beam_center/x",		 detectorPath + "/cs:beam_center/cs:x", "")
		CS_appendMetaData(xmlStr, preMeta + "/beam_center/x/@unit",	 detectorPath + "/cs:beam_center/cs:x/@unit", "")
		CS_appendMetaData(xmlStr, preMeta + "/beam_center/y",		 detectorPath + "/cs:beam_center/cs:y", "")
		CS_appendMetaData(xmlStr, preMeta + "/beam_center/y/@unit",	 detectorPath + "/cs:beam_center/cs:y/@unit", "")
		CS_appendMetaData(xmlStr, preMeta + "/beam_center/z",		 detectorPath + "/cs:beam_center/cs:z", "")
		CS_appendMetaData(xmlStr, preMeta + "/beam_center/z/@unit",	 detectorPath + "/cs:beam_center/cs:z/@unit", "")

		CS_appendMetaData(xmlStr, preMeta + "/pixel_size/@name", 	 detectorPath + "/cs:pixel_size/@name", "")
		CS_appendMetaData(xmlStr, preMeta + "/pixel_size/x",		 detectorPath + "/cs:pixel_size/cs:x", "")
		CS_appendMetaData(xmlStr, preMeta + "/pixel_size/x/@unit",	 detectorPath + "/cs:pixel_size/cs:x/@unit", "")
		CS_appendMetaData(xmlStr, preMeta + "/pixel_size/y",		 detectorPath + "/cs:pixel_size/cs:y", "")
		CS_appendMetaData(xmlStr, preMeta + "/pixel_size/y/@unit",	 detectorPath + "/cs:pixel_size/cs:y/@unit", "")
		CS_appendMetaData(xmlStr, preMeta + "/pixel_size/z",		 detectorPath + "/cs:pixel_size/cs:z", "")
		CS_appendMetaData(xmlStr, preMeta + "/pixel_size/z/@unit",	 detectorPath + "/cs:pixel_size/cs:z/@unit", "")

		CS_appendMetaData(xmlStr, preMeta + "/slit_length",		       detectorPath + "/cs:slit_length", "")
		CS_appendMetaData(xmlStr, preMeta + "/slit_length/@unit",	       detectorPath + "/cs:slit_length/@unit", "")
	endfor

	// <SASprocess> might appear multiple times
	xpath = sasEntryPath+"//cs:SASprocess"
	listXPath = IN2G_XMLlistXpath(xmlStr, xpath, nsStr)
	CS_XMLxpathList2Wave(listXPath)
	WAVE/T M_listXPath
	DUPLICATE/O/T   M_listXPath, SASprocessList
	STRING SASprocessPath, prefix
	for(i = 0; i<DimSize(SASprocessList, 0); i+=1)
		preMeta = "SASprocess"
		if(DimSize(SASprocessList, 0) > 1)
			preMeta += "_" + num2str(i)
		endif
		SASprocessPath = sasEntryPath+"/cs:SASprocess["+num2str(i+1)+"]"
		CS_appendMetaData(xmlStr, preMeta+"/@name",	   SASprocessPath + "/@name", "")
		CS_appendMetaData(xmlStr, preMeta+"/name",	   SASprocessPath + "/cs:name", "")
		CS_appendMetaData(xmlStr, preMeta+"/date",		   SASprocessPath + "/cs:date", "")
		CS_appendMetaData(xmlStr, preMeta+"/description",   SASprocessPath + "/cs:description", "")
		xpath = SASprocessPath+"//cs:term"
		listXPath = IN2G_XMLlistXpath(xmlStr, xpath, nsStr)
		CS_XMLxpathList2Wave(listXPath)
		WAVE/T M_listXPath
		for(j = 0; j<DimSize(M_listXPath, 0); j+=1)
			prefix = SASprocessPath + "/cs:term[" + num2str(j+1) + "]"
			CS_appendMetaData(xmlStr, preMeta+"/term_"+num2str(j)+"/@name",     prefix + "/@name", "")
			CS_appendMetaData(xmlStr, preMeta+"/term_"+num2str(j)+"/@unit",  	  prefix + "/@unit", "")
			CS_appendMetaData(xmlStr, preMeta+"/term_"+num2str(j),				  prefix, "")
		endfor
		// ignore <SASprocessnote>
	endfor

	// <SASnote> might appear multiple times
	xpath = sasEntryPath+"//cs:SASnote"
	listXPath = IN2G_XMLlistXpath(xmlStr, xpath, nsStr)
	CS_XMLxpathList2Wave(listXPath)
	WAVE/T M_listXPath
	DUPLICATE/O/T   M_listXPath, SASnoteList
	for(i = 0; i<DimSize(SASnoteList, 0); i+=1)
		preMeta = "SASnote"
		if(DimSize(SASnoteList, 0) > 1)
			preMeta += "_" + num2str(i)
		endif
		notePath = sasEntryPath+"//cs:SASnote["+num2str(i+1)+"]"
		CS_appendMetaData(xmlStr, preMeta+"/@name", 	notePath + "/@name", "")
		CS_appendMetaData(xmlStr, preMeta,		notePath, "")
	endfor

	KillWaves/Z M_listXPath, detailsList, SAScollimationList, SASdetectorList, SASprocessList, SASnoteList
End

// ==================================================================

Function/S CS_1i_locateTitle(xmlStr, SASentryPath)
	String xmlStr, SASentryPath
	STRING TitlePath, Title
	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr

	// /cs:SASroot/cs:SASentry/cs:Title is the expected location, but it could be empty
	TitlePath = SASentryPath + "/cs:Title"
	Title = IN2G_XMLstrFmXpath(xmlStr,  TitlePath, nsStr, "")
	// search harder for a title
	if(strlen(Title) == 0)
		TitlePath = SASentryPath + "/@name"
		Title = IN2G_XMLstrFmXpath(xmlStr,  TitlePath, nsStr, "")
	endif
	if(strlen(Title) == 0)
		TitlePath = SASentryPath + "/cs:SASsample/cs:ID"
		Title = IN2G_XMLstrFmXpath(xmlStr,  TitlePath, nsStr, "")
	endif
	if(strlen(Title) == 0)
		TitlePath = SASentryPath + "/cs:SASsample/@name"
		Title = IN2G_XMLstrFmXpath(xmlStr,  TitlePath, nsStr, "")
	endif
	if(strlen(Title) == 0)
		// last resort: make up a title
		Title = "SASentry"
		TitlePath = ""
	endif
	PRINT "\t Title:", Title
	RETURN(Title)
End

// ==================================================================

Function CS_appendMetaData(xmlStr, key, xpath, value)
	String xmlStr, key, xpath, value
	WAVE/T metadata
	STRING k, v

	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr

	k = TrimWS(key)
	if(  strlen(k) > 0 )
		if( strlen(xpath) > 0 )
			value = IN2G_XMLstrFmXpath(xmlStr,  xpath, nsStr, "")
		endif
		// What if the value string has a ";" embedded?
		//  This could complicate (?compromise?) the wavenote "key=value;" syntax.
		//  But let the caller deal with it.
		v = TrimWS(ReplaceString(";", value, " :semicolon: "))
		if( strlen(v) > 0 )
			VARIABLE last
			last = DimSize(metadata, 0)
			Redimension/N=(last+1, 2) metadata
			metadata[last][0] = k
			metadata[last][1] = v
		endif
	endif
End

// ==================================================================

Function/T   TrimWS(str)
    // TrimWhiteSpace (code from Jon Tischler)
    String str
    return IN2G_TrimFrontBackWhiteSpace(str)
End

// ==================================================================

Function/T   TrimWSL(str)
    // TrimWhiteSpaceLeft (code from Jon Tischler)
    String str
    Variable i, N=strlen(str)
    for (i=0;char2num(str[i])<=32 && i<N;i+=1)    // find first non-white space
    endfor
    return str[i,Inf]
End

// ==================================================================

Function/T   TrimWSR(str)
    // TrimWhiteSpaceRight (code from Jon Tischler)
    String str
    Variable i
    for (i=strlen(str)-1; char2num(str[i])<=32 && i>=0; i-=1)    // find last non-white space
    endfor
    return str[0,i]
End

// ==================================================================
// Turn the ";" separated node path list returned by IN2G_XMLlistXpath into the same
// M_listXPath text wave the XMLutils XOP used to create in the current data folder:
//		[i][0]	full indexed node path, e.g. "/SASroot[1]/SASentry[1]/SASdata[1]"
//		[i][1]	local element name, e.g. "SASdata"
// ==================================================================

Function CS_XMLxpathList2Wave(str)
	String str

	variable nItems = ItemsInList(str, ";")
	MAKE/O/T/N=(max(nItems,1),2) M_listXPath
	WAVE/T M_listXPath
	if(nItems<1)
		Redimension/N=(0,2) M_listXPath
		return 0
	endif

	variable i, lastSlash, br
	string path, name
	for(i=0; i<nItems; i+=1)
		path = StringFromList(i, str, ";")
		M_listXPath[i][0] = path
		lastSlash = strsearch(path, "/", Inf, 3)		// 3 = reverse, case insensitive
		name = SelectString(lastSlash>=0, path, path[lastSlash+1, Inf])
		br = strsearch(name, "[", 0)
		if(br>=0)
			name = name[0, br-1]						// drop the [n] sibling index
		endif
		M_listXPath[i][1] = name
	endfor

	return nItems
End

// ==================================================================
// ==================================================================
// ==================================================================


Function prj_grabMyXmlData()
	STRING srcDir = "root:Packages:CS_XMLreader"
	STRING destDir = "root:PRJ_canSAS"
	STRING srcFolder, destFolder, theFolder
	Variable i
	NewDataFolder/O  $destDir		// for all my imported data
	for( i = 0; i < CountObjects(srcDir, 4) ; i += 1 )
		theFolder = GetIndexedObjName(srcDir, 4, i)
		srcFolder = srcDir + ":" + theFolder
		destFolder = destDir + ":" + theFolder
		// PRINT srcFolder, destFolder
		if(DataFolderExists(destFolder))
			// !!!!!!!!!!!!!!!!! NOTE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			// need to find unique name for destination
			// Persons who implement this properly should be more elegant
			// For now, I will blast the existing and proceed blindly.
			KillDataFolder/Z  $destFolder		// clear out any previous work
			DuplicateDataFolder $srcFolder, $destFolder
		else
			DuplicateDataFolder $srcFolder, $destFolder
		endif
	endfor
End

Function prjTest_cansas1d()
	// unit tests for the routines under prj-readXML.ipf
	STRING theFile
	STRING fList = ""
	VARIABLE i, result, timerID, seconds
	// build a table of test data sets
	fList = AddListItem("elmo.xml", 				fList, ";", Inf)		// non-existent file
	fList = AddListItem("cansasXML.ipf", 			fList, ";", Inf)		// this file (should fail on XML parsing)
	fList = AddListItem("../examples/book.xml", 				fList, ";", Inf)		// good XML example file but not canSAS, not even close
	fList = AddListItem("../examples/bimodal-test1.xml", 		fList, ";", Inf)		// simple dataset
	fList = AddListItem("../examples/testers/test3.xml",					fList, ";", Inf)		// no number provided for wavelength, others, too
	fList = AddListItem("../examples/ISIS_SANS_Example.xml", 	fList, ";", Inf)		// from S. King, 2008-03-17
	fList = AddListItem("../examples/W1W2.xml", 				fList, ";", Inf)		// from S. King, 2008-03-17
	fList = AddListItem("../examples/ill_sasxml_example.xml", 	fList, ";", Inf)		// from canSAS 2007 meeting, reformatted
	fList = AddListItem("../examples/isis_sasxml_example.xml", 	fList, ";", Inf)		// from canSAS 2007 meeting, reformatted
	fList = AddListItem("../examples/r586.xml", 					fList, ";", Inf)		// from canSAS 2007 meeting, reformatted
	fList = AddListItem("../examples/r597.xml", 					fList, ";", Inf)		// from canSAS 2007 meeting, reformatted
	fList = AddListItem("../examples/xg009036_001.xml", 		fList, ";", Inf)		// foreign elements with other namespaces
	fList = AddListItem("../examples/cs_collagen.xml", 			fList, ";", Inf)		// another simple dataset, bare minimum info
	fList = AddListItem("../examples/cs_collagen_full.xml", 		fList, ";", Inf)		// more Q range than previous
	fList = AddListItem("../examples/cs_af1410.xml", 			fList, ";", Inf)		// multiple SASentry and SASdata elements
	fList = AddListItem("../examples/cs_rr_polymers.xml", 		fList, ";", Inf)		// Round Robin polymer samples from John Barnes @ NIST
	fList = AddListItem("../examples/cansas1d-template.xml", 	fList, ";", Inf)		// multiple SASentry and SASdata elements
	fList = AddListItem("../examples/1998spheres.xml", 			fList, ";", Inf)		// 2 SASentry, few thousand data points each
	fList = AddListItem("../examples/does-not-exist-file.xml", 		fList, ";", Inf)		// non-existent file
	fList = AddListItem("../examples/s81-polyurea.xml", 			fList, ";", Inf)		// polyurea from APS/USAXS/Indra (with extra metadata)
	fList = AddListItem("../examples/GLASSYC_C4G8G9_w_TL.xml", 			fList, ";", Inf)		// from S. King, with transmission spectra
	
	// try to load each data set in the table
	for( i = 0; i < ItemsInList(fList) ; i += 1 )
		theFile = StringFromList(i, fList)					// walk through all test files
		// PRINT "file: ", theFile
		pathInfo home 
		//IF (CS_XmlReader(theFile) == 0)					// did the XML reader return without an error code?
		timerID = StartMStimer
		result = CS_XmlReader(ParseFilePath(5,S_path,"*",0,0) + theFile)
		seconds = StopMSTimer(timerID) * 1.0e-6
		PRINT "\t Completed in ", seconds, " seconds"
		if(result == 0)    // did the XML reader return without an error code?
			prj_grabMyXmlData()						// move the data to my directory
		endif
	endfor
End


Function testCollette()
					// !!!!!!!!!!!!!!!!! NOTE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					//          THIS IS JUST AN EXAMPLE

// suggestions from ISIS users
	// 3.	Loading actual data from LOQ caused some problems. 
	//	Data created by Colette names files with run number. 
	//	When entering full path to load the data if you use "Ö\example\31531.X" Igor will read \3 as a character. 
	//	A simple fix which has worked for this is to use / instead of \ e.g. "Ö\example/31531.X".
	
	//4.	Once data is loaded in Igor it is relatively easy to work with but would be nicer if the SASdata 
	//	was loaded into root directory (named using run number rather than generically as it is at the moment) rather than another folder.
	//This becomes more problematic when two samples are being loaded for comparison. 
	//	Although still relatively easy to work with, changing the folders can lead to mistakes being made.

	//Say, for Run=31531, then Qsas_31531

	CS_XmlReader("../examples/W1W2.XML")
	STRING srcDir = "root:Packages:CS_XMLreader"
	STRING destDir = "root", importFolder, target
	Variable i, j
	for( i = 0; i < CountObjects(srcDir, 4) ; i += 1 )
		SetDataFolder $srcDir
		importFolder = GetIndexedObjName(srcDir, 4, i)
		SetDataFolder $importFolder
		if( EXISTS( "metadata" ) == 1 )
			// looks like a SAS data folder
			WAVE/T metadata
			STRING Run = ""
			for(j = 0; j < DimSize(metadata, 0); j += 1)
				if( CmpStr( "Run", metadata[j][0]) == 0 )
					// get the Run number and "clean" it up a bit
					Run = TrimWS(  ReplaceString("\\", metadata[j][1], "/")  )
					// !!!!!!!!!!!!!!!!! NOTE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					// need to find unique name for destination waves        
					//          THIS IS JUST AN EXAMPLE
					// Persons who implement this properly should be more elegant
					// For now, I will blast any existing and proceed blindly.
					target = "root:Qsas_" + Run
					Duplicate/O Qsas, $target
					target = "root:Isas_" + Run
					Duplicate/O Isas, $target
					if( exists( "Idev" ) == 1 )
						target = "root:Idev_" + Run
						Duplicate/O Idev, $target
					endif
					if( exists( "Qdev" ) == 1 )
						target = "root:Qdev_" + Run
						Duplicate/O Qdev, $target
					endif
					if( exists( "dQw" ) == 1 )
						target = "root:QdQw_" + Run
						Duplicate/O dQw, $target
					endif
					if( exists( "dQl" ) == 1 )
						target = "root:dQl_" + Run
						Duplicate/O dQl, $target
					endif
					if( exists( "Qmean" ) == 1 )
						target = "root:Qmean_" + Run
						Duplicate/O Qmean, $target
					endif
					if( exists( "Shadowfactor" ) == 1 )
						target = "root:Shadowfactor_" + Run
						Duplicate/O Shadowfactor, $target
					endif
					target = "root:metadata_" + Run
					Duplicate/O/T metadata, $target
					BREAK
				endif
			endfor
		endif
	endfor

	SetDataFolder root:
End
