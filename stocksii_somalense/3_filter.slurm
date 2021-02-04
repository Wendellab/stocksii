#!/bin/bash

#SBATCH --nodes=1 
#SBATCH --cpus-per-task=20 
#SBATCH --mem=200G 
#SBATCH --time=7-02:30:00
#SBATCH --output=job.Ffilter.%J.out 
#SBATCH --error=job.Ffilter.%J.err
#SBATCH -J "F.filter" 
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=corrinne@iastate.edu 



vcftools --vcf somalense.SNPs.recode.vcf --out somalense.SNPs.filtered --max-alleles 2 --min-meanDP 10 --max-meanDP 100 --recode

module load snpeff/2017-11-24-3ueyysf

# gather files
gzip -c stocksii.V1.0.hic_juiced.fasta > stocksii.fasta.gz

# fix the gff3 names and make the gtf
sed -i -e 's/Alias=.*//g' -e 's/,maker[^;,]*//g' stocksii.gff3

ml genometools/1.5.9-py2-awelg6n
gt gff3_to_gtf stocksii.gff3 > stocksii.gtf
gzip stocksii.gtf

# make the snpeff database for the longicalyx genome
mkdir stocksii
cp stocksii.gtf.gz stocksii/genes.gtf.gz
cp stocksii.fasta.gz stocksii/sequences.fa.gz
echo "stocksii.genome : stocksii" >> snpEff.config

snpEff build -v stocksii -gtf22 -dataDir . -c snpEff.config

# annotate effects for SNPs using snpeff
snpEff ann -stats somalense.html -dataDir . -c snpEff.config stocksii somalense.SNPs.filtered.recode.vcf > somalense.snpeff.vcf


############ get only certain features from gff and use those to prune the vcf
ml bedtools2

cat stocksii.gff3 | awk ' { OFS="\t" }  $3 ~ "gene"  { print $1,$4,$5,$3 }' > stocksii.gene.bed
bedtools intersect -wa -a somalense.SNPs.filtered.recode.vcf -b stocksii.gene.bed > somalense.gene.vcf

bedtools subtract -a somalense.SNPs.filtered.recode.vcf -b stocksii.gene.bed | awk ' {OFS="\t"} {print $1,$2,$2,"intergenic"} ' > stocksii.intergenic.bed
bedtools intersect -wa -a somalense.SNPs.filtered.recode.vcf -b stocksii.intergenic.bed > somalense.intergenic.vcf


cat stocksii.gff3 | awk ' { OFS="\t" }  ( $3 ~ "CDS" || $3 ~ "UTR" )  { print $1,$4,$5,$3 }' > stocksii.utrcds.bed
cat stocksii.gff3 | awk ' { OFS="\t" }  ( $3 ~ "mRNA" )  { print $1,$4,$5,$3 }' > stocksii.mRNA.bed
cat stocksii.gff3 | awk ' { OFS="\t" }  ( $3 ~ "CDS" )  { print $1,$4,$5,$3 }' > stocksii.exon.bed


bedtools subtract -a stocksii.mRNA.bed -b stocksii.utrcds.bed > stocksii.intron.bed


bedtools intersect -wa -a somalense.SNPs.filtered.recode.vcf -b stocksii.exon.bed > somalense.exons.vcf
bedtools intersect -wa -a somalense.SNPs.filtered.recode.vcf -b stocksii.intron.bed > somalense.intron.vcf


vcftools --vcf somalense.SNPs.filtered.recode.vcf --out somalense.diversity.100kb.all --window-pi 100000
vcftools --vcf somalense.SNPs.filtered.recode.vcf --out somalense.diversity.100kb.gene --window-pi 100000 --positions somalense.gene.vcf
vcftools --vcf somalense.SNPs.filtered.recode.vcf --out somalense.diversity.100kb.intergenic --window-pi 100000 --positions somalense.intergenic.vcf
vcftools --vcf somalense.SNPs.filtered.recode.vcf --out somalense.diversity.100kb.exons --window-pi 100000 --positions somalense.exons.vcf
vcftools --vcf somalense.SNPs.filtered.recode.vcf --out somalense.diversity.100kb.intron --window-pi 100000 --positions somalense.intron.vcf


