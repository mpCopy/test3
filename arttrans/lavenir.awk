BEGIN { 
  print "" > APTFN
  APTSHAPE[1] = "Round"
  APTSHAPE[2] = "Square"
  APTSHAPE[3] = "Rect"
  APTSHAPE[4] = "Oblong"
  APTSHAPE[5] = "Oblong"
  APTSHAPE[6] = "Thermal"
  APTSHAPE[7] = "Target"
  APTSHAPE[8] = "Thermal"
  APTSHAPE[9] = "Square"
  APTSHAPE[10] = "Custom"
  APTSHAPE[11] = "Poin"
  APTSHAPE[12] = "Poex"
  APTSHAPE[13] = "Target"
  APTSHAPE[14] = "Custom"
}

{
  if (NR == 3)
  {
    print "FORMAT " $1 "." $2 >>APTFN
    VAL = $3
    BIT0 = BIT1 = 0
    BIT2 = BIT3 = 0
    if(VAL >= 8)
    {
      BIT3 = 1
      VAL -= 8
    }
    if(VAL >= 4)
    {
      BIT2 = 1
      VAL -= 4
    }
    if(VAL >= 2)
    {
      BIT1 = 1
      VAL -= 2
    }
   if(VAL)
      BIT0 = 1

    if(BIT0)
      print "SUPPRESS LEADING"  >>APTFN
    else
      print "SUPPRESS TRAILING"  >>APTFN

    if(BIT1)
      print "ABSOLUTE on"  >>APTFN
    else
      print "ABSOLUTE off"  >>APTFN

    if(BIT2)
      print "APTUNITS mm"  >>APTFN
    else
      print "APTUNITS inch"  >>APTFN

    if(BIT3)
      print "CIRANG 360"  >>APTFN
    else
      print "CIRANG 90"  >>APTFN

  }
  else if (NR > 4)
  {
    if(NF < 4) # End of Aperture Definitions
    {
      close(APTFN)
      exit
    }
    DCSTR = $1
    DCLEN = split(DCSTR,DCARR,"-")
    if(DCLEN == 2)
    {
      DCMIN = DCARR[1]
      DCMAX = DCARR[2]
    }
    else
    {
      DCMIN = DCSTR
      DCMAX = DCSTR
    }
    AIDX = $2 + 1
    APTTYPE = APTSHAPE[AIDX]
    XSTR = $3
    YSTR = $4
    if((AIDX == 10) || (AIDX == 14))
      DCODEDEF = "0 d Custom"
    else
      DCODEDEF = sprintf("%s d %s %s %s",XSTR,APTTYPE,XSTR,YSTR)
    for(DCNUM=DCMIN; DCNUM<=DCMAX; ++DCNUM)
      print DCNUM, DCODEDEF >> APTFN
    
    
  }

}

END {
  close(APTFN)
}
