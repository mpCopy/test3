#!/usr/bin/perl 
# Copyright Keysight Technologies 2007 - 2014  
# DC IV test template for four-terminal nmos with LOD parameters 
# with m as prefix, i.e., using a model.
# Note: spectre part not implemented yet because no spectre LOD information available.

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
  print "       -id_tol []   -abs_tol []\n";
  print "       -testname []\n"; 
  print "       -model_name []\n"; 
  print "       -allparams []        -adsparams []    -spectreparams []    -hspiceparams []\n";

  print "       -length []           -width []    -bin_length []  -bin_width []\n";
  print "       -ad []               -as []       -pd []          -ps []         -nrd []     -nrs []\n";
  print "       -nqsmod []  \n";
  print "       -source_v []         -bulk_v []\n";
  print "       -gate_bias []        -drain_bias []\n";
  print "                            -vd_pts []   -vd_start []    -vd_stop []    -vd_numpts []\n";
  print "       -sweep_vg [yes/no]   -vg_pts []   -vg_start []    -vg_stop []    -vg_numpts []\n";
  print "       -sweep_l [yes/no]    -l_pts []    -l_start []     -l_stop []     -l_numpts []\n";
  print "       -sweep_w [yes/no]    -w_pts []    -w_start []     -w_stop []     -w_numpts []\n";
  print "       -sweep_temp [yes/no] -temp_pts []\n";
#  print "       -sweep_fingers [yes/no] -fingers_pts []\n";
  print "       -ads_model_lib []    -hspice_model_lib []    -spectre_model_lib []   -inline [yes/no]\n";
  print "  -nf [] \n";
#### LOD Parameters #############
  print "  -Rgeomod [] -Geomod [] -Sa [] -Sb [] -Sd [] \n";
  print " -Sa1 [] -Sb1 [] -Sw1 [] -Sa2 [] -Sb2 [] -Sw2 []  \n";
  print " -Sa3 [] -Sb3 [] -Sw3 [] -Sa4 [] -Sb4 [] -Sw4 []  \n";
  print " -Sa5 [] -Sb5 [] -Sw5 [] -Sa6 [] -Sb6 [] -Sw6 []  \n";
  print " -Sa7 [] -Sb7 [] -Sw7 [] -Sa8 [] -Sb8 [] -Sw8 []  \n";
  print " -Sa9 []  -Sb9 [] -Sw9 [] -Sa10 [] -Sb10 [] -Sw10 []  \n";
#### End LOD Parameters #############

  print "       -reltol []  -vabstol []    -iabstol []    -gmin []\n";
  print "       -scale []    -temp[]   -tnom[]   -digits []\n";
  print "       -ads_scale []\n";
};

sub getVal {
   local($str) = @_;
   $str =~ s/[uU][mM]*/*1e-6/;
   $str =~ s/[nN][mM]*/*1e-9/;
   return(eval($str));
};

$ret = GetOptions ("h|help", "delfiles|delfiles:s", "resultfile|resultfile:s", "id_tol|id_tol:s", "abs_tol|abs_tol:s", "bin_length|bin_length:s", "bin_width|bin_width:s", "length|length:s", "width|width:s", "ad|ad:s", "pd|pd:s", "nrd|nrd:s", "ps|ps:s", "as|as:s", "nrs|nrs:s", "nqsmod|nqsmod:s", "simulators|simulators:s", "testname|testname:s", "model_name|device_name:s", "allparams|allparams:s", "adsparams|adsparams:s", "hspiceparams|hspiceparams:s", "spectreparams|spectreparams:s", "source_v|source_v:f", "bulk_v|bulk_v:f", "gate_bias|gate_bias:f", "drain_bias|drain_bias:f", "vd_pts|vd_pts:s", "vd_start|vd_start:f", "vd_stop|vd_stop:f", "vd_numpts|vd_numpts:i", "sweep_vg|sweep_vg:s", "vg_pts|vg_pts:s", "vg_start|vg_start:f", "vg_stop|vg_stop:f", "vg_numpts|vg_numpts:i", "sweep_l|sweep_l:s", "l_pts|l_pts:s", "l_start|l_start:f", "l_stop|l_stop:f", "l_numpts|l_numpts:i", "sweep_w|sweep_w:s", "w_pts|w_pts:s", "w_start|w_start:f", "w_stop|w_stop:f", "w_numpts|w_numpts:i", "sweep_temp|sweep_temp:s", "temp_pts|temp_pts:s", "sweep_fingers|sweep_fingers:s", "fingers_pts|fingers_pts:s", "ads_model_lib|ads_model_lib:s", "hspice_model_lib|hspice_model_lib:s", "spectre_model_lib|spectre_model_lib:s","inline|inline:s", "nf|nf:i", "Rgeomod|Rgeomod:s", "Geomod|Geomod:s", "Sa|Sa:s", "Sb|Sb:s", "Sd|Sd:s", "Sa1|Sa1:s", "Sb1|Sb1:s", "Sw1|Sw1:s", "Sa2|Sa2:s", "Sb2|Sb2:s", "Sw2|Sw2:s", "Sa3|Sa3:s", "Sb3|Sb3:s", "Sw3|Sw3:s", "Sa4|Sa4:s", "Sb4|Sb4:s", "Sw4|Sw4:s", "Sa5|Sa5:s", "Sb5|Sb5:s", "Sw5|Sw5:s", "Sa6|Sa6:s", "Sb6|Sb6:s", "Sw6|Sw6:s", "Sa7|Sa7:s", "Sb7|Sb7:s", "Sw7|Sw7:s", "Sa8|Sa8:s", "Sb8|Sb8:s", "Sw8|Sw8:s", "Sa9|Sa9:s", "Sb9|Sb9:s", "Sw9|Sw9:s", "Sa10|Sa10:s", "Sb10|Sb10:s", "Sw10|Sw10:s","reltol|reltol:f","vabstol|vabstol:f","iabstol|iabstol:f","gmin|gmin:f","scale|scale:f","temp|temp:f","tnom|tnom:f","digits|digits:i","ads_scale|ads_scale:f");


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

$bin_length         = $opt_bin_length;
$bin_width          = $opt_bin_width;
$length             = $opt_length;
$width              = $opt_width;
$as                 = $opt_as;
$ad                 = $opt_ad;
$ps                 = $opt_ps;
$pd                 = $opt_pd;
$nrs                = $opt_nrs;
$nrd                = $opt_nrd;
$nqsmod             = $opt_nqsmod;

$source_v           = $opt_source_v;
$bulk_v             = $opt_bulk_v;
$gate_bias          = $opt_gate_bias;
$drain_bias         = $opt_drain_bias;

$vd_pts             = $opt_vd_pts;
$vd_start           = $opt_vd_start;
$vd_stop            = $opt_vd_stop;
$vd_numpts          = $opt_vd_numpts;

$sweep_vg           = $opt_sweep_vg;
$vg_pts             = $opt_vg_pts;
$vg_start           = $opt_vg_start;
$vg_stop            = $opt_vg_stop;
$vg_numpts          = $opt_vg_numpts;

$sweep_l            = $opt_sweep_l;
$l_pts              = $opt_l_pts;
$l_start            = $opt_l_start;
$l_stop             = $opt_l_stop;
$l_numpts           = $opt_l_numpts;

$sweep_w            = $opt_sweep_w;
$w_pts              = $opt_w_pts;
$w_start            = $opt_w_start;
$w_stop             = $opt_w_stop;
$w_numpts           = $opt_w_numpts;

$sweep_temp         = $opt_sweep_temp;
$temp_pts           = $opt_temp_pts;

# $sweep_fingers      = $opt_sweep_fingers;
$fingers_pts        = $opt_fingers_pts;

$ads_model_lib      = $opt_ads_model_lib;

$hspice_model_lib   = $opt_hspice_model_lib;
$spectre_model_lib  = $opt_spectre_model_lib;
$inline             = $opt_inline;
if($inline && lc($inline) eq 'yes') {$inline=1;}

$nf        = $opt_nf;
#### LOD Parameters #############

$Rgeomod   = $opt_Rgeomod;
$Geomod    = $opt_Geomod;
$Sa        = $opt_Sa;
$Sb        = $opt_Sb;
$Sd        = $opt_Sd;
$Sa1       = $opt_Sa1;
$Sb1       = $opt_Sb1;
$Sw[1]       = $opt_Sw1;
$Sa2       = $opt_Sa2;
$Sb2       = $opt_Sb2;
$Sw[2]       = $opt_Sw2;
$Sa3       = $opt_Sa3;
$Sb3       = $opt_Sb3;
$Sw[3]       = $opt_Sw3;
$Sa4       = $opt_Sa4;
$Sb4       = $opt_Sb4;
$Sw[4]       = $opt_Sw4;
$Sa5       = $opt_Sa5;
$Sb5       = $opt_Sb5;
$Sw[5]       = $opt_Sw5;
$Sa6       = $opt_Sa6;
$Sb6       = $opt_Sb6;
$Sw[6]       = $opt_Sw6;
$Sa7       = $opt_Sa7;
$Sb7       = $opt_Sb7;
$Sw[7]       = $opt_Sw7;
$Sa8       = $opt_Sa8;
$Sb8       = $opt_Sb8;
$Sw[8]       = $opt_Sw8;
$Sa9       = $opt_Sa9;
$Sb9       = $opt_Sb9;
$Sw[9]       = $opt_Sw9;
$Sa10      = $opt_Sa10;
$Sb10      = $opt_Sb10;
$Sw[10]      = $opt_Sw10;
#### End LOD Parameters #############

# Model: nmos

# This is a simulation to compare ADS vs. HSPICE using the verification 
# tool. It is an S-Parameter Simulation using a FET device.

# This simulation is intended to find S parameters vs. frequency while sweeping vg.  

if (! $testname) {
  $head = "";
  $CIRCUIT=dKitCircuit->new('nmos');
} else {
  $CIRCUIT=dKitCircuit->new($testname);
  $head = $testname . "_";
}

# Add instances of FET and four voltage sources, vd, vs, vg and vb.
if (! $model_name) {die "Error: \$model_name must be defined.";}
$model_name=~s/\s//g;
if ($allparams||$spectreparams||$adsparams||$hspiceparams)
{
if ($bin_length||$bin_width||$length||$width||$as||$ad||$ps||$pd||$nrs||$nrd||$nqsmod||$nf)
{
print "WARNING: Instance parameters specified individually are ignored when *params are used!\n";
}
$fet = dKitTemplate->new(fet);
$fet->requiredPrefix("m");
$fet->addNode("n1");
$fet->addNode("n2");
$fet->addNode("n3");
$fet->addNode("n4");
my $modelLabel='modelName';
$fet->addParameter('modelName');
$fet->addParameter("allParams");
$fet->addParameter("adsParams");
$fet->addParameter("hspiceParams");
$fet->addParameter("spectreParams");

my $nodelist=" %n1 %n2 %n3 %n4 ";
my $adsInstLine = &dKitUtils::setAdsInstanceLineFormat($modelLabel, $adsparams, $spectreparams, $hspiceparams, $nodelist);
$fet->netlistInstanceTemplate(ads, $adsInstLine);
my $spectreInstLine = &dKitUtils::setSpectreInstanceLineFormat($modelLabel, $spectreparams, $hspiceparams, $nodelist);
$fet->netlistInstanceTemplate(spectre, $spectreInstLine);
$fet->netlistInstanceTemplate(hspice, '#instanceName %n1 %n2 %n3 %n4 <' . $modelLabel . '> [[<allParams>]] [[<hspiceParams>]]');

$m1=dKitInstance->new(fet, m1);
$m1->parameterValue('modelName',$model_name);
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
$CIRCUIT->addInstance($m1);
} else {
$m1=dKitInstance->new(M, m1);
if (defined $length) {$m1->parameterValue('length', $length);}
if (defined $width) {$m1->parameterValue('width', $width);}
if (defined $ps) {$m1->parameterValue('sourcePerimeter', $ps);}
if (defined $as) {$m1->parameterValue('sourceDiffusionArea', $as);}
if (defined $nrs) {$m1->parameterValue('sourceDiffusionSquares', $nrs);}
if (defined $pd) {$m1->parameterValue('drainPerimeter', $pd);}
if (defined $ad) {$m1->parameterValue('drainDiffusionArea', $ad);}
if (defined $nrd) {$m1->parameterValue('drainDiffusionSquares', $nrd);}
if (defined $nqsmod) {$m1->parameterValue('nqsmod', $nqsmod);}

if (defined $nf) {$m1->parameterValue('nf', $nf);}

#### LOD Parameters #############

if (defined $Rgeomod) {$m1->parameterValue('Rgeomod', $Rgeomod);}
if (defined $Geomod) {$m1->parameterValue('Geomod', $Geomod);}
if (defined $Sa) { $m1->parameterValue('Sa', $Sa);}
if (defined $Sb) { $m1->parameterValue('Sb', $Sb);}
if (defined $Sd) { $m1->parameterValue('Sd', $Sd);}
if (defined $Sa1) { $Sa1=&getVal($Sa1); $m1->parameterValue('Sa1', $Sa1);}
if (defined $Sb1) { $Sb1=&getVal($Sb1); $m1->parameterValue('Sb1', $Sb1);}
if (defined $opt_Sw1) { $m1->parameterValue('Sw1', $opt_Sw1);}
if (defined $Sa2) { $Sa2=&getVal($Sa2); $m1->parameterValue('Sa2', $Sa2);}
if (defined $Sb2) { $Sb2=&getVal($Sb2); $m1->parameterValue('Sb2', $Sb2);}
if (defined $opt_Sw2) { $m1->parameterValue('Sw2', $opt_Sw2);}
if (defined $Sa3) { $Sa3=&getVal($Sa3); $m1->parameterValue('Sa3', $Sa3);}
if (defined $Sb3) { $Sb3=&getVal($Sb3); $m1->parameterValue('Sb3', $Sb3);}
if (defined $opt_Sw3) { $m1->parameterValue('Sw3', $opt_Sw3);}
if (defined $Sa4) { $Sa4=&getVal($Sa4); $m1->parameterValue('Sa4', $Sa4);}
if (defined $Sb4) { $Sb4=&getVal($Sb4); $m1->parameterValue('Sb4', $Sb4);}
if (defined $opt_Sw4) { $m1->parameterValue('Sw4', $opt_Sw4);}
if (defined $Sa5) { $Sa5=&getVal($Sa5); $m1->parameterValue('Sa5', $Sa5);} 
if (defined $Sb5) { $Sb5=&getVal($Sb5); $m1->parameterValue('Sb5', $Sb5);}
if (defined $opt_Sw5) { $m1->parameterValue('Sw5', $opt_Sw5);}
if (defined $Sa6) { $Sa6=&getVal($Sa6); $m1->parameterValue('Sa6', $Sa6);}
if (defined $Sb6) { $Sb6=&getVal($Sb6); $m1->parameterValue('Sb6', $Sb6);}
if (defined $opt_Sw6) { $m1->parameterValue('Sw6', $opt_Sw6);}
if (defined $Sa7) { $Sa7=&getVal($Sa7); $m1->parameterValue('Sa7', $Sa7);}
if (defined $Sb7) { $Sb7=&getVal($Sb7); $m1->parameterValue('Sb7', $Sb7);}
if (defined $opt_Sw7) { $m1->parameterValue('Sw7', $opt_Sw7);}
if (defined $Sa8) { $Sa8=&getVal($Sa8); $m1->parameterValue('Sa8', $Sa8);}
if (defined $Sb8) { $Sb8=&getVal($Sb8); $m1->parameterValue('Sb8', $Sb8);}
if (defined $opt_Sw8) { $m1->parameterValue('Sw8', $opt_Sw8);}
if (defined $Sa9) { $Sa9=&getVal($Sa9); $m1->parameterValue('Sa9', $Sa9);}
if (defined $Sb9) { $Sb9=&getVal($Sb9); $m1->parameterValue('Sb9', $Sb9);}
if (defined $opt_Sw9) { $m1->parameterValue('Sw9', $opt_Sw9);}
if (defined $Sa10) { $Sa10=&getVal($Sa10); $m1->parameterValue('Sa10', $Sa10);}
if (defined $Sb10) { $Sb10=&getVal($Sb10); $m1->parameterValue('Sb10', $Sb10);}
if (defined $opt_Sw10) { $m1->parameterValue('Sw10', $opt_Sw10);}
#### End LOD Parameters #############

$m1->nodeName(nd, 'drain');
$m1->nodeName(ng, 'gate');
$m1->nodeName(ns, 'source');
$m1->nodeName(nb, 'bulk');
$CIRCUIT->addInstance($m1);
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

$vg=dKitInstance->new(V, vg);
$vg->nodeName(nplus, 'gate');
$vg->nodeName(nminus, 0);
if (! defined $gate_bias) {$gate_bias=1.5;} 
$vg->parameterValue(Vdc, $gate_bias);
$CIRCUIT->addInstance($vg);

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

if (($sweep_vg) && ($sweep_vg ne 'no'))
{
  $sweep_level = 2;
#  print "SWEEP_LEVEL = $sweep_level\n";

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
  $SWEEP2->parameterValue(device, 'vg');
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
  $SWEEP3->parameterValue(device, 'm1');  
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
  $SWEEP4->parameterValue(device, 'm1');
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
   if    ($SWEEP5)  {$SWEEP5->addSubAnalysis($SWEEP5);}
   elsif ($SWEEP4)  {$SWEEP5->addSubAnalysis($SWEEP4);}
   elsif ($SWEEP3)  {$SWEEP5->addSubAnalysis($SWEEP3);}
   elsif ($SWEEP2)  {$SWEEP5->addSubAnalysis($SWEEP2);}
   else             {$SWEEP5->addSubAnalysis($DC1);}
}

# print "FINALSWEEP LEVEL= $sweep_level\n";

if    ($sweep_level == 1) {$CIRCUIT->addAnalysis($DC1);}
elsif ($sweep_level == 2) {$CIRCUIT->addAnalysis($SWEEP2);}
elsif ($sweep_level == 3) {$CIRCUIT->addAnalysis($SWEEP3);}
elsif ($sweep_level == 4) {$CIRCUIT->addAnalysis($SWEEP4);}
elsif ($sweep_level == 5) {$CIRCUIT->addAnalysis($SWEEP5);}
else                      {$CIRCUIT->addAnalysis($SWEEP6);}


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

if (($bin_width) && (! defined $bin_length)) { if ($length) {$bin_length=$length;} else { print "WARNING:  bin_width defined but length and bin_length undefined." }}
if ((! defined $bin_width) && ($bin_length)) { if ($width) {$bin_width=$width;} else { print "WARNING:  bin_length defined but width and bin_width are undefined." }}
@bin_length = split /\s*,\s*/, $bin_length;
@bin_width = split /\s*,\s*/, $bin_width;
@model_name = split /\s*,\s*/, $model_name;
foreach $modelName (@model_name) 
{
  if ((! defined $bin_length) && (! defined $bin_width))
  {
    `rm -rf ${head}$modelName\_dc\_iv.* 2>/dev/null`;
    $CIRCUIT->circuitName("${head}$modelName\_dc\_iv");
    $m1->parameterValue('modelName',$modelName);
    #### LOD Parameters #############
    if ($width) {
      $width=&getVal($width);
      $length=&getVal($length);
      if (defined $opt_Sw10) { $Sw_count=10; }
      elsif (defined $opt_Sw9) { $Sw_count=9; }
      elsif (defined $opt_Sw8) { $Sw_count=8; }
      elsif (defined $opt_Sw7) { $Sw_count=7; }
      elsif (defined $opt_Sw6) { $Sw_count=6; }
      elsif (defined $opt_Sw5) { $Sw_count=5; }
      elsif (defined $opt_Sw4) { $Sw_count=4; }
      elsif (defined $opt_Sw3) { $Sw_count=3; }
      elsif (defined $opt_Sw2) { $Sw_count=2; }
      else { $Sw_count=1; }
    
      foreach $i (1 .. $Sw_count) { $Sw[$i]=$width/$Sw_count; }
      foreach $i ($Sw_count+1 .. 10) { undef($Sw[$i]); }
    
      $m1->parameterValue('Sw1', $Sw[1]);
      $m1->parameterValue('Sw2', $Sw[2]);
      $m1->parameterValue('Sw3', $Sw[3]);
      $m1->parameterValue('Sw4', $Sw[4]);
      $m1->parameterValue('Sw5', $Sw[5]);
      $m1->parameterValue('Sw6', $Sw[6]);
      $m1->parameterValue('Sw7', $Sw[7]);
      $m1->parameterValue('Sw8', $Sw[8]);
      $m1->parameterValue('Sw9', $Sw[9]);
      $m1->parameterValue('Sw10', $Sw[10]);
    
      # calculate Sa if it's not given
      if(! defined $Sa) {
        $m1->parameterValue('Sa', $width  
            / ($Sw[1]/($Sa1+$length/2) + $Sw[2]/($Sa2+$length/2)
            + $Sw[3]/($Sa3+$length/2) + $Sw[4]/($Sa4+$length/2)
            + $Sw[5]/($Sa5+$length/2) + $Sw[6]/($Sa6+$length/2)
            + $Sw[7]/($Sa7+$length/2) + $Sw[8]/($Sa8+$length/2)
            + $Sw[9]/($Sa9+$length/2) + $Sw[10]/($Sa10+$length/2)) 
            - $length/2
         );
      }
      # calculate Sb if it's not given
      if(! defined $Sb) {
        $m1->parameterValue('Sb', $width 
            / ($Sw[1]/($Sb1+$length/2) + $Sw[2]/($Sb2+$length/2)
            + $Sw[3]/($Sb3+$length/2) + $Sw[4]/($Sb4+$length/2)
            + $Sw[5]/($Sb5+$length/2) + $Sw[6]/($Sb6+$length/2)
            + $Sw[7]/($Sb7+$length/2) + $Sw[8]/($Sb8+$length/2)
            + $Sw[8]/($Sb9+$length/2) + $Sw[10]/($Sb10+$length/2))
            - $length/2
         );
      }
    }
    #### End LOD Parameters #############
    $CIRCUIT->simulate(eval($simulators));
    my $passFail=mVerifyResults->compareResults("${head}$modelName\_dc\_iv",$testname,$modelName,"dc_iv",$resultHtmlFile,$simulators,$abs_tol,"vd.i1",$id_tol);
    print "$modelName Status: $passFail\n\n";
    mVerifyResults::deleteFiles("${head}$modelName\_dc\_iv",$delFiles,$passFail);
  } else
  {
    foreach $binWidth (@bin_width)
    {
      foreach $binLength (@bin_length)              
      {                
        if ($binLength) {$m1->parameterValue('length', $binLength);}
        if ($binWidth) {$m1->parameterValue('width', $binWidth);}
        $m1->parameterValue('modelName',$modelName);
        #### LOD Parameters #############
        if (defined $Sw10) { $Sw_count=10; }
        elsif (defined $opt_Sw9) { $Sw_count=9; }
        elsif (defined $opt_Sw8) { $Sw_count=8; }
        elsif (defined $opt_Sw7) { $Sw_count=7; }
        elsif (defined $opt_Sw6) { $Sw_count=6; }
        elsif (defined $opt_Sw5) { $Sw_count=5; }
        elsif (defined $opt_Sw4) { $Sw_count=4; }
        elsif (defined $opt_Sw3) { $Sw_count=3; }
        elsif (defined $opt_Sw2) { $Sw_count=2; }
        else { $Sw_count=1; }
        
        $binWidth=&getVal($binWidth);
        $binLength=&getVal($binLength);
        foreach $i (1 .. $Sw_count) { $Sw[$i]=$binWidth/$Sw_count; }
        foreach $i ($Sw_count+1 .. 10) { undef($Sw[$i]); }
      
        $m1->parameterValue('Sw1', $Sw[1]);
        $m1->parameterValue('Sw2', $Sw[2]);
        $m1->parameterValue('Sw3', $Sw[3]);
        $m1->parameterValue('Sw4', $Sw[4]);
        $m1->parameterValue('Sw5', $Sw[5]);
        $m1->parameterValue('Sw6', $Sw[6]);
        $m1->parameterValue('Sw7', $Sw[7]);
        $m1->parameterValue('Sw8', $Sw[8]);
        $m1->parameterValue('Sw9', $Sw[9]);
        $m1->parameterValue('Sw10', $Sw[10]);
      
        # calculate Sa if it's not given
        if(! defined $Sa) {
          $m1->parameterValue('Sa', $binWidth  
              / ($Sw[1]/($Sa1+$binLength/2) + $Sw[2]/($Sa2+$binLength/2)
              + $Sw[3]/($Sa3+$binLength/2) + $Sw[4]/($Sa4+$binLength/2)
              + $Sw[5]/($Sa5+$binLength/2) + $Sw[6]/($Sa6+$binLength/2)
              + $Sw[7]/($Sa7+$binLength/2) + $Sw[8]/($Sa8+$binLength/2)
              + $Sw[9]/($Sa9+$binLength/2) + $Sw[10]/($Sa10+$binLength/2)) 
              - $binLength/2
           );
        }
        # calculate Sb if it's not given
        if(! defined $Sb) {
          $m1->parameterValue('Sb', $binWidth 
              / ($Sw[1]/($Sb1+$binLength/2) + $Sw[2]/($Sb2+$binLength/2)
              + $Sw[3]/($Sb3+$binLength/2) + $Sw[4]/($Sb4+$binLength/2)
              + $Sw[5]/($Sb5+$binLength/2) + $Sw[6]/($Sb6+$binLength/2)
              + $Sw[7]/($Sb7+$binLength/2) + $Sw[8]/($Sb8+$binLength/2)
              + $Sw[8]/($Sb9+$binLength/2) + $Sw[10]/($Sb10+$binLength/2))
              - $binLength/2
           );
        }
        #### End LOD Parameters #############
        `rm -rf ${head}$modelName\_W$binWidth\_L$binLength\_dc\_iv.* 2>/dev/null`;
        $CIRCUIT->circuitName("${head}$modelName\_W$binWidth\_L$binLength\_dc\_iv");
        $CIRCUIT->simulate(eval($simulators));
        my $passFail=mVerifyResults->compareResults("${head}$modelName\_W$binWidth\_L$binLength\_dc\_iv",$testname,$modelName,"dc_iv",$resultHtmlFile,$simulators,$abs_tol,"vd.i1",$id_tol);
        print "$modelName Status: $passFail\n\n";
        mVerifyResults::deleteFiles("${head}$modelName\_dc\_iv",$delFiles,$passFail);
      }
    }
  }
}
