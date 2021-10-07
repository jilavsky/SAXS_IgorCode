****  I n d r a  *****

USAXS - data reduction macros.

Jan Ilavsky, ilavsky@aps.anl.gov

************************************
This set of macros is developed for data reduction of USAXS data obtained on APS USAXS instrument beamline instrument. 
It runs on Wavemetrics Igor Pro version 8.04 and higher.


Modification history:
_____________________________________________________________________________________
1.99 10/10/2021
Fixed all fixed length wave names (hopefully). Now should use long names if user chooses so in Configuration for all waves and folders. 
Sample Survey tool -  multiple row selection enabled, Clipboard now handles multiple rows. Manual updated. Added ability to import image from jpg/tiff/gif... files
Minor changes to various setting to make user life easier.
Step scanning in BlueSky (uses Nexus file) now fully supported and well tested. 


1.98 9/3/2020
Require Igor 8.03 or higher. 
Added "Smart select Blank" for selection of Blank measured BEFORE the sample measurements. 
DataBrowser - Igor 8 - added Buttons to display w1 vs w2 and extract info from USAXS Folder name strings. Same tools are in Igor 9 right click. 
Added for every graph right click option to export as jpg and pxp. Also to duplicate graph (which Igor does on ctrl/cmd-D) but with duplicate of all data in the graph. 1D graphs only.  
Added new samplePlate tool for users to prepare command files.  
Working on step scan data reduction from BlueSky, it is not tested yet. Needs another round of development of both data collection and code development. 


1.97 2/9/2020
Many tools - changed code compiler instruction to rtGLobals=3, this is less forgiving compile which prevents more accidental bugs, but may generate new errors in old code. Report as many errors as possible to author, please.  
Added ability of Flyscanniong data reduction to guess minimum useable q for data reduction. Based on intensity ratio between sample and blank - note, it is q dependent ratio. Black magic.  
Changed default number of USAXS points to 500, seems reasonable now. 


1.96  12/5/2018
Igor 8 OSX XOPs now available. version 2.0 of 64-bit xops. 
Modified "Configure GUI..." menu name and added warning on name shortening. Should generate dialog when names are too long and users are not using Igor 8 with long names enabled. Only once per Igor experiment.  
Added checkbox to use for calibration FWHM of sample and not Blank. Variability of Blanks adds to uncertainty of the absolute intensity calibration. Usually sample FHWM is better measure of Solid angle. Will be overwritten if sample FWHM is too large (Multiple scattering). 
Improved on negative background subtractions... 
Added ability to overwrite Flyscan amplifier dead times. 
Fixed problem with color scale for amplifiers not showing correctly. 


1.95  7/7/2018
Igor 8.0 tested. 
Modified behavior of Automatic blank selection in GUI. 

1.94 1/27/2018
Converted all procedure files to UTF8 to prevent text encoding issues. 
Fixed Case spelling of USAXS Error data to SMR_Error and DSM_Error.
Added ability to smooth R_Int data - suitable mostly for Blank where it removes noise from the blank. Should reduce noise of the USAXS data. 
Added masking options into FLyscan panel Listbox. 
Checked that - with reduced functionality - code will work without Github distributed xops. 
Tested and fixed for Igor 8 beta version. 


1.93 11/05/2017
Promoted required minimum version to 7.05 due to bug in Igor prior of this version. 
Added restore of prior size of panels when user closes and reopens a tool. Data stored in the current Igor experiment. Size limited to 50% width and 90% height. Hold down any modifier key and size will be reset to original default state. 
Added Desmearing to Data reduction as final step. Saves both SMR and DSM data. Contains much less choices as USAXS is reasonably stable and choices are known. May fail for border cases. 
Added UserSamplename string to each folder for long names. 
Removed pdf manual from distribution.It is obsolete, use on-line version and if needed, download pdf from the on-line source.  



1.92 5/1/2017 
Made Igor 7 compatible ONLY. Thanks to GeneralProcedures changes will not work on Igor 6. 

1.91 5/1/2017
Version 1.90 updated, Igor 6 release. 

1.90 2/22/2017
Modified Nexus support, added new library to use it. 
Removed Utility_JZT from distribution, not needed and causing conflict with JZT package. `
Added OverRideSampleThickness where user can set new sample thickness for range of samples. Set to 0 to ignore. 
Added Live processing of data same as Nika has.
Fixed internal bug which caused problems when dark current on UPD was measured too high. 
Added overwrite for Dark current 5 
Added overwrite for sample thickness
Fixed slow down caused by debugging messages function.
Fixed up readme and reorganized menu to make it easier to find important items.  


1.89 6/29/2016
Due to some new features used, requires Igor 6.34 or higher
New - can load and process FLyscan data directly, single step process now. No manual yet. Use Import & reduce data. 
Modification for Flyscans in 2016-02
Re-casted internally use of folders, this is likely incompatible change backwards, so you need to reopen the Data reduction in old experiments. 
Removed some obsolete code (like X23A3 support, no data were collected since 1998). 

1.88 3/5/3016
Added panel scaling on most large panels
Fixed bug for names which were liberal - e.g. with decimal point in name. Was failing to load them.
Added ability to remove string from data set name similar to Nika to shorten sensibly the names to 32 characters Igor is using. 
Added multi-package loaders (Indra+Irena+Nika, Indra+Irena, etc.)


1.87 2/1/2016
Igor 7 beta update

1.86 10/30/2015
Verified to work on Igor 7 beta 1
Revised manual - it was really obsolete. Added Flyscan import, updated Data reduction and removed some obsolete stuff from the manual altogether. Added chapter on dQ. 
Added FLyscan dropouts removal code to remove weird dropouts in intensity which seem to happen sometimes. 
Added new wave to data - SMR_dQ (and DSM etc), which contains per pixel smearing value. It is combination of racking curve width (Gauss profile) smearing given by USAXS resolution and, for flyscans, bin width over which the bin in q is created (rectangular profile).  
Fixed case when spec file name was too long and Igor erred since the folder name was too long. Trim to 30 characters when needed. 


1.85 3/8/2015
Modifications for 2D flyscans. 
Fixed for 9ID USAXS and the flyscans there. 

1.84 8/20/2014
Created on log-rebinning routine and propagated that routine (General Procedures 1.71) through the system, mainly FLyScan, replacing all log-rebinning other routines.
Major development to handle Flyscan data, should handle all data up to August 2014.
Added ability to overwrite range 5 dark current for all imported data (sometimes needed).
Small other improvements in GUI and data handling. 

1.83 4/18/2014
Flyscan updated support to support Flyscans from April 2014
Read comments from spec file now can use Grepstring to pull only specific lines from the spec file (kind of work as grep on the spec file). 

1.82 2/20/2014
FlyScan support, firs user suitable version. 
Added Remove points with marquee option
Made pinUSAXS transmission use default. 

1.81 1/1/2014
First release with FlyScan support. Development version. 


1.80 1/5/2014
Added support of FlyUsaxs scans based on data collected 12/2013. 
Change in size of error bars, the old one are simply too large. Step scan reduced by ~5, fly scan reduced by 3. Will need to be changed. 
Added version control for panels
Modified Readme to match better current state
Added Copyright message


1.79 4/24/2013
Added ability to use pinDiode Transmission for USAXS measured first time in April 2013. 

1.78 4/8/2013
Added calibration to weight, can calculate weight of sample in the beam, and can use transmission to calculate also thickness of 100% dense sample. Therefore it can use area of the beam with transmission, line absorption coefficient and density of the material for  cm2/g calibration. 
Modified to compile on computers even without xop and abort & produce message when xop is called with instructions. 


1.77 11/5/2012
Added I0_gain to the data reduction so the gain of I0 can be changing during scan. 

1.76 5/30/2012
Added controls for selection of default peak fitting function.
Fixed error calculations which did not work properly when using I0 gain. 
Tweaked MSAXS start/end search transfer to make more robust and minimize limits creep.  

1.75 4/30/2012
Modifications for auto ranging I0. Added I0_gain column to spec and now using it when available to avoid stale I0_gain in spec header.  
Changes step when matching q shifts to 10x smaller. 

1.74 2/27/2012
Added more button to the top of the R_Int graph and added option to fix the PD range.
Added fix for bad points when coming up. 

1.73 2/19/2012
Changed how the loader works. Now the loader will look for files relatively related tho the loader files itself. This should enable in the future having multiple Irena packages installed and be able to switch among them. I am not sure why would any user need to have it, but I need it myself for debugging purposes… 
Modified Calculations to handle scanning down (typical) but also up (for GISAXS for example). 

1.72 7/6/2010
IN3_modifiedGauss added constraint to keep one of the parameters large enough to prevent unreasonable peak shapes. 
Added fix for lost communication with Monochromator which happened on 15ID sometimes. Set to 12keV as default and added error message.
Removed CursorMovedHook function to avoid conflicts, converted to Window hook functions when necessary

1.71 7/11/2009
Added calculator to estimate scattering above USAX background when scattering intensity for model is available from some Irena tools. Need also thickness and transmission. 

1.70 7/8/2009
Change in Mac code to show all files in dialog for spec files. Apparently they are not TEXT files, cannot figure out what they are (TextWrangler type?).
Added Modified Gauss peak profile and made it default.
Fixed remembering of cursor position for starting Q  for subtracting data. Now uses not point position, but Q position and should be preserved to what was the last value used in previous correction. 
Note: Igor 6.04 on Windows has a bug, which causes problems in data reduction. Use different version of Igor - to update, use unreleased version 6.05: http://www.wavemetrics.net/Updaters/IgorPro6.05Beta01.zip.


December 2, 2007, version 1.62
Update needed for change in Common Control procedures. The change in Irena data selection procedures required slight modification in use in Indra package. No other change. 


August 20, version 1.61
Removed bug when MSAXS correction failed after user used different tool and changed folder.
Modified Desktop loader for David Londono - added option to use file name as sample name and changed the selection method to allow easy multiple file selection with shift-click.
Made compatible with Igor 5.05 and higher. (MSAXS graph fix)
Removed bug when MSAXS graph was showing at wrong time.
Fixed position of the main graph and main panel.   

July 15, 2007, version 1.60
Main release of the new USAXS reduction procedure. Still Only Igor 6.0 compatible. 

May 17, 2007, version 1.51
Fixed bug in Rigaku/Osmic data support created by new reduction panel. 

April 17, 2007, version 1.50
Added whole new main panel in which reduction is doen in one step (more or less). Same panel used for Blank and sample. Resulted in some changes to wave names and at this time may be breaking some older code functionality. Also, only Igor 6 compatible. 


October 18, 2006, version 1.42 
Changed dialog which appears when user does not save R data and wants to continue to more easy to understand and easie to use...
Changes place where Indra stores temporary files to allow users to run as no-privileges user who has no rights to write into Program files folder.
Add button to reload same spec file to Spec import panel. 

August 2006, version 1.41
Patch for non linearity of the USAXS diode system observed in AUgust 2006. Will check if needed and if so, it will put out dialog with the correction factor. Default should be OK, but for details talk to me... 

April 7, 2006 version 1.40
Desmearing - added some more controls to 1. load Irena desmearing (if present), 2. load Irena package (if present in Igor but not loaded) and start desmeraing, 3. Tell user where to go for the Irena package. 
Included beta version of loader data for Osmic/Rigaku Desktop USAXS instrument. For proer function need new data format, but should work with limitations with the old one too...
Few minor changes to improve stability of displaying peak on lin-lin plot in Subtract Blank from Sample
Removed Autofit Gauss - did not work...

1.30a and 1.30b
Needed to make minor changes due to changes in the IN2_generalProcedures package.
Attempting to do better in peak height/width calculations. Not much improvement...
Modified subtract sample and blank routine to avoid any chance of user accidentally leaving the sample thickness 0 mm, which was causing lately problems. 
Added I0 dark current in the calculations. It is now available, let's use it. 


December 1, 2003, release 1.30
Redesigned Spec import data tool to use panel, not old style dialogs. Should avoid some user confusions. See the manual for use. 
Fixed minor bug in Plot with Math, which caused problems when graph did not exist and user tried to change their setting.
Fixed minor bug in convert Raw to non-USAXS, which caused problem with generation of folder names under some conditions...


October 23, 2003, release 1.27a
Update of spec.ipf. Add requested feature. No other changes.

October 23, 2003, release 1.27
Minor update:
Moved all menu items to one, use submenus. Should save some space for users on the screen.
Fixed desmearing bug, which caused crash when user dropped cursor on wrong wave.
Minor patches.

May 12, 2003, release 1.25
Minor update:
Minor fix for AnisoScans used in SBUSAXS. Now scales the data to range 1 (* 10^8). This is so the data from different aniso scans can be compared together. Note, no attempt to scale for other calibration parameters is attempted...

January 1, 2003, release 1.24
Minor updates:
Desmearing update for export of waves from within the routine. Previous code failed with data different than DSM, new fix should export also M_DSM data and any name data.
Minor modification of panel where user selects the spec wave names. 
Modification of Standard Plots, which should now allow displaying data types of differnet types... Sorrely needed function.

October 18, 2002, release 1.23
Few minor updates and bug fixes. Nothing major. Removed Sizes part and moved to Irena 1 where it is with new GUI. 

March 1, 2002, release 1.20 
Larger change so skipped few numbers here...
This is update, in which I had to make General Procedures incompatible with both Indra2 and Irena 1 previous versions. Combination with old Irena 1 and Indra 2 will not compile... Therefore users of both packages MUST update both at the same time - now...
Some usual bug fixes:
1. Major change in desmearing routine, removed "fast" method and modified parts of the extrapolation, made input using cursors...
2. Added some features in R wave creation. Fixed few bugs, which were not too bad, but annoying. 
 
January 30, 2002 release 1.17
Maintanance release, minor change. Fix for yet unused piece of code - merging different data sets. Minor change with look of one graph (R_wave creation).

December 8, 2001 release 1.16
Maintanance release, minor change - Spec file now may include sample thickness. Igor code now check, if this value is included and if so, it will offer it as sample thickness. No problem, if the value does not exist - 1 is still default value.

October 25, 2001 release 1.15
Major redesign of the errors for the R_Int... This seems to be very close to the useful method (propagation of poisson errors) + 1% of UPD intensity as constant error... The final errors for SMR data are up to 5-6% at the high Q region, which looks OK.
Now the fit for beam center in R_wave procedure is weighted by errors as well as the errors from the fit are propagated forward through wavenote and eventually are used to calculate the Kfactor error (from the Blank FWHM error and transmission error).
Minor change in behavior of the importing data from Spec to Igor. More automated for USAXS users... Also added verification, that the wave names in spec exist for each scan which is being converted... I wonder how much checking needs and can be done...  
Added new MSAXS evaluation procedure with some more needed functionality. Allows not to weigh the results for caculation of average transmission of the sample and allows to have sectors selected, which are recalculated. Little housekeeping willbe necessary at some point, but should be sufficient at this time. Added (by request) also manual overwrite of the average transmission.

September 23, 2001
Intermediate change in way we calculate errors for R, SMR and for SB-USAXS also DSM waves - now we use 1% of the R Intensity is the major component of the error - we have found out from experiments, that this is apparently best error estimate. We add first principal error calculations, but these are negligible. For now we neglect increase of error in the tails at high Q region...

Added feature requested by Pete - Size distribution now offers user to recover old fitting parameters, if it finds out, that the size distribution was already run on the data... The logic now is about this: User has chance to recover already used parameters, if decides against it, the parameters are set to the last used in this Igor experiment, and they do not exist, they are set to default values... 

Few minor cosmetic changes.

September 1, 2001
Added calculation panel for size distributions. Will work only when displayed is Size Distribution (volume f(D)). Note, that the math was checked but need to be treated with caution - for now, before I have chance to verify formulas. Function with formulas added into the General Procedures.

Subtract sample from blank now asks for restarting with new sample if no SMR (DSM for SBUSAXS) data were created. This prevents users from clicking buttons too fast mistake...

Sample thickness is now written in the wavenote for each wave. Further, the sample thickness is carried forward in this order: first is set to 1([mm]), then set to previous sample thickness(if exists), then set to previously used thickness for this sample from wavenote (if exists), and then presented in dialog to user.

Fix problem when subsequent running of Raw-to-USAXS second time on the same data caused loss of SDD from the list of parameters, which caused SMR wave to be full of NaNs, when run without R_wave prior. This was obscure bug, but appeared. ANyway, now the SMR wave procedure, if the SDD is missing reruns function which fixes this. It is still unadvisable to rerun Raw-to-USAXS as I am not sure about the consequences.

___________________________________________
August 1, 2001
Initial release was actually 1.1 version of most macros. Release 1.0 was distributed on limited scale. Release 1.1 is first which seems to contain all pieces of the code in working order and was released in early August 2001. This is the first release, which uses version numbers to guarrantee the compatibility.


___________________________________________
Indra 1 set. 
this set is currently retired and was used from year 2000 until January 2001. I strongly suggest that, if you have data files using these macros you keep the macros safely, so you can access the data. version 1 and 2 of macros are incompatible. I have developed function which converst the old (Indra 1) data into new (Indra 2) schematics, but it is not perfect and is so difficult to use, that I suggest to everyone reevaluation of data with the new macros. Old data sets should be readable without any problems.