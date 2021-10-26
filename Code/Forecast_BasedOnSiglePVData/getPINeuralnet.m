function [PImean, PImin, PImax] = getPINeuralNet(predictorTable, EnsembleEnergy,  errDistEnergy)
    [cutoffX] = getCutoff(errDistEnergy);
    
   
    %% Train the model for Energy Transition
    % Training for Energy Trantision
    % Training for SOC
    trainedNet_EnergyTrans = NeuralNet_train(trainData, colPredictors, {'ChargeDischargeKwh'});
    trainedNet_SOC = NeuralNet_train(trainData, colPredictors, 'SOCPercent');
    
    %% save result mat file
    building_num = num2str(trainData.BuildingIndex(1));
    save_name1 = '\EV_trainedNeuralNet_';
    save_fullPath = strcat(path,save_name1,building_num,'.mat');
    clearvars path;
    save(save_fullPath, 'trainedNet_EnergyTrans', 'trainedNet_SOC');
    % Display for user
    disp('Training the neraul network model.... Done!');
end

function trainedNet = NeuralNet_train(trainData, columnPredictors, columnTarget)
    % Iterete 3 times to make average of them. (more than 3 is also acceptable)
    % The forecasting error from randomness of neural network is reduced.
    maxLoop = 3;
    % Number of instances in the training data set
    n_instance = size(trainData,1);        
    % Training
    for i = 1:maxLoop
        x = transpose(table2array(trainData(1:n_instance, columnPredictors))); % input(feature)
        t = transpose(table2array(trainData(1:n_instance, columnTarget))); % target
        % Create and display the network
        net = fitnet([20,20,20,15],'trainscg');
        net.trainParam.showWindow = false;
        net = train(net,x,t); % Train the network using the data in x and t
        trainedNet{i} = net;             % save result
    end   
end

function [cutoffX] = getCutoff(err_distribution)

    hours = size(err_distribution,1);
    quarters = size(err_distribution,2);
    
    for hour = 1:hours
        for quarter = 1:quarters
            % get probabilisity density function object 
            pd = fitdist(err_distribution(hour, quarter).err,'Kernel','Kernel','epanechnikov');
            % get cutoff value for X and edge of the PDF
            % the cutoff is calculated by Inverse cumulative distribution function (icdf)
            cutoffX = icdf(pd, [.025, .975]);
            edgeX = icdf(pd, [.000001, .9999999]);
            % get x and y to be discribed
            x = linspace(edgeX(1), edgeX(2));
            y = pdf(pd, x);
            plot(x,y);
            % set area to be patched
            xci = [linspace(edgeX(1), cutoffX(1)); linspace(cutoffX(2), edgeX(2))]; % set X axis area
            yci = pdf(pd,xci);  % set Y axis area
            % Patch the outside of the Prediction Interval
            patch([xci(1,:) cutoffX(1)], [yci(1,:) 0], [0.5 0.5 0.5]);
            patch([cutoffX(2) xci(2,:)], [0 yci(2,:)], [0.5 0.5 0.5]);
        end
    end
    
    %% Display sample PDF and cutoff
    edgeX = icdf(pd, [.000001, .9999999]);
    % get x and y to be discribed
    x = linspace(edgeX(1), edgeX(2));
    y = pdf(pd, x);v 
    plot(x,y);
    % set area to be patched
    xci = [linspace(edgeX(1), cutoffX(1)); linspace(cutoffX(2), edgeX(2))]; % set X axis area
    yci = pdf(pd,xci);  % set Y axis area
    % Patch the outside of the Prediction Interval
    patch([xci(1,:) cutoffX(1)], [yci(1,:) 0], [0.5 0.5 0.5])
    patch([cutoffX(2) xci(2,:)], [0 yci(2,:)], [0.5 0.5 0.5])
end