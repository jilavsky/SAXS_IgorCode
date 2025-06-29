#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method.
#pragma version=2.31

Constant NI1BCversionNumber = 2.25
//*************************************************************************\
//* Copyright (c) 2005 - 2025, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution.
//*************************************************************************/

//2.31	 Fix Beam Center and Geometry correction which failed fitting when using Geometry correction.
//2.30 Remove for MatrixOP /NTHR=0 since it is applicable to 3D matrices only
//2.29 Fixed to accept tiff as tif extension.
//2.28 fix autoscaling panel components.
//2.27  removed unused functions
//2.26 Modified Screen Size check to match the needs
//2.25 added getHelp button calling to www manual
//2.24 Modified to point to USAXS_data on USAXS computers
//2.23 GUI fix on new calibrants lines
//2.22 added more lines to the calibrants
//2.21 added panel scaling
//2.20 fixed line 5 of Ag Behenate
//2.19 addressed new ADSC_A file type
//2.18 modified call to hook function
//2.17 Added right click "Refresh content" to Listbox
//2.16 fixed  , 1 is simply wrong...
//2.15 add avoidace in case user is using Calibrated 2D data.
//2.14 minor fix
//2.13 added many more lines for Lab6, Si, and Ce standards. Modified to disable fitting both SDD and Wavelength, very unlikely this would be possible with most data.
//2.12 added double click function to the file selection listbox, modified CheckVersion procedure to avoid Igor crash.
//2.11 added three new NIST calibration standards, provided by Christina.Reinhard@diamond.ac.uk
//2.10 added SSRLMatSAXS format.
//2.09 added Math name string so one can easier find Ag behenate data
//2.08 added check on Nika version when file is reopened. Force user to restart when old version of Nika was used...
//2.07 changed to enable to run update fundtion without the widnwo as needed by 9IDC software configuration
//2.06 adds response to FileLoader returning 0 for failed loads
//2.05 added azimuthal tilt on detector, changed method of fitting beam center and other parameters to more robust method...
// 2.04  added ability to subtract empty cell from the imorted image (reduce background for weak images
// also added ability to fit Gauss with sloping background for measurements with high air background.
// 2.03 added mutlithread and MatrixOp/NTHR=1 where seemed possible to use multile cores
// 8/2/2010 fixed fitting when I was checking on presence of infs in lineout but not nan. Added chgeck for nan (when mask is used)
//2.0 updated for Nika 1.42

Function NI1_CreateBmCntrFile()

	NI1A_Initialize2Dto1DConversion()
	NVAR UseCalib2DData = root:Packages:Convert2Dto1D:UseCalib2DData
	if(UseCalib2DData)
		Abort "This tool cannot be used when Calibrated 2D data are used. It makes no sense. Uncheck the checkbox on the main panel and the try again."
	endif
	NI1BC_InitCreateBmCntrFile()
	IN2G_CheckScreenSize("height", 680)
	NI1BC_CreateBmCntrField()
	NI1_UpdatePanelVersionNumber("NI1_CreateBmCntrFieldPanel", NI1BCversionNumber)
	NI1BC_TabProc("", 0)
End

//*****************************************************************************************************************
//*****************************************************************************************************************

Function NIBC_MainCheckVersion()
	DoWindow NI1_CreateBmCntrFieldPanel
	if(V_Flag)
		if(!NI1_CheckPanelVersionNumber("NI1_CreateBmCntrFieldPanel", NI1BCversionNumber))
			DoAlert/T="The Beam center panel was created by incorrect version of Nika " 1, "Beamcenter tool may need to be restarted to work properly. Restart now?"
			if(V_flag == 1)
				KillWIndow/Z NI1_CreateBmCntrFieldPanel
				NI1_CreateBmCntrFile()
			else //at least reinitialize the variables so we avoid major crashes...
				NI1A_Initialize2Dto1DConversion()
				NI1BC_InitCreateBmCntrFile()
			endif
		endif
	endif
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_CreateBmCntrField()

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	KillWIndow/Z NI1_CreateBmCntrFieldPanel
	//BmCntrFileName
	SVAR BmCntrFileType   = root:Packages:Convert2Dto1D:BmCntrFileType
	SVAR BMColorTableName = root:Packages:Convert2Dto1D:BMColorTableName
	SVAR BmCalibrantName  = root:Packages:Convert2Dto1D:BmCalibrantName

	NVAR BMImageRangeMaxLimit = root:Packages:Convert2Dto1D:BMImageRangeMaxLimit
	NVAR BMImageRangeMinLimit = root:Packages:Convert2Dto1D:BMImageRangeMinLimit
	NVAR BMBeamCenterXStep    = root:Packages:Convert2Dto1D:BMBeamCenterXStep
	NVAR BMBeamCenterYStep    = root:Packages:Convert2Dto1D:BMBeamCenterYStep
	NVAR BMHelpCircleRadius   = root:Packages:Convert2Dto1D:BMHelpCircleRadius
	NVAR BMMaxCircleRadius    = root:Packages:Convert2Dto1D:BMMaxCircleRadius

	NVAR UseCalib2DData             = root:Packages:Convert2Dto1D:UseCalib2DData
	SVAR ListOfKnownCalibExtensions = root:Packages:Convert2Dto1D:ListOfKnownCalibExtensions

	//	NVAR =root:Packages:Convert2Dto1D:

	PauseUpdate // building window...
	NewPanel/K=1/W=(22, 58, 450, 730)/N=NI1_CreateBmCntrFieldPanel as "Beam center and calibration panel"
	//Dowindow/C NI1_CreateBmCntrFieldPanel
	SetDrawLayer UserBack
	SetDrawEnv fsize=19, fstyle=1, textrgb=(0, 0, 65280)
	TitleBox MainTitle, title="\Zr160Refinement of Beam Center & Calibration", pos={10, 4}, frame=0, fstyle=3, size={300, 24}, fColor=(1, 4, 52428)
	TitleBox DataSetUse, title="\Zr100Select data set to use:", pos={18, 72}, frame=0, fstyle=3, size={300, 24}, fColor=(1, 4, 52428)

	Button SelectPathToData, pos={15, 31}, size={150, 20}, proc=NI1BC_BmCntrButtonProc, title="Select path to data"
	Button SelectPathToData, help={"Sets path to data where BmCntr image is"}
	Button GetHelp, pos={335, 105}, size={80, 15}, fColor=(65535, 32768, 32768), proc=NI1BC_BmCntrButtonProc, title="Get Help", help={"Open www manual page for this tool"}

	PopupMenu BmCntrFileType, pos={247, 31}, size={101, 21}, proc=NI1BC_BmCntrPopMenuProc, title="File type:"
	PopupMenu BmCntrFileType, help={"Select image type of data to be used"}
	PopupMenu BmCntrFileType, mode=1, popvalue=BmCntrFileType, value=#"root:Packages:Convert2Dto1D:ListOfKnownExtensions"
	TitleBox BCPathInfoStr, pos={3, 56}, size={325, 20}, variable=root:Packages:Convert2Dto1D:BCPathInfoStr, fixedSize=0, frame=0, fstyle=2, fColor=(0, 12800, 32000)

	ListBox CCDDataSelection, pos={17, 95}, size={300, 150}, special={0, 0, 1} //this will scale the width of column, users may need to slide right using slider at the bottom.
	ListBox CCDDataSelection, help={"Select CCD file for which you want to create mask"}
	ListBox CCDDataSelection, listWave=root:Packages:Convert2Dto1D:ListOfCCDDataInBmCntrPath
	ListBox CCDDataSelection, row=0, mode=1, selRow=0, proc=NI1_BMUListBoxProc
	SetVariable BCMatchNameString, pos={220, 75}, size={200, 16}, title="Match name (grep)"
	SetVariable BCMatchNameString, help={"Use string to match to name"}, proc=NI1BC_SetVarProc
	SetVariable BCMatchNameString, variable=root:Packages:Convert2Dto1D:BCMatchNameString

	Button CreateROIWorkImage, pos={325, 225}, size={100, 20}, proc=NI1BC_BmCntrButtonProc, title="Make Image"

	CheckBox BMUseGeometryCorr, title="Use Geom. corrs?", pos={300, 250}
	CheckBox BMUseGeometryCorr, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMUseGeometryCorr
	CheckBox BMUseGeometryCorr, help={"Use geometry corrections?"}

	CheckBox BMUseMask, title="Use Mask?", pos={300, 266}
	CheckBox BMUseMask, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMUseMask
	CheckBox BMUseMask, help={"Use mask for data evaluation?"}

	//AddFlat;FlatValToAdd;MaximumValueBmCntr
	CheckBox DisplayLogImage, title="Log image?", pos={10, 260}
	CheckBox DisplayLogImage, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BmCntrDisplayLogImage
	CheckBox DisplayLogImage, help={"Display log intensity for the image?"}

	CheckBox BMDezinger, title="Dezinger?", pos={90, 250}
	CheckBox BMDezinger, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMDezinger
	CheckBox BMDezinger, help={"Deziner image during loading?"}
	NVAR BMDezinger = root:Packages:Convert2Dto1D:BMDezinger
	SetVariable BMDezinerTimes, pos={175, 250}, size={90, 16}, title="times =", disable=!(BMDezinger)
	SetVariable BMDezinerTimes, help={"How many times to dezinger"}, proc=NI1BC_SetVarProc
	SetVariable BMDezinerTimes, limits={0, Inf, 1}, variable=root:Packages:Convert2Dto1D:BMDezinerTimes

	CheckBox BMSubtractBlank, title="Subtr Blank?", pos={90, 266}
	CheckBox BMSubtractBlank, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMSubtractBlank
	CheckBox BMSubtractBlank, help={"Subtract Air scattering from the image?"}
	NVAR BMSubtractBlank = root:Packages:Convert2Dto1D:BMSubtractBlank
	SetVariable BMStandardTransmission, pos={175, 266}, size={110, 16}, title="Transm =", disable=!(BMSubtractBlank)
	SetVariable BMStandardTransmission, help={"Transmission of the Standard?"}, proc=NI1BC_SetVarProc
	SetVariable BMStandardTransmission, limits={0, Inf, 1}, variable=root:Packages:Convert2Dto1D:BMStandardTransmission

	TabControl BmCntrTab, pos={8, 284}, size={412, 310}, proc=NI1BC_TabProc
	TabControl BmCntrTab, help={"Select tabs to control various methods"}
	TabControl BmCntrTab, tabLabel(0)="BeamCntr", tabLabel(1)="Calibrant"
	TabControl BmCntrTab, tabLabel(2)="Refinement" //,tabLabel(3)="4"
	TitleBox UserSuggestion, pos={20, 310}, title=" Zoom to area of attn. beam & fit 2DGauss or Manually guess "

	//TAB 0
	Button Fit2DGauss, pos={30, 340}, size={180, 20}, proc=NI1BC_BmCntrBtnProc, title="Fit 2D Gaussian"
	Button Fit2DGauss, help={"Zoom to area with beam imprint and fit 2D Gaussian on the peak there"}
	Button ReadCursors, pos={260, 340}, size={100, 20}, proc=NI1BC_BmCntrBtnProc, title="Read Cursor A"
	Button ReadCursors, help={"Read into Beam center values position of cursor A"}
	SetVariable BeamCenterX, pos={30, 380}, size={200, 16}, title="Beam center X ="
	SetVariable BeamCenterX, help={"Beam center X value, fitted or input manually"}, proc=NI1BC_SetVarProc
	SetVariable BeamCenterX, limits={-Inf, Inf, BMBeamCenterXStep}, variable=root:Packages:Convert2Dto1D:BeamCenterX
	SetVariable BMBeamCenterXStep, pos={250, 380}, size={80, 16}, title="step="
	SetVariable BMBeamCenterXStep, help={"Step for Beam center X "}, proc=NI1BC_SetVarProc
	SetVariable BMBeamCenterXStep, limits={-Inf, Inf, 1}, variable=root:Packages:Convert2Dto1D:BMBeamCenterXStep

	SetVariable BeamCenterY, pos={30, 410}, size={200, 16}, title="Beam center Y ="
	SetVariable BeamCenterY, help={"Beam center Y value, fitted or input manually"}, proc=NI1BC_SetVarProc
	SetVariable BeamCenterY, limits={-Inf, Inf, BMBeamCenterYStep}, variable=root:Packages:Convert2Dto1D:BeamCenterY
	SetVariable BMBeamCenterYStep, pos={250, 410}, size={80, 16}, title="step="
	SetVariable BMBeamCenterYStep, help={"Step for Beam center Y "}, proc=NI1BC_SetVarProc
	SetVariable BMBeamCenterYStep, limits={-Inf, Inf, 1}, variable=root:Packages:Convert2Dto1D:BMBeamCenterYStep

	CheckBox BMDisplayHelpCircle, title="Display circle?", pos={40, 430}
	CheckBox BMDisplayHelpCircle, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMDisplayHelpCircle
	CheckBox BMDisplayHelpCircle, help={"Display circle in the image to help guess the beam center?"}
	Slider BMHelpCircleRadius, pos={15, 450}, size={230, 16}, proc=NI1BC_MainSliderProc, variable=root:Packages:Convert2Dto1D:BMHelpCircleRadius, live=0, side=2, vert=0, ticks=0
	Slider BMHelpCircleRadius, limits={1, BMMaxCircleRadius, 0}, title="Help circle radius"
	SetVariable BMHelpCircleRadiusV, pos={270, 452}, size={120, 16}, title=" "
	SetVariable BMHelpCircleRadiusV, help={"Step for Beam center Y "}, proc=NI1BC_SetVarProc
	SetVariable BMHelpCircleRadiusV, limits={1, BMMaxCircleRadius, 1}, variable=root:Packages:Convert2Dto1D:BMHelpCircleRadius

	//Tab 1
	PopupMenu BmCalibrantName, pos={13, 340}, size={101, 21}, proc=NI1BC_BmCntrPopMenuProc, title="Calibrant:"
	PopupMenu BmCalibrantName, help={"Select type of calibrant to be used"}
	PopupMenu BmCalibrantName, mode=1, popvalue=BmCalibrantName, value=#"\"User;Ceria;Ag behenate;LaB6;LaB6_2;SRM 674b (CeO2);SRM 660b (LaB6);SRM 640d (Si);\""
	CheckBox BMCalibrantDisplayCircles, title="Display?", pos={320, 305}
	CheckBox BMCalibrantDisplayCircles, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMCalibrantDisplayCircles
	CheckBox BMCalibrantDisplayCircles, help={"Display circles in image?"}
	SetVariable BMPathWidth, pos={220, 330}, size={190, 16}, title="Lineout Intg over (pix) ="
	SetVariable BMPathWidth, help={"Integration width for for lineouts"}, proc=NI1BC_SetVarProc
	SetVariable BMPathWidth, limits={1, Inf, 1}, variable=root:Packages:Convert2Dto1D:BMPathWidth
	SetVariable BMPathLength, pos={220, 350}, size={190, 16}, title="Set width all ="
	SetVariable BMPathLength, help={"Integration length for all"}, proc=NI1BC_SetVarProc
	SetVariable BMPathLength, limits={1, Inf, 1}, variable=root:Packages:Convert2Dto1D:BMPathWidthAll

	CheckBox BMUseCalibrantD1, title="Use d1?", pos={20, 370}
	CheckBox BMUseCalibrantD1, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMUseCalibrantD1
	CheckBox BMUseCalibrantD1, help={"Use d1 for calibrant?"}
	SetVariable BMCalibrantD1, pos={90, 370}, size={100, 16}, title="d1 = "
	SetVariable BMCalibrantD1, help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD1, limits={0, Inf, 0}, variable=root:Packages:Convert2Dto1D:BMCalibrantD1
	SetVariable BMCalibrantD1LineWidth, pos={210, 370}, size={100, 16}, title="width ="
	SetVariable BMCalibrantD1LineWidth, help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD1LineWidth, limits={1, Inf, 5}, variable=root:Packages:Convert2Dto1D:BMCalibrantD1LineWidth

	CheckBox BMUseCalibrantD2, title="Use d2?", pos={20, 390}
	CheckBox BMUseCalibrantD2, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMUseCalibrantD2
	CheckBox BMUseCalibrantD2, help={"Use d2 for calibrant?"}
	SetVariable BMCalibrantD2, pos={90, 390}, size={100, 16}, title="d2 = "
	SetVariable BMCalibrantD2, help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD2, limits={0, Inf, 0}, variable=root:Packages:Convert2Dto1D:BMCalibrantD2
	SetVariable BMCalibrantD2LineWidth, pos={210, 390}, size={100, 16}, title="width ="
	SetVariable BMCalibrantD2LineWidth, help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD2LineWidth, limits={1, Inf, 5}, variable=root:Packages:Convert2Dto1D:BMCalibrantD2LineWidth

	CheckBox BMUseCalibrantD3, title="Use d3?", pos={20, 410}
	CheckBox BMUseCalibrantD3, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMUseCalibrantD3
	CheckBox BMUseCalibrantD3, help={"Use d3 for calibrant?"}
	SetVariable BMCalibrantD3, pos={90, 410}, size={100, 16}, title="d3 = "
	SetVariable BMCalibrantD3, help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD3, limits={0, Inf, 0}, variable=root:Packages:Convert2Dto1D:BMCalibrantD3
	SetVariable BMCalibrantD3LineWidth, pos={210, 410}, size={100, 16}, title="width ="
	SetVariable BMCalibrantD3LineWidth, help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD3LineWidth, limits={1, Inf, 5}, variable=root:Packages:Convert2Dto1D:BMCalibrantD3LineWidth

	CheckBox BMUseCalibrantD4, title="Use d4?", pos={20, 430}
	CheckBox BMUseCalibrantD4, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMUseCalibrantD4
	CheckBox BMUseCalibrantD4, help={"Use d4 for calibrant?"}
	SetVariable BMCalibrantD4, pos={90, 430}, size={100, 16}, title="d4 = "
	SetVariable BMCalibrantD4, help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD4, limits={0, Inf, 0}, variable=root:Packages:Convert2Dto1D:BMCalibrantD4
	SetVariable BMCalibrantD4LineWidth, pos={210, 430}, size={100, 16}, title="width ="
	SetVariable BMCalibrantD4LineWidth, help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD4LineWidth, limits={1, Inf, 5}, variable=root:Packages:Convert2Dto1D:BMCalibrantD4LineWidth

	CheckBox BMUseCalibrantD5, title="Use d5?", pos={20, 450}
	CheckBox BMUseCalibrantD5, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMUseCalibrantD5
	CheckBox BMUseCalibrantD5, help={"Use d5 for calibrant?"}
	SetVariable BMCalibrantD5, pos={90, 450}, size={100, 16}, title="d5 = "
	SetVariable BMCalibrantD5, help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD5, limits={0, Inf, 0}, variable=root:Packages:Convert2Dto1D:BMCalibrantD5
	SetVariable BMCalibrantD5LineWidth, pos={210, 450}, size={100, 16}, title="width ="
	SetVariable BMCalibrantD5LineWidth, help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD5LineWidth, limits={1, Inf, 5}, variable=root:Packages:Convert2Dto1D:BMCalibrantD5LineWidth

	CheckBox BMUseCalibrantD6, title="Use d6?", pos={20, 470}
	CheckBox BMUseCalibrantD6, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMUseCalibrantD6
	CheckBox BMUseCalibrantD6, help={"Use d6 for calibrant?"}
	SetVariable BMCalibrantD6, pos={90, 470}, size={100, 16}, title="d6 = "
	SetVariable BMCalibrantD6, help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD6, limits={0, Inf, 0}, variable=root:Packages:Convert2Dto1D:BMCalibrantD6
	SetVariable BMCalibrantD6LineWidth, pos={210, 470}, size={100, 16}, title="width ="
	SetVariable BMCalibrantD6LineWidth, help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD6LineWidth, limits={1, Inf, 5}, variable=root:Packages:Convert2Dto1D:BMCalibrantD6LineWidth

	CheckBox BMUseCalibrantD7, title="Use d7?", pos={20, 490}
	CheckBox BMUseCalibrantD7, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMUseCalibrantD7
	CheckBox BMUseCalibrantD7, help={"Use d7 for calibrant?"}
	SetVariable BMCalibrantD7, pos={90, 490}, size={100, 16}, title="d7 = "
	SetVariable BMCalibrantD7, help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD7, limits={0, Inf, 0}, variable=root:Packages:Convert2Dto1D:BMCalibrantD7
	SetVariable BMCalibrantD7LineWidth, pos={210, 490}, size={100, 16}, title="width ="
	SetVariable BMCalibrantD7LineWidth, help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD7LineWidth, limits={1, Inf, 5}, variable=root:Packages:Convert2Dto1D:BMCalibrantD7LineWidth

	CheckBox BMUseCalibrantD8, title="Use d8?", pos={20, 510}
	CheckBox BMUseCalibrantD8, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMUseCalibrantD8
	CheckBox BMUseCalibrantD8, help={"Use d8 for calibrant?"}
	SetVariable BMCalibrantD8, pos={90, 510}, size={100, 16}, title="d8 = "
	SetVariable BMCalibrantD8, help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD8, limits={0, Inf, 0}, variable=root:Packages:Convert2Dto1D:BMCalibrantD8
	SetVariable BMCalibrantD8LineWidth, pos={210, 510}, size={100, 16}, title="width ="
	SetVariable BMCalibrantD8LineWidth, help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD8LineWidth, limits={1, Inf, 5}, variable=root:Packages:Convert2Dto1D:BMCalibrantD8LineWidth

	CheckBox BMUseCalibrantD9, title="Use d9?", pos={20, 530}
	CheckBox BMUseCalibrantD9, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMUseCalibrantD9
	CheckBox BMUseCalibrantD9, help={"Use d9 for calibrant?"}
	SetVariable BMCalibrantD9, pos={90, 530}, size={100, 16}, title="d9 = "
	SetVariable BMCalibrantD9, help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD9, limits={0, Inf, 0}, variable=root:Packages:Convert2Dto1D:BMCalibrantD9
	SetVariable BMCalibrantD9LineWidth, pos={210, 530}, size={100, 16}, title="width ="
	SetVariable BMCalibrantD9LineWidth, help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD9LineWidth, limits={1, Inf, 5}, variable=root:Packages:Convert2Dto1D:BMCalibrantD9LineWidth

	CheckBox BMUseCalibrantD10, title="Use d10?", pos={20, 550}
	CheckBox BMUseCalibrantD10, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMUseCalibrantD10
	CheckBox BMUseCalibrantD10, help={"Use d10 for calibrant?"}
	SetVariable BMCalibrantD10, pos={90, 550}, size={100, 16}, title="d10 ="
	SetVariable BMCalibrantD10, help={"Largest d spacing of calibrant"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD10, limits={0, Inf, 0}, variable=root:Packages:Convert2Dto1D:BMCalibrantD10
	SetVariable BMCalibrantD10LineWidth, pos={210, 550}, size={100, 16}, title="width ="
	SetVariable BMCalibrantD10LineWidth, help={"Width of the line for evaluation"}, proc=NI1BC_SetVarProc
	SetVariable BMCalibrantD10LineWidth, limits={1, Inf, 5}, variable=root:Packages:Convert2Dto1D:BMCalibrantD10LineWidth

	//Tab 2

	//	ListOfVariables+="BMFitBeamCenter;BMFitSDD;BMFitWavelength;"
	SVAR BMFunctionName = root:Packages:Convert2Dto1D:BMFunctionName
	PopupMenu BMFunctionName, pos={180, 310}, size={101, 21}, proc=NI1BC_BmCntrPopMenuProc, title="Peak shape function:"
	PopupMenu BMFunctionName, help={"Select type of function to fit to peaks"}
	PopupMenu BMFunctionName, mode=(1 + WhichListItem(BMFunctionName, "Gauss;Lorenz;GaussWithSlopedBckg;")), value=#"\"Gauss;Lorenz;GaussWithSlopedBckg;\""
	CheckBox BMFitBeamCenter, title="Refine beam center?", pos={20, 340}
	CheckBox BMFitBeamCenter, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMFitBeamCenter
	CheckBox BMFitBeamCenter, help={"Refine beam center?"}
	CheckBox BMFitSDD, title="Refine Sa-Det distance?", pos={20, 360}
	CheckBox BMFitSDD, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMFitSDD
	CheckBox BMFitSDD, help={"Refine sample to detector distance?"}
	CheckBox BMFitWavelength, title="Refine wavelength?", pos={20, 380}
	CheckBox BMFitWavelength, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMFitWavelength
	CheckBox BMFitWavelength, help={"Refine wavelength?"}
	CheckBox BMFitTilts, title="Refine tilts?", pos={20, 400}
	CheckBox BMFitTilts, proc=NI1BC_BmCntrCheckProc, variable=root:Packages:Convert2Dto1D:BMFitTilts
	CheckBox BMFitTilts, help={"Refine tilts?"}

	TitleBox ExplainNumSect, pos={20, 490}, title="Num. of directions per 360 deg in which we will look for peak positions"

	SetVariable BMRefNumberOfSectors, pos={20, 520}, size={200, 16}, title="Num sectors   =   "
	SetVariable BMRefNumberOfSectors, help={"Number of sectors to use per 360 degrees"}, proc=NI1BC_SetVarProc
	SetVariable BMRefNumberOfSectors, limits={0, Inf, 1}, variable=root:Packages:Convert2Dto1D:BMRefNumberOfSectors
	SetVariable BMRefStepInAngle, pos={20, 540}, size={200, 16}, title="Step in [deg]   =   "
	SetVariable BMRefStepInAngle, help={"Search Step in degrees"}, disable=2, noedit=1, limits={0, Inf, 0}
	SetVariable BMRefStepInAngle, limits={0, Inf, 1}, variable=root:Packages:Convert2Dto1D:BMRefStepInAngle
	CheckBox BMDisplayInImage, title="Display in image?", pos={250, 520}
	CheckBox BMDisplayInImage, variable=root:Packages:Convert2Dto1D:BMDisplayInImage
	CheckBox BMDisplayInImage, help={"Display in image where sectors are evaluated?"}

	SetVariable BeamCenterX2, pos={150, 340}, size={120, 16}, title="BC X =", format="%.2f"
	SetVariable BeamCenterX2, help={"Beam center X value, fitted or input manually"}, proc=NI1BC_SetVarProc
	SetVariable BeamCenterX2, limits={-Inf, Inf, BMBeamCenterXStep}, variable=root:Packages:Convert2Dto1D:BeamCenterX
	SetVariable BeamCenterY2, pos={290, 340}, size={120, 16}, title="BC Y  =", format="%.2f"
	SetVariable BeamCenterY2, help={"Beam center Y value, fitted or input manually"}, proc=NI1BC_SetVarProc
	SetVariable BeamCenterY2, limits={-Inf, Inf, BMBeamCenterYStep}, variable=root:Packages:Convert2Dto1D:BeamCenterY

	SetVariable SampleToDetectorDistance, pos={180, 360}, size={200, 16}, disable=1, proc=NI1BC_SetVarProc, title="Sa-det distance [mm]  "
	SetVariable SampleToDetectorDistance, limits={0, Inf, 1}, value=root:Packages:Convert2Dto1D:SampleToCCDDistance, format="%.2f"
	SetVariable Wavelength, pos={180, 380}, size={200, 16}, proc=NI1BC_SetVarProc, title="Wavelength [A]          "
	SetVariable Wavelength, help={"\"Input wavelegth of X-rays in Angstroems\" "}
	SetVariable Wavelength, limits={0, Inf, 0.1}, value=root:Packages:Convert2Dto1D:Wavelength, format="%.5f"
	//	SetVariable XrayEnergy,pos={180,380},size={200,16},proc=NI1BC_SetVarProc,title="X-ray energy [keV]      "
	//	SetVariable XrayEnergy,help={"Input energy of X-rays in keV (linked with wavelength)"}
	//	SetVariable XrayEnergy,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:XrayEnergy

	SetVariable HorizontalTilt, pos={150, 400}, size={120, 16}, proc=NI1BC_SetVarProc, title="Horizontal", format="%.3f"
	SetVariable HorizontalTilt, limits={-90, 90, 1}, value=root:Packages:Convert2Dto1D:HorizontalTilt, help={"Tilt of the image in horizontal plane (around 0 degrees)"}
	SetVariable VerticalTilt, pos={290, 400}, size={120, 16}, proc=NI1BC_SetVarProc, title="Vertical", format="%.3f"
	SetVariable VerticalTilt, limits={-90, 90, 1}, value=root:Packages:Convert2Dto1D:VerticalTilt, help={"Tilt of the image in vertical plane (around 90 degrees)"}

	Button RefineParameters, pos={30, 560}, size={150, 20}, proc=NI1BC_BmCntrButtonProc, title="Run refinement"
	Button RefineParameters, help={"Refine above selected parameters"}
	Button RecoverParameters, pos={200, 560}, size={150, 20}, proc=NI1BC_BmCntrButtonProc, title="Return back"
	Button RecoverParameters, help={"If refinement fails, this is going to return parameters where they were before..."}

	//bottom
	Slider ImageRangeMin, pos={15, 600}, size={150, 16}, proc=NI1BC_MainSliderProc, variable=root:Packages:Convert2Dto1D:BMImageRangeMin, live=0, side=2, vert=0, ticks=0
	Slider ImageRangeMin, limits={BMImageRangeMinLimit, BMImageRangeMaxLimit, 0}
	Slider ImageRangeMax, pos={15, 630}, size={150, 16}, proc=NI1BC_MainSliderProc, variable=root:Packages:Convert2Dto1D:BMImageRangeMax, live=0, side=2, vert=0, ticks=0
	Slider ImageRangeMax, limits={BMImageRangeMinLimit, BMImageRangeMaxLimit, 0}
	SVAR BMColorTableName = root:Packages:Convert2Dto1D:BMColorTableName
	PopupMenu BMImageColor, pos={200, 600}, size={200, 16}, value=#"\"Grays;Rainbow;YellowHot;BlueHot;BlueRedGreen;RedWhiteBlue;PlanetEarth;Terrain;\""
	PopupMenu BMImageColor, proc=NI1BC_PopMenuProc, mode=(1 + WhichListItem(BMColorTableName, "Grays;Rainbow;YellowHot;BlueHot;BlueRedGreen;RedWhiteBlue;PlanetEarth;Terrain;"))

	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_BMUListBoxProc(lba) : ListBoxControl
	STRUCT WMListboxAction &lba

	variable i
	string items             = ""
	SVAR   BmCalibrantName   = root:Packages:Convert2Dto1D:BmCalibrantName
	SVAR   BCMatchNameString = root:Packages:Convert2Dto1D:BCMatchNameString
	switch(lba.eventCode)
		case 3: //double click
			NI1BC_BmCntrButtonProc("CreateROIWorkImage")
			break
		case 1:
			if(lba.eventMod & 0x10) // rightclick
				// list of items for PopupContextualMenu
				items = "Refresh Content;Match \"AgBehenate\";Match \"LaB6\";Match \"640d\";"
				PopupContextualMenu items
				// V_flag is index of user selected item
				switch(V_flag)
					case 1:
						NI1BC_UpdateBmCntrListBox()
						break
					case 2:
						BCMatchNameString = "(?i)Behenate"
						NI1BC_UpdateBmCntrListBox()
						BmCalibrantName = "Ag behenate"
						NI1BC_BmCntrPopMenuProc("BmCalibrantName", 5, "Ag behenate")
						//"User;Ceria;Ceria_2;Ceria_3;Ag behenate;LaB6;LaB6_2;LaB6_3;LaB6_4;SRM 674b (CeO2);SRM 660b (LaB6);SRM 640d (Si);SRM 640d (Si)_2;SRM 640d (Si)_3;\""
						PopupMenu BmCalibrantName, win=NI1_CreateBmCntrFieldPanel, mode=1, popvalue=BmCalibrantName, value=#"\"User;Ceria;Ceria_2;Ceria_3;Ag behenate;LaB6;LaB6_2;LaB6_3;LaB6_4;SRM 674b (CeO2);SRM 660b (LaB6);SRM 640d (Si);SRM 640d (Si)_2;SRM 640d (Si)_3;\""
						break
					case 3:
						BCMatchNameString = "(?i)LaB6"
						NI1BC_UpdateBmCntrListBox()
						BmCalibrantName = "LaB6"
						NI1BC_BmCntrPopMenuProc("BmCalibrantName", 6, "LaB6")
						PopupMenu BmCalibrantName, win=NI1_CreateBmCntrFieldPanel, mode=1, popvalue=BmCalibrantName, value=#"\"User;Ceria;Ceria_2;Ceria_3;Ag behenate;LaB6;LaB6_2;LaB6_3;LaB6_4;SRM 674b (CeO2);SRM 660b (LaB6);SRM 640d (Si);SRM 640d (Si)_2;SRM 640d (Si)_3;\""
						break
					case 4:
						BCMatchNameString = "(?i)640d"
						NI1BC_UpdateBmCntrListBox()
						BmCalibrantName = "SRM 640d (Si)"
						NI1BC_BmCntrPopMenuProc("BmCalibrantName", 13, "SRM 640d (Si)")
						PopupMenu BmCalibrantName, win=NI1_CreateBmCntrFieldPanel, mode=1, popvalue=BmCalibrantName, value=#"\"User;Ceria;Ceria_2;Ceria_3;Ag behenate;LaB6;LaB6_2;LaB6_3;LaB6_4;SRM 674b (CeO2);SRM 660b (LaB6);SRM 640d (Si);SRM 640d (Si)_2;SRM 640d (Si)_3;\""
						break
				endswitch
			endif
	endswitch
	return 0
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_TabProc(ctrlName, tabNum)
	string   ctrlName
	variable tabNum

	//	//tab 0 controls
	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	NVAR BMDisplayHelpCircle = root:Packages:Convert2Dto1D:BMDisplayHelpCircle
	Button Fit2DGauss, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 0)
	Button ReadCursors, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 0)
	SetVariable BeamCenterX, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 0)
	SetVariable BeamCenterY, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 0)
	SetVariable BMBeamCenterXStep, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 0)
	SetVariable BMBeamCenterYStep, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 0)
	CheckBox BMDisplayHelpCircle, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 0)
	Slider BMHelpCircleRadius, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 0 || BMDisplayHelpCircle == 0)
	SetVariable BMHelpCircleRadiusV, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 0 || BMDisplayHelpCircle == 0)
	if(tabNum == 0)
		TitleBox UserSuggestion, win=NI1_CreateBmCntrFieldPanel, title=" Zoom to area of attn. beam & fit 2DGauss or Manually guess "
	elseif(tabNum == 1)
		TitleBox UserSuggestion, win=NI1_CreateBmCntrFieldPanel, title=" Pick calibrant / own param, border lines "
	elseif(tabNum == 2)
		TitleBox UserSuggestion, win=NI1_CreateBmCntrFieldPanel, title=" Select what to refine and run "
	else
		TitleBox UserSuggestion, win=NI1_CreateBmCntrFieldPanel, title="  help text here   "
	endif
	//	SetVariable PixleSizeY,disable=(tabNum!=0)
	NVAR BMUseCalibrantD1  = root:Packages:Convert2Dto1D:BMUseCalibrantD1
	NVAR BMUseCalibrantD2  = root:Packages:Convert2Dto1D:BMUseCalibrantD2
	NVAR BMUseCalibrantD3  = root:Packages:Convert2Dto1D:BMUseCalibrantD3
	NVAR BMUseCalibrantD4  = root:Packages:Convert2Dto1D:BMUseCalibrantD4
	NVAR BMUseCalibrantD5  = root:Packages:Convert2Dto1D:BMUseCalibrantD5
	NVAR BMUseCalibrantD6  = root:Packages:Convert2Dto1D:BMUseCalibrantD6
	NVAR BMUseCalibrantD7  = root:Packages:Convert2Dto1D:BMUseCalibrantD7
	NVAR BMUseCalibrantD8  = root:Packages:Convert2Dto1D:BMUseCalibrantD8
	NVAR BMUseCalibrantD9  = root:Packages:Convert2Dto1D:BMUseCalibrantD9
	NVAR BMUseCalibrantD10 = root:Packages:Convert2Dto1D:BMUseCalibrantD10

	SetVariable BMPathWidth, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1)
	SetVariable BMPathLength, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1)
	PopupMenu BmCalibrantName, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1)
	CheckBox BMCalibrantDisplayCircles, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1)
	CheckBox BMUseCalibrantD1, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1)
	SetVariable BMCalibrantD1, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD1 == 0)
	SetVariable BMCalibrantD1LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD1 == 0)
	CheckBox BMUseCalibrantD2, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1)
	SetVariable BMCalibrantD2, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD2 == 0)
	SetVariable BMCalibrantD2LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD2 == 0)
	CheckBox BMUseCalibrantD3, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1)
	SetVariable BMCalibrantD3, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD3 == 0)
	SetVariable BMCalibrantD3LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD3 == 0)
	CheckBox BMUseCalibrantD4, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1)
	SetVariable BMCalibrantD4, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD4 == 0)
	SetVariable BMCalibrantD4LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD4 == 0)
	CheckBox BMUseCalibrantD5, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1)
	SetVariable BMCalibrantD5, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD5 == 0)
	SetVariable BMCalibrantD5LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD5 == 0)

	CheckBox BMUseCalibrantD6, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1)
	SetVariable BMCalibrantD6, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD6 == 0)
	SetVariable BMCalibrantD6LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD5 == 0)
	CheckBox BMUseCalibrantD7, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1)
	SetVariable BMCalibrantD7, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD7 == 0)
	SetVariable BMCalibrantD7LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD5 == 0)
	CheckBox BMUseCalibrantD8, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1)
	SetVariable BMCalibrantD8, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD8 == 0)
	SetVariable BMCalibrantD8LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD5 == 0)
	CheckBox BMUseCalibrantD9, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1)
	SetVariable BMCalibrantD9, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD9 == 0)
	SetVariable BMCalibrantD9LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD5 == 0)
	CheckBox BMUseCalibrantD10, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1)
	SetVariable BMCalibrantD10, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD10 == 0)
	SetVariable BMCalibrantD10LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 1 || BMUseCalibrantD5 == 0)

	PopupMenu BMFunctionName, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	CheckBox BMFitBeamCenter, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	CheckBox BMFitSDD, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	CheckBox BMFitWavelength, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	Button RefineParameters, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	Button RecoverParameters, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	SetVariable BMRefNumberOfSectors, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	CheckBox BMDisplayInImage, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	SetVariable SampleToDetectorDistance, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	SetVariable Wavelength, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	//	SetVariable XrayEnergy, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum!=2)
	SetVariable HorizontalTilt, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	SetVariable VerticalTilt, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	SetVariable BeamCenterX2, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	SetVariable BeamCenterY2, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	CheckBox BMFitTilts, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	TitleBox ExplainNumSect, win=NI1_CreateBmCntrFieldPanel, disable=(tabNum != 2)
	SetVariable BMRefStepInAngle, win=NI1_CreateBmCntrFieldPanel, disable=2 - (tabNum != 2)

	if(tabNum == 0)
		NI1BC_DisplayHelpCircle()
	elseif(tabNum == 1 || tabNum == 2)
		NI1BC_DisplayCalibrantCircles()
	endif

	setDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1BC_SetVarProc(ctrlName, varNum, varStr, varName) : SetVariableControl
	string   ctrlName
	variable varNum
	string   varStr
	string   varName

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	if(cmpstr(ctrlName, "BMBeamCenterXStep") == 0)
		NVAR BMBeamCenterXStep = root:Packages:Convert2Dto1D:BMBeamCenterXStep
		SetVariable BeamCenterX, limits={-Inf, Inf, BMBeamCenterXStep}, win=NI1_CreateBmCntrFieldPanel
	endif
	if(cmpstr(ctrlName, "BMBeamCenterYStep") == 0)
		NVAR BMBeamCenterYStep = root:Packages:Convert2Dto1D:BMBeamCenterYStep
		SetVariable BeamCenterY, limits={-Inf, Inf, BMBeamCenterYStep}, win=NI1_CreateBmCntrFieldPanel
	endif
	if(cmpstr(ctrlName, "BeamCenterX") == 0)
		NI1BC_DisplayHelpCircle()
	endif
	if(cmpstr(ctrlName, "BeamCenterY") == 0)
		NI1BC_DisplayHelpCircle()
	endif
	if(cmpstr(ctrlName, "BCMatchNameString") == 0)
		NI1BC_UpdateBMCntrListBOx()
	endif

	variable i
	for(i = 1; i <= 10; i += 1)
		if(cmpstr(ctrlName, "BMCalibrantD" + num2str(i)) == 0 || cmpstr(ctrlName, "BMCalibrantD" + num2str(i) + "LineWidth") == 0)
			NI1BC_DisplayCalibrantCircles()
		endif
	endfor
	if(cmpstr(ctrlName, "BMPathLength") == 0) //sets path width length for all
		for(i = 1; i < 11; i += 1)
			NVAR length         = $("root:Packages:Convert2Dto1D:BMCalibrantD" + num2str(i) + "LineWidth")
			NVAR BMPathWidthAll = root:Packages:Convert2Dto1D:BMPathWidthAll
			length = BMPathWidthAll
		endfor
		NI1BC_DisplayCalibrantCircles()
	endif
	if(cmpstr("XrayEnergy", ctrlName) == 0)
		NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength
		Wavelength = 12.398424437 / VarNum
		NI1BC_DisplayCalibrantCircles()
	endif
	if(cmpstr("Wavelength", ctrlName) == 0)
		NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy
		XrayEnergy = 12.398424437 / VarNum
		NI1BC_DisplayCalibrantCircles()
	endif
	if(cmpstr("SampleToDetectorDistance", ctrlName) == 0)
		NI1BC_DisplayCalibrantCircles()
	endif
	if(cmpstr("BMHelpCircleRadiusV", ctrlName) == 0)
		NI1BC_DisplayHelpCircle()
	endif
	if(cmpstr("HorizontalTilt", ctrlName) == 0)
		NI1BC_DisplayCalibrantCircles()
	endif
	if(cmpstr("VerticalTilt", ctrlName) == 0)
		NI1BC_DisplayCalibrantCircles()
	endif
	if(cmpstr("BeamCenterX2", ctrlName) == 0)
		NI1BC_DisplayCalibrantCircles()
	endif
	if(cmpstr("BeamCenterY2", ctrlName) == 0)
		NI1BC_DisplayCalibrantCircles()
	endif
	if(cmpstr("BMRefNumberOfSectors", ctrlName) == 0)
		NVAR BMRefStepInAngle     = root:Packages:Convert2Dto1D:BMRefStepInAngle
		NVAR BMRefNumberOfSectors = root:Packages:Convert2Dto1D:BMRefNumberOfSectors
		BMRefStepInAngle = 360 / BMRefNumberOfSectors
	endif

	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_DisplayHelpCircle()

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR BMDisplayHelpCircle = root:Packages:Convert2Dto1D:BMDisplayHelpCircle
	NVAR BMHelpCircleRadius  = root:Packages:Convert2Dto1D:BMHelpCircleRadius
	//remove all drawings
	DoWindow CCDImageForBmCntr
	if(V_Flag)
		setDrawLayer/W=CCDImageForBmCntr/K ProgFront
		setDrawLayer/W=CCDImageForBmCntr UserFront
		//and now new drawing
		if(BMDisplayHelpCircle)
			setDrawLayer/W=CCDImageForBmCntr ProgFront
			NVAR ycenter = root:Packages:Convert2Dto1D:BeamCenterY
			NVAR xcenter = root:Packages:Convert2Dto1D:BeamCenterX
			if(stringMatch(AxisList("CCDImageForBmCntr"), "*top*"))
				setdrawenv/W=CCDImageForBmCntr fillpat=0, xcoord=top, ycoord=left, save
			else
				setdrawenv/W=CCDImageForBmCntr fillpat=0, xcoord=bottom, ycoord=left, save
			endif
			SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 65535, 65535)
			SetDrawEnv/W=CCDImageForBmCntr linethick=3
			DrawOval/W=CCDImageForBmCntr xcenter - 2, ycenter + 2, xcenter + 2, ycenter - 2
			SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 0, 0)
			SetDrawEnv/W=CCDImageForBmCntr linethick=2
			DrawOval/W=CCDImageForBmCntr xcenter - 10, ycenter + 10, xcenter + 10, ycenter - 10
			//SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 0,0 )
			//SetDrawEnv/W=CCDImageForBmCntr linethick=2
			//DrawOval/W=CCDImageForBmCntr xcenter-50, ycenter+50, xcenter+50, ycenter-50
			SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 0, 0)
			SetDrawEnv/W=CCDImageForBmCntr linethick=2
			DrawOval/W=CCDImageForBmCntr xcenter - BMHelpCircleRadius, ycenter + BMHelpCircleRadius, xcenter + BMHelpCircleRadius, ycenter - BMHelpCircleRadius
			setDrawLayer/W=CCDImageForBmCntr UserFront
		endif
	endif
	DoWIndow CCDImageForBmCntr
	if(V_Flag)
		RemoveFromGraph/W=CCDImageForBmCntr/Z ywave
	endif

	setDataFolder OldDf

End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_DisplayCalibrantCircles()

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR   ycenter                   = root:Packages:Convert2Dto1D:BeamCenterY
	NVAR   xcenter                   = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR   HorizontalTilt            = root:Packages:Convert2Dto1D:HorizontalTilt //tilt in degrees
	NVAR   VerticalTilt              = root:Packages:Convert2Dto1D:VerticalTilt   //tilt in degrees
	NVAR   BMCalibrantDisplayCircles = root:Packages:Convert2Dto1D:BMCalibrantDisplayCircles
	WAVE/Z BmCntrCCDImg              = root:Packages:Convert2Dto1D:BmCntrCCDImg
	if(!WaveExists(BmCntrCCDImg))
		return 0
	endif
	//remove all drawings
	DoWindow CCDImageForBmCntr
	if(V_Flag)
		setDrawLayer/W=CCDImageForBmCntr/K ProgFront
		setDrawLayer/W=CCDImageForBmCntr UserFront
		//and now new drawing
		//this calculates the right radius NI1_GetPixelFromDSpacing(dspacing, direction)
		variable i, radX, radY
		if(BMCalibrantDisplayCircles)
			for(i = 1; i <= 10; i += 1)
				NVAR BMUseCalibrantD       = $("root:Packages:Convert2Dto1D:BMUseCalibrantD" + num2str(i))
				NVAR BMCalibrantD          = $("root:Packages:Convert2Dto1D:BMCalibrantD" + num2str(i))
				NVAR BMCalibrantDLineWidth = $("root:Packages:Convert2Dto1D:BMCalibrantD" + num2str(i) + "LineWidth")

				setDrawLayer/W=CCDImageForBmCntr ProgFront
				if(BMUseCalibrantD)
					if(stringMatch(AxisList("CCDImageForBmCntr"), "*top*"))
						setdrawenv/W=CCDImageForBmCntr fillpat=0, xcoord=top, ycoord=left, save
					else
						setdrawenv/W=CCDImageForBmCntr fillpat=0, xcoord=bottom, ycoord=left, save
					endif
					SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 65535, 65535)
					SetDrawEnv/W=CCDImageForBmCntr linethick=2
					if(abs(HorizontalTilt) > 0.01 || abs(VerticalTilt) > 0.01) //use tilts, new method March 2011, JIL. Using extracted code by Jon Tischler.
						make/O/N=180 $("CalibrantCenterWaveX" + num2str(i)), $("CalibrantCenterWaveY" + num2str(i)) //these are two "Paths" for the drawing
						WAVE wvX = $("CalibrantCenterWaveX" + num2str(i))
						WAVE wvY = $("CalibrantCenterWaveY" + num2str(i))
						SetScale/I x, 0, 2 * pi, "rad", wvX, wvY //their x dimension is their azimuthal direction
						//we need to fill them with px and py values for given Q
						//radX = NI1BC_GetPixelFromDSpacing(BMCalibrantD, "X")		//these are no tilts estimates
						//radY = NI1BC_GetPixelFromDSpacing(BMCalibrantD, "Y")		//these are no tilts estimates
						NI1BC_FindTiltedQvalues(wvx, wvy, BMCalibrantD, BmCntrCCDImg, "CCDImageForBmCntr")
						SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 65535, 65535)
						SetDrawEnv/W=CCDImageForBmCntr linethick=2
						DrawPoly/W=CCDImageForBmCntr/ABS 0, 0, 1, 1, wvX, wvY
						duplicate/O wvx, $("CalibrantCenterWaveXin" + num2str(i)), $("CalibrantCenterWaveXout" + num2str(i))
						duplicate/O wvy, $("CalibrantCenterWaveYin" + num2str(i)), $("CalibrantCenterWaveYout" + num2str(i))
						WAVE wvxin  = $("CalibrantCenterWaveXin" + num2str(i))
						WAVE wvxout = $("CalibrantCenterWaveXout" + num2str(i))
						WAVE wvyin  = $("CalibrantCenterWaveYin" + num2str(i))
						WAVE wvyout = $("CalibrantCenterWaveYout" + num2str(i))
						wvxin  = wvx[p] + BMCalibrantDLineWidth * cos(x)
						wvxout = wvx[p] - BMCalibrantDLineWidth * cos(x)
						wvyin  = wvy[p] + BMCalibrantDLineWidth * sin(x)
						wvyout = wvy[p] - BMCalibrantDLineWidth * sin(x)
						SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 0, 0)
						SetDrawEnv/W=CCDImageForBmCntr linethick=1
						DrawPoly/W=CCDImageForBmCntr/ABS 0, 0, 1, 1, wvXin, wvYin
						SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 0, 0)
						SetDrawEnv/W=CCDImageForBmCntr linethick=1
						DrawPoly/W=CCDImageForBmCntr/ABS 0, 0, 1, 1, wvXout, wvYout

					else //original no-tilts code...
						radX = NI1BC_GetPixelFromDSpacing(BMCalibrantD, "X")
						radY = NI1BC_GetPixelFromDSpacing(BMCalibrantD, "Y")
						DrawOval/W=CCDImageForBmCntr xcenter - radX, ycenter + radY, xcenter + radX, ycenter - radY
						SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 0, 0)
						SetDrawEnv/W=CCDImageForBmCntr linethick=1
						DrawOval/W=CCDImageForBmCntr xcenter - radX + BMCalibrantDLineWidth, ycenter + radY - BMCalibrantDLineWidth, xcenter + radX - BMCalibrantDLineWidth, ycenter - radY + BMCalibrantDLineWidth
						SetDrawEnv/W=CCDImageForBmCntr linefgc=(65535, 0, 0)
						SetDrawEnv/W=CCDImageForBmCntr linethick=1
						DrawOval/W=CCDImageForBmCntr xcenter - radX - BMCalibrantDLineWidth, ycenter + radY + BMCalibrantDLineWidth, xcenter + radX + BMCalibrantDLineWidth, ycenter - radY - BMCalibrantDLineWidth
					endif
				endif
				setDrawLayer/W=CCDImageForBmCntr UserFront
			endfor
		endif
	endif
	setDataFolder OldDf

End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function/C NI1BC_FindTiltedPxPyValues(dspacing, direction) //return complex value px+i*py
	variable dspacing //find this d-spacing
	//	variable radx,rady		//estimates for starting points
	variable direction //this is azimuthal direction in radians

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	//store structure of current geometry
	//	STRUCT NikadetectorGeometry d
	//	NI2T_ReadOrientationFromGlobals(d)
	//	NI2T_SaveStructure(d)

	//	variable Lradx=abs(radx)
	//	variable Lrady=abs(rady)
	NVAR Wavelength
	NVAR SampleToCCDDistance
	NVAR PixelSizeX
	NVAR PixelSizeY
	NVAR XrayEnergy
	NVAR HorizontalTilt
	NVAR VerticalTilt
	NVAR BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
	//pixelDist = SampleToCCDDistance *tan(2* asin( Wavelength /(2* dspacing) )  )
	// d = 2*pi/Q
	// sin (theta) = Q * Lambda / 4 * pi
	// Lambda = 2 * d * sin (theta)
	// d = 0.5 * Lambda / sin(theta) = 2 * pi / Q    Q = 2pi/d
	variable TargetTheta = asin(Wavelength / (2 * dspacing)) //in radians...
	// now this function will return theta for px and py... NI2T_CalculateThetaWithTilts(px,py,1)
	//need to generate px and py in direction given by x and scan from 0 to px max/py max and find when we get theta equal theta we need...
	variable i, ii, xmax, ymax, xval, yval, previousTheta, signx, signy
	variable px, py
	DoWindow CCDImageForBmCntr
	if(V_Flag)
		variable/C result = NI2T_CalculatePxPyWithTilts(TargetTheta, direction)
		return result
	endif
	setDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_FindTiltedQvalues(wvx, wvy, dspacing, BmCntrCCDImg, WindowNameToAttach)
	WAVE wvx, wvy
	variable dspacing //find this d-spacing
	WAVE     BmCntrCCDImg
	string   WindowNameToAttach

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	//store structure of current geometry
	STRUCT NikadetectorGeometry d
	NI2T_ReadOrientationFromGlobals(d)
	NI2T_SaveStructure(d)

	NVAR Wavelength
	NVAR SampleToCCDDistance
	NVAR PixelSizeX
	NVAR PixelSizeY
	NVAR XrayEnergy
	NVAR HorizontalTilt
	NVAR VerticalTilt
	NVAR     BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR     BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
	variable theta       = asin(Wavelength / (2 * dspacing)) //in radians...
	//	variable dspacing = 0.5*Wavelength/sin(theta)
	// now this function will return theta for px and py... NI2T_CalculateThetaWithTilts(px,py,1)
	//need to generate px and py in direction given by x and scan from 0 to px max/py max and find when we get theta equal theta we need...
	variable i, ii
	variable   direction
	variable/C tempresult
	variable ImageSizeX, ImageSizeY
	ImageSizeX = DimSize(BmCntrCCDImg, 0)
	ImageSizeY = DimSize(BmCntrCCDImg, 1)
	DoWindow $(WindowNameToAttach)
	if(V_Flag)
		for(ii = 0; ii < numpnts(wvx); ii += 1) //for each point on wvx, wvy
			direction  = pnt2x(wvx, ii) //this is azimuthal direction in radians
			tempresult = NI2T_CalculatePxPyWithTilts(theta, direction)
			wvx[ii]    = real(tempresult)
			wvy[ii]    = imag(tempresult)
		endfor
		for(ii = 0; ii < numpnts(wvx); ii += 1) //for each point on wvx, wvy
			if(wvx[ii] > (ImageSizeX) || wvx[ii] < 0 || wvy[ii] > (ImageSizeY) || wvy[ii] < 0) //out if image already
				wvx[ii] = NaN
				wvy[ii] = NaN
			endif
		endfor
	endif
	setDataFolder OldDf
End

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

//this function calculate angle of the triangle which is between the px,py on detector and SDD (gamma), we also know the SDD
//and we also know the 2theta angle in thi traingle. So now we need to calcualte distance to px,py from beam center with this gasmma anlge
//that is knowing ASA:
//function ASA(&$firstangle, &$secondangle, &$intside) {
//     $otherangle=(180-$firstangle-$secondangle);
//    $firstside=($intside*(sin(deg2rad($firstangle)))/(sin(deg2rad($otherangle))));
//   $secondside=($intside*(sin(deg2rad($secondangle)))/(sin(deg2rad($otherangle))));
//
//  Function/C NI2T_CalculateGammaFixedPxPy(theta, direction)
//	variable theta, direction
//	//theta is bragg angle in question
//	//direction is azimuthal angle in radians
//	variable TwoTheta= 2*theta		//theta of this px, py with tilts
//	variable px,py
//	NVAR BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
//	NVAR BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
//	px=  cos(direction)
//	py=  sin(direction)
//	variable GammaAngle=NI2T_CalculateGammaWithTilts(px,py)		//gamma angle
//	variable SDD
//	NVAR SampleToCCDDistance = root:Packages:Convert2Dto1D:SampleToCCDDistance	//in mm
//	NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
//	NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
//	SDD=SampleToCCDDistance/(0.5*(PixelSizeX+PixelSizeY))
//	variable OtherAngle = pi - TwoTheta - GammaAngle
//	variable distance = SDD*sin(TwoTheta)/sin(OtherAngle)		//distance in pixels from beam center
//	variable pxR = BeamCenterX+distance*cos(direction)
//	variable pyR = BeamCenterY+distance*sin(direction)
//
//	return cmplx(pxR,pyR)
//
//end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
//
// Function NI2T_CalculateGammaFixedDist(px,py)
//	variable px,py
//
////that is knowing ASA:
////function ASA(&$firstangle, &$secondangle, &$intside) {
//  //     $otherangle=(180-$firstangle-$secondangle);
//   //    $firstside=($intside*(sin(deg2rad($firstangle)))/(sin(deg2rad($otherangle))));
//    //   $secondside=($intside*(sin(deg2rad($secondangle)))/(sin(deg2rad($otherangle))));
//	variable TwoTheta= 2*NI2T_CalculateThetaWithTilts(px,py,1)		//theta of this px, py with tilts
//	variable GammaAngle=NI2T_CalculateGammaWithTilts(px,py)		//gamma angle
//	variable SDD
//	NVAR SampleToCCDDistance = root:Packages:Convert2Dto1D:SampleToCCDDistance	//in mm
//	NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
//	NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
//	SDD=2*SampleToCCDDistance/(PixelSizeX+PixelSizeY)
//	variable OtherAngle = pi - TwoTheta - GammaAngle
//	variable result = SDD*sin(TwoTheta)/sin(OtherAngle)
//	print result
//end
//
//

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_GetPixelFromDSpacing(dspacing, direction)
	variable dspacing  //d in A
	string   direction //X (horizontal) or Y (vertical)

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	variable pixelDist //distance from center
	NVAR     Wavelength
	NVAR     SampleToCCDDistance
	NVAR     PixelSizeX
	NVAR     PixelSizeY
	NVAR     XrayEnergy
	NVAR     HorizontalTilt
	NVAR     VerticalTilt
	//Ok, this should just return simple Bragg law with little trigonometry

	pixelDist = SampleToCCDDistance * tan(2 * asin(Wavelength / (2 * dspacing)))

	if(stringmatch(direction, "X"))
		pixelDist = pixelDist / PixelSizeX
	elseif(stringmatch(direction, "Y"))
		pixelDist = pixelDist / PixelSizeY
	else
		pixelDist = 0
	endif

	setDataFolder OldDf

	return pixelDist

End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_PopMenuProc(ctrlName, popNum, popStr) : PopupMenuControl
	string   ctrlName
	variable popNum
	string   popStr

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	if(cmpstr(ctrlName, "BMImageColor") == 0)
		SVAR ColorTableName = root:Packages:Convert2Dto1D:BMColorTableName
		ColorTableName = popStr
		NI1BC_TopCCDImageUpdateColors(0)
	endif

	setDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_MainSliderProc(ctrlName, sliderValue, event) //: SliderControl
	string   ctrlName
	variable sliderValue
	variable event // bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	if(cmpstr(ctrlName, "ImageRangeMin") == 0 || cmpstr(ctrlName, "ImageRangeMax") == 0)
		if(event & 0x1) // bit 0, value set
			NI1BC_TopCCDImageUpdateColors(0)
		endif
	endif
	if(cmpstr(ctrlName, "BMHelpCircleRadius") == 0)
		if(event & 0x1) // bit 0, value set
			NI1BC_DisplayHelpCircle()
		endif
	endif

	return 0
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_TopCCDImageUpdateColors(updateRanges)
	variable updateRanges

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR     ImageRangeMin      = root:Packages:Convert2Dto1D:BMImageRangeMin
	NVAR     ImageRangeMax      = root:Packages:Convert2Dto1D:BMImageRangeMax
	SVAR     ColorTableName     = root:Packages:Convert2Dto1D:BMColorTableName
	NVAR     ImageRangeMinLimit = root:Packages:Convert2Dto1D:BMImageRangeMinLimit
	NVAR     ImageRangeMaxLimit = root:Packages:Convert2Dto1D:BMImageRangeMaxLimit
	string   s                  = ImageNameList("", ";")
	variable p1                 = StrSearch(s, ";", 0)
	if(p1 < 0)
		abort // no image in top graph
	endif
	s = s[0, p1 - 1]
	if(updateRanges)
		WAVE waveToDisplayDis = $(s)
		wavestats/Q waveToDisplayDis
		ImageRangeMin      = V_min
		ImageRangeMinLimit = V_min
		ImageRangeMax      = V_max
		ImageRangeMaxLimit = V_max
		Slider ImageRangeMin, limits={ImageRangeMinLimit, ImageRangeMaxLimit, 0}, win=NI1_CreateBmCntrFieldPanel
		Slider ImageRangeMax, limits={ImageRangeMinLimit, ImageRangeMaxLimit, 0}, win=NI1_CreateBmCntrFieldPanel
	endif
	ModifyImage $(s), ctab={ImageRangeMin, ImageRangeMax, $ColorTableName, 0}
	PopupMenu BMImageColor, win=NI1_CreateBmCntrFieldPanel, popvalue=ColorTableName
	setDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1BC_BmCntrBtnProc(ctrlName) : ButtonControl
	string ctrlName

	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D
	if(cmpstr(ctrlName, "Fit2DGauss") == 0)
		DoWindow CCDImageForBmCntr
		if(!V_flag)
			abort
		endif
		variable BCMarqueetop, BCMarqueebottom, BCMarqueeleft, BCMarqueeright
		WAVE BmCntrCCDImg = root:Packages:Convert2Dto1D:BmCntrCCDImg
		NVAR InvertImages = root:Packages:Convert2Dto1D:InvertImages
		if(InvertImages)
			GetAxis/W=CCDImageForBmCntr/Q bottom
			BCMarqueeleft  = V_min
			BCMarqueeright = V_max
		else
			GetAxis/W=CCDImageForBmCntr/Q top
			BCMarqueeleft  = V_min
			BCMarqueeright = V_max
		endif
		GetAxis/W=CCDImageForBmCntr/Q left
		BCMarqueebottom = V_max
		BCMarqueetop    = V_min
		NI1BC_Fitto2DGaussian1(BCMarqueeleft, BCMarqueeright, BCMarqueebottom, BCMarqueetop, BmCntrCCDImg)
	endif

	if(cmpstr(ctrlName, "ReadCursors") == 0)
		DoWindow CCDImageForBmCntr
		if(V_Flag)
			NVAR   BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
			NVAR   BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
			string strC        = CsrInfo(A, "CCDImageForBmCntr")
			if(strlen(strC) > 0)
				BeamCenterX = NumberByKey("Point", strC)
				BeamCenterY = NumberByKey("Ypoint", strC)
			endif
			NI1BC_DisplayHelpCircle()
		else
			Abort "Proper image for Beam center and Calibration to work with does not exist"
		endif
	endif

	SetDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_Fitto2DGaussian1(left, right, bottom, top, wvToFItTo)
	variable left, right, bottom, top
	WAVE wvToFItTo

	string OldDf = GetDataFolder(1)
	SetDataFolder root:Packages:Convert2Dto1D
	redimension/S wvToFItTo
	variable tmp
	if(left > right)
		tmp   = right
		right = left
		left  = tmp
	endif
	if(bottom > top)
		tmp    = top
		top    = bottom
		bottom = tmp
	endif
	ImageStats/G={left, right, bottom, top} wvToFItTo
	if(V_Flag < 0)
		Abort "Problem in Fit2DGaussian routine, bad range of data for image stats"
	endif

	if(abs(left - right) + abs(bottom - top) > 400)
		Abort "Too large area for fitting 2D gauss function"
	endif
	variable PeakInt = V_max
	variable xcenter = V_maxColLoc
	variable ycenter = V_MaxRowLoc
	make/O/N=(abs(floor(right - left))) tempStDevWv
	tempStDevWv = wvToFItTo[p + left][xcenter]
	FindLEvels/P tempStDevWv, (V_max / 2)
	WAVE W_FindLevels
	variable stddev = 2
	if(numpnts(W_FindLevels) == 2)
		stddev = abs(W_FindLevels[1] - W_FindLevels[0])
	endif
	if(stddev < 2)
		stddev = 2
	endif
	WAVE fit_BmCntrCCDImg

	//	root:P:gPeakInt=PeakInt ;root:P:gxcenter=xcenter ;root:P:gycenter=ycenter ;root:P:gstddev=stddev
	Make/O/N=4 gw2DGaussian
	gw2DGaussian[0] = PeakInt
	gw2DGaussian[1] = ycenter
	gw2DGaussian[2] = xcenter
	gw2DGaussian[3] = stddev
	CheckDisplayed/W=CCDImageForBmCntr fit_BmCntrCCDImg
	if(V_Flag)
		RemoveContour fit_BmCntrCCDImg
	endif
	FuncFitMD NI1BC_gaussian2D, gw2DGaussian, wvToFItTo(left, right)(bottom, top)/D
	WAVE fit_BmCntrCCDImg = root:Packages:Convert2Dto1D:fit_BmCntrCCDImg
	make/O/N=(DimSize(fit_BmCntrCCDImg, 0)) fit_BmCntrCCDImgX
	fit_BmCntrCCDImgX = DimOffset(fit_BmCntrCCDImg, 0) + p * DimDelta(fit_BmCntrCCDImg, 0)
	make/O/N=(DimSize(fit_BmCntrCCDImg, 1)) fit_BmCntrCCDImgY
	fit_BmCntrCCDImgY = DimOffset(fit_BmCntrCCDImg, 1) + p * DimDelta(fit_BmCntrCCDImg, 1)
	if(stringmatch(AxisList("CCDImageForBmCntr"), "*top*"))
		AppendMatrixContour/T fit_BmCntrCCDImg vs {fit_BmCntrCCDImgX, fit_BmCntrCCDImgY}
	else
		AppendMatrixContour fit_BmCntrCCDImg vs {fit_BmCntrCCDImgX, fit_BmCntrCCDImgY}
	endif
	ModifyContour fit_BmCntrCCDImg, labels=0 //, interpolate=1
	ModifyGraph/W=CCDImageForBmCntr lsize=1

	//now save data in centers...
	NVAR BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
	BeamCenterX = gw2DGaussian[1]
	BeamCenterY = gw2DGaussian[2]
	setDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_Gaussian2D(w, x1, y1)
	WAVE w; variable x1, y1 //x is chann
	return (w[0] * exp(-((x1 - w[1])^2 + (y1 - w[2])^2) / w[3]^2))
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_DisplayMask()

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	NVAR BMUseMask = root:Packages:Convert2Dto1D:BMUseMask
	if(BMUseMask)
		WAVE/Z M_ROIMask = root:Packages:Convert2Dto1D:M_ROIMask
		if(!WaveExists(M_ROIMask))
			DoAlert 0, "Mask image does not exist, please load the mask through main panel or create new one through the Mask tool"
			BMUseMask = 0
		endif
	endif

	DoWindow CCDImageForBmCntr
	if(V_Flag)
		if(BMUseMask && WaveExists(M_ROIMask))
			DoWindow/F CCDImageForBmCntr
			CheckDisplayed/W=CCDImageForBmCntr M_ROIMask
			if(WaveExists(M_ROIMask) && !V_Flag)
				AppendImage/W=CCDImageForBmCntr M_ROIMask
				ModifyImage/W=CCDImageForBmCntr M_ROIMask, ctab={0.2, 0.5, Grays}, minRGB=(12000, 12000, 12000), maxRGB=NaN
			endif
		else
			DoWindow CCDImageForBmCntr
			if(V_Flag)
				CheckDisplayed/W=CCDImageForBmCntr root:Packages:Convert2Dto1D:M_ROIMask
				if(V_Flag)
					RemoveImage/W=CCDImageForBmCntr M_ROIMask
				endif
			endif
		endif
	endif
	setDataFolder OldDf

End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_BmCntrCheckProc(ctrlName, checked) : CheckBoxControl
	string   ctrlName
	variable checked

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	if(cmpstr(ctrlName, "DisplayLogImage") == 0)
		DoWindow CCDImageForBmCntr
		if(V_Flag)
			DoWindow/F CCDImageForBmCntr
			NVAR BmCntrDisplayLogImage = root:Packages:Convert2Dto1D:BmCntrDisplayLogImage
			WAVE BmCntrCCDImg          = root:Packages:Convert2Dto1D:BmCntrCCDImg
			WAVE BmCntrDisplayImage    = root:Packages:Convert2Dto1D:BmCntrDisplayImage
			redimension/S BmCntrCCDImg
			ImageStats BmCntrCCDImg
			if(BmCntrDisplayLogImage)
				MatrixOp/O BmCntrDisplayImage = log(BmCntrCCDImg)
				V_min = log(V_min)
				V_max = log(V_max)
				if(numType(V_min) != 0)
					V_min = 0
				endif
			else
				MatrixOp/O BmCntrDisplayImage = BmCntrCCDImg
			endif
			NVAR ImageRangeMin      = root:Packages:Convert2Dto1D:BMImageRangeMin
			NVAR ImageRangeMax      = root:Packages:Convert2Dto1D:BMImageRangeMax
			NVAR ImageRangeMinLimit = root:Packages:Convert2Dto1D:BMImageRangeMinLimit
			NVAR ImageRangeMaxLimit = root:Packages:Convert2Dto1D:BMImageRangeMaxLimit
			SVAR BMColorTableName   = root:Packages:Convert2Dto1D:BMColorTableName
			ImageRangeMin      = V_min
			ImageRangeMinLimit = V_min
			ImageRangeMax      = V_max
			ImageRangeMaxLimit = V_max
			Slider ImageRangeMin, win=NI1_CreateBmCntrFieldPanel, limits={ImageRangeMinLimit, ImageRangeMaxLimit, 0}
			Slider ImageRangeMax, win=NI1_CreateBmCntrFieldPanel, limits={ImageRangeMinLimit, ImageRangeMaxLimit, 0}

			ModifyImage/W=CCDImageForBmCntr BmCntrDisplayImage, ctab={ImageRangeMin, ImageRangeMax, $BMColorTableName, 0}
		endif
	endif
	if(cmpstr(ctrlName, "BMDisplayHelpCircle") == 0)
		Slider BMHelpCircleRadius, win=NI1_CreateBmCntrFieldPanel, disable=(checked == 0)
		SetVariable BMHelpCircleRadiusV, win=NI1_CreateBmCntrFieldPanel, disable=(checked == 0)
		NI1BC_DisplayHelpCircle()
	endif

	NVAR BMFitSDD        = root:Packages:Convert2Dto1D:BMFitSDD
	NVAR BMFitWavelength = root:Packages:Convert2Dto1D:BMFitWavelength
	if(cmpstr(ctrlName, "BMFitSDD") == 0)
		//CheckBox BMFitWavelength, win=NI1_CreateBmCntrFieldPanel, disable=2*BMFitSDD
		if(BMFitSDD)
			BMFitWavelength = 0
		endif
	endif
	if(cmpstr(ctrlName, "BMFitWavelength") == 0)
		//	CheckBox BMFitSDD, win=NI1_CreateBmCntrFieldPanel, disable=2*BMFitWavelength
		if(BMFitSDD)
			BMFitSDD = 0
		endif
	endif

	if(cmpstr(ctrlName, "BMUseMask") == 0)
		NI1BC_DisplayMask()
	endif
	if(cmpstr(ctrlName, "BMCalibrantDisplayCircles") == 0)
		NI1BC_DisplayCalibrantCircles()
	endif
	if(cmpstr(ctrlName, "BMDezinger") == 0)
		NVAR BMDezinger = root:Packages:Convert2Dto1D:BMDezinger
		SetVariable BMDezinerTimes, win=NI1_CreateBmCntrFieldPanel, disable=!(BMDezinger)
	endif
	if(cmpstr(ctrlName, "BMSubtractBlank") == 0)
		WAVE/Z EmptyData       = root:Packages:Convert2Dto1D:EmptyData
		NVAR   BMSubtractBlank = root:Packages:Convert2Dto1D:BMSubtractBlank
		if(!WaveExists(EmptyData) && checked)
			DoAlert 0, "No Empty data found, please load them through main panel. You may need to select \"Use Empty filed\" on the 1st tab and then load empty on 4th tab. Only then this function will work."
			BMSubtractBlank = 0
		endif
		SetVariable BMStandardTransmission, win=NI1_CreateBmCntrFieldPanel, disable=!(BMSubtractBlank)
		NVAR BMStandardTransmission = root:Packages:Convert2Dto1D:BMStandardTransmission
		if((BMStandardTransmission < 0.1 || BMStandardTransmission > 1) && checked)
			DoAlert 0, "Please set or guess right standard transmission"
			BMStandardTransmission = 1
		endif
	endif
	if(stringmatch(ctrlName, "BMUseCalibrantD*"))
		NVAR BMUseCalibrantD1  = root:Packages:Convert2Dto1D:BMUseCalibrantD1
		NVAR BMUseCalibrantD2  = root:Packages:Convert2Dto1D:BMUseCalibrantD2
		NVAR BMUseCalibrantD3  = root:Packages:Convert2Dto1D:BMUseCalibrantD3
		NVAR BMUseCalibrantD4  = root:Packages:Convert2Dto1D:BMUseCalibrantD4
		NVAR BMUseCalibrantD5  = root:Packages:Convert2Dto1D:BMUseCalibrantD5
		NVAR BMUseCalibrantD6  = root:Packages:Convert2Dto1D:BMUseCalibrantD6
		NVAR BMUseCalibrantD7  = root:Packages:Convert2Dto1D:BMUseCalibrantD7
		NVAR BMUseCalibrantD8  = root:Packages:Convert2Dto1D:BMUseCalibrantD8
		NVAR BMUseCalibrantD9  = root:Packages:Convert2Dto1D:BMUseCalibrantD9
		NVAR BMUseCalibrantD10 = root:Packages:Convert2Dto1D:BMUseCalibrantD10

		SetVariable BMCalibrantD1, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD1 == 0)
		SetVariable BMCalibrantD1LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD1 == 0)
		SetVariable BMCalibrantD2, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD2 == 0)
		SetVariable BMCalibrantD2LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD2 == 0)
		SetVariable BMCalibrantD3, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD3 == 0)
		SetVariable BMCalibrantD3LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD3 == 0)
		SetVariable BMCalibrantD4, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD4 == 0)
		SetVariable BMCalibrantD4LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD4 == 0)
		SetVariable BMCalibrantD5, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD5 == 0)
		SetVariable BMCalibrantD5LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD5 == 0)
		SetVariable BMCalibrantD6, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD6 == 0)
		SetVariable BMCalibrantD6LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD6 == 0)
		SetVariable BMCalibrantD7, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD7 == 0)
		SetVariable BMCalibrantD7LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD7 == 0)
		SetVariable BMCalibrantD8, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD8 == 0)
		SetVariable BMCalibrantD8LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD8 == 0)
		SetVariable BMCalibrantD9, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD9 == 0)
		SetVariable BMCalibrantD9LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD9 == 0)
		SetVariable BMCalibrantD10, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD10 == 0)
		SetVariable BMCalibrantD10LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD10 == 0)
		NI1BC_DisplayCalibrantCircles()
	endif

	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1BC_BmCntrPopMenuProc(ctrlName, popNum, popStr) : PopupMenuControl
	string   ctrlName
	variable popNum
	string   popStr

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	if(cmpstr(ctrlName, "BMFunctionName") == 0)
		SVAR BMFunctionName = root:Packages:Convert2Dto1D:BMFunctionName
		BMFunctionName = popStr
	endif
	if(cmpstr(ctrlName, "BmCntrFileType") == 0)
		//set appropriate extension
		SVAR BmCntrFileType = root:Packages:Convert2Dto1D:BmCntrFileType
		BmCntrFileType = popStr
		if(cmpstr(popStr, "GeneralBinary") == 0)
			NI1_GBLoaderPanelFnct()
		endif
		if(cmpstr(popStr, "Pilatus") == 0)
			NI1_PilatusLoaderPanelFnct()
		endif
		NI1BC_UpdateBmCntrListBox()
	endif
	if(cmpstr(ctrlName, "BmCalibrantName") == 0)
		NVAR BMCalibrantD1     = root:Packages:Convert2Dto1D:BMCalibrantD1
		NVAR BMCalibrantD2     = root:Packages:Convert2Dto1D:BMCalibrantD2
		NVAR BMCalibrantD3     = root:Packages:Convert2Dto1D:BMCalibrantD3
		NVAR BMCalibrantD4     = root:Packages:Convert2Dto1D:BMCalibrantD4
		NVAR BMCalibrantD5     = root:Packages:Convert2Dto1D:BMCalibrantD5
		NVAR BMCalibrantD6     = root:Packages:Convert2Dto1D:BMCalibrantD6
		NVAR BMCalibrantD7     = root:Packages:Convert2Dto1D:BMCalibrantD7
		NVAR BMCalibrantD8     = root:Packages:Convert2Dto1D:BMCalibrantD8
		NVAR BMCalibrantD9     = root:Packages:Convert2Dto1D:BMCalibrantD9
		NVAR BMCalibrantD10    = root:Packages:Convert2Dto1D:BMCalibrantD10
		NVAR BMUseCalibrantD1  = root:Packages:Convert2Dto1D:BMUseCalibrantD1
		NVAR BMUseCalibrantD2  = root:Packages:Convert2Dto1D:BMUseCalibrantD2
		NVAR BMUseCalibrantD3  = root:Packages:Convert2Dto1D:BMUseCalibrantD3
		NVAR BMUseCalibrantD4  = root:Packages:Convert2Dto1D:BMUseCalibrantD4
		NVAR BMUseCalibrantD5  = root:Packages:Convert2Dto1D:BMUseCalibrantD5
		NVAR BMUseCalibrantD6  = root:Packages:Convert2Dto1D:BMUseCalibrantD6
		NVAR BMUseCalibrantD7  = root:Packages:Convert2Dto1D:BMUseCalibrantD7
		NVAR BMUseCalibrantD8  = root:Packages:Convert2Dto1D:BMUseCalibrantD8
		NVAR BMUseCalibrantD9  = root:Packages:Convert2Dto1D:BMUseCalibrantD9
		NVAR BMUseCalibrantD10 = root:Packages:Convert2Dto1D:BMUseCalibrantD10
		if(cmpstr(popStr, "Ceria") == 0)
			BMCalibrantD1  = 3.1241
			BMCalibrantD2  = 2.70555
			BMCalibrantD3  = 1.91311
			BMCalibrantD4  = 1.63151
			BMCalibrantD5  = 1.56205
			BMCalibrantD6  = 1.3529128
			BMCalibrantD7  = 1.2415179
			BMCalibrantD8  = 1.2100820
			BMCalibrantD9  = 1.1046486
			BMCalibrantD10 = 1.0414727
			//these data are from : http://www.sci.himeji-tech.ac.jp/material/cryst_struct/LTVcam/sokutei/ceo2.htm
			//and further d spacings: 1.35278, 1.24139, 1.20996, 1.10454...
			BMUseCalibrantD1  = 1
			BMUseCalibrantD2  = 1
			BMUseCalibrantD3  = 1
			BMUseCalibrantD4  = 1
			BMUseCalibrantD5  = 1
			BMUseCalibrantD6  = 1
			BMUseCalibrantD7  = 1
			BMUseCalibrantD8  = 1
			BMUseCalibrantD9  = 1
			BMUseCalibrantD10 = 1
		elseif(cmpstr(popStr, "Ag behenate") == 0)
			//The number I use is q = 0.1076 (1/Angstrom), d = 58.380 Angstroms.  The
			//reference is T.C. Huang et al, J. Appl. Cryst. (1993), 26, 180-184.
			BMCalibrantD1     = 58.380
			BMCalibrantD2     = 29.185
			BMCalibrantD3     = 19.46
			BMCalibrantD4     = 14.595
			BMCalibrantD5     = 11.676 //fixed form 11.767 on 2-12-2015, typo
			BMCalibrantD6     = 9.73
			BMCalibrantD7     = 8.34
			BMCalibrantD8     = 7.2975
			BMCalibrantD9     = 6.48667
			BMCalibrantD10    = 5.838
			BMUseCalibrantD1  = 1
			BMUseCalibrantD2  = 1
			BMUseCalibrantD3  = 1
			BMUseCalibrantD4  = 1
			BMUseCalibrantD5  = 1
			BMUseCalibrantD6  = 1
			BMUseCalibrantD7  = 1
			BMUseCalibrantD8  = 1
			BMUseCalibrantD9  = 1
			BMUseCalibrantD10 = 1
		elseif(cmpstr(popStr, "LaB6") == 0)
			//Numbers from Peter Lee
			BMCalibrantD1     = 4.15690 //[100]/rel int 60
			BMCalibrantD2     = 2.93937 //110 /100
			BMCalibrantD3     = 2.39999 //111/45
			BMCalibrantD4     = 2.07845 //200/23.6
			BMCalibrantD5     = 1.85902 //210/55
			BMCalibrantD6     = 1.6970539
			BMCalibrantD7     = 1.4696918
			BMCalibrantD8     = 1.3856387
			BMCalibrantD9     = 1.3145323
			BMCalibrantD10    = 1.2533574
			BMUseCalibrantD1  = 1
			BMUseCalibrantD2  = 1
			BMUseCalibrantD3  = 1
			BMUseCalibrantD4  = 1
			BMUseCalibrantD5  = 1
			BMUseCalibrantD6  = 1
			BMUseCalibrantD7  = 1
			BMUseCalibrantD8  = 1
			BMUseCalibrantD9  = 1
			BMUseCalibrantD10 = 1
		elseif(cmpstr(popStr, "LaB6_2") == 0)
			BMCalibrantD1     = 1.6970539
			BMCalibrantD2     = 1.4696918
			BMCalibrantD3     = 1.4696918
			BMCalibrantD4     = 1.3856387
			BMCalibrantD5     = 1.3145323
			BMCalibrantD6     = 1.2533574
			BMCalibrantD7     = 1.1999983
			BMCalibrantD8     = 1.1529211
			BMCalibrantD9     = 1.1109826
			BMCalibrantD10    = 1.0392291
			BMUseCalibrantD1  = 1
			BMUseCalibrantD2  = 1
			BMUseCalibrantD3  = 1
			BMUseCalibrantD4  = 1
			BMUseCalibrantD5  = 1
			BMUseCalibrantD6  = 1
			BMUseCalibrantD7  = 1
			BMUseCalibrantD8  = 1
			BMUseCalibrantD9  = 1
			BMUseCalibrantD10 = 1
		elseif(cmpstr(popStr, "SRM 674b (CeO2)") == 0)
			//Numbers from Christina.Reinhard@diamond.ac.uk, NIST standard values
			BMCalibrantD1     = 3.1244182
			BMCalibrantD2     = 2.7058255
			BMCalibrantD3     = 1.9133076
			BMCalibrantD4     = 1.6316742
			BMCalibrantD5     = 1.5622091
			BMUseCalibrantD1  = 1
			BMUseCalibrantD2  = 1
			BMUseCalibrantD3  = 1
			BMUseCalibrantD4  = 1
			BMUseCalibrantD5  = 1
			BMUseCalibrantD6  = 0
			BMUseCalibrantD7  = 0
			BMUseCalibrantD8  = 0
			BMUseCalibrantD9  = 0
			BMUseCalibrantD10 = 0
		elseif(cmpstr(popStr, "SRM 660b (LaB6)") == 0 || cmpstr(popStr, "SRM 660a (LaB6)") == 0)
			//Numbers from Christina.Reinhard@diamond.ac.uk, NIST standard values
			BMCalibrantD1     = 4.1569162
			BMCalibrantD2     = 2.9393836
			BMCalibrantD3     = 2.3999967
			BMCalibrantD4     = 2.0784581
			BMCalibrantD5     = 1.8590294
			BMUseCalibrantD1  = 1
			BMUseCalibrantD2  = 1
			BMUseCalibrantD3  = 1
			BMUseCalibrantD4  = 1
			BMUseCalibrantD5  = 1
			BMUseCalibrantD6  = 0
			BMUseCalibrantD7  = 0
			BMUseCalibrantD8  = 0
			BMUseCalibrantD9  = 0
			BMUseCalibrantD10 = 0
		elseif(cmpstr(popStr, "SRM 640d (Si)") == 0)
			//Numbers from Christina.Reinhard@diamond.ac.uk, NIST standard values
			BMCalibrantD1     = 3.1357221
			BMCalibrantD2     = 1.9202298
			BMCalibrantD3     = 1.6375775
			BMCalibrantD4     = 1.3578075
			BMCalibrantD5     = 1.2460096
			BMCalibrantD6     = 1.1086452
			BMCalibrantD7     = 1.0452407
			BMCalibrantD8     = 0.9601149
			BMCalibrantD9     = 0.9180454
			BMCalibrantD10    = 0.858729
			BMUseCalibrantD1  = 1
			BMUseCalibrantD2  = 1
			BMUseCalibrantD3  = 1
			BMUseCalibrantD4  = 1
			BMUseCalibrantD5  = 1
			BMUseCalibrantD6  = 1
			BMUseCalibrantD7  = 1
			BMUseCalibrantD8  = 1
			BMUseCalibrantD9  = 1
			BMUseCalibrantD10 = 1
		endif
		SetVariable BMCalibrantD1, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD1 == 0)
		SetVariable BMCalibrantD1LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD1 == 0)
		SetVariable BMCalibrantD2, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD2 == 0)
		SetVariable BMCalibrantD2LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD2 == 0)
		SetVariable BMCalibrantD3, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD3 == 0)
		SetVariable BMCalibrantD3LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD3 == 0)
		SetVariable BMCalibrantD4, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD4 == 0)
		SetVariable BMCalibrantD4LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD4 == 0)
		SetVariable BMCalibrantD5, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD5 == 0)
		SetVariable BMCalibrantD5LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD5 == 0)
		SetVariable BMCalibrantD6, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD6 == 0)
		SetVariable BMCalibrantD6LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD5 == 0)
		SetVariable BMCalibrantD7, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD7 == 0)
		SetVariable BMCalibrantD7LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD5 == 0)
		SetVariable BMCalibrantD8, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD8 == 0)
		SetVariable BMCalibrantD8LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD5 == 0)
		SetVariable BMCalibrantD9, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD9 == 0)
		SetVariable BMCalibrantD9LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD5 == 0)
		SetVariable BMCalibrantD10, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD10 == 0)
		SetVariable BMCalibrantD10LineWidth, win=NI1_CreateBmCntrFieldPanel, disable=(BMUseCalibrantD5 == 0)
		NI1BC_DisplayCalibrantCircles()
	endif

	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_UpdateBmCntrListBox()

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	WAVE/T ListOfCCDDataInBmCntrPath = root:Packages:Convert2Dto1D:ListOfCCDDataInBmCntrPath
	WAVE   SelofCCDDataInBmCntrDPath = root:Packages:Convert2Dto1D:SelofCCDDataInBmCntrDPath
	SVAR   DataFileExtension         = root:Packages:Convert2Dto1D:BmCntrFileType
	SVAR/Z BCMatchNameString         = root:Packages:Convert2Dto1D:BCMatchNameString
	if(!SVAR_Exists(BCMatchNameString))
		string/G root:Packages:Convert2Dto1D:BCMatchNameString
	endif

	string RealExtension //for starnge extensions
	PathInfo Convert2Dto1DBmCntrPath
	if(V_Flag == 0)
		abort
	endif

	if(cmpstr(DataFileExtension, ".tif") == 0)
		realExtension = DataFileExtension
	elseif(cmpstr(DataFileExtension, "ADSC") == 0 || cmpstr(DataFileExtension, "ADSC_A") == 0) //ADSC_A has wavelength in A
		realExtension = ".img"
	elseif(cmpstr(DataFileExtension, "DND/txt") == 0)
		realExtension = ".txt"
	elseif(cmpstr(DataFileExtension, ".hdf") == 0)
		realExtension = ".hdf"
	elseif(cmpstr(DataFileExtension, "TPA/XML") == 0)
		realExtension = ".xml"
	elseif(cmpstr(DataFileExtension, "Nexus") == 0)
		realExtension = ".hdf"
	elseif(cmpstr(DataFileExtension, "SSRLMatSAXS") == 0)
		realExtension = ".tif"
	else
		realExtension = "????"
	endif
	string ListOfAvailableCompounds = ""
	if(cmpstr(realExtension, ".hdf") == 0) //there are many options for hdf...
		ListOfAvailableCompounds  = IndexedFile(Convert2Dto1DBmCntrPath, -1, ".hdf")
		ListOfAvailableCompounds += IndexedFile(Convert2Dto1DBmCntrPath, -1, ".h5")
		ListOfAvailableCompounds += IndexedFile(Convert2Dto1DBmCntrPath, -1, ".hdf5")
	elseif(cmpstr(realExtension, ".tif") == 0) //there are many options for hdf...
		ListOfAvailableCompounds  = IndexedFile(Convert2Dto1DBmCntrPath, -1, ".tif")
		ListOfAvailableCompounds += IndexedFile(Convert2Dto1DBmCntrPath, -1, ".tiff")
	else
		ListOfAvailableCompounds = IndexedFile(Convert2Dto1DBmCntrPath, -1, realExtension)
	endif
	if(strlen(BCMatchNameString) > 0)
		ListOfAvailableCompounds = GrepList(ListOfAvailableCompounds, BCMatchNameString)
	endif
	if(strlen(ListOfAvailableCompounds) < 2) //none found
		ListOfAvailableCompounds = "--none--;"
	endif
	ListOfAvailableCompounds = IN2G_RemoveInvisibleFiles(ListOfAvailableCompounds)
	ListOfAvailableCompounds = NI1A_CleanListOfFilesForTypes(ListOfAvailableCompounds, DataFileExtension, "")
	redimension/N=(ItemsInList(ListOfAvailableCompounds)) ListOfCCDDataInBmCntrPath
	redimension/N=(ItemsInList(ListOfAvailableCompounds)) SelofCCDDataInBmCntrDPath
	variable i
	ListOfCCDDataInBmCntrPath = NI1A_CleanListOfFilesForTypes(ListOfCCDDataInBmCntrPath, DataFileExtension, "")
	for(i = 0; i < ItemsInList(ListOfAvailableCompounds); i += 1)
		ListOfCCDDataInBmCntrPath[i] = StringFromList(i, ListOfAvailableCompounds)
	endfor
	sort ListOfCCDDataInBmCntrPath, ListOfCCDDataInBmCntrPath, SelofCCDDataInBmCntrDPath //, NumbersOfCompoundsOutsideIgor
	SelofCCDDataInBmCntrDPath = 0
	DOWIndow NI1_CreateBmCntrFieldPanel
	if(V_Flag) //if the window is not up, do not do anything.
		ListBox CCDDataSelection, win=NI1_CreateBmCntrFieldPanel, listWave=root:Packages:Convert2Dto1D:ListOfCCDDataInBmCntrPath
		ListBox CCDDataSelection, win=NI1_CreateBmCntrFieldPanel, row=0, mode=1, selRow=0
		DoUpdate
	endif
	setDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1BC_BmCntrButtonProc(ctrlName) : ButtonControl
	string ctrlName

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	variable i
	if(CmpStr(ctrlName, "CreateROIWorkImage") == 0)
		//create image for working here...
		NI1BC_BmCntrCreateImage()
		//set slider
		NVAR BMMaxCircleRadius = root:Packages:Convert2Dto1D:BMMaxCircleRadius
		WAVE BmCntrFieldImg    = root:Packages:Convert2Dto1D:BmCntrCCDImg
		BMMaxCircleRadius = sqrt(DimSize(BmCntrFieldImg, 0)^2 + DimSize(BmCntrFieldImg, 1)^2)
		Slider BMHelpCircleRadius, limits={1, BMMaxCircleRadius, 0}, win=NI1_CreateBmCntrFieldPanel
		SetVariable BMHelpCircleRadiusV, limits={1, BMMaxCircleRadius, 0}, win=NI1_CreateBmCntrFieldPanel
		NVAR BMImageRangeMinLimit = root:Packages:Convert2Dto1D:BMImageRangeMinLimit
		NVAR BMImageRangeMaxLimit = root:Packages:Convert2Dto1D:BMImageRangeMaxLimit
		Slider ImageRangeMin, limits={BMImageRangeMinLimit, BMImageRangeMaxLimit, 0}, win=NI1_CreateBmCntrFieldPanel
		Slider ImageRangeMax, limits={BMImageRangeMinLimit, BMImageRangeMaxLimit, 0}, win=NI1_CreateBmCntrFieldPanel
		NI1BC_DisplayHelpCircle()
		NI1BC_DisplayMask()
		TabControl BmCntrTab, value=0, win=NI1_CreateBmCntrFieldPanel
		NI1BC_TabProc("", 0)
		ShowInfo/W=CCDImageForBmCntr
	endif
	if(cmpstr(ctrlName, "GetHelp") == 0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Nika/BCandGeometry.html")
	endif

	if(CmpStr(ctrlName, "SelectPathToData") == 0)
		//check if we are running on USAXS computers
		GetFileFOlderInfo/Q/Z "Z:USAXS_data:"
		if(V_isFolder)
			//OK, this computer has Z:USAXS_data
			PathInfo Convert2Dto1DBmCntrPath
			if(V_flag == 0)
				NewPath/Q Convert2Dto1DBmCntrPath, "Z:USAXS_data:"
				pathinfo/S Convert2Dto1DBmCntrPath
			endif
		endif
		//PathInfo/S Convert2Dto1DMaskPath
		NewPath/C/O/M="Select path to your data" Convert2Dto1DBmCntrPath
		SVAR BCPathInfoStr = root:Packages:Convert2Dto1D:BCPathInfoStr
		PathInfo Convert2Dto1DBmCntrPath
		BCPathInfoStr = S_Path
		NI1BC_UpdateBmCntrListBox()
	endif
	if(CmpStr(ctrlName, "RefineParameters") == 0)
		NI1BC_RunRefinement()
	endif

	if(CmpStr(ctrlName, "RecoverParameters") == 0)
		NI1BC_RecoverParameters()
	endif
	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_BmCntrCreateImage()

	string OldDf = GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D
	WAVE/T ListOfCCDDataInBmCntrPath = root:Packages:Convert2Dto1D:ListOfCCDDataInBmCntrPath
	controlInfo/W=NI1_CreateBmCntrFieldPanel CCDDataSelection
	variable selection = V_Value
	if(selection < 0)
		setDataFolder OldDf
		abort
	endif
	KillWIndow/Z CCDImageForBmCntr
	SVAR FileNameToLoad = root:Packages:Convert2Dto1D:FileNameToLoad
	FileNameToLoad = ListOfCCDDataInBmCntrPath[selection]
	SVAR BmCntrFileType = root:Packages:Convert2Dto1D:BmCntrFileType
	//need to communicate to Nexus reader what we are loading and this seems the only way to do so
	string/G ImageBeingLoaded
	ImageBeingLoaded = ""
	//awful workaround end
	variable LoadedOK = NI1A_UniversalLoader("Convert2Dto1DBmCntrPath", FileNameToLoad, BmCntrFileType, "BmCntrCCDImg")
	if(!LoadedOK)
		abort "Loading the image file failed"
	endif
	NVAR BmCntrDisplayLogImage = root:Packages:Convert2Dto1D:BmCntrDisplayLogImage
	WAVE BmCntrCCDImg
	//allow user function modification to the image through hook function...
#if Exists("ModifyImportedImageHook") == 6
	ModifyImportedImageHook(BmCntrCCDImg)
#endif
	//		String infostr = FunctionInfo("ModifyImportedImageHook")
	//		if (strlen(infostr) >0)
	//			Execute("ModifyImportedImageHook(BmCntrCCDImg)")
	//		endif
	//end of allow user modification of imported image through hook function
	variable i
	NVAR BMDezinger = root:Packages:Convert2Dto1D:BMDezinger
	if(BMDezinger)
		NVAR BMDezinerTimes = root:Packages:Convert2Dto1D:BMDezinerTimes
		for(i = 0; i < BMDezinerTimes; i += 1)
			NI1A_DezingerImage(BmCntrCCDImg)
		endfor
	endif
	//subtract emopty if requested...
	NVAR BMSubtractBlank        = root:Packages:Convert2Dto1D:BMSubtractBlank
	NVAR BMStandardTransmission = root:Packages:Convert2Dto1D:BMStandardTransmission
	if(BMSubtractBlank)
		WAVE Empty = root:Packages:Convert2Dto1D:EmptyData
		MatrixOP/O BmCntrDisplayImage = BmCntrCCDImg - Empty * BMStandardTransmission
		MatrixOp/O BmCntrCCDImg = BmCntrDisplayImage
	else
		MatrixOp/O BmCntrDisplayImage = BmCntrCCDImg
	endif

	redimension/S BmCntrCCDImg
	//ed of dezinger...

	ImageStats BmCntrCCDImg
	if(BmCntrDisplayLogImage)
		MatrixOp/O BmCntrDisplayImage = log(BmCntrCCDImg)
		V_min = log(V_min)
		V_max = log(V_max)
		if(numType(V_min) != 0)
			V_min = 0
		endif
	else
		MatrixOp/O BmCntrDisplayImage = BmCntrCCDImg
	endif
	NVAR InvertImages = root:Packages:Convert2Dto1D:InvertImages
	if(InvertImages)
		NewImage/F/K=1 BmCntrDisplayImage
	else
		NewImage/K=1 BmCntrDisplayImage
	endif
	DoWindow/C CCDImageForBmCntr
	AutoPositionWindow/E/M=0/R=NI1_CreateBmCntrFieldPanel CCDImageForBmCntr
	NVAR ImageRangeMin      = root:Packages:Convert2Dto1D:BMImageRangeMin
	NVAR ImageRangeMax      = root:Packages:Convert2Dto1D:BMImageRangeMax
	NVAR ImageRangeMinLimit = root:Packages:Convert2Dto1D:BMImageRangeMinLimit
	NVAR ImageRangeMaxLimit = root:Packages:Convert2Dto1D:BMImageRangeMaxLimit
	SVAR BMColorTableName   = root:Packages:Convert2Dto1D:BMColorTableName
	ImageRangeMin      = V_min
	ImageRangeMinLimit = V_min
	ImageRangeMax      = V_max
	ImageRangeMaxLimit = V_max
	Slider ImageRangeMin, win=NI1_CreateBmCntrFieldPanel, limits={ImageRangeMinLimit, ImageRangeMaxLimit, 0}
	Slider ImageRangeMax, win=NI1_CreateBmCntrFieldPanel, limits={ImageRangeMinLimit, ImageRangeMaxLimit, 0}

	ModifyImage/W=CCDImageForBmCntr BmCntrDisplayImage, ctab={ImageRangeMin, ImageRangeMax, $BMColorTableName, 0}
	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_InitCreateBmCntrFile()

	string OldDf = GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:Convert2Dto1D

	string/G ListOfVariablesBC
	string/G ListOfStringsBC

	//here define the lists of variables and strings needed, separate names by ;...

	//ListOfVariables="AddFlat;FlatValToAdd;MaximumValueBmCntr;MinimumValueBmCntr;ImageRangeMaxLimit;ImageRangeMinLimit;BmCntrDisplayLogImage;"
	ListOfVariablesBC  = "BMImageRangeMaxLimit;BMImageRangeMinLimit;BMImageRangeMax;BMImageRangeMin;BmCntrDisplayLogImage;BMUseGeometryCorr;"
	ListOfVariablesBC += "BMBeamCenterXStep;BMBeamCenterYStep;BMDisplayHelpCircle;BMHelpCircleRadius;BMMaxCircleRadius;BMFitTilts;"
	ListOfVariablesBC += "BMCalibrantD1;BMUseCalibrantD1;BMCalibrantD2;BMUseCalibrantD2;BMCalibrantD3;BMUseCalibrantD3;BMCalibrantD4;BMUseCalibrantD4;BMCalibrantD5;BMUseCalibrantD5;"
	ListOfVariablesBC += "BMCalibrantD1LineWidth;BMCalibrantD2LineWidth;BMCalibrantD3LineWidth;BMCalibrantD4LineWidth;BMCalibrantD5LineWidth;BMCalibrantDisplayCircles;"
	ListOfVariablesBC += "BMCalibrantD6;BMUseCalibrantD6;BMCalibrantD7;BMUseCalibrantD7;BMCalibrantD8;BMUseCalibrantD8;BMCalibrantD9;BMUseCalibrantD9;BMCalibrantD10;BMUseCalibrantD10;"
	ListOfVariablesBC += "BMCalibrantD6LineWidth;BMCalibrantD7LineWidth;BMCalibrantD8LineWidth;BMCalibrantD9LineWidth;BMCalibrantD10LineWidth;"
	ListOfVariablesBC += "BMFitBeamCenter;BMFitSDD;BMFitWavelength;BMRefNumberOfSectors;BMDezinger;BMDezinerTimes;BMPathWidth;BMUseMask;BMDisplayInImage;"
	ListOfVariablesBC += "BMSubtractBlank;BMStandardTransmission;BMRefStepInAngle;BMPathWidthAll;"

	ListOfStringsBC  = "BmCntrFileName;BmCntrFileType;ExportBmCntrFileName;BMColorTableName;FileNameToLoad;"
	ListOfStringsBC += "BmCalibrantName;BMFunctionName;BCPathInfoStr;BCMatchNameString;"

	WAVE/Z/T ListOfCCDDataInBmCntrPath
	if(!WaveExists(ListOfCCDDataInBmCntrPath))
		make/O/T/N=0 ListOfCCDDataInBmCntrPath
	endif
	WAVE/Z SelofCCDDataInBmCntrDPath
	if(!WaveExists(SelofCCDDataInBmCntrDPath))
		make/O/N=0 SelofCCDDataInBmCntrDPath
	endif

	variable i
	//and here we create them
	for(i = 0; i < itemsInList(ListOfVariablesBC); i += 1)
		IN2G_CreateItem("variable", StringFromList(i, ListOfVariablesBC))
	endfor

	for(i = 0; i < itemsInList(ListOfStringsBC); i += 1)
		IN2G_CreateItem("string", StringFromList(i, ListOfStringsBC))
	endfor

	string ListOfVariablesL
	string ListOfStringsL
	//set start values
	ListOfVariablesL = "BMBeamCenterXStep;BMBeamCenterYStep;BMDisplayHelpCircle;BMHelpCircleRadius;BMMaxCircleRadius;BMCalibrantDisplayCircles;BMDezinerTimes;"
	for(i = 0; i < itemsInList(ListOfVariablesL); i += 1)
		NVAR testMe = $stringFromList(i, ListOfVariablesL)
		if(testMe == 0)
			testMe = 1
		endif
	endfor

	ListOfVariablesL  = "BMCalibrantD1LineWidth;BMCalibrantD2LineWidth;BMCalibrantD3LineWidth;BMCalibrantD4LineWidth;BMCalibrantD5LineWidth;"
	ListOfVariablesL += "BMCalibrantD6LineWidth;BMCalibrantD7LineWidth;BMCalibrantD8LineWidth;BMCalibrantD9LineWidth;BMCalibrantD10LineWidth;BMPathWidthAll;"
	for(i = 0; i < itemsInList(ListOfVariablesL); i += 1)
		NVAR testMe = $stringFromList(i, ListOfVariablesL)
		if(testMe == 0)
			testMe = 15
		endif
	endfor
	ListOfVariablesL = "BMRefNumberOfSectors;"
	for(i = 0; i < itemsInList(ListOfVariablesL); i += 1)
		NVAR testMe = $stringFromList(i, ListOfVariablesL)
		if(testMe == 0)
			testMe = 60
		endif
	endfor
	NVAR BMRefStepInAngle
	NVAR BMRefNumberOfSectors
	BMRefStepInAngle = 360 / BMRefNumberOfSectors
	ListOfVariablesL = "BMPathWidth;"
	for(i = 0; i < itemsInList(ListOfVariablesL); i += 1)
		NVAR testMe = $stringFromList(i, ListOfVariablesL)
		if(testMe == 0)
			testMe = 5
		endif
	endfor

	SVAR BmCalibrantName
	if(strlen(BmCalibrantName) < 1)
		BmCalibrantName = "user"
	endif
	SVAR BmCntrFileType
	if(strlen(BmCntrFileType) < 2)
		BmCntrFileType = ".tif"
	endif
	SVAR BMColorTableName
	if(strlen(BMColorTableName) < 1)
		BMColorTableName = "Terrain"
	endif
	SVAR BMFunctionName
	if(strlen(BMFunctionName) < 1)
		BMFunctionName = "Gauss"
	endif
	NVAR BMFitSDD
	NVAR BMFitWavelength
	if(BMFitSDD + BMFitWavelength > 1)
		BMFitSDD        = 1
		BMFitWavelength = 0
	endif
	setDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1BC_RecoverParameters()

	string oldDf = GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D

	WAVE/Z/T ParametersNames
	WAVE/Z   parametersWvBackup
	if(WaveExists(parametersWvBackup))
		variable i
		for(i = 0; i < numpnts(ParametersNames); i += 1)
			NVAR temp = $(ParametersNames[i])
			temp = parametersWvBackup[i]
		endfor
	endif
	setDataFolder OldDf
	NI1BC_DisplayCalibrantCircles()
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_RunRefinement()

	string oldDf = GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR BMRefNumberOfSectors = root:Packages:Convert2Dto1D:BMRefNumberOfSectors
	NVAR BMFitBeamCenter      = root:Packages:Convert2Dto1D:BMFitBeamCenter
	NVAR BMFitSDD             = root:Packages:Convert2Dto1D:BMFitSDD
	NVAR BMFitWavelength      = root:Packages:Convert2Dto1D:BMFitWavelength
	NVAR BMFitTilts           = root:Packages:Convert2Dto1D:BMFitTilts

	if(BMFitBeamCenter + BMFitSDD + BMFitWavelength + BMFitTilts < 0.5)
		//		abort //nothing to do, no fitting requested...
	endif
	if(BMFitSDD + BMFitWavelength > 1)
		//try to fit both SDD and wavelength, must have more tha 1 line...
		NVAR Use1  = root:Packages:Convert2Dto1D:BMUseCalibrantD1
		NVAR Use2  = root:Packages:Convert2Dto1D:BMUseCalibrantD2
		NVAR Use3  = root:Packages:Convert2Dto1D:BMUseCalibrantD3
		NVAR Use4  = root:Packages:Convert2Dto1D:BMUseCalibrantD4
		NVAR Use5  = root:Packages:Convert2Dto1D:BMUseCalibrantD5
		NVAR Use6  = root:Packages:Convert2Dto1D:BMUseCalibrantD6
		NVAR Use7  = root:Packages:Convert2Dto1D:BMUseCalibrantD7
		NVAR Use8  = root:Packages:Convert2Dto1D:BMUseCalibrantD8
		NVAR Use9  = root:Packages:Convert2Dto1D:BMUseCalibrantD9
		NVAR Use10 = root:Packages:Convert2Dto1D:BMUseCalibrantD10
		if(Use1 + Use2 + Use3 + Use4 + Use5 + Use6 + Use7 + Use8 + Use9 + Use10 < 1.5)
			abort "Not enough lines to fit both Sample to detector distance and wavelength, you need at least  2 lines"
		endif
	endif
	variable i
	for(i = 1; i <= 10; i += 1)
		NVAR BMUseCalibrantD = $("root:Packages:Convert2Dto1D:BMUseCalibrantD" + num2str(i))
		if(BMUseCalibrantD)
			NI1BC_GetEvaluationPaths(i, BMRefNumberOfSectors)
		endif
	endfor

	NI1BC_FitParameters()

	NI1BC_DisplayCalibrantCircles()
	RemoveFromGraph/W=CCDImageForBmCntr/Z ywave

	setDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_FitParameters()

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR BeamCenterX         = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY         = root:Packages:Convert2Dto1D:BeamCenterY
	NVAR Wavelength          = root:Packages:Convert2Dto1D:Wavelength
	NVAR SampleToCCDDistance = root:Packages:Convert2Dto1D:SampleToCCDDistance
	variable azimuthalAngle, i, MaxNumPixels

	variable radX
	variable radY
	variable CalibrantRadInPix
	variable startPnt, endPnt, minX, maxX, minY, maxY
	//variable angleStep=360/numberOfSectors

	//create wave containing d spacifngs for each point from known d spacing for that ring...
	KillWIndow/Z LineFitWindow
	make/O/N=0 CalibrantDspacings, CalibrantFitXpnts, calibrantFitYpnts
	variable tempStart
	for(i = 1; i <= 10; i += 1)
		NVAR BMUseCalibrantD = $("root:Packages:Convert2Dto1D:BMUseCalibrantD" + num2str(i))
		if(BMUseCalibrantD)
			WAVE BMOptimizeAngles = $("root:Packages:Convert2Dto1D:BMOptimizeAngles" + num2str(i))
			WAVE BMOptimizeXs     = $("BMOptimizeXs" + num2str(i))
			WAVE BMOptimizeYs     = $("BMOptimizeYs" + num2str(i))
			if(numpnts(BMOptimizeAngles) > 0)
				NVAR BMCalibrantD = $("root:Packages:Convert2Dto1D:BMCalibrantD" + num2str(i))
				//create list of X vealues we should calculate d spacing for
				Concatenate/NP/O {CalibrantFitXpnts, BMOptimizeXs}, CalibrantXYtmp
				//fix for 6.10 upodate...
				WAVE CalibrantXYtmp
				Duplicate/O CalibrantXYtmp, CalibrantFitXpnts
				//create list of Y vealues we should calculate d spacing for
				Concatenate/NP/O {CalibrantFitYpnts, BMOptimizeYs}, CalibrantXYtmp
				//fix for 6.10 upodate...
				WAVE CalibrantXYtmp
				Duplicate/O CalibrantXYtmp, CalibrantFitYpnts
				//			Wave BMOptimizeErrors = $("BMOptimizeErrors"+num2str(i))
				//create list of d spacing we need to fit for...
				tempStart = numpnts(CalibrantDspacings)
				redimension/N=(tempStart + numpnts(BMOptimizeAngles)) CalibrantDspacings
				CalibrantDspacings[tempStart, numpnts(CalibrantDspacings) - 1] = BMCalibrantD
			endif

		endif
	endfor

	Make/D/N=0/O parametersWv, parametersWvBackup, parametersWvStartStep
	Make/T/N=0/O ParametersNames
	NVAR BMFitBeamCenter = root:Packages:Convert2Dto1D:BMFitBeamCenter
	NVAR BMFitSDD        = root:Packages:Convert2Dto1D:BMFitSDD
	NVAR BMFitWavelength = root:Packages:Convert2Dto1D:BMFitWavelength
	NVAR BMFitTilts      = root:Packages:Convert2Dto1D:BMFitTilts
	NVAR HorizontalTilt  = root:Packages:Convert2Dto1D:HorizontalTilt
	NVAR VerticalTilt    = root:Packages:Convert2Dto1D:VerticalTilt
	//	NVAR AzimuthalTilt=root:Packages:Convert2Dto1D:AzimuthalTilt
	Make/O/T/N=0 T_Constraints
	variable indx = 0, curIndx = 0
	if(BMFitTilts)
		redimension/N=(numpnts(parametersWv) + 2) parametersWv, parametersWvBackup, parametersWvStartStep
		redimension/N=(numpnts(ParametersNames) + 2) ParametersNames
		HorizontalTilt                                   = (abs(HorizontalTilt) > 0.3) ? HorizontalTilt : 1
		VerticalTilt                                     = (abs(VerticalTilt) > 0.3) ? VerticalTilt : 1
		parametersWv[numpnts(parametersWv) - 2]          = HorizontalTilt
		parametersWv[numpnts(parametersWv) - 1]          = VerticalTilt
		parametersWvStartStep[numpnts(parametersWv) - 2] = (abs(HorizontalTilt) > 10) ? HorizontalTilt / 10 : 1
		parametersWvStartStep[numpnts(parametersWv) - 1] = (abs(VerticalTilt) > 10) ? VerticalTilt / 10 : 1
		ParametersNames[numpnts(parametersWv) - 2]       = "HorizontalTilt"
		ParametersNames[numpnts(parametersWv) - 1]       = "VerticalTilt"
		redimension/N=(numpnts(T_Constraints) + 4) T_Constraints
		T_Constraints[indx]     = "K" + num2str(curIndx) + ">" + num2str(HorizontalTilt - 45)
		T_Constraints[indx + 1] = "K" + num2str(curIndx) + "<" + num2str(HorizontalTilt + 45)
		T_Constraints[indx + 2] = "K" + num2str(curIndx + 1) + ">" + num2str(VerticalTilt - 45)
		T_Constraints[indx + 3] = "K" + num2str(curIndx + 1) + "<" + num2str(VerticalTilt + 45)
		indx                   += 4
		curIndx                += 2
	endif
	if(BMFitBeamCenter)
		redimension/N=(numpnts(parametersWv) + 2) parametersWv, parametersWvBackup, parametersWvStartStep
		redimension/N=(numpnts(ParametersNames) + 2) ParametersNames
		parametersWv[numpnts(parametersWv) - 2]          = BeamCenterX
		parametersWv[numpnts(parametersWv) - 1]          = BeamCenterY
		parametersWvStartStep[numpnts(parametersWv) - 2] = 1
		parametersWvStartStep[numpnts(parametersWv) - 1] = 1
		ParametersNames[numpnts(parametersWv) - 2]       = "BeamCenterX"
		ParametersNames[numpnts(parametersWv) - 1]       = "BeamCenterY"
		redimension/N=(numpnts(T_Constraints) + 4) T_Constraints
		T_Constraints[indx]     = "K" + num2str(curIndx) + ">" + num2str(BeamCenterX - 50)
		T_Constraints[indx + 1] = "K" + num2str(curIndx) + "<" + num2str(BeamCenterX + 50)
		T_Constraints[indx + 2] = "K" + num2str(curIndx + 1) + ">" + num2str(BeamCenterY - 50)
		T_Constraints[indx + 3] = "K" + num2str(curIndx + 1) + "<" + num2str(BeamCenterY + 50)
		indx                   += 4
		curIndx                += 2
	endif
	if(BMFitSDD)
		redimension/N=(numpnts(parametersWv) + 1) parametersWv, parametersWvBackup, parametersWvStartStep
		redimension/N=(numpnts(ParametersNames) + 1) ParametersNames
		parametersWv[numpnts(parametersWv) - 1]          = SampleToCCDDistance
		parametersWvStartStep[numpnts(parametersWv) - 1] = SampleToCCDDistance / 20
		ParametersNames[numpnts(parametersWv) - 1]       = "SampleToCCDDistance"
		redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
		T_Constraints[indx]     = "K" + num2str(curIndx) + ">" + num2str(SampleToCCDDistance * 0.8)
		T_Constraints[indx + 1] = "K" + num2str(curIndx) + "<" + num2str(SampleToCCDDistance * 1.2)
		indx                   += 2
		curIndx                += 1
	endif
	if(BMFitWavelength)
		redimension/N=(numpnts(parametersWv) + 1) parametersWv, parametersWvBackup, parametersWvStartStep
		redimension/N=(numpnts(ParametersNames) + 1) ParametersNames
		parametersWv[numpnts(parametersWv) - 1]          = Wavelength
		parametersWvStartStep[numpnts(parametersWv) - 1] = Wavelength / 20
		ParametersNames[numpnts(parametersWv) - 1]       = "Wavelength"
		redimension/N=(numpnts(T_Constraints) + 2) T_Constraints
		T_Constraints[indx]     = "K" + num2str(curIndx) + ">" + num2str(Wavelength * 0.9)
		T_Constraints[indx + 1] = "K" + num2str(curIndx) + "<" + num2str(Wavelength * 1.1)
		indx                   += 2
		curIndx                += 1
	endif
	parametersWvBackup = parametersWv
	//	Duplicate/O parametersWv, parametersWvStartStep
	//	parametersWvStartStep = 0.05 * parametersWvStartStep
	//	parametersWvStartStep = abs(parametersWvStartStep[p])>0.02 ? abs(parametersWvStartStep[p]) : 0.02
	//fitting...................
	variable V_fitError   = 0
	variable V_fitOptions = 4
	//print parametersWv
	//	FuncFit/Q NI1BC_RefinementFunction parametersWv  CalibrantXY /X=CalibrantAngles /I=1 /W=CalibrantErrors /E=parametersWvStartStep
	//	FuncFit/Q NI1BC_RefinementFunction parametersWv  CalibrantXY /X=CalibrantAngles /E=parametersWvStartStep/C=T_Constraints

	FuncFit/Q NI1BC_RefinementFunction, parametersWv, CalibrantDspacings/E=parametersWvStartStep/C=T_Constraints

	//	make/O tempWvParms
	//	//try Optimize
	//	Optimize /I=20/X=parametersWv NI1BC_OptimizeFunction, tempWvParms
	//fitting...................
	STRUCT NikadetectorGeometry d
	if(V_fitError == 0)
		for(i = 0; i < numpnts(ParametersNames); i += 1)
			NVAR temp = $(ParametersNames[i])
			temp = parametersWv[i]
			if(cmpstr(ParametersNames[i], "Wavelength") == 0)
				NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy
				XrayEnergy = 12.398424437 / temp
			endif
		endfor
		NI2T_ReadOrientationFromGlobals(d)
		NI2T_SaveStructure(d)
		print "Fitting of beam center and other geometry parameters finished with chi-square of : " + num2str(V_chisq)
	else
		for(i = 0; i < numpnts(ParametersNames); i += 1)
			NVAR temp = $(ParametersNames[i])
			temp = parametersWvBackup[i]
			if(cmpstr(ParametersNames[i], "Wavelength") == 0)
				NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy
				XrayEnergy = 12.398424437 / temp
			endif
		endfor
		NI2T_ReadOrientationFromGlobals(d)
		NI2T_SaveStructure(d)
		abort "Fitting was unsuccesful, no changes made. Make different parameter selection and try again..."
	endif

	setDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_CalculateDSpacing(Xpos, Ypos)
	variable Xpos, Ypos

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR     Wavelength = root:Packages:Convert2Dto1D:Wavelength
	variable Theta      = NI2T_CalculateThetaWithTilts2(Xpos, Ypos)
	variable dspacing   = 0.5 * Wavelength / sin(theta)
	return dspacing
	setDataFolder OldDf

End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI2BC_GaussWithSlopeBckg(w, x) : FitFunc
	WAVE     w
	variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = y0+y1*x+A*exp(-((x-x0)/width)^2)
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 5
	//CurveFitDialog/ w[0] = y0
	//CurveFitDialog/ w[1] = A
	//CurveFitDialog/ w[2] = x0
	//CurveFitDialog/ w[3] = width
	//CurveFitDialog/ w[4] = y1

	return w[0] + w[4] * x + w[1] * exp(-((x - w[2]) / w[3])^2)
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_RefinementFunction(pw, yw, xw) : FitFunc
	WAVE pw, yw, xw

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	WAVE     parametersWv
	WAVE/T   ParametersNames
	variable i
	for(i = 0; i < numpnts(ParametersNames); i += 1)
		NVAR temp = $(ParametersNames[i])
		temp = pw[i]
	endfor
	STRUCT NikadetectorGeometry d
	NI2T_ReadOrientationFromGlobals(d)
	NI2T_SaveStructure(d)
	variable LocalNumPnts, OldLength = 0

	WAVE CalibrantFitXpnts
	WAVE calibrantFitYpnts

	yw = NI1BC_CalculateDSpacing(CalibrantFitXpnts[p], calibrantFitYpnts[p])
	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_OptimizeFunction(w, pw)
	WAVE w, pw

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	WAVE     parametersWv
	WAVE/T   ParametersNames
	variable i
	for(i = 0; i < numpnts(ParametersNames); i += 1)
		NVAR temp = $(ParametersNames[i])
		temp = pw[i]
	endfor
	STRUCT NikadetectorGeometry d
	NI2T_ReadOrientationFromGlobals(d)
	NI2T_SaveStructure(d)
	variable LocalNumPnts, OldLength = 0

	WAVE CalibrantFitXpnts
	WAVE calibrantFitYpnts
	WAVE CalibrantDspacings

	Duplicate/O CalibrantDspacings, tempWvOptimize
	tempWvOptimize = NI1BC_CalculateDSpacing(CalibrantFitXpnts[p], calibrantFitYpnts[p])

	tempWvOptimize = tempWvOptimize[p] - CalibrantDspacings[p]

	tempWvOptimize = tempWvOptimize[p]^2

	variable distance = sqrt(sum(tempWvOptimize))

	return distance
	setDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_GetEvaluationPaths(CalibrantLine, numberOfSectors)
	variable CalibrantLine, numberOfSectors

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	NVAR BeamCenterX         = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY         = root:Packages:Convert2Dto1D:BeamCenterY
	NVAR PixelSizeX          = root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY          = root:Packages:Convert2Dto1D:PixelSizeY
	NVAR SampleToCCDDistance = root:Packages:Convert2Dto1D:SampleToCCDDistance
	NVAR HorizontalTilt      = root:Packages:Convert2Dto1D:HorizontalTilt
	NVAR VerticalTilt        = root:Packages:Convert2Dto1D:VerticalTilt
	NVAR Wavelength          = root:packages:Convert2Dto1D:Wavelength

	NVAR   BMPathWidth       = root:Packages:Convert2Dto1D:BMPathWidth
	NVAR   BMUseMask         = root:Packages:Convert2Dto1D:BMUseMask
	NVAR   BMUseGeometryCorr = root:Packages:Convert2Dto1D:BMUseGeometryCorr
	WAVE/Z M_ROIMask         = root:Packages:Convert2Dto1D:M_ROIMask

	WAVE BmCntrImage = root:Packages:Convert2Dto1D:BmCntrCCDImg
	if(BMUseMask && WaveExists(M_ROIMask))
		MatrixOp/O BmCntrImageMsk = BmCntrImage / M_ROIMask
	else
		MatrixOp/O BmCntrImageMsk = BmCntrImage
	endif
	WAVE BmCntrImageMsk = root:Packages:Convert2Dto1D:BmCntrImageMsk
	//we need to get path for each direction, pick 30 directions, each therefore 6 degrees appart
	variable azimuthalAngle, i, MaxNumPixels
	if(BeamCenterX > 0 && BeamCenterX < DimSize(BmCntrImage, 0) && BeamCenterY > 0 && BeamCenterY < DimSize(BmCntrImage, 1))
		//true but only if center is in the field of picture.... If it is outside, we need to add a bit.
		MaxNumPixels = floor(sqrt(DimSize(BmCntrImage, 0)^2 + DimSize(BmCntrImage, 1)^2))
	else
		MaxNumPixels = floor(sqrt((abs(BeamCenterX) + DimSize(BmCntrImage, 0))^2 + (abs(BeamCenterY) + DimSize(BmCntrImage, 1))^2))
	endif

	//NVAR  BMUseCalibrantD=$("root:Packages:Convert2Dto1D:BMUseCalibrantD"+num2str(i))
	NVAR     BMCalibrantD          = $("root:Packages:Convert2Dto1D:BMCalibrantD" + num2str(CalibrantLine))               //d spacing for calibrant
	NVAR     BMCalibrantDLineWidth = $("root:Packages:Convert2Dto1D:BMCalibrantD" + num2str(CalibrantLine) + "LineWidth") //line width
	variable radX                  = NI1BC_GetPixelFromDSpacing(BMCalibrantD, "X")                                        //for no tilts correction this is x direction radius for the line in pixels
	variable radY                  = NI1BC_GetPixelFromDSpacing(BMCalibrantD, "Y")                                        //same for y direction
	variable CalibrantRadInPix     = radX
	variable startPnt, endPnt, minX, maxX, minY, maxY
	variable angleStep    = 360 / numberOfSectors
	variable V_fitOptions = 4
	variable V_FitError   = 0
	//the following are waves with numbers we will fit to
	Make/O/N=0 $("BMOptimizeAngles" + num2str(CalibrantLine)), $("BMOptimizeXs" + num2str(CalibrantLine)), $("BMOptimizeYs" + num2str(CalibrantLine)), $("BMOptimizeErrors" + num2str(CalibrantLine))
	WAVE BMOptimizeAngles = $("BMOptimizeAngles" + num2str(CalibrantLine))
	WAVE BMOptimizeXs     = $("BMOptimizeXs" + num2str(CalibrantLine))     //measured X for the diffraction line in Angle direction
	WAVE BMOptimizeYs     = $("BMOptimizeYs" + num2str(CalibrantLine))     //measured Y
	WAVE BMOptimizeErrors = $("BMOptimizeErrors" + num2str(CalibrantLine)) //error fo the measurement
	SVAR BMFunctionName   = root:Packages:Convert2Dto1D:BMFunctionName
	NVAR BMDisplayInImage = root:Packages:Convert2Dto1D:BMDisplayInImage

	Make/O/N=(MaxNumPixels) xwave, ywave, radialDistWv, MyProfile, xwaveT, ywaveT, GeomCorrWv //working folder
	for(i = 0; i < numberOfSectors; i += 1)
		redimension/N=(MaxNumPixels) xwave, ywave, radialDistWv, MyProfile, xwaveT, ywaveT //OK, here is the part which depends on the tilts..
		//Original code, no tilt...
		if(abs(HorizontalTilt) < 0.01 && abs(VerticalTilt) < 0.01)
			CalibrantRadInPix = sqrt((radX * cos(i * angleStep * (pi / 180)))^2 + (radY * sin(i * angleStep * (pi / 180)))^2) //this is distance of the ring calcualted from dspacing (~radX, radY)
		else //need to account for tilts... Bit more complex.
			variable/C tempPxPy
			variable theta = asin(Wavelength / (2 * BMCalibrantD)) //in radians...
			tempPxPy = NI2T_CalculatePxPyWithTilts(theta, (i * angleStep * pi / 180))
			//tempPxPy = NI1BC_FindTiltedPxPyValues(BMCalibrantD,(i * angleStep*pi/180))
			tempPxPy = tempPxPy - cmplx(BeamCenterX, BeamCenterY)
			//tempPxPy = cmplx(BeamCenterX,BeamCenterY)-tempPxPy
			CalibrantRadInPix = sqrt(magsqr(tempPxPy))
			//print "azim angle = "+num2str(i * angleStep)+"   distance ="+num2str(CalibrantRadInPix) + "   positions : x ="+num2str(real(tempPxPy))+ " y ="+num2str(imag(tempPxPy))
		endif
		//keeps bombing on tilted calculations, since the thing returns NaN when it runs out of detector...

		if(numtype(CalibrantRadInPix) == 0)
			xwave        = BeamCenterX + p * cos(i * angleStep * (pi / 180))
			ywave        = BeamCenterY + p * sin(i * angleStep * (pi / 180))
			xwaveT       = p * cos(i * angleStep * (pi / 180))
			ywaveT       = -p * sin(i * angleStep * (pi / 180))
			radialDistWv = sqrt((xwaveT)^2 + (ywaveT)^2) //this is distace from beam center as wave so we can figure out where to go...
			if(BMUseGeometryCorr)
				redimension/N=(numpnts(radialDistWv)) GeomCorrWv
				NI1BC_SolidangleCorrection(radialDistWv, GeomCorrWv, (PixelSizeY + PixelSizeX) / 2, SampleToCCDDistance) //rough approximation, for now valid strictly only for square pixels...
			endif
			startPnt = BinarySearch(radialDistWv, CalibrantRadInPix - BMCalibrantDLineWidth)
			endPnt   = BinarySearch(radialDistWv, CalibrantRadInPix + BMCalibrantDLineWidth) + 1
			if(startPnt > 0 && endPnt > 0)
				DeletePoints endPnt, Inf, xwave, ywave, GeomCorrWv
				DeletePoints 0, startPnt, xwave, ywave, GeomCorrWv
				wavestats/Q xwave
				minX = V_min
				maxX = V_max
				wavestats/Q ywave
				minY = V_min
				maxY = V_max
				if(MinX >= 0 && maxX <= dimsize(BmCntrImage, 0) && MinY >= 0 && maxY <= dimsize(BmCntrImage, 1))
					ImageLineProfile xWave=xwave, yWave=ywave, srcwave=BmCntrImageMsk, width=BMPathWidth
					CheckDisplayed/A/W=CCDImageForBmCntr ywave
					if(!V_flag && BMDisplayInImage)
						AppendtoGraph/T/W=CCDImageForBmCntr ywave vs xwave
						ModifyGraph/W=CCDImageForBmCntr lsize=5, lstyle=1, rgb=(65280, 16384, 16384)
					endif
					WAVE W_ImageLineProfile
					if(BMUseGeometryCorr)
						//need to check W_ImageLineProfile has same number of points as GeomCorrWv, seem s like routinely it has more...
						variable LineProfNPS, WcoefNPS
						LineProfNPS = numpnts(W_ImageLineProfile)
						WcoefNPS    = numpnts(GeomCorrWv)
						if(LineProfNPS != WcoefNPS)
							Redimension/N=(LineProfNPS) GeomCorrWv
							if(LineProfNPS > WcoefNPS)
								GeomCorrWv[LineProfNPS - 1] = GeomCorrWv[LineProfNPS - 2]
							endif
						endif
						W_ImageLineProfile = W_ImageLineProfile * GeomCorrWv
					endif
					wavestats/Q W_ImageLineProfile
					if(V_numINFs == 0 && V_numNans == 0 && V_max > 0)
						DoWindow LineFitWindow
						if(!V_Flag)
							Display/K=1 W_ImageLineProfile
							DoWindow/C/T LineFitWindow, "Profile Fit window"
						endif
						DoWindow/F LineFitWindow
						V_FitError = 0
						if(cmpstr(BMFunctionName, "Gauss") == 0)
							CurveFit/Q/N gauss, W_ImageLineProfile/D
						elseif(cmpstr(BMFunctionName, "GaussWithSlopedBckg") == 0)
							CurveFit/Q/O/N gauss, W_ImageLineProfile/D
							WAVE W_coef
							//fix bad estimate in case of K1<0, this indicates failure of Gauss to estimate the right position...
							//lets do estimate by having K1 (A) =max value for W_ImageLineProfile, and K2 (position) = mid point and K3 (width) = 0.2*number of points
							if(W_coef[1] < 0)
								wavestats/Q W_ImageLineProfile
								W_coef[1] = V_max
								W_coef[2] = V_npnts / 2
								W_coef[3] = V_npnts / 5
							endif
							Make/O/T/N=4 T_Constraints
							T_Constraints[0] = {"K0 > 0", "K1 > 0", "K2 > 0", "K3 > 0"}
							Duplicate/O W_coef, W_startVals
							redimension/N=5 W_startVals
							W_startVals[4] = (W_ImageLineProfile[Inf] - W_ImageLineProfile[0]) / numpnts(W_ImageLineProfile)
							W_startVals[0] = W_startVals[0] - W_startVals[4] * numpnts(W_ImageLineProfile) / 2
							FuncFit/Q/N NI2BC_GaussWithSlopeBckg, W_startVals, W_ImageLineProfile/D/C=T_Constraints
							Duplicate/O W_startVals, W_Coef
						else
							CurveFit/Q/N Lor, W_ImageLineProfile/D
						endif
						WAVE W_sigma
						ModifyGraph/W=LineFitWindow mode(W_ImageLineProfile)=3, marker(W_ImageLineProfile)=19
						ModifyGraph/W=LineFitWindow rgb(W_ImageLineProfile)=(0, 0, 65280), lsize(fit_W_ImageLineProfile)=2
						Label/W=LineFitWindow left, "Intensity"
						ModifyGraph/W=LineFitWindow mirror=1
						Label/W=LineFitWindow bottom, "Pixels"
						TextBox/W=LineFitWindow/C/N=text0/A=LT "Angle = " + num2str(i * angleStep)
						DoUpdate
						//Sleep/S 2
						WAVE W_coef // really need w_coef[2] which is the position of center of gaussien ={134.04,71.355,30.111,12.034}
						//print num2str(i * angleStep ) +"   " + num2str(W_coef[2])
						if(W_coef[2] > 1 && W_coef[2] < numpnts(W_ImageLineProfile) - 2) //fitting did not fall or other wise this will be 0
							redimension/N=(numpnts(BMOptimizeYs) + 1) BMOptimizeYs, BMOptimizeXs, BMOptimizeAngles, BMOptimizeErrors
							BMOptimizeAngles[numpnts(BMOptimizeAngles) - 1] = i * angleStep
							BMOptimizeYs[numpnts(BMOptimizeAngles) - 1]     = ywave[W_coef[2]]
							BMOptimizeXs[numpnts(BMOptimizeAngles) - 1]     = xwave[W_coef[2]]
							BMOptimizeErrors[numpnts(BMOptimizeAngles) - 1] = W_sigma[2]
						endif
					endif
				endif
			endif
		endif
	endfor

	KillWaves/Z BmCntrImageMsk
	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1BC_SolidangleCorrection(radialDistWv, GeomCorrWv, pixelsize, SDD) //from Dale Schaefer, needs to be checked what is it doing...
	WAVE radialDistWv, GeomCorrWv
	variable pixelsize, SDD

	string oldDf = GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	duplicate/O radialDistWv, omega, SAP, HYP, theta
	theta = atan(radialDistWv / SDD) //theta here is really 2Theta, since it is angle between beam in and out...
	SAP   = PixelSize * cos(theta)   //this is projection of pixel into the direction perpendicular to the center line from sample
	// HYP=((PixelSize*(qwave))^2+SDD^2)^(1/2)//qout is still in pixels
	HYP = SDD / cos(theta) //this is distance from the sample
	//       qwave=(4*pi/wavelength)*(sin(theta/2))
	omega = (SAP / HYP) //this is angle under which we see the pixel from the sample
	variable startOmega = omega[0]
	omega /= startOmega //and this is to scale it, so the correction for center pixel is 1
	duplicate/O theta, PF
	PF         = (1 + cos((theta))^2) / 2 // polarization factor
	GeomCorrWv = 1 / (omega^2 * PF)       //Squared because it is solid angle and the above is done for lin angle
	killwaves/Z SAP, HYP, omega, PF, theta
	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//
//
//Function NI1BC_CalcXYForAngleAndParam(Type, Angle, BeamCenterX, BeamCenterY, dspacing,Wavelength,SampleToCCDDistance)
//	variable Angle, BeamCenterX, BeamCenterY, dspacing,Wavelength,SampleToCCDDistance		//d in A, angle in degrees, centers in pixles etc...
//	string Type		//X (horizontal) or Y (vertical)
//
//	string oldDf=GetDataFOlder(1)
//	setDataFolder root:Packages:Convert2Dto1D
//	NVAR PixelSizeX
//	NVAR PixelSizeY
//	NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt							//tilt in degrees
//	NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt								//tilt in degrees
//	variable TheoreticalDistance, pixelDistX, pixelDistY 			//distance from center of the line
//	variable pixelPosXAngle, pixelPosYAngle
//	//Ok, this should just return simple Bragg law with little trigonometry
//	//
//	//wrong at high angles...pixelDist = 2 * SampleToCCDDistance * asin( Wavelength /(2* dspacing) )
//	variable SDDLoc=SampleToCCDDistance
//	TheoreticalDistance =  SDDLoc * tan(2* asin( Wavelength /(2* dspacing) ) )	//this is theoretical distance on detector in perfect alignment
//	pixelDistX = TheoreticalDistance* cos(Angle * (pi/180))  / PixelSizeX 		//this is in pixels how much that theoretical distance is...  in X direction corrected for azimuthal angle...
//	pixelDistY = TheoreticalDistance *(-1)* sin(Angle * (pi/180))  / PixelSizeY		//this is in pixels
//	variable  SampleToCCDDistanceX = SampleToCCDDistance/PixelSizeX		//this is now in pixles aslo
//	variable  SampleToCCDDistanceY = SampleToCCDDistance/PixelSizeY
//	setDataFolder OldDf
//	variable/C CmplxPxPy
//	if(abs(HorizontalTilt)<1e-12&&abs(VerticalTilt)<1e-12)		//no tilts, old code...
//		if(cmpstr(Type,"X")==0)
//	//		return BeamCenterX + NI1T_TheoreticalToTilted(pixelDistX, SampleToCCDDistanceX, HorizontalTilt)
//			return BeamCenterX + pixelDistX
//		elseif(cmpstr(Type,"Y")==0)
//	//		return BeamCenterY + NI1T_TheoreticalToTilted(pixelDistY, SampleToCCDDistanceY, VerticalTilt)
//			return BeamCenterY + pixelDistY
//		else
//			return 0
//		endif
//	else		//tilts used, need to find it with tilts...
//		CmplxPxPy = NI1BC_FindTiltedPxPyValues(dspacing,(Angle*pi/180))
//		if(cmpstr(Type,"X")==0)
//			return real(CmplxPxPy)
//		elseif(cmpstr(Type,"Y")==0)
//			return imag(CmplxPxPy)
//		else
//			return 0
//		endif
//	endif
//end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

