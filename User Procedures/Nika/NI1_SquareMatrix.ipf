#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method.
//#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.05

//*************************************************************************\
//* Copyright (c) 2005 - 2023, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.05 fixes for ImageLineProfile which seems to produce sometimes points at non expected location. This is actually documented feature.  
//1.04 fixed /NTHR=1 to  
//1.03 fixed masking which was failing due to bug. 
//1.02 added mutlithread and MatrixOp/NTHR=1 where seemed possible to use multile cores
//1.01 added license for ANL

Function NI1_MakeSectorGraph(withTilts)
	variable withTilts

	string OdlDf=GetDataFolder(1)
	SetDataFolder root:Packages:Convert2Dto1D
	NVAR SectorsNumSect=root:Packages:Convert2Dto1D:SectorsNumSect
	NVAR SectorsSectWidth=root:Packages:Convert2Dto1D:SectorsSectWidth
	NVAR SectorsGraphEndAngle= root:Packages:Convert2Dto1D:SectorsGraphEndAngle
	NVAR SectorsGraphStartAngle= root:Packages:Convert2Dto1D:SectorsGraphStartAngle
	NVAR ImageDisplayLogScaled=root:Packages:Convert2Dto1D:ImageDisplayLogScaled
	NVAR A2DLineoutDisplayLogInt=root:Packages:Convert2Dto1D:A2DLineoutDisplayLogInt
	A2DLineoutDisplayLogInt=ImageDisplayLogScaled				//set to same scaling as user has for the image file
	NVAR SectorsUseRAWData=root:Packages:Convert2Dto1D:SectorsUseRAWData
	NVAR SectorsUseCorrData=root:Packages:Convert2Dto1D:SectorsUseCorrData
	if(SectorsUseCorrData)
		NI1A_CorrectDataPerUserReq("")								//calibrate data
	endif
	if(withTilts)
		NI1_MakeSqMtxOfLinswtilts(SectorsNumSect,SectorsSectWidth,SectorsGraphStartAngle,SectorsGraphEndAngle)	
	else
		NI1_MakeSqMatrixOfLineouts(SectorsNumSect,SectorsSectWidth,SectorsGraphStartAngle,SectorsGraphEndAngle)		//convert to lineout
	endif
	wave SquareMap=root:Packages:Convert2Dto1D:SquareMap
	//duplicate/O SquareMap, SquareMap_dis
	NVAR A2DImageRangeMinLimit=root:Packages:Convert2Dto1D:A2DImageRangeMinLimit
	NVAR A2DImageRangeMaxLimit=root:Packages:Convert2Dto1D:A2DImageRangeMaxLimit
	NVAR A2DImageRangeMin=root:Packages:Convert2Dto1D:A2DImageRangeMin
	NVAR A2DImageRangeMax=root:Packages:Convert2Dto1D:A2DImageRangeMax
	
	Duplicate/O SquareMap, SquareMap_dis
	if(A2DLineoutDisplayLogInt)
		MatrixOP/O  SquareMap_dis=log(SquareMap)
	else
		MatrixOP/O  SquareMap_dis=SquareMap
	endif
	
	wavestats/Q   SquareMap_dis
	A2DImageRangeMinLimit=V_min
	A2DImageRangeMin=V_min
	A2DImageRangeMaxLimit=V_max
	A2DImageRangeMax=V_max
	
	DoWindow SquareMapIntvsPixels
	if(!V_Flag)
		Execute("NI1_SquareGraph()")
	else
		DoWindow/F SquareMapIntvsPixels
	endif
//	NVAR SectorsGraphStartAngle=root:Packages:Convert2Dto1D:SectorsGraphStartAngle
//	NVAR SectorsGraphEndAngle=root:Packages:Convert2Dto1D:SectorsGraphEndAngle
//	SetAxis/W=SquareMapIntvsPixels left SectorsGraphStartAngle,SectorsGraphEndAngle	

end
//********************************************************************
//********************************************************************
//********************************************************************
//********************************************************************
//********************************************************************

Function NI1_MakeSqMatrixOfLineouts(SectorsNumSect,AngleWidth,SectorsGraphStartAngle,SectorsGraphEndAngle)
	variable SectorsNumSect,AngleWidth,SectorsGraphStartAngle,SectorsGraphEndAngle
	//Create matrix of lineouts using the ImageLineProfile function
	//will have to be finished, for now it is simple method... 
	string OdlDf=GetDataFolder(1)
	SetDataFolder root:Packages:Convert2Dto1D
	variable AngleStep = (SectorsGraphEndAngle-SectorsGraphStartAngle)/SectorsNumSect
	
	NVAR SectorsUseRAWData=root:Packages:Convert2Dto1D:SectorsUseRAWData
	NVAR SectorsUseCorrData=root:Packages:Convert2Dto1D:SectorsUseCorrData
	if(SectorsUseRAWData)
		Wave CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
	else
		Wave CCDImageToConvert=root:Packages:Convert2Dto1D:Calibrated2DDataSet
	endif
	string OriginalNote=note(CCDImageToConvert)
	string NewNote, MaskSquareImageNote
	Wave/Z Mask=root:Packages:Convert2Dto1D:M_ROIMask
	Wave/Z MaskSquareImage
	if(WaveExists(MaskSquareImage))
		MaskSquareImageNote=note(MaskSquareImage)
	else
		MaskSquareImageNote=""
	endif
	NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
	NVAR A2DmaskImage=root:Packages:Convert2Dto1D:A2DmaskImage
	SVAR CurrentMaskFileName=root:Packages:Convert2Dto1D:CurrentMaskFileName
	NewNote = OriginalNote
	NewNote+="BeamCenterX="+num2str(BeamCenterX)+";"
	NewNote+="BeamCenterY="+num2str(BeamCenterY)+";"
	NewNote+="CurrentMaskFileName="+CurrentMaskFileName+";"
	NewNote+="SectorsNumSect="+num2str(SectorsNumSect)+";"
	NewNote+="AngleWidth="+num2str(AngleWidth)+";"
	NewNote+="SectorsGraphStartAngle="+num2str(SectorsGraphStartAngle)+";"
	NewNote+="SectorsGraphEndAngle="+num2str(SectorsGraphEndAngle)+";"
	//for now work in pixles...
	//find maximum distance from center to corners
	variable dist00=sqrt(BeamCenterX^2 + BeamCenterY^2)
	variable dist0Max = sqrt(BeamCenterX^2 + (BeamCenterY - dimSize(CCDImageToConvert,1)) ^2) 
	variable distMax0 = sqrt((BeamCenterX - dimSize(CCDImageToConvert,0))^2 + BeamCenterY ^2) 
	variable distMaxMax = sqrt((BeamCenterX - dimSize(CCDImageToConvert,0))^2 + (BeamCenterY - dimSize(CCDImageToConvert,1)) ^2) 
	//if the beam center is outside the image, we need more work...
	variable distMax3
	if((BeamCenterX>dimSize(CCDImageToConvert,0))||BeamCenterY>dimSize(CCDImageToConvert,1))
		distMax3=sqrt(BeamCenterX^2+BeamCenterY^2)
	endif
	if(BeamCenterX<0||BeamCenterY<0)
		distMax3=sqrt((dimSize(CCDImageToConvert,0)-BeamCenterX)^2+(dimSize(CCDImageToConvert,1)-BeamCenterY)^2)
	endif
	variable distMaxOutside
	variable MaxDist = floor(max(max(max(dist00,dist0Max),max(distMax0,distMaxMax )),distMax3))	//max number of pixles from the beam center to end
	
	variable RecalculateMask=0
	if(A2DmaskImage)
		variable oldBeamCenterX=NumberByKey("BeamCenterX",MaskSquareImageNote,"=")
		variable oldBeamCenterY=NumberByKey("BeamCenterY",MaskSquareImageNote,"=")
		string oldCurrentMaskFileName=StringByKey("CurrentMaskFileName",MaskSquareImageNote,"=")
		variable oldSectorsNumSect=NumberByKey("SectorsNumSect",MaskSquareImageNote,"=")
		variable oldAngleWidth=NumberByKey("AngleWidth",MaskSquareImageNote,"=")
		variable oldSectorsGraphStartAngle=NumberByKey("SectorsGraphStartAngle",MaskSquareImageNote,"=")
		variable oldSectorsGraphEndAngle=NumberByKey("SectorsGraphEndAngle",MaskSquareImageNote,"=")
		
		variable diff1 = ((abs(oldBeamCenterX-BeamCenterX)>0.1) || (abs(oldBeamCenterY-BeamCenterY)>0.1) || cmpstr(oldCurrentMaskFileName,CurrentMaskFileName)!=0)
		variable diff2 = (oldSectorsNumSect!=SectorsNumSect || oldAngleWidth!=AngleWidth || oldSectorsGraphStartAngle!=SectorsGraphStartAngle || oldSectorsGraphEndAngle!=SectorsGraphEndAngle) 
		if( diff1 || diff2)
			RecalculateMask=1
			print "recalculate Square Mask also"
			Duplicate/O Mask, MaskS
			Redimension/S MaskS
			Make/O/N=(MaxDist,SectorsNumSect) MaskSquareImage
		endif
	endif
	Duplicate/O CCDImageToConvert, MaskedImage	//working waves
	Redimension/S MaskedImage					//to use NaN as masked point, this has to be single precision
	Make/O/N=(MaxDist,SectorsNumSect) SquareMap			//create angle vs point number squared intensity wave
	SquareMap = NaN
	Make/O/N=(MaxDist) PixelAddressesX, PixelAddressesY, PathWidth, PathWidthTemp	//create addresses and width for path around which to get profile 
	PathWidth = 2* p * tan(AngleWidth*(pi/180))		//create the path profile width - same for all sectors

	variable ang, indx, i
	variable NumPntsXS,NumPntsXE, NumPntsYS,NumPntsYE, tempVal
	indx = SectorsNumSect
	ang = SectorsGraphStartAngle
	For(i=0;i<SectorsNumSect;i+=1)			//evaluate the sectors
		Redimension/N=(MaxDist) PathWidthTemp, PixelAddressesY, PixelAddressesX
		PixelAddressesX=BeamCenterX + p * cos((SectorsGraphStartAngle+(i*AngleStep))*(pi/180))		//calculate the path, this is now in "pixles", assumes same
		PixelAddressesY=BeamCenterY - p * sin((SectorsGraphStartAngle+(i*AngleStep))*(pi/180))		// pixel size in both directions
		PathWidthTemp = PathWidth
		ImageLineProfile xWave=PixelAddressesX, yWave=PixelAddressesY, srcwave=MaskedImage , widthWave=PathWidthTemp
		Wave W_ImageLineProfile
		//this is collected at points: W_LineProfileX and W_LineProfileY, scaled distance measured along the path is stored in the wave W_LineProfileDisplacement
		// W_LineProfileDisplacement is needed for placing the points correctly... 
		Wave W_LineProfileDisplacement
		Redimension /N=(MaxDist) W_ImageLineProfile		//fix for rtGlobals=3
		//this was failing sometimes because in some cases ImageLineProfile generates points at different distcances than expected. 
		// we need to assign intensities to proper distances... 
		//so this does not work sometimes: 		SquareMap[][i] = W_ImageLineProfile[p]
		//limited range below is needed to avoid bombing on index out of range... First few and last points are rarely needed,
		//code needed to fix this would be ugly and slow. 
		multithread SquareMap[2,MaxDist-10][i] = W_ImageLineProfile[BinarySearchInterp(W_LineProfileDisplacement,p)]
		if(recalculateMask)
			ImageLineProfile xWave=PixelAddressesX, yWave=PixelAddressesY, srcwave=MaskS , widthWave=PathWidthTemp
			Wave W_ImageLineProfile
			Wave W_LineProfileDisplacement
			W_ImageLineProfile = W_ImageLineProfile[p]>0.9999 ? W_ImageLineProfile[p] : NaN
 			//Redimension /N=(MaxDist) W_ImageLineProfile
			//W_ImageLineProfile[tempVal,inf ] = NaN
			//MaskSquareImage[][i] = W_ImageLineProfile[p]
			MaskSquareImage[2,MaxDist-10][i] = W_ImageLineProfile[BinarySearchInterp(W_LineProfileDisplacement,p)]
		endif
	endfor	
	Note SquareMap, NewNote
	if(recalculateMask)
		Note MaskSquareImage, NewNote
	endif
	if(A2DmaskImage)
		MatrixOP/O  SquareMap=SquareMap*(MaskSquareImage/MaskSquareImage)
	endif
	SetScale/P y SectorsGraphStartAngle,AngleStep,"", SquareMap
	KillWaves/Z MaskedImage
	KillWaves/Z MaskS
	KillWIndow/Z SquareMapIntvsPixels
 	//comment
	// In order to convert the data next into Int vs Q scale, we need to produce also Q scale which would map pixels into Q, this is 
	//function of geometry...
	// also we need to propage somehow errors through. This can be done here, but it is unclear to me how to easily propaget it further.
	
end

//********************************************************************
//********************************************************************
//********************************************************************

//josh add with tilts
Function NI1_MakeSqMtxOfLinswtilts(SectorsNumSect,AngleWidth,SectorsGraphStartAngle,SectorsGraphEndAngle)
//strategy:  this function will return a squaremap just like the original, but with row points that each correspond to
//a specific q-bin. To do this, the q2dwave is used (and must have been already created) to make squaremap with q-points. 
//looking at how it is created, the tilts are incorporated into the calculation.
//from there, it is just a matter of putting each point in the square map in the right qbin, which is determined from q2dwave.
//this is slow and stupid, but should be easy to verify.
	variable SectorsNumSect,AngleWidth,SectorsGraphStartAngle,SectorsGraphEndAngle
	//Create matrix of lineouts using the ImageLineProfile function
	//will have to be finished, for now it is simple method... 
	string OdlDf=GetDataFolder(1)
	SetDataFolder root:Packages:Convert2Dto1D
	variable AngleStep = (SectorsGraphEndAngle-SectorsGraphStartAngle)/SectorsNumSect
	wave Q2Dwave = root:Packages:Convert2Dto1D:Q2Dwave
	NVAR SectorsUseRAWData=root:Packages:Convert2Dto1D:SectorsUseRAWData
	NVAR SectorsUseCorrData=root:Packages:Convert2Dto1D:SectorsUseCorrData
	if(SectorsUseRAWData)
		Wave CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert
	else
		Wave CCDImageToConvert=root:Packages:Convert2Dto1D:Calibrated2DDataSet
	endif
	string OriginalNote=note(CCDImageToConvert)
	string NewNote, MaskSquareImageNote
	Wave/Z Mask=root:Packages:Convert2Dto1D:M_ROIMask
	Wave/Z MaskSquareImage
	if(WaveExists(MaskSquareImage))
		MaskSquareImageNote=note(MaskSquareImage)
	else
		MaskSquareImageNote=""
	endif
	NVAR BeamCenterX=root:Packages:Convert2Dto1D:BeamCenterX
	NVAR BeamCenterY=root:Packages:Convert2Dto1D:BeamCenterY
	NVAR A2DmaskImage=root:Packages:Convert2Dto1D:A2DmaskImage
	SVAR CurrentMaskFileName=root:Packages:Convert2Dto1D:CurrentMaskFileName
	NewNote = OriginalNote
	NewNote+="BeamCenterX="+num2str(BeamCenterX)+";"
	NewNote+="BeamCenterY="+num2str(BeamCenterY)+";"
	NewNote+="CurrentMaskFileName="+CurrentMaskFileName+";"
	NewNote+="SectorsNumSect="+num2str(SectorsNumSect)+";"
	NewNote+="AngleWidth="+num2str(AngleWidth)+";"
	NewNote+="SectorsGraphStartAngle="+num2str(SectorsGraphStartAngle)+";"
	NewNote+="SectorsGraphEndAngle="+num2str(SectorsGraphEndAngle)+";"
	//for now work in pixles...
	//find maximum distance from center to corners
	variable dist00=sqrt(BeamCenterX^2 + BeamCenterY^2)
	variable dist0Max = sqrt(BeamCenterX^2 + (BeamCenterY - dimSize(CCDImageToConvert,1)) ^2) 
	variable distMax0 = sqrt((BeamCenterX - dimSize(CCDImageToConvert,0))^2 + BeamCenterY ^2) 
	variable distMaxMax = sqrt((BeamCenterX - dimSize(CCDImageToConvert,0))^2 + (BeamCenterY - dimSize(CCDImageToConvert,1)) ^2) 
	//if the beam center is outside the image, we need more work...
	variable distMax3
	if((BeamCenterX>dimSize(CCDImageToConvert,0))||BeamCenterY>dimSize(CCDImageToConvert,1))
		distMax3=sqrt(BeamCenterX^2+BeamCenterY^2)
	endif
	if(BeamCenterX<0||BeamCenterY<0)
		distMax3=sqrt((dimSize(CCDImageToConvert,0)-BeamCenterX)^2+(dimSize(CCDImageToConvert,1)-BeamCenterY)^2)
	endif
	variable distMaxOutside
	variable MaxDist = floor(max(max(max(dist00,dist0Max),max(distMax0,distMaxMax )),distMax3))	//max number of pixles from the beam center to end
	
	variable RecalculateMask=0
	if(A2DmaskImage)
		variable oldBeamCenterX=NumberByKey("BeamCenterX",MaskSquareImageNote,"=")
		variable oldBeamCenterY=NumberByKey("BeamCenterY",MaskSquareImageNote,"=")
		string oldCurrentMaskFileName=StringByKey("CurrentMaskFileName",MaskSquareImageNote,"=")
		variable oldSectorsNumSect=NumberByKey("SectorsNumSect",MaskSquareImageNote,"=")
		variable oldAngleWidth=NumberByKey("AngleWidth",MaskSquareImageNote,"=")
		variable oldSectorsGraphStartAngle=NumberByKey("SectorsGraphStartAngle",MaskSquareImageNote,"=")
		variable oldSectorsGraphEndAngle=NumberByKey("SectorsGraphEndAngle",MaskSquareImageNote,"=")
		
		variable diff1 = ((abs(oldBeamCenterX-BeamCenterX)>0.1) || (abs(oldBeamCenterY-BeamCenterY)>0.1) || cmpstr(oldCurrentMaskFileName,CurrentMaskFileName)!=0)
		variable diff2 = (oldSectorsNumSect!=SectorsNumSect || oldAngleWidth!=AngleWidth || oldSectorsGraphStartAngle!=SectorsGraphStartAngle || oldSectorsGraphEndAngle!=SectorsGraphEndAngle) 
		if( diff1 || diff2)
			RecalculateMask=1
			print "recalculate Square Mask also"
			Duplicate/O Mask, MaskS
			Redimension/S MaskS
			Make/O/N=(MaxDist,SectorsNumSect) MaskSquareImage
		endif
	endif
	Duplicate/O CCDImageToConvert, MaskedImage	//working waves
	Redimension/S MaskedImage					//to use NaN as masked point, this has to be single precision
	Make/O/N=(MaxDist,SectorsNumSect) SquareMap,Qbin4SquareMap,SquareMap4Qbin			//create angle vs point number squared intensity wave
	SquareMap = NaN
	Make/O/N=(MaxDist) PixelAddressesX, PixelAddressesY, PathWidth, PathWidthTemp	//create addresses and width for path around which to get profile 
	PathWidth = 2* p * tan(AngleWidth*(pi/180))		//create the path profile width - same for all sectors

	variable ang, indx, i
	variable NumPntsXS,NumPntsXE, NumPntsYS,NumPntsYE, tempVal
	indx = SectorsNumSect
	ang = SectorsGraphStartAngle
	For(i=0;i<SectorsNumSect;i+=1)			//evaluate the sectors
		Redimension/N=(MaxDist) PathWidthTemp, PixelAddressesY, PixelAddressesX
		PixelAddressesX=BeamCenterX + p * cos((SectorsGraphStartAngle+(i*AngleStep))*(pi/180))		//calculate the path, this is now in "pixles", assumes same
		PixelAddressesY=BeamCenterY - p * sin((SectorsGraphStartAngle+(i*AngleStep))*(pi/180))		// pixel size in both directions
		PathWidthTemp = PathWidth
		ImageLineProfile xWave=PixelAddressesX, yWave=PixelAddressesY, srcwave=MaskedImage , widthWave=PathWidthTemp
		Wave W_ImageLineProfile
		//this is collected at points: W_LineProfileX and W_LineProfileY, scaled distance measured along the path is stored in the wave W_LineProfileDisplacement
		// W_LineProfileDisplacement is needed for placing the points correctly... 
		Wave W_LineProfileDisplacement
		Wave W_LineProfileX
		Wave W_LineProfileY
		Redimension /N=(MaxDist) W_ImageLineProfile, W_LineProfileY, W_LineProfileX		//fix for rtGlobals=3
		//this failed because in some cases ImageLineProfile generates points at different distcances than expected. 
		// we need to assign intnesities to proper distances... 
		//SquareMap[][i] = W_ImageLineProfile[p]
		//limited range below is needed to avoid bombing on index out of range... 
		SquareMap[2,MaxDist-10][i] = W_ImageLineProfile[BinarySearchInterp(W_LineProfileDisplacement,p)]
		//SquareMap[][i] = W_ImageLineProfile[p]
		//josh add:  make an analogous qmap wave
		STRUCT NikadetectorGeometry d
		NVAR Wavelength = root:Packages:Convert2Dto1D:Wavelength	
		NI2T_ReadOrientationFromGlobals(d)
		NI2T_SaveStructure(d)
		multithread Qbin4SquareMap[][i] = ((4*pi)/Wavelength)*sin(NI2T_pixelTheta(d,PixelAddressesX[p],PixelAddressesY[p]))
		//josh done
		if(recalculateMask)
			ImageLineProfile xWave=PixelAddressesX, yWave=PixelAddressesY, srcwave=MaskS , widthWave=PathWidthTemp
			Wave W_ImageLineProfile
			Wave W_LineProfileDisplacement
			W_ImageLineProfile = W_ImageLineProfile[p]>0.9999 ? W_ImageLineProfile[p] : NaN
			Redimension /N=(MaxDist) W_ImageLineProfile		//fix for rtGlobals=3
 			//Redimension /N=(MaxDist) W_ImageLineProfile
			//W_ImageLineProfile[tempVal,inf ] = NaN
			//MaskSquareImage[][i] = W_ImageLineProfile[p]
			MaskSquareImage[2,MaxDist-10][i] = W_ImageLineProfile[BinarySearchInterp(W_LineProfileDisplacement,p)]
		endif
	endfor	
	
	
	Note SquareMap, NewNote
	if(recalculateMask)
		Note MaskSquareImage, NewNote
	endif
	if(A2DmaskImage)
		MatrixOP/O  SquareMap=SquareMap*(MaskSquareImage/MaskSquareImage)
	endif
	SetScale/P y SectorsGraphStartAngle,AngleStep,"", SquareMap
	//josh add:  now create square map for q points and not pixels
	duplicate/o SquareMap,Squaremap4Q
	//the minimum q and maximum q are defined by the maximum of the first column and the minium of the last column
	duplicate/free/r=(0,inf)(0) Qbin4SquareMap,qtempmin
	duplicate/free/r=(0,inf)(dimsize(Qbin4SquareMap,1)-1) Qbin4SquareMap,qtempmax
	setscale/I x wavemax(qtempmin),wavemin(qtempmax),"q",Squaremap4Q
	//now iterate through each azimuthal angle on the raw image
	For(i=0;i<SectorsNumSect;i+=1)	
		duplicate/free/r=(0,inf)(i) Qbin4SquareMap,qtemp
		duplicate/free/r=(0,inf)(i) SquareMap,rtemp
		redimension/n=(dimsize(Qbin4SquareMap,0)) qtemp,rtemp
		Squaremap4Q[][i] = interp(x,qtemp,rtemp)//this seems somewhat dubious because i am interpolating values instead of using the actual q-values of each pixel
	endfor
	
	
	KillWaves/Z MaskedImage
	KillWaves/Z MaskS
	KillWIndow/Z SquareMapIntvsPixels
 	//comment
	// In order to convert the data next into Int vs Q scale, we need to produce also Q scale which would map pixels into Q, this is 
	//function of geometry...
	// also we need to propage somehow errors through. This can be done here, but it is unclear to me how to easily propaget it further.
	
end
//end josh add



//********************************************************************
//********************************************************************
//********************************************************************


Function NI1_SquareGraph() : Graph

	Wave SquareMap_dis=root:Packages:Convert2Dto1D:SquareMap_dis
	NVAR A2DImageRangeMinLimit=root:Packages:Convert2Dto1D:A2DImageRangeMinLimit
	NVAR A2DImageRangeMaxLimit=root:Packages:Convert2Dto1D:A2DImageRangeMaxLimit
	PauseUpdate    		// building window...
	Display /W=(191.25,169.25,705,562.25)/K=1; AppendImage SquareMap_dis
	DoWindow/C/T SquareMapIntvsPixels,"SquareMap of intensity vs pixel"
	ControlBar 40
	CheckBox DisplayLogLineout,pos={10,8},size={90,14},proc=NI1A_SquareCheckProc,title="Log Int?"
	CheckBox DisplayLogLineout,help={"Display 2D map oflineouts in log units?"}
	CheckBox DisplayLogLineout,variable= root:Packages:Convert2Dto1D:A2DLineoutDisplayLogInt
	Slider ImageRangeMinSquare,pos={100,4},size={150,16},proc=NI1A_MainSliderProc,variable= root:Packages:Convert2Dto1D:A2DImageRangeMin,live= 0,side= 2,vert= 0,ticks= 0
	Slider ImageRangeMinSquare,limits={A2DImageRangeMinLimit,A2DImageRangeMaxLimit,0}
	Slider ImageRangeMaxSquare,pos={100,20},size={150,16},proc=NI1A_MainSliderProc,variable= root:Packages:Convert2Dto1D:A2DImageRangeMax,live= 0,side= 2,vert= 0,ticks= 0
	Slider ImageRangeMaxSquare,limits={A2DImageRangeMinLimit,A2DImageRangeMaxLimit,0}
//
	ModifyImage SquareMap_dis ctab= {*,*,Terrain,0}
	ModifyGraph margin(left)=38,margin(bottom)=25,margin(top)=14,margin(right)=14
	ModifyGraph mirror=2
	ModifyGraph nticks(left)=10
	ModifyGraph minor=1
	ModifyGraph fSize=8
	ModifyGraph standoff=0
	ModifyGraph tkLblRot(left)=90
	ModifyGraph btLen=3
	ModifyGraph tlOffset=-2
//	ModifyGraph swapXY=1
	ModifyGraph mirror(left)=1
	Label bottom "Pixels from beam center"
	Label left "Azimuthal angle [degrees]"
	NVAR SectorsGraphStartAngle=root:Packages:Convert2Dto1D:SectorsGraphStartAngle
	NVAR SectorsGraphEndAngle=root:Packages:Convert2Dto1D:SectorsGraphEndAngle
	SetAxis left SectorsGraphStartAngle,SectorsGraphEndAngle	
EndMacro

Function NI1A_SquareCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

	if(cmpstr("DisplayLogLineout",ctrlName)==0)
		Wave SquareMap_dis=root:Packages:Convert2Dto1D:SquareMap_dis
		Wave SquareMap=root:Packages:Convert2Dto1D:SquareMap
		NVAR A2DLineoutDisplayLogInt=root:Packages:Convert2Dto1D:A2DLineoutDisplayLogInt
	
		if(A2DLineoutDisplayLogInt)
			SquareMap_dis=log(SquareMap)
		else
			SquareMap_dis=SquareMap
		endif
		NVAR A2DImageRangeMinLimit=root:Packages:Convert2Dto1D:A2DImageRangeMinLimit
		NVAR A2DImageRangeMaxLimit=root:Packages:Convert2Dto1D:A2DImageRangeMaxLimit
		NVAR A2DImageRangeMin=root:Packages:Convert2Dto1D:A2DImageRangeMin
		NVAR A2DImageRangeMax=root:Packages:Convert2Dto1D:A2DImageRangeMax
		
		wavestats/Q   SquareMap_dis
		A2DImageRangeMinLimit=V_min
		A2DImageRangeMin=V_min
		A2DImageRangeMaxLimit=V_max
		A2DImageRangeMax=V_max
		DoWindow SquareMapIntvsPixels
		if(!V_Flag)
			Execute ("NI1_SquareGraph()")
		else
			DoWindow/F SquareMapIntvsPixels
		endif	
		Slider ImageRangeMinSquare,win=SquareMapIntvsPixels,variable= root:Packages:Convert2Dto1D:A2DImageRangeMin,live= 0,side= 2,vert= 0,ticks= 0
		Slider ImageRangeMinSquare,limits={A2DImageRangeMinLimit,A2DImageRangeMaxLimit,0}
		Slider ImageRangeMaxSquare,win=SquareMapIntvsPixels,variable= root:Packages:Convert2Dto1D:A2DImageRangeMax,live= 0,side= 2,vert= 0,ticks= 0
		Slider ImageRangeMaxSquare,limits={A2DImageRangeMinLimit,A2DImageRangeMaxLimit,0}
	endif
	
	
end

Function NI1_SquareButtonProc(ctrlName) : ButtonControl
	String ctrlName
	
	
	if(cmpstr(ctrlName,"SaveCurrentLineout")==0)
		Wave profile=root:Packages:NI1_ImProcess:LineProfile:profile
		
		string OldDf=GetDataFolder(1)
		string NewFldrName
		//DoAlert 0, "Need to finish NI1_SquareButtonProc procedure in NI1_SquareMatrix.ipf" 
		//need to convert data into Int vs Q and then save data somewhere...
		SVAR FileNameToLoad=root:Packages:Convert2Dto1D:FileNameToLoad
		NVAR DisplayPixles=root:Packages:NI1_ImProcess:LineProfile:DisplayPixles
		NVAR DisplayQvec=root:Packages:NI1_ImProcess:LineProfile:DisplayQvec
		NVAR DisplaydSpacing=root:Packages:NI1_ImProcess:LineProfile:DisplaydSpacing
		NVAR DisplayTwoTheta=root:Packages:NI1_ImProcess:LineProfile:DisplayTwoTheta
		NVAR A2DLineoutDisplayLogInt=root:Packages:Convert2Dto1D:A2DLineoutDisplayLogInt
		wave profile=root:Packages:NI1_ImProcess:LineProfile:profile
		wave qvector=root:Packages:NI1_ImProcess:LineProfile:qvector
		wave TwoTheta=root:Packages:NI1_ImProcess:LineProfile:TwoTheta
		wave Dspacing=root:Packages:NI1_ImProcess:LineProfile:Dspacing
		NVAR width=root:Packages:NI1_ImProcess:LineProfile:width
		NVAR position=root:Packages:NI1_ImProcess:LineProfile:position
		NewFldrName = CleanupName(FileNameToLoad,0)[0,20] +"_"+num2str(floor(position))+"_"+num2str(floor(width))
		Prompt NewFldrName, "Input folder name for data to be stored to"
		DoPrompt "User input", NewFldrName
		if(V_Flag)
			abort
		endif
		NewFldrName=cleanupName(NewFldrName,0)
		NewDataFolder/O/S root:SAS
		if(DataFolderExists(NewFldrName))
			DoAlert 1, "The folder with data exists, ovewrite?"
			if(V_Flag==2)
				abort
			endif
		endif
		NewDataFolder/O/S $(NewFldrName)

		Duplicate/O profile, $("r_"+NewFldrName),$("s_"+NewFldrName) 
		Wave Intensity = $("r_"+NewFldrName)
		Wave Error = $("s_"+NewFldrName) 
		if(A2DLineoutDisplayLogInt)
			Intensity=10^Intensity
		endif
		Error = sqrt(Intensity)
		if(DisplayPixles)
			IN2G_RemoveNaNsFrom2Waves(Intensity,Error)
		elseif(DisplayQvec)
			Duplicate/O qvector, $("q_"+NewFldrName)
			wave QvectorN=$("q_"+NewFldrName)
			IN2G_RemoveNaNsFrom3Waves(Intensity,Error,QvectorN)
		elseif(DisplaydSpacing)
			Duplicate/O Dspacing, $("d_"+NewFldrName)
			wave DspacingN=$("d_"+NewFldrName)
			IN2G_RemoveNaNsFrom3Waves(Intensity,Error,DspacingN)
		elseif(DisplayTwoTheta)
			Duplicate/O TwoTheta, $("t_"+NewFldrName)
			wave TwoThetaN=$("t_"+NewFldrName)
			IN2G_RemoveNaNsFrom3Waves(Intensity,Error,TwoThetaN)
		endif		
		setDataFolder OldDf
		
	endif
End

Function NI1A_SQCCDImageUpdateColors(updateRanges)
	variable updateRanges
	
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D
	NVAR ImageRangeMin= root:Packages:Convert2Dto1D:A2DImageRangeMin
	NVAR ImageRangeMax = root:Packages:Convert2Dto1D:A2DImageRangeMax
	SVAR ColorTableName=root:Packages:Convert2Dto1D:ColorTableName
	NVAR ImageRangeMinLimit= root:Packages:Convert2Dto1D:A2DImageRangeMinLimit
	NVAR ImageRangeMaxLimit = root:Packages:Convert2Dto1D:A2DImageRangeMaxLimit
//	String s= ImageNameList("", ";")
//	Variable p1= StrSearch(s,";",0)
//	if( p1<0 )
//		abort			// no image in top graph
//	endif
//	s= s[0,p1-1]
	if(updateRanges)
		Wave waveToDisplayDis=root:Packages:Convert2Dto1D:SquareMap_dis
		wavestats/Q  waveToDisplayDis
		ImageRangeMin=V_min
		ImageRangeMinLimit=V_min
		ImageRangeMax=V_max
		ImageRangeMaxLimit=V_max
		Slider ImageRangeMinSquare,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}, win=SquareMapIntvsPixels
		Slider ImageRangeMaxSquare,limits={ImageRangeMinLimit,ImageRangeMaxLimit,0}, win=SquareMapIntvsPixels
	endif
	ModifyImage/W=SquareMapIntvsPixels SquareMap_dis  ctab= {ImageRangeMin,ImageRangeMax,$ColorTableName,0}
	setDataFolder OldDf
end
