#!/usr/bin/perl 
# Copyright Keysight Technologies 2007 - 2014  
# DC IV test for npn having 3 or more pins.
# This template replaces npn3_dc_iv.pl, npn4_dc_iv.pl, npn3_subckt_dc_iv.pl, 
# and npn4_subckt_dc_iv.pl.
# The mverify script is changed to accomodate for tests created for npn3_subckt_dc_iv
# and npn4_subckt_dc_iv. These tests will invoke this template with the following
# options: 
#           -num_pins=3/4/...
#           -prefix=q/x

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
  print "       -ic_tol []   -abs_tol []\n"; 
  print "       -testname []         -prefix [q/x] \n";
  print "       -model_name []\n"; 
  print "       -allparams []        -adsparams []           -spectreparams []           -hspiceparams []\n";
  print "       -emitter_v []\n";
  print "       -base_bias []        -collector_bias []\n";
  print "                            -vc_pts []   -vc_start []    -vc_stop []    -vc_numpts []\n";
  print "       -sweep_ib [yes/no]   -ib_pts []   -ib_start []    -ib_stop []    -ib_numpts []\n";
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

$ret = GetOptions ("h|help", "delfiles|delfiles:s", "resultfile|resultfile:s", "ic_tol|ic_tol:s", "abs_tol|abs_tol:s", "simulators|simulators:s", "testname|testname:s", "prefix|prefix:s", "model_name|device_name:s", "allparams|allparams:s", "adsparams|adsparams:s", "hspiceparams|hspiceparams:s", "spectreparams|spectreparams:s", "emitter_v|emitter_v:f", "subs_v|subs_v:f", "base_bias|base_bias:f", "collector_bias|collector_bias:f", "vc_pts|vc_pts:s", "vc_start|vc_start:f", "vc_stop|vc_stop:f", "vc_numpts|vc_numpts:i", "sweep_ib|sweep_ib:s", "ib_pts|ib_pts:s", "ib_start|ib_start:f", "ib_stop|ib_stop:f", "ib_numpts|ib_numpts:i", "sweep_l|sweep_l:s", "l_pts|l_pts:s", "l_start|l_start:f", "l_stop|l_stop:f", "l_numpts|l_numpts:i", "sweep_w|sweep_w:s", "w_pts|w_pts:s", "w_start|w_start:f", "w_stop|w_stop:f", "w_numpts|w_numpts:i", "sweep_temp|sweep_temp:s", "temp_pts|temp_pts:s", "num_pins|num_pins:i", "sweep_fingers|sweep_fingers:s", "fingers_pts|fingers_pts:s", "ads_model_lib|ads_model_lib:s", "hspice_model_lib|hspice_model_lib:s", "spectre_model_lib|spectre_model_lib:s","inline|inline:s","reltol|reltol:f","vabstol|vabstol:f","iabstol|iabstol:f","gmin|gmin:f","scale|scale:f","temp|temp:f","tnom|tnom:f","digits|digits:i","ads_scale|ads_scale:f");

$help               = $opt_h;
if ($help) {Usage();exit}

$simulators         = $opt_simulators;
$delFiles           = $opt_delfiles;
$resultHtmlFile     = $opt_resultfile;
$testname           = $opt_testname;
$prefix             = $opt_prefix;
if(!$prefix) {$prefix="q";}

$ic_tol             = $opt_ic_tol;
if(!$ic_tol) {$ic_tol=1.0;}

$abs_tol            = $opt_abs_tol;
if (!$abs_tol) { $abs_tol=1e-20; }

$model_name         = $opt_model_name;

$allparams          = $opt_allparams;
$adsparams          = $opt_adsparams;
$hspiceparams       = $opt_hspiceparams;
$spectreparams      = $opt_spectreparams;

$emitter_v          = $opt_emitter_v;
$subs_v             = $opt_subs_v;
if ($subs_v) {$biases{n4} = $subs_v;}
$base_bias          = $opt_base_bias;
$collector_bias     = $opt_collector_bias;

$vc_pts             = $opt_vc_pts;
if($vc_pts) { $vc_pts = &dKitUtils::sortInAscendingOrder($vc_pts); }
$vc_start           = $opt_vc_start;
$vc_stop            = $opt_vc_stop;
if ($vc_start > $vc_stop)
{
  $tmp = $vc_stop;
  $vc_stop = $vc_start;
  $vc_start = $tmp;
}
$vc_numpts          = $opt_vc_numpts;

$sweep_ib           = $opt_sweep_ib;
$ib_pts             = $opt_ib_pts;
if($ib_pts) { $ib_pts = &dKitUtils::sortInAscendingOrder($ib_pts); }
$ib_start           = $opt_ib_start;
$ib_stop            = $opt_ib_stop;
if ($ib_start > $ib_stop)
{
  $tmp = $ib_stop;
  $ib_stop = $ib_start;
  $ib_start = $tmp;
}
$ib_numpts          = $opt_ib_numpts;

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
if(!$num_pins) {$num_pins=3;}

#$sweep_fingers      = $opt_sweep_fingers;
$fingers_pts        = $opt_fingers_pts;

$ads_model_lib      = $opt_ads_model_lib;
$hspice_model_lib   = $opt_hspice_model_lib;
$spectre_model_lib  = $opt_spectre_model_lib;
$inline             = $opt_inline;
if($inline && lc($inline) eq 'yes') {$inline=1;}

# Model: rfnpn 

# This is a simulation to compare ADS vs. HSPICE using the verification 
# tool. It is a  DC-IV Simulation using a npn BJT device.

# This simulation is intended to find S parameters vs. frequency while sweeping vg.  

if (! $testname) {
  $head = "";
  $CIRCUIT=dKitCircuit->new('npn');
} else {
  $CIRCUIT=dKitCircuit->new($testname);
  $head = $testname . "_";
}

$rf_bjt = dKitTemplate->new(rf_bjt);
$rf_bjt->requiredPrefix($prefix);
$rf_bjt->addNode("n1");
$rf_bjt->addNode("n2");
$rf_bjt->addNode("n3");
my $nodelist="collector base emitter ";
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
  if ( $nodelist !~ /$connections{$nodei} / )
  {
    $rf_bjt->addNode($nodename);
  }
  $nodelist=$nodelist . $nodename . " ";
}
my $modelLabel='model';
$rf_bjt->addParameter('model');
$rf_bjt->addParameter("allParams");
$rf_bjt->addParameter("adsParams");
$rf_bjt->addParameter("hspiceParams");
$rf_bjt->addParameter("spectreParams");

my $adsInstLine = &dKitUtils::setAdsInstanceLineFormat($modelLabel, $adsparams, $spectreparams, $hspiceparams, $nodelist);
$rf_bjt->netlistInstanceTemplate(ads, $adsInstLine);
my $spectreInstLine = &dKitUtils::setSpectreInstanceLineFormat($modelLabel, $spectreparams, $hspiceparams, $nodelist);
$rf_bjt->netlistInstanceTemplate(spectre, $spectreInstLine);
$rf_bjt->netlistInstanceTemplate(hspice, '#instanceName ' . $nodelist . ' <' . $modelLabel . '> [[<allParams>]] [[<hspiceParams>]]');


# Add instances of BJT and three voltage/current sources, vc, ve, and ib.
if (! $model_name) {die "Error: \$model_name must be defined.";}
$model_name=~s/\s//g;
$m1=dKitInstance->new(rf_bjt, ${prefix} . "99");
$m1->parameterValue('model',$model_name);
if ($allparams) {$m1->parameterValue('allParams', $allparams);}

my $adsInstParams = &dKitUtils::adsInstanceParams($adsparams, $spectreparams, $hspiceparams);
if ($adsInstParams) {$m1->parameterValue('adsParams', $adsInstParams);}
my $spectreInstParams = &dKitUtils::spectreInstanceParams($spectreparams, $hspiceparams);
if ($spectreInstParams) {$m1->parameterValue('spectreParams', $spectreInstParams);}
if ($hspiceparams) {$m1->parameterValue('hspiceParams', $hspiceparams);}

$m1->nodeName(n1, 'collector');
$m1->nodeName(n2, 'base');
$m1->nodeName(n3, 'emitter');
for( $nodei=4; $nodei <= $num_pins; $nodei++ )
{
  my $nodename = sprintf("n%d", $nodei);
  if ( $nodelist =~ / $nodename / )
  {
    $m1->nodeName(eval($nodename), $nodename);
  }
}
$CIRCUIT->addInstance($m1);

$ve=dKitInstance->new(V, ve);
$ve->nodeName(nplus, 'emitter');
$ve->nodeName(nminus, 0);
if (! defined $emitter_v) {$emitter_v=0;} 
$ve->parameterValue('Vdc', $emitter_v);
$CIRCUIT->addInstance($ve);

$ib=dKitInstance->new(I, ib);
$ib->nodeName(nplus, 0);
$ib->nodeName(nminus, 'base');
if (! defined $base_bias) {$base_bias=1e-5;} 
$ib->parameterValue(Idc, $base_bias);
$CIRCUIT->addInstance($ib);

$vc=dKitInstance->new(V, vc);
$vc->nodeName(nplus, 'collector');
$vc->nodeName(nminus, 0);
if (! defined $collector_bias) {$collector_bias=3;}
$vc->parameterValue(Vdc, $collector_bias);
$CIRCUIT->addInstance($vc);

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

# Add DC (Ic vs Vce) Analysis Component

# Add Sweep Plans  
if ($vc_pts) {
  $SWEEPPLAN1 = dKitAnalysis->new(SWEEPPLAN_PT, Plan1);
  $SWEEPPLAN1->parameterValue("values", $vc_pts);
} else
{
  if (! defined $vc_start) { $vc_start='0.1';}
  if (! defined $vc_stop) { $vc_stop='5';}
  if (! defined $vc_numpts) { $vc_numpts='51';}
  $SWEEPPLAN1 = dKitAnalysis->new(SWEEPPLAN_LIN, Plan1);
  $SWEEPPLAN1->parameterValue(start, $vc_start);
  $SWEEPPLAN1->parameterValue(stop, $vc_stop);
  $SWEEPPLAN1->parameterValue(numPts, $vc_numpts);
}

$DC1 = dKitAnalysis->new(DC, DC1);
$DC1->parameterValue(device, 'vc');
$DC1->parameterValue(parameter, 'Vdc');
$DC1->addSweepPlan($SWEEPPLAN1);
$sweep_level = 1;

if (($sweep_ib) && ($sweep_ib ne 'no'))
{
  $sweep_level = 2;
#  print "SWEEP_LEVEL = $sweep_level\n";

  if ($ib_pts) {
    $SWEEPPLAN2 = dKitAnalysis->new(SWEEPPLAN_PT, Plan2);
    $SWEEPPLAN2->parameterValue("values", $ib_pts);
  } else
  {
    if (! defined $ib_start) { $ib_start='2.5e-5';}
    if (! defined $ib_stop) { $ib_stop='1e-4';}
    if (! defined $ib_numpts) { $ib_numpts='5';}
    $SWEEPPLAN2 = dKitAnalysis->new(SWEEPPLAN_LIN, Plan2);
    $SWEEPPLAN2->parameterValue(start, $ib_start);
    $SWEEPPLAN2->parameterValue(stop, $ib_stop);
    $SWEEPPLAN2->parameterValue(numPts, $ib_numpts);
  }

  $SWEEP2 = dKitAnalysis->new(SWEEP, Sweep2);
  $SWEEP2->parameterValue(device, 'ib');
  $SWEEP2->parameterValue(parameter, 'Idc');
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
  $SWEEP3->parameterValue(device, 'vg');  
  $SWEEP3->parameterValue(parameter, 'Vdc');
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
  $SWEEP4->parameterValue(device, 'xg');
  $SWEEP4->parameterValue(parameter, 'pbn_vdc');
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
$OUTPUTDOPS->parameterValue(deviceParameters, "vc:i");
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
  `rm -rf ${head}$modelName\_dc\_iv.* 2>/dev/null`;
  $CIRCUIT->circuitName("${head}$modelName\_dc\_iv");
  $m1->parameterValue('model',$modelName);
  $CIRCUIT->simulate(eval($simulators));
  my $passFail=mVerifyResults->compareResults("${head}$modelName\_dc\_iv",$testname,$modelName,"dc_iv",$resultHtmlFile,$simulators,$abs_tol,"vc.i1",$ic_tol);
  print "$modelName Status: $passFail\n\n";
  mVerifyResults::deleteFiles("${head}$modelName\_dc\_iv",$delFiles,$passFail);
}
