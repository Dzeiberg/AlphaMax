#!/bin/bash
#SBATCH --partition=short
#SBATCH --cpus-per-task=10
#SBATCH --job-name=alphamax                    # sets the job name
#SBATCH --mem=32Gb                               # reserves 32 GB memory
#SBATCH --time=23:59:00                            # reserves machines/cores for ~24 hours.
#SBATCH --output=logs/makeCurves.%A_%a.out               # sets the standard output to be stored in file my_nice_job.%j.out, where %j is the job id)
#SBATCH --error=logs/makeCurves.%A_%a.err                # sets the standard error to be stored in file my_nice_job.%j.err, where %j is the job id)
#SBATCH --constraint=E5-2690v3@2.60GHz          # only consider reserving the machines that has Intel E5-2690v3 chip)
#SBATCH --array=1-1000 # job array index

module load matlab/R2020a
SetsPerJob=10;
TotalSets=1000000;
cd /home/zeiberg.d/alphamax
let "TotalJobs=$TotalSets/$SetsPerJob"
for ((i=1; i <=$TotalJobs; i++))
do 
	let "Start=$SetsPerJob*($i-1)+1";
	let "End=$i*$SetsPerJob";
	F=/scratch/zeiberg.d/alphamax/results/curves_paramsets_$Start_$End
	if test -f "$F";then
            echo "$F exists, skipping" >> logs/makeCurves.%A_%a.out
	    echo "" >> logs/makeCurves.%A_%a.err
        else
            srun matlab -nodisplay -nosplash -nodesktop -r "curves=makeCurves('/scratch/zeiberg.d/alphamax/syntheticParameters.mat', @(x,y)CurveConstructor(x,y,'useGPU',false),'setNumberStart',"$Start", 'setNumberEnd',"$End",'savePath','/scratch/zeiberg.d/alphamax/results/curves_paramsets_"$Start"_"$End"','quiet',true);exit;" &
	fi
done
wait

