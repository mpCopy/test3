BEGIN {
  OF = ARGV[2]
  gsub(/^"/,"",OF)
  gsub(/"$/,"",OF)
  print "" >OF
} # BEGIN

{ # main

  PRT = 0

  BUFF=$0
  GFPARMLEN = split(BUFF,GFPARMARR,",")
  GBRFN=""
  FNCNT=""
  if(GFPARMLEN >= 1)
  {
    GBRFN = GFPARMARR[1]
    if(GFPARMLEN > 1)
      FNCNT = GFPARMARR[2]
  }
  if ( FNCNT == "" ) FNCNT = NR
  print "~~" FNCNT "*" >>OF
  RS = "*"
  RETVAL = getline < GBRFN
  while (RETVAL == 1){
    BUFF = $0
    gsub(/\n/,"",BUFF)
    gsub(/\r/,"",BUFF)
    POS = index(BUFF,"%")
    while(POS > 0){
      if(PRT == 0){
        PRT = 1
      } # if
      else {
        PRT = 0
        TMPBUFF = BUFF
        gsub(/%.*/,"",TMPBUFF)
        if(TMPBUFF != "")
          printf "%s*",TMPBUFF >>OF
      } # if else
      sub(/^[^%]*%/,"",BUFF)
      POS = index(BUFF,"%")
    } # while
    if(PRT == 0){
      if(match(BUFF,/[XYM][-+0-9]/) != 0){
        if(match(BUFF,/^G/) != 0){
          split(BUFF,BUFFARR)
          GCODE = substr(BUFFARR[1],2)
          sub(/^0*/,"",GCODE)
          if ((GCODE != 4)  &&
              (GCODE != 28) &&
              (GCODE != 53) &&
              (GCODE != 59))
            break
        } # if
      } # if
    } # if
    else {
      if(BUFF != "")
        printf "%s*",BUFF >>OF
    } # if else
    RETVAL = getline < GBRFN
  } # while
  close(GBRFN)
  RS = "\n"
} # main

END{
  close(OF)
} # END
