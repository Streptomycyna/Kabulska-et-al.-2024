function [winnersMat, newPrefMat] = summarizeActionHierarchy_ZK(subMatrix,thrToUse)
% Leyla Tarhan
% ltarhan@g.harvard.edu
% 4/2021
% last change: 28.07.2023 ZK

% take pre-computed brain-behavior correlations to 3 model RDMs, and
% compute a 3-way winner map over the cortex. 


%% Setup

% color display limits
minClim = 0;
maxClim = 0.25; % specify the max preference to display for any given model in the pref map

% colors for each model RDM
colors = [];

% colors that match the commonality analysis plots:
cmap = hsv(size(subMatrix,1));
GRAY=[0.5 0.5 0.5];

% colors.VisualSimilarity = [227, 0, 0]; % red
% colors.MovementSimilarity = [0, 0, 222]; % dark blue
% colors.GoalSimilarity = [0, 167, 0]; % green
% GRAY = [180 180 180]; % base color for no preference / brain

% model RDM names:
% models = fieldnames(rsaResults);
% % models(strncmp(models, 'GrayMatterVoxIdx', 16)) = [];

featureNames = {'Component_1','Component_2','Component_3','Component_4',...
    'Component_5','Component_6','Component_7','Component_8'};

models=featureNames;
%% Make a colormap
numberColors = length(models);
%%% How many colors do I have?
%switch numberColors
nIncrements = 64;
bigCMap = zeros(nIncrements*numberColors, 3);
counter = 1;
for m = 1:numberColors
    startIdx = counter;
    endIdx = counter + nIncrements-1;
    %bigCMap(startIdx:endIdx, :) = twoColorInterpolate(GRAY, colors.(models{m}), nIncrements);
    bigCMap(startIdx:endIdx, :) = twoColorInterpolate(GRAY, cmap(m,:), nIncrements);
    counter = counter + nIncrements;
end
%end
bigCMap = [GRAY; bigCMap];

% % make a colormap for each model and stack them:
% nIncrements = 64;
% bigCMap = zeros(nIncrements*length(models), 3);
% counter = 1;
% for m = 1:length(models)
%     startIdx = counter;
%     endIdx = counter + nIncrements-1;
%     %bigCMap(startIdx:endIdx, :) = twoColorInterpolate(GRAY, colors.(models{m}), nIncrements);
%     bigCMap(startIdx:endIdx, :) = twoColorInterpolate(GRAY, cmap(m,:), nIncrements);
%     counter = counter + nIncrements;   
% end

%% Compute a 3-way winner map

nVox = length(subMatrix);
winnersMat = zeros(nVox, 1); % keep track of the model RDM with the strongest correlation
strengthMat = zeros(nVox, 1); % keep track of the difference between the strongest and next-strongest correlation

% % flatten the rmaps from cubes to matrices
% flatMaps = nan(nVox, length(models));
% for m = 1:length(models)
%    flatCube = flattenCube(rsaResults.(models{m}).rmap); 
%    flatMaps(:, m) = flatCube(rsaResults.GrayMatterVoxIdx);
% end
flatMaps = subMatrix';
% preference-mapping
for v = 1:nVox
   % check that this vox has data for all models:
   if all(~isnan(flatMaps(v, :))) % good to go
      % get the max r-value
      %[max_r, max_idx] = max(flatMaps(v, :));
      max_r = max(flatMaps(v,:));
      lia = ismember(flatMaps(v,:),max_r);
      max_idx = find(lia);
      if length(max_idx) > 1 % there's a tie
          strengthMat(v) = 0; % no strength
          winnersMat(v) = 0; % no winner
      else
          if max_r < thrToUse
              winnersMat(v) = 0;
              strengthMat(v) = 0;
          else
              winnersMat(v) = max_idx;
              
              % get the next-highest r-value:
              comparisonIdx = logical(ones(1, length(models)));
              comparisonIdx(max_idx) = 0;
              runnerUp = max(flatMaps(v, comparisonIdx));
              
              % calculate the strength:
              strengthMat(v) = max_r - runnerUp;
          end
      end
   else % some missing data
       fprinft('Voxel %d had missing data.\n', rsaResults.GrayMatterVoxIdx(v))
       keyboard
   end
    
end

%% Connect the winner map to the colormap
% transform pref map data to new values that map to this colormap

newPrefMat = zeros(nVox, 1);
for v = 1:nVox
    winner = winnersMat(v);
    if winner > 0 % there's a winner in this voxel
        
        % convert strength & winner to a new value that maps to the
        % colormap (which combines all models together)
        strength = strengthMat(v);
        if strength <= maxClim
            % how far along the color scale (for this model)?
            relPosition = strength / (maxClim - minClim);
        else
            % strengh is > the max displayed strength
            relPosition = 1;
        end
        
        % how far along the big color scale?
        absPosition = relPosition + winner; % move up or down along the big scale according to which model won
        
        % record this position as the new winner map value
        newPrefMat(v) = absPosition;
    end
    
end


%% quick visualization
newPrefCube=reshape(newPrefMat,[91 109 91]);

% newPrefCube = nan([91 109 91]);
% newPrefCube(rsaResults.GrayMatterVoxIdx) = newPrefMat;
% quickViewCubePrefMap(newPrefCube, bigCMap, [1, 4], models);


end