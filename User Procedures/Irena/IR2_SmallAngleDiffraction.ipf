#pragma rtGlobals=3 // Use modern global access method.
#pragma version=1.21
Constant IR2DversionNumber = 1.15

//*************************************************************************\
//* Copyright (c) 2005 - 2026, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution.
//*************************************************************************/

//1.21 change to prgagma version 3
//1.20 fix GenCurveFit call, which was failing due to Exists("gencurvefit") returning 4 instead of 3 which was in the code.
//1.19 added units to Intensity
//1.18 modified graph size control to use IN2G_GetGraphWidthHeight and associated settings. Should work on various display sizes.
//1.17 modified fitting to include Igor display with iterations /N=0/W=0
//1.16  removed unused functions
//1.15 added getHelp button calling to www manual
//1.14 added oversampling to calculation of peak parameters. When user selects "oversample", peaks are calculated at 5x higher resolution. This provides parameters 5x more precise than what measured Q points are.
//1.13 fixed bug in linking which showed on Igor 7 and caused error messages.
//1.12 fixed bug in useSMR data which called old code and screwed up control procedures.
//1.11 removed most Executes in preparation for Igor 7.
//1.10 added check fro slit smeared data if qmax is sufficently high (3* slit length is minimum).
//1.09 changed term for storing data back to folder, Previously used  save, which confused users.
//1.08 added panel version control and made panel vertically scrollable.
//1.07 removed all font and font size from panel definitions to enable user control
//1.06 fixed the PercusYevickSQFQ to actually use F(Q)^2
//1.05 fixed some GUI bugs
//1.04 added Lorenz Squared peak profile per request and few other weird profiles
//1.03 removed old method of genetic optimization
//1.02 added license for ANL

//January 2008. JIL.
//First version of the Small-angle scattering package in version 2.25 of Irena package. Basic SA diffraction package with usual functionality. Mostly in manual.
// January 13, 2008 added Rg and prefactor for Rg, changed to use basic one level of Unified fit for background.

//Comment to be able to remember...
// Common structures - peak d spacing ratios
// Lamellar  1: 2 : 3 : 4 : 5 : 6 : 7
// Hexagonally packed cylinders 1 : sqrt(3) : 2 : sqrt(7) : 3 : sqrt(12) : sqrt(13) : 4
// Primitive (simple cubic) 1 : sqrt(2) : sqrt(3) : 2 : sqrt(5) : sqrt(6) :sqrt(8) : 3
// BCC   1 : sqrt(2) : sqrt(3) : 2 : sqrt(5) : sqrt(6) : sqrt(7) : sqrt(8) : 3
//FCC    sqrt(3) : 2 : sqrt(8) : sqrt (11) : sqrt(12) : 4 : sqrt(19)
// Hex close packed  sqrt(32) : 6 : sqrt(41) : sqrt(68) : sqrt(96) : sqrt(113)
// double diamond   sqrt(2) : sqrt(3) : 2 : sqrt(6) :sqrt(8) : 3 : sqrt(10) : sqrt(11)
//Ialpha(-3)d		sqrt(3) : 2 : sqrt(7) :sqrt(8) : sqrt(10) : sqrt(11) : sqrt(12)
//Pm3m		sqrt(2) : 2 : sqrt(5) : sqrt(6) : sqrt(8) : sqrt(10) : sqrt(12)
// from Block copolymers: synthetic strategies, Physical properties and applications, Hadjichrististidis, Pispas, Floudas, Willey & sons, 2003, chapter 19, pg 347
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_MainSmallAngleDiff()

	IN2G_CheckScreenSize("height", 670)

	IR2D_InitializeSAD()

	DoWindow IR2D_ControlPanel
	if(V_Flag)
		DoWIndow/K IR2D_ControlPanel
	endif
	Execute("IR2D_ControlPanel()")
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("IR2D_ControlPanel", IR2DversionNumber, 1)

End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR2D_MainCheckVersion()
	DoWindow IR2D_ControlPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("IR2D_ControlPanel", IR2DversionNumber))
			DoAlert/T="The Diffraction tool panel was created by incorrect version of Irena " 1, "Diffraction tool may need to be restarted to work properly. Restart now?"
			if(V_flag == 1)
				IR2D_MainSmallAngleDiff()
			else //at least reinitialize the variables so we avoid major crashes...
				IR2D_InitializeSAD() //this may be OK now...
			endif
		endif
	endif
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_InitializeSAD()

	DFREF oldDf = GetDataFolderDFR()

	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:Irena_SAD

	string/G ListOfVariables
	string/G ListOfStrings

	ListOfVariables  = "UseIndra2Data;UseQRSdata;UseSMRData;SlitLength;AutoRecalculate;UserCanceled;UseGeneticOptimization;DisplayPeaks;PeakSASScaling;"
	ListOfVariables += "UseGeneticOptimization;Oversample;ResultingChiSquared;UseLogX;UseLogY;AppendResiduals;AppendNormalizedResiduals;"
	ListOfVariables += "Background;FitBackground;BackgroundLowLimit;BackgroundHighLimit;"
	ListOfVariables += "PwrLawPref;FitPwrLawPref;PwrLawPrefLowLimit;PwrLawPrefHighLimit;"
	ListOfVariables += "PwrLawSlope;FitPwrLawSlope;PwrLawSlopeLowLimit;PwrLawSlopeHighLimit;"
	ListOfVariables += "RgPrefactor;FitRgPrefactor;RgPrefactorLowLimit;RgPrefactorHighLimit;"
	ListOfVariables += "Rg;FitRg;RgLowLimit;RgHighLimit;"

	ListOfVariables += "UsePeak1;UsePeak2;UsePeak3;UsePeak4;UsePeak5;UsePeak6;"

	ListOfVariables += "PeakDPosition1;PeakDPosition2;PeakDPosition3;PeakDPosition4;PeakDPosition5;PeakDPosition6;"
	ListOfVariables += "PeakPosition1;PeakPosition2;PeakPosition3;PeakPosition4;PeakPosition5;PeakPosition6;"
	ListOfVariables += "PeakFWHM1;PeakFWHM2;PeakFWHM3;PeakFWHM4;PeakFWHM5;PeakFWHM6;"
	ListOfVariables += "PeakIntgInt1;PeakIntgInt2;PeakIntgInt3;PeakIntgInt4;PeakIntgInt5;PeakIntgInt6;"

	ListOfVariables += "Peak1_Par1;FitPeak1_Par1;Peak1_Par1LowLimit;Peak1_Par1HighLimit;"
	ListOfVariables += "Peak1_Par2;FitPeak1_Par2;Peak1_Par2LowLimit;Peak1_Par2HighLimit;"
	ListOfVariables += "Peak1_Par3;FitPeak1_Par3;Peak1_Par3LowLimit;Peak1_Par3HighLimit;"
	ListOfVariables += "Peak1_Par4;FitPeak1_Par4;Peak1_Par4LowLimit;Peak1_Par4HighLimit;"
	ListOfVariables += "Peak1_LinkPar2;Peak1_LinkMultiplier;"

	ListOfVariables += "Peak2_Par1;FitPeak2_Par1;Peak2_Par1LowLimit;Peak2_Par1HighLimit;"
	ListOfVariables += "Peak2_Par2;FitPeak2_Par2;Peak2_Par2LowLimit;Peak2_Par2HighLimit;"
	ListOfVariables += "Peak2_Par3;FitPeak2_Par3;Peak2_Par3LowLimit;Peak2_Par3HighLimit;"
	ListOfVariables += "Peak2_Par4;FitPeak2_Par4;Peak2_Par4LowLimit;Peak2_Par4HighLimit;"
	ListOfVariables += "Peak2_LinkPar2;Peak2_LinkMultiplier;"

	ListOfVariables += "Peak3_Par1;FitPeak3_Par1;Peak3_Par1LowLimit;Peak3_Par1HighLimit;"
	ListOfVariables += "Peak3_Par2;FitPeak3_Par2;Peak3_Par2LowLimit;Peak3_Par2HighLimit;"
	ListOfVariables += "Peak3_Par3;FitPeak3_Par3;Peak3_Par3LowLimit;Peak3_Par3HighLimit;"
	ListOfVariables += "Peak3_Par4;FitPeak3_Par4;Peak3_Par4LowLimit;Peak3_Par4HighLimit;"
	ListOfVariables += "Peak3_LinkPar2;Peak3_LinkMultiplier;"

	ListOfVariables += "Peak4_Par1;FitPeak4_Par1;Peak4_Par1LowLimit;Peak4_Par1HighLimit;"
	ListOfVariables += "Peak4_Par2;FitPeak4_Par2;Peak4_Par2LowLimit;Peak4_Par2HighLimit;"
	ListOfVariables += "Peak4_Par3;FitPeak4_Par3;Peak4_Par3LowLimit;Peak4_Par3HighLimit;"
	ListOfVariables += "Peak4_Par4;FitPeak4_Par4;Peak4_Par4LowLimit;Peak4_Par4HighLimit;"
	ListOfVariables += "Peak4_LinkPar2;Peak4_LinkMultiplier;"

	ListOfVariables += "Peak5_Par1;FitPeak5_Par1;Peak5_Par1LowLimit;Peak5_Par1HighLimit;"
	ListOfVariables += "Peak5_Par2;FitPeak5_Par2;Peak5_Par2LowLimit;Peak5_Par2HighLimit;"
	ListOfVariables += "Peak5_Par4;FitPeak5_Par4;Peak5_Par4LowLimit;Peak5_Par4HighLimit;"
	ListOfVariables += "Peak5_Par3;FitPeak5_Par3;Peak5_Par3LowLimit;Peak5_Par3HighLimit;"
	ListOfVariables += "Peak5_LinkPar2;Peak5_LinkMultiplier;"

	ListOfVariables += "Peak6_Par1;FitPeak6_Par1;Peak6_Par1LowLimit;Peak6_Par1HighLimit;"
	ListOfVariables += "Peak6_Par2;FitPeak6_Par2;Peak6_Par2LowLimit;Peak6_Par2HighLimit;"
	ListOfVariables += "Peak6_Par3;FitPeak6_Par3;Peak6_Par3LowLimit;Peak6_Par3HighLimit;"
	ListOfVariables += "Peak6_Par4;FitPeak6_Par4;Peak6_Par4LowLimit;Peak6_Par4HighLimit;"
	ListOfVariables += "Peak6_LinkPar2;Peak6_LinkMultiplier;"

	ListOfStrings  = "DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;ListOfKnownPeakShapes;"
	ListOfStrings += "Peak1_Function;Peak2_Function;Peak3_Function;Peak4_Function;Peak5_Function;Peak6_Function;"
	ListOfStrings += "Peak1_LinkedTo;Peak2_LinkedTo;Peak3_LinkedTo;Peak4_LinkedTo;Peak5_LinkedTo;Peak6_LinkedTo;"
	ListOfStrings += "PeakRelationship;"
	string/G ListOfKnownPeakRelationships = "---;Lamellar;HCP cylinders;Simple Cubic;BCC;FCC;HCP spheres;Doube Diamond;1a-3d;Pm-3n;"
	variable i
	//and here we create them
	for(i = 0; i < itemsInList(ListOfVariables); i += 1)
		IN2G_CreateItem("variable", StringFromList(i, ListOfVariables))
	endfor

	for(i = 0; i < itemsInList(ListOfStrings); i += 1)
		IN2G_CreateItem("string", StringFromList(i, ListOfStrings))
	endfor
	SVAR PeakRelationship
	if(strlen(PeakRelationship) < 2)
		PeakRelationship = "---"
	endif

	for(i = 1; i <= 6; i += 1)
		SVAR testStr = $("Peak" + num2str(i) + "_Function")
		if(strlen(testStr) < 2)
			testStr = "Gauss"
		endif
	endfor
	for(i = 1; i <= 6; i += 1)
		NVAR testPar1 = $("Peak" + num2str(i) + "_Par1")
		if(testPar1 == 0)
			testPar1 = 1
		endif
		NVAR testPar1 = $("Peak" + num2str(i) + "_LinkMultiplier")
		if(testPar1 == 0)
			testPar1 = 4
		endif
		NVAR testPar2 = $("Peak" + num2str(i) + "_Par2")
		if(testPar2 == 0)
			testPar2 = 0.01
		endif
		NVAR testPar3 = $("Peak" + num2str(i) + "_Par3")
		if(testPar3 == 0)
			testPar3 = 0.01
		endif
		NVAR testPar4 = $("Peak" + num2str(i) + "_Par4")
		if(testPar4 == 0)
			testPar4 = 0.5
		endif
		NVAR testPar4LL = $("Peak" + num2str(i) + "_Par4LowLimit")
		testPar4LL = 0
		NVAR testPar4HL = $("Peak" + num2str(i) + "_Par4HighLimit")
		testPar4HL = 1
		SVAR testStr = $("Peak" + num2str(i) + "_LinkedTo")
		if(strlen(TestStr) < 3)
			testStr = "---"
		endif
	endfor
	NVAR Rg
	NVAR RgPrefactor
	if(Rg == 0)
		Rg          = 10^10
		RgPrefactor = 0
	endif
	NVAR PwrLawPref
	if(PwrLawPref == 0)
		PwrLawPref = 1
	endif
	NVAR PwrLawSlope
	if(PwrLawSlope == 0)
		PwrLawSlope = 4
	endif
	SVAR ListOfKnownPeakShapes
	ListOfKnownPeakShapes  = "Gauss;Lorenz;LorenzSquared;Pseudo-Voigt;Gumbel;Pearson_VII;Modif_Gauss;SkewedNormal;"
	ListOfKnownPeakShapes += "Percus-Yevick-Sq;Percus-Yevick-SqFq;"
	ListOfKnownPeakShapes += "LogNormal;"

	setDataFolder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Window IR2D_ControlPanel()
	PauseUpdate // building window...
	NewPanel/K=1/W=(2.25, 43.25, 390, 690) as "Small angle diffraction panel"

	string UserDataTypes  = ""
	string UserNameString = ""
	string XUserLookup    = "r*:q*;"
	string EUserLookup    = "r*:s*;"
	IR2C_AddDataControls("Irena_SAD", "IR2D_ControlPanel", "DSM_Int;M_DSM_Int;SMR_Int;M_SMR_Int;", "", UserDataTypes, UserNameString, XUserLookup, EUserLookup, 0, 1)

	TitleBox MainTitle, title="\Zr210Small angle diffraction input panel", pos={20, 0}, anchor=MC, frame=0, fstyle=3, font="Times New Roman", size={350, 24}, fColor=(0, 0, 52224)
	TitleBox FakeLine1, title=" ", fixedSize=1, size={330, 3}, pos={16, 181}, frame=0, fColor=(0, 0, 52224), labelBack=(0, 0, 52224)
	TitleBox Info1, title="\Zr160Data input", pos={10, 30}, frame=0, fstyle=1, fixedSize=1, size={80, 20}, fColor=(0, 0, 52224)
	TitleBox Info2, title="\Zr160Model input", pos={10, 185}, frame=0, fstyle=2, fixedSize=1, size={150, 20}, fColor=(0, 0, 52224)
	TitleBox Info3, title="Fit?   Low limit:    High Limit:", pos={200, 260}, frame=0, fstyle=2, fixedSize=0, size={20, 15}

	CheckBox UseSMRData, pos={170, 40}, size={141, 14}, proc=IR2D_InputPanelCheckboxProc, title="SMR data"
	CheckBox UseSMRData, variable=root:packages:Irena_SAD:UseSMRData, help={"Check, if you are using slit smeared data"}
	SetVariable SlitLength, limits={0, Inf, 0}, value=root:Packages:Irena_SAD:SlitLength, disable=!root:packages:Irena_SAD:UseSMRData
	SetVariable SlitLength, pos={260, 40}, size={100, 16}, title="SL=", noproc, help={"slit length"}

	Button DrawGraphs, pos={56, 158}, size={100, 20}, proc=IR2D_InputPanelButtonProc, title="Graph", help={"Create a graph (log-log) of your experiment data"}
	Button GetHelp, pos={305, 105}, size={80, 15}, fColor=(65535, 32768, 32768), proc=IR2D_InputPanelButtonProc, title="Get Help", help={"Open www manual page for this tool"}

	CheckBox UseLogX, pos={250, 150}, size={141, 14}, proc=IR2D_InputPanelCheckboxProc2, title="Log X axis?"
	CheckBox UseLogX, variable=root:packages:Irena_SAD:UseLogX, help={"Check, if you want to display X axis on log scale"}
	CheckBox UseLogY, pos={250, 165}, size={141, 14}, proc=IR2D_InputPanelCheckboxProc2, title="Log Y axis?"
	CheckBox UseLogY, variable=root:packages:Irena_SAD:UseLogY, help={"Check, if you want to display Y axis on log scale"}

	CheckBox AutoRecalculate, pos={150, 185}, size={141, 14}, proc=IR2D_InputPanelCheckboxProc, title="Auto recalculate"
	CheckBox AutoRecalculate, variable=root:packages:Irena_SAD:AutoRecalculate, help={"Check, if you want to reclaculate data at any change"}
	CheckBox PeakSASScaling, pos={150, 201}, size={141, 14}, proc=IR2D_InputPanelCheckboxProc, title="Peak SAS rel."
	CheckBox PeakSASScaling, variable=root:packages:Irena_SAD:PeakSASScaling, help={"Check, to modify relationship between SAS and peaks. See manual."}

	CheckBox DisplayPeaks, pos={250, 185}, size={141, 14}, proc=IR2D_InputPanelCheckboxProc, title="Display peaks"
	CheckBox DisplayPeaks, variable=root:packages:Irena_SAD:DisplayPeaks, help={"Check, if you want to display peaks"}
	CheckBox Oversample, pos={250, 201}, size={141, 14}, proc=IR2D_InputPanelCheckboxProc, title="Oversample (SMR)"
	CheckBox Oversample, variable=root:packages:Irena_SAD:Oversample, help={"Check, if you have artefacts for slit smeared data and want to oversample (slow)"}

	TabControl DataTabs, pos={2, 220}, size={380, 320}, proc=IR2D_TabPanelControl
	TabControl DataTabs, tabLabel(0)="SAS", tabLabel(1)="Pk 1"
	TabControl DataTabs, tabLabel(2)="Pk 2", tabLabel(3)="Pk 3"
	TabControl DataTabs, tabLabel(4)="Pk 4", tabLabel(5)="Pk 5"
	TabControl DataTabs, tabLabel(6)="Pk 6", value=0

	//	ListOfVariables+="Background;FitBackground;BackgroundowLimit;BackgroundHighLimit;"
	//	/ListOfVariables+="PwrLawPref;FitPwrLawPref;PwrLawPrefLowLimit;PwrLawPrefHighLimit;"
	//	ListOfVariables+="PwrLawSlope;FitPwrLawSlope;PwrLawSlopeLowLimit;PwrLawSlopeHighLimit;"
	SetVariable RgPrefactor, pos={14, 280}, size={180, 16}, proc=IR2D_PanelSetVarProc, title="G   ", format="%.4g"
	SetVariable RgPrefactor, limits={0, Inf, 0.03 * root:Packages:Irena_SAD:RgPrefactor}, value=root:Packages:Irena_SAD:RgPrefactor, help={"Guinier prefactor"}
	CheckBox FitRgPrefactor, pos={200, 281}, size={80, 16}, proc=IR2D_InputPanelCheckboxProc, title=" "
	CheckBox FitRgPrefactor, variable=root:Packages:Irena_SAD:FitRgPrefactor, help={"Fit G?, find god starting conditions and select fitting limits..."}
	SetVariable RgPrefactorLowLimit, pos={230, 280}, size={60, 16}, title=" ", format="%.3g"
	SetVariable RgPrefactorLowLimit, limits={0, Inf, 0}, value=root:Packages:Irena_SAD:RgPrefactorLowLimit, help={"Low limit for G fitting"}
	SetVariable RgPrefactorHighLimit, pos={300, 280}, size={60, 16}, title=" ", format="%.3g"
	SetVariable RgPrefactorHighLimit, limits={0, Inf, 0}, value=root:Packages:Irena_SAD:RgPrefactorHighLimit, help={"High limit for G fitting"}

	SetVariable Rg, pos={14, 300}, size={180, 16}, proc=IR2D_PanelSetVarProc, title="Rg  ", format="%.4g"
	SetVariable Rg, limits={0, Inf, 0.03 * root:Packages:Irena_SAD:Rg}, value=root:Packages:Irena_SAD:Rg, help={"Guinier radius"}
	CheckBox FitRg, pos={200, 301}, size={80, 16}, proc=IR2D_InputPanelCheckboxProc, title=" "
	CheckBox FitRg, variable=root:Packages:Irena_SAD:FitRg, help={"Fit Rg?, find god starting conditions and select fitting limits..."}
	SetVariable RgLowLimit, pos={230, 300}, size={60, 16}, title=" ", format="%.3g"
	SetVariable RgLowLimit, limits={0, Inf, 0}, value=root:Packages:Irena_SAD:RgLowLimit, help={"Low limit for Rg fitting"}
	SetVariable RgHighLimit, pos={300, 300}, size={60, 16}, title=" ", format="%.3g"
	SetVariable RgHighLimit, limits={0, Inf, 0}, value=root:Packages:Irena_SAD:RgHighLimit, help={"High limit for Rg fitting"}

	SetVariable PwrLawPref, pos={14, 320}, size={180, 16}, proc=IR2D_PanelSetVarProc, title="B   ", format="%.4g"
	SetVariable PwrLawPref, limits={0, Inf, 0.03 * root:Packages:Irena_SAD:PwrLawPref}, value=root:Packages:Irena_SAD:PwrLawPref, help={"Powerlaw prefactor"}
	CheckBox FitPwrLawPref, pos={200, 321}, size={80, 16}, proc=IR2D_InputPanelCheckboxProc, title=" "
	CheckBox FitPwrLawPref, variable=root:Packages:Irena_SAD:FitPwrLawPref, help={"Fit B?, find god starting conditions and select fitting limits..."}
	SetVariable PwrLawPrefLowLimit, pos={230, 320}, size={60, 16}, title=" ", format="%.3g"
	SetVariable PwrLawPrefLowLimit, limits={0, Inf, 0}, value=root:Packages:Irena_SAD:PwrLawPrefLowLimit, help={"Low limit for B fitting"}
	SetVariable PwrLawPrefHighLimit, pos={300, 320}, size={60, 16}, title=" ", format="%.3g"
	SetVariable PwrLawPrefHighLimit, limits={0, Inf, 0}, value=root:Packages:Irena_SAD:PwrLawPrefHighLimit, help={"High limit for B fitting"}

	SetVariable PwrLawSlope, pos={14, 340}, size={180, 16}, proc=IR2D_PanelSetVarProc, title="P   ", format="%.4g"
	SetVariable PwrLawSlope, limits={0, Inf, 0.03 * root:Packages:Irena_SAD:PwrLawSlope}, value=root:Packages:Irena_SAD:PwrLawSlope, help={"Power law slope"}
	CheckBox FitPwrLawSlope, pos={200, 341}, size={80, 16}, proc=IR2D_InputPanelCheckboxProc, title=" "
	CheckBox FitPwrLawSlope, variable=root:Packages:Irena_SAD:FitPwrLawSlope, help={"Fit P?, find god starting conditions and select fitting limits..."}
	SetVariable PwrLawSlopeLowLimit, pos={230, 340}, size={60, 16}, title=" ", format="%.3g"
	SetVariable PwrLawSlopeLowLimit, limits={0, Inf, 0}, value=root:Packages:Irena_SAD:PwrLawSlopeLowLimit, help={"Low limit for P fitting"}
	SetVariable PwrLawSlopeHighLimit, pos={300, 340}, size={60, 16}, title=" ", format="%.3g"
	SetVariable PwrLawSlopeHighLimit, limits={0, Inf, 0}, value=root:Packages:Irena_SAD:PwrLawSlopeHighLimit, help={"High limit for P fitting"}

	SetVariable Background, pos={14, 360}, size={180, 16}, proc=IR2D_PanelSetVarProc, title="Bckg", format="%.4g"
	SetVariable Background, limits={-Inf, Inf, 0.03 * root:Packages:Irena_SAD:Background}, value=root:Packages:Irena_SAD:Background, help={"Background"}
	CheckBox FitBackground, pos={200, 361}, size={80, 16}, proc=IR2D_InputPanelCheckboxProc, title=" "
	CheckBox FitBackground, variable=root:Packages:Irena_SAD:FitBackground, help={"Fit Background?, find god starting conditions and select fitting limits..."}
	SetVariable BackgroundLowLimit, pos={230, 360}, size={60, 16}, title=" ", format="%.3g"
	SetVariable BackgroundLowLimit, limits={0, Inf, 0}, value=root:Packages:Irena_SAD:BackgroundLowLimit, help={"Low limit for Background fitting"}
	SetVariable BackgroundHighLimit, pos={300, 360}, size={60, 16}, title=" ", format="%.3g"
	SetVariable BackgroundHighLimit, limits={0, Inf, 0}, value=root:Packages:Irena_SAD:BackgroundHighLimit, help={"High limit for Background fitting"}

	//and now the other 6 tabs for 6 peaks... Populate them
	CheckBox UseThePeak, pos={10, 245}, size={25, 16}, proc=IR2D_ModelTabCheckboxProc, title="Use?", fstyle=1
	CheckBox UseThePeak, variable=root:Packages:Irena_SAD:UsePeak1, help={"Use the peak in model?"}

	PopupMenu PopSizeDistShape, title="Peak shape : ", proc=IR2D_PanelPopupControl, pos={10, 280}
	PopupMenu PopSizeDistShape, value=root:packages:Irena_SAD:ListOfKnownPeakShapes, mode=whichListItem(root:Packages:Irena_SAD:Peak1_Function, root:Packages:Irena_SAD:ListOfKnownPeakShapes) + 1
	PopupMenu PopSizeDistShape, help={"Select peak profile for this population"}

	SetVariable Peak_Par1, limits={0, Inf, 0.03 * root:Packages:Irena_SAD:Peak1_Par1}, variable=root:Packages:Irena_SAD:Peak1_Par1, proc=IR2D_PanelSetVarProc
	SetVariable Peak_Par1, pos={5, 320}, size={180, 16}, title="Prefactor    :", help={"Peak parameter 1"}, format="%.4g"
	CheckBox FitPeak_Par1, pos={200, 320}, size={80, 16}, proc=IR2D_ModelTabCheckboxProc, title=" ", fstyle=1
	CheckBox FitPeak_Par1, variable=root:Packages:Irena_SAD:FitPeak1_Par1, help={"Fit this parameter?"}
	SetVariable Peak_Par1LowLimit, limits={0, Inf, 0}, variable=root:Packages:Irena_SAD:Peak1_Par1LowLimit, noproc, format="%.4g"
	SetVariable Peak_Par1LowLimit, pos={230, 320}, size={60, 15}, title=" ", help={"This is min selected for this peak parameter"}
	SetVariable Peak_Par1HighLimit, limits={0, Inf, 0}, variable=root:Packages:Irena_SAD:Peak1_Par1HighLimit, noproc, format="%.4g"
	SetVariable Peak_Par1HighLimit, pos={300, 320}, size={60, 15}, title=" ", help={"This is max selected for this peak parameter"}

	SetVariable Peak_Par2, limits={0, Inf, 0.03 * root:Packages:Irena_SAD:Peak1_Par2}, variable=root:Packages:Irena_SAD:Peak1_Par2, proc=IR2D_PanelSetVarProc
	SetVariable Peak_Par2, pos={5, 340}, size={180, 16}, title="Position       :", help={"Peak parameter 2"}, format="%.4g"
	CheckBox FitPeak_Par2, pos={200, 340}, size={80, 16}, proc=IR2D_ModelTabCheckboxProc, title=" ", fstyle=1
	CheckBox FitPeak_Par2, variable=root:Packages:Irena_SAD:FitPeak1_Par2, help={"Fit this parameter?"}
	SetVariable Peak_Par2LowLimit, limits={0, Inf, 0}, variable=root:Packages:Irena_SAD:Peak1_Par2LowLimit, noproc, format="%.4g"
	SetVariable Peak_Par2LowLimit, pos={230, 340}, size={60, 15}, title=" ", help={"This is min selected for this peak parameter"}
	SetVariable Peak_Par2HighLimit, limits={0, Inf, 0}, variable=root:Packages:Irena_SAD:Peak1_Par2HighLimit, noproc, format="%.4g"
	SetVariable Peak_Par2HighLimit, pos={300, 340}, size={60, 15}, title=" ", help={"This is max selected for this peak parameter"}

	SetVariable Peak_Par3, limits={0, Inf, 0.03 * root:Packages:Irena_SAD:Peak1_Par3}, variable=root:Packages:Irena_SAD:Peak1_Par3, proc=IR2D_PanelSetVarProc
	SetVariable Peak_Par3, pos={5, 360}, size={180, 16}, title="Width          :", help={"Peak parameter 3"}, format="%.4g"
	CheckBox FitPeak_Par3, pos={200, 360}, size={80, 16}, proc=IR2D_ModelTabCheckboxProc, title=" ", fstyle=1
	CheckBox FitPeak_Par3, variable=root:Packages:Irena_SAD:FitPeak1_Par3, help={"Fit this parameter?"}
	SetVariable Peak_Par3LowLimit, limits={0, Inf, 0}, variable=root:Packages:Irena_SAD:Peak1_Par3LowLimit, noproc, format="%.4g"
	SetVariable Peak_Par3LowLimit, pos={230, 360}, size={60, 15}, title=" ", help={"This is min selected for this peak parameter"}
	SetVariable Peak_Par3HighLimit, limits={0, Inf, 0}, variable=root:Packages:Irena_SAD:Peak1_Par3HighLimit, noproc, format="%.4g"
	SetVariable Peak_Par3HighLimit, pos={300, 360}, size={60, 15}, title=" ", help={"This is max selected for this peak parameter"}

	SetVariable Peak_Par4, limits={0, 1, 0.03 * root:Packages:Irena_SAD:Peak1_Par4}, variable=root:Packages:Irena_SAD:Peak1_Par4, proc=IR2D_PanelSetVarProc
	SetVariable Peak_Par4, pos={5, 380}, size={180, 16}, title="Eta(Pseudo-Voigt):", help={"Peak parameter 3"}, format="%.4g"
	CheckBox FitPeak_Par4, pos={200, 380}, size={80, 16}, proc=IR2D_ModelTabCheckboxProc, title=" ", fstyle=1
	CheckBox FitPeak_Par4, variable=root:Packages:Irena_SAD:FitPeak1_Par4, help={"Fit this parameter?"}
	SetVariable Peak_Par4LowLimit, limits={0, 1, 0}, variable=root:Packages:Irena_SAD:Peak1_Par4LowLimit, noproc, format="%.4g"
	SetVariable Peak_Par4LowLimit, pos={230, 380}, size={60, 15}, title=" ", help={"This is min selected for this peak parameter"}
	SetVariable Peak_Par4HighLimit, limits={0, 1, 0}, variable=root:Packages:Irena_SAD:Peak1_Par4HighLimit, noproc, format="%.4g"
	SetVariable Peak_Par4HighLimit, pos={300, 380}, size={60, 15}, title=" ", help={"This is max selected for this peak parameter"}

	CheckBox Peak_LinkPar2, pos={10, 410}, size={80, 16}, proc=IR2D_ModelTabCheckboxProc, title="Link Position to other peak?", fstyle=1
	CheckBox Peak_LinkPar2, variable=root:Packages:Irena_SAD:Peak1_LinkPar2, help={"Link the position parameter to other peak position?"}
	PopupMenu Peak_LinkedTo, title="Link to : ", proc=IR2D_PanelPopupControl, pos={10, 430}
	PopupMenu Peak_LinkedTo, value="---;Peak1;Peak2;Peak3;Peak4;Peak5;Peak6;", mode=whichListItem(root:Packages:Irena_SAD:Peak1_LinkedTo, "---;Peak1;Peak2;Peak3;Peak4;Peak5;Peak6;") + 1
	PopupMenu Peak_LinkedTo, help={"Select which population to link to"}
	SetVariable Peak_LinkMultiplier, limits={1e-10, Inf, 0}, variable=root:Packages:Irena_SAD:Peak1_LinkMultiplier, proc=IR2D_PanelSetVarProc
	SetVariable Peak_LinkMultiplier, pos={200, 433}, size={130, 16}, title="Multiplier", help={"Multiplier to scale the Pak X position here"}

	SetVariable PeakDPosition, limits={0, 1, 0}, variable=root:Packages:Irena_SAD:PeakDPosition1, noproc, disable=2, format="%.6g"
	SetVariable PeakDPosition, pos={5, 460}, size={280, 16}, title="Peak position -spacing [A]:", help={"peak position in D units"}
	SetVariable PeakPosition, limits={0, 1, 0}, variable=root:Packages:Irena_SAD:PeakPosition1, noproc, disable=2, format="%.4g"
	SetVariable PeakPosition, pos={5, 480}, size={280, 16}, title="Peak position - Q   [A^-1]:", help={"peak position in Q units"}
	SetVariable PeakFWHM, limits={0, 1, 0}, variable=root:Packages:Irena_SAD:PeakFWHM1, noproc, disable=2, format="%.4g"
	SetVariable PeakFWHM, pos={5, 500}, size={280, 16}, title="Peak FWHM [A^-1]:", help={"peak FWHM in Q units"}
	SetVariable PeakIntgInt, limits={0, 1, 0}, variable=root:Packages:Irena_SAD:PeakIntgInt1, noproc, disable=2, format="%.4g"
	SetVariable PeakIntgInt, pos={5, 520}, size={280, 16}, title="Peak Integral Intensity:", help={"peak integral inetnsity"}

	Button Recalculate, pos={16, 545}, size={100, 20}, proc=IR2D_InputPanelButtonProc, title="Recalculate", help={"Recalculate model data"}
	Button CopyToNbk, pos={16, 570}, size={100, 20}, proc=IR2D_InputPanelButtonProc, title="Paste to Notebook", help={"Recalculate model data"}

	PopupMenu EnforceGeometry, title="Structure?", proc=IR2D_PanelPopupControl, pos={130, 545}
	PopupMenu EnforceGeometry, value=root:packages:Irena_SAD:ListOfKnownPeakRelationships, mode=whichListItem(root:Packages:Irena_SAD:PeakRelationship, root:Packages:Irena_SAD:ListOfKnownPeakRelationships) + 1
	PopupMenu EnforceGeometry, help={"Select structure to present peak d-spacing relationships"}

	Button AppendResultsToGraph, pos={130, 570}, size={100, 20}, proc=IR2D_InputPanelButtonProc, title="Add tags to graph", help={"Append results to graphs"}
	Button RemoveResultsFromGraph, pos={130, 595}, size={100, 20}, proc=IR2D_InputPanelButtonProc, title="Remove tags", help={"Append results to graphs"}
	Button Fit, pos={250, 570}, size={100, 20}, proc=IR2D_InputPanelButtonProc, title="Fit", help={"Fit model data"}
	Button ResetFit, pos={250, 595}, size={100, 20}, proc=IR2D_InputPanelButtonProc, title="Revert back", help={"Fit model data"}
	Button SaveDataInFoldr, pos={16, 595}, size={100, 20}, proc=IR2D_InputPanelButtonProc, title="Store In Fldr", help={"Copy model data to original folder"}

	CheckBox AppendResiduals, pos={10, 620}, size={100, 14}, proc=IR2D_InputPanelCheckboxProc2, title="Display Residuals?"
	CheckBox AppendResiduals, variable=root:packages:Irena_SAD:AppendResiduals, help={"Check, if you want to display residuals in the graph"}
	CheckBox AppendNormalizedResiduals, pos={120, 620}, size={141, 14}, proc=IR2D_InputPanelCheckboxProc2, title="Display Norm. Residuals?"
	CheckBox AppendNormalizedResiduals, variable=root:packages:Irena_SAD:AppendNormalizedResiduals, help={"Check, if you want to display normalized residuals in the graph"}
	CheckBox UseGeneticOptimization, pos={270, 620}, size={80, 16}, noproc, title="Use genetic opt?", fstyle=1
	CheckBox UseGeneticOptimization, variable=root:Packages:Irena_SAD:UseGeneticOptimization, help={"Usze genetic optimization (uncheck to use LSQF)?"}
	//scaling info code

	//	TitleBox MainTitle,userdata(ResizeControlsInfo)= A"!!,BYz!!#Bn!!#=#z!!#`-A7TLfzzzzzzzzzzzzzz!!#`-A7TLfzz"
	//	TitleBox MainTitle,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	TitleBox MainTitle,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	TitleBox FakeLine1,userdata(ResizeControlsInfo)= A"!!,B9!!#AR!!#B_!!#8Lz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	TitleBox FakeLine1,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	TitleBox FakeLine1,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	TitleBox Info1,userdata(ResizeControlsInfo)= A"!!,A.!!#=c!!#?Y!!#<Xz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	TitleBox Info1,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	TitleBox Info1,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	TitleBox Info2,userdata(ResizeControlsInfo)= A"!!,A.!!#AW!!#A%!!#<Xz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	TitleBox Info2,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	TitleBox Info2,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	TitleBox Info3,userdata(ResizeControlsInfo)= A"!!,GX!!#BFJ,hqP!!#;mz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	TitleBox Info3,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	TitleBox Info3,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox UseSMRData,userdata(ResizeControlsInfo)= A"!!,G:!!#>:!!#?1!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox UseSMRData,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox UseSMRData,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	SetVariable SlitLength,userdata(ResizeControlsInfo)= A"!!,H=!!#>:!!#@,!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable SlitLength,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable SlitLength,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	Button DrawGraphs,userdata(ResizeControlsInfo)= A"!!,Do!!#A9!!#@,!!#<Xz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	Button DrawGraphs,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	Button DrawGraphs,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	CheckBox UseLogX,userdata(ResizeControlsInfo)= A"!!,H5!!#A1!!#?I!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox UseLogX,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox UseLogX,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	CheckBox UseLogY,userdata(ResizeControlsInfo)= A"!!,H5!!#AA!!#?I!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox UseLogY,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox UseLogY,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	CheckBox AutoRecalculate,userdata(ResizeControlsInfo)= A"!!,G&!!#AW!!#@$!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox AutoRecalculate,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox AutoRecalculate,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox PeakSASScaling,userdata(ResizeControlsInfo)= A"!!,G&!!#Ah!!#?Y!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox PeakSASScaling,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox PeakSASScaling,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	CheckBox DisplayPeaks,userdata(ResizeControlsInfo)= A"!!,H5!!#AW!!#?]!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox DisplayPeaks,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox DisplayPeaks,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox Oversample,userdata(ResizeControlsInfo)= A"!!,H5!!#Ah!!#@6!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox Oversample,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox Oversample,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	TabControl DataTabs,userdata(ResizeControlsInfo)= A"!!,=b!!#B(!!#C#!!#Bgz!!#](Aon#pBE/#4zzzzzzzzzzzzz!!#o2B4uAeBE/#4z"
	//	TabControl DataTabs,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	TabControl DataTabs,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable RgPrefactor,userdata(ResizeControlsInfo)= A"!!,An!!#BQ!!#AC!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable RgPrefactor,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable RgPrefactor,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox FitRgPrefactor,userdata(ResizeControlsInfo)= A"!!,GX!!#BR!!#<X!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox FitRgPrefactor,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox FitRgPrefactor,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	SetVariable RgPrefactorLowLimit,userdata(ResizeControlsInfo)= A"!!,H!!!#BQ!!#?)!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable RgPrefactorLowLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable RgPrefactorLowLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable RgPrefactorHighLimit,userdata(ResizeControlsInfo)= A"!!,HQ!!#BQ!!#?)!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable RgPrefactorHighLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable RgPrefactorHighLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable Rg,userdata(ResizeControlsInfo)= A"!!,An!!#B\\!!#AC!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable Rg,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Rg,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox FitRg,userdata(ResizeControlsInfo)= A"!!,GX!!#B\\J,hm.!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox FitRg,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox FitRg,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	SetVariable RgLowLimit,userdata(ResizeControlsInfo)= A"!!,H!!!#B\\!!#?)!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable RgLowLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable RgLowLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable RgHighLimit,userdata(ResizeControlsInfo)= A"!!,HQ!!#B\\!!#?)!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable RgHighLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable RgHighLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable PwrLawPref,userdata(ResizeControlsInfo)= A"!!,An!!#Bg!!#AC!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable PwrLawPref,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable PwrLawPref,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox FitPwrLawPref,userdata(ResizeControlsInfo)= A"!!,GX!!#BgJ,hm.!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox FitPwrLawPref,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox FitPwrLawPref,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	SetVariable PwrLawPrefLowLimit,userdata(ResizeControlsInfo)= A"!!,H!!!#Bg!!#?)!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable PwrLawPrefLowLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable PwrLawPrefLowLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable PwrLawPrefHighLimit,userdata(ResizeControlsInfo)= A"!!,HQ!!#Bg!!#?)!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable PwrLawPrefHighLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable PwrLawPrefHighLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable PwrLawSlope,userdata(ResizeControlsInfo)= A"!!,An!!#BqJ,hqn!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable PwrLawSlope,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable PwrLawSlope,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox FitPwrLawSlope,userdata(ResizeControlsInfo)= A"!!,GX!!#Br!!#<X!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox FitPwrLawSlope,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox FitPwrLawSlope,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	SetVariable PwrLawSlopeLowLimit,userdata(ResizeControlsInfo)= A"!!,H!!!#BqJ,hoT!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable PwrLawSlopeLowLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable PwrLawSlopeLowLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable PwrLawSlopeHighLimit,userdata(ResizeControlsInfo)= A"!!,HQ!!#BqJ,hoT!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable PwrLawSlopeHighLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable PwrLawSlopeHighLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable Background,userdata(ResizeControlsInfo)= A"!!,An!!#C'J,hqn!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable Background,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Background,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO5fF8u:@zzzzzzzzzzzz!!!"
	//	CheckBox FitBackground,userdata(ResizeControlsInfo)= A"!!,GX!!#C(!!#<X!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox FitBackground,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox FitBackground,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	SetVariable BackgroundLowLimit,userdata(ResizeControlsInfo)= A"!!,H!!!#C'J,hoT!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable BackgroundLowLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable BackgroundLowLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable BackgroundHighLimit,userdata(ResizeControlsInfo)= A"!!,HQ!!#C'J,hoT!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable BackgroundHighLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable BackgroundHighLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox UseThePeak,userdata(ResizeControlsInfo)= A"!!,A.!!#B>J,hn]!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox UseThePeak,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox UseThePeak,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	PopupMenu PopSizeDistShape,userdata(ResizeControlsInfo)= A"!!,A.!!#BQ!!#@h!!#<pz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	PopupMenu PopSizeDistShape,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	PopupMenu PopSizeDistShape,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable Peak_Par1,userdata(ResizeControlsInfo)= A"!!,?X!!#Bg!!#AC!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable Peak_Par1,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Peak_Par1,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox FitPeak_Par1,userdata(ResizeControlsInfo)= A"!!,GX!!#Bg!!#<X!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox FitPeak_Par1,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox FitPeak_Par1,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	SetVariable Peak_Par1LowLimit,userdata(ResizeControlsInfo)= A"!!,H!!!#Bg!!#?)!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable Peak_Par1LowLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Peak_Par1LowLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable Peak_Par1HighLimit,userdata(ResizeControlsInfo)= A"!!,HQ!!#Bg!!#?)!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable Peak_Par1HighLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Peak_Par1HighLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable Peak_Par2,userdata(ResizeControlsInfo)= A"!!,?X!!#BqJ,hqn!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable Peak_Par2,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Peak_Par2,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox FitPeak_Par2,userdata(ResizeControlsInfo)= A"!!,GX!!#BqJ,hm.!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox FitPeak_Par2,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox FitPeak_Par2,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	SetVariable Peak_Par2LowLimit,userdata(ResizeControlsInfo)= A"!!,H!!!#BqJ,hoT!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable Peak_Par2LowLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Peak_Par2LowLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable Peak_Par2HighLimit,userdata(ResizeControlsInfo)= A"!!,HQ!!#BqJ,hoT!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable Peak_Par2HighLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Peak_Par2HighLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable Peak_Par3,userdata(ResizeControlsInfo)= A"!!,?X!!#C'J,hqn!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!#r+D.OhkBk2=!z"
	//	SetVariable Peak_Par3,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Peak_Par3,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox FitPeak_Par3,userdata(ResizeControlsInfo)= A"!!,GX!!#C'J,hm.!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox FitPeak_Par3,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox FitPeak_Par3,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	SetVariable Peak_Par3LowLimit,userdata(ResizeControlsInfo)= A"!!,H!!!#C'J,hoT!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable Peak_Par3LowLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Peak_Par3LowLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable Peak_Par3HighLimit,userdata(ResizeControlsInfo)= A"!!,HQ!!#C'J,hoT!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable Peak_Par3HighLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Peak_Par3HighLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable Peak_Par4,userdata(ResizeControlsInfo)= A"!!,?X!!#C2J,hqn!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable Peak_Par4,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Peak_Par4,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox FitPeak_Par4,userdata(ResizeControlsInfo)= A"!!,GX!!#C2J,hp/!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox FitPeak_Par4,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox FitPeak_Par4,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	SetVariable Peak_Par4LowLimit,userdata(ResizeControlsInfo)= A"!!,H!!!#C2J,hoT!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable Peak_Par4LowLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Peak_Par4LowLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable Peak_Par4HighLimit,userdata(ResizeControlsInfo)= A"!!,HQ!!#C2J,hoT!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable Peak_Par4HighLimit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Peak_Par4HighLimit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox Peak_LinkPar2,userdata(ResizeControlsInfo)= A"!!,A.!!#CBJ,hqQ!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox Peak_LinkPar2,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox Peak_LinkPar2,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	PopupMenu Peak_LinkedTo,userdata(ResizeControlsInfo)= A"!!,A.!!#CMJ,hpI!!#<pz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	PopupMenu Peak_LinkedTo,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	PopupMenu Peak_LinkedTo,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable Peak_LinkMultiplier,userdata(ResizeControlsInfo)= A"!!,GX!!#CO!!#@f!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable Peak_LinkMultiplier,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable Peak_LinkMultiplier,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	SetVariable PeakDPosition,userdata(ResizeControlsInfo)= A"!!,?X!!#C]J,hrq!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable PeakDPosition,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable PeakDPosition,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	SetVariable PeakPosition,userdata(ResizeControlsInfo)= A"!!,?X!!#Cf^]6`\\!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable PeakPosition,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable PeakPosition,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	SetVariable PeakFWHM,userdata(ResizeControlsInfo)= A"!!,?X!!#Cl!!#BF!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable PeakFWHM,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable PeakFWHM,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	SetVariable PeakIntgInt,userdata(ResizeControlsInfo)= A"!!,?X!!#CqJ,hrq!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	SetVariable PeakIntgInt,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	SetVariable PeakIntgInt,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	Button Recalculate,userdata(ResizeControlsInfo)= A"!!,B9!!#D#5QF-l!!#<Xz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	Button Recalculate,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	Button Recalculate,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	Button CopyToNbk,userdata(ResizeControlsInfo)= A"!!,B9!!#D*!!#@,!!#<Xz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	Button CopyToNbk,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	Button CopyToNbk,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	PopupMenu EnforceGeometry,userdata(ResizeControlsInfo)= A"!!,Fg!!#D#5QF-n!!#<pz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	PopupMenu EnforceGeometry,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	PopupMenu EnforceGeometry,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	Button AppendResultsToGraph,userdata(ResizeControlsInfo)= A"!!,Fg!!#D*!!#@,!!#<Xz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE3-fz"
	//	Button AppendResultsToGraph,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	Button AppendResultsToGraph,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	Button RemoveResultsFromGraph,userdata(ResizeControlsInfo)= A"!!,Fg!!#D0^]6^B!!#<Xz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	Button RemoveResultsFromGraph,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	Button RemoveResultsFromGraph,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO5fF8u:@zzzzzzzzzzzz!!!"
	//	Button Fit,userdata(ResizeControlsInfo)= A"!!,H5!!#D*!!#@,!!#<Xz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	Button Fit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	Button Fit,userdata(ResizeControlsInfo) += A"zzz!!#r+D.Oh\\ASGdjF8u:@zzzzzzzzzzzz!!!"
	//	Button ResetFit,userdata(ResizeControlsInfo)= A"!!,H5!!#D0^]6^B!!#<Xz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	Button ResetFit,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	Button ResetFit,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	Button SaveDataInFoldr,userdata(ResizeControlsInfo)= A"!!,B9!!#D0^]6^B!!#<Xz!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	Button SaveDataInFoldr,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	Button SaveDataInFoldr,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox AppendResiduals,userdata(ResizeControlsInfo)= A"!!,A.!!#D7J,hp_!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox AppendResiduals,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox AppendResiduals,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox AppendNormalizedResiduals,userdata(ResizeControlsInfo)= A"!!,FU!!#D7J,hqB!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox AppendNormalizedResiduals,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox AppendNormalizedResiduals,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	CheckBox UseGeneticOptimization,userdata(ResizeControlsInfo)= A"!!,HB!!#D7J,hpQ!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	CheckBox UseGeneticOptimization,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	CheckBox UseGeneticOptimization,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	Button ScrollButtonUp,userdata(ResizeControlsInfo)= A"!!,HtJ,hh7!!#<(!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	Button ScrollButtonUp,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	Button ScrollButtonUp,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//	Button ScrollButtonDown,userdata(ResizeControlsInfo)= A"!!,HtJ,hls!!#<(!!#<8z!!\";f=(u2eBE/#4zzzzzzzzzzzzz!!\";f=(u2eBE/#4z"
	//	Button ScrollButtonDown,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzz!!\";f87cLJBQO4Szzzzzzzzzz"
	//	Button ScrollButtonDown,userdata(ResizeControlsInfo) += A"zzz!!\";f87cLJBQO4Szzzzzzzzzzzzz!!!"
	//
	//	SetWindow kwTopWin,hook(ResizeControls)=ResizeControls#ResizeControlsHook
	//	SetWindow kwTopWin,userdata(ResizeControlsInfo)= A"!!*'\"z!!#C'!!#D?zzzzzzzzzzzzzzzzzzzzz"
	//	SetWindow kwTopWin,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzzzzzzzz"
	//	SetWindow kwTopWin,userdata(ResizeControlsInfo) += A"zzzzzzzzzzzzzzzzzzz!!!"
	IR2D_TabPanelControl("", 0)
	//	IR1_PanelAppendSizeRecordNote()
	//	SetWindow kwTopWin,hook(ResizeFontControls)=IR1_PanelResizeFontSize

EndMacro

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//Function IR2D_PopSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
//	String ctrlName
//	Variable varNum
//	String varStr
//	String varName
//
//	DFref oldDf= GetDataFolderDFR()

//	setDataFolder root:Packages:Irena_SAD
//	variable whichDataSet
//	//BackgStep_set
//	ControlInfo/W=IR2D_ControlPanel DataTabs
//	whichDataSet= V_Value+1
//
//	IR2D_CalculateIntensity(0)
//
//	setDataFolder OldDf
//end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_ModelTabCheckboxProc(ctrlName, checked) : CheckBoxControl
	string   ctrlName
	variable checked

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD

	ControlInfo/W=IR2D_ControlPanel DataTabs
	variable WhichPeakSet = V_Value + 1

	//	if (stringMatch(ctrlName,"UseThePeak"))
	IR2D_TabPanelControl("", WhichPeakSet - 1)
	IR2D_CalculateIntensity(0)
	//	endif

	setDataFolder OldDf
End
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_PanelPopupControl(ctrlName, popNum, popStr) : PopupMenuControl
	string   ctrlName
	variable popNum
	string   popStr

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD
	if(stringmatch(ctrlName, "PopSizeDistShape"))
		ControlInfo/W=IR2D_ControlPanel DataTabs
		SVAR PeakFunction = $("root:Packages:Irena_SAD:Peak" + num2str(V_Value) + "_Function")
		PeakFunction = popStr
		IR2D_CalculateIntensity(0)
		IR2D_TabPanelControl("", V_Value)
	endif

	if(stringmatch(ctrlName, "Peak_LinkedTo"))
		ControlInfo/W=IR2D_ControlPanel DataTabs
		SVAR Peak_LinkedTo = $("root:Packages:Irena_SAD:Peak" + num2str(V_Value) + "_LinkedTo")
		Peak_LinkedTo = popStr
		IR2D_CalculateIntensity(0)
		IR2D_TabPanelControl("", V_Value)
	endif
	if(stringmatch(ctrlName, "EnforceGeometry"))
		ControlInfo/W=IR2D_ControlPanel DataTabs
		SVAR PeakRelationship
		PeakRelationship = popStr
		IR2D_SetStructure()
		//	string/g ListOfKnownPeakRelationships	="---;Lamellar;HCP cylinders;Primitive Simple cubic;BCC;FCC;HCP spheres;Doube Diamond;1a-3d;Pm-3n;"

		IR2D_CalculateIntensity(0)
		IR2D_TabPanelControl("", V_Value)
	endif

	setDataFolder OldDf

End
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_SetStructure()
	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD
	SVAR     PeakRelationship
	variable i
	NVAR UsePeak1 = UsePeak1
	usePeak1 = 1
	SVAR LinkPk1 = Peak1_linkedTo
	LinkPk1 = "---"
	NVAR LinkOn = Peak1_LinkPar2
	LinkOn = 0
	for(i = 2; i <= 6; i += 1)
		NVAR usePop = $("UsePeak" + num2str(i))
		usePop = 1
		SVAR linkPk = $("Peak" + num2str(i) + "_LinkedTo")
		linkPk = "Peak1"
		NVAR LinkOn = $("Peak" + num2str(i) + "_LinkPar2")
		LinkOn = 1
	endfor
	//and now the ratios...
	NVAR Pk1M = root:Packages:Irena_SAD:Peak1_LinkMultiplier
	NVAR Pk2M = root:Packages:Irena_SAD:Peak2_LinkMultiplier
	NVAR Pk3M = root:Packages:Irena_SAD:Peak3_LinkMultiplier
	NVAR Pk4M = root:Packages:Irena_SAD:Peak4_LinkMultiplier
	NVAR Pk5M = root:Packages:Irena_SAD:Peak5_LinkMultiplier
	NVAR Pk6M = root:Packages:Irena_SAD:Peak6_LinkMultiplier
	if(stringmatch(PeakRelationship, "Lamellar"))
		// Lamellar  1: 2 : 3 : 4 : 5 : 6 : 7
		Pk1M = 1 * (1)
		Pk2M = 1 * (2)
		Pk3M = 1 * (3)
		Pk4M = 1 * (4)
		Pk5M = 1 * (5)
		Pk6M = 1 * (6)
	elseif(stringmatch(PeakRelationship, "HCP cylinders"))
		// Hexagonally packed cylinders 1 : sqrt(3) : 2 : sqrt(7) : 3 : sqrt(12) : sqrt(13) : 4
		Pk1M = 1 * (1)
		Pk2M = 1 * (sqrt(3))
		Pk3M = 1 * (2)
		Pk4M = 1 * (sqrt(7))
		Pk5M = 1 * (3)
		Pk6M = 1 * (sqrt(12))
	elseif(stringmatch(PeakRelationship, "Simple cubic"))
		// Primitive (simple cubic) 1 : sqrt(2) : sqrt(3) : 2 : sqrt(5) : sqrt(6) :sqrt(8) : 3
		Pk1M = 1 * (1)
		Pk2M = 1 * (sqrt(2))
		Pk3M = 1 * (sqrt(3))
		Pk4M = 1 * (2)
		Pk5M = 1 * (sqrt(5))
		Pk6M = 1 * (sqrt(6))
	elseif(stringmatch(PeakRelationship, "BCC"))
		// BCC   1 : sqrt(2) : sqrt(3) : 2 : sqrt(5) : sqrt(6) : sqrt(7) : sqrt(8) : 3
		Pk1M = 1 * (1)
		Pk2M = 1 * (sqrt(2))
		Pk3M = 1 * (sqrt(3))
		Pk4M = 1 * (2)
		Pk5M = 1 * (sqrt(5))
		Pk6M = 1 * (sqrt(6))
	elseif(stringmatch(PeakRelationship, "FCC"))
		//FCC    sqrt(3) : 2 : sqrt(8) : sqrt (11) : sqrt(12) : 4 : sqrt(19)
		Pk1M = 1 * (1)
		Pk2M = 1 * (2 / sqrt(3))
		Pk3M = 1 * (sqrt(8) / sqrt(3))
		Pk4M = 1 * (sqrt(11) / sqrt(3))
		Pk5M = 1 * (sqrt(12) / sqrt(3))
		Pk6M = 1 * (4 / sqrt(3))
	elseif(stringmatch(PeakRelationship, "HCP spheres"))
		// Hex close packed  sqrt(32) : 6 : sqrt(41) : sqrt(68) : sqrt(96) : sqrt(113)
		Pk1M = 1 * (1)
		Pk2M = 1 * (6 / sqrt(32))
		Pk3M = 1 * (sqrt(41) / sqrt(32))
		Pk4M = 1 * (sqrt(68) / sqrt(32))
		Pk5M = 1 * (sqrt(96) / sqrt(32))
		Pk6M = 1 * (sqrt(113) / sqrt(32))
	elseif(stringmatch(PeakRelationship, "Doube Diamond"))
		// double diamond   sqrt(2) : sqrt(3) : 2 : sqrt(6) :sqrt(8) : 3 : sqrt(10) : sqrt(11)
		Pk1M = 1 * (1)
		Pk2M = 1 * (sqrt(3) / sqrt(2))
		Pk3M = 1 * (2 / sqrt(2))
		Pk4M = 1 * (sqrt(6) / sqrt(2))
		Pk5M = 1 * (sqrt(8) / sqrt(2))
		Pk6M = 1 * (3 / sqrt(2))
	elseif(stringmatch(PeakRelationship, "1a-3d"))
		//Ialpha(-3)d		sqrt(3) : 2 : sqrt(7) :sqrt(8) : sqrt(10) : sqrt(11) : sqrt(12)
		Pk1M = 1 * (1)
		Pk2M = 1 * (2 / sqrt(3))
		Pk3M = 1 * (sqrt(7) / sqrt(3))
		Pk4M = 1 * (sqrt(10) / sqrt(3))
		Pk5M = 1 * (sqrt(11) / sqrt(3))
		Pk6M = 1 * (sqrt(12) / sqrt(3))
	elseif(stringmatch(PeakRelationship, "Pm-3n"))
		//Pm3m		sqrt(2) : 2 : sqrt(5) : sqrt(6) : sqrt(8) : sqrt(10) : sqrt(12)
		Pk1M = 1 * (1)
		Pk2M = 1 * (2 / sqrt(2))
		Pk3M = 1 * (sqrt(5) / sqrt(2))
		Pk4M = 1 * (sqrt(8) / sqrt(2))
		Pk5M = 1 * (sqrt(10) / sqrt(2))
		Pk6M = 1 * (sqrt(12) / sqrt(2))

	endif
	//	SVAR ListOfKnownPeakRelationships	="---;Lamellar;HCP cylinders;Primitive Simple cubic;BCC;FCC;HCP spheres;Doube Diamond;1a-3d;Pm-3n;"
	// from Block copolymers: synthetic strategies, Physical properties and applications, Hadjichrististidis, Pispas, Floudas, Willey & sons, 2003, chapter 19, pg 347

	setDataFolder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_TabPanelControl(name, tab)
	string   name
	variable tab

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD

	SetVariable RgPrefactor, disable=(tab != 0)
	CheckBox FitRgPrefactor, disable=(tab != 0)
	NVAR FitRgPrefactor = root:Packages:Irena_SAD:FitRgPrefactor
	SetVariable RgPrefactorLowLimit, disable=(tab != 0 || !FitRgPrefactor)
	SetVariable RgPrefactorHighLimit, disable=(tab != 0 || !FitRgPrefactor)

	SetVariable Rg, disable=(tab != 0)
	CheckBox FitRg, disable=(tab != 0)
	NVAR FitRg = root:Packages:Irena_SAD:FitRg
	SetVariable RgLowLimit, disable=(tab != 0 || !FitRg)
	SetVariable RgHighLimit, disable=(tab != 0 || !FitRg)

	SetVariable PwrLawPref, disable=(tab != 0)
	CheckBox FitPwrLawPref, disable=(tab != 0)
	NVAR FitPwrLawPref = root:Packages:Irena_SAD:FitPwrLawPref
	SetVariable PwrLawPrefLowLimit, disable=(tab != 0 || !FitPwrLawPref)
	SetVariable PwrLawPrefHighLimit, disable=(tab != 0 || !FitPwrLawPref)

	SetVariable PwrLawSlope, disable=(tab != 0)
	CheckBox FitPwrLawSlope, disable=(tab != 0)
	NVAR FitPwrLawSlope = root:Packages:Irena_SAD:FitPwrLawSlope
	SetVariable PwrLawSlopeLowLimit, disable=(tab != 0 || !FitPwrLawSlope)
	SetVariable PwrLawSlopeHighLimit, disable=(tab != 0 || !FitPwrLawSlope)

	SetVariable Background, disable=(tab != 0)
	CheckBox FitBackground, disable=(tab != 0)
	NVAR FitBackground = root:Packages:Irena_SAD:FitBackground
	SetVariable BackgroundLowLimit, disable=(tab != 0 || !FitBackground)
	SetVariable BackgroundHighLimit, disable=(tab != 0 || !FitBackground)

	CheckBox UseThePeak, disable=(tab == 0)
	SetVariable Peak_Par1, disable=(tab == 0)
	CheckBox FitPeak_Par1, disable=(tab == 0)
	SetVariable Peak_Par1LowLimit, disable=(tab == 0)
	SetVariable Peak_Par1HighLimit, disable=(tab == 0)
	SetVariable Peak_Par2, disable=(tab == 0)
	CheckBox FitPeak_Par2, disable=(tab == 0)
	SetVariable Peak_Par2LowLimit, disable=(tab == 0)
	SetVariable Peak_Par2HighLimit, disable=(tab == 0)
	SetVariable Peak_Par3, disable=(tab == 0)
	CheckBox FitPeak_Par3, disable=(tab == 0)
	SetVariable Peak_Par3LowLimit, disable=(tab == 0)
	SetVariable Peak_Par3HighLimit, disable=(tab == 0)
	SetVariable Peak_Par4, disable=(tab == 0)
	CheckBox FitPeak_Par4, disable=(tab == 0)
	SetVariable Peak_Par4LowLimit, disable=(tab == 0)
	SetVariable Peak_Par4HighLimit, disable=(tab == 0)
	PopupMenu PopSizeDistShape, disable=(tab == 0)

	CheckBox Peak_LinkPar2, disable=(tab == 0)
	PopupMenu Peak_LinkedTo, disable=(tab == 0)
	SetVariable Peak_LinkMultiplier, disable=(tab == 0)

	SetVariable PeakDPosition, disable=(tab == 0)
	SetVariable PeakPosition, disable=(tab == 0)
	SetVariable PeakFWHM, disable=(tab == 0)
	SetVariable PeakIntgInt, disable=(tab == 0)

	if(tab > 0)
		SVAR     ListOfKnownPeakShapes = root:packages:Irena_SAD:ListOfKnownPeakShapes
		SVAR     CurDistType           = $("root:Packages:Irena_SAD:Peak" + num2str(tab) + "_Function")
		NVAR     PP2                   = $("root:Packages:Irena_SAD:Peak" + num2str(tab) + "_LinkPar2")
		variable Display4              = 0
		if(stringmatch(CurDistType, "Pseudo-Voigt") || stringmatch(CurDistType, "Pearson_VII") || stringmatch(CurDistType, "Modif_Gauss") || stringmatch(CurDistType, "SkewedNormal"))
			Display4 = 1
		endif
		PopupMenu PopSizeDistShape, win=IR2D_ControlPanel, mode=whichListItem(CurDistType, ListOfKnownPeakShapes) + 1
		NVAR UsePeak = $("root:Packages:Irena_SAD:UsePeak" + num2str(tab))
		NVAR Fit1    = $("root:Packages:Irena_SAD:FitPeak" + num2str(tab) + "_Par1")
		CheckBox UseThePeak, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("UsePeak" + num2str(tab))
		SetVariable Peak_Par1, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_Par1"), disable=(!(UsePeak))
		CheckBox FitPeak_Par1, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("FitPeak" + num2str(tab) + "_Par1"), disable=(!(UsePeak))
		SetVariable Peak_Par1LowLimit, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_Par1LowLimit"), disable=!((UsePeak) && (Fit1))
		SetVariable Peak_Par1HighLimit, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_Par1HighLimit"), disable=!((UsePeak) && (Fit1))

		NVAR Fit2 = $("root:Packages:Irena_SAD:FitPeak" + num2str(tab) + "_Par2")
		SetVariable Peak_Par2, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_Par2"), disable=(!(UsePeak))
		if(PP2)
			SetVariable Peak_Par2, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_Par2"), disable=2
		endif
		CheckBox FitPeak_Par2, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("FitPeak" + num2str(tab) + "_Par2"), disable=(!UsePeak || PP2)
		SetVariable Peak_Par2LowLimit, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_Par2LowLimit"), disable=!((UsePeak && Fit2)) || PP2
		SetVariable Peak_Par2HighLimit, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_Par2HighLimit"), disable=!((UsePeak && Fit2)) || PP2

		NVAR Fit3 = $("root:Packages:Irena_SAD:FitPeak" + num2str(tab) + "_Par3")
		SetVariable Peak_Par3, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_Par3"), disable=(!(UsePeak))
		CheckBox FitPeak_Par3, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("FitPeak" + num2str(tab) + "_Par3"), disable=(!(UsePeak))
		SetVariable Peak_Par3LowLimit, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_Par3LowLimit"), disable=!(UsePeak && Fit3)
		SetVariable Peak_Par3HighLimit, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_Par3HighLimit"), disable=!(UsePeak && Fit3)

		NVAR Fit4 = $("root:Packages:Irena_SAD:FitPeak" + num2str(tab) + "_Par4")
		SetVariable Peak_Par4, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_Par4"), disable=!(UsePeak && Display4)
		CheckBox FitPeak_Par4, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("FitPeak" + num2str(tab) + "_Par4"), disable=!(UsePeak && Display4)
		SetVariable Peak_Par4LowLimit, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_Par4LowLimit"), disable=!(UsePeak && Display4 && Fit4)
		SetVariable Peak_Par4HighLimit, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_Par4HighLimit"), disable=!(UsePeak && Display4 && Fit4)

		SetVariable Peak_Par2, win=IR2D_ControlPanel, title="Position       "
		SetVariable Peak_Par3, win=IR2D_ControlPanel, title="Width     "
		SVAR PeakFunction = $("root:Packages:Irena_SAD:Peak" + num2str(tab) + "_Function")
		NVAR value4       = $("root:Packages:Irena_SAD:Peak" + num2str(tab) + "_Par4")
		if(stringmatch(PeakFunction, "SkewedNormal"))
			SetVariable Peak_Par4, limits={-Inf, Inf, (0.03 * value4)}
			SetVariable Peak_Par4LowLimit, limits={-Inf, Inf, 0}
			SetVariable Peak_Par4HighLimit, limits={-Inf, Inf, 0}
		else
			SetVariable Peak_Par4, limits={0, Inf, (0.03 * value4)}
			SetVariable Peak_Par4LowLimit, limits={0, Inf, 0}
			SetVariable Peak_Par4HighLimit, limits={0, Inf, 0}
		endif

		if(stringmatch(CurDistType, "Pseudo-Voigt"))
			SetVariable Peak_Par4, win=IR2D_ControlPanel, title="ETA (Pseudo-Voigt)"
		elseif(stringmatch(CurDistType, "Pearson_VII"))
			SetVariable Peak_Par4, win=IR2D_ControlPanel, title="Tail Par"
		elseif(stringmatch(CurDistType, "Modif_Gauss"))
			SetVariable Peak_Par4, win=IR2D_ControlPanel, title="Tail Par"
		elseif(stringmatch(CurDistType, "SkewedNormal"))
			SetVariable Peak_Par4, win=IR2D_ControlPanel, title="Skewness"
		elseif(stringmatch(CurDistType, "Percus-Yevick-Sq") || stringmatch(CurDistType, "Percus-Yevick-SqFq"))
			//	SetVariable Peak_Par1 win=IR2D_ControlPanel,title=\"Skewness\"")
			SetVariable Peak_Par2, win=IR2D_ControlPanel, title="Radius       "
			SetVariable Peak_Par3, win=IR2D_ControlPanel, title="Fraction    "
		endif

		CheckBox Peak_LinkPar2, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_LinkPar2"), disable=!(UsePeak)

		string MenuVal = "---;Peak1;Peak2;Peak3;Peak4;Peak5;Peak6;"
		MenuVal = ReplaceString("Peak" + num2str(tab) + ";", MenuVal, "")
		SVAR testStr = $("root:Packages:Irena_SAD:Peak" + num2str(tab) + "_LinkedTo")
		PopupMenu Peak_LinkedTo, value=#("\"" + MenuVal + "\""), mode=(whichListItem(testStr, MenuVal) + 1)

		PopupMenu Peak_LinkedTo, win=IR2D_ControlPanel, disable=!((UsePeak) && (PP2))
		SetVariable Peak_LinkMultiplier, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("Peak" + num2str(tab) + "_LinkMultiplier"), disable=!((UsePeak) && (PP2))

		SetVariable PeakDPosition, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("PeakDPosition" + num2str(tab)), disable=2
		SetVariable PeakPosition, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("PeakPosition" + num2str(tab)), disable=2
		SetVariable PeakFWHM, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("PeakFWHM" + num2str(tab)), disable=2
		SetVariable PeakIntgInt, win=IR2D_ControlPanel, variable=root:Packages:Irena_SAD:$("PeakIntgInt" + num2str(tab)), disable=2

	endif
	setDataFolder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_InputPanelButtonProc(ctrlName) : ButtonControl
	string ctrlName

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD

	if(cmpstr(ctrlName, "GetHelp") == 0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Irena/SmallAngleDiffraction.html")
	endif
	if(cmpstr(ctrlName, "DrawGraphs") == 0 || cmpstr(ctrlName, "DrawGraphsSkipDialogs") == 0)
		//here goes what is done, when user pushes Graph button
		SVAR     DFloc         = root:Packages:Irena_SAD:DataFolderName
		SVAR     DFInt         = root:Packages:Irena_SAD:IntensityWaveName
		SVAR     DFQ           = root:Packages:Irena_SAD:QWaveName
		SVAR     DFE           = root:Packages:Irena_SAD:ErrorWaveName
		variable IsAllAllRight = 1
		if(cmpstr(DFloc, "---") == 0)
			IsAllAllRight = 0
		endif
		if(cmpstr(DFInt, "---") == 0)
			IsAllAllRight = 0
		endif
		if(cmpstr(DFQ, "---") == 0)
			IsAllAllRight = 0
		endif
		if(cmpstr(DFE, "---") == 0)
			IsAllAllRight = 0
		endif

		if(IsAllAllRight)
			if(cmpstr(ctrlName, "DrawGraphsSkipDialogs") != 0)
				//				variable recovered = IR1A_RecoverOldParameters()	//recovers old parameters and returns 1 if done so...
			endif
			IR2D_GraphMeasuredData()
			IR2D_RecoverOldParameters()
		else
			Abort "Data not selected properly"
		endif
	endif
	if(cmpstr(ctrlName, "Recalculate") == 0)
		IR2D_CalculateIntensity(1)
	endif
	if(cmpstr(ctrlName, "Fit") == 0)
		IR2D_Fitting()
	endif
	if(cmpstr(ctrlName, "ResetFit") == 0)
		IR2D_ResetParamsAfterBadFit()
	endif
	if(cmpstr(ctrlName, "AppendResultsToGraph") == 0)
		IR2D_AppendTagsToGraph()
	endif
	if(cmpstr(ctrlName, "RemoveResultsFromGraph") == 0)
		IR2D_RemoveTagsFromGraph()
	endif
	if(cmpstr(ctrlName, "SaveDataInFoldr") == 0)
		IR2D_SaveResultsToFolder()
	endif
	if(cmpstr(ctrlName, "CopyToNbk") == 0)
		IR2D_SaveResultsToNotebook()
	endif

	setDataFolder OldDf
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR2D_SaveResultsToNotebook()

	IR1_CreateResultsNbk()

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD
	SVAR DataFolderName    = root:Packages:Irena_SAD:DataFolderName
	SVAR IntensityWaveName = root:Packages:Irena_SAD:IntensityWaveName
	SVAR QWavename         = root:Packages:Irena_SAD:QWavename
	SVAR ErrorWaveName     = root:Packages:Irena_SAD:ErrorWaveName
	IR1_AppendAnyText("\r Results of Small-angle diffraction fitting\r", 1)
	IR1_AppendAnyText("Date & time: \t" + Date() + "   " + time(), 0)
	IR1_AppendAnyText("Data from folder: \t" + DataFolderName, 0)
	IR1_AppendAnyText("Intensity: \t" + IntensityWaveName, 0)
	IR1_AppendAnyText("Q: \t" + QWavename, 0)
	IR1_AppendAnyText("Error: \t" + ErrorWaveName, 0)
	//	IR1_AppendAnyText("Method used: \t"+MethodRun,0)

	IR1_AppendAnyGraph("IR2D_LogLogPlotSAD")
	//save data here... For Moore include "Fittingresults" which is Intensity Fit stuff
	//	SVAR FittingResults = root:Packages:Irena_PDDF:FittingResults
	string FittingResults = ""
	NVAR   background     = root:Packages:Irena_SAD:Background
	NVAR   PwrlawPref     = root:Packages:Irena_SAD:PwrLawPref
	NVAR   PwrLawSlope    = root:Packages:Irena_SAD:PwrLawSlope
	NVAR   RgPref         = root:Packages:Irena_SAD:RgPrefactor
	NVAR   Rg             = root:Packages:Irena_SAD:Rg
	if(Rg < 10000)
		FittingResults  = "Guinier area parameters \r"
		FittingResults += "Rg = " + num2str(Rg) + "   prefactor = " + num2str(RgPref) + "\r"
	endif
	FittingResults += " Power law slope = " + num2str(PwrLawSlope) + "   Prefactor = " + num2str(PwrlawPref) + "\r"
	FittingResults += " Bacground = " + num2str(background) + " \r\r"
	variable i
	for(i = 1; i <= 6; i += 1)
		NVAR UsePeak = $("root:Packages:Irena_SAD:UsePeak" + num2str(i))
		if(UsePeak)
			NVAR PeakDpos    = $("root:Packages:Irena_SAD:PeakDPosition" + num2str(i))
			NVAR PeakFWHM    = $("root:Packages:Irena_SAD:PeakFWHM" + num2str(i))
			NVAR PeakIntgInt = $("root:Packages:Irena_SAD:PeakIntgInt" + num2str(i))
			NVAR PeakPos     = $("root:Packages:Irena_SAD:PeakPosition" + num2str(i))
			FittingResults += "Peak number " + num2str(i) + " used \r"
			FittingResults += "Peak position (Q units) = " + num2str(PeakPos) + "  [A^-1]   , D units = " + num2str(PeakDpos) + " [A] \r"
			FittingResults += "Peak FWHM (Q units) = " + num2str(PeakFWHM) + " [A^-1] \r"
			FittingResults += "Peak Integral intensity = " + num2str(PeakIntgInt) + "\r\r"
		endif
	endfor
	IR1_AppendAnyText(FittingResults, 0)
	IR1_AppendAnyText("******************************************\r", 0)
	SetDataFolder OldDf
	SVAR/Z nbl = root:Packages:Irena:ResultsNotebookName
	DoWindow/F $nbl

End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_RecoverOldParameters()

	DFREF oldDf = GetDataFolderDFR()

	SVAR DataFolderName = root:Packages:Irena_SAD:DataFolderName
	SetDataFolder DataFolderName
	variable DataExists = 0, i
	string ListOfWaves = IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
	string tempString
	if(stringmatch(ListOfWaves, "*SADModelIntensity*"))
		string ListOfSolutions = "start from current state;"
		for(i = 0; i < itemsInList(ListOfWaves); i += 1)
			if(stringmatch(stringFromList(i, ListOfWaves), "*SADModelIntensity*"))
				tempString = stringFromList(i, ListOfWaves)
				WAVE tempwv = $(DataFolderName + tempString)
				tempString       = stringByKey("UsersComment", note(tempwv), "=")
				ListOfSolutions += stringFromList(i, ListOfWaves) + "*  " + tempString + ";"
			endif
		endfor
		DataExists = 1
		string ReturnSolution = ""
		Prompt ReturnSolution, "Select solution to recover", popup, ListOfSolutions
		DoPrompt "Previous solutions found, select one to recover", ReturnSolution
		if(V_Flag)
			abort
		endif
		if(cmpstr("start from current state", ReturnSolution) == 0)
			DataExists = 0
		endif
	endif

	setDataFolder root:Packages:Irena_SAD
	if(DataExists == 1)
		ReturnSolution = ReturnSolution[0, strsearch(ReturnSolution, "*", 0) - 1]
		WAVE/Z OldDistribution = $(DataFolderName + ReturnSolution)

		string OldNote            = note(OldDistribution)
		SVAR   ListOfVariables    = root:Packages:Irena_SAD:ListOfVariables
		SVAR   ListOfStrings      = root:Packages:Irena_SAD:ListOfStrings
		string LocalListOFStrings = ReplaceString("DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;ListOfKnownPeakShapes;", ListOfStrings, "")

		for(i = 0; i < ItemsInList(ListOfVariables); i += 1)
			NVAR tmp = $(StringFromList(i, ListOfVariables))
			tmp = NumberByKey(StringFromList(i, ListOfVariables), OldNote, "=", ";")
		endfor
		for(i = 0; i < ItemsInList(LocalListOFStrings); i += 1)
			SVAR tmpS = $(StringFromList(i, LocalListOFStrings))
			tmpS = StringByKey(StringFromList(i, LocalListOFStrings), OldNote, "=", ";")
		endfor
	endif
	setDataFolder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_SaveResultsToFolder()

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD

	SVAR/Z ListOfVariables = root:Packages:Irena_SAD:ListOfVariables
	SVAR/Z ListOfStrings   = root:Packages:Irena_SAD:ListOfStrings
	if(!SVAR_Exists(ListOfVariables) || !SVAR_Exists(ListOfStrings))
		abort "Error in parameters in IR2D_SaveResultsToFolder routine. Send the file to author for bug fix, please"
	endif

	variable i, j

	//and here we store them in the List to use in the wave note...
	string ListOfParameters = ""
	for(i = 0; i < itemsInList(ListOfVariables); i += 1)
		NVAR testVar = $(StringFromList(i, ListOfVariables))
		ListOfParameters += StringFromList(i, ListOfVariables) + "=" + num2str(testVar) + ";"
	endfor
	for(i = 0; i < itemsInList(ListOfStrings); i += 1)
		SVAR testStr = $(StringFromList(i, ListOfStrings))
		ListOfParameters += StringFromList(i, ListOfStrings) + "=" + testStr + ";"
	endfor
	//

	SVAR DataFolderName = root:Packages:Irena_SAD:DataFolderName

	WAVE/Z Intensity = root:Packages:Irena_SAD:ModelIntensity
	WAVE/Z Qvector   = root:Packages:Irena_SAD:ModelQvector
	if(!WaveExists(Intensity) || !WaveExists(Qvector))
		setDataFolder OldDf
		abort "No data exist, aborted"
	endif

	string UsersComment, ExportSeparateDistributions
	UsersComment                = "Result from Small-angle difraction Modeling " + date() + "  " + time()
	ExportSeparateDistributions = "No"
	Prompt UsersComment, "Modify comment to be saved with these results"
	Prompt ExportSeparateDistributions, "Export separately populations data", popup, "No;Yes;"
	DoPrompt "Need input for saving data", UsersComment, ExportSeparateDistributions
	if(V_Flag)
		abort
	endif

	setDataFolder $(DataFolderName)
	string tempname
	variable ii = 0
	for(ii = 0; ii < 1000; ii += 1)
		tempname = "SADModelIntensity_" + num2str(ii)
		if(checkname(tempname, 1) == 0)
			break
		endif
	endfor

	Duplicate Intensity, $("SADModelIntensity_" + num2str(ii))
	Duplicate Qvector, $("SADModelQ_" + num2str(ii))

	WAVE MytempWave = $("SADModelIntensity_" + num2str(ii))
	tempname = "SADModelIntensity_" + num2str(ii)
	IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
	IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
	IN2G_AppendorReplaceWaveNote(tempname, "Units", "1/cm")
	note MytempWave, ListOfParameters
	Redimension/D MytempWave

	WAVE MytempWave = $("SADModelQ_" + num2str(ii))
	tempname = "SADModelQ_" + num2str(ii)
	IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
	IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
	IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
	IN2G_AppendorReplaceWaveNote(tempname, "Units", "1/A")
	note MytempWave, ListOfParameters
	Redimension/D MytempWave

	if(stringmatch(ExportSeparateDistributions, "Yes"))
		WAVE UnifiedIntensity = root:Packages:Irena_SAD:UnifiedIntensity
		WAVE UnifiedQvector   = root:Packages:Irena_SAD:UnifiedQvector
		Duplicate UnifiedIntensity, $("SADUnifiedIntensity_" + num2str(ii))
		Duplicate UnifiedQvector, $("SADUnifiedQvector_" + num2str(ii))
		for(i = 1; i <= 6; i += 1)
			WAVE/Z IntensityPeak = $("root:Packages:Irena_SAD:Peak" + num2str(i) + "Intensity")
			if(WaveExists(IntensityPeak))
				Duplicate IntensityPeak, $("SADModelIntPeak" + num2str(i) + "_" + num2str(ii))
				Duplicate Qvector, $("SADModelQPeak" + num2str(i) + "_" + num2str(ii))

				WAVE MytempWave = $("SADModelIntPeak" + num2str(i) + "_" + num2str(ii))
				tempname = "SADModelIntPeak" + num2str(i) + "_" + num2str(ii)
				IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
				IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
				IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
				IN2G_AppendorReplaceWaveNote(tempname, "Units", "1/cm")
				note MytempWave, ListOfParameters
				Redimension/D MytempWave
				WAVE MytempWave = $("SADModelQPeak" + num2str(i) + "_" + num2str(ii))
				tempname = "SADModelQPeak" + num2str(i) + "_" + num2str(ii)
				IN2G_AppendorReplaceWaveNote(tempname, "DataFrom", GetDataFolder(0))
				IN2G_AppendorReplaceWaveNote(tempname, "UsersComment", UsersComment)
				IN2G_AppendorReplaceWaveNote(tempname, "Wname", tempname)
				IN2G_AppendorReplaceWaveNote(tempname, "Units", "1/cm")
				note MytempWave, ListOfParameters
				Redimension/D MytempWave
			endif
		endfor
	endif

	setDataFolder OldDf
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_PanelSetVarProc(ctrlName, varNum, varStr, varName) : SetVariableControl
	string   ctrlName
	variable varNum
	string   varStr
	string   varName

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD
	ControlInfo/W=IR2D_ControlPanel DataTabs
	string whichTab = num2str(V_Value)
	if(stringMatch(ctrlName, "RgPrefactor"))
		if(varNum == 0)
			NVAR Rg = root:Packages:Irena_SAD:Rg
			Rg = 1e10
		endif
	endif

	//recalculate...
	IR2D_CalculateIntensity(0)
	//set step to
	if(V_Value > 0) //these are the tabs related to peaks
		SVAR PeakFunction = $("root:Packages:Irena_SAD:Peak" + whichTab + "_Function")
		if(stringmatch(PeakFunction, "SkewedNormal"))
			Execute("SetVariable " + ctrlName + ",limits={-inf,inf," + num2str(0.03 * varNum) + "}")
			Execute("SetVariable " + ctrlName + "LowLimit,limits={-inf,inf,0}")
			Execute("SetVariable " + ctrlName + "HighLimit,limits={-inf,inf,0}")
		else
			Execute("SetVariable " + ctrlName + ",limits={0,inf," + num2str(0.03 * varNum) + "}")
			Execute("SetVariable " + ctrlName + "LowLimit,limits={0,inf,0}")
			Execute("SetVariable " + ctrlName + "HighLimit,limits={0,inf,0}")
		endif
		//set limits
		if((!stringmatch(varName, "*par4*") && !stringmatch(varName, "*LinkMultiplier")) || (stringmatch(PeakFunction, "SkewedNormal"))) //no change in limtis for eta
			if(V_Value > 0) //need to insert the peak number in it...
				ctrlName = ctrlName[0, 3] + num2str(V_Value) + ctrlName[4, Inf]
			endif
			NVAR LowLimit = $("root:Packages:Irena_SAD:" + ctrlName + "LowLimit")
			LowLimit = 0.2 * varNum
			NVAR HighLimit = $("root:Packages:Irena_SAD:" + ctrlName + "HighLimit")
			HighLimit = 5 * varNum
		endif
	else //this is tab0 = Unified fit tab, need to set limits and steps...
		Execute("SetVariable " + ctrlName + ",limits={0,inf," + num2str(0.03 * varNum) + "}")
		Execute("SetVariable " + ctrlName + "LowLimit,limits={0,inf,0}")
		Execute("SetVariable " + ctrlName + "HighLimit,limits={0,inf,0}")
		NVAR LowLimit = $("root:Packages:Irena_SAD:" + ctrlName + "LowLimit")
		LowLimit = 0.2 * varNum
		NVAR HighLimit = $("root:Packages:Irena_SAD:" + ctrlName + "HighLimit")
		HighLimit = 5 * varNum
		if(stringmatch(ctrlName, "PwrLawSlope"))
			LowLimit  = 1
			HighLimit = 4.5
		endif

	endif
	setDataFolder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_InputPanelCheckboxProc(ctrlName, checked) : CheckBoxControl
	string   ctrlName
	variable checked

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD

	if(cmpstr(ctrlName, "UseSMRData") == 0)
		//here we control the data structure checkbox
		NVAR UseIndra2Data = root:Packages:Irena_SAD:UseIndra2Data
		NVAR UseQRSData    = root:Packages:Irena_SAD:UseQRSData
		NVAR UseSMRData    = root:Packages:Irena_SAD:UseSMRData
		SetVariable SlitLength, win=IR2D_ControlPanel, disable=!UseSMRData
		Checkbox UseIndra2Data, win=IR2D_ControlPanel, value=UseIndra2Data
		Checkbox UseQRSData, win=IR2D_ControlPanel, value=UseQRSData
		SVAR Dtf   = root:Packages:Irena_SAD:DataFolderName
		SVAR IntDf = root:Packages:Irena_SAD:IntensityWaveName
		SVAR QDf   = root:Packages:Irena_SAD:QWaveName
		SVAR EDf   = root:Packages:Irena_SAD:ErrorWaveName
		Dtf   = " "
		IntDf = " "
		QDf   = " "
		EDf   = " "
		PopupMenu SelectDataFolder, win=IR2D_ControlPanel, mode=1
		PopupMenu IntensityDataName, mode=1, win=IR2D_ControlPanel, value="---"
		PopupMenu QvecDataName, mode=1, win=IR2D_ControlPanel, value="---"
		PopupMenu ErrorDataName, mode=1, win=IR2D_ControlPanel, value="---"
		//here we control the data structure checkbox
		execute("PopupMenu SelectDataFolder,mode=1,popvalue=\"---\",value= \"---;\"+IR2P_GenStringOfFolders(winNm=\"" + "IR2D_ControlPanel" + "\")")

	elseif(!stringmatch(ctrlName, "DisplayPeaks") && !stringMatch(ctrlname, "AutoRecalculate") && !stringMatch(ctrlname, "Oversample"))
		Setvariable $(ctrlName[3, Inf] + "LowLimit"), disable=!(checked)
		Setvariable $(ctrlName[3, Inf] + "HighLimit"), disable=!(checked)
	endif

	if(stringmatch(ctrlName, "DisplayPeaks") || stringMatch(ctrlname, "AutoRecalculate") || stringMatch(ctrlname, "Oversample") || stringMatch(ctrlname, "PeakSASScaling"))
		IR2D_CalculateIntensity(0)
	endif

	setDataFolder OldDF
End

///********************************************************************************************************
///********************************************************************************************************
///********************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_InputPanelCheckboxProc2(ctrlName, checked) : CheckBoxControl
	string   ctrlName
	variable checked

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD

	NVAR AppendResiduals
	NVAR AppendNormalizedResiduals
	if(stringmatch(ctrlName, "AppendResiduals"))
		if(checked)
			AppendNormalizedResiduals = 0
		endif
		IR2D_AppendRemoveResiduals()
	endif
	if(stringmatch(ctrlName, "AppendNormalizedResiduals"))
		if(checked)
			AppendResiduals = 0
		endif
		IR2D_AppendRemoveResiduals()
	endif
	if(stringmatch(ctrlName, "UseLogX"))
		DoWindow IR2D_LogLogPlotSAD
		if(V_Flag)
			ModifyGraph log(bottom)=checked
		endif
	endif
	if(stringmatch(ctrlName, "UseLogY"))
		DoWindow IR2D_LogLogPlotSAD
		if(V_Flag)
			ModifyGraph log(left)=checked
		endif
	endif

	setDataFolder OldDF
End
///********************************************************************************************************
///********************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_AppendRemoveResiduals()

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD
	NVAR AppendResiduals
	NVAR AppendNormalizedResiduals
	WAVE Residuals
	WAVE ModelQvector
	WAVE NormalizedResiduals

	CheckDisplayed/W=IR2D_LogLogPlotSAD Residuals
	if(V_Flag && AppendResiduals)
		//do nothing
	elseif(V_Flag && !AppendResiduals)
		RemoveFromGraph/W=IR2D_LogLogPlotSAD Residuals
		CheckDisplayed/W=IR2D_LogLogPlotSAD NormalizedResiduals
		if(!V_Flag)
			ModifyGraph mirror(left)=1
		endif
	elseif(!V_Flag && AppendResiduals)
		CheckDisplayed/W=IR2D_LogLogPlotSAD NormalizedResiduals
		if(V_Flag)
			RemoveFromGraph/W=IR2D_LogLogPlotSAD NormalizedResiduals
			ModifyGraph mirror(left)=1
		endif
		AppendToGraph/W=IR2D_LogLogPlotSAD/R Residuals vs ModelQvector
		SetAxis/A=2/E=2 right
		ModifyGraph mode(Residuals)=3, marker(Residuals)=29, rgb(Residuals)=(0, 0, 0)
		Label right, "Residuals"
	endif

	CheckDisplayed/W=IR2D_LogLogPlotSAD NormalizedResiduals
	if(V_Flag && AppendNormalizedResiduals)
		//do nothing
	elseif(V_Flag && !AppendNormalizedResiduals)
		RemoveFromGraph/W=IR2D_LogLogPlotSAD NormalizedResiduals
		CheckDisplayed/W=IR2D_LogLogPlotSAD Residuals
		if(!V_Flag)
			ModifyGraph mirror(left)=1
		endif
	elseif(!V_Flag && AppendNormalizedResiduals)
		CheckDisplayed/W=IR2D_LogLogPlotSAD Residuals
		if(V_Flag)
			RemoveFromGraph/W=IR2D_LogLogPlotSAD Residuals
			ModifyGraph mirror(left)=1
		endif
		AppendToGraph/W=IR2D_LogLogPlotSAD/R NormalizedResiduals vs ModelQvector
		SetAxis/A=2/E=2 right
		ModifyGraph mode(NormalizedResiduals)=3, marker(NormalizedResiduals)=29, rgb(NormalizedResiduals)=(0, 0, 0)
		Label right, "Normalized Residuals"
	endif

	setDataFolder OldDF
End
///********************************************************************************************************
///********************************************************************************************************
///********************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_GraphMeasuredData()
	//this function graphs data into the various graphs as needed

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD
	SVAR DataFolderName
	SVAR IntensityWaveName
	SVAR QWavename
	SVAR ErrorWaveName
	variable cursorAposition, cursorBposition

	//fix for liberal names
	IntensityWaveName = PossiblyQuoteName(IntensityWaveName)
	QWavename         = PossiblyQuoteName(QWavename)
	ErrorWaveName     = PossiblyQuoteName(ErrorWaveName)

	WAVE/Z test = $(DataFolderName + IntensityWaveName)
	if(!WaveExists(test))
		abort "Error in IntensityWaveName wave selection"
	endif
	cursorAposition = 0
	cursorBposition = numpnts(test) - 1
	WAVE/Z test = $(DataFolderName + QWavename)
	if(!WaveExists(test))
		abort "Error in QWavename wave selection"
	endif
	WAVE/Z test = $(DataFolderName + ErrorWaveName)
	if(!WaveExists(test))
		abort "Error in ErrorWaveName wave selection"
	endif

	Duplicate/O $(DataFolderName + IntensityWaveName), OriginalIntensity
	Duplicate/O $(DataFolderName + QWavename), OriginalQvector
	Duplicate/O $(DataFolderName + ErrorWaveName), OriginalError
	Redimension/D OriginalIntensity, OriginalQvector, OriginalError

	////test  Lorenzian correction
	//OriginalIntensity = OriginalIntensity * OriginalQvector^2
	//OriginalError = OriginalError *  OriginalQvector^2
	////end of test for Lorenzian correction

	wavestats/Q OriginalQvector
	if(V_min < 0)
		OriginalQvector = OriginalQvector[p] <= 0 ? NaN : OriginalQvector[p]
	endif
	IN2G_RemoveNaNsFrom3Waves(OriginalQvector, OriginalIntensity, OriginalError)
	NVAR/Z SubtractBackground = root:Packages:Irena_SAD:SubtractBackground
	NVAR/Z UseSMRData         = root:Packages:Irena_SAD:UseSMRData
	if(stringmatch(IntensityWaveName, "*SMR_Int*")) // slit smeared data
		UseSMRData = 1
		SetVariable SlitLength, win=IR2D_ControlPanel, disable=!UseSMRData
	elseif(stringmatch(IntensityWaveName, "*DSM_Int*")) //Indra 2 desmeared data
		UseSMRData = 0
		SetVariable SlitLength, win=IR2D_ControlPanel, disable=!UseSMRData
	else
		//we have no clue what user input, leave it to him to deal with slit smearing
	endif

	if(NVAR_Exists(UseSMRData))
		if(UseSMRData)
			NVAR     SlitLength = root:Packages:Irena_SAD:SlitLength
			variable tempSL1    = NumberByKey("SlitLength", note(OriginalIntensity), "=", ";")
			if(numtype(tempSL1) == 0)
				SlitLength = tempSL1
			endif
		endif
	endif

	KillWIndow/Z IR2D_LogLogPlotSAD
	Execute("IR2D_LogLogPlotSAD()")
	setDataFolder oldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Proc IR2D_LogLogPlotSAD()
	PauseUpdate // building window...
	string fldrSav = GetDataFolder(1)
	SetDataFolder root:Packages:Irena_SAD:
	//Display /W=(400.75,37.25,959.75,508.25)/K=1  OriginalIntensity vs OriginalQvector as "LogLogPlot"
	Display/W=(0, 0, IN2G_GetGraphWidthHeight("width"), IN2G_GetGraphWidthHeight("height"))/K=1 OriginalIntensity vs OriginalQvector as "LogLogPlot"
	DoWindow/C IR2D_LogLogPlotSAD
	AutoPositionWindow/M=0/R=IR2D_ControlPanel IR2D_LogLogPlotSAD

	ModifyGraph mode(OriginalIntensity)=3
	ModifyGraph msize(OriginalIntensity)=1
	//	NVAR UseLogX=root:Packages:Irena_SAD:UseLogX
	//	NVAR UseLogY=root:Packages:Irena_SAD:UseLogY
	if(UseLogX)
		ModifyGraph log(bottom)=1
	else
		ModifyGraph log(bottom)=0
	endif
	if(UseLogY)
		ModifyGraph log(left)=1
	else
		ModifyGraph log(left)=0
	endif
	ModifyGraph mirror=1
	ShowInfo
	string LabelStr = "\\Z" + IN2G_LkUpDfltVar("AxisLabelSize") + "Intensity [" + IN2G_ReturnUnitsForYAxis(OriginalIntensity) + "\\Z" + IN2G_LkUpDfltVar("AxisLabelSize") + "]"
	Label left, LabelStr
	LabelStr = "\\Z" + IN2G_LkUpDfltVar("AxisLabelSize") + "Q [A\\S-1\\M\\Z" + IN2G_LkUpDfltVar("AxisLabelSize") + "]"
	Label bottom, LabelStr
	string LegendStr = "\\F" + IN2G_LkUpDfltStr("FontType") + "\\Z" + IN2G_LkUpDfltVar("LegendSize") + "\\s(OriginalIntensity) Experimental intensity"
	Legend/W=IR2D_LogLogPlotSAD/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr
	//
	ErrorBars/Y=1 OriginalIntensity, Y, wave=(OriginalError, OriginalError)
	//and now some controls
	TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z" + IN2G_LkUpDfltVar("TagSize") + date() + ", " + time()
	TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z" + IN2G_LkUpDfltVar("TagSize") + DataFolderName + IntensityWaveName
	//	ControlBar 30
	//	Button SaveStyle size={80,20}, pos={50,5},proc=IR1U_StyleButtonCotrol,title="Save Style"
	//	Button ApplyStyle size={80,20}, pos={150,5},proc=IR1U_StyleButtonCotrol,title="Apply Style"
	SetDataFolder fldrSav
EndMacro

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_CalculateIntensity(force)
	variable force

	NVAR AutoRecalculate = root:Packages:Irena_SAD:AutoRecalculate
	if(!AutoRecalculate && !force)
		return 1
	endif
	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD

	NVAR   Background        = root:Packages:Irena_SAD:Background
	NVAR   RgPrefactor       = root:Packages:Irena_SAD:RgPrefactor
	NVAR   Rg                = root:Packages:Irena_SAD:Rg
	NVAR   PwrLawSlope       = root:Packages:Irena_SAD:PwrLawSlope
	NVAR   PwrLawPref        = root:Packages:Irena_SAD:PwrLawPref
	NVAR   DisplayPeaks      = root:Packages:Irena_SAD:DisplayPeaks
	WAVE/Z OriginalIntensity = root:Packages:Irena_SAD:OriginalIntensity
	WAVE/Z OriginalQvector   = root:Packages:Irena_SAD:OriginalQvector
	WAVE/Z OriginalError     = root:Packages:Irena_SAD:OriginalError
	NVAR   UseSMRData        = root:Packages:Irena_SAD:UseSMRData
	NVAR   SlitLength        = root:Packages:Irena_SAD:SlitLength
	NVAR   Oversample        = root:Packages:Irena_SAD:Oversample
	NVAR   PeakSASScaling    = root:Packages:Irena_SAD:PeakSASScaling

	if(!WaveExists(OriginalIntensity) || !WaveExists(OriginalQvector))
		abort
	endif
	variable startPoint, endPoint, i
	startPoint = 0
	endPoint   = numpnts(OriginalIntensity) - 1
	if(strlen(CsrInfo(A, "IR2D_LogLogPlotSAD")))
		startPoint = pcsr(A, "IR2D_LogLogPlotSAD")
	endif
	if(strlen(CsrInfo(B, "IR2D_LogLogPlotSAD")))
		endPoint = pcsr(B, "IR2D_LogLogPlotSAD")
	endif

	IN2G_CheckForSlitSmearedRange(UseSMRData, OriginalQvector[endPoint], SlitLength)

	Duplicate/O/R=[startpoint, endpoint] OriginalQvector, ModelQvector
	Duplicate/O/R=[startpoint, endpoint] OriginalError, TempErrors
	Duplicate/O/R=[startpoint, endpoint] OriginalIntensity, ModelIntensity, tempInt, tempInt2, ResInt, Residuals, NormalizedResiduals

	SetScale/P x, 0, 1, "", ModelQvector, ModelIntensity, tempInt, Residuals, NormalizedResiduals

	//here we fix it in case of slit smeared data...
	variable OriginalNumPnts  = numpnts(ModelQvector)
	variable OriginalNumPnts2 = numpnts(ModelQvector)
	variable CurLength
	variable newLength
	variable DataLengths
	if(UseSMRData)
		DataLengths = numpnts(ModelQvector) //get number of original data points
		variable Qstep     = ((ModelQvector[DataLengths - 1] / ModelQvector[DataLengths - 2]) - 1) * ModelQvector[DataLengths]
		variable ExtendByQ = sqrt(ModelQvector[DataLengths - 1]^2 + (1.5 * slitLength)^2) - ModelQvector[DataLengths - 1]
		if(ExtendByQ < 2.1 * Qstep)
			ExtendByQ = 2.1 * Qstep
		endif
		variable NumNewPoints = floor(ExtendByQ / Qstep)
		if(NumNewPoints < 1)
			NumNewPoints = 1
		endif
		newLength = OriginalNumPnts + NumNewPoints //New length of waves
		Redimension/N=(newLength) ModelQvector, ModelIntensity, tempInt, tempInt2
		for(i = 0; i <= NumNewPoints; i += 1)
			ModelQvector[OriginalNumPnts + i] = ModelQvector[OriginalNumPnts - 1] + (ExtendByQ) * ((i + 1) / NumNewPoints) //extend Q
		endfor
	endif
	//end of slit smeared data 1 part...
	CurLength = numpnts(ModelQvector)
	if(Oversample)
		Duplicate/O ModelQvector, ShortQvector
		Redimension/N=(5 * CurLength) ModelQvector, ModelIntensity, tempInt, tempInt2
		for(i = 0; i < (5 * CurLength); i += 5)
			ModelQvector[i]     = ShortQvector[i / 5]
			ModelQvector[i + 1] = ShortQvector[i / 5] + (1 / 5) * (ShortQvector[(i + 5) / 5] - ShortQvector[i / 5])
			ModelQvector[i + 2] = ShortQvector[i / 5] + (2 / 5) * (ShortQvector[(i + 5) / 5] - ShortQvector[i / 5])
			ModelQvector[i + 3] = ShortQvector[i / 5] + (3 / 5) * (ShortQvector[(i + 5) / 5] - ShortQvector[i / 5])
			ModelQvector[i + 4] = ShortQvector[i / 5] + (4 / 5) * (ShortQvector[(i + 5) / 5] - ShortQvector[i / 5])
		endfor
		OriginalNumPnts = 5 * CurLength
	endif

	SetScale/P x, 0, 1, "", ModelQvector, ModelIntensity, tempInt, tempInt2, Residuals, NormalizedResiduals, ResInt

	//calculate the intensity
	ModelIntensity = 0

	IR2D_UnifiedIntensity(ModelIntensity, ModelQvector, RgPrefactor, Rg, PwrLawPref, PwrLawSlope)
	IR2D_UnifiedIntensity(tempInt2, ModelQvector, RgPrefactor, Rg, PwrLawPref, PwrLawSlope)

	ModelIntensity += Background

	Duplicate/O ModelIntensity, UnifiedIntensity
	Duplicate/O ModelQvector, UnifiedQvector

	//here we need to add the code which calculates the peaks...
	Duplicate/O ModelIntensity, tempModelIntensity
	//	NVAR PeakSASScaling = root:Packages:Irena_SAD:PeakSASScaling
	//set PeakSASScaling to 1 to have peaks separate, otherwise these are multiplied by Unified level intensity here... No background assumed.
	for(i = 1; i <= 6; i += 1)
		IR2D_CalcOnePeakInt(i, tempInt, ModelQvector)
		if(PeakSASScaling)
			ModelIntensity += tempInt
		else
			ModelIntensity += tempInt * tempInt2
		endif
	endfor

	if(UseSMRData)
		Duplicate/O ModelIntensity, SMModelIntensity
		IR1B_SmearData(ModelIntensity, ModelQvector, slitLength, SMModelIntensity)
		DeletePoints (OriginalNumPnts), Inf, SMModelIntensity, ModelQvector, ModelIntensity
		ModelIntensity = SMModelIntensity
	endif
	//fix low resolution of peak results, make special dense Q vector copy for local fits.
	Duplicate/O ModelQvector, PeakModelQvector //thi sis now either sparse or dense, depending on the user checkbox.
	//
	if(Oversample)
		Duplicate/O ModelIntensity, CutMeModelIntensity
		Redimension/N=(OriginalNumPnts2) ModelIntensity
		for(i = 0; i < (OriginalNumPnts2); i += 1)
			ModelIntensity[i] = CutMeModelIntensity[i * 5]
		endfor
		Duplicate/O ShortQvector, ModelQvector
	endif
	//residuals
	Residuals           = ResInt - ModelIntensity
	NormalizedResiduals = Residuals / TempErrors

	//now the local fits
	RemoveFromGraph/W=IR2D_LogLogPlotSAD/Z Peak1Intensity, Peak2Intensity, Peak3Intensity, Peak4Intensity, Peak5Intensity, Peak6Intensity
	KillWaves/Z Peak1Intensity, Peak2Intensity, Peak3Intensity, Peak4Intensity, Peak5Intensity, Peak6Intensity, ResInt, TempErrors, tempInt2
	//
	Duplicate/FREE PeakModelQvector, TempPeakInt
	for(i = 1; i <= 6; i += 1)
		NVAR usePk = $("root:Packages:Irena_SAD:UsePeak" + num2str(i))
		if(usePk)
			IR2D_CalcOnePeakInt(i, TempPeakInt, PeakModelQvector)
			Duplicate/O TempPeakInt, $("Peak" + num2str(i) + "Intensity")
			SetScale/P x, 0, 1, "", TempPeakInt
		endif
	endfor

	IR2D_AppendDataToGraph()
	IR2D_AppendRemoveResiduals()
	IR2D_UpdatePeakParams()
	setDataFolder oldDf
End
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_UnifiedIntensity(ReturnInt, Qvector, G, Rg, B, P)
	variable G, Rg, B, P
	WAVE Qvector, ReturnInt

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD
	WAVE OriginalIntensity

	Duplicate/O Qvector, QstarVector

	variable K = 1

	QstarVector = Qvector / (erf(K * Qvector * Rg / sqrt(6)))^3

	ReturnInt = G * exp(-Qvector^2 * Rg^2 / 3) + (B / QstarVector^P)

	killWaves/Z QstarVector
	setDataFolder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_CalcOnePeakInt(i, tempInt, qwv)
	variable i
	WAVE tempInt, qwv

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD

	NVAR UsePeak             = $("root:Packages:Irena_SAD:UsePeak" + num2str(i))
	NVAR Par1                = $("root:Packages:Irena_SAD:Peak" + num2str(i) + "_Par1")
	NVAR Par2                = $("root:Packages:Irena_SAD:Peak" + num2str(i) + "_Par2")
	NVAR Par3                = $("root:Packages:Irena_SAD:Peak" + num2str(i) + "_Par3")
	NVAR Par4                = $("root:Packages:Irena_SAD:Peak" + num2str(i) + "_Par4")
	SVAR FunctionName        = $("root:Packages:Irena_SAD:Peak" + num2str(i) + "_Function")
	NVAR Peak_LinkPar2       = $("root:Packages:Irena_SAD:Peak" + num2str(i) + "_LinkPar2")
	NVAR Peak_LinkMultiplier = $("root:Packages:Irena_SAD:Peak" + num2str(i) + "_LinkMultiplier")
	SVAR Peak_LinkedTo       = $("root:Packages:Irena_SAD:Peak" + num2str(i) + "_LinkedTo")

	tempInt = 0
	if(usePeak)
		if(Peak_LinkPar2)
			variable PeakLinkedTo = str2num(Peak_LinkedTo[4, Inf])
			if(numtype(PeakLinkedTo) > 0)
				abort "Bad Peak number linked to peak " + num2str(i)
			endif
			NVAR Par2Linked = $("root:Packages:Irena_SAD:Peak" + num2str(PeakLinkedTo) + "_Par2")
			Par2 = Par2Linked * Peak_LinkMultiplier
		endif

		if(stringmatch(FunctionName, "Gauss"))
			//			tempInt =Par1*exp(-((qwv-Par2)^2/Par3))
			tempInt = IR2D_Gauss(qwv, Par1, Par2, Par3)
			//Par1 * IR1_GaussProbability(qwv,Par2,Par3, 0)
		endif
		if(stringmatch(FunctionName, "Lorenz"))
			tempInt = IR2D_Lorenz(qwv, Par1, Par2, Par3)
			//tempInt =(1/pi) *  Par1 * Par3/((qwv-Par2)^2+Par3^2) 	//from formula 10 at
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(FunctionName, "LorenzSquared"))
			tempInt = IR2D_Lorenz2(qwv, Par1, Par2, Par3)
			//tempInt =(1/pi) *  Par1 * Par3/((qwv-Par2)^2+Par3^2) 	//from formula 10 at
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif

		if(stringmatch(FunctionName, "Pseudo-Voigt"))
			tempInt = Par4 * (IR2D_Lorenz(qwv, Par1, Par2, Par3)) + (1 - Par4) * IR2D_Gauss(qwv, Par1, Par2, Par3)
			//tempInt =(1/pi) *  Par1 * Par3/((qwv-Par2)^2+Par3^2) 	//from formula 10 at
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(FunctionName, "Gumbel"))
			tempInt = IR2D_Gumbel(qwv, Par1, Par2, Par3, Par4)
			//NIST handbook on statistics
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(FunctionName, "Pearson_VII"))
			tempInt = IR2D_PearsonVII(qwv, Par1, Par2, Par3, Par4)
			//NIST handbook on statistics
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(FunctionName, "Modif_Gauss"))
			tempInt = IR2D_ModifGauss(qwv, Par1, Par2, Par3, Par4)
			//NIST handbook on statistics
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(FunctionName, "LogNormal"))
			tempInt = IR2D_LogNormal(qwv, Par1, Par2, Par3)
			//NIST handbook on statistics
			//http://mathworld.wolfram.com/CauchyDistribution.html
		endif
		if(stringmatch(FunctionName, "Percus-Yevick-Sq"))
			tempInt = IR2D_PercusYevickSqNIST(qwv, Par1, Par2, Par3)
			//IR2D_PercusYevick(Q,Par1,Diameter,Fraction)
		endif
		if(stringmatch(FunctionName, "Percus-Yevick-SqFq"))
			tempInt = IR2D_PercusYevickSqFqNIST(qwv, Par1, Par2, Par3)
			//IR2D_PercusYevick(Q,Par1,Diameter,Fraction)
		endif
		if(stringmatch(FunctionName, "SkewedNormal"))
			tempInt = IR2D_SkewedNormal(qwv, Par1, Par2, Par3, Par4)
			//IR2D_PercusYevick(Q,Par1,Diameter,Fraction)
		endif

	endif

	return 1
	setDataFolder oldDf
End
//*****************************************************************************************************************

Function IR2D_SkewedNormal(Q, Par1, Location, scale, shape)
	variable Q, Par1, Location, scale, shape
	//location is clear
	//scale is width
	//shape is skweness, shape<0 skews to left, >0 skews to right

	variable result
	//define parameters needed here:
	variable tempPos = (Q - location) / scale
	variable FiX     = (1 + erf(shape * tempPos / sqrt(2))) / 2
	result = Par1 * 2 / scale * ((1 / (sqrt(2 * pi))) * exp(-1 * tempPos^2 / 2)) * FiX

	return result
End
//*****************************************************************************************************************

Function IR2D_PercusYevickSqFqNIST(x, Par1, Radius, Fraction)
	variable x, Par1, Radius, Fraction

	//     SUBROUTINE HSSTRCT: CALCULATES THE STRUCTURE FACTOR FOR A
	//                         DISPERSION OF MONODISPERSE HARD SPHERES
	//                         IN THE PERCUS-YEVICK APPROXIMATION
	//
	//     REFS:  PERCUS,YEVICK PHYS. REV. 110 1 (1958)
	//            THIELE J. CHEM PHYS. 39 474 (1968)
	//            WERTHEIM  PHYS. REV. LETT. 47 1462 (1981)
	variable r, phi, struc
	r   = Radius
	phi = Fraction

	// Local variables
	variable denom, dnum, alpha, BetaVar, gamm, q, a, asq, ath, afor, rca, rsa
	variable calp, cbeta, cgam, prefac, c, vstruc
	DENOM   = (1.0 - PHI)^4
	DNUM    = (1.0 + 2.0 * PHI)^2
	ALPHA   = DNUM / DENOM
	BetaVar = -6.0 * PHI * ((1.0 + PHI / 2.0)^2) / DENOM
	GAMM    = 0.50 * PHI * DNUM / DENOM
	Q       = x // q-value for the calculation is passed in as variable x
	A       = 2.0 * Q * R
	ASQ     = A * A
	ATH     = ASQ * A
	AFOR    = ATH * A
	RCA     = COS(A)
	RSA     = SIN(A)
	CALP    = ALPHA * (RSA / ASQ - RCA / A)
	CBETA   = BetaVar * (2.0 * RSA / ASQ - (ASQ - 2.0) * RCA / ATH - 2.0 / ATH)
	CGAM    = GAMM * (-RCA / A + (4.0 / A) * ((3.0 * ASQ - 6.0) * RCA / AFOR + (ASQ - 6.0) * RSA / ATH + 6.0 / AFOR))
	PREFAC  = -24.0 * PHI / A
	C       = PREFAC * (CALP + CBETA + CGAM)
	VSTRUC  = 1.0 / (1.0 - C)
	STRUC   = VSTRUC
	variable QR = Q * R
	variable FQ = ((3 / (QR * QR * QR)) * (sin(QR) - (QR * cos(QR))))

	return Par1 * Struc * FQ^2 * Fraction
End
//*****************************************************************************************************************

Function IR2D_PercusYevickSqNIST(x, Par1, Radius, Fraction)
	variable x, Par1, Radius, Fraction

	//     SUBROUTINE HSSTRCT: CALCULATES THE STRUCTURE FACTOR FOR A
	//                         DISPERSION OF MONODISPERSE HARD SPHERES
	//                         IN THE PERCUS-YEVICK APPROXIMATION
	//
	//     REFS:  PERCUS,YEVICK PHYS. REV. 110 1 (1958)
	//            THIELE J. CHEM PHYS. 39 474 (1968)
	//            WERTHEIM  PHYS. REV. LETT. 47 1462 (1981)
	variable r, phi, struc
	r   = Radius
	phi = Fraction

	// Local variables
	variable denom, dnum, alpha, BetaVar, gamm, q, a, asq, ath, afor, rca, rsa
	variable calp, cbeta, cgam, prefac, c, vstruc
	DENOM   = (1.0 - PHI)^4
	DNUM    = (1.0 + 2.0 * PHI)^2
	ALPHA   = DNUM / DENOM
	BetaVar = -6.0 * PHI * ((1.0 + PHI / 2.0)^2) / DENOM
	GAMM    = 0.50 * PHI * DNUM / DENOM
	Q       = x // q-value for the calculation is passed in as variable x
	A       = 2.0 * Q * R
	ASQ     = A * A
	ATH     = ASQ * A
	AFOR    = ATH * A
	RCA     = COS(A)
	RSA     = SIN(A)
	CALP    = ALPHA * (RSA / ASQ - RCA / A)
	CBETA   = BetaVar * (2.0 * RSA / ASQ - (ASQ - 2.0) * RCA / ATH - 2.0 / ATH)
	CGAM    = GAMM * (-RCA / A + (4.0 / A) * ((3.0 * ASQ - 6.0) * RCA / AFOR + (ASQ - 6.0) * RSA / ATH + 6.0 / AFOR))
	PREFAC  = -24.0 * PHI / A
	C       = PREFAC * (CALP + CBETA + CGAM)
	VSTRUC  = 1.0 / (1.0 - C)
	STRUC   = VSTRUC
	return Par1 * Struc
End
// End of HardSphereStruct
//*****************************************************************************************************************
Function IR2D_PearsonVII(x, Par1, Par2, Par3, Par4)
	variable x, Par1, Par2, Par3, Par4
	//this function calculates probability for Gauss (normal) distribution

	variable result
	//NIST handbook on statists...
	result = Par1 * (1 + ((x - Par2)^2 / (Par4 * Par3^2)))^(-Par4)

	if(numtype(result) != 0)
		result = 0
	endif

	return result

End

//*****************************************************************************************************************
Function IR2D_ModifGauss(x, Par1, Par2, Par3, Par4)
	variable x, Par1, Par2, Par3, Par4
	//this function calculates probability for Gauss (normal) distribution

	variable result
	//NIST handbook on statists...
	result = Par1 * exp(-0.5 * ((abs(x - Par2) / Par3)^Par4))

	if(numtype(result) != 0)
		result = 0
	endif

	return result

End

//*****************************************************************************************************************
Function IR2D_Gumbel(x, Par1, Par2, Par3, Par4)
	variable x, Par1, Par2, Par3, Par4
	//this function calculates probability for Gauss (normal) distribution

	variable result
	//NIST handbook on statists...
	result = (Par1 / Par3) * exp((x - Par2) / Par3) * exp(-exp((x - Par2) / Par3))

	if(numtype(result) != 0)
		result = 0
	endif

	return result

End

//*****************************************************************************************************************
Function IR2D_Gauss(x, Par1, Par2, Par3)
	variable x, Par1, Par2, Par3
	//this function calculates probability for Gauss (normal) distribution

	variable result

	//	result=Par1 * (exp(-((x-Par2)^2)/(2*Par3^2)))/(Par3*(sqrt(2*pi)))
	//used: http://books.google.com/books?id=P6Y7FRi9gW0C&pg=PA23&lpg=PA23&dq=%22pseudo+voigt%22+peak+shape+function&source=web&ots=Ejz1Fm95Jo&sig=coEWMIfGWu6yzeQIMzF7HK1E7Us#PPA23,M1

	result = Par1 * (exp(-ln(2) * ((x - Par2) / Par3)^2))

	if(numtype(result) != 0)
		result = 0
	endif

	return result

End
//*****************************************************************************************************************
Function IR2D_LogNormal(x, Par1, Par2, Par3)
	variable x, Par1, Par2, Par3
	//this function calculates probability for lognormal distribution
	//Par1 is scaleing factor
	//Par2 is mean value (position)
	//Par3 is sigma (width)

	variable result
	result = Par1 * (exp(-0.5 * (ln(x / Par2) / Par3)^2)) / (x * Par3 * sqrt(2 * pi))
	//return  w[1] * exp( - 0.5 * (ln(x/w[2])/w[3])^2) / ( x*w[3] * sqrt(2*pi) )

	if(numtype(result) != 0)
		result = 0
	endif
	return result
End

//*****************************************************************************************************************
Function IR2D_Lorenz(x, Par1, Par2, Par3)
	variable x, Par1, Par2, Par3

	//		tempInt =(1/pi) *  Par1 * Par3/((qwv-Par2)^2+Par3^2) 	//from formula 10 at
	//used: http://books.google.com/books?id=P6Y7FRi9gW0C&pg=PA23&lpg=PA23&dq=%22pseudo+voigt%22+peak+shape+function&source=web&ots=Ejz1Fm95Jo&sig=coEWMIfGWu6yzeQIMzF7HK1E7Us#PPA23,M1

	variable result

	//result=(1/pi) *  Par1 * Par3/((x-Par2)^2+Par3^2)
	result = Par1 * (1 + ((x - Par2) / Par3)^2)^(-1.5)

	if(numtype(result) != 0)
		result = 0
	endif

	return result

End

//*****************************************************************************************************************
Function IR2D_Lorenz2(x, Par1, Par2, Par3)
	variable x, Par1, Par2, Par3

	variable result

	result = Par1 * ((1 + ((x - Par2) / Par3)^2)^(-1.5))^2

	if(numtype(result) != 0)
		result = 0
	endif

	return result

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_AppendDataToGraph()

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD

	DoWindow IR2D_LogLogPlotSAD
	if(!V_Flag)
		abort
	endif
	NVAR   DisplayPeaks     = root:Packages:Irena_SAD:DisplayPeaks
	WAVE/Z ModelIntensity   = root:Packages:Irena_SAD:ModelIntensity
	WAVE/Z ModelQvector     = root:Packages:Irena_SAD:ModelQvector
	WAVE/Z PeakModelQvector = root:Packages:Irena_SAD:PeakModelQvector
	if(!WaveExists(ModelIntensity) || !WaveExists(ModelQvector) || !WaveExists(PeakModelQvector))
		abort
	endif
	Checkdisplayed/W=IR2D_LogLogPlotSAD ModelIntensity
	if(!V_Flag)
		AppendToGraph/W=IR2D_LogLogPlotSAD ModelIntensity vs ModelQvector
		ModifyGraph/W=IR2D_LogLogPlotSAD lsize(ModelIntensity)=2, rgb(ModelIntensity)=(1, 3, 39321)
		SetAxis/W=IR2D_LogLogPlotSAD bottom, ModelQvector[0], ModelQvector[numpnts(ModelQvector) - 1]
		wavestats/Q ModelIntensity
		SetAxis/W=IR2D_LogLogPlotSAD left, V_min, V_max

	endif

	variable i
	for(i = 0; i <= 6; i += 1)
		WAVE/Z PeakInt = $("Peak" + num2str(i) + "Intensity")
		if(WaveExists(PeakInt) && DisplayPeaks)
			Checkdisplayed/W=IR2D_LogLogPlotSAD $("Peak" + num2str(i) + "Intensity")
			AppendToGraph/W=IR2D_LogLogPlotSAD PeakInt vs PeakModelQvector
			ModifyGraph/W=IR2D_LogLogPlotSAD lsize($("Peak" + num2str(i) + "Intensity"))=2, rgb($("Peak" + num2str(i) + "Intensity"))=(0, 0, 0)
		endif

	endfor
	//Peak1Intensity,Peak2Intensity,Peak3Intensity,Peak4Intensity,Peak5Intensity,Peak6Intensity
	setDataFolder oldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_Fitting()
	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD

	//Create the fitting parameters, these will have _pop added and we need to add them to list of parameters to fit...
	string ListOfPeakVariables = ""

	Make/O/N=0/T T_Constraints
	T_Constraints = ""
	Make/D/N=0/O W_coef
	Make/O/N=(0, 2) Gen_Constraints
	Make/T/N=0/O CoefNames
	CoefNames = ""

	variable i, j //i goes through all items in list, j is 1 to 6 - populations
	variable Link2 = 1
	//first handle coefficients which are easy - those existing all the time... Volume is the only one at this time...
	ListOfPeakVariables = "Peak1_Par;Peak2_Par;Peak3_Par;Peak4_Par;Peak5_Par;Peak6_Par;"
	for(j = 1; j <= 6; j += 1)
		NVAR UseThePop = $("root:Packages:Irena_SAD:UsePeak" + num2str(j))
		if(UseThePop)
			//Parameter 1
			NVAR CurVarTested = $("root:Packages:Irena_SAD:Peak" + num2str(j) + "_Par1")
			NVAR FitCurVar    = $("root:Packages:Irena_SAD:FitPeak" + num2str(j) + "_Par1")
			NVAR CuVarMin     = $("root:Packages:Irena_SAD:Peak" + num2str(j) + "_Par1LowLimit")
			NVAR CuVarMax     = $("root:Packages:Irena_SAD:Peak" + num2str(j) + "_Par1HighLimit")
			if(FitCurVar) //are we fitting this variable?
				Redimension/N=(numpnts(W_coef) + 1) W_coef, CoefNames
				Redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
				W_Coef[numpnts(W_Coef) - 1]               = CurVarTested
				CoefNames[numpnts(CoefNames) - 1]         = "Peak" + num2str(j) + "_Par1"
				T_Constraints[numpnts(T_Constraints) - 2] = {"K" + num2str(numpnts(W_coef) - 1) + " > " + num2str(CuVarMin)}
				T_Constraints[numpnts(T_Constraints) - 1] = {"K" + num2str(numpnts(W_coef) - 1) + " < " + num2str(CuVarMax)}
				Redimension/N=((numpnts(W_coef)), 2) Gen_Constraints
				Gen_Constraints[numpnts(CoefNames) - 1][0] = CuVarMin
				Gen_Constraints[numpnts(CoefNames) - 1][1] = CuVarMax
			endif
			//Parameter 2

			NVAR LinkPop = $("root:Packages:Irena_SAD:Peak" + num2str(j) + "_LinkPar2")
			Link2 = !LinkPop
			NVAR CurVarTested = $("root:Packages:Irena_SAD:Peak" + num2str(j) + "_Par2")
			NVAR FitCurVar    = $("root:Packages:Irena_SAD:FitPeak" + num2str(j) + "_Par2")
			NVAR CuVarMin     = $("root:Packages:Irena_SAD:Peak" + num2str(j) + "_Par2LowLimit")
			NVAR CuVarMax     = $("root:Packages:Irena_SAD:Peak" + num2str(j) + "_Par2HighLimit")
			if(FitCurVar && Link2) //are we fitting this variable?
				Redimension/N=(numpnts(W_coef) + 1) W_coef, CoefNames
				Redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
				W_Coef[numpnts(W_Coef) - 1]               = CurVarTested
				CoefNames[numpnts(CoefNames) - 1]         = "Peak" + num2str(j) + "_Par2"
				T_Constraints[numpnts(T_Constraints) - 2] = {"K" + num2str(numpnts(W_coef) - 1) + " > " + num2str(CuVarMin)}
				T_Constraints[numpnts(T_Constraints) - 1] = {"K" + num2str(numpnts(W_coef) - 1) + " < " + num2str(CuVarMax)}
				Redimension/N=((numpnts(W_coef)), 2) Gen_Constraints
				Gen_Constraints[numpnts(CoefNames) - 1][0] = CuVarMin
				Gen_Constraints[numpnts(CoefNames) - 1][1] = CuVarMax
			endif
			//Parameter 3
			NVAR CurVarTested = $("root:Packages:Irena_SAD:Peak" + num2str(j) + "_Par3")
			NVAR FitCurVar    = $("root:Packages:Irena_SAD:FitPeak" + num2str(j) + "_Par3")
			NVAR CuVarMin     = $("root:Packages:Irena_SAD:Peak" + num2str(j) + "_Par3LowLimit")
			NVAR CuVarMax     = $("root:Packages:Irena_SAD:Peak" + num2str(j) + "_Par3HighLimit")
			if(FitCurVar) //are we fitting this variable?
				Redimension/N=(numpnts(W_coef) + 1) W_coef, CoefNames
				Redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
				W_Coef[numpnts(W_Coef) - 1]               = CurVarTested
				CoefNames[numpnts(CoefNames) - 1]         = "Peak" + num2str(j) + "_Par3"
				T_Constraints[numpnts(T_Constraints) - 2] = {"K" + num2str(numpnts(W_coef) - 1) + " > " + num2str(CuVarMin)}
				T_Constraints[numpnts(T_Constraints) - 1] = {"K" + num2str(numpnts(W_coef) - 1) + " < " + num2str(CuVarMax)}
				Redimension/N=((numpnts(W_coef)), 2) Gen_Constraints
				Gen_Constraints[numpnts(CoefNames) - 1][0] = CuVarMin
				Gen_Constraints[numpnts(CoefNames) - 1][1] = CuVarMax
			endif
			//Parameter 4
			SVAR Peak_Function = $("root:Packages:Irena_SAD:Peak" + num2str(j) + "_Function")
			NVAR CurVarTested  = $("root:Packages:Irena_SAD:Peak" + num2str(j) + "_Par4")
			NVAR FitCurVar     = $("root:Packages:Irena_SAD:FitPeak" + num2str(j) + "_Par4")
			NVAR CuVarMin      = $("root:Packages:Irena_SAD:Peak" + num2str(j) + "_Par4LowLimit")
			NVAR CuVarMax      = $("root:Packages:Irena_SAD:Peak" + num2str(j) + "_Par4HighLimit")
			if(FitCurVar && stringmatch(Peak_Function, "Pseudo-Voigt")) //are we fitting this variable?
				Redimension/N=(numpnts(W_coef) + 1) W_coef, CoefNames
				Redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
				W_Coef[numpnts(W_Coef) - 1]               = CurVarTested
				CoefNames[numpnts(CoefNames) - 1]         = "Peak" + num2str(j) + "_Par4"
				T_Constraints[numpnts(T_Constraints) - 2] = {"K" + num2str(numpnts(W_coef) - 1) + " > " + num2str(CuVarMin)}
				T_Constraints[numpnts(T_Constraints) - 1] = {"K" + num2str(numpnts(W_coef) - 1) + " < " + num2str(CuVarMax)}
				Redimension/N=((numpnts(W_coef)), 2) Gen_Constraints
				Gen_Constraints[numpnts(CoefNames) - 1][0] = CuVarMin
				Gen_Constraints[numpnts(CoefNames) - 1][1] = CuVarMax
			endif
		endif
	endfor

	//Now background...
	string ListOfDataVariables = "Background;PwrLawPref;PwrLawSlope;Rg;RgPrefactor;"
	for(i = 0; i < ItemsInList(ListOfDataVariables); i += 1)
		NVAR CurVarTested = $("root:Packages:Irena_SAD:" + stringfromList(i, ListOfDataVariables))
		NVAR FitCurVar    = $("root:Packages:Irena_SAD:Fit" + stringfromList(i, ListOfDataVariables))
		NVAR CuVarMin     = $("root:Packages:Irena_SAD:" + stringfromList(i, ListOfDataVariables) + "LowLimit")
		NVAR CuVarMax     = $("root:Packages:Irena_SAD:" + stringfromList(i, ListOfDataVariables) + "HighLimit")
		if(FitCurVar) //are we fitting this variable?
			Redimension/N=(numpnts(W_coef) + 1) W_coef, CoefNames
			Redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
			W_Coef[numpnts(W_Coef) - 1]               = CurVarTested
			CoefNames[numpnts(CoefNames) - 1]         = stringfromList(i, ListOfDataVariables)
			T_Constraints[numpnts(T_Constraints) - 2] = {"K" + num2str(numpnts(W_coef) - 1) + " > " + num2str(CuVarMin)}
			T_Constraints[numpnts(T_Constraints) - 1] = {"K" + num2str(numpnts(W_coef) - 1) + " < " + num2str(CuVarMax)}
			Redimension/N=((numpnts(W_coef)), 2) Gen_Constraints
			Gen_Constraints[numpnts(CoefNames) - 1][0] = CuVarMin
			Gen_Constraints[numpnts(CoefNames) - 1][1] = CuVarMax
		endif
	endfor

	//Ok, all parameters should be dealt with, now the fitting...
	//	DoWindow /F LSQF_MainGraph
	//	variable QstartPoint, QendPoint
	//	Make/O/N=0 QWvForFit, IntWvForFit, EWvForFit
	WAVE/Z OriginalIntensity = root:Packages:Irena_SAD:OriginalIntensity
	WAVE/Z OriginalQvector   = root:Packages:Irena_SAD:OriginalQvector
	WAVE/Z OriginalError     = root:Packages:Irena_SAD:OriginalError
	//	Wave/Z ModelIntensity=root:Packages:Irena_SAD:ModelIntensity
	//	if(!WaveExists(ModelIntensity))
	//		IR2D_CalculateIntensity(1)
	//	endif
	NVAR UseGeneticOptimization = root:Packages:Irena_SAD:UseGeneticOptimization

	if(!WaveExists(OriginalIntensity) || !WaveExists(OriginalQvector))
		abort
	endif
	variable startPoint, endPoint
	startPoint = 0
	endPoint   = numpnts(OriginalIntensity) - 1
	if(strlen(CsrInfo(A, "IR2D_LogLogPlotSAD")))
		startPoint = pcsr(A, "IR2D_LogLogPlotSAD")
	endif
	if(strlen(CsrInfo(B, "IR2D_LogLogPlotSAD")))
		endPoint = pcsr(B, "IR2D_LogLogPlotSAD")
	endif
	Duplicate/O/R=[startpoint, endpoint] OriginalQvector, QvectorForFit
	Duplicate/O/R=[startpoint, endpoint] OriginalIntensity, IntensityForFit
	Duplicate/O/R=[startpoint, endpoint] OriginalError, ErrorForFit

	if(numpnts(W_Coef) < 1)
		DoAlert 0, "Nothing to fit, select at least 1 parameter to fit"
		return 1
	endif

	Duplicate/O W_Coef, E_wave, CoefficientInput
	E_wave = W_coef / 20
	variable V_chisq
	string HoldStr = ""
	for(i = 0; i < numpnts(CoefficientInput); i += 1)
		HoldStr += "0"
	endfor
	Duplicate/O IntensityForFit, MaskWaveGenOpt
	MaskWaveGenOpt = 1

	if(UseGeneticOptimization)
		IR2D_CheckFittingParamsFnct()
		PauseForUser IR2D_CheckFittingParams
	endif
	NVAR UserCanceled = root:Packages:Irena_SAD:UserCanceled
	if(UserCanceled)
		setDataFolder OldDf
		abort
	endif

	IR2D_RecordResults("before")
	//	Duplicate/O IntensityForFit, tempDestWave
	variable V_FitError = 0 //This should prevent errors from being generated
	//and now the fit...
	if(UseGeneticOptimization)
#if Exists("gencurvefit") == 4
		gencurvefit/I=1/W=ErrorForFit/M=MaskWaveGenOpt/N/TOL=0.002/K={50, 20, 0.7, 0.5}/X=QvectorForFit IR2D_FitFunction, IntensityForFit, W_Coef, HoldStr, Gen_Constraints
#else
		//	  	GEN_curvefit("IR2D_FitFunction",W_Coef,IntensityForFit,HoldStr,x=QvectorForFit,w=ErrorForFit,c=Gen_Constraints, mask=MaskWaveGenOpt, popsize=20,k_m=0.7,recomb=0.5,iters=50,tol=0.002)
		Abort "Genetic Optimization xop NOT installed. Install xop support and then try again"
#endif
	else
		FuncFit/N=0/W=0/Q IR2D_FitFunction, W_coef, IntensityForFit/X=QvectorForFit/W=ErrorForFit/I=1/E=E_wave/D/C=T_Constraints
	endif

	if(V_FitError != 0) //there was error in fitting
		IR2D_ResetParamsAfterBadFit()
		Abort "Fitting error, check starting parameters and fitting limits"
	else //results OK, make sure the resulting values are set
		variable NumParams = numpnts(CoefNames)
		string ParamName
		for(i = 0; i < NumParams; i += 1)
			ParamName = CoefNames[i]
			NVAR TempVar = $(ParamName)
			TempVar = W_Coef[i]
		endfor
		print "Achieved chi-square = " + num2str(V_chisq)
	endif

	variable/G AchievedChisq = V_chisq
	IR2D_RecordResults("after")
	KillWaves/Z T_Constraints, E_wave

	//	IR2L_CalculateIntensity(1,0)

	setDataFolder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_CheckFittingParamsFnct()
	//PauseUpdate    		// building window...
	NewPanel/K=1/W=(400, 140, 870, 600) as "Check fitting parameters"
	Dowindow/C IR2D_CheckFittingParams
	SetDrawLayer UserBack
	SetDrawEnv fsize=20, fstyle=3, textrgb=(0, 0, 65280)
	DrawText 39, 28, "Small angle diffraction Fit Params & Limits"
	NVAR UseGeneticOptimization = root:Packages:Irena_SAD:UseGeneticOptimization
	if(UseGeneticOptimization)
		SetDrawEnv fstyle=1, fsize=14
		DrawText 10, 50, "For Gen Opt. verify fitted parameters. Make sure"
		SetDrawEnv fstyle=1, fsize=14
		DrawText 10, 70, "the parameter range is appropriate."
		SetDrawEnv fstyle=1, fsize=14
		DrawText 10, 90, "The whole range must be valid! It will be tested!"
		SetDrawEnv fstyle=1, fsize=14
		DrawText 10, 110, "       Then continue....."
	else
		SetDrawEnv fstyle=1, fsize=14
		DrawText 17, 55, "Verify the list of fitted parameters."
		SetDrawEnv fstyle=1, fsize=14
		DrawText 17, 75, "        Then continue......"
	endif
	Button CancelBtn, pos={27, 420}, size={150, 20}, proc=IR2D_CheckFitPrmsButtonProc, title="Cancel fitting"
	Button ContinueBtn, pos={187, 420}, size={150, 20}, proc=IR2D_CheckFitPrmsButtonProc, title="Continue fitting"
	string fldrSav0 = GetDataFolder(1)
	SetDataFolder root:Packages:Irena_SAD:
	WAVE Gen_Constraints, W_coef
	WAVE/T CoefNames
	SetDimLabel 1, 0, Min, Gen_Constraints
	SetDimLabel 1, 1, Max, Gen_Constraints
	variable i
	for(i = 0; i < numpnts(CoefNames); i += 1)
		SetDimLabel 0, i, $(CoefNames[i]), Gen_Constraints
	endfor
	if(UseGeneticOptimization)
		Edit/HOST=#/W=(0.05, 0.25, 0.95, 0.865) Gen_Constraints.ld, W_coef
		//		ModifyTable format(Point)=1,width(Point)=0, width(Gen_Constraints)=110
		//		ModifyTable alignment(W_coef)=1,sigDigits(W_coef)=4,title(W_coef)="Curent value"
		//		ModifyTable alignment(Gen_Constraints)=1,sigDigits(Gen_Constraints)=4,title(Gen_Constraints)="Limits"
		//		ModifyTable statsArea=85
		ModifyTable format(Point)=1, width(Point)=0, alignment(W_coef.y)=1, sigDigits(W_coef.y)=4
		ModifyTable width(W_coef.y)=90, title(W_coef.y)="Start value", width(Gen_Constraints.l)=172
		//		ModifyTable title[1]="Min"
		//		ModifyTable title[2]="Max"
		ModifyTable alignment(Gen_Constraints.d)=1, sigDigits(Gen_Constraints.d)=4, width(Gen_Constraints.d)=72
		ModifyTable title(Gen_Constraints.d)="Limits"
		//		ModifyTable statsArea=85
		//		ModifyTable statsArea=20
	else
		Edit/W=(0.05, 0.18, 0.95, 0.865)/HOST=#CoefNames
		ModifyTable format(Point)=1, width(Point)=0, width(CoefNames)=144, title(CoefNames)="Fitted Coef Name"
		//		ModifyTable statsArea=85
	endif
	SetDataFolder fldrSav0
	RenameWindow #, T0
	SetActiveSubwindow ##
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_CheckFitPrmsButtonProc(ctrlName) : ButtonControl
	string ctrlName

	if(stringmatch(ctrlName, "*CancelBtn*"))
		variable/G root:Packages:Irena_SAD:UserCanceled = 1
		KillWIndow/Z IR2D_CheckFittingParams
	endif

	if(stringmatch(ctrlName, "*ContinueBtn*"))
		variable/G root:Packages:Irena_SAD:UserCanceled = 0
		KillWIndow/Z IR2D_CheckFittingParams
	endif

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_FitFunction(w, yw, xw) : FitFunc
	WAVE w, yw, xw

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD
	variable i

	WAVE/T CoefNames
	variable NumParams = numpnts(CoefNames)
	string ParamName

	for(i = 0; i < NumParams; i += 1)
		ParamName = CoefNames[i]
		NVAR TempVar = $(ParamName)
		TempVar = w[i]
	endfor
	IR2D_CalculateIntensity(1)
	Wave ModelQvector
	WAVE ModelIntensity
	//these above are in selected range in number of points, just in case the fitting asks different number of points number points. 
	//was: 
	//yw = ModelIntensity
	//iddoit proof? 
	yw = interp(xw[p],ModelQvector, ModelIntensity)

	setDataFolder oldDF
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_RecordResults(CalledFromWere)
	string CalledFromWere 
	//before or after - that means fit...

	DFREF oldDf = GetDataFolderDFR()

	setdataFolder root:Packages:Irena_SAD
	variable i, j
	IR1_CreateLoggbook() //this creates the logbook
	SVAR nbl = root:Packages:SAS_Modeling:NotebookName
	IR1L_AppendAnyText("     ")
	if(cmpstr(CalledFromWere, "before") == 0)
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Parameters before starting Small-angle diffraction on the data from: ")
		IR1_InsertDateAndTime(nbl)
	else //after
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Results of the Small-angle diffraction on the data from: ")
		IR1_InsertDateAndTime(nbl)
	endif
	SVAR   DataFolderName
	SVAR   IntensityWaveName
	SVAR   QWavename
	SVAR   ErrorWaveName
	NVAR/Z AchievedChiSq
	IR1L_AppendAnyText("Data folder    : " + DataFolderName)
	IR1L_AppendAnyText("Intensity     : " + IntensityWaveName)
	IR1L_AppendAnyText("Qvector     : " + QWavename)
	IR1L_AppendAnyText("Error     : " + ErrorWaveName)
	if(NVAR_Exists(AchievedChiSq))
		IR1L_AppendAnyText("Achieved chi^2     : " + num2str(AchievedChiSq))
	endif
	string ListOfVariables = "Background;RgPrefactor;Rg;PwrLawPref;PwrLawSlope;"
	for(j = 0; j < ItemsInList(ListOfVariables); j += 1)
		NVAR testVar = $(stringFromList(j, ListOfVariables))
		IR1L_AppendAnyText(stringFromList(j, ListOfVariables) + "    : " + num2str(testVar))
	endfor

	string tempName
	ListOfVariables = "PeakX_Par1;PeakX_Par2;PeakX_Par3;PeakX_Par4;PeakPositionX;PeakFWHMX;PeakIntgIntX;"
	for(i = 1; i <= 6; i += 1)
		NVAR Useme = $("usePeak" + num2str(i))
		if(UseMe)
			IR1L_AppendAnyText("******************")
			IR1L_AppendAnyText("Included peak number     : " + num2str(i))
			SVAR PeakFnct = $("Peak" + num2str(i) + "_Function")
			IR1L_AppendAnyText("Peak function     : " + PeakFnct)
			NVAR Peak_LinkPar2 = $("Peak" + num2str(i) + "_LinkPar2")
			if(Peak_LinkPar2)
				SVAR LinkedTo = $("Peak" + num2str(i) + "_LinkedTo")
				IR1L_AppendAnyText("Position of this peak was linked to      : " + LinkedTo)
			endif
			for(j = 0; j < ItemsInList(ListOfVariables); j += 1)
				tempName = ReplaceString("X", stringFromList(j, ListOfVariables), num2str(i))
				NVAR testVar = $(tempName)
				IR1L_AppendAnyText(tempName + "    : " + num2str(testVar))
			endfor
		endif
	endfor

	setdataFolder oldDf

End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR2D_ResetParamsAfterBadFit()

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD
	variable i
	WAVE/Z   w         = root:Packages:Irena_SAD:CoefficientInput
	WAVE/Z/T CoefNames = root:Packages:Irena_SAD:CoefNames //text wave with names of parameters

	if(!WaveExists(w) || !WaveExists(CoefNames))
		abort
	endif

	variable NumParams = numpnts(CoefNames)
	string ParamName

	for(i = 0; i < NumParams; i += 1)
		ParamName = CoefNames[i]
		NVAR TempVar = $(ParamName)
		TempVar = w[i]
	endfor

	IR2D_CalculateIntensity(1)

	setDataFolder oldDF
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_UpdatePeakParams()

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD
	variable i
	for(i = 1; i <= 6; i += 1)
		NVAR   usePk     = $("root:Packages:Irena_SAD:UsePeak" + num2str(i))
		WAVE/Z Intensity = $("Peak" + num2str(i) + "Intensity")
		WAVE/Z Qvec      = PeakModelQvector
		if(usePk && WaveExists(Intensity))
			NVAR PeakDPosition = $("PeakDPosition" + num2str(i))
			NVAR PeakPosition  = $("PeakPosition" + num2str(i))
			NVAR PeakFWHM      = $("PeakFWHM" + num2str(i))
			NVAR PeakIntgInt   = $("PeakIntgInt" + num2str(i))
			PeakIntgInt = areaXY(Qvec, Intensity)
			wavestats/Q Intensity
			PeakPosition  = Qvec[V_maxloc]
			PeakDPosition = 2 * pi / PeakPosition
			FindLevels/Q/N=2 Intensity, V_max / 2
			if(V_Flag==0)
				WAVE W_FindLevels
				PeakFWHM = abs(Qvec[W_FindLevels[1]] - Qvec[W_FindLevels[0]])
			else
				PeakFWHM = 0
			endif
		endif
	endfor

	setDataFolder oldDF
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_RemoveTagsFromGraph()

	variable i
	string   TagName
	for(i = 1; i <= 6; i += 1)
		TagName = "peakTag" + num2str(i)
		Tag/K/W=IR2D_LogLogPlotSAD/N=$(TagName)
	endfor

End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR2D_AppendTagsToGraph()

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:Irena_SAD
	variable i, LocationPnt
	string TagName, TagText
	for(i = 1; i <= 6; i += 1)
		NVAR   usePk = $("root:Packages:Irena_SAD:UsePeak" + num2str(i))
		WAVE/Z Qvec  = ModelQvector
		if(usePk)
			NVAR PeakDPosition = $("PeakDPosition" + num2str(i))
			NVAR PeakPosition  = $("PeakPosition" + num2str(i))
			NVAR PeakFWHM      = $("PeakFWHM" + num2str(i))
			NVAR PeakIntgInt   = $("PeakIntgInt" + num2str(i))
			TagName     = "peakTag" + num2str(i)
			LocationPnt = BinarySearch(Qvec, PeakPosition)
			TagText     = "\\Z" + IN2G_LkUpDfltVar("TagSize") + "Peak number " + num2str(i) + "\r"
			TagText    += "Peak Position (d) = " + num2str(PeakDPosition) + "  [A]\r"
			TagText    += "Peak Position (Q) = " + num2str(PeakPosition) + "  [A^-1]\r"
			TagText    += "Peak Integral intensity = " + num2str(PeakIntgInt) + "\r"
			TagText    += "Peak FWHM (Q) = " + num2str(PeakFWHM) + " [A^-1]"
			Tag/C/W=IR2D_LogLogPlotSAD/N=$(TagName)/F=0/L=2/TL=0 ModelIntensity, LocationPnt, TagText

		endif
	endfor

	setDataFolder oldDF
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
