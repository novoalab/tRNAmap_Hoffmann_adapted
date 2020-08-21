#directory paths
cwd=$(pwd)

source ${cwd}/scripts/variables.sh

bn=$(basename $n _filtered.fastq.gz)

cd ${workDir}/mapping
zcat ${bn}.fastq.gz | paste  - - - - | sed 's/@/@\t/g' | cut -f 2 > ${bn}_matureIDs.txt

samtools view ${bn}_filtered.sam | grep -vwf ${bn}_matureIDs.txt | samtools view -Sb | samtools sort > ${bn}_pre-tRNAs.bam
samtools index ${bn}_pre-tRNAs.bam
