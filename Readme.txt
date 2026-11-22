Human RNA-seq analysis with Snakemake
=====================================

1. DESCRIPTION
Alignment-based (HISAT2 + featureCounts) and alignment-free (kallisto)
quantification of human RNA-seq data, with QC (FastQC, RSeQC, deepTools)
and MultiQC reporting.

2. DATA
Series: GSE52778 (SRA project SRP033351), Homo sapiens, Illumina HiSeq 2000, paired-end.
Samples: SRR1039508 (GSM1275862), SRR1039512 (GSM1275866),
         SRR1039513 (GSM1275867), SRR1039514 (GSM1275868)
Submitted to GEO: 26 Nov 2013 (last updated 13 Jan 2023) by Blanca E. Himes,
University of Pennsylvania, Department of Biostatistics, Epidemiology and Informatics.
Contributors: Himes B, Lu Q.

Original publication:
Himes BE, Jiang X, Wagner P, Hu R et al. RNA-Seq transcriptome profiling identifies
CRISPLD2 as a glucocorticoid responsive gene that modulates cytokine function in
airway smooth muscle cells. PLoS One 2014;9(6):e99625. PMID: 24926665

Later paper that also uses this series:
Panganiban RAM, Yang Z, Sun M, Park CY et al. Antagonizing cholecystokinin A receptor
in the lung attenuates obesity-induced airway hyperresponsiveness.
Nat Commun 2023;14(1):47. PMID: 36599824

Samples (SRR / donor / treatment):
SRR1039508  N61311   untreated
SRR1039512  N052611  untreated
SRR1039513  N052611  dexamethasone
SRR1039514  N052611  albuterol

3. CONTROL AND TREATMENT
Control: Two samples are airway smooth muscle cells that received no drug
(donors N61311 and N052611). They show the normal, baseline gene activity of
these cells, so every treated sample is compared against them.

Treatment: Two samples are cells from donor N052611 that were treated for 18
hours with 1 uM of a drug. One got dexamethasone, a glucocorticoid that reduces
inflammation. The other got albuterol, a beta2-agonist that relaxes airway muscle.

Why interesting: Both drugs are used to treat asthma, and airway smooth muscle
is one of the tissues they act on. Comparing treated cells to untreated cells
shows which genes each drug switches on or off, which helps explain how the
drugs work and why patients can respond differently.

Limitation: There is only one sample per treatment, and only one donor has all
three conditions, so the treatments have no replicates and differences may
partly come from donor variation instead of the drug.

4. REFERENCE (GENCODE release 50, GRCh38)
Primary assembly genome, comprehensive GTF and transcripts FASTA from the same release.

5. REQUIREMENTS
Conda (Miniconda), Snakemake 9.27.2 with snakemake-executor-plugin-slurm 2.8.0, pandas.
All other tools are installed per rule from envs/*.yaml.

6. RUN
  bash scripts/download_data.sh
  bash scripts/reference.sh
  snakemake -s workflow/Snakefile -n --rerun-triggers mtime
  snakemake -s workflow/Snakefile --use-conda --executor slurm --jobs 30 \
    --latency-wait 60 --rerun-triggers mtime \
    --default-resources slurm_partition=main mem_mb=4000 runtime=120
Edit config/config.yaml and config/samples.tsv to analyse other same-style data.

7. STRUCTURE
config/    config.yaml, samples.tsv
envs/      Conda environments
scripts/   download scripts
workflow/  Snakefile and rule files
