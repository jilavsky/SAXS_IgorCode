#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.10




//******************************************************Import X23 Data

Function IN2I_ImportX23Data()
	//this function will eventually import data from X23 data format.
	//user better know a lot about the sample!!!!
	
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:X23Import
	SetDataFolder root:packages:X23Import
 
	loadwave/A=Loaded/G/D/L={0,1,0,0,0}
	
	KillWaves/Z PD_range, ar, AR_encoder, Monitor, USAXS_PD, MeasTime	
	rename loaded0 PD_range
	rename loaded1 ar
	rename loaded2 AR_encoder
	rename loaded3 Monitor
	rename loaded4 USAXS_PD
	rename loaded5 MeasTime
	
	string/G specCommand="uascan X23 downloaded data this string is SDD_mm used later DoNotChange"
	string/G PathToRawData="X23 downloaded data"
  	string/G SpecComment=""
  	string/G SpecSourceFileName=S_path+S_fileName
  	
  	IN2I_CreateParameters()
	
	IN2I_InitializeConversion()
	
	IN2I_UserInput()

End

Function In2I_InitializeConversion()

	NewDataFolder/O root:USAXS
	setDataFolder root:Packages:X23Import:
	
	SVAR/Z USAXSDataSubfolder
	if (!SVAR_Exists(USAXSDataSubfolder))
		string/g USAXSDataSubfolder=""
	endif
	string/G USAXSDataFolder=""
end


Function IN2I_CreateParameters()
	//creates all global parameters, if they do not exist, so we can put them in the panel and get user input
	setDataFolder root:Packages:X23Import:
	 NVAR/Z Vfc
	 if (!NVAR_Exists(Vfc))
		 variable/G Vfc=100000
	endif
	 NVAR/Z Gain1
	 if (!NVAR_Exists(Gain1))
		 variable/G Gain1=1000
	endif
	 NVAR/Z Gain2
	 if (!NVAR_Exists(Gain2))
		 variable/G Gain2=100000
	endif
	 NVAR/Z Gain3
	 if (!NVAR_Exists(Gain3))
		 variable/G Gain3=10000000
	endif
	 NVAR/Z Gain4
	 if (!NVAR_Exists(Gain4))
		 variable/G Gain4=1000000000
	endif
	 NVAR/Z Gain5
	 if (!NVAR_Exists(Gain5))
		 variable/G Gain5=NaN
	endif
	 NVAR/Z Bkg1
	 if (!NVAR_Exists(Bkg1))
		 variable/G Bkg1=100
	endif
	 NVAR/Z Bkg2
	 if (!NVAR_Exists(Bkg2))
		 variable/G Bkg2=100
	endif
	 NVAR/Z Bkg3
	 if (!NVAR_Exists(Bkg3))
		 variable/G Bkg3=100
	endif
	 NVAR/Z Bkg4
	 if (!NVAR_Exists(Bkg4))
		 variable/G Bkg4=100
	endif
	 NVAR/Z Bkg5
	 if (!NVAR_Exists(Bkg5))
		 variable/G Bkg5=NaN
	endif
	 NVAR/Z Wavelength
	 if (!NVAR_Exists(Wavelength))
		 variable/G Wavelength=1.24
	endif
	 NVAR/Z DCM_energy
	 if (!NVAR_Exists(DCM_energy))
		 variable/G DCM_energy=10
	endif
	 NVAR/Z SlitLength
	 if (!NVAR_Exists(SlitLength))
		 variable/G SlitLength=0.05
	endif
	 NVAR/Z NumberOfSteps
	 WAVE USAXS_PD
	 if (!NVAR_Exists(NumberOfSteps))
		 variable/G NumberOfSteps=0
	endif
	NumberOfSteps=numpnts(USAXS_PD)
	 NVAR/Z SDDistance
	 if (!NVAR_Exists(SDDistance))
		 variable/G SDDistance=320
	endif


 	variable/G UPD2mode=2
 	variable/G UPD2selected=1
 	
	 NVAR/Z energy
	 if (!NVAR_Exists(energy))
		 variable/G energy
	endif
	energy=12.398424437/wavelength
	 NVAR/Z SampleThickness
	 if (!NVAR_Exists(SampleThickness))
		 variable/G SampleThickness=1
	endif

end

Function IN2I_UserInput()

	Execute ("X23ImportPanel()")


end

Function IN2I_SetVarProcForPanel(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	setDataFolder root:Packages:X23Import
	
	SVAR SpecComment
	SVAR USAXSDataFolder
	SVAR USAXSDataSubfolder
	if (cmpstr(ctrlName,"SpecComment")==0)
		SpecComment=varStr
		USAXSDataFolder=IN2I_GenerateLibUSAXSFolderName(USAXSDataSubfolder, SpecComment)	
	endif

	SVAR USAXSDataSubfolder
	if (cmpstr(ctrlName,"Subfolder")==0)
		USAXSDataSubfolder=varStr
		USAXSDataSubfolder=IN2I_GenerateLibUSAXSFolderName("root:USAXS", USAXSDataSubfolder)	
	endif
	SVAR USAXSDataFolder
	if (cmpstr(ctrlName,"Folder")==0)
		USAXSDataFolder=varStr
		USAXSDataFolder=IN2I_GenerateLibUSAXSFolderName(USAXSDataSubfolder, USAXSDataFolder)
	endif

	


	NVAR SampleThickness
	if (cmpstr(ctrlName,"SampleThickness")==0)
		SampleThickness=varNum
	endif
	NVAR energy
	NVAR wavelength
	NVAR DCM_Energy
	if (cmpstr(ctrlName,"Energy")==0)
		energy=varNum
		DCM_Energy=energy
		wavelength=12.398424437/energy
	endif
	NVAR SDDistance
	SVAR specCommand
	if (cmpstr(ctrlName,"SDDistance")==0)
		SDDistance=varNum
		specCommand="uascan X23 downloaded data this string is "+num2str(SDDistance)+" used later DoNotChange"
	endif
	NVAR SlitLength
	if (cmpstr(ctrlName,"SlitLength")==0)
		SlitLength=varNum
	endif
	NVAR Vfc
	if (cmpstr(ctrlName,"Vfc")==0)
		Vfc=varNum
	endif
	NVAR Gain1
	if (cmpstr(ctrlName,"Gain1")==0)
		Gain1=varNum
	endif
	NVAR Gain2
	if (cmpstr(ctrlName,"Gain2")==0)
		Gain2=varNum
	endif
	NVAR Gain3
	if (cmpstr(ctrlName,"Gain3")==0)
		Gain3=varNum
	endif
	NVAR Gain4
	if (cmpstr(ctrlName,"Gain4")==0)
		Gain4=varNum
	endif
	NVAR Gain5
	if (cmpstr(ctrlName,"Gain5")==0)
		Gain5=varNum
	endif

	NVAR Bkg1
	if (cmpstr(ctrlName,"Bkg1")==0)
		Bkg1=varNum
	endif
	NVAR Bkg2
	if (cmpstr(ctrlName,"Bkg2")==0)
		Bkg2=varNum
	endif
	NVAR Bkg3
	if (cmpstr(ctrlName,"Bkg3")==0)
		Bkg3=varNum
	endif
	NVAR Bkg4
	if (cmpstr(ctrlName,"Bkg4")==0)
		Bkg4=varNum
	endif
	NVAR Bkg5
	if (cmpstr(ctrlName,"Bkg5")==0)
		Bkg5=varNum
	endif
	
End

Window X23ImportPanel() : Panel
	
	setDataFolder root:packages:X23Import
	
	PauseUpdate; Silent 1		// building window...
	NewPanel/K=1 /W=(144,47.75,600,589.25) as "X23 import panel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (52224,0,0)
	DrawText 102,25,"X 23 data import panel"
	SetDrawEnv linethick= 3,linefgc= (52224,0,0)
	DrawLine 6,66,432,66
	SetDrawEnv fstyle= 1,textrgb= (0,0,52224)
	DrawText 6,92,"Sample description :"
	SetDrawEnv linethick= 3,linefgc= (52224,0,0)
	DrawLine 6,152,432,152
	SetDrawEnv fstyle= 1,textrgb= (0,0,52224)
	DrawText 6,172,"Measurement parameters :"
	SetDrawEnv linethick= 3,linefgc= (52224,0,0)
	DrawLine 6,235,432,235
	SetDrawEnv fstyle= 1,textrgb= (0,0,52224)
	DrawText 6,261,"UPD parameters (can be modified later) :"
	SetDrawEnv linethick= 3,linefgc= (52224,0,0)
	DrawLine 6,407,432,407
	SetDrawEnv fstyle= 1,textrgb= (0,0,52224)
	DrawText 5,432,"Convert data to:"
	SetVariable SpecSourceFileName,pos={12,34},size={400,16},proc=IN2I_SetVarProcForPanel,title="Data :  "
	SetVariable SpecSourceFileName,limits={0,0,0},value= root:Packages:X23Import:SpecSourceFileName
	SetVariable SpecComment,pos={13,101},size={300,16},proc=IN2I_SetVarProcForPanel,title="Sample name: "
	SetVariable SpecComment,limits={-Inf,Inf,1},value= root:Packages:X23Import:SpecComment
	SetVariable SampleThickness,pos={14,127},size={200,16},proc=IN2I_SetVarProcForPanel,title="Sample thickness [mm] :"
	SetVariable SampleThickness,limits={-Inf,Inf,0.05},value= root:Packages:X23Import:SampleThickness
	SetVariable Energy,pos={10,182},size={150,16},proc=IN2I_SetVarProcForPanel,title="Energy [keV] :"
	SetVariable Energy,limits={5,30,0.05},value= root:Packages:X23Import:energy
	SetVariable SDDistance,pos={7,204},size={200,16},proc=IN2I_SetVarProcForPanel,title="Sa-Det distance [mm] :"
	SetVariable SDDistance,limits={150,1000,5},value= root:Packages:X23Import:SDDistance
	SetVariable SlitLength,pos={216,182},size={200,16},proc=IN2I_SetVarProcForPanel,title="Slit Length [Q units] :"
	SetVariable SlitLength,limits={0,1,0.0005},value= root:Packages:X23Import:SlitLength
	SetVariable Vfc,pos={8,268},size={150,16},proc=IN2I_SetVarProcForPanel,title="V-to-f factor : "
	SetVariable Vfc,limits={1000,Inf,1},value= root:Packages:X23Import:Vfc
	SetVariable Gain1,pos={8,293},size={150,16},proc=IN2I_SetVarProcForPanel,title="Gain range 1: "
	SetVariable Gain1,limits={1,Inf,1},value= root:Packages:X23Import:Gain1
	SetVariable Gain2,pos={8,314},size={150,16},proc=IN2I_SetVarProcForPanel,title="Gain range 2: "
	SetVariable Gain2,limits={1,Inf,1},value= root:Packages:X23Import:Gain2
	SetVariable Gain3,pos={8,336},size={150,16},proc=IN2I_SetVarProcForPanel,title="Gain range 3: "
	SetVariable Gain3,limits={1,Inf,1},value= root:Packages:X23Import:Gain3
	SetVariable Gain4,pos={8,358},size={150,16},proc=IN2I_SetVarProcForPanel,title="Gain range 4: "
	SetVariable Gain4,limits={1,Inf,1},value= root:Packages:X23Import:Gain4
	SetVariable Gain5,pos={8,379},size={150,16},proc=IN2I_SetVarProcForPanel,title="Gain range 5: "
	SetVariable Gain5,limits={1,Inf,1},value= root:Packages:X23Import:Gain5
	SetVariable Bkg1,pos={195,293},size={150,16},proc=IN2I_SetVarProcForPanel,title="Bkg range 1: "
	SetVariable Bkg1,limits={1,Inf,1},value= root:Packages:X23Import:Bkg1
	SetVariable Bkg2,pos={195,314},size={150,16},proc=IN2I_SetVarProcForPanel,title="Bkg range 2: "
	SetVariable Bkg2,limits={1,Inf,1},value= root:Packages:X23Import:Bkg2
	SetVariable Bkg3,pos={195,336},size={150,16},proc=IN2I_SetVarProcForPanel,title="Bkg range 3: "
	SetVariable Bkg3,limits={1,Inf,1},value= root:Packages:X23Import:Bkg3
	SetVariable Bkg4,pos={195,358},size={150,16},proc=IN2I_SetVarProcForPanel,title="Bkg range 4: "
	SetVariable Bkg4,limits={1,Inf,1},value= root:Packages:X23Import:Bkg4
	SetVariable Bkg5,pos={195,379},size={150,16},proc=IN2I_SetVarProcForPanel,title="Bkg range 5: "
	SetVariable Bkg5,limits={1,Inf,1},value= root:Packages:X23Import:Bkg5
	SetVariable Subfolder,pos={117,417},size={250,16},proc=IN2I_SetVarProcForPanel,title="(Create) Subfolder of root:USAXS:  "
	SetVariable Subfolder,limits={-Inf,Inf,0},value= root:Packages:X23Import:USAXSDataSubfolder
	SetVariable Folder,pos={7,467},size={350,16},proc=IN2I_SetVarProcForPanel,title="Folder name  root:USAXS:(subfolder):+"
	SetVariable Folder,limits={-Inf,Inf,0},value= root:Packages:X23Import:USAXSDataFolder
	Button DoConversion,pos={154,495},size={100,20},proc=IN2I_DoConv_ButtonProc,title="Write data"
	PopupMenu SelectSubDir,pos={1,440},size={224,21},proc=IN2I_PopMenuProc,title="Or select subfolder for data: "
	PopupMenu SelectSubDir,mode=1,popvalue="test new",value= #"IN2G_CreateListOfItemsInFolder(\"root:USAXS:\",1)"
EndMacro



Function/T IN2I_GenerateLibUSAXSFolderName(subfolder, newname)			//complicated way to create unique & liberal name of USAXS data
	string subfolder, newname	

	string df=GetDataFolder(1)												//thats where we start

	string USAXSpath="root:USAXS:"										//create pointer to the USAXS data subfolder
	if (strlen(subfolder)>1)
		USAXSpath+=subfolder
	endif	
	string LibName=CleanupName(newname, 1 )									//clean it up
	
	if (DataFolderExists(USAXSpath))										//go there..
		SetDataFolder $USAXSpath 
		if (CheckName(LibName, 11)!=0)					//this needs to be in root:USAXS:subfldr to work
			LibName+="_"
			LibName=UniqueName(LibName, 11, 0)			//check if the name exists and create unique name
		endif
		SetDataFolder $df								//go back
	endif
	Libname= PossiblyQuoteName(LibName)				//cleanup the name
	return Libname
end


Function IN2I_PopMenuProc(ctrlName,popNum,popStr) : PopupMenuControl
	String ctrlName
	Variable popNum
	String popStr

	setdataFolder root:Packages:X23Import
	
	SVAR USAXSDataSubfolder
	if (cmpstr(ctrlName,"SelectSubDir")==0)
		USAXSDataSubfolder=popStr
	endif

End




//*******************************************************


Function IN2I_FunnyTimeCalculated(RealTimeSec)
	variable RealTimeSec
	variable t=abs(RealTimeSec/16e-6)
	variable m=0,f=0,b=0
	variable bestTime=IN2I_X23A3TimeFloat(0,0,0)
	variable Bestz=abs(1-bestTime/RealTimeSec), Bestf=0,Bestm=0, Bestb=0
	
	variable f2=1, b2=1, m2=1, TimeNew, z
		Do
			variable t2=t*f2
			b=0
			b2=1
				Do
					m2=t2*b2
					if ((127>=m2) %& (m2>=1))
						m=floor((m2-1)/2)
						TimeNew=IN2I_X23A3TimeFloat(m,f,b)
						z=abs(1-TimeNew/RealTimeSec)
						if (z< Bestz)
							Bestz=z
							Bestf=f
							Bestm=m
							Bestb=b
							
						endif
					endif
					b+=1
					b2=b2/10
				while (b<8)
			f+=1
			f2=f2/2
		while (f<16)
		variable code = 128*Bestm+8*Bestf+Bestb
		return code
End

Function IN2I_X23A3TimeFloat(m,f,b)
	variable m,f,b
	variable result
	result=(2*m+1)*2^(f+4)*10^(b-6)
	return result
end



Function IN2I_ConvertFunnyTimeToSec(FunnyTime)
	variable FunnyTime
	variable m=floor(FunnyTime/128)
	variable f=floor((FunnyTime-m*128)/8)
	variable b=FunnyTime-m*128-f*8
	print m, f, b
	variable RealTimeSec=(2*m+1)*2^(f+4)*10^(b-6)
	return RealTimeSec
End


Proc Align()
	string GraphName=Winname(0,1)
	string PanelName=WinName(0,64)
	AutopositionWindow/M=0 /R=$GraphName $PanelName
end



Function IN2I_DoConv_ButtonProc(ctrlName) : ButtonControl
	String ctrlName
	setDataFolder root:Packages:X23Import

	//here goes the conversion
	//first we need to create the lists and make the wavenotes
	IN2I_CreateStringsWithData()
	SVAR NewWavenote
	IN2G_AppendListToAllWavesNotes(NewWavenote)
	//next we need to copy data to destinations
	SVAR USAXSDataFolder
	SVAR USAXSDataSubfolder
	string USAXSFldr
	
	NewDataFolder/O root:USAXS
	
	if (strlen(USAXSDataSubfolder)>0)
		NewDataFolder/O $("root:USAXS:"+USAXSDataSubfolder)
		USAXSFldr="root:USAXS:"+USAXSDataSubfolder+":"+USAXSDataFolder
	else
		USAXSFldr="root:USAXS:"+USAXSDataFolder
	endif

	NewDataFolder $USAXSFldr
	
	USAXSFldr+=":"
	IN2I_CopyDataToUSAXS(USAXSFldr)

	//and last we will save the data to raw folder
	IN2I_RecordImportedData()

	DoWindow/K X23ImportPanel
	
End

Function IN2I_CopyDataToUSAXS(USAXSFldr)
	string USAXSFldr
	//this function copies data to USAXS folder

	setDataFolder root:Packages:X23Import
	
	IN2Z_CpyMvOneWave("PD_range",USAXSFldr,0)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("ar",USAXSFldr,0)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("AR_Encoder",USAXSFldr,0)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("Monitor",USAXSFldr,0)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("USAXS_PD",USAXSFldr,0)		//this moves wave into new folder
	IN2Z_CpyMvOneWave("MeasTime",USAXSFldr,0)		//this moves wave into new folder

	IN2Z_CpyMvOneString("UPDParameters",USAXSFldr,0)		//this moves or copies string
	IN2Z_CpyMvOneString("ListOfASBParameters",USAXSFldr,0)		//this moves or copies string
	IN2Z_CpyMvOneString("MeasurementParameters",USAXSFldr,0)		//this moves or copies string
	SVAR/Z specCommand					//this removes spaces in the beggigning of SpecComment... problem
	variable i=0
	if (SVAR_Exists(specCommand))	
		for (i=0;i<4;i+=1)
			if (cmpstr(specCommand[0]," ")==0)
				specCommand=specCommand[1, strlen(specCommand)-1]
			endif
		endfor
	endif
	IN2Z_CpyMvOneString("specCommand",USAXSFldr,0)		//this moves or copies string
	IN2Z_CpyMvOneString("timeWritten",USAXSFldr,0)		//this moves or copies string	
	IN2Z_CpyMvOneString("specComment",USAXSFldr,0)		//this moves or copies string
	IN2Z_CpyMvOneString("SpecSourceFileName",USAXSFldr,0)		//this moves or copies string
	IN2Z_CpyMvOneVariable("wavelength",USAXSFldr,0)		//and this moves or copies one variable	

end

Function IN2I_CreateStringsWithData()
//this function converts variables into strings as needed in the Indra2
	setDataFolder root:Packages:X23Import
		
	string/G UPDParameters=""
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","UPD2mode","UPD2mode")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","UPD2selected","UPD2selected")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Vfc","Vfc")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Gain1","Gain1")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Gain2","Gain2")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Gain3","Gain3")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Gain4","Gain4")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Gain5","Gain5")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Bkg1","Bkg1")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Bkg2","Bkg2")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Bkg3","Bkg3")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Bkg4","Bkg4")
	UPDParameters =  IN2Z_NVARRplcKwString("UPDParameters","Bkg5","Bkg5")
	
	

	string/g MeasurementParameters=""
	MeasurementParameters =  IN2Z_NVARRplcKwString("MeasurementParameters","Wavelength","wavelength")
	MeasurementParameters =  IN2Z_NVARRplcKwString("MeasurementParameters","SlitLength","SlitLength")
	MeasurementParameters =  IN2Z_NVARRplcKwString("MeasurementParameters","SDDistance","SDDistance")
	MeasurementParameters =  IN2Z_NVARRplcKwString("MeasurementParameters","DCM_energy","DCM_energy")
	MeasurementParameters =  IN2Z_NVARRplcKwString("MeasurementParameters","UPD2mode","UPD2mode")
	MeasurementParameters =  IN2Z_NVARRplcKwString("MeasurementParameters","UPD2selected","UPD2selected")


	MeasurementParameters+= UPDParameters+";"

	MeasurementParameters=ChangePartsOfString(MeasurementParameters,":","=")

	SVAR specComment
	SVAR specCommand
	SVAR SpecSourceFileName
	string/g ListOfASBParameters=""
	ListOfASBParameters =  IN2Z_NVARRplcKwString("ListOfASBParameters","SaThickness","SampleThickness")
	ListOfASBParameters =  IN2Z_SVARRplcKwString("ListOfASBParameters","Sample","specComment")

	ListOfASBParameters+="ASWidthUsed=0;"

	string/G NewWavenote=ListOfASBParameters+MeasurementParameters+";SpecScan="+"Imported X 23 scan from file:"+SpecSourceFileName+";"
	NewWavenote =  IN2Z_SVARRplcKwString("NewWavenote","SpecCommand","SpecCommand")
	NewWavenote =  IN2Z_SVARRplcKwString("NewWavenote","SpecComment","SpecComment")


end


Function IN2I_RecordImportedData()
	//this makes record of everything into raw data directory
	
	NewDataFolder/O root:raw
	NewDataFolder/O root:raw:importedX23
	
	setDataFolder root:Packages:X23Import
	SVAR SpecSourceFileName
	string shortFileName=StringFromList((ItemsInList(SpecSourceFileName,":" )-1), SpecSourceFileName, ":")
	string MyFolder= IN2I_GenerateLibUniqFolderName("root:raw:importedX23", shortFileName)	
	string FullMyFolder="root:raw:importedX23:"+MyFolder
	DuplicateDataFolder root:Packages:X23Import $FullMyFolder
end

Function/T IN2I_GenerateLibUniqFolderName(subfolder, newname)			//complicated way to create unique & liberal name of USAXS data
	string subfolder, newname	

	string df=GetDataFolder(1)												//thats where we start

	string LibName=CleanupName(newname, 1 )									//clean it up
	
	SetDataFolder $subfolder 
		if (CheckName(LibName, 11)!=0)					//this needs to be in root:USAXS:subfldr to work
			LibName+="_"
			LibName=UniqueName(LibName, 11, 0)			//check if the name exists and create unique name
		endif
		SetDataFolder $df								//go back
	Libname= PossiblyQuoteName(LibName)				//cleanup the name
	return Libname
end

