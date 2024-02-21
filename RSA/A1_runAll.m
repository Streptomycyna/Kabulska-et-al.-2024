% Specify models and parameters for the RSA
% 1. run the RSA (A2_runRSA.m)
% 2. After running RSA, smooth the data (runManySMOOTHING.sh)
% 3. Monte Carlo correction (RSA_MonteCarloCorr.m)

% For the users: change the paths

% Models to choose:
% Behavioral action space: inverseMDSModel 
% Feature model: multidimFeatureModel
% PCA models: PCAFeat_Comp1, PCAFeat_Comp2, PCAFeat_Comp3,...
%   PCAFeat_Comp4, PCAFeat_Comp5, PCAFeat_Comp6,...
%   PCAFeat_Comp7, PCAFeat_Comp8
% Control models: gist, Resnet50_conv2_1.1

% Choose if you're running RSA or Mont Carlo correction (after smoothing
% the data)
whichRSA = 'firstPart_RSA'; % 'firstPart_RSA' or 'secondPart_MonteCarlo'
% Choose the main models
models = {'inverseMDSModel','multidimFeatureModel'};

args.mask = 'reliabilityMap'; % 'standardBrain' or 'reliabilityMap'
args.neuralData_distMeas = 'squaredEuclidean';
args.voxThresh = 0.25; % reliability map threshold
args.typeRSA = 'GLMtype'; % 'standardRSA' or 'GLMtype'


switch whichRSA
    case 'firstPart_RSA'
        
        for iModel = 1:length(models)
            model_first = models{iModel};
            models = {model_first, 'gist','Resnet50_layer1_0conv1'};
            args.DSMTypes = models;
            A2_runRSA(args)
            A3_separateMaps(args)

        end
        
        %% Here do the smoothing (bash scripts)!

    case 'SecondPart_MonteCarlo'
        
        for iModel = 1:length(models)
            model_first = models{iModel};
            models = {model_first, 'gist','Resnet50_layer1_0conv1'};
            args.DSMTypes = models;
            A4_RSA_MonteCarloCorr(args);
        end

end


