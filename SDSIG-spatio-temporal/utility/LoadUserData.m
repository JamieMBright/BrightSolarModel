%% User defined variables
% The user should fill in the variables within the USER_INPUT_DATA folder.
% This is the script that loads up the data into memory for the SDSIG to
% use.
%
%% SINGLE VALUE INPUT OF TIME
% start_day - must be a string of number characters in 'ddmmyyyy' format
%             e.g. 1st January 2018  =  '01012018'
%
% end_day   - must be a string of number characters in 'ddmmyyyy' format
%             e.g. 5th January 2018  =  '05012018'
%
% latitude_central  - must be a numeric vector matrix. Must be a single site
%             Note that the SIG cannot provide time series
%             with a relationship to each other, for that purpose, the
%             modern SDSIG version should be used. The permissible range is
%             -90 to 90 whereby -90 is the south pole, 90 is the north.
%             e.g. 50.1234  
%
% longitude_central - must be a numeric vector matrix. Must be a single site 
%             Note that the SIG cannot provide time series
%             with a relationship to each other, for that purpose, the
%             modern SDSIG version should be used. The permissible range 
%             is -180 to 180 whereby -180 is degrees west of the prime
%             meridian (London), and 180 is degrees east.
%             e.g. 140.877       
% 
% panel_pitch - must be a numeric vector matrix. This is the tilt of the 
%               panels. permissible values are 0:90 whereby 0 represents a
%               flat panel and 90 is fully verticle aiming towards the 
%               azimuth angle.
%               e.g. 30.35
% 
% panel_azimuth - must be a numeric vector matrix.
%                 the orientation of each panel measured where 0 is due
%                 south and -180 or 180 is equal to due north. Negative
%                 values indicate westerly while positive are easterly.
%                 e.g.  -15.9
%
% height_above_sea_level - must be a numeric vector matrix. this is the
%                          height above sea level of the associated site 
%                          latitude and longitude in metres. e.g. 50
%
% house_info - this is the metadata of all the houses within a spatial
%              domain defined by the central lat/lon/elevation. It is a
%              strict format of [x,y,h,aximuth,tilt], where each row is a
%              new property. 
%
%

% -----------------------------------------------------------------------
%% Load in the user simulation data data
% The user should fill in the simulation_settings.txt and house_info.csv in
% order to define the settings for this simulation. The descriptions of
% what information is required in those settings is described above

fid = fopen('USER_INPUT_DATA\simulation_settings.txt');
user_data = textscan(fid,'%s%s%f%f%f','delimiter',',','endofline','\r\n','headerlines',1);
fclose(fid);
start_day = cell2mat(user_data{1,1});
end_day = cell2mat(user_data{1,2});
latitude_central = user_data{1,3};
longitude_central = user_data{1,4};
height_above_sea_level_central = user_data{1,5};
% start_day='01012017'; % set the start time of the simulation
% end_day='01012018'; % set the end time of the simulation
% latitude_central=50.2178; % set the latitude of the desired location. Currently Cambourne, UK
% longitude_central=-5.32656; % set the longitude of the desired location. Currently Cambourne, UK
% height_above_sea_level_central=87; %meters above sea level. Currently Cambourne, UK

%% Load in the house information
% define the different properties within the simulation
%  NOTE that this is an arbitrary example to set random properties of X,Y,h,azi and tilt.
house_info = csvread('house_info.csv',1,0);
number_of_houses = size(house_info,1);

%% Load in the raw variables data here.
% The data is required in a strict 1-hour time series format. Each variable
% can have its own time series (with exception of cloud_amount and pressure
% as these must be the same), it must be in matlab datenum() format and
% be of equal size to its corresponding variable

% IMPORTANT!
% The data produced here is just example data. You need to replace each
% variable within this script with your own raw data!
% e.g. consider pressure.
% you must produce a variable called "pressure" that is a 1-hour resolution
% time series of pressure data for close to the central lat-lon defined.
% the variable time_pressure must be a datenum time series of time stamps
% for the corresponding pressure variable.

% cloud_base_height should be in deca-meteres (10m = 1 dm). This is the
% standard format that most ceilometers report to.
data=csvread('USER_INPUT_DATA\cloud_base_height.csv',1,0);
% load the time stamps for the cloud base height.
time_cloud_base_height = data(:,1);
% load the cloud base height here
cloud_base_height =data(:,2); 
clear data

% pressure must be in mb, use space below to convert if necessary.
data=csvread('USER_INPUT_DATA\pressure.csv',1,0);
% load the time stamps for the pressure.
time_pressure = data(:,1);
% load the pressure here
pressure =data(:,2); 
clear data

% cloud_amount must be in okta (where 0 to 8 out of 8 describes the
% fraction of cloud cover in eigths, and 9 okta is for obscurred/haze/mist
% or other meteorological phenomenon.
data=csvread('USER_INPUT_DATA\clound_amount.csv',1,0);
% load the time stamps for the cloud base height.
time_cloud_amount = data(:,1);
% load the cloud base height here
cloud_amount =data(:,2); 
clear data

% wind_speed is the hourly wind_speed measured at 10m (standard) in m/s.
data=csvread('USER_INPUT_DATA\wind_speed.csv',1,0);
% load the time stamps for the wind_speed times.
time_wind_speed = data(:,1);
% load the wind speed here
wind_speed =data(:,2); 
clear data

