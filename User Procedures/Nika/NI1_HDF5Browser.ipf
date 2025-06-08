#pragma TextEncoding="UTF-8"
#pragma rtGlobals=3 // Use modern global access method.
#pragma version=1.02

//1.02 modified 2022-11-06 to handle 1st 2-3D data set in the file, difficult to support more flexible method.
//1.01 modified to compile when hdf5 xop is not available.
// 1.0 initial release. Not working yet, but need to go ahead with release.
//This is modified version of HDF5 Browser.ipf version 1.03 modified for use with Nika package by jan Ilavsky, January 2011
// ilavsky@aps.anl.gov
//this will provide limited functionality to provide user with ability to select for Nika which data to load and how.

//Menu "testing"
//	"New HDF5 Browser", /Q, NI2_CreateNewHDF5Browser("Nika")
//End

//**********************
//       this is the main function called by Nika or Irena to load general hdf file...

