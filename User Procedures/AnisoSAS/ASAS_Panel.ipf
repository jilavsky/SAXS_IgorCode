#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.1		//modified 5 29 2005 to accept 5 populations JIL


//These are panel functions for ASAS


Window ASAS_ControlPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(321.75,128.75,726.75,560) as "ASAS_ControlPanel"
	SetDrawLayer UserBack
	SetDrawEnv fsize= 16,fstyle= 1,textrgb= (0,0,65280)
	DrawText 13,25,"Control panel to modify parameters of Aniso SAS"
	DrawText 14,52,"Formula 4 selection:"
	CheckBox ASAS_CntrlFormula4a,pos={21,66},size={181,14},proc=ASAS_CheckProc,title="Formula 4a, integration & refraction. No size distribution."
	CheckBox ASAS_CntrlFormula4a,help={"Integration is slow, but accounts for diffraction and refraction and works for any aspect ratios"}
	CheckBox ASAS_CntrlFormula4a,value= 0
	CheckBox ASAS_CntrlFormula4b,pos={21,86},size={192,14},proc=ASAS_CheckProc,title="Formula 4b, infinite series & refraction. No size distribution."
	CheckBox ASAS_CntrlFormula4b,help={"Infinite series, faster than 4a for small nu, diffraction and refraction, but works well only for aspect ratios < 1 "}
	CheckBox ASAS_CntrlFormula4b,value= 0
	CheckBox ASAS_CntrlFormula4c,pos={21,106},size={142,14},proc=ASAS_CheckProc,title="Formula 4c, diffraction limit. Uses size distribution."
	CheckBox ASAS_CntrlFormula4c,help={"Fastest, but diffraction limit only"}
	CheckBox ASAS_CntrlFormula4c,value= 1
	SetVariable ASAS_CntrlAlphaSteps,pos={15,132},size={200,16},title="Integration steps in Alpha", help={"Number of steps in integration for alpha angle (0 to 90 degrees), less steps, lessprecision but significantly faster"}
	SetVariable ASAS_CntrlAlphaSteps,limits={10,600,5},value= root:Packages:AnisoSAS:IntegrationStepsInAlpha
	SetVariable ASAS_CntrlOmegaSteps,pos={15,152},size={200,16},title="Integration steps in Omega", help={"Number of steps in integration for omega angle (0 to 360 degrees), less steps, lessprecision but significantly faster"}
	SetVariable ASAS_CntrlOmegaSteps,limits={10,600,5},value= root:Packages:AnisoSAS:IntegrationStepsInOmega

	CheckBox ASAS_Pop1_UseTrianFnct,pos={10,180},size={142,14},proc=ASAS_CheckProc,title="Pop1 use Old triangular size dist."
	CheckBox ASAS_Pop1_UseTrianFnct,help={"Use old triangular size distribution"}, mode=1
	CheckBox ASAS_Pop1_UseTrianFnct,variable = root:Packages:AnisoSAS:Pop1_UseTriangularDist
	CheckBox ASAS_Pop1_UseGaussFnct,pos={10,195},size={142,14},proc=ASAS_CheckProc,title="Pop1 use Gauss size dist."
	CheckBox ASAS_Pop1_UseGaussFnct,help={"Use Gauss size distribution"}, mode=1
	CheckBox ASAS_Pop1_UseGaussFnct,variable = root:Packages:AnisoSAS:Pop1_UseGaussSizeDist
	SetVariable ASAS_Pop1_FWHM,pos={10,215},size={170,16},title="Pop 1 FWHM", help={"Population 1 Fractional Full width at half max for radius distribution. Triangular function"}
	SetVariable ASAS_Pop1_FWHM,limits={0,1,0.05},variable= root:Packages:AnisoSAS:Pop1_FWHM
	SetVariable ASAS_Pop1_GFWHM,pos={10,215},size={170,16},title="Pop 1 FWHM", help={"Population 1 Fractional Full width at half max for radius distribution. Gauss dist"}
	SetVariable ASAS_Pop1_GFWHM,limits={0,0.69,0.05},variable= root:Packages:AnisoSAS:Pop1_GaussSDFWHM
	SetVariable ASAS_Pop1_NumPnts,pos={10,235},size={170,16},title="Pop 1 Num Pnts", help={"Population 1 Number of points, Gauss function"}
	SetVariable ASAS_Pop1_NumPnts,limits={0,51,2},variable= root:Packages:AnisoSAS:Pop1_GaussSDNumBins


	CheckBox ASAS_Pop2_UseTrianFnct,pos={10,260},size={142,14},proc=ASAS_CheckProc,title="Pop2 use Old triangular size dist."
	CheckBox ASAS_Pop2_UseTrianFnct,help={"Use old triangular size distribution"}, mode=1
	CheckBox ASAS_Pop2_UseTrianFnct,variable = root:Packages:AnisoSAS:Pop2_UseTriangularDist
	CheckBox ASAS_Pop2_UseGaussFnct,pos={10,275},size={142,14},proc=ASAS_CheckProc,title="Pop2 use Gauss size dist."
	CheckBox ASAS_Pop2_UseGaussFnct,help={"Use Gauss size distribution"}, mode=1
	CheckBox ASAS_Pop2_UseGaussFnct,variable = root:Packages:AnisoSAS:Pop2_UseGaussSizeDist
	SetVariable ASAS_Pop2_FWHM,pos={10,295},size={170,16},title="Pop 2 FWHM", help={"Population 2 Fractional Full width at half max for radius distribution. Triangular function"}
	SetVariable ASAS_Pop2_FWHM,limits={0,1,0.05},variable= root:Packages:AnisoSAS:Pop2_FWHM
	SetVariable ASAS_Pop2_GFWHM,pos={10,295},size={170,16},title="Pop 2 FWHM", help={"Population 2 Fractional Full width at half max for radius distribution. Gauss dist"}
	SetVariable ASAS_Pop2_GFWHM,limits={0,0.69,0.05},variable= root:Packages:AnisoSAS:Pop2_GaussSDFWHM
	SetVariable ASAS_Pop2_NumPnts,pos={10,315},size={170,16},title="Pop 2 Num Pnts", help={"Population 2 Number of points, Gauss function"}
	SetVariable ASAS_Pop2_NumPnts,limits={0,51,2},variable= root:Packages:AnisoSAS:Pop2_GaussSDNumBins

	CheckBox ASAS_Pop3_UseTrianFnct,pos={200,180},size={142,14},proc=ASAS_CheckProc,title="Pop3 use Old triangular size dist."
	CheckBox ASAS_Pop3_UseTrianFnct,help={"Use old triangular size distribution"}, mode=1
	CheckBox ASAS_Pop3_UseTrianFnct,variable = root:Packages:AnisoSAS:Pop3_UseTriangularDist
	CheckBox ASAS_Pop3_UseGaussFnct,pos={200,195},size={142,14},proc=ASAS_CheckProc,title="Pop3 use Gauss size dist."
	CheckBox ASAS_Pop3_UseGaussFnct,help={"Use Gauss size distribution"}, mode=1
	CheckBox ASAS_Pop3_UseGaussFnct,variable = root:Packages:AnisoSAS:Pop3_UseGaussSizeDist
	SetVariable ASAS_Pop3_FWHM,pos={200,215},size={170,16},title="Pop 3 FWHM", help={"Population 3 Fractional Full width at half max for radius distribution. Triangular function"}
	SetVariable ASAS_Pop3_FWHM,limits={0,1,0.05},variable= root:Packages:AnisoSAS:Pop3_FWHM
	SetVariable ASAS_Pop3_GFWHM,pos={200,215},size={170,16},title="Pop 3 FWHM", help={"Population 3 Fractional Full width at half max for radius distribution. Gauss dist"}
	SetVariable ASAS_Pop3_GFWHM,limits={0,0.69,0.05},variable= root:Packages:AnisoSAS:Pop3_GaussSDFWHM
	SetVariable ASAS_Pop3_NumPnts,pos={200,235},size={170,16},title="Pop 3 Num Pnts", help={"Population 3 Number of points, Gauss function"}
	SetVariable ASAS_Pop3_NumPnts,limits={0,51,2},variable= root:Packages:AnisoSAS:Pop3_GaussSDNumBins


	CheckBox ASAS_Pop4_UseTrianFnct,pos={200,260},size={142,14},proc=ASAS_CheckProc,title="Pop4 use Old triangular size dist."
	CheckBox ASAS_Pop4_UseTrianFnct,help={"Use old triangular size distribution"}, mode=1
	CheckBox ASAS_Pop4_UseTrianFnct,variable = root:Packages:AnisoSAS:Pop4_UseTriangularDist
	CheckBox ASAS_Pop4_UseGaussFnct,pos={200,275},size={142,14},proc=ASAS_CheckProc,title="Pop4 use Gauss size dist."
	CheckBox ASAS_Pop4_UseGaussFnct,help={"Use Gauss size distribution"}, mode=1
	CheckBox ASAS_Pop4_UseGaussFnct,variable = root:Packages:AnisoSAS:Pop4_UseGaussSizeDist
	SetVariable ASAS_Pop4_FWHM,pos={200,295},size={170,16},title="Pop 4 FWHM", help={"Population 4 Fractional Full width at half max for radius distribution. Triangular function"}
	SetVariable ASAS_Pop4_FWHM,limits={0,1,0.05},variable= root:Packages:AnisoSAS:Pop4_FWHM
	SetVariable ASAS_Pop4_GFWHM,pos={200,295},size={170,16},title="Pop 4 FWHM", help={"Population 4 Fractional Full width at half max for radius distribution. Gauss dist"}
	SetVariable ASAS_Pop4_GFWHM,limits={0,0.69,0.05},variable= root:Packages:AnisoSAS:Pop4_GaussSDFWHM
	SetVariable ASAS_Pop4_NumPnts,pos={200,315},size={170,16},title="Pop 4 Num Pnts", help={"Population 4 Number of points, Gauss function"}
	SetVariable ASAS_Pop4_NumPnts,limits={0,51,2},variable= root:Packages:AnisoSAS:Pop4_GaussSDNumBins

	CheckBox ASAS_Pop5_UseTrianFnct,pos={10,340},size={142,14},proc=ASAS_CheckProc,title="Pop5 use Old triangular size dist."
	CheckBox ASAS_Pop5_UseTrianFnct,help={"Use old triangular size distribution"}, mode=1
	CheckBox ASAS_Pop5_UseTrianFnct,variable = root:Packages:AnisoSAS:Pop5_UseTriangularDist
	CheckBox ASAS_Pop5_UseGaussFnct,pos={10,355},size={142,14},proc=ASAS_CheckProc,title="Pop5 use Gauss size dist."
	CheckBox ASAS_Pop5_UseGaussFnct,help={"Use Gauss size distribution"}, mode=1
	CheckBox ASAS_Pop5_UseGaussFnct,variable = root:Packages:AnisoSAS:Pop5_UseGaussSizeDist
	SetVariable ASAS_Pop5_FWHM,pos={10,370},size={170,16},title="Pop 5 FWHM", help={"Population 5 Fractional Full width at half max for radius distribution. Triangular function"}
	SetVariable ASAS_Pop5_FWHM,limits={0,1,0.05},variable= root:Packages:AnisoSAS:Pop5_FWHM
	SetVariable ASAS_Pop5_GFWHM,pos={10,370},size={170,16},title="Pop 5 FWHM", help={"Population 5 Fractional Full width at half max for radius distribution. Gauss dist"}
	SetVariable ASAS_Pop5_GFWHM,limits={0,0.69,0.05},variable= root:Packages:AnisoSAS:Pop5_GaussSDFWHM
	SetVariable ASAS_Pop5_NumPnts,pos={10,390},size={170,16},title="Pop 5 Num Pnts", help={"Population 5 Number of points, Gauss function"}
	SetVariable ASAS_Pop5_NumPnts,limits={0,51,2},variable= root:Packages:AnisoSAS:Pop5_GaussSDNumBins

	if (root:packages:AnisoSAS:UseOfFormula4==1)
		CheckBox ASAS_CntrlFormula4c,value= 1
		CheckBox ASAS_CntrlFormula4b,value= 0
		CheckBox ASAS_CntrlFormula4a,value= 0
	endif
	if (root:packages:AnisoSAS:UseOfFormula4==2)
		CheckBox ASAS_CntrlFormula4c,value= 0
		CheckBox ASAS_CntrlFormula4b,value= 0
		CheckBox ASAS_CntrlFormula4a,value= 1
	endif
	if (root:packages:AnisoSAS:UseOfFormula4==3)
		CheckBox ASAS_CntrlFormula4c,value= 0
		CheckBox ASAS_CntrlFormula4b,value= 3
		CheckBox ASAS_CntrlFormula4a,value= 0
	endif
	if (root:packages:AnisoSAS:UseOfFormula4==1)
		SetVariable ASAS_Pop1_FWHM, disable=0
		SetVariable ASAS_Pop2_FWHM, disable=0
		SetVariable ASAS_Pop3_FWHM, disable=0
		SetVariable ASAS_Pop4_FWHM, disable=0
		SetVariable ASAS_Pop5_FWHM, disable=0
	else
		SetVariable ASAS_Pop1_FWHM, disable=1
		SetVariable ASAS_Pop2_FWHM, disable=1
		SetVariable ASAS_Pop3_FWHM, disable=1
		SetVariable ASAS_Pop4_FWHM, disable=1
		SetVariable ASAS_Pop5_FWHM, disable=1
	endif
EndMacro

Function ASAS_InterferencePanel(Population)
	variable Population
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(105.75,320.75,576,529.25) as "ASAS_InterferencePanel population "+num2str(Population)
	DoWindow/C $("ASAS_InterferencePanel"+num2str(Population))
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (0,0,65280)
	DrawText 103,28,"Interference input pop: "+num2str(Population)
	SetVariable Pop_InterfETA,pos={11,88},size={130,16},proc=ASAS_SetVarProc,title="ETA       "
	SetVariable Pop_InterfETA,help={"ETA for this population. This is interparticle spacing."}
	SetVariable Pop_InterfETA,limits={0,Inf,1},value= $("root:Packages:AnisoSAS:Pop"+num2str(population)+"_InterfETA")
	CheckBox Pop_FitInterfETA,pos={169,87},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox Pop_FitInterfETA,help={"Check if you want to fit this parameter"}
	CheckBox Pop_FitInterfETA,variable = $("root:Packages:AnisoSAS:Pop"+num2str(population)+"_FitInterfETA")
	SetVariable Pop_InterfETAMin,pos={214,87},size={70,16},proc=ASAS_SetVarProc,title=" "
	SetVariable Pop_InterfETAMin,help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable Pop_InterfETAMin,limits={0,Inf,1},value= $("root:Packages:AnisoSAS:Pop"+num2str(population)+"_InterfETAMin")
	SetVariable Pop_InterfETAMax,pos={291,87},size={130,16},proc=ASAS_SetVarProc,title=" < ETA <  "
	SetVariable Pop_InterfETAMax,help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable Pop_InterfETAMax,limits={0,Inf,1},value= $("root:Packages:AnisoSAS:Pop"+num2str(population)+"_InterfETAMax")

	SetVariable Pop_InterfPack,pos={9,127},size={130,16},proc=ASAS_SetVarProc,title="Packing "
	SetVariable Pop_InterfPack,help={"Packing for this population"}
	SetVariable Pop_InterfPack,limits={0,Inf,1},value= $("root:Packages:AnisoSAS:Pop"+num2str(population)+"_InterfPack")
	CheckBox Pop_FitInterfPack,pos={167,127},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox Pop_FitInterfPack,help={"Check if you want to fit packing"}
	CheckBox Pop_FitInterfPack,variable = $("root:Packages:AnisoSAS:Pop"+num2str(population)+"_FitInterfPack")
	SetVariable Pop_InterfPackMin,pos={214,127},size={70,16},proc=ASAS_SetVarProc,title=" "
	SetVariable Pop_InterfPackMin,help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable Pop_InterfPackMin,limits={0,Inf,1},value= $("root:Packages:AnisoSAS:Pop"+num2str(population)+"_InterfPackMin")
	SetVariable Pop_InterfPackMax,pos={289,127},size={130,16},proc=ASAS_SetVarProc,title=" < Pack <  "
	SetVariable Pop_InterfPackMax,help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable Pop_InterfPackMax,limits={0,Inf,1},value= $("root:Packages:AnisoSAS:Pop"+num2str(population)+"_InterfPackMax")
//	ListOfVariables+="Pop1_InterfETA;Pop1_InterfPack;Pop1_FitInterfETA;Pop1_InterfETAMin;Pop1_InterfETAMax;Pop1_FitInterfPack;Pop1_InterfPackMin;Pop1_InterfPackMax;"
//	ListOfVariables+="Pop2_InterfETA;Pop2_InterfPack;Pop2_FitInterfETA;Pop2_InterfETAMin;Pop2_InterfETAMax;Pop2_FitInterfPack;Pop2_InterfPackMin;Pop2_InterfPackMax;"
//	ListOfVariables+="Pop3_InterfETA;Pop3_InterfPack;Pop3_FitInterfETA;Pop3_InterfETAMin;Pop3_InterfETAMax;Pop3_FitInterfPack;Pop3_InterfPackMin;Pop3_InterfPackMax;"
//	ListOfVariables+="Pop4_InterfETA;Pop4_InterfPack;Pop4_FitInterfETA;Pop4_InterfETAMin;Pop4_InterfETAMax;Pop4_FitInterfPack;Pop4_InterfPackMin;Pop4_InterfPackMax;"


EndMacro

Window ASAS_InputPanel() : Panel
	PauseUpdate; Silent 1		// building window...
	NewPanel /K=1 /W=(3,41.75,453,740) as "ASAS_InputPanel"
//	ShowTools
	SetDrawLayer UserBack
	SetDrawEnv fsize= 20,fstyle= 1,textrgb= (0,0,65280)
	DrawText 73,27,"Anisotropic SAS Modeling"
	SetDrawEnv fstyle= 1,textrgb= (0,0,65280)
	DrawText 239,74,"Alpha          Omega         Bckg."
	SetDrawEnv linethick= 3,linefgc= (0,0,65280)
	DrawLine 10,271,405,271
	SetDrawEnv fsize= 18,fstyle= 1,textrgb= (0,0,65280)
	DrawText 10,297,"Scatterers populations"
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 47,398,"Parameter"
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 293,400,"Limits"
	SetDrawEnv fsize= 14,fstyle= 1,textrgb= (0,0,65280)
	DrawText 163,400,"Fit?"
	CheckBox ASASDataType,pos={8,48},size={153,14},proc=ASAS_CheckProc,title="Use Multiply corrected data?"
	CheckBox ASASDataType,help={"Check, if the data to be used are after MSAXS correction (M_DSM_Int, Qvec, Error)"}
	CheckBox ASASDataType,value=root:Packages:AnisoSAS:UseMultiplyCorrDta
	PopupMenu ASASNumberOfDirections,pos={241,33},size={154,21},proc=ASAS_PopMenuProc,title="Number fo directions"
	PopupMenu ASASNumberOfDirections,help={"Select number of directions for input"}
	PopupMenu ASASNumberOfDirections,value= #"\"0;1;2;3;4;5;6\"", mode=(root:Packages:AnisoSAS:NumberOfDirections+1)
	PopupMenu ASASDir1FolderName,pos={5,80},size={79,21},proc=ASAS_PopMenuProc,title="Dir 1:"
	PopupMenu ASASDir1FolderName,help={"Select folder with data in direction 1, assign the angles"}
	PopupMenu ASASDir1FolderName,mode=1, popvalue="---",value= #"\"---;\"+ASAS_GenStringOfFolders(root:Packages:AnisoSAS:UseMultiplyCorrDta)"
	PopupMenu ASASDir2FolderName,pos={5,105},size={79,21},proc=ASAS_PopMenuProc,title="Dir 2:"
	PopupMenu ASASDir2FolderName,help={"Select folder with data in direction 2, assign the angles"}
	PopupMenu ASASDir2FolderName,mode=1, popvalue="---",value= #"\"---;\"+ASAS_GenStringOfFolders(root:Packages:AnisoSAS:UseMultiplyCorrDta)"
	PopupMenu ASASDir3FolderName,pos={5,130},size={79,21},proc=ASAS_PopMenuProc,title="Dir 3:"
	PopupMenu ASASDir3FolderName,help={"Select folder with data in direction 3, assign the angles"}
	PopupMenu ASASDir3FolderName,mode=1, popvalue="---",value= #"\"---;\"+ASAS_GenStringOfFolders(root:Packages:AnisoSAS:UseMultiplyCorrDta)"
	PopupMenu ASASDir4FolderName,pos={5,155},size={79,21},proc=ASAS_PopMenuProc,title="Dir 4:"
	PopupMenu ASASDir4FolderName,help={"Select folder with data in direction 4, assign the angles"}
	PopupMenu ASASDir4FolderName,mode=1, popvalue="---",value= #"\"---;\"+ASAS_GenStringOfFolders(root:Packages:AnisoSAS:UseMultiplyCorrDta)"
	PopupMenu ASASDir5FolderName,pos={5,180},size={79,21},proc=ASAS_PopMenuProc,title="Dir 5:"
	PopupMenu ASASDir5FolderName,help={"Select folder with data in direction 5, assign the angles"}
	PopupMenu ASASDir5FolderName,mode=1, popvalue="---",value= #"\"---;\"+ASAS_GenStringOfFolders(root:Packages:AnisoSAS:UseMultiplyCorrDta)"
	PopupMenu ASASDir6FolderName,pos={5,205},size={79,21},proc=ASAS_PopMenuProc,title="Dir 6:"
	PopupMenu ASASDir6FolderName,help={"Select folder with data in direction 6, assign the angles"}
	PopupMenu ASASDir6FolderName,mode=1, popvalue="---",value= #"\"---;\"+ASAS_GenStringOfFolders(root:Packages:AnisoSAS:UseMultiplyCorrDta)"
	SetVariable ASASDir1AlphaQ,pos={240,83},size={50,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir1AlphaQ,help={"Input value of Alpha for this direction"}
	SetVariable ASASDir1AlphaQ,value= root:Packages:AnisoSAS:Dir1_AlphaQ
	SetVariable ASASDir1OmegaQ,pos={300,83},size={50,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir1OmegaQ,help={"Input value of Omega for this direction"}
	SetVariable ASASDir1OmegaQ,value= root:Packages:AnisoSAS:Dir1_OmegaQ
	SetVariable ASASDir1Background,pos={360,83},size={60,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir1Background,help={"Input value of background for this direction"}
	SetVariable ASASDir1Background,value= root:Packages:AnisoSAS:Dir1_Background
	SetVariable ASASDir2AlphaQ,pos={240,108},size={50,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir2AlphaQ,help={"Input value of Alpha for this direction"}
	SetVariable ASASDir2AlphaQ,value= root:Packages:AnisoSAS:Dir2_AlphaQ
	SetVariable ASASDir2OmegaQ,pos={300,108},size={50,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir2OmegaQ,help={"Input value of Omega for this direction"}
	SetVariable ASASDir2OmegaQ,value= root:Packages:AnisoSAS:Dir2_OmegaQ
	SetVariable ASASDir2Background,pos={360,108},size={60,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir2Background,help={"Input value of background for this direction"}
	SetVariable ASASDir2Background,value= root:Packages:AnisoSAS:Dir2_Background
	SetVariable ASASDir3AlphaQ,pos={240,133},size={50,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir3AlphaQ,help={"Input value of Alpha for this direction"}
	SetVariable ASASDir3AlphaQ,value= root:Packages:AnisoSAS:Dir3_AlphaQ
	SetVariable ASASDir3OmegaQ,pos={300,133},size={50,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir3OmegaQ,help={"Input value of Omega for this direction"}
	SetVariable ASASDir3OmegaQ,value= root:Packages:AnisoSAS:Dir3_OmegaQ
	SetVariable ASASDir3Background,pos={360,133},size={60,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir3Background,help={"Input value of background for this direction"}
	SetVariable ASASDir3Background,value= root:Packages:AnisoSAS:Dir3_Background
	SetVariable ASASDir4AlphaQ,pos={240,158},size={50,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir4AlphaQ,help={"Input value of Alpha for this direction"}
	SetVariable ASASDir4AlphaQ,value= root:Packages:AnisoSAS:Dir4_AlphaQ
	SetVariable ASASDir4OmegaQ,pos={300,158},size={50,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir4OmegaQ,help={"Input value of Omega for this direction"}
	SetVariable ASASDir4OmegaQ,value= root:Packages:AnisoSAS:Dir4_OmegaQ
	SetVariable ASASDir4Background,pos={360,158},size={60,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir4Background,help={"Input value of background for this direction"}
	SetVariable ASASDir4Background,value= root:Packages:AnisoSAS:Dir4_Background
	SetVariable ASASDir5AlphaQ,pos={240,183},size={50,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir5AlphaQ,help={"Input value of Alpha for this direction"}
	SetVariable ASASDir5AlphaQ,value= root:Packages:AnisoSAS:Dir5_AlphaQ
	SetVariable ASASDir5OmegaQ,pos={300,183},size={50,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir5OmegaQ,help={"Input value of Omega for this direction"}
	SetVariable ASASDir5OmegaQ,value= root:Packages:AnisoSAS:Dir5_OmegaQ
	SetVariable ASASDir5Background,pos={360,183},size={60,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir5Background,help={"Input value of background for this direction"}
	SetVariable ASASDir5Background,value= root:Packages:AnisoSAS:Dir5_Background
	SetVariable ASASDir6AlphaQ,pos={240,208},size={50,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir6AlphaQ,help={"Input value of Alpha for this direction"}
	SetVariable ASASDir6AlphaQ,value= root:Packages:AnisoSAS:Dir6_AlphaQ
	SetVariable ASASDir6OmegaQ,pos={300,208},size={50,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir6OmegaQ,help={"Input value of Omega for this direction"}
	SetVariable ASASDir6OmegaQ,value= root:Packages:AnisoSAS:Dir6_OmegaQ
	SetVariable ASASDir6Background,pos={360,208},size={60,16},proc=ASAS_SetVarProc,title=" "
	SetVariable ASASDir6Background,help={"Input value of background for this direction"}
	SetVariable ASASDir6Background,value= root:Packages:AnisoSAS:Dir6_Background
	Button ASASGraphData,pos={29,238},size={120,20},proc=ASAS_ButtonProc,title="Graph"
	Button ASASGraphData,help={"This button creates log-log plot of data and allows further modeling"}
	SetVariable ASASWavelength,pos={200,238},size={150,16},proc=ASAS_SetVarProc,title="Wavelength [A]"
	SetVariable ASASWavelength,help={"Input value of Wavelength for all directions"}
	SetVariable ASASWavelength,value= root:Packages:AnisoSAS:Wavelength
	
	
	PopupMenu ASASNumberOfPopulations,pos={21,302},size={166,21},proc=ASAS_PopMenuProc,title="Number of populations "
	PopupMenu ASASNumberOfPopulations,help={"Select number of scatterers populations to be modeled"}
	PopupMenu ASASNumberOfPopulations,mode=1,popvalue="0",value= #"\"0;1;2;3;4;5\""

	Button ASASCalcModelInt,pos={30,645},size={120,20},proc=ASAS_ButtonProc,title="Calc Int"
	Button ASASCalcModelInt,help={"This button creates calculates intensity from model"}

	Button ASASModelAnisotropyX,pos={30,675},size={120,20},proc=ASAS_ButtonProc,title="Model Anisotropy X"
	Button ASASModelAnisotropyX,help={"Model anisotropy of intensity from this model in X direction"}
	Button ASASModelAnisotropyY,pos={160,645},size={120,20},proc=ASAS_ButtonProc,title="Model Anisotropy Y"
	Button ASASModelAnisotropyY,help={"Model anisotropy of intensity from this model in Y direction"}
	Button ASASModelAnisotropyZ,pos={160,675},size={120,20},proc=ASAS_ButtonProc,title="Model Anisotropy Z"
	Button ASASModelAnisotropyZ,help={"Model anisotropy of intensity from this model in Z direction"}

	Button ASASFitAnisotropy,pos={290,645},size={120,20},proc=ASAS_ButtonProc,title="Fit"
	Button ASASFitAnisotropy,help={"This button fits model intensity to measured data, not e this will be slow!!!!"}
	Button ASASReverseFit,pos={290,675},size={120,20},proc=ASAS_ButtonProc,title="Reverse fit"
	Button ASASReverseFit,help={"This button returns back the values of parameters before the last LSQ fiting"}





	TabControl DistTabs,pos={10,330},size={400,305},proc=ASAS_TabPanelControl
	TabControl DistTabs,fSize=8,tabLabel(0)="1. Population "
	TabControl DistTabs,tabLabel(1)="2. Population ",tabLabel(2)="3. Population "
	TabControl DistTabs,tabLabel(3)="4. Population ",tabLabel(4)="5. Population ",value= 0
	CheckBox ASASDisplayLocals,pos={246,282},size={117,14},proc=ASAS_CheckProc,title="Display Single fits"
	CheckBox ASASDisplayLocals,help={"Recalculate anytimes you make change in parameters? Careful - can be SLOW...."}
	CheckBox ASASDisplayLocals,variable= root:Packages:AnisoSAS:DisplayPopulations
	CheckBox ASASUpdateImmediately,pos={246,298},size={117,14},proc=ASAS_CheckProc,title="Update automatically"
	CheckBox ASASUpdateImmediately,help={"Recalculate anytimes you make change in parameters? Careful - can be SLOW...."}
	CheckBox ASASUpdateImmediately,value= 0
	CheckBox ASASDisplayAllPops,pos={246,314},size={117,14},proc=ASAS_CheckProc,title="Display all pops?"
	CheckBox ASASDisplayAllPops,help={"Displays in the probability graph all populations probability distributions"}
	CheckBox ASASDisplayAllPops,value= root:Packages:AnisoSAS:DisplayAllProbabilityDist

//DisplayPopulations

//Population 1
	SetVariable ASASPop1DeltaRho,pos={24,358},size={190,16},proc=ASAS_SetVarProc,title="Delta rho [cm-2] "
	SetVariable ASASPop1DeltaRho,value= root:Packages:AnisoSAS:Pop1_DeltaRho, help={"Insert delat rho (NOT delat rho squared!!!) for this population"}
	SetVariable ASASPop1Beta,pos={249,359},size={100,16},proc=ASAS_SetVarProc,title="Beta: "
	SetVariable ASASPop1Beta,limits={0.05,20,0.1},value= root:Packages:AnisoSAS:Pop1_Beta, help={"Aspect ratio for this population. beta >1 - cigar like shape, beta<1 doughnut like shape"}
	SetVariable ASASPop1Radius,pos={16,400},size={130,16},proc=ASAS_SetVarProc,title="Radius [A]  "
	SetVariable ASASPop1Radius,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop1_Radius, help={"Radius of this population in A"}
	CheckBox ASASPop1FitRadius,pos={168,402},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop1FitRadius,value= 0, help={"Check if Radius should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop1RadiusMin,pos={223,400},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this population, this is MINIMUM"}
	SetVariable ASASPop1RadiusMin,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop1_RadiusMin
	SetVariable ASASPop1RadiusMax,pos={290,400},size={100,16},proc=ASAS_SetVarProc,title=" <  R  <  ", help={"Fitting limits of this population, this is Maximum"}
	SetVariable ASASPop1RadiusMax,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop1_RadiusMax

	SetVariable ASASPop1VolumeFraction,pos={16,420},size={130,16},proc=ASAS_SetVarProc,title="Volume Fract"
	SetVariable ASASPop1VolumeFraction,limits={0.00001,1,0.02},value= root:Packages:AnisoSAS:Pop1_VolumeFraction, help={"Volume fraction of this population"}
	CheckBox ASASPop1FitVolumeFraction,pos={168,422},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop1FitVolumeFraction,value= 0, help={"Check if Volume Fraction should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop1VolumeFractionMin,pos={223,420},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this population, this is MINIMUM"}
	SetVariable ASASPop1VolumeFractionMin,limits={0,1,0.02},value= root:Packages:AnisoSAS:Pop1_VolumeFractionMin
	SetVariable ASASPop1VolumeFractionMax,pos={290,420},size={100,16},proc=ASAS_SetVarProc,title=" <  V  <  ", help={"Fitting limits of this population, this is Maximum"}
	SetVariable ASASPop1VolumeFractionMax,limits={0,1,0.02},value= root:Packages:AnisoSAS:Pop1_VolumeFractionMax

	SetVariable ASASPop1PAlphaSteps,pos={16,440},size={180,16},proc=ASAS_SetVarProc,title="Probab. Alpha steps"
	SetVariable ASASPop1PAlphaSteps,limits={10,Inf,1},value= root:Packages:AnisoSAS:Pop1_PAlphaSteps, help={"How many steps (bins) in Probablility over alpha you want to use?"}
	CheckBox ASASPop1UsePAlphaParam,pos={210,442},size={21,14},proc=ASAS_CheckProc,title="Use Parameters for P alpha"
	CheckBox ASASPop1UsePAlphaParam,value= 0, help={"Check if you want to use P alpha parameters, if not fill in table manually"}
	Button ASASPop1GetAlphaWave,pos={100,470},size={160,20},proc=ASAS_ButtonProc,title="Edit Alpha Dist"
	Button ASASPop1GetAlphaWave,help={"This button creates table of alpha probablity for user to edit"}

	SetVariable ASASPop1PAlphaPar1,pos={16,460},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 1"
	SetVariable ASASPop1PAlphaPar1,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_PAlphaPar1, help={"Parameters 1 for P alpha"}
	CheckBox ASASPop1FitPAlphaPar1,pos={168,462},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop1FitPAlphaPar1,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop1PAlphaPar1Min,pos={223,460},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop1PAlphaPar1Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_PAlphaPar1Min
	SetVariable ASASPop1PAlphaPar1Max,pos={290,460},size={100,16},proc=ASAS_SetVarProc,title=" < PA1 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop1PAlphaPar1Max,limits={10,Inf,1},value= root:Packages:AnisoSAS:Pop1_PAlphaPar1Max
	SetVariable ASASPop1PAlphaPar2,pos={16,480},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 2"
	SetVariable ASASPop1PAlphaPar2,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_PAlphaPar2, help={"Parameters 2 for P alpha"}
	CheckBox  ASASPop1FitPAlphaPar2,pos={168,482},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox  ASASPop1FitPAlphaPar2,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop1PAlphaPar2Min,pos={223,480},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop1PAlphaPar2Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_PAlphaPar2Min
	SetVariable ASASPop1PAlphaPar2Max,pos={290,480},size={100,16},proc=ASAS_SetVarProc,title=" < PA2 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop1PAlphaPar2Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_PAlphaPar2Max
	SetVariable ASASPop1PAlphaPar3,pos={16,500},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 3"
	SetVariable ASASPop1PAlphaPar3,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_PAlphaPar3, help={"Parameters 3 for P alpha"}
	CheckBox ASASPop1FitPAlphaPar3,pos={168,502},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop1FitPAlphaPar3,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop1PAlphaPar3Min,pos={223,500},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop1PAlphaPar3Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_PAlphaPar3Min
	SetVariable ASASPop1PAlphaPar3Max,pos={290,500},size={100,16},proc=ASAS_SetVarProc,title=" < PA3 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop1PAlphaPar3Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_PAlphaPar3Max

	SetVariable ASASPop1BOmegaSteps,pos={16,520},size={180,16},proc=ASAS_SetVarProc,title="Probab. Omega steps"
	SetVariable ASASPop1BOmegaSteps,limits={10,Inf,1},value= root:Packages:AnisoSAS:Pop1_BOmegaSteps, help={"How many steps (bins) in Probablility over omega you want to use?"}
	CheckBox ASASPop1UseBOmegaParam,pos={210,522},size={21,14},proc=ASAS_CheckProc,title="Use Parameters for B omega"
	CheckBox ASASPop1UseBOmegaParam,value= 0, help={"Check if you want to use B omega parameters, if not fill in table manually"}
	Button ASASPop1GetOmegaWave,pos={100,550},size={160,20},proc=ASAS_ButtonProc,title="Edit Omega Dist"
	Button ASASPop1GetOmegaWave,help={"This button creates table of omega probablity for user to edit"}

	SetVariable ASASPop1BOmegaPar1,pos={16,540},size={130,16},proc=ASAS_SetVarProc,title="B omega par 1"
	SetVariable ASASPop1BOmegaPar1,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_BOmegaPar1, help={"Parameters 1 for B Omega"}
	CheckBox ASASPop1FitBOmegaPar1,pos={168,542},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop1FitBOmegaPar1,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop1BOmegaPar1Min,pos={223,540},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop1BOmegaPar1Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_BOmegaPar1Min
	SetVariable ASASPop1BOmegaPar1Max,pos={290,540},size={100,16},proc=ASAS_SetVarProc,title=" < BO1 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop1BOmegaPar1Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_BOmegaPar1Max
	SetVariable ASASPop1BOmegaPar2,pos={16,560},size={130,16},proc=ASAS_SetVarProc,title="B omega par 2"
	SetVariable ASASPop1BOmegaPar2,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_BOmegaPar2, help={"Parameters 2 for B Omega"}
	CheckBox  ASASPop1FitBOmegaPar2,pos={168,562},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox  ASASPop1FitBOmegaPar2,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop1BOmegaPar2Min,pos={223,560},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop1BOmegaPar2Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_BOmegaPar2Min
	SetVariable ASASPop1BOmegaPar2Max,pos={290,560},size={100,16},proc=ASAS_SetVarProc,title=" < BO2 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop1BOmegaPar2Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_BOmegaPar2Max
	SetVariable ASASPop1BOmegaPar3,pos={16,580},size={130,16},proc=ASAS_SetVarProc,title="B omega par 3"
	SetVariable ASASPop1BOmegaPar3,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_BOmegaPar3, help={"Parameters 3 for B Omega"}
	CheckBox ASASPop1FitBOmegaPar3,pos={168,582},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop1FitBOmegaPar3,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop1BOmegaPar3Min,pos={223,580},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop1BOmegaPar3Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_BOmegaPar3Min
	SetVariable ASASPop1BOmegaPar3Max,pos={290,580},size={100,16},proc=ASAS_SetVarProc,title=" < BO3 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop1BOmegaPar3Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop1_BOmegaPar3Max

	SetVariable ASASPop1SurfaceArea,pos={20,605},size={180,16},proc=noproc,title="Surface area", help={"Surface area of this population in cm2/cm3"}
	SetVariable ASASPop1SurfaceArea,limits={0,Inf,0},value= root:Packages:AnisoSAS:Pop1_SurfaceArea
	CheckBox ASASPop1UseInterference,pos={240,605},size={21,14},proc=ASAS_CheckProc,title="Interference?"
	CheckBox ASASPop1UseInterference,variable=root:Packages:AnisoSAS:Pop1_UseInterference, help={"Check if you want to use interference for this population"}

//Population 2
	SetVariable ASASPop2DeltaRho,pos={24,358},size={190,16},proc=ASAS_SetVarProc,title="Delta rho [cm-2] "
	SetVariable ASASPop2DeltaRho,value= root:Packages:AnisoSAS:Pop2_DeltaRho, help={"Insert delat rho (NOT delat rho squared!!!) for this population"}
	SetVariable ASASPop2Beta,pos={249,359},size={100,16},proc=ASAS_SetVarProc,title="Beta: "
	SetVariable ASASPop2Beta,limits={0.05,20,0.1},value= root:Packages:AnisoSAS:Pop2_Beta, help={"Aspect ratio for this population. beta >1 - cigar like shape, beta<1 doughnut like shape"}
	SetVariable ASASPop2Radius,pos={16,400},size={130,16},proc=ASAS_SetVarProc,title="Radius [A]  "
	SetVariable ASASPop2Radius,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop2_Radius, help={"Radius of this population in A"}
	CheckBox ASASPop2FitRadius,pos={168,402},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop2FitRadius,value= 0, help={"Check if Radius should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop2RadiusMin,pos={223,400},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this population, this is MINIMUM"}
	SetVariable ASASPop2RadiusMin,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop2_RadiusMin
	SetVariable ASASPop2RadiusMax,pos={290,400},size={100,16},proc=ASAS_SetVarProc,title=" <  R  <  ", help={"Fitting limits of this population, this is Maximum"}
	SetVariable ASASPop2RadiusMax,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop2_RadiusMax

	SetVariable ASASPop2VolumeFraction,pos={16,420},size={130,16},proc=ASAS_SetVarProc,title="Volume Fract"
	SetVariable ASASPop2VolumeFraction,limits={0.00001,1,0.02},value= root:Packages:AnisoSAS:Pop2_VolumeFraction, help={"Volume fraction of this population"}
	CheckBox ASASPop2FitVolumeFraction,pos={168,422},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop2FitVolumeFraction,value= 0, help={"Check if Volume Fraction should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop2VolumeFractionMin,pos={223,420},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this population, this is MINIMUM"}
	SetVariable ASASPop2VolumeFractionMin,limits={0,1,0.02},value= root:Packages:AnisoSAS:Pop2_VolumeFractionMin
	SetVariable ASASPop2VolumeFractionMax,pos={290,420},size={100,16},proc=ASAS_SetVarProc,title=" <  V  <  ", help={"Fitting limits of this population, this is Maximum"}
	SetVariable ASASPop2VolumeFractionMax,limits={0,1,0.02},value= root:Packages:AnisoSAS:Pop2_VolumeFractionMax

	SetVariable ASASPop2PAlphaSteps,pos={16,440},size={180,16},proc=ASAS_SetVarProc,title="Probab. Alpha steps"
	SetVariable ASASPop2PAlphaSteps,limits={10,Inf,1},value= root:Packages:AnisoSAS:Pop2_PAlphaSteps, help={"How many steps (bins) in Probablility over alpha you want to use?"}
	CheckBox ASASPop2UsePAlphaParam,pos={210,442},size={21,14},proc=ASAS_CheckProc,title="Use Parameters for P alpha"
	CheckBox ASASPop2UsePAlphaParam,value= 0, help={"Check if you want to use P alpha parameters, if not fill in table manually"}
	Button ASASPop2GetAlphaWave,pos={100,470},size={160,20},proc=ASAS_ButtonProc,title="Edit Alpha Dist"
	Button ASASPop2GetAlphaWave,help={"This button creates table of alpha probablity for user to edit"}

	SetVariable ASASPop2PAlphaPar1,pos={16,460},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 1"
	SetVariable ASASPop2PAlphaPar1,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_PAlphaPar1, help={"Parameters 1 for P alpha"}
	CheckBox ASASPop2FitPAlphaPar1,pos={168,462},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop2FitPAlphaPar1,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop2PAlphaPar1Min,pos={223,460},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop2PAlphaPar1Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_PAlphaPar1Min
	SetVariable ASASPop2PAlphaPar1Max,pos={290,460},size={100,16},proc=ASAS_SetVarProc,title=" < PA1 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop2PAlphaPar1Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_PAlphaPar1Max
	SetVariable ASASPop2PAlphaPar2,pos={16,480},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 2"
	SetVariable ASASPop2PAlphaPar2,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_PAlphaPar2, help={"Parameters 2 for P alpha"}
	CheckBox  ASASPop2FitPAlphaPar2,pos={168,482},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox  ASASPop2FitPAlphaPar2,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop2PAlphaPar2Min,pos={223,480},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop2PAlphaPar2Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_PAlphaPar2Min
	SetVariable ASASPop2PAlphaPar2Max,pos={290,480},size={100,16},proc=ASAS_SetVarProc,title=" < PA2 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop2PAlphaPar2Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_PAlphaPar2Max
	SetVariable ASASPop2PAlphaPar3,pos={16,500},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 3"
	SetVariable ASASPop2PAlphaPar3,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_PAlphaPar3, help={"Parameters 3 for P alpha"}
	CheckBox ASASPop2FitPAlphaPar3,pos={168,502},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop2FitPAlphaPar3,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop2PAlphaPar3Min,pos={223,500},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop2PAlphaPar3Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_PAlphaPar3Min
	SetVariable ASASPop2PAlphaPar3Max,pos={290,500},size={100,16},proc=ASAS_SetVarProc,title=" < PA3 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop2PAlphaPar3Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_PAlphaPar3Max

	SetVariable ASASPop2BOmegaSteps,pos={16,520},size={180,16},proc=ASAS_SetVarProc,title="Probab. Omega steps"
	SetVariable ASASPop2BOmegaSteps,limits={10,Inf,1},value= root:Packages:AnisoSAS:Pop2_BOmegaSteps, help={"How many steps (bins) in Probablility over omega you want to use?"}
	CheckBox ASASPop2UseBOmegaParam,pos={210,522},size={21,14},proc=ASAS_CheckProc,title="Use Parameters for B omega"
	CheckBox ASASPop2UseBOmegaParam,value= 0, help={"Check if you want to use B omega parameters, if not fill in table manually"}
	Button ASASPop2GetOmegaWave,pos={100,550},size={160,20},proc=ASAS_ButtonProc,title="Edit Omega Dist"
	Button ASASPop2GetOmegaWave,help={"This button creates table of omega probablity for user to edit"}

	SetVariable ASASPop2BOmegaPar1,pos={16,540},size={130,16},proc=ASAS_SetVarProc,title="B omega par 1"
	SetVariable ASASPop2BOmegaPar1,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_BOmegaPar1, help={"Parameters 1 for B Omega"}
	CheckBox ASASPop2FitBOmegaPar1,pos={168,542},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop2FitBOmegaPar1,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop2BOmegaPar1Min,pos={223,540},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop2BOmegaPar1Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_BOmegaPar1Min
	SetVariable ASASPop2BOmegaPar1Max,pos={290,540},size={100,16},proc=ASAS_SetVarProc,title=" < BO1 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop2BOmegaPar1Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_BOmegaPar1Max
	SetVariable ASASPop2BOmegaPar2,pos={16,560},size={130,16},proc=ASAS_SetVarProc,title="B omega par 2"
	SetVariable ASASPop2BOmegaPar2,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_BOmegaPar2, help={"Parameters 2 for B Omega"}
	CheckBox  ASASPop2FitBOmegaPar2,pos={168,562},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox  ASASPop2FitBOmegaPar2,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop2BOmegaPar2Min,pos={223,560},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop2BOmegaPar2Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_BOmegaPar2Min
	SetVariable ASASPop2BOmegaPar2Max,pos={290,560},size={100,16},proc=ASAS_SetVarProc,title=" < BO2 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop2BOmegaPar2Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_BOmegaPar2Max
	SetVariable ASASPop2BOmegaPar3,pos={16,580},size={130,16},proc=ASAS_SetVarProc,title="B omega par 3"
	SetVariable ASASPop2BOmegaPar3,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_BOmegaPar3, help={"Parameters 3 for B Omega"}
	CheckBox ASASPop2FitBOmegaPar3,pos={168,582},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop2FitBOmegaPar3,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop2BOmegaPar3Min,pos={223,580},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop2BOmegaPar3Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_BOmegaPar3Min
	SetVariable ASASPop2BOmegaPar3Max,pos={290,580},size={100,16},proc=ASAS_SetVarProc,title=" < BO3 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop2BOmegaPar3Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop2_BOmegaPar3Max


	SetVariable ASASPop2SurfaceArea,pos={20,605},size={180,16},proc=noproc,title="Surface area", help={"Surface area of this population in cm2/cm3"}
	SetVariable ASASPop2SurfaceArea,limits={0,Inf,0},value= root:Packages:AnisoSAS:Pop2_SurfaceArea
	CheckBox ASASPop2UseInterference,pos={240,605},size={21,14},proc=ASAS_CheckProc,title="Interference?"
	CheckBox ASASPop2UseInterference,variable=root:Packages:AnisoSAS:Pop2_UseInterference, help={"Check if you want to use interference for this population"}
//Population 3
	SetVariable ASASPop3DeltaRho,pos={24,358},size={190,16},proc=ASAS_SetVarProc,title="Delta rho [cm-2] "
	SetVariable ASASPop3DeltaRho,value= root:Packages:AnisoSAS:Pop3_DeltaRho, help={"Insert delat rho (NOT delat rho squared!!!) for this population"}
	SetVariable ASASPop3Beta,pos={249,359},size={100,16},proc=ASAS_SetVarProc,title="Beta: "
	SetVariable ASASPop3Beta,limits={0.05,20,0.1},value= root:Packages:AnisoSAS:Pop3_Beta, help={"Aspect ratio for this population. beta >1 - cigar like shape, beta<1 doughnut like shape"}
	SetVariable ASASPop3Radius,pos={16,400},size={130,16},proc=ASAS_SetVarProc,title="Radius [A]  "
	SetVariable ASASPop3Radius,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop3_Radius, help={"Radius of this population in A"}
	CheckBox ASASPop3FitRadius,pos={168,402},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop3FitRadius,value= 0, help={"Check if Radius should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop3RadiusMin,pos={223,400},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this population, this is MINIMUM"}
	SetVariable ASASPop3RadiusMin,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop3_RadiusMin
	SetVariable ASASPop3RadiusMax,pos={290,400},size={100,16},proc=ASAS_SetVarProc,title=" <  R  <  ", help={"Fitting limits of this population, this is Maximum"}
	SetVariable ASASPop3RadiusMax,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop3_RadiusMax

	SetVariable ASASPop3VolumeFraction,pos={16,420},size={130,16},proc=ASAS_SetVarProc,title="Volume Fract"
	SetVariable ASASPop3VolumeFraction,limits={0.00001,1,0.02},value= root:Packages:AnisoSAS:Pop3_VolumeFraction, help={"Volume fraction of this population"}
	CheckBox ASASPop3FitVolumeFraction,pos={168,422},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop3FitVolumeFraction,value= 0, help={"Check if Volume Fraction should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop3VolumeFractionMin,pos={223,420},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this population, this is MINIMUM"}
	SetVariable ASASPop3VolumeFractionMin,limits={0,1,0.02},value= root:Packages:AnisoSAS:Pop3_VolumeFractionMin
	SetVariable ASASPop3VolumeFractionMax,pos={290,420},size={100,16},proc=ASAS_SetVarProc,title=" <  V  <  ", help={"Fitting limits of this population, this is Maximum"}
	SetVariable ASASPop3VolumeFractionMax,limits={0,1,0.02},value= root:Packages:AnisoSAS:Pop3_VolumeFractionMax

	SetVariable ASASPop3PAlphaSteps,pos={16,440},size={180,16},proc=ASAS_SetVarProc,title="Probab. Alpha steps"
	SetVariable ASASPop3PAlphaSteps,limits={10,Inf,1},value= root:Packages:AnisoSAS:Pop3_PAlphaSteps, help={"How many steps (bins) in Probablility over alpha you want to use?"}
	CheckBox ASASPop3UsePAlphaParam,pos={210,442},size={21,14},proc=ASAS_CheckProc,title="Use Parameters for P alpha"
	CheckBox ASASPop3UsePAlphaParam,value= 0, help={"Check if you want to use P alpha parameters, if not fill in table manually"}
	Button ASASPop3GetAlphaWave,pos={100,470},size={160,20},proc=ASAS_ButtonProc,title="Edit Alpha Dist"
	Button ASASPop3GetAlphaWave,help={"This button creates table of alpha probablity for user to edit"}

	SetVariable ASASPop3PAlphaPar1,pos={16,460},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 1"
	SetVariable ASASPop3PAlphaPar1,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_PAlphaPar1, help={"Parameters 1 for P alpha"}
	CheckBox ASASPop3FitPAlphaPar1,pos={168,462},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop3FitPAlphaPar1,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop3PAlphaPar1Min,pos={223,460},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop3PAlphaPar1Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_PAlphaPar1Min
	SetVariable ASASPop3PAlphaPar1Max,pos={290,460},size={100,16},proc=ASAS_SetVarProc,title=" < PA1 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop3PAlphaPar1Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_PAlphaPar1Max
	SetVariable ASASPop3PAlphaPar2,pos={16,480},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 2"
	SetVariable ASASPop3PAlphaPar2,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_PAlphaPar2, help={"Parameters 2 for P alpha"}
	CheckBox  ASASPop3FitPAlphaPar2,pos={168,482},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox  ASASPop3FitPAlphaPar2,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop3PAlphaPar2Min,pos={223,480},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop3PAlphaPar2Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_PAlphaPar2Min
	SetVariable ASASPop3PAlphaPar2Max,pos={290,480},size={100,16},proc=ASAS_SetVarProc,title=" < PA2 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop3PAlphaPar2Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_PAlphaPar2Max
	SetVariable ASASPop3PAlphaPar3,pos={16,500},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 3"
	SetVariable ASASPop3PAlphaPar3,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_PAlphaPar3, help={"Parameters 3 for P alpha"}
	CheckBox ASASPop3FitPAlphaPar3,pos={168,502},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop3FitPAlphaPar3,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop3PAlphaPar3Min,pos={223,500},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop3PAlphaPar3Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_PAlphaPar3Min
	SetVariable ASASPop3PAlphaPar3Max,pos={290,500},size={100,16},proc=ASAS_SetVarProc,title=" < PA3 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop3PAlphaPar3Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_PAlphaPar3Max

	SetVariable ASASPop3BOmegaSteps,pos={16,520},size={180,16},proc=ASAS_SetVarProc,title="Probab. Omega steps"
	SetVariable ASASPop3BOmegaSteps,limits={10,Inf,1},value= root:Packages:AnisoSAS:Pop3_BOmegaSteps, help={"How many steps (bins) in Probablility over omega you want to use?"}
	CheckBox ASASPop3UseBOmegaParam,pos={210,522},size={21,14},proc=ASAS_CheckProc,title="Use Parameters for B omega"
	CheckBox ASASPop3UseBOmegaParam,value= 0, help={"Check if you want to use B omega parameters, if not fill in table manually"}
	Button ASASPop3GetOmegaWave,pos={100,550},size={160,20},proc=ASAS_ButtonProc,title="Edit Omega Dist"
	Button ASASPop3GetOmegaWave,help={"This button creates table of omega probablity for user to edit"}

	SetVariable ASASPop3BOmegaPar1,pos={16,540},size={130,16},proc=ASAS_SetVarProc,title="B omega par 1"
	SetVariable ASASPop3BOmegaPar1,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_BOmegaPar1, help={"Parameters 1 for B Omega"}
	CheckBox ASASPop3FitBOmegaPar1,pos={168,542},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop3FitBOmegaPar1,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop3BOmegaPar1Min,pos={223,540},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop3BOmegaPar1Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_BOmegaPar1Min
	SetVariable ASASPop3BOmegaPar1Max,pos={290,540},size={100,16},proc=ASAS_SetVarProc,title=" < BO1 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop3BOmegaPar1Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_BOmegaPar1Max
	SetVariable ASASPop3BOmegaPar2,pos={16,560},size={130,16},proc=ASAS_SetVarProc,title="B omega par 2"
	SetVariable ASASPop3BOmegaPar2,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_BOmegaPar2, help={"Parameters 2 for B Omega"}
	CheckBox  ASASPop3FitBOmegaPar2,pos={168,562},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox  ASASPop3FitBOmegaPar2,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop3BOmegaPar2Min,pos={223,560},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop3BOmegaPar2Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_BOmegaPar2Min
	SetVariable ASASPop3BOmegaPar2Max,pos={290,560},size={100,16},proc=ASAS_SetVarProc,title=" < BO2 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop3BOmegaPar2Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_BOmegaPar2Max
	SetVariable ASASPop3BOmegaPar3,pos={16,580},size={130,16},proc=ASAS_SetVarProc,title="B omega par 3"
	SetVariable ASASPop3BOmegaPar3,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_BOmegaPar3, help={"Parameters 3 for B Omega"}
	CheckBox ASASPop3FitBOmegaPar3,pos={168,582},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop3FitBOmegaPar3,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop3BOmegaPar3Min,pos={223,580},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop3BOmegaPar3Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_BOmegaPar3Min
	SetVariable ASASPop3BOmegaPar3Max,pos={290,580},size={100,16},proc=ASAS_SetVarProc,title=" < BO3 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop3BOmegaPar3Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop3_BOmegaPar3Max

	SetVariable ASASPop3SurfaceArea,pos={20,605},size={180,16},proc=noproc,title="Surface area", help={"Surface area of this population in cm2/cm3"}
	SetVariable ASASPop3SurfaceArea,limits={0,Inf,0},value= root:Packages:AnisoSAS:Pop3_SurfaceArea
	CheckBox ASASPop3UseInterference,pos={240,605},size={21,14},proc=ASAS_CheckProc,title="Interference?"
	CheckBox ASASPop3UseInterference,variable=root:Packages:AnisoSAS:Pop3_UseInterference, help={"Check if you want to use interference for this population"}

//Population 4
	SetVariable ASASPop4DeltaRho,pos={24,358},size={190,16},proc=ASAS_SetVarProc,title="Delta rho [cm-2] "
	SetVariable ASASPop4DeltaRho,value= root:Packages:AnisoSAS:Pop4_DeltaRho, help={"Insert delat rho (NOT delat rho squared!!!) for this population"}
	SetVariable ASASPop4Beta,pos={249,359},size={100,16},proc=ASAS_SetVarProc,title="Beta: "
	SetVariable ASASPop4Beta,limits={0.05,20,0.1},value= root:Packages:AnisoSAS:Pop4_Beta, help={"Aspect ratio for this population. beta >1 - cigar like shape, beta<1 doughnut like shape"}
	SetVariable ASASPop4Radius,pos={16,400},size={130,16},proc=ASAS_SetVarProc,title="Radius [A]  "
	SetVariable ASASPop4Radius,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop4_Radius, help={"Radius of this population in A"}
	CheckBox ASASPop4FitRadius,pos={168,402},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop4FitRadius,value= 0, help={"Check if Radius should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop4RadiusMin,pos={223,400},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this population, this is MINIMUM"}
	SetVariable ASASPop4RadiusMin,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop4_RadiusMin
	SetVariable ASASPop4RadiusMax,pos={290,400},size={100,16},proc=ASAS_SetVarProc,title=" <  R  <  ", help={"Fitting limits of this population, this is Maximum"}
	SetVariable ASASPop4RadiusMax,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop4_RadiusMax

	SetVariable ASASPop4VolumeFraction,pos={16,420},size={130,16},proc=ASAS_SetVarProc,title="Volume Fract"
	SetVariable ASASPop4VolumeFraction,limits={0.00001,1,0.02},value= root:Packages:AnisoSAS:Pop4_VolumeFraction, help={"Volume fraction of this population"}
	CheckBox ASASPop4FitVolumeFraction,pos={168,422},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop4FitVolumeFraction,value= 0, help={"Check if Volume Fraction should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop4VolumeFractionMin,pos={223,420},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this population, this is MINIMUM"}
	SetVariable ASASPop4VolumeFractionMin,limits={0,1,0.02},value= root:Packages:AnisoSAS:Pop4_VolumeFractionMin
	SetVariable ASASPop4VolumeFractionMax,pos={290,420},size={100,16},proc=ASAS_SetVarProc,title=" <  V  <  ", help={"Fitting limits of this population, this is Maximum"}
	SetVariable ASASPop4VolumeFractionMax,limits={0,1,0.02},value= root:Packages:AnisoSAS:Pop4_VolumeFractionMax

	SetVariable ASASPop4PAlphaSteps,pos={16,440},size={180,16},proc=ASAS_SetVarProc,title="Probab. Alpha steps"
	SetVariable ASASPop4PAlphaSteps,limits={10,Inf,1},value= root:Packages:AnisoSAS:Pop4_PAlphaSteps, help={"How many steps (bins) in Probablility over alpha you want to use?"}
	CheckBox ASASPop4UsePAlphaParam,pos={210,442},size={21,14},proc=ASAS_CheckProc,title="Use Parameters for P alpha"
	CheckBox ASASPop4UsePAlphaParam,value= 0, help={"Check if you want to use P alpha parameters, if not fill in table manually"}
	Button ASASPop4GetAlphaWave,pos={100,470},size={160,20},proc=ASAS_ButtonProc,title="Edit Alpha Dist"
	Button ASASPop4GetAlphaWave,help={"This button creates table of alpha probablity for user to edit"}

	SetVariable ASASPop4PAlphaPar1,pos={16,460},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 1"
	SetVariable ASASPop4PAlphaPar1,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_PAlphaPar1, help={"Parameters 1 for P alpha"}
	CheckBox ASASPop4FitPAlphaPar1,pos={168,462},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop4FitPAlphaPar1,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop4PAlphaPar1Min,pos={223,460},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop4PAlphaPar1Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_PAlphaPar1Min
	SetVariable ASASPop4PAlphaPar1Max,pos={290,460},size={100,16},proc=ASAS_SetVarProc,title=" < PA1 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop4PAlphaPar1Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_PAlphaPar1Max
	SetVariable ASASPop4PAlphaPar2,pos={16,480},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 2"
	SetVariable ASASPop4PAlphaPar2,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_PAlphaPar2, help={"Parameters 2 for P alpha"}
	CheckBox  ASASPop4FitPAlphaPar2,pos={168,482},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox  ASASPop4FitPAlphaPar2,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop4PAlphaPar2Min,pos={223,480},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop4PAlphaPar2Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_PAlphaPar2Min
	SetVariable ASASPop4PAlphaPar2Max,pos={290,480},size={100,16},proc=ASAS_SetVarProc,title=" < PA2 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop4PAlphaPar2Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_PAlphaPar2Max
	SetVariable ASASPop4PAlphaPar3,pos={16,500},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 3"
	SetVariable ASASPop4PAlphaPar3,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_PAlphaPar3, help={"Parameters 3 for P alpha"}
	CheckBox ASASPop4FitPAlphaPar3,pos={168,502},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop4FitPAlphaPar3,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop4PAlphaPar3Min,pos={223,500},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop4PAlphaPar3Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_PAlphaPar3Min
	SetVariable ASASPop4PAlphaPar3Max,pos={290,500},size={100,16},proc=ASAS_SetVarProc,title=" < PA3 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop4PAlphaPar3Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_PAlphaPar3Max

	SetVariable ASASPop4BOmegaSteps,pos={16,520},size={180,16},proc=ASAS_SetVarProc,title="Probab. Omega steps"
	SetVariable ASASPop4BOmegaSteps,limits={10,Inf,1},value= root:Packages:AnisoSAS:Pop4_BOmegaSteps, help={"How many steps (bins) in Probablility over omega you want to use?"}
	CheckBox ASASPop4UseBOmegaParam,pos={210,522},size={21,14},proc=ASAS_CheckProc,title="Use Parameters for B omega"
	CheckBox ASASPop4UseBOmegaParam,value= 0, help={"Check if you want to use B omega parameters, if not fill in table manually"}
	Button ASASPop4GetOmegaWave,pos={100,550},size={160,20},proc=ASAS_ButtonProc,title="Edit Omega Dist"
	Button ASASPop4GetOmegaWave,help={"This button creates table of omega probablity for user to edit"}

	SetVariable ASASPop4BOmegaPar1,pos={16,540},size={130,16},proc=ASAS_SetVarProc,title="B omega par 1"
	SetVariable ASASPop4BOmegaPar1,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_BOmegaPar1, help={"Parameters 1 for B Omega"}
	CheckBox ASASPop4FitBOmegaPar1,pos={168,542},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop4FitBOmegaPar1,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop4BOmegaPar1Min,pos={223,540},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop4BOmegaPar1Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_BOmegaPar1Min
	SetVariable ASASPop4BOmegaPar1Max,pos={290,540},size={100,16},proc=ASAS_SetVarProc,title=" < BO1 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop4BOmegaPar1Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_BOmegaPar1Max
	SetVariable ASASPop4BOmegaPar2,pos={16,560},size={130,16},proc=ASAS_SetVarProc,title="B omega par 2"
	SetVariable ASASPop4BOmegaPar2,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_BOmegaPar2, help={"Parameters 2 for B Omega"}
	CheckBox  ASASPop4FitBOmegaPar2,pos={168,562},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox  ASASPop4FitBOmegaPar2,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop4BOmegaPar2Min,pos={223,560},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop4BOmegaPar2Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_BOmegaPar2Min
	SetVariable ASASPop4BOmegaPar2Max,pos={290,560},size={100,16},proc=ASAS_SetVarProc,title=" < BO2 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop4BOmegaPar2Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_BOmegaPar2Max
	SetVariable ASASPop4BOmegaPar3,pos={16,580},size={130,16},proc=ASAS_SetVarProc,title="B omega par 3"
	SetVariable ASASPop4BOmegaPar3,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_BOmegaPar3, help={"Parameters 3 for B Omega"}
	CheckBox ASASPop4FitBOmegaPar3,pos={168,582},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop4FitBOmegaPar3,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop4BOmegaPar3Min,pos={223,580},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop4BOmegaPar3Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_BOmegaPar3Min
	SetVariable ASASPop4BOmegaPar3Max,pos={290,580},size={100,16},proc=ASAS_SetVarProc,title=" < BO3 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop4BOmegaPar3Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop4_BOmegaPar3Max

	SetVariable ASASPop4SurfaceArea,pos={20,605},size={180,16},proc=noproc,title="Surface area", help={"Surface area of this population in cm2/cm3"}
	SetVariable ASASPop4SurfaceArea,limits={0,Inf,0},value= root:Packages:AnisoSAS:Pop4_SurfaceArea
	CheckBox ASASPop4UseInterference,pos={240,605},size={21,14},proc=ASAS_CheckProc,title="Interference?"
	CheckBox ASASPop4UseInterference,variable=root:Packages:AnisoSAS:Pop4_UseInterference, help={"Check if you want to use interference for this population"}
//Population 5
	SetVariable ASASPop5DeltaRho,pos={24,358},size={190,16},proc=ASAS_SetVarProc,title="Delta rho [cm-2] "
	SetVariable ASASPop5DeltaRho,value= root:Packages:AnisoSAS:Pop5_DeltaRho, help={"Insert delat rho (NOT delat rho squared!!!) for this population"}
	SetVariable ASASPop5Beta,pos={249,359},size={100,16},proc=ASAS_SetVarProc,title="Beta: "
	SetVariable ASASPop5Beta,limits={0.05,20,0.1},value= root:Packages:AnisoSAS:Pop5_Beta, help={"Aspect ratio for this population. beta >1 - cigar like shape, beta<1 doughnut like shape"}
	SetVariable ASASPop5Radius,pos={16,400},size={130,16},proc=ASAS_SetVarProc,title="Radius [A]  "
	SetVariable ASASPop5Radius,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop5_Radius, help={"Radius of this population in A"}
	CheckBox ASASPop5FitRadius,pos={168,402},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop5FitRadius,value= 0, help={"Check if Radius should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop5RadiusMin,pos={223,400},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this population, this is MINIMUM"}
	SetVariable ASASPop5RadiusMin,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop5_RadiusMin
	SetVariable ASASPop5RadiusMax,pos={290,400},size={100,16},proc=ASAS_SetVarProc,title=" <  R  <  ", help={"Fitting limits of this population, this is Maximum"}
	SetVariable ASASPop5RadiusMax,limits={10,Inf,100},value= root:Packages:AnisoSAS:Pop5_RadiusMax

	SetVariable ASASPop5VolumeFraction,pos={16,420},size={130,16},proc=ASAS_SetVarProc,title="Volume Fract"
	SetVariable ASASPop5VolumeFraction,limits={0.00001,1,0.02},value= root:Packages:AnisoSAS:Pop5_VolumeFraction, help={"Volume fraction of this population"}
	CheckBox ASASPop5FitVolumeFraction,pos={168,422},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop5FitVolumeFraction,value= 0, help={"Check if Volume Fraction should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop5VolumeFractionMin,pos={223,420},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this population, this is MINIMUM"}
	SetVariable ASASPop5VolumeFractionMin,limits={0,1,0.02},value= root:Packages:AnisoSAS:Pop5_VolumeFractionMin
	SetVariable ASASPop5VolumeFractionMax,pos={290,420},size={100,16},proc=ASAS_SetVarProc,title=" <  V  <  ", help={"Fitting limits of this population, this is Maximum"}
	SetVariable ASASPop5VolumeFractionMax,limits={0,1,0.02},value= root:Packages:AnisoSAS:Pop5_VolumeFractionMax

	SetVariable ASASPop5PAlphaSteps,pos={16,440},size={180,16},proc=ASAS_SetVarProc,title="Probab. Alpha steps"
	SetVariable ASASPop5PAlphaSteps,limits={10,Inf,1},value= root:Packages:AnisoSAS:Pop5_PAlphaSteps, help={"How many steps (bins) in Probablility over alpha you want to use?"}
	CheckBox ASASPop5UsePAlphaParam,pos={210,442},size={21,14},proc=ASAS_CheckProc,title="Use Parameters for P alpha"
	CheckBox ASASPop5UsePAlphaParam,value= 0, help={"Check if you want to use P alpha parameters, if not fill in table manually"}
	Button ASASPop5GetAlphaWave,pos={100,470},size={160,20},proc=ASAS_ButtonProc,title="Edit Alpha Dist"
	Button ASASPop5GetAlphaWave,help={"This button creates table of alpha probablity for user to edit"}

	SetVariable ASASPop5PAlphaPar1,pos={16,460},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 1"
	SetVariable ASASPop5PAlphaPar1,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_PAlphaPar1, help={"Parameters 1 for P alpha"}
	CheckBox ASASPop5FitPAlphaPar1,pos={168,462},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop5FitPAlphaPar1,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop5PAlphaPar1Min,pos={223,460},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop5PAlphaPar1Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_PAlphaPar1Min
	SetVariable ASASPop5PAlphaPar1Max,pos={290,460},size={100,16},proc=ASAS_SetVarProc,title=" < PA1 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop5PAlphaPar1Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_PAlphaPar1Max
	SetVariable ASASPop5PAlphaPar2,pos={16,480},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 2"
	SetVariable ASASPop5PAlphaPar2,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_PAlphaPar2, help={"Parameters 2 for P alpha"}
	CheckBox  ASASPop5FitPAlphaPar2,pos={168,482},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox  ASASPop5FitPAlphaPar2,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop5PAlphaPar2Min,pos={223,480},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop5PAlphaPar2Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_PAlphaPar2Min
	SetVariable ASASPop5PAlphaPar2Max,pos={290,480},size={100,16},proc=ASAS_SetVarProc,title=" < PA2 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop5PAlphaPar2Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_PAlphaPar2Max
	SetVariable ASASPop5PAlphaPar3,pos={16,500},size={130,16},proc=ASAS_SetVarProc,title="P alpha par 3"
	SetVariable ASASPop5PAlphaPar3,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_PAlphaPar3, help={"Parameters 3 for P alpha"}
	CheckBox ASASPop5FitPAlphaPar3,pos={168,502},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop5FitPAlphaPar3,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop5PAlphaPar3Min,pos={223,500},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop5PAlphaPar3Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_PAlphaPar3Min
	SetVariable ASASPop5PAlphaPar3Max,pos={290,500},size={100,16},proc=ASAS_SetVarProc,title=" < PA3 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop5PAlphaPar3Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_PAlphaPar3Max

	SetVariable ASASPop5BOmegaSteps,pos={16,520},size={180,16},proc=ASAS_SetVarProc,title="Probab. Omega steps"
	SetVariable ASASPop5BOmegaSteps,limits={10,Inf,1},value= root:Packages:AnisoSAS:Pop5_BOmegaSteps, help={"How many steps (bins) in Probablility over omega you want to use?"}
	CheckBox ASASPop5UseBOmegaParam,pos={210,522},size={21,14},proc=ASAS_CheckProc,title="Use Parameters for B omega"
	CheckBox ASASPop5UseBOmegaParam,value= 0, help={"Check if you want to use B omega parameters, if not fill in table manually"}
	Button ASASPop5GetOmegaWave,pos={100,550},size={160,20},proc=ASAS_ButtonProc,title="Edit Omega Dist"
	Button ASASPop5GetOmegaWave,help={"This button creates table of omega probablity for user to edit"}

	SetVariable ASASPop5BOmegaPar1,pos={16,540},size={130,16},proc=ASAS_SetVarProc,title="B omega par 1"
	SetVariable ASASPop5BOmegaPar1,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_BOmegaPar1, help={"Parameters 1 for B Omega"}
	CheckBox ASASPop5FitBOmegaPar1,pos={168,542},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop5FitBOmegaPar1,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop5BOmegaPar1Min,pos={223,540},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop5BOmegaPar1Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_BOmegaPar1Min
	SetVariable ASASPop5BOmegaPar1Max,pos={290,540},size={100,16},proc=ASAS_SetVarProc,title=" < BO1 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop5BOmegaPar1Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_BOmegaPar1Max
	SetVariable ASASPop5BOmegaPar2,pos={16,560},size={130,16},proc=ASAS_SetVarProc,title="B omega par 2"
	SetVariable ASASPop5BOmegaPar2,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_BOmegaPar2, help={"Parameters 2 for B Omega"}
	CheckBox  ASASPop5FitBOmegaPar2,pos={168,562},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox  ASASPop5FitBOmegaPar2,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop5BOmegaPar2Min,pos={223,560},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop5BOmegaPar2Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_BOmegaPar2Min
	SetVariable ASASPop5BOmegaPar2Max,pos={290,560},size={100,16},proc=ASAS_SetVarProc,title=" < BO2 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop5BOmegaPar2Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_BOmegaPar2Max
	SetVariable ASASPop5BOmegaPar3,pos={16,580},size={130,16},proc=ASAS_SetVarProc,title="B omega par 3"
	SetVariable ASASPop5BOmegaPar3,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_BOmegaPar3, help={"Parameters 3 for B Omega"}
	CheckBox ASASPop5FitBOmegaPar3,pos={168,582},size={21,14},proc=ASAS_CheckProc,title=" "
	CheckBox ASASPop5FitBOmegaPar3,value= 0, help={"Check if P alpha  should be varied when doing least sqaure fitting. Set properly the limits!!!"}
	SetVariable ASASPop5BOmegaPar3Min,pos={223,580},size={60,16},proc=ASAS_SetVarProc,title=" ", help={"Fitting limits of this parameter, this is MINIMUM"}
	SetVariable ASASPop5BOmegaPar3Min,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_BOmegaPar3Min
	SetVariable ASASPop5BOmegaPar3Max,pos={290,580},size={100,16},proc=ASAS_SetVarProc,title=" < BO3 <  ", help={"Fitting limits of this parameter, this is Maximum"}
	SetVariable ASASPop5BOmegaPar3Max,limits={0,Inf,1},value= root:Packages:AnisoSAS:Pop5_BOmegaPar3Max

	SetVariable ASASPop5SurfaceArea,pos={20,605},size={180,16},proc=noproc,title="Surface area", help={"Surface area of this population in cm2/cm3"}
	SetVariable ASASPop5SurfaceArea,limits={0,Inf,0},value= root:Packages:AnisoSAS:Pop5_SurfaceArea
	CheckBox ASASPop5UseInterference,pos={240,605},size={21,14},proc=ASAS_CheckProc,title="Interference?"
	CheckBox ASASPop5UseInterference,variable=root:Packages:AnisoSAS:Pop5_UseInterference, help={"Check if you want to use interference for this population"}

EndMacro


//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 
//*********************************************************************************************************************** 

Function/T ASAS_GenStringOfFolders(UseMSASDta)
	variable UseMSASDta

	setDataFolder root:Packages:AnisoSAS
	
	//	if UseMSASDta = 1 we are using M_DSM data, else return folders with DSM data 
	string result
	if (UseMSASDta)
		result=IN2G_FindFolderWithWaveTypes("root:USAXS:", 10, "*M_DSM*", 1)
	else
		result=IN2G_FindFolderWithWaveTypes("root:", 10, "*DSM*", 1)
	endif
	
	return result
end


Function/T ASAS_GenStringOfAnisoFolders()
	variable UseMSASDta

	setDataFolder root:Packages:AnisoSAS
	
	//	if UseMSASDta = 1 we are using M_DSM data, else return folders with DSM data 
	string result
//	if (UseMSASDta)
	result=IN2G_FindFolderWithWaveTypes("root:Others:", 10, "*", 1)
	if (strlen(result)==0)
		result="---"
	endif
//	else
//		result=IN2G_FindFolderWithWaveTypes("root:", 10, "DSM", 1)
//	endif
	
	return result
end
