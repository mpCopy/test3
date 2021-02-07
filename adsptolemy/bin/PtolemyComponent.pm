package PtolemyComponent;

use strict;
use Carp;
use Class::Struct;

use PtolemyParameter;
use PtolemyEnum;
use PtolemyPort;

%PtolemyComponent::symbolNameMap = (
	"Abs_M" => "SYM_Abs",
	"AbsSyn" => "SYM_Abs",
	"Add_M" => "SYM_Add",
	"AddCx_M" => "SYM_Add",
	"AddCx" => "SYM_Add",
	"AverageCx" => "SYM_Average",
	"BiquadCascade" => "SYM_Biquad",
	"ConvolveCx" => "SYM_Convolve",
	"Delay_M" => "SYM_Delay",
	"DiagonalCx_M" => "SYM_Diagonal_M",
	"FIR_Cx" => "SYM_FIR",
	"FixedGainSyn" => "SYM_Gain",
	"FixToFloatSyn" => "SYM_Convert",
	"FloatToFixSyn" => "SYM_Convert",
	"Gain_M" => "SYM_Gain",
	"GainCx" => "SYM_Gain",
	"GainCx_M" => "SYM_Gain",
	"GainSyn" => "SYM_Gain",
	"GaussianNoiseGen" => "SYM_IID_Gaussian",
	"IdentityCx_M" => "SYM_Identity_M",
	"IIR_Cx" => "SYM_IIR",
	"InitDelay" => "SYM_Delay",
	"InverseCx_M" => "SYM_Inverse_M",
	"LMS_Cx" => "SYM_LMS",
	"LMS_CxTkPlot" => "SYM_LMS",
	"LMS_TkPlot" => "SYM_LMS",
	"LPF_Bessel" => "SYM_LPF",
	"LPF_Butterworth" => "SYM_LPF",
	"LPF_Chebyshev" => "SYM_LPF",
	"LPF_Elliptic" => "SYM_LPF",
	"LPF_Gaussian" => "SYM_LPF",
	"LPF_RaisedCosine" => "SYM_LPF",
	"BPF_Bessel" => "SYM_BPF",
	"BPF_Butterworth" => "SYM_BPF",
	"BPF_Chebyshev" => "SYM_BPF",
	"BPF_Elliptic" => "SYM_BPF",
	"BPF_Gaussian" => "SYM_BPF",
	"BPF_RaisedCosine" => "SYM_BPF",
	"MathCx" => "SYM_Math",
	"Matlab_M" => "SYM_Matlab",
	"MATLAB_Cosim" => "SYM_Matlab",
	"MatlabF_M" => "SYM_Matlab",
	"MatlabFCx_M" => "SYM_Matlab",
	"MatlabSinkF" => "SYM_MatlabSink",
	"MpyCx" => "SYM_Mpy",
	"MpyCx_M" => "SYM_Mpy_M",
	"MpyScalarCx_M" => "SYM_MpyScalar_M",
	"PackCx_M" => "SYM_Pack_M",
	"Printer" => "SYM_Printer",
	"Sink" => "SYM_Sink",
	"Sub_M" => "SYM_Sub",
	"SubCx" => "SYM_Sub",
	"SubCx_M" => "SYM_Sub",
	"SubMxCx_M" => "SYM_SubMx_M",
	"Table_M" => "SYM_Table",
	"TableCx" => "SYM_Table",
	"TableCx_M" => "SYM_Table",
	"TimedSink" => "SYM_NumericSink",
	"ToeplitzCx_M" => "SYM_Toeplitz_M",
	"TransposeCx_M" => "SYM_Transpose_M",
	"Trig" => "SYM_Trig",
	"TrigCx" => "SYM_Trig",
	"UnPkCx_M" => "SYM_UnPk_M",
	"WaveFormCx" => "SYM_WaveForm",
	"MathLang" => "SYM_Matlab",
	"Probe" => "SYM_Const"
);


############################################################################
#
# The following definition will automatically create (through the use of the 
# Class:Struct module) a PtolemyComponent class with 
#
# scalar members: name, model_type, description, instance_name,
#                 library, domain, pde_symbol, pde_bitmap
#
# array members:  parameters, inputs, outputs
#
# It will also create methods to access and set the above members. 
# These methods have the same name as the member they access/set. For example, 
# methods called name, model_type, description, etc. are created. If no 
# arguments are passed to these methods they return the value of the member 
# (a reference to the array for the array members). If an argument is passed 
# to them, they set the value of the member. Setting elements of the arrays 
# requires that the index of the array element is also passed. This is not user 
# friendly, so add methods were created and they are the ones that should be 
# used to add elements in the parameters, inputs, and outputs arrays. 
# Retrieving the elements of an array is also a little user unfriendly, so 
# iterators were created that help you iterate over all the elements in the 
# arrays.
#
############################################################################

struct PtolemyComponent => {
	name          => '$',
	model_type    => '$',
	description   => '$',
	instance_name => '$',
	library       => '$',
	domain        => '$',
	netlist_name  => '$',
	pde_symbol    => '$',
	pde_bitmap    => '$',
	parameters    => '@',
	inputs        => '@',
	outputs       => '@',
};


############################################################################
#
# Adds a parameter to the parameters array.
# Takes a PtolemyParameter reference as an argument.
#
############################################################################

sub PtolemyComponent::addParameter {
	my $self = shift;
	my $paramRef = shift;
	if ( ref( $paramRef ) && ref( $paramRef ) eq "PtolemyParameter" ) {
		push @{$self->parameters()}, $paramRef;
	}
	else {
		croak "Argument to PtolemyComponent::addParameter must be a reference to PtolemyParameter.\n";
	}
}


############################################################################
#
# Adds an input port to the inputs array.
# Takes a PtolemyPort reference as an argument.
#
############################################################################

sub PtolemyComponent::addInput {
	my $self = shift;
	my $inRef = shift;
	if ( ref( $inRef ) && ref( $inRef ) eq "PtolemyPort" ) {
		push @{$self->inputs()}, $inRef;
	}
	else {
		croak "Argument to PtolemyComponent::addInput must be a reference to PtolemyPort.\n";
	}
}


############################################################################
#
# Adds an output port to the outputs array.
# Takes a PtolemyPort reference as an argument.
#
############################################################################

sub PtolemyComponent::addOutput {
	my $self = shift;
	my $outRef = shift;
	if ( ref( $outRef ) && ref( $outRef ) eq "PtolemyPort" ) {
		push @{$self->outputs()}, $outRef;
	}
	else {
		croak "Argument to PtolemyComponent::addOutput must be a reference to PtolemyPort.\n";
	}
}


############################################################################
#
# Returns the number of parameters.
#
############################################################################

sub PtolemyComponent::getParameterNumber {
	my $self = shift;
	return $#{$self->parameters()} + 1;
}


############################################################################
#
# Returns the number of input ports.
#
############################################################################

sub PtolemyComponent::getInputPortNumber {
	my $self = shift;
	return $#{$self->inputs()} + 1;
}


############################################################################
#
# Returns the number of output ports.
#
############################################################################

sub PtolemyComponent::getOutputPortNumber {
	my $self = shift;
	return $#{$self->outputs()} + 1;
}


############################################################################
#
# Returns an iterator for the parameters.
# The use of the iterator is different from C++.
# Here is an example. Assume $xyz is a PtolemyComponent.
#
# my $nextParameter = $xyz->getParameterIterator();
#
# while ( my $parameter = $nextParameter->() ) {
#    ...
# }
#
############################################################################

sub PtolemyComponent::getParameterIterator {
	my $self = shift;
	my $index = -1;
	return sub {
		$index++;
		if ( $index > $#{$self->parameters()} ) {
			$index--;     # to avoid possible wrap around if called many times
			return undef;
		}
		else {
			return $self->parameters()->[$index];
		}
	}
}


############################################################################
#
# Returns an iterator for the inputs.
# The use of the iterator is different from C++.
# Here is an example. Assume $xyz is a PtolemyComponent.
#
# my $nextInputPort = $xyz->getInputPortIterator();
#
# while ( my $port = $nextInputPort->() ) {
#    ...
# }
#
############################################################################

sub PtolemyComponent::getInputPortIterator {
	my $self = shift;
	my $index = -1;
	return sub {
		$index++;
		if ( $index > $#{$self->inputs()} ) {
			$index--;     # to avoid possible wrap around if called many times
			return undef;
		}
		else {
			return $self->inputs()->[$index];
		}
	}
}


############################################################################
#
# Returns an iterator for the outputs.
# The use of the iterator is different from C++.
# Here is an example. Assume $xyz is a PtolemyComponent.
#
# my $nextOutputPort = $xyz->getOutputPortIterator();
#
# while ( my $port = $nextOutputPort->() ) {
#    ...
# }
#
############################################################################

sub PtolemyComponent::getOutputPortIterator {
	my $self = shift;
	my $index = -1;
	return sub {
		$index++;
		if ( $index > $#{$self->outputs()} ) {
			$index--;     # to avoid possible wrap around if called many times
			return undef;
		}
		else {
			return $self->outputs()->[$index];
		}
	}
}


############################################################################
#
# Returns an iterator for the ports (inputs first, outputs next).
# The use of the iterator is different from C++.
# Here is an example. Assume $xyz is a PtolemyComponent.
#
# my $nextPort = $xyz->getPortIterator();
#
# while ( my $port = $nextPort->() ) {
#    ...
# }
#
############################################################################

sub PtolemyComponent::getPortIterator {
	my $self = shift;
	my $index = -1;
	my $numIns = $#{$self->inputs()} + 1;
	my $numOuts = $#{$self->outputs()} + 1;
	return sub {
		$index++;
		if ( $index < $numIns ) {
			return $self->inputs()->[$index];
		}
		elsif ( $index < $numIns + $numOuts ) {
			return $self->outputs()->[$index - $numIns];
		}
		else {
			$index--;     # to avoid possible wrap around if called many times
			return undef;
		}
	}
}


############################################################################
#
# Prints the information stored in the PtolemyComponent object.
# This is mainly used for debugging purposes.
#
############################################################################

sub PtolemyComponent::printInfo {

	my $self = shift;

	my $info = "";

	$info .= "NAME = " . $self->name() . "\n";
	$info .= "DESCRIPTION = " . $self->description() . "\n";
	$info .= "INSTANCE_NAME = " . $self->instance_name() . "\n";
	$info .= "LIBRARY = " . $self->library() . "\n";
	$info .= "DOMAIN = " . $self->domain() . "\n";
	$info .= "PDE_SYMBOL = " . $self->pde_symbol() . "\n";
	$info .= "PDE_BITMAP = " . $self->pde_bitmap() . "\n";

	$info .= "PARAMETERS = " . $self->getParameterNumber() . "\n";

	my $nextParameter = $self->getParameterIterator();

	while ( my $parameter = $nextParameter->() ) {

		$info .= "\tNAME = " . $parameter->name() . "\n";
		$info .= "\tTYPE = " . $parameter->type() . "\n";
		$info .= "\tDESCRIPTION = " . $parameter->description() . "\n";
		$info .= "\tDEFAULT = " . $parameter->default() . "\n";
		$info .= "\tUNIT = " . $parameter->unit() . "\n";

		$info .= "\tATTRIBUTES = ";

		my $nextAttribute = $parameter->getAttributeIterator();

		while ( my $attribute = $nextAttribute->() ) {
			$info .= $attribute . ", ";
		}

		$info .= "\n\tFILE_EXTENSIONS = ";

		my $nextFileExt = $parameter->getFileExtensionIterator();

		while ( my $fileExt = $nextFileExt->() ) {
			$info .= $fileExt . ", ";
		}

		$info .= "\n\tENUMS = ";

		my $nextEnum = $parameter->getEnumIterator();

		while ( my $enum = $nextEnum->() ) {
			$info .= "\n\t\talias = " . $enum->alias() . ", ";
			$info .= "abbreviation = " . $enum->abbreviation() . ", ";
			$info .= "value = " . $enum->value();
		}

		$info .= "\n\n";
	}

	$info .= "INPUTS = " . $self->getInputPortNumber() . "\n";

	my $nextInPort = $self->getInputPortIterator();

	while ( my $inPort = $nextInPort->() ) {
		$info .= "\tpin no = " . $inPort->pin_no() . "\n";
		$info .= "\tname = " . $inPort->name() . "\n";
		$info .= "\ttype = " . $inPort->type() . "\n";
		$info .= "\tdescription = " . $inPort->description() . "\n\n";
	}

	
	$info .= "OUTPUTS = " . $self->getOutputPortNumber() . "\n";

	my $nextOutPort = $self->getOutputPortIterator();

	while ( my $outPort = $nextOutPort->() ) {
		$info .= "\tpin no = " . $outPort->pin_no() . "\n";
		$info .= "\tname = " . $outPort->name() . "\n";
		$info .= "\ttype = " . $outPort->type() . "\n";
		$info .= "\tdescription = " . $outPort->description() . "\n\n";
	}

	$info .= "PORTS = \n";

	my $nextPort = $self->getPortIterator();

	while ( my $port = $nextPort->() ) {
		$info .= "\tpin no = " . $port->pin_no() . "\n";
		$info .= "\tname = " . $port->name() . "\n";
		$info .= "\ttype = " . $port->type() . "\n";
		$info .= "\tdescription = " . $port->description() . "\n\n";
	}

	$info .= "\n";

	print $info;
}


############################################################################
#
# Prints the information stored in the PtolemyComponent object in the form of 
# a pl file. This is experimental code and should not be used.
#
############################################################################

sub PtolemyComponent::printPL {

	my $self = shift;

	my $pl = "";

	$pl .= "defstar {\n";
	$pl .= "\tname { " . $self->name() . " }\n";
	$pl .= "\tdomain { " . $self->domain() . " }\n";
	$pl .= "\tdesc {" . $self->description() . " }\n";
	$pl .= "\tlocation { " . $self->library() . " }\n\n";

	my $nextParameter = $self->getParameterIterator();

	while ( my $parameter = $nextParameter->() ) {

		$pl .= "\tdefstate {\n";
		$pl .= "\t\tname { " . $parameter->name() . " }\n";
		$pl .= "\t\ttype { " . $parameter->type() . " }\n";
		$pl .= "\t\tdesc { " . $parameter->description() . " }\n";
		$pl .= "\t\tdefault { " . $parameter->default() . " }\n";
		$pl .= "\t\tunit { " . $parameter->getPDE_Unit() . " }\n";

		my $attrCounter = 0;

		my $nextAttribute = $parameter->getAttributeIterator();

		while ( my $attribute = $nextAttribute->() ) {
			$attrCounter++;
			if ( $attrCounter == 1 ) {
				$pl .= "\t\tattributes { " . $attribute;
			}
			else {
				$pl .= " | " . $attribute;
			}
		}

		if ( $attrCounter > 0 ) {
			$pl .= " }\n";
		}

		my $fileExtCounter = 0;

		my $nextFileExt = $parameter->getFileExtensionIterator();

		while ( my $fileExt = $nextFileExt->() ) {
			$fileExtCounter++;
			if ( $fileExtCounter == 1 ) {
				$pl .= "\t\textensions { " . $fileExt;
			}
			else {
				$pl .= ", " . $fileExt;
			}
		}

		if ( $fileExtCounter > 0 ) {
			$pl .= " }\n";
		}

		my $enumCounter = 0;
		my $enumList = "";
		my $enumLabels = "";
		my $enumValues = "";

		my $nextEnum = $parameter->getEnumIterator();

		while ( my $enum = $nextEnum->() ) {
			$enumCounter++;
			if ( $enumCounter == 1 ) {
				$enumList = "\t\tenumlist { " . $enum->alias();
				$enumLabels = "\t\tenumlabels { " . $enum->abbreviation();
				$enumValues = "\t\tenumValues { " . $enum->value();
			}
			else {
				$enumList .= ", " . $enum->alias();
				$enumLabels .= ", " . $enum->abbreviation();
				$enumValues .= ", " . $enum->value();
			}
		}

		if ( $enumCounter > 0 ) {
			$pl .= $enumList . " }\n";
			$pl .= $enumLabels . " }\n";
			$pl .= $enumValues . " }\n";
		}
		$pl .= "\t}\n\n";
	}

	my $nextInPort = $self->getInputPortIterator();

	while ( my $inPort = $nextInPort->() ) {
		$pl .= "\tinput {\n";
		$pl .= "\t\tname { " . $inPort->name() . " }\n";
		$pl .= "\t\ttype { " . $inPort->type() . " }\n";
		$pl .= "\t\tdesc { " . $inPort->description() . " }\n";
		$pl .= "\t}\n\n";
	}

	my $nextOutPort = $self->getOutputPortIterator();

	while ( my $outPort = $nextOutPort->() ) {
		$pl .= "\toutput {\n";
		$pl .= "\t\tname { " . $outPort->name() . " }\n";
		$pl .= "\t\ttype { " . $outPort->type() . " }\n";
		$pl .= "\t\tdesc { " . $outPort->description() . " }\n";
		$pl .= "\t}\n\n";
	}

	$pl .= "}\n\n";

	print $pl;
}


############################################################################
#
# Mangle string (strip off leading and trailing spaces and 
# replace all non-alphanumeric characters with _x5f)
#
############################################################################

sub PtolemyComponent::mangleString {
	my $self = shift;
	my $str = shift;
	$str =~ s/^ +//;
	$str =~ s/ +$//;
	$str =~ s/[^a-zA-Z0-9]/_x5f/g;
	return $str;
}


############################################################################
#
# Another mangling function (strip off leading and trailing spaces and 
# replace all non-alphanumeric characters with _)
#
############################################################################

sub PtolemyComponent::mangleString2 {
	my $self = shift;
	my $str = shift;
	$str =~ s/^ +//;
	$str =~ s/ +$//;
	$str =~ s/[^a-zA-Z0-9]/_/g;
	return $str;
}


############################################################################
#
# Convert description string to conform to PDE limitations.
# Replace "\n" with space.
# Truncate string at first full stop ('.' must be at the end of the 
# string or followed by a space).
# String is limited to 150 characters.
#
############################################################################

sub PtolemyComponent::convertDescription {

	my $maxDescLen = 150;
	my $pressHelpString = "...(Press Help for more info)";
	my $trunDescLen = $maxDescLen - length( $pressHelpString );

	my $self = shift;
	my $desc = shift;

	$desc =~ s/\\n/ /g;

# truncate at first full stop

	$desc =~ s/([^\.]+?)\. .*/$1/;
	$desc =~ s/([^\.]+?)\.$/$1/;

	if ( length( $desc ) > $maxDescLen ) {
		$desc =~ s/(.{$trunDescLen}).*/$1/;
		$desc .= $pressHelpString;
	}

	return $desc;
}


############################################################################
#
# Creates ael definition of the component including constant forms and formsets.
#
############################################################################

sub PtolemyComponent::createAEL {

	my $self = shift;

	my $forms_and_formset = "";
	my $ael = "";

	my $compName = $self->name();
	my $compNameMangled = $self->mangleString( $compName );

	$ael = "create_item (\"" . $compName;

	my $compDesc = $self->description();

	if ( defined( $compDesc ) ) {
		$ael .= "\",\"" . $self->convertDescription( $compDesc ) . "\",\n";
	}
	else {
		$ael .= "\",\"\",\n";
	}

	$ael .= "\t\"" . $self->instance_name() . "\",\n";
	$ael .= "\tITEM_NOT_ALL_PARM";

	my $modelType = $self->model_type();

	if ( $modelType eq "SUBCKT" ) {
		$ael .= " | ITEM_DESIGN_INST";
	}

	if ( $modelType eq "WTB" ) {
		$ael .= " | ITEM_DESIGN_INST | ITEM_UNIQUE";
	}

	$ael .= ",\n\t-1,\n";
	$ael .= "\t\"" . $self->pde_bitmap() . "\",\n";

	
	if ( $modelType eq "STAR" ) {
		$ael .= "\tstandard_dialog,\n";
	}
	else {
		$ael .= "\t\"Component Parameters\",\n";
	}

	$ael .= "\tNULL,\n";

	if ( $modelType eq "SUBCKT" ) {
		$ael .= "\tSPDesignNetlistFmt,\n";
	}
	elsif ( $modelType eq "ARF_SOURCE" ) {
		$ael .= "\tARFSourceNetlistFmt,\n";
	}
	elsif ( $modelType eq "WTB" ) {
		$ael .= "\tARFWTBNetlistFmt,\n";
	}
	elsif ( $modelType eq "STAR" ) {
		$ael .= "\tSPComponentNetlistFmt,\n";
	}

	if ( $modelType eq "STAR" ) {
		$ael .= "\t\"" . $self->netlist_name() . "\",\n";
	}
	else {
		$ael .= "\t\"" . $compName . "\",\n";
	}

	if ( $modelType eq "STAR" ) {
		$ael .= "\tSPComponentAnnotFmt,\n";
	}
	else {
		$ael .= "\tSPDesignAnnotFmt,\n";
	}

	$ael .= "\t\"" . $self->pde_symbol() . "\",\n";
	$ael .= "\tno_artwork,\n";
	$ael .= "\tNULL,\n";
	$ael .= "\tITEM_PRIMITIVE_EX";

	if ( $modelType eq "ARF_SOURCE" ) {
		$ael .= " | ITEM_INITIAL_ORIENTATION_DOWN_EX";
	}

	my $nextParameter = $self->getParameterIterator();
	my $parmCounter = 0;

	while ( my $parameter = $nextParameter->() ) {

		my $forms = "";
		my $formset = "";

		$parmCounter++;

		$ael .= ",\n";

		my $parmName = $parameter->name();
		my $parmNameMangled = $self->mangleString( $parmName );
		my $parmDesc = $parameter->description();
		$parmDesc = $self->convertDescription( $parmDesc );

		$parmDesc =~ s/"/'/g;

		my $parmDefault = $parameter->default();
		my $parmDefaultMangled = $self->mangleString( $parmDefault );
		my $parmDefaultMangled2 = $self->mangleString2( $parmDefault );

		$ael .= "\tcreate_parm (\"" . $parmName;
		$ael .= "\",\"" . $parmDesc . "\",\n";
		$ael .= "\t\t" . $parameter->getPDE_Type();

		my $nextAttribute = $parameter->getAttributeIterator();

		while ( my $attribute = $nextAttribute->() ) {
			$ael .= " | " . $attribute;
		}

		$ael .= ",\n";

		my $type = $parameter->type();

		if ( $type eq "enum" ) {
			$ael .= "\t\t\"_n" . $compNameMangled . "_f";
			$ael .= $parmNameMangled . "Set\",\n";
		}
		elsif ( $type eq "real enum" ) {
			$ael .= "\t\t\"_n" . $compNameMangled . "_f_x5f";
			$ael .= $parmNameMangled . "Set\",\n";
		}
		elsif ( $type eq "filename" ) {
			$ael .= "\t\t\"_n" . $compNameMangled . "_f";
			$ael .= $parmNameMangled . "_x5fFileSet\",\n";
		}
		elsif ( $type eq "instrument" ) {
			$ael .= "\t\t\"InstrumentFormSet\",\n";
		}
		elsif ( $type =~ /array/ || $type eq "precision" || $type eq "string" ) {
			$ael .= "\t\t\"StringAndReferenceSet\",\n";
		}
		else {
			$ael .= "\t\t\"StdFormSet\",\n";
		}

		$ael .= "\t\t" . $parameter->getPDE_Unit() . ",\n";

		if ( $type eq "enum" ) {
			$ael .= "\t\tprm(\"_n" . $compNameMangled . "_f";
			$ael .= $parmDefaultMangled . "\",\"";
			$ael .= $parmDefaultMangled2 . "\"))";
		}
		elsif ( $type eq "real enum" ) {
			$ael .= "\t\tprm(\"_n" . $compNameMangled . "_f";
			$ael .= $parmDefaultMangled . "\",\"";
			$ael .= $parmDefaultMangled2 . "\"))";
		}
		elsif ( $type eq "filename" ) {
			my $fileExt = $parmDefault;
			$fileExt =~ s/[^\.]+\.(.+)/$1/;

			if ( $fileExt eq "" || ! $parameter->fileExtensionExists( $fileExt ) ) {
				$fileExt = $parameter->getFirstFileExtension();
			}

			$ael .= "\t\tprm(\"_n" . $compNameMangled . "_f" . $fileExt;
			$ael .= "_x5ffile\",\"\\\"" . $parmDefault . "\\\"\"))";
		}
		elsif ( $type eq "instrument" ) {
			$ael .= "\t\tprm(\"InstrumentForm\",\"\\\"";
			$ael .= $parmDefault . "\\\"\"))";
		}
		elsif ( $type =~ /array/ ) {
			if ( $parmDefault =~ /^{/ ) {
				$ael .= "\t\tprm(\"StringAndReference\",\"";
				$ael .= $parmDefault . "\"))";
			}
			else {
				$ael .= "\t\tprm(\"StringAndReference\",\"\\\"";
				$ael .= $parmDefault . "\\\"\"))";
			}
		}
		elsif ( $type eq "precision" || $type eq "string" ) {
			$ael .= "\t\tprm(\"StringAndReference\",\"\\\"";
			$ael .= $parmDefault . "\\\"\"))";
		}
		else {
			$ael .= "\t\tprm(\"StdForm\",\"" . $parmDefault . "\"))";
		}

		my $nextEnum = $parameter->getEnumIterator();

		while ( my $enum = $nextEnum->() ) {
			my $enumAlias = $enum->alias();
			my $enumAliasMangled = $enumAlias;
			$enumAliasMangled =~ s/^ +//;
			$enumAliasMangled =~ s/ +$//;
			$enumAliasMangled =~ s/[^a-zA-Z0-9]/_x5f/g;

			$forms .= "create_constant_form (\"_n";
			$forms .= $compNameMangled . "_f" . $enumAliasMangled . "\",\n";
			$forms .= "\t\"" . $enumAlias . "\",\n";
			$forms .= "\t0,\n";
			$forms .= "\t\"" . $enum->value() . "\",\n";
			$forms .= "\t\"" . $enum->abbreviation() . "\");\n";
			$formset .= "\t\"_n" . $compNameMangled . "_f";
			$formset .= $enumAliasMangled . "\",\n";
		}


		if ( $forms ne "" ) {

			my $tmpStr = "create_form_set(\"_n" . $compNameMangled . "_f";

			if ( $type eq "real enum" ) {
				$tmpStr .= "_x5f";
			}

			$tmpStr .= $parmNameMangled . "Set\",\n";

			$formset = $tmpStr . $formset . "\t\"StdForm\");\n";
		}

		if ( $type eq "filename" ) {

			my $nextFileExt = $parameter->getFileExtensionIterator();
			my $fileExtCounter = 0;

			while ( my $fileExt = $nextFileExt->() ) {
				$forms .= "create_text_form (\"_n";
				$forms .= $compNameMangled . "_f" . $fileExt . "_x5ffile\",\n";
				$forms .= "\t\"File with " . $fileExt . " extension\",\n";
				$forms .= "\t\"ReadFileForm\", 0, \"%v\", \"%v\",";;
				$forms .= " get_file_name_list_with_ext, NULL,\n";
				$forms .= "\tlist(\"DATA_FILES\", \"" . $fileExt;
				$forms .= "\"), prefix_path_to_data_file);\n";
				$formset .= ",\n\t\"_n" . $compNameMangled . "_f" . $fileExt . "_x5ffile\"";

				$fileExtCounter++;
			}

			if ( $forms ne "" ) {
				$formset = "create_form_set ( \"_n" . $compNameMangled . "_f" . $parmNameMangled . "_x5fFileSet\"" . $formset;

				$formset .= ");\n";
			}

			if ( $fileExtCounter > 0 ) {
			}
		}

		$forms_and_formset .= $forms . $formset;
	}

	if ( $parmCounter == 0 ) {
		$ael .= "\n);\n";
	}
	else {
		$ael .= ");\n";
	}

	$ael = $forms_and_formset . $ael;

	$ael .= "library_group(\"" . $self->library() . "\",\"";
	$ael .= $self->library() . "\",\"" . $self->name() . "\");\n";
	$ael .= "palette_group(\"" . $self->library() . "\",\"";
	$ael .= $self->library() . "\",\"" . $self->name() . "\");\n\n";

	if ( $modelType eq "ARF_SOURCE" ) {
		$ael = "set_design_type( analogRFnet );\n" . $ael;
	}
	else {
		$ael = "set_design_type( sigproc_net );\n" . $ael;
	}

	open( AEL_FILENAME, ">$compName.ael" );
	print AEL_FILENAME $ael;
	close( AEL_FILENAME );

	system( "$ENV{HPEESOF_DIR}/tools/bin/perl $ENV{HPEESOF_DIR}/adsptolemy/bin/processStarAel $compName.ael" );
	unlink( $compName . ".ael.bak" );
}


############################################################################
#
# This method translates the method StarSymbol::drawArrow( )
#
# It returns a string with "code" for PDE to draw an arrow. Arguments:
#
# arrowl: int (lower left x coordinate of the bounding box)
# arrowr: int (upper right x coordinate of the bounding box)
# arrowb: int (lower left y coordinate of the bounding box)
# arrowt: int (upper right y coordinate of the bounding box)
# piny  : int (pin y coordinate)
#
############################################################################

sub PtolemyComponent::drawArrow {

	my $self = shift;
	my $arrowl = shift;
	my $arrowr = shift;
	my $arrowb = shift;
	my $arrowt = shift;
	my $piny = shift;

	my $code = "";

	$code .= "50 1 $arrowl $arrowb $arrowr $arrowt 1 0 0 0 0 0 0 0 0\n";
	$code .= "60 4 0 4 $arrowl $arrowb $arrowr $arrowt 1 0 0 0 0\n";
	$code .= "70 $arrowr $piny $arrowl $arrowt $arrowl $arrowb $arrowr $piny\n";

	return $code;
}


############################################################################
#
# Creates symbol for component
#
############################################################################

sub PtolemyComponent::createSymbol {

	my $self = shift;

	my $numInPorts = $self->getInputPortNumber();
	my $numOutPorts = $self->getOutputPortNumber();

	my $sqrwidth = 750;           # width of square
	my $sqrheight = 750;          # min height of square
	my $pinlen = 500;             # length of a pin
	my $vincr = 125;              # distance from square edge to pin
	my $pinspace = 250;           # distance between pins
	my $arrowwidth = 187;         # arrow width
	my $arrowheight = 187;        # arrow height
	my $textoffset = 25;          # text x offset from pin
	my $textheight = 75;          # height of text
	my $textcharwidth = 70;       # width of a character of text (approx)
	my $bigtextheight = 194;      # height of big text
	my $bigtextcharwidth = 150;   # width of a character of big text (approx)
	my $hieroffset = 63;          # subcircuit inner square offset from outer
	my $targetwidth = 2000;       # width of target (0 pin symbol)
	my $targetheight = 375;       # height of target
	my $threedwidth = 60;         # width of 3d target border

	my $boxxmin = 0;              # bounding
	my $boxymin = 0;              # box
	my $boxxmax = 0;              # of 
	my $boxymax = 0;              # symbol

	my $sqrxmin = 0;              # square
	my $sqrymin = 0;              # inside
	my $sqrxmax = 0;              # the
	my $sqrymax = 0;              # symbol

	my $sqrthickness = 0;         # thickness of square

	my $startiny = 0;             # y coord of first in pin
	my $startouty = 0;            # y coord of first out pin

	my $symbol = "";

############################################################################
#
# This part of the code translates the method StarSymbol::calcSizes( )
#
############################################################################

	my $numin = $self->getInputPortNumber();
	my $numout = $self->getOutputPortNumber();
	my $nummax = ( $numin > $numout ) ? $numin : $numout;
	my $mysqrheight;

	if ( $sqrheight > 2 * $vincr + ( $nummax - 1 ) * $pinspace ) {
		$mysqrheight = $sqrheight;
	}
	else {
		$mysqrheight = 2 * $vincr + ( $nummax - 1 ) * $pinspace;
	}

	if ( $numin > 0 ) {     # input 1 is at 0,0
		$startiny = 0;
		$sqrxmin = $pinlen;
		$sqrxmax = $sqrxmin + $sqrwidth;
		$sqrymin = $startiny - ( $mysqrheight - ( $numin - 1 ) * $pinspace ) / 2;
		$sqrymax = $sqrymin + $mysqrheight;
		$startouty = $sqrymin + ( $mysqrheight - ( $numout - 1 ) * $pinspace ) / 2;
		$sqrthickness = 2;
	}
	elsif ( $numout > 0 ) {     # output 1 is at 0,0
		$startouty = 0;
		$sqrxmax = -$pinlen;
		$sqrxmin = $sqrxmax - $sqrwidth;
		$sqrymin = $startouty - ( $mysqrheight - ( $numout - 1 ) * $pinspace ) / 2;
		$sqrymax = $sqrymin + $mysqrheight;
		$sqrthickness = 2;
	}
	else {     # no pins
		$sqrxmin = 0;
		$sqrymax = 0;
		$sqrxmax = $targetwidth;
		$sqrymin = -$targetheight;
		$sqrthickness = 3;
	}

	$boxxmin = $sqrxmin - ( $numin  ? $pinlen : 0 );
	$boxxmax = $sqrxmax + ( $numout ? $pinlen : 0 );
	$boxymin = $sqrymin;
	$boxymax = $sqrymax;

############################################################################
#
# End of StarSymbol::calcSizes( ) translation
#
############################################################################


############################################################################
#
# This part of the code translates the method StarSymbol::drawHeader( )
#
############################################################################

	$symbol .= "1 7.300 0 0\n";
	$symbol .= "10 -1 \"" . $self->pde_symbol();
	$symbol .= "\" 2 " . time() . " 0 0 0 0\n";
	$symbol .= "20 0 \"\" 0 0 0 0 0 2 -3 1 0 0 \"schematic.prf\" \"schematic.lay\"\n";
	$symbol .= "44 $boxxmin $boxymin $boxxmax $boxymax 1 0 0\n";
	$symbol .= "40 11 0 0 0\n";
	$symbol .= "50 1 $sqrxmin $sqrymin $sqrxmax $sqrymax 1 0 0 0 0 0 0 0 0\n";
	$symbol .= "90 \"line_thickness_prop\" 1 1 0 `$sqrthickness`\n";
	$symbol .= "60 3 0 5 $sqrxmin $sqrymin $sqrxmax $sqrymax 1 0 0 0 0\n";
	$symbol .= "70 $sqrxmin $sqrymin $sqrxmax $sqrymax $sqrxmin $sqrymin\n";

	if ( $self->model_type() eq "SUBCKT" || 
	     $self->model_type() eq "WTB"    || 
	     $self->model_type() eq "ARF_SOURCE" ) {
		$symbol .= "50 7 " . ( $sqrxmin + $hieroffset );
		$symbol .= " "     . ( $sqrymin + $hieroffset );
		$symbol .= " "     . ( $sqrxmax - $hieroffset );
		$symbol .= " "     . ( $sqrymax - $hieroffset );
		$symbol .= " 1 0 0 0 0 0 0 0 0\n";
	}

############################################################################
#
# End of StarSymbol::drawHeader( ) translation
#
############################################################################


	my $symbol2 = "";
	my $iny = $startiny;
	my $outy = $startouty;
	my $cnt = 0;

	my @portCodes = ();
	my @portLayers = ();

	my $nextPort = $self->getPortIterator();

	while ( my $port = $nextPort->() ) {

		my $pinx = 0;
		my $piny = 0;

		$cnt++;

		if ( $cnt <= $numInPorts ) {
# set variables for input port drawing
			$pinx = $sqrxmin - $pinlen;
			$piny = $iny;
		}
		else {
# set variables for output port drawing
			$pinx = $sqrxmax;
			$piny = $outy;
		}

############################################################################
#
# This part of the code translates the method StarSymbol::drawPort( )
#
############################################################################

		my $portCode = "";

		my $pincoord = "$pinx $piny " . ( $pinx + $pinlen ) . " $piny";

		$portCode .= "50 6 " . ( $pinx + $textoffset ) . " $piny ";
		$portCode .= ( $pinx + $textoffset + length( $port->name() ) * $textcharwidth );
		$portCode .= " " . ( $piny + $textheight ) . " 1 0 0 0 0 0 0 0 0\n";
		$portCode .= "62 0 $textheight 9 " . ( $pinx + $textoffset ) . " $piny";
		$portCode .= " 0 1 0 0 0 10 0 \"Arial\" `" . $port->name() . "`\n";
		$portCode .= "50 2 $pincoord 1 0 0 0 0 0 0 0 0\n";
		$portCode .= "90 \"line_thickness_prop\" 1 1 0 `" . $port->getThickness() . "`\n";
		$portCode .= "60 2 0 2 $pincoord 1 0 0 0 0\n";
		$portCode .= "70 $pincoord\n";

		$portCode .= $self->drawArrow( $pinx + $pinlen - $arrowwidth, $pinx + $pinlen, $piny - int( $arrowheight / 2 ), $piny + int( $arrowheight / 2 ), $piny );

		if ( $port->type() =~ /multiple/ ) {
			$portCode .= $self->drawArrow( $pinx + $pinlen - 2 * $arrowwidth, $pinx + $pinlen - $arrowwidth, $piny - int ( $arrowheight / 2 ), $piny + int( $arrowheight / 2 ), $piny );
		}

		$symbol2 .= "42 $cnt 2 \"" . $port->name() . "\" $cnt";

		if ( $cnt <= $numInPorts ) {
			$symbol2 .= " 0 0 $pinx $piny 180000 0 0 \"\"\n";
		}
		else {
			$symbol2 .= " 1 0 " . ( $pinx + $pinlen ) . " $piny 0 0 0 \"\"\n";
		}

############################################################################
#
# End of StarSymbol::drawPort( ) translation
#
############################################################################

# Save $portCode to array so that it can be used later on
		push @portCodes, $portCode;

		push @portLayers, $port->getLayer();

		if ( $cnt <= $numInPorts ) {
			$iny = $iny + $pinspace;
		}
		else {
			$outy = $outy + $pinspace;
		}

	}

############################################################################
#
# This part of the code translates the "print ports in layer-sorted orded"
# section of the method StarSymbol::createSymbol( )
#
############################################################################

	my $largelayer = 2000;
	my $prevlayer = $largelayer;

	for my $portIdx1 ( 0 .. $#portLayers ) {

		my $min = $numInPorts + $numOutPorts;
		my $minlayer = $largelayer;

		for my $portIdx2 ( 0 .. $#portLayers ) {

			if ( $portLayers[$portIdx2] < $minlayer ) {
				$minlayer = $portLayers[$portIdx2];
				$min = $portIdx2;
			}

		}

		if ( $prevlayer != $minlayer ) {
			$symbol .= "40 $minlayer 0 0 0\n";
		}

		$symbol .= $portCodes[$min];
		$portLayers[$min] = $largelayer;
		$prevlayer = $minlayer;
	}

############################################################################
#
# End of "print ports in layer-sorted orded" section of the method 
# StarSymbol::createSymbol( ) translation
#
############################################################################

############################################################################
#
# This part of the code translates the method StarSymbol::drawTarget( )
#
############################################################################

	if ( $numInPorts == 0 && $numOutPorts == 0 ) {
		my $symtextlayer = 20;
		my $symbodyfilledlayer = 21;
		my $textx = int( $targetwidth / 2 );
		my $texty = -int( $targetheight / 2 );
		$symbol .= "40 $symtextlayer 0 0 0\n";
		$symbol .= "50 6 $textx $texty ";
		$symbol .= ( $textx + length( $self->name() ) * $bigtextcharwidth );
		$symbol .= " " . ( $texty + $bigtextheight ) . " 1 0 0 0 0 0 0 0 0\n";
		$symbol .= "62 0 $bigtextheight 18 $textx $texty";
		$symbol .= " 0 1 0 0 0 14 0 \"HersheyRomanNarrow\" `";
		$symbol .= $self->name() . "`\n";
		$symbol .= "40 $symbodyfilledlayer 0 0 0\n";
		$symbol .= "50 1 $threedwidth " . ( -$targetheight - $threedwidth );
		$symbol .= " " . ( $targetwidth + $threedwidth );
		$symbol .= " " . ( -$threedwidth ) . " 1 0 0 0 0 0 0 0 0\n";
		$symbol .= "90 \"line_thickness_prop\" 1 0 0 `1`\n";
		$symbol .= "60 4 0 7 $threedwidth " . ( -$targetheight - $threedwidth );
		$symbol .= " " . ( $targetwidth + $threedwidth ) . " -$threedwidth 1 0 0 0 0\n";
		$symbol .= "70 $targetwidth -$threedwidth ";
		$symbol .= ( $targetwidth + $threedwidth ) . " -$threedwidth ";
		$symbol .= ( $targetwidth + $threedwidth ) . " ";
		$symbol .= ( -$targetheight - $threedwidth ) . " $threedwidth ";
		$symbol .= ( -$targetheight - $threedwidth ) . " $threedwidth ";
		$symbol .= "-$targetheight\n";
		$symbol .= "70 $targetwidth -$targetheight $targetwidth -$threedwidth\n";
	}

############################################################################
#
# End of StarSymbol::drawTarget( ) translation
#
############################################################################

############################################################################
#
# This part of the code translates the method StarSymbol::drawFooter( )
#
############################################################################

	$symbol .= $symbol2;
	$symbol .= "21\n";
	$symbol .= "20 1 \"\" 0 0 0 0 0 1 -2 1 0 0 \"layout.prf\" \"layout.lay\"\n";
	$symbol .= "44 0 0 0 0 0 0 0\n";
	$symbol .= "21\n";

############################################################################
#
# End of StarSymbol::drawFooter( ) translation
#
############################################################################

	my $symFileName = $self->pde_symbol() . ".dsn";

	open( SYMBOL_FILENAME, ">$symFileName" );
	print SYMBOL_FILENAME $symbol;
	close( SYMBOL_FILENAME );

}


############################################################################
#
# Creates bitmap for component
#
############################################################################

sub PtolemyComponent::createBitmap {

# The charBitmaps hash contains arrays with 9 integers. The first integer is 
# the horizonatal bit (pixel) count, including a leading space, needed to 
# represent the character that is the key of the hash. The remaining 8 integers 
# represent the 8x8 bitmap for the character.

	my %charBitmaps = (
# a #
		"a" => [ 4, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x06,   # 0000110
		            0x01,   # 0000001
		            0x05,   # 0000101
		            0x03,   # 0000011
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# b #
		"b" => [ 6, 0x18,   # 0011000
		            0x08,   # 0001000
		            0x0a,   # 0001010
		            0x0d,   # 0001101
		            0x09,   # 0001001
		            0x0e,   # 0001110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# c #
		"c" => [ 4, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x03,   # 0000011
		            0x04,   # 0000100
		            0x04,   # 0000100
		            0x03,   # 0000011
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# d #
		"d" => [ 5, 0x03,   # 0000011
		            0x01,   # 0000001
		            0x07,   # 0000111
		            0x09,   # 0001001
		            0x09,   # 0001001
		            0x07,   # 0000111
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# e #
		"e" => [ 4, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x02,   # 0000010
		            0x05,   # 0000101
		            0x04,   # 0000100
		            0x03,   # 0000011
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# f #
		"f" => [ 3, 0x01,   # 0000001
		            0x02,   # 0000010
		            0x03,   # 0000011
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x03,   # 0000011
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# g #
		"g" => [ 5, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x07,   # 0000111
		            0x09,   # 0001001
		            0x09,   # 0001001
		            0x07,   # 0000111
		            0x01,   # 0000001
		            0x06,   # 0000110
		     ],
# h #
		"h" => [ 5, 0x0c,   # 0001100
		            0x04,   # 0000100
		            0x06,   # 0000110
		            0x05,   # 0000101
		            0x05,   # 0000101
		            0x05,   # 0000101
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# i #
		"i" => [ 2, 0x01,   # 0000001
		            0x00,   # 0000000
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# j #
		"j" => [ 2, 0x01,   # 0000001
		            0x00,   # 0000000
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		     ],
# k #
		"k" => [ 5, 0x0c,   # 0001100
		            0x04,   # 0000100
		            0x05,   # 0000101
		            0x06,   # 0000110
		            0x06,   # 0000110
		            0x05,   # 0000101
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# l #
		"l" => [ 2, 0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# m #
		"m" => [ 6, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x1a,   # 0011010
		            0x15,   # 0010101
		            0x15,   # 0010101
		            0x15,   # 0010101
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# n #
		"n" => [ 4, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x06,   # 0000110
		            0x05,   # 0000101
		            0x05,   # 0000101
		            0x05,   # 0000101
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# o #
		"o" => [ 5, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x06,   # 0000110
		            0x09,   # 0001001
		            0x09,   # 0001001
		            0x06,   # 0000110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# p #
		"p" => [ 6, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x1e,   # 0011110
		            0x09,   # 0001001
		            0x09,   # 0001001
		            0x0e,   # 0001110
		            0x08,   # 0001000
		            0x0c,   # 0001100
		     ],
# q #
		"q" => [ 5, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x07,   # 0000111
		            0x09,   # 0001001
		            0x09,   # 0001001
		            0x07,   # 0000111
		            0x01,   # 0000001
		            0x03,   # 0000011
		     ],
# r #
		"r" => [ 3, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x03,   # 0000011
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x00,   # 0000000
		            0x00,    # 0000000
		     ],
# s #
		"s" => [ 4, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x03,   # 0000011
		            0x04,   # 0000100
		            0x01,   # 0000001
		            0x06,   # 0000110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# t #
		"t" => [ 4, 0x00,   # 0000000
		            0x02,   # 0000010
		            0x07,   # 0000111
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x01,   # 0000001
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# u #
		"u" => [ 4, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x05,   # 0000101
		            0x05,   # 0000101
		            0x05,   # 0000101
		            0x03,   # 0000011
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# v #
		"v" => [ 4, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x05,   # 0000101
		            0x05,   # 0000101
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# w #
		"w" => [ 6, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x15,   # 0010101
		            0x15,   # 0010101
		            0x0a,   # 0001010
		            0x0a,   # 0001010
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# x #
		"x" => [ 4, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x05,   # 0000101
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x05,   # 0000101
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# y #
		"y" => [ 4, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x05,   # 0000101
		            0x05,   # 0000101
		            0x05,   # 0000101
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x04,   # 0000100
		     ],
# z #
		"z" => [ 4, 0x00,   # 0000000
		            0x00,   # 0000000
		            0x07,   # 0000111
		            0x01,   # 0000001
		            0x04,   # 0000100
		            0x07,   # 0000111
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# A #
		"A" => [ 7, 0x0c,   # 0001100
		            0x0c,   # 0001100
		            0x12,   # 0010010
		            0x1e,   # 0011110
		            0x21,   # 0100001
		            0x33,   # 0110011
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# B #
		"B" => [ 6, 0x1e,   # 0011110
		            0x09,   # 0001001
		            0x0e,   # 0001110
		            0x09,   # 0001001
		            0x09,   # 0001001
		            0x1e,   # 0011110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# C #
		"C" => [ 6, 0x0f,   # 0001111
		            0x11,   # 0010001
		            0x10,   # 0010000
		            0x10,   # 0010000
		            0x11,   # 0010001
		            0x0e,   # 0001110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# D #
		"D" => [ 6, 0x1e,   # 0011110
		            0x09,   # 0001001
		            0x09,   # 0001001
		            0x09,   # 0001001
		            0x09,   # 0001001
		            0x1e,   # 0011110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# E #
		"E" => [ 5, 0x0f,   # 0001111
		            0x05,   # 0000101
		            0x06,   # 0000110
		            0x04,   # 0000100
		            0x05,   # 0000101
		            0x0f,   # 0001111
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# F #
		"F" => [ 5, 0x0f,   # 0001111
		            0x05,   # 0000101
		            0x06,   # 0000110
		            0x04,   # 0000100
		            0x04,   # 0000100
		            0x0e,   # 0001110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# G #
		"G" => [ 6, 0x0f,   # 0001111
		            0x11,   # 0010001
		            0x10,   # 0010000
		            0x13,   # 0010011
		            0x11,   # 0010001
		            0x0f,   # 0001111
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# H #
		"H" => [ 5, 0x09,   # 0001001
		            0x09,   # 0001001
		            0x0f,   # 0001111
		            0x09,   # 0001001
		            0x09,   # 0001001
		            0x09,   # 0001001
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# I #
		"I" => [ 4, 0x07,   # 0000111
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x07,   # 0000111
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# J #
		"J" => [ 5, 0x07,   # 0000111
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x0a,   # 0001010
		            0x0c,   # 0001100
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# K #
		"K" => [ 6, 0x1b,   # 0011011
		            0x0a,   # 0001010
		            0x0c,   # 0001100
		            0x0c,   # 0001100
		            0x0a,   # 0001010
		            0x1b,   # 0011011
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# L #
		"L" => [ 5, 0x0e,   # 0001110
		            0x04,   # 0000100
		            0x04,   # 0000100
		            0x04,   # 0000100
		            0x05,   # 0000101
		            0x0f,   # 0001111
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# M #
		"M" => [ 8, 0x63,   # 1100011
		            0x22,   # 0100010
		            0x36,   # 0110110
		            0x36,   # 0110110
		            0x2a,   # 0101010
		            0x6b,   # 1101011
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# N #
		"N" => [ 7, 0x21,   # 0100001
		            0x31,   # 0110001
		            0x29,   # 0101001
		            0x25,   # 0100101
		            0x23,   # 0100011
		            0x21,   # 0100001
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# O #
		"O" => [ 6, 0x0e,   # 0001110
		            0x11,   # 0010001
		            0x11,   # 0010001
		            0x11,   # 0010001
		            0x11,   # 0010001
		            0x0e,   # 0001110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# P #
		"P" => [ 5, 0x0e,   # 0001110
		            0x05,   # 0000101
		            0x05,   # 0000101
		            0x06,   # 0000110
		            0x04,   # 0000100
		            0x0e,   # 0001110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# Q #
		"Q" => [ 6, 0x0e,   # 0001110
		            0x11,   # 0010001
		            0x11,   # 0010001
		            0x11,   # 0010001
		            0x11,   # 0010001
		            0x0e,   # 0001110
		            0x02,   # 0000010
		            0x00,   # 0000000
		     ],
# R #
		"R" => [ 5, 0x0e,   # 0001110
		            0x05,   # 0000101
		            0x05,   # 0000101
		            0x06,   # 0000110
		            0x05,   # 0000101
		            0x0d,   # 0001101
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# S #
		"S" => [ 5, 0x07,   # 0000111
		            0x09,   # 0001001
		            0x06,   # 0000110
		            0x01,   # 0000001
		            0x09,   # 0001001
		            0x0e,   # 0001110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# T #
		"T" => [ 4, 0x07,   # 0000111
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# U #
		"U" => [ 6, 0x1b,   # 0011011
		            0x11,   # 0010001
		            0x11,   # 0010001
		            0x11,   # 0010001
		            0x11,   # 0010001
		            0x0e,   # 0001110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# V #
		"V" => [ 7, 0x33,   # 0110011
		            0x21,   # 0100001
		            0x12,   # 0010010
		            0x12,   # 0010010
		            0x0c,   # 0001100
		            0x0c,   # 0001100
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# W #
		"W" => [ 7, 0x33,   # 0110011
		            0x21,   # 0100001
		            0x2d,   # 0101101
		            0x2d,   # 0101101
		            0x12,   # 0010010
		            0x12,   # 0010010
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# X #
		"X" => [ 7, 0x33,   # 0110011
		            0x12,   # 0010010
		            0x0c,   # 0001100
		            0x0c,   # 0001100
		            0x12,   # 0010010
		            0x33,   # 0110011
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# Y #
		"Y" => [ 8, 0x63,   # 1100011
		            0x22,   # 0100010
		            0x14,   # 0010100
		            0x08,   # 0001000
		            0x08,   # 0001000
		            0x1c,   # 0011100
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# Z #
		"Z" => [ 5, 0x0f,   # 0001111
		            0x09,   # 0001001
		            0x02,   # 0000010
		            0x04,   # 0000100
		            0x09,   # 0001001
		            0x0f,   # 0001111
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# 0 #
		"0" => [ 6, 0x0e,   # 0001110
		            0x11,   # 0010001
		            0x11,   # 0010001
		            0x11,   # 0010001
		            0x11,   # 0010001
		            0x0e,   # 0001110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# 1 #
		"1" => [ 2, 0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# 2 #
		"2" => [ 5, 0x06,   # 0000110
		            0x09,   # 0001001
		            0x02,   # 0000010
		            0x04,   # 0000100
		            0x08,   # 0001000
		            0x0f,   # 0001111
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# 3 #
		"3" => [ 5, 0x06,   # 0000110
		            0x09,   # 0001001
		            0x02,   # 0000010
		            0x02,   # 0000010
		            0x09,   # 0001001
		            0x06,   # 0000110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# 4 #
		"4" => [ 5, 0x09,   # 0001001
		            0x09,   # 0001001
		            0x0f,   # 0001111
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# 5 #
		"5" => [ 5, 0x0f,   # 0001111
		            0x08,   # 0001000
		            0x0e,   # 0001110
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x0e,   # 0001110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# 6 #
		"6" => [ 5, 0x06,   # 0000110
		            0x09,   # 0001001
		            0x08,   # 0001000
		            0x0e,   # 0001110
		            0x09,   # 0001001
		            0x06,   # 0000110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# 7 #
		"7" => [ 5, 0x0f,   # 0001111
		            0x01,   # 0000001
		            0x02,   # 0000010
		            0x04,   # 0000100
		            0x08,   # 0001000
		            0x08,   # 0001000
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# 8 #
		"8" => [ 5, 0x06,   # 0000110
		            0x09,   # 0001001
		            0x06,   # 0000110
		            0x06,   # 0000110
		            0x09,   # 0001001
		            0x06,   # 0000110
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
# 9 #
		"9" => [ 5, 0x07,   # 0000111
		            0x09,   # 0001001
		            0x09,   # 0001001
		            0x07,   # 0000111
		            0x01,   # 0000001
		            0x01,   # 0000001
		            0x00,   # 0000000
		            0x00,   # 0000000
		     ],
	);

# Hash that returns the "reverse" representation of a hex digit. Examples:
# 1 = 0001 -> 1000 = 8
# 2 = 0010 -> 0100 = 4
# 3 = 0011 -> 1100 = c

	my %ChrReverse = (
						"0" => "0",
						"1" => "8",
						"2" => "4",
						"3" => "c",
						"4" => "2",
						"5" => "a",
						"6" => "6",
						"7" => "e",
						"8" => "1",
						"9" => "9",
						"a" => "5",
						"b" => "d",
						"c" => "3",
						"d" => "b",
						"e" => "7",
						"f" => "f",
	);

	my $self = shift;

	my $bitmapSize = 32;
	my $compName = $self->name();
	my $bitmap = "";

	$bitmap .= "#define $compName" . "_width $bitmapSize\n";
	$bitmap .= "#define $compName" . "_height $bitmapSize\n";
	$bitmap .= "static char $compName" . "_bits[] = { \n";

############################################################################
#
# This part of the code does something equivalent to the method 
# StarBitmap::CreateWordSegments( )
#
# Split the name string into word segments (maximum number of segments 
# is 4) and truncate the segments so that the pixel number needed to 
# represent them does not exceed $bitmapSize.
#
############################################################################

	my @wordSegments = ();
	my $segmentCounter = 0;

	my $string = $compName;
	my $segment = "";


# End of segment is detected when an underbar is matched or an upper 
# case letter is followed by a lower case one or end of string
# Maximum 4 segments allowed

	while ( length( $string ) > 0 && $segmentCounter < 4 ) {
		$segmentCounter++;
		$string =~ s/^_//;      # remove leading underbar
		$segment = $string;
		$segment =~ s/(\w+?)([A-Z][a-z]|_|$).*/$1/;
		$string =~ s/(\w+?)(([A-Z][a-z]|_|$).*)/$2/;

		my @chars = split //, $segment;
		my $pixelCount = 0;
		$segment = "";

# Truncate segment so that the pixel number needed to represent 
# it does not exceed $bitmapSize.

		while ( $#chars >= 0 && $pixelCount + $charBitmaps{$chars[0]}->[0] <= $bitmapSize ) {
			$pixelCount += $charBitmaps{$chars[0]}->[0];
			$segment .= shift( @chars );
		}

		push @wordSegments, $segment;
	}

# push empty segments if less than 4 segments were created

	while ( $segmentCounter < 4 ) {
		$segmentCounter++;
		push @wordSegments, "";
	}


############################################################################
#
# End of StarBitmap::CreateWordSegments( ) translation
#
############################################################################

############################################################################
#
# This is how the next part of the code works
#
#           'A'  'i' 
#         0001100|01|0000000000000000000000000
#         0001100|00|0000000000000000000000000
#         0010010|01|0000000000000000000000000
#         0011110|01|0000000000000000000000000
#         0100001|01|0000000000000000000000000
#         0110011|01|0000000000000000000000000
#         0000000|00|0000000000000000000000000
#         0000000|00|0000000000000000000000000
#
# RULES:
# 1) REMEMBER, 1 bit = 1 pixel
#
# 2) All character bitmaps are 8 bits even though the pixel width for each 
#    letter varies from 2 to 8. The charBitmaps hash holds arrays for each 
#    character key, where the first element of the array is the pixel width 
#    needed to represent the character. The width also includes one extra 
#    pixel on the left side of the character for a space.
#    EXAMPLE
#       The first row of the 'A' Bitmap is stored as ox0c (00001100), but we 
#       only need 6 pixels plus a space which equals a pixel width of 7.
#       The first row of the 'i' Bitmap is stored as 0x01 (00000001), but we 
#       only need 1 pixel plus a space which equals a pixel width of 2.
#
# 3) The 8 Row buffers are first set to 0.
#
# 4) The Row buffers are shifted left by the pixel width of the next character.
#
# 5) Row by row, the bitmaps rows are added to the Row buffers.
#
# 6) The bits in the Rows are then shifted left so the total entered bits is 
#    equal to $bitmapSize (32).
#
#   EXAMPLE: 
#   Row1 = 000000000000000000000000 
#   Row1 = 000000000000000000001100  the 7 bits of 'A' are added (from left)
#   Row1 = 000000000000000000110000  the 7 bits of 'A' are shifted 2 places for i
#   Row1 = 000000000000000000110001  the 2 bits of 'i' are added in
#   Row1 = 000110001000000000000000  when done, all are shifted by 32-(2+7) = 15
#   Row2 = 000110000000000000000000  When all 8 Rows are loaded
#   Row3 = 001001001000000000000000
#   Row4 = 001111001000000000000000
#   Row5 = 010000101000000000000000
#   Row6 = 011001101000000000000000
#   Row7 = 000000000000000000000000
#   Row8 = 000000000000000000000000  = 'Ai'
#
# 7) When all loaded, the 32 bits are divided into 4 bytes starting from left side.
#
# 8) For each byte swap the upper and lower halfs and mirror image the bit order.
#    0x0c -> 0x30 ( 0x0c -> 0xc0 -> 1100 0000 -> 0011 0000 -> 0x30 )
#    0x01 -> 0x80 ( 0x01 -> 0x10 -> 0001 0000 -> 1000 0000 -> 0x80 )
#    0x02 -> 0x40 ( 0x02 -> 0x20 -> 0010 0000 -> 0100 0000 -> 0x40 )
#    0x5d -> 0x40 ( 0x5d -> 0xd5 -> 1101 0101 -> 1011 1010 -> 0xba )
#
#    Don't ask me why but this the way the output of the bm generator looks.
#
############################################################################

	my @rows = ( 0 ) x 8;
	my $rowIdx = 0;

	for my $wordSegIdx ( 0 .. $#wordSegments ) { # Create bitmap for each segment

		my @chars = split //, $wordSegments[$wordSegIdx];
		my $totalPixelCount = 0;

		for my $chrIdx ( 0 .. $#chars ) {

			my $pixelCount = $charBitmaps{$chars[$chrIdx]}->[0];
			$totalPixelCount += $pixelCount;

# For each of the 8 rows in a segment, shift by $pixelCount to make "room" for
# character bit pattern to be "loaded" in the row, and load the bit pattern

			for my $rowIdx ( 0 .. 7 ) {
				$rows[$rowIdx] = $rows[$rowIdx] << $pixelCount;
				$rows[$rowIdx] += $charBitmaps{$chars[$chrIdx]}->[$rowIdx+1];
			}
		}

		for $rowIdx ( 0 .. 7 ) {   # For each of the 8 rows

# Add blank pixels to right side of segment (left align the word segment)

			$rows[$rowIdx] = $rows[$rowIdx] << ( 32 - $totalPixelCount );

			for my $byteIdx ( 0 .. ( $bitmapSize / 8 - 1 ) ) { # for all 4 bytes

				my $hexInt = $rows[$rowIdx] & 0x0f000000;  # get hex digit for
				my $hexStr = sprintf( "%lx", $hexInt );    # 2nd half of MS byte
				my $firstChar = $hexStr;
				$firstChar =~ s/^(.).*/$1/;                # get first character
				$firstChar = $ChrReverse{ $firstChar };    # and "reverse" it
				$bitmap .= sprintf( "0x%s", $firstChar );

				$hexInt = $rows[$rowIdx] & 0xf0000000;     # get hex digit for
				$hexStr = sprintf( "%lx", $hexInt );       # 1st half of MS byte
				$firstChar = $hexStr;
				$firstChar =~ s/^(.).*/$1/;                # get first character
				$firstChar = $ChrReverse{ $firstChar };    # and "reverse" it
				$bitmap .= sprintf( "%s", $firstChar );

				$rows[$rowIdx] = $rows[$rowIdx] << 8;      # shift out MS byte

				if ( $byteIdx != ( $bitmapSize / 8 ) - 1 || $rowIdx != 7 ) {
					$bitmap .= ",";
				}
			}
		}

		if ( $wordSegIdx == int( $bitmapSize / 8 ) - 1 ) {
			$bitmap .= "};\n";
		}
		else {
			$bitmap .= ",\n";
		}
	}

	my $bmpFileName = $self->pde_bitmap() . ".bmp";
	my $xbmFileName = $self->pde_bitmap() . ".xbm";

	open( BITMAP_FILENAME, ">$xbmFileName" );
	print BITMAP_FILENAME $bitmap;
	close( BITMAP_FILENAME );

# Convert bitmap on Windows

	if ( $^O =~ /^MSWin/ ) {
		$ENV{PATH} = "$ENV{HPEESOF_DIR}\\tools\\bin;$ENV{PATH}";
		my $arch=`sh $ENV{HPEESOF_DIR}\\bin\\hpeesofarch`;
		chomp( $arch );
		$ENV{PATH} = "$ENV{HPEESOF_DIR}\\adsptolemy\\bin.$arch;$ENV{PATH}";
		system( "sh -c \"xbmtopbm $xbmFileName | ppmtobmp -w > $bmpFileName && rm $xbmFileName\"" ) && die(" Error: returned $?\n");
	}
}


############################################################################
#
# Creates Genesys XML description
#
############################################################################

sub PtolemyComponent::createGenesysModel {

	my $self = shift;

	my $xml = "";
	my $compName = $self->name();

	$xml .= "<Item XName=\"$compName\" Type=\"Design\">\n";

	my $parmNum = $self->getParameterNumber();

	if ( $parmNum > 0 ) {

		$xml .= "<Item XName=\"Parameters\" Type=\"Parameters\">\n";
		$xml .= "<Item XName=\"ParamSet\" Type=\"ParamSet\">\n";

		my $nextParameter = $self->getParameterIterator();

		while ( my $parameter = $nextParameter->() ) {

			my $parmName = $parameter->name();
			my $parmDesc = $parameter->description();
			my $parmType = $parameter->type();
			my $parmDefault = $parameter->default();
			my $parmGenesysType = $parameter->getGenesysType();
			my $parmGenesysUnit = $parameter->getGenesysUnit();

			$xml .= "<Item XName=\"$parmName\" Type=\"PartParam\">\n";

			$parmDesc =~ s/&/&amp;/g;
			$parmDesc =~ s/</&lt;/g;
			$xml .= "<Description>$parmDesc</Description>\n";
			$xml .= "<Unit><T>Int</T><D>$parmGenesysUnit</D></Unit>\n";
			
			if ( "$parmType" eq "real" ) {
				$xml .= "<Validate><T>Int</T><D>0</D></Validate>\n";
			}
			elsif ( "$parmType" eq "string" ) {
				$xml .= "<Validate><T>Int</T><D>4</D></Validate>\n";
			}
			elsif ( "$parmType" eq "filename" ) {
				$xml .= "<Validate><T>Int</T><D>10</D></Validate>\n";
			}
			else {
				$xml .= "<Validate><T>Int</T><D>5</D></Validate>\n";
			}
			
			if ( ( defined $parmGenesysType ) && ( $parmGenesysType eq "BString" ) ) {
				$xml .= "<Data><T>$parmGenesysType</T><D>";
			}
			else {
				$xml .= "<DataEntry>";
			}			

			my $enumName = "";

			if ( "$parmType" eq "complex" ) {
				$parmDefault =~ s/ //g;         # remove all spaces
				$parmDefault =~ s/^j/+j/;       # add implied + in front of j
				if ( ! ( $parmDefault =~ /j/ ) ) {
					$parmDefault .= "+j*0.0";             # fill in 0.0 imag part
				}
				if ( $parmDefault =~ /^[+-]j/ ) {
					$parmDefault = "0.0" . $parmDefault;  # fill in 0.0 real part
				}
				$parmDefault =~ s/j$/j*1.0/;        # add implied *1.0 after j
				$parmDefault =~ s/([+-])j\*/, $1/;  # replace "+-j*" with ", +-"
				$parmDefault =~ s/, \+/,/g;         # remove unecessary "+"
				$parmDefault =~ s/^\+//g;           # remove unecessary "+"
				$xml .= "complex(" . $parmDefault . ")";
			}
			elsif ( "$parmType" eq "int" ) {
				if ( $parmDefault =~ /^0x/ ) {
					$xml .= hex( $parmDefault );
				}
				else {
					$xml .= $parmDefault;
				}
			}
			elsif ( "$parmType" eq "enum" ) {
				my $numEnums = $parameter->getEnumNumber();
				my $counter = 0;
				my $defaultIdx = -1;
				my $enumData = "";
				my $nextEnum = $parameter->getEnumIterator();

				while ( my $enum = $nextEnum->() ) {
					my $enumAlias = $enum->alias();
					my $enumAbbr = $enum->abbreviation();
					$enumData .= $counter . ";$enumAbbr;";
					$enumName .= "$enumAbbr;";
					if ( "$parmDefault" eq "$enumAlias" ) {
						$defaultIdx = $counter;
					}
					$counter++;
				}

				$enumData =~ s/;$//;
				$enumName =~ s/;$//;

				if ( $defaultIdx == -1 ) {
					print STDERR "Enumerated parameter $parmName does not have default value\n";
				}

				$xml .= $defaultIdx;
				open( ENUMS, ">>Enums.txt" ) || die "Could not open Enums.txt\n";
				print ENUMS "AddEnum( CString(\"$enumName\"), CString(\"$enumData\") );\n";
				close( ENUMS );
			}
			elsif ( "$parmType" eq "real enum" ) {
				print STDERR "$parmName: real enum parameters not supported.\n";
			}
			elsif ( "$parmType" =~ /array/ ) {

				if ( "$parmType" eq "complex array" ) {

					my @values = ();
					
					if ( $parmDefault =~ /^\{/ ) {    # curly brace notation

						$parmDefault =~ s/^\{//g;      # remove leading "{"
						$parmDefault =~ s/\}$//g;      # remove trailing "}"
						$parmDefault =~ s/ //g;        # remove all spaces
						$parmDefault =~ s/([^+-])j/$1+j/g; # add implied + in front of j
						$parmDefault =~ s/,/,,/g;      # double the commas to help rest of parsing
						$parmDefault =~ s/^(.*)/,$1/;  # add comma at the front to help rest of parsing
						$parmDefault =~ s/(.*)$/$1,/;  # add comma at the end to help rest of parsing
						$parmDefault =~ s/,(\(*)([^j]+?)(\)*),/,$1$2+j*0.0$3,/g; # fill in 0.0 imag part
						$parmDefault =~ s/,(\(*)([+-]j.*?)(\)*),/,$1 0.0$2$3,/g; # fill in 0.0 real part
						$parmDefault =~ s/ //g;        # remove all spaces in case new were added
						$parmDefault =~ s/j(\)*),/j*1.0$1,/g; # add implied *1.0 after j

# The next 4 statements will not work for complicated expressions 
# with many level of parentheses
						$parmDefault =~ s/^\(//g;      # remove leading "("
						$parmDefault =~ s/\)$//g;      # remove trailing ")"
						$parmDefault =~ s/\),/,/g;     # remove parenthesis just before ","
						$parmDefault =~ s/,\(/,/g;     # remove parenthesis just after ","

						$parmDefault =~ s/([+-])j\*/; $1/g;  # replace "+-j*" with "; +-"
						$parmDefault =~ s/[, ]\+/ /g;        # remove unecessary "+"
						$parmDefault =~ s/^,//;      # remove comma from the front
						$parmDefault =~ s/,$//;      # remove comma from the end
						$parmDefault =~ s/,,/,/g;    # remove double commas

						@values = split /,/, $parmDefault;  # split on ","
					}
					else {                        # double quote notation
						$parmDefault =~ s/ //g;    # remove all spaces
						$parmDefault =~ s/\),/)/g; # remove "," after ")"
						$parmDefault =~ s/(\([^,)]+?)\)/$1,0.0)/g; # fill in 0.0 imaginary part
						$parmDefault =~ s/,/; /g;  # replace "," with "; "
						$parmDefault =~ s/\(//g;   # remove opening "("

						@values = split /\)/, $parmDefault;  # split on closing ")"
					}

					if ( scalar( @values ) > 0 ) {

						$xml .= "[ ";

						while ( @values > 0 ) {
							my $value = shift( @values );
							$value =~ s/; /, /;
							$xml .= "complex($value)";
							if ( scalar( @values ) > 0 ) {
								$xml .= ", ";
							}
						}

						$xml .= " ]";
					}
				}
				else {
					$parmDefault =~ s/,/ /g;   # replace "," with " "
					$parmDefault =~ s/ +/ /g;  # merge multiple spaces to 1
					$parmDefault =~ s/^{ *//g; # remove leading "{" and spaces 
					$parmDefault =~ s/ *}$//g; # remove trailing "}" and spaces
					my @values = split / /, $parmDefault;
					my @expandedValues = ();
					while ( @values > 0 ) {
						my $val = shift( @values );
						if ( $val =~ /\[/ ) {
							my $repetitionFactor = $val;
							$repetitionFactor =~ s/^.*\[//;
							$repetitionFactor =~ s/]$//;
							my $prevVal = $val;
							$prevVal =~ s/\[.*//;
							if ( $prevVal eq "" ) {
								$prevVal = $expandedValues[$#expandedValues];
								$repetitionFactor--;
							}
							while ( $repetitionFactor > 0 ) {
								push @expandedValues, $prevVal;
								$repetitionFactor--;
							}
						}
						else {
							push @expandedValues, $val;
						}
					}

					if ( scalar( @expandedValues ) > 0 ) {

						$xml .= "[ ";

						while ( @expandedValues > 0 ) {
							$xml .= shift( @expandedValues );
							if ( scalar( @expandedValues ) > 0 ) {
								$xml .= ", ";
							}
						}

						$xml .= " ]";
					}
				}
			}
			elsif ( "$parmType" eq "string" || "$parmType" eq "filename" ) {
				if ( "$parmDefault" ne "" ) {
					$parmDefault =~ s/&/&amp;/g;
					$parmDefault =~ s/</&lt;/g;
					$xml .= "\"$parmDefault\"";
				}
			}
			else {   # real parameter
				$xml .= $parmDefault;
			}

			if ( ( defined $parmGenesysType ) && ( $parmGenesysType eq "BString" ) ) {
				$xml .= "</D></Data>\n";
			}
			else {
				$xml .= "</DataEntry>\n";
			}			

			if ( "$parmType" eq "enum" ) {
				$xml .= "<Enum>$enumName</Enum>\n";
			}

			if ( "$parmType" eq "filename" ) {
				my $nextFileExt = $parameter->getFileExtensionIterator();
				my $numValues = 0;
				my $values = "";
				while ( my $fileExt = $nextFileExt->() ) {
					$numValues++;
					$values .= "; $fileExt";
				}
				if ( $numValues > 0 ) {
					$values = "1; $numValues" . $values;
					$xml .= "<FileExtensions><T>Array_BString</T><D>$values</D></FileExtensions>\n";
				}
			}

			if ( $parameter->isNotShownOnSchematic() ) {
				$xml .= "<Show><T>Bool</T><D>0</D></Show>\n";
				$xml .= "<Default UserName=\"Default\" Help=\"329\"><T>Bool</T><D>1</D></Default>\n";
			}

			$xml .= "</Item>\n";
		}

		$xml .= "</Item>\n";
		$xml .= "</Item>\n";
	}

	my $inPortNum = $self->getInputPortNumber();
	my $outPortNum = $self->getOutputPortNumber();
	my $portNum = $inPortNum + $outPortNum;
	my $portCounter = 0;

	if ( $portNum > 0 ) {

		$xml .= "<Item XName=\"Ports\" Type=\"Ports\">\n";
		$xml .= "<Item XName=\"PortSet\" Type=\"PortSet\">\n";

		my $nextPort = $self->getPortIterator();

		while ( my $port = $nextPort->() ) {

			$portCounter++;
			my $portName = $port->name();
			my $portType = $port->type();
			my $portDescription = $port->description();
			my $portDirection = ( $portCounter > $inPortNum ) ? "out" : "in";
			my $portOptional = ( $port->optional() eq "YES" ) ? "1" : "0";
			my $portCommutative = ( $port->commutative() eq "YES" ) ? "1" : "0";
			
			$xml .= "<Item XName=\"$portName\" Type=\"PartPort\">\n";
			$xml .= "<Description>$portDescription</Description>\n";
			$xml .= "<DataType><T>BString</T><D>$portType</D></DataType>\n";
			$xml .= "<Direction><T>BString</T><D>$portDirection</D></Direction>\n";
			
			if ( $portOptional == 1 && "$portDirection" eq "in" ) {
				$xml .= "<IsOptional><T>Bool</T><D>1</D></IsOptional>\n";
			}
			
			if ( $portCommutative == 1 ) {
				$xml .= "<IsCommutative><T>Bool</T><D>1</D></IsCommutative>\n";
			}
				
			$xml .= "</Item>\n";
		}

		$xml .= "</Item>\n";
		$xml .= "</Item>\n";

	}

	my $type = $self->model_type();

	if ( $type eq "STAR" ) {
		$xml .= "<IsDataFlowModel><T>Bool</T><D>1</D></IsDataFlowModel>\n";
		my $dataFlowLib = $self->netlist_name();
		$dataFlowLib =~ s/.*_l(.*)/$1/;
		$dataFlowLib =~ s/([^_]*)_.*/$1/;
		$xml .= "<DataFlowLibrary>$dataFlowLib</DataFlowLibrary>\n";
	}

	$xml .= "</Item>\n\n";

#	open( XML_FILENAME, ">$compName.G.xml" );
#	print XML_FILENAME $xml;
#	close( XML_FILENAME );
	print $xml;
}



############################################################################
#
# Creates Genesys symbol
#
############################################################################

sub PtolemyComponent::createGenesysSymbol {

	my $self = shift;

	my $xml = "";
	my $partListXML = "";
	my $schematicXML = "";

	my $compName = $self->name();

	$xml .= "<Item XName=\"SYM_" . $compName . "\" ";
	$xml .= "UserName=\"SYM_" . $compName . "\" Type=\"Design\">\n";

	$partListXML .= "<Item XName=\"PartList\" Type=\"PartList\">\n";

	$schematicXML .= "<Item XName=\"Schematic\" Type=\"CSchematic\">\n";
	$schematicXML .= "<Item XName=\"Height\" Type=\"Param\">\n";
	$schematicXML .= "<DataEntry>8</DataEntry>\n";
	$schematicXML .= "<Unit><T>Int</T><D>6003</D></Unit>\n";
	$schematicXML .= "</Item>\n";
	$schematicXML .= "<Item XName=\"Width\" Type=\"Param\">\n";
	$schematicXML .= "<DataEntry>11</DataEntry>\n";
	$schematicXML .= "<Unit><T>Int</T><D>6003</D></Unit>\n";
	$schematicXML .= "</Item>\n";
	$schematicXML .= "<Item XName=\"PartLength\" Type=\"Param\">\n";
	$schematicXML .= "<DataEntry>1</DataEntry>\n";
	$schematicXML .= "<Unit><T>Int</T><D>6003</D></Unit>\n";
	$schematicXML .= "</Item>\n";
	$schematicXML .= "<Item XName=\"SnapGrid\" Type=\"Param\">\n";
	$schematicXML .= "<Data><T>Double</T><D>250000</D></Data>\n";
	$schematicXML .= "<Unit><T>Int</T><D>0</D></Unit>\n";
	$schematicXML .= "</Item>\n";
	$schematicXML .= "<Item XName=\"Page\" Type=\"PageMgr\">\n";
	$schematicXML .= "<Item XName=\"PageBox\" Type=\"PageBox\">\n";
	$schematicXML .= "<Visible><T>Bool</T><D>0</D></Visible>\n";
	$schematicXML .= "</Item>\n";
	$schematicXML .= "<Item XName=\"Font\" Type=\"Font\">\n";
	$schematicXML .= "<Size><T>Double</T><D>62.5</D></Size>\n";
	$schematicXML .= "</Item>\n";
	$schematicXML .= "<CenterX><T>Double</T><D>0</D></CenterX>\n";
	$schematicXML .= "<CenterY><T>Double</T><D>0</D></CenterY>\n";
	$schematicXML .= "<Item XName=\"Display0\" Type=\"SchematicDisp\">\n";
	$schematicXML .= "<PVPort>\n";
	$schematicXML .= "<T>Array_Dbl64</T>\n";
	$schematicXML .= "<D>1;4;GW012PTrv1C;cjkKjeN}52C;48GW01Y9K24;pMNgRGzyG24</D>\n";
	$schematicXML .= "</PVPort>\n";
	$schematicXML .= "<DVport>\n";
	$schematicXML .= "<T>Array_Dbl64</T>\n";
	$schematicXML .= "<D>1;4;;;k224;u324</D>\n";
	$schematicXML .= "</DVport>\n";
	$schematicXML .= "</Item>\n";

	my $inPortNum = $self->getInputPortNumber();
	my $outPortNum = $self->getOutputPortNumber();
	my $maxPortNum = ( $inPortNum > $outPortNum ) ? ( $inPortNum ) : ( $outPortNum );

	my $bodyHeight = $maxPortNum * 250.0;

	if ( $bodyHeight < 750 ) {
		$bodyHeight = 750;
	}

	my $bodyWidth = 750;

	my $portLength = 500;
	my $portSpacing = 250;

	my $posX = 0;
	my $posY = 0;

	if ( $inPortNum > 0 ) {
		$posX = $portLength;
		$posY = -( $bodyHeight - ( $inPortNum - 1 ) * $portSpacing ) / 2;
	}
	else {
		$posX = -( $portLength + $bodyWidth );
		$posY = -( $bodyHeight - ( $outPortNum - 1 ) * $portSpacing ) / 2;
	}

	$schematicXML .= $self->drawGenesysSymbolBody( $bodyHeight, $bodyWidth, $posX, -( $posY + $bodyHeight) );

	my $portCounter = 0;
	my $portX = 0;
	my $portY = 0;

	my $nextInputPort = $self->getInputPortIterator();

	while ( my $inPort = $nextInputPort->() ) {
		$portCounter++;
		$partListXML .= $self->addGenesysInputPortPart( $portCounter, $inPort );
		$schematicXML .= $self->drawGenesysPort( "INPUT", $portCounter, $portX, -$portY, $portLength, $inPort );
		$portY += $portSpacing;
	}

	if ( $inPortNum > 0 ) {
		$portX = $portLength + $bodyWidth;
		$portY = ( $inPortNum - $outPortNum ) * $portSpacing / 2;
	}
	else {
		$portX = -$portLength;
		$portY = 0;
	}
	
	my $nextOutputPort = $self->getOutputPortIterator();

	while ( my $outPort = $nextOutputPort->() ) {
		$portCounter++;
		$partListXML .= $self->addGenesysOutputPortPart( $portCounter, $outPort );
		$schematicXML .= $self->drawGenesysPort( "OUTPUT", $portCounter, $portX, -$portY, $portLength, $outPort );
		$portY += $portSpacing;
	}

	$partListXML .= "</Item>\n";

	$schematicXML .= "<Item XName=\"Font\" Type=\"Font\">\n";
	$schematicXML .= "<Size><T>Double</T><D>62.5</D></Size>\n";
	$schematicXML .= "</Item>\n";
	$schematicXML .= "<Item XName=\"Grid\" Type=\"Param\">\n";
	$schematicXML .= "<DataEntry>250</DataEntry>\n";
	$schematicXML .= "<Unit><T>Int</T><D>0</D></Unit>\n";
	$schematicXML .= "<Data><T>Double</T><D>250</D></Data>\n";
	$schematicXML .= "</Item>\n";
	$schematicXML .= "<ShowPage><T>Int</T><D>1</D></ShowPage>\n";
	$schematicXML .= "<Units><T>Int</T><D>6003</D></Units>\n";
	$schematicXML .= "<SymScale><T>Double</T><D>1</D></SymScale>\n";
	$schematicXML .= "<SymRotate><T>Double</T><D>0</D></SymRotate>\n";
	$schematicXML .= "</Item>\n";
	$schematicXML .= "<LibName>Symbols</LibName>\n";
	$schematicXML .= "</Item>\n";

	$xml .= $partListXML . $schematicXML;
	$xml .= "<Intent><T>Int</T><D>3</D></Intent>\n";
	$xml .= "</Item>\n\n\n";

#	open( XML_FILENAME, ">SYM_$compName.xml" );
#	print XML_FILENAME $xml;
#	close( XML_FILENAME );
	print $xml;
}



sub PtolemyComponent::drawGenesysSymbolBody {
	my $self = shift;
	my $height = shift;
	my $width = shift;
	my $posX = shift;
	my $posY =shift;
	my $xml = "";
	$xml .= "<Item XName=\"Annotate0\" Type=\"RectA\">\n";
	$xml .= "<Color><T>Int</T><D>16765676</D></Color>\n";
	$xml .= "<ZOrder><T>Int</T><D>0</D></ZOrder>\n";
	$xml .= "<BorderColor><T>Int</T><D>0</D></BorderColor>\n";
	$xml .= "<BorderWeight><T>Int</T><D>10</D></BorderWeight>\n";
	$xml .= "<BorderStyle><T>Int</T><D>0</D></BorderStyle>\n";
	$xml .= "<PosX><T>Double</T><D>$posX</D></PosX>\n";
	$xml .= "<PosY><T>Double</T><D>$posY</D></PosY>\n";
	$xml .= "<Width><T>Double</T><D>$width</D></Width>\n";
	$xml .= "<Height><T>Double</T><D>$height</D></Height>\n";
	$xml .= "<Treat ><T>Int</T><D>9</D></Treat>\n";
	$xml .= "<Filled><T>Int</T><D>1</D></Filled>\n";
	$xml .= "</Item>\n";
	return $xml;
}


sub PtolemyComponent::addGenesysInputPortPart {

	my $self = shift;
	my $portNum = shift;
	my $port = shift;
	my $portName = $port->name();
	my $portDesc = $port->description();

	my $xml = "";
	$xml .= "<Item XName=\"$portName\" Type=\"Part\">\n";
	$xml .= "<Model Help=\"318\">*INP</Model>\n";
	$xml .= "<Symbol Help=\"319\">INPUT</Symbol>\n";
	$xml .= "<Item XName=\"ParamSet\" Type=\"ParamSet\">\n";
	$xml .= "<Item XName=\"PORT\" Type=\"PartParam\">\n";
	$xml .= "<Description>Port Number</Description>\n";
	$xml .= "<Validate><T>Int</T><D>3</D></Validate>\n";
	$xml .= "<Unit><T>Int</T><D>0</D></Unit>\n";
	$xml .= "<Data><T>Double</T><D>$portNum</D></Data>\n";
	$xml .= "<DataEntry>$portNum</DataEntry>\n";
	$xml .= "<Show><T>Bool</T><D>0</D></Show>\n";
	$xml .= "</Item>\n";

	$xml .= "</Item>\n";
	$xml .= "<Description>$portDesc</Description>\n";
	$xml .= "<Netlist>Term_0,$portNum</Netlist>\n";
	$xml .= "<HideDes><T>Int</T><D>1</D></HideDes>\n";
	$xml .= "</Item>\n";
	return $xml;
}


sub PtolemyComponent::addGenesysOutputPortPart {

	my $self = shift;
	my $portNum = shift;
	my $port = shift;
	my $portName = $port->name();
	my $portDesc = $port->description();

	my $xml = "";
	$xml .= "<Item XName=\"$portName\" Type=\"Part\">\n";
	$xml .= "<Model Help=\"1826\">*OUT</Model>\n";
	$xml .= "<Symbol Help=\"1827\">OUTPUT</Symbol>\n";
	$xml .= "<Item XName=\"ParamSet\" Type=\"ParamSet\">\n";

	$xml .= "<Item XName=\"PORT\" Type=\"PartParam\">\n";
	$xml .= "<Description>Port Number</Description>\n";
	$xml .= "<Validate><T>Int</T><D>3</D></Validate>\n";
	$xml .= "<Unit><T>Int</T><D>0</D></Unit>\n";
	$xml .= "<Data><T>Double</T><D>$portNum</D></Data>\n";
	$xml .= "<DataEntry>$portNum</DataEntry>\n";
	$xml .= "<Show><T>Bool</T><D>0</D></Show>\n";
	$xml .= "</Item>\n";
	$xml .= "</Item>\n";
	$xml .= "<Description>$portDesc</Description>\n";
	$xml .= "<Netlist>Term_0,$portNum</Netlist>\n";
	$xml .= "<ParentPartName>OUT_OUTPUT</ParentPartName>\n";
	$xml .= "<SectionNum><T>Int</T><D>0</D></SectionNum>\n";
	$xml .= "<Footprint UserName=\"Footprint\" Help=\"1833\"/>\n";
	$xml .= "<Category>Basic</Category>\n";
	$xml .= "<HideDes><T>Int</T><D>1</D></HideDes>\n";
	$xml .= "</Item>\n";
	return $xml;
}


sub drawGenesysPort {
	my $self = shift;
	my $type = shift;
	my $portCounter = shift;
	my $X1 = shift;
	my $Y = shift;
	my $portLength = shift;
	my $X2 = $X1 + $portLength;
	my $port = shift;
	my $portName = $port->name();

	my $portX = $X1;
	my $rotation = 0;

	if ( "$type" eq "INPUT" ) {
		$rotation = 180;
	}
	else {
		$portX += $portLength;
	}

	my $xml = "";

	$xml .= "<Item XName=\"Part" . $portCounter . "\" Type=\"SchPart\">\n";
	$xml .= "<Designator>$portName</Designator>\n";
	$xml .= "<Symbol>$type</Symbol>\n";
	$xml .= "<CenterX>0</CenterX>\n";
	$xml .= "<CenterY>83</CenterY>\n";
	$xml .= "<PosX>$portX</PosX>\n";
	$xml .= "<PosY>" . ( $Y - 83 ) . "</PosY>\n";
	$xml .= "<Rotate>$rotation</Rotate>\n";
	$xml .= "</Item>\n";

	$xml .= "<Item XName=\"Port" . $portCounter . "\" Type=\"LineA\">\n";
	$xml .= "<StartArrowhead><T>Int</T><D>0</D></StartArrowhead>\n";
	$xml .= "<EndArrowhead><T>Int</T><D>0</D></EndArrowhead>\n";
	$xml .= "<Coords><T>Array_Double</T><D>1;4;$X1;$Y;$X2;$Y</D></Coords>\n";
	$xml .= "<Filled><T>Bool</T><D>0</D></Filled>\n";
	$xml .= "<Color><T>Int</T><D>16757983</D></Color>\n";
	$xml .= "<ZOrder><T>Int</T><D>$portCounter</D></ZOrder>\n";
	$xml .= "<BorderColor><T>Int</T><D>8388608</D></BorderColor>\n";
	$xml .= "<BorderWeight><T>Int</T><D>10</D></BorderWeight>\n";
	$xml .= "<BorderStyle><T>Int</T><D>0</D></BorderStyle>\n";
	$xml .= "<PosX><T>Double</T><D>0</D></PosX>\n";
	$xml .= "<PosY><T>Double</T><D>0</D></PosY>\n";
	$xml .= "<Treat ><T>Int</T><D>6</D></Treat>\n";
	$xml .= "</Item>\n";

	return $xml;
}


############################################################################
#
# Creates Genesys part info
#
############################################################################

sub PtolemyComponent::createGenesysPart {

	my $self = shift;
	my $compName = $self->name();
	my $compDesc = $self->description();
	my $library = $self->library();
	my $instName = $self->instance_name();

	my $tier1 = $library;
	$tier1 =~ s/([^,]+),(.*)/$1/;

	my $tier2 = $library;
	$tier2 =~ s/([^,]+),(.*)/$2/;
	$tier2 =~ s/^\W+//;

#	if ( "$tier1" eq "$tier2" ) {
#		$tier2 = "";
#	}

	my $symbolName;

	if ( exists( $PtolemyComponent::symbolNameMap{ $compName } ) ) {
		$symbolName = $PtolemyComponent::symbolNameMap{ $compName };
	}
	else {
		$symbolName = "SYM_$compName";
	}

	my $type = $self->model_type();
	my $dataFlowLib = "";

	if ( $type eq "STAR" ) {
		$dataFlowLib = $self->netlist_name();
		$dataFlowLib =~ s/.*_l(.*)/$1/;
		$dataFlowLib =~ s/_x5f/_/g;
		if ( "$dataFlowLib" ne "" ) {
			$dataFlowLib .= " ";
		}
	}

	my $xml = "";
	$xml .= "<Item XName=\"$compName\" UserName=\"$compName\" Type=\"LibPart\">\n";
	$xml .= "<Item XName=\"Sections\" Type=\"SerItem\">\n";
	$xml .= "<Item XName=\"Section\" Type=\"LibSect\">\n";
	$xml .= "<Model>$compName@" . $dataFlowLib . "Data Flow Models</Model>\n";
	$xml .= "<ModelSet>$compName@" . $dataFlowLib . "Data Flow Models</ModelSet>\n";
	$xml .= "<Symbol>$symbolName@" . $dataFlowLib . "Data Flow Symbols</Symbol>\n";
	$xml .= "<SymbolSet>$symbolName@" . $dataFlowLib . "Data Flow Symbols</SymbolSet>\n";
	$xml .= "</Item>\n";
	$xml .= "</Item>\n";
	$xml .= "<Category>$tier2</Category>\n";
	$xml .= "<Description>$compDesc</Description>\n";
	$xml .= "<LibName>Comms Architect</LibName>\n";
	$xml .= "<AutoDes>$instName</AutoDes>\n";
	$xml .= "</Item>\n\n\n";
	print $xml;
}



############################################################################
#
# Creates wiki markup for parameter, input, and output tables
#
# First argument is footnotes, which are obtained from the *.pl.xml file
# (they are not available in the *.xml file because they are not part of
# the NamedObj class). This argument could be an empty string.
#
############################################################################

sub PtolemyComponent::createWiki {

	my $self = shift;
	my $footnotes = shift;
	
	my $compName = $self->name();
	my $compDesc = $self->description();
	my $library = $self->library();
	my $wiki = "";

	$wiki .= "*Description:* $compDesc\n";
	$wiki .= "*Library:* $library\n\n";

	my $paramTable = "";

	if ( $self->getParameterNumber() > 0 ) {

		$paramTable .= "h5. Parameters\n\n";
		$paramTable .= "|| Name || Description || Default || Symbol || Unit || Type || Range ||\n";

		my $symbolDefined = "FALSE";
		my $unitDefined = "FALSE";
		my $rangeDefined = "FALSE";
		
		my $nextParameter = $self->getParameterIterator();
		
		while ( my $parameter = $nextParameter->() ) {

			my $paramName = $parameter->name();
			my $paramDescription = $parameter->description();
			my $paramDefault = $parameter->default();

			$paramDefault =~ s/-/\\-/g;    # escape - so that they are not interpreted as strikethrough formatting

			my $paramSymbol = $parameter->symbol();
			if ( ! defined $paramSymbol ) {
				$paramSymbol = "";
			}
			else {
				$symbolDefined = "TRUE";
			}

			if ( $paramSymbol =~ /\.gif$/ ) {
				$paramSymbol =~ s/.gif$/;/;
				$paramSymbol = "&" . $paramSymbol;
			}

			my $paramUnit = $parameter->unit();
			if ( $paramUnit ne "" ) {
				$unitDefined = "TRUE";
			}

			my $paramType = $parameter->type();
			
			if ( $paramType eq "enum" ) {

				my $nextEnum = $parameter->getEnumIterator();
				my $enum = $nextEnum->();
				
				$paramDescription .= ": " . $enum->alias();
				
				while ( $enum = $nextEnum->() ) {
					$paramDescription .= ", " . $enum->alias();
				}
			
			}
			
			my $paramValueRange = $parameter->value_range();
			if ( ! defined $paramValueRange ) {
				$paramValueRange = "";
			}
			else {
				$rangeDefined = "TRUE";
			}

			$paramValueRange =~ s/:/,/g;                          # replace ':' with ','
			$paramValueRange =~ s/dagger.gifdagger.gif/&#135;/;   # replace 'dagger.gifdagger.gif' with its HTML code
			$paramValueRange =~ s/dagger.gif/&#134;/;             # replace 'dagger.gif' with its HTML code
			$paramValueRange =~ s/inf/&#8734;/g;                  # replace inf with its HTML code

			$paramTable .= "| $paramName | $paramDescription | $paramDefault | $paramSymbol | $paramUnit | $paramType | $paramValueRange |\n";
		}

# Remove empty Symbol column; {3} is used because the symbol column is column 4.
# Match exactly 3 sections of the form "|xyz", the fourth "empty" one "|  ", and everything else.

		if ( "$symbolDefined" eq "FALSE" ) {
			$paramTable =~ s/^((\|[^\|]+){3})\|  (\|.+)$/$1$3/gm;
			$paramTable =~ s/ Symbol \|\|//;
		}
		
# Remove empty Unit column; {4} is used because the unit column is column 5.
# However, if the symbol column has been removed then {3} is used.

		if ( "$unitDefined" eq "FALSE" ) {
			$paramTable =~ s/^((\|[^\|]+){3,4})\|  (\|.+)$/$1$3/gm;
			$paramTable =~ s/ Unit \|\|//;
		}

# Remove empty Range column; {6} is used because the Range column is column 7.
# However, if the symbol and/or unit columns have been removed then {4} or {5} is used.

		if ( "$rangeDefined" eq "FALSE" ) {
			$paramTable =~ s/^((\|[^\|]+){4,6}\|)  \|$/$1/gm;
			$paramTable =~ s/ Range \|\|//;
		}

		$paramTable =~ s/(\(|\)|\[|\]|\{|\})/\\$1/g;  # escape parentheses, square brackets, and curly braces
		$paramTable =~ s:<sub>([^<]+)</sub>: ~$1~:g;  # replace <sub>foo</sub> with ~foo~
		$paramTable =~ s:<sup>([^<]+)</sup>: ^$1^:g;  # replace <sup>foo</sup> with ^foo^

		$paramTable .= "\n";
		
		if ( "$footnotes" ne "" ) {
			$footnotes =~ s/(\(|\)|\[|\]|\{|\})/\\$1/g;  # escape parentheses, square brackets, and curly braces
			$footnotes =~ s/\\n.*?dagger.gifdagger.gif/\\\\&#135;/; # replace 'dagger.gifdagger.gif' with its HTML code
			$footnotes =~ s/dagger.gif/&#134;/;                     # replace 'dagger.gif' with its HTML code
			$footnotes =~ s/\\n/\\\\/g;
			$paramTable .= "$footnotes\n";
		}
	}

	$wiki .= $paramTable;

	my $inputPortNumber = $self->getInputPortNumber();
	
	if ( $inputPortNumber > 0 ) {
		$wiki .= "h5. Pin Inputs\n\n";
		$wiki .= "|| Pin || Name || Description || Signal Type ||\n";
	}
		
	my $nextPort = $self->getPortIterator();
		
	while ( my $port = $nextPort->() ) {
		
		my $pin_no = $port->pin_no();
		
		if ( $pin_no == $inputPortNumber + 1 ) {
			$wiki .= "\n";
			$wiki .= "h5. Pin Outputs\n\n";
			$wiki .= "|| Pin || Name || Description || Signal Type ||\n";
		}

		my $name = $port->name();

		my $description = $port->description();
		if ( ( ! defined $description ) || ( "$description" eq "" ) ) {
			$description = "$name signal";
		}

		my $type = $port->type();
			
		$wiki .= "| $pin_no | $name | $description | $type |\n";
	}
		
	$wiki .= "\n";

# Replace (y), (n), (i), (x) with \(y\), \(n\), \(i\), \(x\)
# because (y), (n), (i), (x) have special meaning for the wiki.
	$wiki =~ s/\((y|x|i|n)\)/\\($1\\)/g;

	open( WIKI_FILENAME, ">$compName" . "_AutoDoc.txt" );
	print WIKI_FILENAME $wiki;
	close( WIKI_FILENAME );

}


1;
