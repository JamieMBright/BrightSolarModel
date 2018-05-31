%% Load in the data here.
% The data is required in a strict 1-hour time series format. Each variable
% can have its own time series (with exception of cloud_amount and pressure
% as these must be the same), it must be in matlab datenum() format and
% be of equal size to its corresponding variable

%% IMPORTANT!
% The data produced here is just example data. You need to replace each
% variable within this script with your own raw data!
% e.g. consider pressure.
% you must produce a variable called "pressure" that is a 1-hour resolution
% time series of pressure data for close to the central lat-lon defined.
% the variable time_pressure must be a datenum time series of time stamps
% for the corresponding pressure variable.

% cloud_base_height should be in deca-meteres (10m = 1 dm). This is the
% standard format that most ceilometers report to.
time_cloud_base_height = datenum('20000101','yyyymmdd'):1/24:datenum('20000101','yyyymmdd')+365*10; % 10 year time series
cloud_base_height = 1 + 10*round(50.*rand(length(time_cloud_base_height),1)); % load your cloud base height here, note that this can be removed, see notes in DeriveCloudCover around line 178

% pressure must be in mb, use space below to convert if necessary.
time_pressure = datenum('20000101','yyyymmdd'):1/24:datenum('20000101','yyyymmdd')+365*20; % 5 year time series
pressure = round(normrnd(1005,5,[length(time_pressure),1])); % load your 1h pressure data here

% cloud_amount must be in okta (where 0 to 8 out of 8 describes the
% fraction of cloud cover in eigths, and 9 okta is for obscurred/haze/mist
% or other meteorological phenomenon.
time_cloud_amount = datenum('20000101','yyyymmdd'):1/24:datenum('20000101','yyyymmdd')+365*20; % 20 year time series
cloud_amount = round(9*rand([length(time_cloud_amount),1])); % load your data here, e.g. csvread('oktadata.csv')

% wind_speed is the hourly wind_speed measured at 10m (standard) in m/s.
time_wind_speed= datenum('20000101','yyyymmdd'):1/24:datenum('20000101','yyyymmdd')+365*8; % 8 year time series
wind_speed = round(gamrnd(2.7,2.144,[length(time_wind_speed),1]));  % load your wind_speed here. 






