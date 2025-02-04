#!/bin/bash

file=""
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
        --file)
            file="$2"
            shift 2
            ;;
        --chr)
            chr="$2"
            shift 2
            ;;
        --start)
            start="$2"
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
            ;;
    esac
done

RITA=~/rita

dir_name=$(basename "$file" .gtf)

mkdir "$RITA"/isoforms/"$dir_name"

awk -v chr="$chr" -v start="$start" -v end="$end" -v strand="$strand" '\$1 == chr && \$4 >= start && \$5 <= end && \$7 == strand' "$file" > "$RITA"/isoforms/"$dir_name"/filtered_output.gtf

"$RITA/tools/gffread/gffread" -g "$RITA"/refs/Homo_sapiens.GRCh38.dna.toplevel.fa -w "$RITA"/isoforms/"$dir_name"/transcripts.fa "$RITA"/isoforms/"$dir_name"/filtered_output.gtf