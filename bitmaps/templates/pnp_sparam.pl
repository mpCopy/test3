#!/usr/bin/perl 
# Copyright Keysight Technologies 2007 - 2014  
# S-parameter test for pnp having 3 or more pins.
# This template replaces pnp3_sparam.pl, pnp4_sparam.pl, pnp_subckt_sparam.pl.
# The mverify script is changed to accomodate for tests created for these 
# legacy templates. These tests will invoke this template with the following
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
  print "       -s11_tol []          -s21_tol []      -s22_tol []       -s12_tol []   -abs_tol []\n";
  print "       -testname []         -prefix [q/x] \n"; 
  print "       -model_name []\n"; 
  print "       -allparams []        -adsparams []           -spectreparams []           -hspiceparams []\n";
  print "       -emitter_v []\n";
  print "       -base_refz []        -collector_refz []\n";
  print "       -base_bias []        -collector_bias []\n";
  print "                            -freq_pts []   -freq_start []    -freq_stop []    -freq_numpts []\n";
  print "       -sweep_vb [yes/no]   -vb_pts []     -vb_start []      -vb_stop []      -vb_numpts []\n";
  print "       -sweep_temp [yes/no] -temp_pts []\n";
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

$ret = GetOptions ("h|help", "delfiles|delfiles:s", "simulators|simulators:s", "resultfile|resultfile:s", "s11_tol|s11_tol:s", "s21_tol|s21_tol:s", "s22_tol|s22_tol:s", "s12_tol|s12_tol:s", "abs_tol|abs_tol:s", "testname|testname:s", "prefix|prefix:s", "model_name|device_name:s", "allparams|allparams:s", "adsparams|adsparams:s", "hspiceparams|hspiceparams:s", "spectreparams|spectreparams:s", "emitter_v|emitter_v:f", "base_refz|base_refz:f", "collector_refz|collector_refz:f", "base_bias|base_bias:f", "collector_bias|collector_bias:f", "subs_v|subs_v:f", "freq_pts|freq_pts:s", "freq_start|freq_start:f", "freq_stop|freq_stop:f", "freq_numpts|freq_numpts:i", "sweep_vb|sweep_vb:s", "vb_pts|vb_pts:s", "vb_start|vb_start:f", "vb_stop|vb_stop:f", "vb_numpts|vb_numpts:i", "sweep_temp|sweep_temp:s", "temp_pts|temp_pts:s", "num_pins|num_pins:i", "ads_model_lib|ads_model_lib:s", "hspice_model_lib|hspice_model_lib:s", "spectre_model_lib|spectre_model_lib:s","inline|inline:s","reltol|reltol:f","vabstol|vabstol:f","iabstol|iabstol:f","gmin|gmin:f","scale|scale:f","temp|temp:f","tnom|tnom:f","digits|digits:i","ads_scale|ads_scale:f");

$help               = $opt_h;
if ($help) {Usage();exit}

$simulators         = $opt_simulators;
$testname           = $opt_testname;
$prefix             = $opt_prefix;
if(!$prefix) {$prefix="q";}
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

$emitter_v          = $opt_emitter_v;
$base_refz          = $opt_base_refz;
$collector_refz     = $opt_collector_refz;
$base_bias          = $opt_base_bias;
$collector_bias     = $opt_collector_bias;
$subs_v             = $opt_subs_v;
if ($subs_v) {$biases{n4} = $subs_v;}

$freq_pts           = $opt_freq_pts;
$freq_start         = $opt_freq_start;
$freq_stop          = $opt_freq_stop;
$freq_numpts        = $opt_freq_numpts;

$sweep_vb           = $opt_sweep_vb;
$vb_pts             = $opt_vb_pts;
$vb_start           = $opt_vb_start;
$vb_stop            = $opt_vb_stop;
$vb_numpts          = $opt_vb_numpts;

$sweep_temp         = $opt_sweep_temp;
$temp_pts           = $opt_temp_pts;

$num_pins           = $opt_num_pins;
if(!$num_pins) {$num_pins=3;}

$ads_model_lib      = $opt_ads_model_lib;
$hspice_model_lib   = $opt_hspice_model_lib;
$spectre_model_lib  = $opt_spectre_model_lib;
$inline             = $opt_inline;
if($inline && lc($inline) eq 'yes') {$inline=1;}

# Model: rfpnp 

# This is a simulation to compare ADS vs. HSPICE using the verification 
# tool. It is an S-Parameter Simulation using a pnp BJT subcircuit.

# This simulation is intended to find S parameters vs. frequency while sweeping vb.  

if (! $testname) {
  $head = "";
  $CIRCUIT=dKitCircuit->new('pnp');
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
  $nodelist=$nodelist . $nodename . " ";
  if ( $nodelist !~ /$connections{$nodei} / )
  {
    $rf_bjt->addNode($nodename);
  }
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


# Add instances of BJT and three voltage sources, vc, ve, and vb.
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
$ve->nodeName(nminus, 'emitter');
$ve->nodeName(nplus, 0);
if (! defined $emitter_v) {$emitter_v=0;}
$ve->parameterValue('Vdc', $emitter_v);
$CIRCUIT->addInstance($ve);

$vb=dKitInstance->new(PORT_BN, xb);
$vb->nodeName(nminus, 0);
$vb->nodeName(nplus, 'base');
if (! defined $base_bias) {$base_bias=-0.7;} 
$vb->parameterValue(pbn_vdc, $base_bias);
$vb->parameterValue(pbn_portnr, 1);
if (! defined $base_refz) {$base_refz=50;}
$vb->parameterValue(pbn_referenceimpedance, $base_refz);
$vb->parameterValue(pbn_inductance, 1);
$vb->parameterValue(pbn_capacitance, 1);
$CIRCUIT->addInstance($vb);

$vc=dKitInstance->new(PORT_BN, xc);
$vc->nodeName(nminus, 'collector');
$vc->nodeName(nplus, 0);
if (! defined $collector_bias) {$collector_bias=-2.0;}
$vc->parameterValue(pbn_vdc, $collector_bias);
$vc->parameterValue(pbn_portnr, 2);
if (! defined $collector_refz) {$collector_refz=50;}
$vc->parameterValue(pbn_referenceimpedance, $collector_refz);
$vc->parameterValue(pbn_inductance, 1);
$vc->parameterValue(pbn_capacitance, 1);
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

# Add S-Parameter Analysis Component

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
$sweep_level = 1;

if (($sweep_vb) && ($sweep_vb ne 'no'))
{
  $sweep_level = 2;
#  print "SWEEP_LEVEL = $sweep_level\n";

  if ($vb_pts) {
    $SWEEPPLAN2 = dKitAnalysis->new(SWEEPPLAN_PT, Plan2);
    $SWEEPPLAN2->parameterValue("values", $vb_pts);
  } else
  {
    if (! defined $vb_start) { $vb_start='-0.9';}
    if (! defined $vb_stop) { $vb_stop='-0.5';}
    if (! defined $vb_numpts) { $vb_numpts='5';}
    $SWEEPPLAN2 = dKitAnalysis->new(SWEEPPLAN_LIN, Plan2);
    $SWEEPPLAN2->parameterValue(start, $vb_start);
    $SWEEPPLAN2->parameterValue(stop, $vb_stop);
    $SWEEPPLAN2->parameterValue(numPts, $vb_numpts);
  }

  $SWEEP2 = dKitAnalysis->new(SWEEP, Sweep2);
  $SWEEP2->parameterValue(device, 'xb');
  $SWEEP2->parameterValue(parameter, 'pbn_vdc');
  $SWEEP2->addSweepPlan($SWEEPPLAN2);
  $SWEEP2->addSubAnalysis($SP1);
}

if (($sweep_temp) && ($sweep_temp ne 'no'))
{
  $sweep_level = 3;
#  print "SWEEP_LEVEL = $sweep_level\n";

  $SWEEPPLAN3 = dKitAnalysis->new(SWEEPPLAN_PT, Plan3);
    if (! defined $temp_pts) { $temp_pts='-40 25 125';  print "\$temp_pts not defined.  \$temp_pts set to \"$temp_pts\"\n";}
  $SWEEPPLAN3->parameterValue("values", $temp_pts);

  $SWEEP3 = dKitAnalysis->new(SWEEP, Sweep3);
  $SWEEP3->parameterValue(parameter, 'temp');
  $SWEEP3->addSweepPlan($SWEEPPLAN3);
   if    ($SWEEP2)  {$SWEEP3->addSubAnalysis($SWEEP2);}
   else             {$SWEEP3->addSubAnalysis($SP1);}
}

if    ($sweep_level == 1) {$CIRCUIT->addAnalysis($SP1);}
elsif ($sweep_level == 2) {$CIRCUIT->addAnalysis($SWEEP2);}
else                      {$CIRCUIT->addAnalysis($SWEEP3);}


# Output Plans

$OUTPUTDOPS=dKitAnalysis->new(OUTPUTPLAN_DOPS, "out1");
$OUTPUTDOPS->parameterValue(deviceParameters, "vc:i");
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
