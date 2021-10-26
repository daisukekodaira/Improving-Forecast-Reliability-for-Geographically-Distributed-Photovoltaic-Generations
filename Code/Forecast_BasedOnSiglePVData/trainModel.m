% ---------------------------------------------------------------------------
% PV forecast: Prediction Model development algorithm 
% Contact: daisuke.kodaira03@gmail.com
% 
% function flag =setPVModel(LongTermPastData)
%         flag =1 ; if operation is completed successfully
%         flag = -1; if operation fails.
% ----------------------------------------------------------------------------

function trainModel(trainTable,  framesInDay, validDays, colPredictors)
    warning('off','all');   % Warning is not shown
     
    %% Data preprocessing
    %     TableAllPastData = preprocess(T);
    
    %% Devide the data into training and validation
    % Parameter
    nValidData = framesInDay*validDays; % How many records are for validation 
    pvID =trainTable.PV_ID(1);
        
    %% Data restructure
    %     % Arrange the structure to be sotred for all data
    %     allData.Predictor = trainTable(:, colPredictors);
    %     allData.Target = table2array(trainTable(:, {'Observed'})); % trarget Data for validation (targets only)
    %     allData.OpticalFlow = table2array(trainTable(:, {'ForecastOpticalFlow'})); % Forecasted result by optical flow
    
    % Divide all past data into training and validation
    trainData = trainTable(1:end-nValidData, :);     % training Data (predictors + target)
    validData.Predictor = trainTable(end-nValidData+1:end, colPredictors);    % validation Data (predictors only)
    validData.Target = table2array(trainTable(end-nValidData+1:end, {'Observed'})); % trarget Data for validation (targets only)
    validData.OpticalFlow = table2array(trainTable(end-nValidData+1:end, {'ForecastOpticalFlow'}));
    
    %% Train each model using past load data
    kmeansPV_Training(trainData, colPredictors);
    neuralNetPV_Training(trainData, colPredictors);
    LSTMPV_Training(trainData, colPredictors);
    
    %% Validate the performance of each model
    % 1. k-means
    % 2. Neural net
    % 3. LSTM
    % 4. Optical Flow
    validData.Kmeans  = kmeansPV_Forecast(validData.Predictor, pvID);
    validData.NeuralNet= neuralNetPV_Forecast(validData.Predictor, pvID);
    validData.LSTM = LSTMPV_Forecast(validData.Predictor, pvID);
    validData.OpticalFlow = table2array(trainTable(end-nValidData+1:end, {'ForecastOpticalFlow'}));
    validDataML = [validData.Kmeans validData.NeuralNet validData.LSTM ];
    validDataALL = [validData.Kmeans validData.NeuralNet validData.LSTM validData.OpticalFlow];    
    
    %% Optimize the coefficients (weights) for the ensembled forecasting model
    weight.ML = getWeight(validData.Predictor, validDataML, validData.Target); % only Machine learning
    weight.All = getWeight(validData.Predictor, validDataALL, validData.Target);  % Machine learining + optical flow
           
    %% Get error distribution for validation data 
    % Calculate error from validation data
     [validData.errDistML, validData.errML] = getErrorDist(validData.Predictor, validDataML, validData.Target, weight.ML);   % 3 ML methods
     [validData.errDistOF, validData.errOF] = getErrorDist(validData.Predictor, validData.OpticalFlow, validData.Target, ones(24,1));  % only Optical flow
     [validData.errDistAll, validData.errAll] = getErrorDist(validData.Predictor, validDataALL, validData.Target, weight.All);    % all methods

    %     %% Get error distribution for all past data (training+validation data)
    %     % Get forecasted result from each method
    %     [allData.Pred(:,1)]  = kmeansPV_Forecast(allData.Predictor, pvID);
    %     [allData.Pred(:,2)] = neuralNetPV_Forecast(allData.Predictor, pvID);   
    %     [allData.Pred(:,3)] =  allData.OpticalFlow;
    %     [allData.errDist, allData.ensembledPred]= getErrorDist(allData, weight.ML);
    %     [allData.errDist, allData.ensembledPred]= getErrorDist(allData, weight.All);

    % Get neural network for PI 
    % this part is under configuration 2021/4/15 --------------------------
    %     getPINeuralnet(allData);
    % ----------------------------------------------------------------
    
    
    %% Save .mat files
    filename = {'PV_trainingData_', 'PV_weight_'};
    PVid = num2str(trainTable.PV_ID(1)); % Get building index to add to fine name
    varX = {'validData', 'weight'};
    for i = 1:size(varX,2)
        name = strcat(filename(i), PVid, '.mat');
        matname = fullfile(pwd, name);
        save(char(matname), char(varX(i)));
    end
    
%     % for debugging --------------------------------------------------------
%     % Under construction 2020 June 16th
%         display_result(1:size(nValidData,1), ensembledPredEnergy, validData.Target, [], 'EnergyTrans'); % EnergyTrans
%         display_result(1:size(nValidData,1), ensembledPredSOC, validData.TargetSOC, [], 'SOC'); % SOC 
%     % for debugging --------------------------------------------------------------------- 
end
