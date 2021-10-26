function LSTMPV_Training(trainData, colPredictors)
% PV prediction: LSTM Model Forecast algorithm
%% Standarlization the predictors and the target
predictorsMean = mean(trainData{: ,colPredictors});
predictorsSigma = std(trainData{: , colPredictors}); 
targetMean = mean(trainData{:, 'Observed'});
targetSigma = std(trainData{:, 'Observed'});
% Fill NaN value
predictorsSigma = fillmissing(predictorsSigma, 'constant', 1);
targetSigma = fillmissing(targetSigma, 'constant', 1);

% Arrange Input and Target for LSTM
% Input; Standardlized predictors {Seaon, Year, Month, Day, Time, Tempreature, Precipitation, Weather}
% Target; Standardlized observed 
input = (trainData{: ,colPredictors} - predictorsMean) ./ predictorsSigma;
target = (trainData{: ,'Observed'} - targetMean) ./ targetSigma;
% Fill NaN value
input = fillmissing(input, 'constant', 1)';
target = fillmissing(target, 'previous')';


%% train lstm (generation)
%lstm
numFeatures = size(colPredictors,2);
numResponses = 1;   % 1
numHiddenUnits1 = 100;  % 100
numHiddenUnits2 = 50;   % 50
numHiddenUnits3 = 25;   % 25
layers = [ ...
    sequenceInputLayer(numFeatures)
    reluLayer
    lstmLayer(numHiddenUnits1)
    reluLayer
    lstmLayer(numHiddenUnits2)
    reluLayer
    lstmLayer(numHiddenUnits3)    
    reluLayer
    fullyConnectedLayer(numResponses)
    regressionLayer];
options = trainingOptions('adam', ...
    'MaxEpochs',250, ...
    'GradientThreshold',1.2, ...
    'InitialLearnRate',0.01, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',125, ...
    'LearnRateDropFactor',0.2, ...
    'Verbose',0);
pv_net = trainNetwork(input, target, layers, options);
    %% save result mat file
    clearvars input;
    clearvars shortTermPastData dataTrainnormalize
    save_name = '\PV_LSTM_';
    save_name = strcat(pwd, save_name, num2str(trainData.PV_ID(1)),'.mat');
    save(save_name);
end