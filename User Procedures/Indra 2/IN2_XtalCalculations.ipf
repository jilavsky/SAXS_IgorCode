#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3			// Use modern global access method.
//#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.1


//*************************************************************************\
//* Copyright (c) 2005 - 2023, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

// 1.1	added high energy Mstage2
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************

Function IN2Y_GapCalculations()

	IN2Y_InitializeXtalCalc()			//initialize the folder to work in
	
	Execute ("IN2Y_ChannelCutPosCalculations()")

	IN2Y_CalculatePositions()
end
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************

Window IN2Y_ChannelCutPosCalculations() : Panel
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(287,93,1087,506) as "ChannelCut Position Calculations"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 30,fstyle= 1,textrgb= (65280,0,0)
	DrawText 203,43,"ChannelCut Position Calculations"
	SetDrawEnv linethick= 5,linefgc= (0,0,52224)
	DrawLine 129,53,727,53
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,12800,52224)
	DrawText 12,40,"ax/mx  [mm]:"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 73,353,"X = 0"
	DrawText 15,323,"1 reflection"
	SetDrawEnv fsize= 18
	DrawText 624,289,"Energy/Xtal data :"
	SetDrawEnv linethick= 5,linefgc= (0,0,52224)
	DrawLine 129,342,224,342
	SetDrawEnv linethick= 5,linefgc= (0,0,52224)
	DrawLine 129,52,129,342
	SetDrawEnv linethick= 5,linefgc= (0,0,52224)
	DrawLine 221,344,271,204
	SetDrawEnv linethick= 5,linefgc= (0,0,52224)
	DrawLine 727,51,727,118
	SetDrawEnv linethick= 5,linefgc= (0,0,52224)
	DrawLine 271,204,730,114
	DrawText 9,205,"2 reflections"
	DrawText 9,161,"4 reflections"
	DrawText 9,121,"6 reflections"
	DrawText 9,83,"8 reflections"

	SetDrawEnv linefgc= (65535,0,0),fillpat= 48,fillfgc= (65535,0,0)
	DrawOval 180,305,205,326
	SetDrawEnv linefgc= (65535,0,0),fillpat= 48,fillfgc= (65535,0,0)
	DrawOval 180,187,205,208
	SetDrawEnv linefgc= (65535,0,0),fillpat= 48,fillfgc= (65535,0,0)
	DrawOval 180,142,205,163
	SetDrawEnv linefgc= (65535,0,0),fillpat= 48,fillfgc= (65535,0,0)
	DrawOval 180,102,205,123
	SetDrawEnv linefgc= (65535,0,0),fillpat= 48,fillfgc= (65535,0,0)
	DrawOval 180,66,205,87

	SetDrawEnv linefgc= (65535,0,0),fillpat= 48,fillfgc= (65535,0,0)
	DrawOval 344,66,370,89
	SetDrawEnv linefgc= (65535,0,0),fillpat= 48,fillfgc= (65535,0,0)
	DrawOval 344,142,370,165
	SetDrawEnv linefgc= (65535,0,0),fillpat= 48,fillfgc= (65535,0,0)
	DrawOval 344,102,370,125

	SetDrawEnv linefgc= (65535,0,0),fillpat= 48,fillfgc= (65535,0,0)
	DrawOval 514,65,540,88
	SetDrawEnv linefgc= (65535,0,0),fillpat= 48,fillfgc= (65535,0,0)
	DrawOval 514,101,540,124

	SetDrawEnv linefgc= (65535,0,0),fillpat= 48,fillfgc= (65535,0,0)
	DrawOval 684,64,710,87

	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 100,197,190,197
	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 100,153,190,153
	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 100,113,190,113
	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 100,316,190,316
	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 100,77,190,77

	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 185,153,362,153
	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 185,114,362,114
	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 185,78,362,78

	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 360,113,532,113
	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 360,77,532,77
	
	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 529,76,700,76
	SetVariable BraggAngle,pos={532,377},size={250,22},proc=IN2Y_XtalCalculations,title="Bragg Angle [degrees]"
	SetVariable BraggAngle,fSize=14,format="%3.2f"
	SetVariable BraggAngle,limits={1,50,0.1},value= root:Packages:XtalCalc:BraggAngle
	SetVariable Gapsetting,pos={262,330},size={200,22},proc=IN2Y_XtalCalculations,title="Gap [mm]             "
	SetVariable Gapsetting,fSize=14,value= root:Packages:XtalCalc:Gapsetting
	SetVariable xpos2Min,pos={50,207},size={70,15},title=" ",format="%3.2f"
	SetVariable xpos2Min,limits={-inf,inf,0},value= root:Packages:XtalCalc:Pos2refStart
	SetVariable xpos2Max,pos={50,169},size={70,15},title=" ",format="%3.2f"
	SetVariable xpos2Max,limits={-inf,inf,0},value= root:Packages:XtalCalc:Pos4refStart
	SetVariable xpos4Max,pos={50,127},size={70,15},title=" ",format="%3.2f"
	SetVariable xpos4Max,limits={-inf,inf,0},value= root:Packages:XtalCalc:Pos6refStart
	SetVariable xpos6Max,pos={50,88},size={70,15},title=" ",format="%3.2f"
	SetVariable xpos6Max,limits={-inf,inf,0},value= root:Packages:XtalCalc:Pos8refStart
	SetVariable xpos8Max,pos={50,47},size={70,15},title=" ",format="%3.2f"
	SetVariable xpos8Max,limits={-inf,inf,0},value= root:Packages:XtalCalc:Pos8refEnd
	PopupMenu HKLSelection,pos={622,305},size={160,21},proc=IN2Y_PopProcedure,title="Si Xtal HKL  : "
	PopupMenu HKLSelection,fSize=16
	PopupMenu HKLSelection,mode=WhichListItem(root:Packages:XtalCalc:XtalHKL,"111;220;311;331;333;440;660;")+1,value= #"\"111;220;311;331;333;440;660;\""
	PopupMenu StageSelection,pos={288,284},size={174,21},proc=IN2Y_PopProcedure,title="Xtal Stage  : "
	PopupMenu StageSelection,fSize=16
	PopupMenu StageSelection,mode=WhichListItem(root:Packages:XtalCalc:XtalStage,"Astage;Mstage;Mstage2;")+1,value= #"\"Astage;Mstage;Mstage2;\""
	SetVariable Energy,pos={582,337},size={200,22},proc=IN2Y_XtalCalculations,title="Energy  [keV] :"
	SetVariable Energy,fSize=14
	SetVariable Energy,limits={6,60,0.05},value= root:Packages:XtalCalc:Energy
//	SetVariable Yoffset,pos={312,364},size={150,15},disable=2,proc=IN2Y_XtalCalculations,title="Vertical offset [mm]:"
//	SetVariable Yoffset,limits={-inf,inf,0.1},value= root:Packages:XtalCalc:ChannelCutYOffset
EndMacro
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************

Function IN2Y_PopProcedure(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR XtalHKL=root:Packages:XtalCalc:XtalHKL
	SVAR StageSelection = root:Packages:XtalCalc:XtalStage
	if (cmpstr(ctrlName,"HKLSelection")==0)
		XtalHKL=popStr
	endif
	if (cmpstr(ctrlName,"StageSelection")==0)
		StageSelection=popStr
	endif	
	IN2Y_CalculatePositions()
End
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************


Function IN2Y_XtalCalculations(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	IN2Y_CalculatePositions()
End
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************

Function IN2Y_InitializeXtalCalc()

	string OldDf=GetDataFolder(1)
	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:XtalCalc
	
	 NVAR/Z BraggAngle
	 if (NVAR_Exists(BraggAngle)==0)
	 	variable/g BraggAngle=15.61
	 endif

	 NVAR/Z Energy
	 if (NVAR_Exists(Energy)==0)
	 	variable/g Energy=12
	 endif
	 
	 SVAR/Z XtalStage
	 if (SVAR_Exists(XtalStage)==0)
	 	string/g XtalStage="Astage"
	 endif
	 
	 SVAR/Z XtalHKL
	 if (SVAR_Exists(XtalHKL)==0)
	 	string/g XtalHKL="220"
	 endif

	 NVAR/Z Gapsetting
	  if (NVAR_Exists(Gapsetting)==0)
	 	variable/g Gapsetting=5
	 endif

	 NVAR/Z Pos2refStart
	 if (NVAR_Exists(Pos2refStart)==0)
	 	variable/g Pos2refStart
	 endif

	 NVAR/Z Pos4refStart
	 if (NVAR_Exists(Pos4refStart)==0)
	 	variable/g Pos4refStart
	 endif

	 NVAR/Z Pos6refStart
	 if (NVAR_Exists(Pos6refStart)==0)
	 	variable/g Pos6refStart
	 endif

	 NVAR/Z Pos8refStart
	 if (NVAR_Exists(Pos8refStart)==0)
	 	variable/g Pos8refStart
	 endif

	 NVAR/Z Pos8refEnd
	 if (NVAR_Exists(Pos8refEnd)==0)
	 	variable/g Pos8refEnd
	 endif
	 
	 setDataFolder OldDf
end
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************

Function IN2Y_CalculatePositions()

	string OldDf=GetDataFolder(1)
	SetDataFolder root:Packages:XtalCalc
		
		Variable xvalue, xx, i, j
		Variable a_0
		Variable TopXTalLength, M
		Variable x_1, y_1, x_2, y_2, x_3, y_3, x_4, y_4
		Variable TopXtalOffset
		Variable Dspacing 
		variable step
		variable alpha
		Variable wavelength
		variable SubsequentReflectionDistance
		Make /free/N=100 Reale, xval, NB

		SVAR XtalHKL=root:Packages:XtalCalc:XtalHKL
		SVAR XtalStage=root:Packages:XtalCalc:XtalStage
		NVAR Energy=root:Packages:XtalCalc:Energy
		NVAR Gap = root:Packages:XtalCalc:Gapsetting
		NVAR Pos2refStart=root:Packages:XtalCalc:Pos2refStart
		NVAR Pos4refStart=root:Packages:XtalCalc:Pos4refStart
		NVAR Pos6refStart=root:Packages:XtalCalc:Pos6refStart
		NVAR Pos8refStart=root:Packages:XtalCalc:Pos8refStart
		NVAR Pos8refEnd=root:Packages:XtalCalc:Pos8refEnd
		NVAR BraggAngle= root:Packages:XtalCalc:BraggAngle

		if (cmpstr(XtalHKL,"220")==0)
			Dspacing=5.43102088/sqrt(8)		//220 d spacing for Si 	
		elseif (cmpstr(XtalHKL,"311")==0) 		//
			Dspacing=5.43102088/sqrt(11)		//311 d spacing for Si 	
		elseif (cmpstr(XtalHKL,"331")==0) 		//
			Dspacing=5.43102088/sqrt(19)		//331 d spacing for Si 	
		elseif (cmpstr(XtalHKL,"333")==0) 		//
			Dspacing=5.43102088/sqrt(27)		//333 d spacing for Si 	
		elseif (cmpstr(XtalHKL,"440")==0) 		//
			Dspacing=5.43102088/sqrt(32)		//440 d spacing for Si 	
		elseif (cmpstr(XtalHKL,"660")==0) 		//
			Dspacing=5.43102088/sqrt(72)		//660 d spacing for Si 	
		elseif (cmpstr(XtalHKL,"111")==0) 		//
			Dspacing=5.43102088/sqrt(3)		//111 d spacing for Si 
		endif
		wavelength=12.398424437/Energy
		alpha=asin(wavelength/(2*Dspacing))
		BraggAngle=(alpha/pi)*180
		
		if (cmpstr(XtalStage,"Astage")==0)			// We are using the A stage, this describes the geometry of the A stage crystals
			TopXtalOffset=12.5						//top crystal starts offset from first crystal impact position
			TopXTalLength=87.5						//top crystal total length
			x_1=5									//position where the fixed long length ends from long edge in mm
			x_2=25									//end of linearly length changing part of crystal 
			x_3=59									//total x dimension of the A first crystal

			y_2=87.5								//maximum length of first crystal after 	first impact of the beam 					
			y_3=12.5								//minimum length of first crystal after first impact of the beam
			M = (y_3 - y_2)/(x_2 - x_1)				//slope of the crystal	
		elseif ((cmpstr(XtalStage,"Mstage")==0))	// We are using M stage
			TopXtalOffset=0						//top crystal starts offset from first crystal impact position
			TopXTalLength=100						//top crystal total length
			x_1=5									//position where the fixed long length ends from long edge in mm
			x_2=25									//end of linearly length changing part of crystal 
			x_3=34									//total x dimension of the A first crystal

			y_2=100								//maximum length of first crystal after 	first impact of the beam 	
			y_3=15									//minimum length of first crystal after first impact of the beam
			M = (y_3 - y_2)/(x_2 - x_1)				//slope of the crystal
		elseif ((cmpstr(XtalStage,"Mstage2")==0))	// We are using M stage
			TopXtalOffset=10						//top crystal starts offset from first crystal impact position
			TopXTalLength=85						//top crystal total length
			x_1=5									//position where the fixed long length ends from long edge in mm
			x_2=25									//end of linearly length changing part of crystal 
			x_3=34									//total x dimension of the A first crystal

			y_2=100								//maximum length of first crystal after 	first impact of the beam 	
			y_3=15									//minimum length of first crystal after first impact of the beam
			M = (y_3 - y_2)/(x_2 - x_1)				//slope of the crystal
		endif
		
		step=(x_3/numpnts(xval))
		for(i=0;i<numpnts(xval);i+=1)					// Cfreate Real whicih contains available Firsdt crystal length after first beam impact...  
				if (i*step <x_1)							//xval is position in mm starting from the longest edge of the frist crystal
					xval[i] = i* step  					//x position on the crystal from longest edge
					Reale[i] = y_2						//first few mm the crystal is fixed length
				elseif (i*step<x_2)						//here the crystal length is linearly proportional to position
					xval[i] = i*step   					//x position on the crystal from longest edge
					Reale[i] = y_2 + M*(xval[i] - x_1)		//this should get us the length of crystal available, note the M is negative...
				else										//this is the fixed length end which we use for one reflection only...
					xval[i] = i*step   					//x position again
					Reale[i]=y_3						//the fixed length
				endif									//
		endfor	
		SubsequentReflectionDistance=Gap/tan(alpha)		//distance between two subsequent reflections (1st to 2nd etc) between the two crystals										
		NB= Reale / SubsequentReflectionDistance			//number of reflections on first crystal after frist reflection 
															//    (how many times the distance between the reflections on the frist crystal
															//    fits in the length of the first crystal after the first reflection//. 
		//print SubsequentReflectionDistance							//distance between subsequent bounce on first and secodn crystal
		NVAR Pos2refStart=root:Packages:XtalCalc:Pos2refStart		//always start of overlap of the two crystals
		NVAR Pos4refStart=root:Packages:XtalCalc:Pos4refStart		//second impact on first crystal, NB 2 or higher sicne we hit the first crystal second time... 
		NVAR Pos6refStart=root:Packages:XtalCalc:Pos6refStart		//etc...
		NVAR Pos8refStart=root:Packages:XtalCalc:Pos8refStart
		NVAR Pos8refEnd=root:Packages:XtalCalc:Pos8refEnd
		
		//FindLevel  /Q NB,  0						//we always have 2 reflections if the top crystal ovelaps the first and the beam makes it in... We check for that later.
		//Pos2refStart = V_LevelX*step			// 	this value is fixed for each pair or crystals, not needed for any calculations
		FindLevel  /Q NB,  2							//this is when we hit top crystal once and then second crystal, here the 4 reflections should start
		Pos4refStart = V_LevelX*step				
		FindLevel  /Q NB,  4							//start of 6 reflections, 
		Pos6refStart = V_LevelX*step
		FindLevel  /Q NB,  6							//start of 8 reflections, 
		Pos8refStart = V_LevelX*step
				
		if (cmpstr(XtalStage,"Astage")==0)			
			Pos2refStart=-38									//top crystals overlap bottom from here... 
			Pos4refStart=Pos4refStart - x_3 
			Pos6refStart=Pos6refStart - x_3 
			Pos8refStart=Pos8refStart - x_3
			Pos8refEnd=-x_3
			//limit the max values to sensible numbers..., check for sufficient length of top crystal also....
			if(numtype(Pos8refStart) || (TopXtalOffset+TopXTalLength)<(7*SubsequentReflectionDistance))
				Pos8refEnd=NaN
				Pos8refStart=-x_3
			endif
			if(numtype(Pos6refStart)|| (TopXtalOffset+TopXTalLength)<(5*SubsequentReflectionDistance))
				Pos8refEnd=NaN
				Pos8refStart=NaN
				Pos6refStart=-x_3
			endif
			if(numtype(Pos4refStart)|| (TopXtalOffset+TopXTalLength)<(3*SubsequentReflectionDistance))
				Pos8refEnd=NaN
				Pos8refStart=NaN
				Pos6refStart=NaN
				Pos4refStart=-x_3
			endif
			if(numtype(Pos2refStart)|| (TopXtalOffset+TopXTalLength)<(SubsequentReflectionDistance))
				Pos8refEnd=NaN
				Pos8refStart=NaN
				Pos6refStart=NaN
				Pos4refStart=NaN
				Pos2refStart=NaN
			endif
		elseif ((cmpstr(XtalStage,"Mstage")==0)||(cmpstr(XtalStage,"Mstage2")==0))	
			Pos2refStart=11
			Pos4refStart=x_3-Pos4refStart 
			Pos6refStart=x_3-Pos6refStart 
			Pos8refStart=x_3-Pos8refStart
			Pos8refEnd=34
			//limit the max values to sensible numbers...
			if(numtype(Pos8refStart)|| (TopXtalOffset+TopXTalLength)<(7*SubsequentReflectionDistance))
				Pos8refEnd=NaN
				Pos8refStart=x_3
			endif
			if(numtype(Pos6refStart)|| (TopXtalOffset+TopXTalLength)<(5*SubsequentReflectionDistance))
				Pos8refEnd=NaN
				Pos8refStart=NaN
				Pos6refStart=x_3
			endif
			if(numtype(Pos4refStart)|| (TopXtalOffset+TopXTalLength)<(3*SubsequentReflectionDistance))
				Pos8refEnd=NaN
				Pos8refStart=NaN
				Pos6refStart=NaN
				Pos4refStart=x_3
			endif
			if(numtype(Pos2refStart)|| (TopXtalOffset+TopXTalLength)<(1*SubsequentReflectionDistance))
				Pos8refEnd=NaN
				Pos8refStart=NaN
				Pos6refStart=NaN
				Pos4refStart=NaN
				Pos2refStart=x_3
			endif
		endif
		
		if(TopXtalOffset>SubsequentReflectionDistance)		//miss the front of the top crystal, no reflections at all...
			Pos2refStart = NaN
			Pos4refStart = NaN
			Pos6refStart = NaN
			Pos8refStart = NaN
			Pos8refEnd=NaN
		endif
		
	setDataFolder oldDf
End 
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************
//***********************************************************************************

