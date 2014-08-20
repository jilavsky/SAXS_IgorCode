#pragma rtGlobals=1		// Use modern global access method.

Menu "USAXS"
//	''--"
	"Use NIST models", IN2F_NISTModels()
end

Function IN2F_NISTModels()
	//this function prepares USAXs data for use with NIST models.
	//the use will be following:
	//create readme to explain basics to user
	//select data (DSM data)
	//create new folder for the data
	//create waves with names appropriate for NIST models
	//and let users to model as they wish in their separate folder... Good luck
	
IN2F_SelectModelData()

IN2F_MakeFoldersCopyData()

IN2F_CreateGraphsAndLeaveUser()

end


Function IN2F_CreateGraphsAndLeaveUser() 
	DoWindow ModelingGraph
	if (V_Flag)
		DoWindow/K ModelingGraph	
	endif

	string Ywave=stringFromList(0,WaveList("*_absI",";",""))
	string Xwave=stringFromList(0,WaveList("*_absq",";",""))
	string Ewave=stringFromList(0,WaveList("*_abss",";",""))
	Wave Ywv=$Ywave
	Wave Xwv=$Xwave
	Wave Ewv=$Ewave
	
	PauseUpdate; Silent 1		// building window...
	Display/K=1 /W=(54,58.25,448.5,266.75) Ywv vs Xwv as "ModelingGraph"
	DoWindow/C ModelingGraph
	ModifyGraph mode=3
	ModifyGraph marker=19
	ModifyGraph msize=1
	ModifyGraph log=1
	ModifyGraph mirror=1
	Label left "Intensity [inverse cm]"
	Label bottom "Q vector [A]"
	ErrorBars $Ywave Y,wave=(Ewv,Ewv)
End



Function IN2F_MakeFoldersCopyData()
		//here we create the folders

		string Cdf=GetDataFolder(0)
		string CdfLong="root:Modeling:"+Cdf
		NewDataFolder/O root:Modeling
		NewDataFolder/O $CdfLong
	
		//and now lets copy the data there
		string tempName=CdfLong+":"
		//first need to remove ' from the Cdf, if it is liberal... 
		//do it here
		if(cmpstr(cdf[0],"'")==0)		//liberal, remove first and last character
			Cdf=Cdf[1,inf]
			Cdf=Cdf[0, strlen(Cdf)-2]
		endif
		//then check length
		if (strlen(Cdf)>25)
			Cdf=Cdf[0,25]
		endif
		//and now make them liberal again...
		Wave DSM_Int
		Wave DSM_Qvec
		Wave DSM_Error
		Duplicate/O DSM_Int, $(tempName+PossiblyQuoteName(Cdf+"_absI"))
		Duplicate/O DSM_Qvec, $(tempName+PossiblyQuoteName(Cdf+"_absq"))
		Duplicate/O DSM_Error, $(tempName+PossiblyQuoteName(Cdf+"_abss"))
		Duplicate/O DSM_Error, $(tempName+PossiblyQuoteName(Cdf+"_abswt"))
		
		SetDataFolder $CdfLong
		string WaveNm=(Cdf+"_abswt")
		Wave Weight=$WaveNm
		Weight=1/DSM_Error
end


Function IN2F_SelectModelData()			//This procedure just sets folder where are the data
	
	string df
	Prompt df, "Select folder with data to model", popup, IN2F_NextDataToModel()+";"+IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "DSM_Int", 1)
	DoPrompt "Modeling folder selection", df
	if (V_Flag)
		Abort 
	endif	
			
	SetDataFolder df
	SVAR CurrentModel=root:Packages:USAXS:CurrentModel
	CurrentModel = df
	IN2G_AppendAnyText("Data for modeling converted for :"+ df)

end
 
 Function/T IN2F_NextDataToModel()					//this returns next Folder in order to evaluate 

	string ListOfData=IN2G_FindFolderWithWaveTypes("root:USAXS:", 5, "DSM_Int", 1)	
	SVAR/Z LastModel=root:Packages:USAXS:CurrentModel				//global string for current folder info
	if (!SVAR_Exists(LastModel))
		NewDataFolder/O root:Packages
		NewDataFolder/O root:Packages:USAXS
		string/g root:packages:USAXS:CurrentModel								//create if nesessary
		SVAR LastModel=root:Packages:USAXS:CurrentModel
		LastModel=""
	endif
	variable start=FindListItem(LastModel, ListOfData)
	if (start==-1)
		return StringFromList(0,ListOfdata)
	else
		ListOfdata=ListOfData[start,inf]
		return StringFromList(1,ListOfdata)
	endif
end




