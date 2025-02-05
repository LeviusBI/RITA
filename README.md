# RITA

**R**eveal new **I**soforms by **T**ranscripts **A**lignment

# RITA_install.sh
This script creates ~/rita directory, in which all tools, references, intermediate files and result files are stored. Created dirs:

1. refs (with Human genome fasta and gff files)
2. reads (where fasterq-dump will store downloaded reads)
3. tools (where the downloaded tools are stored, list can be found below)
4. fastp_reports (for fastp reports about reads)
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

# RITA_find.sh

It takes chr number (like 1, 2, 3 etc), then start position of region of interes, the end position, then strand (+ or -) and the last argument is a '.gtf' file from RITA_align.sh. RITA_find,sh creates corresponding dir in isoforms, then it parse gtf file with awk, creating new gtf file only with those transcripts 
