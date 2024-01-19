#!/bin/bash

rm -rf ./LuaUI/Config
"$1/engine/*/spring-headless" --isolation --write-dir "$1" "$1/startscript.txt"