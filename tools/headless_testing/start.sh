#!/bin/bash

# Get a list of MAP_NAMEs from filenames in ./maps/*.sd7
MAP_NAMES=($(find ./maps -name "*.sd7" -exec basename {} \; | sed 's/_/ /g'))

for MAP_NAME in "${MAP_NAMES[@]}"; do
  TEMP_FILE=$(mktemp)

  sed "s/MapName=.*?;/MapName=$MAP_NAME;/g" startscript.txt > "$TEMP_FILE"

  rm -rf $1/LuaUI/Config
  $1/engine/*/spring-headless --isolation --write-dir "$1" "$TEMP_FILE"

  rm "$TEMP_FILE"
done