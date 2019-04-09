#pragma rtGlobals = 3	// Use strict wave reference mode and runtime bounds checking
//#pragma rtGlobals=21	// Use modern global access method.
#pragma version=2.11

//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.11 fixed some bugs in find FWHM IR1G_FindFWHM(IntProbWave,DiaWave, StartP, EndP)
//2.10 fixed operations for case when user uses Modeling II (now MOdeling) cdata and used not first, but later pop for Size distribution. Needed to build in skipping of non-size distribution cases...
//2.09  removed unused functions
//2.08 added getHelp button calling to www manual
//2.07 minor fix for parameter6 of form factor parameter. 
//2.06 removed Executes as preparation for Igor 7
//2.05 modified IR1G_CreateAveVolSfcWvUsingNote by cleaning up unneeded code. 
//2.04 some improvements to handle radii and diameters. 
//2.03  Modified all controls not to define font and font size to enable proper control by user 
//2.02 modified display to show "size" instead of diameter, Modeling II is using radii, so the results are in readii. Also, need to fix the absolute calibrations sometimes...
//2.01 added license for ANL

//part of Irena macros.
//evaluation graph for ONE sample only... Complex way to get to do some statistics...
//all variables and strings start with GR1_ ...



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1G_EvaluateONESample()

	IN2G_CheckScreenSize("height",700)
	IN2G_CheckScreenSize("width",950)
	//initialize
	IR1G_IniEvaluationGraph()
	//create graph
	KillWIndow/Z IR1G_OneSampleEvaluationGraph
	Execute("IR1G_OneSampleEvaluationGraph()")
	SetWindow IR1G_OneSampleEvaluationGraph, hook(named)=IRG1_MainHookFunction
		//now set the checkboxes for appropriate number of distributions fitted
	IR1G_SetProperlyTheCheckboxes()
	
	
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IRG1_MainHookFunction(H_Struct)
    STRUCT WMWinHookStruct &H_Struct
    variable i
    
    if (h_struct.eventCode==7 && stringMatch(h_struct.winName,"IR1G_OneSampleEvaluationGraph"))
	//    print h_struct.eventCode, h_struct.winName
		string oldDf=GetDataFolder(1)
		setDataFolder root:Packages:SASDataEvaluation
				string Values=""
				string WvNote=""
		
		NVAR GR1_AutoUpdate=root:Packages:SASDataEvaluation:GR1_AutoUpdate
		if(GR1_AutoUpdate)
			IR1G_CalculateStatistics()
			IR1G_ResetGraphAfterChanges()
		endif
		variable NumOfPops=IR1G_FindNumOfPopsUsed(CsrWaveRef(A))		
		if(NumOfPops>0 && NumOfPops<6)
				Values=""
				WvNote=note(CsrWaveRef(A))
				For(i=1;i<=NumOfPops;i+=1)
					Values+=num2str(i)+": "+StringByKey("Dist"+num2str(i)+"ShapeModel", WvNote, "=" , ";" ) +";"
				endfor
				Values+="\""+Values+"\""
				PopupMenu EvaluatePopulationNumber win=IR1G_OneSampleEvaluationGraph, value=#Values, disable=0
		elseif(NumOfPops==6)
				Values=""
				WvNote=note(CsrWaveRef(A))
				For(i=1;i<=NumOfPops;i+=1)
					if(NumberByKey("UseThePop_pop"+num2str(i), WvNote , "=" , ";"))
						if(strlen(StringByKey("FormFactor_pop"+num2str(i), WvNote, "=" , ";" ))>2)		//this removes non-size distribution cases, like Unified fit etc. 
							Values+=num2str(i)+": "+StringByKey("FormFactor_pop"+num2str(i), WvNote, "=" , ";" ) +";"
						endif
					else
						//Values+=num2str(i)+": "+"The population not used +";"
					endif
				endfor
				Values ="\""+Values+"\""
				PopupMenu EvaluatePopulationNumber win=IR1G_OneSampleEvaluationGraph, value=#Values, disable=0
		else
				PopupMenu EvaluatePopulationNumber win=IR1G_OneSampleEvaluationGraph, value=#("\""+num2str(abs(NumOfPops))+"\""), disable=2
				//PopupMenu EvaluatePopulationNumber value=num2str(abs(NumPops)), disable=2
		endif
		NVAR OldACursorPosition=root:Packages:SASDataEvaluation:OldACursorPosition
		NVAR OldBCursorPosition=root:Packages:SASDataEvaluation:OldBCursorPosition
		Wave/Z WxA=CsrXWaveRef(A)
		Wave/Z WxB=CsrXWaveRef(B)
		if(WaveExists(WxA))
			OldACursorPosition=WxA[pcsr(A)]
		endif
		if(WaveExists(WxB))
			OldBCursorPosition=WxB[pcsr(B)]
		endif
//		print OldACursorPosition, OldBCursorPosition
		setDataFolder oldDf
	endif
    return 0        // 0 if nothing done, else 1
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_AppendTag()

	NVAR GR1_Mean=root:Packages:SASDataEvaluation:GR1_Mean
	NVAR GR1_Mode=root:Packages:SASDataEvaluation:GR1_Mode
	NVAR GR1_Median=root:Packages:SASDataEvaluation:GR1_Median
	NVAR GR1_diameterMin=root:Packages:SASDataEvaluation:GR1_diameterMin
	NVAR GR1_diameterMax=root:Packages:SASDataEvaluation:GR1_diameterMax
	NVAR GR1_Volume=root:Packages:SASDataEvaluation:GR1_Volume
	NVAR GR1_NumberDens=root:Packages:SASDataEvaluation:GR1_NumberDens
	NVAR GR1_PorodSurface=root:Packages:SASDataEvaluation:GR1_PorodSurface
	NVAR GR1_FWHM=root:Packages:SASDataEvaluation:GR1_FWHM
	SVAR GR1_NumberOrVolumeDist=root:Packages:SASDataEvaluation:GR1_NumberOrVolumeDist

		//first lets check, that we have both cursors in the graph and they are on the same wave
	DoWindow/F IR1G_OneSampleEvaluationGraph
	string CsrAwaveName=CsrWave(A, "IR1G_OneSampleEvaluationGraph",1)
	string CsrBwaveName=CsrWave(B, "IR1G_OneSampleEvaluationGraph",1)
	
	IR1G_CalculateStatistics()

	//in these cases we need to stop and not progress

	if (strLen(CsrAwaveName)==0)
		DoAlert 0, "Cursor A not on in the graph"
		abort
	endif
	if (strLen(CsrBwaveName)==0)
		DoAlert 0, "Cursor A not on in the graph"
		abort
	endif
	if (cmpstr(CsrAwaveName,CsrBwaveName)!=0)
		DoAlert 0, "Cursors not on the same data"
		abort
	endif
	variable startP=pcsr(A)
	variable endP=pcsr(B)
	variable pos=StartP+0.5*abs(endP-StartP)
	string TagName=UniqueName("TagNm", 14, 0, "IR1G_OneSampleEvaluationGraph")
	
	string TextString="\Z12Selected data range: "+num2str(GR1_diameterMin)+"  :  "+num2str(GR1_diameterMax)+"  [A] \r"
	TextString+="Data :"+GR1_NumberOrVolumeDist+"\r"
	TextString+="Mean = "+Num2str(GR1_Mean)+"\tMode = "+num2str(GR1_Mode)+" [A]\r"
	TextString+="Median = "+Num2str(GR1_Median)+"\tFWHM = "+num2str(GR1_FWHM) +" [A]\r"
	TextString+="Number of scatterers = "+Num2str(GR1_NumberDens)+" [1/cm3] \r"
	TextString+="Volume of scatterers = "+Num2str(GR1_Volume)+" [cm3/cm3] \r"
	TextString+="Surface of scatterers = "+Num2str(GR1_PorodSurface)+" [cm2/cm3] (if meaningful)"
	
	
	Tag/C/F=2/L=1/N=$(TagName)/S=3 $(CsrAwaveName), pos, TextString


end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_CalculateStatistics()

	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SASDataEvaluation

	NVAR GR1_Mean=root:Packages:SASDataEvaluation:GR1_Mean
	NVAR GR1_Mode=root:Packages:SASDataEvaluation:GR1_Mode
	NVAR GR1_Median=root:Packages:SASDataEvaluation:GR1_Median
	NVAR GR1_diameterMin=root:Packages:SASDataEvaluation:GR1_diameterMin
	NVAR GR1_diameterMax=root:Packages:SASDataEvaluation:GR1_diameterMax
	NVAR GR1_Volume=root:Packages:SASDataEvaluation:GR1_Volume
	NVAR GR1_NumberDens=root:Packages:SASDataEvaluation:GR1_NumberDens
	NVAR GR1_PorodSurface=root:Packages:SASDataEvaluation:GR1_PorodSurface
	NVAR GR1_FWHM=root:Packages:SASDataEvaluation:GR1_FWHM
	NVAR CalcMIPdata=root:Packages:SASDataEvaluation:CalcMIPdata
	NVAR InvertCumulativeDists=root:Packages:SASDataEvaluation:InvertCumulativeDists
	NVAR CalcCumulativeSizeDist = root:Packages:SASDataEvaluation:CalcCumulativeSizeDist

	SVAR GR1_NumberOrVolumeDist=root:Packages:SASDataEvaluation:GR1_NumberOrVolumeDist
	
	//first lets check, that we have both cursors in the graph and they are on the same wave
	DoWindow/F IR1G_OneSampleEvaluationGraph
	string CsrAwaveName=CsrWave(A, "IR1G_OneSampleEvaluationGraph",1)
	string CsrBwaveName=CsrWave(B, "IR1G_OneSampleEvaluationGraph",1)
	
	//in these cases we need to stop and not progress
	if (strLen(CsrAwaveName)==0)
		IR1G_SetStatsToNaN()
		IR1G_UpdateStatisticsSetVars()
		return 0
	endif
	if (strLen(CsrBwaveName)==0)
		IR1G_SetStatsToNaN()
		IR1G_UpdateStatisticsSetVars()
		return 0
	endif
	if (cmpstr(CsrAwaveName,CsrBwaveName)!=0)
		IR1G_SetStatsToNaN()
		IR1G_UpdateStatisticsSetVars()
		return 0
	endif
	variable startP=pcsr(A)
	variable startX=CsrXWaveRef(A)(startP)
	variable endP=pcsr(B)
	variable endX=CsrXWaveRef(A)(endP)
	if (StartP>endP)
		variable tempP=EndP
		EndP=StartP
		StartP=tempP
		tempP=endX
		EndX=StartX
		StartX=tempP
	endif
	GR1_diameterMin=StartX
	GR1_diameterMax=EndX
	wave w = CsrWaveRef(A,"IR1G_OneSampleEvaluationGraph" )
	string curNote = note(w)
	GR1_NumberOrVolumeDist=stringByKey("SizesDataFrom", curNote,"=",";")+CsrAwaveName
	GR1_Mean=IR1G_CalculateMean(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B))
	GR1_Mode=IR1G_CalculateMode(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B))
	GR1_Median=IR1G_CalculateMedian(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B))
	GR1_Volume=IR1G_CalculateVolume(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B), CsrAwaveName)
	GR1_NumberDens=IR1G_CalculateNumber(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B), CsrAwaveName)
	GR1_PorodSurface=IR1G_CalculateSurfaceArea(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B), CsrAwaveName)
	GR1_FWHM=IR1G_FindFWHM(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B))
	IR1G_UpdateStatisticsSetVars()
	if(CalcCumulativeSizeDist)
		IR1G_CreateCumulativeCurves(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B), CsrAwaveName)
		Wave CumulativeSizeDist
		Wave CumulativeSfcArea
		Wave CumulativeDistDiameters
		CheckDisplayed CumulativeSizeDist
		if(!V_Flag)
			AppendToGraph/W=IR1G_OneSampleEvaluationGraph /L=CumulVolumeAxis CumulativeSizeDist vs CumulativeDistDiameters
		endif
		ModifyGraph freePos(CumulVolumeAxis)=-571
		Label CumulVolumeAxis "Cumulative size dist [fraction]"
		ModifyGraph rgb(CumulativeSizeDist)=(0,0,0)
		ModifyGraph lstyle(CumulativeSizeDist)=3,lsize(CumulativeSizeDist)=2

		CheckDisplayed CumulativeSfcArea
		if(!V_Flag)
			AppendToGraph/W=IR1G_OneSampleEvaluationGraph /L=SurfaceAreaAxis CumulativeSfcArea vs CumulativeDistDiameters
		endif
		ModifyGraph freePos(SurfaceAreaAxis)=-110
		Label SurfaceAreaAxis "Cumulative surface area [cm\S2\M/cm\S3\M]"
		ModifyGraph rgb(CumulativeSfcArea)=(16385,16388,65535)
		ModifyGraph lstyle(CumulativeSfcArea)=6,lsize(CumulativeSfcArea)=2

	else
		Wave/Z CumulativeSizeDist
		Wave/Z CumulativeSfcArea
		Wave/Z CumulativeDistDiameters
		if(WaveExists(CumulativeSizeDist))
			RemoveFromGraph/Z/W=IR1G_OneSampleEvaluationGraph  CumulativeSizeDist, CumulativeSfcArea
			KillWaves /Z  CumulativeSizeDist, CumulativeDistDiameters, CumulativeSfcArea
		endif
	endif

	if(CalcMIPdata)
		IR1G_CreateMIPCurve(CsrWaveRef(A),CsrXWaveRef(A), pcsr(A),pcsr(B), CsrAwaveName)
		DoWIndow MIPDataGraph
		if(V_Flag)
			DoWIndow /F MIPDataGraph
		else
			IR1G_MIPDataGraph()
		endif
	else
		KillWIndow/Z MIPDataGraph
		KillWaves/Z MIPVolume, MIPDistDiameters, MIPPressure	
	endif
	
	IR1G_ResetGraphAfterChanges()
	setDataFolder OldDf
	
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1G_MIPDataGraph()

	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SASDataEvaluation
	Wave MIPVOlume
	Wave MIPPressure

//	PauseUpdate; Silent 1		// building window...
	String fldrSav0= GetDataFolder(1)
	string WavesFrom=GetWavesDataFolder(CsrWaveRef(A), 0 )
	Display /K=1/W=(35,84,380,291)/N=MIPDataGraph MIPVolume vs MIPPressure as "MIP curve for "+WavesFrom
	ModifyGraph log(bottom)=1
	Label left "Intruded volume [fraction]"
	Label bottom "Pressure [Psi]"
	ModifyGraph mirror=1
	ModifyGraph mode=0,lsize=2,rgb=(0,0,0)
	string WaveNameWithCsr=CsrWave(A,"IR1G_OneSampleEvaluationGraph")
	variable startD, endD
	Wave Xwv=CsrXWaveRef(A,"IR1G_OneSampleEvaluationGraph")
	startD=Xwv[pcsr(A,"IR1G_OneSampleEvaluationGraph")]
	endD=Xwv[pcsr(B,"IR1G_OneSampleEvaluationGraph")]
	Legend/C/N=text1/J/F=0/A=LT "\\s(MIPVolume) MIP Volume for "+WaveNameWithCsr +"  for "+num2str(startD)+" < D [A] < " +num2str(endD)
	setDataFolder OldDf

end

//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_FindFWHM(IntProbWave,DiaWave, StartP, EndP)
	wave IntProbWave,DiaWave
	variable StartP, EndP
	
	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SASDataEvaluation
	
	Duplicate/O/R=(StartP, EndP) IntProbWave, Int_temp
	Duplicate/O/R=(StartP, EndP) DiaWave, Dia_temp

	FindPeak/P/Q Int_temp
	if (V_Flag)		//peak not found
		return NaN
	endif

	wavestats/Q/P Int_temp
	
	variable maximum=V_max
	variable maxLoc=V_maxLoc
	Duplicate/O/R=[0,maxLoc] Int_temp, temp_wv1
	Duplicate/O/R=[0,maxLoc] Dia_temp, temp_DWwv1
	
	wavestats/Q/P temp_wv1
	variable OneMin=V_min
	
	Duplicate/O/R=[maxLoc, numpnts(Int_temp)-1] Int_temp, temp_wv2
	Duplicate/O/R=[maxLoc, numpnts(Int_temp)-1] Dia_temp, temp_DWwv2

	wavestats/Q/P temp_wv2
	variable TwoMin=V_min
	
	if (OneMin>(maximum/2) || TwoMin>(maximum/2))
		return NaN
	endif
	FindLevel/P/Q temp_wv1, (maximum/2)
	//Print V_levelX
	//variable MinD=temp_DWwv1[BinarySearchInterp(temp_wv1, (maximum/2) )]
	variable MinD=temp_DWwv1[V_levelX]
	FindLevel/P/Q temp_wv2, (maximum/2)
	//variable MaxD=temp_DWwv2[BinarySearchInterp(temp_wv2, (maximum/2) )]
	variable MaxD=temp_DWwv2[V_levelX]
	KillWaves/Z temp_wv2, temp_wv1,temp_DWwv1,temp_DWwv2, Dia_temp, Int_temp

	setDataFolder OldDf
	
	return abs(MaxD-MinD)
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_CreateCumulativeCurves(DistributionWv,diametersWv, StartP, EndP, DistWaveName)
	Wave DistributionWv,diametersWv
	variable StartP, EndP
	string DistWaveName
	
	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SASDataEvaluation
	Duplicate/O/R=(StartP, EndP) DistributionWv, CumulativeSizeDist, CumulativeSfcArea, ParticleVolumes, ParticleSurfaces
	Duplicate/O/R=(StartP, EndP) diametersWv, CumulativeDistDiameters
	//fix for use of radius in Modeling II
	//12/31/2011
	variable scaleDueToDiaRadChange=1
	String XwaveNm = nameofWave(diametersWv)
	NVAR InvertCumulativeDists=root:Packages:SASDataEvaluation:InvertCumulativeDists
	
	variable surface
	if (stringmatch(DistWaveName,"*Number*"))
		IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,CumulativeDistDiameters,Note(DistributionWv),"Volume")
		CumulativeSizeDist = DistributionWv * ParticleVolumes				//this is volume distribution
		IR1G_CreateAveVolSfcWvUsingNote(ParticleSurfaces,CumulativeDistDiameters,Note(DistributionWv),"Surface")
		CumulativeSfcArea = DistributionWv * ParticleSurfaces				//this is volume distribution
	endif
	if (stringmatch(DistWaveName,"*Volume*"))
		IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,CumulativeDistDiameters,Note(DistributionWv),"Volume")
		IR1G_CreateAveVolSfcWvUsingNote(ParticleSurfaces,CumulativeDistDiameters,Note(DistributionWv),"Surface")
		CumulativeSfcArea = (DistributionWv/ParticleVolumes) * ParticleSurfaces				//this is volume distribution
	endif
	variable curPnts= numpnts(CumulativeDistDiameters)
	Redimension/N=(curPnts+1) CumulativeDistDiameters
	CumulativeDistDiameters[curPnts] =  CumulativeDistDiameters[curPnts-1] +  (CumulativeDistDiameters[curPnts-1] - CumulativeDistDiameters[curPnts-2])
	integrate CumulativeSizeDist /X=CumulativeDistDiameters
	integrate CumulativeSfcArea /X=CumulativeDistDiameters
	Redimension/N=(curPnts) CumulativeSizeDist, CumulativeSfcArea, CumulativeDistDiameters
	
	if(InvertCumulativeDists)
		CumulativeSizeDist = CumulativeSizeDist[numpnts(CumulativeSizeDist)-1] - CumulativeSizeDist[p]
		CumulativeSfcArea = CumulativeSfcArea[numpnts(CumulativeSfcArea)-1] - CumulativeSfcArea[p]		
	endif

	if(stringmatch(XwaveNm, "*Radi*"))	//name contains radius, so we need to multiply the radius by 2 and divide the otehr waves by two to keep calibration
		CumulativeDistDiameters*=2
		CumulativeSizeDist*=0.5
		CumulativeSfcArea*=0.5
	endif
	
	//record stuff to wave note...
	note/NOCR CumulativeSizeDist, "Cumulative Source Data="+GetWavesDataFolder(DistributionWv, 2 )+";"
	note/NOCR CumulativeSizeDist, "Cumulative Start Diameter="+num2str(diametersWv[StartP])+";"
	note/NOCR CumulativeSizeDist, "Cumulative End Diameter="+num2str(diametersWv[EndP])+";"
	note/NOCR CumulativeSizeDist, "Cumulative Calculated On="+Date()+" "+time()+";"

	note/NOCR CumulativeSfcArea, "Cumulative Source Data="+GetWavesDataFolder(DistributionWv, 2 )+";"
	note/NOCR CumulativeSfcArea, "Cumulative Start Diameter="+num2str(diametersWv[StartP])+";"
	note/NOCR CumulativeSfcArea, "Cumulative End Diameter="+num2str(diametersWv[EndP])+";"
	note/NOCR CumulativeSfcArea, "Cumulative Calculated On="+Date()+" "+time()+";"
	 
	IN2G_AppendorReplaceWaveNote("CumulativeSizeDist","Wname","CumulativeSizeDist")
	IN2G_AppendorReplaceWaveNote("CumulativeSizeDist","Units","cm3/cm3")

	IN2G_AppendorReplaceWaveNote("CumulativeSfcArea","Wname","CumulativeSfcArea")
	IN2G_AppendorReplaceWaveNote("CumulativeSizeDist","Units","cm2/cm3")

	IN2G_AppendorReplaceWaveNote("CumulativeDistDiameters","Wname","CumulativeDistDiameters")
	IN2G_AppendorReplaceWaveNote("CumulativeDistDiameters","Units","A")
	KillWaves/Z  ParticleVolumes
	setDataFolder OldDf	

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_CreateMIPCurve(DistributionWv,diametersWv, StartP, EndP, DistWaveName)
	Wave DistributionWv,diametersWv
	variable StartP, EndP
	string DistWaveName
	
	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SASDataEvaluation
	Duplicate/O/R=(StartP, EndP) DistributionWv, MIPVolume, ParticleVolumes, ParticleSurfaces
	Duplicate/O/R=(StartP, EndP) diametersWv, MIPDistDiameters, MIPPressure
	
	NVAR MIPUserSigma=root:Packages:SASDataEvaluation:MIPUserSigma
	NVAR MIPUserCosTheta=root:Packages:SASDataEvaluation:MIPUserCosTheta
	
//	variable surface
	if (stringmatch(DistWaveName,"*Number*"))
		IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,MIPDistDiameters,Note(DistributionWv),"Volume")
		MIPVolume = DistributionWv * ParticleVolumes				//this is volume distribution
	endif
	if (stringmatch(DistWaveName,"*Volume*"))
		IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,MIPDistDiameters,Note(DistributionWv),"Volume")
	endif

	variable curPnts= numpnts(MIPDistDiameters)
	Redimension/N=(curPnts+1) MIPDistDiameters
	MIPDistDiameters[curPnts] =  MIPDistDiameters[curPnts-1] +  (MIPDistDiameters[curPnts-1] - MIPDistDiameters[curPnts-2])
	integrate MIPVolume /X=MIPDistDiameters
	Redimension/N=(curPnts) MIPVolume, MIPDistDiameters
	MIPVolume = MIPVolume[numpnts(MIPVolume)-1] - MIPVolume[p]		//invert, so the max is at small sizes...

//	
//	//record stuff to wave note...
	note/NOCR MIPVolume, "MIP Source Data="+GetWavesDataFolder(DistributionWv, 2 )+";"
	note/NOCR MIPVolume, "MIP Start Diameter="+num2str(diametersWv[StartP])+";"
	note/NOCR MIPVolume, "MIP End Diameter="+num2str(diametersWv[EndP])+";"
	note/NOCR MIPVolume, "MIP Calculated On="+Date()+" "+time()+";"

	note/NOCR MIPPressure, "MIP Source Data="+GetWavesDataFolder(DistributionWv, 2 )+";"
	note/NOCR MIPPressure, "MIP Start Diameter="+num2str(diametersWv[StartP])+";"
	note/NOCR MIPPressure, "MIP End Diameter="+num2str(diametersWv[EndP])+";"
	note/NOCR MIPPressure, "MIP Calculated On="+Date()+" "+time()+";"
	 
	IN2G_AppendorReplaceWaveNote("MIPVolume","Wname","MIPVolume")
	IN2G_AppendorReplaceWaveNote("MIPVolume","Units","cm3/cm3")

	IN2G_AppendorReplaceWaveNote("MIPDistDiameters","Wname","MIPDistDiameters")
	IN2G_AppendorReplaceWaveNote("MIPDistDiameters","Units","A")

	IN2G_AppendorReplaceWaveNote("MIPPressure","Wname","MIPPressure")
	IN2G_AppendorReplaceWaveNote("MIPPressure","Units","Psi")
	
	
	variable MIPSigma
	if(MIPUserSigma>300 && MIPUserSigma<750)			//sigma in dynes/cm, should be around 485 dynes/cm = 485 mN/m2... Weird unit. Radlinski,  Oct 2007
		MIPSigma = MIPUserSigma
	else
		MIPSigma = MIPUserSigma
	endif
	variable MIPCosTheta					//this should be around -0.766, Radlinski, Oct 2007
	if(MIPUserCosTheta<-0.1 && MIPUserCosTheta>-1)
		MIPCosTheta = MIPUserCosTheta
	else
		MIPCosTheta = -0.766
	endif
	
	//Pc=2sigma cos(theta)/r
	variable TwoSigCosTheta =  -2 * MIPSigma * MIPCosTheta * 10
	MIPPressure = TwoSigCosTheta / (MIPDistDiameters / 20)
	//these units will be surely wrong, so here it goes: MIP sigma is in dynes/cm which should be equivalent to mN/m2
	// Cost(theta) = - 0.766 unitless
	//Diameters are in A in Irena, here are converted into nm and radii for this formula to work... 
	// and pressure needs to be in Psi (the hell, could we use SI units for once, please??? 
	// according to my info, p[kg/cm2] = 2 * sigma * cos(theta) / r [nm], approximately 7500/r [nm]
	// but 2 * sigma * cos(theta) ~ 750, so multiply by 10  
	MIPPressure = MIPPressure * 9.8e4 * 1.4504e-4		//here the first converst kg/cm2 into Pascals and the second Pa into psi... 
	
	Sort MIPPressure, MIPPressure, MIPVolume 

//	KillWaves/Z  ParticleVolumes
	setDataFolder OldDf	

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1G_CalculateSurfaceArea(DistributionWv,diametersWv, StartP, EndP, DistWaveName)
	Wave DistributionWv,diametersWv
	variable StartP, EndP
	string DistWaveName
	
	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SASDataEvaluation
	Duplicate/O/R=(StartP, EndP)/Free DistributionWv, Dist_temp, ParticleSurface, ParticleVolumes
	Duplicate/O/R=(StartP, EndP)/Free diametersWv, Dia_temp, Dia_tempOrig
	variable number

	string XWvName = NameOfWave(diametersWv)
	if(stringMatch(XWvName,"*Radi*"))		//this is really radius wave...
		Dia_temp =  2 * Dia_temp		//convert to diameters for next calculations
	endif
	IR1G_CreateAveVolSfcWvUsingNote(ParticleSurface,Dia_temp,Note(DistributionWv),"Surface")

	if (stringmatch(DistWaveName,"*Number*") || stringmatch(DistWaveName,"*NumDist*"))
		//this is easy, just integrate
		Dist_temp = Dist_temp * ParticleSurface
		number=areaXY(Dia_tempOrig, Dist_temp, 0, inf)
	endif
	if (stringmatch(DistWaveName,"*Volume*") || stringmatch(DistWaveName,"*VolDist*"))
		IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,Dia_temp,Note(DistributionWv),"Volume")
		Dist_temp = Dist_temp / ParticleVolumes			//this is now number distribution
		Dist_temp = Dist_temp * ParticleSurface			//this is now specific surface area
		number=areaXY(Dia_tempOrig, Dist_temp, 0, inf)
	endif

	setDataFolder OldDf	
	return number
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_CalculateNumber(DistributionWv,diametersWv, StartP, EndP, DistWaveName)
	Wave DistributionWv,diametersWv
	variable StartP, EndP
	string DistWaveName
	
	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SASDataEvaluation
	Duplicate/O/R=(StartP, EndP)/Free DistributionWv, Dist_temp,  ParticleVolumes
	Duplicate/O/R=(StartP, EndP)/Free diametersWv, Dia_temp, Dia_tempOrig
	variable number
	//need to fix this in case we have radius wave and not diameter...
	string XWvName = NameOfWave(diametersWv)
	if(stringMatch(XWvName,"*Radi*"))		//this is really radius wave...
		Dia_temp =  2 * Dia_temp			//convert to diameters for next calculations
	endif

	if (stringmatch(DistWaveName,"*Number*") || stringmatch(DistWaveName,"*NumDist*"))
		//this is easy, just integrate
		number=areaXY(Dia_tempOrig, Dist_temp, 0, inf)
	endif
	if (stringmatch(DistWaveName,"*Volume*") || stringmatch(DistWaveName,"*VolDist*"))
		IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,Dia_temp,Note(DistributionWv),"Volume")
		Dist_temp = Dist_temp / ParticleVolumes			//this is now number distribution
		number=areaXY(Dia_tempOrig, Dist_temp, 0, inf)
	endif

	setDataFolder OldDf	
	return number
end



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1G_CalculateVolume(DistributionWv,diametersWv, StartP, EndP, DistWaveName)
	Wave DistributionWv,diametersWv
	variable StartP, EndP
	string DistWaveName
	
	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SASDataEvaluation
	Duplicate/O/R=(StartP, EndP) DistributionWv, Dist_temp, ParticleVolumes
	Duplicate/O/R=(StartP, EndP) diametersWv, Dia_temp
	variable volume
	if (stringmatch(DistWaveName,"*Volume*") || stringmatch(DistWaveName,"*VolDist*"))
		//this is easy, just integrate
		volume=areaXY(Dia_temp, Dist_temp, 0, inf)
	endif
	if (stringmatch(DistWaveName,"*Number*") || stringmatch(DistWaveName,"*NumDist*"))
		IR1G_CreateAveVolSfcWvUsingNote(ParticleVolumes,Dia_temp,Note(DistributionWv),"Volume")
		Dist_temp = Dist_temp * ParticleVolumes				//this is volume distribution
		volume=areaXY(Dia_temp, Dist_temp, 0, inf)
	endif
	
	KillWaves/Z  Dist_temp, Dia_temp, ParticleVolumes
	setDataFolder OldDf	
	return Volume
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_CalculateMean(DistributionWv,diametersWv, StartP, EndP)
	Wave DistributionWv,diametersWv
	variable StartP, EndP
	
	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SASDataEvaluation
	Duplicate/O/R=(StartP, EndP) DistributionWv, Dist_temp, Another_temp
	Duplicate/O/R=(StartP, EndP) diametersWv, Dia_temp
	Another_temp=Dia_temp*Dist_temp
	variable DistMean=areaXY(Dia_temp, Another_temp,0,inf)/areaXY(Dia_temp, Dist_temp,0,inf)		//Sum P(R)*R*deltaR
	KillWaves/Z  Another_Temp, Dist_temp, Dia_temp
	setDataFolder OldDf	
	return DistMean
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_CalculateMedian(DistributionWv,diametersWv, StartP, EndP)
	Wave DistributionWv,diametersWv
	variable StartP, EndP
	
	string OldDf=GetDataFolder(1)
	variable DistMedian
	SetDataFolder root:Packages:SASDataEvaluation
	Duplicate/O/R=(StartP, EndP) DistributionWv, Dist_temp, Another_temp
	Duplicate/O/R=(StartP, EndP) diametersWv, Dia_temp
	IN2G_IntegrateXY(Dia_temp, Dist_temp)
	WaveStats/Q Dist_temp
	DistMedian=Dia_temp[BinarySearchInterp(Dist_temp, 0.5*V_max)]		//R for which cumulative probability=0.5

	KillWaves/Z  Another_Temp, Dist_temp, Dia_temp
	setDataFolder OldDf	
	return DistMedian
end



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_CalculateMode(DistributionWv,diametersWv, StartP, EndP)
	Wave DistributionWv,diametersWv
	variable StartP, EndP
	
	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SASDataEvaluation
	Duplicate/O/R=(StartP, EndP) DistributionWv, Dist_temp, Another_temp
	Duplicate/O/R=(StartP, EndP) diametersWv, Dia_temp
	variable DistMode

	FindPeak/P/Q Dist_temp
	if (V_Flag)		//peak not found
		DistMode=NaN
	else
		DistMode=Dia_temp[V_PeakLoc]								//location of maximum on the P(R)
	endif

	KillWaves/Z  Another_Temp, Dist_temp, Dia_temp
	setDataFolder OldDf	
	return DistMode
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1G_SetStatsToNaN()

	NVAR GR1_Mean=root:Packages:SASDataEvaluation:GR1_Mean
	NVAR GR1_Mode=root:Packages:SASDataEvaluation:GR1_Mode
	NVAR GR1_Median=root:Packages:SASDataEvaluation:GR1_Median
	NVAR GR1_diameterMin=root:Packages:SASDataEvaluation:GR1_diameterMin
	NVAR GR1_diameterMax=root:Packages:SASDataEvaluation:GR1_diameterMax
	NVAR GR1_Volume=root:Packages:SASDataEvaluation:GR1_Volume
	NVAR GR1_NumberDens=root:Packages:SASDataEvaluation:GR1_NumberDens
	NVAR GR1_PorodSurface=root:Packages:SASDataEvaluation:GR1_PorodSurface
	NVAR GR1_FWHM=root:Packages:SASDataEvaluation:GR1_FWHM
	SVAR GR1_NumberOrVolumeDist=root:Packages:SASDataEvaluation:GR1_NumberOrVolumeDist

	 GR1_Mean=Nan
	 GR1_Mode=NaN
	 GR1_Median=NaN
	 GR1_diameterMin=naN
	 GR1_diameterMax=NaN
	 GR1_Volume=NaN
	 GR1_NumberDens=NaN
	 GR1_PorodSurface=NaN
	 GR1_FWHM=NaN
	 GR1_NumberOrVolumeDist="Cursors not on the same wave" 

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_UpdateStatisticsSetVars()

	SetVariable diameterMin,win=IR1G_OneSampleEvaluationGraph,value= root:Packages:SASDataEvaluation:GR1_diameterMin
	SetVariable diameterMax,win=IR1G_OneSampleEvaluationGraph,value= root:Packages:SASDataEvaluation:GR1_diameterMax
	SetVariable Volume,win=IR1G_OneSampleEvaluationGraph,value= root:Packages:SASDataEvaluation:GR1_Volume
	SetVariable Number,win=IR1G_OneSampleEvaluationGraph,value= root:Packages:SASDataEvaluation:GR1_NumberDens
	SetVariable PorodSurface,win=IR1G_OneSampleEvaluationGraph,value= root:Packages:SASDataEvaluation:GR1_PorodSurface
	SetVariable NumerOrVolume,win=IR1G_OneSampleEvaluationGraph,value= root:Packages:SASDataEvaluation:GR1_NumberOrVolumeDist
	SetVariable MeanV,win=IR1G_OneSampleEvaluationGraph,value= root:Packages:SASDataEvaluation:GR1_Mean
	SetVariable Mode,win=IR1G_OneSampleEvaluationGraph,value= root:Packages:SASDataEvaluation:GR1_Mode
	SetVariable Median,win=IR1G_OneSampleEvaluationGraph,value= root:Packages:SASDataEvaluation:GR1_Median
	SetVariable FWHM,win=IR1G_OneSampleEvaluationGraph,value= root:Packages:SASDataEvaluation:GR1_FWHM

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_IniEvaluationGraph()

	string OldDf=getDataFolder(1)
	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S  root:Packages:SASDataEvaluation
	string ListOfVariables
	string ListOfStrings
	
	
	ListOfVariables="GR1_DisplayDistribution1;GR1_DisplayDistribution2;GR1_DisplayDistribution3;GR1_DisplayDistribution4;GR1_DisplayDistribution5;"
	ListOfVariables+="GR1_DisplayND;GR1_DisplayVD;GR1_Mean;GR1_Mode;GR1_Median;GR1_diameterMin;GR1_diameterMax;GR1_Volume;GR1_NumberDens;InvertCumulativeDists;"
	ListOfVariables+="GR1_PorodSurface;GR1_FWHM;GR1_AutoUpdate;QLogScale;CalcCumulativeSizeDist;EvaluatePopulationNumber;OldACursorPosition;OldBCursorPosition;CalcMIPdata;"
	ListOfVariables+="MIPUserSigma;MIPUserCosTheta;logXAxis;"
	
	
	ListOfStrings="GR1_NumberOrVolumeDist;DataFolderName;YWaveName;XWaveNameStr;"

	variable i
	For (i=0;i<ItemsInList(ListOfVariables);i+=1)
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor
	For (i=0;i<ItemsInList(ListOfStrings);i+=1)
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor
	//and now some title texts
	string/G TtlText1="Data control"
	string/G TtlText2="Select range of data with cursors"
	
	
	NVAR MIPUserSigma
	if(MIPUserSigma<100)
		MIPUserSigma = 485
	endif
	NVAR MIPUserCosTheta
	if(MIPUserCosTheta>-0.4)
		MIPUserCosTheta = -0.766
	endif
	setDataFolder OldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_CheckDisplayedDist(Ywv,Xwv)
	wave Ywv,Xwv
	
	variable NewDataAdded=0
		
	string OldDf=getDataFolder(1)
	SetDataFolder  root:Packages:SASDataEvaluation
	
	
	string CheckWvname=GetWavesDataFolder(Ywv,2)
	Variable numOfDisplayedWaves, i
	string WavesListWithpaths=""
	
	numOfDisplayedWaves = itemsInList(TraceNameList("IR1G_OneSampleEvaluationGraph", ";", 1))
	
	For(i=0;i<numOfDisplayedWaves;i+=1)
		Wave/Z w=WaveRefIndexed("IR1G_OneSampleEvaluationGraph", i, 1 )
		WavesListWithpaths+=GetWavesDataFolder(w,2)+";"
	endfor
	if(!stringMatch(WavesListWithpaths, "*"+CheckWvname+"*"))
		if(stringMatch(CheckWvname,"*volume*"))
			AppendToGraph/W=IR1G_OneSampleEvaluationGraph Ywv vs Xwv
		else
			AppendToGraph/R/W=IR1G_OneSampleEvaluationGraph Ywv vs Xwv
		endif
		NewDataAdded=1
	endif
	
	setDataFolder OldDf
	return NewDataAdded
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//
//
//Function IR1G_CheckDisplayedND()
//		
//	string OldDf=getDataFolder(1)
//	SetDataFolder  root:Packages:SASDataEvaluation
//
//		//check that NR is as requested
//		NVAR NDdisplay=root:Packages:SASDataEvaluation:GR1_DisplayND
//		CheckDisplayed/W=IR1G_OneSampleEvaluationGraph  TotalNumberDist
//		variable IsDisplayed=V_Flag
//		
//		if (NDDisplay)		//display the NR
//			if(!IsDisplayed)
//				//append the NR display
//				AppendToGraph/W=IR1G_OneSampleEvaluationGraph TotalNumberDist vs Distdiameters
//			endif
//		else					//do not display NR
//			if (IsDisplayed)
//				RemoveFromGraph/W=IR1G_OneSampleEvaluationGraph TotalNumberDist
//				ModifyGraph mirror(right)=1
//			endif		
//		endif		
//	setDataFolder OldDf
//end
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//
//Function IR1G_CheckDisplayedVD()
//		
//	string OldDf=getDataFolder(1)
//	SetDataFolder  root:Packages:SASDataEvaluation
//
//		//check that VD is as requested
//		NVAR VDdisplay=root:Packages:SASDataEvaluation:GR1_DisplayND
//		CheckDisplayed/W=IR1G_OneSampleEvaluationGraph  TotalVolumeDist
//		variable IsDisplayed=V_Flag
//		
//		if (VDDisplay)		//display the NR
//			if(!IsDisplayed)
//				//append the NR display
//				AppendToGraph/W=IR1G_OneSampleEvaluationGraph /R TotalVolumeDist vs Distdiameters
//			endif
//		else					//do not display NR
//			if (IsDisplayed)
//				RemoveFromGraph/W=IR1G_OneSampleEvaluationGraph TotalVolumeDist
//				ModifyGraph mirror(left)=1
//			endif		
//		endif		
//	setDataFolder OldDf
//end
//
//

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1G_CheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string OldDf=getDataFolder(1)
	SetDataFolder  root:Packages:SASDataEvaluation

	if (cmpstr(ctrlName,"AutoUpdate")==0)
		//here goes what happens when we check/uncheck this
		NVAR GR1_AutoUpdate=root:Packages:SASDataEvaluation:GR1_AutoUpdate
		GR1_AutoUpdate=checked
		IR1G_CalculateStatistics()
		IR1G_ResetGraphAfterChanges()
	endif
	if (cmpstr(ctrlName,"CalcCumulativeSizeDist")==0 || stringmatch(ctrlName,"InvertCumulativeDists"))
		IR1G_CalculateStatistics()	
		IR1G_ResetGraphAfterChanges()
	endif
	if (cmpstr(ctrlName,"LogXAxis")==0)
		IR1G_AddDataToGraph()	
	endif
	if (cmpstr(ctrlName,"CalcMIPdata")==0)
		IR1G_CalculateStatistics()	
		IR1G_ResetGraphAfterChanges()
		SetVariable MIPUserSigma, disable = !(checked)
		SetVariable MIPCosTheta, disable = !(checked)
	endif


	
	DoWindow/F IR1G_OneSampleEvaluationGraph
	DoWindow MIPDataGraph
	if(V_Flag)
		DoWindow/F MIPDataGraph
	endif
	setDataFolder OldDf
End


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1G_ButtonProc(ctrlName) : ButtonControl
	String ctrlName

	if (cmpstr(ctrlName,"AppendTag")==0)
		//here goes what happens when we want to append textbox to the results...
		IR1G_AppendTag()
	endif
	if (cmpstr(ctrlName,"Calculate")==0)
		//here goes what happens when we want to calculate results...
		IR1G_CalculateStatistics()
	endif
	if(cmpstr(ctrlName,"GetHelp")==0)
		//Open www manual with the right page
		IN2G_OpenWebManual("Irena/EvaluateSizeDistributions.html")
	endif

//AddDataToGraph
	if (cmpstr(ctrlName,"AddData")==0)
		//here goes what happens when we want to append textbox to the results...
		IR1G_AddDataToGraph()
		DoUpdate
		IR1G_CalculateStatistics()
	endif
	if (cmpstr(ctrlName,"ClearGraph")==0)
		//here goes what happens when we want to append textbox to the results...
		IR1G_ClearGraph()
	endif
	if (cmpstr(ctrlName,"SaveCumulativeSizeDist")==0)
		//here goes what happens when we want to append textbox to the results...
		IR1G_SaveCumulativeSizeDist()
	endif

	DoWindow/F IR1G_OneSampleEvaluationGraph
	DoWindow MIPDataGraph
	if(V_Flag)
		DoWindow/F MIPDataGraph
	endif

End


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_SaveCumulativeSizeDist()
	string OldDf=getDataFolder(1)
	SetDataFolder  root:Packages:SASDataEvaluation

	Wave/Z CumulativeSizeDist=root:Packages:SASDataEvaluation:CumulativeSizeDist
	Wave/Z CumulativeSfcArea=root:Packages:SASDataEvaluation:CumulativeSfcArea
	Wave/Z CumulativeDistDiameters=root:Packages:SASDataEvaluation:CumulativeDistDiameters

	Wave/Z MIPPressure=root:Packages:SASDataEvaluation:MIPPressure
	Wave/Z MIPVolume=root:Packages:SASDataEvaluation:MIPVolume
	
	string IntrCrvNote
	String DataFldr
	variable LocOfUnd
	variable IndxOfData
	string NewIntrCrvName
	string NewSfcCrvName
	string NewDiaWvName
	String SavedWhat=""
	variable AlertUserNotSaved=0
	If(!WaveExists(CumulativeSizeDist) ||!WaveExists(CumulativeSfcArea) || !WaveExists(CumulativeDistDiameters))
		SavedWhat= "\rCumulativeSizeDist or CumulativeSfcArea data do not exist, not saved \r"	
		AlertUserNotSaved+=1	
	else
		IntrCrvNote=note(CumulativeSizeDist)
		Wave OrigData = $(stringByKey("Cumulative Source Data",IntrCrvNote,"=",";"))
		DataFldr=GetWavesDataFolder(ORIGDATA, 1)
		LocOfUnd=strsearch(stringByKey("Cumulative Source Data",IntrCrvNote,"=",";"),"_",strlen(stringByKey("Cumulative Source Data",IntrCrvNote,"=",";")),3)+1
		//print stringByKey("CumulativeSizeDist Curve Source Data",IntrCrvNote,"=",";")[LocOfUnd,inf]
		IndxOfData=str2num(stringByKey("Cumulative Source Data",IntrCrvNote,"=",";")[LocOfUnd,inf])
		
		SetDataFolder DataFldr
		NewIntrCrvName= "CumulativeSizeDist_"+num2str(IndxOfData)
		NewSfcCrvName="CumulativeSfcArea_"+num2str(IndxOfData)
		NewDiaWvName="CumulativeDistDiameters_"+num2str(IndxOfData)
		if(checkName ("CumulativeSizeDist_"+num2str(IndxOfData),1)!=0)
			NewIntrCrvName= UniqueName("CumulativeSizeDist_"+num2str(IndxOfData),1,0)
			NewSfcCrvName="CumulativeSfcArea_"+NewIntrCrvName[14,inf]
			NewDiaWvName="CumulativeDistDiameters"+NewIntrCrvName[14,inf]
			DoALert 0, "Note that existing index of the result was already used, the data stored with increased index. See message in history area"
		endif
		
		Duplicate/O CumulativeSizeDist, $(NewIntrCrvName)
		Duplicate/O CumulativeSfcArea, $(NewSfcCrvName)
		Duplicate/O CumulativeDistDiameters, $(NewDiaWvName)
		SavedWhat = "\rSaved Cumulative data to     " + NewIntrCrvName +"     /     " + NewSfcCrvName +"     /     " +NewDiaWvName +"    in folder    "+DataFldr+"\r"
	endif
	//now the MIP data, if they exist...
	If(!WaveExists(MIPPressure) ||!WaveExists(MIPVolume))
		SavedWhat+= "MIPVolume data do not exist, not saved \r"		
		AlertUserNotSaved+=1	
	else
		IntrCrvNote=note(MIPVolume)
		Wave OrigData = $(stringByKey("MIP Source Data",IntrCrvNote,"=",";"))
		DataFldr=GetWavesDataFolder(ORIGDATA, 1)
		LocOfUnd=strsearch(stringByKey("MIP Source Data",IntrCrvNote,"=",";"),"_",strlen(stringByKey("MIP Source Data",IntrCrvNote,"=",";")),3)+1
		//print stringByKey("CumulativeSizeDist Curve Source Data",IntrCrvNote,"=",";")[LocOfUnd,inf]
		IndxOfData=str2num(stringByKey("MIP Source Data",IntrCrvNote,"=",";")[LocOfUnd,inf])
		
		SetDataFolder DataFldr
		NewIntrCrvName= "MIPVolume_"+num2str(IndxOfData)
		NewDiaWvName="MIPPressure_"+num2str(IndxOfData)
		if(checkName ("MIPVolume_"+num2str(IndxOfData),1)!=0)
			NewIntrCrvName= UniqueName("MIPVolume_"+num2str(IndxOfData),1,0)
			NewDiaWvName="MIPPressure_"+NewIntrCrvName[10,inf]
			DoALert 0, "Note that existing index of the result was already used, the data stored with increased index. See message in history area"
		endif
		
		Duplicate/O MIPVolume, $(NewIntrCrvName)
		Duplicate/O MIPPressure, $(NewDiaWvName)
		SavedWhat += "Saved MIP data to     " + NewIntrCrvName +"     /     " + NewDiaWvName +"    in folder    "+DataFldr
	endif
	if(AlertUserNotSaved>1.5)
		DoAlert 0, "Nothing available for saving..."
	endif

	
	print SavedWhat
	setDataFolder OldDf	
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR1G_ClearGraph()
	string OldDf=getDataFolder(1)
	SetDataFolder  root:Packages:SASDataEvaluation

	Variable numOfDisplayedWaves, i
	string ListOfWaves=TraceNameList("IR1G_OneSampleEvaluationGraph", ";", 1)
	
	numOfDisplayedWaves = itemsInList(ListOfWaves)
	
	SetWindow IR1G_OneSampleEvaluationGraph, hook(named)=$""
	For(i=0;i<numOfDisplayedWaves;i+=1)
		RemoveFromGraph/W=IR1G_OneSampleEvaluationGraph /Z $(stringFromList(i, ListOfWaves))
	endfor
	TextBox/W=IR1G_OneSampleEvaluationGraph /K/N=SampleName
	SetWindow IR1G_OneSampleEvaluationGraph, hook(named)=IRG1_MainHookFunction

	setDataFolder OldDf	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_AddDataToGraph()

	string OldDf=getDataFolder(1)
	SetDataFolder  root:Packages:SASDataEvaluation

	SVAR DataFoldername=root:Packages:SASDataEvaluation:DataFolderName
	SVAR YWaveNameStr=root:Packages:SASDataEvaluation:IntensityWaveName
	SVAR XWaveNameStr=root:Packages:SASDataEvaluation:QWavename
	if(stringmatch(YWaveNameStr,"ModelInt"))
		Abort
	endif
	
	Wave/Z Ywv=$(DataFoldername+YWaveNameStr)
	Wave/Z Xwv=$(DataFoldername+XWaveNameStr)

	if(!WaveExists(Ywv) || !WaveExists(Xwv))
		DoAlert 1, "Bug, the selected data do not exist. Report as bug - send this experiment to ilavsky@aps.anl.gov"
		setDataFolder OldDf	
		abort
	endif

	variable NewDataAdded=0
	 
	NewDataAdded = IR1G_CheckDisplayedDist(Ywv,Xwv)
	
	if(NewDataAdded)
		//sync the record of what data we have in graph...
		//modify the graph now...
			if(!strlen(axisinfo("IR1G_OneSampleEvaluationGraph","right"))>0)		//not used right, mirror left...
				ModifyGraph/Z/W=IR1G_OneSampleEvaluationGraph mirror(left)=1
			endif
			if(!strlen(axisinfo("IR1G_OneSampleEvaluationGraph","left"))>0)		//not used left, mirror left...
				ModifyGraph/Z/W=IR1G_OneSampleEvaluationGraph mirror(right)=1
			endif
			ModifyGraph/Z/W=IR1G_OneSampleEvaluationGraph mirror(bottom)=1
			ModifyGraph/Z/W=IR1G_OneSampleEvaluationGraph lblMargin(right)=18,lblMargin(left)=7
			ModifyGraph/Z/W=IR1G_OneSampleEvaluationGraph axOffset(left)=-0.444444
			ModifyGraph/Z/W=IR1G_OneSampleEvaluationGraph lblLatPos(right)=12,lblLatPos(left)=1
			ModifyGraph/Z/W=IR1G_OneSampleEvaluationGraph lblMargin(bottom)=6
			ModifyGraph/Z/W=IR1G_OneSampleEvaluationGraph axOffset(bottom)=0.388889
			ModifyGraph/Z/W=IR1G_OneSampleEvaluationGraph lblLatPos(bottom)=9
			Label/Z/W=IR1G_OneSampleEvaluationGraph bottom "Scatterers size (radius or diameter) [A]"
			Label/Z/W=IR1G_OneSampleEvaluationGraph LEFT "Volume distribution [cm\\S3\\M/cm\\S3\\MA\\S1\\M]"
			Label/Z/W=IR1G_OneSampleEvaluationGraph right "Number distribution [1/cm\\S3\\MA\\S1\\M]"
		
	endif
	NVAR logXaxis = root:Packages:SASDataEvaluation:logXAxis
	ModifyGraph log(bottom)=logXaxis
	NVAR OldACursorPosition=root:Packages:SASDataEvaluation:OldACursorPosition
	NVAR OldBCursorPosition=root:Packages:SASDataEvaluation:OldBCursorPosition
	//Set cursors, if they are not set...
	if(strlen(csrInfo(A,"IR1G_OneSampleEvaluationGraph"))<1 && strlen(csrinfo(B,"IR1G_OneSampleEvaluationGraph"))<1 && (OldACursorPosition+OldBCursorPosition)>1)
		cursor /W=IR1G_OneSampleEvaluationGraph /P  A  $YWaveNameStr  BinarySearch(Xwv,OldACursorPosition)
		cursor /W=IR1G_OneSampleEvaluationGraph /P  B  $YWaveNameStr  (BinarySearch(Xwv,OldBCursorPosition)+1)		
	endif

		NVAR GR1_AutoUpdate=root:Packages:SASDataEvaluation:GR1_AutoUpdate
		if(GR1_AutoUpdate)
			IR1G_CalculateStatistics()
		endif
		IR1G_ResetGraphAfterChanges()

	setDataFolder OldDf	
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1G_ResetGraphAfterChanges()

	string OldDf=getDataFolder(1)
	SetDataFolder  root:Packages:SASDataEvaluation

	DoWindow /F IR1G_OneSampleEvaluationGraph
	ModifyGraph/Z mode=4
	ModifyGraph/Z lSize=1, msize=2
	//OK, lets find number of displayed waves
	string listOfWaves=TraceNameList("IR1G_OneSampleEvaluationGraph", ";", 1 )
	string tempName="", LegendStuff="", curNote
	variable NumDisplayedWaves = ItemsInList(listOfWaves)
	Variable i, Ind
	ind = 65280/NumDisplayedWaves
	String FromName=""
	variable DisplayedDia, DisplayedRad
	DisplayedDia=0
	DisplayedRad=0
	For(i=0;i<NumDisplayedWaves;i+=1)
		tempName= StringFromList(i, listOfWaves )
		if(stringmatch(tempname,"CumulativeSizeDist"))
			ModifyGraph/Z marker($tempname)=0, rgb($tempname)=(0,0,0)
			ModifyGraph/Z msize($tempname)=4,lsize($tempname)=2
			wave w = TraceNameToWaveRef("IR1G_OneSampleEvaluationGraph", tempname )
			curNote = note(w)
			FromName = stringByKey("SizesDataFrom", curNote,"=",";")	//this is for Sizes...
			if(strlen(FromName)<2)	//this is for Modeling I
				FromName = stringByKey("DataFolderinIgor", curNote,"=",";")	
			endif
			
			LegendStuff +="\s("+tempname+") CumulativeSizeDist curve for :   "+FromName+"\r"
		endif
		if(stringmatch(tempname,"CumulativeSfcArea"))
			ModifyGraph/Z marker($tempname)=0, rgb($tempname)=(16385,16388,65535)
			ModifyGraph/Z msize($tempname)=4,lsize($tempname)=2
			wave w = TraceNameToWaveRef("IR1G_OneSampleEvaluationGraph", tempname )
			curNote = note(w)
			FromName = stringByKey("SizesDataFrom", curNote,"=",";")	//this is for Sizes...
			if(strlen(FromName)<2)	//thsi is for Modeling I
				FromName = stringByKey("DataFolderinIgor", curNote,"=",";")	
			endif
			
			LegendStuff +="\s("+tempname+") CumulativeSfcArea curve for :   "+FromName+"\r"
		endif
		if(stringmatch(tempname,"*Volume*") || stringmatch(tempname,"*VolDist*"))
			ModifyGraph/Z marker($tempname)=19, rgb($tempname)=(i*ind,65280-(i*ind),0)
			ModifyGraph/Z msize($tempname)=3,lsize($tempname)=2
			wave w = TraceNameToWaveRef("IR1G_OneSampleEvaluationGraph", tempname )
			wave wx=XWaveRefFromTrace("IR1G_OneSampleEvaluationGraph", tempname )
			if(stringmatch(nameOfWave(wx),"*Radi*"))
				DisplayedRad=1
			endif
			if(stringmatch(nameOfWave(wx),"*Diameter*"))
				DisplayedDia=1
			endif
			curNote = note(w)
			LegendStuff +="\s("+tempname+") "+stringByKey("SizesDataFrom", curNote,"=",";")+" "+tempname+"\r"
		endif
		if(stringmatch(tempname,"*Number*") || stringmatch(tempname,"*NumDist*"))
			ModifyGraph/Z marker($tempname)=8, rgb($tempname)=(0, i*ind,65280-(i*ind))
			ModifyGraph/Z msize($tempname)=3,lsize($tempname)=2
			wave w = TraceNameToWaveRef("IR1G_OneSampleEvaluationGraph", tempname )
			curNote = note(w)
			wave wx=XWaveRefFromTrace("IR1G_OneSampleEvaluationGraph", tempname )
			if(stringmatch(nameOfWave(wx),"*Radi*"))
				DisplayedRad=1
			endif
			if(stringmatch(nameOfWave(wx),"*Diameter*"))
				DisplayedDia=1
			endif
			LegendStuff +="\s("+tempname+") "+stringByKey("SizesDataFrom", curNote,"=",";")+" "+tempname+"\r"
		endif
		
	endfor
	
	ModifyGraph lblMargin(bottom)=6
	ModifyGraph axOffset(bottom)=0.388889
	ModifyGraph lblLatPos(bottom)=9
	string BottomLabel="Scatterers "
	if(DisplayedRad)
		BottomLabel+="radii "
	endif
	if(DisplayedRad&&DisplayedDia)
		BottomLabel+="_and_also_ "
	endif
	if(DisplayedDia)
		BottomLabel+="diameters "
	endif
	BottomLabel+="[A]"
	Label/Z bottom BottomLabel
	Label/Z left "Volume distribution [cm\\S3\\M/cm\\S3\\MA\\S1\\M]"
	Label/Z right "Number distribution [1/cm\\S3\\MA\\S1\\M]"
	TextBox/C/N=SampleName/F=0/A=RT "\\F'Times New Roman'\\Z12"+LegendStuff
	ShowInfo

//	Legend/C/N=text0/S=3/A=RT
	setDataFolder OldDf

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1G_SetProperlyTheCheckboxes()
	
	string OldDf=GetDataFolder(1)
	setdataFolder root:Packages:SASDataEvaluation
	
//	NVAR GR1_DisplayDistribution1
//	NVAR GR1_DisplayDistribution2
//	NVAR GR1_DisplayDistribution3
//	NVAR GR1_DisplayDistribution4
//	NVAR GR1_DisplayDistribution5
//	NVAR NumberOfDistributions
//	NVAR GR1_AutoUpdate=root:Packages:SASDataEvaluation:GR1_AutoUpdate
//	NVAR GR1_DisplayND=root:Packages:SASDataEvaluation:GR1_DisplayND
//	NVAR GR1_DisplayVD=root:Packages:SASDataEvaluation:GR1_DisplayVD
//	
//	GR1_DisplayND=1
//	GR1_DisplayVD=1
//	GR1_DisplayDistribution1=0
//	GR1_DisplayDistribution2=0
//	GR1_DisplayDistribution3=0
//	GR1_DisplayDistribution4=0
//	GR1_DisplayDistribution5=0
//	GR1_AutoUpdate=0
//
//	CheckBox DisplayDis1, disable=1, win=IR1_OneSampleEvaluationGraph
//	CheckBox DisplayDis2, disable=1, win=IR1_OneSampleEvaluationGraph
//	CheckBox DisplayDis3, disable=1, win=IR1_OneSampleEvaluationGraph
//	CheckBox DisplayDis4, disable=1, win=IR1_OneSampleEvaluationGraph
//	CheckBox DisplayDis5, disable=1, win=IR1_OneSampleEvaluationGraph
//
//	CheckBox AutoUpdate,  value =GR1_AutoUpdate , win=IR1_OneSampleEvaluationGraph
//	CheckBox DisplayND,value= GR1_DisplayND, win=IR1_OneSampleEvaluationGraph
//	CheckBox DisplayVD,value= GR1_DisplayVD, win=IR1_OneSampleEvaluationGraph
//
//	if (NumberOfDistributions>=1)
//			CheckBox DisplayDis1, disable=0, win=IR1_OneSampleEvaluationGraph, value=	GR1_DisplayDistribution1	
//	endif
//	if (NumberOfDistributions>=2)
//			CheckBox DisplayDis2, disable=0, win=IR1_OneSampleEvaluationGraph, value=	GR1_DisplayDistribution2	
//	endif
//	if (NumberOfDistributions>=3)
//			CheckBox DisplayDis3, disable=0, win=IR1_OneSampleEvaluationGraph, value=	GR1_DisplayDistribution3	
//	endif
//	if (NumberOfDistributions>=4)
//			CheckBox DisplayDis4, disable=0, win=IR1_OneSampleEvaluationGraph, value=	GR1_DisplayDistribution4	
//	endif
//	if (NumberOfDistributions>=5)
//			CheckBox DisplayDis5, disable=0, win=IR1_OneSampleEvaluationGraph, value=	GR1_DisplayDistribution5	
//	endif

end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************



Proc  IR1G_OneSampleEvaluationGraph() 
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:SASDataEvaluation:
	Display /W=(5.25,42,1000,590)/K=1 /R  as "Evaluate Irena results"
	DoWIndow/C IR1G_OneSampleEvaluationGraph
	SetDataFolder fldrSav
	ShowInfo
	ControlBar 130

	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	string ResultsNameStrings="SizesVolumeDistribution;SizesNumberDistribution;VolumeDistModelLSQF2;NumberDistModelLSQF2;ModelingVolumeDistribution;ModelingNumberDistribution;"
	ResultsNameStrings+="ModelingVolDist_Pop1;ModelingNumDist_Pop1;"
	ResultsNameStrings+="ModelingVolDist_Pop2;ModelingNumDist_Pop2;"
	ResultsNameStrings+="ModelingVolDist_Pop3;ModelingNumDist_Pop3;"
	ResultsNameStrings+="ModelingVolDist_Pop4;ModelingNumDist_Pop4;"
	ResultsNameStrings+="ModelingVolDist_Pop5;ModelingNumDist_Pop5;"
	IR2C_AddDataControls("SASDataEvaluation","IR1G_OneSampleEvaluationGraph","",ResultsNameStrings,UserDataTypes,UserNameString,XUserLookup,EUserLookup, 0,1)
	
	Checkbox UseResults , disable=1
	Checkbox UseModelData, disable=1
	Checkbox UseQRSData, disable=1
	PopupMenu SelectDataFolder, pos={8,15}
	PopupMenu QvecDataName, disable =0, pos={8,40}
	Popupmenu IntensityDataName, disable =0, pos={8,65}
	PopupMenu ErrorDataName, disable=1
	
//	NVAR UseResults=root:Packages:SASDataEvaluation:UseResults
	UseResults=1
//	NVAR UseQRSData=root:Packages:SASDataEvaluation:UseQRSData
	UseQRSData=0
//	NVAR UseModelData=root:Packages:SASDataEvaluation:UseModelData
	UseModelData=0
//	PopupMenu IntensityDataName, pos={8,50}
	SetVariable diameterMin,pos={490,18},size={180,16},title="Selected size min:  ", format="%3.1f", disable=2, help={"This is start diameter for evaluation, cursor A position"}
	SetVariable diameterMin,limits={-Inf,Inf,0},value= root:Packages:SASDataEvaluation:GR1_diameterMin
	SetVariable diameterMax,pos={490,38},size={180,16},title="Selected size max: ", format="%3.1f", disable=2, help={"This is end diameter for evaluation, cursor B position"}
	SetVariable diameterMax,limits={-Inf,Inf,0},value= root:Packages:SASDataEvaluation:GR1_diameterMax
	SetVariable Volume,pos={490,58},size={180,16},title="Volume in the range   ", format="%3.4f", disable=2, help={"This is total volume of scatterers in the range (fraction, between csr A and B)"}
	SetVariable Volume,limits={-Inf,Inf,0},value= root:Packages:SASDataEvaluation:GR1_Volume
	SetVariable Number,pos={490,78},size={250,16},title="Number density [1/cm3]       ", format="%1.3e", disable=2, help={"This is total number of scatterers in cm3 in the range evaluated *between csr A and B)"}
	SetVariable Number,limits={-Inf,Inf,0},value= root:Packages:SASDataEvaluation:GR1_NumberDens
	SetVariable PorodSurface,pos={490,98},size={250,16},title="Specific surface area [cm2/cm3]", format="%3.1e"
	SetVariable PorodSurface,limits={-Inf,Inf,0},value= root:Packages:SASDataEvaluation:GR1_PorodSurface, disable=2, help={"This is total specificc surface area (cm2/cm3) in the range evaluated (between csr A and B)"}

	SetVariable NumerOrVolume,pos={490,2},size={450,16},title="Statistics for:"//, format="%3.1f"
	SetVariable NumerOrVolume,limits={-Inf,Inf,0},value= root:Packages:SASDataEvaluation:GR1_NumberOrVolumeDist

	SetVariable MeanV,pos={750,27},size={110,16},title="Mean    ", format="%3.1f", disable=2, help={"This is mean value in the range evaluated"}
	SetVariable MeanV,limits={-Inf,Inf,0},value= root:Packages:SASDataEvaluation:GR1_Mean
	SetVariable Mode,pos={750,49},size={110,16},title="Mode    ", format="%3.1f", disable=2, help={"This is mode value in the range evaluated"}
	SetVariable Mode,limits={-Inf,Inf,0},value= root:Packages:SASDataEvaluation:GR1_Mode
	SetVariable Median,pos={750,72},size={110,16},title="Median  ", format="%3.1f", disable=2, help={"This is median value in the range evaluated"}
	SetVariable Median,limits={-Inf,Inf,0},value= root:Packages:SASDataEvaluation:GR1_Mode
	SetVariable FWHM,pos={750,95},size={110,16},title="FWHM   ", format="%3.1f", disable=2, help={"This is Full width at half max value in the range evaluated, meaningful for one peak only"}
	SetVariable FWHM,limits={-Inf,Inf,0},value= root:Packages:SASDataEvaluation:GR1_FWHM


//	CheckBox QLogScale,pos={100,135},size={90,14},disable=1,proc=IR2C_InputPanelCheckboxProc,title="Log-Q stepping?"
//	CheckBox QLogScale,help={"Check, if you want to generate Q in log scale"}
//	CheckBox QLogScale,variable= root:Packages:IrenaControlProcs:IR1G_OneSampleEvaluationGraph:QLogScale

	PopupMenu  EvaluatePopulationNumber, pos={20,90}, size={100,20},    title="Shape of populations"
	PopupMenu EvaluatePopulationNumber proc=IR1G_PopProc,value="1;2;3;4;5;", disable=2, help={"If the data were produced with more than one particle shape, select the appropriate."}

	CheckBox AutoUpdate,pos={372,16},size={111,14},proc=IR1G_CheckProc,title="Auto-update"
	CheckBox AutoUpdate,variable= root:Packages:SASDataEvaluation:GR1_AutoUpdate, help={"Check to have results updated after every change of cursor position"}

	Button GetHelp,pos={305,1},size={80,15},fColor=(65535,32768,32768), proc=IR1G_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}

	Button AddData,pos={368,34},size={100,18},proc=IR1G_ButtonProc,title="Add data "
	Button AddData,  help={"Select data on the left and push to add data in the graph"}
	Button ClearGraph,pos={368,54},size={100,18},proc=IR1G_ButtonProc,title="Clear All data"
	Button ClearGraph,  help={"Remove all data from graph"}
	Button SaveCumulativeSizeDist,pos={368,74},size={100,18},proc=IR1G_ButtonProc,title="Save Cum/MIP Crvs."
	Button SaveCumulativeSizeDist,  help={"Saves the new data types - cumulative data and MIP data"}
	Button Calculate,pos={368,94},size={100,18},   proc=IR1G_ButtonProc,title="Calculate ", help={"Forces recalculation of the data"}
	Button AppendTag,pos={368,114},size={100,18},   proc=IR1G_ButtonProc,title="Append tag", help={"Appends tag to the data with statistics"}
	
	CheckBox LogXAxis,pos={870,15},size={63,14},proc=IR1G_CheckProc,title="Log X axis"
	CheckBox LogXAxis,variable= root:Packages:SASDataEvaluation:LogXAxis, help={"Check to have x-axis log scale"}
	CheckBox CalcCumulativeSizeDist,pos={870,33},size={83,14},proc=IR1G_CheckProc,title="Cumulative Curves?"
	CheckBox CalcCumulativeSizeDist,variable= root:Packages:SASDataEvaluation:CalcCumulativeSizeDist, help={"Calculate and attach dumulative curves"}
	CheckBox InvertCumulativeDists,pos={870,51},size={83,14},proc=IR1G_CheckProc,title="Invert Cumul Curves?"
	CheckBox InvertCumulativeDists,variable= root:Packages:SASDataEvaluation:InvertCumulativeDists, help={"Invert cumulative curves to have 0 value at large sizes"}
	CheckBox CalcMIPdata,pos={870,69},size={83,14},proc=IR1G_CheckProc,title="MIP Curves?"
	CheckBox CalcMIPdata,variable= root:Packages:SASDataEvaluation:CalcMIPdata, help={"Calculate Mercury intrusion data from the size dists"}


	SetVariable MIPUserSigma,pos={870,89},size={120,13},title="MIP sigma ", format="%3.1f", help={"Assumed sigma for MIP calcs. Units: dynes/cm, usually 285 dynes/cm"}
	SetVariable MIPUserSigma,limits={300,700,0},value= root:Packages:SASDataEvaluation:MIPUserSigma, disable = !(root:Packages:SASDataEvaluation:CalcMIPdata), proc=IR1G_SetVarProc
	SetVariable MIPCosTheta,pos={870,109},size={120,13},title="MIP cos(theta) ", format="%3.4f", help={"Assumed cos(theta) for MIP calcs. Unitless, usually -0.766"}
	SetVariable MIPCosTheta,limits={-1,-0.1,0},value= root:Packages:SASDataEvaluation:MIPUserCosTheta, disable = !(root:Packages:SASDataEvaluation:CalcMIPdata), proc=IR1G_SetVarProc

	TitleBox Title1,pos={1,1},size={82,24}, frame=0, labelBack=(16384,65280,16384 ) 
	TitleBox Title1,title="   Data control    "
	TitleBox Title4,pos={420,1},size={82,24}, frame=0, labelBack=(65280,54528,32768 ) 
	TitleBox Title4,title="   Results  :  "
	TitleBox Title2,pos={5,115},size={82,24}, frame=0
	TitleBox Title2,title="Select range of data with cursors"
	TitleBox Title3,pos={190,115},size={82,24}, frame=0
	TitleBox Title3,title="Set cursors to the same data!!"
EndMacro

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1G_CreateAveVolSfcWvUsingNote(AveDataWave,DiameterWave,NoteStr,VolOrSfc)
	wave AveDataWave,DiameterWave
	string NoteStr, VolOrSfc
	// set VolOrSfc to either "Volume" or "Surface"

	string OldDf=getDataFolder(1)
	SetDataFolder  root:Packages:SASDataEvaluation
	variable Par1, Par2, Par3, Par4, Par5, Par6
	variable UPar1, UPar2, UPar3, UPar4, UPar5
	string UserVolFunct="", ShapeType=""
	
	
	if(stringmatch(NoteStr,"*SizesDataFrom*"))		//data from Size dsistributioon package
		//ListOfFormFactorsSD="Spheroid;Cylinder;CylinderAR;Unified_Sphere;Unified_Rod;Unified_RodAR;Unified_Disk;Unified_Tube;"
		shapeType= StringByKey("ShapeType", NoteStr , "=" ,";")
		if(strlen(ShapeType)<3)
			DoAlert 0, "Bad ShapeType in IR1G_CreateAveVolSfcWvUsingNote"
		endif
		if(stringMatch(ShapeType,"Cylinder"))
			Par1 = numberByKey("CylinderLength", NoteStr , "=" ,";")
		elseif(stringMatch(ShapeType,"Unified_Sphere"))
		
		elseif(stringMatch(ShapeType,"Unified_Disk") || stringMatch(ShapeType,"Unified_Disc"))
			Par1 = numberByKey("AspectRatio", NoteStr , "=" ,";")
		elseif(stringMatch(ShapeType,"Unified_Rod"))
			Par1 = numberByKey("AspectRatio", NoteStr , "=" ,";")
		elseif(stringMatch(ShapeType,"Unified_Tube"))
			Par1 = numberByKey("TubeLength", NoteStr , "=" ,";")
			Par2 = numberByKey("TubeWallThickness", NoteStr , "=" ,";")
		else	//spheroid, CylinderAR, Integrated_Spheroid,Unified_RodAR,NoFF_setTo1
			Par1 = numberByKey("AspectRatio", NoteStr , "=" ,";")		
		endif
	elseif(stringmatch(NoteStr,"*DistributionTypeModelled*"))		//date from Modeling I package, total of size distribution..
		print "These data may contain mixture of shapes for different populations. Please select the right population number to evaluate"
		NVAR EvaluatePopulationNumber=root:Packages:SASDataEvaluation:EvaluatePopulationNumber
		shapeType= StringByKey("Dist"+num2str(EvaluatePopulationNumber)+"ShapeModel", NoteStr , "=" ,";")
			Par1 = numberByKey("Dist"+num2str(EvaluatePopulationNumber)+"ScatShapeParam1", NoteStr , "=" ,";")
			Par2 = numberByKey("Dist"+num2str(EvaluatePopulationNumber)+"ScatShapeParam2", NoteStr , "=" ,";")
			Par3 = numberByKey("Dist"+num2str(EvaluatePopulationNumber)+"ScatShapeParam3", NoteStr , "=" ,";")
			Par4 = 0
			Par5 = 0
	elseif(stringmatch(NoteStr,"*DistShapeModel:*"))		//date from Modeling I package, partial of size distribution..
		shapeType= StringByKey("DistShapeModel", NoteStr , ":" ,";")
			Par1 = numberByKey("DistScatShapeParam1", NoteStr , ":" ,";")
			Par2 = numberByKey("DistScatShapeParam2", NoteStr , ":" ,";")
			Par3 = numberByKey("DistScatShapeParam3", NoteStr , ":" ,";")
			Par4 = 0
			Par5 = 0
	elseif(stringmatch(NoteStr,"*FormFactor_pop*"))		//date from Modeling II package, total of size distribution..
		print "These data may contain mixture of shapes for different populations. Please select the right population number to evaluate"
		NVAR EvaluatePopulationNumber=root:Packages:SASDataEvaluation:EvaluatePopulationNumber
		shapeType= StringByKey("FormFactor_pop"+num2str(EvaluatePopulationNumber), NoteStr , "=" ,";")
			Par1 = numberByKey("FormFactor_Param1_pop"+num2str(EvaluatePopulationNumber), NoteStr , "=" ,";")
			Par2 = numberByKey("FormFactor_Param2_pop"+num2str(EvaluatePopulationNumber), NoteStr , "=" ,";")
			Par3 = numberByKey("FormFactor_Param3_pop"+num2str(EvaluatePopulationNumber), NoteStr , "=" ,";")
			Par4 = numberByKey("FormFactor_Param4_pop"+num2str(EvaluatePopulationNumber), NoteStr , "=" ,";")
			Par5 = numberByKey("FormFactor_Param5_pop"+num2str(EvaluatePopulationNumber), NoteStr , "=" ,";")
			Par6 = numberByKey("FormFactor_Param6_pop"+num2str(EvaluatePopulationNumber), NoteStr , "=" ,";")
			UserVolFunct = StringByKey("FFUserFFformula_pop"+num2str(EvaluatePopulationNumber), NoteStr , "=" ,";")
			UPar1 = numberByKey("FormFactor_Param1_pop"+num2str(EvaluatePopulationNumber), NoteStr , "=" ,";")
			UPar2 = numberByKey("FormFactor_Param2_pop"+num2str(EvaluatePopulationNumber), NoteStr , "=" ,";")
			UPar3 = numberByKey("FormFactor_Param3_pop"+num2str(EvaluatePopulationNumber), NoteStr , "=" ,";")
			UPar4 = numberByKey("FormFactor_Param4_pop"+num2str(EvaluatePopulationNumber), NoteStr , "=" ,";")
			UPar5 = numberByKey("FormFactor_Param5_pop"+num2str(EvaluatePopulationNumber), NoteStr , "=" ,";")
			//UPar6 = numberByKey("FormFactor_Param6_pop"+num2str(EvaluatePopulationNumber), NoteStr , "=" ,";")
		
	else
	DoAlert 0, "Do not know yet these data, fix IR1G_CreateAveVolSfcWvUsingNote"
	
	endif
	
	if(Stringmatch(VolOrSfc,"Volume"))		//volume
	 	 IR1T_CreateAveVolumeWave(AveDataWave,DiameterWave,ShapeType,Par1,Par2,Par3,Par4,Par5,UserVolFunct,UPar1,UPar2,UPar3,UPar4,UPar5)
	else		//surface
	 	 IR1T_CreateAveSurfaceAreaWave(AveDataWave,DiameterWave,ShapeType,Par1,Par2,Par3,Par4,Par5,UserVolFunct,UPar1,UPar2,UPar3,UPar4,UPar5)	
	endif
	


	setDataFolder OldDf
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1G_FindNumOfPopsUsed(WaveWithWv)	//return number of populations (1..5) or for separate populations, returns the population number (as negative value)
	wave WaveWithWv
	
	string OldDf=getDataFolder(1)
	SetDataFolder  root:Packages:SASDataEvaluation
	string WvName=NameOfWave(WaveWithWv)
	variable numOfPops=0
	string WvNote=note(WaveWithWv)
	variable i
	
	if(stringMatch(WvName, "SizesVolume*") || stringMatch(WvName,"SizesNumber*"))
		numOfPops=0
	elseif(stringMatch(WvName, "ModelingVolDist*") || stringMatch(WvName,"ModelingNumDist*")) //separate Modeling I results
		numOfPops=-1*(str2num(WvName[strsearch(WvName, "Pop", 0,2)+3, strsearch(WvName, "Pop", 0,2)+4]))
	elseif (stringMatch(WvName, "ModelingVolumeDistribution*") || stringMatch(WvName,"ModelingNumberDistribution*")) //Modeling I results
		//need to fix...
		For(i=1;i<=5;i+=1)
			if(stringmatch(WvNote, "*;Dist"+num2str(i)+"DistributionType=*" ))
				numOfPops=i
			endif
		endfor
	elseif (stringMatch(WvName, "VolumeDistModelLSQF2_*") || stringMatch(WvName,"NumberDistModelLSQF2_*")) //Modeling II results
		//need to fix...
		//For(i=1;i<=6;i+=1)
			//if(stringmatch(WvNote, "*;Dist"+num2str(i)+"DistributionType=*" ))
				//numOfPops=i
			//endif
		//endfor
		numOfPops=6
	else
	
	endif

	setDataFolder OldDf
	return numOfPops
end
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************

Function IR1G_PopProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr
	
	NVAR EvaluatePopulationNumber=root:Packages:SASDataEvaluation:EvaluatePopulationNumber
	//blah blah...
	if(stringmatch(ctrlname,"EvaluatePopulationNumber"))
		EvaluatePopulationNumber=str2num(popStr[0])
	endif
End
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1G_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	If(stringmatch(ctrlname,"MIPUserSigma") || stringmatch(ctrlName,"MIPCosTheta"))
			IR1G_CalculateStatistics()	
	endif
End
