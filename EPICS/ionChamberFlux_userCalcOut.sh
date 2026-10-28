#!/bin/sh
#  ionChamberFlux_userCalcOut.sh
#
#  Configures synApps userCalcOut1..5 to compute incident X-ray flux (photons/s)
#  from an ion chamber read out as a mean current in pA.
#  Nitrogen fill, 60 mm active, 17.5 mm upstream dead length, 0.001" Kapton window.
#
#  This is the in-place alternative to loading ionChamberFlux.db; see that file's
#  header for the derivation, accuracy, the GASF gas-factor discussion and the
#  test vectors.  Prefer the .db if you can -- it does not consume userCalcOuts
#  and it survives an IOC reboot without save/restore.
#
#  Run once, then make the values persistent with autosave.
#  Requires the EPICS base command line tools on PATH.

# ---------------------------------------------------------------- EDIT THESE
P=9idcUSX:                        # IOC prefix
ENERGY_PV=9idcUSX:mono:keV        # mono energy in keV
LAMBDA_PV=                        # mono wavelength in Angstrom, or leave empty
USELAM=0                          # 0 = use ENERGY_PV, 1 = use LAMBDA_PV
CURRENT_PV=9idcUSX:I0:current_pA  # ion chamber current in pA
DARK=0                            # dark current in pA
GASF=1                            # P[atm]*273.15/T[K];  1 = match the Igor panel
FSCAN=".5 second"                 # scan period of the flux record
# ---------------------------------------------------------------------------

set -e

# 1 -- X-ray energy (keV)
caput  "${P}userCalcOut1.DESC" "X-ray energy"
caput  "${P}userCalcOut1.SCAN" "Passive"
caput  "${P}userCalcOut1.INPA" "${ENERGY_PV} CP MS"
caput  "${P}userCalcOut1.INPB" "${LAMBDA_PV:+${LAMBDA_PV} CP MS}"
caput  "${P}userCalcOut1.C"    "${USELAM}"
caput  "${P}userCalcOut1.CALC" 'C&&B>0?12.39842435/B:A'
caput  "${P}userCalcOut1.EGU"  "keV"
caput  "${P}userCalcOut1.PREC" 5

# 2 -- fraction of the beam absorbed in the 60 mm N2 active volume
caput  "${P}userCalcOut2.DESC" "N2 fraction absorbed in 60mm"
caput  "${P}userCalcOut2.SCAN" "Passive"
caput  "${P}userCalcOut2.INPA" "${P}userCalcOut1 CP MS"
caput  "${P}userCalcOut2.F"    "${GASF}"
caput  "${P}userCalcOut2.CALC" '1-EXP(-F*EXP(3.236913+LN(A)*(-2.654+LN(A)*(-0.200445+LN(A)*0.0200765))))'
caput  "${P}userCalcOut2.PREC" 6

# 3 -- divide out the 17.5 mm N2 dead length ahead of the active volume
caput  "${P}userCalcOut3.DESC" "17.5mm N2 dead length factor"
caput  "${P}userCalcOut3.SCAN" "Passive"
caput  "${P}userCalcOut3.INPA" "${P}userCalcOut1 CP MS"
caput  "${P}userCalcOut3.F"    "${GASF}"
caput  "${P}userCalcOut3.CALC" 'EXP(F*EXP(-0.384525+LN(A)*(0.967290+LN(A)*(-2.040742+LN(A)*0.340121))))'
caput  "${P}userCalcOut3.PREC" 6

# 4 -- divide out the 0.001 inch Kapton entrance window
caput  "${P}userCalcOut4.DESC" "0.001in Kapton window factor"
caput  "${P}userCalcOut4.SCAN" "Passive"
caput  "${P}userCalcOut4.INPA" "${P}userCalcOut1 CP MS"
caput  "${P}userCalcOut4.CALC" 'EXP(EXP(0.124906+LN(A)*(0.729615+LN(A)*(-1.983058+LN(A)*0.342089))))'
caput  "${P}userCalcOut4.PREC" 6

# 5 -- incident flux, photons/s
caput  "${P}userCalcOut5.DESC" "I0 incident flux"
caput  "${P}userCalcOut5.INPA" "${CURRENT_PV} CP MS"
caput  "${P}userCalcOut5.INPB" "${P}userCalcOut1 MS"
caput  "${P}userCalcOut5.INPC" "${P}userCalcOut2 MS"
caput  "${P}userCalcOut5.INPD" "${P}userCalcOut3 MS"
caput  "${P}userCalcOut5.INPE" "${P}userCalcOut4 MS"
caput  "${P}userCalcOut5.F"    "${DARK}"
caput  "${P}userCalcOut5.CALC" '226566.8*(A-F)*D*E/(B*C)'
caput  "${P}userCalcOut5.EGU"  "ph/s"
caput  "${P}userCalcOut5.PREC" 4
caput  "${P}userCalcOut5.SCAN" "${FSCAN}"

echo "done -- flux is ${P}userCalcOut5"
