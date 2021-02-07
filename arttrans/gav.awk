BEGIN {
  print "" > APTFN
}# BEGIN

{# main
  if(NF >= 5)
  {
    F_DSTR = "d"
    OUTXY = 1
    XSTR = $2
    YSTR = $3
    if(($5 == "NOT-SET") || ($5 == "FILLED-CIRCLE"))
      APTTYPSTR = "Round"
    else
      APTTYPSTR = "Round"
    if(OUTXY == 2)
      outbuf=sprintf("%s %s %s %s %s %s",$1,XSTR,F_DSTR,APTTYPSTR,XSTR,YSTR);
    else if(OUTXY == 1)
      outbuf=sprintf("%s %s %s %s %s",$1,XSTR,F_DSTR,APTTYPSTR,XSTR);
    else
      outbuf=sprintf("%s %s %s %s",$1,XSTR,F_DSTR,APTTYPSTR);
    print outbuf >>APTFN
  }
}

END {
  close(APTFN)
}# END
