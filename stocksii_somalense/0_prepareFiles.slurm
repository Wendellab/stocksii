#!/bin/bash

#SBATCH --nodes=1 
#SBATCH --cpus-per-task=7 
#SBATCH --mem=20G 
#SBATCH --time=4-02:30:00
#SBATCH --output=job.F.%J.out 
#SBATCH --error=job.F.%J.err
#SBATCH --job-name "F.prepare" 
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=corrinne@iastate.edu 

file=stocksii.V1.0.hic_juiced.fasta

ml samtools
ml bwa

bwa index $file
samtools faidx $file

