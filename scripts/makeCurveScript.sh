#!/bin/bash

set MALLOC_CHECK=0
JobsPerLoop=2;
TOTALJOBS=100000;
let "NumLoops=$TOTALJOBS/$JobsPerLoop";
echo running $NumLoops loops
for ((loopNum=1; loopNum<=$NumLoops; loopNum++))
do
	for ((n=1; n <=$JobsPerLoop; n++))
	do
		let "jobNum=$JobsPerLoop*($loopNum-1)+$n";
		F=../data/curves_paramset_$jobNum.mat
		if test -f "$F";then
			echo "$F exists, skipping"
		else
			echo starting $loopNum - $jobNum;
			matlab  -nodisplay -nosplash - nodesktop -r "curves = makeCurves('../data/syntheticParameters.mat',@(x,y)CurveConstructor(x,y), 'setNumberStart', "$jobNum", 'setNumberEnd', "$jobNum", 'savePath','../data/curves_paramset_"$jobNum".mat','quiet',true);exit;" > logs/out_$jobNum.out &
			pids[${i}]=$!
		fi
	done

	# wait for all pids
	for pid in ${pids[*]}; do
	    wait $pid
	done
done


# SetsPerJob=100;
# TotalSets=100000;
# JobsPerLoop=2;
# let "TotalJobs=$TotalSets/$SetsPerJob"
# let "NumLoops=$TotalJobs/$JobsPerLoop"
# for ((loopNum=1; loopNum<=$NumLoops; loopNum++))
# do
# 	for ((n=1; n <=$JobsPerLoop; n++))
# 	do
# 		let "jobNum=$JobsPerLoop*($loopNum-1)+$n";
# 	done
# done


# for ((i=1; i <=$TotalJobs; i++))
# do 
# 	let "Start=$SetsPerJob*($i-1)+1";
# 	let "End=$i*$SetsPerJob";
#     matlab -nodisplay -nosplash -nodesktop -r "curves=makeCurves('../data/syntheticParameters.mat', @(x,y)CurveConstructor(x,y),'setNumberStart',"$Start", 'setNumberEnd',"$End",'savePath','../data/curves_paramsets_"$Start"_"$End"','quiet',true);exit;"> logs/out_$Start_$End.out &
#     pids[${i}]=$!
# done