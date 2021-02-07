#!/usr/bin/perl 
# Copyright Keysight Technologies 2007 - 2014  
# DC IV test for diodes having 2 or more pins.
# This template replaces diode2_dc_iv.pl, diode2_subckt_dc_iv.pl, diode3_subckt_dc_iv.pl 
# and diode4_subckt_dc_iv.pl
# The mverify script is changed to accomodate for tests created for diode2_dc_iv.pl, 
# diode2_subckt_dc_iv, diode3_subckt_dc_iv, and diode4_subckt_dc_iv. These tests will 
# invoke this template with the following options: 
#       -num_pins=2/3/4/...
#       -prefix=d/x

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
  print "       -i_tol []   -abs_tol []\n";
  print "       -testname []         -prefix [r/l/c/.../x] \n"; 
  print "       -model_name []\n"; 
  print "       -allparams []        -adsparams []           -spectreparams []           -hspiceparams []\n";
  print "       -plus_bias []  \n";
  print "       -plus_pts []         -plus_start []          -plus_stop []               -plus_numpts []\n";
  print "       -sweep_temp [yes/no] -temp_pts []\n";
  print "       -ads_model_lib []    -hspice_model_lib []    -spectre_model_lib []   -inline [yes/no]\n";
  print "       -num_pins [2/3/4/...]    -n2_load    -n3_bias ...\n";
  print "       -reltol []  -vabstol []    -iabstol []    -gmin []\n";
  print "       -scale []    -temp[]   -tnom[]   -digits []\n";
  print "       -ads_scale []\n";
};

my %biases=();
my %loads=();
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
  elsif ($_ =~ /-n\d+_load/) {
    my $ni = $_;
    my $nv = $_;
    $ni =~ s/-n(\d+)_load.*/$1/;
    $nv =~ s/-n\d+_load=(.*)/$1/;
    $loads{$ni} = $nv;
    # The line below is just to avoid warning about unknown option 'n?_load'.
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

$ret = GetOptions ("h|help", "delfiles|delfiles:s", "simulators|simulators:s", "resultfile|resultfile:s", "i_tol|i_tol:s", "abs_tol|abs_tol:s", "testname|testname:s", "prefix|prefix:s", "model_name|device_name:s", "allparams|allparams:s", "adsparams|adsparams:s", "hspiceparams|hspiceparams:s", "spectreparams|spectreparams:s", "plus_bias|plus_bias:f", "n2_load|n2_load:f", "plus_pts|plus_pts:s", "plus_start|plus_start:f", "plus_stop|plus_stop:f", "plus_numpts|plus_numpts:i", "sweep_temp|sweep_temp:s", "temp_pts|temp_pts:s", "num_pins|num_pins:i", "ads_model_lib|ads_model_lib:s", "hspice_model_lib|hspice_model_lib:s", "spectre_model_lib|spectre_model_lib:s","inline|inline:s","reltol|reltol:f","vabstol|vabstol:f","iabstol|iabstol:f","gmin|gmin:f","scale|scale:f","temp|temp:f","tnom|tnom:f","digits|digits:i","ads_scale|ads_scale:f");

$help               = $opt_h;
if ($help) {Usage();exit}

$simulators         = $opt_simulators;
$testname           = $opt_testname;
$prefix             = $opt_prefix;
if(!$prefix) {$prefix="d";}
$model_name         = $opt_model_name;
$delFiles           = $opt_delfiles;
$resultHtmlFile     = $opt_resultfile;

$i_tol              = $opt_i_tol;
if(!$i_tol) {$i_tol=1.0;}
$abs_tol            = $opt_abs_tol;
if (!$abs_tol) { $abs_tol=1e-20; }

$allparams          = $opt_allparams;
$adsparams          = $opt_adsparams;
$hspiceparams       = $opt_hspiceparams;
$spectreparams      = $opt_spectreparams;

$plus_bias          = $opt_plus_bias;
$n2_load            = $opt_n2_load;

$plus_pts           = $opt_plus_pts;
$plus_start         = $opt_plus_start;
$plus_stop          = $opt_plus_stop;
$plus_numpts        = $opt_plus_numpts;

$sweep_temp         = $opt_sweep_temp;
$temp_pts           = $opt_temp_pts;

$num_pins           = $opt_num_pins;
if(!$num_pins) {$num_pins=2;}

$ads_model_lib      = $opt_ads_model_lib;
$hspice_model_lib   = $opt_hspice_model_lib;
$spectre_model_lib  = $opt_spectre_model_lib;
$inline             = $opt_inline;
if($inline && lc($inline) eq 'yes') {$inline=1;}

# Model: diode 

# This is a simulation to compare ADS vs. HSPICE using the verification 
# tool. It is an S-Parameter Simulation using a diode subcircuit.

# This simulation is intended to find S parameters vs. frequency while sweeping vp.  

if (! $testname) {
  $head = "";
  $CIRCUIT=dKitCircuit->new('rf_diode');
} else {
  $CIRCUIT=dKitCircuit->new($testname);
  $head = $testname . "_";
}

# Add an optional load
my $nodei = 2;
my $nodename = sprintf("n%d", $nodei);
if ($loads{$nodei}) {
   # if n2_load is given, then add 'rload_2 n2 0 R=value(n2_load)'
   my $rname = sprintf("rload_%d", $nodei);
   my $res = $loads{$nodei};
   $other_pins[$nodei]=dKitInstance->new(R, $rname);
   $other_pins[$nodei]->nodeName(n1, $nodename);
   $other_pins[$nodei]->nodeName(n2, 0);
   $other_pins[$nodei]->parameterValue(resistance, $res);
   $CIRCUIT->addInstance($other_pins[$nodei]);
}

$diode = dKitTemplate->new(rf_diode);
$diode->addNode("n1");
$diode->addNode("n2");
my $nodelist="";
if ($loads{$nodei}) {
   $nodelist="plus n2 ";
} else {
   $nodelist="plus 0 ";
}

for( $nodei=3; $nodei <= $num_pins; $nodei++ )
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
    $diode->addNode($nodename);
  }
  $nodelist=$nodelist . $nodename . " ";
}
my $modelLabel='model';
$diode->addParameter('model');
$diode->addParameter("allParams");
$diode->addParameter("adsParams");
$diode->addParameter("hspiceParams");
$diode->addParameter("spectreParams");

my $adsInstLine = &dKitUtils::setAdsInstanceLineFormat($modelLabel, $adsparams, $spectreparams, $hspiceparams, $nodelist);
$diode->netlistInstanceTemplate(ads, $adsInstLine);
my $spectreInstLine = &dKitUtils::setSpectreInstanceLineFormat($modelLabel, $spectreparams, $hspiceparams, $nodelist);
$diode->netlistInstanceTemplate(spectre, $spectreInstLine);
$diode->netlistInstanceTemplate(hspice, '#instanceName ' . $nodelist . ' <' . $modelLabel . '> [[<allParams>]] [[<hspiceParams>]]');

# Add instances of DIODE and voltage source vp.
if (! $model_name) {die "Error: \$model_name must be defined.";}
$model_name=~s/\s//g;
$diode->requiredPrefix($prefix);
$m1=dKitInstance->new(rf_diode, ${prefix} . "99");

$m1->parameterValue('model',$model_name);
if ($allparams) {$m1->parameterValue('allParams', $allparams);}

my $adsInstParams = &dKitUtils::adsInstanceParams($adsparams, $spectreparams, $hspiceparams);
if ($adsInstParams) {$m1->parameterValue('adsParams', $adsInstParams);}
my $spectreInstParams = &dKitUtils::spectreInstanceParams($spectreparams, $hspiceparams);
if ($spectreInstParams) {$m1->parameterValue('spectreParams', $spectreInstParams);}
if ($hspiceparams) {$m1->parameterValue('hspiceParams', $hspiceparams);}

if ($loads{$nodei}) {
   $m1->nodeName(n2, $nodename);
} else {
   $m1->nodeName(n2, 0);
}

for( $nodei=3; $nodei <= $num_pins; $nodei++ )
{
  my $nodename = sprintf("n%d", $nodei);
  if ( $nodelist =~ / $nodename / )
  {
    $m1->nodeName(eval($nodename), $nodename);
  }
}
$CIRCUIT->addInstance($m1);

$vp=dKitInstance->new(V, vp);
$vp->nodeName(nplus, 'plus');
$vp->nodeName(nminus, 0);
if (! defined $plus_bias) {$plus_bias=1;} 
$vp->parameterValue(Vdc, $plus_bias);
$CIRCUIT->addInstance($vp);

my @varray=();
for( $nodei=3; $nodei <= $num_pins; $nodei++ )
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

# Add DC IV Analysis Component

# Add Sweep Plans  
if ($plus_pts) {
  $SWEEPPLAN1 = dKitAnalysis->new(SWEEPPLAN_PT, Plan1);
  $SWEEPPLAN1->parameterValue("values", $plus_pts);
} else
{
  if (! defined $plus_start) { $plus_start='0.1';}
  if (! defined $plus_stop) { $plus_stop='2';}
  if (! defined $plus_numpts) { $plus_numpts='101';}
  if ( $plus_start > $plus_stop) { my $plus_tmp=$plus_stop; $plus_stop=$plus_start; $plus_start=$plus_tmp; }
  $SWEEPPLAN1 = dKitAnalysis->new(SWEEPPLAN_LIN, Plan1);
  $SWEEPPLAN1->parameterValue(start, $plus_start);
  $SWEEPPLAN1->parameterValue(stop, $plus_stop);
  $SWEEPPLAN1->parameterValue(numPts, $plus_numpts);
}

$DC1 = dKitAnalysis->new(DC, DC1);
$DC1->parameterValue(device, 'vp');
$DC1->parameterValue(parameter, Vdc);
$DC1->addSweepPlan($SWEEPPLAN1);

if (($sweep_temp) && ($sweep_temp ne 'no'))
{
  $SWEEPPLAN2 = dKitAnalysis->new(SWEEPPLAN_PT, Plan2);
    if (! defined $temp_pts) { $temp_pts='-40 25 125';  print "\$temp_pts not defined.  \$temp_pts set to \"$temp_pts\"\n";}
  $SWEEPPLAN2->parameterValue("values", $temp_pts);

  $SWEEP2 = dKitAnalysis->new(SWEEP, Sweep2);
  $SWEEP2->parameterValue(parameter, 'temp');
  $SWEEP2->addSweepPlan($SWEEPPLAN2);
  $SWEEP2->addSubAnalysis($DC1);
  $CIRCUIT->addAnalysis($SWEEP2);
}
else
{ 
  $CIRCUIT->addAnalysis($DC1);
}

# Output Plans

$OUTPUTDOPS=dKitAnalysis->new(OUTPUTPLAN_DOPS, "out1");
$OUTPUTDOPS->parameterValue(deviceParameters, "vp:i");
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
  my $passFail=mVerifyResults->compareResults("${head}$modelName\_dc\_iv",$testname,$modelName,"dc_iv",$resultHtmlFile,$simulators,$abs_tol,"vp.i1",$i_tol);
  print "$modelName Status: $passFail\n\n";
  mVerifyResults::deleteFiles("${head}$modelName\_dc\_iv",$delFiles,$passFail);
}
