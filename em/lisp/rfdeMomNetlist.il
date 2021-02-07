; Copyright Keysight Technologies 2014 - 2018  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; ADS Lisp netlist callback expressions for CDF based components created in Virtuoso
;
;    N = number of S-parameter ports defined in layout view of the component
;    The component's symbol view can have 0, 1 or N reference pins
;
;    Gemini and GoldenGate support spectre syntax. In order to limit the netlist callback
;    maintenance, all 6 callbacks will netlist as a spectre nport.
;
; Public procedures:
;   Note: the name of these functions cannot be changed!
;
;   for symbol without a reference pin (symbolType == 0)
;     rfdeMomNetlist_NPORTforSpectre_noRef() 
;     rfdeMomNetlist_SNPforADS_noRef()
;
;   for symbol with one reference pin (symbolType == 1)
;     rfdeMomNetlist_NPORTforSpectre_wRef()
;     rfdeMomNetlist_SNPforADS_wRef()
;
;   for symbol with N reference pins (symbolType == 2)
;     rfdeMomNetlist_NPORTforSpectre_nport()
;     rfdeMomNetlist_SNPforADS_nport() 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(procedure (rfdeMomNetlist_NPORTforSpectre_noRef netlister)

  (rfdeMomNetlist_NPORTforSpectre netlister ?symbolType 0)
)

(procedure (rfdeMomNetlist_NPORTforSpectre_wRef netlister)

  (rfdeMomNetlist_NPORTforSpectre netlister ?symbolType 1)
)

(procedure (rfdeMomNetlist_NPORTforSpectre_nport netlister)

  (rfdeMomNetlist_NPORTforSpectre netlister ?symbolType 2)
)

(procedure (rfdeMomNetlist_SNPforADS_noRef netlister)

  (cnl_print_string netlister "simulator lang = spectre\n")
  (rfdeMomNetlist_NPORTforSpectre netlister ?symbolType 0)
  (cnl_print_string netlister "simulator lang = ads\n")
)

(procedure (rfdeMomNetlist_SNPforADS_wRef netlister)

  (cnl_print_string netlister "simulator lang = spectre\n")
  (rfdeMomNetlist_NPORTforSpectre netlister ?symbolType 1)
  (cnl_print_string netlister "simulator lang = ads\n")
)

(procedure (rfdeMomNetlist_SNPforADS_wRef netlister)

  (cnl_print_string netlister "simulator lang = spectre\n")
  (rfdeMomNetlist_NPORTforSpectre netlister ?symbolType 2)
  (cnl_print_string netlister "simulator lang = ads\n")
)


;;
; 2-port example
;   symbolType = 0: symbol without reference pin
;       I__0 ( N__0 0 N__1 0) nport interp=linear file="<libraryPath>/<cellName>/mommdl/text.txt" datafmt=citi
;
;   symbolType = 1: symbol with 1 reference pin
;       I__0 ( N__0 N__2 N__1 N__2) nport interp=linear file="<libraryPath>/<cellName>/mommdl/text.txt" datafmt=citi
;
;   symbolType = 2: symbol with N reference pins
;       I__0 ( N__0 N__1 N__2 N__3) nport interp=linear file="<libraryPath>/<cellName>/mommdl/text.txt" datafmt=citi
;
(procedure (rfdeMomNetlist_NPORTforSpectre netlister @key (symbolType 0))

  ;;(cnl_print_string netlister ";rfdeMomNetlist_NPORTforSpectre\n") ;; DEBUG

  (let 
    ((modelFilePath (rfdeMomNetlist_modelFilePath netlister)))
  
    (when modelFilePath
      (let (fmax addNoise)

        (cnl_print_inst_name netlister)

        (cnl_print_string netlister " (")
        ;; spectre's nport device requires 2n terminals
        if( (eq symbolType 2) then
          ; N reference pins directly maps to the nport device in spectre
          (cnl_print_inst_signals netlister)
        else
          (let ((sigList (cnl_get_signal_list netlister))
                refNode)
            (if (eq symbolType 1) then
              ; 1 reference pin assumed to be at the end of the sigList
              (setq sigList (reverse sigList))
              (setq refNode (car sigList)) ; last node is reference
              (setq sigList (reverse (cdr sigList))) ; all but last node
            else
              ; no reference pin 
              (setq refNode "0")
            )
            ;; alternate nodes with the reference node
            (while (car sigList)
              (cnl_print_string netlister (strcat " " (car sigList)))
              (cnl_print_string netlister (strcat " " refNode))
              (setq sigList (cdr sigList))
            )
          )
        )
        (cnl_print_string netlister ") nport")
        
        (cnl_print_string netlister " interp=linear")
        (cnl_print_string netlister (strcat " file=" (identify_value modelFilePath)))
        (cnl_print_string netlister " datafmt=citi")

        (setq fmax (cnl_get_param_string_value netlister "ImpMaxFreq"))
        (when fmax && fmax != " "
          (cnl_print_string netlister (strcat " fmax=" fmax " usewindow=no passivity=no"))
        )
        (setq addNoise (cnl_get_param_string_value netlister "AddNoise"))
        (when addNoise && addNoise != " "
          (cnl_print_string netlister (strcat " thermalnoise=" addNoise))
        )
      )
    )
  )
)


(procedure (rfdeMomNetlist_modelFilePath netlister)

  ;;(cnl_print_string netlister ";rfdeMomNetlist_modelFilePath\n") ;; DEBUG

  (let 
    ( bitInstance
      libName
      cellName
      (viewName "mommdl")
      (fileName "text.txt")
      (filePath 'nil)
    )
    (setq bitInstance (cnl_get_bit_instance netlister))
    (setq libName (db_get_instance_library_name bitInstance))
    (setq cellName (db_get_instance_cell_name bitInstance))
    (setq filePath (de_find_file_in_cellview libName cellName viewName fileName))
    (when (or (not (stringp filePath)) (not (ael_file_exists filePath)) )
      (setq filePath 'nil)
    )
    filePath
  )
)

