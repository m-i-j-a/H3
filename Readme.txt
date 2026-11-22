cat > Readme.txt << 'EOF'
Human RNA-seq analysis with Snakemake
=====================================

1. DESCRIPTION
Alignment-based (HISAT2 + featureCounts) and alignment-free (kallisto)
quantification of human RNA-seq data, with QC (FastQC, RSeQC, deepTools)
and MultiQC reporting.

2. DATA
Series: GSE52778 (SRA project SRP033351), Homo sapiens, Illumina HiSeq 2000, paired-end.
Samples: SRR1039508 (GSM1275862), SRR1039512 (GSM1275866),SRR1039513 (GSM1275867),
	 SRR1039514 (GSM1275868) (* will stand for GSM12758)
Submitted to GEO: 26 Nov 2013 (last updated: 13 Jan 2023) by Blanca E. Himes,
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

Control: Airway smooth muscle cells that received no drugs,
from donors N61311 and N052611 (Samples *62 and *66).

Treatment: Same cells from donor N052611 (*67 and *68) that were treated for 18
hours with 1 µM of a drug. First one got dexamethasone,the other got albuterol. 
(Information from https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE52778)

Interesting/usefull: Both drugs are used to treat asthma, dexamethasone is slower
working while albuterol is faster one. Dexamethasone suppresses inflammation, 
albuterol relaxes muscle cells. Using them together, (not my samples) could be 
even better, but as I read, real reaction is still tested, I found reports, 
that it can increase risk abnormally low levels of potassium in the blood, 
called hypokalemia.

3. REQUIREMENTS
- Conda/Mamba
- Snakemake 9.27.2 
All other tools are installed automatically via per-rule Conda envs (envs/).

4. SETUP
1) Download reference (GRCh38 genome, transcriptome, GENCODE GTF):
     bash scripts/reference.sh
2) Download FASTQ files into data/ (SRA/ENA).
3) Edit config/samples.tsv (sample, condition, fq1, fq2).
4) Edit config/config.yaml (reference paths, threads, strandedness).

5. RUN
Dry run:
     snakemake -s workflow/Snakefile -n -p
Local:
     snakemake -s workflow/Snakefile --use-conda --cores 8
SLURM (as used for this project; runs the workflow inside one job):
     sbatch run.slurm

6. OUTPUT
results/multiqc/multiqc_report.html   aggregated QC
results/featurecounts/counts.txt      gene counts
results/kallisto/<sample>/            transcript abundances
results/rseqc/, results/deeptools/    QC plots

7. STRUCTURE
config/    config.yaml, samples.tsv
envs/      Conda environments
scripts/   helper scripts
workflow/  Snakefile
