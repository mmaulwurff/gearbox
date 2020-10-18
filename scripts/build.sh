#!/bin/bash

set -e

mkdir -p build

filename=$(./scripts/make_name.sh)

rm -f "$filename"
zip -R0 "$filename" "*.md" "*.txt" "*.zs" "*.png"

~/src/build-gzdoom-Desktop-Debug/gzdoom -norun -noautoload -file "$filename" "$@"
#gzdoom -norun -noautoload -file "$filename" "$@"
