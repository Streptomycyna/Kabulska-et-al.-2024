% Calculate correlations between RDMs for RSA for VIF
% 28.07.2023 ZK

resDir = '../Data/';
modelDir = fullfile(resDir, 'RSA_models/');
outputDir = fullfile(resDir, 'Results_VIF');
modelNames = {'category', 'feature', 'PC1','PC2','PC3','PC4',...
    'PC5','PC6','PC7','PC8','gist','lowLvVisual'};

% make vectors from RDMs
load(fullfile(modelDir, 'inverseMDSModel.mat')); %as RSAmodel
cat_vec = squareform(RSAmodel,'tovector')';
load(fullfile(modelDir, 'multidimFeatureModel.mat'));
feat_vec = squareform(RSAmodel,'tovector')';
load(fullfile(modelDir, 'PCAmodels/PCAFeat_Comp1.mat'));
PC1_vec = squareform(PCAFeat_Comp,'tovector')';
load(fullfile(modelDir, 'PCAmodels/PCAFeat_Comp2.mat'));
PC2_vec = squareform(PCAFeat_Comp,'tovector')';
load(fullfile(modelDir, 'PCAmodels/PCAFeat_Comp3.mat'));
PC3_vec = squareform(PCAFeat_Comp,'tovector')';
load(fullfile(modelDir, 'PCAmodels/PCAFeat_Comp4.mat'));
PC4_vec = squareform(PCAFeat_Comp,'tovector')';
load(fullfile(modelDir, 'PCAmodels/PCAFeat_Comp5.mat'));
PC5_vec = squareform(PCAFeat_Comp,'tovector')';
load(fullfile(modelDir, 'PCAmodels/PCAFeat_Comp6.mat'));
PC6_vec = squareform(PCAFeat_Comp,'tovector')';
load(fullfile(modelDir, 'PCAmodels/PCAFeat_Comp7.mat'));
PC7_vec = squareform(PCAFeat_Comp,'tovector')';
load(fullfile(modelDir, 'PCAmodels/PCAFeat_Comp8.mat'));
PC8_vec = squareform(PCAFeat_Comp,'tovector')';
load(fullfile(modelDir, 'gist.mat'));
gist_vec = squareform(RSAmodel,'tovector')';
load(fullfile(modelDir, 'Resnet50_conv2_1.1.mat'));
lowLvVisual_vec = squareform(RSAmodel,'tovector')';


% calculate correlations
allModels = [cat_vec,feat_vec,PC1_vec,PC2_vec,PC3_vec,PC4_vec,PC5_vec,...
    PC6_vec,PC7_vec,PC8_vec,gist_vec,lowLvVisual_vec];
corrAll = corrcoef(allModels);
corrAll_round = round(corrAll, 2);

% visualize the correlations
figure;imagesc(corrAll)
colorbar
set(gca,'ytick',1:length(corrAll),'yticklabel',modelNames)
set(gca,'xtick',1:length(corrAll),'xticklabel',modelNames)
xtickangle(45)

%set(gcf, 'Units', 'Inches', 'Position', [0, 0, 6, 6])
saveas(gcf,fullfile(outputDir, 'correlationMat_AllModels.jpg'))
savefig(gcf,fullfile(outputDir, 'correlationMat_AllModels.fig'))
close

heatmap(corrAll_round, 'XData',modelNames,'YData', modelNames)
colormap(parula)
saveas(gcf,fullfile(outputDir, 'correlationMat_AllModels_withCorrValNumbers.jpg'))
savefig(gcf,fullfile(outputDir, 'correlationMat_AllModels_withCorrValNumbers.fig'))
close

% Calculate VIF
vif = diag(inv(corrAll));




