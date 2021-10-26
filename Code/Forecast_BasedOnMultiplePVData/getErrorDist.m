% Create matrix; structure 24*4 (hour*quater)
% - Each cell (each 15min inteval) has its own error records, which form error distribution.
% - Input: Array [error, hour, quater]
% - Return: Structure 24*4

function [errTable, ensembledPred] = getErrorDist(predictors, forecasted, target, weight)
    % Generate forecasting result based on ensembled model
    steps = size(predictors, 1);
    for i = 1:steps
        predictors.Hour(i) = fix(predictors.Time(i));       % Transpose 'hours' from 0 to 23 -> from 1 to 24
        ensembledPred(i,:) = sum(weight(predictors.Hour(i), :).*forecasted(i,:));
    end
    % Calculate error from validation data: error[%]
    err = ensembledPred - target;
    errTable = restructErrorData(predictors, err);
end

function errTable = restructErrorData(predictors, err)
    % Initialize the structure for error distribution
    % structure of err_distribution.data is as below:
    %   row=24hours(1~24 in "LongTermPastData"), columns=4quarters.
    %   For instance, "err_distribution(1).data" means 0am which contains array like [e1,e2,e3....] 
    for hour = 1:24
        errTable(hour).err(1) = NaN;            
    end
    % build the error distibution
    steps = size(predictors.Hour, 1);
    % The hour and quater in 'err' are composed of from 0 to 23.
    % On the other hand, err matrix column and row are compose of from 1 to 24. 
    % 'err' always require +1 to match the hour/quater with the column and row in 'err'    
    for i = 1:steps
        currentHour = predictors.Hour(i);
        if isnan(errTable(currentHour).err(1)) 
            % if the err_distribution is NaN -> yes -> put the error as a new element
            errTable(currentHour).err(1, :) = err(i);
        else
            % if the err_distribution is NaN -> no -> append the new error to the last element. 
            lastStep = size(errTable(currentHour).err,1);
            errTable(currentHour).err(lastStep+1, :) = err(i);
        end
    end
end