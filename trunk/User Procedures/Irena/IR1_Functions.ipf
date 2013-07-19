#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 2.04

//*************************************************************************\
//* Copyright (c) 2005 - 2013, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.01 added license for ANL
//2.02 modified by adding Shultz-Zimm distribution, JIL, 3/17/2011
//2.03 changed min size to 1A sicne many users are using really high q data. 
//2.04 added IR2R_InsertRemoveLayers in the KillAllPanels

//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from usaxs.xray.aps.anl.gov/
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky,  2010

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov

//this file contains distribution related functions, at this time
// there are three type of distributions: LSW (Pete's request), LogNormal and Gauss (Normal)
//each requires 3 parameters, but LSW uses only the location, Normal uses two - location and scale (=width)
//only Log-normal uses all three - location, scale and shape. But all three require the three parametser - for simplicity
//Each distribution has two forms - probability distribution and cumulative distribution
//finaly, there is function used to generate distribution of diameters for each of the distributions. Lot of parameters, see the function

//Log-Normal and Normal (here called Gauss) distributions defined by NIST Engineering Statistics Handbook (http://www.itl.nist.gov/div898/handbook/index.htm)
//LSW distribution, based on Lifshitz, Slyozov, and Wagner theory as used in paper by Naser, Kuruvilla, and Smith: Compositional Effects
// on Grain Growth During Liquid Phase Sintering in Microgravity, found on web site www.space.gc.ca/science/space_science/paper_reports/spacebound97/materials_science....


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//****************   LSW   ***********************************************************
Function IR1_LSWProbability(x,location,scale, shape)
		variable x, location,scale, shape
	//this function calculates probability for LSW distribution
	
	variable result, reducedX
	
	reducedX=x/location
	
	result=(81/(2^(5/3))) * (reducedX^2 * exp(-1*(reducedX/(1.5-reducedX) ) ) ) / ( (1.5-reducedX)^(11/3) * (3+reducedX)^(7/3) )
	
	//this funny distribution reaches values (integral under the curve) of location
	//so we need to renormalize...

	if (numtype(result)!=0)
		result=0
	endif
	
	return result/location

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_LSWCumulative(xx,location,scale, shape)
		variable xx, location,scale, shape
	//this function calculates probability for LSW distribution
	//I do not have cumulative probability function, so it is done numerically... More complex and much more annoying...
	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SAS_Modeling
			
	variable result, pointsNeeded=ceil(xx/30+30)
	//points neede is at least 30 and max out around 370 for 10000 A location
	make/D /O/N=(PointsNeeded) temp_LSWwav 
	
	SetScale/P x 10,(xx/(numpnts(temp_LSWwav)-3)),"", temp_LSWwav	
	//this sets scale so the model wave x scale covers area from 10 A over the needed point...
	
	temp_LSWwav=IR1_LSWProbability(pnt2x(temp_LSWwav, p ),location,scale, shape)
	
	integrate /T temp_LSWwav
	//and at this point the temp_LSWwav has integral values in it... 
	result = temp_LSWwav(xx) //here we get the value interpolated (linearly) for the needed point...
	KillWaves temp_LSWwav
	setDataFolder OldDf
	return result
end

 

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//****************   Normal (Gauss) distribution   ***********************************************************

Function IR1_GaussProbability(x,location,scale, shape)
		variable x, location,scale, shape
	//this function calculates probability for Gauss (normal) distribution
	
	variable result
	
	result=(exp(-((x-location)^2)/(2*scale^2)))/(scale*(sqrt(2*pi)))

	if (numtype(result)!=0)
		result=0
	endif
	
	return result
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_SchulzZimmProbability(x,MeanPos,Width, shape)
		variable x, MeanPos,Width, shape
	//this function calculates probability for Schulz-Zimm distribution
	//finished 3/17/2011, seems to work.  
	variable result, a, b
	
	b = 1/(width/(2*MeanPos))^2
	a = b / MeanPos
	
	if(b<70)
		result=( (a^(b+1))/gamma(b+1) * x^b / exp(a*x) )
	else			//do it in logs to avoid large numbers
		result=exp(    (b+1)*ln(a)-  gammln(b+1) + B*ln(x) - (a*x) )
	endif

	if (numtype(result)!=0)
		result=0
	endif
	
	return result
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_SZCumulative(xpos,location,scale, shape)
	variable xpos, location,scale, shape
	//this function calcualtes cumulative probabliltiy for SZ distribution
	//until I find the formula for SZ I will use numberical method, slower but should work... 
	
	variable result
	Make/O/N=500 tempSZDistWv
	SetScale/I x 0,xpos,"", tempSZDistWv
	tempSZDistWv =  IR1_SchulzZimmProbability(x,location,scale, shape)
//	doupdate
	result = area(tempSZDistWv  )
	KillWaves/Z tempSZDistWv
	return result
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_GaussCumulative(x,location,scale, shape)
	variable x, location,scale, shape
	//this function calcualtes cumulative probabliltiy for gauss (normal) distribution
	
	variable result, ReducedX
	
	ReducedX=(x-location)/scale
	
	result = (erf(ReducedX/sqrt(2))+1)/2
	
	return result
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_PowerLawCumulative(x, shape,startx,endx)
	variable x, endx,startx, shape
	//this function calculates cumulative probability for log-normal distribution
	
	variable result
	
	Make/O/N=1000 TempCumWv
	SetScale/I x startx, endx, TempCumWv
	TempCumWv = x^(-(7-shape))
	
	result = area(TempCumWv,startx, x)/area(TempCumWv,startx, endx)
	KillWaves TempCumWv

	return result


end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_PowerLawProbability(x, shape,diameterswv)
	variable x,  shape
	wave diameterswv
	
	//this function calculates cumulative probability for log-normal distribution
	duplicate/O diameterswv, tempCalcWvPowerLaw
	
	variable result
	
	tempCalcWvPowerLaw =  diameterswv^(-(7-shape))
	result =  (x^(-(7-shape))) / areaXY(diameterswv, tempCalcWvPowerLaw, 0, inf )
	killwaves/Z tempCalcWvPowerLaw
	
	return result


end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


//****************   Log-Normal distribution   ***********************************************************

Function IR1_LogNormProbability(x,location,scale, shape)
	variable x, location, scale, shape
	//this function calculates probability for log-normal distribution
	
	variable result
	
	result = exp(-1*( ln( (x-location) / scale) )^2 / (2*shape^2) ) / (shape*sqrt(2*pi)*(x-location))
	if (numtype(result)!=0)
		result=0
	endif
	return result	
end	



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_LogNormCumulative(x,location,scale, shape)
	variable x, location, scale, shape
	//this function calculates cumulative probability for log-normal distribution
	
	variable result, ReducedX
	
	ReducedX=(x-location)/scale
	
	result = (erf((ln(ReducedX)/shape)/sqrt(2))+1)/2
	if(numtype(result)!=0)
		result=0
	endif

	return result
end



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1S_UpdateModeMedianMean()

	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
	
	variable i
	For (i=1;i<=NumberOfDistributions;i+=1)
		IR1S_UpdtSeparateMMM(i)
	endfor
end



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1S_UpdtSeparateMMM(distNum)
	Variable distNum

	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SAS_Modeling

	NVAR DistMean=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Mean")
	NVAR DistMedian=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Median")
	NVAR DistMode=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Mode")
	NVAR DistLocation=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Location")
	NVAR DistScale=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Scale")
	NVAR DistShape=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Shape")
	NVAR DistFWHM=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"FWHM")
	SVAR DistDistributionType=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"DistributionType")
	NVAR UseNumberDistribution=root:Packages:SAS_Modeling:UseNumberDistribution

	Wave Distdiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"diameters")
	
	Duplicate/O Distdiameters, Temp_Probability, Temp_Cumulative, Another_temp
	Redimension/D Temp_Probability, Temp_Cumulative, Another_temp
		if (cmpstr(DistDistributionType,"LogNormal")==0)
			Temp_Probability=IR1_LogNormProbability(Distdiameters,DistLocation,DistScale, DistShape)
			Temp_Cumulative=IR1_LogNormCumulative(Distdiameters,DistLocation,DistScale, DistShape)
		endif
		if (cmpstr(DistDistributionType,"Gauss")==0)
			Temp_Probability=IR1_GaussProbability(Distdiameters,DistLocation,DistScale, DistShape)
			Temp_Cumulative=IR1_GaussCumulative(Distdiameters,DistLocation,DistScale, DistShape)
		endif
		if (cmpstr(DistDistributionType,"LSW")==0)
			Temp_Probability=IR1_LSWProbability(Distdiameters,DistLocation,DistScale, DistShape)
			Temp_Cumulative=IR1_LSWCumulative(Distdiameters,DistLocation,DistScale, DistShape)
		endif
		if (cmpstr(DistDistributionType,"PowerLaw")==0)
			Temp_Probability=NaN
			Temp_Cumulative=NaN
		endif

	
		Another_temp=Distdiameters*Temp_Probability
		DistMean=areaXY(Distdiameters, Another_temp,0,inf)					//Sum P(R)*R*deltaR
		DistMedian=Distdiameters[BinarySearchInterp(Temp_Cumulative, 0.5 )]		//R for which cumulative probability=0.5
		FindPeak/P/Q Temp_Probability
		DistMode=Distdiameters[V_PeakLoc]								//location of maximum on the P(R)
		
		DistFWHM=IR1_FindFWHM(Temp_Probability,Distdiameters)				//Ok, this is monkey approach

		if (cmpstr(DistDistributionType,"PowerLaw")==0)
			DistFWHM=NaN
			DistMode=NaN
			DistMedian=NaN
			DistMean=NaN
		endif
	DoWindow IR1S_ControlPanel
	if (V_Flag)
		SetVariable $("DIS"+num2str(distNum)+"_Mode"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Mode"), format="%.1f", win=IR1S_ControlPanel 
		SetVariable $("DIS"+num2str(distNum)+"_Median"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Median"), format="%.1f", win=IR1S_ControlPanel 
		SetVariable $("DIS"+num2str(distNum)+"_Mean"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Mean"), format="%.1f", win=IR1S_ControlPanel 
		SetVariable $("DIS"+num2str(distNum)+"_FWHM"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"FWHM"), format="%.1f", win=IR1S_ControlPanel 
	endif
	DoWindow IR1U_ControlPanel
	if (V_Flag)
		SetVariable $("DIS"+num2str(distNum)+"_Mode"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Mode"), format="%.1f", win=IR1U_ControlPanel 
		SetVariable $("DIS"+num2str(distNum)+"_Median"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Median"), format="%.1f", win=IR1U_ControlPanel 
		SetVariable $("DIS"+num2str(distNum)+"_Mean"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Mean"), format="%.1f", win=IR1U_ControlPanel 
		SetVariable $("DIS"+num2str(distNum)+"_FWHM"),value= $("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"FWHM"), format="%.1f", win=IR1U_ControlPanel 
	endif
	
	
	KillWaves/Z Temp_Probability, Temp_Cumulative, Another_Temp

	setDataFolder OldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1_FindFWHM(IntProbWave,DiaWave)
	wave IntProbWave,DiaWave

//	string OldDf=GetDataFolder(1)
//	SetDataFolder root:Packages:SAS_Modeling

	wavestats/Q IntProbWave
	
	variable maximum=V_max
	variable maxLoc=V_maxLoc
	Duplicate/O/R=[0,maxLoc] IntProbWave, temp_wv1
	Duplicate/O/R=[0,maxLoc] DiaWave, temp_RWwv1
	
	Duplicate/O/R=[maxLoc, numpnts(IntProbWave)-1] IntProbWave temp_wv2
	Duplicate/O/R=[maxLoc, numpnts(IntProbWave)-1] DiaWave, temp_RWwv2
	
	variable MinD=temp_RWwv1[BinarySearchInterp(temp_wv1, (maximum/2) )]
	variable MaxD=temp_RWwv2[BinarySearchInterp(temp_wv2, (maximum/2) )]
	KillWaves/Z temp_wv2, temp_wv1,temp_RWwv1,temp_RWwv2

//	setDataFolder OldDf
	
	return abs(MaxD-MinD)
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//****************   This calculates distribution of diameters and needed for the probability distribution   ***********************************************************

Function IR1_GenerateDiametersDist(MyFunction, OutputWaveName, numberOfPoints, myprecision, location,scale, shape)
	string MyFunction, OutputWaveName
	variable numberOfPoints, myprecision, location,scale, shape
	//
	//  Important : this wave will be produced in current folder
	//
	//this function generates non-regular distribution of diameters for distributions
	//Myfunction can now be Gauss, LSW, or LogNormal
	//OutputWaveName is string with wave name. The wave is created with numberOfPoints number of points and existing one, if exists, is overwritten
	// my precision is value (~0.001 for example) which denotes how low probability we want to neglect (P<precision and P>(1-precision) are neglected
	//location, scale, shape are values for the probability distributions
	
	//logic: we start in the median and walk towards low (high) values. When cumulative value is smaller (larger) than precision (1-precision)
	//we end. If we walk out of reasonable values (10A and 10^15A), we stop.
	
	//first we need to find step, which we will use to step from median
	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SAS_Modeling


	variable startx, endx, guess, Step, mode, tempVal, tempResult
	
	if (cmpstr("Gauss",MyFunction)==0)
		Step=scale*0.02					//standard deviation
	endif
	if (cmpstr("LSW",MyFunction)==0)
		Step=location*0.3				//just some step for this distribution
	endif
	if (cmpstr("LogNormal",MyFunction)==0)
		Step=4*sqrt(exp(shape^2)*(exp(shape^2)-1))	//standard deviation
	endif
	if (cmpstr("PowerLaw",MyFunction)==0)
		Step=500	//a number here
	endif
	
	//now we need to find the median

	if (cmpstr("Gauss",MyFunction)==0)
		mode=location	//=median
	endif
	if (cmpstr("LSW",MyFunction)==0)
		mode=location	//close to median, who really cares where we start as long as it is close...
	endif
	if (cmpstr("LogNormal",MyFunction)==0)
		mode=location+scale/(exp(shape^2))	//=median
	endif
	if (cmpstr("PowerLaw",MyFunction)==0)
		mode=500  				// a number
	endif
	// look for minimum
	//now we can start at median and go step by step and end when the 
	//cumulative function is smaller than the myprecision
	
	variable minimumXPossible=1   //if it should be smaller than 2A, it is nonsence...
	
	tempVal=mode
	
	do
		tempVal=tempVal-Step			//OK, this way we should make always one more step over the limit...

		if (tempVal<minimumXPossible)
			tempVal=minimumXPossible
		endif

		if (cmpstr("Gauss",MyFunction)==0)
			tempResult=IR1_GaussCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("LSW",MyFunction)==0)
			tempResult=IR1_LSWCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("LogNormal",MyFunction)==0)
			tempResult=IR1_LogNormCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("PowerLaw",MyFunction)==0)		//this funny function exists over whole size range possible....
			tempResult=0
			tempVal=minimumXPossible
		endif
		
	while ((tempResult>myprecision)&&(tempVal>minimumXPossible))			

	startx = tempVal
	//and this will be needed lower, in case when we have distributions attempting to get into negative diameters...
	variable startCumTrgts=myprecision
	if (startx==minimumXPossible)	//in this case we run into negative values and overwrote the startX values
			if (cmpstr("Gauss",MyFunction)==0)
				startCumTrgts=IR1_GaussCumulative(minimumXPossible,location,scale, shape)
			endif
			if (cmpstr("LSW",MyFunction)==0)
				startCumTrgts=IR1_LSWCumulative(minimumXPossible,location,scale, shape)
			endif
			if (cmpstr("LogNormal",MyFunction)==0)
				startCumTrgts=IR1_LogNormCumulative(minimumXPossible,location,scale, shape)
			endif
			if (cmpstr("PowerLaw",MyFunction)==0)
				startCumTrgts=myprecision
			endif
	endif

	//now we need to calculate the endx

	variable maximumXPossible=1e15	//maximum, fixed for giant number due to use of the code for light scattering
		
	tempVal=mode
	
	do
		tempVal=tempVal+Step		//again, whould be one step larger than needed...
		if (tempVal>maximumXPossible)
			tempVal=maximumXPossible
		endif

		if (cmpstr("Gauss",MyFunction)==0)
			tempResult=IR1_GaussCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("LSW",MyFunction)==0)
			tempResult = 1
			tempVal = 1.5 * location //this distribution does not exist over this value...
		endif
		if (cmpstr("LogNormal",MyFunction)==0)
			tempResult=IR1_LogNormCumulative(tempVal,location,scale, shape)
		endif
		if (cmpstr("PowerLaw",MyFunction)==0)
			maximumXPossible=1e7
			tempResult=1
			tempVal=maximumXPossible
		endif

	while ((tempResult<(1-myprecision))&&(tempVal<maximumXPossible))			
	
	endx = tempVal

	//and now we can start making the the data. 
	// First we will create a wave with equally distributed values between myprecision and 1-myprecision : Temp_CumulTargets
	//We will also create waves with 3*as many points with diameters between startx and endx (Temp_diameters) and with appropriate cumulative distribution (Temp_CumulativeWave)
	//then we will look for which diameters we get the cumulative numbers in Temp_CumulTargets and put these in output wave
	
	Make/D /N=(numberOfPoints) /O Temp_CumulTargets, $OutputWaveName
	Make/D /N=(3*numberOfPoints) /O Temp_CumulativeWave,Temp_diameters
	
	Wave DistributiondiametersWave=$OutputWaveName
	
	Temp_diameters=startx+p*(endx-startx)/(3*numberOfPoints-1)			//this puts the proper diameters distribution in the temp diameters wave
	
	Temp_CumulTargets=startCumTrgts+p*(1-myprecision-startCumTrgts)/(numberOfPoints-1) //this puts equally spaced values between myprecision and (1-myprecision) in this wave
	
	//calculate the cumulative waves
	if (cmpstr("Gauss",MyFunction)==0)
		Temp_CumulativeWave=IR1_GaussCumulative(Temp_diameters,location,scale, shape)
	endif
	if (cmpstr("LSW",MyFunction)==0)
		Temp_CumulativeWave=IR1_LSWCumulative(Temp_diameters,location,scale, shape)
		Temp_CumulativeWave[numpnts(Temp_CumulativeWave)-1]=1	//last point is NaN, we need to make it 1
	endif
	if (cmpstr("LogNormal",MyFunction)==0)
		Temp_CumulativeWave=IR1_LogNormCumulative(Temp_diameters,location,scale, shape)
	endif
	if (cmpstr("PowerLaw",MyFunction)==0)
		Temp_CumulativeWave=IR1_PowerLawCumulative(Temp_diameters,shape,startx,endx)
	endif
	
		//and now the difficult part - get the diameterss, which are unequally spaced, but whose probability for the distribution are equally spaced...
		DistributionDiametersWave=interp(Temp_CumulTargets, Temp_CumulativeWave, Temp_diameters )
	variable temp
	if (cmpstr("PowerLaw",MyFunction)==0) //the code above fails for this distribution type, we need to create new diameters...
		//DistributionDiametersWave=startx+log(p)*(endx-startx)/log(numberOfPoints)
		//temp=log(startx)+p*((log(endx)-log(startx))/(numberOfPoints-1))
		DistributionDiametersWave=10^(log(startx)+p*((log(endx)-log(startx))/(numberOfPoints-1)))
	endif

	
	//and now cleanup
	
	KillWaves/Z Temp_CumulTargets //, myTest
	KillWaves/Z Temp_CumulativeWave,Temp_diameters

	setDataFolder OldDf
	
end



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

//**********************************************************************************************************

Function IR1_KillGraphsAndPanels()



	String ListOfWindows
	ListOfWindows = "UnivDataExportPanel;TempExportGraph;ExportNoteDisplay;IR1G_OneSampleEvaluationGraph;MIPDataGraph;IR2D_LogLogPlotSAD;"
	ListOfWindows += "IR2D_ControlPanel;IR2H_SI_Q2_PlotGels;IR2H_IQ4_Q_PlotGels;IR2H_LogLogPlotGels;IR2H_ControlPanel;Shape_Model_Input_Panel;"
	ListOfWindows += "IR1S_InterferencePanel;IR1K_AnomCalcPnl;IR1G_OneSampleEvaluationGraph;IR1K_ScatteringContCalc;IR1F_CreateQRSFldrStructure;"
	ListOfWindows += "IR1B_DesmearingControlPanel;TrimGraph;SmoothGraph;CheckTheBackgroundExtns;DesmearingProcess;SmoothGraphDSM;"
	ListOfWindows += "IR1Y_ScatteringContrastPanel;About_Irena_1_Macros;IR1R_SizesInputPanel;IR1_LogLogPlotU;IR1_LogLogPlotLSQF;IR1P_ChangeGraphDetailsPanel;"
	ListOfWindows += "IR1_IQ4_Q_PlotU;IR1_IQ4_Q_PlotLSQF;IR1_Model_Distributions;IR1S_ControlPanel;IR1P_ControlPanel;IR1U_ControlPanel;"
	ListOfWindows += "IR1A_ControlPanel;IR1R_SizesInputGraph;IR1P_PlottingTool;GeneralGraph;IR1P_ControlPanel;IR1P_RemoveDataPanel;"
	ListOfWindows += "IR1P_ModifyDataPanel;IR1P_RemoveDataPanel;IR1P_StoreGraphsCtrlPnl;IR1D_DataManipulationPanel;IR1D_DataManipulationGraph;"
	ListOfWindows += "IR1I_ImportData;IR1V_ControlPanel;IR1V_LogLogPlotV;IR1V_IQ4_Q_PlotV;IR2S_ScriptingToolPnl;IR2Pr_PDFInputGraph;IR2Pr_ControlPanel;"
	ListOfWindows += "PlotingToolWaterfallGrph;LSQF2_MainPanel;LSQF_MainGraph;GraphSizeDistributions;LSQF_ResidualsGraph;Irena_Gizmo;GizmoControlPanel;"
	ListOfWindows += "DataMiningTool;ItemsInFolderPanel;ItemsInFolderPanel_DMII;DataManipulationII;IR2R_InsertRemoveLayers;PlotingToolContourGrph;"
	variable i
	string TempNm
	For(i=0;i<ItemsInList(ListOfWindows);i+=1)
		TempNm = stringFromList(i,ListOfWindows)
		DoWindow $TempNm
		if (V_Flag)
			DoWindow/K $TempNm	
		endif
	endfor
end