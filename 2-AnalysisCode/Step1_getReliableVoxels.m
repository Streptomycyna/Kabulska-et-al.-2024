% Leyla Tarhan
% ltarhan@g.harvard.edu
% 9/2019
% MATLAB R2017b

% find and save reliable voxels:
    % (1) calculate split-half reliability in the whole brain
    % (2) assess reliability curve to determine an inclusion threshold
    % (3) save supra-threshold, "reliable" voxels for each subject and the
    % group
    
% output: 
    % - 'ROI' struct for each subject and the group with the following
    % fields:
        % - final reliability-based inclusion threshold
        % - indices of all reliable voxels
    % - summary figures visualizing the patterns of reliability within the
    % data
    

% -------------------------------------------------------------------------
% To use this script:
    % (1) run Step0_makeSubjectModels for the dataset you're interested in.
    % The resulting SubjectModels file should save in the same directory as
    % this script.
    % (2) optional: change the 'dataSetName' variable to toggle between the 2
    % datasets:
        % 'ActionMap': responses to 60 everyday action videos
        % 'ExploringObjects': responses to 72 everyday objects
    % (3) run the script, checking out the summary figures produced along
    % the way.
    % (4) when prompted, enter an appropriate reliability-based voxel
    % inclusion threshold, based on where the "item pattern reliability"
    % curves begin to plateau.
    % (5) when prompted, check that the 'ROI' structs (which save the
    % locations of reliable voxels in each subject and the group) contain
    % the expected information. The number of reliable voxels (the size of 
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

%% set up subjects

fprintf('Defining reliable voxels for %s...\n', dataSetName)

% load in SubjectModels, with paths to all the datafiles you need
smName = sprintf('SubjectModels_%s.mat', dataSetName);
load(smName);

% check it out:
SubjectModels
GroupModel

%% set up file structure

% helper functions
addpath(genpath('HelperFunctions'));

% directory to save summary figures in:
saveDir = fullfile('..', '3-Results', dataSetName, 'Step1-Reliability');
if ~exist(saveDir, 'dir'); mkdir(saveDir); end

% directory to save ROI structs in:
roiDir = fullfile('..', '1-Data', dataSetName, 'ROI Structs');
if ~exist(roiDir, 'dir'); mkdir(roiDir); end

%% compute reliabilty in the group data

clc
fprintf('calculating split-half reliability in group data...\n')

R = computeReliabilityGroup18(GroupModel, saveDir);
R
% visualize overview:
plotGroupItemReliability(R, saveDir)

% decide on a reliability threshold:
clc
rThresh = input('Based on these plots, what should rThresh be? ');

% plot the reliability of each item separately when only considering the
% voxels whose overall reliability survives rThresh:
plotItemByItemAtThresh(R, rThresh, saveDir);

% Look at it as a histogram:
plotItemPatternHistAtThresh(R, rThresh, saveDir);


%% compute reliability in the SS data

clc
fprintf('calculating split-half reliability in single-subject data...\n')

R_SS = computeReliabilityMultiSubs18(SubjectModels, saveDir);

% plot the average item-pattern reliability separately for each subject:
plotItemReliabilities(R_SS, rThresh, saveDir); % check out how the rThresh 
% specified above aligns with the SS data


%% save reliable voxels: group

clc
fprintf('Making Group ROI struct with rThresh = %0.2f...\n', rThresh)

% initialize the group ROI struct:
ROI = [];

% add reliable voxels in gray matter:
ROI = addReliableVoxels18(GroupModel, ROI, rThresh, saveDir, 1);
ROI.rThresh = rThresh;

% save it
disp('saving roi struct...')
fn = 'ROIstruct_Group.mat';
save(fullfile(roiDir, fn), 'ROI');

% pause
disp(sprintf('\n\npause to check output, any key to continue...'));
ROI
pause()

disp('Saved reliable voxels for the group!');

%% save reliable voxels: SS

for s = 1:length(SubjectModels)
   % which sub?
   S = SubjectModels(s);
   
   clc
   fprintf('%s Making ROI struct with rThresh = %0.2f...\n', S.name, rThresh)
    
   % initialize the group ROI struct:
   ROI = [];
   
   % add reliable voxels in gray matter:
   ROI = addReliableVoxels18(S, ROI, rThresh, saveDir, 0);
   ROI.rThresh = rThresh;

   % save it
   disp('saving roi struct...')
   fn = sprintf('ROIstruct_%s.mat', S.name);
   save(fullfile(roiDir, fn), 'ROI');
   
   % pause
   disp(sprintf('\n\npause to check output, any key to continue...'));
   ROI
   pause()
end

disp('Saved reliable voxels for all subs!')





