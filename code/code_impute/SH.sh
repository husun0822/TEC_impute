#!/bin/bash
# The interpreter used to execute the script

#“#SBATCH” directives that convey submission options:

#SBATCH --job-name=SH
#SBATCH --mail-user=zhijunh@umich.edu
##SBATCH --mail-type=ARRAY_TASKS
#SBATCH --mail-type=begin,end
#SBATCH --cpus-per-task=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=5g
#SBATCH --time=10:00:00
#SBATCH --account=stats_dept1
#SBATCH --partition=standard
#SBATCH --output=./SHfit.log
#SBATCH --array=1-181

# The application(s) to execute along with its input arguments and options:
#python SHARP_compare.py $SLURM_ARRAY_TASK_ID
#python stat_low_res.py
#python Threshold.py
#Rscript emp_study.R $SLURM_ARRAY_TASK_ID
matlab -r "SHfit(${SLURM_ARRAY_TASK_ID})"
