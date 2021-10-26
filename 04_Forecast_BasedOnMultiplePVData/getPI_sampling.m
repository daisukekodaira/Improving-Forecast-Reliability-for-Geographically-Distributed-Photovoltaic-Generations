% Return Prediction Interval (PI) based on sampling basis method
% "Sampling basis method" is just based on the counting the index of the array in ascending order
% percentage must be 0 to 1. E.g.) 95% PI -> percentage is '0.05'

function [probPred] = getPI_sampling(probPred, percentage)    
    for i = 1:size(probPred,1)
        if isnan(probPred(i).pred) == 0  % when the element is not NaN
            srtPred = sort(probPred(i).pred,1);
            size_PI = size(srtPred,1);
            lowerIdx = round(size_PI*percentage);
            upperIdx = round(size_PI*(1-percentage));       
            if lowerIdx < 1 
                lowerIdx = 1;
            elseif size_PI < lowerIdx
                lowerIdx = size_PI;
            end
            probPred(i).PImin = srtPred(lowerIdx);
            probPred(i).PImax = srtPred(upperIdx);                        
        end
    end
end    