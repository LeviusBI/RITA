#!/bin/bash

chr=""
start=""
end=""
strand=""

usage() {
    echo "usage: $0 --chr <> --start <xxxxxxxx> --end <xxxxxxxx> --strand <+/->"
    exit 1
}


while [[ $# -gt 0 ]]; do
    case "$1" in
        --chr)
            chr="$2"
            shift 2
            ;;
        --start)
            tstart="$2"
            shift 2
            ;;
        --end)
            end="$2"
            shift 2
            ;;
        --strand)
            strand="$2"
            shift 2
            ;;
        *)
            echo "Unknown flag: $1"
            usage
            exit 1
            ;;
    esac
done

awk '$1 
