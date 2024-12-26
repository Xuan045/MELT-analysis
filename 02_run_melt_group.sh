#!/bin/bash

#########################################################################################
# This script is used to run MELT on group samples.
# The script will prepare the MELT analysis, and submit the job array for each MEI type
#########################################################################################

#########################################################################################
# Define the following variables:
# wkdir: The working directory to store scripts and logfiles
# outdir: The output directory for the MELT results
# pipeline: The path to the MELT pipeline script

wkdir="/staging/biology/u4432941/sv/melt"
outdir="/staging/reserve/jacobhsu/TWB/TWB_1492_MEI/"
pipeline="/staging/biology/u4432941/sv/melt/02_melt_group.sh"
#########################################################################################

DAY=$(date +%Y%m%d)

mkdir -p $wkdir/step2

# Individual analysis
for i in {ALU,LINE1,SVA}; do
    var_script="$wkdir/step2/${DAY}_melt_group_$i.sh"
    rsync "${pipeline}" "${var_script}"

    # Replace placeholders in the script
    sed -i "s|WKDIR|${outdir}|g" "${var_script}"
    sed -i "s|VAR|${i}|g" "${var_script}"

    # Submit the job
    sbatch $var_script
done
