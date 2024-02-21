% Leyla Tarhan
% ltarhan@g.harvard.edu
% 9/2019
% MATLAB R2017b

% Directly compare 2 voxel selection methods: reliability-based and 
% activity-based.
    
% output: 
	% - figure plotting # of voxels selected by each method, plus results
	% of a paired-samples t-test testing whether these values differ.


% -------------------------------------------------------------------------
% To use this script:
    % (1) run Step0_makeSubjectModels for the dataset you're interested in.
    % The resulting SubjectModels file should save in the same directory as
    % this script.
    % (2) run Step1_getReliableVoxels to define all reliable voxels.
    % (3) run Step2_getActiveVoxels to define all active voxels.
    % (4) run Step3_formatData to consolidate the resulting data.
    % (5) optional: change the 'dataSetName' variable to toggle between the 2
    % datasets:
        % 'ActionMap': responses to 60 everyday action videos
        % 'ExploringObjects': responses to 72 everyday objects
    % (6) run this script, checking the summary figures as they're made.
    

%% clean up

clear all
close all
clc

%% customize variables

% see notes in header for how to alter these variables to run this script

% dataset
dataSetName = 'ActionMap'; % 'ActionMap' or 'ExploringObjects'

%% set up other variables

% store methods names for plotting, in same order as the plotting vectors:
methods = {'active', 'reliable'};
% store colors for each method, in same order as the plotting vectors:
colors = {'blue', 'red'};
colorsRGB = [0 0 255; 255 0 0];

%% file structure

% helpers
addpath(genpath('HelperFunctions'))

% directory to save results figures to:
saveDir = fullfile('..', '3-Results', dataSetName, 'Step4-CompareMethods');
if ~exist(saveDir, 'dir'); mkdir(saveDir); end

% directory with formatted data:
dataDir = fullfile('..', '3-Results', dataSetName, 'Step3-FormatData');

%% load the formatted data

fprintf('Comparing voxel selection methods for %s dataset!\n', dataSetName)

data = load(fullfile(dataDir, 'formattedData.mat'));
data

load(['SubjectModels_' dataSetName '.mat'])
SubjectModels
GroupModel

%% How many voxels selected by each method?

avgNVox = compareVoxelCounts(SubjectModels, data, methods, colors);

% save it:
saveFigureHelper(1, saveDir, 'VoxelCounts_boxPlot.png');

