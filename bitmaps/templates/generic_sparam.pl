#!/usr/bin/perl 
# Copyright Keysight Technologies 2007 - 2014  
# S-Parameter test for any device with 1 or more pins. 
# This template replaces 
#          res2_sparam.pl 
#          res2_subckt_sparam.pl 
#          res3_subckt_sparam.pl 
#          ind2_sparam.pl 
#          ind2_subckt_sparam.pl 
#          ind3_subckt_sparam.pl 
#          ind4_subckt_sparam.pl
#          cap2_sparam.pl 
#          cap2_subckt_sparam.pl 
#          cap3_subckt_sparam.pl 
#          esd1_subckt_sparam.pl 
#          generic_subckt_sparam.pl 
# The mverify script is changed to accomodate for tests created for the above
# templates. These tests will invoke this template with the following additional
# options:
#          -num_pins=1/2/3/4
#          -prefix=r/l/c/x

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
  print "       -testname []         -prefix [r/l/c/.../x] \n"; 
  print "       -model_name []\n"; 
  print "       -allparams []        -adsparams []           -spectreparams []           -hspiceparams []\n";
  print "       -p1_refz []          -p2_refz []\n";
  print "       -freq_pts []         -freq_start []          -freq_stop []               -freq_numpts []\n";
  print "       -sweep_temp [yes/no] -temp_pts []\n";
  print "       -num_pins [1/2/3/...]  -p1_conn [n1/n2/...]  p2_conn [] \n";
  print "       -p1_bias []  -p2_bias []  -n3_bias  -n4_load ... \n";
  print "       -ads_model_lib []    -hspice_model_lib []    -spectre_model_lib []   -inline [yes/no]\n";
  print "       -reltol []  -vabstol []    -iabstol []    -gmin []\n";
  print "       -scale []    -temp[]   -tnom[]   -digits []\n";
  print "       -ads_scale []\n";
  print "NOTE: Calling the following templates via mverify will invoke this template with \n";
  print " appropriate -num_pins and -prefix options:                                      \n";
  print "          res2_sparam \n";
  print "          res2_subckt_sparam \n";
  print "          res3_subckt_sparam \n";
  print "          ind2_sparam \n";
  print "          ind2_subckt_sparam \n";
  print "          ind3_subckt_sparam \n";
  print "          ind4_subckt_sparam \n";
  print "          cap2_sparam \n";
  print "          cap2_subckt_sparam \n";
  print "          cap3_subckt_sparam \n";
  print "          esd1_subckt_sparam \n";
  print "          generic_subckt_sparam \n";
};

my %biases=();
my %loads=();
foreach (@ARGV) {
  if ($_ =~ /-n\d+_load/) {
    my $ni = $_;
    my $nv = $_;
    $ni =~ s/-n(\d+)_load.*/$1/;
    $nv =~ s/-n\d+_load=(.*)/$1/;
    $loads{$ni} = $nv;
    # The line below is just to avoid warning about unknown option 'n?_load'.
    $_ = '';
  }
  elsif ($_ =~ /-n\d+_bias/) {
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

$ret = GetOptions ("h|help", "delfiles|delfiles:s", "simulators|simulators:s", "resultfile|resultfile:s", "s11_tol|s11_tol:s", "s21_tol|s21_tol:s", "s22_tol|s22_tol:s", "s12_tol|s12_tol:s", "abs_tol|abs_tol:s", "testname|testname:s", "prefix|prefix:s", "model_name|device_name:s", "allparams|allparams:s", "adsparams|adsparams:s", "hspiceparams|hspiceparams:s", "spectreparams|spectreparams:s", "p1_refz|p1_refz:f", "p2_refz|p2_refz:f", "freq_pts|freq_pts:s", "freq_start|freq_start:f", "freq_stop|freq_stop:f", "freq_numpts|freq_numpts:i", "sweep_temp|sweep_temp:s", "temp_pts|temp_pts:s",  "num_pins|num_pins:i", "p1_conn|p1_conn:s", "p2_conn|p2_conn:s", "p1_bias|p1_bias:f", "p2_bias|p2_bias:f", "ads_model_lib|ads_model_lib:s", "hspice_model_lib|hspice_model_lib:s", "spectre_model_lib|spectre_model_lib:s","inline|inline:s","reltol|reltol:f","vabstol|vabstol:f","iabstol|iabstol:f","gmin|gmin:f","scale|scale:f","temp|temp:f","tnom|tnom:f","digits|digits:i","ads_scale|ads_scale:f");

$help               = $opt_h;
if ($help) {Usage();exit}

$simulators         = $opt_simulators;
$testname           = $opt_testname;
$prefix             = $opt_prefix;
if(!$prefix) {$prefix="x";}
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

$p1_refz            = $opt_p1_refz;
$p2_refz            = $opt_p2_refz;

$freq_pts           = $opt_freq_pts;
$freq_start         = $opt_freq_start;
$freq_stop          = $opt_freq_stop;
$freq_numpts        = $opt_freq_numpts;

$sweep_temp         = $opt_sweep_temp;
$temp_pts           = $opt_temp_pts;

$num_pins           = $opt_num_pins;
if(!$num_pins) {$num_pins=2;}

$p1_conn            = $opt_p1_conn;
if(!$p1_conn) {$p1_conn="n1";}
$p2_conn            = $opt_p2_conn;
if(!$p2_conn) {$p2_conn="n2";}

$p1_bias            = $opt_p1_bias;
if (! defined $p1_bias) {$p1_bias=0;}
$p2_bias            = $opt_p2_bias;
if (! defined $p2_bias) {$p2_bias=0;}

$ads_model_lib      = $opt_ads_model_lib;

$hspice_model_lib   = $opt_hspice_model_lib;
$spectre_model_lib  = $opt_spectre_model_lib;
$inline             = $opt_inline;
if($inline && lc($inline) eq 'yes') {$inline=1;}

# This is a simulation to compare ADS vs. spectre using the verification 
# tool. It is a 1 or 2-port S-Parameter Simulation for the device under test.

# This simulation is intended to find S parameters vs. frequency.  

if (! $testname) {
  $head = "";
  $CIRCUIT=dKitCircuit->new('test1');
} else {
  $CIRCUIT=dKitCircuit->new($testname);
  $head = $testname . "_";
}

$dut = dKitTemplate->new(rf_dut);
$dut->requiredPrefix($prefix);
$dut->addNode("n1");
my $nodelist="n1 ";
for( $nodei=2; $nodei <= $num_pins; $nodei++ )
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
    $dut->addNode($nodename);
  }
  $nodelist=$nodelist . $nodename . " ";
}
my $modelLabel='model';
$dut->addParameter('model');
$dut->addParameter("allParams");
$dut->addParameter("adsParams");
$dut->addParameter("hspiceParams");
$dut->addParameter("spectreParams");

my $adsInstLine = &dKitUtils::setAdsInstanceLineFormat($modelLabel, $adsparams, $spectreparams, $hspiceparams, $nodelist);
$dut->netlistInstanceTemplate(ads, $adsInstLine);
my $spectreInstLine = &dKitUtils::setSpectreInstanceLineFormat($modelLabel, $spectreparams, $hspiceparams, $nodelist);
$dut->netlistInstanceTemplate(spectre, $spectreInstLine);
$dut->netlistInstanceTemplate(hspice, '#instanceName ' . $nodelist . '<' . $modelLabel . '> [[<allParams>]] [[<hspiceParams>]]');


# Add an instance of the device under test and voltage sources.
if (! $model_name) {die "Error: \$model_name must be defined.";}
$model_name=~s/\s//g;
$m1=dKitInstance->new(rf_dut, ${prefix} . "99");
if($p1_conn !~ /^n\d+$/)
{
  printf("WARNING: p1_conn must be n followed by an integer, use ");
  if($p2_conn !~ /^n1$/) {
    $p1_conn="n1";
  } else {
    $p1_conn="n2";
  }
  printf($p1_conn . " instead.\n");
}
if($p2_conn !~ /^n\d+$/)
{
  if($num_pins > 1)
  {
    printf("WARNING: p2_conn must be n followed by an integer, use ");
    if($p1_conn == "n1") {
      $p2_conn="n2";
    } else {
      $p2_conn="n1";
    }
    printf($p2_conn . " instead.\n");
  }
}
$m1->parameterValue('model',$model_name);
if ($allparams) {$m1->parameterValue('allParams', $allparams);}

my $adsInstParams = &dKitUtils::adsInstanceParams($adsparams, $spectreparams, $hspiceparams);
if ($adsInstParams) {$m1->parameterValue('adsParams', $adsInstParams);}
my $spectreInstParams = &dKitUtils::spectreInstanceParams($spectreparams, $hspiceparams);
if ($spectreInstParams) {$m1->parameterValue('spectreParams', $spectreInstParams);}
if ($hspiceparams) {$m1->parameterValue('hspiceParams', $hspiceparams);}

$m1->nodeName(eval($p1_conn), $p1_conn);
if($p2_conn)
{
  $m1->nodeName(eval($p2_conn), $p2_conn);
}
for( $nodei=1; $nodei <= $num_pins; $nodei++ )
{
  my $nodename = sprintf("n%d", $nodei);
  if ( !($nodename eq $p1_conn) && !($nodename eq $p2_conn) && $nodelist =~ / $nodename / )
  {
    $m1->nodeName(eval($nodename), $nodename);
  }
}
$CIRCUIT->addInstance($m1);

$v1=dKitInstance->new(PORT, vport1);
$v1->nodeName(nplus, $p1_conn);
$v1->nodeName(nminus, 0);
$v1->parameterValue(Vdc, eval($p1_bias));
$v1->parameterValue(portNr, 1);
if (! defined $p1_refz) {$p1_refz=50;} 
$v1->parameterValue(referenceImpedance, $p1_refz);
$CIRCUIT->addInstance($v1);

if($p2_conn)
{
$v2=dKitInstance->new(PORT, vport2);
$v2->nodeName(nplus, $p2_conn);
$v2->nodeName(nminus, 0);
$v2->parameterValue(Vdc, eval($p2_bias));
$v2->parameterValue(portNr, 2);
if (! defined $p2_refz) {$p2_refz=50;} 
$v2->parameterValue(referenceImpedance, $p2_refz);
$CIRCUIT->addInstance($v2);
}

my @other_pins=();
for( $nodei=1; $nodei <= $num_pins; $nodei++ )
{
  my $nodename = sprintf("n%d", $nodei);
  if ( !(${nodename} eq ${p1_conn}) && !(${nodename} eq ${p2_conn}) && ${nodelist} =~ / ${nodename} / )
  {
    if ($loads{$nodei}) {
      # if nx_load is given, then add 'rl_x nx 0 R=value(nx_load)'
      my $rname = sprintf("rl_%d", $nodei);
      my $res = $loads{$nodei};
      $other_pins[$nodei]=dKitInstance->new(R, $rname);
      $other_pins[$nodei]->nodeName(n1, $nodename);
      $other_pins[$nodei]->nodeName(n2, 0);
      $other_pins[$nodei]->parameterValue(resistance, $res);
      $CIRCUIT->addInstance($other_pins[$nodei]);
    } else {
      # whether or not nx_bias is given, add 'vx nx 0 V=value(nx_bias)'
      my $bias = 0; 
      if ($biases{$nodei}) { $bias=$biases{$nodei}; }
      my $vname = sprintf("v%d", $nodei);
      $other_pins[$nodei]=dKitInstance->new(V, $vname);
      $other_pins[$nodei]->nodeName(nplus, $nodename);
      $other_pins[$nodei]->nodeName(nminus, 0);
      $other_pins[$nodei]->parameterValue(Vdc, $bias);
      $CIRCUIT->addInstance($other_pins[$nodei]);
    }
  }
}

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
  $CIRCUIT->addAnalysis($SP1);
}

# Output Plans

$OUTPUTDOPS=dKitAnalysis->new(OUTPUTPLAN_DOPS, "out1");
$OUTPUTDOPS->parameterValue(deviceParameters, "v2:i");
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
