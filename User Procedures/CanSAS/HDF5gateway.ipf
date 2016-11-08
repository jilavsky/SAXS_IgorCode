#pragma rtGlobals=3		// Use modern global access method.

#include <HDF5 Browser>

// requires the Wavemetrics "HDF5.xop" to be installed for IgorPro

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// This file is part of a project hosted at the Advanced Photon Source.
// Access all the source files and data files by checking out the project here:
//   git clone https://github.com/prjemian/hdf5gateway.git
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// The documentation is written in restructured text for use by Sphinx.
//
// :doc: http://hdf5gateway.readthedocs.org/
//
// A python program will read this file and grab all the text between lines
// beginning with "//@+" and "//@-" that begin with "//\t" and use them for the Sphinx documentation.
// The tables here have been adjusted for a fixed width font.  Don't "fix" them in Igor!

//@+
//	============================================================
//	HDF5gateway: HDF5 File I/O Support
//	============================================================
//	
//	Version: 1.0
//	
//	HDF5gateway makes it easy to read 
//	a HDF5 file into an IgorPro folder,
//	including group and dataset attributes,
//	such as a NeXus data file,
//	modify it, and then write it back out.
//	
//	.. index:: goal
//	
//	The goal was to make it easy to read a HDF5 file into an IgorPro folder, 
//	including group and dataset attributes,
//	such as a NeXus data file,
//	modify it, and then write it back out.
//	This file provides functions to do just that.
//	
//	.. index:: functions; public
//	
//	Starting with utilities provided in the *HDF5 Browser* package, this file provides
//	these public functions:
//	
//		* :ref:`H5GW_ReadHDF5`
//		* :ref:`H5GW_WriteHDF5`
//		* :ref:`H5GW_ValidateFolder`
//	
//	and this function which is useful only for testing and development:
//	
//		* :ref:`H5GW_TestSuite`
//	
//	Help is provided with each of these functions to indicate their usage.
//	
//	.. index:: read
//	
//	Reading
//	===========
//	
//	An HDF5 file is read into an IgorPro data folder in these steps:
//	
//	#. The groups and datasets are read and stored into an IgorPro folder.
//	#. Any attributes of these groups and datasets are read and assigned to IgorPro objects.
//	
//	.. index:: DataPath
//	
//	The data file is expected to be in the DataPath folder (the folder specified by IgorPro path passed as DataPath parameter),
//	or relative to that folder, or given by an absolute path name.
//	
//	.. index:: write, HDF5___xref
//	
//	Writing
//	=================
//	
//	An IgorPro data folder is written to an HDF5 file in these steps:
//	
//	#. The IgorPro folder is validated for correct structure.
//	#. The objects in the *HDF5___xref* text wave are written to the HDF5 file.
//	#. Any folder attributes or wave notes are written to the corresponding HDF5 data path.
//	
//	The data file is expected to be in the *home* folder (the folder specified by IgorPro's *home* path),
//	or relative to that folder, or given by an absolute path name.
//	
//	.. index:: validate
//	
//	Validating
//	=================
//	
//	Call :ref:`H5GW_ValidateFolder` to test if the 
//	*parentFolder* in the IgorPro Data Browser has the proper structure to 
//	successfully write out to an HDF5 file by :ref:`H5GW_WriteHDF5`.
//	
//	.. index:: ! HDF5___xref
//	
//	Structure of the *HDF5___xref* text wave
//	=====================================================
//	
//	It is necessary to devise a method to correlate the name 
//	of the same object in the HDF5 file with its representation in
//	the IgorPro data structure.   In IgorPro, certain names are 
//	reserved such that objects cannot be named.  Routines exist
//	to substitute such names on data import to comply with
//	these restrictions.  The routine *HDF5LoadGroup* performs
//	this substitution automatically, yet no routine is provided to
//	describe any name substitutions performed.
//	
//	The text wave, *HDF5___xref*, is created in the base folder of
//	the IgorPro folder structure to describe the mapping between
//	relative IgorPro and HDF5 path names, as shown in the next table.
//	This name was chosen in hopes that it might remain unique
//	and unused by others at the root level HDF5 files.
//	
//		HDF5___xref wave column plan
//		
//		=======   ==================
//		column    description
//		=======   ==================
//		0         HDF5 path
//		1         Igor relative path
//		=======   ==================
//	
//		**Example**
//		
//		Consider the HDF5 file with datasets stored in this structure:
//	
//		.. code-block:: guess
//			:linenos:
//			
//			/
//			  /sasentry01
//			    /sasdata01
//			      I
//			      Q
//	
//		The next table shows the contents of *HDF5___xref* once this
//		HDF5 is read by *H5GW_WriteHDF5()*:
//		
//		===  =======================  ==========================
//		row  ``HDF5___xref[row][0]``  ``HDF5___xref[row][1]``
//		===  =======================  ==========================
//		0    /                        :
//		1    /sasentry01              :sasentry01
//		2    /sasentry01/sasdata01    :sasentry01:sasdata01
//		3    /sasentry01/sasdata01/I  :sasentry01:sasdata01:I0
//		4    /sasentry01/sasdata01/Q  :sasentry01:sasdata01:Q0
//		===  =======================  ==========================
//	
//		Remember, column 0 is for HDF5 paths, column 1 is for IgorPro paths.
//	
//	On reading an HDF5 file, the *file_name* and *file_path* are written to the
//	wave note of *HDF5___xref*.  These notations are strictly informative and 
//	are not used further by this interface.  When writing back to HDF5, any 
//	wave notes of the *HDF5___xref* wave are ignored.
//	
//		.. rubric::  About *HDF5___xref*:
//	
//		* Only the folders and waves listed in the *HDF5___xref* text
//		  wave will be written to the HDF5 file.
//		* The *HDF5___xref* text wave is **not written** to the HDF5 file.
//	
//	When writing an HDF5 file with these functions, 
//	based on the structure expected in an IgorPro data folder structure,
//	the *HDF5___xref* text wave is required.  Each IgorPro object described
//	must exist as either an IgorPro folder or wave.  A wave note is optional.
//	For each such IgorPro object, a corresponding HDF5 file object will be created.
//	
//	.. note:: Important!  Any IgorPro data storage objects (folders or waves) 
//	   not listed in *HDF5___xref* **will not be written** to the HDF5 file.
//	
//	.. index:: group
//	.. index:: folder
//	
//	Groups and Folders
//	=====================
//	
//	An HDF5 *group* corresponds to the IgorPro *folder*.  Both are containers
//	for either data or containers.  
//	
//	.. index:: Igor___folder_attributes
//	
//	In HDF5, a group may have attached metadata
//	known as *attributes*.  In IgorPro, folders have no provision to store  
//	attributes, thus an optional *Igor___folder_attributes* wave is created.  The
//	folder attributes are stored in the wave note of this wave.  For more information
//	about attributes, see the discussion of :ref:`attributes` below.
//	
//	.. index:: datasets
//	.. index:: waves
//	
//	Datasets and Waves
//	======================
//	
//	Data is stored in HDF5 datasets and IgorPro waves.  
//	Both objects are capable of storing a variety of data types
//	with different shapes (rank and length).  Of the two systems,
//	IgorPro is the more restrictive, limiting the rank of stored data
//	to four dimensions.
//	
//	Keep in mind that all components of a single dataset (or wave) are
//	of the same data type (such as 64-bit float or 8-bit int).
//	
//	In HDF5, a dataset may have attached metadata known as 
//	*attributes*.  HDF5 attributes are data structures in their own
//	right and may contain data structures.  In IgorPro, waves have 
//	a provision to store  attributes in a text construct called the *wave note*.  
//	Of these two, IgorPro is the more restrictive, unless one creates
//	a new wave to hold the data structure of the attributes.
//	For more information
//	about attributes, see the discussion of :ref:`attributes` below.
//	
//	The HDF5 library used by this package will take care of converting
//	between HDF5 datasets and IgorPro waves and the user need
//	not be too concerned about this.
//	
//	
//	.. index:: attributes
//	.. index:: ! Igor___folder_attributes
//	
//	.. _attributes:
//	
//	Attributes and Wave Notes
//	============================================
//	
//	Metadata about each of the objects in HDF5 files and IgorPro folders
//	is provided by *attributes*.  In HDF5, these are attributes directly attached 
//	to the object (group or dataset).  In IgorPro, these attributes are **stored as text** in 
//	different places depending on the type of the object, as shown in this table:
//	
//		========   =======================================================
//		object     description
//		========   =======================================================
//		folder     attributes are stored in the wave note of a special
//		           wave in the folder named *Igor___folder_attributes*
//		wave       attributes are stored in the wave note of the wave
//		========   =======================================================
//	
//	.. note:: IgorPro folders do not have a *wave note*
//	
//	HDF5 allows an attribute to be a data structure with the same rules for
//	complexity as a dataset except that attributes must be attached to a dataset
//	and cannot themselves have attributes.
//	
//	.. note:: In IgorPro, attributes will be stored as text.
//	
//	An IgorPro wave note is a text string that is used here to store a list of
//	*key,value* pairs.  IgorPro provides helpful routines to manipulate such
//	lists, especially when used as wave notes.  The IgorPro wave note is the most 
//	natural representation of an *attribute* except that it does not preserve
//	the data structure of an HDF5 attribute without additional coding.  This
//	limitation is deemed acceptable for this work.  
//	
//	It is most obvious to see
//	the conversion of attributes into text by reading and HDF5 file and then
//	writing it back out to a new file.  The data type of the HDF5 attributes will
//	likely be changed from its original type into "string, variable length".  If this
//	is not acceptable, more work must be done in the routines below.
//	
//	IgorPro key,value list for the attributes
//	----------------------------------------------------------------------------------------
//	
//	Attributes are represented in IgorPro wave notes using a
//	list of *key,value* pairs.  For example:
//	
//		.. code-block:: guess
//			:linenos:
//	
//			NX_class=SASdata
//			Q_indices=0,1
//			I_axes=Q,Q
//			Mask_indices=0,1
//	
//	It is important to know the delimiters used by this string to 
//	differentiate various attributes, some of which may have a 
//	list of values.  Please refer to this table:
//	
//		===========  ====  ==========================================
//		separator    char  description
//		===========  ====  ==========================================
//		keySep       =     between *key* and *value*
//		itemSep      ,     between multiple items in *value*
//		listSep      \\r   between multiple *key,value* pairs
//		===========  ====  ==========================================
//	
//	.. note::  A proposition is to store these values in a text wave
//	   at the base of the folder structure and then use these value
//	   throughout the folder.  This can allow some flexibility with other
//	   code and to make obvious which terms are used.
//	
//	.. index:: example
//	
//	Examples
//	====================
//	
//	Export data from IgorPro
//	-------------------------------------------------------
//	
//	To write a simple dataset *I(Q)*, one might write this IgorPro code:
//	
//		.. code-block:: guess
//			:linenos:
//			
//			// create the folder structure
//			NewDataFolder/O/S root:mydata
//			NewDataFolder/O sasentry
//			NewDataFolder/O :sasentry:sasdata
//	
//			// create the waves
//			Make :sasentry:sasdata:I0
//			Make :sasentry:sasdata:Q0
//	
//			Make/N=0 Igor___folder_attributes
//			Make/N=0 :sasentry:Igor___folder_attributes
//			Make/N=0 :sasentry:sasdata:Igor___folder_attributes
//	
//			// create the attributes
//			Note/K Igor___folder_attributes, "producer=IgorPro\rNX_class=NXroot"
//			Note/K :sasentry:Igor___folder_attributes, "NX_class=NXentry"
//			Note/K :sasentry:sasdata:Igor___folder_attributes, "NX_class=NXdata"
//			Note/K :sasentry:sasdata:I0, "units=1/cm\rsignal=1\rtitle=reduced intensity"
//			Note/K :sasentry:sasdata:Q0, "units=1/A\rtitle=|scattering vector|"
//	
//			// create the cross-reference mapping
//			Make/T/N=(5,2) HDF5___xref
//			Edit/K=0 'HDF5___xref';DelayUpdate
//			HDF5___xref[0][1] = ":"
//			HDF5___xref[1][1] = ":sasentry"
//			HDF5___xref[2][1] = ":sasentry:sasdata"
//			HDF5___xref[3][1] = ":sasentry:sasdata:I0"
//			HDF5___xref[4][1] = ":sasentry:sasdata:Q0"
//			HDF5___xref[0][0] = "/"
//			HDF5___xref[1][0] = "/sasentry"
//			HDF5___xref[2][0] = "/sasentry/sasdata"
//			HDF5___xref[3][0] = "/sasentry/sasdata:I"
//			HDF5___xref[4][0] = "/sasentry/sasdata:Q"
//	
//			// Check our work so far.
//			// If something prints, there was an error above.
//			print H5GW_ValidateFolder("root:mydata")
//	
//			// set I0 and Q0 to your data
//		
//			print H5GW_WriteHDF5("root:mydata", "mydata.h5")
//	
//	.. index:: read
//	
//	Read data into IgorPro
//	-------------------------------------------------------
//	
//	.. index:: example
//	
//	This is a simple operation, reading the file from the previous example into a new folder:
//	
//		.. code-block:: guess
//			:linenos:
//			
//			NewDataFolder/O/S root:newdata
//			H5GW_ReadHDF5("", "mydata.h5")	// reads into current folder
//@-

//  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //


//@+
//	.. index:: read
//	
//	Public Functions
//	======================================
//	
//	.. index:: ! H5GW_ReadHDF5()
//	
//	.. _H5GW_ReadHDF5:
//	
//	H5GW_ReadHDF5(parentFolder, fileName, [hdf5Path])
//	-------------------------------------------------------------------------------------------------------------
//	
//	Read the HDF5 data file *fileName* (located in directory *data*,
//	an IgorPro path variable) and store it in a subdirectory of 
//	IgorPro folder *parentFolder*.
//	
//	At present, the *hdf5Path* parameter is not used.  It is planned
//	(for the future) to use this to indicate reading only part of the 
//	HDF5 file to be read.
//	
//	:String parentFolder: Igor folder path (default is current folder)
//	:String fileName: name of file (with extension), 
//			either relative to current file system directory, 
//			or include absolute file system path
//	:String hdf5Path: path of HDF file to load (default is "/")
//		:return String: Status: ""=no error, otherwise, error is described in text
//@-

Function/T H5GW_ReadHDF5(DataPathStr, parentFolder, fileName, [hdf5Path])
	String DataPathStr, parentFolder, fileName, hdf5Path
	if ( ParamIsDefault(hdf5Path) )
		hdf5Path = "/"
	endif

	String status = ""
	String oldFolder
	oldFolder = GetDataFolder(1)
	parentFolder = H5GW__SetStringDefault(parentFolder, oldFolder)

	// First, check that parentFolder exists
	if ( DataFolderExists(parentFolder) )
		SetDataFolder $parentFolder
	else
		return parentFolder + " (Igor folder) not found"
	endif
	
	// do the work here:
	Variable/G fileID = H5GW__OpenHDF5_RO(DataPathStr, fileName)
	if ( fileID == 0 )
		return fileName + ": could not open as HDF5 file"
	endif
	//   read the data (too bad that HDF5LoadGroup does not read the attributes)
	String base_name = StringFromList(0,FileName,".")
	HDF5LoadGroup/Z/L=7/O/R/T=$base_name  :, fileID, hdf5Path		//	recursive
	if ( V_Flag != 0 )
		SetDataFolder $oldFolder
		return fileName + ": problem while opening HDF5 file"
	endif
	String/G objectPaths = S_objectPaths  // this gives a clue to renamed datasets (see below for attributes)
	//   read the attributes
	base_name = possiblyQuoteName(base_name)					//JIL fix, needed to handle liberal names. 
	H5GW__HDF5ReadAttributes(fileID, hdf5Path, base_name)
	HDF5CloseFile fileID

	String/G file_path
	String/G group_name_list
	String/G dataset_name_list
	String file_info
	sprintf file_info, ":%s:HDF5___xref", base_name
	Note/K $file_info, "file_name="+fileName
	Note $file_info, "file_path="+file_path

	KillStrings/Z file_path, file_name, objectPaths, group_name_list, dataset_name_list
	KillVariables/Z fileID
	
	SetDataFolder $oldFolder
	return status
End


// ======================================
//@+
//	.. index:: write
//	.. index:: ! H5GW_WriteHDF5()
//	
//	.. _H5GW_WriteHDF5:
//	
//	H5GW_WriteHDF5(parentFolder, newFileName)
//	-------------------------------------------------------------------------------------------------------------
//	
//	Starting with an IgorPro folder constructed such that it passes the :ref:`H5GW_ValidateFolder` test,
//	write the components described in *HDF5___xref* to *newFileName*.
//	
//	:String parentFolder: Igor folder path (default is current folder)
//	:String fileName: name of file (with extension), 
//			either relative to current file system directory, 
//			or include absolute file system path
//@-
Function/T H5GW_WriteHDF5(parentFolder, newFileName, [replace])
	String parentFolder, newFileName
	Variable replace
	if ( ParamIsDefault(replace) )
		replace = 1
	endif

	String status = ""
	String oldFolder = GetDataFolder(1)

	// First, check that parentFolder exists
	status = H5GW_ValidateFolder(parentFolder)
	if ( strlen(status) > 0 )
		return status
	endif
	SetDataFolder $parentFolder
	
	// Build HDF5 group structure
	Variable fileID = H5GW__OpenHDF5_RW(newFileName, replace)
	if (fileID == 0)
		SetDataFolder $oldFolder
		return "Could not create HDF5 file " + newFileName + " for writing"
	endif

	// write datasets and attributes based on HDF5___xref table
	status = H5GW__WriteHDF5_Data(fileID)
	if ( strlen(status) > 0 )
		HDF5CloseFile fileID
		SetDataFolder $oldFolder
		return status
	endif
	
	HDF5CloseFile fileID

	SetDataFolder $oldFolder
	return status			// report success
End



// ======================================
//@+
//	.. index:: validate
//	.. index:: ! H5GW_ValidateFolder()
//	
//	.. _H5GW_ValidateFolder:
//	
//	H5GW_ValidateFolder(parentFolder)
//	-------------------------------------------------------------------------------------------------------------
//	
//	Check (validate) that a given IgorPro folder has the necessary
//	structure for the function H5GW__WriteHDF5_Data(fileID) to be
//	successful when writing that folder to an HDF5 file.
//	
//		:String parentFolder: Igor folder path (default is current folder)
//		:return String: Status: ""=no error, otherwise, error is described in text
//@-

Function/T H5GW_ValidateFolder(parentFolder)
	String parentFolder
	String oldFolder = GetDataFolder(1)
	// First, check that parentFolder exists
	if ( DataFolderExists(parentFolder) )
		SetDataFolder $parentFolder
	else
		return parentFolder + " (Igor folder) not found"
	endif

	if (1 != Exists("HDF5___xref"))
		SetDataFolder $oldFolder
		return "required wave (HDF5___xref) is missing in folder: " + parentFolder
	endif
	Wave/T HDF5___xref
	if ( DimSize(HDF5___xref, 1) != 2 )
		SetDataFolder $oldFolder
		return "text wave HDF5___xref must be of shape (N,2)"
	endif

	Variable length = DimSize(HDF5___xref, 0), ii
	String item, msg
	for (ii=0; ii < length; ii=ii+1)
		item = HDF5___xref[ii][1]
		if ( (1 != DataFolderExists(item)) && (1 != Exists(item)) )
			SetDataFolder $oldFolder
			return "specified IgorPro object " + item + " was not found in folder " + parentFolder
		endif
		// TODO: Check that each corresponding HDF5___xref[ii][0] is a valid HDF5 path name
		if ( itemsInList(item, ":") != itemsInList(HDF5___xref[ii][0], "/") )
			SetDataFolder $oldFolder
			msg = "different lengths between HDF5 and IgorPro paths on row" + num2str(ii) + "of HDF5___xref"
			return msg
		endif
	endfor
	
	// TODO: more validation steps

	SetDataFolder $oldFolder
	return ""
End


// ======================================
//@+
//	.. index:: test
//	.. index:: ! H5GW_TestSuite()
//	
//	.. _H5GW_TestSuite:
//	
//	H5GW_TestSuite()
//	-------------------------------------------------------------------------------------------------------------
//	
//	Test the routines in this file using the supplied test data files.
//	HDF5 data files are obtained from the canSAS 2012 repository of 
//	HDF5 examples 
//	(http://www.cansas.org/formats/canSAS2012/1.0/doc/_downloads/simpleexamplefile.h5).
//@-

Function H5GW_TestSuite()
	String listSep = ";"
	String fileExt = ".h5"
	String parentDir = "root:worker"

	String name_list = "simpleexamplefile"
	name_list = name_list +listSep + "simple2dcase"
	name_list = name_list +listSep + "simple2dmaskedcase"
	name_list = name_list +listSep + "generic2dqtimeseries"
	name_list = name_list +listSep + "generic2dtimetpseries"
	name_list = name_list +listSep + "NXtest"
	string DataPathStr="home"

	Variable length = itemsInList(name_list, listSep), ii
	String name, newName, newerName
	for (ii = 0; ii < length; ii = ii + 1)
		name = StringFromList(ii, name_list, listSep) + fileExt
		// Test reading the HDF5 file and then writing the data to a new HDF5 file
		newName = H5GW__TestFile(DataPathStr, parentDir, name)
		// Apply the test again on the new HDF5 file
		newerName = H5GW__TestFile(DataPathStr, parentDir, newName)
	endfor
End


//  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //


// ======================================
//@+
//	.. index:: functions; private (static)
//	
//	Private (static) Functions
//	======================================
//	
//	Documentation of some, but not all, private functions is provided.
//	
//@-


//@+
//	.. index:: ! H5GW__OpenHDF5_RW()
//	
//	H5GW__OpenHDF5_RW(newFileName, replace)
//	-------------------------------------------------------------------------------------------------------------
//@-
static Function H5GW__OpenHDF5_RW(newFileName, replace)
	String newFileName
	Variable replace
	Variable fileID
	if (replace)
		HDF5CreateFile/P=home/Z/O fileID as newFileName
	else
		// make sure file does not exist now, or handle better
		HDF5CreateFile/P=home/Z fileID as newFileName
	endif
	if (V_Flag != 0)
		return 0
	endif
	return fileID
End


//@+
//	.. index:: ! H5GW__WriteHDF5_Data()
//	
//	H5GW__WriteHDF5_Data(fileID)
//	-------------------------------------------------------------------------------------------------------------
//@-
static Function/T H5GW__WriteHDF5_Data(fileID)
	Variable fileID
	String status = ""
	
	Wave/t xref = HDF5___xref
	Variable HDF5_col = 0
	Variable Igor_col = 1
	Variable rows = DimSize(xref,0), ii, groupID, length, jj
	String igorPath, hdf5Path, dataType, folder_attr_info, notes, item, key, value
	for (ii = 0; ii < rows; ii=ii+1)
		igorPath = xref[ii][Igor_col]
		hdf5Path = xref[ii][HDF5_col]
		// print DataFolderExists(igorPath), igorPath, " --> ", hdf5Path
		if ( DataFolderExists(igorPath) )
			// group
			if ( cmpstr("/", hdf5Path) != 0 )
				HDF5CreateGroup /Z fileID , hdf5Path, groupID
				if (V_Flag != 0)
					status = H5GW__AppendString(status, "\r",  "problem creating HDF5 group: " + hdf5Path)
				endif
			else
				groupID = fileID
			endif
			// attributes
			notes = ""
			folder_attr_info = H5GW__appendPathDelimiter(igorPath, ":") + "Igor___folder_attributes"
			Wave folder_attr = $folder_attr_info
			notes = note(folder_attr)
			length = itemsInList(notes, "\r")
			String response
			if ( length > 0 )
				for (jj = 0; jj < length; jj=jj+1 )
					item = StringFromList(jj, notes,"\r")
					key = StringFromList(0, item,"=")
					value = StringFromList(1, item,"=")
					response = H5GW__SetTextAttributeHDF5(fileID, key, value, hdf5Path)
					status = H5GW__AppendString(status, "\r",  response)
				endfor
			endif
		else
			// dataset
			Wave theWave = $igorPath
			HDF5SaveData/IGOR=0/Z theWave, fileID, hdf5Path
			if (V_Flag != 0)
				status = H5GW__AppendString(status, "\r",  "problem saving HDF5 dataset: " + hdf5Path)
			endif

			// look at the wave note for any attributes
			notes = note(theWave)
			length = itemsInList(notes, "\r")
			if ( length > 0 )
				for (jj = 0; jj < length; jj=jj+1 )
					item = StringFromList(jj, notes,"\r")
					key = StringFromList(0, item,"=")
					value = StringFromList(1, item,"=")
					H5GW__SetTextAttributeHDF5(fileID, key, value, hdf5Path)
				endfor
			endif

		endif
	endfor
	
	return status
End


//@+
//	.. index:: ! H5GW__SetHDF5ObjectAttributes()
//	
//	H5GW__SetHDF5ObjectAttributes(itemID, igorPath, hdf5Path)
//	-------------------------------------------------------------------------------------------------------------
//@-
static Function H5GW__SetHDF5ObjectAttributes(itemID, igorPath, hdf5Path)
	Variable itemID
	String igorPath, hdf5Path
	Wave theWave = $igorPath
	String notes = note(theWave), item, key, value
	Variable jj, length = itemsInList(notes, "\r")
	notes = note(theWave)
	length = itemsInList(notes, "\r")
	if ( length > 0 )
		for (jj = 0; jj < length; jj=jj+1 )
			item = StringFromList(jj, notes,"\r")
			key = StringFromList(0, item,"=")
			value = StringFromList(1, item,"=")
			H5GW__SetTextAttributeHDF5(itemID, key, value, hdf5Path)
		endfor
	endif
End


//@+
//	.. index:: ! H5GW__SetTextAttributeHDF5()
//	
//	H5GW__SetTextAttributeHDF5(itemID, name, value, hdf5Path)
//	-------------------------------------------------------------------------------------------------------------
//@-
static Function/T H5GW__SetTextAttributeHDF5(itemID, name, value, hdf5Path)
	Variable itemID
	String name, value, hdf5Path
	String status = ""
	Make/T/N=(1) H5GW____temp
	H5GW____temp[0] = value
	HDF5SaveData/Z/A=name   H5GW____temp, itemID, hdf5Path
	if ( V_Flag != 0)
		status = "problem saving HDF5 text attribute: " + hdf5Path
	endif
	KillWaves  H5GW____temp
	return status
End


// ======================================
//@+
//	.. index:: ! H5GW__make_xref()
//	
//	H5GW__make_xref(parentFolder, objectPaths, group_name_list, dataset_name_list, base_name)
//	---------------------------------------------------------------------------------------------------------------------------------------------------------
//	
//	Analyze the mapping between HDF5 objects and Igor paths
//	Store the discoveries of this analysis in the HDF5___xref text wave
//	
//		:String parentFolder: Igor folder path (default is current folder)
//		:String objectPaths: Igor paths to data objects
//		:String group_name_list: 
//		:String dataset_name_list: 
//		:String base_name: 
//	
//	HDF5___xref wave column plan
//	
//		======   ===============================
//		column   description
//		======   ===============================
//		0        HDF5 path
//		1        Igor relative path
//		======   ===============================
//@-

static Function H5GW__make_xref(parentFolder, objectPaths, group_name_list, ds_list, base_name)
	String parentFolder, objectPaths, group_name_list, ds_list, base_name
	
	String xref = ""		// key.value pair list as a string
	String keySep = "="	// between key and value
	String listSep = "\r"	// between key,value pairs
	
	String matchStr = parentFolder + base_name
	String igorPaths = ReplaceString(matchStr, objectPaths, "")
	
	Variable ii, length
	String dataset, igorPath
	// compare items in ds_list and igorPaths
	length = itemsInList(ds_list, ";")
	if ( length == itemsInList(igorPaths, ";") )
		for (ii = 0; ii < length; ii = ii + 1)
			// ASSUME this is the cross-reference list we need
			dataset = StringFromList(ii, ds_list, ";")
			igorPath = StringFromList(ii, igorPaths, ";")
			xref = H5GW__addPathXref(parentFolder, base_name, dataset, igorPath, xref, keySep, listSep)
		endfor
	else
		// TODO: report an error here and return
	endif
	
	// finally, write the xref contents to a wave
	length = itemsInList(xref, listSep)
	String file_info
	sprintf file_info, ":%s:HDF5___xref", base_name
	Make/O/N=(length,2)/T $file_info
	Wave/T file_infoT = $file_info
	String item
	Variable HDF5_col = 0
	Variable Igor_col = 1
	for (ii = 0; ii < length; ii=ii+1)
		item = StringFromList(ii, xref, listSep)
		file_infoT[ii][HDF5_col] = StringFromList(0, item, keySep)
		file_infoT[ii][Igor_col] = StringFromList(1, item, keySep)
	endfor
End


//@+
//	.. index:: ! H5GW__addPathXref()
//	
//	H5GW__addPathXref(parentFolder, base_name, hdf5Path, igorPath, xref, keySep, listSep)
//	----------------------------------------------------------------------------------------------------------------------------------------------------------
//@-
static Function/T H5GW__addPathXref(parentFolder, base_name, hdf5Path, igorPath, xref, keySep, listSep)
	String parentFolder, base_name, hdf5Path, igorPath, xref, keySep, listSep
	String result = xref
	// look through xref to find each component of full hdf5Path, including the dataset
	Variable ii, length = itemsInList(hdf5Path, "/")
	String hdf5 = "", path = ""
	for (ii = 0; ii < length; ii = ii + 1)
		hdf5 = H5GW__appendPathDelimiter(hdf5, "/") + StringFromList(ii, hdf5Path, "/")
		path = H5GW__appendPathDelimiter(path, ":") + StringFromList(ii, igorPath, ":")
		if ( strlen(StringByKey(hdf5, result, keySep, listSep)) == 0 )
			result = H5GW__addXref(hdf5, path, result, keySep, listSep)
		endif
	endfor
	return result
End


//@+
//	.. index:: ! H5GW__addXref()
//	
//	H5GW__addXref(key, value, xref, keySep, listSep)
//	-------------------------------------------------------------------------------------------------------------
//	
//	append a new key,value pair to the cross-reference list
//@-
static Function/T H5GW__addXref(key, value, xref, keySep, listSep)
	String key, value, xref, keySep, listSep
	return H5GW__AppendString(xref, listSep,  key + keySep + value)
End


//@+
//	.. index:: ! H5GW__appendPathDelimiter()
//	
//	H5GW__appendPathDelimiter(str, sep)
//	-------------------------------------------------------------------------------------------------------------
//@-
static Function/T H5GW__appendPathDelimiter(str, sep)
	String str, sep
	if ( (strlen(str) == 0) || ( cmpstr(sep, str[strlen(str)-1]) != 0) )
		return str + sep
	endif
	return str
End



// ======================================
//@+
//	.. index:: ! H5GW__findTextWaveIndex()
//	
//	H5GW__findTextWaveIndex(twave, str, col)
//	-------------------------------------------------------------------------------------------------------------
//	
//		:Wave/T twave: correlation between HDF5 and Igor paths
//		:String str: text to be located in column *col*
//		:int col: column number to search for *str*
//		:returns int: index of found text or -1 if not found
//@-

static Function H5GW__findTextWaveIndex(twave, str, col)
	Wave/T twave
	String str
	Variable col
	Variable result = -1, ii, rows=DimSize(twave,0)
	for (ii=0; ii < rows; ii=ii+1)
		if (0 == cmpstr(str, twave[ii][col]) )
			result = ii
			break
		endif
	endfor
	return result
End


// ======================================
//@+
//	.. index:: ! H5GW__OpenHDF5_RO()
//	
//	H5GW__OpenHDF5_RO(DataPathStr, fileName)
//	-------------------------------------------------------------------------------------------------------------
//	
//		:String DataPathStr - name of Igor Path where the file resides
//		:String fileName: name of file (with extension),
//			either relative to current file system directory
//			or includes absolute file system path
//		:returns int: Status: 0 if error, non-zero (fileID) if successful
//	
//@-

Static Function H5GW__OpenHDF5_RO(DataPathStr, fileName)
	String DataPathStr, fileName
	if ( H5GW__FileExists(DataPathStr, fileName) == 0 )
		// avoid the open file dialog if the file is not found here
		return 0
	endif
	Variable fileID = 0
	HDF5OpenFile/R/P=$(DataPathStr)/Z fileID as fileName
	if (V_Flag != 0)
		return 0
	endif

	if ( 0 )
		STRUCT HDF5DataInfo di	// Defined in HDF5 Browser.ipf.
		InitHDF5DataInfo(di)	// Initialize structure.
		HDF5AttributeInfo(fileID, "/", 1, "file_name", 0, di)
		Print di
	endif


	String/G file_path = S_path
	String/G file_name = fileName
	return fileID
End


// ======================================
//@+
//	.. index:: ! H5GW__HDF5ReadAttributes()
//	
//	H5GW__HDF5ReadAttributes(fileID, hdf5Path, baseName)
//	-------------------------------------------------------------------------------------------------------------
//	
//	Reads and assigns the group and dataset attributes.
//	For groups, it creates a dummy wave *Igor___folder_attributes*
//	to hold the group attributes.
//	
//	All attributes are stored in the wave note
//	
//	Too bad that HDF5LoadGroup does not read the attributes.
//	
//		:int fileID: IgorPro reference number for this HDF5 file
//		:String hdf5Path: read the HDF5 file starting 
//				from this level (default is the root level, "/")
//				Note: not implemented yet.
//		:String baseName: IgorPro subfolder name to 
//				store attributes.  Maps directly from HDF5 path.
//@-

Static Function H5GW__HDF5ReadAttributes(fileID, hdf5Path, baseName)
	Variable fileID
	String hdf5Path
	String baseName
	
	Variable group_attributes_type = 1
	Variable dataset_attributes_type = 2
	
	// read and assign group attributes
	String S_HDF5ListGroup
	HDF5ListGroup/F/R/TYPE=(group_attributes_type)  fileID, hdf5Path		//	TYPE=1 reads groups
	String/G group_name_list = hdf5Path + ";" + S_HDF5ListGroup
	
	Variable length = ItemsInList(group_name_list)
	Variable index, i_attr
	String group_name
	String attr_name_list, attr_name, attribute_str
	
	String old_dir = GetDataFolder(1), subdir, group_attr_name
	for (index = 0; index < length; index = index+1)
		group_name = StringFromList(index, group_name_list)
		attribute_str = H5GW__HDF5AttributesToString(fileID, group_name, group_attributes_type)
		if ( strlen(attribute_str) > 0 )
			// store these attributes in the wavenote of a unique wave in the group
			subdir = ":" + baseName + ReplaceString("/", group_name, ":")
			SetDataFolder $subdir
			group_attr_name = StringFromList((itemsInList(group_name, "/")-1), group_name, "/")
			group_attr_name = H5GW__SetStringDefault(group_attr_name, "root") + "_attributes"
			group_attr_name = "Igor___folder_attributes"
			Make/O/N=0 $group_attr_name
			Note/K $group_attr_name, attribute_str
		endif
		SetDataFolder $old_dir
	endfor
	
	// read and assign dataset attributes
	HDF5ListGroup/F/R/TYPE=(dataset_attributes_type)  fileID, hdf5Path		//	TYPE=2 reads datasets
	String/G dataset_name_list = S_HDF5ListGroup

	// build a table connecting objectPaths with group_name_list and dataset_name_list 
	// using parentFolder and baseName
	String parentFolder = GetDataFolder(1)
	String/G objectPaths
	H5GW__make_xref(parentFolder, objectPaths, group_name_list, dataset_name_list, baseName)

	String file_info
	sprintf file_info, ":%s:HDF5___xref", baseName
	Wave/T xref = $file_info

	Variable row
	String hdf5_path, igor_path
	length = ItemsInList(dataset_name_list)
	for (index = 0; index < length; index = index+1)
		hdf5_path = StringFromList(index, dataset_name_list)
		attribute_str = H5GW__HDF5AttributesToString(fileID, hdf5_path, dataset_attributes_type)
		if ( strlen(attribute_str) > 0 )
			// store these attributes in the wavenote of the dataset
			row = H5GW__findTextWaveIndex(xref, hdf5_path, 0)
			if (row > -1)
				igor_path = ":" + baseName + xref[row][1]
				wave targetWave=$igor_path
				Note/K targetWave, attribute_str
			endif
		endif
	endfor

End

// ======================================
//@+
//	.. index:: ! H5GW__HDF5AttributesToString()
//	
//	H5GW__HDF5AttributesToString(fileID, hdf5_Object, hdf5_Type, [keyDelimiter, keyValueSep, itemDelimiter])
//	----------------------------------------------------------------------------------------------------------------------------------------------------------------------
//	
//	Reads the attributes assigned to this object and returns
//	a string of key=value pairs, delimited by ;
//	Multiple values for a key are delimited by ,
//	
//	All attributes are stored in the wave note
//	
//	Too bad that HDF5LoadGroup does not read the attributes.
//	
//		:int fileID: IgorPro reference number for this HDF5 file
//		:String hdf5_Object: full HDF5 path of object
//		:int hdf5_Type: 1=group, 2=dataset
//		:String keyDelimiter: between key=value pairs, default = "\r"
//		:String keyValueSep: key and value, default = "="
//		:String itemDelimiter: between multiple values, default = ","
//		:returns str: key1=value;key2=value,value;key3=value, empty string if no attributes
//@-

Static Function/T H5GW__HDF5AttributesToString(fileID, hdf5_Object, hdf5_Type, [keyDelimiter, keyValueSep, itemDelimiter])
	Variable fileID
	String hdf5_Object
	Variable hdf5_Type
	String keyDelimiter
	String keyValueSep
	String itemDelimiter
	
	if ( ParamIsDefault(keyDelimiter) )
		keyDelimiter = "\r"
	endif
	if ( ParamIsDefault(keyValueSep) )
		keyValueSep = "="
	endif
	if ( ParamIsDefault(itemDelimiter) )
		itemDelimiter = ","
	endif
	
	String result = ""
	String attr_name_list, attr_name, attr_str, temp_str
	Variable num_attr, i_attr
	HDF5ListAttributes/TYPE=(hdf5_Type)/Z  fileID, hdf5_Object
	if ( V_Flag != 0 )
		return result
	endif
	attr_name_list = S_HDF5ListAttributes
	num_attr = ItemsInList(attr_name_list)
	for (i_attr = 0; i_attr < num_attr; i_attr = i_attr+1)
		attr_name = StringFromList(i_attr, attr_name_list)
		attr_str = H5GW__HDF5AttributeDataToString(fileID, hdf5_Object, hdf5_Type, attr_name, itemDelimiter)
		if (strlen(result) > 0)
			result = result + keyDelimiter
		endif
		result = result + attr_name + keyValueSep + attr_str
	endfor
	KillWaves/Z attr_wave

	return result
End


// ======================================
//@+
//	.. index:: ! H5GW__HDF5AttributeDataToString()
//	
//	H5GW__HDF5AttributeDataToString(fileID, hdf5_Object, hdf5_Type, attr_name, itemDelimiter)
//	---------------------------------------------------------------------------------------------------------------------------------------------------
//	
//	Reads the value of a specific attribute assigned to this object
//	and returns its value.
//	
//		:int fileID: IgorPro reference number for this HDF5 file
//		:String hdf5_Object: full HDF5 path of object
//		:int hdf5_Type: 1=group, 2=dataset
//		:String attr_name: name of the attribute
//		:String itemDelimiter: if the attribute data is an array, 
//				this will delimit the representation of its members in a string
//		:returns String: value, empty string if no value
//@-

Static Function/T H5GW__HDF5AttributeDataToString(fileID, hdf5_Object, hdf5_Type, attr_name, itemDelimiter)
	Variable fileID
	String hdf5_Object
	Variable hdf5_Type
	String attr_name
	String itemDelimiter

	String attr_str = "", temp_str
	Variable index
	HDF5LoadData/A=attr_name/TYPE=(hdf5_Type)/N=attr_wave/Z/O/Q   fileID, hdf5_Object
	if ( V_Flag == 0 )
		if ( 0 == cmpstr( "attr_wave,", WaveList("attr_wave", ",", "TEXT:1")) )
			Wave/T attr_waveT=attr_wave
			attr_str = attr_waveT[0]
		else
			Wave attr_waveN=attr_wave
			attr_str = ""
			sprintf attr_str, "%g", attr_waveN[0]		// assume at least one point
			for ( index=1; index < numpnts(attr_waveN); index=index+1)
				sprintf temp_str, "%g", attr_waveN[index]
				attr_str = attr_str + itemDelimiter + temp_str
			endfor
		endif
	endif
	KillWaves/Z attr_wave
	return attr_str
End


// ======================================
//@+
//	.. index:: ! H5GW__SetStringDefault()
//	
//	H5GW__SetStringDefault(str, string_default)
//	-------------------------------------------------------------------------------------------------------------
//	
//	   :String str: supplied value
//	   :String string_default: default value
//	   :returns String: default if supplied value is empty
//@-

Static Function/T H5GW__SetStringDefault(str, string_default)
	String str
	String string_default
	String result = string_default
	if ( strlen(str)>0 )
		result = str
	endif
	return result
End


// ======================================
//@+
//	.. index:: ! H5GW__AppendString()
//	
//	H5GW__AppendString(str, sep, newtext)
//	-------------------------------------------------------------------------------------------------------------
//	
//	   :String str: starting string
//	   :String sep: separator
//	   :String newtext: text to be appended
//	   :returns String: result
//@-

Static Function/T H5GW__AppendString(str, sep, newtext)
	String str, sep, newtext
	if ( strlen(newtext) == 0 )
		return str
	endif
	if ( strlen(str) > 0 )
		str = str + sep
	endif
	return str +newtext
End




// ======================================
//@+
//	.. index:: ! H5GW__FileExists()
//	
//	H5GW__FileExists(file_name)
//	-------------------------------------------------------------------------------------------------------------
//	
//		:String file_name: name of file to be found
//		:returns int: 1 if exists, 0 if does not exist
//@-

Static Function H5GW__FileExists(DataPathStr, file_name)
	String DataPathStr, file_name
	Variable fileID
	Open/R/P=$(DataPathStr)/Z fileID as file_name	// test if it will open as a regular file
	if ( fileID > 0 )
		Close fileID
		return 1
	endif
	return 0
End


//  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //  //


//@+
//	Testing and Development
//	======================================
//	
//	Examples to test read and write:
//	
//		.. code-block:: guess
//			:linenos:
//			
//			print H5GW_ReadHDF5("root:worker", "simpleexamplefile.h5")
//			print H5GW_ReadHDF5("root:worker", "simple2dcase.h5")
//			print H5GW_ReadHDF5("root:worker", "simple2dmaskedcase.h5")
//			print H5GW_ReadHDF5("root:worker", "generic2dqtimeseries.h5")
//			print H5GW_ReadHDF5("root:worker", "generic2dtimetpseries.h5")
//			print H5GW_WriteHDF5("root:worker:simpleexamplefile", "test_output.h5")
//	
//	.. index:: test
//	.. index:: ! H5GW__TestFile()
//	
//	H5GW__TestFile(parentDir, sourceFile)
//	-------------------------------------------------------------------------------------------------------------
//	
//	Reads HDF5 file sourceFile into a subfolder of IgorPro folder parentDir.
//	Then writes the structure from that subfolder to a new HDF5 file: ``"test_"+sourceFile``
//	Assumes that sourceFile is only a file name, with no path components, in the present working directory.
//	Returns the name (string) of the new HDF5 file written.
//	
//		:String parentDir: folder within IgorPro memory to contain the HDF5 test data
//		:String sourceFile: HDF5 test data file (assumes no file path information prepends the file name)
//@-

static Function/T H5GW__TestFile(DataPathStr, parentDir, sourceFile)
	String DataPathStr, parentDir, sourceFile
	String prefix = "test_"
	String newFile = prefix + sourceFile
	String name = StringFromList(0, sourceFile, ".")
	print H5GW_ReadHDF5(DataPathStr, parentDir, sourceFile)
	print H5GW_WriteHDF5(parentDir+":"+name, newFile)
	return newFile
End
