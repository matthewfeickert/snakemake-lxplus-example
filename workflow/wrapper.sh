#!/usr/bin/env bash

set -e
export HOME=$(pwd)
snakemake "$@"
