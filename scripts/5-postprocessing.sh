#directory paths
cwd=$(pwd)

source ${cwd}/scripts/variables.sh


###post-processing
mkdir ${workDir}/postprocessing
cd ${workDir}/postprocessing


    bn=$(basename $n _filtered.fastq.gz)

	#post-mapping against cluster
    $segemehl --silent --threads 16 --evalue 500 --differences 3 --maxinterval 1000 --accuracy 85 --index ${genomeDir}/${tRNAmature}_cluster.idx --database ${genomeDir}/${tRNAmature}_cluster.fa --nomatchfilename ${bn}_unmatched.fastq --query $n | $samtools view -bS -F 16 | $samtools sort -T ${bn} -o ${bn}.bam
    gzip ${bn}_unmatched.fastq

    ##preparing bam file for indel realignment
    #indexing
    $samtools index ${bn}.bam

###PICARD WAS RUN IN THE DOCKER

    #add read groups to bam file
    $picard AddOrReplaceReadGroups I=${bn}.bam O=${bn}.mod.bam RGPL=RNASeqReadSimulator RGLB=Simlib RGPU=unit1 RGSM=36bam

    #indexing
    $samtools index ${bn}.mod.bam


#modify mapping quality to 60 (otherwise all were removed)
    $gatk -T PrintReads -R ${genomeDir}/${tRNAmature}_cluster.fa -I ${bn}.mod.bam -o ${bn}.temp.bam -rf ReassignMappingQuality -DMQ 60
    mv -f ${bn}.temp.bam ${bn}.mod.bam
    rm -f ${bn}.temp.bai ${bn}.mod.bam.bai

    #indexing
    $samtools index ${bn}.mod.bam
    
    ##realignment
    $gatk -T RealignerTargetCreator -R ${genomeDir}/${tRNAmature}_cluster.fa -I ${bn}.mod.bam -o ${bn}.temp.intervals
    $gatk -T IndelRealigner -R ${genomeDir}/${tRNAmature}_cluster.fa -I ${bn}.mod.bam -targetIntervals ${bn}.temp.intervals -o ${bn}.realigned.bam
    rm -f ${bn}.temp.intervals

    ##filter multimapped reads
    if [ "$multimapperHandling" == "uniq" ]; then
      $samtools view -h ${bn}.realigned.bam | grep -P 'NH:i:1\D'\|'^@' | $samtools view -bS | $samtools sort -T ${bn} -o ${bn}.mmHandled.bam
    elif [ "$multimapperHandling" == "phased" ]; then
      $samtools sort -n -T ${bn} -O sam ${bn}.realigned.bam  > ${bn}.nSorted.sam
      $RUN perl ${scriptDir}/multimapperPhasing.pl -ed 0 -id 0 -verbose 0 -sam ${bn}.nSorted.sam -out ${bn}.nSorted.phased.sam
      $samtools view -bS ${bn}.nSorted.phased.sam | $samtools sort -T ${bn} -o ${bn}.mmHandled.bam
    elif [ "$multimapperHandling" == "all" ]; then
      cp ${bn}.realigned.bam ${bn}.mmHandled.bam
    else
      echo "Unkown parameter for multimapperHandling; set to 'uniq', 'all', or 'phased'";
      exit;
    fi


    #indexing
    $samtools index ${bn}.mmHandled.bam

    ##modification site calling
    $gatk -R ${genomeDir}/${tRNAmature}_cluster.fa -T UnifiedGenotyper -I ${bn}.mmHandled.bam -o ${bn}.GATK.vcf -stand_call_conf 50.0
    grep -i -v lowqual ${bn}.GATK.vcf > ${bn}.GATK_filtered.vcf
