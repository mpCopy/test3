eval 'exec $HPEESOF_DIR/tools/bin/perl -S $0 ${1+"$@"}'
# Copyright Keysight Technologies 2001 - 2014  
if 0;

BEGIN {
    if ($ENV{DKITVERIFICATION} eq "")
    {
	if ($ENV{HPEESOF_DIR} eq "")
        {
	    print "\nPlease set environment variable DKITVERIFICATION\nto point to the design kit verification installation directory\n\n";
	    exit 1;
	} else
        {
	    $ENV{DKITVERIFICATION} = "$ENV{HPEESOF_DIR}/design_kit/verification";
	}
    }
    $myLibPath = "$ENV{DKITVERIFICATION}/perl/lib";
    if ( ! -d $myLibPath)
    {
	if ($ENV{DKITVERIFICATION} eq "$ENV{HPEESOF_DIR}/design_kit/verification")
	{
	    if ( ! -d "$ENV{HPEESOF_DIR}/design_kit/verification")
	    {
		print "\nERROR: Unable to find verification module directory\nVerification tool not installed at default\nlocation \$HPEESOF_DIR/design_kit/verification\n";
		print "Please set environment variable DKITVERIFICATION to point\nto the design kit verification installation directory\n\n";
	    } else
            {
		print "\nERROR: Unable to find verification module directory at\ndefault location \$HPEESOF_DIR/design_kit/verification/perl/lib\n";
		print "Please set environment variable DKITVERIFICATION\nto point to the installation directory\n\n";
	    }
	} else
	{
	    print "\nERROR : Unable to find verification module directory \$DKITVERIFICATION/perl/lib\n\n";
	    print "Please set environment variable DKITVERIFICATION\nto point to the design kit verification installation directory\n\n";
	}
	exit 1;
    }
### mv version 1 dKitParameter.pm file out of the way
    if (-f "./dKitParameter.pm" && ! -f "$workDirectory/dKitCircuit.pm" )
    {
	rename("dKitParameter.pm", "dKitParameter.pm" . ".old");
    }
    
### mv previous database out of the way
    if (-f "./dKitParameterDB.pl" )
    {
	rename("dKitParameterDB.pl", "dKitParameterDB.pl" . ".old");
    }

}
use lib "$myLibPath";

use Cwd;
my $workDirectory = cwd;


use dKitParameter;

### define default instances
###

$IDC = dKitParameter->new(Idc);
$IDC->description("dc current");

$VDC = dKitParameter->new(Vdc);
$VDC->description("dc voltage");

$IAC = dKitParameter->new(Iac);
$IAC->description("ac current");

$VAC = dKitParameter->new(Vac);
$VAC->description("ac voltage");

$IAC_mag = dKitParameter->new(Iac_Mag);
$IAC_mag->description("magnitude of ac current");

$VAC_mag = dKitParameter->new(Vac_Mag);
$VAC_mag->description("magnitude of ac voltage");

$IAC_phase = dKitParameter->new(Iac_Phase);
$IAC_phase->description("phase of ac current");

$VAC_phase = dKitParameter->new(Vac_Phase);
$VAC_phase->description("phase of ac voltage");

$FREQ = dKitParameter->new(freq);
$FREQ->description("frequency");

$TEMP = dKitParameter->new(temp);
$TEMP->description("temperature");

$ITER = dKitParameter->new(iteration);
$ITER->description("Monte Carlo Iteration");

$YIELD = dKitParameter->new(yield);
$YIELD->description("Yield");

$NPASS = dKitParameter->new(numpass);
$NPASS->description("Number Passed");

$NFAIL = dKitParameter->new(numfail);
$NPASS->description("Number Failed");

#hspice

$IDC->dialectReference(hspice, 'dc');
$VDC->dialectReference(hspice, 'dc');
$IAC->dialectReference(hspice, 'ac');
$VAC->dialectReference(hspice, 'ac');
$IAC_mag->dialectReference(hspice, 'mag');
$VAC_mag->dialectReference(hspice, 'mag');
$IAC_phase->dialectReference(hspice, 'phase');
$VAC_phase->dialectReference(hspice, 'phase');

$FREQ ->dialectReference(hspice, 'freq');
$TEMP ->dialectReference(hspice, 'temp');


#ads

$IDC->dialectReference(ads, 'Idc');
$VDC->dialectReference(ads, 'Vdc');
$IAC->dialectReference(ads, 'Iac');
$VAC->dialectReference(ads, 'Vac');
$IAC_mag->dialectReference(ads, 'Iac');
$VAC_mag->dialectReference(ads, 'Vac');
$IAC_phase->dialectReference(ads, 'phase');
$VAC_phase->dialectReference(ads, 'phase');
$FREQ->dialectReference(ads, 'freq');
$TEMP->dialectReference(ads, 'temp');

$ITER->dialectReference(ads, 'mcTrial');
$YIELD->dialectReference(ads, 'Yield');
$NPASS->dialectReference(ads, 'NumPass');
$NFAIL->dialectReference(ads, 'NumFail');


#spectre

$IDC->dialectReference(spectre, 'dc');
$VDC->dialectReference(spectre, 'dc');
$IAC->dialectReference(spectre, 'mag');
$VAC->dialectReference(spectre, 'mag');
$IAC_mag->dialectReference(spectre, 'mag');
$VAC_mag->dialectReference(spectre, 'mag');
$IAC_phase->dialectReference(spectre, 'phase');
$VAC_phase->dialectReference(spectre, 'phase');
$FREQ->dialectReference(spectre, 'freq');
$TEMP->dialectReference(spectre, 'temp');

# resultNames
# names should be choses inorder that $parameter($dialect)->resultname 
# is unique
#e.g 
#$IDC->resultName("idc");
#$VDC->resultName("vdc");
#would create ambiguity, because both have the hspice reference dc
#so we need 
#$IDC->resultName("dc");
#$VDC->resultName("dc");

$IDC->resultName("dc");
$VDC->resultName("dc");

$IAC->resultName("ac_mag");
$VAC->resultName("ac_mag");
$IAC_mag->resultName("ac_mag");
$VAC_mag->resultName("ac_mag");
$IAC_phase->resultName("phase");
$VAC_phase->resultName("phase");

$FREQ->resultName("freq");
$TEMP->resultName("temp");

$ITER->resultName("iteration");
$YIELD->resultName("yield");
$NPASS->resultName("npass");
$NFAIL->resultName("nfail");

#### parameters related to device operating points (output)

$DOP = dKitParameter->new(oppoint);
$DOP->description("output all parameters of device operationg point");
$DOP->dialectReference(hspice, ''); # not possible
$DOP->dialectReference(ads, '');
$DOP->dialectReference(spectre, 'oppoint');
$DOP->resultName('');

#### parameters related to device operating points

$DOP = dKitParameter->new("emptyOne");
$DOP->description("");
$DOP->dialectReference(hspice, ''); 
$DOP->dialectReference(ads, '');
$DOP->dialectReference(spectre, '');
$DOP->resultName('');

$DOP = dKitParameter->new("Power");
$DOP->description("");
$DOP->dialectReference(hspice, ''); 
$DOP->dialectReference(ads, 'Power');
$DOP->dialectReference(spectre, 'pwr');
$DOP->resultName('power');

$DOP = dKitParameter->new("Vth");
$DOP->description("");
$DOP->dialectReference(hspice, ''); 
$DOP->dialectReference(ads, 'Vth');
$DOP->dialectReference(spectre, 'vth');
$DOP->resultName('vth');

$DOP = dKitParameter->new("Vbs");
$DOP->description("");
$DOP->dialectReference(hspice, ''); 
$DOP->dialectReference(ads, 'Vbs');
$DOP->dialectReference(spectre, 'vbs');
$DOP->resultName('vbs');

$DOP = dKitParameter->new("Vds");
$DOP->description("");
$DOP->dialectReference(hspice, ''); 
$DOP->dialectReference(ads, 'Vds');
$DOP->dialectReference(spectre, 'vds');
$DOP->resultName('vds');

$DOP = dKitParameter->new("Vgs");
$DOP->description("");
$DOP->dialectReference(hspice, ''); 
$DOP->dialectReference(ads, 'Vgs');
$DOP->dialectReference(spectre, 'vgs');
$DOP->resultName('vgs');

$DOP = dKitParameter->new(Id);
$DOP->description("Idrain");
$DOP->dialectReference(hspice, ''); 
$DOP->dialectReference(ads, 'Id');
$DOP->dialectReference(spectre, 'id');
$DOP->resultName('id');

$DOP = dKitParameter->new(Ig);
$DOP->description("Gate current");
$DOP->dialectReference(hspice, ''); 
$DOP->dialectReference(ads, 'Ig');
$DOP->dialectReference(spectre, '');
$DOP->resultName('ig');

$DOP = dKitParameter->new(Gm);
$DOP->description("Forward transconductance");
$DOP->dialectReference(hspice, 'lx7ofdevice'); 
$DOP->dialectReference(ads, 'Gm');
$DOP->dialectReference(spectre, 'gm');
$DOP->resultName('gm');

$DOP = dKitParameter->new(Gds);
$DOP->description("Output conductance");
$DOP->dialectReference(hspice, 'lx8ofdevice');
$DOP->dialectReference(ads, 'Gds');
$DOP->dialectReference(spectre, 'gds');
$DOP->resultName('gds');

$DOP = dKitParameter->new(Ib);
$DOP->description("Ibase(BJT) or Ibulk(MOS)");
$DOP->dialectReference(hspice, '');
$DOP->dialectReference(ads, 'Ib');
$DOP->dialectReference(spectre, 'ib');
$DOP->resultName('ib');


$DOP = dKitParameter->new(i);
$DOP->description("device operationg point current");
$DOP->dialectReference(hspice, 'iofdevice');
$DOP->dialectReference(ads, 'i');
$DOP->dialectReference(spectre, 'i');
$DOP->resultName('i1');

$DOP = dKitParameter->new(I);
$DOP->description("device operationg point current");
$DOP->dialectReference(ads, 'I');
$DOP->resultName('i1');

$DOP = dKitParameter->new(Is);
$DOP->description("device operationg point current");
$DOP->dialectReference(ads, 'Is');
$DOP->resultName('i1');

$DOP = dKitParameter->new(Vs);
$DOP->description("device operationg point voltage");
$DOP->dialectReference(ads, 'Vs');
$DOP->resultName('v');

$DOP = dKitParameter->new(Vd);
$DOP->description("device operationg point voltage");
$DOP->dialectReference(ads, 'Vd');
$DOP->dialectReference(spectre, 'v');
$DOP->resultName('v');

$DOP = dKitParameter->new(V);
$DOP->description("device operationg point voltage");
$DOP->dialectReference(ads, 'V');
$DOP->resultName('v');

$DOP = dKitParameter->new(R);
$DOP->description("device operationg point resistance");
$DOP->dialectReference(ads, 'R');
$DOP->resultName('r');

$DOP = dKitParameter->new(L);
$DOP->description("device operationg point inductance");
$DOP->dialectReference(ads, 'L');
$DOP->resultName('l');

$DOP = dKitParameter->new(C);
$DOP->description("device operationg point capacitance");
$DOP->dialectReference(ads, 'C');
$DOP->resultName('c');

$DOP = dKitParameter->new(Vbc);
$DOP->description("Base-collector voltage");
$DOP->dialectReference(hspice, 'lx1ofdevice');
$DOP->dialectReference(ads, 'Vbc');
$DOP->dialectReference(spectre, 'vbc');
$DOP->resultName('vbc');

$DOP = dKitParameter->new(Vbe);
$DOP->description("Base-emitter voltage");
$DOP->dialectReference(hspice, 'lx0ofdevice');
$DOP->dialectReference(ads, 'Vbe');
$DOP->dialectReference(spectre, 'vbe');
$DOP->resultName('vbe');

$DOP = dKitParameter->new(Vce);
$DOP->description("Collector-emitter voltage");
$DOP->dialectReference(hspice, '');
$DOP->dialectReference(ads, 'Vce');
$DOP->dialectReference(spectre, 'vce');
$DOP->resultName('vce');

$DOP = dKitParameter->new(Ic);
$DOP->description("Collector current");
$DOP->dialectReference(hspice, 'lx2ofdevice');
$DOP->dialectReference(ads, 'Ic');
$DOP->dialectReference(spectre, 'ic');
$DOP->resultName('ic');

$DOP = dKitParameter->new(Ie);
$DOP->description("Emitter current");
$DOP->dialectReference(hspice, '');
$DOP->dialectReference(ads, 'Ie');
$DOP->dialectReference(spectre, 'ie');
$DOP->resultName('ie');

$DOP = dKitParameter->new(BetaDc);
$DOP->description("DC current gain");
$DOP->dialectReference(hspice, '');
$DOP->dialectReference(ads, 'BetaDc');
$DOP->dialectReference(spectre, 'betadc');
$DOP->resultName('betadc');

$DOP = dKitParameter->new(BetaAc);
$DOP->description("Ac current gain");
$DOP->dialectReference(hspice, '');
$DOP->dialectReference(ads, 'BetaAc');
$DOP->dialectReference(spectre, 'betaac');
$DOP->resultName('betaac');

$DOP = dKitParameter->new(Rpi);
$DOP->description("Input resistance");
$DOP->dialectReference(hspice, '');
$DOP->dialectReference(ads, 'Rpi');
$DOP->dialectReference(spectre, 'rpi');
$DOP->resultName('rpi');

$DOP = dKitParameter->new(Rmu);
$DOP->description("Feedback resistance");
$DOP->dialectReference(hspice, '');
$DOP->dialectReference(ads, 'Rmu');
$DOP->dialectReference(spectre, '');
$DOP->resultName('rmu');

$DOP = dKitParameter->new(Rx);
$DOP->description("Base resistance");
$DOP->dialectReference(hspice, '');
$DOP->dialectReference(ads, 'Rx');
$DOP->dialectReference(spectre, '');
$DOP->resultName('rx');

$DOP = dKitParameter->new(Ro);
$DOP->description("Base resistance");
$DOP->dialectReference(hspice, '');
$DOP->dialectReference(ads, 'Ro');
$DOP->dialectReference(spectre, 'ro');
$DOP->resultName('ro');

$DOP = dKitParameter->new(Cpi);
$DOP->description("Base-emitter capacitance");
$DOP->dialectReference(hspice, 'lx19');
#would create ambiguity, because both Cpi and DqgDvdb have the hspice reference lx19
$DOP->dialectReference(ads, 'Cpi');
$DOP->dialectReference(spectre, 'cpi');
$DOP->resultName('cpi');

$DOP = dKitParameter->new(Cmu);
$DOP->description("Base-internal collector capacitance");
$DOP->dialectReference(hspice, 'lx20');
#would create ambiguity, because both Cmu and DqgDvsb have the hspice reference lx20
$DOP->dialectReference(ads, 'Cmu');
$DOP->dialectReference(spectre, 'cmu');
$DOP->resultName('cmu');

$DOP = dKitParameter->new(Cbx);
$DOP->description("Base-external collector capacitance");
$DOP->dialectReference(hspice, 'lx22');
#would create ambiguity, because both Cbx and DqbDvdb have the hspice reference lx22
$DOP->dialectReference(ads, 'Cbx');
$DOP->dialectReference(spectre, 'cmux');
$DOP->resultName('cbx');

$DOP = dKitParameter->new(Ccs);
$DOP->description("Substrate capacitance");
$DOP->dialectReference(hspice, 'lx21');
#would create ambiguity, because both Ccs and DqbDvgb have the hspice reference lx21
$DOP->dialectReference(ads, 'Ccs');
$DOP->dialectReference(spectre, 'csub');
$DOP->resultName('ccs');

$DOP = dKitParameter->new(Ft);
$DOP->description("Unity current gain frequency");
$DOP->dialectReference(hspice, 'lx5ofdevice');
$DOP->dialectReference(ads, 'Ft');
$DOP->dialectReference(spectre, 'ft');
$DOP->resultName('ft');

$DOP = dKitParameter->new(Rdsw);
$DOP->description("Sidewall series resistance");
$DOP->dialectReference(hspice, '');
$DOP->dialectReference(ads, 'Rdsw');
$DOP->dialectReference(spectre, 'resp');
$DOP->resultName('rdsw');

$DOP = dKitParameter->new(Rd);
$DOP->description("Junction series resistance");
$DOP->dialectReference(hspice, '');
$DOP->dialectReference(ads, 'Rd');
$DOP->dialectReference(spectre, 'res');
$DOP->resultName('rd');

$DOP = dKitParameter->new(Cd);
$DOP->description("Junction capacitance");
$DOP->dialectReference(hspice, '');
$DOP->dialectReference(ads, 'Cd');
$DOP->dialectReference(spectre, 'cap');
$DOP->resultName('cd');

$DOP = dKitParameter->new(Cdsw);
$DOP->description("Sidewall capacitance");
$DOP->dialectReference(hspice, '');
$DOP->dialectReference(ads, 'Cdsw');
$DOP->dialectReference(spectre, 'capp');
$DOP->resultName('cdsw');

$DOP = dKitParameter->new(Gmb);
$DOP->description("Backgate transconductance");
$DOP->dialectReference(hspice, 'lx9ofdevice'); 
$DOP->dialectReference(ads, 'Gmb');
$DOP->dialectReference(spectre, 'gmbx');
$DOP->resultName('gmb');

$DOP = dKitParameter->new(Vdsat);
$DOP->description("Drain-source saturation voltage");
$DOP->dialectReference(hspice, 'lx10ofdevice'); 
$DOP->dialectReference(ads, 'Vdsat');
$DOP->dialectReference(spectre, 'vdsat');
$DOP->resultName('vdsat');

$DOP = dKitParameter->new(Capbd);
$DOP->description("Bulk-drain capacitance");
$DOP->dialectReference(hspice, 'lx29ofdevice'); 
$DOP->dialectReference(ads, 'Capbd');
$DOP->dialectReference(spectre, 'cjd');
$DOP->resultName('capbd');

$DOP = dKitParameter->new(Capbs);
$DOP->description("Bulk-source capacitance");
$DOP->dialectReference(hspice, 'lx28ofdevice'); 
$DOP->dialectReference(ads, 'Capbs');
$DOP->dialectReference(spectre, 'cjs');
$DOP->resultName('capbs');

$DOP = dKitParameter->new(CgdM);
$DOP->description("Gate-drain Meyer capacitance");
$DOP->dialectReference(hspice, ''); 
$DOP->dialectReference(ads, 'CgdM');
$DOP->dialectReference(spectre, '');
$DOP->resultName('cgdm');

$DOP = dKitParameter->new(CgbM);
$DOP->description("Gate-bulk Meyer capacitance");
$DOP->dialectReference(hspice, ''); 
$DOP->dialectReference(ads, 'CgbM');
$DOP->dialectReference(spectre, '');
$DOP->resultName('cgbm');

$DOP = dKitParameter->new(CgsM);
$DOP->description("Gate-source Meyer capacitance");
$DOP->dialectReference(hspice, ''); 
$DOP->dialectReference(ads, 'CgsM');
$DOP->dialectReference(spectre, '');
$DOP->resultName('cgsm');

$DOP = dKitParameter->new(DqgDvgb);
$DOP->description("(dQg/dVgb)");
$DOP->dialectReference(hspice, 'lx18ofdevice'); 
$DOP->dialectReference(ads, 'DqgDvgb');
$DOP->dialectReference(spectre, 'cgg');
$DOP->resultName('dqgdvgb');

$DOP = dKitParameter->new(DqgDvdb);
$DOP->description("(dQg/dVdb)");
$DOP->dialectReference(hspice, 'lx19ofdevice'); 
#would create ambiguity, because both Cpi and DqgDvdb have the hspice reference lx19
$DOP->dialectReference(ads, 'DqgDvdb');
$DOP->dialectReference(spectre, 'cgd');
$DOP->resultName('dqgdvdb');

$DOP = dKitParameter->new(DqgDvsb);
$DOP->description("(dQg/dVsb)");
$DOP->dialectReference(hspice, 'lx20ofdevice'); 
#would create ambiguity, because both Cmu and DqgDvsb have the hspice reference lx20
$DOP->dialectReference(ads, 'DqgDvsb');
$DOP->dialectReference(spectre, 'cgs');
$DOP->resultName('dqgdvsb');

$DOP = dKitParameter->new(DqbDvgb);
$DOP->description("(dQb/dVgb)");
$DOP->dialectReference(hspice, 'lx21ofdevice'); 
#would create ambiguity, because both Ccs and DqbDvgb have the hspice reference lx21
$DOP->dialectReference(ads, 'DqbDvgb');
$DOP->dialectReference(spectre, 'cbg');
$DOP->resultName('dqbdvgb');

$DOP = dKitParameter->new(DqbDvdb);
$DOP->description("(dQb/dVdb)");
$DOP->dialectReference(hspice, 'lx22ofdevice'); 
#would create ambiguity, because both Cbx and DqbDvdb have the hspice reference lx22
$DOP->dialectReference(ads, 'DqbDvdb');
$DOP->dialectReference(spectre, 'cdb');
$DOP->resultName('dqgdvgb');

$DOP = dKitParameter->new(DqbDvsb);
$DOP->description("(dQb/dVsb)");
$DOP->dialectReference(hspice, 'lx23ofdevice'); 
$DOP->dialectReference(ads, 'DqbDvsb');
$DOP->dialectReference(spectre, 'cbs');
$DOP->resultName('dqbdvsb');

$DOP = dKitParameter->new(DqdDvgb);
$DOP->description("(dQd/dVgb)");
$DOP->dialectReference(hspice, 'lx32ofdevice'); 
$DOP->dialectReference(ads, 'DqdDvgb');
$DOP->dialectReference(spectre, 'cdg');
$DOP->resultName('dqddvgb');

$DOP = dKitParameter->new(DqdDvdb);
$DOP->description("(dQd/dVdb)");
$DOP->dialectReference(hspice, 'lx33ofdevice'); 
$DOP->dialectReference(ads, 'DqdDvdb');
$DOP->dialectReference(spectre, 'cdd');
$DOP->resultName('dqddvdb');

$DOP = dKitParameter->new(DqdDvsb);
$DOP->description("(dQd/dVsb)");
$DOP->dialectReference(hspice, 'lx34ofdevice'); 
$DOP->dialectReference(ads, 'DqdDvsb');
$DOP->dialectReference(spectre, 'cds');
$DOP->resultName('dqddvsb');

### create the dKitParameterDB.pl file

dKitParameter->createParameterDatabaseFile;

1






