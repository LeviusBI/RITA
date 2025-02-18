# RITA

**R**eveal **I**soforms by **T**ranscripts **A**lignment

# RITA_install.sh
This script creates ~/rita directory, in which all tools, references, intermediate files and result files are stored. Created dirs:

1. refs (with Human genome fasta and gff files)
2. reads (where fasterq-dump will store downloaded reads)
3. tools (where the downloaded tools are stored, list can be found below)
4. fastp_reports (for fastp reports made on reads)
5. STAR_results (for each SRR you can find here dir containing STAR_genome and alignments)
6. stringtie_results (outputs of stringtie)
7. isoforms (fasta files from gffread with sequences of found (not always new) transcripts)

This script downloads tools:

1. [fastp](https://github.com/OpenGene/fastp)
2. [sratools/fasterq-dump](https://github.com/ncbi/sra-tools/wiki/HowTo:-fasterq-dump)
3. [STAR](https://github.com/alexdobin/STAR/tree/master)
4. [stringtie](https://github.com/gpertea/stringtie)
5. [gffread](https://github.com/gpertea/gffread)

Reference genome:

1. GENOMEFA: https://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/Homo_sapiens.GRCh38.dna.toplevel.fa.gz
2. GENOMEGTF: https://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/Homo_sapiens.GRCh38.113.gtf.gz

# RITA_align.sh
It takes paths to forward and reverse reads (separetely) via -F (for forward *.fastq) and -R (for reverse *.fastq). Than you might enter their SRR (or just specify how you would like to name the directories for these reads) after -S flag. Then input -t and number of threads. There are no default values for flags. 

Example of usage
```
./RITA_align.sh -F SRR123456_R1.fastq -R SRR123456_R2.fastq -S SRR123456 -t 32
```
First it will create ```$srrNumber``` directory in reads and fastp_reports dirs. It will copy your reads to ```~/RITA/reads```, and gzip them. Then it creates fastp reports, running fastp on gzipped reads. Then the json report file is parsed to find average read length after trimming. Using this value, STAR in genomeGenerate mode runs. Then the script uses STAR in twoPassMode Basic to find and include new splice junctions. It finds not only new isoforms, it finds all including new. Then the stringtie is used to make gtf file with annotation of alignments from second run of STAR. You can find all files in corresponding directories when the script stops.  

# RITA_find.sh

It takes chr number (like 1, 2, 3 etc), then start position of region of interes, the end position, then strand (+ or -) and the last argument is a '.gtf' file from RITA_align.sh. RITA_find,sh creates corresponding dir in isoforms, then it parse gtf file with awk, creating new gtf file only with those transcripts which are into the region of interest. Then it uses gffread to convert them into nucleotide sequences from reference genome in ~RITA/isoforms/$dir_name/transcripts.fa file.
