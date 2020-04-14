

#directory paths
cwd=$(pwd)

source ${cwd}/scripts/variables.sh

cd ${genomeDir}


###pre-mapping against artificial genome
##THIS STEP CAN TAKE SEVERAL DAYS!!! for mouse genome it took up to 3 days, up to 5 with the human genome (depending on the number of reads)
##MAKE SURE TO CHANGE THE --threads PARAMETER ACCORDING TO THE YOUR POSSIBILITIES (and to add the thread number in the qsub command)

mkdir -p ${workDir}/mapping
cd ${workDir}/mapping

    bn=$(basename $n _trimmed.fastq.gz)

    $segemehl --silent --threads 16 --evalue 500 --differences 3 --maxinterval 1000 --accuracy 80 --index ${genomeDir}/${genomeName}_artificial.idx --database ${genomeDir}/${genomeName}_artificial.fa --nomatchfilename ${bn}_unmatched.fastq --query $n -o ${bn}.sam
    gzip ${bn}_unmatched.fastq

    ##remove all reads mapping at least once to the genome
    $RUN perl ${scriptDir}/removeGenomeMapper.pl ${genomeDir}/${tRNAName}_pre-tRNAs.fa ${bn}.sam ${bn}_filtered.sam

    ##remove pre-tRNA reads, keep only mature tRNA reads
    $RUN perl ${scriptDir}/removePrecursor_new.pl  ${genomeDir}/${tRNAName}_pre-tRNAs.bed12 ${bn}_filtered.sam $n > ${bn}_filtered.fastq
    gzip ${bn}_filtered.fastq
