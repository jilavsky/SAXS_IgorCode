#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.01

//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.01 added license for ANL

//this is attempt to develop style using for Irena.


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//Function IR1U_StyleButtonCotrol(ctrlName) : ButtonControl
//	String ctrlName
//	
//	if (cmpstr("SaveStyle",ctrlName)==0)
//		//then here save the style macro
//		IR1U_CreateNewStyle()
//	endif
//	if (cmpstr("ApplyStyle",ctrlName)==0)
//		//then here Apply the style macro
//		IR1U_ApplyStyleMacro()
//	endif
//
//End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1U_CreateNewStyle()

	string OldDf
	OldDf=GetDataFolder(1)
	NewDataFolder/S/O root:Packages:UserStyleMacros
	string NewName="Saved style Macro"
	string NewNameBckp
	if (stringMatch(StringList("*",";"),"*"+NewName+";*"))
		Newname = UniqueName(NewName, 4,0)
	endif
	Prompt NewName, "What is new name of this style?"
	DoPrompt "test", NewName
	if (V_Flag)
		abort
	endif
	NewNameBckp=NewName
	if (stringmatch(StringList("*",";"),"*"+NewName+";*"))
		Newname = UniqueName(NewName, 4,0)
		DoAlert 2, "This name exists, \ruse new name :   "+NewName+"    (Yes) \ror overwrite old one   (No)? \rCancel to stop macro."
		if (V_Flag==3)
			abort
		endif
		if(V_Flag==2)
			Newname=NewNameBckp
		endif
	endif
	string WinStyle=WinRecreation("", 1 )
	string/g $newName
	SVAR Nm=$NewName
	Nm=WinStyle
	SetDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_ApplyStyleMacro()
	
	string OldDf
	OldDf=GetDataFolder(1)
	NewDataFolder/S/O root:Packages:UserStyleMacros
	
	string ListOfStyles=IN2G_ConvertDataDirToList(DataFolderDir(8))
	
	String StyleToApply
	Prompt StyleToApply, "Select style to apply", popup, ListOfStyles
	DoPrompt "Select", StyleToApply
	if(V_Flag)
		abort
	endif
	
	SVAR StyleApply=$StyleToApply
	variable ItemLines=ItemsInList(StyleApply,"\r")
	variable i
//	DoWindow/F Graph1
	//reset the graph into basic style...
  	ModifyGraph/Z mode=1  
  	ModifyGraph/Z msize=1  
  	ModifyGraph/Z log=0  
  	ModifyGraph/Z mirror=0  
  	Label/Z left ""  
  	Label/Z bottom ""  
  	//and now modify to users taste
	For(i=2;i<ItemLines-1;i+=1)
		Execute (StringFromList(i, StyleApply , "\r"))
		print StringFromList(i, StyleApply , "\r")
	endfor
	setDataFolder OldDf
end