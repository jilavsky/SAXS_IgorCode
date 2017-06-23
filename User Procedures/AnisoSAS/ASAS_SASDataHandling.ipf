#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.1		//modified 5 29 2005 to accept 5 populations JIL


//here we deal with copying SAS data and working with them...

Function ASAS_CreateWvsForFitting()
	//here we create truncated copies of data for fitting
	
	setDataFolder root:Packages:AnisoSAS:
	variable i, startP, endP, j
	NVAR NumbOfDir=root:Packages:AnisoSAS:NumberOfDirections

	For (i=1;i<=NumbOfDir;i+=1)
		Wave Int=$("Dir"+num2str(i)+"_Intensity")
		Wave Qvec=$("Dir"+num2str(i)+"_Qvector")
		Wave Error=$("Dir"+num2str(i)+"_Error")
		Wave Mask=$("Dir"+num2str(i)+"_MaskWave")
		Wave Color=$("Dir"+num2str(i)+"_ColorWave")
		For(j=0;j<numpnts(Mask);j+=1)
			if (Mask[j]!=18)
				StartP=j
				break
			endif
		endfor
		For(j=numpnts(Mask);j>0;j-=1)
			if (Mask[j]!=18)
				EndP=j
				break
			endif
		endfor
		
		Duplicate/O /R=[StartP,EndP] Int, $("Dir"+num2str(i)+"_CutIntensity")
		Duplicate/O /R=[StartP,EndP] Qvec, $("Dir"+num2str(i)+"_CutQvector")
		Duplicate/O /R=[StartP,EndP] Error, $("Dir"+num2str(i)+"_CutError")
		Duplicate/O /R=[StartP,EndP] Color, $("Dir"+num2str(i)+"_CutColor")
	
	endfor
end


Function ASAS_GetWavelength()

	setDataFolder root:Packages:AnisoSAS:
	
	Wave Dir1_Intensity=root:Packages:AnisoSAS:Dir1_Intensity
	NVAR Wavelength=root:Packages:AnisoSAS:Wavelength
	
	Wavelength=NumberByKey("Wavelength", note(Dir1_Intensity), "=")

end

Function ASAS_CreateDataGraph()

	Execute("ASAS_InputGraph()")

end

Function ASAS_AppendWvsToGraph()
	
	RemoveFromGraph /Z /W=ASAS_InputGraph  Dir1_Intensity,Dir2_Intensity,Dir3_Intensity,Dir4_Intensity,Dir5_Intensity, Dir6_Intensity

	variable i
	NVAR NumbOfDir=root:Packages:AnisoSAS:NumberOfDirections
	string WvName
	
	For (i=1;i<=NumbOfDir;i+=1)
		Wave Int=$("root:Packages:AnisoSAS:Dir"+num2str(i)+"_Intensity")
		Wave Qvec=$("root:Packages:AnisoSAS:Dir"+num2str(i)+"_Qvector")
		Wave Error=$("root:Packages:AnisoSAS:Dir"+num2str(i)+"_Error")
		WvName="Dir"+num2str(i)+"_Intensity"
		
		AppendToGraph /W=ASAS_InputGraph  Int vs Qvec
		ErrorBars $WvName Y,wave=(Error,Error)
		
	endfor
end

Function ASAS_FixWavesMarkers()
	//this function fixes the markers in the graph to numbers in the waves

	setDataFolder root:Packages:AnisoSAS
	
//	Wave/Z Markers1= Dir1_MaskWave
//	Wave/Z Markers2= Dir2_MaskWave
//	Wave/Z Markers3= Dir3_MaskWave
//	Wave/Z Markers4= Dir4_MaskWave
//	Wave/Z Markers5= Dir5_MaskWave
//	Wave/Z Markers6= Dir6_MaskWave

//	ModifyGraph /Z /W=ASAS_InputGraph zmrkNum[0]={Markers1}, zmrkNum[1]={Markers2}, zmrkNum[2]={Markers3}, zmrkNum[3]={Markers4}, zmrkNum[4]={Markers5}, zmrkNum[5]={Markers6}
	variable i
	NVAR nmbdist=root:Packages:AnisoSAS:NumberOfDirections
	For (i=1;i<=nmbdist;i+=1)
		ModifyGraph /Z /W=ASAS_InputGraph zmrkNum[0]={$("Dir"+num2str(i)+"_MaskWave")} ///{Markers1}
		ModifyGraph /Z /W=ASAS_InputGraph  zColor[i-1]={$("Dir"+num2str(i)+"_ColorWave"),0,10,PlanetEarth}
	endfor
end

Function ASAS_SelectRangeOfData()
	
	//OK, here we select range of data to work with from the graph using cursors
	//first we need to know if both cursors are in the graph and on the same wave
	if (strlen(CsrWave(B))==0 || strlen(CsrWave(A))==0)
			Abort "Both cursors need to be in graph and on the SAME wave"	
	endif
	if (cmpstr(CsrWave(B), CsrWave(A))!=0)
			Abort "Both cursors need to be on the SAME wave"	
	endif
	
	variable startPnt, endPnt
	startPnt=pcsr(A)
	endPnt=pcsr(B)
	string CsrWaveName, MaskWaveName, ClrWaveName
	CsrWaveName=CsrWave(A)
	MaskWaveName=CsrWaveName[0,4]+"MaskWave"
	ClrWaveName=CsrWaveName[0,4]+"ColorWave"
	Wave MskWv=$(MaskWaveName)
	Wave ClrWv=$(ClrWaveName)

	MskWv  = 1+str2num(MaskWaveName[3])*2
	ClrWv    = 1.6*(str2num(MaskWaveName[3])-1)
	
	
	MskWv[0,startPnt-1]=18
	MskWv[endPnt+1,numpnts(MskWv)-1]=18
	
	ClrWv[0,startPnt-1]=10
	ClrWv[endPnt+1,numpnts(ClrWv)-1]=10
	
	//and now we create also short waves with Int, Q nad error for fitting.
	Wave TempInt=$(CsrWaveName[0,4]+"Intensity")
	Wave TempQ=$(CsrWaveName[0,4]+"Qvector")
	Wave TempError=$(CsrWaveName[0,4]+"Error")
	Duplicate/O/R=[startPnt,endPnt] TempInt, $(CsrWaveName[0,4]+"FitIntensity")
	Duplicate/O/R=[startPnt,endPnt]  TempQ, $(CsrWaveName[0,4]+"FitQvector")
	Duplicate/O/R=[startPnt,endPnt]  TempError, $(CsrWaveName[0,4]+"FitError")

end

Function ASAS_FixGraphVisual()

	ModifyGraph/W=ASAS_InputGraph mode=3, msize=3
//	ModifyGraph /Z /W=ASAS_InputGraph rgb[0]=(0,0,65280), rgb[1]=(65280,0,0), rgb[2]=(0,52224,0), rgb[3]=(4352,4352,4352), rgb[4]=(48000,16384,16384), rgb[5]=(32000,16000,16000)
	ModifyGraph/W=ASAS_InputGraph log=1
	ModifyGraph/W=ASAS_InputGraph mirror=1
	ModifyGraph/W=ASAS_InputGraph standoff=0
	Label left "Intensity [cm\\S-1\\M]"
	Label bottom "Q vector [A\\S-1\\M]"
	SetAxis bottom 1e-04,1
	Button ASASSelectRangeOfData proc=ASAS_ButtonProc,title="Select"
	Button ASASSelectRangeOfData pos={300,20},size={100,30}
	ShowInfo
	Wave Dir1_Qvector
	cursor /A=1/P  A Dir1_Intensity binarysearch(Dir1_Qvector, 0.0002 )
	cursor /A=1/P  B Dir1_Intensity binarysearch(Dir1_Qvector, 0.02 )
	
	ASAS_GenerateLegend()
end


Function ASAS_GenerateLegend()

	NVAR nmbdist=root:Packages:AnisoSAS:NumberOfDirections
	STRING LegendText, markerDesc, colorDesc
	LegendText=""
	
	
	//colors can be changed by     \K(65280,0,0)
	
	variable i, medPoint, myMarker
	For (i=1;i<=nmbdist;i+=1)
		Wave Markers=$("Dir"+num2str(i)+"_MaskWave")
		MedPoint=numpnts(Markers)/2
		myMarker=Markers[MedPoint]
		if (myMarker<=9)
			markerDesc="0"+num2str(myMarker)
		else
			MarkerDesc=num2str(myMarker)
		endif
		if (i==1)
			colorDesc="\\K(0,0,0)"
		elseif(i==2)
			colorDesc="\\K(65280,32512,16384)"
		elseif(i==3)
			colorDesc="\\K(65280,65280,0)"
		elseif(i==4)
			colorDesc="\\K(0,65280,0)"
		elseif(i==5)
			colorDesc="\\K(16384,48896,65280)"
		else
			colorDesc="\\K(39168,39168,39168)"
		endif
		
		LegendText+=colorDesc+"\\W4"+MarkerDesc+"   Dir"+num2str(i)+"_Intensity\r"
	endfor
	
	LegendText=LegendText[0,strlen(LegendText)-2]+"\\K(0,0,0)"
	
	Legend/C/N=text0/A=RT/W=ASAS_InputGraph LegendText
end

Window ASAS_InputGraph() : Graph
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:AnisoSAS:
	Display /W=(403.5,42.5,800,360)/K=1  Dir1_Intensity vs Dir1_Qvector as "ASAS input graph"
	SetDataFolder fldrSav
EndMacro


Window ASAS_ProbabilityGraph() : Graph
	PauseUpdate; Silent 1		// building window...
	String fldrSav= GetDataFolder(1)
	SetDataFolder root:Packages:AnisoSAS:
	Display/K=1 /W=(344.25,497.75,766.5,731.75) Pop1_AlphaDist
	AppendToGraph/R/T Pop1_OmegaDist
	ModifyGraph lSize=3
      ModifyGraph rgb[1]=(4352,4352,4352)
	Label left "Probability Alpha (normalized)"
	Label bottom "Alpha angle (0 - 90 degrees in radians)"
	Label right "Omega probability (normalized)"
	Label top "Omega angle (0 - 360 degrees in radians)"
	Legend/C/N=text0
	SetAxis/A/E=1 left
	SetAxis/A/E=1 right
EndMacro


Function ASAS_UpdateDistGraph(tab)
	variable tab
	
	DoWIndow ASAS_ProbabilityGraph
	if (!V_Flag)
		Execute("ASAS_ProbabilityGraph()")
	endif
	DoWIndow/F ASAS_ProbabilityGraph
	
	NVAR/Z DisplayAllProbabilityDist=root:Packages:AnisoSAS:DisplayAllProbabilityDist		//set to 1 if user wants to see all active populations distributions
	If(!NVAR_Exists(DisplayAllProbabilityDist))
		variable/g root:Packages:AnisoSAS:DisplayAllProbabilityDist
		NVAR DisplayAllProbabilityDist=root:Packages:AnisoSAS:DisplayAllProbabilityDist
		DisplayAllProbabilityDist=0
	endif
	NVAR NumbDist=root:Packages:AnisoSAS:NumberOfPopulations
	
	variable DistNum=tab+1
	variable i
		
	RemoveFromGraph/Z /W=ASAS_ProbabilityGraph Pop1_AlphaDist, Pop2_AlphaDist, Pop3_AlphaDist,Pop4_AlphaDist, Pop5_AlphaDist,Pop6_AlphaDist
	RemoveFromGraph/Z /W=ASAS_ProbabilityGraph Pop1_OmegaDist, Pop2_OmegaDist, Pop3_OmegaDist, Pop4_OmegaDist, Pop5_OmegaDist, Pop6_OmegaDist
	//ASAS_FixStupidIgorBug()
	
	if (DisplayAllProbabilityDist)		//display all populations
		for(i=1;i<=NumbDist;i+=1)
			AppendToGraph /W=ASAS_ProbabilityGraph $("Pop"+num2str(i)+"_AlphaDist")
			AppendToGraph/R/T/W=ASAS_ProbabilityGraph $("Pop"+num2str(i)+"_OmegaDist")
		endfor
	else
		AppendToGraph /W=ASAS_ProbabilityGraph $("Pop"+num2str(DistNum)+"_AlphaDist")
		AppendToGraph/R/T/W=ASAS_ProbabilityGraph $("Pop"+num2str(DistNum)+"_OmegaDist")
	endif
	DoUpdate
	
	ModifyGraph/Z/W=ASAS_ProbabilityGraph lSize[0]=3, lSize[1]=5
	ModifyGraph/Z/W=ASAS_ProbabilityGraph lSize[2]=3, lSize[3]=5
	ModifyGraph/Z/W=ASAS_ProbabilityGraph lSize[4]=3, lSize[5]=5
	ModifyGraph/Z/W=ASAS_ProbabilityGraph lSize[6]=3, lSize[7]=5
	ModifyGraph/Z/W=ASAS_ProbabilityGraph lStyle[0]=0, lStyle[1]=3,lStyle[2]=0, lStyle[3]=3,lStyle[4]=0, lStyle[5]=3,lStyle[6]=0, lStyle[7]=3,lStyle[8]=0, lStyle[9]=3
      ModifyGraph/Z/W=ASAS_ProbabilityGraph rgb[0]=(65280,16384,16384), rgb[1]=(65280,16384,16384)
      ModifyGraph/Z/W=ASAS_ProbabilityGraph rgb[2]=(0,0,0), rgb[3]=(0,0,0)
      ModifyGraph/Z/W=ASAS_ProbabilityGraph rgb[4]=(16384,16384,65280), rgb[5]=(16384,16384,65280)
      ModifyGraph/Z/W=ASAS_ProbabilityGraph rgb[6]=(16384,65280,16384), rgb[7]=(16384,65280,16384)
      
	Label /W=ASAS_ProbabilityGraph left "Probability Alpha (normalized)"
	Label /W=ASAS_ProbabilityGraph bottom "Alpha angle (0 - 90 degrees in radians)"
	Label  /W=ASAS_ProbabilityGraph right "Omega probability (normalized)"
	Label  /W=ASAS_ProbabilityGraph top "Omega angle (0 - 360 degrees in radians)"
	Legend /W=ASAS_ProbabilityGraph /C/N=text0
	SetAxis /W=ASAS_ProbabilityGraph/A/E=1 left
	SetAxis /W=ASAS_ProbabilityGraph/A/E=1 right
end

//Function ASAS_FixStupidIgorBug()
//
//	//	RemoveFromGraph/Z /W=ASAS_ProbabilityGraph Pop1_AlphaDist, Pop2_AlphaDist, Pop3_AlphaDist,Pop4_AlphaDist, Pop5_AlphaDist,Pop6_AlphaDist
//	//	RemoveFromGraph/Z /W=ASAS_ProbabilityGraph Pop1_OmegaDist, Pop2_OmegaDist, Pop3_OmegaDist, Pop4_OmegaDist, Pop5_OmegaDist, Pop6_OmegaDist
//	string WavesToRemove ="Pop1_AlphaDist;Pop2_AlphaDist;Pop3_AlphaDist;Pop4_AlphaDist;Pop5_AlphaDist;Pop6_AlphaDist;"
//	WavesToRemove+="Pop1_OmegaDist;Pop2_OmegaDist;Pop3_OmegaDist;Pop4_OmegaDist;Pop5_OmegaDist;Pop6_OmegaDist;"
//	
//	variable i, imax=ItemsInList(WavesToRemove)
//	string OneWaveName
//	For(i=0;i<=imax;i+=1)
//		OneWaveName=StringFromList(i, WavesToRemove)
//		CheckDisplayed/W=ASAS_ProbabilityGraph $(OneWaveName)
//		if (V_Flag)
//			RemoveFromGraph/Z/W=ASAS_ProbabilityGraph $OneWaveName
//		endif
//	endfor
//end
//

Function  ASAS_CopyDataLocaly()

	setDataFolder root:Packages:AnisoSAS
	
	Variable i
	NVAR NumberOfUsedDirections=root:Packages:AnisoSAS:NumberOfDirections

	For (i=1;i<=6;i+=1)
		Wave/Z KillInt=$("Dir"+num2str(i)+"_OrgIntensity")
		Wave/Z KillQ=$("Dir"+num2str(i)+"_OrgQvector")
		Wave/Z KillError=$("Dir"+num2str(i)+"_OrgError")
		Wave/Z KillMask=$("Dir"+num2str(i)+"_MaskWave")

		Wave/Z KillFitInt=$("Dir"+num2str(i)+"_FitIntensity")
		Wave/Z KillFitQ=$("Dir"+num2str(i)+"_FitQvector")
		Wave/Z KillFitErr=$("Dir"+num2str(i)+"_FitError")

		KillWaves/Z KillInt, KillQ, KillError, KillMask, KillFitQ, KillFitInt, KillFitErr
	endfor

	For (i=1;i<=NumberOfUsedDirections;i+=1)
	
		SVAR Dir_DataFolderName=$("root:Packages:AnisoSAS:Dir"+num2str(i)+"_DataFolderName")
		SVAR Dir_IntWvName=$("root:Packages:AnisoSAS:Dir"+num2str(i)+"_IntWvName")
		SVAR Dir_QvecWvName=$("root:Packages:AnisoSAS:Dir"+num2str(i)+"_QvecWvName")
		SVAR Dir_ErrorWvName=$("root:Packages:AnisoSAS:Dir"+num2str(i)+"_ErrorWvName")
			
		if(i==1)
			if (strlen(Dir_DataFolderName)<5)
				abort
			endif
		endif
		
		if (strlen(Dir_DataFolderName)>5)
			Wave TempInt=$(Dir_DataFolderName+Dir_IntWvName)
			Wave TempQ=$(Dir_DataFolderName+Dir_QvecWvName)
			Wave TempError=$(Dir_DataFolderName+Dir_ErrorWvName)
			
			Duplicate/O TempInt, $("Dir"+num2str(i)+"_OrgIntensity"), $("Dir"+num2str(i)+"_Intensity")
			Duplicate/O TempQ, $("Dir"+num2str(i)+"_OrgQvector"), $("Dir"+num2str(i)+"_Qvector")
			Duplicate/O TempError, $("Dir"+num2str(i)+"_OrgError"), $("Dir"+num2str(i)+"_Error")
			Duplicate/O TempInt, $("Dir"+num2str(i)+"_MaskWave")
			Duplicate/O TempInt, $("Dir"+num2str(i)+"_ColorWave")
			Wave MskWv=$("Dir"+num2str(i)+"_MaskWave")
			Wave ClrWv=$("Dir"+num2str(i)+"_ColorWave")
//			Duplicate/O TempInt, $("Dir"+num2str(i)+"_FitIntensity")
//			Duplicate/O TempQ, $("Dir"+num2str(i)+"_FitQvector")
//			Duplicate/O TempError, $("Dir"+num2str(i)+"_FitError")

			MskWv =  1+i*2
			
			if (i==1)
				ClrWv=0
			elseif (i==2)
				ClrWv=1.6*1
			elseif(i==3)
				ClrWv=1.6*2
			elseif(i==4)
				ClrWv=1.6*3
			elseif(i==5)
				ClrWv=1.6*4
			elseif(i==6)
				ClrWv=1.6*5
			endif
		else
			break
		endif
	endfor
end

Function ASAS_CorrectWvsForBckg()

	setDataFolder root:Packages:AnisoSAS
	
	variable i
	
	For(i=1;i<=6;i+=1)
		Wave/Z IntOrg=$("Dir"+num2str(i)+"_OrgIntensity")
		
		if (WaveExists(IntOrg))
			Wave IntCorr=$("Dir"+num2str(i)+"_Intensity")
			NVAR Bckg=$("Dir"+num2str(i)+"_Background")
			IntCorr=IntOrg-Bckg			
		endif
	endfor
	
end