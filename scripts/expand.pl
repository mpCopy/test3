
# Copyright Keysight Technologies 2002 - 2017  
use Cwd;
use File::Basename;

##This script does some preprocessing on the netlists before the encoding happens
##     1. Expands each argument file by looking for #includes and expanding them.
##     2. Then runs through each file and modifies the subcircuit names to 
##        prevent name clashes (and insert netlist version strings)
##
## Arguments: $ARGV[0] is the name of the library being created
##            $ARGV[1] is the path for the data file{s) if any.
##            $ARGV[2] is the path for the ADS project.
##            $ARGV[3] ... $ARGV[N] are the names of the netlist fragments to be modified

##Using file::copy means I need a shell script wrapped around this to set the
##include path -- blech!  -- instead do my own file copy...
##use File::Copy;

sub file_copy
{
    local($src, $dest) = @_;
    #extra checking for file handles
    unless(open(IN, "<$src"))
    {
        print  "\nFIOE:*$src"; #to display an internal error on encode dialog status box
        exit;
    }
    binmode(IN); # fix for IP_Encoder.207
    unless(open(OUT, ">$dest"))
    {
        print "\nFIOE:*$dest";
        exit;
    }
    binmode(OUT); #fix for IP_Encoder.207
    while ($line = <IN>)
    {
    print OUT $line;
    }
    close(IN);
    close(OUT);
}

@REVERSE = reverse @ARGV;
$libName = pop(@REVERSE);
$dataDir = pop(@REVERSE);
$projDir = pop(@REVERSE);
@Files = @REVERSE;
@FilesNotToBeModified = @Files;
############
@Files=(); #reset the variable;  this will be filled in the below code again.
#Praveen Vs- fix for IP_Encoder.185 and IP_Encoder.209 - Below lines are scans the 'libary.cfg' file and stores the
#first column contents as different array elements in @Files.
$cfgFileName = "library.cfg";
if(!(-e $cfgFileName))
{
    print "\nFIOE:*$cfgFileName\n";
        exit;
}
open(CfgFileHandle,"< $cfgFileName"); #or die "Couldn't open $cfgFileName for reading: $!\n";
$libNameH = <CfgFileHandle>;
$libSizeH = <CfgFileHandle>;
$isNetListFile='0';
while (<CfgFileHandle>) 
        {
                @aLine = split /[ \t]+/,$_;
                $desiredFileName = $aLine[0]; 
                if(!(-e $desiredFileName)) # make sure the desiredFile is a plain file
                {
                        print "\nFIOE:*$desiredFileName";
                        exit;
            }
            # below for-loop filters all the netlist files from @Files.
            # Only netlists coming from the 'Browse Netlists..' are removed.
            foreach $x (@FilesNotToBeModified) 
            {
                if ($x eq $desiredFileName)
                {
                   $isNetListFile='1';
                }
            }
            if($isNetListFile eq '0')
            {
                push(@Files,$desiredFileName);
            }
            $isNetListFile='0';
        }
$arraySize = @Files; #can be used to verify
close $CfgFileHandle;
##############

# Processing only for files having '.subckt' construct in it
# for each netlised file (can be HSpice file too) replace the sub-circuit name
# with the long form name (i.e. libname_cellname_viewname)

foreach $Files (@Files)
{
    open(OP_PRAV, ">$Files.temp");
    open(IN_PRAV, "<$Files");

    while(<IN_PRAV>)
    {
        $temp = $_;
        if ($temp =~ /\s*\.subckt\s+(\w+)\s*/)
        {
            $temp =~ s/$1/$Files/;
        }
        print OP_PRAV $temp;
     }

    close(IN_PRAV);
    close(OP_PRAV);

    file_copy("$Files".".temp", "$Files");
    unlink("$Files".".temp");
}


##First do the include in-line expansions
foreach $Files (@Files)
{
    open(OUTPUT, ">$Files.new");
    process($Files, 'fh00');

    sub process 
    {
        my $temp;
        local($filename, $input) = @_;
        $input++;
        if ( !(-e $filename) )   # check if the file with the complete path exists
        {
            $filename = "$projDir/$filename";
            # if the file path does not exist, append that with the path of the current project directory
        }
        unless(open $input, $filename) 
        {
            print  "\nFIOE:*$filename\n";
            exit;
        }
        $isMomCompDataStart = 0;
        while (<$input>) 
        {
            $temp = $_;
            
            @lcvArray;
            
            # code fix to remove the previous behaviour of deletion of leading 
            # spaces in netlisted lines of design to be encoded (EDA00194000)
            # fix to look for both ADS and HSPICE include statements (EDA00221180)
            # #include for ADS and .include for HSPICE
            if ($temp =~ /^\s*[.#]{1}include\s+['"](.*)['"]/)
            {
                process($1, $input);
                next;
            }
            # start
            # Below code will look for "em_data_name=<value>" parameter in em view block of netlist
            # and replaces the <value> in lib:cell:view format with the encoded_lib:cell:name.
            # Also it replaces the path befrore the lib name in "modelFile=" param
            # with just lib name.
            elsif($temp =~ /em_data_name="(\S+)"/ && $isMomCompDataStart eq 0)
            {
                $isMomCompDataStart = 1;    
                $libCellViewName = $1;  
                @lcvArray = split(':', $libCellViewName);   
                $newLibCellViewName = $libName . ":" . $lcvArray[1] . ":" . $lcvArray[2];                
                $temp =~ s/$libCellViewName/$newLibCellViewName/; #replace the design name   
            }
            elsif($temp =~ /MomCmpt:em_data/ && $isMomCompDataStart eq 1)
            {
                $isMomCompDataStart = 1;  
            }          
            # end
            # rest of the em view block manipulation code
			# moved the emView block out of the last elsif block (S-parms files not being copied to data directory)
            elsif($temp =~ m/modelFile="(\S+)"/ && $isMomCompDataStart eq 1)
            {
                $filePath = $1;
                $filePath =~ /(\S+)$lcvArray[0](\S+)/; # split the file path using the old lib name
                $modifiedPath = $libName . $2;
                $filePath =~ s/\\/\\\\/g;   # escape the windows '\' char
                
                $temp =~ s/$filePath/$modifiedPath/; # finally repalce the file path
                
                $isMomCompDataStart = 0; # reset this flag to start scanning a new momemtum sub design
            }
            elsif ($temp =~ m/File="((\S+ *)+)"/)
            {
                # In case we're on Windows, get rid of the "\" delimiter in file names
                $temp2 = $1;                #make a copy
                $temp3 = $1;                #make another copy
                $temp3 =~ s/\\/\//g;        #replace delim in matched file name
                $temp2 =~ s/\\/\\\\/g;      #escape the windows delim
                $temp =~ s/$temp2/$temp3/;  #replace windows delim file name with UNIX compatible file name
                # We use a non-greedy match to get the file name.
                $temp =~ m/(.*?)File="(.*?)"(.*?)/;
                $DataFile = basename($2); #code fix for IP_Encoder.205

                # Tie the data file name to the library name to
                # hopefully avoid duplicate names with other
                # libraries. So if we have "test.s2p" in multiple
                # libraries we can keep them unique by prefixing
                # the name with the library name.
                $DataFile = $libName . "_" . $DataFile;
                $temp =~ s/File="([^"]*)"/File=\"$DataFile\"/;

                @Flist =  $1;
                @Flist[0] = basename($1);

                if (-f  $1) #to handle the case where any file location is valid for data files
                {
                   # Copy the un-encoded data file to the new directory.
                   file_copy($1,"$dataDir/$DataFile"); 
                }
                # There's a chance that the file we are looking for 
                # doesn't have the full path - we look in the project
                # data directory for a file match. We use @Flist[0]
                # directly since it might contain only the name of the 
                # file. 
                elsif (-f "$projDir/data/@Flist[0]")
                { 
                   # Copy the un-encoded data file to the new directory.
                   file_copy("$projDir/data/@Flist[0]","$dataDir/$DataFile");
                }
               elsif (length($1) != 0)
               {
                      #additional error checking
                      $datafilePrav = $1;
                      $temP = $Files;
                      $temP =~ m/(.+)(_$libName)$/; # to extract design name from $Files
                      print "\nDFNF:*$datafilePrav*$1\n";
                      exit;
                }
            }
           print OUTPUT $temp;
        }
        print OUTPUT "\n";
        close $input;
    }
    
    close(OUTPUT);
    file_copy("$Files".".new", "$Files");
    unlink("$Files".".new");
}

##insert netlist version strings

foreach $Files (@Files)
{
    open(INPUT, "<$Files");

    @lines = ();
    @sorted = ();
    @SubCktNames = ();
    
    push(@lines, "% _ver = 1.0\n");
    while (<INPUT>)
    { 
        if (/^\s*end\s+. */)
        { 
        }
        push(@lines, $_);
        if (/^\s*define\s+. */)
        {
            @parsed = split(/define/,$_);
            @parsed = split(/\(/,$parsed[1]);
            $parsed[0] =~ s/\s+//g;
            push(@SubCktNames, $parsed[0]);
         }
        
    }
    push(@lines, "% _ver = !\n");
    close(INPUT);

    open(OUTPUT, ">$Files");
    print OUTPUT @lines;
    close(OUTPUT);
}

exit();
