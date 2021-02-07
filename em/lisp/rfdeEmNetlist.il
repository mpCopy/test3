; Copyright Keysight Technologies 2015 - 2018  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; ADS Lisp netlist callback expressions for CDF based components created by EM Cosimulation
;
; Public procedures:
;   Note: the name of these functions cannot be changed!
;
;   for symbol without a reference pin (symbolType == 0)
;     rfdeEmNetlist_eesofEmForSpectre_noRef
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This function implements the equivalent of the skill function in ADS RFDE
; It will allow to share config views between Virtuoso and ADS
;    Switch view list: emExtracted spectre schematic veriloga 
;    Stop view list: spectre
; It is netlisting an SnP rather than nport to take advantage of the .sio.
; The same limitations apply:
;  - The EM Model must contain a data item named "data.0000"
;  - The number of symbol pins must match with the number of ports in the S-parameter model. 
;
(procedure (rfdeEmNetlist_eesofEmForSpectre_noRef netlister)
  ; (cnl_print_string netlister ";rfdeEmNetlist_eesofEmForSpectre_noRef\n") ;; DEBUG
  (rfdeEmNetlist_eesofEmForSpectre netlister ?symbolType 0)
)

;;
; 2-port example
;   symbolType = 0: symbol without reference pin
;  #uselib "ckt" , "SnP"
;  SnP:I__0 N__0 N__1  NumPorts=2 File="<libraryPath>/<cellName>/emModel/data.000.sio" Type="smatrixio"
;
(procedure (rfdeEmNetlist_eesofEmForSpectre netlister @key (symbolType 0))
    ;(de_warning_dialog ";rfdeEmNetlist_eesofEmForSpectre\n") ;; DEBUG
    (let 
      ( bitInstance
        libName
        cellName
        (viewName "emModel") ;; hardcoded
        modelFilePath
      )
      (setq bitInstance (cnl_get_bit_instance netlister))
      (setq libName (db_get_instance_library_name bitInstance))
      (setq cellName (db_get_instance_cell_name bitInstance))
    ;(de_warning_dialog (strcat "info: bit_instance: '" libName ":" cellName ":" (db_get_instance_view_name bitInstance) "'\n")) ;; DEBUG

    (if (eq (emModelView_isEmModelView libName cellName viewName) 0) then
      ;(de_error_dialog (strcat "Unable to generate netlist: the EM model " libName ":" cellName ":" viewName " does not exist."))
      (error (strcat "The EM model '" libName ":" cellName ":" viewName "' does not exist.\nHint: Rerun the EM Cosimulation view generation."))
    else
      (setq modelFilePath (rfdeEmNetlist_modelFilePath netlister))
      ;(de_warning_dialog (strcat modelFilePath "\n")) ;; DEBUG
      (when modelFilePath
        (let 
          ( sigList
            numPorts
            modelFileType
          )
          (setq sigList (cnl_get_signal_list netlister))
          (setq numPorts (listlen sigList))
          (if (rightstr modelFilePath 3) == "sio" then
            (setq modelFileType "smatrixio")
           else
            (setq modelFileType "citi")
          )

        (cnl_print_string netlister "simulator lang = ads\n")
        (cnl_print_string netlister "#uselib \"ckt\", \"SnP\"\n")
        (cnl_print_string netlister "SnP:")
        (cnl_print_string netlister (cnl_get_inst_sim_name netlister))
        (while (car sigList)
          (cnl_print_string netlister (strcat " " (car sigList)))
          (setq sigList (cdr sigList))
        )
        (cnl_print_string netlister (strcat " NumPorts=" numPorts))
        (cnl_print_string netlister (strcat " File=" (identify_value modelFilePath)))
        (cnl_print_string netlister (strcat " Type=" (identify_value modelFileType)))
        (cnl_print_string netlister "\nsimulator lang = spectre")
        )
      )
    )
  )
)


(procedure (rfdeEmNetlist_modelFilePath netlister)
    ;(de_warning_dialog ";rfdeEmNetlist_modelFileType\n") ;; DEBUG
    (let 
    ( bitInstance
      libName
      cellName
      (viewName "emModel") ;; hardcoded
      (fileName "data.000.sio")
      (filePath 'nil)
    )
    (setq bitInstance (cnl_get_bit_instance netlister))
    (setq libName (db_get_instance_library_name bitInstance))
    (setq cellName (db_get_instance_cell_name bitInstance))
    (setq filePath (de_find_file_in_cellview libName cellName viewName fileName))
    (when (or (not (stringp filePath)) (not (ael_file_exists filePath)) )
      ;; fallback to .afs
      (setq fileName "data.000.afs")
      (setq filePath (de_find_file_in_cellview libName cellName viewName fileName))
      (when (or (not (stringp filePath)) (not (ael_file_exists filePath)) )
        (setq filePath 'nil)
        ;(de_error_dialog (strcat "Unable to generate netlist: the em simulation result for " libName ":" cellName ":" viewName " does not exist."));
        (error (strcat "The EM simulation result for '" libName ":" cellName ":" viewName "' does not exist.\nHint: Open the emModel and calculate the model for the default parameters."));
        )
    )
    ;(de_warning_dialog (strcat ";filePath " filePath "\n")) ;; DEBUG
    filePath
  )
)

