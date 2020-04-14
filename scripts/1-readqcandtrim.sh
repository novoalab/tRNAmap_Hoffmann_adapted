#directory paths
cwd=$(pwd)

source ${cwd}/scripts/variables.sh

## pre- and post-quality control, adapter and quality trimming using BBduk
cd ${ngsDir}


## pre-trimming quality control
for i in $(ls ${ngsDir}/*.fastq.gz)
do
    $fastqc -q ${bi}    
done

## adapter and quality trimming using BBduk
for i in $(ls ${ngsDir}/*.fastq.gz)
do
  bi=$(basename $i .fastq.gz)
  $bbduk in=$i  out=${ngsDir}/${bi}_trimmed.fastq ref=${adapterFile} mink=8 ktrim=r k=10 rcomp=t hdist=1 qtrim=rl trimq=25 minlength=50 maxlength=100 2> ${ngsDir}/${bi}.bbduk.log
done

## post-trimming quality control
for i in $(ls ${ngsDir}/*trimmed.fastq)
do
  bi=$(basename $i .fastq)
  gzip $i
  $fastqc -q ${ngsDir}/${bi}.fastq.gz
done
