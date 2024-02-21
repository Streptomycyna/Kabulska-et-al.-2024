%%% Check the correlation of DNN with the ROIs (bilateral V1)
% last change: 28.07.2023

addpath(genpath('../CoSMoMVPA-master/'));
addpath(genpath('../libsvm-master/'));

resDir = '../Data/';

modelsDir = fullfile(resDir, 'RSA_models/');
neuralData_distMeas = 'squaredEuclidean';
outputDir = fullfile(resDir,sprintf('Results_correlations/DNN-ROIs/neuralData_%s',neuralData_distMeas));
DNNType = 'Resnet50'; % 'VGG16' or 'Resnet50' or 'AlexNet'
corrType = 'Pearson';
brainMask = 'wholeBrain'; % 'wholeBrain' or 'reliabilityMask'

%layers to remove (downsmaple layers)
layersRemove = [5,15,28,47];
% Specify ROI
ROI_types = {'lV1','rV1'};
corr_list_All = [];

for iROI = 1:length(ROI_types)
    corr_list = [];
    pvalue_list = [];
    
    ROI = ROI_types{iROI};
    fprintf('Running between-model correlation within %s ROI\n', ROI)
    args.neuralData_distMeas = neuralData_distMeas;
    args.brainMask = brainMask;
    refRDMs = prepareReferenceRDM_ROI(ROI,args);
    
    nDNN_layers = 54; %length
    dnnModelDir = fullfile(modelsDir, 'Resnet50/');
    load(fullfile(resDir,'Resnet50Names'));
    labels = Resnet50Names;
    
    for iLayer = 1:nDNN_layers
        load(fullfile(dnnModelDir, sprintf('RDM_Resnet50_layer%d.mat', iLayer)));
        matrixDNN = RSAmodel;
        for iSub = 1:size(refRDMs,3)
            thisSub_mat = refRDMs(:,:,iSub);
            corr_list(iSub,iLayer) = corr(squareform(thisSub_mat,'tovector')', squareform(matrixDNN,'tovector')','Type',corrType);
        end
    end
    
    corr_list(:,layersRemove)=[]; % rm layers which are downsample
    
    if iROI == 1
        corr_list_All(1:20,1:50) = corr_list;
    elseif iROI == 2
        corr_list_All(21:40,1:50) = corr_list;
    end
end

fileName = fullfile(outputDir, sprintf('correlation_%s-bothV1',DNNType));
save(fileName,'corr_list_All');

% visualize the results
figure;
bar(mean(corr_list_All));
title(sprintf('correlation %s - V1',DNNType))
ylabel('Pearson correlation')
ylim([-0.03 0.07])
set(gca,'xtick', 1:nDNN_layers, 'xticklabel',labels, 'xticklabelrotation',45)
hold on
semCorr = std(corr_list)/sqrt(size(corr_list,1));
errorbar(1:nDNN_layers, mean(corr_list), semCorr,'Color',[0 0 0],'LineWidth',2,'LineStyle','none');
hold on

    
set(gcf, 'Units', 'Inches', 'Position', [0, 0, 15, 10], 'PaperUnits', 'Inches', 'PaperSize', [10,10])

switch brainMask
    case 'wholeBrain'
        savefig(fullfile(outputDir, sprintf('Corr %s - AllROIs',DNNType)))
        saveas(gcf,fullfile(outputDir, sprintf('Corr %s - AllROIs.jpg',DNNType)))
    case 'reliabilityMask'
        savefig(fullfile(outputDir, sprintf('Corr %s - AllROIs_relMask',DNNType)))
        saveas(gcf,fullfile(outputDir, sprintf('Corr %s - AllROIs_relMask.jpg',DNNType)))
end

close all
clear all