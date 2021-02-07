; Copyright 2004 - 2014 Keysight Technologies, Inc  
rfdeExprAddMeasurement(
  ?type 'Env
  ?name "Spectrum analyzer"
  ?params list(
    list( 'signal
      list(
        ?name "RF"
        ?prompt "RF Voltage/Current"
      )
    )
    list( 'string
      list(
        ?name "FCarrier"
        ?prompt "Carrier Frequency (Hz)"
        ?optional t
        ?defValue "0.0 Hz"
      )
    )
    list( 'string
      list(
        ?name "Start"
        ?prompt "Start Time (sec)"
        ?optional t
        ?defValue "0.0"
      )
    )
    list( 'string
      list(
        ?name "Stop"
        ?prompt "Stop Time (sec)"
        ?optional t
        ?defValue "1.0 msec"
      )
    )
    list( 'selection
      list(
        ?name "Window"
        ?prompt "Window "
        ?choices '( "none" "Hamming 0.54" "Hanning 0.50" "Gaussian 0.75" "Kaiser 7.865" "_8510 6.0" "Blackman" "Blackman-Harris"  "Enter option index" )
        ?optional t
        ?defValue "none"
      )
    )
    list( 'string
      list(
        ?name "ResBW"
        ?prompt "Resolution Bandwidth (Hz)"
        ?optional t
        ?defValue "0.0"
      )
    )
  )
  ?ael "spectrum_analyzer($1[1], $2, $3, $4, \"$5\", $6)"
)
rfdeExprAddMeasurement(
  ?type 'Env
  ?name "Voltage Difference Spectrum analyzer"
  ?params list(
    list( 'voltage
      list(
        ?name "RF"
        ?prompt "RF Positive Voltage"
      )
    )
    list( 'voltage
      list(
        ?name "RF"
        ?prompt "RF Negative Voltage"
      )
    )
    list( 'string
      list(
        ?name "FCarrier"
        ?prompt "Carrier Frequency (Hz)"
        ?optional t
        ?defValue "0.0 Hz"
      )
    )
    list( 'string
      list(
        ?name "Start"
        ?prompt "Start Time (sec)"
        ?optional t
        ?defValue "0.0"
      )
    )
    list( 'string
      list(
        ?name "Stop"
        ?prompt "Stop Time (sec)"
        ?optional t
        ?defValue "1.0 msec"
      )
    )
    list( 'selection
      list(
        ?name "Window"
        ?prompt "Window "
        ?choices '( "none" "Hamming 0.54" "Hanning 0.50" "Gaussian 0.75" "Kaiser 7.865" "_8510 6.0" "Blackman" "Blackman-Harris"  "Enter option index" )
        ?optional t
        ?defValue "none"
      )
    )
    list( 'string
      list(
        ?name "ResBW"
        ?prompt "Resolution Bandwidth (Hz)"
        ?optional t
        ?defValue "0.0"
      )
    )
  )
  ?ael "spectrum_analyzer(($1[1]-$2[1]), $3, $4, $5, \"$6\", $7)"
)
