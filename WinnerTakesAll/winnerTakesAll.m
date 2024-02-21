function winnerTakesAll
% 28.07.2023 ZK

resDir = '../Data/';
pcsDir = fullfile(resDir, 'Results_PCA/mask_reliabilityMap/voxThresh=0.25/standardRSA/neuralData_squaredEuclidean/');
outputDir = fullfile(resDir, 'Results_PCA/WinnerTakesAll');
nComp = 8;

subID = {'S001','S002', 'S004','S005','S006','S007', 'S008', 'S010',...
    'S011','S012', 'S013','S014', 'S015','S016','S017','S018','S019',...
    'S021','S022','S023'};
nSub = length(subjectIDs);

tMap_Group = [];
for thisPC = 1:nComp
    ds = cosmo_fmri_dataset(fullfile(pcsDir, sprintf('Component_%d/GROUP-RSA-TFCE_nIter5000_tMapThr165.nii.gz',thisPC)));
    tMap_Group(thisPC,:)=ds.samples(1,:);
end

thrCorr = linspace(0,0.05,11);
uniqueFeatures={};

for thisThr = 1:1 %length(thrCorr)
    
    thrToUse=thrCorr(thisThr);
    [winnersMat, newPrefMat] = summarizeActionHierarchy_ZK(tMap_Group,thrToUse);
    uniqueFeatures{1,thisThr} = unique(winnersMat);
    
    % Change the colors such that there are no empty numbers in between
    winnersMat(find(winnersMat==uniqueFeatures{1,1}(2)))=1;
    winnersMat(find(winnersMat==uniqueFeatures{1,1}(3)))=2;
    winnersMat(find(winnersMat==uniqueFeatures{1,1}(4)))=3;
    winnersMat(find(winnersMat==uniqueFeatures{1,1}(5)))=4;
    winnersMat(find(winnersMat==uniqueFeatures{1,1}(6)))=5;
    winnersMat(find(winnersMat==uniqueFeatures{1,1}(7)))=6;
    
    ds.samples=winnersMat';
    cosmo_map2fmri(ds, fullfile(outputDir, sprintf('winnerTakesAll_WINNERmat_AllPCs_allSub-mean_thr%0.3f.nii.gz',thrToUse)));
    
end






end

