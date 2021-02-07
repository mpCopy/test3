sub file_copy
{
    local($src, $dest) = @_;

    unlink("$dest");

    open(IN, "<$src")   || die "Can't open $src: $!\n";
    open(OUT, ">$dest") || die "Can't open $dest $!\n";
    while ($line = <IN>)
    {
	print OUT $line;
    }
    close(IN);
    close(OUT);
}

## This script assumes a current working directory of $HPEESOF_DIR

$libName = $ARGV[0];
$hped = $ENV{"HPEESOF_DIR_ARCH"} || $ENV{"HPEESOF_DIR"};
$x1 = $ENV{"HPEESOF_DIR_ARCH"};
$x2 = $ENV{"HPEESOF_DIR"};

open(LOGFILE, ">/tmp/enc.log");
print LOGFILE "hped is $hped\n";
print LOGFILE "x1 is $x1\n";
print LOGFILE "x2 is $x2\n";

#Make sure that HPEESOF_DIR is set for hpedlibgen to run properly
$ENV{"HPEESOF_DIR"}=$hped;
$x2 = $ENV{"HPEESOF_DIR"};

print LOGFILE "x2 is now $x2\n";
close(LOGFILE);

## If this is a windows platform then replace the bitmap file
$arch = $ARGV[2];
if (($arch =~ "Win") || ($arch =~ "CYGWIN"))
{
  ## get all files in dir
  $dirtoget="$hped/CustomEncoded/$libName/bitmaps";
  opendir(IMD, $dirtoget) || die("Cannot open directory");
  @BMPFILES=readdir(IMD);
  closedir(IMD);

  foreach $bmpfile ( @BMPFILES )
  {
    unless( ($bmpfile eq ".") || ($bmpfile eq "..")) 
    {
      ## Only copy files with .win32 extension
      if (substr( $bmpfile, length($bmpfile)-6, 6) eq ".win32")
      {
        $outfile=substr($bmpfile, 0, length($bmpfile)-6);
        file_copy("$hped/CustomEncoded/$libName/bitmaps/$bmpfile",
	  "$hped/CustomEncoded/$libName/bitmaps/$outfile.bmp");
      }
    }
    ##file_copy("$hped/CustomEncoded/$libName/bitmaps/encoded.win32", 
    ##	 "$hped/CustomEncoded/$libName/bitmaps/encoded.bmp");
    $bootscript = " ";
  }
} else
{
    $bootscript = "\. $hped/bin/bootscript.sh;";
}

## Compile the AEL files

$defAEL = "$hped/CustomEncoded/ael/".$libName."_encode_def.ael";
$defATF = "$hped/CustomEncoded/ael/".$libName."_encode_def.atf";
$itemAEL = "$hped/CustomEncoded/ael/".$libName."_encode_item.ael";
$itemATF = "$hped/CustomEncoded/ael/".$libName."_encode_item.atf";
`$bootscript $hped/bin/aelcomp $defAEL $defATF`;
`$bootscript $hped/bin/aelcomp $itemAEL $itemATF`;

## Run hpeesoflibgen to generate *.idf file
$aelFile = "$hped/CustomEncoded/ael/"."$libName"."_encode_item.ael";
`$bootscript $hped/bin/hpedlibgen -in $aelFile -out $hped/CustomEncoded/records/$libName.idf`;

## Modify the de_encode_master.ael file to include this libraries palette defintions
## file
$masterFile = "$hped/CustomEncoded/ael/de_encode_master.ael";
$defFile1 = "CustomEncoded/ael/$libName"."_encode_def";
$defFile = "strcat(expandenv(\"\$HPEESOF_DIR\"),api_get_directory_delimiter(),\"$defFile1\")";
	    
open(MASTERFILE, ">>$masterFile") or die;
print MASTERFILE "load($defFile);\n";
close(MASTERFILE);
$masterFileATF = "$hped/CustomEncoded/ael/de_encode_master.atf";
`$bootscript $hped/bin/aelcomp $masterFile $masterFileATF`;

## Modify ADSlibconfig
## If there is an entry for this library, replace it, if not make a new one.
chmod 0666, "$hped/circuit/config/ADSlibconfig";
open(ADSLIBCONFIG, "<$hped/circuit/config/ADSlibconfig") or die;
open(ADSLIBCONFIG2, ">$hped/circuit/config/ADSlibconfig.new") or die;
$entryMade = 0;
while ($line = <ADSLIBCONFIG>)
{
    chop $line;
    @temp = split /\s+/, $line;
    if ($temp[0] eq $libName)
    {
	print ADSLIBCONFIG2 "$libName	\$HPEESOF_DIR/CustomEncoded/models/$libName.library\n";
	$entryMade = 1;
    }
    else
    {
	print ADSLIBCONFIG2 "$line\n";
    }
}
if ($entryMade == 0)
{
    print ADSLIBCONFIG2 "$libName	\$HPEESOF_DIR/CustomEncoded/models/$libName.library\n";
}

close(ADSLIBCONFIG);
close(ADSLIBCONFIG2);
##copy("circuit/config/ADSlibconfig", "circuit/config/ADSlibconfig.old");
file_copy("circuit/config/ADSlibconfig.new", "circuit/config/ADSlibconfig");
unlink("circuit/config/ADSlibconfig.new");

## Modify the hpeesofbrowser.cfg file to add the search path for HPTOLEMY stuff
open(BROWCFG, "<$hped/config/hpeesofbrowser.cfg") or die;
open(BROWCFG2, ">$hped/config/hpeesofbrowser.new") or die;

while ($line = <BROWCFG>)
{
    chop $line;
    @temp = split /=/, $line;
    if ($temp[0] =~ /HPVENDORLIB_BROWSER_PATH/)
    {
	if ($line !~ /CustomEncoded/)
	{
	    $line = $line.";\$HPEESOF_DIR/CustomEncoded/records";
        }
    }
    print BROWCFG2 "$line\n";
}
close(BROWCFG);
close(BROWCFG2);
file_copy("config/hpeesofbrowser.new", "config/hpeesofbrowser.cfg");
unlink("config/hpeesofbrowser.new");

## Modify the hpeesofsim.cfg file to add the search path
## for any simulation data files that might be referenced.
open(SIMCFG, "<$hped/config/hpeesofsim.cfg") or die;
open(SIMCFG2, ">$hped/config/hpeesofsim.new") or die;

while ($line = <SIMCFG>)
{
    chop $line;
    @temp = split /=/, $line;
    if ($temp[0] =~ /^SIM_FILE_PATH/)
    {
       $line = $line.":\$HPEESOF_DIR/CustomEncoded/$libName/data";
    }
    print SIMCFG2 "$line\n";
}
close(SIMCFG);
close(SIMCFG2);
file_copy("config/hpeesofsim.new", "config/hpeesofsim.cfg");
unlink("config/hpeesofsim.new");


exit 0;
