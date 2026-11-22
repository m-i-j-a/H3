rule kallisto_index:
    input:
        transcripts = config["transcripts_fa"]
    output:
        idx = config["kallisto_index"]
    conda:
        "../envs/kallisto.yaml"
    threads: 8
    log:
        OUT + "/logs/kallisto_index.log"
    shell:
        """
        mkdir -p $(dirname {output.idx})
        kallisto index -i {output.idx} {input.transcripts} > {log} 2>&1
        """


rule kallisto_quant:
    input:
        r1  = OUT + "/trimmed/{sample}_1.fastq.gz",
        r2  = OUT + "/trimmed/{sample}_2.fastq.gz",
        idx = config["kallisto_index"]
    output:
        abundance = OUT + "/kallisto/{sample}/abundance.tsv",
        h5        = OUT + "/kallisto/{sample}/abundance.h5",
        run_info  = OUT + "/kallisto/{sample}/run_info.json"
    params:
        outdir = OUT + "/kallisto/{sample}"
    conda:
        "../envs/kallisto.yaml"
    threads: 8
    log:
        OUT + "/logs/kallisto/{sample}.log"
    shell:
        """
        kallisto quant \\
            -i {input.idx} \\
            -o {params.outdir} \\
            -t {threads} \\
            {input.r1} {input.r2} > {log} 2>&1
        """


rule featurecounts:
    input:
        bams = expand(OUT + "/hisat2/{sample}.bam", sample=SAMPLES),
        gtf  = config["gtf"]
    output:
        counts = OUT + "/featurecounts/counts.txt"
    conda:
        "../envs/align.yaml"
    threads: 8
    log:
        OUT + "/logs/featurecounts.log"
    shell:
        """
        mkdir -p $(dirname {output.counts})
        featureCounts -T {threads} -p -s {config[strandedness]} -t exon -g gene_id \\
            -a {input.gtf} \\
            -o {output.counts} \\
            {input.bams} > {log} 2>&1
        """
