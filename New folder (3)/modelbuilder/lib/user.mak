# @(#) $Source: /cvs/sr/src/geminiui/modelbuilder/user.mak,v $ $Revision: 1.4 $ $Date: 2003/02/27 00:45:57 $
#
#*****************************************************************************
#
# PLEASE NOTE THAT many variables defined here are platform 
# dependent. It is recommended to use following statements 
# to check platform type so the modification of this file is
# not neccessary when you switch the platform you need to 
# work on.
#
#       ifeq (win32,$(findstring win32,$(ARCH)))
#       ifeq (hpux,$(findstring hpux,$(ARCH)))
#       ifeq ($(findstring sun,$(ARCH)),sun)
#       ifeq ($(ARCH),aix4)
#
# For example:
#   ifeq (win32,$(findstring win32,$(ARCH)))
#       USER_OBJ = My_other_object_file.obj
#   else
#       USER_OBJ = My_other_object_file.o
#   endif
#
#*****************************************************************************


# Add your senior source modules here.

# Add your senior header files here, if any

# (only CURRENT_SOURCE can be dependent on this)

#STARS = 

# Stars to compile and link in
USER_STARS =

# Include path for user C++ include files (must use .cc suffix)
USER_CPLUS_INCLS =

# Other C++ source files to link in
USER_CPLUS_SRCS =

# Include path for other C include files
USER_C_INCLS =

# Other C source files to link in (must use .c suffix)
USER_C_SRCS =

# Other object files to link in
USER_OBJ =

# Libraries to link in
USER_LIBS =

