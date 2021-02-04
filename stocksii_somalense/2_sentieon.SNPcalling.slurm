#!/bin/bash

#SBATCH --nodes=1 
#SBATCH --cpus-per-task=70 
#SBATCH --mem=200G 
#SBATCH --time=7-02:30:00
#SBATCH --output=job.E.%J.out 
#SBATCH --error=job.E.%J.err
#SBATCH -J "E.sentieonArray" 
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=corrinne@iastate.edu 

module load bwa
module load samtools

DIR=/work/LAS/jfw-lab/corrinne/somalense/reads
ref=stocksii.V1.0.hic_juiced.fasta
thr=70

name="somalense"


module load sentieon-genomics


sentieon driver -t $thr -i E0.sort.bam -i E1.sort.bam -i E2.sort.bam --algo LocusCollector --fun score_info $name.score &> $name.locusCollect.log
sentieon driver -t $thr -i E0.sort.bam -i E1.sort.bam -i E2.sort.bam --algo Dedup --rmdup --score_info $name.score --metrics $name.dedup.metric $name.dedup.bam &> $name.rmDup.log

sentieon driver -t $thr -r $ref -i $name.dedup.bam --algo Realigner $name.realign.bam &> $name.realign.log
sentieon driver -t $thr -r $ref -i $name.realign.bam --algo Genotyper $name.vcf &> $name.vcf.timelog

ml vcftools
vcftools --vcf $name.vcf --remove-indels --recode --recode-INFO-all --out $name.SNPs
vcftools --vcf $name.vcf --keep-only-indels --recode --recode-INFO-all --out $name.indels

