#!/bin/bash 
# 20.05.2022
###################
# Running many SMOOTHINGs for RSA

iStartSUB=1;
iEndSUB=23;

MASK_TYPE=reliabilityMap #standardBrain or reliabilityMap
RSA_TYPE=GLMtype #standardRSA or GLMtype
MODEL=inverseMDSModel
VOX_THRESH=0.25

for ((iSub=$iStartSUB;iSub<=$iEndSUB;iSub++))
do
	echo "iSub is $iSub"
	if [[ $iSub -eq 3 ]] || [[ $iSub -eq 9 ]] || [[ $iSub -eq 20 ]]
	then
		# skip
		echo "no subject"
	else
		printf -v SUB "RESPACT%03d" $iSub
		#echo "Running SMOOTHING for subject $SUB"
		./runSMOOTHING.sh $SUB $MASK_TYPE $RSA_TYPE $MODEL $VOX_THRESH
	fi
done
