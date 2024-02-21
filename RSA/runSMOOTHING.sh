#!/bin/bash 
###################
# 20.05.2022
###################
# Run SMOOTHING to smooth data after RSA and before correction, Gaussian 5mm
# Example: ./runSMOOTHING.sh S01 reliabilityMap GLMtype inverseMDSModel 0.25

SUB=$1
PROJECT_DIR=/Data
SMOOTHING_VAL=0
MASK_TYPE=$2 #standardBrain or reliabilityMap
RSA_TYPE=$3 #standardRSA or GLMtype
MODEL=$4
nModels=3 #for GLM-based

iFirstModel=1;
iLastModel=1;

VOX_THRESH=$5

echo "Running SMOOTHING on ${SUB}"

for ((iModel=$iFirstModel;iModel<=$iLastModel;iModel++))
do
	echo "Smoothing component $MODEL"

	## define the mask
	if [ "$MASK_TYPE" == "standardBrain" ]
	then
		#echo "Mask type is standard brain"
		MASK_DIR=${PROJECT_DIR}/Results_RSA/whole-brain/mask_$MASK_TYPE
	elif [ "$MASK_TYPE" == "reliabilityMap" ]
	then
		#echo "RSA type is GLM-based RSA"
		MASK_DIR=${PROJECT_DIR}/Results_RSA/whole-brain/mask_$MASK_TYPE/voxThresh=${VOX_THRESH}
	elif [ "$MASK_TYPE" == "L_LOTC" ]
	then
		#echo "RSA type is GLM-based RSA"
		MASK_DIR=${PROJECT_DIR}/Results_RSA/$MASK_TYPE/mask_$MASK_TYPE
	elif [ "$MASK_TYPE" == "R_LOTC" ]
	then
		#echo "RSA type is GLM-based RSA"
		MASK_DIR=${PROJECT_DIR}/Results_RSA/$MASK_TYPE/mask_$MASK_TYPE	
	else
		echo "Error. Mask type not indicated"
	fi

	# define the RSA type
	if [ "$RSA_TYPE" == "standardRSA" ]
	then
		#echo "RSA type is standard RSA"
		MAP_DIR=${MASK_DIR}/$RSA_TYPE/neuralData_squaredEuclidean/Model_${MODEL}
	elif [ "$RSA_TYPE" == "GLMtype" ]
	then
		#echo "RSA type is GLM-based RSA"
		#MAP_DIR=${MASK_DIR}/$RSA_TYPE/${nModels}_models/neuralData_squaredEuclidean/Models_${MODEL}Resnet50_layer1_0conv1/Model_${MODEL}
		MAP_DIR=${MASK_DIR}/$RSA_TYPE/${nModels}_models/neuralData_squaredEuclidean/Models_${MODEL}gistResnet50_layer1_0conv1/Model_${MODEL}
	else
		echo "Error. RSA type not indicated"
	fi

	# Save unsmoothed data first to have a backup
	UNSMOOTHED_DIR=$MAP_DIR/unsmoothed
	mkdir -p $UNSMOOTHED_DIR
	if [ -z "$(ls -A $UNSMOOTHED_DIR)" ]
	then
		cp -a $MAP_DIR/*.nii.gz $UNSMOOTHED_DIR
	fi

	MAP_IN=${MAP_DIR}/rsm_searchlight_SS${SMOOTHING_VAL}_${SUB}-2mm_mask-standBrain.nii.gz
	MAP_OUT=${MAP_DIR}/rsm_searchlight_SS${SMOOTHING_VAL}_${SUB}-2mm_mask-standBrain.nii.gz

	fslmaths ${MAP_IN} -kernel gauss 2.1233226 -fmean ${MAP_OUT}

done
echo "${SUB} done!"

