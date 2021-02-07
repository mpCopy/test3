
# Copyright Keysight Technologies 2002 - 2013  
sub file_copy
{
    local($src, $dest) = @_;
    open(IN, "<$src");
    open(OUT, ">$dest");
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

## Remove the *.idf file
unlink("$hped/ComponentLibs/records/$libName.idf");
## Remove the *.atf files
unlink("$hped/ComponentLibs/ael/$libName"."_encode_item.atf");
unlink("$hped/ComponentLibs/ael/$libName"."_encode_def.atf");

## Modify de_encode_master.ael -- remove entry for this library
#$defFile = "ComponentLibs/ael/".$libName."_encode_def";
#open(MASTERFILE, "<$hped/ComponentLibs/ael/de_encode_master.ael") or die;
#open(MASTERFILE2, ">$hped/ComponentLibs/ael/de_encode_master.new") or die;
#$numLines=0;
#while ($line = <MASTERFILE>)
#{
#    chop $line;
#    @temp = split /\s+/, $line;
#    if ($temp[0] !~ /$defFile/)
#    {
#	print MASTERFILE2 "$line\n";
#    }
#    $numLines++;
#}
#close(MASTERFILE);
#close(MASTERFILE2);
if ($numLines > 0)
{
    ##file_copy("$hped/ComponentLibs/ael/de_encode_master.ael", 
    ##     "$hped/ComponentLibs/ael/de_encode_master.old");
#    file_copy("$hped/ComponentLibs/ael/de_encode_master.new", 
#         "$hped/ComponentLibs/ael/de_encode_master.ael");
#    unlink("$hped/ComponentLibs/ael/de_encode_master.new");
#    unlink("$hped/ComponentLibs/ael/de_encode_master.atf");

    ## Now the ael file must be recompiled
    $arch = $ARGV[2];
    if (($arch =~ "Win") || ($arch =~ "CYGWIN"))
    {
	$bootscript = " ";
    }
    else
    {
	$bootscript = "\. $hped/bin/bootscript.sh;";
    }
#    $fileAEL = "$hped/ComponentLibs/ael/de_encode_master.ael";
#    $fileATF = "$hped/ComponentLibs/ael/de_encode_master.atf";
#    `$bootscript $hped/bin/aelcomp $fileAEL $fileATF`;
}
else
{
    ##If the file is empty, just get rid of it all together
#    unlink("$hped/ComponentLibs/ael/de_encode_master.ael");
#    unlink("$hped/ComponentLibs/ael/de_encode_master.new");
#    unlink("$hped/ComponentLibs/ael/de_encode_master.atf");
}

## Modify ADSlibconfig -- remove the entry for this library
chmod 0666, "$hped/circuit/config/ADSlibconfig";
open(ADSLIBCONFIG, "<$hped/circuit/config/ADSlibconfig") or die;
open(ADSLIBCONFIG2, ">$hped/circuit/config/ADSlibconfig.new") or die;
$entryMade = 0;
while ($line = <ADSLIBCONFIG>)
{
    chop $line;
    @temp = split /\s+/, $line;
    if ($temp[0] ne $libName)
    {
	print ADSLIBCONFIG2 "$line\n";
    }
}

close(ADSLIBCONFIG);
close(ADSLIBCONFIG2);
##file_copy("$hped/circuit/config/ADSlibconfig", "$hped/circuit/config/ADSlibconfig.old");
file_copy("$hped/circuit/config/ADSlibconfig.new", "$hped/circuit/config/ADSlibconfig");
unlink("$hped/circuit/config/ADSlibconfig.new");

exit 0;
