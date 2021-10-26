function kmeansPV_Training(trainData, colPredictors)

    %% Read inpudata
    %     train_data = LongTermpastData(~any(isnan(LongTermpastData),2),:); % Eliminate NaN from inputdata
    %     %% Format error check (to be modified)
    %     % "-1" if there is an error in the LongpastData's data form, or "1"
    %     [~,number_of_columns1] = size(train_data);
    %     if number_of_columns1 == 12
    %         error_status = 1;
    %     else
    %         error_status = -1;
    %     end
    
    %     % Display for user
    %     disp('Training the k-menas & Baysian model....');

    %% Kmeans clustering for Charge/Discharge data
    % Extract appropriate data from inputdata for Energy transactions: pastEnegyTrans
    % Extract appropriate data from inputdata for SOC prediction: pastSOC
    PastPredictors= table2array(trainData(:, colPredictors)); % Extract predictors (Year,Month,Day,Hour,Quater,P1(Day),P2(Holiday))
    pastTarget = table2array(trainData(:, {'Observed'})); % Charge/Discharge [kwh]

    % Set K for Charge/Discharge [kwh]. 50 is experimentally chosen
    % Set K for SOC[%]. 35 is experimentally chosen
    k = 50;
    
    % Train k-means clustering
    [idx, centroid] = kmeans(pastTarget, k);
    
    % Train multiclass naive Bayes model
    NaiveBayesModel = fitcnb(PastPredictors, idx,'Distribution','kernel');
        
    %% Save trained data in .mat files
    % idx: index for each record
    % k: optimal K  (experimentally chosen)    
    % NaiveBayesModel: Trained Baysian model for Charge/Discharge [kwh]
    % centroid: centroid for each cluster. The number of these values must correspond with k_EnergyTrans
    save_name = strcat(pwd, '\PV_trainedKmeans_', num2str(trainData.PV_ID(1)),'.mat');
    save(save_name, 'idx', 'k', 'NaiveBayesModel', 'centroid');
    %     disp('Training the k-menas & Baysian model.... Done!');

end