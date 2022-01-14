#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method.
//#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.73
#include <TransformAxis1.2>

//*************************************************************************\
//* Copyright (c) 2005 - 2022, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.73 5-24-2021 changed resolution to be FWHM/2, same as USAXS and as expected by Modeling package and sasView. 
//		modifed NI1A_CalculateQresolution to return FWHM and use only Q steps and Beam size. Pixel size used before is wrong, that is accounted for in Q stepping already, Nika cannot oversample in Q points. 
//2.72 Remove for MatrixOP /NTHR=0 since it is applicable to 3D matrices only 
//2.71 Added NI1A_ImportThisJPGFile which adds functionality ONLY for 9IDC USAXS/SAXS/WAXS instrument. Should never run else. 
//2.70 fixed NI1A_FindeOrderNumber to utilize for sorting in "_001" option the last number, ignores any string, even if at the end of name. 
//			can sort nases as "name_With_Order_0001344_waxs.tif" based on teh 0001344 
//2.69 fixed NI1A_GenerAngleLine for angles between 135 - 360 deg. Allow negative angles, If Angle<0, Angle = 180+Angle
//2.68 Fixed to accept tiff as tif extension.
//2.67 Added Batch processing
//2.66 fixes for rtGlobal=3
//2.65 fixerd solid angle correction. It was doing the wrong thing. 
//2.64 added new tab with Save data opions, seems better. Removed range selections. Added controls for delay between images and display ImageStatistics. 
//2.63 fix bug when user did stuff our of order. 
//2.62 fixed single precision rounding error (ki and kout were single precision) which caused under some cconditions problems with data at low-q bining. 
//2.61 fixed erros for case where we have missing range of Q in the middle of detecotr (space between tiles on Pilatus). 
//2.60 fixed case when for intensities=0 (set in software like Mar165) we wouldget error=0 and users would consider these regular data points. Removed now. 
//2.59 tried to speed up the main conversion loop. Fixed case where for negative intensities we can get nan as uncertainty and for Int=0 uncertainty=0.
//2.58 added saving color table in preferences. 
//2.57 removed unused functions
//2.56 added getHelp button calling to www manual
//2.55 fixed missing forced naming to data. Now will force use of File name fopr naming the data if nothign else is selected.
//2.54 added a lot of 	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"") in the code here. 
//2.53 important correction - prior versions did NOT have samplethickness converted to cm, so this may break prior exerimets calibrations. 
//2.52 changed selection options for data
//2.51 New nexus support fixes. Pops up now the panel as needed and sets the input choice. 
//2.50 Modified to point to USXS_data on USAXS computers, added handling of ...tiff file names
//2.49 added Function for creating user custom data names. 
//2.48 added main data reduction parameters in the wave note. For unknown reason were missing. 
//2.47 added time stamps to background task print statements so user has any idea when was the task run last time. 
//2.46 added Q width (Q resolution, dQ) to line profiles. Works only for Q for now, fix for bug in Qresolution callcualtions in version 2.45
//2.45 added Qresolution accounting which takes care of bin width + pixel size + beam size
//2.44 fixed bug when 2DQwave had note appended, not repalced and if beam center changed, it will get recaculated always since a wrong center values were read first. 
//2.43 added ability to type in Q distance from center for line profile. Is rounded to nearest full pixel. 
//2.42 minor GISAXS panel update (kill it on tab change). 
//2.41 GISAXS panel now updates lineprofile, when value changes. 
//2.40 added GISAXS_SOL and GISAXS_LSS geomtries - vary for alfa-f per marvin infor from below. Uses new panel and variable. 
//2.39 fixed GISAXS alfa-f calculation. Bug found by one of the users marvin.berlinghof@fau.de
//2.38 removed Executes as preparation for Igor 7
//2.37 renamed tab "Prev" into "PolTran" = Polar transform. This seems better descrition of the conversion. 
//2.36 added ADSC_A
//2.35 moved Dezinger to tab 2 - some users thought, that dezingenring is available only for empty and dark.  
//2.34 can read/write canSAS/Nexus files. Can log-bin 2D data and use those. 
//2.33 fixed display of files for CanSAS/Nexus file type
//2.32 fixed case, when user wanted to display processed data, but the images were created/updated before the processed data were even created. 
//2.31 added hook functions, required change in main panel function from macro to function and therefore also renaming it. 
//2.30 Added right click "Refresh content" to Listbox and other functionality
//2.29 fixed /NTHR=1 to  
//2.28 add ability to load and use 2D calibrated data (from EQSANS for now)
//2.27 adds DataCalibrationString to GUI and Intensity/q/theta/d/distance data 
//2.26 added double clicks to Mask listbox and to Empty/Dark listboxes. 
//2.25 adds TPA/XML code
//2.24 minor GUI improvements
//2.23 Refresh now sets top data set as selected. Added first version of background task monitoring folder...
//2.22 added user defined Image range and display color scale... 
//2.21 added export in distacne from center, minor fix in search for match files
//2.20 changed behavior to enable calculation of smeared data in 9IDC SAXS instrument
//2.19 fixed NI1A_UpdateEmptyDarkListBox() for bug (was looking in wrong path...)
//2.18 fixed UpdateEmptyDark File list 
//2.17 Support for SAXS and Nexus file reader, fixed loadEMpty/dark bug which used wrong extension for file 
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

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	
	Duplicate/O QvectorA, Qvector, Intensity, Error
	Duplicate/O QvectorWidth, Qsmearing
	Duplicate/O TwoThetaA, TwoTheta
	Duplicate/O TwoThetaWidthA, TwoThetaWidth
	Duplicate/O DistanceInmmA, DistanceInmm
	Duplicate/O DistacneInmmWidthA, DistacneInmmWidth
	Duplicate/O DspacingA, Dspacing
	Duplicate/O DspacingWidthA, DspacingWidth
	Intensity=0
	Error=0
	//variable i, j, counter, numbins, start1, end1
	MatrixOp/Free  tempInt = LUT
	tempInt = Calibrated2DDataSet
	//following si probably slow, but IndexSort cannot be multithreaded... 
	IndexSort LUT, tempInt
	//Duplicate/O tempInt, TempIntSqt
	MatrixOp/Free  TempIntSqt = tempInt* tempInt
	//variable timerRefNum
	//timerRefNum = StartMSTimer
	//counter = HistogramWv[0]
	//	For(j=1;j<QvectorNumberPoints;j+=1)
	//		numbins = HistogramWv[j]
	//		if(numbins>0)
	//			//Intensity[j] = sum(tempInt, pnt2x(tempInt,Counter), pnt2x(tempInt,Counter+numbins-1))		//this cointains sum Xi
	//			//Error[j] = sum(TempIntSqt, pnt2x(tempInt,Counter), pnt2x(tempInt,Counter+numbins-1))			//this now contains sum Xi^2
	//			//assuming standard point scaling the pnt2x is not necessary... This should speed it up...
	//			Intensity[j] = sum(tempInt,Counter, Counter+numbins-1)			//this cointains sum Xi
	//			Error[j] = sum(TempIntSqt, Counter, Counter+numbins-1)			//this now contains sum Xi^2
	//		endif
	//		Counter+=numbins
	//	endfor

	//2017-06-27 new, faster method for larger number of destination points... Few times faster for large number of points. 
	MatrixOp/Free  HistogramWvTemp = HistogramWv
	MatrixOp/Free  TempHistSum = HistogramWv
	SetScale/I x 0,numpnts(TempHistSum)-1,"", TempHistSum, HistogramWvTemp
	Multithread TempHistSum = sum(HistogramWvTemp,0,p)
	//this is 2018-03-1 old method which seems to fail and has error in normalization by nuber of bins. 
	//Multithread Intensity[1,numpnts(Intensity)-1] = sum(tempInt,TempHistSum[p-1],TempHistSum[p])
	//MatrixOp/O  Intensity=Intensity/HistogramWv			//This is average intensity....
	//basially, the above has problem, that the binning has always 1 more point included, so this does not work for 1 bin large bins here
	
	Multithread Intensity[1,numpnts(Intensity)-1] = (TempHistSum[p] - TempHistSum[p-1] )>0 ? sum(tempInt,TempHistSum[p-1],TempHistSum[p]) : 0
	Multithread Error[1,numpnts(Error)-1] = sum(TempIntSqt,TempHistSum[p-1],TempHistSum[p])
	
//	//suggested by Wavemetrics another way... I am unable to make this work at this time...
//		//Yes, MatrixOP is a possible solution.
//		//First notice that your indexWave needs to be converted into a matrix using the following rule:
//		//Initialize the matrix to zero.
//		//Each row of the matrix contains as many columns as there are points in source wave.	
//		//In each row set to 1 the index of the elements that you want to sum.  The result is simply
//		//MatrixOP/o result=indexMatrix x sourceWave
//		make/Free/N=(numpnts(HistogramWv),numpnts(Intensity)) indexWaveM 
//		MatrixOp  indexWaveM = 0
//		
	
	//print StopMSTimer(timerRefNum)	
	MatrixOp/Free  TempSumXi=Intensity				//OK, now we have sumXi saved
	MatrixOp/O  Intensity=Intensity/(HistogramWv+1)			//This is average intensity...., for +1 see above notes. 
	//MatrixOp/O  Intensity=Intensity/(HistogramWv)			//This is average intensity...., for +1 see above notes. 
	Intensity = (HistogramWv>0) ? Intensity[p] : NaN
	MatrixOp/O  Intensity = replace(Intensity,inf,nan)

	//version 1.43 December 2009, changed uncertainity estimates. Three new methods now available. Old method which has weird formula, standard deviation and standard error fof mean ...
	NVAR ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
	NVAR ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
	NVAR ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
	//change in the Configuration panel. 	
	if(ErrorCalculationsUseOld)	//this is the old code... Hopefully I did not screw up. 
		MatrixOp/O  Error=sqrt(abs(Error - (TempSumXi*TempSumXi))/(HistogramWv - 1))	
		MatrixOp/O  Error=Error/HistogramWv
	else //now new code. Need to calculate standard deviation anyway... 
		//variance  = (Error - (Intensity^2 / Histogram)) / (Histogram - 1)
		//st deviation = sqrt(variance)
		MatrixOp/O  Error = sqrt(abs(Error - (TempSumXi*TempSumXi / HistogramWv)) / clip((HistogramWv - 1),1,inf))	//modified 2022-01-05, this clip shoudl avoid infs/Nans due to histrogramWv-1 being 0
		if(ErrorCalculationsUseSEM)
			//error_mean=stdDev/sqrt(Histogram)			use Standard error of mean...
			MatrixOp/O  Error = Error /sqrt(HistogramWv)
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
	
	//this fix is same for all - if there is only 1 point in the bin, simply use sqrt of intensity... Of course, this can be really wrong, since by now this is fully calibrated and hence sqrt is useless... 
	Error = (HistogramWv[p]>1)? Error[p] : sqrt(abs(Intensity[p]))		//for negative intensities this can give nan, so take abs(int)
	//now handling of case where we have error=0, which is possible only if Intensity=0 for each point summed together.  
	Error = Error[p]>0 ? Error[p] : NaN								//for Int=0 we could have error = 0 if all points have 0 intensity, which is degenerate case (bad masking). 
	note Intensity, OldNote
	note Error, OldNote
	//remove first point - it contains all the masked points set to Q=0...
	DeletePoints 0,1, intensity, error, Qvector, Qsmearing, TwoTheta, TwoThetaWidth, Dspacing, DspacingWidth, DistanceInmm, DistacneInmmWidth
	//remove any Nan points (set to Nan by error evaluation above). 
	IN2G_RemoveNaNsFrom10Waves(intensity, error, Qvector, Qsmearing, TwoTheta, TwoThetaWidth, Dspacing, DspacingWidth, DistanceInmm, DistacneInmmWidth)
	//now fix oversubtraction of background, if selected.
	NVAR FixBackgroundOversubtraction = root:Packages:Convert2Dto1D:FixBackgroundOversubtraction
	if(FixBackgroundOversubtraction)
		//need to find out minimum of Intensity
		Wavestats/Q/Z Intensity
		//V_min is the lowest value we got, likely negative.
		if(V_min<0)	//it is negative
			//add FixBackgroundOversubScale 8 abs(V_min), fix FixBackgroundOversubScale in NI1_Main.ipf
			Intensity+=FixBackgroundOversubScale * abs(V_min)
		endif
		
	endif
	
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_CalculateQresolution(Qvector,QvectorWidth,TwoThetaWidth, DistacneInmmWidth, DspacingWidth, PixX,PixY,BeamX,BeamY,Wavelength,SampleToCCDdistance)
	wave Qvector, QvectorWidth, TwoThetaWidth, DistacneInmmWidth, DspacingWidth
	variable PixX,PixY,BeamX,BeamY, Wavelength,SampleToCCDdistance
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//note the Qresolution already has accounted for bin width for integration.
	
	//as caulcated above... 
	//QvectorWidth this is center to center distace of two Q points. This is equivalenth to FWHM estimate, it is rectangle
	//QvectorWidth[0,numpnts(Qvector)-2] = Qvector[p+1] - Qvector[p]
	//QvectorWidth[numpnts(Qvector)-1]=QvectorWidth[numpnts(Qvector)-2]
	///////
	//this function will caculate Q resolution for each q point given by pixel size and beam size
	//for simplicity this is done in perpendicular detector approximation (no tilts)
	//assume we can calculate width of the pixes/beam in 45 degrees (max dimension) and the 2/3 of that as FWHM
	//this is midlessly approximate, but seems acceptable
	//then we will convolute this with Qresolution going in and these two values 
	//this thing is called in NI1A_AverageDataPerUserReq
	variable constVal=Wavelength / (4 * pi)
	variable PixDim, BeamDim
	PixDim=  sqrt(PixX^2 + PixY^2)					//this is width in mm of the pixel along diagonal direction
	PixDim = PixDim * 2/3							//assume this is FWHM of the pixel sensitivity, in mm - the 2/3 is there to convert this into FWHM somehow.
	//However, the pixel size and integration width are quite similar in logic. So let's try to make some corrections here. If there was no integration width, we should see FWHM ~ 2/3 of the 
	//total width of the bin to represent the FWHM. I tested this with case example, and either one can have square bin width (and then it is rectangle) or use FWHM, then the bin width s 2/3 of the square, approximately. 
   // If we are going to convolute these together later, we should correct the QvectorWidth coming from binning to smaller numbers, BUT only for bins approximately wide as the pixel width
   // this requires transition from 2/3 correction to use of full bin width as the bin width increases. This is bit cumbersome. 
   // assume that if the bin width is less than 3*pixDim, we should use FWHM, at higher bin widths lets assume bin width and keep this. 
   variable pixDiminQ
   pixDiminQ = sin(atan(PixDim/SampleToCCDDistance)/2)/constVal
   QvectorWidth = (QvectorWidth[p] < 1.5 * pixDiminQ) ? (2*QvectorWidth[p]/3) : QvectorWidth[p]
	//	
	BeamDim = sqrt(BeamX^2 + BeamY^2)			//width of beam size in mm along diagonal direction
	BeamDim = BeamDim * 2 /3						//assume this is estimated FWHM of the beam sensitivity, in mm - the 2/3 is there to convert this into FWHM somehow. 
	Duplicate/Free Qvector, TwoTheta, DistacneInmm, DistInmmLow, DistInmmHigh, TempPixQres,  TempBeamQres, TmpQlow, TmpQhigh
	Duplicate/Free Qvector, TempDBeam, TempDPix, tempTTBeam, tempTTPix, tempDistBeam, tempDistPix
	TwoTheta =  2 * asin ( Qvector * constVal) 
	DistacneInmm = SampleToCCDDistance*tan(TwoTheta)			//this is distance in mm for each pixel. 
	
	//calculate the effect of pixel Size here...
	DistInmmLow = DistacneInmm - (PixDim/2)						//this is low edge of distance, in mm of the pixel start
	DistInmmHigh = DistacneInmm + (PixDim/2)						//this is high edge of distance, in mm of the pixel start
	tempDistPix = PixDim											//this is DistanceInmm FWHM due to pixel size
	// atan(DistInmmLow/SampleToCCDDistance)/2 is theta (bragg angle)
	tempTTPix = (atan(DistInmmHigh/SampleToCCDDistance)/2 - atan(DistInmmLow/SampleToCCDDistance)/2)*180/pi		//this is TwoTheta FWHM due to pixel size
	TmpQlow = sin(atan(DistInmmLow/SampleToCCDDistance)/2)/constVal			//and this should be qmin of the FWHM of the pixel
	TmpQhigh = sin(atan(DistInmmHigh/SampleToCCDDistance)/2)/constVal			//and this qmax of the FWHM of the pixel
	TempDPix = (constVal/TmpQlow) - (constVal/TmpQhigh)							//this is FWHM of d distribution due to pixel size
	TempPixQres = TmpQhigh - TmpQlow
	//end of pixel size effect... 
	
	//calculate the effect of beam Size here...
	DistInmmLow = DistacneInmm - (BeamDim/2)					//this is low edge of distance, in mm of the BeamDim start
	DistInmmHigh = DistacneInmm + (BeamDim/2)				 //this is high edge of distance, in mm of the BeamDim start
	tempDistBeam = BeamDim									//this is DistanceInmm FWHM due to BeamDim size
	// atan(DistInmmLow/SampleToCCDDistance)/2 is theta (bragg angle)
	tempTTBeam = (atan(DistInmmHigh/SampleToCCDDistance)/2 - atan(DistInmmLow/SampleToCCDDistance)/2)*180/pi		//this is TwoTheta FWHM due to BeamDim size
	TmpQlow = sin(atan(DistInmmLow/SampleToCCDDistance)/2)/constVal			//and this should be qmin of the FWHM ofthe BeamDim
	TmpQhigh = sin(atan(DistInmmHigh/SampleToCCDDistance)/2)/constVal			//and this qmax of the FWHM ofthe BeamDim
	TempDBeam = (constVal/TmpQlow) - (constVal/TmpQhigh)						//this is FWHM of d distribution due to BeamDim size
	TempBeamQres = TmpQhigh - TmpQlow
	//now, QvectorWidth is larger of QvectorWidth and TempPixQres
	QvectorWidth = QvectorWidth[p]>TempPixQres[p] ? QvectorWidth[p] : TempPixQres[p]
	TwoThetaWidth = TwoThetaWidth[p]> tempTTPix[p] ? TwoThetaWidth[p] : tempTTPix[p]
	DistacneInmmWidth = DistacneInmmWidth[p]>tempDistPix[p] ? DistacneInmmWidth[p] : tempDistPix[p]
	DspacingWidth = DspacingWidth[p]>TempDPix[p] ? DspacingWidth[p] : TempDPix[p]
	//now convolute this... 
	QvectorWidth = sqrt(QvectorWidth[p]^2 + TempBeamQres[p]^2)
	TwoThetaWidth = sqrt(TwoThetaWidth[p]^2 + tempTTBeam[p]^2)
	DistacneInmmWidth = sqrt(DistacneInmmWidth[p]^2 + tempDistBeam[p]^2)
	DspacingWidth = sqrt(DspacingWidth[p]^2 + TempDBeam[p]^2)	
	//convert all of these into 1/2 of FWHM, above are FWHM
	QvectorWidth/=2
	TwoThetaWidth/=2
	DistacneInmmWidth/=2
	DspacingWidth/=2
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_CorrectDataPerUserReq(orientation)
	string orientation
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	NVAR CorrectSelfAbsorption = root:Packages:Convert2Dto1D:CorrectSelfAbsorption
	
	NVAR DoGeometryCorrection=root:Packages:Convert2Dto1D:DoGeometryCorrection

	NVAR Use2DPolarizationCor = root:Packages:Convert2Dto1D:Use2DPolarizationCor
	NVAR DoPolarizationCorrection = root:Packages:Convert2Dto1D:DoPolarizationCorrection

	NVAR UseCalib2DData=root:Packages:Convert2Dto1D:UseCalib2DData
	
	Wave DataWave=root:Packages:Convert2Dto1D:CCDImageToConvert
	Wave/Z EmptyRunWave=root:Packages:Convert2Dto1D:EmptyData
	Wave/Z DarkCurrentWave=root:Packages:Convert2Dto1D:DarkFieldData
	Wave/Z MaskWave=root:Packages:Convert2Dto1D:M_ROIMask
	Wave/Z Pix2DSensitivity=root:Packages:Convert2Dto1D:Pixel2DSensitivity
	//Wave/Z SolAngCor2Dwave = root:Packages:Convert2Dto1D:SolAngCor2Dwave //2022-01 - this is not needed, 2D Solid angle correction is combination of SOlidAngle Correction AND geometry correction. 
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
	if(UsePixelSensitivity &&!UseCalib2DData)
		if(!WaveExists(Pix2DSensitivity) || DimSize(Pix2DSensitivity, 0)!=DimSize(DataWave, 0) || DimSize(Pix2DSensitivity, 1)!=DimSize(DataWave, 1))
			abort "Pix2D Sensitivity problem - either does not exist or has differnet dimensions that data "
		endif
	endif
	//if(UseSolidAngle&&!UseCalib2DData)
	//	if(!WaveExists(SolAngCor2Dwave))
	//		abort "SOlid ANgle Correction wave does nto exist. Change some parameters to recalculate geometry and try again. "
	//	endif
	//endif

	//MatrixOP/O/S   Calibrated2DDataSet = DataWave		// MatrixOP/O does NOT preserve wavenote...  
	Duplicate/O DataWave,  Calibrated2DDataSet
	
	Wave Calibrated2DDataSet=root:Packages:Convert2Dto1D:Calibrated2DDataSet
	//redimension/S Calibrated2DDataSet		//2022-01 needed??? 
	string OldNote=note(Calibrated2DDataSet)

	variable tempVal
	variable CalibrationPrefactor=1
	
	if(!UseCalib2DData)
		if(UseCorrectionFactor)
			CalibrationPrefactor*=CorrectionFactor
		endif
		if(UseSolidAngle)		//Combined with Gemoetry Correction this results in angle dependent solid angle correction.  
			variable solidAngle =PixelSizeX/SampleToCCDDistance * PixelSizeY/SampleToCCDDistance
			//print solidAngle
			//fixed bug 10-13-2018, was multiplying by solid angle. not dividing.But we need to divide by solid angle - if the detector is further, we see less of area, 
			//well, this is approximate, but should be just fine... my testing shows, that for 30mm far pixel with 0.3mm size the difference is less than 4e-4... Who cares?
			CalibrationPrefactor/=solidAngle
		endif
		if(UseI0ToCalibrate)
			CalibrationPrefactor/=SampleI0
		endif
		if(UseSampleThickness)
			CalibrationPrefactor/=(SampleThickness/10)		//NOTE: changed in ver 1.75 (1/2017), previously was not converted to cm.
			//this is potentially breaking calibration of prior experiments. Need User warning! 
		endif
	
		MatrixOP/O   tempDataWv = DataWave
		MatrixOP/O   tempEmptyField = DataWave
		//redimension/S tempDataWv, tempEmptyField - needed??? 
		Wave tempDataWv
		Wave tempEmptyField
		tempEmptyField=0
		
		if(UsePixelSensitivity)
			MatrixOP/O  tempDataWv=tempDataWv/Pix2DSensitivity
		endif
		//if(UseSolidAngle)		//2022-01 - this is not needed, 2D Solid angle correction is combination of SOlidAngle Correction AND geometry correction. 
		//	MatrixOP/O  tempDataWv=tempDataWv/SolAngCor2Dwave
		//endif

		if(UseDarkField)
			if(UseSampleMeasTime && UseDarkMeasTime)
				if(UsePixelSensitivity)
					tempVal = SampleMeasurementTime/BackgroundMeasTime
					MatrixOP/O  tempDataWv = tempDataWv - (tempVal*DarkCurrentWave/Pix2DSensitivity)
				else
					tempVal = SampleMeasurementTime/BackgroundMeasTime
					MatrixOP/O  tempDataWv = tempDataWv - (tempVal*DarkCurrentWave)
				endif
			else
				if(UsePixelSensitivity)
					MatrixOP/O  tempDataWv = tempDataWv - (DarkCurrentWave/Pix2DSensitivity)
				else
					MatrixOP/O  tempDataWv = tempDataWv - DarkCurrentWave
				endif
			endif
		endif
		if(UseSubtractFixedOffset)
			MatrixOP/O  tempDataWv = tempDataWv - SubtractFixedOffset
		endif
		if(UseSampleTransmission)
			//this is normal correcting by one transmission. 
			MatrixOP/O  tempDataWv=tempDataWv/SampleTransmission
			if(CorrectSelfAbsorption && SampleTransmission<1)
				variable MuCalc=-1*ln(SampleTransmission)/SampleThickness
				variable muD = MuCalc*SampleThickness
				Wave Theta2DWave = root:Packages:Convert2Dto1D:Theta2DWave		//this is actually Theta in radians. 
				if(DimSize(Theta2DWave, 0 )!=DimSize(tempDataWv, 0) || DimSize(Theta2DWave, 1)!=DimSize(tempDataWv, 1) )
					NI1A_Create2DQWave(tempDataWv)				//creates 2-D Q wave does not need to be run always...
					NI1A_Create2DAngleWave(tempDataWv)			//creates 2-D Azimuth Angle wave does not need to be run always...
				endif 	
				MatrixOP/free  SelfAbsorption2D=tempDataWv
				//next is formula 29, chapter 3.4.7 Brain Pauw paper
				MatrixOp/Free  MuDdivCos2TH=MuD*rec(cos(2*Theta2DWave))
				MatrixOp/Free  OneOverBottomPart = rec( -1*MuDdivCos2TH + MuD)
				variable expmud=exp(muD)
				variable expNmud=exp(-1*MuD)
				MatrixOP/O  SelfAbsorption2D=expmud * (exp(-MuDdivCos2TH) - expNmud) * OneOverBottomPart
				//replace nans around center... 
				MatrixOP/O  SelfAbsorption2D=replaceNaNs(SelfAbsorption2D,1)
				//and now correct... 
				MatrixOP/O  tempDataWv=tempDataWv / SelfAbsorption2D
				if(IrenaDebugLevel>1)
					variable MaxCorrection
					wavestats SelfAbsorption2D
					MaxCorrection = 1/wavemin(SelfAbsorption2D)
					print "Sample self absorption correction max is : "+num2str(MaxCorrection) 
				endif
			else
				//print "Could not do corection for self absorption, wrong parameters" 
			endif
		endif
		variable ScalingConstEF=1
	
		if(UseEmptyField)
			tempEmptyField = EmptyRunWave
			if(UsePixelSensitivity)
				MatrixOP/O  tempEmptyField = tempEmptyField/Pix2DSensitivity
			endif
			if(UseSubtractFixedOffset)
				MatrixOP/O  tempEmptyField = tempEmptyField - SubtractFixedOffset
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
						MatrixOP/O  tempEmptyField=tempEmptyField - (tempVal*(DarkCurrentWave/Pix2DSensitivity))
					else
						tempVal = EmptyMeasurementTime/BackgroundMeasTime
						MatrixOP/O  tempEmptyField=tempEmptyField - (tempVal*DarkCurrentWave)
					endif
				else
					if(UsePixelSensitivity)
						MatrixOP/O  tempEmptyField=tempEmptyField - (DarkCurrentWave/Pix2DSensitivity)
					else
						MatrixOP/O  tempEmptyField=tempEmptyField - DarkCurrentWave
					endif
				endif
			endif
	
		endif
	
		MatrixOP/O  Calibrated2DDataSet = CalibrationPrefactor * (tempDataWv - ScalingConstEF * tempEmptyField)
		
		if(DoGeometryCorrection)  		//geometry correction (= cos(angle)^3) for solid angle projection, added 6/24/2006 to do in 2D data, not in 1D as done (incorrectly also) before using Dales routine.
			NI1A_GenerateGeometryCorr2DWave()
			Wave GeometryCorrection
			MatrixOp/O  Calibrated2DDataSet = Calibrated2DDataSet / GeometryCorrection
		endif
		if(DoPolarizationCorrection)		//added 8/31/09 to enable 2D corection for polarization
			NI1A_Generate2DPolCorrWv()
			Wave polar2DWave
			MatrixOp/O  Calibrated2DDataSet = Calibrated2DDataSet / polar2DWave 		//changed to "/" on October 12 2009 since due to use MatrixOp in new formula the calculate values are less than 1 and this is now correct. 
		endif
		
		//Add to note:
		//need to add also geometry parameters
		NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
		NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
		NVAR BeamSizeX=root:Packages:Convert2Dto1D:BeamSizeX
		NVAR BeamSizeY=root:Packages:Convert2Dto1D:BeamSizeY
		NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt
		NVAR XrayEnergy=root:Packages:Convert2Dto1D:XrayEnergy
		NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt
		NVAR PixelSizeX=	root:Packages:Convert2Dto1D:PixelSizeX
		NVAR PixelSizeY=	root:Packages:Convert2Dto1D:PixelSizeY
		NVAR SampleToCCDDistance=	root:Packages:Convert2Dto1D:SampleToCCDDistance
		NVAR Wavelength=	root:Packages:Convert2Dto1D:Wavelength
		OldNote+= "Nika_SampleToDetectorDistacne="+num2str(SampleToCCDDistance)+";"
		OldNote+= "Nika_Wavelength="+num2str(Wavelength)+";"
		OldNote+= "Nika_XrayEnergy="+num2str(XrayEnergy)+";"
		OldNote+= "Nika_PixelSizeX="+num2str(PixelSizeX)+";"
		OldNote+= "Nika_PixelSizeY="+num2str(PixelSizeY)+";"
		OldNote+= "Nika_HorizontalTilt="+num2str(HorizontalTilt)+";"
		OldNote+= "Nika_VerticalTilt="+num2str(VerticalTilt)+";"
		OldNote+= "Nika_BeamCenterX="+num2str(BeamCenterX)+";"
		OldNote+= "Nika_BeamCenterY="+num2str(BeamCenterY)+";"
		OldNote+= "Nika_BeamSizeX="+num2str(BeamSizeX)+";"
		OldNote+= "Nika_BeamSizeY="+num2str(BeamSizeY)+";"
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
	NVAR UseSolidAngle=root:Packages:Convert2Dto1D:UseSolidAngle
	if(UseSolidAngle)
		OldNote+= "SolidAngleCorrection=Done"+";"
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
		MatrixOp/O    A2Theta2DWave =  2 * Theta2DWave
		if(Use1DPolarizationCor)
			//	Int=Int/( (1+cos((2theta))^2)/2	)
		    	MatrixOP/O  polar2DWave = (1+cos(A2Theta2DWave))/2
		else			//at least partially polarized radiation
			if(abs(StartAngle2DPolCor)<1)
			     	MatrixOP/O  polar2DWave = (TwoDPolarizFract*(powR(cos(A2Theta2DWave),2) * powR(cos(AnglesWave),2)+powR(sin(AnglesWave),2)) +(1-TwoDPolarizFract)*(powR(cos(A2Theta2DWave),2)*powR(sin(AnglesWave),2)+powR(cos(AnglesWave),2)))
			//note, matrixOp cannot do 1/ therefore changed to use 1/ in calling function....
			else
				Duplicate/O AnglesWave, TempAnglesWave
				NVAR beamCenterX=root:Packages:Convert2Dto1D:beamCenterX
				NVAR beamCenterY=root:Packages:Convert2Dto1D:beamCenterY
				//Now angle from 0 degrees, so we can do sectors if necessary
				TempAnglesWave = abs(atan2((BeamCenterY-q),(BeamCenterX-p))-pi+OffsetInRadians)			
			       MatrixOP/O  polar2DWave = (TwoDPolarizFract*(powR(cos(A2Theta2DWave),2) * powR(cos(TempAnglesWave),2)+powR(sin(TempAnglesWave),2)) +(1-TwoDPolarizFract)*(powR(cos(A2Theta2DWave),2)*powR(sin(TempAnglesWave),2)+powR(cos(TempAnglesWave),2)))
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	
	Wave/Z GeometryCorrection = root:Packages:Convert2Dto1D:GeometryCorrection
	Wave DataWave=root:Packages:Convert2Dto1D:CCDImageToConvert
	NVAR SampleToCCDDistance = root:Packages:Convert2Dto1D:SampleToCCDDistance
	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength

	Wave/Z Q2DWave = root:Packages:Convert2Dto1D:Q2DWave
	if(!WaveExists(Q2DWave))
		NI1A_Create2DQWave(DataWave)			//creates 2-D Q wave 
		wave Q2DWave = root:Packages:Convert2Dto1D:Q2DWave
	endif
	string O2N = note(Q2DWave)

	variable recalculate=1
	if(WaveExists(GeometryCorrection))
		string OGN= note(GeometryCorrection)
		//BeamCenterX=501.19;BeamCenterY=506.05;PixelSizeX=0.1;  PixelSizeY=0.1;HorizontalTilt=0;VerticalTilt=0;SampleToCCDDistance=250.5;Wavelength=1.541;
		variable Match1=0, Match2=0, Match3=0, Match4=0, Match5=0
		if(abs(NumberByKey("BeamCenterX",OGN,"=",";")-NumberByKey("BeamCenterX",O2N,"=",";"))<0.01 && abs(NumberByKey("BeamCenterY",OGN,"=",";")-NumberByKey("BeamCenterY",O2N,"=",";"))<0.01 )
			Match1=1
		endif
		if(abs(NumberByKey("PixelSizeX",OGN,"=",";")-NumberByKey("PixelSizeX",O2N,"=",";"))<0.01 && abs(NumberByKey("PixelSizeY",OGN,"=",";")-NumberByKey("PixelSizeY",O2N,"=",";"))<0.01 )
			Match2=1
		endif
		if(abs(NumberByKey("HorizontalTilt",OGN,"=",";")-NumberByKey("HorizontalTilt",O2N,"=",";"))<0.01 && abs(NumberByKey("VerticalTilt",OGN,"=",";")-NumberByKey("VerticalTilt",O2N,"=",";"))<0.01 )
			Match3=1
		endif
		if(abs(NumberByKey("SampleToCCDDistance",OGN,"=",";")-NumberByKey("SampleToCCDDistance",O2N,"=",";"))<0.01 && abs(NumberByKey("Wavelength",OGN,"=",";")-NumberByKey("Wavelength",O2N,"=",";"))<0.01 )
			Match4=1
		endif
		if(DimSize(GeometryCorrection, 0 )==DimSize(DataWave, 0 ) && DimSize(GeometryCorrection,1 )==DimSize(DataWave, 1 ))
			Match5=1
		endif
		if(Match1 && match2 && Match3 && Match4 && Match5)
			return 1
		endif
	endif
	//OK, we need to recalculate the GeometryCorrention, here is the procedure...
	variable Ltemp = Wavelength / (4 * pi)
	//NI1A_Create2DQWave(DataWave)			//creates 2-D Q wave - this must exist by now... 
	wave Q2DWave = root:Packages:Convert2Dto1D:Q2DWave
	MatrixOp/O  GeometryCorrection =  2 * asin(Q2DWave * Ltemp))
	MatrixOp/O  GeometryCorrection = powR(cos(GeometryCorrection),3)
	Wave GeometryCorrection
	Redimension/S GeometryCorrection
	
	Note/K GeometryCorrection, O2N
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_CheckGeometryWaves(orientation)		//checks if current geometry waves are OK for the input geometry
	string orientation
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//wave/Z SolAngCor2Dwave=root:Packages:Convert2Dto1D:SolAngCor2Dwave				//2022-01 - this is not needed, 2D Solid angle correction is combination of SOlidAngle Correction AND geometry correction. 
	wave/Z Rdistribution1D=$("root:Packages:Convert2Dto1D:Rdistribution1D_"+orientation)
	wave/Z AnglesWave=root:Packages:Convert2Dto1D:AnglesWave
	wave/Z LUT=$("root:Packages:Convert2Dto1D:LUT_"+orientation)
	wave/Z Qdistribution1D=$("root:Packages:Convert2Dto1D:Qdistribution1D_"+orientation)
	wave/Z HistogramWv=$("root:Packages:Convert2Dto1D:HistogramWv_"+orientation)
	wave/Z Qvector=$("root:Packages:Convert2Dto1D:Qvector_"+orientation)
	
	//Check that the waves exist at all...
	if (!WaveExists(Qvector) || !WaveExists(HistogramWv) || !WaveExists(LUT))
		NI1A_Create2DQWave(DataWave)					//creates 2-D Q wave and SolAngCor2Dwave does not need to be run always...
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
//	NVAR ThetaSameNumPoints=root:Packages:Convert2Dto1D:ThetaSameNumPoints
	
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
	variable constVal=Wavelength / (4 * pi)
	
	if (QbinningLogarithmic)
		//logarithmic binning of Q
		duplicate/Free  Qdistribution1D, logQdistribution1D
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
		QvectorWidth[0,numpnts(Qvector)-2] = Qvector[p+1] - Qvector[p]
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
//		if(ThetaSameNumPoints)	//linear stepping in Theta
//			MinQtemp = MinQ + 0.2*(MaxQ-MinQ)/QvectorNumberPoints
//			Qdistribution1D = (Qdistribution1D[p]>MinQ) ? Qdistribution1D[p] : MinQtemp
//			duplicate/O  Qdistribution1D, ThetaDistribution1D
//			ThetaDistribution1D = 2 * asin ( Qdistribution1D * constVal) * 180 /pi
//			wavestats/Q ThetaDistribution1D
//			ThetaDistribution1D = V_min + p*(V_max-V_min)		//this is linear stepping in 2Theta
//			Qdistribution1D = sin(ThetaDistribution1D*pi/360) / constVal
//			Histogram /B={MinQ, ((MaxQ-MinQ)/QvectorNumberPoints), QvectorNumberPoints } Qdistribution1D, HistogramWv 
//			Qvector = MinQ + 0.5*(MaxQ-MinQ)/QvectorNumberPoints+ p*(MaxQ-MinQ)/QvectorNumberPoints		
//		else		//linear stepping in Q
			MinQtemp = MinQ + 0.2*(MaxQ-MinQ)/QvectorNumberPoints
			Qdistribution1D = (Qdistribution1D[p]>MinQ) ? Qdistribution1D[p] : MinQtemp
			Histogram /B={MinQ, ((MaxQ-MinQ)/QvectorNumberPoints), QvectorNumberPoints } Qdistribution1D, HistogramWv 
			Qvector = MinQ + 0.5*(MaxQ-MinQ)/QvectorNumberPoints+ p*(MaxQ-MinQ)/QvectorNumberPoints
//		endif
		//calculate width given by center to center distnce between Q points. 
		//this is equivalent to FWHM
		QvectorWidth[0,numpnts(Qvector)-2] = Qvector[p+1] - Qvector[p]
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
	TwoTheta =  2 * asin ( Qvector * constVal) * 180 /pi
	TwoThetaWidth[0,numpnts(TwoThetaWidth)-2]  = TwoTheta[p+1] - TwoTheta [p]
	TwoThetaWidth[numpnts(TwoThetaWidth)-1]=TwoThetaWidth[numpnts(TwoThetaWidth)-2]
	constVal = 2*pi
	Dspacing = constVal / Qvector
	DSpacingWidth[0,numpnts(DSpacingWidth)-2]  = Dspacing [p] - Dspacing[p+1]
	DSpacingWidth[numpnts(DSpacingWidth)-1]=DSpacingWidth[numpnts(DSpacingWidth)-2]
	
	DistanceInmm =  SampleToCCDDistance*tan(TwoTheta*pi/180)
	DistacneInmmWidth[0,numpnts(DistacneInmmWidth)-2]  = DistanceInmm[p+1] - DistanceInmm[p]
	DistacneInmmWidth[numpnts(DistacneInmmWidth)-1]=DistacneInmmWidth[numpnts(DistacneInmmWidth)-2]

	//create proper Q smearing data accounting for all other parts of gemoetry - beam size and pixels size
	//now this needs to be convoluted with other effects. 
	NVAR BeamSizeX = root:Packages:Convert2Dto1D:BeamSizeX
	NVAR BeamSizeY = root:Packages:Convert2Dto1D:BeamSizeY
	NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY
	NVAR Wavelength= root:Packages:Convert2Dto1D:Wavelength
	NVAR SampleToCCDdistance = root:Packages:Convert2Dto1D:SampleToCCDdistance
	NI1A_CalculateQresolution(Qvector,QvectorWidth,TwoThetaWidth, DistacneInmmWidth, DspacingWidth, PixelSizeX,PixelSizeY,BeamSizeX,BeamSizeY,Wavelength,SampleToCCDdistance)
	//that above creates the resolution due to pixel size, beam size and convolute them to existing binning q resolution. 
	
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
//Function NI1A_CreateQvector(orientation)
//	string orientation
//
////	print "Creating Q vector"
////	
////	string OldDf=GetDataFolder(1)
////	setDataFolder root:Packages:Convert2Dto1D
////	wave Rdistribution1D=$("root:Packages:Convert2Dto1D:Rdistribution1D_"+orientation)
////	wave LUT=$("root:Packages:Convert2Dto1D:LUT_"+orientation)
////	NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance		//in millimeters
////	NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength							//in A
////	//wavelength=12.398424437/EnergyInKeV
////	
////	//Create wave for q distribution
////	Duplicate/O Rdistribution1D, $("Qdistribution1D_"+orientation)
////	wave Qdistribution1D=$("Qdistribution1D_"+orientation)
////	Redimension/S Qdistribution1D
////	//Qdistribution1D = ((4*pi)/Wavelength)*sin(0.5*Rdistribution1D/SampleToCCDDistance)
////	Qdistribution1D = ((4*pi)/Wavelength)*sin(0.5*atan(Rdistribution1D/SampleToCCDDistance))
////	string NoteStr=note(Rdistribution1D)
////	NoteStr+="SampleToCCDDistance="+num2str(SampleToCCDDistance)+";"
////	NoteStr+="Wavelength="+num2str(Wavelength)+";"	
////	note Qdistribution1D, NoteStr
////
////	setDataFolder OldDf
//end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_CreateLUT(orientation)
	string orientation
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	if(UseMask)
		wave M_ROIMask=root:Packages:Convert2Dto1D:M_ROIMask
		MatrixOp/Free  MaskedQ2DWave = Q2DWave * M_ROIMask
	else
		MatrixOp/Free  MaskedQ2DWave = Q2DWave
	endif
	//this is likely not worhth the time now. 
	//redimension/S MaskedQ2DWave
	if(cmpstr(orientation,"C")!=0)
		MatrixOp/FREE   tempAnglesMask = AnglesWave
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
		
		MatrixOp/O  MaskedQ2DWave = MaskedQ2DWave * tempAnglesMask
		//killwaves tempAnglesMask
	endif
	//radius data are masked now 
	//wavestats/Q MaskedQ2DWave
	//this should be faster
	variable Npnts = DimSize(MaskedQ2DWave, 0)*DimSize(MaskedQ2DWave, 1)
	make/O/N=(Npnts)  $("Qdistribution1D_"+orientation), $("LUT_"+orientation)
	wave LUT=$("LUT_"+orientation)
	wave Qdistribution1D=$("Qdistribution1D_"+orientation)
	///redimension/S Qdistribution1D	//probably not needed anymore. Waste of time. 
	Qdistribution1D = MaskedQ2DWave
	LUT=p
	MakeIndex Qdistribution1D, LUT
	string NoteStr=note(Q2DWave)
	NoteStr+="UseMask="+num2str(UseMask)+";"
	NoteStr+="CurrentMaskFileName="+CurrentMaskFileName+";"
	note Qdistribution1D, NoteStr
	note LUT, NoteStr
	//KillWaves/Z MaskedQ2DWave
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
		MatrixOp/O  Q2DWave=DataWave
		MatrixOp/O  Theta2DWave=DataWave
		Redimension/S Q2DWave
		Redimension/S Theta2DWave
		variable ts=ticks
		if(abs(HorizontalTilt)>0.01 || abs(VerticalTilt)>0.01)		//use tilts, new method March 2011, JIL. Using extracted code by Jon Tischler. 
			NI2T_Calculate2DThetaWithTilts(Theta2DWave)		
			print "Both tilts used, time was = "+num2str((ticks-ts)/60)
		else			//no tilts... 
			//			variable timerRefNum, microSeconds
			//			timerRefNum = StartMSTimer
			//			Theta2DWave = sqrt(((p-BeamCenterX)*PixelSizeX)^2 + ((q-BeamCenterY)*PixelSizeY)^2)
			//			microSeconds = StopMSTimer(timerRefNum)
			//			print microSeconds/10000, "Direct calculation"
			//			timerRefNum = StartMSTimer
			Multithread Theta2DWave = sqrt(((p-BeamCenterX)*PixelSizeX)^2 + ((q-BeamCenterY)*PixelSizeY)^2)
			//			microSeconds = StopMSTimer(timerRefNum)
			//			print microSeconds/10000, "Multithread"
			//the QsDWave now contains the distance from beam center  Results should be in mm.... 
			//added to calculate the theta values...
			// Multithread Theta2DWave = atan(Theta2DWave/SampleToCCDDistance)/2
			//this shoudl be faster... 
			 MatrixOp/O  Theta2DWave = atan(Theta2DWave/SampleToCCDDistance)/2
			print "No tilts used, time was = "+num2str((ticks-ts)/60)
		endif
		if( (beamCenterX>=0 && beamCenterX<dimsize(Theta2DWave,0))&&(beamCenterY>=0 && beamCenterY<dimsize(Theta2DWave,1)))
			Theta2DWave[beamCenterX][beamCenterY] = NaN
		endif
		//theta values exist by now... Now convert to real Q. Theta2D may be neededc later... 
		//variable timerRefNum, microSeconds
		//timerRefNum = StartMSTimer
		//	Q2DWave = ((4*pi)/Wavelength)*sin(Theta2DWave)
		//microSeconds = StopMSTimer(timerRefNum)
		//print microSeconds/10000, "Direct calculation"
		//timerRefNum = StartMSTimer	
		//	Multithread Q2DWave = ((4*pi)/Wavelength)*sin(Theta2DWave)
		//microSeconds = StopMSTimer(timerRefNum)
		//print microSeconds/10000, "Multithread"
		//timerRefNum = StartMSTimer	
		// 2-1-2021 this seems 5x faster than Multithread and 10x faster than direct calculation. 
		MatrixOp/O  Q2DWave = ((4*pi)/Wavelength)*sin(Theta2DWave)
		//microSeconds = StopMSTimer(timerRefNum)
		//print microSeconds/10000, "MatrixOP"
		//record for which geometry this Radius vector wave was created
		//MatrixOp/O SolAngCor2Dwave = PixelSizeX*PixelSizeY/powR(SampleToCCDDistance*cos(Theta2DWave),2)
	else
		Theta2DWave[beamCenterX][beamCenterY] = NaN
		Q2Dwave[beamCenterX][beamCenterY] = NaN
		XrayEnergy=12.398424437/wavelength
		if(!WaveExists(Q2DWave))
			abort "Qwave does not exist and for Calibrated2D data it must"
		endif
		NoteStr = "Q calibration based on imported 2D data values. Geometry values are fake to make Nika work. Do not trust them.;"
	endif
	NoteStr = ReplaceStringByKey("BeamCenterX", NoteStr, num2str(BeamCenterX), "=", ";")
	NoteStr = ReplaceStringByKey("BeamCenterY", NoteStr, num2str(BeamCenterY), "=", ";")
	NoteStr = ReplaceStringByKey("PixelSizeX", NoteStr, num2str(PixelSizeX), "=", ";")
	NoteStr = ReplaceStringByKey("PixelSizeY", NoteStr, num2str(PixelSizeY), "=", ";")
	NoteStr = ReplaceStringByKey("HorizontalTilt", NoteStr, num2str(HorizontalTilt), "=", ";")
	NoteStr = ReplaceStringByKey("VerticalTilt", NoteStr, num2str(VerticalTilt), "=", ";")
	NoteStr = ReplaceStringByKey("SampleToCCDDistance", NoteStr, num2str(SampleToCCDDistance), "=", ";")
	NoteStr = ReplaceStringByKey("Wavelength", NoteStr, num2str(Wavelength), "=", ";")
	note/K Q2DWave, NoteStr
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_GISAXSOptions() : Panel
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1/W=(520,221,965,409) as "GISAXS Options"
	DoWindow/C GISAXSOptionsPanel
	SetDrawLayer UserBack
	SetDrawEnv linefgc= (1,16019,65535),fsize= 18,fstyle= 3,textrgb= (1,16019,65535)
	DrawText 10,31,"GISAXS options selection"
	DrawText 10,52,"For GISAXS_SOL (tilted sample) use 0 in this variable"
	DrawText 10,77,"For GISAXS_LSS (horizontal sample), typically Liquid Surface Scattering"
	DrawText 10,102,"Set this variable to Vertical center (in pixels) of reflected beam"
	DrawText 10,127,"For details, see manual !!!!"
	SetVariable GISAXS_YcenterReflBeam,pos={10,141},size={300,25},title="Vert. center of reflected beam [pixels]"
	SetVariable GISAXS_YcenterReflBeam,limits={-inf,inf,0},value= root:Packages:Convert2Dto1D:GISAXS_ycenterReflectedbeam
	SetVariable GISAXS_YcenterReflBeam proc=NI1_GISAXSOptsSetVarProc
EndMacro

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_GISAXSOptsSetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
			NI1A_LineProf_Update()
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

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1A_UpdateMainMaskListBox()		

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
			elseif(cmpstr(realExtension, ".tif")==0)//there are many options for hdf...
				ListOfAvailableDataSets=IndexedFile(Convert2Dto1DEmptyDarkPath,-1,".tif")
				ListOfAvailableDataSets+=IndexedFile(Convert2Dto1DEmptyDarkPath,-1,".tiff")
			else
				ListOfAvailableDataSets=IndexedFile(Convert2Dto1DEmptyDarkPath,-1,realExtension)
			endif	
			if(strlen(ListOfAvailableDataSets)<2)	//none found
				ListOfAvailableDataSets="--none--;"
			endif
			ListOfAvailableDataSets = IN2G_RemoveInvisibleFiles(ListOfAvailableDataSets)
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//variable StartTicks=ticks
	
	if(StringMatch(ctrlName,"CreateOutputPath"))
		PathInfo/S Convert2Dto1DOutputPath
		NewPath/C/O/M="Select path to save your data" Convert2Dto1DOutputPath	
	endif
	if(StringMatch(ctrlName,"GetHelp"))
		//Open www manual with the right page
		IN2G_OpenWebManual("Nika/Main.html")
	endif
	if(StringMatch(ctrlName,"SelectMaskDarkPath"))
		PathInfo/S Convert2Dto1DEmptyDarkPath
		NewPath/C/O/M="Select path to your Empty, Dark, and Mask data" Convert2Dto1DEmptyDarkPath	
		NI1A_UpdateEmptyDarkListBox()	
	endif
	if(StringMatch(ctrlName,"RefreshList"))
		ControlInfo/W=NI1A_Convert2Dto1DPanel Select2DInputWave
		variable oldSets=V_startRow
		NI1A_UpdateDataListBox()	
		ListBox Select2DInputWave,win=NI1A_Convert2Dto1DPanel,row=V_startRow
	endif
	if(StringMatch(ctrlName,"LoadDarkField"))
		NI1A_LoadEmptyOrDark("Dark")	
	endif
	if(StringMatch(ctrlName,"LoadEmpty"))
		NI1A_LoadEmptyOrDark("Empty")		
	endif
	if(StringMatch(ctrlName,"CreateMovie"))
		NI1A_CreateMovie()		
	endif
	if(StringMatch(ctrlName,"OnLineDataProcessing"))
		NI1A_OnLineDataProcessing()		
	endif
	//now new controls, keep old ones to keep other code functioning...
	NVAR Process_DisplayAve = root:Packages:Convert2Dto1D:Process_DisplayAve
	NVAR Process_Individually = root:Packages:Convert2Dto1D:Process_Individually
	NVAR Process_Average = root:Packages:Convert2Dto1D:Process_Average
	NVAR Process_AveNFiles = root:Packages:Convert2Dto1D:Process_AveNFiles
	NVAR Process_ReprocessExisting = root:Packages:Convert2Dto1D:Process_ReprocessExisting
	NVAR UseBatchProcessing=root:Packages:Convert2Dto1D:UseBatchProcessing
		
	if(StringMatch(ctrlName,"DisplaySelectedFile") ||(StringMatch(ctrlName, "ProcessSelectedImages") && Process_DisplayAve))
		//set selections for using RAW/Converted data...
		NVAR LineProfileUseRAW=root:Packages:Convert2Dto1D:LineProfileUseRAW
		NVAR LineProfileUseCorrData=root:Packages:Convert2Dto1D:LineProfileUseCorrData
		NVAR SectorsUseRAWData=root:Packages:Convert2Dto1D:SectorsUseRAWData
		NVAR SectorsUseCorrData=root:Packages:Convert2Dto1D:SectorsUseCorrData
		LineProfileUseRAW=1
		LineProfileUseCorrData=0
		SectorsUseRAWData=1
		SectorsUseCorrData=0
		UseBatchProcessing = 0
		//selection done
		NI1A_DisplayOneDataSet()	
		NI1_CalculateImageStatistics()
	endif
	if(StringMatch(ctrlName,"ExportDisplayedImage"))
		NI1A_ExportDisplayedImage()			
	endif
	if(StringMatch(ctrlName,"SaveDisplayedImage"))
		NI1A_SaveDisplayedImage()			
	endif

	if(StringMatch(ctrlName, "ProcessSelectedImages") & Process_ReprocessExisting)
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
		UseBatchProcessing = 0
		//selection done
		NI1A_ReprocessCurrentImage()			
	endif
	if(stringmatch(ctrlName,"ConvertSelectedFiles") ||(StringMatch(ctrlName, "ProcessSelectedImages") && Process_Individually))
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
		NI1A_BatchSetupWarningPanel()
		NI1A_LoadManyDataSetsForConv()		
		NI1A_BatchKillWarningPanel()	
	endif
	if(StringMatch(ctrlName,"AveConvertSelectedFiles") ||(StringMatch(ctrlName, "ProcessSelectedImages") && Process_Average))
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
		NI1A_BatchSetupWarningPanel()
		NI1A_AveLoadManyDataSetsForConv()		
		NI1A_BatchKillWarningPanel()
	endif
	if(StringMatch(ctrlName,"AveConvertNFiles") ||(StringMatch(ctrlName, "ProcessSelectedImages") && Process_AveNFiles))
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
		NI1A_BatchSetupWarningPanel()
		NI1A_AveLoadNDataSetsForConv()		
		NI1A_BatchKillWarningPanel()
	endif

	if(StringMatch(ctrlName,"Select2DDataPath"))
		//check if we are running on USAXS computers
		GetFileFOlderInfo/Q/Z "Z:USAXS_data:"
		if(V_isFolder)
			//OK, this computer has Z:USAXS_data 
			PathInfo Convert2Dto1DDataPath
			if(V_flag==0)
				NewPath/Q  Convert2Dto1DDataPath, "Z:USAXS_data:"
				pathinfo/S Convert2Dto1DDataPath
			endif
		endif
		//PathInfo/S Convert2Dto1DDataPath
		NewPath/C/O/M="Select path to your data" Convert2Dto1DDataPath
		PathInfo Convert2Dto1DDataPath
		SVAR MainPathInfoStr=root:Packages:Convert2Dto1D:MainPathInfoStr
		MainPathInfoStr=S_path
		TitleBox PathInfoStr, win =NI1A_Convert2Dto1DPanel, variable=MainPathInfoStr
		NI1A_UpdateDataListBox()		
	endif
	if(StringMatch(ctrlName,"MaskSelectPath"))
		//check if we are running on USAXS computers
		GetFileFOlderInfo/Q/Z "Z:USAXS_data:"
		if(V_isFolder)
			//OK, this computer has Z:USAXS_data 
			PathInfo Convert2Dto1DMaskPath
			if(V_flag==0)
				NewPath/Q  Convert2Dto1DMaskPath, "Z:USAXS_data:"
				pathinfo/S Convert2Dto1DMaskPath
			endif
		endif
		//PathInfo/S Convert2Dto1DMaskPath
		NewPath/C/O/M="Select path to your data" Convert2Dto1DMaskPath	
		NI1A_UpdateMainMaskListBox()	
		NI1M_UpdateMaskListBox()		
	endif
	if(StringMatch(ctrlName,"LoadMask"))
		NI1A_LoadMask()
	endif
	if(StringMatch(ctrlName,"DisplayMaskOnImage"))
		NI1M_DisplayMaskOnImage()
		PopupMenu MaskImageColor,win=NI1A_Convert2Dto1DPanel, mode=1
	endif
	if(StringMatch(ctrlName,"RemoveMaskFromImage"))
		NI1M_RemoveMaskFromImage()
	endif

	//LoadPixel2DSensitivity
	if(StringMatch(ctrlName,"LoadPixel2DSensitivity"))
		NI1A_LoadEmptyOrDark("Pixel2DSensitivity")		
	endif
	//this pops up the main panel back, some code should nto do that... 
	DoWIndow/F NI1A_Convert2Dto1DPanel
	//here is code which shiuld nto end with main panel at the top.  
	//Store current setting for future use
	if(StringMatch(ctrlName,"SaveCurrentToolSetting"))
		//call create mask routine here
		NI1A_StoreLoadCurSettingPnl()
	endif

	if(StringMatch(ctrlName,"CreateMask"))
		NI1M_CreateMask()
	endif
	//create squared sector graph...
	if(StringMatch(ctrlName,"CreateSectorGraph"))
		//call create mask routine here
		NI1_MakeSectorGraph(0)
	endif
	if(StringMatch(ctrlName,"CreateSectorGraphTilts"))
		//call create mask routine here
		NI1_MakeSectorGraph(1)
	endif


	
	//print "The processing took : "+num2str((ticks-StartTicks)/60)+" seconds to process" 
	
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_BatchSetupWarningPanel()

	NVAR UseBatchProcessing=root:Packages:Convert2Dto1D:UseBatchProcessing
	if(!UseBatchProcessing)
		return 0
	endif
	variable/g root:Packages:Convert2Dto1D:BatchProcessingStart
	NVAR BatchProcessingStart = root:Packages:Convert2Dto1D:BatchProcessingStart
	BatchProcessingStart = ticks
	print "*****************************************************************"
	print "Batch processing selected, no images will be displayed or updated"
	print "Igor will look like it is hanging. "
	print "Progress can be seen as changing Sample name (red text) on Main Nika panel"

	NewPanel /K=1/W=(395,325,750,444)/N=NikaBatchProcessRunning as "Nika is batch Processing data"
	ModifyPanel cbRGB=(65535,43690,0)
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,textrgb= (52428,1,1)
	DrawText 47,40,"Nika is batch processing data ..."
	DrawText 47,65,"At the end this window will disapper"
	DrawText 47,90,"and message in history will appear"
	DoUpdate /W=NikaBatchProcessRunning  
	
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_BatchKillWarningPanel()
	KillWIndow/Z NikaBatchProcessRunning
	NVAR UseBatchProcessing=root:Packages:Convert2Dto1D:UseBatchProcessing
	if(UseBatchProcessing)
		NVAR BatchProcessingStart = root:Packages:Convert2Dto1D:BatchProcessingStart
		print "Done with Batch processing. Nika is yours again..."
		print "Batch processing took : "+num2str((ticks-BatchProcessingStart)/60)+"  seconds"
		print "*****************************************************************"
	endif
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1M_DisplayMaskOnImage()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	DoWindow CCDImageToConvertFig
	if(V_Flag)
		DoWindow/F CCDImageToConvertFig
		Wave/Z M_ROIMask=root:Packages:Convert2Dto1D:M_ROIMask
		CheckDisplayed/W=CCDImageToConvertFig M_ROIMask
		if(WaveExists(M_ROIMask) && V_Flag)
			if(StringMatch(ColorToUse,"red"))//red
				ModifyImage/W=CCDImageToConvertFig M_ROIMask ctab ={0.2,0.5,Grays}, minRGB=(65280,0,0),maxRGB=NaN
			elseif(StringMatch(ColorToUse,"blue"))//blue
				ModifyImage/W=CCDImageToConvertFig M_ROIMask ctab ={0.2,0.5,Grays}, minRGB=(0,0,65280),maxRGB=NaN
			elseif(StringMatch(ColorToUse,"grey"))//grey
				ModifyImage/W=CCDImageToConvertFig M_ROIMask ctab ={0.2,0.5,Grays}, minRGB=(16000,16000,16000),maxRGB=NaN
			elseif(StringMatch(ColorToUse,"black"))
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D
	SVAR FileNameToLoad=root:Packages:Convert2Dto1D:FileNameToLoad
	FileNameToLoad = SelectedFileToLoad
	SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension
	NVAR UseCalib2DData=root:Packages:Convert2Dto1D:UseCalib2DData
	//need to communicate to Nexus reader what we are loading and this seems the only way to do so
	string/g ImageBeingLoaded
	ImageBeingLoaded = "sample"
	//awful workaround end
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
#if Exists("ModifyImportedImageHook")==6
	ModifyImportedImageHook(CCDImageToConvert)
#endif
	//end of allow user modification of imported image through hook function
	redimension/S CCDImageToConvert
	string NewNote=note(CCDImageToConvert)
	NewNote +="Processed on="+date()+","+time()+";"
	Note/K CCDImageToConvert 
	Note CCDImageToConvert, NewNote 
	MatrixOp/O    CCDImageToConvert_dis=CCDImageToConvert
	Note CCDImageToConvert_dis, NewNote
	setDataFolder OldDf
	//import jpg file (9IDC USAXS stuff)
	NI1A_ImportThisJPGFile(SelectedFileToLoad)
	return LoadedOK
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
// this function adds functionality to 9IDC SAXs/WAXS instrument and should never be called else. 
static Function NI1A_ImportThisJPGFile(SelectedFileToLoad)
		string SelectedFileToLoad
		//"Convert2Dto1DDataPath"
		NVAR/Z DisplayJPGFile = root:Packages:Convert2Dto1D:DisplayJPGFile
		KillWindow/Z SampleImageDuringMeasurementImg
		if(NVAR_Exists(DisplayJPGFile))
			if(DisplayJPGFile)
				string JPGFileName = StringFromList(0,SelectedFileToLoad,".")+".jpg"
					setDataFOlder root:Packages:Convert2Dto1D:
					ImageLoad/P=Convert2Dto1DDataPath/T=jpeg/Q/O/Z/N=SampleImageDuringMeasurement JPGFileName
					if(V_flag)	//success...
						Wave Img = root:Packages:Convert2Dto1D:SampleImageDuringMeasurement
						NewImage/K=1/N=SampleImageDuringMeasurementImg Img
						MoveWindow /W=SampleImageDuringMeasurementImg 40,45,910,664
						AutoPositionWindow/R=NI1A_Convert2Dto1DPanel/M=1 SampleImageDuringMeasurementImg
					endif
			endif
		endif	
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_DisplayTheRight2DWave()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D

			NVAR DisplayProcessed2DData=root:Packages:Convert2Dto1D:DisplayProcessed2DData
			NVAR DisplayRaw2DData=root:Packages:Convert2Dto1D:DisplayRaw2DData
			NVAR ImageDisplayLogScaled=root:Packages:Convert2Dto1D:ImageDisplayLogScaled
			NVAR UseBatchProcessing=root:Packages:Convert2Dto1D:UseBatchProcessing
			
			Wave/Z CCDImageToConvert_dis=root:Packages:Convert2Dto1D:CCDImageToConvert_dis
			Wave/Z CCDImageToConvert =root:Packages:Convert2Dto1D:CCDImageToConvert
			if(!WaveExists(CCDImageToConvert_dis)||!WaveExists(CCDImageToConvert) || UseBatchProcessing)		//no need to claculate display wave here... 
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
				MatrixOp/O  CCDImageToConvert_dis = log(waveToDisplay)
			else
				MatrixOp/O  CCDImageToConvert_dis = waveToDisplay
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	//Kill top graph with Imge if it exists..
	KillWIndow/Z CCDImageToConvertFig
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
	SVAR UserSampleName=root:Packages:Convert2Dto1D:UserSampleName
	Wave/Z tempWave=root:Packages:Convert2Dto1D:CCDImageToConvertTemp
	if(WaveExists(tempWave))
		KillWaves tempWave
	endif
	For(i=0;i<imax;i+=1)
		if (ListOf2DSampleDataNumbers[i])
			SelectedFileToLoad=ListOf2DSampleData[i]		//this is the file selected to be processed
			UserSampleName = RemoveEnding(RemoveListItem(ItemsInList(SelectedFileToLoad,".")-1, SelectedFileToLoad, "."))
			loadedOK = NI1A_ImportThisOneFile(SelectedFileToLoad)
			if(!loadedOK)
				return 0
			endif
			NI1A_ImportThisJPGFile(SelectedFileToLoad)
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
				MatrixOp/O   tempWave=CCDImageToConvert+tempWave
				numLoadedImages+=1
				OldNote+="DataFileName"+num2str(numLoadedImages)+"="+StringByKey("DataFileName", TempNote , "=", ";")+";"
			endif
		endif
	endfor
	OldNote+="NumberOfAveragedFiles="+num2str(numLoadedImages)+";"
	Wave tempWave=root:Packages:Convert2Dto1D:CCDImageToConvertTemp
	redimension/D tempWave
	MatrixOp/O    CCDImageToConvert=tempWave/numLoadedImages
	KillWaves/Z tempWave
	note/K CCDImageToConvert
	note CCDImageToConvert, OldNote
		NI1A_DisplayLoadedFile()
		DoWIndow CCDImageToConvertFig
		if(V_Flag)	//if Batch processing is checked, not woindow is opened.
			NI1A_DisplayStatsLoadedFile("CCDImageToConvert")
			NI1A_TopCCDImageUpdateColors(1)
			NI1A_DoDrawingsInto2DGraph()
			NI1A_CallImageHookFunction()
			DoWIndow Sample_Information
			if(V_FLag)
				AutopositionWindow/M=0/R=CCDImageToConvertFig Sample_Information
			endif
		endif
	setDataFolder OldDf	
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_DisplayStatsLoadedFile(WaveNameStr)
	string WaveNameStr
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=GetDataFOlder(1)
	setDataFOlder root:Packages:Convert2Dto1D


	KillWIndow/Z CCDImageToConvertFig
 	wave basewv=root:Packages:Convert2Dto1D:CCDImageToConvert
	wave/Z waveToDisplayDis = $("root:Packages:Convert2Dto1D:CCDImageToConvert_dis")
	NVAR UseBatchProcessing=root:Packages:Convert2Dto1D:UseBatchProcessing
	NVAR/Z LastDisplayedGBatchMessage=root:Packages:Convert2Dto1D:LastDisplayedGBatchMessage
	if(!NVAR_Exists(LastDisplayedGBatchMessage))
		variable/g root:Packages:Convert2Dto1D:LastDisplayedGBatchMessage
		NVAR LastDisplayedGBatchMessage=root:Packages:Convert2Dto1D:LastDisplayedGBatchMessage
		LastDisplayedGBatchMessage = 0
	endif
	if(UseBatchProcessing)
		if(abs(DateTime-LastDisplayedGBatchMessage)>10)
			//print "Batch processing selected, no images will be displayed or updated"
			print "Batch processing selected, I am working, hang on ... "
		endif
		LastDisplayedGBatchMessage = DateTime
		return 0
	endif
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
	//user requested scaling of the graph...
	NVAR ScaleImageBy=root:Packages:Convert2Dto1D:ScaleImageBy
	GetWindow CCDImageToConvertFig wsize
	string NewRecord="GraphLeft:"+num2str(V_left)+";GraphWidth:"+num2str(V_right-V_left)+";GraphTop:"+num2str(V_top)+";GraphHeight:"+num2str(V_bottom-V_top)+";"
	SetWindow CCDImageToConvertFig, note=NewRecord+";"	
	MoveWindow V_left, V_top, V_left+ScaleImageBy*(V_right-V_left), V_top+ScaleImageBy*(V_bottom-V_top)
	AutoPositionWindow/E/M=0/R=NI1A_Convert2Dto1DPanel CCDImageToConvertFig
	//append name of the file loaded in...
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
	TextBox/C/N=text0/S=1/B=2/A=LT "\\F"+IN2G_LkUpDfltStr("FontType")+"\\K(65280,16384,16384)\\Z"+IN2G_LkUpDfltVar("LegendSize")+LegendImg
	
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR DezingerHowManyTimes=root:Packages:Convert2Dto1D:DezingerHowManyTimes
	NVAR DezingerCCDData =root:Packages:Convert2Dto1D:DezingerCCDData
	NVAR DezingerEmpty =root:Packages:Convert2Dto1D:DezingerEmpty
	NVAR DezingerDarkField =root:Packages:Convert2Dto1D:DezingerDarkField
	
	wave w = $("root:Packages:Convert2Dto1D:"+whichFile)
	variable i
	if (StringMatch(whichFile,"CCDImageToConvert") && DezingerCCDData)
		For(i=0;i<DezingerHowManyTimes;i+=1)
			NI1A_DezingerImage(w)
		endfor
	endif
	if (StringMatch(whichFile,"EmptyData") && DezingerEmpty)
		For(i=0;i<DezingerHowManyTimes;i+=1)
			NI1A_DezingerImage(w)
		endfor
	endif
	if (StringMatch(whichFile,"DarkFieldData") && DezingerDarkField)
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

Function NI1A_ReprocessCurrentImage()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	//setup controls and display settings...
	//Kill window
	KillWIndow/Z CCDImageToConvertFig
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
	string DataWaveName="CCDImageToConvert"
	string DataWaveNameDis="CCDImageToConvert_dis"	//name of copy (lin or log int) for display
	NVAR SampleThickness=root:Packages:Convert2Dto1D:SampleThickness
	NVAR SampleTransmission=root:Packages:Convert2Dto1D:SampleTransmission
	NVAR CorrectionFactor=root:Packages:Convert2Dto1D:CorrectionFactor
	NVAR SampleMeasurementTime=root:Packages:Convert2Dto1D:SampleMeasurementTime
	NVAR SampleI0=root:Packages:Convert2Dto1D:SampleI0
	SVAR UserSampleName=root:Packages:Convert2Dto1D:UserSampleName
	SVAR/Z NX_Index1ProcessRule= root:Packages:Irena_Nexus:NX_Index1ProcessRule
	NVAR DelayBetweenImages=root:Packages:Convert2Dto1D:DelayBetweenImages
	if(!SVAR_Exists(NX_Index1ProcessRule))
		NEXUS_Initialize(0)
		SVAR NX_Index1ProcessRule= root:Packages:Irena_Nexus:NX_Index1ProcessRule
	endif
	string extension
	variable LoadedOK
	//SelectedFileToLoad=ListOf2DSampleData[i]		//this is the file selected to be processed
	//UserSampleName = RemoveEnding(RemoveListItem(ItemsInList(SelectedFileToLoad,".")-1, SelectedFileToLoad, "."))
	//NI1A_ImportThisOneFile(SelectedFileToLoad)	
	//NI1A_LoadParamsUsingFncts(SelectedFileToLoad)	
	Wave/Z CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(CCDImageToConvert))
		Abort "Data set does not exist" 
	endif
	string Oldnote=note(CCDImageToConvert)
	OldNote+=NI1A_CalibrationNote()
	note/K CCDImageToConvert
	note CCDImageToConvert, OldNote
	NI1A_DezingerDataSetIfAskedFor(DataWaveName)
	NI1A_Convert2DTo1D()
	NI1A_DisplayLoadedFile()
	NI1A_DisplayTheRight2DWave()
	NI1A_DoDrawingsInto2DGraph()
	NI1A_CallImageHookFunction()
	NI1_CalculateImageStatistics()
	NEXUS_NikaSave2DData()
	DoUpdate
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_LoadManyDataSetsForConv()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	//setup controls and display settings...
	//Kill window
	KillWIndow/Z CCDImageToConvertFig
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
	SVAR UserSampleName=root:Packages:Convert2Dto1D:UserSampleName
	SVAR/Z NX_Index1ProcessRule= root:Packages:Irena_Nexus:NX_Index1ProcessRule
	NVAR DelayBetweenImages=root:Packages:Convert2Dto1D:DelayBetweenImages
	NVAR UseBatchProcessing=root:Packages:Convert2Dto1D:UseBatchProcessing
	if(!SVAR_Exists(NX_Index1ProcessRule))
		NEXUS_Initialize(0)
		SVAR NX_Index1ProcessRule= root:Packages:Irena_Nexus:NX_Index1ProcessRule
	endif
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
					UserSampleName = RemoveEnding(RemoveListItem(ItemsInList(SelectedFileToLoad,".")-1, SelectedFileToLoad, "."))
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
					NI1_CalculateImageStatistics()
					NEXUS_NikaSave2DData()
					DoUpdate
				endfor
				currentframe=1
			//josh: Time Resolved Summation
			elseif(cmpstr(extension,"BSL/SAXS")==0 && sumframes==0 && average==0 && sumseq==1)	
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
						UserSampleName = RemoveEnding(RemoveListItem(ItemsInList(SelectedFileToLoad,".")-1, SelectedFileToLoad, "."))
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
						NI1_CalculateImageStatistics()
						NEXUS_NikaSave2DData()
						DoUpdate
					endfor
				duplicate/o BSLframelistsequence, $("root:SAS:BSLframelistsequence")
				currentframe=1
			elseif(stringMatch(extension,"Nexus"))
				//this is either regular or mutlidimensional Nexus file which user wantds to process all frames in with indexing over all frames. Index 1 (second in 4D)
				// image alllowed only... 
				NVAR NX_Index0Value = root:Packages:Irena_Nexus:NX_Index0Value
				NVAR NX_Index0Max = root:Packages:Irena_Nexus:NX_Index0Max
				NVAR NX_Index1Value = root:Packages:Irena_Nexus:NX_Index1Value
				NVAR NX_Index1Max = root:Packages:Irena_Nexus:NX_Index1Max
				//these are Nexus indexes for the up to 4D image
				//Let's iterate over the index, start with 0 value:
				variable nindx
				variable indxStart
				variable indxEnd
				if(stringMatch(NX_Index1ProcessRule,"All sequentially")||stringMatch(NX_Index1ProcessRule,"Sum together"))
					indxStart= 0
					indxEnd=NX_Index1Max
				else		//singlle image
					indxStart= NX_Index1Value
					indxEnd	=NX_Index1Value
				endif
				if(stringMatch(NX_Index1ProcessRule,"Sum together"))
					KillWaves/Z TempCCDImageToConvert
					SelectedFileToLoad=ListOf2DSampleData[i]		//this is the file selected to be processed
					UserSampleName = RemoveEnding(RemoveListItem(ItemsInList(SelectedFileToLoad,".")-1, SelectedFileToLoad, "."))
					//append the order numbers in the file... 
					if(NX_Index0Max>0)
						UserSampleName+="_"+num2str(NX_Index0Value)
					endif
					UserSampleName+="_sum"
					//
					print "This may take serious time, loading and avergaing images from the Nexus file "+SelectedFileToLoad
					For(nindx=indxStart;nindx<indxEnd+1;nindx+=1)
						NX_Index1Value = nindx
						NI1A_ImportThisOneFile(SelectedFileToLoad)	
						Wave CCDImageToConvert
						Wave/Z TempCCDImageToConvert
						if(!WaveExists(TempCCDImageToConvert))
							Duplicate CCDImageToConvert, TempCCDImageToConvert
						else
							TempCCDImageToConvert+=CCDImageToConvert
						endif
					endfor
					print "Done loading "+num2str(indxEnd+1)+" frames from the Nexus file"
					Duplicate/O TempCCDImageToConvert, CCDImageToConvert
					CCDImageToConvert/=(indxEnd+1)			//average... 
					KillWaves TempCCDImageToConvert
					NI1A_LoadParamsUsingFncts(SelectedFileToLoad)	
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
					NI1_CalculateImageStatistics()
					NEXUS_NikaSave2DData()
					DoUpdate
				else
					For(nindx=indxStart;nindx<indxEnd+1;nindx+=1)
						NX_Index1Value = nindx
						SelectedFileToLoad=ListOf2DSampleData[i]		//this is the file selected to be processed
						UserSampleName = RemoveEnding(RemoveListItem(ItemsInList(SelectedFileToLoad,".")-1, SelectedFileToLoad, "."))
						//append the order numbers in the file... 
						if(NX_Index0Max>0)
							UserSampleName+="_"+num2str(NX_Index0Value)
						endif
						if(NX_Index1Value>0)
							UserSampleName+="_"+num2str(NX_Index1Value)
						endif
						//
						NI1A_ImportThisOneFile(SelectedFileToLoad)	
						NI1A_LoadParamsUsingFncts(SelectedFileToLoad)	
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
						NI1_CalculateImageStatistics()
						NEXUS_NikaSave2DData()
						if(!UseBatchProcessing)
							ResumeUpdate
							DoUpdate
							sleep/S DelayBetweenImages
							//sleep/S/B/Q/C=6/M="Paused for "+num2str(DelayBetweenImages)+" seconds for user data review" DelayBetweenImages
						endif
					endfor
				endif
			else
				SelectedFileToLoad=ListOf2DSampleData[i]		//this is the file selected to be processed
				UserSampleName = RemoveEnding(RemoveListItem(ItemsInList(SelectedFileToLoad,".")-1, SelectedFileToLoad, "."))
				NI1A_ImportThisOneFile(SelectedFileToLoad)	
				NI1A_LoadParamsUsingFncts(SelectedFileToLoad)	
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
				NI1_CalculateImageStatistics()
				NEXUS_NikaSave2DData()
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DoWIndow CCDImageToConvertFig
	if(exists("AfterDisplayImageHook")==6 && V_Flag)
		Execute("AfterDisplayImageHook()")
	endif

end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_AveLoadNDataSetsForConv()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	//setup controls and display settings...
	//Kill window
	KillWIndow/Z CCDImageToConvertFig
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
		KillWIndow/Z CCDImageToConvertFig
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
	SVAR UserSampleName=root:Packages:Convert2Dto1D:UserSampleName
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
					UserSampleName = RemoveEnding(RemoveListItem(ItemsInList(SelectedFileToLoad,".")-1, SelectedFileToLoad, "."))
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
							MatrixOp/O  tempWave=CCDImageToConvert+tempWave
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
			
				MatrixOp/O  CCDImageToConvert=tempWave/numLoadedImages
				KillWaves/Z tempWave
				note/K CCDImageToConvert
				note CCDImageToConvert, OldNote
				NI1A_Convert2DTo1D()
				NI1A_DisplayLoadedFile()
				NI1A_DisplayTheRight2DWave()
				NI1A_DoDrawingsInto2DGraph()
				NI1A_CallImageHookFunction()
				NEXUS_NikaSave2DData()
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	//setup controls and display settings...
	//Kill window
	KillWIndow/Z CCDImageToConvertFig
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
		KillWIndow/Z CCDImageToConvertFig
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
	SVAR UserSampleName=root:Packages:Convert2Dto1D:UserSampleName
	//need to averaged 5 parameters above...
	For(i=0;i<imax;i+=1)
		if (ListOf2DSampleDataNumbers[i])
			SelectedFileToLoad=ListOf2DSampleData[i]		//this is the file selected to be processed
			UserSampleName = RemoveEnding(RemoveListItem(ItemsInList(SelectedFileToLoad,".")-1, SelectedFileToLoad, "."))
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
					MatrixOp/O  tempWave=CCDImageToConvert+tempWave
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

	MatrixOp/O  CCDImageToConvert=tempWave/numLoadedImages
	KillWaves/Z tempWave
	note/K CCDImageToConvert
	note CCDImageToConvert, OldNote
	NI1A_Convert2DTo1D()
	NI1A_DisplayLoadedFile()
	NI1A_DisplayTheRight2DWave()
	NI1A_DoDrawingsInto2DGraph()
	NI1A_CallImageHookFunction()
	NEXUS_NikaSave2DData()
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

		variable/g temp
		//add here options to get something done by instrument controls... 
		//this is used by support for ALS RXoXS support
		NVAR/Z UseRSoXSCodeModifications=root:Packages:Nika_RSoXS:UseRSoXSCodeModifications
		if(NVAR_Exists(UseRSoXSCodeModifications))
			if(UseRSoXSCodeModifications)
					NI1_RSoXSRestoreDarkOnImport()
			endif
		endif
		//this has restored proper Dark exposure time data for RSoXS ALS support. 
		
		
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string OldDf=GetDataFolder(1)
	setDataFOlder root:Packages:Convert2Dto1D
	WAVE/Z ww=root:Packages:Convert2Dto1D:CCDImageToConvert_dis
	NVAR DisplayProcessed2DData=root:Packages:Convert2Dto1D:DisplayProcessed2DData
	if(WaveExists(ww)==0)
		Abort "Something is wrong here"
	endif
	SVAR FileNameToLoad=root:Packages:Convert2Dto1D:FileNameToLoad
	//string  SaveFileName=FileNameToLoad[0,25]+"_mod.tif"
	string  SaveFileName=FileNameToLoad+"_mod.tif"
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	wave waveToDisplay = $("root:Packages:Convert2Dto1D:"+DataWaveName)
	Duplicate/O waveToDisplay, $("root:Packages:Convert2Dto1D:"+DataWaveName+"_dis")
	wave waveToDisplayDis= $("root:Packages:Convert2Dto1D:"+DataWaveName+"_dis")
	Redimension/S waveToDisplayDis
	NVAR ImageDisplayLogScaled=root:Packages:Convert2Dto1D:ImageDisplayLogScaled
		if(ImageDisplayLogScaled)
			MatrixOp/O  waveToDisplayDis = log(waveToDisplay)
		else
			MatrixOp/O  waveToDisplayDis = waveToDisplay
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	KillWIndow/Z EMptyOrDarkImage
 	SVAR CurrentEmptyName
	SVAR CurrentDarkFieldName
	SVAR CurrentPixSensFile
	string FileNameToLoad=ListOf2DEmptyData[selection]
	string NewWaveName
		if(numtype(strlen(FileNameToLoad))!=0)		//abort if user did not select anything in the box
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
	//need to communicate to Nexus reader what we are loading and this seems the only way to do so
	string/g ImageBeingLoaded
	ImageBeingLoaded = EmptyOrDark
	//awful workaround end
	
	NI1A_UniversalLoader("Convert2Dto1DEmptyDarkPath",FileNameToLoad,FileExtLocal,NewWaveName)

	wave NewCCDData = $(NewWaveName)
	//this is modification needed for RSoXS data processing
	NVAR/Z UseRSoXSCodeModifications = root:Packages:Nika_RSoXS:UseRSoXSCodeModifications
	if(NVAR_Exists(UseRSoXSCodeModifications)&&StringMatch(NewWaveName, "DarkFieldData"))
		NI1_RSoXSCopyDarkOnImport()		
	endif


	//allow user function modification to the image through hook function...
#if Exists("ModifyImportedImageHook")==6
	ModifyImportedImageHook(NewCCDData)
#endif

	duplicate/O NewCCDData, $(NewWaveName+"_dis")
	wave NewCCDDataDis=$(NewWaveName+"_dis")
	redimension/S NewCCDDataDis
	NVAR ImageDisplayLogScaled=root:Packages:Convert2Dto1D:ImageDisplayLogScaled
	if(ImageDisplayLogScaled)
		MatrixOp/O  NewCCDDataDis=log(NewCCDData)
	else
		MatrixOp/O  NewCCDDataDis=NewCCDData
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
//Function NI1A_DisplayOneDataSets()
//	//check the parameters for conversion
//	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//	string oldDf=GetDataFOlder(1)
//	setDataFolder root:Packages:Convert2Dto1D
//	
//	Wave ListOf2DSampleDataNumbers=root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers
//	Wave/T ListOf2DSampleData=root:Packages:Convert2Dto1D:ListOf2DSampleData
//	string SelectedFileToLoad
//	variable i, imax = numpnts(ListOf2DSampleDataNumbers)
//	For(i=0;i<imax;i+=1)
//		if (ListOf2DSampleDataNumbers[i])
//			SelectedFileToLoad=ListOf2DSampleData[i]		//this is the file selected to be processed
//			NI1A_ImportThisOneFile(SelectedFileToLoad)
//			abort
//		endif
//	endfor
//	setDataFolder OldDf
//end
////*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_LoadMask()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
		elseif(cmpstr(DataFileExtension, "12IDB_tif")==0)
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
				ListOfAvailableDataSets+=IndexedFile(Convert2Dto1DDataPath,-1,".nxs")		//rhis is Diamond decision, hdf5 for data files, nxs for metadata. May need to hide the hdf5? 
			elseif(cmpstr(realExtension, ".tif")==0)//there are many options for hdf...
				ListOfAvailableDataSets=IndexedFile(Convert2Dto1DDataPath,-1,".tif")
				ListOfAvailableDataSets+=IndexedFile(Convert2Dto1DDataPath,-1,".tiff")
			else
				ListOfAvailableDataSets=IndexedFile(Convert2Dto1DDataPath,-1,realExtension)
			endif	
			if(strlen(ListOfAvailableDataSets)<2)	//none found
				ListOfAvailableDataSets="--none--;"
			endif
			//ListOfAvailableDataSets = GrepList(ListOfAvailableDataSets, "^((?!_mask.hdf).)*$" ) //remove _mask files... 
			ListOfAvailableDataSets = GrepList(ListOfAvailableDataSets, "_mask.hdf",1 ) //remove _mask files... 
			//ListOfAvailableDataSets = GrepList(ListOfAvailableDataSets, "^((?!.pxp).)*$" ) //remove _mask files... 
			ListOfAvailableDataSets = GrepList(ListOfAvailableDataSets, ".pxp",1 ) //remove _mask files... 
			ListOfAvailableDataSets =  IN2G_RemoveInvisibleFiles(ListOfAvailableDataSets)
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
					tempSortWv = IN2G_FindNumIndxForSort(ListOf2DSampleData[p])
					//tempSortWv = NI1A_FindeOrderNumber(ListOf2DSampleData[p]) 
					sort tempSortWv, tempSortWv, ListOf2DSampleData, ListOf2DSampleDataNumbers
					KillWaves/Z tempSortWv
					ListOf2DSampleDataNumbers[numpnts(ListOf2DSampleDataNumbers)-1]=1
				elseif(FIlesSortOrder==4)
					//extract the order number and use that to sort out.. Inverted
					Make/O/N=(numpnts(ListOf2DSampleData)) tempSortWv
					//tempSortWv = NI1A_FindeOrderNumber(ListOf2DSampleData[p]) 
					tempSortWv = IN2G_FindNumIndxForSort(ListOf2DSampleData[p])
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
				//PopupMenu SelectStartOfRange,win=NI1A_Convert2Dto1DPanel,popvalue="---",value= #"NI1A_Create2DSelectionPopup()"
				//PopupMenu SelectEndOfRange,win=NI1A_Convert2Dto1DPanel,popvalue="---",value= #"NI1A_Create2DSelectionPopup()"
			endif
		endif
	setDataFolder OldDf
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//
//Function NI1A_FindeOrderNumber(stringWithName)	
//	string stringWithName
//	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//	//FoundON = stringWithName[strsearch(stringWithName, "_", inf ,1)+1, strsearch(stringWithName, ".", inf ,1)-1]
//	//change to search from teh back side for frst useful number. Some palces append text at the end. 
//	string FoundON, tempname
//	variable OrderNum, i, imax
//	tempname = stringWithName[0,strsearch(stringWithName, ".", inf ,1)-1]
//	imax = ItemsInList(tempname,"_")
//	For(i=imax-1;i>=0;i-=1)	
//		FoundON = StringFromList(i, tempname , "_")
//		OrderNum = str2num(FoundON)
//		if(numtype(OrderNum)==0)
//			return OrderNum
//		endif	
//	endfor
//	return 0
//end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function/T NI1A_CleanListOfFilesForTypes(ListOfAvailableCompounds,DataFileType, MatchString)
	string ListOfAvailableCompounds,DataFileType, MatchString
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	variable i, imax, numberOfFile
	if(strlen(ListOfAvailableCompounds)<2)
		return ""
	endif
	ListOfAvailableCompounds = GrepList(ListOfAvailableCompounds, ".pxp",1)
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	PauseUpdate    		// building window...
	NewPanel /K=1/N=NI1A_Convert2Dto1DPanel /W=(16,57,459,810) as "Main 2D to 1D conversion panel"
	SVAR DataFileExtension = root:Packages:Convert2Dto1D:DataFileExtension

	TitleBox MainTitle title="\Zr1602D to 1D data conversion panel",pos={48,2},frame=0,fstyle=3,size={300,24},fColor=(1,4,52428)
	TitleBox Info1 title="\Zr120Select input data here",pos={5,72},frame=0,fstyle=1, size={130,20},fColor=(1,4,52428)
	Button GetHelp,pos={335,5},size={80,15},fColor=(65535,32768,32768), proc=NI1A_ButtonProc,title="Get Help", help={"Open www manual page for this tool"}
//first data selection part
	Button Select2DDataPath,pos={5,30},size={140,20},proc=NI1A_ButtonProc,title="Select data path"
	Button Select2DDataPath,help={"Select Data path where 2D data are"}
	TitleBox PathInfoStr, pos={3,55}, size={350,20}, variable=root:Packages:Convert2Dto1D:MainPathInfoStr, frame=0, fstyle=2, fColor=(0,12800,32000)//,fSize=1.3
	PopupMenu Select2DDataType,pos={290,30},size={111,21},proc=NI1A_PopMenuProc,title="Image type"
	PopupMenu Select2DDataType,help={"Select type of 2D images being loaded"},value= #"root:Packages:Convert2Dto1D:ListOfKnownExtensions"
	PopupMenu Select2DDataType,popmatch=DataFileExtension
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

	CheckBox InvertImages,pos={150,73},size={146,14},proc=NI1A_CheckProc,title="Invert 0, 0 corner?"
	CheckBox InvertImages,help={"Check to have 0,0 in left BOTTOM corner, uncheck to have 0,0 in left TOP corner. Only for newly loaded images!"}
	CheckBox InvertImages,variable= root:Packages:Convert2Dto1D:InvertImages
	PopupMenu FIlesSortOrder,pos={275,73},size={111,13},proc=NI1A_PopMenuProc,title="Sort order: "
	PopupMenu FIlesSortOrder,help={"Select Sorting of data"}
	NVAR FIlesSortOrder = root:Packages:Convert2Dto1D:FIlesSortOrder
	PopupMenu FIlesSortOrder,mode=(FIlesSortOrder+1),value= "None;Sort;Sort2;_001;Invert_001;Invert Sort;Invert Sort2;"

	TitleBox RefreshList1 title="\Zr080Refresh using Right click",pos={320,99},frame=0,fstyle=1, fixedSize=1,size={120,11}
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
	PopupMenu DataCalibrationString,pos={280,218},size={211,18},proc=NI1A_PopMenuProc,title="Int. Calibration:"
	PopupMenu DataCalibrationString,help={"Select data calibration string"}
	SVAR DataCalibrationString = root:Packages:Convert2Dto1D:DataCalibrationString
	PopupMenu DataCalibrationString,mode=1+WhichListItem(DataCalibrationString, "Arbitrary;cm2/cm3;cm2/g;" ),value= "Arbitrary;cm2/cm3;cm2/g;"

	CheckBox CalculateStatistics,pos={350,238},size={146,14},noproc,title="Calc. Stats."
	CheckBox CalculateStatistics,help={"Check to have statistics on each image calculated on import"}
	CheckBox CalculateStatistics,variable= root:Packages:Convert2Dto1D:CalculateStatistics

	CheckBox UseBatchProcessing,pos={280,255},size={146,14},noproc,title="Batch Proc (no images)"
	CheckBox UseBatchProcessing,help={"Prevent Images to be updated, speeds up processing."}
	CheckBox UseBatchProcessing,variable= root:Packages:Convert2Dto1D:UseBatchProcessing


	ListBox Select2DInputWave,pos={16,92},size={300,120},row=0, clickEventModifiers=4, special={0,0,1 }		//this will scale the width of column, users may need to slide right using slider at the bottom. 
	ListBox Select2DInputWave,help={"Select data file to be converted, you can select multiple data sets"}
	ListBox Select2DInputWave,listWave=root:Packages:Convert2Dto1D:ListOf2DSampleData
	ListBox Select2DInputWave,selWave=root:Packages:Convert2Dto1D:ListOf2DSampleDataNumbers
	ListBox Select2DInputWave,mode= 9, proc=NI1_MainListBoxProc

	SetVariable SampleNameMatchStr,pos={10,217},size={245,18},proc=NI1A_PanelSetVarProc,title="Match (RegEx)"
	SetVariable SampleNameMatchStr,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:SampleNameMatchStr, help={"Gegula expression used to select some of the fle name above."}
	TitleBox Info2 title="\Zr100Sample name [controls are on Save tab] :",pos={10,240},frame=0,fstyle=2, fixedSize=1,size={350,20}, fColor=(1,12815,52428)
	SetVariable UserSampleName,pos={10,253},size={410,18},proc=NI1A_PanelSetVarProc,title=" ", noedit=1,frame=0
	SetVariable UserSampleName,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:UserSampleName, help={"Sample name build based on controls in \"Save\" tab"}
	SetVariable UserSampleName styledText=1,fstyle=1,valueColor=(65535,0,0)
	
//tab controls here
	TabControl Convert2Dto1DTab,pos={4,274},size={435,310},proc=NI1A_TabProc
	TabControl Convert2Dto1DTab,help={"Select tabs to control various parameters"}
	TabControl Convert2Dto1DTab,tabLabel(0)="Main",tabLabel(1)="Par"
	TabControl Convert2Dto1DTab,tabLabel(2)="Mask",tabLabel(3)="Em/Dk"
	TabControl Convert2Dto1DTab,tabLabel(4)="Sect",tabLabel(5)="PolTran"
	TabControl Convert2Dto1DTab,tabLabel(6)="LineProf", tabLabel(7)="Save/Exp", value= 0
	//TabControl Convert2Dto1DTab,tabLabel(7)="2D Exp."
//tab 1 geometry and method of calibration
	SetVariable SampleToDetectorDistance,pos={54,300},size={230,16},proc=NI1A_PanelSetVarProc,title="Sample to CCD distance [mm]"
	SetVariable SampleToDetectorDistance,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:SampleToCCDDistance
	SetVariable Wavelength,pos={20,322},size={162,16},proc=NI1A_PanelSetVarProc,title="Wavelength [A]  "
	SetVariable Wavelength,help={"\"Input wavelegth of X-rays in Angstroems\" "}, bodyWidth=80
	SetVariable Wavelength,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:Wavelength
	SetVariable XrayEnergy,pos={220,322},size={162,16},proc=NI1A_PanelSetVarProc,title="X-ray energy [keV]"
	SetVariable XrayEnergy,help={"Input energy of X-rays in keV (linked with wavelength)"}, bodyWidth=80
	SetVariable XrayEnergy,limits={0,Inf,0.1},value= root:Packages:Convert2Dto1D:XrayEnergy
	TitleBox GeometryDesc,pos={45,342},size={276,16},title="Direction     X (horizontal)                                Y (vertical)"
	TitleBox GeometryDesc,labelBack=(56576,56576,56576),fSize=12,frame=0
	TitleBox GeometryDesc,fColor=(0,0,65280)
	SetVariable PixleSizeX,pos={34,362},size={160,16},proc=NI1A_PanelSetVarProc,title="CCD pixel size [mm]"
	SetVariable PixleSizeX,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:PixelSizeX, bodyWidth=80
	SetVariable PixleSizeY,pos={250,362},size={160,16},proc=NI1A_PanelSetVarProc,title="CCD pixel size [mm]"
	SetVariable PixleSizeY,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:PixelSizeY, bodyWidth=80
	SetVariable BeamCenterX,pos={34,382},size={160,16},proc=NI1A_PanelSetVarProc,title="Beam center [pix]"
	SetVariable BeamCenterX,limits={-inf,Inf,1},value= root:Packages:Convert2Dto1D:BeamCenterX, bodyWidth=80
	SetVariable BeamCenterY,pos={250,382},size={160,16},proc=NI1A_PanelSetVarProc,title="Beam center [pix]"
	SetVariable BeamCenterY,limits={-inf,Inf,1},value= root:Packages:Convert2Dto1D:BeamCenterY, bodyWidth=80
	SetVariable HorizontalTilt,pos={34,402},size={160,16},proc=NI1A_PanelSetVarProc,title="Horizontal Tilt [deg]", bodyWidth=80
	SetVariable HorizontalTilt,limits={-90,90,0},value= root:Packages:Convert2Dto1D:HorizontalTilt,help={"Tilt of the image in horizontal plane (around 0 degrees)"}
	SetVariable VerticalTilt,pos={250,402},size={160,16},proc=NI1A_PanelSetVarProc,title="Vertical Tilt [deg]", bodyWidth=80
	SetVariable VerticalTilt,limits={-90,90,0},value= root:Packages:Convert2Dto1D:VerticalTilt,help={"Tilt of the image in vertical plane (around 90 degrees)"}
	SetVariable BeamSizeX,pos={34,422},size={160,16},proc=NI1A_PanelSetVarProc,title="Beam Size [mm]", bodyWidth=80
	SetVariable BeamSizeX,limits={0,25,0},value= root:Packages:Convert2Dto1D:BeamSizeX,help={"Beam size on detector in X direction in mm"}
	SetVariable BeamSizeY,pos={250,422},size={160,16},proc=NI1A_PanelSetVarProc,title="Beam Size [mm]", bodyWidth=80
	SetVariable BeamSizeY,limits={0,25,0},value= root:Packages:Convert2Dto1D:BeamSizeY,help={"Beam Size on detector in Y direction in mm"}
	CheckBox UseSampleThickness,pos={10,441},size={146,14},proc=NI1A_CheckProc,title="Use sample thickness (St)?"
	CheckBox UseSampleThickness,help={"Check if you will use sample thickness to scale data for calibration purposes"}
	CheckBox UseSampleThickness,variable= root:Packages:Convert2Dto1D:UseSampleThickness
	CheckBox UseSampleTransmission,pos={10,457},size={155,14},proc=NI1A_CheckProc,title="Use sample transmission (T)?"
	CheckBox UseSampleTransmission,help={"Check if you wil use sample transmission"}
	CheckBox UseSampleTransmission,variable= root:Packages:Convert2Dto1D:UseSampleTransmission
	CheckBox UseSampleCorrectionFactor,pos={10,473},size={173,14},proc=NI1A_CheckProc,title="Use sample Corection factor (C)?"
	CheckBox UseSampleCorrectionFactor,help={"Check if you will use correction factor to scale data to absolute scale"}
	CheckBox UseSampleCorrectionFactor,variable= root:Packages:Convert2Dto1D:UseCorrectionFactor
	CheckBox UseSolidAngle,pos={10,489},size={173,14},proc=NI1A_CheckProc,title="Use Solid Angle Corection (O)?"
	CheckBox UseSolidAngle,help={"Check if you will use correction factor to scale data to absolute scale"}
	CheckBox UseSolidAngle,variable= root:Packages:Convert2Dto1D:UseSolidAngle
	CheckBox UseI0ToCalibrate,pos={10,505},size={99,14},proc=NI1A_CheckProc,title="Use Monitor (I0)?"
	CheckBox UseI0ToCalibrate,help={"Check if you want to scale data by monitor counts"}
	CheckBox UseI0ToCalibrate,variable= root:Packages:Convert2Dto1D:UseI0ToCalibrate
	CheckBox UseDarkField,pos={10,521},size={128,14},proc=NI1A_CheckProc,title="Use Dark field (DF2D)?"
	CheckBox UseDarkField,help={"Check if you will use dark field"}
	CheckBox UseDarkField,variable= root:Packages:Convert2Dto1D:UseDarkField
	CheckBox UseEmptyField,pos={10,537},size={133,14},proc=NI1A_CheckProc,title="Use Empty field (EF2D)?"
	CheckBox UseEmptyField,help={"Check if you will use empty field"}
	CheckBox UseEmptyField,variable= root:Packages:Convert2Dto1D:UseEmptyField
	CheckBox UseSubtractFixedOffset,pos={209,462},size={183,14},proc=NI1A_CheckProc,title="Subtract constant from data (Ofst)?"
	CheckBox UseSubtractFixedOffset,help={"Check if you want to subtract constant from CCD data (replace dark field)"}
	CheckBox UseSubtractFixedOffset,variable= root:Packages:Convert2Dto1D:UseSubtractFixedOffset
	CheckBox UseSampleMeasTime,pos={209,501},size={184,14},proc=NI1A_CheckProc,title="Use sample measurement time (ts)?"
	CheckBox UseSampleMeasTime,help={"Check if you want to scale data by measurement time"}
	CheckBox UseSampleMeasTime,variable= root:Packages:Convert2Dto1D:UseSampleMeasTime
	CheckBox UseEmptyMeasTime,pos={209,519},size={180,14},proc=NI1A_CheckProc,title="Use empty measurement time (te)?"
	CheckBox UseEmptyMeasTime,help={"Check if you want to scale empty field data by measurement time"}
	CheckBox UseEmptyMeasTime,variable= root:Packages:Convert2Dto1D:UseEmptyMeasTime
	CheckBox UseDarkMeasTime,pos={209,537},size={195,14},proc=NI1A_CheckProc,title="Use dark field measurement time (td)?"
	CheckBox UseDarkMeasTime,help={"Check if you want to scale dark field data by measurement time"}
	CheckBox UseDarkMeasTime,variable= root:Packages:Convert2Dto1D:UseDarkMeasTime
	CheckBox UsePixelSensitivity,pos={209,443},size={159,14},proc=NI1A_CheckProc,title="Use pixel sensitivity (Pix2D)?"
	CheckBox UsePixelSensitivity,help={"Check if you want to use pixel sensitivity map"}
	CheckBox UsePixelSensitivity,variable= root:Packages:Convert2Dto1D:UsePixelSensitivity
	CheckBox UseMOnitorForEF,pos={209,481},size={146,14},proc=NI1A_CheckProc,title="Use I0/I0ef for empty field?"
	CheckBox UseMOnitorForEF,help={"Check if you want to scale empty by ratio of monitor values"}
	CheckBox UseMOnitorForEF,variable= root:Packages:Convert2Dto1D:UseMonitorForEF
	SetVariable CalibrationFormula,pos={12,560},size={390,16},title=" "
	SetVariable CalibrationFormula,help={"This is calibration method which will be applied to your data"}
	SetVariable CalibrationFormula,labelBack=(32768,40704,65280),fSize=10,frame=0
	SetVariable CalibrationFormula,limits={-Inf,Inf,0},value= root:Packages:Convert2Dto1D:CalibrationFormula
//tab 2 sample and calibration values

	CheckBox DoGeometryCorrection,pos={20,308},size={100,14},title="Geometry corr?",proc=NI1A_CheckProc
	CheckBox DoGeometryCorrection,help={"Correct for change in relative angular size and obliqueness of off-axis pixels. Correction to the output intensities to be equivalent to 2-theta scan. "}
	CheckBox DoGeometryCorrection,variable= root:Packages:Convert2Dto1D:DoGeometryCorrection

	CheckBox DoPolarizationCorrection,pos={170,308},size={100,14},title="Polarization corr?",proc=NI1A_CheckProc
	CheckBox DoPolarizationCorrection,help={"Correct intensities for Polarization correction."}
	CheckBox DoPolarizationCorrection,variable= root:Packages:Convert2Dto1D:DoPolarizationCorrection

	CheckBox CorrectSelfAbsorption,pos={290,308},size={100,14},title="Self-Absorption corr?",proc=NI1A_CheckProc
	CheckBox CorrectSelfAbsorption,help={"Correct intensities for self absorption. Needs correct thickness!"}
	CheckBox CorrectSelfAbsorption,variable= root:Packages:Convert2Dto1D:CorrectSelfAbsorption

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
	SetVariable SampleTransmission,limits={0,Inf,0.01},value= root:Packages:Convert2Dto1D:SampleTransmission


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
	ListBox MaskListBoxSelection,pos={83,375},size={260,100}, row=0, clickEventModifiers=4, special={0,0,1 }		//this will scale the width of column, users may need to slide right using slider at the bottom. 
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
	SVAR DataFileExtension = root:Packages:Convert2Dto1D:DataFileExtension
	PopupMenu SelectBlank2DDataType,value= #"root:Packages:Convert2Dto1D:ListOfKnownExtensions"
	PopupMenu SelectBlank2DDataType,pos={270,310},size={111,21},proc=NI1A_PopMenuProc,title="Image type"
	PopupMenu SelectBlank2DDataType,help={"Select type of 2D images being loaded"}
	PopupMenu SelectBlank2DDataType,popmatch=DataFileExtension
	ListBox Select2DMaskDarkWave,pos={23,335},size={351,120},disable=1, row=0, special={0,0,1 }		//this will scale the width of column, users may need to slide right using slider at the bottom. 
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
	CheckBox FixBackgroundOversubtraction,pos={255,535},size={95,14},title="Fix Backg. Oversubtraction"
	CheckBox FixBackgroundOversubtraction,help={"Check to add flat background to prevent negative intensities"}, proc=NI1A_CheckProc
	CheckBox FixBackgroundOversubtraction,variable= root:Packages:Convert2Dto1D:FixBackgroundOversubtraction


//tab 5 output conditions
	
	CheckBox UseSectors,pos={15,310},size={90,14},title="Use?", mode=0, proc=NI1A_CheckProc
	CheckBox UseSectors,help={"Use any of the settings in this tab?"}
	CheckBox UseSectors,variable= root:Packages:Convert2Dto1D:UseSectors
	CheckBox UseQvector,pos={100,308},size={90,14},title="Q space?", mode=1, proc=NI1A_CheckProc
	CheckBox UseQvector,help={"Select to have output as function of q [inverse nm]"}
	CheckBox UseQvector,variable= root:Packages:Convert2Dto1D:UseQvector
	CheckBox UseDspacing,pos={180,308},size={90,14},title="d ?", mode=1, proc=NI1A_CheckProc
	CheckBox UseDspacing,help={"Select to have output as function of d spacing"}
	CheckBox UseDspacing,variable= root:Packages:Convert2Dto1D:UseDspacing
	CheckBox UseTheta,pos={232,308},size={90,14},title="2 Theta ?", mode=1, proc=NI1A_CheckProc
	CheckBox UseTheta,help={"Select to have output as function of 2 theta"}
	CheckBox UseTheta,variable= root:Packages:Convert2Dto1D:UseTheta
	CheckBox UseDistanceFromCenter,pos={320,308},size={90,14},title="Distance [mm]?", mode=1, proc=NI1A_CheckProc
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
	SetVariable QbinPoints,pos={220,370},size={200,16},title="Number of points   "
	NVAR QvectorMaxNumPnts = root:Packages:Convert2Dto1D:QvectorMaxNumPnts
	SetVariable QbinPoints,help={"Number of points in Q you want to create"}, disable = (QvectorMaxNumPnts)
	SetVariable QbinPoints,limits={0,Inf,10},value= root:Packages:Convert2Dto1D:QvectorNumberPoints
	CheckBox QvectorMaxNumPnts,pos={152,350},size={130,14},title="Max num points?",proc=NI1A_CheckProc
	CheckBox QvectorMaxNumPnts,help={"Use Max possible number of points? Num pnts = num pixels"}
	CheckBox QvectorMaxNumPnts,variable= root:Packages:Convert2Dto1D:QvectorMaxNumPnts
	NVAR UseTheta = root:Packages:Convert2Dto1D:UseTheta
//	CheckBox ThetaSameNumPoints,pos={282,350},size={130,14},title="Equi-spaced 2Theta?",proc=NI1A_CheckProc
//	CheckBox ThetaSameNumPoints,help={"Generate equidistantly spaced 2Theta points as for diffractometers?"}
//	CheckBox ThetaSameNumPoints,variable= root:Packages:Convert2Dto1D:ThetaSameNumPoints, disable=!UseTheta

	CheckBox DoCircularAverage,pos={20,370},size={130,14},title="Do circular average?",proc=NI1A_CheckProc
	CheckBox DoCircularAverage,help={"Create data with circular average?"}
	CheckBox DoCircularAverage,variable= root:Packages:Convert2Dto1D:DoCircularAverage
	CheckBox DoSectorAverages,pos={20,390},size={130,14},title="Make sector averages?",proc=NI1A_CheckProc
	CheckBox DoSectorAverages,help={"Create data with sector average?"}, proc=NI1A_checkProc
	CheckBox DoSectorAverages,variable= root:Packages:Convert2Dto1D:DoSectorAverages
	SetVariable NumberOfSectors,pos={20,410},size={190,16},title="Number of sectors",proc=NI1A_PanelSetVarProc
	SetVariable NumberOfSectors,help={"Number of sectors you want to create"}
	SetVariable NumberOfSectors,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:NumberOfSectors
	
	SetVariable SectorsStartAngle,pos={220,410},size={200,16},title="Start angle of sectors",proc=NI1A_PanelSetVarProc
	SetVariable SectorsStartAngle,help={"Angle around which first sectors is centered"}
	SetVariable SectorsStartAngle,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:SectorsStartAngle
	SetVariable SectorsHalfWidth,pos={20,430},size={190,16},title="Width of sector +/- ",proc=NI1A_PanelSetVarProc
	SetVariable SectorsHalfWidth,help={"Half width of sectors in degrees"}
	SetVariable SectorsHalfWidth,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:SectorsHalfWidth
	SetVariable SectorsStepInAngle,pos={220,430},size={200,16},title="Angle between sectors",proc=NI1A_PanelSetVarProc
	SetVariable SectorsStepInAngle,help={"Angle between center directions of sectors"}
	SetVariable SectorsStepInAngle,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:SectorsStepInAngle

	//tab 6 - sectors for namual processing...
	Button CreateSectorGraph,pos={20,530},size={160,20},title="Create sector graph"
	Button CreateSectorGraph,help={"Create graph in of angle vs pixel for manual processing"},proc=NI1A_ButtonProc
	Button CreateSectorGraphTilts,pos={20,555},size={160,20},title="Create sector graph w/tilts"
	Button CreateSectorGraphTilts,help={"Create graph in of angle vs pixel for manual processing and account for tilts"},proc=NI1A_ButtonProc
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
	SetVariable LineProf_LineAzAngle,help={"Azimuthal angle for line going through center in degrees?"}, limits={-179.99, 179.999,1}
	SetVariable LineProf_LineAzAngle,variable= root:Packages:Convert2Dto1D:LineProf_LineAzAngle, proc=NI1A_SetVarProcMainPanel
	
	//other controls	
	SetVariable LineProf_DistanceFromCenter,pos={20,405},size={220,16},title="Distance from center [in pixles] "
	SetVariable LineProf_DistanceFromCenter,help={"Distacne from center in pixels?"}, limits={-inf, inf,1}
	SetVariable LineProf_DistanceFromCenter,variable= root:Packages:Convert2Dto1D:LineProf_DistanceFromCenter, proc=NI1A_SetVarProcMainPanel
	SetVariable LineProf_DistanceQ,pos={280,405},size={100,16},title="Q =  ",format="%.4f"
	SetVariable LineProf_DistanceQ,help={"Distance from center in q units"}, limits={-inf, inf,0}
	SetVariable LineProf_DistanceQ,variable= root:Packages:Convert2Dto1D:LineProf_DistanceQ, proc=NI1A_SetVarProcMainPanel
	SetVariable LineProf_Width,pos={20,425},size={220,17},proc=NI1A_SetVarProcMainPanel,title="Width [in pixels]                      "
	SetVariable LineProf_Width,help={"WIdth of the line in pixels?"}
	SetVariable LineProf_Width,variable= root:Packages:Convert2Dto1D:LineProf_Width
	SetVariable LineProf_WidthQ,pos={280,425},size={100,17},title="Q =  "
	SetVariable LineProf_WidthQ,help={"Width in q units"},format="%.4f"
	SetVariable LineProf_WidthQ,limits={-inf,inf,0},variable= root:Packages:Convert2Dto1D:LineProf_WidthQ 
//	//Tab 7 - Save data
	TitleBox Tab7_1 title="\Zr120Store data controls:",pos={20,310},frame=0,fstyle=2, fixedSize=1,size={350,20}, fColor=(1,12815,52428)
	CheckBox DisplayDataAfterProcessing,pos={20,335},size={159,14},title="Create 1D graph?"
	CheckBox DisplayDataAfterProcessing,help={"Create graph of 1D data after processing"},proc=NI1A_CheckProc
	CheckBox DisplayDataAfterProcessing,variable= root:Packages:Convert2Dto1D:DisplayDataAfterProcessing
	CheckBox StoreDataInIgor,pos={230,325},size={159,14},title="Store data in Igor experiment?"
	CheckBox StoreDataInIgor,help={"Save data in current Igor experiment"},proc=NI1A_CheckProc
	CheckBox StoreDataInIgor,variable= root:Packages:Convert2Dto1D:StoreDataInIgor
	CheckBox OverwriteDataIfExists,pos={230,350},size={159,14},title="Overwrite existing data if exist?"
	CheckBox OverwriteDataIfExists,help={"Overwrite data in current Igor experiment if they already exist"}
	CheckBox OverwriteDataIfExists,variable= root:Packages:Convert2Dto1D:OverwriteDataIfExists
	//Data hame handling
	TitleBox Tab7_2 title="\Zr120Name data controls:",pos={20,370},frame=0,fstyle=2, fixedSize=1,size={350,20}, fColor=(1,12815,52428)
	CheckBox Use2DdataName,pos={20,390},size={170,14},title="Use input data name for output?",proc=NI1A_CheckProc
	CheckBox Use2DdataName,help={"Check to have output data named after input data name"}
	CheckBox Use2DdataName,variable= root:Packages:Convert2Dto1D:Use2DdataName
	CheckBox UseSampleNameFnct,pos={230,390},size={170,14},title="Use function for output name?",proc=NI1A_CheckProc
	CheckBox UseSampleNameFnct,help={"Check to use String function to provide output data name"}
	CheckBox UseSampleNameFnct,variable= root:Packages:Convert2Dto1D:UseSampleNameFnct
	NVAR Use2DdataName = root:Packages:Convert2Dto1D:Use2DdataName
	SetVariable OutputFileName,pos={20,410},size={360,16},title="ASCII data name"
	SetVariable OutputFileName,help={"Input string for 1D data"}
	SetVariable OutputFileName,value= root:Packages:Convert2Dto1D:OutputDataName, disable=Use2DdataName
	NVAR UseSampleNameFnct = root:Packages:Convert2Dto1D:UseSampleNameFnct
	SetVariable SampleNameFnct,pos={20,410},size={360,16},title="Function name"
	SetVariable SampleNameFnct,help={"String Name function "}
	SetVariable SampleNameFnct,value= root:Packages:Convert2Dto1D:SampleNameFnct, disable=UseSampleNameFnct
	CheckBox TrimFrontOfName,pos={20,410},size={100,18},proc=NI1A_CheckProc,title="Trim Front"
	CheckBox TrimFrontOfName,help={"Check to trim FRONT of name to 20 characters"}, variable=root:Packages:Convert2Dto1D:TrimFrontOfName
	CheckBox TrimEndOfName,pos={230,410},size={100,18},proc=NI1A_CheckProc,title="Trim End"
	CheckBox TrimEndOfName,help={"Check to trim END of name to 20 characters"}, variable=root:Packages:Convert2Dto1D:TrimEndOfName
	SetVariable RemoveStringFromName,pos={20,430},size={280,18},noproc,title="Remove from name:"
	SetVariable RemoveStringFromName,limits={0,Inf,1},value= root:Packages:Convert2Dto1D:RemoveStringFromName

	TitleBox Tab7_3 title="\Zr120Export data controls:",pos={20,470},frame=0,fstyle=2, fixedSize=1,size={350,20}, fColor=(1,12815,52428)

	CheckBox AppendToNexusFile,pos={20,490},size={170,14},title="Export to Nexus?"
	CheckBox AppendToNexusFile,help={"Append to Nexus file- more controls on separate screen."}
	CheckBox AppendToNexusFile,variable= root:Packages:Convert2Dto1D:AppendToNexusFile,proc=NI1A_CheckProc

	
	Button CreateOutputPath,pos={250,490},size={160,20},title="Select output path"
	Button CreateOutputPath,help={"Select path to export data into"},proc=NI1A_ButtonProc

	CheckBox ExportDataOutOfIgor,pos={20,510},size={122,14},title="Export data as ASCII?"
	CheckBox ExportDataOutOfIgor,help={"Check to export data out of Igor, select data path"}
	CheckBox ExportDataOutOfIgor,variable= root:Packages:Convert2Dto1D:ExportDataOutOfIgor
	NVAR UseTheta = root:Packages:Convert2Dto1D:UseTheta
	CheckBox SaveGSASdata,pos={50,530},size={122,14},title="GSAS xye?", disable=!(UseTheta)
	CheckBox SaveGSASdata,help={"Export data as GSAS xye data. Must use Two Theta"}
	CheckBox SaveGSASdata,variable= root:Packages:Convert2Dto1D:SaveGSASdata

	//last few items under the tabs area
	Button ProcessSelectedImages,pos={160,585},size={150,20},proc=NI1A_ButtonProc,title="Process image(s)"
	Button ProcessSelectedImages,help={"Process images as selected in the checkboxes"}, fColor=(65535,49151,49151)

	SetVariable DelayBetweenImages,pos={320,587},size={110,18},proc=NI1A_PanelSetVarProc,title="Pause b/Imgs"
	SetVariable DelayBetweenImages,limits={0,500,1},value= root:Packages:Convert2Dto1D:DelayBetweenImages, help={"Delay to see data when multiple images are being processed"}
	NVAR ScaleImageBy = root:Packages:Convert2Dto1D:ScaleImageBy
	SetVariable ScaleImageBy,pos={320,608},size={110,16},title="Scale Img x", proc=NI1A_SetVarProcMainPanel
	SetVariable ScaleImageBy,help={"Scale Image size by this factor - make it larger or smaller"}, limits={0.05,inf,0.2*ScaleImageBy}
	SetVariable ScaleImageBy,variable= root:Packages:Convert2Dto1D:ScaleImageBy

	//control variable for what happens...
	CheckBox Process_DisplayAve,pos={5,585},size={80,16},title="Display only",variable= root:Packages:Convert2Dto1D:Process_DisplayAve, proc=NI1A_CheckProc
	CheckBox Process_DisplayAve,help={"Average all selected files and display them in image, no processing"}, mode=1
	CheckBox Process_Individually,pos={5,600},size={80,16},title="Process sel. files individualy",variable= root:Packages:Convert2Dto1D:Process_Individually, proc=NI1A_CheckProc
	CheckBox Process_Individually,help={"Load each file individually and process them (separately)"}, mode=1
	CheckBox Process_ReprocessExisting,pos={5,615},size={80,16},title="Re-Process current",variable= root:Packages:Convert2Dto1D:Process_ReprocessExisting, proc=NI1A_CheckProc
	CheckBox Process_ReprocessExisting,help={"Reprocess the current image"}, mode=1
	CheckBox Process_Average,pos={5,630},size={80,16},title="Average all selected and process",variable= root:Packages:Convert2Dto1D:Process_Average, proc=NI1A_CheckProc
	CheckBox Process_Average,help={"Average all selected files together and process them into one output data"}, mode=1
	CheckBox Process_AveNFiles,pos={5,645},size={80,16},title="Average N of selected and process",variable= root:Packages:Convert2Dto1D:Process_AveNFiles, proc=NI1A_CheckProc
	CheckBox Process_AveNFiles,help={"Average N selected files and process them into output"}, mode=1

	SetVariable ProcessNImagesAtTime,pos={5,665},size={80,16},title="N = "
	SetVariable ProcessNImagesAtTime,help={"How many images at time should be averaged?"}, limits={1,inf,1}
	SetVariable ProcessNImagesAtTime,variable= root:Packages:Convert2Dto1D:ProcessNImagesAtTime, proc=NI1A_SetVarProcMainPanel
	//
	CheckBox SkipBadFiles,pos={5,680},size={100,16},title="Skip bad files?"
	CheckBox SkipBadFiles,help={"Skip images with low maximum intensity?"}
	CheckBox SkipBadFiles,variable= root:Packages:Convert2Dto1D:SkipBadFiles
	CheckBox SkipBadFiles proc=NI1A_CheckProc
	SetVariable MaxIntForBadFile,pos={120,680},size={100,16},title="Min. Int = "
	SetVariable MaxIntForBadFile,help={"Bad file has less than this intensity?"}, limits={0,inf,0}
//	NVAR SkipBadFiles = root:Packages:Convert2Dto1D:SkipBadFiles
	SetVariable MaxIntForBadFile,variable= root:Packages:Convert2Dto1D:MaxIntForBadFile//, disable=!(SkipBadFiles)

	CheckBox DisplayRaw2DData,pos={195,607},size={120,16},title="Display RAW ?"
	CheckBox DisplayRaw2DData,help={"In the 2D image, display raw data?"}, mode=1
	CheckBox DisplayRaw2DData,variable= root:Packages:Convert2Dto1D:DisplayRaw2DData
	CheckBox DisplayRaw2DData proc=NI1A_CheckProc
	CheckBox DisplayProcessed2DData,pos={195,625},size={120,16},title="Display Processed?"
	CheckBox DisplayProcessed2DData,help={"In the 2D image, display processed, calibrated data?"}, mode=1
	CheckBox DisplayProcessed2DData,variable= root:Packages:Convert2Dto1D:DisplayProcessed2DData
	CheckBox DisplayProcessed2DData proc=NI1A_CheckProc

	SVAR ColorTableName = root:Packages:Convert2Dto1D:ColorTableName
	SVAR ColorTableList = root:Packages:Convert2Dto1D:ColorTableList
	PopupMenu ColorTablePopup,pos={195,657},size={100,21},proc=NI1A_PopMenuProc,title="Colors"
	PopupMenu ColorTablePopup,mode=1,popvalue=ColorTableName,value= #"root:Packages:Convert2Dto1D:ColorTableList"

	CheckBox ImageDisplayBeamCenter,variable= root:Packages:Convert2Dto1D:DisplayBeamCenterIn2DGraph, help={"Display beam center on teh image?"}
	CheckBox ImageDisplayBeamCenter proc=NI1A_CheckProc, pos={310,630},size={120,16},title="Display beam center?"
	CheckBox ImageDisplaySectors,variable= root:Packages:Convert2Dto1D:DisplaySectorsIn2DGraph, help={"Display sectors(if selected) in the image?"}
	CheckBox ImageDisplaySectors proc=NI1A_CheckProc, pos={310,645},size={120,16},title="Display sects/Lines?"
	CheckBox ImageDisplayLogScaled,pos={310,660},size={120,16},title="Log Int display?"
	CheckBox ImageDisplayLogScaled,help={"Display image with log(intensity)?"}
	CheckBox ImageDisplayLogScaled,variable= root:Packages:Convert2Dto1D:ImageDisplayLogScaled
	CheckBox ImageDisplayLogScaled proc=NI1A_CheckProc


	CheckBox DisplayQCirclesOnImage,pos={250,690},size={120,15},title="Img w/Q circles?"
	CheckBox DisplayQCirclesOnImage,help={"Display image with Q circles on axis?"}
	CheckBox DisplayQCirclesOnImage,variable= root:Packages:Convert2Dto1D:DisplayQCirclesOnImage
	CheckBox DisplayQCirclesOnImage proc=NI1A_CheckProc

	CheckBox DisplayQValsOnImage,pos={250,705},size={120,15},title="Image with Q axes?"
	CheckBox DisplayQValsOnImage,help={"Display image with Q values on axis?"}
	CheckBox DisplayQValsOnImage,variable= root:Packages:Convert2Dto1D:DisplayQValsOnImage
	CheckBox DisplayQValsOnImage proc=NI1A_CheckProc

	CheckBox DisplayQvalsWIthGridsOnImg,pos={250,720},size={120,15},title="Img w/Q axes with grids?"
	CheckBox DisplayQvalsWIthGridsOnImg,help={"Display image with Q values on axis and grids?"}
	CheckBox DisplayQvalsWIthGridsOnImg,variable= root:Packages:Convert2Dto1D:DisplayQvalsWIthGridsOnImg
	CheckBox DisplayQvalsWIthGridsOnImg proc=NI1A_CheckProc

	CheckBox DisplayColorScale,pos={250,735},size={120,15},title="Display Color scale?"
	CheckBox DisplayColorScale,help={"Display image with color scale?"}
	CheckBox DisplayColorScale,variable= root:Packages:Convert2Dto1D:DisplayColorScale
	CheckBox DisplayColorScale proc=NI1A_CheckProc

	CheckBox UseUserDefMinMax,pos={45,695},size={120,15},title="User def. Min/Max?"
	CheckBox UseUserDefMinMax,help={"Display image with color scale?"}
	CheckBox UseUserDefMinMax,variable= root:Packages:Convert2Dto1D:UseUserDefMinMax
	CheckBox UseUserDefMinMax proc=NI1A_CheckProc

	//bottom controls
	NVAR ImageRangeMinLimit = root:Packages:Convert2Dto1D:ImageRangeMinLimit
	NVAR ImageRangeMaxLimit = root:Packages:Convert2Dto1D:ImageRangeMaxLimit
	Slider ImageRangeMin,pos={5,708},size={180,16},proc=NI1A_MainSliderProc,variable= root:Packages:Convert2Dto1D:ImageRangeMin,live= 0,side= 2,vert= 0,ticks= 0
	Slider ImageRangeMin,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}
	Slider ImageRangeMax,pos={5,723},size={180,16},proc=NI1A_MainSliderProc,variable= root:Packages:Convert2Dto1D:ImageRangeMax,live= 0,side= 2,vert= 0,ticks= 0
	Slider ImageRangeMax,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}

	//NVAR UseUserDefMinMax = root:Packages:Convert2Dto1D:UseUserDefMinMax
	SetVariable UserImageRangeMin,pos={80,712},size={120,16},title="Min. =  ", proc=NI1A_SetVarProcMainPanel
	SetVariable UserImageRangeMin,help={"Select minimum intensity to display?"}, limits={0,inf,0}
	SetVariable UserImageRangeMin,variable= root:Packages:Convert2Dto1D:UserImageRangeMin//, disable=!(UseUserDefMinMax)

	SetVariable UserImageRangeMax,pos={80,732},size={120,16},title="Max. = ", proc=NI1A_SetVarProcMainPanel
	SetVariable UserImageRangeMax,help={"Select minimum intensity to display?"}, limits={0,inf,0}
	SetVariable UserImageRangeMax,variable= root:Packages:Convert2Dto1D:UserImageRangeMax//, disable=!(UseUserDefMinMax)
	
	NI1A_FixMovieBtnAndOtherCntrls()
	//print Exists("Nika_Hook_ModifyMainPanel")
	if(Exists("Nika_Hook_ModifyMainPanel")==6)
		Execute("Nika_Hook_ModifyMainPanel()")
	endif
	ING2_AddScrollControl()
EndMacro


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_FixMovieBtnAndOtherCntrls()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR Movie_FileOpened=root:Packages:Convert2Dto1D:Movie_FileOpened
	NVAR Movie_AppendAutomatically=root:Packages:Convert2Dto1D:Movie_AppendAutomatically
	if(Movie_FileOpened && Movie_AppendAutomatically)
		Button CreateMovie win=NI1A_Convert2Dto1DPanel, title="Creating Movie Auto",fColor=(16386,65535,16385)
	elseif(Movie_FileOpened && !Movie_AppendAutomatically)
		Button CreateMovie win=NI1A_Convert2Dto1DPanel, title="Creating Movie Manual",fColor=(16386,65535,16385)
	endif
	//N averagin g controls can be now hidden
	NVAR Process_AveNFiles = root:Packages:Convert2Dto1D:Process_AveNFiles
	NVAR SkipBadFiles = root:Packages:Convert2Dto1D:SkipBadFiles

	SetVariable ProcessNImagesAtTime win=NI1A_Convert2Dto1DPanel,disable=!Process_AveNFiles
	CheckBox SkipBadFiles win=NI1A_Convert2Dto1DPanel,disable=!Process_AveNFiles
	SetVariable MaxIntForBadFile win=NI1A_Convert2Dto1DPanel,disable=!(Process_AveNFiles && SkipBadFiles)
	
	NVAR UseUserDefMinMax = root:Packages:Convert2Dto1D:UseUserDefMinMax
	SetVariable UserImageRangeMin win=NI1A_Convert2Dto1DPanel, disable=!(UseUserDefMinMax)
	SetVariable UserImageRangeMax win=NI1A_Convert2Dto1DPanel, disable=!(UseUserDefMinMax)
	Slider ImageRangeMin win=NI1A_Convert2Dto1DPanel, disable=(UseUserDefMinMax)
	Slider ImageRangeMax win=NI1A_Convert2Dto1DPanel, disable=(UseUserDefMinMax)

end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_SetVarProcMainPanel(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String ctrlName=sva.ctrlName
	Variable varNum=sva.dval
	String varStr=sva.sval

	if(!(sva.eventCode==1 || sva.EventCode==2))
		return 0
	endif
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

	NVAR SectorsNumSect= root:Packages:Convert2Dto1D:SectorsNumSect
	NVAR SectorsGraphEndAngle= root:Packages:Convert2Dto1D:SectorsGraphEndAngle
	NVAR SectorsSectWidth= root:Packages:Convert2Dto1D:SectorsSectWidth
	NVAR SectorsGraphStartAngle= root:Packages:Convert2Dto1D:SectorsGraphStartAngle
	Wave/Z CCDImage=root:Packages:Convert2Dto1D:CCDImageToConvert
	if(!WaveExists(CCDImage))
		return 0
	endif
	variable temp
	variable highBracket = sqrt(DimSize(CCDImage, 0 )^2+DimSize(CCDImage, 1)^2)
	variable lowBracket = -sqrt(DimSize(CCDImage, 0 )^2+DimSize(CCDImage, 1)^2)
	NVAR LineProf_DistanceQ=root:Packages:Convert2Dto1D:LineProf_DistanceQ
	NVAR LineProf_DistanceFromCenter=root:Packages:Convert2Dto1D:LineProf_DistanceFromCenter
	
	if(stringMatch("LineProf_DistanceQ",ctrlName))
			make/Free/N=1 pWave
			pWave = LineProf_DistanceQ
			Optimize /H=(highBracket) /L=(lowBracket)/Q /I=50/T=0.1 NI1A_CalcQValForSearch, pWave 
			LineProf_DistanceFromCenter = round(V_minloc)
	endif

	
	if(stringMatch("LineProf_DistanceQ",ctrlName)||stringMatch("LineProf_DistanceFromCenter",ctrlName)||stringMatch("LineProf_Width",ctrlName)||stringMatch("LineProf_LineAzAngle",ctrlName)||stringMatch("LineProf_GIIncAngle",ctrlName)||stringMatch("LineProf_EllipseAR",ctrlName))
		//fix negative allowed Az angle behavior...
		if(stringMatch("LineProf_LineAzAngle",ctrlName))
			variable oldvalue=str2num(sva.userdata)
			NVAR LineProf_DistanceFromCenter = root:Packages:Convert2Dto1D:LineProf_DistanceFromCenter
			if ((sign(oldvalue) * sign(sva.dval))<0)
				 // print "sign changed"
				 LineProf_DistanceFromCenter*=-1
			endif
			sva.userdata=num2str(sva.dval)
		endif

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
	if(cmpstr("ScaleImageBy",ctrlName)==0)
		//user requested scaling of the graph...
		string OldRecord 	//="GraphLeft:"+num2str(V_left)+";GraphWidth:"+num2str(V_right-V_left)+";GraphTop:"+num2str(V_top)+";GraphHeight:"+num2str(V_bottom-V_top)+";"
		DoWIndow CCDImageToConvertFig
		if(V_Flag)
			GetWindow CCDImageToConvertFig, note
			OldRecord = S_value
			//MoveWindow V_left, V_top, V_left+ScaleImageBy*(V_right-V_left), V_top+ScaleImageBy*(V_bottom-V_top)
			variable oldWidth, oldHeight
			oldWidth=NumberByKey("GraphWidth", OldRecord)
			oldHeight=NumberByKey("GraphHeight", OldRecord)
			NVAR ScaleImageBy=root:Packages:Convert2Dto1D:ScaleImageBy
			DoWIndow /F CCDImageToConvertFig
			GetWindow CCDImageToConvertFig wsize
			MoveWindow/W=CCDImageToConvertFig  V_left, V_top, V_left+ScaleImageBy*oldWidth, V_top+ScaleImageBy*oldHeight
			AutoPositionWindow/E/M=0/R=NI1A_Convert2Dto1DPanel CCDImageToConvertFig
			SetVariable ScaleImageBy win=NI1A_Convert2Dto1DPanel, limits={0.05,inf,0.2*ScaleImageBy}

		endif
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	SetVariable BeamSizeX,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
	SetVariable BeamSizeY,disable=(tabNum!=0||UseCalib2DData), win=NI1A_Convert2Dto1DPanel
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
	CheckBox CorrectSelfAbsorption, disable=(tabNum!=1 || !UseSampleThickness || !UseSampleTransmission ), win=NI1A_Convert2Dto1DPanel
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
	CheckBox FixBackgroundOversubtraction,disable=(tabNum!=3), win=NI1A_Convert2Dto1DPanel
	//tab 4 controls
	NVAR UseQvector=root:Packages:Convert2Dto1D:UseQvector
	NVAR UseDspacing=root:Packages:Convert2Dto1D:UseDspacing
	NVAR UseTheta=root:Packages:Convert2Dto1D:UseTheta
	NVAR QvectorMaxNumPnts=root:Packages:Convert2Dto1D:QvectorMaxNumPnts
	NVAR UseSectors=root:Packages:Convert2Dto1D:UseSectors
	NVAR UseLineProfile=root:Packages:Convert2Dto1D:UseLineProfile
	NVAR UseSampleNameFnct=root:Packages:Convert2Dto1D:UseSampleNameFnct
	NVAR Use2DdataName=root:Packages:Convert2Dto1D:Use2DdataName
	

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
//	CheckBox ThetaSameNumPoints,disable=(tabNum!=4 || !UseTheta||!UseSectors), win=NI1A_Convert2Dto1DPanel

	CheckBox QbinningLogarithmic,disable=(tabNum!=4||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable QbinPoints,disable=(tabNum!=4 || QvectorMaxNumPnts||!UseSectors), win=NI1A_Convert2Dto1DPanel
	CheckBox QvectorMaxNumPnts,disable=(tabNum!=4||!UseSectors), win=NI1A_Convert2Dto1DPanel
	CheckBox DoCircularAverage,disable=(tabNum!=4||!UseSectors), win=NI1A_Convert2Dto1DPanel
	//end of common block for line profiel and secotrs
	CheckBox DoSectorAverages,disable=(tabNum!=4||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable NumberOfSectors,disable=(tabNum!=4 || !DoSectorAverages||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable SectorsStartAngle,disable=(tabNum!=4 || !DoSectorAverages||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable SectorsHalfWidth,disable=(tabNum!=4 || !DoSectorAverages||!UseSectors), win=NI1A_Convert2Dto1DPanel
	SetVariable SectorsStepInAngle,disable=(tabNum!=4 || !DoSectorAverages||!UseSectors), win=NI1A_Convert2Dto1DPanel
	//tab 5 controls
	Button CreateSectorGraph,disable=(tabNum!=5), win=NI1A_Convert2Dto1DPanel
	Button CreateSectorGraphTilts,disable=(tabNum!=5), win=NI1A_Convert2Dto1DPanel
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
	if((tabNum!=6))
		DoWIndow/Z/K GISAXSOptionsPanel
	endif
////tab 7 controls
	//the nextset will be used also in Line profile, so make it appear also when that is selected on its tab...
	CheckBox StoreDataInIgor,disable=!(tabNum==7), win=NI1A_Convert2Dto1DPanel
	CheckBox OverwriteDataIfExists,disable=!(tabNum==7), win=NI1A_Convert2Dto1DPanel
	CheckBox ExportDataOutOfIgor,disable=!(tabNum==7), win=NI1A_Convert2Dto1DPanel 
	CheckBox SaveGSASdata,disable=!(tabNum==7&&UseTheta), win=NI1A_Convert2Dto1DPanel

	CheckBox AppendToNexusFile,disable=!((tabNum==7)||(tabNum==7&&ExpCalib2DData)), win=NI1A_Convert2Dto1DPanel
	Button CreateOutputPath,disable=(!((tabNum==7)||(tabNum==7&&ExpCalib2DData&&!AppendToNexusFile))), win=NI1A_Convert2Dto1DPanel

	CheckBox DisplayDataAfterProcessing,disable= !(tabNum==7), win=NI1A_Convert2Dto1DPanel	
	TitleBox Tab7_1,disable= !(tabNum==7), win=NI1A_Convert2Dto1DPanel	
	TitleBox Tab7_2,disable= !(tabNum==7), win=NI1A_Convert2Dto1DPanel	
	TitleBox Tab7_3,disable= !(tabNum==7), win=NI1A_Convert2Dto1DPanel	

	CheckBox UseSampleNameFnct,disable= !((tabNum==7)||(tabNum==7&&ExpCalib2DData&&!AppendToNexusFile)), win=NI1A_Convert2Dto1DPanel
	CheckBox Use2DdataName,disable= !((tabNum==7)||(tabNum==7&&ExpCalib2DData&&!AppendToNexusFile)), win=NI1A_Convert2Dto1DPanel
	variable disableFnct, disableStr
	disableFnct = !UseSampleNameFnct || !((tabNum==7)||(tabNum==7&&ExpCalib2DData&&!AppendToNexusFile))
	//disableStr = Use2DdataName || UseSampleNameFnct || !((tabNum==4&&UseSectors)||(tabNum==7))
	disableStr = Use2DdataName || UseSampleNameFnct || !(tabNum==7)
	SetVariable OutputFileName,disable=(disableStr), win=NI1A_Convert2Dto1DPanel
	SetVariable SampleNameFnct,disable=(disableFnct), win=NI1A_Convert2Dto1DPanel

	CheckBox TrimFrontOfName,disable=!(Use2DdataName &&(tabNum==7)), win=NI1A_Convert2Dto1DPanel
	CheckBox TrimEndOfName,disable=!(Use2DdataName &&( tabNum==7)), win=NI1A_Convert2Dto1DPanel
	SetVariable RemoveStringFromName,disable=!(Use2DdataName &&( tabNum==7)), win=NI1A_Convert2Dto1DPanel

//	CheckBox ExpCalib2DData,disable=(tabNum!=7), win=NI1A_Convert2Dto1DPanel
//	CheckBox InclMaskCalib2DData,disable=(tabNum!=7||!ExpCalib2DData), win=NI1A_Convert2Dto1DPanel
//	CheckBox UseQxyCalib2DData,disable=(tabNum!=7||!ExpCalib2DData), win=NI1A_Convert2Dto1DPanel
//	CheckBox RebinCalib2DData,disable=(tabNum!=7||!ExpCalib2DData), win=NI1A_Convert2Dto1DPanel
//	PopupMenu RebinCalib2DDataToPnts,disable=(tabNum!=7||!ExpCalib2DData||!RebinCalib2DData), win=NI1A_Convert2Dto1DPanel
//	PopupMenu Calib2DDataOutputFormat,disable=(tabNum!=7||!ExpCalib2DData || AppendToNexusFile), win=NI1A_Convert2Dto1DPanel

	
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

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
//
//Function NI1A_ListBoxProc(ctrlName,row,col,event)
//	String ctrlName
//	Variable row
//	Variable col
//	Variable event	//1=mouse down, 2=up, 3=dbl click, 4=cell select with mouse or keys
//					//5=cell select with shift key, 6=begin edit, 7=end
//	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//	if(cmpstr("MaskListBoxSelection",ctrlName)==0)
//	
//	endif
//	return 0
//End
////*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_PolarCorCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	PauseUpdate    		// building window...
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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

		//NVAR LineProf_LineAzAngle=root:Packages:Convert2Dto1D:LineProf_LineAzAngle
		NVAR LineProf_LineAzAngleG =root:Packages:Convert2Dto1D:LineProf_LineAzAngle
		variable LineProf_LineAzAngle
		LineProf_LineAzAngle = LineProf_LineAzAngleG>=0 ? LineProf_LineAzAngleG : LineProf_LineAzAngleG+180	
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
		//fix for allowed negative AZ angle values...
		if(stringMatch(LineProf_CurveType,"Angle Line"))
			NVAR LPAzAngle = root:Packages:Convert2Dto1D:LineProf_LineAzAngle
			NVAR LPDistanceFromCenter = root:Packages:Convert2Dto1D:LineProf_DistanceFromCenter
			if(sign(LPAzAngle) == sign(LPDistanceFromCenter))
				Qval = abs(Qval)
			else
				Qval = -1*abs(Qval)
			endif
		endif

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
Function NI1A_CalcQValForSearch(w, LineProf_DistanceFromCenter)
		Wave w
		variable LineProf_DistanceFromCenter
		//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

		variable QValueTarget = w[0]
		NVAR LineProf_DistanceQ=root:Packages:Convert2Dto1D:LineProf_DistanceQ
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
		variable distance
		if(stringMatch(LineProf_CurveType,"Horizontal Line") || stringMatch(LineProf_CurveType,"GI_Horizontal line"))
			distance=NI1T_TiltedToCorrectedR( LineProf_DistanceFromCenter*PixelSizeY ,SampleToCCDDistance,VerticalTilt)		//in mm 
		endif
		if(stringMatch(LineProf_CurveType,"Vertical Line")|| stringMatch(LineProf_CurveType,"Ellipse")|| stringMatch(LineProf_CurveType,"Angle Line"))
			distance=NI1T_TiltedToCorrectedR( LineProf_DistanceFromCenter*PixelSizeX ,SampleToCCDDistance,HorizontalTilt)		//in mm 
		endif
		variable theta=atan(distance/SampleToCCDDistance)/2
		variable Qval= ((4*pi)/Wavelength)*sin(theta)

		if( stringMatch(LineProf_CurveType,"GI_Vertical line"))
			Qval = NI1GI_CalculateQxyz(LineProf_DistanceFromCenter+BeamCenterX,BeamCenterY,"Y")
		endif
		if( stringMatch(LineProf_CurveType,"GI_Horizontal line"))
			Qval = NI1GI_CalculateQxyz(BeamCenterX,BeamCenterY-LineProf_DistanceFromCenter,"Z")
		endif
		
		return abs(QValueTarget-Qval)
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function/S NI1A_CreateHelpForNameFunction()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	DOwindow	NI1A_UseFnctToCreateName
	if(V_Flag)
		DoWIndow/F NI1A_UseFnctToCreateName
	else
		String nb = "NI1A_UseFnctToCreateName"
		NewNotebook/N=$nb/F=1/V=1/K=1/W=(655,103,1195,471)
		Notebook $nb defaultTab=36
		Notebook $nb showRuler=0, rulerUnits=2, updating={1, 1}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Helvetica",11,0,(0,0,0)}
		Notebook $nb newRuler=Header, justification=1, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Helvetica",13,1,(0,0,65535)}
		Notebook $nb ruler=Header, text="Use function to create data name\r"
		Notebook $nb ruler=Normal
		Notebook $nb text="You can create Igor function to return the name for the data. This needs to be string function which wi"
		Notebook $nb text="ll take as parameter current 2DDataWave (image) and the file name. It has to return valid Igor name, wh"
		Notebook $nb text="ich must be string shorter than about 17 characters (to enable Nika to add sector information to it). Th"
		Notebook $nb text="e name will be checked for validity and uniquness.\r"
		Notebook $nb text="\r"
		Notebook $nb text="here is example\r"
		Notebook $nb text="\r"
		Notebook $nb text="Function/S ReturnSampleName(My2DImage, OriginalDataFileName)\r"
		Notebook $nb text="\twave My2DImage\r"
		Notebook $nb text="\tstring OriginalDataFileName\r"
		Notebook $nb text="\t//do something to create a new name, here I will trunkate the name to 15 characters\r"
		Notebook $nb text="\tstring tempName=OriginalDataFileName[0,14]\r"
		Notebook $nb text="\t//or here look up \"SampleTitle\" in wave note\r"
		Notebook $nb text="\t//string Wvnote = note(My2DImage)\r"
		Notebook $nb text="\t//tempName = stringByKey(\"SampleTitle\", Wvnote)\r"
		Notebook $nb text="\r"
		Notebook $nb text="\treturn tempName\r"
		Notebook $nb text="end"
	endif
	AutoPositionWindow/M=0 /R=NI1A_Convert2Dto1DPanel NI1A_UseFnctToCreateName
end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_CheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	NVAR UseSampleNameFnct = root:Packages:Convert2Dto1D:UseSampleNameFnct
	NVAR Use2DdataName = root:Packages:Convert2Dto1D:Use2DdataName

	NVAR Process_DisplayAve = root:Packages:Convert2Dto1D:Process_DisplayAve
	NVAR Process_Individually = root:Packages:Convert2Dto1D:Process_Individually
	NVAR Process_Average = root:Packages:Convert2Dto1D:Process_Average
	NVAR Process_AveNFiles = root:Packages:Convert2Dto1D:Process_AveNFiles
	NVAR Process_ReprocessExisting = root:Packages:Convert2Dto1D:Process_ReprocessExisting
	
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


	if(StringMatch("UseSampleNameFnct",ctrlName))
		if(checked)
			Use2DdataName=0
			NI1A_CreateHelpForNameFunction()
		else
			KillWIndow/Z NI1A_UseFnctToCreateName
 		endif
		Setvariable OutputFileName, disable=(Use2DdataName ||UseSampleNameFnct), win=NI1A_Convert2Dto1DPanel
		Setvariable SampleNameFnct, disable=!UseSampleNameFnct, win=NI1A_Convert2Dto1DPanel
		CheckBox TrimFrontOfName,disable=!(Use2DdataName), win=NI1A_Convert2Dto1DPanel
		CheckBox TrimEndOfName,disable=!(Use2DdataName), win=NI1A_Convert2Dto1DPanel
		SetVariable RemoveStringFromName,disable=!(Use2DdataName), win=NI1A_Convert2Dto1DPanel
	endif
	if(StringMatch("Use2DdataName",ctrlName))
		if(checked)
			UseSampleNameFnct=0
			KillWIndow/Z NI1A_UseFnctToCreateName
 		endif
		Setvariable OutputFileName, disable=(Use2DdataName ||UseSampleNameFnct), win=NI1A_Convert2Dto1DPanel
		Setvariable SampleNameFnct, disable=!UseSampleNameFnct, win=NI1A_Convert2Dto1DPanel
		CheckBox TrimFrontOfName,disable=!(Use2DdataName), win=NI1A_Convert2Dto1DPanel
		CheckBox TrimEndOfName,disable=!(Use2DdataName), win=NI1A_Convert2Dto1DPanel
		SetVariable RemoveStringFromName,disable=!(Use2DdataName), win=NI1A_Convert2Dto1DPanel
	endif

//	if(StringMatch(ctrlName,"RebinCalib2DData"))
//		PopupMenu RebinCalib2DDataToPnts,disable=(!RebinCalib2DData), win=NI1A_Convert2Dto1DPanel
//	endif
	if(StringMatch(ctrlName,"InclMaskCalib2DData"))
		if(!UseMask)
			InclMaskCalib2DData =0
			DoAlert 0, "Mask is not used, cannot include it in the export file"
		endif
	endif

	if(StringMatch(ctrlName,"Process_DisplayAve"))
		if(checked)
			//Process_DisplayAve = 0
			Process_Individually = 0
			Process_Average = 0
			Process_AveNFiles = 0
			Process_ReprocessExisting = 0
			NI1A_FixMovieBtnAndOtherCntrls()
		endif
	endif
	if(StringMatch(ctrlName,"Process_Individually"))
		if(checked)
			Process_DisplayAve = 0
			//Process_Individually = 0
			Process_Average = 0
			Process_AveNFiles = 0
			Process_ReprocessExisting = 0
			NI1A_FixMovieBtnAndOtherCntrls()
		endif
	endif
	if(StringMatch(ctrlName,"Process_Average"))
		if(checked)
			Process_DisplayAve = 0
			Process_Individually = 0
			//Process_Average = 0
			Process_AveNFiles = 0
			Process_ReprocessExisting = 0
			NI1A_FixMovieBtnAndOtherCntrls()
		endif
	endif
	if(StringMatch(ctrlName,"Process_AveNFiles"))
		if(checked)
			Process_DisplayAve = 0
			Process_Individually = 0
			Process_Average = 0
			//Process_AveNFiles = 0
			Process_ReprocessExisting = 0
			NI1A_FixMovieBtnAndOtherCntrls()
		endif
	endif
	if(StringMatch(ctrlName,"Process_ReprocessExisting"))
		if(checked)
			Process_DisplayAve = 0
			Process_Individually = 0
			Process_Average = 0
			Process_AveNFiles = 0
			//Process_ReprocessExisting = 0
			NI1A_FixMovieBtnAndOtherCntrls()
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
		if(checked)
			NEXUS_NikaCall(1)
			NVAR NX_SaveToProcNexusFile = root:Packages:Irena_Nexus:NX_SaveToProcNexusFile
			NX_SaveToProcNexusFile = 1
			NVAR Use2DdataName=root:Packages:Convert2Dto1D:Use2DdataName
			NVAR UseSampleNameFnct=root:Packages:Convert2Dto1D:UseSampleNameFnct
			if((Use2DdataName+UseSampleNameFnct)!=1)
				Use2DdataName = 1
				UseSampleNameFnct=0
			endif
			NVAR NX_Append2DDataToProcNexus = root:Packages:Irena_Nexus:NX_Append2DDataToProcNexus
			NVAR NX_Append1DDataToProcNexus = root:Packages:Irena_Nexus:NX_Append1DDataToProcNexus
			if(NX_SaveToProcNexusFile)
				if((NX_Append2DDataToProcNexus + NX_Append1DDataToProcNexus)<1)
					NX_Append1DDataToProcNexus = 1
				endif
			endif
			NEXUS_NikaCall(0)
		else
			NVAR NX_SaveToProcNexusFile = root:Packages:Irena_Nexus:NX_SaveToProcNexusFile
			NX_SaveToProcNexusFile = 0
			DoWIndow NEXUS_ConfigurationPanel
			if(V_flag)
					NEXUS_NikaCall(0)
			endif
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
	NVAR DisplayQCirclesOnImage=root:Packages:Convert2Dto1D:DisplayQCirclesOnImage

	if(StringMatch("DisplayQCirclesOnImage",ctrlName))
		DoWIndow CCDImageToConvertFig
		if(!V_flag)
			return 0
		endif
		if(checked)
			if(Qgrids+QnoGrids > 0.1)
				Qgrids=0
				QnoGrids=0
				NI1G_RemoveQAxisToImage(1)
			endif
		endif
		NI1G_AppendQCirclesToImage()		
	endif
	
	if(StringMatch("DisplayQValsOnImage",ctrlName))
		if(checked)
			Qgrids=0
			DisplayQCirclesOnImage = 0
			DoWIndow CCDImageToConvertFig
			if(!V_flag)
				return 0
			endif
			NI1G_AppendQCirclesToImage()		//removed drawings if needed also
			NI1G_AddQAxisToImage(0)
		else
			NI1G_RemoveQAxisToImage(1)
		endif
	endif
	
	if(StringMatch("DisplayQvalsWIthGridsOnImg",ctrlName))
		if(checked)
			QnoGrids=0
			DisplayQCirclesOnImage = 0
			DoWIndow CCDImageToConvertFig
			if(!V_flag)
				return 0
			endif
			NI1G_AppendQCirclesToImage()		//removed drawings if needed also
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
		NI1A_FixMovieBtnAndOtherCntrls()
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

//	if(cmpstr("UseUserDefMinMax",ctrlName)==0)
//		NVAR UseUserDefMinMax =  root:Packages:Convert2Dto1D:UseUserDefMinMax
//		SetVariable UserImageRangeMin,disable=!(UseUserDefMinMax)
//		SetVariable UserImageRangeMax, disable=!(UseUserDefMinMax)
//	endif
	
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
//		CheckBox ThetaSameNumPoints,disable=(!UseTheta)
	endif
	if(cmpstr("UseDspacing",ctrlName)==0)
		UseQvector=0
		//UseDspacing=0
		UseTheta=0
		UseDistanceFromCenter=0
		ControlInfo /W=NI1A_Convert2Dto1DPanel Convert2Dto1DTab
		if(V_Value==4)
			DoWIndow/F NI1A_Convert2Dto1DPanel
			SetVariable UserQMin,disable=(!UseQvector)
			SetVariable UserQMax,disable=( !UseQvector)
			SetVariable UserThetaMin,disable=( !UseTheta)
			SetVariable UserThetaMax,disable=( !UseTheta)
			SetVariable UserDMin,disable=( !UseDspacing)
			SetVariable UserDMax,disable=( !UseDspacing)
			Checkbox SaveGSASdata, disable=(!UseTheta)
	//		CheckBox ThetaSameNumPoints,disable=(!UseTheta)
		endif
	endif
	if(cmpstr("UseTheta",ctrlName)==0)
		UseQvector=0
		UseDspacing=0
		//UseTheta=0
		UseDistanceFromCenter=0
		ControlInfo /W=NI1A_Convert2Dto1DPanel Convert2Dto1DTab
		if(V_Value==4)
			DoWIndow/F NI1A_Convert2Dto1DPanel
			SetVariable UserQMin,disable=(!UseQvector)
			SetVariable UserQMax,disable=( !UseQvector)
			SetVariable UserThetaMin,disable=( !UseTheta)
			SetVariable UserThetaMax,disable=( !UseTheta)
			SetVariable UserDMin,disable=( !UseDspacing)
			SetVariable UserDMax,disable=( !UseDspacing)
			Checkbox SaveGSASdata, disable=(!UseTheta)
	//		CheckBox ThetaSameNumPoints,disable=(!UseTheta)
		endif
	endif
	if(cmpstr("UseDistanceFromCenter",ctrlName)==0)
		UseQvector=0
		UseDspacing=0
		UseTheta=0
		//UseDistanceFromCenter=0
		ControlInfo /W=NI1A_Convert2Dto1DPanel Convert2Dto1DTab
		if(V_Value==4)
			DoWIndow/F NI1A_Convert2Dto1DPanel
			SetVariable UserQMin,disable=(!UseQvector)
			SetVariable UserQMax,disable=( !UseQvector)
			SetVariable UserThetaMin,disable=( !UseTheta)
			SetVariable UserThetaMax,disable=( !UseTheta)
			SetVariable UserDMin,disable=( !UseDspacing)
			SetVariable UserDMax,disable=( !UseDspacing)
			Checkbox SaveGSASdata, disable=(!UseTheta)
	//		CheckBox ThetaSameNumPoints,disable=(!UseTheta)
		endif
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
			SetVariable QbinPoints, win=NI1A_Convert2Dto1DPanel, disable=(QvectorMaxNumPnts )
		endif
	endif
	if(cmpstr("QvectorMaxNumPnts",ctrlName)==0)
		NVAR QbinningLogarithmic=root:Packages:Convert2Dto1D:QbinningLogarithmic
		DoWIndow NI1A_Convert2Dto1DPanel
		if(V_Flag)
			ControlInfo /W=NI1A_Convert2Dto1DPanel Convert2Dto1DTab
			SetVariable QbinPoints, win=NI1A_Convert2Dto1DPanel, disable=(checked || V_Value!=4)
		endif
		DoWindow NI1_9IDCConfigPanel
		if(V_Flag)
			SetVariable QbinPoints, win=NI1_9IDCConfigPanel, disable=(checked)
		endif
		if(checked)
			QbinningLogarithmic=0
		else
			QbinningLogarithmic = 1
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
				MatrixOp/O  waveToDisplayDis = log(waveToDisplay)
			else
				MatrixOp/O  waveToDisplayDis = waveToDisplay
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
			KillWIndow/Z NI1A_PolCorPanel
 		endif		
	endif

	setDataFolder OldDf
End
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1A_LineProf_Update()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFOlder(1)
	DoWIndow CCDImageToConvertFig
	if(!V_Flag)
		return 0
	endif
	
	setDataFolder root:Packages:Convert2Dto1D
	NVAR DisplayBeamCenterIn2DGraph=root:Packages:Convert2Dto1D:DisplayBeamCenterIn2DGraph
	NVAR DisplaySectorsIn2DGraph=root:Packages:Convert2Dto1D:DisplaySectorsIn2DGraph
	NVAR UseSectors = root:Packages:Convert2Dto1D:UseSectors
	NVAR UseLineProfile=root:Packages:Convert2Dto1D:UseLineProfile
	NVAR DisplayQValsOnImage= root:Packages:Convert2Dto1D:DisplayQValsOnImage
	NVAR DisplayQvalsWIthGridsOnImg = root:Packages:Convert2Dto1D:DisplayQvalsWIthGridsOnImg
	NVAR DisplayColorScale = root:Packages:Convert2Dto1D:DisplayColorScale
	NVAR DisplayQCirclesOnImage=root:Packages:Convert2Dto1D:DisplayQCirclesOnImage
	
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
	if(DisplayQCirclesOnImage)
		NI1G_AppendQCirclesToImage()
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
		//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	
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

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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

		//NVAR LineProf_LineAzAngle=root:Packages:Convert2Dto1D:LineProf_LineAzAngle
		NVAR LineProf_LineAzAngleG =root:Packages:Convert2Dto1D:LineProf_LineAzAngle
		variable LineProf_LineAzAngle
		LineProf_LineAzAngle = LineProf_LineAzAngleG>=0 ? LineProf_LineAzAngleG : LineProf_LineAzAngleG+180
		NVAR LineProf_GIIncAngle=root:Packages:Convert2Dto1D:LineProf_GIIncAngle
		NVAR LineProf_EllipseAR=root:Packages:Convert2Dto1D:LineProf_EllipseAR

		if(stringMatch(LineProf_CurveType,"---"))
			return 0
		endif
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	//generate X-Y path for angle line on the detector
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	variable MaxDIm=max(DetDimX, DetDimY)		//rtGlobals=3 fix. 
	make/O/N=(MaxDIm) tempWvX
	make/O/N=(MaxDIm) tempWvY
	if(abs(angle)<45)
		tempWvX=p
		tempWvY=BCy-(tempWvX-BCx)*tan(Angle*pi/180)
	elseif(abs(angle)>=45 && abs(angle)<135)
		tempWvY=p
		tempWvX=BCx+(tempWvY-BCy)*tan((Angle-90)*pi/180)
	else
		tempWvX=p
		tempWvY=BCy-(tempWvX-BCx)*tan(Angle*pi/180)	
	endif
	//now offset the line by the geometrically corrected offset...
	if(abs(angle)<45)
		tempWvY-=Offset / cos(Angle*pi/180)
	elseif(abs(angle)>=45 && abs(angle)<135)
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
//
//Function NI1A_GenerGISAXSQyLine(DetDimX,DetDimY,BCx,BCy,Angle,Offset,WaveX,WaveY)
//	variable DetDimX,DetDimY,BCx,BCy,Angle,Offset
//	Wave WaveX,WaveY
//	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//	//generate X-Y path for angle line on the detector
//	string oldDf=GetDataFOlder(1)
//	setDataFolder root:Packages:Convert2Dto1D
//	
//	make/O/N=(DetDimX) tempWvX
//	make/O/N=(DetDimY) tempWvY
//
//
//
//	WaveX=tempWvX
//	WaveY=tempWvY
//	killWaves tempWvY, tempWvX
//	
//	setDataFolder OldDf
//end
//
//
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1GI_CalculateQxyz(DimXpos,DimYpos,WhichOne)
	variable DimXpos,DimYpos
	String WhichOne
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR ycenter=root:Packages:Convert2Dto1D:BeamCenterY
	NVAR xcenter=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR LineProf_GIIncAngle=root:Packages:Convert2Dto1D:LineProf_GIIncAngle
	NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance
	NVAR Wavelength=root:Packages:Convert2Dto1D:Wavelength
	NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
	NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
	NVAR GISAXS_ycenterReflectedbeam=root:Packages:Convert2Dto1D:GISAXS_ycenterReflectedbeam
	
	variable K0val=2*pi/wavelength
	variable alphaI = LineProf_GIIncAngle * pi / 180
	variable TwoThetaF=atan((xcenter-DimXpos)*PixelSizeX /SampleToCCDDistance) 
	variable alphaF
	if(abs(GISAXS_ycenterReflectedbeam)<1)			//this is GISAXS_SOL where user set this value to about 0 and tilted the samples
		alphaF = atan((ycenter - DimYpos)*PixelSizeY /SampleToCCDDistance) - alphaI		
	else		//GISAXS_ycenterReflectedbeam !=0, user is using center of reflected beam. This is for GISAXS_LSS geometry.
		alphaF = atan((ycenter-(ycenter-GISAXS_ycenterReflectedbeam)/2 - DimYpos)*PixelSizeY /SampleToCCDDistance)
	endif
	//fix 2015-02-14, found by marvin.berlinghof@fau.de
	//note. See Manual. 
	
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
 	 //IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
 	 //string OldDf=GetDataFOlder(1)
    //setDataFolder root:Packages:Convert2Dto1D
 	 NVAR DezingerRatio =root:Packages:Convert2Dto1D:DezingerRatio
 	 string OldNote=note(image)
    Duplicate/Free image, dup
    MatrixFilter /N=3 median image				    			 // 3x3 median filter (integer result if image integer, fp if fp)
    MatrixOp/Free  DiffWave = dup / (abs(image))      // difference between raw and filtered, high values (>35) are cosmics and high signals
       //image = SelectNumber(DiffWave>DezingerRatio,dup,image)    // choose filtered (image) if difference is great
    MatrixOp/O  image = dup * (-1)*(greater(Diffwave,DezingerRatio)-1) + image*(greater(Diffwave,DezingerRatio))
	     //the MatrixOp is 3x faster than the original line.... 
	 note image, OldNote
    //KillWaves/Z DiffWave, FilteredDiffWave, dup
   // setDataFolder OldDf
End


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//this is way to get a circle on the main graph...
Function NI1G_AppendQCircle(Qvalue)
		variable QValue
		//OK, now the window is at the top...
		//what is this for? This is from Beam Center utilities... 
		if(stringMatch(AxisList("CCDImageToConvertFig"),"*top*"))
			setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=top,ycoord=left,save
		else
			setdrawenv/W=CCDImageToConvertFig fillpat=0,xcoord=bottom,ycoord=left,save
		endif
		//lets use tilts always...
		make/O/N=180 $("QCircleWaveX"+num2str(QValue)), $("QCircleWaveY"+num2str(QValue))		//these are two "Paths" for the drawing
		wave wvX=$("QCircleWaveX"+num2str(QValue))
		wave wvY = $("QCircleWaveY"+num2str(QValue))
		SetScale /I x, 0, 2*pi,"rad" , wvX, wvY					//their x dimension is their azimuthal direction
		//we need to fill them with px and py values for given Q
		Wave CCDImageToCOnvert=root:Packages:Convert2Dto1D:CCDImageToCOnvert
		//round Q value to be easy number
		if(QValue<1)
			QValue = IN2G_roundSignificant(QValue,2)
		else
			QValue = IN2G_roundSignificant(QValue,3)
		endif
		variable dPosition = 2*pi/QValue
		NI1BC_FindTiltedQvalues(wvx,wvy,dPosition, CCDImageToCOnvert,"CCDImageToConvertFig")
		variable Xattach, Yattach
		variable PntNumber = NI1G_FindAttachPoint(wvx)
		
		Xattach = wvx[PntNumber]
		Yattach = wvy[PntNumber]
		//print Xattach, Yattach
		//setDrawLayer/W=CCDImageToConvertFig ProgFront
		SetDrawEnv/W=CCDImageToConvertFig linefgc=(65535, 65535,65535)
		SetDrawEnv/W=CCDImageToConvertFig linethick=2, linefgc= (65535,0,0)
		DrawPoly /W=CCDImageToConvertFig /ABS 0,0, 1, 1, wvX,wvY
		SetDrawEnv textrgb= (65535,0,0),fsize= 16
		DrawText /W=CCDImageToConvertFig Xattach, Yattach, num2str(QValue)
		//setDrawLayer/W=CCDImageToConvertFig/K UserFront
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
static Function NI1G_FindAttachPoint(xWaveIn)
	wave xWaveIn
	//locate point for attaching the label
	//ideally at the top or bottom 
	//alternative is left or right
	variable PointNum
	if(numtype(xWaveIn(3*pi/2))==0)	//real value at 90 deg up
		PointNum = x2pnt(xWaveIn, 3*pi/2 )
	elseif(numtype(xWaveIn(pi/2))==0)	//real value at 90 deg up
		PointNum = x2pnt(xWaveIn, pi/2 )
	elseif(numtype(xWaveIn(pi))==0)	//real value at 90 deg up
		PointNum = x2pnt(xWaveIn,pi )
	elseif(numtype(xWaveIn(0))==0)	//real value at 90 deg up
		PointNum = x2pnt(xWaveIn, 0)
	else
		PointNum = 0
	endif
	return PointNum	
end
//	wave BmCntrCCDImg = root:Packages:Convert2Dto1D:BmCntrCCDImg
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1G_AppendQCirclesToImage()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	
	string OldDf = GetDataFolder(1)
	setDataFolder root:Packages:Convert2Dto1D
	DoWIndow CCDImageToConvertFig
	if(!V_flag)
		abort
	else
		DoWIndow/F CCDImageToConvertFig
	endif
	NVAR DisplayQCirclesOnImage=root:Packages:Convert2Dto1D:DisplayQCirclesOnImage
	//figure out Q raneg using root:Packages:Convert2Dto1D:Q2DWave
	Wave/Z Q2DWave = root:Packages:Convert2Dto1D:Q2DWave
	if(!WaveExists(Q2DWave))
		return 0		//cannot append Q axis if we do not know the Q range.  
	else
		Duplicate/Free Q2DWave, TmpQ2DWave
	endif
	Wave/Z Mask = root:Packages:Convert2Dto1D:M_ROIMask
	if(WaveExists(Mask))	//mask the Q values... 
		//check dimensions agree...
		if(dimsize(Q2DWave,0)!=dimsize(Mask,0)||dimsize(Q2DWave,1)!=dimsize(Mask,1))
			return 0		//something worng, stop here...
		else
			MatrixOp/O TmpQ2DWave=TmpQ2DWave/Mask
		endif
	endif
	if(DisplayQCirclesOnImage)
		variable Qmin, Qmax
		wavestats/Q TmpQ2DWave
		Qmin=V_min*1.2
		Qmax=V_max*0.95
		variable NumLines=NikaNumberOfQCirclesDisp
		make/O/D/FREE/N=(NumLines) QPositions
		variable Qvalue, i, tmpVal, logstartX, logendX
		logstartX=log(Qmin)
		logendX=log(Qmax)
		QPositions = logstartX + p*(logendX-logstartX)/(numpnts(QPositions)-1)
		QPositions = 10^(QPositions)
	
		For(i=0;i<NikaNumberOfQCirclesDisp;i+=1)
			Qvalue = QPositions[i]
			//print Qvalue
			NI1G_AppendQCircle(Qvalue)
		endfor
	else	//remove drawings
		//setDrawLayer/W=CCDImageToConvertFig/K ProgFront
	   setDrawLayer/W=CCDImageToConvertFig/K UserFront
	endif

	setDataFolder OldDf
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//************************************************************************
//************************************************************************
//************************************************************************

Function NI1G_AddQAxisToImage(UseGrids)
	variable UseGrids
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")


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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

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
//
//Function NI2T_testThetaWithTilts()		// calculate theta for pixel px, py - optionally reset parameters from defaluts, else read stored structure
//	
//	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//	STRUCT NikadetectorGeometry d
//	wave testImg
//		NI2T_ReadOrientationFromGlobals(d)
//		NI2T_SaveStructure(d)
//		NI2t_printDetectorStructure(d)
////variable startTicks=ticks	
////	multithread testImg =  NI2T_pixel2Theta(d,p,q)
////print (ticks-startTicks)/60
//end
//
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI2T_Calculate2DThetaWithTilts(Theta2DWave)		// calculate theta for pixel px, py
	wave Theta2DWave
	STRUCT NikadetectorGeometry d
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")

		NI2T_ReadOrientationFromGlobals(d)
		NI2T_SaveStructure(d)
		Multithread Theta2DWave =  NI2T_pixelTheta(d,p,q)
end


//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************
Function/C NI2T_CalculatePxPyWithTilts(theta, direction)  
	variable theta, direction
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	make/FREE/N=3/D ki
	make/FREE/N=3/D kout
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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

	make/FREE/N=3/D ki
	make/FREE/N=3/D kout
	ki = {0,0,1}									//	ki =   ki[p],  incident beam direction

	NI2T_pixel2XYZ(d,px,py,kout)						// kout is in direction of pixel in beam line coords
	NI2T_normalize(kout)
	//MatrixOp kout= Normalize(kout)
	
	Variable Theta = acos(MatrixDot(kout,ki)) /2   	// ki.kf = cos(2theta), (radians)

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
//
//
//Function NI2T_InitTiltCorrection()
//
//	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
//	string OldDf=GetDataFolder(1)
//	setDataFolder root:
//	NewDataFolder/O root:Packages							// ensure Packages exists
//	NewDataFolder/O root:Packages:NikaTiltCorrections		// ensure NikaTiltCorrections exists
//
//	Make/N=3/O/D root:Packages:NikaTiltCorrections:pixel2q_ki, root:Packages:NikaTiltCorrections:pixel2q_kout
//
//	setDataFolder OldDf
//end 
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

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
//	d.R[2]=pi*AzimuthalTilt/180				// angle of detector, theta = 0
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

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	printf "	Nx=%d, Ny=%d			// number of un-binned pixels in detector\r",d.Nx,d.Ny
	printf "	sizeX=%g, sizeY=%g		// size of detector (mm)\r",(d.sizeX/1000), (d.sizeY/1000)
	printf "	R = {%.7g, %.7g, %.7g}, a rotation of %.7g°	// rotation vector\r",d.R[0],d.R[1],d.R[2],sqrt(d.R[0]*d.R[0] + d.R[1]*d.R[1] + d.R[2]*d.R[2])*180/PI
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
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	String OldDf=GetDataFolder(1)
	SetDataFOlder root:Packages:Convert2Dto1D
	NVAR UseBatchProcessing=root:Packages:Convert2Dto1D:UseBatchProcessing
	UseBatchProcessing = 0
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
		NewPanel /FLT/K=1/W=(573,44,1000,210) as "Nika Background processing"
		DoWindow/C NI_LiveDataProcessing
		SetDrawLayer UserBack
		SetDrawEnv fsize= 14,fstyle= 3,textrgb= (0,0,65535)
		DrawText 6,25,"Nika \"Live\" data proc."
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
	CtrlNamedBackground NI2_MonitorDataFolder, status
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

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			if(stringMatch("UpdateTimeSelection",pa.ctrlName))
				NVAR BckgUpdateInterval= root:Packages:Convert2Dto1D:BckgMonitorParams:BckgUpdateInterval
				BckgUpdateInterval = str2num(pa.popStr)
				CtrlNamedBackground NI2_MonitorDataFolder, status
				if(NumberByKey("RUN", S_Info))		//running, restart with new parameters
					NI2_StopFolderWatchTask()
					NI2_StartFolderWatchTask()
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

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch("StartBackgrTask",ba.ctrlName))
				NI2_StartFolderWatchTask()
			endif
			if(stringmatch("StopBackgrTask",ba.ctrlName))
				NI2_StopFolderWatchTask()
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


Function NI2_StartFolderWatchTask()
	//Variable numTicks = 5 * 60 // Run every two seconds (120 ticks) 
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR BckgUpdateInterval= root:Packages:Convert2Dto1D:BckgMonitorParams:BckgUpdateInterval
		CtrlNamedBackground NI2_MonitorDataFolder, period=BckgUpdateInterval*60, proc=NI2_MonitorFldrBackground 
		CtrlNamedBackground NI2_MonitorDataFolder, start
		Printf "Nika FolderWatch background task (\"NI2_MonitorDataFolder\") started with %d [s] update interval\r", BckgUpdateInterval
		SVAR BckgStatus = root:Packages:Convert2Dto1D:BckgMonitorParams:BckgStatus
		BckgStatus = "   Running background job   "
		TitleBox Status win=NI_LiveDataProcessing,fColor=(65535,0,0),labelBack=(32792,65535,1)
		Button OnLineDataProcessing win=NI1A_Convert2Dto1DPanel, fColor=(65535,0,0)
End
//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI2_StopFolderWatchTask()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
   CtrlNamedBackground NI2_MonitorDataFolder, stop
	Printf "Nika FolderWatch background task (\"NI2_MonitorDataFolder\") stopped\r"
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
	
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
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

	Printf "%s : task %s called, found %d data images in current folder\r", time(), s.name, numpnts(ListOf2DSampleData)

	if(numpnts(ListOf2DSampleData)>numpnts(ListOf2DSampleDataOld))	//new data set appeared
		NumberOfNewImages=numpnts(ListOf2DSampleData)-numpnts(ListOf2DSampleDataOld)
		if(FilesSortOrder==0)
			//here we need to select the new file. Only when files are not ordered, or it should be clear. 
			Printf "%s : found %g new data image(s), since using unsorted as sort order, will pick one to process \r", time(), NumberOfNewImages
			Make/Free/T ResWave
			IN2G_FindNewTextElements(ListOf2DSampleData,ListOf2DSampleDataOld,reswave)
			//assume reswave[0] contains the last image added (impossible to say, actually)
			Printf "%s : Selected %s, calling user routine using this file name \r", time(), reswave[0]
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
			Printf "%s : found %g new data image(s), since sorting is selected, using the last one \r", time(), NumberOfNewImages
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

//Function NI1A_Export2DData()
	//exports 2D calibrated data if user requests it
//	NEXUS_NikaSave2DCalData()
//ABort "This belongs to NEXUS package"
//	NVAR ExpCalib2DData=root:Packages:Convert2Dto1D:ExpCalib2DData
//	if(!ExpCalib2DData)
//		return 0
//	endif
//	NVAR RebinCalib2DData=root:Packages:Convert2Dto1D:RebinCalib2DData
//	NVAR InclMaskCalib2DData=root:Packages:Convert2Dto1D:InclMaskCalib2DData
//	NVAR UseQxyCalib2DData=root:Packages:Convert2Dto1D:UseQxyCalib2DData
//	NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
//	NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
//	variable XDimension, YDimension
//	SVAR/Z RebinCalib2DDataToPnts=root:Packages:Convert2Dto1D:NX_RebinCal2DDtToPnts
//	if(!SVAR_Exists(RebinCalib2DDataToPnts))
//		NEXUS_NikaCall(1)
//		SVAR RebinCalib2DDataToPnts=root:Packages:Convert2Dto1D:NX_RebinCal2DDtToPnts		
//	endif
//	strswitch(RebinCalib2DDataToPnts)	// string switch
//		case "100x100":		// execute if case matches expression
//			XDimension=100
//			YDimension=100
//			break					// exit from switch
//		case "200x200":		// execute if case matches expression
//			XDimension=200
//			YDimension=200
//			break					// exit from switch
//		case "300x300":		// execute if case matches expression
//			XDimension=300
//			YDimension=300
//			break					// exit from switch
//		case "400x400":		// execute if case matches expression
//			XDimension=400
//			YDimension=400
//			break					// exit from switch
//		case "600x600":		// execute if case matches expression
//			XDimension=600
//			YDimension=600
//			break					// exit from switch
//		default:							// optional default expression executed
//			XDimension=800
//			YDimension=800
//		endswitch
//	//here we get only if user wants to export 2D calibrated data...
//	//check the wave of interest exist...
//	wave/Z Calibrated2DDataSet = root:Packages:Convert2Dto1D:Calibrated2DDataSet
//	if(!WaveExists(Calibrated2DDataSet))
//			Abort "Error in NI1A_Export2DData. Calibrated data do not exist..."
//			return 0
//	endif
//	wave/Z Q2DWave = root:Packages:Convert2Dto1D:Q2DWave
//	if(!WaveExists(Q2DWave))
//			Abort "Error in NI1A_Export2DData. Q2DWave data do not exist..."
//			return 0
//	endif
//	//check for Mask presence...
//	if(InclMaskCalib2DData)
//		Wave/Z Mask = root:Packages:Convert2Dto1D:M_ROIMask
//		if(!WaveExists(Mask))
//				Abort "Error in NI1A_Export2DData. Mask data do not exist..."
//				return 0
//		endif
//	endif
//	Duplicate/Free Calibrated2DDataSet, IntExp2DData
//	Duplicate/Free Q2DWave, QExp2DData
//	if(InclMaskCalib2DData)
//		Duplicate/O Mask, MaskExp2DData
//		//Igor Mask has 0 where masked, 1 where used. This is opposite (of course) to what Nexus/CanSAS uses:
//		//Pete:   mask is 1 when the point is removed, 0 when is used. 
//		//MatrixOp/O  MaskExp2DData = abs(MaskExp2DData-1)
//		MaskExp2DData = !MaskExp2DData
//	else
//		Duplicate/Free Q2DWave, MaskExp2DData		//fake for possible rebinning...
//	endif
//	Wave AnglesWave= root:Packages:Convert2Dto1D:AnglesWave
//	Duplicate/Free AnglesWave, AnglesWaveExp
//
//	if(RebinCalib2DData)
//		//here we need to create proper rebinned data
//		//first need to create UnbinnedQx, and UnbinnedQy
//		MatrixOp/Free QxExp2DData = QExp2DData * sin(AnglesWaveExp)
//		MatrixOp/Free QyExp2DData = QExp2DData * cos(AnglesWaveExp)
//		make/Free/N=(DimSize(QxExp2DData, 0)) UnbinnedQx
//		make/Free/N=(DimSize(QyExp2DData, 1)) UnbinnedQy
//		UnbinnedQx = QxExp2DData[BeamCenterX][p]
//		UnbinnedQy = QyExp2DData[p][BeamCenterY]
//		NI1A_RebinOnLogScale2DData(IntExp2DData,QExp2DData, AnglesWaveExp, MaskExp2DData, XDimension, YDimension,BeamCenterX, BeamCenterY)
//		MatrixOp/O MaskExp2DData = ceil(MaskExp2DData)	//any point which had mask in it will be masked, I need to revisit this later, if this works. 
//	else
//		//exporting data in their original size. This may be large for SAXS data sets!
//	endif
//	//create Qx and Qy if needed, using rebinned data, if these were created.
//	if(UseQxyCalib2DData)
//		MatrixOp/Free QxExp2DData = QExp2DData * sin(AnglesWaveExp)
//		MatrixOp/Free QyExp2DData = QExp2DData * cos(AnglesWaveExp)
//	endif
//
//	//get the file name right...
//	string LocalUserFileName
//	string UseName
//	string LongUseName
//	SVAR LoadedFile=root:Packages:Convert2Dto1D:FileNameToLoad
//	SVAR UserFileName=root:Packages:Convert2Dto1D:OutputDataName
//	SVAR TempOutputDataname=root:Packages:Convert2Dto1D:TempOutputDataname
//	SVAR TempOutputDatanameUserFor=root:Packages:Convert2Dto1D:TempOutputDatanameUserFor
//	NVAR Use2DdataName=root:Packages:Convert2Dto1D:Use2DdataName
//	NVAR AppendToNexusFile=root:Packages:Convert2Dto1D:AppendToNexusFile	
//
//	if(AppendToNexusFile)
//			UseName=LoadedFile		//this is file we imported, now we need to append to it. 
//	else
//		if (Use2DdataName)
//			UseName=NI1A_TrimCleanDataName(LoadedFile)+".h5"
//		else
//			if(strlen(UserFileName)<1)	//user did not set the file name
//				if(cmpstr(TempOutputDatanameUserFor,LoadedFile)==0 && strlen(TempOutputDataname)>0)		//this file output was already asked for user
//					LocalUserFileName = TempOutputDataname
//				else
//					Prompt LocalUserFileName, "No name for this sample selected, data name is "+ LoadedFile
//					DoPrompt /HELP="Input name for the data to be stored, max 20 characters" "Input name for the 1D data", LocalUserFileName
//					if(V_Flag)
//						abort
//					endif
//					TempOutputDataname = LocalUserFileName
//					TempOutputDatanameUserFor = LoadedFile
//				endif
//				UseName=NI1A_TrimCleanDataName(LocalUserFileName)+".h5"
//			else
//				UseName=NI1A_TrimCleanDataName(UserFileName)+".h5"
//			endif
//		endif
//	endif
//	if(InclMaskCalib2DData)
//		if(UseQxyCalib2DData)
//			if(RebinCalib2DData)
//				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData, Qx=QxExp2DData, Qy=QyExp2DData, Mask=MaskExp2DData, AzimAngles=AnglesWaveExp,UnbinnedQx=UnbinnedQx,UnbinnedQy=UnbinnedQy)
//			else
//				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData, Qx=QxExp2DData, Qy=QyExp2DData, Mask=MaskExp2DData, AzimAngles=AnglesWaveExp)
//			endif
//		else
//			if(RebinCalib2DData)
//				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData, Mask=MaskExp2DData,Qwv=QExp2DData, AzimAngles=AnglesWaveExp,UnbinnedQx=UnbinnedQx,UnbinnedQy=UnbinnedQy)
//			else
//				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData, Mask=MaskExp2DData,Qwv=QExp2DData, AzimAngles=AnglesWaveExp)
//			endif
//		endif
//	else
//		if(UseQxyCalib2DData)
//			if(RebinCalib2DData)
//				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData, Qx=QxExp2DData, Qy=QyExp2DData, AzimAngles=AnglesWaveExp,UnbinnedQx=UnbinnedQx,UnbinnedQy=UnbinnedQy)
//			else
//				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData, Qx=QxExp2DData, Qy=QyExp2DData, AzimAngles=AnglesWaveExp)
//			endif
//		else
//			if(RebinCalib2DData)
//				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData,Qwv=QExp2DData, AzimAngles=AnglesWaveExp,UnbinnedQx=UnbinnedQx,UnbinnedQy=UnbinnedQy)
//			else
//				NI1A_WriteHdf52DCanSASData(AppendToNexusFile, UseName, IntExp2DData,Qwv=QExp2DData, AzimAngles=AnglesWaveExp)
//			endif
//		endif	
//	endif
//end


//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI1A_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	
	if(cmpstr(ctrlName,"Select2DDataType")==0)
		//set appropriate extension
		SVAR DataFileExtension=root:Packages:Convert2Dto1D:DataFileExtension
		NVAR UseCalib2DData=root:Packages:Convert2Dto1D:UseCalib2DData
		DataFileExtension = popStr
		NI1A_UpdateDataListBox()
		if(cmpstr(popStr,"GeneralBinary")==0)
			NI1_GBLoaderPanelFnct()
		endif
		if(cmpstr(popStr,"Pilatus/Eiger")==0)
			NI1_PilatusLoaderPanelFnct()
		endif
		if(cmpstr(popStr,"ESRFedf")==0)
			NI1_ESRFEdfLoaderPanelFnct()
		endif	
		if(cmpstr(popStr,"Nexus")==0)
			NEXUS_NikaCall(1)
			NVAR NX_InputFileIsNexus=root:Packages:Irena_Nexus:NX_InputFileIsNexus
			NX_InputFileIsNexus = 1
		else
			NVAR/Z NX_InputFileIsNexus=root:Packages:Irena_Nexus:NX_InputFileIsNexus
			if(NVAR_Exists(NX_InputFileIsNexus))
				NX_InputFileIsNexus = 0
			endif
		endif	
		NEXUS_NikaCall(0)
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
//	if(cmpstr(ctrlName,"RebinCalib2DDataToPnts")==0)
//		//set appropriate extension
//		SVAR RebinCalib2DDataToPnts=root:Packages:Convert2Dto1D:RebinCalib2DDataToPnts
//		RebinCalib2DDataToPnts = popStr
//	endif

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
		KillWIndow/Z GISAXSOptionsPanel
		if(stringMatch(LineProf_CurveType,"GI_*"))
			NI1_GISAXSOptions() 
		endif
		NI1A_LineProf_Update()
	endif
	if(cmpstr(ctrlName,"ColorTablePopup")==0)
		SVAR ColorTableName=root:Packages:Convert2Dto1D:ColorTableName
		ColorTableName = popStr
		//check if there is image at the top, if not, bring up the CCDImageoCOnvert  
		if(strlen(ImageNameList("", ";"))<1)
			DoWIndow CCDImageToConvertFig
			if(V_Flag)
				DoWIndow/F CCDImageToConvertFig
			endif
		endif
		NI1A_TopCCDImageUpdateColors(1)
		IN2G_SaveIrenaGUIPackagePrefs(0)
	endif
	if(cmpstr(ctrlName,"MaskImageColor")==0)
		NI1M_ChangeMaskColor(popStr) 
	endif
	if(cmpstr(ctrlName,"GI_Shape1")==0)
		SVAR GI_Shape1=root:Packages:Convert2Dto1D:GI_Shape1
		GI_Shape1=popStr 
		NI1A_TabProc("",6)
	endif

	DoWIndow/F NEXUS_ConfigurationPanel
	DoWIndow/F NI1A_Convert2Dto1DPanel
	DoWIndow/F NI_GBLoaderPanel
	DoWIndow/F NI_PilatusLoaderPanel

	setDataFolder OldDf
End


//*************************************************************************************************
//*************************************************************************************************
//*************************************************************************************************

Function NI1_CalculateImageStatistics()
	//IN2G_PrintDebugStatement(IrenaDebugLevel, 5,"")
	NVAR CalculateStatistics=root:Packages:Convert2Dto1D:CalculateStatistics
	String nb = "ImageStatistics"
	if(CalculateStatistics)
		//first figure out if there is anything to do...
		//1. we need CCDImageToConvertFig
		//2. we need root:Packages:Convert2Dto1D:CCDImageToConvert
		//3. alternatively, if available also : root:Packages:Convert2Dto1D:Calibrated2DDataSet
		DoWIndow CCDImageToConvertFig
		string tmpsStr1
		if(V_Flag)
			Wave/Z CCDImageToConvert =  root:Packages:Convert2Dto1D:CCDImageToConvert
			Wave/Z Calibrated2DDataSet =  root:Packages:Convert2Dto1D:Calibrated2DDataSet
			SVAR UserSampleName = root:Packages:Convert2Dto1D:UserSampleName
			SVAR FileNameToLoad = root:Packages:Convert2Dto1D:FileNameToLoad
			NVAR UseMask = root:Packages:Convert2Dto1D:UseMask
			if(WaveExists(CCDImageToConvert))
				KilLWIndow/Z ImageStatistics
				NewNotebook/N=$nb/F=0/V=1/K=1/ENCG={1,1}/W=(678,55,1113,713)
				Notebook $nb defaultTab=20
				Notebook $nb font="Monaco", fSize=11, fStyle=0, textRGB=(0,0,0)
				AutoPositionWindow/M=0/R=CCDImageToConvertFig ImageStatistics		
				Notebook $nb text="***************************\r"
				Notebook $nb text="User sample name :\t"+UserSampleName+"\r"
				Notebook $nb text="File name : \t\t\t"+FileNameToLoad+"\r"			
				PathInfo Convert2Dto1DDataPath
				Notebook $nb text="Data path: \t\t\t"+S_path+"\r"				
				Notebook $nb text="\r"
				Notebook $nb text="***************************\r"		
				Duplicate/Free CCDImageToConvert, tmpCCDImageToConvert
				if(UseMask)
					Wave mask = root:Packages:Convert2Dto1D:M_ROIMask
					WaveStats/Q mask
					Notebook $nb text="Data are masked\r"
					Notebook $nb text="Number of Masked points = "+num2str(V_npnts - V_Sum)+"\r"	
					tmpCCDImageToConvert /=mask
					tmpsStr1 = "Masked Raw image statistics:\r"
					Notebook $nb text="\r"
				else
					tmpsStr1 = "Raw image statistics:\r"
				endif
				Notebook $nb text=tmpsStr1
				WaveStats/Q  tmpCCDImageToConvert
				Notebook $nb text="Image dimensions: "+num2str(DimSize(CCDImageToConvert, 0 ))+" x "+ num2str(DimSize(CCDImageToConvert, 1 ))+"\r"
				Notebook $nb text="Nuber of pixels = "+num2str(V_npnts)+"\r"
				Notebook $nb text="Average counts/pix = "+num2str(V_avg)+"\r"
				Notebook $nb text="Sum counts = "+num2str(V_Sum)+"\r"
				Notebook $nb text="Max Counts/pix = "+num2str(V_max)+"\r"
				Notebook $nb text="Min Counts/pix = "+num2str(V_min)+"\r"
				if(WaveExists(Calibrated2DDataSet))
					Notebook $nb text="\r"
					Notebook $nb text="***************************\r"
					Notebook $nb text="Processed image statistics:\r"
					WaveStats/Q  Calibrated2DDataSet
					Notebook $nb text="Average Intensity/pix = "+num2str(V_avg)+"\r"
					Notebook $nb text="Sum Intensity = "+num2str(V_Sum)+"\r"
					Notebook $nb text="Max Int/pix = "+num2str(V_max)+"\r"
					Notebook $nb text="Min Int/pix = "+num2str(V_min)+""
				endif						
			endif
		endif
	endif
end