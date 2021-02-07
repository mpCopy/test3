package dKitGemx;

use strict;
use Carp;

############################################################################
####
##    Versioning stuff
#

my $VERSION = 2.0;

sub version
{
    return $VERSION;
}
#to be able to use perl versioning
$dKitAnalysis::VERSION = $VERSION;

############################################################################
####
##    socket port number stuff to communicate with daemon
#

my $defaultPortNumber = 12317;

####
# set/get portNumber for gemx protocol
# when setting portnumber it returns the old one....
#

sub
portNumber()
{
    my $self = shift;
    if (ref $self) 
    { 
	confess "Class method called as object method";
    }
    if (@_)
    {
        my $oldPortNumber = $defaultPortNumber;
	$defaultPortNumber = shift;
	return $oldPortNumber;
    }
    return $defaultPortNumber;
}

####
# set/get portNumber for gemx protocol
# when setting portnumber it returns the old one....
#

sub
defaultPortNumber()
{
    print "The function dKitGemx->defaultPortNumber will be obsoleted.\n";
    print "Use dKitGemx->portNumber instead.\n";
    my $self = shift;
    return $self->portNumber;
}


sub cti2ds($$)
{
    my $self = shift;
    if (ref $self) 
    { 
	confess "Class method called as object method";
    }
    my $ctifile = shift;
    my $dataset = shift;
    
    if (startService() == -1)
    {
        return -1;
    }

    print "Running the translation\n";
    my $hp = 'hpeesofdds CMD';
    &sndsckt( "$hp READFILE 3 0 $ctifile $dataset" );
    print "Translation Complete\n";

    stopService();

    return 0;
}


#### Debugging
my $Debugging = 0;

################################################
# class method : debug
# purpose : set debugging level for class
# call vocabulary
#
# dKitGemx->debug(level);
#   0 : debugging off.
#


sub debug {
    my $class = shift;
    if (ref $class) { confess "Class method called as object method";}
    unless (@_ == 1) { confess "usage : Component->debug(level)" }
    $Debugging = shift;
    if ($Debugging)
    {
        carp ("Circuit debugging turned on\n");
    } else
    {
        carp ("Circuit debugging turned off\n");
    }
}




#####low level communication functions

use Socket;
use FileHandle;

######
## start the gemx service on the port given
#  call vocabulary
#
#  startService(portNr))

my $gemxPid = -1;

sub startService(;$)
{
    if ($gemxPid != -1)
    {
	carp "Gemx service already started\nUsing existing service";
	return $gemxPid;
    }

    my $serverName="dKitGemxServer";

    my $port = shift;
    if (! $port)
    {
	$port = $defaultPortNumber;
    }

    my $hpeesof_dir = $ENV{'HPEESOF_DIR'};
    
    if (! $ENV{'LM_LICENSE_FILE'})
    {
	$ENV{'LM_LICENSE_FILE'}="$hpeesof_dir/licenses/license.dat";
    }
    if (! $ENV{'TK_LIBRARY'})
    {
	$ENV{'TK_LIBRARY'}="$hpeesof_dir/hptolemy/tools/tcltk/lib/tk8.0";
    }
    if (! $ENV{'TCL_LIBRARY'})
    {
	$ENV{'TCL_LIBRARY'}="$hpeesof_dir/hptolemy/tools/tcltk/lib/tcl8.0";
    }
    if (! $ENV{'WBMLANGPATH'})
    {
	$ENV{'WBMLANGPATH'}="$hpeesof_dir/circuit/bitmaps:$hpeesof_dir/de/bitmaps";
    }

    if ($^O =~ /win/i)
    {
	if ($Debugging > 10)
	{
	    print "on PC: start hpeesofemx -d stderr $serverName $port\n";
	    system("start hpeesofemx -d stderr $serverName $port");
	} else
	{
	    print "on PC: start hpeesofemx $serverName $port\n";
	    system("start hpeesofemx $serverName $port");
	}
    } else
    {
	if ($Debugging > 10)
	{
	    print "on unix :hpeesofemx -d stderr $serverName $port -d logfile &\n";
	    system("hpeesofemx -d stderr $serverName $port -d logfile &");
	} else
	{
	    print "on unix :hpeesofemx $serverName $port &\n";
	    system("hpeesofemx $serverName $port&");
	}
    }
    
    #try to connect to server
    my $connected = -10;
    while ($connected)
    {
	print "Connecting to the Server ($connected)\n";
	my $proto = getprotobyname('tcp');
	socket(S, PF_INET, SOCK_STREAM, $proto);
	my $sin = sockaddr_in($port, inet_aton("127.1"));
	if (connect(S,$sin))
        {
	    last;
	} 
	$connected += 1;
        sleep 1;
    }

    if (! $connected)
    {
	carp "Could not connect";
	return -1;
    }

    print "getting server process ID\n";
    my $hp = 'parent CMD';
    my $emxpid = &sndsckt( "$hp GETPID" );
    print "emxpid = $emxpid\n";
    if ($emxpid)
    {
	$gemxPid = $emxpid;
    }
    return $gemxPid;
}


sub stopService(;$)
{
    if ($gemxPid == -1)
    {
	carp "Gemx service was not running\n";
	return 0;
    }
    print "killing gemx process $gemxPid\n";
    close S;
    kill(1, $gemxPid);
    $gemxPid = -1;
    return 0;
}

sub sndsckt {
    my ($s) = @_;

    $s = join '$', $s, "\n";
    print "Send Socket $s\n";
    send( S, $s, 0 );
    recv( S, $s, 5000, 0 );
    print "Recv Socket $s\n";
    if ($s =~ /DONE\s+(.*)$/)
    {
        if ($1)
        {
            return $1;
        } else
        {
            return 1;
        }
    } else
    {
        carp("received $s\n");
        return 0;
    }
}






