#Generate the library install instructions
# Copyright Keysight Technologies 2002 - 2013  


$destfile = $ARGV[0];
$control = $ARGV[1];
$hped = $ARGV[2];
$libName = $ARGV[3];
$company = $ARGV[4];
$company =~ s/_/ /g;

open(INPUT, "<$control");
@pkginfo = <INPUT>;
close(INPUT);

sub grabinfo
{
    my ($input, $output) = @_;
    my @temp = split(/:/,$input);
    $output = $temp[1];
    $output =~ s/^\s+//;
    $output =~ s/\s+$//;
    return $output;
}

foreach $pkginfo (@pkginfo)
{
    $pkginfo =~ s/^\s+//;
    $pkginfo =~ s/\s+$//;
}
for ($i = 0; $i < @pkginfo; $i++)
{
     if ($pkginfo[$i] =~ /PACKAGE:/)
     {
	 $pkg_name = grabinfo($pkginfo[$i]);
     }
     if ($pkginfo[$i] =~ /VERSION:/)
     {
	 $pkg_ver = grabinfo($pkginfo[$i]);
     }
     if ($pkginfo[$i] =~ /MAINTAINER:/)
     {
	 $pkg_maint = grabinfo($pkginfo[$i]);
     }
     if ($pkginfo[$i] =~ /DESCRIPTION:/)
     {
	 $pkg_desc = grabinfo($pkginfo[$i]);
     }
     if ($pkginfo[$i] =~ /Encoding Date:/)
     {
         @temp = split(/:/,$pkginfo[$i]);
	 @out = splice(@temp, 1, $#temp);
         $output = join(":",@out);;
         $output =~ s/^\s+//;
         $output =~ s/\s+$//;
	 $pkg_date = $output;
     }
     if ($pkginfo[$i] =~ /\*\* Library Contents \*\*/)
     {
	 $index = $i;
	 last;
     }
}

$n = $#pkginfo - $index;
@pkg_content = splice(@pkginfo, -$n);

$contents="";
$i=0;
foreach $pkg_content (@pkg_content)
{ 
    if ($i == 0)
    {
        $contents = $contents." ".$pkg_content."\n";
    }
    else
    {
        $contents = $contents."\t\t\t  ".$pkg_content."\n";
    }
    $i++;
}

open(OUTPUT, ">$destfile");
print OUTPUT << "DOC";

	       Advanced Design System Version 2004A
	       RF IP Encoded Library Instructions

OVERVIEW

This automatically generated document provides
instructions on installing, removing, and using the 
encoded IP library ($libName) described below:
 
	$libName
	Library Vendor	: $company
	Library Version	: $pkg_ver
	Date Encoded	: $pkg_date
	Maintainer	: $pkg_maint
	Description	: $pkg_desc
        Encoded Content :$contents

The encoded IP library is distributed as a standard, platform-independent,
ADS 2004A Add-On package.  Along with the file that contained these 
instructions you should have received a package file named $libName.deb.  
If you do not have the file $libName.deb, contact the library vendor.

In order to install the encoded IP library, you must have write access
to the ADS 2004A installation directory.  Before installing the encoded 
library, be sure to exit ADS, and then follow the instructions under 
"SETTING ENVIRONMENT VARIABLES".  The sections "INSTALLING THE ENCODED 
IP LIBRARY", "VIEWING CURRENTLY INSTALLED PACKAGES", and "REMOVING AN 
ENCODED IP LIBRARY" all require that you have opened a terminal window 
and set your environment variables appropriately, therefore, always start 
with the section "SETTING ENVIRONMENT VARIABLES".

SETTING ENVIRONMENT VARIABLES

Windows Environment Setup

1. Copy the file $libName.deb to your ADS installation directory.
   Typically your ADS 2004A installation directory will be

	c:\\Ads2004A

   Place the file $libName.deb into this directory.

NOTE: The commands in these instructions assume the installation
directory is c:\\Ads2004A. If ADS2004A is installed in a different 
location then adjust the instructions accordingly.

2. Open an MSDOS shell.

3. If you don't already have one, create a temporary directory in 
   your boot drive. For example, if your boot drive is C:, then type:

     mkdir c:\\tmp

   If you already have a temporary directory then proceed to step 4.

4. Change to your ADS 2004A installation directory. At the command
   prompt, type:

     cd c:\\ADS2004A

5. Add the "bin" directory to your path by typing:

     set path=c:\\ADS2004A\\bin;\%path\%

Unix Environment Setup

1. Open a terminal window.

2. Copy the files for your architecture to your ADS 2004A
   installation directory (see instructions above).

3. Set the HPEESOF_DIR environment variable to the ADS 2004A
   installation area. 

4. Change directory to the installation area:

     cd \$HPEESOF_DIR

5. Add the \$HPEESOF_DIR/bin to your PATH environment variable.

INSTALLING THE ENCODED IP LIBRARY (UNIX and Windows)

To install the encoded IP library package ($libName.deb), from the
terminal window, type:

   hpeesofpkg -i $libName.deb

Note: If an old version of the encoded IP library exists, you don't
have to remove the old one to install the new one, the packager
will automatically overwrite the old installation.

VIEWING CURRENTLY INSTALLED PACKAGES (UNIX and Windows)

To view the list of currently installed packages, including your
encoded IP libraries, open a terminal window and type:

   hpeesofpkg --list

REMOVING AN ENCODED IP LIBRARY (UNIX and Windows)

You can remove an encoded IP Library that has been previously
installed by typing

   hpeesofpkg --remove <package_name> 

where <package_name> is the name of the encoded IP library being
removed. For example, in the case of the package that contains
the encoded IP library $libName, the command to remove would be:

   hpeesofpkg --remove $pkg_name

Note: Ensure the encoded IP library package exists and that you
have the correct spelling before attempting to remove it. See
"VIEWING CURRENTLY INSTALLED PACKAGES" for information on how to 
view the existing packages.

USING THE ENCODED IP LIBRARY (UNIX and Windows)

If installation has been completed successfully, then the encoded
IP library will appear as $libName in the "Component Library
Browser".  There will also be a component palette named 
$libName in the schematic window.

Encoded IP libraries can be used in Advanced Design System just
like any other library with the exception of being able to push
into its hierarchy.  If an encoded component design has variable 
parameters, you are able to change the value of certain components
within the design. This information is typically provided by the
vendor. Refer to the ADS manual for more information on variable 
parameters.

DOC

close(OUTPUT);
