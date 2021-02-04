#!/bin/bash

#SBATCH --nodes=1 
#SBATCH --cpus-per-task=80 
#SBATCH --mem=200G 
#SBATCH --time=7-02:30:00
#SBATCH --output=job.OF.%A_%a.out 
#SBATCH --error=job.OF.%A_%a.err
#SBATCH -J "OrthoFinder" 
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=corrinne@iastate.edu 


module load orthofinder/2.2.0-py2-tf3rsoz

orthofinder -f primaryOnly/ -t 80
