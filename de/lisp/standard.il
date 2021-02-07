; Copyright Keysight Technologies 2014 - 2018  
; This file contains lisp procedures that may used by standard Virtuoso libraries and customer PDKs.

;isCallable does not support auto-loading of functions
defun(isCallable ( function )
    fboundp( function )
)

defun(caaaar (val)
    car(car(car(car(val))))
)

defun(caaadr (val)
    car(car(car(cdr(val))))
)

defun(caadar (val)
    car(car(cdr(car(val))))
)

defun(caaddr (val)
    car(car(cdr(cdr(val))))
)

defun(cadaar (val)
    car(cdr(car(car(val))))
)

defun(cadadr (val)
    car(cdr(car(cdr(val))))
)

defun(caddar (val)
    car(cdr(cdr(car(val))))
)

defun(cadddr (val)
    car(cdr(cdr(cdr(val))))
)

defun(cdaaar (val)
    cdr(car(car(car(val))))
)

defun(cdaadr (val)
    cdr(car(car(cdr(val))))
)

defun(cdadar (val)
    cdr(car(cdr(car(val))))
)

defun(cdaddr (val)
    cdr(car(cdr(cdr(val))))
)

defun(cddaar (val)
    cdr(cdr(car(car(val))))
)

defun(cddadr (val)
    cdr(cdr(car(cdr(val))))
)

defun(cdddar (val)
    cdr(cdr(cdr(car(val))))
)

defun(cddddr (val)
    cdr(cdr(cdr(cdr(val))))
)

defun(caaar (val)
    car(car(car(val)))
)

defun(caadr (val)
    car(car(cdr(val)))
)

defun(cadar (val)
    car(cdr(car(val)))
)

defun(caddr (val)
    car(cdr(cdr(val)))
)

defun(cdaar (val)
    cdr(car(car(val)))
)

defun(cdadr (val)
    cdr(car(cdr(val)))
)

defun(cddar (val)
    cdr(cdr(car(val)))
)

defun(cdddr (val)
    cdr(cdr(cdr(val)))
)

defun(caar (val)
    car(car(val))
)

defun(cadr (val)
    car(cdr(val))
)

defun(cdar (val)
    cdr(car(val))
)

defun(cddr (val)
    cdr(cdr(val))
)

defun(evenp (num)
    let(((status nil))
        if( fixp( num ) && (mod( num 2 ) == 0) then
            status=t
        )
        status
    )
)

defun(oddp (num)
    let(((status nil))
        if( fixp( num ) && (mod( num 2 ) == 1) then
            status=t
        )
        status
    )
)

defun(warn (@rest args)
    let((output sprintfArgs)
        sprintfArgs=list( 'sprintf nil )
        sprintfArgs=append( sprintfArgs args )
        output=eval( sprintfArgs )
        if( stringp( output ) then
            output=strcat( "*WARNING* " output )
        else
            output="*WARNING* "
        )
        ui_add_to_message_list_window(output)
        nil
    )
)

; Used by Virtuoso libraries

defun(artWarn (@rest args)
    apply( warn args)
)

defun(artBlankString (string)
    ; TODO: Allow any number of spaces (either use AEL or add string support to Lisp)
    if( string == nil || string == "" || string == " " || string == "  " then
        t
    else
        nil
    )
)
