#!/bin/bash

pwd
echo $@
modules=()
while [[ $# -gt 0 ]] && [[ $1 != 'run' ]]; do
    key=$1
    case $key in
        -m|--modules)
            posContainer='modules'
            shift
        ;;
        *)
            if [[ $1 != -* ]]; then
                eval "$posContainer+=($1)"
                shift
            else
                echo "Unknown option: $1" 1>&2
                exit 1
            fi
    esac
done
mdir=`oc config md ./mdir`
echo "mdir=$mdir"

# Unzip in parallel
echo 'Unzip modules in parallel'
unzipProcs=()
for module in "${modules[@]}"; do
    echo "Unzipping $module"
    tar -xzf $module -C $mdir &
    unzipProcs+=($!)
done
# wait for all unzips
for pid in ${unzipProcs[*]}; do
    echo "wait for pid $pid"
    wait $pid
done
echo 'Done unzipping'
oc module ls -i
echo "TMPDIR = $TMPDIR"
export TMPDIR=/tmp
echo "TMPDIR = $TMPDIR"
oc $@