/* Copyright Keysight Technologies 1998 - 2011 */ 
#define STDTEMP 27.0         /* libra default temperature */
#define PI     3.141592654
#define sqr(x) ((x)*(x))
#define EPS    1.0e-8
#define ZO   50 /* reference impedance for S-pars */

static char ErrMsg[101];  

/*----------------------------------------------------------------------------*/
#define DEV_TEMP  (CTOK+27) /* Assumed constant device temperature, 27 deg. C */
#define   GMIN    1.0e-12 
#define   RMIN    1.0e-12 
#define   GMAX    1.0e12
#define   VT      (BOLTZ*DEV_TEMP/CHARGE)
/*----------------------------------------------------------------------------*/

/* The pn diode model is a three node device that has a
 * linear R in series with a nonlinear R || C, as well as
 * a transit time associated with conduction.
 * There are a number of different operating
 * regions that are apparent in the model.
 */

static boolean add_y_branch(
  UserInstDef *userInst,
  int n1,
  int n2,
  COMPLEX y)
{
  boolean status = TRUE;

  status = add_lin_y(userInst, n1, n1, y) &&
           add_lin_y(userInst, n2, n2, y);
  if (status)
  {
    y.real = -y.real; y.imag = -y.imag;
    status = add_lin_y(userInst, n1, n2, y) &&
             add_lin_y(userInst, n2, n1, y);
  }
  return status;
}

/*----------------------------------------------------------------------------*/

static boolean add_n_branch(
  UserInstDef *userInst,
  int n1,
  int n2,
  COMPLEX iNcorr)
{
  boolean status = TRUE;

  status = add_lin_n(userInst, n1, n1, iNcorr) &&
           add_lin_n(userInst, n2, n2, iNcorr);
  if (status)
  {
    iNcorr.real = -iNcorr.real; iNcorr.imag = -iNcorr.imag;
    status = add_lin_n(userInst, n1, n2, iNcorr) &&
             add_lin_n(userInst, n2, n1, iNcorr);
  }
  return status;
}

static boolean analyze_lin (
  UserInstDef *userInst,
  double omega)
{
  boolean status;
  COMPLEX y;
  UserParamData *pData = userInst->pData;

  y.real = y.imag = 0.0;
  if (RS_P > RMIN)
    y.real = AREA_P / RS_P;
  else
    y.real = GMAX;

  status = add_y_branch(userInst, 0, 2, y);

  if (!status)
  {
    (void)sprintf(ErrMsg, "analyze_lin(%s) -> add_lin_y() failed",
                  userInst->tag);
    send_error_to_scn(ErrMsg);
  }
  return status;
}

/*----------------------------------------------------------------------------*/

static void diode_nl_iq_gc (
  UserInstDef *userInst, /* Changed from SIV to be consistent w/CUI */
  double *vPin,
  double *id,
  double *qd,
  double *gd,
  double *capd)
{
  double vd, csat, vte, evd, evrev;
  double exparg;
  double fcpb, xfc, f1, f2, f3;
  double czero, arg, sarg, czof2;
  UserParamData *pData = userInst->pData;

  csat = IS_P * AREA_P;
  vte = N_P * VT;
  vd = vPin[2] - vPin[1]; /* junction voltage */

  /*
   * compute current and derivatives with respect to voltage
   */
  if ( vd >= -5.0*vte )
  {
    if (vd/vte < 40.0)
    {
      evd = exp(vd/vte);
      *id = csat * (evd - 1.0) + GMIN * vd;
      *gd = csat * evd / vte + GMIN;
    }
    else
    {
      /* linearize the exponential above vd/vte=40 */
      evd = (vd/vte+1.0-40.0)*exp(40.0);
      *id = csat * (evd - 1.0) + GMIN * vd;
      *gd = csat * exp(40.0) / vte + GMIN;
    }
  }
  else
  {
    *id = -csat + GMIN * vd;
    *gd = -csat / vd + GMIN;
    if ( BV_P != 0.0 && vd <= (-BV_P+50.0*VT) )
    {
      exparg = ( -(BV_P+vd)/VT < 40.0 ) ? -(BV_P+vd)/VT : 40.0;
      evrev = exp(exparg);
      *id -= csat * evrev;
      *gd += csat * evrev / VT;
    }
  }

  /*
   * charge storage elements
   */
  fcpb = FC_P * VJ_P;

  czero = CJO_P * AREA_P;
  if (vd < fcpb)
  {
    arg = 1.0 - vd / VJ_P;
    sarg = exp(-M_P * log(arg));
    *qd = TT_P * (*id) + VJ_P * czero * (1.0 - arg * sarg) 
        / (1.0 - M_P);
    *capd = TT_P * (*gd) + czero * sarg;
  }
  else
  {
    xfc = log(1.0 - FC_P);
    /* f1 = vj*(1.0-(1.0-fc)^(1.0-m))/(1.0-m)  */
    f1 = VJ_P * (1.0-exp((1.0-M_P)*xfc)) / (1.0-M_P);

    /* f2 = (1.0-fc)^(1.0+m)  */
    f2 = exp((1.0+M_P)*xfc);

    /* f3=1.0-fc*(1.0+m)  */
    f3 = 1.0 - FC_P * (1.0+M_P);
    czof2 = czero / f2;
    *qd = TT_P * (*id) + czero * f1 + czof2 * (f3 * (vd - fcpb) +
         (M_P / (VJ_P + VJ_P)) * (vd * vd - fcpb * fcpb));
    *capd = TT_P * (*gd) + czof2 * (f3 + M_P * vd / VJ_P);
  }
} /* diode_nl_iq_gc() */

/*----------------------------------------------------------------------------*/

static boolean analyze_nl (
  UserInstDef *userInst,
  double *vPin)
{
  double id, gd; /* current, conductance */
  double qd, capd; /* charge, capacitance */
  boolean status;
  char *pMsg = NULL;
  UserParamData *pData = userInst->pData;

  diode_nl_iq_gc(userInst, vPin, &id, &qd, &gd, &capd);
  /*
   * load nonlinear pin currents out of each terminal and 
   * nonlinear charges at each terminal.
   */
  status = add_nl_iq(userInst, 1, -id, -qd) &&
           add_nl_iq(userInst, 2, id,  qd);
  if (!status)
  {
    pMsg = "add_nl_iq()";
    goto END;
  }

  /* Add nonlinear conductance, capacitance
   *      0   1   2
   *   0           
   *   1      Y   Y
   *   2      Y   Y
   */
  status = add_nl_gc(userInst, 1, 1,  gd, capd) &&
           add_nl_gc(userInst, 1, 2, -gd, -capd ) &&
           add_nl_gc(userInst, 2, 1, -gd, -capd ) &&
           add_nl_gc(userInst, 2, 2,  gd,  capd);

  if (!status)
    pMsg = "add_nl_gc()";

 END:
  if (pMsg)
  {
    (void)sprintf(ErrMsg, "Error: PNDIODE analyze_nl(%s) -> %s", userInst->tag, pMsg);
    send_error_to_scn(ErrMsg);
  }
  return status;
} /* analyze_nl() */

/*----------------------------------------------------------------------------*/

static boolean analyze_ac (
  UserInstDef *userInst,
  double *vPin,
  double omega)
{
  COMPLEX y;
  double id, gd; /* current, conductance */
  double qd, capd; /* charge, capacitance */
  boolean status;
  UserParamData *pData = userInst->pData;

  /*
   * Add linearized conductance, susceptance
   *      0   1   2
   *   0  G       G
   *   1      Y   Y
   *   2  G   Y   Y
   */
  if (!analyze_lin(userInst, omega))
    return FALSE;

  diode_nl_iq_gc(userInst, vPin, &id, &qd, &gd, &capd);
  y.real = gd; y.imag = omega * capd;
  status = add_y_branch(userInst, 1, 2, y);
  if (!status)
  {
    (void)sprintf(ErrMsg, "Error: PNDIODE: analyze_ac(%s) -> add_lin_y", userInst->tag);
    send_error_to_scn(ErrMsg);
  }
  return status;
} /* analyze_ac() */

/*----------------------------------------------------------------------------*/

static boolean analyze_ac_n (
  UserInstDef *userInst,
  double *vPin,
  double omega)
{
  double id, gd; /* current, conductance */
  double qd, capd; /* charge, capacitance */
  boolean status;
  COMPLEX thermal, dNoise; /* noise-current correlation admittance */
  double kf, gs, tempScale;
  char *pMsg = NULL;
  UserParamData *pData = userInst->pData;

  diode_nl_iq_gc(userInst, vPin, &id, &qd, &gd, &capd);

  tempScale = DEV_TEMP / NOISE_REF_TEMP;

  dNoise.imag = thermal.imag = 0.0;

  if (RS_P > RMIN)
    gs = AREA_P / RS_P;
  else
    gs = GMAX;
  thermal.real = tempScale * gs;

  id = fabs(id);
  kf = fabs(KF_P);

  /* shot noise */
  dNoise.real = 2.0 * CHARGE * id;
  /* flicker noise */
  if (id > 0.0 && omega > 0.0 && kf > 0.0)
    dNoise.real += kf * pow(id, AF_P) * pow(omega/TWOPI, -FFE_P);

  dNoise.real /= FOUR_K_TO;

  status = add_n_branch(userInst, 0, 2, thermal) &&
           add_n_branch(userInst, 1, 2, dNoise);
  if (!status)
    pMsg = "add_lin_n()";

  if (pMsg)
  {
    (void)sprintf(ErrMsg, "Error: analyze_ac_n(%s) -> %s", userInst->tag, pMsg);
    send_error_to_scn(ErrMsg);
  }
  return status;
} /* analyze_ac_n() */

/*----------------------------------------------------------------------------*/

static boolean analyze_tr(
  UserInstDef *userInst,
  double      *vPin)
{
  UserParamData *pData = userInst->pData;
  char *pMsg = NULL;
  boolean status;
  double id, qd, gd, capd, rs;
  
  /* compute the nonlinear portion */
  diode_nl_iq_gc(userInst, vPin, &id, &qd, &gd, &capd);

  status = add_tr_iq(userInst, 2,  id,  qd) &&
           add_tr_iq(userInst, 1, -id, -qd);
  if (status == FALSE) goto END;
  
  status = add_tr_gc(userInst, 2, 2,  gd,  capd) &&
           add_tr_gc(userInst, 2, 1, -gd, -capd) &&
           add_tr_gc(userInst, 1, 2, -gd, -capd) &&
           add_tr_gc(userInst, 1, 1,  gd,  capd);
  if (status == FALSE) goto END;

  /* series resistance */
  if (AREA_P > 0.0)
    rs = RS_P / AREA_P;
  else
    rs = 0.0;
  status = add_tr_resistor(userInst, 0, 2, rs);  

 END:
  if (pMsg)
  {
    (void)sprintf(ErrMsg, "Error: PNDIODE: analyze_tr(%s) -> %s", userInst->tag, pMsg);
    send_info_to_scn(ErrMsg);
  }
  return status;
} /* analyze_tr() */

