#!/bin/bash

#SBATCH --nodes=1 
#SBATCH --cpus-per-task=70 
#SBATCH --mem=200G 
#SBATCH --time=7-02:30:00
#SBATCH --output=job.A.%J.out 
#SBATCH --error=job.A.%J.err
#SBATCH -J "A.sentieon" 
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=corrinne@iastate.edu 

module load bwa
module load samtools

DIR=/work/LAS/jfw-lab/corrinne/herbaceum/reads
ref=herbaceum.fasta
thr=70

file1=SRR8979980.1.fq.gz
file2=SRR8979980.2.fq.gz

name=A2

module load bwa
bwa mem -M -K 10000000 -R "@RG\tID:A2 \tSM:arboreum \tPL:ILLUMINA" -t $thr $ref $DIR/$file1 $DIR/$file2 > $name.sam

module load sentieon-genomics
sentieon util sort -o $name.sort.bam -t $thr --sam2bam -i $name.sam  &> $name.sam2bam.log

