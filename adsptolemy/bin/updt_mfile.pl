#!/hped/builds/bin/perl
# Copyright Keysight Technologies 2007 - 2017  
use File::Copy;


$MFILE=$ARGV[0];
chomp($MFILE);
if ( -f $MFILE )
{ print "Working on $MFILE \n"; }
else
{ print "Warning: can not find $MFILE \n"; 
  exit (0);
}

chmod(0777,$MFILE);
open(manfile, "<$MFILE") || die "Can't open $MFILE: $!\n";
open(tfile,">manifest_tmp.txt");
while( <manfile> )
{
  if ( m/name=\'Microsoft.VC80.CRT\'/o )
   {
    close(tfile);
    unlink("manifest_tmp.txt");
    print "Found Microsoft.VC80.CRT\n";
    exit (0);
   }


my $MYARCH=$ENV{CEDA_ARCH};
     
  if ( $_ =~ m/<\/assembly>/o )
  {

if  (  $MYARCH  =~ m/win32_64/o )
  {
# 64-bit setting
print tfile "
<dependency>
  <dependentAssembly>
     <assemblyIdentity type='win32' name='Microsoft.VC80.CRT' version='8.0.50727.762' processorArchitecture='amd64' publicKeyToken='1fc8b3b9a1e18e3b' />
   </dependentAssembly>
</dependency>
";
}
else
  {
# 32-bit setting    
print tfile "
<dependency>
  <dependentAssembly>
      <assemblyIdentity type='win32' name='Microsoft.VC80.CRT' version='8.0.50727.762' processorArchitecture='x86' publicKeyToken='1fc8b3b9a1e18e3b' />
   </dependentAssembly>
</dependency>
";
}


  }
  print tfile $_;

}
close(manfile);
close(tfile);
move("manifest_tmp.txt",$MFILE);

