#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.12

//*************************************************************************\
//* Copyright (c) 2005 - 2013, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/
//to do: need to handle better the symbols and line types, limit for 8 types is just way too little. 

//2.12 Minor improvement to Countour plot. 
//2.11 added contour plot and basic handling
//2.10 modified to handle different Intensity units for calibration 
//2.09 added units to lookup string so we can propagate them forward. 
//2.08 changed rainbow colorization method to produce prettier color scheme. based on Data manipulation II method (Tishler likely). 
//2.07 modified name of backup waves to use only _B at the end increasing length of names to 30. Should match enforced user length on import now. 
//2.06 modified movie creation to avoid debugger when problems happen. 
//2.05 Added movie creation for 2D and 3D graphs
//2.04 Graph3D modifications and fixes.
//2.03 modifed coloring schemes, support for 2.05 version of IR1_GeneralGraph.ipf
//2.02 added license for ANL


//2.01 8/23/2010 fixed bug when if the General graph was not the top one, some formating was applied to the top graph. Now general graph is made top before formating it. 

	//this string contains formating for the data
//	SVAR ListOfGraphFormating
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//this creates graph, adds data into the graph, synchronizes the formating string and control
//variables and formats the graph
Function IR1P_CreateGraph()
	IR1P_CheckForDataIntegrity()
	Execute ("IR1P_makeGraphWindow()")
	IR1P_CreateDataToPlot()
	IR1P_AddDataToGenGraph()
	IR1P_SynchronizeListAndVars()
	IR1P_UpdateGenGraph()
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_CheckForDataIntegrity()

	SVAR ListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	

	variable i, imax, IsOK, j
	string checkDf, checkEwave
	isOK=1
	imax=ItemsInList(ListOfDataFolderNames)
	For(i=0;i<imax;i+=1)
		checkDF=StringFromList(i,ListOfDataFolderNames)
		j=itemsInList(checkDF,":")
		checkDf=RemoveFromList(StringFromList(j-1,checkDF,":"),checkDf,":")
		if (!DataFolderExists(checkDF))
			IsOk=0
		endif
		Wave/Z TestInt=$(StringByKey("IntWave"+num2str(i),ListOfDataOrgWvNames,"=",";"))
		Wave/Z TestQ=$(StringByKey("QWave"+num2str(i),ListOfDataOrgWvNames,"=",";"))
		Wave/Z TestE=$(StringByKey("EWave"+num2str(i),ListOfDataOrgWvNames,"=",";"))
		checkEwave=StringByKey("EWave"+num2str(i),ListOfDataOrgWvNames,"=",";")
		j = itemsInList(StringByKey("IntWave"+num2str(i),ListOfDataOrgWvNames,"=",";"),":")
		checkEwave=StringFromList(j-1,checkEWave)
		if (strlen(checkEwave)>0)		
			if(!WaveExists(TestInt)||!WaveExists(TestQ)||!WaveExists(TestE))
				IsOk=0
			endif
		else
			if(!WaveExists(TestInt)||!WaveExists(TestQ))
				IsOk=0
			endif
		endif
	endfor
	if (!IsOK)
		Abort "Data integrity compromised, restart the tool and do not modify data while this tool si running"
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//this is added into selection in Marquee.
//if run, sets limits to marquee selection and switches into manual mode for axis range
Function ZoomAndSetLimits(): GraphMarquee
	//this will zoom graph and set limits to the appropriate numbers
	GetMarquee/K left, bottom
	if(!stringmatch(S_MarqueeWin"GeneralGraph"))
		return 0	
	endif
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	ListOfGraphFormating=ReplaceStringByKey("Axis left auto",ListOfGraphFormating,"0","=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis bottom auto",ListOfGraphFormating,"0","=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis left min",ListOfGraphFormating,num2str(V_bottom),"=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis left max",ListOfGraphFormating,num2str(V_top),"=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis bottom min",ListOfGraphFormating,num2str(V_left),"=" )
	ListOfGraphFormating=ReplaceStringByKey("Axis bottom max",ListOfGraphFormating,num2str(V_right),"=" )
	IR1P_SynchronizeListAndVars()
	IR1P_UpdateGenGraph()
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//makes graph 
Proc  IR1P_makeGraphWindow() 
	DoWindow GeneralGraph
	if (V_Flag)
		DoWindow/K generalGraph
	endif
	PauseUpdate; Silent 1		// building window...
	Display /K=1 /W=(285,37.25,756.75,340.25) as "GeneralGraph"
	DoWindow/C GeneralGraph
	showInfo
EndMacro
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//adds data into general graph
Function IR1P_AddDataToGenGraph()

	
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	variable NumberOfWaves,i
	
	string ListOfWaves=TraceNameList("GeneralGraph", ",", 1 )		//list of waves in the graph
	ListOfWaves=TraceNameList("GeneralGraph", ",", 1 )	
	For(i=(ItemsInList(ListOfWaves,",")-1);i>=0;i-=1)
		RemoveFromGraph/W=GeneralGraph $(stringFromList(i,ListOfWaves,","))
	endfor
	
	NumberOfWaves=ItemsInList(ListOfDataFolderNames)
	For(i=0;i<NumberOfWaves;i+=1)
		Wave IntWv=$(StringByKey("IntWave"+num2str(i), ListOfDataWaveNames  , "="))
		Wave QWv=$(StringByKey("QWave"+num2str(i), ListOfDataWaveNames  , "="))
		Wave/Z EWv=$(StringByKey("EWave"+num2str(i), ListOfDataWaveNames  , "="))
		
		AppendToGraph/W=GeneralGraph IntWv vs QWv
	endfor
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//stores pointers to data for the graph from other pieces 
Function IR1P_RecordDataForGraph()
	//here we need to create record of data for plotting in the graph

	setDataFolder root:Packages:GeneralplottingTool
	//these should by now exist, since the previous function checked for their existence...
		SVAR DFloc=root:Packages:GeneralplottingTool:DataFolderName
		SVAR DFInt=root:Packages:GeneralplottingTool:IntensityWaveName
		SVAR DFQ=root:Packages:GeneralplottingTool:QWaveName
		SVAR DFE=root:Packages:GeneralplottingTool:ErrorWaveName
		
		//these strings have to checked and fixed for lieral names, or the code later does not work
		DFInt= possiblyQuoteName(DfInt)
		DFQ= possiblyQuoteName(DfQ)
		DFE= possiblyQuoteName(DfE)
	
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	SVAR ListOfDataFormating=root:Packages:GeneralplottingTool:ListOfDataFormating
	
	variable NumberOfDataPresent,i
	NumberOfDataPresent=ItemsInList(ListOfDataFolderNames)
	For(i=0;i<NumberOfDataPresent;i+=1)
		if(cmpstr(stringfromList(i,ListOfDataFolderNames),DFloc+DFInt)==0)		//same data we are trying to add are present already....
			Abort "These data are already present, cannot display same data twice"
		endif
	endfor

	//OK, these data are not yet in the list, so let's add them in the list as necessary
	//print "Added "+DFloc+DFInt+" to the Plotting tool"
	
	ListOfDataFolderNames+=DFloc+DFInt+";"
	//now add any units in teh last wave added to 
	Wave InputIntWv=$(DFloc+DFInt)
	string NewInputUnit=StringByKey("Units", note(InputIntWv), "=" , ";")
	string LastInputUnit = StringByKey("Units", ListOfDataFormating, "=")
	NVAR DoNotCheckYAxisUnits = root:Packages:GeneralplottingTool:DoNotCheckYAxisUnits
	if(!DoNotCheckYAxisUnits && NumberOfDataPresent>0 && strlen(LastInputUnit)>0 && !stringmatch(LastInputUnit, newInputUnit))
		DoAlert 0, "Units for Y data do not match; prior data: "+LastInputUnit+", new data : "+NewInputUnit+". This message can be disabled in \"Change graph details\"."
	endif
	ListOfDataFormating=ReplaceStringByKey("Units", ListOfDataFormating, newInputUnit , "=")
	ListOfDataOrgWvNames=ReplaceStringByKey("IntWave"+num2str(NumberOfDataPresent), ListOfDataOrgWvNames, DFloc+DFInt , "=")
	ListOfDataOrgWvNames=ReplaceStringByKey("QWave"+num2str(NumberOfDataPresent), ListOfDataOrgWvNames, DFloc+DFQ , "=")
	if (strlen(DFE)>1)
		ListOfDataOrgWvNames=ReplaceStringByKey("EWave"+num2str(NumberOfDataPresent), ListOfDataOrgWvNames, DFloc+DFE , "=")
	else
		ListOfDataOrgWvNames=ReplaceStringByKey("EWave"+num2str(NumberOfDataPresent), ListOfDataOrgWvNames, "---" , "=")
	endif

end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//create data if user wants to plot different type of data than directly int, q and error
Function IR1P_CreateDataToPlot()
	//here we create data to plot, if they do not exist and move appropriate names from ListOfDataOrgWvNames into ListOfDataWaveNames

	SVAR ListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	//this string contains formating for the data
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	//this list cointains follwing list
	//DataX: Q, Q^2, Q^3, Q^4
	//DataY and DataE: I, I^2, I^3, I^4, I*Q^4, I*Q^2, I*Q, ln(I*Q^2), ln(I*Q)
	//here we need to create (if do not exist) these data and write the appropriate names into the appropriate list
	//ListOfDataOrgWvNames contains full path to original waves
	//ListOfDataWaveNames contains full path to ploted waves
	//ListOfGraphFormating contains info, which data should be ploted...
	
	variable i, imax=floor(ItemsInList(ListOfDataOrgWvNames)/3)		//there should be always 3 items in each list per data set ploted + common units added later
	string DataX=stringByKey("DataX", ListOfGraphFormating,"=")
	string DataY=stringByKey("DataY", ListOfGraphFormating,"=")
	string DataE=stringByKey("DataE", ListOfGraphFormating,"=")
	string tempFullName, tempShortName, tempPath, tempQwaveName
	
	For (i=0;i<imax;i+=1)
		//and here we need to take the data and make them as needed
	//	1. Intensity
		tempFullName=stringByKey("IntWave"+num2str(i),ListOfDataOrgWvNames,"=")
		tempQwaveName=stringByKey("QWave"+num2str(i),ListOfDataOrgWvNames,"=")
		tempShortName=StringFromList(itemsInList(tempFullName,":")-1, tempFullName , ":")
		tempPath=tempFullName[0,(strlen(tempFullName)-strlen(tempShortName)-1)]
		Wave IntOrg=$(tempFullName)
		if (cmpstr(DataY,"Y")==0)		//straight, nothing to do really
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")
		elseif(cmpstr(DataY,"Y^2")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_2"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			IntNew=IntNew^2
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"Y^3")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_3"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			IntNew=IntNew^3
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"Y^4")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_4"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			IntNew=IntNew^4
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"1/Y")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_r1"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			IntNew=1/IntNew
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"ln(Y)")==0)		//Want to plot ln(I), create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_lny"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			IntNew=ln(IntNew)
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"sqrt(1/Y)")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_sr1"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			IntNew=sqrt(1/IntNew)
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"ln(Y*X^2)")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_Gu"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			Wave QWvOld=$(tempQwaveName)
			IntNew=ln(QWvOld^2*IntNew)
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"ln(Y*X)")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_LIQ"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			Wave QWvOld=$(tempQwaveName)
			IntNew=ln(QWvOld*IntNew)
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"Y*X^2")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_IQ2"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			Wave QWvOld=$(tempQwaveName)
			IntNew=IntNew * QWvOld^2
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataY,"Y*X^4")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_IQ4"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o IntOrg, $tempFullName
			Wave IntNew=$(tempFullName)
			Wave QWvOld=$(tempQwaveName)
			IntNew=IntNew*QWvOld^4
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		else
			ListOfDataWaveNames=replaceStringByKey("IntWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")
		endif
		
	//	2. Q vector (X axis)
		tempFullName=stringByKey("QWave"+num2str(i),ListOfDataOrgWvNames,"=")
		tempShortName=StringFromList(itemsInList(tempFullName,":")-1, tempFullName , ":")
		tempPath=tempFullName[0,(strlen(tempFullName)-strlen(tempShortName)-1)]
		Wave QOrg=$(tempFullName)
		if (cmpstr(DataX,"X")==0)		//straight, nothing to do really
			ListOfDataWaveNames=replaceStringByKey("QWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")
		elseif(cmpstr(DataX,"X^2")==0)		//Want to plot I^2, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_2"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o QOrg, $tempFullName
			Wave QNew=$(tempFullName)
			QNew=QNew^2
			ListOfDataWaveNames=replaceStringByKey("QWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataX,"X^3")==0)		//Want to plot I^3, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_3"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o QOrg, $tempFullName
			Wave QNew=$(tempFullName)
			QNew=QNew^3
			ListOfDataWaveNames=replaceStringByKey("QWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		elseif(cmpstr(DataX,"X^4")==0)		//Want to plot I^4, create data and name...
			tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
			tempShortName=tempShortName[0,26]	+ "_4"			//Igor names are limited to 30 characters
			tempShortName = possiblyQuoteName(tempShortName)
			tempFullName=tempPath+tempShortName
			Duplicate/o QOrg, $tempFullName
			Wave QNew=$(tempFullName)
			QNew=QNew^4
			ListOfDataWaveNames=replaceStringByKey("QWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
		else
			ListOfDataWaveNames=replaceStringByKey("QWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")
		endif
		
	//	3 errors
		tempFullName=stringByKey("EWave"+num2str(i),ListOfDataOrgWvNames,"=")
		tempShortName=StringFromList(itemsInList(tempFullName,":")-1, tempFullName , ":")
		if(cmpstr(tempShortName,"---")==0 || cmpstr(tempShortName,"'---'")==0)
			ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, "---","=")
		else
			tempPath=tempFullName[0,(strlen(tempFullName)-strlen(tempShortName)-1)]
			Wave EOrg=$(tempFullName)
			if (cmpstr(DataE,"Y")==0)		//straight, nothing to do really
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")
			elseif(cmpstr(DataE,"Y^2")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_2"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				ENew=IRP_ErrorsForPowers(IntOrg, EOrg, 2)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			elseif(cmpstr(DataE,"Y^3")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_3"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				ENew=IRP_ErrorsForPowers(IntOrg, EOrg, 3)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			elseif(cmpstr(DataE,"Y^4")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_4"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				ENew=IRP_ErrorsForPowers(IntOrg, EOrg, 4)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			elseif(cmpstr(DataE,"1/Y")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_r1"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				ENew=IRP_ErrorsForInverse(IntOrg, EOrg)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			elseif(cmpstr(DataE,"ln(Y)")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_lny"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				ENew=IRP_ErrorsForLn(IntNew, ENew)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			elseif(cmpstr(DataE,"sqrt(1/Y)")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_sr1"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				ENew = IRP_ErrorsForInverse(IntOrg, EOrg)
				ENew = IRP_ErrorsForSQRT(IntNew, ENew)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
 			elseif(cmpstr(DataE,"ln(Y*X^2)")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_Gu"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				Wave QWvOld=$(tempQwaveName)
				ENew= EOrg * QWvOld^2
				ENew = IRP_ErrorsForLn(IntNew, ENew)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
 			elseif(cmpstr(DataE,"ln(Y*X)")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_LIQ"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				Wave QWvOld=$(tempQwaveName)
				ENew= EOrg * QWvOld
				ENew = IRP_ErrorsForLn(IntNew, ENew)
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			elseif(cmpstr(DataE,"Y*X^2")==0)		//Want to plot I^2, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_IQ2"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				Wave QWvOld=$(tempQwaveName)
				ENew=ENew * QWvOld^2
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			elseif(cmpstr(DataE,"Y*X^4")==0)		//Want to plot I*Q^4, create data and name...
				tempShortName=IN2G_RemoveExtraQuote(tempShortName,1,1)
				tempShortName=tempShortName[0,26]	+ "_IQ4"			//Igor names are limited to 30 characters
				tempShortName = possiblyQuoteName(tempShortName)
				tempFullName=tempPath+tempShortName
				Duplicate/o EOrg, $tempFullName
				Wave ENew=$(tempFullName)
				Wave QWvOld=$(tempQwaveName)
				ENew=ENew * QWvOld^4
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")		
			else
				ListOfDataWaveNames=replaceStringByKey("EWave"+num2str(i),ListOfDataWaveNames, tempFullName,"=")
			endif
		endif
	
	endfor
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//checbox control procedure
Function IR1P_GenPlotCheckBox(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	
	SVAR 	ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating

	if (cmpstr("GraphErrors",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("ErrorBars",ListOfGraphFormating, num2str(checked),"=")
	endif
	if (cmpstr("DisplayTimeAndDate",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("DisplayTimeAndDate",ListOfGraphFormating, num2str(checked),"=")
	endif

	if (cmpstr("GraphLogX",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("log(bottom)",ListOfGraphFormating, num2str(checked),"=")
		IR1P_ChangeToUserPlotType()
	endif
	if (cmpstr("GraphXMajorGrid",ctrlName)==0)
		//anything needs to be done here?   
		NVAR GraphXMajorGrid=root:Packages:GeneralplottingTool:GraphXMajorGrid
		NVAR GraphXMinorGrid=root:Packages:GeneralplottingTool:GraphXMinorGrid
		if (GraphXMajorGrid)
			if(GraphXMinorGrid)
				ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "1","=")
			else
				ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "2","=")
			endif
		else
			ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "0","=")
			GraphXMinorGrid=0
		endif
	endif
	if (cmpstr("GraphXMinorGrid",ctrlName)==0)
		//anything needs to be done here?
		NVAR GraphXMajorGrid=root:Packages:GeneralplottingTool:GraphXMajorGrid
		NVAR GraphXMinorGrid=root:Packages:GeneralplottingTool:GraphXMinorGrid
		ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "0","=")
		if (GraphXMinorGrid)
			GraphXMajorGrid=1
			ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "1","=")
		else
			if(GraphXMajorGrid) 
				ListOfGraphFormating=ReplaceStringByKey("grid(bottom)",ListOfGraphFormating, "2","=")
			endif
		endif
	endif
	if (cmpstr("GraphXMirrorAxis",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("mirror(bottom)",ListOfGraphFormating, num2str(checked),"=")
	endif


	if (cmpstr("GraphLogY",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("log(left)",ListOfGraphFormating, num2str(checked),"=")
		IR1P_ChangeToUserPlotType()
	endif
	if (cmpstr("GraphYMajorGrid",ctrlName)==0)
		//anything needs to be done here?
		NVAR GraphYMajorGrid=root:Packages:GeneralplottingTool:GraphYMajorGrid
		NVAR GraphYMinorGrid=root:Packages:GeneralplottingTool:GraphYMinorGrid
		if (GraphYMajorGrid)
			if(GraphYMinorGrid)
				ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "1","=")
			else
				ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "2","=")
			endif
		else
			ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "0","=")
			GraphYMinorGrid=0
		endif
	endif
	if (cmpstr("GraphYMinorGrid",ctrlName)==0)
		//anything needs to be done here?
		NVAR GraphYMajorGrid=root:Packages:GeneralplottingTool:GraphYMajorGrid
		NVAR GraphYMinorGrid=root:Packages:GeneralplottingTool:GraphYMinorGrid
		ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "0","=")
		if (GraphYMinorGrid)
			GraphYMajorGrid=1
			ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "1","=")
		else
			if(GraphYMajorGrid) 
				ListOfGraphFormating=ReplaceStringByKey("grid(left)",ListOfGraphFormating, "2","=")
			endif
		endif
	endif
	if (cmpstr("GraphYMirrorAxis",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("mirror(left)",ListOfGraphFormating, num2str(checked),"=")
	endif
	if (cmpstr("GraphLegend",ctrlName)==0)
		//anything needs to be done here?
		if(checked)
			NVAR GraphLegendUseFolderNms=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
			NVAR GraphLegendUseWaveNote=root:Packages:GeneralplottingTool:GraphLegendUseWaveNote
			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(checked+GraphLegendUseFolderNms+2*GraphLegendUseWaveNote),"=")
		else
			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(checked),"=")
		endif
	endif
	variable UseLegend
	if (cmpstr("GraphLegendUseFolderNms",ctrlName)==0)
		//anything needs to be done here?
		UseLegend=NumberByKey("Legend",ListOfGraphFormating,"=")
		if (UseLegend)
			NVAR GraphLegendUseFolderNms=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
			NVAR GraphLegendUseWaveNote=root:Packages:GeneralplottingTool:GraphLegendUseWaveNote
			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(1+GraphLegendUseFolderNms+2*GraphLegendUseWaveNote),"=")
		endif
	endif
	if (cmpstr("GraphLegendUseWaveNote",ctrlName)==0)
		//anything needs to be done here?
		UseLegend=NumberByKey("Legend",ListOfGraphFormating,"=")
		if (UseLegend)
			NVAR GraphLegendUseFolderNms=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
			NVAR GraphLegendUseWaveNote=root:Packages:GeneralplottingTool:GraphLegendUseWaveNote
			ListOfGraphFormating=ReplaceStringByKey("Legend",ListOfGraphFormating, num2str(1+GraphLegendUseFolderNms+2*GraphLegendUseWaveNote),"=")
		endif
	endif

	if (cmpstr("GraphLegendFrame",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph Legend Frame",ListOfGraphFormating, num2str(checked),"=")
	endif
	if (cmpstr("GraphUseRainbow",ctrlName)==0)
		NVAR GraphUseBW = root:Packages:GeneralplottingTool:GraphUseBW	
		NVAR GraphUseColors = root:Packages:GeneralplottingTool:GraphUseColors	
		NVAR GraphUseRainbow = root:Packages:GeneralplottingTool:GraphUseRainbow	
		if(checked)
			GraphUseColors=0
			GraphUseBW = 0
		endif
		if(!GraphUseRainbow)
			IR1P_GraphUseColorsOld(GraphUseColors, GraphUseBW)
		else
			IR1P_GraphUseRainbow(GraphUseRainbow, GraphUseBW)
		endif
		ListOfGraphFormating=ReplaceStringByKey("Graph use Rainbow",ListOfGraphFormating, num2str(GraphUseRainbow),"=")
		ListOfGraphFormating=ReplaceStringByKey("Graph use Colors",ListOfGraphFormating, num2str(GraphUseColors),"=")
		ListOfGraphFormating=ReplaceStringByKey("Graph use BW",ListOfGraphFormating, num2str(GraphUseBW),"=")
	endif
	
	if (cmpstr("GraphUseColors",ctrlName)==0)
		//anything needs to be done here?
		NVAR GraphUseBW = root:Packages:GeneralplottingTool:GraphUseBW
		NVAR GraphUseColors = root:Packages:GeneralplottingTool:GraphUseColors	
		NVAR GraphUseRainbow = root:Packages:GeneralplottingTool:GraphUseRainbow	
		if(checked)
			GraphUseBW = 0
			GraphUseRainbow = 0
		endif
		if(!GraphUseRainbow)
			IR1P_GraphUseColorsOld(GraphUseColors, GraphUseBW)
		else
			IR1P_GraphUseRainbow(GraphUseRainbow * GraphUseColors, GraphUseBW)
		endif
		ListOfGraphFormating=ReplaceStringByKey("Graph use Rainbow",ListOfGraphFormating, num2str(GraphUseRainbow),"=")
		ListOfGraphFormating=ReplaceStringByKey("Graph use Colors",ListOfGraphFormating, num2str(GraphUseColors),"=")
		ListOfGraphFormating=ReplaceStringByKey("Graph use BW",ListOfGraphFormating, num2str(GraphUseBW),"=")
	endif
	if (cmpstr("GraphUseBW",ctrlName)==0)
		//anything needs to be done here?
		NVAR GraphUseBW = root:Packages:GeneralplottingTool:GraphUseBW
		NVAR GraphUseColors = root:Packages:GeneralplottingTool:GraphUseColors	
		NVAR GraphUseRainbow = root:Packages:GeneralplottingTool:GraphUseRainbow	
		if(checked)
			GraphUseColors = 0
			GraphUseRainbow = 0
		endif
		if(!GraphUseRainbow)
			IR1P_GraphUseColorsOld(GraphUseColors, GraphUseBW)
		else
			IR1P_GraphUseRainbow(GraphUseRainbow * GraphUseColors, GraphUseBW)
		endif
		ListOfGraphFormating=ReplaceStringByKey("Graph use Rainbow",ListOfGraphFormating, num2str(GraphUseRainbow),"=")
		ListOfGraphFormating=ReplaceStringByKey("Graph use Colors",ListOfGraphFormating, num2str(GraphUseColors),"=")
		ListOfGraphFormating=ReplaceStringByKey("Graph use BW",ListOfGraphFormating, num2str(GraphUseBW),"=")
	endif

	if (cmpstr("GraphUseSymbols",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph use Symbols",ListOfGraphFormating, num2str(checked),"=")
		variable UseLinesAlso=NumberByKey("Graph use Lines",ListOfGraphFormating,"=",";")

		if ((checked==1)&&(UseLinesAlso==1))
			IR1P_SetSymbolsAndLines()	
		else
			ListOfGraphFormating=ReplaceStringByKey("Graph use Lines",ListOfGraphFormating, "1","=")
			NVAR GraphUseLines=root:Packages:GeneralplottingTool:GraphUseLines
			GraphUseLines=1
			IR1P_SetSymbolsAndLines()
		endif
	endif
	if (cmpstr("GraphVarySymbols",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph vary Symbols",ListOfGraphFormating, num2str(checked),"=")
		IR1P_SetSymbolsAndLines()			
	endif
	if (cmpstr("GraphUseSymbolSet1",ctrlName)==0)
		ListOfGraphFormating=ReplaceStringByKey("GraphUseSymbolSet1",ListOfGraphFormating, num2str(checked),"=")
		if (checked)
			NVAR GraphUseSymbolSet2=root:Packages:GeneralplottingTool:GraphUseSymbolSet2
			GraphUseSymbolSet2=0
			ListOfGraphFormating=ReplaceStringByKey("GraphUseSymbolSet2",ListOfGraphFormating, "0","=")
		endif
		IR1P_SetSymbolsAndLines()
	endif
	if (cmpstr("GraphUseSymbolSet2",ctrlName)==0)
		ListOfGraphFormating=ReplaceStringByKey("GraphUseSymbolSet2",ListOfGraphFormating, num2str(checked),"=")
		if (checked)
			NVAR GraphUseSymbolSet1=root:Packages:GeneralplottingTool:GraphUseSymbolSet1
			GraphUseSymbolSet1=0
			ListOfGraphFormating=ReplaceStringByKey("GraphUseSymbolSet1",ListOfGraphFormating, "0","=")
		endif
		IR1P_SetSymbolsAndLines()
	endif
	
	if (cmpstr("GraphVaryLines",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph vary Lines",ListOfGraphFormating, num2str(checked),"=")
		if (checked==1)
			ListOfGraphFormating=ReplaceStringByKey("lStyle[0]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[1]",ListOfGraphFormating, "1","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[2]",ListOfGraphFormating, "2","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[3]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[4]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[5]",ListOfGraphFormating, "5","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[6]",ListOfGraphFormating, "6","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[7]",ListOfGraphFormating, "7","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[8]",ListOfGraphFormating, "8","=")
		else
			ListOfGraphFormating=ReplaceStringByKey("lStyle[0]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[1]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[2]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[3]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[4]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[5]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[6]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[7]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("lStyle[8]",ListOfGraphFormating, "0","=")
		endif
	endif

	if (cmpstr("GraphUseLines",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Graph use Lines",ListOfGraphFormating, num2str(checked),"=")
		variable UseSymbolsAlso=NumberByKey("Graph use Symbols",ListOfGraphFormating,"=",";")
		if ((checked==1)&&(UseSymbolsAlso==1))
			ListOfGraphFormating=ReplaceStringByKey("mode[0]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[1]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[2]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[3]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[4]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[5]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[6]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[7]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[8]",ListOfGraphFormating, "4","=")
		else
			ListOfGraphFormating=ReplaceStringByKey("Graph use Symbols",ListOfGraphFormating, "1","=")
			NVAR GraphUseSymbols=root:Packages:GeneralplottingTool:GraphUseSymbols
			GraphUseSymbols=1
			ListOfGraphFormating=ReplaceStringByKey("mode[0]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[1]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[2]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[3]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[4]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[5]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[6]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[7]",ListOfGraphFormating, "3","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[8]",ListOfGraphFormating, "3","=")
		endif
	endif


	if (cmpstr("GraphLeftAxisAuto",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Axis left auto",ListOfGraphFormating, num2str(checked),"=")
	endif
	if (cmpstr("GraphBottomAxisAuto",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Axis bottom auto",ListOfGraphFormating, num2str(checked),"=")
	endif
	if (cmpstr("GraphAxisStandoff",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("standoff",ListOfGraphFormating, num2str(checked),"=")
	endif
	if (cmpstr("GraphTicksIn",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("tick",ListOfGraphFormating, num2str(2*checked),"=")
	endif
	if (cmpstr("GraphLegendShortNms",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("GraphLegendShortNms",ListOfGraphFormating, num2str(checked),"=")
	endif

DoUpdate

	//And here we should update everytime
	IR1P_UpdateGenGraph()
	
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR1P_GraphUseColorsOld(checked, GraphUseBW)
	variable checked, GraphUseBW

	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	ListOfGraphFormating=ReplaceStringByKey("Graph use Colors",ListOfGraphFormating, num2str(checked),"=")
	variable i
	
		if (checked==1)
			ListOfGraphFormating=ReplaceStringByKey("rgb[0]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[1]",ListOfGraphFormating, "(0,0,65280)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[2]",ListOfGraphFormating, "(0,65280,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[3]",ListOfGraphFormating, "(32680,32680,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[4]",ListOfGraphFormating, "(0,32680,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[5]",ListOfGraphFormating, "(32680,0,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[6]",ListOfGraphFormating, "(32680,32680,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[7]",ListOfGraphFormating, "(65280,32680,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[8]",ListOfGraphFormating, "(32680,32680,65280)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[9]",ListOfGraphFormating, "(65280,0,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[10]",ListOfGraphFormating, "(0,0,65280)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[11]",ListOfGraphFormating, "(32680,32680,65280)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[12]",ListOfGraphFormating, "(0,65280,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[13]",ListOfGraphFormating, "(32680,32680,0)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[14]",ListOfGraphFormating, "(0,32680,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[15]",ListOfGraphFormating, "(32680,0,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[16]",ListOfGraphFormating, "(32680,32680,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[17]",ListOfGraphFormating, "(65280,32680,32680)","=")
			ListOfGraphFormating=ReplaceStringByKey("rgb[18]",ListOfGraphFormating, "(32680,32680,65280)","=")
		else
		string ColorCode
		if(GraphUseBW)
			ColorCode = "(0,0,0)"
		else
			ColorCode="(65280,0,0)"
		endif
		    For(i=0;i<256;i+=1)
			ListOfGraphFormating=ReplaceStringByKey("rgb["+num2str(i)+"]",ListOfGraphFormating,ColorCode ,"=")
		    endfor
		endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

static Function IR1P_GraphUseRainbow(checked, GraphUseBW)
	variable checked, GraphUseBW

	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	//ListOfGraphFormating=ReplaceStringByKey("Graph use Colors",ListOfGraphFormating, num2str(checked),"=")
      variable NumberOfWaves=ItemsInList(ListOfDataFolderNames)
	Variable i
		if (checked==1)
// 	       Variable i, NumTraces, iRed, iBlue, iGreen, io, w, Red, Blue, Green,  ColorNorm
//              w = NumberOfWaves/2
//	        For(i=0;i<NumberOfWaves;i+=1)
//                      io = 0
//	                iRed = exp(-(i-io)^2/w)
//	                io = NumberOfWaves/2
//	                iBlue = exp(-(i-io)^2/w)
//	                io = NumberOfWaves
//	                iGreen = exp(-(i-io)^2/w)
//     	                ColorNorm = sqrt(iRed^2 + iBlue^2 + iGreen^2)	
//	                Red = 65535 * (iRed/ColorNorm)
//	                Blue = 65535 * (iBlue/ColorNorm)
//	                Green = 65535 * (iGreen/ColorNorm)
//	               // print "("+num2str(Red)+","+num2str(Blue)+","+num2str(Green)+")"
//			    ListOfGraphFormating=ReplaceStringByKey("rgb["+num2str(i)+"]",ListOfGraphFormating, "("+num2str(Red)+","+num2str(Blue)+","+num2str(Green)+")","=")
//		    endfor
 			//requested 2013-02 : use prettier method from Data manipualtion II
 		    	   //Variable k, km, rev=0
			    variable r,g,b,scale
			   // k = NumberOfWaves
			   // km = k
			    colortab2wave Rainbow
			    wave M_colors
			   // do
			    For(i=0;i<NumberOfWaves;i+=1)
			       // k-=1
			        //scale = (rev==0 ? k : (km-k-1))  / (km-1) * dimsize(M_colors,0)
			        scale =  (NumberOfWaves-i)  / (NumberOfWaves-1) * dimsize(M_colors,0)
			        r = M_colors[scale][0]
			        g = M_colors[scale][1]
			        b = M_colors[scale][2]
				  ListOfGraphFormating=ReplaceStringByKey("rgb["+num2str(i)+"]",ListOfGraphFormating, "("+num2str(r)+","+num2str(g)+","+num2str(b)+")","=")
			       // ModifyGraph/Z rgb[k]=( r, g, b )
			    //while(k>0)
			    endfor
			    killwaves/Z M_colors
			
		else
			string ColorCode
			if(GraphUseBW)
				ColorCode = "(0,0,0)"
			else
				ColorCode="(65280,0,0)"
			endif
		    For(i=0;i<256;i+=1)
			ListOfGraphFormating=ReplaceStringByKey("rgb["+num2str(i)+"]",ListOfGraphFormating,ColorCode ,"=")
		    endfor
		endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//SetVar procedure 
Function  IR1P_SetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	SVAR 	ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	
	if (cmpstr("GraphXAxisName",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Label bottom",ListOfGraphFormating, varStr,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("Xoffset",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Xoffset",ListOfGraphFormating, varStr,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("Yoffset",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Yoffset",ListOfGraphFormating, varStr,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("GraphYAxisName",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceStringByKey("Label left",ListOfGraphFormating, varStr,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("GraphLineWidth",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("lsize",ListOfGraphFormating, varNum,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("GraphSymbolSize",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("msize",ListOfGraphFormating, varNum,"=")
		DoWindow/F IR1P_ControlPanel
	endif

	if (cmpstr("GraphLeftAxisMin",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("Axis left min",ListOfGraphFormating, varNum,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("GraphLeftAxisMax",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("Axis left max",ListOfGraphFormating, varNum,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("GraphBottomAxisMin",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom min",ListOfGraphFormating, varNum,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("GraphBottomAxisMax",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom max",ListOfGraphFormating, varNum,"=")
		DoWindow/F IR1P_ControlPanel
	endif
	if (cmpstr("GraphAxisWidth",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("axThick",ListOfGraphFormating, varNum,"=")
	endif
	if (cmpstr("GraphWindowWidth",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("Graph Window Width",ListOfGraphFormating, varNum,"=")
	endif
	if (cmpstr("GraphWindowHeight",ctrlName)==0)
		//anything needs to be done here?
		ListOfGraphFormating=ReplaceNumberByKey("Graph Window Height",ListOfGraphFormating, varNum,"=")
	endif
	//this part belongs to modify data panel
	if (cmpstr("ModifyDataMultiplier",ctrlName)==0)
		//anything needs to be done here?
		IR1P_RecalcModifyData()
	endif
	if (cmpstr("ModifyDataBackground",ctrlName)==0)
		//anything needs to be done here?
		IR1P_RecalcModifyData()
	endif
	if (cmpstr("ModifyDataQshift",ctrlName)==0)
		//anything needs to be done here?
		IR1P_RecalcModifyData()
	endif
	if (cmpstr("ModifyDataErrorMult",ctrlName)==0)
		//anything needs to be done here?
		IR1P_RecalcModifyData()
	endif
	
	
	//And here we should update everytime
	IR1P_UpdateGenGraph()
End

//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************

Function IR1P_SetGraphSize(left,top, right,bottom)
		variable left, top, right, bottom
		
		MoveWindow /W=GeneralGraph left, top, right, bottom
		AutopositionWindow /M=0 /R=IR1P_ControlPanel GeneralGraph
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//update all function...
Function IR1P_UpdateGenGraph()

	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
	variable i, imax=ItemsInList(ListOfGraphFormating,";"), j
	string ListOfWaves
	variable Xofst, Yofst
	DoWindow GeneralGraph
	if (!V_Flag)
		abort
	endif
	//User could change the type of graph on us, so we also need to recalculate the data...
	IR1P_CheckForDataIntegrity()
	IR1P_CreateDataToPlot()
	IR1P_AddDataToGenGraph()
	IR1P_FixAxesInGraph()
	IR1P_SetGraphSize(0,0, NumberByKey("Graph Window Width", ListOfGraphFormating,"=",";"),NumberByKey("Graph Window Height", ListOfGraphFormating,"=",";"))
	//done
	DoWindow generalGraph
	if (V_Flag)
		DoWindow/F generalGraph
		ListOfWaves=TraceNameList("generalGraph", ";", 1 )
		For(i=0;i<imax;i+=1)
//			Dowindow/F generalGraph
			if(cmpstr(StringFromList(i,ListOfGraphFormating)[0,4],"Label")==0)
				Execute (IN2G_ChangePartsOfString(StringFromList(i,ListOfGraphFormating),"="," \"")+"\"")	
			elseif (cmpstr(StringFromList(i,ListOfGraphFormating)[0,5],"Legend")==0)
				IR1P_AttachLegend(NumberByKey("Legend",ListOfGraphFormating,"="))
			elseif(cmpstr(StringFromList(i,ListOfGraphFormating)[0,8],"ErrorBars")==0)
				//attach error bars or remove them
				IR1P_AttachErrorBars(NumberByKey("ErrorBars",ListOfGraphFormating,"="))
			elseif(cmpstr(StringFromList(i,ListOfGraphFormating)[0,3],"Data")==0)
				//these lines contain data formating (which data are plot) and this macro needs to skip them
			elseif(cmpstr(StringFromList(i,ListOfGraphFormating)[0,4],"Graph")==0)
				//these lines contain some other graph formating and this macro needs to skip them
			elseif(cmpstr(StringFromList(i,ListOfGraphFormating)[0,17],"DisplayTimeAndDate")==0)
				//these lines contain some other graph formating and this macro needs to skip them
				if(NumberByKey("DisplayTimeAndDate", ListOfGraphFormating,"=",";"))
					TextBox/W=GeneralGraph/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()		
				else
					TextBox/W=GeneralGraph/K/N=DateTimeTag
				endif
			elseif(cmpstr(StringFromList(i,ListOfGraphFormating)[0,3],"Axis")==0)
				//these lines contain axis formating (about axis ranges) and this macro needs to skip them
			elseif(cmpstr(StringFromList(i,ListOfGraphFormating)[0,6],"Xoffset")==0 || cmpstr(StringFromList(i,ListOfGraphFormating)[0,6],"Yoffset")==0)
				//these lines contain axis formating (about axis ranges) and this macro needs to skip them
			else
				Execute ("ModifyGraph /Z "+StringFromList(i,ListOfGraphFormating))
			endif
		endfor
		SVAR ListOfWavesNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
		variable tempXLin, tempXlog, tempYLin, tempYlog
		For(j=0;j<ItemsInList(ListOfWaves);j+=1)
			//change 12 1 2006, Igor 6 now has multiplicative offset...
			if(NumberByKey("IGORVERS", IgorInfo(0) )< 6)	//Igor 5 only
				Xofst=numberByKey("Xoffset",ListOfGraphFormating,"=")*j
				Yofst=numberByKey("Yoffset",ListOfGraphFormating,"=")*j
				Xofst = numtype(Xofst)==0 ?  Xofst : 0
				Yofst = numtype(Yofst)==0 ? Yofst : 0
				ModifyGraph/W=GeneralGraph offset($(stringFromList(j,ListOfWaves)))={Xofst,Yofst}
			else	//Igor 6, so need to check what is axis
				//log(bottom)=1;log(left)=1
				
				if(NumberByKey("log(bottom)", ListOfGraphFormating ,"="))	//log x axis
					Xofst=numberByKey("Xoffset",ListOfGraphFormating,"=")^j
					Xofst = numtype(Xofst)==0 ?  Xofst : 0
					tempXLin = 0
					tempXlog = Xofst
				else
					Xofst=numberByKey("Xoffset",ListOfGraphFormating,"=")*j
					Xofst = numtype(Xofst)==0 ?  Xofst : 0
					tempXLin = Xofst
					tempXlog = 0
				endif
				if(NumberByKey("log(left)", ListOfGraphFormating ,"="))	//log x axis
					Yofst=numberByKey("Yoffset",ListOfGraphFormating,"=")^j
					Yofst = numtype(Yofst)==0 ? Yofst : 0
					tempYLin = 0
					tempYLog = Yofst
				else
					Yofst=numberByKey("Yoffset",ListOfGraphFormating,"=")*j
					Yofst = numtype(Yofst)==0 ? Yofst : 0
					tempYLin = Yofst
					tempYLog = 0
				endif
				Execute("ModifyGraph/W=GeneralGraph offset("+stringFromList(j,ListOfWaves)+")={"+num2str(tempXLin)+","+num2str(tempYLin)+"},muloffset("+stringFromList(j,ListOfWaves)+")={"+num2str(tempXLog)+","+num2str(tempYLog)+"}")
				//ModifyGraph muloffset(SMR_Int#1)={2,2}
			endif
		endfor
	endif
	//and if 3d graph exists, let's update it also...
	IR1P_UpdateColorAndFormat3DPlot(1)
	//print "update now"
	DoUpdate
//	DOWIndow/F IR1P_ControlPanel
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//Legend handling
Function IR1P_AttachLegend(addOrRemove)
		variable addOrRemove

	if (addOrRemove>0)
		SVAR ListOfWavesNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
		SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
		string ListOfWaves=TraceNameList("GeneralGraph", ";", 1 )		//list of waves in the graph
		variable i, imax, test2
		string FontSize, test1, test3
		imax=ItemsInList(ListOfWavesNames , ";")
		SVAR GraphLegendPosition=root:Packages:GeneralplottingTool:GraphlegendPosition
		NVAR GraphLegendFrame=root:Packages:GeneralplottingTool:GraphLegendFrame
		NVAR GraphLegendShortNms=root:Packages:GeneralplottingTool:GraphLegendShortNms
				
		string text0=""
		For(i=0;i<imax;i+=1)
			if(addOrRemove==1)		//if 1 use only wave names, if 2 use full folder structure for legend
					test1=StringFromList(i, ListOfWavesNames)
					test2=ItemsInList(StringFromList(i, ListOfWavesNames),":")
//					test3=StringFromList(ItemsInList(StringFromList(i, ListOfWavesNames),":")-1,StringFromList(i, ListOfWavesNames))
					FontSize = stringByKey("Graph Legend Size", ListOfGraphFormating, "=",";")
					text0+="\\Z"+FontSize+"\\s("+StringFromList(i, ListOfWaves)+") "+StringFromList(ItemsInList(StringFromList(i, ListOfWavesNames),":")-1,StringFromList(i, ListOfWavesNames),":")
			else
				if (GraphLegendShortNms)
					test1=StringFromList(i, ListOfWavesNames)
					test2=ItemsInList(StringFromList(i, ListOfWavesNames),":")
//					test3=StringFromList(ItemsInList(StringFromList(i, ListOfWavesNames),":")-1,StringFromList(i, ListOfWavesNames))
					FontSize = stringByKey("Graph Legend Size", ListOfGraphFormating, "=",";")
					string longname=StringFromList(ItemsInList(StringFromList(i, ListOfWavesNames),":")-2,StringFromList(i, ListOfWavesNames),":")
//					text0+="\\Z"+FontSize+"\\s("+StringFromList(i, ListOfWaves)+") "+StringFromList(ItemsInList(LongName,":")-2,Longname,":")
					text0+="\\Z"+FontSize+"\\s("+StringFromList(i, ListOfWaves)+") "+Longname
				else
					FontSize = stringByKey("Graph Legend Size", ListOfGraphFormating, "=",";")
					text0+="\\Z"+FontSize+"\\s("+StringFromList(i, ListOfWaves)+") "+StringFromList(i, ListOfWavesNames)
				endif
			endif
			if (i<imax-1)
				text0+="\r"
			endif
		endfor
		Legend/C/N=text0/W=GeneralGraph/A=$(GraphLegendPosition)/J/F=(2*GraphLegendFrame) text0
	else
		Execute("Legend/W=GeneralGraph/K/N=text0")
	endif	
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//error bars handling
Function IR1P_AttachErrorBars(addOrRemove)
	variable addOrRemove
	
	variable i, imax
	string ListOfWaves=TraceNameList("GeneralGraph", ";", 1 )		//list of waves in the graph
	SVAR ListOfWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	imax=ItemsInList(ListOfWaves , ";")
	if (addOrRemove)
		For(i=0;i<imax;i+=1)
			if(WaveExists($(StringByKey("EWave"+num2str(i), ListOfWaveNames, "="))))
				ErrorBars/W=GeneralGraph $(StringFromList(i, ListOfWaves)) Y,wave=($(StringByKey("EWave"+num2str(i), ListOfWaveNames, "=")),$(StringByKey("EWave"+num2str(i), ListOfWaveNames, "=")))
			else			//no errors given by user, cannot display
				ErrorBars/W=GeneralGraph $(StringFromList(i, ListOfWaves)) OFF
			endif
		endfor
	else
		For(i=0;i<imax;i+=1)
			ErrorBars/W=GeneralGraph $(StringFromList(i, ListOfWaves)) OFF
		endfor
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//apply selected style function. Copies string with graph & data formating into current formating string 
//and updates the graph as necessary
Function IR1P_ApplySelectedStyle(StyleString)
	string StyleString
	
	if (cmpstr("NewUserStyle",StyleString)!=0)
		SVAR StringToApply=$("root:Packages:plottingToolsStyles:"+possiblyQuoteName(StyleString))
		SVAR FormatingString=root:Packages:GeneralplottingTool:ListOfGraphFormating
		FormatingString=StringToApply
		IR1P_SynchronizeListAndVars()
		IR1P_UpdateGenGraph()
		NVAR LegendYes=root:Packages:GeneralplottingTool:GraphLegend
		NVAR LongLegend=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
		if (LegendYes)
			LegendYes+=LongLegend
		endif
		IR1P_AttachLegend(LegendYes)
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//very important. The string with graph formating is primary record of the graph style. This
//function must synchronize the variables used to control GUI 
Function IR1P_SynchronizeListAndVars()
	
	SVAR FormatingStr=root:Packages:GeneralplottingTool:ListOfGraphFormating
	SVAR GraphXAxisName=root:Packages:GeneralplottingTool:GraphXAxisName
	SVAR GraphYAxisName=root:Packages:GeneralplottingTool:GraphYAxisName

	NVAR GraphLogX=root:Packages:GeneralplottingTool:GraphLogX
	NVAR GraphLogY=root:Packages:GeneralplottingTool:GraphLogY
	NVAR GraphErrors=root:Packages:GeneralplottingTool:GraphErrors

	NVAR GraphLegend=root:Packages:GeneralplottingTool:GraphLegend
	NVAR GraphLegendUseFolderNms=root:Packages:GeneralplottingTool:GraphLegendUseFolderNms
	NVAR GraphUseColors=root:Packages:GeneralplottingTool:GraphUseColors
	NVAR GraphUseSymbols=root:Packages:GeneralplottingTool:GraphUseSymbols

	NVAR GraphXMajorGrid=root:Packages:GeneralplottingTool:GraphXMajorGrid
	NVAR GraphXMinorGrid=root:Packages:GeneralplottingTool:GraphXMinorGrid
	NVAR GraphYMajorGrid=root:Packages:GeneralplottingTool:GraphYMajorGrid
	NVAR GraphYMinorGrid=root:Packages:GeneralplottingTool:GraphYMinorGrid
	NVAR GraphXMirrorAxis=root:Packages:GeneralplottingTool:GraphXMirrorAxis
	NVAR GraphYMirrorAxis=root:Packages:GeneralplottingTool:GraphYMirrorAxis
	
	NVAR GraphLeftAxisAuto=root:Packages:GeneralplottingTool:GraphLeftAxisAuto
	NVAR GraphLeftAxisMin=root:Packages:GeneralplottingTool:GraphLeftAxisMin
	NVAR GraphLeftAxisMax=root:Packages:GeneralplottingTool:GraphLeftAxisMax
	NVAR GraphBottomAxisAuto=root:Packages:GeneralplottingTool:GraphBottomAxisAuto
	NVAR GraphBottomAxisMin=root:Packages:GeneralplottingTool:GraphBottomAxisMin
	NVAR GraphBottomAxisMax=root:Packages:GeneralplottingTool:GraphBottomAxisMax
	NVAR GraphAxisStandoff=root:Packages:GeneralplottingTool:GraphAxisStandoff
	NVAR GraphUseLines=root:Packages:GeneralplottingTool:GraphUseLines
	NVAR GraphSymbolSize=root:Packages:GeneralplottingTool:GraphSymbolSize
	NVAR GraphVarySymbols=root:Packages:GeneralplottingTool:GraphVarySymbols
	NVAR GraphVaryLines=root:Packages:GeneralplottingTool:GraphVaryLines
	NVAR GraphAxisWidth=root:Packages:GeneralplottingTool:GraphAxisWidth
	NVAR GraphWindowWidth=root:Packages:GeneralplottingTool:GraphWindowWidth
	NVAR GraphWindowHeight=root:Packages:GeneralplottingTool:GraphWindowHeight
	NVAR GraphTicksIn=root:Packages:GeneralplottingTool:GraphTicksIn
	NVAR GraphLegendFrame=root:Packages:GeneralplottingTool:GraphLegendFrame
	NVAR GraphLegendShortNms=root:Packages:GeneralplottingTool:GraphLegendShortNms

	NVAR GraphUseBW = root:Packages:GeneralplottingTool:GraphUseBW
	NVAR GraphUseRainbow = root:Packages:GeneralplottingTool:GraphUseRainbow	
	
	SVAR GraphLegendPosition=root:Packages:GeneralplottingTool:GraphLegendPosition

	SVAR Graph3DColorScale = root:Packages:GeneralplottingTool:Graph3DColorScale
	SVAR Graph3DVisibility=root:Packages:GeneralplottingTool:Graph3DVisibility
	NVAR Graph3DAngle=root:Packages:GeneralplottingTool:Graph3DAngle
	NVAR Graph3DAxLength=root:Packages:GeneralplottingTool:Graph3DAxLength
	NVAR Graph3DClrMin = root:Packages:GeneralplottingTool:Graph3DClrMin
	NVAR Graph3DClrMax = root:Packages:GeneralplottingTool:Graph3DClrMax
	NVAR Graph3DLogColors = root:Packages:GeneralplottingTool:Graph3DLogColors
	NVAR Graph3DColorsReverse = root:Packages:GeneralplottingTool:Graph3DColorsReverse

	Graph3DColorScale=StringByKey("Graph3D Color Scale", FormatingStr, "=")
	Graph3DVisibility=StringByKey("Graph3D Visibility", FormatingStr, "=")
	Graph3DAngle=NumberByKey("Graph3D Angle", FormatingStr, "=")
	Graph3DAxLength=NumberByKey("Graph3D Ax Length", FormatingStr, "=")
	Graph3DClrMin=NumberByKey("Graph3D Clr Min", FormatingStr, "=")
	Graph3DClrMax=NumberByKey("Graph3D Clr Max", FormatingStr, "=")
	Graph3DLogColors=NumberByKey("Graph3D Log Colors", FormatingStr, "=")
	Graph3DColorsReverse=NumberByKey("Graph3D Colors Reverse", FormatingStr, "=")
	GraphLegendPosition=StringByKey("Graph Legend Position", FormatingStr, "=")
	
	GraphLegendFrame=NumberByKey("Graph Legend Frame", FormatingStr, "=")
	GraphUseLines=NumberByKey("Graph use Lines", FormatingStr, "=")
	GraphSymbolSize=NumberByKey("msize", FormatingStr, "=")
	GraphVarySymbols=NumberByKey("Graph Vary Symbols", FormatingStr, "=")
	GraphVaryLines=NumberByKey("Graph vary Lines", FormatingStr, "=")
	GraphAxisWidth=NumberByKey("axThick", FormatingStr, "=")
	GraphWindowWidth=NumberByKey("Graph Window width", FormatingStr, "=")
	GraphWindowHeight=NumberByKey("Graph window Height", FormatingStr, "=")
	GraphTicksIn=NumberByKey("tick", FormatingStr, "=")
	
	GraphAxisStandoff=NumberByKey("standoff", FormatingStr, "=")
	GraphUseColors=NumberByKey("Graph use Colors", FormatingStr, "=")
	GraphUseBW = NumberByKey("Graph use BW", FormatingStr, "=")
	GraphUseRainbow = NumberByKey("Graph use Rainbow", FormatingStr, "=")	
	GraphUseSymbols=NumberByKey("Graph use Symbols", FormatingStr, "=")

	GraphLeftAxisAuto=NumberByKey("Axis left auto", FormatingStr, "=")
	GraphLeftAxisMin=NumberByKey("Axis left min", FormatingStr, "=")
	GraphLeftAxisMax=NumberByKey("Axis left max", FormatingStr, "=")
	GraphBottomAxisAuto=NumberByKey("Axis bottom auto", FormatingStr, "=")
	GraphBottomAxisMin=NumberByKey("Axis bottom min", FormatingStr, "=")
	GraphBottomAxisMax=NumberByKey("Axis bottom max", FormatingStr, "=")
	
	GraphXAxisName=StringByKey("Label bottom", FormatingStr, "=")
	GraphYAxisName=StringByKey("Label left", FormatingStr, "=")
	GraphLogX=NumberByKey("log(bottom)", FormatingStr, "=")
	GraphLogY=NumberByKey("log(left)", FormatingStr, "=")
	GraphXMirrorAxis=NumberByKey("mirror(bottom)", FormatingStr, "=")
	GraphYMirrorAxis=NumberByKey("mirror(left)", FormatingStr, "=")
	GraphLegendShortNms= NumberByKey("GraphLegendShortNms", FormatingStr, "=")
	if (NumberByKey("Legend", FormatingStr, "=")==2)
		GraphLegend=1
		GraphLegendUseFolderNms=1
	elseif (NumberByKey("Legend", FormatingStr, "=")==1)
		GraphLegend=1
		GraphLegendUseFolderNms=0
	else
		GraphLegend=0
		GraphLegendUseFolderNms=0
	endif

	GraphXMajorGrid=0
	GraphXMinorGrid=0
	GraphYMajorGrid=0
	GraphYMinorGrid=0
	if (NumberByKey("grid(bottom)", FormatingStr, "=")==1)
		GraphXMajorGrid=1
		GraphXMinorGrid=1
	endif
	if (NumberByKey("grid(bottom)", FormatingStr, "=")==2)
		GraphXMajorGrid=1
		GraphXMinorGrid=0
	endif
	if (NumberByKey("grid(left)", FormatingStr, "=")==1)
		GraphYMajorGrid=1
		GraphYMinorGrid=1
	endif
	if (NumberByKey("grid(left)", FormatingStr, "=")==2)
		GraphYMajorGrid=1
		GraphYMinorGrid=0
	endif
	PopupMenu XAxisDataType, win=IR1P_ControlPanel,mode=1,popvalue=StringByKey("DataX", FormatingStr, "=") //,value= "Q;Q^2;Q^3;Q^4;"
	PopupMenu YAxisDataType,win=IR1P_ControlPanel, mode=1,popvalue=StringByKey("DataY", FormatingStr, "=")//,value= "I;I^2;I^3;I^4;I*Q^4;1/I;ln(Q^2*I);"
	IR1P_UpdateAxisName("Y",StringByKey("DataY", FormatingStr, "="))
	IR1P_UpdateAxisName("X",StringByKey("DataX", FormatingStr, "="))
	NVAR GraphUseBW = root:Packages:GeneralplottingTool:GraphUseBW
	if(GraphUseBW+GraphUseColors+GraphUseRainbow!=1)
		GraphUseBW=0
		GraphUseColors=1
		GraphUseRainbow=0
	endif
	if(GraphUseColors)
		IR1P_GraphUseColorsOld(GraphUseColors, GraphUseBW)
	else
		IR1P_GraphUseRainbow(GraphUseRainbow, GraphUseBW)
	endif
	variable i
	if (GraphUseSymbols)
		For(i=0;i<62;i+=1)
			FormatingStr=ReplaceStringByKey("mode["+num2str(i)+"]",FormatingStr, "4","=")
			//FormatingStr=ReplaceStringByKey("mode[1]",FormatingStr, "4","=")
			//FormatingStr=ReplaceStringByKey("mode[2]",FormatingStr, "4","=")
			//FormatingStr=ReplaceStringByKey("mode[3]",FormatingStr, "4","=")
			//FormatingStr=ReplaceStringByKey("mode[4]",FormatingStr, "4","=")

			FormatingStr=ReplaceStringByKey("marker["+num2str(i)+"]",FormatingStr, num2str(i),"=")
			//FormatingStr=ReplaceStringByKey("marker[1]",FormatingStr, "17","=")
			//FormatingStr=ReplaceStringByKey("marker[2]",FormatingStr, "5","=")
			//FormatingStr=ReplaceStringByKey("marker[3]",FormatingStr, "12","=")
			//FormatingStr=ReplaceStringByKey("marker[4]",FormatingStr, "16","=")
		endfor	
	else
		For(i=0;i<62;i+=1)
			FormatingStr=ReplaceStringByKey("mode["+num2str(i)+"]",FormatingStr, "0","=")
			//FormatingStr=ReplaceStringByKey("mode[1]",FormatingStr, "0","=")
			//FormatingStr=ReplaceStringByKey("mode[2]",FormatingStr, "0","=")
			//FormatingStr=ReplaceStringByKey("mode[3]",FormatingStr, "0","=")
			//FormatingStr=ReplaceStringByKey("mode[4]",FormatingStr, "0","=")	
		endfor	
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//sets the popup to "userstyle". Just simple reset of the popup menu
Function IR1P_ChangeToUserPlotType()

	PopupMenu GraphType,mode=1, win=IR1P_ControlPanel
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//create new user style, so user can apply it to another data
Function IR1P_CreateNewUserStyle()

	//here we must make new user style
	//this contains the current graph
	SVAR CurrentGraph=root:Packages:GeneralplottingTool:ListOfGraphFormating
	
	string NewStyleName="MyNewStyle"
	Prompt NewStyleName, "Input name for new style"
	DoPrompt "Modify for new style name macro",NewStyleName
	
	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:plottingToolsStyles
	NewStyleName = CleanupName(NewStyleName, 0)
	if(CheckName(NewStyleName,4)!=0)
		NewStyleName=UniqueName(NewStyleName,4,0)
	endif
	
	string/g $NewStyleName
	SVAR newstyle=$NewStyleName
	newstyle=CurrentGraph

	PopupMenu GraphType,win= IR1P_ControlPanel, mode=1,popvalue= newstyleName
	
	SetDataFolder oldDf
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
//Axis handling function. Needs tro have synchronized fromating string and variables, since it
//apparently uses the variables, not the string as it should. FIX IT>>>
Function IR1P_FixAxesInGraph()
	
	DoWindow GeneralGraph
	if (V_Flag==0)
		abort
	endif
	//this function fixes both axis in the graph according to variables
	
	NVAR GraphLeftAxisAuto=root:Packages:GeneralplottingTool:GraphLeftAxisAuto
	NVAR GraphLeftAxisMin=root:Packages:GeneralplottingTool:GraphLeftAxisMin
	NVAR GraphLeftAxisMax=root:Packages:GeneralplottingTool:GraphLeftAxisMax
	NVAR GraphBottomAxisAuto=root:Packages:GeneralplottingTool:GraphBottomAxisAuto
	NVAR GraphBottomAxisMin=root:Packages:GeneralplottingTool:GraphBottomAxisMin
	NVAR GraphBottomAxisMax=root:Packages:GeneralplottingTool:GraphBottomAxisMax
	SVAR ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating
		GetAxis/Q left
		if (V_Flag)
			abort
		endif
	
	if (GraphLeftAxisAuto)	//autoscale left axis
		SetAxis/A/W=GeneralGraph left
		DoUpdate
		GetAxis /W=GeneralGraph /Q left
		GraphLeftAxisMin=V_min
		GraphLeftAxisMax=V_max
		ListOfGraphFormating=ReplaceNumberByKey("Axis left min",ListOfGraphFormating, GraphLeftAxisMin,"=")
		ListOfGraphFormating=ReplaceNumberByKey("Axis left max",ListOfGraphFormating, GraphLeftAxisMax,"=")
		SetVariable GraphLeftAxisMin win=IR1P_ControlPanel,  limits={0,inf,0}, noedit=1
		SetVariable GraphLeftAxisMax win=IR1P_ControlPanel, limits={0,inf,0}, noedit=1
	else		//fixed left axis
		SetAxis/W=GeneralGraph left GraphLeftAxisMin,GraphLeftAxisMax
		SetVariable GraphLeftAxisMin win=IR1P_ControlPanel,  limits={0,inf,1e-6+GraphLeftAxisMin/10}, noedit=0
		SetVariable GraphLeftAxisMax win=IR1P_ControlPanel, limits={0,inf,1e-6+GraphLeftAxisMax/10}, noedit=0
	endif
	
	if (GraphBottomAxisAuto)	//autoscale bottom axis
		SetAxis/A/W=GeneralGraph bottom
		DoUpdate
		GetAxis /W=GeneralGraph /Q bottom
		GraphBottomAxisMin=V_min
		GraphBottomAxisMax=V_max
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom min",ListOfGraphFormating, GraphBottomAxisMin,"=")
		ListOfGraphFormating=ReplaceNumberByKey("Axis bottom max",ListOfGraphFormating, GraphBottomAxisMax,"=")
		SetVariable GraphBottomAxisMin win=IR1P_ControlPanel, limits={0,inf,0}, noedit=1
		SetVariable GraphBottomAxisMax win=IR1P_ControlPanel, limits={0,inf,0}, noedit=1
	else		//fixed bottom axis
		SetAxis/W=GeneralGraph bottom GraphBottomAxisMin,GraphBottomAxisMax
		SetVariable GraphBottomAxisMin win=IR1P_ControlPanel, limits={0,inf,1e-6+GraphBottomAxisMin/10}, noedit=0
		SetVariable GraphBottomAxisMax win=IR1P_ControlPanel, limits={0,inf,1e-6+GraphBottomAxisMax/10}, noedit=0
	endif
end
//**********************************************************************************************************
//**********************************************************************************************************
//**********************************************************************************************************
Function IR1P_CopyModifyData()  //this function copies data so they can be modified

	SVAR SelectedDataToModify=root:Packages:GeneralplottingTool:SelectedDataToModify
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataOrgWvNames

	if (cmpstr(SelectedDataToModify,"---")==0)
		abort
	endif

	SVAR ModifyIntName=root:Packages:GeneralplottingTool:ModifyIntName
	SVAR ModifyQname= root:Packages:GeneralplottingTool:ModifyQname
	SVAR ModifyErrName=root:Packages:GeneralplottingTool:ModifyErrName
	
	ModifyIntName = ""
	ModifyQname = ""
	ModifyErrName = ""
	
	variable i
	variable imax=ItemsInList(ListOfDataWaveNames,";")/3
	
	For(i=0;i<imax;i+=1)
		if (cmpstr(StringByKey("IntWave"+num2str(i), ListOfDataWaveNames , "=", ";"),SelectedDataToModify)==0)
			ModifyIntName= StringByKey("IntWave"+num2str(i), ListOfDataWaveNames , "=", ";")
			ModifyQname=StringByKey("QWave"+num2str(i), ListOfDataWaveNames , "=", ";")
			ModifyErrName=StringByKey("EWave"+num2str(i), ListOfDataWaveNames , "=", ";")
		endif
	endfor
	
	Wave OrgInt=$ModifyIntName
	Wave OrgQ=$ModifyQname
	Wave/Z OrgE=$ModifyErrName
	
	Duplicate/O OrgInt, $("root:Packages:GeneralplottingTool:BackupInt")
	Duplicate/O OrgQ, $("root:Packages:GeneralplottingTool:BackupQ")
	if(WaveExists(OrgE))
		Duplicate/O OrgE, $("root:Packages:GeneralplottingTool:BackupErr")
	endif
	string addOn="_b"
		string ModifyIntName1 = ModifyIntName
		string ModifyQName1 = ModifyQName
		string ModifyErrName1 = ModifyErrName
	if(stringmatch(ModifyIntName[strlen(ModifyIntName)-1],"'"))
		ModifyIntName1 = ModifyIntName[0,strlen(ModifyIntName)-2]
		ModifyQName1 = ModifyQName[0,strlen(ModifyQName)-2]
		ModifyErrName1 = ModifyErrName[0,strlen(ModifyErrName)-2]
		addOn+="'"
	endif
	
	Wave/Z OrgIntBckp=$((ModifyIntName1+addOn))		//known bug, the name of waves cannot be longer than 32 characters
	if (!WaveExists(OrgIntBckp))
		Duplicate/O OrgInt, $((ModifyIntName1+addOn))
		Duplicate/O OrgQ, $((ModifyQName1+addOn))
		if(WaveExists(OrgE))
			Duplicate/O OrgE, $((ModifyErrName1+addOn))
		endif
	endif
		
	IR1P_RecalcModifyData()
end
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
Function IR1P_RecalcModifyData()	//and this function modifies the data with parameters set in the panel

	NVAR ModifyDataBackground=root:Packages:GeneralplottingTool:ModifyDataBackground
	NVAR ModifyDataMultiplier=root:Packages:GeneralplottingTool:ModifyDataMultiplier
	NVAR ModifyDataQshift=root:Packages:GeneralplottingTool:ModifyDataQshift
	NVAR ModifyDataErrorMult=root:Packages:GeneralplottingTool:ModifyDataErrorMult
	SVAR ListOfRemovedPoints=root:Packages:GeneralplottingTool:ListOfRemovedPoints

	SVAR ModifyIntName=root:Packages:GeneralplottingTool:ModifyIntName
	SVAR ModifyQname= root:Packages:GeneralplottingTool:ModifyQname
	SVAR ModifyErrName=root:Packages:GeneralplottingTool:ModifyErrName

	Wave OrgInt=$ModifyIntName
	Wave OrgQ=$ModifyQname
	Wave/Z OrgE=$ModifyErrName
	
	Wave BackupInt= $("root:Packages:GeneralplottingTool:BackupInt")
	Wave BackupQ = $("root:Packages:GeneralplottingTool:BackupQ")
	if(WaveExists(OrgE))
		Wave BackupErr= $("root:Packages:GeneralplottingTool:BackupErr")
	endif
	OrgInt = ModifyDataMultiplier * backupInt - ModifyDataBackground
	OrgQ  = BackupQ - ModifyDataQshift
	if(WaveExists(OrgE))
		OrgE  = BackupErr * ModifyDataErrorMult
	endif
	NVAR TrimPointSmallQ=root:Packages:GeneralplottingTool:TrimPointSmallQ
	NVAR TrimPointLargeQ=root:Packages:GeneralplottingTool:TrimPointLargeQ
	OrgInt[0,TrimPointSmallQ-1]=NaN
	OrgInt[TrimPointLargeQ+1,inf]=NaN
	
	variable i, cursorNow
	string tempPntNum, tempWvName
	if (strlen(ListOfRemovedPoints)>0)
		for (i=0;i<ItemsInList(ListOfRemovedPoints);i+=1)
			tempPntNum=stringFromList(i,ListOfRemovedPoints)
			OrgInt[str2num(tempPntNum)]=NaN
		endfor
	endif
//	cursorNow=pcsr(A)+1
//	cursor/M /P/W=GeneralGraph  A,csrWave(A,"GeneralGraph"), cursorNow
	IR1P_CreateDataToPlot()
end
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
Function IRP_ButtonProc3(ctrlName) : ButtonControl
	String ctrlName
	
	if(cmpstr(ctrlName,"CancelModify")==0)

		NVAR ModifyDataBackground=root:Packages:GeneralplottingTool:ModifyDataBackground
		NVAR ModifyDataMultiplier=root:Packages:GeneralplottingTool:ModifyDataMultiplier
		NVAR ModifyDataQshift=root:Packages:GeneralplottingTool:ModifyDataQshift
		NVAR ModifyDataErrorMult=root:Packages:GeneralplottingTool:ModifyDataErrorMult
		NVAR TrimPointSmallQ=root:Packages:GeneralplottingTool:TrimPointSmallQ
		NVAR TrimPointLargeQ=root:Packages:GeneralplottingTool:TrimPointLargeQ
		SVAR ListOfRemovedPoints=root:Packages:GeneralplottingTool:ListOfRemovedPoints

		SVAR ModifyIntName=root:Packages:GeneralplottingTool:ModifyIntName
		SVAR ModifyQname= root:Packages:GeneralplottingTool:ModifyQname
		SVAR ModifyErrName=root:Packages:GeneralplottingTool:ModifyErrName
	
		Wave/Z OrgInt=$ModifyIntName
		if (WaveExists(OrgInt)==0)
			abort
		endif
		Wave OrgQ=$ModifyQname
		Wave OrgE=$ModifyErrName
		
		Wave BackupInt= $("root:Packages:GeneralplottingTool:BackupInt")
		Wave BackupQ = $("root:Packages:GeneralplottingTool:BackupQ")
		Wave BackupErr= $("root:Packages:GeneralplottingTool:BackupErr")

		ModifyDataBackground = 0
		ModifyDataMultiplier = 1
		ModifyDataQshift = 0
		ModifyDataErrorMult = 1
		TrimPointSmallQ=0
		TrimPointLargeQ=inf
		ListOfRemovedPoints=""
	
		OrgInt = BackupInt
		OrgQ = BackupQ
		OrgE = BackupErr

		IR1P_CreateDataToPlot()

	endif
	
	if(cmpstr(ctrlName,"RemoveSmallData")==0)
		IR1P_RemoveSmallData()
		IR1P_RecalcModifyData()
	endif
	
	if(cmpstr(ctrlName,"RemoveLargeData")==0)
		IR1P_RemoveLargeData()
		IR1P_RecalcModifyData()
	endif
	if(cmpstr(ctrlName,"RemoveOneDataPnt")==0)
		IR1P_RemoveOneDataPoint()
		IR1P_RecalcModifyData()
	endif
	if(cmpstr(ctrlName,"RecoverBackup")==0)
		IR1P_RecoverBackup()
		IR1P_RecalcModifyData()
	endif


	if(cmpstr(ctrlName,"DoFitting")==0)
		IR1P_DoFitting()
	endif
	if(cmpstr(ctrlName,"RemoveTagsAndFits")==0)
		IR1P_RemoveTagsAndFits()
	endif
	if(cmpstr(ctrlName,"GuessFitParam")==0)
		IR1P_GuessFitParam()
	endif
End

//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function IR1P_RecoverBackup()
	//this function recovers original data from backup for Modify data panel
	
	SVAR ModifyIntName=root:Packages:GeneralplottingTool:ModifyIntName
	SVAR ModifyQname= root:Packages:GeneralplottingTool:ModifyQname
	SVAR ModifyErrName=root:Packages:GeneralplottingTool:ModifyErrName

	Wave/Z OrgIntBckp=$(ModifyIntName+"_bckup") //known bug, the name cannot be longer than 32 characters
	Wave/Z OrgIntBckpNew=$(ModifyIntName+"_b") //known bug, the name cannot be longer than 32 characters
	if (WaveExists(OrgIntBckp))
		Wave OrgBackupInt= $(ModifyIntName+"_bckup")
		Wave OrgBackupQ = $(ModifyQName+"_bckup")
		Wave OrgBackupE=  $(ModifyErrName+"_bckup")
	elseif (WaveExists(OrgIntBckpNew))
		Wave/Z OrgIntBckp=$(ModifyIntName+"_b") //known bug, the name cannot be longer than 32 characters
		Wave OrgBackupInt= $(ModifyIntName+"_b")
		Wave OrgBackupQ = $(ModifyQName+"_b")
		Wave OrgBackupE=  $(ModifyErrName+"_b")
	else
		Abort "backup for these data does not exists"
	endif


		NVAR ModifyDataBackground=root:Packages:GeneralplottingTool:ModifyDataBackground
		NVAR ModifyDataMultiplier=root:Packages:GeneralplottingTool:ModifyDataMultiplier
		NVAR ModifyDataQshift=root:Packages:GeneralplottingTool:ModifyDataQshift
		NVAR ModifyDataErrorMult=root:Packages:GeneralplottingTool:ModifyDataErrorMult
		NVAR TrimPointSmallQ=root:Packages:GeneralplottingTool:TrimPointSmallQ
		NVAR TrimPointLargeQ=root:Packages:GeneralplottingTool:TrimPointLargeQ
		SVAR ListOfRemovedPoints=root:Packages:GeneralplottingTool:ListOfRemovedPoints

		Wave/Z OrgInt=$ModifyIntName
		if (WaveExists(OrgInt)==0)
			abort
		endif
		Wave OrgQ=$ModifyQname
		Wave OrgE=$ModifyErrName
		
		Wave BackupInt= $("root:Packages:GeneralplottingTool:BackupInt")
		Wave BackupQ = $("root:Packages:GeneralplottingTool:BackupQ")
		Wave BackupErr= $("root:Packages:GeneralplottingTool:BackupErr")

		ModifyDataBackground = 0
		ModifyDataMultiplier = 1
		ModifyDataQshift = 0
		ModifyDataErrorMult = 1
		TrimPointSmallQ=0
		TrimPointLargeQ=inf
		ListOfRemovedPoints=""
	
		BackupInt=OrgBackupInt
		BackupQ = OrgBackupQ
		BackupErr=OrgBackupE
		OrgInt = BackupInt
		OrgQ = BackupQ
		OrgE = BackupErr

		IR1P_CreateDataToPlot()
	
end
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function IR1P_RemoveSmallData()
  

	//sets to NaNs data with Q smaller than where the cursor A is in GeneralGraph
	//is cursor A on the wave listed in the list Box, let's put it there...
	
		SVAR ModifyIntName=root:Packages:GeneralplottingTool:ModifyIntName
		string CsrAFullWaveRef=IR1P_CursorAWave()
		if (cmpstr(ModifyIntName,CsrAFullWaveRef)!=0)
			Abort "Cursor is not on the right wave"
		endif
		
		variable PointWithCsrA=pcsr(A,"GeneralGraph" )
		NVAR TrimPointSmallQ = root:Packages:GeneralplottingTool:TrimPointSmallQ
		TrimPointSmallQ = PointWithCsrA
end

//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function IR1P_RemoveLargeData()
  

	//sets to NaNs data with Q smaller than where the cursor A is in GeneralGraph
	//is cursor A on the wave listed in the list Box, let's put it there...
	
		SVAR ModifyIntName=root:Packages:GeneralplottingTool:ModifyIntName
		string CsrBFullWaveRef=IR1P_CursorBWave()
		if (cmpstr(ModifyIntName,CsrBFullWaveRef)!=0)
			Abort "Cursor is not on the right wave"
		endif
		
		variable PointWithCsrB=pcsr(B,"GeneralGraph" )
		NVAR TrimPointLargeQ = root:Packages:GeneralplottingTool:TrimPointLargeQ
		TrimPointLargeQ = PointWithCsrB
end
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************


Function IR1P_RemoveOneDataPoint()
  

	//sets to NaNs data point where the cursor A is in GeneralGraph
	//is cursor A on the wave listed in the list Box, let's put it there...
	
		SVAR ModifyIntName=root:Packages:GeneralplottingTool:ModifyIntName
		string CsrAFullWaveRef=IR1P_CursorAWave()
		if (cmpstr(ModifyIntName,CsrAFullWaveRef)!=0)
			Abort "Cursor is not on the right wave"
		endif
		
		variable PointWithCsrA=pcsr(A,"GeneralGraph" )
		SVAR ListOfRemovedPoints = root:Packages:GeneralplottingTool:ListOfRemovedPoints
		ListOfRemovedPoints += num2str(PointWithCsrA)+";"
end
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function/S IR1P_CursorAWave()
	Wave/Z w= CsrWaveRef(A)
	if (WaveExists(w)==0)
		return ""
	endif
	return GetWavesDataFolder(w,2)
End
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function/S IR1P_CursorBWave()
	Wave/Z w= CsrWaveRef(B)
	if (WaveExists(w)==0)
		return ""
	endif
	return GetWavesDataFolder(w,2)
End

//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
Function IR1P_SetSymbolsAndLines()

	SVAR 	ListOfGraphFormating=root:Packages:GeneralplottingTool:ListOfGraphFormating


	variable UseLinesAlso=NumberByKey("Graph use Lines",ListOfGraphFormating,"=",";")
	variable GraphVarySymbols=NumberByKey("Graph Vary Symbols",ListOfGraphFormating,"=",";")
	variable GraphUseSymbols=NumberByKey("Graph Use Symbols",ListOfGraphFormating,"=",";")
	variable GraphUseSymbolSet1=NumberByKey("GraphUseSymbolSet1",ListOfGraphFormating,"=",";")
	variable GraphUseSymbolSet2=NumberByKey("GraphUseSymbolSet2",ListOfGraphFormating,"=",";")

	if (GraphUseSymbols && UseLinesAlso)
		//	ListOfGraphFormating=ReplaceStringByKey("mode",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[0]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[1]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[2]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[3]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[4]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[5]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[6]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[7]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[8]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[9]",ListOfGraphFormating, "4","=")
	endif
	if (!GraphUseSymbols && UseLinesAlso)
		//	ListOfGraphFormating=ReplaceStringByKey("mode",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[0]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[1]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[2]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[3]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[4]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[5]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[6]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[7]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[8]",ListOfGraphFormating, "0","=")
			ListOfGraphFormating=ReplaceStringByKey("mode[9]",ListOfGraphFormating, "0","=")		
	endif

	if (GraphVarySymbols)
		if (GraphUseSymbolSet2)
			ListOfGraphFormating=ReplaceStringByKey("marker[0]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[1]",ListOfGraphFormating, "5","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[2]",ListOfGraphFormating, "6","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[3]",ListOfGraphFormating, "22","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[4]",ListOfGraphFormating, "25","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[5]",ListOfGraphFormating, "28","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[6]",ListOfGraphFormating, "7","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[7]",ListOfGraphFormating, "4","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[8]",ListOfGraphFormating, "3","=")		
	// plne 19,16,17, 23, 26, 29 ,18, 15, 14
	// otevrene 8, 5, 6, 22, 25, 28, 7, 4, 3
		else		//symbol set1
			ListOfGraphFormating=ReplaceStringByKey("marker[0]",ListOfGraphFormating, "19","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[1]",ListOfGraphFormating, "16","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[2]",ListOfGraphFormating, "17","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[3]",ListOfGraphFormating, "23","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[4]",ListOfGraphFormating, "26","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[5]",ListOfGraphFormating, "29","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[6]",ListOfGraphFormating, "18","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[7]",ListOfGraphFormating, "15","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[8]",ListOfGraphFormating, "14","=")
		endif
	else		//do not vary
		//	ListOfGraphFormating=ReplaceStringByKey("marker",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[0]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[1]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[2]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[3]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[4]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[5]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[6]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[7]",ListOfGraphFormating, "8","=")
			ListOfGraphFormating=ReplaceStringByKey("marker[8]",ListOfGraphFormating, "8","=")
	endif

end 

//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

///////////// 3D graph controsl and dvelopemnt


Function IR1P_Create3DGraph()

	//IR1P_CreateGraph()
	//IR1P_AddDataToGenGraph()
	DoWIndow PlotingToolWaterfallGrph
	if(V_Flag)
		DoWIndow/K PlotingToolWaterfallGrph
	endif
	IR1P_CreateDataToPlot()
	
	IR1P_genGraphCreateDataWF()
	//PauseUpdate; Silent 1		// create new 3D graph.
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:GeneralplottingTool:Waterfall:
	WAVE PlottingTool_Int_M=root:Packages:GeneralplottingTool:Waterfall:PlottingTool_Int_M
	WAVE PlottingTool_Q = root:Packages:GeneralplottingTool:Waterfall:PlottingTool_Q
	NewWaterfall/W=(405,467,950,900) /K=1  PlottingTool_Int_M vs {PlottingTool_Q,*} as "Plotting Tool I 3D graph"
	DoWindow/C PlotingToolWaterfallGrph
	ControlBar /T/W=PlotingToolWaterfallGrph 50
	//Angle, colorscale, ax length
	SVAR Graph3DColorScale = root:Packages:GeneralplottingTool:Graph3DColorScale
	SVAR Graph3DVisibility=root:Packages:GeneralplottingTool:Graph3DVisibility
	PopupMenu ColorTable,pos={140,5},size={150,20},title="Colors:", proc=IR1P_Plot3D_PopMenuProc, help={"Select color table"}
	PopupMenu ColorTable,mode=1,popvalue=Graph3DColorScale,value= #"CTabList()", bodyWidth=100
	PopupMenu Graph3DVisibility,pos={140,30},size={150,20},title="Hidden lines:", bodyWidth=100, proc=IR1P_Plot3D_PopMenuProc
	PopupMenu Graph3DVisibility,mode=1,popvalue=Graph3DVisibility,value= #"\"Off;Painter;True;No bottom;Color bottom\""
	SetVariable angVar,size={120,15},pos={10,5},bodyWidth=50,title="Angle"
	SetVariable angVar,format="%.1f", proc=IR1P_Plot3D_SetVarProc, help={"Change angle of the slant"}
	SetVariable angVar,limits={10,90,1},value= root:Packages:GeneralplottingTool:Graph3DAngle
	SetVariable alenVar,pos={10,30},size={120,15},bodyWidth=50,title="Axis Length"
	SetVariable alenVar,format="%.2f", proc=IR1P_Plot3D_SetVarProc, help={"change length of slanted axis"}
	SetVariable alenVar,limits={0.1,0.9,0.05},value= root:Packages:GeneralplottingTool:Graph3DAxLength
	Checkbox Graph3DLogColors, pos={420,10}, title="Log Colors?", size={80,15}, variable=root:Packages:GeneralplottingTool:Graph3DLogColors, proc=IR1P_Plot3D_CheckProc
	Checkbox Graph3DColorsReverse, pos={420,30}, title="Reverse Colors?", size={80,15}, variable=root:Packages:GeneralplottingTool:Graph3DColorsReverse, proc=IR1P_Plot3D_CheckProc
	NVAR Graph3DClrMin = root:Packages:GeneralplottingTool:Graph3DClrMin
	NVAR Graph3DClrMax = root:Packages:GeneralplottingTool:Graph3DClrMax

	Slider /Z Graph3DClrMax  limits = {Graph3DClrMin,Graph3DClrMax,0} , vert=0, pos = {300,10}, size = {100,10}, variable= root:Packages:GeneralplottingTool:Graph3DClrMax
	Slider /Z Graph3DClrMax proc=IR1P_Plot3D_SliderProc,ticks=0, help={"Slide to change color scaling"}, title = "Max"

	Slider /Z Graph3DClrMin  limits = {Graph3DClrMin,Graph3DClrMax,0} , vert=0, pos = {300,30}, size = {100,10}, variable= root:Packages:GeneralplottingTool:Graph3DClrMin
	Slider /Z Graph3DClrMin proc=IR1P_Plot3D_SliderProc,ticks=0, help={"Slide to change color scaling"}, title="min"
	IR1P_UpdateColorAndFormat3DPlot(1)
end


//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function IR1P_CreateCountourGraph()

	DoWIndow PlotingToolContourGrph
	if(V_Flag)
		DoWIndow/K PlotingToolContourGrph
	endif
	IR1P_CreateDataToPlot()
	IR1P_genGraphCreateDataWF()
	Wave PlottingTool_Int_M=root:Packages:GeneralplottingTool:Waterfall:PlottingTool_Int_M
	Duplicate/O PlottingTool_Int_M, PlottingTool_Int_Contour
	wave PlottingTool_Int_Contour=root:Packages:GeneralplottingTool:Waterfall:PlottingTool_Int_Contour
	NVAR ContSmoothOverValue=root:Packages:GeneralplottingTool:ContSmoothOverValue
	if(ContSmoothOverValue>2)
		MatrixFilter /N=(ContSmoothOverValue) avg PlottingTool_Int_Contour
	endif
	SVAR Graph3DColorScale = root:Packages:GeneralplottingTool:ContGraph3DColorScale
	Display /K=1/W=(405,467,950,900) as "Plotting tool I Contour plot"
	AppendMatrixContour PlottingTool_Int_Contour vs {PlottingTool_Q,*}
	ModifyGraph mirror=2
	DoWindow/C PlotingToolContourGrph
	ControlBar /T/W=PlotingToolContourGrph 52
	SetVariable ContNumCountours,pos={10,2},size={170,15},title="Number of contours",bodyWidth=70
	SetVariable ContNumCountours, proc=IR1P_ContSetVarProc, help={"Number of contours to use"}
	SetVariable ContNumCountours,limits={11,inf,5},value= root:Packages:GeneralplottingTool:ContNumCountours
	SetVariable ContMinValue,pos={10,18},size={170,15},title="Min Contour val ",bodyWidth=70
	SetVariable ContMinValue, proc=IR1P_ContSetVarProc, help={"Value of minimum Contour"}
	SetVariable ContMinValue,limits={0,inf,0},value= root:Packages:GeneralplottingTool:ContMinValue
	SetVariable ContMaxValue,pos={10,35},size={170,15},title="Max Contour val",bodyWidth=70
	SetVariable ContMaxValue, proc=IR1P_ContSetVarProc, help={"change length of slanted axis"}
	SetVariable ContMaxValue,limits={0,inf,0},value= root:Packages:GeneralplottingTool:ContMaxValue
	Checkbox ContDisplayContValues, pos={200,5}, title="Labels?", size={100,15}, variable=root:Packages:GeneralplottingTool:ContDisplayContValues, proc=IR1P_ContCheckProc
	PopupMenu ColorTable,pos={200,30},size={150,20},title="Colors:", help={"Select color table"}
	PopupMenu ColorTable,mode=1,popvalue=Graph3DColorScale,value= #"CTabList()", bodyWidth=100, proc=IR1P_ContPopMenuProc
	PopupMenu SmoothOverValue,pos={350,30},size={150,20},title="Smooth val:", help={"Smooth value"}, proc=IR1P_ContPopMenuProc
	PopupMenu SmoothOverValue,mode=1,popvalue=num2str(ContSmoothOverValue),value= "0;3;5;9;", bodyWidth=40
	Checkbox ContLogContours, pos={300,5}, title="Log countours?", size={100,15}, variable=root:Packages:GeneralplottingTool:ContLogContours, proc=IR1P_ContCheckProc
	Checkbox ContUseOnlyRedColor, pos={400,5}, title="Only red?", size={100,15}, variable=root:Packages:GeneralplottingTool:ContUseOnlyRedColor, proc=IR1P_ContCheckProc

	IR1P_FormatContourPlot()
end
//************************************************************************************************************************
//************************************************************************************************************************
Function IR1P_FormatContourPlot()
	DoWIndow PlotingToolContourGrph
	if(!V_Flag)
		return 0
	else
		DoWIndow/F PlotingToolContourGrph
	endif

	SVAR Graph3DColorScale = root:Packages:GeneralplottingTool:ContGraph3DColorScale
	NVAR GraphLeftAxisAuto = root:Packages:GeneralplottingTool:GraphLeftAxisAuto
	NVAR GraphLeftAxisMin = root:Packages:GeneralplottingTool:GraphLeftAxisMin
	NVAR GraphLeftAxisMax = root:Packages:GeneralplottingTool:GraphLeftAxisMax
	NVAR GraphBottomAxisAuto= root:Packages:GeneralplottingTool:GraphBottomAxisAuto
	NVAR GraphBottomAxisMin= root:Packages:GeneralplottingTool:GraphBottomAxisMin
	NVAR GraphBottomAxisMax = root:Packages:GeneralplottingTool:GraphBottomAxisMax
	NVAR ContMinValue = root:Packages:GeneralplottingTool:ContMinValue
	NVAR ContMaxValue = root:Packages:GeneralplottingTool:ContMaxValue
	NVAR ContNumCountours = root:Packages:GeneralplottingTool:ContNumCountours
	NVAR ContDisplayContValues = root:Packages:GeneralplottingTool:ContDisplayContValues
	NVAR ContMinValue = root:Packages:GeneralplottingTool:ContMinValue
	NVAR ContMaxValue = root:Packages:GeneralplottingTool:ContMaxValue
	NVAR ContNumCountours = root:Packages:GeneralplottingTool:ContNumCountours
	NVAR ContDisplayContValues = root:Packages:GeneralplottingTool:ContDisplayContValues
	NVAR ContLogContours = root:Packages:GeneralplottingTool:ContLogContours
	NVAR ContUseOnlyRedColor = root:Packages:GeneralplottingTool:ContUseOnlyRedColor
	
	WAVE PlottingTool_Int_Contour=root:Packages:GeneralplottingTool:Waterfall:PlottingTool_Int_Contour
	WAVE PlottingTool_Q = root:Packages:GeneralplottingTool:Waterfall:PlottingTool_Q
	//let's set the min/max values right...
//	if(!GraphLeftAxisAuto)
//		SetAxis left GraphLeftAxisMin, GraphLeftAxisMax
//	else
//		SetAxis/A left
//	endif	
	//SVAR GraphYAxisName = root:Packages:GeneralplottingTool:GraphYAxisName
	if(!GraphBottomAxisAuto)
		SetAxis bottom GraphBottomAxisMin, GraphBottomAxisMax
	else
		SetAxis/A bottom
	endif	
	SVAR GraphXAxisName = root:Packages:GeneralplottingTool:GraphXAxisName
	Label /W=PlotingToolContourGrph bottom GraphXAxisName
	//Label left GraphYAxisName
	if(!GraphLeftAxisAuto)
		ContMinValue = GraphLeftAxisMin
		ContMaxValue = GraphLeftAxisMax
		ModifyContour PlottingTool_Int_Contour autoLevels={ContMinValue,ContMaxValue,ContNumCountours}
	else
		ModifyContour PlottingTool_Int_Contour autoLevels={*,*,ContNumCountours}
		ContMinValue = GraphLeftAxisMin
		ContMaxValue = GraphLeftAxisMax
	endif	
	SetVariable ContMinValue,limits={ContMinValue,ContMaxValue,((ContMaxValue-ContMinValue)/25)},win= PlotingToolContourGrph
	SetVariable ContMaxValue,limits={ContMinValue,ContMaxValue,((ContMaxValue-ContMinValue)/25)},win= PlotingToolContourGrph

	ModifyContour PlottingTool_Int_Contour labels=2*ContDisplayContValues
	NVAR ContUseOnlyRedColor = root:Packages:GeneralplottingTool:ContUseOnlyRedColor
	if(stringmatch(Graph3DColorScale,"none"))
		Graph3DColorScale = "Rainbow"
		PopupMenu ColorTable win=PlotingToolContourGrph, mode=2
	endif
	if(ContUseOnlyRedColor)
		ModifyContour PlottingTool_Int_Contour labelRGB=(65535, 0, 0 )
	else
		ModifyContour PlottingTool_Int_Contour ctabLines={ContMinValue, ContMaxValue, $(Graph3DColorScale), 1 }
	endif
	NVAR ContLogContours = root:Packages:GeneralplottingTool:ContLogContours
	ModifyContour PlottingTool_Int_Contour logLines=ContLogContours
	NVAR GraphLogX = root:Packages:GeneralplottingTool:GraphLogX
	if(GraphLogX)
		ModifyGraph /W=PlotingToolContourGrph log(bottom)=1
	else
		ModifyGraph  /W=PlotingToolContourGrph log(bottom)=0
	endif
	Label/W=PlotingToolContourGrph left "Data Order"

end


//************************************************************************************************************************
//************************************************************************************************************************
Function IR1P_ContSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
			if(stringmatch(sva.ctrlName,"ContNumCountours")||stringmatch(sva.ctrlName,"ContMinValue")||stringmatch(sva.ctrlName,"ContMaxValue"))
				//do something
				NVAR ContNumCountours = root:Packages:GeneralplottingTool:ContNumCountours
				NVAR ContMinValue = root:Packages:GeneralplottingTool:ContMinValue
				NVAR ContMaxValue = root:Packages:GeneralplottingTool:ContMaxValue
				ModifyContour PlottingTool_Int_Contour autoLevels={ContMinValue,ContMaxValue,ContNumCountours}
			endif
			break
		case 2: // Enter key
			if(stringmatch(sva.ctrlName,"ContNumCountours")||stringmatch(sva.ctrlName,"ContMinValue")||stringmatch(sva.ctrlName,"ContMaxValue"))
				//do something
				NVAR ContNumCountours = root:Packages:GeneralplottingTool:ContNumCountours
				NVAR ContMinValue = root:Packages:GeneralplottingTool:ContMinValue
				NVAR ContMaxValue = root:Packages:GeneralplottingTool:ContMaxValue
				ModifyContour PlottingTool_Int_Contour autoLevels={ContMinValue,ContMaxValue,ContNumCountours}
			endif
			break
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************************
//************************************************************************************************************************
Function IR1P_ContCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(stringmatch(cba.ctrlName,"ContDisplayContValues"))
				NVAR ContDisplayContValues = root:Packages:GeneralplottingTool:ContDisplayContValues
				ModifyContour PlottingTool_Int_Contour labels=2*ContDisplayContValues
				//do something
			endif
			NVAR ContLogContours = root:Packages:GeneralplottingTool:ContLogContours
			NVAR ContUseOnlyRedColor = root:Packages:GeneralplottingTool:ContUseOnlyRedColor
			if(stringmatch(cba.ctrlName,"ContUseOnlyRedColor"))
				NVAR ContLogContours = root:Packages:GeneralplottingTool:ContLogContours
				ContLogContours=0
				ModifyContour PlottingTool_Int_Contour rgbLines=(65535,0,0 )
				//do something
			endif
			if(stringmatch(cba.ctrlName,"ContLogContours"))
				NVAR ContLogContours = root:Packages:GeneralplottingTool:ContLogContours
				ModifyContour PlottingTool_Int_Contour logLines=ContLogContours
				//do something
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************************
//************************************************************************************************************************
Function IR1P_ContPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(stringmatch(pa.ctrlName,"ColorTable"))
				SVAR Graph3DColorScale = root:Packages:GeneralplottingTool:ContGraph3DColorScale
				Graph3DColorScale = popStr
				NVAR ContMinValue = root:Packages:GeneralplottingTool:ContMinValue
				NVAR ContMaxValue = root:Packages:GeneralplottingTool:ContMaxValue
				NVAR ContLogContours = root:Packages:GeneralplottingTool:ContLogContours
				NVAR ContUseOnlyRedColor = root:Packages:GeneralplottingTool:ContUseOnlyRedColor
				ContUseOnlyRedColor=0
				if(stringMatch(Graph3DColorScale,"none"))
					ModifyContour PlottingTool_Int_Contour labelRGB=(65535, 0, 0 )
				else
					ModifyContour PlottingTool_Int_Contour ctabLines={ContMinValue, ContMaxValue, $(Graph3DColorScale), 1 }
					ModifyContour PlottingTool_Int_Contour logLines=ContLogContours
				endif
			endif
			if(stringmatch(pa.ctrlName,"SmoothOverValue"))
				NVAR ContSmoothOverValue=root:Packages:GeneralplottingTool:ContSmoothOverValue
				WAVE PlottingTool_Int_M = root:Packages:GeneralplottingTool:Waterfall:PlottingTool_Int_M
				WAVE PlottingTool_Int_Contour = root:Packages:GeneralplottingTool:Waterfall:PlottingTool_Int_Contour
				Duplicate /O PlottingTool_Int_M, PlottingTool_Int_Contour
				ContSmoothOverValue = str2num(pa.popStr)
				if(ContSmoothOverValue>2)
					MatrixFilter /N=(ContSmoothOverValue) avg PlottingTool_Int_Contour
				endif
				IR1P_FormatContourPlot()
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************************
//************************************************************************************************************************
Function IR1P_Plot3D_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	SVAR FormatingStr=root:Packages:GeneralplottingTool:ListOfGraphFormating
	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			if(stringmatch(cba.ctrlName,"Graph3DLogColors"))
				FormatingStr=ReplaceNumberByKey("Graph3D Log Colors", FormatingStr, checked  , "=" )
				IR1P_Color3DGraph(0)			
			endif
			if(stringmatch(cba.ctrlName,"Graph3DColorsReverse"))
				FormatingStr=ReplaceNumberByKey("Graph3D Colors Reverse", FormatingStr, checked  , "=" )
				IR1P_Color3DGraph(0)			
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function IR1P_Plot3D_SliderProc(sa) : SliderControl
	STRUCT WMSliderAction &sa

	switch( sa.eventCode )
		case -1: // control being killed
			break
		default:
			if( sa.eventCode & 1 ) // value set
				Variable curval = sa.curval
				SVAR FormatingStr=root:Packages:GeneralplottingTool:ListOfGraphFormating
				NVAR Graph3DClrMax = root:Packages:GeneralplottingTool:Graph3DClrMax
				NVAR Graph3DClrMin = root:Packages:GeneralplottingTool:Graph3DClrMin
				FormatingStr=ReplaceNumberByKey("Graph3D Clr Max", FormatingStr, Graph3DClrMax  , "=" )
				FormatingStr=ReplaceNumberByKey("Graph3D Clr Min", FormatingStr, Graph3DClrMin  , "=" )
				
				IR1P_Color3DGraph(0)
			endif
			break
	endswitch

	return 0
End

//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
Function IR1P_Plot3D_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	NVAR Graph3DAngle=root:Packages:GeneralplottingTool:Graph3DAngle
	NVAR Graph3DAxLength=root:Packages:GeneralplottingTool:Graph3DAxLength
	SVAR FormatingStr=root:Packages:GeneralplottingTool:ListOfGraphFormating
	switch( sva.eventCode )
			Variable dval = sva.dval
			String sval = sva.sval
		case 1: // mouse up
		case 2: // Enter key
			if(stringmatch(sva.ctrlName,"angVar"))
				FormatingStr=ReplaceNumberByKey("Graph3D Angle", FormatingStr, sva.dval  , "=" )
				Graph3DAngle = sva.dval
				IR1P_Format3DGraph()
			endif
			if(stringmatch(sva.ctrlName,"alenVar"))
				FormatingStr=ReplaceNumberByKey("Graph3D Ax Length", FormatingStr, sva.dval  , "=" )
				Graph3DAxLength = sva.dval
				IR1P_Format3DGraph()
			endif
		case 3: // Live update
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function IR1P_Plot3D_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			SVAR Graph3DColorScale = root:Packages:GeneralplottingTool:Graph3DColorScale
			SVAR Graph3DVisibility = root:Packages:GeneralplottingTool:Graph3DVisibility
			NVAR Graph3DClrMin = root:Packages:GeneralplottingTool:Graph3DClrMin
			NVAR Graph3DClrMax = root:Packages:GeneralplottingTool:Graph3DClrMax
			SVAR Graph3DVisibility = root:Packages:GeneralplottingTool:Graph3DVisibility
			SVAR FormatingStr=root:Packages:GeneralplottingTool:ListOfGraphFormating
			if(stringmatch("ColorTable",pa.ctrlName))
				Graph3DColorScale = popStr
				FormatingStr=ReplaceStringByKey("Graph3D Color Scale", FormatingStr, popStr  , "=" )
				IR1P_Color3DGraph(0)
			endif
			if(stringmatch("Graph3DVisibility",pa.ctrlName))
				FormatingStr=ReplaceStringByKey("Graph3D Visibility", FormatingStr, popStr  , "=" )
				Graph3DVisibility = popStr
				IR1P_Color3DGraph(0)
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function IR1P_UpdateColorAndFormat3DPlot(ForceScale)
	variable ForceScale
	DoWIndow PlotingToolWaterfallGrph
	if(V_Flag)
		IR1P_Format3DGraph()
		IR1P_Color3DGraph(ForceScale)
	endif
end
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function IR1P_Color3DGraph(ForceScale)
	variable ForceScale
	DoWIndow PlotingToolWaterfallGrph
	if(!V_Flag)
		return 0
	endif
	SVAR Graph3DColorScale = root:Packages:GeneralplottingTool:Graph3DColorScale
	NVAR Graph3DClrMin = root:Packages:GeneralplottingTool:Graph3DClrMin
	NVAR Graph3DClrMax = root:Packages:GeneralplottingTool:Graph3DClrMax
	NVAR GraphBottomAxisMin = root:Packages:GeneralplottingTool:GraphBottomAxisMin
	NVAR GraphBottomAxisMax = root:Packages:GeneralplottingTool:GraphBottomAxisMax
	NVAR GraphLeftAxisMin = root:Packages:GeneralplottingTool:GraphLeftAxisMin
	NVAR GraphLeftAxisMax = root:Packages:GeneralplottingTool:GraphLeftAxisMax
	NVAR GraphLeftAxisAuto = root:Packages:GeneralplottingTool:GraphLeftAxisAuto
	SVAR Graph3DVisibility = root:Packages:GeneralplottingTool:Graph3DVisibility
	NVAR Graph3DLogColors=root:Packages:GeneralplottingTool:Graph3DLogColors
	NVAR Graph3DColorsReverse=root:Packages:GeneralplottingTool:Graph3DColorsReverse
	wave DisplayedWv= root:Packages:GeneralplottingTool:Waterfall:PlottingTool_Int_M
	//,mode=1,popvalue=Graph3DVisibility,value= #"\"Off;Painter;True;No bottom;Color bottom\""
	if(stringmatch(Graph3DVisibility,"Off"))
		ModifyWaterfall /W=PlotingToolWaterfallGrph hidden=0
	elseif(stringmatch(Graph3DVisibility,"Painter"))
		ModifyWaterfall /W=PlotingToolWaterfallGrph hidden=1
	elseif(stringmatch(Graph3DVisibility,"True"))
		ModifyWaterfall /W=PlotingToolWaterfallGrph hidden=2
	elseif(stringmatch(Graph3DVisibility,"No bottom"))
		ModifyWaterfall /W=PlotingToolWaterfallGrph hidden=3
	elseif(stringmatch(Graph3DVisibility,"Color bottom"))
		ModifyWaterfall /W=PlotingToolWaterfallGrph hidden=4
	endif

	if((Graph3DClrMin==0 && Graph3DClrMax==0))
		ModifyGraph/W=PlotingToolWaterfallGrph zColor(PlottingTool_Int_M)={PlottingTool_Int_M,*,*,$(Graph3DColorScale),0}
	else //not in auto mode...
		if(ForceScale)
			if(GraphLeftAxisAuto)
				Duplicate/Free DisplayedWv, TmpWv
				TmpWv = TmpWv[p][q] <=0 ? NaN : Tmpwv[p][q] 
				wavestats/q TmpWv
				Graph3DClrMin = V_Min
				Graph3DClrMax = V_max
			else
				Graph3DClrMin = GraphLeftAxisMin
				Graph3DClrMax = GraphLeftAxisMax
			endif
			Slider/Z Graph3DClrMax limits={Graph3DClrMin,Graph3DClrMax,0}, win=PlotingToolWaterfallGrph, variable= root:Packages:GeneralplottingTool:Graph3DClrMax, proc=IR1P_Plot3D_SliderProc
			Slider/Z Graph3DClrMin limits={Graph3DClrMin,Graph3DClrMax,0}, win=PlotingToolWaterfallGrph,variable= root:Packages:GeneralplottingTool:Graph3DClrMin, proc=IR1P_Plot3D_SliderProc
		endif
		string TempMin, tempMax
		if(Graph3DClrMin>0)
			ModifyGraph/W=PlotingToolWaterfallGrph zColor(PlottingTool_Int_M)={root:Packages:GeneralplottingTool:Waterfall:PlottingTool_Int_M,Graph3DClrMin,Graph3DClrMax,$(Graph3DColorScale),Graph3DColorsReverse}	
		else
			ModifyGraph/W=PlotingToolWaterfallGrph zColor(PlottingTool_Int_M)={root:Packages:GeneralplottingTool:Waterfall:PlottingTool_Int_M,*,Graph3DClrMax,$(Graph3DColorScale),Graph3DColorsReverse}	
		endif
		ModifyGraph/W=PlotingToolWaterfallGrph logZColor=Graph3DLogColors
	endif
	
	NVAR GraphUseRainbow = root:Packages:GeneralplottingTool:GraphUseRainbow
	NVAR GraphUseBW = root:Packages:GeneralplottingTool:GraphUseBW
	
	IR1P_GraphUseRainbow(GraphUseRainbow, GraphUseBW)
end

//	Slider /Z Graph3DClrMax  limits = {Graph3DClrMin,Graph3DClrMax,0} , vert=0, pos = {300,10}, size = {150,10}, variable= root:Packages:GeneralplottingTool:Graph3DClrMax
//	Slider /Z Graph3DClrMax proc=IR1P_Plot3D_SliderProc,ticks=0, help={"Slide to change color scaling"}, title = "Max"
//
//	Slider /Z Graph3DClrMin  limits = {Graph3DClrMin,Graph3DClrMax,0} , vert=0, pos = {300,30}, size = {150,10}, variable= root:Packages:GeneralplottingTool:Graph3DClrMin
//	Slider /Z Graph3DClrMin proc=IR1P_Plot3D_SliderProc,ticks=0, help={"Slide to change color scaling"}, title="min"

//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function IR1P_Format3DGraph()
	DoWIndow PlotingToolWaterfallGrph
	if(!V_Flag)
		return 0
	endif

	SVAR GraphXAxisName = root:Packages:GeneralplottingTool:GraphXAxisName
	SVAR GraphYAxisName = root:Packages:GeneralplottingTool:GraphYAxisName
	NVAR GraphLogX = root:Packages:GeneralplottingTool:GraphLogX
	NVAR GraphLogY = root:Packages:GeneralplottingTool:GraphLogY
	NVAR GraphLineWIdth = root:Packages:GeneralplottingTool:GraphLineWIdth
	NVAR GraphUseSymbols = root:Packages:GeneralplottingTool:GraphUseSymbols
	NVAR GraphSymbolSize = root:Packages:GeneralplottingTool:GraphSymbolSize

	NVAR GraphBottomAxisMin = root:Packages:GeneralplottingTool:GraphBottomAxisMin
	NVAR GraphBottomAxisMax = root:Packages:GeneralplottingTool:GraphBottomAxisMax
	NVAR GraphLeftAxisMin = root:Packages:GeneralplottingTool:GraphLeftAxisMin
	NVAR GraphLeftAxisMax = root:Packages:GeneralplottingTool:GraphLeftAxisMax
	NVAR GraphBottomAxisAuto = root:Packages:GeneralplottingTool:GraphBottomAxisAuto
	NVAR GraphLeftAxisAuto = root:Packages:GeneralplottingTool:GraphLeftAxisAuto

	NVAR Graph3DAngle=root:Packages:GeneralplottingTool:Graph3DAngle
	NVAR Graph3DAxLength=root:Packages:GeneralplottingTool:Graph3DAxLength

	if(GraphBottomAxisAuto)
		SetAxis/W=PlotingToolWaterfallGrph/A bottom 
	else
		SetAxis/W=PlotingToolWaterfallGrph bottom GraphBottomAxisMin,GraphBottomAxisMax
	endif
	if(GraphLeftAxisAuto)
		SetAxis/W=PlotingToolWaterfallGrph/A left
	else
		SetAxis/W=PlotingToolWaterfallGrph left GraphLeftAxisMin,GraphLeftAxisMax
	endif
	Label/W=PlotingToolWaterfallGrph left GraphYAxisName
	Label/W=PlotingToolWaterfallGrph bottom GraphXAxisName
	ModifyGraph/W=PlotingToolWaterfallGrph log(left)=GraphLogY
	ModifyGraph/W=PlotingToolWaterfallGrph log(bottom)=GraphLogX
	ModifyGraph/W=PlotingToolWaterfallGrph lsize=GraphLineWIdth
	ModifyWaterfall/W=PlotingToolWaterfallGrph angle=Graph3DAngle, axlen= Graph3DAxLength, hidden= 2
	ModifyWaterfall/W=PlotingToolWaterfallGrph hidden= 3

end
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************

Function IR1P_genGraphCreateDataWF()
	//create data for the waterfall...

	NewDataFolder/O/S root:Packages:GeneralplottingTool:Waterfall
	SVAR ListOfDataFolderNames=root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR ListOfDataWaveNames=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	NVAR Graph3DClrMin = root:Packages:GeneralplottingTool:Graph3DClrMin
	NVAR Graph3DClrMax = root:Packages:GeneralplottingTool:Graph3DClrMax

	variable NumberOfWaves,i
		
	NumberOfWaves=ItemsInList(ListOfDataFolderNames)
	if(NumberOfWaves<2)
		abort "Not enough data in the tool, need at least 3 data sets"
	endif
	//need to figure out the Q scale first... Keeps failing if q(x)-scales vary. 
	Wave QWv=$(StringByKey("QWave0", ListOfDataWaveNames  , "="))
	Duplicate/O QWv, PlottingTool_Q						//this is first data set Q
	For(i=1;i<NumberOfWaves;i+=1)
		Wave QWv=$(StringByKey("QWave"+num2str(i), ListOfDataWaveNames  , "="))
		if(QWv[0] < PlottingTool_Q[0])		//data longer on low-q end
			Duplicate/Free/O/R=[0, BinarySearch(QWv,PlottingTool_Q[0])]  QWv, QWvStart
			Concatenate /NP /O  { QWvStart,PlottingTool_Q}, PlottingTool_QT
			Duplicate/O PlottingTool_QT, PlottingTool_Q
		endif
		if(PlottingTool_Q[numpnts(PlottingTool_Q)-1] < QWv[numpnts(QWv)-1])		//data longer on high-q end
			Duplicate/Free/O/R=[BinarySearch(QWv,PlottingTool_Q[numpnts(PlottingTool_Q)-1]), inf]  QWv, QWvEnd
			Concatenate /NP /O  {PlottingTool_Q, QWvEnd}, PlottingTool_QT
			Duplicate/O PlottingTool_QT, PlottingTool_Q			
		endif
	endfor
	
	Wave IntWv=$(StringByKey("IntWave0", ListOfDataWaveNames  , "="))
	Wave QWv=$(StringByKey("QWave0", ListOfDataWaveNames  , "="))
	Duplicate/O PlottingTool_Q, PlottingTool_Int_M
	//PlottingTool_Q is the final Q wave 
	variable StrtPnt, endpnt
	PlottingTool_Int_M = interp(PlottingTool_Q[p], QWv, IntWv )
	if(PlottingTool_Q[0]<QWv[0])
		StrtPnt = BinarySearch(PlottingTool_Q,QWv[0])
		PlottingTool_Int_M[0, StrtPnt]=NaN
	endif
	if(PlottingTool_Q[numpnts(PlottingTool_Q)-1]>QWv[numpnts(QWv)-1])
		endpnt = BinarySearch(PlottingTool_Q,QWv[numpnts(QWv)-1])
		PlottingTool_Int_M[endpnt+1, inf]=NaN
	endif
	
	
	For(i=1;i<NumberOfWaves;i+=1)
		Wave IntWv=$(StringByKey("IntWave"+num2str(i), ListOfDataWaveNames  , "="))
		Wave QWv=$(StringByKey("QWave"+num2str(i), ListOfDataWaveNames  , "="))
		Wave/Z EWv=$(StringByKey("EWave"+num2str(i), ListOfDataWaveNames  , "="))
		Redimension/N=(-1,i+1) PlottingTool_Int_M
		//PlottingTool_Int_M[][i]= IntWv[p]
		PlottingTool_Int_M[][i]= interp(PlottingTool_Q[p], QWv, IntWv )
		if(PlottingTool_Q[0]<QWv[0])
			StrtPnt = BinarySearch(PlottingTool_Q,QWv[0])
			PlottingTool_Int_M[0, StrtPnt][i]=NaN
		endif
		if(PlottingTool_Q[numpnts(PlottingTool_Q)-1]>QWv[numpnts(QWv)-1])
			endpnt = BinarySearch(PlottingTool_Q,QWv[numpnts(QWv)-1])
			PlottingTool_Int_M[endpnt+1, inf][i]=NaN
		endif
	endfor
	wavestats/Q PlottingTool_Int_M
	Graph3DClrMin = V_min
	Graph3DClrMax = V_max
	if(V_min<0)
		Duplicate/Free 	PlottingTool_Int_M, temp2Dwv
		temp2Dwv = temp2Dwv<0 ? Nan : temp2Dwv[p][q]
		wavestats/Q temp2Dwv
		Graph3DClrMin = V_min
	endif

	note/K PlottingTool_Q								//kill wave note, useless...
	note/K PlottingTool_Int_M								//kill wave note, useless...
	
end


//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
Function IR1P_MovieSetup()
	//this tool will setup Movie creation for Ploting tool I
	//
	//defined here: IR1P_InitializeGenGraph()	
	//ListOfVariables+="MovieUse2Dgraph;MovieUse3DGraph;MoiveReplaceData;MovieFrameRate;"
	//ListOfStrings+=""
	//use NI1A_CreateMoviesPanel as example...
	
	DoWindow IR1P_CreateMovie
	if(V_Flag)
		DoWIndow/F IR1P_CreateMovie
	else
		IR1P_CreateMovieFnct()
	endif
end

//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************

Function IR1P_Movie3DCreateGraphAddFrame(AddFrame)
	variable AddFrame 			//set to 1 if add frame, else just display for user
	
	NVAR Graph3DClrMax = root:Packages:GeneralplottingTool:Graph3DClrMax
	variable/g root:Packages:GeneralplottingTool:Graph3DClrMaxBckp
	NVAR Graph3DClrMaxBckp = root:Packages:GeneralplottingTool:Graph3DClrMaxBckp
	Graph3DClrMaxBckp = Graph3DClrMax
	
	NVAR Graph3DClrMin = root:Packages:GeneralplottingTool:Graph3DClrMin
	variable/g root:Packages:GeneralplottingTool:Graph3DClrMinBckp
	NVAR Graph3DClrMinBckp = root:Packages:GeneralplottingTool:Graph3DClrMinBckp
	Graph3DClrMinBckp = Graph3DClrMin

	NVAR Graph3DAxLength = root:Packages:GeneralplottingTool:Graph3DAxLength
	variable/g root:Packages:GeneralplottingTool:Graph3DAxLengthBckp
	NVAR Graph3DAxLengthBckp = root:Packages:GeneralplottingTool:Graph3DAxLengthBckp
	Graph3DAxLengthBckp = Graph3DAxLength

	//first need to grab list of displayed data sets as they are in the tool and store it separately...
	SVAR DataFoldersInTool= root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR DataWavenamesInTool=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	SVAR ListOfDataOrgWvNames = root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	variable NumOfDataSets=ItemsInList(DataFoldersInTool)
	String/G root:Packages:GeneralplottingTool:ListOfDataFolderNamesBckp
	String/G root:Packages:GeneralplottingTool:ListOfDataWaveNamesBckp
	String/G root:Packages:GeneralplottingTool:ListOfDataOrgWvNamesBckp
	SVAR StoredDataFoldersInTool= root:Packages:GeneralplottingTool:ListOfDataFolderNamesBckp
	SVAR StoredDataWavenamesInTool=root:Packages:GeneralplottingTool:ListOfDataWaveNamesBckp
	SVAR StoredListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataWaveNamesBckp
	StoredDataFoldersInTool= DataFoldersInTool
	StoredDataWavenamesInTool = DataWavenamesInTool
	StoredListOfDataOrgWvNames = ListOfDataOrgWvNames
	
	NVAR  MovieUse2Dgraph= root:Packages:GeneralplottingTool:MovieUse2Dgraph
	NVAR  MovieReplaceData= root:Packages:GeneralplottingTool:MovieReplaceData
	NVAR  MovieDisplayDelay= root:Packages:GeneralplottingTool:MovieDisplayDelay
	if(MovieUse2Dgraph)
		//in wrong place, abort...
		Abort "This function uses 2D graph"
	endif
	variable i
	String Fldrname
	String IntWvName, QWvName, EWvName
	DataFoldersInTool = ""
	DataWavenamesInTool = ""
	
	for(i=0;i<NumOfDataSets;i+=1)
		Fldrname = StringFromList(i,StoredDataFoldersInTool)
		IntWvName = StringByKey("IntWave"+num2str(i), StoredListOfDataOrgWvNames  , "=", ";")
		QWvName = StringByKey("QWave"+num2str(i), StoredListOfDataOrgWvNames  , "=", ";")
		EWvName = StringByKey("EWave"+num2str(i), StoredListOfDataOrgWvNames  , "=", ";")
		DataFoldersInTool += Fldrname+";"
		ListOfDataOrgWvNames = ReplaceStringByKey("IntWave"+num2str(i), ListOfDataOrgWvNames, IntWvName, "="  , ";")
		ListOfDataOrgWvNames = ReplaceStringByKey("QWave"+num2str(i), ListOfDataOrgWvNames, QWvName, "="  , ";")
		ListOfDataOrgWvNames = ReplaceStringByKey("EWave"+num2str(i), ListOfDataOrgWvNames, EWvName, "="  , ";")
		if(i>1)
			Graph3DClrMax = Graph3DClrMaxBckp
			Graph3DClrMin = Graph3DClrMinBckp
			SVAR FormatingStr=root:Packages:GeneralplottingTool:ListOfGraphFormating
			FormatingStr=ReplaceNumberByKey("Graph3D Clr Max", FormatingStr, Graph3DClrMax  , "=" )
			FormatingStr=ReplaceNumberByKey("Graph3D Clr Min", FormatingStr, Graph3DClrMin  , "=" )	
			Graph3DAxLength = i * Graph3DAxLengthBckp / NumOfDataSets
			Graph3DAxLength = (Graph3DAxLength<0.1)? 0.1 : Graph3DAxLength
			FormatingStr=ReplaceNumberByKey("Graph3D Ax Lengthy", FormatingStr, Graph3DClrMin  , "=" )	
			IR1P_Create3DGraph()
			IR1P_Color3DGraph(0)
			DoUpdate/W=PlotingToolWaterfallGrph
			DoUpdate/W=PlotingToolWaterfallGrph
			sleep/s MovieDisplayDelay
			if(AddFrame)
				DoWindow/F PlotingToolWaterfallGrph
				AddMovieFrame
			endif
		endif
	endfor
	
	
	//at the end we need to restore the tool back...
	DataFoldersInTool = StoredDataFoldersInTool
	DataWavenamesInTool = StoredDataWavenamesInTool
	ListOfDataOrgWvNames =  StoredListOfDataOrgWvNames
end

//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************

Function IR1P_Movie2DCreateGraphAddFrame(AddFrame)
	variable AddFrame 			//set to 1 if add frame, else just display for user
	
	//first need to grab list of displayed data sets as they are in the tool and store it separately...
	SVAR DataFoldersInTool= root:Packages:GeneralplottingTool:ListOfDataFolderNames
	SVAR DataWavenamesInTool=root:Packages:GeneralplottingTool:ListOfDataWaveNames
	SVAR ListOfDataOrgWvNames = root:Packages:GeneralplottingTool:ListOfDataOrgWvNames
	variable NumOfDataSets=ItemsInList(DataFoldersInTool)
	String/G root:Packages:GeneralplottingTool:ListOfDataFolderNamesBckp
	String/G root:Packages:GeneralplottingTool:ListOfDataWaveNamesBckp
	String/G root:Packages:GeneralplottingTool:ListOfDataOrgWvNamesBckp
	SVAR StoredDataFoldersInTool= root:Packages:GeneralplottingTool:ListOfDataFolderNamesBckp
	SVAR StoredDataWavenamesInTool=root:Packages:GeneralplottingTool:ListOfDataWaveNamesBckp
	SVAR StoredListOfDataOrgWvNames=root:Packages:GeneralplottingTool:ListOfDataWaveNamesBckp
	StoredDataFoldersInTool= DataFoldersInTool
	StoredDataWavenamesInTool = DataWavenamesInTool
	StoredListOfDataOrgWvNames = ListOfDataOrgWvNames
	
	NVAR  MovieUse2Dgraph= root:Packages:GeneralplottingTool:MovieUse2Dgraph
	NVAR  MovieReplaceData= root:Packages:GeneralplottingTool:MovieReplaceData
	NVAR  MovieDisplayDelay= root:Packages:GeneralplottingTool:MovieDisplayDelay
	if(!MovieUse2Dgraph)
		//in wrong place, abort...
		Abort "This function uses 2D graph"
	endif
	variable i
	String Fldrname
	String IntWvName, QWvName, EWvName
	DataFoldersInTool = ""
	DataWavenamesInTool = ""
	
	for(i=0;i<NumOfDataSets;i+=1)
		Fldrname = StringFromList(i,StoredDataFoldersInTool)
		IntWvName = StringByKey("IntWave"+num2str(i), StoredListOfDataOrgWvNames  , "=", ";")
		QWvName = StringByKey("QWave"+num2str(i), StoredListOfDataOrgWvNames  , "=", ";")
		EWvName = StringByKey("EWave"+num2str(i), StoredListOfDataOrgWvNames  , "=", ";")
		if(MovieReplaceData)
			DataFoldersInTool = Fldrname+";"
			ListOfDataOrgWvNames = ReplaceStringByKey("IntWave0", ListOfDataOrgWvNames, IntWvName, "="  , ";")
			ListOfDataOrgWvNames = ReplaceStringByKey("QWave0", ListOfDataOrgWvNames, QWvName, "="  , ";")
			ListOfDataOrgWvNames = ReplaceStringByKey("EWave0", ListOfDataOrgWvNames, EWvName, "="  , ";")
		else
			DataFoldersInTool += Fldrname+";"
			ListOfDataOrgWvNames = ReplaceStringByKey("IntWave"+num2str(i), ListOfDataOrgWvNames, IntWvName, "="  , ";")
			ListOfDataOrgWvNames = ReplaceStringByKey("QWave"+num2str(i), ListOfDataOrgWvNames, QWvName, "="  , ";")
			ListOfDataOrgWvNames = ReplaceStringByKey("EWave"+num2str(i), ListOfDataOrgWvNames, EWvName, "="  , ";")
		endif
		IR1P_CreateGraph()
		DoUpdate/W=GeneralGraph
		DoWindow/F GeneralGraph
		DoUpdate/W=GeneralGraph
		sleep/s MovieDisplayDelay
		if(AddFrame)
			DoWindow/F GeneralGraph
			AddMovieFrame
		endif
	endfor
	
	
	//at the end we need to restore the tool back...
	DataFoldersInTool = StoredDataFoldersInTool
	DataWavenamesInTool = StoredDataWavenamesInTool
	ListOfDataOrgWvNames =  StoredListOfDataOrgWvNames
end
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************


Function IR1P_CreateMovieFnct() : Panel
	//PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(376,264,674,504) as "Ploting tool I Create Movie"
	DoWIndow/C IR1P_CreateMovie
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 3,textrgb= (0,0,65535)
	DrawText 42,28,"Create Movie from Plots"
	SetDrawEnv fsize= 10
	DrawText 11,53,"Select what to use:"
	SetDrawEnv fsize= 10
	DrawText 11,137,"Set Frame rate:"
	SetDrawEnv fsize= 10
	DrawText 11,102,"Add or Replace in 2D:"
	NVAR MovieUse3DGraph = root:Packages:GeneralplottingTool:MovieUse3DGraph
	CheckBox MovieUse2Dgraph,pos={174,38},size={82,14},proc=IR1P_MovieCheckProc,title="Use 2D graph?"
	CheckBox MovieUse2Dgraph,variable= root:Packages:GeneralplottingTool:MovieUse2Dgraph
	CheckBox MovieUse3Dgraph,pos={174,58},size={82,14},proc=IR1P_MovieCheckProc,title="Use 3D graph?"
	CheckBox MovieUse3Dgraph,variable= root:Packages:GeneralplottingTool:MovieUse3DGraph
	SetVariable MovieFrameRate,pos={137,122},size={150,15},title="Frame rate="
	SetVariable MovieFrameRate,value= root:Packages:GeneralplottingTool:MovieFrameRate
	CheckBox MovieReplaceData,pos={174,87},size={79,14},proc=IR1P_MovieCheckProc,title="Replace data?"
	CheckBox MovieReplaceData,variable= root:Packages:GeneralplottingTool:MovieReplaceData, disable=MovieUse3DGraph
	Button TestMovie,pos={67,155},size={120,20},proc=IR1P_MovieButtonProc,title="Test how it will look"
	Button CreateMovie,pos={68,186},size={120,20},proc=IR1P_MovieButtonProc,title="Create Movie"
	SetVariable MovieDisplayDelay,pos={30,215},size={190,15},title="Delay for Display ="
	SetVariable MovieDisplayDelay,value= root:Packages:GeneralplottingTool:MovieDisplayDelay
End


//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************

Function IR1P_MovieCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR MovieUse2Dgraph=root:Packages:GeneralplottingTool:MovieUse2Dgraph
			NVAR MovieUse3DGraph=root:Packages:GeneralplottingTool:MovieUse3DGraph
			if(stringmatch("MovieUse2Dgraph",cba.ctrlName))
				MovieUse2Dgraph = checked
				MovieUse3DGraph = !checked
				CheckBox MovieReplaceData, disable=MovieUse3DGraph, win=IR1P_CreateMovie
			endif
			if(stringmatch("MovieUse3DGraph",cba.ctrlName))
				MovieUse3DGraph = checked
				MovieUse2DGraph = !checked
				CheckBox MovieReplaceData, disable=MovieUse3DGraph, win=IR1P_CreateMovie
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************

Function IR1P_MovieButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	NVAR MovieUse2Dgraph=root:Packages:GeneralplottingTool:MovieUse2Dgraph
	NVAR MovieUse3DGraph=root:Packages:GeneralplottingTool:MovieUse3DGraph
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlname,"CreateMovie"))
				IR1P_MovieOpenFile()
				if(MovieUse2Dgraph)
					IR1P_Movie2DCreateGraphAddFrame(1)
				elseif(MovieUse3DGraph)
					IR1P_Movie3DCreateGraphAddFrame(1)
				else
					print "Nothing to do, closing the file"
				endif
				IR1P_MovieCloseFile()
			endif
			if(stringmatch(ba.ctrlname,"TestMovie"))
				if(MovieUse2Dgraph)
					IR1P_Movie2DCreateGraphAddFrame(0)
				elseif(MovieUse3DGraph)
					IR1P_Movie3DCreateGraphAddFrame(0)
				else
					Abort "Nothing to do"
				endif
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************

Function IR1P_MovieOpenFile()

	NVAR MovieFrameRate=root:Packages:GeneralplottingTool:MovieFrameRate
	NVAR MovieFileOpened=root:Packages:GeneralplottingTool:MovieFileOpened
	NVAR MovieUse2Dgraph=root:Packages:GeneralplottingTool:MovieUse2Dgraph
	NVAR MovieUse3DGraph=root:Packages:GeneralplottingTool:MovieUse3DGraph
	
	if(MovieUse2Dgraph)
		DoWIndow GeneralGraph
		if(!V_Flag)
			Abort "2D graph must exists, create it first, please"
		else
			DoWIndow/F MovieUse2Dgraph
		endif
	elseif(MovieUse3DGraph)
	
	else
		abort "Please select first what to use - 2D or 3D graph"
	endif
	
	NewMovie/A/L /F=(MovieFrameRate)/I/Z
	if(V_Flag==-1)
		abort
	elseif(V_Flag!=0)
		abort "Error opening movie file" //user canceled or other error
	endif
	MovieFileOpened=1
	Execute("Button CreateMovie win=IR1P_CreateMovie, title=\"Movie file opened\", disable=2,fColor=(16386,65535,16385)")
end
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************

Function IR1P_MovieCloseFile()

	NVAR MovieFrameRate=root:Packages:GeneralplottingTool:MovieFrameRate
	NVAR MovieFileOpened=root:Packages:GeneralplottingTool:MovieFileOpened
	
	Variable DebugEnab
	DebuggerOptions
	DebugEnab = V_debugOnError 	//check for debug on error
	if (DebugEnab)					//if it is on,
		DebuggerOptions debugOnError=0	//turn it off
		Execute/P/Q/Z "DebuggerOptions debugOnError=1"	//make sure it gets turned back on
	endif
	CloseMovie
	Variable err = GetRTError(0)
	if (err != 0)
		String message = GetErrMessage(err)
		Printf "Error in Movie creation: %s\r", message
		err = GetRTError(1)						// Clear error state
		Print "Continuing execution"
	endif
	if (DebugEnab)
		DebuggerOptions debugOnError=1	//turn it back on
	endif
	MovieFileOpened=0
	Execute("Button CreateMovie win=IR1P_CreateMovie, title=\"Create Movie\",fColor=(0,0,0), disable=0")
end
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************
//*****************************************************************************************

//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
//************************************************************************************************************************
