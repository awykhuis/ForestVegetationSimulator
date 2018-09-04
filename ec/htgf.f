      SUBROUTINE HTGF
      IMPLICIT NONE
C----------
C EC $Id$
C----------
C  THIS SUBROUTINE COMPUTES THE PREDICTED PERIODIC HEIGHT
C  INCREMENT FOR EACH CYCLE AND LOADS IT INTO THE ARRAY HTG.
C  THIS ROUTINE IS CALLED FROM **TREGRO** DURING REGULAR CYCLING.
C  ENTRY **HTCONS** IS CALLED FROM **RCON** TO LOAD SITE
C  DEPENDENT CONSTANTS THAT NEED ONLY BE RESOLVED ONCE.
C----------
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'ARRAYS.F77'
C
C
      INCLUDE 'COEFFS.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
      INCLUDE 'OUTCOM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'MULTCM.F77'
C
C
      INCLUDE 'HTCAL.F77'
C
C
      INCLUDE 'PDEN.F77'
C
C
      INCLUDE 'VARCOM.F77'
C
C
COMMONS
C----------
      LOGICAL DEBUG
      INTEGER I,ISPC,I1,I2,I3,ITFN
      REAL SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,D1,D2,BARK,BRATIO
      REAL RHR(MAXSP), RHYXS(MAXSP), RHM(MAXSP), RHB(MAXSP)
      REAL CRC,CRB,CRA,RHXS,RHK,HGUESS,SCALE,SINDX,XHT,BAL
      REAL H,POTHTG,RELHT,HGMDCR,RHX,FCTRKX,FCTRRB,FCTRXB,FCTRM
      REAL HGMDRH,WTCR,WTRH,HTGMOD,TEMPH,TEMHTG,AGP10
      REAL MISHGF,MAXGUESS,HGUESS1,HGUESS2
C----------
C  SPECIES LIST FOR EAST CASCADES VARIANT.
C
C   1 = WESTERN WHITE PINE      (WP)    PINUS MONTICOLA
C   2 = WESTERN LARCH           (WL)    LARIX OCCIDENTALIS
C   3 = DOUGLAS-FIR             (DF)    PSEUDOTSUGA MENZIESII
C   4 = PACIFIC SILVER FIR      (SF)    ABIES AMABILIS
C   5 = WESTERN REDCEDAR        (RC)    THUJA PLICATA
C   6 = GRAND FIR               (GF)    ABIES GRANDIS
C   7 = LODGEPOLE PINE          (LP)    PINUS CONTORTA
C   8 = ENGELMANN SPRUCE        (ES)    PICEA ENGELMANNII
C   9 = SUBALPINE FIR           (AF)    ABIES LASIOCARPA
C  10 = PONDEROSA PINE          (PP)    PINUS PONDEROSA
C  11 = WESTERN HEMLOCK         (WH)    TSUGA HETEROPHYLLA
C  12 = MOUNTAIN HEMLOCK        (MH)    TSUGA MERTENSIANA
C  13 = PACIFIC YEW             (PY)    TAXUS BREVIFOLIA
C  14 = WHITEBARK PINE          (WB)    PINUS ALBICAULIS
C  15 = NOBLE FIR               (NF)    ABIES PROCERA
C  16 = WHITE FIR               (WF)    ABIES CONCOLOR
C  17 = SUBALPINE LARCH         (LL)    LARIX LYALLII
C  18 = ALASKA CEDAR            (YC)    CALLITROPSIS NOOTKATENSIS
C  19 = WESTERN JUNIPER         (WJ)    JUNIPERUS OCCIDENTALIS
C  20 = BIGLEAF MAPLE           (BM)    ACER MACROPHYLLUM
C  21 = VINE MAPLE              (VN)    ACER CIRCINATUM
C  22 = RED ALDER               (RA)    ALNUS RUBRA
C  23 = PAPER BIRCH             (PB)    BETULA PAPYRIFERA
C  24 = GIANT CHINQUAPIN        (GC)    CHRYSOLEPIS CHRYSOPHYLLA
C  25 = PACIFIC DOGWOOD         (DG)    CORNUS NUTTALLII
C  26 = QUAKING ASPEN           (AS)    POPULUS TREMULOIDES
C  27 = BLACK COTTONWOOD        (CW)    POPULUS BALSAMIFERA var. TRICHOCARPA
C  28 = OREGON WHITE OAK        (WO)    QUERCUS GARRYANA
C  29 = CHERRY AND PLUM SPECIES (PL)    PRUNUS sp.
C  30 = WILLOW SPECIES          (WI)    SALIX sp.
C  31 = OTHER SOFTWOODS         (OS)
C  32 = OTHER HARDWOODS         (OH)
C
C  SURROGATE EQUATION ASSIGNMENT:
C
C  FROM THE EC VARIANT:
C      USE 6(GF) FOR 16(WF)
C      USE OLD 11(OT) FOR NEW 12(MH) AND 31(OS)
C
C  FROM THE WC VARIANT:
C      USE 19(WH) FOR 11(WH)
C      USE 33(PY) FOR 13(PY)
C      USE 31(WB) FOR 14(WB)
C      USE  7(NF) FOR 15(NF)
C      USE 30(LL) FOR 17(LL)
C      USE  8(YC) FOR 18(YC)
C      USE 29(WJ) FOR 19(WJ)
C      USE 21(BM) FOR 20(BM) AND 21(VN)
C      USE 22(RA) FOR 22(RA)
C      USE 24(PB) FOR 23(PB)
C      USE 25(GC) FOR 24(GC)
C      USE 34(DG) FOR 25(DG)
C      USE 26(AS) FOR 26(AS) AND 32(OH)
C      USE 27(CW) FOR 27(CW)
C      USE 28(WO) FOR 28(WO)
C      USE 36(CH) FOR 29(PL)
C      USE 37(WI) FOR 30(WI)
C----------
C  COEFFICIENTS--CROWN RATIO (CR) BASED HT. GRTH. MODIFIER
C----------
      DATA CRA /100.0/, CRB /3.0/, CRC /-5.0/
C----------
C  COEFFICIENTS--RELATIVE HEIGHT (RH) BASED HT. GRTH. MODIFIER
C----------
      DATA RHK /1.0/, RHXS /0.0/
C----------
C  COEFFS BASED ON SPECIES SHADE TOLERANCE AS FOLLOWS:
C                                   RHR  RHYXS    RHM    RHB
C        VERY TOLERANT             20.0   0.20    1.1  -1.10
C        TOLERANT                  16.0   0.15    1.1  -1.20
C        INTERMEDIATE              15.0   0.10    1.1  -1.45
C        INTOLERANT                13.0   0.05    1.1  -1.60
C        VERY INTOLERANT           12.0   0.01    1.1  -1.60
C  IN THE EC VARIANT, SILVICS OF NORTH AMERICA (AG.HNDBK-654)
C  WAS USED TO GET SHADE TOLERANCE.
C  SEQ. NO.   CHAR. CODE    SHADE TOL.   SEQ. NO.  CHAR. CODE    SHADE TOL.
C      1      WP            INTM            17     LL            VINT
C      2      WL            VINT            18     YC            TOLN
C      3      DF            INTM            19     WJ            INTL
C      4      SF            VTOL            20     BM            VTOL
C      5      RC            VTOL            21     VN            VTOL
C      6      GF            TOLN            22     RA            INTL
C      7      LP            VINT            23     PB            INTL
C      8      ES            TOLN            24     GC            INTM
C      9      AF            TOLN            25     DG            VTOL
C     10      PP            INTL            26     AS            VINT
C     11      WH            VTOL            27     CW            VINT
C     12      MH            INTM            28     WO            INTM
C     13      PY            VTOL            29     PL            INTL
C     14      WB            INTM            30     WI            VINT
C     15      NF            INTM            31     OS            INTM
C     16      WF            TOLN            32     OH            VINT
C----------
      DATA RHR/
     &  15.0,  12.0,  15.0,  20.0,  20.0,
     &  16.0,  12.0,  16.0,  16.0,  13.0,
     &  20.0,  15.0,  20.0,  15.0,  15.0,
     &  16.0,  12.0,  16.0,  13.0,  20.0,
     &  20.0,  13.0,  13.0,  15.0,  20.0,
     &  12.0,  12.0,  15.0,  13.0,  12.0,
     &  15.0,  12.0/
C
      DATA RHYXS/
     &  0.10,  0.01,  0.10,  0.20,  0.20,
     &  0.15,  0.01,  0.15,  0.15,  0.05,
     &  0.20,  0.10,  0.20,  0.10,  0.10,
     &  0.15,  0.01,  0.15,  0.05,  0.20,
     &  0.20,  0.05,  0.05,  0.10,  0.20,
     &  0.01,  0.01,  0.10,  0.05,  0.01,
     &  0.10,  0.01/
C
      DATA RHM/
     &  1.10,  1.10,  1.10,  1.10,  1.10,
     &  1.10,  1.10,  1.10,  1.10,  1.10,
     &  1.10,  1.10,  1.10,  1.10,  1.10,
     &  1.10,  1.10,  1.10,  1.10,  1.10,
     &  1.10,  1.10,  1.10,  1.10,  1.10,
     &  1.10,  1.10,  1.10,  1.10,  1.10,
     &  1.10,  1.10/
C
      DATA RHB/
     & -1.45, -1.60, -1.45, -1.10, -1.10,
     & -1.20, -1.60, -1.20, -1.20, -1.60,
     & -1.10, -1.45, -1.10,  0.10, -1.45,
     & -1.20, -1.60, -1.20, -1.60, -1.10,
     & -1.10, -1.60, -1.60, -1.45, -1.10,
     & -1.60, -1.60, -1.45, -1.60, -1.60,
     & -1.45, -1.60/
C----------
C  SEE IF WE NEED TO DO SOME DEBUG.
C-----------
      CALL DBCHK (DEBUG,'HTGF',4,ICYC)
      IF(DEBUG) WRITE(JOSTND,3)ICYC
    3 FORMAT(' ENTERING SUBROUTINE HTGF CYCLE =',I5)
C
      IF(DEBUG)WRITE(JOSTND,*) 'IN HTGF AT BEGINNING,HTCON=',
     *HTCON,'RMAI=',RMAI,'ELEV=',ELEV
      SCALE=FINT/YR
C----------
C  GET THE HEIGHT GROWTH MULTIPLIERS.
C----------
      CALL MULTS (2,IY(ICYC),XHMULT)
      IF(DEBUG)WRITE(JOSTND,*)'HTGF- IY(ICYC),XHMULT= ',
     & IY(ICYC), XHMULT
C----------
C   BEGIN SPECIES LOOP:
C----------
      DO 40 ISPC=1,MAXSP
      I1 = ISCT(ISPC,1)
      IF (I1 .EQ. 0) GO TO 40
      I2 = ISCT(ISPC,2)
      SINDX = SITEAR(ISPC)
      XHT=XHMULT(ISPC)
C-----------
C   BEGIN TREE LOOP WITHIN SPECIES LOOP
C-----------
      DO 30 I3=I1,I2
      I=IND1(I3)
      BAL=((100.0-PCT(I))/100.0)*BA
      H=HT(I)
      HTG(I)=0.
C
      SITAGE = 0.0
      SITHT = 0.0
      AGMAX = 0.0
      HTMAX = 0.0
      HTMAX2 = 0.0
      D1 = DBH(I)
      BARK=BRATIO(ISPC,D1,H)
      D2 = D1 + DG(I)/BARK
      IF (PROB(I).LE.0.0) GO TO 161
      IF(DEBUG)WRITE(JOSTND,*)' IN HTGF, CALLING FINDAG I= ',I
      CALL FINDAG(I,ISPC,D1,D2,H,SITAGE,SITHT,AGMAX,HTMAX,HTMAX2,DEBUG)
C
      SELECT CASE (ISPC)
C
C  SPECIES USING EQUATIONS FROM THE WC VARIANT
C
      CASE(11,13:15,17:30,32)
C----------
C  CHECK TO SEE IF TREE HT/DBH RATIO IS ABOVE THE MAXIMUM RATIO AT
C  THE BEGINNING OF THE CYCLE. THIS COULD HAPPEN FOR TREES COMING
C  OUT OF THE ESTAB MODEL.  IF IT IS, THEN CHECK TO SEE IF THE
C  HT/NEWDBH RATIO IS ABOVE THE MAXIMUM.  IF THIS IS ALSO TRUE, LIMIT
C  HTG TO 0.1 FOOT OR HALF THE DG, WHICH EVER IS GREATER.
C  IF IT ISN'T, THEN LET HTG BE COMPUTED THE NORMAL
C  WAY AND THEN CHECK IT AGAIN AT THAT POINT.
C----------
        IF(H .GT.HTMAX) THEN
          IF(H .GE. HTMAX2) THEN
            HTG(I)=0.5 * DG(I)
            IF(HTG(I).LT.0.1)HTG(I)=0.1
            HTG(I)=SCALE*XHT*HTG(I)*EXP(HTCON(ISPC))
          ENDIF
          GO TO 161
        ENDIF
C
C  SPECIES USING EQUATIONS FROM THE EC VARIANT
C
      CASE DEFAULT
        IF(H .GE. HTMAX)THEN
          HTG(I)=0.1
          HTG(I)=SCALE*XHT*HTG(I)*EXP(HTCON(ISPC))
          GO TO 161
        END IF
      END SELECT
C----------
C  NORMAL HEIGHT INCREMENT CALCULATON BASED ON TREE AGE
C  FIRST CHECK FOR MAXIMUM TREE AGE
C----------
      IF (SITAGE .GE. AGMAX) THEN
        POTHTG= 0.10
C----------
C THE FOLLOWING 5 LINES ARE AN RJ FIX 7-28-88
C----------
        IF(ISPC .EQ. 10) THEN
          POTHTG = -1.31 + 0.05 * SINDX
          IF(POTHTG .LT. 0.1) POTHTG = 0.1
        ENDIF
        GO TO 1320
      ELSE
        AGP10 = SITAGE+10.
      ENDIF
C----------
C   CALL HTCALC FOR NORMAL CYCLING
C----------
      HGUESS = 0.0
      CALL HTCALC(SINDX,ISPC,AGP10,HGUESS,JOSTND,DEBUG) 
      POTHTG= HGUESS-SITHT
C----------
C  PATCH FOR OREGON WHITE OAK - WORK BY GOULD AND HARRINGTON, PNW
C  USES A HT-DBH EQUATION MODIFIED BY SI AND BA, FIRST PREDICTS
C  HEIGHT GUESS BASED ON PREVIOUS DIAMETER AND THEN PREDICT THE
C  HEIGHT GUESS BASED ON PRESENT DIAMETER, SUBTRACT GUESSES
C  TO CALCULATE HEIGHT GROWTH.
C----------
      IF (ISPC .EQ. 28) THEN
C----------
C  CALCULATE MAX HEIGHT BASED ON SI, THEN MODIFY BASED ON BA
C----------
        MAXGUESS = SINDX - 18.6024/ALOG(2.7 + BA)
C----------
C  DUB HEIGHT BASED ON PRESENT DBH
C----------
        D2 = DBH(I) + DG(I)
        IF (D2 .LT. 0.) D2 = 0.1
        HGUESS2 = 4.5 + MAXGUESS*(1-EXP(-0.137428*D2))**1.38994
C----------
C  DUB HEIGHT BASED ON PAST DBH
C----------
        HGUESS1 = 4.5 + MAXGUESS*(1-EXP(-0.137428*D1))**1.38994
C----------
C  DIFFERENCE OF TWO DUBBED HEIGHTS IS POTENTIAL HEIGHT GROWTH
C----------
        POTHTG = HGUESS2 - HGUESS1
      ENDIF
C--End OWO PATCH
C
      IF(DEBUG)WRITE(JOSTND,*)' I,ISPC,AGP10,SITHT,HGUESS,POTHTG= ',
     & I,ISPC,AGP10,SITHT,HGUESS,POTHTG
C----------
C  HEIGHT GROWTH MUST BE POSITIVE
C----------
      IF(POTHTG .LT. 0.1)POTHTG= 0.1
C----------
C ASSIGN A POTENTIAL HTG FOR THE ASYMPTOTIC AGE
C----------
 1320 CONTINUE
C----------
C  HEIGHT GROWTH MODIFIERS
C----------
      RELHT = 0.0
      IF(AVH .GT. 0.0) RELHT=HT(I)/AVH
      IF(RELHT .GT. 1.5)RELHT=1.5
C----------
C     REVISED HEIGHT GROWTH MODIFIER APPROACH.
C----------
C     CROWN RATIO CONTRIBUTION.  DATA AND READINGS INDICATE HEIGHT
C     GROWTH PEAKS IN MID-RANGE OF CR, DECREASES SOMEWHAT FOR LARGE
C     CROWN RATIOS DUE TO PHOTOSYNTHETIC ENERGY PUT INTO CROWN SUPPORT
C     RATHER THAN HT. GROWTH.  CROWN RATIO FOR THIS COMPUTATION NEEDS
C     TO BE IN (0-1) RANGE; DIVIDE BY 100.  FUNCTION IS HOERL'S
C     SPECIAL FUNCTION (REF. P.23, CUTHBERT&WOOD, FITTING EQNS. TO DATA
C     WILEY, 1971).  FUNCTION OUTPUT CONSTRAINED TO BE 1.0 OR LESS.
C----------
      HGMDCR = (CRA * (ICR(I)/100.0)**CRB) * EXP(CRC*(ICR(I)/100.0))
      IF (HGMDCR .GT. 1.0) HGMDCR = 1.0
C----------
C     RELATIVE HEIGHT CONTRIBUTION.  DATA AND READINGS INDICATE HEIGHT
C     GROWTH IS ENHANCED BY STRONG TOP LIGHT AND HINDERED BY HIGH
C     SHADE EVEN IF SOME LIGHT FILTERS THROUGH.  ALSO RESPONSE IS
C     GREATER FOR GIVEN LIGHT AS SHADE TOLERANCE INCREASES.  FUNCTION
C     IS GENERALIZED CHAPMAN-RICHARDS (REF. P.2 DONNELLY ET AL. 1992.
C     THINNING EVEN-AGED FOREST STANDS...OPTIMAL CONTROL ANALYSES.
C     USDA FOR. SERV. RES. PAPER RM-307).
C     PARTS OF THE GENERALIZED CHAPMAN-RICHARDS FUNCTION USED TO
C     COMPUTE HGMDRH BELOW ARE SEGMENTED INTO FACTORS
C     FOR PROGRAMMING CONVENIENCE.
C----------
      RHX = RELHT
      FCTRKX = ( (RHK/RHYXS(ISPC))**(RHM(ISPC)-1.0) ) - 1.0
      FCTRRB = -1.0*( RHR(ISPC)/(1.0-RHB(ISPC)) )
      FCTRXB = RHX**(1.0-RHB(ISPC)) - RHXS**(1.0-RHB(ISPC))
      FCTRM  = -1.0/(RHM(ISPC)-1.0)
C
      IF (DEBUG)
     &WRITE(JOSTND,*) ' HTGF-HGMDRH FACTORS = ',
     &ISPC, RHX, FCTRKX, FCTRRB, FCTRXB, FCTRM
C
      HGMDRH = RHK * ( 1.0 + FCTRKX*EXP(FCTRRB*FCTRXB) ) ** FCTRM
C----------
C     APPLY WEIGHTED MODIFIER VALUES.
C----------
      WTCR = .25
      WTRH = 1.0 - WTCR
      HTGMOD = WTCR*HGMDCR + WTRH*HGMDRH
C----------
C    MULTIPLIED BY SCALE TO CHANGE FROM A YR. PERIOD TO FINT AND
C    MULTIPLIED BY XHT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
C----------
C
      IF(DEBUG) THEN
        WRITE(JOSTND,*)' IN HTGF, I= ',I,' ISPC= ',ISPC,'HTGMOD= ',
     &  HTGMOD,' ICR= ',ICR(I),' HGMDCR= ',HGMDCR
        WRITE(JOSTND,*)' HT(I)= ',HT(I),' AVH= ',AVH,' RELHT= ',RELHT,
     & ' HGMDRH= ',HGMDRH
      ENDIF
C
      IF (HTGMOD .GE. 2.0) HTGMOD= 2.0
      IF (HTGMOD .LE. 0.0) HTGMOD= 0.1
C
      HTG(I) = POTHTG * HTGMOD
C
      IF(DEBUG)    WRITE(JOSTND,901)ICR(I),PCT(I),BA,DG(I),HT(I),
     & POTHTG,BAL,AVH,HTG(I),DBH(I),RMAI,HGUESS
  901 FORMAT(' HTGF',I5,14F9.2)
C----------
C  HEIGHT GROWTH EQUATION, EVALUATED FOR EACH TREE EACH CYCLE
C  MULTIPLIED BY SCALE TO CHANGE FROM A YR. PERIOD TO FINT AND
C  MULTIPLIED BY XHT TO APPLY USER SUPPLIED GROWTH MULTIPLIERS.
C----------
C CHECK FOR HT GT MAX HT FOR THE SITE AND SPECIES
C
      TEMPH=H + HTG(I)
      SELECT CASE (ISPC)
      CASE(11,13:15,17:30,32)
        IF(TEMPH .GT. HTMAX2) HTG(I)=HTMAX2-H
      CASE DEFAULT
        IF(TEMPH .GT. HTMAX) HTG(I)=HTMAX-H
      END SELECT
      IF(HTG(I).LT.0.1)HTG(I)=0.1
      HTG(I)=SCALE*XHT*HTG(I)*EXP(HTCON(ISPC))
      IF(DEBUG) WRITE(JOSTND,*)' I=',I,' TEMPH=',TEMPH,
     &    ' D=',DBH(I),' DG=',DG(I),' H=',H,' HTG=',HTG(I),
     &    ' HTMAX2=',HTMAX2
  161 CONTINUE
C----------
C    APPLY DWARF MISTLETOE HEIGHT GROWTH IMPACT HERE,
C    INSTEAD OF AT EACH FUNCTION IF SPECIAL CASES EXIST.
C----------
      HTG(I)=HTG(I)*MISHGF(I,ISPC)
      TEMHTG=HTG(I)
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(I)+HTG(I)).GT.SIZCAP(ISPC,4))THEN
        HTG(I)=SIZCAP(ISPC,4)-HT(I)
        IF(HTG(I) .LT. 0.1) HTG(I)=0.1
      ENDIF
C
      IF(.NOT.LTRIP) GO TO 30
      ITFN=ITRN+2*I-1
      HTG(ITFN)=TEMHTG
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN)+HTG(ITFN)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN)=SIZCAP(ISPC,4)-HT(ITFN)
        IF(HTG(ITFN) .LT. 0.1) HTG(ITFN)=0.1
      ENDIF
C
      HTG(ITFN+1)=TEMHTG
C----------
C CHECK FOR SIZE CAP COMPLIANCE.
C----------
      IF((HT(ITFN+1)+HTG(ITFN+1)).GT.SIZCAP(ISPC,4))THEN
        HTG(ITFN+1)=SIZCAP(ISPC,4)-HT(ITFN+1)
        IF(HTG(ITFN+1) .LT. 0.1) HTG(ITFN+1)=0.1
      ENDIF
C
      IF(DEBUG) WRITE(JOSTND,9001) HTG(ITFN),HTG(ITFN+1)
 9001 FORMAT( ' UPPER HTG =',F8.4,' LOWER HTG =',F8.4)
C----------
C   END OF TREE LOOP
C----------
   30 CONTINUE
C----------
C   END OF SPECIES LOOP
C----------
   40 CONTINUE
      IF(DEBUG)WRITE(JOSTND,60)ICYC
   60 FORMAT(' LEAVING SUBROUTINE HTGF   CYCLE =',I5)
      RETURN
C
      ENTRY HTCONS
C----------
C  ENTRY POINT FOR LOADING HEIGHT INCREMENT MODEL COEFFICIENTS THAT
C  ARE SITE DEPENDENT AND REQUIRE ONE-TIME RESOLUTION.
C  LOAD OVERALL INTERCEPT FOR EACH SPECIES.
C----------
      DO 50 ISPC=1,MAXSP
      HTCON(ISPC)=0.0
      IF(LHCOR2 .AND. HCOR2(ISPC).GT.0.0) HTCON(ISPC)=
     &    HTCON(ISPC)+ALOG(HCOR2(ISPC))
   50 CONTINUE
C
      RETURN
      END