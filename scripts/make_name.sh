#!/bin/bash

set -e

filename=build/gearbox-$(git describe --abbrev=0 --tags).pk3
echo "$filename"
