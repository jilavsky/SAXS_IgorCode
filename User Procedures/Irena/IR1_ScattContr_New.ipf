#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method.
#pragma version=2.27

constant IR1K_CurrentPanelVersion=2.27

//*************************************************************************\
//* Copyright (c) 2005 - 2018, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.27 added Compound name mask (regex) string to handle when lots of names is listed. 
//2.26  removed unused functions
//2.25  Modified Screen Size check to match the needs
//2.24 added getHelp button calling to www manual
//2.23 changes fro panel scaling. 
//2.22 minor fix of nits on the Scatt Contrast Calculator main panel. 
//2.21 minor GUI fixes (added Transm to show it is transmission). 
//2.20 removed some execute commands
//2.19 Modified descxription for exp(-Mu*T) as Transmission. Users seem to be missing the point. 
//2.18 fix of GUI - units for roh/gram for neutrons was wrong. 
//2.17 minor fix to avoid p and x outside the assignement loop Igor error. 
//2.16  Modified all controls not to define font and font size to enable proper control by user 
//2.15 minor fix - do not update controls on Main panel, if user closed it when went to ANomalous calculator. 
//2.14 fixed the label for SL per gram as noticed by Dale 
//2.13 added SLD per gram for purpose of Unified Analysis... 
//2.12 added license for ANL
//2.11 fixed Au values and added units in neutron fields
//
//
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
Function IR1K_ScattCont2()

	IR1K_InitializeScattContrast()
	IR1K_InitCalculatorExportDta()

	IN2G_CheckScreenSize("height",500)
	IN2G_CheckScreenSize("width",800)
	
	KillWIndow/Z IR1K_ScatteringContCalc
	
	Execute("IR1K_ScatteringContCalc()")
	IR1_UpdatePanelVersionNumber("IR1K_ScatteringContCalc", IR1K_CurrentPanelVersion,1)

	IR1K_FixDisplayedVariables()
	IR1K_DisplayRightElement()
	IR1K_FixCompoundFormula()
	IR1K_UpdateCalcExportDta()
end
//
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
//
Window IR1K_ScatteringContCalc() 
	setDataFolder root:Packages:ScatteringContrast:
	
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(19,52,780,530)
	DoWindow/T IR1K_ScatteringContCalc,"Scattering contrast calculator main"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 3,textrgb= (0,0,65280)
	TitleBox MainTitle title="\Zr220Substance editor and scattering contrast calculator",pos={100,10},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={560,24},anchor=MC,fColor=(0,0,52224)
//	DrawText 100,32,"Substance editor and scattering contrast calculator"
	TitleBox Info1 title="\Zr160Modify element:",pos={13,91},frame=0,fstyle=1, fixedSize=1,size={120,20},fColor=(0,0,52224)
	//DrawText 13,91,"Modify element:"
	//SetDrawEnv fsize= 14,fstyle= 3,textrgb= (0,0,65280)
	TitleBox Info21 title="\Zr160Saved substances:",pos={300,200},frame=0,fstyle=2, fixedSize=1,size={150,20}, fColor= (0,0,65280)
	//DrawText 300,220,"Saved substances:"
	TitleBox CompoundFormula,pos={10,170},size={75,15},title="  "
	TitleBox CompoundFormula,frame=0
	TitleBox CompoundFormula,variable= root:Packages:ScatteringContrast:Formula
	SetVariable NumberOfElements,pos={25,48},size={170,16},proc=IR1K_SetVarProc,title="Number of elements"
	SetVariable NumberOfElements,limits={0,24,1},value= root:Packages:ScatteringContrast:NumberOfAtoms
	SetVariable density,pos={218,49},size={160,16},proc=IR1K_SetVarProc,title="Density [g/cm3]   "
	SetVariable density,limits={0,Inf,0},value= root:Packages:ScatteringContrast:Density
	CheckBox WeightPercent, pos={430,49}, title="Weight fraction?",proc=IR1K_CheckProc
	CheckBox WeightPercent, variable=root:Packages:ScatteringContrast:UseWeightPercent	, help={"Use weight fraction (if you want to use balance) or weight percent or weight ratio"}
	CheckBox BalanceElement,pos={140,128},size={144,14},proc=IR1K_CheckProc,title="balance"
	CheckBox BalanceElement,help={"Check to have this element to be balance"}, disable=!(root:Packages:ScatteringContrast:UseWeightPercent)
	Button GetHelp,pos={670,45},size={80,15},fColor=(65535,32768,32768), proc=IR1K_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}

	Slider ElementSelection size={500,20},pos={115,75},vert=0, proc=IR1K_ScatCont2SliderProc, limits= {1,root:Packages:ScatteringContrast:NumberOfAtoms,1 }
	Slider ElementSelection help={"Select element to edit (maximum of elements changes as set above)"}
	
//	PopupMenu ElementType,pos={5,130},size={51,21}, proc=IR1K_PopMenuProc, title="Select element",help={"Select atom type"}
//	PopupMenu ElementType,mode=1,popvalue= "---",value= #"root:Packages:ScatteringContrast:ListOfElements"
	SetVariable ElementType,pos={13,128},size={125,20},title="Element    ",help={"Element"}, frame=0, noedit=1, bodywidth=40
	SetVariable ElementType, proc=IR1K_SetVarProc,limits={0,Inf,0},value= root:Packages:ScatteringContrast:El1_type
	Button SelectElement size={90,20},pos={40,150}, proc=IR1K_ButtonProc
	Button SelectElement title="Change element",help={"Click to change the displayed element"}

	SetVariable Elementcontent,pos={140,145},size={40,16},title=" ",help={"Amount of this atom in molecule, use decimal numbers if necessary"}
	SetVariable Elementcontent,proc=IR1K_SetVarProc,limits={0,Inf,0},value= root:Packages:ScatteringContrast:El1_content
	PopupMenu ElementIsotope,pos={230,130},size={106,21},title="Isotope",proc=IR1K_PopMenuProc
	PopupMenu ElementIsotope,mode=1,popvalue=root:Packages:ScatteringContrast:El1_Isotope,value= #"IR1K_ListTheIsotopes(root:Packages:ScatteringContrast:El1_type)"

	SetVariable ElNumOfElectrons,pos={370,125},size={125,16},title="Electrons:",help={"This is number of electrosn of this atom, not editable"}
	SetVariable ElNumOfElectrons,limits={-Inf,Inf,0},noedit= 1,frame=0, value=root:Packages:ScatteringContrast:El_NumOfElectrons
	SetVariable ElAtomWeight,pos={370,145},size={125,16},title="Atom wt:",help={"Atomic weight of this element, not editable"}
	SetVariable ElAtomWeight,limits={-Inf,Inf,0},noedit= 1,frame=0, value=root:Packages:ScatteringContrast:El_AtomWeight
	SetVariable ElNeutronCohB,pos={530,120},size={135,16},title="Neu b [e-14 m]      :  ",help={"Neutron coherent b of this atom"}
	SetVariable ElNeutronCohB,limits={-Inf,Inf,0},noedit= 1,frame=0, value=root:Packages:ScatteringContrast:El_NeutronCohB
	SetVariable ElNeutronIncohB,pos={530,135},size={135,16},title="Incoh b [e-14 m]     :  ",help={"Neutron incoherent b of this atom"}
	SetVariable ElNeutronIncohB,limits={-Inf,Inf,0},noedit= 1,frame=0, value=root:Packages:ScatteringContrast:El_NeutronIncohB
	SetVariable ElNeutronAbsCross,pos={530,150},size={135,16},title="Abs Xsec [e-24 cm^2]:",help={"Neutron absorption cross section (barn) of this atom"}
	SetVariable ElNeutronAbsCross,limits={-Inf,Inf,0},noedit= 1,frame=0, value=root:Packages:ScatteringContrast:El_NeutronAbsCross

	SetVariable MolWeight,pos={14,216},size={260,16},title="Molecular weight                             ",frame=0, help={"Molecular weight"}
	SetVariable MolWeight,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:MolWeight,noedit= 1
	SetVariable WghtOf1Mol,pos={13,234},size={260,16},title="Weight of 1 mol [g]                          ",frame=0, help={"Weight of 1 molecule"}
	SetVariable WghtOf1Mol,help={"Weight of 1 molecule in gramms caluclated from density and other numbers"}
	SetVariable WghtOf1Mol,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:WghtOf1Mol,noedit= 1, format="%.5e"
	SetVariable NumOfMolin1cm3,pos={14,252},size={260,16},title="Num of mol in 1cm3                        ",frame=0, help={"Number of molecules in 1 cm3"}
	SetVariable NumOfMolin1cm3,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:NumOfMolin1cm3,noedit= 1, format="%.5e"
	SetVariable NumOfElperMol,pos={14,270},size={260,16},title="Number of electrons per mol           ",frame=0, help={"Number of electrons per 1 molecule"}
	SetVariable NumOfElperMol,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:NumOfElperMol,noedit= 1
	SetVariable NumOfElincm3,pos={14,294},size={260,16},title="Number of el per 1cm3                   ",frame=0, help={"Number of electors per 1 cm3"}
	SetVariable NumOfElincm3,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:NumOfElincm3,noedit= 1, format="%.5e"
	SetVariable ScattContrXrays,pos={14,312},size={270,16},title="Xray scat length dens (rho) [10^10 cm-2] ",frame=0,labelBack=(32768,65280,32768)
	SetVariable ScattContrXrays,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:ScattContrXrays,noedit= 1, format="%.4g", help={"X ray scattering length density [10^10 cm-2], also known as rho"}
	SetVariable ScattContrXraysPerGram,pos={14,330},size={270,16},title="Xray SL per gram [10^10 cm/g] ",frame=0,labelBack=(32768,65280,32768)
	SetVariable ScattContrXraysPerGram,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:ScattContrXraysPerGram,noedit= 1, format="%.4g", help={"X ray scattering length density [10^10 cm-2] per 1g of material, also known as rho"}

	SetVariable NeutronsVolume1Mol,pos={14,350},size={260,16},title="Volume of 1 mol [cm3]                     ",frame=0
	SetVariable NeutronsVolume1Mol,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:NeutronsVolume1Mol,noedit= 1, format="%.5e",help={"Volume (in cm3) of 1 molecule"}
	SetVariable NeutronTotalMolB,pos={14,368},size={260,16},title="Total b of the molecule [cm]           ",frame=0
	SetVariable NeutronTotalMolB,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:NeutronTotalMolB,noedit= 1, format="%.5e",help={"Neutron sum of Bs for all atoms in the molecule, properly weighted"}
	SetVariable NeutronsScatlengthDens,pos={14,386},size={270,16},title="Neut. scat length dens (rho) [10^10 cm-2]  ",frame=0,labelBack=(32768,65280,32768)
	SetVariable NeutronsScatlengthDens,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:NeutronsScatlengthDens,noedit= 1, format="%.4g",help={"Neutron scattering length density in cm-2, also known as rho"}
	SetVariable NeutronsScatlengthDensPerGram,pos={14,404},size={270,16},title="Neut. SLD (rho) per gram [10^10 cm/g]  ",frame=0,labelBack=(32768,65280,32768)
	SetVariable NeutronsScatlengthDensPerGram,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:NeutronsScatlengthDensPerGram,noedit= 1, format="%.4g",help={"Neutron scattering length density in cm per gram, also known as rho per gram"}
	
	SetVariable UsedMatrixCompound,pos={330,370},size={250,16},title="Second phase :  ",help={"This is the name of compound set as matrix using button on right"}
	SetVariable UsedMatrixCompound,value= root:Packages:ScatteringContrast:UsedMatrixCompound, frame=0, noedit=1
	SetVariable MatrixScattContXrays,pos={330,390},size={390,16},title="X ray scatt length dens second phase (rho)  [10^10 cm-2]       ",help={"Input matrix X rays rho"}
	SetVariable MatrixScattContXrays,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:MatrixScattContXrays, proc=IR1K_SetVarProc, format="%.5g"
	SetVariable MatrixScattContNeutrons,pos={330,410},size={390,16},title="Neutrons scatt length dens second phase  (rho)  [10^10 cm-2]  ",help={"Input matrix Neutron rho"}
	SetVariable MatrixScattContNeutrons,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:MatrixScattContNeutrons, proc=IR1K_SetVarProc, format="%.4g"

	SetVariable CalcXrays,pos={14,422},size={270,16},title="X rays delta-rho squared   [10^20 cm-4]          ",frame=0,labelBack=(32768,65280,32768)
	SetVariable CalcXrays,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:XraysDeltaRhoSquared, format="%4.4g",help={"Xrays contrast (delta-rho squared)"}
	SetVariable CalcNeutrons,pos={14,440},size={270,16},title="Neutrons delta-rho squared    [10^20 cm-4]     ",frame=0,labelBack=(32768,65280,32768)
	SetVariable CalcNeutrons,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:NeutronsDeltaRhoSquared, format="%4.4g",help={"Neutron contrast (delta-rho squared)"}
	SetVariable XraysNeutronsRatio,pos={14,458},size={270,16},title="Ratio Xrays/Neutrons delta rho-squared          ",frame=0,labelBack=(32768,65280,32768), format="%.4g"
	SetVariable XraysNeutronsRatio,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:XraysNeutronsRatio,help={"This is ratio of X-ray and neutron contrast (delta-rho sqaured)"}


	CheckBox StoreCompoundsInIgorExperiment, pos={450,200}, title="Within this experiment (or on the computer)?",proc=IR1K_CheckProc
	CheckBox StoreCompoundsInIgorExperiment, variable=root:Packages:ScatteringContrast:StoreCompoundsInIgorExperiment, help={"Store compounds inside current Igor experiment? Or outside this experiment on the hard drive."}
	ListBox ListOfAvailableData,pos={300,220},size={280,126}
	ListBox ListOfAvailableData,help={"List of stored data "}
	ListBox ListOfAvailableData,listWave=root:Packages:ScatteringContrast:WaveOfCompoundsOutsideIgor
//	ListBox ListOfAvailableData,selWave=root:Packages:ScatteringContrast:NumbersOfCompoundsOutsideIgor
	ListBox ListOfAvailableData,mode= 2

	SetVariable AvailableCompoundsMask,pos={300,350},size={280,16},title="Mask names (regex) :  ",help={"Mask Stored data list using regex"}
	SetVariable AvailableCompoundsMask,value= root:Packages:ScatteringContrast:AvailableCompoundsMask, frame=1, proc=IR1K_SetVarProc



	Button SaveData size={120,20},pos={610,220}, proc=IR1K_ButtonProc
	Button SaveData title="Save data",help={"Stores this compound for later use"}
	Button LoadNewData size={120,20},pos={610,245}, proc=IR1K_ButtonProc
	Button LoadNewData title="Load data",help={"Load stored data"}
	Button DeleteData size={120,20},pos={610,270}, proc=IR1K_ButtonProc
	Button DeleteData title="Delete data",help={"Delete stored data"}
	Button NewData size={120,20},pos={610,295}, proc=IR1K_ButtonProc
	Button NewData title="New compound",help={"Clean the tool to start new compound"}
	Button SetAsMatrix size={140,20},pos={600,320}, proc=IR1K_ButtonProc
	Button SetAsMatrix title="Load as second phase",help={"Sets current data contrasts as second phase"}

	CheckBox UseMatrixVacuum, pos={610,370}, title="Use Vacuum?",proc=IR1K_CheckProc
	CheckBox UseMatrixVacuum, variable=root:Packages:ScatteringContrast:UseMatrixVacuum, help={"Use vacuum as second phase "}

	Button AnomalousCalc size={190,30},pos={400,440}, proc=IR1K_ButtonProc
	Button AnomalousCalc title="Anomalous calculator",help={"Call Anomalous calculator tool"}

EndMacro
////******************************************************************************************************************
////******************************************************************************************************************
////******************************************************************************************************************
////******************************************************************************************************************
//
Function/T IR1K_ListTheIsotopes(WhichOne)
	string WhichOne
	
	SVAR ListOfIsotopes=root:Packages:ScatteringContrast:ListOfIsotopes
	string tempList=StringByKey(WhichOne, ListOfIsotopes , "=" , ";")
	
	tempList = IN2G_ChangePartsOfString(tempList,",",";")
	return tempList
end

//
////******************************************************************************************************************
////******************************************************************************************************************
////******************************************************************************************************************
////******************************************************************************************************************
//
Function IR1K_ButtonProc(ctrlName) : ButtonControl
	String ctrlName

	if(cmpstr(ctrlName,"AnomalousCalc")==0)
		DoWIndow IR1K_AnomCalcPnl
		if(V_Flag)
			DoWIndow/F IR1K_AnomCalcPnl
		else
			IR1K_AnomScattContCalc()
		endif
		//IR1K_LoadCromerLiberman()
	endif
	if(cmpstr(ctrlName,"GetHelp")==0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Irena/ScatteringContrastCalculator.html")
	endif

//		Button SaveData size={120,20},pos={610,410},proc=IR1Y_ButtonProc
	if(cmpstr(ctrlName,"SaveData")==0)
		IR1K_SaveDataCompound()
	endif
	if(cmpstr(ctrlName,"NewData")==0)
		IR1K_CleanCompoundTool()
	endif
////		Button LoadNewData size={120,20},pos={610,440},proc=IR1Y_ButtonProc
	if(cmpstr(ctrlName,"LoadNewData")==0)
		IR1K_LoadDataCompound()
	endif
////		Button LoadMatrixData size={120,20},pos={610,470},proc=IR1Y_ButtonProc
	if(cmpstr(ctrlName,"SelectElement")==0)
		KillWIndow/Z IN2G_PeriodicTableInput
		NVAR SelectedElement=root:Packages:ScatteringContrast:SelectedElement
		SVAR SelectedElementName=root:Packages:ScatteringContrast:SelectedElementName
		IN2G_InputPeriodicTable("IR1K_PerTblButtonProc", "IN2G_PeriodicTableInput", "Select element", 180,220)
		IR1_UpdatePanelVersionNumber("IN2G_PeriodicTableInput", 1,1)	
		PauseForUser IN2G_PeriodicTableInput
		SVAR ELType=$("root:Packages:ScatteringContrast:El"+num2str(SelectedElement)+"_type")
		ELType=SelectedElementName
		SVAR IsotopeTypeString=$("root:Packages:ScatteringContrast:El"+num2str(SelectedElement)+"_Isotope")
		IsotopeTypeString = "natural"
		IR1K_DisplayRightElement()
		IR1K_FixCompoundFormula()
	endif
//
	if(cmpstr(ctrlName,"DeleteData")==0)
		IR1K_DeleteDataCompound()
		IR1K_UpdateCalcExportDta()
	endif

	if(cmpstr(ctrlName,"SetAsMatrix")==0)
		IR1K_LoadDataToMatrix()
	endif

End
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1K_PerTblButtonProc(ctrlName) : ButtonControl
	String ctrlName

	//print ctrlName
	SVAR SelectedElementName=root:Packages:ScatteringContrast:SelectedElementName
	SelectedElementName=ctrlName
	KillWIndow/Z IN2G_PeriodicTableInput
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function  IR1K_LoadDataToMatrix()

	string OldDf=GetDataFolder(1)
	SetdataFolder root:Packages:ScatteringContrast

	NVAR StoreCompoundsInIgorExperiment = root:Packages:ScatteringContrast:StoreCompoundsInIgorExperiment
	Wave/T WaveOfCompoundsOutsideIgor
	variable i
	string testNm, LoadedString, ExecComm
	ControlInfo/W=IR1K_ScatteringContCalc ListOfAvailableData
	i = V_Value
	if (i>=0)
		if(StoreCompoundsInIgorExperiment)
			testNm=WaveOfCompoundsOutsideIgor[i]
			string OldDf1=GetDataFolder(1)
			SetDataFolder root:Packages
			NewDataFolder/O/S root:Packages:IrenaSavedCompounds
			SVAR testStr = $(testNm)
			LoadedString = testStr
			SetDataFolder OldDf1
		else
			testNm=WaveOfCompoundsOutsideIgor[i]+".dat"
			LoadWave/J/Q/P=CalcSavedCompounds/K=2/N=ImportData/V={"\t"," $",0,1} testNm
			Wave/T LoadedData=root:Packages:ScatteringContrast:ImportData0
			LoadedString = LoadedData[0]
			KillWaves/Z LoadedData
		endif
	endif
	SVAR UsedMatrixCompound=root:Packages:ScatteringContrast:UsedMatrixCompound
	
	UsedMatrixCompound=StringFromList(0,testNm,".")

	NVAR MatrixScattContXrays=root:Packages:ScatteringContrast:MatrixScattContXrays
	NVAR MatrixScattContNeutrons=root:Packages:ScatteringContrast:MatrixScattContNeutrons
	
	MatrixScattContXrays=NumberByKey("ScattContrXrays", LoadedString  , "=" )
	MatrixScattContNeutrons=NumberByKey("NeutronsScatlengthDens", LoadedString  , "=" )
	
	IR1K_CalcMolWeightEtc()

	setDataFolder oldDf

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1K_SaveDataCompound()

	string OldDf=GetDataFolder(1)
	SetdataFolder root:Packages:ScatteringContrast

	string CompoundDescription=""
	variable i
	string ExportName=""
	string Overwrite
	
	NVAR Density=root:Packages:ScatteringContrast:Density
	NVAR NumberOfAtoms=root:Packages:ScatteringContrast:NumberOfAtoms
	NVAR ScattContrXrays=root:Packages:ScatteringContrast:ScattContrXrays
	NVAR NeutronsScatlengthDens=root:Packages:ScatteringContrast:NeutronsScatlengthDens
	NVAR UseWeightPercent=root:Packages:ScatteringContrast:UseWeightPercent
	NVAR WeightPercentBalanceElem=root:Packages:ScatteringContrast:WeightPercentBalanceElem
	SVAR LastLoadedCompound=root:Packages:ScatteringContrast:LastLoadedCompound
	
	NVAR StoreCompoundsInIgorExperiment = root:Packages:ScatteringContrast:StoreCompoundsInIgorExperiment
		//if =1 user wants to store dat within the Igor experiment, not outside...
	
	CompoundDescription+="NumberOfAtoms="+num2str(NumberOfAtoms)+";"
	CompoundDescription+="Density="+num2str(Density)+";"
	CompoundDescription+="ScattContrXrays="+num2str(ScattContrXrays)+";"
	CompoundDescription+="NeutronsScatlengthDens="+num2str(NeutronsScatlengthDens)+";"
	CompoundDescription+="UseWeightPercent="+num2str(UseWeightPercent)+";"
	CompoundDescription+="WeightPercentBalanceElem="+num2str(WeightPercentBalanceElem)+";"
	
	if(strlen(LastLoadedCompound)>0)
		ExportName=LastLoadedCompound
	else
		For(i=1;i<=NumberOfAtoms;i+=1)
			SVAR El_type=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_type")
			SVAR El_Isotope=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_Isotope")
			NVAR El_content=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_content")
			ExportName+=El_type
			if (El_content!=1)
			ExportName+=num2str(El_content)
			endif
		endfor
	endif
	ExportName=ExportName[0,27]
	
	For(i=1;i<=NumberOfAtoms;i+=1)
		SVAR El_type=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_type")
		SVAR El_Isotope=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_Isotope")
		NVAR El_content=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_content")
		CompoundDescription+="El"+num2str(i)+"_type="+El_type+";"
		CompoundDescription+="El"+num2str(i)+"_content="+num2str(El_content)+";"
		CompoundDescription+="El"+num2str(i)+"_Isotope="+El_Isotope+";"
	endfor
	Prompt ExportName, "Modify the compound name (27 char max)"
	DoPrompt "Save compound name", ExportName
	if(V_Flag)
		abort 		//user canceled
	endif
	
	ExportName=ExportName[0,27]
	
	//Ok, here we break and see,  if these data should be stored outside Igor or within current experiment
	if(StoreCompoundsInIgorExperiment)
		ExportName = cleanupname(ExportName,0)
		string OldDf1=getDataFolder(1)
		setDataFolder root:Packages
		newDataFolder/O/S root:Packages:IrenaSavedCompounds
		if(checkname(ExportName,4)!=0)
			DoAlert 2, "Compound exists, do you want to overwrite existing data?"
				if (V_Flag==3)
					abort
				endif
				if (V_Flag==1)
					Overwrite="Yes"
				else
					Overwrite="No"
				endif
				if (cmpstr(Overwrite,"Yes")==0)
					killstrings $(ExportName)
				else
					Prompt ExportName, "Change name of style being exported"
					DoPrompt "Change name for exported compound", ExportName	
					if (V_Flag)
						abort
					endif
				endif
		endif
		string/g $(ExportName)
		SVAR ExportStr=$(ExportName)
		ExportStr = CompoundDescription
		setDataFolder OldDf1
	else
		ExportName+=".dat"
		//check that notebook does not exist
		close/A
		OpenNotebook /Z/P=CalcSavedCompounds /V=0 /N=TestNbk ExportName
		if (V_Flag==0)	//notebook opened, therefore it exists
			DoAlert 2, "Compound exists, do you want to overwrite existing data?"
			if (V_Flag==3)
				abort
			endif
			if (V_Flag==1)
				Overwrite="Yes"
			else
				Overwrite="No"
			endif
			
			if (cmpstr(Overwrite,"Yes")==0)
				DoWindow /D/K testNbk
			else
				DoWindow /K testNbk
				ExportName = ExportName[0,strlen(ExportName)-5]
				Prompt ExportName, "Change name of compound being exported"
				DoPrompt "Change name for exported compound", ExportName	
				if (V_Flag)
					abort
				endif
				ExportName=ExportName+".dat"
			endif
		endif
		NewNotebook /F=0 /V=0/N=TestNbk 
		Notebook TestNbk selection={endOfFile, endOfFile}
		Notebook TestNbk text=CompoundDescription
		SaveNotebook /S=3/O/P=CalcSavedCompounds TestNbk as ExportName
		DoWindow /K testNbk
		LastLoadedCompound=stringFromList(0,ExportName,".")
	endif

	ListBox ListOfAvailableData, win=IR1K_ScatteringContCalc, selRow=-1
	setDataFolder oldDf
	
	IR1K_UpdateCalcExportDta()	
end
//
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
//
Function IR1K_FixDisplayedVariables()

	NVAR UseWeightPercent=root:Packages:ScatteringContrast:UseWeightPercent
	NVAR WeightPercentBalanceElem=root:Packages:ScatteringContrast:WeightPercentBalanceElem
	NVAR SelectedElement=root:Packages:ScatteringContrast:SelectedElement
	if(UseWeightPercent && ((WeightPercentBalanceElem==0) || (SelectedElement==WeightPercentBalanceElem)))
		CheckBox BalanceElement, disable=0, win=IR1K_ScatteringContCalc
	else
		CheckBox BalanceElement, disable=1, win=IR1K_ScatteringContCalc
	endif
	if(UseWeightPercent && (SelectedElement==WeightPercentBalanceElem))
		CheckBox BalanceElement, value=1, win=IR1K_ScatteringContCalc
		SetVariable Elementcontent, noedit=1, frame=0, win=IR1K_ScatteringContCalc
	else
		CheckBox BalanceElement, value=0, win=IR1K_ScatteringContCalc
		SetVariable Elementcontent, noedit=0, frame=1, win=IR1K_ScatteringContCalc
	endif
	

	NVAR UseMatrixVacuum=root:Packages:ScatteringContrast:UseMatrixVacuum
	if(UseMatrixVacuum)
			button SetAsMatrix, disable=2, win=IR1K_ScatteringContCalc
	else
			button SetAsMatrix, disable=0, win=IR1K_ScatteringContCalc
	endif
	
	if(UseWeightPercent)
		SetVariable MolWeight,disable=1, win=IR1K_ScatteringContCalc
		SetVariable WghtOf1Mol,disable=1, win=IR1K_ScatteringContCalc
		SetVariable WghtOf1Mol,disable=1, win=IR1K_ScatteringContCalc
		SetVariable NumOfMolin1cm3,disable=1, win=IR1K_ScatteringContCalc
		SetVariable NumOfElperMol,disable=1, win=IR1K_ScatteringContCalc
		SetVariable NeutronsVolume1Mol,disable=1, win=IR1K_ScatteringContCalc
		SetVariable NeutronTotalMolB,disable=1, win=IR1K_ScatteringContCalc
	else
		SetVariable MolWeight,disable=0, win=IR1K_ScatteringContCalc
		SetVariable WghtOf1Mol,disable=0, win=IR1K_ScatteringContCalc
		SetVariable WghtOf1Mol,disable=0, win=IR1K_ScatteringContCalc
		SetVariable NumOfMolin1cm3,disable=0, win=IR1K_ScatteringContCalc
		SetVariable NumOfElperMol,disable=0, win=IR1K_ScatteringContCalc
		SetVariable NeutronsVolume1Mol,disable=0, win=IR1K_ScatteringContCalc
		SetVariable NeutronTotalMolB,disable=0, win=IR1K_ScatteringContCalc
	endif
	IR1K_SetVarProc("NumberOfElements",1,"","")
//	IR1K_SetVarProc(ctrlName,varNum,varStr,varName)
end
////******************************************************************************************************************
////******************************************************************************************************************
////******************************************************************************************************************
////******************************************************************************************************************
//
Function IR1K_CalcMolWeightEtc()

	//here we calculate molecular weight 
	NVAR Density=root:Packages:ScatteringContrast:Density
	NVAR MolWeight=root:Packages:ScatteringContrast:MolWeight
	NVAR WghtOf1Mol=root:Packages:ScatteringContrast:WghtOf1Mol
	NVAR NumOfMolin1cm3=root:Packages:ScatteringContrast:NumOfMolin1cm3
	SVAR ListOfElAtomWghts=root:Packages:ScatteringContrast:ListOfElAtomWghts
	SVAR ListOfElNumbers=root:Packages:ScatteringContrast:ListOfElNumbers
	NVAR NumberOfAtoms = root:Packages:ScatteringContrast:NumberOfAtoms
	NVAR NumOfElperMol = root:Packages:ScatteringContrast:NumOfElperMol
	NVAR NumOfElincm3 = root:Packages:ScatteringContrast:NumOfElincm3
	NVAR ScattContrXrays = root:Packages:ScatteringContrast:ScattContrXrays
//	NVAR CalcNeutrons = root:Packages:ScatteringContrast:CalcNeutrons
	NVAR CalcXrays = root:Packages:ScatteringContrast:CalcXrays
	NVAR UseWeightPercent = root:Packages:ScatteringContrast:UseWeightPercent

	NVAR ScattContrXraysPerGram = root:Packages:ScatteringContrast:ScattContrXraysPerGram
	NVAR NeutronsScatlengthDensPerGram = root:Packages:ScatteringContrast:NeutronsScatlengthDensPerGram

	variable i, tempMolWght, tempNumOfElctrns, CorrectedElContent, sumMoles
	tempMolWght=0
	tempNumOfElctrns=0
	IF (UseWeightPercent)
		// use sumMoles to help convert weight fraction to atomic fraction
		sumMoles = 0
		FOR (i=1;i<=NumberOfAtoms;i+=1)
			NVAR Elcontent=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_content")
			NVAR ElementWeight=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_AtomWeight")
			// sum the number of moles of each element/isotype
			sumMoles += Elcontent/ElementWeight
		ENDFOR
	ENDIF
	For(i=1;i<=NumberOfAtoms;i+=1)
		NVAR Elcontent=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_content")
		NVAR ElementWeight=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_AtomWeight")
		if (UseWeightPercent)
			// number of moles = massFrac / AtMass
			// atFrac = number of moles / total number of moles
			CorrectedElContent = Elcontent/ElementWeight / sumMoles
		else
			CorrectedElContent = Elcontent
		endif
		
		if (CorrectedElContent>0)
			SVAR Eltype=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_type")
			tempMolWght+= CorrectedElContent * NumberByKey(ELType, ListOfElAtomWghts , "=" , ";")	
			tempNumOfElctrns += CorrectedElContent* NumberByKey(ELType, ListOfElNumbers , "=" , ";")		
		endif
	endfor
	//and now set the molecular weight to result....
	MolWeight = tempMolWght
	//and now calculate weight of 1 mol in grams
	WghtOf1Mol = MolWeight /(6.022142e23)
	//and now calculate number of mol per cm3
	 NumOfMolin1cm3 = density / WghtOf1Mol
	 //X rays calculations
	// 	calc number of electrons/molecule (from user formula)
	NumOfElperMol = tempNumOfElctrns
	//	calc number of electrons/cm3		el/mol  * mol/cm3
	NumOfElincm3 = NumOfElperMol * NumOfMolin1cm3
	//	scatt length density of 1 electron = 0.28 x 10^-12 cm	
	//	calc the scattering length density of material 
	ScattContrXrays = NumOfElincm3 * 0.28179e-12 * 10^(-10)
	ScattContrXraysPerGram = ScattContrXrays / density

//Neutrons:
// 	calc total b of molecule 	(need table of b for various materials)
//	use formula + the table
// 	calculate the volume of 1 molecule from weight of 1 molecule/density
//	scattering length = total b of molecule / V of the molecule
	NVAR NeutronTotalMolB=root:Packages:ScatteringContrast:NeutronTotalMolB
	NVAR NeutronsVolume1Mol=root:Packages:ScatteringContrast:NeutronsVolume1Mol
	NVAR NeutronsScatlengthDens=root:Packages:ScatteringContrast:NeutronsScatlengthDens
	SVAR ListOfElNeutronBs=root:Packages:ScatteringContrast:ListOfElNeutronBs
	variable tempTotalB=0
	NeutronsScatlengthDens=NaN
	NeutronTotalMolB=NaN
	NeutronsVolume1Mol=NaN
	For(i=1;i<=NumberOfAtoms;i+=1)
		NVAR Elcontent=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_content")
		NVAR ElementWeight=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_AtomWeight")
		if (UseWeightPercent)
			CorrectedElContent = Elcontent/ElementWeight
		else
			CorrectedElContent = Elcontent
		endif
		if (CorrectedElContent>0)
			SVAR Eltype=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_type")
			SVAR Elisotope=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_Isotope")
			tempTotalB+= CorrectedElContent * NumberByKey(ELType+"_"+Elisotope, ListOfElNeutronBs , "=" , ";")	
		endif
	endfor
	NeutronTotalMolB=tempTotalB
	NeutronTotalMolB*=1e-12
	NeutronsVolume1Mol=1/NumOfMolin1cm3
	NeutronsScatlengthDens=NeutronTotalMolB/NeutronsVolume1Mol*10^(-10)
	NeutronsScatlengthDensPerGram = NeutronsScatlengthDens/density

	NVAR  MatrixScattContXrays= root:Packages:ScatteringContrast:MatrixScattContXrays
	NVAR  MatrixScattContNeutrons= root:Packages:ScatteringContrast:MatrixScattContNeutrons
	NVAR  XraysDeltaRhoSquared= root:Packages:ScatteringContrast:XraysDeltaRhoSquared
	NVAR  NeutronsDeltaRhoSquared= root:Packages:ScatteringContrast:NeutronsDeltaRhoSquared
	NVAR  XraysNeutronsRatio= root:Packages:ScatteringContrast:XraysNeutronsRatio

	XraysDeltaRhoSquared = (MatrixScattContXrays - ScattContrXrays)^2
	NeutronsDeltaRhoSquared =  (MatrixScattContNeutrons - NeutronsScatlengthDens)^2
	XraysNeutronsRatio = XraysDeltaRhoSquared/NeutronsDeltaRhoSquared
end
//
//
////******************************************************************************************************************
////******************************************************************************************************************
////******************************************************************************************************************
////******************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
//
Function IR1K_DisplayRightElement()

	NVAR SelectedElement=root:Packages:ScatteringContrast:SelectedElement
	NVAR NumberOfAtoms=root:Packages:ScatteringContrast:NumberOfAtoms
	if(SelectedElement<1 || SelectedElement>NumberOfAtoms)
		SelectedElement=1
	endif
	string ElementTypeString="root:Packages:ScatteringContrast:El"+num2str(SelectedElement)+"_type"
	string IsotopeTypeString="root:Packages:ScatteringContrast:El"+num2str(SelectedElement)+"_Isotope"
	string ElementContentVariable="root:Packages:ScatteringContrast:El"+num2str(SelectedElement)+"_content"
	DoWIndow IR1K_ScatteringContCalc
	if(NumberOfAtoms>0)
		if(V_Flag)
			//Execute("SetVariable ElementType, value= "+ElementTypeString+", win=IR1K_ScatteringContCalc")
			SetVariable ElementType, value= $(ElementTypeString), win=IR1K_ScatteringContCalc
			SetVariable Elementcontent,value=$(ElementContentVariable), win=IR1K_ScatteringContCalc
			Execute("PopupMenu ElementIsotope,mode=1,popvalue="+IsotopeTypeString+",value= #\"IR1K_ListTheIsotopes(root:Packages:ScatteringContrast:El"+num2str(SelectedElement)+"_type)\", win=IR1K_ScatteringContCalc")
			Slider ElementSelection, value=SelectedElement, win=IR1K_ScatteringContCalc
		endif
	else
		string/g $("root:Packages:ScatteringContrast:BlankString")
		SVAR BlankString=root:Packages:ScatteringContrast:BlankString
		BlankString=" "
		if(V_Flag)
			SetVariable ElementType, value= root:Packages:ScatteringContrast:BlankString, win=IR1K_ScatteringContCalc
			SetVariable Elementcontent,value= root:Packages:ScatteringContrast:BlankString, win=IR1K_ScatteringContCalc
			Execute("PopupMenu ElementIsotope,mode=1,popvalue=root:Packages:ScatteringContrast:BlankString,value= #\"IR1K_ListTheIsotopes(root:Packages:ScatteringContrast:El"+num2str(SelectedElement)+"_type)\", win=IR1K_ScatteringContCalc")
			//	Slider ElementSelection, disable = 1, win=IR1K_ScatteringContCalc	
		endif
	endif
	SVAR ElementType=$(ElementTypeString)
	SVAR IsotopeType=$(IsotopeTypeString)
	
	NVAR El_NumOfElectrons=root:Packages:ScatteringContrast:El_NumOfElectrons
	NVAR El_AtomWeight=root:Packages:ScatteringContrast:El_AtomWeight
	NVAR El_NeutronCohB=root:Packages:ScatteringContrast:El_NeutronCohB
	NVAR El_NeutronIncohB=root:Packages:ScatteringContrast:El_NeutronIncohB
	NVAR El_NeutronAbsCross=root:Packages:ScatteringContrast:El_NeutronAbsCross
	SVAR ListOfElNumbers=root:Packages:ScatteringContrast:ListOfElNumbers
	SVAR ListOfElAtomWghts=root:Packages:ScatteringContrast:ListOfElAtomWghts
	SVAR ListOfElNeutronBs=root:Packages:ScatteringContrast:ListOfElNeutronBs
	SVAR ListOfElNeuIncohBs=root:Packages:ScatteringContrast:ListOfElNeuIncohBs
	SVAR ListofNeutronAbsCross=root:Packages:ScatteringContrast:ListofNeutronAbsCross
	El_NumOfElectrons=NumberByKey(ElementType, ListOfElNumbers , "=", ";")
	El_AtomWeight=NumberByKey(ElementType, ListOfElAtomWghts , "=", ";")
	El_NeutronCohB=NumberByKey(ElementType+"_"+IsotopeType, ListOfElNeutronBs , "=", ";")
	El_NeutronIncohB=NumberByKey(ElementType+"_"+IsotopeType, ListOfElNeuIncohBs , "=", ";")
	El_NeutronAbsCross=NumberByKey(ElementType+"_"+IsotopeType, ListofNeutronAbsCross , "=", ";")
end
//
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
//
Function IR1K_BalanceWghtPerc()
	NVAR NumberOfAtoms=root:Packages:ScatteringContrast:NumberOfAtoms
	NVAR UseWeightPercent = root:Packages:ScatteringContrast:UseWeightPercent
	NVAR WeightPercentBalanceElem=root:Packages:ScatteringContrast:WeightPercentBalanceElem

	if(!UseWeightPercent || WeightPercentBalanceElem==0)
		return 0
	endif
	variable tempSum=0, i
	For(i=1;i<=NumberOfAtoms;i+=1)
		if(i!=WeightPercentBalanceElem)
			NVAR ElementContentVariable=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_content")
			tempSum+=ElementContentVariable
		endif
	endfor	
	if(tempSum>1)
		DoAlert 0, "To use balance element, the sum of weights of other elements must be less than 1"
		CheckBox BalanceElement, value=0, disable=0, win=IR1K_ScatteringContCalc
		WeightPercentBalanceElem=0
		tempSum=0
		abort
	endif
	
	NVAR ElementContentVariable=$("root:Packages:ScatteringContrast:El"+num2str(WeightPercentBalanceElem)+"_content")
	ElementContentVariable=1-tempSum


end
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************

Function IR1K_FixCompoundFormula()

	variable i
	string formula=""
	NVAR NumberOfAtoms=root:Packages:ScatteringContrast:NumberOfAtoms
	NVAR UseWeightPercent = root:Packages:ScatteringContrast:UseWeightPercent
	NVAR WeightPercentBalanceElem=root:Packages:ScatteringContrast:WeightPercentBalanceElem
	SVAR FormulaGlobal=root:Packages:ScatteringContrast:Formula
	SVAR ListOfElAtomWghts=root:Packages:ScatteringContrast:ListOfElAtomWghts
	variable breakDone=0
	variable scalingFac, sumMoles
	if(numtype(UseWeightPercent)!=0)
		UseWeightPercent=0
	endif
	IF (UseWeightPercent)
		// use sumMoles to help convert weight fraction to atomic fraction
		sumMoles = 0
		FOR (i=1;i<=NumberOfAtoms;i+=1)
			NVAR Elcontent=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_content")
			NVAR ElementWeight=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_AtomWeight")
			// sum the number of moles of each element/isotype
			sumMoles += Elcontent/ElementWeight
		ENDFOR
		NVAR ElementContentVariable=$("root:Packages:ScatteringContrast:El"+num2str(1)+"_content")
		NVAR ElementWeight=$("root:Packages:ScatteringContrast:El"+num2str(1)+"_AtomWeight")
		scalingFac=1/(ElementContentVariable/ElementWeight)
		if(numType(scalingFac)!=0)
			scalingFac=1
		endif
	endif
			
	For(i=1;i<=NumberOfAtoms;i+=1)
		SVAR ElementTypeString=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_type")
		SVAR IsotopeTypeString=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_Isotope")
		NVAR ElementContentVariable=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_content")
		NVAR ElementWeight=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_AtomWeight")
		ElementWeight= NumberByKey(ElementTypeString, ListOfElAtomWghts , "=", ";")
		
		formula+=ElementTypeString
		if (UseWeightPercent)
			if(strlen(ElementTypeString)!=0)
				formula+="\\B"+num2str(scalingFac*ElementContentVariable/ElementWeight)+"\\M"
			else
				formula+=" "
			endif
		else
			if(ElementContentVariable!=1 && strlen(ElementTypeString)!=0)
				formula+="\\B"+num2str(ElementContentVariable)+"\\M"
			else
				formula+=" "
			endif
		endif
		formula+=" "
		if(BreakDone==0 && strlen(formula)>150)
			formula+="\r"
			BreakDone=1
		endif
	endfor
	FormulaGlobal=formula

end

////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
//
//
Function IR1K_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
		NVAR UseMatrixVacuum=root:Packages:ScatteringContrast:UseMatrixVacuum


	if(cmpstr(ctrlName,"NumberOfElements")==0)
		//here we do what happens when we change number oif elements
		//IR1K_FixCheckboxes()
		NVAR NumberOfAtoms=root:Packages:ScatteringContrast:NumberOfAtoms
		NVAR UseWeightPercent=root:Packages:ScatteringContrast:UseWeightPercent
		NVAR WeightPercentBalanceElem=root:Packages:ScatteringContrast:WeightPercentBalanceElem
		if (UseWeightPercent)
			if(WeightPercentBalanceElem>NumberOfAtoms)
				WeightPercentBalanceElem=0
				CheckBox BalanceElement,disable=0,value=0
			endif
		endif
		variable length
		length = 100+NumberOfAtoms*30
		if(length>600)
			length=600
		endif
		if (NumberOfAtoms<=1)
			Slider ElementSelection win=IR1K_ScatteringContCalc, disable=1, size={length,100}
		else
			Slider ElementSelection win=IR1K_ScatteringContCalc, limits= {1,NumberOfAtoms,1 }, size={length,100}, disable=0, ticks=NumberOfAtoms-1
		endif
		if (NumberOfAtoms<1)
//			PopupMenu ElementType, disable=2
			SetVariable Elementcontent, disable=2
			PopupMenu ElementIsotope, disable=2
		else
//			PopupMenu ElementType, disable=0
			SetVariable Elementcontent, disable=0
			PopupMenu ElementIsotope, disable=0
		endif
		IR1K_DisplayRightElement()
	endif
	if(cmpstr(ctrlName,"density")==0)
		//here we do what happens when we change density
	endif
	SVAR UsedMatrixCompound=root:Packages:ScatteringContrast:UsedMatrixCompound
	if(cmpstr(ctrlName,"MatrixScattContXrays")==0)
		UsedMatrixCompound=""
		UseMatrixVacuum=0
	endif
	if(cmpstr(ctrlName,"MatrixScattContNeutrons")==0)
		UsedMatrixCompound=""
		UseMatrixVacuum=0
	endif
	if(cmpstr(ctrlName,"AvailableCompoundsMask")==0)
		IR1K_UpdateCalcExportDta()	
	endif
	
	
	if(cmpstr(ctrlName,"Elementcontent")==0)
		//here we do what happens when we change element content
		NVAR SelectedElement=root:Packages:ScatteringContrast:SelectedElement
		NVAR ElementContentVariable=$("root:Packages:ScatteringContrast:El"+num2str(SelectedElement)+"_content")
		ElementContentVariable = varNum
	endif

	DoUpdate
	IR1K_BalanceWghtPerc()
	IR1K_FixCompoundFormula()
	IR1K_CalcMolWeightEtc()
End
//
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
Function IR1K_CheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	variable i
	NVAR SelectedElement=root:Packages:ScatteringContrast:SelectedElement
	NVAR NumberOfAtoms=root:Packages:ScatteringContrast:NumberOfAtoms
	NVAR WeightPercentBalanceElem=root:Packages:ScatteringContrast:WeightPercentBalanceElem

	if (cmpstr(ctrlName[0,7],"Element_")==0)
		SelectedElement=0
		
		For(i=1;i<=NumberOfAtoms;i+=1)
			if(cmpstr(ctrlName,"Element_"+num2str(i))==0)
				SelectedElement=i
			endif
		endfor
//		IR1K_FixCheckboxes2()
		IR1K_DisplayRightElement()
	endif

	if(cmpstr(ctrlName,"BalanceElement")==0)
		//user checked weight percent button
		if(checked)
			WeightPercentBalanceElem=SelectedElement			//store, which element user wants to use as babalnce
		else
			WeightPercentBalanceElem=0
		endif
		IR1K_BalanceWghtPerc()
		IR1K_FixCompoundFormula()
		IR1K_FixDisplayedVariables()
		IR1K_CalcMolWeightEtc()
	endif
	if(cmpstr(ctrlName,"StoreCompoundsInIgorExperiment")==0)
		IR1K_UpdateCalcExportDta()
	endif

	if(cmpstr(ctrlName,"WeightPercent")==0)
		//user checked weight percent button
		IR1K_BalanceWghtPerc()
		IR1K_FixCompoundFormula()
		IR1K_FixDisplayedVariables()
		IR1K_CalcMolWeightEtc()
	endif
	if(cmpstr(ctrlName,"UseMatrixVacuum")==0)
		if(checked)
			button SetAsMatrix, disable=2, win=IR1K_ScatteringContCalc
		else
			button SetAsMatrix, disable=0, win=IR1K_ScatteringContCalc
		endif
		SVAR UsedMatrixCompound=root:Packages:ScatteringContrast:UsedMatrixCompound
		NVAR MatrixScattContXrays=root:Packages:ScatteringContrast:MatrixScattContXrays
		NVAR MatrixScattContNeutrons=root:Packages:ScatteringContrast:MatrixScattContNeutrons
		UsedMatrixCompound="vacuum"
		MatrixScattContXrays=0
		MatrixScattContNeutrons=0
		IR1K_BalanceWghtPerc()
//		IR1K_FixCompoundFormula()
		IR1K_FixDisplayedVariables()
		IR1K_CalcMolWeightEtc()
	endif
	DoUpdate 
End

////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
Function IR1K_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	variable i
	NVAR SelectedElement=root:Packages:ScatteringContrast:SelectedElement
	NVAR NumberOfAtoms=root:Packages:ScatteringContrast:NumberOfAtoms
	SVAR ElementTypeString=$("root:Packages:ScatteringContrast:El"+num2str(SelectedElement)+"_type")
	SVAR IsotopeTypeString=$("root:Packages:ScatteringContrast:El"+num2str(SelectedElement)+"_Isotope")

	if(cmpstr(ctrlName,"ElementType")==0)
		//element type changed
		ElementTypeString =  popStr
		IsotopeTypeString = "natural"
		IR1K_DisplayRightElement()
	endif
	if(cmpstr(ctrlName,"ElementIsotope")==0)
		//element type changed
		IsotopeTypeString =  popStr
		IR1K_DisplayRightElement()
	endif
	
	IR1K_BalanceWghtPerc()
	IR1K_FixCompoundFormula()
	IR1K_CalcMolWeightEtc()
End

////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
//
Function IR1K_InitializeScattContrast()


	string oldDf=GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:ScatteringContrast
	
	string ListOfVariables
	string ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="FirstInitialize;Density;MolWeight;WghtOf1Mol;NumOfMolin1cm3;NumOfElperMol;NumOfElincm3;ScattContrXrays;"
	ListOfVariables+="NumberOfAtoms;ScattContrNeutrons;MatrixScattContXrays;MatrixScattContNeutrons;CalcXrays;CalcNeutrons;XraysNeutronsRatio;"
	ListOfVariables+="NeutronTotalMolB;NeutronsVolume1Mol;NeutronsScatlengthDens;XraysDeltaRhoSquared;NeutronsDeltaRhoSquared;"
	ListOfVariables+="El1_content;El1_NumOfElectrons;El1_AtomWeight;El1_NeutronCohB;El1_NeutronIncohB;El1_NeutronAbsCross;"
	ListOfVariables+="El2_content;El2_NumOfElectrons;El2_AtomWeight;El2_NeutronCohB;El2_NeutronIncohB;El2_NeutronAbsCross;"
	ListOfVariables+="El3_content;El3_NumOfElectrons;El3_AtomWeight;El3_NeutronCohB;El3_NeutronIncohB;El3_NeutronAbsCross;"
	ListOfVariables+="El4_content;El4_NumOfElectrons;El4_AtomWeight;El4_NeutronCohB;El4_NeutronIncohB;El4_NeutronAbsCross;"
	ListOfVariables+="El5_content;El5_NumOfElectrons;El5_AtomWeight;El5_NeutronCohB;El5_NeutronIncohB;El5_NeutronAbsCross;"
	ListOfVariables+="El6_content;El6_NumOfElectrons;El6_AtomWeight;El6_NeutronCohB;El6_NeutronIncohB;El6_NeutronAbsCross;"
	ListOfVariables+="El7_content;El7_NumOfElectrons;El7_AtomWeight;El7_NeutronCohB;El7_NeutronIncohB;El7_NeutronAbsCross;"
	ListOfVariables+="El8_content;El8_NumOfElectrons;El8_AtomWeight;El8_NeutronCohB;El8_NeutronIncohB;El8_NeutronAbsCross;"
	ListOfVariables+="El9_content;El9_NumOfElectrons;El9_AtomWeight;El9_NeutronCohB;El9_NeutronIncohB;El9_NeutronAbsCross;"
	ListOfVariables+="El10_content;El10_NumOfElectrons;El10_AtomWeight;El10_NeutronCohB;El10_NeutronIncohB;El10_NeutronAbsCross;"
	ListOfVariables+="El11_content;El11_NumOfElectrons;El11_AtomWeight;El11_NeutronCohB;El11_NeutronIncohB;El11_NeutronAbsCross;"
	ListOfVariables+="El12_content;El12_NumOfElectrons;El12_AtomWeight;El12_NeutronCohB;El12_NeutronIncohB;El12_NeutronAbsCross;"
	ListOfVariables+="El13_content;El13_NumOfElectrons;El13_AtomWeight;El13_NeutronCohB;El13_NeutronIncohB;El13_NeutronAbsCross;"
	ListOfVariables+="El14_content;El14_NumOfElectrons;El14_AtomWeight;El14_NeutronCohB;El14_NeutronIncohB;El14_NeutronAbsCross;"
	ListOfVariables+="El15_content;El15_NumOfElectrons;El15_AtomWeight;El15_NeutronCohB;El15_NeutronIncohB;El15_NeutronAbsCross;"
	ListOfVariables+="El16_content;El16_NumOfElectrons;El16_AtomWeight;El16_NeutronCohB;El16_NeutronIncohB;El16_NeutronAbsCross;"
	ListOfVariables+="El17_content;El17_NumOfElectrons;El17_AtomWeight;El17_NeutronCohB;El17_NeutronIncohB;El17_NeutronAbsCross;"
	ListOfVariables+="El18_content;El18_NumOfElectrons;El18_AtomWeight;El18_NeutronCohB;El18_NeutronIncohB;El18_NeutronAbsCross;"
	ListOfVariables+="El19_content;El19_NumOfElectrons;El19_AtomWeight;El19_NeutronCohB;El19_NeutronIncohB;El19_NeutronAbsCross;"
	ListOfVariables+="El20_content;El20_NumOfElectrons;El20_AtomWeight;El20_NeutronCohB;El20_NeutronIncohB;El20_NeutronAbsCross;"
	ListOfVariables+="El21_content;El21_NumOfElectrons;El21_AtomWeight;El21_NeutronCohB;El21_NeutronIncohB;El21_NeutronAbsCross;"
	ListOfVariables+="El22_content;El22_NumOfElectrons;El22_AtomWeight;El22_NeutronCohB;El22_NeutronIncohB;El22_NeutronAbsCross;"
	ListOfVariables+="El23_content;El23_NumOfElectrons;El23_AtomWeight;El23_NeutronCohB;El23_NeutronIncohB;El23_NeutronAbsCross;"
	ListOfVariables+="El24_content;El24_NumOfElectrons;El24_AtomWeight;El24_NeutronCohB;El24_NeutronIncohB;El24_NeutronAbsCross;"
	ListOfVariables+="El_content;El_NumOfElectrons;El_AtomWeight;El_NeutronCohB;El_NeutronIncohB;El_NeutronAbsCross;"
	ListOfVariables+="SelectedElement;UseWeightPercent;WeightPercentBalanceElem;UseMatrixVacuum;"
	ListOfVariables+="StoreCompoundsInIgorExperiment;ScattContrXraysPerGram;NeutronsScatlengthDensPerGram;"
	
	ListOfVariables+="Anom_UseSingleEnergy;Anom_UseEnergyRange;Anom_CalcEnergyContrast;Anom_CalcAbsorption;Anom_MatrixVacuum;Anom_QvalueUsed;"
	ListOfVariables+="Anom_SingleEnergy;Anom_EnergyStart;Anom_EnergyEnd;Anom_EnergyNumSteps;Anom_DisplayGraph;"
	ListOfVariables+="Anom_Thickness;Display_DRhoSq;Disp_FPrime_1;Disp_FDoublePrime_1;Disp_F_1;Disp_MuOverRho_1;Disp_OneOverMu_1;Disp_Mu_1;Disp_eToMinusMuT_1;"
	ListOfVariables+="Disp_FPrime_2;Disp_FDoublePrime_2;Disp_F_2;Disp_MuOverRho_2;Disp_OneOverMu_2;Disp_Mu_2;Disp_eToMinusMuT_2;"	
	ListOfVariables+="SingE_F_1;SingE_F0_1;SingE_Fprime_1;SingE_F0Fprime_1;SingE_FdoublePrime_1;SingE_MuOverRho_1;SingE_OneOverMu_1;SingE_Mu_1;SingE_eToMInusMuT_1;SingE_DRhoSq;"	
	ListOfVariables+="SingE_F_2;SingE_F0_2;SingE_Fprime_2;SingE_F0Fprime_2;SingE_FdoublePrime_2;SingE_MuOverRho_2;SingE_OneOverMu_2;SingE_Mu_2;SingE_eToMInusMuT_2;"
	ListOfVariables+="SingE_F0DRHO_1;SingE_FprimeDRHO_1;SingE_F0FprimeDRHO_1;SingE_FdoublePrimeDRHO_1;SingE_Fdrho_1;SingE_FDPrho_1;"
	ListOfVariables+="SingE_F0DRHO_2;SingE_FprimeDRHO_2;SingE_F0FprimeDRHO_2;SingE_FdoublePrimeDRHO_2;SingE_Fdrho_2;SingE_FDPrho_2;"
	
	ListOfStrings="ListOfElements;ListOfElNumbers;ListOfElAtomWghts;Formula;"
	ListOfStrings+="ListOfIsotopes;ListOfElNeutronBs;ListOfElNeuIncohBs;ListofNeutronAbsCross;"
	ListOfStrings+="El1_type;El1_Isotope;"
	ListOfStrings+="El2_type;El2_Isotope;"
	ListOfStrings+="El3_type;El3_Isotope;"
	ListOfStrings+="El4_type;El4_Isotope;"
	ListOfStrings+="El5_type;El5_Isotope;"
	ListOfStrings+="El6_type;El6_Isotope;"
	ListOfStrings+="El7_type;El7_Isotope;"
	ListOfStrings+="El8_type;El8_Isotope;"
	ListOfStrings+="El9_type;El9_Isotope;"
	ListOfStrings+="El10_type;El10_Isotope;"
	ListOfStrings+="El11_type;El11_Isotope;"
	ListOfStrings+="El12_type;El12_Isotope;"
	ListOfStrings+="El13_type;El13_Isotope;"
	ListOfStrings+="El14_type;El14_Isotope;"
	ListOfStrings+="El15_type;El15_Isotope;"
	ListOfStrings+="El16_type;El16_Isotope;"
	ListOfStrings+="El17_type;El17_Isotope;"
	ListOfStrings+="El18_type;El18_Isotope;"
	ListOfStrings+="El19_type;El19_Isotope;"
	ListOfStrings+="El20_type;El20_Isotope;"
	ListOfStrings+="El21_type;El21_Isotope;"
	ListOfStrings+="El22_type;El22_Isotope;"
	ListOfStrings+="El23_type;El23_Isotope;"
	ListOfStrings+="El24_type;El24_Isotope;"
	ListOfStrings+="ListOfAvailableCompounds;UsedMatrixCompound;LastLoadedCompound;SelectedElementName;AvailableCompoundsMask;"
	ListOfStrings+="Anom_Compound1;Anom_Compound2;Anom_CompFormula1;Anom_CompFormula2;"
	
	variable /C SingE_F_1, SingE_F_2
	
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	
	NVAR FirstInitialize
	if (FirstInitialize == 0)
		IR1K_SetLookupLists()
		IR1K_DefaultValues()
	endif
	FirstInitialize = 1
	NVAR Anom_UseSingleEnergy
	Anom_UseSingleEnergy=1
	NVAR Anom_UseEnergyRange
	Anom_UseEnergyRange=0
	NVAR Anom_CalcEnergyContrast
	Anom_CalcEnergyContrast=1
	NVAR Anom_CalcAbsorption
	Anom_CalcAbsorption=1
	NVAR Anom_SingleEnergy
	Anom_SingleEnergy=10
	NVAR Anom_EnergyStart
	Anom_EnergyStart=10
	NVAR Anom_EnergyEnd
	Anom_EnergyEnd=12
	NVAR Anom_EnergyNumSteps
	Anom_EnergyNumSteps=20
	NVAR Anom_DisplayGraph
	Anom_DisplayGraph=1
	NVAR Anom_Thickness
	Anom_Thickness=0.1
	NVAR Anom_QvalueUsed
	Anom_QvalueUsed=0
	NVAR UseMatrixVacuum
	UseMatrixVacuum=1
	SVAR UsedMatrixCompound
	UsedMatrixCompound="vacuum"

end
////******************************************************************************************************************
////******************************************************************************************************************
////******************************************************************************************************************
////******************************************************************************************************************
//
Function IR1K_DefaultValues()

	string oldDf=GetDataFolder(1)
	
	SetDataFolder root:Packages:ScatteringContrast
	
	string ListOfVariables

	NVAR Density=root:Packages:ScatteringContrast:Density
	NVAR CalcXrays=root:Packages:ScatteringContrast:CalcXrays
	if (Density<=0)
		Density = 1
	endif
	if(CalcXrays ==0)
		CalcXrays = 1
	endif
	SetDataFolder oldDf
end
//
//
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
//
Function IR1K_ScatCont2SliderProc(ctrlName,sliderValue,event)
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	if((cmpstr(ctrlName,"ElementSelection")==0) && (event %& 0x1))	// bit 0, value set
		//do something here
		NVAR SelectedElement=root:Packages:ScatteringContrast:SelectedElement
		SelectedElement=sliderValue
		IR1K_BalanceWghtPerc()
		IR1K_FixDisplayedVariables()
		IR1K_DisplayRightElement()
	endif

	return 0
End
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
////*******************************************************************************************************************************************
//
Function IR1K_InitCalculatorExportDta()

	string OldDf=GetDataFolder(1)
	//create if does not exist the internal place for styles
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:ScatteringContrast

	SVAR ListOfAvailableCompounds=root:Packages:ScatteringContrast:ListOfAvailableCompounds
	NVAR StoreCompoundsInIgorExperiment = root:Packages:ScatteringContrast:StoreCompoundsInIgorExperiment
	
	//Now outside
	PathInfo Igor
	string IgorPathStr=S_Path
	string WhereAreProcedures=RemoveEnding(FunctionPath(""),"Irena:IR1_ScattContr_New.ipf")

	string/g StylePath=WhereAreProcedures+"Irena_CalcSavedCompounds"
	NewPath/C/O/Q/Z CalcSavedCompounds, StylePath
	if(V_flag!=0)	//user cannot write in the place where procedures are... Force user to use only internal storage of compounds....
		StoreCompoundsInIgorExperiment=1
	endif
	
		string OldDf1=GetDataFolder(1)
		SetDataFolder root:Packages
		NewDataFolder/O/S root:Packages:IrenaSavedCompounds
		SetDataFolder OldDf1
	if(StoreCompoundsInIgorExperiment)
		OldDf1=GetDataFolder(1)
		SetDataFolder root:Packages:IrenaSavedCompounds
		ListOfAvailableCompounds=DataFolderDir(8)[8,strlen(DataFolderDir(8))-2]
		ListOfAvailableCompounds=ReplaceString(",", ListOfAvailableCompounds, ";")	
		SetDataFolder OldDf1	
	else
		ListOfAvailableCompounds=IndexedFile(CalcSavedCompounds,-1,".dat")
	endif
	Make/O/T/N=(ItemsInList(ListOfAvailableCompounds)) WaveOfCompoundsOutsideIgor
	Make/O/N=(ItemsInList(ListOfAvailableCompounds)) NumbersOfCompoundsOutsideIgor
	variable i
	For(i=0;i<ItemsInList(ListOfAvailableCompounds);i+=1)
		WaveOfCompoundsOutsideIgor[i]=StringFromList(i, ListOfAvailableCompounds)[0,strlen(StringFromList(i, ListOfAvailableCompounds))-5]
	endfor
	SVAR AvailableCompoundsMask=root:Packages:ScatteringContrast:AvailableCompoundsMask
	grep/E=(AvailableCompoundsMask) WaveOfCompoundsOutsideIgor as WaveOfCompoundsOutsideIgor
	redimension/N=(numpnts(WaveOfCompoundsOutsideIgor)) NumbersOfCompoundsOutsideIgor
	sort WaveOfCompoundsOutsideIgor, NumbersOfCompoundsOutsideIgor
	
	setDataFolder oldDf
end
//
////**********************************************************************************************************
////**********************************************************************************************************
////**********************************************************************************************************
Function IR1K_UpdateCalcExportDta()

	string OldDf=GetDataFolder(1)
	SetdataFolder root:Packages:ScatteringContrast
	//create if does not exist the internal place for styles
	
	NVAR StoreCompoundsInIgorExperiment = root:Packages:ScatteringContrast:StoreCompoundsInIgorExperiment
	
	SVAR ListOfAvailableCompounds=root:Packages:ScatteringContrast:ListOfAvailableCompounds
	
	if(StoreCompoundsInIgorExperiment)
		string OldDf1=GetDataFolder(1)
		SetDataFolder root:Packages
		NewDataFolder/O/S root:Packages:IrenaSavedCompounds
		ListOfAvailableCompounds=DataFolderDir(8)[8,strlen(DataFolderDir(8))-2]
		ListOfAvailableCompounds=ReplaceString(",", ListOfAvailableCompounds, ";")
		SetDataFolder OldDf1
	else
		ListOfAvailableCompounds=IndexedFile(CalcSavedCompounds,-1,".dat")
	endif
	ListOfAvailableCompounds = IN2G_RemoveInvisibleFiles(ListOfAvailableCompounds)
	Make/O/T/N=(ItemsInList(ListOfAvailableCompounds)) WaveOfCompoundsOutsideIgor
	Make/O/N=(ItemsInList(ListOfAvailableCompounds)) NumbersOfCompoundsOutsideIgor
	variable i
	For(i=0;i<ItemsInList(ListOfAvailableCompounds);i+=1)
		if(StoreCompoundsInIgorExperiment)
			WaveOfCompoundsOutsideIgor[i]=StringFromList(i, ListOfAvailableCompounds)
		else
			WaveOfCompoundsOutsideIgor[i]=StringFromList(i, ListOfAvailableCompounds)[0,strlen(StringFromList(i, ListOfAvailableCompounds))-5]
		endif
	endfor
	SVAR AvailableCompoundsMask=root:Packages:ScatteringContrast:AvailableCompoundsMask
	grep/E=(AvailableCompoundsMask) WaveOfCompoundsOutsideIgor as WaveOfCompoundsOutsideIgor
	redimension/N=(numpnts(WaveOfCompoundsOutsideIgor)) NumbersOfCompoundsOutsideIgor
	sort WaveOfCompoundsOutsideIgor, WaveOfCompoundsOutsideIgor		//, NumbersOfCompoundsOutsideIgor
	
	setDataFolder oldDf
end
//
////**********************************************************************************************************
////**********************************************************************************************************
////**********************************************************************************************************
//
//
Function  IR1K_LoadDataCompound()

	string OldDf=GetDataFolder(1)
	SetdataFolder root:Packages:ScatteringContrast

	NVAR Density=root:Packages:ScatteringContrast:Density
	NVAR NumberOfAtoms=root:Packages:ScatteringContrast:NumberOfAtoms
	NVAR ScattContrXrays=root:Packages:ScatteringContrast:ScattContrXrays
	NVAR NeutronsScatlengthDens=root:Packages:ScatteringContrast:NeutronsScatlengthDens
	NVAR UseWeightPercent=root:Packages:ScatteringContrast:UseWeightPercent
	NVAR WeightPercentBalanceElem=root:Packages:ScatteringContrast:WeightPercentBalanceElem
	SVAR LastLoadedCompound=root:Packages:ScatteringContrast:LastLoadedCompound
	Wave/T WaveOfCompoundsOutsideIgor

	NVAR StoreCompoundsInIgorExperiment = root:Packages:ScatteringContrast:StoreCompoundsInIgorExperiment

	variable i
	string testNm, LoadedString, ExecComm
	ControlInfo/W=IR1K_ScatteringContCalc ListOfAvailableData
	i = V_Value
	if (i>=0)
		if(StoreCompoundsInIgorExperiment)
			testNm=WaveOfCompoundsOutsideIgor[i]
			if(strlen(testNm)<1)
				abort
			endif
			SVAR LoadedStrVal=$("root:Packages:IrenaSavedCompounds:"+testNm)
			LoadedString = LoadedStrVal
		else
			testNm=WaveOfCompoundsOutsideIgor[i]+".dat"
			LoadWave/J/Q/P=CalcSavedCompounds/K=2/N=ImportData/V={"\t"," $",0,1} testNm
			Wave/T LoadedData=root:Packages:ScatteringContrast:ImportData0
			LoadedString = LoadedData[0]
			KillWaves/Z LoadedData
		endif
	endif
	LastLoadedCompound=stringFromList(0,testNm,".")

	
	NumberOfAtoms=NumberByKey("NumberOfAtoms", LoadedString  , "=" )
	Density=NumberByKey("Density", LoadedString  , "=" )
	ScattContrXrays=NumberByKey("ScattContrXrays", LoadedString  , "=" )
	NeutronsScatlengthDens=NumberByKey("NeutronsScatlengthDens", LoadedString  , "=" )
	UseWeightPercent=NumberByKey("UseWeightPercent", LoadedString  , "=" )
	WeightPercentBalanceElem=NumberByKey("WeightPercentBalanceElem", LoadedString  , "=" )
	if (numtype(WeightPercentBalanceElem)!=0)
		WeightPercentBalanceElem=0
	endif
	For(i=1;i<=NumberOfAtoms;i+=1)
		SVAR El_type=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_type")
		SVAR El_Isotope=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_Isotope")
		NVAR El_content=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_content")

		El_content=NumberByKey("El"+num2str(i)+"_content", LoadedString  , "=" )
		El_Isotope=StringByKey("El"+num2str(i)+"_Isotope", LoadedString  , "=" )
		El_type=StringByKey("El"+num2str(i)+"_type", LoadedString  , "=" )
	endfor

	NVAR SelectedElement=root:Packages:ScatteringContrast:SelectedElement
	Slider ElementSelection win=IR1K_ScatteringContCalc, limits= {1,NumberOfAtoms,1 }, value=1
	SelectedElement=1
	IR1K_BalanceWghtPerc()
	IR1K_DisplayRightElement()
	IR1K_FixDisplayedVariables()
	IR1K_FixCompoundFormula()
	IR1K_CalcMolWeightEtc()
	setDataFolder oldDf

end
//
//
////**********************************************************************************************************
////**********************************************************************************************************
////**********************************************************************************************************
//
Function  IR1K_CleanCompoundTool()

	string OldDf=GetDataFolder(1)
	SetdataFolder root:Packages:ScatteringContrast

	NVAR Density=root:Packages:ScatteringContrast:Density
	NVAR NumberOfAtoms=root:Packages:ScatteringContrast:NumberOfAtoms
	NVAR ScattContrXrays=root:Packages:ScatteringContrast:ScattContrXrays
	NVAR NeutronsScatlengthDens=root:Packages:ScatteringContrast:NeutronsScatlengthDens
	NVAR UseWeightPercent=root:Packages:ScatteringContrast:UseWeightPercent
	NVAR WeightPercentBalanceElem=root:Packages:ScatteringContrast:WeightPercentBalanceElem
	NVAR UseMatrixVacuum=root:Packages:ScatteringContrast:UseMatrixVacuum
	SVAR LastLoadedCompound=root:Packages:ScatteringContrast:LastLoadedCompound
	SVAR UsedMatrixCompound=root:Packages:ScatteringContrast:UsedMatrixCompound
	Wave/T WaveOfCompoundsOutsideIgor
	variable i
	string testNm, LoadedString, ExecComm

	UseMatrixVacuum=1
	UsedMatrixCompound="vacuum"
	LastLoadedCompound=""
	NumberOfAtoms=0
	Density=0
	ScattContrXrays=0
	NeutronsScatlengthDens=0
	UseWeightPercent=0
	WeightPercentBalanceElem=0
	if (numtype(WeightPercentBalanceElem)!=0)
		WeightPercentBalanceElem=0
	endif
	For(i=1;i<=24;i+=1)
		SVAR El_type=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_type")
		SVAR El_Isotope=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_Isotope")
		NVAR El_content=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_content")

		El_content=0
		El_Isotope=""
		El_type=""
	endfor

	NVAR SelectedElement=root:Packages:ScatteringContrast:SelectedElement
	Slider ElementSelection win=IR1K_ScatteringContCalc, limits= {1,NumberOfAtoms,1 }, value=1
	SelectedElement=1
	IR1K_BalanceWghtPerc()
	IR1K_DisplayRightElement()
	IR1K_FixDisplayedVariables()
	IR1K_FixCompoundFormula()
	IR1K_CalcMolWeightEtc()
	setDataFolder oldDf

end
//
//
////**********************************************************************************************************
////**********************************************************************************************************
////**********************************************************************************************************
//
//
Function  IR1K_DeleteDataCompound()

	string OldDf=GetDataFolder(1)
	SetdataFolder root:Packages:ScatteringContrast


	NVAR StoreCompoundsInIgorExperiment = root:Packages:ScatteringContrast:StoreCompoundsInIgorExperiment

//		if(StoreCompoundsInIgorExperiment)
//			testNm=WaveOfCompoundsOutsideIgor[i]
//			SVAR LoadedStrVal=$("root:Packages:IrenaSavedCompounds:"+testNm)
//			LoadedString = LoadedStrVal

	Wave/T WaveOfCompoundsOutsideIgor
	variable i
	string testNm, LoadedString, ExecComm
	ControlInfo/W=IR1K_ScatteringContCalc ListOfAvailableData
	i = V_Value
	if (i>=0)
		if(StoreCompoundsInIgorExperiment)
			testNm=WaveOfCompoundsOutsideIgor[i]
			if(strlen(testNm)<1)
				abort
			endif
			string OldDf1=GetDataFolder(1)
			setDataFolder root:Packages
			setDataFolder root:Packages:IrenaSavedCompounds
			killstrings $testNm
			setDataFolder OldDf1	
		else
			testNm=WaveOfCompoundsOutsideIgor[i]+".dat"
			OpenNotebook/P=CalcSavedCompounds /V=0/N=testNbk testNm
			DoWindow /D/K testNbk
		endif
	endif

	setDataFolder oldDf
	IR1K_UpdateCalcExportDta()

end
////**********************************************************************************************************
////**********************************************************************************************************
////**********************************************************************************************************
//
//
//
Function IR1K_ListBoxProc(ctrlName,row,col,event)
	String ctrlName
	Variable row
	Variable col
	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
					//5=cell select with shift key, 6=begin edit, 7=end
	
	if (cmpstr(ctrlName,"CompoundSelection")==0)
	
		Wave/T  WaveOfCompoundsOutsideIgor=root:Packages:ScatteringContrast:WaveOfCompoundsOutsideIgor
		Wave NumbersOfCompoundsOutsideIgor=root:Packages:ScatteringContrast:NumbersOfCompoundsOutsideIgor
	
		if (sum(NumbersOfCompoundsOutsideIgor,-inf,inf)>2)
			variable num1sFOund=0
			variable i
			For(i=0;i<(numpnts(NumbersOfCompoundsOutsideIgor));i+=1)
				if(NumbersOfCompoundsOutsideIgor[i]==1)
					num1sFOund+=1
					if(num1sFOund>2)
						NumbersOfCompoundsOutsideIgor[i]=0
					endif
				endif
			endfor
			
		endif
	endif
	return 0
End
//
////**********************************************************************************************************
////**********************************************************************************************************
////**********************************************************************************************************
//
Function IR1K_AnomCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	NVAR Anom_UseSingleEnergy=root:Packages:ScatteringContrast:Anom_UseSingleEnergy
	NVAR Anom_UseEnergyRange=root:Packages:ScatteringContrast:Anom_UseEnergyRange

	if(cmpstr(ctrlName,"StoreCompoundsInIgorExperiment")==0)
		IR1K_UpdateCalcExportDta()
	endif
	if(cmpstr(ctrlName,"Anom_UseSingleEnergy")==0)
		if(checked)
			Anom_UseEnergyRange=0
			SetVariable OneEnergy, disable=0
			SetVariable EnergyStart, disable=1
			SetVariable EnergyEnd, disable=1
			SetVariable EnergyNumberOfSteps, disable=1

			SetVariable Sing_F0_1, disable=0 
			SetVariable Sing_FPrime_1, disable=0
			SetVariable Sing_FDoublePrime_1, disable=0
			SetVariable Sing_MuOverRho_1, disable=0
			SetVariable Sing_Mu_1 , disable=0
			SetVariable Sing_1OverMu_1, disable=0
			SetVariable Sing_eToMinusMuT_1, disable=0
			SetVariable Sing_F0_2, disable=0 
			SetVariable Sing_F0FPrime_1, disable=0 
			SetVariable Sing_F0FPrime_2, disable=0 
			SetVariable Sing_FPrime_2, disable=0
			SetVariable Sing_FDoublePrime_2, disable=0
			SetVariable Sing_MuOverRho_2, disable=0
			SetVariable Sing_Mu_2 , disable=0
			SetVariable Sing_1OverMu_2, disable=0
			SetVariable Sing_eToMinusMuT_2, disable=0
			SetVariable Sing_Contrast, disable=0
			SetVariable SingE_Fdrho_1, disable=0
			SetVariable SingE_Fdrho_2, disable=0
			SetVariable SingE_FDPrho_1, disable=0
			SetVariable SingE_FDPrho_2, disable=0

			Button DisplayDeltaRhoSquared, disable=1
			Button DisplayFDoublePrime, disable=1
			Button DisplayFPrime, disable=1
			Button DisplayMuOverRho, disable=1
			Button DisplayOneOverMu, disable=1
			Button DisplayeToMinusMuT, disable=1
			Button DisplayF0FPrime, disable=1
			Button SaveF0FPrime1, disable=1
			Button SaveF0FPrime2, disable=1

			Button SaveDeltaRhoSquared, disable=1
			Button SaveFPrime1, disable=1
			Button SaveFDoublePrime1, disable=1
			Button SaveMuOverRho1, disable=1
			Button SaveOneOverMu1, disable=1
			Button SaveToMinusMuT1, disable=1
			Button SaveFPrime2, disable=1
			Button SaveFDoublePrime2, disable=1
			Button SaveMuOverRho2, disable=1
			Button SaveOneOverMu2, disable=1
			Button SaveToMinusMuT2, disable=1
			IR1K_KillAllGraphs()
			IR1K_ClearData()
		endif
	endif
	if(cmpstr(ctrlName,"Anom_UseEnergyRange")==0)
		if(checked)
			Anom_UseSingleEnergy=0
			SetVariable OneEnergy, disable=1
			SetVariable EnergyStart, disable=0
			SetVariable EnergyEnd, disable=0
			SetVariable EnergyNumberOfSteps, disable=0

			SetVariable Sing_F0_1, disable=1 
			SetVariable Sing_FPrime_1, disable=1
			SetVariable Sing_FDoublePrime_1, disable=1
			SetVariable Sing_MuOverRho_1, disable=1
			SetVariable Sing_Mu_1 , disable=1
			SetVariable Sing_1OverMu_1, disable=1
			SetVariable Sing_eToMinusMuT_1, disable=1
			SetVariable Sing_F0_2, disable=1 
			SetVariable Sing_FPrime_2, disable=1
			SetVariable Sing_F0FPrime_1, disable=1 
			SetVariable Sing_F0FPrime_2, disable=1 
			SetVariable Sing_FDoublePrime_2, disable=1
			SetVariable Sing_MuOverRho_2, disable=1
			SetVariable Sing_Mu_2 , disable=1
			SetVariable Sing_1OverMu_2, disable=1
			SetVariable Sing_eToMinusMuT_2, disable=1
			SetVariable Sing_Contrast, disable=1
			SetVariable SingE_Fdrho_1, disable=1
			SetVariable SingE_Fdrho_2, disable=1
			SetVariable SingE_FDPrho_1, disable=1
			SetVariable SingE_FDPrho_2, disable=1
			Button DisplayDeltaRhoSquared, disable=0
			Button DisplayFDoublePrime, disable=0
			Button DisplayFPrime, disable=0
			Button DisplayMuOverRho, disable=0
			Button DisplayOneOverMu, disable=0
			Button DisplayeToMinusMuT, disable=0
			Button DisplayF0FPrime, disable=0
			Button SaveF0FPrime1, disable=0
			Button SaveF0FPrime2, disable=0

			Button SaveDeltaRhoSquared, disable=0

			Button SaveFPrime1, disable=0
			Button SaveFDoublePrime1, disable=0
			Button SaveMuOverRho1, disable=0
			Button SaveOneOverMu1, disable=0
			Button SaveToMinusMuT1, disable=0
			Button SaveFPrime2, disable=0
			Button SaveFDoublePrime2, disable=0
			Button SaveMuOverRho2, disable=0
			Button SaveOneOverMu2, disable=0
			Button SaveToMinusMuT2, disable=0
			IR1K_ClearData()
		endif

	endif
		NVAR Anom_MatrixVacuum=root:Packages:ScatteringContrast:Anom_MatrixVacuum
	if(cmpstr(ctrlName,"Anom_MatrixVacuum")==0)
		if(checked)
			ListBox CompoundSelection, mode= 1, win=IR1K_AnomCalcPnl
		else
			ListBox CompoundSelection, mode= 4, win=IR1K_AnomCalcPnl		
		endif
		IR1K_ClearData()
	endif
End
//
////**********************************************************************************************************
////**********************************************************************************************************
////**********************************************************************************************************
//
Function IR1K_AnomSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	if(cmpstr("OneEnergy",ctrlName)==0)
		//here we update what is necessary if user wants to calc stuff at 1 energy only
	endif
	if(cmpstr("EnergyStart",ctrlName)==0)
		//here we update what is necessary if user wants to calc stuff at range of energies
	endif
	if(cmpstr("EnergyEnd",ctrlName)==0)
		//here we update what is necessary if user wants to calc stuff at range of energies
	endif
	if(cmpstr("EnergyNumberOfSteps",ctrlName)==0)
		//here we update what is necessary if user wants to calc stuff at range of energies
	endif
	if(cmpstr("Thickness",ctrlName)==0)
		variable i
		For(i=1;i<=2;i+=1)
			NVAR Anom_UseSingleEnergy=root:Packages:ScatteringContrast:Anom_UseSingleEnergy
			NVAR Anom_UseEnergyRange=root:Packages:ScatteringContrast:Anom_UseEnergyRange
			NVAR Anom_Thickn=root:Packages:ScatteringContrast:Anom_Thickness
	
			if(Anom_UseEnergyRange)
				Wave/Z Mu=$("root:Packages:ScatteringContrast:Mu_"+num2str(i))
				Wave/Z eToMinusMuT=$("root:Packages:ScatteringContrast:eToMinusMuT_"+num2str(i))
				if(WaveExists(Mu) && WaveExists(eToMinusMuT))
					eToMinusMuT=exp(-Mu*Anom_Thickn*0.1)				//x is in mm, but Mu is in cm (density in cm3, MuOverRho cm2/g)
				endif
			else
				NVAR SingE_eToMInusMuT=$("root:Packages:ScatteringContrast:SingE_eToMInusMuT_"+num2str(i))
				NVAR SingE_Mu=$("root:Packages:ScatteringContrast:SingE_Mu_"+num2str(i))
		
				SingE_eToMInusMuT=exp(-SingE_Mu*Anom_Thickn*0.1)				//x is in mm, but Mu is in cm (density in cm3, MuOverRho cm2/g)
			endif
		endfor
	endif
	

End
//
////**********************************************************************************************************
////**********************************************************************************************************
////**********************************************************************************************************
//
Function IR1K_AnomButtonProc(ctrlName) : ButtonControl
	String ctrlName

//Recalculate
	if(cmpstr(ctrlName,"Recalculate")==0)
		variable startTicks=ticks
		IR1K_SetCompounds()
		IR1K_Calculate(1)
		IR1K_Calculate(2)
		NVAR Anom_UseEnergyRange=root:Packages:ScatteringContrast:Anom_UseEnergyRange
		if(Anom_UseEnergyRange)
			Wave/C f1=$("root:Packages:ScatteringContrast:f_1")
			Wave/C f2=$("root:Packages:ScatteringContrast:f_2")
			Wave DeltaRhoSq=$("root:Packages:ScatteringContrast:DeltaRhoSq")
			DeltaRhoSq=magsqr(f1-f2) * 10^(-20)
		else
			NVAR SingE_F_1=root:Packages:ScatteringContrast:SingE_F_1
			NVAR SingE_F_2=root:Packages:ScatteringContrast:SingE_F_2
			NVAR SingE_DRhoSq=root:Packages:ScatteringContrast:SingE_DRhoSq
			SingE_DRhoSq=magsqr(SingE_F_1-SingE_F_2) * 10^(-20)
		endif
		
		if((ticks-startTicks)>300)		//beep if it takes more than 5 seconds to calculate
			beep
		endif
		IR1K_DisplayRightElement()
		IR1K_FixCompoundFormula()
		IR1K_CalcMolWeightEtc()

	endif

//DisplayDeltaRhoSquared
	if(cmpstr(ctrlName,"DisplayDeltaRhoSquared")==0)
		DoWindow DeltaRhoSquaredGrph
		if(!V_Flag)
			IR1K_DeltaRhoSquaredGraph()
		else
			DoWindow/F DeltaRhoSquaredGrph
		endif
	endif
//DisplayFDoublePrime
	if(cmpstr(ctrlName,"DisplayFDoublePrime")==0)
		DoWindow FDoublePrimeGrph
		if(!V_Flag)
			IR1K_FDoublePrimeGraph()
		else
			DoWindow/F FDoublePrimeGrph
		endif
	endif
//DisplayFPrime
	if(cmpstr(ctrlName,"DisplayFPrime")==0)
		DoWindow FPrimeGrph
		if(!V_Flag)
			IR1K_FPrimeGraph()
		else
			DoWindow/F FPrimeGrph
		endif
	endif
//DisplayF0FPrime
	if(cmpstr(ctrlName,"DisplayF0FPrime")==0)
		DoWindow F0FPrimeGrph
		if(!V_Flag)
			IR1K_F0FPrimeGraph()
		else
			DoWindow/F F0FPrimeGrph
		endif
	endif

//DisplayMuOverRho
	if(cmpstr(ctrlName,"DisplayMuOverRho")==0)
		DoWindow MuOverRhoGrph
		if(!V_Flag)
			IR1K_MuOverRhoGraph()
		else
			DoWindow/F MuOverRhoGrph
		endif
	endif
//DisplayOneOverMu
	if(cmpstr(ctrlName,"DisplayOneOverMu")==0)
		DoWindow OneOverMuGrph
		if(!V_Flag)
			IR1K_OneOverMuGraph()
		else
			DoWindow/F OneOverMuGrph
		endif
	endif
//DisplayeToMinusMuT
	if(cmpstr(ctrlName,"DisplayeToMinusMuT")==0)
		DoWindow eToMinusMuTGrph
		if(!V_Flag)
			IR1K_eToMinusMuTGraph()
		else
			DoWindow/F eToMinusMuTGrph
		endif
	endif

//SaveFPrime
	if(cmpstr(ctrlName,"SaveFPrime1")==0)
		IR1K_SaveSelectedData("FPrime",1)
	endif
	if(cmpstr(ctrlName,"SaveFPrime2")==0)
		IR1K_SaveSelectedData("FPrime",2)
	endif
//SaveFDoublePrime
	if(cmpstr(ctrlName,"SaveFDoublePrime1")==0)
		IR1K_SaveSelectedData("FDoublePrime",1)
	endif
	if(cmpstr(ctrlName,"SaveFDoublePrime2")==0)
		IR1K_SaveSelectedData("FDoublePrime",2)
	endif
//SaveFDoublePrime
	if(cmpstr(ctrlName,"SaveF0FPrime1")==0)
		IR1K_SaveSelectedData("F0FDoublePrime",1)
	endif
	if(cmpstr(ctrlName,"SaveF0FPrime2")==0)
		IR1K_SaveSelectedData("F0FDoublePrime",2)
	endif
//SaveDeltaRhoSquared
	if(cmpstr(ctrlName,"SaveDeltaRhoSquared")==0)
		IR1K_SaveDeltaRhoSq()	
	endif
//SaveMuOverRho
	if(cmpstr(ctrlName,"SaveMuOverRho1")==0)
		IR1K_SaveSelectedData("MuOverRho",1)
	endif
	if(cmpstr(ctrlName,"SaveMuOverRho2")==0)
		IR1K_SaveSelectedData("MuOverRho",2)
	endif
//SaveOneOverMu
	if(cmpstr(ctrlName,"SaveOneOverMu1")==0)
		IR1K_SaveSelectedData("OneOverMu",1)
	endif
	if(cmpstr(ctrlName,"SaveOneOverMu2")==0)
		IR1K_SaveSelectedData("OneOverMu",2)
	endif
//SaveToMinusMuT
	if(cmpstr(ctrlName,"SaveToMinusMuT1")==0)
		IR1K_SaveSelectedData("eToMinusMuT",1)
	endif
	if(cmpstr(ctrlName,"SaveToMinusMuT2")==0)
		IR1K_SaveSelectedData("eToMinusMuT",2)
	endif

End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1K_SaveDeltaRhoSq()

	String fldrSav0= GetDataFolder(1)
	string tempStr
	SVAR/Z ExportFoldrAndName=root:Packages:ScatteringContrast:ExportFoldrAndName
	SVAR/Z LastExportFoldr=root:Packages:ScatteringContrast:LastExportFoldr
	if(!SVAR_Exists(ExportFoldrAndName) || !SVAR_Exists(LastExportFoldr))
		string/g $("root:Packages:ScatteringContrast:LastExportFoldr")
		string/g $("root:Packages:ScatteringContrast:ExportFoldrAndName")
		SVAR ExportFoldrAndName=root:Packages:ScatteringContrast:ExportFoldrAndName
		SVAR LastExportFoldr=root:Packages:ScatteringContrast:LastExportFoldr
		ExportFoldrAndName="root:"
		LastExportFoldr="root"
	endif
	// Anom_Compound1
	tempStr=IN2G_ExtractFldrNmFromPntr(ExportFoldrAndName)
	if (strlen(tempStr)<2)
			tempStr=LastExportFoldr
	endif

	IN2G_FolderSelectPanel("root:Packages:ScatteringContrast:ExportFoldrAndName", "Select Folder and Wave name to save DeltaRhoSq into",tempStr,1,1,1,1,1,"IR1K_SaveWaveData(\"DeltaRhoSq\")")
	SetDataFolder fldrSav0

end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1K_SaveSelectedData(DataType,which)
	variable which
	string DataType

	String fldrSav0= GetDataFolder(1)
	SVAR Anom_Compound=$("root:Packages:ScatteringContrast:Anom_Compound"+num2str(which))
	SVAR/Z LastExportFoldr=root:Packages:ScatteringContrast:LastExportFoldr
	SVAR/Z ExportFoldrAndName=root:Packages:ScatteringContrast:ExportFoldrAndName
	if(!SVAR_Exists(ExportFoldrAndName) || !SVAR_Exists(LastExportFoldr))
		string/g $("root:Packages:ScatteringContrast:LastExportFoldr")
		string/g $("root:Packages:ScatteringContrast:ExportFoldrAndName")
		SVAR ExportFoldrAndName=root:Packages:ScatteringContrast:ExportFoldrAndName
		SVAR LastExportFoldr=root:Packages:ScatteringContrast:LastExportFoldr
		ExportFoldrAndName="root:"
		LastExportFoldr="root"
	endif
	string tempStr
	// Anom_Compound1
	if(Cmpstr(Anom_Compound,"empty")!=0)
		tempStr=IN2G_ExtractFldrNmFromPntr(ExportFoldrAndName)
		if (strlen(tempStr)<2)
			tempStr=LastExportFoldr
		endif
		IN2G_FolderSelectPanel("root:Packages:ScatteringContrast:ExportFoldrAndName", "Select Folder and Wave name to save "+DataType+" for "+ Anom_Compound+" into",tempStr,1,1,1,1,1,"IR1K_SaveWaveData(\""+DataType+"_"+num2str(which)+"\")")
	endif
	SetDataFolder fldrSav0

end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1K_SaveWaveData(WhichWave)
	string WhichWave

		SVAR ExportFoldrAndName=root:Packages:ScatteringContrast:ExportFoldrAndName
		SVAR LastExportFoldr=root:Packages:ScatteringContrast:LastExportFoldr
		if (strlen(ExportFoldrAndName)>2)		//if user cancels, the string length is 0
			Wave exportWv=$("root:Packages:ScatteringContrast:"+WhichWave)
			Duplicate/O exportWv, $(ExportFoldrAndName)
		endif
		LastExportFoldr=IN2G_ExtractFldrNmFromPntr(ExportFoldrAndName)
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1K_DeltaRhoSquaredGraph() : Graph
	//PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:ScatteringContrast:
	wave/Z DeltaRhoSq=root:Packages:ScatteringContrast:DeltaRhoSq
	if(!WaveExists(DeltaRhoSq))
		abort "No data available, push Recalculate button first"
	endif
	Display/K=1 /W=(449.25,137.75,897.75,331.25) DeltaRhoSq
	DoWindow/C DeltaRhoSquaredGrph
	SetDataFolder fldrSav0
	ModifyGraph mirror=1
	ModifyGraph mode=4,marker[0]=17
	//ModifyGraph rgb[1]=(0,0,65280)
	SVAR Anom_Compound1=root:Packages:ScatteringContrast:Anom_Compound1
	SVAR Anom_Compound2=root:Packages:ScatteringContrast:Anom_Compound2
	Legend/C/N=text0/F=0/A=RB "\\s(DeltaRhoSq) "+Anom_Compound1+" vs "+Anom_Compound2
	Label left "Delta Rho squared [10\\S20\\M cm\\S4\\M]"
	Label bottom "Energy [keV]"
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1K_FPrimeGraph() : Graph
	//PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:ScatteringContrast:
	wave/Z Fprime_1=root:Packages:ScatteringContrast:Fprime_1
	if(!WaveExists(Fprime_1))
		abort "No data available, push Recalculate button first"
	endif
	wave Fprime_2=root:Packages:ScatteringContrast:Fprime_2
	Display/K=1 /W=(449.25,137.75,897.75,331.25) Fprime_1, Fprime_2
	DoWindow/C FPrimeGrph
	SetDataFolder fldrSav0
	ModifyGraph mirror=1
	ModifyGraph mode=4,marker[0]=17,marker[1]=19
	ModifyGraph rgb[1]=(0,0,65280)
	SVAR Anom_Compound1=root:Packages:ScatteringContrast:Anom_Compound1
	SVAR Anom_Compound2=root:Packages:ScatteringContrast:Anom_Compound2
	Legend/C/N=text0/F=0/A=RB "\\s(Fprime_1) "+Anom_Compound1+"\r\\s(Fprime_2) "+Anom_Compound2
	Label left "f '  [ e- ]"
	Label bottom "Energy [keV]"
End
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1K_F0FPrimeGraph() : Graph
	//PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:ScatteringContrast:
	wave/Z Fprime_1=root:Packages:ScatteringContrast:F0Fprime_1
	if(!WaveExists(Fprime_1))
		abort "No data available, push Recalculate button first"
	endif
	wave Fprime_2=root:Packages:ScatteringContrast:F0Fprime_2
	//Display/K=1 /W=(449.25,137.75,897.75,331.25) F0Fprime_1, F0Fprime_2
	Display/K=1 /W=(449.25,137.75,897.75,331.25) Fprime_1, Fprime_2
	DoWindow/C F0FPrimeGrph
	SetDataFolder fldrSav0
	ModifyGraph mirror=1
	ModifyGraph mode=4,marker[0]=17,marker[1]=19
	ModifyGraph rgb[1]=(0,0,65280)
	SVAR Anom_Compound1=root:Packages:ScatteringContrast:Anom_Compound1
	SVAR Anom_Compound2=root:Packages:ScatteringContrast:Anom_Compound2
	Legend/C/N=text0/F=0/A=RB "\\s(F0Fprime_1) "+Anom_Compound1+"\r\\s(F0Fprime_2) "+Anom_Compound2
	Label left "f\B0\M + f '  [ e- ]"
	Label bottom "Energy [keV]"
End


//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1K_FDoublePrimeGraph() : Graph
	//PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:ScatteringContrast:
	wave/Z FDoublePrime_1=root:Packages:ScatteringContrast:FDoublePrime_1
	if(!WaveExists(FDoublePrime_1))
		abort "No data available, push Recalculate button first"
	endif
	wave FDoublePrime_2=root:Packages:ScatteringContrast:FDoublePrime_2
	Display/K=1 /W=(449.25,137.75,897.75,331.25) FDoublePrime_1, FDoublePrime_2
	DoWindow/C FDoublePrimeGrph
	SetDataFolder fldrSav0
	ModifyGraph mirror=1
	ModifyGraph mode=4,marker[0]=17,marker[1]=19
	ModifyGraph rgb[1]=(0,0,65280)
	SVAR Anom_Compound1=root:Packages:ScatteringContrast:Anom_Compound1
	SVAR Anom_Compound2=root:Packages:ScatteringContrast:Anom_Compound2
	Legend/C/N=text0/F=0/A=RB "\\s(FDoublePrime_1) "+Anom_Compound1+"\r\\s(FDoublePrime_2) "+Anom_Compound2
	Label left "f ' '  [ e- ]"
	Label bottom "Energy [keV]"
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1K_MuOverRhoGraph() : Graph
	//PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:ScatteringContrast:
	wave/Z MuOverRho_1=root:Packages:ScatteringContrast:MuOverRho_1
	if(!WaveExists(MuOverRho_1))
		abort "No data available, push Recalculate button first"
	endif
	wave MuOverRho_2=root:Packages:ScatteringContrast:MuOverRho_2
	Display/K=1 /W=(449.25,137.75,897.75,331.25) MuOverRho_1, MuOverRho_2
	DoWindow/C MuOverRhoGrph
	SetDataFolder fldrSav0
	ModifyGraph mirror=1
	ModifyGraph mode=4,marker[0]=17,marker[1]=19
	ModifyGraph rgb[1]=(0,0,65280)
	SVAR Anom_Compound1=root:Packages:ScatteringContrast:Anom_Compound1
	SVAR Anom_Compound2=root:Packages:ScatteringContrast:Anom_Compound2
	Legend/C/N=text0/F=0/A=RB "\\s(MuOverRho_1) "+Anom_Compound1+"\r\\s(MuOverRho_2) "+Anom_Compound2
	Label left "Mu/Rho [cm\\S2\\M/g]"
	Label bottom "Energy [keV]"
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1K_OneOverMuGraph() : Graph
	//PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:ScatteringContrast:
	wave/Z OneOverMu_1=root:Packages:ScatteringContrast:OneOverMu_1
	if(!WaveExists(OneOverMu_1))
		abort "No data available, push Recalculate button first"
	endif
	wave OneOverMu_2=root:Packages:ScatteringContrast:OneOverMu_2
	Display/K=1 /W=(449.25,137.75,897.75,331.25) OneOverMu_1, OneOverMu_2
	DoWindow/C OneOverMuGrph
	SetDataFolder fldrSav0
	ModifyGraph mirror=1
	ModifyGraph mode=4,marker[0]=17,marker[1]=19
	ModifyGraph rgb[1]=(0,0,65280)
	SVAR Anom_Compound1=root:Packages:ScatteringContrast:Anom_Compound1
	SVAR Anom_Compound2=root:Packages:ScatteringContrast:Anom_Compound2
	Legend/C/N=text0/F=0/A=RB "\\s(OneOverMu_1) "+Anom_Compound1+"\r\\s(OneOverMu_2) "+Anom_Compound2
	Label left "1/mu [cm]"
	Label bottom "Energy [keV]"
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1K_eToMinusMuTGraph() : Graph
	//PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:ScatteringContrast:
	wave/Z eToMinusMuT_1=root:Packages:ScatteringContrast:eToMinusMuT_1
	if(!WaveExists(eToMinusMuT_1))
		abort "No data available, push Recalculate button first"
	endif
	wave eToMinusMuT_2=root:Packages:ScatteringContrast:eToMinusMuT_2
	Display/K=1 /W=(449.25,137.75,897.75,331.25) eToMinusMuT_1, eToMinusMuT_2
	DoWindow/C eToMinusMuTGrph
	SetDataFolder fldrSav0
	ModifyGraph mirror=1
	ModifyGraph mode=4,marker[0]=17,marker[1]=19
	ModifyGraph rgb[1]=(0,0,65280)
	SVAR Anom_Compound1=root:Packages:ScatteringContrast:Anom_Compound1
	SVAR Anom_Compound2=root:Packages:ScatteringContrast:Anom_Compound2
	Legend/C/N=text0/F=0/A=RB "\\s(eToMinusMuT_1) "+Anom_Compound1+"\r\\s(eToMinusMuT_2) "+Anom_Compound2
	Label left "exp(-mu*T)"
	Label bottom "Energy [keV]"
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1K_KillAllGraphs()

	KillWIndow/Z DeltaRhoSquaredGrph
	KillWIndow/Z FPrimeGrph
	KillWIndow/Z FDoublePrimeGrph
	KillWIndow/Z MuOverRhoGrph
	KillWIndow/Z OneOverMuGrph
	KillWIndow/Z eToMinusMuTGrph
	KillWIndow/Z F0FPrimeGrph
	
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1K_AnomScattContCalc() 
	
	NVAR Anom_MatrixVacuum=root:Packages:ScatteringContrast:Anom_MatrixVacuum
	
	//PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(5,52,611,580)
	DoWindow/C/T IR1K_AnomCalcPnl,"Anomalous scattering contrast calculator"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 3,textrgb= (0,15872,65280), fname= "Times New Roman"
	DrawText 97,30,"Anomalous Scattering Contrast Calculator"
	SetDrawEnv fstyle= 1, fname= "Times New Roman",fsize= 13
	DrawText 13,50,"Select ONE or TWO stored compounds"
	CheckBox StoreCompoundsInIgorExperiment, pos={10,70}, title="Compounds within experiment ?",proc=IR1K_AnomCheckProc
	CheckBox StoreCompoundsInIgorExperiment, variable=root:Packages:ScatteringContrast:StoreCompoundsInIgorExperiment, help={"Compounds are stored inside current Igor experiment? Or on the hard drive?"}
	ListBox CompoundSelection,pos={10,90},size={220,360},proc=IR1K_ListBoxProc
	ListBox CompoundSelection,help={"Select two compounds to calculate contrast between"}
	ListBox CompoundSelection,font="Times New Roman",frame=2
	ListBox CompoundSelection,listWave=root:Packages:ScatteringContrast:WaveOfCompoundsOutsideIgor
	ListBox CompoundSelection,selWave=root:Packages:ScatteringContrast:NumbersOfCompoundsOutsideIgor
	if(Anom_MatrixVacuum)
		ListBox CompoundSelection,mode= 1, selRow=-1
	else
		ListBox CompoundSelection,mode= 4
	endif
	SetVariable AvailableCompoundsMask,pos={10,454},size={215,16},title="Mask (regex):",help={"Mask Stored data list using regex"}
	SetVariable AvailableCompoundsMask,value= root:Packages:ScatteringContrast:AvailableCompoundsMask, frame=1, proc=IR1K_SetVarProc

	CheckBox Anom_UseSingleEnergy,pos={256,53},size={139,14},proc=IR1K_AnomCheckProc,title="Calculate at single energy"
	CheckBox Anom_UseSingleEnergy,help={"Check to calculate data at single energy"}
	CheckBox Anom_UseSingleEnergy,variable= root:Packages:ScatteringContrast:Anom_UseSingleEnergy,mode=1
	CheckBox Anom_UseEnergyRange,pos={415,54},size={138,14},proc=IR1K_AnomCheckProc,title="Calculate in energy range"
	CheckBox Anom_UseEnergyRange,help={"Check to calculate data at range of energies"}
	CheckBox Anom_UseEnergyRange,variable= root:Packages:ScatteringContrast:Anom_UseEnergyRange,mode=1

	CheckBox Anom_MatrixVacuum,pos={20,480},size={138,14},proc=IR1K_AnomCheckProc,title="Second phase is Vacuum"
	CheckBox Anom_MatrixVacuum,help={"Check to use vacuum as second phase"}
	CheckBox Anom_MatrixVacuum,variable= root:Packages:ScatteringContrast:Anom_MatrixVacuum,mode=0

	SetVariable OneEnergy,pos={244,76},size={200,16},proc=IR1K_AnomSetVarProc,title="Energy [keV]:     "
	SetVariable OneEnergy,help={"Set energy aqt which to calculate the values"}
	SetVariable OneEnergy,limits={2,200,1},value= root:Packages:ScatteringContrast:Anom_SingleEnergy
	SetVariable EnergyStart,pos={244,76},size={200,16},proc=IR1K_AnomSetVarProc,title="Energy start [keV]:"
	SetVariable EnergyStart,help={"Set energy start from which to calculate the values"}
	SetVariable EnergyStart,limits={2,200,1},value= root:Packages:ScatteringContrast:Anom_EnergyStart
	SetVariable EnergyEnd,pos={244,98},size={200,16},proc=IR1K_AnomSetVarProc,title="Energy end [keV]:"
	SetVariable EnergyEnd,help={"Set energy end to which to calculate the values"}
	SetVariable EnergyEnd,limits={2,200,1},value= root:Packages:ScatteringContrast:Anom_EnergyEnd
	SetVariable EnergyNumberOfSteps,pos={244,121},size={200,16},proc=IR1K_AnomSetVarProc,title="Number of steps in energy:"
	SetVariable EnergyNumberOfSteps,help={"Set number of steps in energy to calculate"}
	SetVariable EnergyNumberOfSteps,limits={2,20000,10},value= root:Packages:ScatteringContrast:Anom_EnergyNumSteps
	SetVariable Thickness,pos={244,144},size={200,16},title="Thickness [mm]", proc=IR1K_AnomSetVarProc
	SetVariable Thickness,help={"Input thickness of the sample for calculations of 1/muT. In millimeters."}
	SetVariable Thickness,limits={1e-05,Inf,0.05},value= root:Packages:ScatteringContrast:Anom_Thickness
	SetVariable Anom_QvalueUsed,pos={480,76},size={110,16},title="Q [A-1]  ", proc=IR1K_AnomSetVarProc
	SetVariable Anom_QvalueUsed,help={"For SAS usually assumed = 0. However, f0 variation between Q=0 ... 1 A-1 is between 3-10% for most materials!!!!"}
	SetVariable Anom_QvalueUsed,limits={0,Inf,0.1},value= root:Packages:ScatteringContrast:Anom_QvalueUsed



	SetVariable Sing_F0_1,pos={237,281},size={170,18},title=" f0  [ e- ]      ", bodywidth=60
	SetVariable Sing_F0_1,labelBack=(48896,52992,65280) 
	SetVariable Sing_F0_1,frame=0, format="%4.4g"
	SetVariable Sing_F0_1,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_F0_1
	SetVariable Sing_F0_2,pos={424,281},size={170,18},title=" f0  [ e- ]      "
	SetVariable Sing_F0_2,help={"F0 (energy independent] in cm-1"}, 				bodywidth=60
	SetVariable Sing_F0_2,labelBack=(49152,65280,32768) 
	SetVariable Sing_F0_2,frame=0, format="%4.4g"
	SetVariable Sing_F0_2,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_F0_2

	SetVariable Sing_FPrime_1,pos={237,301},size={170,18},title=" f ' [ e- ]      ", bodywidth=60
	SetVariable Sing_FPrime_1,help={"Fprime (energy dependent] in electrons"}
	SetVariable Sing_FPrime_1,labelBack=(48896,52992,65280) 
	SetVariable Sing_FPrime_1,frame=0, format="%4.4g"
	SetVariable Sing_FPrime_1,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_Fprime_1
	SetVariable Sing_FPrime_2,pos={424,301},size={170,18},title=" f'  [ e- ]      ", bodywidth=60
	SetVariable Sing_FPrime_2,help={"Fprime (energy dependent] in electrons"}
	SetVariable Sing_FPrime_2,labelBack=(49152,65280,32768) 
	SetVariable Sing_FPrime_2,frame=0, format="%4.4g"
	SetVariable Sing_FPrime_2,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_Fprime_2

	SetVariable Sing_F0FPrime_1,pos={237,321},size={170,18},title=" f0+f'  [ e- ]      ", bodywidth=60
	SetVariable Sing_F0FPrime_1,help={"F0+Fprime (energy dependent] in electrons"}
	SetVariable Sing_F0FPrime_1,labelBack=(48896,52992,65280) 
	SetVariable Sing_F0FPrime_1,frame=0, format="%4.4g"
	SetVariable Sing_F0FPrime_1,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_F0Fprime_1
	SetVariable Sing_F0FPrime_2,pos={424,321},size={170,18},title=" f0+f'  [ e- ]      ", bodywidth=60
	SetVariable Sing_F0FPrime_2,help={"F0+Fprime (energy dependent] in electrons"}
	SetVariable Sing_F0FPrime_2,labelBack=(49152,65280,32768) 
	SetVariable Sing_F0FPrime_2,frame=0, format="%4.4g"
	SetVariable Sing_F0FPrime_2,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_F0Fprime_2

	SetVariable Sing_FDoublePrime_1,pos={237,341},size={170,18},title=" f''  [ e- ]      ", bodywidth=60
	SetVariable Sing_FDoublePrime_1,help={"F double prime (energy dependent], imaginary part  in electrons"}
	SetVariable Sing_FDoublePrime_1,labelBack=(48896,52992,65280)
	SetVariable Sing_FDoublePrime_1 ,frame=0, format="%4.4g"
	SetVariable Sing_FDoublePrime_1,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_FdoublePrime_1
	SetVariable Sing_FDoublePrime_2,pos={424,341},size={170,18},title=" f''  [ e- ]      ", bodywidth=60
	SetVariable Sing_FDoublePrime_2,help={"F double prime (energy dependent], imaginary part  in electrons"}
	SetVariable Sing_FDoublePrime_2,labelBack=(49152,65280,32768)
	SetVariable Sing_FDoublePrime_2 ,frame=0, format="%4.4g"
	SetVariable Sing_FDoublePrime_2,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_FdoublePrime_2
	SetVariable Sing_MuOverRho_1,pos={237,361},size={170,18},title=" Mu/Rho [cm2/g]", bodywidth=60
	SetVariable Sing_MuOverRho_1,help={"Mu over Rho in [cm2/g]"}
	SetVariable Sing_MuOverRho_1,labelBack=(48896,52992,65280)
	SetVariable Sing_MuOverRho_1 ,frame=0, format="%4.4g"
	SetVariable Sing_MuOverRho_1,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_MuOverRho_1
	SetVariable Sing_MuOverRho_2,pos={424,361},size={170,18},title=" Mu/Rho [cm2/g]", bodywidth=60
	SetVariable Sing_MuOverRho_2,help={"Mu over Rho in [cm2/g]"}
	SetVariable Sing_MuOverRho_2,labelBack=(49152,65280,32768)
	SetVariable Sing_MuOverRho_2 ,frame=0, format="%4.4g"
	SetVariable Sing_MuOverRho_2,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_MuOverRho_2
	SetVariable Sing_Mu_1,pos={237,381},size={170,18},title=" Mu [1/cm]    ", bodywidth=60
	SetVariable Sing_Mu_1,help={"Mu on [1/cm]"},labelBack=(48896,52992,65280)
	SetVariable Sing_Mu_1 ,frame=0, format="%4.4g"
	SetVariable Sing_Mu_1,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_Mu_1
	SetVariable Sing_Mu_2,pos={424,381},size={170,18},title=" Mu [1/cm]    ", bodywidth=60
	SetVariable Sing_Mu_2,help={"Mu on [1/cm]"},labelBack=(49152,65280,32768)
	SetVariable Sing_Mu_2 ,frame=0, format="%4.4g"
	SetVariable Sing_Mu_2,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_Mu_2
	SetVariable Sing_1OverMu_1,pos={237,401},size={170,18},title=" 1/Mu [cm]     ", bodywidth=60
	SetVariable Sing_1OverMu_1,help={"1/Mu in [cm]"},labelBack=(48896,52992,65280)
	SetVariable Sing_1OverMu_1 ,frame=0, format="%4.4g"
	SetVariable Sing_1OverMu_1,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_OneOverMu_1
	SetVariable Sing_1OverMu_2,pos={424,401},size={170,18},title=" 1/Mu [cm]    ", bodywidth=60
	SetVariable Sing_1OverMu_2,help={"1/Mu in [cm]"},labelBack=(49152,65280,32768)
	SetVariable Sing_1OverMu_2 ,frame=0, format="%4.4g"
	SetVariable Sing_1OverMu_2,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_OneOverMu_2
	SetVariable Sing_eToMinusMuT_1,pos={237,421},size={170,18},title="Trans = exp(-Mu*T)", bodywidth=60
	SetVariable Sing_eToMinusMuT_1,help={"Transmission for thickness given above"}
	SetVariable Sing_eToMinusMuT_1,labelBack=(48896,52992,65280)
	SetVariable Sing_eToMinusMuT_1 ,frame=0, format="%4.4g"
	SetVariable Sing_eToMinusMuT_1,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_eToMInusMuT_1
	SetVariable Sing_eToMinusMuT_2,pos={424,421},size={170,18},title=" Trans = exp(-Mu*T)", bodywidth=60
	SetVariable Sing_eToMinusMuT_2,help={"Transmission for thickness given above"}
	SetVariable Sing_eToMinusMuT_2,labelBack=(49152,65280,32768)
	SetVariable Sing_eToMinusMuT_2 ,frame=0, format="%4.4g"
	SetVariable Sing_eToMinusMuT_2,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_eToMInusMuT_2

	SetVariable SingE_Fdrho_1,pos={237,441},size={170,18},title=" f [10^10 cm^-2]    ", bodywidth=60
	SetVariable SingE_Fdrho_1,help={"f in cm^2 units"}
	SetVariable SingE_Fdrho_1,labelBack=(48896,52992,65280)
	SetVariable SingE_Fdrho_1 ,frame=0, format="%4.4g"
	SetVariable SingE_Fdrho_1,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_Fdrho_1
	SetVariable SingE_Fdrho_2,pos={424,441},size={170,18},title=" f  [10^10 cm^-2]   ", bodywidth=60
	SetVariable SingE_Fdrho_2,help={"f in cm2 units"}
	SetVariable SingE_Fdrho_2,labelBack=(49152,65280,32768)
	SetVariable SingE_Fdrho_2 ,frame=0, format="%4.4g"
	SetVariable SingE_Fdrho_2,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_Fdrho_2

	SetVariable SingE_FDPrho_1,pos={237,461},size={170,18},title=" f\"  [10^10 cm^-2]   ", bodywidth=60
	SetVariable SingE_FDPrho_1,help={"f\" in cm2 units"}
	SetVariable SingE_FDPrho_1,labelBack=(48896,52992,65280)
	SetVariable SingE_FDPrho_1 ,frame=0, format="%4.4g"
	SetVariable SingE_FDPrho_1,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_FDPrho_1
	SetVariable SingE_FDPrho_2,pos={424,461},size={170,18},title=" f\"  [10^10 cm^-2]   ", bodywidth=60
	SetVariable SingE_FDPrho_2,help={"f\" in cm2 units"}
	SetVariable SingE_FDPrho_2,labelBack=(49152,65280,32768)
	SetVariable SingE_FDPrho_2 ,frame=0, format="%4.4g"
	SetVariable SingE_FDPrho_2,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_FDPrho_2

	SetVariable Sing_Contrast,pos={255,490},size={300,19},title="Delta Rho Squared [10^20 cm^-4]    ", bodywidth=60
	SetVariable Sing_Contrast,help={"Delta Rho Squared "}, format="%5.5g"
	SetVariable Sing_Contrast,labelBack=(65280,43520,32768) 
	SetVariable Sing_Contrast,frame=0
	SetVariable Sing_Contrast,limits={-Inf,Inf,0},value= root:Packages:ScatteringContrast:SingE_DRhoSq

	SetVariable Compound_1,pos={235,163},size={180,16},disable=2,title=" "
	SetVariable Compound_1,help={"This is name of the stored compound used for these calcualtions"}
	SetVariable Compound_1,labelBack=(48896,52992,65280),frame=0
	SetVariable Compound_1,value= root:Packages:ScatteringContrast:Anom_Compound1
	SetVariable Compound_2,pos={427,163},size={180,16},disable=2,title=" "
	SetVariable Compound_2,help={"This is name of the stored compound used for these calcualtions"}
	SetVariable Compound_2,labelBack=(49152,65280,32768),frame=0
	SetVariable Compound_2,value= root:Packages:ScatteringContrast:Anom_Compound2
	TitleBox CompFormula1,pos={235,185},size={42,15},disable=2
	TitleBox CompFormula1,labelBack=(48896,52992,65280),frame=0
	TitleBox CompFormula1,variable= root:Packages:ScatteringContrast:Anom_CompFormula1
	TitleBox CompFormula2,pos={236,225},size={29,13},disable=2
	TitleBox CompFormula2,labelBack=(49152,65280,32768),frame=0
	TitleBox CompFormula2,variable= root:Packages:ScatteringContrast:Anom_CompFormula2
	Button DisplayFPrime,pos={248,274},size={150,20},proc=IR1K_AnomButtonProc,title="Display f'"
	Button DisplayFPrime,help={"Click to create graph with f prime"}
	Button DisplayFDoublePrime,pos={248,303},size={150,20},proc=IR1K_AnomButtonProc,title="Display f''"
	Button DisplayFDoublePrime,help={"Click to create graph with f''"}
	Button DisplayF0FPrime,pos={248,332},size={150,20},proc=IR1K_AnomButtonProc,title="Display f0+f'"
	Button DisplayF0FPrime,help={"Click to create graph with f0+f'"}
	Button DisplayDeltaRhoSquared,pos={248,361},size={150,20},proc=IR1K_AnomButtonProc,title="Display Delta Rho squared"
	Button DisplayDeltaRhoSquared,help={"Click to create graph with Delat Rho squared"}
	Button DisplayMuOverRho,pos={248,390},size={150,20},proc=IR1K_AnomButtonProc,title="Display Mu / Rho"
	Button DisplayMuOverRho,help={"Click to create graph with Mu over Rho"}
	Button DisplayOneOverMu,pos={248,419},size={150,20},proc=IR1K_AnomButtonProc,title="Display 1/Mu"
	Button DisplayOneOverMu,help={"Click to create graph with Mu over Rho"}
	Button DisplayeToMinusMuT,pos={248,448},size={150,20},proc=IR1K_AnomButtonProc,title="Display Transm = exp(-Mu*T)"
	Button DisplayeToMinusMuT,help={"Click to create graph with exp(-Mu T)"}

	Button Recalculate,pos={474,105},size={100,20},proc=IR1K_AnomButtonProc,title="Recalculate"
	Button Recalculate,help={"Click to recalculate"},labelBack=(16384,16384,65280)
	Button Recalculate,fColor=(24576,24576,65280)


	Button SaveFPrime1,pos={413,274},size={90,20},proc=IR1K_AnomButtonProc,title="Save f '"
	Button SaveFPrime1,help={"Click to save waves with f prime dependence"}
	Button SaveFPrime1, labelBack=(48896,52992,65280),fColor=(48896,52992,65280)
	Button SaveFDoublePrime1,pos={413,303},size={90,20},proc=IR1K_AnomButtonProc,title="Save f ' '"
	Button SaveFDoublePrime1,help={"Click to save waves with f Double Prime"}
	Button SaveFDoublePrime1, labelBack=(48896,52992,65280),fColor=(48896,52992,65280)
	Button SaveF0FPrime1,pos={413,332},size={90,20},proc=IR1K_AnomButtonProc,title="Save f0+f ' "
	Button SaveF0FPrime1,help={"Click to save waves with f0+f'"}
	Button SaveF0FPrime1, labelBack=(48896,52992,65280),fColor=(48896,52992,65280)
	Button SaveMuOverRho1,pos={413,390},size={90,20},proc=IR1K_AnomButtonProc,title="Save Mu / Rho"
	Button SaveMuOverRho1,help={"Click to save waves with Mu over Rho"}
	Button SaveMuOverRho1, labelBack=(48896,52992,65280),fColor=(48896,52992,65280)
	Button SaveOneOverMu1,pos={413,419},size={90,20},proc=IR1K_AnomButtonProc,title="Save 1/Mu"
	Button SaveOneOverMu1,help={"Click to save waves with Mu over Rho"}
	Button SaveOneOverMu1, labelBack=(48896,52992,65280),fColor=(48896,52992,65280)
	Button SaveToMinusMuT1,pos={413,448},size={90,20},proc=IR1K_AnomButtonProc,title="Save exp(-Mu*T)"
	Button SaveToMinusMuT1,help={"Click to save waves with exp(-Mu T)"}

	Button SaveDeltaRhoSquared,pos={414,361},size={185,20},proc=IR1K_AnomButtonProc,title="Save Delta Rho squared"
	Button SaveDeltaRhoSquared,help={"Click to save data Delta Rho squared"}
	Button SaveToMinusMuT1,labelBack=(48896,52992,65280),fColor=(48896,52992,65280)

	Button SaveFPrime2,pos={510,274},size={90,20},proc=IR1K_AnomButtonProc,title="Save f '"
	Button SaveFPrime2,help={"Click to save waves with f prime dependence"}
	Button SaveFPrime2, labelBack=(49152,65280,32768),fColor=(49152,65280,32768)	
	Button SaveFDoublePrime2,pos={510,303},size={90,20},proc=IR1K_AnomButtonProc,title="Save f ' '"
	Button SaveFDoublePrime2,help={"Click to save waves with f Double Prime"}
	Button SaveFDoublePrime2, labelBack=(49152,65280,32768),fColor=(49152,65280,32768)	
	Button SaveF0FPrime2,pos={510,332},size={90,20},proc=IR1K_AnomButtonProc,title="Save f0+f '"
	Button SaveF0FPrime2,help={"Click to save waves with F0+F'"}
	Button SaveF0FPrime2, labelBack=(49152,65280,32768),fColor=(49152,65280,32768)
	Button SaveMuOverRho2,pos={510,390},size={90,20},proc=IR1K_AnomButtonProc,title="Save Mu / Rho"
	Button SaveMuOverRho2,help={"Click to save waves with Mu over Rho"}
	Button SaveMuOverRho2, labelBack=(49152,65280,32768),fColor=(49152,65280,32768)	
	Button SaveOneOverMu2,pos={510,419},size={90,20},proc=IR1K_AnomButtonProc,title="Save 1/Mu"
	Button SaveOneOverMu2,help={"Click to save waves with Mu over Rho"}
	Button SaveOneOverMu2, labelBack=(49152,65280,32768),fColor=(49152,65280,32768)	
	Button SaveToMinusMuT2,pos={510,448},size={90,20},proc=IR1K_AnomButtonProc,title="Save exp(-Mu*T)"
	Button SaveToMinusMuT2,help={"Click to save waves with exp(-Mu T)"}
	Button SaveToMinusMuT2, labelBack=(49152,65280,32768),fColor=(49152,65280,32768)	


	NVAR Anom_UseSingleEnergy= root:Packages:ScatteringContrast:Anom_UseSingleEnergy
	NVAR Anom_UseEnergyRange= root:Packages:ScatteringContrast:Anom_UseEnergyRange
	Anom_UseSingleEnergy=!Anom_UseEnergyRange
	IR1K_AnomCheckProc("Anom_UseSingleEnergy",Anom_UseSingleEnergy)
	IR1K_AnomCheckProc("Anom_UseEnergyRange",Anom_UseEnergyRange)
	IR1_UpdatePanelVersionNumber("IR1K_AnomCalcPnl", IR1K_CurrentPanelVersion,1)
EndMacro

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1K_SetCompounds()

	string oldDf=getDataFolder(1)
	setDataFolder root:Packages:ScatteringContrast
	SVAR Anom_Compound1=root:Packages:ScatteringContrast:Anom_Compound1
	SVAR Anom_Compound2=root:Packages:ScatteringContrast:Anom_Compound2
	WAVE/T WaveOfCompoundsOutsideIgor=root:Packages:ScatteringContrast:WaveOfCompoundsOutsideIgor
	Wave NumbersOfCompoundsOutsideIgor=root:Packages:ScatteringContrast:NumbersOfCompoundsOutsideIgor
	NVAR Anom_MatrixVacuum=root:Packages:ScatteringContrast:Anom_MatrixVacuum

	Anom_Compound1="empty"
	Anom_Compound2="empty"
	if (Anom_MatrixVacuum)
		ControlInfo/W=IR1K_AnomCalcPnl CompoundSelection
		if(V_Value>=0)
			Anom_Compound1=WaveOfCompoundsOutsideIgor[V_Value]
			Anom_Compound2="vacuum"
		endif
	else
		variable i, cntr=1
		For(i=0;i<numpnts(WaveOfCompoundsOutsideIgor);i+=1)
			if(NumbersOfCompoundsOutsideIgor[i]==1 && cntr==1)
				Anom_Compound1=WaveOfCompoundsOutsideIgor[i]
				cntr+=1
			elseif(NumbersOfCompoundsOutsideIgor[i]==1 && cntr==2)
				Anom_Compound2=WaveOfCompoundsOutsideIgor[i]
			endif
		endfor
	endif
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1K_Calculate(which)
	variable which		//this is which compound to calculate, yet to be decided which form this will be in...
	
	string oldDf=getDataFolder(1)
	setDataFolder root:Packages:ScatteringContrast

	NVAR Anom_UseSingleEnergy=root:Packages:ScatteringContrast:Anom_UseSingleEnergy
	NVAR Anom_UseEnergyRange=root:Packages:ScatteringContrast:Anom_UseEnergyRange
	NVAR Anom_CalcEnergyContrast=root:Packages:ScatteringContrast:Anom_CalcEnergyContrast
	NVAR Anom_CalcAbsorption=root:Packages:ScatteringContrast:Anom_CalcAbsorption
	NVAR Anom_SingleEnergy=root:Packages:ScatteringContrast:Anom_SingleEnergy
	NVAR Anom_EnergyStart=root:Packages:ScatteringContrast:Anom_EnergyStart
	NVAR Anom_EnergyEnd=root:Packages:ScatteringContrast:Anom_EnergyEnd
	NVAR Anom_EnergyNumSteps=root:Packages:ScatteringContrast:Anom_EnergyNumSteps
	NVAR Anom_DisplayGraph=root:Packages:ScatteringContrast:Anom_DisplayGraph
	SVAR Anom_Compound=$("root:Packages:ScatteringContrast:Anom_Compound"+num2str(which))
	NVAR Anom_Thickn=root:Packages:ScatteringContrast:Anom_Thickness
	NVAR Density=root:Packages:ScatteringContrast:Density


	//now let's load in the variables stored compound
	IR1K_AnomLoadDataCom(which)
	//create output waves if necessary
	if(Anom_UseEnergyRange)
		Make/D/O/N=(Anom_EnergyNumSteps) $("MuOverRho_"+num2str(which)), $("DeltaRhoSq"), $("Fprime_"+num2str(which)), $("F0Fprime_"+num2str(which)), $("FDoublePrime_"+num2str(which)), $("F0DRHO_"+num2str(which))   
		Make/O/D/N=(Anom_EnergyNumSteps) $("Mu_"+num2str(which)), $("OneOverMu_"+num2str(which)), $("F0_"+num2str(which)), $("eToMinusMuT_"+num2str(which)), $("FprimeDRHO_"+num2str(which)), $("F0FprimeDRHO_"+num2str(which)), $("FDoublePrimeDRHO_"+num2str(which))		   
		Make/O/C/D/N=(Anom_EnergyNumSteps) $("f_"+num2str(which))
		Wave/C f=$("root:Packages:ScatteringContrast:f_"+num2str(which))
		Wave MuOverRho=$("root:Packages:ScatteringContrast:MuOverRho_"+num2str(which))
		Wave DeltaRhoSq=$("root:Packages:ScatteringContrast:DeltaRhoSq")
		Wave Mu=$("root:Packages:ScatteringContrast:Mu_"+num2str(which))
		Wave OneOverMu= $("root:Packages:ScatteringContrast:OneOverMu_"+num2str(which))
		Wave eToMinusMuT=$("root:Packages:ScatteringContrast:eToMinusMuT_"+num2str(which))
		Wave FPrime=$("root:Packages:ScatteringContrast:Fprime_"+num2str(which))
		Wave F0FPrime=$("root:Packages:ScatteringContrast:F0Fprime_"+num2str(which))
		Wave FDoublePrime=$("root:Packages:ScatteringContrast:FDoublePrime_"+num2str(which))   
		Wave F0=$("root:Packages:ScatteringContrast:F0_"+num2str(which))   
		Wave FPrimeDRHO=$("root:Packages:ScatteringContrast:FprimeDRHO_"+num2str(which))
		Wave F0FPrimeDRHO=$("root:Packages:ScatteringContrast:F0FprimeDRHO_"+num2str(which))
		Wave FDoublePrimeDRHO=$("root:Packages:ScatteringContrast:FDoublePrimeDRHO_"+num2str(which))   
		Wave F0DRHO=$("root:Packages:ScatteringContrast:F0DRHO_"+num2str(which))   
		SetScale/I x Anom_EnergyStart,Anom_EnergyEnd,"keV", f, MuOverRho,DeltaRhoSq, F0FPrime, Mu, OneOverMu, FPrime, FDoublePrime, F0, eToMinusMuT
		//fill them in with data 
		if(cmpstr("empty",Anom_Compound)!=0 && cmpstr("vacuum",Anom_Compound)!=0)
			IR1K_AnomContrWaves(which)
			Mu=MuOverRho * density
			OneOverMu=1/Mu
			eToMinusMuT=exp(-Mu*Anom_Thickn*0.1)				//x is in mm, but Mu is in cm (density in cm3, MuOverRho cm2/g)
		else
			MuOverRho=0
			DeltaRhoSq=0
			Mu=0
			OneOverMu=0
			eToMinusMuT=0
			FPrime=0
			FDoublePrime=0
			F0=0
			f=0
			FPrimeDRHO=0
			FDoublePrimeDRHO=0
			F0DRHO=0
			f=0
		endif
	else
		NVAR SingE_F=$("root:Packages:ScatteringContrast:SingE_F_"+num2str(which))
		NVAR SingE_F0=$("root:Packages:ScatteringContrast:SingE_F0_"+num2str(which))
		NVAR SingE_Fprime=$("root:Packages:ScatteringContrast:SingE_Fprime_"+num2str(which))
		NVAR SingE_F0Fprime=$("root:Packages:ScatteringContrast:SingE_F0Fprime_"+num2str(which))
		NVAR SingE_F0DRHO=$("root:Packages:ScatteringContrast:SingE_F0DRHO_"+num2str(which))
		NVAR SingE_FprimeDRHO=$("root:Packages:ScatteringContrast:SingE_FprimeDRHO_"+num2str(which))
		NVAR SingE_F0FprimeDRHO=$("root:Packages:ScatteringContrast:SingE_F0FprimeDRHO_"+num2str(which))
		NVAR SingE_FdoublePrime=$("root:Packages:ScatteringContrast:SingE_FdoublePrime_"+num2str(which))
		NVAR SingE_FdoublePrimeDRHO=$("root:Packages:ScatteringContrast:SingE_FdoublePrimeDRHO_"+num2str(which))
		NVAR SingE_MuOverRho=$("root:Packages:ScatteringContrast:SingE_MuOverRho_"+num2str(which))
		NVAR SingE_OneOverMu=$("root:Packages:ScatteringContrast:SingE_OneOverMu_"+num2str(which))
		NVAR SingE_Mu=$("root:Packages:ScatteringContrast:SingE_Mu_"+num2str(which))
		NVAR SingE_eToMInusMuT=$("root:Packages:ScatteringContrast:SingE_eToMInusMuT_"+num2str(which))
		NVAR SingE_DRhoSq=$("root:Packages:ScatteringContrast:SingE_DRhoSq")
		NVAR SingE_Fdrho=$("root:Packages:ScatteringContrast:SingE_Fdrho_"+num2str(which))
		NVAR SingE_FDPrho=$("root:Packages:ScatteringContrast:SingE_FDPrho_"+num2str(which))

		if(cmpstr("empty",Anom_Compound)!=0 &&cmpstr("vacuum",Anom_Compound)!=0 )
			IR1K_AnomContrSingle(which)
			SingE_DRhoSq=magsqr(SingE_F)
			SingE_Fdrho = real(SingE_F) * 1e-10
			SingE_FDPrho =imag(SingE_F) * 1e-10
			SingE_Mu=SingE_MuOverRho * density
			SingE_OneOverMu=1/SingE_Mu
			SingE_eToMInusMuT=exp(-SingE_Mu*Anom_Thickn*0.1)				//x is in mm, but Mu is in cm (density in cm3, MuOverRho cm2/g)
			//let's calculate the scattering length density - both real and imaginary... 
			//ScattContrXrays = NumOfElincm3 * 0.28e-12 * 10^(-10)
		else
			SingE_F=0
			SingE_F0=0
			SingE_Fdrho = 0
			SingE_FDPrho =0 
			SingE_Fprime=0
			SingE_F0Fprime=0
			SingE_FdoublePrime=0
			SingE_F0DRHO=0
			SingE_FprimeDRHO=0
			SingE_F0FprimeDRHO=0
			SingE_FdoublePrimeDRHO=0
			SingE_MuOverRho=0
			SingE_OneOverMu=0
			SingE_Mu=0
			SingE_eToMInusMuT=0
			SingE_DRhoSq=0
		endif
	endif
		
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1K_AnomContrSingle(which)
	variable which

	NVAR Density=root:Packages:ScatteringContrast:Density
	NVAR MolWeight=root:Packages:ScatteringContrast:MolWeight
	NVAR WghtOf1Mol=root:Packages:ScatteringContrast:WghtOf1Mol
	NVAR NumOfMolin1cm3=root:Packages:ScatteringContrast:NumOfMolin1cm3
	SVAR ListOfElAtomWghts=root:Packages:ScatteringContrast:ListOfElAtomWghts
	SVAR ListOfElNumbers=root:Packages:ScatteringContrast:ListOfElNumbers
	NVAR NumberOfAtoms = root:Packages:ScatteringContrast:NumberOfAtoms
	NVAR NumOfElperMol = root:Packages:ScatteringContrast:NumOfElperMol
	NVAR NumOfElincm3 = root:Packages:ScatteringContrast:NumOfElincm3
	NVAR ScattContrXrays = root:Packages:ScatteringContrast:ScattContrXrays
	NVAR CalcNeutrons = root:Packages:ScatteringContrast:CalcNeutrons
	NVAR CalcXrays = root:Packages:ScatteringContrast:CalcXrays
	NVAR UseWeightPercent = root:Packages:ScatteringContrast:UseWeightPercent
	NVAR Anom_QvalueUsed=root:Packages:ScatteringContrast:Anom_QvalueUsed
		NVAR Anom_SingleEnergy=root:Packages:ScatteringContrast:Anom_SingleEnergy
		NVAR/C SingE_F=$("SingE_F_"+num2str(which))
		NVAR SingE_F0=$("SingE_F0_"+num2str(which))
		NVAR SingE_Fprime=$("SingE_Fprime_"+num2str(which))
		NVAR SingE_F0Fprime=$("SingE_F0Fprime_"+num2str(which))
		NVAR SingE_FdoublePrime=$("SingE_FdoublePrime_"+num2str(which))

		NVAR SingE_F0DRHO=$("SingE_F0DRHO_"+num2str(which))
		NVAR SingE_FprimeDRHO=$("SingE_FprimeDRHO_"+num2str(which))
		NVAR SingE_F0FprimeDRHO=$("SingE_F0FprimeDRHO_"+num2str(which))
		NVAR SingE_FdoublePrimeDRHO=$("SingE_FdoublePrimeDRHO_"+num2str(which))

		NVAR SingE_MuOverRho=$("SingE_MuOverRho_"+num2str(which))
		NVAR SingE_OneOverMu=$("SingE_OneOverMu_"+num2str(which))
		NVAR SingE_Mu=$("SingE_Mu_"+num2str(which))
		NVAR SingE_eToMInusMuT=$("SingE_eToMInusMuT_"+num2str(which))
		NVAR SingE_DRhoSq	

	SingE_FdoublePrime=0
	SingE_Fprime=0
	SingE_F0=0
	SingE_FdoublePrimeDRHO=0
	SingE_FprimeDRHO=0
	SingE_F0DRHO=0
	SingE_MuOverRho=0
	
	variable j, i, tempMolWght, CorrectedElContent, tempSumAtomNumb
	variable/C tempNumOfElctrns
	tempMolWght=0
	tempNumOfElctrns=0
	tempSumAtomNumb=0
	For(i=1;i<=NumberOfAtoms;i+=1)
		NVAR Elcontent=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_content")
		NVAR ElementWeight=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_AtomWeight")
		if (UseWeightPercent)
			CorrectedElContent = Elcontent/ElementWeight
		else
			CorrectedElContent = Elcontent
		endif
		
		if (CorrectedElContent>0)
			SVAR Eltype=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_type")
			tempMolWght+= CorrectedElContent * ElementWeight	
			tempSumAtomNumb+=CorrectedElContent
		//	here we need to fill in the variables with data from CromerLiberman 
			SingE_FprimeDRHO+=IR1_Get_RealPartfp(ELType, Anom_SingleEnergy) *CorrectedElContent
			SingE_FdoublePrimeDRHO+=IR1_Get_ImagPartfpp(ELType, Anom_SingleEnergy) *CorrectedElContent
			SingE_F0DRHO+=IR1_Get_f0(ELType,Anom_QvalueUsed)*CorrectedElContent
	
			SingE_Fprime+=IR1_Get_RealPartfp(ELType, Anom_SingleEnergy) *CorrectedElContent
			SingE_FdoublePrime+=IR1_Get_ImagPartfpp(ELType, Anom_SingleEnergy) *CorrectedElContent
			SingE_MuOverRho+=IR1_Get_MuOverRho(ELType, Anom_SingleEnergy)*CorrectedElContent*ElementWeight			//scale by weigth of element in molecule

			SingE_F0+=IR1_Get_f0(ELType,Anom_QvalueUsed)*CorrectedElContent
		endif
	endfor
	//and now set the molecular weight to result....
	MolWeight = tempMolWght
	//and now calculate weight of 1 mol in grams
	WghtOf1Mol = MolWeight * 1.67e-24
	//and now calculate number of mol per cm3
	NumOfMolin1cm3 = density / WghtOf1Mol
	SingE_F0Fprime=(SingE_Fprime+SingE_F0)/tempSumAtomNumb
	SingE_F0=SingE_F0/tempSumAtomNumb					//calculates values in electron units
	SingE_Fprime=SingE_Fprime	/tempSumAtomNumb							
	SingE_FdoublePrime=SingE_FdoublePrime/tempSumAtomNumb
	
	SingE_MuOverRho=SingE_MuOverRho/MolWeight			//normalize by weight of all elements in molecule
	
	SingE_F=cmplx(SingE_F0DRHO+SingE_FprimeDRHO,SingE_FdoublePrimeDRHO) *  0.28179 * 10^(-12)*NumOfMolin1cm3
	
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1K_ClearData()

	//this cleans the data 
	
	variable which 
	For(which=1;which<=2;which+=1)
		NVAR/Z SingE_F=$("root:Packages:ScatteringContrast:SingE_F_"+num2str(which))
		if(NVAR_Exists(SingE_F))
			NVAR SingE_F0=$("root:Packages:ScatteringContrast:SingE_F0_"+num2str(which))
			NVAR SingE_Fprime=$("root:Packages:ScatteringContrast:SingE_Fprime_"+num2str(which))
			NVAR SingE_FdoublePrime=$("root:Packages:ScatteringContrast:SingE_FdoublePrime_"+num2str(which))
			NVAR SingE_F0FPrime=$("root:Packages:ScatteringContrast:SingE_F0FPrime_"+num2str(which))
			NVAR SingE_MuOverRho=$("root:Packages:ScatteringContrast:SingE_MuOverRho_"+num2str(which))
			NVAR SingE_OneOverMu=$("root:Packages:ScatteringContrast:SingE_OneOverMu_"+num2str(which))
			NVAR SingE_Mu=$("root:Packages:ScatteringContrast:SingE_Mu_"+num2str(which))
			NVAR SingE_eToMInusMuT=$("root:Packages:ScatteringContrast:SingE_eToMInusMuT_"+num2str(which))
			NVAR SingE_Fdrho=$("root:Packages:ScatteringContrast:SingE_Fdrho_"+num2str(which))
			NVAR SingE_FDPrho=$("root:Packages:ScatteringContrast:SingE_FDPrho_"+num2str(which))
			NVAR SingE_DRhoSq=$("root:Packages:ScatteringContrast:SingE_DRhoSq")
			SingE_F=0
			SingE_F0=0
			SingE_Fprime=0
			SingE_F0FPrime=0
			SingE_FdoublePrime=0
			SingE_MuOverRho=0
			SingE_OneOverMu=0
			SingE_Mu=0
			SingE_eToMInusMuT=0
			SingE_DRhoSq=0
			SingE_Fdrho=0
			SingE_FDPrho=0
		endif
	endfor
	For(which=1;which<=2;which+=1)
		Wave/C/Z f=$("root:Packages:ScatteringContrast:f_"+num2str(which))
		if(WaveExists(f))
			Wave MuOverRho=$("root:Packages:ScatteringContrast:MuOverRho_"+num2str(which))
			Wave DeltaRhoSq=$("root:Packages:ScatteringContrast:DeltaRhoSq")
			Wave Mu=$("root:Packages:ScatteringContrast:Mu_"+num2str(which))
			Wave OneOverMu= $("root:Packages:ScatteringContrast:OneOverMu_"+num2str(which))
			Wave eToMinusMuT=$("root:Packages:ScatteringContrast:eToMinusMuT_"+num2str(which))
			Wave FPrime=$("root:Packages:ScatteringContrast:Fprime_"+num2str(which))
			Wave FDoublePrime=$("root:Packages:ScatteringContrast:FDoublePrime_"+num2str(which))   
			Wave F0=$("root:Packages:ScatteringContrast:F0_"+num2str(which))   
			Wave F0FPrime=$("root:Packages:ScatteringContrast:F0FPrime_"+num2str(which))   
			MuOverRho=0
			DeltaRhoSq=0
			Mu=0
			OneOverMu=0
			eToMinusMuT=0
			FPrime=0
			FDoublePrime=0
			F0=0
			f=0
			F0FPrime=0
		endif
	endfor
end

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1K_AnomContrWaves(which)
	variable which

	NVAR Density=root:Packages:ScatteringContrast:Density
	NVAR MolWeight=root:Packages:ScatteringContrast:MolWeight
	NVAR WghtOf1Mol=root:Packages:ScatteringContrast:WghtOf1Mol
	NVAR NumOfMolin1cm3=root:Packages:ScatteringContrast:NumOfMolin1cm3
	SVAR ListOfElAtomWghts=root:Packages:ScatteringContrast:ListOfElAtomWghts
	SVAR ListOfElNumbers=root:Packages:ScatteringContrast:ListOfElNumbers
	NVAR NumberOfAtoms = root:Packages:ScatteringContrast:NumberOfAtoms
	NVAR NumOfElperMol = root:Packages:ScatteringContrast:NumOfElperMol
	NVAR NumOfElincm3 = root:Packages:ScatteringContrast:NumOfElincm3
	NVAR ScattContrXrays = root:Packages:ScatteringContrast:ScattContrXrays
	NVAR CalcNeutrons = root:Packages:ScatteringContrast:CalcNeutrons
	NVAR CalcXrays = root:Packages:ScatteringContrast:CalcXrays
	NVAR UseWeightPercent = root:Packages:ScatteringContrast:UseWeightPercent
	NVAR Anom_QvalueUsed=root:Packages:ScatteringContrast:Anom_QvalueUsed
		Wave/C f=$("f_"+num2str(which))
		Wave MuOverRho=$("MuOverRho_"+num2str(which))
		Wave DeltaRhoSq=$("DeltaRhoSq")
		Wave Mu=$("Mu_"+num2str(which))
		Wave OneOverMu= $("OneOverMu_"+num2str(which))
		Wave eToMinusMuT=$("eToMinusMuT_"+num2str(which))
		Wave FPrime=$("Fprime_"+num2str(which))
		Wave F0FPrime=$("F0Fprime_"+num2str(which))
		Wave FDoublePrime=$("FDoublePrime_"+num2str(which))   
		Wave F0=$("F0_"+num2str(which))   
		Wave FPrimeDRHO=$("FprimeDRHO_"+num2str(which))
		Wave F0FPrimeDRHO=$("F0FprimeDRHO_"+num2str(which))
		Wave FDoublePrimeDRHO=$("FDoublePrimeDRHO_"+num2str(which))   
		Wave F0DRHO=$("F0DRHO_"+num2str(which))   

	FPrime=0
	FDoublePrime=0
	F0=0
	FPrimeDRHO=0
	FDoublePrimeDRHO=0
	F0DRHO=0
	MuOverRho=0
	
	variable j, i, tempMolWght, CorrectedElContent, tempSumAtomNumb
	variable/C tempNumOfElctrns
	tempMolWght=0
	tempNumOfElctrns=0
	tempSumAtomNumb=0
	For(i=1;i<=NumberOfAtoms;i+=1)
		NVAR Elcontent=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_content")
		NVAR ElementWeight=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_AtomWeight")
		if (UseWeightPercent)
			CorrectedElContent = Elcontent/ElementWeight
		else
			CorrectedElContent = Elcontent
		endif
		
		if (CorrectedElContent>0)
			SVAR Eltype=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_type")
			tempMolWght+= CorrectedElContent * ElementWeight	
			tempSumAtomNumb+=CorrectedElContent
		//	here we need to fill in the waves with data from CromerLiberman 
			//For(j=0;j<(numpnts(FPrime));j+=1)
				FPrime+=IR1_Get_RealPartfp(ELType, x) *CorrectedElContent
				FDoublePrime+=IR1_Get_ImagPartfpp(ELType, x) *CorrectedElContent
				F0+=IR1_Get_f0(ELType,Anom_QvalueUsed)*CorrectedElContent

				MuOverRho+=IR1_Get_MuOverRho(ELType, x)*CorrectedElContent*ElementWeight			//scale by weight of this atom in the molecule
			//endfor
		endif
	endfor
	//and now set the molecular weight to result....
	MolWeight = tempMolWght
	//and now calculate weight of 1 mol in grams
	WghtOf1Mol = MolWeight * 1.67e-24
	//and now calculate number of mol per cm3
	NumOfMolin1cm3 = density / WghtOf1Mol
	FPrimeDRHO=FPrime
	FDoublePrimeDRHO=FDoublePrime
	F0DRHO=F0

	FPrime=FPrime/tempSumAtomNumb					//sets them to relativ electron units
	F0FPrime=(F0+FPrime)/tempSumAtomNumb
	FDoublePrime=FDoublePrime/tempSumAtomNumb
	MuOverRho=MuOverRho/MolWeight									//normalize by weight of molecule

	f=cmplx(F0DRHO+FPrimeDRHO,FDoublePrimeDRHO) *  0.28179 * 10^(-12) *NumOfMolin1cm3
	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************


Function  IR1K_AnomLoadDataCom(which)
	variable which

	string OldDf=GetDataFolder(1)
	SetdataFolder root:Packages:ScatteringContrast
	SVAR Anom_Compound=$("root:Packages:ScatteringContrast:Anom_Compound"+num2str(which))
	NVAR Density=root:Packages:ScatteringContrast:Density
	NVAR NumberOfAtoms=root:Packages:ScatteringContrast:NumberOfAtoms
	NVAR ScattContrXrays=root:Packages:ScatteringContrast:ScattContrXrays
	NVAR NeutronsScatlengthDens=root:Packages:ScatteringContrast:NeutronsScatlengthDens
	NVAR UseWeightPercent=root:Packages:ScatteringContrast:UseWeightPercent
	SVAR FormulaGlobal=root:Packages:ScatteringContrast:Formula
	SVAR FormulaLocal=$("root:Packages:ScatteringContrast:Anom_CompFormula"+num2str(which))
	NVAR StoreCompoundsInIgorExperiment = root:Packages:ScatteringContrast:StoreCompoundsInIgorExperiment
	
	if(cmpstr("empty",Anom_Compound)!=0 && cmpstr("vacuum",Anom_Compound)!=0)
		string testNm, LoadedString
		variable i
		if(StoreCompoundsInIgorExperiment)
			testNm=Anom_Compound
			string OldDf1=GetDataFolder(1)
			SetDataFolder root:Packages
			NewDataFolder/O/S root:Packages:IrenaSavedCompounds
			SVAR testStr=$(testNm)
			LoadedString = testStr
			SetDataFolder OldDf1		
		else
			testNm=Anom_Compound+".dat"
			LoadWave/J/Q/P=CalcSavedCompounds/K=2/N=ImportData/V={"\t"," $",0,1} testNm
			Wave/T LoadedData=root:Packages:ScatteringContrast:ImportData0
			LoadedString = LoadedData[0]
			KillWaves/Z LoadedData
		endif
		NumberOfAtoms=NumberByKey("NumberOfAtoms", LoadedString  , "=" )
		Density=NumberByKey("Density", LoadedString  , "=" )
		ScattContrXrays=NumberByKey("ScattContrXrays", LoadedString  , "=" )
		NeutronsScatlengthDens=NumberByKey("NeutronsScatlengthDens", LoadedString  , "=" )
		UseWeightPercent=NumberByKey("UseWeightPercent", LoadedString  , "=" )
		
		For(i=1;i<=NumberOfAtoms;i+=1)
			SVAR El_type=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_type")
			SVAR El_Isotope=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_Isotope")
			NVAR El_content=$("root:Packages:ScatteringContrast:El"+num2str(i)+"_content")
	
			El_content=NumberByKey("El"+num2str(i)+"_content", LoadedString  , "=" )
			El_Isotope=StringByKey("El"+num2str(i)+"_Isotope", LoadedString  , "=" )
			El_type=StringByKey("El"+num2str(i)+"_type", LoadedString  , "=" )
		endfor
		
		 IR1K_FixCompoundFormula()
		
		FormulaLocal = FormulaGlobal
		if(strlen(FormulaLocal)>60)
			FormulaLocal=FormulaLocal[0,60]+"\r"+FormulaLocal[61,inf]
		endif
	else
		NumberOfAtoms=0
		Density=0
		ScattContrXrays=0
		NeutronsScatlengthDens=0
		UseWeightPercent=0
		FormulaLocal = Anom_Compound
	endif

	setDataFolder oldDf

end
//
////**********************************************************************************************************
////**********************************************************************************************************
////**********************************************************************************************************
//
Function IR1K_SetLookupLists()

//here we fill in the infor for all known elements

	SVAR ListOfElements=root:Packages:ScatteringContrast:ListOfElements
	SVAR ListOfElNumbers=root:Packages:ScatteringContrast:ListOfElNumbers
	SVAR ListOfElAtomWghts=root:Packages:ScatteringContrast:ListOfElAtomWghts
	SVAR ListOfIsotopes=root:Packages:ScatteringContrast:ListOfIsotopes
	SVAR ListOfElNeutronBs=root:Packages:ScatteringContrast:ListOfElNeutronBs
	SVAR ListOfElNeuIncohBs=root:Packages:ScatteringContrast:ListOfElNeuIncohBs
	SVAR ListofNeutronAbsCross=root:Packages:ScatteringContrast:ListofNeutronAbsCross
	

//common for X rays and neutrons
// 	ListOfElements = "H;D;He;..."
//	ListOfElNumbers = "H=1;D=1;He=2;..."
//	ListOfElAtomWghts = "H=1;D=2;He=4;..."
	//H
	ListOfElements ="---;H;"
	ListOfElNumbers ="H=1;"
	ListOfElAtomWghts ="H=1.00794;"
	//D  (see http://en.wikipedia.org/wiki/Isotopes_of_hydrogen)
	ListOfElements +="D;"
	ListOfElNumbers +="D=1;"
	ListOfElAtomWghts +="D=2.014101778;"
	//T
	ListOfElements +="T;"
	ListOfElNumbers +="T=1;"
	ListOfElAtomWghts +="T=3.0160493;"
	//He
	ListOfElements +="He;"
	ListOfElNumbers +="He=2;"
	ListOfElAtomWghts +="He=4.002602;"
	//Li
	ListOfElements +="Li;"
	ListOfElNumbers +="Li=3;"
	ListOfElAtomWghts +="Li=6.941;"
	//Be
	ListOfElements +="Be;"
	ListOfElNumbers +="Be=4;"
	ListOfElAtomWghts +="Be=9.012182;"
	//B
	ListOfElements +="B;"
	ListOfElNumbers +="B=5;"
	ListOfElAtomWghts +="B=10.811;"
	//C
	ListOfElements +="C;"
	ListOfElNumbers +="C=6;"
	ListOfElAtomWghts +="C=12.011;"
	//N
	ListOfElements +="N;"
	ListOfElNumbers +="N=7;"
	ListOfElAtomWghts +="N=14.00674;"
	//O
	ListOfElements +="O;"
	ListOfElNumbers +="O=8;"
	ListOfElAtomWghts +="O=15.9994;"
	//F
	ListOfElements +="F;"
	ListOfElNumbers +="F=9;"
	ListOfElAtomWghts +="F=18.9984032;"
	//Ne
	ListOfElements +="Ne;"
	ListOfElNumbers +="Ne=10;"
	ListOfElAtomWghts +="Ne=20.1797;"
//  III line
	//Na
	ListOfElements +="Na;"
	ListOfElNumbers +="Na=11;"
	ListOfElAtomWghts +="Na=22.989768;"
	//Mg
	ListOfElements +="Mg;"
	ListOfElNumbers +="Mg=12;"
	ListOfElAtomWghts +="Mg=24.3050;"
	//Al
	ListOfElements +="Al;"
	ListOfElNumbers +="Al=13;"
	ListOfElAtomWghts +="Al=26.981539;"
	//Si
	ListOfElements +="Si;"
	ListOfElNumbers +="Si=14;"
	ListOfElAtomWghts +="Si=28.0855;"
	//P
	ListOfElements +="P;"
	ListOfElNumbers +="P=15;"
	ListOfElAtomWghts +="P=30.973762;"
	//S
	ListOfElements +="S;"
	ListOfElNumbers +="S=16;"
	ListOfElAtomWghts +="S=32.066;"
	//Cl
	ListOfElements +="Cl;"
	ListOfElNumbers +="Cl=17;"
	ListOfElAtomWghts +="Cl=35.4527;"
	//Ar
	ListOfElements +="Ar;"
	ListOfElNumbers +="Ar=18;"
	ListOfElAtomWghts +="Ar=39.948;"
	//K
	ListOfElements +="K;"
	ListOfElNumbers +="K=19;"
	ListOfElAtomWghts +="K=39.0983;"
	//Ca
	ListOfElements +="Ca;"
	ListOfElNumbers +="Ca=20;"
	ListOfElAtomWghts +="Ca=40.078;"
	//Sc
	ListOfElements +="Sc;"
	ListOfElNumbers +="Sc=21;"
	ListOfElAtomWghts +="Sc=44.95591;"
	//Ti
	ListOfElements +="Ti;"
	ListOfElNumbers +="Ti=22;"
	ListOfElAtomWghts +="Ti=47.88;"
	//V
	ListOfElements +="V;"
	ListOfElNumbers +="V=23;"
	ListOfElAtomWghts +="V=50.9415;"
	//Cr
	ListOfElements +="Cr;"
	ListOfElNumbers +="Cr=24;"
	ListOfElAtomWghts +="Cr=51.9961;"
	//Mn
	ListOfElements +="Mn;"
	ListOfElNumbers +="Mn=25;"
	ListOfElAtomWghts +="Mn=54.93805;"
	//Fe
	ListOfElements +="Fe;"
	ListOfElNumbers +="Fe=26;"
	ListOfElAtomWghts +="Fe=55.847;"
	//Co
	ListOfElements +="Co;"
	ListOfElNumbers +="Co=27;"
	ListOfElAtomWghts +="Co=58.93320;"
	//Ni
	ListOfElements +="Ni;"
	ListOfElNumbers +="Ni=28;"
	ListOfElAtomWghts +="Ni=58.6934;"
	//Cu
	ListOfElements +="Cu;"
	ListOfElNumbers +="Cu=29;"
	ListOfElAtomWghts +="Cu=63.546;"
	//Zn
	ListOfElements +="Zn;"
	ListOfElNumbers +="Zn=30;"
	ListOfElAtomWghts +="Zn=65.38;"
	//Ga
	ListOfElements +="Ga;"
	ListOfElNumbers +="Ga=31;"
	ListOfElAtomWghts +="Ga=69.723;"
	//Ge
	ListOfElements +="Ge;"
	ListOfElNumbers +="Ge=32;"
	ListOfElAtomWghts +="Ge=72.61;"
	//As
	ListOfElements +="As;"
	ListOfElNumbers +="As=33;"
	ListOfElAtomWghts +="As=74.92159;"
	//Se
	ListOfElements +="Se;"
	ListOfElNumbers +="Se=34;"
	ListOfElAtomWghts +="Se=78.96;"
	//Br
	ListOfElements +="Br;"
	ListOfElNumbers +="Br=35;"
	ListOfElAtomWghts +="Br=79.904;"
	//Kr
	ListOfElements +="Kr;"
	ListOfElNumbers +="Kr=36;"
	ListOfElAtomWghts +="Kr=83.80;"
	//Rb
	ListOfElements +="Rb;"
	ListOfElNumbers +="Rb=37;"
	ListOfElAtomWghts +="Rb=85.4678;"
	//Sr
	ListOfElements +="Sr;"
	ListOfElNumbers +="Sr=38;"
	ListOfElAtomWghts +="Sr=87.62;"
	//Y
	ListOfElements +="Y;"
	ListOfElNumbers +="Y=39;"
	ListOfElAtomWghts +="Y=88.90585;"
	//Zr
	ListOfElements +="Zr;"
	ListOfElNumbers +="Zr=40;"
	ListOfElAtomWghts +="Zr=91.224;"
	//Nb
	ListOfElements +="Nb;"
	ListOfElNumbers +="Nb=41;"
	ListOfElAtomWghts +="Nb=92.9064;"
	//Mo
	ListOfElements +="Mo;"
	ListOfElNumbers +="Mo=42;"
	ListOfElAtomWghts +="Mo=95.94;"
	//Tc
	ListOfElements +="Tc;"
	ListOfElNumbers +="Tc=43;"
	ListOfElAtomWghts +="Tc=98.0;"
	//Ru
	ListOfElements +="Ru;"
	ListOfElNumbers +="Ru=44;"
	ListOfElAtomWghts +="Ru=101.07;"
	//Rh
	ListOfElements +="Rh;"
	ListOfElNumbers +="Rh=45;"
	ListOfElAtomWghts +="Rh=102.9055;"
	//Pd
	ListOfElements +="Pd;"
	ListOfElNumbers +="Pd=46;"
	ListOfElAtomWghts +="Pd=106.42;"
	//Ag
	ListOfElements +="Ag;"
	ListOfElNumbers +="Ag=47;"
	ListOfElAtomWghts +="Ag=107.868;"
	//Cd
	ListOfElements +="Cd;"
	ListOfElNumbers +="Cd=48;"
	ListOfElAtomWghts +="Cd=112.411;"
	//In
	ListOfElements +="In;"
	ListOfElNumbers +="In=49;"
	ListOfElAtomWghts +="In=114.818;"
	//Sn
	ListOfElements +="Sn;"
	ListOfElNumbers +="Sn=50;"
	ListOfElAtomWghts +="Sn=118.710;"
	//Sb
	ListOfElements +="Sb;"
	ListOfElNumbers +="Sb=51;"
	ListOfElAtomWghts +="Sb=121.75;"
	//Te
	ListOfElements +="Te;"
	ListOfElNumbers +="Te=52;"
	ListOfElAtomWghts +="Te=127.60;"
	//I
	ListOfElements +="I;"
	ListOfElNumbers +="I=53;"
	ListOfElAtomWghts +="I=126.9045;"
	//Xe
	ListOfElements +="Xe;"
	ListOfElNumbers +="Xe=54;"
	ListOfElAtomWghts +="Xe=131.29;"
	//Cs
	ListOfElements +="Cs;"
	ListOfElNumbers +="Cs=55;"
	ListOfElAtomWghts +="Cs=132.9054;"
	//Ba
	ListOfElements +="Ba;"
	ListOfElNumbers +="Ba=56;"
	ListOfElAtomWghts +="Ba=137.327;"
	//La
	ListOfElements +="La;"
	ListOfElNumbers +="La=57;"
	ListOfElAtomWghts +="La=138.9055;"
	//Ce
	ListOfElements +="Ce;"
	ListOfElNumbers +="Ce=58;"
	ListOfElAtomWghts +="Ce=140.115;"
	//Pr
	ListOfElements +="Pr;"
	ListOfElNumbers +="Pr=59;"
	ListOfElAtomWghts +="Pr=140.90765;"
	//Nd
	ListOfElements +="Nd;"
	ListOfElNumbers +="Nd=60;"
	ListOfElAtomWghts +="Nd=144.24;"
	//Pm
	ListOfElements +="Pm;"
	ListOfElNumbers +="Pm=61;"
	ListOfElAtomWghts +="Pm=146.9151;"
	//Sm
	ListOfElements +="Sm;"
	ListOfElNumbers +="Sm=62;"
	ListOfElAtomWghts +="Sm=150.36;"
	//Eu
	ListOfElements +="Eu;"
	ListOfElNumbers +="Eu=63;"
	ListOfElAtomWghts +="Eu=151.965;"
	//Gd
	ListOfElements +="Gd;"
	ListOfElNumbers +="Gd=64;"
	ListOfElAtomWghts +="Gd=157.25;"
	//Tb
	ListOfElements +="Tb;"
	ListOfElNumbers +="Tb=65;"
	ListOfElAtomWghts +="Tb=158.92534;"
	//Dy
	ListOfElements +="Dy;"
	ListOfElNumbers +="Dy=66;"
	ListOfElAtomWghts +="Dy=162.50;"
	//Ho
	ListOfElements +="Ho;"
	ListOfElNumbers +="Ho=67;"
	ListOfElAtomWghts +="Ho=164.93032;"
	//Er
	ListOfElements +="Er;"
	ListOfElNumbers +="Er=68;"
	ListOfElAtomWghts +="Er=167.26;"
	//Tm
	ListOfElements +="Tm;"
	ListOfElNumbers +="Tm=69;"
	ListOfElAtomWghts +="Tm=168.9342;"
	//Yb
	ListOfElements +="Yb;"
	ListOfElNumbers +="Yb=70;"
	ListOfElAtomWghts +="Yb=173.04;"
	//Lu
	ListOfElements +="Lu;"
	ListOfElNumbers +="Lu=71;"
	ListOfElAtomWghts +="Lu=174.967;"
	//Hf
	ListOfElements +="Hf;"
	ListOfElNumbers +="Hf=72;"
	ListOfElAtomWghts +="Hf=178.49;"
	//Ta
	ListOfElements +="Ta;"
	ListOfElNumbers +="Ta=73;"
	ListOfElAtomWghts +="Ta=180.9479;"
	//W
	ListOfElements +="W;"
	ListOfElNumbers +="W=74;"
	ListOfElAtomWghts +="W=183.84;"
	//Re
	ListOfElements +="Re;"
	ListOfElNumbers +="Re=75;"
	ListOfElAtomWghts +="Re=186.207;"
	//Os
	ListOfElements +="Os;"
	ListOfElNumbers +="Os=76;"
	ListOfElAtomWghts +="Os=190.23;"
	//Ir
	ListOfElements +="Ir;"
	ListOfElNumbers +="Ir=77;"
	ListOfElAtomWghts +="Ir=192.22;"
	//Pt
	ListOfElements +="Pt;"
	ListOfElNumbers +="Pt=78;"
	ListOfElAtomWghts +="Pt=195.08;"
	//Au
	ListOfElements +="Au;"
	ListOfElNumbers +="Au=79;"
	ListOfElAtomWghts +="Au=196.96654;"
	//Hg
	ListOfElements +="Hg;"
	ListOfElNumbers +="Hg=80;"
	ListOfElAtomWghts +="Hg=200.59;"
	//Tl
	ListOfElements +="Tl;"
	ListOfElNumbers +="Tl=81;"
	ListOfElAtomWghts +="Tl=204.3833;"
	//Pb
	ListOfElements +="Pb;"
	ListOfElNumbers +="Pb=82;"
	ListOfElAtomWghts +="Pb=207.2;"
	//Bi
	ListOfElements +="Bi;"
	ListOfElNumbers +="Bi=83;"
	ListOfElAtomWghts +="Bi=208.98037;"
	//Po
	ListOfElements +="Po;"
	ListOfElNumbers +="Po=84;"
	ListOfElAtomWghts +="Po=208.9824;"
	//At
	ListOfElements +="At;"
	ListOfElNumbers +="At=85;"
	ListOfElAtomWghts +="At=209.9871;"
	//Rn
	ListOfElements +="Rn;"
	ListOfElNumbers +="Rn=86;"
	ListOfElAtomWghts +="Rn=222.0176;"
	//Fr
	ListOfElements +="Fr;"
	ListOfElNumbers +="Fr=87;"
	ListOfElAtomWghts +="Fr=223.0197;"
	//Ra
	ListOfElements +="Ra;"
	ListOfElNumbers +="Ra=88;"
	ListOfElAtomWghts +="Ra=226.0254;"
	//Ac
	ListOfElements +="Ac;"
	ListOfElNumbers +="Ac=89;"
	ListOfElAtomWghts +="Ac=227.0278;"
	//Th
	ListOfElements +="Th;"
	ListOfElNumbers +="Th=90;"
	ListOfElAtomWghts +="Th=232.0381;"
	//Pa
	ListOfElements +="Pa;"
	ListOfElNumbers +="Pa=91;"
	ListOfElAtomWghts +="Pa=231.0359;"
	//U
	ListOfElements +="U;"
	ListOfElNumbers +="U=92;"
	ListOfElAtomWghts +="U=238.0289;"
	//Np
	ListOfElements +="Np;"
	ListOfElNumbers +="Np=93;"
	ListOfElAtomWghts +="Np=237.0482;"
	//Pu
	ListOfElements +="Pu;"
	ListOfElNumbers +="Pu=94;"
	ListOfElAtomWghts +="Pu=244.0642;"
	//Am
	ListOfElements +="Am;"
	ListOfElNumbers +="Am=95;"
	ListOfElAtomWghts +="Am=243.0614;"
	//Cm
	ListOfElements +="Cm;"
	ListOfElNumbers +="Cm=96;"
	ListOfElAtomWghts +="Cm=247.0703;"
	//Bk
	ListOfElements +="Bk;"
	ListOfElNumbers +="Bk=97;"
	ListOfElAtomWghts +="Bk=247.0703;"
	//Cf
	ListOfElements +="Cf;"
	ListOfElNumbers +="Cf=98;"
	ListOfElAtomWghts +="Cf=251.0796;"
	//Es
	ListOfElements +="Es;"
	ListOfElNumbers +="Es=99;"
	ListOfElAtomWghts +="Es=252.0829;"
	//Fm
	ListOfElements +="Fm;"
	ListOfElNumbers +="Fm=100;"
	ListOfElAtomWghts +="Fm=257.0951;"
	//Md
	ListOfElements +="Md;"
	ListOfElNumbers +="Md=101;"
	ListOfElAtomWghts +="Md=258.0986;"
	//No
	ListOfElements +="No;"
	ListOfElNumbers +="No=102;"
	ListOfElAtomWghts +="No=259.1009;"
	//Lr
	ListOfElements +="Lr;"
	ListOfElNumbers +="Lr=103;"
	ListOfElAtomWghts +="Lr=262.11;"
	//Rf
	ListOfElements +="Rf;"
	ListOfElNumbers +="Rf=104;"
	ListOfElAtomWghts +="Rf=261.1087;"
	//Db
	ListOfElements +="Db;"
	ListOfElNumbers +="Db=105;"
	ListOfElAtomWghts +="Db=262.1138;"
	//Sg
	ListOfElements +="Sg;"
	ListOfElNumbers +="Sg=106;"
	ListOfElAtomWghts +="Sg=263.1182;"
	//Bh
	ListOfElements +="Bh;"
	ListOfElNumbers +="Bh=107;"
	ListOfElAtomWghts +="Bh=262.1229;"
	//Hs
	ListOfElements +="Hs;"
	ListOfElNumbers +="Hs=108;"
	ListOfElAtomWghts +="Hs=265;"
	//Mt
	ListOfElements +="Mt;"
	ListOfElNumbers +="Mt=109;"
	ListOfElAtomWghts +="Mt=266;"
	
///////////
	//
//	ListOfElements +=";"
//	ListOfElNumbers +="=;"
//	ListOfElAtomWghts +="=;"
//	
//netron part
//	ListOfIsotopes = "H=natural;D=natural;He=natural,He3,He4;..."		use "natural" for natural mixture, element name + number for isotope
//	ListOfElNeutronBs = "H_natural=xxx;D_natural=xxx;He_natural=xxx;He_He3=xxx;..."
//	ListOfElNeuIncohBs= "H_natural=xxx;D_natural=xxx;He_natural=xxx;He_He3=xxx;..."
	//H
	ListOfIsotopes ="H=natural;"
	ListOfElNeutronBs ="H_natural=-0.3740;"
	ListOfElNeuIncohBs="H_natural=79.7;"
	ListofNeutronAbsCross="H_natural=0.33"
	//D
	ListOfIsotopes +="D=natural;"
	ListOfElNeutronBs +="D_natural=0.6674;"
	ListOfElNeuIncohBs+="D_natural=2.0;"
	ListofNeutronAbsCross+="D_natural=0.00046"
	//T
	ListOfIsotopes +="T=natural;"
	ListOfElNeutronBs +="T_natural=0.50;"
	ListOfElNeuIncohBs+="T_natural=NaN;"
	ListofNeutronAbsCross+="T_natural=NaN"
	//He
	ListOfIsotopes +="He=He3,He4;"
	ListOfElNeutronBs+="He_He3=0.62;He_He4=0.30;"
	ListOfElNeuIncohBs+="He_He3=1.2;He_He4=0;"
	ListofNeutronAbsCross+="He_He3=5500;He_He4=0.007;"
	//Li
	ListOfIsotopes +="Li=natural;Li6,Li7;"
	ListOfElNeutronBs+="Li_natural=-0.203;Li_Li6=0.18;Li_Li7=-0.233;"
	ListOfElNeuIncohBs+="Li_natural=0.7;Li_Li6=NaN;Li_Li7=0.7;"
	ListofNeutronAbsCross+="Li_natural=71;Li_Li6=945;Li_Li7=NaN;"
	//Be
	ListOfIsotopes +="Be=natural;"
	ListOfElNeutronBs+="Be_natural=0.78;"
	ListOfElNeuIncohBs+="Be_natural=0.005;"
	ListofNeutronAbsCross+="Be_natural=0.01;"
	//B
	ListOfIsotopes+="B=natural,B10,B11;"
	ListOfElNeutronBs+="B_natural=0.535;B_B10=0.14;B_B11=0.60;"
	ListOfElNeuIncohBs+="B_natural=0.7;B_B10=NaN;B_B11=NaN;"
	ListofNeutronAbsCross+="B_natural=755;B_B10=3813;B_B11=NaN;"
	//C
	ListOfIsotopes +="C=natural,C12,C13;"
	ListOfElNeutronBs+="C_natural=0.66484;C_C12=0.665;C_C13=0.60;"
	ListOfElNeuIncohBs+="C_natural=0.018;C_C12=0;C_C13=1.0;"
	ListofNeutronAbsCross+="C_natural=0.0033;C_C12=NaN;C_C13=NaN;"
	//N
	ListOfIsotopes +="N=natural,N14,N15;"
	ListOfElNeutronBs+="N_natural=0.936;N_N14=0.94;N_N15=0.65;"
	ListOfElNeuIncohBs+="N_natural=0.46;N_N14=NaN;N_N15=NaN;"
	ListofNeutronAbsCross+="N_natural=1.88;N_N14=NaN;N_N15=NaN;"
	//O
	ListOfIsotopes +="O=natural,O16,O17,O18;"
	ListOfElNeutronBs+="O_natural=0.5803;O_O16=0.580;O_O17=0.578;O_O18=0.600;"
	ListOfElNeuIncohBs+="O_natural=0.015;O_O16=0;O_O17=NaN;O_O18=0;"
	ListofNeutronAbsCross+="O_natural=0.0002;O_O16=NaN;O_O17=NaN;O_O18=NaN;"
	//F
	ListOfIsotopes +="F=natural;"
	ListOfElNeutronBs+="F_natural=0.566;"
	ListOfElNeuIncohBs+="F_natural=0.0004;"
	ListofNeutronAbsCross+="F_natural=0.01;"
	//Ne
	ListOfIsotopes +="Ne=natural;"
	ListOfElNeutronBs+="Ne_natural=0.46;"
	ListOfElNeuIncohBs+="Ne_natural=0.11;"
	ListofNeutronAbsCross+="Ne_natural=2.8;"
	//Na
	ListOfIsotopes +="Na=natural;"
	ListOfElNeutronBs+="Na_natural=0.363;"
	ListOfElNeuIncohBs+="Na_natural=1.75;"
	ListofNeutronAbsCross+="Na_natural=0.505;"
	//Mg
	ListOfIsotopes +="Mg=natural,Mg24,Mg25,Mg26;"
	ListOfElNeutronBs+="Mg_natural=0.5375;Mg_Mg24=0.55;Mg_Mg25=0.36;Mg_Mg26=0.49;"
	ListOfElNeuIncohBs+="Mg_natural=0.04;Mg_Mg24=0;Mg_Mg25=NaN;Mg_Mg26=0;"
	ListofNeutronAbsCross+="Mg_natural=0.063;Mg_Mg24=NaN;Mg_Mg25=NaN;Mg_Mg26=NaN;"
	//Al
	ListOfIsotopes +="Al=natural;"
	ListOfElNeutronBs+="Al_natural=0.3446;"
	ListOfElNeuIncohBs+="Al_natural=0.01;"
	ListofNeutronAbsCross+="Al_natural=0.23;"
	//Si
	ListOfIsotopes +="Si=natural;"
	ListOfElNeutronBs+="Si_natural=0.41491;"
	ListOfElNeuIncohBs+="Si_natural=0.017;"
	ListofNeutronAbsCross+="Si_natural=0.16;"
	//P
	ListOfIsotopes +="P=natural;"
	ListOfElNeutronBs+="P_natural=0.513;"
	ListOfElNeuIncohBs+="P_natural=0.23;"
	ListofNeutronAbsCross+="P_natural=0.2;"
	//S
	ListOfIsotopes +="S=natural;"
	ListOfElNeutronBs+="S_natural=0.2847;"
	ListOfElNeuIncohBs+="S_natural=0.012;"
	ListofNeutronAbsCross+="S_natural=0.52;"
	//Cl
	ListOfIsotopes +="Cl=natural,Cl35,Cl37;"
	ListOfElNeutronBs+="Cl_natural=0.95792;Cl_Cl35=1.18;Cl_Cl37=0.26;"
	ListOfElNeuIncohBs+="Cl_natural=5.9;Cl_Cl35=NaN;Cl_Cl37=NaN;"
	ListofNeutronAbsCross+="Cl_natural=33.6;Cl_Cl35=NaN;Cl_Cl37=NaN;"
	//Ar
	ListOfIsotopes +="Ar=natural,Ar36;"
	ListOfElNeutronBs+="Ar_natural=0.18;Ar_Ar36=2.43;"
	ListOfElNeuIncohBs+="Ar_natural=0.27;Ar_Ar36=0;"
	ListofNeutronAbsCross+="Ar_natural=0.66;Ar_Ar36=NaN;"
	//K
	ListOfIsotopes +="K=natural,K39;"
	ListOfElNeutronBs+="K_natural=0.371;K_K39=0.37;"
	ListOfElNeuIncohBs+="K_natural=0.38;K_K39=NaN;"
	ListofNeutronAbsCross+="K_natural=2.07;K_K39=NaN;"
	//Ca
	ListOfIsotopes +="Ca=natural,Ca40,Ca44;"
	ListOfElNeutronBs+="Ca_natural=0.49;Ca_Ca40=0.49;Ca_Ca44=0.18;"
	ListOfElNeuIncohBs+="Ca_natural=0.06;Ca_Ca40=0;Ca_Ca44=0;"
	ListofNeutronAbsCross+="Ca_natural=0.46;Ca_Ca40=NaN;Ca_Ca44=NaN;"
	//Sc
	ListOfIsotopes +="Sc=natural;"
	ListOfElNeutronBs+="Sc_natural=1.215;"
	ListOfElNeuIncohBs+="Sc_natural=0.446;"
	ListofNeutronAbsCross+="Sc_natural=24;"
	//Ti
	ListOfIsotopes +="Ti=natural,Ti46,Ti47,Ti48,Ti49,Ti50;"
	ListOfElNeutronBs+="Ti_natural=-0.337;Ti_Ti46=0.48;Ti_Ti47=0.33;Ti_Ti48=-0.58;Ti_Ti49=0.08;Ti_Ti50=0.55;"
	ListOfElNeuIncohBs+="Ti_natural=2.71;Ti_Ti46=NaN;Ti_Ti47=NaN;Ti_Ti48=NaN;Ti_Ti49=NaN;Ti_Ti50=NaN;"
	ListofNeutronAbsCross+="Ti_natural=5.8;Ti_Ti46=NaN;Ti_Ti47=NaN;Ti_Ti48=NaN;Ti_Ti49=NaN;Ti_Ti50=NaN;"
	//V
	ListOfIsotopes +="V=natural,V51;"
	ListOfElNeutronBs+="V_natural=-0.0385;V_V51=-0.038;"
	ListOfElNeuIncohBs+="V_natural=4.97;V_V51=NaN;"
	ListofNeutronAbsCross+="V_natural=4.98;V_V51=NaN;"
	//Cr
	ListOfIsotopes +="Cr=natural,Cr52;"
	ListOfElNeutronBs+="Cr_natural=0.3532;Cr_Cr52=0.49;"
	ListOfElNeuIncohBs+="Cr_natural=1.90;Cr_Cr52=0;"
	ListofNeutronAbsCross+="CR_natural=3.1;Cr_Cr52=NaN;"
	//Mn
	ListOfIsotopes +="Mn=natural;"
	ListOfElNeutronBs+="Mn_natural=-0.373;"
	ListOfElNeuIncohBs+="Mn_natural=0.6;"
	ListofNeutronAbsCross+="Mn_natural=13.2;"
	//Fe
	ListOfIsotopes +="Fe=natural,Fe54,Fe56,Fe57,Fe58;"
	ListOfElNeutronBs+="Fe_natural=0.954;Fe_Fe54=0.42;Fe_Fe56=1.01;Fe_Fe57=0.23;Fe_Fe58=1.54;"
	ListOfElNeuIncohBs+="Fe_natural=0.22;Fe_Fe54=0;Fe_Fe56=0;Fe_Fe57=NaN;Fe_Fe58=NaN;"
	ListofNeutronAbsCross+="Fe_natural=2.53;Fe_Fe54=NaN;Fe_Fe56=NaN;Fe_Fe57=NaN;Fe_Fe58=NaN;"
	//Co
	ListOfIsotopes +="Co=natural;"
	ListOfElNeutronBs+="Co_natural=0.278;"
	ListOfElNeuIncohBs+="Co_natural=5.22;"
	ListofNeutronAbsCross+="Co_natural=37;"
	//Ni
	ListOfIsotopes +="Ni=natural,Ni58,Ni60,Ni61,Ni62,Ni64;"
	ListOfElNeutronBs+="Ni_natural=1.03;Ni_Ni58=1.44;Ni_Ni60=0.28;Ni_Ni61=0.76;Ni_Ni62=-0.87;Ni_Ni64=-0.037;"
	ListOfElNeuIncohBs+="Ni_natural=5;Ni_Ni58=0;Ni_Ni60=0;Ni_Ni61=NaN;Ni_Ni62=0;Ni_Ni64=0;"
	ListofNeutronAbsCross+="Ni_natural=4.8;Ni_Ni58=NaN;Ni_Ni60=NaN;Ni_Ni61=NaN;Ni_Ni62=NaN;Ni_Ni64=NaN;"
	//Cu
	ListOfIsotopes +="Cu=natural,Cu63,Cu65;"
	ListOfElNeutronBs+="Cu_natural=0.7689;Cu_Cu63=0.67;Cu_Cu65=1.11;"
	ListOfElNeuIncohBs+="Cu_natural=0.51;Cu_Cu63=NaN;Cu_Cu65=NaN;"
	ListofNeutronAbsCross+="Cu_natural=3.77;Cu_Cu63=NaN;Cu_Cu65=NaN;"
	//Zn
	ListOfIsotopes +="Zn=natural,Zn64,Zn66,Zn68;"
	ListOfElNeutronBs+="Zn_natural=0.5686;Zn_Zn64=0.55;Zn_Zn66=0.63;Zn_Zn68=0.68;"
	ListOfElNeuIncohBs+="Zn_natural=0.08;Zn_Zn64=0;Zn_Zn66=0;Zn_Zn68=0;"
	ListofNeutronAbsCross+="Zn_natural=1.1;Zn_Zn64=NaN;Zn_Zn66=NaN;Zn_Zn68=NaN;"
	//Ga
	ListOfIsotopes +="Ga=natural;"
	ListOfElNeutronBs+="Ga_Natural=0.72;"
	ListOfElNeuIncohBs+="Ga_natural=0.5;"
	ListofNeutronAbsCross+="Ga_natural=2.8;"
	//Ge
	ListOfIsotopes +="Ge=natural;"
	ListOfElNeutronBs+="Ge_natural=0.81858;"
	ListOfElNeuIncohBs+="Ge_natural=0.2;"
	ListofNeutronAbsCross+="Ge_natural=2.45;"
	//As
	ListOfIsotopes +="As=natural;"
	ListOfElNeutronBs+="As_natural=0.673;"
	ListOfElNeuIncohBs+="As_natural=1.6;"
	ListofNeutronAbsCross+="As_natural=4.3;"
	//Se
	ListOfIsotopes +="Se=natural;"
	ListOfElNeutronBs+="Se_natural=0.795;"
	ListOfElNeuIncohBs+="Se_natural=0.27;"
	ListofNeutronAbsCross+="Se_natural=12.3;"
	//Br
	ListOfIsotopes +="Br=natural;"
	ListOfElNeutronBs+="Br_natural=0.677;"
	ListOfElNeuIncohBs+="Br_natural=0.5;"
	ListofNeutronAbsCross+="Br_natural=6.7;"
	//Kr
	ListOfIsotopes +="Kr=natural;"
	ListOfElNeutronBs+="Kr_natural=0.791;"
	ListOfElNeuIncohBs+="Kr_natural=NaN;"
	ListofNeutronAbsCross+="Kr_natural=31;"
	//Rb
	ListOfIsotopes +="Rb=natural,Rb85;"
	ListOfElNeutronBs+="Rb_natural=0.708;Rb_Rb85=0.83;"
	ListOfElNeuIncohBs+="Rb_natural=0.4;Rb_Rb85=NaN;"
	ListofNeutronAbsCross+="Rb_natural=0.7;Rb_Rb85=NaN;"
	//Sr
	ListOfIsotopes +="Sr=natural;"
	ListOfElNeutronBs+="Sr_natural=0.69;"
	ListOfElNeuIncohBs+="Sr_natural=4;"
	ListofNeutronAbsCross+="Sr_natural=1.21;"
	//Y
	ListOfIsotopes +="Y=natural;"
	ListOfElNeutronBs+="Y_natural=0.775;"
	ListOfElNeuIncohBs+="Y_natural=0.15;"
	ListofNeutronAbsCross+="Y_natural=1.31;"
	//Zr
	ListOfIsotopes +="Zr=natural;"
	ListOfElNeutronBs+="Zr_natural=0.70;"
	ListOfElNeuIncohBs+="Zr_natural=0.3;"
	ListofNeutronAbsCross+="Zr_natural=0.18;"
	//Nb
	ListOfIsotopes +="Nb=natural;"
	ListOfElNeutronBs+="Nb_natural=0.7050;"
	ListOfElNeuIncohBs+="Nb_natural=0.0063;"
	ListofNeutronAbsCross+="Nb_natural=1.15;"
	//Mo
	ListOfIsotopes +="Mo=natural;"
	ListOfElNeutronBs+="Mo_natural=0.695;"
	ListOfElNeuIncohBs+="Mo_natural=0.6;"
	ListofNeutronAbsCross+="Mo_natural=2.7;"
	//Tc
	ListOfIsotopes +="Tc=Tc99;"
	ListOfElNeutronBs+="Tc_Tc99=0.68;"
	ListOfElNeuIncohBs+="Tc_Tc99=NaN;"
	ListofNeutronAbsCross+="Tc_Tc99=122;"
	//Ru
	ListOfIsotopes +="Ru=natural;"
	ListOfElNeutronBs+="Ru_natural=0.721;"
	ListOfElNeuIncohBs+="Ru_natural=0.1;"
	ListofNeutronAbsCross+="Ru_natural=2.56;"
	//Rh
	ListOfIsotopes +="Rh=natural;"
	ListOfElNeutronBs+="Rh_natural=0.588;"
	ListOfElNeuIncohBs+="Rh_natural=1.2;"
	ListofNeutronAbsCross+="Rh_natural=156;"
	//Pd
	ListOfIsotopes +="Pd=natural;"
	ListOfElNeutronBs+="Pd_natural=0.60;"
	ListOfElNeuIncohBs+="Pd_natural=0.093;"
	ListofNeutronAbsCross+="Pd_natural=8;"
	//Ag
	ListOfIsotopes +="Ag=natural,Ag107,Ag109;"
	ListOfElNeutronBs+="Ag_natural=0.602;Ag_Ag107=0.83;Ag_Ag109=0.43;"
	ListOfElNeuIncohBs+="Ag_natural=0.49;Ag_Ag107=NaN;Ag_Ag109=NaN;"
	ListofNeutronAbsCross+="Ag_natural=63;Ag_Ag107=NaN;Ag_Ag109=NaN;"
	//Cd
	ListOfIsotopes +="Cd=natural,Cd113;"
	ListOfElNeutronBs+="Cd_natural=0.37;Cd_Cd113=-1.5;"
	ListOfElNeuIncohBs+="Cd_natural=NaN;Cd_Cd113=NaN;"
	ListofNeutronAbsCross+="Cd_natural=2450;Cd_Cd113=20000;"
	//In
	ListOfIsotopes +="In=natural;"
	ListOfElNeutronBs+="In_natural=0.408;"
	ListOfElNeuIncohBs+="In_natural=NaN;"
	ListofNeutronAbsCross+="In_natural=196;"
	//Sn
	ListOfIsotopes +="Sn=natural,Sn116,Sn117,Sn118,Sn119,Sn120,Sn122,Sn124;"
	ListOfElNeutronBs+="Sn_natural=0.6223;Sn_Sn116=0.58;Sn_Sn117=0.64;Sn_Sn118=0.58;Sn_Sn119=0.60;Sn_Sn120=0.64;Sn_Sn122=0.55;Sn_Sn124=0.59;"
	ListOfElNeuIncohBs+="Sn_natural=0.022;Sn_Sn116=0;Sn_Sn117=NaN;Sn_Sn118=0;Sn_Sn119=NaN;Sn_Sn120=0;Sn_Sn122=0;Sn_Sn124=0;"
	ListofNeutronAbsCross+="Sn_natural=NaN;Sn_Sn116=NaN;Sn_Sn117=nan;Sn_Sn118=nan;Sn_Sn119=nan;Sn_Sn120=nan;Sn_Sn122=nan;Sn_Sn124=nan;"
	//Sb
	ListOfIsotopes +="Sb=natural;"
	ListOfElNeutronBs+="Sb_natural=0.5641;"
	ListOfElNeuIncohBs+="Sb_natural=0.17;"
	ListofNeutronAbsCross+="Sb_natural=5.7;"
	//Te
	ListOfIsotopes +="Te=natural,Te120,Te123,Te124,Te125;"
	ListOfElNeutronBs+="Te_natural=0.543;Te_Te120=0.52;Te_Te123=0.57;Te_Te124=0.55;Te_Te125=0.56;"
	ListOfElNeuIncohBs+="Te_natural=0.6;Te_Te120=nan;Te_Te123=nan;Te_Te124=nan;Te_Te125=nan;"
	ListofNeutronAbsCross+="Te_natural=4.7;Te_Te120=nan;Te_Te123=nan;Te_Te124=nan;Te_Te125=nan;"
	//I
	ListOfIsotopes +="I=natural;"
	ListOfElNeutronBs+="I_natural=0.528;"
	ListOfElNeuIncohBs+="I_natural=0;"
	ListofNeutronAbsCross+="I_natural=7;"
	//Xe
	ListOfIsotopes +="Xe=natural,Xe135;"
	ListOfElNeutronBs+="Xe_natural=0.488;Xe_Xe135=NaN;"
	ListOfElNeuIncohBs+="Xe_natural=nan;Xe_Xe135=NaN;"
	ListofNeutronAbsCross+="Xe_natural=74;Xe_Xe135=2.7e6;"
	//Cs
	ListOfIsotopes +="Cs=natural;"
	ListOfElNeutronBs+="Cs_natural=0.542;"
	ListOfElNeuIncohBs+="Cs_natural=4.6;"
	ListofNeutronAbsCross+="Cs_natural=29;"
	//Ba
	ListOfIsotopes +="Ba=natural;"
	ListOfElNeutronBs+="Ba_natural=0.528;"
	ListOfElNeuIncohBs+="Ba_natural=2.5;"
	ListofNeutronAbsCross+="Ba_natural=1.2;"
	//La
	ListOfIsotopes +="La=natural,La139;"
	ListOfElNeutronBs+="La_natural=0.827;La_La139=0.83;"
	ListOfElNeuIncohBs+="La_natural=1.87;La_La139=Nan;"
	ListofNeutronAbsCross+="La_natural=9.3;La_La139=Nan;"
	//Ce
	ListOfIsotopes +="Ce=natural,Ce140,Ce142;"
	ListOfElNeutronBs+="Ce_natural=0.483;Ce_Ce140=0.47;Ce_Ce142=0.45;"
	ListOfElNeuIncohBs+="Ce_natural=0;Ce_Ce140=0;Ce_Ce142=0;"
	ListofNeutronAbsCross+="Ce_natural=0.77;Ce_Ce140=nan;Ce_Ce142=nan;"
	//Pr
	ListOfIsotopes +="Pr=natural;"
	ListOfElNeutronBs+="Pr_natural=0.445;"
	ListOfElNeuIncohBs+="Pr_natural=1.6;"
	ListofNeutronAbsCross+="Pr_natural=11.6;"
	//Nd
	ListOfIsotopes +="Nd=natural,Nd142,Nd144,Nd146;"
	ListOfElNeutronBs+="Nd_natural=0.78;Nd_Nd142=0.77;Nd_Nd144=0.28;Nd_Nd164=0.87;"
	ListOfElNeuIncohBs+="Nd_natural=11;Nd_Nd142=0;Nd_Nd144=0;Nd_Nd164=0;"
	ListofNeutronAbsCross+="Nd_natural=46;Nd_Nd142=nan;Nd_Nd144=nan;Nd_Nd164=nan;"
	//Sm
	ListOfIsotopes +="Sm=Sm149,Sm152,Sm154;"
	ListOfElNeutronBs+="Sm_Sm149=-1.9;Sm_Sm152=-0.5;Sm_Sm154=0.96;"
	ListOfElNeuIncohBs+="Sm_Sm149=nan;Sm_Sm152=0;Sm_Sm154=0;"
	ListofNeutronAbsCross+="Sm_Sm149=41000;Sm_Sm152=210;Sm_Sm154=5.5;"
	//Eu
	ListOfIsotopes +="Eu=natural;"
	ListOfElNeutronBs+="Eu_natural=0.68;"
	ListOfElNeuIncohBs+="Eu_natural=nan;"
	ListofNeutronAbsCross+="Eu_natural=4300;"
	//Gd
	ListOfIsotopes +="Gd=natural,Gd157,Gd160;"
	ListOfElNeutronBs+="Gd_natural=1.5;Gd_Gd157=4.3;Gd_Gd160=0.91;"
	ListOfElNeuIncohBs+="Gd_natural=nan;Gd_Gd157=nan;Gd_Gd160=0;"
	ListofNeutronAbsCross+="Gd_natural=49000;Gd_Gd157=254000;Gd_Gd160=0.77;"
	//Tb
	ListOfIsotopes +="Tb=natural;"
	ListOfElNeutronBs+="Tb_natural=0.738;"
	ListOfElNeuIncohBs+="Tb_natural=nan;"
	ListofNeutronAbsCross+="Tb_natural=46;"
	//Dy
	ListOfIsotopes +="Dy-natural,Dy160,Dy161,Dy162,Dy163,Dy164;"
	ListOfElNeutronBs+="Dy_natural=1.71;Dy_Dy160=0.67;Dy_Dy161=1.03;Dy_Dy162=-0.14;Dy_Dy163=0.50;Dy_Dy164=4.94;"
	ListOfElNeuIncohBs+="Dy_natural=nan;Dy_Dy160=0;Dy_Dy161=nan;Dy_Dy162=0;Dy_Dy163=nan;Dy_Dy164=0;"
	ListofNeutronAbsCross+="Dy_natural=950;Dy_Dy160=55;Dy_Dy161=585;Dy_Dy162=200;Dy_Dy163=140;Dy_Dy164=2300;"
	//Ho
	ListOfIsotopes +="Ho=natural;"
	ListOfElNeutronBs+="Ho_natural=0.85;"
	ListOfElNeuIncohBs+="Ho_natural=4;"
	ListofNeutronAbsCross+="Ho_natural=65;"
	//Er
	ListOfIsotopes +="Er=natural;"
	ListOfElNeutronBs+="Er_natural=0.803;"
	ListOfElNeuIncohBs+="Er_natural=7;"
	ListofNeutronAbsCross+="Er_natural=173;"
	//Tm
	ListOfIsotopes +="Tm=natural;"
	ListOfElNeutronBs+="Tm_natural=0.705;"
	ListOfElNeuIncohBs+="Tm_natural=nan;"
	ListofNeutronAbsCross+="Tm_natural=127;"
	//Yb
	ListOfIsotopes +="Yb=natural;"
	ListOfElNeutronBs+="Yb_natural=1.262;"
	ListOfElNeuIncohBs+="Yb_natural=nan;"
	ListofNeutronAbsCross+="Yb_natural=37;"
	//Lu
	ListOfIsotopes +="Lu=natural;"
	ListOfElNeutronBs+="Lu_natural=0.73;"
	ListOfElNeuIncohBs+="Lu_natural=nan;"
	ListofNeutronAbsCross+="Lu_natural=112;"
	//Hf
	ListOfIsotopes +="Hf=natural;"
	ListOfElNeutronBs+="Hf_natural=0.777;"
	ListOfElNeuIncohBs+="Hf_natural=nan;"
	ListofNeutronAbsCross+="Hf_natural=105;"
	//Ta
	ListOfIsotopes +="Ta=natural;"
	ListOfElNeutronBs+="Ta_natural=0.691;"
	ListOfElNeuIncohBs+="Ta_natural=0.02;"
	ListofNeutronAbsCross+="Ta_natural=21;"
	//W
	ListOfIsotopes +="W=natural,W182,W183,W184,W186;"
	ListOfElNeutronBs+="W_natural=0.477;W_W182=0.83;W_W183=0.43;W_W184=0.76;W_W186=-0.12;"
	ListOfElNeuIncohBs+="W_natural=1.86;W_W182=0;W_W183=nan;W_W184=0;W_W186=0;"
	ListofNeutronAbsCross+="W_natural=nan;W_W182=nan;W_W183=nan;W_W184=nan;W_W186=nan"
	//Re
	ListOfIsotopes +="Re=natural;"
	ListOfElNeutronBs+="Re_natural=0.92;"
	ListOfElNeuIncohBs+="Re_natural=nan;"
	ListofNeutronAbsCross+="Re_natural=86;"
	//Os
	ListOfIsotopes +="Os=natural,Os188,Os189,Os190,Os192;"
	ListOfElNeutronBs+="Os_natural=1.08;Os_Os188=0.78;Os_Os189=1.10;Os_Os190=1.14;Os_Os192=1.19;"
	ListOfElNeuIncohBs+="Os_natural=0.5;Os_Os188=0;Os_Os189=nan;Os_Os190=0;Os_Os192=0;"
	ListofNeutronAbsCross+="Os_natural=15.3;Os_Os188=nan;Os_Os189=nan;Os_Os190=nan;Os_Os192=nan;"
	//Ir
	ListOfIsotopes +="Ir=natural;"
	ListOfElNeutronBs+="Ir_natural=1.06;"
	ListOfElNeuIncohBs+="Ir_natural=nan;"
	ListofNeutronAbsCross+="Ir_natural=440;"
	//Pt
	ListOfIsotopes +="Pt=natural;"
	ListOfElNeutronBs+="Pt_natural=0.95;"
	ListOfElNeuIncohBs+="Pt_natural=0.60;"
	ListofNeutronAbsCross+="Pt_natural=8.8;"
	//Au
	ListOfIsotopes +="Au=natural;"
	ListOfElNeutronBs+="Au_natural=0.763;"
	ListOfElNeuIncohBs+="Au_natural=-0.184;"
	ListofNeutronAbsCross+="Au_natural=98.65;"
	//Hg
	ListOfIsotopes +="Hg=natural;"
	ListOfElNeutronBs+="Hg_natural=1.266;"
	ListOfElNeuIncohBs+="Hg_natural=6;"
	ListofNeutronAbsCross+="Hg_natural=375;"
	//Tl
	ListOfIsotopes +="Tl=natural;"
	ListOfElNeutronBs+="Tl_natural=0.889;"
	ListOfElNeuIncohBs+="Tl_natural=0.1;"
	ListofNeutronAbsCross+="Tl_natural=3.4;"
	//Pb
	ListOfIsotopes +="Pb=natural;"
	ListOfElNeutronBs+="Pb_natural=0.94003;"
	ListOfElNeuIncohBs+="Pb_natural=0.0013;"
	ListofNeutronAbsCross+="Pb_natural=0.17;"
	//Bi
	ListOfIsotopes +="Bi=natural;"
	ListOfElNeutronBs+="Bi_natural=0.85;"
	ListOfElNeuIncohBs+="Bi_natural=0.0072;"
	ListofNeutronAbsCross+="Bi_natural=0.036;"
	//Th
	ListOfIsotopes +="Th=Th232;"
	ListOfElNeutronBs+="Th_Th232=1.008;"
	ListOfElNeuIncohBs+="Th_TH232=0;"
	ListofNeutronAbsCross+="Th_Th232=7.56;"
	//Pa
	ListOfIsotopes +="Pa=Pa231;"
	ListOfElNeutronBs+="Pa_Pa231=1.3;"
	ListOfElNeuIncohBs+="Pa_Pa231=nan;"
	ListofNeutronAbsCross+="Pa_Pa231=200;"
	//U
	ListOfIsotopes +="U=natural,U235,U238;"
	ListOfElNeutronBs+="U_natural=0.861;U_U235=0.98;U_U238=0.85;"
	ListOfElNeuIncohBs+="U_natural=nan;U_U235=nan;U_U238=0;"
	ListofNeutronAbsCross+="U_natural=7.68;U_U235=694;U_U238=2.71;"
	//Np
	ListOfIsotopes +="Np=Np237;"
	ListOfElNeutronBs+="Np_Np237=1.06;"
	ListOfElNeuIncohBs+="Np_Np237=nan;"
	ListofNeutronAbsCross+="Np_Np237=170;"
	//Pu
	ListOfIsotopes +="Pu=Pu239,Pu240,Pu242;"
	ListOfElNeutronBs+="Pu_Pu239=0.75;Pu_Pu240=0.35;Pu_Pu242=0.81;"
	ListOfElNeuIncohBs+="Pu_Pu239=nan;Pu_Pu240=0;Pu_Pu242=0;"
	ListofNeutronAbsCross+="Pu_Pu239=1026;Pu_Pu240=295;Pu_Pu242=nan;"
	//Am
	ListOfIsotopes +="Am=Am243;"
	ListOfElNeutronBs+="Am_AM243=0.76;"
	ListOfElNeuIncohBs+="Am_AM243=nan;"
	ListofNeutronAbsCross+="Am_AM243=nan;"
	//Cm
	ListOfIsotopes +="Cm=Cm244;"
	ListOfElNeutronBs+="Cm_Cm244=0.7;"
	ListOfElNeuIncohBs+="Cm_Cm244=0;"
	ListofNeutronAbsCross+="Cm_Cm244=nan;"
	
end


//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************
//******************************************************************************************************************


