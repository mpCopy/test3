
  print "SUPPRESS CR" >APTFILE
  print "CIRCULAR off" >>APTFILE
  print "A:VIEW386" >>APTFILE
  print "GBR_END M02" >>APTFILE
  print "LINK off" >>APTFILE
  print "TEXT d11" >>APTFILE
  print "LINE d10" >>APTFILE
  print "MSCALE 1.0" >>APTFILE
  print "ARCRES 9" >>APTFILE
  print "REMOVE_HATCH off" >>APTFILE
  print "FLOATZERO off" >>APTFILE
  print "FONT /tmp/txt.shx" >>APTFILE
  print "FONTDIR /tmp/" >>APTFILE
  print "CIRANG 360" >>APTFILE
  print "REMOVE_DIM on" >>APTFILE

  ISENG=1
  if(length(DSNFILE)){
    RETVAL=getline < DSNFILE
    while(RETVAL == 1) {
      if ($1 ~ /Database_format:/) {print "FORMAT",$2>> APTFILE }
      if ($1 ~ /Coordinate_mode:/) {
        if($2 == "Absolute") print "ABSOLUTE on" >>APTFILE
        else print "ABSOLUTE off" >>APTFILE
      }
      if ($1 ~ /Zero_suppression:/) {
        if($2 == "Leading") print "SUPPRESS LEADING" >>APTFILE
        else {
          if($2 == "Trailing") print "SUPPRESS TRAILING" >>APTFILE
        }
      }
      if ($1 ~ /Coordinate_units:/) {
        if($2 == "English") { 
          print "APTUNITS inch" >>APTFILE
          ISENG=1
        }
        if($2 == "Metric") {
          print "APTUNITS mm" >>APTFILE
          ISENG=0
        }
      }
      RETVAL=getline < DSNFILE
    }
  }# if
  else {
    print "FORMAT 3.4" >> APTFILE 
    print "ABSOLUTE on" >>APTFILE
    print "SUPPRESS LEADING" >>APTFILE
    print "APTUNITS inch" >>APTFILE
  }# if else
}

{
  if($1 ~ /D[1-9][0-9][0-9]*/){
    APT = substr($1,2) + 0;
    AAPT=APT-10
    if(AAPT > 999) {next}
    if($2 == "ROUND")
      {TYPE = "Round"}
    if($2 == "DONUT")
      {TYPE = "Donut"}
    if($2 == "SQUARE")
      {TYPE = "Square"}
    if($2 == "RECTANGLE")
      {TYPE = "Rect"}
    if($2 == "THERMAL")
      {TYPE = "Thermal"}
    if($2 == "THMSQ")
      {TYPE = "Thmsq"}
    if($2 == "OCTAGON")
      {TYPE = "Octagon"}
    if($2 == "OBLONG")
      {TYPE = "Oblong"}
    if($2 == "TARGET")
      {TYPE = "Target"}
    if($2 == "CUSTOM")
      {TYPE = "Custom"}
    
    if(ISENG == 1) {
      DIA = $3 /1000
      XVAL = $3 /1000
      YVAL = $5 /1000
    }#if
    else {
      DIA = $4
      XVAL = $4
      YVAL = $6
    }#if
    if(TYPE == "Custom"){
      XVAL = $3
      YVAL = ""
      DIA = "0"
    }#if
    if(($11 > 0) &&($11 < 100)){
        if(ISENG == 1)
          TDIA = $12 /1000
        else
          TDIA = $13
        printf "%s %s d %s %s %s ( T%s %s )\n",$1,DIA,TYPE,XVAL,YVAL,$11,TDIA >>APTFILE
    }#if
    else
      print $1,DIA,"d",TYPE,XVAL,YVAL >>APTFILE
  }
}
END { 
  close(APTFILE) 
  if(length(DSNFILE))
    close(DSNFILE) 
}# END
