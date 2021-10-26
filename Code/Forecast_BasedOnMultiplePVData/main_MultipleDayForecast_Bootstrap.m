% Forecast EV demand and SOC on a daily basis
% Note:
%   - If we have 30 days to be forecasted ('days' as following), we get 30 independent results.
%
%

%% Initialize
clear all; clc; close all;
% Read Data
allPastData = readtable('BringtonBootstrapHour.csv');
% Parameters
days = 30;  % how many days to be repeatedly forecasted
Nsteps = size(allPastData,1); 

%% Perform forecasting for multiple days
for i = 1:days
    disp(['Processing..... ', num2str(i), '/', num2str(days)])
    % Split the data as follows: -----------------------------------------------
    % If days = 30, each Table is as following;
    % short: from [end - 24*30 - 24*7] -> [end - 24*29 - 24*7]
    %            to     [end - 24*30] -> [end -24*29]
    % forecast: from [end - 24*30] -> [end - 24*29]
    %                to [end - 24*29] -> [end - 24*28]
    % ---------------------------------------------------------------------------
    % Specify the lines in the talbe
    forecastStart = Nsteps - 24*(days-(i-1)) + 1;
    forecastEnd = forecastStart + 23;
    shortTermEnd = forecastStart - 1; 
    shortTermStart = shortTermEnd - 24*7 + 1;  
    % Distribute all Data to each table 
    shortTermTable = allPastData(shortTermStart:shortTermEnd, :); % 1 week more 
    forecastTable = allPastData(forecastStart:forecastEnd, 1:7);  % 1 day more
    targetTable = allPastData(forecastStart:forecastEnd, 8:9);    % the same as forecastTable
    % Perform forecasting for one day
    [PICoverRate, MAPE, RMSE, outTables{i,1}] = getEVModel_MultipleDay(shortTermTable, forecastTable, targetTable);   
    % Store the forecast result
    resultSummary.PIcoverRate(i, 1) = PICoverRate.ensemble;
    resultSummary.MAPE(i, 1) = MAPE.ensemble;
    resultSummary.RMSE(i, 1) = RMSE.ensemble;
    % get the date to be forecasted. It properly works in case the
    % forecasting is only for whole 1 day.
    resultSummary.date(i,1) = datetime(forecastTable.Year(1), forecastTable.Month(1), forecastTable.Day(1));
end

%% Write the result in csv files
% Concatenate forecast result
outTable = cat(1, outTables{:});
% Wirte the result to the tables
writetable(outTable, 'resultEVData_Brington.csv');   % forecasted result
writetable(struct2table(resultSummary), 'resultSummary_Brington.csv'); % Daily performance summary

%% Display the bset and worst day performance
% Get the Best Coverage rate day
[bestPIcoverRate, day] = max(resultSummary.PIcoverRate);
getPerformanceGraph(outTables, day,  ['The best PI coverage day / ' datestr(resultSummary.date(day))]);
% Get the Best (minimum) RMSE day
[bestRMSE, day] = min(resultSummary.RMSE);
getPerformanceGraph(outTables, day, ['The best RMSE day / ' datestr(resultSummary.date(day))]);
% Get the Worst Coverage rate day
[worstPIcoverRate, day] = min(resultSummary.PIcoverRate);
getPerformanceGraph(outTables, day,  ['The worst PI coverage day / ' datestr(resultSummary.date(day))]);
% Get the Worst (maximum) RMSE day
[worstRMSE, day] = max(resultSummary.RMSE);
getPerformanceGraph(outTables, day, ['The worst RMSE day / ' datestr(resultSummary.date(day))]);


function getPerformanceGraph(outTables, day, figTitle)
    PI = [outTables{day}.EnergyPImax outTables{day}.EnergyPImin];
    determPred =  outTables{day}.EnsembleEnergy;
    observed = outTables{day}.EnergyDemand;
    alph = 0.05;
    % Get graph
    %   graph_desc(x, yLabel, y_pred, y_true, boundaries, name, ci_percentage)
    %   1. x values [array]
    %   2. y axis lable [char]
    %   3. forecasted value [array]
    %   4. target value [array]
    %   5. Prediction Inverval [array]
    %   6. figure title [char]
    %   7. Interval width ex) 96% -> 0.5
    graph_desc(1:size(PI,1), 'EV demand [kwh]', determPred, observed, PI, figTitle, alph);
end