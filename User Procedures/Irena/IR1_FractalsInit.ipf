#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.02

//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.02 added Qc transition of Surface fractals ito Porod's slope at the end. Change to smooth surface. 
//2.01 added license for ANL

///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_InitializeFractals()

	string oldDf=GetDataFolder(1)
	
	NewDataFolder/O/S root:Packages
	NewdataFolder/O/S root:Packages:FractalsModel
	
	string ListOfVariables
	string ListOfStrings
	
	//here define the lists of variables and strings needed, separate names by ;...
	
	ListOfVariables="UseIndra2Data;UseQRSdata;NumberOfLevels;SubtractBackground;"
	ListOfVariables+="UseMassFract1;UseMassFract2;UseSurfFract1;UseSurfFract2;DisplayLocalFits;"
	ListOfVariables+="MassFr1_Phi;MassFr1_Radius;MassFr1_Dv;MassFr1_Ksi;MassFr1_Beta;MassFr1_Contrast;MassFr1_Eta;MassFr1_IntgNumPnts;"
	ListOfVariables+="MassFr1_FitPhi;MassFr1_FitRadius;MassFr1_FitDv;MassFr1_FitKsi;"
	ListOfVariables+="MassFr1_PhiError;MassFr1_RadiusError;MassFr1_DvError;MassFr1_KsiError;"
	ListOfVariables+="MassFr1_PhiMin;MassFr1_PhiMax;MassFr1_PhiStep;MassFr1_RadiusMin;MassFr1_RadiusMax;MassFr1_RadiusStep;"
	ListOfVariables+="MassFr1_DvMin;MassFr1_DvMax;MassFr1_DvStep;MassFr1_KsiMin;MassFr1_KsiMax;MassFr1_KsiStep;MassFr1_FitMin;MassFr1_FitMax;"
	
	ListOfVariables+="MassFr2_Phi;MassFr2_Radius;MassFr2_Dv;MassFr2_Ksi;MassFr2_Beta;MassFr2_Contrast;MassFr2_Eta;MassFr2_IntgNumPnts;"
	ListOfVariables+="MassFr2_FitPhi;MassFr2_FitRadius;MassFr2_FitDv;MassFr2_FitKsi;"
	ListOfVariables+="MassFr2_PhiError;MassFr2_RadiusError;MassFr2_DvError;MassFr2_KsiError;MassFr2_FitError;"
	ListOfVariables+="MassFr2_PhiMin;MassFr2_PhiMax;MassFr2_PhiStep;MassFr2_RadiusMin;MassFr2_RadiusMax;MassFr2_RadiusStep;"
	ListOfVariables+="MassFr2_DvMin;MassFr2_DvMax;MassFr2_DvStep;MassFr2_KsiMin;MassFr2_KsiMax;MassFr2_KsiStep;MassFr2_FitMin;MassFr2_FitMax;"
	
	ListOfVariables+="SurfFr1_Surface;SurfFr1_Ksi;SurfFr1_DS;SurfFr1_Contrast;"
	ListOfVariables+="SurfFr1_FitSurface;SurfFr1_FitKsi;SurfFr1_FitDS;"
	ListOfVariables+="SurfFr1_SurfaceError;SurfFr1_KsiError;SurfFr1_DSError;"
	ListOfVariables+="SurfFr1_SurfaceMin;SurfFr1_SurfaceMax;SurfFr1_SurfaceStep;SurfFr1_KsiMin;SurfFr1_KsiMax;SurfFr1_KsiStep;"
	ListOfVariables+="SurfFr1_DSMin;SurfFr1_DSMax;SurfFr1_DSStep;"
	ListOfVariables+="SurfFr1_Qc;SurfFr1_QcWidth;SurfFr1_QcStep;"
		
	ListOfVariables+="SurfFr2_Surface;SurfFr2_Ksi;SurfFr2_DS;SurfFr2_Contrast;"
	ListOfVariables+="SurfFr2_FitSurface;SurfFr2_FitKsi;SurfFr2_FitDS;"
	ListOfVariables+="SurfFr2_SurfaceError;SurfFr2_KsiError;SurfFr2_DSError;"
	ListOfVariables+="SurfFr2_SurfaceMin;SurfFr2_SurfaceMax;SurfFr2_SurfaceStep;SurfFr2_KsiMin;SurfFr2_KsiMax;SurfFr2_KsiStep;"
	ListOfVariables+="SurfFr2_DSMin;SurfFr2_DSMax;SurfFr2_DSStep;"
	ListOfVariables+="SurfFr2_Qc;SurfFr2_QcWidth;SurfFr2_QcStep;"
		
	ListOfVariables+="SASBackground;SASBackgroundError;SASBackgroundStep;FitSASBackground;UpdateAutomatically;DisplayLocalFits;ActiveTab;"

	ListOfStrings="DataFolderName;IntensityWaveName;QWavename;ErrorWaveName;"
	
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
										
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	//cleanup after possible previous fitting stages...
	Wave/Z CoefNames=root:Packages:FractalsModel:CoefNames
	Wave/Z CoefficientInput=root:Packages:FractalsModel:CoefficientInput
	KillWaves/Z CoefNames, CoefficientInput
	
	IR1V_SetInitialValues()		
	setDataFolder oldDF

end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_SetInitialValues()
	//and here set default values...

	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:FractalsModel
	
	string ListOfVariables
	variable i
	//here we set what needs to be 0
	ListOfVariables="MassFr1_FitPhi;MassFr1_FitRadius;MassFr1_FitDv;MassFr1_FitKsi;"
	ListOfVariables+="MassFr2_FitPhi;MassFr2_FitRadius;MassFr2_FitDv;MassFr2_FitKsi;"
	ListOfVariables+="SurfFr1_FitSurface;SurfFr1_FitKsi;SurfFr1_FitDS;"
	ListOfVariables+="SurfFr2_FitSurface;SurfFr2_FitKsi;SurfFr2_FitDS;"
	ListOfVariables+="FitSASBackground;UpdateAutomatically;DisplayLocalFits;ActiveTab;DisplayLocalFits;UseIndra2Data;UseRQSdata;SubtractBackground;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		testVar=0
	endfor
	
	//and here values to 0.000001
	ListOfVariables="MassFr1_PhiMin;"
	ListOfVariables+="MassFr2_PhiMin;"
	ListOfVariables+="SurfFr1_SurfaceMin;"
	ListOfVariables+="SurfFr2_SurfaceMin;"
	ListOfVariables+="SASBackground;SASBackgroundStep;"

	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=0.01
		endif
	endfor
	
	
	//and here to 1
	ListOfVariables="SurfFr1_SurfaceStep;SurfFr1_KsiStep;SurfFr2_SurfaceStep;SurfFr2_KsiStep;MassFr1_DvMin;MassFr2_DvMin;"
	ListOfVariables+="MassFr1_PhiStep;MassFr1_RadiusStep;MassFr2_PhiStep;MassFr2_RadiusStep;MassFr1_DvStep;MassFr1_KsiStep;"
	ListOfVariables+="SurfFr1_DSStep;SurfFr2_DSStep;MassFr2_KsiStep;MassFr2_DvStep;MassFr1_PhiMax;MassFr2_PhiMax;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=1
		endif
	endfor
//

	ListOfVariables="MassFr1_RadiusMin;MassFr2_RadiusMin;MassFr1_KsiMin;MassFr2_KsiMin;SurfFr1_KsiMin;SurfFr2_KsiMin;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=10
		endif
	endfor
	
	ListOfVariables="SurfFr1_DSMin;SurfFr2_DSMin;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=2
		endif
	endfor
	ListOfVariables="MassFr1_DvMax;MassFr2_DvMax;SurfFr2_DSMax;SurfFr1_DSMax;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=3
		endif
	endfor

	ListOfVariables="MassFr1_RadiusMax;MassFr1_KsiMax;"
	ListOfVariables+="MassFr2_RadiusMax;MassFr2_KsiMax;"
	ListOfVariables+="SurfFr1_SurfaceMax;SurfFr1_KsiMax;"
	ListOfVariables+="SurfFr2_SurfaceMax;SurfFr2_KsiMax;"

	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=10000
		endif
	endfor

	ListOfVariables="SurfFr1_Surface;"
	ListOfVariables+="SurfFr2_Surface;"
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=1000
		endif
	endfor
	
	ListOfVariables="MassFr1_Radius;MassFr1_Ksi;"
	ListOfVariables+="MassFr2_Radius;MassFr2_Ksi;"
	ListOfVariables+="SurfFr1_Ksi;"
	ListOfVariables+="SurfFr2_Ksi;"	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=500
		endif
	endfor

	ListOfVariables="MassFr1_Phi;"
	ListOfVariables+="MassFr2_Phi;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=0.1000
		endif
	endfor

	ListOfVariables="MassFr1_Contrast;MassFr2_Contrast;"
	ListOfVariables+="SurfFr1_Contrast;SurfFr2_Contrast;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=100
		endif
	endfor

	ListOfVariables="MassFr1_Beta;MassFr2_Beta;"	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=2
		endif
	endfor

	ListOfVariables="MassFr1_Eta;MassFr2_Eta;"	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=0.5
		endif
	endfor

	ListOfVariables="MassFr1_Dv;MassFr2_Dv;SurfFr1_DS;SurfFr2_DS;"	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=2
		endif
	endfor
	
	ListOfVariables="MassFr1_IntgNumPnts;MassFr2_IntgNumPnts;"
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=500
		endif
	endfor
	
	ListOfVariables="SurfFr1_QcWidth;SurfFr2_QcWidth;"
	//this sets width of Qc transition to 10%, may need to be oiptimized later.
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		if (testVar==0)
			testVar=0.1
		endif
	endfor
	
	IR1V_SetErrorsToZero()
	setDataFolder oldDF
end


///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************
///******************************************************************************************

Function IR1V_SetErrorsToZero()

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:FractalsModel

	string ListOfVariables="SASBackgroundError;"
	ListOfVariables+="MassFr1_PhiError;MassFr1_RadiusError;MassFr1_DvError;MassFr1_KsiError;"
	ListOfVariables+="MassFr2_PhiError;MassFr2_RadiusError;MassFr2_DvError;MassFr2_KsiError;"
	ListOfVariables+="SurfFr1_SurfaceError;SurfFr1_KsiError;SurfFr1_DSError;"
	ListOfVariables+="SurfFr2_SurfaceError;SurfFr2_KsiError;SurfFr2_DSError;"
	variable i
	
	For(i=0;i<itemsInList(ListOfVariables);i+=1)
		NVAR/Z testVar=$(StringFromList(i,ListOfVariables))
		testVar=0
	endfor

	setDataFolder oldDF

end

