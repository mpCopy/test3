use File::Copy;

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
	    if ($line !~ /CustomEncoded/)
	    {
	        print NewConfig "$line;\$HPEESOF_DIR/CustomEncoded/symbols\n";
            }
	    else
	    {
		print NewConfig "$line\n";
            }
        }
	elsif ($temp[0] eq "ANALOG_RF_SIMULATOR_AEL")
	{
	    if ($line !~ /CustomEncoded/)
	    {
	        print NewConfig "$line:{\$HPEESOF_DIR}/CustomEncoded/ael/de_encode_master\n";
            }
	    else
	    {
		print NewConfig "$line\n";
            }
	}
	elsif ($temp[0] eq "DSP_SIMULATOR_AEL")
	{
	    if ($line !~ /CustomEncoded/)
	    {
	        print NewConfig "$line:{\$HPEESOF_DIR}/CustomEncoded/ael/de_encode_master\n";
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
   
    if ($menu == 1)
    {
	##Create/modify the file de_encode_master.ael
	$masterFile = "$hped/CustomEncoded/ael/de_encode_master.ael";
	$defFile = "de_encode_menu";
	open(MASTERFILE, ">>$masterFile") or die;
	print MASTERFILE "load(\"$defFile\");\n";
	close(MASTERFILE);

        #Add a function call to usermenu.ael
        open(NewMenu, ">$hped/de/ael/usermenu.new");
        open(OldMenu, "<$hped/de/ael/usermenu.ael");
        while (($line = <OldMenu>) && ($line !~ /defun app_add_user_menus/))
        {
	    print NewMenu $line;
        }
        print NewMenu $line;
        while (($line = <OldMenu>) && ($line !~ /{/))
        {
	    print NewMenu $line;
        }
        print NewMenu $line;
        while (($line = <OldMenu>) && !(($line =~ /winTempId/) && ($line =~ /SCHEMATIC_WINDOW/)))
        {
	    print NewMenu $line;
        }
        print NewMenu $line;
        while (($line = <OldMenu>) && ($line !~ /{/))
        {
            print NewMenu $line;
        }
        print NewMenu $line;
        print NewMenu "        de_encode_add_menu();\n";
        while ($line = <OldMenu>)
        {
	    print NewMenu $line;
        }
        close(NewMenu);
        close(OldMenu);
        copy("$hped/de/ael/usermenu.ael", "$hped/de/ael/usermenu.ael.old");
        copy("$hped/de/ael/usermenu.new", "$hped/de/ael/usermenu.ael");
        unlink("$hped/de/ael/usermenu.new");
    }
}
else
{
    #Uninstall mode

    if ($menu == 1)
    {
	## Modify de_encode_master.ael -- remove entry for this library
	$defFile = "de_encode_menu";
	open(MASTERFILE, "<$hped/CustomEncoded/ael/de_encode_master.ael") or die;
	open(MASTERFILE2, ">$hped/CustomEncoded/ael/de_encode_master.new") or die;
	$numLines=0;
	while ($line = <MASTERFILE>)
	{
	    chop $line;
 	    @temp = split /\s+/, $line;
	    if ($temp[0] !~ /$defFile/)
	    {
	       print MASTERFILE2 "$line\n";
	    }
	    $numLines++;
	}
	close(MASTERFILE);
	close(MASTERFILE2);
	if ($numLines > 1)
	{
	    ##copy("$hped/CustomEncoded/ael/de_encode_master.ael",
	    ##     "$hped/CustomEncoded/ael/de_encode_master.old");
	    copy("$hped/CustomEncoded/ael/de_encode_master.new",
		     "$hped/CustomEncoded/ael/de_encode_master.ael");
	    unlink("$hped/CustomEncoded/ael/de_encode_master.new");
	    unlink("$hped/CustomEncoded/ael/de_encode_master.atf");
	}
	else
	{
	 ##If the file is empty, just get rid of it all together
	    unlink("$hped/CustomEncoded/ael/de_encode_master.ael");
	    unlink("$hped/CustomEncoded/ael/de_encode_master.new");
	    unlink("$hped/CustomEncoded/ael/de_encode_master.atf");
	}

        # Take out the menu add-on
        open(NewMenu, ">$hped/de/ael/usermenu.new");
        open(OldMenu, "<$hped/de/ael/usermenu.ael");
        while ($line = <OldMenu>)
        {
	    if ($line !~ /de_encode_add_menu/)
  	    {
	        print NewMenu $line;
            }
        }
        close(NewMenu);
        close(OldMenu);
        copy("$hped/de/ael/usermenu.ael", "$hped/de/ael/usermenu.ael.old");
        copy("$hped/de/ael/usermenu.new", "$hped/de/ael/usermenu.ael");
        unlink("$hped/de/ael/usermenu.new");
    }

    ##This is used to check if the file is there anymore
    $noFile = 0;
    open(MASTERFILE, "<$hped/CustomEncoded/ael/de_encode_master.ael") or $noFile = 1;
    close(MASTERFILE);

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
		if ($temp !~ "CustomEncoded")
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
		if ($temp !~ "CustomEncoded")
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
		if ($temp !~ "CustomEncoded")
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
