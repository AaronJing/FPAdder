
#!/bin/bash

CONFIGS=(
  "8" "23" "0" "0"
  "8" "23" "0" "1" # unsigned
  "8" "23" "1" "0" # no round
  "8" "23" "1" "1" # unsigned & no round

)

CONFIG_LEN=4 # Number of arguments in each config

for ((i=0; i<${#CONFIGS[@]}; i+=CONFIG_LEN)); do
  SBT_CMD="runMain unsignedfpadder.VerilogMain ${CONFIGS[@]:$i:$CONFIG_LEN}"
  sbt "${SBT_CMD}"
done