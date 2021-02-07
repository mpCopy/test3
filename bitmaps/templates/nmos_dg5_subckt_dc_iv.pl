#!/usr/bin/perl 
# Copyright Keysight Technologies 2007 - 2014  
# Template for five-terminal dual gate nmos DC IV test with x as prefix, i.e.,  
# using a subcircuit.

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
  print "       -testname []\n"; 
  print "       -id_tol []   -abs_tol []\n";
  print "       -model_name []\n"; 
  print "       -allparams []        -adsparams []           -spectreparams []           -hspiceparams []\n";
  print "       -source_v []         -bulk_v []\n";
  print "       -gate1_bias []       -gate2_bias []          -drain_bias []\n";
  print "                            -vd_pts []   -vd_start []    -vd_stop []    -vd_numpts []\n";
  print "       -sweep_vg1 [yes/no]  -vg1_pts []  -vg1_start []   -vg1_stop []   -vg1_numpts []\n";
  print "       -sweep_vg2 [yes/no]  -vg2_pts []  -vg2_start []   -vg2_stop []   -vg2_numpts []\n";
#  print "       -sweep_l [yes/no]    -l_pts []    -l_start []     -l_stop []     -l_numpts []\n";
#  print "       -sweep_w [yes/no]    -w_pts []    -w_start []     -w_stop []     -w_numpts []\n";
  print "       -sweep_temp [yes/no] -temp_pts []\n";
#  print "       -sweep_fingers [yes/no] -fingers_pts []\n";
  print "       -ads_model_lib []    -hspice_model_lib []    -spectre_model_lib []   -inline [yes/no]\n";
  print "       -reltol []  -vabstol []    -iabstol []    -gmin []\n";
  print "       -scale []    -temp[]   -tnom[]   -digits []\n";
  print "       -ads_scale []\n";
};

$ret = GetOptions ("h|help", "delfiles|delfiles:s", "simulators|simulators:s", "resultfile|resultfile:s", "id_tol|id_tol:s", "abs_tol|abs_tol:s", "testname|testname:s", "model_name|device_name:s", "allparams|allparams:s", "adsparams|adsparams:s", "hspiceparams|hspiceparams:s", "spectreparams|spectreparams:s", "source_v|source_v:f", "bulk_v|bulk_v:f", "gate1_bias|gate1_bias:f", "gate2_bias|gate2_bias:f", "drain_bias|drain_bias:f", "vd_pts|vd_pts:s", "vd_start|vd_start:f", "vd_stop|vd_stop:f", "vd_numpts|vd_numpts:i", "sweep_vg1|sweep_vg1:s", "vg1_pts|vg1_pts:s", "vg1_start|vg1_start:f", "vg1_stop|vg1_stop:f", "vg1_numpts|vg1_numpts:i", "sweep_vg2|sweep_vg2:s", "vg2_pts|vg2_pts:s", "vg2_start|vg2_start:f", "vg2_stop|vg2_stop:f", "vg2_numpts|vg2_numpts:i", "sweep_l|sweep_l:s", "l_pts|l_pts:s", "l_start|l_start:f", "l_stop|l_stop:f", "l_numpts|l_numpts:i", "sweep_w|sweep_w:s", "w_pts|w_pts:s", "w_start|w_start:f", "w_stop|w_stop:f", "w_numpts|w_numpts:i", "sweep_temp|sweep_temp:s", "temp_pts|temp_pts:s", "sweep_fingers|sweep_fingers:s", "fingers_pts|fingers_pts:s", "ads_model_lib|ads_model_lib:s", "hspice_model_lib|hspice_model_lib:s", "spectre_model_lib|spectre_model_lib:s","inline|inline:s","reltol|reltol:f","vabstol|vabstol:f","iabstol|iabstol:f","gmin|gmin:f","scale|scale:f","temp|temp:f","tnom|tnom:f","digits|digits:i","ads_scale|ads_scale:f");

$help               = $opt_h;
if ($help) {Usage();exit}

$simulators         = $opt_simulators;
$testname           = $opt_testname;
$model_name         = $opt_model_name;
$delFiles           = $opt_delfiles;
$resultHtmlFile     = $opt_resultfile;


$id_tol             = $opt_id_tol;
if(!$id_tol) {$id_tol=1.0;}

$abs_tol            = $opt_abs_tol;
if (!$abs_tol) { $abs_tol=1e-20; }

$allparams          = $opt_allparams;
$adsparams          = $opt_adsparams;
$hspiceparams       = $opt_hspiceparams;
$spectreparams      = $opt_spectreparams;

$source_v           = $opt_source_v;
$bulk_v             = $opt_bulk_v;
$gate1_bias         = $opt_gate1_bias;
$gate2_bias         = $opt_gate2_bias;
$drain_bias         = $opt_drain_bias;

$vd_pts             = $opt_vd_pts;
$vd_start           = $opt_vd_start;
$vd_stop            = $opt_vd_stop;
$vd_numpts          = $opt_vd_numpts;

$sweep_vg1          = $opt_sweep_vg1;
$vg1_pts            = $opt_vg1_pts;
$vg1_start          = $opt_vg1_start;
$vg1_stop           = $opt_vg1_stop;
$vg1_numpts         = $opt_vg1_numpts;

$sweep_vg2          = $opt_sweep_vg2;
$vg2_pts            = $opt_vg2_pts;
$vg2_start          = $opt_vg2_start;
$vg2_stop           = $opt_vg2_stop;
$vg2_numpts         = $opt_vg2_numpts;

#$sweep_l            = $opt_sweep_l;
$l_pts              = $opt_l_pts;
$l_start            = $opt_l_start;
$l_stop             = $opt_l_stop;
$l_numpts           = $opt_l_numpts;

#$sweep_w            = $opt_sweep_w;
$w_pts              = $opt_w_pts;
$w_start            = $opt_w_start;
$w_stop             = $opt_w_stop;
$w_numpts           = $opt_w_numpts;

$sweep_temp         = $opt_sweep_temp;
$temp_pts           = $opt_temp_pts;

#$sweep_fingers      = $opt_sweep_fingers;
$fingers_pts        = $opt_fingers_pts;

$ads_model_lib      = $opt_ads_model_lib;

$hspice_model_lib   = $opt_hspice_model_lib;
$spectre_model_lib  = $opt_spectre_model_lib;
$inline             = $opt_inline;
if($inline && lc($inline) eq 'yes') {$inline=1;}

# This is a simulation to compare ADS vs. HSPICE using the verification 
# tool. It is a DC IV Simulation using a dual-gate FET device.

# This simulation is intended to find Id vs Vd while sweeping vg1 and/or vg2.  

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
my $modelLabel='model';
$rf_fet->addParameter('model');
$rf_fet->addParameter("allParams");
$rf_fet->addParameter("adsParams");
$rf_fet->addParameter("hspiceParams");
$rf_fet->addParameter("spectreParams");

my $nodelist=" %n1 %n2 %n3 %n4 %n5 ";
my $adsInstLine = &dKitUtils::setAdsInstanceLineFormat($modelLabel, $adsparams, $spectreparams, $hspiceparams, $nodelist);
$rf_fet->netlistInstanceTemplate(ads, $adsInstLine);
my $spectreInstLine = &dKitUtils::setSpectreInstanceLineFormat($modelLabel, $spectreparams, $hspiceparams, $nodelist);
$rf_fet->netlistInstanceTemplate(spectre, $spectreInstLine);
$rf_fet->netlistInstanceTemplate(hspice, '#instanceName %n1 %n2 %n3 %n4 %n5 <' . $modelLabel . '> [[<allParams>]] [[<hspiceParams>]]');


# Add instances of FET and five voltage sources, vd, vs, vg1, vg2 and vb.
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
$m1->nodeName(n2, 'gate1');
$m1->nodeName(n3, 'gate2');
$m1->nodeName(n4, 'source');
$m1->nodeName(n5, 'bulk');
$CIRCUIT->addInstance($m1);

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

$vg1=dKitInstance->new(V, vg1);
$vg1->nodeName(nplus, 'gate1');
$vg1->nodeName(nminus, 0);
if (! defined $gate1_bias) {$gate1_bias=0.9;} 
$vg1->parameterValue(Vdc, $gate1_bias);
$CIRCUIT->addInstance($vg1);

$vg2=dKitInstance->new(V, vg2);
$vg2->nodeName(nplus, 'gate2');
$vg2->nodeName(nminus, 0);
if (! defined $gate2_bias) {$gate2_bias=0.9;} 
$vg2->parameterValue(Vdc, $gate2_bias);
$CIRCUIT->addInstance($vg2);

$vd=dKitInstance->new(V, vd);
$vd->nodeName(nplus, 'drain');
$vd->nodeName(nminus, 0);
if (! defined $drain_bias) {$drain_bias=0.5;}
$vd->parameterValue(Vdc, $drain_bias);
$CIRCUIT->addInstance($vd);

# Add DC (Id vs Vds) Analysis Component

# Add Sweep Plans  
if ($vd_pts) {
  $SWEEPPLAN1 = dKitAnalysis->new(SWEEPPLAN_PT, Plan1);
  $SWEEPPLAN1->parameterValue("values", $vd_pts);
} else
{
  if (! defined $vd_start) { $vd_start='0.1';}
  if (! defined $vd_stop) { $vd_stop='2.5';}
  if (! defined $vd_numpts) { $vd_numpts='51';}
  $SWEEPPLAN1 = dKitAnalysis->new(SWEEPPLAN_LIN, Plan1);
  $SWEEPPLAN1->parameterValue(start, $vd_start);
  $SWEEPPLAN1->parameterValue(stop, $vd_stop);
  $SWEEPPLAN1->parameterValue(numPts, $vd_numpts);
}

$DC1 = dKitAnalysis->new(DC, DC1);
$DC1->parameterValue(device, 'vd');
$DC1->parameterValue(parameter, 'Vdc');
$DC1->addSweepPlan($SWEEPPLAN1);
$sweep_level = 1;

if (($sweep_vg1) && ($sweep_vg1 ne 'no'))
{
  $sweep_level = 2;
#  print "SWEEP_LEVEL = $sweep_level\n";

  if ($vg1_pts) {
    $SWEEPPLAN2 = dKitAnalysis->new(SWEEPPLAN_PT, Plan2);
    $SWEEPPLAN2->parameterValue("values", $vg1_pts);
  } else
  {
    if (! defined $vg1_start) { $vg1_start='0.5';}
    if (! defined $vg1_stop) { $vg1_stop='1.5';}
    if (! defined $vg1_numpts) { $vg1_numpts='5';}
    $SWEEPPLAN2 = dKitAnalysis->new(SWEEPPLAN_LIN, Plan2);
    $SWEEPPLAN2->parameterValue(start, $vg1_start);
    $SWEEPPLAN2->parameterValue(stop, $vg1_stop);
    $SWEEPPLAN2->parameterValue(numPts, $vg1_numpts);
  }

  $SWEEP2 = dKitAnalysis->new(SWEEP, Sweep2);
  $SWEEP2->parameterValue(device, 'vg1');
  $SWEEP2->parameterValue(parameter, 'Vdc');
  $SWEEP2->addSweepPlan($SWEEPPLAN2);
  $SWEEP2->addSubAnalysis($DC1);
}

if (($sweep_l) && ($sweep_l ne 'no'))
{
  $sweep_level = 3;
#  print "SWEEP_LEVEL = $sweep_level\n";

  if ($l_pts) {
    $SWEEPPLAN3 = dKitAnalysis->new(SWEEPPLAN_PT, Plan3);
    $SWEEPPLAN3->parameterValue("values", $l_pts);
  } else
  {
    if (! defined $l_start) { $l_start='0.2e-6';}
    if (! defined $l_stop) { $l_stop='1e-6';}
    if (! defined $l_numpts) { $l_numpts='5';}
    $SWEEPPLAN3 = dKitAnalysis->new(SWEEPPLAN_LIN, Plan3);
    $SWEEPPLAN3->parameterValue(start, $l_start);
    $SWEEPPLAN3->parameterValue(stop, $l_stop);
    $SWEEPPLAN3->parameterValue(numPts, $l_numpts);
  }

  $SWEEP3 = dKitAnalysis->new(SWEEP, Sweep3);
  $SWEEP3->parameterValue(device, 'x1');  
  $SWEEP3->parameterValue(parameter, 'length');
  $SWEEP3->addSweepPlan($SWEEPPLAN3);
  if ($SWEEP2)  {$SWEEP3->addSubAnalysis($SWEEP2);}
  else          {$SWEEP3->addSubAnalysis($DC1);}
}

if (($sweep_w) && ($sweep_w ne 'no'))
{
  $sweep_level = 4;
#  print "SWEEP_LEVEL = $sweep_level\n";

  if ($w_pts) {
    $SWEEPPLAN4 = dKitAnalysis->new(SWEEPPLAN_PT, Plan4);
    $SWEEPPLAN4->parameterValue("values", $w_pts);
  } else
  {
    if (! defined $w_start) { $w_start='0.2e-6';}
    if (! defined $w_stop) { $w_stop='1e-6';}
    if (! defined $w_numpts) { $w_numpts='5';}
    $SWEEPPLAN4 = dKitAnalysis->new(SWEEPPLAN_LIN, Plan4);
    $SWEEPPLAN4->parameterValue(start, $w_start);
    $SWEEPPLAN4->parameterValue(stop, $w_stop);
    $SWEEPPLAN4->parameterValue(numPts, $w_numpts);
  }

  $SWEEP4 = dKitAnalysis->new(SWEEP, Sweep4);
  $SWEEP4->parameterValue(device, 'x1');
  $SWEEP4->parameterValue(parameter, 'width');
  $SWEEP4->addSweepPlan($SWEEPPLAN4);
  if    ($SWEEP3)  {$SWEEP4->addSubAnalysis($SWEEP3);}
  elsif ($SWEEP2)  {$SWEEP4->addSubAnalysis($SWEEP2);}
  else             {$SWEEP4->addSubAnalysis($DC1);}
}

if (($sweep_temp) && ($sweep_temp ne 'no'))
{
  $sweep_level = 5;
#  print "SWEEP_LEVEL = $sweep_level\n";

  $SWEEPPLAN5 = dKitAnalysis->new(SWEEPPLAN_PT, Plan5);
    if (! defined $temp_pts) { $temp_pts='-40 25 125';  print "\$temp_pts not defined.  \$temp_pts set to \"$temp_pts\"\n";}
  $SWEEPPLAN5->parameterValue("values", $temp_pts);

  $SWEEP5 = dKitAnalysis->new(SWEEP, Sweep5);
  $SWEEP5->parameterValue(parameter, 'temp');
  $SWEEP5->addSweepPlan($SWEEPPLAN5);
   if    ($SWEEP4)  {$SWEEP5->addSubAnalysis($SWEEP4);}
   elsif ($SWEEP3)  {$SWEEP5->addSubAnalysis($SWEEP3);}
   elsif ($SWEEP2)  {$SWEEP5->addSubAnalysis($SWEEP2);}
   else             {$SWEEP5->addSubAnalysis($DC1);}
}

if (($sweep_fingers) && ($sweep_fingers ne 'no'))
{
  $sweep_level = 6;
#  print "SWEEP_LEVEL = $sweep_level\n";

  $SWEEPPLAN6 = dKitAnalysis->new(SWEEPPLAN_PT, Plan6);
    if (! defined $fingers_pts) { $fingers_pts='2 4 8';  print "\$fingers_pts not defined.  \$fingers_pts set to \"$fingers_pts\"\n";}
  $SWEEPPLAN6->parameterValue("values", $fingers_pts);

  $SWEEP6 = dKitAnalysis->new(SWEEP, Sweep6);
  $SWEEP6->parameterValue(parameter, 'fingers');
  $SWEEP6->addSweepPlan($SWEEPPLAN6);
   if    ($SWEEP5)  {$SWEEP6->addSubAnalysis($SWEEP5);}
   elsif ($SWEEP4)  {$SWEEP6->addSubAnalysis($SWEEP4);}
   elsif ($SWEEP3)  {$SWEEP6->addSubAnalysis($SWEEP3);}
   elsif ($SWEEP2)  {$SWEEP6->addSubAnalysis($SWEEP2);}
   else             {$SWEEP6->addSubAnalysis($DC1);}
}

if (($sweep_vg2) && ($sweep_vg2 ne 'no'))
{
  $sweep_level = 7;
#  print "SWEEP_LEVEL = $sweep_level\n";

  if ($vg2_pts) {
    $SWEEPPLAN7 = dKitAnalysis->new(SWEEPPLAN_PT, Plan7);
    $SWEEPPLAN7->parameterValue("values", $vg2_pts);
  } else
  {
    if (! defined $vg2_start) { $vg2_start='0.5';}
    if (! defined $vg2_stop) { $vg2_stop='1.5';}
    if (! defined $vg2_numpts) { $vg2_numpts='5';}
    $SWEEPPLAN7 = dKitAnalysis->new(SWEEPPLAN_LIN, Plan7);
    $SWEEPPLAN7->parameterValue(start, $vg2_start);
    $SWEEPPLAN7->parameterValue(stop, $vg2_stop);
    $SWEEPPLAN7->parameterValue(numPts, $vg2_numpts);
  }

  $SWEEP7 = dKitAnalysis->new(SWEEP, Sweep7);
  $SWEEP7->parameterValue(device, 'vg2');
  $SWEEP7->parameterValue(parameter, 'Vdc');
  $SWEEP7->addSweepPlan($SWEEPPLAN7);
   if    ($SWEEP6)  {$SWEEP7->addSubAnalysis($SWEEP6);}
   elsif ($SWEEP5)  {$SWEEP7->addSubAnalysis($SWEEP5);}
   elsif ($SWEEP4)  {$SWEEP7->addSubAnalysis($SWEEP4);}
   elsif ($SWEEP3)  {$SWEEP7->addSubAnalysis($SWEEP3);}
   elsif ($SWEEP2)  {$SWEEP7->addSubAnalysis($SWEEP2);}
   else             {$SWEEP7->addSubAnalysis($DC1);}
}

# print "FINALSWEEP LEVEL= $sweep_level\n";

if    ($sweep_level == 1) {$CIRCUIT->addAnalysis($DC1);}
elsif ($sweep_level == 2) {$CIRCUIT->addAnalysis($SWEEP2);}
elsif ($sweep_level == 3) {$CIRCUIT->addAnalysis($SWEEP3);}
elsif ($sweep_level == 4) {$CIRCUIT->addAnalysis($SWEEP4);}
elsif ($sweep_level == 5) {$CIRCUIT->addAnalysis($SWEEP5);}
elsif ($sweep_level == 6) {$CIRCUIT->addAnalysis($SWEEP6);}
else                      {$CIRCUIT->addAnalysis($SWEEP7);}


# Output Plans

$OUTPUTDOPS=dKitAnalysis->new(OUTPUTPLAN_DOPS, "out1");
$OUTPUTDOPS->parameterValue(deviceParameters, "vd:i");
$DC1->addOutputPlan($OUTPUTDOPS);

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
  $m1->parameterValue('model',$modelName);
  `rm -rf ${head}$modelName\_dc\_iv.* 2>/dev/null`;
  $CIRCUIT->circuitName("${head}$modelName\_dc\_iv");
  $CIRCUIT->simulate(eval($simulators));
  my $passFail=mVerifyResults->compareResults("${head}$modelName\_dc\_iv",$testname,$modelName,"dc_iv",$resultHtmlFile,$simulators,$abs_tol,"vd.i1",$id_tol);
  print "$modelName Status: $passFail\n\n";
  mVerifyResults::deleteFiles("${head}$modelName\_dc\_iv",$delFiles,$passFail);
}
