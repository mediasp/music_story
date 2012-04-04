#!/bin/bash
dir=$1
script_path=$2
json=$3

pushd $dir
. ~/.rvm/scripts/rvm
. .rvmrc
bin/msp script $script_path "$json"
popd