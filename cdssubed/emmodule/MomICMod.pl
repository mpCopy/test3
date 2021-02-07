eval 'exec $HPEESOF_DIR/tools/bin/perl -S $0 ${1+"$@"}'
# Copyright Keysight Technologies 2011 - 2015  
if 0;

use warnings;
use strict;

use Getopt::Long;
use File::Basename;
use File::Path;
use File::Copy;

sub Usage()
{
    print "Usage: MomICMod.pl [<options>...] <moduleName> <techFilePath> <ltdFilePath> [<ltdFilePath>...]\n\n";
    print "<Options>\n";
    print "   --oDir <outputDir>           Set output directory\n";
};

my $showHelp = 0;
my ($viaNameRDL, $momModuleName, $momModulePath, $techFilePath, @ltdFilePaths, $ltdFilePath, $ltdFileName);
my $productPath=dirname($0);

GetOptions(
    "vrdl:s" => \$viaNameRDL,
    "oDir:s" => \$momModulePath,
    'help!' => \$showHelp
    );
	# print @ARGV;
($momModuleName, $techFilePath, @ltdFilePaths) = @ARGV;
# print @ltdFilePaths;
if ( $showHelp )
{
    Usage();
    exit 1;
}

length($momModuleName)>0 || die "ERROR: Please specify a module name\n";
length($techFilePath)>0 || die "ERROR: Please specify a technology file name\n";
scalar(@ltdFilePaths)>0 || die "ERROR: Please specify at least one LTD substrate file name\n";

if ( $momModulePath && -d $momModulePath )
{
  $momModulePath = $momModulePath."/".$momModuleName;
}
else
{
  $momModulePath = $momModuleName;
}

rmtree( $momModulePath );
mkpath(
  [$momModulePath,
   $momModulePath."/aa",
   $momModulePath."/etc",
   $momModulePath."/MomentumSDB",
   $momModulePath."/MomentumState",
   $momModulePath."/MomentumState/state",
   $momModulePath."/skill"]);

my @newFileList=(
  [$productPath."/source/simdata", $momModulePath."/MomentumState/state/simdata", "0644"],
  [$productPath."/source/init.il", $momModulePath."/skill/init.il", "0644"],
  [$productPath."/source/buildMomSDB.pl", $momModulePath."/etc/buildMomSDB.pl", "0755"],
  [$productPath."/source/README.txt", $momModulePath."/README.txt", "0644"],
  [$productPath."/source/cdsinit", $momModulePath."/aa/cdsinit", "0644"]
  );
for my $i (0 .. $#newFileList)
{
  my $basename=basename( $newFileList[$i][0] );
  #print "Copying \"$basename\" to \"$newFileList[$i][1]\"\n";
  copy($newFileList[$i][0],$newFileList[$i][1]) or die "Cannot copy \"$basename\" to \"$newFileList[$i][1]\"\n";
  chmod oct($newFileList[$i][2]), $newFileList[$i][1];
}

if ( $techFilePath && -e $techFilePath )
{
  my $fileName = basename($techFilePath);
  copy( $techFilePath, $momModulePath."/MomentumSDB/".$fileName) or die $!;
}

foreach $ltdFilePath (@ltdFilePaths)
{
  if ( -e $ltdFilePath )
  {
    my $ltdFileName = basename($ltdFilePath);
    copy( $ltdFilePath, $momModulePath."/MomentumSDB/".$ltdFileName) or die $!;
  }
}

#(options numberOfPerLayerOptions) 1
#(plOptions 1 uid) 1
#(plOptions 1 layerName) "padopen"
#(plOptions 1 useGlobalViaModelType) nil
#(plOptions 1 viaModelType) "3D-distributed"

if ( $viaNameRDL && length($viaNameRDL)>0)
{
    if ( -w $momModulePath."/MomentumState/state/simdata" )
    {
        my $filePath = $momModulePath."/MomentumState/state/simdata";
        open( my $fh, '>>', $filePath) or die "Could not open file '$filePath' $!";
        print $fh "(options numberOfPerLayerOptions) 1\n";
        print $fh "(plOptions 1 uid) 1\n";
        print $fh "(plOptions 1 layerName) \"".$viaNameRDL."\"\n";
        print $fh "(plOptions 1 useGlobalViaModelType) nil\n";
        print $fh "(plOptions 1 viaModelType) \"3D-distributed\"\n"; 
        close $fh;
    }
}

1;