; Copyright Keysight Technologies 2014 - 2017  
; This file contains lisp procedures used by standard Virtuoso libraries and customer PDKs so the library lisp files can execute properly within the ADS environment.
; This file contains implementations of netlisting functions used by analogLib.

defun(_artCheckFeature (dummy) t)

defun(_spectreCheckFeature (envName) t)

; Used by nport
defun(_spectreNportCheckBoxDisplay ()
    t
)

defun(hiGetCurrentForm ()
    ; TODO: This is probably supposed to return a dialog box object
    nil
)

defun(hiIsForm (form)
    api_dlg_is_dialog(form)
)

defun(hiIsFormDisplayed (form)
    api_dlg_is_managed(form)
)

defun(hiFormClose (form)
    api_dlg_unmanage(form)
)

defun( _spectreiBrowseFile (form parameter)
    let( (fileName)
        fileName=ui_prompt_for_file("Select a file")
        if(fileName then
            fileName = filename_make_relative_path(fileName, getcwd())
            (get cdfgData parameter)->value = fileName
        )
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;
; custom netlist functions

defun(analogLib_append_parameter_value (netlister paramName currentOutput)
    let( (val (output currentOutput) )
        val=cnl_get_param_string_value( netlister paramName )
        when( val 
            output=strcat( output " " paramName "=" val )
        )
        output
    )
)

; Used by cccs and ccvs
defun(spectreCCPrim (netlister)
    let( ( trfType iVectSpec typeSrc)
        trfType=cnl_get_param_string_value( netlister "trfType" )
        if( trfType == "Linear" then
            cnl_print_inst( netlister )
        else
            cnl_print_inst_name( netlister )
            cnl_print_inst_signals( netlister )
            cnl_print_inst_model_name( netlister )
            _spectrePrintParam( netlister "m" )
            _spectrePrintParam( netlister "type" )
            _spectrePrintParam( netlister "scale" )
            _spectrePrintParam( netlister "stretch" )
            _spectrePrintParam( netlister "delta" )
            _spectrePrintParam( netlister "tc1" )
            _spectrePrintParam( netlister "tc2" )
            iVectSpec=cnl_get_param_string_value( netlister "iVectSpec" )

            if( iVectSpec == "DataFile" then
                _spectrePrintQuotedParam( netlister "file" )
            else
                _spectrePrintPwlVec( netlister )
            )
        )
        typeSrc = cnl_get_param_string_value(netlister "typesrc")
        if( typeSrc == "cccs" || typeSrc == "ccvs" || typeSrc == nil then
            _spectrePrintParam( netlister "probe" )
            _spectrePrintParam( netlister "port" )
        else
            _spectrePrintVecUnderscored(netlister "probes" "p" "probeCnt")
            _spectrePrintOptionalVec(netlister "ports" "port" "probeCnt")
        )
    )
)

; Use this to report errors (or could be warnings) about unsupported components
defun(report_unsupported_analogLib_component (netlister)
    let( ((output ""))
        output=strcat( "Unsupported netlisting function for analogLib component "
            cnl_get_inst_model_name( netlister ) "." )
        ; this could use warning
        error(output)
        ;the error should abort this function
    )
)

;NOTE: It seems better to have missing functions than to have comments in the netlist

/*
The functions commented out are either not implemented yet or not supported in ADS.

; Used by ibis_buffer
defun(_spectreIbis (netlister) report_unsupported_analogLib_component(netlister) )

; Used by iprbs, pprbs and vprbs
defun(_spectrePrbsPrim (netlister) report_unsupported_analogLib_component(netlister) )

; Used by ipwlf and vpwlf
defun(spectreFsrcPrim (netlister) report_unsupported_analogLib_component(netlister) )

; Used by isource and vsource
defun(spectreVandISourcePrim (netlister) report_unsupported_analogLib_component(netlister) )

; Used by mtline
defun(_spectreMtlineNew (netlister) report_unsupported_analogLib_component(netlister) )

; Used by pcccs, pccvs, pvccs, pvccs2, pvccs3, pvcvs, pvcvs2, pvcvs3
defun(spectrePolyCntrlPrim (netlister) report_unsupported_analogLib_component(netlister) )

; Used by pvccsp, pvcvsp
defun(_spectrePolyCntrlPrimP (netlister) report_unsupported_analogLib_component(netlister) )

; Used by scasubckt
defun(_spectreSubCkt (netlister) report_unsupported_analogLib_component(netlister) )

; Used by scccs, sccvs, zcccs, zccvs
defun(spectreSCCPrim (netlister) report_unsupported_analogLib_component(netlister) )

; Used by svccs, svcvs, zvccs, zvcvs
defun(spectreSVCPrim (netlister) report_unsupported_analogLib_component(netlister) )

; Used by vccsp, vcvsp
defun(_spectreVCPrimP (netlister) report_unsupported_analogLib_component(netlister) )

*/

; used by ind, pinductor
defun(_spectreInd (netlister)
    cnl_print_inst( netlister )
    ; Output polynomial coefficients if necessary
    _spectrePrintRequiredVec( netlister "coeffs" "c" "polyCoef" )
)

; Used by ipwl, ppwl, and vpwl
defun(spectrePwlsrcPrim (netlister)
    let( ((output "") modelName)
        cnl_print_inst( netlister )

        modelName = cnl_get_inst_model_name( netlister )
        if( modelName == "isource" then
            _spectrePrintTivPairs( netlister "i")
        else
            _spectrePrintTivPairs( netlister "v")
        )

        _spectrePrintFundName( netlister )
        _spectrePrintNoiseFile(netlister)
        _spectrePrintNoiseVec(netlister)
    )
)

; Used by mind, pmind
defun(spectreMindPrim (netlister)
    let( (ind1 ind2)
        cnl_print_inst_name( netlister )
        cnl_print_inst_model_name( netlister )
        cnl_print_inst_parameters( netlister )
        if( ind1=cnl_get_param_string_value( netlister, "ind1" ) then
            cnl_print_string( netlister strcat( " ind1=" ind1 ) )
        )
        if( ind2=cnl_get_param_string_value( netlister, "ind2" ) then
            cnl_print_string( netlister strcat( " ind2=" ind2 ) )
        )
    )
)

defun(_spectrePrintQuotedParam (netlister netlistedName)
    let( (output paramValue)
        paramValue = cnl_get_param_string_value(netlister netlistedName)
        if( paramValue then
            output = _spectreGetStringParamNameAndValue(netlister netlistedName paramValue)
            cnl_print_string( netlister output)
        )
    )
)

defun(_spectreGetStringParamNameAndValue (netlister paramName paramValue)
    let( (haspParExp valueOutPut)
        haspParExp = cnl_string_param_has_ppar_expression(netlister paramName)
        valueOutPut = _spectreGetStringParamValue(paramValue haspParExp)
        strcat(" " paramName "=" valueOutPut)
    )
)

defun(_spectreGetStringParamValue (paramValue haspParExp)
    if( haspParExp then
        paramValue
    else
        strcat("\"" paramValue "\""))
)

defun(_spectrePrintParam (netlister netlistedName)
    let( (output paramValue)
        paramValue = cnl_get_param_string_value(netlister netlistedName)
        if( paramValue then
            output = strcat( " " netlistedName "=" paramValue)
            cnl_print_string( netlister output)
        )
    )
)

defun(_spectrePrintRequiredParamValueOnly (netlister netlistedName)
    let( (output paramValue)
        paramValue = cnl_get_param_string_value(netlister netlistedName)
        if( !paramValue then
            error("Missing parameter '%s' on instance %s." netlistedName cnl_get_inst_sim_name(netlister))
        )
        output = strcat( " " paramValue)
        cnl_print_string( netlister output)
    )
)

defun(_spectrePrintRequiredParamValueOnlyNoThrow (netlister netlistedName)
    let( (output paramValue)
        paramValue = cnl_get_param_string_value(netlister netlistedName)
        if( paramValue != "" then
            output = strcat( " " paramValue)
            cnl_print_string( netlister output)
        )
    )
)

defun(_spectrePrintFundName (netlister)
    _spectrePrintQuotedParam(netlister "fundname")
)

defun(_spectrePrintFund2Name (netlister)
    _spectrePrintQuotedParam(netlister "fundname2")
)

defun(_spectrePrintNoiseFile (netlister)
    _spectrePrintQuotedParam(netlister "noisefile")
)

defun(_spectrePrintFmModFiles (netlister)
let( (fmmodfile1ParamValue fmmodfile2ParamValue haspParFile1 haspParFile2 outParamValueFile1 outParamValueFile2)

        fmmodfile1ParamValue = cnl_get_param_string_value(netlister "fmmodfile1")
        fmmodfile2ParamValue = cnl_get_param_string_value(netlister "fmmodfile2")

        if( fmmodfile1ParamValue || fmmodfile2ParamValue then
            cnl_print_string( netlister " fmmodfiles=[" )
            if( fmmodfile1ParamValue then
                haspParFile1 = cnl_string_param_has_ppar_expression(netlister "fmmodfile1")
                outParamValueFile1 = strcat(" " _spectreGetStringParamValue(fmmodfile1ParamValue haspParFile1))
                cnl_print_string(netlister outParamValueFile1)
            )
            if( fmmodfile2ParamValue then
                haspParFile2 = cnl_string_param_has_ppar_expression(netlister "fmmodfile2")
                outParamValueFile2 = strcat(" " _spectreGetStringParamValue(fmmodfile2ParamValue haspParFile2))
                cnl_print_string(netlister outParamValueFile2)
            )
            cnl_print_string( netlister " ]" )
        )
    )
)

defun(_spectrePrintIQModFiles (netlister)
    let( ( iModFilesParamValue qModFilesParamValue haspPariMod haspParqMod outiModValue outpModValue)

        iModFilesParamValue = cnl_get_param_string_value(netlister "imodfile")
        qModFilesParamValue = cnl_get_param_string_value(netlister "qmodfile")

        if( iModFilesParamValue || qModFilesParamValue then
            cnl_print_string( netlister " iqmodfiles=[" )
            if( iModFilesParamValue then
                haspPariMod = cnl_string_param_has_ppar_expression(netlister "imodfile")
                outiModValue = strcat(" " _spectreGetStringParamValue(iModFilesParamValue haspPariMod))
                cnl_print_string(netlister outiModValue)
            )
            if( qModFilesParamValue then
                haspParqMod = cnl_string_param_has_ppar_expression(netlister "qmodfile")
                outpModValue = strcat(" " _spectreGetStringParamValue(qModFilesParamValue haspParqMod))
                cnl_print_string(netlister outpModValue)
            )
            cnl_print_string( netlister " ]" )
        )
    )
)

defun(_spectrePrintNoiseVec (netlister)
    let( (FNpairs freqParamName freqParamValue noiseParamName noiseParamValue i )
        FNpairs = evalstring( cnl_get_param_string_value(netlister "FNpairs") )
        when( FNpairs > 0
            i=1
            cnl_print_string( netlister " noisevec=[")
            while( i <= FNpairs && i <= 10
                sprintf( freqParamName "F%d" i )
                _spectrePrintRequiredParamValueOnly(netlister freqParamName)
                sprintf( noiseParamName "N%d" i )
                _spectrePrintRequiredParamValueOnly(netlister noiseParamName)
                i++
            )
            cnl_print_string( netlister " ]")
        )
    )
)

defun(_spectrePrintEdgeTypePrbs (netlister)
        edgeTypeValue = cnl_get_param_string_value(netlister "edgetypePrbs")
        if( edgeTypeValue then
            cnl_print_string( netlister " edgetype=")
            cnl_print_string( netlister edgeTypeValue)
        )
)

defun(_spectrePrintTivPairs (netlister ivPrefix)
    let( (tvPairs i timeParamName ivParamName )
        tvPairs = evalstring( cnl_get_param_string_value(netlister "tvpairs") )
        when( tvPairs > 0
            i=1
            cnl_print_string( netlister " wave=[")
            while( i <= tvPairs && i <= 50
                sprintf( timeParamName "t%d" i )
                _spectrePrintRequiredParamValueOnly(netlister timeParamName)
                sprintf( ivParamName "%s%d" ivPrefix i )
                _spectrePrintRequiredParamValueOnly(netlister ivParamName)
                i++
            )
            cnl_print_string( netlister " ]")
        )
    )
)

defun(_spectrePrintTVPairs (netlister)
    let( (tvPairs i)
        tvPairs = evalstring( cnl_get_param_string_value(netlister "tvpairs") )
        when( tvPairs > 0
            i=1
            cnl_print_string( netlister " wave=[")
            while( i <= tvPairs && i <= 50
                sprintf( timeParamName "t%d" i )
                _spectrePrintRequiredParamValueOnly(netlister timeParamName)
                sprintf( ivParamName "v%d" i )
                _spectrePrintRequiredParamValueOnly(netlister ivParamName)
                i++
            )
            cnl_print_string( netlister " ]")
        )
    )
)

defun(_spectreBitParameterOutput (netlister)
    let( ((parameterOutput "") paramList )
    )
)

defun(_spectreDcParameterOutput (netlister)
    let( ((parameterOutput "") )
        _spectrePrintNoiseFile(netlister)
        _spectrePrintNoiseVec(netlister)
    )
)

defun(_spectreExpParameterOutput (netlister)
    let( ((parameterOutput "") paramList )
    )
)

defun(_spectrePrbsParameterOutput (netlister)
    let( ((parameterOutput "") paramList )
    )
)

defun(_spectrePulseParameterOutput (netlister)
    let( ((parameterOutput "") )

        _spectrePrintFundName( netlister )
        _spectrePrintNoiseFile(netlister)
        _spectrePrintNoiseVec(netlister)
    )
)

defun(_spectrePwlParameterOutput (netlister)
    let( ((parameterOutput "") paramList )
    )
)

defun(_spectreSinParameterOutput (netlister)
    let( ((parameterOutput "") (noisevec "" ) freqParamName freqParamValue noiseParamName noiseParamValue )
        _spectrePrintFundName( netlister )
        _spectrePrintFund2Name( netlister )
        _spectrePrintNoiseFile(netlister)
        _spectrePrintNoiseVec(netlister)
        _spectrePrintFmModFiles(netlister)
    )
)

; This function is used to output the vsource and isource based components, which consist of bit, dc, exp, pulse, sin. The source and prbs types 
; have their own functions.
; Used by ibit, idc, iexp, ipulse, isin, pdc, pexp, ppulse
; The source components compile multiple parameters into arrays; this could have been achieved by making an auxiliary parameter that gets set appropriately by 
; callback functions, but Cadence chose to do the outputs by having a netlisting callback instead.
defun(spectreSrcPrim (netlister)
    let( (srcType)
        cnl_print_inst( netlister )
        srcType = cnl_get_param_string_value(netlister "type")
        cond(
            ( srcType == "bit"
                _spectreBitParameterOutput(netlister)
            )
            ( srcType == "dc"
                _spectreDcParameterOutput(netlister)
            )
            ( srcType == "exp"
                output _spectreExpParameterOutput(netlister)
            )
            ( srcType == "pulse"
                _spectrePulseParameterOutput(netlister)
            )
            ( srcType == "pwl"
                _spectrePwlParameterOutput(netlister)
            )            
            ( srcType == "sine"
                _spectreSinParameterOutput(netlister)
            )
        )
    )
)

defun(_printPortSignals (netlister)
    let( ( signalList )
        cnl_print_string( netlister " (" )
        signalList = cnl_get_signal_list(netlister)
        setq(firstSignal t)
        foreach( signal signalList
            if( firstSignal then
                cnl_print_string(netlister strcat(signal))       
            else
                cnl_print_string(netlister strcat(" " signal))
            )
            firstSignal = nil
        )
        cnl_print_string( netlister ")" )
    )
)

defun(_spectrePrintParamTaps (netlister)
    let( (output paramValue)
        paramValue = cnl_get_param_string_value(netlister "taps")
        if( paramValue then
            output = strcat( " taps=[" paramValue "]") 
            cnl_print_string( netlister output)
        )
    )
)

defun(_spectrePrintHP (netlister)
    let( ((output "")paramValue (ro "") (xo "") (harmvec "") (rvec "") (xvec "") (space ""))
        paramValue = cnl_get_param_string_value(netlister "hp")
        listOfStrings = evalstring( paramValue )   

        resistanceAndReactance = nth(0 listOfStrings)
        ro = nth( 0 resistanceAndReactance )
        ro = strcat( " ro=" ro )
        xo = nth( 1 resistanceAndReactance )
        xo = strcat( " xo=" xo )
               
        listOfStrings = cdr( listOfStrings )
        listOfStrings = reverse( listOfStrings )
        
        foreach( signal listOfStrings
            harmvec = strcat( harmvec space stripstr(nth( 0 signal )) )
            rvec = strcat( rvec space nth( 1 signal ) )
            xvec = strcat( xvec space nth( 2 signal ) )
            space = " "
        )       
        harmvec = strcat( " harmvec=[" harmvec "]")
        rvec = strcat( " rvec=[" rvec "]")
        xvec = strcat( " xvec=[" xvec "]")
        
        output = strcat( ro xo harmvec rvec xvec )
        cnl_print_string( netlister output)
    )
)

defun(_hpPopupPortSetForm ()
    hPortSetForm = port_harmonic_open_dialog(cdfgData)
)

defun(_spectrePrintDelay ( netlister )
    let( (paramValue (output ""))
        paramValue = cnl_get_param_string_value(netlister "tdPrbs")
        if( paramValue then
            output = strcat( " delay="paramValue "")
            cnl_print_string( netlister output )
        )     
    )
)

defun(_spectrePrintPeriod ( netlister )
    let( (paramValue (output ""))
        paramValue = cnl_get_param_string_value(netlister "perPrbs")
        if( paramValue then
            output = strcat( " period="paramValue "")
            cnl_print_string( netlister output )
        )     
    )
)

defun(_spectrePrintTransitionReference ( netlister )
    let( (paramValue (output ""))
        paramValue = cnl_get_param_string_value(netlister "transitionreference")
        if( paramValue then
            parsedString = parseString( paramValue "-" )
            highTransitionReference = nth( 1 parsedString )
            if( highTransitionReference then
                highTransitionReferenceNoPercent = parseString( highTransitionReference "%" )
                output = strcat( " transitionreference="nth( 0 highTransitionReferenceNoPercent ) "")
                cnl_print_string( netlister output )
            
            else
                if( cnl_get_param_string_value(netlister "transitionreference") == "Specify" then
                    paramValue = cnl_get_param_string_value(netlister "upperthreshold")
                    if( paramValue then
                        output = strcat( " transitionreference="paramValue "")
                        cnl_print_string( netlister output )
                    )
                )
            )
        )     
    )
)

defun(_spectrePrintLfsrmode ( netlister )
    let( (paramValue (output ""))
        paramValue = cnl_get_param_string_value(netlister "lfsrmode")
        if( paramValue then
            if( paramValue != "Specify bit file" && paramValue != "Specify seed and taps" then
                parsedString = parseString( paramValue "PN" )            
                output = strcat( " registerlength="nth( 0 parsedString ) "")
                cnl_print_string( netlister output )
            )
        )
    )
)

defun(_spectrePrintLfsrseed ( netlister )
    let( (paramModeValue (output "") parseStringValue (fileStringToBuild "") )
        paramModeValue = cnl_get_param_string_value(netlister "lfsrmode")
        paramValue = cnl_get_param_string_value(netlister "lfsrseed")
        if( paramModeValue != "Specify bit file" && paramValue then
            output = strcat( " lfsrseed=["paramValue "]")
            cnl_print_string( netlister output )
        )
        if( paramModeValue == "Specify bit file" then
            paramValue = cnl_get_param_string_value(netlister "prbsFile")
            if( paramValue then
                parseStringValue = parseString( paramValue "/" )
                foreach( val parseStringValue
                    fileStringToBuild = strcat( fileStringToBuild " / " val )                    
                )
                output = strcat( " file" "=\"" fileStringToBuild "")
                cnl_print_string( netlister output )
            )
        )
        if( paramModeValue == "Specify seed and taps" then
            paramValue = cnl_get_param_string_value(netlister "lfsrtaps")
            output = strcat( " lfsrtaps=["paramValue "")
            cnl_print_string( netlister output )
            cnl_print_string( netlister "]" )
        )               
    )
)

defun(_spectrePrintPJ ( netlister )
    let( (paramValue (output ""))
        paramValue = cnl_get_param_string_value(netlister "pjamp1")
        if( paramValue then
            output = strcat( " pjamp="paramValue "")
            cnl_print_string( netlister output )
        ) 
        paramValue = cnl_get_param_string_value(netlister "pjfreq1")
        if( paramValue then
            output = strcat( " pjfreq="paramValue "")
            cnl_print_string( netlister output )
        )  
        paramValue = cnl_get_param_string_value(netlister "pjtype1")
        if( paramValue then
            output = strcat( " pjtype="paramValue "")
            cnl_print_string( netlister output )
        )          
    )
)

defun(_spectrePrintTrigger ( netlister )
    let( ( paramValue )
        paramValue = cnl_get_param_string_value(netlister "trigger")
        if( paramValue then
            if( ( paramValue == "External rising edge" ) then
                cnl_print_string( netlister " triggerdirection=rise")
            )            
            if( ( paramValue == "External falling edge" ) then
                cnl_print_string( netlister " triggerdirection=fall")
            )                                   
            if( ( paramValue == "External both edges" ) then
                cnl_print_string( netlister " triggerdirection=both")
            )      
        )
    )
)

defun(_spectrePrintTriggerThreshold ( netlister )
    let( (paramValue (output ""))
        paramValue = cnl_get_param_string_value(netlister "triggerthreshold")
        if( paramValue then
            if( ( paramValue != "Internal" ) then 
                _spectrePrintParam( netlister "triggerthreshold" )
            )
        )
    )
)

defun(_spectrePrintIsNoisy ( netlister )
    let( (paramValue (output ""))
        paramValue = cnl_get_param_string_value(netlister "isnoisyNoiseModel")
        if( paramValue then
            output = strcat( " isnoisy="paramValue "")
            cnl_print_string( netlister output )
        )

    )
)

defun(_spectrePrintNoiseType ( netlister )
    let( (paramValue (output ""))
        paramValue = cnl_get_param_string_value(netlister "noiseModelType")
        if( paramValue == "Noise Voltage(V^2/Hz)" then
            output = strcat( " noisetype=noisevoltage")
            cnl_print_string( netlister output )
        )
        if( paramValue == "SSB Phase Noise(dBc)" then
            output = strcat( " noisetype=ssbphasenoise")
            cnl_print_string( netlister output )
        ) 
    )
)

defun(_spectrePrintNoiseModelInterp ( netlister )
    let( (paramValue (output ""))
        paramValue = cnl_get_param_string_value(netlister "noiseModelInterMethod")
        noiseModelTypeValue = cnl_get_param_string_value(netlister "noiseModelType")
        if( paramValue && noiseModelTypeValue == "Noise Voltage(V^2/Hz)" then
            output = strcat( " noiseinterp="paramValue "")
            cnl_print_string( netlister output )
        )
    )
)

hPortSetForm = nil

; Used by port, port3t
defun(spectrePortSrcPrim (netlister)
    let( ((output "") )
        cnl_print_inst_name( netlister )
        _printPortSignals( netlister )
        cnl_print_inst_model_name( netlister )
        cnl_print_inst_parameters( netlister )
                    
        _spectrePrintTVPairs( netlister )
        _spectrePrintQuotedParam( netlister "fundname" )
        _spectrePrintQuotedParam( netlister "noisefile" )
        _spectrePrintIsNoisy( netlister )
        _spectrePrintNoiseType( netlister )
        _spectrePrintNoiseModelInterp( netlister )
        _spectrePrintNoiseVec( netlister )
        if( ( cnl_get_param_string_value( netlister "pm" ) == "HarmonicPort" ) then
            _spectrePrintHP( netlister )
        )
        _spectrePrintQuotedParam( netlister "file" )
        _spectrePrintQuotedParam( netlister "fundname2" )
        _spectrePrintFmModFiles( netlister )
        _spectrePrintIQModFiles( netlister )

        _spectrePrintOptionalVec(netlister "freqvec" "freqv" "freqvec") 
        
        _spectrePrintOptionalVec(netlister "amplvec" "vav" "freqvec")
        _spectrePrintOptionalVec(netlister "dbmvec" "vaDBmv" "freqvec")         
        
        _spectrePrintVecWithDefault(netlister "phasevec" "phasev" 0 "freqvec")
        _spectrePrintVecWithDefault(netlister "maxharms" "harmv" 1 "freqvec")       
        
        if( ( cnl_get_param_string_value( netlister "type" ) == "prbs" && 
        ( cnl_get_param_string_value( netlister "trigger" ) == "Internal" )) then
            _spectrePrintDelay( netlister )
            _spectrePrintPeriod( netlister )
        )
        
        if( ( cnl_get_param_string_value( netlister "type" ) == "bit" ) then
            _spectrePrintQuotedParam( netlister "data" )
            _spectrePrintParam( netlister "rptstart" )
            _spectrePrintParam( netlister "rpttimes" )
        )

        if( ( cnl_get_param_string_value( netlister "type" ) == "prbs" ) then
            _spectrePrintParam( netlister "seed" )
            _spectrePrintParam( netlister "jitter" )
            _spectrePrintParam( netlister "ref" )
            _spectrePrintParamTaps( netlister )
            _spectrePrintTransitionReference( netlister )
            _spectrePrintEdgeTypePrbs( netlister )
            _spectrePrintTrigger( netlister )
            _spectrePrintTriggerThreshold( netlister )
            _spectrePrintLfsrmode( netlister )
            _spectrePrintLfsrseed( netlister )
            if( ( cnl_get_param_string_value( netlister "trigger" ) == "Internal" ) then
                _spectrePrintParam( netlister "rjrms" )
                _spectrePrintParam( netlister "rjseed" )
                _spectrePrintPJ( netlister )
            )
        )       
    )
)

; if any values are specified, print the whole vector
; use the default for missing values - throw error if default is nil
defun(_spectrePrintVecWithDefault (netlister netlistName baseParamName default countName)
    let( ((output "") (vec "" ) numValues count i paramName paramValue missingParam )
        count = evalstring( cnl_get_param_string_value(netlister countName) )
        when( count > 0
            i=1
            numValues=0
            while( i <= count && i <= 10
                sprintf( paramName "%s%d" baseParamName i )
                paramValue = cnl_get_param_string_value(netlister paramName)
                if( paramValue  then
                    ++numValues
                else
                    if(!missingParam
                        missingParam = paramName
                    )
                    if(default then
                        paramValue = default
                    else
                        paramValue = ""
                    )
                )
                vec = strcat( vec " " paramValue )
                i++
            )
            if(numValues > 0 && numValues < count && !default then
                error("Missing parameter '%s' on instance %s." missingParam cnl_get_inst_sim_name(netlister))
            )
            if( numValues > 0 then
                output = strcat( " " netlistName "=[" vec " ]" )
                cnl_print_string( netlister output)
            )
        )
    )
)

; only print the vector if any values are specified
defun(_spectrePrintOptionalVec (netlister netlistName baseParamName countName)
    let( (output (vec "" ) count i numValues paramName paramValue )
        count = evalstring( cnl_get_param_string_value(netlister countName) )
        when( count > 0
            i=1
            numValues=0
            while( i <= count && i <= 10
                sprintf( paramName "%s%d" baseParamName i )
                paramValue = cnl_get_param_string_value(netlister paramName)
                if( paramValue  then
                    vec = strcat( vec " " paramValue )
                    ++numValues
                )
                i++
            )
            if( numValues > 0 then
                output = strcat( " " netlistName "=[" vec " ]" )
                cnl_print_string( netlister output)
            )
        )
    )
)

; throw error if any values are not specified
defun(_spectrePrintRequiredVec (netlister netlistName baseParamName countName)
    let( (count i paramName )
        count = evalstring( cnl_get_param_string_value(netlister countName) )
        when( count > 0
            i=1
            cnl_print_string( netlister " ")
            cnl_print_string( netlister netlistName)
            cnl_print_string( netlister "=[")
            while( i <= count && i <= 10
                sprintf( paramName "%s%d" baseParamName i )
                _spectrePrintRequiredParamValueOnly(netlister paramName)
                i++
            )
            cnl_print_string( netlister " ]")
        )
    )
)

defun(_spectrePrintRequiredVecNoThrow (netlister netlistName baseParamName countName)
    let( (count i paramName )
        count = evalstring( cnl_get_param_string_value(netlister countName) )
        when( count > 0
            i=1
            cnl_print_string( netlister " ")
            cnl_print_string( netlister netlistName)
            cnl_print_string( netlister "=[")
            while( i <= count && i <= 10
                sprintf( paramName "%s%d" baseParamName i )
                _spectrePrintRequiredParamValueOnlyNoThrow(netlister paramName)
                i++
            )
            cnl_print_string( netlister " ]")
        )
    )
)

; only print the vector if any values are specified (precede numbers by underscore)
defun(_spectrePrintVecUnderscored (netlister netlistName baseParamName countName)
    let( (output (vec "" ) count i numValues paramName paramValue prefix )
        count = evalstring( cnl_get_param_string_value(netlister countName) )
        when( count > 0
            i=1
            numValues=0
            while( i <= count && i <= 10
                sprintf( paramName "%s%d" baseParamName i )
                paramValue = cnl_get_param_string_value(netlister paramName)
                if( paramValue  then
                    if( atof(paramValue) == nil then
                        prefix = ""
                    else
                        prefix = "_"
                    )
                    vec = strcat( vec " " prefix paramValue )
                    ++numValues
                )
                i++
            )
            if( numValues > 0 then
                output = strcat( " " netlistName "=[" vec " ]" )
                cnl_print_string( netlister output)
            )
        )
    )
)

; all values are required
defun(_spectrePrintPwlVec (netlister)
    let( (count i pwiParamName pwoParamName )
        count = evalstring( cnl_get_param_string_value(netlister "pwlCnt") )
        when( count > 0
            i=1
            cnl_print_string( netlister " pwl=[")
            while( i <= count && i <= 20
                sprintf( pwiParamName "pwi%d" i )
                _spectrePrintRequiredParamValueOnly(netlister pwiParamName)
                sprintf( pwoParamName "pwo%d" i )
                _spectrePrintRequiredParamValueOnly(netlister pwoParamName)
                i++
            )
            cnl_print_string( netlister " ]")
        )
    )
)

; Used by psin
defun(spectrePortPrim (netlister)
    let( ((output "") signalList srcType)
        cnl_print_inst( netlister )
        _spectrePrintFundName( netlister )
        _spectrePrintFund2Name( netlister )
        _spectrePrintNoiseFile(netlister)
        _spectrePrintNoiseVec(netlister)
        _spectrePrintFmModFiles(netlister)
        _spectrePrintRequiredVec(netlister "freqvec" "freqv" "freqvec")
        _spectrePrintVecWithDefault(netlister "dbmvec" "vaDBmv" nil "freqvec")
        _spectrePrintVecWithDefault(netlister "phasevec" "phasev" 0 "freqvec")
        _spectrePrintVecWithDefault(netlister "maxharms" "harmv" 1 "freqvec")
    )
)

; Used by vccs, vcvs
defun(_spectreVCPrim (netlister)
    let( ( trfType iVectSpec )
        trfType=cnl_get_param_string_value( netlister "trfType" )
        if( trfType == "Linear" then
            cnl_print_inst( netlister )
        else
            cnl_print_inst_name( netlister )
            cnl_print_inst_signals( netlister )
            cnl_print_inst_model_name( netlister )
            _spectrePrintParam( netlister "m" )
            _spectrePrintParam( netlister "type" )
            _spectrePrintParam( netlister "scale" )
            _spectrePrintParam( netlister "stretch" )
            _spectrePrintParam( netlister "delta" )
            _spectrePrintParam( netlister "tc1" )
            _spectrePrintParam( netlister "tc2" )
            _spectrePrintParam( netlister "inputtype" )
            iVectSpec=cnl_get_param_string_value( netlister "iVectSpec" )
            if( iVectSpec == "DataFile" then
                _spectrePrintQuotedParam( netlister "file" )
            else
                _spectrePrintPwlVec( netlister )
            )
        )
    )
)

; Used by winding
defun(spectreWindingPrim (netlister)
    let( ((core ""))
        cnl_print_inst( netlister )
        if( core = cnl_get_param_string_value( netlister "core" ) then
            cnl_print_string( netlister strcat( " core=" core ) )
        )
    )
)

; Used by n1port, n2port, n3port, n4port
defun(spectreNportPrim (netlister)
    cnl_print_inst( netlister )
    _spectrePrintQuotedParam(netlister "file")
    _spectrePrintQuotedParam(netlister "romdatfile")
)

defun(_print_nport_signals (netlister)
    let( ( ports port portName signal nmode portNameMinus signalMinus )
        ports = evalstring( cnl_get_param_string_value(netlister "p") )
        nmode =  cnl_get_param_string_value(netlister "nmode")
        cnl_print_string( netlister " (")
        for( port 1 ports
            portName =  sprintf( nil "p%d" port )
            signal = cnl_get_terminal_signal_name( netlister portName )
            portNameMinus = "common"
            if( nmode != "TRUE" || ports == 1 then
                portNameMinus =  sprintf( nil "m%d" port )
            )
            signalMinus = cnl_get_terminal_signal_name( netlister portNameMinus )
            cnl_print_string( netlister strcat( " " signal " " signalMinus) )
        )
        cnl_print_string( netlister ")")
    )
)

defun(_print_nport_port_types (netlister)
    let( ( ports port portTypeParamName )
        ports = evalstring( cnl_get_param_string_value(netlister "p") )
        if( ports > 20 then
            ports = 20
        )
        cnl_print_string( netlister " porttypes=[")
        for( port 1 ports
            portTypeParamName =  sprintf( nil "porttype%d" port )
            _spectrePrintRequiredParamValueOnly(netlister portTypeParamName)
        )
        cnl_print_string( netlister " ]")
    )
)

defun(_print_nport_port_quantities (netlister)
    let( ( ports port portQuantityParamName )
        ports = evalstring( cnl_get_param_string_value(netlister "p") )
        if( ports > 20 then
            ports = 20
        )
        cnl_print_string( netlister " portquantities=[")
        for( port 1 ports
            portQuantityParamName = sprintf( nil "portquantity%d" port )
            _spectrePrintRequiredParamValueOnly(netlister portQuantityParamName)
        )
        cnl_print_string( netlister " ]")
    )
)

; Used by nport
defun(_spectreNportPrimParameterizedNew (netlister)
    cnl_print_inst_name( netlister )
    _print_nport_signals( netlister )
    cnl_print_inst_model_name( netlister )
    cnl_print_inst_parameters( netlister )

    _spectrePrintQuotedParam( netlister "file" )
    _spectrePrintQuotedParam( netlister "romdatfile" )

    if( ( cnl_get_param_string_value( netlister "matrixform" ) == "yes" ) then
        _spectrePrintQuotedParam( netlister "matrixfile" )
        _print_nport_port_types(netlister)
        _print_nport_port_quantities(netlister)
    )

    if( cnl_get_param_string_value( netlister "noisecorr" ) != "real" then
        _spectrePrintQuotedParam( netlister "noisecorr" )
    )
    if( cnl_get_param_string_value( netlister "dcextrap" ) != "constant" then
        _spectrePrintParam( netlister "dcextrap" )
    )
    _spectrePrintParam( netlister "hfextrap" )
    if( cnl_get_param_string_value( netlister "passivity" ) != "check" then
        _spectrePrintParam( netlister "passivity" )
    )
    _spectrePrintParam( netlister "pabstol" )
    _spectrePrintParam( netlister "datatrunc" )
    if( cnl_get_param_string_value( netlister "causality" ) != "fmax" then
        _spectrePrintParam( netlister "causality" )
    )
    _spectrePrintQuotedParam( netlister "outFile" )

    if( ( cnl_get_param_string_value( netlister "interp" ) != "linear" ) then
        _spectrePrintParam( netlister "interp" )
    )
    if( cnl_get_param_string_value( netlister "thermalnoise" ) != "yes" then
        _spectrePrintParam( netlister "thermalnoise" )
    )

    if( additionalParam = cnl_get_param_string_value( netlister "additionalParam" ) then
        cnl_print_string( netlister strcat( " " additionalParam ) )
    )
)
