#!/bin/bash

##############################################################################
# This script is used to run MELT on combining the results from all samples.
##############################################################################

##############################################################################
# Define the following variables:
# wkdir: The working directory to store scripts and logfiles
# outdir: The output directory for the MELT results
# pipeline: The path to the MELT pipeline script

pipeline="/staging/biology/u4432941/sv/melt/04_melt_makevcf.sh"
wkdir="/staging/biology/u4432941/sv/melt"
outdir="/staging/reserve/jacobhsu/TWB/TWB_1492_MEI/"
##############################################################################

DAY=$(date +%Y%m%d)

mkdir -p $wkdir/step4

# Individual analysis
for i in {ALU,LINE1,SVA}; do
    var_script="$wkdir/step4/${DAY}_melt_makeVCF_$i.sh"
    rsync "${pipeline}" "${var_script}"

    # Replace placeholders in the script
    sed -i "s|WKDIR|${outdir}|g" "${var_script}"
    sed -i "s|VAR|${i}|g" "${var_script}"

    # Submit the job
    sbatch $var_script
done
