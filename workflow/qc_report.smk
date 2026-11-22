BAMS = expand(OUT + "/hisat2/{sample}.bam", sample=SAMPLES)
LABELS = " ".join(SAMPLES)


rule gtf_to_bed:
    input:
        gtf = config["gtf"]
    output:
        bed = "resources/genes.bed",
        sub = "resources/genes_subset.bed"
    conda: "../envs/rseqc.yaml"
    log: OUT + "/logs/gtf_to_bed.log"
    shell:
        """
        gtfToGenePred -genePredExt {input.gtf} resources/genes.gp 2> {log}
        genePredToBed resources/genes.gp {output.bed} 2>> {log}
        shuf -n 5000 --random-source=<(yes) {output.bed} > {output.sub}
        """


rule bam_stat:
    input: bam = OUT + "/hisat2/{sample}.bam"
    output: OUT + "/rseqc/{sample}.bam_stat.txt"
    conda: "../envs/rseqc.yaml"
    log: OUT + "/logs/rseqc/{sample}.bam_stat.log"
    shell: "bam_stat.py -i {input.bam} > {output} 2> {log}"


rule infer_experiment:
    input:
        bam = OUT + "/hisat2/{sample}.bam",
        bed = "resources/genes.bed"
    output: OUT + "/rseqc/{sample}.infer_experiment.txt"
    conda: "../envs/rseqc.yaml"
    log: OUT + "/logs/rseqc/{sample}.infer_experiment.log"
    shell: "infer_experiment.py -r {input.bed} -i {input.bam} > {output} 2> {log}"


rule read_distribution:
    input:
        bam = OUT + "/hisat2/{sample}.bam",
        bed = "resources/genes.bed"
    output: OUT + "/rseqc/{sample}.read_distribution.txt"
    conda: "../envs/rseqc.yaml"
    log: OUT + "/logs/rseqc/{sample}.read_distribution.log"
    shell: "read_distribution.py -r {input.bed} -i {input.bam} > {output} 2> {log}"


rule gene_body_coverage:
    input:
        bam = OUT + "/hisat2/{sample}.bam",
        bai = OUT + "/hisat2/{sample}.bam.bai",
        bed = "resources/genes_subset.bed"
    output: OUT + "/rseqc/{sample}.geneBodyCoverage.txt"
    params: prefix = OUT + "/rseqc/{sample}"
    conda: "../envs/rseqc.yaml"
    log: OUT + "/logs/rseqc/{sample}.gbc.log"
    shell: "geneBody_coverage.py -r {input.bed} -i {input.bam} -o {params.prefix} > {log} 2>&1"


rule inner_distance:
    input:
        bam = OUT + "/hisat2/{sample}.bam",
        bed = "resources/genes.bed"
    output: OUT + "/rseqc/{sample}.inner_distance_freq.txt"
    params: prefix = OUT + "/rseqc/{sample}"
    conda: "../envs/rseqc.yaml"
    log: OUT + "/logs/rseqc/{sample}.inner_distance.log"
    shell: "inner_distance.py -r {input.bed} -i {input.bam} -o {params.prefix} > {log} 2>&1"


rule fragment_size:
    input: bams = BAMS
    output:
        png = OUT + "/deeptools/fragment_size.png",
        tab = OUT + "/deeptools/fragment_size.txt"
    params: labels = LABELS
    threads: 8
    conda: "../envs/deeptools.yaml"
    log: OUT + "/logs/deeptools/fragment_size.log"
    shell:
        "bamPEFragmentSize -p {threads} -b {input.bams} --samplesLabel {params.labels} "
        "-hist {output.png} --table {output.tab} > {log} 2>&1"


rule multibam_summary:
    input: bams = BAMS
    output: OUT + "/deeptools/bins.npz"
    params: labels = LABELS
    threads: 8
    conda: "../envs/deeptools.yaml"
    log: OUT + "/logs/deeptools/multibam.log"
    shell:
        "multiBamSummary bins -p {threads} -b {input.bams} --labels {params.labels} "
        "-o {output} > {log} 2>&1"


rule plot_correlation:
    input: OUT + "/deeptools/bins.npz"
    output:
        fig = OUT + "/deeptools/correlation.png",
        tab = OUT + "/deeptools/correlation.tsv"
    conda: "../envs/deeptools.yaml"
    log: OUT + "/logs/deeptools/correlation.log"
    shell:
        "plotCorrelation -in {input} -c spearman -p heatmap --plotNumbers "
        "-o {output.fig} --outFileCorMatrix {output.tab} > {log} 2>&1 && "
        "sed -i '1i #plotCorrelation --outFileCorMatrix' {output.tab}"


rule plot_pca:
    input: OUT + "/deeptools/bins.npz"
    output:
        fig = OUT + "/deeptools/pca.png",
        tab = OUT + "/deeptools/pca.tsv"
    conda: "../envs/deeptools.yaml"
    log: OUT + "/logs/deeptools/pca.log"
    shell: "plotPCA -in {input} -o {output.fig} --outFileNameData {output.tab} > {log} 2>&1 && sed -i '1i #plotPCA --outFileNameData' {output.tab}"


rule multiqc:
    input:
        expand(OUT + "/rseqc/{sample}.{f}", sample=SAMPLES,
               f=["bam_stat.txt", "infer_experiment.txt", "read_distribution.txt",
                  "geneBodyCoverage.txt", "inner_distance_freq.txt"]),
        expand(OUT + "/fastp/{sample}.json", sample=SAMPLES),
        expand(OUT + "/fastqc_raw/{sample}_{read}_fastqc.zip", sample=SAMPLES, read=["1", "2"]),
        expand(OUT + "/fastqc_trimmed/{sample}_{read}_fastqc.zip", sample=SAMPLES, read=["1", "2"]),
        expand(OUT + "/logs/hisat2/{sample}.log", sample=SAMPLES),
        expand(OUT + "/kallisto/{sample}/run_info.json", sample=SAMPLES),
        OUT + "/featurecounts/counts.txt",
        OUT + "/deeptools/correlation.tsv",
        OUT + "/deeptools/pca.tsv",
        OUT + "/deeptools/fragment_size.txt"
    output: OUT + "/multiqc/multiqc_report.html"
    params: outdir = OUT + "/multiqc"
    conda: "../envs/multiqc.yaml"
    log: OUT + "/logs/multiqc.log"
    shell: "multiqc {OUT} -f --dirs --dirs-depth 1 -c config/multiqc_config.yaml -o {params.outdir} > {log} 2>&1"
