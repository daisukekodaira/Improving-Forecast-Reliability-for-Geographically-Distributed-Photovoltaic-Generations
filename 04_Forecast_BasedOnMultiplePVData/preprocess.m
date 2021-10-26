function fullTable = preprocess(data)
   
    %% Generate completed calendar in the duration
    % Get duration
    initYear = data.Year(1);
    endYear = data.Year(end);
    initMonth = data.Month(1);
    endMonth = data.Month(end);
    initDay = data.Day(1);
    endDay = data.Day(end);
    t(1) = datetime([data.Year(1),  data.Month(1), data.Day(1), 0, 0, 0]);  % initial date time
    t(2) = datetime([data.Year(end),  data.Month(end), data.Day(end)]); % last date time
    days = split(caldiff(t, 'days'), 'days');
    currentDay = t(1);  % set initial day
    for  i = 1:days  % while current day is smaller than last day
        initRow = (i-1)*96+1;
        lastRow = i*96;
        Year(initRow:lastRow,1) = ones(96,1)*year(currentDay);
        Month(initRow:lastRow,1) = ones(96,1)*month(currentDay);
        Day(initRow:lastRow,1) = ones(96,1)*day(currentDay);
        DayInWeek(initRow:lastRow,1) = ones(96,1)*weekday(currentDay);
        for j = 0:23
            hourInitRow = initRow+j*4;
            Hour(hourInitRow:hourInitRow+3,1) = ones(4,1)*j; % hour is from 0 to 23
            for k = 0:3 
                Quarter(hourInitRow+k,1) = k; % Quarter is from 0 to 3
            end
        end
        currentDay = currentDay + caldays(1);
    end
    fullTable = table(Year, Month, Day, DayInWeek, Hour, Quarter);
    
    %% Put the raw data into the completed calendar
    
    
    
    
    %% interpolation
    
    
end