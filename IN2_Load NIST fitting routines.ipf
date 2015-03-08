#pragma rtGlobals=1		// Use modern global access method.

//requires that "SANS_Models" are stored in the User Procedures Folder
//subfolders are permitted

//Indra 2 interface procedure
#include "IN2_NISTFittingRoutines"
#include "IN2_GeneralProcedures"

//utility procedures
#include "PlotUtilsMacro"
#include "GaussUtils"
#include "WriteModelData"

//RPA, polyelectrolyte
#include "SmearedRPA"
#include "BE"
//two-phase models
#include "DAB_model"
#include "Teubner"
#include "Lorentz_model"
#include "Peak_Gauss_model"
#include "Peak_Lorentz_model"
#include "Power_Law_model"
//form factors
#include "sphere"
#include "CoreShell"
#include "PolyCore"
#include "PolyCoreShellRatio"
#include "RectPolySpheres"
#include "PolyHSInt"
#include "UniformEllipsoid"
#include "OblateForm"
#include "ProlateForm"
#include "CylinderForm"
#include "CoreShellCylinder"
#include "HollowCylinders"
//structure factors
#include "HardSphereStruct"
#include "HPMSA"
#include "SquareWellStruct"
//P*S combinations
#include "EffectiveDiameter"
#include "Sphere_and_Struct"
#include "CoreShell_and_Struct"
#include "PolyRectSphere_and_Struct"
#include "Cylinder_and_Struct"
#include "OblateCS_and_Struct"
#include "ProlateCS_and_Struct"
#include "PolyCore_and_Struct"
#include "PolyCSRatio_and_Struct"
#include "UnifEllipsoid_and_Struct"


Menu "NIST Models"
	"LoadOneDData"
	"WriteModelData"
	"SANS Analysis Help"
	"-"
	Submenu "Particle Models"
		"PlotSphereForm"
		"PlotEllipsoidForm"
		"PlotCylinderForm"
		"PlotCoreShellSphere"
		"PlotProlateCSForm"
		"PlotOblateCSForm"
		"PlotCoreShellCylinderForm"
		"PlotHollowCylinderForm"
		"-"
		"PlotPolyCoreForm"
		"PlotPolyCoreShellRatio"
		"PlotPolyRectSpheres"
		"PlotPolyHardSpheres"
		"-"
		"PlotSmearedSphereForm"
		"PlotSmearedEllipsoidForm"
		"PlotSmearedCylinderForm"
		"PlotSmearedCoreShellSphere"
		"PlotSmearedProlateCSForm"
		"PlotSmearedOblateCSForm"
		"PlotSmearedCSCylinderForm"
		"PlotSmearedHollowCylinderForm"
		"PlotSmearedPolyCoreForm"
		"PlotSmearedPolyCoreShellRatio"
		"PlotSmearedPolyRectSpheres"
		"PlotSmearedPolyHardSpheres"
	End
	Submenu "Structure Factors"
		"PlotHardSphereStruct"
		"PlotSquareWellStruct"
		"PlotHayterPenfoldMSA"
	End
	"-"
	Submenu "P * Hard Sphere Models"
		"Sphere * HS",PlotSphere_HS()
		"CoreShellSphere * HS", PlotCoreShell_HS()
		"Poly Core w_Shell * HS", PlotPolyCore_HS()
		"Poly Core_Shell Ratio * HS", PlotPolyCSRatio_HS()
		"Rect Distr of Spheres * HS", PlotPolyRectSphere_HS()
		"-"
		"Uniform Ellipsoid * HS", PlotEllipsoid_HS()
		"Oblate C_S Ellipsoid * HS", PlotOblate_HS()
		"Prolate C_S Ellipsoid * HS", PlotProlate_HS()
		"Cylinder * HS", PlotCylinder_HS()
	End
	Submenu "P * Square Well Models"
		"Sphere * SW",PlotSphere_SW()
		"CoreShellSphere * SW", PlotCoreShell_SW()
		"Poly Core w_Shell * SW", PlotPolyCore_SW()
		"Poly Core_Shell Ratio * SW", PlotPolyCSRatio_SW()
		"Rect Distr of Spheres * SW", PlotPolyRectSphere_SW()
		"-"
		"Uniform Ellipsoid * SW", PlotEllipsoid_SW()
		"Oblate C_S Ellipsoid * SW", PlotOblate_SW()
		"Prolate C_S Ellipsoid * SW", PlotProlate_SW()
		"Cylinder * SW", PlotCylinder_SW()
	End
	Submenu "P * Screened Coulomb Models"
		"Sphere * SC",PlotSphere_SC()
		"CoreShellSphere * SC", PlotCoreShell_SC()
		"Poly Core w_Shell * SC", PlotPolyCore_SC()
		"Poly Core_Shell Ratio * SC", PlotPolyCSRatio_SC()
		"Rect Distr of Spheres * SC", PlotPolyRectSphere_SC()
		"-"
		"Uniform Ellipsoid * SC", PlotEllipsoid_SC()
		"Oblate C_S Ellipsoid * SC", PlotOblate_SC()
		"Prolate C_S Ellipsoid * SC", PlotProlate_SC()
		"Cylinder * SC", PlotCylinder_SC()
	End
	"-"
	Submenu "Ten RPA Cases"
		"PlotRPAForm"
		"-"
		"PlotSmearedRPAForm"
	End
	Submenu "Polyelectrolyte model"
		"PlotBE"
		"-"
		"PlotSmearedBE"
	End
	"-"
	Submenu "Two-Phase Models"
		"PlotDAB"
		"Plot_Lorentz"
		"PlotPeak_Gauss"
		"PlotPeak_Lorentz"
		"PlotPower_Law"
		"PlotTeubnerStreyModel"
		"-"
		"PlotSmearedDAB"
		"PlotSmeared_Lorentz"
		"PlotSmearedPeak_Gauss"
		"PlotSmearedPeak_Lorentz"
		"PlotSmearedPower_Law"
		"PlotSmearedTeubnerStreyModel"
	End
End

Function SANSAnalysisHelp()
	DoAlert 0,"You'll find the SANS Help in the Help Browser, under the Windows Menu."
	//DisplayHelpTopic/K=1 "SANS Data Reduction Tutorial"
End