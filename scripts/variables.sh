#this script will be sourced at the beginning of every other script to define all the variables
#set up your project folder
project=yourprojectfolderpath (that will always be the folder from which you qsub the scripts)

#Executables

export RUN="singularity exec -e $project/scripts/trna_align-100120.simg"

bbduk="$RUN bbduk.sh"                     #BBMap version 36.14
fastqc="$RUN fastqc"                      #v0.11.8
samtools="$RUN samtools"                  #1.3 (using htslib 1.3)
tRNAscanSE="$RUN tRNAscan-SE"             #2.0.4 (September 2019)(infernal 1.1.2)
bedtools="$RUN bedtools"                  #v2.25.0
segemehl="$RUN segemehl.x"                #0.2.0-418
picardJar="picard.jar"                    #required by hoffmann is 2.2.1
picard="$RUN java -jar $picardJar"         
gatkJar="GenomeAnalysisTK.jar"            #required by hoffmann is 3.5-0-g36282e4
gatk="$RUN java -jar $gatkJar"

#directory paths:
ngsDir="${project}/data/ngs/"
scriptDir="${project}/scripts"
genomeDir="${project}/data/genome/"
workDir="${project}/analysis/"
adapterFile="${project}/data/ngs/adapter.fa"

#variables
#change here the names of the variable (without file extension!)

genomeName= #reference genome name
tRNAName= #trnascan output name
tRNAmature=$tRNAName
chrM= #name of the mitochondrial chromosome in your genome ("Mito" in yeast, "chrM" in mouse and human)
tRNAmito= #name of the mitochondrial tRNA fasta file that you have downloaded from mitotRNAdb INCLUDING FILE EXTENSION

#specify multimapper handling:
multimapperHandling=#set to "uniq" for only uniquely mapped reads, set to "phased" for only phased mapped reads (=if multimapping, the reads are not filtered out if they have the same mismatch pattern with all the loci they map to), set to "all" for all reads.
