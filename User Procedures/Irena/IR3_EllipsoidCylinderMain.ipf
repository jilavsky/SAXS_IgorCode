#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3				// Use modern global access method and strict wave access
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later
#pragma version=0.3

//*************************************************************************\
//* Copyright (c) 2005 - 2025, Argonne National Laboratorys
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//version info:
//	0.1 initial testing
//  0.3 initial inclusion in Irena


// this code models SAS from very long cylinder, core shell cylinder, cylinder with elliptical cross section and core shell cylinder with eliptical cross section
// presumably, this is for bioSAXS
// new tool needed as some of the methods of fitting may be unusual... 

constant IR3FversionNumber = 0.1
constant IR3FSetVariableStepRatio = 0.05
constant IR3FSetVariableLowLimRatio = 0.3
constant IR3FSetVariableHighLimRatio = 3


/////******************************************************************************************
/////******************************************************************************************

//Menu "Dev"
//	"Cylinder tool",IR3F_CylinderModels() 
//
//end
//	


/////******************************************************************************************
/////******************************************************************************************
Function IR3F_CylinderModels()

	KillWindow/Z IR3F_CylinderModelsPanel
	KillWindow/Z IR3F_LogLogDataDisplay

	IN2G_CheckScreenSize("width",1200)
	DoWIndow IR3F_CylinderModelsPanel
	if(V_Flag)
		DoWindow/F IR3F_CylinderModelsPanel
	else
		IR3F_InitCylinderModels()
		IR3F_CylinderPanelFnct()
		ING2_AddScrollControl()
		IR1_UpdatePanelVersionNumber("IR3F_CylinderModelsPanel", IR3FversionNumber,1)
		IR3C_MultiUpdListOfAvailFiles("Irena:CylinderModels")	
	endif
	//IR3F_CreateCylinderModelsGraphs()
end
////************************************************************************************************************
Function IR3F_MainCheckVersion()	
	DoWindow IR3F_CylinderModelsPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR3F_CylinderModelsPanel", IR3FversionNumber))
			DoAlert /T="The CylinderModels panel was created by incorrect version of Irena " 1, "CylinderModels needs to be restarted to work properly. Restart now?"
			if(V_flag==1)
				KillWIndow/Z IR3F_CylinderModelsPanel
				//KillWindow/Z IR3F_LogLogDataDisplay
				IR3F_CylinderModels()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR3F_InitCylinderModels()
			endif
		endif
	endif
end
//
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
////************************************************************************************************************
Function IR3F_CylinderPanelFnct()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(2.25,43.25,560,815) as "Cylinder based Models"
	DoWIndow/C IR3F_CylinderModelsPanel
	TitleBox MainTitle title="Cylinder Models - Dev!",pos={140,2},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={360,30},fSize=22,fColor=(0,0,52224)
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("Irena:CylinderModels","IR3F_CylinderModelsPanel","DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;","AllCurrentlyAllowedTypes",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,0, DoNotAddControls=1)
	IR3C_MultiAppendControls("Irena:CylinderModels","IR3F_CylinderModelsPanel", "IR3F_CopyAndAppendData","",1,1)
	//hide what is not needed
	checkbox UseResults, disable=1
	SetVariable DataQEnd,pos={290,90},size={190,15}, proc=IR3F_SetVarProc,title="Q max "
	Setvariable DataQEnd, variable=root:Packages:Irena:CylinderModels:DataQEnd, limits={-inf,inf,0}
	SetVariable DataQstart,pos={290,110},size={190,15}, proc=IR3F_SetVarProc,title="Q min "
	Setvariable DataQstart, variable=root:Packages:Irena:CylinderModels:DataQstart, limits={-inf,inf,0}
	SetVariable DataFolderName,noproc,title=" ",pos={260,145},size={260,20},frame=0, fstyle=1,fSize=11,valueColor=(0,0,65535)
	Setvariable DataFolderName, variable=root:Packages:Irena:CylinderModels:DataFolderName, noedit=1

	//Button SelectAll,pos={187,680},size={80,15}, proc=IR3F_ButtonProc,title="SelectAll", help={"Select All data in Listbox"}
	Button GetHelp,pos={430,50},size={80,15},fColor=(65535,32768,32768), proc=IR3F_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}
	PopupMenu ModelSelected,pos={280,165},size={200,20},fStyle=2,proc=IR3F_PopMenuProc,title="Function : "
	SVAR ModelSelected = root:Packages:Irena:CylinderModels:ModelSelected
	PopupMenu ModelSelected,mode=1,popvalue=ModelSelected,value= #"root:Packages:Irena:CylinderModels:ListOfModels" 

	//	here will be model variables/controls... These will be attached to specific variables later... 
	SetVariable ModelVarPar1,pos={340,190},size={110,17},title="ModelVarPar1",proc=IR3F_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar1"}
	CheckBox FitModelVarPar1,pos={470,190},size={79,14},proc=IR3F_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar2,pos={340,210},size={110,17},title="ModelVarPar2",proc=IR3F_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar2"}
	CheckBox FitModelVarPar2,pos={470,210},size={79,14},proc=IR3F_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar3,pos={340,230},size={110,17},title="ModelVarPar3",proc=IR3F_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar3"}
	CheckBox FitModelVarPar3,pos={470,230},size={79,14},proc=IR3F_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar4,pos={340,250},size={110,17},title="ModelVarPar4",proc=IR3F_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar4"}
	CheckBox FitModelVarPar4,pos={470,250},size={79,14},proc=IR3F_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar5,pos={340,270},size={110,17},title="ModelVarPar5",proc=IR3F_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar5"}
	CheckBox FitModelVarPar5,pos={470,270},size={79,14},proc=IR3F_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar6,pos={340,290},size={110,17},title="ModelVarPar6",proc=IR3F_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar6"}
	CheckBox FitModelVarPar6,pos={470,290},size={79,14},proc=IR3F_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar7,pos={340,310},size={110,17},title="ModelVarPar7",proc=IR3F_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar7"}
	CheckBox FitModelVarPar7,pos={470,310},size={79,14},proc=IR3F_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1
	SetVariable ModelVarPar8,pos={340,330},size={110,17},title="ModelVarPar8",proc=IR3F_SetVarProc, disable=1, bodywidth=70,limits={0,inf,1}, help={"ModelVarPar8"}
	CheckBox FitModelVarPar8,pos={470,330},size={79,14},proc=IR3F_FitCheckProc,title="Fit?", help={"Fit this parameter?"}, disable=1


	SetVariable ModelVarPar1LL,pos={260,355},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var1"}
	SetVariable ModelVarPar1UL,pos={340,355},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var1"}
	SetVariable ModelVarPar2LL,pos={260,375},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var2"}
	SetVariable ModelVarPar2UL,pos={340,375},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var2"}
	SetVariable ModelVarPar3LL,pos={260,395},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var3"}
	SetVariable ModelVarPar3UL,pos={340,395},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var3"}
	SetVariable ModelVarPar4LL,pos={260,415},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var4"}
	SetVariable ModelVarPar4UL,pos={340,415},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var4"}
	SetVariable ModelVarPar5LL,pos={260,435},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var5"}
	SetVariable ModelVarPar5UL,pos={340,435},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var5"}
	SetVariable ModelVarPar6LL,pos={260,455},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var6"}
	SetVariable ModelVarPar6UL,pos={340,455},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var6"}
	SetVariable ModelVarPar7LL,pos={260,475},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var7"}
	SetVariable ModelVarPar7UL,pos={340,475},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var7"}
	SetVariable ModelVarPar8LL,pos={260,495},size={60,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Lower fitting limit Var8"}
	SetVariable ModelVarPar8UL,pos={340,495},size={100,17},title=" ",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Upper fitting limit Var8"}

	Button ModelButton1,pos={500,345},size={80,20}, proc=IR3F_ButtonProc, title="Button1", help={""}, disable=0
	Button ModelButton2,pos={500,370},size={80,20}, proc=IR3F_ButtonProc, title="Button2", help={""}, disable=0
	Button ModelButton3,pos={500,395},size={80,20}, proc=IR3F_ButtonProc, title="Button3", help={""}, disable=0

	SetVariable ProfileMaxX,pos={400,530},size={70,17},title="Profile max radius [A]",noproc, disable=1, bodywidth=60,limits={0,inf,1}, help={"Max radius considered in Profile"}
	SetVariable ProfileMaxX win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfileMaxX
//	CheckBox UseGMatrixCalculations,pos={400,550},size={79,14},title="Use Matrix Calc", help={"Use calculations which are faster when changing only profile?"}, disable=1
//	CheckBox UseGMatrixCalculations,noproc,variable= root:Packages:Irena:CylinderModels:UseGMatrixCalculations


//	//here is Unified level + background. 
//	CheckBox UseUnified,pos={270,480},size={79,14},proc=IR3F_MainPanelCheckProc,title="Add Unified?"
//	CheckBox UseUnified,variable= root:Packages:Irena:CylinderModels:UseUnified, help={"Add one level unified level to model data?"}
//	NVAR UseUnified = root:Packages:Irena:CylinderModels:UseUnified
//	Button EstimateUF,pos={380,480},size={100,15}, proc=IR3F_ButtonProc
//	//	UnifiedNames = {"G","Rg","B","P","RgCO", "LinkRgCO"}
//	Button EstimateUF, title="Estimate slope", help={"Fit power law to estimate slope of low q region"}, disable=!(UseUnified)
//	SetVariable UnifG,pos={270,500},size={110,17},title="G       ",proc=IR3F_SetVarProc, disable=!(UseUnified), bodywidth=70
//	SetVariable UnifG,limits={0,inf,1},value= root:Packages:Irena:CylinderModels:UnifiedPar[0][0], help={"G for Unified level Rg"}
//	SetVariable UnifRg,pos={270,520},size={110,17},title="Rg     ",proc=IR3F_SetVarProc, disable=!(UseUnified), bodywidth=70
//	SetVariable UnifRg,limits={0,inf,1},value= root:Packages:Irena:CylinderModels:UnifiedPar[1][0], help={"Rg for Unified level"}	
//	SetVariable UnifPwrlawB,pos={270,540},size={110,17},title="B       ",proc=IR3F_SetVarProc, disable=!(UseUnified), bodywidth=70
//	SetVariable UnifPwrlawB,limits={0,inf,1},value= root:Packages:Irena:CylinderModels:UnifiedPar[2][0], help={"Prefactor for low-Q power law slope"}
//	SetVariable UnifPwrlawP,pos={270,560},size={110,17},title="P       ",proc=IR3F_SetVarProc, disable=!(UseUnified), bodywidth=70
//	SetVariable UnifPwrlawP,limits={0,5,0.1},value= root:Packages:Irena:CylinderModels:UnifiedPar[3][0], help={"Power law slope of low-Q region"}
//	SetVariable UnifRgCO,pos={270,580},size={110,17},title="RgCO  ",proc=IR3F_SetVarProc, disable=!(UseUnified), bodywidth=70
//	SetVariable UnifRgCO,limits={0,inf,10},value= root:Packages:Irena:CylinderModels:UnifiedPar[4][0], help={"Rg cutt off for low-Q region"}
	PopupMenu FittingPower,pos={270,580},size={200,20},fStyle=2,proc=IR3F_PopMenuProc,title="Fit I*Q^x : "
	SVAR FittingPower = root:Packages:Irena:CylinderModels:FittingPower
	PopupMenu FittingPower,mode=1,popvalue=FittingPower,value= #"root:Packages:Irena:CylinderModels:ListOfFittingPowers" 

	SetVariable SASBackground,pos={270,610},size={150,16},proc=IR3F_SetVarProc,title="SAS Background", help={"Background of SAS"}, bodywidth=70
	SetVariable SASBackground,limits={-inf,Inf,1},variable= root:Packages:Irena:CylinderModels:SASBackground
//
//	Wave UnifiedPar = root:Packages:Irena:CylinderModels:UnifiedPar
//	//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
//	CheckBox FitUnifG,pos={400,500},size={79,14},proc=IR3F_FitCheckProc,title="Fit?", value= UnifiedPar[0][1], help={"Fit this parameter?"}, disable=!(UseUnified)
//	CheckBox FitUnifRg,pos={400,520},size={79,14},proc=IR3F_FitCheckProc,title="Fit?", value= UnifiedPar[1][1], help={"Fit this parameter?"}, disable=!(UseUnified)
//	CheckBox FitUnifPwrlawB,pos={400,540},size={79,14},proc=IR3F_FitCheckProc,title="Fit?", value= UnifiedPar[2][1], help={"Fit this parameter?"}, disable=!(UseUnified)
//	CheckBox FitUnifPwrlawP,pos={400,560},size={79,14},proc=IR3F_FitCheckProc,title="Fit?", value= UnifiedPar[3][1], help={"Fit this parameter?"}, disable=!(UseUnified)
//	CheckBox LinkUnifRgCO,pos={400,580},size={79,14},proc=IR3F_FitCheckProc,title="Link?", value= UnifiedPar[4][1], help={"Link this RgCO to model feature size?"}, disable=!(UseUnified)


	CheckBox FitSASBackground,pos={450,610},size={79,14},noproc,title="Fit?", variable= root:Packages:Irena:CylinderModels:FitSASBackground, help={"Fit this parameter?"}
//

	//final controls... 
	Button RecalculateModel,pos={275,640},size={110,20}, proc=IR3F_ButtonProc, title="Calculate Model", help={"Calculate Model using parameters above"}
	Button FitModel,pos={275,665},size={110,20}, proc=IR3F_ButtonProc, title="Fit Data", help={"Fit Model using selection/model above to data curtrently in tool"}
	//Button FitAllSelected, pos={275,690},size={110,20}, proc=IR3F_ButtonProc, title="Fit sequence", help={"Fit sequnce of data selected in the ListBox with model"}
	Button ReverseFit,pos={275,715},size={110,18}, proc=IR3F_ButtonProc, title="Reverse fit", help={"Fit Model using selection/model above"}

	CheckBox RecalculateAutomatically,pos={400,640},size={79,14},proc=IR3F_MainPanelCheckProc,title="Auto Recalculate?", variable= root:Packages:Irena:CylinderModels:UpdateAutomatically, help={"Recalculate when any number changes?"}
	CheckBox SaveToNotebook,pos={400,660},size={79,14},noproc,title="Save To Notebook?", variable= root:Packages:Irena:CylinderModels:SaveToNotebook, help={"Save results to Notebook?"}
	//CheckBox SaveToFolder,pos={400,680},size={79,14},noproc,title="Save To folder?", variable= root:Packages:Irena:CylinderModels:SaveToFolder, help={"Save results to folder?"}
	//CheckBox SaveToWaves,pos={400,700},size={79,14},noproc,title="Save To waves?", variable= root:Packages:Irena:CylinderModels:SaveToWaves, help={"Save results to waves in folder?"}
	Button   SaveResults,pos={400,720},size={110,18}, proc=IR3F_ButtonProc, title="Save Results", help={"Save results"}


	TitleBox Instructions1 title="\Zr100Double click to add data to graph",size={330,15},pos={4,680},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions2 title="\Zr100Shift-click to select range of data",size={330,15},pos={4,695},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions3 title="\Zr100Ctrl/Cmd-click to select one data set",size={330,15},pos={4,710},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions4 title="\Zr100Regex for not contain: ^((?!string).)*$",size={330,15},pos={4,725},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions5 title="\Zr100Regex for contain:  string, two: str2.*str1",size={330,15},pos={4,740},frame=0,fColor=(0,0,65535),labelBack=0
	TitleBox Instructions6 title="\Zr100Regex for case independent:  (?i)string",size={330,15},pos={4,755},frame=0,fColor=(0,0,65535),labelBack=0
	
	SetVariable DelayBetweenProcessing,pos={240,735},size={150,16},noproc,title="Delay in Seq. Proc:", help={"Delay between sample in sequence of processing data sets"}
	SetVariable DelayBetweenProcessing,limits={0,30,0},variable= root:Packages:Irena:CylinderModels:DelayBetweenProcessing, bodywidth=50
	//CheckBox DoNotTryRecoverData,pos={245,754},size={79,14},noproc,title="Do not restore prior result", variable= root:Packages:Irena:CylinderModels:DoNotTryRecoverData, help={"Save results to Notebook?"}
	CheckBox HideTagsAlways,pos={425,754},size={79,14},proc=IR3F_MainPanelCheckProc,title="Hide Tags", variable= root:Packages:Irena:CylinderModels:HideTagsAlways, help={"Save results to Notebook?"}

	//and fix which controls are displayed:
	IR3F_SetupControlsOnMainpanel()
	//IR3F_AutoRecalculateModelData(0)
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR3F_SetupControlsOnMainpanel()
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	SVAR ModelSelected = root:Packages:Irena:CylinderModels:ModelSelected
	NVAR UseUnified = root:Packages:Irena:CylinderModels:UseUnified
	Wave CylPar	 = root:Packages:Irena:CylinderModels:CylPar	
	//CylParNames = {"Prefactor","Radius","Length","SLD"}
	Wave CSCylPar	 = root:Packages:Irena:CylinderModels:CSCylPar	
	//CylParNames = {"Prefactor","Radius","Length","SLD","ShellThickness"}
	Wave ElCylPar	 = root:Packages:Irena:CylinderModels:ElCylPar	
	//ElCylParNames = {"Prefactor","Radius","Length","SLD","AspectRatio"}
	Wave CSElCylPar	 = root:Packages:Irena:CylinderModels:CSElCylPar	
	//CSElCylParNames = 		{"Prefactor","Radius","Length","SLD","ShellThickness","AspectRatio"}
	Wave ProfCSElCylPar= root:Packages:Irena:CylinderModels:ProfCSElCylPar
	//ProfCSElCylParNames = {"Prefactor","Radius","Length","AspectRatio","Shell1Th","Shell1SLD", "Shell2th", "Shell2SLD"}
	
	//Wave UBGPar 	= 	root:Packages:Irena:CylinderModels:UBGPar
	//UBGParNames = {"Rg1","B1","pack","CorrDist","StackIrreg","kI"}
	DoWindow IR3F_CylinderModelsPanel
	if(V_Flag)
		strswitch(ModelSelected)	// string switch
			case "Cylinder":	// execute if case matches expression
				//CylParNames = {"Prefactor","Radius","Length","SLD"}
				SetVariable ModelVarPar1 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CylPar[0][0] ,title="Scale         ", disable=0, limits={-inf,inf,IR3FSetVariableStepRatio*CylPar[0][0]}, help={"Scale"}
				SetVariable ModelVarPar2 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CylPar[1][0] ,title="Radius [A]    ", disable=0, limits={1,inf,IR3FSetVariableStepRatio*CylPar[1][0]}, help={"Radius of the cylinder, A"}
				SetVariable ModelVarPar3 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CylPar[2][0] ,title="Length [A]    ", disable=0, limits={10,inf,IR3FSetVariableStepRatio*CylPar[2][0]}, help={"Length of cylinder, A"}
				SetVariable ModelVarPar4 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CylPar[3][0] ,title="Δ SLD [10^10cm^-2]", disable=0, limits={0.01,inf,IR3FSetVariableStepRatio*CylPar[3][0]}, help={"SLD of core (NOT dRho^2)"}
				SetVariable ModelVarPar5 win=IR3F_CylinderModelsPanel, disable=1, noedit=0
				SetVariable ModelVarPar6 win=IR3F_CylinderModelsPanel, disable=1, noedit=0
				SetVariable ModelVarPar7 win=IR3F_CylinderModelsPanel, disable=1, noedit=0

				CheckBox FitModelVarPar1 win=IR3F_CylinderModelsPanel,value= CylPar[0][1], disable=0 	//variable= root:Packages:Irena:CylinderModels:FitDBPrefactor, disable=1
				CheckBox FitModelVarPar2 win=IR3F_CylinderModelsPanel,value= CylPar[2][1], disable=0
				CheckBox FitModelVarPar3 win=IR3F_CylinderModelsPanel,value= CylPar[1][1], disable=1
				CheckBox FitModelVarPar4 win=IR3F_CylinderModelsPanel,disable=1//value= DBPar[3][1], disable=0
				CheckBox FitModelVarPar5 win=IR3F_CylinderModelsPanel,disable=1
				CheckBox FitModelVarPar6 win=IR3F_CylinderModelsPanel,disable=1
				CheckBox FitModelVarPar7 win=IR3F_CylinderModelsPanel,disable=1

				Button ModelButton1 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1
				Button ModelButton2 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1
				Button ModelButton3 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1

				SetVariable ModelVarPar1LL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CylPar[0][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Scale"}
				SetVariable ModelVarPar1UL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CylPar[0][3] ,title="< Scale < ", disable=0, limits={0.01,inf,0}, help={"High limit for Scale"}
				SetVariable ModelVarPar2LL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CylPar[1][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Radius"}
				SetVariable ModelVarPar2UL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CylPar[1][3] ,title="< Rad < ", disable=0, limits={0.01,inf,0}, help={"High limit for Radius"}
				SetVariable ModelVarPar3LL win=IR3F_CylinderModelsPanel,disable=1
				SetVariable ModelVarPar3UL win=IR3F_CylinderModelsPanel,disable=1
				SetVariable ModelVarPar4LL win=IR3F_CylinderModelsPanel,disable=1			//value=root:Packages:Irena:CylinderModels:DBPar[1][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for SLD"}
				SetVariable ModelVarPar4UL win=IR3F_CylinderModelsPanel,disable=1			//value=root:Packages:Irena:CylinderModels:DBPar[1][3] ,title="< SLD < ", disable=0, limits={0.01,inf,0}, help={"High limit for SLD"}
				SetVariable ModelVarPar5LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar5UL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar6LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar6UL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar7LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar7UL win=IR3F_CylinderModelsPanel, disable=1
				break		// exit from switch

			case "Core Shell Cylinder":	// execute if case matches expression
				//CSCylParNames = {"Prefactor","Radius","Length","SLD","ShellThickness"}
				SetVariable ModelVarPar1 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSCylPar[0][0] ,title="Scale         ", disable=0, limits={-inf,inf,IR3FSetVariableStepRatio*CSCylPar[0][0]}, help={"Scale"}
				SetVariable ModelVarPar2 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSCylPar[1][0] ,title="Radius [A]    ", disable=0, limits={1,inf,IR3FSetVariableStepRatio*CSCylPar[1][0]}, help={"Radius of the cylinder, A"}
				SetVariable ModelVarPar3 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSCylPar[2][0] ,title="Length [A]    ", disable=0, limits={10,inf,IR3FSetVariableStepRatio*CSCylPar[2][0]}, help={"Length of cylinder, A"}
				SetVariable ModelVarPar4 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSCylPar[3][0] ,title="Δ SLD [10^10cm^-2]", disable=0, limits={0.01,inf,IR3FSetVariableStepRatio*CSCylPar[3][0]}, help={"SLD of core (NOT dRho^2)"}
				SetVariable ModelVarPar5 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSCylPar[4][0] ,title="Shell Thick [A]", disable=0, limits={0.01,inf,IR3FSetVariableStepRatio*CSCylPar[4][0]}, help={"Thickenss of shell in A"}
				SetVariable ModelVarPar6 win=IR3F_CylinderModelsPanel, disable=1, noedit=0
				SetVariable ModelVarPar7 win=IR3F_CylinderModelsPanel, disable=1, noedit=0

				CheckBox FitModelVarPar1 win=IR3F_CylinderModelsPanel,value= CSCylPar[0][1], disable=0 	//variable= root:Packages:Irena:CylinderModels:FitDBPrefactor, disable=1
				CheckBox FitModelVarPar2 win=IR3F_CylinderModelsPanel,value= CSCylPar[1][1], disable=0
				CheckBox FitModelVarPar3 win=IR3F_CylinderModelsPanel,value= CSCylPar[2][1], disable=1
				CheckBox FitModelVarPar4 win=IR3F_CylinderModelsPanel,value= CSCylPar[3][1], disable=0
				CheckBox FitModelVarPar5 win=IR3F_CylinderModelsPanel,value= CSCylPar[4][1], disable=0
				CheckBox FitModelVarPar6 win=IR3F_CylinderModelsPanel,disable=1
				CheckBox FitModelVarPar7 win=IR3F_CylinderModelsPanel,disable=1

				Button ModelButton1 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1
				Button ModelButton2 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1
				Button ModelButton3 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1

				SetVariable ModelVarPar1LL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSCylPar[0][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Scale"}
				SetVariable ModelVarPar1UL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSCylPar[0][3] ,title="< Scale < ", disable=0, limits={0.01,inf,0}, help={"High limit for Scale"}
				
				SetVariable ModelVarPar2LL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSCylPar[1][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Radius"}
				SetVariable ModelVarPar2UL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSCylPar[1][3] ,title="< Rad < ", disable=0, limits={0.01,inf,0}, help={"High limit for Radius"}
				
				SetVariable ModelVarPar3LL win=IR3F_CylinderModelsPanel,disable=1
				SetVariable ModelVarPar3UL win=IR3F_CylinderModelsPanel,disable=1
				
				SetVariable ModelVarPar4LL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSCylPar[3][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for SLD"}
				SetVariable ModelVarPar4UL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSCylPar[3][3] ,title="< ΔSLD < ", disable=0, limits={0.01,inf,0}, help={"High limit for SLD"}
				
				SetVariable ModelVarPar5LL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:CSCylPar[4][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Shell Thickness"}
				SetVariable ModelVarPar5UL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:CSCylPar[4][3] ,title="< ShTh < ", disable=0, limits={0.01,inf,0}, help={"High limit for Shell Thickness"}
				
				SetVariable ModelVarPar6LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar6UL win=IR3F_CylinderModelsPanel, disable=1
				
				SetVariable ModelVarPar7LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar7UL win=IR3F_CylinderModelsPanel, disable=1
				break		// exit from switch

			case "Ellip. Cylinder":	// execute if case matches expression
				//ElCylParNames = {"Prefactor","Radius","Length","SLD","AspectRatio"}
				SetVariable ModelVarPar1 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ElCylPar[0][0] ,title="Scale         ", disable=0, limits={-inf,inf,IR3FSetVariableStepRatio*ElCylPar[0][0]}, help={"Scale"}
				SetVariable ModelVarPar2 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ElCylPar[1][0] ,title="Radius [A]    ", disable=0, limits={1,inf,IR3FSetVariableStepRatio*ElCylPar[1][0]}, help={"Radius of the cylinder, A"}
				SetVariable ModelVarPar3 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ElCylPar[2][0] ,title="Length [A]    ", disable=0, limits={10,inf,IR3FSetVariableStepRatio*ElCylPar[2][0]}, help={"Length of cylinder, A"}
				SetVariable ModelVarPar4 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ElCylPar[3][0] ,title="Δ SLD [10^10cm^-2]", disable=0, limits={0.01,inf,IR3FSetVariableStepRatio*ElCylPar[3][0]}, help={"SLD of core (NOT dRho^2)"}
				SetVariable ModelVarPar5 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ElCylPar[4][0] ,title="Aspect Ratio  ", disable=0, limits={0.01,inf,IR3FSetVariableStepRatio*ElCylPar[4][0]}, help={"Aspect Ratio, 0.5 - 2"}
				SetVariable ModelVarPar6 win=IR3F_CylinderModelsPanel, disable=1, noedit=0
				SetVariable ModelVarPar7 win=IR3F_CylinderModelsPanel, disable=1, noedit=0

				CheckBox FitModelVarPar1 win=IR3F_CylinderModelsPanel,value= ElCylPar[0][1], disable=0 	//variable= root:Packages:Irena:CylinderModels:FitDBPrefactor, disable=1
				CheckBox FitModelVarPar2 win=IR3F_CylinderModelsPanel,value= ElCylPar[1][1], disable=0
				CheckBox FitModelVarPar3 win=IR3F_CylinderModelsPanel,value= ElCylPar[2][1], disable=1
				CheckBox FitModelVarPar4 win=IR3F_CylinderModelsPanel,value= ElCylPar[3][1], disable=0
				CheckBox FitModelVarPar5 win=IR3F_CylinderModelsPanel,value= ElCylPar[4][1], disable=0
				CheckBox FitModelVarPar6 win=IR3F_CylinderModelsPanel,disable=1
				CheckBox FitModelVarPar7 win=IR3F_CylinderModelsPanel,disable=1

				Button ModelButton1 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1
				Button ModelButton2 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1
				Button ModelButton3 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1

				SetVariable ModelVarPar1LL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ElCylPar[0][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Scale"}
				SetVariable ModelVarPar1UL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ElCylPar[0][3] ,title="< Scale < ", disable=0, limits={0.01,inf,0}, help={"High limit for Scale"}
				
				SetVariable ModelVarPar2LL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ElCylPar[1][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Radius"}
				SetVariable ModelVarPar2UL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ElCylPar[1][3] ,title="< Rad < ", disable=0, limits={0.01,inf,0}, help={"High limit for Radius"}
				
				SetVariable ModelVarPar3LL win=IR3F_CylinderModelsPanel,disable=1
				SetVariable ModelVarPar3UL win=IR3F_CylinderModelsPanel,disable=1
				
				SetVariable ModelVarPar4LL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ElCylPar[3][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for SLD"}
				SetVariable ModelVarPar4UL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ElCylPar[3][3] ,title="< ΔSLD < ", disable=0, limits={0.01,inf,0}, help={"High limit for SLD"}
				
				SetVariable ModelVarPar5LL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:ElCylPar[4][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for AspectRatio"}
				SetVariable ModelVarPar5UL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:ElCylPar[4][3] ,title="< AR < ", disable=0, limits={0.01,inf,0}, help={"High limit for AspectRatio"}
				
				SetVariable ModelVarPar6LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar6UL win=IR3F_CylinderModelsPanel, disable=1
				
				SetVariable ModelVarPar7LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar7UL win=IR3F_CylinderModelsPanel, disable=1
				break		// exit from switch

			case "Core Shell Ellip. Cylinder":	// execute if case matches expression
				//CSCSElCylParNames = 		{"Prefactor","Radius","Length","SLD","ShellThickness","AspectRatio"}
				SetVariable ModelVarPar1 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSElCylPar[0][0] ,title="Scale         ", disable=0, limits={-inf,inf,IR3FSetVariableStepRatio*CSElCylPar[0][0]}, help={"Scale"}
				SetVariable ModelVarPar2 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSElCylPar[1][0] ,title="Radius [A]    ", disable=0, limits={1,inf,IR3FSetVariableStepRatio*CSElCylPar[1][0]}, help={"Radius of the cylinder, A"}
				SetVariable ModelVarPar3 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSElCylPar[2][0] ,title="Length [A]    ", disable=0, limits={10,inf,IR3FSetVariableStepRatio*CSElCylPar[2][0]}, help={"Length of cylinder, A"}
				SetVariable ModelVarPar4 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSElCylPar[3][0] ,title="Δ SLD [10^10cm^-2]", disable=0, limits={0.01,inf,IR3FSetVariableStepRatio*CSElCylPar[3][0]}, help={"SLD of core (NOT dRho^2)"}
				SetVariable ModelVarPar5 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSElCylPar[4][0] ,title="Shell Thick [A]", disable=0, limits={0.01,inf,IR3FSetVariableStepRatio*CSElCylPar[4][0]}, help={"Shell Thick[A]"}
				SetVariable ModelVarPar6 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSElCylPar[5][0] ,title="Aspect Ratio  ", disable=0, limits={0.01,inf,IR3FSetVariableStepRatio*CSElCylPar[5][0]}, help={"Aspect Ratio, 0.5 - 2"}
				SetVariable ModelVarPar7 win=IR3F_CylinderModelsPanel, disable=1, noedit=0

				CheckBox FitModelVarPar1 win=IR3F_CylinderModelsPanel,value= CSElCylPar[0][1], disable=0 	//variable= root:Packages:Irena:CylinderModels:FitDBPrefactor, disable=1
				CheckBox FitModelVarPar2 win=IR3F_CylinderModelsPanel,value= CSElCylPar[1][1], disable=0
				CheckBox FitModelVarPar3 win=IR3F_CylinderModelsPanel,value= CSElCylPar[2][1], disable=1
				CheckBox FitModelVarPar4 win=IR3F_CylinderModelsPanel,value= CSElCylPar[3][1], disable=0
				CheckBox FitModelVarPar5 win=IR3F_CylinderModelsPanel,value= CSElCylPar[4][1], disable=0
				CheckBox FitModelVarPar6 win=IR3F_CylinderModelsPanel,value= CSElCylPar[5][1], disable=0
				CheckBox FitModelVarPar7 win=IR3F_CylinderModelsPanel,disable=1

				Button ModelButton1 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1
				Button ModelButton2 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1
				Button ModelButton3 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1

				SetVariable ModelVarPar1LL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSElCylPar[0][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Scale"}
				SetVariable ModelVarPar1UL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSElCylPar[0][3] ,title="< Scale < ", disable=0, limits={0.01,inf,0}, help={"High limit for Scale"}
				
				SetVariable ModelVarPar2LL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSElCylPar[1][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Radius"}
				SetVariable ModelVarPar2UL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSElCylPar[1][3] ,title="< Rad < ", disable=0, limits={0.01,inf,0}, help={"High limit for Radius"}
				
				SetVariable ModelVarPar3LL win=IR3F_CylinderModelsPanel,disable=1
				SetVariable ModelVarPar3UL win=IR3F_CylinderModelsPanel,disable=1
				
				SetVariable ModelVarPar4LL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSElCylPar[3][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for SLD"}
				SetVariable ModelVarPar4UL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:CSElCylPar[3][3] ,title="< Δ SLD < ", disable=0, limits={0.01,inf,0}, help={"High limit for SLD"}
				
				SetVariable ModelVarPar5LL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:CSElCylPar[4][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Shell Thickness"}
				SetVariable ModelVarPar5UL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:CSElCylPar[4][3] ,title="< ShTh < ", disable=0, limits={0.01,inf,0}, help={"High limit for Shell Thickness"}
				
				SetVariable ModelVarPar6LL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:CSElCylPar[5][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for AspectRatio"}
				SetVariable ModelVarPar6UL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:CSElCylPar[5][3] ,title="< AR < ", disable=0, limits={0.01,inf,0}, help={"High limit for AspectRatio"}
				
				SetVariable ModelVarPar7LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar7UL win=IR3F_CylinderModelsPanel, disable=1
				break		// exit from switch

			case "Profile CS Ellip. Cylinder":	// execute if case matches expression
				//ProfProfCSElCylParNames = {"Prefactor","Radius","Length","AspectRatio","Shell1Th","Shell1SLD", "Shell2th", "Shell2SLD"}
				SetVariable ModelVarPar1 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[0][0] ,title="Scale         ", disable=0, limits={-inf,inf,IR3FSetVariableStepRatio*ProfCSElCylPar[0][0]}, help={"Scale"}
				SetVariable ModelVarPar2 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[1][0] ,title="Radius [A]    ", disable=0, limits={1,inf,1}, help={"Radius of the cylinder, A"}
				SetVariable ModelVarPar3 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[2][0] ,title="Length [A]    ", disable=0, limits={10,inf,IR3FSetVariableStepRatio*ProfCSElCylPar[2][0]}, help={"Length of cylinder, A"}
				SetVariable ModelVarPar4 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[3][0] ,title="Aspect Ratio  ", disable=0, limits={0.01,inf,IR3FSetVariableStepRatio*ProfCSElCylPar[5][0]}, help={"Aspect Ratio, 0.5 - 2"}
				
				SetVariable ModelVarPar5 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[4][0] ,title="Shell 1 Thick [A]", disable=0, limits={0.01,inf,1}, help={"Shell Thick[A]"}
				SetVariable ModelVarPar6 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[5][0] ,title="Δ SLD 1 [10^10cm^-2]", disable=0, limits={-inf,inf,IR3FSetVariableStepRatio*ProfCSElCylPar[3][0]}, help={"SLD of shell 1 (NOT dRho^2)"}
				SetVariable ModelVarPar7 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[6][0] ,title="Shell 2 Thick [A]", disable=0, limits={0.01,inf,1}, help={"Shell Thick[A]"}
				SetVariable ModelVarPar8 win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[7][0] ,title="Δ SLD 2 [10^10cm^-2]", disable=0, limits={-inf,inf,IR3FSetVariableStepRatio*ProfCSElCylPar[3][0]}, help={"SLD of shell 2 (NOT dRho^2)"}

				CheckBox FitModelVarPar1 win=IR3F_CylinderModelsPanel,value= ProfCSElCylPar[0][1], disable=0 	//variable= root:Packages:Irena:CylinderModels:FitDBPrefactor, disable=1
				CheckBox FitModelVarPar2 win=IR3F_CylinderModelsPanel,value= ProfCSElCylPar[1][1], disable=0
				CheckBox FitModelVarPar3 win=IR3F_CylinderModelsPanel,value= ProfCSElCylPar[2][1], disable=1
				CheckBox FitModelVarPar4 win=IR3F_CylinderModelsPanel,value= ProfCSElCylPar[3][1], disable=0
				CheckBox FitModelVarPar5 win=IR3F_CylinderModelsPanel,value= ProfCSElCylPar[4][1], disable=0
				CheckBox FitModelVarPar6 win=IR3F_CylinderModelsPanel,value= ProfCSElCylPar[5][1], disable=0
				CheckBox FitModelVarPar7 win=IR3F_CylinderModelsPanel,value= ProfCSElCylPar[6][1], disable=0
				CheckBox FitModelVarPar8 win=IR3F_CylinderModelsPanel,value= ProfCSElCylPar[7][1], disable=0

				Button ModelButton1 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1
				Button ModelButton2 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1
				Button ModelButton3 win=IR3F_CylinderModelsPanel, title="", help={""}, disable=1

				SetVariable ModelVarPar1LL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[0][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Scale"}
				SetVariable ModelVarPar1UL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[0][3] ,title="< Scale < ", disable=0, limits={0.01,inf,0}, help={"High limit for Scale"}
				
				SetVariable ModelVarPar2LL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[1][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Radius"}
				SetVariable ModelVarPar2UL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[1][3] ,title="< Rad < ", disable=0, limits={0.01,inf,0}, help={"High limit for Radius"}
				
				SetVariable ModelVarPar3LL win=IR3F_CylinderModelsPanel,disable=1
				SetVariable ModelVarPar3UL win=IR3F_CylinderModelsPanel,disable=1
				
				SetVariable ModelVarPar4LL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[3][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for SLD"}
				SetVariable ModelVarPar4UL win=IR3F_CylinderModelsPanel,value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[3][3] ,title="< AR < ", disable=0, limits={0.01,inf,0}, help={"High limit for SLD"}
				
				SetVariable ModelVarPar5LL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[4][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Shell 1 Thickness"}
				SetVariable ModelVarPar5UL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[4][3] ,title="< Sh1Th < ", disable=0, limits={1,inf,0}, help={"High limit for Shell 1 Thickness"}
				
				SetVariable ModelVarPar6LL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[5][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for SLD 1"}
				SetVariable ModelVarPar6UL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[5][3] ,title="< ΔSLD 1 < ", disable=0, limits={0.0001,inf,0}, help={"High limit for SLD 1"}
				
				SetVariable ModelVarPar7LL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[6][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for Shell 1 Thickness"}
				SetVariable ModelVarPar7UL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[6][3] ,title="< Sh2Th < ", disable=0, limits={1,inf,0}, help={"High limit for Shell 2 Thickness"}

				SetVariable ModelVarPar8LL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[5][2] ,title=" ", disable=0, limits={0.01,inf,0}, help={"Lower limit for SLD 2"}
				SetVariable ModelVarPar8UL win=IR3F_CylinderModelsPanel, value=root:Packages:Irena:CylinderModels:ProfCSElCylPar[5][3] ,title="< ΔSLD 2 < ", disable=0, limits={0.0001,inf,0}, help={"High limit for SLD 2"}

				SetVariable ProfileMaxX win=IR3F_CylinderModelsPanel, disable=0
				CheckBox UseGMatrixCalculations win=IR3F_CylinderModelsPanel, disable=0

				break		// exit from switch

			
			default:			// optional default expression executed
							
				SetVariable ModelVarPar1 win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar2 win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar3 win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar4 win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar5 win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar6 win=IR3F_CylinderModelsPanel, disable=1
				CheckBox FitModelVarPar1 win=IR3F_CylinderModelsPanel, disable=1
				CheckBox FitModelVarPar2 win=IR3F_CylinderModelsPanel, disable=1
				CheckBox FitModelVarPar3 win=IR3F_CylinderModelsPanel, disable=1
				CheckBox FitModelVarPar4 win=IR3F_CylinderModelsPanel, disable=1
				CheckBox FitModelVarPar5 win=IR3F_CylinderModelsPanel, disable=1
				CheckBox FitModelVarPar6 win=IR3F_CylinderModelsPanel, disable=1
				CheckBox FitModelVarPar7 win=IR3F_CylinderModelsPanel,disable=1
				SetVariable ModelVarPar7 win=IR3F_CylinderModelsPanel, disable=1, noedit=0
				CheckBox FitModelVarPar8 win=IR3F_CylinderModelsPanel,disable=1
				SetVariable ModelVarPar8 win=IR3F_CylinderModelsPanel, disable=1, noedit=0
				Button ModelButton1 win=IR3F_CylinderModelsPanel, disable=1
				Button ModelButton2 win=IR3F_CylinderModelsPanel, disable=1
				Button ModelButton3 win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar1LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar1UL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar2LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar2UL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar3LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar3UL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar4LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar4UL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar5LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar5UL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar6LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar6UL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar7LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar7UL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar8LL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ModelVarPar8UL win=IR3F_CylinderModelsPanel, disable=1
				SetVariable ProfileMaxX win=IR3F_CylinderModelsPanel, disable=1
				CheckBox UseGMatrixCalculations win=IR3F_CylinderModelsPanel, disable=1
				
		endswitch
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3F_MainPanelCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(StringMatch(cba.ctrlName, "UseUnified" ))
				IR3F_SetupControlsOnMainpanel()
				IR3F_AutoRecalculateModelData(0)				
			endif
			if(StringMatch(cba.ctrlName, "RecalculateAutomatically" ))
				IR3F_AutoRecalculateModelData(0)
			endif
			if(StringMatch(cba.ctrlName, "HideTagsAlways" ))
				IR3F_AttachTags(1)
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR3F_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"ModelButton1"))
				//do something...
				//likely not this: IR3F_AutoRecalculateModelData()
					//SVAR ModelSelected = root:Packages:Irena:CylinderModels:ModelSelected
			endif
			if(stringmatch(ba.ctrlName,"FitAllSelected"))
			//	IR3F_FitSequenceOfData()
			endif
			if(stringmatch(ba.ctrlName,"FitModel"))
				IR3F_FitCSCylinderModel()	
				IR3F_AttachTags(1)
			endif
			if(stringmatch(ba.ctrlName,"EstimateUF"))
				//fit power law between cursors...
				//IR3F_EstimateLowQslope()	
			endif
			if(stringmatch(ba.ctrlName,"SaveResults"))
				NVAR SaveToNotebook=root:Packages:Irena:CylinderModels:SaveToNotebook
				NVAR SaveToWaves=root:Packages:Irena:CylinderModels:SaveToWaves
				NVAR SaveToFolder=root:Packages:Irena:CylinderModels:SaveToFolder
				if(SaveToNotebook+SaveToWaves+SaveToFolder<1)
					Abort "Nothing is selected to Record, check at least on checkbox above" 
				endif	
				IR3F_SaveResultsToNotebook()
				//IR3F_SaveResultsToWaves()
				//IR3F_SaveResultsToFolder(0)
			endif

			string ParamName
			if(stringmatch(ba.ctrlName,"ReverseFit"))
				Wave/Z BackupFitValues = root:Packages:Irena:CylinderModels:BackupFitValues
				Wave/Z/T CoefNames = root:Packages:Irena:CylinderModels:CoefNames
				variable i
				if(WaveExists(BackupFitValues)&&WaveExists(CoefNames))
					for (i=0;i<numpnts(CoefNames);i+=1)
					ParamName=StringFromList(0,CoefNames[i],";")
					if(StringMatch(ParamName, "SASBackground" ))
						NVAR SASBackground = root:Packages:Irena:CylinderModels:SASBackground
						SASBackground = BackupFitValues[i]
					else
						Wave TempParam=$("root:Packages:Irena:CylinderModels:"+ParamName)
						TempParam[str2num(StringFromList(1,CoefNames[i],";"))][0]=BackupFitValues[i]	
					endif
					endfor
				endif
				IR3F_AutoRecalculateModelData(1)
			endif

			if(stringmatch(ba.ctrlName,"RecalculateModel"))
				IR3F_AutoRecalculateModelData(1)
				IR3F_AttachTags(1)
			endif
			if(stringmatch(ba.ctrlName,"SelectAll"))
				Wave/Z SelectionOfAvailableData = root:Packages:Irena:CylinderModels:SelectionOfAvailableData
				if(WaveExists(SelectionOfAvailableData))
					SelectionOfAvailableData=1
				endif
			endif

			if(stringmatch(ba.ctrlName,"GetHelp"))
			//	IN2G_OpenWebManual("Irena/CylinderModels.html")				//fix me!!	
			DoAlert /T="Unifinshed" 0, "Write manual page as CylinderModels.html and link it here"		
			endif			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**************************************************************************************

Function IR3F_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	variable tempP
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
			NVAR DataQstart=root:Packages:Irena:CylinderModels:DataQstart
			NVAR DataQEnd=root:Packages:Irena:CylinderModels:DataQEnd
			NVAR DataQEndPoint = root:Packages:Irena:CylinderModels:DataQEndPoint
			NVAR DataQstartPoint = root:Packages:Irena:CylinderModels:DataQstartPoint
			variable Indx
			
			if(stringmatch(sva.ctrlName,"DataQEnd"))
				WAVE OriginalDataQWave = root:Packages:Irena:CylinderModels:OriginalDataQWave
				tempP = BinarySearch(OriginalDataQWave, DataQEnd )
				if(tempP<1)
					print "Wrong Q value set, Data Q max must be at most 1 point before the end of Data"
					tempP = numpnts(OriginalDataQWave)-2
					DataQEnd = OriginalDataQWave[tempP]
				endif
				DataQEndPoint = tempP			
				IR3F_SyncCursorsTogether("OriginalDataIntWave","B",tempP)
				IR3F_SyncCursorsTogether("LinModelDataIntWave","B",tempP)
			endif
			if(stringmatch(sva.ctrlName,"DataQstart"))
				WAVE OriginalDataQWave = root:Packages:Irena:CylinderModels:OriginalDataQWave
				tempP = BinarySearch(OriginalDataQWave, DataQstart )
				if(tempP<1)
					print "Wrong Q value set, Data Q min must be at least 1 point from the start of Data"
					tempP = 1
					DataQstart = OriginalDataQWave[tempP]
				endif
				DataQstartPoint=tempP
				//IR3F_SyncCursorsTogether("OriginalDataIntWave","A",tempP)
				//IR3F_SyncCursorsTogether("LinModelDataIntWave","A",tempP)
			endif
			if(stringmatch(sva.ctrlName,"ModelVarPar*"))
				// 1 	change step t0 fraction of value
				// 2 	change limits for the variable... 
				// 3	recalculate 
				if(StringMatch(sva.vName, "ProfCSElCylPar[1]")||StringMatch(sva.vName, "ProfCSElCylPar[4]")||StringMatch(sva.vName, "ProfCSElCylPar[6]"))	//this is for Profile radius and shell thicknesses, small steps make no sense. 1A resolution needed
					SetVariable $(sva.ctrlName) win=IR3F_CylinderModelsPanel,limits={1 ,inf,1} 
				elseif(StringMatch(sva.vName, "ProfCSElCylPar[7]")||StringMatch(sva.vName, "ProfCSElCylPar[5]"))	//this is for Profile shell dSLD, need negative values
					SetVariable $(sva.ctrlName) win=IR3F_CylinderModelsPanel,limits={-inf ,inf,abs(IR3FSetVariableStepRatio*sva.dval)} 
				else
					SetVariable $(sva.ctrlName) win=IR3F_CylinderModelsPanel,limits={0 ,inf,abs(IR3FSetVariableStepRatio*sva.dval)} 
				endif
//				// sva.vName contains name of variable
				Wave/Z CntrlWv=sva.svwave
				Indx = str2num(stringFromList(1,sva.vName,"["))			//Wname[0]
				if(WaveExists(CntrlWv))
					CntrlWv[Indx][2] = sva.dval * IR3FSetVariableLowLimRatio
					CntrlWv[Indx][3] = sva.dval * IR3FSetVariableHighLimRatio
				endif
				IR3F_AutoRecalculateModelData(0)
			endif
			if(stringmatch(sva.ctrlName,"UnifG"))
//				Wave UnifiedPar = root:Packages:Irena:CylinderModels:UnifiedPar
//				//NVAR UnifRg = root:Packages:Irena:CylinderModels:UnifRg
//				//NVAR UnifG = root:Packages:Irena:CylinderModels:UnifG
//				if(UnifiedPar[0][0]==0)
//					UnifiedPar[1][0]=1e10
//				endif
			endif
			if(stringmatch(sva.ctrlName,"UnifRg")||stringmatch(sva.ctrlName,"SASBackground") )
				SetVariable $(sva.ctrlName) win=IR3F_CylinderModelsPanel,limits={0,inf,IR3FSetVariableStepRatio*sva.dval} 
				Wave/Z CntrlWv=sva.svwave
				Indx = str2num(stringFromList(1,sva.vName,"["))			//Wname[0]
				if(WaveExists(CntrlWv))
					CntrlWv[Indx][2] = sva.dval * IR3FSetVariableLowLimRatio
					CntrlWv[Indx][3] = sva.dval * IR3FSetVariableHighLimRatio
				endif
				IR3F_AutoRecalculateModelData(0)
			endif
		
			break
		case 3: // live update
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//**********************************************************************************************************
//**********************************************************************************************************
//**************************************************************************************
//**************************************************************************************
Function IR3F_CopyAndAppendData(FolderNameStr)
	string FolderNameStr
	
	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:Irena:CylinderModels					//go into the folder
		SVAR DataStartFolder=root:Packages:Irena:CylinderModels:DataStartFolder
		SVAR DataFolderName=root:Packages:Irena:CylinderModels:DataFolderName
		SVAR IntensityWaveName=root:Packages:Irena:CylinderModels:IntensityWaveName
		SVAR QWavename=root:Packages:Irena:CylinderModels:QWavename
		SVAR ErrorWaveName=root:Packages:Irena:CylinderModels:ErrorWaveName
		SVAR dQWavename=root:Packages:Irena:CylinderModels:dQWavename
		NVAR UseIndra2Data=root:Packages:Irena:CylinderModels:UseIndra2Data
		NVAR UseQRSdata=root:Packages:Irena:CylinderModels:UseQRSdata
		//these are variables used by the control procedure
		NVAR  UseResults=  root:Packages:Irena:CylinderModels:UseResults
		NVAR  UseUserDefinedData=  root:Packages:Irena:CylinderModels:UseUserDefinedData
		NVAR  UseModelData = root:Packages:Irena:CylinderModels:UseModelData
		SVAR DataFolderName  = root:Packages:Irena:CylinderModels:DataFolderName 
		SVAR IntensityWaveName = root:Packages:Irena:CylinderModels:IntensityWaveName
		SVAR QWavename = root:Packages:Irena:CylinderModels:QWavename
		SVAR ErrorWaveName = root:Packages:Irena:CylinderModels:ErrorWaveName
		UseUserDefinedData = 0
		UseModelData = 0
		//get the names of waves, assume this tool actually works. May not under some conditions. In that case this tool will not work. 
		IR3C_SelectWaveNamesData("Irena:CylinderModels", FolderNameStr)			//this routine will preset names in strings as needed,		
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
			Abort "Data selection failed for System Specific Models routine IR3F_CopyAndAppendData"
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
		NVAR SlitLength=  root:Packages:Irena:CylinderModels:SlitLength
		NVAR UseSlitSmearedData=  root:Packages:Irena:CylinderModels:UseSlitSmearedData
		if(UseIndra2Data && StringMatch(IntensityWaveName, "*SMR*" ))
			UseSlitSmearedData = 1
			string oldNote=Note(SourceIntWv)
			SlitLength = NumberByKey("SlitLength", oldNote, "=" , ";")
		else
			UseSlitSmearedData=0
		endif
		
		//IR3F_RecoverParameters()	
		IR3F_CreateCylinderModelsGraphs()
		pauseUpdate
		IR3F_AppendDataToGraphLogLog()
		IR3F_AutoRecalculateModelData(0)
		DoUpdate
		print "Added Data from folder : "+DataFolderName
	SetDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
static Function IR3F_CreateCylinderModelsGraphs()
	
	variable exists1=0
	DoWIndow IR3F_LogLogDataDisplay
	if(V_Flag)
		DoWIndow/hide=? IR3F_LogLogDataDisplay
		if(V_Flag==2)
			DoWIndow/F IR3F_LogLogDataDisplay
		endif
	else
		Display /W=(521,10,1383,750)/K=1 /N=IR3F_LogLogDataDisplay
		ShowInfo/W=IR3F_LogLogDataDisplay
		exists1=1
	endif
	AutoPositionWindow/M=0/R=IR3F_CylinderModelsPanel IR3F_LogLogDataDisplay	
	
	SVAR FittingPower= root:Packages:Irena:CylinderModels:FittingPower
	//"Int;I*Q;I*Q^2;I*Q^3;I*Q^4;
	if(StringMatch(FittingPower, "Int" ))
		KillWIndow/Z IR3F_FittingDataDisplay
	else
		KillWIndow/Z IR3F_FittingDataDisplay
		//DoWIndow IR3F_FittingDataDisplay
		//if(!V_Flag)
		Display /W=(521,10,1383,750)/K=1 /N=IR3F_FittingDataDisplay
		ShowInfo/W=IR3F_FittingDataDisplay
		//endif	
		AutoPositionWindow/M=0/R=IR3F_LogLogDataDisplay IR3F_FittingDataDisplay
	endif
	
	
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


static Function IR3F_AppendDataToGraphLogLog()
	
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Irena:CylinderModels:
	IR3F_CreateCylinderModelsGraphs()
	variable WhichLegend=0
	string Shortname1
	Wave/Z OriginalDataIntWave=root:Packages:Irena:CylinderModels:OriginalDataIntWave
	if(!WaveExists(OriginalDataIntWave))
		return 0
	endif
	Wave OriginalDataQWave=root:Packages:Irena:CylinderModels:OriginalDataQWave
	Wave OriginalDataErrorWave=root:Packages:Irena:CylinderModels:OriginalDataErrorWave
	CheckDisplayed /W=IR3F_LogLogDataDisplay OriginalDataIntWave
	if(!V_flag)
		AppendToGraph /W=IR3F_LogLogDataDisplay  OriginalDataIntWave  vs OriginalDataQWave
		ModifyGraph /W=IR3F_LogLogDataDisplay log=1, mirror=1
		Label /W=IR3F_LogLogDataDisplay left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
		Label /W=IR3F_LogLogDataDisplay bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q[A\\S-1\\M"+"\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
		ErrorBars /W=IR3F_LogLogDataDisplay OriginalDataIntWave Y,wave=(OriginalDataErrorWave,OriginalDataErrorWave)		
	endif
	removeFromGraph /Z /W=IR3F_LogLogDataDisplay ModelIntensity, Residuals
	NVAR DataQEnd = root:Packages:Irena:CylinderModels:DataQEnd
	NVAR DataQstart = root:Packages:Irena:CylinderModels:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:CylinderModels:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:CylinderModels:DataQstartPoint
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
	//SetWindow IR3F_LogLogDataDisplay, hook(DM3LogCursorMoved) = $""
	cursor /W=IR3F_LogLogDataDisplay B, OriginalDataIntWave, DataQEndPoint
	cursor /W=IR3F_LogLogDataDisplay A, OriginalDataIntWave, DataQstartPoint
	//SetWindow IR3F_LogLogDataDisplay, hook(CylinderModelsLogCursorMoved) = IR3F_GraphWindowHook

	SVAR DataFolderName=root:Packages:Irena:CylinderModels:DataFolderName
	Shortname1 = StringFromList(ItemsInList(DataFolderName, ":")-1, DataFolderName  ,":")
	Legend/W=IR3F_LogLogDataDisplay /C/N=text0/J/A=LB "\\s(OriginalDataIntWave) "+Shortname1
	
	SVAR FittingPower= root:Packages:Irena:CylinderModels:FittingPower
	//"Int;I*Q;I*Q^2;I*Q^3;I*Q^4;
	if(!StringMatch(FittingPower, "Int"))
		strswitch(FittingPower)
			case "Int":
			
			case "I*Q":
				Duplicate/O OriginalDataIntWave, IntWaveQ
				Duplicate/O OriginalDataErrorWave, ErrWaveQ
				IntWaveQ = OriginalDataIntWave*OriginalDataQWave
				ErrWaveQ = OriginalDataErrorWave*OriginalDataQWave
				AppendToGraph /W=IR3F_FittingDataDisplay  IntWaveQ vs OriginalDataQWave
				ModifyGraph /W=IR3F_FittingDataDisplay mode=3
				ErrorBars /W=IR3F_FittingDataDisplay IntWaveQ Y,wave=(ErrWaveQ,ErrWaveQ)
				break
			case "I*Q^2":
				Duplicate/O OriginalDataIntWave, IntWaveQ2
				Duplicate/O OriginalDataErrorWave, ErrWaveQ2
				IntWaveQ2 = OriginalDataIntWave*OriginalDataQWave^2
				ErrWaveQ2 = OriginalDataErrorWave*OriginalDataQWave^2
				AppendToGraph /W=IR3F_FittingDataDisplay  IntWaveQ2 vs OriginalDataQWave
				ModifyGraph /W=IR3F_FittingDataDisplay mode=3
				ErrorBars /W=IR3F_FittingDataDisplay IntWaveQ2 Y,wave=(ErrWaveQ2,ErrWaveQ2)
				break
			case "I*Q^3":
				Duplicate/O OriginalDataIntWave, IntWaveQ3
				Duplicate/O OriginalDataErrorWave, ErrWaveQ3
				IntWaveQ3 = OriginalDataIntWave*OriginalDataQWave^3
				ErrWaveQ3 = OriginalDataErrorWave*OriginalDataQWave^3
				AppendToGraph /W=IR3F_FittingDataDisplay  IntWaveQ3 vs OriginalDataQWave
				ModifyGraph /W=IR3F_FittingDataDisplay mode=3
				ErrorBars /W=IR3F_FittingDataDisplay IntWaveQ3 Y,wave=(ErrWaveQ3,ErrWaveQ3)
				break
			case "I*Q^4":
				Duplicate/O OriginalDataIntWave, IntWaveQ4
				Duplicate/O OriginalDataErrorWave, ErrWaveQ4
				IntWaveQ4 = OriginalDataIntWave*OriginalDataQWave^4
				ErrWaveQ4 = OriginalDataErrorWave*OriginalDataQWave^4
				AppendToGraph /W=IR3F_FittingDataDisplay /W=IR3F_FittingDataDisplay  IntWaveQ4 vs OriginalDataQWave
				ModifyGraph /W=IR3F_FittingDataDisplay mode=3
				ErrorBars IntWaveQ4 Y,wave=(ErrWaveQ4,ErrWaveQ4)
				break
		endswitch
	
	endif
	setDataFolder OldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3F_SyncCursorsTogether(traceName,CursorName,PointNumber)
	string traceName,CursorName
	variable PointNumber

	//IR3F_CreateCylinderModelsGraphs()
	NVAR DataQEnd = root:Packages:Irena:CylinderModels:DataQEnd
	NVAR DataQstart = root:Packages:Irena:CylinderModels:DataQstart
	NVAR DataQEndPoint = root:Packages:Irena:CylinderModels:DataQEndPoint
	NVAR DataQstartPoint = root:Packages:Irena:CylinderModels:DataQstartPoint
	Wave OriginalDataQWave=root:Packages:Irena:CylinderModels:OriginalDataQWave
	Wave OriginalDataIntWave=root:Packages:Irena:CylinderModels:OriginalDataIntWave
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
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3F_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(StringMatch(pa.ctrlName, "ModelSelected" ))
				SVAR ModelSelected = root:Packages:Irena:CylinderModels:ModelSelected
				ModelSelected = popStr
				IR3F_CreateCylinderModelsGraphs()
				doUpdate
				IR3F_SetupControlsOnMainpanel()
				IR3F_AutoRecalculateModelData(0)
				IR3F_AppendDataToGraphLogLog()
			endif
			if(StringMatch(pa.ctrlName, "FittingPower" ))
				SVAR FittingPower = root:Packages:Irena:CylinderModels:FittingPower
				FittingPower = popStr
				IR3F_CreateCylinderModelsGraphs()
				IR3F_AppendDataToGraphLogLog()
			endif

			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End



//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR3F_FitCSCylinderModel()

	dfref OldDf
	OldDf=GetDataFolderDFR
	setDataFolder root:Packages:Irena:CylinderModels:
	Make/D/N=0/O W_coef, BackupFitValues
	Make/T/N=0/O CoefNames
	Make/D/O/T/N=0 T_Constraints
	Make/O/N=(0,2) Gen_Constraints
	T_Constraints=""
	CoefNames=""
	variable curLen

	String ListOfVariablesToCheck, FullListOfVariablesToCheck=""
	NVAR FitSASBackground = root:Packages:Irena:CylinderModels:FitSASBackground
	NVAR SASBackground = root:Packages:Irena:CylinderModels:SASBackground
	SVAR ModelSelected = root:Packages:Irena:CylinderModels:ModelSelected

	NVAR UseUnified=root:Packages:Irena:CylinderModels:UseUnified
	NVAR UseSlitSmearedData=root:Packages:Irena:CylinderModels:UseSlitSmearedData
	NVAR SlitLength=root:Packages:Irena:CylinderModels:SlitLength
	NVAR SASBackground=root:Packages:Irena:CylinderModels:SASBackground
	SVAR ModelSelected = root:Packages:Irena:CylinderModels:ModelSelected
	NVAR UseGMatrixCalculations=root:Packages:Irena:CylinderModels:UseGMatrixCalculations

	Wave UnifiedPar = root:Packages:Irena:CylinderModels:UnifiedPar
	//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
	Wave CylPar	 = root:Packages:Irena:CylinderModels:CylPar	
	//CylParNames = {"Prefactor","Radius","Length","SLD"}
	Wave CSCylPar	 = root:Packages:Irena:CylinderModels:CSCylPar	
	//CylParNames = {"Prefactor","Radius","Length","SLD","ShellThickness"}
	Wave ElCylPar	 = root:Packages:Irena:CylinderModels:ElCylPar	
	//ElCylParNames = {"Prefactor","Radius","Length","SLD","AspectRatio"}
	Wave CSElCylPar	 = root:Packages:Irena:CylinderModels:CSElCylPar	
	//CSElCylParNames = 		{"Prefactor","Radius","Length","SLD","ShellThickness","AspectRatio"}
	Wave ProfCSElCylPar= root:Packages:Irena:CylinderModels:ProfCSElCylPar
	//ProfCSElCylParNames = {"Prefactor","Radius","Length","AspectRatio","Shell1Th","Shell1SLD", "Shell2th", "Shell2SLD"}


	variable i
	//reset errrors
	UnifiedPar[][4]=0
	CylPar[][4]=0
	CSCylPar[][4]=0
	ElCylPar[][4]=0
	CSElCylPar[][4]=0
	ProfCSElCylPar[][4]=0

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
		case "Cylinder":	// execute if case matches expression
			Wave CylPar	 = root:Packages:Irena:CylinderModels:CylPar	
			//CylParNames = {"Prefactor","Radius","Length","SLD"}
			For(i=0;i<4;i+=1)	//only first 4 parameters are fittable. 
				if(CylPar[i][1]>0.5)	//fit? 
					curLen = (numpnts(W_coef))
					Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
					W_Coef[curLen]			= CylPar[i][0]
					BackupFitValues[curLen]	=	CylPar[i][0]
					CoefNames[curLen]	  	=   "CylPar;"+num2str(i)+";"
					if(CylPar[i][2]<CylPar[i][0] && CylPar[i][0]<CylPar[i][3])
						Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
						T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CylPar[i][2])}
						T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CylPar[i][3])}		
						//Redimension /N=((curLen+1),2) Gen_Constraints
						//Gen_Constraints[curLen][0] = varMeLL
						//Gen_Constraints[curLen][1] = varMeHL
					endif
				endif
			endfor
			break
		case "Core Shell Cylinder":	// execute if case matches expression
			Wave CSCylPar	 = root:Packages:Irena:CylinderModels:CSCylPar	
			//CSCylParNames = {"Prefactor","Radius","Length","SLD","ShellThickness"}
			For(i=0;i<4;i+=1)	//only first 4 parameters are fittable. 
				if(CSCylPar[i][1]>0.5)	//fit? 
					curLen = (numpnts(W_coef))
					Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
					W_Coef[curLen]			= CSCylPar[i][0]
					BackupFitValues[curLen]	=	CSCylPar[i][0]
					CoefNames[curLen]	  	=   "CSCylPar;"+num2str(i)+";"
					if(CSCylPar[i][2]<CSCylPar[i][0] && CSCylPar[i][0]<CSCylPar[i][3])
						Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
						T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CSCylPar[i][2])}
						T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CSCylPar[i][3])}		
					endif
				endif
			endfor
			break
		case "Ellip. Cylinder":	// execute if case matches expression
			//ElCylParNames = {"Prefactor","Radius","Length","SLD","AspectRatio"}
			Wave ElCylPar	 = root:Packages:Irena:CylinderModels:ElCylPar	
			For(i=0;i<3;i+=1)	//only first 4 parameters are fittable. 
				if(ElCylPar[i][1]>0.5)	//fit? 
					curLen = (numpnts(W_coef))
					Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
					W_Coef[curLen]			= ElCylPar[i][0]
					BackupFitValues[curLen]	=	ElCylPar[i][0]
					CoefNames[curLen]	  	=   "ElCylPar;"+num2str(i)+";"
					if(ElCylPar[i][2]<ElCylPar[i][0] && ElCylPar[i][0]<ElCylPar[i][3])
						Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
						T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(ElCylPar[i][2])}
						T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(ElCylPar[i][3])}		
					endif
				endif
			endfor
			break
		case "Core Shell Ellip. Cylinder":	// execute if case matches expression
			Wave CSElCylPar	 = root:Packages:Irena:CylinderModels:CSElCylPar	
			//CSElCylParNames = 		{"Prefactor","Radius","Length","SLD","ShellThickness","AspectRatio"}
			For(i=0;i<5;i+=1)	//only first 5 parameters are fittable. 
				if(CSElCylPar[i][1]>0.5)	//fit? 
					curLen = (numpnts(W_coef))
					Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
					W_Coef[curLen]			= CSElCylPar[i][0]
					BackupFitValues[curLen]	=	CSElCylPar[i][0]
					CoefNames[curLen]	  	=   "CSElCylPar;"+num2str(i)+";"
					if(CSElCylPar[i][2]<CSElCylPar[i][0] && CSElCylPar[i][0]<CSElCylPar[i][3])
						Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
						T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(CSElCylPar[i][2])}
						T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(CSElCylPar[i][3])}		
					endif
				endif
			endfor
			break
		case "Profile CS Ellip. Cylinder":	// execute if case matches expression
			Wave ProfCSElCylPar= root:Packages:Irena:CylinderModels:ProfCSElCylPar
			//ProfCSElCylParNames = {"Prefactor","Radius","Length","AspectRatio","Shell1Th","Shell1SLD", "Shell2th", "Shell2SLD"}
			For(i=0;i<8;i+=1)	// 
				if(ProfCSElCylPar[i][1]>0.5)	//fit? 
					curLen = (numpnts(W_coef))
					Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
					W_Coef[curLen]			= ProfCSElCylPar[i][0]
					BackupFitValues[curLen]	=	ProfCSElCylPar[i][0]
					CoefNames[curLen]	  	=   "ProfCSElCylPar;"+num2str(i)+";"
					if(ProfCSElCylPar[i][2]<ProfCSElCylPar[i][0] && ProfCSElCylPar[i][0]<ProfCSElCylPar[i][3])
						Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
						T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(ProfCSElCylPar[i][2])}
						T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(ProfCSElCylPar[i][3])}		
					endif
				endif
			endfor
			break
	endswitch
//	if(UseUnified)
//		//ListOfVariablesToCheck+="UnifPwrlawP;UnifPwrlawB;UnifRg;UnifG;"
//			//UnifiedParNames = {"G","Rg","B","P","UnifRgCO","LinkUnifRgCO"}
//			For(i=0;i<4;i+=1)	//only first 5 parameters are fittable. 
//				if(UnifiedPar[i][1]>0.5)	//fit? 
//					curLen = (numpnts(W_coef))
//					Redimension /N=(curLen+1) W_coef, CoefNames, BackupFitValues
//					W_Coef[curLen]			= UnifiedPar[i][0]
//					BackupFitValues[curLen]	=	UnifiedPar[i][0]
//					CoefNames[curLen]	  	=   "UnifiedPar;"+num2str(i)+";"
//					if(UnifiedPar[i][2]<UnifiedPar[i][0] && UnifiedPar[i][0]<UnifiedPar[i][3])
//						Redimension /N=(numpnts(T_Constraints)+2) T_Constraints
//						T_Constraints[numpnts(T_Constraints)-2] = {"K"+num2str(numpnts(W_coef)-1)+" > "+num2str(UnifiedPar[i][2])}
//						T_Constraints[numpnts(T_Constraints)-1] = {"K"+num2str(numpnts(W_coef)-1)+" < "+num2str(UnifiedPar[i][3])}		
//					endif
//				endif
//			endfor
//	endif
	
//	For(i=0;i<itemsInList(FullListOfVariablesToCheck);i+=1)
//		NVAR ValError = $(StringFromList(i, FullListOfVariablesToCheck)+"Error")
//		ValError = 0	
//	endfor
	if(numpnts(W_Coef)<1)
		Abort "Nothing to fit" 
	endif
	
	DoWindow /F IR3F_LogLogDataDisplay
	wave/Z OriginalDataIntWave=root:Packages:Irena:CylinderModels:OriginalDataIntWave
	if(!WaveExists(OriginalDataIntWave))//wave does not exist, user probably did not create data yet.
		abort
	endif
	Wave OriginalDataQWave=root:Packages:Irena:CylinderModels:OriginalDataQWave
	Wave OriginalDataErrorWave=root:Packages:Irena:CylinderModels:OriginalDataErrorWave
	NVAR AchievedChiSquare=root:Packages:Irena:CylinderModels:AchievedChiSquare
	SVAR FittingPower= root:Packages:Irena:CylinderModels:FittingPower
	//FittingPower = "Int;I*Q;I*Q^2;I*Q^3;I*Q^4;

	
	Variable V_chisq
	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave=W_coef/20
	string HoldStr=""
	Print "Fitting stating now"
	IR3F_SetupWarningPanel(0, 1)
	string ParamName
		//least squares...
		Variable V_FitError=0			//This should prevent errors from being generated
		//and now the fit...
		if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
			//check that cursors are actually on hte right wave...
			//make sure the cursors are on the right waves..
			if (cmpstr(CsrWave(A, "IR3F_LogLogDataDisplay"),"OriginalDataQWave")!=0)
				Cursor/P/W=IR3F_LogLogDataDisplay A  OriginalDataIntWave  binarysearch(OriginalDataQWave, CsrXWaveRef(A) [pcsr(A, "IR3F_LogLogDataDisplay")])
			endif
			if (cmpstr(CsrWave(B, "IR3F_LogLogDataDisplay"),"OriginalDataQWave")!=0)
				Cursor/P /W=IR3F_LogLogDataDisplay B  OriginalDataIntWave  binarysearch(OriginalDataQWave,CsrXWaveRef(B) [pcsr(B, "IR3F_LogLogDataDisplay")])
			endif
			Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalDataIntWave, FitIntensityWave		
			Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalDataQWave, FitQvectorWave
			Duplicate/O/R=[pcsr(A),pcsr(B)] OriginalDataErrorWave, FitErrorWave
			strswitch(FittingPower)
				case "Int":
				
				case "I*Q":
					FitIntensityWave = FitIntensityWave*FitQvectorWave
					FitErrorWave = FitErrorWave*FitQvectorWave
				case "I*Q^2":
					FitIntensityWave = FitIntensityWave*FitQvectorWave^2
					FitErrorWave = FitErrorWave*FitQvectorWave^2
				case "I*Q^3":
					FitIntensityWave = FitIntensityWave*FitQvectorWave^3
					FitErrorWave = FitErrorWave*FitQvectorWave^3
				case "I*Q^4":
					FitIntensityWave = FitIntensityWave*FitQvectorWave^4
					FitErrorWave = FitErrorWave*FitQvectorWave^4		
			endswitch
			
			FuncFit/W=1  IR3F_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1/E=E_wave /D /C=T_Constraints 
		else
			Duplicate/O OriginalDataIntWave, FitIntensityWave		
			Duplicate/O OriginalDataQWave, FitQvectorWave
			Duplicate/O OriginalDataErrorWave, FitErrorWave
			strswitch(FittingPower)
				case "Int":
				
				case "I*Q":
					FitIntensityWave = FitIntensityWave*FitQvectorWave
					FitErrorWave = FitErrorWave*FitQvectorWave
				case "I*Q^2":
					FitIntensityWave = FitIntensityWave*FitQvectorWave^2
					FitErrorWave = FitErrorWave*FitQvectorWave^2
				case "I*Q^3":
					FitIntensityWave = FitIntensityWave*FitQvectorWave^3
					FitErrorWave = FitErrorWave*FitQvectorWave^3
				case "I*Q^4":
					FitIntensityWave = FitIntensityWave*FitQvectorWave^4
					FitErrorWave = FitErrorWave*FitQvectorWave^4
				
			endswitch

			FuncFit/W=1  IR3F_FitFunction W_coef FitIntensityWave /X=FitQvectorWave /W=FitErrorWave /I=1 /E=E_wave/D /C=T_Constraints	
		endif
		if (V_FitError!=0)	//there was error in fitting
			AchievedChiSquare = 0
			for (i=0;i<numpnts(CoefNames);i+=1)
				ParamName=StringFromList(0,CoefNames[i],";")
				if(StringMatch(ParamName, "SASBackground" ))
					NVAR SASBackground = root:Packages:Irena:CylinderModels:SASBackground
					SASBackground = BackupFitValues[i]
				else
					Wave TempParam=$("root:Packages:Irena:CylinderModels:"+ParamName)
					TempParam[str2num(StringFromList(1,CoefNames[i],";"))][0]=BackupFitValues[i]	
				endif
			endfor
			Print "Warning - Fitting error, Parameters restored to values before failure. Check starting parameters and fitting limits" 
			IR3F_AutoRecalculateModelData(1)
			setDataFolder OldDf
			return 0
		endif
		//this now records the errors for fitted parameters into the appropriate variables
		Wave W_sigma=W_sigma
		for (i=0;i<numpnts(CoefNames);i+=1)
			ParamName=StringFromList(0,CoefNames[i],";")
			if(StringMatch(ParamName, "SASBackground" ))
				NVAR BackgroundError = root:Packages:Irena:CylinderModels:SASBackgroundError
				BackgroundError = W_sigma[i]
			else
				Wave TempParam=$("root:Packages:Irena:CylinderModels:"+ParamName)
				TempParam[str2num(StringFromList(1,CoefNames[i],";"))][4]=W_sigma[i]	
			endif
		endfor
		//	endif
		NVAR AchievedChiSquare=root:Packages:Irena:CylinderModels:AchievedChiSquare
		AchievedChiSquare=V_chisq
		IR3F_AutoRecalculateModelData(1)
		IR3F_KillWarningPanel()
	setDataFolder OldDf
end
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3F_FitFunction(w,yw,xw) : FitFunc
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
	Wave/T CoefNames=root:Packages:Irena:CylinderModels:CoefNames		//text wave with names of parameters
	//CoefNames[curLen]	  	=   "DBPar;"+num2str(i)+";"
	variable i, NumOfParam
	NumOfParam=numpnts(CoefNames)
	string ParamName=""
	for (i=0;i<NumOfParam;i+=1)
		ParamName=StringFromList(0,CoefNames[i],";")
		if(StringMatch(ParamName, "SASBackground" ))
			NVAR SASBackground = root:Packages:Irena:CylinderModels:SASBackground
			SASBackground = w[i]
		else
			Wave TempParam=$("root:Packages:Irena:CylinderModels:"+ParamName)
			TempParam[str2num(StringFromList(1,CoefNames[i],";"))][0]=w[i]	
		endif
	endfor
	IR3F_CalculateModel(yw,xw,1)
	Wave resultWv=root:Packages:Irena:CylinderModels:ModelIntensity
	yw=resultWv
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3F_fitcheckproc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			SVAR ModelSelected = root:Packages:Irena:CylinderModels:ModelSelected
			//	WaveParamsValues={"Value","Fit?","LowLimit","HighLimit","FitError"}

		Wave UnifiedPar = root:Packages:Irena:CylinderModels:UnifiedPar
		//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
		Wave CylPar	 = root:Packages:Irena:CylinderModels:CylPar	
		//CylParNames = {"Prefactor","Radius","Length","SLD"}
		Wave CSCylPar	 = root:Packages:Irena:CylinderModels:CSCylPar	
		//CSCylParNames = {"Prefactor","Radius","Length","SLD","ShellThickness"}
		Wave ElCylPar	 = root:Packages:Irena:CylinderModels:ElCylPar	
		//ElCylParNames = {"Prefactor","Radius","Length","SLD","AspectRatio"}
		Wave CSElCylPar	 = root:Packages:Irena:CylinderModels:CSElCylPar	
		//CSElCylParNames = 		{"Prefactor","Radius","Length","SLD","ShellThickness","AspectRatio"}
		Wave ProfCSElCylPar= root:Packages:Irena:CylinderModels:ProfCSElCylPar
		//ProfCSElCylParNames = {"Prefactor","Radius","Length","AspectRatio","Shell1Th","Shell1SLD", "Shell2th", "Shell2SLD"}

		strswitch(ModelSelected)	// string switch
			case "Cylinder":	// execute if case matches expression
				if(StringMatch(cba.ctrlName, "FitModelVarPar1" ))
					CylPar[0][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar2" ))
					CylPar[1][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar3" ))
					CylPar[2][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar4" ))
					CylPar[3][1] = checked
				endif
				break		// exit from switch
			case "Core Shell Cylinder":	// execute if case matches expression
				if(StringMatch(cba.ctrlName, "FitModelVarPar1" ))
					CSCylPar[0][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar2" ))
					CSCylPar[1][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar3" ))
					CSCylPar[2][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar4" ))
					CSCylPar[3][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar5" ))
					CSCylPar[4][1] = checked
				endif
				break		// exit from switch
			case "Ellip. Cylinder":	// execute if case matches expression
				if(StringMatch(cba.ctrlName, "FitModelVarPar1" ))
					ElCylPar[0][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar2" ))
					ElCylPar[1][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar3" ))
					ElCylPar[2][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar4" ))
					ElCylPar[3][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar5" ))
					ElCylPar[4][1] = checked
				endif
				break		// exit from switch
			case "Core Shell Ellip. Cylinder":	// execute if case matches expression
				if(StringMatch(cba.ctrlName, "FitModelVarPar1" ))
					CSElCylPar[0][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar2" ))
					CSElCylPar[1][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar3" ))
					CSElCylPar[2][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar4" ))
					CSElCylPar[3][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar5" ))
					CSElCylPar[4][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar6" ))
					CSElCylPar[5][1] = checked
				endif
				break		// exit from switch
			case "Profile CS Ellip. Cylinder":	// execute if case matches expression
		//{"Prefactor","Radius","Length","AspectRatio","Shell1Th","Shell1SLD", "Shell2th", "Shell2SLD"}
				if(StringMatch(cba.ctrlName, "FitModelVarPar1" ))
					ProfCSElCylPar[0][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar2" ))
					ProfCSElCylPar[1][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar3" ))
					ProfCSElCylPar[2][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar4" ))
					ProfCSElCylPar[3][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar5" ))
					ProfCSElCylPar[4][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar6" ))
					ProfCSElCylPar[5][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar7" ))
					ProfCSElCylPar[6][1] = checked
				endif
				if(StringMatch(cba.ctrlName, "FitModelVarPar8" ))
					ProfCSElCylPar[7][1] = checked
				endif
				break		// exit from switch
			endswitch
			//handle Unified controls
//			Wave UnifiedPar = root:Packages:Irena:CylinderModels:UnifiedPar
//			//UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}, "LinkUnifRgCO"= [4][1] aka Fit
//			if(StringMatch(cba.ctrlName, "FitUnifG" ))
//				UnifiedPar[0][1]=checked
//			endif
//			if(StringMatch(cba.ctrlName, "FitUnifRg" ))
//				UnifiedPar[1][1]=checked
//			endif
//			if(StringMatch(cba.ctrlName, "FitUnifPwrlawB" ))
//				UnifiedPar[2][1]=checked
//			endif
//			if(StringMatch(cba.ctrlName, "FitUnifPwrlawP" ))
//				UnifiedPar[3][1]=checked
//			endif
//			if(StringMatch(cba.ctrlName, "LinkUnifRgCO" ))
//				UnifiedPar[4][1]=checked
//				IR3S_SetRGCOAsNeeded()
//				IR3S_AutoRecalculateModelData(0)				
//			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//*****************************************************************************************************************
//*****************************************************************************************************************


//**********************************************************************************************************
//**********************************************************************************************************

static Function IR3F_InitCylinderModels()	


	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFref oldDf= GetDataFolderDFR()
	variable i
		
	if (!DataFolderExists("root:Packages:Irena:CylinderModels"))		//create folder
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Irena
		NewDataFolder/O root:Packages:Irena:CylinderModels
	endif
	SetDataFolder root:Packages:Irena:CylinderModels					//go into the folder
	string ListOfVariables
	string ListOfStrings
	string/g ListOfVariablesCyl, ListOfVariablesCylCS, ListOfVariablesElCyl, ListOfVariablesElCylCS, ListOfVariablesBG
	string/g ListOfVariablesMain
	
	//here define the lists of variables and strings needed, separate names by ;...
	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;dQWavename;DataUnits;"
	ListOfStrings+="DataStartFolder;DataMatchString;FolderSortString;FolderSortStringAll;"
	ListOfStrings+="UserMessageString;SavedDataMessage;"
	ListOfStrings+="ModelSelected;ListOfModels;FittingPower;ListOfFittingPowers;"

	ListOfVariablesMain="UseIndra2Data;UseQRSdata;DataQEnd;DataQStart;DataQEndPoint;DataQstartPoint;"
	ListOfVariablesMain+="UpdateAutomatically;AchievedChiSquare;ScatteringContrast;SlitLength;UseSlitSmearedData;"
	ListOfVariablesMain+="SaveToNotebook;SaveToWaves;SaveToFolder;DelayBetweenProcessing;DoNotTryRecoverData;HideTagsAlways;"
	ListOfVariablesMain+="UseUnified;"
	
	//background
	ListOfVariablesBG="SASBackground;FitSASBackground;SASBackgroundLL;SASBackgroundHL;SASBackgroundError;"

	//Cylinder
	ListOfVariablesCyl=""
	//Core Shell Cylinder
	ListOfVariablesCylCS=""
	//Ellipsoid Cylinder
	ListOfVariablesElCyl = ""
	//Ellipsoid Core Shell Cylinder
	ListOfVariablesElCylCS = "ProfileMaxX;UseGMatrixCalculations;"
	
	ListOfVariables = ListOfVariablesMain+ListOfVariablesElCylCS+ListOfVariablesBG
	// new, use waves for parameters. Let's see if it is better
	make/O/T/N=(5) WaveParamsValues		//this is names for columns 
	WaveParamsValues={"Value","Fit?","LowLimit","HighLimit","FitError"}
	//Unified fit, 4 paramegers, G, Rg, P, B + 1 not fitted parameter, UnifRgCO, LinkUnifRgCO is [4][1], aka Fit
	make/O/N=(5,5) UnifiedPar			//Parameters
	make/O/T/N=(5) UnifiedParNames		//Names for Unified fit parameters. 
	wave/T UnifiedParNames
	UnifiedParNames = {"G","Rg","B","P","UnifRgCO"}

	//Cylinder, 4 parameters
	make/O/N=(4,5) CylPar			//
	make/O/T/N=(4) CylParNames		// 
	wave/T CylParNames
	CylParNames = {"Prefactor","Radius","Length","SLD"}
	//Core-shell Cylinder = Tube, 5 parameters
	make/O/N=(5,5) CSCylPar			//
	make/O/T/N=(5) CSCylParNames		// 
	wave/T CSCylParNames
	CSCylParNames = {"Prefactor","Radius","Length","SLD","ShellThickness"}
	//Elliptical Cylinder, 5 parameters
	make/O/N=(5,5) ElCylPar			//
	make/O/T/N=(5) ElCylParNames		// 
	wave/T ElCylParNames
	ElCylParNames = {"Prefactor","Radius","Length","SLD","AspectRatio"}
	//Core-shell Elliptical Cylinder, 5 parameters
	make/O/N=(6,5) CSElCylPar			//
	make/O/T/N=(6) CSElCylParNames		// 
	wave/T CSElCylParNames
	CSElCylParNames = {"Prefactor","Radius","Length","SLD","ShellThickness","AspectRatio"}

	//SLD Profile Core-shell Elips Cylinder, 7 parameters
	make/O/N=(8,5) ProfCSElCylPar			//
	make/O/T/N=(8) ProfCSElCylParNames		// 
	wave/T ProfCSElCylParNames
	ProfCSElCylParNames = {"Prefactor","Radius","Length","AspectRatio","Shell1Th","Shell1SLD", "Shell2th", "Shell2SLD"}
	
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
	ListOfModels="---;Cylinder;Core Shell Cylinder;Ellip. Cylinder;Core Shell Ellip. Cylinder;Profile CS Ellip. Cylinder;"
	SVAR ModelSelected
	if(strlen(ModelSelected)<1)
		ModelSelected="---"
	endif
	SVAR ListOfFittingPowers 
	ListOfFittingPowers = "Int;I*Q;I*Q^2;I*Q^3;I*Q^4;"
	SVAR FittingPower
	if(strlen(FittingPower)<1)
		FittingPower="Int"
	endif
	
	Make/O/T/N=(0) ListOfAvailableData
	Make/O/N=(0) SelectionOfAvailableData
	SetDataFolder oldDf
	IR3F_SetInitialValues()
end
//**************************************************************************************
//**************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR3F_SetInitialValues()
	//and here set default values...

	DFref oldDf= GetDataFolderDFR()

	setDataFolder root:Packages:Irena:CylinderModels
	NVAR FitSASBackground=root:Packages:Irena:CylinderModels:FitSASBackground
	NVAR UpdateAutomatically=root:Packages:Irena:CylinderModels:UpdateAutomatically

	NVAR UseSlitSmearedData=root:Packages:Irena:CylinderModels:UseSlitSmearedData
	NVAR SlitLength=root:Packages:Irena:CylinderModels:SlitLength
	NVAR UseQRSData = root:Packages:Irena:CylinderModels:UseQRSData
	NVAR UseIndra2data = root:Packages:Irena:CylinderModels:UseIndra2data

	//Unified
	Wave UnifiedPar = root:Packages:Irena:CylinderModels:UnifiedPar
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

	//Cylinder, 4 paramegers
	Wave CylPar = root:Packages:Irena:CylinderModels:CylPar
	//CylParNames = {"Prefactor","Radius","Length","SLD"}
	if(CylPar[0][0]<=0)		//Prefactor
		CylPar[0][0]=1
		CylPar[0][2]=1e-10
		CylPar[0][3]=1e10
	endif
	if(CylPar[1][0]==0)			//Radius
		CylPar[1][0]=50
		CylPar[1][2]=5
		CylPar[1][3]=1000
	endif
	if(CylPar[2][0]==0)		//Length
		CylPar[2][0]=2000
		CylPar[2][2]=200
		CylPar[2][3]=20000
	endif
	if(CylPar[3][0]==0)		//SLD
		CylPar[3][0]=0.01
		CylPar[3][2]=1e-5
		CylPar[3][3]=1e5
	endif

	Wave CSCylPar = root:Packages:Irena:CylinderModels:CSCylPar
	//CylParNames = {"Prefactor","Radius","Length","SLD","ShellThickness"}
	if(CSCylPar[0][0]<=0)		//Prefactor
		CSCylPar[0][0]=1
		CSCylPar[0][2]=1e-10
		CSCylPar[0][3]=1e10
	endif
	if(CSCylPar[1][0]==0)			//Radius
		CSCylPar[1][0]=50
		CSCylPar[1][2]=5
		CSCylPar[1][3]=1000
	endif
	if(CSCylPar[2][0]==0)		//Length
		CSCylPar[2][0]=2000
		CSCylPar[2][2]=200
		CSCylPar[2][3]=20000
	endif
	if(CSCylPar[3][0]==0)		//SLD
		CSCylPar[3][0]=0.01
		CSCylPar[3][2]=1e-5
		CSCylPar[3][3]=1e5
	endif
	if(CSCylPar[4][0]==0)		//ShellThickness
		CSCylPar[3][0]=20
		CSCylPar[3][2]=1
		CSCylPar[3][3]=1000
	endif

	Wave ElCylPar = root:Packages:Irena:CylinderModels:ElCylPar
	//ElCylParNames = {"Prefactor","Radius","Length","SLD","AspectRatio"}
	if(ElCylPar[0][0]<=0)		//Prefactor
		ElCylPar[0][0]=1
		ElCylPar[0][2]=1e-10
		ElCylPar[0][3]=1e10
	endif
	if(ElCylPar[1][0]==0)			//Radius
		ElCylPar[1][0]=50
		ElCylPar[1][2]=5
		ElCylPar[1][3]=1000
	endif
	if(ElCylPar[2][0]==0)		//Length
		ElCylPar[2][0]=2000
		ElCylPar[2][2]=200
		ElCylPar[2][3]=20000
	endif
	if(ElCylPar[3][0]==0)		//SLD
		ElCylPar[3][0]=0.01
		ElCylPar[3][2]=1e-5
		ElCylPar[3][3]=1e5
	endif
	if(ElCylPar[4][0]==0)		//AspectRatio
		ElCylPar[4][0]=1
		ElCylPar[4][2]=0.2
		ElCylPar[4][3]=5
	endif

	Wave CSElCylPar = root:Packages:Irena:CylinderModels:CSElCylPar
	//CSElCylParNames = {"Prefactor","Radius","Length","SLD","ShellThickness","AspectRatio"}
	if(CSElCylPar[0][0]<=0)			//Prefactor
		CSElCylPar[0][0]=1
		CSElCylPar[0][2]=1e-10
		CSElCylPar[0][3]=1e10
	endif
	if(CSElCylPar[1][0]==0)			//Radius
		CSElCylPar[1][0]=50
		CSElCylPar[1][2]=5
		CSElCylPar[1][3]=1000
	endif
	if(CSElCylPar[2][0]==0)			//Length
		CSElCylPar[2][0]=2000
		CSElCylPar[2][2]=200
		CSElCylPar[2][3]=20000
	endif
	if(CSElCylPar[3][0]==0)			//SLD
		CSElCylPar[3][0]=0.01
		CSElCylPar[3][2]=1e-5
		CSElCylPar[3][3]=1e5
	endif
	if(CSElCylPar[4][0]==0)			//ShellThickness
		CSElCylPar[4][0]=20
		CSElCylPar[4][2]=1
		CSElCylPar[4][3]=1000
	endif
	if(CSElCylPar[5][0]==0)			//AspectRatio
		CSElCylPar[5][0]=1
		CSElCylPar[5][2]=0.2
		CSElCylPar[5][3]=5
	endif

	Wave ProfCSElCylPar = root:Packages:Irena:CylinderModels:ProfCSElCylPar
	//ProfCSElCylParNames = {"Prefactor","Radius","Length","AspectRatio","Shell1Th","Shell1SLD", "Shell2th", "Shell2SLD"}
	if(ProfCSElCylPar[0][0]<=0)			//Prefactor
		ProfCSElCylPar[0][0]=1
		ProfCSElCylPar[0][2]=1e-10
		ProfCSElCylPar[0][3]=1e10
	endif
	if(ProfCSElCylPar[1][0]==0)			//Radius
		ProfCSElCylPar[1][0]=50
		ProfCSElCylPar[1][2]=5
		ProfCSElCylPar[1][3]=1000
	endif
	if(ProfCSElCylPar[2][0]==0)			//Length
		ProfCSElCylPar[2][0]=2000
		ProfCSElCylPar[2][2]=200
		ProfCSElCylPar[2][3]=20000
	endif
	if(ProfCSElCylPar[3][0]==0)			//AspectRatio
		ProfCSElCylPar[3][0]=0.01
		ProfCSElCylPar[3][2]=1e-5
		ProfCSElCylPar[3][3]=1e5
	endif
	if(ProfCSElCylPar[4][0]==0)			//Shell1Thickness
		ProfCSElCylPar[4][0]=10
		ProfCSElCylPar[4][2]=1
		ProfCSElCylPar[4][3]=1000
	endif
	if(ProfCSElCylPar[5][0]==0)			//Shell1SLD
		ProfCSElCylPar[5][0]=1
		ProfCSElCylPar[5][2]=0.2
		ProfCSElCylPar[5][3]=5
	endif
	if(ProfCSElCylPar[6][0]==0)			//Shell2Thickness
		ProfCSElCylPar[6][0]=20
		ProfCSElCylPar[6][2]=1
		ProfCSElCylPar[6][3]=1000
	endif
	if(ProfCSElCylPar[7][0]==0)			//Shell2SLD
		ProfCSElCylPar[7][0]=2
		ProfCSElCylPar[7][2]=0.2
		ProfCSElCylPar[7][3]=5
	endif
	
	NVAR DelayBetweenProcessing=root:Packages:Irena:CylinderModels:DelayBetweenProcessing
	if(DelayBetweenProcessing<0)
		DelayBetweenProcessing=0
	endif
	NVAR ProfileMaxX=root:Packages:Irena:CylinderModels:ProfileMaxX
	if(ProfileMaxX<round(1.1*(ProfCSElCylPar[1][0]+2*ProfCSElCylPar[4][0]+ProfCSElCylPar[6][0])))
		ProfileMaxX=round(1.1*(ProfCSElCylPar[1][0]+2*ProfCSElCylPar[4][0]+ProfCSElCylPar[6][0]))
	endif

	//CurrentTab=0
	if(SlitLength==0)
		SlitLength = 1 
	endif
	if (UseQRSData)
		UseIndra2data=0
	endif
	if (FitSASBackground==0)
		FitSASBackground=1
	endif
	
	UpdateAutomatically=0

	setDataFolder oldDF
	
end	




//*****************************************************************************************************************
//*****************************************************************************************************************
