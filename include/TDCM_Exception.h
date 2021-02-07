// Copyright Keysight Technologies 2009 - 2011  
#ifndef __TDCM__EXCEPTION_INCLUDE_FILE__
#define __TDCM__EXCEPTION_INCLUDE_FILE__

#include "TDCM_String.h"

namespace TDCM{
  class Exception{
  public:
    Exception(const char* message);
   ~Exception();
   const char* what();
  private:
   String message;
  };
}

#endif
