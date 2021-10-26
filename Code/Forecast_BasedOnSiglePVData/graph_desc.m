function graph_desc(x, yLabel, y_pred, y_true, PI, PIBoot, name, ci_percentage)
    % To overcome the bug in Matlab2019; it cannot display legneds lines in figs
    opengl software 
    
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