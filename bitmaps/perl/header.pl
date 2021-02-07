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
# To find the standard supplied libraries in the local path
    use Cwd;
    $curDir = cwd;
}

use lib "$myLibPath";
use lib "$curDir";

