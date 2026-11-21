IDX = multiext(config["hisat2_index"], ".1.ht2", ".2.ht2", ".3.ht2", ".4.ht2",
               ".5.ht2", ".6.ht2", ".7.ht2", ".8.ht2")


rule hisat2_index:
    input:
        fasta = config["genome_fa"]
    output:
        idx = IDX
    conda:
        "../envs/align.yaml"
    threads: 8
    log:
        OUT + "/logs/hisat2_index.log"
    shell:
        """
        mkdir -p $(dirname {config[hisat2_index]})
        hisat2-build -p {threads} {input.fasta} {config[hisat2_index]} > {log} 2>&1
        """


rule splice_sites:
    input:
        gtf = config["gtf"]
    output:
        ss   = "resources/splice_sites.txt",
        exon = "resources/exons.txt"
    script:
        "scripts/splice_sites.py"


rule hisat2_align:
    input:
        r1  = OUT + "/trimmed/{sample}_1.fastq.gz",
        r2  = OUT + "/trimmed/{sample}_2.fastq.gz",
        idx = IDX,
        ss  = "resources/splice_sites.txt"
    output:
        bam = OUT + "/hisat2/{sample}.bam",
        bai = OUT + "/hisat2/{sample}.bam.bai"
    params:
        prefix = config["hisat2_index"]
    conda:
        "../envs/align.yaml"
    threads: 8
    log:
        OUT + "/logs/hisat2/{sample}.log"
    shell:
        """
        hisat2 -p {threads} \\
            --known-splicesite-infile {input.ss} \\
            -x {params.prefix} \\
            -1 {input.r1} -2 {input.r2} \\
          2> {log} \\
        | samtools sort -@ 2 -o {output.bam}
        samtools index {output.bam}
        """
