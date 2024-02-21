function A4_RSA_MonteCarloCorr(args)
%% Create stat maps and then perform Monte Carlo correction
% 28.07.2023 ZK
% The input data are smoothed (runManySMOOTHINGs.sh)

addpath(genpath('.../CoSMoMVPA-master/'));
addpath(genpath('.../libsvm-master/'));

resDir = '../Data/';

typeRSA         = args.typeRSA;     % 'standardRSA' or 'GLMtype'
mask            = args.mask;             % 'standardBrain' or 'reliabilityMap'
voxThresh       = args.voxThresh;   % threshold for the reliability map
DSMTypes        = args.DSMTypes; 
nModelTypes     = length(DSMTypes);
modelName       = findModelName(DSMTypes);
neuralData_distMeas =  args.neuralData_distMeas;

thresh = 1.65;                                              % threshold for getting the maps after Monte Carlo
subID = {'S001','S002', 'S004','S005','S006','S007', 'S008', 'S010',...
    'S011','S012', 'S013','S014', 'S015','S016','S017','S018','S019',...
    'S021','S022','S023'};
nSubs = length(subID);

mask_fn = fullfile(resDir, 'MNI152_T1_2mm_brain_mask.nii.gz'); 
 
for iModel = 1:1%nModelTypes
    switch mask
        case 'standardBrain'
            resDir_thisMask = fullfile(resDir, sprintf(sprintf('/Results_RSA/whole-brain/mask_%s',mask)));
        case 'reliabilityMap'
            resDir_thisMask = fullfile(resDir, sprintf(sprintf('/Results_RSA/whole-brain/mask_%s/voxThresh=%s',mask,num2str(voxThresh,'%.2f'))));
    end
    
    switch typeRSA
        case 'standardRSA'
            outputDir = fullfile(resDir_thisMask, sprintf(sprintf('/%s/neuralData_%s/Model_%s/',typeRSA,neuralData_distMeas,char(modelName))));
        case 'GLMtype'
            temp_outputDir = fullfile(resDir_thisMask, sprintf(sprintf('/%s/%d_models/neuralData_%s',typeRSA,nModelTypes,neuralData_distMeas)));
            if nModelTypes==2
                outputDir = fullfile(temp_outputDir, sprintf('Models_%s%s/Model_%s/',char(modelName(1)),char(modelName(2)),char(modelName(iModel))));
            elseif nModelTypes==3
                outputDir = fullfile(temp_outputDir, sprintf('Models_%s%s%s/Model_%s/',char(modelName(1)),char(modelName(2)),char(modelName(3)),char(modelName(iModel))));
            elseif nModelTypes==4
                outputDir = fullfile(temp_outputDir, sprintf('Models_%s%s%s%s/Model_%s/',char(modelName(1)),char(modelName(2)),char(modelName(3)),char(modelName(4)),char(modelName(iModel))));
            end
    end
        
    for iSub = 1:nSubs
        individualMap = sprintf('rsm_searchlight_SS0_%s-2mm_mask-standBrain.nii.gz', char(subID{iSub}));
        groupMap{iSub} = cosmo_fmri_dataset(fullfile(outputDir, individualMap), 'mask', mask_fn);
        groupMap{iSub}.sa.targets = 1;
        groupMap{iSub}.sa.chunks = zeros(1,1)+iSub;
    end
    
    dsGroup = cosmo_stack(groupMap);
    switch mask
        case 'reliabilityMap'
            reliabilityMask = cosmo_fmri_dataset(fullfile(resDir, 'reliabilityMap_GROUP.nii.gz'), 'mask',mask_fn);
            theseTake = find(reliabilityMask.samples==1);
            
            reliableSamples = dsGroup.samples(:,theseTake);
            dsGroup.samples = reliableSamples;
            dsGroup.fa.i = dsGroup.fa.i(1,theseTake);
            dsGroup.fa.j = dsGroup.fa.j(1,theseTake);
            dsGroup.fa.k = dsGroup.fa.k(1,theseTake);
        case 'standardBrain'
            % do nothing
    end     
    dsGroup = cosmo_remove_useless_data(dsGroup);

    [~,p,~,stats] = ttest(dsGroup.samples);
    % [~,p,~,stats] = ttest(dsGroup.samples,1/c);
    dsGroup.samples(end+1,:) = mean(dsGroup.samples);
    dsGroup.samples(end+1,:) = stats.tstat;
    dsGroup.sa.targets(end+1:end+2,1) = 1;
    dsGroup.sa.chunks(end+1:end+2,1) = length(dsGroup.sa.chunks)+1;
    
    %Save the data
    fprintf('Saving...\n');
    cosmo_map2fmri(dsGroup, fullfile(outputDir, 'GROUP-RSA-Statmap_mask-standBrain.nii.gz'));
    
    %% MonteCarlo
    
    opt = struct();
    opt.cluster_stat = 'tfce'; %other options 'tfce', 'maxsize', 'max', maxsum'
    opt.niter = 5000;         % usually should be > 1000
    %opt.h0_mean = 1/c;   % was '0'
    opt.h0_mean = 0;
    opt.dh = 0.1;
    opt.nproc = 4;
    
    % Prepare the dataset
    ds = cosmo_slice(dsGroup, 1:nSubs, 1);
    ds_corrMap = dsGroup;
    %ds = cosmo_remove_useless_data(ds);
    nbrhood = cosmo_cluster_neighborhood(ds);
    
    ds_z = cosmo_montecarlo_cluster_stat(ds, nbrhood, opt);
    cosmo_map2fmri(ds_z, fullfile(outputDir, sprintf('GROUP-RSA-TFCE_nIter%d.nii.gz',opt.niter)));
    
    ds_corrMap = cosmo_slice(ds_corrMap, nSubs+2,1);
    ds_corrMap.sa.targets = 1;
    ds_corrMap.sa.chunks = 1;
    ds_corrMap.samples(ds_z.samples<thresh)=0;
    cosmo_map2fmri(ds_corrMap, fullfile(outputDir, sprintf('GROUP-RSA-TFCE_nIter%d_tMapThr165.nii.gz',opt.niter)));
end
    
end
