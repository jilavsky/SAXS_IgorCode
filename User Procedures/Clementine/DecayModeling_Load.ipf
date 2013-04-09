#pragma rtGlobals=1		// Use modern global access method.
#pragma version=1.00

// This is part of package called "Clementine" for modeling of decay kinetics using Maximum Entropy method
// Jan Ilavsky, PhD June 1 2008
// 

#include "DecayModeling_GUI", version>=1
#include "DecayModeling_1", version>=1
#include "DecayModeling_2", version>=1
#Include "MaxEntPackage", version>=1

Menu "Macros"
	"MEM Decay fitting", DecJIL_mainFunction()
end
