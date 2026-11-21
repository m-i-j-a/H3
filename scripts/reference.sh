#!/bin/bash
#SBATCH --job-name=ref
#SBATCH --cpus-per-task=1
#SBATCH --mem=4G
#SBATCH --time=02:00:00
#SBATCH --output=/dev/null
set -euo pipefail
cd "${SLURM_SUBMIT_DIR:-$PWD}"
BASE="https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_50"
mkdir -p reference
cd reference
wget -c -q "${BASE}/GRCh38.primary_assembly.genome.fa.gz"
wget -c -q "${BASE}/gencode.v50.primary_assembly.annotation.gtf.gz"
wget -c -q "${BASE}/gencode.v50.transcripts.fa.gz"
wget -q -O MD5SUMS "${BASE}/MD5SUMS"
md5sum -c --ignore-missing MD5SUMS > md5_check.txt
gunzip -f *.gz
