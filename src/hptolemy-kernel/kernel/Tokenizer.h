/******************************************************************
Version identification:
@(#)Tokenizer.h	1.19	3/28/96

Copyright (c) 1990-1995 The Regents of the University of California.
All rights reserved.

Permission is hereby granted, without written agreement and without
license or royalty fees, to use, copy, modify, and distribute this
software and its documentation for any purpose, provided that the
above copyright notice and the following two paragraphs appear in all
copies of this software.

IN NO EVENT SHALL THE UNIVERSITY OF CALIFORNIA BE LIABLE TO ANY PARTY
FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES
ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, EVEN IF
THE UNIVERSITY OF CALIFORNIA HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGE.

THE UNIVERSITY OF CALIFORNIA SPECIFICALLY DISCLAIMS ANY WARRANTIES,
INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE SOFTWARE
PROVIDED HEREUNDER IS ON AN "AS IS" BASIS, AND THE UNIVERSITY OF
CALIFORNIA HAS NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES,
ENHANCEMENTS, OR MODIFICATIONS.

						PT_COPYRIGHT_VERSION_2
						COPYRIGHTENDKEY

 Programmer:  J. T. Buck
 Date of creation: 3/18/90

*******************************************************************/
/* @(#) $Source: /cvs/wlv/src/hptolemyaddons/src/hptolemy/kernel/Tokenizer.h,v $ $Revision: 100.22 $ $Date: 2011/08/25 01:47:10 $ */


#ifndef TOKENIZER_H_INCLUDED
#define TOKENIZER_H_INCLUDED
// Copyright  1996 - 2017 Keysight Technologies, Inc  

#ifndef _Tokenizer_h
#define _Tokenizer_h 1
#ifdef __GNUG__
#pragma interface
#endif

#include "DataStruct.h"
#include "ptolemyDll.h"
#include <iostream>
#include "StringList.h"

const int maxTokenSize = 1024*10;

class TokenContext;

/** A simple lexical analyzer class.

  The Tokenizer class is designed to accept input for a string or file
  and break it up into tokens.  It is similar to the standard istream
  class in this regard, but it has some additional facilities.  It
  permits character classes to be defined to specify that certain
  characters are white space and others are ``special'' and should be
  returned as single-character tokens; it permits quoted strings to
  override this, and it has a file inclusion facility.  In short, it
  is a simple, reconfigurable lexical analyzer.

  Tokenizer can use include files ({\tt fromFile} method), and can
  nest them to any depth.  It maintains a stack of include files, and
  as EOF is reached in each file, it is closed and popped off of the
  stack.

  To use the tokenizer to parse strings in memory, use a constructor
  like:

  \code
  Tokenizer lexer("x+2.0*y/(z-23)", "*+-/()");
  \endcode

  Here, successive {\tt lexer >> tokenbuf} operations will return x,
  +, 2.0, *, y, /, (, z, -, 23, and ).  Subsequent calls will return
  strings of length zero (the first character of tokenbuf will be set
  to 0).*/
class Tokenizer {
private:
  const char *special;		//list of one-character tokens
  const char *whitespace;	//list of whitespace characters
  std::istream *strm;		//associated input stream
  TokenContext* stack;		//stack for include files
  char* curfile;		//current input file name
  short depth;			//depth of nesting
  short myStrm;			//true if strm needs deletion at end
  int line_num;			//current line number
  char comment_char;		//character for comments
  char quote_char;		//character for quoted strings
  char escape_char;		//behave like the " \ " in C
  int escape_enabled;           //whether escape character parsing is enabled
  char c;			//last char read
  char ungot;
  
  struct {			//variables for pushback buffer
    char* ptr;
    int index, size;
  } pb_buffer;

  // this is the common part of all constructors
  void init ();

  // this method reads a character from the stream into c
  int get();

  // used to include files from other files and get back
  void push(std::istream* s,const char* f);

  void pop();

public:
  /** The ``default whitespace characters'' string.

    Tokenizer has a public const data member named {\tt defWhite} that
    contains the default white space characters: space, newline, and
    tab.  It is possible to change the definition of white space for a
    particular constructor.  */
  HPTOLEMY_KERNEL_API static const char *defWhite;

  /** Construct a tokenizer that reads from the standard input stream.

    The default constructor creates a Tokenizer that reads from the
    standard input stream, {\tt cin}.  Its special characters are
    simply {\tt (} and {\tt )}.*/
  Tokenizer();

  /** Construct a tokenizer that reads from a given stream.

    This constructor creates a Tokenizer that reads from the stream
    named by {\tt input}.  The other arguments specify the special
    characters and the white space characters.*/
  Tokenizer(std::istream& input,const char* spec,const char* w = defWhite);
  
  /// Construct a tokenizer that reads from a given string
  Tokenizer(const char* buffer,const char* spec,const char* w = defWhite);

  /// Destructor - Close any applicable input streams
  ~Tokenizer();

  /** Return the name of the current file where the Tokenizer is
    currently reading from.  This information is maintained for
    include files.  At the top level, {\tt current_file} returns a
    null pointer.  */
  inline const char* current_file() const { return curfile;}

  /** Return the current line number where the Tokenizer is currently
    reading from.  This information is maintained for include files.
    At the top level, {\tt current_line} returns one more than the
    number of line feeds seen so far.  */
  inline int current_line() const { return line_num;}

  /** Open a file and read tokens from it. This method opens a new
    file and the Tokenizer will then read from that.  When that file
    ends, Tokenizer will continue reading from the current point in
    the current file.  */
  int fromFile(const char* name);

  /// Return TRUE if reading from an include file, FALSE otherwise
  inline int readingFromFile() const { return depth > 0 ? 1 : 0;}

  /** Return the next token from the given string.  This operator is
    the basic mechanism for reading tokens from the Tokenzier.
    
    Here {\tt pBuffer} points to a character buffer that reads the
    token.  There is a design flaw: there isn't a way to give a
    maximum buffer length, so overflow is a risk.  Define the buffer
    to be of size maxTokenSize for consistency. */
  Tokenizer& operator >> (char * pBuffer);

  /** Return next token as above except using StringList to prevent
    buffer overflow */
  Tokenizer& operator >> (StringList& strBuffer);

  /// Return NULL if we at EOF
  inline operator void* () { return eof() ? 0 : this; }

  /** Push back a token; there is no limit to the number of tokens
    pushed back.  */
  void pushBack(const char* s);

  /** Returns TRUE if the end of file or end of input has been
    reached.  It is possible that there is nothing left in the input
    but write space, so in many situations \code{skipwhite} should be
    called before making this test.  */
  int eof() const;

  /// Skip whitespace in the input
  void skipwhite();

  /// Clears through whitespace and comments, stops at eof 
  void clearwhite();

  /** Error cleanup - discard current line or close files.  If in an
    include file, the file is closed.  If at the top level, discard
    the rest of the current line.  */
  void flush();

  /// Change the white space characters, return the previous ones
  const char* setWhite(const char* w) {
    const char* t = whitespace;
    whitespace = w;
    return t;
  }

  /// Change the special characters, return the previous ones
  const char* setSpecial(const char* s) {
    const char* t = special;
    special = s;
    return t;
  }

  /** Change the comment character (``\#'' is the default).  This
    method is used to change the comment character.  If you would like
    to disable this feature, specify 0 as it's argument.  By default
    the comment charachter is {\tt \#}.

    Returns the old comment character.*/
  char setCommentChar(char n) {
    char o = comment_char;
    comment_char = n;
    return o;
  }

  /// Change the quote character, return old one
  char setQuoteChar(char n) {
    char o = quote_char;
    quote_char = n;
    return o;
  }

  /// Return the next character
  char peekAtNextChar();


  /// Enable or disable escape character parsing, return old setting
  int enableEscape (int n) {
      int o = escape_enabled;
      escape_enabled = n;
      return o;
  }
};

#endif







#endif   /* TOKENIZER_H_INCLUDED */
