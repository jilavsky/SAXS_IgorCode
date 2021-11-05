#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=1.02


//*************************************************************************\
//* Copyright (c) 2005 - 2021, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/


//version notes:
//	1.02 add Hermans, HybridHermans, and Unified Born Green models. https://doi.org/10.1016/j.polymer.2021.124281
//	1.01 add handling of USAXS M_... waves 
//	1.0 Original release, 1/2/2021


//this is now System Specific Models, replacement for Analytical models. 
// SysSpecModels = short name of package
// IR3S = working prefix, short (e.g., IR3DM) 
// add IR3S_MainCheckVersion to Irena after compile hook function correctly
//To add model in System Specific Models, follow these instructions:
//	add model parameters in  
//IR3S_InitSysSpecModels()
//IR3S_SetInitialValues()
//IR3S_SysSpecModelsPanelFnct()
//IR3S_AutoRecalculateModelData(0)
//			IR3S_CalculateModel(OriginalIntensity,OriginalQvector,0)


constant IR3SversionNumber = 1.02			//SysSpecModels panel version number
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
//	ListOfVariablesUF="UseUnified;"

//	WaveParamsValues={"Value","Fit?","LowLimit","HighLimit","FitError"}

//	//Unified fit, 4 paramegers, G, Rg, P, B + 2 not fitted parameters, UnifRgCO;LinkUnifRgCO
//	Wave UnifiedPar = root:Packages:Irena:SysSpecModels:UnifiedPar
//	UnifiedParNames = {"G","Rg","B","P","UnifRgCO","LinkUnifRgCO"}
//
//
//	//Teubner-Strey, 4 paramegers + 2 calculated parameters (never fitted)
//	Wave TSPar = root:Packages:Irena:SysSpecModels:TSPar
//	TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}
//
//
//	//Debye-Bueche, 3 paramegers + 1 calculated parameters (never fitted)
//	Wave DBPar = root:Packages:Irena:SysSpecModels:DBPar
//	DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
//
//
//	//Benedetti-Ciccariello 3 paramegers + 2 calculated parameters (never fitted)
//	Wave BCPar = root:Packages:Irena:SysSpecModels:BCPar
//	BCParNames = {"PorodsSpecSurfArea", "CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}
//
// 	HermansPar
//	HermansPar			//Hermans 4 parameters
//	HermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue"}
//
//	Hybrid Hermans model. https://doi.org/10.1016/j.polymer.2021.124281
//	Wave HybHermansPar 	= 	root:Packages:Irena:SysSpecModels:HybHermansPar
//	HybHermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue","G2","Rg2","LinkRGCO"}
//
//	Unified Born Green model. https://doi.org/10.1016/j.polymer.2021.124281, Formula 8
//	Wave UBGPar 	= 	root:Packages:Irena:SysSpecModels:UBGPar
//	UBGParNames = {"Rg1","B1","pack","CorDist","StackIrreg","kI"}



////************************************************************************************************************
////************************************************************************************************************
Function IR3S_SysSpecModelsPanelFnct()
	IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(2.25,43.25,560,815) as "System Specific Models"
	DoWIndow/C IR3S_SysSpecModelsPanel
	TitleBox MainTitle title="System Specific Models - Dev!",pos={140,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
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
	SetVariable DataFolderName,noproc,title=" ",pos={260,145},size={260,20},frame=0, fstyle=1,fSize=11,valueColor=(0,0,65535)
	Setvariable DataFolderName, variable=root:Packages:Irena:SysSpecModels:DataFolderName, noedit=1

	Button SelectAll,pos={187,680},size={80,15}, proc=IR3S_ButtonProc,title="SelectAll", help={"Select All data in Listbox"}
	Button GetHelp,pos={430,50},size={80,15},fColor=(65535,32768,32768), proc=IR3S_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	PopupMenu ModelSelected,pos={280,165},size={200,20},fStyle=2,proc=IR3S_PopMenuProc,title="Function : "
	SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
	PopupMenu ModelSelected,mode=1,popvalue=ModelSelected,value= #"root:Packages:Irena:SysSpecModels:ListOfModels" 

	//	here will be model variables/controls... These will be attached to specific variables later... 
	SetVariable ModelVarPar1,pos={340,190},size={110,17},title="ModelVarPar1",proc=IR3S_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar1"}
	CheckBox FitModelVarPar1,pos={470,190},size={79,14},proc=IR3S_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar2,pos={340,210},size={110,17},title="ModelVarPar2",proc=IR3S_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar2"}
	CheckBox FitModelVarPar2,pos={470,210},size={79,14},proc=IR3S_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar3,pos={340,230},size={110,17},title="ModelVarPar3",proc=IR3S_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar3"}
	CheckBox FitModelVarPar3,pos={470,230},size={79,14},proc=IR3S_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar4,pos={340,250},size={110,17},title="ModelVarPar4",proc=IR3S_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar4"}
	CheckBox FitModelVarPar4,pos={470,250},size={79,14},proc=IR3S_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar5,pos={340,270},size={110,17},title="ModelVarPar5",proc=IR3S_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar5"}
	CheckBox FitModelVarPar5,pos={470,270},size={79,14},proc=IR3S_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar6,pos={340,290},size={110,17},title="ModelVarPar6",proc=IR3S_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar6"}
	CheckBox FitModelVarPar6,pos={470,290},size={79,14},proc=IR3S_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar7,pos={340,310},size={110,17},title="ModelVarPar7",proc=IR3S_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar7"}
	CheckBox FitModelVarPar7,pos={470,310},size={79,14},proc=IR3S_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1


	SetVariable ModelVarPar1LL,pos={260,335},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var1"}
	SetVariable ModelVarPar1UL,pos={340,335},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var1"}
	SetVariable ModelVarPar2LL,pos={260,355},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var2"}
	SetVariable ModelVarPar2UL,pos={340,355},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var2"}
	SetVariable ModelVarPar3LL,pos={260,375},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var3"}
	SetVariable ModelVarPar3UL,pos={340,375},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var3"}
	SetVariable ModelVarPar4LL,pos={260,395},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var4"}
	SetVariable ModelVarPar4UL,pos={340,395},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var4"}
	SetVariable ModelVarPar5LL,pos={260,415},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var5"}
	SetVariable ModelVarPar5UL,pos={340,415},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var5"}
	SetVariable ModelVarPar6LL,pos={260,435},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var6"}
	SetVariable ModelVarPar6UL,pos={340,435},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var6"}
	SetVariable ModelVarPar7LL,pos={260,455},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var7"}
	SetVariable ModelVarPar7UL,pos={340,455},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var7"}

	Button ModelButton1,pos={470,345},size={80,20}, proc=IR3S_ButtonProc, title="Button1", help={""}, disable=0
	Button ModelButton2,pos={470,370},size={80,20}, proc=IR3S_ButtonProc, title="Button2", help={""}, disable=0
	Button ModelButton3,pos={470,395},size={80,20}, proc=IR3S_ButtonProc, title="Button3", help={""}, disable=0


	//here is Unified level + background. 
	CheckBox UseUnified,pos={270,480},size={79,14},proc=IR3S_MainPanelCheckProc,title="Add Unified?"
	CheckBox UseUnified,variable= root:Packages:Irena:SysSpecModels:UseUnified, help={"Add one level unified level to model data?"}
	NVAR UseUnified = root:Packages:Irena:SysSpecModels:UseUnified
	Button EstimateUF,pos={380,480},size={100,15}, proc=IR3S_ButtonProc
	//	UnifiedNames = {"G","Rg","B","P","RgCO", "LinkRgCO"}
	Button EstimateUF, title="Estimate slope", help={"Fit power law to estimate slope of low q region"}, disable=!(UseUnified)
	SetVariable UnifG,pos={270,500},size={110,17},title="G       ",proc=IR3S_SetVarProc, disable=!(UseUnified), bodywidth=70
	SetVariable UnifG,limits={0,inf,1},value= root:Packages:Irena:SysSpecModels:UnifiedPar[0][0], help={"G for Unified level Rg"}
	SetVariable UnifRg,pos={270,520},size={110,17},title="Rg     ",proc=IR3S_SetVarProc, disable=!(UseUnified), bodywidth=70
	SetVariable UnifRg,limits={0,inf,1},value= root:Packages:Irena:SysSpecModels:UnifiedPar[1][0], help={"Rg for Unified level"}	
	SetVariable UnifPwrlawB,pos={270,540},size={110,17},title="B       ",proc=IR3S_SetVarProc, disable=!(UseUnified), bodywidth=70
	SetVariable UnifPwrlawB,limits={0,inf,1},value= root:Packages:Irena:SysSpecModels:UnifiedPar[2][0], help={"Prefactor for low-Q power law slope"}
	SetVariable UnifPwrlawP,pos={270,560},size={110,17},title="P       ",proc=IR3S_SetVarProc, disable=!(UseUnified), bodywidth=70
	SetVariable UnifPwrlawP,limits={0,5,0.1},value= root:Packages:Irena:SysSpecModels:UnifiedPar[3][0], help={"Power law slope of low-Q region"}
	SetVariable UnifRgCO,pos={270,580},size={110,17},title="RgCO  ",proc=IR3S_SetVarProc, disable=!(UseUnified), bodywidth=70
	SetVariable UnifRgCO,limits={0,inf,10},value= root:Packages:Irena:SysSpecModels:UnifiedPar[4][0], help={"Rg cutt off for low-Q region"}
	SetVariable SASBackground,pos={270,610},size={150,16},proc=IR3S_SetVarProc,title="SAS Background", help={"Background of SAS"}, bodywidth=70
	SetVariable SASBackground,limits={-inf,Inf,1},variable= root:Packages:Irena:SysSpecModels:SASBackground

	Wave UnifiedPar = root:Packages:Irena:SysSpecModels:UnifiedPar
	//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
	CheckBox FitUnifG,pos={400,500},size={79,14},proc=IR3S_FitCheckProc,title="Fit?", value= UnifiedPar[0][1], help={"Fit this parameter?"}, disable=!(UseUnified)
	CheckBox FitUnifRg,pos={400,520},size={79,14},proc=IR3S_FitCheckProc,title="Fit?", value= UnifiedPar[1][1], help={"Fit this parameter?"}, disable=!(UseUnified)
	CheckBox FitUnifPwrlawB,pos={400,540},size={79,14},proc=IR3S_FitCheckProc,title="Fit?", value= UnifiedPar[2][1], help={"Fit this parameter?"}, disable=!(UseUnified)
	CheckBox FitUnifPwrlawP,pos={400,560},size={79,14},proc=IR3S_FitCheckProc,title="Fit?", value= UnifiedPar[3][1], help={"Fit this parameter?"}, disable=!(UseUnified)
	CheckBox LinkUnifRgCO,pos={400,580},size={79,14},proc=IR3S_FitCheckProc,title="Link?", value= UnifiedPar[4][1], help={"Link this RgCO to model feature size?"}, disable=!(UseUnified)
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
	NVAR UseUnified = root:Packages:Irena:SysSpecModels:UseUnified
	Wave DBPar = root:Packages:Irena:SysSpecModels:DBPar
	//DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
	Wave TSPar = root:Packages:Irena:SysSpecModels:TSPar
	//TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}
	Wave BCPar = root:Packages:Irena:SysSpecModels:BCPar
	//BCParNames = {"PorodsSpecSurfArea", "CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}
	Wave HermansPar 	= 	root:Packages:Irena:SysSpecModels:HermansPar
	//HermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue"}
	Wave HybHermansPar 	= 	root:Packages:Irena:SysSpecModels:HybHermansPar
	//HybHermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue","G2","Rg2"}
	Wave UBGPar 	= 	root:Packages:Irena:SysSpecModels:UBGPar
	//UBGParNames = {"Rg1","B1","pack","CorrDist","StackIrreg","kI"}
	DoWindow IR3S_SysSpecModelsPanel
	if(V_Flag)
		//force useUnfiied when using Hybrid Hermans model
		if(StringMatch(ModelSelected, "Hybrid Hermans" ))
			UseUnified = 1
		endif
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
				//DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
				//NVAR DBPrefactor = root:Packages:Irena:SysSpecModels:DBPrefactor
				//NVAR DBEta=root:Packages:Irena:SysSpecModels:DBEta
				//NVAR DBcorrL=root:Packages:Irena:SysSpecModels:DBcorrL
				//NVAR DBWavelength=root:Packages:Irena:SysSpecModels:DBWavelength
				SetVariable ModelVarPar1 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBPar[0][0] ,title="Scale         ", disable=1, limits={0.01,inf,IR3SSetVariableStepRatio*DBPar[0][0]}, help={"Scale for Debye-Bueche model"}
				SetVariable ModelVarPar2 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBPar[2][0] ,title="Eta           ", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*DBPar[2][0]}, help={"ETA for Debye-Bueche model"}
				SetVariable ModelVarPar3 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBPar[1][0] ,title="Corr Length", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*DBPar[1][0]}, help={"Correlation length for Debye-Bueche model"}
				SetVariable ModelVarPar4 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBPar[3][0] ,title="Wavelength", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*DBPar[3][0]}, help={"Wavelength for Debye-Bueche model"}
				SetVariable ModelVarPar5 win=IR3S_SysSpecModelsPanel, disable=1, noedit=0
				SetVariable ModelVarPar6 win=IR3S_SysSpecModelsPanel, disable=1, noedit=0
				SetVariable ModelVarPar7 win=IR3S_SysSpecModelsPanel, disable=1, noedit=0

				CheckBox FitModelVarPar1 win=IR3S_SysSpecModelsPanel,value= DBPar[0][1], disable=1 	//variable= root:Packages:Irena:SysSpecModels:FitDBPrefactor, disable=1
				CheckBox FitModelVarPar2 win=IR3S_SysSpecModelsPanel,value= DBPar[2][1], disable=0
				CheckBox FitModelVarPar3 win=IR3S_SysSpecModelsPanel,value= DBPar[1][1], disable=0
				CheckBox FitModelVarPar4 win=IR3S_SysSpecModelsPanel,value= DBPar[3][1], disable=1
				CheckBox FitModelVarPar5 win=IR3S_SysSpecModelsPanel,disable=1
				CheckBox FitModelVarPar6 win=IR3S_SysSpecModelsPanel,disable=1
				CheckBox FitModelVarPar7 win=IR3S_SysSpecModelsPanel,disable=1

				Button ModelButton1 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1
				Button ModelButton2 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1
				Button ModelButton3 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1

				SetVariable ModelVarPar1LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBPar[0][2] ,title=" ", disable=1, limits={0.01,inf,0}, help={"Lower limit for Scale for Debye-Bueche model"}
				SetVariable ModelVarPar1UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBPar[0][3] ,title="< Scale < ", disable=1, limits={0.01,inf,0}, help={"High limit for Scale for Debye-Bueche model"}
				SetVariable ModelVarPar2LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBPar[2][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for ETA for Debye-Bueche model"}
				SetVariable ModelVarPar2UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBPar[2][3] ,title="< Eta < ", disable=0, limits={0.01,inf,0}, help={"High limit for ETA for Debye-Bueche model"}
				SetVariable ModelVarPar3LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBPar[1][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Correlation length for Debye-Bueche model"}
				SetVariable ModelVarPar3UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:DBPar[1][3] ,title="< CorL < ", disable=0, limits={0.01,inf,0}, help={"High limit for Correlation length for Debye-Bueche model"}
				SetVariable ModelVarPar4LL win=IR3S_SysSpecModelsPanel,disable=1
				SetVariable ModelVarPar4UL win=IR3S_SysSpecModelsPanel,disable=1
				SetVariable ModelVarPar5LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar5UL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar6LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar6UL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar7LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar7UL win=IR3S_SysSpecModelsPanel, disable=1
				break		// exit from switch
			case "Treubner-Strey":	// execute if case matches expression
				//Teubner-Strey, 4 paramegers + 2 calculated parameters (never fitted)
				//TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}
				//NVAR TSPrefactor 	= 	root:Packages:Irena:SysSpecModels:TSPrefactor
				//NVAR TSAvalue		=	root:Packages:Irena:SysSpecModels:TSAvalue
				//NVAR TSC1Value		=	root:Packages:Irena:SysSpecModels:TSC1Value
				//NVAR TSC2Value		=	root:Packages:Irena:SysSpecModels:TSC2Value
				//NVAR TSCorrelationLength	=	root:Packages:Irena:SysSpecModels:TSCorrelationLength
				//NVAR TSRepeatDistance		=	root:Packages:Irena:SysSpecModels:TSRepeatDistance
				SetVariable ModelVarPar1 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPar[0][0] ,title="Scale         ", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*TSPar[0][0]}, help={"Scale for Treubner-Strey model"}
				SetVariable ModelVarPar2 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPar[1][0] ,title="A par         ", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*TSPar[1][0]}, help={"A parameter for Treubner-Strey model"}
				SetVariable ModelVarPar3 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPar[2][0] ,title="TC1 par       ", disable=0, limits={-inf,inf,IR3SSetVariableStepRatio*TSPar[2][0]}, help={"TC1 parameter for Treubner-Strey model"}
				SetVariable ModelVarPar4 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPar[3][0] ,title="TC2 par       ", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*TSPar[3][0]}, help={"TC2 parameter for Treubner-Strey model"}
				SetVariable ModelVarPar5 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPar[4][0] ,title="Corr length  ", disable=0, noedit=1, limits={-INF,inf,0}, help={"Calculated Correlation Length parameter for Treubner-Strey model"}
				SetVariable ModelVarPar6 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPar[5][0] ,title="Repeat Dist.  ", disable=0,noedit=1, limits={-inf,inf,0}, help={"Calculated Repeat distance for Treubner-Strey model"}
				SetVariable ModelVarPar7 win=IR3S_SysSpecModelsPanel, disable=1, noedit=0

				CheckBox FitModelVarPar1 win=IR3S_SysSpecModelsPanel,value= TSPar[0][1], disable=0
				CheckBox FitModelVarPar2 win=IR3S_SysSpecModelsPanel,value= TSPar[1][1], disable=0
				CheckBox FitModelVarPar3 win=IR3S_SysSpecModelsPanel,value= TSPar[2][1], disable=0
				CheckBox FitModelVarPar4 win=IR3S_SysSpecModelsPanel,value= TSPar[3][1], disable=0
				CheckBox FitModelVarPar5 win=IR3S_SysSpecModelsPanel, disable=1
				CheckBox FitModelVarPar6 win=IR3S_SysSpecModelsPanel, disable=1
				CheckBox FitModelVarPar7 win=IR3S_SysSpecModelsPanel,disable=1
				
				Button ModelButton1 win=IR3S_SysSpecModelsPanel, title="Estimate corrL", help={"Estimate Correlation length"}, disable=1
				Button ModelButton2 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1
				Button ModelButton3 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1

				SetVariable ModelVarPar1LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPar[0][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Scale for Treubner-Strey model"}
				SetVariable ModelVarPar1UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPar[0][3] ,title="< Scale < ", disable=0, limits={0.01,inf,0}, help={"High limit for Scale for Treubner-Strey model"}
				SetVariable ModelVarPar2LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPar[1][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for A for Treubner-Strey model"}
				SetVariable ModelVarPar2UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPar[1][3] ,title="< A par < ", disable=0, limits={0.01,inf,0}, help={"High limit for A for Treubner-Strey model"}
				SetVariable ModelVarPar3LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPar[2][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for TC1 for Treubner-Strey model"}
				SetVariable ModelVarPar3UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPar[2][3] ,title="< TC1 < ", disable=0, limits={0.01,inf,0}, help={"High limit for TC1 for Treubner-Strey model"}
				SetVariable ModelVarPar4LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPar[3][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for TC2 for Treubner-Strey model"}
				SetVariable ModelVarPar4UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:TSPar[3][3] ,title="< TC2 < ", disable=0, limits={0.01,inf,0}, help={"High limit for TC2 for Treubner-Strey model"}
				SetVariable ModelVarPar5LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar5UL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar6LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar6UL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar7LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar7UL win=IR3S_SysSpecModelsPanel, disable=1
				break
			case "Benedetti-Ciccariello":	// execute if case matches expression
				//Benedetti-Ciccariello 3 paramegers + 2 calculated parameters (never fitted)
				//BCParNames = {"PorodsSpecSurfArea", "CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}
				//NVAR BCPorodsSpecSurfArea 	= 	root:Packages:Irena:SysSpecModels:BCPorodsSpecSurfArea
				//NVAR BCSolidScatLengthDensity 	= 	root:Packages:Irena:SysSpecModels:BCSolidScatLengthDensity
				//NVAR BCVoidScatLengthDensity 	= 	root:Packages:Irena:SysSpecModels:BCVoidScatLengthDensity
				//NVAR BCLayerScatLengthDens 	= 	root:Packages:Irena:SysSpecModels:BCLayerScatLengthDens
				//NVAR BCCoatingsThickness 		= 	root:Packages:Irena:SysSpecModels:BCCoatingsThickness
				SetVariable ModelVarPar1 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[0][0] ,title="Porod Surface     ", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*BCPar[0][0]}, help={"Porod Surface [cm2/cm3] for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar2 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[3][0] ,title="Solid SLD [10^10]", disable=0, limits={-inf,inf,IR3SSetVariableStepRatio*BCPar[3][0]}, help={"Solid SLD * 10^10 for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar3 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[4][0] ,title="Void/Sol SLD     ", disable=0, limits={-inf,inf,BCPar[4][0]*IR3SSetVariableStepRatio}, help={"Void or solvent SLD parameter for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar4 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[2][0] ,title="Layer SLD [10^10]", disable=0, limits={-inf,inf,IR3SSetVariableStepRatio*BCPar[2][0]}, help={"Layer SLD for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar5 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[1][0] ,title="Layer thick [A]   ", disable=0, noedit=0, limits={1,inf,BCPar[1][0]*IR3SSetVariableStepRatio}, help={"Thickness of the layer for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar6 win=IR3S_SysSpecModelsPanel,title="", disable=1, noedit=0
				SetVariable ModelVarPar7 win=IR3S_SysSpecModelsPanel, disable=1, noedit=0

				CheckBox FitModelVarPar1 win=IR3S_SysSpecModelsPanel,value= BCPar[0][1], disable=0
				CheckBox FitModelVarPar2 win=IR3S_SysSpecModelsPanel,value= BCPar[3][1], disable=1
				CheckBox FitModelVarPar3 win=IR3S_SysSpecModelsPanel,value= BCPar[4][1], disable=1
				CheckBox FitModelVarPar4 win=IR3S_SysSpecModelsPanel,value= BCPar[2][1], disable=0
				CheckBox FitModelVarPar5 win=IR3S_SysSpecModelsPanel,value= BCPar[1][1], disable=0
				CheckBox FitModelVarPar6 win=IR3S_SysSpecModelsPanel, disable=1
				CheckBox FitModelVarPar7 win=IR3S_SysSpecModelsPanel,disable=1

				Button ModelButton1 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1
				Button ModelButton2 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1
				Button ModelButton3 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1

				SetVariable ModelVarPar1LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[0][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Porod Surface Benedetti-Ciccariello model"}
				SetVariable ModelVarPar1UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[0][3] ,title="< Por S < ", disable=0, limits={0.01,inf,0}, help={"High limit for Porod Surface for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar2LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[3][2] ,title=" ", disable=1, limits={0.01,inf,0}, help={"Lower limit for Solid SLD for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar2UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[3][3] ,title="< S SLD < ", disable=1, limits={0.01,inf,0}, help={"High limit for Solid  SLD for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar3LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[4][2] ,title=" ", disable=1, limits={0.01,inf,0}, help={"Lower limit for Void/Solvent for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar3UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[4][3] ,title="< V SLD < ", disable=1, limits={0.01,inf,0}, help={"High limit for Void/Solvent for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar4LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[2][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Layer SLD for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar4UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[2][3] ,title="< L SLD < ", disable=0, limits={0.01,inf,0}, help={"High limit for Layer SLD for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar5LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[1][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Layer thickness for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar5UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:BCPar[1][3] ,title="< Thick < ", disable=0, limits={0.01,inf,0}, help={"High limit for Layer thickness for Benedetti-Ciccariello model"}
				SetVariable ModelVarPar6LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar6UL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar7LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar7UL win=IR3S_SysSpecModelsPanel, disable=1
				break
			case "Hermans":	// execute if case matches expression
				//	HermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue"}
				//	WaveParamsValues={"Value","LowLimit","HighLimit","FitError"}
				// 	variables HermansAmThFit, HermansAmSigFit, HermansLamThFit, HermansLamSigFit, HermansBvalFit 

				SetVariable ModelVarPar1 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[0][0] ,title="Amorphous Thickness ", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*HermansPar[0][0]}, help={"Thickness of amorphous phase [A]"}
				SetVariable ModelVarPar2 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[1][0] ,title="Am. Thick. Sigma    ", disable=0, limits={-inf,inf,IR3SSetVariableStepRatio*HermansPar[1][0]}, help={"Sigma for amorphous thickness"}
				SetVariable ModelVarPar3 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[2][0] ,title="Lamellae Thickness  ", disable=0, limits={-inf,inf,IR3SSetVariableStepRatio*HermansPar[2][0]}, help={"Thickness of cryst. Lamellae [A]"}
				SetVariable ModelVarPar4 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[3][0] ,title="Lam. Thick. Sigma   ", disable=0, limits={-inf,inf,IR3SSetVariableStepRatio*HermansPar[3][0]}, help={"Sigma for cryst. Lamellae thickness"}
				SetVariable ModelVarPar5 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[4][0] ,title="B value             ", disable=0, noedit=0, limits={1,inf,IR3SSetVariableStepRatio*HermansPar[4][0]}, help={"B value "}
				SetVariable ModelVarPar6 win=IR3S_SysSpecModelsPanel, disable=1, noedit=0
				SetVariable ModelVarPar7 win=IR3S_SysSpecModelsPanel, disable=1, noedit=0

				CheckBox FitModelVarPar1 win=IR3S_SysSpecModelsPanel,value= HermansPar[0][1], disable=0
				CheckBox FitModelVarPar2 win=IR3S_SysSpecModelsPanel,value= HermansPar[0][1], disable=0
				CheckBox FitModelVarPar3 win=IR3S_SysSpecModelsPanel,value= HermansPar[0][1], disable=0
				CheckBox FitModelVarPar4 win=IR3S_SysSpecModelsPanel,value= HermansPar[0][1], disable=0
				CheckBox FitModelVarPar5 win=IR3S_SysSpecModelsPanel,value= HermansPar[0][1], disable=0
				CheckBox FitModelVarPar6 win=IR3S_SysSpecModelsPanel,disable=1
				CheckBox FitModelVarPar7 win=IR3S_SysSpecModelsPanel,disable=1

				Button ModelButton1 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1
				Button ModelButton2 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1
				Button ModelButton3 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1

				SetVariable ModelVarPar1LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[0][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Thickness of amorphous phase"}
				SetVariable ModelVarPar1UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[0][3] ,title="< Am Th < ", disable=0, limits={0.01,inf,0}, help={"High limit for Thickness of amorphous phase"}
				SetVariable ModelVarPar2LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[1][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Sigma for amorphous thickness"}
				SetVariable ModelVarPar2UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[1][3] ,title="< Sigma < ", disable=0, limits={0.01,inf,0}, help={"High limit Sigma for amorphous thickness"}
				SetVariable ModelVarPar3LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[2][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Thickness of cryst. Lamellae"}
				SetVariable ModelVarPar3UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[2][3] ,title="< Lam Th < ", disable=0, limits={0.01,inf,0}, help={"High limit for Thickness of cryst. Lamellae"}
				SetVariable ModelVarPar4LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[3][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Sigma for cryst. Lamellae thickness"}
				SetVariable ModelVarPar4UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[3][3] ,title="< Sigma < ", disable=0, limits={0.01,inf,0}, help={"High limit for Sigma for cryst. Lamellae thickness"}
				SetVariable ModelVarPar5LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[4][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for B value"}
				SetVariable ModelVarPar5UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HermansPar[4][3] ,title="< B value < ", disable=0, limits={0.01,inf,0}, help={"High limit for B value"}
				SetVariable ModelVarPar6LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar6UL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar7LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar7UL win=IR3S_SysSpecModelsPanel, disable=1
				break
				
			case "Hybrid Hermans":	// execute if case matches expression
				//	HybHermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue","G2","Rg2","LinkRGCO"}
				SetVariable ModelVarPar1 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[0][0] ,title="Amorphous Thickness ", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*HybHermansPar[0][0]}, help={"Thickness of amorphous phase [A]"}
				SetVariable ModelVarPar2 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[1][0] ,title="Am. Thick. Sigma    ", disable=0, limits={-inf,inf,IR3SSetVariableStepRatio*HybHermansPar[1][0]}, help={"Sigma for amorphous thickness"}
				SetVariable ModelVarPar3 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[2][0] ,title="Lamellae Thickness  ", disable=0, limits={-inf,inf,IR3SSetVariableStepRatio*HybHermansPar[2][0]}, help={"Thickness of cryst. Lamellae [A]"}
				SetVariable ModelVarPar4 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[3][0] ,title="Lam. Thick. Sigma   ", disable=0, limits={-inf,inf,IR3SSetVariableStepRatio*HybHermansPar[3][0]}, help={"Sigma for cryst. Lamellae thickness"}
				SetVariable ModelVarPar5 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[4][0] ,title="B value             ", disable=0, noedit=0, limits={1,inf,IR3SSetVariableStepRatio*HybHermansPar[4][0]}, help={"B value "}
				SetVariable ModelVarPar6 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[5][0] ,title="G2 value            ", disable=0, noedit=0, limits={1,inf,IR3SSetVariableStepRatio*HybHermansPar[5][0]}, help={"B value "}
				SetVariable ModelVarPar7 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[6][0] ,title="Rg2 value           ", disable=0, noedit=0, limits={1,inf,IR3SSetVariableStepRatio*HybHermansPar[6][0]}, help={"B value "}

				CheckBox FitModelVarPar1 win=IR3S_SysSpecModelsPanel,value= HybHermansPar[0][1], disable=0
				CheckBox FitModelVarPar2 win=IR3S_SysSpecModelsPanel,value= HybHermansPar[1][1], disable=0
				CheckBox FitModelVarPar3 win=IR3S_SysSpecModelsPanel,value= HybHermansPar[2][1], disable=0
				CheckBox FitModelVarPar4 win=IR3S_SysSpecModelsPanel,value= HybHermansPar[3][1], disable=0
				CheckBox FitModelVarPar5 win=IR3S_SysSpecModelsPanel,value= HybHermansPar[4][1], disable=0
				CheckBox FitModelVarPar6 win=IR3S_SysSpecModelsPanel,value= HybHermansPar[5][1], disable=0
				CheckBox FitModelVarPar7 win=IR3S_SysSpecModelsPanel,value= HybHermansPar[6][1], disable=0

				Button ModelButton1 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1
				Button ModelButton2 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1
				Button ModelButton3 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1

				SetVariable ModelVarPar1LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[0][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Thickness of amorphous phase"}
				SetVariable ModelVarPar1UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[0][3] ,title="< Am Th < ", disable=0, limits={0.01,inf,0}, help={"High limit for Thickness of amorphous phase"}
				SetVariable ModelVarPar2LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[1][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Sigma for amorphous thickness"}
				SetVariable ModelVarPar2UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[1][3] ,title="< Sigma < ", disable=0, limits={0.01,inf,0}, help={"High limit Sigma for amorphous thickness"}
				SetVariable ModelVarPar3LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[2][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Thickness of cryst. Lamellae"}
				SetVariable ModelVarPar3UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[2][3] ,title="< Lam Th < ", disable=0, limits={0.01,inf,0}, help={"High limit for Thickness of cryst. Lamellae"}
				SetVariable ModelVarPar4LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[3][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Sigma for cryst. Lamellae thickness"}
				SetVariable ModelVarPar4UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[3][3] ,title="< Sigma < ", disable=0, limits={0.01,inf,0}, help={"High limit for Sigma for cryst. Lamellae thickness"}
				SetVariable ModelVarPar5LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[4][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for B value"}
				SetVariable ModelVarPar5UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[4][3] ,title="< B value < ", disable=0, limits={0.01,inf,0}, help={"High limit for B value"}
				SetVariable ModelVarPar6LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[5][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for G2 value"}
				SetVariable ModelVarPar6UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[5][3] ,title="< G2 value < ", disable=0, limits={0.01,inf,0}, help={"High limit for G2 value"}
				SetVariable ModelVarPar7LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[6][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Rg2 value"}
				SetVariable ModelVarPar7UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:HybHermansPar[6][3] ,title="< Rg2 value < ", disable=0, limits={0.01,inf,0}, help={"High limit for Tg2 value"}
				break
				
			case "Unified Born Green":	// execute if case matches expression
				//UBGParNames = {"Rg1","B1","pack","CorDist","StackIrreg","kI"}

				SetVariable ModelVarPar1 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[0][0] ,title="Rg1    [A]", disable=0, limits={0.01,inf,IR3SSetVariableStepRatio*UBGPar[0][0]}, help={"Rg1 [A]"}
				SetVariable ModelVarPar2 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[1][0] ,title="B1 [cm\\S-1\\MA\\S-4\\M]", disable=0, limits={-inf,inf,IR3SSetVariableStepRatio*UBGPar[1][0]}, help={"B1"}
				SetVariable ModelVarPar3 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[2][0] ,title="Pack     ", disable=0, limits={-inf,inf,IR3SSetVariableStepRatio*UBGPar[2][0]}, help={"Pack value"}
				SetVariable ModelVarPar4 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[3][0] ,title="Corr Dist ξ [A]", disable=0, limits={-inf,inf,IR3SSetVariableStepRatio*UBGPar[3][0]}, help={"Mesh (see paper)"}
				SetVariable ModelVarPar5 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[4][0] ,title="Stack Irreg δ ", disable=0, noedit=0, limits={1,inf,IR3SSetVariableStepRatio*UBGPar[4][0]}, help={"Del (see paper) "}
				SetVariable ModelVarPar6 win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[5][0] ,title="k\\BI             ", disable=0, noedit=0, limits={1,inf,IR3SSetVariableStepRatio*UBGPar[5][0]}, help={"kI (see paper) "}
				SetVariable ModelVarPar7 win=IR3S_SysSpecModelsPanel, disable=1, noedit=0

				CheckBox FitModelVarPar1 win=IR3S_SysSpecModelsPanel,value= UBGPar[0][1], disable=0
				CheckBox FitModelVarPar2 win=IR3S_SysSpecModelsPanel,value= UBGPar[1][1], disable=0
				CheckBox FitModelVarPar3 win=IR3S_SysSpecModelsPanel,value= UBGPar[2][1], disable=0
				CheckBox FitModelVarPar4 win=IR3S_SysSpecModelsPanel,value= UBGPar[3][1], disable=0
				CheckBox FitModelVarPar5 win=IR3S_SysSpecModelsPanel,value= UBGPar[4][1], disable=0
				CheckBox FitModelVarPar6 win=IR3S_SysSpecModelsPanel,value= UBGPar[5][1], disable=0
				CheckBox FitModelVarPar7 win=IR3S_SysSpecModelsPanel,disable=1

				Button ModelButton1 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1
				Button ModelButton2 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1
				Button ModelButton3 win=IR3S_SysSpecModelsPanel, title="", help={""}, disable=1

				SetVariable ModelVarPar1LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[0][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Rg1"}
				SetVariable ModelVarPar1UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[0][3] ,title="< Rg1 <  ", disable=0, limits={0.01,inf,0}, help={"High limit for Rg1"}
				SetVariable ModelVarPar2LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[1][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for G1"}
				SetVariable ModelVarPar2UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[1][3] ,title="< B1 <   ", disable=0, limits={0.01,inf,0}, help={"High limit G1"}
				SetVariable ModelVarPar3LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[2][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Pack"}
				SetVariable ModelVarPar3UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[2][3] ,title="< Pack <  ", disable=0, limits={0.01,inf,0}, help={"High limit for Pack"}
				SetVariable ModelVarPar4LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[3][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Mesh"}
				SetVariable ModelVarPar4UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[3][3] ,title=" < ξ <    ", disable=0, limits={0.01,inf,0}, help={"High limit for Sigma for Mesh"}
				SetVariable ModelVarPar5LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[4][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Del"}
				SetVariable ModelVarPar5UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[4][3] ,title="< δ <    ", disable=0, limits={0.01,inf,0}, help={"High limit for Del"}
				SetVariable ModelVarPar6LL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[4][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for kI"}
				SetVariable ModelVarPar6UL win=IR3S_SysSpecModelsPanel,value=root:Packages:Irena:SysSpecModels:UBGPar[4][3] ,title="< k\\BI \\M<    ", disable=0, limits={0.01,inf,0}, help={"High limit for kI"}
				SetVariable ModelVarPar7LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar7UL win=IR3S_SysSpecModelsPanel, disable=1
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
				CheckBox FitModelVarPar7 win=IR3S_SysSpecModelsPanel,disable=1
				SetVariable ModelVarPar7 win=IR3S_SysSpecModelsPanel, disable=1, noedit=0
				Button ModelButton1 win=IR3S_SysSpecModelsPanel, disable=1
				Button ModelButton2 win=IR3S_SysSpecModelsPanel, disable=1
				Button ModelButton3 win=IR3S_SysSpecModelsPanel, disable=1
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
				SetVariable ModelVarPar7LL win=IR3S_SysSpecModelsPanel, disable=1
				SetVariable ModelVarPar7UL win=IR3S_SysSpecModelsPanel, disable=1
				
				
		endswitch
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3S_FitCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
			//	WaveParamsValues={"Value","Fit?","LowLimit","HighLimit","FitError"}
			Wave DBPar = root:Packages:Irena:SysSpecModels:DBPar
			//DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
			Wave TSPar = root:Packages:Irena:SysSpecModels:TSPar
			//TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}
			Wave BCPar = root:Packages:Irena:SysSpecModels:BCPar
			//BCParNames = {"PorodsSpecSurfArea", "CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}
			Wave HermansPar 	= 	root:Packages:Irena:SysSpecModels:HermansPar
			//HermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue"}
			Wave HybHermansPar 	= 	root:Packages:Irena:SysSpecModels:HybHermansPar
			//HybHermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue","G2","Rg2"}
			Wave UBGPar 	= 	root:Packages:Irena:SysSpecModels:UBGPar
			//UBGParNames = {"Rg1","B1","pack","CorrDist","StackIrreg","kI"}
		strswitch(ModelSelected)	// string switch
			case "Unified Born Green":	// execute if case matches expression
				if(StringMatch(cba.ctrlName, "FitModelVarPar1" ))
					UBGPar[0][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar2" ))
					UBGPar[1][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar3" ))
					UBGPar[2][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar4" ))
					UBGPar[3][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar5" ))
					UBGPar[4][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar6" ))
					UBGPar[5][1] = checked
				endif
				break		// exit from switch
			case "Debye-Bueche":	// execute if case matches expression
				if(StringMatch(cba.ctrlName, "FitModelVarPar1" ))
					DBPar[0][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar2" ))
					DBPar[1][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar3" ))
					DBPar[2][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar4" ))
					DBPar[3][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar5" ))
					DBPar[4][1] = checked
				endif
				break		// exit from switch
			case "Hermans":	// execute if case matches expression
				if(StringMatch(cba.ctrlName, "FitModelVarPar1" ))
					HermansPar[0][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar2" ))
					HermansPar[1][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar3" ))
					HermansPar[2][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar4" ))
					HermansPar[3][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar5" ))
					HermansPar[4][1] = checked
				endif
				break		// exit from switch
			case "Treubner-Strey":	// execute if case matches expression
				if(StringMatch(cba.ctrlName, "FitModelVarPar1" ))
					TSPar[0][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar2" ))
					TSPar[1][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar3" ))
					TSPar[2][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar4" ))
					TSPar[3][1] = checked
				endif
				break		// exit from switch
			case "Benedetti-Cicariello":	// execute if case matches expression
				if(StringMatch(cba.ctrlName, "FitModelVarPar1" ))
					BCPar[0][1] = checked
				endif
				//if(StringMatch(cba.ctrlName, "FitModelVarPar2" ))
				//	BCPar[1][1] = checked
				//endif
				//if(StringMatch(cba.ctrlName, "FitModelVarPar3" ))
				//	BCPar[2][1] = checked
				//endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar4" ))
					BCPar[3][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar5" ))
					BCPar[4][1] = checked
				endif
				break		// exit from switch
			case "Hybrid Hermans":	// execute if case matches expression
				if(StringMatch(cba.ctrlName, "FitModelVarPar1" ))
					HybHermansPar[0][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar2" ))
					HybHermansPar[1][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar3" ))
					HybHermansPar[2][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar4" ))
					HybHermansPar[3][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar5" ))
					HybHermansPar[4][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar6" ))
					HybHermansPar[5][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar7" ))
					HybHermansPar[6][1] = checked
				endif
				break		// exit from switch
			endswitch
			//handle Unified controls
			Wave UnifiedPar = root:Packages:Irena:SysSpecModels:UnifiedPar
		//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
			if(StringMatch(cba.ctrlName, "FitUnifG" ))
				UnifiedPar[0][1]=checked
			endif
			if(StringMatch(cba.ctrlName, "FitUnifRg" ))
				UnifiedPar[1][1]=checked
			endif
			if(StringMatch(cba.ctrlName, "FitUnifPwrlawB" ))
				UnifiedPar[2][1]=checked
			endif
			if(StringMatch(cba.ctrlName, "FitUnifPwrlawP" ))
				UnifiedPar[3][1]=checked
			endif
			if(StringMatch(cba.ctrlName, "LinkUnifRgCO" ))
				UnifiedPar[4][1]=checked
				IR3S_SetRGCOAsNeeded()
				IR3S_AutoRecalculateModelData(0)				
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

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

			string ParamName
			if(stringmatch(ba.ctrlName,"ReverseFit"))
				Wave/Z BackupFitValues = root:Packages:Irena:SysSpecModels:BackupFitValues
				Wave/Z/T CoefNames = root:Packages:Irena:SysSpecModels:CoefNames
				variable i
				if(WaveExists(BackupFitValues)&&WaveExists(CoefNames))
					for (i=0;i<numpnts(CoefNames);i+=1)
					ParamName=StringFromList(0,CoefNames[i],";")
					if(StringMatch(ParamName, "SASBackground" ))
						NVAR SASBackground = root:Packages:Irena:SysSpecModels:SASBackground
						SASBackground = BackupFitValues[i]
					else
						Wave TempParam=$("root:Packages:Irena:SysSpecModels:"+ParamName)
						TempParam[str2num(StringFromList(1,CoefNames[i],";"))][0]=BackupFitValues[i]	
					endif
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
			variable Indx
			
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
				if(StringMatch(sva.vName, "TSPar[2]" ))
					SetVariable $(sva.ctrlName) win=IR3S_SysSpecModelsPanel,limits={-inf ,inf,abs(IR3SSetVariableStepRatio*sva.dval)} 
				else
					SetVariable $(sva.ctrlName) win=IR3S_SysSpecModelsPanel,limits={0 ,inf,abs(IR3SSetVariableStepRatio*sva.dval)} 
				endif
				// sva.vName contains name of variable
				Wave/Z CntrlWv=sva.svwave
				Indx = str2num(stringFromList(1,sva.vName,"["))			//Wname[0]
				if(WaveExists(CntrlWv))
					CntrlWv[Indx][2] = sva.dval * IR3SSetVariableLowLimRatio
					CntrlWv[Indx][3] = sva.dval * IR3SSetVariableHighLimRatio
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
				Wave/Z CntrlWv=sva.svwave
				Indx = str2num(stringFromList(1,sva.vName,"["))			//Wname[0]
				if(WaveExists(CntrlWv))
					CntrlWv[Indx][2] = sva.dval * IR3SSetVariableLowLimRatio
					CntrlWv[Indx][3] = sva.dval * IR3SSetVariableHighLimRatio
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
			OriginalDataErrorWave = 0.02*SourceIntWv		//set to 2% error. Fails with errors=0
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
		//get wavelength, if present in In tensity wave note
		variable wavelength
		wavelength = numberByKey("Wavelength", note(OriginalDataIntWave), "=",";")
		if(numtype(wavelength)==0)
			if(wavelength>0)
				Wave DBPar = root:Packages:Irena:SysSpecModels:DBPar
				//DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
				DBPar[3][0]=wavelength
			endif
		endif
		
		//IR3S_RecoverParameters()	TBA - needs to be fixed for waves
		IR3S_CreateSysSpecModelsGraphs()
		pauseUpdate
		IR3S_AppendDataToGraphLogLog()
		IR3S_AutoRecalculateModelData(0)
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
	ListOfVariablesUF="UseUnified;"
	//	ListOfVariablesUF+="UnifPwrlawP;FitUnifPwrlawP;UnifPwrlawPLL;UnifPwrlawPHL;UnifPwrlawPError;"
	//	ListOfVariablesUF+="UnifPwrlawB;FitUnifPwrlawB;UnifPwrlawBLL;UnifPwrlawBHL;UnifPwrlawBError;"
	//	ListOfVariablesUF+="UnifRg;FitUnifRg;UnifRgLL;UnifRgHL;UnifRgError;"
	//	ListOfVariablesUF+="UnifG;FitUnifG;UnifGLL;UnifGHL;UnifGError;"
	//Debye-Bueche parameters	
	//ListOfVariablesDB="DBPrefactor;FitDBPrefactor;DBPrefactorHL;DBPrefactorLL;"
	//ListOfVariablesDB+="DBcorrL;FitDBcorrL;DBcorrLLL;DBcorrLHL;DBcorrLError;"
	///ListOfVariablesDB+="DBEta;FitDBEta;DBEtaLL;DBEtaHL;DBEtaError;"
	//ListOfVariablesDB+="DBWavelength;"
	ListOfVariablesDB=""
	//Teubner-Strey Model
	//ListOfVariablesTS="TSPrefactor;FitTSPrefactor;TSPrefactorHL;TSPrefactorLL;TSPrefactorError;"
	//ListOfVariablesTS+="TSAvalue;FitTSAvalue;TSAvalueHL;TSAvalueLL;TSAvalueError;"
	//ListOfVariablesTS+="TSC1Value;FitTSC1Value;TSC1ValueHL;TSC1ValueLL;TSC1ValueError;"
	//ListOfVariablesTS+="TSC2Value;FitTSC2Value;TSC2ValueHL;TSC2ValueLL;TSC2ValueError;"
	//ListOfVariablesTS+="TSCorrelationLength;TSCorrLengthError;TSRepeatDistance;TSRepDistError;"
	//Benedetti-Ciccariello Coated Porous media Porods oscillations
	ListOfVariablesBC = ""//"BCVoidScatLengthDensity;BCSolidScatLengthDensity;"
	//ListOfVariablesBC+="BCLayerScatLengthDens;BCLayerScatLengthDensHL;BCLayerScatLengthDensLL;FitBCLayerScatLengthDens;BCLayerScatLengthDensError;"
	//ListOfVariablesBC+="BCCoatingsThickness;BCCoatingsThicknessHL;BCCoatingsThicknessLL;FitBCCoatingsThickness;BCCoatingsThicknessError;"
	//ListOfVariablesBC+="BCPorodsSpecSurfArea;FitBCPorodsSpecSurfArea;BCPorodsSpecSurfAreaHL;BCPorodsSpecSurfAreaLL;BCPorodsSpecSurfAreaError;"
	
	//	SVAR ListOfVariablesBC = root:Packages:Irena:SysSpecModels:ListOfVariablesBC
	//	SVAR ListOfVariablesTS = root:Packages:Irena:SysSpecModels:ListOfVariablesTS
	//	SVAR ListOfVariablesDB = root:Packages:Irena:SysSpecModels:ListOfVariablesDB
	//	SVAR ListOfVariablesUF = root:Packages:Irena:SysSpecModels:ListOfVariablesUF
	//	SVAR ListOfVariablesBG = root:Packages:Irena:SysSpecModels:ListOfVariablesBG
	//	SVAR ListOfVariablesMain = root:Packages:Irena:SysSpecModels:ListOfVariablesMain
	
	ListOfVariables = ListOfVariablesMain+ListOfVariablesUF+ ListOfVariablesDB+ ListOfVariablesTS+ ListOfVariablesBC+ListOfVariablesBG
	// new, use waves for parameters. Let's see if it is better
	make/O/T/N=(5) WaveParamsValues		//this is names for columns 
	WaveParamsValues={"Value","Fit?","LowLimit","HighLimit","FitError"}
	//Unified fit, 4 paramegers, G, Rg, P, B + 1 not fitted parameter, UnifRgCO, LinkUnifRgCO is [4][1], aka Fit
	make/O/N=(5,5) UnifiedPar			//Parameters
	make/O/T/N=(5) UnifiedParNames		//Names for Unified fit parameters. 
	wave/T UnifiedParNames
	UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}

	//Teubner-Strey, 4 paramegers + 2 calculated parameters (never fitted)
	make/O/N=(6,5) TSPar			//
	make/O/T/N=(6) TSParNames		// 
	wave/T TSParNames
	TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}

	//Debye-Bueche, 3 paramegers + 1 calculated parameters (never fitted)
	make/O/N=(4,5) DBPar			//
	make/O/T/N=(4) DBParNames		// 
	wave/T DBParNames
	DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}

	//Benedetti-Ciccariello 3 paramegers + 2 calculated parameters (never fitted)
	make/O/N=(5,5) BCPar			//
	make/O/T/N=(5) BCParNames		// 
	wave/T BCParNames
	BCParNames = {"PorodsSpecSurfArea","CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}


	// Hermans model. https://doi.org/10.1016/j.polymer.2021.124281
	//Hermans model for crystalline polymers, https://doi.org/10.1016/j.polymer.2021.124281
	// Hermans has five parameters [0] is amorphous thickness (or lamellae thickness); [1] is sigma for a Gaussian distribution of amorphous
	//[2] is the lamellar thickness; [3] is sigma; [4] is the Bval. Background is generic parameter for all. 
	make/O/N=(5,5) HermansPar			//Hermans 4 parameters
	make/O/T/N=(5) HermansParNames		//Names for Hermans 4 parameters. 
	HermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue"}

	// Hybrid Hermans model. https://doi.org/10.1016/j.polymer.2021.124281
	//wHybridHermans has has 7 parameters + LinkRGCO to UF + Unified fit we already have.  
	//[0] is amorphous thickness (or lamellae thickness); [1] is sigma for a Gaussian distribution of amorphous
	//[2] is the lamellar thickness; [3] is sigma; [4] is the Bval
	//[5] is G2; [6] is Rg2  // - these need to use Unfied fit which we already have...  [8] is G3; [9] is Rg3; [10] is B3; [11] is P3
	make/O/N=(7,5) HybHermansPar			//Hermans 4 parameters
	make/O/T/N=(7) HybHermansParNames		//Names for Hermans 4 parameters. 
	HybHermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue","G2","Rg2"}

	// Unified Born Green model. https://doi.org/10.1016/j.polymer.2021.124281, Formula 8
	//Fit parameters Rg1,B1,pack,mesh,del,kI
	//UBGParNames = {"Rg1","B1","pack","CorDist","StackIrreg","kI"}
	make/O/N=(6,5) UBGPar			//Hermans 4 parameters
	make/O/T/N=(6) UBGParNames		//Names for Hermans 4 parameters. 
	UBGParNames = {"Rg1","B1","pack","CorDist","StackIrreg","kI"}
	//mesh = CorrDist [A]
	//kI= interfacial broadening parameter (𝑘I) 
	//del = staking irregularity factor (𝛿), typ ~ 0

	
	
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
	ListOfModels="---;Debye-Bueche;Treubner-Strey;Benedetti-Ciccariello;Hermans;Hybrid Hermans;Unified Born Green;"
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

	//Unified
	Wave UnifiedPar = root:Packages:Irena:SysSpecModels:UnifiedPar
	//	UnifiedNames = {"G","Rg","B","P", "UnifRgCO","LinkUnifRgCO"}
	if(UnifiedPar[0][0]<1)		//not initialized
		UnifiedPar[][1] = 0		//Fit?
		if(UnifiedPar[1][0]<=0)	//Rg
			UnifiedPar[1][0]=1e10
			UnifiedPar[0][0] = 0
			UnifiedPar[1][2]=1
			UnifiedPar[1][3]=1.1e10
		endif
		if(UnifiedPar[0][0]<0)	//G
			UnifiedPar[0][0]=0
			UnifiedPar[0][2]=1e-10
			UnifiedPar[0][3]=1e10
		endif
		if(UnifiedPar[0][0]==0)		//G
			UnifiedPar[1][0]=1e10
		endif
		if(UnifiedPar[3][0]==0)		//P
			UnifiedPar[3][0]=3
			UnifiedPar[3][2]=1
			UnifiedPar[3][3]=4
		endif
		if(UnifiedPar[2][0]==0)		//B
			UnifiedPar[2][0]=1
			UnifiedPar[2][2]=1e-10
			UnifiedPar[2][3]=1e10
		endif
		UnifiedPar[][4] = 0		//reset errors
	endif

	//Treubner-Strey
	Wave TSPar = root:Packages:Irena:SysSpecModels:TSPar
	//TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}
	if(TSPar[0][0]<=0)		//TSPrefactor
		TSPar[0][0]=1
		TSPar[0][2]=1e-10
		TSPar[0][3]=1e10
	endif
	if(TSPar[1][0]==0)			//TSAvalue
		TSPar[1][0]=0.1
		TSPar[1][2]=-1e10
		TSPar[1][3]=1e10
	endif
	if(TSPar[2][0]==0)		//TSC1Value
		TSPar[2][0]=-30
		TSPar[2][2]=-1e10
		TSPar[2][3]=1e10
	endif
	if(TSPar[3][0]==0)		//TSC2Value
		TSPar[3][0]=5000
		TSPar[3][2]=-1e10
		TSPar[3][3]=1e10
	endif
	TSPar[][4] = 0
	
	//Debye-Bueche
	Wave DBPar = root:Packages:Irena:SysSpecModels:DBPar
	//DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
	if(DBPar[0][0]==0)	//DBPrefactor
		DBPar[0][0] = 1
		DBPar[0][2] = 1e-10
		DBPar[0][3] = 1e10
	endif
	if(DBPar[2][0]==0)	//DBEta
		DBPar[2][0]=1
		DBPar[2][2]=1e-6
		DBPar[2][3]=1e6
	endif
	if(DBPar[1][0]==0)		//DBcorrL
		DBPar[1][0]=200
		DBPar[1][2]=2
		DBPar[1][3]=1e6
	endif
	if(DBPar[3][0]==0)		//DBWavelength
		DBPar[3][0]=1
	endif
	//NVAR DBWavelength=root:Packages:Irena:SysSpecModels:DBWavelength
	DBPar[][4] = 0
		
	//Hermans, https://doi.org/10.1016/j.polymer.2021.124281, table 2
	Wave HermansPar = root:Packages:Irena:SysSpecModels:HermansPar
	if(HermansPar[0][0]<1)		//not initialized
		HermansPar[0][0] = 47	//amorph thick
		HermansPar[1][0] = 23	//amorph sigma
		HermansPar[2][0] = 146	//lamel thick
		HermansPar[3][0] = 58	//Lamel sigma
		HermansPar[4][0] = 0.0001	//Bval
		HermansPar[][1] = 0		//Fit?
		HermansPar[][2] = 0.05*HermansPar[p][0]	//low limit
		HermansPar[][3] =  20*HermansPar[p][0]	//high limit
	endif
	HermansPar[][4] = 0		//reset errors

	//Hybrid Hermans, https://doi.org/10.1016/j.polymer.2021.124281, table 2
	Wave HybHermansPar = root:Packages:Irena:SysSpecModels:HybHermansPar
	if(HybHermansPar[0][0]<1)		//not initialized
		HybHermansPar[0][0] = 47	//amorph thick
		HybHermansPar[1][0] = 23	//amorph sigma
		HybHermansPar[2][0] = 146	//lamel thick
		HybHermansPar[3][0] = 65	//Lamel sigma
		HybHermansPar[4][0] = 0.0001		//Bval
		HybHermansPar[5][0] = 20		//G2
		HybHermansPar[6][0] = 120	//Rg2
		HybHermansPar[][2] = 0.05*HybHermansPar[p][0]		//low limit
		HybHermansPar[][3] = 20*HybHermansPar[p][0]	//high limit
	endif
	HybHermansPar[][4] = 0		//reset errors


	// Unified Born Green model. https://doi.org/10.1016/j.polymer.2021.124281, table 3
	Wave UBGPar 	= 	root:Packages:Irena:SysSpecModels:UBGPar
	//UBGParNames = {"Rg1","B1","pack","CorDist","StackIrreg","kI"}
	if(UBGPar[0][0]<1)		//not initialized
		UBGPar[0][0] = 100		//Rg1
		UBGPar[1][0] = 0.1		//B1
		UBGPar[2][0] = 168		//pack
		UBGPar[3][0] = 242		//CorrDist
		UBGPar[4][0] = 0.17	//del
		UBGPar[5][0] = 0.02	//kI
		UBGPar[][1] = 0		//unFit all. 
		UBGPar[][2] = 0.05*UBGPar[p][0]		//low limit
		UBGPar[][3] = 20*UBGPar[p][0]	//high limit
	endif
		
	Wave BCPar = root:Packages:Irena:SysSpecModels:BCPar
	//BCParNames = {"PorodsSpecSurfArea", "CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}
	if(BCPar[0][0]<=0)			//BCPorodsSpecSurfArea
		BCPar[0][0] =1e4
	endif
	if(BCPar[2][0]<=0)
		BCPar[2][0] = 19.32			//this is value for silica 
	endif
	BCPar[][4] = 0
	
	NVAR DelayBetweenProcessing=root:Packages:Irena:SysSpecModels:DelayBetweenProcessing
	if(DelayBetweenProcessing<0)
		DelayBetweenProcessing=0
	endif

	//CurrentTab=0
	if(SlitLength==0)
		SlitLength = 1 
	endif
	//if (UseQRSData)
	//	UseIndra2data=0
	//endif
	if (FitSASBackground==0)
		FitSASBackground=1
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



	Wave UnifiedPar = root:Packages:Irena:SysSpecModels:UnifiedPar
	//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
	Wave DBPar = root:Packages:Irena:SysSpecModels:DBPar
	//DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
	Wave TSPar = root:Packages:Irena:SysSpecModels:TSPar
	//TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}
	Wave BCPar = root:Packages:Irena:SysSpecModels:BCPar
	//BCParNames = {"PorodsSpecSurfArea", "CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}
	Wave HermansPar 	= 	root:Packages:Irena:SysSpecModels:HermansPar
	//HermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue"}
	Wave HybHermansPar 	= 	root:Packages:Irena:SysSpecModels:HybHermansPar
	//HybHermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue","G2","Rg2"}
	Wave UBGPar 	= 	root:Packages:Irena:SysSpecModels:UBGPar
	//UBGParNames = {"Rg1","B1","pack","CorrDist","StackIrreg","kI"}
	//	WaveParamsValues={"Value","Fit?","LowLimit","HighLimit","FitError"}

	variable i
	//reset errrors
	UnifiedPar[][4]=0
	DBPar[][4]=0
	TSPar[][4]=0
	BCPar[][4]=0
	HermansPar[][4]=0
	HybHermansPar[][4]=0
	UBGPar[][4]=0

	if (FitSASBackground)		//are we fitting background?
		curLen = (numpnts(W_coef))
		Redimension /N=((curLen+1),2) Gen_Constraints
		Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
		W_Coef[curLen]		=	SASBackground
		BackupFitValues[curLen]=	SASBackground
		CoefNames[curLen]	=	"SASBackground;"
		//Gen_Constraints[curLen][0] = SASBackground/10
		//Gen_Constraints[curLen][1] = SASBackground*10
		FullListOfVariablesToCheck+="SASBackground;"
	endif
	strswitch(ModelSelected)	// string switch
		case "Debye-Bueche":	// execute if case matches expression
			For(i=0;i<4;i+=1)	//only first 4 parameters are fittable. 
				if(DBPar[i][1]>0.5)	//fit? 
					curLen = (numpnts(W_coef))
					Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
					W_Coef[curLen]			= DBPar[i][0]
					BackupFitValues[curLen]	=	DBPar[i][0]
					CoefNames[curLen]	  	=   "DBPar;"+num2str(i)+";"
					if(DBPar[i][2]<DBPar[i][0] && DBPar[i][0]<DBPar[i][3])
						Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
						T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(DBPar[i][2])}
						T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(DBPar[i][3])}		
						//Redimension /N=((curLen+1),2) Gen_Constraints
						//Gen_Constraints[curLen][0] = varMeLL
						//Gen_Constraints[curLen][1] = varMeHL
					endif
				endif
			endfor
			break
		case "Treubner-Strey":	// execute if case matches expression
			//TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}
			//ListOfVariablesToCheck="TSPrefactor;TSAvalue;TSC1Value;TSC2Value;"
			For(i=0;i<4;i+=1)	//only first 4 parameters are fittable. 
				if(TSPar[i][1]>0.5)	//fit? 
					curLen = (numpnts(W_coef))
					Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
					W_Coef[curLen]			= TSPar[i][0]
					BackupFitValues[curLen]	=	TSPar[i][0]
					CoefNames[curLen]	  	=   "TSPar;"+num2str(i)+";"
					if(TSPar[i][2]<TSPar[i][0] && TSPar[i][0]<TSPar[i][3])
						Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
						T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(TSPar[i][2])}
						T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(TSPar[i][3])}		
					endif
				endif
			endfor
			break
		case "Benedetti-Ciccariello":	// execute if case matches expression
			//BCParNames = {"PorodsSpecSurfArea", "CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}
			//ListOfVariablesToCheck="BCPorodsSpecSurfArea;BCLayerScatLengthDens;BCCoatingsThickness;"
			For(i=0;i<3;i+=1)	//only first 4 parameters are fittable. 
				if(BCPar[i][1]>0.5)	//fit? 
					curLen = (numpnts(W_coef))
					Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
					W_Coef[curLen]			= BCPar[i][0]
					BackupFitValues[curLen]	=	BCPar[i][0]
					CoefNames[curLen]	  	=   "BCPar;"+num2str(i)+";"
					if(BCPar[i][2]<BCPar[i][0] && BCPar[i][0]<BCPar[i][3])
						Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
						T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(BCPar[i][2])}
						T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(BCPar[i][3])}		
					endif
				endif
			endfor
			break
		case "Hermans":	// execute if case matches expression
			//HermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue"}
			For(i=0;i<5;i+=1)	//only first 5 parameters are fittable. 
				if(HermansPar[i][1]>0.5)	//fit? 
					curLen = (numpnts(W_coef))
					Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
					W_Coef[curLen]			= HermansPar[i][0]
					BackupFitValues[curLen]	=	HermansPar[i][0]
					CoefNames[curLen]	  	=   "HermansPar;"+num2str(i)+";"
					if(HermansPar[i][2]<HermansPar[i][0] && HermansPar[i][0]<HermansPar[i][3])
						Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
						T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(HermansPar[i][2])}
						T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(HermansPar[i][3])}		
					endif
				endif
			endfor
			break
		case "Hybrid Hermans":	// execute if case matches expression
			//HybHermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue","G2","Rg2"}
			For(i=0;i<7;i+=1)	//only first 5 parameters are fittable. 
				if(HybHermansPar[i][1]>0.5)	//fit? 
					curLen = (numpnts(W_coef))
					Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
					W_Coef[curLen]			= HybHermansPar[i][0]
					BackupFitValues[curLen]	=	HybHermansPar[i][0]
					CoefNames[curLen]	  	=   "HybHermansPar;"+num2str(i)+";"
					if(HybHermansPar[i][2]<HybHermansPar[i][0] && HybHermansPar[i][0]<HybHermansPar[i][3])
						Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
						T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(HybHermansPar[i][2])}
						T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(HybHermansPar[i][3])}		
					endif
				endif
			endfor
			break
		case "Unified Born Green":	// execute if case matches expression
			//UBGParNames = {"Rg1","B1","pack","CorrDist","StackIrreg","kI"}
			For(i=0;i<6;i+=1)	//only first 5 parameters are fittable. 
				if(UBGPar[i][1]>0.5)	//fit? 
					curLen = (numpnts(W_coef))
					Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
					W_Coef[curLen]			= UBGPar[i][0]
					BackupFitValues[curLen]	=	UBGPar[i][0]
					CoefNames[curLen]	  	=   "UBGPar;"+num2str(i)+";"
					if(UBGPar[i][2]<UBGPar[i][0] && UBGPar[i][0]<UBGPar[i][3])
						Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
						T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(UBGPar[i][2])}
						T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(UBGPar[i][3])}		
					endif
				endif
			endfor
			break
	endswitch
	if(UseUnified)
		//ListOfVariablesToCheck+="UnifPwrlawP;UnifPwrlawB;UnifRg;UnifG;"
			//UnifiedParNames = {"G","Rg","B","P","UnifRgCO","LinkUnifRgCO"}
			For(i=0;i<4;i+=1)	//only first 5 parameters are fittable. 
				if(UnifiedPar[i][1]>0.5)	//fit? 
					curLen = (numpnts(W_coef))
					Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
					W_Coef[curLen]			= UnifiedPar[i][0]
					BackupFitValues[curLen]	=	UnifiedPar[i][0]
					CoefNames[curLen]	  	=   "UnifiedPar;"+num2str(i)+";"
					if(UnifiedPar[i][2]<UnifiedPar[i][0] && UnifiedPar[i][0]<UnifiedPar[i][3])
						Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
						T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(UnifiedPar[i][2])}
						T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(UnifiedPar[i][3])}		
					endif
				endif
			endfor
	endif
	
	For(i=0;i<itemsInList(FullListOfVariablesToCheck);i+=1)
		NVAR ValError = $(StringFromList(i, FullListOfVariablesToCheck)+"Error")
		ValError = 0	
	endfor
	if(numpnts(W_Coef)<1)
		Abort "Nothing to fit" 
	endif
	
	DoWindow /F IR3S_LogLogDataDisplay
	wave/Z OriginalDataIntWave=root:Packages:Irena:SysSpecModels:OriginalDataIntWave
	if(!WaveExists(OriginalDataIntWave))//wave does not exist, user probably did not create data yet.
		abort
	endif
	Wave OriginalDataQWave=root:Packages:Irena:SysSpecModels:OriginalDataQWave
	Wave OriginalDataErrorWave=root:Packages:Irena:SysSpecModels:OriginalDataErrorWave
	NVAR AchievedChiSquare=root:Packages:Irena:SysSpecModels:AchievedChiSquare
	
	Variable V_chisq
	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/20
	string HoldStr=""
	string ParamName
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
			AchievedChiSquare = 0
			for (i=0;i<numpnts(CoefNames);i+=1)
				ParamName=StringFromList(0,CoefNames[i],";")
				if(StringMatch(ParamName, "SASBackground" ))
					NVAR SASBackground = root:Packages:Irena:SysSpecModels:SASBackground
					SASBackground = BackupFitValues[i]
				else
					Wave TempParam=$("root:Packages:Irena:SysSpecModels:"+ParamName)
					TempParam[str2num(StringFromList(1,CoefNames[i],";"))][0]=BackupFitValues[i]	
				endif
			endfor
			Print "Warning - Fitting error, Parameters resutored before failure. Check starting parameters and fitting limits" 
			IR3S_AutoRecalculateModelData(1)
			setDataFolder OldDf
			return 0
		endif
		//this now records the errors for fitted parameters into the appropriate variables
		Wave W_sigma=W_sigma
		for (i=0;i<numpnts(CoefNames);i+=1)
			ParamName=StringFromList(0,CoefNames[i],";")
			if(StringMatch(ParamName, "SASBackground" ))
				NVAR BackgroundError = root:Packages:Irena:SysSpecModels:SASBackgroundError
				BackgroundError = W_sigma[i]
			else
				Wave TempParam=$("root:Packages:Irena:SysSpecModels:"+ParamName)
				TempParam[str2num(StringFromList(1,CoefNames[i],";"))][4]=W_sigma[i]	
			endif
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
	//CoefNames[curLen]	  	=   "DBPar;"+num2str(i)+";"
	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	for (i=0;i<NumOfParam;i+=1)
		ParamName=StringFromList(0,CoefNames[i],";")
		if(StringMatch(ParamName, "SASBackground" ))
			NVAR SASBackground = root:Packages:Irena:SysSpecModels:SASBackground
			SASBackground = w[i]
		else
			Wave TempParam=$("root:Packages:Irena:SysSpecModels:"+ParamName)
			TempParam[str2num(StringFromList(1,CoefNames[i],";"))][0]=w[i]	
		endif
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
	//NVAR corrL=root:Packages:Irena:SysSpecModels:DBcorrL
	//NVAR DBEta=root:Packages:Irena:SysSpecModels:DBEta
	Wave DBPar = root:Packages:Irena:SysSpecModels:DBPar
	//DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
	Wave W_coef
	DBPar[1][0] = sqrt(W_coef[1]/W_coef[0])
	IR3S_AutoRecalculateModelData(1)
	Wave DBModelInt=root:Packages:Irena:SysSpecModels:DBModelInt
	variable AveModel, AveData
	wavestats/Q/R=[cursA,cursB] OriginalIntensity
	AveData = V_avg
	wavestats/Q/R=[cursA,cursB] DBModelInt
	AveModel = V_avg
	DBPar[2][0] *= sqrt(AveData/AveModel)
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
	Wave UnifiedPar = root:Packages:Irena:SysSpecModels:UnifiedPar
	//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
	//NVAR LowQslope=root:Packages:Irena:SysSpecModels:UnifPwrlawP
	//NVAR LowQPrefactor=root:Packages:Irena:SysSpecModels:UnifPwrlawB
	Wave W_coef
	if(UseSlitSmearedData)
		UnifiedPar[3][0] = -(W_coef[2] - 1)
		UnifiedPar[2][0] = W_coef[1]
	else
		UnifiedPar[3][0] = -W_coef[2]
		UnifiedPar[2][0] = W_coef[1]
	endif
	IR3S_GraphModelData()
	Wave OriginalIntensity=root:Packages:Irena:SysSpecModels:OriginalDataIntWave
	Wave ModelIntensity=root:Packages:Irena:SysSpecModels:ModelIntensity
	variable AveModel, AveData
	wavestats/Q/R=[cursA,cursB] OriginalIntensity
	AveData = V_avg
	wavestats/Q/R=[cursA,cursB] ModelIntensity
	AveModel = V_avg
	UnifiedPar[2][0] *= (AveData/AveModel)
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

	Wave UnifiedPar = root:Packages:Irena:SysSpecModels:UnifiedPar
	//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
	Wave DBPar = root:Packages:Irena:SysSpecModels:DBPar
	//DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
	Wave TSPar = root:Packages:Irena:SysSpecModels:TSPar
	//TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}
	Wave BCPar = root:Packages:Irena:SysSpecModels:BCPar
	//BCParNames = {"PorodsSpecSurfArea", "CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}
	Wave HermansPar 	= 	root:Packages:Irena:SysSpecModels:HermansPar
	//HermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue"}
	Wave HybHermansPar 	= 	root:Packages:Irena:SysSpecModels:HybHermansPar
	//HybHermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue","G2","Rg2"}
	Wave UBGPar 	= 	root:Packages:Irena:SysSpecModels:UBGPar
	//UBGParNames = {"Rg1","B1","pack","CorrDist","StackIrreg","kI"}
	
	//NVAR LinkUnifRgCO	=root:Packages:Irena:SysSpecModels:LinkUnifRgCO
	//NVAR UnifRgCO		=root:Packages:Irena:SysSpecModels:UnifRgCO
	//NVAR DBcorrL		=root:Packages:Irena:SysSpecModels:DBcorrL
	//NVAR TSAvalue		=root:Packages:Irena:SysSpecModels:TSAvalue
	//NVAR TSC1Value		=root:Packages:Irena:SysSpecModels:TSC1Value
	//NVAR TSC2Value		=root:Packages:Irena:SysSpecModels:TSC2Value
	if(UnifiedPar[4][1])
		if(StringMatch(ModelSelected, "Debye-Bueche") )
			UnifiedPar[4][0]=DBPar[1][0]
		elseif(StringMatch(ModelSelected, "Treubner-Strey") )
			//UnifiedPar[5][0] = 1/sqrt(0.5*sqrt(TSAvalue/TSC2Value)+TSC1Value/4/TSC2Value)
			UnifiedPar[4][0] = 1/sqrt(0.5*sqrt(TSPar[1][0]/TSPar[3][0])+TSPar[2][0]/4/TSPar[3][0])
		elseif(StringMatch(ModelSelected, "Hybrid Hermans") )
			UnifiedPar[4][0] = HybHermansPar[6][0]
		elseif(StringMatch(ModelSelected, "Hermans") )
			UnifiedPar[4][0] = HermansPar[0][0]+HermansPar[2][0]
		elseif(StringMatch(ModelSelected, "Unified Born Green") )
			UnifiedPar[4][0] = UBGPar[0][0]//+UBGPar[3][0]
		else
			UnifiedPar[4][0] = 0
		endif
	else
		//UnifiedPar[4][0] = 0
	endif

end

//*****************************************************************************************************************

static Function IR3S_CalculateModel(OriginalIntensity,OriginalQvector, calledFromFitting)
	wave OriginalIntensity,OriginalQvector
	variable calledFromFitting

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:SysSpecModels

	
	Duplicate/O OriginalIntensity, ModelIntensity,ModelIntensityQ4,ModelIntensityQ3, DBModelIntSqrtN1
	Duplicate/Free OriginalIntensity, CiccBenModelIntensity, UnifiedModelInt, HermansModelIntensity,  DebyBuecheIntensity, UnifiedFitIntensity, UnsmearedModelIntensity,TreubnerStreyIntensity
	Duplicate/O OriginalIntensity, DBModelInt, TSModelInt, CBModelInt, HerModelInt
	Duplicate/O OriginalQvector, DBModelQvector, QstarVector
	DebyBuecheIntensity=0
	UnifiedFitIntensity=0
	UnsmearedModelIntensity=0
	TreubnerStreyIntensity=0
	CiccBenModelIntensity=0
	HermansModelIntensity = 0
	
	NVAR UseUnified=root:Packages:Irena:SysSpecModels:UseUnified
	NVAR UseSlitSmearedData=root:Packages:Irena:SysSpecModels:UseSlitSmearedData
	NVAR SlitLength=root:Packages:Irena:SysSpecModels:SlitLength
	NVAR SASBackground=root:Packages:Irena:SysSpecModels:SASBackground
	SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected
	//NVAR LinkUnifRgCO=root:Packages:Irena:SysSpecModels:LinkUnifRgCO
	IR3S_SetRGCOAsNeeded()

	Wave UnifiedPar = root:Packages:Irena:SysSpecModels:UnifiedPar
	//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
	Wave DBPar = root:Packages:Irena:SysSpecModels:DBPar
	//DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
	Wave TSPar = root:Packages:Irena:SysSpecModels:TSPar
	//TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}
	Wave BCPar = root:Packages:Irena:SysSpecModels:BCPar
	//BCParNames = {"PorodsSpecSurfArea", "CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}
	Wave HermansPar 	= 	root:Packages:Irena:SysSpecModels:HermansPar
	//HermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue"}
	Wave HybHermansPar 	= 	root:Packages:Irena:SysSpecModels:HybHermansPar
	//HybHermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue","G2","Rg2"}
	Wave UBGPar 	= 	root:Packages:Irena:SysSpecModels:UBGPar
	//UBGParNames = {"Rg1","B1","pack","CorrDist","StackIrreg","kI"}

	variable UnifRg = UnifiedPar[1][0], UnifG = UnifiedPar[0][0], UnifPwrlawB = UnifiedPar[2][0]
	variable UnifPwrlawP = UnifiedPar[3][0]
	variable UnifRgCO = UnifiedPar[4][0]
	if(UseUnified && !StringMatch(ModelSelected, "Hybrid Hermans" ))			//Unified level
		QstarVector=OriginalQvector/(erf(OriginalQvector*UnifRg/sqrt(6)))^3	
		UnifiedFitIntensity=UnifG*exp(-OriginalQvector^2*UnifRg^2/3)+(UnifPwrlawB/QstarVector^UnifPwrlawP)* exp(-UnifRgCO^2 * OriginalQvector^2/3)
		//UnifiedFitIntensity = UnifPwrlawB * OriginalQvector^(-1*UnifPwrlawP)
	else
		UnifiedFitIntensity = 0
	endif

	//debye-bueche
	variable DBWavelength =DBPar[3][0] , DBPrefactor =DBPar[0][0], DBEta =DBPar[2][0], DBcorrL =DBPar[1][0]
	//DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
	if(StringMatch(ModelSelected, "Debye-Bueche" ))
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
		//DebyBuecheIntensity = DBPrefactor*(4*pi*DBK*DBeta^2*DBcorrL^2)/(1+OriginalQvector^2*DBcorrL^2)^2
		variable DBK = 8 * pi^2 * DBWavelength^(-4)		
		DebyBuecheIntensity = DBPrefactor*(4*pi*DBK*DBeta^2*DBcorrL^3)/(1+OriginalQvector^2*DBcorrL^2)^2			//changed 2012/08
	else
		DebyBuecheIntensity = 0
	endif

	//Treubner-Strey
	variable TSPrefactor=TSPar[0][0], TSAvalue=TSPar[1][0], TSC1Value=TSPar[2][0], TSC2Value=TSPar[3][0]
	//TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}
	if(StringMatch(ModelSelected, "Treubner-Strey" ))
		TreubnerStreyIntensity = TSPrefactor / (TSAvalue + TSC1Value * OriginalQvector^2 + TSC2Value* OriginalQvector^4)
		//TSCorrelationLength = 1/sqrt(0.5*sqrt(TSAvalue/TSC2Value)+TSC1Value/4/TSC2Value)
		TSPar[4][0] = 1/sqrt(0.5*sqrt(TSAvalue/TSC2Value)+TSC1Value/4/TSC2Value)
		//	xi = 0.5*sqrt(a2/c2) + c1/4/c2
		//	xi = 1/sqrt(xi)
		//TSRepeatDistance = 2*pi/sqrt(0.5*sqrt(TSAvalue/TSC2Value) - TSC1Value/4/TSC2Value)
		TSPar[5][0] = 2*pi/sqrt(0.5*sqrt(TSAvalue/TSC2Value) - TSC1Value/4/TSC2Value)
		//	dd = 0.5*sqrt(a2/c2) - c1/4/c2
		//	dd = 1/sqrt(dd)
		//	dd *=2*Pi
	else
		TreubnerStreyIntensity=0	
	endif

	//Benedetti-Ciccariello's  coated porous media
	variable BCSolidScatLengthDensity=BCPar[3][0] , BCVoidScatLengthDensity=BCPar[4][0], BCPorodsSpecSurfArea=BCPar[0][0]
	variable BCCoatingsThickness=BCPar[1][0], BCLayerScatLengthDens =BCPar[2][0] 
	Wave BCPar = root:Packages:Irena:SysSpecModels:BCPar
	//BCParNames = {"PorodsSpecSurfArea", "CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}
	if(StringMatch(ModelSelected, "Benedetti-Ciccariello" ))
		//nu = (n13 - n32)/n12
		//where n13 =  N1 - N3 etc. 
		// nu = (n13 - n32)/n12 = (N1-2N2+N3)/(N1-N2) 
		variable n12 = BCSolidScatLengthDensity*1e10 - BCVoidScatLengthDensity*1e10
		variable NuValue = ((BCSolidScatLengthDensity - 2*BCLayerScatLengthDens + BCVoidScatLengthDensity))/(BCSolidScatLengthDensity - BCVoidScatLengthDensity)
		variable ALpha = (1 + NuValue^2)/2
		variable Rnu = (1-NuValue^2)/(1+NuValue^2)
		if(!UseSlitSmearedData||(UseSlitSmearedData&&numtype(SlitLength)==0))								//Ciccariello's  coated porous media
			//and now I(q) = (2*pi*n12^2*alpha*BCPorodsSpecSurfArea / Q^4) * [1+Rnu*cos(Q*BCCoatingsThickness)]+BCMicroscDensFluctuations
			//print (2*pi*n12^2*alpha*BCPorodsSpecSurfArea / (OriginalQvector[120]^4*1e32))		
			CiccBenModelIntensity = (2*pi*n12^2*alpha*BCPorodsSpecSurfArea / (OriginalQvector^4*1e32)) * (1+Rnu*cos(OriginalQvector*BCCoatingsThickness))
		else
			CiccBenModelIntensity=0
		endif
	else
		CiccBenModelIntensity=0
	endif
	
	//Hermans
	//Hybrid Hermans
	//Unified Born Green
	if(StringMatch(ModelSelected, "Hermans" ))
		HermansModelIntensity = IR3S_Hermans(HermansPar,OriginalQvector[p])
	elseif(StringMatch(ModelSelected, "Hybrid Hermans" ))
		HermansModelIntensity = IR3S_HybridHermans(HybHermansPar,UnifiedPar, OriginalQvector[p])
	elseif(StringMatch(ModelSelected, "Unified Born Green" ))
		HermansModelIntensity = IR3S_UBG(UBGPar,OriginalQvector[p])
	else
		HermansModelIntensity=0	
	endif
	
	UnsmearedModelIntensity = DebyBuecheIntensity + UnifiedFitIntensity + TreubnerStreyIntensity + CiccBenModelIntensity + HermansModelIntensity+ SASBackground
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
			if(sum(HerModelInt)>0)
				IR1B_SmearData(HermansModelIntensity, OriginalQvector, slitLength, HerModelInt)
			endif

		endif
	else
		ModelIntensity= UnsmearedModelIntensity	
		DBModelInt = DebyBuecheIntensity
		UnifiedModelInt = UnifiedFitIntensity
		TSModelInt = TreubnerStreyIntensity
		CBModelInt = CiccBenModelIntensity
		HerModelInt = HermansModelIntensity
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


static Function IR3S_HybridHermans(wHybridHermans,wUnif, qval)
	wave wHybridHermans, wUnif
	variable qval
	// Hybrid Hermans model. https://doi.org/10.1016/j.polymer.2021.124281
	//wHybridHermans has 7 parameters + Unified fit we already have. 
	// [0] is amorphous thickness (or lamellae thickness); [1] is sigma for a Gaussian distribution of amorphous
	//[2] is the lamellar thickness; [3] is sigma; [4] is the Bval
	//[5] is G2; [6] is Rg2  
	// Others need to be from wUnif  8[0] is G3; 9[1] is Rg3; 10[2] is B3; 11[3] is P3
	//UnifiedParNames = {"G","Rg","B","P","UnifRgCO","LinkUnifRgCO"}
	//abort "Need to fix this to handle everyhitng"
	//will need to apss in the Unified fit par wave also...
	Variable G2=abs(wHybridHermans[5][0]),Rg2=abs(wHybridHermans[6][0])
	Variable G3=abs(wUnif[0][0]),Rg3=abs(wUnif[1][0]),B3=abs(wUnif[2][0]),P3=abs(wUnif[3][0])
	variable amoth=abs(wHybridHermans[0][0]),amosig=abs(wHybridHermans[1][0]),cryth=abs(wHybridHermans[2][0]),crysig=abs(wHybridHermans[3][0])
	//variable/g gcutoff//use level 2 to cutoff level 3? 1 = yes; 2 = no
	variable cutoff=wUnif[4][1]
	Variable/C cv_i=cmplx(0,1)
	Variable qstar2 = qval/(erf(1.06*qval*abs(Rg2)/sqrt(6)))^3,qstar3 = qval/(erf(1.06*qval*abs(Rg3)/sqrt(6)))^3
	//qstar2=qval
	if(P3>3)//For non-fractal level 3
		qstar3 = qval/(erf(qval*abs(Rg3)/sqrt(6)))^3
	endif
	variable sval=qstar2/(2*pi)
	variable/C H1=exp(2*pi*cv_i*amoth*sval-2*pi^2*amosig^2*sval^2)
	variable/C H2=exp(2*pi*cv_i*cryth*sval-2*pi^2*crysig^2*sval^2)
	variable Bs = abs(wHybridHermans[4])/(2*pi)^4
	variable int=(Bs/(sval^4))*Real((1-H1)*(1-H2)/(1-H1*H2))
	//add level 2 Guinier
	Int+=G2*exp(-abs(Rg2)^2*qval^2/3)
	//add level 3
	if(cutoff==1)//use level 2 to cutoff level 3
		wUnif[4][0]=Rg2
		Int+=G3*exp(-abs(Rg3)^2*qval^2/3)+B3*exp(-abs(Rg2)^2*qval^2/3)*qstar3^(-abs(P3))
	else //no cutoff for the power-law
		Int+=G3*exp(-abs(Rg3)^2*qval^2/3)+B3*qstar3^(-abs(P3))
	endif
	return(Int)
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR3S_Hermans(wHermans,qval)
	wave wHermans;variable qval
	// Hermans model. https://doi.org/10.1016/j.polymer.2021.124281
	//wHermans has five parameters [0] is amorphous thickness (or lamellae thickness); [1] is sigma for a Gaussian distribution of amorphous
	//[2] is the lamellar thickness; [3] is sigma; [4] is the Bval
	
	Variable/C cv_i=cmplx(0,1)
	variable sval=qval/(2*pi)
	variable/C H1=exp(2*pi*cv_i*wHermans[0][0]*sval-2*pi^2*wHermans[1][0]^2*sval^2)
	variable/C H2=exp(2*pi*cv_i*wHermans[2][0]*sval-2*pi^2*wHermans[3][0]^2*sval^2)
	variable Bs = wHermans[4][0]/(2*pi)^4
	variable intensity=(Bs/(sval^4))*Real((1-H1)*(1-H2)/(1-H1*H2))
	return(intensity)
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


static Function IR3S_UBG(wUBG,qval)
	wave wUBG
	variable qval
	// Unified Born Green model. https://doi.org/10.1016/j.polymer.2021.124281, Formula 8
	//Fit parameters Rg1,B1,pack,mesh,del,kI
	//variable bkg=abs(wUBG[0])
	variable Rg1=abs(wUBG[0][0])
	variable B1=abs(wUBG[1][0])
	variable pack=abs(wUBG[2][0])
	variable mesh=abs(wUBG[3][0])
	variable del=abs(wUBG[4][0])
	variable kI=abs(wUBG[5][0])
	variable Rad=sqrt(pack*mesh*Rg1/(4))
	//Calculate I(q) no correlations
	variable G1 = B1*Rg1^4*Rad/(2*Rg1+Rad)
	variable B2=2*G1/(Rg1^2)
	variable qstar1=qval/(erf(qval*abs(Rg1)/sqrt(6)))^3
	variable Rg2=sqrt(Rad^2/2+Rg1^2/3)
	variable qstar2=qval/(erf(qval*abs(Rg2)/sqrt(6)))^3
	variable G2=G1*(Rad/Rg1)^2
	variable theResult=G1*exp(-qval^2*Rg1^2/3)+B1*(qstar1)^(-4)
	theResult+=G2*exp(-qval^2*Rg2^2/3)+(exp(-qval^2*Rg1^2/3)*B2*qstar2^(-2))
	//add correlations and only modify the qval in the structure factor
	qval=qval*exp(del*(qval-2*pi/mesh)/qval)
	if(pack!=0)
		variable corrnum=qval*mesh
		variable angle,Slocal=0,count3=0,gNoIters=20
		variable DelAngle=Pi/(2*gNoIters)
		variable sumtheta=0,theta=0
		if(gNoIters==1)
			theResult/=(1+pack*(sin(corrnum)/(corrnum))*exp(-(corrnum)^2*kI))
		else
			do
				angle=Count3*DelAngle
				if(cos(angle)==0)
					theta=1	
				else
					theta=sin(corrnum*cos(angle))/(corrnum*cos(angle))
				endif
				sumtheta+=theta*pi/2
				count3+=1
				while(count3<gNoIters)
					theResult/=(1+pack*(sumtheta/gNoIters)*exp(-(corrnum)^2*kI))
				endif
	endif
	Return(theResult)
End
//*****************************************************************************************************************
//*****************************************************************************************************************
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
	string TargetFolder
	strswitch(ModelSelected)	// string switch
		case "Debye-Bueche":	// execute if case matches expression
			TargetFolder="DebyeBuecheResults"
			break
		case "Treubner-Strey":	// execute if case matches expression
			//Teubner-Strey Model
			TargetFolder="TreubnerStreyResults"
			break
		case "Benedetti-Ciccariello":	// execute if case matches expression
			//Ciccariello Coated Porous media Porods oscillations
			TargetFolder="BenedettiCiccarielloResults"
			break
		case "Hermans":	// execute if case matches expression
			TargetFolder="HermansResults"
			break
		case "Hybrid Hermans":	// execute if case matches expression
			TargetFolder="HybHermansResults"
			break
		case "Unified Born Green":	// execute if case matches expression
			TargetFolder="UBGResults"
			break
	endswitch
	string ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	NewDataFolder/O/S root:$(TargetFolder)
	print "Saving results from "+ModelSelected+" in folder : "+TargetFolder
	print "This folder has number of waves with results ready to be plotted or put in tables"
	Wave/Z/T DataFolderNameWv
	if(!WaveExists(DataFolderNameWv))
		Make/O/N=0/T DataFolderNameWv, IntensityWaveNameWv, QWavenameWv, ErrorWaveNameWv
		Make/O/N=0 TimeWave, TemperatureWave,PercentWave, OrderWave
	endif
	variable curLength=numpnts(DataFolderNameWv)
	For(i=0;i<itemsInList(ListOfStrings);i+=1)
		SVAR TempStr = $("root:Packages:Irena:SysSpecModels:"+stringFromList(i,ListOfStrings))
		Wave/T TmpStrWv = $(stringFromList(i,ListOfStrings)+"Wv")
		redimension/N=(curLength+1) TmpStrWv
		TmpStrWv[curLength] = TempStr
	endfor

	//variable oldnum
	strswitch(ModelSelected)	// string switch
		case "Debye-Bueche":	// execute if case matches expression
			Wave DBPar = root:Packages:Irena:SysSpecModels:DBPar
			Wave/T DBParNames = root:Packages:Irena:SysSpecModels:DBParNames
			//DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
			For(i=0;i<DimSize(DBPar,0);i+=1)
				Wave/Z TmpWv=$(DBParNames[i]+"Wv")
				if(!WaveExists(TmpWv))
					make/O/N=0 $(DBParNames[i]+"Wv"), $(DBParNames[i]+"ErrWv")
				endif
				Wave TmpWv=$(DBParNames[i]+"Wv")
				Wave TmpWvErr=$(DBParNames[i]+"ErrWv")
				//oldnum=numpnts(TmpWv)
				Redimension /N=(curLength+1) TmpWv, TmpWvErr
				TmpWv[curLength] 		= DBPar[i][0]
				TmpWvErr[curLength] 	= DBPar[i][4]
			endfor
			break
		case "Treubner-Strey":	// execute if case matches expression
			//Teubner-Strey Model
			Wave TSPar = root:Packages:Irena:SysSpecModels:TSPar
			Wave/T TSParNames = root:Packages:Irena:SysSpecModels:TSParNames
			//TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}
			For(i=0;i<DimSize(TSPar,0);i+=1)
				Wave/Z TmpWv=$(TSParNames[i]+"Wv")
				if(!WaveExists(TmpWv))
					make/O/N=0 $(TSParNames[i]+"Wv"), $(TSParNames[i]+"ErrWv")
				endif
				Wave TmpWv=$(TSParNames[i]+"Wv")
				Wave TmpWvErr=$(TSParNames[i]+"ErrWv")
				//oldnum=numpnts(TmpWv)
				Redimension /N=(curLength+1) TmpWv, TmpWvErr
				TmpWv[curLength] 		= TSPar[i][0]
				TmpWvErr[curLength] 	= TSPar[i][4]
			endfor
			break
		case "Benedetti-Ciccariello":	// execute if case matches expression
			//Ciccariello Coated Porous media Porods oscillations
			Wave BCPar = root:Packages:Irena:SysSpecModels:BCPar
			Wave/T BCParNames = root:Packages:Irena:SysSpecModels:BCParNames
			//BCParNames = {"PorodsSpecSurfArea", "CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}
			For(i=0;i<DimSize(BCPar,0);i+=1)
				Wave/Z TmpWv=$(BCParNames[i]+"Wv")
				if(!WaveExists(TmpWv))
					make/O/N=0 $(BCParNames[i]+"Wv"), $(BCParNames[i]+"ErrWv")
				endif
				Wave TmpWv=$(BCParNames[i]+"Wv")
				Wave TmpWvErr=$(BCParNames[i]+"ErrWv")
				//oldnum=numpnts(TmpWv)
				Redimension /N=(curLength+1) TmpWv, TmpWvErr
				TmpWv[curLength] 		= BCPar[i][0]
				TmpWvErr[curLength] 	= BCPar[i][4]
			endfor
			break
		case "Hermans":	// execute if case matches expression
			Wave/T HermansParNames = root:Packages:Irena:SysSpecModels:HermansParNames
			Wave HermansPar 	= 	root:Packages:Irena:SysSpecModels:HermansPar
			//HermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeThicknessSigma","Bvalue"}
			For(i=0;i<DimSize(HermansPar,0);i+=1)
				Wave/Z TmpWv=$(HermansParNames[i]+"Wv")
				if(!WaveExists(TmpWv))
					make/O/N=0 $(HermansParNames[i]+"Wv"), $(HermansParNames[i]+"ErrWv")
				endif
				Wave TmpWv=$(HermansParNames[i]+"Wv")
				Wave TmpWvErr=$(HermansParNames[i]+"ErrWv")
				//oldnum=numpnts(TmpWv)
				Redimension /N=(curLength+1) TmpWv, TmpWvErr
				TmpWv[curLength] 		= HermansPar[i][0]
				TmpWvErr[curLength] 	= HermansPar[i][4]
			endfor
			break
		case "Hybrid Hermans":	// execute if case matches expression
			Wave HybHermansPar 	= 	root:Packages:Irena:SysSpecModels:HybHermansPar
			Wave/T HybHermansParNames 	= 	root:Packages:Irena:SysSpecModels:HybHermansParNames
			//HybHermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue","G2","Rg2"}
			For(i=0;i<DimSize(HybHermansPar,0);i+=1)
				Wave/Z TmpWv=$(HybHermansParNames[i]+"Wv")
				if(!WaveExists(TmpWv))
					make/O/N=0 $(HybHermansParNames[i]+"Wv"), $(HybHermansParNames[i]+"ErrWv")
				endif
				Wave TmpWv=$(HybHermansParNames[i]+"Wv")
				Wave TmpWvErr=$(HybHermansParNames[i]+"ErrWv")
				//oldnum=numpnts(TmpWv)
				Redimension /N=(curLength+1) TmpWv, TmpWvErr
				TmpWv[curLength] 		= HybHermansPar[i][0]
				TmpWvErr[curLength] 	= HybHermansPar[i][4]
			endfor
			break
		case "Unified Born Green":	// execute if case matches expression
			Wave UBGPar 	= 	root:Packages:Irena:SysSpecModels:UBGPar
			Wave/T UBGParNames 	= 	root:Packages:Irena:SysSpecModels:UBGParNames
			//UBGParNames = {"Rg1","B1","pack","CorrDist","StackIrreg","kI"}
			For(i=0;i<DimSize(UBGPar,0);i+=1)
				Wave/Z TmpWv=$(UBGParNames[i]+"Wv")
				if(!WaveExists(TmpWv))
					make/O/N=0 $(UBGParNames[i]+"Wv"), $(UBGParNames[i]+"ErrWv")
				endif
				Wave TmpWv=$(UBGParNames[i]+"Wv")
				Wave TmpWvErr=$(UBGParNames[i]+"ErrWv")
				//oldnum=numpnts(TmpWv)
				Redimension /N=(curLength+1) TmpWv, TmpWvErr
				TmpWv[curLength] 		= UBGPar[i][0]
				TmpWvErr[curLength] 	= UBGPar[i][4]
			endfor
			break
	endswitch

	NVAR UseUnified			= root:Packages:Irena:SysSpecModels:UseUnified
	if(UseUnified)
		Wave UnifiedPar = root:Packages:Irena:SysSpecModels:UnifiedPar
		Wave/T UnifiedParNames = root:Packages:Irena:SysSpecModels:UnifiedParNames
		//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
		For(i=0;i<DimSize(UnifiedPar,0);i+=1)
			Wave/Z TmpWv=$(UnifiedParNames[i]+"Wv")
			if(!WaveExists(TmpWv))
				make/O/N=0 $(UnifiedParNames[i]+"Wv"), $(UnifiedParNames[i]+"ErrWv")
			endif
			Wave TmpWv=$(UnifiedParNames[i]+"Wv")
			Wave TmpWvErr=$(UnifiedParNames[i]+"ErrWv")
			//oldnum=numpnts(TmpWv)
			Redimension /N=(curLength+1) TmpWv, TmpWvErr
			TmpWv[curLength] 		= UnifiedPar[i][0]
			TmpWvErr[curLength] 	= UnifiedPar[i][4]
		endfor
	endif	




	
//	For(i=0;i<itemsInList(ListOfVariables);i+=1)
//		TempVarName = stringFromList(i,ListOfVariables)
//		NVAR TempVal = $("root:Packages:Irena:SysSpecModels:"+TempVarName)
//		Wave TmpWv = $(TempVarName+"Wv")
//		redimension/N=(curLength+1) TmpWv
//		TmpWv[curLength] = TempVal
//	endfor
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
	SVAR ModelSelected = root:Packages:Irena:SysSpecModels:ModelSelected

	string ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	variable i,j
	For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
		For(i=0;i<itemsInList(ListOfStrings);i+=1)
			SVAR TempStr = $("root:Packages:Irena:SysSpecModels:"+stringFromList(i,ListOfStrings))
			IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),ModelSelected+"_"+stringFromList(i,ListOfStrings),TempStr)
		endfor
	endfor


	strswitch(ModelSelected)	// string switch
		case "Debye-Bueche":	// execute if case matches expression
			Wave DBPar = root:Packages:Irena:SysSpecModels:DBPar
			Wave/T DBParNames = root:Packages:Irena:SysSpecModels:DBParNames
			//DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
			For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
				For(i=0;i<DimSize(DBPar,0);i+=1)
					IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),ModelSelected+"_"+DBParNames[i],num2str(DBPar[i][0]))
					IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),ModelSelected+"Err_"+DBParNames[i],num2str(DBPar[i][4]))
				endfor
			endfor
			break
		case "Treubner-Strey":	// execute if case matches expression
			//Teubner-Strey Model
			Wave TSPar = root:Packages:Irena:SysSpecModels:TSPar
			Wave/T TSParNames = root:Packages:Irena:SysSpecModels:TSParNames
			//TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}
			For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
				For(i=0;i<DimSize(TSPar,0);i+=1)
					IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),ModelSelected+"_"+TSParNames[i],num2str(TSPar[i][0]))
					IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),ModelSelected+"Err_"+TSParNames[i],num2str(TSPar[i][4]))
				endfor
			endfor
			break
		case "Benedetti-Ciccariello":	// execute if case matches expression
			//Ciccariello Coated Porous media Porods oscillations
			Wave BCPar = root:Packages:Irena:SysSpecModels:BCPar
			Wave/T BCParNames = root:Packages:Irena:SysSpecModels:BCParNames
			//BCParNames = {"PorodsSpecSurfArea", "CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}
			For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
				For(i=0;i<DimSize(BCPar,0);i+=1)
					IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),ModelSelected+"_"+BCParNames[i],num2str(BCPar[i][0]))
					IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),ModelSelected+"Err_"+BCParNames[i],num2str(BCPar[i][4]))
				endfor
			endfor
			break
		case "Hermans":	// execute if case matches expression
			Wave/T HermansParNames = root:Packages:Irena:SysSpecModels:HermansParNames
			Wave HermansPar 	= 	root:Packages:Irena:SysSpecModels:HermansPar
			//HermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeThicknessSigma","Bvalue"}
			For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
				For(i=0;i<DimSize(HermansPar,0);i+=1)
					IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),ModelSelected+"_"+HermansParNames[i],num2str(HermansPar[i][0]))
					IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),ModelSelected+"Err_"+HermansParNames[i],num2str(HermansPar[i][4]))
				endfor
			endfor
			break
		case "Hybrid Hermans":	// execute if case matches expression
			Wave HybHermansPar 	= 	root:Packages:Irena:SysSpecModels:HybHermansPar
			Wave/T HybHermansParNames 	= 	root:Packages:Irena:SysSpecModels:HybHermansParNames
			//HybHermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue","G2","Rg2"}
			For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
				For(i=0;i<DimSize(HybHermansPar,0);i+=1)
					IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),ModelSelected+"_"+HybHermansParNames[i],num2str(HybHermansPar[i][0]))
					IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),ModelSelected+"Err_"+HybHermansParNames[i],num2str(HybHermansPar[i][4]))
				endfor
			endfor
			break
		case "Unified Born Green":	// execute if case matches expression
			Wave UBGPar 	= 	root:Packages:Irena:SysSpecModels:UBGPar
			Wave/T UBGParNames 	= 	root:Packages:Irena:SysSpecModels:UBGParNames
			//UBGParNames = {"Rg1","B1","pack","CorrDist","StackIrreg","kI"}
			For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
				For(i=0;i<DimSize(UBGPar,0);i+=1)
					IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),ModelSelected+"_"+UBGParNames[i],num2str(UBGPar[i][0]))
					IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),ModelSelected+"Err_"+UBGParNames[i],num2str(UBGPar[i][4]))
				endfor
			endfor
			break
	endswitch

	NVAR UseUnified			= root:Packages:Irena:SysSpecModels:UseUnified
	if(UseUnified)
		Wave UnifiedPar = root:Packages:Irena:SysSpecModels:UnifiedPar
		Wave/T UnifiedParNames = root:Packages:Irena:SysSpecModels:UnifiedParNames
		//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
		For(j=0;j<ItemsInList(ListOfWavesForNotes);j+=1)
			For(i=0;i<DimSize(UnifiedPar,0);i+=1)
				IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),"UnifiedLevel_"+UnifiedParNames[i],num2str(UnifiedPar[i][0]))
				IN2G_AppendorReplaceWaveNote(stringFromList(j,ListOfWavesForNotes),"UnifiedLevelErr_"+UnifiedParNames[i],num2str(UnifiedPar[i][4]))
			endfor
		endfor
	endif	
	
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

	//TODO - fix for waves
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

	strswitch(ModelSelected)	// string switch
		case "Debye-Bueche":	// execute if case matches expression
			Wave DBPar = root:Packages:Irena:SysSpecModels:DBPar
			//DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
			variable DBPrefactor	= DBPar[0][0]
			variable DBEta			= DBPar[2][0]
			variable DBcorrL		= DBPar[1][0]
			variable DBEtaError		= DBPar[2][4]
			variable DBcorrLError		= DBPar[1][4]
			FittingResults+="Prefactor = "+num2str(DBPrefactor)+"\r"
			FittingResults+="Eta = "+num2str(DBEta)+" +/- "+num2str(DBEtaError)+"\r"
			FittingResults+="Correlation Length = "+num2str(DBcorrL)+" +/- "+num2str(DBcorrLError)+"\r"
			break
		case "Treubner-Strey":	// execute if case matches expression
			//Teubner-Strey Model
			Wave TSPar = root:Packages:Irena:SysSpecModels:TSPar
			//TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}
			variable TSPrefactor		= TSPar[0][0]
			variable TSCorrelationLength= TSPar[4][0]
			variable TSRepeatDistance	= TSPar[5][0]
			variable TSPrefactorError	= TSPar[0][4]
			variable TSCorrLengthError	= TSPar[4][4]
			variable TSRepDistError		= TSPar[5][4]
			FittingResults+="Prefactor = "+num2str(TSPrefactor)+"\r"
			FittingResults+="Correlation Length = "+num2str(TSCorrelationLength)+"\r"
			FittingResults+="Repeat distance = "+num2str(TSRepeatDistance)+"\r"
			break
		case "Benedetti-Ciccariello":	// execute if case matches expression
			//Ciccariello Coated Porous media Porods oscillations
			Wave BCPar = root:Packages:Irena:SysSpecModels:BCPar
			//BCParNames = {"PorodsSpecSurfArea", "CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}
			variable BCPorodsSpecSurfArea		= BCPar[0][0]
			variable BCLayerScatLengthDens		= BCPar[2][0]
			variable BCCoatingsThickness		= BCPar[1][0]
			variable BCPorodsSpecSurfAreaError	= BCPar[0][4]
			variable BCLayerScatLengthDensError	= BCPar[2][4]
			variable BCCoatingsThicknessError	= BCPar[1][4]
			FittingResults+="Porod specific surface area [cm2/cm3]= "+num2str(BCPorodsSpecSurfArea)+" +/- "+num2str(BCPorodsSpecSurfAreaError)+"\r"
			FittingResults+="Layer Thickness [A] = "+num2str(BCCoatingsThickness)+" +/- "+num2str(BCCoatingsThicknessError)+"\r"
			FittingResults+="Layer Contrast [10^10 cm^-2]= "+num2str(BCLayerScatLengthDens)+" +/- "+num2str(BCLayerScatLengthDensError)+"\r"
			break
		case "Hermans":	// execute if case matches expression
			Wave HermansPar 	= 	root:Packages:Irena:SysSpecModels:HermansPar
			//HermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeThicknessSigma","Bvalue"}
			FittingResults+= "Amorphous Thickness = "+num2str(HermansPar[0][0])+" A"+" +/- "+num2str(HermansPar[0][4])+"\r"
			FittingResults+= "Am. Thick. Sigma = "+num2str(HermansPar[1][0])+" A"+" +/- "+num2str(HermansPar[1][4])+"\r"
			FittingResults+= "Lamellae thickness = "+num2str(HermansPar[2][0])+" A"+" +/- "+num2str(HermansPar[2][4])+"\r"
			FittingResults+= "Lam. thick. Sigma = "+num2str(HermansPar[3][0])+" A"+" +/- "+num2str(HermansPar[3][4])+"\r"
			break
		case "Hybrid Hermans":	// execute if case matches expression
			Wave HybHermansPar 	= 	root:Packages:Irena:SysSpecModels:HybHermansPar
			//HybHermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue","G2","Rg2"}
			FittingResults+= "Amorphous Thickness = "+num2str(HybHermansPar[0][0])+" A"+" +/- "+num2str(HybHermansPar[0][4])+"\r"
			FittingResults+= "Am. Thick. Sigma = "+num2str(HybHermansPar[1][0])+" A"+" +/- "+num2str(HybHermansPar[1][4])+"\r"
			FittingResults+= "Lamellae thickness = "+num2str(HybHermansPar[2][0])+" A"+" +/- "+num2str(HybHermansPar[2][4])+"\r"
			FittingResults+= "Lam. thick. Sigma = "+num2str(HybHermansPar[3][0])+" A"+" +/- "+num2str(HybHermansPar[3][4])+"\r"
			FittingResults+= "G2  = "+num2str(HybHermansPar[5][0])+" A"+" +/- "+num2str(HybHermansPar[5][4])+"\r"
			FittingResults+= "Rg2 = "+num2str(HybHermansPar[6][0])+" A"+" +/- "+num2str(HybHermansPar[6][4])+"\r"
			break
		case "Unified Born Green":	// execute if case matches expression
			Wave UBGPar 	= 	root:Packages:Irena:SysSpecModels:UBGPar
			//UBGParNames = {"Rg1","B1","pack","CorrDist","StackIrreg","kI"}
			FittingResults+= "Rg1 = "+num2str(UBGPar[0][0])+" A"+" +/- "+num2str(UBGPar[0][4])+"\r"
			FittingResults+= "B1 = "+num2str(UBGPar[1][0])+" A"+" +/- "+num2str(UBGPar[1][4])+"\r"
			FittingResults+= "Pack = "+num2str(UBGPar[2][0])+" A"+" +/- "+num2str(UBGPar[2][4])+"\r"
			FittingResults+= "Corr Dist ξ = "+num2str(UBGPar[3][0])+" A"+" +/- "+num2str(UBGPar[3][4])+"\r"
			FittingResults+= "Stack Irr  δ = "+num2str(UBGPar[4][0])+" A"+" +/- "+num2str(UBGPar[4][4])+"\r"
			FittingResults+= "kI   = "+num2str(UBGPar[5][0])+" A"+" +/- "+num2str(UBGPar[5][4])+"\r"
			break


	endswitch
	NVAR UseUnified
	if(UseUnified)
		FittingResults+="\rModeling also included low-q power-law slope\r"
		Wave UnifiedPar = root:Packages:Irena:SysSpecModels:UnifiedPar
		//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
		variable UnifRg			= UnifiedPar[1][0]
		variable UnifG			= UnifiedPar[0][0]
		variable UnifGError		= UnifiedPar[0][4]
		variable UnifRgError	= UnifiedPar[1][4]
		variable UnifPwrlawP	= UnifiedPar[3][0]
		variable UnifPwrlawB	= UnifiedPar[2][0]
		variable UnifPwrlawPError	= UnifiedPar[3][4]
		variable UnifPwrlawBError	= UnifiedPar[2][4]
		FittingResults+="Low-Q G = "+num2str(UnifG)+" +/- "+num2str(UnifGError)+"\r"
		FittingResults+="Low-Q Rg = "+num2str(UnifRg)+" +/- "+num2str(UnifRgError)+"\r"
		FittingResults+="Low-Q B = "+num2str(UnifPwrlawB)+" +/- "+num2str(UnifPwrlawBError)+"\r"
		FittingResults+="Low-Q P = "+num2str(UnifPwrlawP)+" +/- "+num2str(UnifPwrlawPError)+"\r"
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
	Tag/W=IR3S_LogLogDataDisplay /K/N=UBGTag 
	Tag/W=IR3S_LogLogDataDisplay /K/N=HermansTag 
	Tag/W=IR3S_LogLogDataDisplay /K/N=HybHermansTag 

	if(attach && !HideTagsAlways)	
		SVAR DataFolderName		= root:Packages:Irena:SysSpecModels:DataFolderName
		SVAR IntensityWaveName	= root:Packages:Irena:SysSpecModels:IntensityWaveName
		wave OriginalQvector	= root:Packages:Irena:SysSpecModels:OriginalDataQWave
		SVAR ModelSelected 		= root:Packages:Irena:SysSpecModels:ModelSelected
		WAVE ModelIntensity 	= root:Packages:Irena:SysSpecModels:ModelIntensity
		string LowQText, DBText, CiccBenTxt,TStxt, HermansTxt
		variable attachPoint
	
	
		strswitch(ModelSelected)	// string switch
			case "Debye-Bueche":	// execute if case matches expression
				Wave DBPar = root:Packages:Irena:SysSpecModels:DBPar
				//DBParNames = {"Prefactor","CorrLength","Eta","Wavelength"}
				variable DBPrefactor	= DBPar[0][0]
				variable DBEta			= DBPar[2][0]
				variable DBcorrL		= DBPar[1][0]
				variable DBEtaError		= DBPar[2][4]
				variable DBcorrLError		= DBPar[1][4]
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
				Wave TSPar = root:Packages:Irena:SysSpecModels:TSPar
				//TSParNames = {"Prefactor","A","C1","C2","CorrLength","RepeatDistance"}
				variable TSPrefactor		= TSPar[0][0]
				variable TSCorrelationLength= TSPar[4][0]
				variable TSRepeatDistance	= TSPar[5][0]
				variable TSPrefactorError	= TSPar[0][4]
				variable TSCorrLengthError	= TSPar[4][4]
				variable TSRepDistError		= TSPar[5][4]
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
				Wave BCPar = root:Packages:Irena:SysSpecModels:BCPar
				//BCParNames = {"PorodsSpecSurfArea", "CoatingsThickness","LayerScatLengthDens","SolidScatLengthDensity","VoidScatLengthDensity"}
				variable BCPorodsSpecSurfArea		= BCPar[0][0]
				variable BCLayerScatLengthDens		= BCPar[2][0]
				variable BCCoatingsThickness		= BCPar[1][0]
				variable BCPorodsSpecSurfAreaError	= BCPar[0][4]
				variable BCLayerScatLengthDensError	= BCPar[2][4]
				variable BCCoatingsThicknessError	= BCPar[1][4]
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
			case "Hermans":	// execute if case matches expression
				Wave HermansPar 	= 	root:Packages:Irena:SysSpecModels:HermansPar
				//HermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeThicknessSigma","Bvalue"}
				attachPoint=(pcsr(A,"IR3S_LogLogDataDisplay") +pcsr(B,"IR3S_LogLogDataDisplay"))/2
				HermansTxt = "\Z"+IN2G_LkUpDfltVar("LegendSize")+"Hermans model results\r"
				HermansTxt += "Sample name: "+DataFolderName+IntensityWaveName+"\r"
				HermansTxt += "Amorphous Thickness = "+num2str(HermansPar[0][0])+" A"+" +/- "+num2str(HermansPar[0][4])+"\r"
				HermansTxt += "Am. Thick. Sigma = "+num2str(HermansPar[1][0])+" A"+" +/- "+num2str(HermansPar[1][4])+"\r"
				HermansTxt += "Lamellae thickness = "+num2str(HermansPar[2][0])+" A"+" +/- "+num2str(HermansPar[2][4])+"\r"
				HermansTxt += "Lam. thick. Sigma = "+num2str(HermansPar[3][0])+" A"+" +/- "+num2str(HermansPar[3][4])
				Tag/W=IR3S_LogLogDataDisplay /C/N=HermansTag ModelIntensity, attachPoint,HermansTxt
				break
			case "Hybrid Hermans":	// execute if case matches expression
				Wave HybHermansPar 	= 	root:Packages:Irena:SysSpecModels:HybHermansPar
				//HybHermansParNames = {"AmorphousThickness","SigmaAmorphous","LamellaeThickness","LamellaeSigma","Bvalue","G2","Rg2"}
				attachPoint=(pcsr(A,"IR3S_LogLogDataDisplay") +pcsr(B,"IR3S_LogLogDataDisplay"))/2
				HermansTxt = "\Z"+IN2G_LkUpDfltVar("LegendSize")+"Hybrid Hermans model results\r"
				HermansTxt += "Sample name: "+DataFolderName+IntensityWaveName+"\r"
				HermansTxt += "Amorphous Thickness = "+num2str(HybHermansPar[0][0])+" A"+" +/- "+num2str(HybHermansPar[0][4])+"\r"
				HermansTxt += "Am. Thick. Sigma = "+num2str(HybHermansPar[1][0])+" A"+" +/- "+num2str(HybHermansPar[1][4])+"\r"
				HermansTxt += "Lamellae thickness = "+num2str(HybHermansPar[2][0])+" A"+" +/- "+num2str(HybHermansPar[2][4])+"\r"
				HermansTxt += "Lam. thick. Sigma = "+num2str(HybHermansPar[3][0])+" A"+" +/- "+num2str(HybHermansPar[3][4])
				HermansTxt += "G2  = "+num2str(HybHermansPar[5][0])+" A"+" +/- "+num2str(HybHermansPar[5][4])+"\r"
				HermansTxt += "Rg2 = "+num2str(HybHermansPar[6][0])+" A"+" +/- "+num2str(HybHermansPar[6][4])
				Tag/W=IR3S_LogLogDataDisplay /C/N=HybHermansTag ModelIntensity, attachPoint,HermansTxt
				break
			case "Unified Born Green":	// execute if case matches expression
				Wave UBGPar 	= 	root:Packages:Irena:SysSpecModels:UBGPar
				//UBGParNames = {"Rg1","B1","pack","CorrDist","StackIrreg","kI"}
				attachPoint=(pcsr(A,"IR3S_LogLogDataDisplay") +pcsr(B,"IR3S_LogLogDataDisplay"))/2
				HermansTxt = "\Z"+IN2G_LkUpDfltVar("LegendSize")+"Unified Born Green results\r"
				HermansTxt += "Sample name: "+DataFolderName+IntensityWaveName+"\r"
				HermansTxt += "Rg1 = "+num2str(UBGPar[0][0])+" A"+" +/- "+num2str(UBGPar[0][4])+"\r"
				HermansTxt += "B1 = "+num2str(UBGPar[1][0])+" A"+" +/- "+num2str(UBGPar[1][4])+"\r"
				HermansTxt += "Pack = "+num2str(UBGPar[2][0])+" A"+" +/- "+num2str(UBGPar[2][4])+"\r"
				HermansTxt += "Corr Dist ξ = "+num2str(UBGPar[3][0])+" A"+" +/- "+num2str(UBGPar[3][4])+"\r"
				HermansTxt += "Stack Irr  δ = "+num2str(UBGPar[4][0])+" A"+" +/- "+num2str(UBGPar[4][4])+"\r"
				HermansTxt += "k\\BI\\M"+"\Z"+IN2G_LkUpDfltVar("LegendSize")+"  = "+num2str(UBGPar[5][0])+" A"+" +/- "+num2str(UBGPar[5][4])
				Tag/W=IR3S_LogLogDataDisplay /C/N=UBGTag ModelIntensity, attachPoint,HermansTxt
				break
		endswitch

		NVAR UseUnified			= root:Packages:Irena:SysSpecModels:UseUnified
		if(UseUnified)
			Wave UnifiedPar = root:Packages:Irena:SysSpecModels:UnifiedPar
			//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
			variable UnifRg			= UnifiedPar[1][0]
			variable UnifG			= UnifiedPar[0][0]
			variable UnifGError		= UnifiedPar[0][4]
			variable UnifRgError	= UnifiedPar[1][4]
			variable UnifPwrlawP	= UnifiedPar[3][0]
			variable UnifPwrlawB	= UnifiedPar[2][0]
			variable UnifPwrlawPError	= UnifiedPar[3][4]
			variable UnifPwrlawBError	= UnifiedPar[2][4]
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

	// TODO - fix this for waves!
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
