             test-fm : Project Name  (only 1st item is read)
            test.sas : SAS file, contains columns: Q  i  esd
    1e-08        100 : qMin qMax, 1/A  (1.0e-8 to 100 means all data)
                 100 : rhosq       : scattering contrast, 10^20 1/cm^-4
                   1 : fac         :   I = fac * ( i - bkg )
                   1 : err         : ESD = fac * err * esd
                 0.1 : bkg         :   I = fac * ( i - bkg )
                   1 : shapeModel  (1=spheroids, no others yet)
                   1 : Aspect Ratio
                   0 : Bin Type    (1=Lin, 0=Log)
                  40 : nRadii
       25        900 : dMin dMax, A
                   1 : n, in N(D)*V^n
              1.0e-6 : defaultDistLevel  (MaxEnt only)
                  32 : IterMax
                   0 : slitLength, 1/A
              0.0002 : dLambda/Lambda
                   1 : analysisType (1=MaxEnt, 0=regularization)
