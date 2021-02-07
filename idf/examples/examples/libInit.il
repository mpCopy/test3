let( ( (libName "examples") demoIncludePath demoIncludeFile libId libPath)
    libId = ddGetObj( libName )
    when( ddIsId( libId )
        libPath = ddGetObjReadPath( libId )
        printf( "Initializing from libInit.il of library %s...\n" libName )

        ; spectre or adsDL modelFiles are automatically included with DL encrypted cellview.
        ; envSetVal( "spectre.envOpts" "modelFiles" 'string "demo_include.scs;npn" )
        envSetVal( "adsDL.envOpts" "includePath" 'string simplifyFilename( strcat(libPath "/../") ) )
;        envSetVal( "spectre.envOpts" "includePath" 'string simplifyFilename( strcat(libPath "/../") ) )

        ; set model files and sections
        when( libPath && stringp( libPath )
            when( isContextLoaded("schView") && isContextLoaded("ads") 
                demoIncludePath = envGetVal( "adsDL.envOpts" "includePath" )
                demoIncludeFile = "demo_include.scs"
                if( isFile( strcat( demoIncludePath demoIncludeFile ) ) then
                    asiSetEnvOptionVal(asiGetTool('adsDL) "modelFiles"
                        list(
                            list(demoIncludeFile "npn")
                            list(demoIncludeFile "dio")
                        )
                    )
;                    asiSetEnvOptionVal(asiGetTool('spectre) "modelFiles"
;                        list(
;                            list(demoIncludeFile "npn")
;                            list(demoIncludeFile "dio")
;                        )
;                    )
                else
                    warn("Failed to find model file %s" demoIncludeFile)
                )
            )
        )
    )
)  
