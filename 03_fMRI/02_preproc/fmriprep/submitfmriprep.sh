#!/bin/bash

# Set a name for the job (-J or --job-name).
#SBATCH --job-name=submit_fmriprep_3

# Set the file to write the stdout and stderr to (if -e is not set; -o or --output).
#CHANGE HERE:  Rename for each subject
#SBATCH --output=fmriprep_job_13112.log

# Set the number of cores (-n or --ntasks).
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32

# Set the total memory. Units can be given in T|G|M|K.
#SBATCH --mem=128G

# Set the expected running time of your job (-t or --time).
# Formats are MM:SS, HH:MM:SS, Days-HH, Days-HH:MM, Days-HH:MM:SS

#SBATCH --time=48:00:00
#CHANGE HERE: RENAME participant label (eg. H22)

singularity run --cleanenv -B /fast/work/groups/ag_schlagenhauf/B01_FP1_WP2/:/B01_FP1_WP2 fmriprep-23.2.1.simg /B01_FP1_WP2/bids/ /B01_FP1_WP2/derivatives/fmriprep_v23.2.1/ participant --participant-label 13112 --nthreads 32 --low-mem --stop-on-first-crash -w /B01_FP1_WP2/wf_fmriprep/ --mem_mb 200000 --fs-no-reconall --ignore fieldmaps --fs-license-file /B01_FP1_WP2/code/license.txt
