; Copyright Keysight Technologies 2010 - 2018  
; This file contains lisp procedures that may used by standard Virtuoso artworks and customer PDKs.


defun(getLayerIdFromListArg (cv lpp)
    let( (listSize layer purpose)
        listSize=length(lpp)

        if( listSize==2 then
            layer=nth(0 lpp)
            purpose=nth(1 lpp)
        )

        if( listSize==1 then
           layer=nth(0 lpp)
           if( integerp(layer) then
               purpose=-1
           else
                purpose="drawing"
           )
        )

        if( integerp(layer) then
            db_layerid(layer purpose)
        else
            db_get_layerid(cv layer purpose)
        )
    )
)

defun(getLayerIdFromArg (cv layer)
    let( (purpose)
        if( integerp(layer) then
            purpose=-1
        else
            purpose="drawing"
        )
        if( integerp(layer) then
            db_layerid(layer purpose)
        else
            db_get_layerid(cv layer purpose)
        )
    )
)

defun(getLayerIdFromLppArg (cv lpp)
    let( (isListlpp )
        isListlpp=listp(lpp)
        if( isListlpp then
            getLayerIdFromListArg(cv lpp)
        else
            getLayerIdFromArg(cv lpp)
        )
    )
)

;Function dbCreateRect
;dbCreateRect(d_cellView (tx_layer[t_purpose]) l_bBox)

defun(dbCreateRect (cv lpp bbox )
    let( (layerId pt1 pt2 x1 y1 x2 y2 )

        layerId=getLayerIdFromLppArg(cv lpp)

        pt1=nth(0 bbox)
        pt2=nth(1 bbox)
        x1=nth(0 pt1)
        y1=nth(1 pt1)
        x2=nth(0 pt2)
        y2=nth(1 pt2)

        db_add_rectangle(cv layerId x1 y1 x2 y2)
    )
)

;Function dbCreateEllipse
;dbCreateEllipse(d_cellView (tx_layer[t_purpose]) l_bBox)

defun(dbCreateEllipse (cv lpp bbox )
    let( (layerId pt1 pt2 x1 y1 x2 y2 )

        layerId=getLayerIdFromLppArg(cv lpp)

        pt1=nth(0 bbox)
        pt2=nth(1 bbox)
        x1=nth(0 pt1)
        y1=nth(1 pt1)
        x2=nth(0 pt2)
        y2=nth(1 pt2)

        db_add_ellipse(cv layerId x1 y1 x2 y2)
    )
)

;Function dbCreateLine
;dbCreateLine(d_cellView (tx_layer[t_purpose]) l_points)

defun(dbCreateLine (cv lpp points )
    let( (layerId )

        layerId=getLayerIdFromLppArg(cv lpp)
        db_create_line_from_points(cv layerId points)
    )
)

defun(getPathStyleFromArg (pathStyle)
    (case pathStyle
        ("truncateExtend" 0)
        ("extendExtend" 1)
        ("round" 2)
        ("variable" 3)
        (t 0)
    )
)

;Function dbCreatePath
;dbCreatePath(d_cellView (tx_layer[t_purpose]) l_points x_width [t_pathStyle])

defun(dbCreatePath (cv lpp points width @optional (pathStyle "truncateExtend"))
    let( (layerId style)

        layerId=getLayerIdFromLppArg(cv lpp)
        style=getPathStyleFromArg(pathStyle)
        db_create_oa_path(cv layerId width style points)
    )
)

;Function dbCreateTerm
;dbCreateTerm( d_net t_name t_direction [unused [physOnly]])

defun(dbCreateTerm (net termName termDirection @optional unused physOnly)
    db_create_term_by_name(net termName termDirection)
)

;Function dbCreatePin
;dbCreatePin( d_net d_fig [t_name [d_term]])

defun(dbCreatePin (net pinFig @optional pinName term)
    db_create_pin_for_pin_fig(net pinFig pinName)
)

defun(dbFindTermByName (cv name)
    db_find_term_by_name(cv name)
)
