#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.11
#pragma IgorVersion=6.1

// taken from smallangles.net on 02 APR 2010
// changed Function/T to Function/S on (unused) TrimWS functions

// file:	cansasXML.ipf
// author:	Pete R. Jemian <jemian@anl.gov>
// SVN date:	$Date$
// SVN rev.:	$Revision$
// SVN URL:	$HeadURL$
// SVN ID:	$Id$
// purpose:  implement an IgorPro file reader to read the canSAS 1-D reduced SAS data in XML files
//			adheres to the cansas1d/1.0 standard
// readme:    http://www.smallangles.net/wgwiki/index.php/cansas1d_binding_IgorPro
// URL:	http://www.smallangles.net/wgwiki/index.php/cansas1d_documentation
//
// requires:	IgorPro (http://www.wavemetrics.com/)
//				XMLutils - XOP (http://www.igorexchange.com/project/XMLutils)
// provides:  CS_CmlReader(String fileName)
//				all other functions in this file should not be relied upon

// ==================================================================
// CS_XmlReader("bimodal-test1.xml")
// CS_XmlReader("1998spheres.xml")
// CS_XmlReader("xg009036_001.xml")
// CS_XmlReader("s81-polyurea.xml")
// CS_XmlReader("cs_af1410.xml")
//  testCollette();  prjTest_cansas1d()
// ==================================================================


#if( Exists("XmlOpenFile") )
	// BEFORE we do anything else, check that XMLutils XOP is available.


FUNCTION CS_XmlReader(fileName)
	//
	// open a canSAS 1-D reduced SAS XML data file
	//	returns:
	//		0 : successful
	//		-1: XML file not found
	//		-2: root element is not <SASroot> with valid canSAS namespace
	//		-3: <SASroot> version  is not 1.0
	//		-4: no <SASentry> elements
	//		-5: XMLutils XOP needs upgrade
	//		-6: XMLutils XOP not found
	//
	STRING fileName
	STRING origFolder
	STRING workingFolder = "root:Packages:CS_XMLreader"
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
	VARIABLE fileID
	STRING/G errorMsg, xmlFile
	xmlFile = fileName
	fileID = XmlOpenFile(fileName)			// open and parse the XMLfile
	IF ( fileID < 0 )
		SWITCH(fileID)					// fileID holds the return code; check it
			CASE -1:
				errorMsg = fileName + ": failed to parse XML"
			BREAK
			CASE -2:
				errorMsg = fileName + " either not found or cannot be opened for reading"
			BREAK
		ENDSWITCH
		PRINT errorMsg
		SetDataFolder $origFolder
		RETURN(-1)						// could not find file
	ENDIF

	//
	//	test to see if XMLutils has the needed upgrade
	//
	XMLlistXpath(fileID, "/*", "")	
	IF ( EXISTS( "M_listXPath" ) == 0 )
		XmlCloseFile(fileID,0)
		errorMsg = "XMLutils needs an upgrade:  http://www.igorexchange.com/project/XMLutils"
		PRINT errorMsg
		SetDataFolder $origFolder
		RETURN(-5)						// XOPutils needs an upgrade
	ENDIF
	WAVE/T 	M_listXPath

	// check for canSAS namespace string, returns "" if not valid or not found
	STRING/G ns = CS_getDefaultNamespace(fileID)
	IF (strlen(ns) == 0 )
		XmlCloseFile(fileID,0)
		errorMsg = "root element is not <SASroot> with valid canSAS namespace"
		PRINT errorMsg
		SetDataFolder $origFolder
		RETURN(-2)						// root element is not <SASroot> with valid canSAS namespace
	ENDIF
	STRING/G nsPre = "cs:"
	STRING/G nsStr = "cs=" + ns

	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr
	
	STRSWITCH(ns)	
	CASE "cansas1d/1.0":							// version 1.0 of the canSAS 1-D reduced SAS data standard
//		PRINT fileName, "\t\t identified as: cansas1d/1.0 XML file"
		returnCode = CS_1i_parseXml(fileID)			//  This is where the action happens!
		IF (returnCode != 0)
			IF (strlen(errorMsg) == 0)
				errorMsg = "error while parsing the XML"
			ENDIF
			PRINT errorMsg
			XmlCloseFile(fileID,0)
			SetDataFolder $origFolder
			RETURN(returnCode)			// error while parsing the XML
		ENDIF
		BREAK
	CASE "cansas1d/2.0a":						// unsupported
	DEFAULT:							// optional default expression executed
		errorMsg = fileName + ": <SASroot>, namespace (" + ns + ") is not supported"
		PRINT errorMsg
		XmlCloseFile(fileID,0)
		SetDataFolder $origFolder
		RETURN(-3)						// attribute list must include version="1.0"
	ENDSWITCH

	XmlCloseFile(fileID,0)					// now close the file, without saving
	fileID = -1

	SetDataFolder root:Packages:CS_XMLreader
	KillWaves/Z M_listXPath, SASentryList
	SetDataFolder $origFolder
	RETURN(0)							// execution finished OK
END

FUNCTION/S CS_getDefaultNamespace(fileID)
	// Test here (by guessing) for the various known namespaces.
	// Return the one found in the "schemaLocation" attribute
	// since the XMLutils XOP does not provide any xmlns attributes.
	// It is possible to call XMLelemList and get the namespace directly
	// but that call can be expensive (time) when there are lots of elements.
	VARIABLE fileID
	STRING ns = "", thisLocation
	VARIABLE i, item
	MAKE/T/N=(1)/O nsList		// list of all possible namespaces
	nsList[0] = "cansas1d/1.0"		// first version of canSAS 1-D reduced SAS

	FOR (item = 0; item < DimSize(nsList, 0); item += 1)		// loop over all possible namespaces
		XMLlistAttr(fileID, "/cs:SASroot", "cs="+nsList[item])
		WAVE/T M_listAttr
		FOR (i = 0; i < DimSize(M_listAttr,0); i+=1)			// loop over all available attributes
			// Expect the required canSAS XML header (will fail if "schemalocation" is not found)
			IF ( CmpStr(  LowerStr(M_listAttr[i][1]),  LowerStr("schemaLocation") ) == 0 )
				thisLocation = TrimWS(M_listAttr[i][2])
				IF ( StringMatch(thisLocation, nsList[item] + "*") )
					ns = nsList[item]
					BREAK		// found it!
				ENDIF
			ENDIF
		ENDFOR
		IF (strlen(ns))
			BREAK		// found it!
		ENDIF
	ENDFOR

	KillWaves/Z nsList, M_listAttr
	RETURN ns
END

// ==================================================================

FUNCTION CS_1i_parseXml(fileID)
	VARIABLE fileID
	SVAR errorMsg, xmlFile
	STRING/G Title, Title_folder
	VARIABLE i, j, index, SASdata_index, returnCode = 0

	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr

	// locate all the SASentry elements
	//	assume nsPre = "cs" otherwise
	// "/"+nsPre+":SASroot//"+nsPre+":SASentry"
	XmlListXpath(fileID, "/cs:SASroot//cs:SASentry", nsStr)
	WAVE/T 	M_listXPath
	STRING		SASentryPath
	DUPLICATE/O/T	M_listXPath, SASentryList

	FOR (i=0; i < DimSize(SASentryList, 0); i += 1)
		SASentryPath = "/cs:SASroot/cs:SASentry["+num2str(i+1)+"]"
		SetDataFolder root:Packages:CS_XMLreader
		
		title =  CS_1i_locateTitle(fileID, SASentryPath)
		Title_folder = CS_cleanFolderName(Title)
		NewDataFolder/O/S  $Title_folder

		XmlListXpath(fileID, SASentryPath + "//cs:SASdata", nsStr)
		WAVE/T 	M_listXPath
		IF ( DimSize(M_listXPath, 0) == 1)
			CS_1i_getOneSASdata(fileID, Title, SASentryPath+"/cs:SASdata")
			CS_1i_collectMetadata(fileID, SASentryPath)
		ELSE
			FOR (j = 0; j < DimSize(M_listXPath, 0); j += 1)
				// Could make this new behavior optional
				STRING SASdata_item = "SASdata_" + num2str(j)
				STRING SASdata_node = SASentryPath+"/cs:SASdata["+num2str(j+1)+"]"
				// Preferred name obtained from the SASentry/SASdata/@name attribute, if present
				STRING SASdata_name = XMLstrFmXpath(fileID,  SASdata_node + "/@name", nsStr, "")
				IF (strlen(SASdata_name) == 0)
					IF (DimSize(M_listXPath, 0) == 1)
						// Alternative if only one SASdata block is to use the SASentry/Title
						SASdata_name = XMLstrFmXpath(fileID,  SASentryPath+"/cs:Title", nsStr, "")
					ELSE
						// the original behavior: SASdata_0, SASdata_1, ...
						SASdata_name = SASdata_item
					ENDIF
					// the original behavior: SASdata_0, SASdata_1, ...
					SASdata_name = SASdata_item
				ENDIF
				STRING SASdataFolder = CS_cleanFolderName(SASdata_name)
				NewDataFolder/O/S  $SASdataFolder
				CS_1i_getOneSASdata(fileID, Title, SASdata_node)
				CS_1i_collectMetadata(fileID, SASentryPath)
				SetDataFolder ::			// back up to parent directory
			ENDFOR
		ENDIF
		KillWaves/Z M_listXPath
	ENDFOR

	SetDataFolder root:Packages:CS_XMLreader
	KillWaves/Z M_listXPath, SASentryList
	RETURN(returnCode)
END

// ==================================================================

FUNCTION/S CS_cleanFolderName(proposal)
	STRING proposal
	STRING result
	result = CleanupName(proposal, 0)
	IF ( CheckName(result, 11) != 0 )
		result = UniqueName(result, 11, 0)
	ENDIF
	RETURN result
END

// ==================================================================

FUNCTION CS_1i_getOneSASdata(fileID, Title, SASdataPath)
	VARIABLE fileID
	STRING Title, SASdataPath
	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr
	VARIABLE i
	STRING SASdata_name, suffix = ""

	//grab the data and put it in the working data folder
	CS_1i_GetReducedSASdata(fileID, SASdataPath)

	//start the metadata
	MAKE/O/T/N=(0,2) metadata

	SVAR xmlFile = root:Packages:CS_XMLreader:xmlFile
	CS_appendMetaData(fileID, "xmlFile", "", xmlFile)

	SVAR ns = root:Packages:CS_XMLreader:ns
	CS_appendMetaData(fileID, "namespace", "", ns)
	CS_appendMetaData(fileID, "Title", "", Title)
	
	XmlListXpath(fileID, SASdataPath + "/..//cs:Run", nsStr)
	WAVE/T 	M_listXPath
	FOR (i=0; i < DimSize(M_listXPath, 0); i += 1)
		IF ( DimSize(M_listXPath, 0) > 1 )
			suffix = "_" + num2str(i)
		ENDIF
		CS_appendMetaData(fileID, "Run" + suffix,  SASdataPath + "/../cs:Run["+num2str(i+1)+"]", "")
		CS_appendMetaData(fileID, "Run/@name" + suffix,  SASdataPath + "/../cs:Run["+num2str(i+1)+"]/@name", "")
	ENDFOR

	SASdata_name = TrimWS(XMLstrFmXpath(fileID,  SASdataPath + "/@name", nsStr, ""))
	CS_appendMetaData(fileID, "SASdata/@name", "", SASdata_name)

	KillWaves/Z M_listXPath
END

// ==================================================================

FUNCTION CS_1i_getOneVector(file,prefix,XML_name,Igor_name)
	VARIABLE file
	STRING prefix,XML_name,Igor_name
	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr

	XmlWaveFmXpath(file,prefix+XML_name,nsStr,"")			//this loads ALL the vector's nodes at the same time
	WAVE/T M_xmlcontent
	WAVE/T W_xmlContentNodes
	IF (DimSize(M_xmlcontent, 0))			// test to see if the nodes exist.  not strictly necessary if you know the nodes are there
		IF (DimSize(M_xmlcontent,1)>DimSize(M_xmlcontent,0))	//if you're not in vector mode
			MatrixTranspose M_xmlcontent
		ENDIF
		MAKE/O/D/N=(DimSize(M_xmlcontent, 0)) $Igor_name
		WAVE vect = $Igor_name
		vect=str2num(M_xmlcontent)
	ENDIF
	KILLWAVES/Z M_xmlcontent, W_xmlContentNodes
END

// ==================================================================

FUNCTION CS_1i_GetReducedSASdata(fileID, SASdataPath)
	VARIABLE fileID
	STRING SASdataPath
	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr
	STRING prefix = ""
	VARIABLE pos

	VARIABLE cansasStrict = 1		// !!!software developer's choice!!!
	IF (cansasStrict)		// only get known canSAS data vectors
		prefix = SASdataPath + "//cs:"
		// load ALL nodes of each vector (if exists) at the same time
		CS_1i_getOneVector(fileID, prefix, "Q", 		"Qsas")
		CS_1i_getOneVector(fileID, prefix, "I", 		"Isas")
		CS_1i_getOneVector(fileID, prefix, "Idev", 		"Idev")
		CS_1i_getOneVector(fileID, prefix, "Qdev",		"Qdev")
		CS_1i_getOneVector(fileID, prefix, "dQw", 	"dQw")
		CS_1i_getOneVector(fileID, prefix, "dQl", 		"dQl")
		CS_1i_getOneVector(fileID, prefix, "Qmean",	"Qmean")
		CS_1i_getOneVector(fileID, prefix, "Shadowfactor", 	"Shadowfactor")
		// check them for common length
	ELSE				// search for _ANY_ data vectors
		// find the names of all the data columns and load them as vectors
	 	// this gets tricky if we want to avoid namespace references
		XmlListXpath(fileID, SASdataPath+"//cs:Idata[1]/*", nsStr)
		WAVE/T M_listXPath
		STRING xmlElement, xPathStr
		STRING igorWave
		VARIABLE j
		FOR (j = 0; j < DimSize(M_listXPath, 0); j += 1)	// loop over all columns in SASdata/Idata[1]
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
//			// This will need some work to support foreign namespaces here
//			//
//			//
//			xPathStr = M_listXPath[j][0]							// clear name reference
//			pos = strsearch(xPathStr, "/", Inf, 3)					// peel off the tail of the string and reform
//			xmlElement = xPathStr[pos,Inf]						// find last element on the path
//			prefix = xPathStr[0, pos-1-4]+"/*"						// ALL Idata elements
//			CS_1i_getOneVector(fileID,prefix, xmlElement, igorWave)		// loads ALL rows (Idata) of the column at the same time
			//
			//  Could there be a problem with a foreign namespace here?
			prefix = SASdataPath+"//cs:Idata"						// ALL Idata elements
			xmlElement = "cs:" + M_listXPath[j][1]					// just this column
			CS_1i_getOneVector(fileID,prefix, xmlElement, igorWave)		// loads ALL rows (Idata) of the column at the same time
		ENDFOR
		// check them for common length
	ENDIF
 
	//get rid of any mess
	KILLWAVES/z M_listXPath
END

// ==================================================================

FUNCTION CS_1i_collectMetadata(fileID, sasEntryPath)
	VARIABLE fileID
	STRING sasEntryPath
	VARIABLE i, j
	WAVE/T metadata
	STRING suffix = "", preMeta = "", preXpath = ""
	STRING value, detailsPath, detectorPath, notePath

	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr

	// collect some metadata
	// first, fill a table with keywords, and XPath locations, 3rd column will be values

	// handle most <SASsample> fields
	CS_appendMetaData(fileID, "SASsample/@name",				sasEntryPath + "/cs:SASsample/@name", "")
	CS_appendMetaData(fileID, "SASsample/ID",					sasEntryPath + "/cs:SASsample/cs:ID", "")
	CS_appendMetaData(fileID, "SASsample/thickness",				sasEntryPath + "/cs:SASsample/cs:thickness", "")
	CS_appendMetaData(fileID, "SASsample/thickness/@unit",  		sasEntryPath + "/cs:SASsample/cs:thickness/@unit", "")
	CS_appendMetaData(fileID, "SASsample/transmission",			sasEntryPath + "/cs:SASsample/cs:transmission", "")
	CS_appendMetaData(fileID, "SASsample/temperature",			sasEntryPath + "/cs:SASsample/cs:temperature", "")
	CS_appendMetaData(fileID, "SASsample/temperature/@unit",	   sasEntryPath + "/cs:SASsample/cs:temperature/@unit", "")
	CS_appendMetaData(fileID, "SASsample/position/x",			   sasEntryPath + "/cs:SASsample/cs:position/cs:x", "")
	CS_appendMetaData(fileID, "SASsample/position/x/@unit", 	   sasEntryPath + "/cs:SASsample/cs:position/cs:x/@unit", "")
	CS_appendMetaData(fileID, "SASsample/position/y",			   sasEntryPath + "/cs:SASsample/cs:position/cs:y", "")
	CS_appendMetaData(fileID, "SASsample/position/y/@unit", 	   sasEntryPath + "/cs:SASsample/cs:position/cs:y/@unit", "")
	CS_appendMetaData(fileID, "SASsample/position/z",			   sasEntryPath + "/cs:SASsample/cs:position/cs:z", "")
	CS_appendMetaData(fileID, "SASsample/position/z/@unit", 	   sasEntryPath + "/cs:SASsample/cs:position/cs:z/@unit", "")
	CS_appendMetaData(fileID, "SASsample/orientation/roll", 		   sasEntryPath + "/cs:SASsample/cs:orientation/cs:roll", "")
	CS_appendMetaData(fileID, "SASsample/orientation/roll/@unit",	   sasEntryPath + "/cs:SASsample/cs:orientation/cs:roll/@unit", "")
	CS_appendMetaData(fileID, "SASsample/orientation/pitch",	   sasEntryPath + "/cs:SASsample/cs:orientation/cs:pitch", "")
	CS_appendMetaData(fileID, "SASsample/orientation/pitch/@unit",     sasEntryPath + "/cs:SASsample/cs:orientation/cs:pitch/@unit", "")
	CS_appendMetaData(fileID, "SASsample/orientation/yaw",  		   sasEntryPath + "/cs:SASsample/cs:orientation/cs:yaw", "")
	CS_appendMetaData(fileID, "SASsample/orientation/yaw/@unit",	   sasEntryPath + "/cs:SASsample/cs:orientation/cs:yaw/@unit", "")
	// <SASsample><details> might appear multiple times, too!
	XmlListXpath(fileID, sasEntryPath+"/cs:SASsample//cs:details", nsStr)	//output: M_listXPath
	WAVE/T 	M_listXPath
	DUPLICATE/O/T   M_listXPath, detailsList
	suffix = ""
	FOR (i = 0; i < DimSize(detailsList, 0); i += 1)
		IF (DimSize(detailsList, 0) > 1)
			suffix = "_" + num2str(i)
		ENDIF
		detailsPath = sasEntryPath+"/cs:SASsample/cs:details["+num2str(i+1)+"]"
		CS_appendMetaData(fileID, "SASsample/details"+suffix+"/@name", 	detailsPath + "/@name", "")
		CS_appendMetaData(fileID, "SASsample/details"+suffix,	 	detailsPath, "")
	ENDFOR


	// <SASinstrument>
	CS_appendMetaData(fileID, "SASinstrument/name",		sasEntryPath + "/cs:SASinstrument/cs:name", "")
	CS_appendMetaData(fileID, "SASinstrument/@name",	sasEntryPath + "/cs:SASinstrument/@name", "")

	// <SASinstrument><SASsource>
	preMeta = "SASinstrument/SASsource"
	preXpath = sasEntryPath + "/cs:SASinstrument/cs:SASsource"
	CS_appendMetaData(fileID, preMeta + "/@name",			   preXpath + "/@name", "")
	CS_appendMetaData(fileID, preMeta + "/radiation",		   preXpath + "/cs:radiation", "")
	CS_appendMetaData(fileID, preMeta + "/beam/size/@name", 	   preXpath + "/cs:beam_size/@name", "")
	CS_appendMetaData(fileID, preMeta + "/beam/size/x",		   preXpath + "/cs:beam_size/cs:x", "")
	CS_appendMetaData(fileID, preMeta + "/beam/size/x@unit",	   preXpath + "/cs:beam_size/cs:x/@unit", "")
	CS_appendMetaData(fileID, preMeta + "/beam/size/y",		   preXpath + "/cs:beam_size/cs:y", "")
	CS_appendMetaData(fileID, preMeta + "/beam/size/y@unit",	   preXpath + "/cs:beam_size/cs:y/@unit", "")
	CS_appendMetaData(fileID, preMeta + "/beam/size/z",		   preXpath + "/cs:beam_size/cs:z", "")
	CS_appendMetaData(fileID, preMeta + "/beam/size/z@unit",	   preXpath + "/cs:beam_size/cs:z/@unit", "")
	CS_appendMetaData(fileID, preMeta + "/beam/shape",		   preXpath + "/cs:beam_shape", "")
	CS_appendMetaData(fileID, preMeta + "/wavelength",		   preXpath + "/cs:wavelength", "")
	CS_appendMetaData(fileID, preMeta + "/wavelength/@unit",	   preXpath + "/cs:wavelength/@unit", "")
	CS_appendMetaData(fileID, preMeta + "/wavelength_min",  	   preXpath + "/cs:wavelength_min", "")
	CS_appendMetaData(fileID, preMeta + "/wavelength_min/@unit",	   preXpath + "/cs:wavelength_min/@unit", "")
	CS_appendMetaData(fileID, preMeta + "/wavelength_max",  	   preXpath + "/cs:wavelength_max", "")
	CS_appendMetaData(fileID, preMeta + "/wavelength_max/@unit",	   preXpath + "/cs:wavelength_max/@unit", "")
	CS_appendMetaData(fileID, preMeta + "/wavelength_spread",	   preXpath + "/cs:wavelength_spread", "")
	CS_appendMetaData(fileID, preMeta + "/wavelength_spread/@unit",    preXpath + "/cs:wavelength_spread/@unit", "")

	// <SASinstrument><SAScollimation> might appear multiple times
	XmlListXpath(fileID, sasEntryPath+"/cs:SASinstrument//cs:SAScollimation", nsStr)	//output: M_listXPath
	WAVE/T 	M_listXPath
	DUPLICATE/O/T   M_listXPath, SAScollimationList
	STRING collimationPath
	FOR (i = 0; i < DimSize(SAScollimationList, 0); i += 1)
		preMeta = "SASinstrument/SAScollimation"
		IF (DimSize(SAScollimationList, 0) > 1)
			preMeta += "_" + num2str(i)
		ENDIF
		collimationPath = sasEntryPath+"/cs:SASinstrument/cs:SAScollimation["+num2str(i+1)+"]"
		CS_appendMetaData(fileID, preMeta + "/@name",		    collimationPath + "/@name", "")
		CS_appendMetaData(fileID, preMeta + "/length",		    collimationPath + "/cs:length", "")
		CS_appendMetaData(fileID, preMeta + "/length_unit",	    collimationPath + "/cs:length/@unit", "")
		FOR (j = 0; j < DimSize(M_listXPath, 0); j += 1)	// aperture may be repeated!
			IF (DimSize(M_listXPath, 0) == 1)
				preMeta = "SASinstrument/SAScollimation/aperture"
			ELSE
				preMeta = "SASinstrument/SAScollimation/aperture_" + num2str(j)
			ENDIF
			preXpath = collimationPath + "/cs:aperture["+num2str(j+1)+"]"
			CS_appendMetaData(fileID, preMeta + "/@name",	      preXpath + "/@name", "")
			CS_appendMetaData(fileID, preMeta + "/type",	      preXpath + "/cs:type", "")
			CS_appendMetaData(fileID, preMeta + "/size/@name",     preXpath + "/cs:size/@name", "")
			CS_appendMetaData(fileID, preMeta + "/size/x",	      preXpath + "/cs:size/cs:x", "")
			CS_appendMetaData(fileID, preMeta + "/size/x/@unit",   preXpath + "/cs:size/cs:x/@unit", "")
			CS_appendMetaData(fileID, preMeta + "/size/y",	      preXpath + "/cs:size/cs:y", "")
			CS_appendMetaData(fileID, preMeta + "/size/y/@unit",   preXpath + "/cs:size/cs:y/@unit", "")
			CS_appendMetaData(fileID, preMeta + "/size/z",	      preXpath + "/cs:size/cs:z", "")
			CS_appendMetaData(fileID, preMeta + "/size/z/@unit",   preXpath + "/cs:size/cs:z/@unit", "")
			CS_appendMetaData(fileID, preMeta + "/distance",       preXpath + "/cs:distance", "")
			CS_appendMetaData(fileID, preMeta + "/distance/@unit", preXpath + "/cs:distance/@unit", "")
		ENDFOR
	ENDFOR

	// <SASinstrument><SASdetector> might appear multiple times
	XmlListXpath(fileID, sasEntryPath+"/cs:SASinstrument//cs:SASdetector", nsStr)	//output: M_listXPath
	WAVE/T 	M_listXPath
	DUPLICATE/O/T   M_listXPath, SASdetectorList
	FOR (i = 0; i < DimSize(SASdetectorList, 0); i += 1)
		preMeta = "SASinstrument/SASdetector"
		IF (DimSize(SASdetectorList, 0) > 1)
			preMeta += "_" + num2str(i)
		ENDIF
		detectorPath = sasEntryPath+"/cs:SASinstrument/cs:SASdetector["+num2str(i+1)+"]"
		CS_appendMetaData(fileID, preMeta + "/@name",			 detectorPath + "/cs:name", "")
		CS_appendMetaData(fileID, preMeta + "/SDD",				 detectorPath + "/cs:SDD", "")
		CS_appendMetaData(fileID, preMeta + "/SDD/@unit",			 detectorPath + "/cs:SDD/@unit", "")
		CS_appendMetaData(fileID, preMeta + "/offset/@name",		 detectorPath + "/cs:offset/@name", "")
		CS_appendMetaData(fileID, preMeta + "/offset/x", 		 detectorPath + "/cs:offset/cs:x", "")
		CS_appendMetaData(fileID, preMeta + "/offset/x/@unit",		 detectorPath + "/cs:offset/cs:x/@unit", "")
		CS_appendMetaData(fileID, preMeta + "/offset/y", 		 detectorPath + "/cs:offset/cs:y", "")
		CS_appendMetaData(fileID, preMeta + "/offset/y/@unit",		 detectorPath + "/cs:offset/cs:y/@unit", "")
		CS_appendMetaData(fileID, preMeta + "/offset/z", 		 detectorPath + "/cs:offset/cs:z", "")
		CS_appendMetaData(fileID, preMeta + "/offset/z/@unit",		 detectorPath + "/cs:offset/cs:z/@unit", "")

		CS_appendMetaData(fileID, preMeta + "/orientation/@name",	 detectorPath + "/cs:orientation/@name", "")
		CS_appendMetaData(fileID, preMeta + "/orientation/roll", 	 detectorPath + "/cs:orientation/cs:roll", "")
		CS_appendMetaData(fileID, preMeta + "/orientation/roll/@unit",	 detectorPath + "/cs:orientation/cs:roll/@unit", "")
		CS_appendMetaData(fileID, preMeta + "/orientation/pitch",	 detectorPath + "/cs:orientation/cs:pitch", "")
		CS_appendMetaData(fileID, preMeta + "/orientation/pitch/@unit",   detectorPath + "/cs:orientation/cs:pitch/@unit", "")
		CS_appendMetaData(fileID, preMeta + "/orientation/yaw",  	 detectorPath + "/cs:orientation/cs:yaw", "")
		CS_appendMetaData(fileID, preMeta + "/orientation/yaw/@unit",	 detectorPath + "/cs:orientation/cs:yaw/@unit", "")

		CS_appendMetaData(fileID, preMeta + "/beam_center/@name",	 detectorPath + "/cs:beam_center/@name", "")
		CS_appendMetaData(fileID, preMeta + "/beam_center/x",		 detectorPath + "/cs:beam_center/cs:x", "")
		CS_appendMetaData(fileID, preMeta + "/beam_center/x/@unit",	 detectorPath + "/cs:beam_center/cs:x/@unit", "")
		CS_appendMetaData(fileID, preMeta + "/beam_center/y",		 detectorPath + "/cs:beam_center/cs:y", "")
		CS_appendMetaData(fileID, preMeta + "/beam_center/y/@unit",	 detectorPath + "/cs:beam_center/cs:y/@unit", "")
		CS_appendMetaData(fileID, preMeta + "/beam_center/z",		 detectorPath + "/cs:beam_center/cs:z", "")
		CS_appendMetaData(fileID, preMeta + "/beam_center/z/@unit",	 detectorPath + "/cs:beam_center/cs:z/@unit", "")

		CS_appendMetaData(fileID, preMeta + "/pixel_size/@name", 	 detectorPath + "/cs:pixel_size/@name", "")
		CS_appendMetaData(fileID, preMeta + "/pixel_size/x",		 detectorPath + "/cs:pixel_size/cs:x", "")
		CS_appendMetaData(fileID, preMeta + "/pixel_size/x/@unit",	 detectorPath + "/cs:pixel_size/cs:x/@unit", "")
		CS_appendMetaData(fileID, preMeta + "/pixel_size/y",		 detectorPath + "/cs:pixel_size/cs:y", "")
		CS_appendMetaData(fileID, preMeta + "/pixel_size/y/@unit",	 detectorPath + "/cs:pixel_size/cs:y/@unit", "")
		CS_appendMetaData(fileID, preMeta + "/pixel_size/z",		 detectorPath + "/cs:pixel_size/cs:z", "")
		CS_appendMetaData(fileID, preMeta + "/pixel_size/z/@unit",	 detectorPath + "/cs:pixel_size/cs:z/@unit", "")

		CS_appendMetaData(fileID, preMeta + "/slit_length",		       detectorPath + "/cs:slit_length", "")
		CS_appendMetaData(fileID, preMeta + "/slit_length/@unit",	       detectorPath + "/cs:slit_length/@unit", "")
	ENDFOR

	// <SASprocess> might appear multiple times
	XmlListXpath(fileID, sasEntryPath+"//cs:SASprocess", nsStr)	//output: M_listXPath
	WAVE/T 	M_listXPath
	DUPLICATE/O/T   M_listXPath, SASprocessList
	STRING SASprocessPath, prefix
	FOR (i = 0; i < DimSize(SASprocessList, 0); i += 1)
		preMeta = "SASprocess"
		IF (DimSize(SASprocessList, 0) > 1)
			preMeta += "_" + num2str(i)
		ENDIF
		SASprocessPath = sasEntryPath+"/cs:SASprocess["+num2str(i+1)+"]"
		CS_appendMetaData(fileID, preMeta+"/@name",	   SASprocessPath + "/@name", "")
		CS_appendMetaData(fileID, preMeta+"/name",	   SASprocessPath + "/cs:name", "")
		CS_appendMetaData(fileID, preMeta+"/date",		   SASprocessPath + "/cs:date", "")
		CS_appendMetaData(fileID, preMeta+"/description",   SASprocessPath + "/cs:description", "")
		XmlListXpath(fileID, SASprocessPath+"//cs:term", nsStr)
		FOR (j = 0; j < DimSize(M_listXPath, 0); j += 1)
			prefix = SASprocessPath + "/cs:term[" + num2str(j+1) + "]"
			CS_appendMetaData(fileID, preMeta+"/term_"+num2str(j)+"/@name",     prefix + "/@name", "")
			CS_appendMetaData(fileID, preMeta+"/term_"+num2str(j)+"/@unit",  	  prefix + "/@unit", "")
			CS_appendMetaData(fileID, preMeta+"/term_"+num2str(j),				  prefix, "")
		ENDFOR
		// ignore <SASprocessnote>
	ENDFOR

	// <SASnote> might appear multiple times
	XmlListXpath(fileID, sasEntryPath+"//cs:SASnote", nsStr)	//output: M_listXPath
	WAVE/T 	M_listXPath
	DUPLICATE/O/T   M_listXPath, SASnoteList
	FOR (i = 0; i < DimSize(SASnoteList, 0); i += 1)
		preMeta = "SASnote"
		IF (DimSize(SASnoteList, 0) > 1)
			preMeta += "_" + num2str(i)
		ENDIF
		notePath = sasEntryPath+"//cs:SASnote["+num2str(i+1)+"]"
		CS_appendMetaData(fileID, preMeta+"/@name", 	notePath + "/@name", "")
		CS_appendMetaData(fileID, preMeta,		notePath, "")
	ENDFOR

	KillWaves/Z M_listXPath, detailsList, SAScollimationList, SASdetectorList, SASprocessList, SASnoteList
END

// ==================================================================

FUNCTION/S CS_1i_locateTitle(fileID, SASentryPath)
	VARIABLE fileID
	STRING SASentryPath
	STRING TitlePath, Title
	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr

	// /cs:SASroot/cs:SASentry/cs:Title is the expected location, but it could be empty
	TitlePath = SASentryPath + "/cs:Title"
	Title = XMLstrFmXpath(fileID,  TitlePath, nsStr, "")
	// search harder for a title
	IF (strlen(Title) == 0)
		TitlePath = SASentryPath + "/@name"
		Title = XMLstrFmXpath(fileID,  TitlePath, nsStr, "")
	ENDIF
	IF (strlen(Title) == 0)
		TitlePath = SASentryPath + "/cs:SASsample/cs:ID"
		Title = XMLstrFmXpath(fileID,  TitlePath, nsStr, "")
	ENDIF
	IF (strlen(Title) == 0)
		TitlePath = SASentryPath + "/cs:SASsample/@name"
		Title = XMLstrFmXpath(fileID,  TitlePath, nsStr, "")
	ENDIF
	IF (strlen(Title) == 0)
		// last resort: make up a title
		Title = "SASentry"
		TitlePath = ""
	ENDIF
//	PRINT "\t Title:", Title
	RETURN(Title)
END

// ==================================================================

FUNCTION CS_appendMetaData(fileID, key, xpath, value)
	VARIABLE fileID
	STRING key, xpath, value
	WAVE/T metadata
	STRING k, v

	SVAR nsPre = root:Packages:CS_XMLreader:nsPre
	SVAR nsStr = root:Packages:CS_XMLreader:nsStr

	k = TrimWS(key)
	IF (  strlen(k) > 0 )
		IF ( strlen(xpath) > 0 )
			value = XMLstrFmXpath(fileID,  xpath, nsStr, "")
		ENDIF
		// What if the value string has a ";" embedded?
		//  This could complicate (?compromise?) the wavenote "key=value;" syntax.
		//  But let the caller deal with it.
		v = TrimWS(ReplaceString(";", value, " :semicolon: "))
		IF ( strlen(v) > 0 )
			VARIABLE last
			last = DimSize(metadata, 0)
			Redimension/N=(last+1, 2) metadata
			metadata[last][0] = k
			metadata[last][1] = v
		ENDIF
	ENDIF
END

// ==================================================================

Function/S   TrimWS(str)
    // TrimWhiteSpace (code from Jon Tischler)
    String str
    return TrimWSL(TrimWSR(str))
End

// ==================================================================

Function/S   TrimWSL(str)
    // TrimWhiteSpaceLeft (code from Jon Tischler)
    String str
    Variable i, N=strlen(str)
    for (i=0;char2num(str[i])<=32 && i<N;i+=1)    // find first non-white space
    endfor
    return str[i,Inf]
End

// ==================================================================

Function/S   TrimWSR(str)
    // TrimWhiteSpaceRight (code from Jon Tischler)
    String str
    Variable i
    for (i=strlen(str)-1; char2num(str[i])<=32 && i>=0; i-=1)    // find last non-white space
    endfor
    return str[0,i]
End

// ==================================================================
// ==================================================================
// ==================================================================


FUNCTION prj_grabMyXmlData()
	STRING srcDir = "root:Packages:CS_XMLreader"
	STRING destDir = "root:PRJ_canSAS"
	STRING srcFolder, destFolder, theFolder
	Variable i
	NewDataFolder/O  $destDir		// for all my imported data
	FOR ( i = 0; i < CountObjects(srcDir, 4) ; i += 1 )
		theFolder = GetIndexedObjName(srcDir, 4, i)
		srcFolder = srcDir + ":" + theFolder
		destFolder = destDir + ":" + theFolder
		// PRINT srcFolder, destFolder
		IF (DataFolderExists(destFolder))
			// !!!!!!!!!!!!!!!!! NOTE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
			// need to find unique name for destination
			// Persons who implement this properly should be more elegant
			// For now, I will blast the existing and proceed blindly.
			KillDataFolder/Z  $destFolder		// clear out any previous work
			DuplicateDataFolder $srcFolder, $destFolder
		ELSE
			DuplicateDataFolder $srcFolder, $destFolder
		ENDIF
	ENDFOR
END

FUNCTION prjTest_cansas1d()
	// unit tests for the routines under prj-readXML.ipf
	STRING theFile
	STRING fList = ""
	VARIABLE i, result, timerID, seconds
	// build a table of test data sets
	fList = AddListItem("elmo.xml", 				fList, ";", Inf)		// non-existent file
	fList = AddListItem("cansasXML.ipf", 			fList, ";", Inf)		// this file (should fail on XML parsing)
	fList = AddListItem("book.xml", 				fList, ";", Inf)		// good XML example file but not canSAS, not even close
	fList = AddListItem("bimodal-test1.xml", 		fList, ";", Inf)		// simple dataset
	fList = AddListItem("bimodal-test2-vector.xml",	fList, ";", Inf)		// version 2.0 file (no standard yet)
	fList = AddListItem("test.xml",					fList, ";", Inf)		// cs_collagen.xml with no namespace
	fList = AddListItem("test2.xml", 				fList, ";", Inf)		// version 2.0 file (no standard yet)
	fList = AddListItem("ISIS_SANS_Example.xml", 	fList, ";", Inf)		// from S. King, 2008-03-17
	fList = AddListItem("W1W2.xml", 				fList, ";", Inf)		// from S. King, 2008-03-17
	fList = AddListItem("ill_sasxml_example.xml", 	fList, ";", Inf)		// from canSAS 2007 meeting, reformatted
	fList = AddListItem("isis_sasxml_example.xml", 	fList, ";", Inf)		// from canSAS 2007 meeting, reformatted
	fList = AddListItem("r586.xml", 					fList, ";", Inf)		// from canSAS 2007 meeting, reformatted
	fList = AddListItem("r597.xml", 					fList, ";", Inf)		// from canSAS 2007 meeting, reformatted
	fList = AddListItem("xg009036_001.xml", 		fList, ";", Inf)		// foreign elements with other namespaces
	fList = AddListItem("cs_collagen.xml", 			fList, ";", Inf)		// another simple dataset, bare minimum info
	fList = AddListItem("cs_collagen_full.xml", 		fList, ";", Inf)		// more Q range than previous
	fList = AddListItem("cs_af1410.xml", 			fList, ";", Inf)		// multiple SASentry and SASdata elements
	fList = AddListItem("cansas1d-template.xml", 	fList, ";", Inf)		// multiple SASentry and SASdata elements
	fList = AddListItem("1998spheres.xml", 			fList, ";", Inf)		// 2 SASentry, few thousand data points each
	fList = AddListItem("does-not-exist-file.xml", 		fList, ";", Inf)		// non-existent file
	fList = AddListItem("cs_rr_polymers.xml", 		fList, ";", Inf)		// Round Robin polymer samples from John Barnes @ NIST
	fList = AddListItem("s81-polyurea.xml", 			fList, ";", Inf)		// polyurea from APS/USAXS/Indra (with extra metadata)
	
	// try to load each data set in the table
	FOR ( i = 0; i < ItemsInList(fList) ; i += 1 )
		theFile = StringFromList(i, fList)					// walk through all test files
		// PRINT "file: ", theFile
		pathInfo home 
		//IF (CS_XmlReader(theFile) == 0)					// did the XML reader return without an error code?
		timerID = StartMStimer
		result = CS_XmlReader(ParseFilePath(5,S_path,"*",0,0) + theFile)
		seconds = StopMSTimer(timerID) * 1.0e-6
		PRINT "\t Completed in ", seconds, " seconds"
		IF (result == 0)    // did the XML reader return without an error code?
			prj_grabMyXmlData()						// move the data to my directory
		ENDIF
	ENDFOR
END


FUNCTION testCollette()
					// !!!!!!!!!!!!!!!!! NOTE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
					//          THIS IS JUST AN EXAMPLE

// suggestions from ISIS users
	// 3.	Loading actual data from LOQ caused some problems. 
	//	Data created by Colette names files with run number. 
	//	When entering full path to load the data if you use "\example\31531.X" Igor will read \3 as a character. 
	//	A simple fix which has worked for this is to use / instead of \ e.g. "\example/31531.X".
	
	//4.	Once data is loaded in Igor it is relatively easy to work with but would be nicer if the SASdata 
	//	was loaded into root directory (named using run number rather than generically as it is at the moment) rather than another folder.
	//This becomes more problematic when two samples are being loaded for comparison. 
	//	Although still relatively easy to work with, changing the folders can lead to mistakes being made.

	//Say, for Run=31531, then Qsas_31531

	CS_XmlReader("W1W2.XML")
	STRING srcDir = "root:Packages:CS_XMLreader"
	STRING destDir = "root", importFolder, target
	Variable i, j
	FOR ( i = 0; i < CountObjects(srcDir, 4) ; i += 1 )
		SetDataFolder $srcDir
		importFolder = GetIndexedObjName(srcDir, 4, i)
		SetDataFolder $importFolder
		IF ( EXISTS( "metadata" ) == 1 )
			// looks like a SAS data folder
			WAVE/T metadata
			STRING Run = ""
			FOR (j = 0; j < DimSize(metadata, 0); j += 1)
				IF ( CmpStr( "Run", metadata[j][0]) == 0 )
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
					IF ( exists( "Idev" ) == 1 )
						target = "root:Idev_" + Run
						Duplicate/O Idev, $target
					ENDIF
					IF ( exists( "Qdev" ) == 1 )
						target = "root:Qdev_" + Run
						Duplicate/O Qdev, $target
					ENDIF
					IF ( exists( "dQw" ) == 1 )
						target = "root:QdQw_" + Run
						Duplicate/O dQw, $target
					ENDIF
					IF ( exists( "dQl" ) == 1 )
						target = "root:dQl_" + Run
						Duplicate/O dQl, $target
					ENDIF
					IF ( exists( "Qmean" ) == 1 )
						target = "root:Qmean_" + Run
						Duplicate/O Qmean, $target
					ENDIF
					IF ( exists( "Shadowfactor" ) == 1 )
						target = "root:Shadowfactor_" + Run
						Duplicate/O Shadowfactor, $target
					ENDIF
					target = "root:metadata_" + Run
					Duplicate/O/T metadata, $target
					BREAK
				ENDIF
			ENDFOR
		ENDIF
	ENDFOR

	SetDataFolder root:
END

#else	// if( Exists("XmlOpenFile") )
	// No XMLutils XOP: provide dummy function so that IgorPro can compile dependent support code
	FUNCTION CS_XmlReader(fileName)
	    String fileName
	    Abort  "XML function provided by XMLutils XOP is not available, get the XOP from : http://www.igorexchange.com/project/XMLutils (see http://www.smallangles.net/wgwiki/index.php/cansas1d_binding_IgorPro for details)"
	    RETURN(-6)
	END
#endif	// if( Exists("XmlOpenFile") )
