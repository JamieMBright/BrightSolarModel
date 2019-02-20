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
    error(['start_day is not in format ''ddmmyyyy''. The value entered was: ', start_day])
end
if length(end_day)~=8
    error(['end_day is not in format ''ddmmyyyy'' The value entered was: ', end_day])
end


%% reporting 

disp(['Dates:                ',datestr(datenum(start_day,'ddmmyyyy'),'dd/mm/yy'),' to ',datestr(datenum(end_day,'ddmmyyyy'),'dd/mm/yy')]);
disp(['Latitude central:     ',num2str(latitude_central),' degrees'])
disp(['Longitude central:    ',num2str(longitude_central),' degrees'])
disp('-------------------------------------------');
disp('Info on each property in the simulation:')
disp(table(house_info(:,1),house_info(:,2),house_info(:,3),house_info(:,4),house_info(:,5),'VariableNames',{'X','Y','elevation','azimuth','tilt'}))
disp('-------------------------------------------');

%% checks of the raw data
%% Safety checks on the raw data here

% standard exist check
if ~exist('cloud_base_height', 'var')
    error('cloud_base_height variable does not exist')
end

if ~exist('pressure', 'var')
    error('pressure variable does not exist')
end

if ~exist('cloud_amount', 'var')
    error('cloud_amount variable does not exist')
end

if ~exist('wind_speed', 'var')
    error('wind_speed variable does not exist')
end

 % numeric check
if ~isnumeric(cloud_base_height)
    error('cloud_base_height must be numerical input')
end

if ~isnumeric(pressure)
    error('pressure must be numerical input')
end

if ~isnumeric(cloud_amount)
    error('cloud_amount must be numerical input')
end

if ~isnumeric(wind_speed)
    error('wind_speed must be numerical input')
end

if time_cloud_amount ~= time_pressure
    error('the pressure and cloud amount must align')
end

% check that the temporay_files directory exists; if not, make it. 
if ~exist([home_dir,'supportingfiles',filesep,'temporary_files',filesep],'dir')
    mkdir([home_dir,'supportingfiles',filesep,'temporary_files',filesep]);
end
