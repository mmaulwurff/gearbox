#!/bin/bash

set -e

filename=$(./scripts/make_name.sh)

gzdoom -noautoload -file "$filename" "$@"
