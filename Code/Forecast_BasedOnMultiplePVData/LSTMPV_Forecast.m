function result_LSTM = LSTMPV_Forecast(predictors, pvID)
    % PV prediction: LSTM Model Forecast algorithm
    %% load .mat file
    load_name = '\PV_LSTM_';
    load_name = strcat(pwd, load_name, num2str(pvID),'.mat');
    load(load_name,'-mat');
    % Make the test data starndardlized using mean and sigma from training data
    % 'predictorsMean' and 'predictorsSigma' are defined in 'LSTMPV_Training.m' in advance
    % 'predictorsMean' and 'predictosSigma' contain {Seaon, Year, Month, Day, Time, Tempreature, Precipitation, Weather}
    Xtest =((predictors{:, :} - predictorsMean)./predictorsSigma)';
    numTimeStepsTest = size(Xtest, 2);
    for i = 1:numTimeStepsTest
        [pv_net, YPred(:,i)] = predictAndUpdateState(pv_net, Xtest(:,i),'ExecutionEnvironment','auto');
    end
    % The standarlized results are converted into orignal value
    result_LSTM = (targetSigma.*YPred + targetMean)'; 
    % All result (PV generation) must be more than 0
    result_LSTM = max(result_LSTM, 0);
end