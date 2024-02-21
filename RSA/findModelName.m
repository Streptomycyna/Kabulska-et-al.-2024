function modelName = findModelName(RDMused)
% Get model names for the RSA with many models
% ZK 28.07.2028

resDir = '../Data/';
load(fullfile(resDir, 'modelsForRSA/ModelNames')); % as 'model'

nModels = length(RDMused);

for iModel = 1:nModels
    thisModel = char(RDMused(iModel));
    for kk = 1:length(model)
        %if all(ismember(model(kk).OriginalName,thisModel))
        if strcmp(model(kk).OriginalName,thisModel)
            modelName{iModel} = model(kk).name;
        else
            % do nothing
        end
    end
end


end

