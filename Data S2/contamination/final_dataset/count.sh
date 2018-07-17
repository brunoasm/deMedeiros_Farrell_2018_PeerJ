#!/bin/bash
export BOWTIE2_INDEXES=../references/cont_index/

#first, generate a fasta file with final loci for each sample
find ../../*_outfiles -name '*.loci' -exec cat {} + | grep $sample | awk '{$0 = ">" $0; gsub(/ +/,"\n");gsub(/-+/,"") ; print}' > $sample.fasta


bowtie2 --very-sensitive -f --no-hd -p $SLURM_NTASKS -U $sample.fasta -x cont_index -S $sample.sam
cat $sample.sam | awk '{if ($3 ~ /Homo/) {print "Homo"} else if ($3 ~ "*" ) {print "none"} else {gsub(/_[0-9]+/,"",$3); print $3}}' | sort | uniq -c | awk -v output=$sample 'BEGIN {split("Anchylorhynchus Andranthobius Celetes_impar Microstrates_bondari Microstrates_ypsilon Homo none",names); for (i in names) {counts[names[i]] = 0}} {counts[$2] += $1} END {for (i=1; i<=length(names); i++) {output=output "\t" counts[names[i]]} print output}' >> counts.txt
rm $sample.sam
rm $sample.fasta