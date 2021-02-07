# Copyright 1983 Keysight Technologies, Inc 
# Implements common tcl functions to be used in iPDK

package require oa

# iPDK_getCurrentInst function was supposed to return the cdf::InstanceParameters*
# to match the cdfgData used by Virtuoso callbacks.  But Synopsys claims that
# the returned object must be an oaInst (the documentation says it can be any object).
proc iPDK_getCurrentInst {} {
    return [ads::get_current_inst_from_instance_paramters]
}

proc iPDK_getInstLibName { inst } {
        return [oa::getLibName $inst]
}

proc iPDK_getInstCellName { inst } {
        return [oa::getCellName $inst]
}

proc iPDK_engToSci { value } {
    return [ads::eng_to_sci $value]
}

proc iPDK_sciToEng { value } {
    return [ads::sci_to_eng $value]
}

proc iPDK_paramExist { param inst } {
    set paramExist [ads::parameter_exists $param $inst]
    return $paramExist
}

proc iPDK_getParamValue { param inst } {
    set paramValue [ads::get_instance_parameter_value $param $inst]
    return $paramValue
}

proc iPDK_setParamValue { param value inst eval } {
    return [ads::set_instance_parameter_value $param $value $inst $eval]
}

proc iPDK_getParamDef { attr inst param } {
    set attrVal [ads::get_instance_parameter_attribute_value $attr $inst $param]
    return $attrVal
}

# this is a mis-spelled function, required for bad iPDKs
proc iPDK_GetParamDef { attr inst param } {
    return [iPDK_getParamDef $attr $inst $param]
}

proc iPDK_getOrient { inst } {
    return [ads::get_instance_orient_name $inst]
}

proc iPDK_isLayout {} {
    set inst [iPDK_getCurrentInst]
    if {[ads::is_ipdk_layout $inst]} {
       return 1
    } else {
       return 0
    }
}

proc iPDK_isSchematic {} {
    set inst [iPDK_getCurrentInst]
    if {[ads::is_ipdk_schematic $inst]} {
        return 1
    } else {
        return 0
    }
}

proc iPDK_isIvpcell {} {
    return 0
}
