#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.11
#include "In2_GeneralProcedures", version>=1.10	//we need functions from this file

Menu "USAXS"
	"---"
	"Size Distribution", IN2R_Sizes()
end


//this is Sizes procedure.
//this is list of procedures:
//	Data input is done by
	//IN2R_SelectAndCopyData()			//Procedure which loads data and sets work folder
	//IN2R_SetupFittingParameters()		//sets up the graph and panel to control the Sizes
	//
//	Calculate G[][]		done for spheres,
	//procedures:		GenerateShapeFunction()
	//				CalculateSphereFormFactor(FRwave,Qw,radius)	
	//				CalculateSphereFFPoints(Qvalue,radius)
	//				NormalizationFactorSphere(radius)
	//
	//	Units handling:
	//	drho^2 is in 10^20 cm-4, G matrix calculations need to be in cm, so volume of 
	//	particles is in cm3 (10-24 A3) and width of the sectors is in cm.
	//
	//
	//
//	Calculate H matrix	done,
	//procedures:		MakeHmatrix()
	//
//	CalculateBVector()	done, single procedure
	//makes new B vector and calculates values from G, Int and errors
	//	
//	CalculateDMatrix()
	//calculates D matrix from G[][] and errors
	//
//	CalculateAvalue()
	//calculates the A[][]= d[][] + a * H[][]
	//
//	FindOptimumAvalue(Evalue)	
	//does the fitting itself, call with precision (e~0.1 or so)
	// procedures : 	CalculateCvalue()	
	//				
	//this function does the whole Sizes procedure
	//List of waves, vectors, and matrixes
	//	works in root:Packages:Sizes
	//	Intensity	[M]
	//	Error	[M]
	//	Q_vec	[M]
	//	R_distribution	[N]		contains distribution of radia for particles, defines number of points in solution
	//	G_matrix		[M] [N]	Shape matrix, for now spheres
	//	H_matrix		[N] [N]	Constraint matrix, here done for second derivative
	//	B_vector		[N]			
	//	A_matrix	[N][N]
	//	D_matrix	[M][N]
	//	Evalue					precision, for now hardwired to 0.1
	//	Difference		chi squared sum of the difference value between the fit and measured intensity		
//units used:
//	All units internally are in A - Radius and Q ([A^-1]). 
//
//
//****************************************
// Main Evaluation procedure:
//****************************************
Function IN2R_Sizes()

	IN2G_UniversalFolderScan("root:USAXS:", 5, "IN2G_CheckTheFolderName()")  //here we fix the folder names/sample names in wave notes if necessary
			
	IN2R_SelectAndCopyData()			//Procedure which loads data and sets work folder
												//creates keyword-list with parameters of the process
	IN2R_SetupFittingParameters()			//here we create distribution of radia for sizes
end

//*********************************************************************************************
//*********************************************************************************************

Function IN2R_MaxentFitting(ctrlName) : ButtonControl			//this function is called by button from the panel
	String ctrlName
	
	NVAR MaxEntRegular
	if (cmpstr(ctrlname,"RunMaxent")==0)			//caleed to run maxent
		MaxEntRegular=1
	else
		MaxEntRegular=0						//called to run regularization
	endif
	
	If (cmpstr(IgorInfo(2),"Macintosh")==0)
		Abort "This works only on WIndows at this time"
	endif

//	abort "not finished yet"

	IN2R_FinishSetupOfMaxSasParam()	//finishes the setup of parametes for Sizes -may be needed here?
//first check for presence of the masas folder in Igor and create path, makes also tyhe batch file to run

	IN2R_SetupPath()

//here we need to first generate comand file
	IN2R_MakeMaxEntCmd()

//next generate data file
	IN2R_MakeMaxSasDta()

//run maxent
	IN2R_RunMaxsas()
	
//load data back into Igor		
	IN2R_LoadMaxentResults()

//and calculate chisquare	
	variable/G Chisquare=IN2R_CalcMaxasChiSquare()
	
//and here make sure we can use the data in next screen
	
	IN2R_FinishGraph()				//fishies the graph to proper shape
	
end	

Function IN2R_CalcMaxasChiSquare()			//calculates chisquared difference between the data
		//in Intensity and result calculated by G_matrix x x_vector
	Wave NormalizedResidual
	Duplicate/O NormalizedResidual, ChiSquaredWave

	ChiSquaredWave=NormalizedResidual^2			//and this is wave with ChiSquared

	return (sum(ChiSquaredWave,-inf,inf))				//return sum of chiSquared
end


Function IN2R_FinishSetupOfMaxSasParam()			//Finish the preparation for parameters selected in the panel

	Wave DeletePointsMaskWave
	Wave IntensityOriginal
	Wave Intensity
	Wave Q_vec
	Wave Q_vecOriginal
	Wave Errors
	Wave ErrorsOriginal
	SVAR ShapeType
	SVAR SizesParameters						
	SVAR LogDist
	SVAR SlitSmearedData
	NVAR Bckg
	NVAR numOfPoints
	NVAR Dmin
	NVAR Dmax
	NVAR Rmin
	NVAR Rmax
	NVAR AspectRatio
	NVAR ScatteringContrast
	NVAR ErrorsMultiplier

	Duplicate/O IntensityOriginal, Intensity						//here we return in the original data, which will be trimmed next
	Duplicate/O Q_vecOriginal, Q_vec
	Duplicate/O ErrorsOriginal, Errors
	
	Intensity=Intensity*(DeletePointsMaskWave/7)				//since DeletePointsMaskWave contains NaNs for points which we want to delete
															//at this moment we set these points in intensity to NaNs
	if ( ((strlen(CsrWave(A))!=0) && (strlen(CsrWave(B))!=0) ) && (pcsr (A)!=pcsr (B)) )	//this should make sure, that both cursors are in the graph and not on the same point
		IN2R_TrimData(Intensity,Q_vec,Errors)					//this trims the data with cursors
	endif
	
	IN2G_RemoveNaNsFrom3Waves(Intensity,Q_vec,Errors)		//this should remove NaNs from the important waves
	
	Rmax=Dmax/2										//create radia from user input
	Rmin=Dmin/2
	
	make /D/O/N=(numOfPoints) R_distribution, temp		//this part creates the distribution of radia
	if (cmpstr(LogDist,"no")==0)							//linear binninig
		R_distribution=Rmin+p*((Rmax-Rmin)/(numOfPoints-1))
	else													//log binnning (default)
		temp=log(Rmin)+p*((log(Rmax)-log(Rmin))/(numOfPoints-1))
		R_distribution=10^temp
	endif
	Killwaves temp										//kill this wave, not needed anymore

	Duplicate/O R_distribution D_distribution				//and create the Diameter distribution wave
	D_distribution*=2										//and put diameters there
	
	SizesParameters=ReplaceStringByKey("MaxSasNumPoints", SizesParameters, num2str(numOfPoints),"=")
	SizesParameters=ReplaceStringByKey("MaxSasRmin", SizesParameters, num2str(Rmin),"=")
	SizesParameters=ReplaceStringByKey("MaxSasRmax", SizesParameters, num2str(Rmax),"=")
	SizesParameters=ReplaceStringByKey("MaxSasErrorsMultiplier", SizesParameters, num2str(ErrorsMultiplier),"=")
	SizesParameters=ReplaceStringByKey("MaxSasLogRBinning", SizesParameters,LogDist,"=")
	SizesParameters=ReplaceStringByKey("MaxSasParticleShape", SizesParameters, ShapeType,"=")
	SizesParameters=ReplaceStringByKey("MaxSasBackground", SizesParameters, num2str(Bckg),"=")
	SizesParameters=ReplaceStringByKey("MaxSasAspectRatio", SizesParameters, num2str(AspectRatio),"=")
	SizesParameters=ReplaceStringByKey("MaxSasScatteringContrast", SizesParameters, num2str(ScatteringContrast),"=")
	SizesParameters=ReplaceStringByKey("MaxSasSlitSmearedData", SizesParameters, SlitSmearedData,"=")
end


Function IN2R_LoadMaxentResults()
	
	//first check that the files with output exist
	variable refnum
	wave IntensityOriginal
	string originalNote=note(IntensityOriginal)
	SVAR SizesParameters
	
	Open/R/Z=1/P=Igor refnum as "Indra2.fit"
	close /A
		
	if (V_Flag!=0)
		Abort "Maxent did not found solution"
	endif

	//OK, now we can load the data in
	
	Killwaves/Z wave0, wave1, wave2, wave3, wave4, wave5, wave6, wave7, wave8, wave9, wave10

	LoadWave/N/D/G/P=Igor "Indra2.fit"
	
	Duplicate/O wave0, Q_vec
	Duplicate/O wave1, Intensity
	Duplicate/O wave2, Errors
	Duplicate/O wave3, SizesFitIntensity
	Duplicate/O wave4, NormalizedResidual
	
	Killwaves/Z wave0, wave1, wave2, wave3, wave4, wave5, wave6, wave7, wave8, wave9, wave10

	LoadWave/N/D/G/P=Igor "Indra2.f-D"
	Duplicate/O wave0, D_distribution
	Duplicate/O wave1, CurrentResultSizeDistribution

	Killwaves/Z wave0, wave1, wave2, wave3, wave4, wave5, wave6, wave7, wave8, wave9, wave10
	

	IN2G_AppendStringToWaveNote("Q_vec",originalNote)	
	IN2G_AppendStringToWaveNote("Intensity",originalNote)	
	IN2G_AppendStringToWaveNote("Errors",originalNote)	
	IN2G_AppendStringToWaveNote("SizesFitIntensity",originalNote)	
	IN2G_AppendStringToWaveNote("D_distribution",originalNote)	
	IN2G_AppendStringToWaveNote("CurrentResultSizeDistribution",originalNote)	

	IN2G_AppendStringToWaveNote("Q_vec",SizesParameters)	
	IN2G_AppendStringToWaveNote("Intensity",SizesParameters)	
	IN2G_AppendStringToWaveNote("Errors",SizesParameters)	
	IN2G_AppendStringToWaveNote("SizesFitIntensity",SizesParameters)	
	IN2G_AppendStringToWaveNote("D_distribution",SizesParameters)	
	IN2G_AppendStringToWaveNote("CurrentResultSizeDistribution",SizesParameters)	

	IN2G_AppendorReplaceWaveNote("Q_vec","Wname","Q_vec")	
	IN2G_AppendorReplaceWaveNote("Intensity","Wname","Intensity")	
	IN2G_AppendorReplaceWaveNote("Errors","Wname","Errors")	
	IN2G_AppendorReplaceWaveNote("SizesFitIntensity","Wname","SizesFitIntensity")	
	IN2G_AppendorReplaceWaveNote("D_distribution","Wname","D_distribution")	
	IN2G_AppendorReplaceWaveNote("CurrentResultSizeDistribution","Wname","CurrentResultSizeDistribution")	

end


Function IN2R_SetupPath()
	
	variable refnum
	PathInfo Igor
	
//	NewPath/C/O/Q Maxent, S_Path+"Maxent:"
	
	Open/R/Z=1/P=Igor refnum as "SizesDos.exe"
	close /A
		
	if (V_Flag!=0)
		Abort "The Maxent program not found !"
	endif
	
	variable i
	string MyCommand, tempCommand=""
	tempCommand=StringFromList(0,S_Path,":")+":\\"
	For (i=1;i<ItemsInList(S_Path,":");i+=1)
		tempCommand+=StringFromList(i,S_Path,":")+"\\"
	endfor
	MyCommand="\""+tempCommand+"\""
	
		DoWindow RunMax
	if (V_Flag)
		DoWindow/K RunMax
	endif
	string nb = "RunMax"
	NewNotebook/V=0/N=$nb/F=0/V=1/K=0/W=(277.5,81.5,644.25,487.25) 
	Notebook $nb defaultTab=20, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb font="Arial", fSize=10, fStyle=0, textRGB=(0,0,0)
	Notebook $nb text="cd "+MyCommand+"\r"						//project name
	Notebook $nb text="SizesDos.exe\r"						//SAS file
	Notebook $nb text="exit\r"						//SAS file

	close/A
	SaveNotebook /O/P=Igor RunMax as "RunMax.bat"
	DoWindow/K RunMax


end

Function IN2R_RunMaxsas()
	
	variable i
	PathInfo Igor
	
	OpenNotebook /Z/P=Igor/V=0/N=Indra2fit "Indra2.fit"
	if (V_flag==0)
		DoWIndow/D/K Indra2fit
	endif
	OpenNotebook /Z/P=Igor/V=0/N=Indra2fd "Indra2.f-D"
	if (V_flag==0)
		DoWIndow/D/K Indra2fd
	endif
	
	string MyCommand, tempCommand=""
	tempCommand=StringFromList(0,S_Path,":")+":"+"\\"	 	//+"\\"
	For (i=1;i<ItemsInList(S_Path,":");i+=1)
		tempCommand+=StringFromList(i,S_Path,":")+"\\"	//+"\\"
	endfor
	MyCommand="\""+tempCommand	+"RunMax.bat\""
	
//print MyCommand
//
//		Variable t0= ticks			//thsi waits n sedconds, where ticks< (t0+60*n)
//		do
//		while( ticks < (t0+60*2) )
//	Silent 1
//	ExecuteScriptText MyCommand
	ExecuteScriptText "sizesdos.exe"
	//this script does not work on WindowsME, the program is run but returns error- "routine GetInf returned FALSE"
	//ask Pete what it means, but looks like the program does not find Indra2.cmd or Indra2.sas data
//	ExecuteScriptText "\"C:\\Program Files\\WaveMetrics\\Igor Pro Folder\\SizesDos.exe\""
	
//		//ExecuteScriptText  "c:\\test1\\Sdftp32.exe c:\\test1\\CARS3Put.FTP"
//		//   "C:\Program Files\WaveMetrics\Igor Pro Folder\Maxent\sizes.exe "  " C:\Program Files\WaveMetrics\Igor Pro Folder\Maxent\Indra2.com"
//		//this is what I need at command line:
//		//   C:\temp\sizesDos.exe  Indra2.com
//		//this works:
//		//ExecuteScriptText "\"c:\\temp\\sizesDos.exe  \"Indra2.com", important is to have the space within the ""
//	ExecuteScriptText "sizesDos.exe"		//I seem to be able to get this running only within Igor directory, and only on Win98
	
//		Variable t0= ticks			//thsi waits n sedconds, where ticks< (t0+60*n)
//		do
//		while( ticks < (t0+60*8) )
	DoAlert 0, "Wait for external Maximum entropy program to finish and click OK"
	
end

Function IN2R_MakeMaxSasDta()

	Wave Intensity
	Wave Q_vec
	Wave Errors
	
	Save/J/O/P=Igor /M="\r\n" Q_vec, Intensity, Errors as "Indra2.sas"
	// this flag  /M="\r\n" is for PC, Mac needs this flag to be removed

end


Function IN2R_MakeMaxEntCmd()

	NVAR numOfPoints=root:Packages:Sizes:numOfPoints
	NVAR AspectRatio=root:Packages:Sizes:AspectRatio
	NVAR SlitLength=root:Packages:Sizes:SlitLength
	NVAR Rmin=root:Packages:Sizes:Rmin
	NVAR Rmax=root:Packages:Sizes:Rmax
	NVAR Bckg=root:Packages:Sizes:Bckg
	NVAR ScatteringContrast=root:Packages:Sizes:ScatteringContrast
	NVAR Dmin=root:Packages:Sizes:Dmin
	NVAR Dmax=root:Packages:Sizes:Dmax
	NVAR ErrorsMultiplier=root:Packages:Sizes:ErrorsMultiplier
	SVAR SlitSmearedData=root:Packages:Sizes:SlitSmearedData
	SVAR fldrname=root:Packages:Sizes:fldrname
	SVAR SizesParameters=root:Packages:Sizes:SizesParameters
	SVAR LogDist=root:Packages:Sizes:LogDist
	SVAR ShapeType=root:Packages:Sizes:ShapeType
	NVAR MaxsasNumIter=root:Packages:Sizes:MaxsasNumIter
	NVAR MaxEntSkyBckg=root:Packages:Sizes:MaxEntSkyBckg
	NVAR MaxEntMultCoef=root:Packages:Sizes:MaxEntMultCoef
	NVAR MaxEntRegular
	
	Wave Q_vecOriginal
	DoWindow/F IN2R_SizesInputGraph
	
	variable Qmin=Q_vecOriginal[pcsr(A)]
	variable Qmax=Q_vecOriginal[pcsr(B)]	
	if (Qmin>Qmax)
		Qmin=Q_vecOriginal[pcsr(B)]
		Qmax=Q_vecOriginal[pcsr(A)]		
	endif
	
		DoWindow Maxsascom
	if (V_Flag)
		DoWindow/K Maxsascom
	endif
	string nb = "Maxsascom"
	NewNotebook/V=0/N=$nb/F=0/V=1/K=0/W=(277.5,81.5,644.25,487.25) 
	Notebook $nb defaultTab=20, statusWidth=238, pageMargins={72,72,72,72}
	Notebook $nb font="Arial", fSize=10, fStyle=0, textRGB=(0,0,0)
	Notebook $nb text="Indra2"+"\r"						//project name
	Notebook $nb text="Indra2.sas\r"						//SAS file
	Notebook $nb text=num2str(0.8*Qmin)+"       "+num2str(1.2*Qmax)+"\r"			//Q range to be fit
	Notebook $nb text=num2str(ScatteringContrast)+"\r"			//contrast
	Notebook $nb text="1\r"									//intensity multiplier (defualt to 1 here)
	Notebook $nb text=num2str(ErrorsMultiplier)+"\r"				//error multiplier
	Notebook $nb text=num2str(Bckg)+"\r"						//backgropund
	//if (cmpstr(ShapeType,"Spheroid")
	Notebook $nb text=num2str(1)+"\r"							//shape model - 1 is for spheroid, nothing else available
	//endif
	Notebook $nb text=num2str(AspectRatio)+"\r"				//aspect ratio
	if (cmpstr(LogDist,"yes")==0)								//log binning method
		Notebook $nb text=num2str(0)+"\r"						//log mehotd
	else
		Notebook $nb text=num2str(1)+"\r"						//lin mehotd
	endif

	Notebook $nb text=num2str(numOfPoints)+"\r"				//number of radia
	Notebook $nb text=num2str(Dmin)+"     "+num2str(Dmax)+"\r"			//dmin, dmacx
	Notebook $nb text=num2str(MaxEntMultCoef)+"\r"							//whatever
	Notebook $nb text=num2str(MaxEntSkyBckg)+"\r"								//default dist level
	Notebook $nb text=num2str(MaxsasNumIter)+"\r"						//max iterations,
	if (numtype(SlitLength)==2)
		SlitLength=0
	endif
	if (cmpstr(SlitSmearedData,"no")==0)			//desmeared data
		Notebook $nb text="0\r"						//slit length
	else
		Notebook $nb text=num2str(SlitLength)+"\r"						//slit length
	endif
	Notebook $nb text=num2str(0.0002)+"\r"						//dlambda/lambda
	Notebook $nb text=num2str(MaxEntRegular)+"\r"							//method

close/A
SaveNotebook /O/P=Igor Maxsascom as "Indra2.cmd"
DoWindow/K Maxsascom

end
//*********************************************************************************************
//*********************************************************************************************

Function IN2R_SizesFitting(ctrlName) : ButtonControl			//this function is called by button from the panel
	String ctrlName

	IN2R_FinishSetupOfRegParam()	//finishes the setup of parametes for Sizes

	SVAR SlitSmearedData
	if (cmpstr(SlitSmearedData, "Yes")==0)	//if we are working with slit smeared data
		IN2R_ExtendQVecForSmearing()	//here we extend them by slitLength
	endif		
		
	IN2R_GenerateGmatrix()			//this function creates G_matrix for given shape of particles

	if (cmpstr(SlitSmearedData, "Yes")==0)	//if we are working with slit smeared data
		IN2R_SmearGMatrix()			//here we smear the Columns in the G matrix
		IN2R_ShrinkGMatrixAfterSmearing()	//here we cut the G matrix back in length
	endif		

	IN2R_MakeHmatrix()				//creates H matrix
	
	IN2R_CalculateBVector()			//creates B vector
	
	IN2R_CalculateDMatrix()			//creates D matrix
	
	variable Evalue=0.1				//may not be needed in the future
	
	IN2R_FindOptimumAvalue(Evalue)	//does the  fitting for given e value, for now set here to a value 0.1
	
	IN2R_FinishGraph()				//fishies the graph to proper shape
	
	//note, the longest time takes D matrix and then G matrix. The others are fast.
end	

//*********************************************************************************************
//*********************************************************************************************

Function IN2R_SelectAndCopyData()		//this function selects data to be used and copies them with proper names to Sizes folder

	string FldrWithData					//this is where the original data are
		
	Prompt FldrWithData, "select folder with data", popup, IN2G_FindFolderWithWaveTypes("root:", 10, "*DSM*", 1)+";"+IN2G_FindFolderWithWaveTypes("root:", 10, "*SMR*", 1)		//this needs to be cutomized to give only folders with useful data

	DoPrompt "Select Folder with data", FldrWithData		//get user to tell us where the data are
	if (V_Flag)
		abort "User canceled"
	endif
	
	IN2G_AppendAnyText("\r************************************\r")
	IN2G_AppendAnyText("Started Size distribution fitting procedure")
	IN2G_AppendAnyText("Data:  \t"+FldrWithData)

	SetDataFolder $FldrWithData							//go to the data folder
	
	if (!DataFolderExists("root:Packages:Sizes"))		//create packages:Sizes folder, if it does not exist
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:Sizes
	endif
	
	string IntName, Qname, Ename						//strings with wave names 
	
	Prompt IntName, "Wave with Intensity data", popup, WaveList("*DSM_I*",";","" )+";"+WaveList("*SMR_I*",";","" )+";"+WaveList("*",";","" )			//IN2G_ConvertDataDirToList(DataFolderDir(2))
	Prompt Qname, "Wave with Q data", popup, WaveList("*DSM_Q*",";","" )+";"+WaveList("*SMR_Q*",";","" )+";"+WaveList("*",";","" )					//IN2G_ConvertDataDirToList(DataFolderDir(2))
	Prompt Ename, "Wave with Error data", popup, WaveList("*DSM_E*",";","" )+";"+WaveList("*SMR_E*",";","" )+";"+WaveList("*",";","" )				//IN2G_ConvertDataDirToList(DataFolderDir(2))
	
	DoPrompt "Select data to use in Sizes", IntName, Qname, Ename		//get user input on wave names
	if (V_Flag)
		abort "User canceled"
	endif
	
	Duplicate/O $Intname, root:Packages:Sizes:IntensityOriginal			//here goes original Intensity
	Duplicate/O $Intname, root:Packages:Sizes:Intensity					//and its second copy, for fixing
	Duplicate/O $Qname, root:Packages:Sizes:Q_vec					//Q vector 
	Duplicate/O $Qname, root:Packages:Sizes:Q_vecOriginal				//second copy of the Q vector
	Duplicate/O $Ename, root:Packages:Sizes:Errors						//errors
	Duplicate/O $Ename, root:Packages:Sizes:ErrorsOriginal
	
	string fldrName1=GetDataFolder(1)											//get where the data were
	SetDataFolder root:Packages:Sizes									//go into the packages/Sizes folder

	SVAR/Z SlitSmearedData
	if (!SVAR_Exists(SlitSmearedData))
		string/G SlitSmearedData="No"
		SVAR SlitSmearedData
	endif
	if (stringMatch(IntName,"*SMR*"))								//if we are working with slit smeared data
		SlitSmearedData="Yes"									//lets set user the switch
	else
		SlitSmearedData="No"
	endif		

	string/G fldrName=fldrName1												//record parameters there
	String/G SizesParameters
	SizesParameters=ReplaceStringByKey("SizesDataFrom", SizesParameters, fldrName,"=")
	SizesParameters=ReplaceStringByKey("SizesIntensity", SizesParameters, Intname,"=")
	SizesParameters=ReplaceStringByKey("SizesQvector", SizesParameters, Qname,"=")
	SizesParameters=ReplaceStringByKey("SizesError", SizesParameters, Ename,"=")
end

//*********************************************************************************************
//*********************************************************************************************

Function IN2R_SetupFittingParameters()			//dialog for radius wave creation, simple linear binning now.

	NVAR/Z MaxEntSkyBckg
	if (!NVAR_Exists(MaxEntSkyBckg))
		variable/G MaxEntSkyBckg=1e-6
		NVAR MaxEntSkyBckg
	endif

	NVAR/Z MaxEntRegular
	if (!NVAR_Exists(MaxEntRegular))
		variable/G MaxEntRegular=1
		NVAR MaxEntRegular
	endif

	NVAR/Z MaxEntMultCoef
	if (!NVAR_Exists(MaxEntMultCoef))
		variable/G MaxEntMultCoef=1
		NVAR MaxEntMultCoef
	endif

	NVAR/Z MaxsasNumIter
	if (!NVAR_Exists(MaxsasNumIter))
		variable/G MaxsasNumIter=32
		NVAR MaxsasNumIter
	endif

	NVAR/Z numOfPoints
	if (!NVAR_Exists(numOfPoints))
		variable/G numOfPoints=40
		NVAR numOfPoints
	endif

	NVAR/Z AspectRatio
	if (!NVAR_Exists(AspectRatio))
		variable/G AspectRatio=1
		NVAR AspectRatio
	endif

	NVAR/Z SlitLength
	if (!NVAR_Exists(SlitLength))
		variable/G SlitLength=NumberByKey("SlitLength", Note(Intensity), "=")
		NVAR SlitLength
	endif

	NVAR/Z Rmin
	if (!NVAR_Exists(Rmin))
		variable/G Rmin=25
		NVAR Rmin
	endif
	
	NVAR/Z Rmax
	if (!NVAR_Exists(Rmax))
		variable/G Rmax=1000
		NVAR Rmax
	endif
	
	NVAR/Z Bckg
	if (!NVAR_Exists(Bckg))
		variable/G Bckg=0.1
		NVAR Bckg
	endif
	
	NVAR/Z ScatteringContrast
	if (!NVAR_Exists(ScatteringContrast))
		variable/G ScatteringContrast=1
		NVAR ScatteringContrast
	endif
	
	NVAR/Z Dmin
	if (!NVAR_Exists(Dmin))
		variable/G Dmin=25
		NVAR Dmin
	endif

	NVAR/Z Dmax
	if (!NVAR_Exists(Dmax))
		variable/G Dmax=1000
		NVAR Dmax
	endif

	NVAR/Z ErrorsMultiplier
	if (!NVAR_Exists(ErrorsMultiplier))
		variable/G ErrorsMultiplier=1
		NVAR ErrorsMultiplier
	endif

	SVAR/Z LogDist
	if (!SVAR_Exists(LogDist))
		string/G LogDist="yes"
		SVAR LogDist
	endif

	SVAR/Z ShapeType
	if (!SVAR_Exists(ShapeType))
		string/G ShapeType="Spheroid"	
		SVAR ShapeType
	endif

	SVAR/Z SlitSmearedData
	if (!SVAR_Exists(SlitSmearedData))
		string/G SlitSmearedData="no"	
		SVAR SlitSmearedData
	endif

	IN2R_RecoverOldParameters()							//this function recovers fitting parameters, if sizes were run already on the data

	Wave IntensityOriginal
	Wave ErrorsOriginal

	Duplicate/O IntensityOriginal BackgroundWave			//this background wave is to help user to subtract background
	Duplicate/O IntensityOriginal DeletePointsMaskWave		//this wave is used to delete points by using this as amark wave and seting points to 
	Duplicate/O ErrorsOriginal DeletePointsMaskErrorWave		//delete to NaN. Then Intensity is at appropriate time mulitplied by this wave (and divided)
														//to set points to delete to NaNs
	DeletePointsMaskWave=7								//this is symbol number used...
	BackgroundWave=Bckg
	
	
	Execute("IN2R_SizesInputGraph()")				//this creates the graph
	Execute("IN2R_SizesInputPanel()")				//this panel
	IN2G_AutoAlignGraphAndPanel()						//this aligns them together
end

Function IN2R_RecoverOldParameters()
	
	SVAR fldrName
	NVAR MaxEntSkyBckg
	NVAR MaxEntRegular
	NVAR MaxEntMultCoef
	NVAR MaxsasNumIter
	NVAR numOfPoints
	NVAR AspectRatio
	NVAR SlitLength
	NVAR Rmin
	NVAR Rmax
	NVAR Bckg
	NVAR ScatteringContrast
	NVAR Dmin
	NVAR Dmax
	NVAR ErrorsMultiplier
	SVAR LogDist
	SVAR ShapeType
	SVAR SlitSmearedData

	variable DataExists=0

	Wave/Z OldDistribution=$(fldrName+"SizesVolumeDistribution")
	if (WaveExists(OldDistribution))
		DoAlert 1, "Previous Size distribution results exist, recover old used fitting parameters (YES) or use default ones (NO)?"		
		DataExists=V_Flag
	endif

	if (DataExists==1)
		string OldNote=note(OldDistribution)
		numOfPoints=NumberByKey("RegNumPoints", OldNote,"=")
		Rmin=NumberByKey("RegRmin", OldNote,"=")
		Dmin=2*NumberByKey("RegRmin", OldNote,"=")
		Rmax=NumberByKey("RegRmax", OldNote,"=")
		Dmax=2*NumberByKey("RegRmax", OldNote,"=")
		ErrorsMultiplier=NumberByKey("RegErrorsMultiplier", OldNote,"=")
		Bckg=NumberByKey("RegBackground", OldNote,"=")
		AspectRatio=NumberByKey("RegAspectRatio", OldNote,"=")
		ScatteringContrast=NumberByKey("RegScatteringContrast", OldNote,"=")
	
		LogDist=StringByKey("RegLogRBinning", OldNote,"=")
		ShapeType=StringByKey("RegParticleShape", OldNote,"=")
	
	endif

end


//*********************************************************************************************
//*********************************************************************************************

Function IN2R_FinishSetupOfRegParam()			//Finish the preparation for parameters selected in the panel

	Wave DeletePointsMaskWave
	Wave IntensityOriginal
	Wave Intensity
	Wave Q_vec
	Wave Q_vecOriginal
	Wave Errors
	Wave ErrorsOriginal
	SVAR ShapeType
	SVAR SizesParameters						
	SVAR LogDist
	SVAR SlitSmearedData
	NVAR Bckg
	NVAR numOfPoints
	NVAR Dmin
	NVAR Dmax
	NVAR Rmin
	NVAR Rmax
	NVAR AspectRatio
	NVAR ScatteringContrast
	NVAR ErrorsMultiplier

	Duplicate/O IntensityOriginal, Intensity						//here we return in the original data, which will be trimmed next
	Duplicate/O Q_vecOriginal, Q_vec
	Duplicate/O ErrorsOriginal, Errors
	
	Errors=ErrorsMultiplier*ErrorsOriginal						//mulitply the erros by user selected multiplier
	
	Intensity=Intensity*(DeletePointsMaskWave/7)				//since DeletePointsMaskWave contains NaNs for points which we want to delete
															//at htis moment we set these points in intensity to NaNs
	Intensity=Intensity-Bckg							//subtract background from Intensity
	
	if ( ((strlen(CsrWave(A))!=0) && (strlen(CsrWave(B))!=0) ) && (pcsr (A)!=pcsr (B)) )	//this should make sure, that both cursors are in the graph and not on the same point
		IN2R_TrimData(Intensity,Q_vec,Errors)					//this trims the data with cursors
	endif
	
	IN2G_RemoveNaNsFrom3Waves(Intensity,Q_vec,Errors)		//this should remove NaNs from the important waves
	
	Rmax=Dmax/2										//create radia from user input
	Rmin=Dmin/2
	
	make /D/O/N=(numOfPoints) R_distribution, temp		//this part creates the distribution of radia
	if (cmpstr(LogDist,"no")==0)							//linear binninig
		R_distribution=Rmin+p*((Rmax-Rmin)/(numOfPoints-1))
	else													//log binnning (default)
		temp=log(Rmin)+p*((log(Rmax)-log(Rmin))/(numOfPoints-1))
		R_distribution=10^temp
	endif
	Killwaves temp										//kill this wave, not needed anymore

	Duplicate/O R_distribution D_distribution				//and create the Diameter distribution wave
	D_distribution*=2										//and put diameters there
	
	SizesParameters=ReplaceStringByKey("RegNumPoints", SizesParameters, num2str(numOfPoints),"=")
	SizesParameters=ReplaceStringByKey("RegRmin", SizesParameters, num2str(Rmin),"=")
	SizesParameters=ReplaceStringByKey("RegRmax", SizesParameters, num2str(Rmax),"=")
	SizesParameters=ReplaceStringByKey("RegErrorsMultiplier", SizesParameters, num2str(ErrorsMultiplier),"=")
	SizesParameters=ReplaceStringByKey("RegLogRBinning", SizesParameters,LogDist,"=")
	SizesParameters=ReplaceStringByKey("RegParticleShape", SizesParameters, ShapeType,"=")
	SizesParameters=ReplaceStringByKey("RegBackground", SizesParameters, num2str(Bckg),"=")
	SizesParameters=ReplaceStringByKey("RegAspectRatio", SizesParameters, num2str(AspectRatio),"=")
	SizesParameters=ReplaceStringByKey("RegScatteringContrast", SizesParameters, num2str(ScatteringContrast),"=")
	SizesParameters=ReplaceStringByKey("RegSlitSmearedData", SizesParameters, SlitSmearedData,"=")
end

//*********************************************************************************************
//*********************************************************************************************

Function IN2R_TrimData(wave1, wave2, wave3) 				//this is local trimming procedure
	Wave wave1, wave2, wave3
	
	variable AP=pcsr (A)
	variable BP=pcsr (B)
	
	deletePoints 0, AP, wave1, wave2, wave3
	variable newLength=numpnts(wave1)
	deletePoints (BP-AP+1), (newLength),  wave1, wave2, wave3
End

//*********************************************************************************************
//*********************************************************************************************

Function IN2R_GenerateGmatrix()								//here we create G matrix, this takes most time 
	//this function creates G  matrix, Q_vec is q vector distribution, R_distribution is radia distribution
	Wave Q_vec
	Wave R_distribution
	SVAR ShapeType
	NVAR AspectRatio
	
	variable M=numpnts(Q_vec)
	variable N=numpnts(R_distribution)
	Make/D/O/N=(M,N) G_matrix							//note that all matrices and vectors (waves) need to be double precission!!!
	Make/D/O/N=(M) TempWave
	variable i=0, currentR
	
	For (i=0;i<N;i+=1)										//calculate the G matrix in columns!!!
		currentR=R_distribution[i]							//this is current radius
		if (cmpstr(ShapeType,"Spheroid")==0)
			if ((AspectRatio<=1.05)&&(AspectRatio>=0.95))
				IN2R_CalculateSphereFormFactor(TempWave,Q_vec,currentR)	//here we calculate one column of data
				TempWave*=IN2R_SphereVolume(currentR)					//multiply by volume of sphere
				TempWave*=IN2R_BinWidthInRadia(i)							//multiply by the width of radia bin (delta r)
				G_matrix[][i]=TempWave[p]								//and here put it into G wave
			else
				IN2R_CalcSpheroidFormFactor(TempWave,Q_vec,currentR,AspectRatio)	//here we calculate one column of data
				TempWave*=IN2R_SpheroidVolume(currentR,AspectRatio)					//multiply by volume of sphere
				TempWave*=IN2R_BinWidthInRadia(i)							//multiply by the width of radia bin (delta r)
				G_matrix[][i]=TempWave[p]								//and here put it into G wave
			endif
		else
			Abort "other shapes not coded yet, G_matrix not created"
		endif
	endfor
	//here we have corrections for units and contrast
	G_matrix*=1e-24			//this is conversion for Volume of particles from A to cm
	NVAR ScatteringContrast
	G_matrix*=ScatteringContrast*1e20		//this multiplyies by scattering contrast
//	G_matrix*=1e-8			//this fixes the width of the bin from A to cm 
	
end
//*********************************************************************************************
//*********************************************************************************************

Function IN2R_BinWidthInRadia(i)			//calculates the width in radia by taking half distance to point before and after
	variable i								//returns number in A
	Wave R_distribution
	variable width
	variable Imax=numpnts(R_distribution)
	
	if (i==0)
		width=R_distribution[1]-R_distribution[0]
	elseif (i==Imax-1)
		width=R_distribution[i]-R_distribution[i-1]
	else
		width=((R_distribution[i]-R_distribution[i-1])/2)+((R_distribution[i+1]-R_distribution[i])/2)
	endif
	return width
end


//**************************************************************************************************************
//**************************************************************************************************************

Function IN2R_CalculateSphereFormFactor(FRwave,Qw,radius)	
	Wave Qw,FRwave					//returns column (FRwave) for column of Qw and radius
	Variable radius	
	
	FRwave=IN2R_CalculateSphereFFPoints(Qw[p],radius)		//calculates the formula 
	FRwave*=FRwave											//second power of the value
end


Function IN2R_CalculateSphereFFPoints(Qvalue,radius)
	variable Qvalue, radius										//does the math for Sphere Form factor function
	variable QR=Qvalue*radius

	return (3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))
end

Function IN2R_SphereVolume(radius)							//returns the sphere...
	variable radius
	return ((4/3)*pi*radius*radius*radius)
end
//*********************************************************************************************
//*********************************************************************************************
Function IN2R_CalcSpheroidFormFactor(FRwave,Qw,radius,AR)	
	Wave Qw,FRwave					//returns column (FRwave) for column of Qw and radius
	Variable radius, AR	
	
	FRwave=IN2R_CalcIntgSpheroidFFPoints(Qw[p],radius,AR)	//calculates the formula 
	FRwave*=FRwave											//second power of the value
end


Function IN2R_CalcIntgSpheroidFFPoints(Qvalue,radius,AR)		//we have to integrate from 0 to 1 over cos(th)
	variable Qvalue, radius	, AR
	
	Make/O/N=50 IntgWave
	SetScale/P x 0,0.02,"", IntgWave
	IntgWave=IN2R_CalcSpheroidFFPoints(Qvalue,radius,AR, x)	//this 
	variable result= area(IntgWave, 0,1)
	KillWaves IntgWave
	return result
end

Function IN2R_CalcSpheroidFFPoints(Qvalue,radius,AR,CosTh)
	variable Qvalue, radius	, AR, CosTh							//does the math for Spheroid Form factor function
	variable QR=Qvalue*radius*sqrt(1+(((AR*AR)-1)*CosTh*CosTh))

	return (3/(QR*QR*QR))*(sin(QR)-(QR*cos(QR)))
end

Function IN2R_SpheroidVolume(radius,AspectRatio)							//returns the spheroid volume...
	variable radius, AspectRatio
	return ((4/3)*pi*radius*radius*radius*AspectRatio)				//what is the volume of spheroid?
end


//*********************************************************************************************
//*********************************************************************************************

Function IN2R_MakeHmatrix()									//makes the H matrix
	Wave R_distribution
	
	variable numOfPoints=numpnts(R_Distribution), i=0, j=0

	Make/D/O/N=(numOfPoints,numOfPoints) H_matrix			//make the matrix
	H_matrix=0												//zero the matrix
	
	For(i=2;i<numOfPoints-2;i+=1)								//this fills with 1 -4 6 -4 1 most of the matrix
		For(j=0;j<numOfPoints;j+=1)
			if(j==i-2)
				H_matrix[i][j]=1
			endif
			if(j==i-1)
				H_matrix[i][j]=-4
			endif
			if(j==i)
				H_matrix[i][j]=6
			endif
			if(j==i+1)
				H_matrix[i][j]=-4
			endif
			if(j==i+2)
				H_matrix[i][j]=1
			endif
		endfor
	endfor
															//now we need to fill in the first and last parts
	H_matrix[0][0]=1											//beginning of the H matrix
	H_matrix[0][1]=-2
	H_matrix[0][2]=1
	H_matrix[1][0]=-2
	H_matrix[1][1]=5
	H_matrix[1][2]=-4
	H_matrix[1][3]=1

	H_matrix[numOfPoints-2][numOfPoints-4]=1					//end of the H matrix
	H_matrix[numOfPoints-2][numOfPoints-3]=-4
	H_matrix[numOfPoints-2][numOfPoints-2]=5
	H_matrix[numOfPoints-2][numOfPoints-1]=-2
	H_matrix[numOfPoints-1][numOfPoints-3]=1
	H_matrix[numOfPoints-1][numOfPoints-2]=-2
	H_matrix[numOfPoints-1][numOfPoints-1]=1
end

//*********************************************************************************************
//*********************************************************************************************

Function IN2R_CalculateBVector()								//makes new B vector and calculates values from G, Int and errors
	
	Wave G_matrix
	Wave Intensity
	Wave Errors
	
	variable M=DimSize(G_matrix, 0)							//rows, i.e, measured points number
	variable N=DimSize(G_matrix, 1)							//columns, i.e., bins in distribution
	variable i=0, j=0
	Make/D/O/N=(N) B_vector									//points = bins in size dist.
	B_vector=0
	for (i=0;i<N;i+=1)					
		For (j=0;j<M;j+=1)
			B_vector[i]+=((G_matrix[j][i]*Intensity[j])/(Errors[j]*Errors[j]))
		endfor
	endfor
end


//*********************************************************************************************
//*********************************************************************************************

Function IN2R_CalculateDMatrix()								//makes new D matrix and calculates values from G, Int and errors
	
	Wave G_matrix
	Wave Errors
	
	variable N=DimSize(G_matrix, 1)							//rows, i.e, measured points number
	variable M=DimSize(G_matrix, 0)							//columns, i.e., bins in distribution
	variable i=0, j=0, k=0
	Make/D/O/N=(N,N) D_matrix	
	Duplicate Errors, Errors2
	Errors2=Errors^2
			
	D_matrix=0
	
	for (i=0;i<N;i+=1)					
		for (k=0;k<N;k+=1)					
			For (j=0;j<M;j+=1)
				D_matrix[i][k]+=(G_matrix[j][i]*G_matrix[j][k])/(Errors2[j])
			endfor
		endfor
	endfor
	KillWaves Errors2
end

//*********************************************************************************************
//*********************************************************************************************

Function IN2R_FindOptimumAvalue(Evalue)						//does the fitting itself, call with precision (e~0.1 or so)
	variable Evalue	

	Wave Intensity

	variable LogAmax=100, LogAmin=-100, M=numpnts(Intensity)
	variable tolerance=Evalue*sqrt(2*M)
	variable ChiSquared, MidPoint, Avalue, i=0
	do
		MidPoint=(LogAmax+LogAmin)/2
		Avalue=10^MidPoint								//calculate A
		IN2R_CalculateAmatrix(Avalue)
		MatrixLUD A_matrix								//decompose A_matrix 
		Wave M_Lower									//results in these matrices for next step:
		Wave M_Upper
		Wave W_LUPermutation
		Wave B_vector
		MatrixLUBkSub M_Lower, M_Upper, W_LUPermutation, B_vector				//Backsubstitute B to get x[]=inverse(A[][]) B[]	
		Wave M_x										//this is created by MatrixMultiply

		Redimension/N=(-1,0) M_x							//create from M_x[..][0] only M_x[..] so it is simple wave
		Duplicate/O M_x CurrentResultSizeDistribution		//put the data into the wave 
		Note/K CurrentResultSizeDistribution
		Note CurrentResultSizeDistribution, note(intensity)
		CurrentResultSizeDistribution/=2					//this fixes conversion to presentation in diameters
		
		ChiSquared=IN2R_CalculateChiSquare()				//Calculate C 	C=|| I - G M_x ||

		print num2str(i+1)+")     Chi squared value:  " + num2str(ChiSquared) + ",    target value:   "+num2str(M)

		if (ChiSquared>M)
			LogAMax=MidPoint
		else
			LogAmin=MidPoint
		endif
		i+=1
		if (i>40)											//no solution found
			abort "too many iterations..."
		endif
	while(abs(ChiSquared-M)>tolerance)
	
	variable/G Chisquare=ChiSquared

	
	SVAR 	SizesParameters						//record the data
	SizesParameters=ReplaceStringByKey("RegIterations", SizesParameters, num2str(i),"=")
	SizesParameters=ReplaceStringByKey("RegChiSquared", SizesParameters, num2str(ChiSquared),"=")
	SizesParameters=ReplaceStringByKey("RegFinalAparam", SizesParameters, num2str(Avalue),"=")

	IN2G_AppendAnyText("Fitted with following parameters :\r"+SizesParameters)

end
//*********************************************************************************************
//*********************************************************************************************

Function IN2R_CalculateAmatrix(aValue)					//generates A matrix
	variable aValue
	Wave D_matrix
	Wave H_matrix
	
	Duplicate/O D_matrix A_matrix
	A_matrix=0
	A_matrix=D_matrix[p][q]+aValue*H_matrix[p][q]
end

//*********************************************************************************************
//*********************************************************************************************

Function IN2R_CalculateChiSquare()			//calculates chisquared difference between the data
		//in Intensity and result calculated by G_matrix x x_vector
	Wave Intensity
	Wave G_matrix
	Wave Errors
	Wave M_x

	Duplicate/O Intensity, NormalizedResidual, ChiSquaredWave	//waves for data
	IN2G_AppendorReplaceWaveNote("NormalizedResidual","Units"," ")
	
	
	MatrixMultiply  G_matrix, M_x				//generates scattering intesity from current result (M_x - before correction for contrast and diameter)
	Wave M_product	
	Redimension/N=(-1,0) M_product			//again make the matrix with one dimension 0 into regular wave

	Duplicate/O M_product SizesFitIntensity
	Note/K SizesFitIntensity
	Note SizesFitIntensity, note(Intensity)

	NormalizedResidual=(Intensity-M_product)/Errors		//we need this for graph
	ChiSquaredWave=NormalizedResidual^2			//and this is wave with ChiSquared
	return (sum(ChiSquaredWave,-inf,inf))				//return sum of chiSquared
end

//*********************************************************************************************
//*********************************************************************************************

Function IN2R_FinishGraph()			//finish the graph to proper way,  this will be really difficult to make Mac compatible
	string fldrName
	Wave CurrentResultSizeDistribution
	Wave D_distribution
	Wave SizesFitIntensity
	Wave Q_vec
	Wave IntensityOriginal
	Wave NormalizedResidual
	Wave Q_vecOriginal
	SVAR SizesParameters
	Wave BackgroundWave
	
	variable csrApos
	variable csrBpos
	
	if (strlen(csrWave(A))!=0)
		csrApos=pcsr(A)
	else
		csrApos=0
	endif	
	 
	if (strlen(csrWave(B))!=0)
		csrBpos=pcsr(B)
	else
		csrBpos=numpnts(IntensityOriginal)-1
	endif	

	PauseUpdate
	RemoveFromGraph/Z/W=IN2R_SizesInputGraph SizesFitIntensity
	RemoveFromGraph/Z/W=IN2R_SizesInputGraph BackgroundWave
	RemoveFromGraph/Z/W=IN2R_SizesInputGraph CurrentResultSizeDistribution
	RemoveFromGraph/Z/W=IN2R_SizesInputGraph NormalizedResidual
	RemoveFromGraph/Z/W=IN2R_SizesInputGraph IntensityOriginal
	RemoveFromGraph/Z/W=IN2R_SizesInputGraph Intensity
	
	AppendToGraph/T/R/W=IN2R_SizesInputGraph CurrentResultSizeDistribution vs D_distribution
	
	WaveStats/Q CurrentResultSizeDistribution
	if (V_min>0)
		SetAxis/N=1 right 0,V_max*1.1 
	else
		SetAxis/N=1 right -(V_max*0.1),V_max*1.1
	endif
	AppendToGraph/W=IN2R_SizesInputGraph Intensity vs Q_vec
	AppendToGraph/W=IN2R_SizesInputGraph SizesFitIntensity vs Q_vec
	AppendToGraph/W=IN2R_SizesInputGraph BackgroundWave vs Q_vecOriginal
	AppendToGraph/W=IN2R_SizesInputGraph IntensityOriginal vs Q_vecOriginal
	AppendToGraph/W=IN2R_SizesInputGraph/L=ChiSquaredAxis NormalizedResidual vs Q_vec
	ModifyGraph/W=IN2R_SizesInputGraph log(left)=1
	ModifyGraph/W=IN2R_SizesInputGraph log(bottom)=1
	Label/W=IN2R_SizesInputGraph top "Particle diameter [A]"
	ModifyGraph/W=IN2R_SizesInputGraph lblMargin(top)=30,lblLatPos(top)=100
	Label/W=IN2R_SizesInputGraph right "Particle vol. distribution f(D)"
	Label/W=IN2R_SizesInputGraph left "Intensity"
	ModifyGraph/W=IN2R_SizesInputGraph lblPos(left)=50
	ModifyGraph/W=IN2R_SizesInputGraph lblMargin(right)=20
	Label/W=IN2R_SizesInputGraph bottom "Q vector [A\\S-1\\M]"	
	ModifyGraph/W=IN2R_SizesInputGraph axisEnab(left)={0.15,1}
	ModifyGraph/W=IN2R_SizesInputGraph axisEnab(right)={0.15,1}
	ModifyGraph/W=IN2R_SizesInputGraph lblMargin(top)=30
	ModifyGraph/W=IN2R_SizesInputGraph axisEnab(ChiSquaredAxis)={0,0.15}
	ModifyGraph/W=IN2R_SizesInputGraph freePos(ChiSquaredAxis)=0
	Label/W=IN2R_SizesInputGraph ChiSquaredAxis "Residuals"
	ModifyGraph/W=IN2R_SizesInputGraph lblPos(ChiSquaredAxis)=50,lblLatPos=0
	ModifyGraph/W=IN2R_SizesInputGraph mirror(ChiSquaredAxis)=1
	SetAxis/W=IN2R_SizesInputGraph /A/E=2 ChiSquaredAxis
	ModifyGraph/W=IN2R_SizesInputGraph nticks(ChiSquaredAxis)=3

	ModifyGraph/W=IN2R_SizesInputGraph mode(Intensity)=3,marker(Intensity)=5,msize(Intensity)=3
	
	Cursor/P/W=IN2R_SizesInputGraph A IntensityOriginal, csrApos
	Cursor/P/W=IN2R_SizesInputGraph B IntensityOriginal, csrBpos
	
	ModifyGraph/W=IN2R_SizesInputGraph rgb(SizesFitIntensity)=(0,0,52224)	
	ModifyGraph/W=IN2R_SizesInputGraph lstyle(BackgroundWave)=3

	ModifyGraph/W=IN2R_SizesInputGraph mode(IntensityOriginal)=3
	ModifyGraph/W=IN2R_SizesInputGraph msize(IntensityOriginal)=2
	ModifyGraph/W=IN2R_SizesInputGraph rgb(IntensityOriginal)=(0,52224,0)
	ModifyGraph/W=IN2R_SizesInputGraph zmrkNum(IntensityOriginal)={DeletePointsMaskWave}
	ErrorBars/W=IN2R_SizesInputGraph IntensityOriginal Y,wave=(DeletePointsMaskErrorWave,DeletePointsMaskErrorWave)

	ModifyGraph/W=IN2R_SizesInputGraph mode(CurrentResultSizeDistribution)=5
	ModifyGraph/W=IN2R_SizesInputGraph hbFill(CurrentResultSizeDistribution)=4	
	ModifyGraph/W=IN2R_SizesInputGraph useNegRGB(CurrentResultSizeDistribution)=1
	ModifyGraph/W=IN2R_SizesInputGraph usePlusRGB(CurrentResultSizeDistribution)=1
	ModifyGraph/W=IN2R_SizesInputGraph hbFill(CurrentResultSizeDistribution)=12
	ModifyGraph/W=IN2R_SizesInputGraph plusRGB(CurrentResultSizeDistribution)=(32768,65280,0)
	ModifyGraph/W=IN2R_SizesInputGraph negRGB(CurrentResultSizeDistribution)=(32768,65280,0)

	ModifyGraph/W=IN2R_SizesInputGraph mode(NormalizedResidual)=3,marker(NormalizedResidual)=19
	ModifyGraph/W=IN2R_SizesInputGraph msize(NormalizedResidual)=1
	
	NVAR Chisquare
	variable/G FittedNumberOfpoints=numpnts(Intensity)
	SetVariable ChiSquared size={180,20}, pos={400,30}, title="ChiSquared reached"
	SetVariable ChiSquared limits={-Inf,Inf,0},value= Chisquare
	SetVariable NumFittedPoints size={180,20}, pos={400,15}, title="Number of fitted points"
	SetVariable NumFittedPoints limits={-Inf,Inf,0},value= FittedNumberOfpoints

	IN2G_GenerateLegendForGraph(7,0,1)
	Legend/J/C/N=Legend1/J/A=LB/X=-8/Y=-8

	DoUpdate						//and here we again record what we have done
	IN2G_AppendStringToWaveNote("CurrentResultSizeDistribution",SizesParameters)	
	IN2G_AppendStringToWaveNote("D_distribution",SizesParameters)	
	IN2G_AppendStringToWaveNote("SizesFitIntensity",SizesParameters)	
	IN2G_AppendStringToWaveNote("Q_vec",SizesParameters)	
end

//***********************************************************************************************************
//***********************************************************************************************************

Function IN2R_ReturnFitBack()			//copies data back to folder with original data
	SVAR fldrName
	Wave CurrentResultSizeDistribution
	Wave D_distribution
	Wave SizesFitIntensity
	Wave Q_vec
	Wave NormalizedResidual
	SVAR SizesParameters
	
	string tempname
	tempname=fldrName+"SizeDistributionFD"
	IN2G_AppendorReplaceWaveNote("CurrentResultSizeDistribution","Wname","SizeDistributionFD")
	Duplicate/O CurrentResultSizeDistribution $tempname

	tempname=fldrName+"SizeDistDiameter"
	IN2G_AppendorReplaceWaveNote("D_distribution","Wname","SizeDistDiameter")
	IN2G_AppendorReplaceWaveNote("D_distribution","Units","A")
	Duplicate/O D_distribution $tempname

	tempname=fldrName+"SizesFitIntensity"
	IN2G_AppendorReplaceWaveNote("SizesFitIntensity","Wname","SizesFitIntensity")
	IN2G_AppendorReplaceWaveNote("SizesFitIntensity","Units","cm-1")
	Duplicate/O SizesFitIntensity $tempname

	tempname=fldrName+"SizesFitQvector"
	IN2G_AppendorReplaceWaveNote("Q_vec","Wname","SizesFitQvector")
	IN2G_AppendorReplaceWaveNote("Q_vec","Units","A-1")
	Duplicate/O Q_vec $tempname
	
	IN2R_CalcOtherDistributions()	//this function goes to original data folder and calculates new waves with other results
								//but writes results into old Sizesparameters, therefore we need to return back
								//and copy the SizesParameters to the original folder
	tempname=fldrName+"SizesParameters"
	string/G $tempName=SizesParameters

end 


//*********************************************************************************************
//*********************************************************************************************

Window IN2R_SizesInputPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(549,47.75,903.75,569)
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (65280,0,0)
	DrawText 13,24,"Sizes input parameters"
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,52224)
	DrawText 13,420,"Set range of data to fit with cursors!!"
	SetDrawEnv gstart
	SetDrawEnv gstop
	DrawLine 7,121,348,121
	DrawText 174,490,"You need to save the results"
	DrawText 201,505,"or they are lost!!"
	DrawLine 7,263,347,263
	DrawLine 7,323,347,323
	DrawLine 7,400,347,400
	SetVariable RminInput,pos={13,32},size={150,16},title="Minimum diameter"
	SetVariable RminInput,limits={1,Inf,5},value= root:Packages:Sizes:Dmin
	SetVariable RmaxInput,pos={180,33},size={150,16},title="Maximum diameter"
	SetVariable RmaxInput,limits={1,Inf,5},value= root:Packages:Sizes:Dmax
	PopupMenu Binning,pos={5,91},size={198,21},proc=IN2R_ChangeBinningMethod,title="Logaritmic binning method?"
	PopupMenu Binning,mode=1,popvalue=root:Packages:Sizes:LogDist,value= #"\"Yes;No\""
	SetVariable RadiaSteps,pos={24,63},size={150,16},title="Bins in diameter"
	SetVariable RadiaSteps,limits={1,Inf,5},value= root:Packages:Sizes:numOfPoints
	SetVariable Background,pos={10,131},size={200,16},proc=IN2R_BackgroundInput,title="Subtract Background"
	SetVariable Background,limits={-Inf,Inf,0.001},value= root:Packages:Sizes:Bckg
	PopupMenu ShapeModel,pos={11,271},size={220,21},proc=IN2R_SelectShapeModel,title="Select particle shape model"
	PopupMenu ShapeModel,mode=1,popvalue=root:Packages:Sizes:ShapeType,value= #"\"Spheroid;no other available yet\""
	Button RunSizes,pos={12,440},size={150,20},proc=IN2R_SizesFitting,title="Run Internal Regularization"
	Button RunMaxent,pos={180,423},size={150,20},proc=IN2R_MaxentFitting,title="Run External Maxent"
	Button RunRegularization,pos={180,450},size={150,20},proc=IN2R_MaxentFitting,title="Run External Regularization"
	Button SaveData,pos={12,470},size={150,20},proc=IN2R_saveData,title="Save the results"
	Button Restart,pos={12,495},size={150,20},proc=IN2R_restart,title="Start with new data"
	SetVariable ScatteringContrast,pos={10,153},size={250,16},title="Contrast (drho^2)[10^20, 1/cm4]"
	SetVariable ScatteringContrast,limits={0,Inf,1},value= root:Packages:Sizes:ScatteringContrast
	SetVariable ErrorMultiplier,pos={10,175},size={250,16},title="Multiply Errors by : "
	SetVariable ErrorMultiplier,limits={0,Inf,1},value= root:Packages:Sizes:ErrorsMultiplier
	SetVariable AspectRatio,pos={16,303},size={220,16},title="Aspect Ratio (when needed)"
	SetVariable AspectRatio,limits={0,Inf,0.1},value= root:Packages:Sizes:AspectRatio
	SetVariable MaxsasIter,pos={16,330},size={220,16},title="MaxEnt max Num of Iterations"
	SetVariable MaxsasIter,limits={0,Inf,1},value= root:Packages:Sizes:MaxsasNumIter
	SetVariable MaxSkyBckg,pos={16,355},size={220,16},title="MaxEnt sky background"
	SetVariable MaxSkyBckg,limits={0,Inf,1e-6},value= root:Packages:Sizes:MaxEntSkyBckg
	SetVariable MaxMultiplicator,pos={16,380},size={220,16},title="MaxEnt multiplicator"
	SetVariable MaxMultiplicator,limits={0,Inf,1},value= root:Packages:Sizes:MaxEntMultCoef
	PopupMenu SlitSmearedData,pos={40,210},size={205,21},proc=IN2R_ChangeSmeared,title="Slit smeared data?"
	PopupMenu SlitSmearedData,mode=1,popvalue=root:Packages:Sizes:SlitSmearedData,value= #"\"No;Yes\""
	SetVariable SlitLength,pos={50,240},size={150,16},title="Slit Length"
	SetVariable SlitLength,limits={0,Inf,0.001},value= root:Packages:Sizes:SlitLength
	
	
EndMacro

//*********************************************************************************************
//*********************************************************************************************

Function IN2R_ChangeBinningMethod(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR LogDist
	
	LogDist=popStr
End

Function IN2R_ChangeSmeared(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR SlitSmearedData
	SVAR SizesParameters
	SlitSmearedData=popStr
	SizesParameters=ReplaceStringByKey("RegSlitSmearedData",SizesParameters,popStr,"=")
End

//*********************************************************************************************
//*********************************************************************************************

Window IN2R_SizesInputGraph() : Graph
	PauseUpdate; Silent 1		// building window...
	SetDataFolder root:Packages:Sizes:
	Display/K=1 /W=(0.3*IN2G_ScreenWidthHeight("width"),5*IN2G_ScreenWidthHeight("heigth"),60*IN2G_ScreenWidthHeight("width"),80*IN2G_ScreenWidthHeight("height")) IntensityOriginal vs Q_vecOriginal
	DoWindow/C IN2R_SizesInputGraph
	IN2R_AppendIntOriginal()	//appends original Intensity 
//	IN2G_AppendSizeTopWave("IN2R_SizesInputGraph",Q_vecOriginal, IntensityOriginal,-25,0,40)		//appends the size wave
//	removed on request of Pete
	ModifyGraph mirror=1
	AppendToGraph BackgroundWave vs Q_vecOriginal
	ModifyGraph/Z margin(top)=80
	Button RemovePointR pos={150,10}, size={140,20}, title="Remove pnt w/csrA", proc=IN2R_RemovePointWithCursorA
	Button ReturnAllPoints pos={150,40}, size={140,20}, title="Return All deleted points", proc=IN2R_ReturnAllDeletedPoints
	Button KillThisWindow pos={10,10}, size={100,25}, title="Kill window", proc=IN2G_KillGraphsAndTables
	Button ResetWindow pos={10,40}, size={100,25}, title="Reset window", proc=IN2G_ResetGraph
	ModifyGraph log=1
	Label left "Intensity"
	ModifyGraph lblPos(left)=50
	Label bottom "Q vector [A\\S-1\\M]"
	ShowInfo
	Textbox/N=text0/S=3/A=RT "The sample evaluated is:  "+StringByKey("UserSampleName", note(IntensityOriginal), "=")
	DoUpdate

EndMacro
//*********************************************************************************************
//*********************************************************************************************
Function IN2R_AppendIntOriginal()		//appends (and removes) and configures in graph IntOriginal vs Qvec Original
	
	Wave IntensityOriginal
	Wave Q_vecOriginal
	Wave DeletePointsMaskErrorWave
	variable csrApos
	variable csrBpos
	
	if (strlen(csrWave(A))!=0)
		csrApos=pcsr(A)
	else
		csrApos=0
	endif	
		
	 
	if (strlen(csrWave(B))!=0)
		csrBpos=pcsr(B)
	else
		csrBpos=numpnts(IntensityOriginal)-1
	endif	

	RemoveFromGraph/Z IntensityOriginal
	AppendToGraph IntensityOriginal vs Q_vecOriginal
	
	Label left "Intensity"
	ModifyGraph lblPos(left)=50
	Label bottom "Q vector [A\\S-1\\M]"

	ModifyGraph mode(IntensityOriginal)=3
	ModifyGraph msize(IntensityOriginal)=2
	ModifyGraph rgb(IntensityOriginal)=(0,52224,0)
	ModifyGraph zmrkNum(IntensityOriginal)={DeletePointsMaskWave}
	ErrorBars IntensityOriginal Y,wave=(DeletePointsMaskErrorWave,DeletePointsMaskErrorWave)
	Cursor/P A IntensityOriginal, csrApos
	Cursor/P B IntensityOriginal, csrBpos

end

Function IN2R_RemovePointWithCursorA(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname
	
	Wave DeletePointsMaskWave
	Wave DeletePointsMaskErrorWave
	
	DeletePointsMaskWave[pcsr(A)]=NaN
	DeletePointsMaskErrorWave[pcsr(A)]=NaN
	
	IN2R_AppendIntOriginal()	

End

Function IN2R_ReturnAllDeletedPoints(ctrlname) : Buttoncontrol			// Removes point in wave
	string ctrlname
	
	Wave DeletePointsMaskWave
	Wave DeletePointsMaskErrorWave
	Wave ErrorsOriginal
	
	DeletePointsMaskErrorWave=ErrorsOriginal
	DeletePointsMaskWave=7

	IN2R_AppendIntOriginal()	
End

//*********************************************************************************************
//*********************************************************************************************


Function IN2R_BackgroundInput(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	Wave Q_vec
	Duplicate/O Q_vecOriginal BackgroundWave
	BackgroundWave=varNum
	CheckDisplayed BackgroundWave 
	if (!V_Flag)
		AppendToGraph BackgroundWave vs Q_vecOriginal
	endif
End
//*********************************************************************************************
//*********************************************************************************************

Function IN2R_SelectShapeModel(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR ShapeType
	ShapeType=popStr
End


//*********************************************************************************************
//*********************************************************************************************

Function IN2R_restart(ctrlName) : ButtonControl
	String ctrlName
	
	IN2G_KillAllGraphsAndTables("yes")		//kills the graph and panel
	
	IN2R_Sizes()						//restarts the procredure
End

//*********************************************************************************************
//*********************************************************************************************

Function IN2R_saveData(ctrlName) : ButtonControl
	String ctrlName

	IN2R_ReturnFitBack()		//and this returns the data to original folder
End


//*********************************************************************************************
//*********************************************************************************************
Function IN2R_ShrinkGMatrixAfterSmearing()		//this shrinks the G_matrix and Q_vec back
												//Errors are used to get originasl length
	Wave G_matrix
	Wave Q_vec
	Wave Errors
	
	variable OldLength=numpnts(Errors)				//this is old number of points (Erros length did not change during smearing)
	
	redimension/N=(OldLength) Q_vec				//this shrinks the Q_veck to old length
	
	redimension/N=(OldLength,-1) G_matrix			//this shrinks the G_matrix to original number of rows, columns stay same

end
//*********************************************************************************************
//*********************************************************************************************
Function IN2R_SmearGMatrix()			//this function smears the colums in the G matrix

	Wave G_matrix
	Wave Q_vec
	NVAR SlitLength

	variable M=DimSize(G_matrix, 0)							//rows, i.e, measured points 
	variable N=DimSize(G_matrix, 1)							//columns, i.e., bins in radius distribution
	variable i=0
	Make/D/O/N=(M) tempOrg, tempSmeared									//points = measured Q points

	for (i=0;i<N;i+=1)					//for each column (radius point)
		tempOrg=G_matrix[p][i]			//column -> temp
		
		IN2D_SmearData(tempOrg, Q_vec, slitLength, tempSmeared)			//temp is smeared (Q_vec, SlitLength) ->  tempSmeared
	
		G_matrix[][i]=tempSmeared[p]		//column in G is set to smeared value
	endfor

//	G_matrix*=SlitLength*1e-4				//try to fix calibration
end


//*********************************************************************************************
//*********************************************************************************************
Function IN2R_ExtendQVecForSmearing()		//this is function extends the Q vector for smearing

	Wave Q_vec
	NVAR SlitLength

	variable OldPnts=numpnts(Q_vec)
	variable qmax=Q_vec[OldPnts-1]
	variable newNumPnts=0
	
	Duplicate Q_vec, TempWv	
	TempWv=log(Q_vec)

	if (qmax<SlitLength)
		NewNumPnts=numpnts(Q_vec)
	else
		NewNumPnts=numpnts(Q_vec)-BinarySearch(Q_vec, (Q_vec[OldPnts-1]-SlitLength) )
	endif
	
	if (NewNumPnts<10)
		NewNumPnts=10
	endif
	
	Make/O/D/N=(NewNumPnts) Extension
	Extension=Q_vec[OldPnts-1]+p*(SlitLength/NewNumPnts)
	Redimension /N=(OldPnts+NewNumPnts) Q_vec
	Q_vec[OldPnts, OldPnts+NewNumPnts-1]=Extension[p-OldPnts]
	
	KillWaves TempWv, Extension
end

//*********************************************************************************************
//*********************************************************************************************
Function IN2R_CalcOtherDistributions()

	SVAR fldrName
	SVAR SizesParameters
	
	string dfold=GetDataFolder(1)
	
	setDataFolder $fldrName
	
	WAVE SizeDistributionFD
	WAVE SizeDistDiameter
	WAVE SizesFitIntensity
	WAVE SizesFitQvector
	
	//and here we are in the proper folder and need to calculate some parameters
	
	string shape=StringByKey("RegParticleShape", SizesParameters,"=")
	variable Aspectratio=NumberByKey("RegAspectRatio", SizesParameters,"=")

	Duplicate/O SizeDistributionFD, SizesVolumeDistribution, SizesNumberDistribution

	SizesNumberDistribution=SizeDistributionFD/(AspectRatio*(4/3)*pi*((SizeDistDiameter*1e-8)/2)^3)

	variable MeanSize=IN2R_MeanOfDistribution(SizesVolumeDistribution,SizeDistDiameter)

	IN2G_AppendorReplaceWaveNote("SizesVolumeDistribution","Wname","SizesVolumeDistribution")
	IN2G_AppendorReplaceWaveNote("SizesVolumeDistribution","Units","cm3/cm3")
	IN2G_AppendorReplaceWaveNote("SizesVolumeDistribution","MeanSizeOfDistribution",num2str(MeanSize))
	IN2G_AppendorReplaceWaveNote("SizesNumberDistribution","Wname","SizesNumberDistribution")
	IN2G_AppendorReplaceWaveNote("SizesNumberDistribution","Units","1/cm3")
	IN2G_AppendorReplaceWaveNote("SizesNumberDistribution","MeanSizeOfDistribution",num2str(MeanSize))
	
	
	print "Mean size of distribution"+num2str(MeanSize)

	SizesParameters=ReplaceStringByKey("MeanSizeOfDistribution", SizesParameters, num2str(MeanSize),"=")

	setDataFolder $dfold
end


Function IN2R_MeanOfDistribution(VolDist,Dia)
	Wave VolDist, Dia
	variable result=0, i, imax=numpnts(VolDist), VolTotal=0
	
	if (numpnts(VolDist)!=numpnts(Dia))
		Abort "Error in IN2R_MeanOfDistribution, the waves do not have the length"
	endif
	
	for(i=0;i<imax;i+=1)					// initialize variables;continue test
		if (VolDist[i]>=0)
			result+=VolDist[i]*Dia[i]
			VolTotal+=VolDist[i]
		endif
	endfor								// execute body code until continue test is false
 
 	result = result/VolTotal
	
	return result

end
//*********************************************************************************************
//*********************************************************************************************
