function [PICoverRate, MAPE, RMSE, PIWidth, outTable] = forecastPVgen(pvID, predictorTable, targetTable)  
    % parameters
    ci_percentage = 0.05; % 0.05 = 95% it must be between 0 to 1
       
    % Load mat files
    load(strcat('PV_weight_', num2str(pvID), '.mat'));  % Load weight
    load(strcat('PV_trainingData_', num2str(pvID), '.mat')) % Load validData
    
    %% Get individual prediction for test data
    % Two methods are combined
    %   1. k-menas
    %   2. Neural network
    %   3. LSTM
    [predResult.ML(:,1)]  = kmeansPV_Forecast(predictorTable, pvID);
    [predResult.ML(:,2)] = neuralNetPV_Forecast(predictorTable, pvID);
    [predResult.ML(:,3)] = LSTMPV_Forecast(predictorTable, pvID);
    
    %% Get combined prediction result with weight for each algorithm
    % Prepare the tables to store the deterministic forecasted result (ensemble forecasted result)
    % Note: the forecasted results are stored in an hourly basis
    predResult.EnsembleML = NaN(size(predictorTable, 1), 1);                
    predResult.EnsembleAll = NaN(size(predictorTable, 1), 1);
    predResult.OF = targetTable.ForecastOpticalFlow;
    predResult.All = [predResult.ML predResult.OF ];
    records = size(predResult.ML, 1);
    % generate ensemble forecasted result
    predictorTable.Hour = fix(predictorTable.Time);       % Transpose 'time' into hours
    for i = 1:records
        hour =predictorTable.Hour(i);
        predResult.EnsembleML(i) = sum(weight.ML(hour,:).*predResult.ML(i, :));
        predResult.EnsembleAll(i) = sum(weight.All(hour,:).*predResult.All(i, :));
    end
    % Get Prediction Interval
    % 1. Confidence interval basis method
    % Note: Method1 utilizes the error distribution derived from one month
    %            validation data which is not concained in the training process
    [predResult.MLPImean, predResult.MLLwBound, predResult.MLUpBound] = getPI(predictorTable, predResult.EnsembleML, validData.errDistML);
    [predResult.AllPImean, predResult.AllLwBound, predResult.AllUpBound] = getPI(predictorTable, predResult.EnsembleAll, validData.errDistAll);
    [predResult.OFPImean, predResult.OFLwBound, predResult.OFUpBound] = getPI(predictorTable, predResult.OF, validData.errDistOF);
    [predResult.MLLwBoundBoot, predResult.MLUpBoundBoot] = getPIBootstrap(predictorTable, predResult.EnsembleML, validData.errDistML);
    [predResult.AllLwBoundBoot, predResult.AllUpBoundBoot] = getPIBootstrap(predictorTable, predResult.EnsembleAll, validData.errDistAll);
    [predResult.OFLwBoundBoot, predResult.OFUpBoundBoot] = getPIBootstrap(predictorTable, predResult.OF, validData.errDistOF);
    %     % 2. Neural Network basis method
    %     % Note: Method2 utilized the error distribution deriveved from all past
    %     %           data which is utilized for trining process in ensemble forecastin model 
    %     [predData.EnergyPImean, predData.EnergyPImin, predData.EnergyPImax] = getPINeuralNet(predictorTable, predData.EnsembleEnergy,  allData.errDistEnergy);
    
    %% Write  down the forecasted result in csv file
    outTable = [predictorTable, struct2table(predResult), targetTable];

    %% Get forecast performance summary
    MLPI =  [predResult.MLLwBound, predResult.MLUpBound];
    OFPI = [predResult.OFLwBound, predResult.OFUpBound];
    AllPI =  [predResult.AllLwBound, predResult.AllUpBound];
    MLPIBoot =  [predResult.MLLwBoundBoot, predResult.MLUpBoundBoot];
    OFPIBoot =  [predResult.OFLwBoundBoot, predResult.OFUpBoundBoot];
    AllPIBoot =  [predResult.AllLwBoundBoot, predResult.AllUpBoundBoot];

    % Energy demand (ensembled)
    % Raw data set 
    % 1) Machine learning algorithms (3 methods)
    % 2) Only optical flow
    % 3) Ensemble ML methods and optical flow
    [PICoverRate.ensembleML, MAPE.ensembleML, RMSE.ensembleML, PIWidth.ensembleML] = getDailyPerformance(MLPI, predResult.EnsembleML, targetTable.Observed);
    [PICoverRate.OF, MAPE.OF, RMSE.OF, PIWidth.OF] = getDailyPerformance(OFPI, targetTable.ForecastOpticalFlow, targetTable.Observed);    
    [PICoverRate.ensembleAll, MAPE.ensembleAll, RMSE.ensembleAll, PIWidth.ensembleAll] = getDailyPerformance(AllPI, predResult.EnsembleAll, targetTable.Observed);
    % Bootstrapped data set
    [PICoverRate.ensembleMLBoot, ~, ~, PIWidth.ensembleMLBoot] = getDailyPerformance(MLPIBoot, predResult.EnsembleML, targetTable.Observed);
    [PICoverRate.OFBoot, ~, ~, PIWidth.OFBoot] = getDailyPerformance(OFPIBoot, targetTable.ForecastOpticalFlow, targetTable.Observed);
    [PICoverRate.ensembleAllBoot, ~, ~, PIWidth.ensembleAllBoot] = getDailyPerformance(AllPIBoot, predResult.EnsembleAll, targetTable.Observed);

    % 1. k-means
    % 2. Neural net
    % 3. LSTM
    [~, MAPE.kmeans, RMSE.kmeans, ~] = getDailyPerformance([], predResult.ML(:,1), targetTable.Observed);
    [~, MAPE.neuralNet, RMSE.neuralNet, ~] = getDailyPerformance([], predResult.ML(:,2), targetTable.Observed);    
    [~, MAPE.LSTM, RMSE.LSTM, ~] = getDailyPerformance([], predResult.ML(:,3), targetTable.Observed);    
    [~, MAPE.OF, RMSE.OF, ~] = getDailyPerformance([], targetTable.ForecastOpticalFlow, targetTable.Observed);    

end
