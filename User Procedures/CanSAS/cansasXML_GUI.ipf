#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.03
//#include "cansasXML", version>=1.09

// file :     cansasXML_GUI.ipf
// author: Jan Ilavsky
// purpose: provide GUI for Ior Pro reader to read canSAS 1 - D reduced SAS data in XML files
// URL:    http://www.smallangles.net/wgwiki/index.php/cansas1d_documentation

//1.03  6/27/2013 Fixed bnug which failed load for XML files containing only one data set. 
//1.02  Modified all controls not to define font and font size to enable proper control by user 
//ver 1.01, 9/3/09, JIL.... Fixed CS_XMLGUICopyOneFldrWithDta to simplify final folder structure when only one SASdata (the most common case) is present

Menu "Data"
		"SAS data XML import", CS_XMLGUIImportDataMain(defaultType="QRS",defaultQUnits="1/A")
		help={"Import data from CanSAS 1.0 conforming data sets"}
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function CS_XMLGUIImportDataMain([defaultType, defaultQUnits])
	string DefaultType,defaultQUnits					//default type of import: Indra2, QRS, QIS
														// defaultQUnits = "1/A" or "1/nm"
	//to call with default type call for example :   CS_XMLGUIImportDataMain(defaultType="QRS", defaultQUnits="1/A")
	
	if(ParamIsDefault(DefaultType ))
		DefaultType=  "" 
	endif	
	if(ParamIsDefault(defaultQUnits ))
		defaultQUnits=  "" 
	endif	
	DoWindow CS_ImportDataPanel			//check for the existing panel and if it exists, kill it...
	if(V_Flag)
		DoWIndow/K CS_ImportDataPanel
	endif
	CS_XMLGUIInitializeImportData()		//initialization routine. Creates folders, variables, strings...
	//make sure the three options for wave naming system are clean and set to their default states...
	NVAR UseQRSNames=root:Packages:CS_XMLreader_GUI:UseQRSNames
	NVAR UseQISNames=root:Packages:CS_XMLreader_GUI:UseQISNames
	NVAR UseIndra2Names=root:Packages:CS_XMLreader_GUI:UseIndra2Names
	NVAR ConvertQTonm=root:Packages:CS_XMLreader_GUI:ConvertQTonm
	NVAR ConvertQToA=root:Packages:CS_XMLreader_GUI:ConvertQToA

	strswitch(DefaultType)	// string switch
		case "Indra2":		// execute if case matches expression
			UseQRSNames=0
			UseQISNames=0
			UseIndra2Names=1
			break
		case "QRS":		// execute if case matches expression
			UseQRSNames=1
			UseQISNames=0
			UseIndra2Names=0
			break
		case "QIS":		// execute if case matches expression
			UseQRSNames=0
			UseQISNames=1
			UseIndra2Names=0
	endswitch
	strswitch(defaultQUnits)	// string switch
		case "1/A":		// execute if case matches expression
			ConvertQTonm=0
			ConvertQToA=1
			break
		case "1/nm":		// execute if case matches expression
			ConvertQTonm=1
			ConvertQToA=0
	endswitch

	//end of setting to default states...  
	
	Execute("CS_XMLGUIImportDataPanel()")		//create the panel
	
	//fix the selection of output names...
	if(UseQRSNames)
		CS_XMLGUICheckProc("UseQRSNames",1)
	elseif(UseQISNames)
		CS_XMLGUICheckProc("UseQISNames",1)
	elseif(UseIndra2Names)
		CS_XMLGUICheckProc("UseIndra2Names",1)
	endif
		
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Proc CS_XMLGUIImportDataPanel() 			//main panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(3,40,430,660) as "Import XML data"
	DoWindow/C CS_XMLGUIImportDataPanel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 1,textrgb= (16384,16384,65280)
	DrawText 84,31,"Import XML Data in Igor"
	SetDrawEnv linethick= 2,linefgc= (16384,16384,65280)
	DrawLine 21,44,363,44
	DrawText 41,140,"List of available files"
	Button SelectDataPath,pos={99,53},size={130,20}, proc=CS_XMLGUIButtonProc,title="Select data path"
	Button SelectDataPath,help={"Select data path to the data"}
	SetVariable DataPathString,pos={2,85},size={415,19},title="Data path :", noedit=1
	SetVariable DataPathString,help={"This is currently selected data path where Igor looks for the data"}
	SetVariable DataPathString,fSize=12,limits={-Inf,Inf,0},value= root:Packages:CS_XMLreader_GUI:DataPathName
	SetVariable DataExtensionString,pos={220,110},size={150,19},proc=CS_XMLGUISetVarProc,title="Data extension:"
	SetVariable DataExtensionString,help={"Insert extension string to mask data of only some type (dat, txt, ...)"}
	SetVariable DataExtensionString,fSize=12
	SetVariable DataExtensionString,value= root:Packages:CS_XMLreader_GUI:DataExtension

	ListBox ListOfAvailableData,pos={7,148},size={380,200}
	ListBox ListOfAvailableData,help={"Select files from this location you want to import"}
	ListBox ListOfAvailableData,listWave=root:Packages:CS_XMLreader_GUI:WaveOfFiles
	ListBox ListOfAvailableData,selWave=root:Packages:CS_XMLreader_GUI:WaveOfSelections
	ListBox ListOfAvailableData,mode= 4, proc=CS_XMLGUIListBoxProc
	
	Button SelectAll,pos={5,350},size={100,20}, proc=CS_XMLGUIButtonProc,title="Select All"
	Button SelectAll,help={"Select all waves in the list"}
	Button DeSelectAll,pos={120,350},size={100,20}, proc=CS_XMLGUIButtonProc,title="Deselect All"
	Button DeSelectAll,help={"Deselect all waves in the list"}
	Button Preview,pos={300,350},size={80,20}, proc=CS_XMLGUIButtonProc,title="Preview"
	Button Preview,help={"Preview selected file."}

	CheckBox UseFileNameAsFolder,pos={10,380},size={16,14},proc=CS_XMLGUICheckProc,title="Use File Nms As Fldr Nms?",variable= root:Packages:CS_XMLreader_GUI:UseFileNameAsFolder, help={"Use names of imported files as folder names for the data?"}
	CheckBox UseIndra2Names,pos={10,395},size={16,14},proc=CS_XMLGUICheckProc,title="Use USAXS names?",variable= root:Packages:CS_XMLreader_GUI:UseIndra2Names, help={"Use wave names using Indra 2 name structure? (DSM_Int, DSM_Qvec, DSM_Error)"}
	CheckBox UseQRSNames,pos={10,410},size={16,14},proc=CS_XMLGUICheckProc,title="Use QRS data names?",variable= root:Packages:CS_XMLreader_GUI:UseQRSNames, help={"Use QRS name structure? (Q_filename, R_filename, S_filename)"}
	CheckBox UseQISNames,pos={230,395},size={16,14},proc=CS_XMLGUICheckProc,title="Use QIS data names?",variable= root:Packages:CS_XMLreader_GUI:UseQISNames, help={"Use NIST QIS naming structure? (filename_Q, filename_I, filename_S etc..)"}

	PopupMenu SelectFolderNewData,pos={1,430},size={250,21},proc=CS_XMLGUIPopMenuProc,title="Select data folder", help={"Select folder with data"}
	PopupMenu SelectFolderNewData,mode=1,popvalue="---",value= #"\"---;\"+IR1_GenStringOfFolders(0, 0,0,0)"

	SetVariable NewDataFolderName, pos={5,455}, size={410,20},title="New data folder:"//, proc=IR1I_setvarProc
	SetVariable NewDataFolderName value= root:packages:CS_XMLreader_GUI:NewDataFolderName,help={"Folder for the new data. Will be created, if does not exist. Use popup above to preselect."}
	SetVariable NewQwaveName, pos={5,475}, size={260,20},title="Q wave names "//, proc=IR1I_setvarProc
	SetVariable NewQwaveName, value= root:packages:CS_XMLreader_GUI:NewQWaveName,help={"Input name for the new Q wave"}
	SetVariable NewIWaveName, pos={5,495}, size={260,20},title="Intensity names"//, proc=IR1I_setvarProc
	SetVariable NewIWaveName, value= root:packages:CS_XMLreader_GUI:NewIWaveName,help={"Input name for the new intensity wave"}
	SetVariable NewIdevWaveName, pos={5,515}, size={260,20},title="Error wv names"//, proc=IR1I_setvarProc
	SetVariable NewIdevWaveName, value= root:packages:CS_XMLreader_GUI:NewIdevWaveName,help={"Input name for the new I Error wave"}
	SetVariable NewQdevWaveName, pos={5,535}, size={260,20},title="Q Error wv names"//, proc=IR1I_setvarProc
	SetVariable NewQdevWaveName, value= root:packages:CS_XMLreader_GUI:NewQdevWaveName,help={"Input name for the new Q Error wave"}
	SetVariable NewQfwhmWaveName, pos={5,555}, size={260,20},title="Q fwhm wv names"//, proc=IR1I_setvarProc
	SetVariable NewQfwhmWaveName, value= root:packages:CS_XMLreader_GUI:NewQfwhmWaveName,help={"Input name for the new Q fwhm wave"}
	SetVariable NewQmeanWaveName, pos={5,575}, size={260,20},title="Q mean wv names"//, proc=IR1I_setvarProc
	SetVariable NewQmeanWaveName, value= root:packages:CS_XMLreader_GUI:NewQmeanWaveName,help={"Input name for the new Q mean Error wave"}
	SetVariable NewShadowWaveName, pos={5,595}, size={260,20},title="Shadow wv names"//, proc=IR1I_setvarProc
	SetVariable NewShadowWaveName, value= root:packages:CS_XMLreader_GUI:NewShadowWaveName,help={"Input name for the new shadow wave"}

	CheckBox ConvertQToA,pos={290,475},size={16,14},proc=CS_XMLGUICheckProc,title="Convert Q to 1/A?",variable= root:Packages:CS_XMLreader_GUI:ConvertQToA, help={"Inf necessary, convert Q to 1/A?"}
	CheckBox ConvertQTonm,pos={290,495},size={16,14},proc=CS_XMLGUICheckProc,title="Convert Q to 1/nm?",variable= root:Packages:CS_XMLreader_GUI:ConvertQTonm, help={"If necessary convert Q to 1/nm"}
	CheckBox OverwriteOnImport,pos={280,550},size={16,14},proc=CS_XMLGUICheckProc,title="Overwrite existing data?",variable= root:Packages:CS_XMLreader_GUI:OverwriteOnImport, help={"Overwrite existing data without asking"}

	Button ImportData,pos={330,580},size={80,30}, proc=CS_XMLGUIButtonProc,title="Import"
	Button ImportData,help={"Import the selected data files."}

EndMacro
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function CS_XMLGUISetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	if (cmpstr(ctrlName,"DataExtensionString")==0)
		CS_XMLGUIUpdateListOfFilesInWvs()
	endif
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function CS_XMLGUIListBoxProc(LB_Struct) : ListBoxControl
	STRUCT WMListboxAction &LB_Struct

	if(LB_Struct.eventCode==4)
		CS_XMLGUIGuessIgorNames()
	endif

end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function CS_XMLGUIGuessIgorNames()	//here we update the naming structure

	string OldDf = getDataFolder(1)
	setDataFolder root:packages:CS_XMLreader_GUI
	
	NVAR UseQRSNames=root:Packages:CS_XMLreader_GUI:UseQRSNames
	NVAR UseQISNames=root:Packages:CS_XMLreader_GUI:UseQISNames
	NVAR UseIndra2Names=root:Packages:CS_XMLreader_GUI:UseIndra2Names
	Wave/T WaveOfFiles      = root:Packages:CS_XMLreader_GUI:WaveOfFiles
	Wave WaveOfSelections = root:Packages:CS_XMLreader_GUI:WaveOfSelections
	variable WhichNumIsSelected
	FindLevel/P/Q WaveOfSelections, 0.5
	WhichNumIsSelected = floor(V_LevelX+V_rising)
	SVAR NewDataFolderName = root:packages:CS_XMLreader_GUI:NewDataFolderName
	if(strlen(NewDataFolderName)<6)
		NewDataFolderName="root:SASData:"
	endif
	NVAR UseFileNameAsFolder = root:Packages:CS_XMLreader_GUI:UseFileNameAsFolder
	NewDataFolderName = ReplaceString("<DataName>:", NewDataFolderName, "")
	if (UseFileNameAsFolder && !stringmatch(NewDataFolderName, "*<filename>*" ))
		NewDataFolderName+="<fileName>:"
	endif		
	if (!stringmatch(NewDataFolderName, "*<DataName>*" ))
		NewDataFolderName+="<DataName>:"
	endif		
	setDataFolder OldDf
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function CS_XMLGUICheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	NVAR UseFileNameAsFolder = root:Packages:CS_XMLreader_GUI:UseFileNameAsFolder
	NVAR UseIndra2Names = root:Packages:CS_XMLreader_GUI:UseIndra2Names
	NVAR UseQRSNames = root:Packages:CS_XMLreader_GUI:UseQRSNames
	NVAR UseQISNames = root:Packages:CS_XMLreader_GUI:UseQISNames
	NVAR ConvertQToA = root:Packages:CS_XMLreader_GUI:ConvertQToA
	NVAR ConvertQTonm = root:Packages:CS_XMLreader_GUI:ConvertQTonm
	
	SVAR NewDataFolderName = root:packages:CS_XMLreader_GUI:NewDataFolderName
	SVAR NewIWaveName= root:packages:CS_XMLreader_GUI:NewIWaveName
	SVAR NewQwaveName= root:packages:CS_XMLreader_GUI:NewQWaveName
	SVAR NewIdevWaveName= root:packages:CS_XMLreader_GUI:NewIdevWaveName
	SVAR NewQdevWaveName= root:packages:CS_XMLreader_GUI:NewQdevWaveName
	SVAR NewQfwhmWavename= root:packages:CS_XMLreader_GUI:NewQfwhmWavename
	SVAR NewQmeanWavename= root:packages:CS_XMLreader_GUI:NewQmeanWavename
	SVAR NewShadowWavename= root:packages:CS_XMLreader_GUI:NewShadowWavename
	
	if(stringmatch(ctrlName,"ConvertQTonm") && checked)
		ConvertQToA = 0
	endif
	if(stringmatch(ctrlName,"ConvertQToA") && checked)
		ConvertQTonm=0
	endif

	if(cmpstr(ctrlName,"UseFileNameAsFolder")==0)	
		if(!checked)
			UseIndra2Names = 0
			if (!UseQRSNames && !UseQRSNames)
				NewDataFolderName = ""	
				NewIWaveName= ""
				NewQwaveName= ""
				NewIdevWaveName= ""
			endif
			if (stringmatch(NewDataFolderName, "*<fileName>*"))
				NewDataFolderName = RemoveFromList("<fileName>", NewDataFolderName , ":")
			endif
			if (!stringmatch(NewDataFolderName, "*<DataName>*" ))
				NewDataFolderName+="<DataName>:"
			endif		
		else
			NewDataFolderName = ReplaceString("<DataName>:", NewDataFolderName, "")
			if (!stringmatch(NewDataFolderName, "*<fileName>*"))
				if(strlen(NewDataFolderName)==0)
					NewDataFolderName="root:"
				endif
				NewDataFolderName+="<fileName>:"
			endif		
			if (!stringmatch(NewDataFolderName, "*<DataName>*" ))
				NewDataFolderName+="<DataName>:"
			endif		
		endif
	endif
	
	
	
	if(cmpstr(ctrlName,"UseIndra2Names")==0)
//		CheckBox ImportSMRdata, disable= !checked
//		NVAR ImportSMRdata=root:Packages:ImportData:ImportSMRdata
		if(checked)
			UseFileNameAsFolder = 1
			UseQRSNames = 0
			UseQISNames = 0
			//UseIndra2Names = 0
//			if (ImportSMRdata)
//				NewDataFolderName = "root:USAXS:ImportedData:<fileName>:"	
//				NewIWaveName= "SMR_Int"
//				NewQwaveName= "SMR_Qvec"
//				NewIdevWaveName= "SMR_Error"
//			else
				NewDataFolderName = "root:USAXS:ImportedData:<fileName>:<DataName>"	
				NewIWaveName= "DSM_Int"
				NewQwaveName= "DSM_Qvec"
				NewIdevWaveName= "DSM_Error"
				NewQdevWaveName= "---"
				NewQfwhmWavename="---"
				NewQmeanWavename="---"
				NewShadowWavename ="---"
//			endif
		endif
	endif

	if(cmpstr(ctrlName,"UseQRSNames")==0)
		if(checked)
			UseQISNames = 0
			UseIndra2Names = 0
			NewDataFolderName = "root:SAS:ImportedData:"	
			if (UseFileNameAsFolder)
				NewDataFolderName+="<fileName>:"
			endif	
			NewDataFolderName+="<DataName>:"	
			NewIWaveName= "R_<dataName>"
			NewQwaveName= "Q_<dataName>"
			NewIdevWaveName= "S_<dataName>"
			NewQdevWaveName= "W_<dataName>"
			NewQfwhmWavename="---"
			NewQmeanWavename="---"
			NewShadowWavename ="---"
		endif
	endif
	if(cmpstr(ctrlName,"UseQISNames")==0)
		if(checked)
			UseQRSNames = 0
			UseIndra2Names = 0
			NewDataFolderName = "root:SAS:ImportedData:"	
			if (UseFileNameAsFolder&& !stringmatch(NewDataFolderName, "<filename>" ))
				NewDataFolderName+="<fileName>:"
			endif		
			NewDataFolderName+="<DataName>:"	
			NewIWaveName= "<dataName>_i"
			NewQwaveName= "<dataName>_q"
			NewIdevWaveName= "<dataName>_s"
			NewQdevWaveName= "<dataName>_res"
			NewQfwhmWavename="---"
			NewQmeanWavename="---"
			NewShadowWavename ="---"
		endif
	endif

end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function CS_XMLImportPopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	if (Cmpstr(ctrlName,"SelectFolderNewData")==0)
		SVAR NewDataFolderName = root:packages:CS_XMLreader_GUI:NewDataFolderName
		NewDataFolderName = popStr
			NVAR UseFileNameAsFolder = root:Packages:CS_XMLreader_GUI:UseFileNameAsFolder
			if (UseFileNameAsFolder && !stringmatch(NewDataFolderName, "<filename>" ))
				NewDataFolderName+="<fileName>:"
			endif		
	endif
End
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function CS_XMLGUIButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	if(cmpstr(ctrlName,"SelectDataPath")==0)
		CS_XMLGUISelectDataPathforGUI()	
		CS_XMLGUIUpdateListOfFilesInWvs()
	endif
	if(cmpstr(ctrlName,"Preview")==0)
		CS_XMLGUITestImportNotebook()
	endif
	if(cmpstr(ctrlName,"SelectAll")==0)
		CS_XMLGUISelectDeselectAll(1)
	endif
	if(cmpstr(ctrlName,"DeselectAll")==0)
		CS_XMLGUISelectDeselectAll(0)
	endif
	if(cmpstr(ctrlName,"ImportData")==0)
		CS_XMLGUIImportDataFnct()
	endif
End

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function CS_XMLGUIImportDataFnct()

	string OldDf = getDataFolder(1)
	KillDataFOlder/Z root:Packages:CS_XMLreader
	
	Wave/T WaveOfFiles      = root:Packages:CS_XMLreader_GUI:WaveOfFiles
	Wave WaveOfSelections = root:Packages:CS_XMLreader_GUI:WaveOfSelections

	variable i, imax
	string SelectedFile
	imax = numpnts(WaveOfSelections)
	pathInfo XMLImportDataPath
	string fixedPathStr=ParseFilePath(5,S_path,"*",0,0)
	for(i=0;i<imax;i+=1)
		if (WaveOfSelections[i])
			selectedfile = WaveOfFiles[i]
			print fixedPathStr+selectedfile
			IF (CS_XmlReader(fixedPathStr+selectedfile) == 0)					// did the XML reader return without an error code?
				CS_XMLGUICopyXmlDataToFinalFldr()								// move the data to my directory, data from the file are in subfolders
			ENDIF
		endif
	endfor

	KillDataFOlder/Z root:Packages:CS_XMLreader

	setDataFolder OldDf
end
// ==================================================================
// ==================================================================
// ==================================================================


FUNCTION CS_XMLGUICopyXmlDataToFinalFldr()
	//all subfolders of srcDir are data from the XML file... 

	string OldDf = GetDataFolder(1)
	STRING srcDir = "root:Packages:CS_XMLreader"
	setDataFolder srcDir
	string ListOfFFldrsToProcess= IN2G_CreateListOfItemsInFolder(GetDataFOlder(1), 1)	//list of all data sets found in the XML file
	ListOfFFldrsToProcess = RemoveEnding(ListOfFFldrsToProcess , ";\r")
	variable i, NumFIlesFound
	NumFIlesFound = (ItemsInList(ListOfFFldrsToProcess,";") -1) ? 1 : 0
	For(i=0;i<ItemsInList(ListOfFFldrsToProcess,";");i+=1)
		CS_XMLGUICopyOneFldrWithDta(StringFromList(i,ListOfFFldrsToProcess,";"), NumFIlesFound)
	endfor	

	setDataFolder OldDf
END
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function CS_XMLGUICopyOneFldrWithDta(FolderNameStr, MoreFoldersFound)
	string FolderNameStr
	variable MoreFoldersFound		//set to 1 when more than 1 data set was found. In this case need to copy data to subfolders 
	
	string OldDf = GetDataFolder(1)
	setDataFolder FolderNameStr			
	string olddf2 = GetDataFolder(1)
	SVAR xmlFile = root:Packages:CS_XMLreader:xmlFile
	variable i
	string TempName2
	//this is a big mess where we need to create names...
	string tempNameFldr = xmlFile			//this is name of the file loaded = <fileName>
	tempNameFldr = stringfromList(ItemsInList(tempNameFldr,":")-1,tempNameFldr,":")	//and here is should be cleaned up 
	tempNameFldr = ReplaceString(".xml",tempNameFldr, "")
	tempNameFldr = Cleanupname(tempNameFldr,1)						//at this moment the name should be valid Igor name for <fileName>

	SVAR NewDataFolderName = root:packages:CS_XMLreader_GUI:NewDataFolderName
	//now construct the name...
	//first replace the <fileName>. This is never compulsory...
	string tempName = ReplaceString("<fileName>", NewDataFolderName, PossiblyQUoteName(tempNameFldr))
	
	//however, <dataname> is compulsory, if MoreFolderFound==1, or the data would overwrite themselves... 
	if(MoreFoldersFound && !stringmatch(tempName, "*<DataName>*" ))
		tempName += "<DataName>:"
	endif
	if(MoreFoldersFound && !stringmatch(tempNameFldr, "*<DataName>*" ))
		tempNameFldr +=":<DataName>:"
	endif
	if(ItemsInList(IN2G_CreateListOfItemsInFolder(GetDataFOlder(1), 1), ";") < 1)		//this items is number of SAS data folders in this folder. If 0, then all data are here and not in subfolders
		tempName = ReplaceString("<DataName>",tempName, GetDataFolder(0))
	//	tempNameFldr =ReplaceString(":<DataName>:",tempNameFldr, "")		//change 9 03 09 to simplify final data structure...
		tempNameFldr =FolderNameStr
		tempName = CS_XMLGUICreateNewFldr(tempName)									//creates new folder, if exists checks with use\r what to do and fixes the name as needed....
		CS_XMLGUICopyOneDataToFldr(tempName, tempNameFldr)
	else																						//multiple data are in this folder, need to move there and force more names on user if not set to do that...  
		tempName = ReplaceString("<DataName>",tempName, GetDataFolder(0))
		tempNameFldr =ReplaceString("<DataName>",tempNameFldr, GetDataFolder(0))
		//print GetDataFolder(1)
		//print IN2G_CreateListOfItemsInFolder(GetDataFOlder(1), 1)
		For(i=0;i<ItemsInList(IN2G_CreateListOfItemsInFolder(GetDataFOlder(1), 1), ";");i+=1)		//item 0 is parent folder, start from 1
			tempNameFldr = stringfromList(i,IN2G_CreateListOfItemsInFolder(GetDataFOlder(1), 1),";")
			TempName2 = tempName +  stringfromList(i,IN2G_CreateListOfItemsInFolder(GetDataFOlder(1), 1),";")+":"
			TempName2 = CS_XMLGUICreateNewFldr(TempName2)							//creates new folder, if exists checks with user what to do and fixes the name as needed....
			setDataFolder tempNameFldr
				CS_XMLGUICopyOneDataToFldr(TempName2, tempNameFldr)
			setDataFolder OldDf2
		endfor
	endif
	setDataFolder OldDf
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function/T CS_XMLGUICreateNewFldr(DataFldrStr)
	string DataFldrStr
	string OldDf = GetDataFolder(1)

	Variable i
	string tempStr
	NVAR OverwriteOnImport= root:packages:CS_XMLreader_GUI:OverwriteOnImport
	if(!OverwriteOnImport)		//check for existence of this folder...
		if(DataFolderExists(DataFldrStr))
			DoAlert 2, "The folder for data called :" + DataFldrStr +"  exists, Overwrite (=YES), Rename (=NO), or Cancel?"
			if(V_Flag==3)
				setDataFolder OldDf
				abort
			elseif(V_Flag==2)
				Do
					tempStr = DataFldrStr[0,strlen(DataFldrStr)-2]+"_"+num2str(i)+":"
					i+=1
				while  (DataFolderExists(tempStr))
				DataFldrStr = tempStr
				print "Data will be stored in " + DataFldrStr
			else
				print "Data were written in existing folder " + DataFldrStr
			endif 
		endif
	endif

	setDataFolder root:
	string tempFldrNm
	for(i=0;i<ItemsInList(DataFldrStr,":");i+=1)
		tempFldrNm =ReplaceString("'", stringFromList(i,DataFldrStr,":"), "") 
		if(!stringmatch(tempFldrNm,"root"))
			NewDataFolder/O/S  $tempFldrNm		
		endif
	endfor
	setDataFolder OldDf
	return  DataFldrStr
end

//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function CS_XMLGUICopyOneDataToFldr(TargetFolder, NewWvName)		//here we copy the data to new folde3rs as instruected. 
	string TargetFolder, NewWvName		//this is the part of <fileName> or <dataName>
		
	string OldDf = GetDataFolder(1)
	Wave/T/Z metadata		//if one of these two exists, we are in folder with data, if not, then the data are in subfolders...
	Wave/T/Z admin

	if(WaveExists(metadata) || WaveExists(admin))
	
		SVAR NewDataFolderName = root:packages:CS_XMLreader_GUI:NewDataFolderName
		SVAR NewIWaveName= root:packages:CS_XMLreader_GUI:NewIWaveName
		SVAR NewQwaveName= root:packages:CS_XMLreader_GUI:NewQWaveName
		SVAR NewIdevWaveName= root:packages:CS_XMLreader_GUI:NewIdevWaveName
		SVAR NewQdevWaveName= root:packages:CS_XMLreader_GUI:NewQdevWaveName
	
		SVAR NewQfwhmWavename= root:packages:CS_XMLreader_GUI:NewQfwhmWavename
		SVAR NewQmeanWavename= root:packages:CS_XMLreader_GUI:NewQmeanWavename
		SVAR NewShadowWavename= root:packages:CS_XMLreader_GUI:NewShadowWavename
	
		NVAR UseQISNames = root:packages:CS_XMLreader_GUI:UseQISNames
		NVAR UseIndra2Names = root:packages:CS_XMLreader_GUI:UseIndra2Names
		
		Wave/Z Qsas
		Wave/Z Isas
		Wave/Z Idev
		Wave/Z Qdev
		Wave/Z Qfwhm
		Wave/Z Qmean
		Wave/Z ShadowFactor
	
		String FolderList
		
		if(WaveExists(metadata))
			Duplicate/O/T metadata, $(TargetFolder+"metadata")
		endif
		if(WaveExists(admin))
			Duplicate/O/T admin, $(TargetFolder+"admin")
		endif
	
		
		string tempName=PossiblyQUoteName(ReplaceString("<dataName>", NewIWaveName, NewWvName))
		if(WaveExists(Isas))
			Duplicate/O Isas, $(TargetFolder+tempName)
		endif
		tempName=PossiblyQUoteName(ReplaceString("<dataName>", NewQwaveName, NewWvName))
		if(WaveExists(Qsas))
			Duplicate/O Qsas, $(TargetFolder+tempName)
			Wave Qwv = $(TargetFolder+tempName)
			CS_XMLGUICOnvertQUnits(Qwv)
		endif
		tempName=PossiblyQUoteName(ReplaceString("<dataName>", NewIdevWaveName, NewWvName))
		if(WaveExists(Idev))
			Duplicate/O Idev, $(TargetFolder+tempName)
		endif
		
		if (UseQISNames)			//QIS saves 4 columns in the same wave ... 
			tempName=PossiblyQUoteName(ReplaceString("<dataName>", NewQdevWaveName, NewWvName))
			Make/O/N=(numpnts(Idev),4) $(TargetFolder+tempName)
			Wave resWv= $(TargetFolder+tempName)
			
			if(WaveExists(Qdev))
				resWv[][0] = Qdev
				SetScale d 0, 1, WaveUnits(Qdev,0), resWv				// update the wave's "UNITS" string
				SetScale x 0, 1, WaveUnits(Qdev,0), resWv				// put it here, too, for the Data Browser
			endif
			if(WaveExists(Qfwhm))			
				resWv[][1] = Qfwhm
			endif
			if(WaveExists(ShadowFactor))
				resWv[][2] = ShadowFactor
			endif
			if(WaveExists(Qmean))
				resWv[][3] = Qmean
			endif		
			CS_XMLGUICOnvertQUnits(resWv)
		elseif(UseIndra2Names)
			//these data do not exist in Indra 2 data.... 
		else
			tempName=PossiblyQUoteName(ReplaceString("<dataName>", NewQdevWaveName, NewWvName))
			if(WaveExists(Qdev) && !stringmatch(tempName, "---" ))
				Duplicate/O Qdev, $(TargetFolder+tempName)
				Wave Qwv = $(TargetFolder+tempName)
				CS_XMLGUICOnvertQUnits(Qwv)
			endif
			tempName=PossiblyQUoteName(ReplaceString("<dataName>", NewQfwhmWavename, NewWvName))
			if(WaveExists(Qfwhm) && !stringmatch(tempName, "---" ))
				Duplicate/O Qfwhm, $(TargetFolder+tempName)
				Wave Qwv = $(TargetFolder+tempName)
				CS_XMLGUICOnvertQUnits(Qwv)
			endif
			tempName=PossiblyQUoteName(ReplaceString("<dataName>", NewQmeanWavename, NewWvName))
			if(WaveExists(Qmean) && !stringmatch(tempName, "---" ))
				Duplicate/O Qmean, $(TargetFolder+tempName)
				Wave Qwv = $(TargetFolder+tempName)
				CS_XMLGUICOnvertQUnits(Qwv)
			endif
			tempName=PossiblyQUoteName(ReplaceString("<dataName>", NewShadowWavename, NewWvName))
			if(WaveExists(ShadowFactor) && !stringmatch(tempName, "---" ))
				Duplicate/O ShadowFactor, $(TargetFolder+tempName)
			endif
		endif
	else			//OK, metadata do nto exists, so we need to go down even more in the folder structure... 
		variable numOfFolder= 	ItemsInList(IN2G_CreateListOfItemsInFolder(GetDataFOlder(1), 1), ",")
		variable i
		string OldDf2, tempNameFldr2, tempNameFldr, TempName2
		if(i<2)
			Abort "problem loading data in CS_XMLGUICopyOneDataToFldr, send XML data file to ilavsky@aps.anl.gov"
		else	
			olddf2 = GetDataFolder(1)
			//TargetFolder, NewWvName
			For(i=0;i<numOfFolder;i+=1)
			tempNameFldr = NewWvName+":"+stringfromList(i,IN2G_CreateListOfItemsInFolder(GetDataFOlder(1), 1),";")
			TempName2 = TargetFolder+":"+stringfromList(i,IN2G_CreateListOfItemsInFolder(GetDataFOlder(1), 1),";")
			TempName2 = CS_XMLGUICreateNewFldr(TempName2)			//creates new folder, if exists checks with user what to do and fixes the name as needed....
			setDataFolder stringfromList(i,IN2G_CreateListOfItemsInFolder(GetDataFOlder(1), 1),";")
				CS_XMLGUICopyOneDataToFldr(TempName2, tempNameFldr)
			setDataFolder OldDf2
			endfor
		endif
	endif
	
	setDataFolder OldDf
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function CS_XMLGUICOnvertQUnits(Qwave)
	wave Qwave

	NVAR ConvertQTonm = root:packages:CS_XMLreader_GUI:ConvertQTonm
	NVAR ConvertQToA = root:packages:CS_XMLreader_GUI:ConvertQToA

	if(stringmatch(WaveUnits(Qwave,0),"1/nm") && ConvertQToA)
		Qwave = Qwave/10
		SetScale d 0, 1, "1/A", Qwave				// update the wave's "UNITS" string
		SetScale x 0, 1, "1/A", Qwave				// put it here, too, for the Data Browser
		print "Converted Q to 1/A for wave named :  "+NameOfWave(Qwave)
		note/K Qwave, ReplaceStringByKey("unit",note(Qwave), "1/A",":",";")
	elseif(stringmatch(WaveUnits(Qwave,0),"1/A") && ConvertQTonm)
		Qwave = Qwave * 10
		SetScale d 0, 1, "1/nm", Qwave				// update the wave's "UNITS" string
		SetScale x 0, 1, "1/nm", Qwave				// put it here, too, for the Data Browser
		print "Converted Q to 1/nm for wave named :  "+NameOfWave(Qwave)
		note/K Qwave, ReplaceStringByKey("unit",note(Qwave), "1/nm",":",";")
	endif	 
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function CS_XMLGUISelectDataPathforGUI()

	NewPath /M="Select path to data to be imported from" /O XMLImportDataPath
	if (V_Flag!=0)
		abort
	endif 
	PathInfo XMLImportDataPath
	SVAR DataPathName=root:Packages:CS_XMLreader_GUI:DataPathName
	DataPathName = S_Path
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************

Function CS_XMLGUISelectDeselectAll(SetNumber)
		variable setNumber
		
		Wave WaveOfSelections=root:Packages:CS_XMLreader_GUI:WaveOfSelections

		WaveOfSelections = SetNumber
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************


Function CS_XMLGUIInitializeImportData()
	
	string OldDf = GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:CS_XMLreader_GUI
	
	string ListOfStrings
	string ListOfVariables
	variable i
	
	ListOfStrings = "DataPathName;DataExtension;IntName;QvecName;ErrorName;NewDataFolderName;"
	ListOfStrings+="NewIWaveName;NewQWaveName;NewIdevWaveName;NewQdevWavename;NewQfwhmWavename;NewQmeanWavename;NewShadowWavename;"
	ListOfVariables = "UseFileNameAsFolder;UseIndra2Names;UseQRSNames;UseQISNames;DataContainErrors;"
	ListOfVariables += "ImportSMRData;ConvertQToA;ConvertQTonm;OverwriteOnImport;"

		//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		CS_XMLGUICreateItemInCurFldr("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		CS_XMLGUICreateItemInCurFldr("string",StringFromList(i,ListOfStrings))
	endfor	

	Make/O/T/N=0 WaveOfFiles
	Make/O/N=0 WaveOfSelections
	
	ListOfVariables = "UseFileNameAsFolder;"	
	//Set numbers to 0
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR test=$(StringFromList(i,ListOfVariables))
		test =0
	endfor		
	SVAR DataExtension
	if(strlen(DataExtension)<1)
		DataExtension = ".XML"
	endif
	
	NVAR UseQRSNames
	NVAR UseQISNames
	NVAR UseIndra2Names
	if((UseIndra2Names+UseQISNames+UseQRSNames)>1)
		UseQRSNames = 1
		UseQISNames = 0
		UseIndra2Names = 0
	endif	
	CS_XMLGUIUpdateListOfFilesInWvs()
end


//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//**********************************************************************************************
//**********************************************************************************************
Function CS_XMLGUICreateItemInCurFldr(TheSwitch,NewName)
	string TheSwitch, NewName
//this function creates strings or variables with the name passed
	if (cmpstr(TheSwitch,"string")==0)
		SVAR/Z test=$NewName
		if (!SVAR_Exists(test))
			string/g $NewName
			SVAR testS=$NewName
			testS=""
		endif
	endif
	if (cmpstr(TheSwitch,"variable")==0)
		NVAR/Z testNum=$NewName
		if (!NVAR_Exists(testNum))
			variable/g $NewName
			NVAR testV=$NewName
			testV=0
		endif
	endif
end
//**********************************************************************************************
//**********************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function CS_XMLGUITestImportNotebook()

	Wave/T WaveOfFiles      = root:Packages:CS_XMLreader_GUI:WaveOfFiles
	Wave WaveOfSelections = root:Packages:CS_XMLreader_GUI:WaveOfSelections
	variable i, imax, firstSelectedPoint, maxWaves
	string SelectedFile
	imax = numpnts(WaveOfSelections)
	firstSelectedPoint = NaN
	For(i=0;i<numpnts(WaveOfSelections);i+=1)
		if(WaveOfSelections[i]==1)
			firstSelectedPoint = i
			break
		endif
	endfor
	if (numtype(firstSelectedPoint)==2)
		abort
	endif
	selectedfile = WaveOfFiles[firstSelectedPoint]
	
	
	//LoadWave/Q/A/G/P=ImportDataPath  selectedfile
	DOwindow FilePreview
	if (V_Flag)
		DoWindow/K FilePreview
	endif
	OpenNotebook /K=1 /N=FilePreview /P=XMLImportDataPath /R /V=1 selectedfile
	MoveWindow /W=FilePreview 350, 5, 700, 400	
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
Function CS_XMLGUIUpdateListOfFilesInWvs()

	SVAR DataPathName = root:Packages:CS_XMLreader_GUI:DataPathName
	SVAR DataExtension  = root:Packages:CS_XMLreader_GUI:DataExtension
	Wave/T WaveOfFiles      = root:Packages:CS_XMLreader_GUI:WaveOfFiles
	Wave WaveOfSelections = root:Packages:CS_XMLreader_GUI:WaveOfSelections
	string ListOfAllFiles
	string LocalDataExtension
	variable i, imax
	LocalDataExtension = DataExtension
	if (cmpstr(LocalDataExtension[0],".")!=0)
		LocalDataExtension = "."+LocalDataExtension
	endif
	PathInfo XMLImportDataPath
	if(V_Flag && strlen(DataPathName)>0)
		if (strlen(LocalDataExtension)<=1)
			ListOfAllFiles = IndexedFile(XMLImportDataPath,-1,"????")
		else		
			ListOfAllFiles = IndexedFile(XMLImportDataPath,-1,LocalDataExtension)
		endif
		imax = ItemsInList(ListOfAllFiles,";")
		Redimension/N=(imax) WaveOfSelections
		Redimension/N=(imax) WaveOfFiles
		for (i=0;i<imax;i+=1)
			WaveOfFiles[i] = stringFromList(i, ListOfAllFiles,";")
		endfor
	else
		Redimension/N=0 WaveOfSelections
		Redimension/N=0 WaveOfFiles
	endif 
end
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************