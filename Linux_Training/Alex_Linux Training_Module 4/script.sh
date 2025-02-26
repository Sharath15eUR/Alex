#!/bin/bash

input="$1"
output="output.txt"

while IFS= read -r line; do
  if [[ "$line" == *"frame.time"* && "$line" != *"frame.time_"* || "$line" == *"wlan.fc.type"* && "$line" != *"wlan.fc.type_"* || "$line" == *"wlan.fc.subtype"* ]]; then
    param=$(echo "$line" | awk -F': ' '{print $1}' | xargs)
    value=$(echo "$line" | awk -F': ' '{print $2}' | xargs)
    echo "$param : $value" >> "$output"
  fi
done < "$input"