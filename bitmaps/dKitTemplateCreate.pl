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

### mv version 1 dKitTemplate.pm file out of the way
    if (-f "./dKitTemplate.pm" && ! -f "$workDirectory/dKitCircuit.pm" )
    {
	rename("dKitTemplate.pm", "dKitTemplate.pm" . ".old");
    }

### mv previous database out of the way
    if (-f "./dKitTemplateDB.pl" )
    {
	rename("dKitTemplateDB.pl", "dKitTemplateDB.pl" . ".old");
    }

}

use lib "$myLibPath";

use Cwd;
my $workDirectory = cwd;

use dKitTemplate;

### define default instances
###

$B = dKitTemplate->new(B);
$B->description("IBIS Buffer for hspice, N type GaAsFet for ads");
$B->requiredPrefix("b");

$C = dKitTemplate->new(C);
$C->description("Capacitor");
$C->requiredPrefix("c");

$CM = dKitTemplate->new(CM);
$CM->description("Capacitor with model");
$CM->requiredPrefix("c");

$D = dKitTemplate->new(D);
$D->description("Diode");
$D->requiredPrefix("d");

$E = dKitTemplate->new(E);
$E->description("voltage controlled voltage source");
$E->requiredPrefix("e");

$F = dKitTemplate->new(F);
$F->description("current controlled current source");
$F->requiredPrefix("f");

$G = dKitTemplate->new(G);
$G->description("voltage controlled current source");
$G->requiredPrefix("g");

$H = dKitTemplate->new(H);
$H->description("current controlled voltage source");
$H->requiredPrefix("h");

$I = dKitTemplate->new(I);
$I->description("independent current source");
$I->requiredPrefix("i");

$IPULSE = dKitTemplate->new(IPULSE);
$IPULSE->description("independent pulse current source");
$IPULSE->requiredPrefix("i");
# added to fill HSpice syntax and match simulator defaults.
$IPULSE->addParameter("delay");
$IPULSE->addParameter("rise");
$IPULSE->addParameter("fall");
$IPULSE->addParameter("width");
$IPULSE->addParameter("period");
$IPULSE->parameterValue("rise","1n");
$IPULSE->parameterValue("fall","1n");
$IPULSE->parameterValue("width","3n");
$IPULSE->parameterValue("period","10n");
$IPULSE->parameterValue("delay","0");

$ISIN = dKitTemplate->new(ISIN);
$ISIN->description("independent damped sinusoidal current source");
$ISIN->requiredPrefix("i");
# added to fill HSpice syntax and match simulator defaults.
$ISIN->addParameter("freq");
$ISIN->addParameter("delay");
$ISIN->addParameter("damping");
$ISIN->parameterValue("freq","1G");
$ISIN->parameterValue("delay","0");
$ISIN->parameterValue("damping","0");

$INITCOND = dKitTemplate->new(IC);
$INITCOND->description("initial conditions");

$J = dKitTemplate->new(J);
$J->description("JFET");
$J->requiredPrefix("j");

$K = dKitTemplate->new(K);
$K->description("Mutual Inductor");
$K->requiredPrefix("k");

$L = dKitTemplate->new(L);
$L->description("Inductor");
$L->requiredPrefix("l");

$LM = dKitTemplate->new(LM);
$LM->description("Inductor with Model");
$LM->requiredPrefix("l");

$M = dKitTemplate->new(M);
$M->description("MOSFET");
$M->requiredPrefix("m");

$PORT = dKitTemplate->new(PORT);
$PORT->description("Port for S-Parameter Analysis");
$PORT->requiredPrefix("v");
### to be added for verification tool internal port bookkeeping...
$PORT->addParameter('i_portName');
$PORT->addParameter('i_portNr');
$PORT->addParameter('i_referenceImpedance');

$Q = dKitTemplate->new(Q);
$Q->description("Bipolar Junction Transistor");
$Q->requiredPrefix("q");

$R = dKitTemplate->new(R);
$R->description("Resistor");
$R->requiredPrefix("r");

$RM = dKitTemplate->new(RM);
$RM->description("Resistor with model");
$RM->requiredPrefix("r");

$SHORT = dKitTemplate->new(SHORT);
$SHORT->description("DC block or DC feed, ADS only");

$V = dKitTemplate->new(V);
$V->description("indepenent voltage source");
$V->requiredPrefix("v");

$VPULSE = dKitTemplate->new(VPULSE);
$VPULSE->description("independent pulse voltage source");
$VPULSE->requiredPrefix("v");
# added to fill HSpice syntax and match simulator defaults.
$VPULSE->addParameter("delay");
$VPULSE->addParameter("rise");
$VPULSE->addParameter("fall");
$VPULSE->addParameter("width");
$VPULSE->addParameter("period");
$VPULSE->parameterValue("rise","1n");
$VPULSE->parameterValue("fall","1n");
$VPULSE->parameterValue("width","3n");
$VPULSE->parameterValue("period","10n");
$VPULSE->parameterValue("delay","0");

$VSIN = dKitTemplate->new(VSIN);
$VSIN->description("independent damped sinusoidal voltage source");
$VSIN->requiredPrefix("v");
# added to fill HSpice syntax and match simulator defaults.
$VSIN->addParameter("freq");
$VSIN->addParameter("delay");
$VSIN->addParameter("damping");
$VSIN->parameterValue("freq","1G");
$VSIN->parameterValue("delay","0");
$VSIN->parameterValue("damping","0");

$Z = dKitTemplate->new(Z);
$Z->description("MESFET");
$Z->requiredPrefix("z");

$T = dKitTemplate->new(T);
$T->description("Lossless Transmission Line");
$T->requiredPrefix("t");

#$U1 = dKitTemplate->new(U1);
#$U1->description("Lossy Transmission Line (1line)");
#$U1->requiredPrefix("u");

#$W1 = dKitTemplate->new(W1);
#$W1->description("Lossy Transmission Line (1line)");
#$W1->requiredPrefix("w");


$Parameter = dKitTemplate->new(PARAMETER);
$Parameter->description("netlist parameter");
# $Parameter->requiredPrefix("");

$Temp = dKitTemplate->new(TEMPERATURE);
$Temp->description("circuit Temperature");



#hspice
$Parameter->netlistInstanceTemplate(hspice, '.param #instanceName="<value>"');

$Temp->netlistInstanceTemplate(hspice, ".TEMP <temperature>");


$C->netlistInstanceTemplate(hspice, '#instanceName %n1 %n2 C=<capacitance> [[TC1=<tempCoef1>]] [[TC2=<tempCoef2>]] [[SCALE=<scale>]] [[IC=<initialVoltage>]] [[DTEMP=<dtemp>]] [[M=<multiplicity>]]');

$CM->netlistInstanceTemplate(hspice, '#instanceName %n1 %n2 <modelName> [[C=<capacitance>]] [[TC1=<tempCoef1>]] [[TC2=<tempCoef2>]] [[SCALE=<scale>]] [[IC=<initialVoltage>]] [[M=<multiplicity>]] [[DTEMP=<dtemp>]] [[L=<length>]] [[W=<width>]]');

$D->netlistInstanceTemplate(hspice, '#instanceName %nplus %nminus <modelName> [[AREA=<area>]] [[W=<width>]] [[L=<length>]] [[PJ=<peripheryJunction>]] [[WP=<widthPolySilicon>]] [[LP=<lengthPolySilicon>]] [[WM=<widthMetalCapacitor>]] [[LM=<lengthMetalCapacitor>]] [[<off>]] [[IC=<initialVoltage>]] [[M=<multiplicity>]] [[DTEMP=<dtemp>]]');

$I->netlistInstanceTemplate(hspice, '#instanceName %nplus %nminus [[DC=<Idc>]] [[<transientFunction>]] [[AC=<Iac_Mag>,<Iac_Phase>]] [[M=<multiplicity>]]');
$I->parameterValue("Iac_Phase", 0);

$IPULSE->netlistInstanceTemplate(hspice, '#instanceName %nplus %nminus PULSE (<Ilow>,<Ihigh>,[[<delay>]],[[<rise>]],[[<fall>]],[[<width>]],[[<period>]])');

$ISIN->netlistInstanceTemplate(hspice, '#instanceName %nplus %nminus SIN (<Idc>,<amplitude>,[[<freq>]],[[<delay>]],[[<damping>]],[[<phase>]])');

$INITCOND->netlistInstanceTemplate(hspice, '.IC v(<node>)=<value>');

$J->netlistInstanceTemplate(hspice, '#instanceName %nd %ng %ns %nb <modelName> [[AREA=<area>]] [[W=<width>]] [[L=<length>]] [[<off>]] [[VDS=<vdsval>]] [[VGS=<vgsval>]] [[M=<multiplicity>]] [[DTEMP=<dtemp>]]');

$K->netlistInstanceTemplate(hspice, '#instanceName L<inductor1> L<inductor2> K=<coupling>');

$L->netlistInstanceTemplate(hspice, '#instanceName %n1 %n2 [[L=<inductance>]] [[TC1=<tempCoef1>]] [[TC2=<tempCoef2>]] [[SCALE=<scale>]] [[IC=<initialCurrent>]] [[M=<multiplicity>]] [[DTEMP=<dtemp>]] [[R=<resistance>]]');

$M->netlistInstanceTemplate(hspice, '#instanceName %nd %ng %ns %nb <modelName> [[L=<length>]] [[W=<width>]] [[AD=<drainDiffusionArea>]] [[AS=<sourceDiffusionArea>]] [[PD=<drainPerimeter>]] [[PS=<sourcePerimeter>]] [[NRD=<drainDiffusionSquares>]] [[NRS=<sourceDiffusionSquares>]] [[NQSMOD=<nqsmod>]] [[RDC=<drainResistanceAddl>]] [[RSC=<sourceResistanceAddl>]] [[<off>]] [[IC=<vdsval>,<vgsval>,<vbsval>]] [[M=<multiplicity>]] [[DTEMP=<dtemp>]] [[GEO=<geoSharing>]] [[DELVTO=<thresholdVoltageShift>]] [[Nf=<nf>]] [[Rgeomod=<Rgeomod>]] [[Geomod=<Geomod>]] [[Sa1=<Sa1>]] [[Sb1=<Sb1>]] [[Sw1=<Sw1>]] [[Sa2=<Sa2>]] [[Sb2=<Sb2>]] [[Sw2=<Sw2>]] [[Sa3=<Sa3>]] [[Sb3=<Sb3>]] [[Sw3=<Sw3>]] [[Sa4=<Sa4>]] [[Sb4=<Sb4>]] [[Sw4=<Sw4>]] [[Sa5=<Sa5>]] [[Sb5=<Sb5>]] [[Sw5=<Sw5>]] [[Sa6=<Sa6>]] [[Sb6=<Sb6>]] [[Sw6=<Sw6>]] [[Sa7=<Sa7>]] [[Sb7=<Sb7>]] [[Sw7=<Sw7>]] [[Sa8=<Sa8>]] [[Sb8=<Sb8>]] [[Sw8=<Sw8>]] [[Sa9=<Sa9>]] [[Sb9=<Sb9>]] [[Sw9=<Sw9>]] [[Sa10=<Sa10>]] [[Sb10=<Sb10>]] [[Sw10=<Sw10>]]');

$PORT->netlistInstanceTemplate(hspice, '#instanceName %nplus %nminus [[DC=<Vdc>]] [[<transientFunction>]] [[AC=<Vac_Mag>]]');

$Q->netlistInstanceTemplate(hspice, '#instanceName %nc %nb %ne %ns <modelName> [[AREA=<areaEmittor>]] [[AREAB=<areaBasis>]] [[AREAC=<areaCollector>]] [[<off>]] [[VBE=<vbeval>]] [[VCE=<vceval>]] [[M=<multiplicity>]] [[DTEMP=<dtemp>]]');

$R->netlistInstanceTemplate(hspice, '#instanceName %n1 %n2 [[<modelName>]] [[R=<resistance>]] [[TC1=<tempCoef1>]] [[TC2=<tempCoef2>]] [[SCALE=<scale>]] [[M=<multiplicity>]] [[AC=<acResistance>]] [[DTEMP=<dtemp>]] [[L=<length>]] [[W=<width>]] [[C=<capacitanceN2Bulk>]]');

$V->netlistInstanceTemplate(hspice, '#instanceName %nplus %nminus [[DC=<Vdc>]] [[<transientFunction>]] [[AC=<Vac_Mag>,<Vac_Phase>]]');
$V->parameterValue("Vac_Phase", 0);

$VPULSE->netlistInstanceTemplate(hspice, '#instanceName %nplus %nminus PULSE (<Vlow>,<Vhigh>,[[<delay>]],[[<rise>]],[[<fall>]],[[<width>]],[[<period>]])');

$VSIN->netlistInstanceTemplate(hspice, '#instanceName %nplus %nminus SIN (<Vdc>,<amplitude>,[[<freq>]],[[<delay>]],[[<damping>]],[[<phase>]])');

$T->netlistInstanceTemplate(hspice, '#instanceName %in %refin %out %refout [[<uModelName>]] [[Z0=<Z0>]] [[TD=<signalDelay>]] [[L=<length>]] [[F=<frequency>]] [[NL=<electricalLength>]] [[IC=<initial_v1>,<initial_i1>,<initial_v2>,<initial_i2>]]');

### in hspice mesfet is identical to jfet
$Z->netlistInstanceTemplate(hspice, '#instanceName %nd %ng %ns %nb <modelName> [[AREA=<area>]] [[W=<width>]] [[L=<length>]] [[<off>]] [[VDS=<vdsval>]] [[VGS=<vgsval>]] [[M=<multiplicity>]] [[DTEMP=<dtemp>]]');

#$U1->netlistInstanceTemplate(hspice, '#instanceName %in %refin %out %refout [[<uModelName>]] L=<length> [[LUMPS=<lumpedSections>]] ');

#$W1->netlistInstanceTemplate(hspice, '#instanceName %in %refin %out %refout N=1 L=<length> [[RLGCfile=<RLGCfileName>]] [[Umodel=<uModelName>]] [[FSmodel=<fsModelName>]] ');

### ads

$Parameter->netlistInstanceTemplate(ads, "#instanceName=<value>");

$Temp->netlistInstanceTemplate(ads, "Options Temp=<temperature>");

$C->netlistInstanceTemplate(ads, 'C:#instanceName %n1 %n2 C=<capacitance> [[Temp=<temp>]] [[Tnom=<tnom>]] [[TC1=<tempCoef1>]] [[TC2=<tempCoef2>]] [[InitCond=<initialVoltage>]] [[_M=<multiplicity>]]');

$CM->netlistInstanceTemplate(ads, '<modelName>:#instanceName %n1 %n2 [[C=<capacitance>]] [[Length=<length>]] [[Width=<width>]] [[InitCond=<initialVoltage>]] [[TC1=<tempCoef1>]] [[TC2=<tempCoef2>]] [[Temp=<temp>]] [[Tnom=<tnom>]] [[_M=<multiplicity>]]');

$D->netlistInstanceTemplate(ads, '<modelName>:#instanceName %nplus %nminus  [[Area=<area>]] [[Periph=<periphery>]] [[_M=<multiplicity>]] [[Temp=<temp>]] [[Tnom=<tnom>]]');

$I->netlistInstanceTemplate(ads, 'I_Source:#instanceName %nplus %nminus [[Idc=<Idc>]] [[I_Tran=<transientFunction>]] [[Iac=polar(<Iac_Mag>,<Iac_Phase>)]] ');
$I->parameterValue("Iac_Phase", 0);

$IPULSE->netlistInstanceTemplate(ads, 'I_Source:#instanceName %nplus %nminus I_Tran=pulse(time,[[<Ilow>]],[[<Ihigh>]],[[<delay>]],[[<rise>]],[[<fall>]],[[<width>]],[[<period>]])');

$ISIN->netlistInstanceTemplate(ads, 'I_Source:#instanceName %nplus %nminus I_Tran=damped_sin(time,[[<Idc>]],[[<amplitude>]],[[<freq>]],[[<delay>]],[[<damping>]],[[<phase>]])');

$INITCOND->netlistInstanceTemplate(ads, 'InitCond:#instanceName NodeName[1]="<node>" V[1]=<value>');

$J->netlistInstanceTemplate(ads, '<modelName>:#instanceName %nd %ng %ns [[Area=<area>]] [[Region=<region>]] [[_M=<multiplicity>]] [[Temp=<temp>]] [[Tnom=<tnom>]]');

$K->netlistInstanceTemplate(ads, 'Mutual:#instanceName K=<coupling> Inductor1=<inductor1> Inductor2=<inductor2> [[M=<mutualInductance>]]');

$L->netlistInstanceTemplate(ads, 'L:#instanceName %n1 %n2 L=<inductance> [[R=<resistance>]] [[Temp=<temp>]] [[Tnom=<tnom>]] [[TC1=<tempCoef1>]] [[TC2=<tempCoef2>]] [[InitCond=<initialCurrent>]] [[_M=<multiplicity>]]');

$LM->netlistInstanceTemplate(ads, '<modelName>:#instanceName %n1 %n2 [[L=<inductance>]] [[R=<resistance>]] [[Temp=<temp>]] [[Tnom=<tnom>]] [[TC1=<tempCoef1>]] [[TC2=<tempCoef2>]] [[InitCond=<initialCurrent>]] [[_M=<multiplicity>]]');

$M->netlistInstanceTemplate(ads, '<modelName>:#instanceName %nd %ng %ns %nb [[Length=<length>]] [[Width=<width>]] [[Ad=<drainDiffusionArea>]] [[As=<sourceDiffusionArea>]] [[Pd=<drainPerimeter>]] [[Ps=<sourcePerimeter>]] [[Nrd=<drainDiffusionSquares>]] [[Nrs=<sourceDiffusionSquares>]] [[Nqsmod=<nqsmod>]] [[Nf=<nf>]] [[Rgeomod=<Rgeomod>]] [[Geomod=<Geomod>]] [[Sa=<Sa>]] [[Sb=<Sb>]] [[Sd=<Sd>]] [[Temp=<temp>]] [[Tnom=<tnom>]] [[Region=<region>]] [[_M=<multiplicity>]]');

$PORT->netlistInstanceTemplate(ads, 'Port:#instanceName %nplus %nminus Num=<portNr> [[Vdc=<Vdc>]] [[Z=<referenceImpedance>]]');

$Q->netlistInstanceTemplate(ads, '<modelName>:#instanceName %nc %nb %ne %ns [[Area=<areaEmittor>]] [[Temp=<temp>]] [[Tnom=<tnom>]] [[Region=<region>]] [[_M=<multiplicity>]]');

$R->netlistInstanceTemplate(ads, 'R:#instanceName %n1 %n2 R=<resistance> [[Temp=<temp>]] [[Tnom=<tnom>]] [[TC1=<tempCoef1>]] [[TC2=<tempCoef2>]] [[Noise=<noise>]] [[M=<multiplicity>]]');

$RM->netlistInstanceTemplate(ads, '<modelName>:#instanceName %n1 %n2 [[R=<resistance>]] [[Rsh=<sheetResistance>]] [[Length=<length>]] [[Width=<width>]] [[Narrow=<narrow>]] [[Dw=<narrowWidth>]] [[Dl=<narrowLength>]] [[Temp=<temp>]] [[Tnom=<tnom>]] [[TC1=<tempCoef1>]] [[TC2=<tempCoef2>]] [[M=<multiplicity>]]');

$SHORT->netlistInstanceTemplate(ads, 'Short:#instanceName %n1 %n2 Mode=<mode>');

$V->netlistInstanceTemplate(ads, 'V_Source:#instanceName %nplus %nminus [[Vdc=<Vdc>]] [[V_Tran=<transientFunction>]] [[Vac=polar(<Vac_Mag>,<Vac_Phase>)]]');
$V->parameterValue("Vac_Phase", 0);

$VPULSE->netlistInstanceTemplate(ads, 'V_Source:#instanceName %nplus %nminus V_Tran=pulse(time,[[<Vlow>]],[[<Vhigh>]],[[<delay>]],[[<rise>]],[[<fall>]],[[<width>]],[[<period>]])');

$VSIN->netlistInstanceTemplate(ads, 'V_Source:#instanceName %nplus %nminus V_Tran=damped_sin(time,[[<Vdc>]],[[<amplitude>]],[[<freq>]],[[<delay>]],[[<damping>]],[[<phase>]])');

$Z->netlistInstanceTemplate(ads, '<modelName>:#instanceName %nd %ng %ns [[Area=<area>]] [[Region=<region>]]');

$T->netlistInstanceTemplate(ads, 'TLIN4:#instanceName %in %refin %out %refout [[Z=<Z0>]] [[F=<frequency>]] [[E=~eval(<electricalLength> * 360;)end]]');

### be sure to put my before variables !!!!!
#$T->netlistInstanceTemplate(ads, 'TLIN4:#instanceName %in %refin %out %refout [[Z=<Z0>]] [[F=<frequency>]] [[E=~eval(my $electricalLength = <electricalLength>; return $electricalLength * 360;)end]]');

#$U1->netlistInstanceTemplate(hspice, '#instanceName %in %refin %out %refout [[<uModelName>]] L=<length> [[LUMPS=<lumpedSections>]] ');

#$W1->netlistInstanceTemplate(hspice, '#instanceName %in %refin %out %refout N=1 L=<length> [[RLGCfile=<RLGCfileName>]] [[Umodel=<uModelName>]] [[FSmodel=<fsModelName>]] ');

### spectre

$Parameter->netlistInstanceTemplate(spectre, "parameters #instanceName=<value>");

$Temp->netlistInstanceTemplate(spectre, "#instanceName options temp=<temperature>");

$C->netlistInstanceTemplate(spectre, '#instanceName %n1 %n2 capacitor c=<capacitance> [[trise=<dtemp>]]  [[tc1=<tempCoef1>]] [[tc2=<tempCoef2>]] [[ic=<initialVoltage>]] [[m=<multiplicity>]]');

$CM->netlistInstanceTemplate(spectre, '#instanceName %n1 %n2 <modelName> [[c=<capacitance>]] [[w=<width>]] [[l=<length>]] [[trise=<dtemp>]]  [[tc1=<tempCoef1>]] [[tc2=<tempCoef2>]] [[ic=<initialVoltage>]] [[m=<multiplicity>]]');


$D->netlistInstanceTemplate(spectre, '#instanceName %nplus %nminus <modelName> [[area=<area>]] [[m=<multiplicity>]] [[region=<>]]');

$I->netlistInstanceTemplate(spectre, '#instanceName %nplus %nminus isource [[dc=<Idc>]] [[mag=<Iac_Mag> phase=<Iac_Phase>]] [[type=<type>]] [[<typeParams>]] [[m=<multiplicity>]]');
$I->parameterValue("Iac_Phase", 0);

$IPULSE->netlistInstanceTemplate(spectre, '#instanceName %nplus %nminus isource type=pulse [[val0=<Ilow>]] [[val1=<Ihigh>]] [[delay=<delay>]] [[rise=<rise>]] [[fall=<fall>]] [[width=<width>]] [[period=<period>]]');

$ISIN->netlistInstanceTemplate(spectre, '#instanceName %nplus %nminus isource type=sine [[sinedc=<Idc>]] [[ampl=<amplitude>]] [[freq=<freq>]] [[delay=<delay>]] [[sinephase=<phase>]] [[damp=<damping>]]');

$INITCOND->netlistInstanceTemplate(spectre, 'ic <node>=<value>');

$J->netlistInstanceTemplate(spectre, '#instanceName %nd %ng %ns <modelName> [[area=<area>]] [[region=<region>]] [[m=<multiplicity>]]');

$K->netlistInstanceTemplate(spectre, '#instanceName mutual_inductor coupling=<coupling> ind1=<inductor1> ind2=<inductor2>');

$L->netlistInstanceTemplate(spectre, '#instanceName %n1 %n2 inductor l=<inductance> [[R=<resistance>]] [[Temp=<temp>]] [[Tnom=<tnom>]] [[TC1=<tempCoef1>]] [[TC2=<tempCoef2>]] [[InitCond=<initialCurrent>]] [[m=<multiplicity>]]');

$LM->netlistInstanceTemplate(spectre, '#instanceName %n1 %n2 <modelName> [[l=<inductance>]] [[trise=<dtemp>]] [[ic=<initialCurrent>]] [[m=<multiplicity>]]');

$M->netlistInstanceTemplate(spectre, '#instanceName %nd %ng %ns %nb <modelName> [[l=<length>]] [[w=<width>]] [[m=<multiplicity>]] [[ad=<drainDiffusionArea>]] [[as=<sourceDiffusionArea>]] [[pd=<drainPerimeter>]] [[ps=<sourcePerimeter>]] [[nrd=<drainDiffusionSquares>]] [[nrs=<sourceDiffusionSquares>]] [[nqsmod=<nqsmod>]][[nf=<nf>]] [[rgeomod=<Rgeomod>]] [[geomod=<Geomod>]] [[sa=<Sa>]] [[sb=<Sb>]] [[sd=<Sd>]] [[trise=<dtemp>]] [[Region=<region>]]');

$PORT->netlistInstanceTemplate(spectre, '#instanceName %nplus %nminus port num=<portNr> [[dc=~eval(my $Vdc="<Vdc>"; if ($Vdc) {return $Vdc/2.0} else {return ""})end]] [[r=<referenceImpedance>]]');

$Q->netlistInstanceTemplate(spectre, '#instanceName %nc %nb %ne %ns <modelName> [[area=<areaEmittor>]] [[trise=<dtemp>]] [[region=<region>]] [[m=<multiplicity>]]');

$R->netlistInstanceTemplate(spectre, '#instanceName %n1 %n2 resistor r=<resistance> [[trise=<dtemp>]] [[tc1=<tempCoef1>]] [[tc2=<tempCoef2>]] [[isnoisy=<noise>]] [[m=<multiplicity>]]');

$RM->netlistInstanceTemplate(spectre, '#instanceName %n1 %n2 <modelName> [[r=<resistance>]] [[l=<length>]] [[w=<width>]] [[trise=<dtemp>]] [[tc1=<tempCoef1>]] [[tc2=<tempCoef2>]] [[isnoisy=<noise>]] [[m=<multiplicity>]]');

$V->netlistInstanceTemplate(spectre, '#instanceName %nplus %nminus vsource [[dc=<Vdc>]] [[mag=<Vac_Mag> phase=<Vac_Phase>]] [[type=<type>]] [[<typeParams>]] [[m=<multiplicity>]]');
$V->parameterValue("Vac_Phase", 0);

$VPULSE->netlistInstanceTemplate(spectre, '#instanceName %nplus %nminus vsource type=pulse [[val0=<Vlow>]] [[val1=<Vhigh>]] [[delay=<delay>]] [[rise=<rise>]] [[fall=<fall>]] [[width=<width>]] [[period=<period>]]');

$VSIN->netlistInstanceTemplate(spectre, '#instanceName %nplus %nminus vsource type=sine [[sinedc=<Vdc>]] [[ampl=<amplitude>]] [[freq=<freq>]] [[delay=<delay>]] [[sinephase=<phase>]] [[damp=<damping>]]');

$Z->netlistInstanceTemplate(spectre, '#instanceName %nd %ng %ns <modelName> [[area=<area>]] [[region=<region>]] [[m=<multiplicity>]]');

# $T->netlistInstanceTemplate(spectre, '#instanceName %in %refin %out %refout tline [[z0=<Z0>]] [[f=<frequency>]] [[nl=~eval(<electricalLength> * 360;)end]]');

### be sure to put my before variables !!!!!
$T->netlistInstanceTemplate(ads, 'TLIN4:#instanceName %in %refin %out %refout [[Z=<Z0>]] [[F=<frequency>]] [[E=~eval(my $electricalLength = <electricalLength>; return $electricalLength * 360;)end]]');

#$U1->netlistInstanceTemplate(hspice, '#instanceName %in %refin %out %refout [[<uModelName>]] L=<length> [[LUMPS=<lumpedSections>]] ');

#$W1->netlistInstanceTemplate(hspice, '#instanceName %in %refin %out %refout N=1 L=<length> [[RLGCfile=<RLGCfileName>]] [[Umodel=<uModelName>]] [[FSmodel=<fsModelName>]] ');


###############################################################################
#### define default Analysis 
####

$AC = dKitTemplate->new(AC);
$AC->description("small signal AC analysis");

$DC = dKitTemplate->new(DC);
$DC->description("DC analysis");

$NOISE = dKitTemplate->new(NOISE);
$NOISE->description("noise analysis");

$SP = dKitTemplate->new(SP);
$SP->description("S-Parameter analysis");

$SWEEP = dKitTemplate->new(SWEEP);
$SWEEP->description("sweep analysis");

$MONTE = dKitTemplate->new(MONTE);
$MONTE->description("Monte Carlo analysis");
$MONTE->addParameter('iterations');
$MONTE->addParameter('variations');

$TRAN = dKitTemplate->new(TRAN);
$TRAN->description("Transient analysis");
$TRAN->addParameter('useInitCondADS');
$TRAN->parameterValue('useInitCondADS','yes');

#hspice
$DC->netlistInstanceTemplate(hspice, '.DC #hspiceAnalysis');

$AC->netlistInstanceTemplate(hspice, '.AC #hspiceAnalysis');

$NOISE->netlistInstanceTemplate(hspice, '.AC #hspiceAnalysis');
$NOISE->addParameter(noiseReference);

$SP->netlistInstanceTemplate(hspice, '.AC #hspiceAnalysis');

$SWEEP->netlistInstanceTemplate(hspice, '#hspiceAnalysis');

$MONTE->netlistInstanceTemplate(hspice, '#hspiceAnalysis');

$TRAN->netlistInstanceTemplate(hspice, '[[.option IMAX=<maxIterations>
]]~eval(my $timeStepMethod="<timeStepMethod>"; if ($timeStepMethod eq "fixed") {return ".option FS=1 FT=1 DELMAX=<step> RMIN=<step> RMAX=1\n";}  elsif ($timeStepMethod eq "iteration") {return ".option itrprt LVLTIM=0\n";} else {return ".option itrprt LVLTIM=2\n";})end.TRAN <step> <stop> [[START=<start>]] #hspiceAnalysis');

#ads

#$DC->netlistInstanceTemplate(ads, 'DC:#instanceName SweepVar=~eval(my $device="<device>"; my $parameter="<parameter>"; if ($device) {return "\"$device.$parameter\"";} elsif ($parameter) {return "\"$parameter\"";} else {return "";})end #sweepPlanName #outputPlanName');

$DC->netlistInstanceTemplate(ads, 'DC:#instanceName SweepVar=~eval(my $device="<device>"; my $parameter="<parameter>"; (my $newParameter, my $newDevice) = dKitCircuit->current->getTranslatedParameterDevicePair("ads", $parameter, $device); if ($newDevice) {return "\"$newDevice.$newParameter\"";} elsif ($newParameter) {return "\"$newParameter\"";} else {return "";})end #sweepPlanName #outputPlanName');

#$AC->netlistInstanceTemplate(ads, 'AC:#instanceName SweepVar=~eval(my $device="<device>"; my $parameter="<parameter>"; if ($device) {return "\"$device.$parameter\"";} elsif ($parameter) {return "\"$parameter\"";} else {return "";})end [[Freq=<frequency>]] #sweepPlanName #outputPlanName');

$AC->netlistInstanceTemplate(ads, 'AC:#instanceName SweepVar=~eval(my $device="<device>"; my $parameter="<parameter>"; (my $newParameter, my $newDevice) = dKitCircuit->current->getTranslatedParameterDevicePair("ads", $parameter, $device); if ($newDevice) {return "\"$newDevice.$newParameter\"";} elsif ($newParameter) {return "\"$newParameter\"";} else {return "";})end  [[Freq=<frequency>]] #sweepPlanName #outputPlanName');

#$NOISE->netlistInstanceTemplate(ads, 'AC:#instanceName CalcNoise=yes NoiseNode[1]="<noiseNode>" SweepVar=~eval(my $device="<device>"; my $parameter="<parameter>"; if ($device) {return "\"$device.$parameter\"";} elsif ($parameter) {return "\"$parameter\"";} else {return "";})end [[Freq=<frequency>]] #sweepPlanName #outputPlanName_optional');

$NOISE->netlistInstanceTemplate(ads, 'AC:#instanceName CalcNoise=yes NoiseNode[1]="<noiseNode>" SweepVar=~eval(my $device="<device>"; my $parameter="<parameter>"; (my $newParameter, my $newDevice) = dKitCircuit->current->getTranslatedParameterDevicePair("ads", $parameter, $device); if ($newDevice) {return "\"$newDevice.$newParameter\"";} elsif ($newParameter) {return "\"$newParameter\"";} else {return "";})end  [[Freq=<frequency>]] #sweepPlanName #outputPlanName_optional');

#$SP->netlistInstanceTemplate(ads, 'S_Param:#instanceName SweepVar=~eval(my $device="<device>"; my $parameter="<parameter>"; if ($device) {return "\"$device.$parameter\"";} elsif ($parameter) {return "\"$parameter\"";} else {return "";})end  [[Freq=<frequency>]] #sweepPlanName');

$SP->netlistInstanceTemplate(ads, 'S_Param:#instanceName  SweepVar=~eval(my $device="<device>"; my $parameter="<parameter>"; (my $newParameter, my $newDevice) = dKitCircuit->current->getTranslatedParameterDevicePair("ads", $parameter, $device); if ($newDevice) {return "\"$newDevice.$newParameter\"";} elsif ($newParameter) {return "\"$newParameter\"";} else {return "";})end  [[Freq=<frequency>]] #sweepPlanName');

#$SWEEP->netlistInstanceTemplate(ads, 'ParamSweep:#instanceName SweepVar=~eval(my $device="<device>"; my $parameter="<parameter>"; if ($device) {return "\"$device.$parameter\"";} elsif ($parameter) {return "\"$parameter\"";} else {return "";})end #sweepPlanName #subAnalysisName');

$SWEEP->netlistInstanceTemplate(ads, 'ParamSweep:#instanceName  SweepVar=~eval(my $device="<device>"; my $parameter="<parameter>"; (my $newParameter, my $newDevice) = dKitCircuit->current->getTranslatedParameterDevicePair("ads", $parameter, $device); if ($newDevice) {return "\"$newDevice.$newParameter\"";} elsif ($newParameter) {return "\"$newParameter\"";} else {return "";})end #sweepPlanName #subAnalysisName');

$MONTE->netlistInstanceTemplate(ads, 'Yield:#instanceName NumIters=<iterations> SaveSolns=yes SaveRandVars=yes
YieldSpec:Spec1 SimInstanceName="Tran1" Min=0 Max=0 Expr="0" #subAnalysisName' );

$TRAN->netlistInstanceTemplate(ads, 'Tran:#instanceName [[StartTime=<start>]] StopTime=<stop> [[MaxTimeStep=<step>]] [[MaxIters=<maxIterations>]] [[UseInitCond=<useInitCondADS>]] TimeStepControl=~eval(my $timeStepMethod="<timeStepMethod>"; if ($timeStepMethod eq "fixed") {return "0";} elsif ($timeStepMethod eq "iteration") {return "1";} else {return "2";})end #outputPlanName_optional');

#spectre
#$AC->netlistInstanceTemplate(spectre, '#instanceName ac [[param=<parameter>]] [[dev=<device>]] [[freq=<frequency>]] #sweepPlanDef #outputPlanDef');

$AC->netlistInstanceTemplate(spectre, '~eval(my $device="<device>"; my $parameter="<parameter>"; my $frequency="<frequency>"; if ($frequency) {$frequency="freq=$frequency;"}; (my $newParameter, my $newDevice) = dKitCircuit->current->getTranslatedParameterDevicePair("spectre", $parameter, $device); if ($newDevice) {if (dKitCircuit->current->isSubcircuit($newDevice, "spectre")) { return "swp#instanceName sweep param=$newParameter sub=$newDevice #sweepPlanDef {\n#instanceName ac $frequency #outputPlanDef\n}";} else { return "#instanceName ac param=$newParameter dev=$newDevice $frequency #sweepPlanDef #outputPlanDef";}}elsif ($newParameter) {return "#instanceName ac param=$newParameter $frequency #sweepPlanDef #outputPlanDef"} else {return "";})end');

#$DC->netlistInstanceTemplate(spectre, '~eval(my $device="<device>"; my $parameter="<parameter>"; if ($device) {if (dKitInstance->isSubcircuit($device, "spectre")) { return "swp#instanceName sweep param=$parameter sub=$device #sweepPlanDef {\n#instanceName dc #outputPlanDef\n}"; } else { return "#instanceName dc param=$parameter dev=$device #sweepPlanDef #outputPlanDef";} } elsif ($parameter) {return "#instanceName dc param=$parameter #sweepPlanDef #outputPlanDef";} else {return "";})end');

$DC->netlistInstanceTemplate(spectre, '~eval(my $device="<device>"; my $parameter="<parameter>"; (my $newParameter, my $newDevice) = dKitCircuit->current->getTranslatedParameterDevicePair("spectre", $parameter, $device); if ($newDevice) {if (dKitCircuit->current->isSubcircuit($newDevice, "spectre")) { return "swp#instanceName sweep param=$newParameter sub=$newDevice #sweepPlanDef {\n#instanceName dc #outputPlanDef\n}";} else { return "#instanceName dc param=$newParameter dev=$newDevice #sweepPlanDef #outputPlanDef";}}elsif ($newParameter) {return "#instanceName dc param=$newParameter #sweepPlanDef #outputPlanDef;"} else {return "";})end');

#$NOISE->netlistInstanceTemplate(spectre, '#instanceName <noiseNode> 0 noise [[param=<parameter>]] [[dev=<device>]] [[freq=<frequency>]] #sweepPlanDef #outputPlanDef_optional');

$NOISE->netlistInstanceTemplate(spectre, '~eval(my $device="<device>"; my $parameter="<parameter>"; my $frequency="<frequency>"; my $noiseNode="<noiseNode>"; if ($noiseNode eq "") {return "";} if ($frequency) {$frequency="freq=$frequency";} (my $newParameter, my $newDevice) = dKitCircuit->current->getTranslatedParameterDevicePair("spectre", $parameter, $device); if ($newDevice) {if (dKitCircuit->current->isSubcircuit($newDevice, "spectre")) { return "swp#instanceName sweep param=$newParameter sub=$newDevice #sweepPlanDef {\n#instanceName $noiseNode 0 noise $frequency #outputPlanDef_optional\n}";} else { return "#instanceName $noiseNode 0 noise param=$newParameter dev=$newDevice $frequency #sweepPlanDef #outputPlanDef_optional";}}elsif ($newParameter) {return "#instanceName $noiseNode 0 noise param=$newParameter $frequency #sweepPlanDef #outputPlanDef_optional;"} else {return "";})end');


## the #allPortNameList directive is fix a bug in spectre s-param results

#$SP->netlistInstanceTemplate(spectre, '#instanceName sp [[param=<parameter>]] [[dev=<device>]] [[freq=<frequency>]] ports=[#allPortNameList] #sweepPlanDef');

$SP->netlistInstanceTemplate(spectre, '~eval(my $device="<device>"; my $parameter="<parameter>"; my $frequency="<frequency>"; if ($frequency) {$frequency="freq=$frequency";} (my $newParameter, my $newDevice) = dKitCircuit->current->getTranslatedParameterDevicePair("spectre", $parameter, $device); if ($newDevice) {if (dKitCircuit->current->isSubcircuit($newDevice, "spectre")) { return "swp#instanceName sweep param=$newParameter sub=$newDevice #sweepPlanDef {\n#instanceName sp $frequency ports=[#allPortNameList]\n}";} else { return "#instanceName sp param=$newParameter dev=$newDevice $frequency ports=[#allPortNameList] #sweepPlanDef";}}elsif ($newParameter) {return "#instanceName sp param=$newParameter $frequency ports=[#allPortNameList] #sweepPlanDef;"} else {return "";})end');

#$SWEEP->netlistInstanceTemplate(spectre, '#instanceName sweep [[param=<parameter>]] [[dev=<device>]] #sweepPlanDef {
#subAnalysisDef}');

$SWEEP->netlistInstanceTemplate(spectre, '~eval(my $device="<device>"; my $parameter="<parameter>"; (my $newParameter, my $newDevice) = dKitCircuit->current->getTranslatedParameterDevicePair("spectre", $parameter, $device); if ($newDevice) {if (dKitCircuit->current->isSubcircuit($newDevice, "spectre")) { return "#instanceName sweep param=$newParameter sub=$newDevice #sweepPlanDef {\n#subAnalysisDef}";} else { return "#instanceName sweep param=$newParameter dev=$newDevice #sweepPlanDef {\n#subAnalysisDef}";}}elsif ($newParameter) {return "#instanceName sweep param=$newParameter #sweepPlanDef {\n#subAnalysisDef};"} else {return "";})end');


$MONTE->netlistInstanceTemplate(spectre, '#instanceName montecarlo processparamfile="monteCarloParam" processscalarfile="monteCarloData" donominal=yes seed=1 savefamilyplots=yes numruns=<iterations> saveprocessparams=yes variations=<variations> {
#subAnalysisDef }' );

$TRAN->netlistInstanceTemplate(spectre, '#instanceName tran [[start=<start>]] stop=<stop> [[maxstep=<step>]] [[maxiters=<maxIterations>]] [[~eval(my $timeStepMethod="<timeStepMethod>"; if ($timeStepMethod eq "fixed") {return "strobeperiod=<step>";} elsif ($timeStepMethod eq "iteration") {print "NOTE: Spectre does not support iteration count timestep method.  Using the default local truncation error method for Spectre.\n"; return " ";})end]] #outputPlanDef_optional');


##############################################################################
#### sweepplans
####

$LINSWEEPPLAN = dKitTemplate->new(SWEEPPLAN_LIN);
$LINSWEEPPLAN->description("linear sweep plan");

$PTSWEEPPLAN = dKitTemplate->new(SWEEPPLAN_PT);
$PTSWEEPPLAN->description("sweep plan consisting out of descrete points");

#hspice
$LINSWEEPPLAN->netlistInstanceTemplate(hspice, '~eval(my $numPts="<numPts>"; my $step="<step>"; my $offset="<hspiceOffset>"; my $scale="<hspiceScale>"; if ($offset eq "") {$offset=0}; if ($scale eq "") {$scale=1}; my $stop = <stop> * $scale + $offset; my $start = <start> * $scale + $offset;if ($start > $stop) {my $tempStart=$start;$start=$stop;$stop=$tempStart;} if ($numPts ne "") {return "LIN <numPts> $start $stop";} elsif ($step ne "") {$step = $step * $scale; return "START=$start STOP=$stop STEP=$step"} else {return "";})end');

$PTSWEEPPLAN->netlistInstanceTemplate(hspice, '~eval(my $line="POI ";my @values=split(/\s/, "<values>"); $line.=$#values + 1;my $offset="<hspiceOffset>"; my $scale="<hspiceScale>"; if ($offset eq "") {$offset=0}; if ($scale eq "") {$scale=1}; foreach my $value (@values) {$value = $value*$scale+$offset; $line = $line . " $value";}; return $line;)end');

#ads
$LINSWEEPPLAN->netlistInstanceTemplate(ads, 'SweepPlan:#instanceName ~eval(my $numPts="<numPts>"; my $step="<step>"; my $offset="<adsOffset>"; my $scale="<adsScale>"; if ($offset eq "") {$offset=0}; if ($scale eq "") {$scale=1}; my $stop = <stop>*$scale+$offset; my $start = <start>*$scale+$offset;if ($start > $stop) {my $tempStart=$start;$start=$stop;$stop=$tempStart;} if ($numPts ne "") {return "Start=$start Stop=$stop Lin=$numPts";} elsif ($step ne "") {$step = $step * $scale; return "Start=$start Stop=$stop Step=$step";} else {return "";})end');

$PTSWEEPPLAN->netlistInstanceTemplate(ads, 'SweepPlan:#instanceName ~eval(my $line = ""; my @values= split(/\s/, "<values>"); my $offset="<adsOffset>"; my $scale="<adsScale>"; if ($offset eq "") {$offset=0}; if ($scale eq "") {$scale=1}; foreach my $value (@values) {$value = $value*$scale+$offset; $line = $line . "Pt=$value ";}; return $line;)end');

#spectre
$LINSWEEPPLAN->netlistInstanceTemplate(spectre, '~eval(my $numPts="<numPts>"; my $step="<step>"; my $offset="<spectreOffset>"; my $scale="<spectreScale>"; if ($offset eq "") {$offset=0}; if ($scale eq "") {$scale=1}; my $stop = <stop>*$scale+$offset; my $start = <start>*$scale+$offset;if ($start > $stop) {my $tempStart=$start;$start=$stop;$stop=$tempStart;} if ($numPts ne "") {$numPts=$numPts-1; return "start=$start stop=$stop lin=$numPts";} elsif ($step ne "") {$step = $step * $scale; return "start=$start stop=$stop step=$step";} else {return "";})end');

$PTSWEEPPLAN->netlistInstanceTemplate(spectre, '~eval(my $line="values=["; my @values=split(/\s/, "<values>"); my $offset="<spectreOffset>"; my $scale="<spectreScale>"; if ($offset eq "") {$offset=0}; if ($scale eq "") {$scale=1}; foreach my $value (@values) {$value = $value*$scale+$offset; $line = $line . "$value ";};  $line = $line . "]" ; return $line;)end');


##############################################################################
#### outputplans
####

$OUTPUTNODEPLAN = dKitTemplate->new(OUTPUTPLAN_NODES);
$OUTPUTNODEPLAN->description("default outputplan for nodes. Format: List of Nodenames");

$OUTPUTCURRENTPLAN = dKitTemplate->new(OUTPUTPLAN_CURRENTS);
$OUTPUTCURRENTPLAN->description("default outputplan for device currents. Format: List of device:terminal");

$OUTPUTDOPPLAN = dKitTemplate->new(OUTPUTPLAN_DOPS);
$OUTPUTDOPPLAN->description("default outputplan for device operating points. Format: List of device:parameter");

#hspice
$OUTPUTNODEPLAN->netlistInstanceTemplate(hspice, q{.PRINT <analysisType> ~eval(my $line = ""; my @values= split(/\s/, "<nodes>"); foreach my $value (@values) {if ("<analysisType>" eq "AC") {$line = $line . "vr($value) vi($value) ";} else {$line = $line . "v($value) ";}}; return $line; )end});

$OUTPUTCURRENTPLAN->netlistInstanceTemplate(hspice, q{.PRINT <analysisType> ~eval(my $line = ""; my @values= split(/\s/, "<deviceTerminals>"); foreach my $value (@values) { (my $device, my $terminal) = split(":", $value); if ("<analysisType>" eq "AC") {$line = $line . "ir$terminal($device) ii$terminal($device) ";} else {$line = $line . "i$terminal($device) ";}}; return $line; )end});

$OUTPUTDOPPLAN->netlistInstanceTemplate(hspice, q{.PRINT <analysisType> ~eval(my @values = split(/\s/, "<deviceParameters>"); my $line = "";  foreach my $value (@values) { my @fragments = split(/\:/, $value);  my $parameter = pop(@fragments); my $newparameter = dKitParameter->dKit2dialect($parameter, "hspice"); if ($#fragments > -1) { my $device = join(".", @fragments); $newparameter =~ s/ofdevice/($device)/g; $line = $line . "$device" . "_" . dKitParameter->dKit2result($parameter) . "=par('" . $newparameter . "') "; } else { $newparameter =~ s/ofdevice//g; $line = $line . $newparameter . " "; }} return $line; )end});



#ads

$OUTPUTNODEPLAN->netlistInstanceTemplate(ads, 'OutputPlan:#instanceName UseNodeNestLevel=no ~eval(my $line = ""; my $index = 1; my @values= split(/\s/, "<nodes>"); foreach my $value (@values) {$line = $line . "NodeName[$index]=\"$value\" "; $index = $index + 1;}; return $line; )end');

### there is no way to select currents
$OUTPUTCURRENTPLAN->netlistInstanceTemplate(ads, '');

### there is no way to select device operating points
$OUTPUTDOPPLAN->netlistInstanceTemplate(ads, '');


#spectre

$OUTPUTNODEPLAN->netlistInstanceTemplate(spectre, 'save <nodes>');
$OUTPUTCURRENTPLAN->netlistInstanceTemplate(spectre, 'save <deviceTerminals>');
$OUTPUTDOPPLAN->netlistInstanceTemplate(spectre, 'save ~eval(my @values = split(/\s/, "<deviceParameters>"); my $line = "";  foreach my $value (@values) { my @fragments = split(/\:/, $value); my $parameter = pop(@fragments); $parameter = dKitParameter->dKit2dialect($parameter, "spectre"); if ($#fragments > -1) {  $line = $line . join(".", @fragments) . ":"; } $line = $line . $parameter . " "; } return $line; )end');


##############################################################################
####  simulator options
####

$SIMULATOROPTION = dKitTemplate->new(SIMULATOROPTION);
$SIMULATOROPTION->description("circuit options");

#hspice
$SIMULATOROPTION->netlistInstanceTemplate(hspice, '[[.option <hspiceOptions>]]');

#ads
$SIMULATOROPTION->netlistInstanceTemplate(ads, '[[Options <adsOptions>]]');

#spectre
$SIMULATOROPTION->netlistInstanceTemplate(spectre, '[[#instanceName options <spectreOptions>]]');


##############################################################################
####  modellibrary
####

$MODELLIBRARY = dKitTemplate->new(MODELLIBRARY);
$MODELLIBRARY->description("includes one modellibrary");

#hspice
$MODELLIBRARY->netlistInstanceTemplate(hspice, '[[~eval(my $library="<hspiceModelLibrary>"; my $section="<hspiceSectionName>"; if ($section) {return ".lib \"$library\" $section";} elsif ($library) {return ".include \"$library\"";})end]]');

#ads
$MODELLIBRARY->netlistInstanceTemplate(ads, '[[#define <adsSectionName> <adsSectionName>
]][[#include "<adsModelLibrary>"]][[
#undef <adsSectionName>]]');

#spectre
$MODELLIBRARY->netlistInstanceTemplate(spectre, '[[include "<spectreModelLibrary>"]] [[section=<spectreSectionName>]]');


##############################################################################
####  circuit related templates
####

$CIRCUITDEFAULTSIMULATOROPTIONS = dKitTemplate->new(CIRCUITDEFAULTSIMULATOROPTIONS);
$CIRCUITDEFAULTSIMULATOROPTIONS->description("default circuit options, will be used if no other options are defined");

$CIRCUITREQUIREDSIMULATOROPTIONS = dKitTemplate->new(CIRCUITREQUIREDSIMULATOROPTIONS);
$CIRCUITREQUIREDSIMULATOROPTIONS->description("required circuit options, will allways be present");

$CIRCUITNETLISTNAME = dKitTemplate->new(CIRCUITNETLISTNAME);
$CIRCUITNETLISTNAME->description("netlistnames for the different simulators");

$CIRCUITINVOKECOMMAND = dKitTemplate->new(CIRCUITINVOKECOMMAND);
$CIRCUITINVOKECOMMAND->description("command to invoke the simulator");

$CIRCUITSTARTDECKCARD = dKitTemplate->new(CIRCUITSTARTDECKCARD);
$CIRCUITSTARTDECKCARD->description("if defined, added as first card of the deck");

$CIRCUITENDDECKCARD = dKitTemplate->new(CIRCUITENDDECKCARD);
$CIRCUITENDDECKCARD->description("if defined, added as last card of the deck");

#hspice

$CIRCUITDEFAULTSIMULATOROPTIONS->netlistInstanceTemplate(hspice, 
'.option ingold=2 numdgt=10 acct=0 dccap=1
.option abstol=1e-8 reltol=1e-5 absvdc=1e-7');

$CIRCUITREQUIREDSIMULATOROPTIONS->netlistInstanceTemplate(hspice, 
'.option ingold=2');

$CIRCUITNETLISTNAME->netlistInstanceTemplate(hspice, '<projectName><hspiceNetlistSuffix>');
$CIRCUITNETLISTNAME->parameterValue('hspiceNetlistSuffix', '.hsp');

$CIRCUITINVOKECOMMAND->netlistInstanceTemplate(hspice, 'dKitRunHspice [[<cleanup>]] [[<netlistFilename>]]');

$CIRCUITSTARTDECKCARD->netlistInstanceTemplate(hspice, '[[<hspiceStartDeckcard>]]');

$CIRCUITENDDECKCARD->netlistInstanceTemplate(hspice, '[[<hspiceEndDeckcard>]]');
$CIRCUITENDDECKCARD->parameterValue('hspiceEndDeckcard', '.end');


#ads

$CIRCUITDEFAULTSIMULATOROPTIONS->netlistInstanceTemplate(ads, 
'Options ResourceUsage=yes UseNutmegFormat=no ASCII_Rawfile=yes
Options I_AbsTol=1e-8 V_AbsTol=1e-8 I_RelTol=1e-5 V_RelTol=1e-5');

$CIRCUITREQUIREDSIMULATOROPTIONS->netlistInstanceTemplate(ads, 
'Options UseNutmegFormat=no ASCII_Rawfile=yes');

$CIRCUITNETLISTNAME->netlistInstanceTemplate(ads, '<projectName><adsNetlistSuffix>');
$CIRCUITNETLISTNAME->parameterValue('adsNetlistSuffix', '.ckt');

$CIRCUITINVOKECOMMAND->netlistInstanceTemplate(ads, 'dKitRunADSsim [[<cleanup>]] [[<netlistFilename>]]');


$CIRCUITSTARTDECKCARD->netlistInstanceTemplate(ads, '[[<adsStartDeckcard>]]');

$CIRCUITENDDECKCARD->netlistInstanceTemplate(ads, '[[<adsEndDeckcard>]]');


#spectre

$CIRCUITDEFAULTSIMULATOROPTIONS->netlistInstanceTemplate(spectre, 
'myDefaultOptions options save=allpub rawfmt=psfascii');

$CIRCUITREQUIREDSIMULATOROPTIONS->netlistInstanceTemplate(spectre, 
'myRequiredOptions options rawfmt=psfascii');

$CIRCUITNETLISTNAME->netlistInstanceTemplate(spectre, '<projectName><spectreNetlistSuffix>');
$CIRCUITNETLISTNAME->parameterValue('spectreNetlistSuffix', '.scs');

$CIRCUITINVOKECOMMAND->netlistInstanceTemplate(spectre, 'dKitRunSpectre [[<cleanup>]] [[<netlistFilename>]]');

$CIRCUITSTARTDECKCARD->netlistInstanceTemplate(spectre, '[[<spectreStartDeckCard>]]');
$CIRCUITSTARTDECKCARD->parameterValue('spectreStartDeckCard', 'simulator lang=spectre');

$CIRCUITENDDECKCARD->netlistInstanceTemplate(spectre, '[[<spectreEndDeckcard>]]');


### create the dKitTemplateDB.pl file

dKitTemplate->createTemplateDatabaseFile;

1

