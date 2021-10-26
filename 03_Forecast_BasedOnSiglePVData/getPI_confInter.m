% Return the boundaries of confidence interval


function [m, lwBound, upBound] = getPI_confInter(prob_prediction)    
    %% calculate Mean, standard deviation, 95% Confidence interval
    m = mean(prob_prediction);
    s = std(prob_prediction);
    upBound = m + 2*s; % mean+2sigma
    lwBound = m - 2*s; % mean-2sigma

    % rectify the minus data to zero 
    lwBound = max(lwBound,0);
    upBound = max(upBound,0); 

    % %% graph describe
    % hold on;
    % for i = 1:size(prob_prediction,1)
    %     plot(prob_prediction(i,:), 'green');
    % end
    % plot(lwBound, 'black');
    % plot(upBound, 'black');
    % legend('95% boundaries by Confidence Interval');
end    