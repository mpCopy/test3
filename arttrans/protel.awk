  print "" > APTFN
  FSOUT=0
  MOOUT=0

  if ( GBRFN == "" ) {
    print "FORMAT 2.3" >> APTFN
    print "SUPPRESS LEADING" >> APTFN
    print "ABSOLUTE on" >>APTFN 
  } else { 
    RS="*"
    RETVAL=getline < GBRFN
    if(RETVAL != 1) {
      GBRFN=tolower(GBRFN)
      RETVAL=getline < GBRFN
    } # if
    if ( RETVAL == 1 ) {
      while(RETVAL == 1) {
        BUFF = $0
        if( match(BUFF,/M[03][0-2]/) != 0 )
          break
        if( match(BUFF,/%/) != 0 ) {
          gsub(/[%\n]/,"",BUFF)
          if((match(BUFF,/^FS/)) && (FSOUT == 0)){
            BUFFLEN = length(BUFF)
            KEY = substr(BUFF,3,(BUFFLEN-2))
            if(match(KEY,/^[LTD]/)){
              if(match(KEY,/^L/))
                print "SUPPRESS LEADING" >>APTFN 
              else
              if(match(KEY,/^T/))
                print "SUPPRESS TRAILING" >>APTFN 
              KEY = substr(BUFF,4,BUFFLEN-3)
            } # if
            if(match(KEY,/^[AI]/)){
              if(match(KEY,/^A/))
                print "ABSOLUTE on" >>APTFN 
              else
              if(match(KEY,/^I/))
                print "ABSOLUTE off" >>APTFN 
            } # if
            POS = match(KEY,"X")
            if(POS){
              KEY = substr(KEY,POS+1,2)
              printf "FORMAT %lg\n",KEY/10 >>APTFN
              FSOUT = 1
            } # if
          } else
          if((match(BUFF,/^MO/)) && (MOOUT == 0)){
            KEY = substr(BUFF,3,2)
            if(KEY == "MM")
              print "APTUNITS mm" >>APTFN
            else
            if(KEY == "IN")
              print "APTUNITS inch" >>APTFN
            MOOUT = 1
          }
        } else
        if ( match(BUFF,/^[MGDXYIJ]/) != 0 )
          break
        RETVAL=getline < GBRFN
      } # while
      close(GBRFN)
    } # if
    RS="\n"
  } # if GBRFN
} # BEGIN

{ # main
  DCODVAL = $1
  if ( match($1,/^D[0-9]+$/) != 0 ) { # Start by a DCODE
    sub(/D0*/,"",DCODVAL)
    if ( DCODVAL == "" ) next
    if (( DCODVAL >= 10 ) && ( DCODVAL <= 999 )) {
      XVAL=$3 / 1000
      YVAL=$4 / 1000
      if ( match($6,/FLASH/) != 0 )
        DORF="f"
      else
        DORF="d"
      if ( match($2,/RECT/) != 0 ) {
        print $1, XVAL, DORF, "Rect", XVAL, YVAL >> APTFN
      } else 
      if ( match($2,/OCTA/) != 0 ) {
        print $1, XVAL, DORF, "Octagon", XVAL, XVAL >> APTFN
      } else 
      if ( match($2,/RELIEF/) != 0 ) {
        print $1, XVAL, DORF, "Thermal", XVAL, XVAL >> APTFN
      } else { # if ( match($2,/ROUND/) != 0 ) 
        if (XVAL != YVAL) {
          print $1, XVAL, DORF, "Oblong", XVAL, YVAL >> APTFN
        } else {
          print $1, XVAL, DORF, "Round", XVAL, XVAL >> APTFN
        }
      } # if
    } # if
  } # if
} # main
