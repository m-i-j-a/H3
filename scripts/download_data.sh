#!/bin/bash
#SBATCH --job-name=data
#SBATCH --mem=2G
#SBATCH --time=04:00:00
#SBATCH --output=/dev/null
set -euo pipefail
cd "${SLURM_SUBMIT_DIR:-$PWD}"
mkdir -p data
cd data
for GSM in GSM1275862 GSM1275866 GSM1275867 GSM1275868; do
  curl -sf "https://www.ebi.ac.uk/ena/portal/api/search?result=read_run&query=sample_alias=%22${GSM}%22&fields=fastq_ftp,fastq_md5&format=tsv&limit=0" \
    | tail -n +2 | while IFS=$'\t' read -r FTP MD5; do
        IFS=';' read -ra URLS <<< "$FTP"
        IFS=';' read -ra SUMS <<< "$MD5"
        for i in "${!URLS[@]}"; do
          wget -c -q "https://${URLS[$i]}"
          echo "${SUMS[$i]}  $(basename "${URLS[$i]}")" >> md5_check.txt
          md5sum -c --quiet <<< "${SUMS[$i]}  $(basename "${URLS[$i]}")"
        done
      done
done
