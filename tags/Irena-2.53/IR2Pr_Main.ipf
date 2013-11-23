#pragma rtGlobals=1		// Use modern global access method.
#include "IN2_GeneralProcedures", version>=1.46
#include "IR2_PanelCntrlProcs", version>=1.04
#include "IR1_Recording"
#include "IR2Pr_Regularization"
#include "IR2Pr_PDFMain"


//this is new Main loading procedure for Pair distance distribution function for those, who do not want whole Irena package...


Menu "PDDF"
	help = {"PDDF function from Irena SAS modeling macros, version 2.31 released 10/1/2008 by Jan Ilavsky"}
	"Pair distance dist. fnct.", IR2Pr_MainPDDF()
	help={"Calculate pair distribution function using various methods"}
	"Configure Common Items",IR2C_ConfigMain()
	help={"Here you can configure default values for common items, such as font sizes and font types"}
end

///////////////////////////////////////////
//****************************************************************************************
//		Default variables and strings
//
//	these are known at this time:
//		Variables=LegendSize;TagSize;AxisLabelSize;
//		Strings=FontType;
//
//	how to use:
// 	When needed insert font size through lookup function - e.g., IR2C_LkUpDfltVar("LegendSize")
//	or for font type IR2C_LkUpDfltStr("FontType")
//	NOTE: Both return string values, because that is what is generally needed!!!!
// further variables and strings can be added, but need to be added to control panel too...
//	see example in : IR1_LogLogPlotU()  in this procedure file... 


override Function/S IR2C_LkUpDfltStr(StrName)
	string StrName

	string result
	string OldDf=getDataFolder(1)
	SetDataFolder root:
	if(!DataFolderExists("root:Packages:IrenaConfigFolder"))
		IR2C_InitConfigMain()
	endif
	SetDataFolder root:Packages
	setDataFolder root:Packages:IrenaConfigFolder
	SVAR /Z curString = $(StrName)
	if(!SVAR_exists(curString))
		IR2C_InitConfigMain()
		SVAR curString = $(StrName)
	endif	
	result = 	"'"+curString+"'"
	setDataFolder OldDf
	return result
end

override Function/S IR2C_LkUpDfltVar(VarName)
	string VarName

	string result
	string OldDf=getDataFolder(1)
	SetDataFolder root:
	if(!DataFolderExists("root:Packages:IrenaConfigFolder"))
		IR2C_InitConfigMain()
	endif
	SetDataFolder root:Packages
	setDataFolder root:Packages:IrenaConfigFolder
	NVAR /Z curVariable = $(VarName)
	if(!NVAR_exists(curVariable))
		IR2C_InitConfigMain()
		NVAR curVariable = $(VarName)
	endif	
	if(curVariable>=10)
		result = num2str(	curVariable)
	else
		result = "0"+num2str(	curVariable)
	endif
	setDataFolder OldDf
	return result
end


override Function IR2C_ConfigMain()

	//this is main configuration utility... 
	IR2C_InitConfigMain()
	DoWindow IR2C_MainConfigPanel
	if(!V_Flag)
		Execute ("IR2C_MainConfigPanel()")
	else
		DoWindow/F IR2C_MainConfigPanel
	endif

end
override Function IR2C_InitConfigMain()

	//initialize lookup parameters for user selected items.
	string OldDf=getDataFolder(1)
	SetDataFolder root:
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:IrenaConfigFolder
	
	string ListOfVariables
	string ListOfStrings
	//here define the lists of variables and strings needed, separate names by ;...
	ListOfVariables="LegendSize;TagSize;AxisLabelSize;LegendUseFolderName;LegendUseWaveName;"
	ListOfStrings="FontType;ListOfKnownFontTypes;"
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	//Now set default values
	String VariablesDefaultValues
	String StringsDefaultValues
	if (stringMatch(IgorInfo(3),"*Windows*"))		//Windows
		VariablesDefaultValues="LegendSize:8;TagSize:8;AxisLabelSize:8;LegendUseFolderName:0;LegendUseWaveName:0;"
	else
		VariablesDefaultValues="LegendSize:10;TagSize:10;AxisLabelSize:10;LegendUseFolderName:0;LegendUseWaveName:0;"
	endif
	StringsDefaultValues="FontType:Times;"
	
	variable CurVarVal
	string CurVar, CurStr, CurStrVal
	For(i=0;i<ItemsInList(VariablesDefaultValues);i+=1)
		CurVar = StringFromList(0,StringFromList(i, VariablesDefaultValues),":")
		CurVarVal = numberByKey(CurVar, VariablesDefaultValues)
		NVAR temp=$(CurVar)
		if(temp==0)
			temp = CurVarVal
		endif
	endfor
	For(i=0;i<ItemsInList(StringsDefaultValues);i+=1)
		CurStr = StringFromList(0,StringFromList(i, StringsDefaultValues),":")
		CurStrVal = stringByKey(CurStr, StringsDefaultValues)
		SVAR tempS=$(CurStr)
		if(strlen(tempS)<1)
			tempS = CurStrVal
		endif
	endfor
	
	SVAR ListOfKnownFontTypes=ListOfKnownFontTypes
	ListOfKnownFontTypes="Times;Arial;Courier;"
	
	
	setDataFolder OldDf
end

override Function IR2C_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	if (cmpstr(ctrlName,"LegendSize")==0)
		NVAR LegendSize=root:Packages:IrenaConfigFolder:LegendSize
		LegendSize = str2num(popStr)
	endif
	if (cmpstr(ctrlName,"TagSize")==0)
		NVAR TagSize=root:Packages:IrenaConfigFolder:TagSize
		TagSize = str2num(popStr)
	endif
	if (cmpstr(ctrlName,"AxisLabelSize")==0)
		NVAR AxisLabelSize=root:Packages:IrenaConfigFolder:AxisLabelSize
		AxisLabelSize = str2num(popStr)
	endif
	if (cmpstr(ctrlName,"FontType")==0)
		SVAR FontType=root:Packages:IrenaConfigFolder:FontType
		FontType = popStr
	endif
End

override Function IR2C_MainConfigPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(282,48,707,356) as "Irena Main Config Panel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,0,52224)
	DrawText 50,35,"Irena package main user configuration"
	PopupMenu LegendSize,pos={35,74},size={113,21},proc=IR2C_PopMenuProc,title="Legend Size"
	NVAR LegendSize = root:Packages:IrenaConfigFolder:LegendSize
	PopupMenu LegendSize,mode=7,popvalue=num2str(LegendSize),value= #"\"8;9;10;11;12;14;16;18;20;24;26;30;\""
//LegendUseFolderName:1;LegendUseWaveName
	CheckBox LegendUseFolderName,pos={195,65},size={25,16},noproc,title="Legend use Folder Names?"
	CheckBox LegendUseFolderName,variable= root:Packages:IrenaConfigFolder:LegendUseFolderName, help={"Check to use folder names in legends?"}
	CheckBox LegendUseWaveName,pos={195,85},size={25,16},noproc,title="Legend use Wave Names?"
	CheckBox LegendUseWaveName,variable= root:Packages:IrenaConfigFolder:LegendUseWaveName, help={"Check to use wave names in legends?"}
	PopupMenu TagSize,pos={49,118},size={96,21},proc=IR2C_PopMenuProc,title="Tag Size"
	NVAR TagSize = root:Packages:IrenaConfigFolder:TagSize
	PopupMenu TagSize,mode=7,popvalue=num2str(TagSize),value= #"\"8;9;10;11;12;14;16;18;20;24;26;30;\""
	PopupMenu AxisLabelSize,pos={46,157},size={103,21},proc=IR2C_PopMenuProc,title="Label Size"
	NVAR AxisLabelSize = root:Packages:IrenaConfigFolder:AxisLabelSize
	PopupMenu AxisLabelSize,mode=7,popvalue=num2str(AxisLabelSize),value= #"\"8;9;10;11;12;14;16;18;20;24;26;30;\""
	PopupMenu FontType,pos={48,205},size={114,21},proc=IR2C_PopMenuProc,title="Font type"
	SVAR FontType = root:Packages:IrenaConfigFolder:FontType
	PopupMenu FontType,mode=1,popvalue=FontType,value= #"root:Packages:IrenaConfigFolder:ListOfKnownFontTypes"
EndMacro

