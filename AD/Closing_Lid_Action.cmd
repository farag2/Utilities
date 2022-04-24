:: Do nothing when lid is closed

:: Set Balanced battery scheme due to Santosh broken something in the MC's battery scheme
POWERCFG /SETACTIVE SCHEME_BALANCED

:: 0 is the "Do nothing" action
:: While working on battery
POWERCFG /SETACVALUEINDEX SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
:: While being plugged in
POWERCFG /SETDCVALUEINDEX SCHEME_CURRENT SUB_BUTTONS LIDACTION 0
:: Apply changes
POWERCFG /SetActive SCHEME_CURRENT

: Whithout using aliases
:: POWERCFG /SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
:: POWERCFG /SETACVALUEINDEX SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
