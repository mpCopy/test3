#ifndef PT_FSTREAM_H_INCLUDED
#define PT_FSTREAM_H_INCLUDED
// Copyright Keysight Technologies 1996 - 2014  

#ifdef __GNUG__
#pragma interface
#endif

#include <iostream>
#include <fstream>
#include "compat.h"

#ifdef _WIN32 
#include <stdio.h>
#endif

#ifdef _WIN64
#include <stdio.h>
#endif

#include "EEsofIpc/LegacyRemoteFile.h"

#if defined(PTHPPA)
using namespace std;
#endif

#if defined(PTSOL2) && defined(_LP64)
#define PTSOL2_64
#endif

using std::ios;
using std::ios_base;
using std::istream;
using std::ostream;
using std::streambuf;
using std::streampos;
using std::streamoff;

/** Input and output Ptolemy stream classes

    The classes pt_ifstream and pt_ofstream are derived from the
    standard istream and ostream classes.  They use their own
    streambuf which uses gemx primitives so that file I/O over a
    remote simulation works correctly.  They also have the following
    features:

    First, certain special ``filenames'' are recognized.  pt_ifstream
    recognizes {\tt <cin>} and {\tt <stdin>}.  pt_ofstream recognizes
    {\tt <cout>}, {\tt <cerr>}, {\tt <clog>}, {\tt <stdout>}, and {\tt
    <stderr>}.  Note that in a remote simulation, these will open on
    the remote side.

    Second, the Ptolemy {\tt expandPathName} function is applied to
    filenames before they are opened, permitting them to start with
    {\tt ~user} or {\tt $VAR}.

    Finally, if a failure occurs when a file is opened or closed, {\tt
    Error::abortRun} is called with an appropriate error message.

*/

#ifndef streamsize
#if defined(PTHPPA) || defined (PTSOL2_64) || defined(linux64)
#define streamsize long
#else
#define streamsize int
#endif
#endif

class gemxbuf : public streambuf {
protected:
  virtual int overflow(int = EOF);
  virtual streamsize xsputn(const char *s, streamsize n);

  virtual int uflow();
  virtual int underflow();
  virtual streamsize xsgetn(char *s, streamsize n);
  virtual int pbackfail(int c);
  virtual streampos seekoff(streamoff, ios_base::seek_dir, int =ios_base::in|ios_base::out);
  virtual streampos seekpos(streampos, int =ios_base::in|ios_base::out);

public:
  gemxbuf();
  ~gemxbuf();
  int open(const char *name, int mode, int prot=0664);
  int close();
protected:
  eesof::ipc::LegacyRemoteFile myf;
  bool takeFromBuf;
  char charBuf;
};

class gemxstreambase : virtual public ios {
  void _my_sb_init();
  streambuf* check_special(const char *);
public:
  gemxbuf _my_sb;
  gemxstreambase();
  gemxstreambase(const char *name, int mode, int prot=0664);
  void open(const char *name, int mode, int prot=0664);
  void close();
  iostate _my_state;
};

class pt_ofstream : public gemxstreambase, public ostream {
public:
  pt_ofstream() : ostream (&_my_sb) { }
  pt_ofstream(const char *name, int mode=ios_base::out, int prot=0664)
    : gemxstreambase(name, mode, prot), ostream(&_my_sb) {clear(_my_state);}
  void open(const char *name, int mode=ios_base::out, int prot=0664)
  { gemxstreambase::open(name, mode, prot); }
};

class pt_ifstream : public gemxstreambase, public istream {
public:
  pt_ifstream() : istream (&_my_sb) { }
  pt_ifstream(const char *name, int mode=ios_base::in, int prot=0664)
    : gemxstreambase(name, mode, prot), istream(&_my_sb) {clear(_my_state);}
  void open(const char *name, int mode=ios_base::in, int prot=0664)
  { gemxstreambase::open(name, mode, prot); }
};

#endif
