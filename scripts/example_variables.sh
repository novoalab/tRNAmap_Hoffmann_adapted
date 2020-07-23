#directory paths
cwd=$(pwd)

#specify multimapper handling
# set to uniq for only uniq mapped reads
# set to phased for only phased mapped reads# set to all for all reads
multimapperHandling="phased"


#change here your directory paths
ngsDir="${cwd}/data/ngs/"
scriptDir="${cwd}/scripts"
genomeDir="${cwd}/data/genome/"
workDir="${cwd}/analysis/"
adapterFile="${cwd}/data/ngs/adapter.fa"
postprocessingdir="${workDir}/testdir"

#program paths
#change here your program paths
#the workflow was tested at the following tools versions (see comments)

export RUN="singularity exec -e /users/enovoa/scruciani/TRMT1L/docker/trna_align-test.simg"

bbduk="$RUN bbduk.sh"                                                   #BBMap version 36.14 Best install via 'conda install bbmap'
fastqc="$RUN fastqc"                                                    #v0.11.4
samtools="$RUN samtools"                                                #1.3 (using htslib 1.3)
tRNAscanSE="$RUN tRNAscan-SE"                                           #1.3.1 (January 2012)
bedtools="$RUN bedtools"                                                #v2.25.0
segemehl="$RUN segemehl.x"                                              #0.2.0-418
picardJar="/users/enovoa/scruciani/soft/picard.jar"                                                  #2.2.1
picard="$RUN java -jar $picardJar"
gatkJar="/users/enovoa/scruciani/TRMT1L/docker/scripts/GenomeAnalysisTK.jar"       #3.5-0-g36282e4
gatk="java -jar $gatkJar"

# variables
#change here the names of the variable
genomeName="GRCm38.primary_assembly.genome"
tRNAName="mod-aware"
tRNAmature="mm10_trnadb_trnas_130420"
