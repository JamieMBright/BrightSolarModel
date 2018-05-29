%% User defined data safety checks
% class checks
if ~ischar(start_day)
    error('start_day is not an appropriate character string input of ''ddmmyyyy'' format')
end
if ~ischar(end_day)
        error('end_day is not an appropriate character string input of ''ddmmyyyy'' format')
end
if ~isnumeric(latitude_central)
        error('latitude is not an appropriate character string input of ''ddmmyyyy'' format')
end
if ~isnumeric(longitude_central)
        error('longitude is not an appropriate numeric input')
end

% size checks
if length(start_day)~=8
    error('start_day is not in format ''ddmmyyyy''')
end
if length(end_day)~=8
    error('end_day is not in format ''ddmmyyyy''')
end


%% reporting 

disp(['Dates:                ',datestr(datenum(start_day,'ddmmyyyy'),'dd/mm/yy'),' to ',datestr(datenum(end_day,'ddmmyyyy'),'dd/mm/yy')]);
disp(['Latitude central:     ',num2str(latitude_central),' degrees'])
disp(['Longitude central:    ',num2str(longitude_central),' degrees'])
disp('-------------------------------------------');
disp('Info on each property in the simulation:')
disp(table(house_info(:,1),house_info(:,2),house_info(:,3),house_info(:,4),house_info(:,5),'VariableNames',{'X','Y','elevation','azimuth','tilt'}))
disp('-------------------------------------------');