#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.



//*************************************************************************\
//* Copyright (c) 2005 - 2019, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//version 1.0 support functions for 3D modeling tools. Original release. 2019-02-27


//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//			3D packages, 2019-02-27
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************


//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//			Utility functions
//******************************************************************************************************************************************************
//*****************************************************************************************************************
//this function takes as input voxelgram, generated directly or using ConvertToVoxelGram(ListWv, primaryradius)
// VoxelSize here is dimension, which is the size of the voxel... For 3D Solids it is waht mdoel assumed.
// If using ConvertToVoxelGram(ListWv, primaryradius) one needs to calculated this from two values:
// Size of the primary particle of teh aggregate, close to Rg level 1, may be needs to be slightly modified
// Oversampling used in ConvertToVoxelGram - currently defaulted to 10. 
//   Therefore, if Rg of level 1 is 20 A = assume diameter is 40A, the VoxelSize is actually 4 
//   each original "particle" in the Aggregate was replaced with 10 x 10 x 10 voxels, basically we made assumption that diameter of the primary particle is 10.   
Function IR3T_CreatePDF(ThreeDVoxelGram,VoxelSize, NumRSteps, IsoValue, oversample, Qmin, Qmax, NumQSteps)
	wave ThreeDVoxelGram
	variable VoxelSize, NumRSteps, IsoValue, oversample, Qmin, Qmax, NumQSteps
	//oversample can be 1 or larger integer (2-4 is sensible). Makes evaluated voxelgram oversample * larger to improve data at high-qs. 
	//VoxelSize in [A] per voxel
	//IsoValue typically 0.5, if solid is 1 and void is 0 density
	//Qmin, Qmax, NumQSteps 		what q range for intensity calculation
	variable StartTicks=ticks
	
	if(oversample>1)		//this helps a lot, takes time, but imporves high-q fitting... 
		Print "oversampling Data by factor of "+num2str(oversample)
		StartTicks=ticks
		oversample = ceil (oversample)			//make sure we have integer. 
		SetScale/P x 0,1,"", ThreeDVoxelGram		//Interp3D uses wave scaling, so we need to match wave scaling to point numbers... 
		SetScale/P y 0,1,"", ThreeDVoxelGram
		SetScale/P z 0,1,"", ThreeDVoxelGram
		make/Free/S/N=(oversample*dimsize(ThreeDVoxelGram,0),oversample*dimsize(ThreeDVoxelGram,1),oversample*dimsize(ThreeDVoxelGram,2)) OversampledThreeDVoxelGram
		//multithread Use3DWave = ThreeDVoxelGram[floor(p/oversample)][floor(q/oversample)][floor(r/oversample)]
		multithread OversampledThreeDVoxelGram = Interp3D(ThreeDVoxelGram, ((p/oversample)), ((q/oversample)),((r/oversample)) )	
		MatrixOp/Free/NTHR=0 Use3DWaveThresh = greater(OversampledThreeDVoxelGram,0.55)		//this tresholds the wave so it is smoother than what simple assignment above does... 
		wave Use3DWave = Use3DWaveThresh
		print "Done oversampling after "+num2str((ticks-StartTicks)/60)
	else
		Print "NO oversampling selected "
		wave Use3DWave = ThreeDVoxelGram
	endif
	
	variable RadMin,RadMax	//for now, these are simply steps in voxels, we are now working with integer of pixel positions... 
	RadMin = 0.5
	RadMax = ceil(sqrt(3)*max(DimSize(Use3DWave, 0 ), DimSize(Use3DWave, 1),DimSize(Use3DWave, 2 ) ))
	Make/O/N=(NumRSteps)/D VoxDistanceWave
	VoxDistanceWave = p*(RadMax-RadMin)/NumRSteps	+ 1 						//linear distance space... 
	//testing shows, that linear radius binning is better. We get better behavior at high q values. 
	//IN2G_ConvertTologspacing(VoxDistanceWave, 0.5)							//sets k scaling on log-scale...	
	Make/FREE/N=0 Distances
	Make/Free/N=	(1e5) Distancestmp
	Print "Calculating distances "
	StartTicks=ticks	
	variable endDo
	do						
		// this uses at least 1e5 points - and up to 1e7 points.
		// but also always limits the run to 20 seconds. Should adjust dynamically quality fo calculations for cpu and complexity of the problem. 
		multithread  Distancestmp =  IR3T_FindNextDistance(Use3DWave, IsoValue)
		concatenate/Free/NP/O {Distances, Distancestmp}, Distances
		endDo = ((ticks-StartTicks)/60 > 20 ) || (numpnts(Distances)>1e7)
	while(!endDo)
	print "Done calculating distacnes after "+num2str((ticks-StartTicks)/60)
	Histogram /NLIN=VoxDistanceWave/Dest=PDFWave Distances
	Wave PDFWave
	//Smooth/B/E=3 3, PDFWave	 //this is to smooth out the noise on the PDF due to poor sampling... Seems to do more harm than good... 
	//now we need to create radius wave... 
	//VoxDistanceWave are bin edges, returned is 1 less point in PDFWave and bin centers need to be calculated by avergaing...
	Duplicate/O PDFWave, RadiiWave
	RadiiWave = (VoxDistanceWave[p]+VoxDistanceWave[p+1])/2
	//also, add distance 0 , value 0. 
	InsertPoints 0, 1, RadiiWave, PDFWave
	PDFWave[0]=0
	RadiiWave[0]=0
	//remove tailing 0 values from calculations. Note: leaves last 0 point in there... 
	IR3T_RemoveTailZeroes(PDFwave,RadiiWave)						//remove end 0 values, just waste to drag around and plot. 
	//Duplicate/O RadiiWave, GammaWave
	//convert from voxel units to Angstroms
	RadiiWave*=VoxelSize/oversample									//convert to real Angstrom distances
	//normalize the PDF
	variable areaPDF= areaXY(RadiiWave, PDFWave)		
	PDFWave/=areaPDF
	//this is nto needed and for now not useful. 
	//Duplicate/O PDFWave, GammaWave
	//GammaWave = PDFWave/(4*pi*RadiiWave^2)
	//GammaWave[0] = GammaWave[1]
	//variable areaGamma= areaXY(RadiiWave, GammaWave)
	//GammaWave = GammaWave/areaGamma 
	//and calculate intensity
	make/O/N=(NumQSteps)/D 	PDFIntensityWv, PDFQWv
	PDFQWv =	Qmin + p*(Qmax-Qmin)/(NumQSteps-1)  
	IN2G_ConvertTologspacing(PDFQWv,0)									//creates log-q spacing in the PDFQWv
	multithread PDFIntensityWv =  IR3T_CalcIntensityPDF(PDFQWv[p],PDFWave,RadiiWave)	
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

Function  IR3T_RemoveTailZeroes(PDFwave,RadiusWave)
	wave PDFwave,RadiusWave
	variable i=numpnts(PDFwave)-1
	Do
		DeletePoints i, 1, PDFwave,RadiusWave
		i-=1
	 while(PDFwave[i-1]<1e-15)
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
threadsafe Function IR3T_FindNextDistance(ThreeDVoxelGram, IsoValue)
	wave ThreeDVoxelGram
	variable IsoValue
	
	variable distance
	variable p1, p2, q1, q2, r1, r2
	variable i, imax=10000
	variable BoxSizeP=DimSize(ThreeDVoxelGram, 0 )
	variable BoxSizeQ=DimSize(ThreeDVoxelGram, 1 )
	variable BoxSizeR=DimSize(ThreeDVoxelGram, 2 )
	For(i=0;i<imax;i+=1)
		p1 = trunc(abs(enoise(1))*BoxSizeP - 1e-9)
		p2 = trunc(abs(enoise(1))*BoxSizeP - 1e-9)
		q1 = trunc(abs(enoise(1))*BoxSizeQ - 1e-9)
		q2 = trunc(abs(enoise(1))*BoxSizeQ - 1e-9)
		r1 = trunc(abs(enoise(1))*BoxSizeR - 1e-9)
		r2 = trunc(abs(enoise(1))*BoxSizeR - 1e-9)
		if(ThreeDVoxelGram[p1][q1][r1]>(0.99*IsoValue) && ThreeDVoxelGram[p2][q2][r2]>(0.99*IsoValue))		//both are in phase which is declared by > IsoValue...
			distance = sqrt((p1-p2)^2+(q1-q2)^2+(r1-r2)^2)								//this should be distance in pixels between two ends of this line
			if(distance>0)
				return distance
			endif
		endif
	endfor
	return 0
	
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
////threadsafe
//threadsafe Function IR3T_CalcIntensityGamma(Qvalue,GammaVal,Radius)		//Glatter-Kraky book, page 27, formula 29
//	variable Qvalue
//	wave GammaVal,Radius	
//	Make/Free/N=(numpnts(GammaVal))/D QRWave
//	QRWave=sinc(Qvalue*Radius[p])			//(sin(Qvec[p]*Radius))/(Qvec[p]*Radius)		
//	matrixOP/Nthr=0/Free tempWave = powR(Radius, 2) * GammaVal * QRWave
//	return 4*pi*areaXY(Radius, TempWave)
//end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//threadsafe
threadsafe Function IR3T_CalcIntensityPDF(Qvalue,PDF,Radius)		//AMemiys - my theory powerpoint
	variable Qvalue
	wave PDF,Radius	
	Make/Free/N=(numpnts(PDF))/D QRWave
	QRWave=sinc(Qvalue*Radius[p])								//(sin(Qvec[p]*Radius))/(Qvec[p]*Radius)		
	matrixOP/Nthr=0/Free tempWave = PDF * QRWave
	variable AreaW = areaXY(Radius, TempWave)
	return (4*pi*(areaXY(Radius, TempWave)))
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

//			Below is support for 3D Aggreage conversion to intensity. 
//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************
//this function converts list 3d wave (aggregate) into voxelgram.
//Voxelgram is 10x larger than the input space of the aggregate (given by max size of the aggregate). 
//primary radius is size of spehere which is used to fill the "primary particle size". Since the 10x oversamnples
//a good primary radius is 5. In this case nearest neighbor particles are touching. It could be slightly larger, may be 6 or even 7.
//creates denser structure.  
Function IR3T_ConvertToVoxelGram(ListWv, primaryradius)
	wave ListWv
	variable primaryradius
	
	if(primaryradius<2 || primaryradius>20)
		Abort "primaryradius parameter passed to IR3T_ConvertToVoxelGram makes no sense." 
	endif
	//get max size needed... 
	WaveStats/Q ListWv
	variable MaxSize=max(V_max, abs(V_min))
	MaxSize = 2 * (MaxSize+1)*10							//10x larger to oversample, add layer on each side so we do not run out of box...
	variable CenterOffset=MaxSize/2
	Make/Free/N=(MaxSize,MaxSize,MaxSize)/U/B VoxelGram
	//Ok,now fill it up.
	variable i
	For(i=0;i<DimSize(ListWv,0);i+=1)
			//fill centers of each point here with 1
			//ListWv[i][0] is one coordinate, ListWv[i][1] second, ListWv[i][2] third, we need to offset them by half of the box CenterOffset
			VoxelGram[CenterOffset+10*ListWv[i][0]][CenterOffset+10*ListWv[i][1]][CenterOffset+10*ListWv[i][2]] = 1
	endfor
	IR3T_CreateSpheresStructure(VoxelGram,primaryradius, 0.5)
	Wave Wave3DwithPrimary			//this is result produced by above code... 
end
//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************
Function IR3T_FindNearestPrimeSize(ValueIn)
	variable ValueIn
	
	make/N=12/Free PrimeList2,PrimeList3
	PrimeList2 = 2^p
	PrimeList3 = 3^p
	Concatenate /FREE/NP {PrimeList2,PrimeList3}, PrimeList
	sort PrimeList, PrimeList
	variable index
	index = BinarySearch(PrimeList, ValueIn )
	return PrimeList[index+1]
end
//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************

//use this - this is much better:
//this function convolutes sparsely filled 3D space from ConvertToVoxelGram with sphere of size (discussed above).
//this results in voxelgram which looks like filled with touching sheres. Needed to calcualte PDF
//this would be great to make more multicore, but somehow it did not work... 
Function IR3T_CreateSpheresStructure(Wave3DIn,sphereRadius, level)
		wave Wave3DIn
		variable sphereRadius, level
		//level is level above which the material is a phase (solid)
	//in order to make this faster we need to pad this to dimensions which are power of 2 or power of 3, helps fft internally (per AG from WM)
	//hm, this padding does not seem to help for smallish cases... Heps a lot in larger cases, I have seen factor of 3x faster operations... 
	print "Creating Voxelgram, creating spherical structure"
	variable StartTicks=ticks
	Duplicate/Free Wave3DIn, WaveToWorkOn
	variable PadSphere=2*round(0.5 + sphereRadius/2)
	variable newDimP, newDimQ, newDimR
	newDimP = 2*round(0.5+(DimSize(WaveToWorkOn,0)+PadSphere)/2)
	newDimQ = 2*round(0.5+(DimSize(WaveToWorkOn,1)+PadSphere)/2)
	newDimR = 2*round(0.5+(DimSize(WaveToWorkOn,2)+PadSphere)/2)
	if(newDimP>50 || newDimQ>50 || newDimR>50)
		newDimP = IR3T_FindNearestPrimeSize(newDimP)
		newDimQ = IR3T_FindNearestPrimeSize(newDimQ)
		newDimR = IR3T_FindNearestPrimeSize(newDimR)
	endif
	redimension/N=(newDimP, newDimQ,newDimR)/S WaveToWorkOn			//make larger so we do not run out after fft/ifft (which shifts data by size of the sphere...
	make/FREE/N=(dimsize(WaveToWorkOn,0),dimsize(WaveToWorkOn,1),dimsize(WaveToWorkOn,2)) Sphere
	//alternative for sharp sphere is 
	//sphere = Gauss(x,2*sphereRadius+2,sphereRadius/sqrt(2),y,2*sphereRadius+2,sphereRadius/sqrt(2),z,2*sphereRadius+2,sphereRadius/sqrt(2))
	//this is sharp sphere... 
	sphere[0,ceil(2*sphereRadius+2)][0,ceil(2*sphereRadius+2)][0,ceil(2*sphereRadius+2)]=(sqrt((p-sphereRadius)^2+(q-sphereRadius)^2+(r-sphereRadius)^2)<sphereRadius) ? 1 : 0
	fft/DEST=sphereFFT/Free sphere
	fft/DEST=Wave3DInFFT/Free WaveToWorkOn
	//MatrixOp/FREE/NTHR=0 sphereFFT=fft(sphere,0)					//does not work - MatrixOp does 2D ffts, not 3d FFT, so here it works layer-by-layer 
	MatrixOp/FREE/NTHR=0 MultipliedFFT = Wave3DInFFT * sphereFFT
	IFFT/Dest=Wave3DOutIFFT/Free MultipliedFFT
	//this depends on what is used for convolution. If sharp sphere, this is what you need... thresholds are  much smaller for gauss... 
	MatrixOp/O/NTHR=0 Wave3DwithPrimary = greater(Wave3DOutIFFT,level)
	//and now shrink the box as small as possible. Note, it crashes Igor before 8.03 release...
	if(NumberByKey("IGORVERS", IgorInfo(0))>8.02)			//there was bug in Igor 8.02 and before, this would crash Igor... 
		ImageTransform/F=0 shrinkBox Wave3DwithPrimary
		Wave M_shrunkCube
		Duplicate/O M_shrunkCube, Wave3DwithPrimary
	endif
	print "Done with creating Voxelgram spherical structure in :"+num2str((ticks-startTicks)/60)
end

//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************
//**************************************************************************************************************************************************************

