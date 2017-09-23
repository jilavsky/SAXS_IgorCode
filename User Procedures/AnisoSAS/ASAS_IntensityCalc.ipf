#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.1		//modified 5 29 2005 to accept 5 populations JIL


//This file contains calculations of intensities for ASAS



Function ASAS_CalcAllSurfaces()
	//here we need to calculate all intensities, let's see how to do that...

	setDataFolder root:Packages:AnisoSAS:
	variable i, j
	
	NVAR TotalSurfaceArea = root:Packages:AnisoSAS:TotalSurfaceArea
	
	TotalSurfaceArea=0
	//and up to 5 populations
	NVAR NmbPop=root:Packages:AnisoSAS:NumberOfPopulations
	
	For(j=1;j<=NmbPop;j+=1)
			TotalSurfaceArea+=ASAS_CalcOnePopSfcArea(j)		//here we should make the real calculations
	endfor

	print "Total void system surface area = "+num2str(TotalSurfaceArea)+"  cm2/cm3"
end

Function ASAS_CalcOnePopSfcArea(PopNum)
	variable PopNum
	
	
	variable surface, ScattererVolume, ScattererSurface, Chi

	setDataFolder root:Packages:AnisoSAS:
	
	NVAR Radius=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_Radius")
	NVAR Beta=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_Beta")
	NVAR TotalVolume=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_VolumeFraction")
	NVAR PopSurface=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_SurfaceArea")
	
	if (Beta<1)
		Chi = (1/(2*Beta))*(1+ ( Beta^2/sqrt(1-Beta^2) ) * ln((1+sqrt(1-Beta^2))/Beta) )
	else
		Chi = (1/(2*Beta))*(1+(Beta^2/sqrt(Beta^2-1))*asin(sqrt(Beta^2-1)/Beta))
	endif
	if (Beta==1)
		Chi = 1
	endif
	
	ScattererVolume=(4/3)*pi*Beta*Radius^3		//in radius units, i.e., in A	

	ScattererSurface = 4 * pi * Beta * Chi * Radius^2

		surface = ScattererSurface * TotalVolume /ScattererVolume			//A^2/A^3... A^-1
		surface=surface*10^8									//Calc from one scatterer is in units of radius, which is A2
		//this converts the result into cm2
	
	PopSurface = surface
	
	return surface

end

Function ASAS_CalcAllIntensities()
	//here we need to calculate all intensities, let's see how to do that...

	setDataFolder root:Packages:AnisoSAS:
	variable i, j
	
	
//	ASAS_CalcCreateWaves()			//creates needed Waves for model intensity and Q vector
//			//first create final intensity (summ of all populations) and Qvector for all of them
//			//And now create intensity for all populations
	
	//we have up to 6 directions
	NVAR NmbDir=root:Packages:AnisoSAS:NumberOfDirections
	
		variable startT
	//and up to 5 populations
	NVAR NmbPop=root:Packages:AnisoSAS:NumberOfPopulations
	
	For (i=1;i<=NmbDir;i+=1)

		Wave Int=$("root:Packages:AnisoSAS:Dir"+num2str(i)+"_CutIntensity")
		Wave Qvec=$("root:Packages:AnisoSAS:Dir"+num2str(i)+"_CutQvector")
		Duplicate/O Int, $("Dir"+num2str(i)+"_ModelIntensity")
		Duplicate/O Qvec, $("Dir"+num2str(i)+"_ModelQvector")
		Wave Int=$("Dir"+num2str(i)+"_ModelIntensity")
		Int=0
		
		For(j=1;j<=NmbPop;j+=1)
			if(ASAS_NeedToRecalculatePop(i,j))
				Duplicate/O Int, $("Dir"+num2str(i)+"_Pop"+num2str(j)+"_ModelIntensity")	
				startT=ticks
				ASAS_CalcOnePopDir(j,i)		//here we should make the real calculations
				print "Recalculation time was about [s]: "+num2str((ticks-startT)/60)
				Wave IntPop= $("Dir"+num2str(i)+"_Pop"+num2str(j)+"_ModelIntensity")
				Note/K IntPop
				note IntPop, ASAS_GenerateNewWaveNoteRecord(i, j)
			else
				Wave IntPop= $("Dir"+num2str(i)+"_Pop"+num2str(j)+"_ModelIntensity")
				NVAR VolumeFraction = $("Pop"+num2str(j)+"_VolumeFraction")
				if(cmpstr(num2str(VolumeFraction),StringByKey("Pop"+num2str(j)+"_VolumeFraction", note(IntPop)))!=0)
					IntPop = IntPop * VolumeFraction / NumberByKey("Pop"+num2str(j)+"_VolumeFraction", note(IntPop))
					Note/K IntPop
					note IntPop, ASAS_GenerateNewWaveNoteRecord(i, j)
				endif
			endif
			Int+=IntPop					//ahd here we summ it to the overall intensity in this direction
		endfor
	endfor


end


Function ASAS_NeedToRecalculatePop(dirNumber, popNumber)
	variable dirNumber, popNumber

	setDataFolder root:Packages:AnisoSAS:
	Wave/Z IntPop= $("Dir"+num2str(dirNumber)+"_Pop"+num2str(popNumber)+"_ModelIntensity")
	Wave Qvec=$("root:Packages:AnisoSAS:Dir"+num2str(dirNumber)+"_CutQvector")
	Wave AlphaDist=$("root:Packages:AnisoSAS:Pop"+num2str(popNumber)+"_AlphaDist")
	Wave/T AlphaDistDesc=$("root:Packages:AnisoSAS:Pop"+num2str(popNumber)+"_AlphaDistDesc")
	Wave OmegaDist=$("root:Packages:AnisoSAS:Pop"+num2str(popNumber)+"_OmegaDist")
	Wave/T OmegaDistDesc= $("root:Packages:AnisoSAS:Pop"+num2str(popNumber)+"_OmegaDistDesc")
	print "Evaluated if there is need to recalculate direction = "+num2str(dirNumber) +"  population = "+num2str(popNumber)+" reevaluated due to:"
	if(!WaveExists(IntPop))
		print "Data did not exist"
		return 1
	endif
	string ListOfVariables, ListOfStrings, OldNote
	variable i
	OldNote = note(IntPop)
	For(i=0;i<numpnts(Qvec);i+=5)
		if(cmpstr(num2str(Qvec[i]),StringByKey("Qvec"+num2str(i), OldNote))!=0)
			print "Qvec"	
			return 1
		endif
	endfor
	For(i=0;i<numpnts(AlphaDistDesc);i+=5)
		if(cmpstr(AlphaDistDesc[i],StringByKey("AlphaDistDesc"+num2str(i), OldNote))!=0)
			print "AlphaDistDesc"	
			print AlphaDistDesc[i]
			print StringByKey("AlphaDistDesc"+num2str(i), OldNote)
			return 1
		endif
	endfor
	For(i=0;i<numpnts(AlphaDist);i+=5)
		if(cmpstr(num2str(AlphaDist[i]),StringByKey("AlphaDist"+num2str(i), OldNote))!=0)
			print "AlphaDist"	
			return 1
		endif
	endfor
	For(i=0;i<numpnts(OmegaDist);i+=5)
		if(cmpstr(num2str(OmegaDist[i]),StringByKey("OmegaDist"+num2str(i), OldNote))!=0)
			print "OmegaDist"	
			return 1
		endif
	endfor
	For(i=0;i<numpnts(OmegaDistDesc);i+=5)
		if(cmpstr(OmegaDistDesc[i],StringByKey("OmegaDistDesc"+num2str(i), OldNote))!=0)
			print "OmegaDistDesc"	
			return 1
		endif
	endfor


	ListOfVariables="Wavelength;UseOfFormula4;IntegrationStepsInAlpha;IntegrationStepsInOmega;Mprecision;"
	For(i=0;i<ItemsInList(ListOfVariables);i+=1)
		NVAR tempV=$(StringFromList(i, ListOfVariables))
		if(cmpstr(num2str(tempV),StringByKey(StringFromList(i, ListOfVariables), OldNote))!=0)
			print "Wavelength;UseOfFormula4;IntegrationStepsInAlpha;IntegrationStepsInOmega;Mprecision;"
			return 1
		endif
	endfor
	ListOfVariables="Pop1_Radius;Pop1_DeltaRho;Pop1_Beta;Pop1_ScattererVolume;Pop1_Nee;Pop1_FWHM;"
	ListOfVariables+="Pop1_PAlphaSteps;Pop1_BOmegaSteps;"
	ListOfVariables+="Pop1_UsePAlphaParam;Pop1_PAlphaPar1;Pop1_PAlphaPar2;Pop1_PAlphaPar3;"
	ListOfVariables+="Pop1_UseBOmegaParam;Pop1_BOmegaPar1;Pop1_BOmegaPar2;Pop1_BOmegaPar3;"
	ListOfVariables+="Pop1_UseInterference;"
	ListOfVariables+="Pop1_InterfETA;Pop1_InterfPack;"
	ListOfVariables+="Pop1_UseTriangularDist;Pop1_UseGaussSizeDist;Pop1_GaussSDNumBins;Pop1_GaussSDFWHM;"
	For(i=0;i<ItemsInList(ListOfVariables);i+=1)
		NVAR tempV=$("Pop"+num2str(popNumber)+StringFromList(i, ListOfVariables)[4,inf])
		if(cmpstr(num2str(tempV),StringByKey("Pop"+num2str(popNumber)+StringFromList(i, ListOfVariables)[4,inf], OldNote))!=0)
			print "Distribution parameters"
			return 1
		endif
	endfor

	ListOfStrings="Dir1_IntWvName;Dir1_QvecWvName;Dir1_ErrorWvName;Dir1_DataFolderName;"	
	ListOfStrings+="Dir2_IntWvName;Dir2_QvecWvName;Dir2_ErrorWvName;Dir2_DataFolderName;"	
	ListOfStrings+="Dir3_IntWvName;Dir3_QvecWvName;Dir3_ErrorWvName;Dir3_DataFolderName;"	
	ListOfStrings+="Dir4_IntWvName;Dir4_QvecWvName;Dir4_ErrorWvName;Dir4_DataFolderName;"	
	ListOfStrings+="Dir5_IntWvName;Dir5_QvecWvName;Dir5_ErrorWvName;Dir5_DataFolderName;"	
	ListOfStrings+="Dir6_IntWvName;Dir6_QvecWvName;Dir6_ErrorWvName;Dir6_DataFolderName;"	
	For(i=0;i<ItemsInList(ListOfStrings);i+=1)
		SVAR tempS=$(StringFromList(i, ListOfStrings))
		if(cmpstr(tempS,StringByKey(StringFromList(i, ListOfStrings), OldNote))!=0)
			print "Measured data"
			return 1
		endif
	endfor
	print "Not recalculated"
	return 0
end


Function/S ASAS_GenerateNewWaveNoteRecord(dirNumber, popNumber)
	variable dirNumber, popNumber

	setDataFolder root:Packages:AnisoSAS:
	Wave/Z IntPop= $("Dir"+num2str(dirNumber)+"_Pop"+num2str(popNumber)+"_ModelIntensity")
	Wave Qvec=$("root:Packages:AnisoSAS:Dir"+num2str(dirNumber)+"_CutQvector")
	Wave AlphaDist=$("root:Packages:AnisoSAS:Pop"+num2str(popNumber)+"_AlphaDist")
	Wave/T AlphaDistDesc=$("root:Packages:AnisoSAS:Pop"+num2str(popNumber)+"_AlphaDistDesc")
	Wave OmegaDist=$("root:Packages:AnisoSAS:Pop"+num2str(popNumber)+"_OmegaDist")
	Wave/T OmegaDistDesc= $("root:Packages:AnisoSAS:Pop"+num2str(popNumber)+"_OmegaDistDesc")
	string NewNote=""
	string ListOfVariables, ListOfStrings, OldNote
	variable i
	For(i=0;i<numpnts(Qvec);i+=5)
		NewNote=ReplaceStringByKey("Qvec"+num2str(i), NewNote, num2str(Qvec[i]))
	endfor
	For(i=0;i<numpnts(AlphaDist);i+=5)
		NewNote=ReplaceStringByKey("AlphaDist"+num2str(i), NewNote, num2str(AlphaDist[i]))
	endfor
	For(i=0;i<numpnts(OmegaDist);i+=5)
		NewNote=ReplaceStringByKey("OmegaDist"+num2str(i), NewNote, num2str(OmegaDist[i]))
	endfor
	For(i=0;i<numpnts(AlphaDistDesc);i+=5)
		NewNote=ReplaceStringByKey("AlphaDistDesc"+num2str(i), NewNote, AlphaDistDesc[i])
	endfor
	For(i=0;i<numpnts(OmegaDistDesc);i+=5)
		NewNote=ReplaceStringByKey("OmegaDistDesc"+num2str(i), NewNote, OmegaDistDesc[i])
	endfor
	ListOfVariables="Wavelength;UseOfFormula4;IntegrationStepsInAlpha;IntegrationStepsInOmega;Mprecision;"
	For(i=0;i<ItemsInList(ListOfVariables);i+=1)
		NVAR tempV=$(StringFromList(i, ListOfVariables))
		NewNote=ReplaceStringByKey(StringFromList(i, ListOfVariables), NewNote, num2str(tempV))
	endfor
	ListOfVariables="Pop1_Radius;Pop1_DeltaRho;Pop1_Beta;Pop1_VolumeFraction;Pop1_ScattererVolume;Pop1_Nee;Pop1_FWHM;Pop1_SurfaceArea;"
	ListOfVariables+="Pop1_PAlphaSteps;Pop1_BOmegaSteps;"
	ListOfVariables+="Pop1_UsePAlphaParam;Pop1_PAlphaPar1;Pop1_PAlphaPar2;Pop1_PAlphaPar3;Pop1_FitPAlphaPar1;Pop1_FitPAlphaPar2;Pop1_FitPAlphaPar3;"
	ListOfVariables+="Pop1_UseBOmegaParam;Pop1_BOmegaPar1;Pop1_BOmegaPar2;Pop1_BOmegaPar3;Pop1_FitBOmegaPar1;Pop1_FitBOmegaPar2;Pop1_FitBOmegaPar3;"
	ListOfVariables+="Pop1_UseInterference;"
	ListOfVariables+="Pop1_InterfETA;Pop1_InterfPack;"
	ListOfVariables+="Pop1_UseTriangularDist;Pop1_UseGaussSizeDist;Pop1_GaussSDNumBins;Pop1_GaussSDFWHM;"
	For(i=0;i<ItemsInList(ListOfVariables);i+=1)
		NVAR tempV=$("Pop"+num2str(popNumber)+StringFromList(i, ListOfVariables)[4,inf])
		NewNote=ReplaceStringByKey("Pop"+num2str(popNumber)+StringFromList(i, ListOfVariables)[4,inf], NewNote, num2str(tempV))
	endfor

	ListOfStrings="Dir1_IntWvName;Dir1_QvecWvName;Dir1_ErrorWvName;Dir1_DataFolderName;"	
	ListOfStrings+="Dir2_IntWvName;Dir2_QvecWvName;Dir2_ErrorWvName;Dir2_DataFolderName;"	
	ListOfStrings+="Dir3_IntWvName;Dir3_QvecWvName;Dir3_ErrorWvName;Dir3_DataFolderName;"	
	ListOfStrings+="Dir4_IntWvName;Dir4_QvecWvName;Dir4_ErrorWvName;Dir4_DataFolderName;"	
	ListOfStrings+="Dir5_IntWvName;Dir5_QvecWvName;Dir5_ErrorWvName;Dir5_DataFolderName;"	
	ListOfStrings+="Dir6_IntWvName;Dir6_QvecWvName;Dir6_ErrorWvName;Dir6_DataFolderName;"	
	For(i=0;i<ItemsInList(ListOfStrings);i+=1)
		SVAR tempS=$(StringFromList(i, ListOfStrings))
		NewNote=ReplaceStringByKey(StringFromList(i, ListOfStrings), NewNote, tempS)
	endfor
	
	return NewNote
end


Function ASAS_CalcAppendResultsToGraph()

	NVAR NmbDir=root:Packages:AnisoSAS:NumberOfDirections

	DoWindow ASAS_InputGraph
	if(V_Flag)
		RemoveFromGraph/Z/W=ASAS_InputGraph Dir1_ModelIntensity, Dir2_ModelIntensity, Dir3_ModelIntensity, Dir4_ModelIntensity, Dir5_ModelIntensity, Dir6_ModelIntensity
		RemoveFromGraph/Z/W=ASAS_InputGraph Dir1_Pop1_ModelIntensity,Dir1_Pop2_ModelIntensity,Dir1_Pop3_ModelIntensity,Dir1_Pop4_ModelIntensity,Dir1_Pop5_ModelIntensity
		RemoveFromGraph/Z/W=ASAS_InputGraph Dir2_Pop1_ModelIntensity,Dir2_Pop2_ModelIntensity,Dir2_Pop3_ModelIntensity,Dir2_Pop4_ModelIntensity,Dir2_Pop5_ModelIntensity
		RemoveFromGraph/Z/W=ASAS_InputGraph Dir3_Pop1_ModelIntensity,Dir3_Pop2_ModelIntensity,Dir3_Pop3_ModelIntensity,Dir3_Pop4_ModelIntensity,Dir3_Pop5_ModelIntensity
		RemoveFromGraph/Z/W=ASAS_InputGraph Dir4_Pop1_ModelIntensity,Dir4_Pop2_ModelIntensity,Dir4_Pop3_ModelIntensity,Dir4_Pop4_ModelIntensity,Dir4_Pop5_ModelIntensity
		variable i
		string AppndWvName
		ControlInfo/W=ASAS_InputPanel DistTabs
		variable DisplayedTab = V_Value+1
		NVAR DisplayPopulations=root:Packages:AnisoSAS:DisplayPopulations
		NVAR NmbPop=root:Packages:AnisoSAS:NumberOfPopulations
		For (i=1;i<=NmbDir;i+=1)
			AppndWvName="Dir"+num2str(i)+"_ModelIntensity"
			Wave/Z DoIExist=$(AppndWvName)
			if(WaveExists(DoIExist))
				AppendToGraph/W=ASAS_InputGraph $("Dir"+num2str(i)+"_ModelIntensity") vs $("Dir"+num2str(i)+"_ModelQvector")
				ModifyGraph/W=ASAS_InputGraph zColor($AppndWvName)={$("Dir"+num2str(i)+"_CutColor"),0,10,PlanetEarth}
				ModifyGraph/W=ASAS_InputGraph lsize($AppndWvName)=3		
			endif
		endfor
		if(DisplayPopulations && DisplayedTab<=NmbPop)
			For (i=1;i<=NmbDir;i+=1)
				AppndWvName="Dir"+num2str(i)+"_Pop"+num2str(DisplayedTab)+"_ModelIntensity"
				Wave/Z DoIExist=$(AppndWvName)
				if(WaveExists(DoIExist))
					AppendToGraph/W=ASAS_InputGraph $("Dir"+num2str(i)+"_Pop"+num2str(DisplayedTab)+"_ModelIntensity") vs $("Dir"+num2str(i)+"_ModelQvector")
					ModifyGraph/W=ASAS_InputGraph zColor($AppndWvName)={$("Dir"+num2str(i)+"_CutColor"),0,10,PlanetEarth}
					ModifyGraph/W=ASAS_InputGraph lsize($AppndWvName)=2,lStyle($AppndWvName)=4	 	
				endif
			endfor
		endif
	endif
end


Function ASAS_CalcOnePopDir(PopNum,DirNum)
		Variable PopNum,DirNum
		
		//this calculates the intensity in given direction from one population of pores
		ASAS_CalcScatterVolume(PopNum)			//make sure we have the right volume of particles 
		
		Wave IntPop= $("root:Packages:AnisoSAS:Dir"+num2str(DirNum)+"_Pop"+num2str(PopNum)+"_ModelIntensity")
		Wave Qvec=$("root:Packages:AnisoSAS:Dir"+num2str(DirNum)+"_ModelQvector")
		NVAR AlphaQ=$("root:Packages:AnisoSAS:Dir"+num2str(DirNum)+"_AlphaQ")
		NVAR OmegaQ=$("root:Packages:AnisoSAS:Dir"+num2str(DirNum)+"_OmegaQ")
		NVAR UseInterference=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_UseInterference")
		NVAR  ETA=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_InterfETA")
		NVAR  Pack=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_InterfPack")
		//this needs to be checked here... 
		NVAR UseTriangularDist=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_UseTriangularDist")
		NVAR UseGaussSizeDist=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_UseGaussSizeDist")
		if(abs(UseTriangularDist+UseGaussSizeDist-1)>0.01)
			UseTriangularDist=1
			UseGaussSizeDist=0
		endif
		
		IntPop=ASAS_CalcIntOf1Scatterer(Qvec[p], PopNum,AlphaQ, OmegaQ)	//calculate intensity from one scatterer
		IntPop=IntPop*ASAS_CalcNumOfParticles(PopNum)			//multiply by number of scatterers
		IntPop=IntPop*10^(-16)									//Calc from one scatterer is in units of radius, which is A2
		//this converts the result into cm2
		//apply interference if requested
		if (UseInterference)
			//interference		 Int(q, with interference) =Int(q)*(1-8*phi*spherefactor(q,eta))
			//		TempUnifiedIntensity/=(1+pack*IR1A_SphereAmplitude(OriginalQvector,ETA))
			IntPop /= (1+Pack*ASAS_SphereAmplitude(Qvec[p],Eta))
		endif
end
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************


Function ASAS_SphereAmplitude(qval, eta)
		variable qval, eta
		
		return (3*(sin(qval*eta)-qval*eta*cos(qval*eta))/(qval*eta)^3)
end

//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************
//****************************************************************************************************************




Function ASAS_CalcNumOfParticles(PopNum)		//works fine
	variable PopNum
	
	NVAR ScattererVolume=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_ScattererVolume")
	NVAR TotalVolume=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_VolumeFraction")
	
	return 10^24 * TotalVolume/ScattererVolume			//total volume / Scatt. volume converted to 1/cm3 from 1/A3
end


Function ASAS_CalcScatterVolume(PopNum)		//works fine
	variable PopNum
	
	NVAR Radius=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_Radius")
	NVAR Beta=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_Beta")
	NVAR ScattererVolume=$("root:Packages:AnisoSAS:Pop"+num2str(PopNum)+"_ScattererVolume")
	
	ScattererVolume=(4/3)*pi*Beta*Radius^3		//in radius units, i.e., in A	
end


Function ASAS_CalcCreateWaves()
		//here we create waves for intensitites calculated for the model.
		//we need many waves:
		//For each direction and each population
		
	setDataFolder root:Packages:AnisoSAS:
		
	NVAR NmbDir=root:Packages:AnisoSAS:NumberOfDirections
	NVAR NmbPop=root:Packages:AnisoSAS:NumberOfPopulations
	
	variable i, j
	
	For(i=1;i<=NmbDir;i+=1)
		//this will iterate through all the directions we need to evaluate
		Wave Int=$("root:Packages:AnisoSAS:Dir"+num2str(i)+"_CutIntensity")
		Wave Qvec=$("root:Packages:AnisoSAS:Dir"+num2str(i)+"_CutQvector")
			//first create final intensity (summ of all populations) and Qvector for all of them
		Duplicate/O Int, $("Dir"+num2str(i)+"_ModelIntensity")
		Duplicate/O Qvec, $("Dir"+num2str(i)+"_ModelQvector")
			//And now create intensity for all populations
		For (j=1;j<=NmbPop;j+=1)
			Duplicate/O Int, $("Dir"+num2str(i)+"_Pop"+num2str(j)+"_ModelIntensity")
		endfor	
	endfor
end


Function ASAS_AutoupdateIfSelected()

	NVAR autoupdate=root:Packages:AnisoSAS:UpdateAutomatically
	
	if (autoupdate)
		ASAS_CalcAllIntensities()
	endif

end

