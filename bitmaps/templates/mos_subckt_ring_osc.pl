#!/usr/bin/perl
# Copyright Keysight Technologies 2007 - 2014  

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
  print "       -tol []   -abs_tol [] \n";
  print "       -pmos_model []       -nmos_model []\n";
  print "       -vdd []\n";
  print "       -time_stop []        -time_step []\n";
  print "       -ads_model_lib []    -hspice_model_lib []    -spectre_model_lib []   -inline [yes/no]\n";
  print "       -p_allparams []      -p_adsparams []         -p_spectreparams []         -p_hspiceparams []\n";
  print "       -n_allparams []      -n_adsparams []         -n_spectreparams []         -n_hspiceparams []\n";
  print "       -p_width [] -p_length []   -p_ad []    -p_pd []     -p_as []    -p_ps []     -p_nrd []     -p_nrs []\n";
  print "       -n_width [] -n_length []   -n_ad []    -n_pd []     -n_as []    -n_ps []     -n_nrd []     -n_nrs []\n";
  print "       -reltol []  -vabstol []    -iabstol []    -gmin []\n";
  print "       -scale []    -temp[]   -tnom[]   -digits []\n";
  print "       -ads_scale []\n";
};


$ret = GetOptions ("h|help", "tol|tol:s", "abs_tol|abs_tol:s", "delfiles|delfiles:s", "simulators|simulators:s", "resultfile|resultfile:s", "testname|testname:s", "time_step|time_step:s", "time_stop|time_stop:s", "pmos_model|pmos_device:s", "nmos_model|nmos_device:s", "p_allparams|p_allparams:s", "p_adsparams|p_adsparams:s", "p_hspiceparams|p_hspiceparams:s", "p_spectreparams|p_spectreparams:s", "n_allparams|n_allparams:s", "n_adsparams|n_adsparams:s", "n_hspiceparams|n_hspiceparams:s", "n_spectreparams|n_spectreparams:s", "p_ad|p_ad:s", "p_as|p_as:s", "p_pd|p_pd:s", "p_ps|p_ps:s", "p_nrd|p_nrd:s", "p_nrs|p_nrs:s", "p_width|p_width:s", "p_length|p_length:s", "n_ad|n_ad:s", "n_as|p_as:s", "n_pd|n_pd:s", "n_ps|n_ps:s", "n_nrd|n_nrd:s", "n_nrs|n_nrs:s", "n_width|n_width:s", "n_length|n_length:s", "ads_model_lib|ads_model_lib:s", "hspice_model_lib|hspice_model_lib:s", "spectre_model_lib|spectre_model_lib:s","inline|inline:s","reltol|reltol:f","vabstol|vabstol:f","iabstol|iabstol:f","gmin|gmin:f","scale|scale:f","temp|temp:f","tnom|tnom:f","digits|digits:i","ads_scale|ads_scale:f");

$help               = $opt_h;
if ($help) {Usage();exit}

$simulators         = $opt_simulators;
$testName           = $opt_testname;
$delFiles           = $opt_delfiles;
$resultHtmlFile	    = $opt_resultfile;

$tol                = $opt_tol;
if(!$tol) {$tol=1.0;}

$abs_tol            = $opt_abs_tol;

$n_allparams        = $opt_allparams;
$n_adsparams        = $opt_adsparams;
$n_hspiceparams     = $opt_hspiceparams;
$n_spectreparams    = $opt_spectreparams;
$p_allparams        = $opt_allparams;
$p_adsparams        = $opt_adsparams;
$p_hspiceparams     = $opt_hspiceparams;
$p_spectreparams    = $opt_spectreparams;
$p_ad               = $opt_p_ad;
$p_pd               = $opt_p_pd;
$p_as               = $opt_p_as;
$p_ps               = $opt_p_ps;
$p_nrd              = $opt_p_nrd;
$p_nrs              = $opt_p_nrs;
$p_width            = $opt_p_width;
$p_length           = $opt_p_length;
$n_ad               = $opt_n_ad;
$n_pd               = $opt_n_pd;
$n_as               = $opt_n_as;
$n_ps               = $opt_n_ps;
$n_nrd              = $opt_n_nrd;
$n_nrs              = $opt_n_nrs;
$n_width            = $opt_n_width;
$n_length           = $opt_n_length;

$pmodel             = $opt_pmos_model;
$nmodel             = $opt_nmos_model;
$numStages          = $opt_num_stages;
$vdd                = $opt_vdd;
$time_stop          = $opt_time_stop;
$time_step          = $opt_time_step;

$ads_model_lib      = $opt_ads_model_lib;
$hspice_model_lib   = $opt_hspice_model_lib;
$spectre_model_lib  = $opt_spectre_model_lib;
$inline             = $opt_inline;
if($inline && lc($inline) eq 'yes') {$inline=1;}

$savePrefix='output';

if ((! $pmodel) || (! $nmodel)) {die "ERROR:  nmos_model and/or pmos_model has not been defined!";}
$pmodel=~s/\s//g;
$nmodel=~s/\s//g;
if (! $testName) {$testName="MOS_RING_OSC";}
$CIRCUIT=dKitCircuit->new($testName);

$rf_fet = dKitTemplate->new('rf_fet');
$rf_fet->requiredPrefix("x");
$rf_fet->addNode("nd");
$rf_fet->addNode("ng");
$rf_fet->addNode("ns");
$rf_fet->addNode("nb");
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
$rf_fet->netlistInstanceTemplate(hspice, '#instanceName %n1 %n2 %n3 %n4 <' . $modelLabel . '> [[<allParams>]] [[<hspiceParams>]]');

@pmosDevice=();
@nmosDevice=();
if (! $numStages) {$numStages=21};
$template='rf_fet';
$instancePrefix='x';
for $Stage (1..$numStages)
{
    $pDevName= $instancePrefix . (2*$Stage-1);
    $nDevName= $instancePrefix . (2*$Stage);
    $n1Name= $nodePrefix . ($Stage+1);
    $n2Name= $nodePrefix . $Stage;
    $pmosDevice[$Stage]=dKitInstance->new($template, $pDevName);
    $pmosDevice[$Stage]->nodeName(nd, $n1Name);
    $pmosDevice[$Stage]->nodeName(ng, $n2Name);
    $pmosDevice[$Stage]->nodeName(ns, "vplus");
    $pmosDevice[$Stage]->nodeName(nb, "vplus");
    if ($p_allparams) {$pmosDevice[$Stage]->parameterValue("allParams", $p_allparams)};

    my $adsInstParams = &dKitUtils::adsInstanceParams($p_adsparams, $p_spectreparams, $p_hspiceparams);
    if ($adsInstParams) {$pmosDevice[$Stage]->parameterValue('adsParams', $adsInstParams);}
    my $spectreInstParams = &dKitUtils::spectreInstanceParams($p_spectreparams, $p_hspiceparams);
    if ($spectreInstParams) {$pmosDevice[$Stage]->parameterValue('spectreParams', $spectreInstParams);}
    if ($p_hspiceparams) {$pmosDevice[$Stage]->parameterValue('hspiceParams', $p_hspiceparams);}

    $nmosDevice[$Stage]=dKitInstance->new($template, $nDevName);
    $nmosDevice[$Stage]->nodeName(nd, $n1Name);
    $nmosDevice[$Stage]->nodeName(ng, $n2Name);
    $nmosDevice[$Stage]->nodeName(ns, "0");
    $nmosDevice[$Stage]->nodeName(nb, "0");
    if ($n_allparams) {$nmosDevice[$Stage]->parameterValue("allParams", $n_allparams)};

    my $adsInstParams = &dKitUtils::adsInstanceParams($n_adsparams, $n_spectreparams, $n_hspiceparams);
    if ($adsInstParams) {$pmosDevice[$Stage]->parameterValue('adsParams', $adsInstParams);}
    my $spectreInstParams = &dKitUtils::spectreInstanceParams($n_spectreparams, $n_hspiceparams);
    if ($spectreInstParams) {$pmosDevice[$Stage]->parameterValue('spectreParams', $spectreInstParams);}
    if ($n_hspiceparams) {$pmosDevice[$Stage]->parameterValue('hspiceParams', $n_hspiceparams);}

}

$pmosDevice[1]->nodeName(ng, $savePrefix);
$nmosDevice[1]->nodeName(ng, $savePrefix);
$pmosDevice[$numStages]->nodeName(nd, $savePrefix);
$nmosDevice[$numStages]->nodeName(nd, $savePrefix);

for $Stage (1..$numStages)
{
  $CIRCUIT->addInstance($pmosDevice[$Stage]);
  $CIRCUIT->addInstance($nmosDevice[$Stage]);
}

$IC1=dKitInstance->new(IC, "ic2");
$IC1->parameterValue('node', $savePrefix);
if (! $vdd) {print "WARNING:  vdd not set.  Setting to 2.5V\n"; $vdd=2.5;}
$IC1->parameterValue('value', $vdd);
$CIRCUIT->addInstance($IC1);

$V2=dKitInstance->new(V, "v2"); 
$V2->nodeName(nplus, "vplus");
$V2->nodeName(nminus, 0);
$V2->parameterValue(Vdc, $vdd);
$CIRCUIT->addInstance($V2);

if (! $time_stop) {$time_stop='1e-6';}
if (! $time_step) {$time_step='1e-8';}
$TR1 = dKitAnalysis->new(TRAN, Tr1);
$TR1->parameterValue(stop, $time_stop);
$TR1->parameterValue(step, $time_step);
$TR1->parameterValue(useInitCondADS, 'no');

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
if (!$abs_tol) { $abs_tol = "1e-12"; }
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

$OP1=dKitAnalysis->new(OUTPUTPLAN_NODES, "Tran_Plan1");
$OP1->parameterValue(nodes, $savePrefix);
$TR1->addOutputPlan($OP1);
$CIRCUIT->addAnalysis($TR1);

# Add Library Models


@ads_model_lib=split ",",$ads_model_lib;
@hspice_model_lib=split ",",$hspice_model_lib;
@spectre_model_lib=split ",",$spectre_model_lib;

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

$CIRCUIT->simulate(eval($simulators));
my $passFail=mVerifyResults->ringOscResults("$testName",$testName,$resultHtmlFile,$simulators,$savePrefix,$vdd/2,1,1,$numStages,$abs_tol,$tol);
print $passfail;
mVerifyResults::deleteFiles($testName,$delFiles,$passFail);
