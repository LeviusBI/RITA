#!/bin/bash

srrNumber=""
findFlag=false
existingFlag=false
notDownloadFlag=false
r1=""
r2=""
noGgen=false

RITA=~/RITA
usage() {
    echo "usage: $0 --srrNumber <SRA number> [--find] [--existing] [--notDownload] [-r1 <*.fastq.gz>] [-r2 <fastq.gz>]"
    echo "  --srrNumber <number>   (obligatory) SRA id to download via fasterq-dump, create folders for fastp reports and STAR alignments"
    echo "  --find                Starts RITA_find.sh by the end of RITA_align.sh script"
    echo "  --existing            Use this flag to specify that you want to find only existing isoforms"
    echo "  --notDownload         Use this flag if you have already downloaded your data and you want to skip downloading stage"
    echo "  -r1 <*.fastq.gz>            Only with --nowDownload flag: "
    echo "  -r2 <*.fastq.gz>            Указывает второй файл."
    echo "  --noGgen              Use this if you do not want to generate new Genome
     (only in cases if you know that length of reads is equal in all your fastq files)"
    exit 1
}

if [[ $# -eq 0 ]]; then
    usage
fi


while [[ $# -gt 0 ]]; do
    case "$1" in
        --srrNumber)
            srrNumber="$2"
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
            ;;
        -r1)
            r1="$2"
            shift 2
            ;;
        -r2)
            r2="$2"
            shift 2
            ;;
        *)
            echo "Неизвестный флаг: $1"
            usage
            ;;
    esac
done

# Проверка обязательного флага
if [[ -z "$srrNumber" ]]; then
    echo "Ошибка: флаг --srrNumber обязателен."
    usage
fi



FASTERQ=$RITA/tools/sratoolkit.3.2.0-ubuntu64/bin/fasterq-dump
FASTP=$RITA/tools/fastp
STAR=$RITA/tools/STAR-2.7.11b/bin/Linux_x86_64/STAR
STRINGTIE=$RITA/tools/

mkdir $RITA/reads/$srrNumber
$FASTERQ --split-files $srrNumber -O $RITA/reads/$srrNumber

cd $RITA/reads/$srrNumber

$FASTP -i 

json_rep=$RITA/fastp_reports/$srrNumber/FASTP_${srrNumber}_report.json

numbers=($( grep 'read1_mean_length' $json_rep | grep -o '[0-9]\{2,3\}' ))

number1=${numbers[0]}
number2=${numbers[1]}

min=$(( number1 < number2 ? number1 : number2 ))


READLEN=$((min_number - 1))

# # FASTP 0.23.4
# FASTP=~/fastp

# # STAR 2.7.11b
# STAR=~/STAR/bin/Linux_x86_64/STAR



# GENOMEFA=Homo_sapiens.GRCh38.dna.toplevel.fa
# GENOMEGTF=Homo_sapiens.GRCh38.111.chr_patch_hapl_scaff.gtf
# GENOMEFAURL=https://ftp.ensembl.org/pub/release-111/fasta/homo_sapiens/dna/${GENOMEFA}.gz
# GENOMEGTFURL=https://ftp.ensembl.org/pub/release-111/gtf/homo_sapiens/${GENOMEGTF}.gz

# TRANSCRIPTS=gencode.v45.transcripts.fa
# TRANSCRIPTSURL=https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_45/${TRANSCRIPTS}.gz
# GENOMEFA=GRCh38.primary_assembly.genome.fa
# GENOMEFAURL=https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_45/${GENOMEFA}.gz

# # Set length of reads, in case of variable length set the maximum length
# READLEN=151 
# # Set number of threads used
# THREADNUM=100

# # Set higher ulimit for STAR BAM sorting
# ulimit -n 65535

# # Download and ungzip genome files
# mkdir $GENOME
# wget -P $GENOME $GENOMEFAURL $GENOMEGTFURL
# wget -P $GENOME $TRANSCRIPTSURL $GENOMEFAURL
# gunzip ${GENOME}/*



# # Generate STAR genome index
# $STAR --runThreadN $THREADNUM --runMode genomeGenerate --genomeDir $GENOME --genomeFastaFiles ${GENOME}/$GENOMEFA --sjdbGTFfile ${GENOME}/$GENOMEGTF --sjdbOverhang $READLEN-1

# # Loop through the paired files

# for f in /mnt/raid/zherem/output_2/good_trim_*.fastq #..12}
# do
# 	# Get the file name
# 	xbase=${f##*/}
# 	R=${xbase%.*}

# 	# Trim the reads using fastq
# 	$FASTP -w $THREADNUM -i $R1 -I $R2 -o TRIMMED_${i}_R1_001.fastq.gz -O TRIMMED_${i}_R2_001.fastq.gz -j FASTP_${i}_report.json -h FASTP_${i}_report.html
	

# 	# Align the trimmed reads using STAR
# 	$STAR --runThreadN $THREADNUM --outSAMtype BAM SortedByCoordinate --genomeDir $GENOME --readFilesIn TRIMMED_${i}_R1_001.fastq.gz TRIMMED_${i}_R2_001.fastq.gz --readFilesCommand zcat --outFileNamePrefix STAR_${i}_

# done