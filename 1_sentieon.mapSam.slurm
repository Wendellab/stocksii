#!/bin/bash

#SBATCH --job-name=array
#SBATCH --array=1-2
#SBATCH --nodes=1 
#SBATCH --cpus-per-task=70 
#SBATCH --mem=200G 
#SBATCH --time=7-02:30:00
#SBATCH --output=job.D.%A_%a.out 
#SBATCH --error=job.D.%A_%a.err
#SBATCH -J "D.sentieonArray" 
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=corrinne@iastate.edu 

module load bwa
module load samtools

DIR=/work/LAS/jfw-lab/corrinne/gossypioides/reads
ref=raimondii.fasta
thr=70

file1=$(ls -1 $DIR/SRR356*.1.fq.gz | sed -n ${SLURM_ARRAY_TASK_ID}p)
file2=$(ls -1 $DIR/SRR356*.2.fq.gz | sed -n ${SLURM_ARRAY_TASK_ID}p)

name=$(basename $file1 .1.fq.gz)

module load bwa
bwa mem -M -K 10000000 -R "@RG\tID:$name \tSM:gossypioides \tPL:ILLUMINA" -t $thr $ref $file1 $file2 > $name.sam

module load sentieon-genomics
sentieon util sort -o $name.sort.bam -t $thr --sam2bam -i $name.sam  &> $name.sam2bam.log

