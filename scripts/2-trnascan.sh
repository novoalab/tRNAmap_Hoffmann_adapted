##also, yo will need to manipulate the csv files
#directory paths
cwd=$(pwd)

source ${cwd}/scripts/variables.sh

###genome preparation
cd ${genomeDir}

##genome indexing using samtools
gunzip ${genomeName}.fa.gz
$samtools faidx ${genomeName}.fa

## scan for tRNA nuclear
##the -Q option should prevent the program to loop in case the destination file already exists (option present in v 1.3 of tRNAscan. not reported in version 2.0.4)

$tRNAscanSE tmp -Q -o ${tRNAName}.nuc.csv  ${genomeName}.fa

## scan for mitochondrial tRNA, consider: tRNAscanSE finds only 21 mt tRNA

$samtools faidx ${genomeName}.fa $chrM > ${genomeName}.chrM.fa

$tRNAscan-SE tmp -Q -O -o ${tRNAName}.chrM.csv ${genomeName}.chrM.fa

##you can exit the shell

grep -v $chrM ${tRNAName}.nuc.csv > ${tRNAName}.nuc_mod.csv


echo "REMEMBER TO REMOVE THE HEADERS OF THE CSV FILE TO AVOID ERRORS IN THE tRNAscan2bed12.pl SCRIPT!"
