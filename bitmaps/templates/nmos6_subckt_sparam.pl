#!/usr/bin/perl 
# Copyright Keysight Technologies 2007 - 2014  
# Template for six-terminal nmos S-parameter test with x as prefix, i.e.,  
# using a subcircuit.
# Optional d45 diode connecting bulk and the fifth pin.
# Optional d65 diode connecting the sixth pin and the fifth pin.

# <---- Header Start ---->
BEGIN {
    if ($ENV{DKITVERIFICATION} eq "")
    {
        if ($ENV{HPEESOF_DIR} eq "" || ! -d "$ENV{HPEESOF_DIR}/design_kit/verification" )
        {
            print "please define environment variable DKITVERIFICATION\n";
            exit 1;
        }
        else
        {
            $ENV{DKITVERIFICATION} = "$ENV{HPEESOF_DIR}/design_kit/verification";
            $ENV{PATH} = '$ENV{PATH}:$ENV{DKITVERIFICATION}/bin';
        }
    }
    $myLibPath = "$ENV{DKITVERIFICATION}/perl/lib";

    use Cwd;
    $myWorkDir = cwd;

    if ($ENV{MVERIFY_DIR} eq "")
    {
        $ENV{MVERIFY_DIR} = $ENV{DKITVERIFICATION};
    }
    $myMverifyLibPath = "$ENV{MVERIFY_DIR}/perl/lib";
    if ( ! -d $myMverifyLibPath)
    {
        print "\nERROR: Unable to find verification module directory \$MVERIFY_DIR/perl/lib\n\n";
        print "Please set environment variable MVERIFY_DIR\nto point to the mverify installation directory\n\n";
        exit 1;
    }
}

use Getopt::Long;
use lib "$myLibPath";
use lib "$myWorkDir";
use lib "$myMverifyLibPath";

use dKitCircuit;
use mVerifyResults;
use dKitUtils;

dKitCircuit->debug(1);
# <---- Header Stop ---->

sub Usage()
{
  print "Usage: -help\n";
  print "       -simulators []\n"; 
  print "       -s11_tol []          -s21_tol []      -s22_tol []       -s12_tol []   -abs_tol []\n";
  print "       -testname []\n"; 
  print "       -model_name []\n"; 
  print "       -allparams []        -adsparams []           -spectreparams []           -hspiceparams []\n";
  print "       -source_v []         -bulk_v []    -pin5_v []    -pin6_v []\n";
  print "       -d45_model_name []    -d65_model_name []    -d45_allParams []    -d65_allParams []\n";
  print "       -d45_adsParams []    -d65_adsParams [] -d45_spectreParams []    -d65_spectreParams []\n";
  print "       -d45_hspiceParams []    -d65_hspiceParams []\n";
  print "       -gate_refz []        -drain_refz []    -gate_bias []        -drain_bias []\n";
  print "       -freq_pts []         -freq_start []          -freq_stop []               -freq_numpts []\n";
  print "       -sweep_vg [yes/no]   -vg_pts []              -vg_start []                -vg_stop []    -vg_numpts []\n";
  print "       -sweep_temp [yes/no] -temp_pts []\n";
  print "       -ads_model_lib []    -hspice_model_lib []    -spectre_model_lib []   -inline [yes/no]\n";
  print "       -reltol []  -vabstol []    -iabstol []    -gmin []\n";
  print "       -scale []    -temp[]   -tnom[]   -digits []\n";
  print "       -ads_scale []\n";
};

$ret = GetOptions ("h|help", "delfiles|delfiles:s", "simulators|simulators:s", "resultfile|resultfile:s", "s11_tol|s11_tol:s", "s21_tol|s21_tol:s", "s22_tol|s22_tol:s", "s12_tol|s12_tol:s", "abs_tol|abs_tol:s", "testname|testname:s", "model_name|device_name:s", "allparams|allparams:s", "adsparams|adsparams:s", "hspiceparams|hspiceparams:s", "spectreparams|spectreparams:s", "source_v|source_v:f", "bulk_v|bulk_v:f", "pin5_v|pin5_v:f", "pin6_v|pin6_v:f", "d45_model_name|d45_model_name:s", "d65_model_name|d65_model_name:s", "d45_allParams|d45_allParams:s", "d65_allParams|d65_allParams:s", "d45_adsParams|d45_adsParams:s", "d45_spectreParams|d45_spectreParams:s", "d45_hspiceParams|d45_hspiceParams:s", "d65_adsParams|d65_adsParams:s", "d65_spectreParams|d65_spectreParams:s", "d65_hspiceParams|d65_hspiceParams:s", "gate_refz|gate_refz:f", "drain_refz|drain_refz:f", "gate_bias|gate_bias:f", "drain_bias|drain_bias:f", "freq_pts|freq_pts:s", "freq_start|freq_start:f", "freq_stop|freq_stop:f", "freq_numpts|freq_numpts:i", "sweep_vg|sweep_vg:s", "vg_pts|vg_pts:s", "vg_start|vg_start:f", "vg_stop|vg_stop:f", "vg_numpts|vg_numpts:i", "sweep_temp|sweep_temp:s", "temp_pts|temp_pts:s", "ads_model_lib|ads_model_lib:s", "hspice_model_lib|hspice_model_lib:s", "spectre_model_lib|spectre_model_lib:s","inline|inline:s","reltol|reltol:f","vabstol|vabstol:f","iabstol|iabstol:f","gmin|gmin:f","scale|scale:f","temp|temp:f","tnom|tnom:f","digits|digits:i","ads_scale|ads_scale:f");

$help               = $opt_h;
if ($help) {Usage();exit}

$simulators         = $opt_simulators;
$testname           = $opt_testname;
$model_name         = $opt_model_name;
$delFiles           = $opt_delfiles;
$resultHtmlFile     = $opt_resultfile;


$s11_tol            = $opt_s11_tol;
if(!$s11_tol) {$s11_tol=1.0;}

$s21_tol            = $opt_s21_tol;
if(!$s21_tol) {$s21_tol=1.0;}

$s22_tol            = $opt_s22_tol;
if(!$s22_tol) {$s22_tol=1.0;}

$s12_tol            = $opt_s12_tol;
if(!$s12_tol) {$s12_tol=1.0;}

$abs_tol            = $opt_abs_tol;
if (!$abs_tol) { $abs_tol=1e-20; }

$allparams          = $opt_allparams;
$adsparams          = $opt_adsparams;
$hspiceparams       = $opt_hspiceparams;
$spectreparams      = $opt_spectreparams;

$source_v           = $opt_source_v;
$bulk_v             = $opt_bulk_v;
$pin5_v             = $opt_pin5_v;
$pin6_v             = $opt_pin6_v;
$d45_model_name     = $opt_d45_model_name;
$d65_model_name     = $opt_d65_model_name;
$d45_allParams      = $opt_d45_allParams;
$d65_allParams      = $opt_d65_allParams;
$d45_adsParams      = $opt_d45_adsParams;
$d65_adsParams      = $opt_d65_adsParams;
$d45_spectreParams  = $opt_d45_spectreParams;
$d65_spectreParams  = $opt_d65_spectreParams;
$d45_hspiceParams   = $opt_d45_hspiceParams;
$d65_hspiceParams   = $opt_d65_hspiceParams;
$gate_refz          = $opt_gate_refz;
$drain_refz         = $opt_drain_refz;
$gate_bias          = $opt_gate_bias;
$drain_bias         = $opt_drain_bias;

$freq_pts           = $opt_freq_pts;
$freq_start         = $opt_freq_start;
$freq_stop          = $opt_freq_stop;
$freq_numpts        = $opt_freq_numpts;

$sweep_vg           = $opt_sweep_vg;
$vg_pts             = $opt_vg_pts;
$vg_start           = $opt_vg_start;
$vg_stop            = $opt_vg_stop;
$vg_numpts          = $opt_vg_numpts;

$sweep_temp         = $opt_sweep_temp;
$temp_pts           = $opt_temp_pts;

$ads_model_lib      = $opt_ads_model_lib;

$hspice_model_lib   = $opt_hspice_model_lib;
$spectre_model_lib  = $opt_spectre_model_lib;
$inline             = $opt_inline;
if($inline && lc($inline) eq 'yes') {$inline=1;}

# Model: nmos_rf 

# This is a simulation to compare ADS vs. HSPICE using the verification 
# tool. It is an S-Parameter Simulation using a FET device.

# This simulation is intended to find S parameters vs. frequency while sweeping vg.  

if (! $testname) {
  $head = "";
  $CIRCUIT=dKitCircuit->new('rfnmos');
} else {
  $CIRCUIT=dKitCircuit->new($testname);
  $head = $testname . "_";
}

$rf_fet = dKitTemplate->new(rf_fet);
$rf_fet->requiredPrefix("x");
$rf_fet->addNode("n1");
$rf_fet->addNode("n2");
$rf_fet->addNode("n3");
$rf_fet->addNode("n4");
$rf_fet->addNode("n5");
$rf_fet->addNode("n6");
my $modelLabel='model';
$rf_fet->addParameter('model');
$rf_fet->addParameter("allParams");
$rf_fet->addParameter("adsParams");
$rf_fet->addParameter("hspiceParams");
$rf_fet->addParameter("spectreParams");

my $nodelist=" %n1 %n2 %n3 %n4 %n5 %n6 ";
my $adsInstLine = &dKitUtils::setAdsInstanceLineFormat($modelLabel, $adsparams, $spectreparams, $hspiceparams, $nodelist);
$rf_fet->netlistInstanceTemplate(ads, $adsInstLine);
my $spectreInstLine = &dKitUtils::setSpectreInstanceLineFormat($modelLabel, $spectreparams, $hspiceparams, $nodelist);
$rf_fet->netlistInstanceTemplate(spectre, $spectreInstLine);
$rf_fet->netlistInstanceTemplate(hspice, '#instanceName %n1 %n2 %n3 %n4 %n5 %n6 <' . $modelLabel . '> [[<allParams>]] [[<hspiceParams>]]');

$d45 = dKitTemplate->new(d45);
$d45->requiredPrefix("x");
$d45->addNode("plus");
$d45->addNode("minus");
$d45->addParameter("d45_model_name");
$d45->addParameter("d45_allParams");
$d45->addParameter("d45_adsParams");
$d45->addParameter("d45_hspiceParams");
$d45->addParameter("d45_spectreParams");
if ($spectre_model_lib && ! $ads_model_lib && $d45_spectreParams && !$d45_adsParams)
{
$d45->netlistInstanceTemplate(ads, 'simulator lang=spectre
#instanceName %plus %minus <d45_model_name> [[<d45_allParams>]] [[<d45_spectreParams>]]
simulator lang=ads');
} else {
$d45->netlistInstanceTemplate(ads, '<d45_model_name>:#instanceName %plus %minus [[<d45_allParams>]] [[<d45_adsParams>]]');
}
$d45->netlistInstanceTemplate(spectre, '#instanceName %plus %minus <d45_model_name> [[<d45_allParams>]] [[<d45_spectreParams>]]');
$d45->netlistInstanceTemplate(hspice, '#instanceName %plus %minus <d45_model_name> [[<d45_allParams>]] [[<d45_hspiceParams>]]');

$d65 = dKitTemplate->new(d65);
$d65->requiredPrefix("x");
$d65->addNode("plus");
$d65->addNode("minus");
$d65->addParameter("d65_model_name");
$d65->addParameter("d65_allParams");
$d65->addParameter("d65_adsParams");
$d65->addParameter("d65_hspiceParams");
$d65->addParameter("d65_spectreParams");
if ($spectre_model_lib && ! $ads_model_lib && $d65_spectreParams && !$d65_adsParams)
{
$d65->netlistInstanceTemplate(ads, 'simulator lang=spectre
#instanceName %plus %minus <d65_model_name> [[<d65_allParams>]] [[<d65_spectreParams>]]
simulator lang=ads');
} else {
$d65->netlistInstanceTemplate(ads, '<d65_model_name>:#instanceName %plus %minus [[<d65_allParams>]] [[<d65_adsParams>]]');
}
$d65->netlistInstanceTemplate(spectre, '#instanceName %plus %minus <d65_model_name> [[<d65_allParams>]] [[<d65_spectreParams>]]');
$d65->netlistInstanceTemplate(hspice, '#instanceName %plus %minus <d65_model_name> [[<d65_allParams>]] [[<d65_hspiceParams>]]');

# Add instances of FET and six voltage sources, vd, vs, vg, vb, v5, and v6.
if (! $model_name) {die "Error: \$model_name must be defined.";}
$model_name=~s/\s//g;
$m1=dKitInstance->new(rf_fet, x1);
$m1->parameterValue('model',$model_name);
if ($allparams) {$m1->parameterValue('allParams', $allparams);}

my $adsInstParams = &dKitUtils::adsInstanceParams($adsparams, $spectreparams, $hspiceparams);
if ($adsInstParams) {$m1->parameterValue('adsParams', $adsInstParams);}
my $spectreInstParams = &dKitUtils::spectreInstanceParams($spectreparams, $hspiceparams);
if ($spectreInstParams) {$m1->parameterValue('spectreParams', $spectreInstParams);}
if ($hspiceparams) {$m1->parameterValue('hspiceParams', $hspiceparams);}

$m1->nodeName(n1, 'drain');
$m1->nodeName(n2, 'gate');
$m1->nodeName(n3, 'source');
$m1->nodeName(n4, 'bulk');
$m1->nodeName(n5, 'pin5');
$m1->nodeName(n6, 'pin6');
$CIRCUIT->addInstance($m1);

if (defined $d45_model_name) 
{
  $d1=dKitInstance->new(d45, xd45);
  $d1->nodeName(plus, 'bulk');
  $d1->nodeName(minus, 'pin5');
  $d1->parameterValue(d45_model_name, $d45_model_name);
  if (defined $d45_allParams) { $d1->parameterValue(d45_allParams, $d45_allParams); }
  if (defined $d45_adsParams) { $d1->parameterValue(d45_adsParams, $d45_adsParams); }
  if (defined $d45_spectreParams) { $d1->parameterValue(d45_spectreParams, $d45_spectreParams); }
  if (defined $d45_hspiceParams) { $d1->parameterValue(d45_hspiceParams, $d45_hspiceParams); }
  elsif ($d45_spectreParams && $spectre_model_lib && ! $ads_model_lib)
  {$d1->parameterValue(d45_adsParams, $d45_spectreParams);}
  $CIRCUIT->addInstance($d1);
}

if (defined $d65_model_name)
{
  $d2=dKitInstance->new(d65, xd65);
  $d2->nodeName(plus, 'pin6');
  $d2->nodeName(minus, 'pin5');
  $d2->parameterValue(d65_model_name, $d65_model_name);
  if (defined $d65_allParams) { $d2->parameterValue(d65_allParams, $d65_allParams); }
  if (defined $d65_adsParams) { $d2->parameterValue(d65_adsParams, $d65_adsParams); }
  elsif ($d65_spectreParams && $spectre_model_lib && ! $ads_model_lib)
  {$d2->parameterValue(d65_adsParams, $d65_spectreParams);}
  if (defined $d65_spectreParams) { $d2->parameterValue(d65_spectreParams, $d65_spectreParams); }
  if (defined $d65_hspiceParams) { $d2->parameterValue(d65_hspiceParams, $d65_hspiceParams); }
  $CIRCUIT->addInstance($d2);
}

$vs=dKitInstance->new(V, vs);
$vs->nodeName(nplus, 'source');
$vs->nodeName(nminus, 0);
if (! defined $source_v) {$source_v=0;} 
$vs->parameterValue('Vdc', $source_v);
$CIRCUIT->addInstance($vs);

$vb=dKitInstance->new(V, vb);
$vb->nodeName(nplus, 'bulk');
$vb->nodeName(nminus, 0);
if (! defined $bulk_v) {$bulk_v=0;} 
$vb->parameterValue('Vdc', $bulk_v);
$CIRCUIT->addInstance($vb);

$v5=dKitInstance->new(V, v5);
$v5->nodeName(nplus, 'pin5');
$v5->nodeName(nminus, 0);
if (! defined $pin5_v) {$pin5_v=0;} 
$v5->parameterValue('Vdc', $pin5_v);
$CIRCUIT->addInstance($v5);

$v6=dKitInstance->new(V, v6);
$v6->nodeName(nplus, 'pin6');
$v6->nodeName(nminus, 0);
if (! defined $pin6_v) {$pin6_v=0;} 
$v6->parameterValue('Vdc', $pin6_v);
$CIRCUIT->addInstance($v6);

$vg=dKitInstance->new(PORT_BN, xg);
$vg->nodeName(nplus, 'gate');
$vg->nodeName(nminus, 0);
if (! defined $gate_bias) {$gate_bias=0.9;} 
$vg->parameterValue(pbn_vdc, $gate_bias);
$vg->parameterValue(pbn_vac_mag, 1e-3);
$vg->parameterValue(pbn_portnr, 1);
if (! defined $gate_refz) {$gate_refz=50;} 
$vg->parameterValue(pbn_referenceimpedance, $gate_refz);
$vg->parameterValue(pbn_inductance, 1);
$vg->parameterValue(pbn_capacitance, 1);
$CIRCUIT->addInstance($vg);

$vd=dKitInstance->new(PORT_BN, xd);
$vd->nodeName(nplus, 'drain');
$vd->nodeName(nminus, 0);
if (! defined $drain_bias) {$drain_bias=2.5;} 
$vd->parameterValue(pbn_vdc, $drain_bias);
$vd->parameterValue(pbn_portnr, 2);
if (! defined $drain_refz) {$drain_refz=50;} 
$vd->parameterValue(pbn_referenceimpedance, $drain_refz);
$vd->parameterValue(pbn_inductance, 1);
$vd->parameterValue(pbn_capacitance, 1);
$CIRCUIT->addInstance($vd);

# Add S Parameter Analysis Component

# Add Sweep Plans  
if ($freq_pts) {
  $SWEEPPLAN1 = dKitAnalysis->new(SWEEPPLAN_PT, Plan1);
  $SWEEPPLAN1->parameterValue("values", $freq_pts);
} else
{
  if (! defined $freq_start) { $freq_start='0.1e9';}
  if (! defined $freq_stop) { $freq_stop='10e9';}
  if (! defined $freq_numpts) { $freq_numpts='101';}
  $SWEEPPLAN1 = dKitAnalysis->new(SWEEPPLAN_LIN, Plan1);
  $SWEEPPLAN1->parameterValue(start, $freq_start);
  $SWEEPPLAN1->parameterValue(stop, $freq_stop);
  $SWEEPPLAN1->parameterValue(numPts, $freq_numpts);
}

$SP1 = dKitAnalysis->new(SP, SP1);
$SP1->parameterValue(parameter, 'freq');
$SP1->addSweepPlan($SWEEPPLAN1);

if (($sweep_vg) && ($sweep_vg ne 'no'))
{
  if ($vg_pts) {
    $SWEEPPLAN2 = dKitAnalysis->new(SWEEPPLAN_PT, Plan2);
    $SWEEPPLAN2->parameterValue("values", $vg_pts);
  } else
  {
    if (! defined $vg_start) { $vg_start='0.5';}
    if (! defined $vg_stop) { $vg_stop='1.5';}
    if (! defined $vg_numpts) { $vg_numpts='5';}
    $SWEEPPLAN2 = dKitAnalysis->new(SWEEPPLAN_LIN, Plan2);
    $SWEEPPLAN2->parameterValue(start, $vg_start);
    $SWEEPPLAN2->parameterValue(stop, $vg_stop);
    $SWEEPPLAN2->parameterValue(numPts, $vg_numpts);
  }

  $SWEEP2 = dKitAnalysis->new(SWEEP, Sweep2);
  $SWEEP2->parameterValue(device, 'xg');
  $SWEEP2->parameterValue(parameter, 'pbn_vdc');
  $SWEEP2->addSweepPlan($SWEEPPLAN2);
  $SWEEP2->addSubAnalysis($SP1);
}

if (($sweep_temp) && ($sweep_temp ne 'no'))
{
  $SWEEPPLAN3 = dKitAnalysis->new(SWEEPPLAN_PT, Plan3);
    if (! defined $temp_pts) { $temp_pts='-40 25 125';  print "\$temp_pts not defined.  \$temp_pts set to \"$temp_pts\"\n";}
  $SWEEPPLAN3->parameterValue("values", $temp_pts);

  $SWEEP3 = dKitAnalysis->new(SWEEP, Sweep3);
  $SWEEP3->parameterValue(parameter, 'temp');
  $SWEEP3->addSweepPlan($SWEEPPLAN3);
   if ($SWEEP2)  {$SWEEP3->addSubAnalysis($SWEEP2);}
   else          {$SWEEP3->addSubAnalysis($SP1);}
  $CIRCUIT->addAnalysis($SWEEP3);
}
else
{
  if ($SWEEP2)  { $CIRCUIT->addAnalysis($SWEEP2);}
  else          { $CIRCUIT->addAnalysis($SP1);}
}

# Output Plans

$OUTPUTDOPS=dKitAnalysis->new(OUTPUTPLAN_DOPS, "out1");
$OUTPUTDOPS->parameterValue(deviceParameters, "vd:i");
$SP1->addOutputPlan($OUTPUTDOPS);

# Add Options Block

$reltol    = $opt_reltol;
$vabstol   = $opt_vabstol;
$iabstol   = $opt_iabstol;
$gmin      = $opt_gmin;
$scale     = $opt_scale;    # Is scale option in Hspice the same as that in spectre?
$ads_scale = $opt_ads_scale;
$temp      = $opt_temp;     # HSPICE use .TEMP and not TEMP in .OPTION!
$tnom      = $opt_tnom;
$digits    = $opt_digits;

if (!$reltol) { $reltol = "1e-5"; }
if (!$vabstol) { $vabstol = "1e-7"; }
if (!$iabstol) { $iabstol = "1e-12"; }
if (!$abs_tol) { $abs_tol = "1e-20"; }
if (!$gmin) { $gmin = "1e-12"; }
if (!$temp) { $temp = "25"; }
if (!$tnom) { $tnom = $temp; }
if (!$digits) { $digits = "10"; }
if (!$ads_scale && $scale) { $ads_scale = $scale; }
if ($ads_scale) { 
  # UseNutmegFormat=no ASCII_Rawfile=yes are created elsewhere.
  $ADS_options = "ResourceUsage=yes"
    . " V_RelTol=" . $reltol . " I_RelTol=" . $reltol  
    . " V_AbsTol=" . $vabstol . " I_AbsTol=" . $iabstol 
    . " Temp=" . $temp . " Tnom=" . $tnom  . " Gmin=" . $gmin 
    . " NumDigits=". $digits . "\n_Scale=" . $ads_scale; 
} else {
  $ADS_options = "ResourceUsage=yes"
    . " V_RelTol=" . $reltol . " I_RelTol=" . $reltol  
    . " V_AbsTol=" . $vabstol . " I_AbsTol=" . $iabstol 
    . " Temp=" . $temp . " Tnom=" . $tnom  . " Gmin=" . $gmin . " NumDigits=". $digits;
}
if ($scale) { 
  # rawfmt=psfascii is created elsewhere.
  $Spectre_options = "save=lvlpub" 
    . " reltol=" . $reltol . " vabstol=" . $vabstol . " iabstol=" . $iabstol 
    . " temp=" . $temp . " tnom=" . $tnom  . " scale=" . $scale . " gmin=" . $gmin 
    . " digits=" . $digits;
  $Hspice_options = "ACCT=0 DCCAP=1"
    . " RELVDC=" . $reltol  . " RELI=" . $reltol  . " RELMOS=" . $reltol 
    . " ABSVDC=" . $vabstol . " ABSMOS=" . 100 * $iabstol . " ABSI=" . $iabstol 
    . " TNOM=" . $tnom  . " SCALE=" . $scale . " GMIN=" . $gmin . " NUMDGT=" . $digits
    . "\n.TEMP " . $temp;
} else {
  $Spectre_options = "save=lvlpub" 
    . " reltol=" . $reltol . " vabstol=" . $vabstol . " iabstol=" . $iabstol 
    . " temp=" . $temp . " tnom=" . $tnom  . " gmin=" . $gmin . " digits=" . $digits;
  $Hspice_options = "ACCT=0 DCCAP=1"
    . " RELVDC=" . $reltol  . " RELI=" . $reltol  . " RELMOS=" . $reltol 
    . " ABSVDC=" . $vabstol . " ABSMOS=" . 100 * $iabstol . " ABSI=" . $iabstol 
    . " TNOM=" . $tnom  . " GMIN=" . $gmin . " NUMDGT=" . $digits
    . "\n.TEMP " . $temp;
}

$OPTION1=dKitInstance->new(SIMULATOROPTION, myOptions);
$OPTION1->parameterValue(spectreOptions, $Spectre_options);
$OPTION1->parameterValue(adsOptions, $ADS_options);
$OPTION1->parameterValue(hspiceOptions, $Hspice_options);
$CIRCUIT->addSimulatorOption($OPTION1);

# Add Library Models


@ads_model_lib=split /\s*,\s*/,$ads_model_lib;
@hspice_model_lib=split /\s*,\s*/,$hspice_model_lib;
@spectre_model_lib=split /\s*,\s*/,$spectre_model_lib;

$maxsize = $#ads_model_lib;
if ($maxsize < $#hspice_model_lib)  {$maxsize = $#hspice_model_lib;}
if ($maxsize < $#spectre_model_lib) {$maxsize = $#spectre_model_lib;}

@MODLIB=();

# set ads model include line format to ads, spectre, hspice syntax, or inline
&dKitUtils::setAdsIncludeFormat(\@ads_model_lib, \@spectre_model_lib, \@hspice_model_lib, $inline);
# set spectre model include line format to spectre, hspice syntax, or inline
&dKitUtils::setScsIncludeFormat(\@spectre_model_lib, \@hspice_model_lib, $inline);
# set hspice model include line format to hspice syntax or inline
&dKitUtils::setHspIncludeFormat(\@hspice_model_lib, $inline);

foreach $count (0..$maxsize)
{
  $MODLIB[$count]=dKitInstance->new(MODELLIBRARY, 'lib_' . $count);
  $CIRCUIT->addModelLibrary($MODLIB[$count]);
}

foreach $model_file_index (0..$#ads_model_lib)
{
  ($mfilename,$msectionname)=split '#',$ads_model_lib[$model_file_index];
  $MODLIB[$model_file_index]->parameterValue(adsModelLibrary, $mfilename);
  if ($msectionname)
  {
    $MODLIB[$model_file_index]->parameterValue(adsSectionName, $msectionname);
  }
}

foreach $model_file_index (0..$#hspice_model_lib)
{
  ($mfilename,$msectionname)=split '#',$hspice_model_lib[$model_file_index];
  $MODLIB[$model_file_index]->parameterValue(hspiceModelLibrary, $mfilename);
  if ($msectionname)
  {
    $MODLIB[$model_file_index]->parameterValue(hspiceSectionName, $msectionname);
  }
}

foreach $model_file_index (0..$#spectre_model_lib)
{
  ($mfilename,$msectionname)=split '#',$spectre_model_lib[$model_file_index];
  $MODLIB[$model_file_index]->parameterValue(spectreModelLibrary, $mfilename);
  if ($msectionname)
  {
    $MODLIB[$model_file_index]->parameterValue(spectreSectionName, $msectionname);
  }
}

@model_name = split /\s*,\s*/, $model_name;
foreach $modelName (@model_name) {
  `rm -rf ${head}$modelName\_sparam.* 2>/dev/null`;
  $CIRCUIT->circuitName("${head}$modelName\_sparam");
  $m1->parameterValue('model',$modelName);
  $CIRCUIT->simulate(eval($simulators));
  my $passFail=mVerifyResults->compareResults("${head}$modelName\_sparam",$testname,$modelName,"sparam",$resultHtmlFile,$simulators,$abs_tol,"sParams.S[1,1]",$s11_tol,"sParams.S[2,1]",$s21_tol,"sParams.S[2,2]",$s22_tol,"sParams.S[1,2]",$s12_tol);
  print "$modelName Status: $passFail\n\n";
  mVerifyResults::deleteFiles("${head}$modelName\_sparam",$delFiles,$passFail);
}
