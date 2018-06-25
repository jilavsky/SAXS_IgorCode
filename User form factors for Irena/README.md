## User form factors for Modeling tool

These are user contributed - or requested - form factors for use in "User Form factor" in Modeling package in Irena. 
To use:
1. Download the ipf file you need - click on the file, it opens in new type of view, now click in the right corner of the frame button "Raw", opens in text view. Now "Save as" from your browser File menu and save as text file with extension ipf (remove .txt browsers attach.) 
2. Open this ipf file in Igor Experiment where you want to use it. Either double click with Igor Pro opened, or in Igor pro go to File menu, Open File, Procedure... 
3. Keep the ipf file in that experiment, if needed minimize, do NOT kill
4. Follow these instructions below to setup that specific Form factor


#Core Shell Ellipsoid, June 2018
This is modified version of NIST CoreShellEllipsoid, created by Jan Ilavsky in June 2018. Original author is Steven Kline from NIST. 
To use Open this file in Experiment where you want to use it (and keep it there, if needed minimize, do NOT kill) and follow these instructions:
USE in Irena :
* In Modeling II select User form factor 
//In panel put in "Name of ForFactor function this string:    IR1T_EllipsoidalCoreShell
//In Panel put in Name of volume FF function this string:     IR1T_EllipsoidalVolume
//
// Par1 is the aspect ratio which for ellipsoids are defiend as rotational objects with dimensions R x R x AR*R, note, AR=1 may fail. 
// par 2 is shell thickness in A, and it is the same thickness everywhere on the ellipsoid. 
// par3, 4 and 5 are contrasts as this is core shell system and contrasts are part of the form factor. 
// par3, 4 and 5 are implicitelyu multipled by 10^10cm^-2, so insert only a number. These are rhos not, delta-rho-square
// In main panel set contrast = 1 !!!!! Contrasts are part of the form factor in this case. 
//*************************************************************************************************
//*************************************************************************************************


#Flexible Cylinder, June 2018
This is modified version of NIST Flexible Cylinder, created by Jan Ilavsky in June 2018. Original author is Steven Kline from NIST. 
//*************************************************************************************************
//*************************************************************************************************
//USE in Irena :
//In Modeling II select User form factor 
//In panel put in "Name of ForFactor function this string:    IR1T_FlexExclVolCyl
//In Panel put in Name of volume FF function this string:    IR1T_FlexExclVolCylVol
//
// Parameter 1 is the length of the cylinder
// Parameter 2 is the Kuhn length
// other parameters are not being used. 
//*************************************************************************************************
//*************************************************************************************************
