#!/bin/bash

#!/bin/bash

# Инициализация переменных
srrNumber=""
threads=""
findFlag=false
existingFlag=false
notDownloadFlag=false
noGenDir=""
r1=""
r2=""

# Функция для вывода справки
usage() {
    echo "Использование: $0 --srrNumber <номер> --threads <количество> [--find] [--existing] [--notDownload -r1 <файл1> -r2 <файл2>] [--noGen <директория>]"
    exit 1
}

# Обработка аргументов
while [[ $# -gt 0 ]]; do
    case "$1" in
        --srrNumber)
            srrNumber="$2"
            shift 2
            ;;
        --threads)
            threads="$2"
            shift 2
            ;;
        --find)
            findFlag=true
            shift
            ;;
        --existing)
            existingFlag=true
            shift
            ;;
        --notDownload)
            notDownloadFlag=true
            shift
            r1="$1"
            shift
            r2="$1"
            shift
            ;;
        --noGen)
            noGenDir="$2"
            shift 2
            ;;
        *)
            echo "Unknown flag: $1"
            usage
            exit 1
            ;;
    esac
done

# Проверка обязательных флагов
if [[ -z "$srrNumber" || -z "$threads" ]]; then
    echo "Ошибка: обязательные флаги --srrNumber и --threads должны быть указаны."
    usage
fi

# Проверка флага --noGen
if [[ -n "$noGenDir" && ! -d "$noGenDir" ]]; then
    echo "Ошибка: указанный путь для --noGen не является директорией."
    exit 1
fi

# Проверка флага --notDownload
if $notDownloadFlag; then
    if [[ -z "$r1" || -z "$r2" ]]; then
        echo "Ошибка: при использовании --notDownload необходимо указать -r1 и -r2."
        exit 1
    fi
fi

# Вывод значений флагов для проверки
echo "srrNumber: $srrNumber"
echo "threads: $threads"
echo "findFlag: $findFlag"
echo "existingFlag: $existingFlag"
echo "notDownloadFlag: $notDownloadFlag"
echo "noGenDir: $noGenDir"
echo "r1: $r1"
echo "r2: $r2"

RITA=~/rita

FASTERQ=$RITA/tools/sratoolkit.3.2.0-ubuntu64/bin/fasterq-dump
FASTP=$RITA/tools/fastp
STAR=$RITA/tools/STAR-2.7.11b/bin/Linux_x86_64/STAR
STRINGTIE=$RITA/tools/stringtie/stringite

mkdir $RITA/reads/$srrNumber
mkdir $RITA/fastp_reports/$srrNumber

$FASTERQ -p --split-files $srrNumber -O $RITA/reads/$srrNumber

cd $RITA/reads/$srrNumber

gzip $RITA/reads/$srrNumber/*

CURRENT=$RITA/reads/$srrNumber
CUR_REPS=$RITA/fastp_reports/$srrNumber

file_count=$(find "$CURRENT" -maxdepth 1 -type f | wc -l)

case $file_count in
    1) 
        echo "Found 1 file, all downstream analysis will be done for one file with reads"
        $FASTP -w 16 -i "$CURRENT"/*.gz -o "$srrNumber"_TRIMMED.fastq.gz -j "$CUR_REPS"/"$srrNumber"_FASTPREP.json -h "$CUR_REPS"/"$srrNumber"_FASTPREP.html
        rm -rf !("$CURRENT"/"$srrNumber"_TRIMMED.fastq.gz)
        ;;
    2)
        echo "Found 2 files, all downstrean analysis will be done for two files with reads"
        file_list=($(find "$CURRENT" -maxdepth 1 -type f))
        $FASTP -w 16 -i ${file_list[0]} -I ${file_list[1]} -o "$srrNumber"_1_TRIMMED.fastq.gz -O "$srrNumber"_2_TRIMMED.fastq.gz -j "$CUR_REPS"/"$srrNumber"_FASTPREP.json -h "$CUR_REPS"/"$srrNumber"_FASTPREP.html
        rm -rf !("$CURRENT"/"$srrNumber"_?_TRIMMED.fastq.gz)
        ;;
    *)
        echo "Error: found more than 2 files, check ${CURRENT}, delete all and restart. Do fastp manually if more than 2 files"
        exit 1
        ;;
esac

$FASTP -i 

json_rep=$RITA/fastp_reports/$srrNumber/${srrNumber}_FASTPREP.json

numbers=($( grep 'read1_mean_length' $json_rep | grep -o '[0-9]\{2,3\}' ))

number1=${numbers[0]}
number2=${numbers[1]}

min=$(( number1 < number2 ? number1 : number2 ))


READLEN=$((min_number - 1))

mkdir -p "$RITA"/STAR_results/"$srrNumber"/genomeDir

GENDIR="$RITA"/STAR_results/"$srrNumber"/genomeDir

gunzip "$RITA"/refs/*

ulimit -n 65535



"$STAR" --runMode genomeGenerate --runThreadN "$threads" --genomeDir "$GENDIR" --genomeFastaFiles "$RITA"/refs/Homo_sapiens.GRCh38.dna.toplevel.fa --sjdbGTFfile "$RITA"/refs/Homo_sapiens.GRCh38.113.gtf --sjdbOverhang $READLEN

cd "$RITA"/STAR_restults/"$srrNumber"

"$STAR" --genomeDir "$GENDIR" --outFileNamePrefix "$srrNumber" --readFilesCommand zcat --readFilesIn "$RITA"/reads/"$srrNumber"/*_1_TRIMMED.fastq.gz "$RITA"/reads/"$srrNumber"/*_2_TRIMMED.fastq.gz --outSAMtype BAM SortedByCoordinate --limitBAMsortRAM 16000000000 --outSAMunmapped Within --twopassMode Basic --quantMode TranscriptomeSAM --outSAMstrandField intronMotif --runThreadN $threads

cd $RITA

$STRINGTIE


