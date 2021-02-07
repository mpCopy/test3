
 OPMODE=0
 ZERO=0
 print "" >APTOUT
} #BEGIN

{ #main

  if ( OPMODE == 0 ) {
    if ( $1 ~ /Aperture/ )
      OPMODE=1 
    next
  } #if 0

  if ( OPMODE == 1 ) {
    if ( $1 !~ /^[0-9][0-9]*$/ )
      OPMODE=2 
    else
      next
  } #if 1

  if ( $0 ~ /coordinate mode/ ) { 
    if ( $0 ~ /absolute/ )
      print "ABSOLUTE on" >APTOUT
    else
      print "ABSOLUTE off" >APTOUT
    next
  } #if
  if ( $0 ~ /circular interpolation/ ) {
    if ( $0 ~ / not / )
      print "CIRCULAR off" >APTOUT
    else
      print "CIRCULAR on" >APTOUT
    next
  } #if
  if ( $0 ~ /interpolated/ ) { 
    ARCRES=360.0/$7
    if ( ARCRES < 0.5 )
      ARCRES=0.5
    if ( ARCRES > 15 )
      ARCRES=15
    print "ARCRES", ARCRES >APTOUT
    next
  } #if
  if ( $0 ~ /units/ ) { 
    if ( $3 ~ /inch/ ) 
      print "APTUNITS inch" >APTOUT
    else
      print "APTUNITS mm" >APTOUT
    next
  } #if
  if ( $0 ~ /Scale/ ) {
    print "MSCALE", $3 >APTOUT
    next
  } #if
  if ( $0 ~ /format/ ) { 
    print "FORMAT", $3 >APTOUT
    next
  } #if
  if ( $0 ~ /Leading zeros/ ) { 
    if ( ZERO == 0 ) {
      if ( $0 ~ /not/ || $0 !~ /present/ ) {
        print "SUPPRESS LEADING" >APTOUT
        ZERO=1
      } #if 
    } #if
    next
  } #if
  if ( $0 ~ /Trailing zeros/ ) { 
    if ( ZERO == 0 ) {
      if ( $0 ~ /not/ || $0 !~ /present/ ) {
        print "SUPPRESS TRAILING" >APTOUT
        ZERO=1
      } #if
    } #if
    next
  } #if

} # main

END {
  close(APTOUT)
}#END
