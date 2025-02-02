#!/bin/bash

mkdir ~/RITA

RITA=~/RITA

cd $RITA

mkdir refs reads tools fastp_reports STAR_results stringtie_results isoforms

cd $RITA/tools

wget --output-document sratoolkit.tar.gz https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/3.2.0/sratoolkit.3.2.0-ubuntu64.tar.gz
tar -vxzf sratoolkit.tar.gz
rm -rf sratoolkit.tar.gz

wget http://opengene.org/fastp/fastp
chmod a+x ./fastp

wget https://github.com/alexdobin/STAR/archive/2.7.11b.tar.gz
tar -xzf 2.7.11b.tar.gz
cd STAR-2.7.11b/source
make STAR
cd $RITA/tools
rm -rf 2.7.11b.tar.gz

git clone https://github.com/gpertea/stringtie
cd stringtie
make -j4 release

cd $RITA/tools

git clone https://github.com/gpertea/gffread
cd gffread
make release

cd $RITA/refs


GENOMEFA=Homo_sapiens.GRCh38.dna.toplevel.fa
GENOMEGTF=Homo_sapiens.GRCh38.113.chr_patch_hapl_scaff.gtf
GENOMEFAURL=https://ftp.ensembl.org/pub/release-113/fasta/homo_sapiens/dna/${GENOMEFA}.gz
GENOMEGTFURL=https://ftp.ensembl.org/pub/release-113/gtf/homo_sapiens/${GENOMEGTF}.gz

wget $GENOMEFAURL
wget $GENOMEGTFURL

gunzip $RITA/refs/*
