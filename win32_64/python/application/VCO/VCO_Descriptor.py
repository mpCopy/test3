# Copyright Keysight Technologies 2005 - 2015  
###############################################################################
# Amplifier:<instanceName>  positive negative
#                  Vtune_Start             = (s---r)  0.0 V
#                  Vtune_Stop              = (s---r)  3.3 V
#                  Vtune_Step              = (s---r)  0.1 V
#                  Freq                    = (s---r)  1.0 GHz
#                  Order                   = (s---r)  5
#                  Noise                   = (s---b)  False
#                  OutputDatasetName       = (s---s) (None)
###############################################################################


from ADSSim_Modules import *

vtune_StartID               = 0
vtune_StopID                = 1
vtune_StepID                = 2
freqID                      = 3
orderID                     = 4
noiseID                     = 5
activateID                  = 6
modeID                      = 7
networkNameID               = 8
nodeVtuneID                 = 9
nodeVoscpID                 = 10
nodeVoscmID                 = 11
reusePreviousDataID         = 12
outputDatasetNameID         = 13

VCO_Descriptor = Descriptor("VCO")

VCO_Descriptor[vtune_StartID] = ParameterDescriptor("Vtune_Start")
VCO_Descriptor[vtune_StartID].setIsRequired(False)
VCO_Descriptor[vtune_StartID].setIsModifiable(True)
VCO_Descriptor[vtune_StartID].setIsReadable(True)
VCO_Descriptor[vtune_StartID].setDefaultValue(0.0)
VCO_Descriptor[vtune_StartID].setDataType(
    PrimitiveDataType[types.FloatType]|PrimitiveDataType[types.IntType]
    )

VCO_Descriptor[vtune_StopID] = ParameterDescriptor("Vtune_Stop")
VCO_Descriptor[vtune_StopID].setIsRequired(False)
VCO_Descriptor[vtune_StopID].setIsModifiable(True)
VCO_Descriptor[vtune_StopID].setIsReadable(True)
VCO_Descriptor[vtune_StopID].setDefaultValue(3.3)
VCO_Descriptor[vtune_StopID].setDataType(
    PrimitiveDataType[types.FloatType]|PrimitiveDataType[types.IntType]
    )

VCO_Descriptor[vtune_StepID] = ParameterDescriptor("Vtune_Step")
VCO_Descriptor[vtune_StepID].setIsRequired(False)
VCO_Descriptor[vtune_StepID].setIsModifiable(True)
VCO_Descriptor[vtune_StepID].setIsReadable(True)
VCO_Descriptor[vtune_StepID].setDefaultValue(0.1)
VCO_Descriptor[vtune_StepID].setDataType(
    PrimitiveDataType[types.FloatType]|PrimitiveDataType[types.IntType]
    )

VCO_Descriptor[freqID] = ParameterDescriptor("Freq")
VCO_Descriptor[freqID].setIsRequired(False)
VCO_Descriptor[freqID].setIsModifiable(True)
VCO_Descriptor[freqID].setIsReadable(True)
VCO_Descriptor[freqID].setDefaultValue(1.0e9)
VCO_Descriptor[freqID].setDataType(
    PrimitiveDataType[types.FloatType]|PrimitiveDataType[types.IntType]
    )


VCO_Descriptor[orderID] = ParameterDescriptor("Order")
VCO_Descriptor[orderID].setIsRequired(True)
VCO_Descriptor[orderID].setIsModifiable(True)
VCO_Descriptor[orderID].setIsReadable(True)
VCO_Descriptor[orderID].setDefaultValue(5)
VCO_Descriptor[orderID].setDataType(
    PrimitiveDataType[types.FloatType]|PrimitiveDataType[types.IntType]
    )

VCO_Descriptor[noiseID] = ParameterDescriptor("Noise")
VCO_Descriptor[noiseID].setIsRequired(False)
VCO_Descriptor[noiseID].setIsModifiable(False)
VCO_Descriptor[noiseID].setIsReadable(True)
VCO_Descriptor[noiseID].setDefaultValue(False)
VCO_Descriptor[noiseID].setDataType(
    PrimitiveDataType[types.FloatType]|PrimitiveDataType[types.IntType]
  )

VCO_Descriptor[activateID] = ParameterDescriptor("Activate")
VCO_Descriptor[activateID].setIsRequired(False)
VCO_Descriptor[activateID].setDefaultValue(True)
VCO_Descriptor[activateID].setIsModifiable(False)
VCO_Descriptor[activateID].setIsReadable(True)
VCO_Descriptor[activateID].setDataType(
    PrimitiveDataType[types.IntType]
    )

VCO_Descriptor[modeID] = ParameterDescriptor("Mode")
VCO_Descriptor[modeID].setIsRequired(False)
VCO_Descriptor[modeID].setIsModifiable(False)
VCO_Descriptor[modeID].setIsReadable(True)
VCO_Descriptor[modeID].setDefaultValue(0)
VCO_Descriptor[modeID].setDataType(
    PrimitiveDataType[types.FloatType]|PrimitiveDataType[types.IntType]
  )

VCO_Descriptor[networkNameID] = ParameterDescriptor("NetworkName")
VCO_Descriptor[networkNameID].setIsRequired(False)
VCO_Descriptor[networkNameID].setIsModifiable(False)
VCO_Descriptor[networkNameID].setIsReadable(True)
VCO_Descriptor[networkNameID].setDefaultValue(None)
VCO_Descriptor[networkNameID].setDataType(
    PrimitiveDataType[types.StringType]
  )

VCO_Descriptor[nodeVtuneID] = ParameterDescriptor("NodeVtune")
VCO_Descriptor[nodeVtuneID].setIsRequired(False)
VCO_Descriptor[nodeVtuneID].setIsModifiable(False)
VCO_Descriptor[nodeVtuneID].setIsReadable(True)
VCO_Descriptor[nodeVtuneID].setDefaultValue(None)
VCO_Descriptor[nodeVtuneID].setDataType(
    PrimitiveDataType[types.StringType]
  )

VCO_Descriptor[nodeVoscpID] = ParameterDescriptor("NodeVoscp")
VCO_Descriptor[nodeVoscpID].setIsRequired(False)
VCO_Descriptor[nodeVoscpID].setIsModifiable(False)
VCO_Descriptor[nodeVoscpID].setIsReadable(True)
VCO_Descriptor[nodeVoscpID].setDefaultValue(None)
VCO_Descriptor[nodeVoscpID].setDataType(
    PrimitiveDataType[types.StringType]
  )

VCO_Descriptor[nodeVoscmID] = ParameterDescriptor("NodeVoscm")
VCO_Descriptor[nodeVoscmID].setIsRequired(False)
VCO_Descriptor[nodeVoscmID].setIsModifiable(False)
VCO_Descriptor[nodeVoscmID].setIsReadable(True)
VCO_Descriptor[nodeVoscmID].setDefaultValue(None)
VCO_Descriptor[nodeVoscmID].setDataType(
    PrimitiveDataType[types.StringType]
  )

VCO_Descriptor[reusePreviousDataID] = ParameterDescriptor("ReusePreviousData")
VCO_Descriptor[reusePreviousDataID].setIsRequired(False)
VCO_Descriptor[reusePreviousDataID].setIsModifiable(False)
VCO_Descriptor[reusePreviousDataID].setIsReadable(True)
VCO_Descriptor[reusePreviousDataID].setDefaultValue(False)
VCO_Descriptor[reusePreviousDataID].setDataType(
    PrimitiveDataType[types.FloatType]|PrimitiveDataType[types.IntType]
  )

VCO_Descriptor[outputDatasetNameID] = ParameterDescriptor("OutputDatasetName")
VCO_Descriptor[outputDatasetNameID].setIsModifiable(False)
VCO_Descriptor[outputDatasetNameID].setIsReadable(True)
VCO_Descriptor[outputDatasetNameID].setIsRequired(False)
VCO_Descriptor[outputDatasetNameID].setDefaultValue(None)
VCO_Descriptor[outputDatasetNameID].setDataType(
    PrimitiveDataType[types.StringType]
    )









