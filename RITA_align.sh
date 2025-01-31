#!/bin/bash

#!/bin/bash

# Set the path to the data folder, files with paired reads for Nth sample should be 
# formatted as N_anyname_R1_001.fastq.gz and N_anyname_R2_001.fastq.gz
DATA=~/GBM
# Set the path to the hg38 human genome with latest Ensembl gene set
GENOME=~/Human_genome


# FASTP 0.23.4
FASTP=~/fastp

# STAR 2.7.11b
STAR=~/STAR/bin/Linux_x86_64/STAR



GENOMEFA=Homo_sapiens.GRCh38.dna.toplevel.fa
GENOMEGTF=Homo_sapiens.GRCh38.111.chr_patch_hapl_scaff.gtf
GENOMEFAURL=https://ftp.ensembl.org/pub/release-111/fasta/homo_sapiens/dna/${GENOMEFA}.gz
GENOMEGTFURL=https://ftp.ensembl.org/pub/release-111/gtf/homo_sapiens/${GENOMEGTF}.gz

TRANSCRIPTS=gencode.v45.transcripts.fa
TRANSCRIPTSURL=https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_45/${TRANSCRIPTS}.gz
GENOMEFA=GRCh38.primary_assembly.genome.fa
GENOMEFAURL=https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_45/${GENOMEFA}.gz

# Set length of reads, in case of variable length set the maximum length
READLEN=151 
# Set number of threads used
THREADNUM=100

# Set higher ulimit for STAR BAM sorting
ulimit -n 65535

# Download and ungzip genome files
mkdir $GENOME
wget -P $GENOME $GENOMEFAURL $GENOMEGTFURL
wget -P $GENOME $TRANSCRIPTSURL $GENOMEFAURL
gunzip ${GENOME}/*



# Generate STAR genome index
$STAR --runThreadN $THREADNUM --runMode genomeGenerate --genomeDir $GENOME --genomeFastaFiles ${GENOME}/$GENOMEFA --sjdbGTFfile ${GENOME}/$GENOMEGTF --sjdbOverhang $READLEN-1

# Loop through the paired files

for f in /mnt/raid/zherem/output_2/good_trim_*.fastq #..12}
do
	# Get the file name
	xbase=${f##*/}
	R=${xbase%.*}

	# Trim the reads using fastq
	$FASTP -w $THREADNUM -i $R1 -I $R2 -o TRIMMED_${i}_R1_001.fastq.gz -O TRIMMED_${i}_R2_001.fastq.gz -j FASTP_${i}_report.json -h FASTP_${i}_report.html
	

	# Align the trimmed reads using STAR
	$STAR --runThreadN $THREADNUM --outSAMtype BAM SortedByCoordinate --genomeDir $GENOME --readFilesIn TRIMMED_${i}_R1_001.fastq.gz TRIMMED_${i}_R2_001.fastq.gz --readFilesCommand zcat --outFileNamePrefix STAR_${i}_

done