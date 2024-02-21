% Leyla Tarhan
% ltarhan@g.harvard.edu
% 12/2018
% MATLAB R2017b

% Assess how many conditions are necessary to use the reliability-based
% voxel selection method.
    
% output: 
	% - figure plotting stability of the split-half reliability calculation
	% at a range of numbers of conditions

% -------------------------------------------------------------------------
% To use this script:
    % (1) run Step0_makeSubjectModels for the dataset you're interested in.
    % The resulting SubjectModels file should save in the same directory as
    % this script.
    % (2) optional: change the 'dataSetName' variable to toggle between the 2
    % datasets:
        % 'ActionMap': responses to 60 everyday action videos
        % 'ExploringObjects': responses to 72 everyday objects
    % (3) optional: change the number of iterations to use when simulating
    % the stability of the split-half calculation (opts.nIterations)
    % (4) run this script, checking the summary figure produced at the end.

%% clean up

clear all
close all
clc

%% customize variables

% see notes in header for how to alter these variables to run this script

% dataset
dataSetName = 'ActionMap'; % 'ActionMap' or 'ExploringObjects'
% how many times will you sample the data at each # conditions?
opts.nIterations = 100; 

%% set up other variables

if strcmp(dataSetName, 'ActionMap')
    opts.maxConds = 60; % = # of conditions in the data
elseif strcmp(dataSetName, 'ExploringObjects')
    opts.maxConds = 72;
else
    disp('unrecognized dataset.')
    keyboard
end

% check it out:
opts

%% file structure

% directory to save summary figure to:
saveDir = fullfile('..', '3-Results', dataSetName, 'Step5-ConditionRichness');
if ~exist(saveDir, 'dir'); mkdir(saveDir); end

% helpers:
addpath(genpath('HelperFunctions'))
    
%% Load in formatted data

% subject model
load(['SubjectModels_' dataSetName '.mat']);
fprintf('Assessing minimum conditions needed using the %s dataset...\n', dataSetName)
GroupModel

% brain patterns (betas)
load(GroupModel.brainPatterns);
Betas
nConds = length(ConditionNames.AllRuns);
assert(nConds == opts.maxConds, 'mismatch between # of conditions in the data and opts.maxConds.')
nVoxels = size(Betas.Odd, 1);
fprintf('dimension check: analyzing %d voxels in the whole brain.\n', nVoxels)
% concatenate betas from odd and even runs into a cube:
bpCube = NaN(nVoxels, nConds, 2);
bpCube(:, :, 1) = Betas.Odd;
bpCube(:, :, 2) = Betas.Even;

%% Simulate
% - loop through all possible #'s of conditions (1:# of conditions
% in the data)
% - for each # of conditions, randomly sample the data several times
% (iterations specified in opts struct above)
    % - each time calculate split-half reliability for the sampled
    % conditions in all voxels
% - get the standard deviation in split-half r across iterations
% - plot the average s.d. with s.e.m. (across voxels) error bars for
% each # of conditions.

clc
% set up a cube to store the results of all i iterations:
r_sim = zeros(opts.nIterations, nVoxels, opts.maxConds); % iterations x voxels x possible #s of conditions
std_sim = zeros(opts.maxConds, nVoxels); % possible # of conditions x voxels

% loop through the possible #'s of conditions
for n = 1:opts.maxConds
    % loop through the iterations
    for i = 1:opts.nIterations
        % progress printout
        if mod(i, 10) == 0
            fprintf('%d conditions: iteration %d of %d...\n', n, i, opts.nIterations)
        end
        
        % randomly select n conditions:
        currConds = randi(opts.maxConds, 1, n);
        currDat = bpCube(:, currConds, :); % dims: voxels x conds x odd+even
        
        % get split-half reliability in all voxels using those conditions:
        r_sim(i, :, n) = corrRows(currDat(:, :, 1), currDat(:, :, 2));
    end
    
    % get standard deviation for each voxel with this many conditions:
    std_sim(n, :) = nanstd(r_sim(i, :, n));

end

disp('Finished all simulations!')


%% Plot it

% average sd's across voxels:
std_avg = nanmean(std_sim, 2);

% standard error bars:
std_sem = nanstd(std_sim, 0, 2) / sqrt(size(std_sim, 2));

% plot it:
figure('Color', [1 1 1], 'Position', [10 60 800 400])
b = bar(std_avg);
b.FaceColor = [180/255 180/255 180/255];

% error bars
hold on
eb = errorbar(std_avg, std_sem, '.k');
hold off

% appearance:
ylim([0 1.2])
title('Group Data');
ylabel('average split-half r SD')
xlabel('nConds')

% save and close:
saveFigureHelper(1, saveDir, 'SimulateNConditions.png');


