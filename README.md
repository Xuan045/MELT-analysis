# MELT Pipeline README

This repository contains a set of scripts for running the **Mobile Element Locator Tool (MELT)** pipeline. MELT is a tool used to identify and genotype mobile element insertions (MEIs).

Reference: Gardner EJ, Lam VK, Harris DN, Chuang NT, Scott EC, Pittard WS, Mills RE; 1000 Genomes Project Consortium; Devine SE. The Mobile Element Locator Tool (MELT): population-scale mobile element discovery and biology. Genome Res. 2017 Nov;27(11):1916-1929. doi: 10.1101/gr.218032.116. Epub 2017 Aug 30. PMID: 28855259; PMCID: PMC5668948.

## File Descriptions

- **`01_melt_indv.sh`** and **`01_run_melt_indv.sh`**  
  Scripts for running the individual analysis step of the MELT pipeline.

    The script copy CRAM files to the destination directory, preprocess the CRAM files, and prepare them for individual MELT analysis. Additionally, it submit a job array for each batch, with 40 samples per batch.
  
- **`02_melt_group.sh`** and **`02_run_melt_group.sh`**  
  Scripts for running the group analysis step of the MELT pipeline.
  
- **`03_melt_genotype.sh`** and **`03_run_melt_genotype.sh`**  
  Scripts for performing the genotyping step of the MELT pipeline.
  
- **`04_melt_makevcf.sh`** and **`04_run_melt_makevcf.sh`**  
  Scripts for merging the results into a final VCF file.

---


## How to Use the Scripts

### 1. Individual Analysis
Run the individual analysis step using the following command:
```bash
bash 01_run_melt_indv.sh
```
This step identifies MEIs in individual samples.

### 2. Group Analysis
Run the group analysis step:
```bash
bash 02_run_melt_group.sh
```
This step consolidates results across samples to create a group-specific MEI catalog.

### 3. Genotyping
Perform the genotyping step:
```bash
bash 03_run_melt_genotype.sh
```
This step genotypes the MEIs identified in the group step for all samples.

### 4. Create VCF
Generate the final VCF file:
```bash
bash 04_run_melt_makevcf.sh
```
This combines the genotyped results into a single VCF file.

---

## Configuration

Each `*_run_melt_*.sh` script calls the corresponding `*_melt_*.sh` script. Modify the `*_run_melt_*.sh` scripts to set the following parameters:

---

## Example Workflow

Below is an example workflow for running the MELT pipeline:

```bash
# Step 1: Individual analysis
bash 01_run_melt_indv.sh

# Step 2: Group analysis
bash 02_run_melt_group.sh

# Step 3: Genotyping
bash 03_run_melt_genotype.sh

# Step 4: Merge results into a VCF
bash 04_run_melt_makevcf.sh
```
