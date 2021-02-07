/* @(#) $Source: /cvs/wlv/src/linker/source/Linker.h,v $ $Revision: 1.8 $ $Date: 2011/08/28 20:25:32 $ */

#ifndef LINKER_H_INCLUDED
#define LINKER_H_INCLUDED
// Copyright Keysight Technologies 2001 - 2017  

#ifdef __GNUG__
#pragma interface
#endif

#include "compat.h"
#include "HPstddefs.h"
#include "gui_unistd.h"
#include "gui_stdlib.h"
#include "linkerDll.h"
#include "HashTable.h"
/*
#include <map>

#ifndef PTAIX
using namespace __STLPORT_STD;
#endif

struct ltstr
{
  int operator()(const char* s1, const char* s2) const
  {
    return strcmp(s1, s2) < 0;
  }
};

typedef map<const char *, void *, ltstr > MapTable;
*/

enum LinkerLocalHandling
{
    SYMBOLS_ARE_GLOBAL,
    SYMBOLS_ARE_LOCAL,
    SYMBOLS_ARE_LOCAL_SYMBOLIC
};

class Linker {
 public:

  Linker ();
  ~Linker ();

  /** Load a shared library.  If FALSE is returned, call the error()
      method for an explanation.  Opening an opened library again will
      do nothing succesfully.  The second argument will override the
      default extension. */
  static int openLib (const char *library, const char *extension = 0, char**mesage = NULL);

  /** Load a shared library #2 (yes, it's grotesque).  We should be using
      overloading, but too many disparate parts use this, including
      non-easily-rebuilt Tiburon libraries, and so we have a separate function
      for this.

      If FALSE is returned, call the error() method for an explanation.
      Opening an opened library again will do nothing succesfully.  The second
      argument will override the default extension. */
  static int openLib2 (const char *library, const char *extension, char**mesage, const enum LinkerLocalHandling handling);

  /** openLibLocal() is a kludge that is exactly like openLib(), except
      that libararies are loaded using SYMBOLS_ARE_LOCAL_SYMBOLIC on linux. */
  static int openLibLocal (const char *library, const char *extension = 0, char**mesage = NULL);

  /** Load a shared library just like openLib except it accepts a path as
      an argument */
  static int genericOpenLib (const char *library, const char *extension = 0, char**message = NULL, const char *path = 0, const int loaderFlags = -1);

  /** Close a loaded shared library. Pass the name of an opened library.
      If FALSE is returned, call the error() method for an explanation. */
  static int closeLib (const char *library);
  
  /** Look up a symbol in a loaded shared library.  Pass the name of
      an opened library. If NULL is returned, call the error() method
      for an explanation. */
  static void* getSymbol (const char *library, const char *name);

  /** Return an explanation of the last error. */
  static const char* error () { return errorMsg; }
  
  /** Return TRUE if the linker is currently active (so objects can be
      marked as dynamically linked by the known list classes).
      Actually the flag it returns is set while constructors or other
      functions that have just been linked are being run.  */
  static int isActive() { return activeFlag; }

  /** Return TRUE if the linker is doing a dynamic link.  The HP
      Ptolemy Linker only does dynamic links so the result is the same
      as isActive() */
  static int doingDynLink() { return isActive(); }
  
  /** Returns true if the linker is supported on the current platform */
  static int enabled() { return enabledFlag; }

  /** Returns true if HP Ptolemy is modular on the current platform */
  static int modular() { return modularFlag; }

  /** Returns the default shared library file extension.  Includes the
      "." for the extension.  This is a const pointer and data; do not
      use free() or delete upon it!  */
  static const char * const getLibraryDefaultExtension();

 private:
  DllImport static int activeFlag, enabledFlag, modularFlag;
  static void setError (const char *);
  // errorMsg should be const char* but gives problems on multiple platforms (AIX,HPUX cfront)
  DllImport static char *errorMsg;
  DllImport static HashTable libTable;
  //  DllImport void * libTable;
};


#endif
