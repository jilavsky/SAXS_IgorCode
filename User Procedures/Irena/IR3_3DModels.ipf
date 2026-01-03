#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.03

Constant IR3AMassFrAggVersionNumber 	= 1.03
Constant IR3TPOVPDBVersionNumber 		= 1.00
Constant IR3TTwoPhaseVersionNumber 	= 1.00


//*************************************************************************\
//* Copyright (c) 2005 - 2026, Argonne National Laboratory
//* This file is distributed subject to a Software License Agreement found
//* in the file LICENSE that is included with this distribution. 
//*************************************************************************/

//1.03 added Optimized growth - gorws number of aggregates and searches for best matching one... 
//1.02 added MultiParticleAttraction parameter. 
//1.01 3dAggregate added ability ot grow N aggregates and Compare Stored graph
//1.00 first version, added code for 3DMassFractalAggregate from Alex McGlassson 
//			note: this ipf file also contains tools for import of pdb (ATSAS, GNOM produced output files) and for POV files produced by SAXSMorph. 
//			and some Gizmo tools to be used to visualize these. 



//   Parameters description for referecne... This belongs to manual. 
//	MultiParticleAttraction = "Multi Part attr" controls how particle attached when approaching existing aggregate. 
// Sticking method controls how particle attached when approaching existing aggregate
// MultiParticleAttraction = "Neutral;Attractive;Repulsive;Not Allowed;"
// when : neutral, probablity of attaching does not depend on number of particles in neaest neighbor sphere aroudn the new position. 
// when : Attractive more particles increase the probability of attaching
// when : Repulsive more particles decrease the probability of attaching.
// consequence - Repulsive creases larger, more open particles, Attractive creates more compact particles
// Sticking method = which neighbors are counted as "nearest neigbor"
//	1 : only in x, y, znd z direction on lattice, their center distance is < 1.1
//	2 : in x,z,y and in xy, yz, xz planes, their distacne is < 1.05*sqrt(2) 
//	3 : also in xyz body diagonal, their distacne is < 1.05*sqrt(3)
// to grow compact particle set sticking method 1, low sticking probability and positive attraction, I got df up to 2.55   
// to grow open particle, set sticking method 3, high sticking probability and negative attraction, I got df below 2 this way.  
// 
//	SVAR MultiParticleAttraction = root:Packages:AggregateModeling:MultiParticleAttraction 
//	variable StickingProbability1, StickingProbabilityM1,StickingProbabilityM2, StickingProbabilityLoc
//	if(StringMatch(MultiParticleAttraction, "Neutral"))
//		StickingProbability1= StickingProbability
//		StickingProbabilityM1= StickingProbability
//		StickingProbabilityM2= StickingProbability
//	elseif(StringMatch(MultiParticleAttraction, "Attractive"))
//		StickingProbability1= StickingProbability
//		StickingProbabilityM1= (StickingProbability+100)/2
//		StickingProbabilityM2= (StickingProbability+300)/4
//	elseif(StringMatch(MultiParticleAttraction, "Repulsive"))
//		StickingProbability1 = StickingProbability
//		StickingProbabilityM1 = (StickingProbability+10)/2
//		StickingProbabilityM2 = (StickingProbability+30)/4
//	elseif(StringMatch(MultiParticleAttraction, "Not allowed"))
//		StickingProbability1 = StickingProbability
//		StickingProbabilityM1 = 1
//		StickingProbabilityM2 = 0
//	else
//		StickingProbability1 = StickingProbability
//		StickingProbabilityM1 = StickingProbability
//		StickingProbabilityM2 = StickingProbability
//	endif



//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//			3D packages, 2018-12-26
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//			Main packages as they are called from main menu. 
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3A_MassFractalAggregate()
		//this calls Fractal aggregate controls. 
	DoWIndow FractalAggregatePanel
	if(V_Flag)
		DoWIndow/K FractalAggregatePanel
	endif
	IN2G_CheckScreenSize("height",670)
	IR3A_InitializeMassFractAgg()
	IR3A_FractalAggregatePanel()
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("FractalAggregatePanel", IR3AMassFrAggVersionNumber,1)
	IR3A_UpdatePanelValues()	

end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3P_ImportPOVPDB()
		//this calls GUI for import of various 3D formats - POV from SAXSMorph and PDB files from GNOM.
		//this reads POV files: IR3T_ReadPOVFile(dimx,dimy,dimz)
		//for pdb there is code in Subversion which needs to be added here... 
		//DoAlert /T="Unfinished" 0, "IR3A_ImportPOVPDB() is not finished yet" 
		//this calls POV/PDB import controls. 
	DoWIndow/K/Z POVPDBPanel
	DoWIndow/K/Z POV3DData

	IN2G_CheckScreenSize("height",670)
	IR3P_InitializePOVPDB()
	IR3P_POVPDBPanel()
	ING2_AddScrollControl()
	IR1_UpdatePanelVersionNumber("POVPDBPanel", IR3TPOVPDBVersionNumber,1)
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3A_Display3DData()
		//this calls controls which can display 3D data generated by other 3D code or imported by POV/PDB importer
		//use Gizmo, add some way of selecting data and do some simple tricks... 
		DoAlert /T="Unfinished" 0, "IR3A_Display3DData() is not finished yet" 
		//this may be useful: IR3T_Convert3DMatrixToList(My3DVoxelWave, threshVal)
end
//******************************************************************************************************************************************************
//			Utility functions
//******************************************************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3T_MainCheckVersion()	
	//this needs to get more of these lines for each tool/panel... 
	DoWindow TwoPhaseSystems
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("TwoPhaseSystems", IR3TTwoPhaseVersionNumber))
			DoAlert /T="The Two Phase 3D modeling panel was created by incorrect version of Irena " 1, "Two Phase 3D modeling tool may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				DoWindow/K TwoPhaseSystems
 				IR3T_TwoPhaseSystem()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR3T_InitializeTwoPhaseSys()
			endif
		endif
	endif
end 
//*****************************************************************************************************************
//*****************************************************************************************************************
Function IR3P_MainCheckVersion()	
	//this needs to get more of these lines for each tool/panel... 
	DoWindow POVPDBPanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("POVPDBPanel", IR3TPOVPDBVersionNumber))
			DoAlert /T="The POV/PDB panel was created by incorrect version of Irena " 1, "POV/PDB panel may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				DoWindow/K POVPDBPanel
 				IR3P_ImportPOVPDB()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR3P_InitializePOVPDB()
			endif
		endif
	endif 
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3A_MainCheckVersion()	
	//this needs to get more of these lines for each tool/panel... 
	DoWindow FractalAggregatePanel
	if(V_Flag)
		if(!IR1_CheckPanelVersionNumber("FractalAggregatePanel", IR3AMassFrAggVersionNumber))
			DoAlert /T="The Mass Fractal Aggregate panel was created by incorrect version of Irena " 1, "Mass Fractal Aggregate may need to be restarted to work properly. Restart now?"
			if(V_flag==1)
				DoWindow/K FractalAggregatePanel
 				IR3A_MassFractalAggregate()
			else		//at least reinitialize the variables so we avoid major crashes...
				IR3A_InitializeMassFractAgg()
			endif
		endif
	endif
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//			3D aggregate code, modified from Alex 2018-12-26
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

Function IR3A_FractalAggregatePanel()
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(5,20,395,680) as "Fractal Aggregate Model"
	DoWindow/C FractalAggregatePanel
	DefaultGUIControls /W=FractalAggregatePanel ///Mac os9
	TitleBox MainTitle title="\Zr200Mass Fractal Aggregate model",pos={20,0},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={350,24},anchor=MC,fColor=(0,0,52224)
	Button GetHelp,pos={305,50},size={80,15},fColor=(65535,32768,32768), proc=IR3A_PanelButtonProc,title="Get Help", help={"Open www manual page for this tool"}	//<<< fix button to help!!!
	//COPY FROM IR2U_UnifiedEvaPanelFnct()
	Checkbox  CurrentResults, pos={10,52}, size={50,15}, variable =root:packages:AggregateModeling:CurrentResults
	Checkbox  CurrentResults, title="Current Unified Fit",mode=1,proc=IR3A_CheckProc
	Checkbox  CurrentResults, help={"Select of you want to analyze current results in Unified Fit tool"}
	Checkbox StoredResults, pos={150,52}, size={50,15}, variable =root:packages:AggregateModeling:StoredResults
	Checkbox  StoredResults, title="Stored Unified Fit results",mode=1, proc=IR3A_CheckProc
	Checkbox  StoredResults, help={"Select of you want to analyze Stored Unified fit data"}
	
	string UserDataTypes=""
	string UserNameString=""
	string XUserLookup=""
	string EUserLookup=""
	IR2C_AddDataControls("AggregateModeling","FractalAggregatePanel","","UnifiedFitIntensity",UserDataTypes,UserNameString,XUserLookup,EUserLookup, 1,1)
	NVAR UseResults = root:Packages:AggregateModeling:UseResults
	UseResults=1
	STRUCT WMCheckboxAction CB_Struct
	CB_Struct.ctrlName="UseResults"
	CB_Struct.checked=1
	CB_Struct.win="FractalAggregatePanel"
	CB_Struct.eventcode=2
	
	IR2C_InputPanelCheckboxProc(CB_Struct)
	Checkbox  UseResults, disable=1
	KillControl UseModelData
	KillCOntrol UseQRSData
	PopupMenu ErrorDataName, disable=1
	PopupMenu QvecDataName, disable=1
	PopupMenu SelectDataFolder,pos={10,75}
	PopupMenu SelectDataFolder proc=IR3A_PopMenuProc
	PopupMenu IntensityDataName,pos={10,100}
	PopupMenu IntensityDataName proc=IR3A_PopMenuProc	
	Setvariable FolderMatchStr, pos={288,75}
	KillControl Qmin
	KillControl Qmax
	KillControl QNumPoints

	PopupMenu AvailableLevels,pos={288,100},size={109,20},proc=IR3A_PopMenuProc,title="Level:"
	PopupMenu AvailableLevels,help={"Select level to use for data analysis"}
	PopupMenu AvailableLevels,mode=1,popvalue="---", value=#"root:Packages:AggregateModeling:AvailableLevels"
	SetVariable BrFract_ErrorMessage, title=" ",value=root:Packages:AggregateModeling:BrFract_ErrorMessage, noedit=1
	SetVariable BrFract_ErrorMessage, pos={5,122}, size={375,20}, frame=0, help={"Error message, if any"}	

	SetVariable BrFract_z, pos={10,140}, size={200,20}, title="Deg. of aggregation z     = ", help={"Degree of aggregation, 1+G2/G1"}, format="%.4g"
	SetVariable BrFract_z, variable=root:Packages:AggregateModeling:BrFract_z, noedit=1,limits={-inf,inf,0},  disable=0,noedit=1,frame=0, bodyWidth=50
	SetVariable BrFract_Rg1, pos={240,140}, size={150,20}, title="Rg primary part [A] =  ", help={"Rg of primary particle"}, format="%.4g",bodyWidth=50
	SetVariable BrFract_Rg1, variable=root:Packages:AggregateModeling:BrFract_Rg1, noedit=1,limits={-inf,inf,0},  disable=0,noedit=1,frame=0

	SetVariable BrFract_dmin, pos={10,160}, size={200,20}, title="Min. dimension  dmin = ", help={"Minimum dimension of the aggregate"}, format="%.4g"
	SetVariable BrFract_dmin, variable=root:Packages:AggregateModeling:BrFract_dmin, noedit=1,limits={-inf,inf,0},  disable=0,noedit=1,frame=0, bodyWidth=50
	SetVariable BrFract_df, pos={240,160}, size={150,20}, title="Fractal dimension df = ", help={"Mass fractal dimension of the aggregate"}, format="%.4g"
	SetVariable BrFract_df, variable=root:Packages:AggregateModeling:BrFract_df, noedit=1,limits={-inf,inf,0},  disable=0,noedit=1,frame=0, bodyWidth=50
//	SetVariable BrFract_fM, pos={25,190}, size={120,20}, title="fM =   ", help={"Parameter as defined in the references"}, format="%.4g"
//	SetVariable BrFract_fM, variable=root:Packages:AggregateModeling:BrFract_fM, noedit=1,limits={-inf,inf,0},  disable=0,noedit=1,frame=0

	SetVariable BrFract_c, pos={10,180}, size={200,20}, title="Connect. dimension c     = ", help={"Connectivity dimension of the aggregate"}, format="%.4g"
	SetVariable BrFract_c, variable=root:Packages:AggregateModeling:BrFract_c, noedit=1,limits={-inf,inf,0},  disable=0,noedit=1,frame=0, bodyWidth=50
	SetVariable BrFract_Rg2, pos={240,180}, size={150,20}, title="Rg aggregate [A]  =  ", help={"Rg of aggregate"}, format="%.4g",bodyWidth=50
	SetVariable BrFract_Rg2, variable=root:Packages:AggregateModeling:BrFract_Rg2, noedit=1,limits={-inf,inf,0},  disable=0,noedit=1,frame=0
	
	//	R - aggregate size 
	//	df - Mass fractal dimension of the aggregate 
	//	p - short circuit path length 
	//	s - connective path length 
	//	dmin - minimum dimension of the aggregate 
	//	c - connecGvity dimension of the aggregate 
	//	s - connecGve path length of the aggregate
	
	//and this is new code
	TitleBox Info1 title="\Zr160Unified results",pos={40,26},frame=0,fstyle=1, fixedSize=1,size={280,18},fColor=(0,0,52224)
	TitleBox FakeLine1 title=" ",fixedSize=1,size={350,3},pos={16,205},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info2 title="\Zr160Model input parameters",pos={10,215},frame=0,fstyle=1, fixedSize=1,size={280,18},fColor=(0,0,52224)
	SetVariable AggregateModeling,pos={10,240},size={190,16},noproc,title="Deg. of Agg. \"z\" (250) ", help={"Size of aggregate, degree of aggregation"}
	SetVariable AggregateModeling,limits={10,Inf,0},variable= root:Packages:AggregateModeling:DegreeOfAggregation, bodyWidth=50
	SetVariable StickingProbability,pos={10,265},size={190,16},noproc,title="Sticking prob. (10-100) ", help={"Sticking probablility, 100 for DLA, less for RLA"}
	SetVariable StickingProbability,limits={10,100,0},variable= root:Packages:AggregateModeling:StickingProbability, bodyWidth=50
	SetVariable NumberOfTestPaths,pos={10,290},size={190,16},noproc,title="Max paths/end (1k-10k) ", help={"Max measured paths per end point for parameter evaluation. Larger = possibly longer times but is more precise"}
	SetVariable NumberOfTestPaths,limits={1000,100000,0},variable= root:Packages:AggregateModeling:NumberOfTestPaths, bodyWidth=50

	SetVariable RgPrimary,pos={210,240},size={170,16},noproc,title="Primary Rg[A] (10) ", help={"Size of primary particle from which Aggregate is created"}
	SetVariable RgPrimary,limits={10,Inf,0},variable= root:Packages:AggregateModeling:RgPrimary, bodyWidth=50
	PopupMenu AllowedNearDistance,pos={230,260},size={150,20},proc=IR3A_PopMenuProc,title="Sticking method:"
	PopupMenu AllowedNearDistance,help={"Which neighbors are allowed to stick"}
	NVAR AllowedNearDistance=root:Packages:AggregateModeling:AllowedNearDistance
	PopupMenu AllowedNearDistance,mode=1,popvalue=num2str(AllowedNearDistance), value="1;2;3;"

	PopupMenu MParticleAttraction,pos={230,280},size={150,20},proc=IR3A_PopMenuProc,title="Multi Part. attr:"
	PopupMenu MParticleAttraction,help={"If there are more particles neaby, is chance of attaching? "}
	SVAR MultiParticleAttraction=root:Packages:AggregateModeling:MultiParticleAttraction
	PopupMenu MParticleAttraction,mode=1,popvalue=MultiParticleAttraction, value="Neutral;Attractive;Repulsive;Not allowed;"
	

	//Growth Tabs definition
	TabControl GrowthTabs,pos={2,310},size={387,170},proc=IR3A_GrowthTabProc
	TabControl GrowthTabs,tabLabel(0)=" Grow One ",tabLabel(1)=" Grow many "
	TabControl GrowthTabs,tabLabel(2)=" Find Best Growth "

	Button Grow1AggAll,pos={15,335},size={150,18}, proc=IR3A_PanelButtonProc,title="Grow 1 Agg, graph", help={"Perform all steps and generate 3D graph"}
	Button GrowNAggAll,pos={15,335},size={150,18}, proc=IR3A_PanelButtonProc,title="Grow N Agg.", help={"Generate N aggregates randomly"}
	PopupMenu NUmberOfTestAggregates,pos={195,335},size={150,20},proc=IR3A_PopMenuProc,title="N ="
	PopupMenu NUmberOfTestAggregates,help={"How many test aggregates to grow"}
	NVAR NUmberOfTestAggregates=root:Packages:AggregateModeling:NUmberOfTestAggregates
	PopupMenu NUmberOfTestAggregates,mode=1,popvalue=num2str(NUmberOfTestAggregates), value="5;10;20;30;50;"

	Button GrowOptimizedAgg,pos={15,335},size={150,18}, proc=IR3A_PanelButtonProc,title="Grow Best Match Agg", help={"Try to find best aggregate for parameters below"}

	SetVariable CurrentMisfitValue, pos={250,338}, size={120,20}, title="Misfit = ", help={"Current misfit between dmin/c of model and target"}, format="%.4f", fColor=(1,16019,65535),valueColor=(16385,16388,65535)
	SetVariable CurrentMisfitValue, variable=root:Packages:AggregateModeling:CurrentMisfitValue, limits={-inf,inf,0},  disable=0,noedit=1,frame=0, bodyWidth=50,fstyle=1, fsize=11
	//repeat the target values
	SetVariable Target_dmin, pos={28,360}, size={120,20}, title="Target: dmin = ", help={"Minimum dimension of the aggregate"}, format="%.3g",fColor=(1,16019,65535),valueColor=(16385,16388,65535)
	SetVariable Target_dmin, variable=root:Packages:AggregateModeling:BrFract_dmin, noedit=1,limits={-inf,inf,0},  disable=0,noedit=1,frame=0, bodyWidth=50, proc=IR3A_SetVarProc
	SetVariable Target_c, pos={120,360}, size={120,20}, title="c =  ", help={"Connectivity dimension of the aggregate"}, format="%.3g", fColor=(1,16019,65535),valueColor=(16385,16388,65535)
	SetVariable Target_c, variable=root:Packages:AggregateModeling:BrFract_c, limits={-inf,inf,0},  disable=0,noedit=1,frame=0, bodyWidth=50, proc=IR3A_SetVarProc
	SetVariable Target_df, pos={265,360}, size={120,20}, title="Target df =  ", help={"Df value for target"}, format="%.3g", fColor=(1,16019,65535),valueColor=(16385,16388,65535)
	SetVariable Target_df, variable=root:Packages:AggregateModeling:BrFract_df, limits={-inf,inf,0},  disable=0,noedit=1,frame=0, bodyWidth=50, proc=IR3A_SetVarProc

	// here are resulting values
	SetVariable dminValue,pos={40,380},size={100,20},noproc,title="dmin = ", help={"Minimum dimension of the aggregate"},limits={10,100,0}
	SetVariable dminValue,variable= root:Packages:AggregateModeling:dminValue, bodyWidth=80, disable=0,noedit=1,frame=0, format="%.3g"
	SetVariable cValue,pos={150,380},size={100,20},noproc,title="c = ", help={"Connectivity dimension of the aggregate"},limits={10,100,0}
	SetVariable cValue,variable= root:Packages:AggregateModeling:cValue, bodyWidth=80, disable=0,noedit=1,frame=0, format="%.3g"
	SetVariable dfValue,pos={280,380},size={100,20},noproc,title="df = ", help={"Mass fractal dimension of the aggregate"},limits={0,3,0}, format="%.3g"
	SetVariable dfValue,variable= root:Packages:AggregateModeling:dfValue, bodyWidth=80, disable=0,noedit=1,frame=0

	SetVariable MaxNumTests,pos={60,380},size={100,20},proc=IR3A_SetVarProc,title="Max tries =   ", help={"Maximum number of tries"},limits={10,500,10}
	SetVariable MaxNumTests,variable= root:Packages:AggregateModeling:MaxNumTests, bodyWidth=80, disable=0,frame=1, format="%.0f"
	SetVariable MinSearchTargetValue,pos={250,380},size={100,20},noproc,title="Max misfit =   ", help={"Target fit value (see manual)"},limits={0.0001,1,0}, format="%.4f"
	SetVariable MinSearchTargetValue,variable= root:Packages:AggregateModeling:MinSearchTargetValue, bodyWidth=80, disable=0,frame=1

	Checkbox  VaryStickingProbability, pos={20,400}, size={50,15}, variable =root:packages:AggregateModeling:VaryStickingProbability
	Checkbox  VaryStickingProbability, title="Vary Sticking Prob",mode=0, proc=IR3A_CheckProc
	Checkbox  VaryStickingProbability, help={"Vary Sticking probability"}

	SetVariable StickingProbMin,pos={150,400},size={100,20},noproc,title="Min = ", help={"Low limit of sticking probability"},limits={5,80,5}
	SetVariable StickingProbMin,variable= root:Packages:AggregateModeling:StickingProbMin, bodyWidth=80, disable=0,frame=1, format="%.0f"
	SetVariable StickingProbMax,pos={280,400},size={100,20},noproc,title="Max = ", help={"High limit of sticking probability"},limits={10,90,5}, format="%.0f"
	SetVariable StickingProbMax,variable= root:Packages:AggregateModeling:StickingProbMax, bodyWidth=80, disable=0,frame=1

	PopupMenu StickProbNumSteps,pos={20,420},size={150,20},proc=IR3A_PopMenuProc,title="N ="
	PopupMenu StickProbNumSteps,help={"How many steps in Sticking Probability? "}
	NVAR StickProbNumStepsNum=root:Packages:AggregateModeling:StickProbNumSteps
	PopupMenu StickProbNumSteps,mode=1,popvalue=num2str(StickProbNumStepsNum), value="5;10;15;20;"
	SetVariable TotalGrowthsPlanned,pos={20,445},size={210,16},noproc,title="Total number of growths = ", help={"How many growths will be tried... "},limits={0,inf,0}
	SetVariable TotalGrowthsPlanned,variable= root:Packages:AggregateModeling:TotalGrowthsPlanned, disable=0,noedit=1,frame=0


	SetVariable RValue,pos={40,400},size={100,16},noproc,title="R [A] = ", help={"R of the aggregate, Rg/dp"},limits={10,100,0}, format="%6.2f"
	SetVariable RValue,variable= root:Packages:AggregateModeling:RxRgPrimaryValue, bodyWidth=80, disable=0,noedit=1,frame=0
	SetVariable pValue,pos={150,400},size={100,16},noproc,title="p = ", help={"Short circuit path length"},limits={10,100,0}, format="%6.0f"
	SetVariable pValue,variable= root:Packages:AggregateModeling:pValue, bodyWidth=80, disable=0,noedit=1,frame=0
	SetVariable sValue,pos={280,400},size={100,16},noproc,title="s = ", help={"Connective path length of the aggregate"},limits={10,100,0}
	SetVariable sValue,variable= root:Packages:AggregateModeling:sValue, bodyWidth=80, disable=0,noedit=1,frame=0, format="%6.0f"

	SetVariable TrueStickingProbability pos={20,430},size={200,16},noproc,title="True Sticking Prob. [%] = ", help={"True Sticking Probability during aggregate growth"}
	SetVariable TrueStickingProbability variable=root:Packages:AggregateModeling:TrueStickingProbability, noedit=1,frame=0,limits={10,100,0}, format="%2.2d"

	Button Display3DMFASummary,pos={220,423},size={150,18}, proc=IR3A_PanelButtonProc,title="Summary Notebook", help={"Display summary notebook for 3D Mass Fractal Aggregate"}
	Button SaveAggregateData,pos={220,447},size={150,18}, proc=IR3A_PanelButtonProc,title="Store Current Aggregate", help={"Copy this aggregate with parameters in a folder"}
	TitleBox FakeLine2 title=" ",fixedSize=1,size={330,3},pos={16,469},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)

	TitleBox ListBoxTitle title="\Zr130Saved 3D Mass Fract aggregates",size={250,15},pos={5,480},frame=0,fColor=(0,0,52224)
	wave/T Stored3DAggregates= root:Packages:AggregateModeling:Stored3DAggregates
	wave Stored3DAggSelections= root:Packages:AggregateModeling:Stored3DAggSelections
	ListBox StoredAggregates pos={5,500}, size={250,145}
	ListBox StoredAggregates listWave=Stored3DAggregates,mode=1,selRow=-1,selWave=Stored3DAggSelections
	
	Button Display1DData,pos={262,480},size={120,18}, proc=IR3A_PanelButtonProc,title="Display 1D Graph", help={"Display 1 D graph with Intensity vs Q for these data"}
	Button Display3DMassFracGizmo,pos={262,505},size={120,18}, proc=IR3A_PanelButtonProc,title="Display 3D Graph", help={"Display Gizmo with 3D Mass Fractal Aggregate"}
	Button Calculate1DIntensity,pos={262,530},size={120,18}, proc=IR3A_PanelButtonProc,title="Calculate 1D Int.", help={"Calculate using UF 1D intensity and append to graph"}
	Button Model1DIntensity,pos={262,555},size={120,18}, proc=IR3A_PanelButtonProc,title="Monte Carlo 1D Int.", help={"Calculate using Monte Carlo 1D intensity and append to graph"}
	Button CompareStoredResults,pos={262,580},size={120,18}, proc=IR3A_PanelButtonProc,title="Compare Stored", help={"Present statistcs on stored results"}
	Button DeleteStoredResults,pos={262,635},size={100,15}, proc=IR3A_PanelButtonProc,title="Delete all Stored", help={"Delete all stored results"}
	//the above button works, but the results seem to take forever and do not look too good.  
	//IR3A_SetControlsInPanel() - this is done by function called above anyway. 
	IR3A_Create3DAggListForListbox()
end

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3A_GrowthTabProc(tca) : TabControl
	STRUCT WMTabControlAction &tca

	switch( tca.eventCode )
		case 2: // mouse up
			Variable tab = tca.tab
			IR3A_CalculateAggValues()
			Button Grow1AggAll win=FractalAggregatePanel, disable=Tab!=0
			Button GrowNAggAll win=FractalAggregatePanel, disable=Tab!=1
			PopupMenu NUmberOfTestAggregates win=FractalAggregatePanel, disable=Tab!=1
			Button GrowOptimizedAgg win=FractalAggregatePanel, disable=Tab!=2
			if(tab==0 || tab==1)
				SetVariable Target_dmin win=FractalAggregatePanel, noedit=1, disable=0, frame=0 
				SetVariable Target_c win=FractalAggregatePanel, noedit=1, disable=0,frame=0 
				SetVariable Target_df win=FractalAggregatePanel, noedit=1, disable=0,frame=0 
				SetVariable dminValue win=FractalAggregatePanel, disable=0
				SetVariable cValue win=FractalAggregatePanel, disable=0
				SetVariable dfValue win=FractalAggregatePanel, disable=0
				SetVariable RValue win=FractalAggregatePanel, disable=0
				SetVariable pValue win=FractalAggregatePanel, disable=0
				SetVariable sValue win=FractalAggregatePanel, disable=0
				SetVariable TrueStickingProbability  win=FractalAggregatePanel, disable=0
				Button Display3DMFASummary  win=FractalAggregatePanel, disable=0
				Button SaveAggregateData  win=FractalAggregatePanel, disable=0
				SetVariable MaxNumTests  win=FractalAggregatePanel, disable=1
				SetVariable MinSearchTargetValue  win=FractalAggregatePanel, disable=1
				Checkbox  VaryStickingProbability  win=FractalAggregatePanel, disable=1
				SetVariable StickingProbMin  win=FractalAggregatePanel, disable=1
				SetVariable StickingProbMax  win=FractalAggregatePanel, disable=1
				SetVariable TotalGrowthsPlanned  win=FractalAggregatePanel, disable=1
				PopupMenu StickProbNumSteps  win=FractalAggregatePanel, disable=1
			elseif(tab==2)
				NVAR Target_C=root:Packages:AggregateModeling:BrFract_c
				NVAR Target_dmin = root:Packages:AggregateModeling:BrFract_dmin
				if(numtype(Target_C)!=0)
					Target_C = 1.6
				endif
				if(numtype(Target_dmin)!=0)
					Target_dmin = 1.2
				endif
				SetVariable Target_dmin win=FractalAggregatePanel, noedit=0, disable=0,frame=1
				SetVariable Target_c win=FractalAggregatePanel, noedit=0, disable=0,frame=1
				SetVariable Target_df win=FractalAggregatePanel, noedit=1, disable=1,frame=0 
				SetVariable dminValue win=FractalAggregatePanel, disable=1
				SetVariable cValue win=FractalAggregatePanel, disable=1
				SetVariable dfValue win=FractalAggregatePanel, disable=1
				SetVariable RValue win=FractalAggregatePanel, disable=1
				SetVariable pValue win=FractalAggregatePanel, disable=1
				SetVariable sValue win=FractalAggregatePanel, disable=1
				SetVariable TrueStickingProbability  win=FractalAggregatePanel, disable=1
				Button Display3DMFASummary  win=FractalAggregatePanel, disable=1
				Button SaveAggregateData  win=FractalAggregatePanel, disable=1


				SetVariable MaxNumTests  win=FractalAggregatePanel, disable=0
				SetVariable MinSearchTargetValue  win=FractalAggregatePanel, disable=0
				Checkbox  VaryStickingProbability  win=FractalAggregatePanel, disable=0
				SetVariable TotalGrowthsPlanned  win=FractalAggregatePanel, disable=0
				NVAR Showme = root:packages:AggregateModeling:VaryStickingProbability
				SetVariable StickingProbMin  win=FractalAggregatePanel, disable=!Showme
				SetVariable StickingProbMax  win=FractalAggregatePanel, disable=!Showme
				PopupMenu StickProbNumSteps  win=FractalAggregatePanel, disable=!Showme
				
			endif
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

Function IR3A_SetVarProc(sva) : SetVariableControl
	STRUCT WMSetVariableAction &sva

	switch( sva.eventCode )
		case 1: // mouse up
		case 2: // Enter key
		case 3: // Live update
			Variable dval = sva.dval
			String sval = sva.sval
//			NVAR dmin = root:Packages:AggregateModeling:BrFract_dmin
//			NVAR cval = root:Packages:AggregateModeling:BrFract_c
//			NVAR df = root:Packages:AggregateModeling:BrFract_df
//			if(StringMatch(sva.ctrlName, "Target_dmin") || StringMatch(sva.ctrlName, "Target_c"))
//				df = dmin * cval
//			endif
			//MaxNumTests needs simply this below run anyway... 
			IR3A_CalculateAggValues()
			
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
static Function IR3A_Create3DAggListForListbox()
	DFref oldDf= GetDataFolderDFR()


	DOWindow FractalAggregatePanel
	if(!V_Flag)
		return 0
	endif 
	wave/Z Stored3DAggSelections= root:Packages:AggregateModeling:Stored3DAggSelections
	if(!WaveExists(Stored3DAggSelections))
		abort
	endif
	wave/T Stored3DAggregates= root:Packages:AggregateModeling:Stored3DAggregates
	wave/T Stored3DAggregatesPaths= root:Packages:AggregateModeling:Stored3DAggregatesPaths
	variable NumOfFolders
	string CurrentList, tempStr
	if(DataFolderExists("root:MassFractalAggregates"))
		setDataFolder root:MassFractalAggregates
		CurrentList=stringByKey("FOLDERS",DataFolderDir(1),":")
		NumOfFolders = ItemsInList(CurrentList,",")+1
	else
		CurrentList=""
		NumOfFolders = 1
	endif
	redimension/N=(NumOfFolders) Stored3DAggregates, Stored3DAggSelections, Stored3DAggregatesPaths
	Stored3DAggSelections = 0
	Stored3DAggregates[0] = "Current model"
	Stored3DAggregatesPaths[0] = "Current model"
	variable i
	if(NumOfFolders>1)
		For(i=0;i<NumOfFolders-1;i+=1)
			tempStr = StringFromList(i, CurrentList, ",")
			Stored3DAggregatesPaths	[i+1] ="root:MassFractalAggregates:"+possiblyQUoteName(tempStr)
			Stored3DAggregates	[i+1] = num2str(i)+" : "+IR3A_BuildUser3DAggNames("root:MassFractalAggregates:"+possiblyQUoteName(tempStr))
		endfor	
	endif
	DoUpdate  /W=FractalAggregatePanel 
	setDataFOlder OldDf
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
static Function/T IR3A_BuildUser3DAggNames(PathToFolder)
	string PathToFOlder
	DFref oldDf= GetDataFolderDFR()

	string UserFriendlyString=""
	SetDataFolder PathToFolder
	NVAR DOA=DegreeOfAggregation
	NVAR Stick=StickingProbability
	//NVAR SMeth=StickingMethod
	NVAR dMin=DminValue
	NVAR df = dfValue
	NVAR cval= cValue
	UserFriendlyString="z="+num2str(DOA)+",dmin="+num2str(IN2G_roundDecimalPlaces(dmin,2))+",c="+num2str(IN2G_roundDecimalPlaces(cval,2))+",df="+num2str(IN2G_roundDecimalPlaces(df,2))
	setDataFOlder OldDf
	return UserFriendlyString
end

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
static Function IR3A_Display1DIntensity()

	//DoAlert /T="Need calcuation here" 0, "IR3A_Display1DIntensity is not finished yet"
	NVAR useCurrentResults = root:packages:AggregateModeling:CurrentResults
	NVAR useStoredResults = root:packages:AggregateModeling:StoredResults
	if(useCurrentResults+useStoredResults!=1)
		useStoredResults = 0
		useCurrentResults = 1
	endif
	if(useCurrentResults)
		Wave/Z IntWaveOriginal = root:Packages:Irena_UnifFit:OriginalIntensity
		Wave/Z QwaveOriginal = root:Packages:Irena_UnifFit:OriginalQvector
		Wave/Z ErrorOriginal = root:Packages:Irena_UnifFit:OriginalError
		if(!WaveExists(IntWaveOriginal))
			abort
		endif
	else //use stored results, in this case the strings shoudl be set...
		SVAR DataFolderName = root:Packages:AggregateModeling:DataFolderName
		SVAR IntensityWaveName = root:Packages:AggregateModeling:IntensityWaveName
		SVAR QWavename = root:Packages:AggregateModeling:QWavename
		SVAR ErrorWaveName = root:Packages:AggregateModeling:ErrorWaveName
		Wave/Z IntWaveOriginal = $(DataFolderName+IntensityWaveName)
		Wave/Z QwaveOriginal = $(DataFolderName+QWavename)
		Wave/Z ErrorOriginal = $(DataFolderName+ErrorWaveName)
		if(!WaveExists(IntWaveOriginal))
			abort
		endif
	endif
	string IntWvName=nameofWave(IntWaveOriginal)
	DoWIndow MassFractalAggDataPlot
	if(V_Flag)
		DoWIndow/F MassFractalAggDataPlot
	else
		Display /W=(282.75,37.25,900,400)/K=1  IntWaveOriginal vs QwaveOriginal as "Mass Fractal Aggregate 1D Data Plot"
		DoWindow/C MassFractalAggDataPlot
		ModifyGraph mode($(nameofwave(IntWaveOriginal)))=3
		ModifyGraph msize($(nameofwave(IntWaveOriginal)))=0
		ModifyGraph log=1
		ModifyGraph mirror=1
		ShowInfo
		String LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
		Label left LabelStr
		LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
		Label bottom LabelStr
		string LegendStr="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"\\s("+IntWvName+") Data intensity"
		Legend/W=MassFractalAggDataPlot/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr
		TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
		TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+GetWavesDataFolder(IntWaveOriginal,1)	
	endif
	AutoPositionWindow/R=FractalAggregatePanel MassFractalAggDataPlot
	
end


//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3A_Append1DInMassFracAgg(IntensityWV,QvectorWV)
	wave IntensityWV,QvectorWV

	DoWIndow MassFractalAggDataPlot
	if(V_Flag)
		DoWIndow/F MassFractalAggDataPlot
	else
		IR3A_Display1DIntensity()
	endif

	NVAR useCurrentResults = root:packages:AggregateModeling:CurrentResults
	NVAR useStoredResults = root:packages:AggregateModeling:StoredResults
	if(useCurrentResults+useStoredResults!=1)
		useStoredResults = 0
		useCurrentResults = 1
	endif
	//fix q rave of overlap
	//proper scaling of model... this is not so easy here, but may be needed in teh future. 
	//variable QRg2 = 0.5*pi/Level2Rg
	//variable QRg1 = 1.5*pi/Level1Rg
	//print "Scaling Model to data using integral intensities in Q range from "+num2str(QRg2)+"  to "+num2str(QRg1)
	//variable InvarModel=areaXY(A3DAgg1DQwave, Model3DAggIntensity, QRg2, QRg1)
	variable InvarModel=areaXY(QvectorWV, IntensityWV )
	variable InvarData
	//Model3DAggIntensity
	//need to also work, when no data are present. In this case the root:Packages:AggregateModeling:DataFolderName is set to non-sensical value...
	SVAR DataFolderName = root:Packages:AggregateModeling:DataFolderName
	if(strlen(DataFolderName)<4)
		//this is non sensical case. Use Model3DAggIntensity to get proper normalization
		Wave/Z IntWaveOriginal = root:Packages:Irena_UnifFit:Model3DAggIntensity
		Wave/Z QwaveOriginal = root:Packages:Irena_UnifFit:A3DAgg1DQwave
		if(!WaveExists(IntWaveOriginal))
			abort
		endif
		InvarData=areaXY(QwaveOriginal, IntWaveOriginal, QvectorWV[0], QvectorWV[numpnts(QvectorWV)-1])
	else
		if(useCurrentResults)
			Wave/Z IntWaveOriginal = root:Packages:Irena_UnifFit:OriginalIntensity
			Wave/Z QwaveOriginal = root:Packages:Irena_UnifFit:OriginalQvector
			Wave/Z ErrorOriginal = root:Packages:Irena_UnifFit:OriginalError
			if(!WaveExists(IntWaveOriginal))
				abort
			endif
		else //use stored results, in this case the strings should be set...
			SVAR DataFolderName = root:Packages:AggregateModeling:DataFolderName
			SVAR IntensityWaveName = root:Packages:AggregateModeling:IntensityWaveName
			SVAR QWavename = root:Packages:AggregateModeling:QWavename
			SVAR ErrorWaveName = root:Packages:AggregateModeling:ErrorWaveName
			Wave/Z IntWaveOriginal = $(DataFolderName+IntensityWaveName)
			Wave/Z QwaveOriginal = $(DataFolderName+QWavename)
			Wave/Z ErrorOriginal = $(DataFolderName+ErrorWaveName)
			if(!WaveExists(IntWaveOriginal))
				abort
			endif
		endif
		InvarData=areaXY(QwaveOriginal, IntWaveOriginal, QvectorWV[0], QvectorWV[numpnts(QvectorWV)-1])
	endif
	IntensityWV*=InvarData/InvarModel
	CheckDisplayed /W=MassFractalAggDataPlot IntensityWV
	if(V_flag==0)
			AppendToGraph/W=MassFractalAggDataPlot IntensityWV vs QvectorWV
	endif
		 
	ModifyGraph/W=MassFractalAggDataPlot mode($(nameofwave(IntensityWV)))=0,rgb($(nameofwave(IntensityWV)))=(0,0,0)		
	ModifyGraph/W=MassFractalAggDataPlot log=1
	ModifyGraph/W=MassFractalAggDataPlot mirror=1
	ModifyGraph/W=MassFractalAggDataPlot lsize(PDFIntensityWv)=3,rgb(PDFIntensityWv)=(1,16019,65535)	
	ShowInfo
	String LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
	Label/W=MassFractalAggDataPlot left LabelStr
	LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
	Label/W=MassFractalAggDataPlot bottom LabelStr
//		string LegendStr="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"\\s(PDFIntensityWv) Mass Fractal Model intensity"
//		Legend/W=MassFractalAggDataPlot/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr

//	string IntWvName=nameofWave(IntWaveOriginal)
//	DoWIndow MassFractalAggDataPlot
//	if(V_Flag)
//		DoWIndow/F MassFractalAggDataPlot
//	else
//		Display /W=(282.75,37.25,900,400)/K=1  IntWaveOriginal vs QwaveOriginal as "Mass Fractal Aggregate 1D Data Plot"
//		DoWindow/C MassFractalAggDataPlot
//		ModifyGraph mode($(nameofwave(IntWaveOriginal)))=3
//		ModifyGraph msize($(nameofwave(IntWaveOriginal)))=0
//		ModifyGraph log=1
//		ModifyGraph mirror=1
//		ShowInfo
//		String LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
//		Label left LabelStr
//		LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
//		Label bottom LabelStr
//		string LegendStr="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"\\s("+IntWvName+") Data intensity"
//		Legend/W=MassFractalAggDataPlot/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr
//		TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
//		TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+GetWavesDataFolder(IntWaveOriginal,1)	
//	endif
	AutoPositionWindow/R=FractalAggregatePanel MassFractalAggDataPlot
end


//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
static Function IR3A_Calculate1DIntensity()
	
	DFref oldDf= GetDataFolderDFR()

	SetDataFolder root:Packages:AggregateModeling
	//decide which data - if table has selected data, use that, else current data in the tool
	string selection = IR3A_FindSelectedAggData()
	variable isInWorkFolder = 0
	if(strlen(selection)<1 || stringmatch(selection, "root:Packages:*"))
		isInWorkFolder =1
	endif
	Wave/Z MassFractalAggregate=$(selection)
	if(!WaveExists(MassFractalAggregate))
			Print "MassFractalAggregate 3D wave does not exist, cannot do anything"
			return 0			//end on user. 
	endif
	setDataFOlder $(GetWavesDataFolder(MassFractalAggregate, 1 ))
	string OldNote=note(MassFractalAggregate)

	//figure out where we are working... 
	variable measuredDataExists = 0
	string CurrentFolder
	NVAR useCurrentResults = root:packages:AggregateModeling:CurrentResults
	NVAR useStoredResults = root:packages:AggregateModeling:StoredResults
	if(useCurrentResults+useStoredResults!=1)
		useStoredResults = 0
		useCurrentResults = 1
	endif
	if(useCurrentResults)
		Wave/Z IntWaveOriginal = root:Packages:Irena_UnifFit:OriginalIntensity
		Wave/Z QwaveOriginal = root:Packages:Irena_UnifFit:OriginalQvector
		Wave/Z ErrorOriginal = root:Packages:Irena_UnifFit:OriginalError
		if(WaveExists(IntWaveOriginal))
			measuredDataExists = 1
		endif
		CurrentFolder = "root:Packages:Irena_UnifFit"
	else //use stored results, in this case the strings shoudl be set...
		SVAR DataFolderName = root:Packages:AggregateModeling:DataFolderName
		SVAR IntensityWaveName = root:Packages:AggregateModeling:IntensityWaveName
		SVAR QWavename = root:Packages:AggregateModeling:QWavename
		SVAR ErrorWaveName = root:Packages:AggregateModeling:ErrorWaveName
		Wave/Z IntWaveOriginal = $(DataFolderName+IntensityWaveName)
		Wave/Z QwaveOriginal = $(DataFolderName+QWavename)
		Wave/Z ErrorOriginal = $(DataFolderName+ErrorWaveName)
		if(WaveExists(IntWaveOriginal))
			measuredDataExists = 1
		endif
		CurrentFolder = DataFolderName
	endif
	if(!measuredDataExists)
		NewDataFOlder/O root:Aggregate1DModel
		CurrentFolder = "root:Aggregate1DModel"
	endif
	
	//OK, now lets go where we have the data..
	SetDataFolder $(CurrentFolder)
	if(measuredDataExists)
		Duplicate/O IntWaveOriginal, Model3DAggIntensity
		Duplicate/O QwaveOriginal, A3DAgg1DQwave
	else
		Make/O/N=200 IntWaveOriginal, Model3DAggIntensity, QwaveOriginal, A3DAgg1DQwave
		A3DAgg1DQwave = 10^(log(0.001)+p*((log(1)-log(0.001))/(199))) 				//sets k scaling on log-scale...
		QwaveOriginal = 10^(log(0.001)+p*((log(1)-log(0.001))/(199))) 				//sets k scaling on log-scale...
		IntWaveOriginal = 1
	endif
	//DoAlert /T="This is not working right yet" 0, "IR3A_Calculate1DIntensity() is not finished yet, using Guinier-Porod does nto work right... " 
	//SetDataFolder OldDf
	//abort
	//now, use info from Alex McGlasson who back calculated Unified parameters from Andrew Mulderig J. Aerosol Sci. 109 (2017), 28-37 manuscript
	//NoteText="Mass Fractal Aggregate created="+date()+", "+time()+";z="+num2str(DegreeOfAggregation)+";StickingProbability="+num2str(StickingProbability)+
	//";R="+num2str(RValue)+";Rprimary="+num2str(RgPrimary)+";p="+num2str(pValue)
	//NoteText+=";RxRgPrimaryValue="+num2str(RValue*RgPrimary)+";s="+num2str(sValue)+
	//";df="+num2str(IN2G_roundSignificant(dfValue,3))+";dmin="+num2str(IN2G_roundSignificant(dminValue,3))+
	//";c="+num2str(IN2G_roundSignificant(cValue,3))+";True Sticking Probability="+num2str(100*DegreeOfAggregation/AttemptValue)+";"
	variable Level1Rg = str2num(StringByKey("Rprimary", OldNote, "=", ";"))  				//recorded is small dimension Rg in A
	variable level1Radius = 	sqrt(5/3)*Level1Rg															//Rg^2 = 3 * R^2 / 5 
	variable Level2P = str2num(StringByKey("df", OldNote, "=", ";"))  							//this is mass fractal dimension
	variable zval = str2num(StringByKey("z", OldNote, "=", ";"))
	variable dfval = str2num(StringByKey("df", OldNote, "=", ";"))
	variable dminval = str2num(StringByKey("dmin", OldNote, "=", ";"))
	variable Level2G = zval - 1																						//this is assuming level1G = 1 (which we use as default here)
	//variable Level2RgAggregate = str2num(StringByKey("RxRgPrimaryValue", OldNote, "=", ";"))  	//recorded is large dimension Rg in A, R = sqrt(5/3) * Rg
	variable R2val = str2num(StringByKey("R", OldNote, "=", ";"))
	variable cval = str2num(StringByKey("c", OldNote, "=", ";"))
	//variable Level2Rg = (R2val^2 / 4 ) *  zval^(2/dfval)													//per Alex's original formula. way too large
	variable Level2Rg = 	Level1Rg * zval^((1/cval - 1)/(dminval - dfval))								//per Alex's second formula.
	//print "Aggregate Radius of Gyration is [A] : "+num2str(Level2Rg)
	//this above is suppose to be R^2/4 * z^(2/df)  
	//this seems to be unitless, do we need to do following? 
	//Level2Rg = Level2Rg * Level1Rg																		//all calculates seem relative to size of the primary particle, so do we need to scale this by primary size somehow? 
	//this is Unified fit calculation... 
	//	if (MassFractal)
	//		B=(G*P/Rg^P)*exp(gammln(P/2))
	//	endif
	//this below is df * Gamma(df/2) * G2 / (c * Rg2^df)  
	//variable Level2B = dfval * gamma(dfval/2) * Level2G /(cval * Level2Rg^dfval)  
	//use alternativer from mass fractal...
	//variable Level2B = (Level2G*Level2P/Level2Rg^Level2P)*exp(gammln(Level2P/2))
	variable Level2B = (Level2G*Level2P/Level2Rg^Level2P)*gamma(Level2P/2)
	

	variable Level2RgCO = Level1Rg																		//this is logical, needs to terminate mass fractal curve here...
	variable Level1G = 1																								//see above, this is model basic volume fraction term. Needs to be scaled to measured dat athrough invariant. 
	variable Level1B = 4*pi/(Level1Rg^4)																	//does this need to be converted to 1/cm ??? 
	// Alex has Rg1 calculation here: Rg1 = Rg2/(z^((1/c - 1)/(dmin-df)))								//it seems round calculations, I am not sure I understand this whole thing philosophically. 
	variable Level1P = 4																								//see above, this is model basic volume fraction term. Needs to be scaled to measured dat athrough invariant. 
	print "Calculating 1D intensity, here are parameters for Unified fit model used to generate 1D curve"
	print "Rg primary = "+num2str(Level1Rg)
	print "G primary = "+num2str(Level1G)
	print "B primary = "+num2str(Level1B)
	print "P primary = "+num2str(Level1P)
	print "Rg aggregate = "+num2str(Level2Rg)
	print "G aggregate = "+num2str(Level2G)
	print "B aggregate = "+num2str(Level2B)
	print "P aggregate = "+num2str(Level2P)


	Duplicate/Free Model3DAggIntensity, Model3DAggIntensityL1, Model3DAggIntensityL2
	//level 1 - primaries...
	IR3A_UnifiedFitIntOne(A3DAgg1DQwave,Model3DAggIntensityL1, Level1G, Level1Rg, Level1B, Level1P,  0)
	//Level 2 - aggregate 
	IR3A_UnifiedFitIntOne(A3DAgg1DQwave,Model3DAggIntensityL2, Level2G, Level2Rg, Level2B, Level2P, Level2RgCO)
	//summ together
	Model3DAggIntensity = Model3DAggIntensityL1 + Model3DAggIntensityL2
	//make graph if needed... 
	String LabelStr
	DoWIndow MassFractalAggDataPlot
	if(!V_Flag)
		if(measuredDataExists)
			IR3A_Display1DIntensity()
		else
			Display /W=(282.75,37.25,900,400)/K=1  IntWaveOriginal vs QwaveOriginal as "Mass Fractal Aggregate 1D Data Plot"
			DoWindow/C MassFractalAggDataPlot
			ModifyGraph mode($(nameofwave(IntWaveOriginal)))=3
			ModifyGraph msize($(nameofwave(IntWaveOriginal)))=0
			ModifyGraph log=1
			ModifyGraph mirror=1
			ShowInfo
			LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
			Label left LabelStr
			LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
			Label bottom LabelStr
			string LegendStr="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"\\s(IntWaveOriginal) Data intensity"
			Legend/W=MassFractalAggDataPlot/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr
			TextBox/C/N=DateTimeTag/F=0/A=RB/E=2/X=2.00/Y=1.00 "\\Z07"+date()+", "+time()	
			TextBox/C/N=SampleNameTag/F=0/A=LB/E=2/X=2.00/Y=1.00 "\\Z07"+GetWavesDataFolder(IntWaveOriginal,1)	
		endif
	else
		DoWIndow/F MassFractalAggDataPlot
	endif
	//proper scaling of model... 
	variable QRg2 = 0.5*pi/Level2Rg
	variable QRg1 = 1.5*pi/Level1Rg
	//print "Scaling Model to data using integral intensities in Q range from "+num2str(QRg2)+"  to "+num2str(QRg1)
	variable InvarModel=areaXY(A3DAgg1DQwave, Model3DAggIntensity, QRg2, QRg1)
	variable InvarData=areaXY(QwaveOriginal, IntWaveOriginal, QRg2, QRg1)
	Model3DAggIntensity*=InvarData/InvarModel
	CheckDisplayed /W=MassFractalAggDataPlot Model3DAggIntensity
	if(V_flag==0)
			AppendToGraph/W=MassFractalAggDataPlot Model3DAggIntensity vs A3DAgg1DQwave
	endif
		 
	ModifyGraph/W=MassFractalAggDataPlot mode($(nameofwave(Model3DAggIntensity)))=0,rgb($(nameofwave(Model3DAggIntensity)))=(0,0,0)		
	ModifyGraph/W=MassFractalAggDataPlot lsize(Model3DAggIntensity)=3
	ModifyGraph/W=MassFractalAggDataPlot log=1
	ModifyGraph/W=MassFractalAggDataPlot mirror=1
	ShowInfo
	LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
	Label/W=MassFractalAggDataPlot left LabelStr
	LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
	Label/W=MassFractalAggDataPlot bottom LabelStr
	
	AutoPositionWindow/M=0 /R=FractalAggregatePanel MassFractalAggDataPlot
	SetDataFolder OldDf
	
end
///*********************************************************************************************************************
///*********************************************************************************************************************


Function IR3A_UnifiedFitIntOne(QvectorWave,IntensityWave, G, Rg, B, P, RGCO)
	variable G, Rg, B, P, RGCO
	Wave QvectorWave, IntensityWave
	

	Duplicate/Free QvectorWave, TempUnifiedIntensity, QstarVector
	
	variable Kval=1
	QstarVector=QvectorWave/(erf(Kval * QvectorWave*Rg/sqrt(6)))^3
//	if (MassFractal)
//		B=(G*P/Rg^P)*exp(gammln(P/2))
//	endif
	
	IntensityWave=G*exp(-QvectorWave^2*Rg^2/3)+(B/QstarVector^P) * exp(-RGCO^2 * QvectorWave^2/3)
end


///*********************************************************************************************************************
///*********************************************************************************************************************
//**************************************************************************************************************************************************************
Function IR3A_CalcRgof3DAgg(MassFractalAggregate)
	wave MassFractalAggregate
	//note, this is 3 column listing of positions from Aggregate growth
	//we will calculate Rg by using Rg^2 = sum(distances^2) / NumOfPoints
	//this is in units of "simple cubic side" steps used in growth of the particles. 
	//this needs to be multiplied by center-to-center distance between particles in side of this simple cubic strucure
	// if we know Rgp - primary particle Rg, then RadiusPrimary = sqrt(5/3)*Rgp and DiameterPrimary = 2*sqrt(5/3)*Rgp
	//case example: Rgp=22, RadiusP= 28, and DiameterP=56 A
	//multiply result of this by DiameterP to have real world Rg of aggregate... 
	
	make/Free/N=(DimSize(MassFractalAggregate, 0)) DistanceWave2
	DistanceWave2 = MassFractalAggregate[p][0]^2 + MassFractalAggregate[p][1]^2 + MassFractalAggregate[p][2]^2
	variable tmpVal= sum(DistanceWave2)/numpnts(DistanceWave2)
	
	print "Rg in Primary Size units is : "+num2str(sqrt(tmpVal))
	print "Multiply this by Diameter of primary particle =  2*sqrt(5/3)*Rgp "
	return sqrt(tmpVal)
end


//**************************************************************************************************************************************************************

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

static Function IR3A_Model1DIntensity()
	
	variable recalculate3D = 0
	DFref oldDf= GetDataFolderDFR()

	//follow this: IR3P_Calculate1DDataFile()
	//decide which data - if table has selected data, use that, else current data in the tool
	string selection = IR3A_FindSelectedAggData()
	variable isInWorkFolder = 0
	if(strlen(selection)<1 || stringmatch(selection, "root:Packages:*"))
		isInWorkFolder =1
	endif
	Wave/Z MassFractalAggregate=$(selection)
	if(!WaveExists(MassFractalAggregate))
			Print "MassFractalAggregate 3D wave does not exist, cannot do anything"
			return 0			//end on user. 
	endif
	setDataFOlder $(GetWavesDataFolder(MassFractalAggregate, 1 ))
	string OldNote=note(MassFractalAggregate)
	variable AggSize = str2num(StringByKey("RxRgPrimaryValue", OldNote, "=", ";"))  	//recorded is large dimension Rg in A, R = sqrt(5/3) * Rg
	variable Level1Rg = str2num(StringByKey("Rprimary", OldNote, "=", ";"))  				//recorded is small dimension Rg in A
	variable level1Radius = 	sqrt(5/3)*Level1Rg															//Rg^2 = 3 * R^2 / 5 
	variable PrimarySize = 2* sqrt(5/3)*Level1Rg													  		//diameter of primary particle in Angstroms, = also side of the simple cubic lattice these particles are sitting on... 
	//NoteText="Mass Fractal Aggregate created="+date()+", "+time()+";z="+num2str(DegreeOfAggregation)+";StickingProbability="+num2str(StickingProbability)+";R="+num2str(RValue)+";Rprimary="+num2str(RgPrimary)+";p="+num2str(pValue)
	//NoteText+=";RxRgPrimaryValue="+num2str(RValue*RgPrimary)+";s="+num2str(sValue)+";df="+num2str(IN2G_roundSignificant(dfValue,3))+";dmin="+num2str(IN2G_roundSignificant(dminValue,3))+";c="+num2str(IN2G_roundSignificant(cValue,3))+";True Sticking Probability="+num2str(100*DegreeOfAggregation/AttemptValue)+";"
	
	//pick the parameters... 
	variable voxelSize = PrimarySize/10
	variable IsoValue = 0.1
	variable Qmin = 0.5 * pi/AggSize 
	variable Qmax = 6 * pi/PrimarySize
	variable NumQSteps = 200
	variable PrimarySphereRadius = 10		//this is RADIUS of sphere in voxels, not in angstroms. 
	//Internally, each particle volume is made 10x10x10, 8 seems to be value when the spheres are exactly touching in xy direction, 9 when in xyz direction. 
	Wave/Z ThreeDVoxelGram = Wave3DwithPrimaryShrunk  		//this is voxelgram shrunk to min size	
	if(!WaveExists(ThreeDVoxelGram) || isInWorkFolder || recalculate3D)
		//convert to voxelgram
		IR3T_ConvertToVoxelGram(MassFractalAggregate, PrimarySphereRadius)
		Wave ThreeDVoxelGram = Wave3DwithPrimaryShrunk  		//this is voxelgram shrunk to min size... 
	endif

	//Calculate pdf intensity
	//TODO: check these are set correctly: VoxelSize, NumRSteps
	SetScale /P x, 0, VoxelSize, "A" ,ThreeDVoxelGram
	SetScale /P y, 0, VoxelSize, "A" ,ThreeDVoxelGram
	SetScale /P z, 0, VoxelSize, "A" ,ThreeDVoxelGram
	IR3T_CreatePDFIntensity(ThreeDVoxelGram, IsoValue,  Qmin, Qmax, NumQSteps)
	//append to graph... 
	Wave PDFQWv
	Wave PDFIntensityWv
	IR3A_Append1DInMassFracAgg(PDFIntensityWv,PDFQWv)

	Wave/Z ThreeDVoxelGram = Wave3DwithPrimary 		//this is voxelgram with even number of rows/columns/layers. 	
	SetScale /P x, 0, VoxelSize, "A" ,ThreeDVoxelGram
	SetScale /P y, 0, VoxelSize, "A" ,ThreeDVoxelGram
	SetScale /P z, 0, VoxelSize, "A" ,ThreeDVoxelGram
	IR3T_CalcAutoCorelIntensity(ThreeDVoxelGram,  Qmin, Qmax, NumQSteps)
	//these are autocorrelation calculated intensities... 
	Wave AutoCorIntensityWv
	Wave AutoCorQWv
	IR3A_Append1DInMassFracAgg(AutoCorIntensityWv,AutoCorQWv)

	//display the intensity. 
//	DoWIndow IR1_LogLogPlotU
//	if(V_Flag)
//		DoWIndow/F IR1_LogLogPlotU
//		Wave IntWave = root:Packages:Irena_UnifFit:OriginalIntensity
//		Wave Qwave = root:Packages:Irena_UnifFit:OriginalQvector
//		if(!WaveExists(IntWave))
//			setDataFOlder OldDf
//			//this is weird, this should exit in this case...
//			return 0
//		endif
//		variable InvarModel=areaXY(PDFQWv, PDFIntensityWv )
//		variable InvarData=areaXY(Qwave, IntWave )
//		PDFIntensityWv*=InvarData/InvarModel
//		CheckDisplayed /W=IR1_LogLogPlotU PDFIntensityWv
//		if(V_flag==0)
//			AppendToGraph/W=IR1_LogLogPlotU  PDFIntensityWv vs PDFQWv
//		endif
//		ModifyGraph lstyle(PDFIntensityWv)=9,lsize(PDFIntensityWv)=3,rgb(PDFIntensityWv)=(1,16019,65535)
//		ModifyGraph mode(PDFIntensityWv)=4,marker(PDFIntensityWv)=19
//		ModifyGraph msize(PDFIntensityWv)=3
//	else
//		DoWIndow MassFractalAggDataPlot
//		if(V_Flag)
//			DoWIndow/F MassFractalAggDataPlot
//		else
//			IR3A_Display1DIntensity()
//		endif
//		variable InvarModel=areaXY(PDFQWv, PDFIntensityWv )
//		variable InvarData=areaXY(Qwave, IntWave )
//		PDFIntensityWv*=InvarData/InvarModel
//		CheckDisplayed /W=MassFractalAggDataPlot PDFIntensityWv
//		if(V_flag==0)
//			AppendToGraph/W=MassFractalAggDataPlot PDFIntensityWv vs PDFQWv
//		endif
//		 
//		ModifyGraph mode(PDFIntensityWv)=0,rgb(PDFIntensityWv)=(0,0,0)		
//		ModifyGraph log=1
//		ModifyGraph mirror=1
//		ShowInfo
//		String LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
//		Label left LabelStr
//		LabelStr= "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Q [A\\S-1\\M\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"]"
//		Label bottom LabelStr
////		string LegendStr="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"\\s(PDFIntensityWv) Mass Fractal Model intensity"
////		Legend/W=MassFractalAggDataPlot/N=text0/J/F=0/A=MC/X=32.03/Y=38.79 LegendStr
	

	setDataFOlder OldDf
	
end

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
static Function IR3A_Display3DAggregate(AppendToNotebook)
	variable AppendToNotebook

	string selection = IR3A_FindSelectedAggData()
	if(strlen(selection)>0)
		KillWIndow/Z MassFractalAggregateView
		Wave/Z MassFractalAggregate=$(selection)
		if(WaveExists(MassFractalAggregate))
			IR3A_GizmoViewScatterPlot(MassFractalAggregate)
			IR3A_DisplayAggNotebook(MassFractalAggregate, AppendToNotebook)
			DoWIndow MassFractalAggDataPlot
			if(V_FLag)
				AutoPositionWindow /M=1 /R=MassFractalAggDataPlot MassFractalAggregateView
				AutoPositionWindow /M=0 /R=MassFractalAggregateView Summary3DAggregate				
			endif
		else
			Print "MassFractalAggregate 3D wave does not exist, cannot do anything"
		endif
	endif

end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function/S IR3A_FindSelectedAggData()
	//locates which Aggregate data user selected - or returns curren tmodel in Packages. 
	wave/Z/T Stored3DAggregatesPaths= root:Packages:AggregateModeling:Stored3DAggregatesPaths
	if(!WaveExists(Stored3DAggregatesPaths))
		abort
	endif
	wave/T Stored3DAggregates= root:Packages:AggregateModeling:Stored3DAggregates
	variable i
	ControlInfo /W=FractalAggregatePanel StoredAggregates
	if(V_Value<0)		//no selection...
		Wave/Z MassFractalAggregate=root:Packages:AggregateModeling:MassFractalAggregate
		if(WaveExists(MassFractalAggregate))
			return "root:Packages:AggregateModeling:MassFractalAggregate"					
		else
			Print "MassFractalAggregate 3D wave does not exist, cannot do anything"
		endif
	endif
	string selection
	if(V_Value<numpnts(Stored3DAggregatesPaths))
	 	selection = Stored3DAggregatesPaths	[V_Value]
	else
		selection = ""
	endif
	if(stringMatch(selection,"Current model"))
				Wave/Z MassFractalAggregate=root:Packages:AggregateModeling:MassFractalAggregate
				if(WaveExists(MassFractalAggregate))
					return "root:Packages:AggregateModeling:MassFractalAggregate"					
				else
					Print "MassFractalAggregate 3D wave does not exist, cannot do anything"
				endif
	else
				Wave/Z MassFractalAggregate=$(selection+":MassFractalAggregate")
				if(WaveExists(MassFractalAggregate))
					return selection+":MassFractalAggregate"					
				else
					Print "MassFractalAggregate 3D wave does not exist, cannot do anything"
				endif
	endif

end	
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
static Function IR3A_DisplayAggNotebook(MassFractalAggregate, AppendToNotebook)
	wave MassFractalAggregate
	variable AppendToNotebook
	
	
	String nb = "Summary3DAggregate"
	DoWIndow Summary3DAggregate
	if(!V_Flag)
		NewNotebook/N=$nb/F=1/V=1/K=3/ENCG={1,1}/W=(721,68,1397,644)
		Notebook $nb defaultTab=36, magnification=125
		Notebook $nb showRuler=1, rulerUnits=2, updating={1, 1}
		Notebook $nb newRuler=Normal, justification=0, margins={0,0,468}, spacing={0,0,0}, tabs={}, rulerDefaults={"Helvetica",11,0,(0,0,0)}
		Notebook $nb ruler=Normal, fSize=16, fStyle=1, text="Summary of Mass Fractal Aggregates\r"
		Notebook $nb fSize=-1, fStyle=-1, text="\r"
	else
		DoWIndow/F Summary3DAggregate
	endif
	if(AppendToNotebook)
		//and append results for aggregate we are looking at
		NVAR Target_dmin=root:Packages:AggregateModeling:BrFract_dmin
		NVAR Target_c=root:Packages:AggregateModeling:BrFract_c
		NVAR Target_df=root:Packages:AggregateModeling:BrFract_df
		NVAR Misfit = root:Packages:AggregateModeling:CurrentMisfitValue
		string ResultsLocation = GetWavesDataFolder(MassFractalAggregate, 1 )
		string OldNote=note(MassFractalAggregate)
		Notebook $nb selection={endOfFile,endOfFile}
		Notebook $nb ruler=Normal, text="\r"
		Notebook $nb ruler=Normal, text="*************************************************************************************************   \r"
		Notebook $nb ruler=Normal, text="Mass Fractal 3D Aggregate from : "+ResultsLocation+"\r"
		Notebook $nb ruler=Normal, text="Date & time generated : "+StringByKey("Mass Fractal Aggregate created", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="****      *********      *************    *******    \r"
		Notebook $nb ruler=Normal, text="Degree of Aggregation z : \t\t\t"+StringByKey("z", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="Aggregate Size R : \t\t\t\t\t\t"+StringByKey("R", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="Short circuit path length p : \t\t"+StringByKey("p", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="Connective path length s : \t\t\t"+StringByKey("s", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="Mass fractal dimension df : \t\t"+StringByKey("df", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="Minimum dimension dmin : \t\t"+StringByKey("dmin", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="Connectivity dimension c : \t\t\t"+StringByKey("c", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="****      *********      *************    *******    \r"
		Notebook $nb ruler=Normal, text="Sticking Probability :\t\t\t\t\t\t"+StringByKey("StickingProbability", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="Sticking Method : \t\t\t\t\t\t\t"+StringByKey("StickingMethod", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="Multi Particle Attraction : \t\t\t\t"+StringByKey("MultiParticleAttraction", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="True Sticking Probability : \t\t\t"+StringByKey("True Sticking Probability", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="Maximum Path Length : \t\t\t\t"+StringByKey("MaximumPathLength", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="Max Number Of Paths Per End : \t\t"+StringByKey("MaxNumberOfPathsPerEnd", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="Number Of End particles : \t\t\t"+StringByKey("NumberOfEnds", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="******          Target    &    resulting values         ************   \r"
		Notebook $nb ruler=Normal, text="dmin : \t\t Target : "+num2str(IN2G_roundSignificant(Target_dmin,3))+"\t\tResult : "+StringByKey("dmin", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="c : \t\t Target : "+num2str(IN2G_roundSignificant(Target_c,3))+"\t\tResult : "+StringByKey("c", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="df : \t\t Target : "+num2str(IN2G_roundSignificant(Target_df,3))+"\t\tResult : "+StringByKey("df", OldNote, "=", ";")+"\r"
		Notebook $nb ruler=Normal, text="Final Misfit value : "+num2str(IN2G_roundSignificant(Misfit,3))+"\r"
		Notebook $nb ruler=Normal, text="*************************************************************************************************   \r"
		//	NoteText="Mass Fractal Aggregate created="+date()+", "+time()+";z="+num2str(DegreeOfAggregation)+";StickingProbability="+num2str(StickingProbability)+";StickingMethod="+num2str(AllowedNearDistance)
		//	NoteText+=";R="+num2str(RValue)+";Rprimary="+num2str(RgPrimary)+";p="+num2str(pValue)
		//	NoteText+=";RxRgPrimaryValue="+num2str(RValue*PrimaryDiameter)+";s="+num2str(sValue)+";df="+num2str(IN2G_roundSignificant(dfValue,4))+";dmin="+num2str(IN2G_roundSignificant(dminValue,4))
		//	NoteText+=";c="+num2str(IN2G_roundSignificant(cValue,4))+";True Sticking Probability="+num2str(100*DegreeOfAggregation/AttemptValue)
		//	NoteText+=";MultiParticleAttraction="+MultiParticleAttraction+";MaximumPathLength="+num2str(MaxPathLength)+";MaxNumberOfPathsPerEnd="+num2str(MaxNumPaths)+";NumberOfEnds="+num2str(NumStarts)+";"

		DoWIndow MassFractalAggregateView
		if(V_Flag)
			Notebook $nb scaling={80,80}, picture={MassFractalAggregateView, -5, 1 }
			Notebook $nb ruler=Normal, text="\r"
		endif
		DoWIndow MassFractalAggDataPlot
		if(V_Flag)
			Notebook $nb scaling={75,75}, picture={MassFractalAggDataPlot, 2, 1 }
			Notebook $nb ruler=Normal, text="\r"
		endif
	endif
	//	R - aggregate size 
	//	df - Mass fractal dimension of the aggregate 
	//	p - short circuit path length 
	//	s - connective path length 
	//	dmin - minimum dimension of the aggregate 
	//	c - connectivity dimension of the aggregate 
	//	s - connective path length of the aggregate

end

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************



static Function IR3A_Grow1MassFractAgreg(Display3D)
	variable Display3D

	DFref oldDf= GetDataFolderDFR()

	//IR3A_InitializeMassFractAgg()
	SetDataFolder root:Packages:AggregateModeling
	KillWIndow/Z MassFractalAggregateView
	KillWIndow/Z MassFractalAggDataPlot
	KillWindow/Z AggStoredResultsOverview
		
	NVAR DegreeOfAggregation=root:Packages:AggregateModeling:DegreeOfAggregation
	NVAR StickingProbability=root:Packages:AggregateModeling:StickingProbability
	NVAR NumberOfTestPaths=root:Packages:AggregateModeling:NumberOfTestPaths
	NVAR AllowedNearDistance=root:Packages:AggregateModeling:AllowedNearDistance
		// Get the starting position of the aggregate
	Make/n=(DegreeOfAggregation,3)/O MassFractalAggregate=0		// It starts at 0,0,0
	Make/n=(DegreeOfAggregation,4)/O endpoints							//List of end points
	make/N=(DegreeOfAggregation)/O Distances 							// Distance between existing particles & new one. Needed by MakeAgg
	variable StartTicks=ticks
	variable Failed
	//print time()+"  Started Growing Aggregate and evaluation its structure " 
	IR3A_MakeAgg(DegreeOfAggregation,MassFractalAggregate,StickingProbability,AllowedNearDistance)		// Agg is made with DegreeOfAggregation particles
	//Failed = IR3A_Ends(MassFractalAggregate, breakOnFail)
	//if(!Failed)
		//IR3A_Reted(endpoints)
		//IR3A_Path(NumberOfTestPaths)
	IR3A_EvaluateAggregateUsingMT()
	Failed = IR3A_CalculateParametersMT()
	if(!failed)
		if(Display3D)
			IR3A_GizmoViewScatterPlot(MassFractalAggregate)
		endif
	else
		Print "Failed to grow meaningful aggregate"
	endif
	//print time()+"  Finished, done in "+num2str((ticks-StartTicks)/60)+" seconds" 	
	//else
	//	print time()+"  Failed, Aggregate is too compact " 	
	//endif
	setDataFOlder OldDf
	return Failed
End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//this is code to evaluate paths and statistics using multithreading and lot more unique paths... 

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
static FUnction IR3A_EvaluateAggregateUsingMT()

	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:AggregateModeling
	//print "****   Evaluating Aggregate structure    *****"
	print "Evaluating Aggregate - This may take anywhere from seconds to hours, depending on size and complexity of the aggregate." 
	wave ListOfNeighbors
	wave NumberOfNeighbors
	NVAR NumberOfTestPaths = root:Packages:AggregateModeling:NumberOfTestPaths
	NVAR DegreeOfAggregation = root:Packages:AggregateModeling:DegreeOfAggregation

	variable StartTicks=ticks
		//Make/O/N=(dimsize(ListOfNeighbors,0)) ListOfStarts
		//Duplicate/O ListOfNeighbors, ListOfNeighborsForStarts
		//	variable i, ij 
		//	For(i=numpnts(NumberOfNeighbors)-1;i>=0;i-=1)		//this iterates over all points in the aggregate, it goes in order of how points were added. 
		//		if(NumberOfNeighbors[i]>1.5)				//this point is not end, delete. 
		//			DeletePoints/M=0 i, 1, ListOfStarts, ListOfNeighborsForStarts
		//		else
		//			ListOfStarts[i]=i
		//		endif
		//	endFOR	

	//the loop above can done easier by this: 
	//extract indexes for end points. ListOfStarts = endpoints. 
	Extract /O /INDX NumberOfNeighbors, ListOfStarts, NumberOfNeighbors<2
	Duplicate/O ListOfStarts, ListOfNeighborsForStarts
	//and these are neighbors fo each end point. 
	ListOfNeighborsForStarts= ListOfNeighbors[ListOfStarts[p][0]]
	//print dimsize(ListOfStarts,0)
	//at this moment we have list of start points ListOfStarts and list of next points for each start point. 
	//we can now start independent thread for each of pairs of ListOfStarts[i] as prior point and NumberOfNeighborsForStarts[i] as current point. 
	Make/WAVE/O/N=(dimsize(ListOfStarts,0)) ListOfUniquePathListWvs
	//print "start MT evaluation"	
	multithread ListOfUniquePathListWvs = IR3A_MT_WalkPathThread(ListOfNeighbors,NumberOfNeighbors,ListOfStarts[p], NumberOfTestPaths, DegreeOfAggregation)

	variable seconds = ticks -StartTicks

	Print "***** Evaluted  aggregate in sec : "+num2str(seconds/60) 	//takes needless time.. 

	setDataFOlder OldDf

end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

static Function IR3A_CalculateParametersMT()

	DFref oldDf= GetDataFolderDFR()
	SetDataFolder root:Packages:AggregateModeling
	
	Wave/WAVE ListOfUniquePathListWvs
	WAVE ListOfStarts = root:Packages:AggregateModeling:ListOfStarts
	NVAR dfValue
	NVAR RValue
	NVAR pValue
	NVAR sValue
	NVAR cValue
	NVAR dminValue
	NVAR TrueStickingProbability
	NVAR StickingProbability=root:Packages:AggregateModeling:StickingProbability
	NVAR RgPrimary=root:Packages:AggregateModeling:RgPrimary
	NVAR AllowedNearDistance
	NVAR AttemptValue
	NVAR NumberOfTestPaths = root:Packages:AggregateModeling:NumberOfTestPaths
	NVAR AllowedNearDistance=root:Packages:AggregateModeling:AllowedNearDistance
	NVAR RxRgPrimaryValue=root:Packages:AggregateModeling:RxRgPrimaryValue
	NVAR DegreeOfAggregation=root:Packages:AggregateModeling:DegreeOfAggregation
	NVAR Misfit = root:Packages:AggregateModeling:CurrentMisfitValue
	SVAR MultiParticleAttraction = root:Packages:AggregateModeling:MultiParticleAttraction //"Neutral;Attractive;Repulsive;Not allowed;"

	variable failed=0
	//here we will evaluate all paths, they arrive using wave of waves : ListOfUniquePathListWvs
	//each item  in this wave is wavereference to free wave in memory with one path. 
	variable i,j,ij, SumPL2, SumPL, NumPathsFOund, AveragePath, MaxPathLength, MaxNumPaths, tmpNumUsefulPaths
	MaxPathLength = 0
	Wave ListOfStarts
	For(ij=0;ij<numpnts(ListOfStarts);ij+=1)
		Wave UniquePathList=ListOfUniquePathListWvs[ij]
		//calculate sum(path lengths^2)/sum(path Lengths)
		//collect also length of longest path and number of paths per starting point. 
		tmpNumUsefulPaths = 0
		For(i=0;i<DimSize(UniquePathList,1);i+=1)
			//get one path from the table
			Duplicate /free/R=[][i]  UniquePathList, TempWv
			//extract non NaN points from this. 
			extract/Free TempWv, TempWv, TempWv<65534
			//if it is longer than 2, add to list of waves
			if(numpnts(TempWv)>2)
				SumPL+=numpnts(TempWv)
				SumPL2+=numpnts(TempWv)^2
				NumPathsFound+=1
				MaxPathLength = max(MaxPathLength, numpnts(TempWv))
				tmpNumUsefulPaths+=1
			endif
		endfor
		//this is max number of paths we have found in the system. 
		MaxNumPaths = max(MaxNumPaths,tmpNumUsefulPaths)
	endfor
	//weighted avergae path. 
	AveragePath = SumPL2/SumPL
	//this is called also pValue
	pValue = AveragePath
	//this is useful to evaluate also... 
	variable PathperEndPoint=NumPathsFound/numpnts(ListOfStarts)
	//this will release from memory those free waves with paths, saves Igor memory.. 
	KillWaves/Z ListOfUniquePathListWvs
	
	//Next we need to evaluate size of the aggregate. 
	Wave/Z NumNeighbors=root:Packages:AggregateModeling:NumberOfNeighbors
	if(WaveExists(NumNeighbors))
		Wave Agg=root:Packages:AggregateModeling:MassFractalAggregate
		//next we extract from list of neighbors only the short = 1 items items. These are end points. 
		Extract /FREE /INDX NumNeighbors, AggregateEndsIndex, NumNeighbors<2
		// AggregateEndsIndex indexes where are end points in Aggregate
		variable NumEnds=numpnts(AggregateEndsIndex)
		variable numcomb=binomial(NumEnds,2)
		variable REnd, Rsum, cnt, FInx, SInx
		make/Free/N=(numcomb) EndsDistances
		For(i=0;i<NumEnds;i+=1)
			For(j=i+1;j<NumEnds;j+=1)
				FInx=AggregateEndsIndex[i]
				SInx=AggregateEndsIndex[j]
				EndsDistances[cnt]=sqrt((Agg[FInx][0]-Agg[SInx][0])^2+(Agg[FInx][1]-Agg[SInx][1])^2+(Agg[FInx][2]-Agg[SInx][2])^2)
				cnt+=1
			endfor
		endfor
		//For(i=0;i<numcomb;i+=1)
		//	REnd+=EndsDistances[i]^2
		//	Rsum+=EndsDistances[i]
		//endfor
		duplicate/Free EndsDistances, EndsDistances2
		EndsDistances2=EndsDistances^2
		REnd = sum(EndsDistances2)
		Rsum=sum(EndsDistances)
		REnd/=RSum
		RValue=Rend
		dfValue = log(DegreeOfAggregation)/log(REnd)
		cValue=ln(DegreeOfAggregation)/ln(AveragePath)
		dminValue=dfValue/cValue
		sValue=(exp(ln(DegreeOfAggregation)/dminValue))
	endif	

	IR3A_CalculateAggValues()
	
	TrueStickingProbability = 100*DegreeOfAggregation/AttemptValue
	variable PrimaryDiameter = 2*sqrt(5/3)*RgPrimary
	variable NumStarts=numpnts(ListOfStarts)
	RxRgPrimaryValue = RValue*PrimaryDiameter
	print "***** Results listing ******"
	//print "Total number of end points is : "+num2str(NumStarts)
	if(NumStarts<4)
		print "Warning : This particle is too compact (too few ends) to make any sense"
		failed = 1
	endif
	//print "Possible number of paths is : " +num2str(NumStarts*(NumStarts-1))
	//print "Total number of evaluated paths is : "+num2str(NumPathsFound)
	//print "Paths per end point is : "+num2str(PathperEndPoint)
	if(MaxNumPaths > NumberOfTestPaths-2)
		print "Warning : Some path/end point numbers were limited by max endpoint choice. Results may not be valid, increase No of test paths for these conditions"
	endif
	print "Maximum length path is: \t\t\t\t"+num2str(MaxPathLength)
	print "Weighted Average Path = \t\t\t\t"+num2str(pValue)
	Print "Aggregate Rg [relative] = \t\t\t\t"+num2str(REnd)
	Print "R primary particles [A] = \t\t\t\t"+num2str(PrimaryDiameter/2)
	Print "Aggregate R [Angstroms] = \t\t\t\t"+num2str(RValue*PrimaryDiameter)
	Print "z = \t\t\t\t\t"+num2str(DegreeOfAggregation)
	Print "p = \t\t\t\t\t"+num2str(pValue)
	Print "c = \t\t\t\t\t"+num2str(cValue)
	Print "s = \t\t\t\t\t"+num2str(sValue)
	Print "df = \t\t\t\t"+num2str(dfValue)
	Print "dmin = \t\t\t\t"+num2str(dminValue)
	Print "True Sticking Probability = \t\t"+num2str(100*DegreeOfAggregation/AttemptValue)+"%"
	Print "Misfit value = \t\t\t\t"+num2str(Misfit)

	//appned note to MassFractalAggregate
	string NoteText
	NoteText="Mass Fractal Aggregate created="+date()+", "+time()+";z="+num2str(DegreeOfAggregation)+";StickingProbability="+num2str(StickingProbability)+";StickingMethod="+num2str(AllowedNearDistance)
	NoteText+=";R="+num2str(RValue)+";Rprimary="+num2str(RgPrimary)+";p="+num2str(pValue)
	NoteText+=";RxRgPrimaryValue="+num2str(RValue*PrimaryDiameter)+";s="+num2str(sValue)+";df="+num2str(IN2G_roundSignificant(dfValue,4))+";dmin="+num2str(IN2G_roundSignificant(dminValue,4))
	NoteText+=";c="+num2str(IN2G_roundSignificant(cValue,4))+";True Sticking Probability="+num2str(100*DegreeOfAggregation/AttemptValue)
	NoteText+=";MultiParticleAttraction="+MultiParticleAttraction+";MaximumPathLength="+num2str(MaxPathLength)+";MaxNumberOfPathsPerEnd="+num2str(MaxNumPaths)+";NumberOfEnds="+num2str(NumStarts)+";"
	NoteText+=";Misfit="+num2str(Misfit)+";"

	Wave MassFractalAggregate
	Note MassFractalAggregate, NoteText
	
	setDataFOlder OldDf
	return failed
end

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//
Threadsafe Function/Wave IR3A_MT_WalkPathThread(ListOfNeighbors,NumberOfNeighbors,startingPoint, NumberOfTestPaths, DegreeOfAggregation)
	wave ListOfNeighbors, NumberOfNeighbors
	variable startingPoint, NumberOfTestPaths, DegreeOfAggregation
	//Advanced topics, Wave Reference MultiThread Example
	DFREF dfSav= GetDataFolderDFR()
	// Create a free data folder and set it as the current data folder
	SetDataFolder NewFreeDataFolder()
	variable/g UniquePathListInx
	UniquePathListInx = 0
	make/Free/W/U/N=(DegreeOfAggregation,NumberOfTestPaths) UniquePathList
	UniquePathList = NaN
	String PriorPathList 
	variable currentPoint
	PriorPathList=num2str(startingPoint)+";"				//this is the path start as list... 
	currentPoint = ListOfNeighbors[startingPoint][0]		//this is next point since end point has only one neighbor...  
	IR3A_MT_NextPathStep(UniquePathList, ListOfNeighbors,NumberOfNeighbors,currentPoint, startingPoint, PriorPathList)
	// Restore the current data folder
	SetDataFolder dfSav
	return UniquePathList
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

Threadsafe Function IR3A_MT_NextPathStep(UniquePathList, ListOfNeighbors,NumberOfNeighbors,currentPoint, priorPoint, PriorPathList)
//Function MT_NextPathStep(ListOfNeighbors,NumberOfNeighbors,currentPoint, priorPoint, PriorPathList, OrderNumber)
	wave UniquePathList, ListOfNeighbors
	wave NumberOfNeighbors
	variable priorPoint, currentPoint
	string PriorPathList

	variable pointsFound, i, NewCurrentPoint, NewpriorPoint
	string CurrentPathList
	
	//here we need to check, if the new point is already in the list.
	//if it is, this is loop and we shoudl simply return back and refuse to go here. May have to make more decisions later...
	if(StringMatch(PriorPathList, "*;"+num2str(currentPoint)+";*"))
		//print "This was circle:"+PriorPathList+", repeting point would be :"+num2str(currentPoint)
		return 0
	endif
	NVAR UniquePathListInx
	if(UniquePathListInx>=dimsize(UniquePathList,1))
		//we have reached max number of paths allowed for this start point... 
		return 0
	endif
	
	PriorPathList+=num2str(currentPoint)+";"
	CurrentPathList= PriorPathList

	MatrixOP/Free ListOfNeighborsRow = zapNaNs(replace(row(ListOfNeighbors,currentPoint),priorPoint,NaN))
	//how many points are left? 
	pointsFound = numpnts(ListOfNeighborsRow)

	//decisions what to do... 
	if(pointsFound==0)		//this is end point, I just came from the only neighbor this has
		//print "One complete path is : "+CurrentPathList
		IR3A_MT_WriteOutPathString(UniquePathList, CurrentPathList)
		//what we really need here is write out the path into some kind of final container when we get here. 
	elseif(pointsFound==1)		//this is connecting segment, we need to go in next segment and see what is there
		NewpriorPoint = currentPoint
		NewCurrentPoint = ListOfNeighborsRow[0]		//this is new point left.
		//go in next step
		IR3A_MT_NextPathStep(UniquePathList, ListOfNeighbors,NumberOfNeighbors,NewCurrentPoint, NewpriorPoint, CurrentPathList)
	elseif(pointsFound<4)								//this is junction with up to 3 new neighbors, let's take all here...
		For(i=0;i<pointsFound;i+=1)
			NewpriorPoint = currentPoint
			NewCurrentPoint = ListOfNeighborsRow[i]		//this is new point left.
			CurrentPathList = PriorPathList
			IR3A_MT_NextPathStep(UniquePathList, ListOfNeighbors,NumberOfNeighbors,NewCurrentPoint, NewpriorPoint, CurrentPathList)
		endfor
	else												//more points than 3, let's take first three from here...  
		For(i=0;i<3;i+=1)
			NewpriorPoint = currentPoint
			//NewCurrentPoint = ListOfNeighborsRow[floor(pointsFound*(enoise(0.5)+0.5))]		//this is new point left.
			NewCurrentPoint = ListOfNeighborsRow[i]								//this is new point left.
			CurrentPathList = PriorPathList
			IR3A_MT_NextPathStep(UniquePathList, ListOfNeighbors,NumberOfNeighbors,NewCurrentPoint, NewpriorPoint, CurrentPathList)
		endfor
	endif	
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

Threadsafe Function IR3A_MT_WriteOutPathString(UniquePathList, PathStr)
	Wave UniquePathList
	string PathStr
	
	NVAR UniquePathListInx
	
	if(DimSize(UniquePathList, 0)<ItemsInList(PathStr))// || UniquePathListInx > (DimSize(UniquePathList,1)-1))
		//the length here is now set to DegreeOfAggregation which means that we cannot have longer path than number of particles... 
		//variable WvMaxlength, WvNewlength
		//WvMaxlength = DimSize(UniquePathList, 0)
		//WvNewlength = max(WvMaxlength, ItemsInList(PathStr)+10)
		//redimension/N=(WvNewlength,-1) UniquePathList
	endif
	//now, we need to write values in...
	UniquePathList[][UniquePathListInx] = NaN	
	UniquePathList[][UniquePathListInx] = str2num(StringFromList(p,PathStr, ";"))	

	UniquePathListInx = UniquePathListInx+1
end

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************


//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

static Function IR3A_GrowAggregate()
	DFref oldDf= GetDataFolderDFR()

	//IR3A_InitializeMassFractAgg()
	SetDataFolder root:Packages:AggregateModeling

	NVAR DegreeOfAggregation=root:Packages:AggregateModeling:DegreeOfAggregation
	NVAR StickingProbability=root:Packages:AggregateModeling:StickingProbability
	NVAR AllowedNearDistance=root:Packages:AggregateModeling:AllowedNearDistance
	variable DegreeOfAggregationL=DegreeOfAggregation
	VARIABLE StickingProbabilityL=StickingProbability
	Prompt DegreeOfAggregationL, "Enter the size of the aggregate (250)"
	Prompt StickingProbabilityL, "Enter StickingProbabilitying probability (1 - 100)"
	DoPrompt/Help="Basic parameters" "Input model parameters", DegreeOfAggregationL, StickingProbabilityL
	DegreeOfAggregation=DegreeOfAggregationL
	StickingProbability=StickingProbabilityL
	// Get the starting position of the aggregate
	Make/n=(DegreeOfAggregation,3)/O MassFractalAggregate=0		// It starts at 0,0,0
	make/N=(DegreeOfAggregation)/O Distances 	// Distance between existing particles & new one. Needed by MakeAgg
	IR3A_MakeAgg(DegreeOfAggregation,MassFractalAggregate,StickingProbability,AllowedNearDistance)		// Agg is made with DegreeOfAggregation particles
	setDataFOlder OldDf
End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
static Function IR3A_InitializeMassFractAgg()

 	DFref oldDf= GetDataFolderDFR()

	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:AggregateModeling
	IR3A_MakeNBROffsetList()
	string/g ListOfVariables
	string/g ListOfStrings
	//here define the lists of variables and strings needed, separate names by ;...
	ListOfVariables="DegreeOfAggregation;StickingProbability;NumberOfTestPaths;BoxSize;RgPrimary;AllowedNearDistance;NUmberOfTestAggregates;"
	ListOfVariables+="pValue;dfValue;RValue;RxRgPrimaryValue;cValue;dminValue;sValue;AttemptValue;TrueStickingProbability;"
	ListOfVariables+="SelectedLevel;SelectedQlevel;SelectedBlevel;CurrentResults;StoredResults;"
	ListOfVariables+="BrFract_G2;BrFract_Rg2;BrFract_B2;BrFract_P2;BrFract_G1;BrFract_Rg1;BrFract_B1;BrFract_P1;BrFract_dmin;"
	ListOfVariables+="BrFract_c;BrFract_z;BrFract_fBr;BrFract_fM;BrFract_df;CurrentMisfitValue;"
	ListOfVariables+="MaxNumTests;VaryStickingProbability;StickingProbMin;StickingProbMax;MinSearchTargetValue;StickProbNumSteps;TotalGrowthsPlanned;"
	ListOfStrings="SlectedBranchedLevels;Model;BrFract_ErrorMessage;MultiParticleAttraction;"
	Make/O/N=1/T Stored3DAggregates, Stored3DAggregatesPaths
	Make/O/N=1 Stored3DAggSelections
	Wave/T Stored3DAggregates
	Stored3DAggregates[0] = "Current model"
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor												
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
	NVAR DegreeOfAggregation
	if(DegreeOfAggregation<10)
		DegreeOfAggregation = 250
	endif
	NVAR StickingProbability
	if(StickingProbability<1 || StickingProbability>100)
		StickingProbability = 75
	endif
	NVAR NumberOfTestPaths
	if(NumberOfTestPaths<1000)
		NumberOfTestPaths = 2500
	endif
	NVAR RgPrimary
	if(RgPrimary<5)		//Rg of primary partice (voxel size in the model).
		RgPrimary = 10
	endif
	NVAR AllowedNearDistance
	if(AllowedNearDistance<0.9 || AllowedNearDistance>3.1)
		AllowedNearDistance = 3				//nearest neighbor distacne squared, for in line neighbors (x,y,z dir) = 1^2, for in plane neighbors is 2 (1^2+1^2), and for in body neighbors is 3  
	endif
	NVAR CurrentResults
	NVAR StoredResults
	if(CurrentResults+StoredResults!=1)
		StoredResults =1
		CurrentResults = 0
	endif
	SVAR Model
	Model = "Branched mass fractal"
	SVAR MultiParticleAttraction
	if(strlen(MultiParticleAttraction)<1)
		MultiParticleAttraction = "Neutral"
	endif

	NVAR NUmberOfTestAggregates
	if(NUmberOfTestAggregates<5)
		NUmberOfTestAggregates = 5
	endif
	NVAR MaxNumTests
	if(MaxNumTests<1)
		MaxNumTests = 10
	endif
	NVAR StickingProbMin
	if(StickingProbMin<5)
		StickingProbMin = 10
	endif
	NVAR StickingProbMax
	if(StickingProbMax<10)
		StickingProbMax = 90
	endif
	NVAR MinSearchTargetValue
	if(MinSearchTargetValue<0.001)
		MinSearchTargetValue = 0.05
	endif
	NVAR StickProbNumSteps
	if(StickProbNumSteps<5)
		StickProbNumSteps = 5
	endif
//	NVAR gdf, gR
//	variable/g gp = mom2,gc=ln(DegreeOfAggregation)/ln(gp),gdmin=gdf/gc,gs=round(exp(ln(DegreeOfAggregation)/gdmin))
		
	setDataFOlder OldDf
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

static Function IR3A_MakeNBROffsetList()

	Make/n=(26,3)/O nghbrOfsetList
	Wave nghbrOfsetList = nghbrOfsetList
		nghbrOfsetList[0][0] =+1;nghbrOfsetList[0][1] = 0;nghbrOfsetList[0][2] = 0
		nghbrOfsetList[1][0] =-1;nghbrOfsetList[1][1] = 0;nghbrOfsetList[1][2] = 0
		nghbrOfsetList[2][0] = 0;nghbrOfsetList[2][1] =+1;nghbrOfsetList[2][2] = 0
		nghbrOfsetList[3][0] = 0;nghbrOfsetList[3][1] =-1;nghbrOfsetList[3][2] = 0
		nghbrOfsetList[4][0] =+1;nghbrOfsetList[4][1] =+1;nghbrOfsetList[4][2] = 0
		nghbrOfsetList[5][0] =-1;nghbrOfsetList[5][1] =-1;nghbrOfsetList[5][2] = 0
		nghbrOfsetList[6][0] =-1;nghbrOfsetList[6][1] =+1;nghbrOfsetList[6][2] = 0
		nghbrOfsetList[7][0] =+1;nghbrOfsetList[7][1] =-1;nghbrOfsetList[7][2] = 0
		nghbrOfsetList[8][0] = 0;nghbrOfsetList[8][1] = 0;nghbrOfsetList[8][2] =+1
		nghbrOfsetList[9][0] =+1;nghbrOfsetList[9][1] = 0;nghbrOfsetList[9][2] =+1
		nghbrOfsetList[10][0]=-1;nghbrOfsetList[10][1]= 0;nghbrOfsetList[10][2]=+1
		nghbrOfsetList[11][0]= 0;nghbrOfsetList[11][1]=+1;nghbrOfsetList[11][2]=+1
		nghbrOfsetList[12][0]= 0;nghbrOfsetList[12][1]=-1;nghbrOfsetList[12][2]=+1
		nghbrOfsetList[13][0]=+1;nghbrOfsetList[13][1]=+1;nghbrOfsetList[13][2]=+1
		nghbrOfsetList[14][0]=-1;nghbrOfsetList[14][1]=-1;nghbrOfsetList[14][2]=+1
		nghbrOfsetList[15][0]=-1;nghbrOfsetList[15][1]=+1;nghbrOfsetList[15][2]=+1
		nghbrOfsetList[16][0]=+1;nghbrOfsetList[16][1]=-1;nghbrOfsetList[16][2]=+1
		nghbrOfsetList[17][0]= 0;nghbrOfsetList[17][1]= 0;nghbrOfsetList[17][2]=-1
		nghbrOfsetList[18][0]=+1;nghbrOfsetList[18][1]= 0;nghbrOfsetList[18][2]=-1
		nghbrOfsetList[19][0]=-1;nghbrOfsetList[19][1]= 0;nghbrOfsetList[19][2]=-1
		nghbrOfsetList[20][0]= 0;nghbrOfsetList[20][1]=+1;nghbrOfsetList[20][2]=-1
		nghbrOfsetList[21][0]= 0;nghbrOfsetList[21][1]=-1;nghbrOfsetList[21][2]=-1
		nghbrOfsetList[22][0]=+1;nghbrOfsetList[22][1]=+1;nghbrOfsetList[22][2]=-1
		nghbrOfsetList[23][0]=-1;nghbrOfsetList[23][1]=-1;nghbrOfsetList[23][2]=-1
		nghbrOfsetList[24][0]=-1;nghbrOfsetList[24][1]=+1;nghbrOfsetList[24][2]=-1
		nghbrOfsetList[25][0]=+1;nghbrOfsetList[25][1]=-1;nghbrOfsetList[25][2]=-1

end
//******************************************************************************************************************************************************
//Function ProfilingRun()
//	DFref oldDf= GetDataFolderDFR()

//	SetDataFolder root:Packages:AggregateModeling
//	AggMod_Initialize()
//
//	NVAR gGL
//	NVAR DegreeOfAggregation
//	NVAR StickingProbability
//	NVAR NumberOfTestPaths
//	
//	//variable GL=gGL, DegreeOfAggregation=DegreeOfAggregation, StickingProbability=StickingProbability, NumberOfTestPaths=NumberOfTestPaths
//	//Prompt DegreeOfAggregation, "Enter the size of the aggregate (250)"	// Degree of aggregation, z
//	//Prompt StickingProbability, "Enter StickingProbabilitying probability (1 - 100)"	// SP = 100% for DLA; less for RLA
//	//Prompt NumberOfTestPaths,"Enter number of paths (10000)."		// More paths = more accuracy
//	//DoPrompt/Help="Basic parameters" "Input model parameters", DegreeOfAggregation, StickingProbability, NumberOfTestPaths
//
//	gGL=500;DegreeOfAggregation=500;StickingProbability=40;NumberOfTestPaths=500;
//	// Get the starting position of the aggregate
//	Make/n=(DegreeOfAggregation,3)/O Agg=0		// It starts at 0,0,0
//	Make/n=(DegreeOfAggregation,4)/O endpoints
//	make/N=(DegreeOfAggregation)/O Distances 	// Distance between existing particles & new one. Needed by MakeAgg
//	variable StartTicks=ticks
//	print "Started Run All" 
//		MakeAgg(DegreeOfAggregation,Agg,StickingProbability)		// Agg is made with DegreeOfAggregation particles
//		Ends(agg)
//		Reted(endpoints)
//		Path(NumberOfTestPaths)
//		Execute("GizmoViewAggregate()")
//	print "Finished, done in "+num2str((ticks-StartTicks)/60)+" seconds" 	
//	setDataFOlder OldDf
//
//end

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

static Function IR3A_MakeAgg(DegreeOfAggregation,MassFractalAggregate,StickingProbability, AllowedNearDistance)
	variable DegreeOfAggregation,StickingProbability, AllowedNearDistance
	wave MassFractalAggregate
	
	DFref oldDf= GetDataFolderDFR()

	SetDataFolder root:Packages:AggregateModeling
	variable NumParticles=dimsize(MassFractalAggregate,0)
	//these are waves which must exist...
	Wave Distances = root:Packages:AggregateModeling:Distances
	NVAR AttemptValue = root:Packages:AggregateModeling:AttemptValue
	AttemptValue=1
	NVAR BoxSize = root:Packages:AggregateModeling:BoxSize
	SVAR MultiParticleAttraction = root:Packages:AggregateModeling:MultiParticleAttraction //"Neutral;Attractive;Repulsive;Not allowed;"
	variable StickingProbability1, StickingProbabilityM1,StickingProbabilityM2, StickingProbabilityLoc
	if(StringMatch(MultiParticleAttraction, "Neutral"))
		StickingProbability1= StickingProbability
		StickingProbabilityM1= StickingProbability
		StickingProbabilityM2= StickingProbability
	elseif(StringMatch(MultiParticleAttraction, "Attractive"))
		StickingProbability1= StickingProbability
		StickingProbabilityM1= (StickingProbability+100)/2
		StickingProbabilityM2= (StickingProbability+300)/4
	elseif(StringMatch(MultiParticleAttraction, "Repulsive"))
		StickingProbability1 = StickingProbability
		StickingProbabilityM1 = (StickingProbability+10)/2
		StickingProbabilityM2 = (StickingProbability+30)/4
	elseif(StringMatch(MultiParticleAttraction, "Not allowed"))
		StickingProbability1 = StickingProbability
		StickingProbabilityM1 = 1
		StickingProbabilityM2 = 0
	else
		StickingProbability1 = StickingProbability
		StickingProbabilityM1 = StickingProbability
		StickingProbabilityM2 = StickingProbability
	endif


	make/Free/N=(NumParticles,3) CurSite
	make/Free/N=(NumParticles) tmpCol
	//new recording of particles... 
	KillWaves/Z ListOfNeighbors, NumberOfNeighbors, ListOfStarts
	make/O/N=(NumParticles,26)/S ListOfNeighbors 
	make/O/N=(NumParticles)/B/U NumberOfNeighbors
	ListOfNeighbors = Nan
	NumberOfNeighbors = 0
	
	variable chcnt=1,px,py,pz,aggct=1,cnt,con,stuck,dim,choice,wall,Rd=16,GL=16,farpoint,index=0, tmpVal
	variable i
	
	
	
	
	PauseUpdate
	Do
		// resize box based on size of Agg
		farpoint = max(MassFractalAggregate[aggct-1][0], MassFractalAggregate[aggct-1][1],MassFractalAggregate[aggct-1][2],farpoint)
		//For(i=0;i<3;i+=1)
		//	if(MassFractalAggregate[aggct-1][i]>farpoint)
		//		farpoint=MassFractalAggregate[aggct-1][i]
		//	endif
		//endfor
		GL=2*abs(farpoint)+10
		BoxSize=GL		
		// initialize particle on a random wall of the box
		wall=0;choice=0
		if(aggct<64)	// choose random wall on smaller box for low aggct
			do
				wall=abs(round(enoise(7)))
			while(wall==0 || wall==7)
			if(wall==1)
				px=-1+Rd/2;py=round(enoise(Rd/2));pz=round(enoise(Rd/2))
			endif
			if(wall==2)
				px=1-Rd/2;py=round(enoise(Rd/2));pz=round(enoise(Rd/2))
			endif
			if(wall==3)
				px=round(enoise(Rd/2));py=-1+Rd/2;pz=round(enoise(Rd/2))
			endif
			if(wall==4)
				px=round(enoise(Rd/2));py=1-Rd/2;pz=round(enoise(Rd/2))
			endif
			if(wall==5)
				px=round(enoise(Rd/2));py=round(enoise(Rd/2));pz=-1+Rd/2
			endif
			if(wall==6)
				px=round(enoise(Rd/2));py=round(enoise(Rd/2));pz=1-Rd/2
			endif
		else		// choose random wall on normal box
			do
				wall=abs(round(enoise(7)))
			while(wall==0 || wall==7)
			if(wall==1)
				px=-1+GL/2;py=round(enoise(GL/2));pz=round(enoise(GL/2))
			endif
			if(wall==2)
				px=1-GL/2;py=round(enoise(GL/2));pz=round(enoise(GL/2))
			endif
			if(wall==3)
				px=round(enoise(GL/2));py=-1+GL/2;pz=round(enoise(GL/2))
			endif
			if(wall==4)
				px=round(enoise(GL/2));py=1-GL/2;pz=round(enoise(GL/2))
			endif
			if(wall==5)
				px=round(enoise(GL/2));py=round(enoise(GL/2));pz=-1+GL/2
			endif
			if(wall==6)
				px=round(enoise(GL/2));py=round(enoise(GL/2));pz=1-GL/2
			endif
		endif
		// Move the particle until it a) hits the chain or b) leaves the box, if b) you need to have it reenter the box at a mirror position.
		do	//move 1 step in any direction
			//choice=0
			//do
			//choice=abs(round(enoise(7)))
			choice = floor(1 + mod(abs(enoise(100*6)),6))	
			//while(choice==0 || choice==7)
			if(choice==1)
				px+=1
			endif
			if(choice==2)	
				px-=1
			endif
			if(choice==3)	
				py+=1
			endif
			if(choice==4)
				py-=1
			endif
			if(choice==5)	
				pz+=1
			endif
			if(choice==6)	
				pz-=1
			endif
			//if you leave the box (a likely event) then go to the other side and reenter the box (mirror)
			If(aggct<64)	// use smaller box for low number of particles
				if(px>Rd/2)
					px=px-Rd
				endif
				if(px<-Rd/2)
					px=px+Rd
				endif
				if(py>Rd/2)
					py=py-Rd
				endif
				if(py<-Rd/2)
					py=py+Rd
				endif
				if(pz>Rd/2)
					pz=pz-Rd
				endif
				if(pz<-Rd/2)
					pz=pz+Rd
				endif	
			else		// use normal box for higher number of particles
				if(px>GL/2)
					px=px-GL
				endif
				if(px<-GL/2)
					px=px+GL
				endif
				if(py>GL/2)
					py=py-GL
				endif
				if(py<-GL/2)
					py=py+GL
				endif
				if(pz>GL/2)
					pz=pz-GL
				endif
				if(pz<-GL/2)
					pz=pz+GL
				endif
			endif
			cnt=0;con=0
			// check how many neighboring sites are occupied
			//this is by far the longest step in the whole procedure
			//basically, we are looking for how many neighbors px,py,pz position has 
			//this is already much better than before, but it would really be nice to find better way of doing this. We are doing this A LOT. With every particle move, so it is done many, many times. 
			Multithread Distances[0,aggct] = ((px-MassFractalAggregate[p][0])^2 + (py-MassFractalAggregate[p][1])^2 + (pz-MassFractalAggregate[p][2])^2)		
			//	Multithread helps, in my test case reduces time by ~60%
			//this is slower... 
			//CurSite[][0]=px
			//CurSite[][1]=py
			//CurSite[][2]=pz
			//MatrixOp/O/Free/NTHR=0 Distances = sumRows(powR((MassFractalAggregate-CurSite),2))
			variable MaxDistance = 1.05*AllowedNearDistance							//1 - in line nearest neighbor (1 step), 2 is two step nearest neighbor and 3 is nearest neighbor in any direction (3 step nearest neighbor). 
			Histogram/B={0.5,MaxDistance,2}/R=[0,aggct]/Dest=DistHist Distances		//histogram - bin[0] is from 0.5 - 3.1, max allowed distance^2 is 3
			con = DistHist[0]														// this is number of nearest neighbors with distance below sqrt(3)
			//another method, suggested by WM, but is slower, much slower ...
			//			CurSite[0][0]=px
			//			CurSite[0][1]=py
			//			CurSite[0][2]=pz
			//			MatrixOp/Free TestWv = catRows(CurSite,agg)
			//			FPClustering /DSO TestWv
			//			Wave M_DistanceMap
			//			//Edit/K=1 root:M_DistanceMap
			//			MatrixOp/Free Distances=row(M_DistanceMap,0)
			//			//Edit/K=1 root:Distances
			//			Histogram/B={0.1,1.8,2}/Dest=DistHist Distances
			//			//Edit/K=1 root:DistHist
			//			con = DistHist[0]
			// end of neighbor counting. 
			//choice=0
			if(con>=1)	// particle can StickingProbability if there is at least 1 neighbor
				if(con>=3)
					StickingProbabilityLoc=StickingProbabilityM2
				elseif(con==2)
					StickingProbabilityLoc=StickingProbabilityM1
				else
					StickingProbabilityLoc=StickingProbability1
				endif

				do
					// apply StickingProbabilitying probability between 1% and 100%
					choice=floor(1 + mod(abs(enoise(100*99)),100))		//generates random integer from 1 to 99
					choice-=1
					AttemptValue+=1
					if(choice<=StickingProbabilityLoc)
						stuck=1
						con=0
					else
						con-=1
						stuck=0
					endif
				while(con>=1)
			//keep moving if alone or rejected by StickingProbabilitying probability
			else
				stuck=0
			endif
			//if the particle StickingProbabilitys, add it to the aggregate
			variable steps=trunc(DegreeOfAggregation/10)
			steps = max(steps,100)
			if(stuck==1 && IR3A_IsPXYZNOTinList3DWave(MassFractalAggregate,px,py,pz, aggct))	//added here to make sure we do not accidentally add existing particle. 
				//if(mod(aggct,steps)<1) ///round(DegreeOfAggregation/50))==aggct/round(DegreeOfAggregation/50))
				//	Print time()+"  Added "+num2str(aggct)+" particles to the aggregate  "	//takes needless time.. 
				//endif
				MassFractalAggregate[aggct][0]=px
				MassFractalAggregate[aggct][1]=py
				MassFractalAggregate[aggct][2]=pz
				//record here particle and its neighbors. 
				//who is neighbor? that who has Distances[numparticle]<MaxDistance
				//ListOfNeighbors[aggct] needs to get ^^ added to it.
				//NumberOfNeighbors
				IR3A_AddToNeighborList(ListOfNeighbors,NumberOfNeighbors, Distances, MaxDistance, aggct)
				aggct+=1
			endif
		while(stuck==0)
		stuck=0 //reset stuck flag
	While(aggct<DegreeOfAggregation)	// stop aggregate growth when there are DegreeOfAggregation particles in Agg
	Print time()+"  Created Aggregate with "+num2str(aggct)+" particles in it" 	//takes needless time.. 
	setDataFOlder OldDf

End
//******************************************************************************************************************************************************
Function IR3A_AddToNeighborList(ListOfNeighbors,NumberOfNeighbors, Distances, MaxDistance, aggct)
	wave ListOfNeighbors, NumberOfNeighbors, Distances
	variable MaxDistance, aggct
	
	variable i
	For(i=0;i<aggct;i+=1)
		if(Distances[i]<MaxDistance)	//this is neighbor!	
			//i is now old particle as neighbor
			//aggct is new particle	
			ListOfNeighbors[aggct][NumberOfNeighbors[aggct]]=i
			NumberOfNeighbors[aggct]+=1
			ListOfNeighbors[i][NumberOfNeighbors[i]]=aggct
			NumberOfNeighbors[i]+=1
		endif
	endfor 
	
end
//******************************************************************************************************************************************************

//static
// Function IR3A_MakeAgg(DegreeOfAggregation,MassFractalAggregate,StickingProbability, AllowedNearDistance)
//	variable DegreeOfAggregation,StickingProbability, AllowedNearDistance
//	wave MassFractalAggregate
//	
//	DFref oldDf= GetDataFolderDFR()
//
//	SetDataFolder root:Packages:AggregateModeling
//	Wave Distances
//	make/Free/N=(dimsize(MassFractalAggregate,0),3) CurSite
//	make/Free/N=(dimsize(MassFractalAggregate,0)) tmpCol
//	variable chcnt=1,px,py,pz,aggct=1,cnt,con,stuck,dim,choice,wall,Rd=16,GL=16,farpoint,index=0, tmpVal
//	NVAR AttemptValue
//	AttemptValue=1
//	NVAR BoxSize
//	PauseUpdate
//	Do
//		// resize box based on size of Agg
//		index=0
//		do
//			if(MassFractalAggregate[aggct-1][index]>farpoint)
//				farpoint=MassFractalAggregate[aggct-1][index]
//			endif
//			index+=1
//		while(index<3)
//		GL=2*abs(farpoint)+10
//		BoxSize=GL		
//		// initialize particle on a random wall of the box
//		wall=0;choice=0
//		if(aggct<64)	// choose random wall on smaller box for low aggct
//			do
//				wall=abs(round(enoise(7)))
//			while(wall==0 || wall==7)
//			if(wall==1)
//				px=-1+Rd/2;py=round(enoise(Rd/2));pz=round(enoise(Rd/2))
//			endif
//			if(wall==2)
//				px=1-Rd/2;py=round(enoise(Rd/2));pz=round(enoise(Rd/2))
//			endif
//			if(wall==3)
//				px=round(enoise(Rd/2));py=-1+Rd/2;pz=round(enoise(Rd/2))
//			endif
//			if(wall==4)
//				px=round(enoise(Rd/2));py=1-Rd/2;pz=round(enoise(Rd/2))
//			endif
//			if(wall==5)
//				px=round(enoise(Rd/2));py=round(enoise(Rd/2));pz=-1+Rd/2
//			endif
//			if(wall==6)
//				px=round(enoise(Rd/2));py=round(enoise(Rd/2));pz=1-Rd/2
//			endif
//		else		// choose random wall on normal box
//			do
//				wall=abs(round(enoise(7)))
//			while(wall==0 || wall==7)
//			if(wall==1)
//				px=-1+GL/2;py=round(enoise(GL/2));pz=round(enoise(GL/2))
//			endif
//			if(wall==2)
//				px=1-GL/2;py=round(enoise(GL/2));pz=round(enoise(GL/2))
//			endif
//			if(wall==3)
//				px=round(enoise(GL/2));py=-1+GL/2;pz=round(enoise(GL/2))
//			endif
//			if(wall==4)
//				px=round(enoise(GL/2));py=1-GL/2;pz=round(enoise(GL/2))
//			endif
//			if(wall==5)
//				px=round(enoise(GL/2));py=round(enoise(GL/2));pz=-1+GL/2
//			endif
//			if(wall==6)
//				px=round(enoise(GL/2));py=round(enoise(GL/2));pz=1-GL/2
//			endif
//		endif
//		// Move the particle until it a) hits the chain or b) leaves the box, if b) you need to have it reenter the box at a mirror position.
//		do	//move 1 step in any direction
//			//choice=0
//			//do
//			//choice=abs(round(enoise(7)))
//			choice = floor(1 + mod(abs(enoise(100*6)),6))	
//			//while(choice==0 || choice==7)
//			if(choice==1)
//				px+=1
//			endif
//			if(choice==2)	
//				px-=1
//			endif
//			if(choice==3)	
//				py+=1
//			endif
//			if(choice==4)
//				py-=1
//			endif
//			if(choice==5)	
//				pz+=1
//			endif
//			if(choice==6)	
//				pz-=1
//			endif
//			//if you leave the box (a likely event) then go to the other side and reenter the box (mirror)
//			If(aggct<64)	// use smaller box for low number of particles
//				if(px>Rd/2)
//					px=px-Rd
//				endif
//				if(px<-Rd/2)
//					px=px+Rd
//				endif
//				if(py>Rd/2)
//					py=py-Rd
//				endif
//				if(py<-Rd/2)
//					py=py+Rd
//				endif
//				if(pz>Rd/2)
//					pz=pz-Rd
//				endif
//				if(pz<-Rd/2)
//					pz=pz+Rd
//				endif	
//			else		// use normal box for higher number of particles
//				if(px>GL/2)
//					px=px-GL
//				endif
//				if(px<-GL/2)
//					px=px+GL
//				endif
//				if(py>GL/2)
//					py=py-GL
//				endif
//				if(py<-GL/2)
//					py=py+GL
//				endif
//				if(pz>GL/2)
//					pz=pz-GL
//				endif
//				if(pz<-GL/2)
//					pz=pz+GL
//				endif
//			endif
//			cnt=0;con=0
//			// check how many neighboring sites are occupied
//			//this is by far the longest step in the whole procedure
//			//basically, we are looking for how many neighbors px,py,pz position has 
//			//this is already much better than before, but it would really be nice to find better way of doing this. We are doing this A LOT. With every particle move, so it is done many, many times. 
//			Multithread Distances[0,aggct] = ((px-MassFractalAggregate[p][0])^2 + (py-MassFractalAggregate[p][1])^2 + (pz-MassFractalAggregate[p][2])^2)		//	Multithread helps, in my test case reduces time by ~60%
//			//this is slower... 
//			//CurSite[][0]=px
//			//CurSite[][1]=py
//			//CurSite[][2]=pz
//			//MatrixOp/O/Free/NTHR=0 Distances = sumRows(powR((MassFractalAggregate-CurSite),2))
//			variable MaxDistance = 1.05*AllowedNearDistance			//1 - in line nearest neighbor (1 step), 2 is two step nearest neighbor and 3 is nearest neighbor in any direction (3 step nearest neighbor). 
//			Histogram/B={0.5,MaxDistance,2}/R=[0,aggct]/Dest=DistHist Distances			//histogram - bin[0] is from 0.5 - 3.1, max allowed distance^2 is 3
//			con = DistHist[0]																	// this is number of nearest neighbors with distance below sqrt(3)
//			//another method, suggested by WM, but is slower, much slower ...
//			//			CurSite[0][0]=px
//			//			CurSite[0][1]=py
//			//			CurSite[0][2]=pz
//			//			MatrixOp/Free TestWv = catRows(CurSite,agg)
//			//			FPClustering /DSO TestWv
//			//			Wave M_DistanceMap
//			//			//Edit/K=1 root:M_DistanceMap
//			//			MatrixOp/Free Distances=row(M_DistanceMap,0)
//			//			//Edit/K=1 root:Distances
//			//			Histogram/B={0.1,1.8,2}/Dest=DistHist Distances
//			//			//Edit/K=1 root:DistHist
//			//			con = DistHist[0]
//			// end of neighbor counting. 
//			//choice=0
//			if(con>=1)	// particle can StickingProbability if there is at least 1 neighbor
//				do
//					// apply StickingProbabilitying probability between 1% and 100%
//					choice=floor(1 + mod(abs(enoise(100*99)),100))		//generates random integer from 1 to 99
//					choice-=1
//					AttemptValue+=1
//					if(choice<=StickingProbability)
//						stuck=1
//						con=0
//					else
//						con-=1
//						stuck=0
//					endif
//				while(con>=1)
//			//keep moving if alone or rejected by StickingProbabilitying probability
//			else
//				stuck=0
//			endif
//			//if the particle StickingProbabilitys, add it to the aggregate
//			variable steps=trunc(DegreeOfAggregation/10)
//			steps = max(steps,100)
//			if(stuck==1 && IR3A_IsPXYZNOTinList3DWave(MassFractalAggregate,px,py,pz, aggct))	//added here to make sure we do nto accidentally add existing particle. 
//				if(mod(aggct,steps)<1) ///round(DegreeOfAggregation/50))==aggct/round(DegreeOfAggregation/50))
//					Print time()+"  Added "+num2str(aggct)+" particles to the aggregate  "	//takes needless time.. 
//				endif
//				MassFractalAggregate[aggct][0]=px
//				MassFractalAggregate[aggct][1]=py
//				MassFractalAggregate[aggct][2]=pz
//				aggct+=1
//			endif
//		while(stuck==0)
//		stuck=0 //reset stuck flag
//	While(aggct<DegreeOfAggregation)	// stop aggregate growth when there are DegreeOfAggregation particles in Agg
//	Print time()+"  Created Aggregate with "+num2str(aggct)+" particles in it" 	//takes needless time.. 
//	setDataFOlder OldDf
//
//End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//static
Function IR3A_IsPXYZNOTinList3DWave(A3DWaveList,px,py,pz, MaxPoints)
	wave A3DWaveList
	variable px,py,pz, MaxPoints
	variable i
	FOr(i=0;i<MaxPoints;i+=1)
		if((abs(A3DWaveList[i][0]-px)+abs(A3DWaveList[i][1]-py)+abs(A3DWaveList[i][2]-pz))<0.2)
			return 0
		endif
	endfor
	return 1
	
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

//static Function IR3A_Ends(MassFractalAggregate, breakOnFail)
//	wave MassFractalAggregate
//	variable breakOnFail
//
//	DFref oldDf= GetDataFolderDFR()
//	SetDataFolder root:Packages:AggregateModeling
//	Wave/Z ListOfNeighbors = root:Packages:AggregateModeling:ListOfNeighbors
//	//this is list of each particle neighbors. Any one which has only one neigbor, is end point. 
//	//we want to create wave containing row numbers for rows, where Column[2] is =0  
//	if(WaveExists(ListOfNeighbors))
//		make/O/N=(DimSize(ListOfNeighbors, 0)) endpoints
//		variable i
//		endpoints = numtype(ListOfNeighbors[p][1])==2 ? p : NaN
//		Extract /O endpoints, endpoints, numtype(endpoints)==0
//	else
//		//this is old method, which for soem reason even does nto work as far as I can say... 
//		NVAR DegreeOfAggregation
//		Wave endpoints
//	
//		variable cnt=0,ncnt=0,con=0,endcnt=0,dim=0
//		Make/n=(26,3)/Free nghbr
//		Wave/Z nghbrOfsetList
//		if(!WaveExists(	nghbrOfsetList))
//			IR3A_MakeNBROffsetList()
//		endif
//		do
//			// define neighbors for each point in agg
//			nghbr = nghbrOfsetList[p][q] + MassFractalAggregate[cnt][q]
//			ncnt=0;con=0
//			do
//				dim=0
//				do
//					if(nghbr[dim][0]==MassFractalAggregate[ncnt][0]&&nghbr[dim][1]==MassFractalAggregate[ncnt][1]&&nghbr[dim][2]==MassFractalAggregate[ncnt][2])
//						con+=1
//					endif
//					dim+=1
//				while(dim<26)
//				ncnt+=1
//			while(ncnt<DegreeOfAggregation)
//			// it's an endpoint if there is exactly 1 neighboring point
//			// record position in x, y, z and then record index in agg
//			if(con==1)
//				endpoints[endcnt][0]=MassFractalAggregate[cnt][0];endpoints[endcnt][1]=MassFractalAggregate[cnt][1];endpoints[endcnt][2]=MassFractalAggregate[cnt][2];endpoints[endcnt][3]=cnt
//				endcnt+=1
//			endif
//			cnt+=1
//			//Print cnt
//		while(cnt<DegreeOfAggregation)
//		//remove extra rows from endpoints wave
//		DeletePoints endcnt,DegreeOfAggregation, endpoints
//	endif
//	variable Failed = 0
//	if(dimsize(endpoints,0)<5)
//		Failed = 1
//		if(breakOnFail)
//			DoALert/T="FailedGrowth" 0, "Not enough endpoints found, too compact particle"
//		endif
//	endif
//	setDataFOlder OldDf
//	Print time()+"  Finished running Find Ends" 	//takes needless time.. 
//	return Failed
//End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
// 3-16-2021 verification - yields same numbers as original code. 
//static Function IR3A_Reted(endpoints)
//	wave endpoints
//	// calculate longest end-to-end distance for each combination of endpoints and its square for weight-averaged end-to-end distance	
//	DFref oldDf= GetDataFolderDFR()
//
//	SetDataFolder root:Packages:AggregateModeling
//	NVAR DegreeOfAggregation=root:Packages:AggregateModeling:DegreeOfAggregation
//	NVAR RValue=root:Packages:AggregateModeling:RValue
//	NVAR dfValue=root:Packages:AggregateModeling:dfValue
//	NVAR RgPrimary=root:Packages:AggregateModeling:RgPrimary
//	NVAR RxRgPrimaryValue=root:Packages:AggregateModeling:RxRgPrimaryValue
//
//	variable endnum=DimSize(endpoints,0), numcomb=binomial(endnum,2), cnt=0,endadd=0,ecnt=1,REnd=0,Rsum=0,Retend=0,RAve=0,rem=endnum
//	Make/n=(numcomb,1)/o enddist=0
//	Make/n=(endnum-3,7)/o Rlarge=0
//	do	// determine end-to-end distance between all endpoints
//		do
//			enddist[endadd]=sqrt((endpoints[cnt][0]-endpoints[ecnt][0])^2+(endpoints[cnt][1]-endpoints[ecnt][1])^2+(endpoints[cnt][2]-endpoints[ecnt][2])^2)
//			if(endnum-cnt>3)	
//				if(enddist[endadd]>Rlarge[cnt][6])
//					Rlarge[cnt][0]=endpoints[cnt][0];Rlarge[cnt][1]=endpoints[cnt][1];Rlarge[cnt][2]=endpoints[cnt][2]
//					Rlarge[cnt][3]=endpoints[ecnt][0];Rlarge[cnt][4]=endpoints[ecnt][1];Rlarge[cnt][5]=endpoints[ecnt][2]
//					Rlarge[cnt][6]=enddist[endadd]
//				endif
//			endif
//			ecnt+=1
//			endadd+=1
//		while(ecnt<endnum)
//		cnt+=1
//		ecnt=cnt+1
//	while(ecnt<endnum)
//	cnt=0
//	do	// calculate longest end-to-end distance for each combination of endpoints and its square for weight-averaged end-to-end distance
//		REnd+=(Rlarge[cnt][6])*(Rlarge[cnt][6])
//		RSum+=(Rlarge[cnt][6])
//		cnt+=1
//	while(cnt<endnum-3)
//	RAve=RSum/cnt
//	REnd/=RSum
//	cnt=0
//	// Print and record R, df
//	
//	Print "R = "+num2str(REnd)
//	Print "df= "+num2str(log(DegreeOfAggregation)/log(REnd))
//	RValue=Rend
//	dfValue=log(DegreeOfAggregation)/log(REnd)
//	RxRgPrimaryValue = REnd*RgPrimary
//	setDataFOlder OldDf
//End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//
//static Function IR3A_Path(NumberOfTestPaths)
//	variable NumberOfTestPaths
//
//	DFref oldDf= GetDataFolderDFR()
//
//	SetDataFolder root:Packages:AggregateModeling
//	print time()+"  Started parameters evaluation, Calculating...   this takes longest time for these functions "
//	wave MassFractalAggregate
//	Wave endpoints
//	NVAR DegreeOfAggregation
//	NVAR AttemptValue
//	variable minPathLengthAccepted
//	minPathLengthAccepted = floor(min(DegreeOfAggregation^(1/2), 20))		//minimum length of path accpeted as evaluation path, for large particles original value is crazily large. 
//	Make/n=(26,3)/Free nghbr
//	Wave/Z nghbrOfsetList
//	if(!WaveExists(nghbrOfsetList))
//		IR3A_MakeNBROffsetList()
//	endif
//	Make /n=(DegreeOfAggregation,26)/O NeighborList=nan
//	Make/n=(DegreeOfAggregation,1)/Free Pathing=nan
//	Make/n=(NumberOfTestPaths,7)/Free Paths=nan
//	variable endnum=DimSize(endpoints,0), choice=0, cnt=0,ncnt=0,nnum=0,dim=0,con=0,pcnt=0,nans=0,flag=0,ecnt=0,highp,p1,p2,mom1,mom2,startpoint
//	Make/n=(endnum,1)/O LongPath=0
//	variable i
//	MatrixOp/Free EndPointsDistances=col(endpoints,3)
//	variable startTime=ticks
//	For(cnt=0;cnt<DegreeOfAggregation;cnt+=1)
//		nghbr = nghbrOfsetList[p][q] + MassFractalAggregate[cnt][q]					//this generates list of 26 neighbor positions, if any, around the agg[cnt] particle
//		nnum=0
//		For(ncnt=0;ncnt<DegreeOfAggregation;ncnt+=1)
//			For(dim=0;dim<26;dim+=1)
//				if(nghbr[dim][0]==MassFractalAggregate[ncnt][0]&&nghbr[dim][1]==MassFractalAggregate[ncnt][1]&&nghbr[dim][2]==MassFractalAggregate[ncnt][2])
//					NeighborList[cnt][nnum]=ncnt			//cnt is external loop, cnt = 0 ...DegreeOfAggregation
//					nnum+=1
//				endif
//			endfor
//		endfor
//	endfor
//	cnt=0
//	do	// snake through paths
//		pcnt=0
//		startpoint=floor(mod(abs(enoise(100*(endnum-1))),endnum))		//generates random integer from 0 to endnum
//		// record starting position and starting index in agg
//		Paths[cnt][0]=endpoints[startpoint][0]
//		Paths[cnt][1]=endpoints[startpoint][1]
//		Paths[cnt][2]=endpoints[startpoint][2]
//		Pathing[0]=endpoints[startpoint][3]
//		choice=0;con=0
//		do	//pick a random neighbor from list
//			ncnt=0
//			nans=0
//			flag=0
//			//this is faster... 	
//			For(i=0;i<8;i+=1)
//				if(numtype(NeighborList[Pathing[pcnt]][i])==2)
//					nans=8-i
//					break
//				endif
//			endfor
//			variable target= 8-nans-1
//			choice=floor(mod(abs(enoise(100*target)),target+1))		//generates random number from non NaNs entries... 		
//			ncnt=0
//			do	// check to see if value already in path
//				if(NeighborList[Pathing[pcnt]][choice]==Pathing[ncnt])
//					flag+=1
//				endif
//				ncnt+=1
//			while(ncnt<pcnt)
//			if(flag>=2)	// is there a loop in the aggregate?
//				con=1
//			else		// add normally
//				pcnt+=1				//this pcnt is sometimes too large, not sure how to avoid it... 
//				if(pcnt>=DegreeOfAggregation)
//					Abort "Wrong value in IR3A_Path, try again."
//				endif
//				Pathing[pcnt]=NeighborList[Pathing[pcnt-1]][choice]
//			endif
//			ncnt=1
//			ecnt=0
//			// this is about 2x faster...  EndPointsDistances was created above just once, it does not change. 
//			FindValue /V=(Pathing[pcnt])/T=0.1 EndPointsDistances
//			if(V_value>-0.1)
//				con=1
//			endif
//			// (2) done... 			
//		while(con!=1)
//		if(pcnt>minPathLengthAccepted) 				// only interested in longer paths that span aggregate; throws away short paths
//			Paths[cnt][3]=MassFractalAggregate[Pathing[pcnt]][0]
//			Paths[cnt][4]=MassFractalAggregate[Pathing[pcnt]][1]
//			Paths[cnt][5]=MassFractalAggregate[Pathing[pcnt]][2]
//			Paths[cnt][6]=pcnt+1
//			if(Paths[cnt][6]>LongPath[startpoint])
//				LongPath[startpoint]=Paths[cnt][6]	
//			endif
//			cnt+=1
//			//print "Evaluated path length of "+num2str(pcnt)
//		else
//			//print "Discarded path length of "+num2str(pcnt)
//			continue
//		endif
//		if(mod(cnt,500)==0) 
//			Print time()+"  Working... Evaluated "+num2str(cnt)+" Paths through the system"	//takes needless time.. 
//		endif
//	while(cnt<NumberOfTestPaths)
//	ncnt=0;highp=0;p1=0;p2=0
//	do	// determine weight-averaged percolation pathway
//		if(LongPath[ncnt]>highp)
//			highp=LongPAth[ncnt]
//		endif
//		p1+=(LongPath[ncnt])
//		p2+=(LongPath[ncnt])*(LongPath[ncnt])
//		ncnt+=1
//	while(ncnt<endnum)
//	mom2=round(p2/p1);mom1=round(p1/endnum)
//	// print results
//	NVAR dfValue
//	NVAR RValue
//	NVAR pValue
//	NVAR sValue
//	NVAR cValue
//	NVAR dminValue
//	NVAR TrueStickingProbability
//	NVAR StickingProbability=root:Packages:AggregateModeling:StickingProbability
//	NVAR RgPrimary=root:Packages:AggregateModeling:RgPrimary
//	NVAR AllowedNearDistance=root:Packages:AggregateModeling:AllowedNearDistance
//	pValue = mom2
//	cValue=ln(DegreeOfAggregation)/ln(pValue)
//	dminValue=dfValue/cValue
//	sValue=round(exp(ln(DegreeOfAggregation)/dminValue))
//	TrueStickingProbability = 100*DegreeOfAggregation/AttemptValue
//	NVAR RxRgPrimaryValue=root:Packages:AggregateModeling:RxRgPrimaryValue
//	variable PrimaryDiameter = 2*sqrt(5/3)*RgPrimary
//	RxRgPrimaryValue = RValue*PrimaryDiameter
//	Print "R [primary particles]= "+num2str(RValue)
//	Print "R [Angstroms] = "+num2str(RValue*PrimaryDiameter)
//	Print "z = "+num2str(DegreeOfAggregation)
//	Print "p = "+num2str(pValue)
//	Print "s = "+num2str(sValue)
//	Print "df = "+num2str(dfValue)
//	Print "dmin = "+num2str(dminValue)
//	Print "c = "+num2str(cValue)
//	Print "True Sticking Probability = "+num2str(100*DegreeOfAggregation/AttemptValue)+"%"
//	//appned note to MassFractalAggregate
//	string NoteText
//	NoteText="Mass Fractal Aggregate created="+date()+", "+time()+";z="+num2str(DegreeOfAggregation)+";StickingProbability="+num2str(StickingProbability)+";StickingMethod="+num2str(AllowedNearDistance)+";R="+num2str(RValue)+";Rprimary="+num2str(RgPrimary)+";p="+num2str(pValue)
//	NoteText+=";RxRgPrimaryValue="+num2str(RValue*PrimaryDiameter)+";s="+num2str(sValue)+";df="+num2str(IN2G_roundSignificant(dfValue,4))+";dmin="+num2str(IN2G_roundSignificant(dminValue,4))+";c="+num2str(IN2G_roundSignificant(cValue,4))+";True Sticking Probability="+num2str(100*DegreeOfAggregation/AttemptValue)+";"
//	Note MassFractalAggregate, NoteText
//	setDataFolder OldDf
//End

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************


static Function IR3A_GetResults()
	DFref oldDf= GetDataFolderDFR()

	SetDataFolder root:Packages:AggregateModeling
	NVAR RgPrimary=root:Packages:AggregateModeling:RgPrimary
	NVAR RxRgPrimaryValue=root:Packages:AggregateModeling:RxRgPrimaryValue
	NVAR DegreeOfAggregation
	NVAR RValue
	NVAR pValue
	NVAR dfValue
	NVAR dminValue
	NVAR cValue
	NVAR sValue
	NVAR AttemptValue
	NVAR AllowedNearDistance
	cValue=ln(DegreeOfAggregation)/ln(pValue)
	dminValue=dfValue/cValue
	sValue=round(exp(ln(DegreeOfAggregation)/dminValue))
	Print "R [A]= "+num2str(RxRgPrimaryValue)
	Print "df = "+num2str(dfValue)
	Print "z = "+num2str(DegreeOfAggregation)
	Print "p= "+num2str(pValue)
	Print "s = "+num2str(sValue)
	Print "dmin = "+num2str(dminValue)
	Print "c = "+num2str(cValue)
	Print "True Sticking Probability = "+num2str(100*DegreeOfAggregation/AttemptValue)+"%"
	print "Sticking method = "+num2str(AllowedNearDistance)
	setDataFOlder OldDf
End

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************


static Function IR3A_GizmoViewScatterPlot(ScatterPlotWave) : GizmoPlot
	wave ScatterPlotWave

	variable mnd = IR3A_GetAggMaxSize(ScatterPlotWave)
	variable boxSize=mnd+2		//make the box larger... 
	DoWIndow MassFractalAggregateView
	if(V_Flag)
		DoWIndow/F MassFractalAggregateView
		ModifyGizmo setOuterBox={-1*boxSize,boxSize,-1*boxSize,boxSize,-1*boxSize,boxSize}
		ModifyGizmo scalingOption=0
		ModifyGizmo modifyObject=Particle,objectType=Sphere,property={radius,1/(4+mnd)}
	else
		PauseUpdate    		// building window...
		// Building Gizmo 7 window...
		NewGizmo/K=1/T="Mass Fractal Aggregate View"/W=(35,45,550,505)
		DoWIndow/C MassFractalAggregateView
		ModifyGizmo startRecMacro=700
		AppendToGizmo Scatter=ScatterPlotWave,name=scatter0
		ModifyGizmo ModifyObject=scatter0,objectType=scatter,property={ scatterColorType,0}
		ModifyGizmo ModifyObject=scatter0,objectType=scatter,property={ markerType,0}
		ModifyGizmo ModifyObject=scatter0,objectType=scatter,property={ sizeType,0}
		ModifyGizmo ModifyObject=scatter0,objectType=scatter,property={ rotationType,0}
		ModifyGizmo ModifyObject=scatter0,objectType=scatter,property={ Shape,2}
		ModifyGizmo ModifyObject=scatter0,objectType=scatter,property={ size,1}
		ModifyGizmo ModifyObject=scatter0,objectType=scatter,property={ color,1,0,0,1}
		//sphere as object definition:
		AppendToGizmo sphere={1/mnd,25,25},name=Particle
		ModifyGizmo modifyObject=Particle,objectType=Sphere,property={colorType,1}
		ModifyGizmo modifyObject=Particle,objectType=Sphere,property={color,0.000015,0.600000,0.304250,1.000000}
		AppendToGizmo attribute diffuse={0.5,0.5,0.5,1,1032},name=diffuse0
		ModifyGizmo attributeType=diffuse,modifyAttribute={diffuse0,0.733333,0.733333,0.733333,1,1032}
		ModifyGizmo modifyObject=Particle,objectType=Sphere,property={radius,1/(4+mnd)}
		ModifyGizmo ModifyObject=scatter0,objectType=scatter,property={ Shape,7}
		ModifyGizmo ModifyObject=scatter0,objectType=scatter,property={ objectName,Particle}
		AppendToGizmo Axes=boxAxes,name=axes0
		ModifyGizmo ModifyObject=axes0,objectType=Axes,property={-1,axisScalingMode,1}
		ModifyGizmo ModifyObject=axes0,objectType=Axes,property={-1,axisColor,0,0,0,1}
		ModifyGizmo ModifyObject=axes0,objectType=Axes,property={0,ticks,3}
		ModifyGizmo ModifyObject=axes0,objectType=Axes,property={1,ticks,3}
		ModifyGizmo ModifyObject=axes0,objectType=Axes,property={2,ticks,3}
		ModifyGizmo modifyObject=axes0,objectType=Axes,property={-1,Clipped,0}
		AppendToGizmo light=Directional,name=LightFor3dView
		ModifyGizmo modifyObject=LightFor3dView,objectType=light,property={ position,0.000000,0.000000,-1.000000,0.000000}
		ModifyGizmo modifyObject=LightFor3dView,objectType=light,property={ direction,0.000000,0.000000,-1.000000}
		ModifyGizmo modifyObject=LightFor3dView,objectType=light,property={ ambient,0.400000,0.400000,0.400000,1.000000}
		ModifyGizmo modifyObject=LightFor3dView,objectType=light,property={ specular,1.000000,1.000000,1.000000,1.000000}
		ModifyGizmo modifyObject=LightFor3dView,objectType=light,property={ diffuse,0.933333,0.933333,0.933333,1.000000}
		ModifyGizmo modifyObject=LightFor3dView,objectType=light,property={ position,-0.6392,0.7354,0.2250,0.0000}
		ModifyGizmo modifyObject=LightFor3dView,objectType=light,property={ direction,-0.6392,0.7354,0.2250}
		ModifyGizmo setDisplayList=0, object=LightFor3dView
		ModifyGizmo setDisplayList=1, object=scatter0 
		ModifyGizmo setDisplayList=2, object=axes0
		ModifyGizmo currentGroupObject=""
		//ModifyGizmo SETQUATERNION={0.535993,-0.191531,-0.283415,0.771818}
		//now scale this thing... 
		ModifyGizmo setOuterBox={-1*boxSize,boxSize,-1*boxSize,boxSize,-1*boxSize,boxSize}
		ModifyGizmo scalingOption=0
		Modifygizmo enhance
		//give user tools to work with
		//ModifyGizmo showInfo
		//ModifyGizmo infoWindow={350,550,822,320}
		ModifyGizmo resumeUpdates
		ModifyGizmo endRecMacro
		ModifyGizmo SETQUATERNION={-0.041312,-0.884834,-0.102589,0.452588}
	endif
	DoWindow FractalAggregatePanel
	if(V_Flag)
		AutoPositionWindow /M=0/R=FractalAggregatePanel MassFractalAggregateView
	endif
	DoWindow MassFractalAggDataPlot
	if(V_Flag)
		AutoPositionWindow /M=1/R=MassFractalAggDataPlot MassFractalAggregateView
	endif

EndMacro
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************


static Function IR3A_GetAggMaxSize(MassFractalAggregate)
	wave MassFractalAggregate
	
	WaveStats/Q MassFractalAggregate

	variable MaxNeeded=max(V_max, abs(V_min) )
	
	return MaxNeeded
end

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************


Function IR3A_PopMenuProc(pa) : PopupMenuControl
	STRUCT WMPopupAction &pa

	NVAR SelectedLevel=root:Packages:AggregateModeling:SelectedLevel
	SVAR SlectedBranchedLevels=root:Packages:AggregateModeling:SlectedBranchedLevels
	NVAR SelectedQlevel=root:Packages:AggregateModeling:SelectedQlevel
	NVAR SelectedBlevel=root:Packages:AggregateModeling:SelectedBlevel

	switch( pa.eventCode )
		case 2: // mouse up
			Variable popNum = pa.popNum
			String popStr = pa.popStr
			string CtrlName=pa.ctrlName
			if(stringMatch(CtrlName,"AvailableLevels"))
				SelectedLevel = str2num(popStr[0,0])
				SlectedBranchedLevels=popStr
				IR3A_CalculateBranchedMassFr()
				IR3A_CalculateAggValues()
			endif
			if(stringMatch(CtrlName,"IntensityDataName")||stringMatch(CtrlName,"SelectDataFolder"))
				IR2C_PanelPopupControl(pa)		
				IR3A_SetControlsInPanel()	
				IR3A_FindAvailableLevels()
				IR3A_ClearVariables()
				IR3A_CalculateBranchedMassFr()
				IR3A_CalculateAggValues()
			endif	
			if(stringMatch(CtrlName,"AllowedNearDistance"))
				NVAR AllowedNearDistance=root:Packages:AggregateModeling:AllowedNearDistance
				AllowedNearDistance = popNum
			endif
			if(stringMatch(CtrlName,"NUmberOfTestAggregates"))
				NVAR NUmberOfTestAggregates=root:Packages:AggregateModeling:NUmberOfTestAggregates
				NUmberOfTestAggregates = str2num(popStr)
			endif
			if(stringMatch(CtrlName,"StickProbNumSteps"))
				NVAR StickProbNumSteps=root:Packages:AggregateModeling:StickProbNumSteps
				StickProbNumSteps = str2num(popStr)
				IR3A_CalculateAggValues()
			endif
			
			if(stringMatch(CtrlName,"MParticleAttraction"))
				SVAR MultiParticleAttraction=root:Packages:AggregateModeling:MultiParticleAttraction
				MultiParticleAttraction = popStr
			endif

			break
	endswitch

	return 0
End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************


static Function IR3A_FindAvailableLevels()
	
	NVAR/Z UseCurrentResults=root:Packages:AggregateModeling:CurrentResults
	DoWIndow FractalAggregatePanel
	if(!NVAR_Exists(UseCurrentresults) || !V_Flag)
		return 0
	endif
	
	NVAR UseStoredResults=root:Packages:AggregateModeling:StoredResults
	String quote = "\""

	SVAR Model=root:Packages:AggregateModeling:Model
	variable LNumOfLevels, i
	
	if(UseCurrentResults)
		NVAR/Z NumberOfLevels = root:Packages:Irena_UnifFit:NumberOfLevels
		if(!NVAR_Exists(NumberOfLevels))
			return 0			//no Unified Fit at all... 
		endif
		LNumOfLevels = NumberOfLevels
	else
		LNumOfLevels =IR3A_ReturnNoteNumValue("NumberOfModelledLevels")	
	endif
	string AvailableLevels=""
	if(stringmatch(Model,"Branched mass fractal"))	
//		if(LNumOfLevels>=1)
//			AvailableLevels+=num2str(1)+";"
//		endif
		For(i=2;i<=LNumOfLevels;i+=1)
			AvailableLevels+=num2str(i)+"/"+num2str(i-1)+";"//+num2str(i)+";"
		endfor
	else
		AvailableLevels=""
//		For(i=1;i<=LNumOfLevels;i+=1)
//			AvailableLevels+=num2str(i)+";"
//		endfor
	endif
	string OnlyNumLevels=AvailableLevels
//	if(stringmatch(Model,"TwoPhase*"))	
//		AvailableLevels+="Range;All;"
//	endif	
//	if(stringmatch(Model,"Invariant*"))	
//		AvailableLevels+="Range;"
//	endif	
	AvailableLevels = quote + AvailableLevels + quote
	OnlyNumLevels = quote + OnlyNumLevels + quote
	NVAR SelectedQlevel=root:Packages:AggregateModeling:SelectedQlevel
	NVAR SelectedBlevel=root:Packages:AggregateModeling:SelectedBlevel
	SVAR SlectedBranchedLevels=root:Packages:AggregateModeling:SlectedBranchedLevels
	string loQStr="---"
	if(SelectedQlevel>0)
		loQStr=num2str(SelectedQlevel)
	endif
	string hiQStr="---"
	if(SelectedBlevel>0)
		hiQStr=num2str(SelectedBlevel)
	endif
	string AvLevStr="---"
	if(stringmatch(AvailableLevels,"*"+SlectedBranchedLevels+"*"))
		AvLevStr=SlectedBranchedLevels
	endif
	PopupMenu AvailableLevels,win=FractalAggregatePanel,mode=1,popvalue= AvLevStr, value=#AvailableLevels
//	PopupMenu SelectedQlevel,win=FractalAggregatePanel,mode=1,popvalue=loQStr, value=#OnlyNumLevels
//	PopupMenu SelectedBlevel,win=FractalAggregatePanel,mode=1,popvalue=hiQStr, value=#OnlyNumLevels
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

static  Function IR3A_ReturnNoteNumValue(KeyWord)
 	string KeyWord
 	
 	variable LUKVal
 	SVAR DataFolderName= root:Packages:AggregateModeling:DataFolderName
 	SVAR IntensityWaveName = root:Packages:AggregateModeling:IntensityWaveName
 	
 	Wave/Z LkpWv=$(DataFolderName+IntensityWaveName)
 	if(!WaveExists(LkpWv))
 		return NaN
 	endif
 	
 	LUKVal = NumberByKey(KeyWord, note(LkpWv)  , "=",";")
 	return LUKVal
 	
 end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************


static Function IR3A_CalculateBranchedMassFr()

	NVAR SelectedLevel = root:Packages:AggregateModeling:SelectedLevel
	SVAR SlectedBranchedLevels=root:Packages:AggregateModeling:SlectedBranchedLevels
	NVAR UseCurrentResults=root:Packages:AggregateModeling:CurrentResults
	NVAR UseStoredResults=root:Packages:AggregateModeling:StoredResults

	NVAR BrFract_G2=root:Packages:AggregateModeling:BrFract_G2
	NVAR BrFract_Rg2=root:Packages:AggregateModeling:BrFract_Rg2
	NVAR BrFract_B2=root:Packages:AggregateModeling:BrFract_B2
	NVAR BrFract_P2=root:Packages:AggregateModeling:BrFract_P2
	NVAR BrFract_G1=root:Packages:AggregateModeling:BrFract_G1
	NVAR BrFract_Rg1=root:Packages:AggregateModeling:BrFract_Rg1
	NVAR BrFract_B1=root:Packages:AggregateModeling:BrFract_B1
	NVAR BrFract_P1=root:Packages:AggregateModeling:BrFract_P1
	SVAR BrFract_ErrorMessage=root:Packages:AggregateModeling:BrFract_ErrorMessage
	NVAR BrFract_dmin=root:Packages:AggregateModeling:BrFract_dmin
	NVAR BrFract_c=root:Packages:AggregateModeling:BrFract_c
	NVAR BrFract_z=root:Packages:AggregateModeling:BrFract_z
	NVAR BrFract_fBr=root:Packages:AggregateModeling:BrFract_fBr
	NVAR BrFract_fM=root:Packages:AggregateModeling:BrFract_fM
	NVAR BrFract_df=root:Packages:AggregateModeling:BrFract_df
	
	BrFract_ErrorMessage = ""
	
	if(stringMatch(SlectedBranchedLevels,"2/1"))
		SelectedLevel = 2
	elseif(stringMatch(SlectedBranchedLevels,"3/2"))
		SelectedLevel = 3
	elseif(stringMatch(SlectedBranchedLevels,"4/3"))
		SelectedLevel = 4
	elseif(stringMatch(SlectedBranchedLevels,"5/4"))
		SelectedLevel = 5
	endif

	if(SelectedLevel>=2)
		if(UseCurrentResults)
			NVAR gG2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"G")
			BrFract_G2 = gG2
			NVAR gRg2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"Rg")
			BrFract_Rg2 = gRg2
			NVAR gB2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"B")
			BrFract_B2 = gB2
			NVAR gP2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"P")
			BrFract_P2 = gP2
			NVAR gG1=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel-1)+"G")
			BrFract_G1 = gG1
			NVAR gRg1=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel-1)+"Rg")
			BrFract_Rg1 = gRg1
			NVAR gB1=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel-1)+"B")
			BrFract_B1 = gB1
			NVAR gP1=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel-1)+"P")
			BrFract_P1 = gP1
		else
			//look up from wave note...
			BrFract_G2 = IR3A_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"G")
			BrFract_Rg2 = IR3A_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"Rg")
			BrFract_B2 = IR3A_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"B")
			BrFract_P2 = IR3A_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"P")
			BrFract_G1 = IR3A_ReturnNoteNumValue("Level"+num2str(SelectedLevel-1)+"G")
			BrFract_Rg1 = IR3A_ReturnNoteNumValue("Level"+num2str(SelectedLevel-1)+"Rg")
			BrFract_B1 = IR3A_ReturnNoteNumValue("Level"+num2str(SelectedLevel-1)+"B")
			BrFract_P1 = IR3A_ReturnNoteNumValue("Level"+num2str(SelectedLevel-1)+"P")
		endif
	elseif(SelectedLevel==1)
		if(UseCurrentResults)
			NVAR gG2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"G")
			BrFract_G2 = gG2
			NVAR gRg2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"Rg")
			BrFract_Rg2 = gRg2
			NVAR gB2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"B")
			BrFract_B2 = gB2
			NVAR gP2=$("root:Packages:Irena_UnifFit:Level"+num2str(SelectedLevel)+"P")
			BrFract_P2 = gP2
			BrFract_G1 =0
			BrFract_Rg1 = 0
			BrFract_B1 =0
			BrFract_P1 = 0
		else
			//look up from wave note...
			BrFract_G2 = IR3A_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"G")
			BrFract_Rg2 = IR3A_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"Rg")
			BrFract_B2 = IR3A_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"B")
			BrFract_P2 = IR3A_ReturnNoteNumValue("Level"+num2str(SelectedLevel)+"P")
			BrFract_G1 = 0
			BrFract_Rg1 = 0
			BrFract_B1 = 0
			BrFract_P1 = 0
		endif
	else
			BrFract_G2 = 0
			BrFract_Rg2 = 0
			BrFract_B2 = 0
			BrFract_P2 = 0
			BrFract_G1 = 0
			BrFract_Rg1 = 0
			BrFract_B1 = 0
			BrFract_P1 = 0
	endif
	if(strlen(SlectedBranchedLevels)>1)
		BrFract_dmin  =BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)
		BrFract_c  =BrFract_P2/(BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2))
		BrFract_z  =BrFract_G2/BrFract_G1 + 1 			//Greg, 11-24-2018: It should be G2/G1 +1  Karsten figured that out.  If G2 is 0 you still have one primary particle. 
		BrFract_fBr =(1-(BrFract_G2/BrFract_G1)^(1/(BrFract_P2/(BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)))-1))
		BrFract_fM  = (1-(BrFract_G2/BrFract_G1)^(1/((BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)))-1))
		BrFract_df  = BrFract_P2
	else
		BrFract_dmin  =BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2)
		BrFract_c  =BrFract_P2/(BrFract_B2*BrFract_Rg2^(BrFract_P2)/(exp(gammln(BrFract_P2/2))*BrFract_G2))
		BrFract_z  =Nan
		BrFract_fBr =NaN
		BrFract_fM  = NaN
	endif
	
	if(BrFract_c<0.96)
		BrFract_ErrorMessage =  "The mass fractal is too polydisperse to analyse, c < 1"
	else
		if(BrFract_c>=0.96 && BrFract_c<=1.04)//this should be in the range of 1 say +- .02
			BrFract_ErrorMessage = "THIS IS A LINEAR CHAIN WITH NO BRANCHES!"
		endif
		if(BrFract_c>=3)
			BrFract_ErrorMessage =  "There is a problem with the fit, c must be less than 3"
		endif
		if(BrFract_dmin>=3)
			BrFract_ErrorMessage = "There is a problem with the fit since dmin must be less than 3"
		endif
		if(BrFract_dmin>=0.96 && BrFract_dmin<=1.04 )//this should be in the range of 1 say +- .02
			BrFract_ErrorMessage = "This is a regular object, i.e.  c=1 rod, c=2 disk, c=3 sphere, etc."
		endif
	endif
	
	if(strlen(BrFract_ErrorMessage)>0)
		SetVariable BrFract_ErrorMessage, win=FractalAggregatePanel,  labelBack=(65535,49151,49151)
		beep
	else
		SetVariable BrFract_ErrorMessage, win=FractalAggregatePanel,  labelBack=0
	endif

end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************


Function IR3A_CheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR CurrentResults=root:packages:AggregateModeling:CurrentResults
			NVAR StoredResults=root:packages:AggregateModeling:StoredResults
			SVAR Model=root:Packages:AggregateModeling:Model
			if(stringMatch(cba.ctrlName,"CurrentResults"))
				StoredResults=!CurrentResults
				IR3A_UpdatePanelValues()
			endif
			if(stringMatch(cba.ctrlName,"StoredResults"))
				CurrentResults=!StoredResults
				IR3A_UpdatePanelValues()
			endif
			if(stringMatch(cba.ctrlName,"VaryStickingProbability"))
				IR3A_SetControlsInPanel()
			endif
			break
	endswitch

	return 0
End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3A_UpdatePanelValues()

			IR3A_SetControlsInPanel()	
			IR3A_FindAvailableLevels()
			IR3A_ClearVariables()
			IR3A_CalculateBranchedMassFr()
			IR3A_Create3DAggListForListbox()

end

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************


static Function IR3A_SetControlsInPanel()

		DOWindow FractalAggregatePanel
		if(!V_Flag)
			return 0
		endif 
		SVAR Model=root:Packages:AggregateModeling:Model
		NVAR CurrentResults = root:packages:AggregateModeling:CurrentResults
		
		PopupMenu SelectDataFolder, win=FractalAggregatePanel, disable=CurrentResults
		PopupMenu IntensityDataName, win=FractalAggregatePanel, disable=CurrentResults
		Setvariable FolderMatchStr, win=FractalAggregatePanel, disable=CurrentResults
		
		ControlInfo/W=FractalAggregatePanel  GrowthTabs
		STRUCT WMTabControlAction tca
		tca.eventCode = 2
		tca.tab=V_Value
		IR3A_GrowthTabProc(tca)

end

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

static Function IR3A_ClearVariables()


	NVAR BrFract_G2=root:Packages:AggregateModeling:BrFract_G2
	NVAR BrFract_Rg2=root:Packages:AggregateModeling:BrFract_Rg2
	NVAR BrFract_B2=root:Packages:AggregateModeling:BrFract_B2
	NVAR BrFract_P2=root:Packages:AggregateModeling:BrFract_P2
	NVAR BrFract_G1=root:Packages:AggregateModeling:BrFract_G1
	NVAR BrFract_Rg1=root:Packages:AggregateModeling:BrFract_Rg1
	NVAR BrFract_B1=root:Packages:AggregateModeling:BrFract_B1
	NVAR BrFract_P1=root:Packages:AggregateModeling:BrFract_P1
	SVAR BrFract_ErrorMessage=root:Packages:AggregateModeling:BrFract_ErrorMessage
	NVAR BrFract_dmin=root:Packages:AggregateModeling:BrFract_dmin
	NVAR BrFract_c=root:Packages:AggregateModeling:BrFract_c
	NVAR BrFract_z=root:Packages:AggregateModeling:BrFract_z
	NVAR BrFract_fBr=root:Packages:AggregateModeling:BrFract_fBr
	NVAR BrFract_fM=root:Packages:AggregateModeling:BrFract_fM
	NVAR BrFract_df=root:Packages:AggregateModeling:BrFract_df
	
		BrFract_G2 = 0
		BrFract_Rg2 = 0
		BrFract_B2 = 0
		BrFract_P2 = 0
		BrFract_G1 = 0
		BrFract_Rg1 = 0
		BrFract_B1 = 0
		BrFract_P1 = 0
		BrFract_ErrorMessage=""
		BrFract_dmin=0
		BrFract_c=0
		BrFract_z=0
		BrFract_fBr=0
		BrFract_fM=0
		BrFract_df=0

end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3A_FindBestFitGrowth()
	//will try to find best fit growth using random method... 
	
	
	NVAR CurrentMisfitValue=root:Packages:AggregateModeling:CurrentMisfitValue		//misfit value of existing growth		
	NVAR MaxNumTests=root:Packages:AggregateModeling:MaxNumTests					//max growth at specific condition
	NVAR VaryStickingProbability=root:Packages:AggregateModeling:VaryStickingProbability
	NVAR StickingProbMin=root:Packages:AggregateModeling:StickingProbMin
	NVAR StickingProbMax=root:Packages:AggregateModeling:StickingProbMax
	NVAR StickProbNumSteps=root:Packages:AggregateModeling:StickProbNumSteps
	NVAR MinSearchTargetValue=root:Packages:AggregateModeling:MinSearchTargetValue
	NVAR TotalGrowthsPlanned=root:Packages:AggregateModeling:TotalGrowthsPlanned
	NVAR StickingProbability = root:Packages:AggregateModeling:StickingProbability
	//NVAR MinSearchTargetValue=root:Packages:AggregateModeling:MinSearchTargetValue
	variable MinMisfitFound=1e5
	variable i, j, failed, NumStickProbSteps=0
	variable StickProbStepValu=0
	variable StickingProbabilityStart
	variable OriginalStickingProbability
	variable NumberOftestedAggregates=0
	OriginalStickingProbability = StickingProbability
	StickingProbabilityStart = StickingProbability
	if(VaryStickingProbability)
		NumStickProbSteps = StickProbNumSteps-1
		StickProbStepValu = abs(StickingProbMax-StickingProbMin)/NumStickProbSteps
		StickingProbabilityStart = StickingProbMin
	endif
	Variable startTicks, Seconds
	startTicks = ticks
	print "Starting run at : "+time()
	For(j=0;j<=NumStickProbSteps;j+=1)
		StickingProbability = StickingProbabilityStart+j*StickProbStepValu		//set new Sticking probability... 
		sleep/T 1
		//DoUpdate /W=FractalAggregatePanel
		For(i=0;i<MaxNumTests;i+=1)															//iterate over number of growth as needed... 
			failed = IR3A_Grow1MassFractAgreg(0)											//grow the aggregate
			if(!failed)
				NumberOftestedAggregates += 1
				IR3A_CalculateAggValues()
				if(CurrentMisfitValue < MinMisfitFound)						//found better fit than before... 
					MinMisfitFound = CurrentMisfitValue
					IR3A_StoreCurrentMassFractAgreg()
					IR3A_Create3DAggListForListbox()
					//print "Current misfit is : "+num2str(CurrentMisfitValue)
					if(CurrentMisfitValue < MinSearchTargetValue)			//found fit better than what user wants, abort here and save it for user.
						IR3A_Calculate1DIntensity()
						IR3A_Display3DAggregate(1)
						DoUpdate /W=FractalAggregatePanel
						Seconds = ticks - startTicks
						print "End run at : "+time()
						print "   >>>>     SUCCESS!   FOUND RESULT WITH MISFIT LOWER THAN REQUESTED.  <<<<    "
						print "   >>>>     Found Aggregate which matches the requested conditions <<<<    "
						print "Tested "+num2str(NumberOftestedAggregates) +" aggregates, total time run [minutes]: "+num2str(Seconds/60/60)
						StickingProbability = OriginalStickingProbability
						return 1
					endif
				endif
			endif
		endfor
	endfor
	Seconds = ticks - startTicks
	//Print microSeconds/10000, "microseconds per iteration"
	print "End run at : "+time()

	if(NumberOftestedAggregates)
		//last selected one is the best... 
		wave/T Stored3DAggregates= root:Packages:AggregateModeling:Stored3DAggregates
		ListBox StoredAggregates win=FractalAggregatePanel, selRow= numpnts(Stored3DAggregates)-1
		//ControlInfo /W=FractalAggregatePanel StoredAggregates
		IR3A_CalculateAggValues()
		IR3A_Calculate1DIntensity()
		IR3A_Display3DAggregate(1)
		DoUpdate /W=FractalAggregatePanel
		print "   >>>>     FAILURE!      DID NOT FOUND RESULT WITH LOW ENOUGH MISFIT.  <<<<    "
		print "   >>>>     Finished search, the best fit found is "+num2str(CurrentMisfitValue)+" Could not find better fit.  <<<<    "
		print "Tested "+num2str(NumberOftestedAggregates) +" aggregates, total time run [minutes]: "+num2str(Seconds/60/60)
	else		//did not find any...
		print "   >>>>     Finished search, Could not grow any Aggregate, something si wrong.  <<<<    "
	endif
	StickingProbability = OriginalStickingProbability
	return 0
end

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

static Function IR3A_CalculateAggValues()
	
	NVAR Misfit = root:Packages:AggregateModeling:CurrentMisfitValue
	NVAR Target_C=root:Packages:AggregateModeling:BrFract_c
	NVAR Target_dmin = root:Packages:AggregateModeling:BrFract_dmin
	NVAR Model_Dmin=root:Packages:AggregateModeling:dminValue
	NVAR Model_c = root:Packages:AggregateModeling:cValue
	Misfit = sqrt(((Target_C-Model_c)^2/(Target_C)^2 + (Target_dmin-Model_Dmin)^2/(Target_dmin)^2)/2)
	NVAR TotalGrowthsPlanned = root:Packages:AggregateModeling:TotalGrowthsPlanned
	NVAR MaxNumTests = root:Packages:AggregateModeling:MaxNumTests
	NVAR StickProbNumSteps =root:Packages:AggregateModeling:StickProbNumSteps
	TotalGrowthsPlanned = MaxNumTests * StickProbNumSteps
	NVAR dmin = root:Packages:AggregateModeling:BrFract_dmin
	NVAR cval = root:Packages:AggregateModeling:BrFract_c
	NVAR df = root:Packages:AggregateModeling:BrFract_df
	//if(StringMatch(sva.ctrlName, "Target_dmin") || StringMatch(sva.ctrlName, "Target_c"))
	df = dmin * cval
	//endif

end


//******************************************************************************************************************************************************
//******************************************************************************************************************************************************



Function IR3A_PanelButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	variable failed = 0
	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			if(stringmatch(ba.ctrlName,"Grow1AggAll"))
				failed = IR3A_Grow1MassFractAgreg(0)
				if(!failed)
					IR3A_CalculateAggValues()
					IR3A_Calculate1DIntensity()
					IR3A_Display3DAggregate(1)
					IR3A_Create3DAggListForListbox()
				endif
			endif
			if(stringmatch(ba.ctrlName,"GrowNAggAll"))
				NVAR NUmberOfTestAggregates=root:Packages:AggregateModeling:NUmberOfTestAggregates
				variable i
				For(i=0;i<NUmberOfTestAggregates;i+=1)
					failed = IR3A_Grow1MassFractAgreg(0)
					if(!failed)
						IR3A_CalculateAggValues()
						IR3A_Display3DAggregate(1)
						IR3A_Calculate1DIntensity()
						IR3A_StoreCurrentMassFractAgreg()
						IR3A_Create3DAggListForListbox()
						print ">>>      Grown "+num2str(i+1)+" aggregate out of "+num2str(NUmberOfTestAggregates)
					endif
				endfor
				print "   >>>>     Done Growing "+num2str(NUmberOfTestAggregates)+" aggregates <<<<    "
			endif
			if(stringmatch(ba.ctrlName,"GrowOptimizedAgg"))
				IR3A_FindBestFitGrowth()
			endif
			if(stringmatch(ba.ctrlName,"Display3DMassFracGizmo"))
				IR3A_Display3DAggregate(0)
				IR3A_Create3DAggListForListbox()
			endif
			if(stringmatch(ba.ctrlName,"SaveAggregateData"))
				IR3A_StoreCurrentMassFractAgreg()
				IR3A_Create3DAggListForListbox()
			endif
			if(stringmatch(ba.ctrlName,"Display3DMFASummary"))
				Wave/Z MassFractalAggregate = root:Packages:AggregateModeling:MassFractalAggregate
				if(WaveExists(MassFractalAggregate))
					IR3A_DisplayAggNotebook(MassFractalAggregate,0)
				endif
				IR3A_Create3DAggListForListbox()
			endif
			if(stringmatch(ba.ctrlName,"Calculate1DIntensity"))
				IR3A_Calculate1DIntensity()
				IR3A_Create3DAggListForListbox()
			endif
			if(stringmatch(ba.ctrlName,"Model1DIntensity"))
				print "This takes a lot of time as it uses Monte Carlo method to calculate PDF and converts that to intensity. Also, results are noisy as single particle has very poor sampling."
				IR3A_Model1DIntensity()
				IR3A_Create3DAggListForListbox()
			endif
			if(stringmatch(ba.ctrlName,"Display1DData"))
				IR3A_Display1DIntensity()
				IR3A_Create3DAggListForListbox()
			endif
			if(StringMatch(ba.ctrlName, "GetHelp" ))
				//Open www manual with the right page
				IN2G_OpenWebManual("Irena/3DAggregate.html")
			endif
			if(StringMatch(ba.ctrlName, "CompareStoredResults" ))
				IR3A_CompareStoredResults()
			endif
			if(StringMatch(ba.ctrlName, "DeleteStoredResults" ))
				IR3A_DeleteStoredResults()
			endif


			break
		case -1: // control being killed
			break
	endswitch

	return 0
End

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
static Function IR3A_DeleteStoredResults()

	DoAlert /T="Did you thnk about this?" 1, "You will delete all stored Mass Fractal AGgregates, really want to do it?" 

	if(V_FLag==1)
		DFref oldDf= GetDataFolderDFR()

		KillWIndow/Z MassFractalAggregateView
		KillWIndow/Z MassFractalAggDataPlot
		KillWindow/Z AggStoredResultsOverview
			
		KillDataFolder /Z root:MassFractalAggregates:
		IR3A_Create3DAggListForListbox()
		setDataFOlder OldDf
	endif
end

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
	
static Function IR3A_CompareStoredResults()

	DFref oldDf= GetDataFolderDFR()


	DOWindow FractalAggregatePanel
	if(!V_Flag)
		return 0
	endif 
	wave/Z Stored3DAggSelections= root:Packages:AggregateModeling:Stored3DAggSelections
	if(!WaveExists(Stored3DAggSelections))
		abort
	endif
	///wave/T Stored3DAggregates= root:Packages:AggregateModeling:Stored3DAggregates
	//wave/T Stored3DAggregatesPaths= root:Packages:AggregateModeling:Stored3DAggregatesPaths
	variable NumOfFolders
	string CurrentList, tempStr
	if(DataFolderExists("root:MassFractalAggregates"))
		setDataFolder root:MassFractalAggregates
		CurrentList=stringByKey("FOLDERS",DataFolderDir(1),":")+","
		NumOfFolders = ItemsInList(CurrentList,",")+1
	else
		CurrentList=""
		NumOfFolders = 1
	endif
	
	if(NumOfFolders>0)
		redimension/N=(NumOfFolders) Stored3DAggSelections
		Stored3DAggSelections = 0
		setDataFolder root:Packages:AggregateModeling:
		make/O/N=(NumOfFolders-1) IndexStoredResWave, dMinStoredResWave, cValStoredResWave, dfStoredResWave, MisfitValWave
		make/O/N=(NumOfFolders-1) dMinTarget, cValTarget, dfTarget, MisfitTarget
		Wave IndexStoredResWave
		Wave dMinStoredResWave
		Wave cValStoredResWave
		Wave dfStoredResWave
		setDataFolder root:MassFractalAggregates
	else
		return 0
	endif	
		
	variable i
	if(NumOfFolders>1)
		For(i=0;i<NumOfFolders-1;i+=1)
			tempStr = StringFromList(i, CurrentList, ",")
			IndexStoredResWave[i] = i
			cValStoredResWave[i] = IR3A_Return3DAggParamVal("root:MassFractalAggregates:"+tempStr,"cval")
			dMinStoredResWave[i] = IR3A_Return3DAggParamVal("root:MassFractalAggregates:"+tempStr,"dMin")
			dfStoredResWave[i] = IR3A_Return3DAggParamVal("root:MassFractalAggregates:"+tempStr,"df")
			MisfitValWave[i] = IR3A_Return3DAggParamVal("root:MassFractalAggregates:"+tempStr,"Misfit")
		endfor	
	endif
	variable MinVal, MaxVal
	//create plot of the three against the target values... 
	NVAR dminTarg = root:Packages:AggregateModeling:BrFract_dmin
	NVAR cTarg = root:Packages:AggregateModeling:BrFract_c
	NVAR dfTarg = root:Packages:AggregateModeling:BrFract_df
	NVAR MisFitTarg = root:Packages:AggregateModeling:MinSearchTargetValue
	dMinTarget = dminTarg
	cValTarget = cTarg
	dfTarget = dfTarg
	if(MisFitTarg<1e-4)
		MisFitTarg = WaveMin(MisfitValWave)
	endif
	MisfitTarget = MisFitTarg
	KillWIndow/Z AggStoredResultsOverview
	
	Display/W=(695,66,1292,720)/K=1/N=AggStoredResultsOverview dMinStoredResWave vs IndexStoredResWave as "Overview of the Stored 3D Aggregates" 
	AppendToGraph dMinTarget vs IndexStoredResWave
	AppendToGraph/L=cAxis cValStoredResWave,cValTarget vs IndexStoredResWave
	AppendToGraph/L=dfAxis dfStoredResWave,dfTarget vs IndexStoredResWave
	AppendToGraph/L=MisfitAxis MisfitValWave,MisfitTarget vs IndexStoredResWave
	ModifyGraph mode(dMinStoredResWave)=3,mode(cValStoredResWave)=3,mode(dfStoredResWave)=3
	ModifyGraph marker(dMinStoredResWave)=19,marker(cValStoredResWave)=17,marker(dfStoredResWave)=26
	ModifyGraph mode(MisfitValWave)=3,marker(MisfitValWave)=29,rgb(MisfitValWave)=(0,0,0)
	ModifyGraph lStyle(dMinTarget)=3,lStyle(cValTarget)=3,lStyle(dfTarget)=3
	ModifyGraph rgb(cValStoredResWave)=(1,16019,65535),rgb(cValTarget)=(1,16019,65535)
	ModifyGraph rgb(dfStoredResWave)=(3,52428,1),rgb(dfTarget)=(3,52428,1)
	ModifyGraph lblPosMode(cAxis)=3
	ModifyGraph lblPos(left)=64,lblPos(cAxis)=64,lblPos(dfAxis)=64,lblPos(MisfitAxis)=64
	ModifyGraph lblLatPos(left)=-8,lblLatPos(cAxis)=-6,lblLatPos(dfAxis)=-6
	ModifyGraph lblLatPos(MisfitAxis)=-6	
	ModifyGraph freePos(cAxis)=0
	ModifyGraph freePos(dfAxis)=0
	ModifyGraph freePos(MisfitAxis)=0
	ModifyGraph axisEnab(left)={0,0.24}
	ModifyGraph axisEnab(cAxis)={0.26,0.49}
	ModifyGraph axisEnab(dfAxis)={0.51,0.74}
	ModifyGraph axisEnab(MisfitAxis)={0.76,1}
	ModifyGraph mirror=1
	ModifyGraph tick(bottom)=2
	ModifyGraph tick(left)=1
	ModifyGraph tick(cAxis)=1
	ModifyGraph tick(dfAxis)=1
	ModifyGraph lowTrip(MisfitAxis)=0.001
	
	Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"d\\Bmin"
	Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Stored model index"
	Label cAxis "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"c value"
	Label dfAxis "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"df"
	Label MisfitAxis "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Misfit"
	wavestats/Q dMinStoredResWave
	MinVal=min(V_min,dminTarg)*0.95
	MaxVal=max(V_max,dminTarg)*1.05
	if(numtype(dminTarg)==0)
		SetAxis left MinVal,MaxVal
	else
		SetAxis/A left 
	endif
	
	//
	wavestats/Q cValStoredResWave
	MinVal=min(V_min,cTarg)*0.95
	MaxVal=max(V_max,cTarg)*1.05
	if(numtype(cTarg)==0)
		SetAxis cAxis MinVal,MaxVal
	else
		SetAxis/A cAxis 
	endif
	//
	wavestats/Q dfStoredResWave
	MinVal=min(V_min,dfTarg)*0.95
	MaxVal=max(V_max,dfTarg)*1.05
	if(numtype(dfTarg)==0)
		SetAxis dfAxis MinVal,MaxVal
	else
		SetAxis/A dfAxis 
	endif

	DrawLine 0,0.67,1,0.67
	DrawLine 0,0.34,1,0.34
	string LegendText="\\F"+IN2G_LkUpDfltStr("FontType")+"\\Z"+IN2G_LkUpDfltVar("LegendSize")+"\\s(dMinStoredResWave) d\\Bmin\r\\s(dMinTarget) d\\Bmin\\M  target\r\\s(cValStoredResWave) c\r\\s(cValTarget) c target\r\\s(dfStoredResWave) d\\Bf\r\\s(dfTarget) d\\Bf\\M target"
	LegendText+=" \r\s(MisfitValWave) Misfit Values \r\\s(MisfitTarget) MisfitTarget"
	Legend/C/N=LegendText/J/A=LT LegendText
	setDataFOlder OldDf
end	
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

static Function IR3A_Return3DAggParamVal(PathToFolder, ParName)
	string PathToFOlder, ParName
	DFref oldDf= GetDataFolderDFR()

	SetDataFolder PathToFolder
	variable RetValue
	if(StringMatch(ParName, "cval" ))
		NVAR cval= cValue
		RetValue = cval
	elseif(StringMatch(ParName, "dmin"))
		NVAR dMin=DminValue
		RetValue = dMin
	elseif(StringMatch(ParName, "df"))
		NVAR df = dfValue
		RetValue = df
	elseif(StringMatch(ParName, "Misfit"))
		NVAR Misfit = Misfit
		RetValue = Misfit
	else
		RetValue = 0
	endif
	setDataFOlder OldDf
	return RetValue
end

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************


static Function IR3A_StoreCurrentMassFractAgreg()
	DFref oldDf= GetDataFolderDFR()

	SetDataFolder root:Packages:AggregateModeling
	NVAR OldDegreeOfAggregation=root:Packages:AggregateModeling:DegreeOfAggregation
	NVAR OldStickingProbability=root:Packages:AggregateModeling:StickingProbability
	NVAR OldRValue=root:Packages:AggregateModeling:RValue
	NVAR OldpValue=root:Packages:AggregateModeling:pValue
	NVAR OlddfValue=root:Packages:AggregateModeling:dfValue
	NVAR OlddminValue=root:Packages:AggregateModeling:dminValue
	NVAR OldcValue=root:Packages:AggregateModeling:cValue
	NVAR OldsValue=root:Packages:AggregateModeling:sValue
	NVAR OldAttemptValue=root:Packages:AggregateModeling:AttemptValue
	NVAR AllowedNearDistance=root:Packages:AggregateModeling:AllowedNearDistance
	NVAR OldMisfit = root:Packages:AggregateModeling:CurrentMisfitValue
	Wave/Z MSF=root:Packages:AggregateModeling:MassFractalAggregate
	if(WaveExists(MSF))
		string NewFolderName
		NewFolderName = "MFA_DOA_"+num2str(trunc(OldDegreeOfAggregation))+"_Stick_"+num2str(trunc(OldStickingProbability))+"_StickMeth_"+num2str(trunc(AllowedNearDistance))+"_"
		NewDataFolder/O/S root:MassFractalAggregates
		NewFolderName = UniqueName(NewFolderName, 11, 0 )
		NewDataFolder/O/S $(NewFolderName)
		Duplicate/O MSF, MassFractalAggregate
		variable/g DegreeOfAggregation = OldDegreeOfAggregation
		variable/g StickingProbability = OldStickingProbability
		variable/g RValue = OldRValue
		variable/g pValue = OldpValue
		variable/g dfValue = OlddfValue
		variable/g dminValue = OlddminValue
		variable/g cValue = OldcValue
		variable/g sValue = OldsValue
		variable/g AttemptValue = OldAttemptValue		
		variable/g StickingMethod = AllowedNearDistance
		variable/g Misfit = oldMisfit
	endif
	setDataFOlder OldDf


end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//			POV/PDB import/export/modeling code 
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

Function IR3P_POVPDBPanel()
	PauseUpdate    		// building window...
	NewPanel /K=1 /W=(5,20,395,680) as "POV/PDB Panel"
	DoWindow/C POVPDBPanel
	TitleBox MainTitle title="\Zr200POV/PDB panel",pos={20,0},frame=0,fstyle=3, fixedSize=1,font= "Times New Roman", size={350,24},anchor=MC,fColor=(0,0,52224)
	Button GetHelp,pos={305,45},size={80,15},fColor=(65535,32768,32768), proc=IR3P_POVPDBButtonProc,title="Get Help", help={"Open www manual page for this tool"}	//<<< fix button to help!!!
	//COPY FROM IR2U_UnifiedEvaPanelFnct()
	Checkbox  UseForPOV, pos={50,40}, size={50,15}, variable =root:packages:POVPDBImport:UseForPOV
	Checkbox  UseForPOV, title="Use for POV",mode=1,proc=IR3P_POVPDBCheckProc
	Checkbox  UseForPOV, help={"Select of you want to import POV files from SAXSMorph"}
	Checkbox  UseForPDB, pos={200,40}, size={50,15}, variable =root:packages:POVPDBImport:UseForPDB
	Checkbox  UseForPDB, title="Use for PDB",mode=1,proc=IR3P_POVPDBCheckProc
	Checkbox  UseForPDB, help={"Select of you want to import PDB files from SAXSMorph"}

	TitleBox Info1 title="\Zr120Select where to put the data",pos={60,65},frame=0,fstyle=1, fixedSize=1,size={300,20},fColor=(0,0,52224)
	SetVariable NewFolderName,value= root:Packages:POVPDBImport:NewFolderName
	SetVariable NewFolderName,pos={15,90},size={200,20},title="root:",noproc, help={"Type in new folder name"}
	Button CreateFolder,pos={250,87},size={100,20},proc=IR3P_POVPDBButtonProc,title="Create Folder", help={"Create Folder for data"}

	SetVariable CurrentFolderName,value= root:Packages:POVPDBImport:CurrentFolderName
	SetVariable CurrentFolderName,pos={15,120},size={280,20},title="Current Folder Name",noproc, help={"Current FOlder name to use"}

	TitleBox FakeLine1 title=" ",fixedSize=1,size={330,3},pos={16,145},frame=0,fColor=(0,0,52224), labelBack=(0,0,52224)
	TitleBox Info2 title="\Zr120Import data",pos={60,160},frame=0,fstyle=1, fixedSize=1,size={300,20},fColor=(0,0,52224)


	SetVariable voxelSize,value= root:packages:POVPDBImport:voxelSize, frame=1
	SetVariable voxelSize,pos={15,190},noproc, help={"WHat is voxel Size of the imported 3D structure? "}
	SetVariable voxelSize title="Voxel Size [A]                ",size={200,17},limits={1,100,1}


	Button Import3DData,pos={30,220},size={150,20},proc=IR3P_POVPDBButtonProc,title="Import 3D Data", help={"Import 3D data in this folder"}
	Button Display3DData,pos={30,250},size={150,20},proc=IR3P_POVPDBButtonProc,title="Display 3D Data", help={"Display 3D data in this folder"}
	Button ImportIntQData,pos={30,300},size={150,20},proc=IR3P_POVPDBButtonProc,title="Import Int/Q Data", help={"Import 1D data in this folder"}
	Button DisplayIntQData,pos={30,330},size={150,20},proc=IR3P_POVPDBButtonProc,title="Display Int/Q Data", help={"Display 1D data in this folder"}
	Button CalculateIntQData,pos={30,360},size={150,20},proc=IR3P_POVPDBButtonProc,title="Calculate Int/Q Data", help={"Calculate 1D data and append"}

end

//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//*****************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3P_POVPDBCheckProc(cba) : CheckBoxControl
	STRUCT WMCheckboxAction &cba

	switch( cba.eventCode )
		case 2: // mouse up
			Variable checked = cba.checked
			NVAR UseForPOV=root:packages:POVPDBImport:UseForPOV
			NVAR UseForPDB=root:packages:POVPDBImport:UseForPDB
			if(stringMatch(cba.ctrlName,"UseForPOV"))
				UseForPDB=!UseForPOV
			endif
			if(stringMatch(cba.ctrlName,"UseForPDB"))
				UseForPOV=!UseForPDB
			endif
			break
	endswitch

	return 0
End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3P_POVPDBButtonProc(ba) : ButtonControl
	STRUCT WMButtonAction &ba

	switch( ba.eventCode )
		case 2: // mouse up
			// click code here
			DFref oldDf= GetDataFolderDFR()

			setDataFolder root:Packages:POVPDBImport	
			if(StringMatch(ba.ctrlName, "CreateFolder" ))
					IR3P_CreateFolder()	
			endif
			if(StringMatch(ba.ctrlName, "GetHelp" ))
					print "Fix IR3P_POVPDBButtonProc to do what it is suppose to do..."
			endif
			if(StringMatch(ba.ctrlName, "Import3DData" ))
					IR3P_Read3DDataFile()
			endif
			if(StringMatch(ba.ctrlName, "Display3DData" ))
					IR3P_POV3DDataGizmo() 
			endif
			if(StringMatch(ba.ctrlName, "ImportIntQData" ))
					IR3P_Read1DDataFile()
			endif
			if(StringMatch(ba.ctrlName, "DisplayIntQData" ))
					IR3P_DIsplay1DDataFile()
			endif
			if(StringMatch(ba.ctrlName, "CalculateIntQData" ))
					IR3P_Calculate1DDataFile()
			endif
			
			setDataFolder oldDF		
			break
		case -1: // control being killed
			break
	endswitch

	return 0
End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3P_InitializePOVPDB()

 	DFref oldDf= GetDataFolderDFR()

	NewDataFolder/O/S root:Packages
	NewDataFolder/O/S root:Packages:POVPDBImport
	string/g ListOfVariables
	string/g ListOfStrings
	//here define the lists of variables and strings needed, separate names by ;...
	ListOfVariables="UseForPOV;UseForPDB;VoxelSize;"
	ListOfStrings="NewFolderName;CurrentFolderName;"
	variable i
	//and here we create them
	for(i=0;i<itemsInList(ListOfVariables);i+=1)	
		IN2G_CreateItem("variable",StringFromList(i,ListOfVariables))
	endfor												
	for(i=0;i<itemsInList(ListOfStrings);i+=1)	
		IN2G_CreateItem("string",StringFromList(i,ListOfStrings))
	endfor	
		
	NVAR VoxelSize
	if(VoxelSize<1)
		VoxelSize = 1		//default to 1A
	endif
	setDataFOlder OldDf
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
////******************************************************************************************************************************************************
//
//Window POV3DData() : GizmoPlot
//	PauseUpdate    		// building window...
//	// Building Gizmo 8 window...
//	NewGizmo/T="POV Imported 3D data"/W=(919,45,1434,505)
//	ModifyGizmo startRecMacro=700
//	ModifyGizmo scalingOption=63
//	AppendToGizmo isoSurface=root:test:centersWave,name=isoSurface0
//	ModifyGizmo ModifyObject=isoSurface0,objectType=isoSurface,property={ surfaceColorType,1}
//	ModifyGizmo ModifyObject=isoSurface0,objectType=isoSurface,property={ lineColorType,0}
//	ModifyGizmo ModifyObject=isoSurface0,objectType=isoSurface,property={ lineWidthType,0}
//	ModifyGizmo ModifyObject=isoSurface0,objectType=isoSurface,property={ fillMode,2}
//	ModifyGizmo ModifyObject=isoSurface0,objectType=isoSurface,property={ lineWidth,1}
//	ModifyGizmo ModifyObject=isoSurface0,objectType=isoSurface,property={ isoValue,0.5}
//	ModifyGizmo ModifyObject=isoSurface0,objectType=isoSurface,property={ frontColor,1,0,0,1}
//	ModifyGizmo ModifyObject=isoSurface0,objectType=isoSurface,property={ backColor,0,0,1,1}
//	ModifyGizmo modifyObject=isoSurface0,objectType=Surface,property={calcNormals,1}
//	AppendToGizmo light=Directional,name=light0
//	ModifyGizmo modifyObject=light0,objectType=light,property={ position,-0.241800,-0.664500,0.707100,0.000000}
//	ModifyGizmo modifyObject=light0,objectType=light,property={ direction,-0.241800,-0.664500,0.707100}
//	ModifyGizmo modifyObject=light0,objectType=light,property={ ambient,0.133000,0.133000,0.133000,1.000000}
//	ModifyGizmo modifyObject=light0,objectType=light,property={ specular,1.000000,1.000000,1.000000,1.000000}
//	AppendToGizmo Axes=boxAxes,name=axes0
//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={-1,axisScalingMode,1}
//	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={-1,axisColor,0,0,0,1}
//	ModifyGizmo modifyObject=axes0,objectType=Axes,property={-1,Clipped,0}
//	AppendToGizmo attribute specular={1,1,0,1,1032},name=specular0
//	AppendToGizmo attribute shininess={5,20},name=shininess0
//	ModifyGizmo setDisplayList=0, object=light0
//	ModifyGizmo setDisplayList=1, attribute=shininess0
//	ModifyGizmo setDisplayList=2, attribute=specular0
//	ModifyGizmo setDisplayList=3, object=isoSurface0
//	ModifyGizmo setDisplayList=4, opName=clearColor, operation=clearColor, data={0.8,0.8,0.8,1}
//	ModifyGizmo setDisplayList=5, object=axes0
//	ModifyGizmo autoscaling=1
//	ModifyGizmo currentGroupObject=""
//	ModifyGizmo showInfo
//	ModifyGizmo infoWindow={1436,23,2253,322}
//	ModifyGizmo endRecMacro
//	ModifyGizmo SETQUATERNION={-0.134543,0.320522,-0.081181,0.934117}
//EndMacro
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************




//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3P_CreateFolder()	
	SVAR NewFolderName=root:packages:POVPDBImport:NewFolderName
	SVAR CurrentFolderName=root:packages:POVPDBImport:CurrentFolderName
	if(Strlen(NewFolderName)>2)
		setDataFOlder root:
		NewDataFOlder/O/S $(PossiblyQuoteName(NewFolderName))
		CurrentFolderName = GetDataFolder(1)
	else
		Abort "No Folder name exists, type in name first" 
	endif
end
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
Function IR3P_Read1DDataFile()

	SVAR CurrentFolderName=root:packages:POVPDBImport:CurrentFolderName
	SetDataFOlder $(CurrentFolderName)
	IR1I_KillAutoWaves()
	KillWaves/Z Qwave, IntWave
	LoadWave/Q/A/D/G/D
	Wave Wave0
	Wave Wave1
	Rename Wave0, Qwave
	Rename Wave1, IntWave
end
///*************************************************************************************************************************************
///*************************************************************************************************************************************
Function IR3P_DIsplay1DDataFile()
	DOWIndow/K/Z POV1DGraph
	SVAR CurrentFolderName=root:packages:POVPDBImport:CurrentFolderName
	SetDataFOlder $(CurrentFolderName)
	Wave IntWave
	Wave QWave
	Display/K=1/W=(100,50,600,550) IntWave vs QWave as "POV 1D Data display"
	DoWindow/C POV1DGraph
	Label left "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Intensity"
	Label bottom "\\Z"+IN2G_LkUpDfltVar("AxisLabelSize")+"Qvector"
	ModifyGraph log=1
end

///*************************************************************************************************************************************
///*************************************************************************************************************************************
Function IR3P_Calculate1DDataFile()
	SVAR CurrentFolderName=root:packages:POVPDBImport:CurrentFolderName
	SetDataFOlder $(CurrentFolderName)
	Wave ThreeDVoxelGram = POVVoxelWave
	NVAR voxelSize = root:packages:POVPDBImport:voxelSize
	print "Warning = IR3P_Calculate1DDataFile needs to get VoxelSize fixed, it is fixed at 2A"
	//variable NumRSteps=300
	variable IsoValue = 0.5
	variable Qmin = 0.001 
	variable Qmax = 0.6
	variable NumQSteps = 200
	setScale/P x, 0, VoxelSize, ThreeDVoxelGram
	setScale/P y, 0, VoxelSize, ThreeDVoxelGram
	setScale/P z, 0, VoxelSize, ThreeDVoxelGram
	IR3T_CreatePDFIntensity(ThreeDVoxelGram, IsoValue, Qmin, Qmax, NumQSteps)
	Wave PDFQWv
	Wave PDFIntensityWv
	Wave Qwave
	Wave IntWave
	//and this does not work for odd number of rows/columns/... 
	//IR3T_CalcAutoCorelIntensity(ThreeDVoxelGram, IsoValue, Qmin, Qmax, NumQSteps)
	//these are autocorrelation calculated intensities... 
	//Wave AutoCorIntensityWv
	//Wave AutoCorQWv
	variable InvarModel=areaXY(PDFQWv, PDFIntensityWv )
	variable InvarData=areaXY(Qwave, IntWave )
	PDFIntensityWv*=InvarData/InvarModel
	//InvarModel=areaXY(AutoCorQWv, AutoCorIntensityWv )
	//AutoCorIntensityWv*=InvarData/InvarModel
	
	DOWIndow POV1DGraph
	if(V_Flag)
		DoWIndow/F POV1DGraph
		CheckDisplayed /W=POV1DGraph PDFIntensityWv
		if(V_flag==0)
			AppendToGraph/W=POV1DGraph  PDFIntensityWv vs PDFQWv
		endif
		//CheckDisplayed /W=POV1DGraph AutoCorIntensityWv
		//if(V_flag==0)
		//	AppendToGraph/W=POV1DGraph  AutoCorIntensityWv vs AutoCorQWv
		//endif
		ModifyGraph lstyle(PDFIntensityWv)=9,lsize(PDFIntensityWv)=3,rgb(PDFIntensityWv)=(1,16019,65535)
		ModifyGraph mode(PDFIntensityWv)=4,marker(PDFIntensityWv)=19
		ModifyGraph msize(PDFIntensityWv)=3
		//ModifyGraph lsize(AutoCorIntensityWv)=3,rgb(AutoCorIntensityWv)=(3,52428,1)
		Legend/C/N=text0/A=MC
	endif
end
///*************************************************************************************************************************************
///*************************************************************************************************************************************
Function IR3P_Read3DDataFile()
	//variable dimx,dimy,dimz
	
	NVAR UseForPOV = root:Packages:POVPDBImport:UseForPOV
	NVAR UseForPDB = root:Packages:POVPDBImport:UseForPDB
	if(UseForPOV+UseForPDB !=1)
		UseForPDB=0
		UseForPOV=1
	endif
	if(UseForPOV)
		SVAR CurrentFolderName=root:packages:POVPDBImport:CurrentFolderName
		//SetDataFOlder $(CurrentFolderName)
		Variable refNum,err=0
		variable FInalSize
		OPEN/R/F=".POV"/M="Find POV file" refNum
		if(strlen(S_fileName)>0)
			Make/U/B/Free/n=((500),(500),(500)) centersWave
			centersWave=0
			String lineStr
			Variable count=0
			do
				FreadLine refNum,lineStr
				if(strlen(lineStr)<=0)
					break
				endif
				if(strsearch(lineStr,"sphere",0)>=0)
					IR3P_POVprocessAtomLine(lineStr,count,centersWave)
					count+=1
				endif
			while(err==0)
			Close refNum
			FinalSize = count^(1/3)
			//print FinalSize
			Redimension/N=(FInalSize,FInalSize,FInalSize) centersWave
			Duplicate/O centersWave, $(CurrentFolderName+"POVVoxelWave")
		endif
	elseif(UseForPDB)
		print "Finish PDB in IR3P_Read3DDataFile"
	endif
end
///*************************************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************
Function IR3P_POVprocessAtomLine(lineStr,count, destWv)
	String lineStr
	Variable count
	Wave destWv
	
	Variable n1,n2,n3,n4,n5,xx,yy,zz
	String s1,s2,s3,s4,s5
	//sphere{<50,48,33>, 1.5, 1 } 
	lineStr = ReplaceString("{<", lineStr, ",")
	lineStr = ReplaceString(">,", lineStr, ",")
	lineStr = ReplaceString("} \r", lineStr, ",")
	lineStr = ReplaceString(" ", lineStr, "")
	sscanf lineStr,"sphere,%i,%i,%i,%f,%f,",n1,n2,n3,n4,n5
	variable FillVal = 0
	if(n5>0)
		FillVal = 1
	endif
	destWv[(n1-1)][(n2-1)][(n3-1)]= FillVal
End
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************
//******************************************************************************************************************************************************

Function IR3P_POV3DDataGizmo() : GizmoPlot
	DoWIndow/K/Z POV3DData
	PauseUpdate    		// building window...
	SVAR CurrentFolderName=root:packages:POVPDBImport:CurrentFolderName
	Wave Imported3DPOVWave = $(CurrentFolderName+"POVVoxelWave")
	// Building Gizmo 8 window...
	NewGizmo/T="POV Imported 3D data"/W=(919,45,1434,505)
	DoWindow/C POV3DData
	ModifyGizmo startRecMacro=700
	ModifyGizmo scalingOption=63
	AppendToGizmo isoSurface=Imported3DPOVWave,name=ImportedPOV
	ModifyGizmo ModifyObject=ImportedPOV,objectType=isoSurface,property={ surfaceColorType,1}
	ModifyGizmo ModifyObject=ImportedPOV,objectType=isoSurface,property={ lineColorType,0}
	ModifyGizmo ModifyObject=ImportedPOV,objectType=isoSurface,property={ lineWidthType,0}
	ModifyGizmo ModifyObject=ImportedPOV,objectType=isoSurface,property={ fillMode,2}
	ModifyGizmo ModifyObject=ImportedPOV,objectType=isoSurface,property={ lineWidth,1}
	ModifyGizmo ModifyObject=ImportedPOV,objectType=isoSurface,property={ isoValue,0.5}
	ModifyGizmo ModifyObject=ImportedPOV,objectType=isoSurface,property={ frontColor,1,0,0,1}
	ModifyGizmo ModifyObject=ImportedPOV,objectType=isoSurface,property={ backColor,0,0,1,1}
	ModifyGizmo modifyObject=ImportedPOV,objectType=Surface,property={calcNormals,1}
	AppendToGizmo light=Directional,name=light0
	ModifyGizmo modifyObject=light0,objectType=light,property={ position,-0.241800,-0.664500,0.707100,0.000000}
	ModifyGizmo modifyObject=light0,objectType=light,property={ direction,-0.241800,-0.664500,0.707100}
	ModifyGizmo modifyObject=light0,objectType=light,property={ ambient,0.133000,0.133000,0.133000,1.000000}
	ModifyGizmo modifyObject=light0,objectType=light,property={ specular,1.000000,1.000000,1.000000,1.000000}
	AppendToGizmo Axes=boxAxes,name=axes0
	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={-1,axisScalingMode,1}
	ModifyGizmo ModifyObject=axes0,objectType=Axes,property={-1,axisColor,0,0,0,1}
	ModifyGizmo modifyObject=axes0,objectType=Axes,property={-1,Clipped,0}
	AppendToGizmo attribute specular={1,1,0,1,1032},name=specular0
	AppendToGizmo attribute shininess={5,20},name=shininess0
	ModifyGizmo setDisplayList=0, object=light0
	ModifyGizmo setDisplayList=1, attribute=shininess0
	ModifyGizmo setDisplayList=2, attribute=specular0
	ModifyGizmo setDisplayList=3, object=ImportedPOV
	ModifyGizmo setDisplayList=4, opName=clearColor, operation=clearColor, data={0.8,0.8,0.8,1}
	ModifyGizmo setDisplayList=5, object=axes0
	ModifyGizmo autoscaling=1
	ModifyGizmo currentGroupObject=""
	ModifyGizmo showInfo
	ModifyGizmo infoWindow={1436,23,2253,322}
	ModifyGizmo endRecMacro
	ModifyGizmo SETQUATERNION={-0.134543,0.320522,-0.081181,0.934117}
EndMacro
///*************************************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************
//
//Function IR3P_Convert3DMatrixToList(My3DVoxelWave, threshVal)
//	wave My3DVoxelWave
//	variable threshVal
//	
//	variable maxlen=DimSize(My3DVoxelWave, 0 )*DimSize(My3DVoxelWave,1)*DimSize(My3DVoxelWave, 2)
//	
//	Make/O/N=(maxlen,3) MyScatterWave
//	MyScatterWave = NaN
//	variable i, j, k, indx=0
//	For(i=0;i<DimSize(My3DVoxelWave, 0 );i+=1)
//		For(j=0;j<DimSize(My3DVoxelWave, 1 );j+=1)
//			For(k=0;k<DimSize(My3DVoxelWave, 2 );k+=1)
//				if(My3DVoxelWave[i][j][k]<threshVal)
//					MyScatterWave[indx][0]=i
//					MyScatterWave[indx][1]=j
//					MyScatterWave[indx][2]=k
//					indx+=1
//				endif
//			endfor
//		endfor
//	endfor
//	DeletePoints/M=0 indx, (maxlen-indx),  MyScatterWave
//	
//end
///*************************************************************************************************************************************
///*************************************************************************************************************************************
///*************************************************************************************************************************************
 
