eval 'exec $HPEESOF_DIR/tools/bin/perl -S $0 ${1+"$@"}'
# Copyright Keysight Technologies 2015 - 2015  
if 0;

use File::Basename;
use File::Path;
use File::Copy;
use File::Temp qw(tempdir);

not $ENV{'HPEESOF_DIR'} || die "ERROR: The HPEESOF_DIR environment variable must be set to run a Momentum simulation.\n";

not $ENV{'MOM_MODULE_PATH'} || die "ERROR: The MOM_MODULE_PATH environment variable must be set to build Momentum substrate Database.\n";

my $MomModulePath = $ENV{'MOM_MODULE_PATH'};

if ( -d $MomModulePath ) {
  print "--------------------------------\n";
  print "Script to build Momentum Substrate Database...\n";
  print "--------------------------------\n";
}
else
{
  die "ERROR: $MOM_MODULE_PATH directory is not valid.\n";
}


print "--------------------------------\n";

print "Specify Maximum frequency (GHz) - Default=40GHz :";
my $MomMaxFreq = <STDIN> ;
chomp($MomMaxFreq);

if (($MomMaxFreq =~ /^[+-]?\d+$/) or (length($MomMaxFreq) == 0) ) {
  if (length($MomMaxFreq) == 0)
  {
    $MomMaxFreq=40;
  }
}
else
{
  die "ERROR: This is not a valid frequency\n";
}

print "--------------------------------\n";
print "Launching Momentum Engine\n";
print "--------------------------------\n";

my $MomTempDir = tempdir( CLEANUP => 1 );
chdir $MomTempDir;

my $dir = $MomModulePath . "/MomentumSDB";
opendir(DIR, $dir) or die $!;
while (my $file = readdir(DIR)) {

  next unless (-f "$dir/$file");
  next unless ($file =~ m/\.ltd$/);
  
  print "LTD file: $file\n";

  open(projFileH, ">proj.sti") or die "cannot create \"proj.sti\" file in $MomTempDir\n";
  print projFileH "START 0 STOP ".$MomMaxFreq." LIN 2,\n";
  print projFileH "AFS S_50 MAXSAMPLES 15.0 SAMPLING ALL NORMAL,\n;";
  close(projFileH);
  
  open(projFileH, ">proj.cfg") or die "cannot create \"proj.cfg\" file in $MomTempDir\n";
  print projFileH "site = ".$MomModulePath."/MomentumSDB\n\n";
  close(projFileH);
  
  copy("$dir/$file", "proj.ltd") or die "Cannot copy $file in $MomTempDir\n";
  
  open(projFileH, ">runSimulation.sh") or die "cannot create \"runSimulation.sh\" file in $MomTempDir\n";
  print projFileH "#!/bin/sh\n";
  print projFileH "adsMomWrapper --batch -O -DB --objMode=MW proj\n";
  close(projFileH);
  
  system "chmod a+x runSimulation.sh";
  system "./runSimulation.sh";
}
closedir(DIR);

1;



