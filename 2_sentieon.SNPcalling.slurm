#!/bin/bash

#SBATCH --nodes=1 
#SBATCH --cpus-per-task=70 
#SBATCH --mem=200G 
#SBATCH --time=7-02:30:00
#SBATCH --output=job.D.%J.out 
#SBATCH --error=job.D.%J.err
#SBATCH -J "D.sentieonArray" 
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=corrinne@iastate.edu 

module load bwa
module load samtools

DIR=/work/LAS/jfw-lab/corrinne/gossypioides/reads
ref=raimondii.fasta
thr=70

name="gossypioides"


module load sentieon-genomics


sentieon driver -t $thr -i SRR3560148.sort.bam -i SRR3560149.sort.bam --algo LocusCollector --fun score_info $name.score &> $name.locusCollect.log
sentieon driver -t $thr -i SRR3560148.sort.bam -i SRR3560149.sort.bam --algo Dedup --rmdup --score_info $name.score --metrics $name.dedup.metric $name.dedup.bam &> $name.rmDup.log

sentieon driver -t $thr -r $ref -i $name.dedup.bam --algo Realigner $name.realign.bam &> $name.realign.log
sentieon driver -t $thr -r $ref -i $name.realign.bam --algo Genotyper $name.vcf &> $name.vcf.timelog

ml vcftools
vcftools --vcf $name.vcf --remove-indels --recode --recode-INFO-all --out $name.SNPs
vcftools --vcf $name.vcf --keep-only-indels --recode --recode-INFO-all --out $name.indels

vcftools --vcf gossypioides.SNPs.recode.vcf --out gossypioides.SNPs.filtered --max-alleles 2 --min-meanDP 10 --max-meanDP 100 --recode



################################
module load snpeff/2017-11-24-3ueyysf

# gather files
gzip -c raimondii.fasta > raimondii.fasta.gz

# fix the gff3 names and make the gtf
#sed -i -e 's/Alias=.*//g' -e 's/,maker[^;,]*//g' raimondii.gff3

ml genometools/1.5.9-py2-awelg6n
gt gff3_to_gtf raimondii.gff3 > raimondii.gtf
gzip raimondii.gtf

# make the snpeff database for the longicalyx genome
mkdir raimondii
cp raimondii.gtf.gz raimondii/genes.gtf.gz
cp raimondii.fasta.gz raimondii/sequences.fa.gz
#echo "raimondii.genome : raimondii" >> snpEff.config

snpEff build -v raimondii -gtf22 -dataDir . -c snpEff.config

# annotate effects for SNPs using snpeff
snpEff ann -stats gossypioides.html -dataDir . -c snpEff.config raimondii gossypioides.SNPs.filtered.recode.vcf > gossypioides.snpeff.vcf


############ get only certain features from gff and use those to prune the vcf
ml bedtools2

#cat raimondii.gff3 | awk ' { OFS="\t" }  $3 ~ "gene"  { print $1,$4,$5,$3 }' > raimondii.gene.bed
bedtools intersect -wa -a gossypioides.SNPs.filtered.recode.vcf -b raimondii.gene.bed > gossypioides.gene.vcf

bedtools subtract -a gossypioides.SNPs.filtered.recode.vcf -b raimondii.gene.bed | awk ' {OFS="\t"} {print $1,$2,$2,"intergenic"} ' > raimondii.intergenic.bed
bedtools intersect -wa -a gossypioides.SNPs.filtered.recode.vcf -b raimondii.intergenic.bed > gossypioides.intergenic.vcf


#cat raimondii.gff3 | awk ' { OFS="\t" }  ( $3 ~ "CDS" || $3 ~ "UTR" )  { print $1,$4,$5,$3 }' > raimondii.utrcds.bed
#cat raimondii.gff3 | awk ' { OFS="\t" }  ( $3 ~ "mRNA" )  { print $1,$4,$5,$3 }' > raimondii.mRNA.bed
#cat raimondii.gff3 | awk ' { OFS="\t" }  ( $3 ~ "CDS" )  { print $1,$4,$5,$3 }' > raimondii.exon.bed


bedtools subtract -a raimondii.mRNA.bed -b raimondii.utrcds.bed > raimondii.intron.bed


bedtools intersect -wa -a gossypioides.SNPs.filtered.recode.vcf -b raimondii.exon.bed > gossypioides.exons.vcf
bedtools intersect -wa -a gossypioides.SNPs.filtered.recode.vcf -b raimondii.intron.bed > gossypioides.intron.vcf


vcftools --vcf gossypioides.SNPs.filtered.recode.vcf --out gossypioides.diversity.100kb.all --window-pi 100000
vcftools --vcf gossypioides.SNPs.filtered.recode.vcf --out gossypioides.diversity.100kb.gene --window-pi 100000 --positions gossypioides.gene.vcf
vcftools --vcf gossypioides.SNPs.filtered.recode.vcf --out gossypioides.diversity.100kb.intergenic --window-pi 100000 --positions gossypioides.intergenic.vcf
vcftools --vcf gossypioides.SNPs.filtered.recode.vcf --out gossypioides.diversity.100kb.exons --window-pi 100000 --positions gossypioides.exons.vcf
vcftools --vcf gossypioides.SNPs.filtered.recode.vcf --out gossypioides.diversity.100kb.intron --window-pi 100000 --positions gossypioides.intron.vcf

