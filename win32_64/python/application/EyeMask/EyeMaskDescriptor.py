# Copyright Keysight Technologies 2009 - 2015  
from ADSSim_Modules import *

FileNameID = 0
NameID     = 1
EyeMask_Descriptor = Descriptor("EyeMask")

EyeMask_Descriptor[FileNameID] = ParameterDescriptor("FileName")
EyeMask_Descriptor[FileNameID].setIsRequired(True)
EyeMask_Descriptor[FileNameID].setIsModifiable(False)
EyeMask_Descriptor[FileNameID].setIsReadable(True)
EyeMask_Descriptor[FileNameID].setDataType(
    PrimitiveDataType[types.StringType]
    )

EyeMask_Descriptor[NameID] = ParameterDescriptor("Name")
EyeMask_Descriptor[NameID].setIsRequired(True)
EyeMask_Descriptor[NameID].setIsModifiable(False)
EyeMask_Descriptor[NameID].setIsReadable(True)
EyeMask_Descriptor[NameID].setDataType(
    PrimitiveDataType[types.StringType]
    )
