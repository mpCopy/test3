use File::Copy;
# Copyright Keysight Technologies 2002 - 2013  

$mode = $ARGV[0]; 
$hped = $ENV{"HPEESOF_DIR_ARCH"} || $ENV{"HPEESOF_DIR"};
$menu = $ARGV[2];

if ($mode == 1)
{
    #Install mode
    open(NewConfig, ">$hped/config/de_sim.cfg.new");
    open(OldConfig, "<$hped/config/de_sim.cfg");
    while ($line = <OldConfig>)
    {
	chop $line;
	@temp = split /=/,$line;
	if ($temp[0] eq "SYSTEM_CIRCUIT_SYMBOLS")
	{
	    if ($line !~ /ComponentLibs/)
	    {
	        print NewConfig "$line;\$HPEESOF_DIR/ComponentLibs/symbols\n";
            }
	    else
	    {
		print NewConfig "$line\n";
            }
        }
	else
	{ 
	    print NewConfig "$line\n";
        }
    }
    close(NewConfig);
    close(OldConfig);
    copy("$hped/config/de_sim.cfg", "$hped/config/de_sim.cfg.old");
    copy("$hped/config/de_sim.cfg.new", "$hped/config/de_sim.cfg");
    unlink("$hped/config/de_sim.cfg.new");
   
}
else
{
    #Uninstall mode

    ##This is used to check if the file is there anymore
    $noFile = 0;
#    open(MASTERFILE, "<$hped/ComponentLibs/ael/de_encode_master.ael") or $noFile = 1;
#    close(MASTERFILE);

    open(NewConfig, ">$hped/config/de_sim.cfg.new");
    open(OldConfig, "<$hped/config/de_sim.cfg");
    while ($line = <OldConfig>)
    {
	chop $line;
	@temp = split /=/,$line;
	if (($temp[0] =~ "SYSTEM_CIRCUIT_SYMBOLS")
	    && ($noFile == 1))
	{
	    @temp = split /;/,$line;
	    $line = "";
	    foreach $temp(@temp)
	    {
		if ($temp !~ "ComponentLibs")
		{
		    if ($line eq "")
		    {
			$line = $temp;
                    }
		    else
		    {
			$line = $line.";".$temp;
                    }
		}
            }
        }
	elsif (($temp[0] =~ "ANALOG_RF_SIMULATOR_AEL")
	   &&  ($noFile == 1))
	{
	    @temp = split /:/,$line;
	    $line = "";
	    foreach $temp(@temp)
	    {
		if ($temp !~ "ComponentLibs")
		{
		    if ($line eq "")
		    {
			$line = $temp;
                    }
		    else
		    {
			$line = $line.":".$temp;
                    }
		}
            }
	}
	elsif (($temp[0] =~ "DSP_SIMULATOR_AEL")
	   &&  ($noFile == 1))
	{
	    @temp = split /:/,$line;
	    $line = "";
	    foreach $temp(@temp)
	    {
		if ($temp !~ "ComponentLibs")
		{
		    if ($line eq "")
		    {
			$line = $temp;
                    }
		    else
		    {
			$line = $line.":".$temp;
                    }
		}
            }
	}
        print NewConfig "$line\n";
    }
    close(NewConfig);
    close(OldConfig);
    copy("$hped/config/de_sim.cfg", "$hped/config/de_sim.cfg.old");
    copy("$hped/config/de_sim.cfg.new", "$hped/config/de_sim.cfg");
    unlink("$hped/config/de_sim.cfg.new");

}
