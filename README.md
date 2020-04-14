# tRNA alignment pipeline - Hoffmann original

This pipeline is adapted from https://github.com/AnneHoffmann/tRNA-read-mapping/ under the MIT licens for usage with a Docker container 

## Requirements:

-Singularity (tested with version 2.6.1-dist)

-This repository: 

```bash
git clone https://github.com/soniacruciani/trna_align_hoffmann.git
```

## Getting started:

### Create project folder:

```bash
project=yourprojectfolder


mkdir -p $project/data/genome $project/data/ngs $project/scripts $project/analysis
```

### Locate files in the corresponding directory:

-fastq files in $project/data/ngs

-adapter sequence (adapter.fa) in $project/data/ngs

-reference genome in $project/data/genome

-scripts in $project/scripts 


### Download Docker as Singularity image:

```bash
cd $project/scripts

singularity pull docker://scruciani/trna_align:100120
```

### Don't forget to set up the variables in the variables.sh script!

so far, the Picard and GATK cannot work from the singularity, so substitute the path with your local path to the picard.jar and GenomeAnalysisTK.jar files, available online.

```bash
cd $project/scripts
vim variables.sh
```

## Run the pipeline!

```bash
cd $project
```

You can decide whether to qsub or to source the scripts, here I report the qsub commands.

The 1-readqcandtrim.sh and 2-genomeprep.sh can be done in parallel, as they do not depend the one on the other.

### Always qsub from the $project folder!

```bash
qsub -cwd -N qcandtrim -M your@mail -m ea -q short-sl7 scripts/1-readqcandtrim.sh

qsub -cwd -N genprep -M your@mail -m ea -q short-sl7 scripts/2-genomeprep.sh
```

At this point, remember to modify the .csv files (remove header) prior to continuing to the next script.

### Depending wether you are working with an organism for which mature tRNA fasta is available in gtrnadb or not, you should use the scripts from "trnascan_based" folder.

-In the variables.sh the tRNAmature will just be the same as tRNAName

-For the masking it is important to keep the pseudogenes and the UNN-Undet tRNA genes (to avoid losing reads that might map also to the pseudogenes)

-For the second mapping to the cluster it is important to remove the pseudogenes and the UNN-Undet tRNA genes! (added in both 3-trnaprep.sh scripts)

### Make sure you use the correct scripts for your case and proceed

```bash
qsub -cwd -N trnaprep -M your@mail -m ea -q short-sl7 scripts/3-tRNAprep.sh

for n in $(ls $project/data/ngs/*_trimmed.fastq.gz); do qsub -cwd -N $(basename $n _trimmed.fastq.gz)_map -M your@mail -m ea -q long-sl7 -pe smp 16 -l virtual_free=80G,h_rt=72:00:00 -v n=$n scripts/4-pre-mapping.sh; done


for n in $(ls $project/analysis/mapping/*_filtered.fastq.gz); do qsub -cwd -N $(basename $n _filtered.fastq.gz)_gatk -M your@mail -m ea -q short-sl7 -pe smp 16 -v n=$n scripts/5-postprocessing.sh; done
```