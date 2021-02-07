  FORMAT=2.4
  COORD="ABS"
  ZERO="NONE"
  NOWHEEL=0
  UNIT="INCH"
} # BEGIN

$1 ~ /FORMAT/    { FORMAT=$2 ; next }
$2 ~ /FORMAT/    { if ( $1 == "#") {
                     FORMAT=$3 
                     NOWHEEL=1
                   } # if 
                   next 
                 }
$1 ~ /COORD/     { if ( match($2,/ABS/) != 0 )
                     COORD="ABS"
                   else
                     COORD="REL"
                   next
                 } # COORD
$2 ~ /COORD/     { if ( $1 == "#" ) 
                     if ( match($3,/ABS/) != 0 )
                       COORD="ABS"
                     else
                       COORD="REL"
                   next
                 } # COORD
$1 ~ /LEAD-Z/    { if ( $2 == "YES" ) ZERO="LEAD" ; next }
$2 ~ /LEAD-Z/    { if (( $1 == "#" ) && ( $3 == "YES" )) ZERO="LEAD" ; next }
$1 ~ /TRAIL-Z/   { if ( $2 == "YES" ) ZERO="TRAIL" ; next }
$2 ~ /TRAIL-Z/   { if (( $1 == "#" ) && ( $3 == "YES" )) ZERO="TRAIL" ; next }
$1 ~ /INPUT-UN/  { if (( $2 == "METRIC" ) || ( $2 == "MM" )) UNIT="MM" ; next }
$2 ~ /INPUT-UN/  { if (( $1 == "#" ) && 
                       (( $3 == "METRIC" ) || ( $3 == "MM" )))
                     UNIT="MM" ; next }

{ # main

  if ( match($1,/^ *#/) ) next
  if (( NOWHEEL == 0 ) && ( match($1,/^WHEEL/) == 0 )) next

  print "FORMAT", FORMAT > APTFN
  print "APTUNITS", UNIT >> APTFN
  if ( UNIT == "MM" )
    MULTI = 1
  else
    MULTI = 1000
  if ( COORD == "ABS" )
    print "ABSOLUTE on" >> APTFN
  else
    print "ABSOLUTE off" >> APTFN
  if ( ZERO == "LEAD" )
    print "SUPPRESS LEADING" >> APTFN
  else
  if ( ZERO == "TRAIL" )
    print "SUPPRESS TRAILING" >> APTFN

  RETVAL=getline
  while(RETVAL == 1) {
    if ( match($1,/CIRCLE/) != 0 ) {
      XVAL=$2 / MULTI
      print $3, XVAL, "d Round", XVAL, XVAL >> APTFN
    } else
    if ( match($1,/SQUARE/) != 0 ) {
      XVAL=$2 / MULTI
      print $4, XVAL, "d Square", XVAL, XVAL >> APTFN
    } else
    if ( match($1,/RECT/) != 0 ) {
      XVAL=$2 / MULTI
      YVAL=$3 / MULTI
      print $5, XVAL, "d Rect", XVAL, YVAL >> APTFN
    } else
    if ( match($1,/OBLONG/) != 0 ) {
      XVAL=$2 / MULTI
      YVAL=$3 / MULTI
      print $5, XVAL, "d Oblong", XVAL, YVAL >> APTFN
    } else
    if ( match($1,/LINE/) != 0 ) {
      XVAL=$2 / MULTI
      print $3, XVAL, "d Round", XVAL, XVAL >> APTFN
    } else
    if ( match($1,/FLASH/) != 0 ) {
      if ( match($2,/^TR[0-9]*[X][0-9]*[X][0-9]*[X][0-9]*/) != 0 ) {
        split($2,TRLT,"X")
        gsub(/TR/,"",TRLT[1])
        TRLT[1] /= MULTI
        TRLT[2] /= MULTI
        TRLT[3] /= MULTI
        TRLT[4] /= MULTI
        print $4,TRLT[1],"d Thermal",TRLT[1],TRLT[2]","TRLT[3] >>APTFN
      } else

      if ( match($2,/^TS[0-9]*[X][0-9]*[X][0-9]*[X][0-9]*/) != 0 ) {
        split($2,TRLT,"X")
        gsub(/TS/,"",TRLT[1])
        TRLT[1] /= MULTI
        TRLT[2] /= MULTI
        TRLT[3] /= MULTI
        TRLT[4] /= MULTI
        print $4,TRLT[1],"d Thermal",TRLT[1],TRLT[2]","TRLT[3] >>APTFN
      } else

      if ( match($2,/^DR[0-9]*[X][0-9]*/) != 0 ) {
        split($2,TRLT,"X")
        gsub(/DR/,"",TRLT[1])
        TRLT[1] /= MULTI
        TRLT[2] /= MULTI
        print $4,TRLT[1],"d Round",TRLT[1],TRLT[1] >>APTFN
      } else

      if ( match($2,/^DS[0-9]*[X][0-9]*/) != 0 ) {
        split($2,TRLT,"X")
        gsub(/DS/,"",TRLT[1])
        TRLT[1] /= MULTI
        TRLT[2] /= MULTI
        print $4,TRLT[1],"d Square",TRLT[1],TRLT[1] >>APTFN
      } else

      if ( match($2,/^TR[0-9]*\/[0-9]*\/[0-9]/) != 0 ) {
        print $2
        split($2,TRLT,"X")
        gsub(/TR.*/,"",TRLT[3])
        TRLT[1] /= MULTI
        TRLT[2] /= MULTI
        TRLT[3] /= MULTI
        print $4,TRLT[1],"d Thermal",TRLT[1],TRLT[2]","TRLT[3]",45">>APTFN
      } else

      if ( match($2,/TREL/) != 0 ) {
        XVAL=$2
        sub(/TREL0*/,"",XVAL)
        XVAL /= MULTI
        print $4, XVAL, "d Thermal", XVAL, XVAL >> APTFN
      } else
      if ( match($2,/^THR/) != 0 ) {
        XVAL=$2
        sub(/THR*/,"",XVAL)
        XVAL /= MULTI
        YVAL = XVAL-(20/MULTI)
        print $4, XVAL, "d Thermal", XVAL, YVAL >> APTFN
      } else
      if ( match($2,/^T/) != 0 ) {
        XVAL=$2
        sub(/T*/,"",XVAL)
        XVAL /= MULTI
        YVAL = XVAL-(20/MULTI)
        print $4, XVAL, "d Thermal", XVAL, YVAL >> APTFN
      } else
      if ( match($2,/DOT/) != 0 ) {
        print $4, ".005 d Round .005 .005" >> APTFN
      } else {
        print $4, $2, "f Round 0 0" >> APTFN
      } # if 
    } # if
    RETVAL=getline
  } # while
} # main
