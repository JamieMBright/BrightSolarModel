%% User defined variables
% The user should fill in the variables within this script to tailor the
% Bright Solar Irradiance Generator to the required outputs.
%
% start_day - must be a string of number characters in 'ddmmyyyy' format
%             e.g. 1st January 2018  =  '01012018'
%
% end_day   - must be a string of number characters in 'ddmmyyyy' format
%             e.g. 5th January 2018  =  '05012018'
%
% latitude  - must be a numeric vector matrix. Must be a single site
%             Note that the SIG cannot provide time series
%             with a relationship to each other, for that purpose, the
%             modern SDSIG version should be used. The permissible range is
%             -90 to 90 whereby -90 is the south pole, 90 is the north.
%             e.g. 50.1234  
%
% longitude - must be a numeric vector matrix. Must be a single site 
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

% -----------------------------------------------------------------------
%% user data

% IF YOU HAVE RUN THE MODEL ONCE AND ARE NOW CHANGING LOCATION, YOU MUST
% CLEAR THE DATA ELSE THE WRONG NWP DATA WILL BE USED FOR THE NEW LOCATION.
% YOU CAN USE clearvars 
start_day='01012017';
end_day='01012018';
latitude=50.2178;
longitude=-5.32656;
panel_pitch=30;
panel_azimuth=-5;
height_above_sea_level = 50;