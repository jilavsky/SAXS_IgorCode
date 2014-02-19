#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.00

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//version 1.0 original release, Instrument support for SSRLMatSAXS
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
// TPA/XML  note support is here
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_TPASetup()		//this will setup support for data with TPA/XML file format
	string OldDFf=GetDataFolder(1)

	//first initialize if user selects this without opening main window... 
	doWIndow NI1A_Convert2Dto1DPanel
	if(!V_Flag)
		NI1A_Convert2Dto1DMainPanel()		
	endif
	//set some parameters here:
	NVAR UseSampleTransmission = root:Packages:Convert2Dto1D:UseSampleTransmission
	NVAR UseSampleThickness = root:Packages:Convert2Dto1D:UseSampleThickness
	NVAR UseEmptyField = root:Packages:Convert2Dto1D:UseEmptyField
	NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
	NVAR DoGeometryCorrection = root:Packages:Convert2Dto1D:DoGeometryCorrection
	NVAR UseMonitorForEf = root:Packages:Convert2Dto1D:UseMonitorForEf
	NVAR UseSampleTransmFnct = root:Packages:Convert2Dto1D:UseSampleTransmFnct
	NVAR UseSampleThicknFnct = root:Packages:Convert2Dto1D:UseSampleThicknFnct
	NVAR UseSampleMonitorFnct = root:Packages:Convert2Dto1D:UseSampleMonitorFnct
	NVAR UseEmptyMonitorFnct = root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
	NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength
	NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY
	NVAR SampleToCCDdistance = root:Packages:Convert2Dto1D:SampleToCCDdistance
	NVAR BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
	
	//XrayEnergy=8.333
	//Wavelength=12.39842/8.333
	//PixelSizeX = 0.08
	//PixelSizeY = 0.08
	
	UseSampleTransmission = 1
	UseSampleThickness = 1
//	UseEmptyField = 1
//	UseI0ToCalibrate = 1
//	DoGeometryCorrection = 1
//	UseMonitorForEf = 1
	UseSampleTransmFnct = 1
	UseSampleThicknFnct =1
//	UseSampleMonitorFnct = 1
//	UseEmptyMonitorFnct = 1
	SVAR SampleTransmFnct = root:Packages:Convert2Dto1D:SampleTransmFnct
	SVAR SampleThicknFnct = root:Packages:Convert2Dto1D:SampleThicknFnct
	SVAR SampleMonitorFnct = root:Packages:Convert2Dto1D:SampleMonitorFnct
	SVAR EmptyMonitorFnct = root:Packages:Convert2Dto1D:EmptyMonitorFnct

	SampleTransmFnct = "NI1_TPAGetTranmsission"
	SampleThicknFnct = "NI1_TPAGetThickness"
	//SampleMonitorFnct = "NI1_SSRLGetSampleI0"
	//EmptyMonitorFnct = "NI1_SSRLGetEmptyI0"
	PopupMenu Select2DDataType win=NI1A_Convert2Dto1DPanel, popmatch="TPA/XML" //mode=22
	PopupMenu SelectBlank2DDataType win=NI1A_Convert2Dto1DPanel, popmatch="TPA/XML" //mode=22
	NI1A_PopMenuProc("Select2DDataType",1,"TPA/XML")
	NI1A_PopMenuProc("SelectBlank2DDataType",1,"TPA/XML")
	
	Wave/Z image=root:Packages:Convert2Dto1D:CCDImageToConvert
	if(WaveExists(image))
			string sampleNote=note(image)
			string ImageType=StringByKey("DataFileType", sampleNote , "=" , ";")
		if(stringmatch(ImageType,"TPA/XML"))	
			DoAlert 1, "Found TPA Image loaded, do you want to read information from the header to Nika?"
			if(V_FLag==1)	//yes...	
					Wavelength =NumberByKey("Lambda", sampleNote , "=" , ";")
					XrayEnergy = 12.39842/Wavelength
					SampleToCCDdistance =NumberByKey("Detector_Distance", sampleNote , "=" , ";")
					BeamCenterX= NumberByKey("X0", sampleNote , "=" , ";")
					BeamCenterY=NumberByKey("Y", sampleNote , "=" , ";") - NumberByKey("Y0", sampleNote , "=" , ";")
					DoALert 0, "Parameters, paths and lookup functions for TPA/XML have been loaded"
			endif
		else
			NI1A_ButtonProc("Select2DDataPath")
			NI1A_ButtonProc("SelectMaskDarkPath")
			DoAlert 0, "Please load TPA type image and rerun the same macro to load instrument parameters from the header" 		
		endif	
	endif
	if(!WaveExists(image))
			NI1A_ButtonProc("Select2DDataPath")
			NI1A_ButtonProc("SelectMaskDarkPath")
			DoAlert 0, "Please load TPA type image and rerun the same macro to load instrument parameters from the header" 
	endif


end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_TPAGetTranmsission(fileName)
	string fileName
	//T = (ICpstsamp(sample) * ICpresamp(0))/(ICpresamp(sample) * ICpstsamp(0))
	wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	//wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(CCDImageToConvert))// || !WaveExists(EmptyData))
		abort "Needed area data do not exist. Load Sample data before going further"
	endif
	string sampleNote=note(CCDImageToConvert)
	//string emptyNote=note(EmptyData)
	variable transmission=NumberByKey("Transmission", sampleNote , "=" , ";")
	print "Found transmission = "+num2str(transmission)
	return transmission
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_TPAGetThickness(fileName)
	string fileName
	//T = (ICpstsamp(sample) * ICpresamp(0))/(ICpresamp(sample) * ICpstsamp(0))
	wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	//wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(CCDImageToConvert))// || !WaveExists(EmptyData))
		abort "Needed area data do not exist. Load Sample data before going further"
	endif
	string sampleNote=note(CCDImageToConvert)
	//string emptyNote=note(EmptyData)
	variable Thickness=NumberByKey("Thickness", sampleNote , "=" , ";")
	print "Found Thickness = "+num2str(Thickness)
	return Thickness
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
// SSRLMatSAXS support is here
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_SSRLSetup()		//this will setup support for SSRLMatSAXS
	string OldDFf=GetDataFolder(1)

	//first initialize if user selects this without opening main window... 
	doWIndow NI1A_Convert2Dto1DPanel
	if(!V_Flag)
		NI1A_Convert2Dto1DMainPanel()		
	endif
	//set some parameters here:
	NVAR UseSampleTransmission = root:Packages:Convert2Dto1D:UseSampleTransmission
	NVAR UseEmptyField = root:Packages:Convert2Dto1D:UseEmptyField
	NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
	NVAR DoGeometryCorrection = root:Packages:Convert2Dto1D:DoGeometryCorrection
	NVAR UseMonitorForEf = root:Packages:Convert2Dto1D:UseMonitorForEf
	NVAR UseSampleTransmFnct = root:Packages:Convert2Dto1D:UseSampleTransmFnct
	NVAR UseSampleMonitorFnct = root:Packages:Convert2Dto1D:UseSampleMonitorFnct
	NVAR UseEmptyMonitorFnct = root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
	NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength
	NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY
	
	XrayEnergy=8.333
	Wavelength=12.39842/8.333
	PixelSizeX = 0.08
	PixelSizeY = 0.08
	
	UseSampleTransmission = 1
	UseEmptyField = 1
	UseI0ToCalibrate = 1
	DoGeometryCorrection = 1
	UseMonitorForEf = 1
	UseSampleTransmFnct = 1
	UseSampleMonitorFnct = 1
	UseEmptyMonitorFnct = 1
	SVAR SampleTransmFnct = root:Packages:Convert2Dto1D:SampleTransmFnct
	SVAR SampleMonitorFnct = root:Packages:Convert2Dto1D:SampleMonitorFnct
	SVAR EmptyMonitorFnct = root:Packages:Convert2Dto1D:EmptyMonitorFnct

	SampleTransmFnct = "NI1_SSRLGetTranmsission"
	SampleMonitorFnct = "NI1_SSRLGetSampleI0"
	EmptyMonitorFnct = "NI1_SSRLGetEmptyI0"
	PopupMenu Select2DDataType win=NI1A_Convert2Dto1DPanel, popmatch="SSRLMatSAXS" //mode=22
	PopupMenu SelectBlank2DDataType win=NI1A_Convert2Dto1DPanel, popmatch="SSRLMatSAXS" //mode=22
	NI1A_PopMenuProc("Select2DDataType",1,"SSRLMatSAXS")
	NI1A_PopMenuProc("SelectBlank2DDataType",1,"SSRLMatSAXS")
	NI1A_ButtonProc("Select2DDataPath")
	NI1A_ButtonProc("SelectMaskDarkPath")


	DoALert 0, "Parameters, paths and lookup functions for SSRL Mat SAXS have been loaded"
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_SSRLGetTranmsission(fileName)
	string fileName
	//T = (ICpstsamp(sample) * ICpresamp(0))/(ICpresamp(sample) * ICpstsamp(0))
	wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(CCDImageToConvert) || !WaveExists(EmptyData))
		abort "Needed area data do not exist. Load Sample2D and Empty2D before going further"
	endif
	string sampleNote=note(CCDImageToConvert)
	string emptyNote=note(EmptyData)
	variable ICpstsampSa=NumberByKey("ICpstsamp", sampleNote , "=" , ";")
	variable ICpresampEm=NumberByKey("ICpresamp", emptyNote , "=" , ";")
	variable ICpresampSa=NumberByKey("ICpresamp", sampleNote , "=" , ";")
	variable ICpstsampEm=NumberByKey("ICpstsamp", emptyNote , "=" , ";")
	variable transmission  
	transmission = ICpstsampSa * ICpresampEm / (ICpresampSa *ICpstsampEm)
	print "Found transmission = "+num2str(transmission)
	return transmission
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1_SSRLGetSampleI0(fileName)
	string fileName
	wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(CCDImageToConvert))
		abort "Needed area data do not exist. Load Sample2D before going further"
	endif
	string sampleNote=note(CCDImageToConvert)
	variable ICpresampSa=NumberByKey("ICpresamp", sampleNote , "=" , ";")
	//variable secSa=NumberByKey("sec", sampleNote , "=" , ";")
	print "Found I0 value for sample = "+num2str(ICpresampSa)	//*secSa)
	return ICpresampSa	//*secSa

end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_SSRLGetEmptyI0(fileName)
	string fileName
	wave/Z EmptyData = root:Packages:Convert2Dto1D:EmptyData
	if(!WaveExists(EmptyData))
		abort "Needed area data do not exist. Load Empty2D before going further"
	endif
	string sampleNote=note(EmptyData)
	variable ICpresampEm=NumberByKey("ICpresamp", sampleNote , "=" , ";")
	//variable secEm=NumberByKey("sec", sampleNote , "=" , ";")
	print "Found I0 value for empty = "+num2str(ICpresampEm)//*secEm)
	return ICpresampEm	//*secEm

end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
