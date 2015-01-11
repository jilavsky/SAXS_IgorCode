#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.38
#include <TransformAxis1.2>

//*************************************************************************\
//* Copyright (c) 2005 - 2014, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.38 removed Executes as preparation for Igor 7
//2.37 renamed tab "Prev" into "PolTran" = Polar transform. This seems better descrition of the conversion. 
//2.36 added ADSC_A
//2.35 moved Dezinger to tab 2 - some users thought, that dezingenring is available only for empty and dark.  
//2.34 can read/write canSAS/Nexus files. Can log-bin 2D data and use those. 
//2.33 fixed display of files for CanSAS/Nexus file type
//2.32 fixed case, when user wanted to display processed data, but the images were created/updated before the processed data were even created. 
//2.31 added hook functions, required change in main panel function from macro to function and therefore also renaming it. 
//2.30 Added right click "Refresh content" to Listbox and other functionality
//2.29 fixed /NTHR=1 to /NTHR=0
//2.28 add ability to load and use 2D calibrated data (from EQSANS for now)
//2.27 adds DataCalibrationString to GUI and Intensity/q/theta/d/distance data 
//2.26 added double clicks to Mask listbox and to Empty/Dark listboxes. 
//2.25 adds TPA/XML code
//2.24 minor GUI improvements
//2.23 Refresh now sets top data set as selected. Added first version of background task monitoring folder...
//2.22 added user defined Image range and display color scale... 
//2.21 added export in distacne from center, minor fix in search for match files
//2.20 changed behavior to enable calculation of smeared data in 15IDD pinSAXS instrument
//2.19 fixed NI1A_UpdateEmptyDarkListBox() for bug (was looking in wrong path...)
//2.18 fixed UpdateEmptyDark File list 
//2.17 Support for pinSAXS and Nexus file reader, fixed loadEMpty/dark bug which used wrong extension for file 
//2.16 found another bug in PixSensitivity correction, it was done twice under some conditions... , Chenged fixed offset to allow for negative values. 
//2.15 added ability to check and skip for bad loaded files... Reflects changes to UniversalFileLoader
//2.14 Added Movie creating option, some code modification necessary. NOte: Main thing is that I had to move the order of 2Dto1Dconversion after displaying 2D images, not before. 
//2.13 fixed bug in Corrections for 2D wave identified by user. The transmission correction was done befor esubtraction of the dark frame, which is wrong... 6/17/2011
//2.12 added azimuthal tilts on detector; removed filter for extension for MarIP files (requested, what a mess this will create :-(  ) 
// 2.11 (3/25/2011) modified to use tilt correction which was developed by Jon Tischler. Should be correct now and quick. Note: geometrical corrections are still 
     // valid for no tilts only and for now assume tilt around Z axis (beam direction) to be 0 - therefore x axis on detector must be horizontal. 
//2.10 modifies BSL loader as requested by JOSH
//2.09 added mutlithread and MatrixOp/NTHR=1 where seemed possible to use multile cores
//2.08 fix change in TransformAxis with Igor 6.21 which requires one more parameter. Set to useScientific=1., made compatible to prior version of Igor 6 also. 
//2.07 added license for ANL
// 2.06 8/24/2010 fix for Igor 6.20
// 2.05 3/3/2010  fixed bug for adding Q scales which failed when InvertImages was used. 
// 2.04  2/26/2010 added match strings for sample and empty/dark names
//2.03 2/22/2010 added ability to display the Q axes on the image
//2.02 Pilatus stuff
// 2.01 12/06/2009... Changed error calculations to multiple choice. Version 1.43.
//2.00  10/25/2009... Many changes related to line profile tools and some minor fixes. JIL.
//1.11 9/3/09 fixed I0Monitor count showing up at wrong time, JIL. 
// 1.1 updated 8/31 to address Polarization correction, JIL		
//1.01 changed ADSC type to only display .img files. 

//Tilt comments:
//as best as I can, these are the assumptions...
// first rotate detector around vector R={xrot,yrot,zrot}.
// then move detector from sample position, detector xcentered on the sample and beam by vector P={x,y,z}, where z is basically sample-detector distance.
// x, z are shifts from centered position on tetector, so x and y are basically beam center positions
// Here is original John's description... but note that I have changed the order and tilt the detector first to make this more suitabel for our usual definitions... 
// Position of detector: first translate by P, and then rotate detector around R.  Since rho is rotation matrix calculated from R:
//		{X,Y,Z} = rho x [P+{x',y',z'}] ,   where XYZ are beam line coords, and {x'y'z'} are coordinates in detector reference frame.
// Size of detector is measured to the outer edge of the outer most pixels.  So conversion from position to pixel for the x direction is:
//		x' = ( pixel - (Nx-1)/2 )*pitch,   where sizeX = Nx*pitch.  This puts the coordinate of pixel (i,j) at the center of the pixel.
//


//	NVAR Use2DdataName=root:Packages:Convert2Dto1D:Use2DdataName
//	NVAR UseCorrectionFactor=root:Packages:Convert2Dto1D:UseCorrectionFactor
//	NVAR UseDarkField=root:Packages:Convert2Dto1D:UseDarkField
//	NVAR UseDarkMeasTime=root:Packages:Convert2Dto1D:UseDarkMeasTime
//	NVAR UseEmptyField=root:Packages:Convert2Dto1D:UseEmptyField
//	NVAR UseEmptyMeasTime=root:Packages:Convert2Dto1D:UseEmptyMeasTime
//	NVAR UseI0ToCalibrate=root:Packages:Convert2Dto1D:UseI0ToCalibrate
//	NVAR UseMask=root:Packages:Convert2Dto1D:UseMask
//	NVAR UseMonitorForEF=root:Packages:Convert2Dto1D:UseMonitorForEF
//	NVAR UsePixelSensitivity=root:Packages:Convert2Dto1D:UsePixelSensitivity
//	NVAR UseSampleMeasTime=root:Packages:Convert2Dto1D:UseSampleMeasTime
//	NVAR UseSampleThickness=root:Packages:Convert2Dto1D:UseSampleThickness
//	NVAR UseSampleTransmission=root:Packages:Convert2Dto1D:UseSampleTransmission
//	NVAR UseSubtractFixedOffset=root:Packages:Convert2Dto1D:UseSubtractFixedOffset

//DisplayDataAfterProcessing;"
//	ListOfVariables+="DoSectorAverages;NumberOfSectors;SectorsStartAngle;SectorsHalfWidth;SectorsStepInAngle;"
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_AverageDataPerUserReq(orientation)
	STRING ORIENTATION	

	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D
	
	Wave Calibrated2DDataSet=root:Packages:Convert2Dto1D:Calibrated2DDataSet
	string OldNote=note(Calibrated2DDataSet)

	wave LUT=$("root:Packages:Convert2Dto1D:LUT_"+orientation)
	wave HistogramWv=$("root:Packages:Convert2Dto1D:HistogramWv_"+orientation)
	wave QvectorA=$("root:Packages:Convert2Dto1D:Qvector_"+orientation)
	wave QvectorWidth=$("root:Packages:Convert2Dto1D:QvectorWidth_"+orientation)

	wave TwoThetaA=$("root:Packages:Convert2Dto1D:TwoTheta_"+orientation)
	wave TwoThetaWidthA=$("root:Packages:Convert2Dto1D:TwoThetaWidth_"+orientation)

	wave DspacingA=$("root:Packages:Convert2Dto1D:Dspacing_"+orientation)
	wave DspacingWidthA=$("root:Packages:Convert2Dto1D:DspacingWidth_"+orientation)

	wave/Z DistanceInmmA=$("root:Packages:Convert2Dto1D:DistanceInmm_"+orientation)
	wave DistacneInmmWidthA=$("root:Packages:Convert2Dto1D:DistacneInmmWidth_"+orientation)
	
	NVAR DoGeometryCorrection=root:Packages:Convert2Dto1D:DoGeometryCorrection
	NVAR DoPolarizationCorrection=root:Packages:Convert2Dto1D:DoPolarizationCorrection
	NVAR Use1DPolarizationCor=root:Packages:Convert2Dto1D:Use1DPolarizationCor
	NVAR Use2DPolarizationCor=root:Packages:Convert2Dto1D:Use2DPolarizationCor
	NVAR StartAngle2DPolCor=root:Packages:Convert2Dto1D:StartAngle2DPolCor


	NVAR QvectorNumberPoints=root:Packages:Convert2Dto1D:QvectorNumberPoints
	NVAR QvectorMaxNumPnts=root:Packages:Convert2Dto1D:QvectorMaxNumPnts
	
	OldNote+="QvectorMaxNumPnts="+num2str(QvectorMaxNumPnts)+";"
	OldNote+="QvectorNumberPoints="+num2str(QvectorNumberPoints)+";"
	if(cmpstr(orientation,"C")==0)
		OldNote+="CircularAverage="+"1"+";"
	else
		OldNote+="AngularSector="+stringFromList(0,orientation,"_")+";"
		OldNote+="AngularHalfWidth="+stringFromList(1,orientation,"_")+";"
	endif
	if(DoPolarizationCorrection)
		if(Use1DPolarizationCor)
			OldNote+="PolarizationCorrection=1D;"
		else
			OldNote+="PolarizationCorrection=2D;"
			OldNote+="2DPolarizationCorrection0Angle="+num2str(StartAngle2DPolCor)+";"
		endif
	
	else
		OldNote+="PolarizationCorrection=None;"
	endif
	
	Duplicate/O QvectorA, Qvector, Intensity, Error, Qsmearing
	Duplicate/O TwoThetaA, TwoTheta
	Duplicate/O TwoThetaWidthA, TwoThetaWidth
	Duplicate/O DistanceInmmA, DistanceInmm
	Duplicate/O DistacneInmmWidthA, DistacneInmmWidth
	Duplicate/O DspacingA, Dspacing
	Duplicate/O DspacingWidthA, DspacingWidth
	Qsmearing = QvectorWidth
	Intensity=0
	Error=0
	variable i, j, counter, numbins, start1, end1
	Duplicate/O LUT, tempInt
	tempInt = Calibrated2DDataSet
	IndexSort LUT, tempInt
	//Duplicate/O tempInt, TempIntSqt
	MatrixOp/O/NTHR=0 TempIntSqt = tempInt* tempInt
	counter = HistogramWv[0]
	For(j=1;j<QvectorNumberPoints;j+=1)
		numbins = HistogramWv[j]
		if(numbins>0)
			Intensity[j] = sum(tempInt, pnt2x(tempInt,Counter), pnt2x(tempInt,Counter+numbins-1))	//this cointains sum Xi
			Error[j] = sum(TempIntSqt, pnt2x(tempInt,Counter), pnt2x(tempInt,Counter+numbins-1))	//this now contains sum Xi^2
		endif
		Counter+=numbins
	endfor
	MatrixOp/O/NTHR=0 TempSumXi=Intensity				//OK, now we have sumXi saved
	MatrixOp/O/NTHR=0 Intensity=Intensity/HistogramWv	//This is average intensity....
	//version 1.43 December 2009, changed uncertainity estimates. Three new methods now available. Old method which has weird formula, standard deviation and standard error fof mean ...
	NVAR ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
	NVAR ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
	NVAR ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
	//change in the Configuration panel. 	
	if(ErrorCalculationsUseOld)	//this is teh old code... Hopefully I did not screw up. 
		Error=sqrt(abs(Error - (TempSumXi^2))/(HistogramWv - 1))	
		MatrixOp/O/NTHR=0 Error=Error/HistogramWv
	else //now new code. Need to calculate standard deviation anyway... 
		//variance Ê= (Error - (Intensity^2 / Histogram)) / (Histogram - 1)
		//st deviation = sqrt(variance)
		Error = sqrt(abs(Error - (TempSumXi^2 / HistogramWv)) / (HistogramWv - 1))
		if(ErrorCalculationsUseSEM)
			//error_mean=stdDev/sqrt(Histogram)			use Standard error of mean...
			Error = Error /sqrt(HistogramWv)
		endif
	endif
	//need to add comments to wave note...
	if(ErrorCalculationsUseOld)
		OldNote+="UncertainityCalculationMethod=OldNikaMethod;"
	elseif(ErrorCalculationsUseStdDev)
		OldNote+="UncertainityCalculationMethod=StandardDeviation;"
	elseif(ErrorCalculationsUseSEM)
		OldNote+="UncertainityCalculationMethod=StandardErrorOfMean;"
	endif
	
	//this fix is same for all - if there is only 1 point in the bin, simply use sqrt of intensity... Of course, this can be really wrong, since by now this is fully calibrated and hecne sqrt is useless... 
	Error = (HistogramWv[p]>1)? Error[p] : sqrt(Intensity[p])
	note Intensity, OldNote
	note Error, OldNote
	killwaves/Z tempInt, TempIntSqt, temp2D, tempQ, NewQwave, TempSumXi
	//remove first point - it contains all the masked points set to Q=0...
	DeletePoints 0,1, intensity, error, Qvector, Qsmearing, TwoTheta, TwoThetaWidth, Dspacing, DspacingWidth, DistanceInmm, DistacneInmmWidth
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//
//Function NI1A_SolidangleCorrection(qwave,rwave,pixelsize,SDD, lambda,DoGeometryCorrection, DoPolarizationCorrection) //from Dale Schaefer, needs to be checked what is it doing... 
//    		wave qwave,rwave
//        	variable pixelsize,SDD, lambda ,DoGeometryCorrection, DoPolarizationCorrection
//         
//	string oldDf=GetDataFOlder(1)
//	setDataFolder root:Packages:Convert2Dto1D
//
//    duplicate/o qwave, omega, SAP, HYP, theta 
//    theta=2*asin(qwave * Lambda /( 4 * pi) )		//theta here is really 2Theta, since it is angle between beam in and out... 
//    
////    if(DoGeometryCorrection)
//// 	   SAP=PixelSize*cos(theta)		//this is projection of pixel into the direction perpendicular to the center line from sample 
////					   // HYP=((PixelSize*(qwave))^2+SDD^2)^(1/2)//qout is still in pixels 
////	    HYP=SDD/cos(theta)			//this is distance from the sample
////					 //       qwave=(4*pi/wavelength)*(sin(theta/2)) 
////	    omega=(SAP/HYP) 			//this is angle under which we see the pixel from the sample
//// 	   variable startOmega=omega[0]
////	    omega /= startOmega				//and this is to scale it, so the correction for center pixel is 1
////	else
//		omega=1
////	endif
//    	duplicate/o theta, PF 
//    	if(DoPolarizationCorrection)			//comment 6/24/2006 - I think this is wrong... I need to find the right formula... 
//	    PF= (1+cos((theta))^2)/2			// polarization factor, see above, theta is really 2theta
//    	else
//		pf=1 
//      endif
////    rwave=rwave/(omega^2*PF)     		//Squared because it is solid angle and the above is done for lin angle 
////    rwave=rwave/(omega^1.5*PF)     		//Correction JI 5 26 2006
//    rwave=rwave/(PF)     		//Correction JI 5 26 2006
//    //why is it 1.5???? To match geometrical corrections by Fit2D
//    // Correct correction is Int/cos(theta)^3 - that is from NIST macros and agrees with Fit2D - the omega here is already ^2, thats why 1.5...
//    //I believe the right should be ^1, because, only 1 dimensions is actually distorted. ase example pixel on vertical axis. Only
//    //vertical dimension is shrunk, horizontal direction has not changed... But to match Fit2D exactly I need factor of 1.5...
//        
//    killwaves/z  SAP, HYP, omega, PF,theta 
//	setDataFolder OldDf
//end 
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_CorrectDataPerUserReq(orientation)
	string orientation

	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D

	SVAR CalibrationFormula=root:Packages:Convert2Dto1D:CalibrationFormula
	NVAR UseSampleThickness= root:Packages:Convert2Dto1D:UseSampleThickness
	NVAR UseSampleTransmission= root:Packages:Convert2Dto1D:UseSampleTransmission
	NVAR UseCorrectionFactor= root:Packages:Convert2Dto1D:UseCorrectionFactor
	NVAR UseSolidAngle=root:Packages:Convert2Dto1D:UseSolidAngle
	NVAR UseMask= root:Packages:Convert2Dto1D:UseMask
	NVAR UseDarkField= root:Packages:Convert2Dto1D:UseDarkField
	NVAR UseEmptyField= root:Packages:Convert2Dto1D:UseEmptyField
	NVAR UseSubtractFixedOffset= root:Packages:Convert2Dto1D:UseSubtractFixedOffset
	NVAR UseSampleMeasTime= root:Packages:Convert2Dto1D:UseSampleMeasTime
	NVAR UseEmptyMeasTime= root:Packages:Convert2Dto1D:UseEmptyMeasTime
	NVAR UseDarkMeasTime= root:Packages:Convert2Dto1D:UseDarkMeasTime
	NVAR UsePixelSensitivity= root:Packages:Convert2Dto1D:UsePixelSensitivity
	NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
	NVAR UseMonitorForEF = root:Packages:Convert2Dto1D:UseMonitorForEF
	
	NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
	NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance
	
	NVAR CorrectionFactor = root:Packages:Convert2Dto1D:CorrectionFactor
	NVAR SampleI0 = root:Packages:Convert2Dto1D:SampleI0
	NVAR EmptyI0 = root:Packages:Convert2Dto1D:EmptyI0
	NVAR SampleThickness = root:Packages:Convert2Dto1D:SampleThickness
	NVAR SampleTransmission = root:Packages:Convert2Dto1D:SampleTransmission
	NVAR SampleMeasurementTime = root:Packages:Convert2Dto1D:SampleMeasurementTime
	NVAR BackgroundMeasTime = root:Packages:Convert2Dto1D:BackgroundMeasTime
	NVAR EmptyMeasurementTime = root:Packages:Convert2Dto1D:EmptyMeasurementTime
	NVAR SubtractFixedOffset = root:Packages:Convert2Dto1D:SubtractFixedOffset
	
	NVAR DoGeometryCorrection=root:Packages:Convert2Dto1D:DoGeometryCorrection

	NVAR Use2DPolarizationCor = root:Packages:Convert2Dto1D:Use2DPolarizationCor
	NVAR DoPolarizationCorrection = root:Packages:Convert2Dto1D:DoPolarizationCorrection

	NVAR UseCalib2DData=root:Packages:Convert2Dto1D:UseCalib2DData
	
	Wave DataWave=root:Packages:Convert2Dto1D:CCDImageToConvert
	Wave/Z EmptyRunWave=root:Packages:Convert2Dto1D:EmptyData
	Wave/Z DarkCurrentWave=root:Packages:Convert2Dto1D:DarkFieldData
	Wave/Z MaskWave=root:Packages:Convert2Dto1D:M_ROIMask
	Wave/Z Pix2DSensitivity=root:Packages:Convert2Dto1D:Pixel2DSensitivity
	//little checking here...
	if(UseMask)
		if(!WaveExists(MaskWave) || DimSize(MaskWave, 0)!=DimSize(DataWave, 0) || DimSize(MaskWave, 1)!=DimSize(DataWave, 1))
			abort "Mask problem - either does not exist or has differnet dimensions that data "
		endif
	endif
	if(UseDarkField&&!UseCalib2DData)
		if(!WaveExists(DarkCurrentWave) || DimSize(DarkCurrentWave, 0)!=DimSize(DataWave, 0) || DimSize(DarkCurrentWave, 1)!=DimSize(DataWave, 1))
			abort "Dark field problem - either does not exist or has differnet dimensions that data "
		endif
	endif
	if(UseEmptyField&&!UseCalib2DData)
		if(!WaveExists(EmptyRunWave) || DimSize(EmptyRunWave, 0)!=DimSize(DataWave, 0) || DimSize(EmptyRunWave, 1)!=DimSize(DataWave, 1))
			abort "Empty data problem - either does not exist or has differnet dimensions that data "
		endif
	endif
	if(UsePixelSensitivity&&!UseCalib2DData)
		if(!WaveExists(Pix2DSensitivity) || DimSize(Pix2DSensitivity, 0)!=DimSize(DataWave, 0) || DimSize(Pix2DSensitivity, 1)!=DimSize(DataWave, 1))
			abort "Pix2D Sensitivity problem - either does not exist or has differnet dimensions that data "
		endif
	endif

	Duplicate/O DataWave,  Calibrated2DDataSet
	
	Wave Calibrated2DDataSet=root:Packages:Convert2Dto1D:Calibrated2DDataSet
	redimension/S Calibrated2DDataSet
	string OldNote=note(Calibrated2DDataSet)

	variable tempVal
	variable CalibrationPrefactor=1
	
	if(!UseCalib2DData)
		if(UseCorrectionFactor)
			CalibrationPrefactor*=CorrectionFactor
		endif
		if(UseSolidAngle)
			variable solidAngle =PixelSizeX/SampleToCCDDistance * PixelSizeY/SampleToCCDDistance
			//well, this is approximate, but should be just fine... my testing shows, that for 30mm far pixel with 0.3mm size the difference is less than 4e-4... Who cares?
			CalibrationPrefactor*=solidAngle
		endif
		if(UseI0ToCalibrate)
			CalibrationPrefactor/=SampleI0
		endif
		if(UseSampleThickness)
			CalibrationPrefactor/=SampleThickness
		endif
	
		Duplicate/O DataWave, tempDataWv, tempEmptyField
		redimension/S tempDataWv, tempEmptyField
		
		if(UsePixelSensitivity)
			MatrixOP/O/NTHR=0 tempDataWv=tempDataWv/Pix2DSensitivity
		endif
		if(UseDarkField)
			if(UseSampleMeasTime && UseDarkMeasTime)
				if(UsePixelSensitivity)
					tempVal = SampleMeasurementTime/BackgroundMeasTime
					MatrixOP/O/NTHR=0 tempDataWv = tempDataWv - (tempVal*DarkCurrentWave/Pix2DSensitivity)
				else
					tempVal = SampleMeasurementTime/BackgroundMeasTime
					MatrixOP/O/NTHR=0 tempDataWv = tempDataWv - (tempVal*DarkCurrentWave)
				endif
			else
				if(UsePixelSensitivity)
					MatrixOP/O/NTHR=0 tempDataWv = tempDataWv - (DarkCurrentWave/Pix2DSensitivity)
				else
					MatrixOP/O/NTHR=0 tempDataWv = tempDataWv - DarkCurrentWave
				endif
			endif
		endif
		if(UseSubtractFixedOffset)
			MatrixOP/O/NTHR=0 tempDataWv = tempDataWv - SubtractFixedOffset
		endif
		if(UseSampleTransmission)
			MatrixOP/O/NTHR=0 tempDataWv=tempDataWv/SampleTransmission
		endif
		tempEmptyField=0
		variable ScalingConstEF=1
	
		if(UseEmptyField)
			tempEmptyField = EmptyRunWave
			if(UsePixelSensitivity)
				MatrixOP/O/NTHR=0 tempEmptyField = tempEmptyField/Pix2DSensitivity
			endif
			if(UseSubtractFixedOffset)
				MatrixOP/O/NTHR=0 tempEmptyField = tempEmptyField - SubtractFixedOffset
			endif
		
			if(UseMonitorForEF)
				ScalingConstEF=SampleI0/EmptyI0
			elseif(UseEmptyMeasTime && UseSampleMeasTime)
				ScalingConstEF=SampleMeasurementTime/EmptyMeasurementTime
			endif
	
			if(UseDarkField)
				if(UseSampleMeasTime && UseEmptyMeasTime)
					if(UsePixelSensitivity)
						tempVal = EmptyMeasurementTime/BackgroundMeasTime
						MatrixOP/O/NTHR=0 tempEmptyField=tempEmptyField - (tempVal*(DarkCurrentWave/Pix2DSensitivity))
					else
						tempVal = EmptyMeasurementTime/BackgroundMeasTime
						MatrixOP/O/NTHR=0 tempEmptyField=tempEmptyField - (tempVal*DarkCurrentWave)
					endif
				else
					if(UsePixelSensitivity)
						MatrixOP/O/NTHR=0 tempEmptyField=tempEmptyField - (DarkCurrentWave/Pix2DSensitivity)
					else
						MatrixOP/O/NTHR=0 tempEmptyField=tempEmptyField - DarkCurrentWave
					endif
				endif
			endif
	
		endif
	
		MatrixOP/O/NTHR=0 Calibrated2DDataSet = CalibrationPrefactor * (tempDataWv - ScalingConstEF * tempEmptyField)
		
		if(DoGeometryCorrection)  		//geometry correction (= cos(angle)^3) for solid angle projection, added 6/24/2006 to do in 2D data, not in 1D as done (incorrectly also) before using Dales routine.
			NI1A_GenerateGeometryCorr2DWave()
			Wave GeometryCorrection
			MatrixOp/O/NTHR=0 Calibrated2DDataSet = Calibrated2DDataSet / GeometryCorrection
		endif
		if(DoPolarizationCorrection)		//added 8/31/09 to enable 2D corection for polarization
			NI1A_Generate2DPolCorrWv()
			Wave polar2DWave
			MatrixOp/O/NTHR=0 Calibrated2DDataSet = Calibrated2DDataSet / polar2DWave 		//changed to "/" on October 12 2009 since due to use MatrixOp in new formula the calculate values are less than 1 and this is now correct. 
		endif
		
	
		OldNote+= "CalibrationFormula="+CalibrationFormula+";"
		if(UseSampleThickness)
			OldNote+= "SampleThickness="+num2str(SampleThickness)+";"
		endif
		if(UseSampleTransmission)
			OldNote+= "SampleTransmission="+num2str(SampleTransmission)+";"
		endif
		if(UseCorrectionFactor)
			OldNote+= "CorrectionFactor="+num2str(CorrectionFactor)+";"
		endif
		if(UseSubtractFixedOffset)
			OldNote+= "SubtractFixedOffset="+num2str(SubtractFixedOffset)+";"
		endif
		if(UseSampleMeasTime)
			OldNote+= "SampleMeasurementTime="+num2str(SampleMeasurementTime)+";"
		endif
		if(UseEmptyMeasTime)
			OldNote+= "EmptyMeasurementTime="+num2str(EmptyMeasurementTime)+";"
		endif
		if(UseI0ToCalibrate)
			OldNote+= "SampleI0="+num2str(SampleI0)+";"
			OldNote+= "EmptyI0="+num2str(EmptyI0)+";"
		endif
		if(UseDarkMeasTime)
			OldNote+= "BackgroundMeasTime="+num2str(BackgroundMeasTime)+";"
		endif
		if(UsePixelSensitivity)
			OldNote+= "UsedPixelsSensitivity="+num2str(UsePixelSensitivity)+";"
		endif
		if(UseMonitorForEF)
			OldNote+= "UseMonitorForEF="+num2str(UseMonitorForEF)+";"
		endif
	
		SVAR CurrentDarkFieldName=root:Packages:Convert2Dto1D:CurrentDarkFieldName
		SVAR CurrentEmptyName=root:Packages:Convert2Dto1D:CurrentEmptyName	
		if(UseDarkField)
			OldNote+= "CurrentDarkFieldName="+(CurrentDarkFieldName)+";"
		endif
		if(UseEmptyField)
			OldNote+= "CurrentEmptyName="+(CurrentEmptyName)+";"
		endif
	else
		OldNote+= "CalibrationFormula="+"1"+";"
	endif
	SVAR CurrentMaskFileName=root:Packages:Convert2Dto1D:CurrentMaskFileName
	if(UseMask)
		OldNote+= "CurrentMaskFileName="+(CurrentMaskFileName)+";"
	endif
	note /K Calibrated2DDataSet
	note Calibrated2DDataSet, OldNote
	KillWaves/Z tempEmptyField, tempDataWv
	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_Generate2DPolCorrWv()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	//create Polarization correction
	Wave/Z AnglesWave=root:Packages:Convert2Dto1D:AnglesWave
	if(WaveExists(AnglesWave)==0)
		Wave DataWave=root:Packages:Convert2Dto1D:CCDImageToConvert
		NI1A_Create2DAngleWave(DataWave)	
		Wave AnglesWave=root:Packages:Convert2Dto1D:AnglesWave
	endif
	Wave/Z Theta2DWave = root:Packages:Convert2Dto1D:Theta2DWave
	if(!WaveExists(Theta2DWave))
		Wave DataWave=root:Packages:Convert2Dto1D:CCDImageToConvert
		NI1A_Create2DQWave(DataWave)
	endif
	
	Wave/Z polar2DWave=root:Packages:Convert2Dto1D:polar2DWave

	NVAR Use1DPolarizationCor =root:Packages:Convert2Dto1D:Use1DPolarizationCor
	NVAR Use2DPolarizationCor =root:Packages:Convert2Dto1D:Use2DPolarizationCor

	NVAR StartAngle2DPolCor =root:Packages:Convert2Dto1D:StartAngle2DPolCor
	string OldNOte=""
	if(WaveExists(polar2DWave))
		OldNOte=note(polar2DWave)
	endif
	variable NeedToUpdate=0
	
	string ParamsToCheck="SampleToCCDDistance;Wavelength;PixelSizeX;PixelSizeY;beamCenterX;beamCenterY;StartAngle2DPolCor;HorizontalTilt;VerticalTilt;TwoDPolarizFract;Use1DPolarizationCor;"
	NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance		//in millimeters
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength							//in A
	NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX								//in millimeters
	NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY								//in millimeters
	NVAR beamCenterX=root:Packages:Convert2Dto1D:beamCenterX
	NVAR beamCenterY=root:Packages:Convert2Dto1D:beamCenterY
	NVAR TwoDPolarizFract=root:Packages:Convert2Dto1D:TwoDPolarizFract
//	if(Use1DPolarizationCor)
//		TwoDPolarizFract=0
//	endif

	NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt							//tilt in degrees
	NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt								//tilt in degrees
	variable i
	string TempStr
	For(i=0;i<itemsInList(ParamsToCheck);i+=1)
		TempStr=StringFromList(i, ParamsToCheck)
		NVAR TempVar=$("root:Packages:Convert2Dto1D:"+TempStr)
		if(!stringMatch(num2str(TempVar),StringByKey(TempStr,OldNote,"=",";")))
			NeedToUpdate=1
		endif
	endfor

	if(NeedToUpdate)
		print "Updated Polarization correction 2D wave" 
		variable OffsetInRadians=StartAngle2DPolCor *pi/180
		MatrixOp/O/NTHR=0   A2Theta2DWave =  2 * Theta2DWave
		if(Use1DPolarizationCor)
			//	Int=Int/( (1+cos((2theta))^2)/2	)
		    	MatrixOP/O/NTHR=0 polar2DWave = (1+cos(A2Theta2DWave))/2
		else			//at least partially polarized radiation
			if(abs(StartAngle2DPolCor)<1)
			     	MatrixOP/O/NTHR=0 polar2DWave = (TwoDPolarizFract*(powR(cos(A2Theta2DWave),2) * powR(cos(AnglesWave),2)+powR(sin(AnglesWave),2)) +(1-TwoDPolarizFract)*(powR(cos(A2Theta2DWave),2)*powR(sin(AnglesWave),2)+powR(cos(AnglesWave),2)))
			//note, matrixOp cannot do 1/ therefore changed to use 1/ in calling function....
			else
				Duplicate/O AnglesWave, TempAnglesWave
				NVAR beamCenterX=root:Packages:Convert2Dto1D:beamCenterX
				NVAR beamCenterY=root:Packages:Convert2Dto1D:beamCenterY
				//Now angle from 0 degrees, so we can do sectors if necessary
				TempAnglesWave = abs(atan2((BeamCenterY-q),(BeamCenterX-p))-pi+OffsetInRadians)			
			       MatrixOP/O/NTHR=0 polar2DWave = (TwoDPolarizFract*(powR(cos(A2Theta2DWave),2) * powR(cos(TempAnglesWave),2)+powR(sin(TempAnglesWave),2)) +(1-TwoDPolarizFract)*(powR(cos(A2Theta2DWave),2)*powR(sin(TempAnglesWave),2)+powR(cos(TempAnglesWave),2)))
				KillWaves TempAnglesWave
			endif
		endif
		KillWaves A2Theta2DWave
		
		// 2D polarization correction is created. 
		string NewNote=""
	For(i=0;i<itemsInList(ParamsToCheck);i+=1)
		TempStr=StringFromList(i, ParamsToCheck)
		NVAR TempVar=$("root:Packages:Convert2Dto1D:"+TempStr)
		NewNote+=TempStr+"="+num2str(TempVar)+";"
	endfor
	note/K polar2DWave
	note polar2DWave, NewNote
	endif
	setDataFolder OldDf

end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function  NI1A_GenerateGeometryCorr2DWave()
	
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	
	Wave/Z GeometryCorrection = root:Packages:Convert2Dto1D:GeometryCorrection
//	NI1A_CheckGeometryWaves("C")
//	Wave PixRadius2DWave = root:Packages:Convert2Dto1D:PixRadius2DWave
	Wave/Z Q2DWave = root:Packages:Convert2Dto1D:Q2DWave
	if(!WaveExists(Q2DWave))
		Wave DataWave=root:Packages:Convert2Dto1D:CCDImageToConvert
		NI1A_Create2DQWave(DataWave)			//creates 2-D Q wave 
		wave Q2DWave = root:Packages:Convert2Dto1D:Q2DWave
	endif

	NVAR SampleToCCDDistance = root:Packages:Convert2Dto1D:SampleToCCDDistance
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength
	string O2N = note(Q2DWave)

	if(WaveExists(GeometryCorrection))
		string OGN= note(GeometryCorrection)
		//BeamCenterX=501.19;BeamCenterY=506.05;PixelSizeX=0.1;  PixelSizeY=0.1;HorizontalTilt=0;VerticalTilt=0;SampleToCCDDistance=250.5;Wavelength=1.541;
		variable Match1=0, Match2=0, Match3=0, Match4=0, Match5=0
		if(NumberByKey("BeamCenterX",OGN,"=",";")==NumberByKey("BeamCenterX",O2N,"=",";") && NumberByKey("BeamCenterY",OGN,"=+",";")==NumberByKey("BeamCenterY",O2N,"=",";") )
			Match1=1
		endif
		if(NumberByKey("PixelSizeX",OGN,"=",";")==NumberByKey("PixelSizeX",O2N,"=",";") && NumberByKey("PixelSizeY",OGN,"=",";")==NumberByKey("PixelSizeY",O2N,"=",";") )
			Match2=1
		endif
		if(NumberByKey("HorizontalTilt",OGN,"=",";")==NumberByKey("HorizontalTilt",O2N,"=",";") && NumberByKey("VerticalTilt",OGN,"=",";")==NumberByKey("VerticalTilt",O2N,"=",";") )
			Match3=1
		endif
		if(NumberByKey("SampleToCCDDistance",OGN,"=",";")==NumberByKey("SampleToCCDDistance",O2N,"=",";") && NumberByKey("Wavelength",OGN,"=",";")==NumberByKey("Wavelength",O2N,"=",";") )
			Match4=1
		endif
		if(DimSize(GeometryCorrection, 0 )==DimSize(DataWave, 0 ) && DimSize(GeometryCorrection,1 )==DimSize(DataWave, 1 ))
			Match1=5
		endif
		if(Match1 && match2 && Match3 && Match4 && Match5)
			return 1
		endif
	endif
	variable Ltemp = Wavelength / (4 * pi)
//    theta=2*asin(qwave * Lambda /( 4 * pi) )		//theta here is really 2Theta, since it is angle between beam in and out... 
	MatrixOp/O/NTHR=0 GeometryCorrection =  2 * asin(Q2DWave * Ltemp))
	MatrixOp/O/NTHR=0 GeometryCorrection = powR(cos(GeometryCorrection),3)
	Wave GeometryCorrection
	Redimension/S GeometryCorrection
	
	Note GeometryCorrection, O2N
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_CheckGeometryWaves(orientation)		//checks if current geometry waves are OK for the input geometry
	string orientation

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	Wave DataWave=root:Packages:Convert2Dto1D:CCDImageToConvert
	NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance		//in millimeters
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength							//in A
	NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX								//in millimeters
	NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY								//in millimeters
	NVAR beamCenterX=root:Packages:Convert2Dto1D:beamCenterX
	NVAR beamCenterY=root:Packages:Convert2Dto1D:beamCenterY
	SVAR CurrentMaskFileName=root:Packages:Convert2Dto1D:CurrentMaskFileName
	NVAR UseMask=root:Packages:Convert2Dto1D:UseMask
	NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt
	NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt
	NVAR UserThetaMin=root:Packages:Convert2Dto1D:UserThetaMin
	NVAR UserThetaMax=root:Packages:Convert2Dto1D:UserThetaMax
	NVAR UserDMin=root:Packages:Convert2Dto1D:UserDMin
	NVAR UserDMax=root:Packages:Convert2Dto1D:UserDMax
	NVAR UserQMin=root:Packages:Convert2Dto1D:UserQMin
	NVAR UserQMax=root:Packages:Convert2Dto1D:UserQMax
	
//	wave/Z Radius2DWave=root:Packages:Convert2Dto1D:Radius2DWave
	wave/Z Q2DWave=root:Packages:Convert2Dto1D:Q2DWave
	wave/Z Rdistribution1D=$("root:Packages:Convert2Dto1D:Rdistribution1D_"+orientation)
	wave/Z AnglesWave=root:Packages:Convert2Dto1D:AnglesWave
	wave/Z LUT=$("root:Packages:Convert2Dto1D:LUT_"+orientation)
	wave/Z Qdistribution1D=$("root:Packages:Convert2Dto1D:Qdistribution1D_"+orientation)
	wave/Z HistogramWv=$("root:Packages:Convert2Dto1D:HistogramWv_"+orientation)
	wave/Z Qvector=$("root:Packages:Convert2Dto1D:Qvector_"+orientation)
	
	//Check that the waves exist at all...
	if (!WaveExists(Qvector) || !WaveExists(HistogramWv) || !WaveExists(LUT))
		NI1A_Create2DQWave(DataWave)			//creates 2-D Q wave does not need to be run always...
		NI1A_Create2DAngleWave(DataWave)			//creates 2-D Azimuth Angle wave does not need to be run always...
		NI1A_CreateLUT(orientation)					//creates 1D LUT, should not be run always....
		//NI1A_CreateQvector(orientation)				//creates 2-D Q wave does not need to be run always...
		NI1A_CreateHistogram(orientation)				//creates 2-D Q wave does not need to be run always...
		wave KillQ2D = $("root:Packages:Convert2Dto1D:Qdistribution1D_"+orientation)
		KillWaves/Z KillQ2D
		return 1
	endif
	
	variable yesno=0
	//First, 2DQwave may be wrong... 
	string NoteStr=note(Q2DWave)
	string oldSampleToCCDDistance = stringByKey("SampleToCCDDistance", NoteStr , "=")
	string oldBeamCenterX = stringByKey("BeamCenterX", NoteStr , "=")
	string oldBeamCenterY = stringByKey("BeamCenterY", NoteStr , "=")
	string oldPixelSizeX = stringByKey("PixelSizeX", NoteStr , "=")
	string oldPixelSizeY = stringByKey("PixelSizeY", NoteStr , "=")
	string oldHorizontalTilt = stringByKey("HorizontalTilt", NoteStr , "=")
	string oldVerticalTilt = stringByKey("VerticalTilt", NoteStr , "=")
	string oldWavelength = stringByKey("Wavelength", NoteStr , "=")
	variable diff6=cmpstr(oldSampleToCCDDistance,num2str(SampleToCCDDistance))!=0 ||cmpstr(oldWavelength,num2str(Wavelength))!=0 || cmpstr(oldBeamCenterX,num2str(BeamCenterX))!=0 || cmpstr(oldBeamCenterY,num2str(BeamCenterY))!=0
	variable diff7 = cmpstr(oldPixelSizeX,num2str(PixelSizeX))!=0 || cmpstr(oldPixelSizeY,num2str(PixelSizeY))!=0  || cmpstr(oldHorizontalTilt,num2str(HorizontalTilt))!=0  || cmpstr(oldVerticalTilt,num2str(VerticalTilt))!=0
	if(diff6 || diff7)
		NI1A_Create2DQWave(DataWave)			//creates 2-D Q wave does not need to be run always...
		yesno=1
	endif

	//First, AnglesWave may be wrong... 
	NoteStr=note(AnglesWave)
	oldBeamCenterX = stringByKey("BeamCenterX", NoteStr , "=")
	oldBeamCenterY = stringByKey("BeamCenterY", NoteStr , "=")
	if(cmpstr(oldBeamCenterX,num2str(BeamCenterX))!=0 || cmpstr(oldBeamCenterY,num2str(BeamCenterY))!=0)
		NI1A_Create2DAngleWave(DataWave)			//creates 2-D Q wave does not need to be run always...
		yesno=1
	endif
	
	NoteStr=note(LUT)
	oldBeamCenterX = stringByKey("BeamCenterX", NoteStr , "=")
	oldSampleToCCDDistance = stringByKey("SampleToCCDDistance", NoteStr , "=")
	oldWavelength = stringByKey("Wavelength", NoteStr , "=")
	oldBeamCenterY = stringByKey("BeamCenterY", NoteStr , "=")
	oldPixelSizeX = stringByKey("PixelSizeX", NoteStr , "=")
	oldPixelSizeY = stringByKey("PixelSizeY", NoteStr , "=")
	oldHorizontalTilt = stringByKey("HorizontalTilt", NoteStr , "=")
	oldVerticalTilt = stringByKey("VerticalTilt", NoteStr , "=")
	variable oldUseMask=NumberByKey("UseMask", NoteStr , "=")
	string OldMaskName=stringByKey("CurrentMaskFileName", NoteStr , "=") 
	diff6=cmpstr(oldSampleToCCDDistance,num2str(SampleToCCDDistance))!=0 ||cmpstr(oldWavelength,num2str(Wavelength))!=0 || cmpstr(oldBeamCenterX,num2str(BeamCenterX))!=0 || cmpstr(oldBeamCenterY,num2str(BeamCenterY))!=0
	if(diff6 || cmpstr(OldMaskName,CurrentMaskFileName)!=0 || UseMask!=oldUseMask || cmpstr(oldPixelSizeX,num2str(PixelSizeX))!=0 || cmpstr(oldPixelSizeY,num2str(PixelSizeY))!=0  || cmpstr(oldHorizontalTilt,num2str(HorizontalTilt))!=0  || cmpstr(oldVerticalTilt,num2str(VerticalTilt))!=0)
//		NI1A_Create2DQWave(DataWave)			//creates 2-D Q wave does not need to be run always...
//		NI1A_Create2DAngleWave(DataWave)			//creates 2-D Azimuth Angle wave does not need to be run always...
		NI1A_CreateLUT(orientation)					//creates 1D LUT, should not be run always....
		yesno=1
	endif
	wave LUT=$("root:Packages:Convert2Dto1D:LUT_"+orientation)
	
	NoteStr=note(HistogramWv)
	oldSampleToCCDDistance = stringByKey("SampleToCCDDistance", NoteStr , "=")
	oldBeamCenterX = stringByKey("BeamCenterX", NoteStr , "=")
	oldBeamCenterY = stringByKey("BeamCenterY", NoteStr , "=")
	oldPixelSizeX = stringByKey("PixelSizeX", NoteStr , "=")
	oldPixelSizeY = stringByKey("PixelSizeY", NoteStr , "=")
	oldHorizontalTilt = stringByKey("HorizontalTilt", NoteStr , "=")
	oldVerticalTilt = stringByKey("VerticalTilt", NoteStr , "=")
	oldWavelength = stringByKey("Wavelength", NoteStr , "=")
	variable oldQBL = NumberByKey("QbinningLogarithmic", NoteStr , "=")
	variable oldQVNP = NumberByKey("QvectorNumberPoints", NoteStr , "=")
	oldUseMask=NumberByKey("UseMask", NoteStr , "=")
	OldMaskName=stringByKey("CurrentMaskFileName", NoteStr , "=") 
	NVAR QBL=root:Packages:Convert2Dto1D:QbinningLogarithmic
	NVAR QVNP=root:Packages:Convert2Dto1D:QvectorNumberPoints
	
	string oldUserThetaMin=stringByKey("UserThetaMin", NoteStr , "=")
	string oldUserThetaMax=stringByKey("UserThetaMax", NoteStr , "=")
	string oldUserDMin=stringByKey("UserDMin", NoteStr , "=")
	string oldUserDMax=stringByKey("UserDMax", NoteStr , "=")
	string oldUserQMin=stringByKey("UserQMin", NoteStr , "=")
	string oldUserQMax=stringByKey("UserQMax", NoteStr , "=")
	variable diff5=(cmpstr(oldUserThetaMin,num2str(UserThetaMin))!=0 || cmpstr(oldUserThetaMax,num2str(UserThetaMax))!=0 || cmpstr(oldUserDMin,num2str(UserDMin))!=0 || cmpstr(oldUserDMax,num2str(UserDMax))!=0 || cmpstr(oldUserQMin,num2str(UserQMin))!=0 || cmpstr(oldUserQMax,num2str(UserQMax))!=0)
	variable diff1=(yesno || oldQBL!=QBL || oldQVNP!=QVNP || cmpstr(oldSampleToCCDDistance,num2str(SampleToCCDDistance))!=0 || cmpstr(oldBeamCenterX,num2str(BeamCenterX))!=0)
	variable diff2=(cmpstr(oldBeamCenterY,num2str(BeamCenterY))!=0 || cmpstr(oldPixelSizeX,num2str(PixelSizeX))!=0 || cmpstr(oldPixelSizeY,num2str(PixelSizeY))!=0  || cmpstr(oldHorizontalTilt,num2str(HorizontalTilt))!=0  || cmpstr(oldVerticalTilt,num2str(VerticalTilt))!=0 )
	variable diff3 = abs(str2num(oldWavelength)-Wavelength)>0.001*Wavelength
	variable diff4 =(cmpstr(OldMaskName,CurrentMaskFileName)!=0 || UseMask!=oldUseMask)
	if( diff1 || diff2 || diff3 || diff4 || diff5)		//Ok, need to run these
//		if(!yesno)				//have not yet run the first three above...
//			NI1A_Create2DQWave(DataWave)			//creates 2-D Q wave does not need to be run always...
//			NI1A_Create2DAngleWave(DataWave)			//creates 2-D Azimuth Angle wave does not need to be run always...
//			NI1A_CreateLUT(orientation)					//creates 1D LUT, should not be run always....
//		endif		//the ones below must be run always...
	//	NI1A_CreateQvector(orientation)				//creates 2-D Q wave does not need to be run always...
		wave/Z Qdistribution1D=$("root:Packages:Convert2Dto1D:Qdistribution1D_"+orientation)
		if(!WaveExists(Qdistribution1D))
			NI1A_CreateLUT(orientation)					//creates 1D LUT, should not be run always.... Will create Qdistribution 1D vector...
		endif
		NI1A_CreateHistogram(orientation)				//creates 2-D Q wave does not need to be run always...
		yesno=1
	endif
	wave HistogramWv=$("root:Packages:Convert2Dto1D:HistogramWv_"+orientation)
	wave Qvector=$("root:Packages:Convert2Dto1D:Qvector_"+orientation)
	
	wave/Z KillQ2D = $("root:Packages:Convert2Dto1D:Qdistribution1D_"+orientation)
	wave/Z KillR2D = $("root:Packages:Convert2Dto1D:Rdistribution1D_"+orientation)
	KillWaves/Z KillQ2D, KillRQ2D
	setDataFolder OldDf
	return YesNo
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_CreateHistogram(orientation)
	string orientation

	print "Creating histogram"
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D
	wave Qdistribution1D=$("root:Packages:Convert2Dto1D:Qdistribution1D_"+orientation)
	wave LUT=$("root:Packages:Convert2Dto1D:LUT_"+orientation)
	
	Make/O $("HistogramWv_"+orientation)
	Wave HistogramWv=$("HistogramWv_"+orientation)
	redimension/S HistogramWv
	NVAR QbinningLogarithmic=root:Packages:Convert2Dto1D:QbinningLogarithmic
	NVAR QvectorNumberPoints=root:Packages:Convert2Dto1D:QvectorNumberPoints
	
	NVAR UseQvector=root:Packages:Convert2Dto1D:UseQvector
	NVAR UseTheta=root:Packages:Convert2Dto1D:UseTheta
	NVAR UseDspacing=root:Packages:Convert2Dto1D:UseDspacing
	NVAR UserThetaMin=root:Packages:Convert2Dto1D:UserThetaMin
	NVAR UserThetaMax=root:Packages:Convert2Dto1D:UserThetaMax
	NVAR UserDMin=root:Packages:Convert2Dto1D:UserDMin
	NVAR UserDMax=root:Packages:Convert2Dto1D:UserDMax
	NVAR UserQMin=root:Packages:Convert2Dto1D:UserQMin
	NVAR UserQMax=root:Packages:Convert2Dto1D:UserQMax
	NVAR SampleToCCDDistance = root:Packages:Convert2Dto1D:SampleToCCDDistance	//in mm
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength							//in A
	variable UserMin=0
	variable UserMax=0
	variable MaxQ
	variable MinQ		//next define Qmin and Qmax according to user needs
	if(UseQvector && UserQMin>0)
		UserMin=1
		MinQ=UserQMin
	elseif(UseDspacing && UserDMax>0)
		UserMin=1
		MinQ=2*pi / UserDMax
	elseif(UseTheta && UserThetaMin>0)
		UserMin=1
		MinQ=4 *pi * sin (pi*UserThetaMin/360) / Wavelength
	else
		UserMin=0
	endif
	if(UseQvector && UserQMax>0)
		UserMax=1
		MaxQ=UserQMax
	elseif(UseDspacing && UserDMin>0)
		UserMax=1
		MaxQ=2*pi / UserDMin
	elseif(UseTheta && UserThetaMax>0)
		UserMax=1
		MaxQ=4 *pi * sin (pi*UserThetaMax/360) / Wavelength
	else
		UserMax=0
	endif
	//wavestats/Q Qdistribution1D
	make/O/N=(QvectorNumberPoints) $("root:Packages:Convert2Dto1D:Qvector_"+orientation)
	make/O/N=(QvectorNumberPoints) $("root:Packages:Convert2Dto1D:QvectorWidth_"+orientation)
	wave Qvector=$("root:Packages:Convert2Dto1D:Qvector_"+orientation)
	wave QvectorWidth=$("root:Packages:Convert2Dto1D:QvectorWidth_"+orientation)
	variable MinQtemp
	
	if (QbinningLogarithmic)
		//logarithmic binning of Q
		duplicate/O  Qdistribution1D, logQdistribution1D
		logQdistribution1D = log(Qdistribution1D) 
		wavestats/Q logQdistribution1D
		if(!UserMax)
			MaxQ=V_max
		else
			MaxQ = log(MaxQ)
			if(MaxQ > V_max)
				MaxQ = V_max
			endif
		endif
		if(!UserMin)
			MinQ=V_min
		else
			MinQ = log(MinQ)
			if(MinQ<V_min)
				MinQ = V_min
			endif
		endif
		if(MinQ>MaxQ )
			abort "Error in create Histogram, MinQ > MaxQ"
		endif
		MinQtemp = MinQ + 0.2*(MaxQ-MinQ)/QvectorNumberPoints
		logQdistribution1D = (numtype(logQdistribution1D[p])==0 && logQdistribution1D[p]>MinQ) ? logQdistribution1D[p] : MinQtemp
	//	wavestats/Q logQdistribution1D
		Histogram /B={MinQ, ((MaxQ-MinQ)/QvectorNumberPoints), QvectorNumberPoints } logQdistribution1D, HistogramWv 
		Qvector = MinQ + 0.5*(MaxQ-MinQ)/QvectorNumberPoints+p*(MaxQ-MinQ)/QvectorNumberPoints
		Qvector = 10^(Qvector)
		QvectorWidth = Qvector[p+1] - Qvector[p]
		QvectorWidth[numpnts(Qvector)-1]=QvectorWidth[numpnts(Qvector)-2]
		killwaves logQdistribution1D
	else
		//linear binning of Q
		wavestats/Q Qdistribution1D
		if(!UserMax)
			MaxQ=V_max
		else
			if(MaxQ>V_max)
				MaxQ = V_max
			endif
		endif
		if(!UserMin)
			MinQ=V_min
		else
			if(MinQ<V_min)
				MinQ=V_min
			endif
		endif	//next line has problem with MinQ and single precision of Qdistribution1D... Need ot set to slightly higher value...
		if(MinQ>MaxQ )
			abort "Error in create Histogram, MinQ > MaxQ"
		endif
		MinQtemp = MinQ + 0.2*(MaxQ-MinQ)/QvectorNumberPoints
		Qdistribution1D = (Qdistribution1D[p]>MinQ) ? Qdistribution1D[p] : MinQtemp
		Histogram /B={MinQ, ((MaxQ-MinQ)/QvectorNumberPoints), QvectorNumberPoints } Qdistribution1D, HistogramWv 
		Qvector = MinQ + 0.5*(MaxQ-MinQ)/QvectorNumberPoints+ p*(MaxQ-MinQ)/QvectorNumberPoints
		QvectorWidth = Qvector[p+1] - Qvector[p]
		QvectorWidth[numpnts(Qvector)-1]=QvectorWidth[numpnts(Qvector)-2]
	endif
	string NoteStr=note(Qdistribution1D)
	NoteStr+="QbinningLogarithmic="+num2str(QbinningLogarithmic)+";"
	NoteStr+="QvectorNumberPoints="+num2str(QvectorNumberPoints)+";"	
	NoteStr+="UserThetaMin="+num2str(UserThetaMin)+";"	
	NoteStr+="UserThetaMax="+num2str(UserThetaMax)+";"	
	NoteStr+="UserDMin="+num2str(UserDMin)+";"	
	NoteStr+="UserDMax="+num2str(UserDMax)+";"	
	NoteStr+="UserQMin="+num2str(UserQMin)+";"	
	NoteStr+="UserQMax="+num2str(UserQMax)+";"	
	note HistogramWv, NoteStr
	//create now 2theta wave and d spacing wave
	Duplicate/O Qvector, $("root:Packages:Convert2Dto1D:TwoTheta_"+orientation), $("root:Packages:Convert2Dto1D:Dspacing_"+orientation), $("root:Packages:Convert2Dto1D:DistanceInmm_"+orientation)
	Duplicate/O Qvector, $("root:Packages:Convert2Dto1D:TwoThetaWidth_"+orientation), $("root:Packages:Convert2Dto1D:DspacingWidth_"+orientation), $("root:Packages:Convert2Dto1D:DistacneInmmWidth_"+orientation)
	wave TwoTheta=$("root:Packages:Convert2Dto1D:TwoTheta_"+orientation)
	wave Dspacing = $("root:Packages:Convert2Dto1D:Dspacing_"+orientation)
	wave DistanceInmm = $("root:Packages:Convert2Dto1D:DistanceInmm_"+orientation)
	wave TwoThetaWidth = $("root:Packages:Convert2Dto1D:TwoThetaWidth_"+orientation)
	wave DspacingWidth = $("root:Packages:Convert2Dto1D:DspacingWidth_"+orientation)
	wave DistacneInmmWidth = $("root:Packages:Convert2Dto1D:DistacneInmmWidth_"+orientation)
	// sin (theta) = Q * Lambda / 4 * pi     
	// Lamdba = 2 * d * sin (theta)
	// d = 0.5 * Lambda / sin(theta) = 2 * pi / Q    Q = 2pi/d
	// these are Nika theta calcualtions for no tilts case....
	//	Multithread Theta2DWave = sqrt(((p-BeamCenterX)*PixelSizeX)^2 + ((q-BeamCenterY)*PixelSizeY)^2)	//distacne from center 
	//	 Multithread Theta2DWave = atan(Theta2DWave/SampleToCCDDistance)/2		//theta calculation...
	// tg(2*theta) = distFromCenter / SDD     This is valid for notiltscase, but here the Q is corrected for the tilts anyway, so this is no tilts case
	// distance from center =SDD * tg(twoTheta)
	variable constVal=Wavelength / (4 * pi)
	TwoTheta =  2 * asin ( Qvector * constVal) * 180 /pi
	TwoThetaWidth  = TwoTheta[p+1] - TwoTheta [p]
	TwoThetaWidth[numpnts(TwoThetaWidth)-1]=TwoThetaWidth[numpnts(TwoThetaWidth)-2]
	constVal = 2*pi
	Dspacing = constVal / Qvector
	DSpacingWidth  = Dspacing[p+1] - Dspacing [p]
	DSpacingWidth[numpnts(DSpacingWidth)-1]=DSpacingWidth[numpnts(DSpacingWidth)-2]
	
	DistanceInmm =  SampleToCCDDistance*tan(TwoTheta*pi/180)
	DistacneInmmWidth  = DistanceInmm[p+1] - DistanceInmm[p]
	DistacneInmmWidth[numpnts(DistacneInmmWidth)-1]=DistacneInmmWidth[numpnts(DistacneInmmWidth)-2]
	
	setDataFOlder OldDF
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_CreateQvector(orientation)
	string orientation

//	print "Creating Q vector"
//	
//	string OldDf=GetDataFolder(1)
//	setDataFolder root:Packages:Convert2Dto1D
//	wave Rdistribution1D=$("root:Packages:Convert2Dto1D:Rdistribution1D_"+orientation)
//	wave LUT=$("root:Packages:Convert2Dto1D:LUT_"+orientation)
//	NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance		//in millimeters
//	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength							//in A
//	//wavelength=12.398424437/EnergyInKeV
//	
//	//Create wave for q distribution
//	Duplicate/O Rdistribution1D, $("Qdistribution1D_"+orientation)
//	wave Qdistribution1D=$("Qdistribution1D_"+orientation)
//	Redimension/S Qdistribution1D
//	//Qdistribution1D = ((4*pi)/Wavelength)*sin(0.5*Rdistribution1D/SampleToCCDDistance)
//	Qdistribution1D = ((4*pi)/Wavelength)*sin(0.5*atan(Rdistribution1D/SampleToCCDDistance))
//	string NoteStr=note(Rdistribution1D)
//	NoteStr+="SampleToCCDDistance="+num2str(SampleToCCDDistance)+";"
//	NoteStr+="Wavelength="+num2str(Wavelength)+";"	
//	note Qdistribution1D, NoteStr
//
//	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_CreateLUT(orientation)
	string orientation

	print "Creating LUT for "+orientation+"  orientation"

	string OldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	wave Q2DWave=root:Packages:Convert2Dto1D:Q2DWave
	Wave AnglesWave=root:Packages:Convert2Dto1D:AnglesWave
	NVAR UseMask=root:Packages:Convert2Dto1D:UseMask
	NVAR QbinningLogarithmic=root:Packages:Convert2Dto1D:QbinningLogarithmic
	NVAR QvectorNumberPoints=root:Packages:Convert2Dto1D:QvectorNumberPoints
	NVAR DoSectorAverages=root:Packages:Convert2Dto1D:DoSectorAverages
	NVAR NumberOfSectors=root:Packages:Convert2Dto1D:NumberOfSectors
	NVAR SectorsStartAngle=root:Packages:Convert2Dto1D:SectorsStartAngle
	NVAR SectorsHalfWidth=root:Packages:Convert2Dto1D:SectorsHalfWidth
	NVAR SectorsStepInAngle=root:Packages:Convert2Dto1D:SectorsStepInAngle
	SVAR CurrentMaskFileName=root:Packages:Convert2Dto1D:CurrentMaskFileName
	variable centerAngleRad, WidthAngleRad, startAngleFIxed, endAgleFixed
	//apply mask, if selected
	MatrixOp/O/NTHR=0 MaskedQ2DWave=Q2DWave
	redimension/S MaskedQ2DWave
	if(UseMask)
		wave M_ROIMask=root:Packages:Convert2Dto1D:M_ROIMask
		MatrixOp/O/NTHR=0 MaskedQ2DWave = Q2DWave * M_ROIMask
	endif
	if(cmpstr(orientation,"C")!=0)
		MatrixOp/O/NTHR=0  tempAnglesMask = AnglesWave
		centerAngleRad= (pi/180)*str2num(StringFromList(0, orientation,  "_"))
		WidthAngleRad= (pi/180)*str2num(StringFromList(1, orientation,  "_"))
		
		startAngleFixed = centerAngleRad-WidthAngleRad
		endAgleFixed = centerAngleRad+WidthAngleRad

		if(startAngleFixed<0)
			Multithread tempAnglesMask = ((AnglesWave[p][q] > (2*pi+startAngleFixed) || AnglesWave[p][q] <endAgleFixed))? 1 : 0
		elseif(endAgleFixed>(2*pi))
			Multithread tempAnglesMask = (AnglesWave[p][q] > startAngleFixed || AnglesWave[p][q] <(endAgleFixed-2*pi))? 1 : 0
		else
			Multithread tempAnglesMask = (AnglesWave[p][q] > startAngleFixed && AnglesWave[p][q] <endAgleFixed)? 1 : 0
		endif
		
		MatrixOp/O/NTHR=0 MaskedQ2DWave = MaskedQ2DWave * tempAnglesMask
		killwaves tempAnglesMask
	endif
	//radius data are masked now 

	wavestats/Q MaskedQ2DWave
	make/O/N=(V_npnts)  $("Qdistribution1D_"+orientation), $("LUT_"+orientation)
	wave LUT=$("LUT_"+orientation)
	wave Qdistribution1D=$("Qdistribution1D_"+orientation)
	redimension/S Qdistribution1D
	Qdistribution1D = MaskedQ2DWave
	LUT=p
	MakeIndex Qdistribution1D, LUT
	string NoteStr=note(Q2DWave)
	NoteStr+="UseMask="+num2str(UseMask)+";"
	NoteStr+="CurrentMaskFileName="+CurrentMaskFileName+";"
	note Qdistribution1D, NoteStr
	note LUT, NoteStr
	KillWaves/Z MaskedQ2DWave
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_Create2DQWave(DataWave)
	wave DataWave

	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D
	
	NVAR UseCalib2DData=root:Packages:Convert2Dto1D:UseCalib2DData
	Wave/Z Q2DWave
	string NoteStr
	NoteStr = note(DataWave)
	NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance		//in millimeters
	NVAR XrayEnergy = root:Packages:Convert2Dto1D:XrayEnergy							//in A
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength							//in A
	NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX								//in millimeters
	NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY								//in millimeters
	NVAR beamCenterX=root:Packages:Convert2Dto1D:beamCenterX
	NVAR beamCenterY=root:Packages:Convert2Dto1D:beamCenterY

	NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt							//tilt in degrees
	NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt								//tilt in degrees
	if(!UseCalib2DData)		//if we use calibrated data, they come with Qwave...
		//OK, existing radius wave was not correct or did not exist, make the right one... 
		print "Creating 2D Q wave"
		//Create wave for q distribution
		MatrixOp/O/NTHR=0 Q2DWave=DataWave
		MatrixOp/O/NTHR=0 Theta2DWave=DataWave
		Redimension/S Q2DWave
		Redimension/S Theta2DWave
		variable ts=ticks
		if(abs(HorizontalTilt)>0.01 || abs(VerticalTilt)>0.01)		//use tilts, new method March 2011, JIL. Using extracted code by Jon Tischler. 
			NI2T_Calculate2DThetaWithTilts(Theta2DWave)		
			print "Both tilts used, time was = "+num2str((ticks-ts)/60)
		else			//no tilts... 
			Multithread Theta2DWave = sqrt(((p-BeamCenterX)*PixelSizeX)^2 + ((q-BeamCenterY)*PixelSizeY)^2)
			//the QsDWave now contains the distance from beam center  Results should be in mm.... 
			//added to calculate the theta values...
			 Multithread Theta2DWave = atan(Theta2DWave/SampleToCCDDistance)/2
			// MatrixOp/O/NTHR=0 Theta2DWave = atan(Theta2DWave/SampleToCCDDistance)/2
			print "No tilts used, time was = "+num2str((ticks-ts)/60)
		endif
		Theta2DWave[beamCenterX][beamCenterY] = NaN
		//theta values exist by now... Now convert to real Q. Theta2D may be neededc later... 
		Multithread Q2DWave = ((4*pi)/Wavelength)*sin(Theta2DWave)
		//record for which geometry this Radius vector wave was created
	else
		Theta2DWave[beamCenterX][beamCenterY] = NaN
		Q2Dwave[beamCenterX][beamCenterY] = NaN
		XrayEnergy=12.398424437/wavelength
		if(!WaveExists(Q2DWave))
			abort "Qwave does not exist and for Calibrated2D data it must"
		endif
		NoteStr = "Q calibration based on imported 2D data values. Geometry values are fake to make Nika work. Do not trust them.;"
	endif
	NoteStr+="BeamCenterX="+num2str(BeamCenterX)+";"
	NoteStr+="BeamCenterY="+num2str(BeamCenterY)+";"
	NoteStr+="PixelSizeX="+num2str(PixelSizeX)+";"
	NoteStr+="PixelSizeY="+num2str(PixelSizeY)+";"
	NoteStr+="HorizontalTilt="+num2str(HorizontalTilt)+";"
	NoteStr+="VerticalTilt="+num2str(VerticalTilt)+";"
	NoteStr+="SampleToCCDDistance="+num2str(SampleToCCDDistance)+";"
	NoteStr+="Wavelength="+num2str(Wavelength)+";"	
	note Q2DWave, NoteStr
	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_Create2DAngleWave(DataWave)
	wave DataWave
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D
	string NoteStr
	NVAR UseCalib2DData=root:Packages:Convert2Dto1D:UseCalib2DData
	Wave/Z AnglesWave
	if(!UseCalib2DData)
		print "Creating Angle wave"

		NVAR beamCenterX=root:Packages:Convert2Dto1D:beamCenterX
		NVAR beamCenterY=root:Packages:Convert2Dto1D:beamCenterY
		//Now angle from 0 degrees, so we can do sectors if necessary
		Duplicate/O DataWave, AnglesWave
		Redimension/S AnglesWave
		Multithread AnglesWave = abs(atan2((BeamCenterY-q),(BeamCenterX-p))-pi)			
		//this creates wave with angle values for each point, values are between 0 and 2*pi
		NoteStr=";BeamCenterX="+num2str(BeamCenterX)+";"
		NoteStr+="BeamCenterY="+num2str(BeamCenterY)+";"
	else
		if(!WaveExists(AnglesWave))
			abort "Angles Wave does not exist and for Calibrated2D data it must"
		endif
		NoteStr = "Orientation Angles calibration is based on imported 2D data values;"
	
	endif
	note AnglesWave, NoteStr

	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_Check2DConversionData()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	Wave/Z DataWave=root:Packages:Convert2Dto1D:CCDImageToConvert
	Wave/Z EmptyRunWave=root:Packages:Convert2Dto1D:EmptyData
	Wave/Z DarkCurrentWave=root:Packages:Convert2Dto1D:DarkFieldData
	Wave/Z MaskWave=root:Packages:Convert2Dto1D:M_ROIMask
	Wave/Z Pix2DSensitivity=root:Packages:Convert2Dto1D:Pixel2DSensitivity

	NVAR Use2DdataName=root:Packages:Convert2Dto1D:Use2DdataName
	NVAR UseCorrectionFactor=root:Packages:Convert2Dto1D:UseCorrectionFactor
	NVAR UseDarkField=root:Packages:Convert2Dto1D:UseDarkField
	NVAR UseDarkMeasTime=root:Packages:Convert2Dto1D:UseDarkMeasTime
	NVAR UseEmptyField=root:Packages:Convert2Dto1D:UseEmptyField
	NVAR UseEmptyMeasTime=root:Packages:Convert2Dto1D:UseEmptyMeasTime
	NVAR UseI0ToCalibrate=root:Packages:Convert2Dto1D:UseI0ToCalibrate
	NVAR UseMask=root:Packages:Convert2Dto1D:UseMask
	NVAR UseMonitorForEF=root:Packages:Convert2Dto1D:UseMonitorForEF
	NVAR UsePixelSensitivity=root:Packages:Convert2Dto1D:UsePixelSensitivity
	NVAR UseSampleMeasTime=root:Packages:Convert2Dto1D:UseSampleMeasTime
	NVAR UseSampleThickness=root:Packages:Convert2Dto1D:UseSampleThickness
	NVAR UseSampleTransmission=root:Packages:Convert2Dto1D:UseSampleTransmission
	NVAR UseSubtractFixedOffset=root:Packages:Convert2Dto1D:UseSubtractFixedOffset
	NVAR UsePixelSensitivity= root:Packages:Convert2Dto1D:UsePixelSensitivity
	NVAR UseCalib2DData=root:Packages:Convert2Dto1D:UseCalib2DData
	if (!WaveExists(DataWave))
		Abort "Data wave does not exist"
	endif
	if(!UseCalib2DData && (UseEmptyField && (WaveExists(EmptyRunWave)!=1)))
		Abort "Empty wave does not exist"
	endif
	if(!UseCalib2DData && (UseDarkField && (WaveExists(DarkCurrentWave)!=1)))
		Abort "Dark field wave does not exist"
	endif
	if(!UseCalib2DData && (UsePixelSensitivity && (WaveExists(Pix2DSensitivity)!=1)))
		Abort "Pix2D sensitivity wave does not exist"
	endif
	//check the waves for dimensions, they must be the same....
	if(!UseCalib2DData && UsePixelSensitivity)
		if(DimSize(DataWave,0)!=dimsize(Pix2DSensitivity,0) || DimSize(DataWave,1)!=DimSize(Pix2DSensitivity,1))
			Abort "Error, the pix2D sensitivity wave does not have the same dimensions" 
		endif
	endif
	if(!UseCalib2DData && UseEmptyField)
		if(DimSize(DataWave,0)!=dimsize(EmptyRunWave,0) || DimSize(DataWave,1)!=DimSize(EmptyRunWave,1))
			Abort "Error, the empty wave does not have the same dimensions" 
		endif
	endif
	if(!UseCalib2DData && UseDarkField)
		if(DimSize(DataWave,0)!=dimsize(DarkCurrentWave,0) || DimSize(DataWave,1)!=DimSize(DarkCurrentWave,1))
			Abort "Error, the dark field wave does not have the same dimensions" 
		endif
	endif
	if(UseMask)
		if(DimSize(DataWave,0)!=dimsize(MaskWave,0) || DimSize(DataWave,1)!=DimSize(MaskWave,1))
			Abort "Error, the mask field wave does not have the same dimensions" 
		endif
	endif

	setDataFolder OldDf
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	
	SVAR RebinCalib2DDataToPnts=root:Packages:Convert2Dto1D:RebinCalib2DDataToPnts
	SVAR Calib2DDataOutputFormat =root:Packages:Convert2Dto1D:Calib2DDataOutputFormat

	if(StringMatch(ctrlName,"Calib2DDataOutputFormat"))
		Calib2DDataOutputFormat = popStr
	endif
	if(StringMatch(ctrlName,"RebinCalib2DData"))
		RebinCalib2DDataToPnts = popStr
	endif

	if(cmpstr(ctrlName,"Select2DDataType")==0)
		//set appropriate extension
		SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension
		NVAR UseCalib2DData=root:Packages:Convert2Dto1D:UseCalib2DData
		DataFileExtension = popStr
		NI1A_UpdateDataListBox()
		if(cmpstr(popStr,"GeneralBinary")==0)
			NI1_GBLoaderPanelFnct()
		endif
		if(cmpstr(popStr,"Pilatus")==0)
			NI1_PilatusLoaderPanelFnct()
		endif
		if(cmpstr(popStr,"ESRFedf")==0)
			NI1_ESRFEdfLoaderPanelFnct()
		endif	
		CheckBox ReverseBinnedData,help={"Reverse binning if necessary?"}, disable=!(UseCalib2DData && StringMatch(DataFileExtension, "canSAS/Nexus"))
	endif
	if(cmpstr(ctrlName,"SelectBlank2DDataType")==0)
		//set appropriate extension
		SVAR BlankFileExtension=root:Packages:Convert2Dto1D:BlankFileExtension
		BlankFileExtension = popStr
		NI1A_UpdateEmptyDarkListBox()
		if(cmpstr(popStr,"GeneralBinary")==0)
			NI1_GBLoaderPanelFnct()
		endif
		if(cmpstr(popStr,"Pilatus")==0)
			NI1_PilatusLoaderPanelFnct()
		endif
	endif
	if(cmpstr(ctrlName,"DataCalibrationString")==0)
		//set appropriate extension
		SVAR DataCalibrationString=root:Packages:Convert2Dto1D:DataCalibrationString
		DataCalibrationString = popStr
	endif
	if(cmpstr(ctrlName,"RebinCalib2DDataToPnts")==0)
		//set appropriate extension
		SVAR RebinCalib2DDataToPnts=root:Packages:Convert2Dto1D:RebinCalib2DDataToPnts
		RebinCalib2DDataToPnts = popStr
	endif

	if(cmpstr(ctrlName,"FIlesSortOrder")==0)
		NVAR FIlesSortOrder=root:Packages:Convert2Dto1D:FIlesSortOrder
		FIlesSortOrder = popNum-1
		NI1A_UpdateDataListBox()
	endif
	
	if(cmpstr(ctrlName,"LineProf_CurveType")==0)
		//here we select start of the range...
		SVAR LineProf_CurveType=root:Packages:Convert2Dto1D:LineProf_CurveType
		LineProf_CurveType=popStr		
		SVAR KnWCT=root:Packages:Convert2Dto1D:LineProf_CurveType
		SetVariable LineProf_LineAzAngle,disable=(!stringMatch(KnWCT,"Angle Line")), win=NI1A_Convert2Dto1DPanel
		SetVariable LineProf_EllipseAR,disable=(!stringMatch(KnWCT,"Ellipse")), win=NI1A_Convert2Dto1DPanel
		SetVariable LineProf_GIIncAngle,disable=((!stringMatch(KnWCT,"GISAXS_FixQy")&&!stringMatch(KnWCT,"GI_Horizontal Line")&&!stringMatch(KnWCT,"GI_Vertical Line"))), win=NI1A_Convert2Dto1DPanel
		checkbox LineProf_UseBothHalfs,disable=(stringMatch(KnWCT,"Angle Line")), win=NI1A_Convert2Dto1DPanel	
		NI1A_LineProf_Update()
	endif


	if(cmpstr(ctrlName,"SelectStartOfRange")==0)
		//here we select start of the range...
		NVAR StartDataRangeNumber=root:Packages:Convert2Dto1D:StartDataRangeNumber
		StartDataRangeNumber=popNum
		NI1A_MakeContiguousSelection()
	endif
	if(cmpstr(ctrlName,"SelectEndOfRange")==0)
		//here we select end of the range...
		NVAR EndDataRangeNumber=root:Packages:Convert2Dto1D:EndDataRangeNumber
		EndDataRangeNumber=popNum
		NI1A_MakeContiguousSelection()
	endif
	if(cmpstr(ctrlName,"ColorTablePopup")==0)
		SVAR ColorTableName=root:Packages:Convert2Dto1D:ColorTableName
		ColorTableName = popStr
		NI1A_TopCCDImageUpdateColors(1)
	endif
	if(cmpstr(ctrlName,"MaskImageColor")==0)
		NI1M_ChangeMaskColor(popStr) 
	endif
	if(cmpstr(ctrlName,"GI_Shape1")==0)
		SVAR GI_Shape1=root:Packages:Convert2Dto1D:GI_Shape1
		GI_Shape1=popStr 
		NI1A_TabProc("",6)
	endif

	DoWIndow/F NI1A_Convert2Dto1DPanel
	DoWIndow/F NI_GBLoaderPanel
	DoWIndow/F NI_PilatusLoaderPanel

	setDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1A_UpdateMainMaskListBox()		

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
//	NI1M_UpdateMaskListBox()
	
	pathinfo Convert2Dto1DMaskPath
	if(V_Flag==0)
		abort
	endif

		Wave/T  ListOf2DMaskData=root:Packages:Convert2Dto1D:ListOf2DMaskData
		Wave ListOf2DMaskDataNumbers=root:Packages:Convert2Dto1D:ListOf2DMaskDataNumbers
//		SVAR MaskFileExtension=root:Packages:Convert2Dto1D:MaskFileExtension
		string ListOfAvailableMasks
		string MaskFileEnd ="*_mask*"
		ListOfAvailableMasks=IndexedFile(Convert2Dto1DMaskPath,-1,".hdf")
		ListOfAvailableMasks+=IndexedFile(Convert2Dto1DMaskPath,-1,".tif")
		
		variable i, imax=0
		string tempstr
//		redimension/N=(itemsInList(ListOfAvailableMasks)) ListOf2DMaskData
//		redimension/N=(itemsInList(ListOfAvailableMasks)) ListOf2DMaskDataNumbers
//		For(i=0;i<ItemsInList(ListOfAvailableMasks);i+=1)
//			tempstr=StringFromList(i, ListOfAvailableMasks)
//			if (stringmatch(tempstr, MaskFileEnd ))
//				ListOf2DMaskData[imax]=tempstr
//				imax+=1
//			endif
//		endfor
		ListOfAvailableMasks = GrepList(ListOfAvailableMasks, "_mask" )
		redimension/N=(itemsInList(ListOfAvailableMasks)) ListOf2DMaskData
		redimension/N=(itemsInList(ListOfAvailableMasks)) ListOf2DMaskDataNumbers
		For(i=0;i<ItemsInList(ListOfAvailableMasks);i+=1)
			tempstr=StringFromList(i, ListOfAvailableMasks)
			ListOf2DMaskData[i]=tempstr
		endfor
		
		sort ListOf2DMaskData, ListOf2DMaskData, ListOf2DMaskDataNumbers
		ListOf2DMaskDataNumbers=0
		DoWindow NI1A_Convert2Dto1DPanel
		if(V_Flag)
			ListBox MaskListBoxSelection win=NI1A_Convert2Dto1DPanel, listWave=root:Packages:Convert2Dto1D:ListOf2DMaskData
			ListBox MaskListBoxSelection win=NI1A_Convert2Dto1DPanel, row= 0,mode= 1,selRow= 0
		endif
	setDataFolder OldDf
	DoUpdate
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_UpdateEmptyDarkListBox()		

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
		Wave/T  ListOf2DEmptyData=root:Packages:Convert2Dto1D:ListOf2DEmptyData
		SVAR DataFileExtension=root:Packages:Convert2Dto1D:BlankFileExtension
		SVAR EmptyDarkNameMatchStr=root:Packages:Convert2Dto1D:EmptyDarkNameMatchStr
		variable i
		string tempstr, realExtension
		if(cmpstr(DataFileExtension, ".tif")==0)
			realExtension=DataFileExtension
		elseif(cmpstr(DataFileExtension, "ADSC")==0 || cmpstr(DataFileExtension, "ADSC_A")==0)
			realExtension=".img"
		elseif(cmpstr(DataFileExtension, "DND/txt")==0)
			realExtension=".txt"
		elseif(cmpstr(DataFileExtension, "TPA/XML")==0)
			realExtension=".xml"
		elseif(cmpstr(DataFileExtension, ".hdf")==0)
			realExtension=".hdf"
		elseif(cmpstr(DataFileExtension, "Nexus")==0)
			realExtension=".hdf"
		elseif(cmpstr(DataFileExtension, "SSRLMatSAXS")==0)
			realExtension=".tif"
		else
			realExtension="????"
		endif
		string ListOfAvailableDataSets
		PathInfo Convert2Dto1DEmptyDarkPath
		if(V_Flag==1)
			if(cmpstr(realExtension, ".hdf")==0)//there are many options for hdf...
				ListOfAvailableDataSets=IndexedFile(Convert2Dto1DEmptyDarkPath,-1,".hdf")
				ListOfAvailableDataSets+=IndexedFile(Convert2Dto1DEmptyDarkPath,-1,".h5")
				ListOfAvailableDataSets+=IndexedFile(Convert2Dto1DEmptyDarkPath,-1,".hdf5")
			else
				ListOfAvailableDataSets=IndexedFile(Convert2Dto1DEmptyDarkPath,-1,realExtension)
			endif	
			if(strlen(ListOfAvailableDataSets)<2)	//none found
				ListOfAvailableDataSets="--none--;"
			endif
			ListOfAvailableDataSets = GrepList(ListOfAvailableDataSets, "^((?!_mask.hdf).)*$" ) //remove _mask files... 
			ListOfAvailableDataSets=NI1A_CleanListOfFilesForTypes(ListOfAvailableDataSets,DataFileExtension,EmptyDarkNameMatchStr)
			redimension/N=(ItemsInList(ListOfAvailableDataSets)) ListOf2DEmptyData
			NI1A_CreateListOfFiles(ListOf2DEmptyData,ListOfAvailableDataSets,realExtension, EmptyDarkNameMatchStr)
			sort ListOf2DEmptyData, ListOf2DEmptyData
			DoWindow NI1A_Convert2Dto1DPanel
			if(V_Flag)
				ListBox Select2DMaskDarkWave win=NI1A_Convert2Dto1DPanel, listWave=root:Packages:Convert2Dto1D:ListOf2DEmptyData
				ListBox Select2DMaskDarkWave win=NI1A_Convert2Dto1DPanel,row= 0,mode= 1,selRow= 0
			endif
		endif
	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_MakeContiguousSelection()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	NVAR StartDataRangeNumber=root:Packages:Convert2Dto1D:StartDataRangeNumber
	NVAR EndDataRangeNumber=root:Packages:Convert2Dto1D:EndDataRangeNumber

	Wave ListOf2DSampleDataNumbers=root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers

	if (StartDataRangeNumber>0 && EndDataRangeNumber>0)
		ListOf2DSampleDataNumbers[0,StartDataRangeNumber-1]=0
		ListOf2DSampleDataNumbers[StartDataRangeNumber-1,EndDataRangeNumber-1]=1
		if(EndDataRangeNumber<numpnts(ListOf2DSampleDataNumbers))
			ListOf2DSampleDataNumbers[EndDataRangeNumber,inf]=0
		endif
	endif
	setDataFolder OldDf
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function/T NI1A_Create2DSelectionPopup()

	Wave/T  ListOf2DSampleData=root:Packages:Convert2Dto1D:ListOf2DSampleData
	variable i, imax=numpnts(ListOf2DSampleData)	
	string MenuStr=""
	For(i=0;i<imax;i+=1)
		MenuStr+=ListOf2DSampleData[i]+";"
	endfor
	return MenuStr
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_ButtonProc(ctrlName) : ButtonControl
	String ctrlName



	if(cmpstr(ctrlName,"CreateOutputPath")==0)
		PathInfo/S Convert2Dto1DOutputPath
		NewPath/C/O/M="Select path to save your data" Convert2Dto1DOutputPath	
	endif
	if(cmpstr(ctrlName,"SelectMaskDarkPath")==0)
		PathInfo/S Convert2Dto1DEmptyDarkPath
		NewPath/C/O/M="Select path to your Empty, Dark, and Mask data" Convert2Dto1DEmptyDarkPath	
		NI1A_UpdateEmptyDarkListBox()	
	endif
	if(cmpstr(ctrlName,"RefreshList")==0)
		ControlInfo/W=NI1A_Convert2Dto1DPanel Select2DInputWave
		variable oldSets=V_startRow
		NI1A_UpdateDataListBox()	
		ListBox Select2DInputWave,win=NI1A_Convert2Dto1DPanel,row=V_startRow
	endif
	if(cmpstr(ctrlName,"LoadDarkField")==0)
		NI1A_LoadEmptyOrDark("Dark")	
	endif
	if(cmpstr(ctrlName,"LoadEmpty")==0)
		NI1A_LoadEmptyOrDark("Empty")		
	endif
	if(cmpstr(ctrlName,"CreateMovie")==0)
		NI1A_CreateMovie()		
	endif
	if(cmpstr(ctrlName,"OnLineDataProcessing")==0)
		NI1A_OnLineDataProcessing()		
	endif
	
	if(cmpstr(ctrlName,"DisplaySelectedFile")==0)
		//set selections for using RAW/Converted data...
		NVAR LineProfileUseRAW=root:Packages:Convert2Dto1D:LineProfileUseRAW
		NVAR LineProfileUseCorrData=root:Packages:Convert2Dto1D:LineProfileUseCorrData
		NVAR SectorsUseRAWData=root:Packages:Convert2Dto1D:SectorsUseRAWData
		NVAR SectorsUseCorrData=root:Packages:Convert2Dto1D:SectorsUseCorrData
		LineProfileUseRAW=1
		LineProfileUseCorrData=0
		SectorsUseRAWData=1
		SectorsUseCorrData=0
		//selection done
		NI1A_DisplayOneDataSet()	
	endif
	if(cmpstr(ctrlName,"ExportDisplayedImage")==0)
		NI1A_ExportDisplayedImage()			
	endif
	if(cmpstr(ctrlName,"SaveDisplayedImage")==0)
		NI1A_SaveDisplayedImage()			
	endif

	if(cmpstr(ctrlName,"ConvertSelectedFiles")==0)
		NI1A_CheckParametersForConv()
		//set selections for using RAW/Converted data...
		NVAR LineProfileUseRAW=root:Packages:Convert2Dto1D:LineProfileUseRAW
		NVAR LineProfileUseCorrData=root:Packages:Convert2Dto1D:LineProfileUseCorrData
		NVAR SectorsUseRAWData=root:Packages:Convert2Dto1D:SectorsUseRAWData
		NVAR SectorsUseCorrData=root:Packages:Convert2Dto1D:SectorsUseCorrData
		LineProfileUseRAW=0
		LineProfileUseCorrData=1
		SectorsUseRAWData=0
		SectorsUseCorrData=1
		//selection done
		NI1A_LoadManyDataSetsForConv()			
	endif
	if(cmpstr(ctrlName,"AveConvertSelectedFiles")==0)
		NI1A_CheckParametersForConv()
		//set selections for using RAW/Converted data...
		NVAR LineProfileUseRAW=root:Packages:Convert2Dto1D:LineProfileUseRAW
		NVAR LineProfileUseCorrData=root:Packages:Convert2Dto1D:LineProfileUseCorrData
		NVAR SectorsUseRAWData=root:Packages:Convert2Dto1D:SectorsUseRAWData
		NVAR SectorsUseCorrData=root:Packages:Convert2Dto1D:SectorsUseCorrData
		LineProfileUseRAW=0
		LineProfileUseCorrData=1
		SectorsUseRAWData=0
		SectorsUseCorrData=1
		//selection done
		NI1A_AveLoadManyDataSetsForConv()		
	endif
	if(cmpstr(ctrlName,"AveConvertNFiles")==0)
		NI1A_CheckParametersForConv()
		//set selections for using RAW/Converted data...
		NVAR LineProfileUseRAW=root:Packages:Convert2Dto1D:LineProfileUseRAW
		NVAR LineProfileUseCorrData=root:Packages:Convert2Dto1D:LineProfileUseCorrData
		NVAR SectorsUseRAWData=root:Packages:Convert2Dto1D:SectorsUseRAWData
		NVAR SectorsUseCorrData=root:Packages:Convert2Dto1D:SectorsUseCorrData
		LineProfileUseRAW=0
		LineProfileUseCorrData=1
		SectorsUseRAWData=0
		SectorsUseCorrData=1
		//selection done
		NI1A_AveLoadNDataSetsForConv()		
	endif

	if(cmpstr(ctrlName,"Select2DDataPath")==0)
		PathInfo/S Convert2Dto1DDataPath
		NewPath/C/O/M="Select path to your data" Convert2Dto1DDataPath
		PathInfo Convert2Dto1DDataPath
		SVAR MainPathInfoStr=root:Packages:Convert2Dto1D:MainPathInfoStr
		MainPathInfoStr=S_path
		TitleBox PathInfoStrt, win =NI1A_Convert2Dto1DPanel, variable=MainPathInfoStr
		NI1A_UpdateDataListBox()		
	endif
	if(cmpstr(ctrlName,"MaskSelectPath")==0)
		PathInfo/S Convert2Dto1DMaskPath
		NewPath/C/O/M="Select path to your data" Convert2Dto1DMaskPath	
		NI1A_UpdateMainMaskListBox()	
		NI1M_UpdateMaskListBox()		
	endif
	if(cmpstr(ctrlName,"LoadMask")==0)
		NI1A_LoadMask()
	endif
	if(cmpstr(ctrlName,"DisplayMaskOnImage")==0)
		NI1M_DisplayMaskOnImage()
		PopupMenu MaskImageColor,win=NI1A_Convert2Dto1DPanel, mode=1
	endif
	if(cmpstr(ctrlName,"RemoveMaskFromImage")==0)
		NI1M_RemoveMaskFromImage()
	endif

//LoadPixel2DSensitivity
	if(cmpstr(ctrlName,"LoadPixel2DSensitivity")==0)
		NI1A_LoadEmptyOrDark("Pixel2DSensitivity")		
	endif
	//this pops up the main panel back, some code should nto do that... 
	DoWIndow/F NI1A_Convert2Dto1DPanel
	//here is code which shiuld nto end with main panel at the top.  
//Store current setting for future use
	if(cmpstr(ctrlName,"SaveCurrentToolSetting")==0)
		//call create mask routine here
		NI1A_StoreLoadCurSettingPnl()
	endif

	if(cmpstr(ctrlName,"CreateMask")==0)
		NI1M_CreateMask()
	endif
//create squared sector graph...
	if(cmpstr(ctrlName,"CreateSectorGraph")==0)
		//call create mask routine here
		NI1_MakeSectorGraph()
	endif
	
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1M_DisplayMaskOnImage()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	DoWindow CCDImageToConvertFig
	if(V_Flag)
		DoWindow/F CCDImageToConvertFig
		Wave/Z M_ROIMask=root:Packages:Convert2Dto1D:M_ROIMask
		CheckDisplayed/W=CCDImageToConvertFig M_ROIMask
		if(WaveExists(M_ROIMask) && !V_Flag)
			AppendImage/W=CCDImageToConvertFig M_ROIMask
			ModifyImage/W=CCDImageToConvertFig M_ROIMask  ctab ={0.2,0.5, Grays}, minRGB=(12000,12000,12000),maxRGB=NaN
		endif
	endif
	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1M_ChangeMaskColor(ColorToUse) //red, blue, green
	string ColorToUse

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	DoWindow CCDImageToConvertFig
	if(V_Flag)
		DoWindow/F CCDImageToConvertFig
		Wave/Z M_ROIMask=root:Packages:Convert2Dto1D:M_ROIMask
		CheckDisplayed/W=CCDImageToConvertFig M_ROIMask
		if(WaveExists(M_ROIMask) && V_Flag)
			if(cmpstr(ColorToUse,"red")==0)//red
				ModifyImage/W=CCDImageToConvertFig M_ROIMask ctab ={0.2,0.5,Grays}, minRGB=(65280,0,0),maxRGB=NaN
			elseif(cmpstr(ColorToUse,"blue")==0)//blue
				ModifyImage/W=CCDImageToConvertFig M_ROIMask ctab ={0.2,0.5,Grays}, minRGB=(0,0,65280),maxRGB=NaN
			elseif(cmpstr(ColorToUse,"grey")==0)//grey
				ModifyImage/W=CCDImageToConvertFig M_ROIMask ctab ={0.2,0.5,Grays}, minRGB=(16000,16000,16000),maxRGB=NaN
			elseif(cmpstr(ColorToUse,"black")==0)
				ModifyImage/W=CCDImageToConvertFig M_ROIMask ctab ={0.2,0.5,Grays}, minRGB=(0,0,0),maxRGB=NaN
			else
				ModifyImage/W=CCDImageToConvertFig M_ROIMask ctab ={0.2,0.5,Grays}, minRGB=(0,65280,0),maxRGB=NaN
			endif
		else
			PopupMenu MaskImageColor,win=NI1A_Convert2Dto1DPanel, mode=1
		endif
	endif
	setDataFolder OldDf

end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1M_RemoveMaskFromImage()
	DoWindow CCDImageToConvertFig
	if(V_Flag)
		CheckDisplayed /W=CCDImageToConvertFig root:Packages:Convert2Dto1D:M_ROIMask
		if(V_Flag)
			RemoveImage/W=CCDImageToConvertFig  M_ROIMask
		endif
	endif
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_CheckParametersForConv()
	//check the parameters for conversion
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
	NVAR QvectorNumberPoints= root:Packages:Convert2Dto1D:QvectorNumberPoints
	NVAR QbinningLogarithmic=root:Packages:Convert2Dto1D:QbinningLogarithmic
	NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance
	NVAR Wavelength=root:Packages:Convert2Dto1D:Wavelength
	NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
	SVAR CurrentInstrumentGeometry=root:Packages:Convert2Dto1D:CurrentInstrumentGeometry
	SVAR DataFileType=root:Packages:Convert2Dto1D:DataFileType
	SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension
	SVAR MaskFileExtension=root:Packages:Convert2Dto1D:MaskFileExtension
	SVAR BlankFileExtension=root:Packages:Convert2Dto1D:BlankFileExtension
	SVAR CurrentMaskFileName=root:Packages:Convert2Dto1D:CurrentMaskFileName
	SVAR CCDDataPath=root:Packages:Convert2Dto1D:CCDDataPath
	SVAR CCDfileName=root:Packages:Convert2Dto1D:CCDfileName
	SVAR CCDFileExtension=root:Packages:Convert2Dto1D:CCDFileExtension
	SVAR FileNameToLoad=root:Packages:Convert2Dto1D:FileNameToLoad
	SVAR ColorTableName=root:Packages:Convert2Dto1D:ColorTableName
	
	//now check the geometry...
	if(SampleToCCDDistance<=0 || Wavelength<=0 || PixelSizeX<=0 || PixelSizeY<=0)
		abort "Experiment geometry not setup correctly"
	endif	
	NVAR StoreDataInIgor= root:Packages:Convert2Dto1D:StoreDataInIgor
	NVAR ExportDataFromIgor= root:Packages:Convert2Dto1D:ExportDataOutOfIgor
	if(ExportDataFromIgor+StoreDataInIgor<1)
		Print "No 1D reduction setting was found... Data are processed, but unless you save 2D processed image, nothing is saved for you."
	endif
	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_ImportThisOneFile(SelectedFileToLoad)
	string SelectedFileToLoad

	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D
	SVAR FileNameToLoad=root:Packages:Convert2Dto1D:FileNameToLoad
	FileNameToLoad = SelectedFileToLoad
	SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension
	NVAR UseCalib2DData=root:Packages:Convert2Dto1D:UseCalib2DData
	
	variable loadedOK=NI1A_UniversalLoader("Convert2Dto1DDataPath",SelectedFileToLoad,DataFileExtension,"CCDImageToConvert")
	if(LoadedOK==0)
		return 0
	endif
	//record import data for future use...
	wave CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	if(UseCalib2DData)	//imported calibrated data, this thing is also calibrated data set
		Duplicate/O CCDImageToConvert, Calibrated2DData
	endif
	//allow user function modification to the image through hook function...
#if Exists("ModifyImportedImageHook")
	ModifyImportedImageHook(CCDImageToConvert)
#endif
	//end of allow user modification of imported image through hook function
	redimension/S CCDImageToConvert
	string NewNote=note(CCDImageToConvert)
	NewNote +="Processed on="+date()+","+time()+";"
	Note/K CCDImageToConvert 
	Note CCDImageToConvert, NewNote 
	MatrixOp/O/NTHR=0   CCDImageToConvert_dis=CCDImageToConvert
	Note CCDImageToConvert_dis, NewNote
	setDataFolder OldDf
	return LoadedOK
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_DisplayTheRight2DWave()

	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D

			NVAR DisplayProcessed2DData=root:Packages:Convert2Dto1D:DisplayProcessed2DData
			NVAR DisplayRaw2DData=root:Packages:Convert2Dto1D:DisplayRaw2DData
			NVAR ImageDisplayLogScaled=root:Packages:Convert2Dto1D:ImageDisplayLogScaled
			
			Wave/Z CCDImageToConvert_dis=root:Packages:Convert2Dto1D:CCDImageToConvert_dis
			Wave/Z CCDImageToConvert =root:Packages:Convert2Dto1D:CCDImageToConvert
			if(!WaveExists(CCDImageToConvert_dis)||!WaveExists(CCDImageToConvert))
				return 0
			endif
			if(DisplayRaw2DData)
				wave waveToDisplay = root:Packages:Convert2Dto1D:CCDImageToConvert
			else
				wave/Z waveToDisplay = root:Packages:Convert2Dto1D:Calibrated2DDataSet
				if(!WaveExists(waveToDisplay))
					//Abort "Error in Irena in display of Calibrated data initiated by log int change. Please contact author"
					return 0
				endif
			endif
			Redimension/S CCDImageToConvert_dis
			Redimension/S waveToDisplay
			if(ImageDisplayLogScaled)
				MatrixOp/O/NTHR=0 CCDImageToConvert_dis =  log(waveToDisplay)
			else
				MatrixOp/O/NTHR=0 CCDImageToConvert_dis = waveToDisplay
			endif
		
		//fix the sliders
		NVAR ImageRangeMinLimit = root:Packages:Convert2Dto1D:ImageRangeMinLimit
		NVAR ImageRangeMaxLimit = root:Packages:Convert2Dto1D:ImageRangeMaxLimit
		wavestats/Q CCDImageToConvert_dis
		ImageRangeMinLimit = V_min
		ImageRangeMaxLimit = V_max
		if(V_min<1)
			ImageRangeMinLimit =0
		endif
		Slider ImageRangeMin,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}, win=NI1A_Convert2Dto1DPanel
		Slider ImageRangeMax,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}, win=NI1A_Convert2Dto1DPanel

		
		NI1A_TopCCDImageUpdateColors(1)

	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_DisplayOneDataSet()
	
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	//Kill top graph with Imge if it exists..
	DoWIndow CCDImageToConvertFig
	if(V_Flag)
		DoWIndow/K CCDImageToConvertFig
	endif
	//now kill the Calibrated wave, since this process will not create one
	Wave/Z Calibrated2DDataSet = root:Packages:Convert2Dto1D:Calibrated2DDataSet
	if(WaveExists(Calibrated2DDataSet))
		KillWaves /Z Calibrated2DDataSet
	endif
	//end set the parameters for display...
	NVAR DisplayProcessed2DData=root:Packages:Convert2Dto1D:DisplayProcessed2DData
	NVAR DisplayRaw2DData=root:Packages:Convert2Dto1D:DisplayRaw2DData
	DisplayProcessed2DData=0
	DisplayRaw2DData=1
	//and disable the controls...
	CheckBox DisplayProcessed2DData,win=NI1A_Convert2Dto1DPanel, disable=2
	
	Wave ListOf2DSampleDataNumbers=root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers
	if(sum(ListOf2DSampleDataNumbers)<1)
		abort 
	endif	
	Wave/T ListOf2DSampleData=root:Packages:Convert2Dto1D:ListOf2DSampleData
	string SelectedFileToLoad
	variable i, imax = numpnts(ListOf2DSampleDataNumbers), numLoadedImages=0
	string DataWaveName="CCDImageToConvert"
	string Oldnote=""
	string TempNote=""
	variable loadedOK
	Wave/Z tempWave=root:Packages:Convert2Dto1D:CCDImageToConvertTemp
	if(WaveExists(tempWave))
		KillWaves tempWave
	endif
	For(i=0;i<imax;i+=1)
		if (ListOf2DSampleDataNumbers[i])
			SelectedFileToLoad=ListOf2DSampleData[i]		//this is the file selected to be processed
			loadedOK = NI1A_ImportThisOneFile(SelectedFileToLoad)
			if(!loadedOK)
				return 0
			endif
			NI1A_DezingerDataSetIfAskedFor(DataWaveName)
			Wave/Z tempWave=root:Packages:Convert2Dto1D:CCDImageToConvertTemp
			Wave CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
			if(!WaveExists(tempWave))
				OldNote+=note(CCDImageToConvert)
				Duplicate/O CCDImageToConvert, root:Packages:Convert2Dto1D:CCDImageToConvertTemp
				numLoadedImages+=1
				TempNote=note(CCDImageToConvert)
				OldNote+="DataFileName"+num2str(numLoadedImages)+"="+StringByKey("DataFileName", TempNote , "=", ";")+";"
			else
				TempNote=note(CCDImageToConvert)
				MatrixOp/O/NTHR=0  tempWave=CCDImageToConvert+tempWave
				numLoadedImages+=1
				OldNote+="DataFileName"+num2str(numLoadedImages)+"="+StringByKey("DataFileName", TempNote , "=", ";")+";"
			endif
		endif
	endfor
	OldNote+="NumberOfAveragedFiles="+num2str(numLoadedImages)+";"
	Wave tempWave=root:Packages:Convert2Dto1D:CCDImageToConvertTemp
	redimension/D tempWave
	MatrixOp/O/NTHR=0   CCDImageToConvert=tempWave/numLoadedImages
	KillWaves/Z tempWave
	note/K CCDImageToConvert
	note CCDImageToConvert, OldNote
		NI1A_DisplayLoadedFile()
		NI1A_DisplayStatsLoadedFile("CCDImageToConvert")
		NI1A_TopCCDImageUpdateColors(1)
		NI1A_DoDrawingsInto2DGraph()
		NI1A_CallImageHookFunction()
		DoWIndow Sample_Information
		if(V_FLag)
			AutopositionWindow/M=0/R=CCDImageToConvertFig Sample_Information
		endif
	setDataFolder OldDf	
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_DisplayStatsLoadedFile(WaveNameStr)
	string WaveNameStr

	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D

	wave basewv=$(WaveNameStr)
	wavestats/Q basewv
	print "Maximum intensity = " +num2str(V_max)
	print "Minimum intensity = " +num2str(V_min)
	TextBox/C/N=Stats/S=1/F=0/B=1/A=RB "\\K(65280,16384,16384)\\Z10MaxInt="+num2str(V_max)
	setDataFolder OldDf	
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_DisplayLoadedFile()

	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D

	DoWindow CCDImageToConvertFig
	if(V_Flag)
		DoWindow/K CCDImageToConvertFig	
	endif

	wave basewv=root:Packages:Convert2Dto1D:CCDImageToConvert
	wave/Z waveToDisplayDis = $("root:Packages:Convert2Dto1D:CCDImageToConvert_dis")
//	if (!WaveExists(waveToDisplayDis))
//		MatrixOP/O CCDImageToConvert_dis, baseWv
//		wave waveToDisplayDis = $("root:Packages:Convert2Dto1D:CCDImageToConvert_dis")
//	endif
	NI1A_DisplayTheRight2DWave()
	note/K waveToDisplayDis
	note waveToDisplayDis, note(basewv)
	NVAR InvertImages=root:Packages:Convert2Dto1D:InvertImages
	if(InvertImages)
		NewImage/F/K=1 waveToDisplayDis
	else	
		NewImage/K=1 waveToDisplayDis
	endif
	ShowInfo
	DoWindow/C CCDImageToConvertFig
	AutoPositionWindow/E/M=0/R=NI1A_Convert2Dto1DPanel CCDImageToConvertFig
	//append naem of the file loaded in...
	string LegendImg=""
	variable NumImages=NumberByKey("NumberOfAveragedFiles", note(waveToDisplayDis) , "=", ";")
	variable i
	if(NumImages>1)
		For(i=1;i<=NumImages;i+=1)
			LegendImg+=StringByKey("DataFileName"+num2str(i), note(waveToDisplayDis) , "=", ";")
			if(i < NumImages)
				 LegendImg+="\r"
			endif 
		endfor
	else
			LegendImg+=StringByKey("DataFileName", note(waveToDisplayDis) , "=", ";")
	endif
	TextBox/C/N=text0/S=1/B=2/A=LT "\\K(65280,16384,16384)\\Z14"+LegendImg
	
	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_DezingerDataSetIfAskedFor(whichFile)
	string whichFile
	
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR DezingerHowManyTimes=root:Packages:Convert2Dto1D:DezingerHowManyTimes
	NVAR DezingerCCDData =root:Packages:Convert2Dto1D:DezingerCCDData
	NVAR DezingerEmpty =root:Packages:Convert2Dto1D:DezingerEmpty
	NVAR DezingerDarkField =root:Packages:Convert2Dto1D:DezingerDarkField
	
	wave w = $("root:Packages:Convert2Dto1D:"+whichFile)
	variable i
	if (cmpstr(whichFile,"CCDImageToConvert")==0 && DezingerCCDData)
		For(i=0;i<DezingerHowManyTimes;i+=1)
			NI1A_DezingerImage(w)
		endfor
	endif
	if (cmpstr(whichFile,"EmptyData")==0 && DezingerEmpty)
		For(i=0;i<DezingerHowManyTimes;i+=1)
			NI1A_DezingerImage(w)
		endfor
	endif
	if (cmpstr(whichFile,"DarkFieldData")==0 && DezingerDarkField)
		For(i=0;i<DezingerHowManyTimes;i+=1)
			NI1A_DezingerImage(w)
		endfor
	endif
	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

//Function NI1A_UpdateMainSliders()
//
//	string oldDf=GetDataFolder(1)
//	setDataFolder root:Packages:Convert2Dto1D
//	NVAR ImageRangeMin=root:Packages:Convert2Dto1D:ImageRangeMin
//	NVAR ImageRangeMax=root:Packages:Convert2Dto1D:ImageRangeMax
//	NVAR ImageRangeMinLimit=root:Packages:Convert2Dto1D:ImageRangeMinLimit
//	NVAR ImageRangeMaxLimit=root:Packages:Convert2Dto1D:ImageRangeMaxLimit
//	
//	wave CCDImageToConvert_dis=root:Packages:Convert2Dto1D:CCDImageToConvert_dis
//	wavestats/Q CCDImageToConvert_dis
//	ImageRangeMin = V_min
//	ImageRangeMax = V_max
//	ImageRangeMinLimit = V_min
//	ImageRangeMaxLimit = V_max
//
//	Slider ImageRangeMin,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}, win=NI1A_Convert2Dto1DPanel
//	Slider ImageRangeMax,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}, win=NI1A_Convert2Dto1DPanel
//	NI1A_TopCCDImageUpdateColors(1)
//
//	setDataFolder OldDf
//end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_LoadManyDataSetsForConv()
	
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	//setup controls and display settings...
	//Kill window
	DoWIndow CCDImageToConvertFig
	if(V_Flag)
		DoWIndow/K CCDImageToConvertFig
	endif
	//now kill the Calibrated wave, since this process will create one
	Wave/Z Calibrated2DDataSet = root:Packages:Convert2Dto1D:Calibrated2DDataSet
	if(WaveExists(Calibrated2DDataSet))
		KillWaves /Z Calibrated2DDataSet
	endif
	//end set the parameters for display...
	NVAR DisplayProcessed2DData=root:Packages:Convert2Dto1D:DisplayProcessed2DData
	NVAR DisplayRaw2DData=root:Packages:Convert2Dto1D:DisplayRaw2DData
	if(DisplayProcessed2DData+DisplayRaw2DData!=1)
		DisplayProcessed2DData=0
		DisplayRaw2DData=1
	endif
	//and enable the controls...
	CheckBox DisplayProcessed2DData,win=NI1A_Convert2Dto1DPanel, disable=0
	
	
	Wave ListOf2DSampleDataNumbers=root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers
	Wave/T ListOf2DSampleData=root:Packages:Convert2Dto1D:ListOf2DSampleData
	string SelectedFileToLoad
	variable i, imax = numpnts(ListOf2DSampleDataNumbers)
	string DataWaveName="CCDImageToConvert"
	string DataWaveNameDis="CCDImageToConvert_dis"	//name of copy (lin or log int) for display
	NVAR SampleThickness=root:Packages:Convert2Dto1D:SampleThickness
	NVAR SampleTransmission=root:Packages:Convert2Dto1D:SampleTransmission
	NVAR CorrectionFactor=root:Packages:Convert2Dto1D:CorrectionFactor
	NVAR SampleMeasurementTime=root:Packages:Convert2Dto1D:SampleMeasurementTime
	NVAR SampleI0=root:Packages:Convert2Dto1D:SampleI0
	string extension
	variable LoadedOK
	Controlinfo/W=NI1A_Convert2Dto1DPanel   Select2Ddatatype
	extension=S_value
	variable u,j
	For(i=0;i<imax;i+=1)
		if (ListOf2DSampleDataNumbers[i])
			NVAR average=$("root:Packages:NI1_BSLFiles:BSLaverage")
			NVAR sumframes=$("root:Packages:NI1_BSLFiles:BSLsumframes")
			NVAR sumseq=$("root:Packages:NI1_BSLFiles:BSLsumseq")
			NVAR saxsframe=$("root:Packages:NI1_BSLFiles:BSLframes")
			NVAR currentframe=$("root:Packages:NI1_BSLFiles:BSLcurrentframe")
			NVAR BSLfromframe = $("root:Packages:NI1_BSLFiles:BSLfromframe")
			NVAR BSLtoframe = $("root:Packages:NI1_BSLFiles:BSLtoframe")
			wave BSLframelistsequence=$("root:Packages:NI1_BSLFiles:BSLframelistsequence")
			if(cmpstr(extension,"BSL/SAXS")==0&&sumframes==0&&average==0&&sumseq==0)
				for(u=currentframe;u<saxsframe+1;u+=1)
					currentframe=u
					SelectedFileToLoad=ListOf2DSampleData[i]		//this is the file selected to be processed
					loadedOK = NI1A_ImportThisOneFile(SelectedFileToLoad)
					if(!loadedOK)
						return 0
					endif
					NI1A_LoadParamsUsingFncts(SelectedFileToLoad)	
					string Oldnote=""
					Wave/Z CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
					Oldnote=note(CCDImageToConvert)
					OldNote+=NI1A_CalibrationNote()
					note/K CCDImageToConvert
					note CCDImageToConvert, OldNote
					NI1A_DezingerDataSetIfAskedFor(DataWaveName)
					NI1A_Convert2DTo1D()
					NI1A_DisplayLoadedFile()
					NI1A_TopCCDImageUpdateColors(1)
					NI1A_DoDrawingsInto2DGraph()
					NI1A_CallImageHookFunction()
					NI1A_Export2DData()
					DoUpdate
				endfor
				currentframe=1
			//josh: Time Resolved Summation
			elseif(cmpstr(extension,"BSL/SAXS")==0&&sumframes==0&&average==0&&sumseq==1)	
				variable sumsaxsframe
				sumsaxsframe=1
					NI1_BSLgettimesequence()
					newpanel/n=Entersequence_then_kill/k=1/w=(10,10,600,600)
					edit/k=1/Host=Entersequence_then_kill/n=killme/w=(-11,20,599,599) BSLframelistsequence.ld
					//modifytable/w=Entersequence_then_kill#killme title(BSLframelistsequence)="Enter Frames to Sum",  title(Point)="Frame",autosize={0,0, -1,0,0}
					pauseforuser Entersequence_then_kill, Entersequence_then_kill
					for(u=currentframe;u<saxsframe+1;u+=sumsaxsframe)
						currentframe=u
						BSLfromframe=currentframe
						sumsaxsframe=BSLframelistsequence[u-1][2]
						BSLtoframe=min(saxsframe,currentframe+sumsaxsframe-1)
						SelectedFileToLoad=ListOf2DSampleData[i]		//this is the file selected to be processed
						loadedOK = NI1A_ImportThisOneFile(SelectedFileToLoad)
						if(!loadedOK)
							return 0
						endif
						NI1A_LoadParamsUsingFncts(SelectedFileToLoad)	
						Oldnote=""
						Wave/Z CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
						Oldnote=note(CCDImageToConvert)
						OldNote+=NI1A_CalibrationNote()
						note/K CCDImageToConvert
						note CCDImageToConvert, OldNote
						NI1A_DezingerDataSetIfAskedFor(DataWaveName)
						//	NI1A_PrepareLogDataIfWanted(DataWaveName)		//creates the DataWaveNameDis wave...
						NI1A_Convert2DTo1D()
						NI1A_DisplayLoadedFile()
						NI1A_TopCCDImageUpdateColors(1)
						NI1A_DoDrawingsInto2DGraph()
						NI1A_CallImageHookFunction()
						NI1A_Export2DData()
						DoUpdate
					endfor
				duplicate/o BSLframelistsequence, $("root:SAS:BSLframelistsequence")
				currentframe=1
			else
			SelectedFileToLoad=ListOf2DSampleData[i]		//this is the file selected to be processed
			NI1A_ImportThisOneFile(SelectedFileToLoad)	
			NI1A_LoadParamsUsingFncts(SelectedFileToLoad)	
//					string Oldnote=""
					Wave/Z CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
					Oldnote=note(CCDImageToConvert)
					OldNote+=NI1A_CalibrationNote()
					note/K CCDImageToConvert
					note CCDImageToConvert, OldNote
			NI1A_DezingerDataSetIfAskedFor(DataWaveName)
			NI1A_Convert2DTo1D()
			NI1A_DisplayLoadedFile()
			NI1A_DisplayTheRight2DWave()
			NI1A_DoDrawingsInto2DGraph()
			NI1A_CallImageHookFunction()
			NI1A_Export2DData()
			DoUpdate
		endif
		endif
	endfor
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_CallImageHookFunction()
	if(exists("AfterDisplayImageHook")==6)
		Execute("AfterDisplayImageHook()")
	endif

end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_AveLoadNDataSetsForConv()
	
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	//setup controls and display settings...
	//Kill window
	DoWIndow CCDImageToConvertFig
	if(V_Flag)
		DoWIndow/K CCDImageToConvertFig
	endif
	//now kill the Calibrated wave, since this process will create one
	Wave/Z Calibrated2DDataSet = root:Packages:Convert2Dto1D:Calibrated2DDataSet
	if(WaveExists(Calibrated2DDataSet))
		KillWaves /Z Calibrated2DDataSet
	endif
	//end set the parameters for display...
	NVAR DisplayProcessed2DData=root:Packages:Convert2Dto1D:DisplayProcessed2DData
	NVAR DisplayRaw2DData=root:Packages:Convert2Dto1D:DisplayRaw2DData
	if(DisplayProcessed2DData+DisplayRaw2DData!=1)
		DisplayProcessed2DData=0
		DisplayRaw2DData=1
	endif
	//and enable the controls...
	CheckBox DisplayProcessed2DData,win=NI1A_Convert2Dto1DPanel, disable=0


	Wave ListOf2DSampleDataNumbers=root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers
	Wave/T ListOf2DSampleData=root:Packages:Convert2Dto1D:ListOf2DSampleData
	string SelectedFileToLoad
	variable i, imax = numpnts(ListOf2DSampleDataNumbers)
	variable numLoadedImages=0
	NVAR ProcessNImagesAtTime=root:Packages:Convert2Dto1D:ProcessNImagesAtTime
	string Oldnote=""
	string TempNote=""
	string DataWaveName="CCDImageToConvert"
	string DataWaveNameDis="CCDImageToConvert_dis"	//name of copy (lin or log int) for display
	Wave/Z CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
	if(WaveExists(CCDImageToConvert))
		DoWindow CCDImageToConvertFig
		if(V_Flag)
			DoWindow/K CCDImageToConvertFig
		endif
		KillWaves CCDImageToConvert
	endif
		NVAR SampleThickness=root:Packages:Convert2Dto1D:SampleThickness
		NVAR SampleTransmission=root:Packages:Convert2Dto1D:SampleTransmission
		NVAR CorrectionFactor=root:Packages:Convert2Dto1D:CorrectionFactor
		NVAR SampleMeasurementTime=root:Packages:Convert2Dto1D:SampleMeasurementTime
		NVAR SampleI0=root:Packages:Convert2Dto1D:SampleI0
	variable LocSampleThickness=0
	variable LocSampleTransmission=0
	variable LocCorrectionFactor=0
	variable LocSampleMeasurementTime=0
	variable LocSampleI0=0
	variable j=0, Loaded=0, LoadedOK
	NVAR SkipBadFiles=root:Packages:Convert2Dto1D:SkipBadFiles
	NVAR MaxIntForBadFile=root:Packages:Convert2Dto1D:MaxIntForBadFile
	//need to averaged 5 parameters above...
	For(i=0;i<imax;i+=1)
		Loaded=0
		Oldnote=""
		numLoadedImages=0
		 LocSampleThickness=0
		 LocSampleTransmission=0
		 LocCorrectionFactor=0
		 LocSampleMeasurementTime=0
		 LocSampleI0=0
		 if(ListOf2DSampleDataNumbers[i])
			For(j=0;j<ProcessNImagesAtTime;j+=1)
				if (ListOf2DSampleDataNumbers[i+j])
					SelectedFileToLoad=ListOf2DSampleData[i+j]		//this is the file selected to be processed
					loadedOK = NI1A_ImportThisOneFile(SelectedFileToLoad)
					if(!loadedOK)
						return 0
					endif
					if(SkipBadFiles)
						Wave CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
						wavestats/Q CCDImageToConvert
					endif
					if(!SkipBadFiles || (SkipBadFiles && MaxIntForBadFile<=V_max))
						NI1A_LoadParamsUsingFncts(SelectedFileToLoad)	//thsi will call user functions which get sample parameters, if exist
							 LocSampleThickness+=SampleThickness
							 LocSampleTransmission+=SampleTransmission
							 LocCorrectionFactor+=CorrectionFactor
							 LocSampleMeasurementTime+=SampleMeasurementTime
							 LocSampleI0+=SampleI0
						NI1A_DezingerDataSetIfAskedFor(DataWaveName)
						Wave/Z tempWave=root:Packages:Convert2Dto1D:CCDImageToConvertTemp
						Wave CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
						if(!WaveExists(tempWave))
							OldNote+=note(CCDImageToConvert)
							Duplicate/O CCDImageToConvert, root:Packages:Convert2Dto1D:CCDImageToConvertTemp
							numLoadedImages+=1
							TempNote=note(CCDImageToConvert)
							OldNote+="DataFileName"+num2str(numLoadedImages)+"="+StringByKey("DataFileName", TempNote , "=", ";")+";"
						else
							TempNote=note(CCDImageToConvert)
							MatrixOp/O/NTHR=0 tempWave=CCDImageToConvert+tempWave
							numLoadedImages+=1
							OldNote+="DataFileName"+num2str(numLoadedImages)+"="+StringByKey("DataFileName", TempNote , "=", ";")+";"
						endif
						Loaded=1
					endif
				endif
			endfor
			i=i+j	-1
			if(Loaded)
				OldNote+="NumberOfAveragedFiles="+num2str(numLoadedImages)+";"
				Wave tempWave=root:Packages:Convert2Dto1D:CCDImageToConvertTemp
					SampleThickness= LocSampleThickness/numLoadedImages
					SampleTransmission= LocSampleTransmission/numLoadedImages
					CorrectionFactor= LocCorrectionFactor/numLoadedImages
					SampleMeasurementTime= LocSampleMeasurementTime/numLoadedImages
					SampleI0= LocSampleI0/numLoadedImages
				OldNote+=NI1A_CalibrationNote()
			
				MatrixOp/O/NTHR=0 CCDImageToConvert=tempWave/numLoadedImages
				KillWaves/Z tempWave
				note/K CCDImageToConvert
				note CCDImageToConvert, OldNote
				NI1A_Convert2DTo1D()
				NI1A_DisplayLoadedFile()
				NI1A_DisplayTheRight2DWave()
				NI1A_DoDrawingsInto2DGraph()
				NI1A_CallImageHookFunction()
				NI1A_Export2DData()
				DoUpdate
			endif
		endif
	endfor

	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_AveLoadManyDataSetsForConv()
	
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	//setup controls and display settings...
	//Kill window
	DoWIndow CCDImageToConvertFig
	if(V_Flag)
		DoWIndow/K CCDImageToConvertFig
	endif
	//now kill the Calibrated wave, since this process will create one
	Wave/Z Calibrated2DDataSet = root:Packages:Convert2Dto1D:Calibrated2DDataSet
	if(WaveExists(Calibrated2DDataSet))
		KillWaves /Z Calibrated2DDataSet
	endif
	//end set the parameters for display...
	NVAR DisplayProcessed2DData=root:Packages:Convert2Dto1D:DisplayProcessed2DData
	NVAR DisplayRaw2DData=root:Packages:Convert2Dto1D:DisplayRaw2DData
	if(DisplayProcessed2DData+DisplayRaw2DData!=1)
		DisplayProcessed2DData=0
		DisplayRaw2DData=1
	endif
	//and enable the controls...
	CheckBox DisplayProcessed2DData,win=NI1A_Convert2Dto1DPanel, disable=0


	Wave ListOf2DSampleDataNumbers=root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers
	Wave/T ListOf2DSampleData=root:Packages:Convert2Dto1D:ListOf2DSampleData
	string SelectedFileToLoad
	variable i, imax = numpnts(ListOf2DSampleDataNumbers)
	variable numLoadedImages=0
	string Oldnote=""
	string TempNote=""
	string DataWaveName="CCDImageToConvert"
	string DataWaveNameDis="CCDImageToConvert_dis"	//name of copy (lin or log int) for display
	Wave/Z CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
	if(WaveExists(CCDImageToConvert))
		DoWindow CCDImageToConvertFig
		if(V_Flag)
			DoWindow/K CCDImageToConvertFig
		endif
		KillWaves CCDImageToConvert
	endif
		NVAR SampleThickness=root:Packages:Convert2Dto1D:SampleThickness
		NVAR SampleTransmission=root:Packages:Convert2Dto1D:SampleTransmission
		NVAR CorrectionFactor=root:Packages:Convert2Dto1D:CorrectionFactor
		NVAR SampleMeasurementTime=root:Packages:Convert2Dto1D:SampleMeasurementTime
		NVAR SampleI0=root:Packages:Convert2Dto1D:SampleI0
	variable LocSampleThickness=0
	variable LocSampleTransmission=0
	variable LocCorrectionFactor=0
	variable LocSampleMeasurementTime=0
	variable LocSampleI0=0
	variable LoadedOK
	NVAR SkipBadFiles=root:Packages:Convert2Dto1D:SkipBadFiles
	NVAR MaxIntForBadFile=root:Packages:Convert2Dto1D:MaxIntForBadFile
	//need to averaged 5 parameters above...
	For(i=0;i<imax;i+=1)
		if (ListOf2DSampleDataNumbers[i])
			SelectedFileToLoad=ListOf2DSampleData[i]		//this is the file selected to be processed
			loadedOK = NI1A_ImportThisOneFile(SelectedFileToLoad)
			if(!loadedOK)
				return 0
			endif
			if(SkipBadFiles)
				Wave CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
				wavestats/Q CCDImageToConvert
			endif
				if(!SkipBadFiles || (SkipBadFiles && MaxIntForBadFile<=V_max))
				NI1A_LoadParamsUsingFncts(SelectedFileToLoad)	//thsi will call user functions which get sample parameters, if exist
					 LocSampleThickness+=SampleThickness
					 LocSampleTransmission+=SampleTransmission
					 LocCorrectionFactor+=CorrectionFactor
					 LocSampleMeasurementTime+=SampleMeasurementTime
					 LocSampleI0+=SampleI0
				NI1A_DezingerDataSetIfAskedFor(DataWaveName)
				Wave/Z tempWave=root:Packages:Convert2Dto1D:CCDImageToConvertTemp
				Wave CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
				if(!WaveExists(tempWave))
					OldNote+=note(CCDImageToConvert)
					Duplicate/O CCDImageToConvert, root:Packages:Convert2Dto1D:CCDImageToConvertTemp
					numLoadedImages+=1
					TempNote=note(CCDImageToConvert)
					OldNote+="DataFileName"+num2str(numLoadedImages)+"="+StringByKey("DataFileName", TempNote , "=", ";")+";"
				else
					TempNote=note(CCDImageToConvert)
					MatrixOp/O/NTHR=0 tempWave=CCDImageToConvert+tempWave
					numLoadedImages+=1
					OldNote+="DataFileName"+num2str(numLoadedImages)+"="+StringByKey("DataFileName", TempNote , "=", ";")+";"
				endif
			endif
		endif
	endfor
	OldNote+="NumberOfAveragedFiles="+num2str(numLoadedImages)+";"
	Wave tempWave=root:Packages:Convert2Dto1D:CCDImageToConvertTemp
		SampleThickness= LocSampleThickness/numLoadedImages
		SampleTransmission= LocSampleTransmission/numLoadedImages
		CorrectionFactor= LocCorrectionFactor/numLoadedImages
		SampleMeasurementTime= LocSampleMeasurementTime/numLoadedImages
		SampleI0= LocSampleI0/numLoadedImages
	OldNote+=NI1A_CalibrationNote()

	MatrixOp/O/NTHR=0 CCDImageToConvert=tempWave/numLoadedImages
	KillWaves/Z tempWave
	note/K CCDImageToConvert
	note CCDImageToConvert, OldNote
	NI1A_Convert2DTo1D()
	NI1A_DisplayLoadedFile()
	NI1A_DisplayTheRight2DWave()
	NI1A_DoDrawingsInto2DGraph()
	NI1A_CallImageHookFunction()
	NI1A_Export2DData()
	DoUpdate
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function/S NI1A_CalibrationNote()

	string newNote=""
		SVAR DataCalibrationString=root:Packages:Convert2Dto1D:DataCalibrationString
		newNote+="Units="+DataCalibrationString+";"

		NVAR UseSampleThickness=root:Packages:Convert2Dto1D:UseSampleThickness
		NVAR UseSampleThicknFnct=root:Packages:Convert2Dto1D:UseSampleThicknFnct
		SVAR SampleThicknFnct=root:Packages:Convert2Dto1D:SampleThicknFnct
		NVAR SampleThickness=root:Packages:Convert2Dto1D:SampleThickness
		if(UseSampleThickness && UseSampleThicknFnct)
			newNote+="SampleThicknFnct="+SampleThicknFnct+";"
		endif
		newNote+="SampleThickness="+num2str(SampleThickness)+";"

		NVAR UseSampleTransmission=root:Packages:Convert2Dto1D:UseSampleTransmission
		NVAR UseSampleTransmFnct=root:Packages:Convert2Dto1D:UseSampleTransmFnct
		SVAR SampleTransmFnct=root:Packages:Convert2Dto1D:SampleTransmFnct
		NVAR SampleTransmission=root:Packages:Convert2Dto1D:SampleTransmission
		if(UseSampleTransmission && UseSampleThicknFnct)
			newNote+="SampleTransmFnct="+SampleTransmFnct+";"
		endif
		newNote+="SampleTransmission="+num2str(SampleTransmission)+";"
		
		NVAR UseCorrectionFactor=root:Packages:Convert2Dto1D:UseCorrectionFactor
		NVAR CorrectionFactor=root:Packages:Convert2Dto1D:CorrectionFactor
		NVAR UseSampleCorrectFnct=root:Packages:Convert2Dto1D:UseSampleCorrectFnct
		SVAR SampleCorrectFnct=root:Packages:Convert2Dto1D:SampleCorrectFnct
		if(UseCorrectionFactor && UseSampleCorrectFnct)
			newNote+="SampleCorrectFnct="+SampleCorrectFnct+";"
		endif
		newNote+="CorrectionFactor="+num2str(CorrectionFactor)+";"
		
		NVAR UseSampleMeasTime=root:Packages:Convert2Dto1D:UseSampleMeasTime
		NVAR UseSampleMeasTimeFnct=root:Packages:Convert2Dto1D:UseSampleMeasTimeFnct
		SVAR SampleMeasTimeFnct=root:Packages:Convert2Dto1D:SampleMeasTimeFnct
		NVAR SampleMeasurementTime=root:Packages:Convert2Dto1D:SampleMeasurementTime
		if(UseSampleMeasTime && UseSampleMeasTimeFnct)
			newNote+="SampleMeasTimeFnct="+SampleMeasTimeFnct+";"
		endif
		newNote+="SampleMeasurementTime="+num2str(SampleMeasurementTime)+";"

		NVAR UseEmptyMeasTime=root:Packages:Convert2Dto1D:UseEmptyMeasTime
		NVAR UseEmptyTimeFnct=root:Packages:Convert2Dto1D:UseEmptyTimeFnct
		SVAR EmptyTimeFnct=root:Packages:Convert2Dto1D:EmptyTimeFnct
		NVAR EmptyMeasurementTime=root:Packages:Convert2Dto1D:EmptyMeasurementTime
		if(UseEmptyMeasTime && UseEmptyTimeFnct)
			newNote+="EmptyTimeFnct="+EmptyTimeFnct+";"
		endif
		newNote+="EmptyMeasurementTime="+num2str(EmptyMeasurementTime)+";"
		
		NVAR UseDarkMeasTime=root:Packages:Convert2Dto1D:UseDarkMeasTime
		NVAR UseBackgTimeFnct=root:Packages:Convert2Dto1D:UseBackgTimeFnct
		SVAR BackgTimeFnct=root:Packages:Convert2Dto1D:BackgTimeFnct
		NVAR BackgroundMeasTime=root:Packages:Convert2Dto1D:BackgroundMeasTime
		if(UseDarkMeasTime && UseBackgTimeFnct)
			newNote+="BackgTimeFnct="+BackgTimeFnct+";"
		endif
		newNote+="BackgroundMeasTime="+num2str(BackgroundMeasTime)+";"

		NVAR UseI0ToCalibrate=root:Packages:Convert2Dto1D:UseI0ToCalibrate
		NVAR UseSampleMonitorFnct=root:Packages:Convert2Dto1D:UseSampleMonitorFnct
		SVAR SampleMonitorFnct=root:Packages:Convert2Dto1D:SampleMonitorFnct
		NVAR SampleI0=root:Packages:Convert2Dto1D:SampleI0
		if(UseI0ToCalibrate && UseSampleMonitorFnct)
			newNote+="SampleMonitorFnct="+SampleMonitorFnct+";"
		endif
		newNote+="SampleI0="+num2str(SampleI0)+";"
			
		NVAR UseMonitorForEF=root:Packages:Convert2Dto1D:UseMonitorForEF
		NVAR UseEmptyMonitorFnct=root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
		SVAR EmptyMonitorFnct=root:Packages:Convert2Dto1D:EmptyMonitorFnct
		NVAR EmptyI0=root:Packages:Convert2Dto1D:EmptyI0
		if(UseMonitorForEF && UseEmptyMonitorFnct)
			newNote+="EmptyMonitorFnct="+EmptyMonitorFnct+";"
		endif
		newNote+="EmptyI0="+num2str(EmptyI0)+";"

	return newnote
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_LoadParamsUsingFncts(SelectedFileToLoad)
	string SelectedFileToLoad
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

		variable/g temp
		
		NVAR UseSampleThickness=root:Packages:Convert2Dto1D:UseSampleThickness
		NVAR UseSampleThicknFnct=root:Packages:Convert2Dto1D:UseSampleThicknFnct
		SVAR SampleThicknFnct=root:Packages:Convert2Dto1D:SampleThicknFnct
		NVAR SampleThickness=root:Packages:Convert2Dto1D:SampleThickness
		if(UseSampleThickness && UseSampleThicknFnct)
			Execute("root:Packages:Convert2Dto1D:temp = "+SampleThicknFnct+"(\""+SelectedFileToLoad+"\")")
			if(numtype(temp)!=0 || temp<=0)
				Abort "Thickness function returned NaN or thickness <=0"
			endif
			SampleThickness=temp
		endif
		
		NVAR UseSampleTransmission=root:Packages:Convert2Dto1D:UseSampleTransmission
		NVAR UseSampleTransmFnct=root:Packages:Convert2Dto1D:UseSampleTransmFnct
		SVAR SampleTransmFnct=root:Packages:Convert2Dto1D:SampleTransmFnct
		NVAR SampleTransmission=root:Packages:Convert2Dto1D:SampleTransmission
		if(UseSampleTransmission && UseSampleTransmFnct)
			Execute("root:Packages:Convert2Dto1D:temp ="+SampleTransmFnct+"(\""+SelectedFileToLoad+"\")")
			if(numtype(temp)!=0 || temp<=0)// || temp >1.5)
				Abort "Transmission function returned NaN or value <=0 or >1.5"
			endif
			SampleTransmission=temp
		endif
		
		NVAR UseCorrectionFactor=root:Packages:Convert2Dto1D:UseCorrectionFactor
		NVAR CorrectionFactor=root:Packages:Convert2Dto1D:CorrectionFactor
		NVAR UseSampleCorrectFnct=root:Packages:Convert2Dto1D:UseSampleCorrectFnct
		SVAR SampleCorrectFnct=root:Packages:Convert2Dto1D:SampleCorrectFnct
		if(UseCorrectionFactor && UseSampleCorrectFnct)
			Execute("root:Packages:Convert2Dto1D:temp ="+SampleCorrectFnct+"(\""+SelectedFileToLoad+"\")")
			if(numtype(temp)!=0 || temp<=0)
				Abort "Correction factor function returned NaN or value <=0"
			endif
			CorrectionFactor=temp
		endif
		
		NVAR UseSampleMeasTime=root:Packages:Convert2Dto1D:UseSampleMeasTime
		NVAR UseSampleMeasTimeFnct=root:Packages:Convert2Dto1D:UseSampleMeasTimeFnct
		SVAR SampleMeasTimeFnct=root:Packages:Convert2Dto1D:SampleMeasTimeFnct
		NVAR SampleMeasurementTime=root:Packages:Convert2Dto1D:SampleMeasurementTime
		if(UseSampleMeasTime && UseSampleMeasTimeFnct)
			Execute("root:Packages:Convert2Dto1D:temp ="+SampleMeasTimeFnct+"(\""+SelectedFileToLoad+"\")")
			if(numtype(temp)!=0 || temp<=0)
				Abort "Sample measurement time factor function returned NaN or value <=0"
			endif
			SampleMeasurementTime=temp
		endif

		NVAR UseEmptyMeasTime=root:Packages:Convert2Dto1D:UseEmptyMeasTime
		NVAR UseEmptyTimeFnct=root:Packages:Convert2Dto1D:UseEmptyTimeFnct
		SVAR EmptyTimeFnct=root:Packages:Convert2Dto1D:EmptyTimeFnct
		NVAR EmptyMeasurementTime=root:Packages:Convert2Dto1D:EmptyMeasurementTime
		if(UseEmptyMeasTime && UseEmptyTimeFnct)
			Execute("root:Packages:Convert2Dto1D:temp ="+EmptyTimeFnct+"(\""+SelectedFileToLoad+"\")")
			if(numtype(temp)!=0 || temp<=0)
				Abort "Empty beam measurement time factor function returned NaN or value <=0"
			endif
			EmptyMeasurementTime=temp
		endif
		
		NVAR UseDarkMeasTime=root:Packages:Convert2Dto1D:UseDarkMeasTime
		NVAR UseBackgTimeFnct=root:Packages:Convert2Dto1D:UseBackgTimeFnct
		SVAR BackgTimeFnct=root:Packages:Convert2Dto1D:BackgTimeFnct
		NVAR BackgroundMeasTime=root:Packages:Convert2Dto1D:BackgroundMeasTime
		if(UseDarkMeasTime && UseBackgTimeFnct)
			Execute("root:Packages:Convert2Dto1D:temp ="+BackgTimeFnct+"(\""+SelectedFileToLoad+"\")")
			if(numtype(temp)!=0 || temp<=0)
				Abort "Dark field measurement time factor function returned NaN or value <=0"
			endif
			BackgroundMeasTime=temp
		endif

		NVAR UseI0ToCalibrate=root:Packages:Convert2Dto1D:UseI0ToCalibrate
		NVAR UseSampleMonitorFnct=root:Packages:Convert2Dto1D:UseSampleMonitorFnct
		SVAR SampleMonitorFnct=root:Packages:Convert2Dto1D:SampleMonitorFnct
		NVAR SampleI0=root:Packages:Convert2Dto1D:SampleI0
		if(UseI0ToCalibrate && UseSampleMonitorFnct)
			Execute("root:Packages:Convert2Dto1D:temp ="+SampleMonitorFnct+"(\""+SelectedFileToLoad+"\")")
			if(numtype(temp)!=0 || temp<=0)
				Abort "Sample monitor count function returned NaN or value <=0"
			endif
			SampleI0=temp
		endif
			
		NVAR UseMonitorForEF=root:Packages:Convert2Dto1D:UseMonitorForEF
		NVAR UseEmptyMonitorFnct=root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
		SVAR EmptyMonitorFnct=root:Packages:Convert2Dto1D:EmptyMonitorFnct
		NVAR EmptyI0=root:Packages:Convert2Dto1D:EmptyI0
		if(UseMonitorForEF && UseEmptyMonitorFnct)
			Execute("root:Packages:Convert2Dto1D:temp ="+EmptyMonitorFnct+"(\""+SelectedFileToLoad+"\")")
			if(numtype(temp)!=0 || temp<=0)
				Abort "Empty beam monitor count function returned NaN or value <=0"
			endif
			EmptyI0=temp
		endif
		
	
	setDataFolder OldDf

end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_ExportDisplayedImage()
	
	string OldDf=GetDataFolder(1)
	setDataFOlder root:Packages:Convert2Dto1D
	WAVE/Z ww=root:Packages:Convert2Dto1D:CCDImageToConvert_dis
	NVAR DisplayProcessed2DData=root:Packages:Convert2Dto1D:DisplayProcessed2DData
	if(WaveExists(ww)==0)
		Abort "Something is wrong here"
	endif
	SVAR FileNameToLoad=root:Packages:Convert2Dto1D:FileNameToLoad
	string  SaveFileName=FileNameToLoad[0,25]+"_mod.tif"
	Prompt SaveFileName, "Input file name for file to save"
	DoPrompt "Correct file name to use for saving this file", SaveFileName
	if(V_Flag)
		abort
	endif
	if (strlen(SaveFileName)==0)
		abort "No name specified"
	endif
		//print SaveFileName[strlen(SaveFileName)-4,inf]
	if(cmpstr(SaveFileName[strlen(SaveFileName)-4,inf],".tif")!=0)
		SaveFileName+=".tif"
	endif
	string ListOfFilesThere
	ListOfFilesThere=IndexedFile(Convert2Dto1DDataPath,-1,".tif")
	if(stringMatch(ListOfFilesThere,"*"+SaveFileName+"*"))
		DoAlert 1, "File with this name exists, overwrite?"
		if(V_Flag!=1)
			abort
		endif	
	endif
	Duplicate/O ww, wwtemp
	Redimension/S wwtemp
	//Redimension/W/U wwtemp		//this converts to unsigned 16 bit word... needed for export. It correctly rounds.... 
	if(!DisplayProcessed2DData)	//raw data, these are integers...	
		ImageSave/P=Convert2Dto1DDataPath/F/T="TIFF"/O wwtemp SaveFileName			//we save that as single precision float anyway...
	else			//processed, this is real data... 
		ImageSave/P=Convert2Dto1DDataPath/F/T="TIFF"/O wwtemp SaveFileName			// this is single precision float..  
	endif
	//ImageSave/D=16/T="TIFF"/O/P=Convert2Dto1DDataPath wwtemp SaveFileName
	KilLWaves wwtemp
	NI1A_UpdateDataListBox()
	SetDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_SaveDisplayedImage()
	
	string OldDf=GetDataFolder(1)
	setDataFOlder root:Packages:Convert2Dto1D
	WAVE/Z ww=root:Packages:Convert2Dto1D:CCDImageToConvert_dis
	NVAR DisplayProcessed2DData=root:Packages:Convert2Dto1D:DisplayProcessed2DData
	if(WaveExists(ww)==0)
		Abort "Image does not exist"
	endif
	SVAR FileNameToLoad=root:Packages:Convert2Dto1D:FileNameToLoad
	string  SaveFileName=FileNameToLoad[0,30]
	string precision="Unsigned Integer"		//default value, but for processed data we need to have at least single precision..
	Prompt precision, "Precision for wave to save", popup, "Unsigned Integer;Signed Integer;Single;Double;"
	if(DisplayProcessed2DData)
		precision="Single"
		Prompt precision, "Precision for wave to save", popup, "Single;Double;"
	endif
	string MakeImage="no"
	Prompt SaveFileName, "Input file name for file to save"
	Prompt MakeImage, "Make Image?", popup, "no;yes;"
	DoPrompt "Saving this image", SaveFileName, precision, MakeImage
	if(V_Flag)
		abort
	endif
	if (strlen(SaveFileName)==0)
		abort "No name specified"
	endif
		//print SaveFileName[strlen(SaveFileName)-4,inf]
	string ListOfFilesThere
	setDataFolder root:
	NewDataFolder/O/S SavedImages
	wave/Z testme=$(SaveFileName)
	if(WaveExists(testme))
		DoAlert 1, "Image of this name already exists, overwrite?"
		if(V_Flag==2)
			abort
		endif
	endif
	Duplicate/O ww, $(SaveFileName)
	Wave NewWv=$(SaveFileName)
	if(cmpstr(precision,"Unsigned Integer")==0)
		Redimension/U/W NewWv
	elseif(cmpstr(precision,"Signed Integer")==0)
		Redimension/W NewWv
	elseif(cmpstr(precision,"Single")==0)
		Redimension/S NewWv
	elseif(cmpstr(precision,"Double")==0)
		Redimension/D NewWv
	endif
	if(cmpstr(MakeImage,"yes")==0)
		NVAR InvertImages=root:Packages:Convert2Dto1D:InvertImages
		if(InvertImages)
			NewImage/F/K=1 NewWv
		else
			NewImage/K=1 NewWv
		endif
		string SavedImage=UniqueName("SavedImage", 6, 0)
		
		DoWindow/C/T $(SavedImage),SaveFileName
	endif
	SetDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_PrepareLogDataIfWanted(DataWaveName)
	string DataWaveName

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	wave waveToDisplay = $("root:Packages:Convert2Dto1D:"+DataWaveName)
	Duplicate/O waveToDisplay, $("root:Packages:Convert2Dto1D:"+DataWaveName+"_dis")
	wave waveToDisplayDis= $("root:Packages:Convert2Dto1D:"+DataWaveName+"_dis")
	Redimension/S waveToDisplayDis
	NVAR ImageDisplayLogScaled=root:Packages:Convert2Dto1D:ImageDisplayLogScaled
		if(ImageDisplayLogScaled)
			MatrixOp/O/NTHR=0 waveToDisplayDis = log(waveToDisplay)
		else
			MatrixOp/O/NTHR=0 waveToDisplayDis = waveToDisplay
		endif
	setDataFolder OldDF
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_LoadEmptyOrDark(EmptyOrDark)
	string EmptyOrDark
	//check the parameters for conversion
	
	string OldDf=getDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D
	SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension
	SVAR BlankFileExtension=root:Packages:Convert2Dto1D:BlankFileExtension
	string FileExtLocal
	
	//for now !!!!!!!!!!!!!!!!
	//BlankFileExtension = DataFileExtension
	FileExtLocal=BlankFileExtension		//fixed 9/8/2011
	
	Wave/T ListOf2DEmptyData=root:Packages:Convert2Dto1D:ListOf2DEmptyData
	string SelectedFileToLoad
	controlInfo /W=NI1A_Convert2Dto1DPanel Select2DMaskDarkWave
	variable selection = V_Value
	if(selection<0)
		setDataFolder OldDf
		abort
	endif
	DoWindow EMptyOrDarkImage
	if(V_Flag)
		DoWindow/K EMptyOrDarkImage
	endif
	SVAR CurrentEmptyName
	SVAR CurrentDarkFieldName
	SVAR CurrentPixSensFile
	string FileNameToLoad=ListOf2DEmptyData[selection]
	string NewWaveName
		if(numtype(strlen(FileNameToLoad))!=0)		//abort if user did nto select anything in the box
			abort
		endif
	if(cmpstr(EmptyOrDark,"Empty")==0)
		CurrentEmptyName = FileNameToLoad
		NewWaveName = "EmptyData"
	elseif(cmpstr(EmptyOrDark,"Pixel2DSensitivity")==0)
		CurrentPixSensFile = FileNameToLoad
		NewWaveName = "Pixel2DSensitivity"
		FileExtLocal="tiff"
	else
		CurrentDarkFieldName= FileNameToLoad
		NewWaveName = "DarkFieldData"
	endif

	NI1A_UniversalLoader("Convert2Dto1DEmptyDarkPath",FileNameToLoad,FileExtLocal,NewWaveName)

	NI1A_DezingerDataSetIfAskedFor(NewWaveName)

	wave NewCCDData = $(NewWaveName)

	//allow user function modification to the image through hook function...
#if Exists("ModifyImportedImageHook")
	ModifyImportedImageHook(NewCCDData)
#endif
//		String infostr = FunctionInfo("ModifyImportedImageHook")
//		if (strlen(infostr) >0)
//			Execute("ModifyImportedImageHook("+NewWaveName+")")
//		endif
	//end of allow user modification of imported image through hook function

	duplicate/O NewCCDData, $(NewWaveName+"_dis")
	wave NewCCDDataDis=$(NewWaveName+"_dis")
	redimension/S NewCCDDataDis
	NVAR ImageDisplayLogScaled=root:Packages:Convert2Dto1D:ImageDisplayLogScaled
	if(ImageDisplayLogScaled)
		MatrixOp/O/NTHR=0 NewCCDDataDis=log(NewCCDData)
	else
		MatrixOp/O/NTHR=0 NewCCDDataDis=NewCCDData
	endif
	NVAR InvertImages=root:Packages:Convert2Dto1D:InvertImages
	if(InvertImages)
		NewImage/F/K=1 NewCCDDataDis
	else	
		NewImage/K=1 NewCCDDataDis
	endif
	DoWindow/C EmptyOrDarkImage
	AutoPositionWindow/E/M=0/R=NI1A_Convert2Dto1DPanel EmptyOrDarkImage
	NI1A_TopCCDImageUpdateColors(1)
	NI1A_CallImageHookFunction()
	setDataFolder OldDf
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_DisplayOneDataSets()
	//check the parameters for conversion

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	
	Wave ListOf2DSampleDataNumbers=root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers
	Wave/T ListOf2DSampleData=root:Packages:Convert2Dto1D:ListOf2DSampleData
	string SelectedFileToLoad
	variable i, imax = numpnts(ListOf2DSampleDataNumbers)
	For(i=0;i<imax;i+=1)
		if (ListOf2DSampleDataNumbers[i])
			SelectedFileToLoad=ListOf2DSampleData[i]		//this is the file selected to be processed
			NI1A_ImportThisOneFile(SelectedFileToLoad)
			abort
		endif
	endfor
	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_LoadMask()

	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D
	Wave/T  ListOf2DMaskData=root:Packages:Convert2Dto1D:ListOf2DMaskData
	SVAR CurrentMaskFileName=root:Packages:Convert2Dto1D:CurrentMaskFileName

	controlInfo /W=NI1A_Convert2Dto1DPanel MaskListBoxSelection
	variable selection = V_Value
	if(selection<0)
		setDataFolder OldDf
		abort
	endif
	SVAR FileNameToLoad
	FileNameToLoad=ListOf2DMaskData[selection]
	if(stringmatch(FileNameToLoad[strlen(FileNameToLoad)-4,inf],".tif"))
		NI1A_UniversalLoader("Convert2Dto1DMaskPath",FileNameToLoad,"tiff","M_ROIMask")
	else
		NI1_MaskHDFLoader("Convert2Dto1DMaskPath",FileNameToLoad,".hdf","M_ROIMask")
		//NI1A_UniversalLoader
	endif

	CurrentMaskFileName = FileNameToLoad
	wave M_ROIMask
	Redimension/B/U M_ROIMask
	M_ROIMask=M_ROIMask>0.5 ? 1 : 0
	setDataFolder oldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_UpdateDataListBox()		

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
		Wave/T ListOf2DSampleData=root:Packages:Convert2Dto1D:ListOf2DSampleData
		Wave ListOf2DSampleDataNumbers=root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers
		SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension
		SVAR SampleNameMatchStr = root:Packages:Convert2Dto1D:SampleNameMatchStr
		string realExtension		//set to real extension for data types with weird extensions...
		
		if(cmpstr(DataFileExtension, ".tif")==0)
			realExtension=DataFileExtension
		elseif(cmpstr(DataFileExtension, "ADSC")==0 || cmpstr(DataFileExtension, "ADSC_A")==0)
			realExtension=".img"
		elseif(cmpstr(DataFileExtension, "DND/txt")==0)
			realExtension=".txt"
		elseif(cmpstr(DataFileExtension, ".hdf")==0)
			realExtension=".hdf"
		elseif(cmpstr(DataFileExtension, "TPA/XML")==0)
			realExtension=".xml"
		elseif(stringmatch(DataFileExtension, "*Nexus*"))
			realExtension=".hdf"
		elseif(cmpstr(DataFileExtension, "SSRLMatSAXS")==0)
			realExtension=".tif"
		else
			realExtension="????"
		endif
		string ListOfAvailableDataSets
		PathInfo Convert2Dto1DDataPath
		if(V_Flag)	//path exists...
			if(cmpstr(realExtension, ".hdf")==0)//there are many options for hdf...
				ListOfAvailableDataSets=IndexedFile(Convert2Dto1DDataPath,-1,".hdf")
				ListOfAvailableDataSets+=IndexedFile(Convert2Dto1DDataPath,-1,".h5")
				ListOfAvailableDataSets+=IndexedFile(Convert2Dto1DDataPath,-1,".hdf5")
			else
				ListOfAvailableDataSets=IndexedFile(Convert2Dto1DDataPath,-1,realExtension)
			endif	
			if(strlen(ListOfAvailableDataSets)<2)	//none found
				ListOfAvailableDataSets="--none--;"
			endif
			ListOfAvailableDataSets = GrepList(ListOfAvailableDataSets, "^((?!_mask.hdf).)*$" ) //remove _mask files... 
			ListOfAvailableDataSets = GrepList(ListOfAvailableDataSets, "^((?!.plist).)*$" ) //.plist files on Mac files... 
			ListOfAvailableDataSets = GrepList(ListOfAvailableDataSets, "^((?!.DS_Store).)*$" ) //.DS_Store files on Mac files... 
			ListOfAvailableDataSets = GrepList(ListOfAvailableDataSets, "^((?!^\._).)*$" ) //this should remove on PCs the files starting with ._ (OSX system files). 
			ListOfAvailableDataSets=NI1A_CleanListOfFilesForTypes(ListOfAvailableDataSets,DataFileExtension,SampleNameMatchStr)
			redimension/N=(ItemsInList(ListOfAvailableDataSets)) ListOf2DSampleData
			redimension/N=(ItemsInList(ListOfAvailableDataSets)) ListOf2DSampleDataNumbers
			NI1A_CreateListOfFiles(ListOf2DSampleData,ListOfAvailableDataSets,realExtension,"")
			ListOf2DSampleDataNumbers=0
			if(numpnts(ListOf2DSampleData)>1)
				NVAR FIlesSortOrder=root:Packages:Convert2Dto1D:FIlesSortOrder
				if(FIlesSortOrder==1)
					sort ListOf2DSampleData, ListOf2DSampleData, ListOf2DSampleDataNumbers
					ListOf2DSampleDataNumbers[numpnts(ListOf2DSampleDataNumbers)-1]=1
				elseif(FIlesSortOrder==2)
					sort/A ListOf2DSampleData, ListOf2DSampleData, ListOf2DSampleDataNumbers
					ListOf2DSampleDataNumbers[numpnts(ListOf2DSampleDataNumbers)-1]=1
				elseif(FIlesSortOrder==3)
					//extract the order number and use that to sort out..
					Make/O/N=(numpnts(ListOf2DSampleData)) tempSortWv
					tempSortWv = NI1A_FindeOrderNumber(ListOf2DSampleData[p]) 
					sort tempSortWv, tempSortWv, ListOf2DSampleData, ListOf2DSampleDataNumbers
					KillWaves/Z tempSortWv
					ListOf2DSampleDataNumbers[numpnts(ListOf2DSampleDataNumbers)-1]=1
				elseif(FIlesSortOrder==4)
					//extract the order number and use that to sort out.. Inverted
					Make/O/N=(numpnts(ListOf2DSampleData)) tempSortWv
					tempSortWv = NI1A_FindeOrderNumber(ListOf2DSampleData[p]) 
					sort/R tempSortWv, tempSortWv, ListOf2DSampleData, ListOf2DSampleDataNumbers
					KillWaves/Z tempSortWv
					ListOf2DSampleDataNumbers[0]=1
				elseif(FIlesSortOrder==5)
					sort/R ListOf2DSampleData, ListOf2DSampleData, ListOf2DSampleDataNumbers
					ListOf2DSampleDataNumbers[numpnts(ListOf2DSampleDataNumbers)-1]=1
				elseif(FIlesSortOrder==5)
					sort/R/A ListOf2DSampleData, ListOf2DSampleData, ListOf2DSampleDataNumbers
					ListOf2DSampleDataNumbers[numpnts(ListOf2DSampleDataNumbers)-1]=1
				else
				
				endif
			endif
			
			DoWindow NI1A_Convert2Dto1DPanel
			if(V_Flag)
				ListBox Select2DInputWave win=NI1A_Convert2Dto1DPanel,listWave=root:Packages:Convert2Dto1D:ListOf2DSampleData, row=0,selRow= 0
				ListBox Select2DInputWave win=NI1A_Convert2Dto1DPanel,selWave=root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers
				PopupMenu SelectStartOfRange,win=NI1A_Convert2Dto1DPanel,popvalue="---",value= #"NI1A_Create2DSelectionPopup()"
				PopupMenu SelectEndOfRange,win=NI1A_Convert2Dto1DPanel,popvalue="---",value= #"NI1A_Create2DSelectionPopup()"
			endif
		endif
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_FindeOrderNumber(stringWithName)	
	string stringWithName
	
	string FoundON
	FoundON = stringWithName[strsearch(stringWithName, "_", inf ,1)+1, strsearch(stringWithName, ".", inf ,1)-1]
	return str2num(FoundON)
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function/T NI1A_CleanListOfFilesForTypes(ListOfAvailableCompounds,DataFileType, MatchString)
	string ListOfAvailableCompounds,DataFileType, MatchString
	
	variable i, imax, numberOfFile
	if(strlen(ListOfAvailableCompounds)<2)
		return ""
	endif
	//match if needed...
	if(strlen(MatchString)>0)
		ListOfAvailableCompounds = GrepList(ListOfAvailableCompounds, MatchString)
	endif
	imax = itemsInList(ListOfAvailableCompounds)
	if (imax==0)
		return ""
	endif
	string result, tempFileName
	result=""
	if(cmpstr(DataFileType,"BrukerCCD")==0 || cmpstr(DataFileType,"BSL/SAXS")==0 || cmpstr(DataFileType,"BSL/WAXS")==0 || cmpstr(DataFileType,"Fuji/img")==0)
		For(i=0;i<imax;i+=1)
			tempFileName = stringFromList(i,ListOfAvailableCompounds)
				if(strlen(MatchString)==0 || stringmatch(tempFileName, MatchString ))
					if(cmpstr(DataFileType,"BrukerCCD")==0)				//this is one of unknown extensions
						result+= tempFileName +";"
					elseif(cmpstr(DataFileType,"BSL/SAXS")==0)		//display only BSL/OTOKO SAXS file, Xnn003.nnn, note Xnn000.nnn must exist too but not checked
						if(stringmatch(tempFileName, "*001.*" ))
							result+= tempFileName +";"
						endif
					elseif(cmpstr(DataFileType,"BSL/WAXS")==0)		//display only BSL/OTOKO SAXS file, Xnn003.nnn, note Xnn000.nnn must exist too but not checked
						if(stringmatch(tempFileName, "*003.*" ))
							result+= tempFileName +";"
						endif
					elseif(cmpstr(DataFileType,"Fuji/img")==0)		//display only *.img files (Fuji image plate)
						if(stringmatch(tempFileName, "*.img" ))
							result+= tempFileName +";"
						endif
					else
						result+= tempFileName +";"
					endif
				endif
		endfor
	else
		result = ListOfAvailableCompounds
	endif
	return result
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_CreateListOfFiles(ListOf2DSampleData,ListOfFiles,Extension, NameMatchString)
	wave/T ListOf2DSampleData
	string ListOfFiles,Extension, NameMatchString

//	ListOfFiles =  grepList(ListOfFiles,NameMatchString)
	
	variable i, imax, numberOfParts
	imax = itemsInList(listOfFiles)
	string result, tempFileName
	For(i=0;i<imax;i+=1)
		tempFileName = stringFromList(i,ListOfFiles)
		//numberOfParts = itemsInList(tempFileName,".")
		//if(strlen(NameMatchString)==0 || stringmatch(tempFileName, NameMatchString ))
		//	if(cmpstr(Extension,"????")==0)				//this is one of unknown extensions
		ListOf2DSampleData[i] = tempFileName 
		//	else
		//		ListOf2DSampleData[i] = tempFileName 
		//	endif
		//endif
	endfor
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_Convert2Dto1DPanelFnct()
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/N=NI1A_Convert2Dto1DPanel /W=(16,57,454,770) as "Main 2D to 1D conversion panel"
	//DoWindow/C NI1A_Convert2Dto1DPanel
	//SetDrawLayer UserBack
	//SetDrawEnv fsize= 18,fstyle= 1,textrgb= (0,12800,52224)
	//DrawText 48,20,"2D to 1D data conversion panel"
	//DrawText 10,89,"Select input data here"
	//DrawText 11,249,"Select contiguous range:"
	SVAR DataFileExtension = root:Packages:Convert2Dto1D:DataFileExtension

	TitleBox MainTitle title="2D to 1D data conversion panel",pos={48,2},frame=0,fstyle=3, fixedSize=1,size={300,24},fSize=18,fColor=(1,4,52428)
	TitleBox Info1 title="Select input data here",pos={5,72},frame=0,fstyle=1, fixedSize=1,size={130,20},fSize=12,fColor=(1,4,52428)
	TitleBox Info2 title="Select contiguous range:",pos={5,232},frame=0,fstyle=2, fixedSize=1,size={150,20},fSize=12
//first data selection part
	Button Select2DDataPath,pos={5,30},size={140,20},proc=NI1A_ButtonProc,title="Select data path"
	Button Select2DDataPath,help={"Select Data path where 2D data are"}
	TitleBox PathInfoStrt, pos={3,55}, size={350,20}, variable=root:Packages:Convert2Dto1D:MainPathInfoStr, fsize=9, frame=0, fstyle=2, fColor=(0,12800,32000)
	PopupMenu Select2DDataType,pos={290,30},size={111,21},proc=NI1A_PopMenuProc,title="Image type"
	PopupMenu Select2DDataType,help={"Select type of 2D images being loaded"}
	PopupMenu Select2DDataType,mode=2,popvalue=DataFileExtension,value= #"root:Packages:Convert2Dto1D:ListOfKnownExtensions"
	CheckBox UseCalib2DData,pos={165,33},size={146,14},proc=NI1A_CheckProc,title="Calibrated 2D data?"
	CheckBox UseCalib2DData,help={"Import 2D calibrated data, not raw image data"}
	CheckBox UseCalib2DData,variable= root:Packages:Convert2Dto1D:UseCalib2DData
	NVAR UseCalib2DData = root:Packages:Convert2Dto1D:UseCalib2DData
	SVAR DataFileExtension = root:Packages:Convert2Dto1D:DataFileExtension
	SVAR ListOfKnownCalibExtensions = root:Packages:Convert2Dto1D:ListOfKnownCalibExtensions
	if(UseCalib2DData)
		DataFileExtension = StringFromList(0,ListOfKnownCalibExtensions)
		PopupMenu Select2DDataType,mode=2,popvalue=DataFileExtension,value= #"root:Packages:Convert2Dto1D:ListOfKnownCalibExtensions"
	endif

	CheckBox ReverseBinnedData,pos={298,50},size={146,14},proc=NI1A_CheckProc,title="Unbin if needed?"
	CheckBox ReverseBinnedData,help={"Reverse binning if necessary?"}, disable=!(UseCalib2DData|| !StringMatch(DataFileExtension, "canSAS/Nexus"))
	CheckBox ReverseBinnedData,variable= root:Packages:Convert2Dto1D:ReverseBinnedData

	CheckBox InvertImages,pos={150,75},size={146,14},proc=NI1A_CheckProc,title="Invert 0, 0 corner?"
	CheckBox InvertImages,help={"Check to have 0,0 in left BOTTOM corner, uncheck to have 0,0 in left TOP corner. Only for newly loaded images!"}
	CheckBox InvertImages,variable= root:Packages:Convert2Dto1D:InvertImages
	PopupMenu FIlesSortOrder,pos={275,73},size={111,13},proc=NI1A_PopMenuProc,title="Sort order: "
	PopupMenu FIlesSortOrder,help={"Select Sorting of data"}
	NVAR FIlesSortOrder = root:Packages:Convert2Dto1D:FIlesSortOrder
	PopupMenu FIlesSortOrder,mode=(FIlesSortOrder+1),value= "None;Sort;Sort2;_001;Invert_001;Invert Sort;Invert Sort2;"

//	Button RefreshList,pos={330,97},size={100,18},proc=NI1A_ButtonProc,title="Refresh"
//	Button RefreshList,help={"Refresh lisbox"}
	TitleBox RefreshList1 title="Refresh using Right click",pos={325,99},frame=0,fstyle=1, fixedSize=1,size={120,11},fSize=9
	//TitleBox RefreshList2 title="",pos={340,105},frame=0,fstyle=1, fixedSize=1,size={100,11},fSize=9

	Button SaveCurrentToolSetting,pos={330,117},size={100,18},proc=NI1A_ButtonProc,title="Save/Load Config"
	Button SaveCurrentToolSetting,help={"Save or recall configuration of this panel"}
	Button ExportDisplayedImage,pos={330,137},size={100,18},proc=NI1A_ButtonProc,title="Export image"
	Button ExportDisplayedImage,help={"Save displayed image as tiff file for future use"}
	Button SaveDisplayedImage,pos={330,157},size={100,18},proc=NI1A_ButtonProc,title="Store image"
	Button SaveDisplayedImage,help={"Store displayed image within Ior experiment for future use. This can recult in VERY large files..."}
	Button CreateMovie,pos={330,177},size={100,18},proc=NI1A_ButtonProc,title="Create Movie"
	Button CreateMovie,help={"Create movie from the data during reduction"}
	Button OnLineDataProcessing,pos={330,197},size={100,18},proc=NI1A_ButtonProc,title="Live processing"
	Button OnLineDataProcessing,help={"Switch on and off live data visualization and processing"}
	SetVariable SampleNameMatchStr,pos={10,214},size={135,18},proc=NI1A_PanelSetVarProc,title="Match (RegEx)"
	SetVariable SampleNameMatchStr,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:SampleNameMatchStr

	ListBox Select2DInputWave,pos={16,92},size={300,120},row=0, clickEventModifiers=4
	ListBox Select2DInputWave,help={"Select data file to be converted, you can select multiple data sets"}
	ListBox Select2DInputWave,listWave=root:Packages:Convert2Dto1D:ListOf2DSampleData
	ListBox Select2DInputWave,selWave=root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers
	ListBox Select2DInputWave,mode= 4, proc=NI1_MainListBoxProc
	PopupMenu SelectStartOfRange,pos={155,217},size={214,21},proc=NI1A_PopMenuProc,title="Start"
	PopupMenu SelectStartOfRange,help={"Select first 2D data to process"}
	PopupMenu SelectStartOfRange,mode=1,popvalue="---",value= #"NI1A_Create2DSelectionPopup()"
	PopupMenu SelectEndOfRange,pos={158,240},size={211,21},proc=NI1A_PopMenuProc,title="End"
	PopupMenu SelectEndOfRange,help={"Select last 2D data to process"}
	PopupMenu SelectEndOfRange,mode=1,popvalue="---",value= #"NI1A_Create2DSelectionPopup()"  
	PopupMenu DataCalibrationString,pos={275,235},size={211,21},proc=NI1A_PopMenuProc,title="Int. Calibration:"
	PopupMenu DataCalibrationString,help={"Select data calibration string"}
	SVAR DataCalibrationString = root:Packages:Convert2Dto1D:DataCalibrationString
	PopupMenu DataCalibrationString,mode=1+WhichListItem(DataCalibrationString, "Arbitrary;cm2/cm3;cm2/g;" ),value= "Arbitrary;cm2/cm3;cm2/g;"
	CheckBox TrimFrontOfName,pos={10,260},size={100,18},proc=NI1A_CheckProc,title="Trim Front of Name"
	CheckBox TrimFrontOfName,help={"Check to trim FRONT of name to 20 characters"}, variable=root:Packages:Convert2Dto1D:TrimFrontOfName
	CheckBox TrimEndOfName,pos={130,260},size={100,18},proc=NI1A_CheckProc,title="Trim End of Name"
	CheckBox TrimEndOfName,help={"Check to trim END of name to 20 characters"}, variable=root:Packages:Convert2Dto1D:TrimEndOfName
	SetVariable RemoveStringFromName,pos={250,260},size={180,18},noproc,title="Remove from name:"
	SetVariable RemoveStringFromName,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:RemoveStringFromName

//tab controls here
	TabControl Convert2Dto1DTab,pos={4,284},size={430,300},proc=NI1A_TabProc
	TabControl Convert2Dto1DTab,help={"Select tabs to control various parameters"}
	TabControl Convert2Dto1DTab,tabLabel(0)="Main",tabLabel(1)="Param"
	TabControl Convert2Dto1DTab,tabLabel(2)="Mask",tabLabel(3)="Emp/Dk"
	TabControl Convert2Dto1DTab,tabLabel(4)="Sectors",tabLabel(5)="PolTrans", tabLabel(6)="LineProf", value= 0
	TabControl Convert2Dto1DTab,tabLabel(7)="2D Exp."
//tab 1 geometry and method of calibration
	SetVariable SampleToDetectorDistance,pos={24,309},size={230,16},Disable=1,proc=NI1A_PanelSetVarProc,title="Sample to CCD distance [mm]"
	SetVariable SampleToDetectorDistance,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:SampleToCCDDistance
	SetVariable Wavelength,pos={21,331},size={162,16},proc=NI1A_PanelSetVarProc,title="Wavelength [A]  "
	SetVariable Wavelength,help={"\"Input wavelegth of X-rays in Angstroems\" "}
	SetVariable Wavelength,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:Wavelength
	TitleBox GeometryDesc,pos={67,356},size={276,16},title="Direction     X (horizontal)                       Y (vertical)"
	TitleBox GeometryDesc,labelBack=(56576,56576,56576),fSize=12,frame=0
	TitleBox GeometryDesc,fColor=(0,0,65280)
	SetVariable PixleSizeX,pos={34,377},size={160,16},proc=NI1A_PanelSetVarProc,title="CCD pixel size [mm]"
	SetVariable PixleSizeX,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:PixelSizeX
	SetVariable PixleSizeY,pos={222,377},size={160,16},proc=NI1A_PanelSetVarProc,title="CCD pixel size [mm]"
	SetVariable PixleSizeY,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:PixelSizeY
	SetVariable BeamCenterX,pos={34,400},size={160,16},proc=NI1A_PanelSetVarProc,title="Beam center"
	SetVariable BeamCenterX,limits={-inf,Inf,1},value= root:Packages:Convert2Dto1D:BeamCenterX
	SetVariable BeamCenterY,pos={222,400},size={160,16},proc=NI1A_PanelSetVarProc,title="Beam center"
	SetVariable BeamCenterY,limits={-inf,Inf,1},value= root:Packages:Convert2Dto1D:BeamCenterY
	SetVariable HorizontalTilt,pos={34,420},size={160,16},proc=NI1A_PanelSetVarProc,title="Horizontal Tilt"
	SetVariable HorizontalTilt,limits={-90,90,0},value= root:Packages:Convert2Dto1D:HorizontalTilt,help={"Tilt of the image in horizontal plane (around 0 degrees)"}
	SetVariable VerticalTilt,pos={222,420},size={160,16},proc=NI1A_PanelSetVarProc,title="Vertical Tilt"
	SetVariable VerticalTilt,limits={-90,90,0},value= root:Packages:Convert2Dto1D:VerticalTilt,help={"Tilt of the image in vertical plane (around 90 degrees)"}
	SetVariable XrayEnergy,pos={205,331},size={162,16},proc=NI1A_PanelSetVarProc,title="X-ray energy [keV]"
	SetVariable XrayEnergy,help={"Input energy of X-rays in keV (linked with wavelength)"}
	SetVariable XrayEnergy,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:XrayEnergy
	CheckBox UseSampleThickness,pos={10,440},size={146,14},proc=NI1A_CheckProc,title="Use sample thickness (St)?"
	CheckBox UseSampleThickness,help={"Check if you will use sample thickness to scale data for calibration purposes"}
	CheckBox UseSampleThickness,variable= root:Packages:Convert2Dto1D:UseSampleThickness
	CheckBox UseSampleTransmission,pos={10,456},size={155,14},proc=NI1A_CheckProc,title="Use sample transmission (T)?"
	CheckBox UseSampleTransmission,help={"Check if you wil use sample transmission"}
	CheckBox UseSampleTransmission,variable= root:Packages:Convert2Dto1D:UseSampleTransmission
	CheckBox UseSampleCorrectionFactor,pos={10,472},size={173,14},proc=NI1A_CheckProc,title="Use sample Corection factor (C)?"
	CheckBox UseSampleCorrectionFactor,help={"Check if you will use correction factor to scale data to absolute scale"}
	CheckBox UseSampleCorrectionFactor,variable= root:Packages:Convert2Dto1D:UseCorrectionFactor
	CheckBox UseSolidAngle,pos={10,488},size={173,14},proc=NI1A_CheckProc,title="Use Solid Angle Corection (O)?"
	CheckBox UseSolidAngle,help={"Check if you will use correction factor to scale data to absolute scale"}
	CheckBox UseSolidAngle,variable= root:Packages:Convert2Dto1D:UseSolidAngle
	CheckBox UseI0ToCalibrate,pos={10,504},size={99,14},proc=NI1A_CheckProc,title="Use Monitor (I0)?"
	CheckBox UseI0ToCalibrate,help={"Check if you want to scale data by monitor counts"}
	CheckBox UseI0ToCalibrate,variable= root:Packages:Convert2Dto1D:UseI0ToCalibrate
	CheckBox UseDarkField,pos={10,520},size={128,14},proc=NI1A_CheckProc,title="Use Dark field (DF2D)?"
	CheckBox UseDarkField,help={"Check if you will use dark field"}
	CheckBox UseDarkField,variable= root:Packages:Convert2Dto1D:UseDarkField
	CheckBox UseEmptyField,pos={10,536},size={133,14},proc=NI1A_CheckProc,title="Use Empty field (EF2D)?"
	CheckBox UseEmptyField,help={"Check if you will use empty field"}
	CheckBox UseEmptyField,variable= root:Packages:Convert2Dto1D:UseEmptyField
	CheckBox UseSubtractFixedOffset,pos={209,461},size={183,14},proc=NI1A_CheckProc,title="Subtract constant from data (Ofst)?"
	CheckBox UseSubtractFixedOffset,help={"Check if you want to subtract constant from CCD data (replace dark field)"}
	CheckBox UseSubtractFixedOffset,variable= root:Packages:Convert2Dto1D:UseSubtractFixedOffset
	CheckBox UseSampleMeasTime,pos={209,500},size={184,14},proc=NI1A_CheckProc,title="Use sample measurement time (ts)?"
	CheckBox UseSampleMeasTime,help={"Check if you want to scale data by measurement time"}
	CheckBox UseSampleMeasTime,variable= root:Packages:Convert2Dto1D:UseSampleMeasTime
	CheckBox UseEmptyMeasTime,pos={209,518},size={180,14},proc=NI1A_CheckProc,title="Use empty measurement time (te)?"
	CheckBox UseEmptyMeasTime,help={"Check if you want to scale empty field data by measurement time"}
	CheckBox UseEmptyMeasTime,variable= root:Packages:Convert2Dto1D:UseEmptyMeasTime
	CheckBox UseDarkMeasTime,pos={209,536},size={195,14},proc=NI1A_CheckProc,title="Use dark field measurement time (td)?"
	CheckBox UseDarkMeasTime,help={"Check if you want to scale dark field data by measurement time"}
	CheckBox UseDarkMeasTime,variable= root:Packages:Convert2Dto1D:UseDarkMeasTime
	CheckBox UsePixelSensitivity,pos={209,442},size={159,14},proc=NI1A_CheckProc,title="Use pixel sensitivity (Pix2D)?"
	CheckBox UsePixelSensitivity,help={"Check if you want to use pixel sensitivity map"}
	CheckBox UsePixelSensitivity,variable= root:Packages:Convert2Dto1D:UsePixelSensitivity
	CheckBox UseMOnitorForEF,pos={209,480},size={146,14},proc=NI1A_CheckProc,title="Use I0/I0ef for empty field?"
	CheckBox UseMOnitorForEF,help={"Check if you want to scale empty by ratio of monitor values"}
	CheckBox UseMOnitorForEF,variable= root:Packages:Convert2Dto1D:UseMonitorForEF
	SetVariable CalibrationFormula,pos={12,558},size={390,16},title=" "
	SetVariable CalibrationFormula,help={"This is calibration method which will be applied to your data"}
	SetVariable CalibrationFormula,labelBack=(32768,40704,65280),fSize=10,frame=0
	SetVariable CalibrationFormula,limits={-Inf,Inf,0},value= root:Packages:Convert2Dto1D:CalibrationFormula
//tab 2 sample and calibration values

	CheckBox DoGeometryCorrection,pos={20,308},size={100,14},title="Geometry corr?",proc=NI1A_CheckProc
	CheckBox DoGeometryCorrection,help={"Correct for change in relative angular size and obliqueness of off-axis pixels. Correction to the output intensities to be equivalent to 2-theta scan. "}
	CheckBox DoGeometryCorrection,variable= root:Packages:Convert2Dto1D:DoGeometryCorrection

	CheckBox DoPolarizationCorrection,pos={220,308},size={100,14},title="Polarization corr?",proc=NI1A_CheckProc
	CheckBox DoPolarizationCorrection,help={"Correct intensities for Polarization correction."}
	CheckBox DoPolarizationCorrection,variable= root:Packages:Convert2Dto1D:DoPolarizationCorrection

	CheckBox DezingerCCDData,pos={20,328},size={112,14},title="Dezinger 2D Data?"
	CheckBox DezingerCCDData,help={"Remove speckles from image"}, proc=NI1A_CheckProc
	CheckBox DezingerCCDData,variable= root:Packages:Convert2Dto1D:DezingerCCDData
	SetVariable DezingerRatio,pos={150,328},size={100,16},title="Dez. Ratio"
	SetVariable DezingerRatio,help={"Dezinger ratio for removing speckles (usually 1.5 to 2)"}
	SetVariable DezingerRatio,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:DezingerRatio
	SetVariable DezingerHowManyTimes,pos={260,328},size={140,16},title="Dez. N times, N="
	SetVariable DezingerHowManyTimes,help={"Dezinger multiplicity, runs sample through the dezinger filter so many times..."}
	SetVariable DezingerHowManyTimes,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:DezingerHowManyTimes
	

	CheckBox UseSampleThicknFnct,pos={15,355},size={50,14},title="Use fnct?",proc=NI1A_CheckProc
	CheckBox UseSampleThicknFnct,help={"Check is thickness=Function(sampleName) for function name input."}
	CheckBox UseSampleThicknFnct,variable= root:Packages:Convert2Dto1D:UseSampleThicknFnct
	SetVariable SampleThickness,pos={193,355},size={180,16},title="Sample thickness [mm]"
	SetVariable SampleThickness,help={"Input sample thickness in mm"}
	SetVariable SampleThickness,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:SampleThickness
	SetVariable SampleThicknFnct,pos={93,355},size={300,16},title="Sa Thickness =", proc=NI1A_SetVarProcMainPanel
	SetVariable SampleThicknFnct,help={"Input function name which returns thickness in mm."}
	SetVariable SampleThicknFnct,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:SampleThicknFnct
	
	CheckBox UseSampleTransmFnct,pos={15,380},size={50,14},title="Use fnct?",proc=NI1A_CheckProc
	CheckBox UseSampleTransmFnct,help={"Check is transmission=Function(sampleName) for function name input."}
	CheckBox UseSampleTransmFnct,variable= root:Packages:Convert2Dto1D:UseSampleTransmFnct
	SetVariable SampleTransmFnct,pos={93,380},size={300,16},title="Sa Transmis =", proc=NI1A_SetVarProcMainPanel
	SetVariable SampleTransmFnct,help={"Input function name which returns transmission (0 - 1)."}
	SetVariable SampleTransmFnct,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:SampleTransmFnct
	SetVariable SampleTransmission,pos={193,380},size={180,16},title="Sample transmission"
	SetVariable SampleTransmission,help={"Input sample transmission"}
	SetVariable SampleTransmission,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:SampleTransmission


	CheckBox UseSampleCorrectFnct,pos={15,405},size={50,14},title="Use fnct?",proc=NI1A_CheckProc
	CheckBox UseSampleCorrectFnct,help={"Check is Correction factor=Function(sampleName) for function name input."}
	CheckBox UseSampleCorrectFnct,variable= root:Packages:Convert2Dto1D:UseSampleCorrectFnct
	SetVariable SampleCorrectFnct,pos={93,405},size={300,16},title="Corr factor =",proc=NI1A_SetVarProcMainPanel
	SetVariable SampleCorrectFnct,help={"Input function name which returns Corection/Calibration factor."}
	SetVariable SampleCorrectFnct,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:SampleCorrectFnct
	SetVariable CorrectionFactor,pos={193,405},size={180,16},title="Correction factor    "
	SetVariable CorrectionFactor,help={"Corection factor to multiply Measured data by "}
	SetVariable CorrectionFactor,limits={1e-32,Inf,0.1},value= root:Packages:Convert2Dto1D:CorrectionFactor

	CheckBox UseSampleMeasTimeFnct,pos={15,430},size={50,14},title="Use fnct?",proc=NI1A_CheckProc
	CheckBox UseSampleMeasTimeFnct,help={"Check is Measurement time=Function(sampleName) for function name input."}
	CheckBox UseSampleMeasTimeFnct,variable= root:Packages:Convert2Dto1D:UseSampleMeasTimeFnct
	SetVariable SampleMeasTimeFnct,pos={93,430},size={300,16},title="Sample Meas time =",proc=NI1A_SetVarProcMainPanel
	SetVariable SampleMeasTimeFnct,help={"Input function name which returns Sample measurement time."}
	SetVariable SampleMeasTimeFnct,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:SampleMeasTimeFnct
	SetVariable SampleMeasurementTime,pos={123,430},size={250,16},title="Sample measurement time [s]"
	SetVariable SampleMeasurementTime,limits={1e-32,Inf,1},value= root:Packages:Convert2Dto1D:SampleMeasurementTime


	CheckBox UseEmptyTimeFnct,pos={15,455},size={50,14},title="Use fnct?",proc=NI1A_CheckProc
	CheckBox UseEmptyTimeFnct,help={"Check is Empty meas. time = Function(sampleName) for function name input."}
	CheckBox UseEmptyTimeFnct,variable= root:Packages:Convert2Dto1D:UseEmptyTimeFnct
	SetVariable EmptyTimeFnct,pos={93,455},size={300,16},title="Empty meas time =",proc=NI1A_SetVarProcMainPanel
	SetVariable EmptyTimeFnct,help={"Input function name which returns Empty measurement time."}
	SetVariable EmptyTimeFnct,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:EmptyTimeFnct
	SetVariable EmptyMeasurementTime,pos={123,455},size={250,16},title="Empty measurement time [s]  "
	SetVariable EmptyMeasurementTime,help={"Empty beam measurement time"}
	SetVariable EmptyMeasurementTime,limits={1e-32,Inf,1},value= root:Packages:Convert2Dto1D:EmptyMeasurementTime

	CheckBox UseBackgTimeFnct,pos={15,480},size={50,14},title="Use fnct?",proc=NI1A_CheckProc
	CheckBox UseBackgTimeFnct,help={"Check is Background meas. time = Function(sampleName) for function name input."}
	CheckBox UseBackgTimeFnct,variable= root:Packages:Convert2Dto1D:UseBackgTimeFnct
	SetVariable BackgTimeFnct,pos={93,480},size={300,16},title="Backgr meas time =",proc=NI1A_SetVarProcMainPanel
	SetVariable BackgTimeFnct,help={"Input function name which returns Background measurement time."}
	SetVariable BackgTimeFnct,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:BackgTimeFnct
	SetVariable BackgroundMeasTime,pos={93,480},size={280,16},title="Background measurement time [s]  "
	SetVariable BackgroundMeasTime,help={"Background beam measurement time"}
	SetVariable BackgroundMeasTime,limits={1e-32,Inf,1},value= root:Packages:Convert2Dto1D:BackgroundMeasTime

	SetVariable SubtractFixedOffset,pos={153,505},size={220,16},title="Fixed offset for CCD images"
	SetVariable SubtractFixedOffset,help={"Subtract fixed offset value for CCD images"}
	SetVariable SubtractFixedOffset,limits={-inf,Inf,1},value= root:Packages:Convert2Dto1D:SubtractFixedOffset

	CheckBox UseSampleMonitorFnct,pos={15,530},size={50,14},title="Use fnct?",proc=NI1A_CheckProc
	CheckBox UseSampleMonitorFnct,help={"Check is Sample Monitor = Function(sampleName) for function name input."}
	CheckBox UseSampleMonitorFnct,variable= root:Packages:Convert2Dto1D:UseSampleMonitorFnct
	SetVariable SampleMonitorFnct,pos={93,530},size={300,16},title="Sample monitor =",proc=NI1A_SetVarProcMainPanel
	SetVariable SampleMonitorFnct,help={"Input function name which returns Sample monitor (I0) count"}
	SetVariable SampleMonitorFnct,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:SampleMonitorFnct
	SetVariable SampleI0,pos={153,530},size={220,16},title="Sample Monitor counts"
	SetVariable SampleI0,help={"Monitor counts for sample"}
	SetVariable SampleI0,limits={1e-32,Inf,1},value= root:Packages:Convert2Dto1D:SampleI0

	CheckBox UseEmptyMonitorFnct,pos={15,555},size={50,14},title="Use fnct?",proc=NI1A_CheckProc
	CheckBox UseEmptyMonitorFnct,help={"Check is Empty Monitor = Function(sampleName) for function name input."}
	CheckBox UseEmptyMonitorFnct,variable= root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
	SetVariable EmptyMonitorFnct,pos={93,555},size={300,16},title="Empty Mon cnts =",proc=NI1A_SetVarProcMainPanel
	SetVariable EmptyMonitorFnct,help={"Input function name which returns Empty monitor (I0) counts"}
	SetVariable EmptyMonitorFnct,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:EmptyMonitorFnct
	SetVariable EmptyI0,pos={153,555},size={220,16},title="Empty Monitor counts  "
	SetVariable EmptyI0,help={"Monitor counts for empty beam"}
	SetVariable EmptyI0,limits={1e-32,Inf,1},value= root:Packages:Convert2Dto1D:EmptyI0
//tab 3 mask part
	CheckBox UseMask,pos={271,315},size={72,14},proc=NI1A_CheckProc,title="Use Mask?"
	CheckBox UseMask,help={"Check if you will use mask"}
	CheckBox UseMask,variable= root:Packages:Convert2Dto1D:UseMask
	Button MaskSelectPath,pos={25,339},size={200,20},proc=NI1A_ButtonProc,title="Select mask data path"
	Button MaskSelectPath,help={"Select path to mask file"}
//	PopupMenu Select2DMaskType,pos={232,339},size={111,21},proc=NI1A_PopMenuProc,title="Image type"
//	PopupMenu Select2DMaskType,help={"Masks made by this code are tiff files, the should be: xxxx_mask.ext (tif)"}
//	PopupMenu Select2DMaskType,mode=1,popvalue=root:Packages:Convert2Dto1D:MaskFileExtension,value= #"\"tif;\""
	ListBox MaskListBoxSelection,pos={83,375},size={260,100}, row=0, clickEventModifiers=4
	ListBox MaskListBoxSelection,help={"Select 2D data set for mask"}
	ListBox MaskListBoxSelection,listWave=root:Packages:Convert2Dto1D:ListOf2DMaskData
	ListBox MaskListBoxSelection,row= 0,mode= 1,selRow= 0, proc=NI1_MaskListBoxProc
	Button LoadMask,pos={192,480},size={150,20},proc=NI1A_ButtonProc,title="Load mask"
	Button LoadMask,help={"Load the mask file "}
	Button CreateMask,pos={24,480},size={150,20},proc=NI1A_ButtonProc,title="Create new mask"
	Button CreateMask,help={"Create mask file using GUI"}
	Button DisplayMaskOnImage,pos={24,504},size={150,20},proc=NI1A_ButtonProc,title="Add mask to image"
	Button DisplayMaskOnImage,help={"Display the mask file in the image"}
	Button RemoveMaskFromImage,pos={192,504},size={150,20},proc=NI1A_ButtonProc,title="Remove mask from image"
	Button RemoveMaskFromImage,help={"Remove mask from image"}
	PopupMenu MaskImageColor,pos={25,528},size={111,21},proc=NI1A_PopMenuProc,title="Mask color"
	PopupMenu MaskImageColor,help={"Select mask color"}
	PopupMenu MaskImageColor,mode=1,value= #"\"grey;red;blue;black;green\""
	SetVariable CurrentMaskName,pos={43,555},size={300,16},title="Current mask name :"
	SetVariable CurrentMaskName,labelBack=(32768,32768,65280),frame=0
	SetVariable CurrentMaskName,limits={-Inf,Inf,0},value= root:Packages:Convert2Dto1D:CurrentMaskFileName,noedit= 1
//tab 4 Empty, dark and pixel sensitivity
	Button SelectMaskDarkPath,pos={10,310},size={240,20},proc=NI1A_ButtonProc,title="Select path to mask, dark & pix sens. files"
	Button SelectMaskDarkPath,help={"Select Data path where Empty and Dark files are"}
	PopupMenu SelectBlank2DDataType,pos={270,310},size={111,21},proc=NI1A_PopMenuProc,title="Image type"
	PopupMenu SelectBlank2DDataType,help={"Select type of 2D images being loaded"}

	ListBox Select2DMaskDarkWave,pos={23,335},size={351,120},disable=1, row=0
	ListBox Select2DMaskDarkWave,help={"Select data file to be used as empty beam or dark field"}
	ListBox Select2DMaskDarkWave,listWave=root:Packages:Convert2Dto1D:ListOf2DEmptyData
	ListBox Select2DMaskDarkWave,row= 0,mode= 1,selRow= 0, proc=NI1_EmpDarkListBoxProc
	Button LoadEmpty,pos={51,460},size={130,20},proc=NI1A_ButtonProc,title="Load Empty"
	Button LoadEmpty,help={"Load empty data"}
	Button LoadDarkField,pos={41,483},size={160,20},proc=NI1A_ButtonProc,title="Load Dark Field"
	Button LoadDarkField,help={"Load dark field data"}
	CheckBox DezingerEmpty,pos={256,464},size={101,14},title="Dezinger Empty"
	CheckBox DezingerEmpty,help={"Remove speckles from empty"}, proc=NI1A_CheckProc
	CheckBox DezingerEmpty,variable= root:Packages:Convert2Dto1D:DezingerEmpty
	CheckBox DezingerDark,pos={255,485},size={95,14},title="Dezinger Dark"
	CheckBox DezingerDark,help={"Remove speckles from dark field"}, proc=NI1A_CheckProc
	CheckBox DezingerDark,variable= root:Packages:Convert2Dto1D:DezingerDarkField
	SVAR DataFileExtension = root:Packages:Convert2Dto1D:DataFileExtension
	PopupMenu SelectBlank2DDataType,mode=2,popvalue=DataFileExtension,value= #"root:Packages:Convert2Dto1D:ListOfKnownExtensions"
	SetVariable CurrentEmptyName,pos={19,533},size={350,16},title="Empty file:"
	SetVariable CurrentEmptyName,help={"Name of file currently used as empty beam"}
	SetVariable CurrentEmptyName,frame=0, noedit=1
	SetVariable CurrentEmptyName,limits={-Inf,Inf,0},value= root:Packages:Convert2Dto1D:CurrentEmptyName
	SetVariable CurrentDarkFieldName,pos={19,548},size={350,16},title="Dark file:"
	SetVariable CurrentDarkFieldName,help={"Name of file currently used as dark field"}
	SetVariable CurrentDarkFieldName,frame=0, noedit=1
	SetVariable CurrentDarkFieldName,limits={-Inf,Inf,0},value= root:Packages:Convert2Dto1D:CurrentDarkFieldName
	Button LoadPixel2DSensitivity,pos={34,508},size={180,20},proc=NI1A_ButtonProc,title="Load Pixel sensitivity file"
	Button LoadPixel2DSensitivity,help={"Load dark field data"}
	SetVariable CurrentPixSensFileName,pos={19,563},size={350,16},title="Pix sensitivity file:"
	SetVariable CurrentPixSensFileName,help={"Name of file currently used as pixel sensitivity"}
	SetVariable CurrentPixSensFileName,frame=0, noedit =1
	SetVariable CurrentPixSensFileName,limits={-Inf,Inf,0},value= root:Packages:Convert2Dto1D:CurrentPixSensFile

	SetVariable EmptyDarkNameMatchStr,pos={245,510},size={155,18},proc=NI1A_PanelSetVarProc,title="Match (RegEx)"
	SetVariable EmptyDarkNameMatchStr,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:EmptyDarkNameMatchStr

//tab 5 output conditions
	
	CheckBox UseSectors,pos={15,310},size={90,14},title="Use?", mode=0, proc=NI1A_CheckProc
	CheckBox UseSectors,help={"Use any of the settings in this tab?"}
	CheckBox UseSectors,variable= root:Packages:Convert2Dto1D:UseSectors
	CheckBox UseQvector,pos={100,310},size={90,14},title="Q space?", mode=1, proc=NI1A_CheckProc
	CheckBox UseQvector,help={"Select to have output as function of q [inverse nm]"}
	CheckBox UseQvector,variable= root:Packages:Convert2Dto1D:UseQvector
	CheckBox UseDspacing,pos={170,310},size={90,14},title="d ?", mode=1, proc=NI1A_CheckProc
	CheckBox UseDspacing,help={"Select to have output as function of d spacing"}
	CheckBox UseDspacing,variable= root:Packages:Convert2Dto1D:UseDspacing
	CheckBox UseTheta,pos={220,310},size={90,14},title="2 Theta ?", mode=1, proc=NI1A_CheckProc
	CheckBox UseTheta,help={"Select to have output as function of 2 theta"}
	CheckBox UseTheta,variable= root:Packages:Convert2Dto1D:UseTheta
	CheckBox UseDistanceFromCenter,pos={300,310},size={90,14},title="Distance [mm]?", mode=1, proc=NI1A_CheckProc
	CheckBox UseDistanceFromCenter,help={"Select to have output as function of distacne fromcenter in mm"}
	CheckBox UseDistanceFromCenter,variable= root:Packages:Convert2Dto1D:UseDistanceFromCenter

	SetVariable UserQMin,pos={20,330},size={180,16},title="Min Q (0 = automatic)"//,proc=NI1A_PanelSetVarProc
	SetVariable UserQMin,help={"Input minimum in Q, left set to 0 for automatic - find first available Q value"}
	SetVariable UserQMin,limits={0,Inf,0},value= root:Packages:Convert2Dto1D:UserQMin
	SetVariable UserQMax,pos={220,330},size={180,16},title="Max Q (0 = automatic)"//,proc=NI1A_PanelSetVarProc
	SetVariable UserQMax,help={"Input maximum in Q, left set to 0 for automatic - find last available Q value"}
	SetVariable UserQMax,limits={0,Inf,0},value= root:Packages:Convert2Dto1D:UserQMax
	SetVariable UserThetaMin,pos={20,330},size={180,16},title="Min 2th (0 = automatic)"//,proc=NI1A_PanelSetVarProc
	SetVariable UserThetaMin,help={"Input minimum in 2 theta, left set to 0 for automatic - find first available 2 theta value"}
	SetVariable UserThetaMin,limits={0,Inf,0},value= root:Packages:Convert2Dto1D:UserThetaMin
	SetVariable UserThetaMax,pos={220,330},size={180,16},title="Max 2th (0 = automatic)"//,proc=NI1A_PanelSetVarProc
	SetVariable UserThetaMax,help={"Input maximum in 2 theta, left set to 0 for automatic - find last available 2 theta value"}
	SetVariable UserThetaMax,limits={0,Inf,0},value= root:Packages:Convert2Dto1D:UserThetaMax
	SetVariable UserDMin,pos={20,330},size={180,16},title="Min d (0 = automatic)"//,proc=NI1A_PanelSetVarProc
	SetVariable UserDMin,help={"Input minimum in d, left set to 0 for automatic - find first available d value"}
	SetVariable UserDMin,limits={0,Inf,0},value= root:Packages:Convert2Dto1D:UserDMin
	SetVariable UserDMax,pos={220,330},size={180,16},title="Max d (0 = automatic)"//,proc=NI1A_PanelSetVarProc
	SetVariable UserDMax,help={"Input maximum in d, left set to 0 for automatic - find last available d value"}
	SetVariable UserDMax,limits={0,Inf,0},value= root:Packages:Convert2Dto1D:UserDMax


	CheckBox QbinningLogarithmic,pos={20,350},size={90,14},title="Log binning?",proc=NI1A_CheckProc
	CheckBox QbinningLogarithmic,help={"Check to have binning in q (d or theta) logarithmic"}
	CheckBox QbinningLogarithmic,variable= root:Packages:Convert2Dto1D:QbinningLogarithmic
	SetVariable QbinPoints,pos={172,370},size={160,16},title="Number of points"
	NVAR QvectorMaxNumPnts = root:Packages:Convert2Dto1D:QvectorMaxNumPnts
	SetVariable QbinPoints,help={"Number of points in Q you want to create"}, disable = (QvectorMaxNumPnts)
	SetVariable QbinPoints,limits={0,Inf,10},value= root:Packages:Convert2Dto1D:QvectorNumberPoints
	CheckBox QvectorMaxNumPnts,pos={172,350},size={130,14},title="Max num points?",proc=NI1A_CheckProc
	CheckBox QvectorMaxNumPnts,help={"Use Max possible number of points? Num pnts = num pixels"}
	CheckBox QvectorMaxNumPnts,variable= root:Packages:Convert2Dto1D:QvectorMaxNumPnts

	CheckBox DoCircularAverage,pos={20,370},size={130,14},title="Do circular average?",proc=NI1A_CheckProc
	CheckBox DoCircularAverage,help={"Create data with circular average?"}
	CheckBox DoCircularAverage,variable= root:Packages:Convert2Dto1D:DoCircularAverage
	CheckBox DoSectorAverages,pos={20,390},size={130,14},title="Make sector averages?",proc=NI1A_CheckProc
	CheckBox DoSectorAverages,help={"Create data with sector average?"}, proc=NI1A_checkProc
	CheckBox DoSectorAverages,variable= root:Packages:Convert2Dto1D:DoSectorAverages
	SetVariable NumberOfSectors,pos={20,410},size={160,16},title="Number of sectors",proc=NI1A_PanelSetVarProc
	SetVariable NumberOfSectors,help={"Number of sectors you want to create"}
	SetVariable NumberOfSectors,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:NumberOfSectors
	
	SetVariable SectorsStartAngle,pos={200,410},size={160,16},title="Start angle of sectors",proc=NI1A_PanelSetVarProc
	SetVariable SectorsStartAngle,help={"Angle around which first sectors is centered"}
	SetVariable SectorsStartAngle,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:SectorsStartAngle
	SetVariable SectorsHalfWidth,pos={20,430},size={160,16},title="Width of sector +/- ",proc=NI1A_PanelSetVarProc
	SetVariable SectorsHalfWidth,help={"Half width of sectors in degrees"}
	SetVariable SectorsHalfWidth,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:SectorsHalfWidth
	SetVariable SectorsStepInAngle,pos={200,430},size={160,16},title="Angle between sectors",proc=NI1A_PanelSetVarProc
	SetVariable SectorsStepInAngle,help={"Angle between center directions of sectors"}
	SetVariable SectorsStepInAngle,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:SectorsStepInAngle

	CheckBox DisplayDataAfterProcessing,pos={20,450},size={159,14},title="Create 1D graph?"
	CheckBox DisplayDataAfterProcessing,help={"Create graph of 1D data after processing"},proc=NI1A_CheckProc
	CheckBox DisplayDataAfterProcessing,variable= root:Packages:Convert2Dto1D:DisplayDataAfterProcessing

	CheckBox StoreDataInIgor,pos={20,470},size={159,14},title="Store data in Igor experiment?"
	CheckBox StoreDataInIgor,help={"Save data in current Igor experiment"},proc=NI1A_CheckProc
	CheckBox StoreDataInIgor,variable= root:Packages:Convert2Dto1D:StoreDataInIgor
	CheckBox OverwriteDataIfExists,pos={200,470},size={159,14},title="Overwrite existing data if exist?"
	CheckBox OverwriteDataIfExists,help={"Overwrite data in current Igor experiment if they already exist"}
	CheckBox OverwriteDataIfExists,variable= root:Packages:Convert2Dto1D:OverwriteDataIfExists
	
	CheckBox AppendToNexusFile,pos={20,490},size={170,14},title="Append to original image (Nexus ONLY)?"
	CheckBox AppendToNexusFile,help={"Append to Nexus file, useable ONLy if sourceis Nexus"}
	CheckBox AppendToNexusFile,variable= root:Packages:Convert2Dto1D:AppendToNexusFile,proc=NI1A_CheckProc

	CheckBox ExportDataOutOfIgor,pos={20,510},size={122,14},title="Export data as ASCII?"
	CheckBox ExportDataOutOfIgor,help={"Check to export data out of Igor, select data path"}
	CheckBox ExportDataOutOfIgor,variable= root:Packages:Convert2Dto1D:ExportDataOutOfIgor
	NVAR UseTheta = root:Packages:Convert2Dto1D:UseTheta
	CheckBox SaveGSASdata,pos={150,510},size={122,14},title="GSAS?", disable=!(UseTheta)
	CheckBox SaveGSASdata,help={"Check to export data out of Igoras GSAS data"}
	CheckBox SaveGSASdata,variable= root:Packages:Convert2Dto1D:SaveGSASdata

	CheckBox Use2DdataName,pos={20,531},size={170,14},title="Use input data name for output?"
	CheckBox Use2DdataName,help={"Check to have output data named after input data name"}
	CheckBox Use2DdataName,variable= root:Packages:Convert2Dto1D:Use2DdataName
	Button CreateOutputPath,pos={250,505},size={160,20},title="Select output path"
	Button CreateOutputPath,help={"Select path to export data into"},proc=NI1A_ButtonProc
	SetVariable OutputFileName,pos={20,554},size={360,16},title="ASCII data name"
	SetVariable OutputFileName,help={"Input string for 1D data"}
	SetVariable OutputFileName,value= root:Packages:Convert2Dto1D:OutputDataName
	//tab 6 - sectors for namual processing...
	Button CreateSectorGraph,pos={20,530},size={160,20},title="Create sector graph"
	Button CreateSectorGraph,help={"Create graph in of angle vs pixel for manual processing"},proc=NI1A_ButtonProc
	SetVariable SectorsNumSect,pos={20,320},size={180,16},title="Number of sectors   "
	SetVariable SectorsNumSect,help={"How many sectors to use for creating the graph?"}, proc=NI1A_SetVarProcMainPanel
	SetVariable SectorsNumSect,value= root:Packages:Convert2Dto1D:SectorsNumSect, limits={2,720,1}
	SetVariable SectorsSectWidth,pos={20,350},size={180,16},title="Width of each sector"
	SetVariable SectorsSectWidth,help={"How wide (in degrees) the sectors should be?"}, limits={0.5,180,1}
	SetVariable SectorsSectWidth,value= root:Packages:Convert2Dto1D:SectorsSectWidth, proc=NI1A_SetVarProcMainPanel
	SetVariable SectorsGraphStartAngle,pos={20,380},size={220,16},title="Start Angle for sector graph"
	SetVariable SectorsGraphStartAngle,help={"Start angle for sector graph?"}, limits={-180,360,1}
	SetVariable SectorsGraphStartAngle,value= root:Packages:Convert2Dto1D:SectorsGraphStartAngle, proc=NI1A_SetVarProcMainPanel
	SetVariable SectorsGraphEndAngle,pos={20,410},size={220,16},title="End Angle for sector graph "
	SetVariable SectorsGraphEndAngle,help={"And angle for secotr graph?"}, limits={0,540,1}
	SetVariable SectorsGraphEndAngle,variable= root:Packages:Convert2Dto1D:SectorsGraphEndAngle, proc=NI1A_SetVarProcMainPanel
	CheckBox A2DmaskImage,pos={20,440},size={170,14},title="Mask the data?"
	CheckBox A2DmaskImage,help={"Check to have  data masked"}
	CheckBox A2DmaskImage,variable= root:Packages:Convert2Dto1D:A2DmaskImage
	CheckBox SectorsUseRAWData,pos={20,460},size={170,14},title="Use RAW data?", mode=1
	CheckBox SectorsUseRAWData,help={"Use raw data for creating sectors graph?"}, proc=NI1A_CheckProc
	CheckBox SectorsUseRAWData,variable= root:Packages:Convert2Dto1D:SectorsUseRAWData
	CheckBox SectorsUseCorrData,pos={20,480},size={170,14},title="Use Processed data?", mode=1
	CheckBox SectorsUseCorrData,help={"Check to have  data masked"}, proc=NI1A_CheckProc
	CheckBox SectorsUseCorrData,variable= root:Packages:Convert2Dto1D:SectorsUseCorrData

//tab 6 output conditions
	CheckBox UseLineProfile,pos={15,310},size={90,14},title="Use?", mode=0, proc=NI1A_CheckProc
	CheckBox UseLineProfile,help={"Use any of the settings in this tab?"}
	CheckBox UseLineProfile,variable= root:Packages:Convert2Dto1D:UseLineProfile
	CheckBox LineProf_UseBothHalfs,pos={15,330},size={90,14},title="Include mirror?", mode=0, proc=NI1A_CheckProc
	CheckBox LineProf_UseBothHalfs,help={"Use lines at both + and - distance?"}
	CheckBox LineProf_UseBothHalfs,variable= root:Packages:Convert2Dto1D:LineProf_UseBothHalfs
//LineProfileUseRAW;LineProfileUseCorrData
	CheckBox LineProfileUseRAW,pos={300,310},size={90,14},title="Use RAW?", mode=1, proc=NI1A_CheckProc
	CheckBox LineProfileUseRAW,help={"Use uncorrected data?"}
	CheckBox LineProfileUseRAW,variable= root:Packages:Convert2Dto1D:LineProfileUseRAW
	CheckBox LineProfileUseCorrData,pos={300,330},size={90,14},title="Use Processed?", mode=1, proc=NI1A_CheckProc
	CheckBox LineProfileUseCorrData,help={"Use corrected data?"}
	CheckBox LineProfileUseCorrData,variable= root:Packages:Convert2Dto1D:LineProfileUseCorrData

	PopupMenu LineProf_CurveType,pos={20,355},size={214,21},proc=NI1A_PopMenuProc,title="Path type:"
	PopupMenu LineProf_CurveType,help={"Select Line profile method to use"}
	SVAR LineProf_CurveType = root:Packages:Convert2Dto1D:LineProf_CurveType
	PopupMenu LineProf_CurveType,mode=1,popvalue=LineProf_CurveType,value= #"root:Packages:Convert2Dto1D:LineProf_KnownCurveTypes"
//Shape specific controls.
	SetVariable LineProf_GIIncAngle,pos={220,355},size={210,16},title="GI inc. angle [deg] "
	SetVariable LineProf_GIIncAngle,help={"Incident angle for GISAXS configuration in degrees?"}, limits={-inf, inf,0.01}
	SetVariable LineProf_GIIncAngle,variable= root:Packages:Convert2Dto1D:LineProf_GIIncAngle, proc=NI1A_SetVarProcMainPanel

	SetVariable LineProf_EllipseAR,pos={220,355},size={210,16},title="Ellipse AR"
	SetVariable LineProf_EllipseAR,help={"Aspect ratio for ellipse?"}, limits={-inf, inf,1}
	SetVariable LineProf_EllipseAR,variable= root:Packages:Convert2Dto1D:LineProf_EllipseAR, proc=NI1A_SetVarProcMainPanel

	SetVariable LineProf_LineAzAngle,pos={220,355},size={210,16},title="Line Az angle [deg]"
	SetVariable LineProf_LineAzAngle,help={"Azimuthal angle for line going through center in degrees?"}, limits={0, 179.999,1}
	SetVariable LineProf_LineAzAngle,variable= root:Packages:Convert2Dto1D:LineProf_LineAzAngle, proc=NI1A_SetVarProcMainPanel
	
	//other controls	
	SetVariable LineProf_DistanceFromCenter,pos={20,405},size={220,16},title="Distance from center [in pixles] "
	SetVariable LineProf_DistanceFromCenter,help={"Distacne from center in pixels?"}, limits={-inf, inf,1}
	SetVariable LineProf_DistanceFromCenter,variable= root:Packages:Convert2Dto1D:LineProf_DistanceFromCenter, proc=NI1A_SetVarProcMainPanel
	SetVariable LineProf_DistanceQ,pos={280,405},size={100,16},title="Q =  ",format="%.4f"
	SetVariable LineProf_DistanceQ,help={"Distacne from center in q units"}, limits={-inf, inf,0}
	SetVariable LineProf_DistanceQ,variable= root:Packages:Convert2Dto1D:LineProf_DistanceQ//, proc=NI1A_SetVarProcMainPanel
	SetVariable LineProf_Width,pos={20,425},size={220,17},proc=NI1A_SetVarProcMainPanel,title="Width [in pixles]                      "
	SetVariable LineProf_Width,help={"WIdth of the line in pixels?"}
	SetVariable LineProf_Width,variable= root:Packages:Convert2Dto1D:LineProf_Width
	SetVariable LineProf_WidthQ,pos={280,425},size={100,17},title="Q =  "
	SetVariable LineProf_WidthQ,help={"Width in q units"},format="%.4f"
	SetVariable LineProf_WidthQ,limits={-inf,inf,0},variable= root:Packages:Convert2Dto1D:LineProf_WidthQ 
	//last few items under the tabs area
	Button DisplaySelectedFile,pos={14,587},size={150,18},proc=NI1A_ButtonProc,title="Ave & Display sel. file(s)"
	Button DisplaySelectedFile,help={"Average selected files and display, only correction is dezingering!"}
	Button ConvertSelectedFiles,pos={15,607},size={150,18},proc=NI1A_ButtonProc,title="Convert sel. files 1 at time"
	Button ConvertSelectedFiles,help={"Convert selected files (1 by 1) using parameters selected in the tabs"}
	Button AveConvertSelectedFiles,pos={15,627},size={150,18},proc=NI1A_ButtonProc,title="Ave & Convert sel. files"
	Button AveConvertSelectedFiles,help={"Average and convert files selected above using parameters set here"}
	//Tab 7 - export 2D calibrated data
	CheckBox ExpCalib2DData,pos={15,310},size={90,14},title="Export 2D Calibrated data?", mode=0, proc=NI1A_CheckProc
	CheckBox ExpCalib2DData,help={"Use this tab and export 2D caclibrated data?"}, variable=root:Packages:Convert2Dto1D:ExpCalib2DData
	CheckBox InclMaskCalib2DData,pos={15,330},size={90,14},title="Include Mask?", mode=0, proc=NI1A_CheckProc
	CheckBox InclMaskCalib2DData,help={"Include Mask with 2D calibrated data?"}, variable=root:Packages:Convert2Dto1D:InclMaskCalib2DData
	CheckBox UseQxyCalib2DData,pos={15,350},size={90,14},title="Use Qx/Qy (not |Q|)?", mode=0, proc=NI1A_CheckProc
	CheckBox UseQxyCalib2DData,help={"Use Qx and Qy as opposed to Q?"}, variable=root:Packages:Convert2Dto1D:UseQxyCalib2DData
	CheckBox RebinCalib2DData,pos={15,370},size={90,14},title="Rebin Data?", mode=0, proc=NI1A_CheckProc
	CheckBox RebinCalib2DData,help={"Use Qx and Qy as opposed to Q?"}, variable=root:Packages:Convert2Dto1D:RebinCalib2DData
	PopupMenu RebinCalib2DDataToPnts,pos={150,370},size={214,21},proc=NI1A_PopMenuProc,title="Rebin to:"
	PopupMenu RebinCalib2DDataToPnts,help={"Select Line profile method to use"}
	SVAR RebinCalib2DDataToPnts = root:Packages:Convert2Dto1D:RebinCalib2DDataToPnts
	PopupMenu RebinCalib2DDataToPnts,mode=1,popvalue=RebinCalib2DDataToPnts,value= "100x100;200x200;300x300;400x400;600x600;"

	PopupMenu Calib2DDataOutputFormat,pos={220,530},size={111,21},proc=NI1A_PopMenuProc,title="Output data type"
	PopupMenu Calib2DDataOutputFormat,help={"Select type of 2D images being loaded"}
	SVAR Calib2DDataOutputFormat = root:Packages:Convert2Dto1D:Calib2DDataOutputFormat
	PopupMenu Calib2DDataOutputFormat,mode=2,popvalue=Calib2DDataOutputFormat,value= "CanSAS/Nexus;EQSANS;"

	//bottom controls
	NVAR ImageRangeMinLimit = root:Packages:Convert2Dto1D:ImageRangeMinLimit
	NVAR ImageRangeMaxLimit = root:Packages:Convert2Dto1D:ImageRangeMaxLimit
	Slider ImageRangeMin,pos={15,647},size={150,16},proc=NI1A_MainSliderProc,variable= root:Packages:Convert2Dto1D:ImageRangeMin,live= 0,side= 2,vert= 0,ticks= 0
	Slider ImageRangeMin,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}
	Slider ImageRangeMax,pos={15,663},size={150,16},proc=NI1A_MainSliderProc,variable= root:Packages:Convert2Dto1D:ImageRangeMax,live= 0,side= 2,vert= 0,ticks= 0
	Slider ImageRangeMax,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}

	Button AveConvertNFiles,pos={170,587},size={150,18},proc=NI1A_ButtonProc,title="Ave & Convert N files"
	Button AveConvertNFiles,help={"Average N files at time, convert all files selected above using parameters set here"}

	SetVariable ProcessNImagesAtTime,pos={335,589},size={80,16},title="N = "
	SetVariable ProcessNImagesAtTime,help={"Howmany images at time should be averaged?"}, limits={1,inf,1}
	SetVariable ProcessNImagesAtTime,variable= root:Packages:Convert2Dto1D:ProcessNImagesAtTime, proc=NI1A_SetVarProcMainPanel
	//
	CheckBox SkipBadFiles,pos={185,605},size={120,16},title="Skip bad files?"
	CheckBox SkipBadFiles,help={"Skip images with low maximum intensity?"}
	CheckBox SkipBadFiles,variable= root:Packages:Convert2Dto1D:SkipBadFiles
	CheckBox SkipBadFiles proc=NI1A_CheckProc
	SetVariable MaxIntForBadFile,pos={300,610},size={120,16},title="Min. Int = "
	SetVariable MaxIntForBadFile,help={"Bad file has less than this intensity?"}, limits={0,inf,1}
	NVAR SkipBadFiles = root:Packages:Convert2Dto1D:SkipBadFiles
	SetVariable MaxIntForBadFile,variable= root:Packages:Convert2Dto1D:MaxIntForBadFile, disable=!(SkipBadFiles)

	CheckBox DisplayRaw2DData,pos={185,623},size={120,16},title="Display RAW data?"
	CheckBox DisplayRaw2DData,help={"In the 2D image, display raw data?"}, mode=1
	CheckBox DisplayRaw2DData,variable= root:Packages:Convert2Dto1D:DisplayRaw2DData
	CheckBox DisplayRaw2DData proc=NI1A_CheckProc
	CheckBox DisplayProcessed2DData,pos={185,640},size={120,16},title="Display Processed?"
	CheckBox DisplayProcessed2DData,help={"In the 2D image, display processed, calibrated data?"}, mode=1
	CheckBox DisplayProcessed2DData,variable= root:Packages:Convert2Dto1D:DisplayProcessed2DData
	CheckBox DisplayProcessed2DData proc=NI1A_CheckProc

	SVAR ColorTableName = root:Packages:Convert2Dto1D:ColorTableName

	PopupMenu ColorTablePopup,pos={170,658},size={107,21},proc=NI1A_PopMenuProc,title="Colors"
	PopupMenu ColorTablePopup,mode=1,popvalue=ColorTableName,value= #"\"Geo32;Geo32_R;Terrain;Terrain_R;Grays;Grays_R;Rainbow;Rainbow_R;YellowHot;YellowHot_R;BlueHot;BlueHot_R;BlueRedGreen;BlueRedGreen_R;RedWhiteBlue;RedWhiteBlue_R;PlanetEarth;PlanetEarth_R;\""
	CheckBox ImageDisplayBeamCenter,variable= root:Packages:Convert2Dto1D:DisplayBeamCenterIn2DGraph, help={"Display beam center on teh image?"}
	CheckBox ImageDisplayBeamCenter proc=NI1A_CheckProc, pos={310,630},size={120,16},title="Display beam center?"
	CheckBox ImageDisplaySectors,variable= root:Packages:Convert2Dto1D:DisplaySectorsIn2DGraph, help={"Display sectors(if selected) in the image?"}
	CheckBox ImageDisplaySectors proc=NI1A_CheckProc, pos={310,645},size={120,16},title="Display sects/Lines?"
	CheckBox ImageDisplayLogScaled,pos={310,660},size={120,16},title="Log Int display?"
	CheckBox ImageDisplayLogScaled,help={"Display image with log(intensity)?"}
	CheckBox ImageDisplayLogScaled,variable= root:Packages:Convert2Dto1D:ImageDisplayLogScaled
	CheckBox ImageDisplayLogScaled proc=NI1A_CheckProc

	CheckBox DisplayQValsOnImage,pos={260,680},size={120,15},title="Image with Q axes?"
	CheckBox DisplayQValsOnImage,help={"Display image with Q values on axis?"}
	CheckBox DisplayQValsOnImage,variable= root:Packages:Convert2Dto1D:DisplayQValsOnImage
	CheckBox DisplayQValsOnImage proc=NI1A_CheckProc

	CheckBox DisplayQvalsWIthGridsOnImg,pos={260,695},size={120,15},title="Img w/Q axes with grids?"
	CheckBox DisplayQvalsWIthGridsOnImg,help={"Display image with Q values on axis and grids?"}
	CheckBox DisplayQvalsWIthGridsOnImg,variable= root:Packages:Convert2Dto1D:DisplayQvalsWIthGridsOnImg
	CheckBox DisplayQvalsWIthGridsOnImg proc=NI1A_CheckProc

	CheckBox DisplayColorScale,pos={10,680},size={120,15},title="Display Color scale?"
	CheckBox DisplayColorScale,help={"Display image with color scale?"}
	CheckBox DisplayColorScale,variable= root:Packages:Convert2Dto1D:DisplayColorScale
	CheckBox DisplayColorScale proc=NI1A_CheckProc

	CheckBox UseUserDefMinMax,pos={10,695},size={120,15},title="User def. Min/Max?"
	CheckBox UseUserDefMinMax,help={"Display image with color scale?"}
	CheckBox UseUserDefMinMax,variable= root:Packages:Convert2Dto1D:UseUserDefMinMax
	CheckBox UseUserDefMinMax proc=NI1A_CheckProc
	NVAR UseUserDefMinMax = root:Packages:Convert2Dto1D:UseUserDefMinMax
	SetVariable UserImageRangeMin,pos={140,680},size={100,16},title="Min. =  ", proc=NI1A_SetVarProcMainPanel
	SetVariable UserImageRangeMin,help={"Select minimum intensity to display?"}, limits={0,inf,0}
	SetVariable UserImageRangeMin,variable= root:Packages:Convert2Dto1D:UserImageRangeMin, disable=!(UseUserDefMinMax)

	SetVariable UserImageRangeMax,pos={140,695},size={100,16},title="Max. = ", proc=NI1A_SetVarProcMainPanel
	SetVariable UserImageRangeMax,help={"Select minimum intensity to display?"}, limits={0,inf,0}
	SetVariable UserImageRangeMax,variable= root:Packages:Convert2Dto1D:UserImageRangeMax, disable=!(UseUserDefMinMax)
	
	NI1A_FixMovieButton()
	//print Exists("Nika_Hook_ModifyMainPanel")
	if(Exists("Nika_Hook_ModifyMainPanel")==6)
		Execute("Nika_Hook_ModifyMainPanel()")
	endif
EndMacro


Function NI1A_FixMovieButton()
	NVAR Movie_FileOpened=root:Packages:Convert2Dto1D:Movie_FileOpened
	NVAR Movie_AppendAutomatically=root:Packages:Convert2Dto1D:Movie_AppendAutomatically
	if(Movie_FileOpened && Movie_AppendAutomatically)
		Button CreateMovie win=NI1A_Convert2Dto1DPanel, title="Creating Movie Auto",fColor=(16386,65535,16385)
	elseif(Movie_FileOpened && !Movie_AppendAutomatically)
		Button CreateMovie win=NI1A_Convert2Dto1DPanel, title="Creating Movie Manual",fColor=(16386,65535,16385)
	endif

end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_SetVarProcMainPanel(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	NVAR SectorsNumSect= root:Packages:Convert2Dto1D:SectorsNumSect
	NVAR SectorsGraphEndAngle= root:Packages:Convert2Dto1D:SectorsGraphEndAngle
	NVAR SectorsSectWidth= root:Packages:Convert2Dto1D:SectorsSectWidth
	NVAR SectorsGraphStartAngle= root:Packages:Convert2Dto1D:SectorsGraphStartAngle
	variable temp
	
	if(stringMatch("LineProf_DistanceFromCenter",ctrlName)||stringMatch("LineProf_Width",ctrlName)||stringMatch("LineProf_LineAzAngle",ctrlName)||stringMatch("LineProf_GIIncAngle",ctrlName)||stringMatch("LineProf_EllipseAR",ctrlName))
		NI1A_LineProfUpdateQ()
		NI1A_AllDrawingsFrom2DGraph()
		NI1A_DrawCenterIn2DGraph()
		NI1A_DrawLinesIn2DGraph()
		NI1A_DrawSectorsIn2DGraph()
		NI1A_LineProf_CreateLP()
		NI1A_LineProf_DisplayLP()
	endif


	if(cmpstr("SectorsNumSect",ctrlName)==0)
		if(SectorsGraphStartAngle>SectorsGraphEndAngle)
			temp = SectorsGraphEndAngle
			SectorsGraphEndAngle=SectorsGraphStartAngle
			SectorsGraphStartAngle=temp
		endif
		SectorsSectWidth = (SectorsGraphEndAngle-SectorsGraphStartAngle)/SectorsNumSect
	endif
	if(cmpstr("SectorsSectWidth",ctrlName)==0)
	
	endif
	if(cmpstr("UserImageRangeMin",ctrlName)==0||cmpstr("UserImageRangeMax",ctrlName)==0)
		NI1A_TopCCDImageUpdateColors(0)
	endif
	if(cmpstr("ProcessNImagesAtTime",ctrlName)==0)
		Button AveConvertNFiles, title="Ave & Convert "+num2str(varNum)+" files", win=NI1A_Convert2Dto1DPanel
	endif
	if(cmpstr("SectorsGraphStartAngle",ctrlName)==0)
		if(SectorsGraphStartAngle>SectorsGraphEndAngle)
			temp = SectorsGraphEndAngle
			SectorsGraphEndAngle=SectorsGraphStartAngle
			SectorsGraphStartAngle=temp
		endif
		SectorsSectWidth = (SectorsGraphEndAngle-SectorsGraphStartAngle)/SectorsNumSect
	endif
	if(cmpstr("SectorsGraphEndAngle",ctrlName)==0)
		if(SectorsGraphStartAngle>SectorsGraphEndAngle)
			temp = SectorsGraphEndAngle
			SectorsGraphEndAngle=SectorsGraphStartAngle
			SectorsGraphStartAngle=temp
		endif
		SectorsSectWidth = (SectorsGraphEndAngle-SectorsGraphStartAngle)/SectorsNumSect
	endif
	string testFunctInfo
	if(cmpstr("SampleThicknFnct",ctrlName)==0)
		testFunctInfo = FunctionInfo(varStr)
		if(strlen(testFunctInfo)<1)
			Abort "This is not existing user function"
		endif
		if(NumberByKey("RETURNTYPE", testFunctInfo, ":" , ";")!=4)
			Abort "This function does not return single variable value"
		endif
		if(NumberByKey("N_PARAMS", testFunctInfo, ":" , ";")!=1 || NumberByKey("PARAM_0_TYPE", testFunctInfo, ":" , ";")!=8192 )
			Abort "This function does not use ONE string input parameter"
		endif
	endif

	if(cmpstr("SampleTransmFnct",ctrlName)==0)
		testFunctInfo = FunctionInfo(varStr)
		if(strlen(testFunctInfo)<1)
			Abort "This is not existing user function"
		endif
		if(NumberByKey("RETURNTYPE", testFunctInfo, ":" , ";")!=4)
			Abort "This function does not return single variable value"
		endif
		if(NumberByKey("N_PARAMS", testFunctInfo, ":" , ";")!=1 || NumberByKey("PARAM_0_TYPE", testFunctInfo, ":" , ";")!=8192 )
			Abort "This function does not use ONE string input parameter"
		endif
	endif
	if(cmpstr("SampleMonitorFnct",ctrlName)==0)
		testFunctInfo = FunctionInfo(varStr)
		if(strlen(testFunctInfo)<1)
			Abort "This is not existing user function"
		endif
		if(NumberByKey("RETURNTYPE", testFunctInfo, ":" , ";")!=4)
			Abort "This function does not return single variable value"
		endif
		if(NumberByKey("N_PARAMS", testFunctInfo, ":" , ";")!=1 || NumberByKey("PARAM_0_TYPE", testFunctInfo, ":" , ";")!=8192 )
			Abort "This function does not use ONE string input parameter"
		endif
	endif
	if(cmpstr("SampleMeasTimeFnct",ctrlName)==0)
		testFunctInfo = FunctionInfo(varStr)
		if(strlen(testFunctInfo)<1)
			Abort "This is not existing user function"
		endif
		if(NumberByKey("RETURNTYPE", testFunctInfo, ":" , ";")!=4)
			Abort "This function does not return single variable value"
		endif
		if(NumberByKey("N_PARAMS", testFunctInfo, ":" , ";")!=1 || NumberByKey("PARAM_0_TYPE", testFunctInfo, ":" , ";")!=8192 )
			Abort "This function does not use ONE string input parameter"
		endif
	endif
	if(cmpstr("EmptyTimeFnct",ctrlName)==0)
		testFunctInfo = FunctionInfo(varStr)
		if(strlen(testFunctInfo)<1)
			Abort "This is not existing user function"
		endif
		if(NumberByKey("RETURNTYPE", testFunctInfo, ":" , ";")!=4)
			Abort "This function does not return single variable value"
		endif
		if(NumberByKey("N_PARAMS", testFunctInfo, ":" , ";")!=1 || NumberByKey("PARAM_0_TYPE", testFunctInfo, ":" , ";")!=8192 )
			Abort "This function does not use ONE string input parameter"
		endif
	endif
	if(cmpstr("EmptyTimeFnct",ctrlName)==0)
		testFunctInfo = FunctionInfo(varStr)
		if(strlen(testFunctInfo)<1)
			Abort "This is not existing user function"
		endif
		if(NumberByKey("RETURNTYPE", testFunctInfo, ":" , ";")!=4)
			Abort "This function does not return single variable value"
		endif
		if(NumberByKey("N_PARAMS", testFunctInfo, ":" , ";")!=1 || NumberByKey("PARAM_0_TYPE", testFunctInfo, ":" , ";")!=8192 )
			Abort "This function does not use ONE string input parameter"
		endif
	endif
	if(cmpstr("BackgTimeFnct",ctrlName)==0)
		testFunctInfo = FunctionInfo(varStr)
		if(strlen(testFunctInfo)<1)
			Abort "This is not existing user function"
		endif
		if(NumberByKey("RETURNTYPE", testFunctInfo, ":" , ";")!=4)
			Abort "This function does not return single variable value"
		endif
		if(NumberByKey("N_PARAMS", testFunctInfo, ":" , ";")!=1 || NumberByKey("PARAM_0_TYPE", testFunctInfo, ":" , ";")!=8192 )
			Abort "This function does not use ONE string input parameter"
		endif
	endif
	if(cmpstr("EmptyMonitorFnct",ctrlName)==0)
		testFunctInfo = FunctionInfo(varStr)
		if(strlen(testFunctInfo)<1)
			Abort "This is not existing user function"
		endif
		if(NumberByKey("RETURNTYPE", testFunctInfo, ":" , ";")!=4)
			Abort "This function does not return single variable value"
		endif
		if(NumberByKey("N_PARAMS", testFunctInfo, ":" , ";")!=1 || NumberByKey("PARAM_0_TYPE", testFunctInfo, ":" , ";")!=8192 )
			Abort "This function does not use ONE string input parameter"
		endif
	endif
	if(cmpstr("SampleCorrectFnct",ctrlName)==0)
		testFunctInfo = FunctionInfo(varStr)
		if(strlen(testFunctInfo)<1)
			Abort "This is not existing user function"
		endif
		if(NumberByKey("RETURNTYPE", testFunctInfo, ":" , ";")!=4)
			Abort "This function does not return single variable value"
		endif
		if(NumberByKey("N_PARAMS", testFunctInfo, ":" , ";")!=1 || NumberByKey("PARAM_0_TYPE", testFunctInfo, ":" , ";")!=8192 )
			Abort "This function does not use ONE string input parameter"
		endif
	endif

	
	if(cmpstr("GI_Sh1_Param1",ctrlName)==0)
		SetVariable GI_Sh1_Param1,limits = {-inf, inf, (varNum/20)}
	endif

	DoWIndow/F NI1A_Convert2Dto1DPanel
	setDataFolder OldDf
End
 //*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_MainSliderProc(ctrlName,sliderValue,event) //: SliderControl
	String ctrlName
	Variable sliderValue
	Variable event	// bit field: bit 0: value set, 1: mouse down, 2: mouse up, 3: mouse moved

	if(cmpstr(ctrlName,"ImageRangeMin")==0 || cmpstr(ctrlName,"ImageRangeMax")==0)
		if(event %& 0x1)	// bit 0, value set
				NVAR ImageRangeMin= root:Packages:Convert2Dto1D:ImageRangeMin
				NVAR ImageRangeMax = root:Packages:Convert2Dto1D:ImageRangeMax
				//assume when user drags this, he/she wants to update the globals...
				NVAR UserImageRangeMin = root:Packages:Convert2Dto1D:UserImageRangeMin
				NVAR UserImageRangeMax = root:Packages:Convert2Dto1D:UserImageRangeMax
				UserImageRangeMin = ImageRangeMin
				UserImageRangeMax = ImageRangeMax
				//now update the main graph... 
				NI1A_TopCCDImageUpdateColors(0)
		endif
	endif
	if(cmpstr(ctrlName,"ImageRangeMinSquare")==0 || cmpstr(ctrlName,"ImageRangeMaxSquare")==0)
		if(event %& 0x1)	// bit 0, value set
				NI1A_SQCCDImageUpdateColors(0)
		endif
	endif
	return 0
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_TopCCDImageUpdateColors(updateRanges)
	variable updateRanges
	
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	//user defined values...
	NVAR UserImageRangeMin = root:Packages:Convert2Dto1D:UserImageRangeMin
	NVAR UserImageRangeMax = root:Packages:Convert2Dto1D:UserImageRangeMax
	NVAR UseUserDefMinMax =  root:Packages:Convert2Dto1D:UseUserDefMinMax
	//
	NVAR ImageRangeMin= root:Packages:Convert2Dto1D:ImageRangeMin
	NVAR ImageRangeMax = root:Packages:Convert2Dto1D:ImageRangeMax
	SVAR ColorTableName=root:Packages:Convert2Dto1D:ColorTableName
	NVAR ImageRangeMinLimit= root:Packages:Convert2Dto1D:ImageRangeMinLimit
	NVAR ImageRangeMaxLimit = root:Packages:Convert2Dto1D:ImageRangeMaxLimit
	string ColorTableNameL
	variable ReverseColorTable
	if(stringMatch(ColorTableName,"*_R"))
		ColorTableNameL = RemoveEnding(ColorTableName  , "_R")
		ReverseColorTable = 1
	else
		ColorTableNameL=ColorTableName
		ReverseColorTable = 0
	endif
	String s= ImageNameList("", ";")
	Variable p1= StrSearch(s,";",0)
	if( p1<0 )
		return 0			// no image in top graph
	endif
	s= s[0,p1-1]
	if(updateRanges&&!UseUserDefMinMax)
		Wave waveToDisplayDis=ImageNameToWaveRef("",s)
		wavestats/Q  waveToDisplayDis
		ImageRangeMin=V_min
		ImageRangeMinLimit=V_min
		ImageRangeMax=V_max
		ImageRangeMaxLimit=V_max
		DoWindow NI1A_Convert2Dto1DPanel
		if(V_Flag)
			Slider ImageRangeMin,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}, win=NI1A_Convert2Dto1DPanel
			Slider ImageRangeMax,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}, win=NI1A_Convert2Dto1DPanel
		endif
	elseif(UseUserDefMinMax)
		ImageRangeMin = UserImageRangeMin
		ImageRangeMax = UserImageRangeMax
	endif
	ModifyImage $(s) ctab= {ImageRangeMin,ImageRangeMax,$ColorTableNameL,ReverseColorTable}
	DoWindow NI1A_Convert2Dto1DPanel
	if(V_Flag)
		PopupMenu MaskImageColor,win=NI1A_Convert2Dto1DPanel, mode=1
	endif
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_TabProc(ctrlName,tabNum)
	String ctrlName
	Variable tabNum

	NVAR UseSampleThickness= root:Packages:Convert2Dto1D:UseSampleThickness
	NVAR UseSampleTransmission= root:Packages:Convert2Dto1D:UseSampleTransmission
	NVAR UseCorrectionFactor= root:Packages:Convert2Dto1D:UseCorrectionFactor
	NVAR UseMask= root:Packages:Convert2Dto1D:UseMask
	NVAR UseDarkField= root:Packages:Convert2Dto1D:UseDarkField
	NVAR UseEmptyField= root:Packages:Convert2Dto1D:UseEmptyField
	NVAR UseSubtractFixedOffset= root:Packages:Convert2Dto1D:UseSubtractFixedOffset
	NVAR UseSampleMeasTime= root:Packages:Convert2Dto1D:UseSampleMeasTime
	NVAR UseEmptyMeasTime= root:Packages:Convert2Dto1D:UseEmptyMeasTime
	NVAR UseDarkMeasTime= root:Packages:Convert2Dto1D:UseDarkMeasTime
	NVAR UsePixelSensitivity= root:Packages:Convert2Dto1D:UsePixelSensitivity
	NVAR UseSubtractFixedOffset= root:Packages:Convert2Dto1D:UseSubtractFixedOffset
	NVAR DoSectorAverages= root:Packages:Convert2Dto1D:DoSectorAverages
	NVAR DezingerCCDData= root:Packages:Convert2Dto1D:DezingerCCDData
	NVAR DezingerEmpty= root:Packages:Convert2Dto1D:DezingerEmpty
	NVAR DezingerDarkField= root:Packages:Convert2Dto1D:DezingerDarkField

	NVAR UseCalib2DData= root:Packages:Convert2Dto1D:UseCalib2DData

	NVAR UseSampleThicknFnct= root:Packages:Convert2Dto1D:UseSampleThicknFnct
	NVAR UseSampleTransmFnct= root:Packages:Convert2Dto1D:UseSampleTransmFnct
	NVAR UseSampleMonitorFnct= root:Packages:Convert2Dto1D:UseSampleMonitorFnct
	NVAR UseSampleMeasTimeFnct= root:Packages:Convert2Dto1D:UseSampleMeasTimeFnct
	NVAR UseEmptyTimeFnct= root:Packages:Convert2Dto1D:UseEmptyTimeFnct
	NVAR UseBackgTimeFnct= root:Packages:Convert2Dto1D:UseBackgTimeFnct
	NVAR UseSampleMonitorFnct= root:Packages:Convert2Dto1D:UseSampleMonitorFnct
	NVAR UseEmptyMonitorFnct= root:Packages:Convert2Dto1D:UseEmptyMonitorFnct
	NVAR UseSampleCorrectFnct= root:Packages:Convert2Dto1D:UseSampleCorrectFnct
	
	NVAR ExpCalib2DData=root:Packages:Convert2Dto1D:ExpCalib2DData
	NVAR RebinCalib2DData=root:Packages:Convert2Dto1D:RebinCalib2DData
	NVAR AppendToNexusFile=root:Packages:Convert2Dto1D:AppendToNexusFile
	SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension

	//other control on the panel...
	CheckBox ReverseBinnedData, disable=!(UseCalib2DData|| StringMatch(DataFileExtension, "canSAS/Nexus")), win=NI1A_Convert2Dto1DPanel	

 
	//tab 0 controls
	SetVariable SampleToDetectorDistance,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable PixleSizeX, disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable PixleSizeY,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable BeamCenterX,disable=(tabNum!=0), win=NI1A_Convert2Dto1DPanel
	SetVariable BeamCenterY,disable=(tabNum!=0), win=NI1A_Convert2Dto1DPanel
	SetVariable HorizontalTilt,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable VerticalTilt,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	TitleBox GeometryDesc,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable Wavelength,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable XrayEnergy,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseSampleThickness,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseSampleTransmission,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseSampleCorrectionFactor,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseSolidAngle,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseDarkField,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseEmptyField,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseSubtractFixedOffset,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseI0ToCalibrate,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseSampleMeasTime,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseEmptyMeasTime,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseDarkMeasTime,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UsePixelSensitivity,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseMOnitorForEF,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable CalibrationFormula,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel

	//tab 1 controls
	CheckBox DoGeometryCorrection,disable=(tabNum!=1||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox DoPolarizationCorrection,disable=(tabNum!=1||UseCalib2DData), win=NI1A_Convert2Dto1DPanel

	//tab 2 controls
	CheckBox UseMask,disable=(tabNum!=2), win=NI1A_Convert2Dto1DPanel
	ListBox MaskListBoxSelection,disable=(tabNum!=2 || !UseMask), win=NI1A_Convert2Dto1DPanel
	Button MaskSelectPath,disable=(tabNum!=2 || !UseMask), win=NI1A_Convert2Dto1DPanel
	//PopupMenu Select2DMaskType,disable=(tabNum!=2 || !UseMask), win=NI1A_Convert2Dto1DPanel
	Button LoadMask,disable=(tabNum!=2 || !UseMask), win=NI1A_Convert2Dto1DPanel
	Button DisplayMaskOnImage,disable=(tabNum!=2 || !UseMask), win=NI1A_Convert2Dto1DPanel
	Button RemoveMaskFromImage,disable=(tabNum!=2 || !UseMask), win=NI1A_Convert2Dto1DPanel
	SetVariable CurrentMaskName,disable=(tabNum!=2 || !UseMask), win=NI1A_Convert2Dto1DPanel
	Button CreateMask,disable=(tabNum!=2 || !UseMask), win=NI1A_Convert2Dto1DPanel
	PopupMenu MaskImageColor,disable=(tabNum!=2 || !UseMask), win=NI1A_Convert2Dto1DPanel
	//tab 1 controls
	NVAR UseI0ToCalibrate=root:Packages:Convert2Dto1D:UseI0ToCalibrate
	NVAR UseMonitorForEF= root:Packages:Convert2Dto1D:UseMonitorForEF
	SetVariable SampleThickness,disable=(tabNum!=1 || !UseSampleThickness || UseSampleThicknFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseSampleThicknFnct,disable=(tabNum!=1 || !UseSampleThickness||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable SampleThicknFnct,disable=(tabNum!=1 || !UseSampleThickness || !UseSampleThicknFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel

	SetVariable SampleTransmission,disable=(tabNum!=1 || !UseSampleTransmission || UseSampleTransmFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseSampleTransmFnct,disable=(tabNum!=1 || !UseSampleTransmission||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable SampleTransmFnct,disable=(tabNum!=1 || !UseSampleTransmission || !UseSampleTransmFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel

	SetVariable SampleI0,disable=(tabNum!=1 || (!UseI0ToCalibrate && !UseMonitorForEF) || UseSampleMonitorFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseSampleMonitorFnct,disable=(tabNum!=1 || (!UseI0ToCalibrate && !UseMonitorForEF)||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable SampleMonitorFnct,disable=(tabNum!=1 || (!UseI0ToCalibrate && !UseMonitorForEF) || !UseSampleMonitorFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel

	SetVariable SampleMeasurementTime,disable=(tabNum!=1 || !UseSampleMeasTime || UseSampleMeasTimeFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseSampleMeasTimeFnct,disable=(tabNum!=1 || !UseSampleMeasTime||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable SampleMeasTimeFnct,disable=(tabNum!=1 || !UseSampleMeasTime || !UseSampleMeasTimeFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel

	SetVariable EmptyMeasurementTime,disable=(tabNum!=1 || !UseEmptyMeasTime || UseEmptyTimeFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseEmptyTimeFnct,disable=(tabNum!=1 || !UseEmptyMeasTime||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable EmptyTimeFnct,disable=(tabNum!=1 || !UseEmptyMeasTime || !UseEmptyTimeFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel

	SetVariable BackgroundMeasTime,disable=(tabNum!=1 || !UseDarkMeasTime || UseBackgTimeFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseBackgTimeFnct,disable=(tabNum!=1 || !UseDarkMeasTime||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable BackgTimeFnct,disable=(tabNum!=1 || !UseDarkMeasTime || !UseBackgTimeFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel

	SetVariable CorrectionFactor,disable=(tabNum!=1 || !UseCorrectionFactor || UseSampleCorrectFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseSampleCorrectFnct,disable=(tabNum!=1 || !UseCorrectionFactor||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable SampleCorrectFnct,disable=(tabNum!=1 || !UseCorrectionFactor || !UseSampleCorrectFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel

	SetVariable EmptyI0,disable=(tabNum!=1 ||  (!UseMonitorForEF) || UseEmptyMonitorFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseEmptyMonitorFnct,disable=(tabNum!=1 || (!UseMonitorForEF)||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable EmptyMonitorFnct,disable=(tabNum!=1 || (!UseMonitorForEF) || !UseEmptyMonitorFnct||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable SubtractFixedOffset,disable=(tabNum!=1 || !UseSubtractFixedOffset||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	//tab 3 controls
	CheckBox DezingerCCDData,disable=(tabNum!=1||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox DezingerEmpty,disable=(tabNum!=3 || !UseEmptyField||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox DezingerDark,disable=(tabNum!=3 || !UseDarkField||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	if((DezingerCCDData || DezingerEmpty || DezingerDarkField) && tabNum==1&& !UseCalib2DData)
	NVAR UseLineProfile=root:Packages:Convert2Dto1D:UseLineProfile
			SetVariable DezingerRatio, disable=0, win=NI1A_Convert2Dto1DPanel
			SetVariable DezingerHowManyTimes, disable=0, win=NI1A_Convert2Dto1DPanel
	else
			SetVariable DezingerRatio, disable=1, win=NI1A_Convert2Dto1DPanel
			SetVariable DezingerHowManyTimes, disable=1, win=NI1A_Convert2Dto1DPanel
	endif
	PopupMenu SelectBlank2DDataType,disable=(tabNum!=3||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	ListBox Select2DMaskDarkWave,disable=(tabNum!=3 || !(UseEmptyField || UseDarkField || UsePixelSensitivity)||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	if(tabNum==3)
		NI1A_UpdateEmptyDarkListBox()
	endif
	Button LoadEmpty,disable=(tabNum!=3 || !UseEmptyField||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	Button LoadDarkField,disable=(tabNum!=3 || !UseDarkField||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	Button LoadPixel2DSensitivity,disable=(tabNum!=3 || !UsePixelSensitivity||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable CurrentEmptyName,disable=(tabNum!=3 || !UseEmptyField||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable CurrentDarkFieldName,disable=(tabNum!=3 || !UseDarkField||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable CurrentPixSensFileName,disable=(tabNum!=3 || !UsePixelSensitivity||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	Button SelectMaskDarkPath,disable=(tabNum!=3 || !(UseEmptyField || UseDarkField || UsePixelSensitivity)||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable EmptyDarkNameMatchStr,disable=(tabNum!=3 || !(UseEmptyField || UseDarkField || UsePixelSensitivity)||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	//tab 4 controls
	NVAR UseQvector=root:Packages:Convert2Dto1D:UseQvector
	NVAR UseDspacing=root:Packages:Convert2Dto1D:UseDspacing
	NVAR UseTheta=root:Packages:Convert2Dto1D:UseTheta
	NVAR QvectorMaxNumPnts=root:Packages:Convert2Dto1D:QvectorMaxNumPnts
	NVAR UseSectors=root:Packages:Convert2Dto1D:UseSectors
	NVAR UseLineProfile=root:Packages:Convert2Dto1D:UseLineProfile

	CheckBox UseSectors,disable=(tabNum!=4), win=NI1A_Convert2Dto1DPanel
	CheckBox UseQvector,disable=(tabNum!=4||!UseSectors), win=NI1A_Convert2Dto1DPanel
	CheckBox UseDspacing,disable=(tabNum!=4||!UseSectors), win=NI1A_Convert2Dto1DPanel
	CheckBox UseTheta,disable=(tabNum!=4||!UseSectors), win=NI1A_Convert2Dto1DPanel
	CheckBox UseDistanceFromCenter,disable=(tabNum!=4||!UseSectors), win=NI1A_Convert2Dto1DPanel

	SetVariable UserQMin,disable=(tabNum!=4 || !UseQvector||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable UserQMax,disable=(tabNum!=4 || !UseQvector||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable UserThetaMin,disable=(tabNum!=4 || !UseTheta||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable UserThetaMax,disable=(tabNum!=4 || !UseTheta||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable UserDMin,disable=(tabNum!=4 || !UseDspacing||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable UserDMax,disable=(tabNum!=4 || !UseDspacing||!UseSectors), win=NI1A_Convert2Dto1DPanel

	CheckBox QbinningLogarithmic,disable=(tabNum!=4||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable QbinPoints,disable=(tabNum!=4 || QvectorMaxNumPnts||!UseSectors), win=NI1A_Convert2Dto1DPanel
	CheckBox QvectorMaxNumPnts,disable=(tabNum!=4||!UseSectors), win=NI1A_Convert2Dto1DPanel
	CheckBox DoCircularAverage,disable=(tabNum!=4||!UseSectors), win=NI1A_Convert2Dto1DPanel
	//the nextset will be used also in Line profile, so make it appear also when that is selected on its tab...
	CheckBox StoreDataInIgor,disable=!((tabNum==4&&UseSectors)||(tabNum==6&&UseLineProfile)), win=NI1A_Convert2Dto1DPanel
	CheckBox OverwriteDataIfExists,disable=!((tabNum==4&&UseSectors)||(tabNum==6&&UseLineProfile)), win=NI1A_Convert2Dto1DPanel
	CheckBox ExportDataOutOfIgor,disable=!((tabNum==4&&UseSectors)||(tabNum==6&&UseLineProfile)), win=NI1A_Convert2Dto1DPanel 
	CheckBox SaveGSASdata,disable=(tabNum!=4 || !UseTheta||!UseSectors), win=NI1A_Convert2Dto1DPanel

	CheckBox AppendToNexusFile,disable=!((tabNum==4&&UseSectors)||(tabNum==6&&UseLineProfile)||(tabNum==7&&ExpCalib2DData)), win=NI1A_Convert2Dto1DPanel
	CheckBox Use2DdataName,disable= !((tabNum==4&&UseSectors)||(tabNum==6&&UseLineProfile)||(tabNum==7&&ExpCalib2DData&&!AppendToNexusFile)), win=NI1A_Convert2Dto1DPanel
	Button CreateOutputPath,disable=(!((tabNum==4&&UseSectors)||(tabNum==6&&UseLineProfile)||(tabNum==7&&ExpCalib2DData&&!AppendToNexusFile))), win=NI1A_Convert2Dto1DPanel
	SetVariable OutputFileName,disable=(!((tabNum==4&&UseSectors)||(tabNum==6&&UseLineProfile)||(tabNum==7&&ExpCalib2DData&&!AppendToNexusFile))), win=NI1A_Convert2Dto1DPanel

	CheckBox DisplayDataAfterProcessing,disable= !((tabNum==4&&UseSectors)||(tabNum==6&&UseLineProfile)), win=NI1A_Convert2Dto1DPanel	
	//end of common block for line profiel and secotrs
	CheckBox DoSectorAverages,disable=(tabNum!=4||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable NumberOfSectors,disable=(tabNum!=4 || !DoSectorAverages||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable SectorsStartAngle,disable=(tabNum!=4 || !DoSectorAverages||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable SectorsHalfWidth,disable=(tabNum!=4 || !DoSectorAverages||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable SectorsStepInAngle,disable=(tabNum!=4 || !DoSectorAverages||!UseSectors), win=NI1A_Convert2Dto1DPanel
	//tab 5 controls
	Button CreateSectorGraph,disable=(tabNum!=5), win=NI1A_Convert2Dto1DPanel
	SetVariable SectorsNumSect,disable=(tabNum!=5), win=NI1A_Convert2Dto1DPanel
	SetVariable SectorsSectWidth,disable=(tabNum!=5), win=NI1A_Convert2Dto1DPanel
	SetVariable SectorsGraphStartAngle,disable=(tabNum!=5), win=NI1A_Convert2Dto1DPanel
	SetVariable SectorsGraphEndAngle,disable=(tabNum!=5), win=NI1A_Convert2Dto1DPanel
	CheckBox A2DmaskImage,disable=(tabNum!=5), win=NI1A_Convert2Dto1DPanel
	CheckBox SectorsUseRAWData,disable=(tabNum!=5), win=NI1A_Convert2Dto1DPanel
	//here alco check, if Corrected data are meaningful, else make grey next button...
	Variable CorrImgExists=exists("root:Packages:Convert2Dto1D:Calibrated2DDataSet")
	if(!CorrImgExists)
		NVAR SectorsUseCorrData=root:Packages:Convert2Dto1D:SectorsUseCorrData
		NVAR SectorsUseRAWData=root:Packages:Convert2Dto1D:SectorsUseRAWData
		SectorsUseCorrData=0
		SectorsUseRAWData=1
	endif
	CheckBox SectorsUseCorrData,disable=(tabNum!=5 || !CorrImgExists), win=NI1A_Convert2Dto1DPanel

// tab 6 controls, GI geometry
	SVAR KnWCT=root:Packages:Convert2Dto1D:LineProf_CurveType
	CheckBox UseLineProfile,disable=(tabNum!=6), win=NI1A_Convert2Dto1DPanel
	PopupMenu LineProf_CurveType,disable=(tabNum!=6||!UseLineProfile), win=NI1A_Convert2Dto1DPanel
	CheckBox LineProf_UseBothHalfs,disable=(tabNum!=6||!UseLineProfile||stringMatch(KnWCT,"Angle Line")), win=NI1A_Convert2Dto1DPanel

	CheckBox LineProfileUseRAW,disable=(tabNum!=6||!UseLineProfile), win=NI1A_Convert2Dto1DPanel
	CheckBox LineProfileUseCorrData,disable=(tabNum!=6||!UseLineProfile), win=NI1A_Convert2Dto1DPanel

	SetVariable LineProf_DistanceFromCenter,disable=(tabNum!=6||!UseLineProfile), win=NI1A_Convert2Dto1DPanel
	SetVariable LineProf_DistanceQ,disable=(tabNum!=6||!UseLineProfile), win=NI1A_Convert2Dto1DPanel
	SetVariable LineProf_Width,disable=(tabNum!=6||!UseLineProfile), win=NI1A_Convert2Dto1DPanel
	SetVariable LineProf_WidthQ,disable=(tabNum!=6||!UseLineProfile), win=NI1A_Convert2Dto1DPanel
	
	SetVariable LineProf_LineAzAngle,disable=(tabNum!=6||!UseLineProfile||!stringMatch(KnWCT,"Angle Line")), win=NI1A_Convert2Dto1DPanel
	SetVariable LineProf_EllipseAR,disable=(tabNum!=6||!UseLineProfile||!stringMatch(KnWCT,"Ellipse")), win=NI1A_Convert2Dto1DPanel
	SetVariable LineProf_GIIncAngle,disable=(tabNum!=6||!UseLineProfile||(!stringMatch(KnWCT,"GISAXS_FixQy")&&!stringMatch(KnWCT,"GI_Horizontal line")&&!stringMatch(KnWCT,"GI_Vertical line"))), win=NI1A_Convert2Dto1DPanel

//tab 7 controls
	CheckBox ExpCalib2DData,disable=(tabNum!=7), win=NI1A_Convert2Dto1DPanel
	CheckBox InclMaskCalib2DData,disable=(tabNum!=7||!ExpCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox UseQxyCalib2DData,disable=(tabNum!=7||!ExpCalib2DData), win=NI1A_Convert2Dto1DPanel
	CheckBox RebinCalib2DData,disable=(tabNum!=7||!ExpCalib2DData), win=NI1A_Convert2Dto1DPanel
	PopupMenu RebinCalib2DDataToPnts,disable=(tabNum!=7||!ExpCalib2DData||!RebinCalib2DData), win=NI1A_Convert2Dto1DPanel
	PopupMenu Calib2DDataOutputFormat,disable=(tabNum!=7||!ExpCalib2DData || AppendToNexusFile), win=NI1A_Convert2Dto1DPanel

	
	return 0
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_PanelSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName


	if(cmpstr("BeamCenterX",ctrlName)==0)
		NI1A_DoDrawingsInto2DGraph()
		NI1U_UpdateQAxisInImage()
	endif
	if(cmpstr("BeamCenterY",ctrlName)==0)
		NI1A_DoDrawingsInto2DGraph()
		NI1U_UpdateQAxisInImage()
	endif
	if(cmpstr("XrayEnergy",ctrlName)==0)
		NVAR Wavelength= root:Packages:Convert2Dto1D:Wavelength
		Wavelength = 12.398424437/VarNum
		//changed SDD, need to do anything?Wavelength
		NI1U_UpdateQAxisInImage()
	endif
	if(cmpstr("Wavelength",ctrlName)==0)
		NVAR XrayEnergy= root:Packages:Convert2Dto1D:XrayEnergy
		XrayEnergy = 12.398424437/VarNum
		NI1U_UpdateQAxisInImage()
	endif
	if(cmpstr("SampleToDetectorDistance",ctrlName)==0)
		//changed SDD, need to do anything?
		NI1U_UpdateQAxisInImage()
	endif	

	if(cmpstr("SampleNameMatchStr",ctrlName)==0)
		//changed SDD, need to do anything?
		NI1A_UpdateDataListBox()
	endif	

	if(cmpstr("EmptyDarkNameMatchStr",ctrlName)==0)
		//changed SDD, need to do anything?
		NI1A_UpdateEmptyDarkListBox()
	endif	


	if(cmpstr("NumberOfSectors",ctrlName)==0)
		NVAR tr =root:Packages:Convert2Dto1D:NumberOfSectors
		tr=IN2G_roundDecimalPlaces(tr,1)
		NI1A_DoDrawingsInto2DGraph()
	endif	
	if(cmpstr("SectorsStartAngle",ctrlName)==0)
		NVAR tr =root:Packages:Convert2Dto1D:SectorsStartAngle
		tr=IN2G_roundDecimalPlaces(tr,1)
		NI1A_DoDrawingsInto2DGraph()
	endif	
	if(cmpstr("SectorsHalfWidth",ctrlName)==0)
		NVAR tr =root:Packages:Convert2Dto1D:SectorsHalfWidth
		tr=IN2G_roundDecimalPlaces(tr,1)
		NI1A_DoDrawingsInto2DGraph()
	endif	
	if(cmpstr("SectorsStepInAngle",ctrlName)==0)
		NVAR tr =root:Packages:Convert2Dto1D:SectorsStepInAngle
		tr=IN2G_roundDecimalPlaces(tr,1)
		NI1A_DoDrawingsInto2DGraph()
	endif	
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_ListBoxProc(ctrlName,row,col,event)
	String ctrlName
	Variable row
	Variable col
	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
					//5=cell select with shift key, 6=begin edit, 7=end

	if(cmpstr("MaskListBoxSelection",ctrlName)==0)
	
	endif
	return 0
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_PolarCorCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
				NVAR Use1DPolarizationCor = root:Packages:Convert2Dto1D:Use1DPolarizationCor
				NVAR Use2DPolarizationCor = root:Packages:Convert2Dto1D:Use2DPolarizationCor
				if(stringmatch(cba.ctrlName,"Use1DPolarizationCor"))
					Use2DPolarizationCor=!Use1DPolarizationCor
				endif
				if(stringmatch(cba.ctrlName,"Use2DPolarizationCor"))
					Use1DPolarizationCor=!Use2DPolarizationCor
				endif
				
			break
	endswitch

	return 0
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

WIndow NI1A_PolCorPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1/W=(345,282,645,482) as "Polarization Correction"
	Dowindow/C NI1A_PolCorPanel
	SetDrawLayer UserBack
	SetDrawEnv fsize= 14,fstyle= 3,textrgb= (0,0,65535)
	DrawText 23,31,"Polarization correction settings"
	SetDrawEnv fstyle= 1
	DrawText 13,150,"For 2D Pol Corr:"
	DrawText 13,170,"0 deg ... S. Pol. plane horizontal on det."
	DrawText 13,190,"90 deg ... S. Pol. plane vertical on det."
	DrawRect 250,135,280,165
	SetDrawEnv linethick= 2
	DrawLine 265,150,280,150
	DrawRect 250,168,280,198
	SetDrawEnv linethick= 2
	DrawLine 265,168,265,183
	CheckBox Use1DPolarizationCor,pos={15,40},size={145,14},proc=NI1A_PolarCorCheckProc,title="Unpolarized radiation (desktop)"
	CheckBox Use1DPolarizationCor,variable= root:Packages:Convert2Dto1D:Use1DPolarizationCor,mode=1, help={"Select to use with unpolarized radiation such as from tube source"}
	CheckBox Use2DPolarizationCor,pos={16,65},size={145,14},proc=NI1A_PolarCorCheckProc,title="Polarized radiation (synchrotrons)"
	CheckBox Use2DPolarizationCor,variable= root:Packages:Convert2Dto1D:Use2DPolarizationCor,mode=1, help={"Use to apply Polarization correction for linearly polarized radiation"}
	SetVariable TwoDPolarizFract,pos={13,88},size={240,16},title="Sigma : Pi ratio (~1 usually)"
	SetVariable TwoDPolarizFract,value= root:Packages:Convert2Dto1D:TwoDPolarizFract, limits={0,1,0.05}, help={"1 for fully polarized (usual, synchrotrons)"}
	SetVariable a2DPolCorrStarAngle,pos={13,110},size={240,16},title="Sigma Polar. Plane [deg]"
	SetVariable a2DPolCorrStarAngle,value= root:Packages:Convert2Dto1D:StartAngle2DPolCor, limits={0,180,90}, help={"0 for polarization horizontally on detector, 90 vertically"}
EndMacro
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_LineProfUpdateQ()


		NVAR LineProf_DistanceFromCenter=root:Packages:Convert2Dto1D:LineProf_DistanceFromCenter
		NVAR LineProf_Width=root:Packages:Convert2Dto1D:LineProf_Width
		NVAR LineProf_DistanceQ=root:Packages:Convert2Dto1D:LineProf_DistanceQ
		NVAR LineProf_WidthQ=root:Packages:Convert2Dto1D:LineProf_WidthQ
		NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance		//in millimeters
		NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength							//in A
		NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
		NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
		NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
		NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
		NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt
		NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt
		NVAR LineProf_UseBothHalfs=root:Packages:Convert2Dto1D:LineProf_UseBothHalfs

		NVAR LineProf_LineAzAngle=root:Packages:Convert2Dto1D:LineProf_LineAzAngle
		NVAR LineProf_GIIncAngle=root:Packages:Convert2Dto1D:LineProf_GIIncAngle
		NVAR LineProf_EllipseAR=root:Packages:Convert2Dto1D:LineProf_EllipseAR
		
		SVAR LineProf_CurveType=root:Packages:Convert2Dto1D:LineProf_CurveType
		variable distance, distanceW1, distancew2
		if(stringMatch(LineProf_CurveType,"Horizontal Line") || stringMatch(LineProf_CurveType,"GI_Horizontal line"))
			distance=NI1T_TiltedToCorrectedR( LineProf_DistanceFromCenter*PixelSizeY ,SampleToCCDDistance,VerticalTilt)		//in mm 
			distancew1=NI1T_TiltedToCorrectedR( (LineProf_DistanceFromCenter+LineProf_Width)*PixelSizeY ,SampleToCCDDistance,VerticalTilt)		//in mm 
			distancew2=NI1T_TiltedToCorrectedR(  (LineProf_DistanceFromCenter-LineProf_Width)*PixelSizeY ,SampleToCCDDistance,VerticalTilt)		//in mm 
		endif
		if(stringMatch(LineProf_CurveType,"Vertical Line")|| stringMatch(LineProf_CurveType,"Ellipse")|| stringMatch(LineProf_CurveType,"Angle Line"))
			distance=NI1T_TiltedToCorrectedR( LineProf_DistanceFromCenter*PixelSizeX ,SampleToCCDDistance,HorizontalTilt)		//in mm 
			distancew1=NI1T_TiltedToCorrectedR(  (LineProf_DistanceFromCenter+LineProf_Width)*PixelSizeX ,SampleToCCDDistance,HorizontalTilt)		//in mm 
			distancew2=NI1T_TiltedToCorrectedR(  (LineProf_DistanceFromCenter-LineProf_Width)*PixelSizeX ,SampleToCCDDistance,HorizontalTilt)		//in mm 
		endif
		variable theta=atan(distance/SampleToCCDDistance)/2
		variable thetaw1=atan(distancew1/SampleToCCDDistance)/2
		variable thetaw2=atan(distancew2/SampleToCCDDistance)/2
		variable Qval= ((4*pi)/Wavelength)*sin(theta)
		variable Qvalw1= ((4*pi)/Wavelength)*sin(thetaw1)
		variable Qvalw2= ((4*pi)/Wavelength)*sin(thetaw2)

		if( stringMatch(LineProf_CurveType,"GI_Vertical line"))
			Qval = NI1GI_CalculateQxyz(LineProf_DistanceFromCenter+BeamCenterX,BeamCenterY,"Y")
			Qvalw1 = NI1GI_CalculateQxyz(LineProf_DistanceFromCenter+BeamCenterX+LineProf_Width,BeamCenterY,"Y")
			Qvalw2 = NI1GI_CalculateQxyz(LineProf_DistanceFromCenter+BeamCenterX-LineProf_Width,BeamCenterY,"Y")
		endif
		if( stringMatch(LineProf_CurveType,"GI_Horizontal line"))
			Qval = NI1GI_CalculateQxyz(BeamCenterX,BeamCenterY-LineProf_DistanceFromCenter,"Z")
			Qvalw1 = NI1GI_CalculateQxyz(BeamCenterX,BeamCenterY-LineProf_Width-LineProf_DistanceFromCenter,"Z")
			Qvalw2 = NI1GI_CalculateQxyz(BeamCenterX,BeamCenterY+LineProf_Width-LineProf_DistanceFromCenter,"Z")
		endif
		
		LineProf_DistanceQ=Qval
		LineProf_WidthQ=abs(Qvalw1-Qvalw2)
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_CheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	string oldDf=GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D

	NVAR UseSampleThickness= root:Packages:Convert2Dto1D:UseSampleThickness
	NVAR UseSampleTransmission= root:Packages:Convert2Dto1D:UseSampleTransmission
	NVAR UseCorrectionFactor= root:Packages:Convert2Dto1D:UseCorrectionFactor
	NVAR UseMask= root:Packages:Convert2Dto1D:UseMask
	NVAR UseDarkField= root:Packages:Convert2Dto1D:UseDarkField
	NVAR UseEmptyField= root:Packages:Convert2Dto1D:UseEmptyField
	NVAR UseSubtractFixedOffset= root:Packages:Convert2Dto1D:UseSubtractFixedOffset
	NVAR UseSampleMeasTime= root:Packages:Convert2Dto1D:UseSampleMeasTime
	NVAR UseEmptyMeasTime= root:Packages:Convert2Dto1D:UseEmptyMeasTime
	NVAR UseDarkMeasTime= root:Packages:Convert2Dto1D:UseDarkMeasTime
	NVAR UsePixelSensitivity= root:Packages:Convert2Dto1D:UsePixelSensitivity
	NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
	NVAR UseMonitorForEF = root:Packages:Convert2Dto1D:UseMonitorForEF
	NVAR UseQvector = root:Packages:Convert2Dto1D:UseQvector
	NVAR UseDspacing = root:Packages:Convert2Dto1D:UseDspacing
	NVAR UseTheta = root:Packages:Convert2Dto1D:UseTheta
	NVAR UseDistanceFromCenter = root:Packages:Convert2Dto1D:UseDistanceFromCenter
	NVAR UseCalib2DData = root:Packages:Convert2Dto1D:UseCalib2DData
	
	NVAR SkipBadFiles=root:Packages:Convert2Dto1D:SkipBadFiles

	NVAR SectorsUseRAWData= root:Packages:Convert2Dto1D:SectorsUseRAWData
	NVAR SectorsUseCorrData= root:Packages:Convert2Dto1D:SectorsUseCorrData
	NVAR LineProfileUseRAW= root:Packages:Convert2Dto1D:LineProfileUseRAW
	NVAR LineProfileUseCorrData= root:Packages:Convert2Dto1D:LineProfileUseCorrData
	NVAR TrimEndOfName=root:Packages:Convert2Dto1D:TrimEndOfName
	NVAR TrimFrontOfName=root:Packages:Convert2Dto1D:TrimFrontOfName


	NVAR UseCalib2DData=root:Packages:Convert2Dto1D:UseCalib2DData
	NVAR ExpCalib2DData=root:Packages:Convert2Dto1D:ExpCalib2DData
	NVAR RebinCalib2DData=root:Packages:Convert2Dto1D:RebinCalib2DData
	NVAR InclMaskCalib2DData=root:Packages:Convert2Dto1D:InclMaskCalib2DData
	NVAR AppendToNexusFile=root:Packages:Convert2Dto1D:AppendToNexusFile

	SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension


	if(StringMatch(ctrlName,"RebinCalib2DData"))
		PopupMenu RebinCalib2DDataToPnts,disable=(!RebinCalib2DData), win=NI1A_Convert2Dto1DPanel
	endif
	if(StringMatch(ctrlName,"InclMaskCalib2DData"))
		if(!UseMask)
			InclMaskCalib2DData =0
			DoAlert 0, "Mask is not used, cannot include it in the export file"
		endif
	endif
	if(StringMatch("TrimFrontOfName",ctrlName))
		if(checked)
			TrimEndOfName=0
		else
			TrimEndOfName=1
		endif
	endif
	if(StringMatch("TrimEndOfName",ctrlName))
		if(checked)
			TrimFrontOfName=0
		else
			TrimFrontOfName=0
		endif
	endif
	if(stringmatch("AppendToNexusFile",ctrlName))
		if(!StringMatch(DataFileExtension, "Nexus"))
			DoALert /T="Cannot use this", 0, "Appending to original file can be done ONLY for Nexus file"
			AppendToNexusFile = 0
		endif
		COntrolInfo/W=NI1A_Convert2Dto1DPanel Convert2Dto1DTab
		NI1A_TabProc("",V_Value)
	endif
	
	
	if(stringmatch("ExpCalib2DData",ctrlName))
		if(ExpCalib2DData&&UseCalib2DData)
			DoALert /T="Careful on this", 0, "Loading 2D Calibrated data and exporting them at the same time. You can overwrite your 2D data. Make sure you use different output formats or paths!"
		endif
		NI1A_TabProc("",7)
	endif
	if(StringMatch("UseCalib2DData",ctrlName))
		SVAR ListOfKnownExtensions = root:Packages:Convert2Dto1D:ListOfKnownExtensions
		SVAR DataFileExtension = root:Packages:Convert2Dto1D:DataFileExtension
		SVAR ListOfKnownCalibExtensions = root:Packages:Convert2Dto1D:ListOfKnownCalibExtensions
		if(checked)
			DataFileExtension = stringfromlist(0,ListOfKnownCalibExtensions)
			PopupMenu Select2DDataType,win=NI1A_Convert2Dto1DPanel, popvalue=DataFileExtension,value= #"root:Packages:Convert2Dto1D:ListOfKnownCalibExtensions", mode=2
		else
			DataFileExtension = stringfromlist(0,ListOfKnownExtensions)
			PopupMenu Select2DDataType,win=NI1A_Convert2Dto1DPanel, popvalue=DataFileExtension,value= #"root:Packages:Convert2Dto1D:ListOfKnownExtensions", mode=2				
		endif
		CheckBox ReverseBinnedData, disable=!(UseCalib2DData|| StringMatch(DataFileExtension, "canSAS/Nexus")), win=NI1A_Convert2Dto1DPanel	
		if(ExpCalib2DData&&UseCalib2DData)
			DoALert /T="Careful on this", 0, "Loading 2D Calibrated data and exporting them at the same time. You can overwrite your 2D data. Make sure you use different output formats or paths!"
		endif
		NI1A_TabProc("",0)
		NI1A_UpdateDataListBox()
	endif


	if(StringMatch("LineProfileUseRAW",ctrlName))
		LineProfileUseCorrData=!LineProfileUseRAW
		NI1A_LineProf_Update()
	endif
	if(StringMatch("LineProfileUseCorrData",ctrlName))
		LineProfileUseRAW=!LineProfileUseCorrData
		NI1A_LineProf_Update()
	endif

	NVAR QnoGrids= root:Packages:Convert2Dto1D:DisplayQValsOnImage
	NVAR Qgrids = root:Packages:Convert2Dto1D:DisplayQvalsWIthGridsOnImg

	if(StringMatch("DisplayQValsOnImage",ctrlName))
		if(checked)
			Qgrids=0
			DoWIndow CCDImageToConvertFig
			if(!V_flag)
				return 0
			endif
			NI1G_AddQAxisToImage(0)
		else
			NI1G_RemoveQAxisToImage(1)
		endif
	endif
	if(StringMatch("DisplayQvalsWIthGridsOnImg",ctrlName))
		if(checked)
			QnoGrids=0
			DoWIndow CCDImageToConvertFig
			if(!V_flag)
				return 0
			endif
			NI1G_AddQAxisToImage(1)
		else
			NI1G_RemoveQAxisToImage(1)
		endif
	endif

	if(StringMatch("DisplayColorScale",ctrlName))
		NI1A_DoDrawingsInto2DGraph()
	endif


	if(StringMatch("LineProf_UseBothHalfs",ctrlName))
		NI1A_LineProf_Update()
	endif

	if(StringMatch("UseUserDefMinMax",ctrlName))
		if(!checked)
			NI1A_TopCCDImageUpdateColors(1)
		else
			NI1A_TopCCDImageUpdateColors(0)
		endif
	endif

	if(StringMatch("SectorsUseRAWData",ctrlName))
		SectorsUseCorrData=!SectorsUseRAWData
	endif
	if(StringMatch("SectorsUseCorrData",ctrlName))
		SectorsUseRAWData=!SectorsUseCorrData
	endif

	if(cmpstr("SkipBadFiles",ctrlName)==0)
		SetVariable MaxIntForBadFile,disable=(!SkipBadFiles)
	endif

	if(cmpstr("UseUserDefMinMax",ctrlName)==0)
		NVAR UseUserDefMinMax =  root:Packages:Convert2Dto1D:UseUserDefMinMax
		SetVariable UserImageRangeMin,disable=!(UseUserDefMinMax)
		SetVariable UserImageRangeMax, disable=!(UseUserDefMinMax)
	endif
	
	NVAR DisplayRaw2DData=root:Packages:Convert2Dto1D:DisplayRaw2DData
	NVAR DisplayProcessed2DData=root:Packages:Convert2Dto1D:DisplayProcessed2DData
	
	if(cmpstr("DisplayRaw2DData",ctrlName)==0)
		DisplayProcessed2DData=!DisplayRaw2DData
		NI1A_DisplayTheRight2DWave()
		NI1A_DoDrawingsInto2DGraph()
	endif
	if(cmpstr("DisplayProcessed2DData",ctrlName)==0)
		DisplayRaw2DData = !DisplayProcessed2DData
		NI1A_DisplayTheRight2DWave()
		NI1A_DoDrawingsInto2DGraph()
	endif

	if(cmpstr("UseQvector",ctrlName)==0)
		//UseQvector=0
		UseDspacing=0
		UseTheta=0
		UseDistanceFromCenter=0
		SetVariable UserQMin,disable=(!UseQvector)
		SetVariable UserQMax,disable=( !UseQvector)
		SetVariable UserThetaMin,disable=( !UseTheta)
		SetVariable UserThetaMax,disable=( !UseTheta)
		SetVariable UserDMin,disable=( !UseDspacing)
		SetVariable UserDMax,disable=( !UseDspacing)
		Checkbox SaveGSASdata, disable=(!UseTheta)
	endif
	if(cmpstr("UseDspacing",ctrlName)==0)
		UseQvector=0
		//UseDspacing=0
		UseTheta=0
		UseDistanceFromCenter=0
		SetVariable UserQMin,disable=(!UseQvector)
		SetVariable UserQMax,disable=( !UseQvector)
		SetVariable UserThetaMin,disable=( !UseTheta)
		SetVariable UserThetaMax,disable=( !UseTheta)
		SetVariable UserDMin,disable=( !UseDspacing)
		SetVariable UserDMax,disable=( !UseDspacing)
		Checkbox SaveGSASdata, disable=(!UseTheta)
	endif
	if(cmpstr("UseTheta",ctrlName)==0)
		UseQvector=0
		UseDspacing=0
		//UseTheta=0
		UseDistanceFromCenter=0
		SetVariable UserQMin,disable=(!UseQvector)
		SetVariable UserQMax,disable=( !UseQvector)
		SetVariable UserThetaMin,disable=( !UseTheta)
		SetVariable UserThetaMax,disable=( !UseTheta)
		SetVariable UserDMin,disable=( !UseDspacing)
		SetVariable UserDMax,disable=( !UseDspacing)
		Checkbox SaveGSASdata, disable=(!UseTheta)
	endif
	if(cmpstr("UseDistanceFromCenter",ctrlName)==0)
		UseQvector=0
		UseDspacing=0
		UseTheta=0
		//UseDistanceFromCenter=0
		SetVariable UserQMin,disable=(!UseQvector)
		SetVariable UserQMax,disable=( !UseQvector)
		SetVariable UserThetaMin,disable=( !UseTheta)
		SetVariable UserThetaMax,disable=( !UseTheta)
		SetVariable UserDMin,disable=( !UseDspacing)
		SetVariable UserDMax,disable=( !UseDspacing)
		Checkbox SaveGSASdata, disable=(!UseTheta)
	endif


	if(cmpstr("DoCircularAverage",ctrlName)==0)
		NI1A_DoDrawingsInto2DGraph()
	endif	
	if(cmpstr("DoSectorAverages",ctrlName)==0)
		NI1A_DoDrawingsInto2DGraph()
	endif	
	if(cmpstr("UseSectors",ctrlName)==0)
		NI1A_TabProc("",4)
	endif
	if(cmpstr("UseI0ToCalibrate",ctrlName)==0)
	endif
	if(cmpstr("UseSampleThickness",ctrlName)==0)
	endif

	if(stringmatch(ctrlName,"UseSampleThickness")|| StringMatch(ctrlName, "UseSampleTransmission" )||stringmatch(ctrlName,"UseSampleCorrectionFactor"))
		if(UseCorrectionFactor && UseSampleThickness && UseSampleTransmission)
			SVAR DataCalibrationString=root:Packages:Convert2Dto1D:DataCalibrationString
			DataCalibrationString="cm2/cm3"
			PopupMenu DataCalibrationString,win=NI1A_Convert2Dto1DPanel, mode=1+WhichListItem(DataCalibrationString, "Arbitrary;cm2/cm3;cm2/g;" )
		else
			SVAR DataCalibrationString=root:Packages:Convert2Dto1D:DataCalibrationString
			DataCalibrationString="Arbitrary"
			PopupMenu DataCalibrationString,win=NI1A_Convert2Dto1DPanel, mode=1+WhichListItem(DataCalibrationString, "Arbitrary;cm2/cm3;cm2/g;" )
		endif
	
	endif


	if(cmpstr("UseSampleThicknFnct",ctrlName)==0)
		SetVariable SampleThickness,disable=(checked), win=NI1A_Convert2Dto1DPanel
		SetVariable SampleThicknFnct,disable=(!checked), win=NI1A_Convert2Dto1DPanel
	endif
	if(cmpstr("UseSampleMonitorFnct",ctrlName)==0)
		SetVariable SampleI0,disable=(checked), win=NI1A_Convert2Dto1DPanel
		SetVariable SampleMonitorFnct,disable=(!checked), win=NI1A_Convert2Dto1DPanel
	endif
	
	if(cmpstr("UseSampleTransmFnct",ctrlName)==0)
		SetVariable SampleTransmission,disable=(checked), win=NI1A_Convert2Dto1DPanel
		SetVariable SampleTransmFnct,disable=(!checked), win=NI1A_Convert2Dto1DPanel
	endif
	
	if(cmpstr("UseSampleMeasTimeFnct",ctrlName)==0)
		SetVariable SampleMeasurementTime,disable=(checked), win=NI1A_Convert2Dto1DPanel
		SetVariable SampleMeasTimeFnct,disable=(!checked), win=NI1A_Convert2Dto1DPanel
	endif
	
	if(cmpstr("UseEmptyTimeFnct",ctrlName)==0)
		SetVariable EmptyMeasurementTime,disable=(checked), win=NI1A_Convert2Dto1DPanel
		SetVariable EmptyTimeFnct,disable=(!checked), win=NI1A_Convert2Dto1DPanel
	endif
	
	if(cmpstr("UseBackgTimeFnct",ctrlName)==0)
		SetVariable BackgroundMeasTime,disable=(checked), win=NI1A_Convert2Dto1DPanel
		SetVariable BackgTimeFnct,disable=(!checked), win=NI1A_Convert2Dto1DPanel
	endif
	
	if(cmpstr("UseSampleCorrectFnct",ctrlName)==0)
		SetVariable CorrectionFactor,disable=(checked), win=NI1A_Convert2Dto1DPanel
		SetVariable SampleCorrectFnct,disable=(!checked), win=NI1A_Convert2Dto1DPanel
	endif
	
	if(cmpstr("UseEmptyMonitorFnct",ctrlName)==0)
		SetVariable EmptyI0,disable=(checked), win=NI1A_Convert2Dto1DPanel
		SetVariable EmptyMonitorFnct,disable=(!checked), win=NI1A_Convert2Dto1DPanel
	endif


	if(cmpstr("UseSampleTransmission",ctrlName)==0)
	endif
	if(cmpstr("UseSampleCorrectionFactor",ctrlName)==0)
	endif
	if(cmpstr("UseMask",ctrlName)==0)
		if(!checked)
			NI1M_RemoveMaskFromImage()
		endif
		NI1A_TabProc("nothing",2)
	endif
	if(cmpstr("UseDarkField",ctrlName)==0)
		UseSubtractFixedOffset=0
	endif
	if(cmpstr("UseEmptyField",ctrlName)==0)
	endif
	if(cmpstr("UseSubtractFixedOffset",ctrlName)==0)
		UseDarkField = 0
	endif
	if(cmpstr("UseSampleMeasTime",ctrlName)==0)
	endif
	if(cmpstr("UseEmptyMeasTime",ctrlName)==0)
	endif
	if(cmpstr("UseDarkMeasTime",ctrlName)==0)
	endif
	if(cmpstr("UseSolidAngle",ctrlName)==0)
	endif
	if(cmpstr("UseMonitorForEF",ctrlName)==0)
	endif
	if(cmpstr("QbinningLogarithmic",ctrlName)==0)
		if(checked)
			NVAR QvectorMaxNumPnts=root:Packages:Convert2Dto1D:QvectorMaxNumPnts
			QvectorMaxNumPnts=0
			SetVariable QbinPoints, win=NI1A_Convert2Dto1DPanel, disable=QvectorMaxNumPnts
		endif
	endif
	if(cmpstr("QvectorMaxNumPnts",ctrlName)==0)
		SetVariable QbinPoints, win=NI1A_Convert2Dto1DPanel, disable=checked
		if(checked)
			NVAR QbinningLogarithmic=root:Packages:Convert2Dto1D:QbinningLogarithmic
			QbinningLogarithmic=0
		endif
	endif
	if(cmpstr("DoSectorAverages",ctrlName)==0)
		NI1A_TabProc("nothing",4)
	endif
	if(cmpstr("UseLineProfile",ctrlName)==0)
		NI1A_TabProc("nothing",6)
	endif
	
	
	if(cmpstr("DisplayDataAfterProcessing",ctrlName)==0)
		if(checked)
			NVAR tr=root:Packages:Convert2Dto1D:StoreDataInIgor
			tr=1
		endif
	endif
	if(cmpstr("StoreDataInIgor",ctrlName)==0)
		if(!checked)
			NVAR tr=root:Packages:Convert2Dto1D:DisplayDataAfterProcessing
			tr=0
		endif
	endif
	if(cmpstr("ImageDisplayBeamCenter",ctrlName)==0)
		NI1A_DoDrawingsInto2DGraph()
	endif
	if(cmpstr("ImageDisplaySectors",ctrlName)==0)
		NI1A_DoDrawingsInto2DGraph()
	endif

	if(cmpstr("ImageDisplayLogScaled",ctrlName)==0)
		
		string  TopImgName=WinName(0,1)
		if(cmpstr(TopImgName,"CCDImageToConvertFig")!=0 && cmpstr(TopImgName,"EmptyOrDarkImage")!=0)
			DoWindow CCDImageToConvertFig
			if(!V_Flag)
				DoWindow EmptyOrDarkImage
				if(!V_Flag)
					abort
				else
					DoWindow/F EmptyOrDarkImage	
					TopImgName="EmptyOrDarkImage"	
				endif
			else
				DoWindow/F CCDImageToConvertFig	
				TopImgName="CCDImageToConvertFig"
			endif
		endif
		if (cmpstr(TopImgName,"CCDImageToConvertFig")==0)
			NI1A_DisplayTheRight2DWave()
		endif
		if (cmpstr(TopImgName,"EmptyOrDarkImage")==0)
			String s= ImageNameList("", ";")
			Variable p1= StrSearch(s,";",0)
			if( p1<0 )
				abort			// no image in top graph
			endif
			s= s[0,p1-1]
			if(cmpstr(s,"EmptyData_Dis")==0)
				wave waveToDisplay = root:Packages:Convert2Dto1D:EmptyData
				wave waveToDisplayDis = root:Packages:Convert2Dto1D:EmptyData_dis
			elseif(cmpstr(s,"DarkFieldData_Dis")==0)
				wave waveToDisplay = root:Packages:Convert2Dto1D:DarkFieldData
				wave waveToDisplayDis = root:Packages:Convert2Dto1D:DarkFieldData_dis
			elseif(cmpstr(s,"Pixel2Dsensitivity_Dis")==0)
				wave waveToDisplay = root:Packages:Convert2Dto1D:Pixel2Dsensitivity
				wave waveToDisplayDis = root:Packages:Convert2Dto1D:Pixel2Dsensitivity_dis
			else
				abort
			endif
			Redimension/S waveToDisplayDis
			if(checked)
				MatrixOp/O/NTHR=0 waveToDisplayDis = log(waveToDisplay)
			else
				MatrixOp/O/NTHR=0 waveToDisplayDis = waveToDisplay
			endif
		endif
		NVAR UseUserDefMinMax = root:Packages:Convert2Dto1D:UseUserDefMinMax
		NVAR UserImageRangeMin = root:Packages:Convert2Dto1D:UserImageRangeMin
		NVAR UserImageRangeMax = root:Packages:Convert2Dto1D:UserImageRangeMax
		if(UseUserDefMinMax)
			if(checked)
				if(UserImageRangeMin>0)
					UserImageRangeMin = log(UserImageRangeMin)
				else
					UserImageRangeMin = 0
				endif
				UserImageRangeMax = log(UserImageRangeMax)
			else
				if(UserImageRangeMin>0)
					UserImageRangeMin = 10^(UserImageRangeMin)
				else
					UserImageRangeMin=0
				endif
				UserImageRangeMax = 10^(UserImageRangeMax)
			endif
			NI1A_TopCCDImageUpdateColors(0)
		else
			NI1A_TopCCDImageUpdateColors(1)
		endif
		NI1A_AddColorScaleTo2DGraph()
	endif

	
	if(cmpstr("DezingerCCDData",ctrlName)==0)
		NI1A_TabProc("nothing",1)	//this sets the displayed variables accordingly
	endif
	if(cmpstr("DezingerEmpty",ctrlName)==0 || cmpstr("DezingerDark",ctrlName)==0)
		NI1A_TabProc("nothing",3)	//this sets the displayed variables accordingly
	endif

	NI1A_SetCalibrationFormula()

	DoWIndow/F NI1A_Convert2Dto1DPanel	
	
	//and these ones should npt raise the panel above...
	if(cmpstr("DoPolarizationCorrection",ctrlName)==0)
		if(checked)
			DoWindow NI1A_PolCorPanel
			if(V_Flag)
				DoWIndow/F NI1A_PolCorPanel
			else
				Execute("NI1A_PolCorPanel()")
			endif
		else
			DoWindow NI1A_PolCorPanel
			if(V_Flag)
				DoWIndow/K NI1A_PolCorPanel
			endif
		endif		
	endif

	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_LineProf_Update()
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
		NI1A_LineProfUpdateQ()
		NI1A_AllDrawingsFrom2DGraph()
		NI1A_DrawLinesIn2DGraph()
		variable cont = NI1A_LineProf_CreateLP()
		if(cont)
			NI1A_LineProf_DisplayLP()	
		endif	
	setDataFolder OldDf

end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_DoDrawingsInto2DGraph()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR DisplayBeamCenterIn2DGraph=root:Packages:Convert2Dto1D:DisplayBeamCenterIn2DGraph
	NVAR DisplaySectorsIn2DGraph=root:Packages:Convert2Dto1D:DisplaySectorsIn2DGraph
	NVAR UseSectors = root:Packages:Convert2Dto1D:UseSectors
	NVAR UseLineProfile=root:Packages:Convert2Dto1D:UseLineProfile
	NVAR DisplayQValsOnImage= root:Packages:Convert2Dto1D:DisplayQValsOnImage
	NVAR DisplayQvalsWIthGridsOnImg = root:Packages:Convert2Dto1D:DisplayQvalsWIthGridsOnImg
	NVAR DisplayColorScale = root:Packages:Convert2Dto1D:DisplayColorScale
	
	NI1A_AllDrawingsFrom2DGraph()
	if(DisplayBeamCenterIn2DGraph)
		NI1A_DrawCenterIn2DGraph()
	endif
	if(DisplaySectorsIn2DGraph && UseSectors)
		NI1A_DrawSectorsIn2DGraph()
	endif
	if(DisplaySectorsIn2DGraph && UseLineProfile)
		NI1A_DrawLinesIn2DGraph()
	endif
	if(DisplayQValsOnImage)
		NI1G_AddQAxisToImage(0)
	endif
	if(DisplayQvalsWIthGridsOnImg)
		NI1G_AddQAxisToImage(1)
	endif
	if(DisplayColorScale)
		NI1A_AddColorScaleTo2DGraph()
	endif
	
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_AddColorScaleTo2DGraph()
		if(!stringmatch(WinName(0,1,1),"CCDImageToConvertFig"))
			return 0
		endif
		
		ColorScale/K/N=Colorscale2D/W=CCDImageToConvertFig	///W=CCDImageToConvertFig
		NVAR DisplayColorScale = root:Packages:Convert2Dto1D:DisplayColorScale
		IF(DisplayColorScale)
			NVAR ImageDisplayLogScaled = root:Packages:Convert2Dto1D:ImageDisplayLogScaled
			NVAR UseUserDefMinMax = root:Packages:Convert2Dto1D:UseUserDefMinMax
			NVAR CurImageMin = root:Packages:Convert2Dto1D:ImageRangeMinLimit
			NVAR CurImageMax = root:Packages:Convert2Dto1D:ImageRangeMaxLimit
			Wave CCDImageToConvert_dis=root:Packages:Convert2Dto1D:CCDImageToConvert_dis
			variable tempRange
			variable tempStart
			
			if(!ImageDisplayLogScaled)
				ColorScale/C/W=CCDImageToConvertFig/N=Colorscale2D/M/A=RB/X=2.00/Y=2.00  image=CCDImageToConvert_dis, widthPct=5,fsize=12,heightPct=50,tickLen=5.00, "Intensity"
			else
				wavestats/Q CCDImageToConvert_dis
				tempRange = V_max - V_Min + 10
				tempStart = floor(V_min)
				tempRange =  10*ceil(tempRange)
				
				Make/O/N=(tempRange) ColorScaleLogTicks
				Make/O/T/N=(tempRange) ColorScaleLinTicksTW
				variable i
				For(i=0;i<tempRange;i+=10)
						ColorScaleLinTicksTW[i] = num2str(10^(tempStart+i/10))
						ColorScaleLinTicksTW[i+1] = ""
						ColorScaleLinTicksTW[i+2] = ""
						ColorScaleLinTicksTW[i+3] = ""
						ColorScaleLinTicksTW[i+4] = ""
						ColorScaleLinTicksTW[i+5] = ""
						ColorScaleLinTicksTW[i+6] = ""
						ColorScaleLinTicksTW[i+7] = ""
						ColorScaleLinTicksTW[i+8] = ""
						ColorScaleLinTicksTW[i+9] = ""
					ColorScaleLogTicks[i] = (tempStart+i/10)
					ColorScaleLogTicks[i+1] = (tempStart+i/10)+log(2)
					ColorScaleLogTicks[i+2] = (tempStart+i/10)+log(3)
					ColorScaleLogTicks[i+3] = (tempStart+i/10)+log(4)
					ColorScaleLogTicks[i+4] = (tempStart+i/10)+log(5)
					ColorScaleLogTicks[i+5] = (tempStart+i/10)+log(6)
					ColorScaleLogTicks[i+6] = (tempStart+i/10)+log(7)
					ColorScaleLogTicks[i+7] = (tempStart+i/10)+log(8)
					ColorScaleLogTicks[i+8] = (tempStart+i/10)+log(9)
					ColorScaleLogTicks[i+9] = (tempStart+i/10)+log(9)
				endfor
				ColorScale/C/W=CCDImageToConvertFig/N=Colorscale2D/M/A=RB/X=2.00/Y=2.00  image=CCDImageToConvert_dis, widthPct=5,heightPct=50, tickLen=5.00, fsize=12, userTicks={ColorScaleLogTicks,ColorScaleLinTicksTW } "Intensity"
			endif
		endif
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_DrawSectorsIn2DGraph()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

 	DoWindow CCDImageToConvertFig
	if(V_Flag)
	     setDrawLayer/W=CCDImageToConvertFig ProgFront
		NVAR ycenter=root:Packages:Convert2Dto1D:BeamCenterY
		NVAR xcenter=root:Packages:Convert2Dto1D:BeamCenterX
		NVAR DoSectorAverages=root:Packages:Convert2Dto1D:DoSectorAverages
		NVAR UseSectors = root:Packages:Convert2Dto1D:UseSectors
		NVAR UseLineProfile=root:Packages:Convert2Dto1D:UseLineProfile
		NVAR NumberOfSectors=root:Packages:Convert2Dto1D:NumberOfSectors
		NVAR SectorsStartAngle=root:Packages:Convert2Dto1D:SectorsStartAngle
		NVAR SectorsHalfWidth=root:Packages:Convert2Dto1D:SectorsHalfWidth
		Wave CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert_dis
		NVAR SectorsStepInAngle=root:Packages:Convert2Dto1D:SectorsStepInAngle
		variable i, tempEndX, tempEndY, sectorCenterAngle, tempLength
		variable temp1, temp2, temp3, temp4
		
		if(DoSectorAverages && UseSectors)
			For(i=0;i<NumberOfSectors;i+=1)
				//calculate coordinates for lines...
				sectorCenterAngle = SectorsStartAngle+90 + i*(SectorsStepInAngle)
				if(sectorCenterAngle>=90 && sectorCenterAngle<180)
					temp1 = DimSize(CCDImageToConvert, 0 )-xcenter
					temp2 = ycenter
				elseif(sectorCenterAngle>=180 && sectorCenterAngle<270)
					temp1 = xcenter
					temp2= ycenter
				elseif(sectorCenterAngle>=270 && sectorCenterAngle<360)
					temp1 = xcenter
					temp2= DimSize(CCDImageToConvert, 1)-ycenter
				elseif(sectorCenterAngle>=360 && sectorCenterAngle<450)
					temp1 = DimSize(CCDImageToConvert, 0 )-xcenter
					temp2= DimSize(CCDImageToConvert, 1)-ycenter
				endif
				tempLength = sqrt((temp1 * sin(pi/180*sectorCenterAngle))^2+ (temp2 * cos(pi/180*sectorCenterAngle))^2)
				//center line
				tempEndX= (xcenter + (tempLength)*sin(pi/180*(sectorCenterAngle)))
				tempEndY=(ycenter + (tempLength)*cos(pi/180*(sectorCenterAngle)))
				string AxList= AxisList("CCDImageToConvertFig" )
				if(stringMatch(axlist,"*top*"))
					setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=top,ycoord=left,save
				else
					setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=bottom,ycoord=left,save
				endif
				SetDrawEnv/W=CCDImageToConvertFig linefgc= (8704,8704,8704),dash= 7  
				SetDrawEnv /W=CCDImageToConvertFig linethick=2
				Drawline/W=CCDImageToConvertFig xcenter, ycenter, tempEndX, tempEndY
				//side lines
				tempEndX= (xcenter + (tempLength)*sin(pi/180*(sectorCenterAngle-SectorsHalfWidth)))
				tempEndY=(ycenter + (tempLength)*cos(pi/180*(sectorCenterAngle-SectorsHalfWidth)))
				if(stringMatch(axlist,"*top*"))
					setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=top,ycoord=left,save
				else
					setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=bottom,ycoord=left,save
				endif
				SetDrawEnv/W=CCDImageToConvertFig linefgc= (65280,65280,0)
				SetDrawEnv /W=CCDImageToConvertFig dash= 2,linethick= 1.00
				Drawline/W=CCDImageToConvertFig xcenter, ycenter, tempEndX, tempEndY
				tempEndX=(xcenter + (tempLength)*sin(pi/180*(sectorCenterAngle+SectorsHalfWidth)))
				tempEndY=(ycenter + (tempLength)*cos(pi/180*(sectorCenterAngle+SectorsHalfWidth)))
				if(stringMatch(axlist,"*top*"))
					setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=top,ycoord=left,save
				else
					setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=bottom,ycoord=left,save
				endif
				SetDrawEnv/W=CCDImageToConvertFig linefgc= (65280,65280,0)
				SetDrawEnv /W=CCDImageToConvertFig dash= 2,linethick= 1.00
				Drawline/W=CCDImageToConvertFig xcenter, ycenter, tempEndX, tempEndY
			 endfor
	      endif
	endif
	setDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_DrawLinesIn2DGraph()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

 	DoWindow CCDImageToConvertFig
	if(V_Flag)
	     setDrawLayer/W=CCDImageToConvertFig ProgFront
		NVAR ycenter=root:Packages:Convert2Dto1D:BeamCenterY
		NVAR xcenter=root:Packages:Convert2Dto1D:BeamCenterX

		NVAR UseLineProfile=root:Packages:Convert2Dto1D:UseLineProfile
		Wave CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert_dis

		NVAR LineProf_UseBothHalfs=root:Packages:Convert2Dto1D:LineProf_UseBothHalfs
		NVAR LineProf_DistanceFromCenter=root:Packages:Convert2Dto1D:LineProf_DistanceFromCenter
		NVAR LineProf_Width=root:Packages:Convert2Dto1D:LineProf_Width
		NVAR LineProf_DistanceQ=root:Packages:Convert2Dto1D:LineProf_DistanceQ
		NVAR LineProf_WidthQ=root:Packages:Convert2Dto1D:LineProf_WidthQ
		SVAR LineProf_CurveType=root:Packages:Convert2Dto1D:LineProf_CurveType
	
		variable i, tempEndX, tempEndY, sectorCenterAngle, tempLength
		variable temp1, temp2, temp3, temp4
		variable CenterStartX, CenterStartY, CenterEndX, CenterEndY
		variable LeftStartX,LeftEndX,LeftStartY,leftEndY
		variable RightStartX,RightStartY,RightEndX,RightEndY
		NVAR LineProf_UseBothHalfs=root:Packages:Convert2Dto1D:LineProf_UseBothHalfs

		NVAR LineProf_LineAzAngle=root:Packages:Convert2Dto1D:LineProf_LineAzAngle
		NVAR LineProf_GIIncAngle=root:Packages:Convert2Dto1D:LineProf_GIIncAngle
		NVAR LineProf_EllipseAR=root:Packages:Convert2Dto1D:LineProf_EllipseAR

		variable isStraightLine
		if(UseLineProfile)
				//calculate coordinates for lines...

			if(stringMatch(LineProf_CurveType,"Angle Line"))
				isStraightLine=0
					make/O/N=(Dimsize(CCDImageToConvert, 0)) WaveX, WaveXL, WaveXR
					make/O/N=(Dimsize(CCDImageToConvert, 1)) WaveY, WaveYL, WaveYR
					NI1A_GenerAngleLine(Dimsize(CCDImageToConvert, 0),Dimsize(CCDImageToConvert, 1),xcenter,ycenter,LineProf_LineAzAngle,LineProf_DistanceFromCenter,WaveX,WaveY)
					NI1A_GenerAngleLine(Dimsize(CCDImageToConvert, 0),Dimsize(CCDImageToConvert, 1),xcenter,ycenter,LineProf_LineAzAngle,LineProf_DistanceFromCenter+LineProf_Width,WaveXL,WaveYL)
					NI1A_GenerAngleLine(Dimsize(CCDImageToConvert, 0),Dimsize(CCDImageToConvert, 1),xcenter,ycenter,LineProf_LineAzAngle,LineProf_DistanceFromCenter-LineProf_Width,WaveXR,WaveYR)
			endif
			if(stringMatch(LineProf_CurveType,"Ellipse"))
				isStraightLine=0
					make/O/N=(1440) WaveX, WaveXL, WaveXR
					make/O/N=(1440) WaveY, WaveYL, WaveYR
					NI1A_GenerEllipseLine(xcenter,ycenter,LineProf_EllipseAR,LineProf_DistanceFromCenter,WaveX,WaveY)
					NI1A_GenerEllipseLine(xcenter,ycenter,LineProf_EllipseAR,LineProf_DistanceFromCenter+LineProf_Width,WaveXL,WaveYL)
					NI1A_GenerEllipseLine(xcenter,ycenter,LineProf_EllipseAR, LineProf_DistanceFromCenter-LineProf_Width,WaveXR,WaveYR)
			endif
			if(stringMatch(LineProf_CurveType,"GISAXS_FixQy"))
				isStraightLine=0
					CenterStartY = DimSize(CCDImageToConvert, 1 )
					make/O/N=(CenterStartY) WaveX, WaveXL, WaveXR
					make/O/N=(CenterStartY) WaveY, WaveYL, WaveYR
					waveY=p
					WaveYL=p
					WaveYR=p
					variable Qy0=NI1GI_CalculateQxyz(LineProf_DistanceFromCenter-xcenter,ycenter,"Y")
					WaveX=NIGI_CalcYdimForFixQz(WaveY[p],Qy0)
					Qy0=NI1GI_CalculateQxyz(LineProf_DistanceFromCenter+LineProf_Width-xcenter,ycenter,"Y")
					WaveXL=NIGI_CalcYdimForFixQz(WaveY[p],Qy0)
					Qy0=NI1GI_CalculateQxyz(LineProf_DistanceFromCenter-LineProf_Width-xcenter,ycenter,"Y")
					WaveXR=NIGI_CalcYdimForFixQz(WaveY[p],Qy0)
			endif

			if(stringMatch(LineProf_CurveType,"Horizontal Line")||stringMatch(LineProf_CurveType,"GI_Horizontal Line"))
					isStraightLine=1
					CenterStartX = DimSize(CCDImageToConvert, 0 )
					leftStartX=DimSize(CCDImageToConvert, 0 )
					RightStartX=DimSize(CCDImageToConvert, 0 )
					CenterEndX = 0
					LeftEndX=0
					RightEndY=0
					CenterStartY=ycenter-LineProf_DistanceFromCenter
					LeftStartY=CenterStartY+LineProf_Width
					RightStartY=CenterStartY-LineProf_Width
					CenterEndY=ycenter-LineProf_DistanceFromCenter
					LeftEndY=CenterEndY+LineProf_Width
					RightEndY=CenterEndY-LineProf_Width
			endif

			if(stringMatch(LineProf_CurveType,"Vertical Line")||stringMatch(LineProf_CurveType,"GI_Vertical Line"))
					isStraightLine=1
					CenterStartY = DimSize(CCDImageToConvert, 1 )
					LeftStartY = DimSize(CCDImageToConvert, 1 )
					RightStartY = DimSize(CCDImageToConvert, 1 )
					CenterEndY = 0
					LeftEndY = 0
					RightEndY = 0
					CenterStartX=Xcenter+LineProf_DistanceFromCenter
					LeftStartX=Xcenter+LineProf_DistanceFromCenter+LineProf_Width
					RightStartX=Xcenter+LineProf_DistanceFromCenter-LineProf_Width
					CenterEndX=xcenter+LineProf_DistanceFromCenter
					LeftEndX=xcenter+LineProf_DistanceFromCenter+LineProf_Width
					RightEndX=xcenter+LineProf_DistanceFromCenter-LineProf_Width
			endif

			if(isStraightLine)
				string AxList= AxisList("CCDImageToConvertFig" )
				if(stringMatch(axlist,"*top*"))
					setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=top,ycoord=left,save
				else
					setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=bottom,ycoord=left,save
				endif
				SetDrawEnv/W=CCDImageToConvertFig linefgc= (8704,8704,8704),dash= 7  
				SetDrawEnv /W=CCDImageToConvertFig linethick=2
				Drawline/W=CCDImageToConvertFig CenterStartX,CenterStartY,centerEndX,CenterEndY
				SetDrawEnv/W=CCDImageToConvertFig linefgc= (65280,65280,0)
				SetDrawEnv /W=CCDImageToConvertFig dash= 2,linethick= 1.00
				Drawline/W=CCDImageToConvertFig LeftStartX,LeftStartY,leftEndX,leftEndY
				SetDrawEnv/W=CCDImageToConvertFig linefgc= (65280,65280,0)
				SetDrawEnv /W=CCDImageToConvertFig dash= 2,linethick= 1.00
				Drawline/W=CCDImageToConvertFig RightStartX,RightStartY,RightEndX,RightEndY
				
			else
					setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=top,ycoord=left,save
					SetDrawEnv/W=CCDImageToConvertFig linefgc= (8704,8704,8704),dash= 7  
					SetDrawEnv /W=CCDImageToConvertFig linethick=2
					DrawPoly /W=CCDImageToConvertFig/ABS  0, 0,1,1, WaveX, WaveY
					SetDrawEnv/W=CCDImageToConvertFig linefgc= (65280,65280,0)
					SetDrawEnv /W=CCDImageToConvertFig dash= 2,linethick= 1.00
					DrawPoly /W=CCDImageToConvertFig/ABS  0, 0,1,1, WaveXL, WaveYL
					SetDrawEnv/W=CCDImageToConvertFig linefgc= (65280,65280,0)
					SetDrawEnv /W=CCDImageToConvertFig dash= 2,linethick= 1.00
					DrawPoly /W=CCDImageToConvertFig/ABS  0, 0,1,1, WaveXR, WaveYR
			endif
		//mirror line, if needed... for 
				if(LineProf_UseBothHalfs && isStraightLine)
						//calculate coordinates for lines...
					if(stringMatch(LineProf_CurveType,"Horizontal Line")||stringMatch(LineProf_CurveType,"GI_Horirontal Line"))
							CenterStartX = DimSize(CCDImageToConvert, 0 )
							leftStartX=DimSize(CCDImageToConvert, 0 )
							RightStartX=DimSize(CCDImageToConvert, 0 )
							CenterEndX = 0
							LeftEndX=0
							RightEndY=0
							CenterStartY=ycenter+LineProf_DistanceFromCenter
							LeftStartY=CenterStartY+LineProf_Width
							RightStartY=CenterStartY-LineProf_Width
							CenterEndY=ycenter+LineProf_DistanceFromCenter
							LeftEndY=CenterEndY+LineProf_Width
							RightEndY=CenterEndY-LineProf_Width
					endif
		
					if(stringMatch(LineProf_CurveType,"Vertical Line")||stringMatch(LineProf_CurveType,"GI_Vertical Line"))
							CenterStartY = DimSize(CCDImageToConvert, 1 )
							LeftStartY = DimSize(CCDImageToConvert, 1 )
							RightStartY = DimSize(CCDImageToConvert, 1 )
							CenterEndY = 0
							LeftEndY = 0
							RightEndY = 0
							CenterStartX=Xcenter-LineProf_DistanceFromCenter
							LeftStartX=CenterStartX+LineProf_Width
							RightStartX=CenterStartX-LineProf_Width
							CenterEndX=xcenter-LineProf_DistanceFromCenter
							LeftEndX=CenterEndX+LineProf_Width
							RightEndX=CenterEndX-LineProf_Width
					endif
		
						 AxList= AxisList("CCDImageToConvertFig" )
						if(stringMatch(axlist,"*top*"))
							setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=top,ycoord=left,save
						else
							setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=bottom,ycoord=left,save
						endif
						SetDrawEnv/W=CCDImageToConvertFig linefgc= (8704,8704,8704),dash= 7  
						SetDrawEnv /W=CCDImageToConvertFig linethick=2
						Drawline/W=CCDImageToConvertFig CenterStartX,CenterStartY,centerEndX,CenterEndY
						SetDrawEnv/W=CCDImageToConvertFig linefgc= (65280,65280,0)
						SetDrawEnv /W=CCDImageToConvertFig dash= 2,linethick= 1.00
						Drawline/W=CCDImageToConvertFig LeftStartX,LeftStartY,leftEndX,leftEndY
						SetDrawEnv/W=CCDImageToConvertFig linefgc= (65280,65280,0)
						SetDrawEnv /W=CCDImageToConvertFig dash= 2,linethick= 1.00
						Drawline/W=CCDImageToConvertFig RightStartX,RightStartY,RightEndX,RightEndY
				endif
	      endif
	endif
	setDataFolder OldDf
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_GenerAngleLine(DetDimX,DetDimY,BCx,BCy,Angle,Offset,WaveX,WaveY)
	variable DetDimX,DetDimY,BCx,BCy,Angle,Offset
	Wave WaveX,WaveY
	//generate X-Y path for angle line on the detector
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	
	make/O/N=(DetDimX) tempWvX
	make/O/N=(DetDimY) tempWvY
	if(abs(angle)<45)
		tempWvX=p
		tempWvY=BCy-(tempWvX-BCx)*tan(Angle*pi/180)
	elseif(abs(angle)>=45 || abs(angle)<135)
		tempWvY=p
		tempWvX=BCx+(tempWvY-BCy)*tan((Angle-90)*pi/180)
	else
		tempWvX=p
		tempWvY=BCy-(tempWvX-BCx)*tan(Angle*pi/180)	
	endif
	//now offset the line by the geometrically corrected offset...
	if(abs(angle)<45)
		tempWvY-=Offset / cos(Angle*pi/180)
	elseif(abs(angle)>=45 || abs(angle)<135)
		tempWvX-=Offset / sin((Angle)*pi/180) 
	else
		tempWvY-=Offset / cos(Angle*pi/180)	
	endif
	WaveX=tempWvX
	WaveY=tempWvY
	killWaves tempWvY, tempWvX
	
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_GenerEllipseLine(BCx,BCy,Excentricity,Offset,WaveX,WaveY)
	variable Excentricity,BCx,BCy,Offset
	Wave WaveX,WaveY
	//generate X-Y path for angle line on the detector
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	
	
	Redimension/N=(1440) WaveX,WaveY
	WaveX = BCx + Offset * cos(p*(pi/720))
	WaveY = BCy + Offset * Excentricity* sin(p*(pi/720))
	
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_GenerGISAXSQyLine(DetDimX,DetDimY,BCx,BCy,Angle,Offset,WaveX,WaveY)
	variable DetDimX,DetDimY,BCx,BCy,Angle,Offset
	Wave WaveX,WaveY
	//generate X-Y path for angle line on the detector
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	
	make/O/N=(DetDimX) tempWvX
	make/O/N=(DetDimY) tempWvY



	WaveX=tempWvX
	WaveY=tempWvY
	killWaves tempWvY, tempWvX
	
	setDataFolder OldDf
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1GI_CalculateQxyz(DimXpos,DimYpos,WhichOne)
	variable DimXpos,DimYpos
	String WhichOne
	
	NVAR ycenter=root:Packages:Convert2Dto1D:BeamCenterY
	NVAR xcenter=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR LineProf_GIIncAngle=root:Packages:Convert2Dto1D:LineProf_GIIncAngle
	NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance
	NVAR Wavelength=root:Packages:Convert2Dto1D:Wavelength
	NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
	
	variable K0val=2*pi/wavelength
	variable TwoThetaF=atan((xcenter-DimXpos)*PixelSizeX /SampleToCCDDistance)
	variable alphaF = atan((ycenter - DimYpos)*PixelSizeY /SampleToCCDDistance)
	variable alphaI = LineProf_GIIncAngle * pi / 180
	
	if(stringmatch(WhichOne,"X"))
		variable Qx = K0val * (cos(TwoThetaF)*cos(AlphaF) - cos(AlphaI))
		return Qx
	elseif(stringmatch(WhichOne,"Y"))
		variable Qy = -1 * K0val * (sin(TwoThetaF)*cos(AlphaF))
		return Qy
	elseif(stringmatch(WhichOne,"Z"))
		variable Qz = K0val * (sin(alphaF)+sin(alphaI))
		return Qz
	else
		RETURN 0
	endif
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NIGI_CalcYdimForFixQz(DimYPos,Qy)
	variable DimYPos	//this defines really Qz in pixel value
	variable Qy			//for which value of Qy we want to calcualte this?

	NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
	NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance
	NVAR xcenter=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR Wavelength=root:Packages:Convert2Dto1D:Wavelength
	NVAR LineProf_GIIncAngle=root:Packages:Convert2Dto1D:LineProf_GIIncAngle
	variable alphaI = LineProf_GIIncAngle * pi / 180
	
	variable Qz=NI1GI_CalculateQxyz(0,DimYpos,"Z")
	variable K0val=2*pi/wavelength
	
	variable sinAlphaF = (Qz  - K0val *sin(alphaI))/K0val
	variable AlphaF = asin(sinAlphaF)
	
	variable sin2ThetaF = Qy/(k0val * cos(AlphaF))
	variable TwoThetaF = asin(sin2ThetaF)
	//and now convert to pixel units...
//	variable TwoThetaF=atan((xcenter-DimXpos)*PixelSizeX /SampleToCCDDistance)
	variable DimXpos = -1* xcenter + tan(TwoThetaF) * SampleToCCDDistance / PixelSizeX
	
	return DimXpos

end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_DrawCenterIn2DGraph()
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
 	DoWindow CCDImageToConvertFig
	NVAR displaybeamcenterin2Dgraph=root:Packages:Convert2Dto1D:displaybeamcenterin2Dgraph
	if(V_Flag&&displaybeamcenterin2Dgraph)
	     setDrawLayer/W=CCDImageToConvertFig ProgFront
		NVAR ycenter=root:Packages:Convert2Dto1D:BeamCenterY
		NVAR xcenter=root:Packages:Convert2Dto1D:BeamCenterX
		if(stringMatch(AxisList("CCDImageToConvertFig"),"*top*"))
			setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=top,ycoord=left,save
		else
			setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=bottom,ycoord=left,save
		endif
		SetDrawEnv/W=CCDImageToConvertFig linefgc=(65535, 65535,65535 )
		SetDrawEnv /W=CCDImageToConvertFig linethick=3
		DrawOval/W=CCDImageToConvertFig xcenter-2, ycenter+2, xcenter+2, ycenter-2
		SetDrawEnv/W=CCDImageToConvertFig linefgc=(65535, 0,0 )
		SetDrawEnv/W=CCDImageToConvertFig linethick=2
		DrawOval/W=CCDImageToConvertFig xcenter-10, ycenter+10, xcenter+10, ycenter-10
		SetDrawEnv/W=CCDImageToConvertFig linefgc=(65535, 0,0 )
		SetDrawEnv/W=CCDImageToConvertFig linethick=2
		DrawOval/W=CCDImageToConvertFig xcenter-50, ycenter+50, xcenter+50, ycenter-50
		SetDrawEnv/W=CCDImageToConvertFig linefgc=(65535, 0,0 )
		SetDrawEnv/W=CCDImageToConvertFig linethick=2
		DrawOval/W=CCDImageToConvertFig xcenter-200, ycenter+200, xcenter+200, ycenter-200
	      setDrawLayer/W=CCDImageToConvertFig UserFront
	  endif
	  	setDataFolder OldDf
EndMacro
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_AllDrawingsFrom2DGraph()
	DoWindow CCDImageToConvertFig
	if(V_Flag)
	      setDrawLayer/W=CCDImageToConvertFig/K ProgFront
	      setDrawLayer/W=CCDImageToConvertFig UserFront
		ColorScale/K/N=Colorscale2D//Z //image=CCDImageToConvert_dis

	 endif
end


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_SetCalibrationFormula()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	SVAR CalibrationFormula=root:Packages:Convert2Dto1D:CalibrationFormula
	NVAR UseSampleThickness= root:Packages:Convert2Dto1D:UseSampleThickness
	NVAR UseSampleTransmission= root:Packages:Convert2Dto1D:UseSampleTransmission
	NVAR UseCorrectionFactor= root:Packages:Convert2Dto1D:UseCorrectionFactor
	NVAR UseSolidAngle= root:Packages:Convert2Dto1D:UseSolidAngle
	NVAR UseMask= root:Packages:Convert2Dto1D:UseMask
	NVAR UseDarkField= root:Packages:Convert2Dto1D:UseDarkField
	NVAR UseEmptyField= root:Packages:Convert2Dto1D:UseEmptyField
	NVAR UseSubtractFixedOffset= root:Packages:Convert2Dto1D:UseSubtractFixedOffset
	NVAR UseSampleMeasTime= root:Packages:Convert2Dto1D:UseSampleMeasTime
	NVAR UseEmptyMeasTime= root:Packages:Convert2Dto1D:UseEmptyMeasTime
	NVAR UseDarkMeasTime= root:Packages:Convert2Dto1D:UseDarkMeasTime
	NVAR UsePixelSensitivity= root:Packages:Convert2Dto1D:UsePixelSensitivity
	NVAR UseI0ToCalibrate = root:Packages:Convert2Dto1D:UseI0ToCalibrate
	NVAR UseMonitorForEF = root:Packages:Convert2Dto1D:UseMonitorForEF

	string PreProcess=""
	string SampleString=""
	if(UseCorrectionFactor)
		PreProcess+="C"
	endif
	if(strlen(PreProcess)==0)
		PreProcess+="1"
	endif
	if(UseSolidAngle)
		PreProcess+="/O"
	endif
	if(UseI0ToCalibrate)
		PreProcess+="/I0"
	endif
	if(UseSampleThickness)
		PreProcess+="/St"
	endif

	if(strlen(PreProcess)>0)
		SampleString+="*"
	endif
	if(UseSampleTransmission)
		SampleString+="(1/T*"
	else
		SampleString+="("
	endif
//	if(strlen(SampleString)>2)
//		SampleString+="*"
//	endif
	if(UsePixelSensitivity)
		SampleString+="(Sa2D/Pix2D"
	else
		SampleString+="(Sa2D"
	endif
	if(UseSubtractFixedOffset)
		SampleString+="-Ofst"
	endif
	if(UseDarkField)
		if(UseSampleMeasTime && UseDarkMeasTime)
			if(UsePixelSensitivity)
				SampleString+="-(ts/td)*DF2D/Pix2D"
			else
				SampleString+="-(ts/td)*DF2D"
			endif
		else
			if(UsePixelSensitivity)
				SampleString+="-DF2D/Pix2D"
			else
				SampleString+="-DF2D"
			endif
		endif
	endif
		SampleString+=")"
	
		string EmptyStr=""
	if(UseEmptyField)
		EmptyStr+="-"
		if(UseMonitorForEF)
			EmptyStr+="I0/I0ef"
		elseif(UseEmptyMeasTime && UseSampleMeasTime)
			EmptyStr+="ts/te"
		endif
		if(strlen(EmptyStr)>2)
			EmptyStr+="*"
		endif
		if(UsePixelSensitivity)
			EmptyStr+="(EF2D/Pix2D"
		else
			EmptyStr+="(EF2D"
		endif
	if(UseSubtractFixedOffset)
		EmptyStr+="-Ofst"
	endif
		if(UseDarkField)
			if(UseSampleMeasTime && UseEmptyMeasTime)
				if(UsePixelSensitivity)
					EmptyStr+="-(te/td)*(DF2D/Pix2D"
				else
					EmptyStr+="-(te/td)*(DF2D"
				endif
			else
				if(UsePixelSensitivity)
					EmptyStr+="-DF2D/Pix2D"
				else
					EmptyStr+="-DF2D"
				endif
			endif
		endif
		EmptyStr+=")"
	endif

	CalibrationFormula = PreProcess+SampleString+EmptyStr+")"
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_DezingerImage(image)
        Wave image
        string OldDf=GetDataFOlder(1)
        setDataFolder root:Packages:Convert2Dto1D
 	 NVAR DezingerRatio =root:Packages:Convert2Dto1D:DezingerRatio
 	 string OldNote=note(image)
        Duplicate/O image, dup, DiffWave, FilteredDiffWave
        Redimension/S DiffWave, FilteredDiffWave    	    // make single precision
        MatrixFilter /N=3 median image				    // 3x3 median filter (integer result if image integer, fp if fp)
        MatrixOp/O/NTHR=0 DiffWave = dup / (abs(image))          	  	    // difference between raw and filtered, high values (>35) are cosmics and high signals
       //image = SelectNumber(DiffWave>DezingerRatio,dup,image)    // choose filtered (image) if difference is great
   	MatrixOp/O/NTHR=0 image = dup * (-1)*(greater(Diffwave,DezingerRatio)-1) + image*(greater(Diffwave,DezingerRatio))
	//the MatrxiOp is 3x faster than the original line.... 
	note image, OldNote
        KillWaves/Z DiffWave, FilteredDiffWave, dup
        setDataFolder OldDf
End


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//************************************************************************
//************************************************************************
//************************************************************************

Function NI1G_AddQAxisToImage(UseGrids)
	variable UseGrids
	
		string OldDf = GetDataFolder(1)
		setDataFolder root:Packages:Convert2Dto1D
		
	DoWIndow CCDImageToConvertFig
	if(!V_flag)
		abort
	else
		DoWIndow/F CCDImageToConvertFig
	endif
	//OK, image exists... Now we need to check the image does nto have transform axis. 
	string ImgRecreationStr=WinRecreation("CCDImageToConvertFig", 0 )
	
	variable UsesTopAxis
	string HorAxisName, MT_HorAxisname
	
	if(stringMatch(AxisList("CCDImageToConvertFig"),"*top;*"))
		UsesTopAxis=1
		HorAxisName="top"
		MT_HorAxisname="MT_top"
	else
		UsesTopAxis=0		//uses bottom axis in the image (Inverted 0,0)
		HorAxisName="bottom"
		MT_HorAxisname="MT_bottom"
	endif
	
	//and now we need to add the transform axes to the image
	if(!stringmatch(ImgRecreationStr, "*MT_left*" ))
		SetupTransformMirrorAxis("CCDImageToConvertFig", "left", "TransAx_CalculateVerticalQaxis", $"", 7, 1, 5, 0)
	endif
	
	if(!stringmatch(ImgRecreationStr, "*MT_top*" )&&!stringmatch(ImgRecreationStr, "*MT_bottom*" ))
			SetupTransformMirrorAxis("CCDImageToConvertFig", HorAxisName, "TransAx_CalculateHorizQaxis", $"", 7, 1, 5, 0)
	endif
	SetWindow CCDImageToConvertFig, hook(MyKillGraphHook) = NI1U_KillWindowHookF
	//And now we need to format them. 

		SVAR LineProf_CurveType=root:Packages:Convert2Dto1D:LineProf_CurveType
		NVAR UseLineProfile = root:Packages:Convert2Dto1D:UseLineProfile



	ModifyGraph margin=40
	ModifyGraph noLabel(left)=1, noLabel($(HorAxisName))=1
		if(UseLineProfile && (stringMatch(LineProf_CurveType,"GI_Vertical Line") || stringMatch(LineProf_CurveType,"GI_Horizontal Line")))
				Label left "\\Z14q\\Bz\\M\\Z14 [A\\S-1\\M\\Z14]"		
		else
				Label left "\\Z14q\\Bx\\M\\Z14 [A\\S-1\\M\\Z14]"		
		endif
	Label $(HorAxisName) "\\Z14q\\By\\M\\Z14 [A\\S-1\\M\\Z14]"
	ModifyGraph tick(left)=3, tick($(HorAxisName))=3
	ModifyGraph grid=0
	DoUpdate	
	ModifyGraph tick(MT_left)=0 , tick($(MT_HorAxisname))=0
		if(UseLineProfile && (stringMatch(LineProf_CurveType,"GI_Vertical Line") || stringMatch(LineProf_CurveType,"GI_Horizontal Line")))
			Label MT_left "\\Z14q\\Bz\\M\\Z14 [A\\S-1\\M\\Z14]"
		else
			Label MT_left "\\Z14q\\Bx\\M\\Z14 [A\\S-1\\M\\Z14]"
		endif
	Label $(MT_HorAxisname) "\\Z14q\\By\\M\\Z14 [A\\S-1\\M\\Z14]"
	ModifyGraph noLabel(MT_left)=0 , nolabel($(MT_HorAxisname))=0
	ModifyGraph mirror(MT_left)=3 , mirror($(MT_HorAxisname))=3
	ModifyGraph lblPos(MT_left)=40,lblLatPos=0
	ModifyGraph lblPos($(MT_HorAxisname))=35,lblLatPos=0
	if(UseGrids)
		ModifyGraph grid(MT_left)=1
		ModifyGraph grid($(MT_HorAxisname))=1
	endif
	setDataFolder oldDf
end
//************************************************************************
//************************************************************************
//************************************************************************

Function NI1G_RemoveQAxisToImage(Recreate)
	variable Recreate
	
		string OldDf = GetDataFolder(1)
		setDataFolder root:Packages:Convert2Dto1D
		
	DoWIndow CCDImageToConvertFig
	if(!V_flag)
		abort
	else
		DoWIndow/F CCDImageToConvertFig
	endif
	//OK, image exists... Now we need to check the image does nto have transform axis. 
	string ImgRecreationStr=WinRecreation("CCDImageToConvertFig", 0 )
	
	//and now we need to add the transform axes to the image
	if(stringmatch(ImgRecreationStr, "*MT_left*" )||stringmatch(ImgRecreationStr, "*MT_top*" )||stringmatch(ImgRecreationStr, "*MT_bottom*" ))
		CloseTransformAxisGraph("CCDImageToConvertFig", 0)
	endif
	
	if(Recreate)
		NI1A_DisplayLoadedFile()
		NI1A_DisplayStatsLoadedFile("CCDImageToConvert")
		NI1A_TopCCDImageUpdateColors(1)
		NI1A_DoDrawingsInto2DGraph()
	endif
	
	setDataFolder oldDf
end

//************************************************************************
//************************************************************************
//************************************************************************
Function NI1U_UpdateQAxisInImage()
	DoWIndow CCDImageToConvertFig
	if(!V_flag)
		abort
	endif
	//OK, image exists... Now we need to check the image does nto have transform axis. 
	string ImgRecreationStr=WinRecreation("CCDImageToConvertFig", 0 )
	
	//and now we need to add the transform axes to the image
	//this is woraround to change in TransforAxis1.2 starting with Igor 6.21

#if IgorVersion() >= 6.21
	if(stringmatch(ImgRecreationStr, "*MT_left*" ))
		TicksForTransformAxis("CCDImageToConvertFig", "left",  7, 1, 5,"MT_left", 0,1)
	endif
	if(stringmatch(ImgRecreationStr, "*MT_top*" ))
		TicksForTransformAxis("CCDImageToConvertFig", "top",  7, 1, 5,"MT_top",0 ,1)
	endif
#else
	if(stringmatch(ImgRecreationStr, "*MT_left*" ))
		TicksForTransformAxis("CCDImageToConvertFig", "left",  7, 1, 5,"MT_left", 0)
	endif
	if(stringmatch(ImgRecreationStr, "*MT_top*" ))
		TicksForTransformAxis("CCDImageToConvertFig", "top",  7, 1, 5,"MT_top",0 )
	endif
#endif
end
//************************************************************************
//************************************************************************
//************************************************************************

Function NI1U_KillWindowHookF(s)
	STRUCT WMWinHookStruct &s
	
	Variable hookResult = 0	// 0 if we do not handle event, 1 if we handle it.

	switch(s.eventCode)
		case 17:					// Keyboard event
				//	Print "Killed the window"
					hookResult = 1
					NI1G_RemoveQAxisToImage(0)
			break
	endswitch

	return hookResult	// If non-zero, we handled event and Igor will ignore it.
End

//************************************************************************
//************************************************************************
//************************************************************************

Function TransAx_CalculateVerticalQaxis(w, x)
	Wave/Z w
	Variable x		//in pixels


		SVAR LineProf_CurveType=root:Packages:Convert2Dto1D:LineProf_CurveType
		NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt
		NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt
		NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
		NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
		NVAR UseLineProfile = root:Packages:Convert2Dto1D:UseLineProfile
		NVAR SampleToCCDDistance = root:Packages:Convert2Dto1D:SampleToCCDDistance
		NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength
		NVAR InvertImages = root:Packages:Convert2Dto1D:InvertImages

		NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
		NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY

		variable PixPosition= x
		variable DistanceInmmPixPos
		variable DistInQ

		if(UseLineProfile && (stringMatch(LineProf_CurveType,"GI_Vertical Line") || stringMatch(LineProf_CurveType,"GI_Horizontal Line")))
			// this is exception,  need to use GI geometry for conversion, All other should eb the same...
			DistInQ=NI1GI_CalculateQxyz(BeamCenterX,PixPosition,"Z")
		else
			PixPosition=BeamCenterY - x
			DistanceInmmPixPos = PixPosition * PixelSizeY
			//let's not worry about tilsts here, this is just approximate
			DistInQ=NI1A_LP_ConvertPosToQ(DistanceInmmPixPos, SampleToCCDDistance, Wavelength)
		endif
		
		if(InvertImages)
			DistInQ*=-1
		endif

	return  DistInQ
end

//************************************************************************
//************************************************************************
//************************************************************************

Function TransAx_CalculateHorizQaxis(w, x)
	Wave/Z w
	Variable x		//in pixels


		SVAR LineProf_CurveType=root:Packages:Convert2Dto1D:LineProf_CurveType
		NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt
		NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt
		NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
		NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
		NVAR UseLineProfile = root:Packages:Convert2Dto1D:UseLineProfile
		NVAR SampleToCCDDistance = root:Packages:Convert2Dto1D:SampleToCCDDistance
		NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength

		NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
		NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY

		variable PixPosition=x
		variable DistanceInmmPixPos
		variable DistInQ

		if(UseLineProfile && (stringMatch(LineProf_CurveType,"GI_Vertical Line") || stringMatch(LineProf_CurveType,"GI_Horizontal Line")))
			// this is exception,  need to use GI geometry for conversion, All other should eb the same...
			DistInQ=NI1GI_CalculateQxyz(PixPosition,BeamCenterY,"Y")
		else
			PixPosition=BeamCenterX-x
			DistanceInmmPixPos = PixPosition * PixelSizeX
			//let's not worry about tilsts here, this is just approximate
			DistInQ=NI1A_LP_ConvertPosToQ(DistanceInmmPixPos, SampleToCCDDistance, Wavelength)
		endif

		return DistInQ
end
//************************************************************************
//************************************************************************
//************************************************************************

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI2T_testThetaWithTilts()		// calculate theta for pixel px, py - optionally reset parameters from defaluts, else read stored structure
	
	STRUCT NikadetectorGeometry d
	wave testImg
		NI2T_ReadOrientationFromGlobals(d)
		NI2T_SaveStructure(d)
		NI2t_printDetectorStructure(d)
//variable startTicks=ticks	
//	multithread testImg =  NI2T_pixel2Theta(d,p,q)
//print (ticks-startTicks)/60
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI2T_Calculate2DThetaWithTilts(Theta2DWave)		// calculate theta for pixel px, py
	wave Theta2DWave
	STRUCT NikadetectorGeometry d

		NI2T_ReadOrientationFromGlobals(d)
		NI2T_SaveStructure(d)
		Multithread Theta2DWave =  NI2T_pixelTheta(d,p,q)
end


//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

  Function/C NI2T_CalculatePxPyWithTilts(theta, direction)  
	variable theta, direction
	//theta is bragg angle in question
	//direction is azimuthal angle in radians
	variable TwoTheta= 2*theta		//theta of this px, py with tilts
	variable px,py
	NVAR BeamCenterX = root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY = root:Packages:Convert2Dto1D:BeamCenterY
	px=  cos(direction)
	py=  sin(direction)
	variable GammaAngle=NI2T_CalculateGammaWithTilts(px,py)		//gamma angle
	variable SDD
	NVAR SampleToCCDDistance = root:Packages:Convert2Dto1D:SampleToCCDDistance	//in mm
	NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
	SDD=SampleToCCDDistance/(0.5*(PixelSizeX+PixelSizeY))
	variable OtherAngle = pi - TwoTheta - GammaAngle
	variable distance = SDD*sin(TwoTheta)/sin(OtherAngle)		//distance in pixels from beam center 
	//Question 1/8/2012... Should this be tangents? 
	//variable distance = SDD*sin(TwoTheta)/sin(OtherAngle)		//distance in pixels from beam center 
	variable pxR = BeamCenterX+distance*cos(direction)
	variable pyR = BeamCenterY+distance*sin(direction)
	
	return cmplx(pxR,pyR)
	
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI2T_CalculateGammaWithTilts(px,py)		// calculate theta for pixel px, py - optionally reset parameters from defaluts, else read stored structure
	variable  px, py
	
	STRUCT NikadetectorGeometry d
	
		NI2T_ReadOrientationFromGlobals(d)
		NI2T_SaveStructure(d)
	
	return  NI2T_pixelGamma(d,px,py)
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI2T_pixelGamma(d,px,py)				// returns 2-theta (rad)
	STRUCT NikadetectorGeometry &d
	Variable px,py									// pixel position, 0 based, first pixel is (0,0), NOT (1,1)

	make/FREE/N=3 ki
	make/FREE/N=3 kout
	ki = {0,0,1}									//	ki =   ki[p],  incident beam direction

	NI2T_pixel3XYZ(d,px,py,kout)						// kout is in direction of pixel in beam line coords...
	//MatrixOp/O kout= Normalize(kout)
	NI2T_normalize(kout)

	Variable Theta =pi- acos(MatrixDot(kout,ki))   	// ki.kf = cos(2theta), (radians)
	//comment: Added pi - acos here on May 28, 2011. It should be right now. Tested on 45 degree image and needed to agree with the image and analyzed data.. 
	//MatrixOp/O Theta =acos(kout.ki)   	// ki.kf = cos(2theta), (radians)
 
 	return Theta
End


//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI2T_pixel3XYZ(d,px,py,xyz)					// convert pixel position to the beamline coordinate but with detector not moved. 
	STRUCT NikadetectorGeometry, &d
	Variable px,py									// pixel position on detector (full chip & zero based)
	Wave xyz											// 3-vector to receive the result, position in beam line coords (micron)

	Variable xp,yp, zp									// x' and y' (requiring z'=0), detector starts centered on origin and perpendicular to z-axis
	//d.P[0] is Beam center x position in pixels
	//d.P[1] is Beam center y position in pixels
	//d.P[2] is SDD in pixels
//	xp = (px - d.P[0]) //* d.sizeX/d.Nx					// (x' y' z'), position on detector, but with respect to beam center now (not center of detector)
//	yp = (py - d.P[1]) //* d.sizeY/d.Ny					//now in pixels
//	zp = 0								      				 // 
	xp = (px) //* d.sizeX/d.Nx					// (x' y' z'), position on detector, but with respect to beam center now (not center of detector)
	yp = (py) //* d.sizeY/d.Ny					//now in pixels
	zp = 0								      				 // 

	xyz[0] = d.rho00*xp + d.rho01*yp + d.rho02*zp	// xyz = rho x [ (x' y' z') + P ]
	xyz[1] = d.rho10*xp + d.rho11*yp + d.rho12*zp	// rho is pre-calculated from vector d.R
	xyz[2] = d.rho20*xp + d.rho21*yp + d.rho22*zp

//	xyz[2] += d.P[2]								      			 //translate by P distance from sample in pixles. 
//do nto move here, we need this without move to calculate gamma angle

End

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI2T_CalculateThetaWithTilts2(px,py)		// calculate theta for pixel px, py - optionally reset parameters from defaluts, else read stored structure
	variable  px, py
	
	STRUCT NikadetectorGeometry d
//	NI2T_LoadStructure(d)
	NI2T_ReadOrientationFromGlobals(d)
	NI2T_SaveStructure(d)
	variable theta = NI2T_pixelTheta(d,px,py)	
	return theta								
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI2T_CalculateThetaWithTilts(px,py,resetParameters)		// calculate theta for pixel px, py - optionally reset parameters from defaluts, else read stored structure
	variable  px, py, resetParameters
	
	STRUCT NikadetectorGeometry d
	
	if(resetParameters&&px==0&&py==0)					//read default parameters from defaults 
		NI2T_ReadOrientationFromGlobals(d)
		NI2T_SaveStructure(d)
	else										//read stored structure
		NI2T_LoadStructure(d)
	endif
	
	return NI2T_pixelTheta(d,px,py)
end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

//main routine returning theta angle (in radians) for pixel
// convert px,py positions on detector into Q vector, assumes ki={0,0,1}

ThreadSafe Function NI2T_pixelTheta(d,px,py)				// returns 2-theta (rad)
	STRUCT NikadetectorGeometry &d
	Variable px,py									// pixel position, 0 based, first pixel is (0,0), NOT (1,1)

	make/FREE/N=3 ki
	make/FREE/N=3 kout
	ki = {0,0,1}									//	ki =   ki[p],  incident beam direction

	NI2T_pixel2XYZ(d,px,py,kout)						// kout is in direction of pixel in beam line coords
	NI2T_normalize(kout)
	//MatrixOp kout= Normalize(kout)
	
	Variable Theta = acos(MatrixDot(kout,ki)) /2   	// ki.kf = cos(2theta), (radians)
 	//MatrixOp/FREE Theta =acos(kout.ki)   	// ki.kf = cos(2theta), (radians)
	//note, cannot use matrixOp since this is threadsafe function and waves are global... ALso, surprisingly MatrixOp here is slower by far... 
 	return Theta
End
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Threadsafe Function NI2T_normalize(a)	// normalize a and return the initial magnitude
	Wave a
	Variable norm_a
	if (WaveDims(a)==1)											// for a 1-d wave, normalize the vector
		norm_a = norm(a)
	elseif(WaveDims(a)==2 && DimSize(a,0)==DimSize(a,1))	// for an (n x n) wave, divide by the determinant
		norm_a = MatrixDet(a)^(1/DimSize(a,0))
	endif
	if (norm_a==0 || numtype(norm_a))
		return 0
	endif

	if (WaveType(a)&1)											// for a complex wave
		FastOp/C a = (1/norm_a)*a								//	a /= norm_a
	else
		FastOp a = (1/norm_a)*a									//	a /= norm_a
	endif
	return norm_a
End

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Structure NikaDetectorGeometry			// structure definition for a detector
	int16 used							// TRUE=detector used, FALSE=detector un-used ... not used in Nika
	int32 Nx, Ny						// # of un-binned pixels in full detector
	double sizeX,sizeY					// outside size of detector (sizeX = Nx*pitchX), measured to outer edge of outer pixels (micron)
	double R[3]						// rotation vector (length is angle in radians)
	double P[3]						// translation vector (micron)

	uchar timeMeasured[100]		// when this geometry was calculated
	uchar geoNote[100]				// note
	uchar detectorID[100]			// unique detector ID ... not used in Nika
	uchar distortionMapFile[100]	// name of file with distortion map ... not used in Nika

	double rho00, rho01, rho02		// rotation matrix internally calculated from R[3]
	double rho10, rho11, rho12
	double rho20, rho21, rho22
EndStructure

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************


Function NI2T_InitTiltCorrection()

	string OldDf=GetDataFolder(1)
	setDataFolder root:
	NewDataFolder/O root:Packages							// ensure Packages exists
	NewDataFolder/O root:Packages:NikaTiltCorrections		// ensure NikaTiltCorrections exists

	Make/N=3/O/D root:Packages:NikaTiltCorrections:pixel2q_ki, root:Packages:NikaTiltCorrections:pixel2q_kout

	setDataFolder OldDf
end 
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

// this is move first, tilt then. 
//threadsafe Function NI2T_pixel2XYZ(d,px,py,xyz)					// convert pixel position to the beam line coordinate system
//	STRUCT NikadetectorGeometry, &d
//	Variable px,py									// pixel position on detector (full chip & zero based)
//	Wave xyz											// 3-vector to receive the result, position in beam line coords (micron)
//
//	Variable xp,yp, zp								// x' and y' (requiring z'=0), detector starts centered on origin and perpendicular to z-axis
//
//	xp = (px - 0.5*(d.Nx-1)) * d.sizeX/d.Nx		// (x' y' z'), position on detector
//	yp = (py - 0.5*(d.Ny-1)) * d.sizeY/d.Ny
//
//	xp += d.P[0]										// translate by P
//	yp += d.P[1]
//	zp = d.P[2]
//
//	xyz[0] = d.rho00*xp + d.rho01*yp + d.rho02*zp	// xyz = rho x [ (x' y' z') + P ]
//	xyz[1] = d.rho10*xp + d.rho11*yp + d.rho12*zp	// rho is pre-calculated from vector d.R
//	xyz[2] = d.rho20*xp + d.rho21*yp + d.rho22*zp
//
//End

//This is tilt first, move then... 
//threadsafe Function NI2T_pixel2XYZ(d,px,py,xyz)					// convert pixel position to the beam line coordinate system
//	STRUCT NikadetectorGeometry, &d
//	Variable px,py									// pixel position on detector (full chip & zero based)
//	Wave xyz											// 3-vector to receive the result, position in beam line coords (micron)
//
//	Variable xp,yp, zp								// x' and y' (requiring z'=0), detector starts centered on origin and perpendicular to z-axis
//
//	xp = (px - 0.5*(d.Nx-1)) * d.sizeX/d.Nx		// (x' y' z'), position on detector
//	yp = (py - 0.5*(d.Ny-1)) * d.sizeY/d.Ny
//
//	xyz[0] = d.rho00*xp + d.rho01*yp + d.rho02*zp	// xyz = rho x [ (x' y' z') + P ]
//	xyz[1] = d.rho10*xp + d.rho11*yp + d.rho12*zp	// rho is pre-calculated from vector d.R
//	xyz[2] = d.rho20*xp + d.rho21*yp + d.rho22*zp
//
//	xyz[0] += d.P[0]										// translate by P
//	xyz[1] += d.P[1]
//	xyz[2] += d.P[2]
//
//
//End

//thsi si with respect to beam center...
threadsafe Function NI2T_pixel2XYZ(d,px,py,xyz)					// convert pixel position to the beam line coordinate system
	STRUCT NikadetectorGeometry, &d
	Variable px,py									// pixel position on detector (full chip & zero based)
	Wave xyz											// 3-vector to receive the result, position in beam line coords (micron)

	Variable xp,yp, zp									// x' and y' (requiring z'=0), detector starts centered on origin and perpendicular to z-axis
	//d.P[0] is Beam center x position in pixels
	//d.P[1] is Beam center y position in pixels
	//d.P[2] is SDD in pixels
	xp = (px - d.P[0]) //* d.sizeX/d.Nx					// (x' y' z'), position on detector, but with respect to beam center now (not center of detector)
	yp = (py - d.P[1]) //* d.sizeY/d.Ny					//now in pixels
	zp = 0								      				 // 

	xyz[0] = d.rho00*xp + d.rho01*yp + d.rho02*zp	// xyz = rho x [ (x' y' z') + P ]
	xyz[1] = d.rho10*xp + d.rho11*yp + d.rho12*zp	// rho is pre-calculated from vector d.R
	xyz[2] = d.rho20*xp + d.rho21*yp + d.rho22*zp

	xyz[2] += d.P[2]								      			 //translate by P distance from sample in pixles. 


End


//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI2T_ReadOrientationFromGlobals(d)						// sets d to the reference orientation based on user values
	STRUCT NikadetectorGeometry &d

	Wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	Wave/Z BmCntrCCDImg = root:Packages:Convert2Dto1D:BmCntrCCDImg
	variable NumPixX, NumPixY

	if(WaveExists(BmCntrCCDImg))
		NumPixX=dimsize(BmCntrCCDImg,0)
		NumPixY=dimsize(BmCntrCCDImg,1)
	elseif(WaveExists(CCDImageToConvert))
		NumPixX=dimsize(CCDImageToConvert,0)
		NumPixY=dimsize(CCDImageToConvert,1)
	else
		abort "Need image to grab the dimensions from"
	endif
	NVAR SDD=root:Packages:Convert2Dto1D:SampleToCCDDistance
	NVAR BeamCntrX=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR PixSizeX=root:Packages:Convert2Dto1D:PixelSizeX
	NVAR BeamCntrY=root:Packages:Convert2Dto1D:BeamCenterY
	NVAR PixSizeY=root:Packages:Convert2Dto1D:PixelSizeY
	NVAR HorizontalTilt= root:Packages:Convert2Dto1D:HorizontalTilt
	NVAR VerticalTilt = root:Packages:Convert2Dto1D:VerticalTilt
//	NVAR AzimuthalTilt = root:Packages:Convert2Dto1D:AzimuthalTilt

	// define Detector 0, located SDDmm directly behind the sample 
	d.used = 1
	d.Nx = NumPixX ;					d.Ny = NumPixX						// number of un-binned pixels in whole detector
	d.sizeX = NumPixX*PixSizeX*1000;		d.sizeY = NumPixY*PixSizeY*1000		// outside size of detector (micron)

// NOTE THE change here:
	d.R[1]=pi*HorizontalTilt/180
	d.R[0]=pi*VerticalTilt/180
//	d.R[2]=pi*AzimuthalTilt/180							// angle of detector, theta = 0
	d.R[2]=0							// angle of detector, theta = 0
	//if we are doing stuff wrt beam center, these shifts are no more needed
//	d.P[0]=(NumPixX/2 - BeamCntrX)*PixSizeX*1000
//	d.P[1]=(NumPixY/2 - BeamCntrY)*PixSizeX*1000			
	d.P[0]=BeamCntrX		//put the beam center here....
	d.P[1]=BeamCntrY		//put the beam center here... 	
	d.P[2]=SDD	/(0.5 *(PixSizeX+PixSizeY))   			// offset to detector in pixels
	d.timeMeasured = "This is basic setup with detector perpendicularly to beam SDD away"
	d.geoNote = "Basic perpendicular orientation"
	d.detectorID = "User defined"
	d.distortionMapFile = ""
	
	NI2T_DetectorUpdateCalc(d)
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI2T_SaveOrientationToGlobals(d)						// sets d to the reference orientation based on user values
	STRUCT NikadetectorGeometry &d

	Wave/Z CCDImageToConvert = root:Packages:Convert2Dto1D:CCDImageToConvert
	Wave/Z BmCntrCCDImg = root:Packages:Convert2Dto1D:BmCntrCCDImg
	variable NumPixX, NumPixY
	if(WaveExists(BmCntrCCDImg))
		NumPixX=dimsize(BmCntrCCDImg,0)
		NumPixY=dimsize(BmCntrCCDImg,1)
	elseif(WaveExists(CCDImageToConvert))
		NumPixX=dimsize(CCDImageToConvert,0)
		NumPixY=dimsize(CCDImageToConvert,1)
	else
		abort "Need image to grab the dimensions from"
	endif
	NVAR SDD=root:Packages:Convert2Dto1D:SampleToCCDDistance
	NVAR BeamCntrX=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR PixSizeX=root:Packages:Convert2Dto1D:PixelSizeX
	NVAR BeamCntrY=root:Packages:Convert2Dto1D:BeamCenterY
	NVAR PixSizeY=root:Packages:Convert2Dto1D:PixelSizeY
	NVAR HorizontalTilt= root:Packages:Convert2Dto1D:HorizontalTilt
	NVAR VerticalTilt = root:Packages:Convert2Dto1D:VerticalTilt


// NOTE THE change here:
	HorizontalTilt = 180*d.R[1]/pi		//		d.R[1]=pi*HorizontalTilt/180
	VerticalTilt = 180*d.R[0]/pi		//		d.R[0]=pi*VerticalTilt/180
	//d.R[2]=0							// angle of detector, theta = 0
//	BeamCntrX = NumPixX/2 - (d.P[0]/(PixSizeX*1000))						//	d.P[0]=(NumPixX/2 - BeamCntrX)*PixSizeX*1000
//	BeamCntrY = NumPixY/2 - (d.P[1]/(PixSizeY*1000))						//d.P[1]=(NumPixY/2 - BeamCntrY)*PixSizeX*1000			
	BeamCntrX = d.P[0]						//	d.P[0]=beam center X
	BeamCntrY = d.P[1]						//d.P[1]=beam center Y			
	SDD= 		d.P[2]/1000						//d.P[2]=SDD*1000	  			// offset to detector (micron)
	d.timeMeasured = "This is basic setup with detector perpendicularly to beam SDD away"
	d.geoNote = "Basic perpendicular orientation"
	d.detectorID = "User defined"
	d.distortionMapFile = ""
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI2T_DetectorUpdateCalc(d)						// update all internally calculated things in the detector structure
	STRUCT NikadetectorGeometry &d
	if (!(d.used))
		return 1
	endif

	Variable Rx, Ry, Rz								// used to make the rotation matrix rho from vector R
	Variable theta, c, s, c1
	Variable i
	Rx=d.R[0]; Ry=d.R[1]; Rz=d.R[2]				// make the rotation matrix rho from vector R
	theta = sqrt(Rx*Rx+Ry*Ry+Rz*Rz)
	if (theta==0)										// no rotation, set to identity matrix
		d.rho00 = 1;		d.rho01 = 0;		d.rho02 = 0
		d.rho10 = 0;		d.rho11 = 1;		d.rho12 = 0
		d.rho20 = 0;		d.rho21 = 0;		d.rho22 = 1
		return 0
	endif

	c=cos(theta)
	s=sin(theta)
	c1 = 1-c
	Rx /= theta;	Ry /= theta;	Rz /= theta		// make |{Rx,Ry,Rz}| = 1

	d.rho00 = c + Rx*Rx*c1;		d.rho01 = Rx*Ry*c1 - Rz*s;	d.rho02 = Ry*s + Rx*Rz*c1		// this is the Rodrigues formula from:
	d.rho10 = Rz*s + Rx*Ry*c1;	d.rho11 = c + Ry*Ry*c1;		d.rho12 = -Rx*s + Ry*Rz*c1	// http://mathworld.wolfram.com/RodriguesRotationFormula.html
	d.rho20 = -Ry*s + Rx*Rz*c1;	d.rho21 = Rx*s + Ry*Rz*c1;	d.rho22 = c + Rz*Rz*c1
	return 0
End

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************


Function NI2T_SaveStructure(d)						//save structure back into string and create it if necessary. 
	STRUCT NikadetectorGeometry &d	
	
	SVAR/Z  strStruct = root:Packages:NikaTiltCorrections:NikaDetectorGeometryStr
	if(!SVAR_Exists(strStruct))
		string OldDf=getDataFolder(1)
		NewDataFolder/O/S root:Packages:NikaTiltCorrections
		IN2G_CreateItem("string","NikaDetectorGeometryStr")
		SVAR  strStruct = root:Packages:NikaTiltCorrections:NikaDetectorGeometryStr
		setDataFolder OldDf	
	endif
	//NI2T_ReadOrientationFromGlobals(d)				// set structure to the values in the geo panel globals
	NI2T_DetectorUpdateCalc(d)
	StructPut/S/B=2 d, strStruct
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI2T_LoadStructure(d)					//here we load structure from saved structure in the string... 
	STRUCT NikadetectorGeometry &d	
	
	SVAR/Z strStruct = root:Packages:NikaTiltCorrections:NikaDetectorGeometryStr
	if(!SVAR_Exists(strStruct))
		ABort "Structure does not exist. Create it first with Beam center & Calibration tool"
	endif
	StructGet/S/B=2 d, strStruct								// found structure information, load into geo
	//NI2T_SaveOrientationToGlobals(d)						// set structure to the values in the geo panel globals
	NI2T_DetectorUpdateCalc(d)
//	StructPut/S/B=2 d, strStruct
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************




Function NI2t_printDetectorStructure(d)							// print the details for passed detector geometry to the history window
	STRUCT NikadetectorGeometry &d

	printf "	Nx=%d, Ny=%d			// number of un-binned pixels in detector\r",d.Nx,d.Ny
	printf "	sizeX=%g, sizeY=%g		// size of detector (mm)\r",(d.sizeX/1000), (d.sizeY/1000)
	printf "	R = {%.7g, %.7g, %.7g}, a rotation of %.7g¡	// rotation vector\r",d.R[0],d.R[1],d.R[2],sqrt(d.R[0]*d.R[0] + d.R[1]*d.R[1] + d.R[2]*d.R[2])*180/PI
	printf "	P = {%g, %g, %g}					// translation vector (mm)\r",(d.P[0])/1000,(d.P[1])/1000,(d.P[2])/1000

	printf "	geometry measured on  '%s'\r",d.timeMeasured
	if (strlen(d.geoNote))
		printf "	detector note = '%s'\r",d.geoNote
	endif
	if (strlen(d.distortionMapFile))
		printf "	detector distortion file = '%s'\r",d.distortionMapFile
	endif
	printf "	detector ID = '%s'\r"d.detectorID
	if (NumVarOrDefault("root:Packages:geometry:printVerbose",0))
		printf "			{%+.6f, %+.6f, %+.6f}	// rotation matrix from R\r",d.rho00, d.rho01, d.rho02
		printf "	rho =	{%+.6f, %+.6f, %+.6f}\r",d.rho10, d.rho11, d.rho12
		printf "			{%+.6f, %+.6f, %+.6f}\r",d.rho20, d.rho21, d.rho22
	endif
	return 0
End

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
//*********     Live data collection part
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI1A_OnLineDataProcessing()	
	//create global variables 
	String OldDf=GetDataFolder(1)
	SetDataFOlder root:Packages:Convert2Dto1D
	NewDataFolder/O/S BckgMonitorParams
	String ListOfVariables, ListOfStrings
	ListOfVariables = "BckgUpdateInterval;BckgDisplayOnly;BckgConvertData;"
	ListOfStrings = "BckgStatus;"
	variable i
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor		
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor		
	NVAR BckgUpdateInterval
	if(BckgUpdateInterval<5)
		BckgUpdateInterval=30
	endif

	NVAR BckgDisplayOnly
	NVAR BckgConvertData
	if(BckgConvertData+BckgDisplayOnly!=1)
		BckgDisplayOnly=1
		BckgConvertData=0
	endif
	SVAR BckgStatus
	setDataFolder OldDf
	DoWindow NI_LiveDataProcessing
	if(V_Flag==0)
		NewPanel /FLT/K=1/W=(573,44,1000,210) as "Background processing"
		DoWindow/C NI_LiveDataProcessing
		SetDrawLayer UserBack
		SetDrawEnv fsize= 14,fstyle= 3,textrgb= (0,0,65535)
		DrawText 6,25,"\"Live\" data processing"
		SetDrawEnv fsize= 10
		DrawText 178,18,"This tool controls background process which"
		SetDrawEnv fsize= 10
		DrawText 178,33,"watches current data folder and when new files(s)"
		SetDrawEnv fsize= 10
		DrawText 178,48,"is found, runs \" Ave & Display\" or \"Convert one\""
		SetDrawEnv fsize= 10
		DrawText 178,63,"Use sort and Match options to control behavior"
		SetDrawEnv fsize= 10
		DrawText 178,78,"When multiple files are found, arbitrary is selected "
		TitleBox Status pos={5,35},variable=root:Packages:Convert2Dto1D:BckgMonitorParams:BckgStatus,fColor=(65535,0,0),labelBack=(32792,65535,1)
		TitleBox Status fColor=(0,0,0),labelBack=(65535,65535,65535)
		Button StartBackgrTask,pos={200,100},size={140,23},proc=NI2_BackgrTaskButtonProc,title="Start folder watch"
		Button StartBackgrTask,help={"Start Background task here"}
		Button StopBackgrTask,pos={200,130},size={140,23},proc=NI2_BackgrTaskButtonProc,title="Stop folder watch"
		Button StopBackgrTask,help={"Start Background task here"}
		PopupMenu UpdateTimeSelection pos={10, 74}, title="Update Time [sec] :"
		PopupMenu UpdateTimeSelection proc=NI2_BacgroundUpdatesPopMenuProc
		PopupMenu UpdateTimeSelection value="5;10;15;30;45;60;120;360;600;", mode=WhichListItem(num2str(BckgUpdateInterval),"5;10;15;30;45;60;120;360;600;")+1
		CheckBox BackgroundDisplayOnly pos={10,110},title="Display new images"
		CheckBox BackgroundDisplayOnly proc=NI2_BakcgroundCheckProc
		CheckBox BackgroundDisplayOnly variable=root:Packages:Convert2Dto1D:BckgMonitorParams:BckgDisplayOnly
		CheckBox BackgroundConvert pos={10,130},title="Convert new images"
		CheckBox BackgroundConvert proc=NI2_BakcgroundCheckProc
		CheckBox BackgroundConvert variable=root:Packages:Convert2Dto1D:BckgMonitorParams:BckgConvertData
		SetActiveSubwindow _endfloat_
	endif
	CtrlNamedBackground MonitorDataFolder, status
	if(NumberByKey("RUN", S_Info))		//running, restart witrh new parameters
		BckgStatus = "   Running background job   "
		TitleBox Status win=NI_LiveDataProcessing,fColor=(65535,0,0),labelBack=(32792,65535,1)
	else
		BckgStatus = "   Background job not running   "
		TitleBox Status win=NI_LiveDataProcessing,fColor=(0,0,0),labelBack=(65535,65535,65535)
	endif

end

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI2_BakcgroundCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR BckgConvertData=root:Packages:Convert2Dto1D:BckgMonitorParams:BckgConvertData
			NVAR BckgDisplayOnly=root:Packages:Convert2Dto1D:BckgMonitorParams:BckgDisplayOnly
			if(stringMatch(cba.CtrlName,"BackgroundDisplayOnly"))
				if(cba.checked)
					BckgDisplayOnly=1
					BckgConvertData=0
				endif
			endif
			if(stringMatch(cba.CtrlName,"BackgroundConvert"))
				if(cba.checked)
					BckgDisplayOnly=0
					BckgConvertData=1
				endif
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************


Function NI2_BacgroundUpdatesPopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(stringMatch("UpdateTimeSelection",pa.ctrlName))
				NVAR BckgUpdateInterval= root:Packages:Convert2Dto1D:BckgMonitorParams:BckgUpdateInterval
				BckgUpdateInterval = str2num(pa.popStr)
				CtrlNamedBackground MonitorDataFolder, status
				if(NumberByKey("RUN", S_Info))		//running, restart with new parameters
					StopFolderWatchTask()
					StartFolderWatchTask()
				endif
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************



Function NI2_BackgrTaskButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch("StartBackgrTask",ba.ctrlName))
				StartFolderWatchTask()
			endif
			if(stringmatch("StopBackgrTask",ba.ctrlName))
				StopFolderWatchTask()
			endif
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************


Function StartFolderWatchTask()
	//Variable numTicks = 5 * 60 // Run every two seconds (120 ticks) 
	NVAR BckgUpdateInterval= root:Packages:Convert2Dto1D:BckgMonitorParams:BckgUpdateInterval
		CtrlNamedBackground MonitorDataFolder, period=BckgUpdateInterval*60, proc=NI2_MonitorFldrBackground 
		CtrlNamedBackground MonitorDataFolder, start
		Printf "FolderWatch background task started with %d [s] update interval\r", BckgUpdateInterval
		SVAR BckgStatus = root:Packages:Convert2Dto1D:BckgMonitorParams:BckgStatus
		BckgStatus = "   Running background job   "
		TitleBox Status win=NI_LiveDataProcessing,fColor=(65535,0,0),labelBack=(32792,65535,1)
		Button OnLineDataProcessing win=NI1A_Convert2Dto1DPanel, fColor=(65535,0,0)
End
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function StopFolderWatchTask()
   CtrlNamedBackground MonitorDataFolder, stop
	Printf "FolderWatch background task stopped\r"
		SVAR BckgStatus = root:Packages:Convert2Dto1D:BckgMonitorParams:BckgStatus
		BckgStatus = "   Background job not running   "
		TitleBox Status win=NI_LiveDataProcessing,fColor=(0,0,0),labelBack=(65535,65535,65535)
		Button OnLineDataProcessing win=NI1A_Convert2Dto1DPanel, fColor=(65535,65535,65535)
End

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************


Function NI2_MonitorFldrBackground(s) // This is the function that will be called periodically 
	STRUCT WMBackgroundStruct &s
	
	//this should monitor result of Refresh on the folder and grab the new data set and process it.
	Wave/T ListOf2DSampleData=root:Packages:Convert2Dto1D:ListOf2DSampleData
	Wave ListOf2DSampleDataNumbers=root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers
	NVAR BckgConvertData=root:Packages:Convert2Dto1D:BckgMonitorParams:BckgConvertData
	NVAR BckgDisplayOnly=root:Packages:Convert2Dto1D:BckgMonitorParams:BckgDisplayOnly
	
	Duplicate/Free/T ListOf2DSampleData, ListOf2DSampleDataOld 
	
	NI1A_UpdateDataListBox()	
	Wave/T ListOf2DSampleData=root:Packages:Convert2Dto1D:ListOf2DSampleData
	NVAR FIlesSortOrder=root:Packages:Convert2Dto1D:FIlesSortOrder
	variable NumberOfNewImages

	Printf "Task %s called, found %d data images in current folder\r", s.name, numpnts(ListOf2DSampleData)

	if(numpnts(ListOf2DSampleData)>numpnts(ListOf2DSampleDataOld))	//new data set appeared
		NumberOfNewImages=numpnts(ListOf2DSampleData)-numpnts(ListOf2DSampleDataOld)
		if(FilesSortOrder==0)
			//here we need to select the new file. Only when files are not ordered, or it should be clear. 
			Printf "Found %g new data image(s), since using unsorted as sort order, will pick one to process \r", NumberOfNewImages
			Make/Free/T ResWave
			IN2G_FindNewTextElements(ListOf2DSampleData,ListOf2DSampleDataOld,reswave)
			//assume reswave[0] contains the last image added (impossible to say, actually)
			Printf "Selected %s, calling user routine using this file name \r", reswave[0]
			//need to find it in the original wave and select it in the control 
			variable i
			For(i=0;i<numpnts(ListOf2DSampleData);i+=1)
				if(stringmatch(ListOf2DSampleData[i],reswave[0]))
					ListOf2DSampleDataNumbers[i]=1
					break
				endif
			endfor 
			//print "New data set found, but do not know which one it is"
		else
			Printf "Found %g new data image(s), since sorting is selected, using the last one \r", NumberOfNewImages
		endif
		if(BckgConvertData)
			Print "Calling \"Convert sel. files 1 at time\" routine \r"
			NI1A_ButtonProc("ConvertSelectedFiles")
		elseif(BckgDisplayOnly)
			Print "Calling \"Ave & Display\" routine \r"
			NI1A_ButtonProc("DisplaySelectedFile")
		else
			Print "No routine selected by user, doing nothing. Seems to be bug. \r"
		endif
		
	endif
	
   return 0             // Continue background task
End

//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI1A_Export2DData()
	//exports 2D calibrated data if user requests it

	NVAR ExpCalib2DData=root:Packages:Convert2Dto1D:ExpCalib2DData
	if(!ExpCalib2DData)
		return 0
	endif
	NVAR RebinCalib2DData=root:Packages:Convert2Dto1D:RebinCalib2DData
	NVAR InclMaskCalib2DData=root:Packages:Convert2Dto1D:InclMaskCalib2DData
	NVAR UseQxyCalib2DData=root:Packages:Convert2Dto1D:UseQxyCalib2DData
	NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
	variable XDimension, YDimension
	SVAR RebinCalib2DDataToPnts=root:Packages:Convert2Dto1D:RebinCalib2DDataToPnts
	strswitch(RebinCalib2DDataToPnts)	// string switch
		case "100x100":		// execute if case matches expression
			XDimension=100
			YDimension=100
			break					// exit from switch
		case "200x200":		// execute if case matches expression
			XDimension=200
			YDimension=200
			break					// exit from switch
		case "300x300":		// execute if case matches expression
			XDimension=300
			YDimension=300
			break					// exit from switch
		case "400x400":		// execute if case matches expression
			XDimension=400
			YDimension=400
			break					// exit from switch
		case "600x600":		// execute if case matches expression
			XDimension=600
			YDimension=600
			break					// exit from switch
		default:							// optional default expression executed
			XDimension=800
			YDimension=800
		endswitch
	//here we get only if user wants to export 2D calibrated data...
	//check the wave of interest exist...
	wave/Z Calibrated2DDataSet = root:Packages:Convert2Dto1D:Calibrated2DDataSet
	if(!WaveExists(Calibrated2DDataSet))
			Abort "Error in NI1A_Export2DData. Calibrated data do not exist..."
			return 0
	endif
	wave/Z Q2DWave = root:Packages:Convert2Dto1D:Q2DWave
	if(!WaveExists(Q2DWave))
			Abort "Error in NI1A_Export2DData. Q2DWave data do not exist..."
			return 0
	endif
	//check for Mask presence...
	if(InclMaskCalib2DData)
		Wave/Z Mask = root:Packages:Convert2Dto1D:M_ROIMask
		if(!WaveExists(Mask))
				Abort "Error in NI1A_Export2DData. Mask data do not exist..."
				return 0
		endif
	endif
	Duplicate/Free Calibrated2DDataSet, IntExp2DData
	Duplicate/Free Q2DWave, QExp2DData
	if(InclMaskCalib2DData)
		Duplicate/O Mask, MaskExp2DData
		//Igor Mask has 0 where masked, 1 where used. This is opposite (of course) to what Nexus/CanSAS uses:
		//Pete:   mask is 1 when the point is removed, 0 when is used. 
		//MatrixOp/O/NTHR=0 MaskExp2DData = abs(MaskExp2DData-1)
		MaskExp2DData = !MaskExp2DData
	else
		Duplicate/Free Q2DWave, MaskExp2DData		//fake for possible rebinning...
	endif
	Wave AnglesWave= root:Packages:Convert2Dto1D:AnglesWave
	Duplicate/Free AnglesWave, AnglesWaveExp

	if(RebinCalib2DData)
		//here we need to create proper rebinned data
		//first need to create UnbinnedQx, and UnbinnedQy
		MatrixOp/Free QxExp2DData = QExp2DData * sin(AnglesWaveExp)
		MatrixOp/Free QyExp2DData = QExp2DData * cos(AnglesWaveExp)
		make/Free/N=(DimSize(QxExp2DData, 0)) UnbinnedQx
		make/Free/N=(DimSize(QyExp2DData, 1)) UnbinnedQy
		UnbinnedQx = QxExp2DData[BeamCenterX][p]
		UnbinnedQy = QyExp2DData[p][BeamCenterY]
		NI1A_RebinOnLogScale2DData(IntExp2DData,QExp2DData, AnglesWaveExp, MaskExp2DData, XDimension, YDimension,BeamCenterX, BeamCenterY)
		MatrixOp/O MaskExp2DData = ceil(MaskExp2DData)	//any point which had mask in it will be masked, I need to revisit this later, if this works. 
	else
		//exporting data in their original size. This may be large for SAXS data sets!
	endif
	//create Qx and Qy if needed, using rebinned data, if these were created.
	if(UseQxyCalib2DData)
		MatrixOp/Free QxExp2DData = QExp2DData * sin(AnglesWaveExp)
		MatrixOp/Free QyExp2DData = QExp2DData * cos(AnglesWaveExp)
	endif

	//get the file name right...
	string LocalUserFileName
	string UseName
	string LongUseName
	SVAR LoadedFile=root:Packages:Convert2Dto1D:FileNameToLoad
	SVAR UserFileName=root:Packages:Convert2Dto1D:OutputDataName
	SVAR TempOutputDataname=root:Packages:Convert2Dto1D:TempOutputDataname
	SVAR TempOutputDatanameUserFor=root:Packages:Convert2Dto1D:TempOutputDatanameUserFor
	NVAR Use2DdataName=root:Packages:Convert2Dto1D:Use2DdataName
	NVAR AppendToNexusFile=root:Packages:Convert2Dto1D:AppendToNexusFile	

	if(AppendToNexusFile)
			UseName=LoadedFile		//this is file we imported, now we need to append to it. 
	else
		if (Use2DdataName)
			UseName=NI1A_TrimCleanDataName(LoadedFile)+".h5"
		else
			if(strlen(UserFileName)<1)	//user did not set the file name
				if(cmpstr(TempOutputDatanameUserFor,LoadedFile)==0 && strlen(TempOutputDataname)>0)		//this file output was already asked for user
					LocalUserFileName = TempOutputDataname
				else
					Prompt LocalUserFileName, "No name for this sample selected, data name is "+ LoadedFile
					DoPrompt /HELP="Input name for the data to be stored, max 20 characters" "Input name for the 1D data", LocalUserFileName
					if(V_Flag)
						abort
					endif
					TempOutputDataname = LocalUserFileName
					TempOutputDatanameUserFor = LoadedFile
				endif
				UseName=NI1A_TrimCleanDataName(LocalUserFileName)+".h5"
			else
				UseName=NI1A_TrimCleanDataName(UserFileName)+".h5"
			endif
		endif
	endif
	if(InclMaskCalib2DData)
		if(UseQxyCalib2DData)
			if(RebinCalib2DData)
				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData, Qx=QxExp2DData, Qy=QyExp2DData, Mask=MaskExp2DData, AzimAngles=AnglesWaveExp,UnbinnedQx=UnbinnedQx,UnbinnedQy=UnbinnedQy)
			else
				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData, Qx=QxExp2DData, Qy=QyExp2DData, Mask=MaskExp2DData, AzimAngles=AnglesWaveExp)
			endif
		else
			if(RebinCalib2DData)
				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData, Mask=MaskExp2DData,Qwv=QExp2DData, AzimAngles=AnglesWaveExp,UnbinnedQx=UnbinnedQx,UnbinnedQy=UnbinnedQy)
			else
				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData, Mask=MaskExp2DData,Qwv=QExp2DData, AzimAngles=AnglesWaveExp)
			endif
		endif
	else
		if(UseQxyCalib2DData)
			if(RebinCalib2DData)
				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData, Qx=QxExp2DData, Qy=QyExp2DData, AzimAngles=AnglesWaveExp,UnbinnedQx=UnbinnedQx,UnbinnedQy=UnbinnedQy)
			else
				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData, Qx=QxExp2DData, Qy=QyExp2DData, AzimAngles=AnglesWaveExp)
			endif
		else
			if(RebinCalib2DData)
				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData,Qwv=QExp2DData, AzimAngles=AnglesWaveExp,UnbinnedQx=UnbinnedQx,UnbinnedQy=UnbinnedQy)
			else
				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData,Qwv=QExp2DData, AzimAngles=AnglesWaveExp)
			endif
		endif	
	endif
end


//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************


Function NI1A_RebinOnLogScale2DData(Calibrated2DData,Qmatrix, AnglesWave, Mask, XDimension, YDimension,BeamCenterX, BeamCenterY)
	wave Calibrated2DData,Qmatrix, AnglesWave, Mask
	variable XDimension, YDimension, BeamCenterX, BeamCenterY
	//here we rebin the data using fake log binning and return really weird data
	//how to rebin the data.
	variable Dim1=DimSize(Calibrated2DData, 0 )		//this is hwo many points we have here. 
	variable Dim2=DimSize(Calibrated2DData, 1)		//this is hwo many points we have here. 
	//assume this is X, so here is how much user wants: XDimension, beam center is BeamCenterX
	variable distance1, distance2
	distance1 = (Dim1 - BeamCenterX)
	distance2 = BeamCenterX
	//this way distance1+distance2 = Dim1
	variable Rebin1, Rebin2
	Rebin1 = ceil(XDimension * distance1/Dim1)
	Rebin2 = ceil(XDimension * distance2/Dim1)
	//now we need to spread around points correctly... N is original number of points, M is output number of points. 
	//average in each M point is N/M, so M array starts from 1 and goes to 2*N/M - 1, use Round to have the values integers.
	Make/Free/N=(ceil(Rebin1)) Rebin1Wv, Rebin2Wv
	Rebin1Wv = round(1+p/(Rebin1-1) * ((2*distance1/Rebin1)-2))
	Rebin2Wv = round(1+p/(Rebin2-1) * ((2*distance2/Rebin2)-2))
	//now rebinning...
	make/Free/N=(XDimension,Dim2) CalDataRebin1, QmatrixRebin1, MaskRebin1,AnglesRebin1
	variable i, j, ii, jj, iii
	ii = -1
	jj = BeamCenterX
	For(i=ceil(BeamCenterX*XDimension/Dim1);i<XDimension;i+=1)
		ii+=1
		FOr(j=0;j<Rebin1Wv[ii];j+=1)
			CalDataRebin1[i][] += Calibrated2DData[j+jj][q]
			QmatrixRebin1[i][] += Qmatrix[j+jj][q]
			AnglesRebin1[i][] += AnglesWave[j+jj][q]
			MaskRebin1[i][] 	+= Mask[j+jj][q]
		endfor
		CalDataRebin1[i][]/=Rebin1Wv[ii]
		QmatrixRebin1[i][]/=Rebin1Wv[ii]
		AnglesRebin1[i][]/=Rebin1Wv[ii]
		MaskRebin1[i][]/=Rebin1Wv[ii]
		jj += Rebin1Wv[ii]
	endfor
	//now the other side
	ii = -1
	jj = BeamCenterX
	For(i=floor(BeamCenterX*XDimension/Dim1);i>=0;i-=1)
		ii+=1
		FOr(j=0;j<Rebin2Wv[ii];j+=1)
			CalDataRebin1[i][] += Calibrated2DData[jj-j][q]
			QmatrixRebin1[i][] += Qmatrix[jj-j][q]
			AnglesRebin1[i][] += AnglesWave[jj-j][q]
			MaskRebin1[i][] += Mask[jj-j][q]
		endfor
		CalDataRebin1[i][]/=Rebin2Wv[ii]
		QmatrixRebin1[i][]/=Rebin2Wv[ii]
		AnglesRebin1[i][]/=Rebin2Wv[ii]
		MaskRebin1[i][]/=Rebin2Wv[ii]
		jj -= Rebin2Wv[ii]
	endfor
	//now the other dimension
	distance1 = (Dim2 - BeamCenterY)
	distance2 = BeamCenterY
	Rebin1 = ceil(YDimension * distance1/Dim2)
	Rebin2 = ceil(YDimension * distance2/Dim2)
	Make/Free/N=(ceil(Rebin2)) Rebin1Wv2, Rebin2Wv2
	Rebin1Wv2 = round(1+p/(Rebin1-1) * ((2*distance1/Rebin1)-2))
	Rebin2Wv2 = round(1+p/(Rebin2-1) * ((2*distance2/Rebin2)-2))
	make/Free/N=(XDimension,YDimension) CalDataRebin2, QmatrixRebin2, MaskRebin2, AnglesRebin2
	ii = -1
	jj = BeamCenterY
	For(i=ceil(BeamCenterY*YDimension/Dim2);i<YDimension;i+=1)
		ii+=1
		FOr(j=0;j<Rebin1Wv2[ii];j+=1)
			CalDataRebin2[][i] += CalDataRebin1[p][j+jj]
			QmatrixRebin2[][i] += QmatrixRebin1[p][j+jj]
			AnglesRebin2[][i] += AnglesRebin1[p][j+jj]
			MaskRebin2[][i] 	+= MaskRebin1[p][j+jj]
		endfor
		CalDataRebin2[][i]/=Rebin1Wv2[ii]
		QmatrixRebin2[][i]/=Rebin1Wv2[ii]
		AnglesRebin2[][i]/=Rebin1Wv2[ii]
		MaskRebin2[][i]/=Rebin1Wv2[ii]
		jj += Rebin1Wv2[ii]
	endfor
	//now the other side
	ii = -1
	jj = BeamCenterY
	For(i=floor(BeamCenterY*YDimension/Dim1);i>=0;i-=1)
		ii+=1
		FOr(j=0;j<Rebin2Wv2[ii];j+=1)
			CalDataRebin2[][i] += CalDataRebin1[p][jj-j]
			QmatrixRebin2[][i] += QmatrixRebin1[p][jj-j]
			AnglesRebin2[][i] += AnglesRebin1[p][jj-j]
			MaskRebin2[][i] += MaskRebin1[p][jj-j]
		endfor
		CalDataRebin2[][i]/=Rebin2Wv2[ii]
		QmatrixRebin2[][i]/=Rebin2Wv2[ii]
		AnglesRebin2[][i]/=Rebin2Wv2[ii]
		MaskRebin2[][i]/=Rebin2Wv2[ii]
		jj -= Rebin2Wv2[ii]
	endfor	
	Duplicate/O CalDataRebin2,Calibrated2DData
	Duplicate/O QmatrixRebin2,Qmatrix
	Duplicate/O AnglesRebin2,AnglesWave
	Duplicate/O MaskRebin2,Mask
end
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
