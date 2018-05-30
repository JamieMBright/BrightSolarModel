
%% Load in the data here.
% The data is required in a strict 1-hour time series format.
% cloud_base_height should be in deca-meteres (10m = 1 dm). This is the
%       standard format that most ceilometers report to.\%
% pressure should be in mb, use space below to convert if necessary.
%
% cloud_ammount should be in okta (note that it is converted to tenths
% later, and so provide it in tenths if you like and remove the below
% conversion)
%
% wind_speed is the hourly wind_speed measured at 10m (standard) in m/s.


sample_raw_data_duration = 24*365*10; % 10 years;

cloud_base_height = 1 + 10*round(50.*rand(length(time),1)); % load your cloud base height here, note that this can be removed, see notes in DeriveCloudCover around line 178

pressure = round(normrnd(1005,5,[length(time),1])); % load your 1h pressure data here

cloud_amount = round(normrnd(4.5,2.5,[length(time),1])); % load your data here, e.g. csvread('oktadata.csv')
cloud_amount(cloud_amount<0)= 0;
cloud_amount(cloud_amount>9)= 9;

wind_speed = round(gamrnd(2.7,2.144,[length(time),1]));  % load your wind_speed here. 

