
 YXORD=1
 OPMODE=0
 DTYP=1
} # BEGIN

{ #main

  if ( OPMODE == 0 ) {
    if (( $0 ~ /Position.*Shape/ ) ||
       ( $0 ~ /Position.*Diameter/ )) {
      OPMODE=1 
      if ( $1 ~ /Aperture/ ) {
        DTYP=1
      } else {
        DTYP=2
      } #if
      if ( $0 ~ /Y.*X/ )
        YXORD=1
      else
        YXORD=0
    } #if
    next
  } #if 0

  if ( OPMODE == 1 ) {
    if ( $1 !~ /^[0-9][0-9]*$/ )
      OPMODE=2 
    else {
      if ( $0 ~ /trace/ )
        DORF="d"
      else
        DORF="f"
      if ( DTYP == 1 ) {
        if ( NF < 7 )
          next
        DTYPI=$3
        CODEI=$2
        if ( $0 ~ /power/ ) {
          if ( $3 ~ /rect/ )
            TYPE="Thmsq"
          else
            TYPE="Thermal"
          VAL1=$6
          VAL2=$7
        } else { #power
          if ( $3 ~ /rect/ )
            TYPE="Rect"
          else
            TYPE="Round"
          VAL1=$5
          VAL2=$6
        } #if power
      } else {
        if ( NF < 10 )
          next
        DTYPI=$2
        if (( ($3 == "trace,") && ($4 == "flash") ) ||
            ( ($3 == "flash,") && ($4 == "trace") )) {
          CODEI=$10
          ARG8=$9
          VAL1=$5
          VAL2=$6
        } else {
          CODEI=$9
          ARG8=$8
          VAL1=$4
          VAL2=$5
        } # if
        if ( ARG8 ~ /false/ ) {
          if ( $2 ~ /rect/ )
            TYPE="Rect"
          else
            TYPE="Round"
        } else {
          if ( $2 ~ /rect/ )
            TYPE="Thmsq"
          else
            TYPE="Thermal"
        } #if
      } #if DTYP
      if ( DTYPI ~ /rect/ ) {
        if ( YXORD == 1 ) {
          XVAL=VAL2
          YVAL=VAL1
        } else {
          XVAL=VAL1
          YVAL=VAL2
        } #if
      } else {
        if ( VAL1 == 0.0 ) {
          XVAL=VAL2
          YVAL=0
        } else {
          XVAL=VAL1
          YVAL=0
        } #if
      } #if
      if ( XVAL < YVAL ) {
        if ( XVAL > 0.0 )
          DIA=XVAL
        else
          DIA=YVAL
      } else {
        if ( YVAL > 0.0 )
          DIA=YVAL
        else
          DIA=XVAL
      } #if
      if( DORF == "f" )
        DIA="D"CODEI
      print "D" CODEI, DIA, DORF, TYPE, XVAL, YVAL >TMPFILE
      next
    } #if
  } #if 1

  exit
} # main

END{
  close(TMPFILE)
}#END
