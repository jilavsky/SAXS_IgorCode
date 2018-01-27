#pragma rtGlobals=1		// Use modern global access method.

Menu "USAXS"
	"---"
	"ASAXS", IN2L_MainASAXS()
	"---"
end



Function IN2L_MainASAXS()

	IN2L_Initialize()

	DoWIndow IN2L_ASXASControlPanel
	if(V_Flag)
		DoWindow/K IN2L_ASXASControlPanel
	endif
	Execute("IN2L_ASXASControlPanel()")

	DoWIndow IN2L_ASAXSGraph1
	if(V_Flag)
		DoWindow/K IN2L_ASAXSGraph1
	endif
	Execute(" IN2L_ASAXSGraph1()")

	DoWIndow IN2L_ASAXSGraph2
	if(V_Flag)
		DoWindow/K IN2L_ASAXSGraph2
	endif
	Execute(" IN2L_ASAXSGraph2()")

end


Function IN2L_AnalyzeASAXSInSteps(ctrlName) : ButtonControl
	String ctrlName
	
	
	setDataFolder root:Packages:ASAXS
	
	WAVE/Z ASAXS_Slope
	variable Cycles, i, time0
	NVAR CurrentEvaluationPoint
	NVAR NextEvaluationPoint
	NVAR DelayBetweenFrames
	NVAR PauseEvaluation

	//and here we analyze ASAXS in steps
	IN2L_RecordParameters()
	IN2L_InitializeAnalyzeASAXS()
	
	CurrentEvaluationPoint=NextEvaluationPoint
	
	DoWindow IN2L_ASAXSEvaluationGraph
	if (V_Flag)
		DoWindow/K IN2L_ASAXSEvaluationGraph
	endif
	Execute("IN2L_ASAXSEvaluationGraph()")
	
	IN2L_WriteASAXSWaves(NextEvaluationPoint)		//writes data in wave
	IN2L_FitLine(NextEvaluationPoint)					//does the fit & records results
		
	DoUpdate						//plot is updated
	
	NextEvaluationPoint+=1

End

Function IN2L_AnalyzeASAXS(ctrlName) : ButtonControl
	String ctrlName

	setDataFolder root:Packages:ASAXS
	
	variable Cycles, i, time0
	NVAR CurrentEvaluationPoint
	NVAR NextEvaluationPoint
	NVAR DelayBetweenFrames
	NVAR PauseEvaluation
	
	//and here goes procedure to analyze data with ASAXS
	IN2L_RecordParameters()
	IN2L_InitializeAnalyzeASAXS()
	WAVE/Z ASAXS_Slope
	wave/Z ASAXS_Diameters
	
	DoWindow IN2L_ASAXSEvaluationGraph
	if (V_Flag)
		DoWindow/K IN2L_ASAXSEvaluationGraph
	endif
	Execute("IN2L_ASAXSEvaluationGraph()")
	
	cycles=numpnts(ASAXS_Slope)
	string/g diameter
	diameter=""
	
	For (i=0;i<cycles;i+=1)		//here we run through all point and do the evaluation in pieces
		CurrentEvaluationPoint=i
		diameter=num2str (ASAXS_Diameters[CurrentEvaluationPoint])
		IN2L_WriteASAXSWaves(i)		//writes data in wave
		IN2L_FitLine(i)					//does the fit & records results
		
		DoUpdate						//plot is updated
		
		time0=ticks				//creates delay
		do
		while(ticks<(time0+DelayBetweenFrames*60))	
	endfor
	
	DoWindow ASAXS_InterceptsFit
	If(V_Flag)
		DoWindow/K ASAXS_InterceptsFit
	endif
	Execute("ASAXS_InterceptsFit()")
//	IN2L_AppendASAXSToGraph1()
End


Function IN2L_AppendASAXSToGraph1()

	setDataFolder root:Packages:ASAXS:
	WAVE ASAXS_Intercept
	WAVE ASAXS_Diameters
	
	AppendToGraph /W=IN2L_ASAXSGraph1 ASAXS_Intercept vs ASAXS_Diameters
end
//****************************************************************************************************************************
//****************************************************************************************************************************
//****************************************************************************************************************************

Window ASAXS_InterceptsFit() : Graph
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:ASAXS:
	Display /W=(535,51,1003,386)/K=1  ASAXS_Intercept vs ASAXS_Diameters as "ASAXS_InterceptsFit"
	AppendToGraph/R ASAXS_Slope vs ASAXS_Diameters
	SetDataFolder fldrSav
	ModifyGraph mode=4
	ModifyGraph marker=1
	ModifyGraph rgb(ASAXS_Intercept)=(0,0,0),rgb(ASAXS_Slope)=(65280,0,0)
	ModifyGraph msize=2
	ModifyGraph mirror(bottom)=1
	Label left "\\Z12Volume content extrapolated from intercepts "
	Label bottom "\\Z12Diameter [A]"
	Label right "\\Z12\\K(65280,0,0)From slopes "
	ErrorBars/Y=1 ASAXS_Intercept Y,wave=(:Packages:ASAXS:ASAXS_InterceptError,:Packages:ASAXS:ASAXS_InterceptError)
	ErrorBars/Y=1 ASAXS_Slope Y,wave=(:Packages:ASAXS:ASAXS_SlopeError,:Packages:ASAXS:ASAXS_SlopeError)
	Legend/N=Legend1/J/A=MT/X=0.00/Y=0.00/E "\\s(ASAXS_Intercept) ASAXS_Intercept  \\s(ASAXS_Slope) ASAXS_Slope"
	ShowInfo
	Button RemovePoint,pos={12,386},size={100,20},proc=IN2G_SetPointWithCsrAToNaN,title="Set Pnt to NaN"
EndMacro

//****************************************************************************************************************************
//****************************************************************************************************************************
//****************************************************************************************************************************



Function IN2L_RecordResults(ctrlName) : ButtonControl
	String ctrlName

	setDataFolder root:Packages:ASAXS:

	WAVE/Z VolumeDistribution1
	WAVE/Z VolumeDistribution2
	WAVE/Z VolumeDistribution3
	WAVE/Z VolumeDistribution4
	WAVE/Z VolumeDistribution5
	WAVE/Z VolumeDistribution6
	WAVE/Z VolumeDistribution7
	WAVE/Z VolumeDistribution8
	WAVE/Z DiameterDistribution1
	WAVE/Z DiameterDistribution2
	WAVE/Z DiameterDistribution3
	WAVE/Z DiameterDistribution4
	WAVE/Z DiameterDistribution5
	WAVE/Z DiameterDistribution6
	WAVE/Z DiameterDistribution7
	WAVE/Z DiameterDistribution8
	Wave ASAXS_Intercept
	Wave ASAXS_InterceptError
	Wave ASAXS_Slope
	Wave ASAXS_SlopeError
	Wave ASAXS_Diameters
	Wave/Z DSM_Int1
	Wave/Z DSM_Qvec1
	Wave/Z DSM_Error1
	Wave/Z DSM_Int2
	Wave/Z DSM_Qvec2
	Wave/Z DSM_Error2
	Wave/Z DSM_Int3
	Wave/Z DSM_Qvec3
	Wave/Z DSM_Error3
	Wave/Z DSM_Int4
	Wave/Z DSM_Qvec4
	Wave/Z DSM_Error4
	Wave/Z DSM_Int5
	Wave/Z DSM_Qvec5
	Wave/Z DSM_Error5
	Wave/Z DSM_Int6
	Wave/Z DSM_Qvec6
	Wave/Z DSM_Error6
	Wave/Z DSM_Int7
	Wave/Z DSM_Qvec7
	Wave/Z DSM_Error7
	Wave/Z DSM_Int8
	Wave/Z DSM_Qvec8
	Wave/Z DSM_Error8
	
	SVAR EnergyFolder1
	SVAR SampleName1
	NVAR UseSet1
	SVAR EnergyFolder2
	SVAR SampleName2
	NVAR UseSet2
	SVAR EnergyFolder3
	SVAR SampleName3
	NVAR UseSet3
	SVAR EnergyFolder4
	SVAR SampleName4
	NVAR UseSet4
	SVAR EnergyFolder5
	SVAR SampleName5
	NVAR UseSet5
	SVAR EnergyFolder6
	SVAR SampleName6
	NVAR UseSet6
	SVAR EnergyFolder7
	SVAR SampleName7
	NVAR UseSet7
	SVAR EnergyFolder8
	SVAR SampleName8
	NVAR UseSet8
	NVAR Contrast1
	NVAR Contrast2
	NVAR Contrast3
	NVAR Contrast4
	NVAR Contrast5
	NVAR Contrast6
	NVAR Contrast7
	NVAR Contrast8
	NVAR ContrastVoids
	SVAR ASAXSListOfOptions

	NewDataFolder/O root:ASAXS
	
//	SVAR root:Packages:ASAXS:OutputFolder
//	 Abort "Fix routine IN2L_RecordResults"
	
	if ((UseSet1+UseSet2+UseSet3+UseSet4+UseSet5+UseSet6+UseSet7+UseSet8)<1)
		Abort
	endif
	
	string NewFolderName=stringFromList(ItemsInList(SampleName1,":")-1,SampleName1,":")
	
	Prompt NewFolderName, "Create folder name for output data"
	
	DoPrompt "Input for export ASAXS", NewFolderName
	
	NewFolderName=PossiblyQuoteName(NewFolderName)
	
	NewDataFolder/S/O $("root:ASAXS:"+NewFolderName)
	
	string/G ASAXSEvaluationOptions=ASAXSListOfOptions
	
	Duplicate/O ASAXS_Intercept, ASAXS_Intercept
	Duplicate/O  ASAXS_InterceptError, ASAXS_InterceptError
	Duplicate/O  ASAXS_Slope, ASAXS_Slope
	Duplicate/O  ASAXS_SlopeError, ASAXS_SlopeError
	Duplicate/O  ASAXS_Diameters, ASAXS_Diameters

	if (UseSet1)
		Duplicate/O VolumeDistribution1, VolumeDistribution1
		Duplicate/O DSM_Int1, DSM_Int1
		Duplicate/O DSM_Qvec1, DSM_Qvec1
		Duplicate/O DSM_Error1, DSM_Error1
		Duplicate/O DiameterDistribution1,DiameterDistribution1
	endif
	
	if (UseSet2)
		Duplicate/O VolumeDistribution2, VolumeDistribution2
		Duplicate/O DiameterDistribution2, DiameterDistribution2
		Duplicate/O DSM_Int2, DSM_Int2
		Duplicate/O DSM_Qvec2, DSM_Qvec2
		Duplicate/O DSM_Error2, DSM_Error2
	
	endif
	if (UseSet3)
		Duplicate/O VolumeDistribution3, VolumeDistribution3
		Duplicate/O DiameterDistribution3, DiameterDistribution3
		Duplicate/O DSM_Int3, DSM_Int3
		Duplicate/O DSM_Qvec3, DSM_Qvec3
		Duplicate/O DSM_Error3, DSM_Error3
	endif
	if (UseSet4)
		Duplicate/O VolumeDistribution4, VolumeDistribution4
		Duplicate/O DiameterDistribution4, DiameterDistribution4
		Duplicate/O DSM_Int4, DSM_Int4
		Duplicate/O DSM_Qvec4, DSM_Qvec4
		Duplicate/O DSM_Error4, DSM_Error4
	endif
	if (UseSet5)
		Duplicate/O VolumeDistribution5, VolumeDistribution5
		Duplicate/O DiameterDistribution5, DiameterDistribution5
		Duplicate/O DSM_Int5, DSM_Int5
		Duplicate/O DSM_Qvec5, DSM_Qvec5
		Duplicate/O DSM_Error5,DSM_Error5
	endif
	if (UseSet6)
		Duplicate/O VolumeDistribution6, VolumeDistribution6
		Duplicate/O DiameterDistribution6, DiameterDistribution6
		Duplicate/O DSM_Int6, DSM_Int6
		Duplicate/O DSM_Qvec6, DSM_Qvec6
		Duplicate/O DSM_Error6, DSM_Error6
	endif
	if (UseSet7)
		Duplicate/O VolumeDistribution7, VolumeDistribution7
		Duplicate/O DiameterDistribution7, DiameterDistribution7
		Duplicate/O DSM_Int7, DSM_Int7
		Duplicate/O DSM_Qvec7, DSM_Qvec7
		Duplicate/O DSM_Error7, DSM_Error7
	endif
	if (UseSet8)
		Duplicate/O VolumeDistribution8, VolumeDistribution8
		Duplicate/O DiameterDistribution8, DiameterDistribution8
		Duplicate/O DSM_Int8, DSM_Int8
		Duplicate/O DSM_Qvec8, DSM_Qvec8
		Duplicate/O DSM_Error8, DSM_Error8
	endif
	
	if (UseSet1)
		IN2G_AppendNoteToAllWaves("SampleName1",StringByKey("SampleName1", ASAXSListOfOptions, "="))
		IN2G_AppendNoteToAllWaves("Contrast1",StringByKey("Contrast1", ASAXSListOfOptions, "="))	
	endif	
	if (UseSet2)
		IN2G_AppendNoteToAllWaves("SampleName2",StringByKey("SampleName2", ASAXSListOfOptions, "="))
		IN2G_AppendNoteToAllWaves("Contrast2",StringByKey("Contrast2", ASAXSListOfOptions, "="))	
	endif	
	if (UseSet3)
		IN2G_AppendNoteToAllWaves("SampleName3",StringByKey("SampleName3", ASAXSListOfOptions, "="))
		IN2G_AppendNoteToAllWaves("Contrast3",StringByKey("Contrast3", ASAXSListOfOptions, "="))	
	endif	
	if (UseSet4)
		IN2G_AppendNoteToAllWaves("SampleName4",StringByKey("SampleName4", ASAXSListOfOptions, "="))
		IN2G_AppendNoteToAllWaves("Contrast4",StringByKey("Contrast4", ASAXSListOfOptions, "="))	
	endif	
	if (UseSet5)
		IN2G_AppendNoteToAllWaves("SampleName5",StringByKey("SampleName5", ASAXSListOfOptions, "="))
		IN2G_AppendNoteToAllWaves("Contrast5",StringByKey("Contrast5", ASAXSListOfOptions, "="))	
	endif	
	if (UseSet6)
		IN2G_AppendNoteToAllWaves("SampleName6",StringByKey("SampleName6", ASAXSListOfOptions, "="))
		IN2G_AppendNoteToAllWaves("Contrast6",StringByKey("Contrast6", ASAXSListOfOptions, "="))	
	endif	
	if (UseSet7)
		IN2G_AppendNoteToAllWaves("SampleName7",StringByKey("SampleName7", ASAXSListOfOptions, "="))
		IN2G_AppendNoteToAllWaves("Contrast7",StringByKey("Contrast7", ASAXSListOfOptions ,"="))	
	endif	
	if (UseSet8)
		IN2G_AppendNoteToAllWaves("SampleName8",StringByKey("SampleName8", ASAXSListOfOptions,"="))
		IN2G_AppendNoteToAllWaves("Contrast8",StringByKey("Contrast8", ASAXSListOfOptions ,"="))	
	endif	

		IN2G_AppendNoteToAllWaves("ContrastVoids",StringByKey("ContrastVoids", ASAXSListOfOptions ,"="))	

end


//****************************************************************************************************************************
//****************************************************************************************************************************
//****************************************************************************************************************************


Function IN2L_FitLine(point)
	variable point
	
	setDataFolder root:Packages:ASAXS:
	wave ASAXS_Intercept
	wave ASAXS_InterceptError
	wave ASAXS_SlopeError
	wave ASAXS_Slope
	wave/Z W_coef
	NVAR ContrastVoids
	wave PointVolumeContent
	wave PointContrasts
	
 
 
	wavestats PointVolumeContent

	if ((V_avg>0)&&((V_avg-V_sdev)>0))

// this needs some fixing
// 	CurveFit/O line PointVolumeContent /X=PointContrasts
//	K0=abs(W_Coef[0])
//	K1=abs(W_Coef[1])
//	
//	Make/O/T/N=2 T_Constraints
//	T_Constraints[0] = {"K0 > 0","K1 > 0"}
//	CurveFit/N/Q/G line kwCWave=W_coef, PointVolumeContent /X=PointContrasts /D /C=T_Constraints 
//
//	TextBox/C/N=text0/F=0/A=MC "Results are: intercept="+num2str((W_coef[0]))+"    & slope="+num2str((W_coef[1]))
//	
//	ASAXS_Intercept[point]=((W_coef[0]))/ContrastVoids
//	ASAXS_Slope[point]=(W_Coef[1])
//	ASAXS_InterceptError[point]=(W_sigma[0])/ContrastVoids
//	ASAXS_SlopeError[point]=W_sigma[1]


		if(!WaveExists(W_coef))
			Make/O/N=2 W_coef
			Wave W_Coef
		endif
		
		W_coef[0]  = sqrt(abs(V_avg))
		
		variable slopeMin=1e-7
		
		if (W_coef[1]<=slopeMin)
			W_coef[1] =200*slopeMin
			K1=200*slopeMin
		endif

		Make/D/O/N=2 W_epsilon
		W_epsilon[0] = {1e-6,1e-6}
		Make/O/T/N=2 T_Constraints
		T_Constraints[0] = {"K0 > 1e-11","K1 > 1e-11"}
		FuncFit/N IN2L_LineFIt W_coef PointVolumeContent /X=PointContrasts /D /E=W_epsilon /C=T_Constraints 
		
	
		Wave W_sigma
		

//		Make/D/O/T/N=2 T_Constraints
//		T_Constraints[0] = {"K0 > 1e-11","K1 > 1e-11"}
//		FuncFit /G IN2L_LineFIt W_coef PointVolumeContent /X=PointContrasts /D /C=T_Constraints

	// TextBox/C/N=text0/A=MT/E
		TextBox/C/N=text0/F=0/A=MT/E "Results: intercept="+num2str((W_coef[0])^2)+"    & slope="+num2str((W_coef[1])^2)
	
		ASAXS_Intercept[point]=((W_coef[0])^2)/ContrastVoids
		ASAXS_Slope[point]=(W_Coef[1])^2
		ASAXS_InterceptError[point]=(W_sigma[0]*W_coef[0])/ContrastVoids
		ASAXS_SlopeError[point]=W_sigma[1]*W_coef[1]
	else
		ASAXS_Intercept[point]=0
		ASAXS_Slope[point]=0
		ASAXS_InterceptError[point]=0
		ASAXS_SlopeError[point]=0
	endif
end


Function IN2L_LineFIt(w,x) : FitFunc
	Wave w
	Variable x

	//CurveFitDialog/ These comments were created by the Curve Fitting dialog. Altering them will
	//CurveFitDialog/ make the function less convenient to work with in the Curve Fitting dialog.
	//CurveFitDialog/ Equation:
	//CurveFitDialog/ f(x) = (a^2)+(b^2)*x
	//CurveFitDialog/ End of Equation
	//CurveFitDialog/ Independent Variables 1
	//CurveFitDialog/ x
	//CurveFitDialog/ Coefficients 2
	//CurveFitDialog/ w[0] = a
	//CurveFitDialog/ w[1] = b

	return (w[0]^2)+(w[1]^2)*x
End


//****************************************************************************************************************************
//****************************************************************************************************************************
//****************************************************************************************************************************



Window IN2L_ASAXSEvaluationGraph() : Graph
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:ASAXS:
	Display /W=(537,419,1009,730)/K=1  PointVolumeContent vs PointContrasts as "IN2L_ASAXSEvaluationGraph"
	AppendToGraph fit_PointVolumeContent
	SetDataFolder fldrSav
	ModifyGraph mode(PointVolumeContent)=3
	ModifyGraph marker(PointVolumeContent)=19
	ModifyGraph rgb(PointVolumeContent)=(0,0,0)
	ModifyGraph msize(PointVolumeContent)=6
	ModifyGraph mirror=1
	Label left "Volume content"
	Label bottom "Contrast"
	SetAxis/A/E=1 left
	SetAxis/A/E=1 bottom
	TextBox/N=text0/F=0/A=MT/X=4.87/Y=1.93/E "Results: intercept=5.6882e-05    & slope=5.43e-06"
	SetVariable CurrentDia,pos={5,298},size={155,15},title="Current Diameter [A]"
	SetVariable CurrentDia,fSize=9
	SetVariable CurrentDia,limits={0,0,0},value= root:Packages:ASAXS:diameter
EndMacro

//****************************************************************************************************************************
//****************************************************************************************************************************
//****************************************************************************************************************************


Function  IN2L_WriteASAXSWaves(point)
	variable point
	
	WAVE PointContrasts
	WAVE PointVolumeContent
	WAVE/Z VolumeDistribution1
	WAVE/Z VolumeDistribution2
	WAVE/Z VolumeDistribution3
	WAVE/Z VolumeDistribution4
	WAVE/Z VolumeDistribution5
	WAVE/Z VolumeDistribution6
	WAVE/Z VolumeDistribution7
	WAVE/Z VolumeDistribution8
	WAVE/Z DiameterDistribution1
	WAVE/Z DiameterDistribution2
	WAVE/Z DiameterDistribution3
	WAVE/Z DiameterDistribution4
	WAVE/Z DiameterDistribution5
	WAVE/Z DiameterDistribution6
	WAVE/Z DiameterDistribution7
	WAVE/Z DiameterDistribution8
	wave 	PointColors

	NVAR UseSet1
	NVAR UseSet2
	NVAR UseSet3
	NVAR UseSet4
	NVAR UseSet5
	NVAR UseSet6
	NVAR UseSet7
	NVAR UseSet8
	NVAR Contrast1
	NVAR Contrast2
	NVAR Contrast3
	NVAR Contrast4
	NVAR Contrast5
	NVAR Contrast6
	NVAR Contrast7
	NVAR Contrast8
	
	variable currentpoint=0

	if(numpnts(PointContrasts)!=(UseSet1+UseSet2+UseSet3+UseSet4+UseSet5+UseSet6+UseSet7+UseSet8))
		Abort "Error in wave lenths"
	endif
	
	if (UseSet1)
		PointContrasts[currentpoint]=Contrast1
		PointVolumeContent[currentpoint]=VolumeDistribution1[point]
		PointColors[currentpoint]=0
		currentpoint+=1
	endif
	if (UseSet2)
		PointContrasts[currentpoint]=Contrast2
		PointVolumeContent[currentpoint]=VolumeDistribution2[point]
		PointColors[currentpoint]=1.8
		currentpoint+=1
	endif
	if (UseSet3)
		PointContrasts[currentpoint]=Contrast3
		PointVolumeContent[currentpoint]=VolumeDistribution3[point]
		PointColors[currentpoint]=3
		currentpoint+=1
	endif
	if (UseSet4)
		PointContrasts[currentpoint]=Contrast4
		PointVolumeContent[currentpoint]=VolumeDistribution4[point]
		PointColors[currentpoint]=4
		currentpoint+=1
	endif
	if (UseSet5)
		PointContrasts[currentpoint]=Contrast5
		PointVolumeContent[currentpoint]=VolumeDistribution5[point]
		PointColors[currentpoint]=5
		currentpoint+=1
	endif
	if (UseSet6)
		PointContrasts[currentpoint]=Contrast6
		PointVolumeContent[currentpoint]=VolumeDistribution6[point]
		PointColors[currentpoint]=6
		currentpoint+=1
	endif
	if (UseSet7)
		PointContrasts[currentpoint]=Contrast7
		PointVolumeContent[currentpoint]=VolumeDistribution7[point]
		PointColors[currentpoint]=7
		currentpoint+=1
	endif
	if (UseSet8)
		PointContrasts[currentpoint]=Contrast8
		PointVolumeContent[currentpoint]=VolumeDistribution8[point]
		PointColors[currentpoint]=8
		currentpoint+=1
	endif
	
	
	
end

//****************************************************************************************************************************
//****************************************************************************************************************************
//****************************************************************************************************************************

Function IN2L_InitializeAnalyzeASAXS()

	setDataFolder root:Packages:ASAXS

	WAVE/Z VolumeDistribution1
	WAVE/Z VolumeDistribution2
	WAVE/Z VolumeDistribution3
	WAVE/Z VolumeDistribution4
	WAVE/Z VolumeDistribution5
	WAVE/Z VolumeDistribution6
	WAVE/Z VolumeDistribution7
	WAVE/Z VolumeDistribution8
	WAVE/Z DiameterDistribution1
	WAVE/Z DiameterDistribution2
	WAVE/Z DiameterDistribution3
	WAVE/Z DiameterDistribution4
	WAVE/Z DiameterDistribution5
	WAVE/Z DiameterDistribution6
	WAVE/Z DiameterDistribution7
	WAVE/Z DiameterDistribution8
	NVAR UseSet1
	NVAR UseSet2
	NVAR UseSet3
	NVAR UseSet4
	NVAR UseSet5
	NVAR UseSet6
	NVAR UseSet7
	NVAR UseSet8
	
	
	
	if ( UseSet1)
		Duplicate/O VolumeDistribution1, ASAXS_Slope, ASAXS_SlopeError, ASAXS_Intercept, ASAXS_InterceptError
		Duplicate/O DiameterDistribution1, ASAXS_Diameters
	else
		if (UseSet2)
			Duplicate/O VolumeDistribution2, ASAXS_Slope, ASAXS_SlopeError, ASAXS_Intercept, ASAXS_InterceptError
			Duplicate/O DiameterDistribution2, ASAXS_Diameters
		else
			if (UseSet3)
				Duplicate/O VolumeDistribution3, ASAXS_Slope, ASAXS_SlopeError, ASAXS_Intercept, ASAXS_InterceptError
				Duplicate/O DiameterDistribution3, ASAXS_Diameters
			else
				if (UseSet4)
					Duplicate/O VolumeDistribution4, ASAXS_Slope, ASAXS_SlopeError, ASAXS_Intercept, ASAXS_InterceptError
					Duplicate/O DiameterDistribution4, ASAXS_Diameters
				else
					if (UseSet5)
						Duplicate/O VolumeDistribution5, ASAXS_Slope, ASAXS_SlopeError, ASAXS_Intercept, ASAXS_InterceptError
						Duplicate/O DiameterDistribution5, ASAXS_Diameters
					else
						if (UseSet6)
							Duplicate/O VolumeDistribution6, ASAXS_Slope, ASAXS_SlopeError, ASAXS_Intercept, ASAXS_InterceptError
							Duplicate/O DiameterDistribution6, ASAXS_Diameters
						else
							if (UseSet7)
								Duplicate/O VolumeDistribution7, ASAXS_Slope, ASAXS_SlopeError, ASAXS_Intercept, ASAXS_InterceptError
								Duplicate/O DiameterDistribution7, ASAXS_Diameters
							else
								if (UseSet8)
									Duplicate/O VolumeDistribution8, ASAXS_Slope, ASAXS_SlopeError, ASAXS_Intercept, ASAXS_InterceptError
									Duplicate/O DiameterDistribution8, ASAXS_Diameters
								else
									Abort "cannot create ASXS data waves"
								endif
							endif
						endif
					endif
				endif
			endif
		endif
	endif		
	
	ASAXS_Slope=0
	ASAXS_SlopeError=0
	ASAXS_Intercept=0
	ASAXS_InterceptError=0
	
	IN2G_AppendorReplaceWaveNote("ASAXS_Slope","Wname","ASAXS_Slope")
	IN2G_AppendorReplaceWaveNote("ASAXS_SlopeError","Wname","ASAXS_SlopeError")
	IN2G_AppendorReplaceWaveNote("ASAXS_Intercept","Wname","ASAXS_Intercept")
	IN2G_AppendorReplaceWaveNote("ASAXS_InterceptError","Wname","ASAXS_InterceptError")
	
	variable temp=UseSet1+UseSet2+UseSet3+UseSet4+UseSet5+UseSet6+UseSet7+UseSet8
	Make/O/N=(temp) PointVolumeContent, PointContrasts, PointColors
	
	
end

//****************************************************************************************************************************
//****************************************************************************************************************************
//****************************************************************************************************************************

Function IN2L_CopyWavesLocally()

	SVAR EnergyFolder1
	SVAR SampleName1
	NVAR UseSet1
	SVAR EnergyFolder2
	SVAR SampleName2
	NVAR UseSet2
	SVAR EnergyFolder3
	SVAR SampleName3
	NVAR UseSet3
	SVAR EnergyFolder4
	SVAR SampleName4
	NVAR UseSet4
	SVAR EnergyFolder5
	SVAR SampleName5
	NVAR UseSet5
	SVAR EnergyFolder6
	SVAR SampleName6
	NVAR UseSet6
	SVAR EnergyFolder7
	SVAR SampleName7
	NVAR UseSet7
	SVAR EnergyFolder8
	SVAR SampleName8
	NVAR UseSet8
	NVAR Contrast1
	NVAR Contrast2
	NVAR Contrast3
	NVAR Contrast4
	NVAR Contrast5
	NVAR Contrast6
	NVAR Contrast7
	NVAR Contrast8
	NVAR ContrastVoids
	SVAR ASAXSListOfOptions
	NVAR SolutionOrder=root:Packages:ASAXS:SolutionOrder
	NVAR UseM_DSM=root:Packages:ASAXS:UseM_DSM

	//assume we need the waves named: SizesVolumeDistribution and SizeDistDiameter
	
	if (UseSet1)
		WAVE/Z DataY1=$(SampleName1+":SizesVolumeDistribution_"+num2str(SolutionOrder))
		WAVE/Z DataX1=$(SampleName1+":SizesDistDiameter_"+num2str(SolutionOrder))
		if(UseM_DSM)
			WAVE/Z I1=$(SampleName1+":M_DSM_Int")
			WAVE/Z Q1=$(SampleName1+":M_DSM_Qvec")
			WAVE/Z E1=$(SampleName1+":M_DSM_Error")
		else
			WAVE/Z I1=$(SampleName1+":DSM_Int")
			WAVE/Z Q1=$(SampleName1+":DSM_Qvec")
			WAVE/Z E1=$(SampleName1+":DSM_Error")
		endif
		if(!WaveExists(DataY1) || !WaveExists(DataX1) || !WaveExists(I1) || !WaveExists(Q1) || !WaveExists(E1))
			abort "Error in loading set1 data, either order of solution does not exist or wave type selected (DSM/M_DSM) does not exist"
		endif    
		Duplicate /O I1, DSM_Int1
		Duplicate /O Q1, DSM_Qvec1
		Duplicate /O E1, DSM_Error1
		Duplicate /O DataY1, VolumeDistribution1
		Duplicate /O DataX1, DiameterDistribution1	
	endif
	if (UseSet2)
		WAVE/Z DataY2=$(SampleName2+":SizesVolumeDistribution_"+num2str(SolutionOrder))
		WAVE/Z DataX2=$(SampleName2+":SizesDistDiameter_"+num2str(SolutionOrder))
		if(UseM_DSM)
			WAVE/Z I2=$(SampleName2+":M_DSM_Int")
			WAVE/Z Q2=$(SampleName2+":M_DSM_Qvec")
			WAVE/Z E2=$(SampleName2+":M_DSM_Error")
		else
			WAVE/Z I2=$(SampleName2+":DSM_Int")
			WAVE/Z Q2=$(SampleName2+":DSM_Qvec")
			WAVE/Z E2=$(SampleName2+":DSM_Error")
		endif
		if(!WaveExists(DataY2) || !WaveExists(DataX2) || !WaveExists(I2) || !WaveExists(Q2) || !WaveExists(E2))
			abort "Error in loading set2 data, either order of solution does not exist or wave type selected (DSM/M_DSM) does not exist"
		endif    
		Duplicate /O DataY2, VolumeDistribution2
		Duplicate /O DataX2, DiameterDistribution2	
		Duplicate /O I2, DSM_Int2
		Duplicate /O Q2, DSM_Qvec2
		Duplicate /O E2, DSM_Error2
	endif
	if (UseSet3)
		WAVE/Z DataY3=$(SampleName3+":SizesVolumeDistribution_"+num2str(SolutionOrder))
		WAVE/Z DataX3=$(SampleName3+":SizesDistDiameter_"+num2str(SolutionOrder))
		if(UseM_DSM)
			WAVE/Z I3=$(SampleName3+":M_DSM_Int")
			WAVE/Z Q3=$(SampleName3+":M_DSM_Qvec")
			WAVE/Z E3=$(SampleName3+":M_DSM_Error")
		else
			WAVE/Z I3=$(SampleName3+":DSM_Int")
			WAVE/Z Q3=$(SampleName3+":DSM_Qvec")
			WAVE/Z E3=$(SampleName3+":DSM_Error")
		endif
		if(!WaveExists(DataY3) || !WaveExists(DataX3) || !WaveExists(I3) || !WaveExists(Q3) || !WaveExists(E3))
			abort "Error in loading set3 data, either order of solution does not exist or wave type selected (DSM/M_DSM) does not exist"
		endif    
		Duplicate /O DataY3, VolumeDistribution3
		Duplicate /O DataX3, DiameterDistribution3	
		Duplicate /O I3, DSM_Int3
		Duplicate /O Q3,DSM_Qvec3
		Duplicate /O E3, DSM_Error3
	endif
	if (UseSet4)
		WAVE/Z DataY4=$(SampleName4+":SizesVolumeDistribution_"+num2str(SolutionOrder))
		WAVE/Z DataX4=$(SampleName4+":SizesDistDiameter_"+num2str(SolutionOrder))
		if(UseM_DSM)
			WAVE/Z I4=$(SampleName4+":M_DSM_Int")
			WAVE/Z Q4=$(SampleName4+":M_DSM_Qvec")
			WAVE/Z E4=$(SampleName4+":M_DSM_Error")
		else
			WAVE/Z I4=$(SampleName4+":DSM_Int")
			WAVE/Z Q4=$(SampleName4+":DSM_Qvec")
			WAVE/Z E4=$(SampleName4+":DSM_Error")
		endif
		if(!WaveExists(DataY4) || !WaveExists(DataX4) || !WaveExists(I4) || !WaveExists(Q4) || !WaveExists(E4))
			abort "Error in loading set4 data, either order of solution does not exist or wave type selected (DSM/M_DSM) does not exist"
		endif    
		Duplicate /O DataY4, VolumeDistribution4
		Duplicate /O DataX4, DiameterDistribution4	
		Duplicate /O I4, DSM_Int4
		Duplicate /O Q4, DSM_Qvec4
		Duplicate /O E4, DSM_Error4
	endif
	if (UseSet5)
		WAVE/Z DataY5=$(SampleName5+":SizesVolumeDistribution_"+num2str(SolutionOrder))
		WAVE/Z DataX5=$(SampleName5+":SizesDistDiameter_"+num2str(SolutionOrder))
		if(UseM_DSM)
			WAVE/Z I5=$(SampleName5+":M_DSM_Int")
			WAVE/Z Q5=$(SampleName5+":M_DSM_Qvec")
			WAVE/Z E5=$(SampleName5+":M_DSM_Error")
		else
			WAVE/Z I5=$(SampleName5+":DSM_Int")
			WAVE/Z Q5=$(SampleName5+":DSM_Qvec")
			WAVE/Z E5=$(SampleName5+":DSM_Error")
		endif
		if(!WaveExists(DataY5) || !WaveExists(DataX5) || !WaveExists(I5) || !WaveExists(Q5) || !WaveExists(E5))
			abort "Error in loading set5 data, either order of solution does not exist or wave type selected (DSM/M_DSM) does not exist"
		endif    
		Duplicate /O DataY5, VolumeDistribution5
		Duplicate /O DataX5, DiameterDistribution5	
		Duplicate /O I5, DSM_Int5
		Duplicate /O Q5, DSM_Qvec5
		Duplicate /O E5, DSM_Error5
	endif
	if (UseSet6)
		WAVE/Z DataY6=$(SampleName6+":SizesVolumeDistribution_"+num2str(SolutionOrder))
		WAVE/Z DataX6=$(SampleName6+":SizesDistDiameter_"+num2str(SolutionOrder))
		if(UseM_DSM)
			WAVE/Z I6=$(SampleName6+":M_DSM_Int")
			WAVE/Z Q6=$(SampleName6+":M_DSM_Qvec")
			WAVE/Z E6=$(SampleName6+":M_DSM_Error")
		else
			WAVE/Z I6=$(SampleName6+":DSM_Int")
			WAVE/Z Q6=$(SampleName6+":DSM_Qvec")
			WAVE/Z E6=$(SampleName6+":DSM_Error")
		endif
		if(!WaveExists(DataY6) || !WaveExists(DataX6) || !WaveExists(I6) || !WaveExists(Q6) || !WaveExists(E6))
			abort "Error in loading set6 data, either order of solution does not exist or wave type selected (DSM/M_DSM) does not exist"
		endif    
		Duplicate /O DataY6, VolumeDistribution6
		Duplicate /O DataX6, DiameterDistribution6	
		Duplicate /O I6, DSM_Int6
		Duplicate /O Q6, DSM_Qvec6
		Duplicate /O E6, DSM_Error6
	endif
	if (UseSet7)
		WAVE/Z DataY7=$(SampleName7+":SizesVolumeDistribution_"+num2str(SolutionOrder))
		WAVE/Z DataX7=$(SampleName7+":SizesDistDiameter_"+num2str(SolutionOrder))
		if(UseM_DSM)
			WAVE/Z I7=$(SampleName7+":M_DSM_Int")
			WAVE/Z Q7=$(SampleName7+":M_DSM_Qvec")
			WAVE/Z E7=$(SampleName7+":M_DSM_Error")
		else
			WAVE/Z I7=$(SampleName7+":DSM_Int")
			WAVE/Z Q7=$(SampleName7+":DSM_Qvec")
			WAVE/Z E7=$(SampleName7+":DSM_Error")
		endif
		if(!WaveExists(DataY7) || !WaveExists(DataX7) || !WaveExists(I7) || !WaveExists(Q7) || !WaveExists(E7))
			abort "Error in loading set7 data, either order of solution does not exist or wave type selected (DSM/M_DSM) does not exist"
		endif    
		Duplicate /O DataY7, VolumeDistribution7
		Duplicate /O DataX7, DiameterDistribution7	
		Duplicate /O I7, DSM_Int7
		Duplicate /O Q7, DSM_Qvec7
		Duplicate /O E7, DSM_Error7
	endif
	if (UseSet8)
		WAVE/Z DataY8=$(SampleName8+":SizesVolumeDistribution_"+num2str(SolutionOrder))
		WAVE/Z DataX8=$(SampleName8+":SizesDistDiameter_"+num2str(SolutionOrder))
		if(UseM_DSM)
			WAVE/Z I8=$(SampleName8+":M_DSM_Int")
			WAVE/Z Q8=$(SampleName8+":M_DSM_Qvec")
			WAVE/Z E8=$(SampleName8+":M_DSM_Error")
		else
			WAVE/Z I8=$(SampleName8+":DSM_Int")
			WAVE/Z Q8=$(SampleName8+":DSM_Qvec")
			WAVE/Z E8=$(SampleName8+":DSM_Error")
		endif
		if(!WaveExists(DataY8) || !WaveExists(DataX8) || !WaveExists(I8) || !WaveExists(Q8) || !WaveExists(E8))
			abort "Error in loading set8 data, either order of solution does not exist or wave type selected (DSM/M_DSM) does not exist"
		endif    
		Duplicate /O DataY8, VolumeDistribution8
		Duplicate /O DataX8, DiameterDistribution8	
		Duplicate /O I8, DSM_Int8
		Duplicate /O Q8, DSM_Qvec8
		Duplicate /O E8, DSM_Error8
	endif


end

//****************************************************************************************************************************
//****************************************************************************************************************************
//****************************************************************************************************************************

Function IN2L_RecordParameters()

	setDataFolder root:Packages:ASAXS:
	
	SVAR EnergyFolder1
	SVAR SampleName1
	NVAR UseSet1
	SVAR EnergyFolder2
	SVAR SampleName2
	NVAR UseSet2
	SVAR EnergyFolder3
	SVAR SampleName3
	NVAR UseSet3
	SVAR EnergyFolder4
	SVAR SampleName4
	NVAR UseSet4
	SVAR EnergyFolder5
	SVAR SampleName5
	NVAR UseSet5
	SVAR EnergyFolder6
	SVAR SampleName6
	NVAR UseSet6
	SVAR EnergyFolder7
	SVAR SampleName7
	NVAR UseSet7
	SVAR EnergyFolder8
	SVAR SampleName8
	NVAR UseSet8
	NVAR Contrast1
	NVAR Contrast2
	NVAR Contrast3
	NVAR Contrast4
	NVAR Contrast5
	NVAR Contrast6
	NVAR Contrast7
	NVAR Contrast8
	NVAR ContrastVoids
	SVAR ASAXSListOfOptions
	
	ASAXSListOfOptions=ReplaceStringByKey("SampleName1", ASAXSListOfOptions, SampleName1, "=")
	ASAXSListOfOptions=ReplaceStringByKey("SampleName2", ASAXSListOfOptions, SampleName2, "=")
	ASAXSListOfOptions=ReplaceStringByKey("SampleName3", ASAXSListOfOptions, SampleName3, "=")
	ASAXSListOfOptions=ReplaceStringByKey("SampleName4", ASAXSListOfOptions, SampleName4, "=")
	ASAXSListOfOptions=ReplaceStringByKey("SampleName5", ASAXSListOfOptions, SampleName5, "=")
	ASAXSListOfOptions=ReplaceStringByKey("SampleName6", ASAXSListOfOptions, SampleName6, "=")
	ASAXSListOfOptions=ReplaceStringByKey("SampleName7", ASAXSListOfOptions, SampleName7, "=")
	ASAXSListOfOptions=ReplaceStringByKey("SampleName8", ASAXSListOfOptions, SampleName8, "=")
	ASAXSListOfOptions=ReplaceStringByKey("UseSet1", ASAXSListOfOptions, num2str(UseSet1), "=")
	ASAXSListOfOptions=ReplaceStringByKey("UseSet2", ASAXSListOfOptions, num2str(UseSet2), "=")
	ASAXSListOfOptions=ReplaceStringByKey("UseSet3", ASAXSListOfOptions, num2str(UseSet3), "=")
	ASAXSListOfOptions=ReplaceStringByKey("UseSet4", ASAXSListOfOptions, num2str(UseSet4), "=")
	ASAXSListOfOptions=ReplaceStringByKey("UseSet5", ASAXSListOfOptions, num2str(UseSet5), "=")
	ASAXSListOfOptions=ReplaceStringByKey("UseSet6", ASAXSListOfOptions, num2str(UseSet6), "=")
	ASAXSListOfOptions=ReplaceStringByKey("UseSet7", ASAXSListOfOptions, num2str(UseSet7), "=")
	ASAXSListOfOptions=ReplaceStringByKey("UseSet8", ASAXSListOfOptions, num2str(UseSet8), "=")
	ASAXSListOfOptions=ReplaceStringByKey("Contrast1", ASAXSListOfOptions, num2str(Contrast1), "=")
	ASAXSListOfOptions=ReplaceStringByKey("Contrast2", ASAXSListOfOptions, num2str(Contrast2), "=")
	ASAXSListOfOptions=ReplaceStringByKey("Contrast3", ASAXSListOfOptions, num2str(Contrast3), "=")
	ASAXSListOfOptions=ReplaceStringByKey("Contrast4", ASAXSListOfOptions, num2str(Contrast4), "=")
	ASAXSListOfOptions=ReplaceStringByKey("Contrast5", ASAXSListOfOptions, num2str(Contrast5), "=")
	ASAXSListOfOptions=ReplaceStringByKey("Contrast6", ASAXSListOfOptions, num2str(Contrast6), "=")
	ASAXSListOfOptions=ReplaceStringByKey("Contrast7", ASAXSListOfOptions, num2str(Contrast7), "=")
	ASAXSListOfOptions=ReplaceStringByKey("Contrast8", ASAXSListOfOptions, num2str(Contrast8), "=")

	ASAXSListOfOptions=ReplaceStringByKey("ContrastVoids", ASAXSListOfOptions, num2str(ContrastVoids), "=")


end

//****************************************************************************************************************************
//****************************************************************************************************************************
//****************************************************************************************************************************

Function IN2L_ASAXSPanelPopup(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	setDataFolder root:Packages:ASAXS:
	
	SVAR EnergyFolder1
	SVAR SampleName1
	NVAR UseSet1
	SVAR EnergyFolder2
	SVAR SampleName2
	NVAR UseSet2
	SVAR EnergyFolder3
	SVAR SampleName3
	NVAR UseSet3
	SVAR EnergyFolder4
	SVAR SampleName4
	NVAR UseSet4
	SVAR EnergyFolder5
	SVAR SampleName5
	NVAR UseSet5
	SVAR EnergyFolder6
	SVAR SampleName6
	NVAR UseSet6
	SVAR EnergyFolder7
	SVAR SampleName7
	NVAR UseSet7
	SVAR EnergyFolder8
	SVAR SampleName8
	NVAR UseSet8
	NVAR Contrast1
	NVAR Contrast2
	NVAR Contrast3
	NVAR Contrast4
	NVAR Contrast5
	NVAR Contrast6
	NVAR Contrast7
	NVAR Contrast8
	NVAR ContrastVoids
	SVAR ASAXSListOfOptions
	
	
	//do what happens when I work on energy folder1
	if (cmpstr("USAXSSubfolder1",ctrlname)==0)	
		if (cmpstr(popStr,"---")==0)
			EnergyFolder1=popStr
		else		
			EnergyFolder1="root:USAXS:"+PossiblyQuoteName(popStr)+":"	
		endif
			UseSet1=0
			SampleName1="---"
			Contrast1=1
			PopupMenu SampleName1,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder1, 2, \"SizesVolume\", 0)"
			CheckBox UseSample1,value= 0
	endif

	if (cmpstr("SampleName1",ctrlname)==0)
		if (cmpstr("---",popStr)==0)
			UseSet1=0
			CheckBox UseSample1, win=IN2L_ASXASControlPanel, value= UseSet1
			SampleName1=popStr
			Contrast1=1
		else
			SampleName1=EnergyFolder1+popStr
			UseSet1=1
			CheckBox UseSample1, win=IN2L_ASXASControlPanel, value= UseSet1
		endif
	endif

	//do what happens when I work on energy folder2
	if (cmpstr("USAXSSubfolder2",ctrlname)==0)			
		if (cmpstr(popStr,"---")==0)
			EnergyFolder2=popStr
		else		
			EnergyFolder2="root:USAXS:"+PossiblyQuoteName(popStr)+":"	
		endif
			UseSet2=0
			SampleName2="---"
			Contrast2=1
			PopupMenu SampleName2,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder2, 2, \"SizesVolume\", 0)"
			CheckBox UseSample2,value= 0
	endif

	if (cmpstr("SampleName2",ctrlname)==0)
		if (cmpstr("---",popStr)==0)
			UseSet2=0
			CheckBox UseSample2, win=IN2L_ASXASControlPanel, value= UseSet2
			SampleName2=popStr
			Contrast2=1			
		else
			SampleName2=EnergyFolder2+popStr
			UseSet2=1
			CheckBox UseSample2, win=IN2L_ASXASControlPanel, value= UseSet2
		endif
	endif

	//do what happens when I work on energy folder3
	if (cmpstr("USAXSSubfolder3",ctrlname)==0)			
		if (cmpstr(popStr,"---")==0)
			EnergyFolder3=popStr
		else		
			EnergyFolder3="root:USAXS:"+PossiblyQuoteName(popStr)+":"	
		endif
			UseSet3=0
			SampleName3="---"
			Contrast3=1
			PopupMenu SampleName3,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder3, 2, \"SizesVolume\", 0)"
			CheckBox UseSample3,value= 0

	endif

	if (cmpstr("SampleName3",ctrlname)==0)
		if (cmpstr("---",popStr)==0)
			UseSet3=0
			CheckBox UseSample3, win=IN2L_ASXASControlPanel, value= UseSet3
			SampleName3=popStr
			Contrast3=1
		else
			SampleName3=EnergyFolder3+popStr
			UseSet3=1
			CheckBox UseSample3, win=IN2L_ASXASControlPanel, value= UseSet3
		endif
	endif

	//do what happens when I work on energy folder4
	if (cmpstr("USAXSSubfolder4",ctrlname)==0)			
		if (cmpstr(popStr,"---")==0)
			EnergyFolder4=popStr
		else		
			EnergyFolder4="root:USAXS:"+PossiblyQuoteName(popStr)+":"	
		endif
			UseSet4=0
			SampleName4="---"
			Contrast4=1
			PopupMenu SampleName4,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder4, 2, \"SizesVolume\", 0)"
			CheckBox UseSample4,value= 0

	endif

	if (cmpstr("SampleName4",ctrlname)==0)
		if (cmpstr("---",popStr)==0)
			UseSet4=0
			CheckBox UseSample4, win=IN2L_ASXASControlPanel, value= UseSet4
			SampleName4=popStr
			Contrast4=1
		else
			SampleName4=EnergyFolder4+popStr
			UseSet4=1
			CheckBox UseSample4, win=IN2L_ASXASControlPanel, value= UseSet4
		endif
	endif

	//do what happens when I work on energy folder5
	if (cmpstr("USAXSSubfolder5",ctrlname)==0)			
		if (cmpstr(popStr,"---")==0)
			EnergyFolder5=popStr
		else		
			EnergyFolder5="root:USAXS:"+PossiblyQuoteName(popStr)+":"	
		endif
			UseSet5=0
			SampleName5="---"
			Contrast5=1
			PopupMenu SampleName5,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder5, 2, \"SizesVolume\", 0)"
			CheckBox UseSample5,value= 0

	endif

	if (cmpstr("SampleName5",ctrlname)==0)
		if (cmpstr("---",popStr)==0)
			UseSet5=0
			CheckBox UseSample5, win=IN2L_ASXASControlPanel, value= UseSet5
			SampleName5=popStr
			Contrast5=1
		else
			SampleName5=EnergyFolder5+popStr
			UseSet5=1
			CheckBox UseSample5, win=IN2L_ASXASControlPanel, value= UseSet5
		endif
	endif

	//do what happens when I work on energy folder6
	if (cmpstr("USAXSSubfolder6",ctrlname)==0)			
		if (cmpstr(popStr,"---")==0)
			EnergyFolder6=popStr
		else		
			EnergyFolder6="root:USAXS:"+PossiblyQuoteName(popStr)+":"	
		endif
			UseSet6=0
			SampleName6="---"
			Contrast6=1
			PopupMenu SampleName6,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder6, 2, \"SizesVolume\", 0)"
			CheckBox UseSample6,value= 0

	endif

	if (cmpstr("SampleName6",ctrlname)==0)
		if (cmpstr("---",popStr)==0)
			UseSet6=0
			CheckBox UseSample6, win=IN2L_ASXASControlPanel, value= UseSet6
			SampleName6=popStr
			Contrast6=1
		else
			SampleName6=EnergyFolder6+popStr
			UseSet6=1
			CheckBox UseSample6, win=IN2L_ASXASControlPanel, value= UseSet6
		endif
	endif

	//do what happens when I work on energy folder7
	if (cmpstr("USAXSSubfolder7",ctrlname)==0)			
		if (cmpstr(popStr,"---")==0)
			EnergyFolder7=popStr
		else		
			EnergyFolder7="root:USAXS:"+PossiblyQuoteName(popStr)+":"	
		endif
			UseSet7=0
			SampleName7="---"
			Contrast7=1
			PopupMenu SampleName7,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder7, 2, \"SizesVolume\", 0)"
			CheckBox UseSample7,value= 0

	endif

	if (cmpstr("SampleName7",ctrlname)==0)
		if (cmpstr("---",popStr)==0)
			UseSet7=0
			CheckBox UseSample7, win=IN2L_ASXASControlPanel, value= UseSet7
			SampleName7=popStr
			Contrast7=1
		else
			SampleName7=EnergyFolder7+popStr
			UseSet7=1
			CheckBox UseSample7, win=IN2L_ASXASControlPanel, value= UseSet7
		endif
	endif

	//do what happens when I work on energy folder8
	if (cmpstr("USAXSSubfolder8",ctrlname)==0)			
		if (cmpstr(popStr,"---")==0)
			EnergyFolder8=popStr
		else		
			EnergyFolder8="root:USAXS:"+PossiblyQuoteName(popStr)+":"	
		endif
			UseSet8=0
			SampleName8="---"
			Contrast8=1
			PopupMenu SampleName8,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder8, 2, \"SizesVolume\", 0)"
			CheckBox UseSample8,value= 0

	endif

	if (cmpstr("SampleName8",ctrlname)==0)
		if (cmpstr("---",popStr)==0)
			UseSet8=0
			CheckBox UseSample8, win=IN2L_ASXASControlPanel, value= UseSet8
			SampleName8=popStr
			Contrast8=1
		else
			SampleName8=EnergyFolder8+popStr
			UseSet8=1
			CheckBox UseSample8, win=IN2L_ASXASControlPanel, value= UseSet8
		endif
	endif

	//this is done always

	ControlUpdate /A /W=IN2L_ASXASControlPanel 
	
	IN2L_RecordParameters()		//records the string for future use
	IN2L_CopyWavesLocally()		//copy the waves locally 
	IN2L_AppendToGraph1()		//append them as needed
	IN2L_AppendToGraph2()		//append them as needed
End

//****************************************************************************************************************************
//****************************************************************************************************************************
//****************************************************************************************************************************

Window IN2L_ASXASControlPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(6,49.25,546.75,685.25) as "IN2L_ASAXSEvaluationGraph"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (65280,0,0)
	DrawText 144,29,"ASAXS control panel "
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,15872,65280)
	DrawText 24,56,"Select data:"
	SetDrawEnv fsize= 16
	DrawText 25,90,"E-folder"
	SetDrawEnv fsize= 16
	DrawText 173,90,"Dataset"
	SetDrawEnv fsize= 16
	DrawText 351,90,"Use set?"
	SetDrawEnv fsize= 16
	DrawText 464,90,"Contrast"
	SetDrawEnv linebgc= (0,0,0),fillfgc= (0,0,0)
	DrawRect 333,102,534,125
	SetDrawEnv linebgc= (0,0,0),fillfgc= (65280,0,0)
	DrawRect 333,131,534,154
	SetDrawEnv linebgc= (0,0,0),fillfgc= (0,65280,0)
	DrawRect 333,159,534,182
	SetDrawEnv linebgc= (0,0,0),fillfgc= (0,15872,65280)
	DrawRect 333,187,534,210
	SetDrawEnv linebgc= (0,0,0),fillfgc= (36864,14592,58880)
	DrawRect 333,215,534,238
	SetDrawEnv linebgc= (0,0,0),fillfgc= (65280,65280,16384)
	DrawRect 333,243,534,266
	SetDrawEnv linebgc= (0,0,0),fillfgc= (16384,65280,16384)
	DrawRect 333,271,534,294
	SetDrawEnv linebgc= (0,0,0),fillfgc= (16384,16384,65280)
	DrawRect 333,299,534,322
	DrawRect 360,101,394,321
	SetDrawEnv linethick= 3,linefgc= (0,15872,65280)
	DrawLine 12,376,516,376
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,15872,65280)
	DrawText 19,429,"Evaluate data:"
	DrawLine 85,437,401,437
	DrawLine 85,530,401,530
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,15872,65280)
	DrawText 23,628,"Record data:"
	PopupMenu USAXSSubfolder1,pos={5,103},size={46,21},proc=IN2L_ASAXSPanelPopup
	PopupMenu USAXSSubfolder1,mode=1,popvalue="---",value= #"\"---;\"+IN2G_CreateListOfItemsInFolder(\"root:USAXS:\",1)"
	PopupMenu USAXSSubfolder2,pos={5,131},size={46,21},proc=IN2L_ASAXSPanelPopup
	PopupMenu USAXSSubfolder2,mode=1,popvalue="---",value= #"\"---;\"+IN2G_CreateListOfItemsInFolder(\"root:USAXS:\",1)"
	PopupMenu USAXSSubfolder3,pos={5,160},size={46,21},proc=IN2L_ASAXSPanelPopup
	PopupMenu USAXSSubfolder3,mode=1,popvalue="---",value= #"\"---;\"+IN2G_CreateListOfItemsInFolder(\"root:USAXS:\",1)"
	PopupMenu USAXSSubfolder4,pos={5,189},size={46,21},proc=IN2L_ASAXSPanelPopup
	PopupMenu USAXSSubfolder4,mode=1,popvalue="---",value= #"\"---;\"+IN2G_CreateListOfItemsInFolder(\"root:USAXS:\",1)"
	PopupMenu USAXSSubfolder5,pos={5,217},size={46,21},proc=IN2L_ASAXSPanelPopup
	PopupMenu USAXSSubfolder5,mode=1,popvalue="---",value= #"\"---;\"+IN2G_CreateListOfItemsInFolder(\"root:USAXS:\",1)"
	PopupMenu USAXSSubfolder6,pos={5,246},size={46,21},proc=IN2L_ASAXSPanelPopup
	PopupMenu USAXSSubfolder6,mode=1,popvalue="---",value= #"\"---;\"+IN2G_CreateListOfItemsInFolder(\"root:USAXS:\",1)"
	PopupMenu USAXSSubfolder7,pos={5,275},size={46,21},proc=IN2L_ASAXSPanelPopup
	PopupMenu USAXSSubfolder7,mode=1,popvalue="---",value= #"\"---;\"+IN2G_CreateListOfItemsInFolder(\"root:USAXS:\",1)"
	PopupMenu USAXSSubfolder8,pos={5,304},size={46,21},proc=IN2L_ASAXSPanelPopup
	PopupMenu USAXSSubfolder8,mode=1,popvalue="---",value= #"\"---;\"+IN2G_CreateListOfItemsInFolder(\"root:USAXS:\",1)"
	PopupMenu SampleName1,pos={109,103},size={63,21},proc=IN2L_ASAXSPanelPopup,title=" "
	PopupMenu SampleName1,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder1, 2, \"SizesVolume\", 0)"
	PopupMenu SampleName2,pos={109,131},size={63,21},proc=IN2L_ASAXSPanelPopup,title=" "
	PopupMenu SampleName2,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder2, 2, \"SizesVolume\", 0)"
	PopupMenu SampleName3,pos={109,159},size={63,21},proc=IN2L_ASAXSPanelPopup,title=" "
	PopupMenu SampleName3,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder3, 2, \"SizesVolume\", 0)"
	PopupMenu SampleName4,pos={109,188},size={63,21},proc=IN2L_ASAXSPanelPopup,title=" "
	PopupMenu SampleName4,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder4, 2, \"SizesVolume\", 0)"
	PopupMenu SampleName5,pos={109,216},size={63,21},proc=IN2L_ASAXSPanelPopup,title=" "
	PopupMenu SampleName5,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder5, 2, \"SizesVolume\", 0)"
	PopupMenu SampleName6,pos={109,245},size={63,21},proc=IN2L_ASAXSPanelPopup,title=" "
	PopupMenu SampleName6,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder6, 2, \"SizesVolume\", 0)"
	PopupMenu SampleName7,pos={109,273},size={63,21},proc=IN2L_ASAXSPanelPopup,title=" "
	PopupMenu SampleName7,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder7, 2, \"SizesVolume\", 0)"
	PopupMenu SampleName8,pos={109,302},size={63,21},proc=IN2L_ASAXSPanelPopup,title=" "
	PopupMenu SampleName8,mode=1,popvalue="---",value= #"\"---;\"+IN2G_FindFolderWithWaveTypes(root:Packages:ASAXS:EnergyFolder8, 2, \"SizesVolume\", 0)"
	CheckBox UseSample1,pos={369,108},size={21,14},proc=IN2L_ASAXSInputCheckbox,title=" "
	CheckBox UseSample1,value= 0
	CheckBox UseSample2,pos={369,137},size={21,14},proc=IN2L_ASAXSInputCheckbox,title=" "
	CheckBox UseSample2,value= 0
	CheckBox UseSample3,pos={369,165},size={21,14},proc=IN2L_ASAXSInputCheckbox,title=" "
	CheckBox UseSample3,value= 0
	CheckBox UseSample4,pos={369,192},size={21,14},proc=IN2L_ASAXSInputCheckbox,title=" "
	CheckBox UseSample4,value= 0
	CheckBox UseSample5,pos={369,220},size={21,14},proc=IN2L_ASAXSInputCheckbox,title=" "
	CheckBox UseSample5,value= 0
	CheckBox UseSample6,pos={369,247},size={21,14},proc=IN2L_ASAXSInputCheckbox,title=" "
	CheckBox UseSample6,value= 0
	CheckBox UseSample7,pos={369,275},size={21,14},proc=IN2L_ASAXSInputCheckbox,title=" "
	CheckBox UseSample7,value= 0
	CheckBox UseSample8,pos={369,303},size={21,14},proc=IN2L_ASAXSInputCheckbox,title=" "
	CheckBox UseSample8,value= 0
	SetVariable Contrast1,pos={464,107},size={60,16},title=" "
	SetVariable Contrast1,limits={-Inf,Inf,0},value= root:Packages:ASAXS:Contrast1
	SetVariable Contrast2,pos={464,134},size={60,16},title=" "
	SetVariable Contrast2,limits={-Inf,Inf,0},value= root:Packages:ASAXS:Contrast2
	SetVariable Contrast3,pos={464,162},size={60,16},title=" "
	SetVariable Contrast3,limits={-Inf,Inf,0},value= root:Packages:ASAXS:Contrast3
	SetVariable Contrast4,pos={464,190},size={60,16},title=" "
	SetVariable Contrast4,limits={-Inf,Inf,0},value= root:Packages:ASAXS:Contrast4
	SetVariable Contrast5,pos={464,218},size={60,16},title=" "
	SetVariable Contrast5,limits={-Inf,Inf,0},value= root:Packages:ASAXS:Contrast5
	SetVariable Contrast6,pos={464,246},size={60,16},title=" "
	SetVariable Contrast6,limits={-Inf,Inf,0},value= root:Packages:ASAXS:Contrast6
	SetVariable Contrast7,pos={464,274},size={60,16},title=" "
	SetVariable Contrast7,limits={-Inf,Inf,0},value= root:Packages:ASAXS:Contrast7
	SetVariable Contrast8,pos={464,302},size={60,16},title=" "
	SetVariable Contrast8,limits={-Inf,Inf,0},value= root:Packages:ASAXS:Contrast8
	SetVariable ContrastVoids,pos={4,348},size={200,19},title="Voids contrast: "
	SetVariable ContrastVoids,fSize=12
	SetVariable ContrastVoids,limits={-Inf,Inf,0},value= root:Packages:ASAXS:ContrastVoids



	Checkbox UseM_DSM,pos={300,330},size={150,20},variable=root:Packages:ASAXS:UseM_DSM,title="Use M_DSM waves?"
	SetVariable SolutionOrder,pos={300,355},size={160,16},title="Solution Order: "
	SetVariable SolutionOrder,limits={-Inf,Inf,0},value= root:Packages:ASAXS:SolutionOrder

	Button AnalyzeData,pos={138,466},size={150,20},proc=IN2L_AnalyzeASAXS,title="Analyze ASAXS all"
	Button AnalyzeASAXSSetps,pos={138,554},size={150,20},proc=IN2L_AnalyzeASAXSInSteps,title="Analyze ASAXS in steps"
	SetVariable CurrentSet,pos={316,442},size={220,16},title="Currently evaluated data point"
	SetVariable CurrentSet,limits={0,0,0},value= root:Packages:ASAXS:CurrentEvaluationPoint
	SetVariable NextSetToEvaluate,pos={308,556},size={220,16},title="Next data point to evaluate:"
	SetVariable NextSetToEvaluate,limits={-1,Inf,1},value= root:Packages:ASAXS:NextEvaluationPoint
//	SetVariable StopDataEvaluation,pos={316,499},size={220,16},title="Set to 1 to pause data evaluation:"
//	SetVariable StopDataEvaluation,limits={0,1,1},value= root:Packages:ASAXS:PauseEvaluation
	SetVariable DElay,pos={316,470},size={220,16},title="Delay between steps [sec]: "
	SetVariable DElay,limits={0,Inf,1},value= root:Packages:ASAXS:DelayBetweenFrames	
//	SetVariable OutputFolder,pos={50,580},size={400,16},title="Output folder:    root:Contrast:"
//	SetVariable OutputFolder, help={"Out waves (contrast & Energy will be stored in this folder in root:Contrast:"}
//	SetVariable OutputFolder,limits={0,Inf,1},value= root:Packages:ASAXS:OutputFolder
	Button Record,pos={143,610},size={100,20},proc=IN2L_RecordResults,title="Record results"
EndMacro

//****************************************************************************************************************************
//****************************************************************************************************************************
//****************************************************************************************************************************

Function IN2L_ASAXSInputCheckbox(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	setDataFolder root:Packages:ASAXS:
	NVAR UseSet1
	NVAR UseSet2
	NVAR UseSet3
	NVAR UseSet4
	NVAR UseSet5
	NVAR UseSet6
	NVAR UseSet7
	NVAR UseSet8

	if(cmpstr("UseSample1",ctrlName)==0)
		UseSet1=checked		
	endif
	if(cmpstr("UseSample2",ctrlName)==0)
		UseSet2=checked		
	endif
	if(cmpstr("UseSample3",ctrlName)==0)
		UseSet3=checked		
	endif
	if(cmpstr("UseSample4",ctrlName)==0)
		UseSet4=checked		
	endif
	if(cmpstr("UseSample5",ctrlName)==0)
		UseSet5=checked		
	endif
	if(cmpstr("UseSample6",ctrlName)==0)
		UseSet6=checked		
	endif
	if(cmpstr("UseSample7",ctrlName)==0)
		UseSet7=checked		
	endif
	if(cmpstr("UseSample8",ctrlName)==0)
		UseSet8=checked		
	endif
	
	IN2L_AppendToGraph1()
	IN2L_AppendToGraph2()

End

//****************************************************************************************************************************
//****************************************************************************************************************************
//****************************************************************************************************************************

Window IN2L_ASAXSGraph1() : Graph
	PauseUpdate; Silent 1		// building window...
	Display /W=(415,40,870,300)/K=1  as "IN2L_ASAXSGraph1"
EndMacro


Window IN2L_ASAXSGraph2() : Graph
	PauseUpdate; Silent 1		// building window...
	Display /W=(414.75,322.25,870,581.75)/K=1  as "IN2L_ASAXSGraph2"
EndMacro

//****************************************************************************************************************************
//****************************************************************************************************************************
//****************************************************************************************************************************

Function IN2L_AppendToGraph1()

	SetDataFolder root:Packages:ASAXS:
	NVAR UseSet1
	NVAR UseSet2
	NVAR UseSet3
	NVAR UseSet4
	NVAR UseSet5
	NVAR UseSet6
	NVAR UseSet7
	NVAR UseSet8
	
	DoWindow IN2L_ASAXSGraph1
	if (!V_Flag)
		return 0
	endif
	RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 ASAXS_Intercept	

	
	if(UseSet1)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution1	
		AppendToGraph /W=IN2L_ASAXSGraph1 VolumeDistribution1 vs DiameterDistribution1	
		ModifyGraph /W=IN2L_ASAXSGraph1 marker(VolumeDistribution1)=1
		ModifyGraph /W=IN2L_ASAXSGraph1 rgb(VolumeDistribution1)=(0,0,0)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution1	
	endif
	if(UseSet2)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution2
		AppendToGraph /W=IN2L_ASAXSGraph1 VolumeDistribution2 vs DiameterDistribution2	
		ModifyGraph /W=IN2L_ASAXSGraph1 marker(VolumeDistribution2)=2
		ModifyGraph /W=IN2L_ASAXSGraph1 rgb(VolumeDistribution2)=(65280,0,0)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution2	
	endif
	if(UseSet3)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution3
		AppendToGraph /W=IN2L_ASAXSGraph1 VolumeDistribution3 vs DiameterDistribution3	
		ModifyGraph /W=IN2L_ASAXSGraph1 marker(VolumeDistribution3)=3
		ModifyGraph /W=IN2L_ASAXSGraph1 rgb(VolumeDistribution3)=(0,52224,0)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution3	
	endif
	if(UseSet4)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution4
		AppendToGraph /W=IN2L_ASAXSGraph1 VolumeDistribution4 vs DiameterDistribution4	
		ModifyGraph /W=IN2L_ASAXSGraph1 marker(VolumeDistribution4)=4
		ModifyGraph /W=IN2L_ASAXSGraph1 rgb(VolumeDistribution4)=(0,12800,52224)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution4	
	endif
	if(UseSet5)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution5
		AppendToGraph /W=IN2L_ASAXSGraph1 VolumeDistribution5 vs DiameterDistribution5	
		ModifyGraph /W=IN2L_ASAXSGraph1 marker(VolumeDistribution5)=5
		ModifyGraph /W=IN2L_ASAXSGraph1 rgb(VolumeDistribution5)=(52224,0,41728)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution5	
	endif
	if(UseSet6)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution6
		AppendToGraph /W=IN2L_ASAXSGraph1 VolumeDistribution6 vs DiameterDistribution6
		ModifyGraph /W=IN2L_ASAXSGraph1 marker(VolumeDistribution6)=6
		ModifyGraph /W=IN2L_ASAXSGraph1 rgb(VolumeDistribution6)=(65280,65280,0)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution6	
	endif
	if(UseSet7)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution7
		AppendToGraph /W=IN2L_ASAXSGraph1 VolumeDistribution7 vs DiameterDistribution7
		ModifyGraph /W=IN2L_ASAXSGraph1 marker(VolumeDistribution7)=7
		ModifyGraph /W=IN2L_ASAXSGraph1 rgb(VolumeDistribution7)=(16384,65280,16384)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution7
	endif
	if(UseSet8)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution8
		AppendToGraph /W=IN2L_ASAXSGraph1 VolumeDistribution8 vs DiameterDistribution8
		ModifyGraph /W=IN2L_ASAXSGraph1 marker(VolumeDistribution8)=8
		ModifyGraph /W=IN2L_ASAXSGraph1 rgb(VolumeDistribution8)=(0,15872,65280)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph1 VolumeDistribution8	
	endif

	variable testForlabel=UseSet1+UseSet2+UseSet3+UseSet4+UseSet5+UseSet6+UseSet7+UseSet8
	if (testForlabel>0)
		Label /W=IN2L_ASAXSGraph1 left "Volume Distribution"
		Label /W=IN2L_ASAXSGraph1 bottom "Diameter [A]"
		ModifyGraph /W=IN2L_ASAXSGraph1 mode=4
		ModifyGraph /W=IN2L_ASAXSGraph1 msize=2
		ModifyGraph/W=IN2L_ASAXSGraph1 log=0
		IN2G_GenerateLegendForGraph(8,1,0)
	endif
end

Function IN2L_AppendToGraph2()

	SetDataFolder root:Packages:ASAXS:
	NVAR UseSet1
	NVAR UseSet2
	NVAR UseSet3
	NVAR UseSet4
	NVAR UseSet5
	NVAR UseSet6
	NVAR UseSet7
	NVAR UseSet8
	
	DoWindow IN2L_ASAXSGraph2
	if(!V_flag)
		return 0
	endif
	
	if(UseSet1)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int1	
		AppendToGraph /W=IN2L_ASAXSGraph2 DSM_Int1 vs DSM_Qvec1	
		ModifyGraph /W=IN2L_ASAXSGraph2 marker(DSM_Int1)=1
		ModifyGraph /W=IN2L_ASAXSGraph2 rgb(DSM_Int1)=(0,0,0)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int1	
	endif
	if(UseSet2)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int2
		AppendToGraph /W=IN2L_ASAXSGraph2 DSM_Int2 vs DSM_Qvec2	
		ModifyGraph /W=IN2L_ASAXSGraph2 marker(DSM_Int2)=2
		ModifyGraph /W=IN2L_ASAXSGraph2 rgb(DSM_Int2)=(65280,0,0)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int2	
	endif
	if(UseSet3)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int3
		AppendToGraph /W=IN2L_ASAXSGraph2 DSM_Int3 vs DSM_Qvec3	
		ModifyGraph /W=IN2L_ASAXSGraph2 marker(DSM_Int3)=3
		ModifyGraph /W=IN2L_ASAXSGraph2 rgb(DSM_Int3)=(0,52224,0)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int3	
	endif
	if(UseSet4)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int4
		AppendToGraph /W=IN2L_ASAXSGraph2 DSM_Int4 vs DSM_Qvec4	
		ModifyGraph /W=IN2L_ASAXSGraph2 marker(DSM_Int4)=4
		ModifyGraph /W=IN2L_ASAXSGraph2 rgb(DSM_Int4)=(0,12800,52224)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int4	
	endif
	if(UseSet5)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int5
		AppendToGraph /W=IN2L_ASAXSGraph2 DSM_Int5 vs DSM_Qvec5	
		ModifyGraph /W=IN2L_ASAXSGraph2 marker(DSM_Int5)=5
		ModifyGraph /W=IN2L_ASAXSGraph2 rgb(DSM_Int5)=(52224,0,41728)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int5	
	endif
	if(UseSet6)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int6
		AppendToGraph /W=IN2L_ASAXSGraph2 DSM_Int6 vs DSM_Qvec6
		ModifyGraph /W=IN2L_ASAXSGraph2 marker(DSM_Int6)=6
		ModifyGraph /W=IN2L_ASAXSGraph2 rgb(DSM_Int6)=(65280,65280,0)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int6	
	endif
	if(UseSet7)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int7
		AppendToGraph /W=IN2L_ASAXSGraph2 DSM_Int7 vs DSM_Qvec7
		ModifyGraph /W=IN2L_ASAXSGraph2 marker(DSM_Int7)=7
		ModifyGraph /W=IN2L_ASAXSGraph2 rgb(DSM_Int7)=(16384,65280,16384)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int7
	endif
	if(UseSet8)
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int8
		AppendToGraph /W=IN2L_ASAXSGraph2 DSM_Int8 vs DSM_Qvec8
		ModifyGraph /W=IN2L_ASAXSGraph2 marker(DSM_Int8)=8
		ModifyGraph /W=IN2L_ASAXSGraph2 rgb(DSM_Int8)=(0,15872,65280)
	else
		RemoveFromGraph/Z /W=IN2L_ASAXSGraph2 DSM_Int8	
	endif

	variable testForlabel=UseSet1+UseSet2+UseSet3+UseSet4+UseSet5+UseSet6+UseSet7+UseSet8
	if (testForlabel>0)
		Label /W=IN2L_ASAXSGraph2 left "Intensity"
		Label /W=IN2L_ASAXSGraph2 bottom "Qvector [A-1]"
		ModifyGraph /W=IN2L_ASAXSGraph2 mode=4
		ModifyGraph /W=IN2L_ASAXSGraph2 msize=2
		ModifyGraph/W=IN2L_ASAXSGraph2 log=1
		IN2G_GenerateLegendForGraph(8,1,0)
	endif
end


//****************************************************************************************************************************
//****************************************************************************************************************************
//****************************************************************************************************************************

Function IN2L_Initialize()

	NewDataFolder /O root:ASAXS
	NewDataFolder /O root:Packages
	NewDataFolder /O root:Packages:ASAXS

	setDataFolder root:Packages:ASAXS

	//here we create strings
	//sample names

	string ListOfVariables
	string ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="Contrast1;Contrast2;Contrast3;Contrast4;Contrast5;Contrast6;Contrast7;Contrast8;Contrast9;Contrast10;ContrastVoids;NextEvaluationPoint;DelayBetweenFrames;"
	ListOfVariables+="UseSet1;UseSet2;UseSet3;UseSet4;UseSet5;UseSet6;UseSet7;UseSet8;UseSet9;UseSet10;PauseEvaluation;"
	ListOfVariables+="SolutionOrder;UseM_DSM;"
	

	ListOfStrings="SampleName1;SampleName2;SampleName3;SampleName4;SampleName5;SampleName6;SampleName7;SampleName8;SampleName9;SampleName10;"
	ListOfStrings+="EnergyFolder1;EnergyFolder2;EnergyFolder3;EnergyFolder4;EnergyFolder5;EnergyFolder6;EnergyFolder7;EnergyFolder8;EnergyFolder9;EnergyFolder10;"
	ListOfStrings+="OutputFolder;"
	
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
				
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	

	//and here we set the values for it...
	ListOfVariables="Contrast1;Contrast2;Contrast3;Contrast4;Contrast5;Contrast6;Contrast7;Contrast8;Contrast9;Contrast10;ContrastVoids;NextEvaluationPoint;DelayBetweenFrames;"
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR testVar=$(StringFromList(i,ListOfVariables))
		testVar=1
	endfor	

	ListOfVariables="UseSet1;UseSet2;UseSet3;UseSet4;UseSet5;UseSet6;UseSet7;UseSet8;UseSet9;UseSet10;PauseEvaluation;"
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		NVAR testVar=$(StringFromList(i,ListOfVariables))
		testVar=0
	endfor	
	
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		SVAR testStr=$(StringFromList(i,ListOfStrings))
		testStr="---"
	endfor	

	SVAR/Z ASAXSListOfOptions
	if (!SVAR_Exists(ASAXSListOfOptions))
		string/g 	ASAXSListOfOptions=""
		SVAR ASAXSListOfOptions
	endif

	NVAR/Z CurrentEvaluationPoint
	if (!NVAR_Exists(CurrentEvaluationPoint))
		variable/g CurrentEvaluationPoint=NaN
		NVAR CurrentEvaluationPoint
	endif
	
	make/O fit_PointVolumeContent
end

