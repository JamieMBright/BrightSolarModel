%% Intialise the cloud cover generator
disp('Generating stochastic weather conditions');

%% Set starting Markov transition matrices
    
% select random start cloud_amount and wind speed
previous_cloud_amount =ceil(rand*9)-cloud_amount_min+1;
previous_wind_speed =ceil(rand*wind_speed_max)-wind_speed_min+1; 
previous_cloud_height =ceil(rand*cloud_height_max)-cloud_height_min+1;  
% start the pressure at the average pressure.
pressure_start=round(pressure_avg)-pressure_min+1; 

if pressure_start<0.5
    start_pressure_sys=1; % 50:50 chance to start at either high...
else
    start_pressure_sys=0;        % ... or low pressure.
% select pressure system
end
pressure_sys=start_pressure_sys;
pressure_markov_transition_matrix=cum_pressure_markov_prob;

start_season=seasons(1);
% determine start season  for the specified start point

% determine the first morning markov transition matrix required
switch start_season %switch the start_season variable(1,2,3,4) to select the appropriate markov chain
    case 1
        cloud_amount_markov_transition_matrix=cum_morningspring_prob; %if current season is 1, spring, select the spring markov.
    case 2
        cloud_amount_markov_transition_matrix=cum_morningsummer_prob;
    case 3
        cloud_amount_markov_transition_matrix=cum_morningautumn_prob;
    case 4
        cloud_amount_markov_transition_matrix=cum_morningwinter_prob;
end

% determin the wind speed okta
switch start_season
    case 1
        wind_markov_transition_matrix=cum_wind_spring_prob;
    case 2
        wind_markov_transition_matrix=cum_wind_summer_prob;
    case 3
        wind_markov_transition_matrix=cum_wind_autumn_prob;
    case 4
        wind_markov_transition_matrix=cum_wind_winter_prob;
end

% determin the cloud height
switch start_season
    case 1
        cloud_height_transition_matrix=cum_cloud_height_spring_prob;
    case 2
        cloud_height_transition_matrix=cum_cloud_height_summer_prob;
    case 3
        cloud_height_transition_matrix=cum_cloud_height_autumn_prob;
    case 4
        cloud_height_transition_matrix=cum_cloud_height_winter_prob;
end

%% set the weather at the start of the day using Markov transition matrices
% use Markov transition probabilities to derive the next cloud_amount and wind speed
current_cloud_amount = 1 + sum(cloud_amount_markov_transition_matrix(previous_cloud_amount,:)<rand); % use morning weighted markov chain to select hour 1
current_wind_speed=1 + sum(wind_markov_transition_matrix(previous_wind_speed,:)<rand);% use correct seasonal markov chain to select the windspeed
current_cloud_height=1+sum(cloud_height_transition_matrix(previous_cloud_height,:)<rand); % use appropriate markov chain to select start cloud height
current_pressure=1+nansum(pressure_markov_transition_matrix(pressure_start,:)<rand);
current_cloud_dir = rand*360; % random cloud direction to start.

%% Cloud cover production
% pre-allocate the stored variables
cloud_amount_sim=zeros(size(time)).*NaN;
wind_speed_sim=zeros(size(time)).*NaN;
cloud_height_sim=zeros(size(time)).*NaN;
pressure_sim=zeros(size(time)).*NaN;
pressure_system_sim=zeros(size(time)).*NaN;
coverage_sim=zeros(size(time)).*NaN;
cloud_field_sample_sim=zeros(size(time)).*NaN;
cloud_dir_sim=zeros(size(time)).*NaN;
sun_obscurred_sim=zeros(size(time)).*NaN;

coverage_1min_sim=zeros(size(time_1min_resolution)).*NaN;
wind_speed_1min_sim=zeros(size(time_1min_resolution)).*NaN;
cloud_amount_1min_sim=zeros(size(time_1min_resolution)).*NaN;

% Produce the cloud cover over entire length of simulation as well as time requirements for irradiance calculations
% this loop goes through every hour of the desired simulation time and creates 1-minute resolution cloud cover.
for h=1:length(time) %hour is the increasing value from 6 to hours(the preset length of the simulation).
    %move the current variables into the past   
    %as the time progresses, the current state becomes the previous state and a new current state is stochastically determined later in loop
    previous_cloud_amount=current_cloud_amount;  
    previous_wind_speed=current_wind_speed; 
    previous_pressure=current_pressure;
    previous_cloud_height=current_cloud_height;
    previous_cloud_dir=current_cloud_dir;
            
    %%%%%%%%%%%% PRESSURE SYSTEM %%%%%%%%%%%%%%%%%%%%
   %select appropriate pressure markov chain
    if previous_pressure<pressure_avg
        presssure_sys=0;
    else
        pressure_sys=1;
    end
    
    %%%%%%%%%%%%%%%%%%%% CLOUD AMOUNT %%%%%%%%%%%%%%%%%%%%%%%%
    % determine which markov trasition matrices to use for the future cloud_amount
    switch seasons(h) %switch the season, query the pressure
        case 1 % spring            
            if pressure_sys==0 %if it is low pressure, use the spring low pressure transition probability matrix
                cloud_amount_markov_transition_matrix=cum_springlp_prob; 
            else  % else use the spring high pressure transition probabilit matrix
                cloud_amount_markov_transition_matrix=cum_springhp_prob; 
            end
        case 2 % repeat for the reast of the seasons. summer
            if pressure_sys==0
                cloud_amount_markov_transition_matrix=cum_summerlp_prob;
            else
                cloud_amount_markov_transition_matrix=cum_summerhp_prob;
            end
        case 3 % autumn
            if pressure_sys==0
                cloud_amount_markov_transition_matrix=cum_autumnlp_prob;
            else
                cloud_amount_markov_transition_matrix=cum_autumnhp_prob;
            end
        case 4 % winter
            if pressure_sys==0
                cloud_amount_markov_transition_matrix=cum_winterlp_prob;
            else
                cloud_amount_markov_transition_matrix=cum_winterhp_prob;
            end
    end
    
    %select the morning markov chain when hour number is 1-6am
    %overwrite the cloud_amount_transition_matrix with a morning MTM if before 6am
    if hours_of_day(h)<=6 % if the hour is 1--6
        switch seasons(h) 
            case 1
                cloud_amount_markov_transition_matrix=cum_morningspring_prob; %...select the appropriate morning seasonal transition probability matrix
            case 2
                cloud_amount_markov_transition_matrix=cum_morningsummer_prob; % and repeat for each season.
            case 3
                cloud_amount_markov_transition_matrix=cum_morningautumn_prob;
            case 4
                cloud_amount_markov_transition_matrix=cum_morningwinter_prob;
        end
    end    
        
     %%%%%%%%%%%%%%%%% WIND SPEED %%%%%%%%%%%%%%%%%
    % select the appropriate markov chain for wind speed
    switch seasons(h)
        case 1         
            wind_markov_transition_matrix=cum_wind_spring_prob;
        case 2            
            wind_markov_transition_matrix=cum_wind_summer_prob;
        case 3            
            wind_markov_transition_matrix=cum_wind_autumn_prob;
        case 4            
            wind_markov_transition_matrix=cum_wind_winter_prob;
    end    
    
     %%%%%%%%%%%%%%%%% CLOUD HEIGHT %%%%%%%%%%%%%%%%%
    % select the appropriate markov chain for cloud height
    switch seasons(h)
        case 1         
            cloud_height_transition_matrix=cum_cloud_height_spring_prob;
        case 2            
            cloud_height_transition_matrix=cum_cloud_height_summer_prob;
        case 3            
            cloud_height_transition_matrix=cum_cloud_height_autumn_prob;
        case 4            
            cloud_height_transition_matrix=cum_cloud_height_winter_prob;
    end    
 
    %%%%%%%%%%%%% APPLY THE MARKOV TRANSITION MATRICES %%%%%%%%%%%%%%%%
    %Determine the future states using the appropriately selected transition probability matrices.
    current_cloud_amount=1+sum(cloud_amount_markov_transition_matrix(previous_cloud_amount,:)<rand); %see the paper eq.10 for a better explanation
    current_wind_speed=1+sum(wind_markov_transition_matrix(previous_wind_speed,:)<rand);
    current_cloud_height=1+sum(cloud_height_transition_matrix(previous_cloud_height,:)<rand); % use appropriate markov chain to select start cloud height
    current_pressure=1+nansum(pressure_markov_transition_matrix(previous_pressure,:)<rand);
    
    %%%%%% CLOUD DIRECTION
    current_cloud_dir=normrnd(previous_cloud_dir,10); %needs update, just random.
    % modulo division by 360 so that cloud directions <0 or >360 are
    % normalised
    current_cloud_dir = mod(current_cloud_dir,360);
    
    
    % Transform the ground wind speed to the speed at the cloud height (met office):
    %u_ref=u10(log(zref/zoref))/(log(z10/zoref)) for <1km height. A distribution is used for above this. THIS is a significant limitation
    %to accurately determining the cloud speed and should be addressed more. It is difficult to do so without more detailed input data.
    % there is support for the correlation of ground wind speed to
    %%%% NOTE ON CLOUD BASE HEIGHT
    % This is the only place cloud base height is used, and as you can see,
    % it is only if the cloud is below 100dm, which is rare. For this
    % reason, it feels redundant.
    % A study by a student that I guided found a strong linear relationship
    % between cloud speed and 10m wind speed in Leeds, UK, and Kampala, Uganda.
    % http://eprints.whiterose.ac.uk/130200/
    % They found that cloud_speed = 1.9*10m_wind_speed + 9.055 for hourly
    % wind speed over a 5 month study period fit with am R^2 correlation of 
    % 0.91. Therefore, cloud base height can be removed and the below if
    % statement with:
    % current_wind_speed = 1.9.*current_windspeed + 9.055;
    % however, all mention of cloud base height will also need to be
    % commented out.       
    if current_cloud_height<100 %height is in decameters. so below 100 is under 1km.
        current_wind_speed=ceil(current_wind_speed*0.515*((log(current_cloud_height*10/0.14))/(log(10/0.14)))); %perform the met office interpolation %note the 0.515 conversion of knots to m/s. 0.14 is for a rural setting, this could perhaps be updated based on desired location.
    else % else use the ganrnd function above 1km.
        current_wind_speed=round(gamrnd(2.7,2.144)); %gives mean of 3.49m/s with range 0-25 and 0.5% above 25.
    end
    
    % quality check the wind speed
    if current_wind_speed<1        
        current_wind_speed=1;
    elseif current_wind_speed>wind_speed_max
        current_wind_speed=wind_speed_max;  
    end
    
    %convert cloud_amount number into its proportionate sky coverage (out of 10) %WMO 2700 code for cloud cover provides conversions of cloud_amount in 8ths to 10ths.
    switch current_cloud_amount %using whatever the current hour's cloud_amount value is, convert it according to the WMO 2700 code suggestions
        case 1; coverage=1;                 cloud_amount_1min_sim(h*(t_res-1)+1:h*t_res)=1;                %1/10 or less but not zero
        case 2; coverage=2+floor(2*rand);   cloud_amount_1min_sim(h*(t_res-1)+1:h*t_res)=2;                %2/10 - 3/10
        case 3; coverage=4;                 cloud_amount_1min_sim(h*(t_res-1)+1:h*t_res)=3;                %4/10
        case 4; coverage=5;                 cloud_amount_1min_sim(h*(t_res-1)+1:h*t_res)=4;                %5/10
        case 5; coverage= 6;                cloud_amount_1min_sim(h*(t_res-1)+1:h*t_res)=5;                %6/10
        case 6; coverage=7+floor(2*rand);   cloud_amount_1min_sim(h*(t_res-1)+1:h*t_res)=6;                %7/10 or 8/10
        case 7; coverage=9;                 cloud_amount_1min_sim(h*(t_res-1)+1:h*t_res)=7;                %9/10+ but not 10/10
        case 8; coverage=10;                cloud_amount_1min_sim(h*(t_res-1)+1:h*t_res)=8;                %10/10
        case 9; coverage=10;                cloud_amount_1min_sim(h*(t_res-1)+1:h*t_res)=9;                %sky obscured by fog and/or weather or other meteorlogical phenomena
        case 10; coverage=0;                cloud_amount_1min_sim(h*(t_res-1)+1:h*t_res)=0;                %0/10 (note that ockta 0 has been changed to 10 for array use)
    end
        
    % update the simulation stored variables
    % conversions are made from col/row index to units of the variable
    cloud_amount_sim(h)=current_cloud_amount+cloud_amount_min-1;
    wind_speed_sim(h)=current_wind_speed+wind_speed_min-1;
    pressure_sim(h)=current_pressure.*pressure_scale+pressure_min-1;    
    cloud_height_sim((h-1)*t_res+1:h*t_res) = current_cloud_height+cloud_height_min-1;
    pressure_system_sim(h)=pressure_sys;
    coverage_sim(h)=coverage;
    coverage_1min_sim((h-1)*t_res+1:h*t_res) = coverage;
    cloud_dir_sim(h)=current_cloud_dir;
    cloud_field_sample_sim(h)=ceil((num_of_samples-1)*rand)+1;
    wind_speed_1min_sim((h-1)*t_res+1:h*t_res) = current_wind_speed+wind_speed_min-1;
    cloud_amount_1min_sim((h-1)*t_res+1:h*t_res) =current_cloud_amount+cloud_amount_min-1;
 end
 