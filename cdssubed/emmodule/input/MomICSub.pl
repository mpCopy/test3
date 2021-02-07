eval 'exec $HPEESOF_DIR/tools/bin/perl -S $0 ${1+"$@"}'
# Copyright Keysight Technologies 2011 - 2015  
if 0;

use warnings;
use strict;

use File::Basename;
use File::Path;
use File::Copy;

use Cwd;
my $dir = getcwd;

no warnings "uninitialized";	#this is to avoid warning messages regarding "uninitialized" variables etc.

#THIS PART OF CODE GENERATES my_procfile.txt & my_techfile.txt

my (@data11, $i11, $array11, @data12, $i12, $array12, @words11, @words12);
my (@data31, @data32, $array31, $array32, @words31, @words32, $i3, $j3, $p11, $p12, $p21, $p22, $count1, $count2, $exit_flag);

my ($GROUND_PLANE_FLAG,$MATERIAL_NAME,$RESISTIVITY,$PERMITTIVITY,$HEIGHT,$procFilePath,$p2lvsfilePath,$techFilePath,$smart_merge_flag,$ltdFile,$ltdFilePath) = @ARGV ;
#TO DO - From $ltdFile variable, seperate filename and path by using 'basename' & 'dirname'
my ($procFile,$p2lvsfile,$techFile);
my @data21;
my @data22;
my ($array21, @words21);
my ($array22, @words22);
my ($temp21, @temp21words);
my ($temp22, @temp22words);
my $i2=0;
my $j2=0;

my ($proceed,$mytechnologyFile);

# create temporary directory which is automatically cleaned up
use File::Temp qw(tempdir);
my $TempFolderPath = tempdir( CLEANUP => 1 );

#getting filenames
$procFile = basename($procFilePath);
$p2lvsfile = basename($p2lvsfilePath);
$techFile = basename($techFilePath);

my $old_Procfile_name = $procFile;		#Storing the original Procfile name, in case $procFile is set to the "new_procFile.txt" after Smart Layer Merge.

#copying files into Temp folder
copy ($procFilePath, $TempFolderPath."/".$procFile) or die $!;
copy ($p2lvsfilePath, $TempFolderPath."/".$p2lvsfile) or die $!;
copy ($techFilePath, $TempFolderPath."/".$techFile) or die $!;

#Gathering necessary information for the Automation of "controlfile.txt"
#print "\nPlease set the GROUND_PLANE_FLAG (Typically set to 1). Enter the value: ";
#chomp(my $GROUND_PLANE_FLAG = <STDIN>);
#print "Enter the name of the Substrate: ";
#chomp(my $MATERIAL_NAME = <STDIN>);
#print "Enter the Resistivity of the Substrate Material: ";
#chomp(my $RESISTIVITY = <STDIN>);
#print "Enter the Permittivity of the Substrate Material: ";
#chomp(my $PERMITTIVITY = <STDIN>);
#print "Enter the Height of the Substrate Material: ";
#chomp(my $HEIGHT = <STDIN>);

#Smart Layer Merge code
#my $smart_merge_flag = 0;
#print "\nDo you want 'Smart Layer Merge'? (Yes/No)\n";

#REDO1:chomp(my $flag = <STDIN>);
#if($flag eq "Y" || $flag eq "y" )
#{
#	$smart_merge_flag = 1;
#}
#elsif($flag eq "N" || $flag eq "n" )
#{
#	$smart_merge_flag = 0;
#}
#else
#{
#	print "\nWrong option. Please select again!\n";
#	goto REDO1;
#}

#print "\nEnter the filenames in the specified order(with file extensions): \n<proc filename> <p2lvs filename> <tech filename> <ltd filename>\n";
#my ($controlFile,$viaMappingFile,$procFile,$p2lvsfile,$techFile,$ltdFile) = @ARGV ;
#my @filename_list ;
#my $count = 0;
#while($count <= 3)
#{
#	chomp(my $temp_filename = <STDIN>);
#	$filename_list[$count] = $temp_filename;
#	$count+=1;
#}

my $controlFile = "controlfile.txt";
my $viaMappingFile = "viaMapping.txt";
#my $procFile = $filename_list[0];
#my $p2lvsfile = $filename_list[1];
#my $techFile = $filename_list[2];
#my $ltdFile = $filename_list[3];

open READ1, $TempFolderPath."/".$procFile or die $!;
open READ2, $TempFolderPath."/".$techFile or die $!;
open WRITE1, ">>".$TempFolderPath."/my_procfile.txt" or die $!;
open WRITE2, ">>".$TempFolderPath."/my_techfile.txt" or die $!;
@data11 = <READ1>;
@data12 = <READ2>;
$i11 = -1;
$i12 = -1;

#This part of code generates the temporary files
OUTER1:while(1)
{

  INNER11:while(1)
  {
    $array11 = $data11[$i11+1];
    if( $array11 =~ m/deposition/ )
    {
      $i11 = $i11+1;
      last INNER11;
    }
    else
    {
      $i11 = $i11+1;
    }

    #NEW_01062011
    if(!(defined($data11[$i11+1])))
    {
      print "\"deposition\" not found. Inappropriate File Structure!\nTerminating abruptly.";
      deleteFiles();
      exit;
    }
  }

  #$i11 = $i11+2;	#Incrementing by '2' since there is an unwanted line in between

  INNER1p5:while(1)
  {
    $array11 = $data11[$i11+1];
    if($array11 =~ m/^\*/)
    {
      $i11 = $i11+1;
    }
    else
    {
      $i11 = $i11+1;
      last INNER1p5;
    }
  }

  INNER12:while(1)
  {
    $array11 = $data11[$i11];

    if($array11 =~ m/^\*/)
    {
      $i11 = $i11+1;
      next;
    }

    if( $array11 =~ m/enddeposition/ )
    {
      print WRITE1 $array11;
      last INNER12;
    }
    else
    {
      @words11 = split(' ', $array11);
      if ($words11[0] eq "step")
      {
        print WRITE1 $array11;
      }
    }

    $i11 = $i11+1;

    #NEW_01062011
    if(!(defined($data11[$i11])))
    {
      print "\"enddeposition\" not found. Inappropriate File Structure!\nTerminating abruptly.";
      deleteFiles();
      exit;
    }
  }

  INNER125:while(1)
  {
    $array12 = $data12[$i12+1];
    # print $array12;
    if( $array12 =~ m/layerRules/ &&  $array12 !~ m/^;/)
    {
      # $i12 = $i12+1;
      # print "layerRules";
      last INNER125;
    }
    else
    {
      $i12 = $i12+1;
    }

    #NEW_01062011
    if(!(defined($data12[$i12+1])))
    {
      print "\"layerRules\" not found. Inappropriate File Structure!\nTerminating abruptly.";
      deleteFiles();
      exit;
    }
  }

  # $i12 = $i12+3;

  INNER13:while(1)
  {
    $array12 = $data12[$i12+1];
    if( ($array12 =~ m/layerFunctions/ || $array12 =~ m/functions/) &&  $array12 !~ m/^;/)
    {
      $i12 = $i12+1;
      last INNER13;
    }
    else
    {
      $i12 = $i12+1;
    }

    #NEW_01062011
    if(!(defined($data12[$i12+1])))
    {
      print "\"layerFunctions\" and/or \"functions\" not found. Inappropriate File Structure!\nTerminating abruptly.";
      deleteFiles();
      exit;
    }
  }

  $i12 = $i12+3;

  INNER14:while(1)
  {

    $array12 = $data12[$i12];
    if( $array12 =~ m/layerFunctions/ || $array12 =~ m/functions/)
    {
      # last OUTER1;
      # print "End layerFunctions";
      last INNER14;
    }
    else
    {
      @words12 = split(' ', $array12);
      if ($words12[0] ne ";*")
      {
        print WRITE2 $array12;
      }
    }

    $i12 = $i12+1;

    #NEW_01062011
    if(!(defined($data12[$i12])))
    {
      print "\"layerFunctions\" and/or \"functions\" not found. Inappropriate File Structure!\nTerminating abruptly.";
      deleteFiles();
      exit;
    }
  }

  INNER15:while(1)
  {

    $array12 = $data12[$i12+1];
    if( $array12 =~ m/layerRules/ )
    {
      last OUTER1;
      # last INNER14;
    }
    # else
    # {
      # @words12 = split(' ', $array12);
      # if ($words12[0] ne ";*")
      # {
        # print WRITE2 $array12;
      # }
    # }

    $i12 = $i12+1;

    #NEW_01062011
    if(!(defined($data12[$i12+1])))
    {
      print "\"layerRules\" not found. Inappropriate File Structure!\nTerminating abruptly.";
      deleteFiles();
      exit;
    }
  }

}
print WRITE2 "END";

close READ1;
close READ2;
close WRITE1;
close WRITE2;


if($smart_merge_flag eq "Yes" or $smart_merge_flag eq "yes" )	#if TRUE, perform Smart Layer Merge
{
  #print "\nMerging Layers...\n";
  my ($array11, $array12);

  my $my_procFile = "my_procfile.txt";
  my $diel_pointer = 0;
  my $i11=0;

  open READ1, $TempFolderPath."/".$my_procFile or die $!;
  @data11 = <READ1>;

  open WRITE1, ">>".$TempFolderPath."/merged_layers.txt" or die $!;

  my $unduplication_Number = 1;
  OUTER:while(1)
  {
  INNER1:while(1)	# to indicate the end of file
  {
    $array11 = $data11[$i11];

    #test code; mayn't work correctly!!!
    my $check_Layer = (split(' ', $array11))[2];

    if( $array11 =~ m/enddeposition/ )
    {
      last OUTER;	# has to exit the outer loop!!!
    }
    #ASKK_new if( $array11 =~ m/metal/ )	# to find the 1st metal
    if($check_Layer =~ m/metal/)	# to find the 1st metal
    {
      print WRITE1 "$array11";
      $i11 = $i11+1;
      last INNER1;
    }
    else
    {
      print WRITE1 "$array11";
      $i11 = $i11+1;
    }
  }

  $diel_pointer = $i11;	# currently this points to the first dielectric after metal, i.e, the "lateral" one. Pointer would be incremented later to skip this dielectric layer!!!
  my $array = $data11[$i11];
  print WRITE1 "$array";

  INNER2:while(1)
  {
    $array12 = $data11[$i11];

    #test code; mayn't work correctly!!!
    my $check_Layer = (split(' ', $array12))[2];

    if( $array12 =~ m/enddeposition/ )
    {
      last OUTER;	# has to exit the outer loop!!!
    }
    #ASKK_new if( $array12 =~ m/metal/ )	# to find the 2nd metal
    if( $check_Layer =~ m/metal/ )	# to find the 2nd metal
    {
      last INNER2;
    }
    else
    {
      $i11 = $i11+1;
    }
  }

  my $diel_count = $i11 - $diel_pointer;	#this count gives the total number of dielectrics between the 2 metals

  $diel_count = $diel_count - 1; 	#count is reduced by 1, as the "lateral" layer is not considered for merging.
  $diel_pointer = $diel_pointer + 1;	#pointer now pointing to the 1st vertical dielectric layer(immediately after the "lateral" layer)

  #print $diel_count." "; #-1 -1 1 1 3 -1 -1 4 -1 -1 4 -1 -1 4 -1 -1 3 4
  if ($diel_count >= 2)	#if TRUE, Smart Layer Merge has to be performed
  {
    my $num = 0;
    my $den = 0;
    my (@x, @y);

    my $temp_line = $data11[$diel_pointer];
    my @temp_words = split(' ', $temp_line);

    for (my $count=0; $count < $diel_count; $count++)
    {
      my $line = $data11[$diel_pointer];
      my @words = split(' ', $line);

      $x[$count] = $words[6];
      $y[$count] = $words[5];

      $num += $x[$count]*$y[$count];
      $den += $y[$count];

      $diel_pointer++;
    }

    my $single_dielec = $num/$den;	#this gives the equivalent dielectric

    my @mod_dielec;
    $mod_dielec[0] = int(($single_dielec*100)/100);
    $mod_dielec[1] = ($single_dielec*100)%100;

    my $dielec_name = $temp_words[4];
    my @dielec_name = split(undef, $dielec_name);
    print WRITE1 "$temp_words[0] $temp_words[1] $temp_words[2] $temp_words[3]\t$dielec_name[0]$dielec_name[1]$dielec_name[2]_$mod_dielec[0]_$mod_dielec[1]_$unduplication_Number\t$den\t$single_dielec\n";

    $unduplication_Number = $unduplication_Number + 1;
  }
  if ($diel_count == 1)
  {
    my $temp_line = $data11[$i11-1];
    print WRITE1 "$temp_line\n";
  }
    #print WRITE1 "\n";
  }


  my $n = 1;
  $array12 = $data11[$diel_pointer + $n]; #the first "vertical" layer after the last metal.
  while( !($array12 =~ m/enddeposition/))
  {
    print WRITE1 $array12;
    $n+= 1;
    $array12 = $data11[$diel_pointer + $n];
  }
  print WRITE1 "enddeposition";

  close READ1;
  close WRITE1;

  open READ1, $TempFolderPath."/merged_layers.txt";
  open WRITE1, ">>".$TempFolderPath."/new_merged_layers.txt";
  #rewriting step numbers
  #@data11 = <READ1>;

  #$i11 = 0;

  #while($data11[$i11] !~ m/metal/)
  #{
  #	print WRITE1 $data11[$i11];
  #	$i11 += 1;
  #}

  #my $temp_line = $data11[$i11];
  #my @temp_words = split(' ', $temp_line);
  #my $step_no = $temp_words[1];

  #while($data11[$i11] !~ m/enddeposition/)
  #{
  #	my $temp1_line = $data11[$i11];
  #	my @temp1_words = split(' ', $temp1_line);

  #	if($temp1_line =~ m/dielectric/)
  #	{
  #		print WRITE1 "$temp1_words[0] $step_no\t$temp1_words[2] $temp1_words[3]\t$temp1_words[4]\t$temp1_words[5]\t$temp1_words[6]\n";
  #		$step_no += 1;
  #	}
  #	if($temp1_line =~ m/metal/)
  #	{
  #		print WRITE1 "$temp1_words[0] $step_no\t$temp1_words[2]\t\t\t$temp1_words[3]\t$temp1_words[4]\n";
  #		$step_no += 1;
  #	}
  #	if($temp1_line =~ m/substrate/)
  #	{
  #		print WRITE1 "$temp1_words[0] $step_no\t$temp1_words[2]\t\t$temp1_words[3]\t$temp1_words[4]\t$temp1_words[5]\n";
  #		$step_no += 1;
  #	}

  #	#print WRITE1 "\n";
  #	$i11 += 1;
  #	#$step_no += 1;
  #}
  #print WRITE1 "enddeposition";

  my @temp_array = undef;
  my $line = undef;
  my $step_no = 1;
  my $step_flag = 0;
   while(<READ1>)
   {
     next if /^\s*$/;

     $line = $_;
     @temp_array = split(' ', $line);
     if($temp_array[2] eq "metal")
    {
      $step_flag = 1;
    }

    if($step_flag == 1)
    {
      $step_no++;
    }

     $temp_array[1] = $step_no;
     #a "join" statement could be used here.
     $line = join('  ', @temp_array);
     print WRITE1 "$line\n";

   }

  close READ1;
  close WRITE1;

  open READ1, $TempFolderPath."/".$procFile;
  open READ2, $TempFolderPath."/new_merged_layers.txt";
  open WRITE1, ">>".$TempFolderPath."/new_procfile.txt";

  my @data1 = <READ1>;
  my @data2 = <READ2>;

  my $i1 = 0;
  my $i2 = 0;

  while($data1[$i1] !~ m/endprocess/)
  {
    my $temp_line = $data1[$i1];
    if($temp_line =~ m/deposition/)
    {
      print WRITE1 "deposition\n";
      print WRITE1 "*step #	material p/n	name	Z	diel_constant\n";
      while($data2[$i2] !~ m/enddeposition/)
      {
        print WRITE1 $data2[$i2];
        $i2 += 1;
      }
      print WRITE1 "enddeposition\n";

      while($data1[$i1] !~ m/enddeposition/)
      {
        $i1 += 1;
      }
      $i1 += 1;
      $temp_line = $data1[$i1];
    }

    print WRITE1 $temp_line;
    $i1 += 1;
  }
  print WRITE1 "endprocess";

  close READ1;
  close READ2;
  close WRITE1;

  #print "The Smart Layer Merge has been performed.\nProceeding with the creation of $ltdFile file\n";
  $procFile = "new_procfile.txt";
}

#THIS PART OF THE CODE WRITES THE MAPPING INFORMATION INTO THE controlfile.txt

open FILEONEH, $TempFolderPath."/my_procfile.txt" or die $!;
open FILETWOH, $TempFolderPath."/my_techfile.txt" or die $!;

@data21 = <FILEONEH>;
@data22 = <FILETWOH>;

$i2 = 0;
$j2 = 0;
#print "i2 = $i2"."\n"."j2 = $j2"."\n";
$array21 = ($data21[$i2]);
$array22 = ($data22[$j2]);

@words21 = split(' ', $array21);
@words22 = split(' ', $array22);

#print $words1[2], "\t", $words2[1];

#Beginning creating and writing into the control file.txt
open FILETHREEH, ">>".$TempFolderPath."/".$controlFile or die $!;

print FILETHREEH "* Control file for cds2ltd script\n* Required settings\n* Define paths to input files\n* Define Substrate\n";
print FILETHREEH "* GROUNDPLANE below Substrate layer: “1” if GROUNDPLANE, no GROUNDPLANE elsewhere\n* Mapping of  poly/metal layer names in “layerFunctions” and “procfile”\n\n";
print FILETHREEH "GROUNDPLANEFLAG=$GROUND_PLANE_FLAG\n\n";
print FILETHREEH "MATERIAL $MATERIAL_NAME RESISTIVITY=$RESISTIVITY PERMITTIVITY=$PERMITTIVITY\n";
print FILETHREEH "LAYER Name=$MATERIAL_NAME HEIGHT=$HEIGHT MATERIAL=$MATERIAL_NAME\n";
print FILETHREEH "\n", "BEGIN_MAPPING", "\n", "*procfile_name", "\t", "DFII_layer_name", "\n" ;

# print "Working Fine!\n";
my $matchVariable ;
my $new_temp_array1 ;
my @new_temp_words1 ;
my $mismatchFlag=0;
my $skip_diff_flag = 0;	#NEW_25062011
my $MIM_delete_ltdFile = 0;	#NEW_27062011
OUTER2:while(1)
{
  # print "Working Fine!\n";

  $array21 = ($data21[$i2]);
  $array22 = ($data22[$j2]);

  @words21 = split(' ', $array21);
  @words22 = split(' ', $array22);

  if (($words21[2] eq "dielectric") || ($words21[2] eq "substrate"))
  {
    INNER21:while(1)
    {
      $temp21 = $data21[$i2+1];
      @temp21words = split(' ', $temp21);

      if($temp21words[0] eq "enddeposition")
      {
        last OUTER2;
      }
      if($temp21words[2] eq "metal")
      {
        $i2=$i2+1;

        $new_temp_array1 = ($data21[$i2]);
        @new_temp_words1 = split(' ', $new_temp_array1);
        $matchVariable = $new_temp_words1[3];

        #NEW_27062011
        if($new_temp_words1[3] =~ m/mim/i || $new_temp_words1[3] =~ m/cmm/i || $new_temp_words1[3] =~ m/ctm/i || $new_temp_words1[3] =~ m/cbm/i)
        {
          print "MIM layers is currently not supported. Please generate *.ltd file without MIM layers; modify the resulting *.ltd file to include MIM layers.\n";
          $MIM_delete_ltdFile = 1;	#delete generated ltd file
          deleteFiles();
          exit;
        }

        last INNER21;
      }
      # else
      # {
      # $i2=$i2+1;
      # }
      $i2=$i2+1;

      #NEW_01062011
      if(!(defined($data21[$i2+1])))
      {
        print "Inappropriate File Structure!\nTerminating abruptly.";
        deleteFiles();
        exit;
      }
    }
  }
  #print "\n"."BINGO!"."\n";
  #print "$words22[2]";
  #($words22[2] eq "\"cut\"") || ($words22[2] eq "\"ndiff\"") || ($words22[2] eq "\"nwell\"") || ($words22[2] eq "\"pwell\"") || ($words22[2] eq "\"nplus\"") || ($words22[2] eq "\"ap\"")
  if($words22[2] ne "\"metal\"" && $words22[2] ne "\"poly\"" && $words22[2] ne "\"diff\"")
  {
    # print "starting loop INNER22\n";
    INNER22:while(1)
    {
      #print "inside loop INNER22\n";
      $temp22 = $data22[$j2+1];
      if($temp22 =~ m/^END/)
      {
        # print "\nExecution stopped due to unexpected input file structure.\n";
		# removing the below statement as END statement was put intentionally in the my_techfile.txt temporary file
        # print "\nInformation inside the generated \"\*.ltd\" file may not be correct due to inapproriate input files structure.\n";
        $mismatchFlag=1; 
        last OUTER2;
        # exit;
      }
		
		$temp22 =~ s/[\(]//;
		$temp22 =~ s/[\)]//;
		$temp22 =~ s/^\s*//;
		$temp22 =~ s/\s*$//;
      # @temp22words = split(' ', $temp22);
      @temp22words = split(' ', $temp22);

      #if($temp22 !~ m/A/)
      #{
        #print "$temp22words[2]  INNER22 \n";
        if(($temp22words[1] eq "\"metal\"") || ($temp22words[1] eq "\"poly\"") || ($temp22words[1] eq "\"diff\""))
        {
          $j2=$j2+1;

          #NEW_25062011
          if(($skip_diff_flag == 0) && ($temp22words[2] eq "\"diff\""))
          {
            #$j2=$j2+1;
            $skip_diff_flag = 1;
            next;
          }
          $skip_diff_flag = 1;
          last INNER22;
        }
        #elsif($temp22words[2] eq "")
        #{
        #	print "Please check for mismatch\n";
        #	last INNER22;
        #}

        else
        {
        $j2=$j2+1;
        }
      #}
      #else
      #{
      #	$j2=$j2+1;
      #}

      #NEW_01062011
      if(!defined($data22[$j2+1]) && !$mismatchFlag)
      {
        print "Inappropriate File Structure!\nTerminating abruptly.";
        deleteFiles();
        exit;
      }
    }
  }
  #print "\n"."BINGO!"."\n";

  my $new_temp_array2 ;
  my @new_temp_words2 ;


  if($words22[2] eq "\"diff\"" && $words22[1] eq "DIFF" && $j2 == 0)
  {
    INNER23:while(1)
    {
      $j2 = $j2+1;
      $new_temp_array2 = ($data22[$j2]);
      @new_temp_words2 = split(' ', $new_temp_array2);
      #print "$new_temp_words2[1] - $matchVariable\n";

      if($new_temp_words2[1] =~ m/$matchVariable/i)
      {
        last INNER23;
      }

      #NEW_01062011
      if(!(defined($data22[$j2+1])))
      {
        print "Inappropriate File Structure!\nTerminating abruptly.";
        deleteFiles();
        exit;
      }
    }
  }



	$array21 = $data21[$i2];
	$array22 = $data22[$j2];
	$array22 =~ s/[\(]//;
	$array22 =~ s/[\)]//;
	$array22 =~ s/^\s*//;
	$array22 =~ s/\s*$//;
  @words21 = split(' ', $array21);
  @words22 = split(' ', $array22);
  print FILETHREEH " ", $words21[3], "\t\t", $words22[0], "\n";

  $i2=$i2+1;
  $j2=$j2+1;

}
#print "END_MAPPING";
print FILETHREEH "END_MAPPING";
close FILEONEH;
close FILETWOH;
close FILETHREEH;


#THIS PART OF THE CODE CREATES THE viaMapping.txt FILE

#ASKK_NEW_18082011
my %material_via;
my @viaList = undef;
my %via_thickness;
my $k = 0;

my $appropriate_File;
if($smart_merge_flag eq "Yes" or $smart_merge_flag eq "yes" )
{
  $appropriate_File = "new_merged_layers.txt";
}
else
{
  $appropriate_File = "my_procfile.txt";
}

open FH1, $TempFolderPath."/".$appropriate_File or die $!;
open FH2, $TempFolderPath."/my_techfile.txt" or die $!;
open FH3, ">".$TempFolderPath."/".$viaMappingFile or die $!;

@data31 = <FH1>;
@data32 = <FH2>;
$i3 = 0;
$j3 = 0;
$count1 = 0;
$count2 = 0;
$exit_flag = 0;

OUTER3:while(1)
{
  $array31 = ($data31[$i3]);
  @words31 = split(' ', $array31);
  if($words31[2] eq "metal")
  {
    $p11 = $i3;
    last OUTER3;
  }
  else
  {
    $i3 = $i3+1;
  }

  #NEW_01062011
  if(!(defined($data31[$i3])))
  {
    print "Inappropriate File Structure!\nTerminating abruptly.";
    deleteFiles();
    exit;
  }
}

#print "\nexiting outer3 loop\n";

OUTER4:while(1)	#ASKK_NEW_17082011: To get to the 1st poly/metal, matchVariable technique could be tried!!!
{
  $array32 = ($data32[$j3]);
  $array32 =~ s/[\(]//;
  $array32 =~ s/[\)]//;
  $array32 =~ s/^\s*//;
  $array32 =~ s/\s*$//;
  # $array32 =~ /^\((.+)$\)/; /^\s*\) ;constraintGroups/
  @words32 = split(' ', $array32);
  if(($words32[1] eq "\"metal\"") || ($words32[1] eq "\"poly\""))
  {
    $p21 = $j3;
    last OUTER4;
  }
  else
  {
    $j3 = $j3+1;
  }

  #NEW_01062011
  if(!(defined($data32[$j3])))
  {
    print "Inappropriate File Structure!\nTerminating abruptly.";
    deleteFiles();
    exit;
  }
}

$p11 = $i3;
$p21 = $j3;
$j3=$j3-2;
# $i3=$i3-2;
OUTER5:while(1)
{
  # print "$mismatchFlag   mismatchFlag\n";
  if($mismatchFlag==1)
  {
    # print "OUTER5";
    last OUTER5;
  }

  INNER31:while(1) # my_procfile
  {
    $array31 = ($data31[$i3+1]);
    @words31 = split(' ', $array31);
    if($words31[0] eq "enddeposition")
    {
      last OUTER5;
    }
    # print "$words31[1]\t$words31[2]\n";
    if($words31[2] eq "metal")
    {
      $i3 = $i3+1;
      $p12 = $i3;
      last INNER31;
    }
    else
    {
      $i3 = $i3+1;
      $count1 = $count1+1;
    }
    # print " $count1            Count1\n";

    #NEW_01062011
    if(!(defined($data31[$i3+1])))
    {
      print "Inappropriate File Structure!\nTerminating abruptly.";
      deleteFiles();
      exit;
    }
  }

  INNER32:while(1) # my_techfile
  {
    $array32 = ($data32[$j3+1]);
	$array32 =~ s/[\(]//;
	$array32 =~ s/[\)]//;
	$array32 =~ s/^\s*//;
	$array32 =~ s/\s*$//;
    @words32 = split(' ', $array32);
	
    if($words32[0] eq "END")
    {
      last OUTER5;
    }
    my @temp_words32=@words32;
    chop($temp_words32[0]);
    # print "$words32[1]     words31 \n";
    # if((($words32[1] =~ /POLY/ || $temp_words32[1] =~ "POLY" || $words32[1] =~ "METAL" || $temp_words32[1] =~ "METAL")) && (($words32[2] =~ "\"metal\"") || ($words32[2] =~ "\"poly\"" || $words32[2] =~ "\"METAL\"") || ($words32[2] =~ "\"POLY\"" )))
    #if(((uc($words32[1]) =~ /POLY/ || uc($temp_words32[1]) =~ "POLY" || uc($words32[1]) =~ "METAL" || uc($temp_words32[1]) =~ "METAL")) && (($words32[2] =~ "\"metal\"") || ($words32[2] =~ "\"poly\"" || $words32[2] =~ "\"METAL\"") || ($words32[2] =~ "\"POLY\"" )))
   
   # if(((uc($words32[1]) =~ /PO/ || uc($temp_words32[1]) =~ "POLY" || uc($words32[1]) =~ /^M/ || uc($temp_words32[1]) =~ /^M/)) && (($words32[2] =~ "\"metal\"") || ($words32[2] =~ "\"poly\"" || $words32[2] =~ "\"METAL\"") || ($words32[2] =~ "\"POLY\"" )))
    if(((uc($words32[0]) =~ /PO/ || uc($temp_words32[0]) =~ "POLY" || uc($words32[0]) =~ /^M/ || uc($temp_words32[0]) =~ /^M/)) && (($words32[1] =~ "\"metal\"") || ($words32[1] =~ "\"poly\"" || $words32[1] =~ "\"METAL\"") || ($words32[1] =~ "\"POLY\"" )))
    {
      INNER325:while(1)
      {
        $j3 = $j3+1;
        $array32 = ($data32[$j3+1]);
		$array32 =~ s/[\(]//;
		$array32 =~ s/[\)]//;
		$array32 =~ s/^\s*//;
		$array32 =~ s/\s*$//;
        @words32 = split(' ', $array32);  # || ($words32[2] eq "\"poly\""   || ($words32[2] eq "\"POLY\"")

        #ASKK_NEW_17082011
        if($array32 =~ /^END/)	#Forceful exit because of improperness in TECH file
        {
          # print "\nProblem in mapping via layers. The generated \"*.ltd\" file may not be correct.\n";
          last OUTER5;
        }

        # if(($words32[2] eq "\"poly\"" )  || ($words32[2] eq "\"POLY\""))	#ASKK_NEW_17082011: takes care of consecutive metal-poly or poly-poly cases.
        if(($words32[1] eq "\"poly\"" )  || ($words32[1] eq "\"POLY\""))	#ASKK_NEW_17082011: takes care of consecutive metal-poly or poly-poly cases.
        {
          # print "$words32[2]\t		worrds32  for poly";
          $j3=$j3-1;
          last INNER325;
        }
        # elsif(($words32[2] eq "\"cut\"")  || ($words32[2] eq "\"CUT\"") )   #column check
        elsif(($words32[1] eq "\"cut\"")  || ($words32[1] eq "\"CUT\"") )   #column check
        {
          # print "$words32[2]\t		worrds32  for cut";
          $p22 = $j3+1;
          $j3=$j3+1;
          last INNER32;
        }
      }
    }
      $j3=$j3+1;

    #NEW_01062011
    if(!(defined($data32[$j3+1])))
    {
      print "Inappropriate File Structure!\nTerminating abruptly.";
      deleteFiles();
      exit;
    }
  }
  INNER33:while($count1!=0) # need to look for the cut layer  14 times
  {
    $array31 = $data31[$p12-$count1];
    $array32 = $data32[$p22];
	$array32 =~ s/[\(]//;
	$array32 =~ s/[\)]//;
	$array32 =~ s/^\s*//;
	$array32 =~ s/\s*$//;
    @words31 = split(' ', $array31);
    @words32 = split(' ', $array32);

    print FH3 $words31[4], "\t", $words32[0], "\n";
    $count1 = $count1-1;

    #ASKK_NEW_22082011
    $via_thickness{$words32[1]} += $words31[5];

    if($count2>1)
    {
      $count2 = $count2-1;
    }

  }
  $count2 = 0; 	#Reset before next loop, as it is not allowed to goto zero unlike "$count1".

  #ASKK_NEW_18082011
  # my $viaName = $words32[1];
  my $viaName = $words32[0];
  # my $viaMaterial = "Cond_".$words32[1];
  my $viaMaterial = "Cond_".$words32[0];
  $material_via{$viaName} = $viaMaterial;
  $viaList[$k] = $viaName;
  $k = $k+1;
}
$k = 0;

# print "\nOUTER5 after\n";
close FH1;
close FH2;
close FH3;

#ASKK_NEW_23082011 - Gathering rsh and area values for VIAs
my (%rsh_via, %unitArea_via);
open read_file, $TempFolderPath."/".$p2lvsfile or die $!;
while(<read_file>)
{
  if($_ =~ /^ext_cont=(\S+)\s+res=(\S+)\s+unit_area=(\S+)/)
  {
    $rsh_via{$1} = $2;
    $unitArea_via{$1} = $3;
    $unitArea_via{$1} =~ s/;$//;
  }
}
close read_file;

#ASKK_NEW_23082011 - calculating conductivity for VIAs
my %via_conductivity;
foreach my $temp_viaName(@viaList)
{
  my $temp_via_thickness = $via_thickness{$temp_viaName};
  my $temp_via_rsh = $rsh_via{$temp_viaName};
  my $temp_via_area = $unitArea_via{$temp_viaName};

  if($temp_via_thickness ne "" && $temp_via_rsh ne "" && $temp_via_area ne "")
  {
    my $conductivity = $temp_via_thickness/($temp_via_rsh * $temp_via_area) * 1000000;
    $via_conductivity{$temp_viaName} = $conductivity;
  }
  else
  {
    $via_conductivity{$temp_viaName} = "NULL";
  }
}




#THIS PART OF THE CODE CREATES THE .ltd FILE

# my ($controlFile,$viaMappingFile,$procFile,$p2lvsfile,$techFile) = @ARGV ;
open WRITE, ">>".$TempFolderPath."/".$ltdFile or die $!;

my $inDeposition = undef ;
my ($procName,$Z,$diel_constant) ;
my @steps = () ;

open(my $fromProcFile,$TempFolderPath."/".$procFile) ||
  die "cannot open $procFile: $!" ;

while(<$fromProcFile>) {
  chomp ;
  # remove leading whitespaces
  s/^\s+// ;
  # remove trailing a potential backslash
  s/\\$// ;
  /^deposition/ &&
    ($inDeposition = 1) ;
  $inDeposition ||
    next ;
  /^enddeposition/ &&
    last ;
  my @flds = 0 ;
  #my $fld = 0;
  if(@flds=(/^step\s+(\d+)\s+(substrate|metal|dielectric\s+[pn])\s+(\S+)\s+(\S+)(\s+(\S+))?/)) {

    foreach  my $fld  (@flds) { $fld =~ s/^\s+// ; $fld =~ s/\s+$// } ;
    #foreach  (@flds) {$_ =~ s/^\s+// ; $_ =~ s/\s+$//; }
     push(@steps,\@flds) ;
# 		 print ">$flds[0]<     >$flds[1]<     >$flds[2]<    >$flds[3]<     >$flds[4]<\n" ;
  }
}
# exit ;

my %sheetResistance = getSheetResistance($p2lvsfile) ;
my ($groundPlaneFlag,$siMaterialLine,$siLayerLine,%dfIInames) = getControlFileInfo($controlFile) ;
my @techFileLines = readTechFile($techFile) ;
# my %vias = getViasFromTechFile(\@techFileLines,\%dfIInames) ;
my %vias = getViasFromMappingFile($viaMappingFile) ;
my %layerNums = getLayerNumsFromTechFile(\@techFileLines) ;

print WRITE "TECHFORMAT=V2\n" ;
print WRITE "UNITS\n" ;
print WRITE "DISTANCE=UM\n" ;
print WRITE "CONDUCTIVITY=SIEMENS/M\n" ;
print WRITE "RESISTIVITY=OHM.CM\n" ;
print WRITE "RESISTANCE=OHM/SQ\n" ;
print WRITE "PERMITTIVITY=RELATIVETOVACUUM\n" ;
print WRITE "PERMEABILITY=RELATIVETOVACUUM\n" ;
print WRITE "END_UNITS\n" ;

print WRITE "BEGIN_MATERIAL\n" ;
print WRITE "$siMaterialLine\n" ;
# material substrate layers
foreach my $step (@steps) {
  if($step->[1] =~ /substrate|dielectric/) {
    $procName = $step->[2] ;
    $Z = $step->[3] ;
    $diel_constant = $step->[4] ;
    print WRITE "MATERIAL $procName PERMITTIVITY=$diel_constant\n" ;
  }
}
# material metal layers
my $conductivity ;
foreach my $step (@steps) {
  if($step->[1] =~ /metal/) {
    $procName = $step->[2] ;
    $Z = $step->[3] ;
    $diel_constant = $step->[4] ;
    if($sheetResistance{$procName}[0] =~ /sheet_res/) {
      $conductivity = 1 / ( $sheetResistance{$procName}[1] * ($Z / 1000000)) ;
    } else {
      #print "\n".$sheetResistance{$procName}[1]."\n";
      $conductivity = 1/$sheetResistance{$procName}[1] ;
    }
    printf WRITE ("MATERIAL %s CONDUCTIVITY=%-8d\n",$dfIInames{$procName},$conductivity) ;
  }
}

#ASKK_NEW_18082011
foreach my $viaName (@viaList)
{
  if($via_conductivity{$viaName} ne "NULL")
  {
    printf WRITE ("MATERIAL %s CONDUCTIVITY=%s IMAG_CONDUCTIVITY=0\n", $material_via{$viaName}, $via_conductivity{$viaName});
  }
}

print WRITE "END_MATERIAL\n" ;

print WRITE "BEGIN_OPERATION\n" ;
print WRITE "OPERATION Wall WALL\n" ;
print WRITE "OPERATION Via DRILL\n" ;
print WRITE "OPERATION Sheet SHEET\n" ;
foreach my $step (@steps) {
  if($step->[1] =~ /metal/) {
    $procName = $step->[2] ;
    $Z = $step->[3] ;
    $diel_constant = $step->[4] ;
    printf WRITE ("OPERATION Thick_Up_%s EXPAND=%s UP\n",$dfIInames{$procName},$step->[3] ) ;
  }
}
print WRITE "END_OPERATION\n" ;

print WRITE "BEGIN_MASK\n" ;
  $groundPlaneFlag &&
    print WRITE "MASK -1 NAME=eesof_subed_perfectBounPlane NEGATIVE MATERIAL=PERFECT_CONDUCTOR\n" ;
my @toBeSorted = () ;
foreach my $step (@steps) {
  if($step->[1] =~ /metal/) {
    $procName = $step->[2] ;
    # print "$procName\n";
    push(@toBeSorted,sprintf ("MASK %s NAME=%s MATERIAL=%s OPERATION=Thick_Up_%s\n",
      $layerNums{$dfIInames{$procName}},$dfIInames{$procName},$dfIInames{$procName},$dfIInames{$procName})) ;
  }
}
my %xx = reverse %vias ;
foreach my $via (keys %xx) {		#ASKK_NEW_18082011
    if($via_conductivity{$via} ne "NULL")
    {
      push(@toBeSorted,sprintf ("MASK %s NAME=%s MATERIAL=%s OPERATION=Via\n",
      $layerNums{$via},$via,$material_via{$via})) ;
    }
    else
    {
      push(@toBeSorted,sprintf ("MASK %s NAME=%s MATERIAL=PERFECT_CONDUCTOR OPERATION=Via\n",
      $layerNums{$via},$via)) ;
    }
}
foreach my $line (sort {
                  (split(/\s+/,$a))[1] <=> (split(/\s+/,$b))[1]
                } @toBeSorted ) {
  print WRITE "$line" ;
}

print WRITE "END_MASK\n" ;

print WRITE "BEGIN_STACK\n" ;
  print WRITE "TOP OPEN MATERIAL=AIR\n" ;
foreach my $step (reverse(@steps)) {
    $procName = $step->[2] ;
    $Z = $step->[3] ;
    if($step->[1] =~ /substrate|dielectric/) {
      if(exists( $vias{$procName})) {
        printf WRITE ("LAYER Name=%s MASK= { %s } HEIGHT=%s MATERIAL=%s\n",$procName,$layerNums{$vias{$procName}},$Z,$procName) ;
      } else {
        printf WRITE ("LAYER Name=%s HEIGHT=%s MATERIAL=%s\n",$procName,$Z,$procName) ;
      }
    } else {
      printf WRITE ("INTERFACE Name=%s MASK = { %s }\n",$dfIInames{$procName},$layerNums{$dfIInames{$procName}}) ;
    }
}
print WRITE "$siLayerLine\n" ;
$groundPlaneFlag &&
  print WRITE "INTERFACE Name=$MATERIAL_NAME"."_AIR MASK = { -1 }\n" ;
print WRITE "BOTTOM OPEN MATERIAL=AIR\n" ;
print WRITE "END_STACK\n" ;





sub getControlFileInfo {
  my $controlFile = shift ;
  my $inMapping = 0 ;
  my $line = "" ;
  my %dfIInames = () ;
  my ($groundPlaneFlag,$siMaterialLine ,$siLayerLine  ) = 0;
  open(my $fromControlFile,$TempFolderPath."/".$controlFile) ||
     die "cannot open $controlFile $!" ;
  while(<$fromControlFile>) {
    /^\*/ && next ;
    /^\s*$/ && next ;
    /^BEGIN_MAPPING/ && ($inMapping = 1 ) ;
    chomp ;
    $line = $_ ;
    unless($inMapping) {
      /^MATERIAL/ &&
        ($siMaterialLine = $_) ;
      /^LAYER Name=/ &&
        ($siLayerLine = $_) ;
      if(/^GROUNDPLANEFLAG=(.+)/) {
        $groundPlaneFlag = $1 ;
      }
    } else {
      if(/^END_MAPPING/) {
        ($inMapping = 0 ) ;
      } else {
        if(/(\S+)\s+(\S+)/) {
          $dfIInames{$1} = $2 ;
        }
      }
    }

  }
  return ($groundPlaneFlag,$siMaterialLine,$siLayerLine,%dfIInames) ;
}

sub getSheetResistance {
  my $p2lvsfile = shift ;
  my ($pro_layer,$sheet_res,$sheet_res1,$sheet_res2,%sheetResistance) = 0;
  my $line = undef ;
  my $type ;
  my ($test_string, @array_test);	#newly added

  my @temporary_array;
  my $new_sheet_res;

  open(my $fromP2lvsfile,$TempFolderPath."/".$p2lvsfile) ||
     die "cannot open $p2lvsfile: $!" ;
  while(<$fromP2lvsfile>) {
    chomp ;
    $line = $_ ;
    ($pro_layer,$sheet_res1,$sheet_res2) = (split(/\s+/,$line))[0,2,3] ;
    ($sheet_res1 =~ /(sheet_res|rho)/) || ($sheet_res2 =~ /(sheet_res|rho)/) ||
      next ;
    $type = $1 ;
    $pro_layer =~ s/pro_layer=// ;

    if($sheet_res1 =~ /(sheet_res|rho)/)
    {
      $sheet_res = $sheet_res1;
    }
    else
    {
      $sheet_res = $sheet_res2;
    }

    #ASKK_new $sheet_res =~ s/(sheet_res|rho)=// ;
    if($sheet_res =~ /sheet_res/)
    {
      $sheet_res =~ s/sheet_res=// ;
      #new piece of code
      $test_string = $sheet_res;
      if($test_string =~ /^\(/)
      {
        $test_string =~ s/\(//;
        @array_test = split(',', $test_string);
        $sheet_res = $array_test[0];
        #print "\n$sheet_res\n";
      }
      #end
    }
    elsif($sheet_res =~ /rho/)
    {
      $sheet_res =~ s/rho=// ;

      $test_string = $sheet_res;
      if($test_string =~ /^\(/)
      {
        $test_string =~ s/\(//;
        @array_test = split(',', $test_string);
        $sheet_res = $array_test[3];
        $sheet_res = (split(':', $sheet_res))[0];
        #print "\n$sheet_res\n";
      }
    }

    $sheet_res =~ s/;$// ;
    $sheet_res =~ s/\)$// ;

    #Change mayn't work!!!
    if (!( $sheet_res =~ /^[\+-]*[0-9]*\.*[0-9]*$/ && $sheet_res !~ /^[\. ]*$/  )) #checking for non-numeric values
    {
      $sheet_res = (split(',', $sheet_res))[0];
    }

    $sheetResistance{$pro_layer} = [$type,$sheet_res] ;
  }
  return %sheetResistance ;
}

sub readTechFile {
  my $techFileName = shift ;
  open(my $from , $TempFolderPath."/".$techFile) ||
    die "cannot open $techFileName: $!" ;
  my @all = <$from> ;
  chomp @all ;
  return @all ;
}

sub getLayerNumsFromTechFile {
  my ($lines) = @_ ;
  my ($name,$num,$abrev,%layerNums) ;
  my $inTechLayers = 0 ;
  foreach my $line (@$lines) {
    ($line =~ /^\s*;/) &&
      next ;
    if($inTechLayers) {
      if($line =~ /^\s*\)/) {
        $inTechLayers = 0 ;
        next ;
      }
      $line =~ s/[()]//g ;
      $line =~ s/^\s+// ;
      $line =~ s/\s+$// ;
      ($name,$num,$abrev) = split(/\s+/,$line) ;
      $layerNums{$name} = $num ;
    } else {
      ($line =~ /^\s*techLayers\(/) &&
        ($inTechLayers = 1 ) ;
    }
  }
  return %layerNums ;
}

sub getViasFromMappingFile {
  my $mappingFileName = shift ;
  my ($oxide,$via,%oxideVias) ;
  open(my $from , $TempFolderPath."/".$viaMappingFile) ||
    die "cannot open $mappingFileName: $!" ;
  while(<$from>) {
    chomp ;
    s/^\s+// ;
    s/\s+$// ;
    ($oxide,$via) = split() ;
    $oxideVias{$oxide} = $via ;
  }
  return %oxideVias ;
}

sub getViasFromTechFile {
  my ($lines,$dfIInames) = @_ ;
  my %procNames = reverse(%$dfIInames) ;
  my $inViaLayers = 0 ;
  my ($l1,$via,$l2,%via) ;
   %via = () ;
  foreach my $line (@$lines) {
    ($line =~ /^\s*;/) &&
      next ;
    if($inViaLayers) {
      if($line =~ /^\s*\)/) {
        $inViaLayers = 0 ;
        next ;
      }
      $line =~ s/[()]//g ;
      $line =~ s/^\s+// ;
      $line =~ s/\s+$// ;
      ($l1,$via,$l2) = split(/\s+/,$line) ;
      $l1 = $procNames{$l1} ;
      $l2 = $procNames{$l2} ;
      $via{$l1}{$l2} = $via ;
    } else {
      ($line =~ /^\s*viaLayers\(/) &&
        ($inViaLayers = 1 ) ;
    }
  }
  return %via ;
}
close WRITE;
close($fromProcFile);

deleteFiles();

sub deleteFiles
{
  #close any unclosed file handles
  my @fileHandleList = ("READ1", "READ2", "WRITE1", "WRITE2", "FILEONEH", "FILETWOH", "FILETHREEH", "FH1", "FH2", "FH3", "WRITE");
  foreach my $fileHandle(@fileHandleList)
  {
    close $fileHandle;
  }

  #copying the ltd file; delete it at the end of MomICMod.pl
  move ($TempFolderPath."/".$ltdFile, $ltdFilePath."/");

  #NEW_27062011
  if($MIM_delete_ltdFile == 1)	#delete generated ltd file because of MIM layers in procfile
  {
    unlink($ltdFilePath."/".$ltdFile);
  }

  return 1;
}

exit;

