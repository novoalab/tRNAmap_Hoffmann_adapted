#directory paths
cwd=$(pwd)

source ${cwd}/scripts/variables.sh

cd ${genomeDir}

##convert tRNAscan tab file into bed12 entry

cat ${tRNAName}.nuc_mod.csv ${tRNAName}.chrM.csv > ${tRNAName}.csv 

perl ${scriptDir}/tRNAscan2bed12.pl ${tRNAName}.csv ${tRNAName}.bed12

##mask found tRNAs genomic
$bedtools maskfasta -fi ${genomeName}.fa -fo ${genomeName}.masked.fa -mc N -bed ${tRNAName}.bed12

###create pre-tRNA library
##add 50 nt 5' and 3' flanking regions
perl ${scriptDir}/modBed12.pl ${tRNAName}.bed12 ${tRNAName}_pre-tRNAs.bed12

##remove introns, make fasta from bed12
$bedtools getfasta -name -split -s -fi ${genomeName}.fa -bed ${tRNAName}_pre-tRNAs.bed12 -fo ${tRNAName}_pre-tRNAs.fa

##add pre-tRNAs as extra chromosoms to the genome (get the artificial genome)
cat ${genomeName}.masked.fa ${tRNAName}_pre-tRNAs.fa > ${genomeName}_artificial.fa

##indexing artificial genome
$samtools faidx ${genomeName}_artificial.fa
$segemehl -x ${genomeName}_artificial.idx -d ${genomeName}_artificial.fa

###create mature tRNA library
##remove the pseudogenes and the Undet-NNN hits (it is important to keep them for the masking - so you don't lose reads mapping to the genome)
##remove introns, make fasta from bed12

grep -v pseudo ${tRNAName}.csv | grep -v Undet > ${tRNAName}_nopseudo.csv

perl ${scriptDir}/tRNAscan2bed12.pl ${tRNAName}_nopseudo.csv ${tRNAName}_nopseudo.bed12

$bedtools getfasta -name -split -s -fi ${genomeName}.fa -bed ${tRNAName}_nopseudo.bed12 -fo ${tRNAName}_nopseudo.fa


##append mitocondrial tRNAs to the mature tRNA file:

cat ${tRNAmito} >>  ${tRNAName}_nopseudo.fa

##add CCA tail to tRNA chromosomes
perl ${scriptDir}/addCCA.pl ${tRNAName}_nopseudo.fa ${tRNAmature}.fa


###mature tRNA clustering
##only identical tRNAs were clustered
perl ${scriptDir}/clustering.pl ${tRNAmature}.fa ${tRNAmature}_cluster.fa ${tRNAmature}_clusterInfo.fa

##indexing tRNA cluster
$samtools faidx ${tRNAmature}_cluster.fa
$segemehl -x ${tRNAmature}_cluster.idx -d ${tRNAmature}_cluster.fa

$picard CreateSequenceDictionary R=${tRNAmature}_cluster.fa O=${tRNAmature}_cluster.dict
