#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method and strict wave access.
#pragma version=1.00

//*************************************************************************\
//* Copyright (c) 2005 - 2025, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution.
//*************************************************************************/
Constant IR3NAnisSystemVersionNumber = 1

//1.00 first version, added code for Hermans Orientation Parameter

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//			Anisotropy packages, 2019-03-15
//******************************************************************************************************************************************************

Function IR3N_AnisotropicSystems()
	//this calls GUI controlling code for ANisotropic systems.
	KillWIndow/Z AnisotropicSystemsPanel
	KillWIndow/Z AnisotropicSystemsPlot
	IN2G_CheckScreenSize("height", 670)
	IR3N_InitAnisotropicSystems()
	IR3N_AnisotropicSystemsPanel()
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("AnisotropicSystemsPanel", IR3NAnisSystemVersionNumber, 1)
End

//******************************************************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3N_MainCheckVersion()
	//this needs to get more of these lines for each tool/panel...
	DoWindow TwoPhaseSystems
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("AnisotropicSystemsPanel", IR3NAnisSystemVersionNumber))
			DoAlert/T="The Anisotropy analysis panel was created by incorrect version of Irena " 1, "Anisotropic Systems tool may need to be restarted to work properly. Restart now?"
			if(V_flag == 1)
				DoWindow/K AnisotropicSystemsPanel
				IR3N_AnisotropicSystems()
			else //at least reinitialize the variables so we avoid major crashes...
				IR3N_InitAnisotropicSystems()
			endif
		endif
	endif
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//******************************************************************************************************************************************************
//*****************************************************************************************************************

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR3N_AnisotropicSystemsPanel()
	PauseUpdate // building window...
	NewPanel/K=1/W=(2.25, 43.25, 396, 720)/N=AnisotropicSystemsPanel as "Anisotropic Systems"
	//DefaultGUIControls /W=TwoPhaseSystems ///Mac os9
	string UserDataTypes  = "r*;"
	string UserNameString = "Nika Az data"
	string XUserLookup    = "r*:az*;"
	string EUserLookup    = "r*:s*;"
	IR2C_AddDataControls("AnisotropicSystems", "AnisotropicSystemsPanel", "", "", UserDataTypes, UserNameString, XUserLookup, EUserLookup, 0, 0)
	NVAR UseUserDefinedData = root:Packages:AnisotropicSystems:UseUserDefinedData
	NVAR UseIndra2Data      = root:Packages:AnisotropicSystems:UseIndra2Data
	NVAR UseQRSdata         = root:Packages:AnisotropicSystems:UseQRSdata
	NVAR UseModelData       = root:Packages:AnisotropicSystems:UseModelData
	UseUserDefinedData = 1
	UseModelData       = 0
	UseQRSdata         = 0
	UseIndra2Data      = 0
	CheckBox UseModelData, disable=1
	CheckBox UseUserDefinedData, pos={120, 35}
	CheckBox UseQRSdata, disable=1

	TitleBox MainTitle, title="\Zr200Anisotropy Evalution", pos={20, 0}, frame=0, fstyle=3, fixedSize=1, font="Times New Roman", size={350, 24}, anchor=MC, fColor=(0, 0, 52224)
	TitleBox Info1, title="\Zr150Data input", pos={10, 30}, frame=0, fstyle=1, fixedSize=1, size={80, 20}, fColor=(0, 0, 52224)
	Button DrawGraphs, pos={225, 158}, size={150, 20}, proc=IR3N_AniSysButtonProc, title="Graph data", help={"Create a graph (log-log) of your experiment data"}
	Button GetHelp, pos={305, 105}, size={80, 15}, fColor=(65535, 32768, 32768), proc=IR3N_AniSysButtonProc, title="Get Help", help={"Open www manual page for this tool"} //<<< fix button to help!!!
	TitleBox FakeLine1, title=" ", fixedSize=1, size={330, 3}, pos={16, 181}, frame=0, fColor=(0, 0, 52224), labelBack=(0, 0, 52224)
	TitleBox Info2, title="\Zr150Model", pos={10, 195}, frame=0, fstyle=2, fixedSize=1, size={150, 20}, fColor=(0, 0, 52224)

	SVAR PeakProfileShape = root:Packages:AnisotropicSystems:PeakProfileShape
	PopupMenu PeakProfileShape, pos={120, 212}, size={380, 21}, proc=IR3N_AniSysPopMenuProc, title="Peak Profile shape :", help={"Select method to fit the peak profile "}
	PopupMenu PeakProfileShape, mode=2, popvalue=PeakProfileShape, value=#"\"Gauss;Lorenz;\""
	Button FitPeak, pos={125, 245}, size={150, 20}, proc=IR3N_AniSysButtonProc, title="Fit Peak", help={"Fit peak profile and calcualte parameters"}

	SetVariable PeakCenterDegrees, limits={-180, 360, 0}, value=root:Packages:AnisotropicSystems:PeakCenterDegrees, bodyWidth=80 //proc=IR1A_PanelSetVarProc
	SetVariable PeakCenterDegrees, pos={10, 275}, size={260, 20}, title="Peak Center [Degrees]", noproc, help={"Peak Center in Degrees"}, format="%0.5g"
	SetVariable WidthDegrees, limits={-180, 360, 0}, value=root:Packages:AnisotropicSystems:WidthDegrees, bodyWidth=80 //proc=IR1A_PanelSetVarProc
	SetVariable WidthDegrees, pos={10, 300}, size={260, 20}, title="Peak Width [Degrees]", noproc, help={"Peak width in Degrees"}, disable=2, format="%0.4g"
	TitleBox Info3, title="\Zr120Fit Peak to get center, or input center manually", pos={30, 335}, frame=0, fstyle=1, fixedSize=1, size={300, 20}, fColor=(0, 0, 0)

	Button FitHOP, pos={125, 365}, size={150, 20}, proc=IR3N_AniSysButtonProc, title="Fit HOP", help={"Fit peak profile and calcualte parameters"}

	SetVariable HOPAverage, limits={-180, 360, 0}, value=root:Packages:AnisotropicSystems:HOPAverage, bodyWidth=80 //proc=IR1A_PanelSetVarProc
	SetVariable HOPAverage, pos={10, 400}, size={260, 20}, title="HOP (average)", noproc, help={"HOP"}, disable=2, format="%0.3g"
	SetVariable HOPLeft, limits={-180, 360, 0}, value=root:Packages:AnisotropicSystems:HOPLeft, bodyWidth=80 //proc=IR1A_PanelSetVarProc
	SetVariable HOPLeft, pos={10, 425}, size={260, 20}, title="HOP (left)", noproc, help={"HOP left of peak"}, disable=2, format="%0.3g"
	SetVariable HOPRight, limits={-180, 360, 0}, value=root:Packages:AnisotropicSystems:HOPRight, bodyWidth=80 //proc=IR1A_PanelSetVarProc
	SetVariable HOPRight, pos={10, 450}, size={260, 20}, title="HOP (right)", noproc, help={"HOP right of peak"}, disable=2, format="%0.3g"
	SetVariable HOPAngleStart, limits={-180, 360, 0}, value=root:Packages:AnisotropicSystems:HOPAngleStart, bodyWidth=80 //proc=IR1A_PanelSetVarProc
	SetVariable HOPAngleStart, pos={10, 475}, size={260, 20}, title="HOP start Angle [Degrees]", noproc, help={"HOP start angle in Degrees"}, disable=2, format="%0.3g"
	SetVariable HOPAngleEnd, limits={-180, 360, 0}, value=root:Packages:AnisotropicSystems:HOPAngleEnd, bodyWidth=80 //proc=IR1A_PanelSetVarProc
	SetVariable HOPAngleEnd, pos={10, 500}, size={260, 20}, title="HOP end Angle [Degrees]", noproc, help={"HOP end angle in Degrees"}, disable=2, format="%0.3g"

	TitleBox Info4, title="\Zr100HOP (average) is the most likely correct result", pos={30, 530}, frame=0, fixedSize=1, size={300, 20}, fColor=(0, 0, 0)
	TitleBox Info5, title="\Zr100HOP left & right shoudl be abotu the same", pos={30, 545}, frame=0, fixedSize=1, size={300, 20}, fColor=(0, 0, 0)

	Button SaveResults, pos={125, 570}, size={150, 20}, proc=IR3N_AniSysButtonProc, title="Save results (notebook)", help={"Store results and graph to notebook"}

End

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3N_AniSysPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch(pa.eventCode)
		case 2: // mouse up
			variable popNum = pa.popNum
			string   popStr = pa.popStr
			if(StringMatch(pa.ctrlName, "PeakProfileShape"))
				SVAR PeakProfileShape = root:Packages:AnisotropicSystems:PeakProfileShape
				PeakProfileShape = popStr
			endif

			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

Function IR3N_AniSysButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch(ba.eventCode)
		case 2: // mouse up
			// click code here
			DFREF oldDf = GetDataFolderDFR()

			setDataFolder root:Packages:AnisotropicSystems

			if(cmpstr(ba.ctrlName, "DrawGraphs") == 0)
				//here goes what is done, when user pushes Graph button
				SVAR     DFloc         = root:Packages:AnisotropicSystems:DataFolderName
				SVAR     DFInt         = root:Packages:AnisotropicSystems:IntensityWaveName
				SVAR     DFQ           = root:Packages:AnisotropicSystems:QWaveName
				SVAR     DFE           = root:Packages:AnisotropicSystems:ErrorWaveName
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
					//IR1A_FixTabsInPanel()
					IR3N_CopyAndGraphInputData()
					IR3N_ResetParameters()
					MoveWindow/W=AnisotropicSystemsPlot 0, 0, (IN2G_GetGraphWidthHeight("width")), (0.6 * IN2G_GetGraphWidthHeight("height"))
					AutoPositionWIndow/M=0/R=AnisotropicSystemsPanel AnisotropicSystemsPlot
				else
					Abort "Data not selected properly"
				endif
			endif
			if(StringMatch(ba.ctrlName, "FitPeak"))
				IR3N_FitPeakOnDataData()
				//to test original code results, uncomment next 3 lines...
				//Wave OriginalIntensity = root:Packages:AnisotropicSystems:OriginalIntensity
				//Wave OriginalAZvector = root:Packages:AnisotropicSystems:OriginalAZvector
				//IR3N_HOP(OriginalIntensity,OriginalAZvector)
			endif
			if(StringMatch(ba.ctrlName, "FitHOP"))
				IR3N_FitHOPOnDataData()
				//to test original code results, uncomment next 3 lines...
				//Wave OriginalIntensity = root:Packages:AnisotropicSystems:OriginalIntensity
				//Wave OriginalAZvector = root:Packages:AnisotropicSystems:OriginalAZvector
				//IR3N_HOP(OriginalIntensity,OriginalAZvector)
			endif

			if(StringMatch(ba.ctrlName, "GetHelp"))
				//Open www manual with the right page
				IN2G_OpenWebManual("Irena/AnisotropyAnalysis.html")
			endif
			if(StringMatch(ba.ctrlName, "SaveResults"))
				IR3N_SaveResultsToNotebook()
			endif

			setDataFolder oldDF
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//******************************************************************************************************************************************************
//*****************************************************************************************************************
///******************************************************************************************
static Function IR3N_ResetParameters()

	NVAR HOPAngleStart     = root:Packages:AnisotropicSystems:HOPAngleStart
	NVAR HOPAngleEnd       = root:Packages:AnisotropicSystems:HOPAngleEnd
	NVAR PeakCenterDegrees = root:Packages:AnisotropicSystems:PeakCenterDegrees
	NVAR HOPRight          = root:Packages:AnisotropicSystems:HOPRight
	NVAR HOPLeft           = root:Packages:AnisotropicSystems:HOPLeft
	NVAR HOPAverage        = root:Packages:AnisotropicSystems:HOPAverage
	NVAR WidthDegrees      = root:Packages:AnisotropicSystems:WidthDegrees
	HOPAngleStart = 0
	HOPAngleEnd   = 0
	HOPRight      = 0
	HOPLeft       = 0
	HOPAverage    = 0
	WidthDegrees  = 0

End

//*****************************************************************************************************************

static Function IR3N_SaveResultsToNotebook()

	IR1_CreateResultsNbk()

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:AnisotropicSystems

	SVAR DataFolderName    = root:Packages:AnisotropicSystems:DataFolderName
	SVAR IntensityWaveName = root:Packages:AnisotropicSystems:IntensityWaveName
	SVAR AZWavename        = root:Packages:AnisotropicSystems:QWavename
	SVAR ErrorWaveName     = root:Packages:AnisotropicSystems:ErrorWaveName
	SVAR PeakProfileShape  = root:Packages:AnisotropicSystems:PeakProfileShape
	NVAR HOPAngleStart     = root:Packages:AnisotropicSystems:HOPAngleStart
	NVAR HOPAngleEnd       = root:Packages:AnisotropicSystems:HOPAngleEnd
	NVAR PeakCenterDegrees = root:Packages:AnisotropicSystems:PeakCenterDegrees
	NVAR HOPRight          = root:Packages:AnisotropicSystems:HOPRight
	NVAR HOPLeft           = root:Packages:AnisotropicSystems:HOPLeft
	NVAR HOPAverage        = root:Packages:AnisotropicSystems:HOPAverage
	NVAR WidthDegrees      = root:Packages:AnisotropicSystems:WidthDegrees

	IR1_AppendAnyText("\r Results of Hermans orientation parameter fitting\r", 1)
	IR1_AppendAnyText("Date & time: \t" + Date() + "   " + time(), 0)
	IR1_AppendAnyText("Data from folder: \t" + DataFolderName, 0)
	IR1_AppendAnyText("Intensity: \t" + IntensityWaveName, 0)
	IR1_AppendAnyText("Azimuthal angle: \t" + AZWavename, 0)
	IR1_AppendAnyText("Error (used for fitting): \t" + ErrorWaveName, 0)
	IR1_AppendAnyText(" ", 0)
	string FittingResults = ""
	FittingResults += "\rAssumed peak profile shape : \t" + PeakProfileShape + "\r"
	FittingResults += "Peak center [deg] \t= " + num2str(PeakCenterDegrees) + "\rPeak width [deg]\t= " + num2str(WidthDegrees) + "\r"
	FittingResults += "Hermans orientional parameter \t= " + num2str(HOPAverage) + "\r"
	FittingResults += "HOP left \t= " + num2str(HOPLeft) + "\rHOP right \t= " + num2str(HOPRight) + "\r"
	IR1_AppendAnyGraph("AnisotropicSystemsPlot")
	IR1_AppendAnyText(" ", 0)
	IR1_AppendAnyText(FittingResults, 0)
	IR1_AppendAnyText("******************************************\r", 0)
	SetDataFolder OldDf
	SVAR/Z nbl = root:Packages:Irena:ResultsNotebookName
	DoWindow/F $nbl
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//******************************************************************************************************************************************************

static Function IR3N_FitPeakOnDataData()
	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:AnisotropicSystems

	WAVE/Z OriginalIntensity = root:Packages:AnisotropicSystems:OriginalIntensity
	WAVE/Z OriginalAZvector  = root:Packages:AnisotropicSystems:OriginalAZvector
	if(!WaveExists(OriginalIntensity) || !WaveExists(OriginalAZvector))
		print "Data do not exist, end here"
		setDataFolder oldDF
		abort
	endif
	WAVE/Z OriginalError = root:Packages:AnisotropicSystems:OriginalError
	if(!WaveExists(OriginalError))
		Duplicate/O OriginalIntensity, OriginalError
		WAVE OriginalError
		OriginalError *= 0.02 //2% uncertainty, should be OK for all poitns
	endif
	variable CursorAPos, CursorBPos
	if(strlen(CsrInfo(A, "AnisotropicSystemsPlot")) < 1 || strlen(CsrInfo(B, "AnisotropicSystemsPlot")) < 1)
		DoAlert/T="Cursors are not set" 0, "Set cursors A and B to select the peak to analyze."
		setDataFolder oldDF
		abort
	endif
	CursorAPos = pcsr(A, "AnisotropicSystemsPlot")
	CursorBPos = pcsr(B, "AnisotropicSystemsPlot")
	SVAR PeakProfileShape  = root:Packages:AnisotropicSystems:PeakProfileShape
	NVAR HOPAngleStart     = root:Packages:AnisotropicSystems:HOPAngleStart
	NVAR HOPAngleEnd       = root:Packages:AnisotropicSystems:HOPAngleEnd
	NVAR PeakCenterDegrees = root:Packages:AnisotropicSystems:PeakCenterDegrees
	NVAR HOPRight          = root:Packages:AnisotropicSystems:HOPRight
	NVAR HOPLeft           = root:Packages:AnisotropicSystems:HOPLeft
	NVAR HOPAverage        = root:Packages:AnisotropicSystems:HOPAverage
	NVAR WidthDegrees      = root:Packages:AnisotropicSystems:WidthDegrees
	DoWIndow AnisotropicSystemsPlot
	if(!V_Flag)
		abort "Graph does not exist..."
	endif
	DoWIndow/F AnisotropicSystemsPlot
	RemoveFromGraph/W=AnisotropicSystemsPlot/Z fit_OriginalIntensity
	if(stringMatch(PeakProfileShape, "Gauss"))
		CurveFit/Q/N/TBOX=768 gauss, OriginalIntensity[pcsr(A, "AnisotropicSystemsPlot"), pcsr(B, "AnisotropicSystemsPlot")]/X=OriginalAZvector/W=OriginalError/I=1/D
		ModifyGraph/W=AnisotropicSystemsPlot lstyle(fit_OriginalIntensity)=7, rgb(fit_OriginalIntensity)=(0, 0, 65535), lsize(fit_OriginalIntensity)=3
		WAVE W_coef
		PeakCenterDegrees = W_coef[2]
		WidthDegrees      = W_coef[3]
	elseif(stringMatch(PeakProfileShape, "Lorenz"))
		CurveFit/Q/N/TBOX=768 lor, OriginalIntensity[pcsr(A, "AnisotropicSystemsPlot"), pcsr(B, "AnisotropicSystemsPlot")]/X=OriginalAZvector/W=OriginalError/I=1/D
		ModifyGraph/W=AnisotropicSystemsPlot lstyle(fit_OriginalIntensity)=7, rgb(fit_OriginalIntensity)=(0, 0, 65535), lsize(fit_OriginalIntensity)=3
		WAVE W_coef
		PeakCenterDegrees = W_coef[2]
		WAVE fit_OriginalIntensity
		wavestats/Q fit_OriginalIntensity
		FindLevels/Q fit_OriginalIntensity, V_max / 2
		WAVE W_FindLevels
		WidthDegrees = abs(pnt2x(fit_OriginalIntensity, W_FindLevels[1]) - pnt2x(fit_OriginalIntensity, W_FindLevels[0]))
	endif
	if(WidthDegrees > 150)
		setDataFolder oldDF
		ABort "Too wide peak, it makes no sense to calcualte HOP"
	endif
	//	//now calculate HOP
	//	//Calculates Hermans Orientation Parameter
	//	//P. C. van der Heijden, L. Rubatat, O. Diat, Macromolecules 2004, 37, 5327.
	//	//Check L.E. Alexander, R.J. Roe, etc.
	//	//ASSUMES INPUT ANGLE DATA IS IN DEGREES
	//	//Integration from 0 to pi/2 input directly in AreaXY command
	//	Duplicate/FREE OriginalIntensity, HOPIntensity
	//	Duplicate/FREE OriginalAZvector, HOPAZvector
	//	if(PeakCenterDegrees<90)		//peak was too close to negative edge, not enough data... Need to rotate data around.
	//		Duplicate/FREE HOPAZvector, HOPAZvector2
	//		HOPAZvector2 = -360+HOPAZvector
	//		Concatenate/O/NP {HOPIntensity,HOPIntensity}, HOPIntensityExtended
	//		Concatenate/O/NP {HOPAZvector2,HOPAZvector}, HOPAZvectorExtended
	//	elseif(PeakCenterDegrees>270)	//peak was too close to edge, not enough data... Need to ratate data around.
	//		Duplicate/FREE HOPAZvector, HOPAZvector2
	//		HOPAZvector2 = 360+HOPAZvector
	//		Concatenate/O/NP {HOPIntensity,HOPIntensity}, HOPIntensityExtended
	//		Concatenate/O/NP {HOPAZvector,HOPAZvector2}, HOPAZvectorExtended
	//	else
	//		Duplicate/FREE 	HOPIntensity, HOPIntensityExtended
	//		Duplicate/FREE 	HOPAZvector, HOPAZvectorExtended
	//	endif
	//	//now center this on peak center
	//	HOPAZvectorExtended = HOPAZvectorExtended - PeakCenterDegrees
	////	Display/K=1 HOPIntensityExtended vs HOPAZvectorExtended
	////	variable HOPCenterPoint = BinarySearchInterp(HOPAZvector, PeakCenterDegrees )
	////	HOPAZvectorRad *=pi/180
	//	Duplicate/FREE HOPIntensityExtended, HOPTopPart, HOPBottomPart
	//	Duplicate/FREE HOPAZvectorExtended, HOPAZvectorExtendedRad
	//	HOPAZvectorExtendedRad *= pi/180
	//	HOPTopPart = HOPIntensityExtended[p] * sin(HOPAZvectorExtendedRad[p]) *(cos(HOPAZvectorExtendedRad[p])^2)
	//	HOPBottomPart = HOPIntensityExtended[p] * sin(HOPAZvectorExtendedRad[p])
	//	variable UpperVal, lowerVal
	//	//left part:
	//	UpperVal = areaXY(HOPAZvectorExtendedRad,HOPTopPart,0,pi/2)
	//	lowerVal = areaXY(HOPAZvectorExtendedRad,HOPBottomPart,0,pi/2)
	//	HOPRight = (3*(upperval/lowerval)-1)/2
	//	//right part:
	//	UpperVal = areaXY(HOPAZvectorExtendedRad,HOPTopPart,-1*pi/2,0)
	//	lowerVal = areaXY(HOPAZvectorExtendedRad,HOPBottomPart,-1*pi/2,0)
	//	HOPLeft = (3*(upperval/lowerval)-1)/2
	//	//average HOP:
	//	HOPAverage = (HOPRight + HOPLeft)/2
	//	HOPAngleStart = PeakCenterDegrees - 90
	//	HOPAngleEnd = PeakCenterDegrees + 90
	//	string TagHOPResults="        Hermans Orientation Parameter \r"
	//	TagHOPResults+="van der Heijden, et.al., Macromolecules 2004, 37, 5327 \r"
	//	TagHOPResults+=" HOP \t=\t"+num2str(HOPAverage)
	//	TextBox/C/N=HOPResults/A=LT/W=AnisotropicSystemsPlot TagHOPResults
	setDataFolder oldDF
End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR3N_FitHOPOnDataData()
	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:AnisotropicSystems

	WAVE/Z OriginalIntensity = root:Packages:AnisotropicSystems:OriginalIntensity
	WAVE/Z OriginalAZvector  = root:Packages:AnisotropicSystems:OriginalAZvector
	if(!WaveExists(OriginalIntensity) || !WaveExists(OriginalAZvector))
		print "Data do not exist, end here"
		setDataFolder oldDF
		abort
	endif
	WAVE/Z OriginalError = root:Packages:AnisotropicSystems:OriginalError
	if(!WaveExists(OriginalError))
		Duplicate/O OriginalIntensity, OriginalError
		WAVE OriginalError
		OriginalError *= 0.02 //2% uncertainty, should be OK for all poitns
	endif
	//	variable CursorAPos, CursorBPos
	//	if(strlen(CsrInfo(A , "AnisotropicSystemsPlot"))<1 ||strlen(CsrInfo(B , "AnisotropicSystemsPlot"))<1 )
	//		DoAlert /T="Cursors are not set"  0, "Set cursors A and B to select the peak to analyze."
	//		setDataFolder oldDF
	//		abort
	//	endif
	//	CursorAPos = pcsr(A , "AnisotropicSystemsPlot")
	//	CursorBPos =  pcsr(B , "AnisotropicSystemsPlot")
	SVAR PeakProfileShape  = root:Packages:AnisotropicSystems:PeakProfileShape
	NVAR HOPAngleStart     = root:Packages:AnisotropicSystems:HOPAngleStart
	NVAR HOPAngleEnd       = root:Packages:AnisotropicSystems:HOPAngleEnd
	NVAR PeakCenterDegrees = root:Packages:AnisotropicSystems:PeakCenterDegrees
	NVAR HOPRight          = root:Packages:AnisotropicSystems:HOPRight
	NVAR HOPLeft           = root:Packages:AnisotropicSystems:HOPLeft
	NVAR HOPAverage        = root:Packages:AnisotropicSystems:HOPAverage
	NVAR WidthDegrees      = root:Packages:AnisotropicSystems:WidthDegrees
	DoWIndow AnisotropicSystemsPlot
	if(!V_Flag)
		abort "Graph does not exist..."
	endif
	DoWIndow/F AnisotropicSystemsPlot
	//	RemoveFromGraph /W=AnisotropicSystemsPlot /Z fit_OriginalIntensity
	//	if(stringMatch(PeakProfileShape,"Gauss"))
	//		CurveFit/Q/N/TBOX=768 gauss OriginalIntensity[pcsr(A, "AnisotropicSystemsPlot"),pcsr(B, "AnisotropicSystemsPlot")] /X=OriginalAZvector /W=OriginalError /I=1 /D
	//		ModifyGraph/W=AnisotropicSystemsPlot lstyle(fit_OriginalIntensity)=7,rgb(fit_OriginalIntensity)=(0,0,65535),lsize(fit_OriginalIntensity)=3
	//		wave W_coef
	//		PeakCenterDegrees = W_coef[2]
	//		WidthDegrees = W_coef[3]
	//	elseif(stringMatch(PeakProfileShape,"Lorenz"))
	//		CurveFit/Q/N/TBOX=768 lor OriginalIntensity[pcsr(A, "AnisotropicSystemsPlot"),pcsr(B, "AnisotropicSystemsPlot")] /X=OriginalAZvector /W=OriginalError /I=1 /D
	//		ModifyGraph/W=AnisotropicSystemsPlot lstyle(fit_OriginalIntensity)=7,rgb(fit_OriginalIntensity)=(0,0,65535),lsize(fit_OriginalIntensity)=3
	//		wave W_coef
	//		PeakCenterDegrees = W_coef[2]
	//		Wave fit_OriginalIntensity
	//		wavestats/Q fit_OriginalIntensity
	//		FindLevels/Q  fit_OriginalIntensity, V_max/2
	//		Wave W_FindLevels
	//		WidthDegrees = abs(pnt2x(fit_OriginalIntensity, W_FindLevels[1] ) - pnt2x(fit_OriginalIntensity, W_FindLevels[0] ))
	//	endif
	//	if(WidthDegrees>150)
	//		setDataFolder oldDF
	//		ABort "Too wide peak, it makes no sense to calcualte HOP"
	//	endif
	//now calculate HOP
	//Calculates Hermans Orientation Parameter
	//P. C. van der Heijden, L. Rubatat, O. Diat, Macromolecules 2004, 37, 5327.
	//Check L.E. Alexander, R.J. Roe, etc.
	//ASSUMES INPUT ANGLE DATA IS IN DEGREES
	//Integration from 0 to pi/2 input directly in AreaXY command
	Duplicate/FREE OriginalIntensity, HOPIntensity
	Duplicate/FREE OriginalAZvector, HOPAZvector
	if(PeakCenterDegrees < 90) //peak was too close to negative edge, not enough data... Need to rotate data around.
		Duplicate/FREE HOPAZvector, HOPAZvector2
		HOPAZvector2 = -360 + HOPAZvector
		Concatenate/O/NP {HOPIntensity, HOPIntensity}, HOPIntensityExtended
		Concatenate/O/NP {HOPAZvector2, HOPAZvector}, HOPAZvectorExtended
	elseif(PeakCenterDegrees > 270) //peak was too close to edge, not enough data... Need to ratate data around.
		Duplicate/FREE HOPAZvector, HOPAZvector2
		HOPAZvector2 = 360 + HOPAZvector
		Concatenate/O/NP {HOPIntensity, HOPIntensity}, HOPIntensityExtended
		Concatenate/O/NP {HOPAZvector, HOPAZvector2}, HOPAZvectorExtended
	else
		Duplicate/FREE HOPIntensity, HOPIntensityExtended
		Duplicate/FREE HOPAZvector, HOPAZvectorExtended
	endif
	//now center this on peak center
	HOPAZvectorExtended = HOPAZvectorExtended - PeakCenterDegrees
	//	Display/K=1 HOPIntensityExtended vs HOPAZvectorExtended
	//	variable HOPCenterPoint = BinarySearchInterp(HOPAZvector, PeakCenterDegrees )
	//	HOPAZvectorRad *=pi/180
	Duplicate/FREE HOPIntensityExtended, HOPTopPart, HOPBottomPart
	Duplicate/FREE HOPAZvectorExtended, HOPAZvectorExtendedRad
	HOPAZvectorExtendedRad *= pi / 180
	HOPTopPart              = HOPIntensityExtended[p] * sin(HOPAZvectorExtendedRad[p]) * (cos(HOPAZvectorExtendedRad[p])^2)
	HOPBottomPart           = HOPIntensityExtended[p] * sin(HOPAZvectorExtendedRad[p])
	variable UpperVal, lowerVal
	//left part:
	UpperVal = areaXY(HOPAZvectorExtendedRad, HOPTopPart, 0, pi / 2)
	lowerVal = areaXY(HOPAZvectorExtendedRad, HOPBottomPart, 0, pi / 2)
	HOPRight = (3 * (upperval / lowerval) - 1) / 2
	//right part:
	UpperVal = areaXY(HOPAZvectorExtendedRad, HOPTopPart, -1 * pi / 2, 0)
	lowerVal = areaXY(HOPAZvectorExtendedRad, HOPBottomPart, -1 * pi / 2, 0)
	HOPLeft  = (3 * (upperval / lowerval) - 1) / 2
	//average HOP:
	HOPAverage    = (HOPRight + HOPLeft) / 2
	HOPAngleStart = PeakCenterDegrees - 90
	HOPAngleEnd   = PeakCenterDegrees + 90
	string TagHOPResults = "        Hermans Orientation Parameter \r"
	TagHOPResults += "van der Heijden, et.al., Macromolecules 2004, 37, 5327 \r"
	TagHOPResults += " HOP \t=\t" + num2str(HOPAverage)
	TextBox/C/N=HOPResults/A=LT/W=AnisotropicSystemsPlot TagHOPResults
	setDataFolder oldDF
End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
static Function IR3N_CopyAndGraphInputData()
	//this function graphs data into the various graphs as needed

	DFREF oldDf = GetDataFolderDFR()

	setDataFolder root:Packages:AnisotropicSystems
	SVAR DataFolderName    = root:Packages:AnisotropicSystems:DataFolderName
	SVAR IntensityWaveName = root:Packages:AnisotropicSystems:IntensityWaveName
	SVAR AZWavename        = root:Packages:AnisotropicSystems:QWavename
	SVAR ErrorWaveName     = root:Packages:AnisotropicSystems:ErrorWaveName
	variable cursorAposition, cursorBposition

	//fix for liberal names
	IntensityWaveName = PossiblyQuoteName(IntensityWaveName)
	AZWavename        = PossiblyQuoteName(AZWavename)
	ErrorWaveName     = PossiblyQuoteName(ErrorWaveName)

	WAVE/Z test = $(DataFolderName + IntensityWaveName)
	if(!WaveExists(test))
		abort "Error in IntensityWaveName wave selection"
	endif
	cursorAposition = 0
	cursorBposition = numpnts(test) - 1
	WAVE/Z test = $(DataFolderName + AZWavename)
	if(!WaveExists(test))
		abort "Error in QWavename wave selection"
	endif
	WAVE/Z test = $(DataFolderName + ErrorWaveName)
	if(!WaveExists(test))
		abort "Error in ErrorWaveName wave selection"
	endif
	Duplicate/O $(DataFolderName + IntensityWaveName), OriginalIntensity
	Duplicate/O $(DataFolderName + AZWavename), OriginalAZvector
	Duplicate/O $(DataFolderName + ErrorWaveName), OriginalError
	Redimension/D OriginalIntensity, OriginalAZvector, OriginalError
	//	wavestats /Q OriginalAZvector
	//	if(V_min<0)
	//		OriginalQvector = OriginalQvector[p]<=0 ? NaN : OriginalQvector[p]
	//	endif
	IN2G_RemoveNaNsFrom3Waves(OriginalAZvector, OriginalIntensity, OriginalError)
	IR3N_GraphInputData()
	//	IR3T_ClearStaleNumbers()

	setDataFolder oldDF
End
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

static Function IR3N_GraphInputData()

	PauseUpdate // building window...
	string fldrSav = GetDataFolder(1)
	SetDataFolder root:Packages:AnisotropicSystems:
	SVAR DataFolderName    = root:Packages:AnisotropicSystems:DataFolderName
	SVAR IntensityWaveName = root:Packages:AnisotropicSystems:IntensityWaveName
	SVAR AZWavename        = root:Packages:AnisotropicSystems:QWavename
	SVAR ErrorWaveName     = root:Packages:AnisotropicSystems:ErrorWaveName
	WAVE OriginalIntensity = root:Packages:AnisotropicSystems:OriginalIntensity
	WAVE OriginalAZvector  = root:Packages:AnisotropicSystems:OriginalAZvector
	WAVE OriginalError     = root:Packages:AnisotropicSystems:OriginalError
	DoWIndow AnisotropicSystemsPlot
	if(V_Flag)
		DoWIndow/F AnisotropicSystemsPlot
		RemoveFromGraph/W=AnisotropicSystemsPlot/Z fit_OriginalIntensity
		TextBox/N=HOPResults/K/W=AnisotropicSystemsPlot
		TextBox/N=CF_OriginalIntensity/K/W=AnisotropicSystemsPlot
	else
		Display/W=(282.75, 37.25, 759.75, 208.25)/K=1 OriginalIntensity vs OriginalAZvector as "Anisotropic Systems Plot"
		DoWindow/C AnisotropicSystemsPlot
		ModifyGraph mode(OriginalIntensity)=3
		ModifyGraph msize(OriginalIntensity)=0
		ModifyGraph mirror=1
		ShowInfo
		string LabelStr = "\\Z" + IN2G_LkUpDfltVar("AxisLabelSize") + "Intensity [" + IN2G_ReturnUnitsForYAxis(OriginalIntensity) + "\\Z" + IN2G_LkUpDfltVar("AxisLabelSize") + "]"
		Label left, LabelStr
		LabelStr = "\\Z" + IN2G_LkUpDfltVar("AxisLabelSize") + "Azimuthal angle [degree]"
		Label bottom, LabelStr
		string LegendStr = "\\F" + IN2G_LkUpDfltStr("FontType") + "\\Z" + IN2G_LkUpDfltVar("LegendSize") + "\\s(OriginalIntensity) Experimental intensity"
		Legend/W=AnisotropicSystemsPlot/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr
		//
		//ErrorBars/Y=1 OriginalIntensity Y,wave=(OriginalError,OriginalError)
		//and now some controls
		TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07" + date() + ", " + time()
		TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07" + DataFolderName + IntensityWaveName
	endif
	SetDataFolder fldrSav
End

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
static Function IR3N_InitAnisotropicSystems()

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DFREF oldDf = GetDataFolderDFR()

	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:AnisotropicSystems
	string/G ListOfVariables
	string/G ListOfStrings
	//here define the lists of variables and strings needed, separate names by ;...
	ListOfVariables  = "UseIndra2Data;UseQRSdata;UseSMRData;"
	ListOfVariables += "PeakCenterDegrees;HOPRight;HOPLeft;HOPAverage;WidthDegrees;"
	ListOfVariables += "HOPAngleStart;HOPAngleEnd;;"
	ListOfStrings   += "DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;PeakProfileShape;"
	variable i
	//and here we create them
	for(i = 0; i < itemsInList(ListOfVariables); i += 1)
		IN2G_CreateItem("variable", StringFromList(i, ListOfVariables))
	endfor
	for(i = 0; i < itemsInList(ListOfStrings); i += 1)
		IN2G_CreateItem("string", StringFromList(i, ListOfStrings))
	endfor
	SVAR PeakProfileShape
	if(Strlen(PeakProfileShape) < 1)
		PeakProfileShape = "Gauss"
	endif
	IR3N_ResetParameters()

	setDataFOlder OldDf
End
//*****************************************************************************************************************
//*****************************************************************************************************************
static Function IR3N_HOP(R_sam, Az_sam) //original provided code... Can bve tested
	//Calculates Hermans Orientation Parameter
	//P. C. van der Heijden, L. Rubatat, O. Diat, Macromolecules 2004, 37, 5327.
	//Check L.E. Alexander, R.J. Roe, etc.
	//ASSUMES INPUT ANGLE DATA IS IN DEGREES
	//Integration from 0 to pi/2 input directly in AreaXY command

	WAVE R_sam, Az_sam //input the output of Irena Line tool using ellipse w/ AR set to 1
	variable Ang_start, AngR_start //starting angle for integration
	Duplicate/O Az_sam, AzR_sam //Aziumthal angle data in radians
	variable HOP //Hermans orientation parameter final value

	//Get Ang_center from user
	Ang_start = 180;
	Prompt Ang_start, "Enter angle of orientation axis (center of peak?) (in degrees): "
	DoPrompt "Get peak center", Ang_start

	//Convert to radians
	AzR_sam    = Az_sam * pi / 180
	AngR_start = Ang_start * pi / 180
	Print "Starting angle =", Ang_start
	Print "Starting angle (radians) =", AngR_start

	//Create waves that are 2x the original waves, fill with data
	variable Az_num; Az_num = numpnts(Az_sam)
	variable Az_num2x   = 2 * Az_num
	variable Az_index   = 0
	variable Az_index2x = Az_num + 1
	Make/O/N=(Az_num2x) R_sam2x, AzR_sam2x
	do
		R_sam2x[Az_index]            = R_sam[Az_index]            //fill first half of R_sam2x
		R_sam2x[Az_index + Az_num]   = R_sam[Az_index]            //fill second half of R_sam2x
		AzR_sam2x[Az_index]          = AzR_sam[Az_index]          //fill first half of AzR_sam2x
		AzR_sam2x[Az_index + Az_num] = AzR_sam[Az_index] + 2 * pi //fill second half of AzR_sam2x
		Az_index                     = Az_index + 1
	while(Az_index < Az_num)

	//Find index corresponding to Ang_start
	variable Az_index_start
	Az_index = 0
	do
		Az_index_start = Az_index
		Az_index       = Az_index + 1
	while(Az_sam[Az_index_start] <= Ang_start)
	Print "Index of starting angle =", Az_index_start

	//Create new R & angle waves that have the correct angle range
	Make/O/N=(Az_num) R_sam1x
	Az_index = 0
	do
		R_sam1x[Az_index] = R_sam2x[Az_index + Az_index_start]
		Az_index          = Az_index + 1
	while(Az_index < Az_num)

	//Calculate upper & lower integrands
	Make/O/N=(Az_num) upperfunct, lowerfunct
	variable upperval, lowerval
	Az_index = 0
	do
		upperfunct[Az_index] = R_sam1x[Az_index] * sin(AzR_sam[Az_index]) * cos(AzR_sam[Az_index]) * cos(AzR_sam[Az_index])
		lowerfunct[Az_index] = R_sam1x[Az_index] * sin(AzR_sam[Az_index])
		Az_index             = Az_index + 1
	while(Az_index < Az_num)
	upperval = areaXY(AzR_sam, upperfunct, 0, pi / 2)
	lowerval = areaXY(AzR_sam, lowerfunct, 0, pi / 2)

	//Calculate Hermans Orientation Parameter
	HOP = (3 * (upperval / lowerval) - 1) / 2
	Print "HOP =", HOP
End

//*****************************************************************************************************************
//*****************************************************************************************************************
