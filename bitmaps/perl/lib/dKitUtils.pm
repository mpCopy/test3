package dKitUtils;


sub stripLeadingAndTrailingBlanks
# strip leading and trailing blanks from the input line.
# 
# Input: a text string
# Output: the original string with leading and trailing blanks removed.
{
  my ($inputLine) = @_;
  $inputLine =~ s/['"]//g;
  $inputLine =~ s/^\s+//g;
  $inputLine =~ s/\s+$//g;

  return $inputLine;
}


sub joinContinuedLines
# Remove back slash character (\) at the end of the line and append
# the next line to the current line.
# 
# Input: an array of lines of ASCII characters
# Output: an array of lines of ASCII characters with \ at EOL removed
#         and continued lines joined.
{
  my $indx, $contd, $line, $tmp;

  @inData = @_;
  $#new1 = -1;
  $indx=0;
  $contd=0;
  foreach $line (@inData)
  {
    if ($line =~ /(.*)\\\s*$/)
    {
      if($contd == 0)
      {
        $tmp = $1; 
      } 
      else
      {
        $tmp .= $1; 
      }
      $contd = 1;
    } 
    else
    {
      if($contd == 0)
      {
        $tmp = $line; 
      } 
      else
      {
        $tmp .= $line; 
      }
      $contd = 0;
    }

    if($contd == 0)
    {
      $indx += 1;
      $new1[$indx] = $tmp; 
    } 
  }
  @new1;
} # end of joinContinuedLines


sub sortInAscendingOrder
# Sort a list in ascending order
# 
# Input: a list of items with space or , as separator.
# Output: the list with items separated by space and sorted in ascending order.
{
  my ($valueList) = @_;
  $valueList =~ s/['"]//g;
  $valueList =~ s/[,\s][,\s]*/,/g;
  my @items = sort({$a<=>$b} split(/,/, $valueList));
  $valueList = join(' ', @items);
}


sub setAdsInstanceLineFormat
# set the format of ads instance line 
#
# Input: 'model' or 'modelName', adsparams, spectreparams, hspiceparams, and node list.
# Output: the ads instance netlist format based on the inputs. 
{
  my ($model_label, $ads_params, $scs_params, $hsp_params, $nodelist) = @_;

  my $instLine='<' . $model_label . '>:#instanceName ' . $nodelist  
      . ' [[<allParams>]] [[<adsParams>]]';
  $ads_params = stripLeadingAndTrailingBlanks($ads_params);

  if ($hsp_params && (! $ads_params || $ads_params eq "hspiceparams"))
  {
    $instLine="simulator lang=spice\n"
      . '#instanceName ' . $nodelist . ' <' . $model_label 
      . "> [[<allParams>]] [[<hspiceParams>]]\n"
      . "simulator lang=ads\n";
  } 
  elsif ($scs_params && (! $ads_params || $ads_params eq "spectreparams"))
  {
    $instLine="simulator lang=spectre\n"
      . "#instanceName " . $nodelist . ' <' . $model_label 
      . "> [[<allParams>]] [[<spectreParams>]]\n"
      . "simulator lang=ads\n";
  }

  return $instLine;
}


sub adsInstanceParams
# get ads instance parameters
#
# Input: adsparams, spectreparams, and hspiceparams.
# Output: ads parameters to use based on the inputs.
{
  my ($ads_params, $scs_params, $hsp_params) = @_;

  my $instParams =  $ads_params;
  $ads_params = stripLeadingAndTrailingBlanks($ads_params);

  if ($hsp_params && (! $ads_params || $ads_params eq "hspiceparams"))
  {
    $instParams = $hsp_params;
  } 
  elsif ($scs_params && (! $ads_params || $ads_params eq "spectreparams"))
  {
    $instParams = $scs_params;
  }

  return $instParams;
}


sub includeHspiceModel
# set model include line to include Hspice model file or inline content of the file
#
# Input: reference to the arrays hspice_model_lib, a $inline flag, and simulator (ads/spectre)
# Output: the ads/spectre model include line to use or the content of the Hspice model file.
{
  local (*hsp_models, $inline, $simulator) = @_;

  if ( !$simulator )
  {
    $simulator = "ads";
  }

  if ( $inline == 1 )
  {
    $modelInclude = "[[simulator lang=spice\n";
    foreach $lib (@hsp_models)
    {
      print "Reading $lib ...\n";
      open(INF, "<$lib") || die "Failed to open ${lib}!\n" ;
      my @netlists = <INF>;
      close(INF);
      foreach $line (@netlists)
      {
        $modelInclude .= $line;
      }
    }
    $modelInclude .= "simulator lang=" . $simulator . "]]\n";
  } 
  else
  {
    $modelInclude = "[[simulator lang=spice\n"
      . '~eval('
      . 'my $library="<hspiceModelLibrary>"; '
      . 'my $section="<hspiceSectionName>"; '
      . 'if ($section) {return ".lib \"$library\" $section";} '
      . 'elsif ($library) {return ".include \"$library\"";}'
      . ')end]]'
      . "\n"
      . "simulator lang=" . $simulator . "\n";
  } 

  return $modelInclude;
}


sub includeSpectreModel
# set model include line to include Spectre model file or inline content of the file
#
# Input: reference to the arrays spectre_model_lib, a $inline flag
# Output: the ads model include line to use or the content of the Spectre model file.
{
  local (*scs_models, $inline) = @_;

  if ( $inline == 1 )
  {
    $modelInclude = "[[simulator lang=spectre\n";
    foreach $lib (@scs_models)
    {
      print "Reading $lib ...\n";
      open(INF, "<$lib") || die "Failed to open ${lib}!\n" ;
      my @netlists = <INF>;
      close(INF);
      foreach $line (@netlists)
      {
        $modelInclude .= $line;
      }
    }
    $modelInclude .= "simulator lang=ads]]\n";
  } 
  else
  {
    $modelInclude = "[[simulator lang=spectre\n"
      . "include \"<spectreModelLibrary>\"]] [[section=<spectreSectionName>]]\n"
      . "simulator lang=ads\n";
  } 

  return $modelInclude;
}


sub setAdsIncludeFormat
# set ads model include line format
#
# Input: references to the arrays of ads_model_lib, spectre_model_lib, 
#        hspice_model_lib, and a $inline flag
# Output: the ads model include line to use based on the inputs.
{
  local (*ads_models, *scs_models, *hsp_models, $inline) = @_;

  my $modLibTemp = dKitTemplate->getTemplate(MODELLIBRARY);
  my $adsModelIncludeLine = "";
  # If no ADS model is given, use hspice or spectre model for ADS in MODELLIBRARY template
  if ($#hsp_models >= 0 && ($#ads_models < 0 || $ads_models[0] eq "hspice_model_lib"))
  {
      $adsModelIncludeLine = &includeHspiceModel(*hsp_models, $inline, "ads");
  } 
  elsif ($#scs_models >= 0 && ($#ads_models < 0 || $ads_models[0] eq "spectre_model_lib"))
  {
      $adsModelIncludeLine = &includeSpectreModel(*scs_models, $inline);
  } 
  else 
  {
    $adsModelIncludeLine = "[[#define <adsSectionName> <adsSectionName>\n"
      . "]][[#include \"<adsModelLibrary>\"]][[\n"
      . "#undef <adsSectionName>]]\n";
  }
  $modLibTemp->netlistInstanceTemplate(ads, $adsModelIncludeLine);

}


sub setSpectreInstanceLineFormat
# set the format of spectre instance line 
#
# Input: 'model' or 'modelName', spectreparams, hspiceparams, and node list.
# Output: the spectre instance netlist format based on the inputs. 
{
  my ($model_label, $scs_params, $hsp_params, $nodelist) = @_;

  my $instLine='#instanceName ' . $nodelist . ' <' . $model_label 
      . '> [[<allParams>]] [[<spectreParams>]]';

  $scs_params = stripLeadingAndTrailingBlanks($scs_params);

  if ($hsp_params && (!$scs_params || $scs_params eq "hspiceparams"))
  {
    $instLine="simulator lang=spice\n"
      . "#instanceName " . $nodelist . ' <' . $model_label 
      . "> [[<allParams>]] [[<hspiceParams>]]\n"
      . "simulator lang=spectre\n";
  } 

  return $instLine;
}


sub spectreInstanceParams
# get spectre instance parameters
#
# Input: spectreparams and hspiceparams.
# Output: spectre parameters to use based on the inputs.
{
  my ($scs_params, $hsp_params) = @_;

  my $instParams = $scs_params;
  $scs_params = stripLeadingAndTrailingBlanks($scs_params);

  if ($hsp_params && (!$scs_params || $scs_params eq "hspiceparams"))
  {
    $instParams = $hsp_params;
  }

  return $instParams;
}


sub setScsIncludeFormat
# set spectre model include line format
#
# Input: references to the arrays of spectre_model_lib and hspice_model_lib, $inline flag
# Output: the spectre model include line to use based on the inputs.
{
  local (*scs_models, *hsp_models, $inline) = @_;

  my $modLibTemp = dKitTemplate->getTemplate(MODELLIBRARY);
  my $scsModelIncludeLine = "";
  # If no spectre model is given, use hspice model for spectre in MODELLIBRARY template
  if ($#hsp_models >= 0 && ($#scs_models < 0 || $scs_models[0] eq "hspice_model_lib"))
  {
    $scsModelIncludeLine = &includeHspiceModel(*hsp_models, $inline, "spectre");
  } 
  elsif ($#scs_models >= 0)
  {
    if ( $inline == 1 )
    {
      $scsModelIncludeLine = "[[";
      foreach $lib (@scs_models)
      {
        print "Reading $lib ...\n";
        open(INF, "<$lib") || die "Failed to open ${lib}!\n" ;
        my @netlists = <INF>;
        close(INF);
        foreach $line (@netlists)
        {
          $scsModelIncludeLine .= $line;
        }
      }
      $scsModelIncludeLine .= "]]\n";
    }
    else
    {
      $scsModelIncludeLine = '[[include "<spectreModelLibrary>"]] [[section=<spectreSectionName>]]';
    }
  } 
  $modLibTemp->netlistInstanceTemplate(spectre, $scsModelIncludeLine);

}


sub setHspIncludeFormat
# set hspice model include line format
#
# Input: references to the array of hspice_model_lib and $inline flag
# Output: the hspice model include line or inline hspice netlist based on the inputs.
{
  local (*hsp_models, $inline) = @_;

  my $modLibTemp = dKitTemplate->getTemplate(MODELLIBRARY);
  my $hspModelIncludeLine = "";
  if ($#hsp_models < 0)
  {
    $hspModelIncludeLine = "";
  } 
  elsif ( $inline == 1 )
  {
    $hspModelIncludeLine = "[[";
    foreach $lib (@hsp_models)
    {
      print "Reading $lib ...\n";
      open(INF, "<$lib") || die "Failed to open ${lib}!\n" ;
      my @netlists = <INF>;
      close(INF);
      foreach $line (@netlists)
      {
        $hspModelIncludeLine .= $line;
      }
    }
    $hspModelIncludeLine .= "]]\n";
  }
  else
  {
    $hspModelIncludeLine = '[[~eval('
      . 'my $library="<hspiceModelLibrary>"; '
      . 'my $section="<hspiceSectionName>"; '
      . 'if ($section) {return ".lib \"$library\" $section";} '
      . 'elsif ($library) {return ".include \"$library\"";}'
      . ')end]]';
  }
  $modLibTemp->netlistInstanceTemplate(hspice, $hspModelIncludeLine);

}



1
