BEGIN { 
  DRAW=0 
  GBRFN="" 
  gsub(/^"/,"",APTFN)
  gsub(/"$/,"",APTFN)
  APTONLY=0
  POLYOUT=0
  MACOUT=0
  P_DCODE = 10
  PREVFN = ""
  CUSTREF = 0
  CUSTREFI = 1
  PREVLAY = 0
  CURRLAY = 0
  FSOUT=0
  MOOUT=0

  #3 sided POLYGON
  PVLIST[1] = 0
  PVLIST[2] = 1
  PVLIST[3] = -0.5             #COS 210
  PVLIST[4] = -0.8660254037844 #SIN 210
  PVLIST[5] = -PVLIST[3]       #COS 330
  PVLIST[6] = PVLIST[4]        #SIN 330
  #4 sided POLYGON
  PVLIST[7] = 0
  PVLIST[8] = 1
  PVLIST[9] = -1
  PVLIST[10] = 0
  PVLIST[11] = 0
  PVLIST[12] = -1
  PVLIST[13] = 1
  PVLIST[14] = 0
  #5 sided POLYGON
  PVLIST[15] = 0
  PVLIST[16] = 1
  PVLIST[17] = -0.9510565162952 #COS 162
  PVLIST[18] =  0.3090169943749 #SIN 162
  PVLIST[19] = -0.5877852522925 #COS 234
  PVLIST[20] = -0.8090169943749 #SIN 234
  PVLIST[21] = -PVLIST[19]
  PVLIST[22] = PVLIST[20]
  PVLIST[23] = -PVLIST[17]
  PVLIST[24] = PVLIST[18]
  #6 sided POLYGON
  PVLIST[25] = 0
  PVLIST[26] = 1
  PVLIST[27] = PVLIST[3]        #COS 150
  PVLIST[28] = -PVLIST[4]       #SIN 150
  PVLIST[29] = PVLIST[3]        #COS 210
  PVLIST[30] = PVLIST[4]        #SIN 210
  PVLIST[31] = 0
  PVLIST[32] = -1
  PVLIST[33] = -PVLIST[29]
  PVLIST[34] = PVLIST[30]
  PVLIST[35] = -PVLIST[27]
  PVLIST[36] = PVLIST[28]
  #7 sided POLYGON
  PVLIST[37] = 0
  PVLIST[38] = 1
  PVLIST[39] = -0.781831482468  #COS  141.42857142857
  PVLIST[40] =  0.6234898018587 #SIN  141.42857142857
  PVLIST[41] = -0.9749279121818 #COS  192.8571428571
  PVLIST[42] = -0.2225209339563 #SIN  192.8571428571
  PVLIST[43] = -0.4338837391176 #COS  244.2857142857
  PVLIST[44] = -0.9009688679023 #SIN  244.2857142857
  PVLIST[45] = -PVLIST[43]
  PVLIST[46] = PVLIST[44]
  PVLIST[47] = -PVLIST[45]
  PVLIST[48] = PVLIST[46]
  PVLIST[49] = -PVLIST[47]
  PVLIST[50] = PVLIST[48]
  #9 sided POLYGON
  PVLIST[51] = 0
  PVLIST[52] = 1
  PVLIST[53] = -0.6427876096865 #COS 130
  PVLIST[54] =  0.766044443119  #SIN 130
  PVLIST[55] = -0.9848077530122 #COS 170
  PVLIST[56] =  0.1736481776669 #SIN 170
  PVLIST[57] = PVLIST[3]        #COS 210
  PVLIST[58] = PVLIST[4]        #SIN 210
  PVLIST[59] = -0.3420201433257 #COS 250
  PVLIST[60] = -0.9396926207859 #SIN 250
  PVLIST[61] = -PVLIST[59]
  PVLIST[62] = PVLIST[60]
  PVLIST[63] = -PVLIST[57]
  PVLIST[64] = PVLIST[58]
  PVLIST[65] = -PVLIST[55]
  PVLIST[66] = PVLIST[56]
  PVLIST[67] = -PVLIST[53]
  PVLIST[68] = PVLIST[54]
  #10 sided POLYGON
  PVLIST[69] = 0
  PVLIST[70] = 1
  PVLIST[71] = -0.5877852522925 #COS 126
  PVLIST[72] =  0.8090169943749 #SIN 126
  PVLIST[73] = PVLIST[17]       #COS 162
  PVLIST[74] = PVLIST[18]       #SIN 162
  PVLIST[75] = -0.9510565162952 #COS 198
  PVLIST[76] = -0.3090169943749 #SIN 198
  PVLIST[77] = PVLIST[19]       #COS 234
  PVLIST[78] = PVLIST[20]       #SIN 234
  PVLIST[79] = 0
  PVLIST[80] = -1
  PVLIST[81] = -PVLIST[77]
  PVLIST[82] = PVLIST[78]
  PVLIST[83] = -PVLIST[75]
  PVLIST[84] = PVLIST[76]
  PVLIST[85] = -PVLIST[73]
  PVLIST[86] = PVLIST[74]
  PVLIST[87] = -PVLIST[71]
  PVLIST[88] = PVLIST[72]

  PVIDXLIST[1] = 0
  PVIDXLIST[2] = 0
  PVIDXLIST[3] = 1
  PVIDXLIST[4] = 7
  PVIDXLIST[5] = 15
  PVIDXLIST[6] = 25
  PVIDXLIST[7] = 37
  PVIDXLIST[8] = 0
  PVIDXLIST[9] = 51
  PVIDXLIST[10] = 69

  for(IBA=1; IBA<=256; ++IBA)
    BASELAYARR[IBA] = 0
  BASELAYTOTCNT=0
  LAYIDX=0
  JOBFN = APTFN
  sub(".apt",".job",JOBFN)
  sub(".APT",".JOB",JOBFN)
  RETVAL=getline < JOBFN
  while(RETVAL == 1) {
    if(match($1,/^layer=/)) {
      LAYSTR=substr($1,7)
      split(LAYSTR,LAYKEYS,",")
      if(match(LAYKEYS[2],/^@</)){
        POS = index(LAYKEYS[2],">")
        BASELAY = substr(LAYKEYS[2],3,(POS - 3))
        ++BASELAYARR[BASELAY]
        ++BASELAYTOTCNT
      } # if
      else
      {
        ++LAYIDX
        BASELAYARR[LAYIDX]=BASELAYTOTCNT
      } #if else
    } # if
    RETVAL=getline < JOBFN
  } # while
  close(JOBFN)
  DATAPATH=APTFN
  LEN=match(DATAPATH,/[^\/]*$/)
  LEN--
  DATAPATH=substr(DATAPATH,1,LEN)
  RS="*"
  GRID=10000
  print "" >APTFN
  _PI_ = 3.14159265358979323846
}

function joinPath(PTH,FN) {
  if ( index(FN,"/") != 0 )
    return FN
  else {
    if ( PTH != "/" )
      sub(/[\/]*$/,"",PTH)
    if ( PTH == "." )
      PTH=""
    if ( PTH == "" )
      FNAME=FN
    else
      FNAME=PTH "/" FN
    return FNAME
  } # if
} # joinPath

function round_(NUM)
{
  if ((NUM < 1.0e-6) && (NUM > -1.0e-6))
    return 0

  RNDVAL = NUM
  DV = 0
  POS = index(NUM,".")
  if(POS){
    RNDVAL = substr(NUM,1,(POS-1))
    DV = substr(NUM,POS+1,1)
  } # if
  if(DV >= 5){
    if (NUM > 0)
      ++RNDVAL
    else
      --RNDVAL
  } #if
  return RNDVAL
} # round_

function abs_(NUM)
{
  AV = NUM
  if(AV < 0)
    AV *= -1
  return AV
} # abs_

function FEqual_(NUM1,NUM2)
{
  AV = (NUM1-NUM2)
  if(AV < 0)
    AV *= -1
  if(AV < 0.00000001)
    return 1
  return 0
} # FEqual_

function rotate_(XY,SINA,COSA)
{
  XR = (XY[1]*COSA) - (XY[2]*SINA)
  YR = (XY[1]*SINA) + (XY[2]*COSA)
  XY[1] = XR
  XY[2] = YR
} # rotate_

function AddPrimBuff(PRIMBUFF)
{
  if(!length(CUSTPARMSTR[CUSTPARMI]))
    CUSTPARMSTR[CUSTPARMI] = PRIMBUFF
  else
    CUSTPARMSTR[CUSTPARMI] = CUSTPARMSTR[CUSTPARMI] "\n" PRIMBUFF
} # AddPrimBuff

function outLINE(XY1,XY2,WIDTH,HEIGHT)
{
  LINEOUT = 0
  APTTYPE = "Rect"
  if(FEqual_(XY1[1], XY2[1])){         # Vertical
    XVAL = WIDTH
    YVAL = abs_(XY2[2]-XY1[2])
    VAL = (XY1[1]*GRID)
    XCTR = round_(VAL)
    YCTR = round_(((XY2[2]+XY1[2])/2)*GRID)
  } # if
  else if(FEqual_(XY1[2], XY2[2])){    # Horizontal
    XVAL = abs_(XY2[1]-XY1[1])
    YVAL = HEIGHT
    XCTR = round_(((XY2[1]+XY1[1])/2)*GRID)
    YCTR = round_(XY1[2]*GRID)
  } # else if
  else if(WIDTH == 0) { # Non orthogonal && NO WIDTH
    LINEOUT = 1
    APTTYPE = "Round"
    XVAL = 0
    YVAL = 0
    XPT0=round_((XY1[1]) * GRID)
    YPT0=round_((XY1[2]) * GRID)
    print "D" P_DCODE "*X" XPT0 "Y" YPT0 "D02*" >> CUSTFN
    XPT1=round_((XY2[1]) * GRID)
    YPT1=round_((XY2[2]) * GRID)
    print  "X" XPT1 "Y" YPT1 "D01*" >> CUSTFN
  } # else if
  else { # Non orthogonal && WIDTH
    LINEOUT = 1
    APTTYPE = "Poex"
    XVAL = 0
    YVAL = 0
    XLEN=XY2[1]-XY1[1]
    YLEN=XY2[2]-XY1[2]
    NORM=sqrt(XLEN*XLEN + YLEN*YLEN)
    HALFW=HEIGHT/2
    XLEN=XLEN*HALFW
    YLEN=YLEN*HALFW
    XPT0=round_((XY1[1]-YLEN/NORM) * GRID)
    YPT0=round_((XY1[2]+XLEN/NORM) * GRID)
    print "D" P_DCODE "*X" XPT0 "Y" YPT0 "D02*" >> CUSTFN
    XPT1=round_((XY2[1]-YLEN/NORM) * GRID)
    YPT1=round_((XY2[2]+XLEN/NORM) * GRID)
    print  "X" XPT1 "Y" YPT1 "D01*" >> CUSTFN
    XPT1=round_((XY2[1]+YLEN/NORM) * GRID)
    YPT1=round_((XY2[2]-XLEN/NORM) * GRID)
    print "X" XPT1 "Y" YPT1 "D01*" >> CUSTFN
    XPT1=round_((XY1[1]+YLEN/NORM) * GRID)
    YPT1=round_((XY1[2]-XLEN/NORM) * GRID)
    print "X" XPT1 "Y" YPT1 "D01*" >> CUSTFN
    print "X" XPT0 "Y" YPT0 "D01*" >> CUSTFN
  } # if else
  return LINEOUT
} # outLINE

function OutPoly(DIA,SIDES)
{
  RAD = DIA / 2
  PVIDX = PVIDXLIST[SIDES]
  XPT0 = round_((PVLIST[PVIDX] * RAD) * GRID)
  YPT0 = round_((PVLIST[PVIDX+1] * RAD) * GRID)
  print "D" P_DCODE "*X" XPT0 "Y" YPT0 "D02*" >> CUSTFN
  for(IOP=PVIDX+2; IOP<(PVIDX+(SIDES*2)); IOP+=2){
    XPT0 = round_((PVLIST[IOP] * RAD) * GRID)
    YPT0 = round_((PVLIST[IOP+1] * RAD) * GRID)
    print "X" XPT1 "Y" YPT1 "D01*" >> CUSTFN
  } # for
  print "X" XPT0 "Y" YPT0 "D01*" >> CUSTFN
  P_DCODE = P_DCODE + 1
} # OutPoly

function decodePrimitive(BUFF)
{
  PARMCNT = split(BUFF,PARR,",")
  if((PARR[2] == 0) && (PARR[1] != 6) && (PARR[1] != 7))
    DRILLSTR = "( T1 )"
  else
    DRILLSTR = ""
  if(PARR[1] == 1) { # ROUND TYPE
    APTTYPE = "Round"
    XVAL = PARR[3]
    YVAL = 0
    XCTR = round_(PARR[4] * GRID)
    YCTR = round_(PARR[5] * GRID)
    OUTFLASH = 1
  } # if
  else if((PARR[1] == 21) || (PARR[1] == 22)) { # RECT TYPE
    APTTYPE = "Rect"
    XVAL = PARR[3]
    YVAL = PARR[4]
    XCTR = round_(PARR[5] * GRID)
    YCTR = round_(PARR[6] * GRID)
    if(PARR[1] == 22){
      XCTR = round_(XCTR + (XVAL * GRID)/2)
      YCTR = round_(YCTR + (YVAL * GRID)/2)
    } # if
    OUTFLASH = 1
    if(PARR[7] > 0){
      HALFLEN = XVAL/2
      DEGSUB=0
      oLWIDTH = PARR[3]
      oLHEIGHT = PARR[4]
      if(YVAL > XVAL)
      {
        HALFLEN = YVAL/2
        DEGSUB=90
        oLWIDTH = PARR[4]
        oLHEIGHT = PARR[3]
      }
      SINA = sin(((PARR[7]-DEGSUB)*_PI_)/180)
      COSA = cos(((PARR[7]-DEGSUB)*_PI_)/180)
      XY1[1] = -HALFLEN
      XY1[2] = 0
      XY2[1] = HALFLEN
      XY2[2] = 0
      rotate_(XY1,SINA,COSA)
      rotate_(XY2,SINA,COSA)
      XY1[1] += (XCTR/GRID)
      XY1[2] += (YCTR/GRID)
      XY2[1] += (XCTR/GRID)
      XY2[2] += (YCTR/GRID)
      if(outLINE(XY1,XY2,oLWIDTH,oLHEIGHT) == 1)
        OUTFLASH = 0
    } # if
  } # else if
  else if(PARR[1] == 5) { # OCTAGON / POEX TYPE
    if(PARR[3] == 8){
      APTTYPE = "Octagon"
      XCTR = round_(PARR[4] * GRID)
      YCTR = round_(PARR[5] * GRID)
      XVAL = PARR[6]
      YVAL = 0
      OUTFLASH = 1
    } # if
    else {
      OutPoly(PARR[3],PARR[5])
      OUTFLASH = 0
    } # else

  } # else if
  else if(PARR[1] == 6) { # TARGET TYPE
    APTTYPE = "Target"
    XCTR = round_(PARR[2] * GRID)
    YCTR = round_(PARR[3] * GRID)
    XVAL = PARR[4]
    YVAL = 0
    OUTFLASH = 1
  } # else if
  else if(PARR[1] == 7) { # THERMAL TYPE
    APTTYPE = "Thermal"
    XCTR = round_(PARR[2] * GRID)
    YCTR = round_(PARR[3] * GRID)
    XVAL = PARR[4]
    YVAL = PARR[5] "," PARR[6] "," PARR[7]
    OUTFLASH = 1
  } # else if

  else if(PARR[1] == 20) { # LINE-VECTOR 
    OUTFLASH = 0
    XY1[1] = PARR[4]
    XY1[2] = PARR[5]
    XY2[1] = PARR[6]
    XY2[2] = PARR[7]
    if(PARR[8] > 0){
      SINA = sin((PARR[8]*_PI_)/180)
      COSA = cos((PARR[8]*_PI_)/180)
      rotate_(XY1,SINA,COSA)
      rotate_(XY2,SINA,COSA)
    } # if
    if(outLINE(XY1,XY2,PARR[3],PARR[3]) == 0)
      OUTFLASH = 1
  } # else if
  else if(PARR[1] == 4) { # OUTLINE
    APTTYPE = "Poex"
    XVAL = 0
    YVAL = 0
    XPT0 = round_(PARR[4] * GRID)
    YPT0 = round_(PARR[5] * GRID)
    ROTAIDX = ((PARR[3]*2)+6)
    ROTANG = PARR[ROTAIDX]
    if(ROTANG > 0){
      SINA = sin((ROTANG*_PI_)/180)
      COSA = cos((ROTANG*_PI_)/180)
      XY1[1] = XPT0
      XY1[2] = YPT0
      rotate_(XY1,SINA,COSA)
      XPT0 = XY1[1]
      YPT0 = XY1[2]
    } # if
    print "D" P_DCODE "*" >> CUSTFN
    print "X" XPT0 "Y" YPT0 "D02*" >> CUSTFN
    for(IRI=6; IRI<ROTAIDX; IRI+=2){
      XPT1 = round_(PARR[IRI] * GRID)
      YPT1 = round_(PARR[IRI+1] * GRID)
      if(ROTANG > 0){
        XY1[1] = XPT1
        XY1[2] = YPT1
        rotate_(XY1,SINA,COSA)
        XPT1 = XY1[1]
        YPT1 = XY1[2]
      } # if
      print "X" XPT1 "Y" YPT1 "D01*" >> CUSTFN
    } # for
    print "X" XPT0 "Y" YPT0 "D01*" >> CUSTFN
    OUTFLASH = 0
  } # else if

  DCODE = P_DCODE + CUSTREF
  print "D" DCODE, XVAL, "d", APTTYPE, XVAL, YVAL, DRILLSTR >>APTFN
  if(OUTFLASH){
    print "D" P_DCODE "*" >>CUSTFN
    print "X" XCTR "Y" YCTR "D03*" >>CUSTFN
  } # if
  P_DCODE = P_DCODE + 1
} # decodePrimitive

function EvaluateExpr(ESTR)
{

  POS = match(ESTR,/[X\-\+\/]/)
  if(POS)
  {
    OPSTR = substr(ESTR,POS,1)
    OPCNT = split(ESTR,OPARR,OPSTR)
    OP1 = 0
    OP2 = 0
    if(match(ESTR,/[\/]/))
      OP2 = 1
    if(OPCNT >= 1)
    {
      if(match(OPARR[1],/[$]/))
      {
        EEIDX = substr(OPARR[1],2)
        OP1 = VARVALS[EEIDX]
      }
      else
        OP1 = OPARR[1];
    }
    if(OPCNT == 2)
    {
      if(match(OPARR[2],/[$]/))
      {
        EEIDX = substr(OPARR[2],2)
        OP2 = VARVALS[EEIDX]
      }
      else
        OP2 = OPARR[2];
    }
    if(match(ESTR,/[+]/))
      EERESULT = OP1 + OP2
    else if(match(OPSTR,/[-]/))
      EERESULT = OP1 - OP2
    else if(match(OPSTR,/[X]/))
      EERESULT = OP1 * OP2
    else if(match(OPSTR,/[\/]/))
      EERESULT = OP1 / OP2
  } # if
  else if((POS = (match(ESTR,/\$/))) != 0)
  {
    EEIDX = substr(ESTR,2)
    EERESULT = VARVALS[EEIDX]
  } # if else
  else
    EERESULT = ESTR
  return EERESULT
} # EvaluateExpr

function OutCUSTPARM(IDX,PARMARR,PARMCNT)
{
  CUSTSTR = CUSTPARMSTR[IDX]
  for(ICP=1; ICP<=PARMCNT; ++ICP)
  {
    VARVALS[ICP] = PARMARR[ICP]
  } # for
  CUSTPCNT = split(CUSTSTR,CUSTPARR,"\n")
  for(ICP=1; ICP<=CUSTPCNT; ++ICP)
  {
    if(match(CUSTPARR[ICP],"="))
    {
      AACNT = split(CUSTPARR[ICP],ASSNARR,"=")
      if(AACNT != 2)
        continue
      VVIDX = substr(ASSNARR[1],2)
      VARVALS[VVIDX] = EvaluateExpr(ASSNARR[2])
    } # if
    else
    {
      PRIMPCNT = split(CUSTPARR[ICP],PRIMPARR,",")
      PRIMSTR = ""
      for(IPP=1; IPP<=PRIMPCNT; ++IPP)
      {
        PRIMPARR[IPP] = EvaluateExpr(PRIMPARR[IPP])
        if(!length(PRIMSTR))
          PRIMSTR = PRIMPARR[IPP]
        else
          PRIMSTR = PRIMSTR "," PRIMPARR[IPP]
      } # for
      if(length(PRIMSTR))
        decodePrimitive(PRIMSTR)
    } # if else
  } # for
  printf "M00*" >>CUSTFN
} # OutCUSTPARM

function checkGenAptInfo(BUFF)
{
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
      GRID = 1
      for(I=1; I<=(KEY%10); ++I)
        GRID *= 10
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
} # checkGenAptInfo

function checkDCODE(BUFF) {
  ADARRLEN = split(BUFF,ADARR,",") # ADDARR[1] = DCOD & TYPE ADDARR[2] = XY
  if(match(ADARR[1],/[1-9][0-9]+/)){
    DCODVAL = substr(ADARR[1],RSTART,RLENGTH)
    DDCOD=DCODVAL-10
    if((DDCOD >= 0) && (DDCOD <= 999)){
      POS = RSTART + (RLENGTH)
      TYPE = substr(ADARR[1],POS)
      if(!match(TYPE,/^[CRPO]$/)){
        for(I=1; I<CUSTREFI; ++I){
          if(TYPE == CUSTARR[I]){
            ACODE = (CURRLAY * 1000) + DCODVAL

            if(length(PREVFN))
              close(PREVFN)
            BASECUSTFN = "rs274mac." MACOUT++
            CUSTFN = joinPath(DATAPATH,BASECUSTFN)
            PREVFN = CUSTFN
            print "" > CUSTFN
            P_DCODE = 10
            CUSTREF += 1000
            XYLEN = split(ADARR[2],XY,"X")
            OutCUSTPARM(I,XY,XYLEN)

            print "A" ACODE, "0", "f", "Custom", BASECUSTFN, CUSTREF >>APTFN
            break
          } # if
        } # for
      } # if
      XYLEN = split(ADARR[2],XY,"X")
      XStr = ((XYLEN >= 1)?XY[1]:"0")
      YStr = ((XYLEN >= 2)?XY[2]:"0")
      printf "D%s %s d ",DCODVAL,XStr >>APTFN
      if(TYPE == "C"){
        APTTYPE = ((XYLEN == 2)?"Donut":"Round")
        printf "%s %s %s",((XYLEN == 2)?"Donut":"Round"),XStr,YStr >>APTFN
      } else
      if(TYPE == "R"){
        if(XStr == YStr)
          printf "Square %s 0",XStr >>APTFN
        else
          printf "Rect %s %s",XStr,YStr >>APTFN
      }else
      if(TYPE == "P"){
        if(YStr == "8")
          printf "Octagon %s 0",XStr >>APTFN
        else{
          CUSTFN = "rs274ply." POLYOUT++
          CUSTFN = joinPath(DATAPATH,CUSTFN)
          decodePrimitive(BUFF)
          close(CUSTFN)
        } # if else
      }else
      if(TYPE == "O"){
        printf "Oblong %s %s",XStr,YStr >>APTFN
      }else
      {
        printf "Custom" >>APTFN
      }
      printf"\n" >> APTFN
    } # if
  } # if
} # checkDCODE

{ # main

  BUFF=$0
  gsub(/[%\n]/,"",BUFF)
  if(match(BUFF,/M[03][0-2]/) || match(BUFF,/^[XY]/))
    exit
  else if(match(BUFF,/~~/)){
    CURRLAY = substr(BUFF,(RSTART+2))
    OLDLAY = CURRLAY
    if(PREVLAY){
      CURRLAY += BASELAYARR[PREVLAY]
    } # if
    PREVLAY = OLDLAY
  } # else if
  else if(match(BUFF,/^ADD/))
    checkDCODE(BUFF)
  else if(match(BUFF,/^AM/)){
    if(MACOUT == 1009) # no more than 1000 macros allowed
      exit
    CUSTPARMI = CUSTREFI
    CUSTARR[CUSTREFI++] = substr(BUFF,3)
  } # else if
  else if (match(BUFF,/^[$0-9]/)){
    AddPrimBuff(BUFF)
  } # else if
  else
    checkGenAptInfo(BUFF)
} # main
