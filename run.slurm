#!/bin/bash
#SBATCH --job-name=H3_rnaseq
#SBATCH --output=logs/slurm_H3_rnaseq_%j.out
#SBATCH --time=72:00:00
#SBATCH --mem=40G
#SBATCH --cpus-per-task=16

export PATH="/scratch/lustre/home/miju1289/miniconda3/envs/snakemake/bin:$PATH"
export LD_LIBRARY_PATH="/scratch/lustre/home/miju1289/miniconda3/envs/snakemake/lib:$LD_LIBRARY_PATH"
mkdir -p logs results/logs

snakemake -s workflow/Snakefile \
    --jobs 16 \
    --rerun-triggers mtime \
    --latency-wait 120 \
    --keep-going \
    --use-conda \
    --rerun-incomplete
