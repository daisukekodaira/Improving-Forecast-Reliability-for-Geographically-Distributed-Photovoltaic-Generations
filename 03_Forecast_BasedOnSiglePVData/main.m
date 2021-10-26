clear all; clc; close all;

% Forecast PV demand on a daily basis
% Note:
%   - If we have 30 days to be forecasted ('days' as following), we get 30 independent results.
%
%

%% Initialize
clear all; clc; close all;
% Read Data
allPastData = readtable('PVID_6pastDataWithNaNinOF.csv');
% Parameters
days = 30;  % how many days to be repeatedly forecasted
framesInDay = 22;    % how many records are in a day
validDays = 7; % how many days to be utilized to construct PI
modelUpdateDays = 30; % how many days to update the ML models
Nsteps = size(allPastData,1);  % Total records in given data set
pvID = allPastData.PV_ID(1);

%% Perform forecasting for multiple days
for i = 1:days
    disp(['Processing..... ', num2str(i), '/', num2str(days)])
    % Split the data as follows: -----------------------------------------------
    % If days = 30, each Table is as following;
    % short: from [end - 22*30 - 22*7] -> [end - 22*29 - 22*7]
    %            to     [end - 22*30] -> [end -22*29]
    % forecast: from [end - 22*30] -> [end - 22*(30-1)]
    %                to [end - 22*(30-1)] -> [end - 22*28]
    % ---------------------------------------------------------------------------
    % Get forecast data; specify the lines in the talbe
    forecastStart = Nsteps - framesInDay*(days-(i-1)) + 1;
    forecastEnd = forecastStart + framesInDay -1;
    shortTermEnd = forecastStart - 1; 
    shortTermStart = shortTermEnd - framesInDay*validDays + 1;  
    % Distribute all Data to each table 
    % shortTermtable: minimum is 1 week. 
    % forecastTable: The predictors to be utilized for forecasting as test. Minimum is 1 day.
    % targetTable: Actual/observed generation to be forecasted.
    colPredictors = {'Year', 'Month', ...
                            'Day', 'Time', 'Tempreature', 'Precipitation', 'Weather'};
    colTargets = {'Observed', 'ForecastOpticalFlow'};
    shortTermTable = allPastData(shortTermStart:shortTermEnd, :); 
    predictorTable = allPastData(forecastStart:forecastEnd, colPredictors); 
    targetTable = allPastData(forecastStart:forecastEnd, colTargets);
    trainTable = allPastData(1:shortTermEnd, :);
    % The model is updated every modelUpDays such as 30 days
    if  mod(i,modelUpdateDays) == 1
        disp('Updating the ML model..... ')      
        trainModel(trainTable, framesInDay, validDays, colPredictors);
        disp('Done! ')      
    end

    % Perform forecasting for one day
    [PICoverRate, MAPE, RMSE, PIWidth, outTables{i,1}] = forecastPVgen(pvID, predictorTable, targetTable);   

    % Get the date to be forecasted. It properly works in case the
    % forecasting is only for whole 1 day.
    resultSummary.date(i,1) = datetime(predictorTable.Year(1), predictorTable.Month(1), predictorTable.Day(1));
    % Store the forecast result
    resultSummary.PIcoverRateML(i, 1) = PICoverRate.ensembleML;
    resultSummary.PIcoverRateOF(i, 1) = PICoverRate.OF;
    resultSummary.PIcoverRateAll(i, 1) = PICoverRate.ensembleAll;
    resultSummary.PIcoverRateMLBoot(i, 1) = PICoverRate.ensembleMLBoot;
    resultSummary.PIcoverRateOFBoot(i, 1) = PICoverRate.OFBoot;
    resultSummary.PIcoverRateAllBoot(i, 1) = PICoverRate.ensembleAllBoot;
    resultSummary.MapeML(i, 1) = MAPE.ensembleML;
    resultSummary.MapeOF(i, 1) = MAPE.OF;
    resultSummary.MapeAll(i, 1) = MAPE.ensembleAll;
    resultSummary.RmseML(i, 1) = RMSE.ensembleML;
    resultSummary.RmseOF(i, 1) = RMSE.OF;
    resultSummary.RmseAll(i, 1) = RMSE.ensembleAll;
    resultSummary.PIWidthML(i, 1) = PIWidth.ensembleML;
    resultSummary.PIWidthOF(i, 1) = PIWidth.OF;
    resultSummary.PIWidthAll(i, 1) = PIWidth.ensembleAll;
    resultSummary.PIWidthMLBoot(i, 1) = PIWidth.ensembleMLBoot;
    resultSummary.PIWidthOFBoot(i, 1) = PIWidth.OFBoot;
    resultSummary.PIWidthAllBoot(i, 1) = PIWidth.ensembleAllBoot;
end

%% Write the result in csv files
% Concatenate forecast result
outTable = cat(1, outTables{:});
% Wirte the result to the tables
writetable(outTable, ['PVID_' num2str(allPastData.PV_ID_original(1)) 'Single_' 'resultPVData.csv']);   % forecasted result
writetable(struct2table(resultSummary), ['PVID_' num2str(allPastData.PV_ID_original(1)) 'Single_' 'resultSummary.csv']); % Daily performance summary

%% Display the bset and worst day performance
% Get the Best Coverage rate day
% ML
[bestPIcoverRate, day] = max(resultSummary.PIcoverRateML);
PI = [outTables{day}.MLUpBound outTables{day}.MLLwBound];
PIBoot = [outTables{day}.MLLwBoundBoot outTables{day}.MLUpBoundBoot];
graph_desc(1:size(PI,1), outTables{day}.EnsembleML, outTables{day}.Observed, PI, PIBoot, ...
                    ['The best PI coverage day by only ensembled ML / ' datestr(resultSummary.date(day))]);
saveas(gcf,'bestPICoverRate_ML', 'fig');
% Optical flow
[bestPIcoverRate, day] = max(resultSummary.PIcoverRateOF);
PI = [outTables{day}.OFUpBound outTables{day}.OFLwBound];
PIBoot = [outTables{day}.OFLwBoundBoot outTables{day}.OFUpBoundBoot];
graph_desc(1:size(PI,1), outTables{day}.OF, outTables{day}.Observed, PI, PIBoot, ...
                    ['The best PI coverage day by only OpticalFlow / ' datestr(resultSummary.date(day))]);
saveas(gcf,'bestPICOverRate_OF', 'fig');
% ML+Optical flow
[bestPIcoverRate, day] = max(resultSummary.PIcoverRateAll);
PI = [outTables{day}.AllUpBound outTables{day}.AllLwBound];
PIBoot = [outTables{day}.AllLwBoundBoot outTables{day}.AllUpBoundBoot];
graph_desc(1:size(PI,1), outTables{day}.EnsembleAll, outTables{day}.Observed, PI, PIBoot, ...
                    ['The best PI coverage day by ML+OpticalFlow / ' datestr(resultSummary.date(day))]);
saveas(gcf,'bestPICoverRate_All', 'fig');

% Bootstrapped                 
% [bestBootPIcoverRate, dayBoot] = max(resultSummary.PIcoverRateAllBoot);
% PI = [outTables{day}.AllUpBound outTables{day}.AllLwBound];
% PIBoot = [outTables{day}.AllLwBoundBoot outTables{day}.AllUpBoundBoot];
% graph_desc(1:size(PI,1), outTables{day}.EnsembleAll, outTables{day}.Observed, PI, PIBoot, ...
%                     ['The best bootPI coverage day by ML+OpticalFlow / ' datestr(resultSummary.date(day))]);
                
% % Get the Best (minimum) RMSE day
[bestRMSE, day] = min(resultSummary.RmseAll);
PI = [outTables{day}.AllUpBound outTables{day}.AllLwBound];
PIBoot = [outTables{day}.AllLwBoundBoot outTables{day}.AllUpBoundBoot];
graph_desc(1:size(PI,1), outTables{day}.EnsembleAll, outTables{day}.Observed, PI, PIBoot, ...
                    ['The best RMSE day by ML+OpticalFlow / ' datestr(resultSummary.date(day))]);
saveas(gcf,'bestRMSE_All', 'fig');
% % Get the Worst Coverage rate day
[worstPIcoverRate, day] = min(resultSummary.PIcoverRateAll);
PI = [outTables{day}.AllUpBound outTables{day}.AllLwBound];
PIBoot = [outTables{day}.AllLwBoundBoot outTables{day}.AllUpBoundBoot];
graph_desc(1:size(PI,1), outTables{day}.EnsembleAll, outTables{day}.Observed, PI, PIBoot, ...
                    ['The worst PI coverage day  by ML+OpticalFlow', datestr(resultSummary.date(day))]);
saveas(gcf,'WorstRMSE_All', 'fig');

% [worstPIcoverRate, day] = min(resultSummary.PIcoverRateAllBoot);
% PI = [outTables{day}.AllUpBound outTables{day}.AllLwBound];
% PIBoot = [outTables{day}.AllLwBoundBoot outTables{day}.AllUpBoundBoot];
% graph_desc(1:size(PI,1), outTables{day}.EnsembleAll, outTables{day}.Observed, PI, PIBoot, ...
%                     ['The worst bootPI coverage day  by ML+OpticalFlow', datestr(resultSummary.date(day))]);

% [worstPIcoverRate, day] = min(resultSummary.PIcoverRateAll);
% [worstBpptPIcoverRate, dayBoot] = min(resultSummary.PIcoverRateAllBoot);
% getPerformanceGraph(outTables, day,  ['The worst PI coverage day  by ML+OpticalFlow / ' datestr(resultSummary.date(day))]);
% getPerformanceGraph(outTables, dayBoot,  ['The worst BootPI coverage day by ML+OpticalFlow  / ' datestr(resultSummary.date(dayBoot))]);
% % Get the Worst (maximum) RMSE day
% [worstRMSE, day] = max(resultSummary.RmseAll);
% getPerformanceGraph(outTables, day, ['The worst RMSE day by ML+OpticalFlow  / ' datestr(resultSummary.date(day))]);

function graph_desc(x, y_pred, y_true, PI, PIBoot, name)
    % Get graph
    %   graph_desc(x, yLabel, y_pred, y_true, boundaries, name, ci_percentage)
    %   1. x values [array]
    %   2. y axis lable [char]
    %   3. forecasted value [array]
    %   4. target value [array]
    %   5. Prediction Inverval [array]
    %   6. figure title [char]
    %   7. Interval width ex) 96% -> 0.5
    % To overcome the bug in Matlab2019; it cannot display legneds lines in figs
    opengl software
    % parameters
    ci_percentage = 0.05;
    yLabel = 'PV generation [kwh]';
    
    % Graph description for prediction result
    f = figure;
    hold on;
    p(1) = plot(x, y_pred,'g', 'DisplayName','Forecasted', 'LineWidth', 1);
    if isempty(y_true) == 0
        p(2) = plot(y_true,'r', 'DisplayName','True', 'LineWidth', 1);
    end
    
    % Plot Prediction Intervals
    if isempty(PI) == 0
        % we have PI to be described
        CI = 100*(1-ci_percentage);
        p(4) = plot(PI(:,1),'b--', 'DisplayName', [num2str(CI) '% Prediction Interval'], 'LineWidth', 1);
        p(5) = plot(PI(:,2),'b--', 'LineWidth', 1);
        p(6) = plot(PIBoot(:,1),'k--', 'DisplayName', [num2str(CI) '% Prediction Interval (Bootstrap)'], 'LineWidth', 1);
        p(7) = plot(PIBoot(:,2),'k--', 'LineWidth', 1);
        % Turn off the legends for some lines
        set(get(get(p(5),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
        set(get(get(p(7),'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    end
    % Labels of the graph
    xlabel('Time instances');
    ylabel(yLabel);
    title(name);
    % Show legends
    legend('location', 'best');
end