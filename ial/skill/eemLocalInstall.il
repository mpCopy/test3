; Copyright Keysight Technologies 2008 - 2017  
(axlCmdRegister "eemADFILocalInstall" 'eemADFILocalInstall ?cmdType "interactive" )

(unless (boundp 'EEMINSTALLFORM)
(defvar EEMINSTALLFORM nil)
(defvar EEMMENUITEMSLIST nil)
(defvar EEMINITSTRINGS (list "<browse for valid ADS installation directory>"
                             "<browse for valid python executable>"))

(defun eemADFILocalInstall ()

  (let (form formFileName formDisplayed)
    
    (setq form EEMINSTALLFORM)
    (when (axlIsFormType form)
        (setq formDisplayed (axlFormDisplay form))
    ) ; when

    (unless formDisplayed
      ; Write tmp form file, create form, delete tmp form file
      (setq formFileName (eemWriteInstallForm))
      (setq form (axlFormCreate (gensym) formFileName '("msglines" 3 "n" "inner" ) 'eemLocalInstallCB t))
      (axlTempFileRemove formFileName)
  
      (unless form (error "Failed to create form file" ))
  
      (eemInstallFormInit form)
      (axlFormDisplay form)
      EEMINSTALLFORM = form

    ) ; unless

  ) ; let
) ; eemADFILocalInstall

(defun eemWriteInstallForm ()
  (let (formFileName fp cdsTool msg ialDir)
    (setq formFileName (axlTempFile))
    (setq fp (outfile formFileName "w"))
    
    (fprintf fp "FILE_TYPE=FORM_DEFN VERSION=2\n")
    (fprintf fp "FORM\n")
    (fprintf fp "FIXED\n")
    (fprintf fp "PORT 80 1\n")
    (fprintf fp "HEADER \"Keysight EEsof EDA, Allegro Design Flow Integration (Allegro DFI) Setup\"\n")
    (fprintf fp "DEFAULT \"ok\"\n")
    (fprintf fp "TILE\n")

    (fprintf fp "TEXT \"The Allegro DFI setup script will configure your local Allegro Platform environment ")
    (fprintf fp "in the directory: %s\" configtxtl\n" (axlGetVariable "localenv"))
    (fprintf fp "TLOC 2 1\n")
    (fprintf fp "FSIZE 78 4\n")
    (fprintf fp "ENDTEXT\n")

    (fprintf fp "GROUP \"Which Allegro Platform Tools do you want to configure?\" platfromgrpl\n")
    (fprintf fp "FLOC 2 4\n")
    (fprintf fp "FSIZE 78 13\n")
    (fprintf fp "ENDGROUP\n")

    (fprintf fp "FIELD generalcfg\n")
    (fprintf fp "FLOC 4 7\n")
    (fprintf fp "CHECKLIST \"Enable in Allegro PCB and all the Allegro based tools that use only allegro.ilinit files\"\n")
    (fprintf fp "ENDFIELD\n")

    (fprintf fp "TEXT \"Enable in Package Designer, SiP or other Allegro based tools when specific <tool>.ilinit files are active\" toolspectxtl\n")
    (fprintf fp "TLOC 4 10\n")
    (fprintf fp "ENDTEXT\n")

    (fprintf fp "FIELD apdcfg\n")
    (fprintf fp "FLOC 4 12\n")
    (fprintf fp "CHECKLIST \"Allegro Package Designer (apd)\"\n")
    (fprintf fp "ENDFIELD\n")

    (fprintf fp "FIELD cdnsipcfg\n")
    (fprintf fp "FLOC 34 12\n")
    (fprintf fp "CHECKLIST \"Cadence SiP (cdnsip)\"\n")
    (fprintf fp "ENDFIELD\n")

    (fprintf fp "FIELD othercfg\n")
    (fprintf fp "FLOC 4 14\n")
    (fprintf fp "CHECKLIST \"Other\"\n")
    (fprintf fp "ENDFIELD\n")

    (fprintf fp "FIELD otherstring\n")
    (fprintf fp "FLOC 12 14\n")
    (fprintf fp "STRFILLIN 28 1024\n")
    (fprintf fp "OPTIONS RIGHT\n")
    (fprintf fp "ENDFIELD\n")

    (fprintf fp "TEXT \"(comma separated list of Allegro SPB tool names)\" commatxtl\n")
    (fprintf fp "TLOC 42 14\n")
    (fprintf fp "ENDTEXT\n")

    (fprintf fp "GROUP \"How dow you want to use the Allegro DFI?\" installgrp\n")
    (fprintf fp "FLOC 2 17\n")
    (fprintf fp "FSIZE 78 19\n")
    (fprintf fp "ENDGROUP\n")

    (fprintf fp "FIELD usewithads\n")
    (fprintf fp "FLOC 4 19\n")
    (fprintf fp "CHECKLIST \"Integrated with Advanced Design System (ADS)\" adsorstanalone\n")
    (fprintf fp "ENDFIELD\n")

    (fprintf fp "FIELD useexternalpython\n")
    (fprintf fp "FLOC 45 19\n")
    (fprintf fp "CHECKLIST \"Standalone (no ADS available)\" adsorstanalone\n")
    (fprintf fp "ENDFIELD\n")
    
    (fprintf fp "TEXT \"Select directory path to Advanced Design System 2015.01 or later:\" adspathtxt\n")
    (fprintf fp "TLOC 4 21\n")
    (fprintf fp "ENDTEXT\n")

    (fprintf fp "FIELD hpeesofdir\n")
    (fprintf fp "FLOC 4 23\n")
    (fprintf fp "STRFILLIN 66 1000\n")
    (fprintf fp "ENDFIELD\n")

    (fprintf fp "FIELD browsehpeesofdir\n")
    (fprintf fp "FLOC 74 23\n")
    (fprintf fp "MENUBUTTON \"...\" 4 3\n")
    (fprintf fp "ENDFIELD\n")

    (fprintf fp "TEXT \"The Allegro DFI integration in Allegro is independent from Advanced Design System but needs Python scripting to operate correctly. ")
    (fprintf fp "In standalone configuration you need to select a Python installation to work with.\" explaininstall\n")
    (fprintf fp "TLOC 4 26\n")
    (fprintf fp "FSIZE 74 5\n")
    (fprintf fp "ENDTEXT\n")

    (fprintf fp "TEXT \"Select file path to a Python executable (preferred version 2.7.x):\" pythonpathtxt\n")
    (fprintf fp "TLOC 4 30\n")
    (fprintf fp "ENDTEXT\n")

    (fprintf fp "FIELD pythonexe\n")
    (fprintf fp "FLOC 4 32\n")
    (fprintf fp "STRFILLIN 66 1000\n")
    (fprintf fp "ENDFIELD\n")

    (fprintf fp "FIELD browsepython\n")
    (fprintf fp "FLOC 74 32\n")
    (fprintf fp "MENUBUTTON \"...\" 4 3\n")
    (fprintf fp "ENDFIELD\n")

    (fprintf fp "GROUP \"Select your Allegro DFI menu load setting?\" interfacegrp\n")
    (fprintf fp "FLOC 2 36\n")
    (fprintf fp "FSIZE 78 15\n")
    (fprintf fp "ENDGROUP\n")

    (fprintf fp "FIELD enableautoload\n")
    (fprintf fp "FLOC 4 38\n")
    (fprintf fp "CHECKLIST \"Enable automatic load of the Allegro DFI menu\n")
    (fprintf fp "ENDFIELD\n")

    (when (lessp (axlVersion 'version) 17.0)
      (fprintf fp "POPUP <before_after_Pop> \"before\" \"before\",\"after\" \"after\".\n")
      
      (fprintf fp "FIELD defaultitemloc\n")
      (fprintf fp "FLOC 8 40\n")
      (fprintf fp "CHECKLIST \"Use default location before <Help>\" itemlocation\n")
      (fprintf fp "ENDTEXT\n")
      
      (fprintf fp "FIELD beforeorafter\n")
      (fprintf fp "FLOC 44 42\n")
      (fprintf fp "ENUMSET 6\n")
      (fprintf fp "POP \"before_after_Pop\"\n")
      (fprintf fp "ENDFIELD\n")
      
      (fprintf fp "FIELD selitemloc\n")
      (fprintf fp "FLOC 8 42\n")
      (fprintf fp "CHECKLIST \"Select a specific position in the menu structure\" itemlocation\n")
      (fprintf fp "ENDTEXT\n")
      
      (fprintf fp "TEXT \"item:\" theitem\n")
      (fprintf fp "FLOC 53 42 \n")
      (fprintf fp "ENDFIELD\n")
      
      (fprintf fp "FIELD menuitems\n")
      (fprintf fp "FLOC 58 39 \n")
      (fprintf fp "LIST \"\" 20 4\n")
      (fprintf fp "OPTIONS singleselect\n")
      (fprintf fp "ENDFIELD\n")
    )
   
    (fprintf fp "FIELD addadsstart\n")
    (fprintf fp "FLOC 8 46\n")
    (fprintf fp "CHECKLIST \"Add menu item to start Advanced Design System\n")
    (fprintf fp "ENDFIELD\n")

    (setq cdsTool (axlVersion 'displayName))
    (setq ialDir (eemSimplifyFilename (strcat (getWorkingDir) "/../")))
    (setq msg (strcat "You don't want to use automatic load of the Allegro DFI menu items."
                      "Please make sure the ADFI menu fragment is added "
                      "to the appropriate menu file for " cdsTool ". "
                      "The menu files are different for each Allegro based tool and release. "
                      "Check the Cadence Help for more information. " 
                      "For a manual configuration of the ADFI menu "
                      "see the configuration procedure described in the file: "
                      ialDir "/INSTALL or the Allegro DFI manual."))

    (fprintf fp "TEXT \"%s\" autoloaddisabledtxt\n" msg)
    (fprintf fp "TLOC 8 40\n")
    (fprintf fp "FSIZE 70 8\n")
    (fprintf fp "ENDFIELD\n")

    (fprintf fp "FIELD agileesofdtxt\n")
    (fprintf fp "FLOC 8 48\n")
    (fprintf fp "CHECKLIST \"Specify ADS_LICENSE_FILE (needed to start ADS):\"\n")
    (fprintf fp "ENDTEXT\n")

    (fprintf fp "FIELD agileesofdstring\n")
    (fprintf fp "FLOC 53 48\n")
    (fprintf fp "STRFILLIN 24 1000\n")
    (fprintf fp "ENDFIELD\n")

    (fprintf fp "FIELD ok\n")
    (fprintf fp "FLOC 57 52\n")
    (fprintf fp "MENUBUTTON \"Setup\" 10 3\n")
    (fprintf fp "ENDFIELD\n")

    (fprintf fp "FIELD cancel\n")
    (fprintf fp "FLOC 69 52\n")
    (fprintf fp "MENUBUTTON \"Cancel\" 10 3\n")
    (fprintf fp "ENDFIELD\n")

    (fprintf fp "FLEXMODE edgegravity\n")
    (fprintf fp "FLEX configtxtl 0 0 1 1\n")
    (fprintf fp "FLEX platfromgrpl 0 0 1 0\n")
    (fprintf fp "FLEX generalcfg 0 0 0 0\n")
    (fprintf fp "FLEX toolspectxtl 0 0 0 0\n")
    (fprintf fp "FLEX allegrocfg 0 0 0 0\n")
    (fprintf fp "FLEX apdcfg 0 0 0 0\n")
    (fprintf fp "FLEX cdnsipcfg 0 0 0 0\n")
    (fprintf fp "FLEX otherscfg 0 0 0 0\n")
    (fprintf fp "FLEX otherstring 0 0 1 1\n")
    (fprintf fp "FLEX commatxtl 1 0 0 0\n")
    (fprintf fp "FLEX interfacegrp 0 0 1 0\n")
    (fprintf fp "FLEX installgrp 0 0 1 0\n")
    (when (lessp (axlVersion 'version) 17.0)
      (fprintf fp "FLEX beforeorafter 0 0 0 0\n")
      (fprintf fp "FLEX selitemtxt 0 0 0 0\n")
      (fprintf fp "FLEX theitem 0 0 0 0\n")
      (fprintf fp "FLEX menuitems 0 0 1 1\n")
    )
    (fprintf fp "FLEX autoloaddisabledtxt 0 0 1 1\n")
    (fprintf fp "FLEX agileesofdstring 0 0 1 1\n")

    (fprintf fp "FLEX usewithads 0 0 0 0\n")
    (fprintf fp "FLEX useexternalpython 0 0 0 0\n")
    (fprintf fp "FLEX hpeesofdir 0 0 1 1\n")
    (fprintf fp "FLEX pythonexe 0 0 1 1\n")
    (fprintf fp "FLEX browsehpeesofdir 1 0 0 0\n")
    (fprintf fp "FLEX browsepython 1 0 0 0\n")

    (fprintf fp "FLEX ok 1 0 0 0\n")
    (fprintf fp "FLEX cancel 1 0 0 0\n")

    (fprintf fp "ENDTILE\n")
    (fprintf fp "ENDFORM\n")

    (close fp)
    formFileName
  ) ; let
) ; eemWriteFullSetupForm


(defun eemLocalInstallCB (form)
  (case form->curField
    ("generalcfg"
;     (fprintf poport "general cfg touched\n")
    )
    ("apdcfg"
;     (fprintf poport "apd cfg touched\n")
    )
    ("cdnsipcfg"
;     (fprintf poport "cdnsip cfg touched\n")
    )
    ("othercfg"
;     (fprintf poport "other cfg touched\n")
     (axlFormSetFieldEditable form "otherstring" (axlFormGetField form "othercfg"))
    )
    ("otherstring"
;     (fprintf poport "otherstring cfg touched\n")
    )
    (("usewithads" "useexternalpython")
;     (fprintf poport "usewithads touched\n")
     (if (axlFormGetField form "usewithads")
      then
       (eemInstallInsideADSGroupInit form)
      else
       (eemInstallStandalone form)
     )
    )
    ("hpeesofdir"
;     (fprintf poport "hpeesofdir touched\n")
    )
    ("browsehpeesofdir"
     (fprintf poport "browsehpeesofdir touched\n")
     (let (eesofDir (hpeesofInitStr (car EEMINITSTRINGS)))
       (prog (tmpDir)
         (while t
           (setq eesofDir (eemInstallGetKnownEesofDir form hpeesofInitStr))
           (setq tmpDir (axlDMDirectoryBrowse eesofDir nil ?title "Please select valid HPEESOF_DIR directory (Preferably ADS2008 Update2 or later)"))
           (unless tmpDir
             ;just exit loop if returned without dir and return to old setting
             (setq eesofDir (eemInstallGetKnownEesofDir form hpeesofInitStr))
             (return)
           )
           (when (eemIsValidEesofDir tmpDir)
             (setq eesofDir (eemIsValidEesofDir tmpDir))
             (return)
           )
         )
       )
       (eemInstallSetEesofDir form eesofDir hpeesofInitStr)
     )
    )
    ("pythonexe"
;     (fprintf poport "pythonexe touched\n")
    )
    ("browsepython"
;     (fprintf poport "browsepython touched\n")
     (let (pyExe (pyExeInitStr (cadr EEMINITSTRINGS)))
       (prog (tempPy)
         (setq pyExe (or (eemInstallGetKnownPyExe form pyExeInitStr) ""))
         (while t
           (setq tempPy (axlDMFileBrowse nil nil
                                        ?defaultName pyExe
                                        ?directorySet nil
                                        ?noDirectoryButton t
                                        ?title "Browse for a valid Python 2.5 or 2.6 executable"
                                        ?optFilters "Python (*.exe)|*.exe|"))
           (unless tempPy
             ;just exit loop if returned without dir and return to old setting
             (setq pyExe (eemWhichExe "python"))
             (return)
           )
           (when (and (isFile tempPy)
                      (isExecutable tempPy))
             (setq pyExe tempPy)
             (return)
           )
         )
       )
       (eemInstallSetPyExe form pyExe pyExeInitStr)
     )
    )
    ("enableautoload"
;     (fprintf poport "enableautoload touched\n")
     (if (axlFormGetField form "enableautoload")
      then
         (axlFormSetFieldVisible form "autoloaddisabledtxt" 0)  
       (when (lessp (axlVersion 'version) 17.0)
         (axlFormSetFieldVisible form "selitemloc" 1)  
         (axlFormSetFieldVisible form "defaultitemloc" 1)  
         (axlFormSetFieldVisible form "beforeorafter" 1)  
         (axlFormSetFieldVisible form "menuitems" 1)  
         (axlFormSetFieldVisible form "theitem" 1)  
       )
       (axlFormSetFieldVisible form "addadsstart" 1)  
       (axlFormSetFieldVisible form "agileesofdtxt" 1)  
       (axlFormSetFieldVisible form "agileesofdstring" 1)  
      else
       (axlFormSetFieldVisible form "autoloaddisabledtxt" 1)  
       (when (lessp (axlVersion 'version) 17.0)
         (axlFormSetFieldVisible form "selitemloc" 0)  
         (axlFormSetFieldVisible form "defaultitemloc" 0)  
         (axlFormSetFieldVisible form "beforeorafter" 0)  
         (axlFormSetFieldVisible form "menuitems" 0)  
         (axlFormSetFieldVisible form "theitem" 0)  
       )
       (axlFormSetFieldVisible form "addadsstart" 0)  
       (axlFormSetFieldVisible form "agileesofdtxt" 0)  
       (axlFormSetFieldVisible form "agileesofdstring" 0)         
     )
    )
    ("beforeorafter"
;     (fprintf poport "beforeorafter touched\n")
    )
    ("defaultitemloc"
;     (fprintf poport "selitemloc touched\n")
     (axlFormSetField form "beforeorafter" "before")
     (axlFormSetFieldEditable form "beforeorafter" nil)
     (axlFormSetField form "menuitems" (mapcar 'car EEMMENUITEMSLIST))
     (axlFormListSelect form "menuitems" "Help")
     (axlFormSetFieldEditable form "menuitems" nil)
    )
    ("selitemloc"
;     (fprintf poport "selitemloc touched\n")
     (axlFormSetFieldEditable form "beforeorafter" t)
     (axlFormSetField form "menuitems" (mapcar 'car EEMMENUITEMSLIST))
     (axlFormListSelect form "menuitems" "Help")
     (axlFormSetFieldEditable form "menuitems" t)
    )
    ("menuitems"
;     (fprintf poport "menuitems touched\n")
    )
    ("addadsstart"
;     (fprintf poport "addadsstart touched\n")
     (if (axlFormGetField form "addadsstart")
      then
       (axlFormSetFieldEditable form "agileesofdtxt" t)
       (axlFormSetFieldEditable form "agileesofdstring" t)
      else
       (axlFormSetFieldEditable form "agileesofdtxt" nil)
       (axlFormSetFieldEditable form "agileesofdstring" nil)
     )
    )
    ("agileesofdtxt"
;     (fprintf poport "agileesofdtxt touched\n")
     (if (axlFormGetField form "agileesofdtxt")
      then
       (axlFormSetFieldEditable form "agileesofdstring" t)
      else
       (axlFormSetFieldEditable form "agileesofdstring" nil)
     )
    )
    ("agileesofdstring"
;     (fprintf poport "agileesofdstring touched\n")
    )
    ("ok" 
;     (fprintf poport "ok touched\n")
     (cond 
      ((and (axlFormGetField form "addadsstart")
            ((or (axlFormGetField form "agileesofdstring") "") == ""))
       (let (msg)
         (setq msg (strcat "Please define the ADS_LICENSE_FILE value if you enable\n"
                           "\"Start Advanced Design System\" in the DFI menu.\n"))
         (fprintf poport msg)
         (axlUIConfirm msg)
       )
      )
      ((or (axlFormGetField form "generalcfg")
           (axlFormGetField form "apdcfg")
           (axlFormGetField form "cdncfg")
           (and (axlFormGetField form "othercfg")
                (nequal (axlFormGetField form "otherstring") "")))
       (eemInstallWriteADFISetup form)
       (eemInstallCleanAllegroIlinit)
       (eemInstallAddToIlinitFiles form)
       (eemInstallFormCancel form)
       (eemInstallFinishADFIinstall)
      )
      (t
       (let (msg)
         (setq msg "You must at least configure one Allegro based\ntool otherwise please press the Cancel button.")
         (fprintf poport msg)
         (axlUIConfirm msg)
       )
      )
     )
    )
    ("cancel"
     (println "Configuration script cancelled: no files changed.")
     (eemInstallFormCancel form)
    )
  )
  (when (equal form->doneState 3)
    (println "Configuration script cancelled: no files changed.")
    (eemInstallFormCancel form)
  )
)

(defun eemInstallFormCancel (form)
  (axlFormClose form)
  (setq EEMINSTALLFORM nil)
  (setq EEMMENUITEMSLIST nil)
)

(defun eemInstallFormInit (form)
  (eemInstallToolsGroupInit form)
  (eemInstallInsideADSGroupInit form)
  (eemInstallAddMenu form)
)


(defun eemInstallToolsGroupInit (form)
  (let (ilinitList ilinitName otherList) 
    (axlFormSetField form "generalcfg" t)
    (axlFormSetField form "apdcfg" nil)
    (axlFormSetField form "cdnsipcfg" nil)
    (axlFormSetField form "othercfg" nil)
    (axlFormSetFieldEditable form "otherstring" nil)
    (setq ilinitList (eemInstallGetPathFiles (reverse (getSkillPath)) ?extension "ilinit"))
    (foreach ilinit ilinitList
      (setq ilinitName (nth 2 ilinit))
      (case ilinitName
       (("example" "allegro")
        t
       )
       (("apd" "cdnsip")
        (axlFormSetField form (strcat ilinitName "cfg") t)
       )
       (t
        (unless (member ilinitName otherList)
          (setq otherList (cons ilinitName otherList))
        )
       )
      )
    )
    (when (pairp otherList)
      (axlFormSetField form "othercfg" t)
      (axlFormSetFieldEditable form "otherstring" t)
      (axlFormSetField form "otherstring" (buildString otherList ","))
    )
  )
)

(defun eemInstallKnownEesofDir ()
  (let (eesofDir ialDir)
    (setq ialDir (eemSimplifyFilename (strcat (getWorkingDir) "/../")))
    (setq eesofDir (or (eemIsValidEesofDir (strcat ialDir "/../"))
                       (eemIsValidEesofDir (getShellEnvVar "HPEESOF_DIR"))
                       ""))
    eesofDir
  )
)

(defun eemInstallGetKnownEesofDir (form hpeesofInitStr)
  (let (eesofDir)
    (setq eesofDir (axlFormGetField form "hpeesofdir"))
    (when (or (equal eesofDir "")
              (equal hpeesofInitStr eesofDir))
      (setq eesofDir (eemInstallKnownEesofDir))
    )
    eesofDir
  )
)

(defun eemInstallSetEesofDir (form eesofDir hpeesofInitStr)
  (if (and (stringp eesofDir)
           (greaterp (strlen eesofDir) 0))
   then
    (axlFormSetField form "hpeesofdir" eesofDir)
   else
    (axlFormSetField form "hpeesofdir" hpeesofInitStr)
  )
)

(defun eemInstallInsideADSGroupInit (form)
  (let (eesofDir (hpeesofInitStr (car EEMINITSTRINGS)))
    (axlFormSetField form "usewithads" t)
    (axlFormSetFieldEditable form "hpeesofdir" t)
    (axlFormSetFieldEditable form "browsehpeesofdir" t)
    (axlFormSetFieldVisible form "adspathtxt" 1)
    (axlFormSetFieldVisible form "hpeesofdir" 1)
    (axlFormSetFieldVisible form "browsehpeesofdir" 1)
    (setq eesofDir (eemInstallGetKnownEesofDir form hpeesofInitStr))
    (eemInstallSetEesofDir form eesofDir hpeesofInitStr)

    (axlFormSetField form "useexternalpython" nil)
    (axlFormSetFieldEditable form "pythonexe" nil)
    (axlFormSetFieldVisible form "explaininstall" 0)
    (axlFormSetFieldVisible form "pythonpathtxt" 0)
    (axlFormSetFieldVisible form "pythonexe" 0)
    (axlFormSetFieldVisible form "browsepython" 0)

    (axlFormSetFieldEditable form "addadsstart" t)
    (axlFormSetField form "addadsstart" t)
    (axlFormSetFieldEditable form "agileesofdtxt" t)
    (axlFormSetFieldEditable form "agileesofdstring" t)
  )
)


(defun eemInstallGetKnownPyExe (form pyExeInitStr)
  (let (pyExe)
    (setq pyExe (axlFormGetField form "pythonexe"))
    (when (or (equal pyExe "")
              (equal pyExeInitStr pyExe))
      (setq pyExe (eemWhichExe "python"))
    )
    pyExe
  )
)


(defun eemInstallSetPyExe (form pyExe pyExeInitStr)
  (if (and (stringp pyExe)
           (greaterp (strlen pyExe) 0))
   then
    (axlFormSetField form "pythonexe" pyExe)
   else
    (axlFormSetField form "pythonexe" pyExeInitStr)
  )
)

(defun eemInstallStandalone (form)
  (let (pyExe
        (pyExeInitStr (cadr EEMINITSTRINGS)))
    (axlFormSetFieldEditable form "hpeesofdir" nil)
    (axlFormSetFieldEditable form "browsehpeesofdir" nil)
    (axlFormSetField form "useexternalpython" t)
    (axlFormSetFieldVisible form "explaininstall" 1)
    (axlFormSetFieldVisible form "pythonpathtxt" 1)
    (axlFormSetFieldVisible form "pythonexe" 1)
    (axlFormSetFieldEditable form "pythonexe" t)
    (axlFormSetFieldVisible form "browsepython" 1)
    (setq pyExe (eemInstallGetKnownPyExe form pyExeInitStr))
    (eemInstallSetPyExe form pyExe pyExeInitStr)
    (axlFormSetField form "addadsstart" nil)
    (axlFormSetFieldEditable form "addadsstart" nil)
    (axlFormSetField form "agileesofdtxt" nil)
    (axlFormSetFieldEditable form "agileesofdtxt" nil)
    (axlFormSetFieldEditable form "agileesofdstring" nil)
  )
)


(defun eemInstallAddMenu (form)
  (let (agileesofdLicFile menuLevel)
    (axlFormSetField form "enableautoload" t)
    (axlFormSetField form "defaultitemloc" t)
    (axlFormSetField form "beforeorafter" "before")
    (axlFormSetFieldEditable form "beforeorafter" nil)
    (setq menuLevel (atoi (or (axlGetVariable "eem_setup_menu_levels") "2")))
    (setq EEMMENUITEMSLIST (eemInstallCreateMenuItems ?level menuLevel))
    (axlFormSetField form "menuitems" (mapcar 'car EEMMENUITEMSLIST))
    (axlFormListSelect form "menuitems" "Help")
    (axlFormSetFieldEditable form "menuitems" nil)
    
    (axlFormSetField form "addadsstart" t)
    (axlFormSetFieldVisible form "addadsstart" 1) 
    (axlFormSetFieldVisible form "agileesofdtxt" 1)  
    (axlFormSetFieldVisible form "agileesofdstring" 1)
    (axlFormSetFieldEditable form "agileesofdtxt" t)
    (axlFormSetFieldEditable form "agileesofdstring" t)
    (setq agileesofdLicFile (or (axlGetVariable "agileesofd_license_file") ""))
    (axlFormSetField form "agileesofdstring" agileesofdLicFile)
    (if ((or agileesofdLicFile "") == "")
     then
      (axlFormSetField form "agileesofdtxt" t)
      (axlFormSetFieldEditable form "agileesofdstring" t)
     else
      (axlFormSetField form "agileesofdtxt" nil)
      (axlFormSetFieldEditable form "agileesofdstring" nil)
    )
    (axlFormSetFieldVisible form "autoloaddisabledtxt" 0)  
  )
)




(defun eemInstallCreateMenuItems (@key (level 3))
  (prog (menuFilename menuItems defaultItems)
    (setq defaultItems  (list '("File" "&File")
                              '("Edit" "&Edit")
                              '("View" "&View") 
                              '("Add" "&Add")
                              '("Display" "&Display")
                              '("Setup" "Set&up")
                              '("Shape" "&Shape")
                              '("Logic" "&Logic")
                              '("Place" "&Place")
                              '("Route" "&Route")
                              '("Analyze" "Analy&ze")
                              '("Manufacture" "&Manufacture")
                              '("Tools" "&Tools")
                              '("Help" "&Help")))

    (setq menuFilename (axlOSSlash (axlTempFile)))
    (unless (axlUIMenuDump menuFilename)
      (fprintf poport "Can not create menu file: %L\n" menuFilename)
      (return defaultItems)
    )
    (let (mfp line lineL levelString item sItem (iCount -1))
      (if (setq mfp (axlDMOpenFile "TEMP" menuFilename "r"))
       then
        (while (gets line mfp)
;          (fprintf poport line)
          (cond
           ((rexMatchp "^[ ]*BEGIN[ ]*" line)
            (postincrement iCount)
           )
           ((rexMatchp "^[ ]*END[ ]*" line)
            (postdecrement iCount)
           )
           ((and line 
                 (stringp line)
                 (lessp iCount level)
                 (or (rexMatchp "^[ ]*MENUITEM.*" line)
                     (rexMatchp "^[ ]*POPUP.*" line)))
            (setq lineL (parseString line "\""))
            (when (and (pairp lineL)
                       (geqp (length lineL) 2))
              (setq item (nth 1 lineL))
              (setq sItem (buildString (parseString item "&") ""))
              (setq levelString substring("____________________" 1 (min 2*iCount 9)))
              (setq sItem (strcat levelString sItem))
              (setq menuItems (cons (list sItem item) menuItems))
            )
           )
          )
        )
        (axlDMClose mfp)
        (axlTempFileRemove menuFilename)
        (return (reverse menuItems))
       else
        (fprintf poport "Can not parse menu file: %L\n" menuFilename)
        (return defaultItems)
      )
    )
  )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;return fileparts of all files in path list
(defun eemInstallGetPathFiles (pathList @key (base nil) 
                                             (extension nil) 
                                             (regexext nil) 
                                             (caseSensitive nil))
  (let (dirList fileList)
    (if (pairp pathList)
     then
      (setq dirList pathList)
     else
      (setq dirList (ncons (or pathList ".")))
    )
    (setq fileList (mapcan (lambda (dir)
                             (let (fullName fileParts filePartsList dFiles)
                               (when (isDir dir)
                                 (setq dFiles (getDirFiles dir))
                                 (foreach file dFiles
                                   (setq fullName (eemSimplifyFilename (strcat dir "/" file)))
                                   (when (isFile fullName)
                                     (setq fileParts (axlDMFileParts fullName))
                                     (setq fileParts (cons fullName fileParts))
                                     (setq filePartsList (cons fileParts filePartsList))
                                   )
                                 )
                                 filePartsList
                               )
                             )
                           )
                           dirList))
    (when (and base (or (stringp base) (symbolp base)))
      (setq fileList (setof x fileList (eemTwoStringsAreEquivalent base 
                                                                   (nth 2 x)
                                                                   ?caseSensitive caseSensitive)))
    )
    (when (and extension (or (stringp extension) (symbolp extension)))
      (setq fileList (setof x fileList (eemTwoStringsAreEquivalent extension 
                                                                   (car (last x)) 
                                                                   ?caseSensitive caseSensitive)))
    )
    (when (and regexext (or (stringp regexext) (symbolp regexext)))
      (setq fileList (setof x fileList (rexMatchp regexext (or (car (last x)) ""))))
    )
    fileList
  )
)


(defun eemFileRotate (filePath @key (revs (atoi (axlGetVariable "ads_textrevs"))))
  (let (sFilePath parts path base extension filePartsList
        fileList highext hrev nrev destFile orgFile)
    (setq sFilePath (eemSimplifyFilename filePath))
    (setq parts (axlDMFileParts sFilePath))
;    (fprintf poport "fileparts %L\n" parts)
    (setq path (nth 0 parts))
    (setq base (nth 1 parts))
    (setq extension (nth 3 parts))
   
    (setq filePartsList (eemInstallGetPathFiles path
                                                ?base base 
                                                ?regexext (strcat extension "[,0-9]+$")))
    (setq filePartsList (sortcar filePartsList 'axlStrcmpAlpNum))
    (setq filePartsList (reverse filePartsList))
    (setq highext (car (last (car filePartsList))))
    (setq fileList (mapcar 'car filePartsList))
    (when (and highext
               (stringp highext))
      (setq hrev (car (last (parseString highext ","))))
      (when (and hrev
                 (stringp hrev))
        (setq nrev (add1 (atoi hrev)))
        (setq destFile (sprintf nil "%s,%d" sFilePath nrev))
        (while fileList
          (setq orgFile (car fileList))
          (when (and (lessp nrev revs)
                     (isFile orgFile))
            ;(fprintf poport "mv %L %L\n" orgFile destFile)
            (unless (axlOSFileMove orgFile destFile)
              (fprintf poport "file move to rev failed")
            )
          )
          (setq nrev (sub1 nrev))
          (setq destFile orgFile)
          (setq fileList (cdr fileList))
        )
      )
    )
    (setq destFile (strcat sFilePath ",1"))
    (if (axlOSFileCopy sFilePath destFile nil)
     then
      destFile
     else
      (fprintf poport "rev1 file move failed")
      nil
    )
  )
)

(defun eemIsValidEesofDir (iDir)
  (prog (tDir nDir)
    (setq tDir (axlOSSlash (simplifyFilename (or iDir ""))))
    (setq nDir (car (axlDMFileParts tDir)))
    (while (nequal nDir tDir)
      (when (and tDir 
                 (isDir tDir)
                 (isDir (strcat tDir "/de"))
                 (isDir (strcat tDir "/dss"))
                 (isDir (strcat tDir "/dds"))
                 (or (isDir (strcat tDir "/momentum"))
                     (isDir (strcat tDir "/em"))
                 )
                 (isDir (strcat tDir "/pvm3"))
                 (isDir (strcat tDir "/tools")))
        (return tDir)
      )
      (setq tDir nDir)
      (unless tDir
        (return)
      )
      (setq nDir (car (axlDMFileParts tDir)))
    )
    (return)
  )
)


(defun eemWhichExe (executable)
  (prog (execEnvVar execList execP)
    (if (stringp executable)
     then
      (setq execEnvVar (strcat "EEMOM_" (upperCase executable)))
     else
      (return)
    )
    (setq execP (axlGetVariable execEnvVar))
    (setq execList (mapcan (lambda (x)
                             (ncons (eemSimplifyFilename (strcat x "/" executable)))
                           ) 
                           (parseString (axlGetVariable "path"))))
    (setq execList (cons execP execList))
    (foreach execPath execList
      (when (and execPath 
                 (stringp execPath))
        (setq execPath (axlOSSlash execPath))
        (when (and (eemIsFile execPath)
                   (isExecutable execPath))
;        (fprintf poport "first try:%L\n" execPath)
          (return execPath)
        )
        (setq execPath (strcat execPath ".exe"))
        (when (and (eemIsFile execPath)
                   (isExecutable execPath))
;        (fprintf poport "second try %L\n" execPath)
          (return execPath)
        )
      )
    )
    (return)
  )
)

(defun eemInstallCleanAllegroIlinit (@key (local (axlGetVariable "localenv")))
  (prog (allegroFile backupFile afp bfp storeLine line inBlock)
    (setq allegroFile (strcat local "/allegro.ilinit"))

    (when (isFileEncrypted allegroFile)
      (return t)
    )

    (if (isFile allegroFile)
     then
      (setq backupFile (eemFileRotate allegroFile))
      (unless backupFile
        (return)
      )
     else
      (return t)
    )

    (unless (setq afp (axlDMOpenFile "TEMP" allegroFile "w"))
      (fprintf poport "Can't open allegro.ilinit for writing.\n")
      (return)
    )
    (when (and  backupFile 
                (isFile backupFile))
      (if (setq bfp (axlDMOpenFile "TEMP" backupFile "r"))
       then
        (setq inBlock "0")
        (while (gets line bfp)
;          (fprintf poport line)
          (cond
           ((rexMatchp "^;; --- BEGIN ADFI.*" line)
            (setq inBlock "2")
           )
           ((rexMatchp "^;; --- END ADFI.*" line)
            (setq inBlock "3")
           )
           ((index (or line "") ";; ----------------------------------------------------" )
            (case inBlock
             ("0"
              (setq inBlock "1")
              (setq storeLine line)
             )
             ("1"
              (fprintf afp "%s" (or storeLine ""))
              (setq storeLine line)
             )
             ("2"
              (setq storeLine nil)
              t
             )
             ("3"
              (setq storeLine nil)
              (setq line nil)
              (setq inBlock "0")
             )
            )
           )
           (t
            (when (equal inBlock "1")
              (fprintf afp "%s" (or storeLine ""))
              (setq inBlock "0")
            )
            (when (equal inBlock "3")
              (setq inBlock "0")              
            )
           )
          )
          (when (and (equal inBlock "0") 
                     (stringp line))
            (fprintf afp "%s" (or line ""))
          )
        )
        (axlDMClose bfp)
        (axlDMClose afp)
       else
        (fprintf poport "Can't read allegro.ilinit backup file.\n")
        (return)
      )
    )
    (return t)
  )
)


(defun eemInstallWriteADFISetup (form @key (local (axlGetVariable "localenv")))
  (prog (fp initFile)
    (setq initFile "eemAdfiSetup.il")
    (setq initFile (eemSimplifyFilename (strcat local "/" initFile)))
    (when (isFile initFile)
      (unless (eemFileRotate initFile)
        (fprintf poport "Can not save previous initFile file\n")
        (return)
      )
    )
    (if (setq fp (axlDMOpenFile "TEMP" initFile "w"))
     then
      (let (ialDir skillDir skillInitFile eesofDir pyExe)
        (setq ialDir (eemSimplifyFilename (strcat (getWorkingDir) "/../")))
        (if (lessp (axlVersion 'version) 17.0)
         then
          (setq skillDir (strcat ialDir "/skill/15.7"))
         else
          (setq skillDir (strcat ialDir "/skill/17.0"))
        )
        (setq skillInitFile (strcat skillDir "/eemom.ini"))
        (setq eesofDir (or (eemInstallGetKnownEesofDir form (car EEMINITSTRINGS)) ""))
        (setq pyExe (or (eemInstallGetKnownPyExe form (cadr EEMINITSTRINGS)) ""))
        

        (fprintf fp ";; ----------------------------------------------------\n")
        (fprintf fp ";; --- BEGIN ADFI Keysight EEsof EDA ADFI config\n")
        (fprintf fp ";; --- Modified: %s\n" getCurrentTime())
        (fprintf fp (strcat ";; Place or remove or comment character (;) in front\n"
                            ";; and modify values if you want to change the ADS Allegro DFI load behavior.\n\n"))

        (if (axlFormGetField form "enableautoload")
         then
          (if (lessp (axlVersion 'version) 17.0)
           then
             (fprintf fp ";(setShellEnvVar \"EEMOM_MENU_AUTOLOAD=OFF|ON\") ; disable/enable automatic menu load\n")
           else
             (fprintf fp strcat("(setShellEnvVar \"EEMOM_MENU_AUTOLOAD=OFF\")\n"
                                "; disable automatic menu load inside eemom.cxt context for version 17 and later\n"
                                "; use an externally defined menu trigger instead that places ADFI menu just before Help\n"))
          )
          (if (or (axlFormGetField form "defaultitemloc") 
                  (geqp (axlVersion 'version) 17.0))
           then
            (fprintf fp ";(axlSetVariable \"Eem_Menu_ItemPosition\" \"&Help\")\n")
            (fprintf fp ";(axlSetVariable \"Eem_Menu_AfterItem\" nil)\n")
            (unless (axlFormGetField form "addadsstart")
              (fprintf fp ";")
            )
            (fprintf fp "(axlSetVariable \"Eem_Menu_HasStartAds\" 1)\n")
           else
            (let (item)
              (setq item (or (cadr (assoc (axlFormGetField form "menuitems") EEMMENUITEMSLIST))
                               "&Help"))
              (fprintf fp "(axlSetVariable \"Eem_Menu_ItemPosition\" \"%s\")\n" item)
              (when (equal (axlFormGetField form "beforeorafter") "before")
                (fprintf fp ";")
              )             
              (fprintf fp "(axlSetVariable \"Eem_Menu_AfterItem\" 1)\n")
              (unless (axlFormGetField form "addadsstart")
                (fprintf fp ";")
              )
              (fprintf fp "(axlSetVariable \"Eem_Menu_HasStartAds\" 1)\n\n")
            )
          )
         else
          (fprintf fp "(setShellEnvVar \"EEMOM_MENU_AUTOLOAD=OFF\")\n")
          (fprintf fp ";(axlSetVariable \"Eem_Menu_ItemPosition\" \"&Help\")\n")
          (fprintf fp ";(axlSetVariable \"Eem_Menu_AfterItem\" 1)\n")
          (fprintf fp ";(axlSetVariable \"Eem_Menu_HasStartAds\" 1)\n\n")
        )
 
        (fprintf fp "(axlSetVariable \"Eem_Use_Ebond\" 2)\n\n")

        (fprintf fp ";; !!!Always use / as directory delimiter!!!\n\n")
        (unless (axlFormGetField form "usewithads")
          (fprintf fp ";")
        )
        (fprintf fp "(setShellEnvVar \"HPEESOF_DIR=%s\")\n\n" eesofDir)

        (fprintf fp "; Enable if license settings not found.\n")
        (fprintf fp "; Note that additional preference settings for licensing can be required.\n")
        (unless (and (axlFormGetField form "usewithads")
                     (axlFormGetField form "addadsstart")
                     (axlFormGetField form "agileesofdtxt"))
          (fprintf fp ";")
        )
        (fprintf fp ";(setShellEnvVar \"AGILEESOFD_LICENSE_FILE=%s\")\n" 
                 (axlOSSlash (or (axlFormGetField form "agileesofdstring") "")))
        (fprintf fp "(setShellEnvVar \"ADS_LICENSE_FILE=%s\")\n\n" 
                 (axlOSSlash (or (axlFormGetField form "agileesofdstring") "")))
        
        (unless (axlFormGetField form "useexternalpython")
          (fprintf fp ";")
        )
        (fprintf fp "(setShellEnvVar \"EEMOM_PYTHON=%s\")\n\n" pyExe)

        (fprintf fp ";; Define the EEMOM_SKILL_DIR only in local configurations\n")
        (fprintf fp ";; to keep the overloading capabilities for personal setups available.\n")
        (let (useDefaultSkillDir)
          (setq useDefaultSkillDir (equal (eemSimplifyFilename (strcat eesofDir "/")) 
                                          (eemSimplifyFilename (strcat ialDir "/../"))))
;        (fprintf poport "defaultSkillDir %L=%L %L\n" (eemSimplifyFilename (strcat eesofDir "/")) (eemSimplifyFilename (strcat ialDir "/../")) useDefaultSkillDir)
          (when (and useDefaultSkillDir 
                     (axlFormGetField form "usewithads"))
            (fprintf fp ";")
          )
        )
        (fprintf fp "(setShellEnvVar \"EEMOM_SKILL_DIR=%s\")\n\n" skillDir)

        (fprintf fp "(load \"%s\")\n\n" (axlOSSlash skillInitFile))

        (fprintf fp "(let (msgcontext (eemEnableMenuAutoLoadFor17 %s))\n"
                 (if (and (geqp (axlVersion 'version) 17.0) 
                          (axlFormGetField form "enableautoload"))
                     "t"
                     "nil"))
        (fprintf fp "  (defun eemAllegroMenuTriggerExternal (t_menu)\n")
        (fprintf fp "    (let (q)\n")
        (fprintf fp "      (unless (axlUIMenuFind nil \"MomSaveState\")\n")
        (fprintf fp "        (setq eemAllegroMenuList (list (list 'popup \"Export To ADS/EMPro\")\n")
        (fprintf fp "                                       (list \"&Setup ...\" \"MomSetup\")\n")
        (fprintf fp "                                       (list \"Select &Traces ...\" \"MomSelect\")\n")
        (fprintf fp "                                       (list 'separator)\n")
        (fprintf fp "                                       (list 'popup \"&Export\")\n")
        (fprintf fp "                                       (list \"Selected To ADS ...\" \"MomExportSelectedAdfiAs\")\n")
        (fprintf fp "                                       (list \"All To ADS ...\" \"MomExportAllSelectedAdfiAs\")\n")
        (fprintf fp "                                       (list \"Selected To EMPro ...\" \"MomExportSelectedAdfiForEMPro\")\n")
        (fprintf fp "                                       (list 'end)\n")
        (fprintf fp "                                       (list 'separator)\n")
        (fprintf fp "                                       (list 'popup \"St&ate\")\n")
        (fprintf fp "                                       (list \"Sa&ve State ...\" \"MomSaveState\")\n")
        (fprintf fp "                                       (list \"&Load State ...\" \"MomLoadState\")\n")
        (fprintf fp "                                       (list 'end)\n")
        (fprintf fp "                                       (list 'separator)\n")
        (fprintf fp "                                       (list \"About ADFI ...\" \"MomAdsAbout\")\n")
        (fprintf fp "                                       (list 'end)))\n")
        (fprintf fp "        q = axlUIMenuFind(nil -1)\n")
        (fprintf fp "        res = (axlUIMenuInsert q eemAllegroMenuList)\n")
        (fprintf fp "      )\n")
        (fprintf fp "    )\n")
        (fprintf fp "  )\n")

        (fprintf fp " (setq msgcontext (axlMsgContextStart \"Suppress trigger warnings.\"))\n")
        (fprintf fp " (when (and (isCallable 'axlTriggerSet) eemEnableMenuAutoLoadFor17)\n")
        (fprintf fp "   (axlTriggerSet 'menu  'eemAllegroMenuTriggerExternal)\n")
        (fprintf fp " )\n")
        (fprintf fp " (axlMsgContextClear msgcontext)\n")
        (fprintf fp " (axlMsgContextFinish msgcontext)\n")
        (fprintf fp ")\n\n")


        (fprintf fp ";; --- END ADFI Keysight EEsof EDA config\n")
        (fprintf fp ";; ----------------------------------------------------\n")
        (axlDMClose fp)
        (return t)
      )
     else
      (fprintf poport "Can't open %s file for writing.\n" initFile)   
      (return)
    )
  )
)


(defun eemInstallAddToIlinitFiles (form @key (local (axlGetVariable "localenv")))
  (let (ilinitFiles others loadString loadStringOld)
    (when (axlFormGetField form "generalcfg")
      (setq ilinitFiles (cons "allegro" ilinitFiles))
    )
    (when (axlFormGetField form "apdcfg")
      (setq ilinitFiles (cons "apd" ilinitFiles))
    )
    (when (axlFormGetField form "cdnsipcfg")
      (setq ilinitFiles (cons "cdnsip" ilinitFiles))
    )
    (when (axlFormGetField form "othercfg")
      (setq others (or (axlFormGetField form "otherstring") ""))
      (setq others (parseString others ","))
      (when (pairp others)
        (setq ilinitFiles (append ilinitFiles others))
      )
    )
    (setq loadString " ; Keysight EEsof EDA, Allegro ADFI load\n")
    ; need to check for old and new initializations
    (setq loadStringOld " ; Agilent EEsof EDA, Allegro DFI load\n")

    (foreach ilinitFile ilinitFiles
      (prog (fullName fp found line notEncrypted)
        (setq fullName (eemSimplifyFilename (strcat local "/" ilinitFile ".ilinit")))
        (setq notEncrypted (not (isFileEncrypted fullName)))
        (fprintf poport "Check for config in %s.ilinit\n" ilinitFile)
        (when (and (isFile fullName)
                   notEncrypted)
          (setq fp (axlDMOpenFile "TEMP" fullName "r"))
          (when fp
            (while (and (gets line fp)
                        (not found))
              (when (or (index (or line "") loadString)
                        (index (or line "") loadStringOld))
                (setq found t)
              )
            )
            (axlDMClose fp)
          )
        )
        (unless found
          (fprintf poport "Add config in %s.ilinit\n" ilinitFile)
          (when (isFile ilinitFile)
            (unless (eemFileRotate fullName)
              (fprintf poport "Can not save ilinit file %s.ilinit before update\n" ilinitFile)
              (return)
            )
          )
          (if notEncrypted
           then
            (setq fp (axlDMOpenFile "TEMP" fullName "a"))
           else
            (if (axlUIYesNo (strcat "The " ilinitFile " file " fullName " is encrypted in your environment.\n"
                                    "Are you sure you want to continue and remove the original content?"))
             then
              (setq fp (axlDMOpenFile "TEMP" fullName "w"))
             else
              (fprintf poport (strcat "Load configuration will not changed automatically.\n"
                                      "Place add the following line to your local or site\n"
                                      "level "  ilinitFile " configuration to enable the ADFI:\n"
                                      "(load \"" (or local ".") "/eemAdfiSetup.il\")" 
                                      loadString
                                      "\n\n"))
            )
          )
          (when fp
            (fprintf fp "(load \"%s/eemAdfiSetup.il\")" (or local "."))
            (fprintf fp loadString)
            (axlDMClose fp)
          )
        )
      )
    )
  )
)

(defun eemInstallFinishADFIinstall ()
  (let (msg (local (axlGetVariable "localenv")))
    (setq msg (strcat  "The setup process added the Allegro ADFI setup file: \"eemAdfiSetup.il\"\n" 
                       "to your local pcbenv directory: \"" (or local "~/pcbenv") "\"\n"
                       "and modified or added the selected ilinit files to recognize this common setup file.\n\n"
                       "The setup script makes a backup of all the files it modifies in the same directory.\n\n"
                       "Please restart " (axlVersion 'programName) " to activate the new Allegro DFI configuration."))
    (axlUIConfirm msg)
  )
)

(unless (isContextLoaded "eemom")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Prepend "." to skill path before calling simplifyFilename
(defun eemSimplifyFilename (filename)
  (let (skillPath expandedName)
    (setq skillPath (getSkillPath))
    (setSkillPath (cons "." skillPath))
    (when (stringp filename)
      (setq expandedName (simplifyFilename filename))
      (setq expandedName (axlOSSlash expandedName))
      (rexCompile "^\\(.*\\)\\/$")
      (when (rexExecute expandedName)
        (setq expandedName (rexSubstitute "\\1"))
      )
    )
    (setSkillPath skillPath)

    expandedName
  ) ; let
) ; eemSimplifyFilename


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Given a string, return the list of words with space as the delimiter char.

(defun eemStringToListOfWords ( sentence )
  (let (wordList)

    (when (and sentence 
               (stringp sentence))
      (setq wordList (parseString sentence " \t\n"))
    ) ; when

    wordList
  ) ; let
) ; eemStringToListOfWords


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Remove leading spaces and replace consecutive spaces in by a single blank char.
(defun eemRemoveExtraBlanks (string)
  (buildString (eemStringToListOfWords string))
) ; eemRemoveExtraBlanks


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Ignoring blanks, returns t if the two arguments are the same string
; Unless 'caseSensitive' is t, also ignores case.
(defun eemTwoStringsAreEquivalent (string1 string2 @key (caseSensitive nil))
  (when (and (or string1 (stringp string1) (symbolp string1)) 
    (or string2 (stringp string2) (symbolp string2)))

    (setq string1 (eemRemoveExtraBlanks (get_string string1)))
    (setq string2 (eemRemoveExtraBlanks (get_string string2)))
    ; caseSensitive==t => skip lowerCase calls.
    (unless caseSensitive
      (setq string1 (lowerCase string1))
      (setq string2 (lowerCase string2))
    )
    ; return value of the following eq() is to be returned by this function. 
    (eq (strcmp string1 string2) 0)
  ) ; when
) ; eemTwoStringsAreEquivalent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Returns t if the given argument is an existing file name
; Like, isFile except it does not cause an error when argument is not string or symbol  
(defun eemIsFile (name)
  (when (symbolp name)
    (setq name (get_string name))
  )
  (when (stringp name)
    (isFile name)
  )
) ; eemIsFile


) ; unless context loaded
) ; unless allready loaded before

