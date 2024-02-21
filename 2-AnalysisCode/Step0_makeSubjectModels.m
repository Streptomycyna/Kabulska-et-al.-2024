% Leyla Tarhan
% ltarhan@g.harvard.edu
% 9/2019
% MATLAB R2017b

% set up a Subject Model with pointers to the following data files for each subject:
    % - brain patterns for odd runs 
    % - brain patterns for even runs
    % - brain patterns for all runs combined
    % - tMap (from all > rest contrast, using brain patterns for all runs
    % combined)
    % - gray matter mask
    
% in addition, set up a Group Model with pointers to the following files:
    % - brain patterns for odd runs (from group random-effects glm)
    % - brain patterns for even runs (from group random-effects glm)
    % - brain patterns for all runs combined (from group random-effects glm)
    % - tMap (from all > rest contrast, using brain patterns for all runs
    % combined)
    % - gray matter mask (from example subject)
    
% notes on dimensions:
    % - brain patterns: betas in response to each condition, in the whole 
    % brain (voxels x conditions)
    % - tMap: voxels x 1
    % - gray matter mask: voxels x 1 
    
% -------------------------------------------------------------------------    
% to use this script:
    % (1) download the '1-Data' directory, containing data file for each
    % dataset
    % (2) change the 'topDir' directory to the new location of '1-Data' on
    % your computer
    % (3) optional: change the 'dataSetName' variable to toggle between the 2
    % datasets:
        % 'ActionMap': responses to 60 everyday action videos
        % 'ExploringObjects': responses to 72 everyday objects
    % (4) make sure all the files exist (messages will print out to tell
    % you this)
    
%% Clean up

clear all
close all
clc

%% customize variables

% see notes in header for how to alter these variables to run this script

% path to data files
topDir = 'C:\Users\Leyla\Dropbox (KonkLab)\Research-Tarhan\Project - ReliabilityBasedVoxelSelection\Manuscript\9-OSF - XXXX\1-Data';

% dataset
dataSetName = 'ActionMap'; % 'ActionMap' or 'ExploringObjects'

%% set up subjects

% subjects to include (corresponds to file names in topDir):
if strcmp(dataSetName, 'ActionMap')
    subList = [2:14];
    exSub = 'Sub6';
elseif strcmp(dataSetName, 'ExploringObjects')
    subList = [1:7, 10:13];
    exSub = 'Sub1';
else
    disp('unrecognized dataSetName');
    keyboard
end

fprintf('Setting up Subject Models for %s, Sub %d - %d...\n', dataSetName, subList(1), subList(end))

%% set up file structure

% anat files - gray matter masks:
anatDir = fullfile(topDir, dataSetName, 'Anatomy');

% functional data files - brain patterns:
bpDir = fullfile(topDir, dataSetName, 'BrainPatterns');

% t-maps:
tmDir = fullfile(topDir, dataSetName, 'tMaps');

% naming conventions:
cmString = 'GMMask'; % e.g.: 'GMMask_Sub1.mat'
bpString = 'brainPatterns'; % e.g.: 'brainPatterns_Sub1.mat'
tmString = 'tMap'; % e.g.: 'tMap_Sub1.mat';
groupName = sprintf('Group (N=%d)', length(subList));

%% Set up the SS subject models:

% loop through each sub
for s=1:length(subList)
    
    % get sub name
    sub = ['Sub' num2str(subList(s))];
    Sub(s).name         = sub;
    
    % cortex mask
    Sub(s).cortexMask   = fullfile(anatDir, [cmString '_' sub '.mat']);
        
    % functional data (brain patterns or betas for odd runs, even runs, and all runs combined):
    Sub(s).brainPatterns= fullfile(bpDir, [bpString '_' sub '.mat']);

    % t-map ('activity' from all > rest contrast):
    Sub(s).tMap         = fullfile(tmDir, [tmString '_' sub '.mat']);
    
end

% check out the model:
Sub(1)

%% check to see if all the files exist:
clc

% check fields:
headers = fieldnames(Sub);
checkFields = headers(2:end);

for s=1:length(Sub)
    counter=[];
    for h=1:length(checkFields)
        counter(h) = exist(Sub(s).(checkFields{h}), 'file');
        if ~counter(h)
            disp(['DOES NOT EXIST:' Sub(s).name ' ' checkFields{h} ' ' Sub(s).(checkFields{h})])
        end
    end
    if all(counter)
        disp([Sub(s).name ': all files exist']);
    end
end

%% set up the group model:

GroupModel.name = groupName;

% cortex mask
GroupModel.exampleSub = exSub; % example sub for gray matter mask
GroupModel.cortexMask   = fullfile(anatDir, [cmString '_' groupName '.mat']);

% functional data (brain patterns or betas for odd runs, even runs, and all runs combined):
GroupModel.brainPatterns= fullfile(bpDir, [bpString '_' groupName '.mat']);

% t-map ('activity' from all > rest contrast):
GroupModel.tMap         = fullfile(tmDir, [tmString '_' groupName '.mat']);

% check it out:
GroupModel

%% check to see if all the files exist:
clc

headers = fieldnames(GroupModel);
checkFields = headers(3:end);
for s=1:length(GroupModel)
    counter=[];
    for h=1:length(checkFields)
        counter(h) = exist(GroupModel(s).(checkFields{h}), 'file');
        if ~counter(h)
            disp(['DOES NOT EXIST:' GroupModel(s).name ' ' checkFields{h} ' ' GroupModel(s).(checkFields{h})])
        end
    end
    if all(counter)
        disp([GroupModel(s).name ': all files exist']);
    end
end


%% save SS and group subject models

SubjectModels = Sub;

save(['SubjectModels_' dataSetName '.mat'], 'SubjectModels', 'GroupModel')
disp('... saved SubjectModels.mat');
