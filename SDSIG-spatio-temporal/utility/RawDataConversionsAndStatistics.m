
%% This is a place to convert data and generate stats
% after this point, the variables do not change again, this part of the
% code is kept here in the user defined section so the user can easier
% identify potential errors due to the input data.

% Summarise the raw data into units and values of use
pressure_scale=5; % this is used for markov transition matrices to avoid enormous 1500x1500 matrices. We round to nearest 5.
pressure=round(pressure./pressure_scale); % round too nearest 5.

% further conversion of wind speed to avoid values that are insignificant
% and will not form a full range of Markov transition matrices.
% Furthermore, 0 is an invalid motion as it will break the movement of the
% clouds across the pv system.
wind_limit=u_range;%prctile(wind_speed,95);
wind_speed(wind_speed>wind_limit)=wind_limit;
wind_speed(wind_speed==0)=1;

% stats for later
wind_speed_max=max(wind_speed);
wind_speed_min=min(wind_speed);
wind_speed_range=range(wind_speed)+1;
cloud_amount_max=max(cloud_amount);
cloud_amount_min=min(cloud_amount);
cloud_amount_range=range(cloud_amount)+1;
pressure_avg=nanmean(pressure);
pressure_max=max(pressure);
pressure_min=min(pressure);
pressure_range=range(pressure)+1;
cloud_height_min = min(cloud_base_height);
cloud_height_max = max(cloud_base_height);
cloud_height_range = range(cloud_base_height)+1;
