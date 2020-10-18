#!/bin/bash

set -e

filename=$(./scripts/make_name.sh)

~/src/build-gzdoom-Desktop-Debug/gzdoom -noautoload -file "$filename" "$@"
#gzdoom -noautoload -file "$filename" "$@"
