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
		F=data/curves_paramset_$jobNum.mat
		if test -f "$F";then
			echo "$F exists, skipping"
		else
			echo starting $loopNum - $jobNum;
			matlab  -nodisplay -nosplash - nodesktop -r "curves = makeCurves('data/syntheticParameters.mat',@(x,y)CurveConstructor(x,y), 'setNumber', "$jobNum", 'savePath','data/curves_paramset_"$jobNum".mat','quiet',true);exit;" > logs/out_$jobNum.out &
			pids[${i}]=$!
		fi
	done

	# wait for all pids
	for pid in ${pids[*]}; do
	    wait $pid
	done
done
