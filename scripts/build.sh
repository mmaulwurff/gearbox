#!/bin/bash

set -e

mkdir -p build

filename=$(./scripts/make_name.sh)

rm -f "$filename"
zip -R0 "$filename" "*.md" "*.txt" "*.zs" "*.png"
gzdoom -norun -noautoload -file "$filename" "$@"
