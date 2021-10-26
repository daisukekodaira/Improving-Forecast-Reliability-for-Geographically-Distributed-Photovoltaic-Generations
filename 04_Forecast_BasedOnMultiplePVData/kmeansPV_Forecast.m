function [pred] = kmeansPV_Forecast(predictorTable, pvID)  
          
    %% Read inpudata
    % Load mat files
    load_name = strcat(pwd, '\PV_trainedKmeans_', num2str(pvID),'.mat');
    load(load_name,'-mat');
    
    %% Prediction based on the Naive Bayes classification model
    predictors = table2array(predictorTable);   % change table to array
    label = NaiveBayesModel.predict(predictors);  % Distribute class label using attribute "predict".
    pred = centroid(label,:);    % Extract centroid as a predicted targe
    
end
