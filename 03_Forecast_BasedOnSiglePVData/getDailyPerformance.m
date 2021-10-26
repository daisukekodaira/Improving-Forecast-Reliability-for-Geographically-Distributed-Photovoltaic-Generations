function [PICoverRate, MAPE, RMSE, PIWidth] = getDailyPerformance(PI, determPred, observed)
    % Calculate cover rate of PI
    if isempty(PI) == 0
        % If we have PI to be described
        count = 0;
        for i = 1:size(observed,1)
            if (PI(i,1)<=observed(i)) && (observed(i)<=PI(i,2))
                count = count+1;
            end
        end
        PICoverRate = 100*count/size(observed,1);
        PIWidth = mean(PI(:,2) - PI(:,1));  % (Upper boundary) - (Lower boundary)
    else
        % If we don't have PIs to be described, return empty
        PICoverRate = [];
        PIWidth = [];
    end
        
    % Calculate MAPE and RMSE
    MAPE = mean(abs(determPred - observed)*100./observed); % combined
    RMSE = sqrt(mean((determPred - observed).^2));
end