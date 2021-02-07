#!/usr/bin/perl 
# Copyright Keysight Technologies 2007 - 2014  
# DC IV test template for nmos with 3 or more pins.
# This template replaces nmos3_subckt_dc_iv.pl and nmos4_subckt_dc_iv.pl.
# The mverify script has been changed to accomodate for tests created for 
# nmos3_subckt_dc_iv and nmos4_subckt_dc_iv. 
# Use the following two options to designate pin number and instance prefix
#       -num_pins=3/4/5/...
#       -prefix=x/m


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
  print "       -testname []         -prefix [q/x] \n"; 
  print "       -model_name []\n"; 
  print "       -allparams []        -adsparams []           -spectreparams []           -hspiceparams []\n";
  print "       -bin_length []  -bin_width []\n";
  print "       -source_v []\n";
  print "       -gate_bias []        -drain_bias []\n";
  print "                            -vd_pts []   -vd_start []    -vd_stop []    -vd_numpts []\n";
  print "       -sweep_vg [yes/no]   -vg_pts []   -vg_start []    -vg_stop []    -vg_numpts []\n";
#  print "       -sweep_l [yes/no]    -l_pts []    -l_start []     -l_stop []     -l_numpts []\n";
#  print "       -sweep_w [yes/no]    -w_pts []    -w_start []     -w_stop []     -w_numpts []\n";
  print "       -sweep_temp [yes/no] -temp_pts []\n";
#  print "       -sweep_fingers [yes/no] -fingers_pts []\n";
  print "       -ads_model_lib []    -hspice_model_lib []    -spectre_model_lib []   -inline [yes/no]\n";
  print "       -num_pins [3/4/...] -n4_bias ...\n";
  print "       -reltol []  -vabstol []    -iabstol []    -gmin []\n";
  print "       -scale []    -temp[]   -tnom[]   -digits []\n";
  print "       -ads_scale []\n";
};


my %biases=();
foreach (@ARGV) {
  if ($_ =~ /-n\d+_bias/) {
    my $ni = $_;
    my $nv = $_;
    $ni =~ s/-n(\d+)_bias.*/$1/;
    $nv =~ s/-n\d+_bias=(.*)/$1/;
    $biases{$ni} = $nv;
    # The line below is just to avoid warning about unknown option 'n?_bias'.
    $_ = '';
  }
}

my %connections=();
for( $nodei=1; $nodei<=16; $nodei++) # will there be more than 16 pins?
{
  $connections{$nodei} = "-999999999";
}
foreach (@ARGV) {
  if ($_ =~ /-n\d+_connection/) {
    my $ni = $_;
    my $nv = $_;
    $ni =~ s/-n(\d+)_connection.*/$1/;
    $nv =~ s/-n\d+_connection=(.*)/$1/;
    $connections{$ni} = $nv;
    # The line below is just to avoid warning about unknown option 'n?_connection'.
    $_ = '';
  }
}

$ret = GetOptions ("h|help", "delfiles|delfiles:s", "simulators|simulators:s", "resultfile|resultfile:s", "id_tol|id_tol:s", "abs_tol|abs_tol:s", "testname|testname:s", "prefix|prefix:s", "model_name|device_name:s", "allparams|allparams:s", "adsparams|adsparams:s", "hspiceparams|hspiceparams:s", "spectreparams|spectreparams:s", "bin_length|bin_length:s", "bin_width|bin_width:s", "source_v|source_v:f", "gate_bias|gate_bias:f", "drain_bias|drain_bias:f", "vd_pts|vd_pts:s", "vd_start|vd_start:f", "vd_stop|vd_stop:f", "vd_numpts|vd_numpts:i", "sweep_vg|sweep_vg:s", "vg_pts|vg_pts:s", "vg_start|vg_start:f", "vg_stop|vg_stop:f", "vg_numpts|vg_numpts:i", "sweep_l|sweep_l:s", "l_pts|l_pts:s", "l_start|l_start:f", "l_stop|l_stop:f", "l_numpts|l_numpts:i", "sweep_w|sweep_w:s", "w_pts|w_pts:s", "w_start|w_start:f", "w_stop|w_stop:f", "w_numpts|w_numpts:i", "sweep_temp|sweep_temp:s", "temp_pts|temp_pts:s", "num_pins|num_pins:i", "sweep_fingers|sweep_fingers:s", "fingers_pts|fingers_pts:s", "ads_model_lib|ads_model_lib:s", "hspice_model_lib|hspice_model_lib:s", "spectre_model_lib|spectre_model_lib:s","inline|inline:s","reltol|reltol:f","vabstol|vabstol:f","iabstol|iabstol:f","gmin|gmin:f","scale|scale:f","temp|temp:f","tnom|tnom:f","digits|digits:i","ads_scale|ads_scale:f");

$help               = $opt_h;
if ($help) {Usage();exit}

$simulators         = $opt_simulators;
$testname           = $opt_testname;
$prefix             = $opt_prefix;
if(!$prefix) {$prefix="m";}
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

$source_v           = $opt_source_v;
$gate_bias          = $opt_gate_bias;
$drain_bias         = $opt_drain_bias;

$vd_pts             = $opt_vd_pts;
if($vd_pts) { $vd_pts = &dKitUtils::sortInAscendingOrder($vd_pts); }
$vd_start           = $opt_vd_start;
$vd_stop            = $opt_vd_stop;
if ($vd_start > $vd_stop)
{
  $tmp = $vd_stop;
  $vd_stop = $vd_start;
  $vd_start = $tmp;
}
$vd_numpts          = $opt_vd_numpts;

$sweep_vg           = $opt_sweep_vg;
$vg_pts             = $opt_vg_pts;
if($vg_pts) { $vg_pts = &dKitUtils::sortInAscendingOrder($vg_pts); }
$vg_start           = $opt_vg_start;
$vg_stop            = $opt_vg_stop;
if ($vg_start > $vg_stop)
{
  $tmp = $vg_stop;
  $vg_stop = $vg_start;
  $vg_start = $tmp;
}
$vg_numpts          = $opt_vg_numpts;

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
if($temp_pts) { $temp_pts = &dKitUtils::sortInAscendingOrder($temp_pts); }

$num_pins           = $opt_num_pins;
if(!$num_pins) {$num_pins=4;}

#$sweep_fingers      = $opt_sweep_fingers;
$fingers_pts        = $opt_fingers_pts;

$ads_model_lib      = $opt_ads_model_lib;

$hspice_model_lib   = $opt_hspice_model_lib;
$spectre_model_lib  = $opt_spectre_model_lib;
$inline             = $opt_inline;
if($inline && lc($inline) eq 'yes') {$inline=1;}

# Model: nmos_rf 

# This is for comparing drain current in DC IV simulation results of a 
# FET device. It allows comparisions between ADS and HSPICE, ADS and Spectre, 
# or HSPICE and Spectre.

if (! $testname) {
  $head = "";
  $CIRCUIT=dKitCircuit->new('nmos');
} else {
  $CIRCUIT=dKitCircuit->new($testname);
  $head = $testname . "_";
}

$rf_fet = dKitTemplate->new(rf_fet);
$rf_fet->requiredPrefix($prefix);
$rf_fet->addNode("n1");
$rf_fet->addNode("n2");
$rf_fet->addNode("n3");
my $nodelist="drain gate source ";
for( $nodei=4; $nodei <= $num_pins; $nodei++ )
{
  my $nodename;
  if ($connections{$nodei} != "-999999999")
  {
    $nodename = sprintf("%s", $connections{$nodei}); 
  }
  else 
  {
    $nodename = sprintf("n%d", $nodei); 
  }
  if ( index($nodelist, $nodename . " ") < 0 )
  {
    $rf_fet->addNode($nodename);
  }
  $nodelist=$nodelist . $nodename . " ";
}
my $modelLabel='model';
$rf_fet->addParameter('model');
$rf_fet->addParameter("allParams");
$rf_fet->addParameter("adsParams");
$rf_fet->addParameter("hspiceParams");
$rf_fet->addParameter("spectreParams");

my $adsInstLine = &dKitUtils::setAdsInstanceLineFormat($modelLabel, $adsparams, $spectreparams, $hspiceparams, $nodelist);
$rf_fet->netlistInstanceTemplate(ads, $adsInstLine);
my $spectreInstLine = &dKitUtils::setSpectreInstanceLineFormat($modelLabel, $spectreparams, $hspiceparams, $nodelist);
$rf_fet->netlistInstanceTemplate(spectre, $spectreInstLine);
$rf_fet->netlistInstanceTemplate(hspice, '#instanceName ' . $nodelist . ' <'. $modelLabel . '> [[<allParams>]] [[<hspiceParams>]]');


# Add instances of FET and voltage sources, vd, vs, vg, ...
if (! $model_name) {die "Error: \$model_name must be defined.";}
$model_name=~s/\s//g;
$m1=dKitInstance->new(rf_fet, ${prefix} . "99");
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
for( $nodei=4; $nodei <= $num_pins; $nodei++ )
{
  my $nodename = sprintf("n%d", $nodei);
  if ( $nodelist =~ / $nodename / )
  {
    $m1->nodeName(eval($nodename), $nodename);
  }
}
$CIRCUIT->addInstance($m1);

$vs=dKitInstance->new(V, vs);
$vs->nodeName(nplus, 'source');
$vs->nodeName(nminus, 0);
if (! defined $source_v) {$source_v=0;} 
$vs->parameterValue('Vdc', $source_v);
$CIRCUIT->addInstance($vs);

$vg=dKitInstance->new(V, vg);
$vg->nodeName(nplus, 'gate');
$vg->nodeName(nminus, 0);
if (! defined $gate_bias) {$gate_bias=0.9;} 
$vg->parameterValue(Vdc, $gate_bias);
$CIRCUIT->addInstance($vg);

$vd=dKitInstance->new(V, vd);
$vd->nodeName(nplus, 'drain');
$vd->nodeName(nminus, 0);
if (! defined $drain_bias) {$drain_bias=0.5;}
$vd->parameterValue(Vdc, $drain_bias);
$CIRCUIT->addInstance($vd);

my @varray=();
for( $nodei=4; $nodei <= $num_pins; $nodei++ )
{
  my $nodename = sprintf("n%d", $nodei);
  if ( $nodelist =~ / $nodename / )
  {
    my $vname = sprintf("v%d", $nodei);
    my $bias = 0;
    $varray[$nodei]=dKitInstance->new(V, $vname);
    $varray[$nodei]->nodeName(nplus, $nodename);
    $varray[$nodei]->nodeName(nminus, 0);
    if ($biases{$nodei}) {$bias=$biases{$nodei};}
    $varray[$nodei]->parameterValue(Vdc, $bias);
    $CIRCUIT->addInstance($varray[$nodei]);
  }
}

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

#print "FINALSWEEP LEVEL= $sweep_level\n";

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

@model_name = split /\s*,\s*/, $model_name;
foreach $modelName (@model_name) 
{
  my $baseSpectrePrms=$m1->parameterValue('spectreParams');
  my $baseAdsPrms=$m1->parameterValue('adsParams');
  my $baseHspicePrms=$m1->parameterValue('hspiceParams');

  if ($bin_length && $bin_width)
  {
    @bin_length = split /\s*,\s*/, $bin_length;
    @bin_width = split /\s*,\s*/, $bin_width;
    my $filename = "";
    my $longname = 0;
    if ($#bin_length == 0 && $#bin_width == 0)
      { $filename = "${head}${modelName}_dc_iv"; }
    else
      { $longname = 1; }
  
    foreach $binWidth (@bin_width)
    {
      foreach $binLength (@bin_length)
      {
        $m1->parameterValue('spectreParams', "l=${binLength} w=${binWidth} ${baseSpectrePrms}");
        if ($prefix =~ /m/i) {
          $m1->parameterValue('adsParams', "Length=${binLength} Width=${binWidth} ${baseAdsPrms}");
        } else {  # if the ads subckt does not use l and w, then it will fail!
          $m1->parameterValue('adsParams', "l=${binLength} w=${binWidth} ${baseAdsPrms}");
        }
        $m1->parameterValue('hspiceParams', "l=${binLength} w=${binWidth} ${baseHspicePrms}");
  
        if ($longname)
        {
          $filename="${head}${modelName}_W${binWidth}_L${binLength}_dc_iv";
        }
        $m1->parameterValue('model',$modelName);
        `rm -rf ${filename}.* 2>/dev/null`;
        $CIRCUIT->circuitName($filename);
        $CIRCUIT->simulate(eval($simulators));
        my $passFail=mVerifyResults->compareResults("$filename",$testname,$modelName,"dc_iv",$resultHtmlFile,$simulators,$abs_tol,"vd.i1",$id_tol);
        print "$modelName Status: $passFail\n\n";
        mVerifyResults::deleteFiles("$filename",$delFiles,$passFail);
      }
    }
  }
  else
  {
    $m1->parameterValue('model',$modelName);
    my $filename="${head}${modelName}_dc_iv";
    `rm -rf ${filename}.* 2>/dev/null`;
    $CIRCUIT->circuitName("$filename");
    $CIRCUIT->simulate(eval($simulators));
    my $passFail=mVerifyResults->compareResults("$filename",$testname,$modelName,"dc_iv",$resultHtmlFile,$simulators,$abs_tol,"vd.i1",$id_tol);
    print "$modelName Status: $passFail\n\n";
    mVerifyResults::deleteFiles("$filename",$delFiles,$passFail);
  }
}
