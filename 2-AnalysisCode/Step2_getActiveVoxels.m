% Leyla Tarhan
% ltarhan@g.harvard.edu
% 9/2019
% MATLAB R2017b

% find and save active voxels:
    % (1) load in t-values for each voxel, from the contrast all conditions
    % > rest
    % (2) specify a voxel inclusion t-threshold (default here is 2.0)
    % (3) save supra-threshold, "active" voxels for each subject and the
    % group
    
% output: 
    % - modified 'ROI' struct for each subject and the group, now with the 
    % following additional fields:
        % - final activity-based inclusion threshold
        % - indices of all active voxels

    

% -------------------------------------------------------------------------
% To use this script:
    % (1) run Step0_makeSubjectModels for the dataset you're interested in.
    % The resulting SubjectModels file should save in the same directory as
    % this script.
    % (2) run Step1_getReliableVoxels to define all reliable voxels.
    % (3) optional: specify a voxel inclusion t-threshold (default here is 2.0)
    % (4) optional: change the 'dataSetName' variable to toggle between the 2
    % datasets:
        % 'ActionMap': responses to 60 everyday action videos
        % 'ExploringObjects': responses to 72 everyday objects
    % (5) when prompted, check that the modified 'ROI' structs (now with the
    % locations of active voxels in each subject and the group) contain
    % the expected information. The number of active voxels (the size of 
    % ROI.reliableGrayMatter) will vary by subject, but you should be
    % suspicious if you get extremely low numbers.

%% clean up

clear all
close all
clc

%% customize variables

% see notes in header for how to alter these variables to run this script

% dataset
dataSetName = 'ActionMap'; % 'ActionMap' or 'ExploringObjects'

% t-threshold for defining "active" voxels
tThresh = 2.0;

%% set up subjects

fprintf('Defining active voxels for %s...\n', dataSetName)

% load in SubjectModels, with paths to all the datafiles you need
smName = sprintf('SubjectModels_%s.mat', dataSetName);
load(smName);

% check it out:
SubjectModels
GroupModel

%% set up file structure

% helper functions
addpath(genpath('HelperFunctions'));

% directory to save modified ROI structs in:
roiDir = fullfile('..', '1-Data', dataSetName, 'ROI Structs');
if ~exist(roiDir, 'dir'); mkdir(roiDir); end
                
%% define and save active voxels: group

clc
fprintf('Modifying Group ROI struct with tThresh = %0.2f...\n', tThresh)

% load in ROI struct (created in Step1):
rn = 'ROIstruct_Group.mat';
load(fullfile(roiDir, rn));

% add reliable voxels in gray matter:
ROI = addActiveVoxels18(GroupModel, ROI, tThresh);
ROI.tThresh = tThresh;

% save it
disp('re-saving roi struct...')
save(fullfile(roiDir, rn), 'ROI');

% pause
disp(sprintf('\n\npause to check output, any key to continue...'));
ROI
pause()

disp('Saved active voxels for the group!');


%% define and save active voxels: SS

for s = 1:length(SubjectModels)
    % which sub?
    S = SubjectModels(s);
    
    clc
    fprintf('%s: modifying ROI struct with tThresh = %0.2f...\n', S.name, tThresh)
    
    % load in ROI struct (created in Step1):
    rn = sprintf('ROIstruct_%s.mat', S.name);
    load(fullfile(roiDir, rn));
    
    % add reliable voxels in gray matter:
    ROI = addActiveVoxels18(S, ROI, tThresh);
    ROI.tThresh = tThresh;
    
    % save it
    disp('re-saving roi struct...')
    save(fullfile(roiDir, rn), 'ROI');
    
    % pause
    disp(sprintf('\n\npause to check output, any key to continue...'));
    ROI
    pause()
end
disp('Saved active voxels for all subs!');



