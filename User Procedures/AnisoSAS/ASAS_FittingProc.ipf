#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.1		//modified 5 29 2005 to accept 5 populations JIL


Function ASAS_ReverseFitToData()

	setDataFolder root:Packages:AnisoSAS

	variable i
	string tempStr
	Wave BackupFitStartingValues

	Wave/T BackupFitParametersNames
	for(i=0;i<=numpnts(BackupFitStartingValues)-1;i+=1)
		tempStr=BackupFitParametersNames[i]
		NVAR tempVar=$(tempStr)
		tempVar=BackupFitStartingValues[i]
	endfor

end

Function ASAS_FitModelToData()

	setDataFolder root:Packages:AnisoSAS

	//First we need to create one wave of intensity, Qvectors and error
	ASAS_FitCreateDataToFitTo()
	Wave DataToFitIntensity
	Wave DataToFitQvector
	Wave DataToFitError

	//And now we need to create waves with fitting parameters names, starting conditions and limits 
	ASAS_FitCreateParametersWvs()
	Wave FitStartingValues
	// BackupFitStartingValues
	Wave/T FitParametersNames
	// BackupFitParametersNames
	Wave FitParametersLimits
	Wave FitEpsilonValues
	
	//and now we need to call the FuncFit
	FuncFit ASAS_FitTheDataFnct FitStartingValues DataToFitIntensity /X=DataToFitQvector /W=DataToFitError /I=1 /E=FitEpsilonValues /C=FitParametersLimits

	//Now we need to put the results into the appropriate variables

	variable i
	string tempStr
	for(i=0;i<numpnts(FitParametersNames);i+=1)
		tempStr=FitParametersNames[i]
		NVAR tempVar=$(tempStr)
		tempVar=FitStartingValues[i]
	endfor

//	ASAS_CalcAllIntensities()
	ASAS_CalcAppendResultsToGraph()

end


Function ASAS_FitTheDataFnct(ParameterWv,FitOutputWv,FitXwv) : FitFunc
	Wave ParameterWv,FitOutputWv,FitXwv
	
	setDataFolder root:Packages:AnisoSAS
	//first we need to recover the parameters to their global places
	variable i
	string tempStr
	Wave/T FitParametersNames
	for(i=0;i<=numpnts(ParameterWv)-1;i+=1)
		tempStr=FitParametersNames[i]
		NVAR tempVar=$(tempStr)
		tempVar=ParameterWv[i]
	endfor
	//and now we need to calculate the intensities for various directions. assume we have the Q vectors and waves in which we can just calculate it

	ASAS_CorrectAnisotropiesForFit()		//correct the alpha nad omega anisotropies
	
	ASAS_CalcAllIntensities()				//calculate the intensities

	Make/O/D/N=0 TempToFitIntensity
	variable oldlength, newlength
	
	NVAR NmbDir=root:Packages:AnisoSAS:NumberOfDirections
	For (i=1;i<=NmbDir;i+=1)
		Wave Int=$("Dir"+num2str(i)+"_ModelIntensity")
		newlength=numpnts(TempToFitIntensity)+numpnts(Int)
		oldlength=numpnts(TempToFitIntensity)
		redimension/N=(newlength) TempToFitIntensity
		TempToFitIntensity[oldlength, ]=Int[p-oldlength]
	endfor


	FitOutputWv=TempToFitIntensity
End


Function ASAS_CorrectAnisotropiesForFit()

	setDataFolder root:Packages:AnisoSAS

	NVAR NumPop=root:Packages:AnisoSAS:NumberOfPopulations
	variable i
	for(i=1;i<=NumPop;i+=1)
		NVAR UseAlphaParam=$("root:Packages:AnisoSAS:Pop"+num2str(i)+"_UsePAlphaParam")
		if (UseAlphaParam)
			ASAS_RecalculateAlpha(i)
			ASAS_NormalizeAlphaProb(i)
		endif
		NVAR UseOmegaParam=$("root:Packages:AnisoSAS:Pop"+num2str(i)+"_UseBOmegaParam")
		if (UseOmegaParam)
			ASAS_RecalculateOmega(i)
			ASAS_NormalizeOmegaProb(i)
		endif
		
	endfor

end

Function ASAS_FitCreateParametersWvs()
	//here we need to create waves with paramters names, starting conditions and limits

	SetDataFolder root:Packages:AnisoSAS
	NVAR NumPop=root:Packages:AnisoSAS:NumberOfPopulations
	variable i,j
	string NamesToTest="VolumeFraction;Radius;PAlphaPar1;PAlphaPar2;PAlphaPar3;BOmegaPar1;BOmegaPar2;BOmegaPar3;InterfETA;InterfPack;"
	string LocName
	
	make/O/N=0/D FitStartingValues, FitEpsilonValues
	make/O/N=0/T FitParametersNames, FitParametersLimits
	For(i=1;i<=NumPop;i+=1)
		
		NVAR UsePalpha=root:Packages:AnisoSAS:Pop1_UsePAlphaParam
		NVAR UseBomega=root:Packages:AnisoSAS:Pop1_UseBOmegaParam
		For(j=0;j<(ItemsInList(NamesToTest));j+=1)
						
			NVAR Value=$("root:Packages:AnisoSAS:Pop"+num2str(i)+"_"+StringFromList(j,NamesToTest))
			NVAR FitValue=$("root:Packages:AnisoSAS:Pop"+num2str(i)+"_Fit"+StringFromList(j,NamesToTest))
			NVAR ValueMin=$("root:Packages:AnisoSAS:Pop"+num2str(i)+"_"+StringFromList(j,NamesToTest)+"Min")
			NVAR ValueMax=$("root:Packages:AnisoSAS:Pop"+num2str(i)+"_"+StringFromList(j,NamesToTest)+"Max")
			if (FitValue)
				if (stringmatch(StringFromList(j,NamesToTest),"*PAlpha*"))
					if(UsePAlpha)
						redimension/N=(numpnts(FitStartingValues)+1) FitStartingValues, FitParametersNames, FitEpsilonValues
						redimension/N=(numpnts(FitParametersLimits)+2) FitParametersLimits
						FitStartingValues[numpnts(FitStartingValues)-1]=Value
						if (stringmatch(StringFromList(j,NamesToTest),"*PAlphaPar1"))
							FitEpsilonValues[numpnts(FitStartingValues)-1]=10
						elseif(stringmatch(StringFromList(j,NamesToTest),"*PAlphaPar2"))
							FitEpsilonValues[numpnts(FitStartingValues)-1]=1
						else
							FitEpsilonValues[numpnts(FitStartingValues)-1]=0.2
						endif
						FitParametersNames[numpnts(FitStartingValues)-1]="Pop"+num2str(i)+"_"+StringFromList(j,NamesToTest)
						FitParametersLimits[numpnts(FitParametersLimits)-2]="K"+num2str(numpnts(FitStartingValues)-1)+"<"+num2str(ValueMax)
						FitParametersLimits[numpnts(FitParametersLimits)-1]="K"+num2str(numpnts(FitStartingValues)-1)+">"+num2str(ValueMin)
					endif
				elseif (stringmatch(StringFromList(j,NamesToTest),"*BOmega*"))
					if(UseBOmega)
						redimension/N=(numpnts(FitStartingValues)+1) FitStartingValues, FitParametersNames, FitEpsilonValues
						redimension/N=(numpnts(FitParametersLimits)+2) FitParametersLimits
						FitStartingValues[numpnts(FitStartingValues)-1]=Value
						if (stringmatch(StringFromList(j,NamesToTest),"*BOmegaPar1"))
							FitEpsilonValues[numpnts(FitStartingValues)-1]=10
						elseif(stringmatch(StringFromList(j,NamesToTest),"*BOmegaPar2"))
							FitEpsilonValues[numpnts(FitStartingValues)-1]=1
						else
							FitEpsilonValues[numpnts(FitStartingValues)-1]=0.2
						endif
						FitParametersNames[numpnts(FitStartingValues)-1]="Pop"+num2str(i)+"_"+StringFromList(j,NamesToTest)
						FitParametersLimits[numpnts(FitParametersLimits)-2]="K"+num2str(numpnts(FitStartingValues)-1)+"<"+num2str(ValueMax)
						FitParametersLimits[numpnts(FitParametersLimits)-1]="K"+num2str(numpnts(FitStartingValues)-1)+">"+num2str(ValueMin)
					endif				
				elseif (stringmatch(StringFromList(j,NamesToTest),"*Interf*"))
					NVAR FitInterference=$("root:Packages:AnisoSAS:Pop"+num2str(i)+"_UseInterference")
					if (FitInterference)
						redimension/N=(numpnts(FitStartingValues)+1) FitStartingValues, FitParametersNames, FitEpsilonValues
						redimension/N=(numpnts(FitParametersLimits)+2) FitParametersLimits
						FitStartingValues[numpnts(FitStartingValues)-1]=Value
						FitEpsilonValues[numpnts(FitStartingValues)-1]=Value/10 
						FitParametersNames[numpnts(FitStartingValues)-1]="Pop"+num2str(i)+"_"+StringFromList(j,NamesToTest)
						FitParametersLimits[numpnts(FitParametersLimits)-2]="K"+num2str(numpnts(FitStartingValues)-1)+"<"+num2str(ValueMax)
						FitParametersLimits[numpnts(FitParametersLimits)-1]="K"+num2str(numpnts(FitStartingValues)-1)+">"+num2str(ValueMin)
					endif
				else
					redimension/N=(numpnts(FitStartingValues)+1) FitStartingValues, FitParametersNames, FitEpsilonValues
					redimension/N=(numpnts(FitParametersLimits)+2) FitParametersLimits
					FitStartingValues[numpnts(FitStartingValues)-1]=Value
					FitEpsilonValues[numpnts(FitStartingValues)-1]=Value/20 
					FitParametersNames[numpnts(FitStartingValues)-1]="Pop"+num2str(i)+"_"+StringFromList(j,NamesToTest)
					FitParametersLimits[numpnts(FitParametersLimits)-2]="K"+num2str(numpnts(FitStartingValues)-1)+"<"+num2str(ValueMax)
					FitParametersLimits[numpnts(FitParametersLimits)-1]="K"+num2str(numpnts(FitStartingValues)-1)+">"+num2str(ValueMin)
				endif
			endif
		endfor
	endfor

	//and now create backup values, so we know where to return
	Duplicate/O FitStartingValues, BackupFitStartingValues
	Duplicate/O FitParametersNames, BackupFitParametersNames

end

Function ASAS_FitCreateDataToFitTo()

	//this function merges the Intensity vs Q data into one long wave attached together
	setDataFolder root:Packages:AnisoSAS
	
	ASAS_CreateWvsForFitting()
	
	SetDataFolder root:Packages:AnisoSAS
	NVAR NumDir=root:Packages:AnisoSAS:NumberOfDirections
	variable i, oldlength, newlength
	Make/O/D/N=0 DataToFitIntensity, DataToFitQvector, DataToFitError
	For (i=1;i<=NumDir;i+=1)
		Wave TempInt= $("Dir"+num2str(i)+"_CutIntensity")
		Wave TempQ=$("Dir"+num2str(i)+"_CutQvector")
		Wave TempErr= $("Dir"+num2str(i)+"_CutError")
		newlength=numpnts(DataToFitIntensity)+numpnts(TempInt)
		oldlength=numpnts(DataToFitIntensity)
		redimension/N=(newlength) DataToFitIntensity, DataToFitQvector, DataToFitError
		DataToFitIntensity[oldlength, ]=TempInt[p-oldlength]
		DataToFitQvector[oldlength, ]=TempQ[p-oldlength]
		DataToFitError[oldlength, ]=TempErr[p-oldlength]
	endfor
end


Function ASAS_CalcChiSquare()
	//here we calculate Chi squared for data in log-log plot and print them in the history area
	
	setDataFolder root:Packages:AnisoSAS
	
	NVAR NumberOfDirections=root:Packages:AnisoSAS:NumberOfDirections
	variable i, chisquared, ChisqTot, NumPntsTot
	ChisqTot=0
	NumPntsTot=0
	print "Results for Chisquare calculations  "+date()+"  "+time()
	
	Wave/Z LastFitIntensity=root:Packages:AnisoSAS:TempToFitIntensity
	Wave/Z LastInputDataInt=root:Packages:AnisoSAS:DataToFitIntensity
	Wave/Z LastInputDataErr=root:Packages:AnisoSAS:DataToFitError
	if (WaveExists(LastFitIntensity)&&WaveExists(LastInputDataInt)&&WaveExists(LastInputDataErr))
		if((numpnts(LastFitIntensity)==numpnts(LastInputDataInt))&&(numpnts(LastInputDataErr)==numpnts(LastInputDataInt)))
			duplicate/O LastFitIntensity, TempChiSquareWave
			Wave TempChiSquareWave
			TempChiSquareWave=(LastFitIntensity-LastInputDataInt)^2 / (LastInputDataErr)^2
			chisquared=sum(TempChiSquareWave,-inf,inf) / numpnts(TempChiSquareWave)
			print "Last Fit results for these data, \t ChiSquared =  " + num2str(chisquared) 
		endif
	endif
	
	For(i=1;i<=NumberOfDirections;i+=1)
		SVAR folderName=$("Dir"+num2str(i)+"_DataFolderName")
		Wave DataIntensity=$("Dir"+num2str(i)+"_CutIntensity")
		Wave DataError=$("Dir"+num2str(i)+"_CutError")
		Wave FitIntensity=$("Dir"+num2str(i)+"_ModelIntensity")
		duplicate/O DataIntensity, TempChiSquareWave
		Wave TempChiSquareWave
		TempChiSquareWave=(DataIntensity-FitIntensity)^2 / (DataError)^2
		ChisqTot+=sum(TempChiSquareWave,-inf,inf)
		NumPntsTot+=numpnts(TempChiSquareWave)
		chisquared=sum(TempChiSquareWave,-inf,inf) / numpnts(TempChiSquareWave)
		print "Dir"+num2str(i)+ ", "+folderName+", \t the ChiSquared =  " + num2str(chisquared) 
	endfor
	
	print "Overall Chisquared for this model = "+num2str(ChisqTot/NumPntsTot)
	KillWaves/Z TempChiSquareWave

end