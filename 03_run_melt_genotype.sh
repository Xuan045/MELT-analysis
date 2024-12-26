#!/bin/bash

######################################################################
# This script is used to run MELT on individual samples.
# The script will copy the CRAM files to the destination directory,
# prepare the MELT analysis, and submit the job array for each batch
# (40 samples each batch)
######################################################################

################################################################################
# Define the following variables:
# source_dir: The directory containing the CRAM files
# processed_dir: The directory containing the processed CRAM files from step 1
# destination_dir: The directory to copy the CRAM and processed files to
# wkdir: The working directory to store scripts and logfiles
# outdir: The output directory for the MELT results
# pipeline: The path to the MELT pipeline script

source_dir="/staging/biology/u4432941/s3/TWB1492_Dragenv4.0.3"
processed_dir="/staging/reserve/jacobhsu/TWB/TWB_1492_MEI/processed"
destination_dir="/work/u4432941/TWB_CRAM"
wkdir="/staging/biology/u4432941/sv/melt/step3"
outdir="/staging/reserve/jacobhsu/TWB/TWB_1492_MEI/"
pipeline="/staging/biology/u4432941/sv/melt/03_melt_genotype.sh"
################################################################################

DAY=$(date +%Y%m%d)
set -euo pipefail

# logfile
log_file="${DAY}_melt_genotype.log"
exec > "$log_file" 2>&1

# Create the directory for the list files
mkdir -p $wkdir

listdir="/staging/biology/u4432941/sv/melt/step3/fail_list"
# listdir="/staging/biology/u4432941/sv/melt/step1/move_list"

n=$(ls ${listdir}/sample_id_* | wc -l)
# Process each batch
for i in $(seq -f "%02g" 0 $((n-1))); do
    echo "Processing sample_id_$i"

    # Generate the sample list file
    job_list_file="${wkdir}/job_list_${i}.txt"
    rm -f "$job_list_file"
    
    counter=1
    while read -r ID; do
        # Copy files to the destination directory
        cp "$source_dir/${ID}_dragen_v4.0.3_hs38DH_graph.cram" "$destination_dir"
        cp $processed_dir/${ID}_* "$destination_dir"

        # Append the line number and ID to job_list_file
        echo -e "${counter}\t${ID}" >> "$job_list_file"
        counter=$((counter + 1))

        sample_script="${wkdir}/${DAY}_melt_genotype_batch${i}.sh"
        rsync "${pipeline}" "${sample_script}"

        # Replace placeholders in the script
        sed -i "s|WKDIR|${outdir}|g" "${sample_script}"
        sed -i "s|CONFIG|${job_list_file}|g" "${sample_script}"
        sed -i "s|FILEDIR|${destination_dir}|g" "${sample_script}"
        sed -i "s|SAMPLENAME|\$(awk -v ArrayTaskID=\$SLURM_ARRAY_TASK_ID '\$1==ArrayTaskID {print \$2}' \$config)|g" "${sample_script}"
        
    done < "${listdir}/sample_id_$i"

    # Submit the job array
    job_array_id=$(sbatch --parsable \
        --array=1-$(wc -l < "$job_list_file") \
        -o "${wkdir}/${DAY}_melt_genotype_batch${i}.out" \
        -e "${wkdir}/${DAY}_melt_genotype_batch${i}.err" \
        "$sample_script")

    echo "Submitted job array $job_array_id for batch $i"
    sleep 30

    # Wait for job completion
    while true; do
        # Get the job status
        sacct_output=$(sacct -j "${job_array_id}" --format="State" --noheader)

        # Check if the sacct output is empty
        if [[ -z "$sacct_output" ]]; then
            echo "Warning: sacct output is empty. Retrying..."
            sleep 60
            continue
        fi

        # Check if there are any PENDING or RUNNING tasks
        if echo "$sacct_output" | grep -qE "PENDING|RUNNING"; then
            sleep 60
            continue
        else
            echo "No tasks are PENDING or RUNNING. Checking for failures..."

            # Check for failed tasks
            index=1
            while read -r state; do
                if [[ "$state" == "FAILED" ]]; then
                    sample_id=$(awk -v line="$index" 'NR==line {print $2}' "$job_list_file")
                    echo "Fail sample: $sample_id"
                fi
                index=$((index + 1))
            done <<< "$(echo $sacct_output | awk '{for(i=1;i<=NF;i++) if(i%3==1) print $i}')"

            echo "File sample_id_$i finished. Moving to the next batch."
            break
        fi
    done
    
    # Clean up the destination directory
    echo "Cleaning up the destination directory"
    while read -r ID; do
        rm ${destination_dir}/${ID}*
    done < "${listdir}/sample_id_$i"

done

echo "All batches processed successfully."