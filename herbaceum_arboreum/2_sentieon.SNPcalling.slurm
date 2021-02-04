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

ref=herbaceum.fasta
thr=70

name="arboreum"

module load sentieon-genomics

sentieon driver -t $thr -i A2.sort.bam --algo LocusCollector --fun score_info $name.score &> $name.locusCollect.log
sentieon driver -t $thr -i A2.sort.bam --algo Dedup --rmdup --score_info $name.score --metrics $name.dedup.metric $name.dedup.bam &> $name.rmDup.log

sentieon driver -t $thr -r $ref -i $name.dedup.bam --algo Realigner $name.realign.bam &> $name.realign.log
sentieon driver -t $thr -r $ref -i $name.realign.bam --algo Genotyper $name.vcf &> $name.vcf.timelog

ml vcftools
vcftools --vcf $name.vcf --remove-indels --recode --recode-INFO-all --out $name.SNPs
vcftools --vcf $name.vcf --keep-only-indels --recode --recode-INFO-all --out $name.indels

vcftools --vcf arboreum.SNPs.recode.vcf --out arboreum.SNPs.filtered --max-alleles 2 --min-meanDP 10 --max-meanDP 100 --recode

################################
module load snpeff/2017-11-24-3ueyysf

# gather files
gzip -c herbaceum.fasta > herbaceum.fasta.gz

# fix the gff3 names and make the gtf
#sed -i -e 's/Alias=.*//g' -e 's/,maker[^;,]*//g' herbaceum.gff3

ml genometools/1.5.9-py2-awelg6n
gt gff3_to_gtf herbaceum.gff3 > herbaceum.gtf
gzip herbaceum.gtf

# make the snpeff database for the longicalyx genome
mkdir herbaceum
cp herbaceum.gtf.gz herbaceum/genes.gtf.gz
cp herbaceum.fasta.gz herbaceum/sequences.fa.gz
#echo "herbaceum.genome : herbaceum" >> snpEff.config

snpEff build -v herbaceum -gtf22 -dataDir . -c snpEff.config

# annotate effects for SNPs using snpeff
snpEff ann -stats arboreum.html -dataDir . -c snpEff.config herbaceum arboreum.SNPs.filtered.recode.vcf > arboreum.snpeff.vcf

############ get only certain features from gff and use those to prune the vcf
ml bedtools2

cat herbaceum.gff3 | awk ' { OFS="\t" }  $3 ~ "gene"  { print $1,$4,$5,$3 }' > herbaceum.gene.bed
bedtools intersect -wa -a arboreum.SNPs.filtered.recode.vcf -b herbaceum.gene.bed > arboreum.gene.vcf

bedtools subtract -a arboreum.SNPs.filtered.recode.vcf -b herbaceum.gene.bed | awk ' {OFS="\t"} {print $1,$2,$2,"intergenic"} ' > herbaceum.intergenic.bed
bedtools intersect -wa -a arboreum.SNPs.filtered.recode.vcf -b herbaceum.intergenic.bed > arboreum.intergenic.vcf

cat herbaceum.gff3 | awk ' { OFS="\t" }  ( $3 ~ "CDS" || $3 ~ "UTR" )  { print $1,$4,$5,$3 }' > herbaceum.utrcds.bed
cat herbaceum.gff3 | awk ' { OFS="\t" }  ( $3 ~ "mRNA" )  { print $1,$4,$5,$3 }' > herbaceum.mRNA.bed
cat herbaceum.gff3 | awk ' { OFS="\t" }  ( $3 ~ "CDS" )  { print $1,$4,$5,$3 }' > herbaceum.exon.bed

bedtools subtract -a herbaceum.mRNA.bed -b herbaceum.utrcds.bed > herbaceum.intron.bed

bedtools intersect -wa -a arboreum.SNPs.filtered.recode.vcf -b herbaceum.exon.bed > arboreum.exons.vcf
bedtools intersect -wa -a arboreum.SNPs.filtered.recode.vcf -b herbaceum.intron.bed > arboreum.intron.vcf

vcftools --vcf arboreum.SNPs.filtered.recode.vcf --out arboreum.diversity.100kb.all --window-pi 100000
vcftools --vcf arboreum.SNPs.filtered.recode.vcf --out arboreum.diversity.100kb.gene --window-pi 100000 --positions arboreum.gene.vcf
vcftools --vcf arboreum.SNPs.filtered.recode.vcf --out arboreum.diversity.100kb.intergenic --window-pi 100000 --positions arboreum.intergenic.vcf
vcftools --vcf arboreum.SNPs.filtered.recode.vcf --out arboreum.diversity.100kb.exons --window-pi 100000 --positions arboreum.exons.vcf
vcftools --vcf arboreum.SNPs.filtered.recode.vcf --out arboreum.diversity.100kb.intron --window-pi 100000 --positions arboreum.intron.vcf

