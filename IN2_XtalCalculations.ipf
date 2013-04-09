#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.01




Function IN2X_GapCalculations()

	IN2X_InitializeXtalCalc()			//initialize the folder to work in
	
	Execute ("IN2X_ChannelCutGapCalculations()")

	IN2X_Calc2refl()
end

Function IN2X_XtalCalculations(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

		//here goes what is done - probably recalculate at any change...
	IN2X_Calc2refl()

End



Function IN2X_Calc2refl()

	setDataFolder root:Packages:XtalCalc
	
	 NVAR BraggAngle
	 NVAR FirstXtalLength
	 NVAR SecondXtalLength
	 NVAR SecondXtalOffset
	 NVAR Gap2refMin
	 NVAR Gap2refMax
	 NVAR Gap4refMin
	 NVAR Gap4refMax
	 NVAR Gap6refMin
	 NVAR Gap6refMax
	 NVAR Gap8refMin
	 NVAR Gap8refMax
	 NVAR BeamImpactOffset
	 NVAR FirstXtalEdgeOffset
	 NVAR SecondXtalEdgeOffset
	 NVAR BeamHeight
	 SVAR IncomingBeamStatus
	 NVAR ChannelCutYOffset
	 SVAR XtalHKL
	 NVAR Energy

	variable Dspacing
	
//Lets get first the Bragg angle in radians:

	If (cmpstr(XtalHKL,"220")==0)
		Dspacing=1.920155404		//220 d spacing for Si 111	
	elseif (cmpstr(XtalHKL,"440")==0)
		Dspacing=5.43102088/sqrt(32)		//440 d spacing for Si 111
	elseif (cmpstr(XtalHKL,"333")==0)
		Dspacing=5.43102088/sqrt(3*9)		//333 d spacing for Si 111
	else
		Dspacing=5.43102088/sqrt(3)		//111 d spacing for Si 111
	endif
	// dsin(alpha)=lambda/2
	Variable wavelength=12.398424437/Energy
	
	variable alpha=asin(wavelength/(2*Dspacing))
	
//First lets calculate, few useful parameters

	BraggAngle=(alpha/pi)*180
	
	variable BeamHeightOffset=(BeamHeight/sin(alpha))/2
	
	variable BeamImpactPosition=BeamImpactOffset-ChannelCutYOffset/sin(alpha)
	
//now lets check if the beam makes it between the crystals
	
	if(BeamImpactPosition<(BeamHeightOffset))
		IncomingBeamStatus="Beam UNDER first Xtal"
	elseif(BeamImpactPosition>(FirstXtalLength-BeamHeightOffset))
		IncomingBeamStatus="Beam ABOVE first Xtal"
	else
		IncomingBeamStatus="OK"
	endif

	if (cmpstr(IncomingBeamStatus,"OK")!=0)		//the beam is not between the crystals
		 Gap2refMin=NaN
		 Gap2refMax=NaN
		 Gap4refMin=NaN
		 Gap4refMax=NaN
		 Gap6refMin=NaN
		 Gap6refMax=NaN
		 Gap8refMin=NaN
		 Gap8refMax=NaN
	else											//OK beam makes it between the crystals, so next calculations make sense
			
			variable MinGapToMakeImpact=(tan(alpha))*(BeamImpactPosition-SecondXtalOffset+BeamHeightOffset) 
			
	//And now calculations for two reflections
		
			Gap2refMax=(tan(alpha))*(SecondXtalLength+SecondXtalOffset-BeamHeightOffset-BeamImpactPosition)
		
			variable Gap2RefMin1=(tan(alpha))*(SecondXtalOffset-SecondXtalEdgeOffset+BeamHeightOffset-BeamImpactPosition)
		
		//	variable Gap2RefMin2=(0.5*tan(alpha))*(FirstXtalLength+BeamImpactPosition-BeamImpactPosition)
			variable Gap2RefMin2=(0.5*tan(alpha))*(FirstXtalLength+BeamHeightOffset-BeamImpactPosition) //fixed ? JIL 11 2006
			
			Gap2refMin=MinGapToMakeImpact
			
			if (Gap2refMin<Gap2RefMin1)			
				Gap2refMin=Gap2RefMin1
			endif
			if (Gap2refMin<Gap2RefMin2)			
				Gap2refMin=Gap2RefMin2
			endif
			
			
		//Four reflections
		
		variable Gap4refMax1=(1/3)*(tan(alpha))*(SecondXtalLength-SecondXtalEdgeOffset+SecondXtalOffset-BeamHeightOffset-BeamImpactPosition)
		variable Gap4refMax2=0.5*(tan(alpha))*(FirstXtalLength-FirstXtalEdgeOffset-BeamHeightOffset-BeamImpactPosition)
		
		variable Gap4refMin1=0.25*(tan(alpha))*(FirstXtalLength+BeamHeightOffset-BeamImpactPosition)
		
		if (Gap4refMax1<Gap4refMax2)
			Gap4refMax=Gap4refMax1
		else
			Gap4refMax=Gap4refMax2
		endif
		
		if (MinGapToMakeImpact<Gap4refMin1)
			Gap4refMin=Gap4refMin1
		else
			Gap4refMin=MinGapToMakeImpact
		endif
		
		//Six reflections
		
		variable Gap6refMax1=0.2*(tan(alpha))*(SecondXtalLength-SecondXtalEdgeOffset+SecondXtalOffset-BeamHeightOffset-BeamImpactPosition)
		variable Gap6refMax2=0.25*(tan(alpha))*(FirstXtalLength-FirstXtalEdgeOffset-BeamHeightOffset-BeamImpactPosition)
		
		variable Gap6refMin1=(1/6)*(tan(alpha))*(FirstXtalLength+BeamHeightOffset-BeamImpactPosition)
		
		if (Gap6refMax1<Gap6refMax2)
			Gap6refMax=Gap6refMax1
		else
			Gap6refMax=Gap6refMax2
		endif
		
		if (MinGapToMakeImpact<Gap6refMin1)
			Gap6refMin=Gap6refMin1
		else
			Gap6refMin=MinGapToMakeImpact
		endif

		//Eight reflections
		
		variable Gap8refMax1=(1/7)*(tan(alpha))*(SecondXtalLength-SecondXtalEdgeOffset+SecondXtalOffset-BeamHeightOffset-BeamImpactPosition)
		variable Gap8refMax2=(1/6)*(tan(alpha))*(FirstXtalLength-FirstXtalEdgeOffset-BeamHeightOffset-BeamImpactPosition)
		
		variable Gap8refMin1=(1/8)*(tan(alpha))*(FirstXtalLength+BeamHeightOffset-BeamImpactPosition)
		
		if (Gap8refMax1<Gap8refMax2)
			Gap8refMax=Gap8refMax1
		else
			Gap8refMax=Gap8refMax2
		endif
		
		if (MinGapToMakeImpact<Gap8refMin1)
			Gap8refMin=Gap8refMin1
		else
			Gap8refMin=MinGapToMakeImpact
		endif
	//and now cecheck if min is smaller than max to make sense...
			if (Gap2refMin>Gap2refMax)
				Gap2refMin=NaN
				Gap2refMax=NaN
			endif
			if (Gap4refMin>Gap4refMax)
				Gap4refMin=NaN
				Gap4refMax=NaN
			endif
			if (Gap6refMin>Gap6refMax)
				Gap6refMin=NaN
				Gap6refMax=NaN
			endif
			if (Gap8refMin>Gap8refMax)
				Gap8refMin=NaN
				Gap8refMax=NaN
			endif


	endif
end

Window IN2X_ChannelCutGapCalculations() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(179.25,47,992.25,518) as "ChannelCut Gap Calculations"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 30,fstyle= 1,textrgb= (65280,0,0)
	DrawText 18,44,"ChannelCut Gap Calculations"
	SetDrawEnv linethick= 5,linefgc= (0,0,52224)
	DrawLine 120,264,558,176
	SetDrawEnv linethick= 5,linefgc= (0,0,52224)
	DrawLine 224,142,662,54
	SetDrawEnv arrow= 3
	DrawLine 124,288,560,200
	SetDrawEnv arrow= 3
	DrawLine 220,120,656,32
	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 6,240,210,240
	SetDrawEnv linethick= 5,dash= 7,arrow= 3,arrowlen= 20,arrowfat= 1
	DrawLine 492,94,508,182
	SetDrawEnv fsize= 20,fstyle= 1
	DrawText 508,150,"Gap"
	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 220,238,340,122
	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 342,124,516,182
	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 634,64,774,64
	SetDrawEnv linefgc= (52224,0,41728),dash= 5,arrow= 1
	DrawLine 516,178,632,66
	SetDrawEnv linethick= 2,arrow= 3
	DrawLine 104,166,218,144
	SetDrawEnv linethick= 2,arrow= 3
	DrawLine 114,246,206,228
	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (0,12800,52224)
	DrawText 525,295,"Results   [mm]:"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 330,348,"For 2 reflections : "
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 576,348,"< Gap <"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 330,378,"For 4 reflections : "
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 576,378,"< Gap <"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 330,408,"For 6 reflections : "
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 576,408,"< Gap <"
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 330,438,"For 8 reflections : "
	SetDrawEnv fsize= 16,fstyle= 1
	DrawText 576,438,"< Gap <"
	SetDrawEnv arrow= 3
	DrawLine 665,71,633,78
	SetDrawEnv arrow= 3
	DrawLine 558,167,526,174
	SetDrawEnv dash= 5
	DrawLine 96,164,117,267
	SetDrawEnv linefgc= (39168,0,31232),arrow= 3
	DrawLine 38,231,38,248
	DrawText 16,262,"Beam height"
	SetDrawEnv gstart
	SetDrawEnv linethick= 3,linefgc= (52224,0,41728),arrow= 3
	DrawLine 216,209,216,276
	SetDrawEnv linethick= 2,linefgc= (52224,0,41728)
	DrawLine 211,243,221,243
	SetDrawEnv linefgc= (52224,0,41728),fsize= 20,textrgb= (52224,0,41728)
	DrawText 223,231,"+"
	SetDrawEnv linefgc= (52224,0,41728),fsize= 20,textrgb= (52224,0,41728)
	DrawText 225,278,"-"
	SetDrawEnv gstop
	SetDrawEnv dash= 3,arrow= 1
	DrawLine 36,264,33,297
	SetDrawEnv fsize= 18
	DrawText 4,350,"Energy/Xtal data :"
	SetVariable BraggAngle,pos={11,430},size={220,16},proc=IN2X_XtalCalculations,title="Bragg Angle [degrees]"
	SetVariable BraggAngle,format="%3.2f"
	SetVariable BraggAngle,limits={-Inf,Inf,0},value= root:Packages:XtalCalc:BraggAngle
	SetVariable FirstXtalLength,pos={390,218},size={200,16},proc=IN2X_XtalCalculations,title="Length of first Xtal [mm]"
	SetVariable FirstXtalLength,limits={-Inf,Inf,1},value= root:Packages:XtalCalc:FirstXtalLength
	SetVariable SecondXtalLength,pos={278,55},size={230,16},proc=IN2X_XtalCalculations,title="Length of second Xtal [mm]"
	SetVariable SecondXtalLength,limits={-Inf,Inf,1},value= root:Packages:XtalCalc:SecondXtalLength
	SetVariable BeamImpactOffset,pos={11,201},size={200,16},proc=IN2X_XtalCalculations,title="Beam impact offset [mm]"
	SetVariable BeamImpactOffset,limits={-Inf,Inf,1},value= root:Packages:XtalCalc:BeamImpactOffset
	SetVariable SecondXtalOffset,pos={16,119},size={200,16},proc=IN2X_XtalCalculations,title="Second Xtal offset [mm]"
	SetVariable SecondXtalOffset,limits={-Inf,Inf,1},value= root:Packages:XtalCalc:SecondXtalOffset
	SetVariable Gap2Min,pos={494,329},size={70,16},title=" ",format="%3.2f"
	SetVariable Gap2Min,limits={-Inf,Inf,0},value= root:Packages:XtalCalc:Gap2refMin
	SetVariable Gap2Max,pos={642,329},size={70,16},title=" ",format="%3.2f"
	SetVariable Gap2Max,limits={-Inf,Inf,0},value= root:Packages:XtalCalc:Gap2refMax
	SetVariable Gap4Min,pos={494,359},size={70,16},title=" ",format="%3.2f"
	SetVariable Gap4Min,limits={-Inf,Inf,0},value= root:Packages:XtalCalc:Gap4refMin
	SetVariable Gap4Max,pos={642,359},size={70,16},title=" ",format="%3.2f"
	SetVariable Gap4Max,limits={-Inf,Inf,0},value= root:Packages:XtalCalc:Gap4refMax
	SetVariable Gap6Min,pos={494,389},size={70,16},title=" ",format="%3.2f"
	SetVariable Gap6Min,limits={-Inf,Inf,0},value= root:Packages:XtalCalc:Gap6refMin
	SetVariable Gap6Max,pos={642,389},size={70,16},title=" ",format="%3.2f"
	SetVariable Gap6Max,limits={-Inf,Inf,0},value= root:Packages:XtalCalc:Gap6refMax
	SetVariable Gap8Min,pos={494,419},size={70,16},title=" ",format="%3.2f"
	SetVariable Gap8Min,limits={-Inf,Inf,0},value= root:Packages:XtalCalc:Gap8refMin
	SetVariable Gap8Max,pos={642,419},size={70,16},title=" ",format="%3.2f"
	SetVariable Gap8Max,limits={-Inf,Inf,0},value= root:Packages:XtalCalc:Gap8refMax
	SetVariable BeamHeight,pos={7,298},size={180,16},proc=IN2X_XtalCalculations,title="Beam height [mm]"
	SetVariable BeamHeight,limits={-Inf,Inf,0.05},value= root:Packages:XtalCalc:BeamHeight
	SetVariable SecondCrystalEnd,pos={577,85},size={200,16},proc=IN2X_XtalCalculations,title="Avoid 2nd X tal end [mm]"
	SetVariable SecondCrystalEnd,limits={-Inf,Inf,1},value= root:Packages:XtalCalc:SecondXtalEdgeOffset
	SetVariable FirstCrystalEnd,pos={559,152},size={200,16},proc=IN2X_XtalCalculations,title="Avoid 1st X tal end [mm]"
	SetVariable FirstCrystalEnd,limits={-Inf,Inf,1},value= root:Packages:XtalCalc:FirstXtalEdgeOffset
	PopupMenu HKLSelection,pos={34,356},size={135,21},proc=IN2X_PopProcedure,title="Si Xtal HKL  : "
	PopupMenu HKLSelection,mode=1,popvalue="111",value= #"\"111;220;333;440\""
	SetVariable Energy,pos={39,385},size={150,16},proc=IN2X_XtalCalculations,title="Energy  [keV] :"
	SetVariable Energy,limits={-Inf,Inf,0.05},value= root:Packages:XtalCalc:Energy
	SetVariable BeamStatus,pos={374,301},size={300,16},title="Incoming beam in the channelcut:"
	SetVariable BeamStatus,limits={-Inf,Inf,0},value= root:Packages:XtalCalc:IncomingBeamStatus
	SetVariable Yoffset,pos={198,281},size={150,16},proc=IN2X_XtalCalculations,title="Vertical offset [mm]:"
	SetVariable Yoffset,limits={-Inf,Inf,0.1},value= root:Packages:XtalCalc:ChannelCutYOffset
EndMacro

Function IN2X_PopProcedure(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	SVAR XtalHKL
	if (cmpstr(ctrlName,"HKLSelection")==0)
		XtalHKL=popStr
	endif

	IN2X_Calc2refl()
End

Function IN2X_InitializeXtalCalc()

	NewDataFolder/O root:Packages
	NewDataFolder/O/S root:Packages:XtalCalc
	
	 NVAR/Z BraggAngle
	 if (NVAR_Exists(BraggAngle)==0)
	 	variable/g BraggAngle=12
	 endif

	 NVAR/Z Energy
	 if (NVAR_Exists(Energy)==0)
	 	variable/g Energy=10
	 endif
	 
	 SVAR/Z IncomingBeamStatus
	 if (SVAR_Exists(IncomingBeamStatus)==0)
	 	string/g IncomingBeamStatus="OK"
	 endif

	 SVAR/Z XtalHKL
	 if (SVAR_Exists(XtalHKL)==0)
	 	string/g XtalHKL="111"
	 endif

	 NVAR/Z ChannelCutYOffset
	 if (NVAR_Exists(ChannelCutYOffset)==0)
	 	variable/g ChannelCutYOffset=0
	 endif

	 NVAR/Z BeamHeight
	 if (NVAR_Exists(BeamHeight)==0)
	 	variable/g BeamHeight=0.4
	 endif

	 NVAR/Z FirstXtalLength
	 if (NVAR_Exists(FirstXtalLength)==0)
	 	variable/g FirstXtalLength=100
	 endif

	 NVAR/Z SecondXtalLength
	 if (NVAR_Exists(SecondXtalLength)==0)
	 	variable/g SecondXtalLength=100
	 endif

	 NVAR/Z SecondXtalOffset
	 if (NVAR_Exists(SecondXtalOffset)==0)
	 	variable/g SecondXtalOffset=25
	 endif

	 NVAR/Z Gap2refMin
	 if (NVAR_Exists(Gap2refMin)==0)
	 	variable/g Gap2refMin=NaN
	 endif

	 NVAR/Z Gap2refMax
	 if (NVAR_Exists(Gap2refMax)==0)
	 	variable/g Gap2refMax=NaN
	 endif

	 NVAR/Z Gap4refMin
	 if (NVAR_Exists(Gap4refMin)==0)
	 	variable/g Gap4refMin=NaN
	 endif

	 NVAR/Z Gap4refMax
	 if (NVAR_Exists(Gap4refMax)==0)
	 	variable/g Gap4refMax=NaN
	 endif

	 NVAR/Z Gap6refMin
	 if (NVAR_Exists(Gap6refMin)==0)
	 	variable/g Gap6refMin=NaN
	 endif

	 NVAR/Z Gap6refMax
	 if (NVAR_Exists(Gap6refMax)==0)
	 	variable/g Gap6refMax=NaN
	 endif

	 NVAR/Z Gap8refMin
	 if (NVAR_Exists(Gap8refMin)==0)
	 	variable/g Gap8refMin=NaN
	 endif

	 NVAR/Z Gap8refMax
	 if (NVAR_Exists(Gap8refMax)==0)
	 	variable/g Gap8refMax=NaN
	 endif

	 NVAR/Z BeamImpactOffset
	 if (NVAR_Exists(BeamImpactOffset)==0)
	 	variable/g BeamImpactOffset=25
	 endif

	 NVAR/Z FirstXtalEdgeOffset
	 if (NVAR_Exists(FirstXtalEdgeOffset)==0)
	 	variable/g FirstXtalEdgeOffset=0
	 endif

	 NVAR/Z SecondXtalEdgeOffset
	 if (NVAR_Exists(SecondXtalEdgeOffset)==0)
	 	variable/g SecondXtalEdgeOffset=0
	 endif
end