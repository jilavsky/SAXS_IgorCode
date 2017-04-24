#pragma rtGlobals=1		// Use modern global access method.
#pragma version=2.11

//*************************************************************************\
//* Copyright (c) 2005 - 2017, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.11 added Q width (Q resolution, dQ) to line profile. Works only for Q for now. 
//2.10 fixed /NTHR=1 to /NTHR=0
//2.09 fixed note/NOCR which was embedding new line in wrong place
//2.08 tried to fix az direction and display. Seems to work now but what a mess with direction definitions.
//2.07 fixed ellipse (circle) display and output, added angle as one of output waves and modified graph to enable it display. 
//2.06 changed behavior. If line profile is ONLY in negative direction of Q, the Q will be presented as abs(Q), i.e, in positive direction. 
//2.05 fixed display of data for horizontal line and Angle line at 90 degrees. 
//2.04 modified saving data - now when error from ImageLineProfile is NaN, it is replaced by 0 so even data with no error are saved. Also, sorted output waves to start from low q values
//2.03 added mutlithread and MatrixOp/NTHR=1 whre seemed possible to use multile cores
//2.02 added license for ANL

//2.01 updted for Nika 1.43, changed error calculations
//2.0 updated for Nika 1.42
//Line profile functions for NIka
//version September 2009


//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************


Function NI1A_LineProf_CreateLP()

	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

		NVAR LineProf_GIIncAngle=root:Packages:Convert2Dto1D:LineProf_GIIncAngle
		NVAR LineProf_EllipseAR=root:Packages:Convert2Dto1D:LineProf_EllipseAR
		NVAR LineProf_LineAzAngle=root:Packages:Convert2Dto1D:LineProf_LineAzAngle
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
		NVAR UseMask=root:Packages:Convert2Dto1D:UseMask
		NVAR LineProfileUseRAW=root:Packages:Convert2Dto1D:LineProfileUseRAW
		NVAR LineProfileUseCorrData=root:Packages:Convert2Dto1D:LineProfileUseCorrData
		SVAR LineProf_CurveType=root:Packages:Convert2Dto1D:LineProf_CurveType
		NVAR HorizontalTilt=root:Packages:Convert2Dto1D:HorizontalTilt
		NVAR VerticalTilt=root:Packages:Convert2Dto1D:VerticalTilt
		NVAR ErrorCalculationsUseOld=root:Packages:Convert2Dto1D:ErrorCalculationsUseOld
		NVAR ErrorCalculationsUseStdDev=root:Packages:Convert2Dto1D:ErrorCalculationsUseStdDev
		NVAR ErrorCalculationsUseSEM=root:Packages:Convert2Dto1D:ErrorCalculationsUseSEM
		//abort if not selected anything meaningful..
	
		if(stringMatch(LineProf_CurveType,"Horizontal Line"))
			//Ok
		elseif(stringMatch(LineProf_CurveType,"Vertical Line"))
			//OK
		elseif(stringMatch(LineProf_CurveType,"Angle Line"))
			//OK
		elseif(stringMatch(LineProf_CurveType,"Ellipse"))
			//OK
		elseif(stringMatch(LineProf_CurveType,"GI_Vertical Line"))
			//OK
		elseif(stringMatch(LineProf_CurveType,"GI_Horizontal Line"))
			//OK
		else
			//not OK. End
			return 0
		endif	



		if(LineProfileUseRAW)
			Wave/Z CCDImageToConvert=root:Packages:Convert2Dto1D:CCDImageToConvert_dis
			if(!WaveExists(CCDImageToConvert))
				DoAlert 0, "Image data do not exist"
				 return 0
			endif
		else
			Wave/Z CCDImageToConvert=root:Packages:Convert2Dto1D:Calibrated2DDataSet
			if(!WaveExists(CCDImageToConvert))
				DoAlert 0, "Corrected data do not exist"
				 return 0
			endif
		endif
		//deal with wave note...
		string OldNote=note(CCDImageToConvert)
		//first check if our mask is OK here...
		if(UseMask)
			wave M_ROIMask=root:Packages:Convert2Dto1D:M_ROIMask
			MatrixOp/O/NTHR=0 MaskedQ2DWave = CCDImageToConvert *( M_ROIMask/M_ROIMask)
		else
			MatrixOp/O/NTHR=0 MaskedQ2DWave = CCDImageToConvert
		endif
		//first create xwave and ywave for the ImageLineProfile...
		variable length
		if(stringMatch(LineProf_CurveType,"Horizontal Line")||stringMatch(LineProf_CurveType,"GI_Horizontal Line"))
			length=DimSize(CCDImageToConvert, 0 )
			make/O/N=(length) xwave, ywave
		elseif(stringMatch(LineProf_CurveType,"Vertical Line")||stringMatch(LineProf_CurveType,"GI_Vertical Line")||stringMatch(LineProf_CurveType,"GISAXS_FixQy"))
			length=DimSize(CCDImageToConvert, 1 )
			make/O/N=(length) xwave, ywave
		elseif(stringMatch(LineProf_CurveType,"Angle Line"))
			variable dim1
			dim1=max(DimSize(CCDImageToConvert, 0 ),DimSize(CCDImageToConvert, 1 ))
			make/O/N=(dim1) xwave
			make/O/N=(dim1) ywave
		elseif(stringMatch(LineProf_CurveType,"Ellipse"))
			make/O/N=(1440) xwave, ywave			//every 0.25 degrees should be enough...
		endif	
		//here we create paths as needed... This should be the same as in the NI1A_DrawLinesIn2DGraph function
		if(stringMatch(LineProf_CurveType,"Horizontal Line")||stringMatch(LineProf_CurveType,"GI_Horizontal Line"))
			xwave=BeamCenterY-LineProf_DistanceFromCenter
			ywave=p
		elseif(stringMatch(LineProf_CurveType,"Vertical Line")||stringMatch(LineProf_CurveType,"GI_Vertical Line"))
			xwave=p
			ywave=BeamCenterX+LineProf_DistanceFromCenter
		elseif(stringMatch(LineProf_CurveType,"Angle Line"))
			NI1A_GenerAngleLine(Dimsize(CCDImageToConvert, 0),Dimsize(CCDImageToConvert, 1),BeamCenterX,BeamCenterY,LineProf_LineAzAngle,LineProf_DistanceFromCenter,yWave,xWave)
		elseif(stringMatch(LineProf_CurveType,"Ellipse"))
			NI1A_GenerEllipseLine(BeamCenterX,BeamCenterY,LineProf_EllipseAR,LineProf_DistanceFromCenter,yWave,xWave)
		endif	
		ImageLineProfile/S xWave=ywave, yWave=xwave, srcwave=MaskedQ2DWave , width= LineProf_Width
		Wave W_LineProfileX = root:Packages:Convert2Dto1D:W_LineProfileX
		Wave W_LineProfileY = root:Packages:Convert2Dto1D:W_LineProfileY
		Wave W_ImageLineProfile = root:Packages:Convert2Dto1D:W_ImageLineProfile
		Wave W_LineProfileStdv=root:Packages:Convert2Dto1D:W_LineProfileStdv
		if(LineProf_Width<2)
			Print "NOTE: Width used for line profile is less than 2 points. Intensity error in this case is calculated as square root of intensity, which may be WRONG."
			W_LineProfileStdv=sqrt(W_ImageLineProfile)
		else
			if(ErrorCalculationsUseSEM)
				W_LineProfileStdv/=sqrt(LineProf_Width)
			endif
			Print "NOTE: Width used for line profile is 2 points or more, used standard deviation to estimate intensity error."
		endif
		//Now calculate the angle wave for ellipse but calculate for everything...
		Duplicate/O W_ImageLineProfile, LineProfileAzAvalues
//		LineProfileAzAvalues = atan2((W_LineProfileY[p]-BeamCenterY),(W_LineProfileX[p]-BeamCenterX))
//		LineProfileAzAvalues*=180/pi
////		LineProfileAzAvalues=360 - LineProfileAzAvalues
//		LineProfileAzAvalues = LineProfileAzAvalues[p]>=0 ? LineProfileAzAvalues[p] : 360+LineProfileAzAvalues[p]
		LineProfileAzAvalues = atan2((W_LineProfileY[p]-BeamCenterY),(BeamCenterX - W_LineProfileX[p]))
		LineProfileAzAvalues*=180/pi
		LineProfileAzAvalues+=180
//		LineProfileAzAvalues = LineProfileAzAvalues[p]>=0 ? LineProfileAzAvalues[p] : 360+LineProfileAzAvalues[p]
		// end of anlge wave creation...
		Duplicate/O W_ImageLineProfile, LineProfileIntensity, LineProfileQvalues
		Duplicate/O W_LineProfileStdv, LineProfileIntSdev
		Duplicate/O W_LineProfileX, LineProfileYValsPix, LineProfileQy		//note: I screwed up above, so this needs to be changed...
		Duplicate/O W_LineProfileY, LineProfileZValsPix, LineProfileQz
		//add notes...
		note LineProfileIntensity,  OldNote
		note  LineProfileQvalues, OldNote
		note LineProfileIntSdev,  OldNote
		note  LineProfileQy,  OldNote
		note  LineProfileQz , OldNote
		
		//and now add the mirror lines, if needed...
		if(LineProf_UseBothHalfs)
				variable skipme=0
				if(stringMatch(LineProf_CurveType,"Horizontal Line")||stringMatch(LineProf_CurveType,"GI_Horizontal Line"))
					xwave=LineProf_DistanceFromCenter+BeamCenterY
					ywave=p
				elseif(stringMatch(LineProf_CurveType,"Vertical Line")||stringMatch(LineProf_CurveType,"GI_Vertical Line"))
					xwave=p
					ywave=BeamCenterX-LineProf_DistanceFromCenter
				else 
					skipme=1
				endif
				if(!skipme)	
					ImageLineProfile/S xWave=ywave, yWave=xwave, srcwave=MaskedQ2DWave , width= LineProf_Width
					Wave W_LineProfileX = root:Packages:Convert2Dto1D:W_LineProfileX
					Wave W_LineProfileY = root:Packages:Convert2Dto1D:W_LineProfileY
					Wave W_ImageLineProfile = root:Packages:Convert2Dto1D:W_ImageLineProfile
					Wave W_LineProfileStdv=root:Packages:Convert2Dto1D:W_LineProfileStdv

					if(LineProf_Width<2)
						W_LineProfileStdv=sqrt(W_ImageLineProfile)
					else
						if(ErrorCalculationsUseSEM)
							W_LineProfileStdv/=sqrt(LineProf_Width)
						else
						endif
					endif
					
					Duplicate/O W_ImageLineProfile, LineProfileIntensity2
					Duplicate/O W_LineProfileStdv, LineProfileIntSdev2
					
					NI1_SumTwoIntensitiesWithNaNs(LineProfileIntensity,LineProfileIntensity2)
					NI1_SumTwoErrorsWithNaNs(LineProfileIntSdev,LineProfileIntSdev2)
					KillWaves LineProfileIntSdev2,LineProfileIntensity2
				endif
		endif
		KillWaves MaskedQ2DWave
		
		//now we need to calculate the right Q values... There is difference between the regular geometry and GI geometry...
		if(!stringMatch(LineProf_CurveType,"GI_Horizontal Line") && !stringMatch(LineProf_CurveType,"GI_vertical Line"))		//regular geometry...
			//first convert to position in pixels...
			LineProfileYValsPix = LineProfileYValsPix[p] - BeamCenterX
			LineProfileZValsPix = BeamCenterY- LineProfileZValsPix[p] 
			//now convert to distance in mm
			LineProfileQy =PixelSizeX*LineProfileYValsPix[p]
			LineProfileQz =PixelSizeY*LineProfileZValsPix[p]
			//now fix tilts, if needed
			LineProfileQy=NI1T_TiltedToCorrectedR( LineProfileQy[p] ,SampleToCCDDistance,HorizontalTilt) 	//in mm 
			LineProfileQz=NI1T_TiltedToCorrectedR( LineProfileQz[p] ,SampleToCCDDistance,VerticalTilt) 	//in mm 

			LineProfileQy = NI1A_LP_ConvertPosToQ(LineProfileQy[p], SampleToCCDDistance, Wavelength)
			LineProfileQz = NI1A_LP_ConvertPosToQ(LineProfileQz[p], SampleToCCDDistance, Wavelength)
			//this is positive even on left hand side for horizontal line profile...
			if(stringMatch(LineProf_CurveType,"Horizontal Line"))
				LineProfileQvalues=sign(LineProfileQy[p])*sqrt((LineProfileQy[p])^2+(LineProfileQz[p])^2)
			elseif(stringMatch(LineProf_CurveType,"Angle Line"))
				if(LineProf_LineAzAngle==90)
					LineProfileQvalues=sign(LineProfileQy[p])*sign(LineProfileQz[p])*sqrt((LineProfileQy[p])^2+(LineProfileQz[p])^2)
				else
					LineProfileQvalues=sign(LineProfileQy[p])*sqrt((LineProfileQy[p])^2+(LineProfileQz[p])^2)
				endif
			else
				LineProfileQvalues=sign(LineProfileQz[p])*sqrt((LineProfileQy[p])^2+(LineProfileQz[p])^2)
			endif
		elseif(stringMatch(LineProf_CurveType,"GI_Horizontal Line"))		//GI geometry....
			Duplicate/O LineProfileQy, LineProfileQx, tempY
			LineProfileQx = NI1GI_CalculateQxyz(LineProfileYValsPix[p],LineProfileZValsPix[p],"X")
			LineProfileQy = NI1GI_CalculateQxyz(LineProfileYValsPix[p],LineProfileZValsPix[p],"Y")
			LineProfileQz = NI1GI_CalculateQxyz(LineProfileYValsPix[p],LineProfileZValsPix[p],"Z")
			LineProfileQvalues=sign(LineProfileQy[p])*sign(LineProfileQz[p])*sqrt((LineProfileQx[p])^2+(LineProfileQy[p])^2+(LineProfileQz[p])^2)
		elseif(stringMatch(LineProf_CurveType,"GI_vertical Line"))		//GI geometry....
			Duplicate/O LineProfileQy, LineProfileQx, tempY
			LineProfileQx = NI1GI_CalculateQxyz(LineProfileYValsPix[p],LineProfileZValsPix[p],"X")
			LineProfileQy = NI1GI_CalculateQxyz(LineProfileYValsPix[p],LineProfileZValsPix[p],"Y")
			LineProfileQz = NI1GI_CalculateQxyz(LineProfileYValsPix[p],LineProfileZValsPix[p],"Z")
			LineProfileQvalues=sign(LineProfileQy[p])*sign(LineProfileQz[p])*sqrt((LineProfileQx[p])^2+(LineProfileQy[p])^2+(LineProfileQz[p])^2)
		endif
		//add to the note some info for user...
		string Newnote=""
		Newnote+=	"LineProf_DistanceFromCenter="+num2str(LineProf_DistanceFromCenter)+";"
		Newnote+=	"LineProf_Width="+num2str(LineProf_Width)+";"
		Newnote+=	"LineProf_DistanceQ="+num2str(LineProf_DistanceQ)+";"
		Newnote+=	"LineProf_UseBothHalfs="+num2str(LineProf_UseBothHalfs)+";"
		Newnote+=	"UseMask="+num2str(UseMask)+";"
		Newnote+=	"LineProfileUseRAW="+num2str(LineProfileUseRAW)+";"
		Newnote+=	"LineProfileUseCorrData="+num2str(LineProfileUseCorrData)+";"
		Newnote+=	"LineProf_CurveType="+LineProf_CurveType+";"

		if(ErrorCalculationsUseSEM)
			Newnote+="UncertainityCalculationMethod=StandardErrorOfMean;"
		else
			Newnote+="UncertainityCalculationMethod=StandardDeviation;"		
		endif

		note/NOCR LineProfileIntensity , Newnote
		note/NOCR  LineProfileQvalues, Newnote
		note/NOCR LineProfileIntSdev,  Newnote
		note/NOCR  LineProfileQy,  Newnote
		note/NOCR  LineProfileQz , Newnote
		note/NOCR  LineProfileAzAvalues , Newnote
		IN2G_RemoveNaNsFrom6Waves(LineProfileIntensity,LineProfileQvalues,LineProfileIntSdev,LineProfileQy,LineProfileQz,LineProfileAzAvalues)
		//finally, if the data are ONLY in negative direction, then take abs of Q as that is likely what user wants to do...
		if(numpnts(LineProfileIntensity)>3)
			Wavestats /Q LineProfileQvalues
		else
			return 0
		endif
		if(sign(V_min)==-1 && sign(V_max)==-1)
			LineProfileQvalues=abs(LineProfileQvalues)
			LineProfileQy=abs(LineProfileQy)
			LineProfileQz=abs(LineProfileQz)
		endif
		
		variable constVal=Wavelength / (4 * pi)
		Duplicate/O LineProfileQvalues, LineProfiledQvalues, LineProfileTwoThetaWidth, LineProfileDistacneInmmWidth, LineProfileDspacingWidth
		Duplicate/Free LineProfileQvalues, LineProfileTwoTheta, LineProfileDistacneInmm, LineProfileDspacing
		LineProfiledQvalues = LineProfileQvalues[p+1] - LineProfileQvalues[p]
		LineProfiledQvalues[numpnts(LineProfileQvalues)-1]=LineProfiledQvalues[numpnts(LineProfileQvalues)-2]
		LineProfileTwoTheta =  2 * asin ( LineProfileQvalues * constVal) * 180 /pi
		LineProfileTwoThetaWidth  = LineProfileTwoTheta[p+1] - LineProfileTwoTheta [p]
		LineProfileTwoThetaWidth[numpnts(LineProfileTwoThetaWidth)-1]=LineProfileTwoThetaWidth[numpnts(LineProfileTwoThetaWidth)-2]
		constVal = 2*pi
		LineProfileDspacing = constVal / LineProfileQvalues
		LineProfileDspacingWidth  = LineProfileDspacing [p] - LineProfileDspacing[p+1]
		LineProfileDspacingWidth[numpnts(LineProfileDspacingWidth)-1]=LineProfileDspacingWidth[numpnts(DSpacingWidth)-2]
	
		LineProfileDistacneInmm =  SampleToCCDDistance*tan(LineProfileTwoTheta*pi/180)
		LineProfileDistacneInmmWidth  = LineProfileDistacneInmm[p+1] - LineProfileDistacneInmm[p]
		LineProfileDistacneInmmWidth[numpnts(LineProfileDistacneInmmWidth)-1]=LineProfileDistacneInmmWidth[numpnts(LineProfileDistacneInmmWidth)-2]

		//create proper Q smearing data accounting for all other parts of gemoetry - beam size and pixels size
		//now this needs to be convoluted with other effects. 
		NVAR BeamSizeX = root:Packages:Convert2Dto1D:BeamSizeX
		NVAR BeamSizeY = root:Packages:Convert2Dto1D:BeamSizeY
		NVAR PixelSizeX = root:Packages:Convert2Dto1D:PixelSizeX
		NVAR PixelSizeY = root:Packages:Convert2Dto1D:PixelSizeY
		NVAR Wavelength= root:Packages:Convert2Dto1D:Wavelength
		NVAR SampleToCCDdistance = root:Packages:Convert2Dto1D:SampleToCCDdistance
		NI1A_CalculateQresolution(LineProfileQvalues,LineProfiledQvalues,LineProfileTwoThetaWidth, LineProfileDspacingWidth, LineProfileDistacneInmmWidth, PixelSizeX,PixelSizeY,BeamSizeX,BeamSizeY,Wavelength,SampleToCCDdistance)
		//that above creates the resolution due to pixel size, beam size and convolute them to existing binning q resolution. 

	setDataFolder OldDf
	return 1
end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_SumTwoIntensitiesWithNaNs(wave1,wave2)
	Wave wave1,wave2
	//returns average of the two waves if both exists or if one in NaN, returns just the single value
	variable i
	if(numpnts(wave1)!=numpnts(wave2))
		abort  "Error in NI1_SumTwoIntensitiesWithNaNs"
	endif
	For(i=0;i<numpnts(wave1);i+=1)
		if(numtype(Wave1[i])==0 && numtype(wave2[i])==0)
			Wave1[i]=(Wave1[i] + Wave2[i])/2
		elseif(numtype(Wave1[i])==0)
			Wave1[i]=Wave1[i]
		elseif(numtype(wave2[i])==0)
			Wave1[i]=Wave2[i]
		else
			Wave1[i]=nan
		endif 
	endfor
end
Function NI1_SumTwoErrorsWithNaNs(wave1,wave2)
	Wave wave1,wave2
	//returns average of the two waves if both exists or if one in NaN, returns just the single value
	variable i
	if(numpnts(wave1)!=numpnts(wave2))
		abort  "Error in NI1_SumTwoErrorsWithNaNs"
	endif
	For(i=0;i<numpnts(wave1);i+=1)
		if(numtype(Wave1[i])==0 && numtype(wave2[i])==0)
			Wave1[i]=sqrt((Wave1[i]^2 + Wave2[i]^2))
		elseif(numtype(Wave1[i])==0)
			Wave1[i]=Wave1[i]
		elseif(numtype(wave2[i])==0)
			Wave1[i]=Wave2[i]
		else
			Wave1[i]=nan
		endif 
	endfor


end

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_LP_ConvertPosToQ(distance, SampleToCCDDistance, Wavelength)
		variable distance, SampleToCCDDistance, Wavelength
		
		variable theta=atan(abs(distance)/SampleToCCDDistance)/2
		return sign(distance)*((4*pi)/Wavelength)*sin(theta)

end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1A_LineProf_DisplayLP()
	string oldDf=GetDataFOlder(1)
	setDataFolder root:Packages:Convert2Dto1D

		Wave LineProfileQy = root:Packages:Convert2Dto1D:LineProfileQy
		Wave LineProfileQz = root:Packages:Convert2Dto1D:LineProfileQz
		Wave LineProfileQvalues = root:Packages:Convert2Dto1D:LineProfileQvalues
		Wave LineProfileAzAvalues = root:Packages:Convert2Dto1D:LineProfileAzAvalues
		Wave LineProfileIntSdev = root:Packages:Convert2Dto1D:LineProfileIntSdev
		Wave LineProfileIntensity = root:Packages:Convert2Dto1D:LineProfileIntensity

	DoWindow LineProfile_Preview
	if(V_Flag)
		DoWIndow/F LineProfile_Preview
	else
		Display/W=(400,600,1100,850)/K=1/N=LineProfile_Preview as "Line Profile Preview"
		//DoWindow/C LineProfile_Preview
		ControlBar /T/W=LineProfile_Preview 25
		CheckBox DisplayQ,pos={5,5},size={10,14},proc=NI1_LineProf_CheckProc,title="Use Q?"
		CheckBox DisplayQ,help={"Use Q as x axis for the graph?"}, mode=1
		CheckBox DisplayQ,variable= root:Packages:Convert2Dto1D:LineProfileDisplayWithQ
		CheckBox DisplayQy,pos={70,5},size={10,14},proc=NI1_LineProf_CheckProc,title=" Qy?"
		CheckBox DisplayQy,help={"Use Qy as x axis for the graph?"}, mode=1
		CheckBox DisplayQy,variable= root:Packages:Convert2Dto1D:LineProfileDisplayWithQy
		CheckBox DisplayQz,pos={145,5},size={10,14},proc=NI1_LineProf_CheckProc,title=" Qz?"
		CheckBox DisplayQz,help={"Use Qz as x axis for the graph?"}, mode=1
		CheckBox DisplayQz,variable= root:Packages:Convert2Dto1D:LineProfileDisplayWithQz
		CheckBox DisplayAzA,pos={215,5},size={10,14},proc=NI1_LineProf_CheckProc,title="Az Angle?"
		CheckBox DisplayAzA,help={"UseAzimuthal angle as x axis for the graph?"}, mode=1
		CheckBox DisplayAzA,variable= root:Packages:Convert2Dto1D:LineProfileDisplayWithAzA


		CheckBox LineProfileDisplayLogX,pos={330,5},size={10,14},proc=NI1_LineProf_CheckProc,title=" Log X Axis?"
		CheckBox LineProfileDisplayLogX,help={"Use log x axis for the graph?"}, mode=0
		CheckBox LineProfileDisplayLogX,variable= root:Packages:Convert2Dto1D:LineProfileDisplayLogX

		CheckBox LineProfileDisplayLogY,pos={435,5},size={10,14},proc=NI1_LineProf_CheckProc,title=" Log Y axis?"
		CheckBox LineProfileDisplayLogY,help={"Use log y axis for the graph?"}, mode=0
		CheckBox LineProfileDisplayLogY,variable= root:Packages:Convert2Dto1D:LineProfileDisplayLogY
		
		Button SaveDataNow, pos={540,5}, size={100,15}, title="Save Data",proc=NI1_LineProf_ButtonProc
		DoWindow CCDImageToConvertFig
		if(V_Flag)
			AutoPositionWindow/E/M=1/R=CCDImageToConvertFig
		endif
	endif
	CheckDisplayed /W=LineProfile_Preview  LineProfileIntensity 
	if(V_Flag)
		RemoveFromGraph /W=LineProfile_Preview  LineProfileIntensity 
	endif
	
		NVAR LineProfileDisplayWithQz=root:Packages:Convert2Dto1D:LineProfileDisplayWithQz
		NVAR LineProfileDisplayWithQy=root:Packages:Convert2Dto1D:LineProfileDisplayWithQy
		NVAR LineProfileDisplayWithQ=root:Packages:Convert2Dto1D:LineProfileDisplayWithQ
		NVAR LineProfileDisplayWithAzA=root:Packages:Convert2Dto1D:LineProfileDisplayWithAzA
		NVAR LineProfileDisplayLogX=root:Packages:Convert2Dto1D:LineProfileDisplayLogX
		NVAR LineProfileDisplayLogY=root:Packages:Convert2Dto1D:LineProfileDisplayLogY
	if(LineProfileDisplayWithQ)
		AppendTograph LineProfileIntensity vs LineProfileQvalues
		Label bottom "Q [1/A]"
	elseif(LineProfileDisplayWithQy)
		AppendTograph LineProfileIntensity vs LineProfileQy
		Label bottom "Qy [1/A]"
	elseif(LineProfileDisplayWithAzA)
		AppendTograph LineProfileIntensity vs LineProfileAzAvalues
		Label bottom "Azimuthal angle"
	else
		AppendTograph LineProfileIntensity vs LineProfileQz
		Label bottom "Qz [1/A]"
	endif

	if(LineProfileDisplayLogX)
		ModifyGraph log(bottom)=1
	else
		ModifyGraph log(bottom)=0
	endif
	if(LineProfileDisplayLogY)
		ModifyGraph log(left)=1
	else
		ModifyGraph log(left)=0
	endif
	Label left "Intensity"
	ErrorBars LineProfileIntensity Y,wave=(LineProfileIntSdev,LineProfileIntSdev)
	setDataFolder OldDf

end
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
Function NI1_LineProf_ButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here'
			
			//SaveDataNow
				NVAR LineProf_DistanceQ=root:Packages:Convert2Dto1D:LineProf_DistanceQ
				NVAR LineProf_WidthQ=root:Packages:Convert2Dto1D:LineProf_WidthQ
				SVAR LineProf_CurveType=root:Packages:Convert2Dto1D:LineProf_CurveType	
				NVAR LineProf_LineAzAngle=root:Packages:Convert2Dto1D:LineProf_LineAzAngle
				string tempStr, tempStr1
				if(stringMatch(LineProf_CurveType,"Horizontal Line"))
					tempStr1="HLp_"
					sprintf tempStr, "%1.2g" LineProf_DistanceQ
				elseif(stringMatch(LineProf_CurveType,"GI_Horizontal line"))
					tempStr1="GI_HLp_"
					sprintf tempStr, "%1.2g" LineProf_DistanceQ
				elseif(stringMatch(LineProf_CurveType,"GI_Vertical line"))
					tempStr1="GI_VLp_"
					sprintf tempStr, "%1.2g" LineProf_DistanceQ
				elseif(stringMatch(LineProf_CurveType,"Vertical Line"))
					tempStr1="VLp_"
					sprintf tempStr, "%1.2g" LineProf_DistanceQ
				elseif(stringMatch(LineProf_CurveType,"Ellipse"))
					tempStr1="ELp_"
					sprintf tempStr, "%1.2g" LineProf_DistanceQ
				elseif(stringMatch(LineProf_CurveType,"Angle Line"))
					tempStr1="ALp_"
					sprintf tempStr, "%1.2g" LineProf_LineAzAngle
				endif
				NI1A_SaveDataPerUserReq(tempStr1+tempStr)

			break
	endswitch

	return 0
End

//*******************************************************************************************************************************************
//*******************************************************************************************************************************************
//*******************************************************************************************************************************************

Function NI1_LineProf_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR LineProfileDisplayWithQz=root:Packages:Convert2Dto1D:LineProfileDisplayWithQz
			NVAR LineProfileDisplayWithQy=root:Packages:Convert2Dto1D:LineProfileDisplayWithQy
			NVAR LineProfileDisplayWithQ=root:Packages:Convert2Dto1D:LineProfileDisplayWithQ
			NVAR LineProfileDisplayWithAzA=root:Packages:Convert2Dto1D:LineProfileDisplayWithAzA
			if(stringmatch(cba.ctrlName,"DisplayQ")&&LineProfileDisplayWithQ)
				LineProfileDisplayWithQz=0
				LineProfileDisplayWithQy=0
				LineProfileDisplayWithAzA=0
				NI1A_LineProf_DisplayLP()
			endif
			if(stringmatch(cba.ctrlName,"DisplayQz")&&LineProfileDisplayWithQz)
				LineProfileDisplayWithQ=0
				LineProfileDisplayWithQy=0
				LineProfileDisplayWithAzA=0
				NI1A_LineProf_DisplayLP()
			endif
			if(stringmatch(cba.ctrlName,"DisplayQy")&&LineProfileDisplayWithQy)
				LineProfileDisplayWithQz=0
				LineProfileDisplayWithQ=0
				LineProfileDisplayWithAzA=0
				NI1A_LineProf_DisplayLP()
			endif
			if(stringmatch(cba.ctrlName,"DisplayAzA")&&LineProfileDisplayWithAzA)
				LineProfileDisplayWithQz=0
				LineProfileDisplayWithQ=0
				LineProfileDisplayWithQy=0
				NI1A_LineProf_DisplayLP()
			endif
			NVAR LineProfileDisplayLogX=root:Packages:Convert2Dto1D:LineProfileDisplayLogX
			NVAR LineProfileDisplayLogY=root:Packages:Convert2Dto1D:LineProfileDisplayLogY
			if(stringmatch(cba.ctrlName,"LineProfileDisplayLogX"))
				ModifyGraph log(bottom)=LineProfileDisplayLogX
			endif
			if(stringmatch(cba.ctrlName,"LineProfileDisplayLogY"))
				ModifyGraph log(left)=LineProfileDisplayLogY
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
