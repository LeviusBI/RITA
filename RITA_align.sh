#!/bin/bash


F=""
R=""
threads=""
findFlag=false
noGenDir=0
srrNumber=""


usage() {
	echo "Usage: $0 -F <path to forward *.fastq> -R <path to reverse *.fastq> -S SRR number -t <number of threds to use> [-G full path to STAR genomeDir]"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -F)
            	F="$2"
            	shift 2
            	;;
    	-R)
		R="$2"
		shift 2
		;;
	-S)
		srrNumber="$2"
		shift 2
		;;		
        -t)
            	threads="$2"
            	shift 2
            	;;
        *)
            	echo "Unknown flag: $1"
            	usage
            	;;
    esac
done


echo "srrNumber: $srrNumber"
echo "threads: $threads"
echo "findFlag: $findFlag"
echo "noGenDir: $noGenDir"

RITA=~/rita

FASTERQ=$RITA/tools/sratoolkit.3.0.0-ubuntu64/bin/fasterq-dump
FASTP=$RITA/tools/fastp
STAR=$RITA/tools/STAR-2.7.11b/bin/Linux_x86_64/STAR
STRINGTIE=$RITA/tools/stringtie/stringtie

mkdir -p $RITA/reads/$srrNumber
mkdir -p $RITA/fastp_reports/$srrNumber

cp $F $RITA/reads/$srrNumber/
cp $R $RITA/reads/$srrNumber/

cd $RITA/reads/$srrNumber

for file in ./*.fastq; do
	gzip "$file"
done

CURRENT=$RITA/reads/$srrNumber
CUR_REPS=$RITA/fastp_reports/$srrNumber

file_count=$(find "$CURRENT" -maxdepth 1 -type f | wc -l)

case $file_count in
    1) 
        echo "Found 1 file, all downstream analysis will be done for one file with reads"
        $FASTP -w 16 -i "$CURRENT"/*.gz -o "$srrNumber"_TRIMMED.fastq.gz -j "$CUR_REPS"/"$srrNumber"_FASTPREP.json -h "$CUR_REPS"/"$srrNumber"_FASTPREP.html
        ;;
    2)
        echo "Found 2 files, all downstrean analysis will be done for two files with reads"
        file_list=($(find "$CURRENT" -maxdepth 1 -type f))
        $FASTP -w 16 -i ${file_list[0]} -I ${file_list[1]} -o "$srrNumber"_1_TRIMMED.fastq.gz -O "$srrNumber"_2_TRIMMED.fastq.gz -j "$CUR_REPS"/"$srrNumber"_FASTPREP.json -h "$CUR_REPS"/"$srrNumber"_FASTPREP.html
        ;;
    *)
        echo "Error: found more than 2 files, check ${CURRENT}, delete all and restart. Do fastp manually if more than 2 files"
        exit 1
        ;;
esac

 

cd $RITA/fastp_reports/$srrNumber



json_file=$(find . -type f -name "*.json" -print -quit)


numbers=($( grep 'read1_mean_length' "$json_file" | grep -o '[0-9]\{2,3\}' ))

number1=${numbers[0]}
number2=${numbers[1]}

min_number=$(( number1 < number2 ? number1 : number2 ))


READLEN=$((min_number - 1))

mkdir -p $RITA/STAR_results/$srrNumber/genomeDir

GENDIR=$RITA/STAR_results/$srrNumber/genomeDir

cd $RITA/STAR_results/$srrNumber/genomeDir

ulimit -n 65535

cd ../

ulimit -n 65535

"$STAR" --runMode genomeGenerate --runThreadN $threads --genomeDir $GENDIR --genomeFastaFiles $RITA/refs/Homo_sapiens.GRCh38.dna.toplevel.fa --sjdbGTFfile $RITA/refs/Homo_sapiens.GRCh38.113.gtf --sjdbOverhang $READLEN


"$STAR" --genomeDir $GENDIR --readFilesCommand zcat --readFilesIn $RITA/reads/$srrNumber/"$srrNumber"_1_TRIMMED.fastq.gz $RITA/reads/$srrNumber/"$srrNumber"_2_TRIMMED.fastq.gz --outSAMtype BAM SortedByCoordinate --outSAMunmapped Within --twopassMode Basic --quantMode TranscriptomeSAM --outSAMstrandField intronMotif --runThreadN "$threads"

cd $RITA

mkdir -p $RITA/stringtie_results/$srrNumber

"$STRINGTIE" -p "$threads" -G $RITA/refs/Homo_sapiens.GRCh38.113.gtf -o $RITA/stringtie_results/$srrNumber/"$srrNumber"_result.gtf $RITA/STAR_results/$srrNumber/Aligned.sortedByCoord.out.bam

"$STRINGTIE" -p "$threads" -e -G $RITA/stringtie_results/$srrNumber/"$srrNumber"_result.gtf -o $RITA/stringtie_results/$srrNumber/"$srrNumber"_result_calc_cov.gtf


