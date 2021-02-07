
# $Header: /cvs/wlv/src/cedamk/mk/m4/rules.mk,v 1.108 2008/12/08 18:22:08 build Exp $


####################
# Installation


$(INSTALL_INCLUDEDIR):
	$(at)$(MKDIR) $(INSTALL_INCLUDEDIR)

ifdef NEWCEDAMK_HEADER_AWARE
$(INSTALL_INCLUDEDIR)/%: $(PROJECT_PUBLIC_INCPATH)/% $(INSTALL_INCLUDEDIR)
else
$(INSTALL_INCLUDEDIR)/%: % $(INSTALL_INCLUDEDIR)
endif
	$(at)$(MKDIR) $(INSTALL_INCLUDEDIR)
	$(CP) $< $@
	$(at)$(MKDIR) $(INSTALL_INCLUDEDIR)
	$(CP) $< $@

$(INSTALL_LIBDIR):
	$(at)$(MKDIR) $(INSTALL_LIBDIR)

$(INSTALL_LIBDIR)/%: % $(INSTALL_LIBDIR)
	$(CP) $< $@

$(INSTALL_BINDIR):
	$(at)$(MKDIR) $(INSTALL_BINDIR)

$(INSTALL_BINDIR)/%: % $(INSTALL_BINDIR)
	$(CP) $< $@

clean::
	$(RM) -r $(OBJPATH) $(CLEAN)
	$(RM) -f $(MAKE_DEFS_MK)

realclean:: clean
	$(RM) $(REALCLEAN) $(INSTALL_OBJECTS)

####################
# Lex & Yacc

%.c: %.l
	$(at)$(RM) $@
	$(LEX.l) $< > $@

%.c: %.y
	$(YACC.y) $<
	if [ -f y.tab.c ] ; then mv -f y.tab.c $@; fi


###############################################################################
#
# Start of Python compilation rules
#
###############################################################################

.SUFFIXES: .py .pyc

%.pyc: %.py
	compile_python $< $@

ifdef PYTHON_SRCS
ALL_OBJECTS += $(PYTHON_SRCS:.py=.pyc)
endif


###############################################################################
#
# Start of AEL compilation rules
#
###############################################################################

.SUFFIXES: .ael .atf

%.atf: %.ael
	aelcomp $< $@

ifdef AEL_SRCS
ifndef COMBINE_BUILD_64_BIT_PASS
ALL_OBJECTS += $(AEL_SRCS:.ael=.atf)
endif
endif


###############################################################################
#
# Start of regression test rules
#
###############################################################################

.SUFFIXES: .net .ckt .ds

%.ds : %.net
	python $(HPEESOF_DEV_ROOT)/bin/simtest.py $< $(OBJPATH) $(COMPARISONTOOL)

%.ds : %.ckt
	python $(HPEESOF_DEV_ROOT)/bin/simtest.py $< $(OBJPATH) $(COMPARISONTOOL)

ifdef QUICK_NETS
QUICK_REGRESS += $(QUICK_NETS:.net=.ds)
QUICK_REGRESS += $(QUICK_NETS:.ckt=.ds)
endif

ifdef NIGHT_NETS
NIGHT_REGRESS += $(NIGHT_NETS:.net=.ds)
NIGHT_REGRESS += $(NIGHT_NETS:.ckt=.ds)
endif

ifdef FULL_NETS
FULL_REGRESS += $(FULL_NETS:.net=.ds)
FULL_REGRESS += $(FULL_NETS:.ckt=.ds)
endif


###############################################################################
#
# Start of QT 4 MOC (meta-object compiler) rules
#
# To enable this rule, define the variable qt4-MOC_HDRS.  Its value should be the
# list of header files that need MOC files created.  Header files can end
# in ".h" or ".hxx".
#
# The MOC-generated files reside in $(OBJPATH) and have a .cpp suffix.
#
###############################################################################

ifdef qt4-MOC_HDRS

    #
    # The Qt 4 Visual Studio plug-in sends macro definitions and include paths
    # to "moc" on the command line, so I do the same here.  I don't know whether it's
    # needed.  There's no single variable to use to get all of the include paths, so
    # I take them out of $(CXXFLAGS).
    #
    # /D, /I, and /U are converted to -D, -I, and -U.  This is needed only for
    # Windows, but it seems simpler to always perform the transformation, even
    # on non-Windows builds.
    #
    # The combining of the defines and undefines into separate lists has the
    # unfortunate side effect of losing the interleaving of the two.  This
    # will cause a problem if CPPFLAGS is something like
    #
    #     -UFOO -DFOO=1
    #
    # because this will become
    #
    #     -DFOO=1 -UFOO 
    #
    # These rules will also create problems when the value of a macro has spaces in it:
    #
    #     -DFOO="Two words"
    #
    # because this will become
    #
    #     -DFOO="Two
    #
    # The -p option to MOC deletes the relative path from the header
    # file that is #included in the %_moc.cpp file.  hpeesofdepends
    # barfs on include files that have a relative path.
    #

    qt4-MOC_DEFINES =           $(filter -D%, $(patsubst /D%,-D%,$(CPPFLAGS)))
    qt4-MOC_UNDEFINES =         $(filter -U%, $(patsubst /U%,-U%,$(CPPFLAGS)))
    qt4-MOC_INCLUDEPATHOPTION = $(filter -I%, $(patsubst /I%,-I%,$(CXXFLAGS)))
    qt4-MOC_CPPFLAGS = $(qt4-MOC_DEFINES) $(qt4-MOC_UNDEFINES) $(qt4-MOC_INCLUDEPATHOPTION)

    qt4-MOC_COMMAND = $(qt4-MOC) $(qt4-MOC_CPPFLAGS) -p ./ -o "$@" "$<"

    $(OBJPATH)/%_moc.cpp: %.hxx
	$(at)$(MKDIR) $(OBJPATH)
	$(qt4-MOC_COMMAND)

    $(OBJPATH)/%_moc.cpp: %.h
	$(at)$(MKDIR) $(OBJPATH)
	$(qt4-MOC_COMMAND)

    # Create the list of MOC-generated source files
    qt4-MOC_SRCS = $(foreach f, $(qt4-MOC_HDRS), $(OBJPATH)/$(basename $(f))_moc.cpp)

    SRCS += $(qt4-MOC_SRCS)

    clean::
	$(RM) $(qt4-MOC_SRCS)

endif	# qt4-MOC_HDRS


###############################################################################
#
# Start of QT 4 RCC (resource compiler) rules
#
# To enable this rule, define the variable qt4-QRC_FILES.  Its value should be the
# list of .qrc files that need to be RCC-compiled.
#
# The RCC-generated files reside in $(OBJPATH) and have a .cpp suffix.
#
###############################################################################

ifdef qt4-QRC_FILES

    $(OBJPATH)/%_rcc.cpp: %.qrc
	$(MKDIR) $(dir $@)
	$(qt4-RCC) -name $(basename $(notdir $<)) -no-compress -o "$@" "$<"

    # Create the list of RCC-generated source files
    qt4-RCC_SRCS = $(foreach f, $(qt4-QRC_FILES), $(OBJPATH)/$(basename $(f))_rcc.cpp)

    SRCS += $(qt4-RCC_SRCS)

    clean::
	$(RM) $(qt4-RCC_SRCS)

endif	# qt4-QRC_FILES    


###############################################################################
#
# Start of QT 4 UIC (UI compiler) rules
#
# To enable this rule, define the variable qt4-UI_FILES.  Its value should be the
# list of .ui files that need to be UIC-compiled.
#
# The UIC-generated header files reside in $(OBJPATH) and have a .h suffix.
#
###############################################################################

ifdef qt4-UI_FILES

    $(OBJPATH)/%_ui.h: $(SRCPATH)/%.ui
	$(MKDIR) $(dir $@)
	$(qt4-UIC) -o "$@" "$<"

    # Create the list of UIC-generated header files
    qt4-UI_HDRS = $(foreach f, $(qt4-UI_FILES), $(OBJPATH)/$(basename $(f))_ui.h)

    #
    # Use the "pre_compile" target to make sure that the UIC-generated headers
    # exist before the "compile" target is made.  Otherwise, hpeesofdepends does not
    # find the header file  and the .ui file is never processed (because there's
    # nothing in the hpeesofdepends-generated dependency list that depends on the
    # header file that UIC produces).
    #
    pre_compile :: $(qt4-UI_HDRS)
    
    #
    # Add the paths of the UIC-generated header files to INCLUDEPATH so that
    # the compiler (and hpeesofdepends) can find them.  Use "sort" to get rid
    # of duplicates.
    #
    qt4-UI_DIRS = $(sort $(dir $(qt4-UI_HDRS)))
    INCLUDEPATH += $(qt4-UI_DIRS)

    clean::
	$(RM) $(qt4-UI_HDRS)
  
endif	# qt4-UI_FILES






###############################################################################
#
# Start of SKILL compilation rules
#
# Make context files from the files enumerated in SKILL_DEFS and SKILL_SRCS.
#
###############################################################################


# SKILL sources loaded in the first pass.  Should contain all class
# definitions.
ifdef SKILL_DEFS
ALL_SRCS += $(SKILL_DEFS)
SKILL_DEFS_PP += $(SKILL_DEFS:.il=.ilpp)
ALL_OBJECTS += $(SKILL_DEFS_PP)
MAKE_SKILL_LOADER = 1
endif

# SKILL sources loaded in the second pass.  Should not contain any class
# definitions.
ifdef SKILL_SRCS
ALL_SRCS += $(SKILL_SRCS)
SKILL_SRCS_PP += $(SKILL_SRCS:.il=.ilpp)
ALL_OBJECTS += $(SKILL_SRCS_PP)
MAKE_SKILL_LOADER = 1
endif


# A SKILL context file is built when the $(SKILL_CONTEXT) variable is set.
# The $(OBJPATH)/ prefix on the .ini target is done to match the rule for
# that target, below.  See the comment there for an explanation.
ifdef SKILL_CONTEXT
ALL_OBJECTS += $(foreach CDS_VER,$(CDS_VERSIONS),$(CDS_VER)/$(SKILL_CONTEXT).cxt $(CDS_VER)/$(SKILL_CONTEXT)Build.il $(CDS_VER)/$(SKILL_CONTEXT).al)
ifdef SKILL_CONTEXT_INI
ALL_OBJECTS += $(foreach CDS_VER,$(CDS_VERSIONS),$(OBJPATH)/$(CDS_VER)/$(SKILL_CONTEXT).ini)
endif
MAKE_SKILL_LOADER = 1
compile-pre::
	@$(foreach CDS_VER,$(CDS_VERSIONS),if [ ! -d $(CDS_VER) ] ; then mkdir $(CDS_VER); fi;)
endif


# set the MAKE_SKILL_LOADER to force the creation of the loader scripts
# (only necessary if a directory has neither SKILL_DEFS nor SKILL_SRCS
# but contains subdirectories with SKILL_DEFS or SKILL_SRCS or both)
ifdef MAKE_SKILL_LOADER
ALL_OBJECTS += load_defs.il load_srcs.il autoload.il
endif


# "compiling" SKILL script files: run them through the C preprocessor, then
# use perl to strip out any '#' lines that the preprocessor may have added
%.ilpp: %.il
	$(SKILLPP) -DPUBLIC= -DPRIVATE= $(CPPFLAGS) $< | perl -e 'while (<>) { print unless /^#/ }' > $@


# compiling SKILL context files: create the ___Build.il script to define
# the compilation process, then start a Cadence process to run it.  The
# dependency on autoload.il is the method by which a change to a source
# file several directories deep can trigger the rebuild of the context
# file.
%.cxt: $(SKILL_DEFS_PP) $(SKILL_SRCS_PP) %Build.il autoload.il
	$(CDSENV) $(*D:/=) icms -ilLoadIL $*Build.il -nograph -log $*.log


# SKILL: a header to be placed at the top of all auto-generated SKILL
# scripts.  Pass the output file path as the sole parameter.
define skill_autogen_header
	$(ECHO) "; auto-generated by CEDAMK" > $(1)
	$(ECHO) ";   source: $(SRCPATH)/make-defs" >> $(1)
	$(ECHO) ";   date: `date`" >> $(1)
	$(ECHO) "; " >> $(1)
endef

# SKILL: load a file from a subdirectory.  Pass the output file path as the
# first parameter and the relative path to the file to load as the second.
# (The strange path given to load() is to make stack traces more useful.  If
# there's an error loading the file, the stack trace will show you the "full
# path" to each file that was loaded.)
define skill_load_from_subdir
	$(ECHO) "let( ( olddir )" >> $(1)
	$(ECHO) "\tolddir = pwd()" >> $(1)
	$(ECHO) "\tcd( \"$(dir $(2))\" )" >> $(1)
	$(ECHO) "\tload( \"../$(OBJPATH)/$(2)\" )" >> $(1)
	$(ECHO) "\tcd( olddir )" >> $(1)
	$(ECHO) ")" >> $(1)
	$(ECHO) "" >> $(1)
endef

# SKILL: make a loader.  Pass the output file path in the first parameter,
# the list of files in the second parameter, and the list of subdirectories
# in the third.
define skill_make_loader
	$(call skill_autogen_header,$(1))
	$(ECHO) "" >> $(1)
	$(ECHO) "; load files from this directory" >> $(1)
	$(foreach FILE,$(2),$(ECHO) "load( \"$(OBJPATH)/$(FILE)\" )" >> $(1);)
	$(ECHO) "" >> $(1)
	$(ECHO) "; load files from subdirectories" >> $(1)
	$(foreach DIR,$(3),$(call skill_load_from_subdir,$(1),$(DIR)/$(notdir $(1)));)
endef


# SKILL: construct an autoload fragment for all "PUBLIC" functions in this
# directory.  Pass the output file path in the first parameter, the list of
# SKILL source files in the second parameter, and the list of subdirectories'
# autoload.il files in the third.
#
# The regexp looks for procedures and defmethods which are preceded by the
# CommsEDA-standard keyword PUBLIC.  The trailing )?)? are only present to
# avoid a gmake misfeature; without these, gmake complains that the foreach
# call is unterminated and is missing a )'.
define skill_make_autoload_frag
	$(foreach FILE,$(2),$(PERL) -e 'while (<>) { print "$$2.autoload = thisCxt\n" if /PUBLIC\s+(procedure|defmethod)\s*\(\s*([^(\s]+)\)?\)?/ }' < $(FILE) >> $(1);)
	$(foreach FILE,$(3),cat $(FILE) >> $(1);)
endef


# The "defs" are loaded, throughout the entire depth of the hierarchy, before
# any of the "srcs" are loaded.  The load_defs.il and load_srcs.il perform
# their respective functions for this directory and all subdirectories.
load_defs.il: $(SRCPATH)/make-defs
	@-rm -f $@
	@$(ECHO) "Creating $@"
	@$(call skill_make_loader,$@,$(SKILL_DEFS_PP),$(DIRS))

load_srcs.il: $(SRCPATH)/make-defs
	@-rm -f $@
	@$(ECHO) "Creating $@"
	@$(call skill_make_loader,$@,$(SKILL_SRCS_PP),$(DIRS))


# The autoload.il file contains all auto-load declarations for this directory
# and all subdirectories.  When a context file is built, the content for the
# $(SKILL_CONTEXT).al file is taken from the topmost autoload.il.
#
# The autoload.il file also serves as the mechanism for dependency propagation
# up the directory hierarchy.  Whenever any SKILL file is changed, the context
# file must be rebuilt; but we don't want to maintain a gmake dependency from
# the context file on every single SKILL file.  If any file in a directory is
# updated, its autoload.il file is updated.  This causes the autoload.il file
# in each parent directory to also be updated.  The context file is given a
# dependency on the topmost autoload.il file, which ensures that it is updated
# whenever any SKILL file has changed.
autoload.il: $(SRCPATH)/make-defs $(SKILL_DEFS_PP) $(SKILL_SRCS_PP) $(addsuffix /autoload.il,$(addprefix $(OBJPATH)/,$(DIRS)))
	@-rm -f $@
	@$(ECHO) "Creating $@"
	@$(call skill_make_autoload_frag,$@,$(addprefix $(SRCPATH)/,$(SKILL_DEFS)) $(addprefix $(SRCPATH)/,$(SKILL_SRCS)),$(addsuffix /autoload.il,$(DIRS)))

%.al: autoload.il
	@$(ECHO) "let( ( thisCxt )" > $@
	@$(ECHO) "\tthisCxt = prependInstallPath( \"$(*F).cxt\" )  ; FIXME" >> $@
	@$(PERL) -e 'while (<>) { print "\t$$_" }' < autoload.il >> $@
	@$(ECHO) ")" >> $@

# The .ini file is copied from $(SKILL_CONTEXT_INI).  Chances are, the file
# at $(SKILL_CONTEXT_INI) has the same filename as the target, and without
# the leading $(OBJPATH)/ this rule is matched recursively.  Things proceed
# normally except for a gmake warning, indicating that a circular dependency
# of $(SKILL_CONTEXT_INI) on $(SKILL_CONTEXT_INI) has been discarded.  The
# $(OBJPATH)/ was added here to prevent the warning, and this required an
# analogous change to the "ifdef SKILL_CONTEXT" section above.
$(OBJPATH)/%.ini: $(SRCPATH)/$(SKILL_CONTEXT_INI)
	@$(CP) $(SRCPATH)/$(SKILL_CONTEXT_INI) $@

# The context-building script loads, in this order:
#  - all prerequisite contexts
#  - all SKILL_DEFS down through the hierarchy
#  - all SKILL_SRCS down through the hierarchy
%Build.il: $(SRCPATH)/make-defs load_defs.il load_srcs.il
	@$(ECHO) "Creating build script: $@"
	@-rm -f $@
	@$(call skill_autogen_header,$@)
	@$(ECHO) "" >> $@
	@$(ECHO) "procedure( getContext(cxt)" >> $@
	@$(ECHO) "   ;; Given a context name load the context into the session" >> $@
	@$(ECHO) "   let(((ff strcat( prependInstallPath(\"etc/context/\") cxt \".cxt\")))" >> $@
	@$(ECHO) "      (cond ((null (isFile ff)) nil)" >> $@
	@$(ECHO) "            ((null (loadContext ff))" >> $@
	@$(ECHO) "                   (println strcat(\"Failed to load context \" cxt)))" >> $@
	@$(ECHO) "            ((null (callInitProc cxt))" >> $@
	@$(ECHO) "                   (println strcat(\"Failed to initialize context \" cxt)))" >> $@
	@$(ECHO) "            (t (println strcat(\"Loading Context \" cxt)))" >> $@
	@$(ECHO) "      )" >> $@
	@$(ECHO) "   )" >> $@
	@$(ECHO) ")" >> $@
	@$(ECHO) "" >> $@
	@$(ECHO) "procedure( loadSkillCore()" >> $@
	@$(ECHO) "   let((path skillDirs skillCoreFile)" >> $@
	@$(ECHO) "      unless(isContextLoaded(\"skillCore\")" >> $@
	@$(ECHO) "         path=simplifyFilename(prependInstallPath(\"..\"))" >> $@
	@$(ECHO) "         skillDirs=sort(setof(x getDirFiles(path) substring(x 1 5)==\"SKILL\") nil)" >> $@
	@$(ECHO) "         foreach(skillDir skillDirs" >> $@
	@$(ECHO) "            when(isFile(strcat(path \"/\" skillDir \"/context/skillCore.cxt\"))" >> $@
	@$(ECHO) "               skillCoreFile=strcat(path \"/\" skillDir \"/context/skillCore.cxt\")" >> $@
	@$(ECHO) "            )" >> $@
	@$(ECHO) "         )" >> $@
	@$(ECHO) "         when(skillCoreFile" >> $@
	@$(ECHO) "            loadContext(skillCoreFile)" >> $@
	@$(ECHO) "         )" >> $@
	@$(ECHO) "      )" >> $@
	@$(ECHO) "   )" >> $@
	@$(ECHO) ")" >> $@
	@$(ECHO) "" >> $@
	@$(ECHO) "let( ( exitStatus )" >> $@
	@$(ECHO) "  exitStatus = 1" >> $@
	@$(ECHO) "  errset(" >> $@
	@$(ECHO) "    progn(" >> $@
	@$(ECHO) "      ; load Skill core functions" >> $@
	@$(ECHO) "      loadSkillCore()" >> $@
	@$(ECHO) "      " >> $@
	@$(ECHO) "      ; load prerequisite contexts" >> $@
	@$(foreach CXT,$(SKILL_PREREQ_CONTEXTS),$(ECHO) "      getContext( \"$(CXT)\" )" >> $@;)
	@$(ECHO) "      " >> $@
	@$(ECHO) "      ; create the $(*F) context" >> $@
	@$(ECHO) "      setContext( \"$*\" )" >> $@
	@$(ECHO) "      sstatus( writeProtect $(if $(debug),nil,t) )" >> $@
	@$(ECHO) "      load( \"load_defs.il\" )" >> $@
	@$(ECHO) "      load( \"load_srcs.il\" )" >> $@
	@$(ECHO) "      saveContext( \"$*.cxt\" )" >> $@
	@$(ECHO) "      " >> $@
	@$(ECHO) "      ; return success" >> $@
	@$(ECHO) "      exitStatus = 0" >> $@
	@$(ECHO) "    )" >> $@
	@$(ECHO) "  )" >> $@
	@$(ECHO) "  " >> $@
	@$(ECHO) "  ; close the Cadence session" >> $@
	@$(ECHO) "  exit( exitStatus )" >> $@
	@$(ECHO) ")" >> $@


###############################################################################
#
# Compilation
#
# Create subdirectories first if SRCS are defined as dir/file.c
#

REQUIREDSUBDIRS=$(strip $(addprefix $(OBJPATH)/, $(sort $(filter-out ./, $(dir $(SRCS) $(ALL_SRCS))))))

#
# Do not list phony targets here.  Doing so will always cause dependencies
# be updated, which consumes valuable time!
#

ifneq ($(REQUIREDSUBDIRS), ) 
compile-pre :: $(REQUIREDSUBDIRS)

$(REQUIREDSUBDIRS):
	$(at)$(MKDIR) $@
endif

# COMPILE.c and COMPILE.cxx are parameterized, to allow for file-specific
# compile options.
# Note that, in the following, only one parameter may be passed to these
# define's -- that's OK.

define COMPILE.c
$(CC_PREFIX) $(CC) $(CFLAGS) $(CPPFLAGS) /c $(1) $(2) $(3)
endef

define COMPILE.cxx
$(CXX_PREFIX) $(CXX) $(CXXFLAGS) $(CPPFLAGS) /c $(1) $(2) $(3)
endef

%.obj: %.c
	$(call COMPILE.c, /Fo$@ $<)

%.obj: %.cc
	$(call COMPILE.cxx, /Fo$@ $<)

%.obj: %.cxx
	$(call COMPILE.cxx, /Fo$@ $<)

%.obj: %.cpp
	$(call COMPILE.cxx, /Fo$@ $<)

####################
# Static libraries

ifdef NEWARBUILDRULE

ifeq ($(suffix $(TARGET)),.a)
LIBCOBJS  =${addprefix $(LIBBASENAME).lib(, ${addsuffix ), $(patsubst   %.c, %.obj,$(filter %.c, $(SRCS)))}}
ifneq (,$(LIBCOBJS))
(%.obj): %.c ;
$(OBJPATH)/$(LIBBASENAME).lib :: $(LIBCOBJS)
	${call COMPILE.c, ${addprefix $(SRCPATH)/, $(?:.obj=.c)}}
	$(call UPDATE_LIBRARY_COMMAND,$@,${notdir $(?:.c=.obj)});
	$(RM) ${notdir $(?:.c=.obj)}
endif
LIBCCOBJS =${addprefix $(LIBBASENAME).lib(, ${addsuffix ), $(patsubst  %.cc, %.obj,$(filter %.cc, $(SRCS)))}}
ifneq (,$(LIBCCOBJS))
(%.obj): %.cc ;
$(OBJPATH)/$(LIBBASENAME).lib :: $(LIBCCOBJS)
	$(call COMPILE.cxx, $(addprefix $(SRCPATH)/, ${?:.obj=.cc}))
	$(call UPDATE_LIBRARY_COMMAND,$@,${notdir $(?:.cc=.obj)});
	$(RM) ${notdir $(?:.cc=.obj)}
endif
LIBCPPOBJS=${addprefix $(LIBBASENAME).lib(, ${addsuffix ), $(patsubst %.cpp, %.obj,$(filter %.cpp, $(SRCS)))}}
ifneq (,$(LIBCPPOBJS))
(%.obj): %.cpp ;
$(OBJPATH)/$(LIBBASENAME).lib :: $(LIBCPPOBJS)
	$(call COMPILE.cxx, $(addprefix $(SRCPATH)/, ${?:.obj=.cpp}))
	$(call UPDATE_LIBRARY_COMMAND,$@,${notdir $(?:.cpp=.obj)});
	$(RM) ${notdir $(?:.cpp=.obj)}
endif
LIBCXXOBJS=${addprefix $(LIBBASENAME).lib(, ${addsuffix ), $(patsubst %.cxx, %.obj,$(filter %.cxx, $(SRCS)))}}
ifneq (,$(LIBCXXOBJS))
(%.obj): %.cxx ;
$(OBJPATH)/$(LIBBASENAME).lib :: $(LIBCXXOBJS)
	$(call COMPILE.cxx, $(addprefix $(SRCPATH)/, ${?:.obj=.cxx}))
	$(call UPDATE_LIBRARY_COMMAND,$@,${notdir $(?:.cxx=.obj)});
	$(RM) ${notdir $(?:.cxx=.obj)}
endif
.SPECIAL: $(LIBCOBJS) $(LIBCCOBJS) $(LIBCPPOBJS) $(LIBCXXOBJS)
endif
else
ifeq ($(suffix $(TARGET)),.a)
# DO NOT CHANGE THIS WITHOUT ALSO CHANGING THE SCRIPT THAT HANDLES MULTIPLE
# TARGETS!
$(OBJPATH)/$(LIBBASENAME).lib: $(OBJS)
	$(call UPDATE_LIBRARY_COMMAND,$@,$^)
endif
endif

####################
# Shared libraries

# arg 1: target name, arg 2: template file, arg 3: .h file to create
define MAKE_TARGET_DLL_H
$(PERL) -p -e "s/LIBNAME/$(basename $(1))/g" '$(shell cygpath -w $(2))' > $(3)
endef




ifeq ($(suffix $(TARGET)),.sl)

TARGETDLLH = $(basename $(TARGET))Dll.h
EXTRASRCS += $(TARGETDLLH)
REALCLEAN += $(TARGETDLLH)
# DO NOT CHANGE THIS WITHOUT ALSO CHANGING THE SCRIPT THAT HANDLES MULTIPLE
# TARGETS!
#
# wrapped with ifdef because both static and shared build .lib files under
# win32
$(OBJPATH)/$(LIBBASENAME)$(SLLIBVER).dll $(LIBBASENAME)$(SLLIBVER).exp: $(OBJS)
	$(call SL_MAKE_EXP,$(LIBBASENAME)..dll,$^,$(LIBBASENAME).exp)
	$(call SL_MAKE_OBJFILES,$(OBJS))
	$(call SL_LINK_CXX,$(OBJPATH)/$(LIBBASENAME)$(SLLIBVER).dll,$(OBJS),$(TARGET_LIBS),$(LIBBASENAME))

# DO NOT CHANGE THIS WITHOUT ALSO CHANGING THE SCRIPT THAT HANDLES MULTIPLE
# TARGETS!
$(TARGETDLLH): $(ceda_mk_dir)/lib/DllImport.h
	$(call MAKE_TARGET_DLL_H,$(TARGET),$^,$@)
endif

####################
# Executables




#########################################################################
# Ensure the time depencies for private libraries work

LOCALLIBDIRS = $(addprefix $(OBJPATH)/, $(LOCAL_LIBSPATH))

# Hack, kluge: do not build anything in lib.$(ARCH):
$(HPEESOF_DEV_ROOT_UNIX)/lib.$(ARCH)/%: ;

ifeq (win,$(findstring win,$(ARCH)))
LIB_SEARCH_DIRS = $(foreach dir,$(LOCALLIBDIRS) $(MULTIMK_LIBSPATH) $(LIBSPATH),$(shell cygpath -u $(dir)))
else
LIB_SEARCH_DIRS = $(LOCALLIBDIRS) $(MULTIMK_LIBSPATH) $(LIBSPATH)
endif

vpath %.lib $(LIB_SEARCH_DIRS)
vpath %.dll $(LIB_SEARCH_DIRS)
$( )$(basename $(TARGET)).exe: $(LOCAL_LIBS:%=-l%) $(LIBS:%=-l%)

# DO NOT CHANGE THIS WITHOUT ALSO CHANGING THE SCRIPT THAT HANDLES MULTIPLE
# TARGETS!
$( )$(basename $(TARGET)).exe: $(OBJS)
ifdef FORCE_CXX_LINK
	$(call CXXLINKEXE,$@,$(OBJS) $(LIBSPATHOPTION),$(LIBS) $(TARGET_LIBS))
else
ifneq (,$(filter %.cc,$(SRCS)))
	$(call CXXLINKEXE,$@,$(OBJS) $(LIBSPATHOPTION),$(LIBS) $(TARGET_LIBS))
else
ifneq (,$(filter %.cxx,$(SRCS)))
	$(call CXXLINKEXE,$@,$(OBJS) $(LIBSPATHOPTION),$(LIBS) $(TARGET_LIBS))
else
ifneq (,$(filter %.cpp,$(SRCS)))
	$(call CXXLINKEXE,$@,$(OBJS) $(LIBSPATHOPTION),$(LIBS) $(TARGET_LIBS))
else
	$(call CCLINKEXE,$@,$(OBJS) $(LIBSPATHOPTION),$(LIBS) $(TARGET_LIBS))
endif
endif
endif
endif

####################
# Dependencies


MAKEDEPEND=$(ceda_mk_dir)/bin.$(ARCH)/hpeesofdepend
MAKEDEPENDFLAGS += -M -- $(filter-out /U%,$(CPPFLAGS:/D%=-D%)) -- $(patsubst /I%,-I%,$(INCLUDEPATHOPTION) $(CINCLUDEPATHOPTION) $(CXXINCLUDEPATHOPTION))  $(WIN_INCLUDE_VAR) 

ifdef NEWARBUILDRULE

# MACRO MAKEDEPEND_COMMAND
# ## 1 : library name  2 : sources
#
ifeq ($(ARCH),win32_64)
define MAKEDEPEND_COMMAND
$(if $(strip $(1)), ksh -c $(MAKEDEPEND) -f $(OBJPATH)/make-depends -a -p "$(LIBPREFIX)$(1)$(ARSUFFIX)(" -o "$(OBJSUFFIX))" $(MAKEDEPENDFLAGS) $(2), $(MAKEDEPEND) -f $(OBJPATH)/make-depends -a $(MAKEDEPENDFLAGS) $(2);)
endef
else
define MAKEDEPEND_COMMAND
$(if $(strip $(1)), $(MAKEDEPEND) -f $(OBJPATH)/make-depends -a -p "$(LIBPREFIX)$(1)$(ARSUFFIX)(" -o "$(OBJSUFFIX))" $(MAKEDEPENDFLAGS) $(2), $(MAKEDEPEND) -f $(OBJPATH)/make-depends -a $(MAKEDEPENDFLAGS) $(2);)
endef
endif

$(OBJPATH)/make-depends : make-defs $(SRCS) $(ALL_SRCS) $(NONTARGETSRCS) 
	$(at)$(MKDIR) $(OBJPATH)
	: >$(OBJPATH)/make-depends
ifneq ($(strip $(SRCS)),)
ifeq ($(suffix $(TARGET)),.a)
	$(call MAKEDEPEND_COMMAND,$(basename $(TARGET)),$(SRCS))
else
	$(call MAKEDEPEND_COMMAND,,$(SRCS))
endif
endif
ifneq ($(strip $(MULTIMK_LIBNAMES)),)
	$(foreach libname, $(MULTIMK_LIBNAMES), $(call MAKEDEPEND_COMMAND,$(libname),$($(libname)_SRCS)))
endif
ifneq ($(strip $(MULTIMK_NONLIBNAMES)),)
	$(foreach name, $(MULTIMK_NONLIBNAMES), $(call MAKEDEPEND_COMMAND,,$($(name)_SRCS)))
endif
ifneq ($(strip $(NONTARGETSRCS)),)
	$(call MAKEDEPEND_COMMAND,,$(NONTARGETSRCS))
endif


else	# not NEWARBUILDRULE

$(OBJPATH)/make-depends : make-defs $(SRCS) $(ALL_SRCS) $(NONTARGETSRCS)
ifneq ($(strip $(SRCS) $(NONTARGETSRCS) $(ALL_SRCS)),)
	$(at)$(MKDIR) $(OBJPATH)
	: >$(OBJPATH)/make-depends
	$(MAKEDEPEND) -f $(OBJPATH)/make-depends -a $(MAKEDEPENDFLAGS) \
          $(SRCS) $(ALL_SRCS) $(NONTARGETSRCS)
ifeq (win,$(findstring win,$(ARCH)))
	perl -pi.bak -e 's|\ss:/| /|ig;' $(OBJPATH)/make-depends
endif
endif

endif	# not NEWARBUILDRULE

ifdef TARGETS
ifdef SRCPATH

ifndef LONGTARGETSLINE
$(ceda_mk_dir)/bin/multimk: ;
$(SRCPATH)/$(MAKE_DEFS_MK):  $(SRCPATH)/make-defs  $(ceda_mk_dir)/bin/multimk
	$(at)$(PERL) '$(shell cygpath -w $(ceda_mk_dir)/bin/multimk)' $(TARGETS) > $@
else	# not LONGTARGETSLINE
$(ceda_mk_dir)/bin/multimk: ;
$(SRCPATH)/$(MAKE_DEFS_MK):  $(SRCPATH)/make-defs  $(ceda_mk_dir)/bin/multimk
	$(at)echo "" > $@; for i in $(TARGETS); do $(PERL) '$(shell cygpath -w $(ceda_mk_dir)/bin/multimk)' $$i >> $@; done
endif	# not LONGTARGETSLINE
endif	# SRCPATH

endif	# TARGETS

####################
# Targets

ifeq ($(suffix $(TARGET)),.sl)
ALL_OBJECTS += $(OBJPATH)/$(LIBBASENAME)$(SLLIBVER).dll
INSTALL_OBJECTS += $(INSTALL_LIBDIR)/$(LIBBASENAME)$(SLLIBVER).dll $(INSTALL_LIBDIR)/$(LIBBASENAME).lib
else
ifeq ($(suffix $(TARGET)),.a)
ALL_OBJECTS += $(OBJPATH)/$(LIBBASENAME).lib
INSTALL_OBJECTS += $(INSTALL_LIBDIR)/$(LIBBASENAME).lib
else
ifeq ($(suffix $(TARGET)),)
ifdef TARGET
ALL_OBJECTS += $( )$(basename $(TARGET)).exe
INSTALL_OBJECTS += $(INSTALL_BINDIR)/$( )$(basename $(TARGET)).exe
endif	# TARGET
endif	# ifeq ($(suffix $(TARGET)),)
endif	# not ifeq ($(suffix $(TARGET)),.a)
endif	# not ifeq ($(suffix $(TARGET)),.sl)

ifneq ($(strip $(NONLIBOBJS)),)
ALL_OBJECTS += $(NONLIBOBJS)
INSTALL_OBJECTS += $(INSTALL_LIBDIR)/$(NONLIBOBJS)
endif

ifndef PUBLIC_HDRS
ifdef PUBLIC-HDRS
# We're only supporting PUBLIC-HDRS temporarily, for migration purposes.
PUBLIC_HDRS = $(PUBLIC-HDRS)
_dummy := $(warning ***** WARNING: PUBLIC-HDRS is obsolete, and will stop working in the future!)
else
PUBLIC_HDRS = $(HDRS)
endif
endif

ifdef NEWCEDAMK_HEADER_AWARE
PUBLIC_HDRS := $(foreach hdr,$(PUBLIC_HDRS),$(PROJECT_PUBLIC_INCPATH)/$(notdir $(hdr)))
endif

ifndef INSTALL_HDRS
INSTALL_HDRS = $(foreach hdr,$(PUBLIC_HDRS),$(strip $(INSTALL_INCLUDEDIR)/$(notdir $(hdr))))
endif

ifndef DO_NOT_INSTALL_HDRS
INSTALL_OBJECTS += $(INSTALL_HDRS)
endif

ifdef OBJBUILD

.PHONY:  compile-pre compile-real compile-post

compile::  compile-pre compile-real compile-post 


compile-pre::

compile-real:: $(ALL_OBJECTS)

compile-post::

install:: $(ALL_OBJECTS) $(INSTALL_OBJECTS)

ifeq (win,$(findstring win,$(ARCH)))
install::	
	if [ -f $(strip $(TARGET)).exe.manifest ] ; then $(CP) $(strip $(TARGET)).exe.manifest $(INSTALL_BINDIR) ; fi
	if [ -f $(strip $(TARGET)).dll.manifest ] ; then $(CP) $(strip $(TARGET)).dll.manifest $(INSTALL_LIBDIR) ; fi
	if [ -f $(basename $(TARGET))$(SLLIBVER).dll.manifest ] ; then $(CP) $(basename $(TARGET))$(SLLIBVER).dll.manifest $(INSTALL_LIBDIR) ; fi
	$(foreach t,$(basename $(TARGETS)), if [ -f $(t).exe.manifest ] ; then $(CP) $(t).exe.manifest $(INSTALL_BINDIR) ; fi ; )
	$(foreach t,$(basename $(TARGETS)), if [ -f $(t)$(SLLIBVER).dll.manifest ] ; then $(CP) $(t)$(SLLIBVER).dll.manifest $(INSTALL_LIBDIR) ; fi ; )
endif
	

ifdef DEVEL_LIBRARYTYPE 
# This is needed here because the "normal" install needs to run first
install:: install-devpkg install-custpkg 
	@echo "Default install target"
endif

# $(OBJS): $(SRCPATH)/make-defs

ifndef NOAUTODEPEND
# Sigh.  The following no longer generates an error, for those builds without
# any dependencies (like ael-only directories).
-include make-depends
endif

else				# not OBJBUILD

ifndef NO_DEFAULT_INSTALL
ifeq ($(COPYALLTARGETSTOPUBLIC),0)
NO_DEFAULT_INSTALL=1
endif
ifdef DONOTCOPYALLTARGETSTOPUBLIC
NO_DEFAULT_INSTALL=1
endif
endif

ifdef NO_DEFAULT_INSTALL
all:: compile check
else
all:: compile check install
endif

ifdef OBJPATH
ifndef NOAUTODEPEND
objpathdep = $(OBJPATH)/make-depends
endif
compile sources:: $(SRCS) $(NONTARGETSRCS) $(EXTRASRCS)

compile check install quick night full:: $(objpathdep)
ifneq ($(strip $(ALL_OBJECTS)),)
	$(at)$(MKDIR) $(OBJPATH)
	$(at)$(MAKE) -C $(OBJPATH) $(PARALLEL) $(npd) OBJBUILD=1 \
	  -f $(SRCPATH)/makefile $@
endif

ifneq ($(strip $(QUICK_REGRESS)),)
	$(at)$(MKDIR) $(OBJPATH)
	$(at)$(MAKE) -C $(OBJPATH) $(PARALLEL) $(npd) OBJBUILD=1 \
	 -f $(SRCPATH)/makefile $@
endif


ifneq ($(strip $(NIGHT_REGRESS)),)
	$(at)$(MKDIR) $(OBJPATH)
	$(at)$(MAKE) -C $(OBJPATH) $(PARALLEL) $(npd) OBJBUILD=1 \
	 -f $(SRCPATH)/makefile $@
endif


ifneq ($(strip $(FULL_REGRESS)),)
	$(at)$(MKDIR) $(OBJPATH)
	$(at)$(MAKE) -C $(OBJPATH) $(PARALLEL) $(npd) OBJBUILD=1 \
	 -f $(SRCPATH)/makefile $@
endif

quick::$(QUICK_REGRESS)
night::$(NIGHT_REGRESS)
full::$(FULL_REGRESS)

endif				# OBJPATH

endif				# not OBJBUILD

ifdef USESCORRECTSYSTEMINCLUDESYNTAX
 MAKEDEPENDFLAGS += -S
endif

####################
# Doxygen

ifeq ($(wildcard Doxyfile),Doxyfile)
DOXYSRC_DIRS := $(shell grep -w '^INPUT' Doxyfile | sed -e 's/^.*=//')
ifdef SOURCEROOT
DOXYSRCPATH := $(subst $(SOURCEROOT),doxysrc,$(shell pwd))
else
DOXYSRCPATH := $(subst $(DEFAULT_SOURCEROOT),doxysrc,$(shell pwd))
endif
LOCAL_DOXYGEN := $(LOCAL_ROOT)/projects/doxygen
BUILD_DOXYGEN := $(HPEESOF_DEV_ROOT)/projects/doxygen
export PATH := $(PATH):$(LOCAL_DOXYGEN)/bin.$(ARCH):$(LOCAL_DOXYGEN)/scripts:$(BUILD_DOXYGEN)/bin.$(ARCH):$(BUILD_DOXYGEN)/scripts:$(HPEESOF_DIR)/tools/bin
endif

doxygen:
ifdef DOXYSRC_DIRS
	$(at)# found a Doxyfile -> run Doxygen here
	$(foreach d,$(DOXYSRC_DIRS),doxyfilter.py ./$d $(DOXYSRCPATH)/$d ; )
ifneq ($(wildcard $(LOCAL_DOXYGEN)/Doxyfile.template),)
	composeDoxyfile.py --project $(PROJECT_NAME) --template $(LOCAL_DOXYGEN)/Doxyfile.template < Doxyfile > $(DOXYSRCPATH)/Doxyfile
else
	composeDoxyfile.py --project $(PROJECT_NAME) --template $(BUILD_DOXYGEN)/Doxyfile.template < Doxyfile > $(DOXYSRCPATH)/Doxyfile
endif
	grep -w '^OUTPUT_DIRECTORY' $(DOXYSRCPATH)/Doxyfile | sed -e 's/^.*=//' | xargs mkdir -p
	( cd $(DOXYSRCPATH) && doxygen )
else
ifeq ($(notdir $(shell pwd)),build)
	$(at)# we recursed up to the build root -> go no further
	$(error No Doxyfile was found)
else
	$(at)# no Doxyfile found at this level -> try the parent directory
	$(at)$(MAKE) -C .. $@
endif
endif

.PHONY: doxygen


####################
# Debugging



echoenv::
	@$(ECHO) PROJECT_NAME = $(PROJECT_NAME)
	@$(ECHO) DIRS = $(DIRS)
	@$(ECHO) TARGET = $(TARGET)
	@$(ECHO) TARGETS = $(TARGETS)
ifdef TARGETS
	@echo $(foreach t,$(basename $(TARGETS)),$(t)_SRCS = $($(t)_SRCS) "\n")
	@echo $(foreach t,$(basename $(TARGETS)),$(t)_LIBS = $($(t)_LIBS) "\n")
endif
	@$(ECHO) SRCS = $(SRCS)
	@$(ECHO) HDRS = $(HDRS)
	@$(ECHO) PUBLIC_HDRS = $(PUBLIC_HDRS)
	@$(ECHO) INSTALL_HDRS = $(INSTALL_HDRS)
	@$(ECHO) AEL_SRCS = $(AEL_SRCS)
	@echo
	@$(ECHO) ALL_OBJECTS = $(ALL_OBJECTS)
	@$(ECHO) QUICK_REGRESS = $(QUICK_REGRESS)
	@$(ECHO) NIGHT_REGRESS = $(NIGHT_REGRESS)
	@$(ECHO) FULL_REGRESS = $(FULL_REGRESS)
	@$(ECHO) INSTALL_OBJECTS = $(INSTALL_OBJECTS)
	@$(ECHO) OBJS = $(OBJS)
	@echo
	@$(ECHO) NONLIBSRCS = $(NONLIBSRCS)
	@$(ECHO) NONLIBOBJS = $(NONLIBOBJS)
	@$(ECHO) NONTARGETSRCS = $(NONTARGETSRCS)
	@$(ECHO) EXTRASRCS = $(EXTRASRCS)
	@echo
	@$(ECHO) SRCPATH = $(SRCPATH)
	@$(ECHO) VPATH = $(VPATH)
	@$(ECHO) PREINCLUDEPATH = $(PREINCLUDEPATH)
	@$(ECHO) LOCAL_BUILD_MIRROR_INCLUDEPATH = $(LOCAL_BUILD_MIRROR_INCLUDEPATH)
	@$(ECHO) LOCAL_BUILD_INCLUDEPATH = $(LOCAL_BUILD_INCLUDEPATH)
	@$(ECHO) EXTRA_INCLUDEPATH = $(EXTRA_INCLUDEPATH)
	@$(ECHO) INCLUDEPATH = $(INCLUDEPATH)
	@$(ECHO) CINCLUDEPATH = $(CINCLUDEPATH)
	@$(ECHO) CXXINCLUDEPATH = $(CXXINCLUDEPATH)
	@$(ECHO) INCLUDEPATHOPTION = $(INCLUDEPATHOPTION)
	@$(ECHO) LIB_SEARCH_DIRS = $(LIB_SEARCH_DIRS)
	@$(ECHO) _LIBPATTERNS = $(_LIBPATTERNS)
	@$(ECHO) LIBSPATHOPTION = $(LIBSPATHOPTION)
	@$(ECHO) LIBSOPTION = $(LIBSOPTION)
	@$(ECHO) LIBSPATH = $(LIBSPATH)
	@$(ECHO) LIBS = $(LIBS)
	@$(ECHO) LOCAL_BUILD_MIRROR_LIBSPATH = $(LOCAL_BUILD_MIRROR_LIBSPATH)
	@$(ECHO) LOCAL_BUILD_LIBSPATH = $(LOCAL_BUILD_LIBSPATH)
	@$(ECHO) LOCAL_LIBSPATH = $(LOCAL_LIBSPATH)
	@$(ECHO) LOCAL_LIBS = $(LOCAL_LIBS)
	@$(ECHO) EXTRA_INCLUDEPATH = $(EXTRA_INCLUDEPATH)
	@$(ECHO) EXTRA_LIBSPATH = $(EXTRA_LIBSPATH)
	@$(ECHO) EXTRA_LIBS = $(EXTRA_LIBS)
	@$(ECHO) CUSTPACKAGES = $(CUSTPACKAGES)
	@$(ECHO) CUSTPACKAGES_FILES = $(CUSTPACKAGES_FILES)
	@$(ECHO) DEVPACKAGES = $(DEVPACKAGES)
	@$(ECHO) DEVPACKAGES_FILES = $(DEVPACKAGES_FILES)
	@$(ECHO) SPECIAL_CUSTPACKAGES = $(SPECIAL_CUSTPACKAGES)
	@$(ECHO) SPECIAL_DEVPACKAGES = $(SPECIAL_DEVPACKAGES)
	@$(ECHO) CC = $(CC)
	@$(ECHO) CXX = $(CXX)
	@$(ECHO) CPPFLAGS = $(CPPFLAGS)
	@$(ECHO) CPPFLAGS_DEBUG = $(CPPFLAGS_DEBUG)
	@$(ECHO) CPPFLAGS_OPT = $(CPPFLAGS_OPT)
	@$(ECHO) CFLAGS = $(CFLAGS)
	@$(ECHO) CFLAGS_DEBUG = $(CFLAGS_DEBUG)
	@$(ECHO) CFLAGS_OPT = $(CFLAGS_OPT)
	@$(ECHO) CFLAGS_OPT_LESSER = $(CFLAGS_OPT_LESSER)
	@$(ECHO) CXXFLAGS = $(CXXFLAGS)
	@$(ECHO) CXXFLAGS_DEBUG = $(CXXFLAGS_DEBUG)
	@$(ECHO) CXXFLAGS_OPT = $(CXXFLAGS_OPT)
	@$(ECHO) CXXFLAGS_OPT_LESSER = $(CXXFLAGS_OPT_LESSER)
	@$(ECHO) C_LDFLAGS = $(C_LDFLAGS)
	@$(ECHO) C_LDFLAGS_POST = $(C_LDFLAGS_POST)
	@$(ECHO) CXX_LDFLAGS = $(CXX_LDFLAGS)
	@$(ECHO) CXX_LDFLAGS_POST = $(CXX_LDFLAGS_POST)
	@$(ECHO) LIBLINK = $(LIBLINK)
	@$(ECHO) EXEFLAGS = $(EXEFLAGS)
	@$(ECHO) COMMON_SYSTEM_LIBS = $(COMMON_SYSTEM_LIBS)
	@$(ECHO) COMMON_SYSTEM_ARCHIVE_LIBS = $(COMMON_SYSTEM_ARCHIVE_LIBS)
	@$(ECHO) COMMON_SYSTEM_SHLIBS = $(COMMON_SYSTEM_SHLIBS)
	@$(ECHO) CEDALIBVER = $(CEDALIBVER)
	@$(ECHO) SLLIBVER = $(SLLIBVER)
	@$(ECHO) OBJSUFFIX = $(OBJSUFFIX)
	@$(ECHO) ARSUFFIX = $(ARSUFFIX)
	@$(ECHO) SLSUFFIX = $(SLSUFFIX)
	@$(ECHO) EXESUFFIX = $(EXESUFFIX)
	@$(ECHO) LIBPREFIX = $(LIBPREFIX)
	@$(ECHO) LIBBASENAME = $(LIBBASENAME)
	@$(ECHO) LIBRARYTYPE = $(LIBRARYTYPE)
	@$(ECHO) HPEESOF_DIR = $(HPEESOF_DIR)
	@$(ECHO) HPEESOF_DEV_ROOT = $(HPEESOF_DEV_ROOT)
	@$(ECHO) HPEESOF_DEV_ROOT_UNIX = $(HPEESOF_DEV_ROOT_UNIX)
	@$(ECHO) RAW_CDROMDIR = $(RAW_CDROMDIR)
	@$(ECHO) CDROMROOT = $(CDROMROOT)
	@$(ECHO) RELEASECDPATH = $(RELEASECDPATH)
	@$(ECHO) WIN_INCLUDE_VAR = $(WIN_INCLUDE_VAR)
