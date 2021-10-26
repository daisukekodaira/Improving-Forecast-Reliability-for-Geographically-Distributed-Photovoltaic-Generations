% Forecast PV generation on a daily basis
% Note:
%   - If we have 30 days to be forecasted ('days' as following), we get 30 independent results.
%
%

%% Initialize
clear all; clc; close all;
% Read Data
allPastData = readtable('LongTermEVData.csv');
% Parameters
days = 3;  % how many days to be repeatedly forecasted
Nsteps = size(allPastData,1); 

%% Perform forecasting for multiple days
for i = 1:days
    disp(['Processing..... ', num2str(i), '/', num2str(days)])
    % Split the data as follows: -----------------------------------------------
    % If days = 30, each Table is as following;
    % short: from [end - 96*30 - 96*7] -> [end - 96*29 - 96*7]
    %            to     [end - 96*30] -> [end -96*29]
    % forecast: from [end - 96*30] -> [end - 96*29]
    %                to [end - 96*29] -> [end - 96*28]
    % ---------------------------------------------------------------------------
    % Specify the lines in the talbe
    forecastStart = Nsteps - 96*(days-(i-1)) + 1;
    forecastEnd = forecastStart + 95;
    shortTermEnd = forecastStart - 1; 
    shortTermStart = shortTermEnd - 96*7 + 1;  
    % Distribute all Data to each table 
    shortTermTable = allPastData(shortTermStart:shortTermEnd, :); % 1 week more 
    forecastTable = allPastData(forecastStart:forecastEnd, 1:8);  % 1 day more
    targetTable = allPastData(forecastStart:forecastEnd, 9:10);    % the same as forecastTable
    % Perform forecasting for one day
    [PICoverRate, MAPE, RMSE, PIWidth, outTables{i,1}] = getPVModel_MultipleDay(shortTermTable, forecastTable, targetTable);   
    % Store the forecast result
    resultSummary.PIcoverRate(i, :) = PICoverRate.ensemble;
    resultSummary.PIcoverRateBoot(i, :) = PICoverRate.ensembleBoot;
    resultSummary.MAPE(i, :) = MAPE.ensemble;
    resultSummary.RMSE(i, :) = RMSE.ensemble;
    resultSummary.PIWidth(i, :) = PIWidth.ensemble;
    resultSummary.PIWidthBoot(i, :) = PIWidth.ensembleBoot;
    % get the date to be forecasted. It properly works in case the
    % forecasting is only for whole 1 day.
    resultSummary.date(i,1) = datetime(forecastTable.Year(1), forecastTable.Month(1), forecastTable.Day(1));
end

%% Write the result in csv files
% Concatenate forecast result
outTable = cat(1, outTables{:});
% Wirte the result to the tables
writetable(outTable, 'resultEVData.csv');   % forecasted result
writetable(struct2table(resultSummary), 'resultSummary.csv'); % Daily performance summary

%% Display the bset and worst day performance
% Get the Best Coverage rate day
[bestPIcoverRate, day] = max(resultSummary.PIcoverRate);
[bestBootPIcoverRate, dayBoot] = max(resultSummary.PIcoverRateBoot);
getPerformanceGraph(outTables, day,  ['The best PI coverage day / ' datestr(resultSummary.date(day))]);
getPerformanceGraph(outTables, dayBoot,  ['The best BootPI coverage day / ' datestr(resultSummary.date(dayBoot))]);
% Get the Best (minimum) RMSE day
[bestRMSE, day] = min(resultSummary.RMSE);
getPerformanceGraph(outTables, day, ['The best RMSE day / ' datestr(resultSummary.date(day))]);
% Get the Worst Coverage rate day
[worstPIcoverRate, day] = min(resultSummary.PIcoverRate);
[worstBpptPIcoverRate, dayBoot] = min(resultSummary.PIcoverRateBoot);
getPerformanceGraph(outTables, day,  ['The worst PI coverage day / ' datestr(resultSummary.date(day))]);
getPerformanceGraph(outTables, dayBoot,  ['The worst BootPI coverage day / ' datestr(resultSummary.date(dayBoot))]);
% Get the Worst (maximum) RMSE day
[worstRMSE, day] = max(resultSummary.RMSE);
getPerformanceGraph(outTables, day, ['The worst RMSE day / ' datestr(resultSummary.date(day))]);


function getPerformanceGraph(outTables, day, figTitle)
    PI = [outTables{day}.EnergyPImax outTables{day}.EnergyPImin];
    PIBoot = [outTables{day}.EnergyPIBootmax outTables{day}.EnergyPIBootmin];
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
    graph_desc(1:size(PI,1), 'EV demand [kwh]', determPred, observed, PI, PIBoot, figTitle, alph);
end