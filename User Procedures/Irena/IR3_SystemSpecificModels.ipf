#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=1.01


//*************************************************************************\
//* Copyright (c) 2005 - 2021, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/


//version notes:
//	1.01 add handling of USAXS M_... waves 
//	1.0 Original release, 1/2/2021


//this is now System Specific Models, replacement for Analytical models. 
// SysSpecModels = short name of package
// IR3S = working prefix, short (e.g., IR3DM) 
// add IR3S_MainCheckVersion to Irena aftercompile hook function correctly
//To add model in System Specific Models, follow these instructions:
//	add model parameters in ... needs to be finished... 


constant IR3SversionNumber = 1			//SysSpecModels panel version number
constant IR3SSetVariableStepRatio = 0.05	//when we change SetVariable, this is how much the step changes. 
constant IR3SSetVariableLowLimRatio = 0.2	//when we change value in model, this is how low limit is scaled. 
constant IR3SSetVariableHighLimRatio = 5	//when we change value in model, this is how high limit is scaled. 


/////******************************************************************************************
/////******************************************************************************************
/////******************************************************************************************
/////******************************************************************************************
Function IR3S_SysSpecModels()

	KillWindow/Z IR3S_SysSpecModelsPanel
	KillWindow/Z IR3S_LogLogDataDisplay

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IN2G_CheckScreenSize("width",1200)
	DoWIndow IR3S_SysSpecModelsPanel
	if(V_Flag)
		DoWindow/F IR3S_SysSpecModelsPanel
	else
		IR3S_InitSysSpecModels()
		IR3S_SysSpecModelsPanelFnct()
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("IR3S_SysSpecModelsPanel", IR3SversionNumber,1)
		IR3C_MultiUpdListOfAvailFiles("Irena:SysSpecModels")	
	endif
	IR3S_CreateSysSpecModelsGraphs()
end
////************************************************************************************************************
Function IR3S_MainCheckVersion()	
	DoWindow IR3S_SysSpecModelsPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR3S_SysSpecModelsPanel", IR3SversionNumber))
			DoAlert /T="The SysSpecModels panel was created by incorrect version of Irena " 1, "SysSpecModels needs to be restarted to work properly. Restart now?"
			if(V_flag==1)
				KillWIndow/Z IR3S_SysSpecModelsPanel
				KillWindow/Z IR3S_LogLogDataDisplay
				IR3S_SysSpecModels()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR3S_InitSysSpecModels()
			endif
		endif
	endif
end
//
////************************************************************************************************************
////************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//	UpdateAutomatically
//	Unified... 
//	ListOfVariablesUF="UseUnified;UnifRgCO;LinkUnifRgCO;"
//	ListOfVariablesUF+="UnifPwrlawP;FitUnifPwrlawP;UnifPwrlawPLL;UnifPwrlawPHL;UnifPwrlawPError;"
//	ListOfVariablesUF+="UnifPwrlawB;FitUnifPwrlawB;UnifPwrlawBLL;UnifPwrlawBHL;UnifPwrlawBError;"
//	ListOfVariablesUF+="UnifRg;FitUnifRg;UnifRgLL;UnifRgHL;UnifRgError;"
//	ListOfVariablesUF+="UnifG;FitUnifG;UnifGLL;UnifGHL;UnifGError;"

//	//Debye-Bueche parameters	
//	ListOfVariables+="DBPrefactor;DBEta;DBcorrL;DBWavelength;UseDB;"
//	ListOfVariables+="DBEtaError;DBcorrLError;"
//	ListOfVariables+="FitDBPrefactor;FitDBEta;FitDBcorrL;"
//	ListOfVariables+="DBPrefactorHL;DBEtaHL;DBcorrLHL;"
//	ListOfVariables+="DBPrefactorLL;DBEtaLL;DBcorrLLL;"
//	//Teubner-Strey Model
//	ListOfVariables+="TSPrefactor;FitTSPrefactor;TSPrefactorHL;TSPrefactorLL;TSPrefactorError;UseTS;"
//	ListOfVariables+="TSAvalue;FitTSAvalue;TSAvalueHL;TSAvalueLL;TSAvalueError;"
//	ListOfVariables+="TSC1Value;FitTSC1Value;TSC1ValueHL;TSC1ValueLL;TSC1ValueError;"
//	ListOfVariables+="TSC2Value;FitTSC2Value;TSC2ValueHL;TSC2ValueLL;TSC2ValueError;"
//	ListOfVariables+="TSCorrelationLength;TSCorrLengthError;TSRepeatDistance;TSRepDistError;"
//	//Benedetti-Ciccariello Coated Porous media Porods oscillations
//	ListOfVariables+="BCPorodsSpecSurfArea;BCSolidScatLengthDensity;BCVoidScatLengthDensity;BCLayerScatLengthDens;"
//	ListOfVariables+="BCCoatingsThickness;UseCiccBen;"
//	ListOfVariables+="BCLayerScatLengthDensHL;BCLayerScatLengthDensLL;FitBCLayerScatLengthDens;"
//	ListOfVariables+="BCCoatingsThicknessHL;BCCoatingsThicknessLL;FitBCCoatingsThickness;"
//	ListOfVariables+="BCPorodsSpecSurfAreaHL;BCPorodsSpecSurfAreaLL;FitBCPorodsSpecSurfArea;"
//	ListOfVariables+="BCPorodsSpecSurfAreaError;BCCoatingsThicknessError;BCLayerScatLengthDensError;"

//  DBPrefactor 	- ModelVarPar1
//  DBEta 		- ModelVarPar2
//  DBcorrL 		- ModelVarPar3
//  DBWavelength - ModelVarPar4

//  TSPrefactor
//  TSAvalue
//  TSC1Value
//  TSC2Value
//  TSCorrelationLength	- noedit
//  TSRepeatDistance - noedit

//	BCPorodsSpecSurfArea
//  BCSolidScatLengthDensity - no fit
//  BCVoidScatLengthDensity
//  BCLayerScatLengthDens
//  BCCoatingsThickness

////************************************************************************************************************
////************************************************************************************************************
Function IR3S_SysSpecModelsPanelFnct()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(2.25,43.25,530,815) as "System Specific Models"
	DoWIndow/C IR3S_SysSpecModelsPanel
	TitleBox MainTitle title="System Specific Models",pos={140,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:SysSpecModels","IR3S_SysSpecModelsPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,0, DoNotAddControls=1)
	IR3C_MultiAppendControls("Irena:SysSpecModels","IR3S_SysSpecModelsPanel", "IR3S_CopyAndAppendData","",1,1)
	//hide what is not needed
	checkbox UseResults, disable=1
	SetVariable DataQEnd,pos={290,90},size={190,15}, proc=IR3S_SetVarProc,title="Q max "
	Setvariable DataQEnd, variable=root:Packages:Irena:SysSpecModels:DataQEnd, limits={-inf,inf,0}
	SetVariable DataQstart,pos={290,110},size={190,15}, proc=IR3S_SetVarProc,title="Q min "
	Setvariable DataQstart, variable=root:Packages:Irena:SysSpecModels:DataQstart, limits={-inf,inf,0}
	SetVariable DataFolderName,noproc,title=" ",pos={260,160},size={270,17},frame=0, fstyle=1,valueColor=(0,0,65535)
	Setvariable DataFolderName, variable=root:Packages:Irena:SysSpecModels:DataFolderName, noedit=1

	Button SelectAll,pos={187,680},size={80,15}, proc=IR3S_ButtonProc,title="SelectAll", help={"Select All data in Listbox"}
	Button GetHelp,pos={430,50},size={80,15},fColor=(65535,32768,32768), proc=IR3S_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	PopupMenu ModelSelected,pos={280,165},size={200,20},fStyle=2,proc=IR3S_PopMenuProc,title="Function : "
	SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
	PopupMenu ModelSelected,mode=1,popvalue=ModelSelected,value= #"root:Packages:Irena:SysSpecModels:ListOfModels" 

	//	here will be model variables/controls... These will be attached to specific variables later... 
	SetVariable ModelVarPar1,pos={340,200},size={110,17},title="ModelVarPar1",proc=IR3S_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar1"}
	CheckBox FitModelVarPar1,pos={470,200},size={79,14},noproc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar2,pos={340,225},size={110,17},title="ModelVarPar2",proc=IR3S_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar3"}
	CheckBox FitModelVarPar2,pos={470,225},size={79,14},noproc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar3,pos={340,250},size={110,17},title="ModelVarPar3",proc=IR3S_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar3"}
	CheckBox FitModelVarPar3,pos={470,250},size={79,14},noproc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar4,pos={340,275},size={110,17},title="ModelVarPar3",proc=IR3S_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar3"}
	CheckBox FitModelVarPar4,pos={470,275},size={79,14},noproc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar5,pos={340,300},size={110,17},title="ModelVarPar4",proc=IR3S_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar4"}
	CheckBox FitModelVarPar5,pos={470,300},size={79,14},noproc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar6,pos={340,325},size={110,17},title="ModelVarPar5",proc=IR3S_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar5"}
	CheckBox FitModelVarPar6,pos={470,325},size={79,14},noproc,title="Fit?", help={"Fit this parameter?"}, disable=1

	Button ModelButton1,pos={300,340},size={100,15}, proc=IR3S_ButtonProc, title="Button1", help={""}, disable=1

	SetVariable ModelVarPar1LL,pos={270,365},size={80,17},title=" ",noproc, disable=1, bodywidth=70,limits={0,inf,1}, help={"Lower fitting limit Var1"}
	SetVariable ModelVarPar1UL,pos={360,365},size={120,17},title=" ",noproc, disable=1, bodywidth=70,limits={0,inf,1}, help={"Upper fitting limit Var1"}
	SetVariable ModelVarPar2LL,pos={270,385},size={80,17},title=" ",noproc, disable=1, bodywidth=70,limits={0,inf,1}, help={"Lower fitting limit Var2"}
	SetVariable ModelVarPar2UL,pos={360,385},size={120,17},title=" ",noproc, disable=1, bodywidth=70,limits={0,inf,1}, help={"Upper fitting limit Var2"}
	SetVariable ModelVarPar3LL,pos={270,405},size={80,17},title=" ",noproc, disable=1, bodywidth=70,limits={0,inf,1}, help={"Lower fitting limit Var1"}
	SetVariable ModelVarPar3UL,pos={360,405},size={120,17},title=" ",noproc, disable=1, bodywidth=70,limits={0,inf,1}, help={"Upper fitting limit Var1"}
	SetVariable ModelVarPar4LL,pos={270,425},size={80,17},title=" ",noproc, disable=1, bodywidth=70,limits={0,inf,1}, help={"Lower fitting limit Var1"}
	SetVariable ModelVarPar4UL,pos={360,425},size={120,17},title=" ",noproc, disable=1, bodywidth=70,limits={0,inf,1}, help={"Upper fitting limit Var1"}
	SetVariable ModelVarPar5LL,pos={270,445},size={80,17},title=" ",noproc, disable=1, bodywidth=70,limits={0,inf,1}, help={"Lower fitting limit Var1"}
	SetVariable ModelVarPar5UL,pos={360,445},size={120,17},title=" ",noproc, disable=1, bodywidth=70,limits={0,inf,1}, help={"Upper fitting limit Var1"}
	SetVariable ModelVarPar6LL,pos={270,465},size={80,17},title=" ",noproc, disable=1, bodywidth=70,limits={0,inf,1}, help={"Lower fitting limit Var1"}
	SetVariable ModelVarPar6UL,pos={360,465},size={120,17},title=" ",noproc, disable=1, bodywidth=70,limits={0,inf,1}, help={"Upper fitting limit Var1"}


	//here is Unified level + background. 
	CheckBox UseUnified,pos={270,480},size={79,14},proc=IR3S_MainPanelCheckProc,title="Add Unified?"
	CheckBox UseUnified,variable= root:Packages:Irena:SysSpecModels:UseUnified, help={"Add one level unified level to model data?"}
	NVAR UseUnified = root:Packages:Irena:SysSpecModels:UseUnified
	Button EstimateUF,pos={380,480},size={100,15}, proc=IR3S_ButtonProc
	Button EstimateUF, title="Estimate slope", help={"Fit power law to estimate slope of low q region"}, disable=!(UseUnified)
	SetVariable UnifG,pos={270,500},size={110,17},title="G       ",proc=IR3S_SetVarProc, disable=!(UseUnified), bodywidth=70
	SetVariable UnifG,limits={0,inf,1},value= root:Packages:Irena:SysSpecModels:UnifG, help={"G for Unified level Rg"}
	SetVariable UnifRg,pos={270,520},size={110,17},title="Rg     ",proc=IR3S_SetVarProc, disable=!(UseUnified), bodywidth=70
	SetVariable UnifRg,limits={0,inf,1},value= root:Packages:Irena:SysSpecModels:UnifRg, help={"Rg for Unified level"}	
	SetVariable UnifPwrlawB,pos={270,540},size={110,17},title="B       ",proc=IR3S_SetVarProc, disable=!(UseUnified), bodywidth=70
	SetVariable UnifPwrlawB,limits={0,inf,1},value= root:Packages:Irena:SysSpecModels:UnifPwrlawB, help={"Prefactor for low-Q power law slope"}
	SetVariable UnifPwrlawP,pos={270,560},size={110,17},title="P       ",proc=IR3S_SetVarProc, disable=!(UseUnified), bodywidth=70
	SetVariable UnifPwrlawP,limits={0,5,0.1},value= root:Packages:Irena:SysSpecModels:UnifPwrlawP, help={"Power law slope of low-Q region"}
	SetVariable UnifRgCO,pos={270,580},size={110,17},title="RgCO  ",proc=IR3S_SetVarProc, disable=!(UseUnified), bodywidth=70
	SetVariable UnifRgCO,limits={0,inf,10},value= root:Packages:Irena:SysSpecModels:UnifRgCO, help={"Rg cutt off for low-Q region"}
	SetVariable SASBackground,pos={270,610},size={150,16},proc=IR3S_SetVarProc,title="SAS Background", help={"Background of SAS"}, bodywidth=70
	SetVariable SASBackground,limits={-inf,Inf,1},variable= root:Packages:Irena:SysSpecModels:SASBackground

	CheckBox FitUnifG,pos={400,500},size={79,14},noproc,title="Fit?", variable= root:Packages:Irena:SysSpecModels:FitUnifG, help={"Fit this parameter?"}, disable=!(UseUnified)
	CheckBox FitUnifRg,pos={400,520},size={79,14},noproc,title="Fit?", variable= root:Packages:Irena:SysSpecModels:FitUnifRg, help={"Fit this parameter?"}, disable=!(UseUnified)
	CheckBox FitUnifPwrlawB,pos={400,540},size={79,14},noproc,title="Fit?", variable= root:Packages:Irena:SysSpecModels:FitUnifPwrlawB, help={"Fit this parameter?"}, disable=!(UseUnified)
	CheckBox FitUnifPwrlawP,pos={400,560},size={79,14},noproc,title="Fit?", variable= root:Packages:Irena:SysSpecModels:FitUnifPwrlawP, help={"Fit this parameter?"}, disable=!(UseUnified)
	CheckBox LinkUnifRgCO,pos={400,580},size={79,14},proc=IR3S_MainPanelCheckProc,title="Link?", variable= root:Packages:Irena:SysSpecModels:LinkUnifRgCO, help={"Link this RgCO to model feature size?"}, disable=!(UseUnified)
	CheckBox FitSASBackground,pos={450,610},size={79,14},noproc,title="Fit?", variable= root:Packages:Irena:SysSpecModels:FitSASBackground, help={"Fit this parameter?"}


	//final controls... 
	Button RecalculateModel,pos={275,640},size={110,20}, proc=IR3S_ButtonProc, title="Calculate Model", help={"Calculate Model using parameters above"}
	Button FitModel,pos={275,665},size={110,20}, proc=IR3S_ButtonProc, title="Fit Data", help={"Fit Model using selection/model above to data curtrently in tool"}
	Button FitAllSelected, pos={275,690},size={110,20}, proc=IR3S_ButtonProc, title="Fit sequence", help={"Fit sequnce of data selected in the ListBox with model"}
	Button ReverseFit,pos={275,715},size={110,18}, proc=IR3S_ButtonProc, title="Reverse fit", help={"Fit Model using selection/model above"}

	CheckBox RecalculateAutomatically,pos={400,640},size={79,14},proc=IR3S_MainPanelCheckProc,title="Auto Recalculate?", variable= root:Packages:Irena:SysSpecModels:UpdateAutomatically, help={"Recalculate when any number changes?"}
	CheckBox SaveToNotebook,pos={400,660},size={79,14},noproc,title="Save To Notebook?", variable= root:Packages:Irena:SysSpecModels:SaveToNotebook, help={"Save results to Notebook?"}
	CheckBox SaveToFolder,pos={400,680},size={79,14},noproc,title="Save To folder?", variable= root:Packages:Irena:SysSpecModels:SaveToFolder, help={"Save results to folder?"}
	CheckBox SaveToWaves,pos={400,700},size={79,14},noproc,title="Save To waves?", variable= root:Packages:Irena:SysSpecModels:SaveToWaves, help={"Save results to waves in folder?"}
	Button   SaveResults,pos={400,720},size={110,18}, proc=IR3S_ButtonProc, title="Save Results", help={"Save results"}


	TitleBox Instructions1 title="\Zr100Double click to add data to graph",size={330,15},pos={4,680},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions2 title="\Zr100Shift-click to select range of data",size={330,15},pos={4,695},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions3 title="\Zr100Ctrl/Cmd-click to select one data set",size={330,15},pos={4,710},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions4 title="\Zr100Regex for not contain: ^((?!string).)*$",size={330,15},pos={4,725},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions5 title="\Zr100Regex for contain:  string, two: str2.*str1",size={330,15},pos={4,740},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions6 title="\Zr100Regex for case independent:  (?i)string",size={330,15},pos={4,755},frame=0,fColor=(0,0,65535),labelBack=0
	
	SetVariable DelayBetweenProcessing,pos={240,735},size={150,16},noproc,title="Delay in Seq. Proc:", help={"Delay between sample in sequence of processing data sets"}
	SetVariable DelayBetweenProcessing,limits={0,30,0},variable= root:Packages:Irena:SysSpecModels:DelayBetweenProcessing, bodywidth=50
	CheckBox DoNotTryRecoverData,pos={245,754},size={79,14},noproc,title="Do not restore prior result", variable= root:Packages:Irena:SysSpecModels:DoNotTryRecoverData, help={"Save results to Notebook?"}
	CheckBox HideTagsAlways,pos={425,754},size={79,14},proc=IR3S_MainPanelCheckProc,title="Hide Tags", variable= root:Packages:Irena:SysSpecModels:HideTagsAlways, help={"Save results to Notebook?"}

	//and fix which controls are displayed:
	IR3S_SetupControlsOnMainpanel()
	IR3S_AutoRecalculateModelData(0)
end



//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR3S_SetupControlsOnMainpanel()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
	DoWindow IR3S_SysSpecModelsPanel
	if(V_Flag)
		NVAR UseUnified = root:Packages:Irena:SysSpecModels:UseUnified
		Button EstimateUF win=IR3S_SysSpecModelsPanel,disable=!(UseUnified)
		SetVariable UnifG win=IR3S_SysSpecModelsPanel,disable=!(UseUnified)
		SetVariable UnifRg win=IR3S_SysSpecModelsPanel,disable=!(UseUnified)
		SetVariable UnifPwrlawB win=IR3S_SysSpecModelsPanel,disable=!(UseUnified)
		SetVariable UnifPwrlawP win=IR3S_SysSpecModelsPanel,disable=!(UseUnified)
		SetVariable UnifRgCO win=IR3S_SysSpecModelsPanel,disable=!(UseUnified)
		CheckBox FitUnifG win=IR3S_SysSpecModelsPanel,disable=!(UseUnified)
		CheckBox FitUnifRg win=IR3S_SysSpecModelsPanel,pos={400,520},disable=!(UseUnified)
		CheckBox FitUnifPwrlawB win=IR3S_SysSpecModelsPanel,disable=!(UseUnified)
		CheckBox FitUnifPwrlawP win=IR3S_SysSpecModelsPanel,disable=!(UseUnified)
		CheckBox LinkUnifRgCO win=IR3S_SysSpecModelsPanel,disable=!(UseUnified)

		strswitch(ModelSelected)	// string switch
			case "Debye-Bueche":	// execute if case matches expression
				NVAR DBPrefactor = root:Packages:Irena:SysSpecModels:DBPrefactor
				NVAR DBEta=root:Packages:Irena:SysSpecModels:DBEta
				NVAR DBcorrL=root:Packages:Irena:SysSpecModels:DBcorrL
				NVAR DBWavelength=root:Packages:Irena:SysSpecModels:DBWavelength
				SetVariable ModelVarPar1 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBPrefactor ,title="Scale         ", disable=1, limits={0.01,inf,IR3SSetVariableStepRatio*DBPrefactor}, help={"Scale for Debye-Bueche model"}
				SetVariable ModelVarPar2 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBEta ,title="Eta           ", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*DBEta}, help={"ETA for Debye-Bueche model"}
				SetVariable ModelVarPar3 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBcorrL ,title="Corr Length", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*DBcorrL}, help={"Correlation length for Debye-Bueche model"}
				SetVariable ModelVarPar4 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBWavelength ,title="Wavelength", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*DBWavelength}, help={"Wavelength for Debye-Bueche model"}
				SetVariable ModelVarPar5 win=IR3S_SysSpecModelsPanel, disable=1, noedit=0
				SetVariable ModelVarPar6 win=IR3S_SysSpecModelsPanel, disable=1, noedit=0

				CheckBox FitModelVarPar1 win=IR3S_SysSpecModelsPanel,variable= root:Packages:Irena:SysSpecModels:FitDBPrefactor, disable=1
				CheckBox FitModelVarPar2 win=IR3S_SysSpecModelsPanel,variable= root:Packages:Irena:SysSpecModels:FitDBEta, disable=0
				CheckBox FitModelVarPar3 win=IR3S_SysSpecModelsPanel,variable= root:Packages:Irena:SysSpecModels:FitDBcorrL, disable=0
				CheckBox FitModelVarPar4 win=IR3S_SysSpecModelsPanel,variable= root:Packages:Irena:SysSpecModels:FitDBWavelength, disable=1
				CheckBox FitModelVarPar5 win=IR3S_SysSpecModelsPanel,disable=1
				CheckBox FitModelVarPar6 win=IR3S_SysSpecModelsPanel,disable=1

				Button ModelButton1 win=IR3S_SysSpecModelsPanel, title="Estimate corrL", help={"Estimate Correlation length"}, disable=0

				SetVariable ModelVarPar1LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBPrefactorLL ,title=" ", disable=1, limits={0.01,inf,0}, help={"Lower limit for Scale for Debye-Bueche model"}
				SetVariable ModelVarPar1UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBPrefactorHL ,title="< Scale < ", disable=1, limits={0.01,inf,0}, help={"High limit for Scale for Debye-Bueche model"}
				SetVariable ModelVarPar2LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBEtaLL ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for ETA for Debye-Bueche model"}
				SetVariable ModelVarPar2UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBEtaHL ,title="< Eta < ", disable=0, limits={0.01,inf,0}, help={"High limit for ETA for Debye-Bueche model"}
				SetVariable ModelVarPar3LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBcorrLLL ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Correlation length for Debye-Bueche model"}
				SetVariable ModelVarPar3UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBcorrLHL ,title="< CorL < ", disable=0, limits={0.01,inf,0}, help={"High limit for Correlation length for Debye-Bueche model"}
				SetVariable ModelVarPar4LL win=IR3S_SysSpecModelsPanel,disable=1
				SetVariable ModelVarPar4UL win=IR3S_SysSpecModelsPanel,disable=1
				SetVariable ModelVarPar5LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar5UL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar6LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar6UL win=IR3S_SysSpecModelsPanel, disable=1
				break		// exit from switch
			case "Treubner-Strey":	// execute if case matches expression
				NVAR TSPrefactor 	= 	root:Packages:Irena:SysSpecModels:TSPrefactor
				NVAR TSAvalue		=	root:Packages:Irena:SysSpecModels:TSAvalue
				NVAR TSC1Value		=	root:Packages:Irena:SysSpecModels:TSC1Value
				NVAR TSC2Value		=	root:Packages:Irena:SysSpecModels:TSC2Value
				NVAR TSCorrelationLength	=	root:Packages:Irena:SysSpecModels:TSCorrelationLength
				NVAR TSRepeatDistance		=	root:Packages:Irena:SysSpecModels:TSRepeatDistance
				SetVariable ModelVarPar1 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPrefactor ,title="Scale         ", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*TSPrefactor}, help={"Scale for Treubner-Strey model"}
				SetVariable ModelVarPar2 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSAvalue ,title="A par         ", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*TSAvalue}, help={"A parameter for Treubner-Strey model"}
				SetVariable ModelVarPar3 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSC1Value ,title="TC1 par       ", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*TSC1Value}, help={"TC1 parameter for Treubner-Strey model"}
				SetVariable ModelVarPar4 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSC2Value ,title="TC2 par       ", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*TSC2Value}, help={"TC2 parameter for Treubner-Strey model"}
				SetVariable ModelVarPar5 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSCorrelationLength ,title="Corr length  ", disable=0, noedit=1, limits={-INF,inf,0}, help={"Calculated Correlation Length parameter for Treubner-Strey model"}
				SetVariable ModelVarPar6 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSRepeatDistance ,title="Repeat Dist.  ", disable=0,noedit=1, limits={-inf,inf,0}, help={"Calculated Repeat distance for Treubner-Strey model"}

				CheckBox FitModelVarPar1 win=IR3S_SysSpecModelsPanel,variable= root:Packages:Irena:SysSpecModels:FitTSPrefactor, disable=0
				CheckBox FitModelVarPar2 win=IR3S_SysSpecModelsPanel,variable= root:Packages:Irena:SysSpecModels:FitTSAvalue, disable=0
				CheckBox FitModelVarPar3 win=IR3S_SysSpecModelsPanel,variable= root:Packages:Irena:SysSpecModels:FitTSC1Value, disable=0
				CheckBox FitModelVarPar4 win=IR3S_SysSpecModelsPanel,variable= root:Packages:Irena:SysSpecModels:FitTSC2Value, disable=0
				CheckBox FitModelVarPar5 win=IR3S_SysSpecModelsPanel, disable=1
				CheckBox FitModelVarPar6 win=IR3S_SysSpecModelsPanel, disable=1
				
				Button ModelButton1 win=IR3S_SysSpecModelsPanel, title="Estimate corrL", help={"Estimate Correlation length"}, disable=1

				SetVariable ModelVarPar1LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPrefactorLL ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Scale for Treubner-Strey model"}
				SetVariable ModelVarPar1UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPrefactorHL ,title="< Scale < ", disable=0, limits={0.01,inf,0}, help={"High limit for Scale for Treubner-Strey model"}
				SetVariable ModelVarPar2LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSAvalueLL ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for A for Treubner-Strey model"}
				SetVariable ModelVarPar2UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSAvalueHL ,title="< A par < ", disable=0, limits={0.01,inf,0}, help={"High limit for A for Treubner-Strey model"}
				SetVariable ModelVarPar3LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSC1ValueLL ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for TC1 for Treubner-Strey model"}
				SetVariable ModelVarPar3UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSC1ValueHL ,title="< TC1 < ", disable=0, limits={0.01,inf,0}, help={"High limit for TC1 for Treubner-Strey model"}
				SetVariable ModelVarPar4LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSC2ValueLL ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for TC2 for Treubner-Strey model"}
				SetVariable ModelVarPar4UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSC2ValueHL ,title="< TC2 < ", disable=0, limits={0.01,inf,0}, help={"High limit for TC2 for Treubner-Strey model"}
				SetVariable ModelVarPar5LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar5UL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar6LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar6UL win=IR3S_SysSpecModelsPanel, disable=1
				break
			case "Benedetti-Ciccariello":	// execute if case matches expression
				NVAR BCPorodsSpecSurfArea 	= 	root:Packages:Irena:SysSpecModels:BCPorodsSpecSurfArea
				NVAR BCSolidScatLengthDensity 	= 	root:Packages:Irena:SysSpecModels:BCSolidScatLengthDensity
				NVAR BCVoidScatLengthDensity 	= 	root:Packages:Irena:SysSpecModels:BCVoidScatLengthDensity
				NVAR BCLayerScatLengthDens 	= 	root:Packages:Irena:SysSpecModels:BCLayerScatLengthDens
				NVAR BCCoatingsThickness 		= 	root:Packages:Irena:SysSpecModels:BCCoatingsThickness
				SetVariable ModelVarPar1 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPorodsSpecSurfArea ,title="Porod Surface     ", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*BCPorodsSpecSurfArea}, help={"Porod Surface [cm2/cm3] for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar2 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCSolidScatLengthDensity ,title="Solid SLD [10^10]", disable=0, limits={-inf,inf,BCSolidScatLengthDensity*IR3SSetVariableStepRatio}, help={"Solid SLD * 10^10 for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar3 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCVoidScatLengthDensity ,title="Void/Sol SLD     ", disable=0, limits={-inf,inf,BCVoidScatLengthDensity*IR3SSetVariableStepRatio}, help={"Void or solvent SLD parameter for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar4 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCLayerScatLengthDens ,title="Layer SLD [10^10]", disable=0, limits={-inf,inf,IR3SSetVariableStepRatio*BCLayerScatLengthDens}, help={"Layer SLD for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar5 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCCoatingsThickness ,title="Layer thick [A]   ", disable=0, noedit=0, limits={1,inf,BCCoatingsThickness*IR3SSetVariableStepRatio}, help={"Thickness of the layer for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar6 win=IR3S_SysSpecModelsPanel,title="", disable=1, noedit=0

				CheckBox FitModelVarPar1 win=IR3S_SysSpecModelsPanel,variable= root:Packages:Irena:SysSpecModels:FitBCPorodsSpecSurfArea, disable=0
				CheckBox FitModelVarPar2 win=IR3S_SysSpecModelsPanel,variable= root:Packages:Irena:SysSpecModels:FitBCSolidScatLengthDensity, disable=1
				CheckBox FitModelVarPar3 win=IR3S_SysSpecModelsPanel,variable= root:Packages:Irena:SysSpecModels:FitBCVoidScatLengthDensity, disable=1
				CheckBox FitModelVarPar4 win=IR3S_SysSpecModelsPanel,variable= root:Packages:Irena:SysSpecModels:FitBCLayerScatLengthDens, disable=0
				CheckBox FitModelVarPar5 win=IR3S_SysSpecModelsPanel,variable= root:Packages:Irena:SysSpecModels:FitBCCoatingsThickness, disable=0
				CheckBox FitModelVarPar6 win=IR3S_SysSpecModelsPanel, disable=1

				Button ModelButton1 win=IR3S_SysSpecModelsPanel, title="Estimate corrL", help={"Estimate Correlation length"}, disable=1

				SetVariable ModelVarPar1LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPorodsSpecSurfAreaLL ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Porod Surface Benedetti-Ciccariello model"}
				SetVariable ModelVarPar1UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPorodsSpecSurfAreaHL ,title="< Por S < ", disable=0, limits={0.01,inf,0}, help={"High limit for Porod Surface for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar2LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCSolidScatLengthDensityLL ,title=" ", disable=1, limits={0.01,inf,0}, help={"Lower limit for Solid SLD for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar2UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCSolidScatLengthDensityHL ,title="< S SLD < ", disable=1, limits={0.01,inf,0}, help={"High limit for Solid  SLD for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar3LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCVoidScatLengthDensityLL ,title=" ", disable=1, limits={0.01,inf,0}, help={"Lower limit for Void/Solvent for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar3UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCVoidScatLengthDensityHL ,title="< V SLD < ", disable=1, limits={0.01,inf,0}, help={"High limit for Void/Solvent for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar4LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCLayerScatLengthDensLL ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Layer SLD for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar4UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCLayerScatLengthDensHL ,title="< L SLD < ", disable=0, limits={0.01,inf,0}, help={"High limit for Layer SLD for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar5LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCCoatingsThicknessLL ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Layer thickness for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar5UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCCoatingsThicknessHL ,title="< Thick < ", disable=0, limits={0.01,inf,0}, help={"High limit for Layer thickness for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar6LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar6UL win=IR3S_SysSpecModelsPanel, disable=1
				break
				
			default:			// optional default expression executed
							
				SetVariable ModelVarPar1 win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar2 win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar3 win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar4 win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar5 win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar6 win=IR3S_SysSpecModelsPanel, disable=1
				CheckBox FitModelVarPar1 win=IR3S_SysSpecModelsPanel, disable=1
				CheckBox FitModelVarPar2 win=IR3S_SysSpecModelsPanel, disable=1
				CheckBox FitModelVarPar3 win=IR3S_SysSpecModelsPanel, disable=1
				CheckBox FitModelVarPar4 win=IR3S_SysSpecModelsPanel, disable=1
				CheckBox FitModelVarPar5 win=IR3S_SysSpecModelsPanel, disable=1
				CheckBox FitModelVarPar6 win=IR3S_SysSpecModelsPanel, disable=1
				Button ModelButton1 win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar1LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar1UL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar2LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar2UL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar3LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar3UL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar4LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar4UL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar5LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar5UL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar6LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar6UL win=IR3S_SysSpecModelsPanel, disable=1
				
				
		endswitch
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3S_MainPanelCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(StringMatch(cba.ctrlName, "UseUnified" ))
				IR3S_SetupControlsOnMainpanel()
				IR3S_AutoRecalculateModelData(0)				
			endif
			if(StringMatch(cba.ctrlName, "RecalculateAutomatically" ))
				IR3S_AutoRecalculateModelData(0)
			endif
			if(StringMatch(cba.ctrlName, "LinkUnifRgCO" ))
				NVAR UnifRgCO = root:Packages:Irena:SysSpecModels:UnifRgCO
				IR3S_SetRGCOAsNeeded()
				IR3S_AutoRecalculateModelData(0)				
			endif
			if(StringMatch(cba.ctrlName, "HideTagsAlways" ))
				IR3S_AttachTags(1)
			endif
			
			
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3S_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"ModelButton1"))
				//do something...
				//likey not this: IR3S_AutoRecalculateModelData()
				SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
				if(StringMatch(ModelSelected, "Debye-Bueche") )
					IR3S_EstimateCorrL()
				endif
			endif
			if(stringmatch(ba.ctrlName,"FitAllSelected"))
				IR3S_FitSequenceOfData()
			endif
			if(stringmatch(ba.ctrlName,"FitModel"))
				IR3S_FitSysSpecificModels()	
				IR3S_AttachTags(1)
			endif
			if(stringmatch(ba.ctrlName,"EstimateUF"))
				//fit power law between cursors...
				IR3S_EstimateLowQslope()	
			endif
			if(stringmatch(ba.ctrlName,"SaveResults"))
				NVAR SaveToNotebook=root:Packages:Irena:SysSpecModels:SaveToNotebook
				NVAR SaveToWaves=root:Packages:Irena:SysSpecModels:SaveToWaves
				NVAR SaveToFolder=root:Packages:Irena:SysSpecModels:SaveToFolder
				if(SaveToNotebook+SaveToWaves+SaveToFolder<1)
					Abort "Nothing is selected to Record, check at least on checkbox above" 
				endif	
				IR3S_SaveResultsToNotebook()
				IR3S_SaveResultsToWaves()
				IR3S_SaveResultsToFolder(0)
			endif


			if(stringmatch(ba.ctrlName,"ReverseFit"))
				Wave/Z BackupFitValues = root:Packages:Irena:SysSpecModels:BackupFitValues
				Wave/Z/T CoefNames = root:Packages:Irena:SysSpecModels:CoefNames
				variable i
				if(WaveExists(BackupFitValues)&&WaveExists(CoefNames))
					For(i=0;i<(numpnts(CoefNames));i+=1)
						NVAR RestoreValue=$("root:Packages:Irena:SysSpecModels:"+CoefNames[i])
						RestoreValue=BackupFitValues[i]
					endfor
				endif
				IR3S_AutoRecalculateModelData(1)
			endif

			if(stringmatch(ba.ctrlName,"RecalculateModel"))
				IR3S_AutoRecalculateModelData(1)
				IR3S_AttachTags(1)
			endif
			if(stringmatch(ba.ctrlName,"SelectAll"))
				Wave/Z SelectionOfAvailableData = root:Packages:Irena:SysSpecModels:SelectionOfAvailableData
				if(WaveExists(SelectionOfAvailableData))
					SelectionOfAvailableData=1
				endif
			endif

			if(stringmatch(ba.ctrlName,"GetHelp"))
				IN2G_OpenWebManual("Irena/SysSpecModels.html")				//fix me!!			
			endif			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************

static Function IR3S_FitSequenceOfData()

		IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
		//warn user if not saving results...

		NVAR SaveToNotebook=root:Packages:Irena:SysSpecModels:SaveToNotebook
		NVAR SaveToWaves=root:Packages:Irena:SysSpecModels:SaveToWaves
		NVAR SaveToFolder=root:Packages:Irena:SysSpecModels:SaveToFolder
		NVAR DelayBetweenProcessing=root:Packages:Irena:SysSpecModels:DelayBetweenProcessing
		if(SaveToNotebook+SaveToWaves+SaveToFolder<1)
			DoAlert /T="Results not being saved anywhere" 1, "Results of the fits are not being saved anywhere. Do you want to continue (Yes) or abort (No)?"
			if(V_Flag==2)
				abort
			endif
		endif	
		if(SaveToFolder)
			print "Fit results will be saved in original fits as Intensity and Q vector"
		endif
		if(SaveToWaves)
			print "Fit results will be saved in waves to create a table"
		endif
		if(SaveToNotebook)
			print "Fit results will be saved in notebook"
		endif
		Wave SelectionOfAvailableData = root:Packages:Irena:SysSpecModels:SelectionOfAvailableData
		Wave/T ListOfAvailableData = root:Packages:Irena:SysSpecModels:ListOfAvailableData
		NVAR DoNotTryRecoverData = root:Packages:Irena:SysSpecModels:DoNotTryRecoverData
		variable i, imax
		variable oldDoNotTryRecoverData 
		oldDoNotTryRecoverData = DoNotTryRecoverData
		imax = numpnts(ListOfAvailableData)
		For(i=0;i<imax;i+=1)
			DoNotTryRecoverData = 1
			if(SelectionOfAvailableData[i]>0.5)		//data set selected
				IR3S_CopyAndAppendData(ListOfAvailableData[i])
				IR3S_FitSysSpecificModels()	
				IR3S_AttachTags(1)
				print "Fitted data from : "+ListOfAvailableData[i]
				IR3S_SaveResultsToNotebook()
				IR3S_SaveResultsToWaves()
				IR3S_SaveResultsToFolder(1)
				DoUpdate 
				if(DelayBetweenProcessing>0.5)
					sleep/S/C=6/M="Fitted data for "+ListOfAvailableData[i] DelayBetweenProcessing
				endif
			endif
		endfor
		DoNotTryRecoverData = oldDoNotTryRecoverData
		print "all selected data processed"
end
//**********************************************************************************************************
//**************************************************************************************
//**************************************************************************************

Function IR3S_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	variable tempP
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
			NVAR DataQstart=root:Packages:Irena:SysSpecModels:DataQstart
			NVAR DataQEnd=root:Packages:Irena:SysSpecModels:DataQEnd
			NVAR DataQEndPoint = root:Packages:Irena:SysSpecModels:DataQEndPoint
			NVAR DataQstartPoint = root:Packages:Irena:SysSpecModels:DataQstartPoint
			
			if(stringmatch(sva.ctrlName,"DataQEnd"))
				WAVE OriginalDataQWave = root:Packages:Irena:SysSpecModels:OriginalDataQWave
				tempP = BinarySearch(OriginalDataQWave, DataQEnd )
				if(tempP<1)
					print "Wrong Q value set, Data Q max must be at most 1 point before the end of Data"
					tempP = numpnts(OriginalDataQWave)-2
					DataQEnd = OriginalDataQWave[tempP]
				endif
				DataQEndPoint = tempP			
				IR3S_SyncCursorsTogether("OriginalDataIntWave","B",tempP)
				IR3S_SyncCursorsTogether("LinModelDataIntWave","B",tempP)
			endif
			if(stringmatch(sva.ctrlName,"DataQstart"))
				WAVE OriginalDataQWave = root:Packages:Irena:SysSpecModels:OriginalDataQWave
				tempP = BinarySearch(OriginalDataQWave, DataQstart )
				if(tempP<1)
					print "Wrong Q value set, Data Q min must be at least 1 point from the start of Data"
					tempP = 1
					DataQstart = OriginalDataQWave[tempP]
				endif
				DataQstartPoint=tempP
				IR3S_SyncCursorsTogether("OriginalDataIntWave","A",tempP)
				IR3S_SyncCursorsTogether("LinModelDataIntWave","A",tempP)
			endif
			if(stringmatch(sva.ctrlName,"ModelVarPar*"))
				// 1 	change step t0 fraction of value
				// 2 	change limits for the variable... 
				// 3	recalculate 
				SetVariable $(sva.ctrlName) win=IR3S_SysSpecModelsPanel,limits={0,inf,IR3SSetVariableStepRatio*sva.dval} 
				// sva.vName contains name of variable
				NVAR/Z LowLimVal = $("root:Packages:Irena:SysSpecModels:"+sva.vName+"LL")
				NVAR/Z HighLimVal = $("root:Packages:Irena:SysSpecModels:"+sva.vName+"HL")
				if(NVAR_Exists(LowLimVal) && NVAR_Exists(HighLimVal))
					LowLimVal = sva.dval * IR3SSetVariableLowLimRatio
					HighLimVal = sva.dval * IR3SSetVariableHighLimRatio
				endif
				IR3S_AutoRecalculateModelData(0)
			endif
			if(stringmatch(sva.ctrlName,"UnifG"))
				NVAR UnifRg = root:Packages:Irena:SysSpecModels:UnifRg
				NVAR UnifG = root:Packages:Irena:SysSpecModels:UnifG
				if(UnifG==0)
					UnifRg=1e10
				endif
			endif
			if(stringmatch(sva.ctrlName,"UnifG") ||stringmatch(sva.ctrlName,"UnifRg")||stringmatch(sva.ctrlName,"UnifPwrlawB")||stringmatch(sva.ctrlName,"UnifPwrlawP")||stringmatch(sva.ctrlName,"UnifRgCO")||stringmatch(sva.ctrlName,"SASBackground") )
				SetVariable $(sva.ctrlName) win=IR3S_SysSpecModelsPanel,limits={0,inf,IR3SSetVariableStepRatio*sva.dval} 
				NVAR/Z LowLimVal = $("root:Packages:Irena:SysSpecModels:"+sva.vName+"LL")
				NVAR/Z HighLimVal = $("root:Packages:Irena:SysSpecModels:"+sva.vName+"HL")
				if(NVAR_Exists(LowLimVal) && NVAR_Exists(HighLimVal))
					LowLimVal = sva.dval * IR3SSetVariableLowLimRatio
					HighLimVal = sva.dval * IR3SSetVariableHighLimRatio
				endif
				IR3S_AutoRecalculateModelData(0)
			endif
		
			break
		case 3: // live update
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3S_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(StringMatch(pa.ctrlName, "ModelSelected" ))
				SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
				ModelSelected = popStr
//				IR3J_SetupControlsOnMainpanel()
//				KillWaves/Z $("root:Packages:Irena:SimpleFits:ModelLogLogInt")
//				KillWaves/Z $("root:Packages:Irena:SimpleFits:ModelLogLogQ")
//				KillWIndow/Z IR3J_LinDataDisplay
//				KillWindow/Z IR3S_LogLogDataDisplay
				IR3S_CreateSysSpecModelsGraphs()
				IR3S_SetupControlsOnMainpanel()
				IR3S_AutoRecalculateModelData(0)
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End


//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function IR3S_CopyAndAppendData(FolderNameStr)
	string FolderNameStr
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:SysSpecModels					//go into the folder
		SVAR DataStartFolder=root:Packages:Irena:SysSpecModels:DataStartFolder
		SVAR DataFolderName=root:Packages:Irena:SysSpecModels:DataFolderName
		SVAR IntensityWaveName=root:Packages:Irena:SysSpecModels:IntensityWaveName
		SVAR QWavename=root:Packages:Irena:SysSpecModels:QWavename
		SVAR ErrorWaveName=root:Packages:Irena:SysSpecModels:ErrorWaveName
		SVAR dQWavename=root:Packages:Irena:SysSpecModels:dQWavename
		NVAR UseIndra2Data=root:Packages:Irena:SysSpecModels:UseIndra2Data
		NVAR UseQRSdata=root:Packages:Irena:SysSpecModels:UseQRSdata
		//these are variables used by the control procedure
		NVAR  UseResults=  root:Packages:Irena:SysSpecModels:UseResults
		NVAR  UseUserDefinedData=  root:Packages:Irena:SysSpecModels:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:SysSpecModels:UseModelData
		SVAR DataFolderName  = root:Packages:Irena:SysSpecModels:DataFolderName 
		SVAR IntensityWaveName = root:Packages:Irena:SysSpecModels:IntensityWaveName
		SVAR QWavename = root:Packages:Irena:SysSpecModels:QWavename
		SVAR ErrorWaveName = root:Packages:Irena:SysSpecModels:ErrorWaveName
		UseUserDefinedData = 0
		UseModelData = 0
		//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
		IR3C_SelectWaveNamesData("Irena:SysSpecModels", FolderNameStr)			//this routine will preset names in strings as needed,		
		Wave/Z SourceIntWv=$(DataFolderName+possiblyQUoteName(IntensityWaveName))
		Wave/Z SourceQWv=$(DataFolderName+possiblyQUoteName(QWavename))
		Wave/Z SourceErrorWv=$(DataFolderName+possiblyQUoteName(ErrorWaveName))
		Wave/Z SourcedQWv=$(DataFolderName+possiblyQUoteName(dQWavename))
		if(!WaveExists(SourceIntWv) &&	!WaveExists(SourceQWv) && UseIndra2Data)		//may be we heve M_... data here?
			Wave/Z SourceIntWv=$(DataFolderName+possiblyQUoteName("M_"+IntensityWaveName))
			Wave/Z SourceQWv=$(DataFolderName+possiblyQUoteName("M_"+QWavename))
			Wave/Z SourceErrorWv=$(DataFolderName+possiblyQUoteName("M_"+ErrorWaveName))
			Wave/Z SourcedQWv=$(DataFolderName+possiblyQUoteName("M_"+dQWavename))
		endif
		if(!WaveExists(SourceIntWv)||	!WaveExists(SourceQWv))//||!WaveExists(SourceErrorWv))
			Abort "Data selection failed for System Specific Models routine IR3S_CopyAndAppendData"
		endif
		Duplicate/O SourceIntWv, OriginalDataIntWave
		Duplicate/O SourceQWv, OriginalDataQWave
		if(WaveExists(SourceErrorWv))
			Duplicate/O SourceErrorWv, OriginalDataErrorWave
		else
			Duplicate/O SourceIntWv, OriginalDataErrorWave
			OriginalDataErrorWave = 0
		endif
		if(WaveExists(SourcedQWv))
			Duplicate/O SourcedQWv, OriginalDatadQWave
		else
			dQWavename=""
		endif
		//now we need to set slit length if needed...
		NVAR SlitLength=  root:Packages:Irena:SysSpecModels:SlitLength
		NVAR UseSlitSmearedData=  root:Packages:Irena:SysSpecModels:UseSlitSmearedData
		if(UseIndra2Data && StringMatch(IntensityWaveName, "*SMR*" ))
			UseSlitSmearedData = 1
			string oldNote=Note(SourceIntWv)
			SlitLength = NumberByKey("SlitLength", oldNote, "=" , ";")
		else
			UseSlitSmearedData=0
		endif
		IR3S_RecoverParameters()
		IR3S_CreateSysSpecModelsGraphs()
		//clear obsolete data:
		//		Wave/Z NormRes1=root:Packages:Irena:SimpleFits:NormalizedResidualLinLin
		//		Wave/Z NormRes2=root:Packages:Irena:SimpleFits:NormalizedResidualLogLog
		//		if(WaveExists(NormRes1))
		//			NormRes1=0
		//		endif
		//		if(WaveExists(NormRes2))
		//			NormRes2=0
		//		endif
		//		//done cleaning... 
		//		DoWIndow IR3S_LogLogDataDisplay
		//		if(V_Flag)
		//			RemoveFromGraph /W=IR3J_LogLogDataDisplay /Z NormalizedResidualLogLog
		//			DoWIndow/F IR3J_LogLogDataDisplay
		//		endif
		//		DoWIndow IR3J_LinDataDisplay
		//		if(V_Flag)
		//			RemoveFromGraph /W=IR3J_LinDataDisplay /Z NormalizedResidualLinLin
		//			DoWIndow/F IR3J_LinDataDisplay
		//		endif
		pauseUpdate
		IR3S_AppendDataToGraphLogLog()
		IR3S_AutoRecalculateModelData(0)
		//		//now this deals with linearized data, if needed...
		//		IR3J_CreateLinearizedData()
		//		IR3J_AppendDataToGraphModel()
		DoUpdate
		print "Added Data from folder : "+DataFolderName
	SetDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//************************************************************************************************************
//************************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


static Function IR3S_AppendDataToGraphLogLog()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IR3S_CreateSysSpecModelsGraphs()
	variable WhichLegend=0
	string Shortname1
	Wave OriginalDataIntWave=root:Packages:Irena:SysSpecModels:OriginalDataIntWave
	Wave OriginalDataQWave=root:Packages:Irena:SysSpecModels:OriginalDataQWave
	Wave OriginalDataErrorWave=root:Packages:Irena:SysSpecModels:OriginalDataErrorWave
	CheckDisplayed /W=IR3S_LogLogDataDisplay OriginalDataIntWave
	if(!V_flag)
		AppendToGraph /W=IR3S_LogLogDataDisplay  OriginalDataIntWave  vs OriginalDataQWave
		ModifyGraph /W=IR3S_LogLogDataDisplay log=1, mirror=1
		Label /W=IR3S_LogLogDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
		Label /W=IR3S_LogLogDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q[A\\S-1\\M"+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
		ErrorBars /W=IR3S_LogLogDataDisplay OriginalDataIntWave Y,wave=(OriginalDataErrorWave,OriginalDataErrorWave)		
	endif
	removeFromGraph /Z /W=IR3S_LogLogDataDisplay ModelIntensity, Residuals
	NVAR DataQEnd = root:Packages:Irena:SysSpecModels:DataQEnd
	NVAR DataQstart = root:Packages:Irena:SysSpecModels:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:SysSpecModels:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:SysSpecModels:DataQstartPoint
	if(DataQstart>0)	 		//old Q min already set.
		DataQstartPoint = BinarySearch(OriginalDataQWave, DataQstart)
	endif
	if(DataQstartPoint<1)	//Qmin not set or not found. Set to point 2 on that wave. 
		DataQstart = OriginalDataQWave[1]
		DataQstartPoint = 1
	endif
	if(DataQEnd>0)	 		//old Q max already set.
		DataQEndPoint = BinarySearch(OriginalDataQWave, DataQEnd)
	endif
	if(DataQEndPoint<1)	//Qmax not set or not found. Set to last point-1 on that wave. 
		DataQEnd = OriginalDataQWave[numpnts(OriginalDataQWave)-2]
		DataQEndPoint = numpnts(OriginalDataQWave)-2
	endif
	SetWindow IR3S_LogLogDataDisplay, hook(DM3LogCursorMoved) = $""
	cursor /W=IR3S_LogLogDataDisplay B, OriginalDataIntWave, DataQEndPoint
	cursor /W=IR3S_LogLogDataDisplay A, OriginalDataIntWave, DataQstartPoint
	SetWindow IR3S_LogLogDataDisplay, hook(SysSpecModelsLogCursorMoved) = IR3S_GraphWindowHook

	SVAR DataFolderName=root:Packages:Irena:SysSpecModels:DataFolderName
	Shortname1 = StringFromList(ItemsInList(DataFolderName, ":")-1, DataFolderName  ,":")
	Legend/W=IR3S_LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalDataIntWave) "+Shortname1

	
end
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3S_GraphWindowHook(s)
	STRUCT WMWinHookStruct &s

	Variable hookResult = 0

	switch(s.eventCode) 
		case 0:				// Activate
			// Handle activate
			break

		case 1:				// Deactivate
			// Handle deactivate
			break
		case 7:				//coursor moved
			IR3S_SyncCursorsTogether(s.traceName,s.cursorName,s.pointNumber)
			hookResult = 1
		// And so on . . .
	endswitch

	return hookResult	// 0 if nothing done, else 1
End
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3S_SyncCursorsTogether(traceName,CursorName,PointNumber)
	string traceName,CursorName
	variable PointNumber

	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	IR3S_CreateSysSpecModelsGraphs()
	NVAR DataQEnd = root:Packages:Irena:SysSpecModels:DataQEnd
	NVAR DataQstart = root:Packages:Irena:SysSpecModels:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:SysSpecModels:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:SysSpecModels:DataQstartPoint
	Wave OriginalDataQWave=root:Packages:Irena:SysSpecModels:OriginalDataQWave
	Wave OriginalDataIntWave=root:Packages:Irena:SysSpecModels:OriginalDataIntWave
		variable tempMaxQ, tempMaxQY, tempMinQY, maxY, minY
	//check if user removed cursor from graph, in which case do nothing for now...
	if(numtype(PointNumber)==0)
		if(stringmatch(CursorName,"A"))		//moved cursor A, which is start of Q range
			DataQstartPoint = PointNumber
			DataQstart = OriginalDataQWave[PointNumber]
		endif
		if(stringmatch(CursorName,"B"))		//moved cursor B, which is end of Q range
			DataQEndPoint = PointNumber
			DataQEnd = OriginalDataQWave[PointNumber]
		endif
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function IR3S_CreateSysSpecModelsGraphs()
	
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable exists1=0
	DoWIndow IR3S_LogLogDataDisplay
	if(V_Flag)
		DoWIndow/hide=? IR3S_LogLogDataDisplay
		if(V_Flag==2)
			DoWIndow/F IR3S_LogLogDataDisplay
		endif
	else
		Display /W=(521,10,1383,750)/K=1 /N=IR3S_LogLogDataDisplay
		ShowInfo/W=IR3S_LogLogDataDisplay
		exists1=1
	endif
	AutoPositionWindow/M=0/R=IR3S_SysSpecModelsPanel IR3S_LogLogDataDisplay	
end

//**********************************************************************************************************
//**********************************************************************************************************

//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3S_InitSysSpecModels()	


	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()
	variable i
		
	if (!DataFolderExists("root:Packages:Irena:SysSpecModels"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:SysSpecModels
	endif
	SetDataFolder root:Packages:Irena:SysSpecModels					//go into the folder
	string ListOfVariables
	string ListOfStrings
	string/g ListOfVariablesUF, ListOfVariablesDB, ListOfVariablesTS, ListOfVariablesBC, ListOfVariablesBG
	string/g ListOfVariablesMain
	
	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;DataUnits;"
	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"
	ListOfStrings+="UserMessageString;SavedDataMessage;"
	ListOfStrings+="ModelSelected;ListOfModels;"

	ListOfVariablesMain="UseIndra2Data;UseQRSdata;DataQEnd;DataQStart;DataQEndPoint;DataQstartPoint;"
	ListOfVariablesMain+="UpdateAutomatically;AchievedChiSquare;ScatteringContrast;SlitLength;UseSlitSmearedData;"
	ListOfVariablesMain+="SaveToNotebook;SaveToWaves;SaveToFolder;DelayBetweenProcessing;DoNotTryRecoverData;HideTagsAlways;"
	
	//background
	ListOfVariablesBG="SASBackground;FitSASBackground;SASBackgroundLL;SASBackgroundHL;SASBackgroundError;"

	//Unified level
	ListOfVariablesUF="UseUnified;UnifRgCO;LinkUnifRgCO;"
	ListOfVariablesUF+="UnifPwrlawP;FitUnifPwrlawP;UnifPwrlawPLL;UnifPwrlawPHL;UnifPwrlawPError;"
	ListOfVariablesUF+="UnifPwrlawB;FitUnifPwrlawB;UnifPwrlawBLL;UnifPwrlawBHL;UnifPwrlawBError;"
	ListOfVariablesUF+="UnifRg;FitUnifRg;UnifRgLL;UnifRgHL;UnifRgError;"
	ListOfVariablesUF+="UnifG;FitUnifG;UnifGLL;UnifGHL;UnifGError;"
	//Debye-Bueche parameters	
	ListOfVariablesDB="DBPrefactor;FitDBPrefactor;DBPrefactorHL;DBPrefactorLL;"
	ListOfVariablesDB+="DBcorrL;FitDBcorrL;DBcorrLLL;DBcorrLHL;DBcorrLError;"
	ListOfVariablesDB+="DBEta;FitDBEta;DBEtaLL;DBEtaHL;DBEtaError;"
	ListOfVariablesDB+="DBWavelength;"
	ListOfVariablesDB+=""
	//Teubner-Strey Model
	ListOfVariablesTS="TSPrefactor;FitTSPrefactor;TSPrefactorHL;TSPrefactorLL;TSPrefactorError;"
	ListOfVariablesTS+="TSAvalue;FitTSAvalue;TSAvalueHL;TSAvalueLL;TSAvalueError;"
	ListOfVariablesTS+="TSC1Value;FitTSC1Value;TSC1ValueHL;TSC1ValueLL;TSC1ValueError;"
	ListOfVariablesTS+="TSC2Value;FitTSC2Value;TSC2ValueHL;TSC2ValueLL;TSC2ValueError;"
	ListOfVariablesTS+="TSCorrelationLength;TSCorrLengthError;TSRepeatDistance;TSRepDistError;"
	//Benedetti-Ciccariello Coated Porous media Porods oscillations
	ListOfVariablesBC ="BCVoidScatLengthDensity;BCSolidScatLengthDensity;"
	ListOfVariablesBC+="BCLayerScatLengthDens;BCLayerScatLengthDensHL;BCLayerScatLengthDensLL;FitBCLayerScatLengthDens;BCLayerScatLengthDensError;"
	ListOfVariablesBC+="BCCoatingsThickness;BCCoatingsThicknessHL;BCCoatingsThicknessLL;FitBCCoatingsThickness;BCCoatingsThicknessError;"
	ListOfVariablesBC+="BCPorodsSpecSurfArea;FitBCPorodsSpecSurfArea;BCPorodsSpecSurfAreaHL;BCPorodsSpecSurfAreaLL;BCPorodsSpecSurfAreaError;"
	
	SVAR ListOfVariablesBC = root:Packages:Irena:SysSpecModels:ListOfVariablesBC
	SVAR ListOfVariablesTS = root:Packages:Irena:SysSpecModels:ListOfVariablesTS
	SVAR ListOfVariablesDB = root:Packages:Irena:SysSpecModels:ListOfVariablesDB
	SVAR ListOfVariablesUF = root:Packages:Irena:SysSpecModels:ListOfVariablesUF
	SVAR ListOfVariablesBG = root:Packages:Irena:SysSpecModels:ListOfVariablesBG
	SVAR ListOfVariablesMain = root:Packages:Irena:SysSpecModels:ListOfVariablesMain
	
	ListOfVariables = ListOfVariablesMain+ListOfVariablesUF+ ListOfVariablesDB+ ListOfVariablesTS+ ListOfVariablesBC+ListOfVariablesBG
	
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
								
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		teststr =""
	endfor		
	ListOfStrings="DataMatchString;FolderSortString;FolderSortStringAll;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		if(strlen(teststr)<1)
			teststr =""
		endif
	endfor		
	ListOfStrings="DataStartFolder;"
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR teststr=$(StringFromList(i,ListOfStrings))
		if(strlen(teststr)<1)
			teststr ="root:"
		endif
	endfor		
	SVAR ListOfModels
	ListOfModels="---;Debye-Bueche;Treubner-Strey;Benedetti-Ciccariello;"
	SVAR ModelSelected
	if(strlen(ModelSelected)<1)
		ModelSelected="---"
	endif
	Make/O/T/N=(0) ListOfAvailableData
	Make/O/N=(0) SelectionOfAvailableData
	SetDataFolder oldDf
	IR3S_SetInitialValues()
end
//**************************************************************************************
//**************************************************************************************
//**************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR3S_SetInitialValues()
	//and here set default values...

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:SysSpecModels
	NVAR FitSASBackground=root:Packages:Irena:SysSpecModels:FitSASBackground
	NVAR UpdateAutomatically=root:Packages:Irena:SysSpecModels:UpdateAutomatically

	NVAR UseSlitSmearedData=root:Packages:Irena:SysSpecModels:UseSlitSmearedData
	NVAR SlitLength=root:Packages:Irena:SysSpecModels:SlitLength

	NVAR DBPrefactor=root:Packages:Irena:SysSpecModels:DBPrefactor
	NVAR DBPrefactorLL=root:Packages:Irena:SysSpecModels:DBPrefactorLL
	NVAR DBPrefactorHL=root:Packages:Irena:SysSpecModels:DBPrefactorHL

	NVAR DBEta=root:Packages:Irena:SysSpecModels:DBEta
	NVAR DBEtaLL=root:Packages:Irena:SysSpecModels:DBEtaLL
	NVAR DBEtaHL=root:Packages:Irena:SysSpecModels:DBEtaHL

	NVAR DBcorrL=root:Packages:Irena:SysSpecModels:DBcorrL
	NVAR DBcorrLLL=root:Packages:Irena:SysSpecModels:DBcorrLLL
	NVAR DBcorrLHL=root:Packages:Irena:SysSpecModels:DBcorrLHL

	NVAR UnifPwrlawP=root:Packages:Irena:SysSpecModels:UnifPwrlawP
	NVAR UnifPwrlawPLL=root:Packages:Irena:SysSpecModels:UnifPwrlawPLL
	NVAR UnifPwrlawPHL=root:Packages:Irena:SysSpecModels:UnifPwrlawPHL

	NVAR UnifPwrlawB=root:Packages:Irena:SysSpecModels:UnifPwrlawB
	NVAR UnifPwrlawBLL=root:Packages:Irena:SysSpecModels:UnifPwrlawBLL
	NVAR UnifPwrlawBHL=root:Packages:Irena:SysSpecModels:UnifPwrlawBHL
	//Rg
	NVAR UnifRg=root:Packages:Irena:SysSpecModels:UnifRg
	NVAR UnifRgLL=root:Packages:Irena:SysSpecModels:UnifRgLL
	NVAR UnifRgHL=root:Packages:Irena:SysSpecModels:UnifRgHL
	//RGPref
	NVAR UnifG=root:Packages:Irena:SysSpecModels:UnifG
	NVAR UnifGLL=root:Packages:Irena:SysSpecModels:UnifGLL
	NVAR UnifGHL=root:Packages:Irena:SysSpecModels:UnifGHL
	//TSPref
	NVAR TSPrefactor=root:Packages:Irena:SysSpecModels:TSPrefactor
	NVAR TSPrefactorLL=root:Packages:Irena:SysSpecModels:TSPrefactorLL
	NVAR TSPrefactorHL=root:Packages:Irena:SysSpecModels:TSPrefactorHL
	//TSA
	NVAR TSAvalue=root:Packages:Irena:SysSpecModels:TSAvalue
	NVAR TSAvalueLL=root:Packages:Irena:SysSpecModels:TSAvalueLL
	NVAR TSAvalueHL=root:Packages:Irena:SysSpecModels:TSAvalueHL
	//TSC1
	NVAR TSC1Value=root:Packages:Irena:SysSpecModels:TSC1Value
	NVAR TSC1ValueLL=root:Packages:Irena:SysSpecModels:TSC1ValueLL
	NVAR TSC1ValueHL=root:Packages:Irena:SysSpecModels:TSC1ValueHL
	//TSC2
	NVAR TSC2Value=root:Packages:Irena:SysSpecModels:TSC2Value
	NVAR TSC2ValueLL=root:Packages:Irena:SysSpecModels:TSC2ValueLL
	NVAR TSC2ValueHL=root:Packages:Irena:SysSpecModels:TSC2ValueHL
	//Ciccariellos tool
	NVAR BCPorodsSpecSurfArea=root:Packages:Irena:SysSpecModels:BCPorodsSpecSurfArea
	NVAR BCSolidScatLengthDensity=root:Packages:Irena:SysSpecModels:BCSolidScatLengthDensity
	NVAR BCVoidScatLengthDensity=root:Packages:Irena:SysSpecModels:BCVoidScatLengthDensity
	NVAR BCLayerScatLengthDens=root:Packages:Irena:SysSpecModels:BCLayerScatLengthDens
//	NVAR BCCoatingsThickness=root:Packages:Irena:SysSpecModels:BCCoatingsThickness
	
	NVAR DBWavelength=root:Packages:Irena:SysSpecModels:DBWavelength

	NVAR DelayBetweenProcessing=root:Packages:Irena:SysSpecModels:DelayBetweenProcessing
	if(DelayBetweenProcessing<0)
		DelayBetweenProcessing=0
	endif
	if(UnifRg<=0)
		UnifRg=1e10
		UnifG = 0
		UnifRgLL=1
		UnifRgHL=1.1e10
	endif
	if(UnifG<0)
		UnifG=0
		UnifGLL=1e-10
		UnifGHL=1e10
	endif
	if(UnifG==0)
		UnifRg=1e10
	endif

	if(TSPrefactor<=0)
		TSPrefactor=1
		TSPrefactorLL=1e-10
		TSPrefactorHL=1e10
	endif

	if(TSAvalue==0)
		TSAvalue=0.1
		TSAvalueLL=-1e10
		TSAvalueHL=1e10
	endif
	if(TSC1Value==0)
		TSC1Value=-30
		TSC1ValueLL=-1e10
		TSC1ValueHL=1e10
	endif
	if(TSC2Value==0)
		TSC2Value=5000
		TSC2ValueLL=-1e10
		TSC2ValueHL=1e10
	endif


	//CurrentTab=0
	if(SlitLength==0)
		SlitLength = 1 
	endif
	if(DBPrefactor==0)
		DBPrefactor = 1
		DBPrefactorLL = 1e-10
		DBPrefactorHL = 1e10
	endif
	if(DBEta==0)
		DBEta=1
		DBEtaLL=1e-6
		DBEtaHL=1e6
	endif
	if(DBcorrL==0)
		DBcorrL=200
		DBcorrLLL=2
		DBcorrLHL=1e6
	endif
	if(UnifPwrlawP==0)
		UnifPwrlawP=3
		UnifPwrlawPLL=1
		UnifPwrlawPHL=4
	endif
	if(UnifPwrlawB==0)
		UnifPwrlawB=1
		UnifPwrlawBLL=1e-10
		UnifPwrlawBHL=1e10
	endif
	if(DBWavelength==0)
		DBWavelength=1
	endif
	//if (UseQRSData)
	//	UseIndra2data=0
	//endif
	if (FitSASBackground==0)
		FitSASBackground=1
	endif
	
	
	if(BCPorodsSpecSurfArea<=0)
		BCPorodsSpecSurfArea=1e4
	endif
	if(BCSolidScatLengthDensity<=0)
		BCSolidScatLengthDensity=19.32			//this is value for silica 
	endif

	UpdateAutomatically=0

	setDataFolder oldDF
	
end	




//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR3S_FitSysSpecificModels()

	dfref OldDf
	OldDf=GetDataFolderDFR
	setDataFolder root:Packages:Irena:SysSpecModels:
	Make/D/N=0/O W_coef, BackupFitValues
	Make/T/N=0/O CoefNames
	Make/D/O/T/N=0 T_Constraints
	Make/O/N=(0,2) Gen_Constraints
	T_Constraints=""
	CoefNames=""
	variable curLen

	String ListOfVariablesToCheck, FullListOfVariablesToCheck=""
	NVAR FitSASBackground = root:Packages:Irena:SysSpecModels:FitSASBackground
	NVAR SASBackground = root:Packages:Irena:SysSpecModels:SASBackground
	NVAR UseUnified = root:Packages:Irena:SysSpecModels:UseUnified
	SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
	strswitch(ModelSelected)	// string switch
		case "Debye-Bueche":	// execute if case matches expression
			ListOfVariablesToCheck="DBEta;DBcorrL;"			//these cannot be fitted anyway: DBPrefactor (=1, not needed...),DBWavelength
			break
		case "Treubner-Strey":	// execute if case matches expression
			ListOfVariablesToCheck="TSPrefactor;TSAvalue;TSC1Value;TSC2Value;"
			break
		case "Benedetti-Ciccariello":	// execute if case matches expression
			ListOfVariablesToCheck="BCPorodsSpecSurfArea;BCLayerScatLengthDens;BCCoatingsThickness;"
			break
	endswitch
	if(UseUnified)
		ListOfVariablesToCheck+="UnifPwrlawP;UnifPwrlawB;UnifRg;UnifG;"
	endif
	
	if (FitSASBackground)		//are we fitting background?
		curLen = (numpnts(W_coef))
		Redimension /N=((curLen+1),2) Gen_Constraints
		Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
		W_Coef[curLen]		=	SASBackground
		BackupFitValues[curLen]=	SASBackground
		CoefNames[curLen]	=	"SASBackground"
		Gen_Constraints[curLen][0] = SASBackground/10
		Gen_Constraints[curLen][1] = SASBackground*10
		FullListOfVariablesToCheck+="SASBackground;"
	endif
	variable i
	For(i=0;i<ItemsInList(ListOfVariablesToCheck);i+=1)
		NVAR Fitme = $("Fit"+StringFromList(i, ListOfVariablesToCheck))
		NVAR varMe = $(StringFromList(i, ListOfVariablesToCheck))
		NVAR varMeLL = $(StringFromList(i, ListOfVariablesToCheck)+"LL")
		NVAR varMeHL = $(StringFromList(i, ListOfVariablesToCheck)+"HL")
		if (Fitme)		//are we fitting background?
			curLen = (numpnts(W_coef))
			Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
			W_Coef[curLen]		= varMe
			BackupFitValues[curLen]=	varMe
			CoefNames[curLen]	=StringFromList(i, ListOfVariablesToCheck)
			if(varMeLL<varMe && varMe>varMeHL)
				Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
				T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(varMeLL)}
				T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(varMeHL)}		
				Redimension /N=((curLen+1),2) Gen_Constraints
				Gen_Constraints[curLen][0] = varMeLL
				Gen_Constraints[curLen][1] = varMeHL
			endif
		endif
	endfor
	FullListOfVariablesToCheck+=ListOfVariablesToCheck
	//	IR2H_ResetErrors()
	For(i=0;i<itemsInList(FullListOfVariablesToCheck);i+=1)
		NVAR ValError = $(StringFromList(i, FullListOfVariablesToCheck)+"Error")
		ValError = 0	
	endfor
	
	
	DoWindow /F IR3S_LogLogDataDisplay
	wave/Z OriginalDataIntWave=root:Packages:Irena:SysSpecModels:OriginalDataIntWave
	if(!WaveExists(OriginalDataIntWave))//wave does nto exist, user probably did nto ccreate data yet.
		abort
	endif
	Wave OriginalDataQWave=root:Packages:Irena:SysSpecModels:OriginalDataQWave
	Wave OriginalDataErrorWave=root:Packages:Irena:SysSpecModels:OriginalDataErrorWave
	
	Variable V_chisq
	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/20
	string HoldStr=""
				//	For(i=0;i<numpnts(W_Coef);i+=1)
				//		HoldStr+="0"
				//	endfor
				//
				////	IR2H_RecordResults("before")
				//	
				//	if(UseGeneticOptimization)
				//		//and now the fit...
				//		if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
				//			//check that cursors are actually on hte right wave...
				//			//make sure the cursors are on the right waves..
				//			if (cmpstr(CsrWave(A, "IR2H_LogLogPlotGels"),"IntensityOriginal")!=0)
				//				Cursor/P/W=IR2H_LogLogPlotGels A  OriginalIntensity  binarysearch(OriginalQvector, CsrXWaveRef(A) [pcsr(A, "IR2H_LogLogPlotGels")])
				//			endif
				//			if (cmpstr(CsrWave(B, "IR2H_LogLogPlotGels"),"IntensityOriginal")!=0)
				//				Cursor/P /W=IR2H_LogLogPlotGels B  OriginalIntensity  binarysearch(OriginalQvector,CsrXWaveRef(B) [pcsr(B, "IR2H_LogLogPlotGels")])
				//			endif
				//			Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalIntensity, FitIntensityWave		
				//			Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalQvector, FitQvectorWave
				//			Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalError, FitErrorWave
				//			//***Catch error issues
				//			wavestats/Q FitErrorWave
				//			if(V_Min<1e-20)
				//				Print "Warning: Looks like you have some very small uncertainties (ERRORS). Any point with uncertaitny (error) < = 0 is masked off and not fitted. "
				//				Print "Make sure your uncertainties are all LARGER than 0 for ALL points." 
				//			endif
				//			if(V_avg<=0)
				//				Print "Note: these are uncertainties after scaling/processing. Did you accidentally scale uncertainties by 0 ? " 
				//				Abort "Uncertainties (ERRORS) make NO sense. Points with uncertainty (error) <= 0 are not fitted and this causes troubles. Fix uncertainties and try again. See history area for more details."
				//			endif
				//			//***End of Catch error issues
				//			//FuncFit /N/Q IR2H_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D /C=T_Constraints 
				//#if Exists("gencurvefit")
				//			Duplicate/O FitIntensityWave, GenMaskWv
				//			GenMaskWv=1
				//		  	gencurvefit  /I=1 /W=FitErrorWave /M=GenMaskWv /N /TOL=0.001 /K={50,20,0.7,0.5} /X=FitQvectorWave IR2H_FitFunction, FitIntensityWave  , W_Coef, HoldStr, Gen_Constraints  	
				//#else
				//			Abort "Genetic Optimization xop NOT installed. Install xop support and then try again"
				//#endif
				//		else
				//			Duplicate/O OriginalIntensity, FitIntensityWave		
				//			Duplicate/O OriginalQvector, FitQvectorWave
				//			Duplicate/O OriginalError, FitErrorWave
				//			//***Catch error issues
				//			wavestats/Q FitErrorWave
				//			if(V_Min<1e-20)
				//				Print "Warning: Looks like you have some very small uncertainties (ERRORS). Any point with uncertaitny (error) < = 0 is masked off and not fitted. "
				//				Print "Make sure your uncertainties are all LARGER than 0 for ALL points." 
				//			endif
				//			if(V_avg<=0)
				//				Print "Note: these are uncertainties after scaling/processing. Did you accidentally scale uncertainties by 0 ? " 
				//				Abort "Uncertainties (ERRORS) make NO sense. Points with uncertainty (error) <= 0 are not fitted and this causes troubles. Fix uncertainties and try again. See history area for more details."
				//			endif
				//			//***End of Catch error issues
				//			//FuncFit /N/Q IR2H_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D /C=T_Constraints	
				//#if Exists("gencurvefit")
				//		  	gencurvefit  /I=1 /W=FitErrorWave /M=GenMaskWv /N /TOL=0.001 /K={50,20,0.7,0.5} /X=FitQvectorWave IR2H_FitFunction, FitIntensityWave  , W_Coef, HoldStr, Gen_Constraints  	
				//#else
				//			Abort "Genetic Optimization xop NOT installed. Install xop support and then try again"
				//#endif
				//		endif
				////		if (V_FitError!=0)	//there was error in fitting
				////			IR2H_ResetParamsAfterBadFit()
				////			Abort "Fitting error, check starting parameters and fitting limits" 
				////		endif
				//		//this now records the errors for fitted parameters into the appropriate variables
				//		Wave W_sigma=root:Packages:Gels_Modeling:W_sigma
				//	
				//		For(i=0;i<(numpnts(CoefNames));i+=1)
				//			OneErrorName="root:Packages:Gels_Modeling:"+CoefNames[i]+"Error"
				//			NVAR Error=$(OneErrorName)
				//			Error=W_sigma[i]
				//		endfor
				//	else		
		//least squares...
		Variable V_FitError=0			//This should prevent errors from being generated
		//and now the fit...
		if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
			//check that cursors are actually on hte right wave...
			//make sure the cursors are on the right waves..
			if (cmpstr(CsrWave(A, "IR3S_LogLogDataDisplay"),"OriginalDataQWave")!=0)
				Cursor/P/W=IR3S_LogLogDataDisplay A  OriginalDataIntWave  binarysearch(OriginalDataQWave, CsrXWaveRef(A) [pcsr(A, "IR3S_LogLogDataDisplay")])
			endif
			if (cmpstr(CsrWave(B, "IR3S_LogLogDataDisplay"),"OriginalDataQWave")!=0)
				Cursor/P /W=IR3S_LogLogDataDisplay B  OriginalDataIntWave  binarysearch(OriginalDataQWave,CsrXWaveRef(B) [pcsr(B, "IR3S_LogLogDataDisplay")])
			endif
			Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalDataIntWave, FitIntensityWave		
			Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalDataQWave, FitQvectorWave
			Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalDataErrorWave, FitErrorWave
			FuncFit /N/Q IR3S_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D /C=T_Constraints 
		else
			Duplicate/O OriginalDataIntWave, FitIntensityWave		
			Duplicate/O OriginalDataQWave, FitQvectorWave
			Duplicate/O OriginalDataErrorWave, FitErrorWave
			FuncFit /N/Q IR3S_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D /C=T_Constraints	
		endif
		if (V_FitError!=0)	//there was error in fitting
			//	IR2H_ResetParamsAfterBadFit()
			For(i=0;i<(numpnts(CoefNames));i+=1)
				NVAR RestoreValue=$("root:Packages:Irena:SysSpecModels:"+CoefNames[i])
				RestoreValue=BackupFitValues[i]
			endfor
			Abort "Fitting error, Parameters resutored before failure. Check starting parameters and fitting limits" 
		endif
		//this now records the errors for fitted parameters into the appropriate variables
		Wave W_sigma=W_sigma
		For(i=0;i<(numpnts(CoefNames));i+=1)
			NVAR Error=$("root:Packages:Irena:SysSpecModels:"+CoefNames[i]+"Error")
			Error=W_sigma[i]
		endfor
		//	endif
		NVAR AchievedChiSquare=root:Packages:Irena:SysSpecModels:AchievedChiSquare
		AchievedChiSquare=V_chisq
		IR3S_AutoRecalculateModelData(1)

	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3S_FitFunction(w,yw,xw) : FitFunc
	Wave w,yw,xw
	
	//here the w contains the parameters, yw will be the result and xw is the input
	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(q) = very complex calculations, forget about formula
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1 - the q vector...
	//CurveFitDialog/ q
	//CurveFitDialog/ Coefficients 21 - up to, but never used
	Wave/T CoefNames=root:Packages:Irena:SysSpecModels:CoefNames		//text wave with names of parameters
	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	for (i=0;i<NumOfParam;i+=1)
		ParamName=CoefNames[i]
		Nvar TempParam=$("root:Packages:Irena:SysSpecModels:"+ParamName)
		TempParam=w[i]	
	endfor
	IR3S_CalculateModel(yw,xw,1)
	Wave resultWv=root:Packages:Irena:SysSpecModels:ModelIntensity
	yw=resultWv
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//	UpdateAutomatically
//	LinkUnifRgCO
//	ListOfVariablesMain="UseIndra2Data;UseQRSdata;DataQEnd;DataQStart;DataQEndPoint;DataQstartPoint;"
//	ListOfVariablesMain+="UpdateAutomatically;AchievedChiSquare;ScatteringContrast;SlitLength;UseSlitSmearedData;"
//	ListOfVariablesMain+="SaveToNotebook;SaveToWaves;SaveToFolder;DelayBetweenProcessing;"
//	
//	//background
//	ListOfVariablesBG="SASBackground;FitSASBackground;SASBackgroundLL;SASBackgroundHL;SASBackgroundError;"
//
//	//Unified level
//	ListOfVariablesUF="UseUnified;UnifRgCO;LinkUnifRgCO;"
//	ListOfVariablesUF+="UnifPwrlawP;FitUnifPwrlawP;UnifPwrlawPLL;UnifPwrlawPHL;UnifPwrlawPError"
//	ListOfVariablesUF+="UnifPwrlawB;FitUnifPwrlawB;UnifPwrlawBLL;UnifPwrlawBHL;UnifPwrlawBError;"
//	ListOfVariablesUF+="UnifRg;FitUnifRg;UnifRgLL;UnifRgHL;UnifRgError;"
//	ListOfVariablesUF+="UnifG;FitUnifG;UnifGLL;UnifGHL;UnifGError;"
//	//Debye-Bueche parameters	
//	ListOfVariablesBD="DBPrefactor;FitDBPrefactor;DBPrefactorHL;DBPrefactorLL;"
//	ListOfVariablesBD+="DBcorrL;FitDBcorrL;DBcorrLLL;DBcorrLHL;DBcorrLError;"
//	ListOfVariablesBD+="DBEta;FitDBEta;DBEtaLL;DBEtaHL;DBEtaError;"
//	ListOfVariablesBD+="DBWavelength;"
//	ListOfVariablesBD+=""
//	//Teubner-Strey Model
//	ListOfVariablesTS="TSPrefactor;FitTSPrefactor;TSPrefactorHL;TSPrefactorLL;TSPrefactorError;"
//	ListOfVariablesTS+="TSAvalue;FitTSAvalue;TSAvalueHL;TSAvalueLL;TSAvalueError;"
//	ListOfVariablesTS+="TSC1Value;FitTSC1Value;TSC1ValueHL;TSC1ValueLL;TSC1ValueError;"
//	ListOfVariablesTS+="TSC2Value;FitTSC2Value;TSC2ValueHL;TSC2ValueLL;TSC2ValueError;"
//	ListOfVariablesTS+="TSCorrelationLength;TSCorrLengthError;TSRepeatDistance;TSRepDistError;"
//	//Benedetti-Ciccariello Coated Porous media Porods oscillations
//	ListOfVariablesBC ="BCVoidScatLengthDensity;BCSolidScatLengthDensity;"
//	ListOfVariablesBC+="BCLayerScatLengthDens;BCLayerScatLengthDensHL;BCLayerScatLengthDensLL;FitBCLayerScatLengthDens;BCLayerScatLengthDensError;"
//	ListOfVariablesBC+="BCCoatingsThickness;BCCoatingsThicknessHL;BCCoatingsThicknessLL;FitBCCoatingsThickness;BCCoatingsThicknessError;"
//	ListOfVariablesBC+="BCPorodsSpecSurfArea;FitBCPorodsSpecSurfArea;BCPorodsSpecSurfAreaHL;BCPorodsSpecSurfAreaLL;BCPorodsSpecSurfAreaError;"

//	SVAR ListOfVariablesBC = root:Packages:Irena:SysSpecModels:ListOfVariablesBC
//	SVAR ListOfVariablesTS = root:Packages:Irena:SysSpecModels:ListOfVariablesTS
//	SVAR ListOfVariablesDB = root:Packages:Irena:SysSpecModels:ListOfVariablesDB
//	SVAR ListOfVariablesUF = root:Packages:Irena:SysSpecModels:ListOfVariablesUF
//	SVAR ListOfVariablesBG = root:Packages:Irena:SysSpecModels:ListOfVariablesBG
//	SVAR ListOfVariablesMain = root:Packages:Irena:SysSpecModels:ListOfVariablesMain
//	
//	ListOfVariables = ListOfVariablesMain+ListOfVariablesUF+ ListOfVariablesBD+ ListOfVariablesTS+ ListOfVariablesBC+ListOfVariablesBG
//
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR3S_EstimateCorrL()

	wave/Z OriginalIntensity=root:Packages:Irena:SysSpecModels:OriginalDataIntWave
	if(!WaveExists(OriginalIntensity))//wave does nto exist, user probably did nto ccreate data yet.
		abort
	endif
	Wave OriginalQvector=root:Packages:Irena:SysSpecModels:OriginalDataQWave
	Wave OriginalError=root:Packages:Irena:SysSpecModels:OriginalDataErrorWave

	Duplicate/Free OriginalIntensity, OriginalQ2, OriginalSqrtIntN1, OriginalSqrtErrN1
	OriginalQ2=OriginalQvector^2
	OriginalSqrtIntN1=1/sqrt(OriginalIntensity)
	OriginalSqrtErrN1=OriginalSqrtIntN1 * (OriginalError/OriginalIntensity)
	
	if(strlen(CsrWave(A, "IR3S_LogLogDataDisplay"))<=0 || strlen(CsrWave(B, "IR3S_LogLogDataDisplay"))<=0)
		Abort "Cursors not set correctly in the IR3S_LogLogDataDisplay graph. Set cursors in IR3S_LogLogDataDisplay "
	endif
	variable cursA, cursB
	cursA= pcsr(A  , "IR3S_LogLogDataDisplay")
	cursB= pcsr(B  , "IR3S_LogLogDataDisplay")
	//DoWindow/F IR2H_SI_Q2_PlotGels
	//SetAxis/W=IR2H_SI_Q2_PlotGels bottom 0,1.3*OriginalQ2[cursB] 
	//SetAxis/W=IR2H_SI_Q2_PlotGels left 0.3*OriginalSqrtIntN1[cursA],2*OriginalSqrtIntN1[cursB] 
	CurveFit line  OriginalSqrtIntN1[cursA,cursB] /X=OriginalQ2 /W=OriginalSqrtErrN1 /I=1 /D 
	//ModifyGraph/W=IR2H_SI_Q2_PlotGels mode(fit_OriginalSqrtIntN1)=0
	NVAR corrL=root:Packages:Irena:SysSpecModels:DBcorrL
	NVAR DBEta=root:Packages:Irena:SysSpecModels:DBEta
	Wave W_coef
	corrL = sqrt(W_coef[1]/W_coef[0])
	IR3S_AutoRecalculateModelData(1)
	Wave DBModelInt=root:Packages:Irena:SysSpecModels:DBModelInt
	variable AveModel, AveData
	wavestats/Q/R=[cursA,cursB] OriginalIntensity
	AveData = V_avg
	wavestats/Q/R=[cursA,cursB] DBModelInt
	AveModel = V_avg
	DBEta *= sqrt(AveData/AveModel)
	IR3S_AutoRecalculateModelData(1)

end
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR3S_EstimateLowQslope()

	dfref oldDf=GetDataFolderDFR
	setDataFolder root:Packages:Irena:SysSpecModels
	
	wave/Z OriginalIntensity=root:Packages:Irena:SysSpecModels:OriginalDataIntWave
	if(!WaveExists(OriginalIntensity))//wave does not exist, user probably did nto ccreate data yet.
		abort
	endif
	Wave OriginalQvector=root:Packages:Irena:SysSpecModels:OriginalDataQWave
	Wave OriginalError=root:Packages:Irena:SysSpecModels:OriginalDataErrorWave
	variable cursA, cursB
	if(strlen(CsrWave(A, "IR3S_LogLogDataDisplay"))<=0 || strlen(CsrWave(B, "IR3S_LogLogDataDisplay"))<=0)
		Abort "Cursors not set correctly in the IR3S_LogLogDataDisplay graph. Set cursors in IR3S_LogLogDataDisplay."
	endif
	cursA= pcsr(A  , "IR3S_LogLogDataDisplay")
	cursB= pcsr(B  , "IR3S_LogLogDataDisplay")
	Make/O/N=2/T T_Constraints	
	T_Constraints={"K2<-1","K2>-5"}
	CurveFit/Q power  OriginalIntensity[cursA,cursB] /X=OriginalQvector /W=OriginalError /I=1 /C=T_Constraints	
	NVAR UseSlitSmearedData=root:Packages:Irena:SysSpecModels:UseSlitSmearedData
	NVAR LowQslope=root:Packages:Irena:SysSpecModels:UnifPwrlawP
	NVAR LowQPrefactor=root:Packages:Irena:SysSpecModels:UnifPwrlawB
	Wave W_coef
	if(UseSlitSmearedData)
		LowQslope = -(W_coef[2] - 1)
		LowQPrefactor = W_coef[1]
	else
		LowQslope = -W_coef[2]
		LowQPrefactor = W_coef[1]
	endif
	IR3S_GraphModelData()
	Wave OriginalIntensity=root:Packages:Irena:SysSpecModels:OriginalDataIntWave
	Wave ModelIntensity=root:Packages:Irena:SysSpecModels:ModelIntensity
	variable AveModel, AveData
	wavestats/Q/R=[cursA,cursB] OriginalIntensity
	AveData = V_avg
	wavestats/Q/R=[cursA,cursB] ModelIntensity
	AveModel = V_avg
	LowQPrefactor *= (AveData/AveModel)
	IR3S_GraphModelData()
	setDataFolder oldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR3S_AutoRecalculateModelData(variable Force)
	//next we calculate the model
	NVAR UpdateAutomatically=root:Packages:Irena:SysSpecModels:UpdateAutomatically
	if(UpdateAutomatically||Force)
		IR3S_AttachTags(0)
		IR3S_GraphModelData()
	endif

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR3S_GraphModelData()
	//next we calculate the model
	
	DFref oldDf= GetDataFolderDFR()
	setDataFolder root:Packages:Irena:SysSpecModels
	wave/Z OriginalIntensity=root:Packages:Irena:SysSpecModels:OriginalDataIntWave
	if(!WaveExists(OriginalIntensity))//wave does not exist, user probably did nto ccreate data yet.
		abort
	endif
	DoWIndow IR3S_LogLogDataDisplay
	if(V_Flag)
		CheckDisplayed /W=IR3S_LogLogDataDisplay OriginalIntensity
		if(V_Flag)
			Wave OriginalQvector=root:Packages:Irena:SysSpecModels:OriginalDataQWave
			Wave OriginalError=root:Packages:Irena:SysSpecModels:OriginalDataErrorWave
			IR3S_CalculateModel(OriginalIntensity,OriginalQvector,0)
			Wave ModelIntensity=root:Packages:Irena:SysSpecModels:ModelIntensity
			//residuals, see IR2H_CalcAndPlotResiduals(OriginalIntensity,OriginalError, ModelIntensity)
			Duplicate/O OriginalIntensity, Residuals
			Residuals = (OriginalIntensity - ModelIntensity) / OriginalError
			CheckDisplayed /W=IR3S_LogLogDataDisplay ModelIntensity
			if(V_Flag<1)
				AppendToGraph /W=IR3S_LogLogDataDisplay  ModelIntensity vs OriginalQvector
				ModifyGraph/W=IR3S_LogLogDataDisplay lstyle(ModelIntensity)=3,lsize(ModelIntensity)=3,rgb(ModelIntensity)=(1,12815,52428)
			endif
			CheckDisplayed /W=IR3S_LogLogDataDisplay Residuals
			if(V_Flag<1)
				AppendToGraph /W=IR3S_LogLogDataDisplay/R  Residuals vs OriginalQvector
				ModifyGraph /W=IR3S_LogLogDataDisplay mode(Residuals)=2,rgb(Residuals)=(0,0,0)
				SetAxis/A/E=2/W=IR3S_LogLogDataDisplay right
				Label/W=IR3S_LogLogDataDisplay right "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Residuals"
			endif
		endif
	endif		
//	IR2H_AppendModelToMeasuredData()
//	TextBox/W=IR2H_SI_Q2_PlotGels/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
//	TextBox/W=IR2H_IQ4_Q_PlotGels/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=IR3S_LogLogDataDisplay/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
//	TextBox/W=IR2H_ResidualsPlot/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	setDataFolder oldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
static FUnction IR3S_SetRGCOAsNeeded()

	SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
	
	NVAR LinkUnifRgCO	=root:Packages:Irena:SysSpecModels:LinkUnifRgCO
	NVAR UnifRgCO		=root:Packages:Irena:SysSpecModels:UnifRgCO
	NVAR DBcorrL		=root:Packages:Irena:SysSpecModels:DBcorrL
	NVAR LinkUnifRgCO	=root:Packages:Irena:SysSpecModels:LinkUnifRgCO
	NVAR TSAvalue		=root:Packages:Irena:SysSpecModels:TSAvalue
	NVAR TSC1Value		=root:Packages:Irena:SysSpecModels:TSC1Value
	NVAR TSC2Value		=root:Packages:Irena:SysSpecModels:TSC2Value
	if(LinkUnifRgCO)
		if(StringMatch(ModelSelected, "Debye-Bueche") )
			UnifRgCO=DBcorrL
		elseif(StringMatch(ModelSelected, "Treubner-Strey") )
			UnifRgCO = 1/sqrt(0.5*sqrt(TSAvalue/TSC2Value)+TSC1Value/4/TSC2Value)
		else
			UnifRgCO = 0
		endif
	else
		//UnifRgCO = 0
	endif

end

//*****************************************************************************************************************

static Function IR3S_CalculateModel(OriginalIntensity,OriginalQvector, calledFromFitting)
	wave OriginalIntensity,OriginalQvector
	variable calledFromFitting

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:SysSpecModels

	
	Duplicate/O OriginalIntensity, ModelIntensity,ModelIntensityQ4,ModelIntensityQ3, DebyBuecheIntensity, UnifiedFitIntensity, UnsmearedModelIntensity, DBModelIntSqrtN1, TreubnerStreyIntensity
	Duplicate/O OriginalIntensity, CiccBenModelIntensity, UnifiedModelInt, DBModelInt, TSModelInt, CBModelInt
	Duplicate/O OriginalQvector, DBModelQvector, QstarVector
	DebyBuecheIntensity=0
	UnifiedFitIntensity=0
	UnsmearedModelIntensity=0
	TreubnerStreyIntensity=0
	CiccBenModelIntensity=0
	
	NVAR UseSlitSmearedData=root:Packages:Irena:SysSpecModels:UseSlitSmearedData
	NVAR SlitLength=root:Packages:Irena:SysSpecModels:SlitLength
	NVAR SASBackground=root:Packages:Irena:SysSpecModels:SASBackground
	NVAR DBPrefactor=root:Packages:Irena:SysSpecModels:DBPrefactor
	NVAR DBEta=root:Packages:Irena:SysSpecModels:DBEta
	NVAR DBcorrL=root:Packages:Irena:SysSpecModels:DBcorrL
	NVAR UnifPwrlawP=root:Packages:Irena:SysSpecModels:UnifPwrlawP
	NVAR UnifPwrlawB=root:Packages:Irena:SysSpecModels:UnifPwrlawB
	NVAR UnifRgCO=root:Packages:Irena:SysSpecModels:UnifRgCO
	NVAR UnifRg=root:Packages:Irena:SysSpecModels:UnifRg
	
	NVAR DBWavelength=root:Packages:Irena:SysSpecModels:DBWavelength
	NVAR SASBackground=root:Packages:Irena:SysSpecModels:SASBackground
	NVAR UseUnified=root:Packages:Irena:SysSpecModels:UseUnified
	NVAR TSPrefactor=root:Packages:Irena:SysSpecModels:TSPrefactor
	NVAR TSAvalue=root:Packages:Irena:SysSpecModels:TSAvalue
	NVAR TSC1Value=root:Packages:Irena:SysSpecModels:TSC1Value
	NVAR TSC2Value=root:Packages:Irena:SysSpecModels:TSC2Value
	NVAR UnifG=root:Packages:Irena:SysSpecModels:UnifG
	NVAR TSCorrelationLength=root:Packages:Irena:SysSpecModels:TSCorrelationLength
	NVAR TSRepeatDistance=root:Packages:Irena:SysSpecModels:TSRepeatDistance
	
	NVAR BCPorodsSpecSurfArea=root:Packages:Irena:SysSpecModels:BCPorodsSpecSurfArea			//[cm2/cm3]
	NVAR BCSolidScatLengthDensity=root:Packages:Irena:SysSpecModels:BCSolidScatLengthDensity		//N1 [10^10 cm^-2]
	NVAR BCVoidScatLengthDensity=root:Packages:Irena:SysSpecModels:BCVoidScatLengthDensity		//N2 [10^10 cm^-2]
	NVAR BCLayerScatLengthDens=root:Packages:Irena:SysSpecModels:BCLayerScatLengthDens		//N3 [10^10 cm^-2]
	NVAR BCCoatingsThickness=root:Packages:Irena:SysSpecModels:BCCoatingsThickness				//[A]
	NVAR SlitLength = root:Packages:Irena:SysSpecModels:SlitLength	
	NVAR UseSlitSmearedData = root:Packages:Irena:SysSpecModels:UseSlitSmearedData	

	SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
	NVAR LinkUnifRgCO=root:Packages:Irena:SysSpecModels:LinkUnifRgCO
	IR3S_SetRGCOAsNeeded()
		//	if(StringMatch(ModelSelected, "Debye-Bueche") )
		//		UnifRgCO=DBcorrL
		//	elseif(StringMatch(ModelSelected, "Treubner-Strey") )
		////		TSCorrelationLength = 1/sqrt(0.5*sqrt(TSAvalue/TSC2Value)+TSC1Value/4/TSC2Value)
		////		UnifRgCO=TSCorrelationLength
		//	endif
	// first Debye-Bueche theory
	//I(q) = (4*pi*K*eta^2*corrL^2)/(1+q^2*corrL^2)^2
	//K = 8*pi^2*n^2*lambda^-4
	// q = (4*pi*n/lambda)* sin(theta/2).
	//n=1
	//correction 2012/08, Fan realized, that the theory has DBCorrL in 3rd power in the numerator.
	//correct formula should be: DebyBuecheIntensity = DBPrefactor*(4*pi*DBK*DBeta^2*DBcorrL^3)/(1+OriginalQvector^2*DBcorrL^2)^2
	//not DebyBuecheIntensity = DBPrefactor*(4*pi*DBK*DBeta^2*DBcorrL^2)/(1+OriginalQvector^2*DBcorrL^2)^2
	//                                                                                              ^^^
	//It is bit puzzling with the Wavelength which does not seem to be part of Hamoud's writeup on this, but assume it is 3rd power for now. 

	if(UseUnified)			//Unified level
		QstarVector=OriginalQvector/(erf(OriginalQvector*UnifRg/sqrt(6)))^3	
		UnifiedFitIntensity=UnifG*exp(-OriginalQvector^2*UnifRg^2/3)+(UnifPwrlawB/QstarVector^UnifPwrlawP)* exp(-UnifRgCO^2 * OriginalQvector^2/3)
		//UnifiedFitIntensity = UnifPwrlawB * OriginalQvector^(-1*UnifPwrlawP)
	else
		UnifiedFitIntensity = 0
	endif

	//debye-bueche
	variable DBK = 8 * pi^2 * DBWavelength^(-4)		
	if(StringMatch(ModelSelected, "Debye-Bueche" ))
		//DebyBuecheIntensity = DBPrefactor*(4*pi*DBK*DBeta^2*DBcorrL^2)/(1+OriginalQvector^2*DBcorrL^2)^2
		DebyBuecheIntensity = DBPrefactor*(4*pi*DBK*DBeta^2*DBcorrL^3)/(1+OriginalQvector^2*DBcorrL^2)^2			//changed 2012/08
	else
		DebyBuecheIntensity = 0
	endif

	//Treubner-Strey
	if(StringMatch(ModelSelected, "Treubner-Strey" ))
		TreubnerStreyIntensity = TSPrefactor / (TSAvalue + TSC1Value * OriginalQvector^2 + TSC2Value* OriginalQvector^4)
		TSCorrelationLength = 1/sqrt(0.5*sqrt(TSAvalue/TSC2Value)+TSC1Value/4/TSC2Value)
		//	xi = 0.5*sqrt(a2/c2) + c1/4/c2
		//	xi = 1/sqrt(xi)
		TSRepeatDistance = 2*pi/sqrt(0.5*sqrt(TSAvalue/TSC2Value) - TSC1Value/4/TSC2Value)
		//	dd = 0.5*sqrt(a2/c2) - c1/4/c2
		//	dd = 1/sqrt(dd)
		//	dd *=2*Pi
	else
		TreubnerStreyIntensity=0	
	endif

	//Ciccariello's  coated porous media
	//nu = (n13 - n32)/n12
	//where n13 =  N1 - N3 etc. 
	// nu = (n13 - n32)/n12 = (N1-2N2+N3)/(N1-N2) 
	variable n12 = BCSolidScatLengthDensity*1e10 - BCVoidScatLengthDensity*1e10
	variable NuValue = ((BCSolidScatLengthDensity - 2*BCLayerScatLengthDens + BCVoidScatLengthDensity))/(BCSolidScatLengthDensity - BCVoidScatLengthDensity)
	variable ALpha = (1 + NuValue^2)/2
	variable Rnu = (1-NuValue^2)/(1+NuValue^2)
	//COMMON...
	//pinhole data or data with finite slit length
	if(StringMatch(ModelSelected, "Benedetti-Ciccariello" ))
		if(!UseSlitSmearedData||(UseSlitSmearedData&&numtype(SlitLength)==0))								//Ciccariello's  coated porous media
			//and now I(q) = (2*pi*n12^2*alpha*BCPorodsSpecSurfArea / Q^4) * [1+Rnu*cos(Q*BCCoatingsThickness)]+BCMicroscDensFluctuations
			//print (2*pi*n12^2*alpha*BCPorodsSpecSurfArea / (OriginalQvector[120]^4*1e32))		
			CiccBenModelIntensity = (2*pi*n12^2*alpha*BCPorodsSpecSurfArea / (OriginalQvector^4*1e32)) * (1+Rnu*cos(OriginalQvector*BCCoatingsThickness))
		else
			CiccBenModelIntensity=0
		endif
	endif
	//	//and now deal with infinite slit length case for  Benedetti-Ciccariello model
	//	if(UseCiccBen&&(UseSlitSmearedData&&numtype(SlitLength)!=0))								//Ciccariello's  coated porous media
	//		//print (pi^2*n12^2*alpha*BCPorodsSpecSurfArea / (OriginalQvector[120]^3*1e32))	
	//		CiccBenModelIntensity = (pi^2*n12^2*alpha*BCPorodsSpecSurfArea / (OriginalQvector^3*1e32)) * (1+Rnu*IR2H_CiccBenFiFunction(OriginalQvector*BCCoatingsThickness))
	//		ModelIntensity= CiccBenModelIntensity
	//		CBModelInt = CiccBenModelIntensity
	//	endif
	
	
	UnsmearedModelIntensity = DebyBuecheIntensity + UnifiedFitIntensity + TreubnerStreyIntensity + CiccBenModelIntensity + SASBackground
	//slit smear with finite slit length...
	if(UseSlitSmearedData&&numtype(SlitLength)==0)
		//print "slit smeared"
		IR1B_SmearData(UnsmearedModelIntensity, OriginalQvector, slitLength, ModelIntensity)
		if(!calledFromFitting)
			if(sum(DebyBuecheIntensity)>0)
				IR1B_SmearData(DebyBuecheIntensity, OriginalQvector, slitLength, DBModelInt)
			endif
			if(sum(UnifiedFitIntensity)>0)
				IR1B_SmearData(UnifiedFitIntensity, OriginalQvector, slitLength, UnifiedModelInt)
			endif
			if(sum(TreubnerStreyIntensity)>0)
				IR1B_SmearData(TreubnerStreyIntensity, OriginalQvector, slitLength, TSModelInt)
			endif
			if(sum(CiccBenModelIntensity)>0)
				IR1B_SmearData(CiccBenModelIntensity, OriginalQvector, slitLength, CBModelInt)
			endif
		endif
	else
		ModelIntensity= UnsmearedModelIntensity	
		DBModelInt = DebyBuecheIntensity
		UnifiedModelInt = UnifiedFitIntensity
		TSModelInt = TreubnerStreyIntensity
		CBModelInt = CiccBenModelIntensity
	endif

	Duplicate/O OriginalQvector, OriginalQvector4, OriginalQvector3
	OriginalQvector4 = OriginalQvector^4
	OriginalQvector3 = OriginalQvector^3
	ModelIntensityQ4= ModelIntensity*OriginalQvector^4
	ModelIntensityQ3= ModelIntensity*OriginalQvector^3
	DBModelIntSqrtN1 = 1/(sqrt(ModelIntensity))
	
	setDataFolder OldDf
end
//*****************************************************************************************************************


//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR3S_SaveResultsToWaves()

	NVAR SaveToWaves=root:Packages:Irena:SysSpecModels:SaveToWaves
	if(SaveToWaves<1)
		return 0
	endif
	DFref oldDf= GetDataFolderDFR()
	setDataFolder root:Packages:Irena:SysSpecModels	
	SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
	
	string ListOfVariables=""
	string TmpName, TempVarName
	variable i
	SVAR DataFolderName = root:Packages:Irena:SysSpecModels:DataFolderName
	SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
	SVAR ListOfVariablesBC = root:Packages:Irena:SysSpecModels:ListOfVariablesBC
	SVAR ListOfVariablesTS = root:Packages:Irena:SysSpecModels:ListOfVariablesTS
	SVAR ListOfVariablesDB = root:Packages:Irena:SysSpecModels:ListOfVariablesDB
	SVAR ListOfVariablesUF = root:Packages:Irena:SysSpecModels:ListOfVariablesUF
	SVAR ListOfVariablesBG = root:Packages:Irena:SysSpecModels:ListOfVariablesBG
	SVAR ListOfVariablesMain = root:Packages:Irena:SysSpecModels:ListOfVariablesMain
	ListOfVariables += ListOfVariablesMain+ListOfVariablesUF
	string TargetFolder
	strswitch(ModelSelected)	// string switch
		case "Debye-Bueche":	// execute if case matches expression
			ListOfVariables+=ListOfVariablesDB
			TargetFolder="DebyeBuecheResults"
			break
		case "Treubner-Strey":	// execute if case matches expression
			//Teubner-Strey Model
			ListOfVariables+=ListOfVariablesTS
			TargetFolder="TreubnerStreyResults"
			break
		case "Benedetti-Ciccariello":	// execute if case matches expression
			//Ciccariello Coated Porous media Porods oscillations
			ListOfVariables+=ListOfVariablesBC
			TargetFolder="BenedettiCiccarielloResults"
			break
	endswitch
	//now clean up data names we do not want to save 
	ListOfVariables = GrepList(ListOfVariables, "^Fit",1)
	ListOfVariables = GrepList(ListOfVariables, "LL$",1)
	ListOfVariables = GrepList(ListOfVariables, "HL$",1)
	ListOfVariables = GrepList(ListOfVariables, "DataQ|UseIndra2|UseQRS|Update",1)
	ListOfVariables = GrepList(ListOfVariables, "Delay|Link|Save",1)
	//this removed most of the crud users likely do not want... 
	string ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	NewDataFolder/O/S root:$(TargetFolder)
	print "Saving results from "+ModelSelected+" in folder : "+TargetFolder
	print "This folder has number of waves with results redy to be plotted or put in tables"
	Wave/Z/T DataFolderNameWv
	if(!WaveExists(DataFolderNameWv))
		Make/O/N=0/T DataFolderNameWv, IntensityWaveNameWv, QWavenameWv, ErrorWaveNameWv
		Make/O/N=0 TimeWave, TemperatureWave,PercentWave, OrderWave
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			TmpName = StringFromList(i, ListOfVariables)+"Wv"
			Make/O/N=0 $(TmpName)
		endfor
	endif
	variable curLength=numpnts(DataFolderNameWv)
	For(i=0;i<itemsInList(ListOfStrings);i+=1)
		SVAR TempStr = $("root:Packages:Irena:SysSpecModels:"+stringFromList(i,ListOfStrings))
		Wave/T TmpStrWv = $(stringFromList(i,ListOfStrings)+"Wv")
		redimension/N=(curLength+1) TmpStrWv
		TmpStrWv[curLength] = TempStr
	endfor
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		TempVarName = stringFromList(i,ListOfVariables)
		NVAR TempVal = $("root:Packages:Irena:SysSpecModels:"+TempVarName)
		Wave TmpWv = $(TempVarName+"Wv")
		redimension/N=(curLength+1) TmpWv
		TmpWv[curLength] = TempVal
	endfor
	//now create temperature, time etc if thisis in folder name stored... 
	Wave TimeWave, TemperatureWave,PercentWave, OrderWave
	redimension/N=(curlength+1) TimeWave, TemperatureWave,PercentWave, OrderWave
	TimeWave[curlength]				=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzmin")
	TemperatureWave[curlength]  	=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzC")
	PercentWave[curlength] 			=	IN2G_IdentifyNameComponent(DataFolderName, "_xyzpct")
	OrderWave[curlength]			= 	IN2G_IdentifyNameComponent(DataFolderName, "_xyz")
	setDataFolder OldDf
end
//***************************************************************************************
//***************************************************************************************


static Function IR3S_SaveResultsToFolder(DoNotAskUser)
	variable DoNotAskUser		//set to 1 to prevent questions, when doing sequence... 
	NVAR SaveToFolder=root:Packages:Irena:SysSpecModels:SaveToFolder
	if(SaveToFolder<1)
		return 0
	endif

	//here we need to copy the final data back to folder
	//before that we need to also attach note to the waves with the results
	
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:SysSpecModels	
	Wave modelIntensity=root:Packages:Irena:SysSpecModels:ModelIntensity
	Wave modelQvector=root:Packages:Irena:SysSpecModels:OriginalDataQWave
//	SVAR DataFolderName=root:Packages:Irena:SysSpecModels:DataFolderName
//	
	SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
	string UsersComment="Result from "+ModelSelected+" Model "+date()+"  "+time()
	if(!DoNotAskUser)
		Prompt UsersComment, "Modify comment to be saved with these results"
		DoPrompt "Need input for saving data", UsersComment
		if (V_Flag)
			abort
		endif
	endif

	Duplicate/O ModelIntensity, tempDBModelIntensity
	Duplicate/O ModelQvector, tempDBModelQvector
	string ListOfWavesForNotes="tempDBModelQvector;tempDBModelIntensity;"
	string ListOfVariables=""
	SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
	SVAR ListOfVariablesBC = root:Packages:Irena:SysSpecModels:ListOfVariablesBC
	SVAR ListOfVariablesTS = root:Packages:Irena:SysSpecModels:ListOfVariablesTS
	SVAR ListOfVariablesDB = root:Packages:Irena:SysSpecModels:ListOfVariablesDB
	SVAR ListOfVariablesUF = root:Packages:Irena:SysSpecModels:ListOfVariablesUF
	SVAR ListOfVariablesBG = root:Packages:Irena:SysSpecModels:ListOfVariablesBG
	SVAR ListOfVariablesMain = root:Packages:Irena:SysSpecModels:ListOfVariablesMain
	ListOfVariables += ListOfVariablesMain+ListOfVariablesUF
	strswitch(ModelSelected)	// string switch
		case "Debye-Bueche":	// execute if case matches expression
			ListOfVariables+=ListOfVariablesDB
			break
		case "Treubner-Strey":	// execute if case matches expression
			//Teubner-Strey Model
			ListOfVariables+=ListOfVariablesTS
			break
		case "Benedetti-Ciccariello":	// execute if case matches expression
			//Ciccariello Coated Porous media Porods oscillations
			ListOfVariables+=ListOfVariablesBC
			break
	endswitch

	
	string ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	variable i,j
	For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
		For(i=0;i<itemsInList(ListOfVariables);i+=1)
			NVAR TempVal = $("root:Packages:Irena:SysSpecModels:"+stringFromList(i,ListOfVariables))
			IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),"SysSpecModels_"+stringFromList(i,ListOfVariables),num2str(TempVal))
		endfor
	endfor
	For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
		For(i=0;i<itemsInList(ListOfStrings);i+=1)
			SVAR TempStr = $("root:Packages:Irena:SysSpecModels:"+stringFromList(i,ListOfStrings))
			IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),"SysSpecModels_"+stringFromList(i,ListOfStrings),TempStr)
		endfor
	endfor
	
	SVAR DataFolderName=root:Packages:Irena:SysSpecModels:DataFolderName
	setDataFolder $DataFolderName
	string tempname 
	variable ii=0
	For(ii=0;ii<1000;ii+=1)
		tempname="SysSpecModelInt_"+num2str(ii)
		if (checkname(tempname,1)==0)
			break
		endif
	endfor
	Duplicate /O tempDBModelIntensity, $tempname
	Wave MytempWave=$tempname
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","1/cm")
	Redimension/D MytempWave
	
	tempname="SysSpecModelQvec_"+num2str(ii)
	Duplicate /O tempDBModelQvector, $tempname
	Wave MytempWave=$tempname
	IN2G_AppendorReplaceWaveNote(tempname,"UsersComment",UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname,"Wname",tempname)
	IN2G_AppendorReplaceWaveNote(tempname,"Units","1/A")
	Redimension/D MytempWave
	
	setDataFolder root:Packages:Irena:SysSpecModels
//
	Killwaves/Z tempDBModelQvector, tempDBModelIntensity
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR3S_SaveResultsToNotebook()

	NVAR SaveToNotebook=root:Packages:Irena:SysSpecModels:SaveToNotebook
	if(SaveToNotebook<1)
		return 0
	endif

	IR1_CreateResultsNbk()
	MoveWindow /W=IR3S_LogLogDataDisplay 400, 30, 980, 530
	IR3S_AttachTags(1)
	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:SysSpecModels
	SVAR  DataFolderName=root:Packages:Irena:SysSpecModels:DataFolderName
	SVAR  IntensityWaveName=root:Packages:Irena:SysSpecModels:IntensityWaveName
	SVAR  QWavename=root:Packages:Irena:SysSpecModels:QWavename
	SVAR  ErrorWaveName=root:Packages:Irena:SysSpecModels:ErrorWaveName
	SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
	IR1_AppendAnyText("\r Results of System Specific Modeling \r",1)	
	IR1_AppendAnyText("Date & time: \t"+Date()+"   "+time(),0)	
	IR1_AppendAnyText("Data from folder: \t"+DataFolderName,0)	
	IR1_AppendAnyText("Intensity: \t"+IntensityWaveName,0)	
	IR1_AppendAnyText("Q: \t"+QWavename,0)	
	IR1_AppendAnyText("Error: \t"+ErrorWaveName,0)	
	IR1_AppendAnyText("Model used: \t"+ModelSelected,0)	
	string FittingResults="\r\r"

	//Duplicate/O ModelIntensity, tempDBModelIntensity
	//Duplicate/O ModelQvector, tempDBModelQvector
	string ListOfWavesForNotes="tempDBModelQvector;tempDBModelIntensity;"
	string ListOfVariables=""
	SVAR ListOfVariablesBC = root:Packages:Irena:SysSpecModels:ListOfVariablesBC
	SVAR ListOfVariablesTS = root:Packages:Irena:SysSpecModels:ListOfVariablesTS
	SVAR ListOfVariablesDB = root:Packages:Irena:SysSpecModels:ListOfVariablesDB
	SVAR ListOfVariablesUF = root:Packages:Irena:SysSpecModels:ListOfVariablesUF
	SVAR ListOfVariablesBG = root:Packages:Irena:SysSpecModels:ListOfVariablesBG
	SVAR ListOfVariablesMain = root:Packages:Irena:SysSpecModels:ListOfVariablesMain
	ListOfVariables += ListOfVariablesMain+ListOfVariablesUF
	strswitch(ModelSelected)	// string switch
		case "Debye-Bueche":	// execute if case matches expression
			ListOfVariables+=ListOfVariablesDB
			NVAR DBPrefactor
			NVAR DBEta
			NVAR DBcorrL
			NVAR DBEtaError
			NVAR DBcorrLError
			FittingResults+="Prefactor = "+num2str(DBPrefactor)+"\r"
			FittingResults+="Eta = "+num2str(DBEta)+" +/- "+num2str(DBEtaError)+"\r"
			FittingResults+="Correlation Length = "+num2str(DBcorrL)+" +/- "+num2str(DBcorrLError)+"\r"
			break
		case "Treubner-Strey":	// execute if case matches expression
			//Teubner-Strey Model
			ListOfVariables+=ListOfVariablesTS
			NVAR TSPrefactor
			NVAR TSCorrelationLength
			NVAR TSRepeatDistance
			FittingResults+="Prefactor = "+num2str(TSPrefactor)+"\r"
			FittingResults+="Correlation Length = "+num2str(TSCorrelationLength)+"\r"
			FittingResults+="Repeat distance = "+num2str(TSRepeatDistance)+"\r"
			break
		case "Benedetti-Ciccariello":	// execute if case matches expression
			//Ciccariello Coated Porous media Porods oscillations
			ListOfVariables+=ListOfVariablesBC
			NVAR BCPorodsSpecSurfArea
			NVAR BCLayerScatLengthDens
			NVAR BCCoatingsThickness
			NVAR BCPorodsSpecSurfAreaError
			NVAR BCLayerScatLengthDensError
			NVAR BCCoatingsThicknessError
			FittingResults+="Porod specific surface area [cm2/cm3]= "+num2str(BCPorodsSpecSurfArea)+" +/- "+num2str(BCPorodsSpecSurfAreaError)+"\r"
			FittingResults+="Layer Thickness [A] = "+num2str(BCCoatingsThickness)+" +/- "+num2str(BCCoatingsThicknessError)+"\r"
			FittingResults+="Layer Contrast [10^10 cm^-2]= "+num2str(BCLayerScatLengthDens)+" +/- "+num2str(BCLayerScatLengthDensError)+"\r"
			break
	endswitch
	NVAR UseUnified
	if(UseUnified)
		FittingResults+="\rModeling also included low-q power-law slope\r"
		NVAR UnifPwrlawP
		NVAR UnifPwrlawB
		NVAR UnifPwrlawPError
		NVAR UnifPwrlawBError
		FittingResults+="Low-Q Prefactor = "+num2str(UnifPwrlawB)+" +/- "+num2str(UnifPwrlawBError)+"\r"
		FittingResults+="Low-Q slope = "+num2str(UnifPwrlawP)+" +/- "+num2str(UnifPwrlawPError)+"\r"
	endif
	NVAR SASBackground
	FittingResults+= "SAS background included = "+num2str(SASBackground)+"\r"
	IR1_AppendAnyGraph("IR3S_LogLogDataDisplay")
	IR1_AppendAnyText(FittingResults,0)	
	IR1_AppendAnyText("******************************************\r",0)	
	SetDataFolder OldDf
	SVAR/Z nbl=root:Packages:Irena:ResultsNotebookName	
	DoWindow/F $nbl
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



static Function IR3S_AttachTags(Attach)
	variable Attach		//=1 when attach, 0 when only remeove. 
	
	NVAR HideTagsAlways = root:Packages:Irena:SysSpecModels:HideTagsAlways
	Tag/W=IR3S_LogLogDataDisplay /K/N=DBTag 
	Tag/W=IR3S_LogLogDataDisplay /K/N=CiccBenTag 
	Tag/W=IR3S_LogLogDataDisplay /K/N=TStag 
	Tag/W=IR3S_LogLogDataDisplay /K/N=UFTag 

	if(attach && !HideTagsAlways)	
		SVAR DataFolderName		= root:Packages:Irena:SysSpecModels:DataFolderName
		SVAR IntensityWaveName	= root:Packages:Irena:SysSpecModels:IntensityWaveName
		wave OriginalQvector	= root:Packages:Irena:SysSpecModels:OriginalDataQWave
		SVAR ModelSelected 		= root:Packages:Irena:SysSpecModels:ModelSelected
		WAVE ModelIntensity 	= root:Packages:Irena:SysSpecModels:ModelIntensity
		string LowQText, DBText, CiccBenTxt,TStxt
		variable attachPoint
	
	
	
		strswitch(ModelSelected)	// string switch
			case "Debye-Bueche":	// execute if case matches expression
				NVAR DBPrefactor	= root:Packages:Irena:SysSpecModels:DBPrefactor
				NVAR DBEta			= root:Packages:Irena:SysSpecModels:DBEta
				NVAR DBcorrL		= root:Packages:Irena:SysSpecModels:DBcorrL
				NVAR DBEtaError		= root:Packages:Irena:SysSpecModels:DBEtaError
				NVAR DBcorrLError		= root:Packages:Irena:SysSpecModels:DBcorrLError
				findlevel /Q /P OriginalQvector, (pi/(2* DBcorrL))
				attachPoint= numtype(V_levelX)==0 ? V_levelX : numpnts(OriginalQvector)/2
				DBText = "\Z"+IN2G_LkUpDfltVar("LegendSize")+"Debye-Bueche model results\r"
				DBText += "Sample name: "+DataFolderName+IntensityWaveName+"\r"
				DBText += "Eta \t\t= \t"+num2str(DBEta)+" +/- "+num2str(DBEtaError)+"\r"
				DBText += "Correlation length = \t"+num2str(DBcorrL)+" A"+" +/- "+num2str(DBcorrLError)
				Tag/W=IR3S_LogLogDataDisplay /C/N=DBTag ModelIntensity, attachPoint, DBText
				break
			case "Treubner-Strey":	// execute if case matches expression
				//Teubner-Strey Model
				NVAR TSPrefactor		= root:Packages:Irena:SysSpecModels:TSPrefactor
				NVAR TSCorrelationLength= root:Packages:Irena:SysSpecModels:TSCorrelationLength
				NVAR TSRepeatDistance	= root:Packages:Irena:SysSpecModels:TSRepeatDistance
				NVAR TSPrefactorError	= root:Packages:Irena:SysSpecModels:TSPrefactorError
				NVAR TSCorrLengthError	= root:Packages:Irena:SysSpecModels:TSCorrLengthError
				NVAR TSRepDistError		= root:Packages:Irena:SysSpecModels:TSRepDistError
				findlevel /Q /P OriginalQvector, (pi/ (1.55*TSCorrelationLength))
				attachPoint= numtype(V_levelX)==0 ? V_levelX : numpnts(OriginalQvector)/2
				TStxt = "\Z"+IN2G_LkUpDfltVar("LegendSize")+"Teubner-Strey model results\r"
				TStxt += "Sample name: "+DataFolderName+IntensityWaveName+"\r"
				TStxt += "Correlation length = "+num2str(TSCorrelationLength)+"A"+" +/- "+num2str(TSCorrLengthError)+"\r"
				TStxt += "Repeat distance = "+num2str(TSRepeatDistance)+" A"+" +/- "+num2str(TSRepDistError)
				Tag/W=IR3S_LogLogDataDisplay /C/N=TStag ModelIntensity, attachPoint,TStxt
				break
			case "Benedetti-Ciccariello":	// execute if case matches expression
				//Ciccariello Coated Porous media Porods oscillations
				NVAR BCPorodsSpecSurfArea		= root:Packages:Irena:SysSpecModels:BCPorodsSpecSurfArea
				NVAR BCLayerScatLengthDens		= root:Packages:Irena:SysSpecModels:BCLayerScatLengthDens
				NVAR BCCoatingsThickness		= root:Packages:Irena:SysSpecModels:BCCoatingsThickness
				NVAR BCPorodsSpecSurfAreaError	= root:Packages:Irena:SysSpecModels:BCPorodsSpecSurfAreaError
				NVAR BCLayerScatLengthDensError	= root:Packages:Irena:SysSpecModels:BCLayerScatLengthDensError
				NVAR BCCoatingsThicknessError	= root:Packages:Irena:SysSpecModels:BCCoatingsThicknessError
				attachPoint=(pcsr(A,"IR3S_LogLogDataDisplay") +pcsr(B,"IR3S_LogLogDataDisplay"))/2
				CiccBenTxt = "\Z"+IN2G_LkUpDfltVar("LegendSize")+"Ciccariello & Benedetti model results\r"
				CiccBenTxt += "Sample name: "+DataFolderName+IntensityWaveName+"\r"
				CiccBenTxt += "Porod specific surface area [cm2/cm3] = "+num2str(BCPorodsSpecSurfArea)+" +/- "+num2str(BCPorodsSpecSurfAreaError)+"\r"
				CiccBenTxt += "Layer thickness = "+num2str(BCCoatingsThickness)+" A"+" +/- "+num2str(BCCoatingsThicknessError)+"\r"
				CiccBenTxt += "Scat. Length dens = "+num2str(BCLayerScatLengthDens)+" cm^-2"+" +/- "+num2str(BCLayerScatLengthDensError)
				Tag/W=IR3S_LogLogDataDisplay /C/N=CiccBenTag ModelIntensity, attachPoint,CiccBenTxt
				//CheckDisplayed /W=IR2H_IQ4_Q_PlotGels OriginalIntQ3
				//if(V_Flag)
				//	Tag/W=IR2H_IQ4_Q_PlotGels /C/N=CiccBenTag OriginalIntQ3, attachPoint,CiccBenTxt
				//endif
				//CheckDisplayed /W=IR2H_IQ4_Q_PlotGels OriginalIntQ4
				//if(V_Flag)
				//	Tag/W=IR2H_IQ4_Q_PlotGels /C/N=CiccBenTag OriginalIntQ4, attachPoint,CiccBenTxt
				//endif
				break
		endswitch
		NVAR UseUnified			= root:Packages:Irena:SysSpecModels:UseUnified
		if(UseUnified)
			NVAR UnifRg			= root:Packages:Irena:SysSpecModels:UnifRg
			NVAR UnifG			= root:Packages:Irena:SysSpecModels:UnifG
			NVAR UnifGError		= root:Packages:Irena:SysSpecModels:UnifGError
			NVAR UnifRgError	= root:Packages:Irena:SysSpecModels:UnifRgError
			NVAR UnifPwrlawP	= root:Packages:Irena:SysSpecModels:UnifPwrlawP
			NVAR UnifPwrlawB	= root:Packages:Irena:SysSpecModels:UnifPwrlawB
			NVAR UnifPwrlawPError	= root:Packages:Irena:SysSpecModels:UnifPwrlawPError
			NVAR UnifPwrlawBError	= root:Packages:Irena:SysSpecModels:UnifPwrlawBError
			if((pi/ UnifRg)^2 > OriginalQvector[0])
				findlevel /Q /P OriginalQvector, (pi/(2*UnifRg))
				attachPoint=V_levelX
			else
				attachPoint = 0
			endif
			LowQText = "\Z"+IN2G_LkUpDfltVar("LegendSize")+"Low Q Unified model"+"\r"
			if(UnifRg<1e9 && UnifG>0)
				 LowQText +="Rg = "+num2str(UnifRg)+" +/- "+num2str(UnifRgError)+"\r"
				 LowQText +="Rg prefactor (G) = "+num2str(UnifG)+" +/- "+num2str(UnifGError)+"\r"
			endif
			 LowQText +="Power law Slope (P) = "+num2str(UnifPwrlawP)+" +/- "+num2str(UnifPwrlawPError)+"\r"
			 LowQText +="P Prefactor (B) = "+num2str(UnifPwrlawB)+" +/- "+num2str(UnifPwrlawBError)
			 
			Tag/W=IR3S_LogLogDataDisplay /C/N=UFTag/A=LT ModelIntensity, attachPoint/2,LowQText
		else
			Tag/W=IR3S_LogLogDataDisplay /K/N=UFTag/A=LT
		endif
	endif
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR3S_RecoverParameters()

	NVAR DoNotTryRecoverData = root:Packages:Irena:SysSpecModels:DoNotTryRecoverData
	if(DoNotTryRecoverData)
		return 0
	endif
	SVAR DataFolderName=root:Packages:Irena:SysSpecModels:DataFolderName
	variable DataExists=0,i
	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString
	if (stringmatch(ListOfWaves, "*SysSpecModelInt*" ))
		string ListOfSolutions="Start from current state;"
		For(i=0;i<itemsInList(ListOfWaves);i+=1)
			if (stringmatch(stringFromList(i,ListOfWaves),"*SysSpecModelInt*"))
				tempString=stringFromList(i,ListOfWaves)
				Wave tempwv=$(DataFolderName+tempString)
				tempString=stringByKey("UsersComment",note(tempwv),"=")
				ListOfSolutions+=stringFromList(i,ListOfWaves)+"*  "+tempString+";"
			endif
		endfor
		DataExists=1
		string ReturnSolution=""
		Prompt ReturnSolution, "Select solution to recover", popup,  ListOfSolutions
		DoPrompt "Previous solutions found, select one to recover", ReturnSolution
		if (V_Flag)
			abort
		endif
		if (cmpstr("start from current state",ReturnSolution)==0)
			DataExists=0
		endif
	endif

	if (DataExists==1)
		ReturnSolution=ReturnSolution[0,strsearch(ReturnSolution, "*", 0 )-1]
		Wave/Z OldDistribution=$(DataFolderName+ReturnSolution)
		string Notestr = note(OldDistribution)
		string ListOfWavesForNotes="tempDBModelQvector;tempDBModelIntensity;"
		SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
		string ListOfVariables=""
		SVAR ListOfVariablesBC = root:Packages:Irena:SysSpecModels:ListOfVariablesBC
		SVAR ListOfVariablesTS = root:Packages:Irena:SysSpecModels:ListOfVariablesTS
		SVAR ListOfVariablesDB = root:Packages:Irena:SysSpecModels:ListOfVariablesDB
		SVAR ListOfVariablesUF = root:Packages:Irena:SysSpecModels:ListOfVariablesUF
		SVAR ListOfVariablesBG = root:Packages:Irena:SysSpecModels:ListOfVariablesBG
		SVAR ListOfVariablesMain = root:Packages:Irena:SysSpecModels:ListOfVariablesMain
		ListOfVariables += ListOfVariablesMain+ListOfVariablesUF
		strswitch(ModelSelected)	// string switch
			case "Debye-Bueche":	// execute if case matches expression
				ListOfVariables+=ListOfVariablesDB
				break
			case "Treubner-Strey":	// execute if case matches expression
				//Teubner-Strey Model
				ListOfVariables+=ListOfVariablesTS
				break
			case "Benedetti-Ciccariello":	// execute if case matches expression
				//Ciccariello Coated Porous media Porods oscillations
				ListOfVariables+=ListOfVariablesBC
				break
		endswitch
		string ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
		variable j
		For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
			For(i=0;i<itemsInList(ListOfVariables);i+=1)
				NVAR TempVal = $("root:Packages:Irena:SysSpecModels:"+stringFromList(i,ListOfVariables))
				TempVal = numberByKey("SysSpecModels_"+stringFromList(i,ListOfVariables), Notestr, "=", ";") 
			endfor
		endfor
		For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
			For(i=0;i<itemsInList(ListOfStrings);i+=1)
				SVAR TempStr = $("root:Packages:Irena:SysSpecModels:"+stringFromList(i,ListOfStrings))
				TempStr = stringByKey("SysSpecModels_"+stringFromList(i,ListOfStrings), Notestr, "=", ";") 
			endfor
		endfor
	endif
end
//***************************************************************************************
//***************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
