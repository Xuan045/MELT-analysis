#!/bin/bash
#SBATCH -A MST109178        # Account name/project number
#SBATCH -J melt_group_VAR      # Job name
#SBATCH -p ngs186G           # Partition Name 等同PBS裡面的 -q Queue name
#SBATCH -c 28               # 使用的core數 請參考Queue資源設定
#SBATCH --mem=186g           # 使用的記憶體量 請參考Queue資源設定
#SBATCH -o melt_group_VAR_out.log          # Path to the standard output file 
#SBATCH -e melt_group_VAR_err.log 
#SBATCH --mail-user=
#SBATCH --mail-type=FAIL


##set tool path
MELT="/opt/ohpc/Taiwania3/pkg/biology/MELT/build/MELTv2.2.2"
BCFTOOLS="/opt/ohpc/Taiwania3/pkg/biology/BCFtools/bcftools_v1.13/bin/bcftools"
BOWTIE="/opt/ohpc/Taiwania3/pkg/biology/BOWTIE/bowtie2_v2.4.2/bowtie2"
SAMTOOLS="/opt/ohpc/Taiwania3/pkg/biology/SAMTOOLS/SAMTOOLS_v1.18/bin/samtools"
VCFTOOLS="/opt/ohpc/Taiwania3/pkg/biology/VCFtools/vcftools_v0.1.16/bin"
BGZIP="/opt/ohpc/Taiwania3/pkg/biology/HTSLIB/htslib_v1.13/bin"


wkdir=WKDIR
# Should be ALU, LINE1, SVA
var=VAR

ref_file=/staging/reserve/paylong_ntu/AI_SHARE/reference/HLA_Ref/bwa.kit/hs38DH.fa
ref=hs38DH
mem=185G
melt_list=${MELT}/me_refs/Hg38/

##set working directory
vardir="${wkdir}/${var}"

java -Xmx$mem -jar ${MELT}/MELT.jar GroupAnalysis \
    -discoverydir $vardir \
    -w $vardir \
    -t ${melt_list}/${var}_MELT.zip \
    -h ${ref_file} \
    -n ${MELT}/add_bed_files/Hg38/Hg38.genes.bed
