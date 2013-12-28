#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.01

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.01 added license for ANL


//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from www.uni.aps.anl.gov/~ilavsky
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky, March 2002

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov
//main functions for modeling with user input of distributions...


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_GraphModelData()

		IR1U_CheckForCorrectDataState()			//check, that we have data copied locally and so we can calculate stuff
//		IR1U_CreateDistributionWaves()			//create distributon waves...
		//now we will copy original data into local waves
//		IR1U_CopyOrgDataIntoLocWvs()			//next we will copy the data into them
		//now we will modify them with our modifying parameters
		IR1U_ModifyDataWithParams()				//next we will modify the distribution waves with the 2 parameters 
		//lets update the mode median and mean
		IR1U_UpdateModeMedianMean()				//modified for 5
		//now lets calculate the whole distribution together
		IR1U_CalcSumOfDistribution()		//works for 5
		//create graphs, if needed...
		IR1_CreateModelGraphs()			//modified for 5
		//and now we need to calculate the model Intensity
		IR1_CalculateModelIntensity()		//modified for 5
		//now calculate the normalized error wave
		IR1_CalculateNormalizedError("fit")
		//append waves to the two top graphs with measured data
		IR1_AppendModelToMeasuredData()	//modified for 5	
		//pull up Interference panel, if exists
		DoWindow IR1S_InterferencePanel
			if (V_Flag)
			DoWindow/F IR1S_InterferencePanel
		endif
	
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_CheckForCorrectDataState()
//here we check, if our data are correctly set (cdopied locally), so we can manipulate them...
		
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling
	
		NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
		variable IsOK=1
		variable i

		For (i=1;i<=NumberOfDistributions;i+=1)
			Wave/Z DistVolumeDistUnchanged=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"VolumeDistUnchanged")
			Wave/Z DistNumberDistUnchanged=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"NumberDistUnchanged")
			Wave/Z DistdiametersUnchanged=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"diametersUnchanged")
			
			if (!(WaveExists(DistVolumeDistUnchanged)&&WaveExists(DistNumberDistUnchanged)&&WaveExists(DistdiametersUnchanged)))
				IsOK=0
			endif
		endfor
		
		if (!IsOK)
			abort
		endif
	setDataFolder oldDF

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_CalcSumOfDistribution()

	string OldDf
	OldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling
	
	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions

	variable i, tempLength
	Make/O/N=0/D Distdiameters
	
	For(i=1;i<=NumberOfDistributions;i+=1)
		WAVE DistTempdiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"diameters")
		tempLength=numpnts(Distdiameters)
		redimension /N=(tempLength+numpnts(DistTempdiameters)) Distdiameters
		Distdiameters[tempLength,numpnts(Distdiameters)-1]=DistTempdiameters[p-tempLength]
	endfor

	Sort Distdiameters, Distdiameters
	//check if some of the point are the same, that causes troubles later. remove the points which are less than 1% off
	variable imax=numpnts(Distdiameters)
	For(i=1;i<imax;i+=1)
		if((Distdiameters[i]/Distdiameters[i-1])<1.01)		//is 1% enough?
			DeletePoints i,1, Distdiameters
			imax=numpnts(Distdiameters)
		endif
	endfor
	Duplicate/O Distdiameters, TempVolDist, TempNumDist, TotalVolumeDist, TotalNumberDist
	Redimension/D  TempVolDist, TempNumDist, TotalVolumeDist, TotalNumberDist
	TotalVolumeDist=0
	TotalNumberDist=0
	
	variable ii
	string command1, command2
	
	For(i=1;i<=NumberOfDistributions;i+=1)	
		TempVolDist=0
		TempNumDist=0
		Wave DistVolumeDist=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"VolumeDist")
		Wave DistNumberDist=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"NumberDist")
		Wave DistdiametersLoc=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"diameters")
		//OK, we need to add one more point at each end of the above waves, diameters are by one step further and volume or numbers are 0
		Make/D/O/N=(numpnts(DistdiametersLoc)+2) DistdiametersLocExt, DistVolumeDistExt, DistNumberDistExt 
		DistVolumeDistExt[0]=0
		DistNumberDistExt[0]=0
		DistVolumeDistExt[1,]=DistVolumeDist[p-1]
		DistNumberDistExt[1,]=DistNumberDist[p-1]
		DistVolumeDistExt[numpnts(DistVolumeDistExt)-1]=0
		DistNumberDistExt[numpnts(DistNumberDistExt)-1]=0
		
		DistdiametersLocExt[0]=DistdiametersLoc[0]-(DistdiametersLoc[1]-DistdiametersLoc[0])
		DistdiametersLocExt[1, ]=DistdiametersLoc[p-1]
		DistdiametersLocExt[numpnts(DistdiametersLocExt)-1]=DistdiametersLoc[numpnts(DistdiametersLoc)-1]+(DistdiametersLoc[numpnts(DistdiametersLoc)-1]-DistdiametersLoc[numpnts(DistdiametersLoc)-2])
		
		TempVolDist=interp(Distdiameters, DistdiametersLocExt, DistVolumeDistExt )	
		TempNumDist=interp(Distdiameters, DistdiametersLocExt, DistNumberDistExt )
		
		//And now ltes kill these extended waves
		KillWaves/Z DistdiametersLocExt, DistVolumeDistExt, DistNumberDistExt
		//Interpolate [/T=t/N=n/A=a/J=j/F=f/S=s/E=e/I[=i]/Z=z/B=b/Y=yDestName /X=xDestName ] yDataName [/X=xDataName ]
		//command1="Interpolate/T=2 /I=3/Y=TempVolDist /X=Distdiameters Dist"+num2str(i)+"VolumeDist /X=Dist"+num2str(i)+"diameters"
		//command2="Interpolate/t=2 /I=3/Y=TempNumDist /X=Distdiameters Dist"+num2str(i)+"NumberDist /X=Dist"+num2str(i)+"diameters"
		//Execute(command1)
		//Execute(command2)
		
		
		For (ii=0;ii<Numpnts(TempVolDist);ii+=1)
			//cleanup artefacts in form of negative numbers
			if ((TempVolDist[ii]<0) || (TempNumDist[ii]<0))
				TempNumDist[ii]=0
				TempVolDist[ii]=0
			endif
		endfor

		TotalVolumeDist+=TempVolDist
		TotalNumberDist+=TempNumDist

		Duplicate /O TempVolDist, $("TotalVolumeDist"+num2str(i))
	endfor
	KillWaves/Z TempVolDist, TempNumDist	
	//fix the procedure
	setDataFolder OldDf	
end



//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_ModifyDataWithParams()
	
		NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
		variable i
		//here we copy the org waves to local waves
		For(i=1;i<=NumberOfDistributions;i+=1)
			IR1U_ModifyDataWithParamOne(i)
		endfor
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_ModifyDataWithParamOne(DistNum)
		variable DistNum

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling
		
		Wave/Z Distdiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"diameters")
		Wave/Z DistdiametersUnchanged=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"diametersUnchanged")
		Wave/Z DistNumberDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberDist")
		Wave/Z DistVolumeDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolumeDist")
		Wave/Z DistNumberDistUnchanged=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberDistUnchanged")
		Wave/Z DistVolumeDistUnchanged=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolumeDistUnchanged")

		NVAR DistVolFraction=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolFraction")
		NVAR DistVolFractUserInput=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolFractUserInput")
		NVAR DistDiamMultiplier=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"DiamMultiplier")
		NVAR DistDiamAddition=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"DiamAddition")		

		SVAR DistShapeModel=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ShapeModel")
		NVAR DistScatShapeParam1=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam1")
		NVAR DistScatShapeParam2=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam2")
		NVAR DistScatShapeParam3=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam3")
		SVAR UserVolumeFnctName=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserVolumeFnct")
		NVAR UserPar1=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam1")
		NVAR UserPar2=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam2")
		NVAR UserPar3=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam3")
		NVAR UserPar4=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam4")
		NVAR UserPar5=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam5")

		
		if ((!WaveExists(Distdiameters))||(!WaveExists(DistdiametersUnchanged))||(!WaveExists(DistNumberDist))||(!WaveExists(DistVolumeDist))||(!WaveExists(DistNumberDistUnchanged))||(!WaveExists(DistVolumeDistUnchanged)))
			abort
		endif
		//firs let's move the diameters in place...
		Distdiameters=DistDiamMultiplier*(DistdiametersUnchanged+DistDiamAddition)
		//now let's change the volume distribution... To do that, we first find original volume after shift of diameters
		variable tempVol=	areaXY(Distdiameters,DistVolumeDistUnchanged,-inf,inf)
		//next we need to scale the volume distribution into new porosity volume...
		DistVolumeDist=DistVolumeDistUnchanged*(DistVolFraction/tempVol)	
		
		//and last we need to calculate the number distribution of this beast...
		IR1_ConvertVolToNumDist(DistVolumeDist,DistNumberDist,Distdiameters,DistShapeModel,DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)

	setDataFolder oldDF

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_CopyOrgDataIntoLocWvs()
	
		NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
		variable i
		//here we copy the org waves to local waves
		For(i=1;i<=NumberOfDistributions;i+=1)
			IR1U_CpyOrgDtaLocOne(i)
		endfor
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_CpyOrgDtaLocOne(DistNum)
		variable DistNum

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling
		
		NVAR DistInputNumberDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"InputNumberDist")
		SVAR DistShapeModel=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ShapeModel")
		NVAR DistScatShapeParam1=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam1")
		NVAR DistScatShapeParam2=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam2")
		NVAR DistScatShapeParam3=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"ScatShapeParam3")
		Wave Distdiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"diameters")
		Wave DistdiametersUnchanged=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"diametersUnchanged")
		Wave DistNumberDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberDist")
		Wave DistVolumeDist=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolumeDist")
		Wave DistNumberDistUnchanged=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"NumberDistUnchanged")
		Wave DistVolumeDistUnchanged=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolumeDistUnchanged")
		Wave OrigDistdiameters=$("root:Packages:SAS_Modeling:OrigDist"+num2str(DistNum)+"diameters")
		Wave OrigDistNumberDist=$("root:Packages:SAS_Modeling:OrigDist"+num2str(DistNum)+"NumberDist")
		Wave OrigDistVolumeDist=$("root:Packages:SAS_Modeling:OrigDist"+num2str(DistNum)+"VolumeDist")
		NVAR DistVolFraction=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolFraction")
		NVAR DistVolFractUserInput=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"VolFractUserInput")
		NVAR DistInputRadii=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"InputRadii")
		SVAR UserVolumeFnctName=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserVolumeFnct")
		NVAR UserPar1=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam1")
		NVAR UserPar2=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam2")
		NVAR UserPar3=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam3")
		NVAR UserPar4=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam4")
		NVAR UserPar5=$("root:Packages:SAS_Modeling:Dist"+num2str(DistNum)+"UserFFParam5")


		if (DistInputRadii)	//=1 if user inputs radii
			DistdiametersUnchanged=OrigDistdiameters*2
			DistNumberDist/=2
			DistVolumeDist/=2
		else
			DistdiametersUnchanged=OrigDistdiameters
		endif	
	
//		Distdiameters=DistdiametersUnchanged
		
		if (DistInputNumberDist)	//using number distributions
			DistNumberDistUnchanged=OrigDistNumberDist
			IR1_ConvertNumToVolDist(DistVolumeDistUnchanged,DistNumberDistUnchanged,Distdiameters,DistShapeModel,DistScatShapeParam1,DistScatShapeParam2, DistScatShapeParam3,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
		else
			DistVolumeDistUnchanged=OrigDistVolumeDist
			IR1_ConvertVolToNumDist(DistVolumeDistUnchanged,DistNumberDistUnchanged,Distdiameters,DistShapeModel,DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
		endif
		
	//	DistNumberDist=DistNumberDistUnchanged
//		DistVolumeDist=DistVolumeDistUnchanged
		//this is quite important line...
		DistVolFraction=areaXY(DistdiametersUnchanged,DistVolumeDistUnchanged,-inf,inf)
		DistVolFractUserInput=DistVolFraction
		//here we calculate users volume fraction and stuff it where it belongs...
		IR1U_ModifyDataWithParamOne(DistNum)

	setDataFolder oldDF

end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_AutoUpdateIfSelected()
	
	NVAR UpdateAutomatically=root:Packages:SAS_Modeling:UpdateAutomatically
	if (UpdateAutomatically)
		IR1U_GraphModelData()
	endif
end

//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_CopyUserWavesToOriginal()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:SAS_Modeling
	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
	variable i
	
	For(i=1;i<=5;i+=1)
	//let's kill the origirnal waves, if they exist...
		Wave/Z ProbabNumb=$("OrigDist"+num2str(i)+"NumberDist")
		Wave/Z ProbabVol=$("OrigDist"+num2str(i)+"VolumeDist")
		Wave/Z DiamWv=$("OrigDist"+num2str(i)+"Diameters")
		KillWaves/Z ProbabNumb, ProbabVol,DiamWv
	endfor
	
	For(i=1;i<=NumberOfDistributions;i+=1)
		SVAR FldrNm=$"root:Packages:SAS_Modeling:Dist"+num2str(i)+"FolderName"
		SVAR DiamNm=$"root:Packages:SAS_Modeling:Dist"+num2str(i)+"DiameterWvNm"
		SVAR ProbabNm=$"root:Packages:SAS_Modeling:Dist"+num2str(i)+"ProbabilityWvNm"
		SVAR Shape=$"root:Packages:SAS_Modeling:Dist"+num2str(i)+"ShapeModel"
		NVAR UseNumberDist=$"root:Packages:SAS_Modeling:Dist"+num2str(i)+"InputNumberDist"
		NVAR DistScatShapeParam1=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ScatShapeParam1")
		NVAR DistScatShapeParam2=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ScatShapeParam2")
		NVAR DistScatShapeParam3= $("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ScatShapeParam3")
		SVAR UserVolumeFnctName=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"UserVolumeFnct")
		NVAR UserPar1=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"UserFFParam1")
		NVAR UserPar2=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"UserFFParam2")
		NVAR UserPar3=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"UserFFParam3")
		NVAR UserPar4=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"UserFFParam4")
		NVAR UserPar5=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"UserFFParam5")
		
		if (strlen(DiamNm)>0 && strlen(ProbabNm)>0 && strlen(FldrNm)>0)
			Wave DiamWv=$(FldrNm+DiamNm)
			Wave ProbabWv=$(FldrNm+ProbabNm)
			
			Duplicate/O DiamWv, $("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"Diameters")
			Redimension/D $("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"Diameters")

			Duplicate/O DiamWv, AveVolumeWave
			IR1T_CreateAveVolumeWave(AveVolumeWave,DiamWv,Shape,DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,0,0,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)

//			if (UseNumberDist)		//1 if input is number distribution
//				Duplicate/O ProbabWv, $("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"NumberDist")
//				Redimension/D $("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"NumberDist")
//					//and calculate the other 
//				Duplicate/O ProbabWv, $("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"VolumeDist")
//				Wave ProbabWvVol=$("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"VolumeDist")
//				Redimension/D ProbabWvVol
//				if ((cmpstr(Shape,"spheroid")==0)||(cmpstr(Shape,"coreshell")==0) || cmpstr(Shape,"Integrated_Spheroid")==0)
//					ProbabWvVol=ProbabWv*(4/3)*pi*(DiamWv/2)^3
//				endif
//				if ((cmpstr(Shape,"spheroid")==0)|| cmpstr(Shape,"Algebraic_Globules")==0 || cmpstr(Shape,"Algebraic_Disks")==0)
//					ProbabWvVol=ProbabWv*(4/3)*pi*(DiamWv/2)^3*DistScatShapeParam1
//				endif
//				if ((cmpstr(Shape,"cylinder")==0))
//					ProbabWvVol=ProbabWv*pi*(DiamWv/2)^2*DistScatShapeParam1
//				endif
//			else
//				Duplicate/O ProbabWv, $("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"VolumeDist")
//				Redimension/D $("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"VolumeDist")
//				//and calculate the other
//				Duplicate/O ProbabWv, $("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"NumberDist")
//				Wave ProbabWvNum=$("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"NumberDist")
//				Redimension/D ProbabWvNum
//				if ((cmpstr(Shape,"spheroid")==0)||(cmpstr(Shape,"coreshell")==0) || cmpstr(Shape,"Integrated_Spheroid")==0)
//					ProbabWvNum=ProbabWv/((4/3)*pi*(DiamWv/2)^3)
//				endif
//				if ((cmpstr(Shape,"spheroid")==0)|| cmpstr(Shape,"Algebraic_Globules")==0 || cmpstr(Shape,"Algebraic_Disks")==0)
//					ProbabWvNum=ProbabWv/((4/3)*pi*(DiamWv/2)^3*DistScatShapeParam1)
//				endif
//				if ((cmpstr(Shape,"cylinder")==0))
//					ProbabWvNum=ProbabWv/(pi*(DiamWv/2)^2*DistScatShapeParam1)
//				endif
//			endif
			if (UseNumberDist)	//using number distributions
				Duplicate/O ProbabWv, $("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"NumberDist")
				Redimension/D $("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"NumberDist")
					//and calculate the other 
				Duplicate/O ProbabWv, $("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"VolumeDist")
				Wave ProbabWvVol=$("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"VolumeDist")
				Redimension/D ProbabWvVol
				ProbabWvVol=ProbabWv*AveVolumeWave
			else
				Duplicate/O ProbabWv, $("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"VolumeDist")
				Redimension/D $("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"VolumeDist")
				//and calculate the other
				Duplicate/O ProbabWv, $("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"NumberDist")
				Wave ProbabWvNum=$("root:Packages:SAS_Modeling:OrigDist"+num2str(i)+"NumberDist")
				Redimension/D ProbabWvNum
				ProbabWvNum=ProbabWv/AveVolumeWave
			endif
		else
			abort
		endif
	endFor
		IR1U_CreateDistributionWaves()			//create distributon waves...
		//now we will copy original data into local waves
		IR1U_CopyOrgDataIntoLocWvs()			//next we will copy the data into them
	setDataFolder oldDF

end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_CreateDistributionWaves()
	//here we create waves for distributions

	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SAS_Modeling

	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
	//Ok,  lets first kill all waves which may not be needed...
	KillWaves/Z Dist1diameters, Dist1NumberDist, Dist1VolumeDist
	KillWaves/Z Dist2diameters, Dist2NumberDist, Dist2VolumeDist
	KillWaves/Z Dist3diameters, Dist3NumberDist, Dist3VolumeDist
	KillWaves/Z Dist4diameters, Dist4NumberDist, Dist4VolumeDist
	KillWaves/Z Dist5diameters, Dist5NumberDist, Dist5VolumeDist
	
	if (NumberOfDistributions>0)
		Wave OrigDist1Diameters 
		variable Dist1NumberOfPoints=numpnts(OrigDist1Diameters)
		Make/D/O/N=(Dist1NumberOfPoints) Dist1diameters,Dist1diametersUnchanged, Dist1NumberDist, Dist1VolumeDist,Dist1NumberDistUnchanged, Dist1VolumeDistUnchanged
	endif
	if (NumberOfDistributions>1)
		Wave OrigDist2Diameters 
		variable Dist2NumberOfPoints=numpnts(OrigDist2Diameters)
		Make/D/O/N=(Dist2NumberOfPoints) Dist2diameters,Dist2diametersUnchanged, Dist2NumberDist, Dist2VolumeDist,Dist2NumberDistUnchanged, Dist2VolumeDistUnchanged
	endif
	if (NumberOfDistributions>2)
		Wave OrigDist3Diameters 
		variable Dist3NumberOfPoints=numpnts(OrigDist3Diameters)
		Make/D/O/N=(Dist3NumberOfPoints) Dist3diameters,Dist3diametersUnchanged, Dist3NumberDist, Dist3VolumeDist,Dist3NumberDistUnchanged, Dist3VolumeDistUnchanged
	endif
	if (NumberOfDistributions>3)
		Wave OrigDist4Diameters 
		variable Dist4NumberOfPoints=numpnts(OrigDist4Diameters)
		Make/D/O/N=(Dist4NumberOfPoints) Dist4diameters,Dist4diametersUnchanged, Dist4NumberDist, Dist4VolumeDist,Dist4NumberDistUnchanged, Dist4VolumeDistUnchanged
	endif
	if (NumberOfDistributions>4)
		Wave OrigDist5Diameters 
		variable Dist5NumberOfPoints=numpnts(OrigDist5Diameters)
		Make/D/O/N=(Dist5NumberOfPoints) Dist5diameters,Dist5diametersUnchanged, Dist5NumberDist, Dist5VolumeDist,Dist5NumberDistUnchanged, Dist5VolumeDistUnchanged
	endif
	setDataFolder OldDf
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_UpdateModeMedianMean()

	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
	
	variable i
	For (i=1;i<=NumberOfDistributions;i+=1)
		IR1U_UpdtSeparateMMM(i)
	endfor
end


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


Function IR1U_UpdtSeparateMMM(distNum)
	Variable distNum

	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:SAS_Modeling

	NVAR DistMean=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Mean")
	NVAR DistMedian=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Median")
	NVAR DistMode=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"Mode")
	NVAR DistFWHM=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"FWHM")
	NVAR DistInputNumberDist=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"InputNumberDist")

	Wave Distdiameters=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"diameters")
	Wave DistVolumeDist=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"VolumeDist")
	Wave DistNumberDist=$("root:Packages:SAS_Modeling:Dist"+num2str(distNum)+"NumberDist")
	
	if (DistInputNumberDist)		//use number distribution...
		Duplicate/O DistNumberDist, Temp_Probability, Another_temp, Temp_Cumulative
		Redimension/D  Temp_Probability, Another_temp, Temp_Cumulative
		Temp_Cumulative=areaXY(Distdiameters, Temp_Probability, Distdiameters[0], Distdiameters[p] )
	else							//use volume distribution
		Duplicate/O DistVolumeDist, Temp_Probability, Another_temp, Temp_Cumulative
		Redimension/D  Temp_Probability, Another_temp, Temp_Cumulative
		Temp_Cumulative=areaXY(Distdiameters, Temp_Probability, Distdiameters[0], Distdiameters[p] )
	endif	

	
		Another_temp=Distdiameters*Temp_Probability
		DistMean=areaXY(Distdiameters, Another_temp,0,inf)	/ areaXY(Distdiameters, Temp_Probability,0,inf)				//Sum P(D)*D*deltaD/P(D)*deltaD
		DistMedian=Distdiameters[BinarySearchInterp(Temp_Cumulative, 0.5*Temp_Cumulative[numpnts(Temp_Cumulative)-1] )]		//R for which cumulative probability=0.5
		FindPeak/P/Q Temp_Probability
		DistMode=Distdiameters[V_PeakLoc]								//location of maximum on the P(R)
		
		DistFWHM=IR1_FindFWHM(Temp_Probability,Distdiameters)				//Ok, this is monkey approach
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


Function IR1U_RecordResults(CalledFromWere)
	string CalledFromWere	//before or after - that means fit...

	string OldDF=GetDataFolder(1)
	setdataFolder root:Packages:SAS_Modeling

	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions

	NVAR SASBackground=root:Packages:SAS_Modeling:SASBackground
	NVAR FitSASBackground=root:Packages:SAS_Modeling:FitSASBackground
//dist 1 part	
	NVAR Dist1VolFraction=root:Packages:SAS_Modeling:Dist1VolFraction
	NVAR Dist1VolHighLimit=root:Packages:SAS_Modeling:Dist1VolHighLimit
	NVAR Dist1VolLowLimit=root:Packages:SAS_Modeling:Dist1VolLowLimit
	NVAR Dist1DiamAddition=root:Packages:SAS_Modeling:Dist1DiamAddition
	NVAR Dist1DAHighLimit=root:Packages:SAS_Modeling:Dist1DAHighLimit
	NVAR Dist1DALowLimit=root:Packages:SAS_Modeling:Dist1DALowLimit
	NVAR Dist1DiamMultiplier=root:Packages:SAS_Modeling:Dist1DiamMultiplier
	NVAR Dist1DMHighLimit=root:Packages:SAS_Modeling:Dist1DMHighLimit
	NVAR Dist1DMLowLimit=root:Packages:SAS_Modeling:Dist1DMLowLimit
	
	NVAR Dist1FitShape=root:Packages:SAS_Modeling:Dist1FitShape
	NVAR Dist1FitLocation=root:Packages:SAS_Modeling:Dist1FitLocation
	NVAR Dist1FitScale=root:Packages:SAS_Modeling:Dist1FitScale
	NVAR Dist1FitVol=root:Packages:SAS_Modeling:Dist1FitVol

//dist 2 part
	NVAR Dist2VolFraction=root:Packages:SAS_Modeling:Dist2VolFraction
	NVAR Dist2VolHighLimit=root:Packages:SAS_Modeling:Dist2VolHighLimit
	NVAR Dist2VolLowLimit=root:Packages:SAS_Modeling:Dist2VolLowLimit
	NVAR Dist2DiamAddition=root:Packages:SAS_Modeling:Dist2DiamAddition
	NVAR Dist2DAHighLimit=root:Packages:SAS_Modeling:Dist2DAHighLimit
	NVAR Dist2DALowLimit=root:Packages:SAS_Modeling:Dist2DALowLimit
	NVAR Dist2DiamMultiplier=root:Packages:SAS_Modeling:Dist2DiamMultiplier
	NVAR Dist2DMHighLimit=root:Packages:SAS_Modeling:Dist2DMHighLimit
	NVAR Dist2DMLowLimit=root:Packages:SAS_Modeling:Dist2DMLowLimit
	
	NVAR Dist2FitShape=root:Packages:SAS_Modeling:Dist2FitShape
	NVAR Dist2FitLocation=root:Packages:SAS_Modeling:Dist2FitLocation
	NVAR Dist2FitScale=root:Packages:SAS_Modeling:Dist2FitScale
	NVAR Dist2FitVol=root:Packages:SAS_Modeling:Dist2FitVol

//dist3 part
	NVAR Dist3VolFraction=root:Packages:SAS_Modeling:Dist3VolFraction
	NVAR Dist3VolHighLimit=root:Packages:SAS_Modeling:Dist3VolHighLimit
	NVAR Dist3VolLowLimit=root:Packages:SAS_Modeling:Dist3VolLowLimit
	NVAR Dist3DiamAddition=root:Packages:SAS_Modeling:Dist3DiamAddition
	NVAR Dist3DAHighLimit=root:Packages:SAS_Modeling:Dist3DAHighLimit
	NVAR Dist3DALowLimit=root:Packages:SAS_Modeling:Dist3DALowLimit
	NVAR Dist3DiamMultiplier=root:Packages:SAS_Modeling:Dist3DiamMultiplier
	NVAR Dist3DMHighLimit=root:Packages:SAS_Modeling:Dist3DMHighLimit
	NVAR Dist3DMLowLimit=root:Packages:SAS_Modeling:Dist3DMLowLimit
	
	NVAR Dist3FitShape=root:Packages:SAS_Modeling:Dist3FitShape
	NVAR Dist3FitLocation=root:Packages:SAS_Modeling:Dist3FitLocation
	NVAR Dist3FitScale=root:Packages:SAS_Modeling:Dist3FitScale
	NVAR Dist3FitVol=root:Packages:SAS_Modeling:Dist3FitVol

//Dist 4 part
	NVAR Dist4VolFraction=root:Packages:SAS_Modeling:Dist4VolFraction
	NVAR Dist4VolHighLimit=root:Packages:SAS_Modeling:Dist4VolHighLimit
	NVAR Dist4VolLowLimit=root:Packages:SAS_Modeling:Dist4VolLowLimit
	NVAR Dist4DiamAddition=root:Packages:SAS_Modeling:Dist4DiamAddition
	NVAR Dist4DAHighLimit=root:Packages:SAS_Modeling:Dist4DAHighLimit
	NVAR Dist4DALowLimit=root:Packages:SAS_Modeling:Dist4DALowLimit
	NVAR Dist4DiamMultiplier=root:Packages:SAS_Modeling:Dist4DiamMultiplier
	NVAR Dist4DMHighLimit=root:Packages:SAS_Modeling:Dist4DMHighLimit
	NVAR Dist4DMLowLimit=root:Packages:SAS_Modeling:Dist4DMLowLimit
	
	NVAR Dist4FitShape=root:Packages:SAS_Modeling:Dist4FitShape
	NVAR Dist4FitLocation=root:Packages:SAS_Modeling:Dist4FitLocation
	NVAR Dist4FitScale=root:Packages:SAS_Modeling:Dist4FitScale
	NVAR Dist4FitVol=root:Packages:SAS_Modeling:Dist4FitVol

//dist 5 part
	NVAR Dist5VolFraction=root:Packages:SAS_Modeling:Dist5VolFraction
	NVAR Dist5VolHighLimit=root:Packages:SAS_Modeling:Dist5VolHighLimit
	NVAR Dist5VolLowLimit=root:Packages:SAS_Modeling:Dist5VolLowLimit
	NVAR Dist5DiamAddition=root:Packages:SAS_Modeling:Dist5DiamAddition
	NVAR Dist5DAHighLimit=root:Packages:SAS_Modeling:Dist5DAHighLimit
	NVAR Dist5DALowLimit=root:Packages:SAS_Modeling:Dist5DALowLimit
	NVAR Dist5DiamMultiplier=root:Packages:SAS_Modeling:Dist5DiamMultiplier
	NVAR Dist5DMHighLimit=root:Packages:SAS_Modeling:Dist5DMHighLimit
	NVAR Dist5DMLowLimit=root:Packages:SAS_Modeling:Dist5DMLowLimit
	
	NVAR Dist5FitShape=root:Packages:SAS_Modeling:Dist5FitShape
	NVAR Dist5FitLocation=root:Packages:SAS_Modeling:Dist5FitLocation
	NVAR Dist5FitScale=root:Packages:SAS_Modeling:Dist5FitScale
	NVAR Dist5FitVol=root:Packages:SAS_Modeling:Dist5FitVol

	SVAR DataAreFrom=root:Packages:SAS_Modeling:DataFolderName
	SVAR Dist1ShapeModel=root:Packages:SAS_Modeling:Dist1ShapeModel
	SVAR Dist2ShapeModel=root:Packages:SAS_Modeling:Dist2ShapeModel
	SVAR Dist3ShapeModel=root:Packages:SAS_Modeling:Dist3ShapeModel
	SVAR Dist4ShapeModel=root:Packages:SAS_Modeling:Dist4ShapeModel
	SVAR Dist5ShapeModel=root:Packages:SAS_Modeling:Dist5ShapeModel
	
	NVAR Dist1Contrast=root:Packages:SAS_Modeling:Dist1Contrast
	NVAR Dist2Contrast=root:Packages:SAS_Modeling:Dist2Contrast
	NVAR Dist3Contrast=root:Packages:SAS_Modeling:Dist3Contrast
	NVAR Dist4Contrast=root:Packages:SAS_Modeling:Dist4Contrast
	NVAR Dist5Contrast=root:Packages:SAS_Modeling:Dist5Contrast
	
	NVAR Dist1Mean=root:Packages:SAS_Modeling:Dist1Mean
	NVAR Dist1Median=root:Packages:SAS_Modeling:Dist1Median
	NVAR Dist1Mode=root:Packages:SAS_Modeling:Dist1Mode
	NVAR Dist2Mean=root:Packages:SAS_Modeling:Dist2Mean
	NVAR Dist2Median=root:Packages:SAS_Modeling:Dist2Median
	NVAR Dist2Mode=root:Packages:SAS_Modeling:Dist2Mode
	NVAR Dist3Mean=root:Packages:SAS_Modeling:Dist3Mean
	NVAR Dist3Median=root:Packages:SAS_Modeling:Dist3Median
	NVAR Dist3Mode=root:Packages:SAS_Modeling:Dist3Mode
	NVAR Dist4Mean=root:Packages:SAS_Modeling:Dist4Mean
	NVAR Dist4Median=root:Packages:SAS_Modeling:Dist4Median
	NVAR Dist4Mode=root:Packages:SAS_Modeling:Dist4Mode
	NVAR Dist5Mean=root:Packages:SAS_Modeling:Dist5Mean
	NVAR Dist5Median=root:Packages:SAS_Modeling:Dist5Median
	NVAR Dist5Mode=root:Packages:SAS_Modeling:Dist5Mode
	NVAR Dist1FWHM=root:Packages:SAS_Modeling:Dist1FWHM
	NVAR Dist2FWHM=root:Packages:SAS_Modeling:Dist2FWHM
	NVAR Dist3FWHM=root:Packages:SAS_Modeling:Dist3FWHM
	NVAR Dist4FWHM=root:Packages:SAS_Modeling:Dist4FWHM
	NVAR Dist5FWHM=root:Packages:SAS_Modeling:Dist5FWHM
	
	

	IR1_CreateLoggbook()		//this creates the logbook
	SVAR nbl=root:Packages:SAS_Modeling:NotebookName

	IR1L_AppendAnyText("     ")
	if (cmpstr(CalledFromWere,"before")==0)
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Parameters before starting Fitting on the data from: "+DataAreFrom)
		IR1_InsertDateAndTime(nbl)
		IR1L_AppendAnyText("User defined distributions")
		IR1L_AppendAnyText("Number of modelled distributions: "+num2str(NumberOfDistributions))
	else			//after
		IR1L_AppendAnyText("***********************************************")
		IR1L_AppendAnyText("Results of the Fitting on the data from: "+DataAreFrom)	
		IR1_InsertDateAndTime(nbl)
		IR1L_AppendAnyText("User defined distributions")
		IR1L_AppendAnyText("Number of fitted distributions: "+num2str(NumberOfDistributions))
		IR1L_AppendAnyText("Fitting results: ")
	endif
	IR1L_AppendAnyText("SAS background = "+num2str(SASBackground)+", was fitted? = "+num2str(FitSASBackground)+"       (yes=1/no=0)")
	variable i
	For (i=1;i<=NumberOfDistributions;i+=1)
		IR1L_AppendAnyText("***********  Distribution "+num2str(i))
		SVAR tempShape=$("Dist"+num2str(i)+"ShapeModel")
			IR1L_AppendAnyText("Particle shape:     \t"+tempShape)
		NVAR tempVal =$("Dist"+num2str(i)+"Contrast")
			IR1L_AppendAnyText("Contrast       \t"+ num2str(tempVal))
			
		NVAR tempVal =$("Dist"+num2str(i)+"VolFraction")
		NVAR fitTempVal=$("Dist"+num2str(i)+"FitVol")
			IR1L_AppendAnyText("Volume      \t"+ num2str(tempVal)+"       ,  \tfitted? = "+num2str(fitTempVal))
		NVAR tempVal =$("Dist"+num2str(i)+"DiamAddition")
		NVAR fitTempVal=$("Dist"+num2str(i)+"FitDA")
			IR1L_AppendAnyText("Diammeter addition       \t"+ num2str(tempVal)+"       ,  \tfitted? = "+num2str(fitTempVal))
		NVAR tempVal =$("Dist"+num2str(i)+"DiamMultiplier")
		NVAR fitTempVal=$("Dist"+num2str(i)+"FitDM")
			IR1L_AppendAnyText("Diameter multiplier      \t"+ num2str(tempVal)+"       ,  \tfitted? = "+num2str(fitTempVal))

		NVAR tempVal =$("Dist"+num2str(i)+"Mean")
			IR1L_AppendAnyText("Mean       \t"+ num2str(tempVal))
		NVAR tempVal =$("Dist"+num2str(i)+"Median")
			IR1L_AppendAnyText("Median       \t"+ num2str(tempVal))
		NVAR tempVal =$("Dist"+num2str(i)+"Mode")
			IR1L_AppendAnyText("Mode       \t"+ num2str(tempVal))
		NVAR tempVal =$("Dist"+num2str(i)+"FWHM")
			IR1L_AppendAnyText("FWHM       \t"+ num2str(tempVal))

			IR1L_AppendAnyText("  ")
	endfor
	
	if (cmpstr(CalledFromWere,"after")==0)
		IR1L_AppendAnyText("Fit has been reached with following parameters")
		IR1_InsertDateAndTime(nbl)
		NVAR AchievedChisq
		IR1L_AppendAnyText("Chi-Squared \t"+ num2str(AchievedChisq))

		DoWindow /F IR1_LogLogPlotLSQF
		if (strlen(csrWave(A))!=0 && strlen(csrWave(B))!=0)		//cursors in the graph
			IR1L_AppendAnyText("Points selected for fitting \t"+ num2str(pcsr(A)) + "   to \t"+num2str(pcsr(B)))
		else
			IR1L_AppendAnyText("Whole range of data selected for fitting")
		endif
		IR1L_AppendAnyText(" ")
	endif			//after

	setdataFolder oldDf
end
