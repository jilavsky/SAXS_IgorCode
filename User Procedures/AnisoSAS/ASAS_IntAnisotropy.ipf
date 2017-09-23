#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.2		

#include  <New Polar Graphs>

//1.2	modified 9/14/2017 to fix bugs from chanegd WMPolartGraph code. 
//1.1	modified 5 29 2005 to accept 5 populations JIL

Function ASAS_CalcAlphaAnisotropy(direction)
	variable direction
	//here we calculate anisotropy of scattering at given Qs for the current model
	ASAS_KillOldPolarGraphs("Alpha", direction)
	ASAS_CopyAnisoExpData("Alpha", direction)
	ASAS_AniCreateModelWaves(direction)
	ASAS_AniCalcModelWaves(direction)
	ASAS_AniDisplayPolarPlots("Alpha", direction)

end




Function ASAS_CalcOmegaAnisotropy(direction)
	variable direction
	//here we calculate anisotropy of scattering at given Qs for the current model
	ASAS_KillOldPolarGraphs("Omega", direction)
	ASAS_CopyAnisoExpData("Omega", direction)
	ASAS_AniCreateModelWaves(direction)
	ASAS_AniCalcModelWaves(direction)
	ASAS_AniDisplayPolarPlots("Omega", direction)
end

Function ASAS_KillOldPolarGraphs(which, direction)
	string which
	variable direction
	//here we copy aniso experiemntal data, if User provided them.
	//Let's first kill all the graphs, so we can kill all the data
	setDataFolder root:Packages:AnisoSAS
	variable i
	string DirStrng
	if (direction==1)
		DirStrng="X"
	elseif (direction==2)
		DirStrng="Y"
	elseif(direction==3)
		DirStrng="Z"
	endif
	string settings
	For(i=1;i<=6;i+=1)
		string GraphNameToUse="Anisotropy_"+num2str(i)+"_Dir_"+DirStrng
		DoWIndow $GraphNameToUse
		if (V_Flag)
			DoWIndow/K $GraphNameToUse
//			Execute("ASAS_justUpdate()")
//			DoUpdate
			settings= WMPolarSettingsNameForGraph(GraphNameToUse)
			WMPolarRemovePolarGraphData(GraphNameToUse, settings)
		endif
	endfor
end



Function ASAS_CopyAnisoExpData(which, direction)
	string which
	variable direction
	//here we copy aniso experiemntal data, if User provided them.
	setDataFolder root:Packages:AnisoSAS
	variable i
	//now we kill the data waves
	NVAR NumbQs=$("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_NumberOfQVectors")
	For(i=1;i<=6;i+=1)
		string KillWaveInt="Ani"+num2str(direction)+"_ExpIntQ"+num2str(i)
		string KillWaveAngle="Ani"+num2str(direction)+"_ExpAngleQ"+num2str(i)
		Wave/Z KillMe1=$KillWaveInt
		Wave/Z KillMe2=$KillWaveAngle
		KillWaves/Z KillMe1, KillMe2
	endfor
	
	//and now we can copy the data back
	For (i=1;i<=NumbQs;i+=1)
		SVAR FldrName=$("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_AnisoExpDataFldrQ"+num2str(i))
		SVAR IntName=$("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_AnisoExpDataIntQ"+num2str(i))
		SVAR AngleName=$("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_AnisoExpDataAngleQ"+num2str(i))
		
		IntName=PossiblyQuoteName(IntName)
		AngleName=PossiblyQuoteName(AngleName)
		
		if (strlen(FldrName)>5 && strlen(IntName)>0 && strlen(AngleName)>0)
			Wave/Z IntensityWave=$(FldrName+IntName)
			Wave/Z AngleWave=$(FldrName+AngleName)
			if (WaveExists(IntensityWave) && WaveExists(AngleWave))
				Duplicate /O IntensityWave, $("Ani"+num2str(direction)+"_ExpIntQ"+num2str(i))
				Duplicate /O AngleWave, $("Ani"+num2str(direction)+"_ExpAngleQ"+num2str(i))				
			endif
		endif
		
	endfor
end

Function ASAS_AniDisplayPolarPlots(WhichTypeWave, direction)
	string WhichTypeWave
	variable direction

	
	variable i, maxExp, maxMod
	NVAR NmbOfPlots=$("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_NumberOfQVectors")
	variable ExpDataExists=0

	string DirStrng
	if (direction==1)
		DirStrng="X"
	elseif (direction==2)
		DirStrng="Y"
	elseif(direction==3)
		DirStrng="Z"
	endif

	Variable ModelContainsNaNs, DataContainNaNs
	
	For(i=1;i<=NmbOfPlots; i+=1)
		ExpDataExists=0
		ModelContainsNaNs=0
		DataContainNaNs=0
		
		Wave/Z ExpIntensityWave= $("Ani"+num2str(direction)+"_ExpIntQ"+num2str(i))
		Wave/Z ExpAngleWave= $("Ani"+num2str(direction)+"_ExpAngleQ"+num2str(i))
		NVAR NormalizeExp= $("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_AnisoExpDataNormQ"+num2str(i))
		if (WaveExists(ExpIntensityWave) && WaveExists(ExpAngleWave))
			ExpDataExists=1
		endif
		
		Wave waveToDisplay=$("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_ModelIntQ"+num2str(i))
		NVAR Qval=$("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_Qvector"+num2str(i))
		string GraphNameToUse="Anisotropy_"+num2str(i)+"_Dir_"+DirStrng
		string GraphTitleToUse=" Q ="+num2str(Qval)+"   " + DirStrng+" Anisotropy"  
		string settings
		WaveStats /Q waveToDisplay
		ModelContainsNaNs=V_numNaNs
		
		if (ExpDataExists && NormalizeExp) 
			WaveStats /Q ExpIntensityWave
			MaxExp=V_max
			WaveStats /Q waveToDisplay
			MaxMod=V_max
			ExpIntensityWave=ExpIntensityWave*(MaxMod/MaxExp)			
			WaveStats /Q ExpIntensityWave
			DataContainNaNs=V_numNaNs
		endif
		
		if ((ModelContainsNaNs!=0)||(DataContainNaNs!=0))
			DoAlert 0, "Model or Exp Data for graph "+GraphNameToUse+" contained NaNs, graph will not be displayed"
		else
			settings= WMPolarSettingsNameForGraph(GraphNameToUse)
			WMPolarRemovePolarGraphData(GraphNameToUse, settings)
			ASAS_PolarPlot(waveToDisplay, GraphNameToUse)
			DoWindow/T $(GraphNameToUse),GraphTitleToUse
			if (ExpDataExists )
				string polesTraceName=WMPolarAppendTrace(GraphNameToUse,ExpIntensityWave, ExpAngleWave, 360)
	//			WMAppendPolarTrace(GraphNameToUse,ExpIntensityWave, ExpAngleWave, 360)		//this should work but does not 
			endif
			WMPolarAxesRedrawGraphNow(GraphNameToUse)
			if (ExpDataExists )
				ModifyGraph lsize(polarY1)=2,rgb(polarY1)=(0,0,0)
			endif
			SetAxis/W=$GraphNameToUse /N=1/A
		endif
	endfor
end

Function ASAS_CreatePolarPlot(GraphNameToUse)
		string GraphNameToUse

		WMPolarGraphGlobalsInit()
		Display/K=1
		DoWindow/C $(GraphNameToUse)
		String MyPolarPlotName=WMNewPolarGraph("_default_",GraphNameToUse)
end

Function ASAS_PolarPlot(WaveToPlot, GraphNameToUse)
		Wave WaveToPlot
		string GraphNameToUse
		//this should attempt to create the polar plot. Good luck...
		
//		WMNewPolarGraph(templateGraphName, newOrExistingGraphName)
//		WMPolarGraphDisplayed(radiusData)
//		WMPolarTraceNameForRadiusData(polarGraphName,radiusData)
//		WMPolarGraphSetVar(graphNameOrDefault,varName,variableValue)
//		WMPolarGraphGetVar(graphNameOrDefault,varName)
//		WMPolarGraphSetStr(graphNameOrDefault,varName,stringValue)
//		WMPolarGraphGetStr(graphNameOrDefault,varName)
//		WMPolarTagRadius(tagWaveRefHere,tagPointNumber)
//		WMPolarTagAngle(tagWaveRefHere,tagPointNumber)
//		WMPolarAxesRedrawGraphNow(polarGraphName)

		WMPolarGraphGlobalsInit()
		Display/K=1
		DoWindow/C $(GraphNameToUse)
		String MyPolarPlotName=WMNewPolarGraph("_default_",GraphNameToUse)
		
		// change some polar axes settings
		WMPolarGraphSetStr(MyPolarPlotName,"radiusAxesWhere","  0")
		WMPolarGraphSetStr(MyPolarPlotName,"radiusAxesHalves","Both Halves")
		
		WMPolarGraphSetVar(MyPolarPlotName,"radiusTickLabelOmitOrigin",1)
		WMPolarGraphSetVar(MyPolarPlotName,"tickLabelOpaque", 0)
		WMPolarGraphSetVar(MyPolarPlotName,"radiusApproxTicks",2)
		WMPolarGraphSetVar(MyPolarPlotName,"doMinorRadiusTicks",1)
		WMPolarGraphSetVar(MyPolarPlotName,"doMinGridSpacing", 0)
		
		// Scale the angle into frequency
//		WMPolarGraphSetStr(MyPolarPlotName,"angleTickLabelUnits", "degrees")
//		WMPolarGraphSetStr(MyPolarPlotName,"angleTickLabelNotation", "%g deg")
//		WMPolarGraphSetStr(MyPolarPlotName,"angleTickLabelSigns", " no signs")
//		NVAR fs
//		Variable/G root:Packages:WM_IFDL:iir_polar_fs= fs
//		WMPolarGraphSetVar(MyPolarPlotName,"angleTickLabelScale", fs/2/180)
//		WMPolarGraphSetVar(MyPolarPlotName,"angle0", -135)
		
		// use light gray for the axes
		Variable grey=48000	// 25%
		WMPolarGraphSetVar(MyPolarPlotName,"radiusAxisColorRed",grey)
		WMPolarGraphSetVar(MyPolarPlotName,"radiusAxisColorGreen",grey)
		WMPolarGraphSetVar(MyPolarPlotName,"radiusAxisColorBlue",grey)
		
		WMPolarGraphSetVar(MyPolarPlotName,"angleAxisColorRed",grey)
		WMPolarGraphSetVar(MyPolarPlotName,"angleAxisColorGreen",grey)
		WMPolarGraphSetVar(MyPolarPlotName,"angleAxisColorBlue",grey)
		
		WMPolarGraphSetVar(MyPolarPlotName,"majorGridColorRed",grey)
		WMPolarGraphSetVar(MyPolarPlotName,"majorGridColorGreen",grey)
		WMPolarGraphSetVar(MyPolarPlotName,"majorGridColorBlue",grey)
		
		WMPolarGraphSetVar(MyPolarPlotName,"minorGridColorRed",grey)
		WMPolarGraphSetVar(MyPolarPlotName,"minorGridColorGreen",grey)
		WMPolarGraphSetVar(MyPolarPlotName,"minorGridColorBlue",grey)
		
//		WAVE polesRadii, polesAngles, zerosRadii, zerosAngles
//		String polesTraceName= WMPolarAppendTrace(MyPolarPlotName,polesRadii, polesAngles, 2*pi)	// angles are in radians
//		String zerosTraceName= WMPolarAppendTrace(MyPolarPlotName,zerosRadii, zerosAngles, 2*pi)
		
		WMPolarGraphSetVar(MyPolarPlotName,"zeroAngleWhere",90)

		String polesTraceName= WMPolarAppendTrace(MyPolarPlotName,WaveToPlot, $"", 360)
		
		ModifyGraph/W=$MyPolarPlotName mode($polesTraceName)=4,marker($polesTraceName)=19
//		ModifyGraph/W=$MyPolarPlotName mode($zerosTraceName)=3,marker($zerosTraceName)=8, rgb($zerosTraceName)=(0,0,65280)
		// redraw
		WMPolarAxesRedrawGraphNow(MyPolarPlotName)
end

Function ASAS_AniCalcModelWaves(direction)
	variable direction
	//here we calculate intensity as function of alpha for the model...

	setDataFolder root:Packages:AnisoSAS
	NVAR numbQs=$("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_NumberOfQVectors")
	NVAR NmbPop=root:Packages:AnisoSAS:NumberOfPopulations
	
	variable i, j
	
	For (i=1;i<=numbQs;i+=1)	//for each Q
		NVAR Qval=$("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_Qvector"+num2str(i))

		Wave IntModelWv=$("Ani"+num2str(direction)+"_ModelIntQ"+num2str(i))
		Duplicate/O IntModelWv, tempWv
		IntModelWv=0

		if (direction==1)		//alpha is fixed, X direction...
			NVAR AlphaVal=$("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_AlphaFixed")
			For(j=1;j<=NmbPop;j+=1)
				NVAR  UseInterference=$("root:Packages:AnisoSAS:Pop"+num2str(j)+"_UseInterference")
				NVAR  ETA=$("root:Packages:AnisoSAS:Pop"+num2str(j)+"_InterfETA")
				NVAR  Pack=$("root:Packages:AnisoSAS:Pop"+num2str(j)+"_InterfPack")
				tempWv=0
				ASAS_CalcScatterVolume(j)			//make sure we have the right volume of particles 
				tempWv=ASAS_CalcIntOf1Scatterer(Qval, j, AlphaVal, x)
				tempWv=tempWv*ASAS_CalcNumOfParticles(j)
				tempWv=tempWv*10^(-16)
				if (UseInterference)
					tempWv /= (1+Pack*ASAS_SphereAmplitude(Qval,Eta))
				endif
				IntModelWv+=tempWv
			endfor
		else
			NVAR OmegaVal=$("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_OmegaFixed")			
			For(j=1;j<=NmbPop;j+=1)
				NVAR  UseInterference=$("root:Packages:AnisoSAS:Pop"+num2str(j)+"_UseInterference")
				NVAR  ETA=$("root:Packages:AnisoSAS:Pop"+num2str(j)+"_InterfETA")
				NVAR  Pack=$("root:Packages:AnisoSAS:Pop"+num2str(j)+"_InterfPack")
				tempWv=0
				ASAS_CalcScatterVolume(j)			//make sure we have the right volume of particles 
				tempWv=ASAS_CalcIntOf1Scatterer(Qval, j, x, OmegaVal)
				tempWv=tempWv*ASAS_CalcNumOfParticles(j)
				tempWv=tempWv*10^(-16)
				if (UseInterference)
					tempWv /= (1+Pack*ASAS_SphereAmplitude(Qval,Eta))
				endif
				IntModelWv+=tempWv
			endfor
		endif
	endfor	
	
end



//Function ASAS_AniCalcAlphaWaves()
//	//here we calculate intensity as function of alpha for the model...
//
//	setDataFolder root:Packages:AnisoSAS
//	NVAR numbQs=root:Packages:AnisoSAS:Ani_NumberOfQVectors
//	NVAR NmbPop=root:Packages:AnisoSAS:NumberOfPopulations
//	
//	variable i, j
//	For (i=1;i<=numbQs;i+=1)	//for each Q
//		NVAR Qval=$("root:Packages:AnisoSAS:Ani_Qvector"+num2str(i))
//		NVAR OmegaVal=root:Packages:AnisoSAS:Ani_OmegaFixed
//		Wave IntAlphaWv=$("AlphaAnisotropyInt_"+num2str(i))
//		Duplicate/O IntAlphaWv, tempWv
//		IntAlphaWv=0
//		
//		For(j=1;j<=NmbPop;j+=1)
//			tempWv=0
//			ASAS_CalcScatterVolume(j)			//make sure we have the right volume of particles 
//			tempWv=ASAS_CalcIntOf1Scatterer(Qval, j, x, OmegaVal)
//			tempWv=tempWv*ASAS_CalcNumOfParticles(j)
//			tempWv=tempWv*10^(-16)
//			IntAlphaWv+=tempWv
//		endfor
//	endfor	
//end
//

Function ASAS_AniCalcOnePopInt(PopNum,Qval, AlphaQ, OmegaQ)
		Variable PopNum, Qval, AlphaQ, OmegaQ
		
		setDataFolder root:Packages:AnisoSAS:

		
		variable IntPop
			
		IntPop=ASAS_CalcIntOf1Scatterer(Qval, PopNum, AlphaQ, OmegaQ)	//calculate intensity from one scatterer
		IntPop=IntPop*ASAS_CalcNumOfParticles(PopNum)			//multiply by number of scatterers
		IntPop=IntPop*10^(-16)									//Calc from one scatterer is in units of radius, which is A2
		//this converts the result into cm2
		return IntPop
end


Function ASAS_AniCreateModelWaves(direction)
	variable direction 
	setDataFolder root:Packages:AnisoSAS
	NVAR numbQs=$("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_NumberOfQVectors")
	if(direction<1.5)		//this is aniso 1 - omega direction
		NVAR NmbPnts=$("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_NumberOmegaPoints")
	else					//these are alpha direction...
		NVAR NmbPnts=$("root:Packages:AnisoSAS:Ani"+num2str(direction)+"_NumberAlphaPoints")
	endif
	
	variable i
	For (i=1;i<=numbQs;i+=1)
		Make/O/N=(NmbPnts)/D $("Ani"+num2str(direction)+"_ModelIntQ"+num2str(i))
		Wave ModelWv=$("Ani"+num2str(direction)+"_ModelIntQ"+num2str(i))
		SetScale/I x 0, 360,"", ModelWv
	endfor
	
end

Function ASAS_ModelAnisotropy(which)
	variable which 		//1 for X direction, 2 for Y direction and 3 for Z direction
	//this function initializes and calculates anisotropy of the intensity from the model data
	DoWindow $("ASAS_AnisoPanel"+num2str(which))
	if (V_Flag)
		DoWIndow/K $("ASAS_AnisoPanel"+num2str(which))
	endif
	if (which==1)
		Execute ("ASAS_AnisoPanel1()")
		ASAS_AniFixPanel1()
	elseif(which==2)
		Execute ("ASAS_AnisoPanel2()")
		ASAS_AniFixPanel2()
	elseif(which==3)
		Execute ("ASAS_AnisoPanel3()")
		ASAS_AniFixPanel3()
	endif
end

Window ASAS_AnisoDataSelection() : Panel

	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(100,100,600,300) as "ASAS_AnisoDataSelection"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (16384,16384,65280)
	DrawText 60,33,"Use this panel to select waves with data"


	SetVariable AnisoSelectionFldr,pos={22,46},size={400,19},noproc,title="Data folder:", noedit=1
	SetVariable AnisoSelectionFldr,fSize=12, help={"This is folder name, which was selected on previous panel. Do not change, select the wave names below"}
	SetVariable AnisoSelectionFldr,value= $("root:Packages:AnisoSAS:Ani"+num2str(root:Packages:AnisoSAS:Ani_AnisoSelectorDir)+"_AnisoExpDataFldrQ"+num2str(root:Packages:AnisoSAS:Ani_AnisoSelectorQ))

	PopupMenu AnisoSelectionInt,pos={22,80},size={400,19},title="Intensity wv:",proc=ASAS_PopMenuProc
	PopupMenu AnisoSelectionInt,fSize=12, help={"Select wave with intensity"}
	PopupMenu AnisoSelectionInt ,mode=1, popvalue=$("root:Packages:AnisoSAS:Ani"+num2str(root:Packages:AnisoSAS:Ani_AnisoSelectorDir)+"_AnisoExpDataIntQ"+num2str(root:Packages:AnisoSAS:Ani_AnisoSelectorQ))
	PopupMenu AnisoSelectionInt, value= #"\"---;\"+IN2G_CreateListOfItemsInFolder($(\"root:Packages:AnisoSAS:Ani\"+num2str(root:Packages:AnisoSAS:Ani_AnisoSelectorDir)+\"_AnisoExpDataFldrQ\"+num2str(root:Packages:AnisoSAS:Ani_AnisoSelectorQ)),2)"

	PopupMenu AnisoSelectionAngle,pos={22,110},size={400,19},title="Angle wv:",proc=ASAS_PopMenuProc
	PopupMenu AnisoSelectionAngle,fSize=12, help={"Select wave with angle, angle in degrees"}
	PopupMenu AnisoSelectionAngle,mode=1,popvalue=$("root:Packages:AnisoSAS:Ani"+num2str(root:Packages:AnisoSAS:Ani_AnisoSelectorDir)+"_AnisoExpDataAngleQ"+num2str(root:Packages:AnisoSAS:Ani_AnisoSelectorQ))
	PopupMenu AnisoSelectionAngle, value= #"\"---;\"+IN2G_CreateListOfItemsInFolder($(\"root:Packages:AnisoSAS:Ani\"+num2str(root:Packages:AnisoSAS:Ani_AnisoSelectorDir)+\"_AnisoExpDataFldrQ\"+num2str(root:Packages:AnisoSAS:Ani_AnisoSelectorQ)),2)"
	
	CheckBox AnisoSelectionNormalize, fsize=12, help={"Check if you want to renormalize the data to calculated model" }, title="Normalize experimental data to model?  "
	CheckBox AnisoSelectionNormalize, pos={30,150 }, proc=ASAS_CheckProc, value=$("root:Packages:AnisoSAS:Ani"+num2str(root:Packages:AnisoSAS:Ani_AnisoSelectorDir)+"_AnisoExpDataNormQ"+num2str(root:Packages:AnisoSAS:Ani_AnisoSelectorQ))

EndMacro


Window ASAS_AnisoPanel1() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(47.25,32.25,500,400) as "Anisotropy calculations direction X"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 1,textrgb= (0,0,65280)
	DrawText 53,28,"Calculations of anisotropy in X direction"
	PopupMenu Ani1NumberOfQs,pos={52,44},size={217,21},proc=ASAS_PopMenuProc,title="Select number of Qs to calculate :"
	PopupMenu Ani1NumberOfQs,mode=1,popvalue=num2str(root:Packages:AnisoSAS:Ani1_NumberOfQVectors),value= #"\"0;1;2;3;4;5;6\"", help={"Select number of Qs you want to calculate"}
	SetVariable Ani1Qvalue1,pos={10,80},size={110,16},title="First Q        ",help={"This is the first Q, suggest lowest number goes here..."}
	SetVariable Ani1Qvalue1,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani1_Qvector1	
	SetVariable Ani1Qvalue2,pos={10,105},size={110,16},title="Second Q  ",help={"This is the second Q"}
	SetVariable Ani1Qvalue2,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani1_Qvector2
	SetVariable Ani1Qvalue3,pos={10,130},size={110,16},title="Third Q      ",help={"This is the third Q"}
	SetVariable Ani1Qvalue3,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani1_Qvector3
	SetVariable Ani1Qvalue4,pos={10,155},size={110,16},title="Fourth Q   ",help={"This is the fourth Q"}
	SetVariable Ani1Qvalue4,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani1_Qvector4
	SetVariable Ani1Qvalue5,pos={10,180},size={110,16},title="Fifth Q      ",help={"This is the fifth Q"}
	SetVariable Ani1Qvalue5,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani1_Qvector5
	SetVariable Ani1Qvalue6,pos={10,205},size={110,16},title="Sixth Q     ",help={"This is the sixth Q, suggest highest number goes here..."}
	SetVariable Ani1Qvalue6,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani1_Qvector6

	PopupMenu Ani1Qval1FolderName,pos={120,80},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani1Qval1FolderName,help={"Select folder with aniso data for Q1"}
	PopupMenu Ani1Qval1FolderName,mode=1, popvalue=root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ1,value= #"root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ1+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani1Qval2FolderName,pos={120,105},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani1Qval2FolderName,help={"Select folder with aniso data for Q2"}
	PopupMenu Ani1Qval2FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ2,value= #"root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ2+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani1Qval3FolderName,pos={120,130},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani1Qval3FolderName,help={"Select folder with aniso data for Q3"}
	PopupMenu Ani1Qval3FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ3,value= #"root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ3+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani1Qval4FolderName,pos={120,155},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani1Qval4FolderName,help={"Select folder with aniso data for Q4"}
	PopupMenu Ani1Qval4FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ4,value= #"root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ4+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani1Qval5FolderName,pos={120,180},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani1Qval5FolderName,help={"Select folder with aniso data for Q5"}
	PopupMenu Ani1Qval5FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ5,value= #"root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ5+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani1Qval6FolderName,pos={120,205},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani1Qval6FolderName,help={"Select folder with aniso data for Q6"}
	PopupMenu Ani1Qval6FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ6,value= #"root:Packages:AnisoSAS:Ani1_AnisoExpDataFldrQ6+\";---;\"+ASAS_GenStringOfAnisoFolders()"

//	SetVariable Ani1AlphaPoints,pos={10,250},size={120,16},title="Alpha points   ",help={"Input number of points to create for alpha dependence, Apha range is 2pi"}
//	SetVariable Ani1AlphaPoints,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani1_NumberAlphaPoints
	SetVariable Ani1OmegaPoints,pos={160,250},size={120,16},title="Omega points",help={"Input number of points to create for omega dependence, Omega range is 2pi"}
	SetVariable Ani1OmegaPoints,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani1_NumberOmegaPoints

//	SetVariable Ani1OmegaFixed,pos={10,270},size={120,16},title="For Omega of ",help={"Input omega value for this dependence, in degrees"}
//	SetVariable Ani1OmegaFixed,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani1_OmegaFixed
	SetVariable Ani1AlphaFixed,pos={160,270},size={120,16},title="For Alpha of   ",help={"Input Alpha value for this dependence, in degrees"}
	SetVariable Ani1AlphaFixed,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani1_AlphaFixed //, noedit=1
	
//	Button Ani1CalcAlphaAniso,pos={10,300},size={120,20},proc=ASAS_ButtonProc,title="Calc Alpha aniso"
//	Button Ani1CalcAlphaAniso,help={"This button calculates Anisotropy of intensity from model as function of Alpha"}
	Button Ani1CalcOmegaAniso,pos={160,300},size={120,20},proc=ASAS_ButtonProc,title="Calc X dir aniso"
	Button Ani1CalcOmegaAniso,help={"This button calculates Anisotropy of intensity from model as function of Omega"}

EndMacro


Window ASAS_AnisoPanel2() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(47.25,32.25,500,400) as "Anisotropy calculations direction Y"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 1,textrgb= (0,0,65280)
	DrawText 53,28,"Calculations of anisotropy in Y direction"
	PopupMenu Ani2NumberOfQs,pos={52,44},size={217,21},proc=ASAS_PopMenuProc,title="Select number of Qs to calculate :"
	PopupMenu Ani2NumberOfQs,mode=1,popvalue=num2str(root:Packages:AnisoSAS:Ani2_NumberOfQVectors),value= #"\"0;1;2;3;4;5;6\"", help={"Select number of Qs you want to calculate"}
	SetVariable Ani2Qvalue1,pos={10,80},size={110,16},title="First Q        ",help={"This is the first Q, suggest lowest number goes here..."}
	SetVariable Ani2Qvalue1,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani2_Qvector1	
	SetVariable Ani2Qvalue2,pos={10,105},size={110,16},title="Second Q  ",help={"This is the second Q"}
	SetVariable Ani2Qvalue2,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani2_Qvector2
	SetVariable Ani2Qvalue3,pos={10,130},size={110,16},title="Third Q      ",help={"This is the third Q"}
	SetVariable Ani2Qvalue3,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani2_Qvector3
	SetVariable Ani2Qvalue4,pos={10,155},size={110,16},title="Fourth Q   ",help={"This is the fourth Q"}
	SetVariable Ani2Qvalue4,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani2_Qvector4
	SetVariable Ani2Qvalue5,pos={10,180},size={110,16},title="Fifth Q      ",help={"This is the fifth Q"}
	SetVariable Ani2Qvalue5,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani2_Qvector5
	SetVariable Ani2Qvalue6,pos={10,205},size={110,16},title="Sixth Q     ",help={"This is the sixth Q, suggest highest number goes here..."}
	SetVariable Ani2Qvalue6,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani2_Qvector6

	PopupMenu Ani2Qval1FolderName,pos={120,80},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani2Qval1FolderName,help={"Select folder with aniso data for Q1"}
	PopupMenu Ani2Qval1FolderName,mode=1, popvalue=root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ1,value= #"root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ1+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani2Qval2FolderName,pos={120,105},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani2Qval2FolderName,help={"Select folder with aniso data for Q2"}
	PopupMenu Ani2Qval2FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ2,value= #"root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ2+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani2Qval3FolderName,pos={120,130},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani2Qval3FolderName,help={"Select folder with aniso data for Q3"}
	PopupMenu Ani2Qval3FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ3,value= #"root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ3+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani2Qval4FolderName,pos={120,155},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani2Qval4FolderName,help={"Select folder with aniso data for Q4"}
	PopupMenu Ani2Qval4FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ4,value= #"root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ4+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani2Qval5FolderName,pos={120,180},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani2Qval5FolderName,help={"Select folder with aniso data for Q5"}
	PopupMenu Ani2Qval5FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ5,value= #"root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ5+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani2Qval6FolderName,pos={120,205},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani2Qval6FolderName,help={"Select folder with aniso data for Q6"}
	PopupMenu Ani2Qval6FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ6,value= #"root:Packages:AnisoSAS:Ani2_AnisoExpDataFldrQ6+\";---;\"+ASAS_GenStringOfAnisoFolders()"

	SetVariable Ani2AlphaPoints,pos={10,250},size={120,16},title="Alpha points   ",help={"Input number of points to create for alpha dependence, Apha range is 2pi"}
	SetVariable Ani2AlphaPoints,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani2_NumberAlphaPoints
//	SetVariable Ani2OmegaPoints,pos={160,250},size={120,16},title="Omega points",help={"Input number of points to create for omega dependence, Omega range is 2pi"}
//	SetVariable Ani2OmegaPoints,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani2_NumberOmegaPoints

	SetVariable Ani2OmegaFixed,pos={10,270},size={120,16},title="For Omega of ",help={"Input omega value for this dependence, in degrees"}
	SetVariable Ani2OmegaFixed,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani2_OmegaFixed
//	SetVariable Ani2AlphaFixed,pos={160,270},size={120,16},title="For Alpha of   ",help={"Input Alpha value for this dependence, in degrees"}
//	SetVariable Ani2AlphaFixed,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani2_AlphaFixed

	Button Ani2CalcAlphaAniso,pos={10,300},size={120,20},proc=ASAS_ButtonProc,title="Calc Y dir aniso"
	Button Ani2CalcAlphaAniso,help={"This button calculates Anisotropy of intensity from model as function of Alpha"}
//	Button Ani2CalcOmegaAniso,pos={160,300},size={120,20},proc=ASAS_ButtonProc,title="Calc Omega aniso"
//	Button Ani2CalcOmegaAniso,help={"This button calculates Anisotropy of intensity from model as function of Omega"}

EndMacro


Window ASAS_AnisoPanel3() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(47.25,32.25,500,400) as "Anisotropy calculations direction Z"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 18,fstyle= 1,textrgb= (0,0,65280)
	DrawText 53,28,"Calculations of anisotropy in Z direction"
	PopupMenu Ani3NumberOfQs,pos={52,44},size={217,21},proc=ASAS_PopMenuProc,title="Select number of Qs to calculate :"
	PopupMenu Ani3NumberOfQs,mode=1,popvalue=num2str(root:Packages:AnisoSAS:Ani3_NumberOfQVectors),value= #"\"0;1;2;3;4;5;6\"", help={"Select number of Qs you want to calculate"}
	SetVariable Ani3Qvalue1,pos={10,80},size={110,16},title="First Q        ",help={"This is the first Q, suggest lowest number goes here..."}
	SetVariable Ani3Qvalue1,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani3_Qvector1	
	SetVariable Ani3Qvalue2,pos={10,105},size={110,16},title="Second Q  ",help={"This is the second Q"}
	SetVariable Ani3Qvalue2,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani3_Qvector2
	SetVariable Ani3Qvalue3,pos={10,130},size={110,16},title="Third Q      ",help={"This is the third Q"}
	SetVariable Ani3Qvalue3,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani3_Qvector3
	SetVariable Ani3Qvalue4,pos={10,155},size={110,16},title="Fourth Q   ",help={"This is the fourth Q"}
	SetVariable Ani3Qvalue4,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani3_Qvector4
	SetVariable Ani3Qvalue5,pos={10,180},size={110,16},title="Fifth Q      ",help={"This is the fifth Q"}
	SetVariable Ani3Qvalue5,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani3_Qvector5
	SetVariable Ani3Qvalue6,pos={10,205},size={110,16},title="Sixth Q     ",help={"This is the sixth Q, suggest highest number goes here..."}
	SetVariable Ani3Qvalue6,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani3_Qvector6

	PopupMenu Ani3Qval1FolderName,pos={120,80},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani3Qval1FolderName,help={"Select folder with aniso data for Q1"}
	PopupMenu Ani3Qval1FolderName,mode=1, popvalue=root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ1,value= #"root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ1+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani3Qval2FolderName,pos={120,105},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani3Qval2FolderName,help={"Select folder with aniso data for Q2"}
	PopupMenu Ani3Qval2FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ2,value= #"root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ2+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani3Qval3FolderName,pos={120,130},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani3Qval3FolderName,help={"Select folder with aniso data for Q3"}
	PopupMenu Ani3Qval3FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ3,value= #"root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ3+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani3Qval4FolderName,pos={120,155},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani3Qval4FolderName,help={"Select folder with aniso data for Q4"}
	PopupMenu Ani3Qval4FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ4,value= #"root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ4+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani3Qval5FolderName,pos={120,180},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani3Qval5FolderName,help={"Select folder with aniso data for Q5"}
	PopupMenu Ani3Qval5FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ5,value= #"root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ5+\";---;\"+ASAS_GenStringOfAnisoFolders()"
	PopupMenu Ani3Qval6FolderName,pos={120,205},size={79,21},proc=ASAS_PopMenuProc,title="Exp Data:"
	PopupMenu Ani3Qval6FolderName,help={"Select folder with aniso data for Q6"}
	PopupMenu Ani3Qval6FolderName,mode=1,  popvalue=root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ6,value= #"root:Packages:AnisoSAS:Ani3_AnisoExpDataFldrQ6+\";---;\"+ASAS_GenStringOfAnisoFolders()"

	SetVariable Ani3AlphaPoints,pos={10,250},size={120,16},title="Alpha points   ",help={"Input number of points to create for alpha dependence, Apha range is 2pi"}
	SetVariable Ani3AlphaPoints,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani3_NumberAlphaPoints
//	SetVariable Ani3OmegaPoints,pos={160,250},size={120,16},title="Omega points",help={"Input number of points to create for omega dependence, Omega range is 2pi"}
//	SetVariable Ani3OmegaPoints,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani3_NumberOmegaPoints

	SetVariable Ani3OmegaFixed,pos={10,270},size={120,16},title="For Omega of ",help={"Input omega value for this dependence, in degrees"}
	SetVariable Ani3OmegaFixed,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani3_OmegaFixed
//	SetVariable Ani3AlphaFixed,pos={160,270},size={120,16},title="For Alpha of   ",help={"Input Alpha value for this dependence, in degrees"}
//	SetVariable Ani3AlphaFixed,limits={0,Inf,0},value= root:Packages:AnisoSAS:Ani3_AlphaFixed

	Button Ani3CalcAlphaAniso,pos={10,300},size={120,20},proc=ASAS_ButtonProc,title="Calc Z dir aniso"
	Button Ani3CalcAlphaAniso,help={"This button calculates Anisotropy of intensity from model as function of Alpha"}
//	Button Ani3CalcOmegaAniso,pos={160,300},size={120,20},proc=ASAS_ButtonProc,title="Calc Omega aniso"
//	Button Ani3CalcOmegaAniso,help={"This button calculates Anisotropy of intensity from model as function of Omega"}

EndMacro



Function ASAS_AniFixPanel1()

	setDataFolder root:Packages:AnisoSAS
	NVAR NmbQs=root:Packages:AnisoSAS:Ani1_NumberOfQVectors
	
	SetVariable Ani1Qvalue1, win=ASAS_AnisoPanel1, disable=(NmbQs<1)
	SetVariable Ani1Qvalue2, win=ASAS_AnisoPanel1, disable=(NmbQs<2)
	SetVariable Ani1Qvalue3, win=ASAS_AnisoPanel1, disable=(NmbQs<3)
	SetVariable Ani1Qvalue4, win=ASAS_AnisoPanel1, disable=(NmbQs<4)
	SetVariable Ani1Qvalue5, win=ASAS_AnisoPanel1, disable=(NmbQs<5)
	SetVariable Ani1Qvalue6, win=ASAS_AnisoPanel1, disable=(NmbQs<6)
	
	PopupMenu Ani1Qval1FolderName, win=ASAS_AnisoPanel1, disable=(NmbQs<1)
	PopupMenu Ani1Qval2FolderName, win=ASAS_AnisoPanel1, disable=(NmbQs<2)
	PopupMenu Ani1Qval3FolderName, win=ASAS_AnisoPanel1, disable=(NmbQs<3)
	PopupMenu Ani1Qval4FolderName, win=ASAS_AnisoPanel1, disable=(NmbQs<4)
	PopupMenu Ani1Qval5FolderName, win=ASAS_AnisoPanel1, disable=(NmbQs<5)
	PopupMenu Ani1Qval6FolderName, win=ASAS_AnisoPanel1, disable=(NmbQs<6)
	

end


Function ASAS_AniFixPanel2()

	setDataFolder root:Packages:AnisoSAS
	NVAR NmbQs=root:Packages:AnisoSAS:Ani2_NumberOfQVectors
	
	SetVariable Ani2Qvalue1, win=ASAS_AnisoPanel2, disable=(NmbQs<1)
	SetVariable Ani2Qvalue2, win=ASAS_AnisoPanel2, disable=(NmbQs<2)
	SetVariable Ani2Qvalue3, win=ASAS_AnisoPanel2, disable=(NmbQs<3)
	SetVariable Ani2Qvalue4, win=ASAS_AnisoPanel2, disable=(NmbQs<4)
	SetVariable Ani2Qvalue5, win=ASAS_AnisoPanel2, disable=(NmbQs<5)
	SetVariable Ani2Qvalue6, win=ASAS_AnisoPanel2, disable=(NmbQs<6)
	
	PopupMenu Ani2Qval1FolderName, win=ASAS_AnisoPanel2, disable=(NmbQs<1)
	PopupMenu Ani2Qval2FolderName, win=ASAS_AnisoPanel2, disable=(NmbQs<2)
	PopupMenu Ani2Qval3FolderName, win=ASAS_AnisoPanel2, disable=(NmbQs<3)
	PopupMenu Ani2Qval4FolderName, win=ASAS_AnisoPanel2, disable=(NmbQs<4)
	PopupMenu Ani2Qval5FolderName, win=ASAS_AnisoPanel2, disable=(NmbQs<5)
	PopupMenu Ani2Qval6FolderName, win=ASAS_AnisoPanel2, disable=(NmbQs<6)
	

end

Function ASAS_AniFixPanel3()

	setDataFolder root:Packages:AnisoSAS
	NVAR NmbQs=root:Packages:AnisoSAS:Ani3_NumberOfQVectors
	
	SetVariable Ani3Qvalue1, win=ASAS_AnisoPanel3, disable=(NmbQs<1)
	SetVariable Ani3Qvalue2, win=ASAS_AnisoPanel3, disable=(NmbQs<2)
	SetVariable Ani3Qvalue3, win=ASAS_AnisoPanel3, disable=(NmbQs<3)
	SetVariable Ani3Qvalue4, win=ASAS_AnisoPanel3, disable=(NmbQs<4)
	SetVariable Ani3Qvalue5, win=ASAS_AnisoPanel3, disable=(NmbQs<5)
	SetVariable Ani3Qvalue6, win=ASAS_AnisoPanel3, disable=(NmbQs<6)
	
	PopupMenu Ani3Qval1FolderName, win=ASAS_AnisoPanel3, disable=(NmbQs<1)
	PopupMenu Ani3Qval2FolderName, win=ASAS_AnisoPanel3, disable=(NmbQs<2)
	PopupMenu Ani3Qval3FolderName, win=ASAS_AnisoPanel3, disable=(NmbQs<3)
	PopupMenu Ani3Qval4FolderName, win=ASAS_AnisoPanel3, disable=(NmbQs<4)
	PopupMenu Ani3Qval5FolderName, win=ASAS_AnisoPanel3, disable=(NmbQs<5)
	PopupMenu Ani3Qval6FolderName, win=ASAS_AnisoPanel3, disable=(NmbQs<6)
	

end

