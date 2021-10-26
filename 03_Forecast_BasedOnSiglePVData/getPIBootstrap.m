% Generate PI
% Note:
%       - The error distributions are defined for each quater. There are 24*4 = 96 error distributions. 
%       - 

function [lwBoundMean, upBoundMean] = getPIBootstrap(predictors, determPred, err_distribution)
    nBoot = 5000;
    for timeStep = 1:size(predictors,1)
        hour = predictors.Hour(timeStep)+1;   % hour 1~24 (original data is from 0 to 23, so add '1' for the matrix)
        % Bootstrapping        
        bootPool = err_distribution(hour).err;  % Extract resamples from this pool
        bootBound = nan(1,nBoot); 
        for i = 1:nBoot
            [m(i), lwBound(i), upBound(i)] = getPI_confInter(determPred(timeStep) ...
                                                                                  + bootPool(randi(numel(bootPool), size(bootPool)))); 
        end
        upBoundMean(timeStep,1) = mean(upBound); 
        lwBoundMean(timeStep,1) = mean(lwBound); 
    end
end