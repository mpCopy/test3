BEGIN {
  GBRFN=""
  LAYERS=""
  LAYER=1
  COLOR[1]=",255,0,0"
  COLOR[2]=",0,255,0"
  COLOR[3]=",255,255,0"
  COLOR[4]=",0,0,255"
  COLOR[5]=",255,0,255"
  COLOR[6]=",0,255,255"
  DRAWD="Paint"
  DRAWC="Scratch"
  OUTDRAW=DRAWD
  OUTI=0
  OUTI2=1
  SRMODE=0
  LPMODE=0
  GBRDATA=0
  IPPOS = 1
  LPSET = 0
  SRSET = 0

  OUTDRAW2 = ""
  NEGLAYFND = 0
} # BEGIN

function SendLayer(LNUM,FN,DRAWV)
{
  DRLEN = split(GBRFN,DRARR,/[\/\\]/)
  if (DRLEN == 0 )
    LNAME = GBRFN
  else
  {
    LNAME = DRARR[DRLEN]
    BNLEN = split(LNAME,BNARR,".")
    if(BNLEN)
      LNAME = BNARR[1]
  }

  DLTR = substr(DRAWV,1,1);

  if(match(DLTR,"N") && NEGLAYFND)
    OUTDRAWV = "Scratch"
  else
    OUTDRAWV = DRAWV

  if(match(DLTR,"N"))
  {
    LNTAG = "D"
    NEGLAYFND = 1
  }
  else if(match(DLTR,"S"))
    LNTAG = "C"
  else if(match(DLTR,"P"))
  {
    if(IPPOS)
      LNTAG = "D"
    else
      LNTAG = "C"
  }
  if(IPPOS)
    IPTAG = "P"
  else
    IPTAG = "N"
  LNTAG = "_" LPSRARR[LNUM] LNTAG IPTAG

  LNAME = LNAME LNTAG OUTI2

  print "[layer" LNUM "]" >>JOBFN
  print "layer=" LNAME "," FN >>JOBFN
  LAYCOL=LNUM % 6
  if ( LAYCOL == 0 ) LAYCOL=6
  print "gbrvulopt=ON," OUTDRAWV COLOR[LAYCOL] >>JOBFN

  if ( LAYERS != "" ) LAYERS=LAYERS ","
  LAYERS=LAYERS "layer" LNUM
  OUTI2 = OUTI2 + 1
  OUTDRAW2 = ""
} # SendLayer

function IsMassParm(STR)
{
  MPSTR = STR
  gsub(/[%\n]/,"",MPSTR)
  if(match(MPSTR,/^ADD/)) 
    return 1
  else if(match(MPSTR,/^A[ADMPRSV]/)) 
    return 1
  else if(match(MPSTR,/^BD/)) 
    return 1
  else if(match(MPSTR,/^DL/)) 
    return 1
  else if(match(MPSTR,/^FS/)) 
    return 1
  else if(match(MPSTR,/^I[CDFJNOPR]/)) 
    return 1
  else if(match(MPSTR,/^KO/)) 
    return 1
  else if(match(MPSTR,/^L[NPS]/)) 
    return 1
  else if(match(MPSTR,/^M[IO]/)) 
    return 1
  else if(match(MPSTR,/^N[SF]/)) 
    return 1
  else if(match(MPSTR,/^O[FP]/)) 
    return 1
  else if(match(MPSTR,/^P[EFKO]/)) 
    return 1
  else if(match(MPSTR,/^R[CO]/)) 
    return 1
  else if(match(MPSTR,/^S[FMRS]/)) 
    return 1
  else if(match(MPSTR,/^SCC/)) 
    return 1
  else if(match(MPSTR,/^TR/)) 
    return 1
  else if(match(MPSTR,/^VL/)) 
    return 1
  else if(match(MPSTR,/^WI/)) 
    return 1

  return 0
}

{ # main

  INPFN = ARGV[1]
  RETVAL=getline < INPFN
  while( RETVAL == 1) {
    BUFF=$0
    GFPARMLEN = split(BUFF,GFPARMARR,",")
    if(GFPARMLEN)
    {
      OUTI2 = 1
      GBRFN = GFPARMARR[1]
      if(GFPARMLEN > 1)
        LAYNO = GFPARMARR[2]
      if(GFPARMLEN > 2)
        FILETYPE = GFPARMARR[3]
    }
    else
    {
      GBRFN=""
      LAYNO = 0
      FILETYPE = 0
    }

    JOBFN=APTFN
    sub(/\.apt$/,".job",JOBFN)
    sub(/\.APT$/,".JOB",JOBFN)
    DATAPATH=APTFN
    LEN=match(DATAPATH,/[^\/]*$/)
    LEN--
    DATAPATH=substr(DATAPATH,1,LEN)
    print "" > JOBFN

    FTLINCNT = 0
    OUTFN=GBRFN
    OUTI=OUTI+1
    if(OUTI < LAYNO)
      OUTI = LAYNO
    LAYI=OUTI
    LPSRARR[LAYI] = "LP"

    FPOS=0
    RS="*"
    DRAW=""
    RETVAL=getline < GBRFN
    if(RETVAL != 1) {
      GBRFN=tolower(GBRFN)
      RETVAL=getline < GBRFN
    } # if
    while(RETVAL == 1) {
      BUFF = $0
      #gsub(/[\r\n]/,"",BUFF) Unix Only
      XX = match(BUFF,/[^A-Z]D0[1-3][^0-9]/)
      YY = match(BUFF,/[^A-Z]D0[1-3]$/)
      if( match(BUFF,/^M[03][0-2]/) != 0 )
        break
      if(FILETYPE == 1) # if DOS file ?
      {
        FTBUFF=BUFF
        FTLNCNT = gsub(/[\n]/,"",FTBUFF)
      } # if
      if( match(BUFF,/^G0*4/) != 0 )
      {
        FPOS = FPOS + length($0) + 1 + FTLNCNT
        RETVAL=getline < GBRFN
        continue
      }
      if( (IsMassParm(BUFF)) == 0 ) {
        if( (match(BUFF,/[^A-Z]D0[1-3][^0-9]/) != 0) ||
                 (match(BUFF,/[^A-Z]D0[1-3]$/) != 0) ){

          LPSET = 0
          SRSET = 0
          GBRDATA=1
          if(SRMODE || LPMODE) {
            if(SRMODE)
              OUTFPOS = SRFPOS
            else if(LPMODE)
              OUTFPOS = LPFPOS
            if(!LPMODE)
            {
              if(OUTDRAW2 == "")
                OUTDRAW2 = DRAWD
              if( DRAW=="" ) 
                DRAW=DRAWD
              OUTDRAW = DRAW
              DRAW=DRAW2
            }
            if(OUTDRAW2 != "")
              SendLayer(LAYI,OUTFN,OUTDRAW)
            OUTFN="@<" OUTI ">:" OUTFPOS
            LAYI=LAYI+1
            SRMODE = 0
            LPMODE = 0
          }
        } 
      } else {
        TMPBUFF=BUFF
        gsub(/[%\n]/,"",BUFF)

        if(match(BUFF,"^SR")) 
        {
          if(match(BUFF,/X/) ||
             match(BUFF,/Y/))
            SRSET = 1
          else
            LPSET = 1
        }
        else if( match(BUFF,"^LP") != 0 ) 
          LPSET = 1

        if(!GBRDATA)
          LSIDX = LAYI
        else
          LSIDX = LAYI + 1

        if(SRSET)
          LPSRARR[LSIDX] = "SR"
        else if(LPSET)
          LPSRARR[LSIDX] = "LP"

        if( match(BUFF,"^IP") != 0 ) {
          if( match(BUFF,"^IPNEG") != 0 ) {
            IPPOS = 0
            DRAWD="Negative"
            DRAWC="Paint"
          } else {
            IPPOS = 1
            DRAWD="Paint"
            DRAWC="Scratch"
          } # if
          OUTDRAW = DRAWD
        }
        else if( (match(BUFF,"^SR") != 0 ) && (GBRDATA==1)) {
          SRFPOS = FPOS
          SRMODE = 1
          if( match(TMPBUFF,"^%\n*%") != 0 )
            ++SRFPOS
        } else {
          if( match(BUFF,"^LP") != 0 ) {
            if( match(BUFF,"^LPD") != 0 ) {
              DRAW2=DRAWD
            } else {
              DRAW2=DRAWC
            } # if
            if( DRAW=="" ) {
              DRAW=DRAWD
            } # if 
            if(OUTDRAW2 == "")
              OUTDRAW2 = DRAW2
            else
              SendLayer(LAYI,OUTFN,OUTDRAW)
            if( DRAW!=DRAW2 ) {
              LPMODE = 1
              LPFPOS = FPOS
              if( match(TMPBUFF,"^%\n*%") != 0 )
                ++LPFPOS
              OUTDRAW = DRAW
              DRAW=DRAW2
            } # if
            else
              OUTDRAW2 = ""
          } # if else
        } # if else
      } # if %
      FPOS = FPOS + length($0) + 1 + FTLNCNT
      RETVAL=getline < GBRFN
    } # while
    close(GBRFN)
    if( DRAW=="" ) {
      DRAW=DRAWD
    } # if
    SendLayer(LAYI,OUTFN,DRAW)
    OUTI=LAYI
    RS="\n"
    SRMODE=0
    LPMODE=0
    GBRDATA=0
    LPSET = 0
    SRSET = 0
    RETVAL=getline < INPFN
  } # while getline INPFN
} # main

END {
  print "[General]" >>JOBFN
  print "layers=" LAYERS >>JOBFN
  print "aptfile=" APTFN >>JOBFN
} # END
