#pragma rtGlobals=2		// Use modern global access method.
#pragma version = 2.13


//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.13 modified size of the graphs nowusing general function to make graphs suitabel for window area. 
//2.12  removed unused functions
//2.11 Modified Screen Size check to match the needs
//2.10 added getHelp button calling to www manual
//2.09 sped up about 6x the smearing routine in IR1B_SmearData. May need to be checked, seems to work in Unified, Modeling II and Desmearing.
//2.08 propagate dQ if exists in slit smeared data, if does not exist, fake one from distance between points. 
//2.07 fixed Next sample button where there was weird bug when one was goign between use of manual selection and next sample buttons. 
//2.06 changed back to rtGlobals=2, need to check code much more to make it 3
//2.05 fixed index running out again. 
//2.04 converted to rtGlobals=3
//2.03  Modified all controls not to define font and font size to enable proper control by user 
//2.02 changed to use optimized IR2P_ListOfWavesOfType function 
//2.01 added license for ANL

//	This procedure does desmearing using Lake method


//**********************************
//**********************************This routine desmears data using Lake method****************************
//**********************************************************************************************************


Function IR1B_DesmearingMain()
	
	IN2G_CheckScreenSize("height",650)

	KillWIndow/Z IR1B_DesmearingControlPanel
	KillWIndow/Z TrimGraph
	KillWIndow/Z CheckTheBackgroundExtns
	KillWIndow/Z DesmearingProcess
	IR1B_Initialize()					//this may be OK now... 
	IR1B_DesmearingControlPanelFnct()
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************


Function IR1B_DesmearingControlPanelFnct() 
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(2.25,43.25,390,690)/N=IR1B_DesmearingControlPanel as "Desmearing"
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup="r*:q*;"
	string EUserLookup="r*:s*;"
	IR2C_AddDataControls("Irena_desmearing","IR1B_DesmearingControlPanel","M_SMR_Int;SMR_Int;","",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,0)
	SetDrawLayer UserBack
	SetDrawEnv fname= "Times New Roman",fsize= 22,fstyle= 3,textrgb= (0,0,52224)
	DrawText 58,28,"Desmearing control panel"
	SetDrawEnv linethick= 3,linefgc= (0,0,52224)
	DrawLine 16,181,339,181
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 8,49,"Data input"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 20,209,"Desmearing controls"

	//Experimental data input
	NVAR UseIndra2data = root:Packages:Irena_desmearing:UseIndra2data
	Button DrawGraphs,pos={100,158},size={90,20}, proc=IR1B_InputPanelButtonProc,title="Graph", help={"Create a graph (log-log) of your experiment data and start process"}
	Button NextSampleAndDrawGraphs,pos={200,158},size={90,20}, proc=IR1B_InputPanelButtonProc,title="Next sample", help={"Select next sample in order and Create a graph (log-log) of your experiment data and start process"}
	Button NextSampleAndDrawGraphs,disable=!(UseIndra2data)
	SetVariable SlitLength,pos={10,216},size={140,16},noproc,title="Slit length", help={"Input slit length in Q units (you should be using A-1 in this package)"}
	SetVariable SlitLength,limits={0,Inf,0},variable= root:Packages:Irena_desmearing:SlitLength
	SetVariable SlitLengthL,pos={180,216},size={140,16},noproc,title="Slit length L", help={"Slit length L parameters for trapeziodal slit in Q units (you should be using A-1 in this package)"}
	SetVariable SlitLengthL,limits={0,Inf,0},variable= root:Packages:Irena_desmearing:SlitLengthL
	SetVariable SlitWidth,pos={10,230},size={140,16},noproc,title="Slit width ", help={"Input slit width in Q units (you should be using A-1 in this package)"}
	SetVariable SlitWidth,limits={0,Inf,0},variable= root:Packages:Irena_desmearing:SlitWidth
	SetVariable SlitWidthL,pos={180,230},size={140,16},noproc,title="Slit width L ", help={"Slit width L parameters for trapeziodal slit in Q units (you should be using A-1 in this package)"}
	SetVariable SlitWidthL,limits={0,Inf,0},variable= root:Packages:Irena_desmearing:SlitWidthL
	Button ExplainSlitGeom,pos={230,190},size={120,15}, proc=IR1B_InputPanelButtonProc,title="Explain Slit geom", help={"Get explanation of slit geometry"}
	Button GetHelp,pos={305,105},size={80,15},fColor=(65535,32768,32768), proc=IR1B_InputPanelButtonProc,title="Get Help", help={"Open www manual page for this tool"}

	//Dist Tabs definition
	TabControl DesmearTabs,pos={10,260},size={370,200},proc=IR1B_TabPanelControl
	TabControl DesmearTabs,tabLabel(0)="1. Trim",tabLabel(2)="3. Extrap"
	TabControl DesmearTabs,tabLabel(1)="2. Smooth"
	TabControl DesmearTabs,tabLabel(4)="5. Smooth"
	TabControl DesmearTabs,tabLabel(3)="4. Desmear",value= 0

	//trim controls
	Button TrimDataBtn, pos={50, 320}, size={100,20},  proc=IR1B_Trim,title="Trim", help={"Trim the data and leave only data between the cursors"}
	Button RemovePoint pos={50,370}, size={140,20},  title="Remove pnt w/csrA", proc=IN2G_RemovePointWithCursorA, help={"Remove one point using rounded cursor (A). "}
	
	//Smooth SMR controls
	CheckBox SmoothSMRData,pos={50,300},size={141,14},variable=root:Packages:Irena_desmearing:SmoothSMRData,title="Smooth Smeared data?",proc=IR1B_InputPanelCheckboxProc, help={"Smooth smeared data?"}
	Slider SmoothSMRDataSlider pos={50,350},size={300,20},vert=0
	Slider SmoothSMRDataSlider proc=IR1B_SliderProc,variable=root:Packages:Irena_desmearing:SmoothingParameterSMR
	Slider SmoothSMRDataSlider value=0.001,limits={1e-6,12,0},ticks=0
	Slider SmoothSMRDataSlider help={"Slide to change smoothing parameter"}		
	SetVariable SmoothSMRChiSq,pos={50,400},size={300,18},proc=noproc,title="normalized ChiSquared reached   =  ", variable=root:Packages:Irena_desmearing:NormalizedChiSquareSMR,noedit=1
	SetVariable SmoothSMRChiSq limits={-Inf,Inf,0},frame=0

	//smooth DSM data
	CheckBox SmoothDSMData,pos={50,300},size={141,14},variable=root:Packages:Irena_desmearing:SmoothDSMData,title="Smooth Desmeared data?",proc=IR1B_InputPanelCheckboxProc, help={"Check to smooth the desmeared data. Not very suggested..."}
	Slider SmoothDSMDataSlider pos={50,350},size={300,20},vert=0
	Slider SmoothDSMDataSlider proc=IR1B_SliderProc,variable=root:Packages:Irena_desmearing:SmoothingParameterDSM
	Slider SmoothDSMDataSlider value=0.001,limits={1e-6,12,0}, ticks=0
	Slider SmoothDSMDataSlider help={"Slide to change smoothing parameter"}		
	SetVariable SmoothDSMChiSq,pos={50,420},size={300,18},proc=noproc,title="normalized ChiSquared reached   =  ", variable=root:Packages:Irena_desmearing:NormalizedChiSquareDSM,noedit=1
	SetVariable SmoothDSMChiSq limits={-Inf,Inf,0},frame=0, help={"Chi-squared reached..."}
	Button RecalcDSMSmooth pos={50,380}, size={140,20},  title="Recalculate", proc=IR1B_InputPanelButtonProc, help={"Recalculate the smoothing. Needed when you change cursor position... "}
	
	//Extension controls
	SetVariable BackgroundStart,pos={50,330},size={300,18},proc=IR1B_RecalcBackgroundExt,title="Start Bckg extrapolation at Q:   "
	SetVariable BackgroundStart,limits={0,100,0},noedit=1,value= root:Packages:Irena_desmearing:BckgStartQ
	SVAR BackgroundFunction=root:Packages:Irena_desmearing:BackgroundFunction
	PopupMenu BackgroundFnct,pos={50,380},size={178,21},proc=IR1B_ChangeBkgFunction,title="background function :   "
	PopupMenu BackgroundFnct,mode=1,value= "flat;linear;PowerLaw w flat;power law;Porod;polynom2;polynom3",popvalue=BackgroundFunction

//	CheckBox DesmearMaskNegatives pos={100,410}, size={200,15},title="Mask Negative values", proc=IR1B_InputPanelCheckboxProc
//	CheckBox DesmearMaskNegatives variable=root:Packages:Irena_desmearing:DesmearMaskNegatives,mode=1
//	CheckBox DesmearMaskNegatives help={"Check to mask negative values in intensity. Values left in for further processing."}
//	CheckBox DesmearRemoveNegatives pos={100,430}, size={200,15},title="Remove Negative values", proc=IR1B_InputPanelCheckboxProc
//	CheckBox DesmearRemoveNegatives variable=root:Packages:Irena_desmearing:DesmearRemoveNegatives,mode=1
//	CheckBox DesmearRemoveNegatives help={"Check to mask negative values in intensity. Values left in for further processing."}

	//desmearing controls
	Button DoOneIteration , pos={220, 285}, proc=IR1B_DesmearIterations,title="Do one iteration"
	Button DoOneIteration size={150,20},  help={"Does one iteration"}
	Button DoFiveIteration , pos={220, 310}, proc=IR1B_DesmearIterations,title="Do 5 iterations"
	Button DoFiveIteration size={150,20},  help={"Does 5 iterations"}
	Button DoNIterations , pos={220, 335}, proc=IR1B_DesmearIterations,title="Do N iterations"
	Button DoNIterations size={150,20},  help={"Does N number of iterations, set value below"}
	SetVariable NIterations size={120,25},title="N =", pos={220, 360}, help={"Number of iterations to be done on this sample"}
	SetVariable NIterations limits={0,Inf,1},value= root:Packages:Irena_desmearing:DesmearNIterationsTarget
	Button DoAutoIterations , pos={220, 385}, proc=IR1B_DesmearIterations,title="Do Automatically Iterations"
	Button DoAutoIterations size={150,20},  help={"Desmears until sum(abs(norm residuals))/numpnts < AveNormRes target (set below) "}
	SetVariable DesmearAutoTargChisq size={140,25},title="AveNormRes =", pos={220, 410}, help={"Target avearge normalized residual for Automatic method"}
	SetVariable DesmearAutoTargChisq limits={0,Inf,0.1},value= root:Packages:Irena_desmearing:DesmearAutoTargChisq

	SetVariable NumberOfIterations size={300,25},title="Number of iterations done:", pos={70, 435}, mode=0, frame=0, help={"number of iterations rdone on this sample"}
	SetVariable NumberOfIterations limits={-Inf,Inf,0},value= root:Packages:Irena_desmearing:NumberOfIterations, noedit=1
	CheckBox DesmearFastOnly,pos={20,300},size={141,14},variable=root:Packages:Irena_desmearing:DesmearFastOnly,title="Fast method?"
	CheckBox DesmearFastOnly, help={"Fast correction method, works well for USAXS. May be noisy..."}, mode=1,proc=IR1B_InputPanelCheckboxProc
	CheckBox DesmearSlowOnly,pos={20,320},size={141,14},variable=root:Packages:Irena_desmearing:DesmearSlowOnly,title="Slow method?"
	CheckBox DesmearSlowOnly, help={"Slow correction method, very, very slow at small Qs..."}, mode=1,proc=IR1B_InputPanelCheckboxProc
	CheckBox DesmearCombo,pos={20,340},size={141,14},variable=root:Packages:Irena_desmearing:DesmearCombo,title="Combination fast/slow?"
	CheckBox DesmearCombo, help={"Combination of correction methods, strongly suggested"}, mode=1,proc=IR1B_InputPanelCheckboxProc
	SetVariable DesmearSwitchOverVal,pos={20,360},size={150,18},title="Switch to slow at = ", variable=root:Packages:Irena_desmearing:DesmearSwitchOverVal
	SetVariable DesmearSwitchOverVal limits={0,Inf,1}, help={"Value when Fast/slow methods switch. Suggested value between 1 and 6, default 2"}
	CheckBox DesmearDampen,pos={20,380},size={141,14},variable=root:Packages:Irena_desmearing:DesmearDampen,title="Dampen?"
	CheckBox DesmearDampen, help={"Fast method but stops desmearing for points which do not need it."}, mode=1,proc=IR1B_InputPanelCheckboxProc


	//save data
	PopupMenu SelectNewDataFolder,pos={5,470},size={180,21},proc=IR1B_PanelPopupControl,title="Pick existing folder:", help={"Select existing folder to store new SAS data in"}
	PopupMenu SelectNewDataFolder,mode=1,popvalue="---",value= #"\"---;\"+IR1B_GenStringOfFolders(0, 0)"
	SetVariable ExportDataFolderName size={380,30},title="Save data to:", pos={5, 500}, help={"Folder to store new SAS data in. If does not exist, it will be created."}
	SetVariable ExportDataFolderName limits={-Inf,Inf,0},value= root:Packages:Irena_desmearing:ExportDataFolderName
	SetVariable ExportQWaveName size={380,30},title="Q wave name:          ", pos={5, 525}, help={"Q name for desmeared data"}
	SetVariable ExportQWaveName limits={-Inf,Inf,0},value= root:Packages:Irena_desmearing:ExportQWaveName
	SetVariable ExportIntensityWaveName size={380,30},title="Intensity wave name:", pos={5, 550}, help={"In tensity name for desmeared data"}
	SetVariable ExportIntensityWaveName limits={-Inf,Inf,0},value= root:Packages:Irena_desmearing:ExportIntensityWaveName
	SetVariable ExportErrorWaveName size={380,30},title="Error wave name:      ", pos={5, 575}, help={"Error name for desmeared data"}
	SetVariable ExportErrorWaveName limits={-Inf,Inf,0},value= root:Packages:Irena_desmearing:ExportErrorWaveName

	Button SaveDataBtn, pos={100, 610}, size={100,25},  proc=IR1B_InputPanelButtonProc,title="Save data", help={"Push to save the desmeared data."}

	 IR1B_TabPanelControl("name",0)
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************


Function IR1B_Trim(ctrlName) : ButtonControl
	String ctrlName
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing:
	Wave OrgIntwave=root:Packages:Irena_desmearing:OrgIntwave
	Wave OrgQwave=root:Packages:Irena_desmearing:OrgQwave
	Wave OrgEwave=root:Packages:Irena_desmearing:OrgEwave
	Wave OrgdQwave=root:Packages:Irena_desmearing:OrgdQwave
	
	KillWaves/Z SmoothIntwave, SmoothQwave, SmoothEwave, SmoothdQwave
	if (strlen(CsrWave(B))==0 || strlen(CsrWave(A))==0)
		DoAlert 0, "One of the cursors is not in the graph. Position both cursors and select the area which you want to desmear in the graph first before triming."
	else
		variable AP=pcsr (A)
		variable BP=pcsr (B)
		deletePoints 0, AP, OrgIntwave, OrgQwave, OrgEwave, OrgdQwave
		variable newLength=numpnts(OrgIntwave)
		deletePoints (BP-AP+1), (newLength), OrgIntwave, OrgQwave, OrgEwave, OrgdQwave
		cursor/P A, OrgIntwave, 0
		cursor/P B, OrgIntwave, (numpnts(OrgIntwave)-1)
	endif
	setDataFolder OldDf
End
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************


Function/T IR1B_ListOfWaves(WaveTp)
	string WaveTp
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing:

	string result, tempresult, dataType, tempStringQ, tempStringR, tempStringS
	SVAR FldrNm=root:Packages:Irena_desmearing:DataFolderName
	NVAR Indra2Dta=root:Packages:Irena_desmearing:UseIndra2Data
	NVAR QRSdata=root:Packages:Irena_desmearing:UseQRSData
	variable i,j
		
	if (Indra2Dta)
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
		if(stringMatch(result,"*"+WaveTp+"*"))
			tempresult=""
			for (i=0;i<ItemsInList(result);i+=1)
				if (stringMatch(StringFromList(i,result),"*"+WaveTp+"*"))
					tempresult+=StringFromList(i,result)+";"
				endif
			endfor
			result=tempresult
		endif
	elseif(QRSData) 
		result=""			//IN2G_CreateListOfItemsInFolder(FldrNm,2)
		tempStringQ=IR2P_ListOfWavesOfType("q",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		tempStringR=IR2P_ListOfWavesOfType("r",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		tempStringS=IR2P_ListOfWavesOfType("s",IN2G_CreateListOfItemsInFolder(FldrNm,2))
		
		if (cmpstr(WaveTp,"SMR_Int")==0)
//			dataType="r"
			For (j=0;j<ItemsInList(tempStringR);j+=1)
				if (stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringR)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringR)[1,inf]+";*"))
					result+=StringFromList(j,tempStringR)+";"
				endif
			endfor
		elseif(cmpstr(WaveTp,"SMR_Qvec")==0)
//			dataType="q"
			For (j=0;j<ItemsInList(tempStringQ);j+=1)
				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringQ)[1,inf]+";*"))
					result+=StringFromList(j,tempStringQ)+";"
				endif
			endfor
		else
//			dataType="s"			
			For (j=0;j<ItemsInList(tempStringS);j+=1)
				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringS)[1,inf]+";*") && stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringS)[1,inf]+";*"))
					result+=StringFromList(j,tempStringS)+";"
				endif
			endfor
		endif
	else
		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
	endif
	
	setDataFolder OldDf
	return result
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IR1B_Initialize()
	//function, which creates the folder for SAS modeling and creates the strings and variables
	
	string oldDf=GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:Irena_desmearing
	
	string ListOfWavesToKill
	string ListOfVariables
	string ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	ListOfWavesToKill="OrgIntwave;OrgQwave;OrgEwave;ColorWave;ExtrapIntwave;ExtrapQwave;ExtrapErrWave;W_coef;fit_ExtrapIntwave;W_sigma;W_ParamConfidenceInterval;E_wave;CTextWave;DownErr;UpErr;NormalizedError;SmFitIntensity;FitIntensity;Qvector;DsmError;SmErrors;"
	
	ListOfVariables="UseIndra2Data;UseQRSdata;SlitLength;SlitLengthL;SlitWidth;SlitWidthL;"
	ListOfVariables+="BckgStartQ;numOfPoints;NumberOfIterations;SmoothSMRData;SmoothDSMData;"
	ListOfVariables+="SmoothingParameterSMR;SmoothingParameterDSM;NormalizedChiSquareSMR;NormalizedChiSquareDSM;"
	ListOfVariables+="DesmearFastOnly;DesmearSlowOnly;DesmearCombo;DesmearSwitchOverVal;DesmearRemoveNegatives;DesmearMaskNegatives;"
	ListOfVariables+="DesmearDampen;DesmearAutomaticaly;DesmearAutoTargChisq;DesmearNIterationsTarget;"

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;BackgroundFunction;LastSample;"
	ListOfStrings+="ExportDataFolderName;ExportIntensityWaveName;ExportQWavename;ExportErrorWaveName;BackgroundFunction;ExportdQWaveName;"
	
	variable i
	for(i=0;i<itemsInList(ListOfWavesToKill);i+=1)	
		Wave/Z KillMe=$(StringFromList(i,ListOfWavesToKill))
		KillWaves/Z KillMe
	endfor		
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
	
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	//set starting numbers
	SVAR LastSample
	//LastSample=""
	NVAR BckgStartQ
	if (BckgStartQ==0)
		BckgStartQ = 0.01
	endif
	SVAR BackgroundFunction
	if (strlen(BackgroundFunction)==0)
		BackgroundFunction = "Flat"
	endif
	NVAR DesmearAutoTargChisq
	if(DesmearAutoTargChisq==0)
		DesmearAutoTargChisq=0.5
	endif
	
	NVAR DesmearNIterationsTarget
	if(DesmearNIterationsTarget==0)
		DesmearNIterationsTarget=10
	endif
	NVAR DesmearRemoveNegatives
	NVAR DesmearMaskNegatives
	if((DesmearRemoveNegatives + DesmearMaskNegatives) !=1)
		DesmearMaskNegatives=1
		DesmearRemoveNegatives=0
	endif
	NVAR DesmearDampen
	NVAR DesmearFastOnly
	NVAR DesmearSlowOnly
	NVAR DesmearCombo
	NVAR DesmearSwitchOverVal
	if(DesmearFastOnly==0 && DesmearSlowOnly==0 && DesmearCombo==0 && DesmearDampen==0)
		DesmearFastOnly=1
	endif
	if(DesmearFastOnly + DesmearSlowOnly+DesmearDampen+ DesmearCombo>1)
		DesmearFastOnly=1
		DesmearSlowOnly=0
		DesmearCombo=0
		DesmearDampen=0
	endif
	if(DesmearSwitchOverVal==0)
		DesmearSwitchOverVal=2
	endif
	setDataFolder OldDf	
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//Function IR1B_PowerLaw(w,x) : FitFunc
//	Wave w
//	Variable x
//
//	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
//	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
//	//CurveFitDialog/ Equation:
//	//CurveFitDialog/ f(x) = w_0*x^w_1
//	//CurveFitDialog/ End of Equation
//	//CurveFitDialog/ Independent Variables 1
//	//CurveFitDialog/ x
//	//CurveFitDialog/ Coefficients 2
//	//CurveFitDialog/ w[0] = w_0
//	//CurveFitDialog/ w[1] = w_1
//
//	return w[0]*x^w[1]
//End
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IR1B_Porod(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = c1+c2*(x^(-4))
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = c1
	//CurveFitDialog/ w[1] = c2

	return w[0]+w[1]*(x^(-4))
End
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IR1B_FlatFnct(w,x) : FitFunc
	wave w
	variable x
	
	return w[0]
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//
//
//Function IR1B_FreePorod(w,x) : FitFunc
//	Wave w
//	Variable x
//
//	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
//	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
//	//CurveFitDialog/ Equation:
//	//CurveFitDialog/ f(x) = c1+c2*(x^pwr)
//	//CurveFitDialog/ End of Equation
//	//CurveFitDialog/ Independent Variables 1
//	//CurveFitDialog/ x
//	//CurveFitDialog/ Coefficients 3
//	//CurveFitDialog/ w[0] = c1
//	//CurveFitDialog/ w[1] = c2
//	//CurveFitDialog/ w[2] = pwr
//
//	return w[0]+w[1]/(x^w[2])
//End
//
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IR1B_DesmearIterations(ctrlName) : ButtonControl
	String ctrlName

	variable i, tickStart
	tickStart=ticks
	if (cmpstr(ctrlName,"DoOneIteration")==0)
		IR1B_OneDesmearIteration()
	endif
	
	if (cmpstr(ctrlName,"DoFiveIteration")==0)
		For (i=0;i<5;i+=1)
			IR1B_OneDesmearIteration()
		endfor
	endif
	if (cmpstr(ctrlName,"DoNIterations")==0)
		NVAR DesmearNIterationsTarget=root:Packages:Irena_desmearing:DesmearNIterationsTarget
		For (i=0;i<DesmearNIterationsTarget;i+=1)
			IR1B_OneDesmearIteration()
		endfor
	endif
	if (cmpstr(ctrlName,"DoAutoIterations")==0)
		variable endme
		variable oldendme, difff
		NVAR DesmearAutoTargChisq=root:Packages:Irena_desmearing:DesmearAutoTargChisq
		Do 
				IR1B_OneDesmearIteration()
				Wave NormalizedError=root:Packages:Irena_desmearing:NormalizedError
				Duplicate NormalizedError, absNormalizedError
				absNormalizedError=abs(NormalizedError)
				IN2G_RemNaNsFromAWave(absNormalizedError)
				endme = sum(absNormalizedError)/numpnts(absNormalizedError)
				KillWaves/Z absNormalizedError
				difff=1 - oldendme/endme
				oldendme=endme
		while (endme>DesmearAutoTargChisq && abs(difff)>0.01)	
	endif
	
	if ((ticks-TickStart)/60 > 5)			//thsi is going to beep for longer desemaring steps, set now to 5 sec per step
		beep
	endif
	TextBox/W=DesmearingProcess/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	

end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IR1B_OneDesmearIteration()
	String ctrlName
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing:

	SVAR BackgroundFunction    = root:Packages:Irena_desmearing:BackgroundFunction
	NVAR slitLength                    = root:Packages:Irena_desmearing:slitLength
	NVAR slitLengthL                   = root:Packages:Irena_desmearing:slitLengthL
	NVAR slitwidth                   = root:Packages:Irena_desmearing:slitwidth
	NVAR slitwidthL                   = root:Packages:Irena_desmearing:slitwidthL
	
	NVAR BckgStartQ                 = root:Packages:Irena_desmearing:BckgStartQ
	NVAR numOfPoints               = root:Packages:Irena_desmearing:numOfPoints
	WAVE DesmearedIntWave     		= root:Packages:Irena_desmearing:DesmearedIntWave
	WAVE DesmearedQWave     			 = root:Packages:Irena_desmearing:DesmearedQWave
	WAVE OrgIntwave                 = root:Packages:Irena_desmearing:SmoothIntwave
	//Wave ExtrapErrWave                  = root:Packages:Irena_desmearing:ExtrapErrWave
	Wave ExtrapErrWave                  = root:Packages:Irena_desmearing:SmoothEwave
	WAVE SmFitIntensity            = root:Packages:Irena_desmearing:SmFitIntensity
	WAVE NormalizedError          = root:Packages:Irena_desmearing:NormalizedError
	WAVE SmErrors                    = root:Packages:Irena_desmearing:SmErrors
	NVAR NumberOfIterations         = root:Packages:Irena_desmearing:NumberOfIterations

	NVAR DesmearFastOnly 		= root:Packages:Irena_desmearing:DesmearFastOnly
	NVAR DesmearSlowOnly 		= root:Packages:Irena_desmearing:DesmearSlowOnly
	NVAR DesmearCombo 		= root:Packages:Irena_desmearing:DesmearCombo
	NVAR DesmearSwitchOverVal 	= root:Packages:Irena_desmearing:DesmearSwitchOverVal
	NVAR DesmearDampen		= root:Packages:Irena_desmearing:DesmearDampen
//	SVAR DesmearParametersW

	//	numOfPoints=numpnts(FitIntensity)
	
		IR1B_ExtendData(DesmearedIntWave, DesmearedQWave, ExtrapErrWave, slitLength, BckgStartQ, BackgroundFunction,1) 			//extend data to 2xnumOfPoints to Qmax+2.1xSlitLength
		if(slitlength>0)
			if(SlitLengthL<1e-9)
				IR1B_SmearData(DesmearedIntWave, DesmearedQWave, slitLength, SmFitIntensity)						//smear the data, output is SmFitIntensity
			else
				IR1B_SmearDataTrapeziod(DesmearedIntWave, DesmearedQWave, slitLength,slitLengthL, SmFitIntensity)	
			endif
		endif
		if(slitwidth>0)
			if(slitwidthL<1e-9)
				IR1B_SmearData(DesmearedIntWave, DesmearedQWave, slitwidth, SmFitIntensity)						//smear the data, output is SmFitIntensity
			else
				IR1B_SmearDataTrapeziod(DesmearedIntWave, DesmearedQWave, slitwidth,slitwidthL, SmFitIntensity)	
			endif
		endif
		Redimension/N=(numOfPoints) SmFitIntensity, DesmearedIntWave, DesmearedQWave, NormalizedError		//cut the data back to original length (Qmax, numOfPoints)
		
		NormalizedError=(OrgIntwave-SmFitIntensity)/SmErrors			//NormalizedError (input-my Smeared data)/input errors
		Wave FitIntensity
		duplicate/O FitIntensity, FastFitIntensity, SlowFitIntensity
		//fast convergence
		FastFitIntensity=DesmearedIntWave*(OrgIntwave/SmFitIntensity)								//Here we apply the correction on input data, FitIntensity is our best estimate for desmeared data
		//slow convergence
		SlowFitIntensity=DesmearedIntWave+ (OrgIntwave-SmFitIntensity)								//Here we apply the correction on input data, FitIntensity is our best estimate for desmeared data
		
	variable i
	if(DesmearFastOnly)
		DesmearedIntWave = FastFitIntensity
	elseif(DesmearSlowOnly)
		DesmearedIntWave = SlowFitIntensity
	elseif(DesmearDampen)
		For(i=0;i<(numpnts(FitIntensity));i+=1)
			if (abs(NormalizedError[i])>0.5)
				DesmearedIntWave[i]=FastFitIntensity[i]
			else
				DesmearedIntWave[i]=DesmearedIntWave[i]
			endif	
		endfor
	else
		For(i=0;i<(numpnts(FitIntensity));i+=1)
			if (abs(NormalizedError[i])>DesmearSwitchOverVal)
				DesmearedIntWave[i]=FastFitIntensity[i]
			else
				DesmearedIntWave[i]=SlowFitIntensity[i]
			endif	
		endfor
	endif	
	NumberOfIterations+=1
	//remove the normalized error extremes
	wavestats/Q NormalizedError
	NormalizedError[x2pnt(NormalizedError,V_minLoc)] = Nan
	NormalizedError[x2pnt(NormalizedError,V_maxLoc)] = Nan
	Duplicate/O DesmearedIntWave, DesmearedEWave
	DesmearedEWave=0
	IR1B_GetErrors(SmErrors, OrgIntwave, DesmearedIntWave, DesmearedEWave, DesmearedQWave)			//this routine gets the errors
	DoUpdate
	setDataFolder OldDf
End

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*****************************This function smears data***********************
Function IR1B_SmearData(Int_to_smear, Q_vec_sm, slitLength, Smeared_int)
	wave Int_to_smear, Q_vec_sm, Smeared_int
	variable slitLength
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:
	NewDataFolder/O/S Irena_desmearing
	//modified 5/14/2010 to manage cases when slit length is higher than last Q point. Basically, we need to manage extending the data automatically for use with other tools then desmearing. 
	//fixes for interpolate function behavior when asking for data outside the range of x values...
	variable oldNumPnts=numpnts(Q_vec_sm)
	//modified 2/28/2017 - with Fly scans and merged data having lot more points, this is getting to be slow. Keep max number of new points to 300
	variable newNumPoints
	if(oldNumPnts<300)
		newNumPoints = 2*oldNumPnts
	else
		newNumPoints = oldNumPnts+300
	endif
	Duplicate/O/Free Int_to_smear, tempInt_to_smear
	Redimension /N=(newNumPoints) tempInt_to_smear		//increase the points here.
	Duplicate/O/Free Q_vec_sm, tempQ_vec_sm
	Redimension/N=(newNumPoints) tempQ_vec_sm
	tempQ_vec_sm[oldNumPnts, ] =tempQ_vec_sm[oldNumPnts-1] +20* tempQ_vec_sm[p-oldNumPnts]			//creates extension of number of points up to 20*original length
	tempInt_to_smear[oldNumPnts, ]  = tempInt_to_smear[oldNumPnts-1] * (1-(tempQ_vec_sm[p]  - tempQ_vec_sm[oldNumPnts])/(20*tempQ_vec_sm[oldNumPnts-1]))//extend the data by simple fixed value... 
	
	Make/D/Free/N=(oldNumPnts) Smear_Q, Smear_Int							
	//Q's in L spacing and intensitites in the l's will go to Smear_Int (intensity distribution in the slit, changes for each point)

	variable DataLengths=numpnts(Q_vec_sm)

	Smear_Q=2*slitLength*(Q_vec_sm[p]-Q_vec_sm[0])/(Q_vec_sm[DataLengths-1]-Q_vec_sm[0])		//create distribution of points in the l's which mimics the original distribution of points
	//the 2* added later, because without it I did not  cover the whole slit length range... 
	variable i=0
	DataLengths=numpnts(Smeared_int)
	
	//		For(i=0;i<DataLengths;i+=1) 
	//			multithread Smear_Int=interp(sqrt((Q_vec_sm[i])^2+(Smear_Q[p])^2), tempQ_vec_sm, tempInt_to_smear)		//put the distribution of intensities in the slit for each point 
	//			Smeared_int[i]=areaXY(Smear_Q, Smear_Int, 0, slitLength) 							//integrate the intensity over the slit 
	//		endfor
	//this is about 4x faster
	MatrixOp/FREE Q_vec_sm2=powR(Q_vec_sm,2)
	MatrixOp/FREE Smear_Q2=powR(Smear_Q,2)
	MultiThread Smeared_int = IR1B_SmearDataFastFunc(Q_vec_sm2[p], Smear_Q,Smear_Q2, tempQ_vec_sm, tempInt_to_smear, SlitLength)

	Smeared_int*= 1 / slitLength															//normalize
	
	//KillWaves/Z Smear_Int, Smear_Q,tempQ_vec_sm, tempInt_to_smear							//cleanup temp waves
	setDataFolder OldDf
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Threadsafe function IR1B_SmearDataFastFunc(Q_vec_sm2, Smear_Q,Smear_Q2, tempQ_vec_sm, tempInt_to_smear, SlitLength)
			variable Q_vec_sm2, SlitLength
			wave Smear_Q, Smear_Q2, tempQ_vec_sm, tempInt_to_smear	
			Duplicate/Free Smear_Q, Smear_Int
			//Smear_Int=interp(sqrt( Q_vec_sm2 +(Smear_Q2[p])), tempQ_vec_sm, tempInt_to_smear)		//put the distribution of intensities in the slit for each point 
			//this is using Interpolate2, seems slightly faster than above line alone... 
			Duplicate/Free Smear_Q, InterSmear_Q
			InterSmear_Q = sqrt( Q_vec_sm2 +(Smear_Q2[p]))
			//surprisingly, below code is tiny bit slower that the two lines above... 
			//MatrixOp/FREE InterSmear_Q=sqrt(Smear_Q2 + Q_vec_sm2)	
			Interpolate2/I=3/T=1/X=InterSmear_Q /Y=Smear_Int tempQ_vec_sm, tempInt_to_smear
			return areaXY(Smear_Q, Smear_Int, 0, slitLength) 							//integrate the intensity over the slit 
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*****************************This function smears data***********************
Function IR1B_SmearDataTrapeziod(Int_to_smear, Q_vec_sm, slitLength, slitLegthL, Smeared_int)
	wave Int_to_smear, Q_vec_sm, Smeared_int
	variable slitLength, slitLegthL
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:
	NewDataFolder/O/S Irena_desmearing
	
	Make/D/O/N=(2*numpnts(Q_vec_sm)) Smear_Q, Smear_Int, SmearProfile							
		//Q's in L spacing and intensitites in the l's will go to Smear_Int (intensity distribution in the slit, changes for each point)

	variable DataLengths=numpnts(Q_vec_sm)
	
	
	Smear_Q=1.15*(slitLength+slitLegthL/2)*(Q_vec_sm[2*p]-Q_vec_sm[0])/(Q_vec_sm[DataLengths-1]-Q_vec_sm[0])		//create distribution of points in the l's which mimics the original distribution of points
	//the 1.1* added later, because without it I did not  cover the whole slit length range... 
	variable i=0
	
	DataLengths=numpnts(Smeared_int)
	//create slit profile here...
	For(i=0;i<DataLengths;i+=1) 
		if(Smear_Q[i]<(SlitLength-slitLegthL))
			SmearProfile[i]=1
		elseif(Smear_Q[i]<=(SlitLength+slitLegthL))
			SmearProfile[i]=1-(((Smear_Q[i]-(SlitLength-slitLegthL))/slitLegthL)/2)
		else
			SmearProfile[i]=0
		endif
	endfor
	variable scaleBy=areaXY(Smear_Q, SmearProfile, 0, slitLength+slitLegthL/2)
	For(i=0;i<DataLengths;i+=1) 
		Smear_Int=interp(sqrt((Q_vec_sm[i])^2+(Smear_Q[p])^2), Q_vec_sm, Int_to_smear)		//put the distribution of intensities in the slit for each point 
		//here we form this by slit trapeziodal format
		Smear_Int = Smear_Int*SmearProfile
		Smeared_int[i]=areaXY(Smear_Q, Smear_Int, 0, slitLength+slitLegthL/2) 							//integrate the intensity over the slit 
	endfor
//print scaleBy
	Smeared_int*= 1 / scaleBy															//normalize
	
	KillWaves/Z Smear_Int, Smear_Q														//cleanup temp waves
	setDataFolder OldDf
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************


Function IR1B_DoDesmearing()
	// this is continuation of dismearing procedure1, Here we return after trimming the data and checking the background extrapolation
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing

	NVAR BckgStartQ = root:Packages:Irena_desmearing:BckgStartQ
	NVAR numOfPoints=root:Packages:Irena_desmearing:numOfPoints
	SVAR BackgroundFunction = root:Packages:Irena_desmearing:BackgroundFunction
	Wave/Z OrgIntwave=root:Packages:Irena_desmearing:SmoothIntwave
	Wave/Z OrgQwave=root:Packages:Irena_desmearing:SmoothQwave
	Wave/Z OrgEwave=root:Packages:Irena_desmearing:SmoothEwave
	Wave/Z OrgdQwave=root:Packages:Irena_desmearing:SmoothdQwave
	if(!WaveExists(OrgIntWave) || !WaveExists(OrgQwave) || !WaveExists(OrgEWave))
		NVAR SmoothSMRData=root:Packages:Irena_desmearing:SmoothSMRData
		NVAR SmoothingParameterSMR=root:Packages:Irena_desmearing:SmoothingParameterSMR
		Wave OrgIntwave=root:Packages:Irena_desmearing:OrgIntwave
		Wave OrgQwave=root:Packages:Irena_desmearing:OrgQwave
		Wave OrgEwave=root:Packages:Irena_desmearing:OrgEwave
		Wave/Z OrgdQwave=root:Packages:Irena_desmearing:OrgdQwave
		IN2G_ReplaceNegValsByNaNWaves(OrgIntWave,OrgQwave,OrgEwave)			//here we remove negative values by setting them to NaNs
		IN2G_RemoveNaNsFrom4Waves(OrgIntWave,OrgQwave,OrgEwave,OrgdQwave)			//and here we remove NaNs all together
		if(SmoothSMRData)
			IR1B_SliderSmoothSMRData(SmoothingParameterSMR)
		else
			Duplicate/O OrgIntwave, SmoothIntwave
			Duplicate/O OrgQwave, SmoothQwave
			Duplicate/O OrgEwave, SmoothEwave
			Duplicate/O OrgdQwave, SmoothdQwave
		endif
	endif
	Wave/Z OrgIntwave=root:Packages:Irena_desmearing:SmoothIntwave
	Wave/Z OrgQwave=root:Packages:Irena_desmearing:SmoothQwave
	Wave/Z OrgEwave=root:Packages:Irena_desmearing:SmoothEwave
	Wave/Z OrgdQwave=root:Packages:Irena_desmearing:SmoothdQwave
	Wave/Z fit_ExtrapIntWave=root:Packages:Irena_desmearing:fit_ExtrapIntWave
	Wave/Z ColorWave=root:Packages:Irena_desmearing:ColorWave
	IN2G_ReplaceNegValsByNaNWaves(OrgIntWave,OrgQwave,OrgEwave)		//here we remove negative values by setting them to NaNs
	IN2G_RemoveNaNsFrom4Waves(OrgIntWave,OrgQwave,OrgEwave,OrgdQwave)			//and here we remove NaNs all together
	numOfPoints = numpnts(OrgIntwave)
	
	NVAR SlitLength=root:Packages:Irena_desmearing:SlitLength
	NVAR NumberOfIterations=root:Packages:Irena_desmearing:NumberOfIterations
//	SVAR DesmearParametersW
	
	
	Duplicate/O OrgIntwave, DesmearedIntWave, FitIntensity, SmFitIntensity, NormalizedError, UpErr, DownErr		//creates new waves to work on
	Duplicate/O OrgQwave, DesmearedQWave
	Duplicate/O OrgdQwave, DesmeareddQWave
	Duplicate/O OrgEwave, SmErrors, DesmearedEWave	

	UpErr=1
	DownErr=-1
	NormalizedError=0
					
	string UserSampleName=StringByKey("UserSampleName", note(OrgIntWave) , "=", ";")
	SVAR BackgroundFunction=root:Packages:Irena_desmearing:BackgroundFunction	
			
			//***************graph
				Display/K=1 /W=(300,60,IN2G_GetGraphWidthHeight("width"),IN2G_GetGraphWidthHeight("height"))/N=DesmearingProcess OrgIntWave vs OrgQwave as "Intensity vs Q plot"
				AutoPositionWindow/M=0/R=IR1B_DesmearingControlPanel  DesmearingProcess	
				ModifyGraph mode=4,	margin(top)=100, mirror=1, minor=1
				showinfo										//shows info
				ShowTools/A										//show tools
				ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
				Button KillThisWindow pos={10,10}, size={100,25},  title="Kill window", proc=IN2G_KillGraphsTablesEnd
				Button ResetWindow pos={10,40}, size={100,25},  title="Reset window", proc=IN2G_ResetGraph
				AppendToGraph DesmearedIntWave vs DesmearedQWave
				AppendToGraph /R UpErr vs DesmearedQWave 
				AppendToGraph /R DownErr vs DesmearedQWave 
				AppendToGraph /R NormalizedError vs DesmearedQWave 
				SVAR DataFolderName=root:Packages:Irena_desmearing:DataFolderName
				SVAR IntensityWaveName=root:Packages:Irena_desmearing:IntensityWaveName
				TextBox/W=DesmearingProcess/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
				TextBox/W=DesmearingProcess/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
				ModifyGraph mode=3
				ModifyGraph log=1, log(right)=0
				Label left "Intensity"
				Label bottom "Q"	
				if(WaveExists(fit_ExtrapIntWave))
					AppendToGraph fit_ExtrapIntWave
					ModifyGraph mode(fit_ExtrapIntwave)=0,lstyle(fit_ExtrapIntwave)=3
					ModifyGraph rgb(fit_ExtrapIntwave)=(0,15872,65280)
					ModifyGraph lsize(fit_ExtrapIntwave)=2
				endif
				ModifyGraph marker(NormalizedError)=8,mrkThick(NormalizedError)=0.1;
				ModifyGraph lstyle(UpErr)=3,rgb(UpErr)=(0,0,0),lstyle(DownErr)=3
				ModifyGraph rgb(DownErr)=(0,0,0),rgb(SmoothIntwave)=(0,8704,13056)
				ModifyGraph rgb(NormalizedError)=(0,0,0)
				ModifyGraph zero(right)=3
				ModifyGraph mode(UpErr)=0, mode(DownErr)=0
				SetAxis/A/E=2 right
				Label right "Normalized residuals"	
				if(WaveExists(ColorWave))
					ModifyGraph zColor(DesmearedIntWave)={ColorWave,0,2,Rainbow}
				endif
				Legend/N=text0/J/F=0/A=LB/B=1 "\\s(SmoothIntWave) Smeared data\r\\s(DesmearedIntWave) Current desmeared fit"
				AppendText "\\s(NormalizedError) Standardized residual\r"
				AppendText "User sample name:  "+UserSampleName
				AppendText "Used extrapolation function:  "+BackgroundFunction
				AppendText "Extrapolation starts at Q =  "+num2str(BckgStartQ)
				ResumeUpdate
				ModifyGraph width=0, height=0		
				IN2G_AutoAlignPanelAndGraph()
				//***************graph end	
	setDataFolder OldDf
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IR1B_CheckTheBackgroundExtns()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing

	NVAR BckgStartQ = root:Packages:Irena_desmearing:BckgStartQ
	NVAR numOfPoints=root:Packages:Irena_desmearing:numOfPoints
	SVAR BackgroundFunction = root:Packages:Irena_desmearing:BackgroundFunction

	Wave/Z OrgIntwave=root:Packages:Irena_desmearing:SmoothIntwave
	Wave/Z OrgQwave=root:Packages:Irena_desmearing:SmoothQwave
	Wave/Z OrgEwave=root:Packages:Irena_desmearing:SmoothEwave
	Wave/Z OrgdQwave=root:Packages:Irena_desmearing:SmoothdQwave

	if(!WaveExists(OrgIntwave) || !WaveExists(OrgQwave) || !WaveExists(OrgEwave))
		NVAR SmoothSMRData=root:Packages:Irena_desmearing:SmoothSMRData
		NVAR SmoothingParameterSMR=root:Packages:Irena_desmearing:SmoothingParameterSMR
		Wave OrgIntwave=root:Packages:Irena_desmearing:OrgIntwave
		Wave OrgQwave=root:Packages:Irena_desmearing:OrgQwave
		Wave OrgEwave=root:Packages:Irena_desmearing:OrgEwave
		Wave OrgdQwave=root:Packages:Irena_desmearing:OrgdQwave
		IN2G_ReplaceNegValsByNaNWaves(OrgIntWave,OrgQwave,OrgEwave)		//here we remove negative values by setting them to NaNs
		IN2G_RemoveNaNsFrom4Waves(OrgIntWave,OrgQwave,OrgEwave,OrgdQwave)			//and here we remove NaNs all together
		if(SmoothSMRData)
			IR1B_SliderSmoothSMRData(SmoothingParameterSMR)
		else
			Duplicate/O OrgIntwave, SmoothIntwave
			Duplicate/O OrgQwave, SmoothQwave
			Duplicate/O OrgEwave, SmoothEwave
			Duplicate/O OrgdQwave, SmoothdQwave
		endif
	endif
	Wave/Z OrgIntwave=root:Packages:Irena_desmearing:SmoothIntwave
	Wave/Z OrgQwave=root:Packages:Irena_desmearing:SmoothQwave
	Wave/Z OrgEwave=root:Packages:Irena_desmearing:SmoothEwave
	Wave/Z OrgdQwave=root:Packages:Irena_desmearing:SmoothdQwave
	
	IN2G_ReplaceNegValsByNaNWaves(OrgIntWave,OrgQwave,OrgEwave)		//here we remove negative values by setting them to NaNs
	IN2G_RemoveNaNsFrom4Waves(OrgIntWave,OrgQwave,OrgEwave,OrgdQwave)			//and here we remove NaNs all together
	numOfPoints = numpnts(OrgIntWave)
	
	NVAR SlitLength=root:Packages:Irena_desmearing:SlitLength

	Duplicate/O OrgIntwave, ExtrapIntwave, ColorWave
	Duplicate/O OrgQwave, ExtrapQwave
	Duplicate/O OrgEwave, ExtrapErrWave
	Duplicate/O OrgdQwave, ExtrapdQWave
	ColorWave=0				//make the colors to be one, this will change later...
//	numOfPoints=numpnts(OrgQwave)
	
	Display/K=1 /W=(300,60,IN2G_GetGraphWidthHeight("width"),IN2G_GetGraphWidthHeight("height"))/N=CheckTheBackgroundExtns ExtrapIntwave vs ExtrapQwave as "Check bckg functions sel."
	AutoPositionWindow/M=0/R=IR1B_DesmearingControlPanel  CheckTheBackgroundExtns	
	SetWindow CheckTheBackgroundExtns, hook(MyHook) = IR1B_CheckBckgExtHook	// Install window hook
	ModifyGraph mode=4,	margin(top)=100, mirror=1, minor=1
	ModifyGraph zColor(ExtrapIntwave)={ColorWave,0,2,Rainbow}
	showinfo												//shows info
	//ShowTools/A											//show tools
	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
	Button KillThisWindow pos={10,10}, size={100,25},  title="Kill window", proc=IN2G_KillGraphsTablesEnd
	Button ResetWindow pos={10,40}, size={100,25},  title="Reset window", proc=IN2G_ResetGraph
	SVAR DataFolderName=root:Packages:Irena_desmearing:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena_desmearing:IntensityWaveName
	TextBox/W=CheckTheBackgroundExtns/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=CheckTheBackgroundExtns/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	ModifyGraph mode=3
	ModifyGraph log=1
	Label left "Intensity"
	Label bottom "Q"
	ShowTools
	ResumeUpdate
	ModifyGraph width=0, height=0
	IN2G_AutoAlignPanelAndGraph()
	IR1B_SetCsrAToExtendData()				//position cursor
	redimension /N=(numofPoints) ExtrapIntwave, ExtrapQwave, ExtrapErrWave
	IR1B_ExtendData(ExtrapIntwave, ExtrapQwave, ExtrapErrWave, SlitLength, BckgStartQ, BackgroundFunction,0) 	//extend data to 2xnumOfPoints to Qmax+2.1xSlitLength

	setDataFolder OldDf
end	

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IR1B_CheckBckgExtHook(s)
	STRUCT WMWinHookStruct &s
	
//	Variable hookResult = 0	// 0 if we do not handle event, 1 if we handle it.

	switch(s.eventCode)
		case 7:					// Cursor moved
//			string/g root:Packages:Irena_desmearing:CsrMoveInfo
//			SVAR CsrMoveInfo=root:Packages:Irena_desmearing:CsrMoveInfo
//			CsrMoveInfo=info
			if(cmpstr(s.cursorName,"A")==0)
				Execute("IR1B_CursorMoved()")
			endif
			break
	endswitch

//	return hookResult	// If non-zero, we handled event and Igor will ignore it.
End

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IR1B_ChangeBkgFunction(ctrlname, popNum, popStr)  : PopupMenuControl 	
	string ctrlName
	variable popNum
	string popStr
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing

	SVAR BackgroundFunction=root:Packages:Irena_desmearing:BackgroundFunction
	BackgroundFunction=popStr
	WAVE ExtrapIntwave=root:Packages:Irena_desmearing:ExtrapIntwave
	WAVE ExtrapQwave=root:Packages:Irena_desmearing:ExtrapQwave
	Wave ExtrapErrWave=root:Packages:Irena_desmearing:ExtrapErrWave
	NVAR BckgStartQ=root:Packages:Irena_desmearing:BckgStartQ
	NVAR numOfPoints=root:Packages:Irena_desmearing:numOfPoints
	NVAR SlitLength=root:Packages:Irena_desmearing:SlitLength
	
	Redimension/N=(numOfPoints) ExtrapIntwave, ExtrapQwave, ExtrapErrWave
	IR1B_ExtendData(ExtrapIntwave, ExtrapQwave, ExtrapErrWave, SlitLength, BckgStartQ, BackgroundFunction,0)
	TextBox/W=CheckTheBackgroundExtns/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	setDataFolder OldDf
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IR1B_SetCsrAToExtendData()

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing:

	Wave ExtrapQwave=root:Packages:Irena_desmearing:ExtrapQwave
	NVAR Wlength=root:Packages:Irena_desmearing:numOfPoints
	NVAR BckgStart=root:Packages:Irena_desmearing:BckgStartQ

	if (BckgStart<ExtrapQwave[Wlength-6])
		Cursor /P /W=CheckTheBackgroundExtns A ExtrapIntwave BinarySearch(ExtrapQwave,BckgStart)
	else
		Cursor /P /W=CheckTheBackgroundExtns A ExtrapIntwave (Wlength-10)
		BckgStart=ExtrapQwave(Wlength-10)
	endif		
	setDataFolder OldDf
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IR1B_CursorMoved()
	
//	SVAR info=root:Packages:Irena_desmearing:CsrMoveInfo
	String oldDf=GetDataFolder(1)
	SetDataFolder root:Packages:Irena_desmearing:

	string info= csrinfo(A)
		String tName= StringByKey("TNAME", info)
		if( strlen(tName) )	// cursor still on
			//Result needs to be passed to the rest of the procedures
			//but before we need to check that the cursor has not moved on last 5 points
			Wave w= TraceNameToWaveRef("CheckTheBackgroundExtns", tName)
			Wave ExtrapIntWave
			Variable pointNum= NumberByKey("POINT",info)
			NVAR Wlength=root:Packages:Irena_desmearing:numOfPoints
			NVAR BckgStart=root:Packages:Irena_desmearing:BckgStartQ

			variable CurentBckgStart=hcsr(A)
			if (cmpstr(TNAME,"ExtrapIntwave")!=0)			//cursor is not on right wave
				Cursor /P /W=CheckTheBackgroundExtns A ExtrapIntwave BinarySearch(ExtrapIntWave, CurentBckgStart )
			endif
			
			pointNum = pcsr(A)		//update the cursor position
			
			if (pointNum>Wlength-6)			//cursor is not at least 5 points from end move further
				Cursor /P /W=CheckTheBackgroundExtns A ExtrapIntwave (Wlength-6)
			endif		
		
			BckgStart = hcsr(A)
		
			IR1B_RecalcBackgroundExt()
			TextBox/W=CheckTheBackgroundExtns/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	

		endif
//	endif	
	SetDataFolder oldDf
End
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IR1B_RecalcBackgroundExt()

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing:

	WAVE ExtrapIntwave=root:Packages:Irena_desmearing:ExtrapIntwave
	WAVE ExtrapQwave=root:Packages:Irena_desmearing:ExtrapQwave
	WAVE ExtrapErrWave=root:Packages:Irena_desmearing:ExtrapErrWave
	NVAR SlitLength=root:Packages:Irena_desmearing:SlitLength
	NVAR BckgStartQ=root:Packages:Irena_desmearing:BckgStartQ
	SVAR BackgroundFunction=root:Packages:Irena_desmearing:BackgroundFunction
	NVAR numOfPoints=root:Packages:Irena_desmearing:numOfPoints
	
	Redimension/N=(numOfPoints) ExtrapIntwave, ExtrapQwave, ExtrapErrWave
	IR1B_ExtendData(ExtrapIntwave, ExtrapQwave, ExtrapErrWave, SlitLength, BckgStartQ, BackgroundFunction,0)

	setDataFolder OldDf
End

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*************************************Extends the data using user specified parameters***************
Function IR1B_ExtendData(Int_wave, Q_vct, Err_wave, slitLength, Qstart, SelectedFunction, RecordFitParam) 
	wave Int_wave, Q_vct, Err_wave
	variable slitLength, Qstart, RecordFitParam		//RecordFitParam=1 when we should record fit parameters in logbook
	string SelectedFunction
	
	if (numtype(slitLength)!=0)
		abort "Slit length error"
	endif
	if (slitLength<0.0001 || slitLength>1)
		DoALert 0, "Weird value for Slit length, please check"
	endif
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing

	WAVE/Z ColorWave=root:Packages:Irena_desmearing:ColorWave
	if(!WaveExists(ColorWave))
		Duplicate/O Int_Wave, ColorWave
	endif
	WAVE/Z W_coef=W_coef
		if (WaveExists(W_coef)!=1)					
			make/N=2 W_coef
		endif
	W_coef=0		//reset for recording purposes...
	
	string ProblemsWithQ=""
	string ProblemWithFit=""
	string ProblemsWithInt=""
	variable DataLengths=numpnts(Q_vct)-1							//get number of original data points
	variable Qstep=((Q_vct(DataLengths)/Q_vct(DataLengths-1))-1)*Q_vct(DataLengths)
	variable ExtendByQ=sqrt(Q_vct(DataLengths)^2 + (1.5*slitLength)^2) - Q_vct(DataLengths)
	if (ExtendByQ<2.1*Qstep)
		ExtendByQ=2.1*Qstep
	endif
	variable NumNewPoints=floor(ExtendByQ/Qstep)	
	if (NumNewPoints<1)
		NumNewPoints=1
	endif	
	variable OriginalNumPnts=numpnts(Int_wave)
	if (NumNewPoints>OriginalNumPnts)
		NumNewPoints=OriginalNumPnts
	endif	
	variable newLength=numpnts(Q_vct)+NumNewPoints				//New length of waves
	variable FitFrom=binarySearch(Q_vct, Qstart)					//get at which point of Q start fitting for extension
	if (FitFrom<=0)		                 								//error in selection of Q fitting range
		FitFrom=DataLengths-10
		ProblemsWithQ="I did reset Fitting Q range for you..."
	endif
	//There seems to be bug, which prevents me from using /D in FuncFit and cursor control
	//therefore we will have to now handle this ourselves...
	//FIrst check if the wave exists
	Wave/Z fit_ExtrapIntwave
	if (!WaveExists(fit_ExtrapIntwave))
		Make/O/N=1000 fit_ExtrapIntwave
	endif
	//Now we need to set it's x scaling to the range of Q values we need to study
	SetScale/I x Q_vct[FitFrom],Q_vct[DataLengths-1],"", fit_ExtrapIntwave
	//reset the fit wave to constant value
	fit_ExtrapIntwave=Int_wave[DataLengths-1]
		
	Redimension /N=(newLength) Int_wave, Q_vct, Err_wave			//increase length of the two waves
	
	if(exists("ColorWave")==1)
		Redimension /N=(newLength) ColorWave
		ColorWave=0
		ColorWave[FitFrom,DataLengths-1]=1
		ColorWave[DataLengths+1, ]=2	
	endif
	
	variable i=0, ii=0	
	variable/g V_FitError=0					//this is way to avoid bombing due to numerical problems
	variable/g V_FitOptions=4				//this should suppress the window showing progress (4) & force robust fitting (6)
										//using robust fitting caused problems, do not use...
//	variable/g V_FitTol=0.00001				//and this should force better fit
	variable/g V_FitMaxIters=50
//	variable/g V_FitNumIters
	
	DoWindow CheckTheBackgroundExtns
	if (V_flag)
		RemoveFromGraph /W=CheckTheBackgroundExtns /Z Fit_ExtrapIntwave
	endif
	//***********here start different ways to extend the data

	if (cmpstr(SelectedFunction,"flat")==0)				//flat background, for some reason only way this works is 
	//lets setup parameters for FuncFit
		if (exists("W_coef")!=1)					//using my own function to fit. Crazy!!
			make/N=2 W_coef
		endif
		Redimension/D/N=1 W_coef
		Make/O/N=1 E_wave
		E_wave[0]=1e-6
		W_coef[0]=Int_wave[((FitFrom+DataLengths)/2)]			//here is starting guesses
		K0=W_coef[0]										//another way to get starting guess in
	 	V_FitError=0											//this is way to avoid bombing due to numerical problems
		//now lets do the fitting
		FuncFit/N/Q IR1B_FlatFnct W_coef Int_wave [FitFrom, DataLengths-1] /I=1 /W=Err_Wave /E=E_Wave /X=Q_vct	//Here we get the fit to the Int_wave in
		//now check for the convergence
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Linear fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]								//extend Int
			EndFor
			fit_ExtrapIntwave=W_coef[0]
		endif
	endif


	if (cmpstr(SelectedFunction,"power law")==0)			//power law background
	 	V_FitError=0					//this is way to avoid bombing due to numerical problems
		//now lets do the fitting	
		K0 = 0
		CurveFit/N/Q/H="100" Power Int_wave[FitFrom, DataLengths-1] /X=Q_vct /W=Err_Wave /I=1 
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Power law fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]+W_coef[1]*(Q_vct[DataLengths+i])^W_coef[2]			//extend Int
			endfor
			fit_ExtrapIntwave=W_coef[0]+W_coef[1]*(x)^W_coef[2]
		endif
	endif


	if (cmpstr(SelectedFunction,"Porod")==0)				//Porod background
		if (exists("W_coef")!=1)
			make/N=2 W_coef
		endif
		Redimension/D/N=2 W_coef
		variable estimate1_w0=Int_wave[(DataLengths-1)]
		variable estimate1_w1=Q_vct[(FitFrom)]^4*Int_wave[(FitFrom)]
		W_coef={estimate1_w0,estimate1_w1}							//here are starting guesses, may need to be fixed.
		K0=estimate1_w0
		K1=estimate1_w1
	 	V_FitError=0					//this is way to avoid bombing due to numerical problems
		//now lets do the fitting	
		FuncFit/N/Q IR1B_Porod W_coef Int_wave [FitFrom, DataLengths-1] /I=1 /W=Err_Wave /X=Q_vct			//Porod function here
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Porod fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]=W_coef[0]+W_coef[1]/(Q_vct[DataLengths+i])^4		//extend Int
			endfor
			fit_ExtrapIntwave=W_coef[0]+W_coef[1]/(x)^4
		endif
	endif


	if (cmpstr(SelectedFunction,"linear")==0)					//fit line
		CurveFit/N/Q line Int_wave [FitFrom, DataLengths-1] /I=1 /W=Err_Wave /X=Q_vct		//linear function here
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Linear fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)^2	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]+W_coef[1]*Q_vct[DataLengths+i]			//extend Int
			endfor
			fit_ExtrapIntwave=W_coef[0]+W_coef[1]*x	
		endif
	endif

	if (cmpstr(SelectedFunction,"polynom2")==0)				//fit polynom 2st degree
		CurveFit/N/Q poly 3, Int_wave [FitFrom, DataLengths-1] /I=1 /W=Err_Wave /X=Q_vct		//polynom 2st degree function here
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Polynomic fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]+W_coef[1]*Q_vct[DataLengths+i]+W_coef[2]*(Q_vct[DataLengths+i])^2
			endfor
			fit_ExtrapIntwave=W_coef[0]+W_coef[1]*x+W_coef[2]*(x)^2
		endif
	endif


	if (cmpstr(SelectedFunction,"polynom3")==0)				//fit polynom 3rd degree
		CurveFit/N/Q poly 4, Int_wave [FitFrom, DataLengths-1] /I=1 /W=Err_Wave /X=Q_vct			//polynom 3rd degree function here
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Plolynomic fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]+W_coef[1]*Q_vct[DataLengths+i]+W_coef[2]*(Q_vct[DataLengths+i])^2+W_coef[3]*(Q_vct[DataLengths+i])^3
			endFor
			fit_ExtrapIntwave=W_coef[0]+W_coef[1]*x+W_coef[2]*(x)^2+W_coef[3]*(x)^3
		endif
	endif
	

	if (cmpstr(SelectedFunction,"PowerLaw w flat")==0)				//fit polynom 3rd degree
		if (exists("W_coef")!=1)
			make/N=3 W_coef
		endif
	//	variable estimate1_w0=Int_wave[(DataLengths-1)]
	//	variable estimate1_w1=Q_vct[(FitFrom)]^4*Int_wave[(FitFrom)]
		K0=Int_wave[(DataLengths-1)]
		K1=(Int_wave[(FitFrom)] - K0) * (Q_vct[(FitFrom)]^3)
		K2=-3
		W_coef={K0,K1, K2}							//here are starting guesses, may need to be fixed.

		Make/O/T CTextWave={"K1 > 0","K2 < 0","K0 > 0", "K2 > -6"}
		Redimension/D/N=3 W_coef
	 	V_FitError=0					//this is way to avoid bombing due to numerical problems
			Curvefit/N/G/Q power Int_wave [FitFrom, DataLengths-1] /I=1 /C=CTextWave/X=Q_vct /W=Err_Wave		
		if (V_FitError!=0)
			//we had error during fitting
			ProblemWithFit="Power Law with flat fit function did not converge properly,\r change function or Q range"
		else		//the fit converged properly
			For(i=1;i<=NumNewPoints;i+=1)									
				Q_vct[DataLengths+i]=Q_vct[DataLengths]+(ExtendByQ)*(i/NumNewPoints)     	//extend Q
				Int_wave[DataLengths+i]= W_coef[0]+W_coef[1]*(Q_vct[DataLengths+i]^W_coef[2])
			endfor
			fit_ExtrapIntwave=W_coef[0]+W_coef[1]*(x^W_coef[2])
			endif
		endif

		wavestats/Q/R=[DataLengths+1,] Int_wave
	//	print DataLengths
		if (V_min<0)
			ProblemsWithInt="Extrapolated Intensity <0, select different function" 
		endif

	string ErrorMessages=""
	if (strlen(ProblemsWithQ)!=0)
		ErrorMessages=ProblemsWithQ+"\r"
	endif
	if (strlen(ProblemsWithInt)!=0)
		ErrorMessages=ProblemsWithInt+"\r"
	endif
	if (strlen(ProblemWithFit)!=0)
		ErrorMessages+=ProblemWithFit
	endif
	
	Variable/G ExtrapolationFunctionProblem
	NVAR ExtrapolationFunctionProblem
	ExtrapolationFunctionProblem=0
	
	DoWindow CheckTheBackgroundExtns
	if (V_flag)
		AppendToGraph /W=CheckTheBackgroundExtns fit_ExtrapIntwave
		ModifyGraph /W=CheckTheBackgroundExtns /Z rgb(fit_ExtrapIntwave)=(0,0,65280), lstyle(fit_ExtrapIntwave)=3
		ModifyGraph lsize(fit_ExtrapIntwave)=3
		//Error messages
		//First remove the old one
		if (stringMatch(WinRecreation("CheckTheBackgroundExtns",0),"*/N=ErrorMessageTextBox*"))
			TextBox/W=CheckTheBackgroundExtns/K/N=ErrorMessageTextBox
		endif
		if (strlen(ErrorMessages)!=0)
			TextBox/W=CheckTheBackgroundExtns/C/N=ErrorMessageTextBox/B=(65280,32512,16384)/D=3/A=RT "\\Z09"+ErrorMessages
			ExtrapolationFunctionProblem=1
		endif
	endif

	DoWindow CheckTheBackgroundExtns
	if (!V_flag)
		If (strlen(ErrorMessages)!=0)
			DoAlert 0,  ErrorMessages
		endif
	endif
	Wave/Z W_sigma
	
	//Now recording results, if asked for
	if (RecordFitParam)
		NVAR NumberOfIterations=NumberOfIterations
		IN2G_AppendAnyText("Record of extension fitting from desmearing iteration "+num2str(NumberOfIterations+1))
		IN2G_AppendAnyText("Used function: "+SelectedFunction)
		variable NumOfParam=numpnts(W_coef)
		For(i=0;i<NumOfParam;i+=1)
			if (WaveExists(W_sigma))
				IN2G_AppendAnyText("Parameter "+num2str(i+1)+" = "+num2str(W_coef[i])+"  +/-  "+num2str(W_sigma[i]))
			else
				IN2G_AppendAnyText("Parameter "+num2str(i+1)+" = "+num2str(W_coef[i]))
			endif
		endfor
	endif
	setDataFolder OldDf
end 

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IR1B_CopyDataLocally()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing
	 
	 KillWaves/Z SmoothIntwave, SmoothQwave, SmoothEwave
	NVAR SlitLength 			= 	root:Packages:Irena_desmearing:SlitLength
	NVAR SlitLengthL 			= 	root:Packages:Irena_desmearing:SlitLengthL
	NVAR SlitWidth 			= 	root:Packages:Irena_desmearing:SlitWidth
	NVAR SlitWidthL 			= 	root:Packages:Irena_desmearing:SlitWidthL
	SVAR DataFolderName       =  root:Packages:Irena_desmearing:DataFolderName
	SVAR IntensityWaveName   =  root:Packages:Irena_desmearing:IntensityWaveName
	SVAR QwaveName             =  root:Packages:Irena_desmearing:QWavename
	SVAR ErrorWaveName      =   root:Packages:Irena_desmearing:ErrorWaveName
	SVAR ExportdQWaveName      =   root:Packages:Irena_desmearing:ExportdQWaveName
	SVAR LastSample		=	root:Packages:Irena_desmearing:LastSample
	NVAR UseIndra2Data=root:Packages:Irena_desmearing:UseIndra2Data
	
	string dQname
	if(UseIndra2Data)
		dQname = "SMR_dQ"
	else	//QRS names
		dQname = "w"+QWavename[1,inf]
	endif

	LastSample	=	DataFolderName

	IntensityWaveName = PossiblyQuoteName(IntensityWaveName)
	QwaveName = PossiblyQuoteName(QwaveName)
	ErrorWaveName = PossiblyQuoteName(ErrorWaveName)

	Wave/Z Intensity  = $(DataFolderName+IntensityWaveName)
	Wave/Z Qvector   = $(DataFolderName+QwaveName)
	Wave/Z Error     = $(DataFolderName+ErrorWaveName)
	Wave/Z dQ       = $(DataFolderName+dQname)			 
	
	if (!WaveExists(Intensity) || !WaveExists(Qvector) || !WaveExists(Error))
		setDataFolder OldDf
		Abort "Waves not correctly selected. Note this code NEEDS the erros in order to work at all"
	endif
	Duplicate/O Intensity, OrgIntwave
	Duplicate/O Qvector, OrgQwave
	Duplicate/O Error, OrgEwave
	if(WaveExists(dQ))
		Duplicate/O dQ, OrgdQwave
	else
		Duplicate/O Qvector, OrgdQwave
		//Duplicate/O Qvector, dQ
		OrgdQwave[1,numpnts(dQ)-2] = (OrgQwave[p+1] - OrgQwave[p-1])/2
		OrgdQwave[0]= OrgdQwave[1]
		OrgdQwave[numpnts(dQ)-1] = OrgdQwave[-2]
	endif
	
	Redimension/D OrgIntWave, OrgQwave, OrgEwave
	if(strlen(note(OrgIntwave))>0)
		if(numtype(numberByKey("SlitLength",note(OrgIntwave),"=",";"))==0)
			SlitLength = numberByKey("SlitLength",note(OrgIntwave),"=",";")
		endif
		if(UseIndra2Data)
			SlitLengthL=0
			SlitWidth=0
			SlitWidthL=0
		endif
	endif
	IN2G_ReplaceNegValsByNaNWaves(OrgIntWave,OrgQwave,OrgEwave)		//here we remove negative values by setting them to NaNs
	IN2G_RemoveNaNsFrom4Waves(OrgIntWave,OrgQwave,OrgEwave,OrgdQwave)			//and here we remove NaNs all together

	SVAR ExportDataFolderName=root:Packages:Irena_desmearing:ExportDataFolderName
	SVAR ExportIntensityWaveName=root:Packages:Irena_desmearing:ExportIntensityWaveName
	SVAR ExportQWavename=root:Packages:Irena_desmearing:ExportQWavename
	SVAR ExportErrorWaveName=root:Packages:Irena_desmearing:ExportErrorWaveName
	
	if (UseIndra2Data)
		ExportDataFolderName = DataFolderName
		if (cmpstr(IntensityWaveName,"SMR_Int")==0)
			ExportIntensityWaveName = "DSM_Int"
			ExportQWavename = "DSM_Qvec"
			ExportErrorWaveName = "DSM_Error"
			ExportdQWaveName = "DSM_dQ"
		elseif (cmpstr(IntensityWaveName,"M_SMR_Int")==0)
			ExportIntensityWaveName = "M_DSM_Int"
			ExportQWavename = "M_DSM_Qvec"
			ExportErrorWaveName = "M_DSM_Error"
			ExportdQWaveName = "M_DSM_dQ"
		else
			setDataFolder OldDf
			abort
		endif
	else
		ExportDataFolderName = DataFolderName
		ExportIntensityWaveName = IntensityWaveName[0,25]+"_dsm"
		ExportQWavename = QwaveName+"_dsm"
		ExportErrorWaveName = ErrorWaveName+"_dsm"
		ExportdQWaveName = dQname+"_dsm"
	endif
	
	setDataFolder oldDf
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IR1B_TrimTheData()							//this function trims the data before desmearing.
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing:

	KillWIndow/Z TrimGraph
	Wave OrgIntwave=root:Packages:Irena_desmearing:OrgIntwave
	Wave OrgQwave=root:Packages:Irena_desmearing:OrgQwave
	Wave OrgEwave=root:Packages:Irena_desmearing:OrgEwave
	Wave OrgdQwave=root:Packages:Irena_desmearing:OrgdQwave
	IN2G_ReplaceNegValsByNaNWaves(OrgIntWave,OrgQwave,OrgEwave)		//here we remove negative values by setting them to NaNs
	IN2G_RemoveNaNsFrom4Waves(OrgIntWave,OrgQwave,OrgEwave,OrgdQwave)			//and here we remove NaNs all together
	
	Display/K=1 /W=(300,60,IN2G_GetGraphWidthHeight("width"),IN2G_GetGraphWidthHeight("height"))/N=TrimGraph OrgIntwave vs OrgQwave as "Trim the data"
	AutoPositionWindow/M=0/R=IR1B_DesmearingControlPanel  TrimGraph	
	ModifyGraph mode=4,margin(top)=100, mirror=1, minor=1
	showinfo												//shows info
	ShowTools/A											//show tools
	cursor/P A, OrgIntwave, (BinarySearch(OrgQwave, 0.00008)+1)
	cursor/P B, OrgIntwave, (numpnts(OrgIntwave)-1)
	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
	Button KillThisWindow pos={10,10}, size={100,25},  title="Kill window", proc=IN2G_KillGraphsTablesEnd
	Button ResetWindow pos={10,40}, size={100,25},  title="Reset window", proc=IN2G_ResetGraph
	SVAR DataFolderName=root:Packages:Irena_desmearing:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena_desmearing:IntensityWaveName
	TextBox/W=TrimGraph/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=TrimGraph/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	ModifyGraph mode=3
	ModifyGraph log=1
	Label left "Intensity"
	Label bottom "Q"
	ResumeUpdate
	ModifyGraph width=0, height=0
	IN2G_AutoAlignPanelAndGraph()
	setDataFolder OldDf
end	
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IR1B_SmoothDSMData()							//this smooths the data before desmearing.
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing:

	NVAR SmoothSMRData=root:Packages:Irena_desmearing:SmoothSMRData
	NVAR SmoothDSMData=root:Packages:Irena_desmearing:SmoothDSMData
	NVAR SmoothingParameterSMR=root:Packages:Irena_desmearing:SmoothingParameterSMR
	NVAR SmoothingParameterDSM=root:Packages:Irena_desmearing:SmoothingParameterDSM
	NVAR NormalizedChiSquareSMR=root:Packages:Irena_desmearing:NormalizedChiSquareSMR
	NVAR NormalizedChiSquareDSM=root:Packages:Irena_desmearing:NormalizedChiSquareDSM
	
	Wave/Z DesmearedIntWave=root:Packages:Irena_desmearing:DesmearedIntWave
	Wave/Z DesmearedQWave=root:Packages:Irena_desmearing:DesmearedQWave
	Wave/Z DesmearedEWave=root:Packages:Irena_desmearing:DesmearedEWave
	Wave/Z DesmeareddQWave=root:Packages:Irena_desmearing:DesmeareddQWave
	NVAR NumberOfIterations=root:Packages:Irena_desmearing:NumberOfIterations
	if(!WaveExists(DesmearedIntWave) || !WaveExists(DesmearedQWave) ||!WaveExists(DesmearedEWave) || NumberOfIterations<1)
		KillWaves/Z DesmearedIntWave, DesmearedQWave, DesmearedEWave
		setDataFolder OldDf
		return 0
	endif
	IN2G_ReplaceNegValsByNaNWaves(DesmearedIntWave,DesmearedQWave,DesmearedEWave)		//here we remove negative values by setting them to NaNs
	IN2G_RemoveNaNsFrom4Waves(DesmearedIntWave,DesmearedQWave,DesmearedEWave,DesmeareddQWave)			//and here we remove NaNs all together
	Duplicate/O DesmearedIntWave, SmoothDsmIntWave
	Duplicate/O DesmearedQWave, SmoothDsmQWave
	Duplicate/O DesmearedEWave, SmoothDsmEWave
	Duplicate/O DesmeareddQWave, SmoothDsmdQWave
	
	Display/K=1 /W=(300,60,IN2G_GetGraphWidthHeight("width"),IN2G_GetGraphWidthHeight("height"))/N=SmoothGraphDSM DesmearedIntWave vs DesmearedQWave as "Smooth the desmeared data"
	AppendToGraph SmoothDsmIntWave vs SmoothDsmQWave
	AutoPositionWindow/M=0/R=IR1B_DesmearingControlPanel  SmoothGraphDSM	
	ErrorBars DesmearedIntWave Y,wave=(root:Packages:Irena_desmearing:DesmearedEWave,root:Packages:Irena_desmearing:DesmearedEWave)
	ModifyGraph mode=4,margin(top)=100, mirror=1, minor=1
	showinfo												//shows info
	ShowTools/A											//show tools
	cursor/P A, DesmearedIntWave, (BinarySearch(DesmearedQWave, 0.00015)+1)
	cursor/P B, DesmearedIntWave, (numpnts(DesmearedIntWave)-1)
	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
	Button KillThisWindow pos={10,10}, size={100,25},  title="Kill window", proc=IN2G_KillGraphsTablesEnd
	Button ResetWindow pos={10,40}, size={100,25},  title="Reset window", proc=IN2G_ResetGraph
	SVAR DataFolderName=root:Packages:Irena_desmearing:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena_desmearing:IntensityWaveName
	TextBox/W=SmoothGraphDSM/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=SmoothGraphDSM/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	ModifyGraph mode=3
	ModifyGraph log=1
	Label left "Intensity"
	Label bottom "Q"
	ModifyGraph mode(SmoothDsmIntWave)=0,rgb(SmoothDsmIntWave)=(0,0,0)
	ResumeUpdate
	ModifyGraph width=0, height=0
	IN2G_AutoAlignPanelAndGraph()
	if (SmoothDSMData)
		 IR1B_SliderSmoothDSMData(SmoothingParameterDSM)
	endif
	setDataFolder OldDf
end	


//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************


Function IR1B_SmoothSMRData()							//this smooths the data before desmearing.
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing:

	NVAR SmoothSMRData=root:Packages:Irena_desmearing:SmoothSMRData
	NVAR SmoothDSMData=root:Packages:Irena_desmearing:SmoothDSMData
	NVAR SmoothingParameterSMR=root:Packages:Irena_desmearing:SmoothingParameterSMR
	NVAR SmoothingParameterDSM=root:Packages:Irena_desmearing:SmoothingParameterDSM
	NVAR NormalizedChiSquareSMR=root:Packages:Irena_desmearing:NormalizedChiSquareSMR
	NVAR NormalizedChiSquareDSM=root:Packages:Irena_desmearing:NormalizedChiSquareDSM
	
	Wave OrgIntwave=root:Packages:Irena_desmearing:OrgIntwave
	Wave OrgQwave=root:Packages:Irena_desmearing:OrgQwave
	Wave OrgEwave=root:Packages:Irena_desmearing:OrgEwave
	Wave OrgdQwave=root:Packages:Irena_desmearing:OrgdQwave
	IN2G_ReplaceNegValsByNaNWaves(OrgIntWave,OrgQwave,OrgEwave)		//here we remove negative values by setting them to NaNs
	IN2G_RemoveNaNsFrom4Waves(OrgIntWave,OrgQwave,OrgEwave,OrgdQwave)			//and here we remove NaNs all together
	Duplicate/O OrgIntwave, SmoothIntwave
	Duplicate/O OrgQwave, SmoothQwave
	Duplicate/O OrgEwave, SmoothEwave
	Duplicate/O OrgdQwave, SmoothdQwave
	
//	PauseUpdate; Silent 1		// building window...
	Display/K=1 /W=(300,60,IN2G_GetGraphWidthHeight("width"),IN2G_GetGraphWidthHeight("height"))/N=SmoothGraph OrgIntwave vs OrgQwave as "Smooth the data"
	AppendToGraph SmoothIntwave vs SmoothQwave
	AutoPositionWindow/M=0/R=IR1B_DesmearingControlPanel  SmoothGraph	
	ErrorBars OrgIntwave Y,wave=(root:Packages:Irena_desmearing:OrgEwave,root:Packages:Irena_desmearing:OrgEwave)
	ModifyGraph mode=4,margin(top)=100, mirror=1, minor=1
	showinfo												//shows info
	ShowTools/A											//show tools
	ModifyGraph fSize=12,font="Times New Roman"				//modifies size and font of labels
	Button KillThisWindow pos={10,10}, size={100,25},  title="Kill window", proc=IN2G_KillGraphsTablesEnd
	Button ResetWindow pos={10,40}, size={100,25},  title="Reset window", proc=IN2G_ResetGraph
	SVAR DataFolderName=root:Packages:Irena_desmearing:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena_desmearing:IntensityWaveName
	TextBox/W=SmoothGraph/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
	TextBox/W=SmoothGraph/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+DataFolderName+IntensityWaveName	
	ModifyGraph mode=3
	ModifyGraph log=1
	Label left "Intensity"
	Label bottom "Q"
	ModifyGraph mode(SmoothIntwave)=0,rgb(SmoothIntwave)=(0,0,0)
	ResumeUpdate
	ModifyGraph width=0, height=0
	IN2G_AutoAlignPanelAndGraph()
	if (SmoothSMRData)
		 IR1B_SliderSmoothSMRData(SmoothingParameterSMR)
	endif
	setDataFolder OldDf
end	

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//Function IR1B_RecalcBkg (ctrlName,varNum,varStr,varName) : SetVariableControl
//	String ctrlName
//	Variable varNum	// value of variable as number
//	String varStr		// value of variable as string
//	String varName	// name of variable
//
//	string OldDf=GetDataFolder(1)
//	setDataFolder root:Packages:Irena_desmearing:
//
//	WAVE ExtrapIntwave=root:Packages:Irena_desmearing:ExtrapIntwave
//	WAVE ExtrapQwave=root:Packages:Irena_desmearing:ExtrapQwave
//	WAVE ExtrapErrWave=root:Packages:Irena_desmearing:ExtrapErrWave
//	NVAR SlitLength=root:Packages:Irena_desmearing:SlitLength
//	NVAR BckgStartQ=root:Packages:Irena_desmearing:BckgStartQ
//	SVAR BackgroundFunction=root:Packages:Irena_desmearing:BackgroundFunction
//	NVAR numOfPoints=root:Packages:Irena_desmearing:numOfPoints
//	
//	Redimension/N=(numOfPoints) ExtrapIntwave, ExtrapQwave, ExtrapErrWave
//	IR1B_ExtendData(ExtrapIntwave, ExtrapQwave, ExtrapErrWave, SlitLength, BckgStartQ, BackgroundFunction,0)
//
//	setDataFolder OldDf
//End

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IR1B_TabPanelControl(name,tab)
	String name
	Variable tab

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing

	Button TrimDataBtn,disable=1, win=IR1B_DesmearingControlPanel
	Button RemovePoint,disable= 1, win=IR1B_DesmearingControlPanel
	SetVariable BackgroundStart,disable= 1, win=IR1B_DesmearingControlPanel
	PopupMenu BackgroundFnct,disable= 1, win=IR1B_DesmearingControlPanel
	Button DoOneIteration,disable= 1, win=IR1B_DesmearingControlPanel
	Button DoFiveIteration,disable= 1, win=IR1B_DesmearingControlPanel
	SetVariable NumberOfIterations,disable= 1, win=IR1B_DesmearingControlPanel
	CheckBox SmoothSMRData,disable= 1, win=IR1B_DesmearingControlPanel
	Slider SmoothSMRDataSlider,disable= 1, win=IR1B_DesmearingControlPanel
	SetVariable SmoothSMRChiSq,disable= 1, win=IR1B_DesmearingControlPanel
	CheckBox SmoothDSMData,disable= 1, win=IR1B_DesmearingControlPanel
	Slider SmoothDSMDataSlider,disable= 1, win=IR1B_DesmearingControlPanel
	SetVariable SmoothDSMChiSq,disable= 1, win=IR1B_DesmearingControlPanel
	Button RecalcDSMSmooth,disable= 1, win=IR1B_DesmearingControlPanel

//	CheckBox DesmearMaskNegatives,disable= 1, win=IR1B_DesmearingControlPanel
//	CheckBox DesmearRemoveNegatives,disable= 1, win=IR1B_DesmearingControlPanel

	CheckBox DesmearFastOnly,disable= 1, win=IR1B_DesmearingControlPanel
	CheckBox DesmearSlowOnly,disable= 1, win=IR1B_DesmearingControlPanel
	CheckBox DesmearCombo,disable= 1, win=IR1B_DesmearingControlPanel
	SetVariable DesmearSwitchOverVal,disable= 1, win=IR1B_DesmearingControlPanel
	Button DoNIterations , disable= 1, win=IR1B_DesmearingControlPanel
	SetVariable NIterations disable=1, win=IR1B_DesmearingControlPanel
	SetVariable DesmearAutoTargChisq, disable= 1, win=IR1B_DesmearingControlPanel
	Button DoAutoIterations , disable=1, win=IR1B_DesmearingControlPanel
	CheckBox DesmearDampen,disable= 1, win=IR1B_DesmearingControlPanel


	NVAR NumberOfIterations=root:Packages:Irena_desmearing:NumberOfIterations

	Wave/Z OrgIntwave=root:Packages:Irena_desmearing:OrgIntwave
	Wave/Z OrgQwave=root:Packages:Irena_desmearing:OrgQwave
	Wave/Z OrgEwave=root:Packages:Irena_desmearing:OrgEwave
	Wave/Z OrgdQwave=root:Packages:Irena_desmearing:OrgdQwave

	Wave/Z SmoothIntwave=root:Packages:Irena_desmearing:SmoothIntwave
	Wave/Z SmoothQwave=root:Packages:Irena_desmearing:SmoothQwave
	Wave/Z SmoothEwave=root:Packages:Irena_desmearing:SmoothEwave
	Wave/Z SmoothdQwave=root:Packages:Irena_desmearing:SmoothdQwave

	Wave/Z ExtrapIntwave=root:Packages:Irena_desmearing:ExtrapIntwave
	Wave/Z ExtrapQwave=root:Packages:Irena_desmearing:ExtrapQwave
	Wave/Z ExtrapErrWave=root:Packages:Irena_desmearing:ExtrapErrWave
	Wave/Z ExtrapdQWave=root:Packages:Irena_desmearing:ExtrapdQWave

	Wave/Z DesmearedIntWave=root:Packages:Irena_desmearing:DesmearedIntWave
	Wave/Z DesmearedQWave=root:Packages:Irena_desmearing:DesmearedQWave
	Wave/Z DesmearedEWave=root:Packages:Irena_desmearing:DesmearedEWave
	Wave/Z DesmeareddQWave=root:Packages:Irena_desmearing:DesmeareddQWave

	Wave/Z SmoothDsmIntWave=root:Packages:Irena_desmearing:SmoothDsmIntWave
	Wave/Z SmoothDsmQWave=root:Packages:Irena_desmearing:SmoothDsmQWave
	Wave/Z SmoothDsmEWave=root:Packages:Irena_desmearing:SmoothDsmEWave
	Wave/Z SmoothDsmdQWave=root:Packages:Irena_desmearing:SmoothDsmdQWave

	if (!WaveExists(OrgIntwave) || !WaveExists(OrgQwave) || !WaveExists(OrgEwave))
		setDataFolder OldDf
		Abort
	endif
	
//Trim data controls, first tab
	Button TrimDataBtn,disable= (tab!=0), win=IR1B_DesmearingControlPanel
	Button RemovePoint,disable= (tab!=0), win=IR1B_DesmearingControlPanel
	if (tab==0)
		KillWaves/Z SmoothIntwave, SmoothQwave, SmoothEwave, SmoothdQwave
		KillWaves/Z ExtrapIntwave, ExtrapQwave, ExtrapErrWave, ExtrapdQWave
		KillWaves/Z DesmearedIntWave, DesmearedQWave, DesmearedEWave, DesmeareddQWave
		KillWaves/Z SmoothDsmIntWave, SmoothDsmQWave, SmoothDsmEWave, SmoothDsmdQWave
		DoWindow TrimGraph		//create this
		if(!V_Flag)
			IR1B_TrimTheData()
			AutoPositionWindow /M=0 /R=IR1B_DesmearingControlPanel TrimGraph
		endif
	else
		KillWIndow/Z TrimGraph
	endif
	
//Smooth SMR data
	NVAR  SmoothSMRData = root:Packages:Irena_desmearing:SmoothSMRData
	CheckBox SmoothSMRData,disable= (tab!=1), win=IR1B_DesmearingControlPanel
	Slider SmoothSMRDataSlider,disable= (tab!=1 || SmoothSMRData!=1), win=IR1B_DesmearingControlPanel
	SetVariable SmoothSMRChiSq,disable= (tab!=1 || SmoothSMRData!=1), win=IR1B_DesmearingControlPanel
	if (tab==1)
		KillWaves/Z ExtrapIntwave, ExtrapQwave, ExtrapErrWave, ExtrapdQWave
		KillWaves/Z DesmearedIntWave, DesmearedQWave, DesmearedEWave, DesmeareddQWave
		KillWaves/Z SmoothDsmIntWave, SmoothDsmQWave, SmoothDsmEWave, SmoothDsmdQWave
		DoWindow SmoothGraph		//create this
		if(!V_Flag)
			IR1B_SmoothSMRData()
			AutoPositionWindow /M=0 /R=IR1B_DesmearingControlPanel SmoothGraph
		endif
	else
		KillWIndow/Z SmoothGraph
	endif


	
//Extrapolate data controls, second tab
	SetVariable BackgroundStart,disable= (tab!=2), win=IR1B_DesmearingControlPanel
	PopupMenu BackgroundFnct,disable= (tab!=2), win=IR1B_DesmearingControlPanel
//	CheckBox DesmearMaskNegatives,disable= (tab!=2), win=IR1B_DesmearingControlPanel
//	CheckBox DesmearRemoveNegatives,disable= (tab!=2), win=IR1B_DesmearingControlPanel
	if (tab==2)
		KillWaves/Z DesmearedIntWave, DesmearedQWave, DesmearedEWave, DesmeareddQWave
		KillWaves/Z SmoothDsmIntWave, SmoothDsmQWave, SmoothDsmEWave, SmoothDsmdQWave
		DoWindow CheckTheBackgroundExtns
		if(!V_Flag)
			IR1B_CheckTheBackgroundExtns()
			AutoPositionWindow /M=0 /R=IR1B_DesmearingControlPanel CheckTheBackgroundExtns
		endif
	else
		KillWIndow/Z CheckTheBackgroundExtns
	endif

//Desmearing third tab
	Button DoOneIteration,disable= (tab!=3), win=IR1B_DesmearingControlPanel
	Button DoFiveIteration,disable= (tab!=3), win=IR1B_DesmearingControlPanel
	SetVariable NumberOfIterations,disable= (tab!=3), win=IR1B_DesmearingControlPanel
	CheckBox DesmearFastOnly,disable= (tab!=3), win=IR1B_DesmearingControlPanel
	CheckBox DesmearSlowOnly,disable= (tab!=3), win=IR1B_DesmearingControlPanel
	CheckBox DesmearCombo,disable= (tab!=3), win=IR1B_DesmearingControlPanel
	SetVariable DesmearSwitchOverVal,disable= (tab!=3), win=IR1B_DesmearingControlPanel
	Button DoNIterations , disable= (tab!=3), win=IR1B_DesmearingControlPanel
	SetVariable NIterations disable= (tab!=3), win=IR1B_DesmearingControlPanel
	SetVariable DesmearAutoTargChisq, disable= (tab!=3), win=IR1B_DesmearingControlPanel
	Button DoAutoIterations , disable= (tab!=3), win=IR1B_DesmearingControlPanel
	CheckBox DesmearDampen,disable= (tab!=3), win=IR1B_DesmearingControlPanel
	if (tab==3)
		KillWaves/Z SmoothDsmIntWave, SmoothDsmQWave, SmoothDsmEWave
		DoWindow DesmearingProcess
		if(!V_Flag)
			NumberOfIterations=0
			IR1B_DoDesmearing()
			AutoPositionWindow /M=0 /R=IR1B_DesmearingControlPanel DesmearingProcess
		endif
	else
		KillWIndow/Z DesmearingProcess
	endif

//Smooth DSM data
	NVAR  SmoothDSMData = root:Packages:Irena_desmearing:SmoothDSMData
	CheckBox SmoothDSMData,disable= (tab!=4), win=IR1B_DesmearingControlPanel
	Slider SmoothDSMDataSlider,disable= (tab!=4 || SmoothDSMData!=1), win=IR1B_DesmearingControlPanel
	SetVariable SmoothDSMChiSq,disable= (tab!=4 || SmoothDSMData!=1), win=IR1B_DesmearingControlPanel
	Button RecalcDSMSmooth,disable= (tab!=4 || SmoothDSMData!=1), win=IR1B_DesmearingControlPanel
	if (tab==4)
		DoWindow SmoothGraphDSM		//create this
		if(!V_Flag)
			IR1B_SmoothDSMData()
			DoWindow SmoothGraphDSM
			if(V_Flag)
				AutoPositionWindow /M=0 /R=IR1B_DesmearingControlPanel SmoothGraphDSM
			endif
		endif
	else
		KillWIndow/Z SmoothGraphDSM
	endif
	Dowindow/F IR1B_DesmearingControlPanel

	setDataFolder OldDf
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*********************************************************************************************
Function IR1B_SliderProc(ctrlName,sliderValue,event) : SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

//	if(event %& 0x1)	// bit 0, value set
//
//	endif

	if(cmpstr(ctrlName,"SmoothSMRDataSlider")==0 && event ==4)	// bit 0, value set
		//here we go and do what should be done...
		IR1B_SliderSmoothSMRData(sliderValue)
	endif
	if(cmpstr(ctrlName,"SmoothDSMDataSlider")==0 && event ==4)	// bit 0, value set
		//here we go and do what should be done...
		IR1B_SliderSmoothDSMData(sliderValue)
	endif

	return 0
End
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*********************************************************************************************

Function  IR1B_SliderSmoothDSMData(sliderValue)
	variable sliderValue
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing

	Wave Int=root:Packages:Irena_desmearing:DesmearedIntWave
	Wave Qvec=root:Packages:Irena_desmearing:DesmearedQWave
	Wave Error=root:Packages:Irena_desmearing:DesmearedEWave
	Wave dQ=root:Packages:Irena_desmearing:DesmeareddQWave
	Wave SmoothInt=root:Packages:Irena_desmearing:SmoothDsmIntWave
	Wave SmoothQvec=root:Packages:Irena_desmearing:SmoothDsmQWave
	Wave SmoothError=root:Packages:Irena_desmearing:SmoothDsmEWave
	Wave DesmearedIntWave=root:Packages:Irena_desmearing:DesmearedIntWave
	NVAR NormalizedChiSquareDSM=root:Packages:Irena_desmearing:NormalizedChiSquareDSM
	
	Duplicate/O Int, Int_log, Error_log
	Duplicate/O Qvec, Qvec_log
	Qvec_log = log( Qvec)
	Int_log= log(Int)
	variable scaleMe
	variable param = -1+10^sliderValue
	variable startPoint
	variable endPoint
	if(strlen(CsrWave(A, "SmoothGraphDSM"))>0)
		startPoint= pcsr(A, "SmoothGraphDSM")
	else
		startPoint=0
	endif
	if(strlen(CsrWave(B, "SmoothGraphDSM"))>0)
		endPoint= pcsr(B, "SmoothGraphDSM")
	else
		endPoint=numpnts(DesmearedIntWave)-1
	endif
	wavestats/Q Int_log
	scaleMe = 2*(-V_min)
	Int_log+= scaleMe
	Error_log= Int_log*( 1/(Int_Log) - 1/(log(Int+Error)))
	
	IN2G_SplineSmooth(startPoint,endPoint,Qvec_log,Int_Log,Error_Log,param,SmoothInt,$"")
	
	
	SmoothInt-=scaleMe
	SmoothInt = 10^SmoothInt
	duplicate/O Int, ChiSqWv
	ChiSqWv= (Int-SmoothInt)/SmoothError
	ChiSqWv=ChiSqWv^2
	IN2G_RemNaNsFromAWave(ChiSqWv)	
	NormalizedChiSquareDSM = sqrt(sum(ChiSqWv))/numpnts(ChiSqWv)

	setDataFOlder OldDf
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*********************************************************************************************

Function  IR1B_SliderSmoothSMRData(sliderValue)
	variable sliderValue
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing

	Wave Int=root:Packages:Irena_desmearing:OrgIntwave
	Wave Qvec=root:Packages:Irena_desmearing:OrgQwave
	Wave Error=root:Packages:Irena_desmearing:OrgEwave
	Wave dQ=root:Packages:Irena_desmearing:OrgdQwave
	Wave/Z SmoothInt=root:Packages:Irena_desmearing:SmoothIntwave
	Wave/Z SmoothQvec=root:Packages:Irena_desmearing:SmoothQwave
	Wave/Z SmoothError=root:Packages:Irena_desmearing:SmoothEwave
	Wave/Z SmoothdQrror=root:Packages:Irena_desmearing:SmoothdQwave
	if(!WaveExists(SmoothInt)||!WaveExists(SmoothQvec)||!WaveExists(SmoothError))
		Duplicate/O Int, SmoothIntWave
		Duplicate/O Qvec, SmoothQwave
		Duplicate/O Error, SmoothEwave
		Duplicate/O dQ, SmoothdQwave
		Wave SmoothInt=root:Packages:Irena_desmearing:SmoothIntwave
		Wave SmoothQvec=root:Packages:Irena_desmearing:SmoothQwave
		Wave SmoothError=root:Packages:Irena_desmearing:SmoothEwave
		Wave SmoothdQ=root:Packages:Irena_desmearing:SmoothdQwave
	endif
	NVAR NormalizedChiSquareSMR=root:Packages:Irena_desmearing:NormalizedChiSquareSMR
	
	Duplicate/O Int, Int_log, Error_log
	Duplicate/O Qvec, Qvec_log
	Qvec_log = log( Qvec)
	Int_log= log(Int)
	variable scaleMe
	variable param = -1+10^sliderValue
	wavestats/Q Int_log
	scaleMe = 2*(-V_min)
	Int_log+= scaleMe
	Error_log= Int_log*( 1/(Int_Log) - 1/(log(Int+Error)))
	
	IN2G_SplineSmooth(0,numpnts(Int_Log)-1,Qvec_log,Int_Log,Error_Log,param,SmoothInt,$"")
	
	SmoothInt-=scaleMe
	SmoothInt = 10^SmoothInt
	duplicate/O Int, ChiSqWv
	ChiSqWv= (Int-SmoothInt)/SmoothError
	ChiSqWv=ChiSqWv^2
	NormalizedChiSquareSMR = sqrt(sum(ChiSqWv))/numpnts(Int_Log)

	setDataFolder OldDf
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//*********************************************************************************************
Function IR1B_InputPanelCheckboxProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing

	NVAR DesmearRemoveNegatives=root:Packages:Irena_desmearing:DesmearRemoveNegatives	
	NVAR DesmearMaskNegatives=root:Packages:Irena_desmearing:DesmearMaskNegatives	
	if(cmpstr(ctrlName,"DesmearMaskNegatives")==0)
		DesmearMaskNegatives=checked
		DesmearRemoveNegatives=!checked
	endif
	if(cmpstr(ctrlName,"DesmearRemoveNegatives")==0)
		DesmearMaskNegatives=!checked
		DesmearRemoveNegatives=checked
	endif

	if (cmpstr(ctrlName,"UseIndra2Data")==0)
		//here we control the data structure checkbox
		NVAR UseIndra2Data=root:Packages:Irena_desmearing:UseIndra2Data
		NVAR UseQRSData=root:Packages:Irena_desmearing:UseQRSData
		SVAR LastSample=root:Packages:Irena_desmearing:LastSample
		LastSample=""
		UseIndra2Data=checked
		if (checked)
			UseQRSData=0
			Button NextSampleAndDrawGraphs, disable=0, win=IR1B_DesmearingControlPanel
		else
			Button NextSampleAndDrawGraphs, disable=1, win=IR1B_DesmearingControlPanel
		endif
		Checkbox UseIndra2Data, value=UseIndra2Data
		Checkbox UseQRSData, value=UseQRSData
		SVAR Dtf=root:Packages:Irena_desmearing:DataFolderName
		SVAR IntDf=root:Packages:Irena_desmearing:IntensityWaveName
		SVAR QDf=root:Packages:Irena_desmearing:QWaveName
		SVAR EDf=root:Packages:Irena_desmearing:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName  mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
	endif
	if (cmpstr(ctrlName,"UseQRSData")==0)
		//here we control the data structure checkbox
		NVAR UseQRSData=root:Packages:Irena_desmearing:UseQRSData
		NVAR UseIndra2Data=root:Packages:Irena_desmearing:UseIndra2Data
		SVAR LastSample=root:Packages:Irena_desmearing:LastSample
		LastSample=""
		UseQRSData=checked
		if (checked)
			UseIndra2Data=0
			Button NextSampleAndDrawGraphs, disable=1, win=IR1B_DesmearingControlPanel
		endif
		Checkbox UseIndra2Data, value=UseIndra2Data
		Checkbox UseQRSData, value=UseQRSData
		SVAR Dtf=root:Packages:Irena_desmearing:DataFolderName
		SVAR IntDf=root:Packages:Irena_desmearing:IntensityWaveName
		SVAR QDf=root:Packages:Irena_desmearing:QWaveName
		SVAR EDf=root:Packages:Irena_desmearing:ErrorWaveName
			Dtf=" "
			IntDf=" "
			QDf=" "
			EDf=" "
			PopupMenu SelectDataFolder mode=1
			PopupMenu IntensityDataName   mode=1, value="---"
			PopupMenu QvecDataName    mode=1, value="---"
			PopupMenu ErrorDataName    mode=1, value="---"
	endif

	if (cmpstr(ctrlName,"SmoothSMRData")==0)
		IR1B_TabPanelControl("name",1)
		NVAR SmoothSMRData=root:Packages:Irena_desmearing:SmoothSMRData
		NVAR SmoothingParameterSMR=root:Packages:Irena_desmearing:SmoothingParameterSMR
		Wave OrgIntwave=root:Packages:Irena_desmearing:OrgIntwave
		Wave OrgQwave=root:Packages:Irena_desmearing:OrgQwave
		Wave OrgEwave=root:Packages:Irena_desmearing:OrgEwave
		Wave OrgdQwave=root:Packages:Irena_desmearing:OrgdQwave
		IN2G_ReplaceNegValsByNaNWaves(OrgIntWave,OrgQwave,OrgEwave)		//here we remove negative values by setting them to NaNs
		IN2G_RemoveNaNsFrom4Waves(OrgIntWave,OrgQwave,OrgEwave,OrgdQwave)			//and here we remove NaNs all together
		Duplicate/O OrgIntwave, SmoothIntwave
		Duplicate/O OrgQwave, SmoothQwave
		Duplicate/O OrgEwave, SmoothEwave
		Duplicate/O OrgdQwave, SmoothdQwave
		if(SmoothSMRData)
			 IR1B_SliderSmoothSMRData(SmoothingParameterSMR)	
		else
			//do nothing
		endif
	endif
	if (cmpstr(ctrlName,"SmoothDSMData")==0)
		IR1B_TabPanelControl("name",4)
		NVAR SmoothDSMData=root:Packages:Irena_desmearing:SmoothDSMData
		NVAR SmoothingParameterDSM=root:Packages:Irena_desmearing:SmoothingParameterDSM
		Wave/Z DesmearedIntWave=root:Packages:Irena_desmearing:DesmearedIntWave
		Wave/Z DesmearedQWave=root:Packages:Irena_desmearing:DesmearedQWave
		Wave/Z DesmearedEWave=root:Packages:Irena_desmearing:DesmearedEWave
		Wave/Z DesmeareddQWave=root:Packages:Irena_desmearing:DesmeareddQWave
		if(WaveExists(DesmearedIntWave) ||WaveExists(DesmearedQWave) ||WaveExists(DesmearedEWave))
			IN2G_ReplaceNegValsByNaNWaves(DesmearedIntWave,DesmearedQWave,DesmearedEWave)		//here we remove negative values by setting them to NaNs
			IN2G_RemoveNaNsFrom4Waves(DesmearedIntWave,DesmearedQWave,DesmearedEWave,DesmeareddQWave)			//and here we remove NaNs all together
			Duplicate/O DesmearedIntWave, SmoothDsmIntWave
			Duplicate/O DesmearedQWave, SmoothDsmQWave
			Duplicate/O DesmearedEWave, SmoothDsmEWave
			Duplicate/O DesmeareddQWave, SmoothDsmdQWave
			if(SmoothDSMData)
				 IR1B_SliderSmoothDSMData(SmoothingParameterDSM)	
			else
				//do nothing
			endif
		endif
	endif

	NVAR DesmearFastOnly=root:Packages:Irena_desmearing:DesmearFastOnly
	NVAR DesmearSlowOnly=root:Packages:Irena_desmearing:DesmearSlowOnly
	NVAR DesmearCombo=root:Packages:Irena_desmearing:DesmearCombo
	NVAR DesmearDampen=root:Packages:Irena_desmearing:DesmearDampen
	if(cmpstr(ctrlName,"DesmearFastOnly")==0)
		if(checked)
			//DesmearFastOnly=0
			DesmearSlowOnly=0
			DesmearCombo=0
			DesmearDampen=0
		endif
	endif
	if(cmpstr(ctrlName,"DesmearSlowOnly")==0)
		if(checked)
			DesmearFastOnly=0
			//DesmearSlowOnly=0
			DesmearCombo=0
			DesmearDampen=0
		endif
	endif
	if(cmpstr(ctrlName,"DesmearCombo")==0)
		if(checked)
			DesmearFastOnly=0
			DesmearSlowOnly=0
			//DesmearCombo=0
			DesmearDampen=0
		endif
	endif
	if(cmpstr(ctrlName,"DesmearDampen")==0)
		if(checked)
			DesmearFastOnly=0
			DesmearSlowOnly=0
			DesmearCombo=0
			//DesmearDampen=0
		endif
	endif
	
	setDataFolder OldDf
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IR1B_PanelPopupControl(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing

		NVAR UseIndra2Data=root:Packages:Irena_desmearing:UseIndra2Data
		NVAR UseQRSData=root:Packages:Irena_desmearing:UseQRSdata
		SVAR IntDf=root:Packages:Irena_desmearing:IntensityWaveName
		SVAR QDf=root:Packages:Irena_desmearing:QWaveName
		SVAR EDf=root:Packages:Irena_desmearing:ErrorWaveName
		SVAR Dtf=root:Packages:Irena_desmearing:DataFolderName

	if (cmpstr(ctrlName,"SelectDataFolder")==0)
		//here we do what needs to be done when we select data folder
		Dtf=popStr
		PopupMenu IntensityDataName mode=1
		PopupMenu QvecDataName mode=1
		PopupMenu ErrorDataName mode=1
		if (UseIndra2Data)
			if(stringmatch(IR1B_ListOfWaves("SMR_Int"), "*M_SMR_Int*") &&stringmatch(IR1B_ListOfWaves("SMR_Qvec"), "*M_SMR_Qvec*")  &&stringmatch(IR1B_ListOfWaves("SMR_Error"), "*M_SMR_Error*") )			
				IntDf="M_SMR_Int"
				QDf="M_SMR_Qvec"
				EDf="M_SMR_Error"
				PopupMenu IntensityDataName value="M_SMR_Int;SMR_Int"
				PopupMenu QvecDataName value="M_SMR_Qvec;SMR_Qvec"
				PopupMenu ErrorDataName value="M_SMR_Error;SMR_Error"
			else
				if(!stringmatch(IR1B_ListOfWaves("SMR_Int"), "*M_SMR_Int*") &&!stringmatch(IR1B_ListOfWaves("SMR_Qvec"), "*M_SMR_Qvec*")  &&!stringmatch(IR1B_ListOfWaves("SMR_Error"), "*M_SMR_Error*") )			
					IntDf="SMR_Int"
					QDf="SMR_Qvec"
					EDf="SMR_Error"
					PopupMenu IntensityDataName value="SMR_Int"
					PopupMenu QvecDataName value="SMR_Qvec"
					PopupMenu ErrorDataName value="SMR_Error"
				endif
			endif
		else
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName value="---"
			PopupMenu QvecDataName  value="---"
			PopupMenu ErrorDataName  value="---"
		endif
		if(UseQRSdata)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1B_ListOfWaves("SMR_Int")
			PopupMenu QvecDataName  value="---;"+IR1B_ListOfWaves("SMR_Qvec")
			PopupMenu ErrorDataName  value="---;"+IR1B_ListOfWaves("SMR_Error")
		endif
		if(!UseQRSdata && !UseIndra2Data)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---;"+IR1B_ListOfWaves("SMR_Int")
			PopupMenu QvecDataName  value="---;"+IR1B_ListOfWaves("SMR_Qvec")
			PopupMenu ErrorDataName  value="---;"+IR1B_ListOfWaves("SMR_Error")
		endif
		if (cmpstr(popStr,"---")==0)
			IntDf=""
			QDf=""
			EDf=""
			PopupMenu IntensityDataName  value="---"
			PopupMenu QvecDataName  value="---"
			PopupMenu ErrorDataName  value="---"
		endif
	endif
	
	if (cmpstr(ctrlName,"IntensityDataName")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			IntDf=popStr
			if (UseQRSData && strlen(QDf)==0 && strlen(EDf)==0)
				QDf="q"+popStr[1,inf]
				EDf="s"+popStr[1,inf]
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:Irena_desmearing:QWaveName+\";---;\"+IR1B_ListOfWaves(\"SMR_Qvec\")")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:Irena_desmearing:ErrorWaveName+\";---;\"+IR1B_ListOfWaves(\"SMR_Error\")")
			endif
		else
			IntDf=""
		endif
	endif

	if (cmpstr(ctrlName,"QvecDataName")==0)
		//here goes what needs to be done, when we select this popup...	
		if (cmpstr(popStr,"---")!=0)
			QDf=popStr
			if (UseQRSData && strlen(IntDf)==0 && strlen(EDf)==0)
				IntDf="r"+popStr[1,inf]
				EDf="s"+popStr[1,inf]
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:Irena_desmearing:IntensityWaveName+\";---;\"+IR1B_ListOfWaves(\"SMR_Int\")")
				Execute ("PopupMenu ErrorDataName mode=1, value=root:Packages:Irena_desmearing:ErrorWaveName+\";---;\"+IR1B_ListOfWaves(\"SMR_Error\")")
			endif
		else
			QDf=""
		endif
	endif
	
	if (cmpstr(ctrlName,"ErrorDataName")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			EDf=popStr
			if (UseQRSData && strlen(IntDf)==0 && strlen(QDf)==0)
				IntDf="r"+popStr[1,inf]
				QDf="q"+popStr[1,inf]
				Execute ("PopupMenu IntensityDataName mode=1, value=root:Packages:Irena_desmearing:IntensityWaveName+\";---;\"+IR1B_ListOfWaves(\"SMR_Int\")")
				Execute ("PopupMenu QvecDataName mode=1, value=root:Packages:Irena_desmearing:QWaveName+\";---;\"+IR1B_ListOfWaves(\"SMR_Qvec\")")
			endif
		else
			EDf=""
		endif
	endif
	if (cmpstr(ctrlName,"SelectNewDataFolder")==0)
		//here goes what needs to be done, when we select this popup...
		if (cmpstr(popStr,"---")!=0)
			SVAR ExportDataFolderName=root:Packages:Irena_desmearing:ExportDataFolderName
			ExportDataFolderName = popstr
		endif
	endif
	
	setDataFolder OldDf
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function/T IR1B_GenStringOfFolders(UseIndra2Structure, UseQRSStructure)
	variable UseIndra2Structure, UseQRSStructure
	
	string ListOfQFolders
	//	if UseIndra2Structure = 1 we are using Indra2 data, else return all folders 
	string result
	if (UseIndra2Structure)
		result=IN2G_FindFolderWithWaveTypes("root:", 10, "*SMR*", 1)
	elseif (UseQRSStructure)
		ListOfQFolders=IN2G_FindFolderWithWaveTypes("root:", 10, "q*", 1)
		result=IR1_ReturnListQRSFolders(ListOfQFolders,0)
	else
		result=IN2G_FindFolderWithWaveTypes("root:", 10, "*", 1)
	endif
	
	return result
end


//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IR1B_InputPanelButtonProc(ctrlName) : ButtonControl
	String ctrlName

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing
	variable IsAllAllRight
	
	if(cmpstr(ctrlName,"GetHelp")==0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Irena/Desmearing.html")
	endif
	if (cmpstr(ctrlName,"DrawGraphs")==0)
		//here goes what is done, when user pushes Graph button
		SVAR DFloc=root:Packages:Irena_desmearing:DataFolderName
		SVAR DFInt=root:Packages:Irena_desmearing:IntensityWaveName
		SVAR DFQ=root:Packages:Irena_desmearing:QWaveName
		SVAR DFE=root:Packages:Irena_desmearing:ErrorWaveName
		IsAllAllRight=1
		if (cmpstr(DFloc,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFInt,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFQ,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFE,"---")==0)
			IsAllAllRight=0
		endif
		
		if (IsAllAllRight)
			
		else
			setDataFolder OldDf
			Abort "Data not selected properly"
		endif
		IR1B_CopyDataLocally()
		IR1B_TrimTheData()
		IR1B_TabPanelControl("xxx",0)
		TabControl DesmearTabs,value= 0, win=IR1B_DesmearingControlPanel
		//and add or remove the next button, sicne it cannot be done elsewhere...
		NVAR DisplayNextButton=root:Packages:Irena_desmearing:UseIndra2data
		Button NextSampleAndDrawGraphs,win=IR1B_DesmearingControlPanel, disable=!(DisplayNextButton)
	endif
	if (cmpstr(ctrlName,"NextSampleAndDrawGraphs")==0)
		//here goes what is done, when user pushes Next sample button
		SVAR LastSample=root:Packages:Irena_desmearing:LastSample
		NVAR UseIndra2Data=root:Packages:Irena_desmearing:UseIndra2Data
		NVAR UseQRSData=root:Packages:Irena_desmearing:UseQRSData
		//String ShortListOfFolders=IR1B_GenStringOfFolders(UseIndra2Data, UseQRSData)
		String ShortListOfFolders=IR2P_GenStringOfFolders(winNm="IR1B_DesmearingControlPanel")
		SVAR RealLongListOfFolder = root:Packages:Irena_desmearing:RealLongListOfFolder
		SVAR ShortListOfFoldersWP = root:Packages:Irena_desmearing:ShortListOfFolders
		String AllFolders=RealLongListOfFolder
		variable CurrentFolder=WhichListItem(LastSample,ShortListOfFoldersWP)
		SVAR DFloc=root:Packages:Irena_desmearing:DataFolderName
		string Dflocshort
		if(CurrentFolder>=0)
			DFloc = StringFromList(CurrentFolder+1, ShortListOfFoldersWP)
			Dflocshort = StringFromList(CurrentFolder+1, ShortListOfFolders)
			//PopupMenu SelectDataFolder,mode=1,win=IR1B_DesmearingControlPanel, popvalue=DFloc,value= #"\"---;\"+IR1B_GenStringOfFolders(root:Packages:Irena_desmearing:UseIndra2Data, root:Packages:Irena_desmearing:UseQRSData)"
			execute("PopupMenu SelectDataFolder,mode=1,win=IR1B_DesmearingControlPanel,  popvalue=\""+Dflocshort+"\",value= \"---;\"+IR2P_GenStringOfFolders(winNm=\"IR1B_DesmearingControlPanel\")")
		endif
		//this fails for Indra 2 data and combination of SMR/M_SMR waves... Patch it up here.
		SVAR DFInt=root:Packages:Irena_desmearing:IntensityWaveName
		SVAR DFQ=root:Packages:Irena_desmearing:QWaveName
		SVAR DFE=root:Packages:Irena_desmearing:ErrorWaveName
		if(UseIndra2Data)
			if(stringmatch(DFInt,"*SMR_Int"))	
				Wave/Z SMRInt=$(DFloc+"SMR_Int")
				Wave/Z MSMRInt=$(DFloc+"M_SMR_Int")
				if(WaveExists(MSMRInt))
					DFInt="M_SMR_Int"
					DFQ="M_SMR_Qvec"
					DFE="M_SMR_Error"
					PopupMenu IntensityDataName value="M_SMR_Int;SMR_Int"
					PopupMenu QvecDataName value="M_SMR_Qvec;SMR_Qvec"
					PopupMenu ErrorDataName value="M_SMR_Error;SMR_Error"
				elseif(WaveExists(SMRInt))
					DFInt="SMR_Int"
					DFQ="SMR_Qvec"
					DFE="SMR_Error"
					PopupMenu IntensityDataName value="SMR_Int"
					PopupMenu QvecDataName value="SMR_Qvec"
					PopupMenu ErrorDataName value="SMR_Error"
				else
					DFInt="---"
					DFQ="---"
					DFE="---"
				endif
			endif	
		endif
		
		IsAllAllRight=1
		if (cmpstr(DFloc,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFInt,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFQ,"---")==0)
			IsAllAllRight=0
		endif
		if (cmpstr(DFE,"---")==0)
			IsAllAllRight=0
		endif
		
		if (IsAllAllRight)
			
		else
			setDataFolder OldDf
			Abort 
		endif
		IR1B_CopyDataLocally()
		IR1B_TrimTheData()
		IR1B_TabPanelControl("xxx",0)
		TabControl DesmearTabs,value= 0, win=IR1B_DesmearingControlPanel
	endif

	
	if (cmpstr(ctrlName,"SaveDataBtn")==0)
		IR1B_SaveData()	
		IR1B_RecordResults()
	endif
	if (cmpstr(ctrlName,"RecalcDSMSmooth")==0)
		NVAR SmoothingParameterDSM=root:Packages:Irena_desmearing:SmoothingParameterDSM
		 IR1B_SliderSmoothDSMData(SmoothingParameterDSM)
		 //IR1B_SaveData()	
	endif
	if (cmpstr(ctrlName,"ExplainSlitGeom")==0)
		 IR1B_ShowSlitGeomBnb()
	endif
	
	
	setDataFolder OldDf
end
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IR1B_ShowSlitGeomBnb()

	String nb = "SlitGeometryExplanation"
	DoWindow $nb
	if(V_Flag)
		DoWindow/F $nb
	else
		NewNotebook/N=$nb/F=0/V=1/K=1/W=(315,114,1025,500)
		Notebook $nb defaultTab=20, statusWidth=252
		Notebook $nb font="Geneva", fSize=10, fStyle=0, textRGB=(0,0,0)
		Notebook $nb text="Slit geometry explanation\r"
		Notebook $nb text="\r"
		Notebook $nb text="The defintion here follows GNOM definition.  But NOTE: the slit parameters are factor of 2 different!!!!"
		Notebook $nb text="\r"
		Notebook $nb text="\r"
		Notebook $nb text="Note, that if your slit is infinitizemaly small (related to the q-step size) small, set the parameter to"
		Notebook $nb text=" 0. \r"
		Notebook $nb text="\r"
		Notebook $nb text="Slit length is in direction perpendicular to the Q direction.\r"
		Notebook $nb text="Slit width is parallel with the slit direction. Note, if your slit width is smaller (or comparable with)"
		Notebook $nb text=" your q steping, use slit width =0. \r"
		Notebook $nb text="\r"
		Notebook $nb text="Beam divergence is assumed to be a rectangular slit geometry  with slit-legth parameters : SlitLegth and"
		Notebook $nb text="\r"
		Notebook $nb text=" SlitLengthL (GNOM parameters AH and AL) as width parameters (GNOM: AW and LW). Therefore, the beam prof"
		Notebook $nb text="ile\r"
		Notebook $nb text="is assumed to be either rectangular (L parameter =0) or trapezoidal (L is not equal to 0).\r"
		Notebook $nb text="\r"
		Notebook $nb text="                            2*SlitLength - 2*SlitLengthL\r"
		Notebook $nb text="                             ********************\r"
		Notebook $nb text="                         *                                                  *\r"
		Notebook $nb text="                     *                                                          *\r"
		Notebook $nb text="                  ******************************\r"
		Notebook $nb text="                              2*SLitLegth + 2*SlitLengthL        \r"
		Notebook $nb text="\r"
		Notebook $nb text=" The units of these parameters must be the same as for the momentum transfer (Q). Most likely A^-1.\r"
		Notebook $nb text="\r"
	endif
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IR1B_SaveData()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Irena_desmearing

	SVAR ExportDataFolderName=root:Packages:Irena_desmearing:ExportDataFolderName
	SVAR ExportIntensityWaveName=root:Packages:Irena_desmearing:ExportIntensityWaveName
	SVAR ExportQWavename=root:Packages:Irena_desmearing:ExportQWavename
	SVAR ExportdQWavename=root:Packages:Irena_desmearing:ExportdQWavename
	SVAR ExportErrorWaveName=root:Packages:Irena_desmearing:ExportErrorWaveName

	if((strlen(ExportDataFolderName)==0) ||(strlen(ExportIntensityWaveName)==0) ||(strlen(ExportQWavename)==0) ||(strlen(ExportErrorWaveName)==0))
		setDataFolder OldDf
		Abort "Bad folder names or bad desmeared wave names"
	endif	

	Wave/Z SMErrors=root:Packages:Irena_desmearing:SMErrors
	Wave/Z OrgIntWave=root:Packages:Irena_desmearing:OrgIntWave
	Wave/Z DesmearedIntWave=root:Packages:Irena_desmearing:DesmearedIntWave
	Wave/Z DesmearedEWave=root:Packages:Irena_desmearing:DesmearedEWave
	Wave/Z DesmearedQWave=root:Packages:Irena_desmearing:DesmearedQWave
	Wave/Z DesmeareddQWave=root:Packages:Irena_desmearing:DesmeareddQWave
	NVAR NumberOfIterations=root:Packages:Irena_desmearing:NumberOfIterations

	Wave/Z SmoothDsmIntWave=root:Packages:Irena_desmearing:SmoothDsmIntWave
	Wave/Z SmoothDsmQWave=root:Packages:Irena_desmearing:SmoothDsmQWave
	Wave/Z SmoothDsmEWave=root:Packages:Irena_desmearing:SmoothDsmEWave
	Wave/Z SmoothDsmdQWave=root:Packages:Irena_desmearing:SmoothDsmdQWave
	
	if(!WaveExists(SMErrors) || !WaveExists(OrgIntWave) || !WaveExists(SmoothDsmIntWave) || !WaveExists(SmoothDsmQWave) ||!WaveExists(SmoothDsmEWave))
		if(!WaveExists(SMErrors) || !WaveExists(OrgIntWave) ||!WaveExists(DesmearedIntWave) ||!WaveExists(DesmearedEWave) ||!WaveExists(DesmearedQWave))
			setDataFolder OldDf
			Abort "Waves do not exist"
		else
			Duplicate DesmearedIntWave, SmoothDsmIntWave
			Duplicate DesmearedQWave, SmoothDsmQWave
			Duplicate DesmearedEWave, SmoothDsmEWave			
			Duplicate/O DesmeareddQWave, SmoothDsmdQWave			
		endif
	endif
	
	IR1B_GetErrors(SmErrors, OrgIntwave, SmoothDsmIntWave, SmoothDsmEWave, SmoothDsmQWave)			//this routine gets the errors
	variable i
	
	if(!DataFolderExists(ExportDataFolderName ))
		string tempFldrName, tempSelectedFile
		setDataFolder root:
		For (i=0;i<ItemsInList(ExportDataFolderName, ":");i+=1)
			tempFldrName = StringFromList(i, ExportDataFolderName , ":")
			if (cmpstr(tempFldrName,"root")!=0)
				NewDataFolder/O/S $IN2G_RemoveExtraQuote(tempFldrName,1,1)
			endif
		endfor
	endif
	setDataFolder root:Packages:Irena_desmearing
	
	string Outwave=ExportDataFolderName+ExportIntensityWaveName
	string OutQwave=ExportDataFolderName+ExportQWavename
	string OutError=ExportDataFolderName+ExportErrorWaveName
	string OutdQ=ExportDataFolderName+ExportdQWaveName
	
	Wave/Z TestInt=$Outwave	
	Wave/Z TestQ=$OutQwave	
	Wave/Z TestE=$OutError	
	
	if (WaveExists(TestInt) || WaveExists(TestQ) ||WaveExists(TestE))
		DoAlert 1, "Data exist, overwrite?"
		if (V_Flag==1)
			Duplicate/O SmoothDsmIntWave, $Outwave	
			Duplicate/O SmoothDsmQWave, $OutQwave
			Duplicate/O SmoothDsmEWave, $OutError
			Duplicate/O SmoothDsmdQWave, $OutdQ
		else
			setDataFolder OldDf
			Abort
		endif
	else
		Duplicate SmoothDsmIntWave, $Outwave	
		Duplicate SmoothDsmQWave, $OutQwave
		Duplicate SmoothDsmEWave, $OutError
		Duplicate SmoothDsmdQWave, $OutdQ
	endif
	
	Wave FitIntensity = $Outwave	
	Wave Qvector = $OutQwave
	Wave DsmError = $OutError
	Wave DsmdQ = $OutdQ
	
	SVAR DataFolderName = root:Packages:Irena_desmearing:DataFolderName
	SVAR IntensityWaveName = root:Packages:Irena_desmearing:IntensityWaveName
	SVAR QWavename = root:Packages:Irena_desmearing:QWavename
	SVAR ErrorWaveName = root:Packages:Irena_desmearing:ErrorWaveName
	SVAR BackgroundFunction = root:Packages:Irena_desmearing:BackgroundFunction
	NVAR SlitLength = root:Packages:Irena_desmearing:SlitLength
	NVAR BckgStartQ = root:Packages:Irena_desmearing:BckgStartQ
	NVAR SmoothSMRData=root:Packages:Irena_desmearing:SmoothSMRData
	NVAR SmoothDSMData=root:Packages:Irena_desmearing:SmoothDSMData
	NVAR SmoothingParameterSMR=root:Packages:Irena_desmearing:SmoothingParameterSMR
	NVAR SmoothingParameterDSM=root:Packages:Irena_desmearing:SmoothingParameterDSM
	NVAR NormalizedChiSquareSMR=root:Packages:Irena_desmearing:NormalizedChiSquareSMR
	NVAR NormalizedChiSquareDSM=root:Packages:Irena_desmearing:NormalizedChiSquareDSM
	SVAR IntensityWaveName=root:Packages:Irena_desmearing:IntensityWaveName

	IN2G_AppendorReplaceWaveNote(Outwave,"DataDesmeared","yes")
	IN2G_AppendorReplaceWaveNote(OutQwave,"DataDesmeared","yes")
	IN2G_AppendorReplaceWaveNote(OutError,"DataDesmeared","yes")

	IN2G_AppendorReplaceWaveNote(Outwave,"DataFolderName",DataFolderName)
	IN2G_AppendorReplaceWaveNote(OutQwave,"DataFolderName",DataFolderName)
	IN2G_AppendorReplaceWaveNote(OutError,"DataFolderName",DataFolderName)
	IN2G_AppendorReplaceWaveNote(Outwave,"IntensityWaveName",IntensityWaveName)
	IN2G_AppendorReplaceWaveNote(OutQwave,"IntensityWaveName",IntensityWaveName)
	IN2G_AppendorReplaceWaveNote(OutError,"IntensityWaveName",IntensityWaveName)
	IN2G_AppendorReplaceWaveNote(Outwave,"QWavename",QWavename)
	IN2G_AppendorReplaceWaveNote(OutQwave,"QWavename",QWavename)
	IN2G_AppendorReplaceWaveNote(OutError,"QWavename",QWavename)
	IN2G_AppendorReplaceWaveNote(Outwave,"ErrorWaveName",ErrorWaveName)
	IN2G_AppendorReplaceWaveNote(OutQwave,"ErrorWaveName",ErrorWaveName)
	IN2G_AppendorReplaceWaveNote(OutError,"ErrorWaveName",ErrorWaveName)


	IN2G_AppendorReplaceWaveNote(Outwave,"BackgroundFunction",BackgroundFunction)
	IN2G_AppendorReplaceWaveNote(OutQwave,"BackgroundFunction",BackgroundFunction)
	IN2G_AppendorReplaceWaveNote(OutError,"BackgroundFunction",BackgroundFunction)

	IN2G_AppendorReplaceWaveNote(Outwave,"Wname",ExportIntensityWaveName)
	IN2G_AppendorReplaceWaveNote(OutQwave,"Wname",ExportQWavename)
	IN2G_AppendorReplaceWaveNote(OutError,"Wname",ExportErrorWaveName)

	IN2G_AppendorReplaceWaveNote(Outwave,"NumberOfIterations",num2str(NumberOfIterations))
	IN2G_AppendorReplaceWaveNote(OutQwave,"NumberOfIterations",num2str(NumberOfIterations))
	IN2G_AppendorReplaceWaveNote(OutError,"NumberOfIterations",num2str(NumberOfIterations))

	IN2G_AppendorReplaceWaveNote(Outwave,"SlitLength",num2str(SlitLength))
	IN2G_AppendorReplaceWaveNote(OutQwave,"SlitLength",num2str(SlitLength))
	IN2G_AppendorReplaceWaveNote(OutError,"SlitLength",num2str(SlitLength))
	IN2G_AppendorReplaceWaveNote(Outwave,"BckgExtrapolationStartQ",num2str(BckgStartQ))
	IN2G_AppendorReplaceWaveNote(OutQwave,"BckgExtrapolationStartQ",num2str(BckgStartQ))
	IN2G_AppendorReplaceWaveNote(OutError,"BckgExtrapolationStartQ",num2str(BckgStartQ))

	if(SmoothSMRData)
		IN2G_AppendorReplaceWaveNote(Outwave,"DataSmoothedBeforeDesmearing","Yes")
		IN2G_AppendorReplaceWaveNote(OutQwave,"DataSmoothedBeforeDesmearing","Yes")
		IN2G_AppendorReplaceWaveNote(OutError,"DataSmoothedBeforeDesmearing","Yes")
		IN2G_AppendorReplaceWaveNote(Outwave,"DataSmoothedBeforeDesmearingParameter",num2str(SmoothingParameterSMR))
		IN2G_AppendorReplaceWaveNote(OutQwave,"DataSmoothedBeforeDesmearingParameter",num2str(SmoothingParameterSMR))
		IN2G_AppendorReplaceWaveNote(OutError,"DataSmoothedBeforeDesmearingParameter",num2str(SmoothingParameterSMR))
		IN2G_AppendorReplaceWaveNote(Outwave,"DataSmoothedBeforeDesmearingChiSq",num2str(NormalizedChiSquareSMR))
		IN2G_AppendorReplaceWaveNote(OutQwave,"DataSmoothedBeforeDesmearingChiSq",num2str(NormalizedChiSquareSMR))
		IN2G_AppendorReplaceWaveNote(OutError,"DataSmoothedBeforeDesmearingChiSq",num2str(NormalizedChiSquareSMR))
	else
		IN2G_AppendorReplaceWaveNote(Outwave,"DataSmoothedBeforeDesmearing","No")
		IN2G_AppendorReplaceWaveNote(OutQwave,"DataSmoothedBeforeDesmearing","No")
		IN2G_AppendorReplaceWaveNote(OutError,"DataSmoothedBeforeDesmearing","No")
	endif
	if(SmoothDSMData)
		IN2G_AppendorReplaceWaveNote(Outwave,"DataSmoothedAfterDesmearing","Yes")
		IN2G_AppendorReplaceWaveNote(OutQwave,"DataSmoothedAfterDesmearing","Yes")
		IN2G_AppendorReplaceWaveNote(OutError,"DataSmoothedAfterDesmearing","Yes")
		IN2G_AppendorReplaceWaveNote(Outwave,"DataSmoothedAfterDesmearingParameter",num2str(SmoothingParameterDSM))
		IN2G_AppendorReplaceWaveNote(OutQwave,"DataSmoothedAfterDesmearingParameter",num2str(SmoothingParameterDSM))
		IN2G_AppendorReplaceWaveNote(OutError,"DataSmoothedAfterDesmearingParameter",num2str(SmoothingParameterDSM))
		IN2G_AppendorReplaceWaveNote(Outwave,"DataSmoothedAfterDesmearingChiSq",num2str(NormalizedChiSquareDSM))
		IN2G_AppendorReplaceWaveNote(OutQwave,"DataSmoothedAfterDesmearingChiSq",num2str(NormalizedChiSquareDSM))
		IN2G_AppendorReplaceWaveNote(OutError,"DataSmoothedAfterDesmearingChiSq",num2str(NormalizedChiSquareDSM))
	else
		IN2G_AppendorReplaceWaveNote(Outwave,"DataSmoothedAfterDesmearing","No")
		IN2G_AppendorReplaceWaveNote(OutQwave,"DataSmoothedAfterDesmearing","No")
		IN2G_AppendorReplaceWaveNote(OutError,"DataSmoothedAfterDesmearing","No")
	endif
	setDataFolder OldDf
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

Function IR1B_RecordResults()

	string OldDF=GetDataFolder(1)
	setdataFolder root:Packages:Irena_desmearing

	SVAR DataFolderName=root:Packages:Irena_desmearing:DataFolderName
	SVAR IntensityWaveName=root:Packages:Irena_desmearing:IntensityWaveName
	SVAR QWavename=root:Packages:Irena_desmearing:QWavename
	SVAR ErrorWaveName=root:Packages:Irena_desmearing:ErrorWaveName
	SVAR BackgroundFunction=root:Packages:Irena_desmearing:BackgroundFunction
	SVAR ExportDataFolderName=root:Packages:Irena_desmearing:ExportDataFolderName
	SVAR ExportIntensityWaveName=root:Packages:Irena_desmearing:ExportIntensityWaveName
	SVAR ExportQWavename=root:Packages:Irena_desmearing:ExportQWavename
	SVAR ExportErrorWaveName=root:Packages:Irena_desmearing:ExportErrorWaveName

	NVAR SlitLength=root:Packages:Irena_desmearing:SlitLength
	NVAR BckgStartQ=root:Packages:Irena_desmearing:BckgStartQ
	NVAR numOfPoints=root:Packages:Irena_desmearing:numOfPoints
	NVAR NumberOfIterations=root:Packages:Irena_desmearing:NumberOfIterations
	NVAR SmoothSMRData=root:Packages:Irena_desmearing:SmoothSMRData
	NVAR SmoothDSMData =root:Packages:Irena_desmearing:SmoothDSMData
	NVAR SmoothingParameterSMR=root:Packages:Irena_desmearing:SmoothingParameterSMR
	NVAR SmoothingParameterDSM=root:Packages:Irena_desmearing:SmoothingParameterDSM
	NVAR NormalizedChiSquareSMR=root:Packages:Irena_desmearing:NormalizedChiSquareSMR
	NVAR NormalizedChiSquareDSM=root:Packages:Irena_desmearing:NormalizedChiSquareDSM
	NVAR DesmearFastOnly=root:Packages:Irena_desmearing:DesmearFastOnly
	NVAR DesmearSlowOnly=root:Packages:Irena_desmearing:DesmearSlowOnly
	NVAR DesmearCombo=root:Packages:Irena_desmearing:DesmearCombo
	NVAR DesmearSwitchOverVal=root:Packages:Irena_desmearing:DesmearSwitchOverVal
	NVAR DesmearDampen=root:Packages:Irena_desmearing:DesmearDampen
	NVAR DesmearAutomaticaly=root:Packages:Irena_desmearing:DesmearAutomaticaly
	NVAR DesmearAutoTargChisq=root:Packages:Irena_desmearing:DesmearAutoTargChisq
	//NVAR =root:Packages:Irena_desmearing:DesmearNIterationsTarget
	Wave QW=root:Packages:Irena_desmearing:SmoothDsmQWave
	variable MinQ, MaxQ
	WaveStats/Q QW
	MinQ=V_min
	MaxQ=V_max
	IR1_CreateLoggbook()		//this creates the logbook
	SVAR nbl=root:Packages:SAS_Modeling:NotebookName

	IR1L_AppendAnyText("     ")
	IR1L_AppendAnyText("***********************************************")
	IR1L_AppendAnyText("***********************************************")
	IR1L_AppendAnyText("Data desmearing record ")
	IR1_InsertDateAndTime(nbl)
	IR1L_AppendAnyText("Input data names \t")
	IR1L_AppendAnyText("\t\tFolder \t\t"+ DataFolderName)
	IR1L_AppendAnyText("\t\tIntensity/Q/errror wave names \t"+ IntensityWaveName+"\t"+QWavename+"\t"+ErrorWaveName)

	IR1L_AppendAnyText("Extrapolation function used : \t"+BackgroundFunction)
	IR1L_AppendAnyText("Background extrapolated from : \t"+num2str(BckgStartQ))
	IR1L_AppendAnyText("Number of poitns used :\t \t"+num2str(numOfPoints))
	IR1L_AppendAnyText("Minimum Q used ="+num2str(MinQ)+"\t\tMaximum Q used = "+num2str(MaxQ))

	IR1L_AppendAnyText("SlitLength : \t\t\t"+num2str(SlitLength))

	if(DesmearFastOnly)
		IR1L_AppendAnyText("Used Desmear fast method")
	elseif(DesmearSlowOnly)
		IR1L_AppendAnyText("Used Desmear slow method")
	elseif(DesmearCombo)
		IR1L_AppendAnyText("Used Combination Desmear method, switch over value used = "+num2str(DesmearSwitchOverVal))
	elseif(DesmearDampen)
		IR1L_AppendAnyText("Used Dampen Desmear method")
	elseif(DesmearAutomaticaly)
		IR1L_AppendAnyText("Used Automatic Desmear method, target Chi square was "+num2str(DesmearAutoTargChisq))
	endif

	IR1L_AppendAnyText("Number of iterations used : \t"+num2str(NumberOfIterations))
	
	if(SmoothSMRData)
		IR1L_AppendAnyText("Smeared data smoothed before desmearing with smoothing parameter =\t"+num2str(SmoothingParameterSMR))
		IR1L_AppendAnyText("Smoothing Chi-squared achieved =\t"+num2str(NormalizedChiSquareSMR))
	endif
	if(SmoothDSMData)
		IR1L_AppendAnyText("Desmeared data smoothed after desmearing with smoothing parameter =\t"+num2str(SmoothingParameterDSM))
		IR1L_AppendAnyText("Smoothing Chi-squared achieved =\t"+num2str(NormalizedChiSquareDSM))
	endif

	IR1L_AppendAnyText("\tOutput data names :")
	IR1L_AppendAnyText("\t\tFolder \t\t"+ ExportDataFolderName)
	IR1L_AppendAnyText("\t\tIntensity/Q/errror wave names \t"+ ExportIntensityWaveName+"\t"+ExportQWavename+"\t"+ExportErrorWaveName)
	IR1L_AppendAnyText(" ")
	

	IR1L_AppendAnyText("***********************************************")

	setdataFolder oldDf
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
Function IR1B_GetErrors(SmErrors, SmIntensity, FitIntensity, DsmErrors, Qvector)		//calculates errors using Petes formulas
	wave SmErrors, SmIntensity, FitIntensity, DsmErrors, Qvector
	
	Silent 1	
	
	DsmErrors=FitIntensity*(SmErrors/SmIntensity)						//error proportional to input data
	WAVE W_coef=W_coef
	variable i=1, imax=numpnts(FitIntensity)
	Redimension/N=(numpnts(FitIntensity)) DsmErrors
	Do
		if( (numtype(FitIntensity[i-1])==0) && (numtype(FitIntensity[i])==0) && (numtype(FitIntensity[i+1])==0) )
			CurveFit/Q line, FitIntensity (i-1, i+1) /X=Qvector				//linear function here 
			DsmErrors[i]+=abs(W_coef[0]+W_coef[1]*Qvector[i] - FitIntensity[i])	//error due to scatter of data
		endif
	i+=1
	while (i<imax-1)

	DsmErrors[0]=DsmErrors[1]									//some error needed for 1st point
	DsmErrors[imax-1]=DsmErrors[imax-2]								//and error for last point	

	Smooth /E=2 3, DsmErrors
	
end

//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************
//***********************************************************************************************************************************

