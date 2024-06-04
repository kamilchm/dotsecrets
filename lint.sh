#!/usr/bin/env nix-shell
#!nix-shell -p shellcheck
##shellcheck shell=bash

set -euo pipefail

shellcheck dotsecrets tests.sh
