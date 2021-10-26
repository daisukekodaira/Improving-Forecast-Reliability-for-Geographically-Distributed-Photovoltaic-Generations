% Generate PI
% Note:
%       - The error distributions are defined for each quater. There are 24*4 = 96 error distributions. 
%       - 

function [PImean, lwBound, upBound] = getPI(predictors, determPred, err_distribution)
    for i = 1:size(predictors,1)
        hour = predictors.Hour(i);   % hour 1~24 (original data is from 0 to 23, so add '1' for the matrix)
        prob_prediction(hour).pred = determPred(i) + err_distribution(hour).err;
        % All elements must be bigger than zero.
        % Note: In this case, all EVs just is for only charge.
        %           (We can change this concept for another project)
        prob_prediction(hour).pred = max(prob_prediction(hour).pred, 0);    
        % Get mean value of Probabilistic load prediction
        prob_prediction(hour).mean = mean(prob_prediction(hour).pred)';
        % Get Confidence Interval
        %  - getPI_confInter: 2sigma(95%) boundaries return
        %  - getPI_sampling: please specify the percentage by yourself 
        [PImean(i,1), lwBound(i,1), upBound(i,1)] = getPI_confInter(prob_prediction(hour).pred);
        % [PImean(i,1), PImin(i,1), PImax(i,1)] = getPI_sampling(prob_prediction(hour, quater).pred, );
    end
end