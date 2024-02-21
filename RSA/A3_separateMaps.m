function A3_separateMaps(args)
%%% separate the maps
% last change: 28.07.2023 ZK

resDir = '../Data/';

typeRSA         =   args.typeRSA;     % 'standardRSA' or 'GLMtype'
mask            =   args.mask;        % 'standardBrain' or 'reliabilityMap'
voxThresh       =   args.voxThresh;   % threshold for the reliability map
DSMTypes        =   args.DSMTypes; 
nModelTypes     =   length(DSMTypes);
modelName       =   findModelName(DSMTypes);
neuralData_distMeas =  args.neuralDat_metric;

outputDir = fullfile(resDir, 'Results_RSA');
switch mask
    case 'standardBrain'
        outputDir_thisMask = fullfile(outputDir, sprintf(sprintf('whole-brain/mask_%s',mask)));
    case 'reliabilityMap'
        outputDir_thisMask = fullfile(outputDir, sprintf(sprintf('whole-brain/mask_%s/voxThresh=%s',mask,num2str(voxThresh,'%.2f'))));
end

temp_outputDir_thisModel = fullfile(outputDir_thisMask, sprintf(sprintf('/%s/%d_models/neuralData_%s',typeRSA,nModelTypes,neuralData_distMeas)));
if nModelTypes==2
    outputDir_thisModel = fullfile(temp_outputDir_thisModel, sprintf('Models_%s%s/',char(modelName(1)),char(modelName(2))));
elseif nModelTypes==3
    outputDir_thisModel = fullfile(temp_outputDir_thisModel, sprintf('Models_%s%s%s/',char(modelName(1)),char(modelName(2)),char(modelName(3))));
elseif nModelTypes==4
    outputDir_thisModel = fullfile(temp_outputDir_thisModel, sprintf('Models_%s%s%s%s/',char(modelName(1)),char(modelName(2)),char(modelName(3)),char(modelName(4))));
end

subID = {'S001','S002', 'S004','S005','S006','S007', 'S008', 'S010',...
    'S011','S012', 'S013','S014', 'S015','S016','S017','S018','S019',...
    'S021','S022','S023'};
nSubs=length(subID);

for iSub = 1:nSubs
    subjectID = char(subID(iSub));
    ds = cosmo_fmri_dataset(fullfile(outputDir_thisModel,sprintf('rsm_searchlight_SS0_%s-2mm_mask-standBrain.nii.gz',subjectID)));
    for iModel = 1:1%nModelTypes
        ds_new = ds;
        ds_new.samples = [];
        ds_new.samples(1,:)=ds.samples(iModel,:);
        if ~exist(fullfile(outputDir_thisModel, sprintf('/Model_%s',char(modelName(iModel)))))
            mkdir(fullfile(outputDir_thisModel, sprintf('/Model_%s',char(modelName(iModel)))));
        end
        cosmo_map2fmri(ds_new, fullfile(outputDir_thisModel, sprintf('/Model_%s/rsm_searchlight_SS0_%s-2mm_mask-standBrain.nii.gz',char(modelName(iModel)),subjectID)));
    end
end
clear

end

