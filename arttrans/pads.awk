BEGIN {
  print "" > APTFN
}# BEGIN

{# main
  if((NF >= 4) && match($1,/[1-9][0-9]*/))
  {
    F_DSTR = "d"
    OUTXY = 1
    XSTR = $2 * 0.001
    YSTR = $3 * 0.001
    if(($4 == "LINE") || ($4 == "RND") || ($4 == "ODD"))
      APTTYPSTR = "Round"
    else if(($4 == "SQR") || ($4 == "SQRL"))
      APTTYPSTR = "Square"
    else if($4 == "OVAL")
      APTTYPSTR = "Oblong"
    else if($4 == "THER")
      APTTYPSTR = "Thermal"
    else if($4 == "RECT")
    {
      APTTYPSTR = "Rect"
      OUTXY = 2
    }
    else
      APTTYPSTR = "Round"
    if(OUTXY == 2)
      outbuf=sprintf("D%s %s %s %s %s %s",$1,XSTR,F_DSTR,APTTYPSTR,XSTR,YSTR);
    else if(OUTXY == 1)
      outbuf=sprintf("D%s %s %s %s %s",$1,XSTR,F_DSTR,APTTYPSTR,XSTR);
    else
      outbuf=sprintf("D%s %s %s %s",$1,XSTR,F_DSTR,APTTYPSTR);
    print outbuf >>APTFN
  }
}

END {
  close(APTFN)
}# END
