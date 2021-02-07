/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/FileNameState.h,v $ $Revision: 1.10 $ $Date: 2011/08/25 01:47:10 $ */

#ifndef FILENAMESTATE_H_INCLUDED
#define FILENAMESTATE_H_INCLUDED
// Copyright Keysight Technologies 1997 - 2014  

#ifdef __GNUG__
#pragma interface
#endif

#include "StringState.h"



/** A state with FileName type.
  
  It is inherited from StringState.  Currently the only difference is
  that escape characters are not interpreted.  Filenames using
  backslashes under Windows will work as expected.  */

class FileNameState : public StringState
{
public:
  ///
  FileNameState();
  ///
  FileNameState(const FileNameState &);
  ///
  FileNameState& operator=(const char *);
  ///
  FileNameState& operator=(const FileNameState &);

  /// add an extension to look for in the File Selection GUI
  void addExtension (const char *);
 
  /// Functions for backward compatibility mode ael generation
  void setCompatibilityMode (const char * s) { compatibilityMode << s; }
  const StringList& getCompatibilityMode () { return compatibilityMode; }

  /// return the list of extensions
  const StringList& extensionList () { return myExtensionList; }

  /// return the string "FILENAME"
  const char* type() const { return "FILENAME"; }

  ///@name Class identification
  //@{
  /// 
  int isA(const char*) const;
  /// 
  const char* className() const {return "FileNameState";}
  //@}

private:
  StringList myExtensionList;
  StringList compatibilityMode;
};

MULTISTATE(FileNameState,FileNameMultiState)
#endif


