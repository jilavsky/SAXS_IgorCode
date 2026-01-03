#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma version=1.02

//*************************************************************************\
//* Copyright (c) 2005 - 2026, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution.
//*************************************************************************/

//1.02 fix Intensity plotting scaling.
//1.01 modified GSR generation to use MatrixOp and time to calculate (50x50x50) went from 30+ sec to 4.
//1.00 first version, added code for Two Phase solid based on
//Bridget Ingham, Haiyong Li, Emily L. Allen and Michael F. Toney, SAXSMorph program with manuscript: J. Appl. Cryst. (2011). 44, 221–224, doi:10.1107/S0021889810048557
//and
//John A Quintanilla, Jordan T Chen, Richard F Reidy and Andrew J Allen Modelling Simul. Mater. Sci. Eng. 15 (2007) S337–S351, doi:10.1088/0965-0393/15/4/S02

//constant useSAXSMorphCode = 0

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//			3D packages, 2018-12-26
//******************************************************************************************************************************************************

Function IR3T_TwoPhaseSystem()
	//this calls GUI controlling code for two-phase solid, acrding to what SAXSMorph and otherpackages are doing.
	DoWIndow TwoPhaseSystems
	if(V_Flag)
		DoWIndow/K TwoPhaseSystems
	endif
	IN2G_CheckScreenSize("height", 670)
	IR3T_InitializeTwoPhaseSys()
	IR3T_TwoPhaseControlPanel()
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("TwoPhaseSystems", IR3TTwoPhaseVersionNumber, 1)
	IR3T_FixTabsInPanel()
End

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//			Two Phase system - typically Porosu media modeling.
//*****************************************************************************************************************
////	ListOfVariables="BoxSideSize;BoxResolution;Porosity;Invariant;ScatteringContrast;SurfaceToVolumeRatio;CalculatePorosityFromInvariant;"
////	ListOfVariables+="NumberofRPoints;NumberOfKPoints;Kmin;Kmax;Rmin;Rmax;RKlogSpaced;TotalNumberOfVoxels;"

////	ListOfVariables+="LowQExtrapolationMin;LowQExtrapolationStart;LowQExtrapolationEnd;HighQExtrapolationEnd;HighQExtrapolationStart;HighQExtrapolationMax;"
////	ListOfVariables+="PorodConstant;Background;"
////	ListOfStrings="LowQExtrapolationMethod;"
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3T_TwoPhaseControlPanel()
	PauseUpdate // building window...
	NewPanel/K=1/W=(2.25, 43.25, 396, 720)/N=TwoPhaseSystems as "Two Phase 3D modeling"
	//DefaultGUIControls /W=TwoPhaseSystems ///Mac os9
	string UserDataTypes  = ""
	string UserNameString = ""
	string XUserLookup    = "r*:q*;"
	string EUserLookup    = "r*:s*;"
	IR2C_AddDataControls("TwoPhaseSolidModel", "TwoPhaseSystems", "DSM_Int;M_DSM_Int;", "", UserDataTypes, UserNameString, XUserLookup, EUserLookup, 1, 0)
	//CheckBox UseModelData disable=3

	//SetVariable RebinDataTo,limits={0,1000,0},variable= root:Packages:TwoPhaseSolidModel:RebinDataTo, noproc
	//SetVariable RebinDataTo,pos={290,130},size={100,15},title="Rebin to:", help={"To rebin data on import, set to integer number. 0 means no rebinning. "}
	TitleBox MainTitle, title="\Zr200Two Phase 3D modeling", pos={20, 0}, frame=0, fstyle=3, fixedSize=1, font="Times New Roman", size={350, 24}, anchor=MC, fColor=(0, 0, 52224)
	TitleBox Info1, title="\Zr150Data input", pos={10, 30}, frame=0, fstyle=1, fixedSize=1, size={80, 20}, fColor=(0, 0, 52224)
	Button DrawGraphs, pos={225, 158}, size={150, 20}, proc=IR3T_TwoPhaseButtonProc, title="Graph data", help={"Create a graph (log-log) of your experiment data"}
	Button GetHelp, pos={305, 105}, size={80, 15}, fColor=(65535, 32768, 32768), proc=IR3T_TwoPhaseButtonProc, title="Get Help", help={"Open www manual page for this tool"} //<<< fix button to help!!!
	TitleBox FakeLine1, title=" ", fixedSize=1, size={330, 3}, pos={16, 181}, frame=0, fColor=(0, 0, 52224), labelBack=(0, 0, 52224)
	TitleBox Info2, title="\Zr150Model input", pos={10, 185}, frame=0, fstyle=2, fixedSize=1, size={150, 20}

	CheckBox CalculatePorosityFromInvariant, pos={180, 185}, size={250, 14}, proc=IR3T_InputPanelCheckboxProc, title="Calculate Porosity from Invariant"
	CheckBox CalculatePorosityFromInvariant, variable=root:packages:TwoPhaseSolidModel:CalculatePorosityFromInvariant, help={"For calibrated data and contrast - calculate porosity from invariant"}

	SetVariable Porosity, limits={0.001, 1, 0}, value=root:Packages:TwoPhaseSolidModel:Porosity //proc=IR1A_PanelSetVarProc
	SetVariable Porosity, pos={10, 215}, size={190, 16}, title="Porosity fraction (0-0.5)", noproc, help={"Minority phase as fract (0-0.5), corrected for phi*(1-phi), so correct voluem fraction"}

	SetVariable ScatteringContrast, limits={0, Inf, 0}, value=root:Packages:TwoPhaseSolidModel:ScatteringContrast //proc=IR1A_PanelSetVarProc
	SetVariable ScatteringContrast, pos={10, 240}, size={190, 16}, title="Scattering contrast      ", noproc, help={"Contrast to calculate minoritpy phase colume fraction"}

	SetVariable Invariant, limits={0, Inf, 0}, value=root:Packages:TwoPhaseSolidModel:Invariant, noedit=1, frame=0, format="%2.2e" //proc=IR1A_PanelSetVarProc
	SetVariable Invariant, pos={230, 210}, size={150, 16}, title="Invariant       ", noproc, help={"Invariant, calculated from extrapolated data when possible"}

	SetVariable PorodConstant, limits={0, Inf, 0}, value=root:Packages:TwoPhaseSolidModel:PorodConstant, noedit=1, frame=0, format="%2.2e" //proc=IR1A_PanelSetVarProc
	SetVariable PorodConstant, pos={230, 230}, size={150, 16}, title="Porod Constant ", noproc, help={"PorodConstant, calculated from extrapolated data when possible"}

	SetVariable SurfaceToVolumeRatio, limits={0, Inf, 0}, value=root:Packages:TwoPhaseSolidModel:SurfaceToVolumeRatio, noedit=1, frame=0, format="%2.2e" //proc=IR1A_PanelSetVarProc
	SetVariable SurfaceToVolumeRatio, pos={230, 250}, size={150, 16}, title="Surf/Vol Ratio", noproc, help={"Surface To VolumeRatio, calculated from extrapolated data when possible"}

	SetVariable BoxSideSize, limits={100, 100000, 50}, value=root:Packages:TwoPhaseSolidModel:BoxSideSize, proc=IR3T_SetVarProc
	SetVariable BoxSideSize, pos={10, 265}, size={200, 16}, title="Box Physical size [A] ", help={"Physical size of the box for modeling in Angstroms"}

	//	SetVariable BoxResolution,limits={10,500,50},proc=IR3T_SetVarProc, value= root:Packages:TwoPhaseSolidModel:BoxResolution
	//	SetVariable BoxResolution,pos={10,290},size={200,16},title="Box divisions           ", help={"How many steps per side to take"}
	NVAR BoxResolution = root:Packages:TwoPhaseSolidModel:BoxResolution
	PopupMenu BoxResolution, pos={20, 290}, size={180, 21}, proc=IR3T_PopupControl, title="Box divisions : ", help={"Select how many divisions per side"}
	PopupMenu BoxResolution, mode=1, value="64x64x64;128x128x128;256x256x256;512x512x512;"
	BoxResolution = 64

	SetVariable VoxelResolution, limits={0, Inf, 0}, value=root:Packages:TwoPhaseSolidModel:VoxelResolution, noedit=1, frame=0 //proc=IR1A_PanelSetVarProc
	SetVariable VoxelResolution, pos={230, 270}, size={200, 16}, title="Voxels size [A] ", noproc, help={"How big is each voxels in box = model resolution"}

	SetVariable TotalNumberOfVoxels, limits={0, Inf, 0}, value=root:Packages:TwoPhaseSolidModel:TotalNumberOfVoxels, noedit=1, frame=0, format="%2.2e" //proc=IR1A_PanelSetVarProc
	SetVariable TotalNumberOfVoxels, pos={230, 290}, size={200, 16}, title="No of Voxels ", noproc, help={"How many voxels is in box, impacts speed!"}

	//CheckBox useSAXSMorphCode,pos={100,310},size={250,14},proc=IR3T_InputPanelCheckboxProc,title="use SAXSMorph code (slower)"
	//CheckBox useSAXSMorphCode,variable=root:Packages:TwoPhaseSolidModel:useSAXSMorphCode, help={"To use GRF generation using SAXSMorph method"}

	//Dist Tabs definition
	TabControl TwoPhaseModelTabs, pos={5, 330}, size={370, 280}, proc=IR3T_TwoPhaseTabProc
	TabControl TwoPhaseModelTabs, tabLabel(0)="1. Extrapolate ", tabLabel(1)="2. Advanced Pars ", tabLabel(2)="3. Results "

	Button CalculateRg, pos={100, 355}, size={150, 20}, proc=IR3T_TwoPhaseButtonProc, title="Calculate Rg", help={"Set cursors and calculate Rg fro main feature"}
	SetVariable RgValue, limits={0, Inf, 0}, value=root:Packages:TwoPhaseSolidModel:RgValue, noedit=1, frame=0
	SetVariable RgValue, pos={120, 380}, size={220, 16}, title="Rg value [A] ", noproc, help={"Rg Value for main feature"}

	SVAR LowQExtrapolationMethod = root:Packages:TwoPhaseSolidModel:LowQExtrapolationMethod
	PopupMenu LowQExtrapolationMethod, pos={20, 410}, size={380, 21}, proc=IR3T_TwoPhasePopMenuProc, title="Low-Q Extrapolation method :", help={"Select method to extrapolate low-q data "}
	PopupMenu LowQExtrapolationMethod, mode=2, popvalue=LowQExtrapolationMethod, value=#"\"Constant;Linear;\""
	Button ExtrapolateLowQ, pos={100, 435}, size={150, 20}, proc=IR3T_TwoPhaseButtonProc, title="Extrapolate low-Q", help={"Set cursors and extrapolate low-q"}
	SetVariable LowQExtrapolationStart, limits={0, Inf, 0}, value=root:Packages:TwoPhaseSolidModel:LowQExtrapolationStart, noedit=1, frame=0
	SetVariable LowQExtrapolationStart, pos={15, 465}, size={180, 16}, title="Start LowQ extrap ", noproc, help={"Start lowQ extrapolation"}
	SetVariable LowQExtrapolationEnd, limits={0, Inf, 0}, value=root:Packages:TwoPhaseSolidModel:LowQExtrapolationEnd, noedit=1, frame=0
	SetVariable LowQExtrapolationEnd, pos={215, 465}, size={180, 16}, title="End LowQ extrap ", noproc, help={"End lowQ extrapolation"}

	Button ExtrapolateHighQ, pos={100, 495}, size={150, 20}, proc=IR3T_TwoPhaseButtonProc, title="Extrapolate high-Q", help={"Set cursors and extrapolate high-q"}
	SetVariable HighQExtrapolationStart, limits={0, Inf, 0}, value=root:Packages:TwoPhaseSolidModel:HighQExtrapolationStart, noedit=1, frame=0
	SetVariable HighQExtrapolationStart, pos={15, 525}, size={180, 16}, title="Start HighQ extrap ", noproc, help={"Start highQ extrapolation"}
	SetVariable HighQExtrapolationEnd, limits={0, Inf, 0}, value=root:Packages:TwoPhaseSolidModel:HighQExtrapolationEnd, noedit=1, frame=0
	SetVariable HighQExtrapolationEnd, pos={215, 525}, size={180, 16}, title="End HighQ extrap ", noproc, help={"End highQ extrapolation"}

	Button CalculateParameters, pos={100, 565}, size={150, 20}, proc=IR3T_TwoPhaseButtonProc, title="Calculate Params", help={"Calculate Invariant and S/V ratio. Sets Rmax and Rmin."}

	//these are advanced parameters. Need to move to Tab 2...
	CheckBox RKParametersManual, pos={100, 355}, size={200, 14}, proc=IR3T_InputPanelCheckboxProc, title="Manual R/K parameters?"
	CheckBox RKParametersManual, variable=root:packages:TwoPhaseSolidModel:RKParametersManual, help={"Check to select manually R/K parameetrs below. "}
	SetVariable NumberofRPoints, limits={100, 10000, 50}, value=root:Packages:TwoPhaseSolidModel:NumberofRPoints
	SetVariable NumberofRPoints, pos={15, 375}, size={170, 16}, title="R vector points ", noproc, help={"Number of points on R vector"}
	//	CheckBox RKlogSpaced,pos={220,375},size={250,14},proc=IR3T_InputPanelCheckboxProc,title="R/K vectors log-spaced?"
	//	CheckBox RKlogSpaced,variable= root:packages:TwoPhaseSolidModel:RKlogSpaced, help={"Use K vector with log-R binning, Not sure how useful this is. "}
	SetVariable Rmin, limits={0.1, 50, 0}, value=root:Packages:TwoPhaseSolidModel:Rmin
	SetVariable Rmin, pos={15, 400}, size={150, 16}, title="Rmin ", noproc, help={"Minimum of R vector"}
	SetVariable Rmax, limits={50, 1000000, 0}, value=root:Packages:TwoPhaseSolidModel:Rmax
	SetVariable Rmax, pos={220, 400}, size={150, 16}, title="Rmax ", noproc, help={"Maximum value of R vector"}
	SetVariable NumberOfKPoints, limits={100, 10000, 0}, value=root:Packages:TwoPhaseSolidModel:NumberOfKPoints
	SetVariable NumberOfKPoints, pos={15, 445}, size={170, 16}, title="K vector points ", noproc, help={"Number of points on K vector"}
	SetVariable Kmin, limits={0.0001, 1, 0}, value=root:Packages:TwoPhaseSolidModel:Kmin
	SetVariable Kmin, pos={15, 470}, size={100, 16}, title="Kmin ", noproc, help={"Minimum of K vector"}
	SetVariable Kmax, limits={1, 50, 0}, value=root:Packages:TwoPhaseSolidModel:Kmax
	SetVariable Kmax, pos={220, 470}, size={100, 16}, title="Kmax ", noproc, help={"Maximum of K vector"}

	SetVariable LowQExtrapolationMin, limits={1e-8, 1e-2, 0}, value=root:Packages:TwoPhaseSolidModel:LowQExtrapolationMin, noproc
	SetVariable LowQExtrapolationMin, pos={20, 510}, size={220, 16}, title="Low-Q extrapolation Qmin ", help={"Which low-q should code strapolate to (1e-5)"}
	SetVariable HighQExtrapolationMax, limits={1e-8, 1e-2, 0}, value=root:Packages:TwoPhaseSolidModel:HighQExtrapolationMax, noproc
	SetVariable HighQExtrapolationMax, pos={20, 535}, size={220, 16}, title="High-Q extrapolation Qmax ", help={"Which high-q should code strapolate to (50)"}

	//tab 3
	Button Display1DtempData, pos={100, 370}, size={200, 15}, proc=IR3T_TwoPhaseButtonProc, title="Display 1D temp data", help={"Create graphs of 1D transitional data."}
	Button Calc1DTwoPhaseSys, pos={100, 410}, size={200, 20}, proc=IR3T_TwoPhaseButtonProc, title="Calculate 1D", help={"Calculate 1D data using Two Phase Correlation Function."}
	Button Display2DView, pos={100, 460}, size={200, 20}, proc=IR3T_TwoPhaseButtonProc, title="Display 2D view", help={"Create 2D display of 3D data."}
	Button Generate3DView, pos={100, 510}, size={200, 20}, proc=IR3T_TwoPhaseButtonProc, title="Display 3D view", help={"Create 3D display using Gizmo. "}
	CheckBox GizmoFillSolid, pos={50, 540}, size={130, 14}, proc=IR3T_InputPanelCheckboxProc, title="3D fill Solid?"
	CheckBox GizmoFillSolid, variable=root:packages:TwoPhaseSolidModel:GizmoFillSolid, help={"Check to  fill solid phase in Gizmo 3D. "}

	//bottom controls
	Button Generate3DModel, pos={100, 620}, size={200, 25}, proc=IR3T_TwoPhaseButtonProc, title="Generate 3D model", help={"Create 3D model using parameters above. "}, disable=2, fColor=(43690, 43690, 43690)
	SetVariable AchievedVolumeFraction, limits={0, Inf, 0}, value=root:Packages:TwoPhaseSolidModel:AchievedVolumeFraction, noedit=1, frame=0
	SetVariable AchievedVolumeFraction, pos={15, 650}, size={230, 16}, title="Achieved Porosity ", noproc, help={"3D data achieved porosity value"}, disable=2

	IR3T_SetControlsInPanel()
End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
///******************************************************************************************

Function IR3T_FixTabsInPanel()
	//here we modify the panel, so it reflects the selected number of distributions

	//NVAR NumOfDist=root:Packages:Irena_UnifFit:NumberOfLevels
	//and now return us back to original tab...
	//NVAR ActTab=root:Packages:Irena_UnifFit:ActiveTab
	//if(numtype(ActTab)!=0)
	//	ActTab = 1
	//endif
	STRUCT WMTabControlAction tca
	tca.eventCode = 2
	tca.tab       = 0
	TabControl TwoPhaseModelTabs, value=0, win=TwoPhaseSystems
	IR3T_TwoPhaseTabProc(tca)
End

//******************************************************************************************************************************************************

Function IR3T_PopupControl(PU_Struct) : PopupMenuControl
	STRUCT WMPopupAction &PU_Struct

	if(PU_Struct.eventCode == 2)
		NVAR BoxResolution   = root:Packages:TwoPhaseSolidModel:BoxResolution
		NVAR VoxelResolution = root:Packages:TwoPhaseSolidModel:VoxelResolution
		NVAR BoxSideSize     = root:Packages:TwoPhaseSolidModel:BoxSideSize
		NVAR Voxels          = root:Packages:TwoPhaseSolidModel:TotalNumberOfVoxels
		//"64x64x64;128x128x128;256x256x256;512x512x512;"
		BoxResolution   = str2num(PU_Struct.popStr)
		Voxels          = BoxResolution^3
		VoxelResolution = BoxSideSize / BoxResolution
	endif

End

//******************************************************************************************************************************************************
///******************************************************************************************
Function IR3T_TwoPhaseTabProc(tca) : TabControl
	STRUCT WMTabControlAction &tca

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:TwoPhaseSolidModel
	switch(tca.eventCode)
		case 2: // mouse up
			NVAR RKPars = root:packages:TwoPhaseSolidModel:RKParametersManual
			variable RKParsShow
			variable tab = tca.tab

			Button CalculateParameters, win=TwoPhaseSystems, disable=(tab != 0)
			Button CalculateRg, win=TwoPhaseSystems, disable=(tab != 0)
			SetVariable RgValue, win=TwoPhaseSystems, disable=(tab != 0)
			PopupMenu LowQExtrapolationMethod, win=TwoPhaseSystems, disable=(tab != 0)
			Button ExtrapolateLowQ, win=TwoPhaseSystems, disable=(tab != 0)
			SetVariable LowQExtrapolationStart, win=TwoPhaseSystems, disable=(tab != 0)
			SetVariable LowQExtrapolationEnd, win=TwoPhaseSystems, disable=(tab != 0)
			Button ExtrapolateHighQ, win=TwoPhaseSystems, disable=(tab != 0)
			SetVariable HighQExtrapolationStart, win=TwoPhaseSystems, disable=(tab != 0)
			SetVariable HighQExtrapolationEnd, win=TwoPhaseSystems, disable=(tab != 0)

			//tab 2
			CheckBox RKParametersManual, win=TwoPhaseSystems, disable=(tab != 1)
			if(tab == 1)
				if(RKPars)
					RKParsShow = 0
				else
					RKParsShow = 2
				endif
			else
				RKParsShow = 1
			endif
			SetVariable NumberofRPoints, win=TwoPhaseSystems, disable=RKParsShow
			//CheckBox RKlogSpaced, win=TwoPhaseSystems, disable=RKParsShow
			SetVariable Rmin, win=TwoPhaseSystems, disable=RKParsShow
			SetVariable Rmax, win=TwoPhaseSystems, disable=RKParsShow
			SetVariable NumberOfKPoints, win=TwoPhaseSystems, disable=RKParsShow
			SetVariable Kmin, win=TwoPhaseSystems, disable=RKParsShow
			SetVariable Kmax, win=TwoPhaseSystems, disable=RKParsShow
			SetVariable LowQExtrapolationMin, win=TwoPhaseSystems, disable=RKParsShow
			SetVariable HighQExtrapolationMax, win=TwoPhaseSystems, disable=RKParsShow

			//tab 3
			Button Display1DtempData, win=TwoPhaseSystems, disable=(tab != 2)
			Button Calc1DTwoPhaseSys, win=TwoPhaseSystems, disable=(tab != 2)
			Button Display2DView, win=TwoPhaseSystems, disable=(tab != 2)
			Button Generate3DView, win=TwoPhaseSystems, disable=(tab != 2)
			CheckBox GizmoFillSolid, win=TwoPhaseSystems, disable=(tab != 2)

			break
		case -1: // control being killed
			break
	endswitch

	setDataFolder oldDF
	return 0
End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

Function IR3T_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch(sva.eventCode)
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			variable dval = sva.dval
			string   sval = sva.sval
			if(StringMatch(sva.ctrlName, "BoxResolution") || StringMatch(sva.ctrlName, "BoxSideSize"))
				NVAR VoxelResolution = root:Packages:TwoPhaseSolidModel:VoxelResolution
				NVAR BoxSideSize     = root:Packages:TwoPhaseSolidModel:BoxSideSize
				NVAR Steps           = root:Packages:TwoPhaseSolidModel:BoxResolution
				NVAR Voxels          = root:Packages:TwoPhaseSolidModel:TotalNumberOfVoxels
				Voxels          = Steps^3
				VoxelResolution = BoxSideSize / Steps
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3T_TwoPhasePopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch(pa.eventCode)
		case 2: // mouse up
			variable popNum = pa.popNum
			string   popStr = pa.popStr
			if(StringMatch(pa.ctrlName, "LowQExtrapolationMethod"))
				SVAR LowQExtrapolationMethod = root:packages:TwoPhaseSolidModel:LowQExtrapolationMethod
				LowQExtrapolationMethod = popStr
			endif

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

Function IR3T_TwoPhaseButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch(ba.eventCode)
		case 2: // mouse up
			// click code here
			DFREF oldDf = GetDataFolderDFR()

			setDataFolder root:Packages:TwoPhaseSolidModel

			if(cmpstr(ba.ctrlName, "DrawGraphs") == 0)
				//here goes what is done, when user pushes Graph button
				KillWIndow/Z TwoPhaseSystemData
				KillWIndow/Z TwoPhaseSolidGizmo
				KillWIndow/Z TwoPhaseSolid2DImage
				SVAR     DFloc         = root:Packages:TwoPhaseSolidModel:DataFolderName
				SVAR     DFInt         = root:Packages:TwoPhaseSolidModel:IntensityWaveName
				SVAR     DFQ           = root:Packages:TwoPhaseSolidModel:QWaveName
				SVAR     DFE           = root:Packages:TwoPhaseSolidModel:ErrorWaveName
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
					IR3T_FixTabsInPanel()
					IR3T_CopyAndGraphInputData()
					MoveWindow/W=TwoPhaseSystemData 0, 0, (IN2G_GetGraphWidthHeight("width")), (0.6 * IN2G_GetGraphWidthHeight("height"))
					AutoPositionWIndow/M=0/R=TwoPhaseSystems TwoPhaseSystemData
				else
					Abort "Data not selected properly"
				endif
			endif

			if(StringMatch(ba.ctrlName, "CalculateRg"))
				IR3T_CalculateRg()
			endif
			if(StringMatch(ba.ctrlName, "ExtrapolateLowQ"))
				IR3T_ExtrapolateLowQ()
			endif
			if(StringMatch(ba.ctrlName, "ExtrapolateHighQ"))
				IR3T_ExtrapolateHighQ()
			endif
			if(StringMatch(ba.ctrlName, "Calc1DTwoPhaseSys"))
				IR3T_Calc1DSASData()
			endif
			if(StringMatch(ba.ctrlName, "GetHelp"))
				//Open www manual with the right page
				IN2G_OpenWebManual("Irena/TwoPhaseSolid.html")
			endif
			if(StringMatch(ba.ctrlName, "Generate3DModel"))
				KillWIndow/Z TwoPhaseSolid2DImage
				KillWIndow/Z TwoPhaseSolid3D
				IR3T_GenerateTwoPhaseSolid()
				//This thing does not work - we always get scattering from the box size, not from internal strucutre. So this is probably not realistic to do...
				//IR3T_CreatePDF(TwoPhaseSolidMatrix,VoxelSize, NumStepsToUse, 0.5, oversample, 0.001, 0.5, 200)
				//IR3T_AppendModelIntToGraph()
				IR3T_CalculateAchievedValues()
			endif
			if(StringMatch(ba.ctrlName, "Generate3DView"))
				IR3T_TwoPhaseSolidGizmo()
			endif
			if(StringMatch(ba.ctrlName, "Display2DView"))
				IR3T_TwoPhaseSolid2DImage()
			endif

			if(StringMatch(ba.ctrlName, "Display1DtempData"))
				IR3T_Display1DTempData()
			endif

			if(StringMatch(ba.ctrlName, "CalculateParameters"))
				IR3T_ExtendDataCalcParams()
			endif

			setDataFolder oldDF
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

Function IR3T_Calc1DSASData()

	WAVE My3DWv = root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrix
	//note, assumes My3DWave has proper x scaling to indicate voxelsize in A.
	//this does not work for 3D solid, since it gives scattering from external box size...
	//use this for Fractal aggregate and not for 3D solid...
	//IR3T_CreatePDFIntensity(My3DWv, 0.5, 0.001, 0.5, 200)
	//these are PDF distance calculation results
	//Wave PDFIntensityWv
	//wave PDFQWv
	IR3T_CalcAutoCorelIntensity(My3DWv, 0.001, 0.5, 200)
	//these are autocorrelation calculated intensities...
	WAVE AutoCorIntensity
	WAVE AutoCorQWv

	NVAR     BoxSideSize   = root:Packages:TwoPhaseSolidModel:BoxSideSize   //Box size in Angstroms
	NVAR     BoxResolution = root:Packages:TwoPhaseSolidModel:BoxResolution // typically 50 divisions on each side, Voxel size is BoxSideSize/BoxResolution
	variable VoxelSize     = BoxSideSize / BoxResolution                    // voxel size in Angstroms
	NVAR     Rmax          = root:Packages:TwoPhaseSolidModel:Rmax
	NVAR     HighQStart    = root:Packages:TwoPhaseSolidModel:HighQExtrapolationStart
	NVAR     HighQEnd      = root:Packages:TwoPhaseSolidModel:HighQExtrapolationEnd
	//print HighQEnd
	//print 2*pi/BoxResolution
	variable MaxMeaningfulQmax = min(2 * pi / VoxelSize, HighQStart)
	variable MinMeaningfulQmin = 2 * pi / BoxSideSize
	//TheoreticalIntensityDACF
	variable MaxMeaningfulPnt = BinarySearch(AutoCorQWv, MaxMeaningfulQmax)
	if(MaxMeaningfulPnt > 0)
		AutoCorIntensity[MaxMeaningfulPnt, numpnts(AutoCorIntensity) - 1] = NaN
	endif
	AutoCorIntensity[0, MinMeaningfulQmin] = NaN
	IN2G_RemoveNaNsFrom2Waves(AutoCorIntensity, AutoCorQWv)

	WAVE     OriginalIntensity = root:Packages:TwoPhaseSolidModel:OriginalIntensity
	WAVE     OriginalQvector   = root:Packages:TwoPhaseSolidModel:OriginalQvector
	variable IntgInt           = areaXY(OriginalQvector, OriginalIntensity, MinMeaningfulQmin, MaxMeaningfulQmax)
	variable ModelIntgInt      = areaXY(AutoCorQWv, AutoCorIntensity)
	AutoCorIntensity *= IntgInt / ModelIntgInt

	DOWIndow TwoPhaseSystemData
	if(V_Flag)
		DoWIndow/F TwoPhaseSystemData
		//CheckDisplayed /W=TwoPhaseSystemData PDFIntensityWv
		//if(V_flag==0)
		//	AppendToGraph/W=TwoPhaseSystemData/R  PDFIntensityWv vs PDFQWv
		//endif
		CheckDisplayed/W=TwoPhaseSystemData AutoCorIntensity
		if(V_flag == 0)
			AppendToGraph/W=TwoPhaseSystemData AutoCorIntensity vs AutoCorQWv
		endif
		//ModifyGraph lstyle(PDFIntensityWv)=9,lsize(PDFIntensityWv)=3,rgb(PDFIntensityWv)=(1,16019,65535)
		//ModifyGraph mode(PDFIntensityWv)=4,marker(PDFIntensityWv)=19
		//ModifyGraph msize(PDFIntensityWv)=3
		ModifyGraph lsize(AutoCorIntensity)=3, rgb(AutoCorIntensity)=(3, 52428, 1)
	endif

End

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3T_SetControlsInPanel()

	DoWIndow TwoPhaseSystems
	if(V_Flag)
		DoWIndow/F TwoPhaseSystems
		NVAR CalcPor = root:packages:TwoPhaseSolidModel:CalculatePorosityFromInvariant
		SetVariable Porosity, disable=2 * CalcPor
		SetVariable ScatteringContrast, disable=abs(2 * (CalcPor - 1))

		ControlInfo/W=TwoPhaseSystems TwoPhaseModelTabs
		//this sets the tab content right...
		//TabControl TwoPhaseModelTabs, win=TwoPhaseSystems, value=0
		STRUCT WMTabControlAction tca
		tca.tab       = V_Value
		tca.eventcode = 2
		IR3T_TwoPhaseTabProc(tca)
	endif

End

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

Function IR3T_InputPanelCheckboxProc(ctrlName, checked) : CheckBoxControl
	string   ctrlName
	variable checked
	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:TwoPhaseSolidModel
	if(stringMatch(ctrlName, "CalculatePorosityFromInvariant"))
		IR3T_SetControlsInPanel()
	endif
	if(stringMatch(ctrlName, "RKParametersManual"))
		IR3T_SetControlsInPanel()
	endif
	if(stringMatch(ctrlName, "GizmoFillSolid"))
		IR3T_FixGizmoDisplay()
	endif

	setDataFolder oldDF
End

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3T_ExtrapolatelowQ()
	//we will extrapolate low-q with method picked by user...

	DoWindow TwoPhaseSystemData
	if(V_Flag)
		DFREF oldDf = GetDataFolderDFR()

		setDataFolder root:Packages:TwoPhaseSolidModel
		//check is cursors are set, if not, ask user to set tehm
		if(strlen(CsrWave(A)) == 0 || strlen(CsrWave(B)) == 0)
			beep
			abort "Select range fo data to use using Cursors A and B in the graph, set on wave Experimental Intensity"
		endif
		SVAR lowQExtrapolationMethod = root:Packages:TwoPhaseSolidModel:lowQExtrapolationMethod
		WAVE OriginalIntensity       = root:Packages:TwoPhaseSolidModel:OriginalIntensity
		WAVE OriginalQvector         = root:Packages:TwoPhaseSolidModel:OriginalQvector
		WAVE OriginalError           = root:Packages:TwoPhaseSolidModel:OriginalError
		NVAR lowQExtrapolationStart  = root:Packages:TwoPhaseSolidModel:lowQExtrapolationStart
		NVAR lowQExtrapolationEnd    = root:Packages:TwoPhaseSolidModel:lowQExtrapolationEnd
		NVAR lowQExtrapolationMin    = root:Packages:TwoPhaseSolidModel:lowQExtrapolationMin
		//now get the start and end, make sure they are in proper order, just on case...
		variable CursorQstart = OriginalQvector[pcsr(A, "TwoPhaseSystemData")]
		variable CursorQend   = OriginalQvector[pcsr(B, "TwoPhaseSystemData")]
		if(CursorQstart < CursorQend)
			lowQExtrapolationStart = CursorQstart
			lowQExtrapolationEnd   = CursorQend
		else
			lowQExtrapolationStart = CursorQend
			lowQExtrapolationEnd   = CursorQstart
		endif
		//make the wave for extrapolated data
		make/O/N=100/D lowQExtrapolatedIntensity, lowQExtrapolatedQvector
		lowQExtrapolatedQvector = 10^(log(lowQExtrapolationMin) + p * ((log(lowQExtrapolationStart) - log(lowQExtrapolationMin)) / (100 - 1))) //sets k scaling on log-scale...
		//now lets get the proper values we need...
		if(StringMatch(lowQExtrapolationMethod, "Constant"))
			//this is easy...
			WaveStats/R=[pcsr(A, "TwoPhaseSystemData"), pcsr(B, "TwoPhaseSystemData")] OriginalIntensity
			lowQExtrapolatedIntensity = V_avg
		elseif(StringMatch(lowQExtrapolationMethod, "Linear"))
			CurveFit line, OriginalIntensity[pcsr(A), pcsr(B)]/X=OriginalQvector/W=OriginalError/I=1/D
			WAVE W_coef
			lowQExtrapolatedIntensity = W_coef[0] + W_coef[1] * lowQExtrapolatedQvector[p]
			WaveStats/Q lowQExtrapolatedIntensity
			if(V_min < 0)
				DoAlert/T="Extrapolation failed" 0, "Extrapolation gave negative intensities. This is error. Try again."
				lowQExtrapolatedIntensity = 0
			endif
		endif
		GetAxis/W=TwoPhaseSystemData/Q bottom
		variable MinXAxis = V_min
		variable MaxXaxis = V_max

		//OK, and now append to the graph
		CheckDisplayed/W=TwoPhaseSystemData lowQExtrapolatedIntensity
		if(!V_flag)
			AppendToGraph/W=TwoPhaseSystemData lowQExtrapolatedIntensity vs lowQExtrapolatedQvector
		endif
		ModifyGraph/W=TwoPhaseSystemData lstyle(lowQExtrapolatedIntensity)=4, rgb(lowQExtrapolatedIntensity)=(0, 0, 0)
		SetAxis/W=TwoPhaseSystemData bottom, MinXAxis, MaxXaxis
		//and now set the Kimn and Rmax based on Q used for extrapolation.
		NVAR Rmax = root:Packages:TwoPhaseSolidModel:Rmax
		NVAR Rmin = root:Packages:TwoPhaseSolidModel:Rmin
		NVAR Kmin = root:Packages:TwoPhaseSolidModel:Kmin
		NVAR Kmax = root:Packages:TwoPhaseSolidModel:Kmax
		//this is close to formula from SAXSMorph manual...
		//Rmax = 5*2*pi/(lowQExtrapolationEnd)
		Kmin = lowQExtrapolationEnd / 10
		setDataFolder oldDF
	endif

End
///******************************************************************************************
///******************************************************************************************
Function IR3T_CalculateRg()
	//we will Calculate Rg value from cursors set by user...

	DoWindow TwoPhaseSystemData
	if(V_Flag)
		DFREF oldDf = GetDataFolderDFR()

		setDataFolder root:Packages:TwoPhaseSolidModel
		//check is cursors are set, if not, ask user to set tehm
		if(strlen(CsrWave(A)) == 0 || strlen(CsrWave(B)) == 0)
			beep
			abort "Select range fo data to use using Cursors A and B in the graph, set on wave Experimental Intensity"
		endif
		WAVE OriginalIntensity = root:Packages:TwoPhaseSolidModel:OriginalIntensity
		WAVE OriginalQvector   = root:Packages:TwoPhaseSolidModel:OriginalQvector
		//Wave OriginalError = root:Packages:TwoPhaseSolidModel:OriginalError
		WAVE/Z ErrorWave = root:Packages:TwoPhaseSolidModel:OriginalError
		NVAR   RgValue   = root:Packages:TwoPhaseSolidModel:RgValue
		//now get the start and end, make sure they are in proper order, just on case...
		RemoveFromGraph/W=TwoPhaseSystemData/Z $("fit_OriginalIntensity")
		Tag/K/W=TwoPhaseSystemData/N=$("RgTag")
		variable CursorQstart = OriginalQvector[pcsr(A, "TwoPhaseSystemData")]
		variable CursorQend   = OriginalQvector[pcsr(B, "TwoPhaseSystemData")]
		variable tempVal
		if(CursorQstart < CursorQend)
			//all OK...
		else
			tempVal      = CursorQstart
			CursorQstart = CursorQend
			CursorQend   = tempVal
		endif
		//make the wave for extrapolated data
		make/O/N=100/D RgFitIntensity, RgFitQvec
		RgFitQvec = CursorQstart + p * (CursorQend - CursorQstart) / (100 - 1) //sets k scaling on lin-scale...
		//now lets get the proper values we need...
		Make/D/N=0/O W_coef, LocalEwave
		Make/D/T/N=0/O T_Constraints
		WAVE/Z W_sigma
		//find the error wave and make it available, if exists
		variable V_FitError = 0 //This should prevent errors from being generated
		Redimension/N=2 W_coef, LocalEwave
		Redimension/N=2 T_Constraints
		T_Constraints[0] = {"K1 > 10"}
		T_Constraints[1] = {"K0 > 0"}

		W_coef[0] = OriginalIntensity[pcsr(A, "TwoPhaseSystemData")] //G
		W_coef[1] = PI / ((CursorQend + CursorQstart) / 2)           //Rg

		LocalEwave[0] = (W_coef[0] / 20)
		LocalEwave[1] = (W_coef[1] / 20)

		V_FitError = 0 //This should prevent errors from being generated
		if(WaveExists(ErrorWave))
			FuncFit IR1_GuinierFit, W_coef, OriginalIntensity[pcsr(A), pcsr(B)]/X=OriginalQvector/D/C=T_Constraints/W=ErrorWave/I=1 //E=LocalEwave
		else
			FuncFit IR1_GuinierFit, W_coef, OriginalIntensity[pcsr(A), pcsr(B)]/X=OriginalQvector/D/C=T_Constraints //E=LocalEwave
		endif
		if(V_FitError != 0) //there was error in fitting
			RemoveFromGraph/W=TwoPhaseSystemData/Z $("fit_OriginalIntensity")
			beep
			Abort "Fitting error, check starting parameters and fitting limits"
		endif
		WAVE W_sigma
		string TagText = "Fitted Guinier G = " + num2str(W_coef[0]) + "\r Rg = " + num2str(W_coef[1])
		if(WaveExists(ErrorWave))
			TagText += "\r chi-square = " + num2str(V_chisq)
		endif
		Tag/C/W=TwoPhaseSystemData/N=$("RgTag")/L=2 $NameOfWave(OriginalIntensity), ((pcsr(A) + pcsr(B)) / 2), TagText

		//FittingParam1=W_coef[0] 	//G
		RgValue = W_coef[1] //Rg
		NVAR Rmax = root:Packages:TwoPhaseSolidModel:Rmax
		//		NVAR Rmin=root:Packages:TwoPhaseSolidModel:Rmin
		//		NVAR Kmin=root:Packages:TwoPhaseSolidModel:Kmin
		//		NVAR Kmax=root:Packages:TwoPhaseSolidModel:Kmax
		//		//this is close to formula from SAXSMorph manual...
		Rmax = 5 * 2 * RgValue
		//		Kmin = lowQExtrapolationEnd / 10
		setDataFolder oldDF
	endif

End
///******************************************************************************************
///******************************************************************************************

Function IR3T_ExtrapolateHighQ()
	//we will extrapolate high-q with method picked by user...

	DoWindow TwoPhaseSystemData
	if(V_Flag)
		DFREF oldDf = GetDataFolderDFR()

		setDataFolder root:Packages:TwoPhaseSolidModel
		//check is cursors are set, if not, ask user to set tehm
		if(strlen(CsrWave(A)) == 0 || strlen(CsrWave(B)) == 0)
			beep
			abort "Select range fo data to use using Cursors A and B in the graph, set on wave Experimental Intensity"
		endif
		WAVE OriginalIntensity       = root:Packages:TwoPhaseSolidModel:OriginalIntensity
		WAVE OriginalQvector         = root:Packages:TwoPhaseSolidModel:OriginalQvector
		WAVE OriginalError           = root:Packages:TwoPhaseSolidModel:OriginalError
		NVAR highQExtrapolationStart = root:Packages:TwoPhaseSolidModel:highQExtrapolationStart
		NVAR highQExtrapolationEnd   = root:Packages:TwoPhaseSolidModel:highQExtrapolationEnd
		NVAR highQExtrapolationMax   = root:Packages:TwoPhaseSolidModel:highQExtrapolationMax
		NVAR PorodConstant           = root:Packages:TwoPhaseSolidModel:PorodConstant
		NVAR Background              = root:Packages:TwoPhaseSolidModel:Background
		//now get the start and end, make sure they are in proper order, just on case...
		variable CursorQstart = OriginalQvector[pcsr(A, "TwoPhaseSystemData")]
		variable CursorQend   = OriginalQvector[pcsr(B, "TwoPhaseSystemData")]
		if(CursorQstart < CursorQend)
			highQExtrapolationStart = CursorQstart
			highQExtrapolationEnd   = CursorQend
		else
			highQExtrapolationStart = CursorQend
			highQExtrapolationEnd   = CursorQstart
		endif
		//make the wave for extrapolated data
		make/O/N=100/D HighQExtrapolatedIntensity, highQExtrapolatedQvector
		highQExtrapolatedQvector = 10^(log(highQExtrapolationStart) + p * ((log(highQExtrapolationMax) - log(highQExtrapolationStart)) / (100 - 1))) //sets k scaling on log-scale...

		Make/D/N=2/O W_coef
		Make/D/T/O/N=1 T_Constraints
		variable V_FitError
		T_Constraints[0] = {"K1 >= 0"}
		//W_coef = {OriginalIntensity[pcsr(A , "TwoPhaseSystemData")]*(OriginalQvector[pcsr(A , "TwoPhaseSystemData")])^4,0.01*OriginalIntensity[pcsr(B , "TwoPhaseSystemData")]}
		W_coef     = {OriginalIntensity[pcsr(A, "TwoPhaseSystemData")] * (OriginalQvector[pcsr(A, "TwoPhaseSystemData")])^4, 0}
		V_FitError = 0 //This should prevent errors from being generated
		FuncFit/Q PorodInLogLog, W_coef, OriginalIntensity[pcsr(A), pcsr(B)]/X=OriginalQvector/C=T_Constraints/W=OriginalError/I=1
		if(V_FitError != 0) //there was error in fitting
			beep
			DoAlert/T="Extrapolation failed" 0, "Extrapolation fitting failed. Select different Q range and try again."
			highQExtrapolatedIntensity = 0
		else
			highQExtrapolatedIntensity = W_coef[0] * (highQExtrapolatedQvector[p])^(-4)
			PorodConstant              = W_coef[0]
			Background                 = W_coef[1]
		endif
		GetAxis/W=TwoPhaseSystemData/Q bottom
		variable MinXAxis = V_min
		variable MaxXaxis = V_max
		GetAxis/W=TwoPhaseSystemData/Q left
		variable MinYAxis = V_min
		variable MaxYaxis = V_max

		//OK, and now append to the graph
		CheckDisplayed/W=TwoPhaseSystemData highQExtrapolatedIntensity
		if(!V_flag)
			AppendToGraph/W=TwoPhaseSystemData highQExtrapolatedIntensity vs highQExtrapolatedQvector
		endif
		ModifyGraph/W=TwoPhaseSystemData lstyle(highQExtrapolatedIntensity)=4, rgb(highQExtrapolatedIntensity)=(0, 0, 0)
		SetAxis/W=TwoPhaseSystemData bottom, MinXAxis, MaxXaxis
		SetAxis/W=TwoPhaseSystemData left, MinYAxis, MaxYaxis
		//and now set Kmax based on Q range fo data
		NVAR Kmin = root:Packages:TwoPhaseSolidModel:Kmin
		NVAR Kmax = root:Packages:TwoPhaseSolidModel:Kmax
		//this is formula from SAXSMorph manual...
		Kmax = ceil(10 * highQExtrapolationStart)
		Kmax = Kmax < 6.28 ? 6.28 : Kmax

		setDataFolder oldDF
	endif

End

///******************************************************************************************
///******************************************************************************************
Function IR3T_CopyAndGraphInputData()
	//this function graphs data into the various graphs as needed

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:TwoPhaseSolidModel
	SVAR DataFolderName    = root:Packages:TwoPhaseSolidModel:DataFolderName
	SVAR IntensityWaveName = root:Packages:TwoPhaseSolidModel:IntensityWaveName
	SVAR QWavename         = root:Packages:TwoPhaseSolidModel:QWavename
	SVAR ErrorWaveName     = root:Packages:TwoPhaseSolidModel:ErrorWaveName
	//NVAR RebinDataTo=root:Packages:TwoPhaseSolidModel:RebinDataTo
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
	wavestats/Q OriginalQvector
	if(V_min < 0)
		OriginalQvector = OriginalQvector[p] <= 0 ? NaN : OriginalQvector[p]
	endif
	IN2G_RemoveNaNsFrom3Waves(OriginalQvector, OriginalIntensity, OriginalError)
	IR3T_GraphInputData()
	IR3T_ClearStaleNumbers()

	setDataFolder oldDF
End
///******************************************************************************************
///******************************************************************************************
Function IR3T_ExtendDataCalcParams()

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:TwoPhaseSolidModel
	WAVE/Z HighQExtrapolatedIntensity
	WAVE/Z highQExtrapolatedQvector
	WAVE/Z lowQExtrapolatedIntensity
	WAVE/Z lowQExtrapolatedQvector
	WAVE OriginalIntensity       = root:Packages:TwoPhaseSolidModel:OriginalIntensity
	WAVE OriginalQvector         = root:Packages:TwoPhaseSolidModel:OriginalQvector
	WAVE OriginalError           = root:Packages:TwoPhaseSolidModel:OriginalError
	NVAR highQExtrapolationStart = root:Packages:TwoPhaseSolidModel:highQExtrapolationStart
	NVAR highQExtrapolationEnd   = root:Packages:TwoPhaseSolidModel:highQExtrapolationEnd
	NVAR highQExtrapolationMax   = root:Packages:TwoPhaseSolidModel:highQExtrapolationMax
	NVAR RgValue                 = root:Packages:TwoPhaseSolidModel:RgValue

	NVAR PorodConstant        = root:Packages:TwoPhaseSolidModel:PorodConstant
	NVAR Background           = root:Packages:TwoPhaseSolidModel:Background
	NVAR Invariant            = root:Packages:TwoPhaseSolidModel:Invariant
	NVAR SurfaceToVolumeRatio = root:Packages:TwoPhaseSolidModel:SurfaceToVolumeRatio
	NVAR ScatteringContrast   = root:Packages:TwoPhaseSolidModel:ScatteringContrast
	NVAR Porosity             = root:Packages:TwoPhaseSolidModel:Porosity

	NVAR lowQExtrapolationStart = root:Packages:TwoPhaseSolidModel:lowQExtrapolationStart
	NVAR lowQExtrapolationEnd   = root:Packages:TwoPhaseSolidModel:lowQExtrapolationEnd
	NVAR lowQExtrapolationMin   = root:Packages:TwoPhaseSolidModel:lowQExtrapolationMin

	NVAR CalculatePorosityFromInvariant = root:Packages:TwoPhaseSolidModel:CalculatePorosityFromInvariant
	NVAR RKParametersManual             = root:Packages:TwoPhaseSolidModel:RKParametersManual

	NVAR Rmin = root:Packages:TwoPhaseSolidModel:Rmin
	NVAR Rmax = root:Packages:TwoPhaseSolidModel:Rmax
	NVAR Kmin = root:Packages:TwoPhaseSolidModel:Kmin
	NVAR Kmax = root:Packages:TwoPhaseSolidModel:Kmax

	NVAR BoxResolution = root:Packages:TwoPhaseSolidModel:BoxResolution
	NVAR BoxSideSize   = root:Packages:TwoPhaseSolidModel:BoxSideSize

	if(WaveExists(HighQExtrapolatedIntensity) && WaveExists(lowQExtrapolatedIntensity))
		variable OrgStart, OrgEnd
		FindLevel/P/Q OriginalQvector, lowQExtrapolationStart
		OrgStart = V_LevelX
		FindLevel/P/Q OriginalQvector, highQExtrapolationStart
		OrgEnd = V_LevelX
		Duplicate/FREE/R=[OrgStart, OrgEnd] OriginalIntensity, tempInt
		Duplicate/FREE/R=[OrgStart, OrgEnd] OriginalQvector, tempQ
		Concatenate/NP/O {lowQExtrapolatedIntensity, tempInt, HighQExtrapolatedIntensity}, ExtrapolatedIntensity
		Concatenate/NP/O {lowQExtrapolatedQvector, tempQ, highQExtrapolatedQvector}, ExtrapolatedQvector
		DoWIndow TwoPhaseSystemData
		if(V_FLag)
			CheckDisplayed/W=TwoPhaseSystemData ExtrapolatedIntensity
			if(!V_Flag)
				AppendToGraph/W=TwoPhaseSystemData ExtrapolatedIntensity vs ExtrapolatedQvector
			endif
			ModifyGraph/W=TwoPhaseSystemData lstyle(ExtrapolatedIntensity)=6, rgb(ExtrapolatedIntensity)=(1, 12815, 52428)
		endif
		//calculate Invariant
		variable Qmax = 5 //Qmax=5 hardwired here...
		Duplicate/FREE ExtrapolatedQvector, ExtrapolatedIntQ2
		ExtrapolatedIntQ2 = ExtrapolatedIntensity * ExtrapolatedQvector^2
		Invariant         = areaXY(ExtrapolatedQvector, ExtrapolatedIntQ2, 0, Qmax)
		//see IR1A_UpdatePorodSfcandInvariant() in Unified fit.
		NVAR PorodConstant = root:Packages:TwoPhaseSolidModel:PorodConstant
		Invariant += PorodConstant * Qmax^0.5 // 12/2/2013 provided by by dws as Invariant extension to infinity...
		//see IR1A_UpdatePorodSfcandInvariant() in Unified fit.
		Invariant = Invariant * 10^24 // in cm^-4
		if(CalculatePorosityFromInvariant)
			Porosity = (Invariant / ScatteringContrast) * 1e-20 / (2 * pi^2)
			if(Porosity > 0.5^2)
				DoAlert 0, "Calculated volume is too large when we do phi*(1-phi). Seems like there is problem with calibration of contrast. Input Porosity value manually. "
				CalculatePorosityFromInvariant = 0
				Porosity                       = 0.1
				IR3T_SetControlsInPanel()
			else
				Porosity = (1 - sqrt(1 - 4 * Porosity)) / 2 //this is quadratic equation solver
			endif
		else
			ScatteringContrast = (Invariant / (Porosity * (1 - Porosity))) * 1e-20 / (2 * pi^2)
		endif
		SurfaceToVolumeRatio = Porosity * (1 - porosity) * 1e4 * pi * PorodConstant / Invariant // this is not really S/V, that would be S/V = piB/Q * (phi*(1-phi))
		if(RKParametersManual == 0) //calculate and set R and K parameters here...
			//Rmin = BoxSideSize / BoxResolution / 2
			Rmin = 0.1
			//Rmax = IN2G_roundSignificant(35/lowQExtrapolationStart,2)
			variable Rmax1   = IN2G_roundSignificant(10 * RgValue, 2)
			variable RadMax2 = ceil(1.1 * sqrt(BoxSideSize^2 + BoxSideSize^2 + BoxSideSize^2))
			Rmax = max(RadMax2, Rmax1)
			Kmin = IN2G_roundSignificant(lowQExtrapolationStart / 10, 1)
			Kmax = IN2G_roundSignificant(highQExtrapolationStart * 10, 1)
			Kmax = Kmax > 6.28 ? Kmax : 2 * pi
		else
			//Rmax = ceil(1.3*sqrt(BoxSideSize^2+BoxSideSize^2+BoxSideSize^2))
		endif
		DoWIndow TwoPhaseSystems
		if(V_Flag)
			Button Generate3DModel, win=TwoPhaseSystems, disable=0, fColor=(3, 52428, 1)
		endif

	else
		DoAlert/T="Data do not exist" 0, "Cannot do any calculations, data do not exist. Extrapolate low and high Q first. "
	endif

End
///******************************************************************************************
///******************************************************************************************
Function IR3T_ClearStaleNumbers()
	//on import and when needed, this clears numbers which may be stale.

	NVAR PorodConstant          = root:Packages:TwoPhaseSolidModel:PorodConstant
	NVAR Background             = root:Packages:TwoPhaseSolidModel:Background
	NVAR Invariant              = root:Packages:TwoPhaseSolidModel:Invariant
	NVAR SurfaceToVolumeRatio   = root:Packages:TwoPhaseSolidModel:SurfaceToVolumeRatio
	NVAR ScatteringContrast     = root:Packages:TwoPhaseSolidModel:ScatteringContrast
	NVAR Porosity               = root:Packages:TwoPhaseSolidModel:Porosity
	NVAR RgValue                = root:Packages:TwoPhaseSolidModel:RgValue
	NVAR AchievedVolumeFraction = root:Packages:TwoPhaseSolidModel:AchievedVolumeFraction

	PorodConstant          = 0
	Background             = 0
	Invariant              = 0
	SurfaceToVolumeRatio   = 0
	RgValue                = 0
	AchievedVolumeFraction = 0

	DoWIndow TwoPhaseSystemData
	if(V_Flag)
		RemoveFromGraph/W=TwoPhaseSystemData/Z highQExtrapolatedIntensity, lowQExtrapolatedIntensity
	endif
	WAVE/Z lowQExtrapolatedIntensity  = root:Packages:TwoPhaseSolidModel:lowQExtrapolatedIntensity
	WAVE/Z highQExtrapolatedIntensity = root:Packages:TwoPhaseSolidModel:highQExtrapolatedIntensity
	KillWaves/Z lowQExtrapolatedIntensity, highQExtrapolatedIntensity
	DoWIndow TwoPhaseSystems
	if(V_Flag)
		Button Generate3DModel, win=TwoPhaseSystems, disable=2, fColor=(43690, 43690, 43690) // fColor=(3,52428,1)
	endif
End

///******************************************************************************************
///******************************************************************************************

Function IR3T_GraphInputData()

	PauseUpdate // building window...
	string fldrSav = GetDataFolder(1)
	SetDataFolder root:Packages:TwoPhaseSolidModel:
	SVAR DataFolderName    = root:Packages:TwoPhaseSolidModel:DataFolderName
	SVAR IntensityWaveName = root:Packages:TwoPhaseSolidModel:IntensityWaveName
	SVAR QWavename         = root:Packages:TwoPhaseSolidModel:QWavename
	SVAR ErrorWaveName     = root:Packages:TwoPhaseSolidModel:ErrorWaveName
	WAVE OriginalIntensity = root:Packages:TwoPhaseSolidModel:OriginalIntensity
	WAVE OriginalQvector   = root:Packages:TwoPhaseSolidModel:OriginalQvector
	WAVE OriginalError     = root:Packages:TwoPhaseSolidModel:OriginalError
	DoWIndow TwoPhaseSystemData
	if(V_Flag)
		DoWIndow/F TwoPhaseSystemData
	else
		Display/W=(282.75, 37.25, 759.75, 208.25)/K=1 OriginalIntensity vs OriginalQvector as "Two Phase 3D model Input Data"
		DoWindow/C TwoPhaseSystemData
		ModifyGraph mode(OriginalIntensity)=3
		ModifyGraph msize(OriginalIntensity)=0
		ModifyGraph log=1
		ModifyGraph mirror=1
		ShowInfo
		string LabelStr = "\\Z" + IN2G_LkUpDfltVar("AxisLabelSize") + "Intensity [" + IN2G_ReturnUnitsForYAxis(OriginalIntensity) + "\\Z" + IN2G_LkUpDfltVar("AxisLabelSize") + "]"
		Label left, LabelStr
		LabelStr = "\\Z" + IN2G_LkUpDfltVar("AxisLabelSize") + "Q [A\\S-1\\M\\Z" + IN2G_LkUpDfltVar("AxisLabelSize") + "]"
		Label bottom, LabelStr
		string LegendStr = "\\F" + IN2G_LkUpDfltStr("FontType") + "\\Z" + IN2G_LkUpDfltVar("LegendSize") + "\\s(OriginalIntensity) Experimental intensity"
		Legend/W=TwoPhaseSystemData/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr
		//
		ErrorBars/Y=1 OriginalIntensity, Y, wave=(OriginalError, OriginalError)
		//and now some controls
		TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07" + date() + ", " + time()
		TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07" + DataFolderName + IntensityWaveName
	endif
	SetDataFolder fldrSav
End

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3T_InitializeTwoPhaseSys()

 	DFREF oldDf = GetDataFolderDFR()

	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:TwoPhaseSolidModel
	string/G ListOfVariables
	string/G ListOfStrings
	//here define the lists of variables and strings needed, separate names by ;...
	ListOfVariables  = "UseIndra2Data;UseQRSdata;UseSMRData;"
	ListOfVariables += "BoxSideSize;BoxResolution;Porosity;Invariant;ScatteringContrast;SurfaceToVolumeRatio;CalculatePorosityFromInvariant;"
	ListOfVariables += "NumberofRPoints;NumberOfKPoints;Kmin;Kmax;Rmin;Rmax;RKlogSpaced;TotalNumberOfVoxels;RKParametersManual;"
	ListOfVariables += "LowQExtrapolationMin;LowQExtrapolationStart;LowQExtrapolationEnd;HighQExtrapolationEnd;HighQExtrapolationStart;HighQExtrapolationMax;"
	ListOfVariables += "PorodConstant;Background;RgValue;VoxelResolution;GizmoFillSolid;"
	ListOfVariables += "AchievedVolumeFraction;useSAXSMorphCode;"

	ListOfStrings  = "LowQExtrapolationMethod;"
	ListOfStrings += "DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	variable i
	//and here we create them
	for(i = 0; i < itemsInList(ListOfVariables); i += 1)
		IN2G_CreateItem("variable", StringFromList(i, ListOfVariables))
	endfor
	for(i = 0; i < itemsInList(ListOfStrings); i += 1)
		IN2G_CreateItem("string", StringFromList(i, ListOfStrings))
	endfor

	IR3T_SetInitialValues()

	setDataFOlder OldDf
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

static Function IR3T_SetInitialValues()
	//and here set default values...
	//template: IR1A_SetInitialValues(enforce)

 	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:TwoPhaseSolidModel
	variable ListOfVariables
	variable i
	//here limit of 0.3

	NVAR Kmin
	if(Kmin < 0.001)
		Kmin = 0.003
	endif
	NVAR Kmax
	if(Kmax < 3)
		Kmax = 2 * pi
	endif
	NVAR Rmin
	if(Rmin < 0.001 || Rmin > 20)
		Rmin = 0.1
	endif
	NVAR Rmax
	if(Rmax < 100)
		Rmax = 250
	endif

	//	ListOfVariables="Kmin;Rmin;"
	//
	//	For(i=0;i<itemsInList(ListOfVariables);i+=1)
	//		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
	//		if (testVar==0 || enforce)
	//			testVar=2.5
	//		endif
	//	endfor

	NVAR BoxSideSize //size of the box in A
	if(BoxSideSize < 50)
		BoxSideSize = 300
	endif
	NVAR BoxResolution //number of steps per side...
	if(BoxResolution < 20)
		BoxResolution = 50
	endif
	NVAR TotalNumberOfVoxels
	TotalNumberOfVoxels = BoxResolution^3
	NVAR VoxelResolution
	VoxelResolution = BoxSideSize / BoxResolution

	NVAR Porosity
	if(Porosity > 0.5 || Porosity < 0.01)
		Porosity = 0.2
	endif
	NVAR ScatteringContrast
	if(ScatteringContrast < 1)
		ScatteringContrast = 100
	endif
	NVAR NumberofRPoints
	if(NumberofRPoints < 100)
		NumberofRPoints = 10000
	endif
	NVAR NumberOfKPoints
	if(NumberOfKPoints < 100)
		NumberOfKPoints = 10000
	endif
	//	NVAR RKlogSpaced
	//	if(RKlogSpaced!=0 || RKlogSpaced!=1)
	//		RKlogSpaced = 1
	//	endif
	NVAR LowQExtrapolationMin
	if(LowQExtrapolationMin <= 0 || LowQExtrapolationMin > 0.01)
		LowQExtrapolationMin = 1e-5
	endif
	NVAR HighQExtrapolationMax
	if(HighQExtrapolationMax < 10 || HighQExtrapolationMax > 100)
		HighQExtrapolationMax = 50
	endif
	SVAR LowQExtrapolationMethod
	LowQExtrapolationMethod = "Constant"
	setDataFOlder OldDf
End

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************
//														Main twophase solid code
//			based on SAXSMorph & Ingham/Li/Allen/Toney, J. Appl. Cryst. (2011). 44, 221–224, doi:10.1107/S0021889810048557
//															and on
//			Quantanila Modelling Simul. Mater. Sci. Eng. 15 (2007) S337–S351, doi:10.1088/0965-0393/15/4/S02
///*************************************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************
Function IR3T_GenerateTwoPhaseSolid()

	WAVE/Z Intensity = root:Packages:TwoPhaseSolidModel:ExtrapolatedIntensity //Int/Q extended enough that we can ignore edge effects...
	if(!WaveExists(Intensity))
		abort
	endif

	WAVE/Z Qvec  = root:Packages:TwoPhaseSolidModel:ExtrapolatedQvector
	DFREF  oldDf = GetDataFolderDFR()

	PauseUpdate
	NewDataFOlder/O/S root:Packages
	NewDataFOlder/O/S root:Packages:TwoPhaseSolidModel
	//these are current parameters...
	NVAR BoxSideSize   = root:Packages:TwoPhaseSolidModel:BoxSideSize   //Box size in Angstroms
	NVAR BoxResolution = root:Packages:TwoPhaseSolidModel:BoxResolution // typically 50 divisions on each side, Voxel size is BoxSideSize/BoxResolution
	NVAR Porosity      = root:Packages:TwoPhaseSolidModel:Porosity
	//	NVAR RKlogSpaced = root:Packages:TwoPhaseSolidModel:RKlogSpaced
	NVAR NumberOfKPoints = root:Packages:TwoPhaseSolidModel:NumberOfKPoints
	NVAR NumberofRPoints = root:Packages:TwoPhaseSolidModel:NumberofRPoints
	NVAR Kmin            = root:Packages:TwoPhaseSolidModel:Kmin
	NVAR KMax            = root:Packages:TwoPhaseSolidModel:KMax
	NVAR RadMin          = root:Packages:TwoPhaseSolidModel:RMin
	NVAR RadMax          = root:Packages:TwoPhaseSolidModel:RMax
	RadMax = ceil(1.1 * sqrt(BoxSideSize^2 + BoxSideSize^2 + BoxSideSize^2))

	make/O/N=(NumberOfKPoints)/D Kvalues
	Make/O/N=(NumberofRPoints)/D PhaseAutocorFnctRadii, PhaseAutocorFnct, Radii
	WAVE Kvalues
	WAVE PhaseAutocorFnct
	WAVE Radii
	WAVE PhaseAutocorFnctRadii
	variable GammAlfa0 = porosity
	variable alfaValue
	//Now starting conditions.
	//Radius wave needs to be set right.
	//need min and max radius, their model uses 0.1 - 242 by default, I think this comes from input data...
	// this.gammar[i][0] = radius = (i * (this.rmax - this.rmin) / this.rpts + this.rmin);
	//note; log spacing simply does not work well. Needs to be lin spaced...
	//	if(RKlogSpaced)
	//		Radii = 10^(log(RadMin)+p*((log(RadMax)-log(RadMin))/(NumberofRPoints-1))) 				//sets k scaling on log-scale...
	//	else
	Radii                 = p * (RadMax - RadMin) / NumberofRPoints + RadMin //this makes the DebyePhCorrFnct match their function...
	PhaseAutocorFnctRadii = Radii
	//	endif
	//Now the K vector values...
	//need limits, here are their startup limits:
	//SAXSMorh uses linear binning, which results in weird spikes in the spectral function on my test case...
	//not sure what is right here.
	//	if(RKlogSpaced)
	//		Kvalues = 10^(log(Kmin)+p*((log(KMax)-log(Kmin))/(NumberOfKPoints-1))) 				//sets k scaling on log-scale...
	//	else
	Kvalues = Kmin + p * KMax / NumberOfKPoints //sets k scaling on lin-scale...
	//endif
	variable startTicks = ticks
	//important notes:
	//		Per all of the literature...
	//		This is a function that describes the correlation at two points separated by a distance r, arising from real-space density ﬂuctuations in the sample.
	//		That is, it represents the probability that two points separated by a distance r are of the same phase.
	//********************************************
	//  >>>>   Step 1 from Quintanilla  <<<<<<
	//********************************************
	print "Calculating Gamma_alfa(r)" //calculate formula 1	, convert Intensity to Debye Autocorreclation Function DACF
	multithread PhaseAutocorFnct = IR3T_ConvertIntToDACF(PhaseAutocorFnctRadii[p], Intensity, Qvec) //this is really Debye Autocorreclation Function
	print "Gamma_alfa(r) calculation time was " + num2str((ticks - startTicks) / 60) + " sec"
	//renormalize
	variable MaxValue = wavemax(PhaseAutocorFnct)
	//4-19-2022 We need Phase AUtocorrelation function which (read original Debye paper) :
	//	Autocorrelation function (ACF) must trend to 0 at high distances.
	//	Autocorrelation = 1 at 0 distance.
	//	Autocorrelation function can and will be negative if we have structure factor
	//Refer to original SAXSMorph java code, and John A. Quintanilla papers, explains why this is normalized as below:
	// Quintanilla: DebyePhCorrFnct = S2, and S2(0) = porosity (volume fractio of pores)
	//   limit(R->inf) DebyePhCorrFnct  = porosity^2  --- true for normal Autocorrelation function but NOT for Phase Correlation function.
	//Java code:      this.gammar[i][1] = ((this.porosity - this.porosity * this.porosity) * gamma_r_val[i] / gamma_r_max + this.porosity * this.porosity);
	//	Duplicate/O PhaseAutocorFnct, TwoPointsCorFData																	//thsi is two points correlation function.
	//	TwoPointsCorFData = (porosity - porosity^2) * PhaseAutocorFnct[p]/MaxValue + porosity^2					//this converts Two Points Correlation function... .
	// Makes sense, porosity^2 is random probability that two random points will be both in pore/solid (whatever the minority phase is).
	// OK,  but TwoPointsCorFData is actually useless for SAS calcualtions... See below.
	//       >>>>>>      this now works, 2-24-2019, but still seem to get different values than SAXSMorph
	//display/K=1 PhaseAutocorFnct vs Radii as "PhaseAutocorFnct"
	//display/K=1 TwoPointsCorFData vs Radii as "TwoPointsCorFData"

	//**************************************************************
	// >>>>   Step 2 from Quintanilla   <<<<<<
	//********************************************
	//calculate alfaValue		- note that the two methods use different integration limits  ******************************************
	alfaValue = sqrt(2) * inverseErf(1 - porosity * 2)
	print "Alfa calculated = " + num2str(alfaValue)
	//alfa = 0 (50%) to sqrt(2) (0%)
	// this is from SAXSMorph java code, for 20% ~ 0.841621, Checked by porting their Java inverf in Igor, it is inverse error function. So this is correct.
	//tested, see commented out code CalculateApproxAlfa(fiVal). Note, that the definitions between SAXSMorph and John A. Quintanilla vary in which side of erfunction is integrated.
	//this resutls in sign difference between the two papers, which is not material since we make decision which phase is which phase anyway.
	//CalculateApproxAlfa(0.9)
	//Approx number is : 1.2817
	//Erf calculation is : -1.2816
	//this is also reflected in g(r) calculations below, where SAXSmorph intergates from g(r) to 1, while QUINTANILLA integrated from 0 to g(r).
	//**************************************************************

	//**************************************************************
	// >>>>   Step 3 from Quintanilla   <<<<<<
	//********************************************
	//Now formula 2 in Main paper...
	//calculate g(r)																//nb: GammAlfa0 = porosity
	startTicks = ticks
	//print "Calculating gR(r) - the two-point correlation function g(r)"
	Duplicate/O Radii, AutoCorfnctGr
	//NVAR useSAXSMorphCode=root:Packages:TwoPhaseSolidModel:useSAXSMorphCode
	//if(useSAXSMorphCode)
	//	print "Calculating g(r) using SAXSMorph code"
	//	AutoCorfnctGr = IR3T_SMcalcgr(alfaValue, GammAlfa0, TwoPointsCorFData[p])	//this is complete voodoo in the SAXSMorph code. See notes in IR3T_SMcalcgr to try to explain...
	//	AutoCorfnctGr[0]=1																			//first point is 1 by definition and code gets NaN
	//else
	//if using Quantanilla Formula 2 integration, change sign of the next calculation...
	//also Quintanilla uses function Xi(r) = S2(r) - porosity^2, where S2(r) is PhaseAutocorFnct
	//this is needed since Xi(r) is Debye Phase Correlation Function which is 1 at r=0 and 0 at r=inf
	//let us create it for sanity...
	Duplicate/O PhaseAutocorFnct, XiFunctionQuint
	//XiFunctionQuint = PhaseAutocorFnct - GammAlfa0^2		//not needed, this is proper Xi function QUintanilla assumes
	variable alfaValueQ = -1 * alfaValue
	//print "Calculating g(r) using code in Quantanilla paper"
	multithread AutoCorfnctGr = IR3T_ProperCalcgr(alfaValueQ, XiFunctionQuint[p]) //this is correct way of calculating gr
	//AutoCorfnctGr[0]=1																							//first point is 1 by definition and code gets NaN
	variable AutoCorfnctGr0 = AutoCorfnctGr[0]
	AutoCorfnctGr /= AutoCorfnctGr0
	//AutoCorfnctGr = numtype(AutoCorfnctGr[p]) == 0 ? AutoCorfnctGr[p] : 1						//for log scaled data we have number of nans at the begginign due to really small values, need to be 1 for all such values.
	//endif

	//display/K=1 AutoCorfnctGr vs Radii as "AutoCorfnctGr"

	//print "gamma(r) calculation time was "+num2str((ticks-startTicks)/60) +" sec"
	//    fascinating. So the complete voddo in SAXSMorph creates same gR function as code from Quintanilla
	//********************************************
	// >>>>   Step 4 from Quintanilla   <<<<<<
	//********************************************
	//OK, the stuff above nearly matches SAXSMorph, if the k values are linearly spaced... If they are log-spaced, we get different curve a bit. Not really surprising...
	//Bessel function osciallations I would expect in test data, which is sphere intensity profile...
	//what is correct here??? Need to check how the data are used later...
	startTicks = ticks
	//Compute FFT of AutoCorfnctGr to later get non-negative version of it...
	print "Calculating Spectral function, that is fft of the G(r) (Covariance) function"
	duplicate/O Kvalues, SpectralFk
	multithread SpectralFk = IR3T_Formula4_SpectralFnct(Kvalues[p], PhaseAutocorFnct, Radii)
	// spectral function is ridiculously noisy, lets smooth it.
	//display/K=1 SpectralFk vs Kvalues as "SpectralFk"
	print "Spectral function calculation time was " + num2str((ticks - startTicks) / 60) + " sec"
	//********************************************
	// >>>>   Step 5 from Quintanilla   <<<<<<
	//********************************************
	//Step 5. Compute a nonnegative approximation of SpectralFk by solving the following convex quadratic programming problem:
	//Not sure we need to calcualte anything positive here
	//Duplicate/O SpectralFk, PositiveSpectralFk
	//note: this makes HUGE difference and results look lot closer to SAXSMorph and expectations...
	//this is useful, but sure if we need this specific value?
	//variable SMoothBy = ceil(numpnts(PositiveSpectralFk)/60)
	//Smooth/EVEN/B SMoothBy, PositiveSpectralFk
	//this gets some differeces between SAXSMorph and Igor code, but it may be just different rounding and methods. Not sure which one is actually right here anyway.
	//display/K=1 PositiveSpectralFk vs Kvalues as "PositiveSpectralFk"
	///display/K=1 PositiveAutoCorfnctGr vs Radii as "PositiveAutoCorfnctGr"
	startTicks = ticks
	// 	if(useSAXSMorphCode)
	//		print "Using SAXSMorph code... "
	//		//this is SAXSMorph
	//		//now we need to implement function calcGRF from java code...
	//		//this has lots of check code and them calls generateMatrix()
	//		startTicks=ticks
	//		print "Calculating Matrix"
	//		//this is SAXSMorph way
	//		IR3T_GenerateMatrix(Kvalues, SpectralFk, BoxSideSize, BoxResolution, alfaValue)
	//	else
	//and this is using FFT based on Quintanilla
	//********************************************
	// >>>>   Step 6 from Quintanilla   <<<<<<
	//********************************************
	//Evaluate G(r), the optimal positive-deﬁnite approximation to g(r).
	//duplicate/O Radii, PositiveAutoCorfnctGr
	//multithread PositiveAutoCorfnctGr = 	IR3T_ConvertSpectrFtoGr(Radii[p],PositiveSpectralFk,Kvalues)
	//variable NormalizeVal= wavemax(PositiveAutoCorfnctGr)
	//multithread PositiveAutoCorfnctGr = PositiveAutoCorfnctGr/NormalizeVal
	//here we can take over by use of FFT...
	//Duplicate/O AutoCorfnctGr, PositiveAutoCorfnctGr
	//PositiveAutoCorfnctGr = PositiveAutoCorfnctGr[p]>0 ? PositiveAutoCorfnctGr : 0
	//IR3T_UseFFTtoGenerateMatrix(AutoCorfnctGr,PositiveAutoCorfnctGr, alfaValue, BoxResolution, BoxSideSize)
	print "Using FFT to generate 2 phase solid"
	IR3T_MakeGRF(alfaValue)
	//		IR3T_UseFFTtoGenerateMatrix(PositiveAutoCorfnctGr,Radii, alfaValue, BoxResolution, BoxSideSize)
	//endif
	print "GenerateMatrix time is " + num2str((ticks - startTicks) / 60) + " sec"
	//calculate theoretical intensity from gR data per Quintanilla, Modelling Simul. Mater. Sci. Eng. 15 (2007) S337–S351
	//these are steps 7 and 8
	//evaluate TheoreticalAutocorrelationFnct as function of R from gR
	Duplicate/O Radii, RadiiTheorAutoCorrFnct, TheorAutoCorrFnct
	TheorAutoCorrFnct = IR3T_CalcTheorAutocorF(alfaValue, AutoCorfnctGr[p])
	//some calibration fixes...
	WAVE TwoPhaseSolidMatrix = root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrix
	wavestats/Q TwoPhaseSolidMatrix
	//TheorAutoCorrFnct[0]=1-V_avg //-porosity^2
	//TheorAutoCorrFnct+=porosity^2
	//and calculate intensity, step 8
	Duplicate/O Qvec, TheoreticalIntensityDACF, QvecTheorIntensityDACF
	multithread TheoreticalIntensityDACF = IR3T_ConvertDACFToInt(Radii, TheorAutoCorrFnct, QvecTheorIntensityDACF[p])
	//OK, but there is resolution limit to this calculation. Cannot have higher Q values than voxel size resolution...
	//thsi will chang when we allow different sides of the object.
	NVAR     Rmax              = root:Packages:TwoPhaseSolidModel:Rmax
	NVAR     HighQStart        = root:Packages:TwoPhaseSolidModel:HighQExtrapolationStart
	NVAR     HighQEnd          = root:Packages:TwoPhaseSolidModel:HighQExtrapolationEnd
	NVAR     VoxelResolution   = root:Packages:TwoPhaseSolidModel:VoxelResolution
	variable MaxMeaningfulQmax = min(pi / VoxelResolution, HighQStart)
	variable MinMeaningfulQmin = 2 * pi / (BoxSideSize)
	//TheoreticalIntensityDACF
	variable MaxMeaningfulPnt = BinarySearch(QvecTheorIntensityDACF, MaxMeaningfulQmax)
	variable MinMeaningfulPnt = BinarySearch(QvecTheorIntensityDACF, MinMeaningfulQmin)
	TheoreticalIntensityDACF[MaxMeaningfulPnt, numpnts(TheoreticalIntensityDACF) - 1] = NaN
	TheoreticalIntensityDACF[0, MinMeaningfulPnt - 1]                                 = NaN
	IN2G_RemoveNaNsFrom2Waves(TheoreticalIntensityDACF, QvecTheorIntensityDACF)
	//append this to the graph.
	DoWIndow TwoPhaseSystemData
	if(V_Flag)
		WAVE     OriginalIntensity = root:Packages:TwoPhaseSolidModel:OriginalIntensity
		WAVE     OriginalQvector   = root:Packages:TwoPhaseSolidModel:OriginalQvector
		variable IntgInt           = areaXY(OriginalQvector, OriginalIntensity, MinMeaningfulQmin, MaxMeaningfulQmax)
		variable ModelIntgInt      = areaXY(QvecTheorIntensityDACF, TheoreticalIntensityDACF)
		TheoreticalIntensityDACF *= IntgInt / ModelIntgInt
		CheckDisplayed/W=TwoPhaseSystemData TheoreticalIntensityDACF
		if(!V_Flag)
			AppendToGraph/W=TwoPhaseSystemData TheoreticalIntensityDACF vs QvecTheorIntensityDACF
		endif
		ModifyGraph lstyle(TheoreticalIntensityDACF)=10
		ModifyGraph lsize(TheoreticalIntensityDACF)=5, rgb(TheoreticalIntensityDACF)=(1, 16019, 65535)
	endif

	//this is using PDF method for intensity calculation...
	//print "Calculating PDF and SAS curve."
	///Wave TwoPhaseSolidMatrix
	//oversample = BoxResolution>100 ? 2 : 4
	KillWaves/Z RandomField_FFT_Covar_IFFT_norm, AutoCorMatrix, RandomField, CovarFunction3D

	print "Done..."
	resumeUpdate
	setDataFOlder OldDf
End

///*************************************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************

Function IR3T_MakeGRF(CutOffLevel)
	variable CutOffLevel
	setDataFolder root:Packages:TwoPhaseSolidModel:
	NVAR NumVoxels  = root:Packages:TwoPhaseSolidModel:BoxResolution
	NVAR VoxelRes   = root:Packages:TwoPhaseSolidModel:VoxelResolution
	WAVE SpectralFk = root:Packages:TwoPhaseSolidModel:SpectralFk
	WAVE Kvalues    = root:Packages:TwoPhaseSolidModel:Kvalues
	NVAR VOlLevel   = root:Packages:TwoPhaseSolidModel:Porosity
	Duplicate/FREE Kvalues, KvaluesLoc
	Duplicate/FREE SpectralFk, SpectralFkLoc
	InsertPoints 0, 1, KvaluesLoc, SpectralFkLoc
	KvaluesLoc[0]    = 0
	SpectralFkLoc[0] = SpectralFkLoc[1]

	make/N=(NumVoxels, NumVoxels, NumVoxels)/FREE GaussNoise3D //create W(x),
	// add proper scaling for 3D object, VoxelRes A steps in x, y, and z.
	SetScale/P x, 0, VoxelRes, "", GaussNoise3D
	SetScale/P y, 0, VoxelRes, "", GaussNoise3D
	SetScale/P z, 0, VoxelRes, "", GaussNoise3D

	multithread GaussNoise3D = enoise(1) //fill W(x) with random noise
	FFT/FREE/DEST=GaussNoise3DFFT GaussNoise3D //FFT(W(x)) to use from right on the formula 6, this shoudl be FW(x) in that notation
	duplicate/FREE/C GaussNoise3DFFT, Gamma3D //need to store somewhere Gamma(q) - formula 7. q is distance from center here, q=sqrt(x^2+y^2+z^2)
	//Gamma3D now has proper scaling also.

	//this is model of Gamma function for testing.
	//multithread Gamma3D =  cmplx(sqrt((1+abs(20*sqrt(x^2+y^2+z^2))^8)^(-2)),0)	// fill the Gamm(q), but this is real function for spectreal density, Gamma3D is complex???
	//this is using Fk
	//IMPORTANT:
	// we need to multiply the scaling here by 2pi to get sensible sizes, conversion from Q to inverse dimension.
	multithread Gamma3D = cmplx(SpectralFkLoc[BinarySearchInterp(KvaluesLoc, 2 * pi * sqrt(x^2 + y^2 + z^2))], 0)

	MatrixOP/FREE/NTHR=0 GaussNoise3DFFT = GaussNoise3DFFT * Gamma3D //this shoudl be faster.
	//multithread GaussNoise3DFFT=GaussNoise3DFFT*Gamma3D			//this surely works

	IFFT/DEST=TwoPhaseSolidMatrix GaussNoise3DFFT //this finishes formula 6 and shoudl provide fi(x) which we just need to threshold and image in Gizmo
	//now cut off level based on above code is scaled to variation +/- sqrt(2)
	//but we are nowhere around +/-1, so lets scale to the max range of data this cutoff level.
	wavestats/Q TwoPhaseSolidMatrix
	//Converting Alfa into what we need here needs scaling by standard deviation or by rms.
	//took some time to figure out empirically, but somehow makes sense...
	variable CutOffLevelL = CutOffLevel * V_sdev
	//this looked up proper cutoff level from wanted volume.
	//variable CutOfflevelL=IR3T_FindCorrectLevel(TwoPhaseSolidMatrix,VOlLevel)		//looks for correct level to get the right volume of scatterers, this is 10%
	//print "Input cut off level = "+num2str(CutOfflevel)
	//print "Needed cut off level = "+num2str(CutOfflevelL)
	MatrixOP/FREE/NTHR=0 GRF3DTresh = greater(TwoPhaseSolidMatrix, CutOffLevelL) //creates thresholded 3D wave, this is GRF as needed.
	Duplicate/O GRF3DTresh, root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrix
	WAVE TwoPhaseSolidMatrix
	SetScale/P x, 0, VoxelRes, "", TwoPhaseSolidMatrix
	SetScale/P y, 0, VoxelRes, "", TwoPhaseSolidMatrix
	SetScale/P z, 0, VoxelRes, "", TwoPhaseSolidMatrix
	//smooth out the resulting matrix:
	ImageFilter/N=5 gauss3d, TwoPhaseSolidMatrix
	KillWaves/Z M_MatrixFilter //created for some reason, needs to bedisposed off.
	//wavestats/Q TwoPhaseSolidMatrix
	//print "achieved volume fraction = "+num2str(V_avg)
	//if you need to silly wave scaling you can run copyScales().
	//Now if you really want to optimize the code:
	//
	//Make/C/N=(129,256,256)  Gamma3D
	//SetScale/I x 0,255,"", Gamma3D
	//SetScale/I y 0,255,"", Gamma3D
	//SetScale/I z 0,255,"", Gamma3D
	//MultiThread Gamma3D=cmplx(sqrt((1+abs(20*sqrt(x^2+y^2+z^2))^8)^(-2)),0)
	//
	//and then, just a single MatrixOP e.g.,
	//
	//this does not work (AG confirmed, MatrixOP works on 3D waves layer by layer, so this is not really proper 3D FFT
	//
	//MatrixOP/O GRF3DTresh=greater((IFFT(FFT(GaussNoise3D,2)* Gamma3D,3)),5)
	//
	//Note: I have not checked that the option parameters (2 and 3) are correct.
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************

Function IR3T_FindCorrectLevel(GRF3D, level)
	WAVE     GRF3D
	variable level
	wavestats/Q GRF3D
	variable   MinL   = V_min
	variable   MaxL   = V_max
	variable/G levleg = level
	Optimize/H=(MaxL)/L=(MinL)/I=30/T=0.0003/Y=(MaxL - MinL)/Q IR3T_FindCorrectLevelInternal, GRF3D
	return V_minloc
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************

Function IR3T_FindCorrectLevelInternal(GRF3D, Cutoff)
	WAVE     GRF3D
	variable Cutoff
	NVAR     levleg
	MatrixOP/O/NTHR=0 GRF3DTresh = greater(GRF3D, Cutoff)
	wavestats/Q GRF3DTresh
	variable difference
	difference = abs(V_avg - levleg)
	return difference
End

///*************************************************************************************************************************************
///*************************************************************************************************************************************

//this works now, but it is getting very noisy results. In SAXSMorph I had to smooth the F(k) or I had much noisier, unrealistic results.
//what to do here?

Function IR3T_UseFFTtoGenerateMatrix(Gr, Radii, alfaValue, BoxDivisions, BoxSide)
	WAVE Gr, radii 
	//this is covariance function (1D)
	variable alfaValue 
	//this is cut off value
	variable BoxDivisions, BoxSide 
	//Divisions is number of pixels per side, Side is length in A

	//need to add radius 0 = Gr = 1
	Duplicate/O Gr, GRtemp, Radiitemp
	//GRtemp[0]=1
	GRtemp        = Gr / wavemax(Gr) //Positive Gr has not been normalized... Need to normalize to 1 at max.
	Radiitemp[0]  = 0
	Radiitemp[1,] = Radii[p - 1]
	//now we need to create Corelation.
	make/O/N=5000 CovarFunction1D
	variable maxRadgR = radii[numpnts(radii) - 1]
	SetScale x - 0.95 * maxRadgR, 0.95 * maxRadgR, "A", CovarFunction1D

	CovarFunction1D = GRtemp[binarysearchInterp(Radiitemp, abs(x))]

	//for testing
	//Duplicate/O CovarFunction1D, CovarFunction1DGauss, CovarFunction1DOrig

	//Let's see what using smooth function would do...
	//Curve fitting with Gaussian works fine, but is not generic enough...
	//make/N=4/O W_coef
	//W_coef={0,1,0,50}
	//K0 = 0;K1 = 1;K2 = 0;K3 = 50;
	//CurveFit/G/H="1110" gauss GRtemp /X=Radiitemp
	//CovarFunction1D =  W_coef[0]+W_coef[1]*exp(-((x-W_coef[2])/(W_coef[3]))^2)				//<<<< is this to convert radius to distance??? I think Covar FUnction needs distance.
	//end of use of gauss to smooth Gr...

	//use FFT to remove high osciallations...
	//	CovarFunction1D = abs(x)<maxRadgR ? GRtemp[binarysearchInterp(Radiitemp, abs(x) )] : 0
	//	FFT/OUT=3/DEST=CovarFunction1D_FFT 	CovarFunction1D
	//	Smooth/EVEN/B 30, CovarFunction1D_FFT
	// IFFT/DEST=CovarFunction1D_FFT_SM_IFFT  CovarFunction1D_FFT
	//end, this seems to be a problem...

	Make/N=(BoxDivisions, BoxDivisions, BoxDivisions)/O RandomField, CovarFunction3D
	multithread RandomField = gnoise(1)
	variable HalfBox = BoxSide / 2
	//	SetScale x 0,BoxSide,"A", RandomField
	//	SetScale y 0,BoxSide,"A", RandomField
	//	SetScale z 0,BoxSide,"A", RandomField
	//	SetScale y 0,BoxSide,"A", CovarFunction3D
	//	SetScale x 0,BoxSide,"A", CovarFunction3D
	//	SetScale z 0,BoxSide,"A", CovarFunction3D
	SetScale x - HalfBox, HalfBox, "A", RandomField, CovarFunction3D
	SetScale y - HalfBox, HalfBox, "A", RandomField, CovarFunction3D
	SetScale z - HalfBox, HalfBox, "A", RandomField, CovarFunction3D
	//this is generating too small particles, something is off here.
	//	variable BoxCenterX, BoxCenterY, BoxCenterZ
	//	BoxCenterX = BoxSide/2
	//	BoxCenterY = BoxSide/2
	//	BoxCenterZ = BoxSide/2
	multithread CovarFunction3D = CovarFunction1D(sqrt((x)^2 + (y)^2 + (z)^2))

	//Now FFT the two components:
	FFT/OUT=1/DEST=RandomField_FFT RandomField // this is random field after FFT, it should be more or less another random Gauss field.
	FFT/OUT=1/DEST=CovarFunction3D_FFT CovarFunction3D // this is FFT of covariance function

	//cannot make this below work somehow.... this is what causes my GRF to be wrong and narrow...
	//matrixOp does not preserve wave scaling, we need to copy scales after MatrixOps here!
	//still, this is incorrect. I am unable to get proper GRF generation here.
	matrixOp/NTHR=0/O CovarFunction3D_FFTpwr = powC(CovarFunction3D_FFT, 1 / 2) //	<< even for 3D this needs to be sqrt, so why is it for 1D not sqrt???
	matrixOp/NTHR=0/O RandomField_FFT_Covar = RandomField_FFT * CovarFunction3D_FFTpwr
	//return the wave scaling here so IFFT can work...
	CopyScales/P RandomField_FFT, RandomField_FFT_Covar

	IFFT/DEST=RandomField_FFT_Covar_IFFT RandomField_FFT_Covar
	//no normalization lost or needed, when Gr is normalized to 1 at max.

	MatrixOp/NTHR=0/O TwoPhaseSolidMatrix = greater(RandomField_FFT_Covar_IFFT, alfaValue)
	CopyScales/P RandomField_FFT_Covar_IFFT, TwoPhaseSolidMatrix

	KillWaves/Z CovarFunction3D_FFTpwr, RandomField_FFT_Covar, RandomField_FFT_Covar_IFFT
	//
	//	SetScale/I x 0,BoxSide,"A", TwoPhaseSolidMatrix
	//	SetScale/I y 0,BoxSide,"A", TwoPhaseSolidMatrix
	//	SetScale/I z 0,BoxSide,"A", TwoPhaseSolidMatrix

	print "Done"
End

///*************************************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************

Function IR3T_CalculateAchievedValues()

	WAVE/Z TwoPhaseSolidMatrix    = root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrix
	NVAR   AchievedVolumeFraction = root:Packages:TwoPhaseSolidModel:AchievedVolumeFraction

	if(WaveExists(TwoPhaseSolidMatrix))
		Wavestats/Q TwoPhaseSolidMatrix

		AchievedVolumeFraction = V_avg
	endif

End
///*************************************************************************************************************************************
//Function IR3T_AppendModelIntToGraph()
//	DoWindow TwoPhaseSystemData
//	if(V_Flag)
//		DoWIndow/F TwoPhaseSystemData
//		Wave/Z PDFQWv = root:Packages:TwoPhaseSolidModel:PDFQWv
//		Wave/Z PDFIntensityWv = root:Packages:TwoPhaseSolidModel:PDFIntensityWv
//		Wave ExtrapolatedIntensity = root:Packages:TwoPhaseSolidModel:ExtrapolatedIntensity
//		Wave ExtrapolatedQvector = root:Packages:TwoPhaseSolidModel:ExtrapolatedQvector
//		Wave OriginalQvector = root:Packages:TwoPhaseSolidModel:OriginalQvector
//		Wave OriginalIntensity = root:Packages:TwoPhaseSolidModel:OriginalIntensity
//		Wave/Z TheoreticalIntensityDACF = root:Packages:TwoPhaseSolidModel:TheoreticalIntensityDACF
//		Wave/Z QvecTheorIntensityDACF=root:Packages:TwoPhaseSolidModel:QvecTheorIntensityDACF
//		NVAR Qmin = root:Packages:TwoPhaseSolidModel:LowQExtrapolationStart
//		NVAR Qmax = root:Packages:TwoPhaseSolidModel:HighQExtrapolationEnd
//		variable InvarModel
//		variable InvarData
////		if(WaveExists(PDFQWv))
////			//need to renormalzie this together...
////			InvarModel=areaXY(PDFQWv, PDFIntensityWv )
////			InvarData=areaXY(ExtrapolatedQvector, ExtrapolatedIntensity )
////			PDFIntensityWv*=InvarData/InvarModel
////			CheckDisplayed /W=TwoPhaseSystemData PDFIntensityWv
////			if(V_flag==0)
////				AppendToGraph/W=TwoPhaseSystemData  PDFIntensityWv vs PDFQWv
////			endif
////			ModifyGraph lstyle(PDFIntensityWv)=9,lsize(PDFIntensityWv)=3,rgb(PDFIntensityWv)=(1,16019,65535)
////			ModifyGraph mode(PDFIntensityWv)=4,marker(PDFIntensityWv)=19
////			ModifyGraph msize(PDFIntensityWv)=3
////		endif
////		if(WaveExists(TheoreticalIntensityDACF))
////			//need to renormalzie this together...
////			InvarModel=areaXY(QvecTheorIntensityDACF, TheoreticalIntensityDACF, Qmin, QvecTheorIntensityDACF[numpnts(QvecTheorIntensityDACF)-2] )
////			InvarData=areaXY(OriginalQvector, OriginalIntensity, Qmin, QvecTheorIntensityDACF[numpnts(QvecTheorIntensityDACF)-2]  )
////			TheoreticalIntensityDACF*=InvarData/InvarModel
////			CheckDisplayed /W=TwoPhaseSystemData TheoreticalIntensityDACF
////			if(V_flag==0)
////				AppendToGraph/W=TwoPhaseSystemData  TheoreticalIntensityDACF vs QvecTheorIntensityDACF
////			endif
////			ModifyGraph lstyle(TheoreticalIntensityDACF)=9,lsize(TheoreticalIntensityDACF)=3,rgb(TheoreticalIntensityDACF)=(1,16019,65535)
////			ModifyGraph mode(TheoreticalIntensityDACF)=4,marker(TheoreticalIntensityDACF)=19
////			ModifyGraph msize(TheoreticalIntensityDACF)=3
////		endif
//	endif
//
//end

///*************************************************************************************************************************************
///*************************************************************************************************************************************
//			Utility functions
///*************************************************************************************************************************************
///*************************************************************************************************************************************
///******************************************************************************************************************************************
//******************************************************************************************************************************************

Function IR3T_Autocorelate3D(MatIn, ExtendByAverage)
	variable ExtendByAverage 
	//if set to 1, extend by ave density (3D solid), 0 extend by 0 (simple shapes)
	WAVE     MatIn           
	//3D matrix which needs to be autocorelated. Assume 0 and 1 for now.
	//this autocorelates Mat with itself.
	variable startT = ticks
	variable i
	Print "1/3 Autocorrelate3D Preparation phase. "
	//make dimension 2^n or 2^n * 3 and pad with something, it will be faster and without edge effects.
	//record old dimensions
	variable oldD0     = DimSize(MatIn, 0)
	variable oldD1     = DimSize(MatIn, 1)
	variable oldD2     = DimSize(MatIn, 2)
	variable oldD0Step = DimDelta(MatIn, 0) //assume same for all three dimensions or everything falls appart.
	variable oldD1Step = DimDelta(MatIn, 1) //assume same for all three dimensions or everything falls appart.
	variable oldD2Step = DimDelta(MatIn, 2) //assume same for all three dimensions or everything falls appart.
	//now create larger object with dimensions which are "fast" for FFT and larger.
	//basically we will pad the 3D wave, but there is no simple way to do it for 3D in IP8/9
	//find new larger dimension
	variable newD0, newD1, newD2
	//make allowable sizes.
	make/FREE/N=15 size1, size2
	Size1 = 2^p     //fastest
	size2 = 3 * 2^p //fast
	Concatenate/FREE/NP {size1, size2}, Sizes
	Sort Sizes, Sizes
	//find size closest to 2xlarger with number of points 2^n/3*2^n to pad the image with.
	FindLevel/P/Q Sizes, 1.9 * oldD0
	newD0 = Sizes[ceil(V_LevelX)]
	FindLevel/P/Q Sizes, 1.9 * oldD1
	newD1 = Sizes[ceil(V_LevelX)]
	FindLevel/P/Q Sizes, 1.9 * oldD2
	newD2 = Sizes[ceil(V_LevelX)]
	//make new padded image and use that. For now pad with 0 or average intensity.
	//this is not ideal, may need to be changed with repeating structure of the image, not just image.
	Make/FREE/N=(newD0, newD1, newD2)/S Mat
	if(ExtendByAverage == 1)
		Wavestats/Q MatIn
		multithread Mat = V_avg //Avg density - this is for 3D solid (bicontinual solid)
	elseif(ExtendByAverage == 0)
		multithread Mat = 0 //this is 0, for simple shapes like sphere
	else
		abort "Wrong choice in IR3T_Autocorelate3D"
	endif
	//now insert original 3D wave in the middle
	variable D0offset, D1offset, D2offset
	D0offset = (newD0 - oldD0) / 2
	D1offset = (newD1 - oldD1) / 2
	D2offset = (newD2 - oldD2) / 2
	Multithread Mat[D0offset, oldD0 + D0offset - 1][D1offset, oldD1 + D1offset - 1][D2offset, oldD2 + D2offset - 1] = MatIn[p - D0offset][q - D1offset][r - D2offset]
	print "			Step 1/3 took [seconds] : " + num2str((ticks - startT) / 60)
	Print "2/3 Autocorrelate3D FFT/CONJ/IFFT phase. "
	//now do the correlation
	FFT/DEST=TmpFFTMat/FREE Mat //this is slow process... 15 sec in 512^3 wave test
	Duplicate/C/FREE TmpFFTMat, TmpFFTMatConj, TmpInternal //~1 sec in test, MatrixOp is only slightlly faster.
	multithread TmpFFTMatConj = conj(TmpFFTMat) //this is quite fast
	multithread TmpInternal = TmpFFTMat * TmpFFTMatConj //2 sec on test
	IFFT/DEST=AutoCorMatTmp/FREE TmpInternal //this is slow process... 15 sec in 512^3 wave test
	ImageTransform swap3D, AutoCorMatTmp //this is for 3D waves.
	// AutoCorMatrixTmp padded, larger than original size.
	// that made downstream code much slower for handling.
	print "			Step 2/3 took [seconds] : " + num2str((ticks - startT) / 60)
	Print "3/3 Autocorrelate3D Cleanup result phase. "

	//make output matrix:
	//MatrixOp/O/NTHR=0 AutoCorMatrix = MatIn					//if input is not SP, this results in input type, which may be wrong (INT8 for example).
	Make/O/S/N=(dimsize(MatIn, 0), dimsize(MatIn, 1), dimsize(MatIn, 2)) AutoCorMatrix
	//need to clean away some offset.
	multithread AutoCorMatrix = AutoCorMatTmp[p + D0offset][q + D1offset][r + D2offset]
	//need to offset this between 0 and 1
	//get layer 1 and its average, this is to get something resembling converging value for far distances.
	//tried other methods and all of them failed, this one seems to work well enough.
	Duplicate/FREE/R=[0][][] AutoCorMatrix, tempWv
	wavestats/Q tempWv
	//average of this layer 1 shoudl be converging to far distance value, potentially V_avg of the original Mat for 3D solid, but 0 for simple shapes.
	multithread AutoCorMatrix = AutoCorMatrix - V_avg
	//now we are offset as DebyePhaseAutocorrelation function requires.
	//now we need to scale to 1 at center.
	variable MaxValue = WaveMax(AutoCorMatrix)
	multithread AutoCorMatrix = AutoCorMatrix / MaxValue //this is relatively fast.
	//now tweak output... We will add scaling, so we do not forget about it. Shoudl be anstroms, but IP8/9 considers A amperes.
	SetScale/P x, 0, oldD0Step, "", AutoCorMatrix
	SetScale/P y, 0, oldD1Step, "", AutoCorMatrix
	SetScale/P z, 0, oldD2Step, "", AutoCorMatrix
	//result is AutoCorMatrix scaled to max=1 in current data folder.
	//now, to keep sanity, we need to reduce the size to original sizes, this is much larger...

	print "Autocorrelate3D done, created 3D AutoCorMatrix. Run on " + num2str(oldD0) + "^3 points took [seconds] : " + num2str((ticks - startT) / 60)
End

///******************************************************************************************************************************************
///******************************************************************************************************************************************
///******************************************************************************************************************************************

threadsafe Function IR3T_ConvertIntToDACF(Radius, Intensity, Qvec) //formula 1 in SAXSMorph/Quntanilla, DACF is Debye Autocorelation Function
	variable Radius
	WAVE Intensity, Qvec
	Make/FREE/N=(numpnts(Intensity))/D QRWave
	QRWave = sinc(Qvec[p] * Radius) //(sin(Qvec[p]*Radius))/(Qvec[p]*Radius)
	matrixOP/FREE tempWave = powR(Qvec, 2) * Intensity * QRWave
	return 4 * pi * areaXY(Qvec, TempWave)
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************
//
threadsafe Function IR3T_ConvertDACFToInt(Radius, DACF, Qvec) //Convert DACF (Debye Autocorelation Function) to intensity
	WAVE Radius, DACF
	variable Qvec
	Make/FREE/N=(numpnts(Radius))/D QRWave
	QRWave = sinc(Qvec * Radius[p]) //(sin(Qvec[p]*Radius))/(Qvec[p]*Radius)
	matrixOP/FREE tempWave = powR(Radius, 2) * DACF * QRWave
	return 4 * pi * areaXY(Radius, TempWave)
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************

//threadsafe
threadsafe Function IR3T_CalcIntensityPDF(Qvalue, PDF, Radius) //AMemiys - my theory powerpoint
	variable Qvalue
	WAVE PDF, Radius
	Make/FREE/N=(numpnts(PDF))/D QRWave
	QRWave = sinc(Qvalue * Radius[p]) //(sin(Qvec[p]*Radius))/(Qvec[p]*Radius)
	matrixOP/NTHR=0/FREE tempWave = PDF * QRWave
	//variable AreaW = areaXY(Radius, TempWave)
	return (4 * pi * (areaXY(Radius, TempWave)))
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************
threadsafe Function IR3T_CalcTheorAutocorF(alfa, grValue)
	variable alfa, grValue
	make/FREE/N=1 pWave
	pWave[0] = alfa
	//pWave[1] = gammaR
	variable value
	value = Integrate1D(IR3T_JanCalcOfRInt, 0, grValue, 1, 50, pWave)
	value = value / (2 * pi)
	return value
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************
//					here is calculation of gR
///*************************************************************************************************************************************
///*************************************************************************************************************************************
//This is using published formulas as best as I can...proper way the g(r) - not the SAXSMorph way...
//this is using the QUINTANILLA definition of alfa
threadsafe Function IR3T_ProperCalcgr(alfa, gammaR)
	variable alfa, gammaR
	//input values are input numbers for each g(r) value
	//thsi is needed for Optimize, no science here...
	make/FREE/N=3 pWave
	pWave[0] = alfa
	pWave[1] = gammaR
	//This call finds minimum of the called function
	Optimize/I=100/H=1/L=-0.9/Q IR3T_ProperOptimizeFnct, pWave
	variable result = V_MinLoc //this is x for which IR3T_ProperOptimizeFnct returns 0.
	return result //hence, this is g(r)
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************
//this is our function, but Optimize compatible.
threadsafe Function IR3T_ProperOptimizeFnct(w, xval)
	WAVE     w
	variable xval
	variable alfa   = w[0]
	variable gammaR = w[1]
	make/FREE/N=1 pWave
	pWave[0] = alfa
	variable value
	//value = Integrate1D(IR3T_JanCalcOfRInt, xval, 0.9999 , 1, 50, pWave)	 //Formula 2 integral from g(r) to 1, as in SAXSmorph paper.
	//note that QUINTANILLA has this intergated from 0 to g(r) in Formula 2, but also has alfaValue of oposite sign.
	value  = Integrate1D(IR3T_JanCalcOfRInt, 0, xval, 1, 50, pWave) //Formula 2 integral from g(r) to 1, as in QUINTANILLA paper.
	value /= 2 * pi                                                 //divide by 2pi, same as Formula 2
	variable result
	result = abs(gammaR - value) //and this creates the minimum. Value when this is =0 is g(r) value, note the difference from SAXSMorph definitions here...
	return result
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************
//this is code I think we should have here:
threadsafe Function IR3T_JanCalcOfRInt(pWave, xvalue) //this is integral inside Formula 2 in SAXSMorph paper.
	variable xvalue
	WAVE     pWave
	variable part1, part2
	variable alfa = pWave[0]
	// we are using Formula 2 internals of the Integration...
	part1 = exp(-1 * alfa * alfa / (1 + xvalue))
	part2 = sqrt(1 - xvalue * xvalue)
	return part1 / part2
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************
//	here is calculation of g(R) using SAXSMorph code.
// calcGOfR is actually done above by Igor wave calling line..., all it does is iterates over all points.
//	this is line which evaluates for each combination of porosity value, alfa, and DebyePhCorrFnct
Function IR3T_SMcalcgr(alfa, porosity, gammaR)
	variable alfa, porosity, gammaR
	//input values are input numbers for each g(r) value
	//this function is returning testx = g(r) for which called IR3T_SMgr_fun is 0
	make/FREE/N=3 pWave
	pWave[0] = alfa
	pWave[1] = porosity
	pWave[2] = gammaR
	//This call finds minimum of the called function
	Optimize/I=100/H=1/L=-0.9/Q IR3T_SMOptimizeFnct, pWave
	variable result = V_MinLoc //this is x for which IR3T_SMOptimizeFnct returns 0.
	//This is completely baffling line from SAXSMorph, why is it here???
	result = result * sqrt(2.0 - result * result)
	return result //hence, this is g(r)
	// Surprise - 02-24-2018, Tested against QUintanilla method using formulas from both Quyintanilla and SAXSMorph papers and has same results
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************
//this is simply writing wrapper around our function to make it Optimize compatible.
Function IR3T_SMOptimizeFnct(w, x)
	WAVE     w
	variable x
	variable porosity = w[1]
	variable gammaR   = w[2]
	make/FREE/N=1 pWave
	pWave[0] = w[0]
	variable value
	//this calculates the integral in Formula 2 of SAXSMorph paper. Presumably, if the IR3T_SMCalcOfRInt was what is in the paper or manual.
	// Surprise - 02-24-2018, Tested against QUintanilla method using formulas from both Quyintanilla and SAXSMorph papers and has same results
	value  = Integrate1D(IR3T_SMCalcOfRInt, x, 1, 1, 50, pWave) //SAXSMorph code
	value /= 2 * pi                                             //divide by 2pi, same as Formula 2
	return abs(porosity - gammaR - value) //and this creates the minimum. Value when this is =0 is g(r) value
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************

Function IR3T_SMCalcOfRInt(pWave, xvalue) //this is integral inside Formula 2 in SAXSMorph paper, principally. But teh code makes no sense to me.
	variable xvalue
	WAVE     pWave
	variable denom, part1, part2
	variable alfa = pWave[0]
	//now, principally we should be looking at Formula 2 internals of the Integration...
	denom = sqrt(2 - xvalue * xvalue) * xvalue + 1
	part1 = 2 * exp(-1 * alfa * alfa / denom)
	part2 = sqrt(2 - xvalue * xvalue)
	//But this is different formula. So how did it get here????
	// Surprise - 02-24-2018, Tested against QUintanilla method using formulas from both Quyintanilla and SAXSMorph papers and has same results
	return part1 / part2
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************
//note, this gets same g(r) profile as we get from monkey calculation below:
//this does not produce same results as SAXSSMorph...
////threadsafe
//threadsafe Function IR3T_Formula2Main(DebyePhCorrFnct, GamAlfa0, Alfa)		//this is basically Java code calcgr...
//	variable DebyePhCorrFnct, GamAlfa0, Alfa
//	Make/N=10000/Free/D ExpWave, ExpWaveSum			//in Java it has 10000 points, but with Igor smart interpolation, may be not needed??? Check.
//	SetScale/I x 0,1,"", ExpWave, ExpWaveSum
//	ExpWave = IR3T_Formula2Exp(x,Alfa)
//	//ExpWaveSum = area(ExpWave,x,pnt2x(ExpWave, numpnts(ExpWave)-2))
//	ExpWaveSum = area(ExpWave,x,0.9998)
//	variable LookValFor=2*pi*(GamAlfa0 - DebyePhCorrFnct)
//	FindLevel/Q  ExpWaveSum, LookValFor
//	if(V_Flag==0)
//		return V_levelX
//	else
//		return 0
//	endif
//end
//
//threadsafe Function IR3T_Formula2Exp(tval,Alfa)
//	variable tval,Alfa
//
//	return exp(-1*Alfa^2/(1+tval))/(sqrt(1-tval^2))
//
//end
///*************************************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************
//
threadsafe Function IR3T_Formula4_SpectralFnct(Kvector, gR, Radii)
	variable Kvector 
	//this is Q value, or here called k
	WAVE gR, Radii
	//this sums for each k vector over all r and g(r) using paper formula 4
	Make/FREE/N=(numpnts(Radii))/D tempVals
	tempVals = (4 * pi * radii[p] * radii[p] * gR[p] * sinc(Kvector * Radii[p]))
	return abs(areaXY(Radii, tempVals))
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************
//
threadsafe Function IR3T_ConvertSpectrFtoGr(Radius, SpectralFk, Kvector)
	variable Radius 
	//this is Q value, or here called k
	WAVE SpectralFk, Kvector
	//this sums for each k vector over all r and g(r) using paper formula 4
	Make/FREE/N=(numpnts(Kvector))/D tempVals
	tempVals = (4 * pi * Kvector[p] * Kvector[p] * SpectralFk[p] * sinc(Radius * Kvector[p]))
	return abs(areaXY(Kvector, tempVals))
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************
//		This is code following SAXSMorph.

Function IR3T_GenerateMatrix(Kvalues, SpectralFk, BoxSideSize, BoxResolution, alpha)
	WAVE Kvalues, SpectralFk
	variable BoxSideSize, BoxResolution, alpha
	//alpha is number calculated above...
	//BoxResolution is number of divisions of the box called in program.
	//BoxSideSize size of box, called in program...
	//Kvalues is fk[i][0]
	//SPectralFK is fk[i][1] in original java code
	variable BoxXstep = BoxSideSize / BoxResolution
	variable BoxYstep = BoxSideSize / BoxResolution
	variable BoxZStep = BoxSideSize / BoxResolution

	//description of java code
	//get Kvalues
	//find min and max and set limits to
	variable pts = numpnts(Kvalues)
	variable i, j, k, Nn
	wavestats/Q Kvalues
	variable speckxmin = V_min
	variable speckxmax = V_max
	wavestats/Q SpectralFk
	variable speckymin  = V_min
	variable speckymax  = V_max
	variable maxk       = speckxmax
	variable mink       = speckxmin
	variable minsf      = speckymin
	variable specrange  = speckymax - speckymin
	variable randk      = 0.0
	variable randfk     = 0.0
	variable calcfk     = 0.0
	variable kamp       = 0.0
	variable IntgNumber = 10000
	variable xmax, ymax, zmax
	xmax = BoxResolution //num points per side of the box
	ymax = BoxResolution
	zmax = BoxResolution
	Make/FREE/N=(xmax, 3) rmat //this assumes xmax is at least largest, if not all same???
	//this is radius matrix, these are dimensions to match with k-vectors randomly generated...
	// BoxSideSize is real world dimension in Angstroms
	//
	//    int xmax = this.BoxResolution;
	//    int ymax = this.BoxResolution;
	//    int zmax = this.BoxResolution;
	//    for (int i = 0; i < xmax; i++)
	//    {
	//      rmat[i][0] = (i * 10.0D * this.BoxSideSize / xmax);
	//      rmat[i][1] = (i * 10.0D * this.BoxSideSize / ymax);
	//      rmat[i][2] = (i * 10.0D * this.BoxSideSize / zmax);
	//    }
	rmat[][0] = 10 * p * BoxSideSize / xmax
	rmat[][1] = 10 * p * BoxSideSize / ymax
	rmat[][2] = 10 * p * BoxSideSize / zmax
	//in the Java code there is 10.0D* this.BoxSideSize, which is confusing what is it doing...
	//looks like conversion from A to nm, but the manual indicates it is using A or nm based on Q units and that seems logical. No conversion is done as far as I can say.
	// for some reason, no clue why, this 10 is needed or we get too small features. Confusing, but with 10* it seems to get about the same results as SAXSMorph.

	make/FREE/N=3 kvec
	variable kvecnorm = 0.0
	make/FREE/N=(IntgNumber, 3) Kn
	make/FREE/N=(IntgNumber) phin
	make/FREE/N=(pts) fkx, fky
	fkx = Kvalues
	fky = SpectralFk

	print "Calculating K values"
	//phin[i] = (2*pi * abs(enoise(1)))
	multithread phin = IR3T_GeneratePhi()

	for(i = 0; i < IntgNumber; i += 1)
		do //this fills randk and randfk with random values in proper ranges
			randk  = mink + (maxk - mink) * abs(enoise(1)) // in Igor enoise(1) returns -1 to 1, in abs we should have suitable random number between 0 and 1.
			randfk = minsf + specrange * abs(enoise(1))
			//calcfk = interpolate(fkx, fky, randk);
			calcfk = interp(randk, fkx, fky) //this looks up for random k value which the model has in spectral function
			//} while (randfk > calcfk);
		while(randfk > calcfk) //accept only solutions where randfk is less than model spectral function...
		kamp    = randk
		kvec[0] = enoise(1) //same as above... , these are set to +/-1 randomly.
		kvec[1] = enoise(1)
		kvec[2] = enoise(1)
		//kvecnorm = Math.sqrt(kvec[0] * kvec[0] + kvec[1] * kvec[1] + kvec[2] * kvec[2]);
		kvecnorm = sqrt(kvec[0] * kvec[0] + kvec[1] * kvec[1] + kvec[2] * kvec[2])
		//phin[i] = (6.283185307179586D * Math.random());
		Kn[i][0] = (kvec[0] * kamp / kvecnorm)
		Kn[i][1] = (kvec[1] * kamp / kvecnorm)
		Kn[i][2] = (kvec[2] * kamp / kvecnorm)
	endfor

	//      this.TwoPhaseSolidMatrix = new MorphVoxel[xmax][ymax][zmax];
	make/O/N=(xmax, ymax, zmax)/U/B TwoPhaseSolidMatrix // TwoPhaseSolidMatrix[p][q][r] is solid (1) or Void (0)
	//need to do something...
	//this will be fun, MorphVoxel is structure with parameters such as solid/void, belongs to group, and position...
	//this creates matrix with X x Y x Z positions for each we can write MorphVoxel

	print "Calculating Gauss random fields, this is the slowest part of the code!"
	multithread TwoPhaseSolidMatrix = IR3T_GenGRFUsingCosSaxsMorph(Kn, rmat[p][0], rmat[q][1], rmat[r][2], phin, alpha)
	SetScale/P x, 0, BoxXstep, "A", TwoPhaseSolidMatrix
	SetScale/P y, 0, BoxYstep, "A", TwoPhaseSolidMatrix
	SetScale/P z, 0, BoxZStep, "A", TwoPhaseSolidMatrix

End

///*************************************************************************************************************************************
///*************************************************************************************************************************************
threadsafe Function IR3T_GeneratePhi()
	return (2 * pi * abs(enoise(1)))
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************
//
threadsafe Function IR3T_GenGRFUsingCosSaxsMorph(Kn, rmat0, rmat1, rmat2, phin, alpha) //rmat[i][0], rmat1 = rmat[j][1], rmat[k][2]
	WAVE Kn, phin
	variable alpha, rmat0, rmat1, rmat2

	//	variable sumtemp, tval
	////    Character perc = new Character(new DecimalFormatSymbols().getPercent());
	//	for (i = 0; i < xmax; i+=1)
	////      this.progress = i;
	//      for (j = 0; j < ymax; j+=1)
	//			for (k = 0; k < zmax; k+=1)
	////          double sumtemp = 0.0D;
	//				sumtemp=0
	//				for (Nn = 0; Nn < 10000; Nn+=1)
	//	            sumtemp = sumtemp + cos(Kn[Nn][0] * rmat[i][0] + Kn[Nn][1] * rmat[j][1] + Kn[Nn][2] * rmat[k][2] + phin[Nn])
	//				endfor
	////          double t = Math.sqrt(2.0D) * sumtemp / 100.0D;
	//				tval = sqrt(2) * sumtemp/100
	//	         if (tval < alpha)				//solid
	////            this.TwoPhaseSolidMatrix[i][j][k] = new MorphVoxel(true);
	////            this.TwoPhaseSolidMatrix[i][j][k].setPosition(new MatrixPosition(i, j, k));
	//						TwoPhaseSolidMatrix[i][j][k] = 1
	//	         else								//void...
	////            this.TwoPhaseSolidMatrix[i][j][k] = new MorphVoxel(false);
	////            this.TwoPhaseSolidMatrix[i][j][k].setPosition(new MatrixPosition(i, j, k));
	//						TwoPhaseSolidMatrix[i][j][k] = 0
	//				endif
	////          this.message[1] = (this.progress * 100 / this.progmax + perc.toString() + " complete...");
	//			endfor
	//		endfor
	//	endfor
	variable sumtemp = 0
	//Old method
	//		Make/Free/N=(10000) tempWv
	//		tempWv = cos(Kn[p][0] * rmat0 + Kn[p][1] * rmat1  + Kn[p][2] * rmat2 + phin[p])
	//MatrixOp solution... this seems about 10x faster...
	Make/FREE/N=(3) tmpRwv1D
	tmpRwv1D = {rmat0, rmat1, rmat2}
	MatrixOp/FREE tempWv = cos((Kn x tmpRwv1D) + phin)
	variable NumPntsK = DimSize(Kn, 0)
	//common...
	sumtemp = sum(tempWv)
	//normalize, see paper in Manual
	variable tval = sqrt(2 / NumPntsK) * sumtemp
	if(tval < alpha) //solid
		return 0
	else //void...
		return 1
	endif
	return NaN
End
///*************************************************************************************************************************************
///*************************************************************************************************************************************

static Function IR3T_Display1DTempData()

	DFREF oldDf = GetDataFolderDFR()

	NewDataFOlder/O/S root:Packages
	NewDataFOlder/O/S root:Packages:TwoPhaseSolidModel

	WAVE/Z Kvalues
	if(!WaveExists(Kvalues))
		setDataFOlder OldDf
		return 0
	endif
	WAVE DebyePhCorrFnctRadii = root:Packages:TwoPhaseSolidModel:DebyePhCorrRadii
	WAVE DebyePhCorrFnct      = root:Packages:TwoPhaseSolidModel:DebyePhCorrFnct
	DoWIndow DebyePhCorrFnctGraph
	if(V_Flag)
		DoWIndow/F DebyePhCorrFnctGraph
	else
		Display/K=1/N=DebyePhCorrFnctGraph DebyePhCorrFnct vs DebyePhCorrFnctRadii as "Debye Phase Correlation Function"
		//DoWIndow/C DebyePhCorrFnctGraph
		Label/W=DebyePhCorrFnctGraph bottom, "\\Z" + IN2G_LkUpDfltVar("AxisLabelSize") + "Radius [Angstroms]"
	endif
	//	Wave gR
	//	Wave Radii
	//	DoWIndow GrFnctGraph
	//	if(V_Flag)
	//		DoWIndow/F GrFnctGraph
	//	else
	//		Display/K=1 gR vs Radii as "G(r) Function"
	//		DoWIndow/C GrFnctGraph
	//		Label/W=GrFnctGraph bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Radius [Angstroms]"
	//	endif
	WAVE Kvalues
	WAVE SpectralFk
	DoWIndow FkFnctGraph
	if(V_Flag)
		DoWIndow/F FkFnctGraph
	else
		Display/K=1/N=FkFnctGraph SpectralFk vs Kvalues as "F(k) Function"
		//DoWIndow/C FkFnctGraph
		Label/W=FkFnctGraph bottom, "\\Z" + IN2G_LkUpDfltVar("AxisLabelSize") + "K vector [1/Angstroms]"
		ModifyGraph log=1
	endif

	setDataFOlder OldDf

End

//*****************************************************************************************************************
//*****************************************************************************************************************

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3T_TwoPhaseSolid2DImage() : Graph
	DOWindow TwoPhaseSolid2DImage
	if(V_Flag)
		DoWIndow/F TwoPhaseSolid2DImage
	else
		WAVE TwoPhaseSolidMatrix = root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrix
		PauseUpdate // building window...
		Display/W=(110, 106, 585, 640)/K=1/N=TwoPhaseSolid2DImage as "2D Image Slices"
		AppendImage/T TwoPhaseSolidMatrix
		ModifyImage TwoPhaseSolidMatrix, ctab={*, *, Grays, 1}
		ModifyImage TwoPhaseSolidMatrix, plane=0
		ModifyGraph margin(left)=14, margin(bottom)=14, margin(top)=14, margin(right)=14
		ModifyGraph mirror=2
		ModifyGraph nticks=3
		ModifyGraph minor=1
		ModifyGraph fSize=9
		ModifyGraph standoff=0
		ModifyGraph tkLblRot(left)=90
		ModifyGraph btLen=3
		ModifyGraph tlOffset=-2
		SetAxis/A/R left
		ControlBar 50
		Slider LayerSlider, pos={8.00, 3.00}, size={200.00, 47.00}, proc=IR3T_2DImageSliderProc
		Slider LayerSlider, limits={0, 100, 1}, value=0, vert=0
	endif
End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

Function IR3T_2DImageSliderProc(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch(sa.eventCode)
		case -1: // control being killed
			break
		default:
			if(sa.eventCode & 1) // value set
				variable curval = sa.curval
				//change displayed slice
				ModifyImage TwoPhaseSolidMatrix, plane=curval
			endif
			break
	endswitch

	return 0
End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3T_TwoPhaseSolidGizmo() : GizmoPlot

	//Wave TwoPhaseSolidMatrix = root:TestGammaQ:GRF3DTresh
	WAVE TwoPhaseSolidMatrix = root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrix
	//variable BoxSideSize = 10
	//variable GizmoFillSolid = 1
	NVAR BoxSideSize    = root:Packages:TwoPhaseSolidModel:BoxSideSize
	NVAR GizmoFillSolid = root:packages:TwoPhaseSolidModel:GizmoFillSolid
	KillWIndow/Z TwoPhaseSolid3D
	variable Xsize, Ysize, ZSize
	Xsize = DimDelta(TwoPhaseSolidMatrix, 0) * DimSize(TwoPhaseSolidMatrix, 0)
	Ysize = DimDelta(TwoPhaseSolidMatrix, 1) * DimSize(TwoPhaseSolidMatrix, 1)
	ZSize = DimDelta(TwoPhaseSolidMatrix, 2) * DimSize(TwoPhaseSolidMatrix, 2)
	//need to make surfaces here... AGs instructions
	//2.  I noted that the dimensions are 64x64
	//
	//make/n=(64,64) x0=FFTTwoPhaseSolid[0][p][q]
	//
	//This looks like 0-1 range and I know you are plotting 0.5 in this case.
	//
	//I created a color wave for the surface object:
	//
	//make/o/n=(64,64,4) x0ColorWave=1
	//•x0ColorWave[][][1]=0
	//•x0ColorWave[][][2]=0
	//•x0ColorWave[][][0]=x0[p][q]
	//•x0ColorWave[][][3]=x0[p][q]
	//
	//I’m setting the color of the fill to simple red.
	//You can do anything else you wish, but note that I set the alpha to zero outside the fill region.
	//I also enabled the transparency blend (from Gizmo menu).  <<< this is IMPORTANT !!!
	//
	//these are X directions
	make/O/N=(dimsize(TwoPhaseSolidMatrix, 1), dimsize(TwoPhaseSolidMatrix, 2)) x0, x1
	x0 = TwoPhaseSolidMatrix[0][p][q]
	x1 = TwoPhaseSolidMatrix[dimsize(TwoPhaseSolidMatrix, 0) - 1][p][q]

	make/O/N=(dimsize(TwoPhaseSolidMatrix, 1), dimsize(TwoPhaseSolidMatrix, 2), 4) x0ColorWave, x1ColorWave
	x0ColorWave        = 1
	x1ColorWave        = 1
	x0ColorWave[][][1] = 0
	x0ColorWave[][][2] = 0
	x0ColorWave[][][0] = x0[p][q]
	x0ColorWave[][][3] = x0[p][q]
	x1ColorWave[][][1] = 0
	x1ColorWave[][][2] = 0
	x1ColorWave[][][0] = x1[p][q]
	x1ColorWave[][][3] = x1[p][q]
	//these are y directions
	make/O/N=(dimsize(TwoPhaseSolidMatrix, 0), dimsize(TwoPhaseSolidMatrix, 2)) y0, y1
	y0 = TwoPhaseSolidMatrix[p][0][q]
	y1 = TwoPhaseSolidMatrix[p][dimsize(TwoPhaseSolidMatrix, 1) - 1][q]
	make/O/N=(dimsize(TwoPhaseSolidMatrix, 0), dimsize(TwoPhaseSolidMatrix, 2), 4) y0ColorWave, y1ColorWave
	y0ColorWave        = 1
	y1ColorWave        = 1
	y0ColorWave[][][1] = 0
	y0ColorWave[][][2] = 0
	y0ColorWave[][][0] = y0[p][q]
	y0ColorWave[][][3] = y0[p][q]
	y1ColorWave[][][1] = 0
	y1ColorWave[][][2] = 0
	y1ColorWave[][][0] = y1[p][q]
	y1ColorWave[][][3] = y1[p][q]

	//these are z directions
	make/O/N=(dimsize(TwoPhaseSolidMatrix, 0), dimsize(TwoPhaseSolidMatrix, 1)) z0, z1
	z0 = TwoPhaseSolidMatrix[p][q][0]
	z1 = TwoPhaseSolidMatrix[p][q][dimsize(TwoPhaseSolidMatrix, 2) - 1]
	make/O/N=(dimsize(TwoPhaseSolidMatrix, 0), dimsize(TwoPhaseSolidMatrix, 1), 4) z0ColorWave, z1ColorWave
	z0ColorWave        = 1
	z1ColorWave        = 1
	z0ColorWave[][][1] = 0
	z0ColorWave[][][2] = 0
	z0ColorWave[][][0] = z0[p][q]
	z0ColorWave[][][3] = z0[p][q]
	z1ColorWave[][][1] = 0
	z1ColorWave[][][2] = 0
	z1ColorWave[][][0] = z1[p][q]
	z1ColorWave[][][3] = z1[p][q]

	variable i
	//if the TwoPhaseSolidMatrix is too large, Gizmo cannot draw normals, QT limitation
	variable TotalSize    = DimSize(TwoPhaseSolidMatrix, 0) * DimSize(TwoPhaseSolidMatrix, 1) * DimSize(TwoPhaseSolidMatrix, 2)
	variable TwoSidesSize = DimSize(TwoPhaseSolidMatrix, 0) * DimSize(TwoPhaseSolidMatrix, 1)
	variable Dim3Split, Dim3Size
	Dim3Split = 0
	string SurfaceGizmoName
	NewGizmo/K=1/N=TwoPhaseSolid3D/T="TwoPhaseSolid3D"/W=(627, 70, 1142, 530)
	ModifyGizmo startRecMacro=700
	ModifyGizmo scalingOption=63
	if(TotalSize < (512 * 512 * 33)) //small enough, works.
		AppendToGizmo isoSurface=root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrix, name=TwoPhaseSolidSurface
		ModifyGizmo ModifyObject=TwoPhaseSolidSurface, objectType=isoSurface, property={surfaceColorType, 1}
		ModifyGizmo ModifyObject=TwoPhaseSolidSurface, objectType=isoSurface, property={lineColorType, 0}
		ModifyGizmo ModifyObject=TwoPhaseSolidSurface, objectType=isoSurface, property={lineWidthType, 0}
		ModifyGizmo ModifyObject=TwoPhaseSolidSurface, objectType=isoSurface, property={fillMode, 2}
		ModifyGizmo ModifyObject=TwoPhaseSolidSurface, objectType=isoSurface, property={lineWidth, 1}
		ModifyGizmo ModifyObject=TwoPhaseSolidSurface, objectType=isoSurface, property={isoValue, 0.5}
		ModifyGizmo ModifyObject=TwoPhaseSolidSurface, objectType=isoSurface, property={frontColor, 1, 0, 0, 1}
		ModifyGizmo ModifyObject=TwoPhaseSolidSurface, objectType=isoSurface, property={backColor, 0, 0, 1, 1}
		ModifyGizmo modifyObject=TwoPhaseSolidSurface, objectType=Surface, property={calcNormals, 1}
	else //split in smaller dimensions
		//find suitable sizes to plot
		if(TwoSidesSize * (DimSize(TwoPhaseSolidMatrix, 2) / 2) < (512 * 512 * 33))
			Dim3Split = 2
		elseif(TwoSidesSize * (DimSize(TwoPhaseSolidMatrix, 2) / 4) < (512 * 512 * 33))
			Dim3Split = 4
		elseif(TwoSidesSize * (DimSize(TwoPhaseSolidMatrix, 2) / 8) < (512 * 512 * 33))
			Dim3Split = 8
		elseif(TwoSidesSize * (DimSize(TwoPhaseSolidMatrix, 2) / 16) < (512 * 512 * 33))
			Dim3Split = 16
		else
			abort "Cannot split 3D solid for Gizmo display"
		endif
		print "To display in Gizmo need to split data in " + num2str(Dim3Split) + " parts"
		Dim3Size = DimSize(TwoPhaseSolidMatrix, 2) / Dim3Split
		for(i = 0; i < Dim3Split; i += 1)
			//•duplicate/r=[][][0,129] wave0,wave1
			//•duplicate/r=[][][128,] wave0,wave2
			Duplicate/O/R=[][][i * Dim3Size, Dim3Size * (i + 1)] TwoPhaseSolidMatrix, $("root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrixGizmo" + num2str(i))
			SurfaceGizmoName = "TwoPhaseSolidSurface" + num2str(i)
			AppendToGizmo isoSurface=$("root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrixGizmo" + num2str(i)), name=$SurfaceGizmoName
			ModifyGizmo ModifyObject=$SurfaceGizmoName, objectType=isoSurface, property={surfaceColorType, 1}
			ModifyGizmo ModifyObject=$SurfaceGizmoName, objectType=isoSurface, property={lineColorType, 0}
			ModifyGizmo ModifyObject=$SurfaceGizmoName, objectType=isoSurface, property={lineWidthType, 0}
			ModifyGizmo ModifyObject=$SurfaceGizmoName, objectType=isoSurface, property={fillMode, 2}
			ModifyGizmo ModifyObject=$SurfaceGizmoName, objectType=isoSurface, property={lineWidth, 1}
			ModifyGizmo ModifyObject=$SurfaceGizmoName, objectType=isoSurface, property={isoValue, 0.5}
			ModifyGizmo ModifyObject=$SurfaceGizmoName, objectType=isoSurface, property={frontColor, 1, 0, 0, 1}
			ModifyGizmo ModifyObject=$SurfaceGizmoName, objectType=isoSurface, property={backColor, 0, 0, 1, 1}
			ModifyGizmo modifyObject=$SurfaceGizmoName, objectType=Surface, property={calcNormals, 1}

		endfor
	endif

	AppendToGizmo Axes=boxAxes, name=axes0
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={-1, axisScalingMode, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={-1, axisColor, 0, 0, 0, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={0, axisLabel, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={1, axisLabel, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={2, axisLabel, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={3, axisLabel, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={4, axisLabel, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={5, axisLabel, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={6, axisLabel, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={7, axisLabel, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={8, axisLabel, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={9, axisLabel, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={10, axisLabel, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={11, axisLabel, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={0, axisLabelText, num2str(Xsize) + " [A]"}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={1, axisLabelText, num2str(Xsize) + " [A]"}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={2, axisLabelText, num2str(Xsize) + " [A]"}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={3, axisLabelText, num2str(Xsize) + " [A]"}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={4, axisLabelText, num2str(Ysize) + " [A]"}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={5, axisLabelText, num2str(Ysize) + " [A]"}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={6, axisLabelText, num2str(Ysize) + " [A]"}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={7, axisLabelText, num2str(Ysize) + " [A]"}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={8, axisLabelText, num2str(Zsize) + " [A]"}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={9, axisLabelText, num2str(Zsize) + " [A]"}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={10, axisLabelText, num2str(Zsize) + " [A]"}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={11, axisLabelText, num2str(Zsize) + " [A]"}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={0, axisLabelDistance, 0}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={1, axisLabelDistance, 0}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={2, axisLabelDistance, 0}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={3, axisLabelDistance, 0}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={4, axisLabelDistance, 0}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={5, axisLabelDistance, 0}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={6, axisLabelDistance, 0}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={7, axisLabelDistance, 0}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={8, axisLabelDistance, 0}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={9, axisLabelDistance, 0}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={10, axisLabelDistance, 0}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={11, axisLabelDistance, 0}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={0, axisLabelRGBA, 0, 0, 0, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={1, axisLabelRGBA, 0, 0, 0, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={2, axisLabelRGBA, 0, 0, 0, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={3, axisLabelRGBA, 0, 0, 0, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={4, axisLabelRGBA, 0, 0, 0, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={5, axisLabelRGBA, 0, 0, 0, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={6, axisLabelRGBA, 0, 0, 0, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={7, axisLabelRGBA, 0, 0, 0, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={8, axisLabelRGBA, 0, 0, 0, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={9, axisLabelRGBA, 0, 0, 0, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={10, axisLabelRGBA, 0, 0, 0, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={11, axisLabelRGBA, 0, 0, 0, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={0, labelBillboarding, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={1, labelBillboarding, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={2, labelBillboarding, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={3, labelBillboarding, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={4, labelBillboarding, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={5, labelBillboarding, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={6, labelBillboarding, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={7, labelBillboarding, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={8, labelBillboarding, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={9, labelBillboarding, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={10, labelBillboarding, 1}
	ModifyGizmo ModifyObject=axes0, objectType=Axes, property={11, labelBillboarding, 1}
	ModifyGizmo modifyObject=axes0, objectType=Axes, property={-1, Clipped, 0}
	AppendToGizmo light=Directional, name=light0
	ModifyGizmo modifyObject=light0, objectType=light, property={position, -0.241800, -0.664500, 0.707100, 0.000000}
	ModifyGizmo modifyObject=light0, objectType=light, property={direction, -0.241800, -0.664500, 0.707100}
	ModifyGizmo modifyObject=light0, objectType=light, property={ambient, 0.133000, 0.133000, 0.133000, 1.000000}
	ModifyGizmo modifyObject=light0, objectType=light, property={specular, 1.000000, 1.000000, 1.000000, 1.000000}
	AppendToGizmo Surface=root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrix, name=x0
	ModifyGizmo ModifyObject=x0, objectType=surface, property={surfaceColorType, 3}
	ModifyGizmo ModifyObject=x0, objectType=surface, property={srcMode, 128}
	ModifyGizmo ModifyObject=x0, objectType=surface, property={surfaceColorWave, root:Packages:TwoPhaseSolidModel:x0ColorWave}
	AppendToGizmo Surface=root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrix, name=x1
	ModifyGizmo ModifyObject=x1, objectType=surface, property={surfaceColorType, 3}
	ModifyGizmo ModifyObject=x1, objectType=surface, property={srcMode, 128}
	ModifyGizmo ModifyObject=x1, objectType=surface, property={surfaceColorWave, root:Packages:TwoPhaseSolidModel:x1ColorWave}
	ModifyGizmo ModifyObject=x1, objectType=surface, property={plane, dimsize(TwoPhaseSolidMatrix, 0) - 1}
	AppendToGizmo Surface=root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrix, name=y0
	ModifyGizmo ModifyObject=y0, objectType=surface, property={surfaceColorType, 3}
	ModifyGizmo ModifyObject=y0, objectType=surface, property={srcMode, 64}
	ModifyGizmo ModifyObject=y0, objectType=surface, property={surfaceColorWave, root:Packages:TwoPhaseSolidModel:y0ColorWave}
	AppendToGizmo Surface=root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrix, name=y1
	ModifyGizmo ModifyObject=y1, objectType=surface, property={surfaceColorType, 3}
	ModifyGizmo ModifyObject=y1, objectType=surface, property={srcMode, 64}
	ModifyGizmo ModifyObject=y1, objectType=surface, property={surfaceColorWave, root:Packages:TwoPhaseSolidModel:y1ColorWave}
	ModifyGizmo ModifyObject=y1, objectType=surface, property={plane, dimsize(TwoPhaseSolidMatrix, 1) - 1}
	AppendToGizmo Surface=root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrix, name=z0
	ModifyGizmo ModifyObject=z0, objectType=surface, property={surfaceColorType, 3}
	ModifyGizmo ModifyObject=z0, objectType=surface, property={srcMode, 32}
	ModifyGizmo ModifyObject=z0, objectType=surface, property={surfaceColorWave, root:Packages:TwoPhaseSolidModel:z0ColorWave}
	AppendToGizmo Surface=root:Packages:TwoPhaseSolidModel:TwoPhaseSolidMatrix, name=z1
	ModifyGizmo ModifyObject=z1, objectType=surface, property={surfaceColorType, 3}
	ModifyGizmo ModifyObject=z1, objectType=surface, property={srcMode, 32}
	ModifyGizmo ModifyObject=z1, objectType=surface, property={surfaceColorWave, root:Packages:TwoPhaseSolidModel:z1ColorWave}
	ModifyGizmo ModifyObject=z1, objectType=surface, property={plane, dimsize(TwoPhaseSolidMatrix, 2) - 1}
	AppendToGizmo attribute, specular={1, 1, 0, 1, 1032}, name=specular0
	AppendToGizmo attribute, shininess={5, 20}, name=shininess0
	AppendToGizmo attribute, blendFunc={770, 771}, name=blendFunc0
	ModifyGizmo setDisplayList=0, attribute=blendFunc0
	ModifyGizmo setDisplayList=1, opName=enableBlend, operation=enable, data=3042
	ModifyGizmo setDisplayList=2, object=light0
	ModifyGizmo setDisplayList=3, attribute=shininess0
	ModifyGizmo setDisplayList=4, attribute=specular0
	if(Dim3Split < 1)
		ModifyGizmo setDisplayList=5, object=TwoPhaseSolidSurface
		ModifyGizmo setDisplayList=6, object=x0
		ModifyGizmo setDisplayList=7, object=x1
		ModifyGizmo setDisplayList=8, object=y0
		ModifyGizmo setDisplayList=9, object=y1
		ModifyGizmo setDisplayList=10, object=z0
		ModifyGizmo setDisplayList=11, object=z1
		ModifyGizmo setDisplayList=12, object=axes0
		ModifyGizmo setDisplayList=13, opName=clearColor0, operation=clearColor, data={0.8, 0.8, 0.8, 1}
	else
		variable TempNum = 5
		for(i = 0; i < Dim3Split; i += 1)
			ModifyGizmo setDisplayList=(TempNum + i), object=$("TwoPhaseSolidSurface" + num2str(i))
		endfor
		ModifyGizmo setDisplayList=(TempNum + i), object=x0
		ModifyGizmo setDisplayList=(TempNum + i + 1), object=x1
		ModifyGizmo setDisplayList=(TempNum + i + 2), object=y0
		ModifyGizmo setDisplayList=(TempNum + i + 3), object=y1
		ModifyGizmo setDisplayList=(TempNum + i + 4), object=z0
		ModifyGizmo setDisplayList=(TempNum + i + 5), object=z1
		ModifyGizmo setDisplayList=(TempNum + i + 6), object=axes0
		ModifyGizmo setDisplayList=(TempNum + i + 7), opName=clearColor0, operation=clearColor, data={0.8, 0.8, 0.8, 1}
	endif
	//ModifyGizmo setDisplayList=20, opName=clearColor0, operation=clearColor, data={0.8,0.8,0.8,1}
	ModifyGizmo autoscaling=1
	ModifyGizmo currentGroupObject=""
	ModifyGizmo showInfo
	ModifyGizmo infoWindow={1335, 74, 2152, 371}
	ModifyGizmo endRecMacro
	ModifyGizmo SETQUATERNION={-0.094142, -0.281150, -0.201432, 0.933550}

	//	PauseUpdate    		// building window...
	//	// Building Gizmo 8 window...
	//	NewGizmo/K=1/T="Two Phase Solid"/W=(796,73,1311,533)
	//	DoWindow/C TwoPhaseSolid3D
	//	ModifyGizmo startRecMacro=700
	//	ModifyGizmo scalingOption=63
	//	AppendToGizmo isoSurface=TwoPhaseSolidMatrix,name=TwoPhaseSolidSurface
	//	ModifyGizmo ModifyObject=TwoPhaseSolidSurface,objectType=isoSurface,property={ surfaceColorType,1}
	//	ModifyGizmo ModifyObject=TwoPhaseSolidSurface,objectType=isoSurface,property={ lineColorType,0}
	//	ModifyGizmo ModifyObject=TwoPhaseSolidSurface,objectType=isoSurface,property={ lineWidthType,0}
	//	ModifyGizmo ModifyObject=TwoPhaseSolidSurface,objectType=isoSurface,property={ fillMode,2}
	//	ModifyGizmo ModifyObject=TwoPhaseSolidSurface,objectType=isoSurface,property={ lineWidth,1}
	//	ModifyGizmo ModifyObject=TwoPhaseSolidSurface,objectType=isoSurface,property={ isoValue,0.5}
	//	ModifyGizmo ModifyObject=TwoPhaseSolidSurface,objectType=isoSurface,property={ frontColor,1,0,0,1}
	//	ModifyGizmo ModifyObject=TwoPhaseSolidSurface,objectType=isoSurface,property={ backColor,0,0,1,1}
	//	ModifyGizmo modifyObject=TwoPhaseSolidSurface,objectType=Surface,property={calcNormals,1}
	//	AppendToGizmo Axes=boxAxes,name=axes0
	//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={-1,axisScalingMode,1}
	//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={-1,axisColor,0,0,0,1}
	//	//ModifyGizmo modifyObject=axes0,objectType=Axes,property={-1,calcNormals,1}
	//	ModifyGizmo modifyObject=axes0,objectType=Axes,property={-1,Clipped,0}
	//	AppendToGizmo light=Directional,name=light0
	//	ModifyGizmo modifyObject=light0,objectType=light,property={ position,-0.241800,-0.664500,0.707100,0.000000}
	//	ModifyGizmo modifyObject=light0,objectType=light,property={ direction,-0.241800,-0.664500,0.707100}
	//	ModifyGizmo modifyObject=light0,objectType=light,property={ ambient,0.133000,0.133000,0.133000,1.000000}
	//	ModifyGizmo modifyObject=light0,objectType=light,property={ specular,1.000000,1.000000,1.000000,1.000000}
	//	//this is 3D voxelgram "filler"
	//	AppendToGizmo voxelgram=TwoPhaseSolidMatrix,name=Solid
	//	ModifyGizmo ModifyObject=Solid,objectType=voxelgram,property={ valueRGBA,0,GizmoFillSolid,0.000015,0.195544,0.800000,1.000000}
	//	ModifyGizmo ModifyObject=Solid,objectType=voxelgram,property={ mode,0}
	//	ModifyGizmo ModifyObject=Solid,objectType=voxelgram,property={ pointSize,8}
	//	///
	//	AppendToGizmo attribute specular={1,1,0,1,1032},name=specular0
	//	AppendToGizmo attribute shininess={5,20},name=shininess0
	//	ModifyGizmo setDisplayList=0, object=light0
	//	ModifyGizmo setDisplayList=1, attribute=shininess0
	//	ModifyGizmo setDisplayList=2, attribute=specular0
	//	ModifyGizmo setDisplayList=3, object=Solid
	//	ModifyGizmo setDisplayList=4, object=TwoPhaseSolidSurface
	//	ModifyGizmo setDisplayList=5, object=axes0
	//	ModifyGizmo setDisplayList=6, opName=clearColor, operation=clearColor, data={0.8,0.8,0.8,1}
	//
	//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={ -1,axisLabel,1}
	//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={ -1,axisLabelText,num2str(BoxSideSize)+" [A]"}
	//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={ 1,axisLabelText,num2str(BoxSideSize)+" [A]"}
	//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={ 2,axisLabelText,num2str(BoxSideSize)+" [A]"}
	//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={-1,axisLabelCenter,0}
	//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={ -1,axisLabelDistance,0}
	//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={ -1,axisLabelScale,1}
	//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={ -1,axisLabelRGBA,0.000000,0.000000,0.000000,1.000000}
	//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={ -1,axisLabelTilt,0}
	//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={-1,axisLabelFont,"default"}
	//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={ -1,axisLabelFlip,0}
	//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={ -1,labelBillboarding,1}
	//
	//	ModifyGizmo autoscaling=1
	//	ModifyGizmo currentGroupObject=""
	//	ModifyGizmo showInfo
	//	ModifyGizmo infoWindow={639,659,1456,956}
	//	ModifyGizmo endRecMacro
	//	ModifyGizmo SETQUATERNION={-0.092963,-0.838295,-0.165945,0.510964}
End

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3T_FixGizmoDisplay()

	NVAR GizmoFillSolid = root:packages:TwoPhaseSolidModel:GizmoFillSolid

	DoWIndow TwoPhaseSolid3D
	if(V_Flag)
		//		ModifyGizmo/N=TwoPhaseSolid3D ModifyObject=Solid,objectType=voxelgram,property={ valueRGBA,0,GizmoFillSolid,0.000015,0.195544,0.800000,1.000000}
		print "I do nothing, Solid object does not exist for some reason"
	endif
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
