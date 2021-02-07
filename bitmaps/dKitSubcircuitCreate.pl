eval 'exec $HPEESOF_DIR/tools/bin/perl -S $0 ${1+"$@"}'
# Copyright Keysight Technologies 2002 - 2014  
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

### mv previous subcircuit database out of the way
    if (-f "./dKitSubcircuitDB.pl" )
    {
	rename("dKitSubcircuitDB.pl", "dKitSubcircuitDB.pl" . ".old");
    }

}
use lib "$myLibPath";

use dKitCircuit;

# dKitCircuit->debug(0);

###########################################################################
### Contents:
#
# Subcircuits:
#    dKitSubCkt_portBiasedIdealNetwork : port with ideal bias network 
#                                                 (hspice and ads only)
#    dKitSubCkt_portBiasNetwork        : port with LC based bias network
#
#
# Templates:
#    PORT_BIN : port with ideal bias network (hspice and ads only)
#    PORT_BN  : port with LC based bias network
#
#

###########################################################################
## create subcircuit and template for Ideal bias network for hspice and ads
##   add template for S-parameter port component using this subcircuit

$DC_BLOCK = dKitInstance->new('SHORT', 'dc_block');
$DC_BLOCK->parameterValue('mode', '1');
$DC_BLOCK->nodeName('n1', "nIntern1");
$DC_BLOCK->nodeName('n2', "nplus");

$DC_FEED = dKitInstance->new('SHORT', 'dc_feed');
$DC_FEED->parameterValue('mode', '-1');
$DC_FEED->nodeName('n1', "nIntern2");
$DC_FEED->nodeName('n2', "nplus");

$PORT = dKitInstance->new('PORT', 'vport');
$PORT->parameterValue('portNr', 'pbin_portnr');
$PORT->parameterValue('referenceImpedance', 'pbin_referenceimpedance');
$PORT->nodeName('nplus',  "nIntern1");
$PORT->nodeName('nminus', "nminus");

$VDC = dKitInstance->new('V', 'vdc2');
$VDC->parameterValue('Vdc', 'pbin_vdc');
$VDC->nodeName('nplus',  "nIntern2");
$VDC->nodeName('nminus', "nminus");

dKitCircuit->remove("dKitSubCkt_portBiasedIdealNetwork");

$CIRCUIT2 = dKitCircuit->new("dKitSubCkt_portBiasedIdealNetwork");
$CIRCUIT2->addInstance($DC_BLOCK);
$CIRCUIT2->addInstance($DC_FEED);
$CIRCUIT2->addInstance($VDC);
$CIRCUIT2->addInstance($PORT);

$CIRCUIT2->addToSubcircuits(['nplus', 'nminus'],    #NODES
			    [],                     #requiredParameterList
['pbin_referenceimpedance=50', 'pbin_vdc=0', 'pbin_portnr=0' ]      #optionalParameterList
                            );


####### define custom template for 
### PORT_BIN port using dc blocks... native for hspice... not implemented for spectre

$PORTTEMPLATE2 = dKitTemplate->new(PORT_BIN);
$PORTTEMPLATE2->description("Port biased using an ideal bias network.\n   Not available for spectre");
$PORTTEMPLATE2->requiredPrefix("v");

$PORTTEMPLATE2->netlistInstanceTemplate(hspice, '#instanceName %nplus %nminus [[DC=<pbin_vdc>]] [[AC=<pbin_vac_mag>]]');

$PORTTEMPLATE2->netlistInstanceTemplate(ads, 'dKitSubCkt_portBiasedIdealNetwork:#instanceName %nplus %nminus pbin_portnr=<pbin_portnr> [[pbin_vdc=<pbin_vdc>]] [[pbin_referenceimpedance=<pbin_referenceimpedance>]]');

$PORTTEMPLATE2->dKitSubcircuitName(ads, "dKitSubCkt_portBiasedIdealNetwork");
### to be added for verification tool internal port bookkeeping...
$PORTTEMPLATE2->addParameter('i_portNr');
$PORTTEMPLATE2->addParameter('i_referenceImpedance');
$PORTTEMPLATE2->addParameter('i_portName');

## add VDC sweep parameter definition ...
$P_pbin_vdc = dKitParameter->new('pbin_vdc');
$P_pbin_vdc->description("dc voltage ideal bias network");
$P_pbin_vdc->dialectReference('hspice', "pbin_vdc");
$P_pbin_vdc->dialectReference('ads', "pbin_vdc");
$P_pbin_vdc->dialectReference('spectre', "pbin_vdc");
$P_pbin_vdc->resultName("pbin_vdc");

###########################################################################
######## port biased using L and C network

## define feed network ....

$DC_FEED3 = dKitInstance->new('L', 'l3');
$DC_FEED3->parameterValue('inductance', 'pbn_inductance');
$DC_FEED3->nodeName('n1', "nvdc");
$DC_FEED3->nodeName('n2', "nplus");

$DC_BLOCK3 = dKitInstance->new('C', 'c3');
$DC_BLOCK3->parameterValue('capacitance', 'pbn_capacitance');
$DC_BLOCK3->nodeName('n1', "nacsource");
$DC_BLOCK3->nodeName('n2', "nplus");

$VDC3 = dKitInstance->new('V', 'vdc3');
$VDC3->parameterValue('Vdc', 'pbn_vdc');
$VDC3->nodeName('nplus',  "nvdc");
$VDC3->nodeName('nminus', "nminus");

$PORT3 = dKitInstance->new('PORT', 'vport3');

### NOTE
### normally you would expect here to have
# $PORT3->parameterValue('portNr', 'pbn_portnr');
#
# but spectre returns an error in DC analysis when it finds a line
# vport3_x7 nacsource_x7 0 port num=pbn_portnr_x7 r=pbn_referenceimpedance_x7
# where pbn_portnr_x7 is defined as
# parameters pbn_portnr_x7=1
# it does not complain on lines
# vport3_x7 nacsource_x7 0 port num=1 r=pbn_referenceimpedance_x7
# so we have to lookup the value of the variable and substitute it
# so spectre does not have to do it, hence the following line:

$PORT3->parameterValue('portNr', '~eval(my $instance=dKitInstance->getInstance("pbn_portnr"); if ($instance) {return $instance->parameterValue("value");} else {return "pbn_portnr";})end');

$PORT3->parameterValue('referenceImpedance', "pbn_referenceimpedance");
$PORT3->parameterValue('Vac_Mag', "pbn_vac_mag");
$PORT3->nodeName('nplus',  "nacsource");
$PORT3->nodeName('nminus', "nminus");

dKitCircuit->remove("dKitSubCkt_portBiasNetwork");

$CIRCUIT3 = dKitCircuit->new("dKitSubCkt_portBiasNetwork");
$CIRCUIT3->addInstance($DC_BLOCK3);
$CIRCUIT3->addInstance($DC_FEED3);
$CIRCUIT3->addInstance($VDC3);
$CIRCUIT3->addInstance($PORT3);

$PORTTEMPLATE3 = $CIRCUIT3->createTemplateANDaddToSubcircuits("PORT_BN",
                      ['nplus', 'nminus'],   #NODES
['pbn_vdc=0', 'pbn_capacitance=1', 'pbn_inductance=1', 'pbn_portnr=1', 'pbn_referenceimpedance=50', 'pbn_vac_mag=0' ]    #parameterList
				       );

### to be added for verification tool internal port bookkeeping...
$PORTTEMPLATE3->addParameter('i_portNr');
$PORTTEMPLATE3->addParameter('i_referenceImpedance');
$PORTTEMPLATE3->addParameter('i_portName');

### this subcircuit needs to be inlined otherwise it does not work
$PORTTEMPLATE3->inline('ads', 1);
$PORTTEMPLATE3->inline('hspice', 1);
$PORTTEMPLATE3->inline('spectre', 1);

## add VDC sweep parameter definition ...
$P_pbn_vdc = dKitParameter->new('pbn_vdc');
$P_pbn_vdc->description("dc voltage bias network");
$P_pbn_vdc->dialectReference('hspice', "pbn_vdc");
$P_pbn_vdc->dialectReference('ads', "pbn_vdc");
$P_pbn_vdc->dialectReference('spectre', "pbn_vdc");
$P_pbn_vdc->resultName("pbn_vdc");


#### save subcircuits and the templates
#

dKitCircuit->createSubcircuitDatabaseFile;
dKitTemplate->createTemplateDatabaseFile;
dKitParameter->createParameterDatabaseFile;

1




