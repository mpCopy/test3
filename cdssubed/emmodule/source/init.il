; Copyright Keysight Technologies 2015 - 2015  

procedure(rfdeMomLay_loadDefaultMOMSettings(session)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure that loads a state when opening Momentum application Window  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  let( (cv techFile fileList ltdFileList typLtdFileList ltdFileName appData)

  cv = dbOpenCellViewByType(
    session~>data~>designObj~>libName
    session~>data~>designObj~>cellName
    session~>data~>designObj~>viewName
    "" "a")

  techFile = techGetTechFile(cv)
  (if getShellEnvVar("MOM_LTD_NAME")!=nil then
    ltdFileName= strcat( getShellEnvVar("MOM_LTD_NAME") ".ltd" )
   else
      fileList = getDirFiles( strcat( getShellEnvVar("MOM_MODULE_PATH") "/MomentumSDB" ))
      ltdFileList = rexMatchList("\\.ltd$" fileList)
      when( ltdFileList
        typLtdFileList = rexMatchList("typical" ltdFileList)
        (if typLtdFileList then
           ltdFileName = car(typLtdFileList)
        else
           ltdFileName = car(ltdFileList)
        );
      );when
  );if
  when( ltdFileName
    techSetParam(techFile "rfdeMomentumSubstrateFileLocation" strcat( getShellEnvVar("MOM_MODULE_PATH") "/MomentumSDB/" ltdFileName ))
  )

  appData=rfdeApp_findFromSession("rfdeMomSim" ?session session)
  rfdeApp_restoreState(appData ?fileName strcat( getShellEnvVar("MOM_MODULE_PATH") "/MomentumState/state" ))

  );let
);end procedure


;procedure(rfdeMomLay_momViewCreated(session)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Procedure called when momentum view is created 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  let((layer)
;  layer='("<POLY>" "tileNot")
;  rfdeMomProc_removeLayer_internal(session layer)
;  );let
;);end procedure


;procedure(rfdeMomLay_beforeNetlistCreated(session)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Procedure called before writing simulation files
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;);end procedure


;procedure(rfdeMomLay_customMenu()
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Procedure that adds custom Layout submenus in the Momentum Virtuoso window
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    prog((customMenuList)
;
;        if ( fboundp('<add callback function here>) then
;            customMenuList=list(
;                list("Menu title" "<add callback function here>(hiGetCurrentWindow())")
;            )
;            return(customMenuList)
;        else
;            return nil
;        )
;    );prog
;);end procedure
