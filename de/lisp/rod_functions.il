; Copyright Keysight Technologies 2010 - 2018  
; This file contains test implementation for the rodCreateRect functions

defun(getCoordListFromBox (box )
    let( (pt1 pt2)
        pt1=nth(0 box)
        pt2=nth(1 box)
        list(nth(0 pt1) nth(1 pt1) nth(0 pt2) nth(1 pt2))
    )
)

defun(getCoordListFromWidthLengthOrigin (width length origin)
    prog( (originX originY )
        if( origin then
            originX=nth(0 origin)
            originY=nth(1 origin)
            return(list(originX originY originX+width originY+length))
        else
            return(list(0 0 width length))
        )
    )
)

;TODO: This needs to accept a name as a base name
defun(rod_name_objects_in_list (shapeList)
    ;de_information_message("rod_name_objects_in_list" strcat("shapeList: " identify_value(shapeList)))
    let( (shape rod rodList)
        while(shapeList
            shape = car(shapeList)
            shapeList = cdr(shapeList)
            rod = _rodNameObject("" shape)
            rodList = cons(rod rodList)
        )
        rodList
    )
)

defun(rodCreateRect (
    @key
    name
    layer
    width
    length
    (origin 0:0)
    bBox
    elementsX
    elementsY
    spaceX
    spaceY
    cvId
    fillBBox
    fromObj
    size
    prop
    returnBoolean
    netName
    termName
    (termIOType "inputOutput")
    pin
    (pinAccessDir "any")
    pinLabel
    (pinLabelHeight 1)
    pinLabelLayer
    (pinLabelFont "stick")
    (pinLabelDrafting t)
    (pinLabelOrient "R0")
    (pinLabelOffsetPoint 0:0)
    (pinLabelJust "centerCenter")
    (pinLabelRefHandle "centerCenter")
    subRectArray
    )
    /*de_information_message("rodCreateRect"
        strcat(
            "name: " identify_value(name) " layer: " identify_value(layer)
            " width: " identify_value(width) " length: " identify_value(length)
            " box: " identify_value(bBox)
        )
    )*/
    prog(
        (layerId coordList x1 y1 x2 y2 rect rectList rod rodList
            message term net font labelOrigin labelRefHandle
        )

        ; TODO: testcase for global pcCellView
        if(!cvId && boundp('pcCellView) then
            cvId=pcCellView
        )

        if( !cvId then
            warn("Error in rodCreateRect: cvId is not specified.")
            return(nil)
        )

        if( !layer then
            warn("Error in rodCreateRect: layer is not specified.")
            return(nil)
        )

        if( !width && !length && !bBox then
            width = techGetSpacingRule(tf "minWidth" layer)
        )

        layerId=getLayerIdFromLppArg(cvId layer)

        if( !length then length=width )
        if( !width then width=length )

        ; if bBox is specified width, length, and origin ignored
        if( bBox then
            coordList=getCoordListFromBox(bBox)
        else
            coordList=getCoordListFromWidthLengthOrigin(width length origin)
        )

        if(pin && !termName then
            return(nil)
        )
        if(netName && termName && netName != termName then
            sprintf(message "Error in rodCreateRect netName '%L' and termName '%L' must be the same. " netName termName)
            warn(message)
            return(nil)
        )
        if(termName then
            term = dbFindTermByName(cvId termName)
            if(!term then
                net = dbMakeNet(cvId termName)
                term = dbCreateTerm(net termName termIOType)
            )
        else
            if(netName then
                net = dbMakeNet(cvId netName)
            )
        )

        x1=nth(0 coordList)
        y1=nth(1 coordList)
        x2=nth(2 coordList)
        y2=nth(3 coordList)

        ; if elementsX or elementsY just create one rect
        if( !elementsX && !elementsY then
            rect = db_add_rectangle(cvId layerId x1 y1 x2 y2)
            if(rect then
                rod = _rodNameObject(name rect)
                if(pin then
                    dbCreatePin(net rect nil term)
                    if(pinLabel then
                        if(symbolp(pinLabelFont) then
                            font = symbolToString(pinLabelFont)
                        else
                            font = pinLabelFont
                        )
                        if(symbolp(pinLabelRefHandle) then
                            labelRefHandle = symbolToString(pinLabelRefHandle)
                        else
                            labelRefHandle = pinLabelRefHandle
                        )
                        labelOrigin = getSG(rod labelRefHandle)
                        dbCreateLabel(cvId layer labelOrigin termName pinLabelJust pinLabelOrient font pinLabelHeight)
                    )
                else
                    if(net then
                        rect~>net = net
                    )
                )
            )
            if(rod && returnBoolean then return(t)
            else return(rod)
            )
        else
            if( !elementsX then elementsX=1 )
            if( !elementsY then elementsY=1 )

            if( spaceX || spaceY then
                if( !spaceX then spaceX=spaceY )
                if( !spaceY then spaceY=spaceX )
                ;TODO: Do we put the entire array on the net or term?
                rectList=db_add_rectangle_array(cvId layerId x2-x1 y2-y1 spaceX spaceY elementsY elementsX origin)
                rodList=rod_name_objects_in_list(rectList)
                if(returnBoolean then return(t)
                else return(rodList)
                )
            else
                warn("Error in rodCreateRect: spaceX or spaceY must be specified.")
                return(nil)
            )
        )
        return(nil)
    )
)

defun(_rodCalcNumRects (width space boxWidth)
    /*de_information_message("_rodCalcNumRects"
        strcat(
            " width: " identify_value(width)
            " space: " identify_value(space)
            " boxWidth: " identify_value(boxWidth)
        )
    )*/
    prog( (gapCount)
        if(width >= boxWidth then return(0))
        gapCount = floor((boxWidth - width) / (width + space))
        return(gapCount+1)
    )
)

defun(rodCreatePath (
    @key
    name
    layer
    width
    pts
    justification
    offset
    endType
    beginExt
    endExt
    choppable
    cvId
    fromObj
    size
    startHandle
    endHandle
    prop
    netName
    termName
    (termIOType "inputOutput")
    pin
    (pinAccessDir "any")
    pinLabel
    (pinLabelHeight 1)
    pinLabelLayer
    (pinLabelFont "stick")
    (pinLabelDrafting t)
    (pinLabelOrient "R0")
    (pinLabelOffsetPoint 0:0)
    (pinLabelJust "centerCenter")
    (pinLabelRefHandle "centerCenter")
    offsetSubPath
    encSubPath
    subRect
    )
    /*de_information_message("rodCreatePath"
        strcat("name: " identify_value(name) " layer: " identify_value(layer)
            " width: " identify_value(width) " pts: " identify_value(pts)
        )
    )*/
    prog(
        (layerId style path rod
            message term net font labelOrigin labelRefHandle
        )

        ; TODO: testcase for global pcCellView
        if(!cvId && boundp('pcCellView) then
            cvId=pcCellView
        )

        if( !cvId then
            warn("Error in rodCreatePath: cvId is not specified.")
            return(nil)
        )

        if( !layer then
            warn("Error in rodCreatePath: layer is not specified.")
            return(nil)
        )

        if( !width then
            width = techGetSpacingRule(tf "minWidth" layer)
        )

        layerId=getLayerIdFromLppArg(cvId layer)

        if(pin && (!termName || !netName) then
            return(nil)
        )
        if(netName && termName && netName != termName then
            sprintf(message "Error in rodCreatePath netName '%L' and termName '%L' must be the same. " netName termName)
            warn(message)
            return(nil)
        )
        if(termName then
            term = dbFindTermByName(cvId termName)
            if(!term then
                net = dbMakeNet(cvId termName)
                term = dbCreateTerm(net termName termIOType)
            )
        else
            if(netName then
                net = dbMakeNet(cvId netName)
            )
        )

        style = 0 ;truncateExtend
        path = db_create_oa_path(cvId layerId width style pts)
        rod = _rodNameObject(name path)
        if(pin then
            dbCreatePin(net path nil term)
            if(pinLabel then
                if(symbolp(pinLabelFont) then
                    font = symbolToString(pinLabelFont)
                else
                    font = pinLabelFont
                )
                if(symbolp(pinLabelRefHandle) then
                    labelRefHandle = symbolToString(pinLabelRefHandle)
                else
                    labelRefHandle = pinLabelRefHandle
                )
                labelOrigin = getSG(rod labelRefHandle)
                dbCreateLabel(cvId layer labelOrigin termName pinLabelJust pinLabelOrient font pinLabelHeight)
            )
        else
            if(net then
                path~>net = net
            )
        )
        return(rod)
    )
)

defun(rodCreatePolygon (
    @key
    name
    layer
    pts
    cvId
    fromObj
    size
    prop
    netName
    termName
    (termIOType "inputOutput")
    pin
    (pinAccessDir "any")
    pinLabel
    (pinLabelHeight 1)
    pinLabelLayer
    (pinLabelFont "stick")
    (pinLabelDrafting t)
    (pinLabelOrient "R0")
    (pinLabelOffsetPoint 0:0)
    (pinLabelJust "centerCenter")
    (pinLabelRefHandle "centerCenter")
    )
    /*de_information_message("rodCreatePolygon"
        strcat("name: " identify_value(name) " layer: " identify_value(layer)
            " pts: " identify_value(pts)
        )
    )*/
    prog(
        (layerId polygon rod
            message term net font labelOrigin labelRefHandle
        )

        ; TODO: testcase for global pcCellView
        if(!cvId && boundp('pcCellView) then
            cvId=pcCellView
        )

        if( !cvId then
            warn("Error in rodCreatePolygon: cvId is not specified.")
            return(nil)
        )

        if( !layer then
            warn("Error in rodCreatePolygon: layer is not specified.")
            return(nil)
        )

        layerId=getLayerIdFromLppArg(cvId layer)

        if(pin && (!termName || !netName) then
            return(nil)
        )
        if(netName && termName && netName != termName then
            sprintf(message "Error in rodCreatePolygon netName '%L' and termName '%L' must be the same. " netName termName)
            warn(message)
            return(nil)
        )
        if(termName then
            term = dbFindTermByName(cvId termName)
            if(!term then
                net = dbMakeNet(cvId termName)
                term = dbCreateTerm(net termName termIOType)
            )
        else
            if(netName then
                net = dbMakeNet(cvId netName)
            )
        )

        polygon = dbCreatePolygon(cvId layer pts)
        rod = _rodNameObject(name polygon)
        if(pin then
            dbCreatePin(net polygon nil term)
            if(pinLabel then
                if(symbolp(pinLabelFont) then
                    font = symbolToString(pinLabelFont)
                else
                    font = pinLabelFont
                )
                if(symbolp(pinLabelRefHandle) then
                    labelRefHandle = symbolToString(pinLabelRefHandle)
                else
                    labelRefHandle = pinLabelRefHandle
                )
                labelOrigin = getSG(rod labelRefHandle)
                dbCreateLabel(cvId layer labelOrigin termName pinLabelJust pinLabelOrient font pinLabelHeight)
            )
        else
            if(net then
                polygon~>net = net
            )
        )
        return(rod)
    )
)

defun(_rodCalcNumRects (width space boxWidth)
    /*de_information_message("_rodCalcNumRects"
        strcat(
            " width: " identify_value(width)
            " space: " identify_value(space)
            " boxWidth: " identify_value(boxWidth)
        )
    )*/
    prog( (gapCount)
        if(width >= boxWidth then return(0))
        gapCount = floor((boxWidth - width) / (width + space))
        return(gapCount+1)
    )
)

defun(_rodCalcRectDistributeSpacing (count width space boxWidth grid)
    /*de_information_message("_rodCalcRectDistributeSpacing"
        strcat(
            " count: " identify_value(count)
            " width: " identify_value(width)
            " space: " identify_value(space)
            " boxWidth: " identify_value(boxWidth)
            " grid: " identify_value(grid)
        )
    )*/
    prog( (gapCount actualSpace extraSpace)
        gapCount = count-1
        actualSpace = gapCount*(width + space) + width
        extraSpace = boxWidth - actualSpace
        ;now divide the extraSpace evenly
        extraSpace = floor((extraSpace / gapCount) / grid) * grid
        /*de_information_message("_rodCalcRectDistributeSpacing End"
            strcat("extraSpace: " identify_value(extraSpace))
        )*/
        return(extraSpace)
    )
)

defun(_rodCalcRectCenterOffset (width space boxWidth)
    prog( (gapCount actualSpace extraSpace)
        if(width >= boxWidth then return(0))
        gapCount = floor((boxWidth - width) / (width + space))
        actualSpace = gapCount*(width + space) + width
        extraSpace = boxWidth - actualSpace
        ;now divide the extraSpace evenly
        return(extraSpace / 2)
    )
)

defun(rodFillBBoxWithRects (@key
        cvId
        layer
        fillBBox
        width
        length
        gap
        spaceX
        spaceY
        prop
        returnBoolean
    )
    /*de_information_message("rodFillBBoxWithRects"
        strcat(
            "layer: " identify_value(layer)
            " fillBBox: " identify_value(fillBBox)
            " width: " identify_value(width) " length: " identify_value(length)
            " spaceX: " identify_value(spaceX) " spaceY: " identify_value(spaceY)
        )
    )*/
    prog(
            (layerId llx lly urx ury x1 y1 x2 y2 xCount yCount
                tmp dmLib tech grid rect rectList
            )

        ; TODO: testcase for global pcCellView
        if(!cvId && boundp('pcCellView) then
            cvId=pcCellView
        )

        if( !cvId then
            warn("Error in rodFillBBoxWithRects: cvId is not specified.")
            return(nil)
        )

        if( !layer then
            warn("Error in rodFillBBoxWithRects: layer is not specified.")
            return(nil)
        )

        if(!fillBBox then
            warn("Error in rodFillBBoxWithRects: fillBBox is not specified.")
            return(nil)
        )

        if(!spaceX then
            warn("Error in rodFillBBoxWithRects: spaceX must be specified.")
            return(nil)
        )

        if(!spaceY then
            warn("Error in rodFillBBoxWithRects: spaceY must be specified.")
            return(nil)
        )

        if( !width && !length then
            width = techGetSpacingRule(tf "minWidth" layer)
        )

        if( !length then length=width )
        if( !width then width=length )

        if(length<=0 then
            warn("Error in rodFillBBoxWithRects: length must be positive.")
            return(nil)
        )
        if(width<=0 then
            warn("Error in rodFillBBoxWithRects: width must be positive.")
            return(nil)
        )
        if(spaceX<=0 then
            warn("Error in rodFillBBoxWithRects: spaceX must be positive.")
            return(nil)
        )
        if(spaceY<=0 then
            warn("Error in rodFillBBoxWithRects: spaceY must be positive.")
            return(nil)
        )

        layerId=getLayerIdFromLppArg(cvId layer)
        let( (pt1 pt2)
            pt1=nth(0 fillBBox)
            pt2=nth(1 fillBBox)
            llx=xCoord(pt1)
            lly=yCoord(pt1)
            urx=xCoord(pt2)
            ury=yCoord(pt2)
        )
        if(lly>ury then
            tmp = lly
            lly = ury
            ury = tmp
        )
        if(llx>urx then
            tmp = llx
            llx = urx
            urx = tmp
        )

        if(ury-lly<length then return(nil))
        if(urx-llx<width then return(nil))

        xCount = _rodCalcNumRects(width spaceX urx-llx)
        yCount = _rodCalcNumRects(length spaceY ury-lly)
        if(gap==nil || gap=="distribute" then
            tech=techGetTechFile(cvId~>lib)
            if(techIsMfgGridResolutionSet(tech) then
                grid = techGetMfgGridResolution(tech)
            else
                grid = 1 / oatech_get_db_per_uu(tech)
            )
            if(xCount<=1 then
                llx = llx + _rodCalcRectCenterOffset(width spaceX urx-llx)
            else
                spaceX = spaceX + _rodCalcRectDistributeSpacing(xCount width spaceX urx-llx grid)
            )
            if(yCount<=1 then
                lly = lly + _rodCalcRectCenterOffset(length spaceY ury-lly)
            else
                spaceY = spaceY + _rodCalcRectDistributeSpacing(yCount length spaceY ury-lly grid)
            )
        )
        if(gap=="centerMinimum" then
            llx = llx + _rodCalcRectCenterOffset(width spaceX urx-llx)
            lly = lly + _rodCalcRectCenterOffset(length spaceY ury-lly)
        )
        ;TODO: use the gap argument to decide how space should be distributed
        ;default is "distribute".  The following is "minimum".
        ;TODO: use the manufacturing grid
        y1 = lly
        for(i 1 yCount
            y2 = y1 + length
            x1 = llx
            for(j 1 xCount
                x2 = x1 + width
                rect = db_add_rectangle(cvId layerId x1 y1 x2 y2)
                ;TODO: add prop
                ;if(prop then dbReplacePropList(rect quote(prop)))
                rectList = cons(rect rectList)
                x1 = x2 + spaceX
            )
            y1 = y2 + spaceY
        )
        if(returnBoolean then return(t)
        else return(rectList)
        )
    )
)

defun(rodAlign (
        @key
        alignObj
        alignHandle
        refObj
        refHandle
        refPoint
        maintain
        xSep
        ySep
    )
    /*de_information_message("rodAlign"
        strcat(
            "alignObj: " identify_value(alignObj)
            " alignHandle: " identify_value(alignHandle)
            " refObj: " identify_value(refObj)
            " refHandle: " identify_value(refHandle)
            " refPoint: " identify_value(refPoint)
            " maintain: " identify_value(maintain)
            " xSep: " identify_value(xSep)
            " ySep: " identify_value(ySep)
        )
    )*/
    prog( (alignPoint design x y)
        ;TODO: We could set defaults for these
        if(!alignHandle then alignHandle = "centerCenter")
        if(!refHandle then refHandle = "centerCenter")
        alignPoint = getSG(alignObj alignHandle)
        if(!refPoint
            if(refObj then
                refPoint = getSG(refObj refHandle)
            else
                refPoint = list(0 0)
            )
        )
        if(!refPoint then
            warn("rodAlign: Could not get reference point from refObj.")
            return(nil)
        )
        if(!alignPoint then
            warn("rodAlign: Could not get point from alignHandle.")
            return(nil)
        )
        x=xCoord(refPoint)-xCoord(alignPoint)
        y=yCoord(refPoint)-yCoord(alignPoint)
        if(xSep then x=x+xSep)
        if(ySep then y=y+ySep)
        if(x!=0 || y!=0 then
            /*de_information_message("rodAlign move"
                strcat(
                    "x: " identify_value(x)
                    " y: " identify_value(y)
                )
            )*/
            ;TODO: Do this without changing selection
            design = alignObj~>cvId
            db_deselect_all(design)
            db_select(alignObj~>dbId)
            de_move_ex(design x y)
        )
        ;TODO: What do we return?
        return(alignObj)
    )
)

;Since we don't create any permanent alignment, rodUnAlign doesn't need to do anything
defun(rodUnAlign (rodObj1 @optional rodObj2)
    nil
)

defun(rodNameObject (@key name shapeId permitRename)
    _rodNameObject(name shapeId permitRename)
)

;TODO: Support alias
defun(rodNameShape (@key name shapeId permitRename)
    _rodNameObject(name shapeId permitRename)
)

defun(rodAddPoints (pt1 pt2)
    ;de_information_message("rodAddPoints" strcat("pt1: " identify_value(pt1) ", pt2: " identify_value(pt2)))
    let( (x y)
        x = xCoord(pt1) + xCoord(pt2)
        y = yCoord(pt1) + yCoord(pt2)
        list(x y)
    )
)

defun(rodAssignHandleToParameter (
        @key
        parameter
        rodObj
        handleName
        displayName
        displayExpression
        stretchDir
        stretchType
        moveOrigin
        updateIncrement
        userData
        userFunction
        stretchKey
        shape
    )
    ;TODO: We should issue this warning based on a policy in the PDK.
    ;warn("rodAssignHandleToParameter not implemented.")
    nil
)
