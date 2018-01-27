#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.03

//thsi should be all commented out and later removed. 3/31/2017

//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.03 changed to use optimized IR2P_ListOfWavesOfType function
//2.02 added license for ANL


//2.01 fix for bug which caused trouble in Igor 6.20 version. Some non-printable character in one line caused that code cannot compile. 

//This macro file is part of Igor macros package called "Irena", 
//the full package should be available from www.uni.aps.anl.gov/~ilavsky
//this package contains 
// Igor functions for modeling of SAS from various distributions of scatterers...

//Jan Ilavsky, January 2002

//please, read Readme in the distribution zip file with more details on the program
//report any problems to: ilavsky@aps.anl.gov


//these are generally useful functions, shared by various other macro files of Irena packages.


//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************


//Function/T IR1_GenStringOfFolders(UseIndra2Structure, UseQRSStructure, SlitSmearedData, AllowQRDataOnly)
//	variable UseIndra2Structure, UseQRSStructure, SlitSmearedData, AllowQRDataOnly
//		//SlitSmearedData =0 for DSM data, 
//		//                          =1 for SMR data 
//		//                    and =2 for both
//		// AllowQRDataOnly=1 if Q and R data are allowed only (no error wave). For QRS data ONLY!
//	
//	string ListOfQFolders
//	//	if UseIndra2Structure = 1 we are using Indra2 data, else return all folders 
//	string result
//	if (UseIndra2Structure)
//		if(SlitSmearedData==1)
//			result=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*SMR*", 1)
//		elseif(SlitSmearedData==2)
//			string tempStr=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*SMR*", 1)
//			result=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*DSM*", 1)+";"
//			variable i
//			for(i=0;i<ItemsInList(tempStr);i+=1)
//			//print stringmatch(result, "*"+StringFromList(i, tempStr,";")+"*")
//				if(stringmatch(result, "*"+StringFromList(i, tempStr,";")+"*")==0)
//					result+=StringFromList(i, tempStr,";")+";"
//				endif
//			endfor
//		else
//			result=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*DSM*", 1)
//		endif
//	elseif (UseQRSStructure)
//		ListOfQFolders=IN2G_FindFolderWithWaveTypes("root:", 10, "q*", 1)
//		result=IR1_ReturnListQRSFolders(ListOfQFolders,AllowQRDataOnly)
//	else
//		result=IN2G_FindFolderWithWaveTypes("root:", 10, "*", 1)
//	endif
//	
//Print "This code should be already deprecated. Called from "+GetRTStackInfo(0)+". remprt to Jan, please"	
//	return result
//end

//

////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function/T IR1R_ListOfWaves(WaveTp)
//	string WaveTp
//	
//	string result, tempresult, dataType, tempStringQ, tempStringR, tempStringS
//	SVAR FldrNm=root:Packages:Sizes:DataFolderName
//	NVAR Indra2Dta=root:Packages:Sizes:UseIndra2Data
//	NVAR QRSdata=root:Packages:Sizes:UseQRSData
//	variable i,j
//	string tempWvType
//		
//	if (Indra2Dta)
//			result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
//			if(stringMatch(result,"*"+WaveTp+"*"))
//				tempresult=""
//				for (i=0;i<ItemsInList(result);i+=1)
//					if (stringMatch(StringFromList(i,result),"*"+WaveTp+"*"))
//						tempresult+=StringFromList(i,result)+";"
//					endif
//				endfor
//				result=tempresult
//			endif
//	elseif(QRSData) 
//		result=""			//IN2G_CreateListOfItemsInFolder(FldrNm,2)
//		tempStringQ=IR2P_ListOfWavesOfType("q",IN2G_CreateListOfItemsInFolder(FldrNm,2))
//		tempStringR=IR2P_ListOfWavesOfType("r",IN2G_CreateListOfItemsInFolder(FldrNm,2))
//		tempStringS=IR2P_ListOfWavesOfType("s",IN2G_CreateListOfItemsInFolder(FldrNm,2))
//		
//		if (cmpstr(WaveTp,"DSM_Int")==0)
////			dataType="r"
//			For (j=0;j<ItemsInList(tempStringR);j+=1)
//				if (stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringR)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringR)[1,inf]+";*"))
//					result+=StringFromList(j,tempStringR)+";"
//				endif
//			endfor
//		elseif(cmpstr(WaveTp,"DSM_Qvec")==0)
////			dataType="q"
//			For (j=0;j<ItemsInList(tempStringQ);j+=1)
//				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringQ)[1,inf]+";*") && stringMatch(tempStringS,"*s"+StringFromList(j,tempStringQ)[1,inf]+";*"))
//					result+=StringFromList(j,tempStringQ)+";"
//				endif
//			endfor
//		else
////			dataType="s"			
//			For (j=0;j<ItemsInList(tempStringS);j+=1)
//				if (stringMatch(tempStringR,"*r"+StringFromList(j,tempStringS)[1,inf]+";*") && stringMatch(tempStringQ,"*q"+StringFromList(j,tempStringS)[1,inf]+";*"))
//					result+=StringFromList(j,tempStringS)+";"
//				endif
//			endfor
//		endif
////		tempresult=""
////			for (i=0;i<ItemsInList(result);i+=1)
////				if (stringMatch(StringFromList(i,result),dataType+"*"))
////					tempresult+=StringFromList(i,result)+";"
////				endif
////			endfor
////		result=tempresult
//	else
//		result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
//	endif
//	
//	return result
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function/T IR1_ListOfWavesInIFolder(i,ProbOrDia)
//	variable i
//	string ProbOrDia
//	
////look for data in folder called Dist+i+FolderName	
//	string result
//	SVAR FldrNm=$"root:Packages:SAS_Modeling:Dist"+num2str(i)+"FolderName"
//	if (strlen(FldrNm)==0)
//		return ""
//	endif
//	if (cmpstr(ProbOrDia,"Probability")==0)	
//		if(DataFolderExists(FldrNm))	
//			result=IN2G_CreateListOfItemsInFolder(FldrNm,2)
//		else
//			result=""
//		endif
//	endif
//	if (cmpstr(ProbOrDia,"Diameters")==0)
//		if(DataFolderExists(FldrNm))	
//			String dfSave
//			dfSave=GetDataFolder(1)
//			string MyList, MyListWithRightLenght=""	
//			variable ii
//			
//			SetDataFolder $FldrNm
//				SVAR tempName=$"root:Packages:SAS_Modeling:Dist"+num2str(i)+"ProbabilityWvNm"
//				Wave/Z Probab=$tempName 
//				if (!WaveExists(Probab))
//					MyListWithRightLenght=""
//				endif
//				MyList= IN2G_ConvertDataDirToList(DataFolderDir(2))	//here we convert the WAVES:wave1;wave2;wave3 into list
//			For(ii=0;ii<ItemsInList(MyList);ii+=1)
//				Wave testWv=$(StringFromList(ii, MyList))
//				if (numpnts(testWv)==numpnts(Probab))
//					MyListWithRightLenght+=StringFromList(ii, MyList)+";"
//				endif
//			endfor
//			SetDataFolder $dfSave
//		else
//			MyListWithRightLenght=""
//		endif
//		result =MyListWithRightLenght
//	endif
//	return result
//end
//
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
////Proc IR1_LogLogPlotStyle() : GraphStyle
////	PauseUpdate; Silent 1		// modifying window...
////	ModifyGraph/Z mode=3
////	ModifyGraph/Z msize=1
////	ModifyGraph/Z log=1
////	ModifyGraph/Z mirror=1
////	Label/Z left "Intensity [cm\\S-1\\M]"
////	Label/Z bottom "Q [A\\S-1\\M]"
////EndMacro
//
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////
////Function IR1_CalcWidthOfBin(myWvName,MyPoint)
////	Wave myWvName
////	variable MyPoint
////	
////	variable result
////	
////	if (MyPoint==0)	//first point
////		result=abs(MyWvName[1]-MyWvName[0])
////	else
////		if(MyPoint==numpnts(myWvname)-1)	//last point
////			result=abs(MyWvName[numpnts(myWvName)-1]-MyWvName[numpnts(myWvName)-2])
////		else		//normal point
////			result = abs(MyWvName[MyPoint]-MyWvName[MyPoint-1])+abs(MyWvName[MyPoint-1]-MyWvName[MyPoint]) 
////			result/=2
////		endif
////	endif
////	
////	return result
////	
////end
////
////
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
////Function IR1_CalcIntgPr_x_Vr(PrWvName,DiaWvName)
////	Wave PrWvName
////	Wave DiaWvName
////	//this calculates integral under the curve P(r) * 4/3 pi r^3 vs R
////
////	string OldDf=GetDataFolder(1)
////	SetDataFolder root:Packages:SAS_Modeling
////	Duplicate/O DiaWvName, RadWvName
////
////	variable result
////	Duplicate/O PrWvName, temp_PrxVrWave
////	temp_PrxVrWave=PrWvName*4/3*pi*RadWvName^3
////	result = areaXY(RadWvname, temp_PrxVrWave, RadWvName[0], RadWvName[numpnts(RadWvName)-1] )
////	KillWaves temp_PrxVrWave, RadWvName
////
////	result*=10^(-24)	//this converts to centimeters
////	
////	setDataFolder OldDf
////	return result
////end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_ConvertNumToVolDist(DistVolumeDist,DistNumberDist,Distdiameters,DistShapeModel,DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
//	Wave DistNumberDist, DistVolumeDist,Distdiameters
//	string DistShapeModel, UserVolumeFnctName
//	variable DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5
//	
//	Duplicate/O  Distdiameters, AveVolumeWave
//	IR1T_CreateAveVolumeWave(AveVolumeWave,Distdiameters,DistShapeModel,DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,0,0,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
//	
//
//	DistVolumeDist=DistNumberDist*AveVolumeWave
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_ConvertVolToNumDist(DistVolumeDist,DistNumberDist,Distdiameters,DistShapeModel,DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
//	Wave DistNumberDist, DistVolumeDist,Distdiameters
//	string DistShapeModel,UserVolumeFnctName
//	variable DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5
//
//	Duplicate/O  Distdiameters, AveVolumeWave
//	IR1T_CreateAveVolumeWave(AveVolumeWave,Distdiameters,DistShapeModel,DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,0,0,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
//	
//	DistNumberDist=DistVolumeDist/AveVolumeWave
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
////Function IR1_CreateAveVolumeWave(AveVolumeWave,Distdiameters,DistShapeModel,DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3,UserVolumeFnctName,UserPar1,UserPar2,UserPar3,UserPar4,UserPar5)
////	Wave AveVolumeWave,Distdiameters
////	string DistShapeModel, UserVolumeFnctName
////	variable DistScatShapeParam1,DistScatShapeParam2,DistScatShapeParam3, UserPar1,UserPar2,UserPar3,UserPar4,UserPar5
////
////	variable i,j
////	variable StartValue, EndValue, tempVolume, tempRadius
////	string cmd2, infostr
////	
////	string OldDf=GetDataFolder(1)
////	setDataFolder root:Packages:SAS_Modeling
////	variable/g tempVolCalc
////	
////	For (i=0;i<numpnts(Distdiameters);i+=1)
////		StartValue=IR1_StartOfBinInDiameters(Distdiameters,i)
////		EndValue=IR1_EndOfBinInDiameters(Distdiameters,i)
////		tempVolume=0
////		tempVolCalc=0
////		
////		For(j=0;j<=50;j+=1)
////			tempRadius=(StartValue+j*(EndValue-StartValue)/50 ) /2
////			 if (cmpstr(DistShapeModel,"sphere")==0 || cmpstr(DistShapeModel,"Algebraic_Integrated Spheres")==0)			//sphere, volume is 4/3 pi *r^3
////				tempVolume+=4/3*pi*(tempRadius^3)
////			elseif(cmpstr(DistShapeModel,"spheroid")==0 ||cmpstr(DistShapeModel,"Integrated_Spheroid")==0)		//spheroid, volume 4/3 pi * r^3 *beta
////				tempVolume+=4/3*pi*(tempRadius^3)*DistScatShapeParam1
////			elseif(cmpstr(DistShapeModel,"Algebraic_Globules")==0)		//globule 4/3 pi * r^3 *beta
////				tempVolume+=4/3*pi*(tempRadius^3)*DistScatShapeParam1
////			elseif(cmpstr(DistShapeModel,"Algebraic_Disks")==0)		//Alg disk, 
////				tempVolume+=2*pi*(tempRadius^3)*DistScatShapeParam1
////			elseif(cmpstr(DistShapeModel,"Unified_Disc")==0)		//Alg disk, 
////				tempVolume+=2*pi*(tempRadius^3)*DistScatShapeParam1
////			elseif(cmpstr(DistShapeModel,"Algebraic_Rods")==0)		//Alg rod, 
////				tempVolume+=2*pi*(tempRadius^3)*DistScatShapeParam1
////			elseif(cmpstr(DistShapeModel,"cylinder")==0)		//cylinder volume = pi* r^2 * length
////				tempVolume+=pi*(tempRadius^2)*DistScatShapeParam1
////			elseif(cmpstr(DistShapeModel,"tube")==0)			//tube volume = pi* (r+tube wall thickness)^2 * length
////				tempVolume+=pi*((tempRadius+DistScatShapeParam2)^2)*DistScatShapeParam1
////			elseif(cmpstr(DistShapeModel,"coreshell")==0)
////				tempVolume+=4/3*pi*(tempRadius^3)			//this is not right, we'll have to find how to do it right..
////			elseif(cmpstr(DistShapeModel,"Fractal Aggregate")==0)
////				tempVolume+=IR1_VolumeOfFractalAggregate(tempRadius, DistScatShapeParam1,DistScatShapeParam2)
////			elseif(cmpstr(DistShapeModel,"User")==0)	
////					infostr = FunctionInfo(UserVolumeFnctName)
////					if (strlen(infostr) == 0)
////						Abort
////					endif
////					if(NumberByKey("N_PARAMS", infostr)!=6 || NumberByKey("RETURNTYPE", infostr)!=4)
////						Abort
////					endif
////				cmd2="root:Packages:SAS_Modeling:tempVolCalc="+UserVolumeFnctName+"("+num2str(tempRadius)+","+num2str(UserPar1)+","+num2str(UserPar2)+","+num2str(UserPar3)+","+num2str(UserPar4)+","+num2str(UserPar5)+")"
////				Execute (cmd2)
////				tempVolume+=tempVolCalc
////			endif		
////		endfor
////		tempVolume/=50				//average
////		tempVolume*=10^(-24)		//conversion from A to cm
////		AveVolumeWave[i]=tempVolume
////	endfor
////	setDataFolder OldDf
////end
////
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1_VolumeOfFractalAggregate(FractalRadius, PrimaryPartRadius,Dimension)
//	variable FractalRadius, PrimaryPartRadius,Dimension
//	
//	variable result
//	result=((4/3)*pi*PrimaryPartRadius^3)*((FractalRadius/PrimaryPartRadius)^Dimension)*10^(-24)		//solid volume 
////	result=((4/3)*pi*PrimaryPartRadius^3)*10^(-24)
////	result=((4/3)*pi*FractalRadius^3)*10^(-24)
////	result=((4/3)*pi*FractalRadius^3)*10^(-24)				//envelope volume
//	return result
//end
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1S_RecoverOldParameters()
//	
//	NVAR NumberOfDistributions=root:Packages:SAS_Modeling:NumberOfDistributions
//
//	NVAR SASBackground=root:Packages:SAS_Modeling:SASBackground
//	NVAR FitSASBackground=root:Packages:SAS_Modeling:FitSASBackground
//	NVAR SASBackgroundError=root:Packages:SAS_Modeling:SASBackgroundError
//	NVAR UseNumberDistribution=root:Packages:SAS_Modeling:UseNumberDistribution
//	NVAR UseVolumeDistribution=root:Packages:SAS_Modeling:UseVolumeDistribution
//	NVAR UseInterference=root:Packages:SAS_Modeling:UseInterference
//	SVAR DataFolderName=root:Packages:SAS_Modeling:DataFolderName
//	NVAR UseSlitSmearedData=root:Packages:SAS_Modeling:UseSlitSmearedData
//	NVAR SlitLength=root:Packages:SAS_Modeling:SlitLength
//
//	variable DataExists=0,i
//	string ListOfWaves=IN2G_CreateListOfItemsInFolder(DataFolderName, 2)
//	string tempString
//	if (stringmatch(ListOfWaves, "*ModelingIntensity*" ))
//		string ListOfSolutions="start from current state;"
//		For(i=0;i<itemsInList(ListOfWaves);i+=1)
//			if (stringmatch(stringFromList(i,ListOfWaves),"*ModelingIntensity*"))
//				tempString=stringFromList(i,ListOfWaves)
//				Wave tempwv=$(DataFolderName+tempString)
//				tempString=stringByKey("UsersComment",note(tempwv),"=")
//				ListOfSolutions+=stringFromList(i,ListOfWaves)+"*  "+tempString+";"
//			endif
//		endfor
//		DataExists=1
//		string ReturnSolution=""
//		Prompt ReturnSolution, "Select solution to recover", popup,  ListOfSolutions
//		DoPrompt "Previous solutions found, select one to recover", ReturnSolution
//		if (V_Flag)
//			abort
//		endif
//		if (cmpstr("start from current state",ReturnSolution)==0)
//			DataExists=0
//		endif
//	endif
//
//	if (DataExists==1)
//		ReturnSolution=ReturnSolution[0,strsearch(ReturnSolution, "*", 0 )-1]
//		Wave/Z OldDistribution=$(DataFolderName+ReturnSolution)
//
//		string OldNote=note(OldDistribution)
//		NumberOfDistributions=NumberByKey("NumberOfModelledDistributions", OldNote,"=")
//		PopupMenu NumberOfDistributions mode=(NumberOfDistributions+1), win=IR1S_ControlPanel
//		SASBackground =NumberByKey("SASBackground", OldNote,"=")
//		FitSASBackground =NumberByKey("FitSASBackground", OldNote,"=")
//		UseInterference =NumberByKey("UseInterference", OldNote,"=")
//		variable oldUseSlitSmData=NumberByKey("UseSlitSmearedData", OldNote,"=")
//		if(oldUseSlitSmData==UseSlitSmearedData)
//			SlitLength=NumberByKey("SlitLength", OldNote,"=")
//		elseif((numtype(oldUseSlitSmData)!=0) && (UseSlitSmearedData==0))	//dsm data
//			SlitLength=0
//		elseif( (oldUseSlitSmData==1) && (UseSlitSmearedData==0))		//old smr new dsm
//			DoAlert 0, "FYI: Previous results were obtained for slit smeared data, current dataset is desmeared (pihole type)"
//			SlitLength=NumberByKey("SlitLength", OldNote,"=")
//		else
//			DoAlert 0, "FYI: Previous results were obtained for desmeared (pinhole-type) data, current dataset is slit smeared"
//			SlitLength=NumberByKey("SlitLength", OldNote,"=")
//		endif
//		
//		cursor/P/W=IR1_LogLogPlotLSQF A, OriginalIntensity , NumberByKey("cursorAposition", OldNote,"=")
//		cursor/P/W=IR1_LogLogPlotLSQF B, OriginalIntensity, NumberByKey("cursorBposition", OldNote,"=")
//		if (cmpstr(StringByKey("DistributionTypeModelled", OldNote,"="),"Volume distribution")==0)
//			UseNumberDistribution =0	
//			UseVolumeDistribution=1
//		else
//			UseNumberDistribution =1
//			UseVolumeDistribution=0
//		endif
//
//		For(i=1;i<=NumberOfDistributions;i+=1)		
//			IR1S_RecoverOneDistParam(i,OldNote)	
//		endfor
//		//fix the GUI
//		IR1S_TabPanelControl("",0)
//		SVAR DistDistributionType=root:Packages:SAS_Modeling:Dist1DistributionType
//		SVAR DistShapeModel=root:Packages:SAS_Modeling:Dist1ShapeModel
//		SVAR ListOfFormFactors=root:Packages:FormFactorCalc:ListOfFormFactors
//		variable NumItm=WhichListItem(LowerStr(DistDistributionType),LowerStr("LogNormal;Gauss;LSW;PowerLaw"))
//		PopupMenu Dis1_DistributionType,win=IR1S_ControlPanel,mode=NumItm+1
//		NumItm=WhichListItem(LowerStr(DistShapeModel),LowerStr(ListOfFormFactors))
//		PopupMenu Dis1_ShapePopup,win=IR1S_ControlPanel,mode=NumItm+1
//
//
//	endif
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
//Function IR1S_RecoverOneDistParam(i,OldNote)	
//	variable i
//	string OldNote
//
//	
//	NVAR DistNumberOfPoints=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"NumberOfPoints")
//	NVAR DistContrast=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"Contrast")
//	NVAR DistLocation=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"Location")
//	NVAR DistScale=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"Scale")
//	NVAR DistShape=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"Shape")
//	NVAR DistVolFraction=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"VolFraction")
//
//	NVAR DistMean=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"Mean")
//	NVAR DistMedian=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"Median")
//	NVAR DistMode=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"Mode")
//
//	NVAR DistLocHighLimit=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"LocHighLimit")
//	NVAR DistLocLowLimit=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"LocLowLimit")
//	NVAR DistScaleHighLimit=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ScaleHighLimit")
//	NVAR DistScaleLowLimit=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ScaleLowLimit")
//	NVAR DistShapeHighLimit=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ShapeHighLimit")
//	NVAR DistShapeLowLimit=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ShapeLowLimit")
//	NVAR DistVolHighLimit=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"VolHighLimit")
//	NVAR DistVolLowLimit=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"VolLowLimit")
//
//	NVAR DistFitLocation=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"FitLocation")
//	NVAR DistFitScale=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"FitScale")
//	NVAR DistFitShape=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"FitShape")
//	NVAR DistFitVol=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"FitVol")
//
//	NVAR DistNegligibleFraction=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"NegligibleFraction")
//	NVAR DistScatShapeParam1=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ScatShapeParam1")
//	NVAR DistScatShapeParam2=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ScatShapeParam2")
//	NVAR DistScatShapeParam3=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ScatShapeParam3")
//	NVAR DistScatShapeParam4=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ScatShapeParam4")
//	NVAR DistScatShapeParam5=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ScatShapeParam5")
//	
//	NVAR DistUseInterference= $("root:Packages:SAS_Modeling:Dist"+num2str(i)+"UseInterference")
//	NVAR DistInterferencePhi= $("root:Packages:SAS_Modeling:Dist"+num2str(i)+"InterferencePhi")
//	NVAR DistInterferenceEta= $("root:Packages:SAS_Modeling:Dist"+num2str(i)+"InterferenceEta")
//	NVAR DistFitInterferencePhi= $("root:Packages:SAS_Modeling:Dist"+num2str(i)+"FitInterferencePhi")
//	NVAR DistFitInterferenceEta= $("root:Packages:SAS_Modeling:Dist"+num2str(i)+"FitInterferenceEta")
//
//
//	SVAR DistDistributionType=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"DistributionType")
//	SVAR DistShapeModel=$("root:Packages:SAS_Modeling:Dist"+num2str(i)+"ShapeModel")
//
//
//	DistFitShape=NumberByKey("Dist"+num2str(i)+"FitShape", OldNote,"=")
//	DistFitScale=NumberByKey("Dist"+num2str(i)+"FitScale", OldNote,"=")
//	DistFitLocation=NumberByKey("Dist"+num2str(i)+"FitLocation", OldNote,"=")
//	DistFitVol=NumberByKey("Dist"+num2str(i)+"FitVol", OldNote,"=")
//
//	DistNumberOfPoints=NumberByKey("Dist"+num2str(i)+"NumberOfPoints", OldNote,"=")
//	DistContrast=NumberByKey("Dist"+num2str(i)+"Contrast", OldNote,"=")
//	DistShape=NumberByKey("Dist"+num2str(i)+"Shape", OldNote,"=")
//	DistScale=NumberByKey("Dist"+num2str(i)+"Scale", OldNote,"=")
//	DistLocation=NumberByKey("Dist"+num2str(i)+"Location", OldNote,"=")
//	DistVolFraction=NumberByKey("Dist"+num2str(i)+"VolFraction", OldNote,"=")
//	DistNegligibleFraction=NumberByKey("Dist"+num2str(i)+"NegligibleFraction", OldNote,"=")
//	DistDistributionType=StringByKey("Dist"+num2str(i)+"DistributionType", OldNote,"=")
//	DistScatShapeParam1=NumberByKey("Dist"+num2str(i)+"ScatShapeParam1", OldNote,"=")
//	DistScatShapeParam2=NumberByKey("Dist"+num2str(i)+"ScatShapeParam2", OldNote,"=")
//	DistScatShapeParam3=NumberByKey("Dist"+num2str(i)+"ScatShapeParam3", OldNote,"=")
//	DistScatShapeParam4=NumberByKey("Dist"+num2str(i)+"ScatShapeParam4", OldNote,"=")
//	DistScatShapeParam5=NumberByKey("Dist"+num2str(i)+"ScatShapeParam5", OldNote,"=")
//	DistUseInterference =NumberByKey("Dist"+num2str(i)+"UseInterference", OldNote,"=")
//	if (DistUseInterference)
//		DistInterferencePhi =NumberByKey("Dist"+num2str(i)+"InterferencePhi", OldNote,"=")
//		DistInterferenceEta =NumberByKey("Dist"+num2str(i)+"InterferenceEta", OldNote,"=")
//		DistFitInterferencePhi =NumberByKey("Dist"+num2str(i)+"FitInterferencePhi", OldNote,"=")
//		DistFitInterferenceEta =NumberByKey("Dist"+num2str(i)+"FitInterferenceEta", OldNote,"=")
//	endif
//
//	DistShapeModel=StringByKey("Dist"+num2str(i)+"ShapeModel", OldNote,"=")
//	DistDistributionType=StringByKey("Dist"+num2str(i)+"DistributionType", OldNote,"=")
////
//
//end
//
//
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
////*****************************************************************************************************************
//
