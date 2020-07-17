# tRNAlign: a tRNA alignment pipeline 

This pipeline has been adapted from the code described in [Hoffman et al Bioinformatics 2018](https://pubmed.ncbi.nlm.nih.gov/29228294/), which can be found [here](https://github.com/AnneHoffmann/tRNA-read-mapping/) and is distributed under the MIT license. 

We have adapted this code to:
* 1) **improve its performance non-human species** (where the quality of tRNAScan predictions can be lower, therefore leading to the annotation of too many tRNA clusters for the mapping). 
* 2) to implement the pipeline in the form of a **Docker container**, which avoids the requirement of installing the individual softwares used by the pipeline individually. The Docker container can be downloaded as **Singularity image** to ensure reproducibility and simplicity.

Whenever possible, we tried to employ the same versions of the softwares as in Hoffmann's pipeline. When the version needed was not available, we used the closest one. Versions and software details can be found in variables.sh.
 

## Major differences with the original pipeline:

- The script removePrecursor.pl was subsituted with a modified version of the script [removePrecursor_new.pl](https://github.com/hexavier/tRNA_mapping/blob/master/removePrecursor.pl), kindly provided by Xavier Hernandez, due to a bug in dealing with intron-containing tRNA genes.

- We use 15nt minimum read length for the trimming

- We use tRNAscan output for masking the genome and for the pre-tRNA reference, but we downloaded the high confidence mature tRNA set from gtRNAdb for the mature tRNA mapping - still, we keep the possibility to map on tRNAscan output in case the users prefers. If working with tRNAscan output, we exclude pseudogenes and tRNAs with NNN anticodons.

- We keep only reads mapping to the positive strand when mapping to the mature tRNAs

- We have created a Docker container with all the required software, so that there is no need to install dependencies or individual softwares that the pipeline uses in your local computer or cluster (except for java tools Picard and GATK, that need to be installed separately from the container).


## Requirements:

- Singularity (tested with version 2.6.1-dist)

- This repository: 

```bash
git clone https://github.com/soniacruciani/tRNAmap_Hoffmann_adapted.git
```


## Getting started:

### 1. Create project folder:

```bash
project=fullpathtoyourprojectfolder


mkdir -p $project/data/genome $project/data/ngs $project/scripts $project/analysis
```

### 2. Locate files in the corresponding directory:

- fastq files in $project/data/ngs

- adapter sequence (adapter.fa) in $project/data/ngs

- reference genome in $project/data/genome

- scripts in $project/scripts 

- mitochondrial tRNAs in $project/data/genome: download mitochondrial tRNA sequences from and put the file in $project/data/genome:

http://mttrna.bioinf.uni-leipzig.de/mtDataOutput/Organisms (select "send fasta")



### 3. Download Docker as a Singularity image:

```bash
cd $project/scripts

singularity pull docker://scruciani/trna_align:100120
```

### 4. Don't forget to set up the variables in the variables.sh script!

so far, the Picard and GATK cannot work from the singularity, so substitute the path with your local path to the picard.jar and GenomeAnalysisTK.jar files, available online.

```bash
cd $project/scripts
vim variables.sh
```

Now you are ready to start running the pipeline! :) 

## Running the pipeline:

```bash
cd $project
```

You can decide whether to qsub or to source the scripts, here I report the qsub commands.

The 1-readqcandtrim.sh and 2-genomeprep.sh can be done in parallel, as they do not depend the one on the other.

### Note: Always qsub from the $project folder!

```bash
qsub -cwd -N qcandtrim -M your@mail -m ea -q short-sl7 scripts/1-readqcandtrim.sh

qsub -cwd -N genprep -M your@mail -m ea -q short-sl7 scripts/2-genomeprep.sh
```

At this point, remember to modify the .csv files (remove header) prior to continuing to the next script.

-In the variables.sh the tRNAmature will just be the same as tRNAName

-For the masking it is important to keep the pseudogenes and the UNN-Undet tRNA genes (to avoid losing reads that might map also to the pseudogenes)

-For the second mapping to the cluster it is important to remove the pseudogenes and the UNN-Undet tRNA genes! (added in 3-trnaprep.sh script)

### Now you can proceed with the pipeline as follows:

```bash
qsub -cwd -N trnaprep -M your@mail -m ea -q short-sl7 scripts/3-tRNAprep.sh

for n in $(ls $project/data/ngs/*_trimmed.fastq.gz); do qsub -cwd -N $(basename $n _trimmed.fastq.gz)_map -M your@mail -m ea -q long-sl7 -pe smp 16 -l virtual_free=80G,h_rt=72:00:00 -v n=$n scripts/4-pre-mapping.sh; done


for n in $(ls $project/analysis/mapping/*_filtered.fastq.gz); do qsub -cwd -N $(basename $n _filtered.fastq.gz)_gatk -M your@mail -m ea -q short-sl7 -pe smp 16 -v n=$n scripts/5-postprocessing.sh; done
```

## Citing this work
A pre-print is currently in preparation.

## Issues/Questions

Please open an issue if you have any doubts on how to use this code. Thank you!


