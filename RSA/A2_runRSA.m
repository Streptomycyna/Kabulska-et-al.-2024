function A2_runRSA(args)
% 28.07.2023 ZK

% Add path for CoSMoMVPA
addpath(genpath('../CoSMoMVPA-master/'));
addpath(genpath('../libsvm-master/'));

resDir = '../Data/';
outputDir = fullfile(resDir, '../Results_RSA');
modelsDir = fullfile(resDir, '/RSA_models/');

typeRSA         =   args.typeRSA;     % 'standardRSA' or 'GLMtype'
mask            =   args.mask;        % 'standardBrain' or 'reliabilityMap'
voxThresh       =   args.voxThresh;   % threshold for the reliability map
DSMTypes        =   args.DSMTypes; 
nModelTypes     =   length(DSMTypes);
modelName       =   findModelName(DSMTypes);
neuralData_distMeas =  args.neuralData_distMeas;

smoothingVal = 0;
nvoxels_per_searchlight = 100;
nRuns = 8;

subID = {'S001','S002', 'S004','S005','S006','S007', 'S008', 'S010',...
    'S011','S012', 'S013','S014', 'S015','S016','S017','S018','S019',...
    'S021','S022','S023'};
nSubs = length(subID);

for iSub = 1:nSubs
    subjectID = char(subID(iSub));
    % First, load subject data
    data_fn = fullfile(resDir, 'Subject_data/');
    load(fullfile(data_fn,sprintf('%s_tMap.m',subjectID)));

    switch mask
        case 'reliabilityMap'
            mask_fn = fullfile(resDir,'MNI152_T1_2mm_brain_mask.nii.gz');
            reliabilityMask = cosmo_fmri_dataset(fullfile(resDir, 'reliabilityMap_GROUP.nii.gz'),'mask',mask_fn);
            theseTake = find(reliabilityMask.samples==1);

            reliableSamples = dsGroup.samples(:,theseTake);
            dsGroup.samples = reliableSamples;
            dsGroup.fa.i = dsGroup.fa.i(1,theseTake);
            dsGroup.fa.j = dsGroup.fa.j(1,theseTake);
            dsGroup.fa.k = dsGroup.fa.k(1,theseTake);
            
        case 'standardBrain'
            % do nothing

    end
    
    % Load the models
    switch typeRSA
        case 'standardRSA'
            load(fullfile(modelsDir, char(DSMTypes))); % loaded as 'RSAmodel'
        case 'GLMtype'
            for iType = 1:nModelTypes
                load(fullfile(modelsDir, sprintf('%s.mat',char(DSMTypes(iType))))); % as 'RSAmodel'
                modelTypeToDSM{iType} = RSAmodel;
            end
    end
    
    % Set measure
    measure = @cosmo_target_dsm_corr_measure;
    measure_args = struct();
    switch typeRSA
        case 'standardRSA'
            measure_args.target_dsm = RSAmodel;
        case 'GLMtype'    
            measure_args.glm_dsm = modelTypeToDSM;
    end
    measure_args.center_data = true;
    measure_args.type = 'Pearson';
    measure_args.metric = neuralData_distMeas; %'squaredEuclidean';

    % Choose radius for searchlight, find neighborhoods
    fprintf('Creating neighborhoods\n')
    nbrhood = cosmo_spherical_neighborhood(dsGroup, 'count', nvoxels_per_searchlight);
    
    % Run searchlight
    fprintf('Starting searchlight with size %g voxels per searchlight\n', nvoxels_per_searchlight)
    results = cosmo_searchlight(dsGroup, nbrhood, measure, measure_args);

    results_z = atanh(results.samples);
    results.samples = results_z;
    
    switch mask
        case 'standardBrain'
            outputDir_thisMask = fullfile(outputDir, sprintf('whole-brain/mask_%s',mask));
        case 'reliabilityMap'
            outputDir_thisMask = fullfile(outputDir, sprintf('whole-brain/mask_%s/voxThresh=%s',mask,num2str(voxThresh,'%.2f')));
    end
                   
    switch typeRSA
        case 'standardRSA'
            outputDir_thisModel = fullfile(outputDir_thisMask, sprintf('/%s/neuralData_%s/Model_%s/',typeRSA,measure_args.metric,char(modelName)));
        case 'GLMtype'
            temp_outputDir_thisModel = fullfile(outputDir_thisMask, sprintf('/%s/%d_models/neuralData_%s/',typeRSA,nModelTypes,measure_args.metric));
            if nModelTypes==2
                outputDir_thisModel = fullfile(temp_outputDir_thisModel, sprintf('Models_%s%s/',char(modelName(1)),char(modelName(2))));
            elseif nModelTypes==3
                outputDir_thisModel = fullfile(temp_outputDir_thisModel, sprintf('Models_%s%s%s/',char(modelName(1)),char(modelName(2)),char(modelName(3))));
            elseif nModelTypes==4
                outputDir_thisModel = fullfile(temp_outputDir_thisModel, sprintf('Models_%s%s%s%s/',char(modelName(1)),char(modelName(2)),char(modelName(3)),char(modelName(4))));
            end
    end
    
    if ~exist(outputDir_thisModel)
        mkdir(outputDir_thisModel)
    end
    cosmo_map2fmri(results, fullfile(outputDir_thisModel, sprintf('/rsm_searchlight_SS%d_%s-2mm_mask-standBrain.nii.gz', smoothingVal, subjectID)));
            
end


end

