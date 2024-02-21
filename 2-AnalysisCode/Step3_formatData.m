% Leyla Tarhan
% ltarhan@g.harvard.edu
% 9/2019
% MATLAB R2017b

% format data about reliable and active voxels for easier access in Step4. 
    
% output: 
    % - thresholds: voxel inclusion thresholds based on reliability and
    % activity
    % - brainPatterns: betas in all active and reliable voxels, in response
    % to all conditions    

% -------------------------------------------------------------------------
% To use this script:
    % (1) run Step0_makeSubjectModels for the dataset you're interested in.
    % The resulting SubjectModels file should save in the same directory as
    % this script.
    % (2) run Step1_getReliableVoxels to define all reliable voxels.
    % (3) run Step2_getActiveVoxels to define all active voxels.
    % (4) optional: change the 'dataSetName' variable to toggle between the 2
    % datasets:
        % 'ActionMap': responses to 60 everyday action videos
        % 'ExploringObjects': responses to 72 everyday objects

%% clean up

clear all
close all
clc

%% customize variables

% see notes in header for how to alter these variables to run this script

% dataset
dataSetName = 'ActionMap'; % 'ActionMap' or 'ExploringObjects'

%% set up subjects

fprintf('Formatting data for %s...\n', dataSetName)

% load in SubjectModels, with paths to all the datafiles you need
smName = sprintf('SubjectModels_%s.mat', dataSetName);
load(smName);

% check it out:
SubjectModels
GroupModel

%% set up file structure

% directory to save formatted data in:
saveDir = fullfile('..', '3-Results', dataSetName, 'Step3-FormatData');
if ~exist(saveDir, 'dir'); mkdir(saveDir); end

% directory with ROI structs:
roiDir = fullfile('..', '1-Data', dataSetName, 'ROI Structs');

% load in group ROI struct to threshold reference
groupROI = load(fullfile(roiDir, 'ROIstruct_Group.mat'));


%% gather the thresholds

thresholds = [];
thresholds.active = groupROI.ROI.tThresh;
thresholds.reliable = groupROI.ROI.rThresh;
thresholds

%% gather the brain patterns in active and reliable voxels

brainPatterns = [];

% loop through the subjects:
for s = 1:length(SubjectModels)
    % which sub?
    S = SubjectModels(s); 
    
    clc
    disp(['Formatting data for ' S.name '...']);
    
    % load their ROI struct:
    currROI = load(fullfile(roiDir, ['ROIstruct_' S.name '.mat']));
    currROI = currROI.ROI;
    
    % retrieve brain patterns - entire brain:
    bp = load(S.brainPatterns);
    
    % save brain patterns in reliable and active voxels:
    brainPatterns.active.(S.name).allRuns = bp.Betas.AllRuns(currROI.activeGrayMatter, :);
    brainPatterns.active.(S.name).oddRuns = bp.Betas.Odd(currROI.activeGrayMatter, :);
    brainPatterns.active.(S.name).evenRuns = bp.Betas.Even(currROI.activeGrayMatter, :);
    
    brainPatterns.reliable.(S.name).allRuns = bp.Betas.AllRuns(currROI.reliableGrayMatter, :);
    brainPatterns.reliable.(S.name).oddRuns = bp.Betas.Odd(currROI.reliableGrayMatter, :);
    brainPatterns.reliable.(S.name).evenRuns = bp.Betas.Even(currROI.reliableGrayMatter, :);

end

disp('Done formatting data for all subs!')
brainPatterns.active
brainPatterns.reliable

%% save it

save(fullfile(saveDir, 'formattedData.mat'), 'thresholds', 'brainPatterns');
disp('Saved formatted data!')

