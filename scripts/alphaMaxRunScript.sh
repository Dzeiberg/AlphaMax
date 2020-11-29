#!/bin/bash

#SBATCH --job-name=alphamax                    # sets the job name
#SBATCH --mem=32Gb                               # reserves 32 GB memory
#SBATCH --time=23:45:00                            # reserves machines/cores for 17 hours.
#SBATCH --output=alphaMax/alphaMax.%A_%a.out               # sets the standard output to be stored in file my_nice_job.%j.out, where %j is the job id)
#SBATCH --error=alphaMaxJobs/alphaMax.%A_%a.err                # sets the standard error to be stored in file my_nice_job.%j.err, where %j is the job id)
#SBATCH --constraint=E5-2690v3@2.60GHz          # only consider reserving the machines that has Intel E5-2690v3 chip)
#SBATCH --array=1-56 # job array index

module load matlab/R2018a

for i in $(eval echo {$1..$2});
do 
    # echo $i
    srun matlab -nodisplay -nosplash -nodesktop -r "getSingleEstimateSlurm("$i")" &
done
wait

