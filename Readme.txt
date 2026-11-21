H3: RNA-seq pipeline for SRR1039508, SRR1039512, SRR1039513, SRR1039514.

Structure:
- scripts/download_data.sh — fetch raw FASTQs from ENA
- scripts/reference.sh — download GRCh38 genome + GENCODE v50 annotation/transcripts
- config/ — pipeline parameters and sample sheet (rebuilt)
- workflow/ — Snakefile + rule modules (rebuilt)
- envs/ — conda environment specs per step (rebuilt)
- data/, reference/, results/, logs/ — ignored, regenerated locally

Run with: snakemake -s workflow/Snakefile --profile slurm
