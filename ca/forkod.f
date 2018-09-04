      SUBROUTINE FORKOD
      IMPLICIT NONE
C----------
C CA $Id$
C----------
C
C     TRANSLATES FOREST CODE INTO A SUBSCRIPT, IFOR, AND IF
C     KODFOR IS ZERO, THE ROUTINE RETURNS THE DEFAULT CODE.
C
COMMONS
C
C
      INCLUDE 'PRGPRM.F77'
C
C
      INCLUDE 'PLOT.F77'
C
C
      INCLUDE 'CONTRL.F77'
C
C
COMMONS
C
      INTEGER JFOR(11),KFOR(11),NUMFOR
C----------
C  FORESTS IN THIS VARIANT:
C  505 = KLAMATH
C  506 = LASSEN
C  508 = MENDOCINO
C  511 = PLUMAS
C  514 = SHASTA-TRINITY
C  610 = ROGUE RIVER
C  611 = SISKIYOU
C  710 = ROSEBURG
C  711 = MEDFORD
C  712 = COOS BAY
C  518 = TRINITY (MAPPED TO SHASTA-TRINITY)
C----------
      INTEGER I
      DATA JFOR/505,506,508,511,514,610,611,710,711,712,518/,NUMFOR /11/
      DATA KFOR/11*1/
C
      IF (KODFOR .EQ. 0) GOTO 30
      DO 10 I=1,NUMFOR
      IF (KODFOR .EQ. JFOR(I)) GOTO 20
   10 CONTINUE
      CALL ERRGRO (.TRUE.,3)
      WRITE(JOSTND,55) JFOR(IFOR)
  55  FORMAT(T12,'FOREST CODE USED IN THIS PROJECTION IS ',I4)
      GOTO 30
   20 CONTINUE
      IF(I .EQ. 11)THEN
        WRITE(JOSTND,21)
   21   FORMAT(T12,'TRINITY NF (518) BEING MAPPED TO SHASTA-TRINITY ',
     &  '(514) FOR FURTHER PROCESSING.')
        I=5
      ENDIF
      IFOR=I
C
      IGL=KFOR(I)
   30 CONTINUE
      KODFOR=JFOR(IFOR)
      RETURN
      END