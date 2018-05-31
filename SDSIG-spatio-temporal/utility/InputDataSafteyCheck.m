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
