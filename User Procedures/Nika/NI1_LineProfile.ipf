#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method.
  
#pragma version=2.09

//*************************************************************************\
//* Copyright (c) 2005 - 2025, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//2.09 Fix bug with typo in dspacingWv wave name. 
//2.08 Remove for MatrixOP /NTHR=0 since it is applicable to 3D matrices only 
//2.07 Added Batch processing
//2.06 fixes for rtGLobal=3
//2.05 merged with NI1_LineProfCalcs.ipf
//2.04  removed unused functions
//2.03 minor fix to avoid name collision with LaueGo
//2.02 added license for ANL
//2.01 update for Igor 6.20
//2.0 updated for Nika 1.42

//notes from NI1_LineProfCalcs.ipf
//2.12 fixes for case when error=0 for points. 
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



//Comment: Modified Wavemetrics procedure, changed names to free from WM stuff, 
//modified to suit my needs

Function NI1_CreateImageLineProfileGraph()

	DoWindow/F NI1_ImageLineProfileGraph
	if( V_Flag==1 )							// is the "panel" up already?
		return 0
	endif

	String imageName= NI1_TopImageGraph()		// find one top image in the top graph window
	if( strlen(imageName) == 0 )
		DoAlert 0,"No image plot found"
		return 0
	endif
	
	Wave w= $NI1_GetImageWave(imageName)	// get the wave associated with the top image.	
	String dfSav= GetDataFolder(1)

	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:NI1_ImProcess
	NewDataFolder/O/S root:Packages:NI1_ImProcess:LineProfile
	
		String/G imageGraphName= ""			// Let the activate event fill this in
		Variable/G profileMode=1			// truth want horizonal (x) profile
		Variable/G oldProfileMode=1		// for update testing
		Variable/G width= 5				// colums or rows to average
		Variable/G position=0				// this means 0 offset for the initial points (which are the center of the image).
		Variable/G isColor=NI1_isColorWave(w)
		Variable/G DisplayPixles=1
		Variable/G DisplayQvec=0
		variable/G DisplaydSpacing=0
		variable/G DisplayTwoTheta=0
		variable/G DisplayUsingLogScaleX=0
		variable/G DisplayUsingLogScaleY=0
		
		if(isColor==0)
			Make/O profile
			Wave profile= profile
		else
			Make/O profileR,profileG,profileB
			Wave profileR
			Wave profileG
			Wave profileB
		endif
	
	SetDataFolder dfSav
	NVAR horiz= root:Packages:NI1_ImProcess:LineProfile:profileMode
	
	// specify size in pixels to match user controls
	Variable x0=40*72/ScreenResolution, y0= 349*72/ScreenResolution
	Variable x1=555*72/ScreenResolution, y1= 569*72/ScreenResolution

	if(isColor==0)
		Display/K=1/W=(x0,y0,x1,y1) profile as "Image Line Profile"
	else
		Display/K=1/W=(x0,y0,x1,y1) profileR,profileG,profileB as "Image Line Profile"
		ModifyGraph rgb(profileG)=(0,65535,0),rgb(profileB)=(0,0,65535)
	endif
	
	DoWindow/C NI1_ImageLineProfileGraph
	AutoPositionWindow/E/M=1/R=$imageName

	Variable isWin= CmpStr(IgorInfo(2)[0,2],"Win")==0
	Variable fsize=12
	if( isWin )
		fsize=10
	endif
	
	ControlBar 60
	PopupMenu profileModePop,pos={2,6},size={158,24},proc=NI1_ImLineProfileModeProc
	PopupMenu profileModePop,help={"Profile mode selection.  Freehand modes allow you to edit the path by adding and moving points in the trace."}
	//PopupMenu profileModePop,mode=3,popvalue="Horizontal Freehand",value= #"\"Horizontal;Vertical\"" //";Horizontal Freehand;Vertical Freehand;Freehand\""
	PopupMenu profileModePop,mode=3,popvalue="Vertical",value= #"\"Horizontal;Vertical\"" //";Horizontal Freehand;Vertical Freehand;Freehand\""
	SetVariable width,pos={298,35},size={90,19},proc=NI1_ImLineProfWidthSetVarProc,title="width"
	SetVariable width,help={"Number of rows or columns to average."},format="%g"
	SetVariable width,limits={0,Inf,0.5},value= root:Packages:NI1_ImProcess:LineProfile:width
	SetVariable position,pos={408,35},size={107,19},proc=NI1_ImLineProfWidthSetVarProc,title="position"
	SetVariable position,help={"Center row or column."},format="%g"
	SetVariable position,limits={-inf,Inf,1},value= root:Packages:NI1_ImProcess:LineProfile:position
//	Button checkpoint,pos={350,4},size={80,20},proc=NI1_ImLineProfCPButtonProc,title="Checkpoint"
//	Button checkpoint,help={"Click to save and graph current profile."}
//	Button remove,pos={440,4},size={69,20},proc=NI1_ImLineProfRemoveButtonProc,title="Remove"
//	Button remove,help={"Removes profile lines (if any) from target image."}
	Button SaveCurrentLineout,pos={400,4},size={80,20},proc=NI1_SquareButtonProc,title="Save Lineout"
	Button SaveCurrentLineout,help={"Click in this button to terminate the path editing mode."}
 
	CheckBox DisplayPixles,pos={10,35},size={90,14},proc=NI1_SquareGraphCheckProc,title="Use pixles?"
	CheckBox DisplayPixles,help={"Use pixles as x axis for the graph?"}, mode=1
	CheckBox DisplayPixles,variable= root:Packages:NI1_ImProcess:LineProfile:DisplayPixles
	CheckBox DisplayQvec,pos={90,35},size={80,14},proc=NI1_SquareGraphCheckProc,title=" q?"
	CheckBox DisplayQvec,help={"Use q vector as x axis for the graph?"}, mode=1
	CheckBox DisplayQvec,variable= root:Packages:NI1_ImProcess:LineProfile:DisplayQvec
	CheckBox DisplaydSpacing,pos={140,35},size={90,14},proc=NI1_SquareGraphCheckProc,title=" d?"
	CheckBox DisplaydSpacing,help={"Use d spacing as x axis for the graph?"}, mode=1
	CheckBox DisplaydSpacing,variable= root:Packages:NI1_ImProcess:LineProfile:DisplaydSpacing
	CheckBox DisplayTwoTheta,pos={200,35},size={90,14},proc=NI1_SquareGraphCheckProc,title=" 2 theta?"
	CheckBox DisplayTwoTheta,help={"Use two theta as x axis for the graph?"}, mode=1
	CheckBox DisplayTwoTheta,variable= root:Packages:NI1_ImProcess:LineProfile:DisplayTwoTheta

	CheckBox DisplayUsingLogScaleX,pos={100,6},size={90,14},proc=NI1_SquareGraphCheckProc,title="x axis log scale?"
	CheckBox DisplayUsingLogScaleX,help={"Use log scale on x axis?"}
	CheckBox DisplayUsingLogScaleX,variable= root:Packages:NI1_ImProcess:LineProfile:DisplayUsingLogScaleX

//	Button lineProfileHelpButt,pos={220,4},size={50,20},proc=lineProfileHelpProc,title="Help"
//	Button startPathProfileButton,pos={4,34},size={130,20},proc=NI1_StartEditingPathProfile,title="Start Editing Path"
//	Button startPathProfileButton,help={"After clicking in this button edit the path drawn on the top image.  Click in the Finished button when you are done."}
//	Button finishPathProfileButton,pos={140,34},size={130,20},proc=NI1_FinishFHPathProfile,title="Finished Editing"
//	Button finishPathProfileButton,help={"Click in this button to terminate the path editing mode."}
	SetWindow kwTopWin,hook=NI1_ImageLineProfileWindowProc
	
	NI1_CalculateQdTTHwaves()
	
	NI1_ImLineProfileModeProc("",1,"")

//	Wave LineProfileY= root:WinGlobals:$(imageGraphName):LineProfileY
//	ModifyGraph/W=$imageGraphName offset(lineProfileY)={0,0}	
End

Function NI1_SquareGraphCheckProc(ctrlName,checked) : CheckBoxControl
	String ctrlName
	Variable checked

		NVAR DisplayPixles=root:Packages:NI1_ImProcess:LineProfile:DisplayPixles
		NVAR DisplayQvec=root:Packages:NI1_ImProcess:LineProfile:DisplayQvec
		NVAR DisplaydSpacing=root:Packages:NI1_ImProcess:LineProfile:DisplaydSpacing
		NVAR DisplayTwoTheta=root:Packages:NI1_ImProcess:LineProfile:DisplayTwoTheta
		NVAR DisplayUsingLogScaleX=root:Packages:NI1_ImProcess:LineProfile:DisplayUsingLogScaleX

		NI1_CalculateQdTTHwaves()
		wave profile=root:Packages:NI1_ImProcess:LineProfile:profile
		wave qvector=root:Packages:NI1_ImProcess:LineProfile:qvector
		wave TwoTheta=root:Packages:NI1_ImProcess:LineProfile:TwoTheta
		wave Dspacing=root:Packages:NI1_ImProcess:LineProfile:Dspacing
		
	if(cmpstr("DisplayPixles",ctrlName)==0)
		RemoveFromGraph/W=NI1_ImageLineProfileGraph profile
		AppendToGraph profile
		Label/W=NI1_ImageLineProfileGraph bottom "pixles"
		if(DisplayUsingLogScaleX)
			ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
		endif
		setAxis Bottom NI1_FindFirstLastNotNaNPoint(profile, 1), NI1_FindFirstLastNotNaNPoint(profile, 2)
		//DisplayPixles=0
		DisplayQvec=0
		DisplaydSpacing=0
		DisplayTwoTheta=0
	endif
	if(cmpstr("DisplayQvec",ctrlName)==0)
		RemoveFromGraph/W=NI1_ImageLineProfileGraph profile
		AppendToGraph profile vs qvector
		Label/W=NI1_ImageLineProfileGraph bottom "q [1/A]"
		if(DisplayUsingLogScaleX)
			ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
		endif
		setAxis Bottom qvector[NI1_FindFirstLastNotNaNPoint(profile, 1)], qvector[NI1_FindFirstLastNotNaNPoint(profile, 2)]
		DisplayPixles=0
		//DisplayQvec=0
		DisplaydSpacing=0
		DisplayTwoTheta=0
	endif
	if(cmpstr("DisplaydSpacing",ctrlName)==0)
		RemoveFromGraph/W=NI1_ImageLineProfileGraph profile
		AppendToGraph profile vs Dspacing
		Label/W=NI1_ImageLineProfileGraph bottom "d [A]"
		if(DisplayUsingLogScaleX)
			ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
		endif
		setAxis Bottom Dspacing[NI1_FindFirstLastNotNaNPoint(profile, 2)],Dspacing[NI1_FindFirstLastNotNaNPoint(profile, 1)]
		DisplayPixles=0
		DisplayQvec=0
		//DisplaydSpacing=0
		DisplayTwoTheta=0
	endif
	if(cmpstr("DisplayTwoTheta",ctrlName)==0)
		RemoveFromGraph/W=NI1_ImageLineProfileGraph profile
		AppendToGraph profile vs TwoTheta
		Label/W=NI1_ImageLineProfileGraph bottom "2 theta [degrees]"
		if(DisplayUsingLogScaleX)
			ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
		endif
		setAxis Bottom TwoTheta[NI1_FindFirstLastNotNaNPoint(profile, 1)], TwoTheta[NI1_FindFirstLastNotNaNPoint(profile, 2)]
		DisplayPixles=0
		DisplayQvec=0
		DisplaydSpacing=0
		//DisplayTwoTheta=0
	endif
	if(cmpstr("DisplayUsingLogScaleX",ctrlName)==0)
		if(checked)
			ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
		else
			ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=0
		endif
	endif
	
end

Function NI1_FindFirstLastNotNaNPoint(inputWave, FirstOrLast)
	wave inputWave
	variable FirstOrLast		//1 for frist, 2 for last
	
	variable i
	if(FirstOrLast==1)
		i=0
		Do
			if(numtype(inputWave[i])==0)
				break
			endif
			i+=1
		while (i<numpnts(inputWave))
		return i
	else
		i=numpnts(inputWave)-1
		Do
			if(numtype(inputWave[i])==0)
				break
			endif
			i-=1
		while (i>0)
		return i
	endif
end

Function NI1_CalculateQdTTHwaves()
	
	string OldDf=GetDataFolder(1)
	setDataFolder root:Packages:NI1_ImProcess:LineProfile:
	
		wave profile=root:Packages:NI1_ImProcess:LineProfile:profile
		make/O/N=(numpnts(profile)) qvector, TwoTheta, Dspacing
		NVAR Wavelength=root:Packages:Convert2Dto1D:Wavelength
		NVAR PixelSizeX=root:Packages:Convert2Dto1D:PixelSizeX
		NVAR PixelSizeY=root:Packages:Convert2Dto1D:PixelSizeY
		NVAR SampleToCCDDistance=root:Packages:Convert2Dto1D:SampleToCCDDistance
		// sin (theta) = Q * Lambda / 4 * pi     
		//	Qdistribution1D = ((4*pi)/Wavelength)*sin(0.5*Rdistribution1D/SampleToCCDDistance)
		TwoTheta = 180/pi * asin(p*((PixelSizeX+PixelSizeY)/2) / SampleToCCDDistance)
		// d = 0.5 * Lambda / sin(theta) = 2 * pi / Q    Q = 2pi/d
		Dspacing = 0.5 * Wavelength /sin(TwoTheta * pi/360)
		qvector = 2 *pi / Dspacing
	setDataFolder OldDf

end
//*******************************************************************************************************
// Call after changing either position, width or profileMode
//  This creates the waves that are used with the lineProfile operation.
Function NI1_UpdatePositionAndWidth(initLines)
	Variable initLines																	// 17FEB03
	
	NVAR profileMode= root:Packages:NI1_ImProcess:LineProfile:profileMode
	NVAR width= root:Packages:NI1_ImProcess:LineProfile:width
	SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	NVAR position= root:Packages:NI1_ImProcess:LineProfile:position

	WAVE/Z w= $NI1_GetImageWave(imageGraphName)		// the target matrix
	WAVE/Z LineProfileY= root:WinGlobals:$(imageGraphName):LineProfileY
	WAVE/Z LineProfileX= root:WinGlobals:$(imageGraphName):LineProfileX
	WAVE/Z FHLineProfileY= root:WinGlobals:$(imageGraphName):FHLineProfileY
	WAVE/Z FHLineProfileX= root:WinGlobals:$(imageGraphName):FHLineProfileX
	
	if( (WaveExists(w)==0) %| (WaveExists(LineProfileY)==0) %| (WaveExists(LineProfileX)==0) %| (WaveExists(FHLineProfileX)==0)%| (WaveExists(FHLineProfileY)==0))
		return -1
	endif
	
	// 05JUN00 extract the actual min and max values displayed in the graph
	Variable xmin, ymin,xmax,ymax			
	GetAxis /W=$imageGraphName /Q left
	if(V_Flag==0)
		ymin=V_min
		ymax=V_max
	else
		 ymin=DimOffset(w,1)
		 ymax=ymin+DimSize(w,1)*DimDelta(w,1)
	endif
	
	GetAxis /W=$imageGraphName /Q top
	if(V_flag==0)
		xmin=V_min
		xmax=V_max
	else
		GetAxis /W=$imageGraphName /Q bottom
		if(V_Flag==0)
			xmin=V_min
			xmax=V_max
		else
			xmin=DimOffset(w,0)
			xmax=xmin+DimSize(w,0)*DimDelta(w,0)
		endif
	endif

	Variable w2=width/2
	if(w2<0)
		w2=0
	endif
	
	if( profileMode==1 )
		LineProfileY= {position+w2,position+w2,NaN,position-w2,position-w2}
		LineProfileX={-INF,INF,NaN,-INF,INF}
	else
		if( profileMode==2 )
			LineProfileX= {position+w2,position+w2,NaN,position-w2,position-w2}
			LineProfileY={-INF,INF,NaN,-INF,INF}
		else
			// for all other freehand modes hide the regular lines
			LineProfileX=NaN
			LineProfileY=NaN
			if(initLines)						// 17FEB03
				if(profileMode==3)				// FH Horizontal
					FHLineProfileX={xmin,xmax}
					ymin+=(ymax-ymin)/2
					FHLineProfileY={ymin,ymin}
				else
					if(profileMode==4)			// FH Vertical
						xmin+=(xmax-xmin)/2
						FHLineProfileX={xmin,xmin}
						FHLineProfileY={ymin,ymax}
					else
						if(profileMode==5)		// FreeHand
							xmin+=(xmax-xmin)/2
							FHLineProfileX={xmin,xmin}
							FHLineProfileY={ymin,ymax}
						endif
					endif
				endif
			else
 				 NI1_FHLineProfileDependency($"",$"") 			// 21FEB03 make it update the curves
			endif
		endif
	endif


	CheckDisplayed/W=$imageGraphName lineProfileY
	if(V_Flag==1)
		ModifyGraph/W=$imageGraphName offset(lineProfileY)={0,0}
	endif
		
	return 0
End

//*******************************************************************************************************
// have never seen this image plot before

Function NI1_ImageLineProfileNew(newImageGraphName)			
	String newImageGraphName

	WAVE/Z w= $NI1_GetImageWave(newImageGraphName)			// the target matrix
	if( !WaveExists(w) )
		return 0
	endif

	NVAR profileMode= root:Packages:NI1_ImProcess:LineProfile:profileMode
	NVAR oldProfileMode= root:Packages:NI1_ImProcess:LineProfile:oldProfileMode
	NVAR width= root:Packages:NI1_ImProcess:LineProfile:width
	SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	WAVE/Z profile= root:Packages:NI1_ImProcess:LineProfile:profile
	NVAR isColor=root:Packages:NI1_ImProcess:LineProfile:isColor
	NVAR position= root:Packages:NI1_ImProcess:LineProfile:position

	// store the final width and position
	if(strlen(imageGraphName)>0)
		NVAR NI1_LP_width= root:WinGlobals:$(imageGraphName):NI1_LP_width
		NVAR NI1_LP_pos= root:WinGlobals:$(imageGraphName):NI1_LP_pos
		NVAR NI1_LP_profileMode= root:WinGlobals:$(imageGraphName):NI1_LP_profileMode
		NI1_LP_pos=position
		NI1_LP_width=width
		NI1_LP_profileMode=profileMode
	endif
	
	String oldImageName=imageGraphName
	Variable newTarget
	imageGraphName= newImageGraphName						// this is also executed in the calling function.

	Variable newColor=NI1_isColorWave(w)							// check to see if the change requires new waves.
	if(newColor!=isColor)										// changing to a new image
		String oldDF=GetDataFolder(1)
		SetDataFolder root:Packages:NI1_ImProcess:LineProfile
		if(newColor==0)
			Make/O profile
			RemoveFromGraph/z/w=NI1_ImageLineProfileGraph profileR,profileG,profileB
			killWaves/Z profileR,profileG,profileB
		else
			RemoveFromGraph/z/w=NI1_ImageLineProfileGraph profile
			Make/O profileR,profileG,profileB
			killwaves/z profile
		endif
		
		if(WinType(oldImageName)==1)						// 09JAN04 /Z does not work on bad graph name.
			RemoveFromGraph/Z/W=$oldImageName LineProfileY
		endif
		
		isColor=newColor
		NI1_ImLineProfileModeProc("",1,"") 
		SetDataFolder oldDF
		newTarget=1
	else
		newTarget=0
	endif

	if(oldProfileMode!=profileMode)
		newTarget=1
		oldProfileMode=profileMode
	endif
	
	imageGraphName= newImageGraphName // NI1_ImLineProfileModeProc makes it ""
	
	String dfSav= GetDataFolder(1)
	NewDataFolder/O/S root:WinGlobals
	if(DataFolderExists(newImageGraphName )==0)	// if we need to build a new data folder
		NewDataFolder/O/S $newImageGraphName
		String/G S_TraceOffsetInfo= ""
		Variable/G NI1_LP_profileMode= profileMode
		Variable/G NI1_LP_width= width
		Variable/G NI1_LP_pos	=position			// center row or column of profile line
		Variable/G NI1_LP_checkpoint			// serial number incremented when user presses checkpoint button
	
		switch(profileMode)
			case 1:
				position=DimDelta(w,1)*DimSize(w,1)/2+Dimoffset(w,1);
			break
			
			case 2:
				position=DimDelta(w,0)*DimSize(w,0)/2+Dimoffset(w,0);
			break
			
			default:
				position=0
		endswitch
		
		NI1_LP_pos=position
	else										// this is a revisit, but we could have a new mode so check the boundaries on position.
		SetDataFolder $newImageGraphName
		NVAR LP_width= root:WinGlobals:$(newImageGraphName):NI1_LP_width
		NVAR LP_pos= root:WinGlobals:$(newImageGraphName):NI1_LP_pos
		NVAR LP_profileMode= root:WinGlobals:$(newImageGraphName):NI1_LP_profileMode
		width=LP_width
		position=LP_pos
		profileMode=LP_profileMode
		
		// 05JUN00 extract the actual min and max values displayed in the graph
		Variable xmin, ymin,xmax,ymax,midx,midy			
		GetAxis /W=$imageGraphName /Q left
		if(V_Flag==0)
			ymin=V_min
			ymax=V_max
		else
			 ymin=DimOffset(w,1)
			 ymax=ymin+DimSize(w,1)*DimDelta(w,1)
		endif
		
		GetAxis /W=$imageGraphName /Q top
		if(V_flag==0)
			xmin=V_min
			xmax=V_max
		else
			GetAxis /W=$imageGraphName /Q bottom
			if(V_Flag==0)
				xmin=V_min
				xmax=V_max
			else
				xmin=DimOffset(w,0)
				xmax=xmin+DimSize(w,0)*DimDelta(w,0)
			endif
		endif
		
		midx=(xmin+xmax)/2
		midy=(ymin+ymax)/2
		
		// also, we need to check that the width does not exceed the range
		//if(profileMode==1)
		if(profileMode==2)
			if((position<ymin) || (position>ymax))
				position=midy
			endif
			if(width> abs(ymax-ymin))
				width=abs(ymax-ymin)/20											// arbitrary but reasonable 5%
			endif
		endif
		//if(profileMode==2)
		if(profileMode==1)
			if((position<xmin) || (position>xmax))
				position=midx
			endif
			if(width> abs(xmax-xmin))
				width=abs(xmax-xmin)/20											// arbitrary but reasonable 5%
			endif
		endif
		
	endif
	
	PopupMenu profileModePop mode=profileMode

	Make/O/N=5 LineProfileY,LineProfileX		// make the waves needed for the operation.
	Make/O FHLineProfileY,FHLineProfileX		// Freehand waves
	SetDataFolder $dfSav
	
	NI1_UpdatePositionAndWidth(1)				// 3

	RemoveFromGraph/W=$newImageGraphName/Z lineProfileY,FHLineProfileY
	String imax= StringByKey("AXISFLAGS",ImageInfo(newImageGraphName, NameOfWave(w), 0))+" "
	Execute "AppendToGraph/W="+newImageGraphName+" "+imax+GetWavesDataFolder(LineProfileY,2)+" vs "+GetWavesDataFolder(LineProfileX,2)
	ModifyGraph/W=$newImageGraphName rgb(lineProfileY)=(1,4,52428)
	ModifyGraph/W=$newImageGraphName quickdrag(lineProfileY)=1,live(lineProfileY)=1
	
	if(profileMode>2)
		Execute "AppendToGraph/W="+newImageGraphName+" "+imax+ GetWavesDataFolder(FHLineProfileY,2)+" vs "+GetWavesDataFolder(FHLineProfileX,2)
	endif

	S_TraceOffsetInfo=""	// make sure the following does nothing yet
	dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:NI1_ImProcess:LineProfile
	Variable/G lineProfileDummy
	SetFormula lineProfileDummy,"NI1_LineProfileDependency(root:WinGlobals:"+newImageGraphName+":S_TraceOffsetInfo)"
	SetDataFolder dfSav

	ModifyGraph/W=$newImageGraphName offset(lineProfileY)={0,0}			// This will fire the S_TraceOffsetInfo dependency
End
//*******************************************************************************************************
// we are revisiting this image plot and all the variables are assumed to exist
Function NI1_ImageLineProfileUpdate(newImageGraphName)		
	String newImageGraphName

	Wave w= $NI1_GetImageWave(newImageGraphName)		// the target matrix

	NVAR profileMode= root:Packages:NI1_ImProcess:LineProfile:profileMode
	NVAR width= root:Packages:NI1_ImProcess:LineProfile:width
	NVAR position= root:Packages:NI1_ImProcess:LineProfile:position
	SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	WAVE/Z profile= root:Packages:NI1_ImProcess:LineProfile:profile
	
	imageGraphName= newImageGraphName

	NVAR NI1_LP_profileMode= root:WinGlobals:$(imageGraphName):NI1_LP_profileMode
	NVAR NI1_LP_width= root:WinGlobals:$(imageGraphName):NI1_LP_width
	NVAR NI1_LP_pos= root:WinGlobals:$(imageGraphName):NI1_LP_pos
	SVAR S_TraceOffsetInfo= root:WinGlobals:$(imageGraphName):S_TraceOffsetInfo
	
	profileMode= NI1_LP_profileMode
	PopupMenu profileModePop, mode=profileMode

	width= NI1_LP_width
	position= NI1_LP_pos
	
	NI1_UpdatePositionAndWidth(1)				// 4
	Wave LineProfileY= root:WinGlobals:$(imageGraphName):LineProfileY
	Wave LineProfileX= root:WinGlobals:$(imageGraphName):LineProfileX
	
	Variable xoff,yoff
	Variable w2=width/2
	if(w2<0)
		w2=0
	endif
	
	if( profileMode==1 )
		LineProfileY= {position+w2,position+w2,NaN,position-w2,position-w2}
		LineProfileX={-INF,INF,NaN,-INF,INF}
	else
		if( profileMode==2 )
			LineProfileX= {position+w2,position+w2,NaN,position-w2,position-w2}
			LineProfileY={-INF,INF,NaN,-INF,INF}
		endif
	endif
	
	S_TraceOffsetInfo=""	// make sure the following does nothing yet
	String dfSav= GetDataFolder(1)
	SetDataFolder root:Packages:NI1_ImProcess:LineProfile
	Variable/G lineProfileDummy
	SetFormula lineProfileDummy,"NI1_LineProfileDependency(root:WinGlobals:"+newImageGraphName+":S_TraceOffsetInfo)"
	SetDataFolder dfSav

	CheckDisplayed/W=$newImageGraphName lineProfileY
	if(V_Flag==1)
		ModifyGraph/W=$newImageGraphName offset(lineProfileY)={0,0}		// This will fire the S_TraceOffsetInfo dependency
	endif
End

//*******************************************************************************************************
// Fires on a dependency. s is S_TraceOffsetInfo from the quickdrag stuff
Function NI1_LineProfileDependency(s)
	String s

	if( StrSearch(s,"TNAME:LineProfileY;",0)<=0)
		return 0
	endif

	NVAR profileMode= root:Packages:NI1_ImProcess:LineProfile:profileMode
	NVAR width= root:Packages:NI1_ImProcess:LineProfile:width
	NVAR position= root:Packages:NI1_ImProcess:LineProfile:position
	NVAR isColor=root:Packages:NI1_ImProcess:LineProfile:isColor
	SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	WAVE/Z profile= root:Packages:NI1_ImProcess:LineProfile:profile
	WAVE/Z profileR= root:Packages:NI1_ImProcess:LineProfile:profileR
	WAVE/Z profileG= root:Packages:NI1_ImProcess:LineProfile:profileG
	WAVE/Z profileB= root:Packages:NI1_ImProcess:LineProfile:profileB

	if( strlen(imageGraphName)<1)
		return 0
	endif
	
	// remember current params for possible revisit
	NVAR/Z NI1_LP_width=  root:WinGlobals:$(imageGraphName):NI1_LP_width
	if(!NVAR_Exists(NI1_LP_width))
		variable/g $("root:WinGlobals:"+imageGraphName+":NI1_LP_width")
		NVAR NI1_LP_width=  root:WinGlobals:$(imageGraphName):NI1_LP_width
	endif
//	NI1_LP_width= width		// save for reactivate after visiting a different image plot
	NVAR/Z NI1_LP_pos= root:WinGlobals:$(imageGraphName):NI1_LP_pos
	if(!NVAR_Exists(NI1_LP_pos))
		variable/g $("root:WinGlobals:"+imageGraphName+":NI1_LP_pos")
		NVAR NI1_LP_pos=  root:WinGlobals:$(imageGraphName):NI1_LP_pos
	endif
//	NI1_LP_pos= position
	NVAR/Z NI1_LP_profileMode= root:WinGlobals:$(imageGraphName):NI1_LP_profileMode
	if(!NVAR_Exists(NI1_LP_profileMode))
		variable/g $("root:WinGlobals:"+imageGraphName+":NI1_LP_profileMode")
		NVAR NI1_LP_profileMode=  root:WinGlobals:$(imageGraphName):NI1_LP_profileMode
	endif
//	NI1_LP_profileMode= profileMode

	WAVE/Z w= $NI1_GetImageWave(imageGraphName)		// the target matrix

	if( WaveExists(w)==0 )
		return 0
	endif
	
	if(isColor)
		if(WaveExists(profileR)*WaveExists(profileG)*WaveExists(profileB)==0)
			return 0
		endif
	else
		if(WaveExists(profile)==0)
			return 0
		endif
	endif
	

	Variable pos	
	if( profileMode==1 )
		pos= NumberByKey("YOFFSET",s)
		//pos= (dy - DimOffset(w, 1))/DimDelta(w,1)
	else
		if( profileMode==2 )
			pos= NumberByKey("XOFFSET",s)
			//pos= (dx - DimOffset(w, 0))/DimDelta(w,0)
		endif
	endif
		  
	position+=pos
	NI1_DoLineProfile(w,pos,width,profileMode)
	NI1_UpdatePositionAndWidth(1)					// 5 update the wave for no offset.
	NI1_UpdateLineProfileGraph()	
	return 0
End
//*******************************************************************************************************
// given a matrix (wsrc), calculates a horizontal (columnwise) or vertical (rowwise)
// profile by averaging with rows or columns centered on pos
// wprofile is forced to double precision and with same scaling as given dimension of wsrc

Function NI1_DoLineProfile(wsrc,pos,width,profileMode)
	Wave wsrc
	Variable pos,width,profileMode
	
	Variable n,dim1=0,dim2=1
	WAVE/Z wprofile= root:Packages:NI1_ImProcess:LineProfile:profile
	WAVE/Z profileR= root:Packages:NI1_ImProcess:LineProfile:profileR
	WAVE/Z profileG= root:Packages:NI1_ImProcess:LineProfile:profileG
	WAVE/Z profileB= root:Packages:NI1_ImProcess:LineProfile:profileB
	NVAR isColor=root:Packages:NI1_ImProcess:LineProfile:isColor
			
	// horiz, vertical, fh-horiz, fh-vert, freehand
	if( (profileMode ==1) %| (profileMode==3))
		dim1=1;dim2=0
	endif

	n= DimSize(wsrc, dim2)
	
	if(isColor==0)
		Redimension/D/N=(n) wprofile
		SetScale/P x,DimOffset(wsrc, dim2),DimDelta(wsrc, dim2),WaveUnits(wsrc, dim2),wprofile
	else
		Redimension/D/N=(n) profileR,profileG,profileB
		SetScale/P x,DimOffset(wsrc, dim2),DimDelta(wsrc, dim2),WaveUnits(wsrc, dim2),profileR,profileG,profileB	
	endif
	
	NewDataFolder/O/S NI1_Tmp
	Make/O/N=2 xWave,yWave

	SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	Wave LineProfileY= root:WinGlobals:$(imageGraphName):LineProfileY
	Wave LineProfileX= root:WinGlobals:$(imageGraphName):LineProfileX
	
	// the ImageLineProfile operation works in pixels.  We therefore need to translate
	// between the values in the waves and true pixel numbers.
	Wave w= $NI1_GetImageWave(imageGraphName)

	Variable pmFlag=1							// 22OCT02
	Variable allowSliderControl=0				// 08JAN04
	Variable thePlane=0
	
	if(DimSize(w,2)>4)						// 08JAN04
			thePlane=NI1__GetDisplayed3DPlane(imageGraphName)
			allowSliderControl=1
	endif
	
	switch(profileMode)
		case 1:
			yWave=LineProfileY+pos	 
			yWave-=width/2					// 30OCT00 KD Correction
			// 24AUG01 yWave=(yWave-DimOffset(w,1))/DimDelta(w,1)  
			xWave={DimOffset(wsrc,dim2),DimOffset(wsrc,dim2)+DimDelta(wsrc,dim2)*DimSize(wsrc, dim2)}	// 24AUG01
			// yWave[0], yWave[1]
			// xWave[0], xWave[1]
			// 18JAN02 ImageLineProfile srcWave=wsrc, xWave=xWave, yWave=yWave, width=width/2
			if(allowSliderControl==0)
				ImageLineProfile srcWave=wsrc, xWave=xWave, yWave=yWave, width=width
			else
				ImageLineProfile/P=(thePlane) srcWave=wsrc, xWave=xWave, yWave=yWave, width=width
			endif
		break
		
		case 2:
			xWave=LineProfileX+pos
			xWave-=width/2					// 30OCT00 KD Correction
			// 24AUG01 xWave=(xWave-DimOffset(w,0))/DimDelta(w,0)
			yWave={DimOffset(wsrc,dim2),DimOffset(wsrc,dim2)+DimDelta(wsrc,dim2)*DimSize(wsrc, dim2)}	// 24AUG01
			// yWave[0], yWave[1]
			// xWave[0], xWave[1]
			// 18JAN02 ImageLineProfile srcWave=wsrc, xWave=xWave, yWave=yWave, width=width/2
			if(allowSliderControl==0)
				ImageLineProfile srcWave=wsrc, xWave=xWave, yWave=yWave, width=width
			else
				ImageLineProfile/P=(thePlane) srcWave=wsrc, xWave=xWave, yWave=yWave, width=width
			endif
		break

		
		default:	   // all the freehand modes
			pmFlag=0							// 22OCT02
			SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
			Wave FHLineProfileY= root:WinGlobals:$(imageGraphName):FHLineProfileY
			// 24AUG01 FHLineProfileY=(FHLineProfileY-DimOffset(w,1))/DimDelta(w,1)
			Wave FHLineProfileX= root:WinGlobals:$(imageGraphName):FHLineProfileX
			// 24AUG01 FHLineProfileX=(FHLineProfileX-DimOffset(w,0))/DimDelta(w,0)
			// 23OCT02 added /SC
			if(allowSliderControl==0)
				ImageLineProfile/SC srcWave=wsrc, xWave=FHLineProfileX, yWave=FHLineProfileY, width=width
			else
				ImageLineProfile/P=(thePlane) /SC srcWave=wsrc, xWave=FHLineProfileX, yWave=FHLineProfileY, width=width
			endif
			if(isColor)
				Wave M_ImageLineProfile
				profileR= M_ImageLineProfile[p][0]
				profileG= M_ImageLineProfile[p][1]
				profileB= M_ImageLineProfile[p][2]
			else
				Wave W_ImageLineProfile
				wprofile= W_ImageLineProfile
			endif
	endswitch

	if(pmFlag)							// 22OCT02
		if(isColor)
			Wave M_ImageLineProfile
			profileR= M_ImageLineProfile[p][0]
			SetScale/P x,(DimOffset(wsrc,dim2)),DimDelta(wsrc,dim2),"", profileR
			profileG= M_ImageLineProfile[p][1]
			SetScale/P x,(DimOffset(wsrc,dim2)),DimDelta(wsrc,dim2),"", profileG
			profileB= M_ImageLineProfile[p][2]
			SetScale/P x,(DimOffset(wsrc,dim2)),DimDelta(wsrc,dim2),"", profileB
		else
			Wave W_ImageLineProfile
			wprofile= W_ImageLineProfile
			SetScale/P x,(DimOffset(wsrc,dim2)),DimDelta(wsrc,dim2),"", wprofile
		endif
	endif
	
	KillDataFolder :								// 21AUG01 uncommented this line
												// 09JAN04 remove possible error but report it in history.
	if (GetRTError(0))							// check if there was any runtime error.
		printf "Error in NI1_DoLineProfile:  %s\r", GetRTErrMessage()
		variable dummy=GetRTError(1)		// clear the error so there are no pesky alerts.
	endif

	return 0
End
//*******************************************************************************************************
Function NI1_ImageLineProfileUpdateProc()
	String newImageGraphName= NI1_TopImageGraph()
	SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName

	if( CmpStr(newImageGraphName,imageGraphName)!= 0 )
		NI1_ImageLineProfileNew(newImageGraphName)		
	endif
	imageGraphName= newImageGraphName
End
//*******************************************************************************************************

Function NI1_ImageLineProfileWindowProc(infoStr)
	String infoStr
	
			wave profile=root:Packages:NI1_ImProcess:LineProfile:profile
			wave qvector=root:Packages:NI1_ImProcess:LineProfile:qvector
			wave TwoTheta=root:Packages:NI1_ImProcess:LineProfile:TwoTheta
			wave Dspacing=root:Packages:NI1_ImProcess:LineProfile:Dspacing

	SVAR imageGraphName=root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	if( StrSearch(infoStr,"EVENT:activate",0) >= 0 )
		NI1_ImageLineProfileUpdateProc()
		if(cmpstr(imageGraphName,"SquareMapIntvsPixels")==0)
			Button SaveCurrentLineout, disable=0, win=NI1_ImageLineProfileGraph
			CheckBox DisplayPixles, disable=0, win=NI1_ImageLineProfileGraph
			CheckBox DisplayQvec, disable=0, win=NI1_ImageLineProfileGraph
			CheckBox DisplaydSpacing, disable=0, win=NI1_ImageLineProfileGraph
			CheckBox DisplayTwoTheta, disable=0, win=NI1_ImageLineProfileGraph
			CheckBox DisplayUsingLogScaleX, disable=0, win=NI1_ImageLineProfileGraph
			NVAR DisplayPixles=root:Packages:NI1_ImProcess:LineProfile:DisplayPixles
			NVAR DisplayQvec=root:Packages:NI1_ImProcess:LineProfile:DisplayQvec
			NVAR DisplaydSpacing=root:Packages:NI1_ImProcess:LineProfile:DisplaydSpacing
			NVAR DisplayTwoTheta=root:Packages:NI1_ImProcess:LineProfile:DisplayTwoTheta
			NVAR DisplayUsingLogScaleX=root:Packages:NI1_ImProcess:LineProfile:DisplayUsingLogScaleX
			NI1_CalculateQdTTHwaves()
				
			if(DisplayPixles)
				RemoveFromGraph/W=NI1_ImageLineProfileGraph/Z profile
				AppendToGraph/W=NI1_ImageLineProfileGraph profile
				Label/W=NI1_ImageLineProfileGraph bottom "pixles"
				if(DisplayUsingLogScaleX)
					ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
				endif
				setAxis/W=NI1_ImageLineProfileGraph Bottom NI1_FindFirstLastNotNaNPoint(profile, 1), NI1_FindFirstLastNotNaNPoint(profile, 2)
			elseif(DisplayQvec)
				RemoveFromGraph/W=NI1_ImageLineProfileGraph/Z profile
				AppendToGraph/W=NI1_ImageLineProfileGraph profile vs qvector
				Label/W=NI1_ImageLineProfileGraph bottom "q [1/A]"
				if(DisplayUsingLogScaleX)
					ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
				endif
				setAxis/W=NI1_ImageLineProfileGraph Bottom qvector[NI1_FindFirstLastNotNaNPoint(profile, 1)], qvector[NI1_FindFirstLastNotNaNPoint(profile, 2)]			
			elseif(DisplaydSpacing)
				RemoveFromGraph/W=NI1_ImageLineProfileGraph/Z profile
				AppendToGraph/W=NI1_ImageLineProfileGraph profile vs Dspacing
				Label/W=NI1_ImageLineProfileGraph bottom "d [A]"
				if(DisplayUsingLogScaleX)
					ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
				endif
				setAxis/W=NI1_ImageLineProfileGraph Bottom Dspacing[NI1_FindFirstLastNotNaNPoint(profile, 1)], Dspacing[NI1_FindFirstLastNotNaNPoint(profile, 2)]
			elseif(DisplayTwoTheta)
				RemoveFromGraph/W=NI1_ImageLineProfileGraph/Z profile
				AppendToGraph/W=NI1_ImageLineProfileGraph profile vs TwoTheta
				Label/W=NI1_ImageLineProfileGraph bottom "2 theta [degrees]"
				if(DisplayUsingLogScaleX)
					ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
				endif
				setAxis/W=NI1_ImageLineProfileGraph Bottom TwoTheta[NI1_FindFirstLastNotNaNPoint(profile, 1)], TwoTheta[NI1_FindFirstLastNotNaNPoint(profile, 2)]
			endif
			if(DisplayUsingLogScaleX)
					ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
			else
					ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=0
			endif
		else
			Button SaveCurrentLineout, disable=1, win=NI1_ImageLineProfileGraph
			CheckBox DisplayPixles, disable=1, win=NI1_ImageLineProfileGraph
			CheckBox DisplayQvec, disable=1, win=NI1_ImageLineProfileGraph
			CheckBox DisplaydSpacing, disable=1, win=NI1_ImageLineProfileGraph
			CheckBox DisplayTwoTheta, disable=1, win=NI1_ImageLineProfileGraph
			CheckBox DisplayUsingLogScaleX, disable=1, win=NI1_ImageLineProfileGraph
			RemoveFromGraph/W=NI1_ImageLineProfileGraph/Z profile
			AppendToGraph/W=NI1_ImageLineProfileGraph profile
			Label/W=NI1_ImageLineProfileGraph bottom "pixles"
			ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=0
			setAxis/W=NI1_ImageLineProfileGraph /A
		endif
		return 1
	endif
	if( StrSearch(infoStr,"EVENT:kill",0) >= 0 )				// 09JAN04 do some cleanup here:
			// if you want to automatically remove the blue lines when the window is closed, uncomment the next line.
			NI1_ImLineProfRemoveButtonProc("")
			imageGraphName=""
			SetFormula root:Packages:NI1_ImProcess:LineProfile:lineProfileDummy,""
		return 1
	endif
	SVAR imageGraphName=root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	if(cmpstr(imageGraphName,"SquareMapIntvsPixels")==0)
		NI1_SquareGraphCheckProc("test",0)
	endif
	return 0
End
//*******************************************************************************************************
//*******************************************************************************************************
Function NI1_UpdateLineProfileGraph()

			SVAR imageGraphName=root:Packages:NI1_ImProcess:LineProfile:imageGraphName
			wave profile=root:Packages:NI1_ImProcess:LineProfile:profile
			wave qvector=root:Packages:NI1_ImProcess:LineProfile:qvector
			wave TwoTheta=root:Packages:NI1_ImProcess:LineProfile:TwoTheta
			wave Dspacing=root:Packages:NI1_ImProcess:LineProfile:Dspacing
		if(cmpstr(imageGraphName,"SquareMapIntvsPixels")==0)
			Button SaveCurrentLineout, disable=0, win=NI1_ImageLineProfileGraph
			CheckBox DisplayPixles, disable=0, win=NI1_ImageLineProfileGraph
			CheckBox DisplayQvec, disable=0, win=NI1_ImageLineProfileGraph
			CheckBox DisplaydSpacing, disable=0, win=NI1_ImageLineProfileGraph
			CheckBox DisplayTwoTheta, disable=0, win=NI1_ImageLineProfileGraph
			CheckBox DisplayUsingLogScaleX, disable=0, win=NI1_ImageLineProfileGraph
			NVAR DisplayPixles=root:Packages:NI1_ImProcess:LineProfile:DisplayPixles
			NVAR DisplayQvec=root:Packages:NI1_ImProcess:LineProfile:DisplayQvec
			NVAR DisplaydSpacing=root:Packages:NI1_ImProcess:LineProfile:DisplaydSpacing
			NVAR DisplayTwoTheta=root:Packages:NI1_ImProcess:LineProfile:DisplayTwoTheta
			NVAR DisplayUsingLogScaleX=root:Packages:NI1_ImProcess:LineProfile:DisplayUsingLogScaleX
			NI1_CalculateQdTTHwaves()
				
			if(DisplayPixles)
				RemoveFromGraph/W=NI1_ImageLineProfileGraph/Z profile
				AppendToGraph/W=NI1_ImageLineProfileGraph profile
				Label/W=NI1_ImageLineProfileGraph bottom "pixles"
				if(DisplayUsingLogScaleX)
					ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
				endif
				setAxis/W=NI1_ImageLineProfileGraph Bottom NI1_FindFirstLastNotNaNPoint(profile, 1), NI1_FindFirstLastNotNaNPoint(profile, 2)
			elseif(DisplayQvec)
				RemoveFromGraph/W=NI1_ImageLineProfileGraph/Z profile
				AppendToGraph/W=NI1_ImageLineProfileGraph profile vs qvector
				Label/W=NI1_ImageLineProfileGraph bottom "q [1/A]"
				if(DisplayUsingLogScaleX)
					ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
				endif
				setAxis/W=NI1_ImageLineProfileGraph Bottom qvector[NI1_FindFirstLastNotNaNPoint(profile, 1)], qvector[NI1_FindFirstLastNotNaNPoint(profile, 2)]			
			elseif(DisplaydSpacing)
				RemoveFromGraph/W=NI1_ImageLineProfileGraph/Z profile
				AppendToGraph/W=NI1_ImageLineProfileGraph profile vs Dspacing
				Label/W=NI1_ImageLineProfileGraph bottom "d [A]"
				if(DisplayUsingLogScaleX)
					ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
				endif
				setAxis/W=NI1_ImageLineProfileGraph Bottom Dspacing[NI1_FindFirstLastNotNaNPoint(profile, 1)], Dspacing[NI1_FindFirstLastNotNaNPoint(profile, 2)]
			elseif(DisplayTwoTheta)
				RemoveFromGraph/W=NI1_ImageLineProfileGraph/Z profile
				AppendToGraph/W=NI1_ImageLineProfileGraph profile vs TwoTheta
				Label/W=NI1_ImageLineProfileGraph bottom "2 theta [degrees]"
				if(DisplayUsingLogScaleX)
					ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
				endif
				setAxis/W=NI1_ImageLineProfileGraph Bottom TwoTheta[NI1_FindFirstLastNotNaNPoint(profile, 1)], TwoTheta[NI1_FindFirstLastNotNaNPoint(profile, 2)]
			endif
			if(DisplayUsingLogScaleX)
					ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=1
			else
					ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=0
			endif
		else
			RemoveFromGraph/W=NI1_ImageLineProfileGraph/Z profile
			AppendToGraph/W=NI1_ImageLineProfileGraph profile
			Label/W=NI1_ImageLineProfileGraph bottom "pixles"
			ModifyGraph/W=NI1_ImageLineProfileGraph log(bottom)=0
			setAxis/W=NI1_ImageLineProfileGraph /A
		endif
		return 1

end
	

// makes a permanent copy of the current profile, graphs (or appends)
// and sets the wave note to include info about the trace
// Adds a tag to trace with info about the trace (but the tag is often outside the graph)
//
Function NI1_ImageLineProfileCheckpoint()

	NVAR profileMode= root:Packages:NI1_ImProcess:LineProfile:profileMode
	NVAR width= root:Packages:NI1_ImProcess:LineProfile:width
	NVAR position= root:Packages:NI1_ImProcess:LineProfile:position
	SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	Wave/Z profile=root:Packages:NI1_ImProcess:LineProfile:profile
	Wave/Z profileR=root:Packages:NI1_ImProcess:LineProfile:profileR
	Wave/Z profileG=root:Packages:NI1_ImProcess:LineProfile:profileG
	Wave/Z profileB=root:Packages:NI1_ImProcess:LineProfile:profileB
	NVAR NI1_LP_checkpoint= root:WinGlobals:$(imageGraphName):NI1_LP_checkpoint
	NVAR isColor=root:Packages:NI1_ImProcess:LineProfile:isColor
	
	NI1_LP_checkpoint += 1							// start at 1

	WAVE/Z w= $NI1_GetImageWave(imageGraphName)			// the target matrix

	if( WaveExists(w)==0 )									// sanity check
		return 0
	endif
	
	if(!isColor)
		if(WaveExists(profile)==0)
			return 0
		endif
	else
		if(WaveExists(profileR)*WaveExists(profileG)*WaveExists(profileB)==0)
			return 0
		endif
	endif
	
	String profName= NameOfWave(w)+"_Prof"+num2str(NI1_LP_checkpoint)
	String cpGrfName= imageGraphName+"_Prof"
	
	String dfSav= GetDataFolder(1)
	SetDataFolder $GetWavesDataFolder(w,1)
	if(!isColor)
		Duplicate/O profile,$profName						// this might be just the red part in case of color.
	else	
		Duplicate/O profileR, $profName+"R"
		Duplicate/O profileG, $profName+"G"
		Duplicate/O profileB, $profName+"B"
		
		Wave wr=$profName+"R"
		Wave wg=$profName+"G"
		Wave wb=$profName+"B"
	endif

	if(profileMode>2)
		String profNamex=profName+"_x"
		if(profileMode==3)
			Wave W_LineProfileX=root:Packages:NI1_ImProcess:LineProfile:W_LineProfileX
			Duplicate/O W_LineProfileX,$profNamex
		else
			if(profileMode==4)
				Wave W_LineProfileY=root:Packages:NI1_ImProcess:LineProfile:W_LineProfileY
				Duplicate/O W_LineProfileY,$profNamex
			endif
		endif
	endif
		
	Wave/Z pw= $profName							// 21FEB03
	
	SetDataFolder dfSav
	
	String wnote
	sprintf wnote,"HORIZ:%d;WIDTH:%d;POSITION:%d;",profileMode,width,position
	if(!isColor)
		Note pw,wnote
	else
		Note wr,wnote
	endif

	// now prepare a note string suitable for a tag
	String dimName= ""
	String Sposition=""
	do
		if( profileMode==1 )
			dimName= "Column"
			sposition=num2str(position)
			break
		endif
		if( profileMode==2 )
			dimName= "Row"
			sposition=num2str(position)
			break
		endif
		if( profileMode==3 )
			dimName= "FH-Horizontal"
			break
		endif
		if( profileMode==4 )
			dimName= "FH-Vertical"
			break
		endif
		if( profileMode==5 )
			dimName= "FH"
			break
		endif
	while(0)
	
	if(DimSize(w,2)>4)						// 08JAN04
		Variable thePlane=NI1__GetDisplayed3DPlane(imageGraphName)
		sprintf wnote,"profile #%d of %s. Layer=%d\r%s %s,width= %d",NI1_LP_checkpoint,NameOfWave(w),thePlane,dimName,Sposition,width
	else
		sprintf wnote,"profile #%d of %s.\r%s %s,width= %d",NI1_LP_checkpoint,NameOfWave(w),dimName,Sposition,width
	endif

	
	DoWindow/F $cpGrfName
	
	if(isColor)
		string greenName=profName+"G"
		string blueName=profName+"B"
	endif
	
	if(! V_Flag )
		if( (profileMode<3) %| (profileMode==5))
			if(!isColor)
				Display pw
			else
				Display wr,wg,wb
			endif
		else
			if(!isColor)
				Display pw vs $profNamex
			else
				Display wr,wg,wb vs $profNamex
			endif
		endif
		
		DoWindow/C $cpGrfName
		if(isColor)
			ModifyGraph/W=$cpGrfName  rgb($greenName)=(0,65535,0),rgb($blueName)=(0,0,65535)
		endif
	else
		if( (profileMode<3) %| (profileMode==5))
			if(!isColor)
				AppendToGraph pw
			else
				AppendToGraph wr,wg,wb
			endif
		else
			if(!isColor)
				AppendToGraph pw vs	$profNamex
			else
				AppendToGraph wr,wg,wb  vs$profNamex		
			endif
		endif
		if(isColor)
			ModifyGraph/W=$cpGrfName  rgb($greenName)=(0,65535,0),rgb($blueName)=(0,0,65535)
		endif
	endif
	
	if(!isColor)
		WaveStats/Q pw
		Tag/A=LB $profName,V_maxloc,wnote
	endif
End
//*******************************************************************************************************

Function NI1_ImLineProfileModeProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	Variable/G root:Packages:NI1_ImProcess:LineProfile:profileMode=popNum	
	SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	NVAR isColor=root:Packages:NI1_ImProcess:LineProfile:isColor
	NVAR oldProfileMode= root:Packages:NI1_ImProcess:LineProfile:oldProfileMode
	
	oldProfileMode=-1		// to force an update even if  it is the same item
	
	if(strlen(imageGraphName)<=0)
		// this could happen after Remove
		NI1_ImageLineProfileUpdateProc()
	endif
	
	NVAR NI1_LP_profileMode= root:WinGlobals:$(imageGraphName):NI1_LP_profileMode
	NI1_LP_profileMode= popNum

	NI1_UpdatePositionAndWidth(1)				// 1
	
	if(popNum>2)								// Freehand modes have an additional panel
		NI1_PrepareFHPathProfilePanel()		// must be done after the two lines above because they bring the image to the front
	else
		NI1_ClearFHTraces()
	endif
	
	// now make sure the graph displays what we want
	String cdf=GetDataFolder(1)
	SetDataFolder root:Packages:NI1_ImProcess:LineProfile
	
	Wave/Z profile=root:Packages:NI1_ImProcess:LineProfile:profile
	Wave/Z profileR=root:Packages:NI1_ImProcess:LineProfile:profileR
	Wave/Z profileG=root:Packages:NI1_ImProcess:LineProfile:profileG
	Wave/Z profileB=root:Packages:NI1_ImProcess:LineProfile:profileB
	if(isColor==0)
		RemoveFromGraph/Z/W=NI1_ImageLineProfileGraph/Z profile
	else
		RemoveFromGraph/Z/W=NI1_ImageLineProfileGraph/Z profileR,profileG,profileB
	endif
	
	switch(popNum)
		case 1:
		case 2:
			if(isColor==0)
				AppendToGraph/W=NI1_ImageLineProfileGraph profile
			else
				AppendToGraph/W=NI1_ImageLineProfileGraph profileR,profileG,profileB			
				ModifyGraph/W=NI1_ImageLineProfileGraph  rgb(profileG)=(0,65535,0),rgb(profileB)=(0,0,65535)
			endif
			break
		break
		
		case 3:	
			Wave/Z W_LineProfileX
			if(WaveExists(W_LineProfileX)==0)
				Make/O/N=(DimSize($NI1_GetImageWave(imageGraphName) ,0)) W_LineProfileX=x
			endif
			if(isColor==0)
				AppendToGraph/W=NI1_ImageLineProfileGraph profile vs W_LineProfileX
			else
				AppendToGraph/W=NI1_ImageLineProfileGraph profileR,profileG,profileB vs W_LineProfileX		
				ModifyGraph/W=NI1_ImageLineProfileGraph  rgb(profileG)=(0,65535,0),rgb(profileB)=(0,0,65535)
			endif
			DoWindow/F NI1_FHPathProfilePanel
		break
		
		case 4:
			Wave/Z W_LineProfileY
			if(WaveExists(W_LineProfileY)==0)
				Make/O/N=(DimSize($NI1_GetImageWave(imageGraphName) ,1)) W_LineProfileY=x
			endif
			if(isColor==0)
				AppendToGraph/W=NI1_ImageLineProfileGraph profile vs W_LineProfileY
			else
				AppendToGraph/W=NI1_ImageLineProfileGraph profileR,profileG,profileB vs W_LineProfileY		
				ModifyGraph/W=NI1_ImageLineProfileGraph  rgb(profileG)=(0,65535,0),rgb(profileB)=(0,0,65535)
			endif
			DoWindow/F NI1_FHPathProfilePanel
		break
		
		case 5:
			AppendToGraph/W=NI1_ImageLineProfileGraph profile		// just the profile without location info
			
			if(exists("ModifySurfer")!=4)								// make sure the surface plotter is around
				break
			endif
			
			if(WaveExists(W_LineProfileY)==0)
				Make/O/N=(numpnts(profile)) W_LineProfileY=x
			else
				Wave W_LineProfileY=W_LineProfileY
				Redimension/N=(numpnts(profile)) W_LineProfileY
			endif
			if(WaveExists(W_LineProfileX)==0)
				Make/O/N=(numpnts(profile)) W_LineProfileX=x
			else
				Wave W_LineProfileX=W_LineProfileX
				Redimension/N=(numpnts(profile)) W_LineProfileX
			endif
			Execute "CreateSurfer;"+"ModifySurfer srcwave=(W_LineProfileX,W_LineProfileY,profile), srctype=4,update=1"
			Execute "ModifySurfer plotType=6,marker=8,markersize=2"
			DoWindow/F NI1_FHPathProfilePanel
		break
	endswitch
	
	//	update the buttons depending on the mode
	if(popNum<3)
		NI1_updateStartEndButtons(0)
	else
		NI1_updateStartEndButtons(1)
	endif
	
	SetDataFolder cdf
End
//*******************************************************************************************************
Function NI1_ImLineProfWidthSetVarProc(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	NI1_UpdatePositionAndWidth(0)		// 2
End
//*******************************************************************************************************
//
//Function NI1_ImLineProfileCPButtonProc(ctrlName) : ButtonControl
//	String ctrlName
//
//	NI1_ImageLineProfileCheckpoint()
//End
//*******************************************************************************************************

Function NI1_ImLineProfRemoveButtonProc(ctrlName) : ButtonControl
	String ctrlName

	SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	WAVE/Z profile= root:Packages:NI1_ImProcess:LineProfile:profile
	WAVE/Z profileR= root:Packages:NI1_ImProcess:LineProfile:profileR
	WAVE/Z profileG= root:Packages:NI1_ImProcess:LineProfile:profileG
	WAVE/Z profileB= root:Packages:NI1_ImProcess:LineProfile:profileB
	NVAR isColor=root:Packages:NI1_ImProcess:LineProfile:isColor
	NVAR profileMode= root:Packages:NI1_ImProcess:LineProfile:profileMode
	
	SetFormula root:Packages:NI1_ImProcess:LineProfile:lineProfileDummy,""
	 
	 if(!isColor)
		profile= 0
	else
		profileR=0
		profileG=0
		profileB=0
	endif
	
	if(strlen(imageGraphName)>0)
		SetWindow kwTopWin,hook=$""
		DoWindow/F $imageGraphName
		RemoveFromGraph/Z LineProfileY,FHLineProfileY
		KillDataFolder root:WinGlobals:$(imageGraphName)
		DoWindow/F NI1_ImageLineProfileGraph		// this be us
		DoUpdate									// don't let following fire
		SetWindow kwTopWin,hook=NI1_ImageLineProfileWindowProc
		NI1_ImageLineProfileWindowProc("EVENT:activate")
		imageGraphName= ""

		if(profileMode>2)
			NI1_updateStartEndButtons(0)
		endif
		
		if(profileMode==5)
			// close the surface plotter so we don't have to worry about wave contents.
			Execute "Getsurfer surfernamelist"			// test if the surfer is open
			SVAR S_SurferNames=S_SurferNames
			if(strlen(S_SurferNames)>0)
				Execute "ModifySurfer Quit"
			endif
			KillStrings S_SurferNames					// local cleanup.
		endif
	else
		beep	// trying to remove something that does not exist.
	endif
End

//*******************************************************************************************************
Function NI1_PrepareFHPathProfilePanel()	

	SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	Wave FHLineProfileY= root:WinGlobals:$(imageGraphName):FHLineProfileY
	Wave FHLineProfileX= root:WinGlobals:$(imageGraphName):FHLineProfileX
	Wave w= $NI1_GetImageWave(imageGraphName)	
	DoWindow/F $imageGraphName
	
	// before we try to append the waves to the image, check if they are not already there:
	CheckDisplayed/W=$imageGraphName FHLineProfileY
	if(V_Flag==0)
		String imax= StringByKey("AXISFLAGS",ImageInfo(imageGraphName, NameOfWave(w), 0))+" "
		Execute "AppendToGraph "+imax+ GetWavesDataFolder(FHLineProfileY,2)+" vs "+GetWavesDataFolder(FHLineProfileX,2)
	endif

	NI1_SetFHDependency()
End
//*******************************************************************************************************
Function NI1_SetFHDependency()
	SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	String cdf= GetDataFolder(1)
	SetDataFolder root:Packages:NI1_ImProcess:LineProfile
	Variable/G lineProfileDummy
	String s="NI1_FHLineProfileDependency(root:WinGlobals:"+imageGraphName+":FHLineProfileY"+",root:WinGlobals:"+imageGraphName+":FHLineProfileX)"
	SetFormula lineProfileDummy,s
	SetDataFolder cdf
End
//*******************************************************************************************************
Function NI1_FinishFHPathProfile(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR curImageName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	String origImageName=StrVarOrDefault("root:Packages:NI1_ImProcess:LineProfile:editingTarget",curImageName)
	
	if(strlen(origImageName)>0)
		DoWindow/F 	$origImageName
		GraphNormal
	endif
	SetFormula root:Packages:NI1_ImProcess:LineProfile:lineProfileDummy,""
End
//*******************************************************************************************************

Function NI1_StartEditingPathProfile(ctrlName) : ButtonControl
	String ctrlName
	
	SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	String/G	root:Packages:NI1_ImProcess:LineProfile:editingTarget=imageGraphName
	
	NI1_SetFHDependency()		// in case the user wants to re-edit
	DoWindow/F 	$imageGraphName

	// now check to see if this is a new image, in which case we need to append the wave
	Wave FHLineProfileY= root:WinGlobals:$(imageGraphName):FHLineProfileY
	CheckDisplayed/W=$imageGraphName FHLineProfileY
	
	if(V_Flag==0)
		NI1_PrepareFHPathProfilePanel()
	endif
	
	GraphWaveEdit  FHLineProfileY
End

//*******************************************************************************************************
Function NI1_FHLineProfileDependency(ywave,xwave)
	wave ywave,xwave

	NVAR profileMode= root:Packages:NI1_ImProcess:LineProfile:profileMode
	NVAR width= root:Packages:NI1_ImProcess:LineProfile:width
	SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	Wave FHLineProfileY= root:WinGlobals:$(imageGraphName):FHLineProfileY
	Wave FHLineProfileX= root:WinGlobals:$(imageGraphName):FHLineProfileX
	WAVE/Z profile= root:Packages:NI1_ImProcess:LineProfile:profile
	NewDataFolder/O/S NI1_tmp
	
	Wave src=$NI1_GetImageWave(imageGraphName)

	// 08JAN04
	Variable allowSliderControl=0
	Variable thePlane=0
	
	if(DimSize(src,2)>4)						// 08JAN04
		thePlane=NI1__GetDisplayed3DPlane(imageGraphName)
		allowSliderControl=1
	endif
	
	// in case the horrid wave scaling is used.
	// 23AUG01 Duplicate/O FHLineProfileY, ty
	// 23AUG01 Duplicate/O FHLineProfileX,tx

	// 23AUG01 ty=(FHLineProfileY-DimOffset(src,1))/DimDelta(src,1)
	// 23AUG01 tx=(FHLineProfileX-DimOffset(src,0))/DimDelta(src,0)
	if(allowSliderControl==0)
		if(profileMode!=5)		// 23OCT02
			ImageLineProfile srcWave=src, xWave=FHLineProfileX, yWave=FHLineProfileY, width=width
		else
			ImageLineProfile/SC srcWave=src, xWave=FHLineProfileX, yWave=FHLineProfileY, width=width
		endif
	else							// 08JAN04
		if(profileMode!=5)	
			ImageLineProfile/P=(thePlane) srcWave=src, xWave=FHLineProfileX, yWave=FHLineProfileY, width=width
		else
			ImageLineProfile/P=(thePlane)/SC srcWave=src, xWave=FHLineProfileX, yWave=FHLineProfileY, width=width
		endif
	endif
	
	// 23AUG01 KillWaves/Z tx,ty
	Wave W_LineProfileX=W_LineProfileX			// 22OCT02
	Wave W_LineProfileY=W_LineProfileY			// 22OCT02
	Wave tLineProfileX=W_LineProfileX			// 22OCT02
	Wave tLineProfileY=W_LineProfileY			// 22OCT02
	Duplicate/O W_LineProfileX,root:Packages:NI1_ImProcess:LineProfile:W_LineProfileX
	Duplicate/O W_LineProfileY,root:Packages:NI1_ImProcess:LineProfile:W_LineProfileY
	Wave wout= W_ImageLineProfile
	
	NVAR isColor=root:Packages:NI1_ImProcess:LineProfile:isColor
	if(!isColor)
		Duplicate/O wout,root:Packages:NI1_ImProcess:LineProfile:profile
	else
		Wave mw=M_ImageLineProfile
		String oldDF=GetDataFolder(1)
		SetDataFolder root:Packages:NI1_ImProcess:LineProfile 
		Variable len=DimSize(mw,0)
		Make/O/N=(len) profileR,profileG,profileB
		profileR=mw[p][0]
		profileG=mw[p][1]
		profileB=mw[p][2]
		// 22OCT02
		if(profileMode==5)
			Variable wSize=DimSize(profileR,0)
			Make/O/N=(3*wSize+2) profile
			// fill the three waves into a single path wave with NaN separation
			NI1__fillWaveWithThreeWaves(profile,profileR,profileG,profileB)
			Wave W_LineProfileX=root:Packages:NI1_ImProcess:LineProfile:W_LineProfileX
			Wave W_LineProfileY=root:Packages:NI1_ImProcess:LineProfile:W_LineProfileY
			Wave/Z M_PathColorWave=root:Packages:NI1_ImProcess:LineProfile:M_PathColorWave
			NI1__fillWaveWithThreeWaves(W_LineProfileX,tLineProfileX,tLineProfileX,tLineProfileX)
			NI1__fillWaveWithThreeWaves(W_LineProfileY,tLineProfileY,tLineProfileY,tLineProfileY)
			if(WaveExists(M_PathColorWave)==0)
				Make/O/N=(wSize,3) M_PathColorWave
			endif
			NI1__MakeSurferPathColorWave(M_PathColorWave,wSize)
			Execute "ModifySurfer pathRGBWave=M_PathColorWave"
		endif
		SetDataFolder oldDF
	endif
	
	if(profileMode==5)
		WAVE/Z profile= root:Packages:NI1_ImProcess:LineProfile:profile
		profile+=0;		// just to make the surface plotter update if it is already open.
		DoXOPIdle
	endif
	
	KillDataFolder :								// 15FEB02
	return 0
End
//*******************************************************************************************************
Function NI1__MakeSurferPathColorWave(M_PathColorWave,wSize)
	Wave M_PathColorWave
	Variable wSize
	
	Redimension/N=(3*wSize+2,3) M_PathColorWave
	Variable i,wSize1=wSize+1,wSize2=2*wSize+2

	M_PathColorWave=0
	
	for(i=0;i<wSize;i+=1)
		M_PathColorWave[i][0]=65535				// red
		M_PathColorWave[i+wSize1][1]=65535		// green
		M_PathColorWave[i+wSize2][2]=65535		// blue
	endfor
	
End
//*******************************************************************************************************
Function NI1__fillWaveWithThreeWaves(w0,w1,w2,w3)
	Wave w0,w1,w2,w3
	
	Variable d1=DimSize(w1,0)
	Variable d2=DimSize(w2,0)
	Variable d3=DimSize(w3,0)
	Variable wSize=d1+d2+d3+2
	
	Redimension/N=(wSize) w0
	w0[0,d1]=w1[p]
	w0[d1]=NaN
	d1+=1
	w0[d1,d1+d2]=w2[p-d1]
	d1+=d2
	w0[d1]=NaN
	d1+=1
	w0[d1,d1+d3]=w3[p-d1]
End

//*******************************************************************************************************
Function NI1_updateStartEndButtons(turnOn)
	Variable turnOn
	
	DoWindow/F NI1_ImageLineProfileGraph		// make sure the buttons are on the right graph
	if(turnOn)
		Button startPathProfileButton,pos={4,34},size={130,20},proc=NI1_StartEditingPathProfile,title="Start Editing Path"
		Button startPathProfileButton,help={"After clicking in this button edit the path drawn on the top image.  Click in the Finished button when you are done."}
		Button finishPathProfileButton,pos={140,34},size={130,20},proc=NI1_FinishFHPathProfile,title="Finished Editing"
		Button finishPathProfileButton,help={"Click in this button to terminate the path editing mode."}
	else
		KillControl startPathProfileButton
		KillControl finishPathProfileButton
	Endif
End
//*******************************************************************************************************
Function NI1_ClearFHTraces()

	SVAR imageGraphName= root:Packages:NI1_ImProcess:LineProfile:imageGraphName
	DoWindow/F $imageGraphName
	RemoveFromGraph/Z  FHLineProfileY
	imageGraphName= ""						// vip to get initializations right
End
//*******************************************************************************************************
//Function NI1_minWave(w,d)
//	Wave w
//	Variable d
//	
//	if(DimDelta(w,d)>0)
//		return DimOffset(w,d)
//	endif
//	
//	return DimOffset(w,d)+DimSize(w,d)*DimDelta(w,d)
//End
//
////*******************************************************************************************************
//Function NI1_maxWave(w,d)
//	Wave w
//	Variable d
//	
//	if(DimDelta(w,d)<0)
//		return DimOffset(w,d)
//	endif
//	
//	return DimOffset(w,d)+DimSize(w,d)*DimDelta(w,d)
//End
//
//Function NI1_printwaves(wa,wb)
//	Wave wa,wb
//	
//	Variable i
//	for(i=0;i<Dimsize(wa,0);i+=1)
//		print wa[i],wb[i]
//	endfor
//End
//*******************************************************************************************************
// 09JAN03
// Given a name of an image e.g., "graph0", the following function returns the plane displayed in the
// graph.  If the image is a 2D image or if the image is an RGB image, the function returns 0.
Function NI1__GetDisplayed3DPlane(graphName)
	String graphName
	
	Wave w=$NI1_GetImageWave(graphName)
	String info=ImageInfo(graphName,NameOfWave(w),0)
	String sub=info[strSearch(info,"plane",0),strlen(info)]
	
	return NumberByKey("plane", sub, "=")
End

//*******************************************************************************************************

Function/S NI1_TopImageGraph()

	String grfName
	Variable i=0
	do
		grfName= WinName(i, 1)
		if( strlen(grfName) == 0 )
			break
		endif
		if( strlen( ImageNameList(grfName, ";")) != 0 )
			break
		endif
		i += 1
	while(1)
	return grfName
end		
// This routine is used to fetch a full path to the image wave in the top
// graph. A zero length string is returned if failure.
//
Function/S NI1_GetImageWave(grfName)
	String grfName							// use zero len str to speicfy top graph

	String s= ImageNameList(grfName, ";")
	Variable p1= StrSearch(s,";",0)
	if( p1<0 )
		return ""			// no image in top graph
	endif
	s= s[0,p1-1]
	Wave w= ImageNameToWaveRef(grfName, s)
	return GetWavesDataFolder(w,2)		// full path to wave including name
end
// the following function returns 1 if the wave is valid and contains 3 planes.
Function NI1_isColorWave(ww)
	Wave/Z ww
	
	if(WaveExists(ww)==0)
		return 0
	endif
	
	if(DimSize(ww,2)==3)
		return 1
	endif
	return 0;
End

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
		//NVAR LineProf_LineAzAngle=root:Packages:Convert2Dto1D:LineProf_LineAzAngle
		NVAR LineProf_LineAzAngleG =root:Packages:Convert2Dto1D:LineProf_LineAzAngle
		variable LineProf_LineAzAngle
		LineProf_LineAzAngle = LineProf_LineAzAngleG>=0 ? LineProf_LineAzAngleG : LineProf_LineAzAngleG+180
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
			MatrixOp/O MaskedQ2DWave = CCDImageToConvert *( M_ROIMask/M_ROIMask)
		else
			MatrixOp/O MaskedQ2DWave = CCDImageToConvert
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
		ImageLineProfile/S xWave=ywave, yWave=xwave, srcwave=MaskedQ2DWave , width= LineProf_Width				//why is here xwave and ywave swapped? ANy reason (5-3-2022)
		Wave W_LineProfileX = root:Packages:Convert2Dto1D:W_LineProfileX
		Wave W_LineProfileY = root:Packages:Convert2Dto1D:W_LineProfileY
		Wave W_ImageLineProfile = root:Packages:Convert2Dto1D:W_ImageLineProfile
		Wave W_LineProfileStdv=root:Packages:Convert2Dto1D:W_LineProfileStdv
		NVAR UseBatchProcessing=root:Packages:Convert2Dto1D:UseBatchProcessing
		wavestats/Q W_LineProfileStdv
		if(V_numNaNs>(V_npnts/5))		//more than 20% of NaNs , this will not work righ, repalce with stdDev
			Print "NOTE: Too many NaNs in error calculations. Intensity error in this case is calculated as square root of intensity, which may be WRONG."
			W_LineProfileStdv=sqrt(W_ImageLineProfile)
		else	
			if(LineProf_Width<2)
				Print "NOTE: Width used for line profile is less than 2 points. Intensity error in this case is calculated as square root of intensity, which may be WRONG."
				W_LineProfileStdv=sqrt(W_ImageLineProfile)
			else
				if(ErrorCalculationsUseSEM)
					W_LineProfileStdv/=sqrt(LineProf_Width)
				endif
				if(!UseBatchProcessing)
					Print "NOTE: Width used for line profile is 2 points or more, used standard deviation to estimate intensity error."
				endif
			endif
		endif
		//Now calculate the angle wave for ellipse but calculate for everything...
		Duplicate/O W_ImageLineProfile, LineProfileAzAvalues
		LineProfileAzAvalues = atan2((W_LineProfileY[p]-BeamCenterY),(BeamCenterX - W_LineProfileX[p]))
		LineProfileAzAvalues*=180/pi
		LineProfileAzAvalues+=180
		// end of angle wave creation...
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
		KillWaves/Z MaskedQ2DWave

		//need to fix background oversubtraction here, if requested. 
		NVAR FixBackgroundOversubtraction = root:Packages:Convert2Dto1D:FixBackgroundOversubtraction
		if(FixBackgroundOversubtraction)
			//need to find out minimum of Intensity
			Wavestats/Q/Z LineProfileIntensity
			//V_min is the lowest value we got, likely negative.
			if(V_min<0)	//it is negative
				//add FixBackgroundOversubScale 8 abs(V_min), fix FixBackgroundOversubScale in NI1_Main.ipf
				LineProfileIntensity+=FixBackgroundOversubScale * abs(V_min)
			endif
		endif

		
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
		//and here should be right place to check for error = 0
		//now handling of case where we have error=0, which is possible only if Intensity=0 for each point summed together.  
		LineProfileIntSdev = LineProfileIntSdev[p]>0 ? LineProfileIntSdev[p] : NaN	//for Int=0 we could have error = 0 if all points have 0 intensity, which is degenerate case (bad masking). 
		//and this should clear it up as needed...
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
		//		Wave/Z DSpacingWidth
		//		if(!WaveExists(DSpacingWidth))
		//			abort
		//		endif
		
		Duplicate/O LineProfileQvalues, LineProfiledQvalues, LineProfileTwoThetaWidth, LineProfileDistacneInmmWidth, LineProfileDspacingWidth
		Duplicate/Free LineProfileQvalues, LineProfileTwoTheta, LineProfileDistacneInmm, LineProfileDspacing
		LineProfiledQvalues[0,numpnts(LineProfileQvalues)-2] = LineProfileQvalues[p+1] - LineProfileQvalues[p]
		LineProfiledQvalues[numpnts(LineProfileQvalues)-1]=LineProfiledQvalues[numpnts(LineProfileQvalues)-2]
		LineProfileTwoTheta =  2 * asin ( LineProfileQvalues * constVal) * 180 /pi
		LineProfileTwoThetaWidth[0,numpnts(LineProfileTwoThetaWidth)-2]  = LineProfileTwoTheta[p+1] - LineProfileTwoTheta [p]
		LineProfileTwoThetaWidth[numpnts(LineProfileTwoThetaWidth)-1]=LineProfileTwoThetaWidth[numpnts(LineProfileTwoThetaWidth)-2]
		constVal = 2*pi
		LineProfileDspacing = constVal / LineProfileQvalues
		LineProfileDspacingWidth[0,numpnts(LineProfileDspacingWidth)-2]  = LineProfileDspacing [p] - LineProfileDspacing[p+1]
		LineProfileDspacingWidth[numpnts(LineProfileDspacingWidth)-1]=LineProfileDspacingWidth[numpnts(LineProfileDspacingWidth)-2]
	
		LineProfileDistacneInmm =  SampleToCCDDistance*tan(LineProfileTwoTheta*pi/180)
		LineProfileDistacneInmmWidth[0,numpnts(LineProfileDistacneInmmWidth)-2]  = LineProfileDistacneInmm[p+1] - LineProfileDistacneInmm[p]
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
