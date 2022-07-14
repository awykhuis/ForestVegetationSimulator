C----------
C VOLUME $Id$
C----------
!== last modified  4-9-2002
      SUBROUTINE R12TAP(TAPEQ,DBHOB,HT1,HT2,TDIB,FCLASS,VTYPE,SVOL)   
C       (TAPEQ-INT  DBHOB-R  HT1-R  HT2-R  D2-R)
C   
C      HAWAII STEM PROFILE MODEL USES THE SHARPNECK MODEL.   

C      DBHOB - SINGLE PRECISION VALUE FOR DBH   
C      SVOL - SINGLE PRECISION VALUE FOR SEGMENT VOLUME   
C      DBH - DOUBLE PRECISION VALUE FOR DBH   
C      VOLCOR - DOUBLE PRECISION COMPUTED VOLUME  
C      HT1 - SINGLE PRECISION FOR TOTAL TREE SEGMENTS
C      HT2 - SINGLE PRECISION VALUE FOR CURRENT SEGMENT NUMBER
C      HTTOT - DOUBLE PRECISION VALUE FOR HT1   
C      HTUP - DOUBLE PRECISION VALUE FOR HT2   
C      R5SC - SHARPNACK COFFICIENTS 
C      SP - SUBSCRIPT TO USE FOR SPECIES COEFFICIENTS   
C   
C      SPECIES SUBSCRIPTS ARE AS FOLLOWS
C      KOA = 1 
C      OHIA = 2
C      ROBUSTA EUCALYPTUS = 3
C      SALIGNA EUCALYPTUS = 4
C
C###########################################################

      CHARACTER*10 TAPEQ
      REAL DBHOB, HT1, HT2, SVOL, TDIB 
      REAL FC

C species, coefficient number, segment number
      REAL*8 R12BDSC(4,7,19), R12CUSC(4,7,19)    

      REAL*8 DBH, TOTHT, HTUP, VOLCOR   
      REAL*8 TERM1, TERM2, TERM3, TERM4
      INTEGER SP, FCLASS, VTYPE

C****************************************************************  
C    COFFICIENTS FOR SHARPNECK MODEL(B0,B1,B2,B3,B4,B5,B6)     **
C****************************************************************  
C  BOARD FOOT
C     KOA   
      DATA ((R12BDSC(1,I,J),I=1,7),J=1,11)
     >  /-95.82708,   10.18193,  0.17171,   0.00285,    0.0027,
     >    31.1948,   -1.216054,
     >   -98.9874,    9.3395,   -6.9892,    0.0016,     0.0102, 
     >    110.0857,  -1.500098,
     >   -68.87314,   5.287,    -7.41769,   0.002,      0.01008,  
     >    99.45291,  -0.741615,
     >    7.695041,  -0.480727, -2.175746,  0.00298,    0.004667,
     >    4.461617,   0.137687,
     >    48.52265,  -2.85065,   0.95769,   0.00296,    0.00188,
     >   -48.85356,   0.331848,
     >    45.65307,  -2.84193,   1.81631,   0.00236,   -0.00044,
     >   -48.79502,   0.30393,
     >    41.76758,  -2.31423,   1.27148,   0.0016,     0.00022,
     >   -39.71543,   0.117924,
     >    15.86447,  -1.28069,   1.0417,    0.00083,   -0.00057,
     >   -16.60251,   0.10586,
     >    5.825181,  -0.442723,  0.334543,  0.00028,   -0.000149,
     >   -5.615163,   0.025345,
     >    0.3226912, -0.0585186, 0.0563598, 0.000052,  -0.0000766,
     >   -0.1474525, -0.001241,
     >   -98.0369,    14.539,   -10.9328,   0.0175,     0.0285,
     >    85.4659,   -2.4364/

C     OHIA   
      DATA ((R12BDSC(2,I,J),I=1,7),J=1,12)
     >  /-170.3914,   8.2664,     8.6611,    0.0039,   -0.0049, 
     >    62.35210,  -0.84389,
     >   -120.5771,   5.6555,     2.1029,    0.003,     0.0019,
     >    88.9183,   -0.89946,
     >   -44.1824,    5.46496,   -8.78737,   0.00098,   0.01464,
     >    88.82999,  -1.009962,
     >    52.81054,   2.30632,   -10.04607,  0.00109,   0.01558,
     >    1.28497,   -0.584072,
     >    41.31205,  -1.51536,   -0.69208,   0.00201,   0.00396,
     >   -41.87429,   0.282015,
     >    42.1399,   -3.03324,    1.94653,   0.00227,  -0.00022,
     >   -48.86516,   0.440775,
     >    19.19443,  -2.68394,    3.15507,   0.00235,  -0.00444,
     >   -30.33555,   0.380373,
     >    11.08655,  -1.92976,    2.11924,   0.00187,  -0.0035,
     >   -14.02272,   0.181155,
     >    12.47474,  -1.24408,    0.86864,   0.00124,  -0.0014,
     >   -8.822830,   0.012869,
     >    9.690916,  -0.466431,  -0.161346,  0.000458,  0.000283,
     >   -3.608517,  -0.062947,
     >    2.818997,  -0.042842,  -0.179804,  0.000044,  0.000298,
     >   -0.794831,  -0.026993,
     >   -143.6228,   10.775,    -1.0132,    0.0192,    0.0222,
     >    93.0615,   -2.1301/


C     ROBUSTA EUCALYPTUS   
      DATA ((R12BDSC(3,I,J),I=1,7),J=1,16)
     >  /-147.4436,   6.9941,     1.3161,    0.0023,     -0.0023,
     >    135.0112,  -0.590282,
     >   -87.9867,    5.3265,    -2.1968,    0.0016,      0.0021,
     >    100.2585,  -0.529313,
     >   -71.08105,   4.38309,   -1.86725,   0.00113,     0.00204,
     >    62.60464,  -0.215083,
     >   -10.02939,   2.68275,   -3.9293,    0.00108,     0.00363,
     >    18.36333,  -0.153004,
     >   -25.13546,   0.32897,    0.76797,   0.0014,      0.00057,
     >    13.65443,   0.082405,
     >    6.878988,  -0.368779,  -0.313218,  0.001442,    0.00146,
     >   -6.488287,  -0.012552,
     >    29.20325,  -1.45658,   -0.44369,   0.00163,     0.0017,
     >   -17.50768,  -0.081734,
     >    30.21361,  -1.61878,   -0.27416,   0.00151,     0.0016,
     >   -16.36067,  -0.118055,
     >    30.43162,  -1.59213,   -0.05596,   0.00141,     0.00061,
     >   -17.37143,  -0.124815,
     >    23.61735,  -1.44648,    0.26886,   0.00111,     0.0004,
     >   -14.23213,  -0.080985,
     >    13.70695,  -1.07266,    0.39112,   0.00081,    -0.00051,
     >   -7.27223,   -0.019399,
     >    10.27594,  -0.73192,    0.37068,   0.00052,    -0.00026,
     >   -7.7769,    -0.011313,
     >    1.846884,  -0.441627,   0.595504,  0.000311,   -0.000636,
     >   -3.182155,   0.019253,
     >   -0.096042,  -0.246899,   0.40058,   0.000165,   -0.000475,
     >   -1.085088,   0.01998,
     >   -0.4799474, -0.0378753,  0.1016402, 0.0000274,  -0.0001236,
     >    0.0163414,  0.004886,
     >   -196.0776,   10.7017,   -4.8679,    0.0164,      0.0098, 
     >    238.6319,  -1.81/

C     SALIGNA EUCALYPTUS 
      DATA ((R12BDSC(4,I,J),I=1,7),J=1,19)
     >   /139.4222,    13.4385,   -34.3848,   0.0009,    0.015,
     >    77.1701,    -1.656012,
     >   -27.16889,    7.9288,    -11.19857,  0.00093,   0.00798,
     >    80.57326,   -0.799945,
     >   -120.2769,    6.006,     -5.6035,    0.0015,    0.0012,
     >    159.8142,   -0.600258,
     >   -163.0663,    2.6343,     6.9076,    0.0017,   -0.0042,
     >    98.9372,     0.103804,
     >   -101.3343,    0.9542,     7.6232,    0.0016,   -0.0035,
     >    23.6212,     0.317791,
     >   -53.70727,   -0.49243,    6.19461,   0.00162,  -0.00212,
     >   -4.49348,     0.291428,
     >    72.34748,   -1.57365,   -3.36042,   0.00163,   0.00266,
     >   -44.21681,    0.022817,
     >    74.5287,    -2.42129,   -2.18962,   0.00157,   0.00247,
     >   -47.8671,     0.065601,
     >    72.81351,   -3.23532,   -0.53876,   0.0015,    0.0023,
     >   -52.75278,    0.112728,
     >    85.20497,   -2.92933,   -1.87182,   0.0013,    0.00293,
     >   -56.59252,    0.044585,
     >    97.67553,   -2.76203,   -2.42418,   0.0012,    0.00318,
     >   -66.32821,   -0.054258,
     >    62.8306,    -2.37526,    1.09586,   0.00103,   0.0016,
     >   -66.32523,    0.000638,
     >    48.14582,   -1.89902,    1.08436,   0.00078,   0.00203, 
     >   -51.7645,    -0.065606,
     >    87.60065,   -1.18257,   -4.77535,   0.0005,    0.00395,
     >   -42.41969,   -0.242557,
     >    41.87644,   -0.79009,   -2.09,      0.00033,   0.00153,
     >   -18.49814,   -0.111464,
     >    23.01003,   -0.57185,   -1.19807,   0.00021,   0.00025,
     >   -7.53108,    -0.020979,
     >    10.02657,   -0.1822,    -0.6388,    0.00007,   0.00022,
     >   -2.79567,    -0.017864,
     >    3.543246,   -0.061057,  -0.218041,  0.00002,   0.000119,
     >   -1.09622,    -0.009133,
     >    353.4721,    10.4857,   -47.5863,   0.0184,    0.0376,
     >   -22.5655,    -2.6187/


C****************************************************************
C  CUBIC FOOT
C     KOA   
      DATA ((R12CUSC(1,I,J),I=1,7),J=1,11)
     >  /-9.68699,     1.21402,    0.023089,   0.000394,    0.000362,
     >    3.576347,   -0.158056,
     >   -11.9152,     1.138,     -0.86295,    0.00022,     0.0012,
     >    14.77558,   -0.17534,
     >   -11.10862,    0.79387,   -1.04888,    0.00015,     0.00135,
     >    14.720008,  -0.050964,
     >   -1.440857,   -0.004906,  -0.288692,   0.000334,    0.000574,
     >    1.99558,     0.063705,
     >    5.209516,   -0.377899,   0.191257,   0.000387,    0.00017,
     >   -6.460742,    0.079629,
     >    5.789749,   -0.400744,   0.312052,   0.000331,   -0.000154,
     >   -7.159193,    0.066171,
     >    5.915681,   -0.352759,   0.231965,   0.000237,   -0.000029,
     >   -6.129322,    0.030363,
     >    2.427013,   -0.200374,   0.169549,   0.000127,   -0.000095,
     >   -2.670028,    0.019788,
     >    0.8881901,  -0.0669086,  0.0512612,  0.00004120, -0.0000215,
     >   -0.8806413,   0.004412,
     >    0.04958669, -0.00913714, 0.00884829, 0.00000812, -0.00001206,
     >   -0.02262095, -0.000186,
     >   -13.8719,     1.7332,    -1.2125,     0.0022,      0.0033,
     >    11.745,     -0.1205/

C     OHIA   
      DATA ((R12CUSC(2,I,J),I=1,7),J=1,12)
     >  /-19.41844,   1.01349,     1.03132,   0.0005,    -0.00066,
     >    8.00497,   -0.104521,
     >   -14.47685,   0.76226,     0.19734,   0.00033,    0.00024,
     >    11.53981,  -0.099139,
     >   -8.82702,    0.84825,    -1.21373,   0.00002,    0.00187,
     >    14.47147,  -0.099642,
     >    5.926268,   0.415849,   -1.487051,  0.000056,   0.002205,
     >    1.052171,  -0.048797,
     >    5.301151,  -0.198231,   -0.083528,  0.000231,  -0.000582,
     >   -6.32622,    0.071528,
     >    5.977388,  -0.465099,    0.340442,  0.000311,  -0.000055,
     >   -7.753169,   0.088066,
     >    2.533931,  -0.422026,    0.542706,  0.000358,  -0.000767,
     >   -4.849127,   0.071285,
     >    1.419499,  -0.308002,    0.360319,  0.000297,   0.000604,
     >   -2.09887,    0.033883,
     >    1.649707,  -0.207882,    0.177219,  0.000206,  -0.000293,
     >   -1.308878,   0.00668,
     >    1.322752,  -0.081551,    0.001187,  0.00008,   -0.000001,
     >   -0.509818,  -0.007166,
     >    0.405899,  -0.0073059,  -0.0247008, 0.0000074,  0.0000407,
     >   -0.1117655, -0.003833,
     >   -18.1857,    1.3498,     -0.1585,    0.0024,     0.0026,
     >    12.1106,   -0.0917/

C     ROBUSTA EUCALYPTUS   
      DATA ((R12CUSC(3,I,J),I=1,7),J=1,16)
     >  /-17.82186,    0.90209,    0.14525,    0.00026,    -0.00028,
     >    17.48416,   -0.068875,
     >   -10.98505,    0.70596,   -0.27203,    0.00018,     0.00024,
     >    13.34293,   -0.059877,
     >   -10.93912,    0.68559,   -0.2474,     0.00008,     0.00024,
     >    8.95076,    -0.005218,
     >   -1.851224,    0.498383,  -0.72306,    0.000062,    0.00061,
     >    3.034923,   -0.000017,
     >   -5.58477,     0.091009,   0.138066,   0.000139,    0.00005,
     >    3.111704,    0.041055,
     >    0.0086459,  -0.017857,  -0.0535476,  0.0001619,   0.0002073,
     >   -0.6397084,   0.022332,
     >    3.753958,   -0.218191,  -0.032923,   0.000216,    0.000229,
     >   -2.725338,    0.008064,
     >    4.09359,    -0.254223,  -0.007515,   0.000214,    0.000224,
     >   -2.473237,   -0.004053,
     >    4.430871,   -0.254877,   0.019384,   0.000216,    0.000066,
     >   -2.692627,   -0.012634,
     >    3.668604,   -0.24021,    0.055913,   0.000177,    0.000051,
     >   -2.26664,    -0.008779,
     >    2.441994,   -0.185444,   0.050881,   0.000136,   -0.000075,
     >   -1.207162,   -0.00214,
     >    1.74971,    -0.131611,   0.072097,   0.000092,   -0.000055,
     >   -1.362329,   -0.000462,
     >    0.3331091,  -0.0818189,  0.1102678,  0.0000568,  -0.0001179,
     >   -0.5863276,   0.003916,
     >    0.0366694,  -0.0473497,  0.0715013,  0.0000312,  -0.0000847,
     >   -0.2227333,   0.003627,
     >   -0.09175286, -0.00728397, 0.01950573, 0.00000526, -0.0000237,
     >    0.00257417,  0.000946,
     >   -26.7566,     1.4442,    -0.6536,     0.002,       0.0013, 
     >    31.7509,    -0.0821/

C     SALIGNA EUCALYPTUS 
      DATA ((R12CUSC(4,I,J),I=1,7),J=1,19)
     >   /25.55281,   1.72446,   -5.79898,   0.00021,   0.00236, 
     >    20.35287,  -0.31401,
     >    10.75487,   1.09651,   -3.63853,   0.0002,    0.00163, 
     >    20.4398,   -0.216379,
     >   -11.48821,   0.76538,   -0.95195,   0.00018,   0.00033,
     >    18.59479,  -0.071356,
     >   -33.17864,   0.44743,    1.77712,   0.00018,  -0.00097,
     >    16.57859,   0.057898,
     >   -19.78817,   0.23582,    1.37509,   0.00016,  -0.00065,
     >    5.31403,    0.071517,
     >   -10.82043,   0.011,      0.97277,   0.00018,  -0.00036,
     >    1.00509,    0.060427,
     >    12.42869,  -0.15716,   -0.8597,    0.00019,   0.00055,
     >   -5.96517,    0.006107,
     >    12.7247,   -0.30661,   -0.65015,   0.00019,   0.0005,
     >   -6.56025,    0.014429,
     >    12.46305,  -0.45758,   -0.36738,   0.00019,   0.00045,
     >   -7.27538,    0.023199,
     >    14.69305,  -0.41632,   -0.5923,    0.00017,   0.00055,
     >   -7.96605,    0.011469,
     >    16.81795,  -0.40787,   -0.61724,   0.00017,   0.00056, 
     >   -10.15834,  -0.004836,
     >    10.2786,   -0.35576,    0.10614,   0.00015,   0.00023,
     >   -10.63589,   0.007449,
     >    7.441342,  -0.293802,   0.177972,  0.000117,  0.000275,
     >   -8.282357,  -0.003108,
     >    14.04546,  -0.18383,   -0.78781,   0.00008,   0.0006,
     >   -6.68389,   -0.034834,
     >    6.530406,  -0.12294,   -0.33155,   0.000052,  0.000221,
     >   -2.834447,  -0.016085,
     >    3.960105,  -0.093894,  -0.216559,  0.000035,  0.000043,
     >   -1.266801,  -0.003338,
     >    1.620516,  -0.029141,  -0.10454,   0.0000110, 0.000034, 
     >   -0.443422,  -0.002728,
     >    0.5015038, -0.0093961, -0.0297491, 0.0000031, 0.0000016,
     >   -0.1562058, -0.001259,
     >    74.5376,    1.4463,    -10.5373,   0.0025,    0.0064,
     >    14.057,    -0.4151/
 
C     CONVERT VALUES TO DOUBLE PRECISION FOR CACULATIONS   
      
      DBH = DBHOB   
      TOTHT = HT1   
      HTUP = HT2   
      FC = FCLASS/100.0

      IF(TAPEQ(8:10).EQ.'301')THEN
        SP = 1
      ELSEIF(TAPEQ(8:10).EQ.'671')THEN
        SP = 2
      ELSEIF(TAPEQ(8:10).EQ.'510' .AND. TAPEQ(1:3).EQ.'H00')THEN
        SP = 3
      ELSEIF(TAPEQ(8:10).EQ.'510' .AND. TAPEQ(1:3).EQ.'H01')THEN
        SP = 4
      ENDIF

      IF (VTYPE .EQ. 1) THEN
          IF (SP .EQ. 1) HTUP = 11
          IF (SP .EQ. 2) HTUP = 12
          IF (SP .EQ. 3) HTUP = 16
          IF (SP .EQ. 4) HTUP = 19
     
          TERM1 = R12CUSC(SP,1,INT(HTUP)) + R12CUSC(SP,2,INT(HTUP))*DBH 
     >             + R12CUSC(SP,3,INT(HTUP))*TDIB
          TERM2 = R12CUSC(SP,4,INT(HTUP))*(DBH*DBH*TOTHT*FC)
          TERM3 = R12CUSC(SP,5,INT(HTUP))*(TDIB*TDIB*TOTHT*FC)
          TERM4 = R12CUSC(SP,6,INT(HTUP))*FC + R12CUSC(SP,7,INT(HTUP))
     >            *TOTHT

          VOLCOR = TERM1+TERM2+TERM3+TERM4

          SVOL = REAL(VOLCOR)

      ELSE IF (VTYPE.EQ.2) THEN

          TERM1 = R12BDSC(SP,1,INT(HTUP)) + R12BDSC(SP,2,INT(HTUP))*DBH
     >            + R12BDSC(SP,3,INT(HTUP))*TDIB
          TERM2 = R12BDSC(SP,4,INT(HTUP))*(DBH*DBH*TOTHT*FC)
          TERM3 = R12BDSC(SP,5,INT(HTUP))*(TDIB*TDIB*TOTHT*FC)
          TERM4 = R12BDSC(SP,6,INT(HTUP))*FC + R12BDSC(SP,7,INT(HTUP))
     >            *TOTHT

          VOLCOR = TERM1+TERM2+TERM3+TERM4

          SVOL = REAL(VOLCOR)

      ELSE IF (VTYPE.EQ.3) THEN

          TERM1 = R12CUSC(SP,1,INT(HTUP)) + R12CUSC(SP,2,INT(HTUP))*DBH
     >            + R12CUSC(SP,3,INT(HTUP))*TDIB
          TERM2 = R12CUSC(SP,4,INT(HTUP))*(DBH*DBH*TOTHT*FC)
          TERM3 = R12CUSC(SP,5,INT(HTUP))*(TDIB*TDIB*TOTHT*FC)
          TERM4 = R12CUSC(SP,6,INT(HTUP))*FC + R12CUSC(SP,7,INT(HTUP))
     >            *TOTHT

          VOLCOR = TERM1+TERM2+TERM3+TERM4

          SVOL = REAL(VOLCOR)
      ENDIF
C
C   END OF MAIN LOGIC
C
      RETURN
      END