import sys

gtf = snakemake.input.gtf
ss_file = snakemake.output.ss
exon_file = snakemake.output.exon

seen = set()
with open(gtf) as fin, open(ss_file, "w") as fout:
    for line in fin:
        if line.startswith("#"):
            continue
        parts = line.rstrip("\n").split("\t")
        if len(parts) < 9 or parts[2] != "exon":
            continue
        chrom, start, end, strand = parts[0], int(parts[3]), int(parts[4]), parts[6]
        intron_start = start
        intron_end = end - 1
        attr = {}
        for item in parts[8].split(";"):
            item = item.strip()
            if not item or " " not in item:
                continue
            k, v = item.split(" ", 1)
            attr[k] = v.strip('"')
        gene_id = attr.get("gene_id", "NA")
        tx_id = attr.get("transcript_id", "NA")
        key = (chrom, intron_start, intron_end, strand, gene_id, tx_id)
        if key in seen or intron_end <= intron_start:
            continue
        seen.add(key)
        fout.write(f"{chrom}\t{intron_start}\t{intron_end}\t{strand}\t{gene_id}\t{tx_id}\n")

with open(gtf) as fin, open(exon_file, "w") as fout:
    for line in fin:
        if line.startswith("#"):
            continue
        parts = line.rstrip("\n").split("\t")
        if len(parts) >= 4 and parts[2] == "exon":
            fout.write(line)
