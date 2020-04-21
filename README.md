# tRNA alignment pipeline - adapted from Hoffmann 

This pipeline is adapted from https://github.com/AnneHoffmann/tRNA-read-mapping/ under the MIT license for usage with a Docker container and qsub commands for a Sun Grid Engine (SGE) cluster. We tried to stick to the same versions of the softwares as in Hoffmann's pipeline whenever possible. When the version needed was not available, we used the closest one. versions details are available in variables.sh script.

Thing we changed from the original pipeline:

-the script removePrecursor.pl was subsitute with removePrecursor_new.pl, kindly provided by Xavier Hernandez (https://github.com/hexavier/tRNA_mapping)

-we use 15nt as minimum read length for the trimming

-We use tRNAscan output for masking the genome and for the pre-tRNA reference, but we downloaded the high confidence mature tRNA set from gtRNAdb for the mature tRNA mapping

-We keep only reads mapoing to the positive strand when mapping to the mature tRNAs


## Requirements:

-Singularity (tested with version 2.6.1-dist)

-This repository: 

```bash
git clone https://github.com/soniacruciani/trna_align_hoffmann.git
```

## Getting started:

### Create project folder:

```bash
project=fullpathtoyourprojectfolder


mkdir -p $project/data/genome $project/data/ngs $project/scripts $project/analysis
```

### Locate files in the corresponding directory:

-fastq files in $project/data/ngs

-adapter sequence (adapter.fa) in $project/data/ngs

-reference genome in $project/data/genome

-scripts in $project/scripts 

-mitochondrial tRNAs in $project/data/genome:

1. download mitochondrial tRNA sequences from and put the file in $project/data/genome:

http://mttrna.bioinf.uni-leipzig.de/mtDataOutput/Organisms (select "send fasta")



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

-In the variables.sh the tRNAmature will just be the same as tRNAName

-For the masking it is important to keep the pseudogenes and the UNN-Undet tRNA genes (to avoid losing reads that might map also to the pseudogenes)

-For the second mapping to the cluster it is important to remove the pseudogenes and the UNN-Undet tRNA genes! (added in 3-trnaprep.sh script)

### now you can proceed:

```bash
qsub -cwd -N trnaprep -M your@mail -m ea -q short-sl7 scripts/3-tRNAprep.sh

for n in $(ls $project/data/ngs/*_trimmed.fastq.gz); do qsub -cwd -N $(basename $n _trimmed.fastq.gz)_map -M your@mail -m ea -q long-sl7 -pe smp 16 -l virtual_free=80G,h_rt=72:00:00 -v n=$n scripts/4-pre-mapping.sh; done


for n in $(ls $project/analysis/mapping/*_filtered.fastq.gz); do qsub -cwd -N $(basename $n _filtered.fastq.gz)_gatk -M your@mail -m ea -q short-sl7 -pe smp 16 -v n=$n scripts/5-postprocessing.sh; done
```
