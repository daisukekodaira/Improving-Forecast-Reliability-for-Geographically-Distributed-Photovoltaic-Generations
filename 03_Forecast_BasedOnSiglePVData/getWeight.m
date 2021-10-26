function weight = getWeight(predictors, forecasted, target)
    % Reconstruct matrix for PSO calculation
    %  - Uniqe coefficient is defined for each hour 
    
    %     % Display for user
    %     disp('Optimizing the weights for ensemble model....');
        
    %% Restructure the predicted data
    % Combine two time frames into one as in hourly manner
    % - The weight is assinged for every hour.
    % - Ex) Time 7 and 7.5 -> weight for 7 
    % - So, the number of weight is 11 (half of the Time in Predictor)
    predictors.Hour = fix(predictors.Time);
    initHour = min(predictors.Hour);
    lastHour = max(predictors.Hour);
    N_methods = size(forecasted,2);
    
    
    % arrange the matrix to be stored weight
    % - set NaN as an initial occupation
    for i =1:24
        data(i).forecast = NaN(1, N_methods);
        data(i).target = NaN(1);
        weight = NaN(24, N_methods);
    end
    
    for i = 1:22
        if isnan(data(predictors.Hour(i)).forecast)
            % data is not stored yet for the hour
            data(predictors.Hour(i)).forecast(1, :) = forecasted(i, :);
            data(predictors.Hour(i)).target(1) = target(i);
        else
            % there is stored
            lastStep = size(data(predictors.Hour(i)).forecast,1);
            data(predictors.Hour(i)).forecast(lastStep+1, :) = forecasted(i, :);
            data(predictors.Hour(i)).target(lastStep+1, 1) = target(i);
        end
    end
    
    % PSO
    for hour = initHour:lastHour
        objFunc = @(weight) objectiveFunc(weight, data(hour).forecast, data(hour).target);
        rng default  % For reproducibility
        lb = zeros(1, N_methods);
        ub = ones(1, N_methods);
        options = optimoptions('particleswarm', ...
                                          'MaxIterations',10^5, ...
                                          'FunctionTolerance', 10^(-8), ...
                                          'MaxStallIterations', 3000, ...
                                          'Display', 'none');
        [weight(hour, :),~,~,~] = particleswarm(objFunc,N_methods,lb,ub, options);
    end
    
    %     % Display for user
    %     disp('Optimizing the weight for ensemble model.... Done!');
end


function err = objectiveFunc(weight, forecast, target)
    % Note: 
    %   - Here, 'forecast' and 'target' stores the classified focasted data such as Hour = 10
    %   - 'weight' also to be defined with hourly basis, so we will define 24 'weight' for every hour data.
    % objective function
    ensembleForecasted = sum(forecast.*weight, 2);  % add two methods
    err1 = sum(abs(target - ensembleForecasted));
    err2 = (1+abs(1-sum(weight)))*10000;
    err = err1+err2;
    %     err = max(abs(target - ensembleForecasted));
end