function [refRDM] = prepareReferenceRDM_ROI(ROI,args)
% Last change: 28.07.2023
%brainMask = 'reliabilityMask'; % 'wholeBrain' or 'reliabilityMask'

addpath(genpath('../CoSMoMVPA-master/'));
addpath(genpath('../libsvm-master/'));

resDir = '../Data/';
neuralData_distMeas = args.neuralData_distMeas;
brainMask = args.brainMask;

subID = {'S001','S002', 'S004','S005','S006','S007', 'S008', 'S010',...
    'S011','S012', 'S013','S014', 'S015','S016','S017','S018','S019',...
    'S021','S022','S023'};
ROI_type = ROI;
    
sphere_size = 10;
load(fullfile(resDir, 'progs/matrices/listOfROIcoordinates.mat'));  % loaded as 'coord'
for iROI = 1:length(coord)
    if all(ismember(coord(iROI).name,ROI_type))
        ROI_hem = coord(iROI).hem;
        ROI_coord = coord(iROI).peak;
    else
        % do nothing
    end
end
newROIName = eraseBetween(ROI_type,1,1);

for iSub = 1:length(subjectIDs)
    targetDir = fullfile(resDir, subjectIDs{iSub});
    data_fn = fullfile(targetDir, 'results/');
    switch brainMask
        case 'wholeBrain'
            roiDir = sprintf('groupMap_ROIbased_%s_%s_%d-%d-%d_%dmm_avg',char(newROIName),ROI_hem,ROI_coord(1),ROI_coord(2),ROI_coord(3),sphere_size);
        case 'reliabilityMap'
            roiDir = sprintf('groupMap_ROIbased_%s_%s_%d-%d-%d_%dmm_avg_relMask',char(newROIName),ROI_hem,ROI_coord(1),ROI_coord(2),ROI_coord(3),sphere_size);
    end
    
    load(fullfile(data_fn, roiDir));
    vararg_diss.metric = 'squaredeuclidean';
    vararg_diss.center_data = true;
    ds_dsm = cosmo_dissimilarity_matrix_measure(dsGroup_avg,vararg_diss);
    temp = ds_dsm.samples;
    tmp_vec = (temp - min(temp))/(max(temp) - min(temp));
    temp = squareform(tmp_vec);
%     temp = squareform(ds_dsm.samples);
%     temp = pdist(dsGroup_avg.samples,neuralData_distMeas);
%     tmp_vec = (temp - min(temp))/(max(temp) - min(temp));
%     temp = squareform(tmp_vec);
    %temp(logical(eye(size(temp,1)))) = NaN;
    refRDM(:,:,iSub) = temp;
    %ref_RDM(:,:,iSub) = 1-corrcoef(dsGroup.samples');
end




% for iSub = 1:length(subjectIDs)
%     targetDir = fullfile(projectDir, subjectIDs{iSub});
%     data_fn = fullfile(targetDir, '/results/');
%     load(fullfile(data_fn,sprintf('groupMap_forROI-based-RSA_ROI_%d-%d-%d_100act', ROI_coord(1),ROI_coord(2),ROI_coord(3))));
%     temp = 1-corrcoef(dsGroup.samples');
%     tmp_vec = squareform(temp, 'tovector');
%     tmp_vec = tmp_vec/(max(tmp_vec));
%     temp = squareform(tmp_vec);
%     %temp(logical(eye(size(temp,1)))) = NaN;
%     refRDM(:,:,iSub) = temp;
%     %ref_RDM(:,:,iSub) = 1-corrcoef(dsGroup.samples');
% end


end

