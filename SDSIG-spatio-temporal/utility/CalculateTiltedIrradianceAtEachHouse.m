%% Tilted irradiance and clear-sky alteration code
% this code loops through each house and anlyses the clear sky code
% alongside other variables in order to add cloud edge enhancements, long
% period of 0 or 8 okta analysis.
% A provisional step is to determine the size of the outputs. This is a
% function of the duration demanded of the SDSIG, the number of houses
% opted for, and the available system memory for matlab.

% clear the outputs folder
delete(['outputs',filesep,'*']);

% make sure the outputs folder actually exists
if ~exist('outputs','dir')
    mkdir('outputs');
end

% reporting
disp('Applying cloud edge enhancements and long term clear and overcast statistics to clear-sky index')
disp('Calculating the tilted irradiance...')

% check available memory
[userview,systemview] = memory;
available_memory = userview.MemAvailableAllArrays;
required_memory = 8 * length(time_1min_resolution) * number_of_houses * 2;

if available_memory*0.6666 > required_memory
    write_mode = false;
    kc_minutely_all = zeros(length(time_1min_resolution),number_of_houses).*NaN;
    house_panel_irradiance = zeros(length(time_1min_resolution),number_of_houses).*NaN;
else
    write_mode = true;
    disp('There is too much data to load all houses for all time steps into memory, and so write_mode has been activated. This means that each site will have an individual output of clear-sky and tilted irradiance')
end

%initialisation
not_obscured_min=zeros(1,length(time)); %pre allocate array

%kc values for clear sky periods based on Demroes kc_index using distribution curve fitting.
for i=1:floor(length(not_obscured_min)/1440) % loop through each day
    not_obscured_min(i*1440-1439:i*1440)=normrnd(0.99,0.08);%
    % this distribution is N(0.99,0.08) for Camborne,
    % tLocationScale(mu=1.11566,sigma=0.111785,nu=3.2205) for Lerwick
    % Burr dist(alpha=0.981286,c=72.3685,k=0.120297) for Hawaii
    % and N(1.02394,0.04) for San Diego
    
end
not_obscured_min(zenith_angle>90)=0; %take account of night

for house=1:number_of_houses % loop through each houses
    
    disp(['              ...for house: ',num2str(house)]) %indicate to the user the progress
    
    %% load up each house's data
    house_kcvalues_temp=dlmread(['supportingfiles',filesep,'temporary_files',filesep,'house_kcvalues_',num2str(house),'.txt'])';
    house_coverages_temp=dlmread(['supportingfiles',filesep,'temporary_files',filesep,'house_coverages_',num2str(house),'.txt'])';
    sep_temp=dlmread(['supportingfiles',filesep,'temporary_files',filesep,'separation_',num2str(house),'.txt'])';
    
    %pre allocate
    separation=zeros(size(wind_speed_1min_sim));
    house_coverages=zeros(size(wind_speed_1min_sim));
    house_kcvalues=zeros(size(wind_speed_1min_sim));
    
    for i=1:length(time) %extract the house data to working files
        separation(i*60-59:i*60)=sep_temp(:,i)';
        house_coverages(i*60-59:i*60)=house_coverages_temp(:,i)';
        house_kcvalues(i*60-59:i*60)=house_kcvalues_temp(:,i)';
    end
    
    %separation in time from edge of domain at each moment.
    separation=separation./wind_speed_1min_sim;
    separation=floor(separation./temporal_res);
    
    %produce indicators of 8 okta periods
    Ok8_ind=zeros(length(cloud_amount_1min_sim),1); %pre allocate
    for i=2:length(cloud_amount_1min_sim)-1 %loop through okta
        if cloud_amount_1min_sim(i)==8 && cloud_amount_1min_sim(i+1)==8 && cloud_amount_1min_sim(i-1)~=8
            Ok8_ind(i)=1; %indicate start of period
        end
        if cloud_amount_1min_sim(i)==8 && cloud_amount_1min_sim(i-1)==8 && cloud_amount_1min_sim(i+1)~=8
            Ok8_ind(i)=2; %indicate end of period
        end
    end % in 00010000200 format now.
    
    Ok8_duration=1; %initialise the marker
    ok8_cutoff=4; %set the okta 8 cutoff period
    a_ScaleParameter=coeff.scale(78); %extract the shape and scale parameters from coefficients.csv using the indicator CompoundConditionalInd
    p_ShapeParameter=coeff.shape1(78); % parameters  for okta 8 at 10deg elev
    d_ShapeParameter=coeff.shape2(78); %else zeros propagate into obscured min
    %create the Genralised Gamma distribution PDF using the above parameters.
    genGammaPDF=(p_ShapeParameter.*distribution_range.^(d_ShapeParameter-1).*exp(-(distribution_range./a_ScaleParameter).^p_ShapeParameter))./(a_ScaleParameter.^d_ShapeParameter.*gamma(d_ShapeParameter./p_ShapeParameter));
    genGammaCDF=cumsum(genGammaPDF)./100; %find the CDF
    
    for i=1:length(Ok8_ind)-max(max(separation)) %cycle through the indicators
        if Ok8_ind(i)==1 %if this is the start of an okta 8 period
            if i+Ok8_duration==numel(Ok8_ind);break; end %if its the end of the array, break the for loop, else errors.
            while Ok8_ind(i+Ok8_duration)~=2 %while the period of okta 8 continues
                Ok8_duration=Ok8_duration+1; %keep tally of the duration
                if i==numel(Ok8_ind); break; end %if its the end of the array, break the while
                if i+Ok8_duration==numel(Ok8_ind);break; end %if its the end of the array, break the while
            end
        end
        if Ok8_duration>=ok8_cutoff*temporal_res %if the duration is at least X hours or more.
            intervals=ceil(5*(Ok8_duration/temporal_res)*(rand+0.0001)); %random number of intervals
            els=ones(1+intervals,1); %make blank array of each hour plus the start hour
            for j=1:length(els) %loop through each hour in els.
                els(j)=ceil(Ok8_duration*((j-1)/intervals))+i; %find the element row reference to split the moment into sections
            end
            Ok8_kcvalues=zeros(size(els));
            for ii=1:length(els)
                Ok8_kcvalues(ii)=sum(genGammaCDF<rand)./100; %assign kc to each interval
            end
            xx=els(1):els(end);
            this_house_separation = ceil(mean(separation(els(1):els(end))));
            house_kcvalues(els(1)+this_house_separation:els(end)+this_house_separation) =interp1(els,Ok8_kcvalues,xx,'pchip');%piecewise cubic hermit interpolation technique between the kc values.
        end
        Ok8_duration=1; %reset the duration and loop again.
    end
    
    panel_tilt=house_info(house,5) ; %extract the individual location geography and geometry
    panel_orientation=house_info(house,4);
    panel_hasl=house_info(house,3);
    incident_angle=real(acosd(sind(zenith_angle).*sind(panel_tilt).*cosd(panel_orientation-azimuth)+cosd(zenith_angle).*cosd(panel_tilt))); % solar incident angle taking into account panel tilt and azimuth
    
    sun_obscured=house_coverages;%
    sun_obscured(sun_obscured>1)=1; %normalise the number of clouds covered by to create B 1DM
    kc_minutely= house_kcvalues;%temporary kc 1DM
    
    %%  for long periods of Okta 0. As for 8
    Ok0_ind=zeros(length(cloud_amount_1min_sim),1);
    for i=2:length(cloud_amount_1min_sim)-1
        if cloud_amount_1min_sim(i)==0 && cloud_amount_1min_sim(i+1)==0 && cloud_amount_1min_sim(i-1)~=0
            Ok0_ind(i)=1;
        end
        if cloud_amount_1min_sim(i)==0 && cloud_amount_1min_sim(i-1)==0 && cloud_amount_1min_sim(i+1)~=0
            Ok0_ind(i)=2;
        end
    end
    Ok0_duration=1;
    ok0_cutoff=3;
    intervals=1;
    for i=1:length(Ok0_ind)-1
        if Ok0_ind(i)==1 %if this is the start of an okta 0 period
            if i+Ok0_duration==numel(Ok0_ind);break; end
            while Ok0_ind(i+Ok0_duration)~=2 %while the period of okta 0 continues
                Ok0_duration=Ok0_duration+1; %keep tally of the duration
                if i==numel(Ok0_ind); break; end
                if i+Ok0_duration==numel(Ok0_ind);break; end
            end
        end
        if Ok0_duration>=ok0_cutoff*temporal_res
            %instead of a straight linear between the start and end period (very much not the case in real life), there are a fixed amount of intervals between kc values for the whole duration of okta 0.
            els=zeros(1+intervals,1);
            for j=2:length(els)
                els(j)=ceil(Ok0_duration*((j-1)/intervals));
            end
            
            kc_ok0=normrnd(1.02394,0.04,size(els));
            kc_ok0(kc_ok0>1.3)=normrnd(1,0.2,size(kc_ok0(kc_ok0>1.3)));
            kc_ok0(kc_ok0<0.9)=normrnd(1,0.2,size(kc_ok0(kc_ok0<0.9)));
            Ok0_kcvalues=kc_ok0;
            
            for j=1:length(els)-1
                intlinspace=linspace(Ok0_kcvalues(j),Ok0_kcvalues(j+1),els(j+1)-els(j)+1);
            end
        end
        Ok0_duration=1;
    end
    
    % populate kc minutely with the clear moments.
    kc_minutely(sun_obscured==0) = not_obscured_min(sun_obscured==0);
    %remove impossible extremes to the limit
    kc_minutely(kc_minutely<0.01)=normrnd(1.02394,0.04,1,numel(kc_minutely(kc_minutely<0.01)));
    
    %% Add irradiance peaks at moment of cloud shift, as observed in data. Increased reflected irradiance
    %     observed in observational data is a peak in irradiance just before and after a moment of cloud, this is due to increase reflected beam irradiance.
    %     to attempt to recreate this, fluxes based on a normrand distribution are applied to the minute before and after a cloud, limited to a chance  defined as:
    chance=0.30;% 30% of the time, this will be applied
    for i=3*(temporal_res/60):length(kc_minutely) %loop through kcMinutely
        chance_test=rand; % select a random value to test against the chance variable.
        
        %END OF CLOUD
        if sun_obscured(i-1)-sun_obscured(i)==1 % sun obscured is 0001111000 indicating cloud. if i-1 - i = 1. then i must be the end of a clouded period, and so...
            if temporal_res/60>1 %for 1 sec res
                increase =linspace(normrnd(1+0.05*chance_test,0.01,1),1,temporal_res/60);
                increase2=linspace(normrnd(1+0.025*chance_test,0.01,1),1,temporal_res/60);
            elseif temporal_res/60==1 %for 1 min res
                increase=normrnd(1+0.05*chance_test,0.01,1);
                increase2=normrnd(1+0.025*chance_test,0.01,1);
            end
            kc_minutely(i-temporal_res/60+1:i)=kc_minutely(i-(temporal_res/60)+1:i).*increase;%... apply a small increase in kc.
            kc_minutely(i-temporal_res/60+2:i)=kc_minutely(i-temporal_res/60+2:i)*increase2; %...apply a smaller increase to the kc value
            
            %START OF CLOUD for 1-sec resolution
        elseif sun_obscured(i-1)-sun_obscured(i)==-1 %else if i-1 - i=-1 (indicating that i start of a clouded period, and so i-1 is the last period before cloud
            if temporal_res/60>1 %for 1 sec
                increase =linspace(normrnd(1+0.05*chance_test,0.01,1),1,temporal_res/60);
                increase2=linspace(normrnd(1+0.025*chance_test,0.01,1),1,temporal_res/60);
            elseif temporal_res/60==1 % for1-min
                increase=normrnd(1+0.05*chance_test,0.01,1);% pick a single increase
                increase2=normrnd(1+0.025*chance_test,0.01,1);
            end
            kc_minutely(i-temporal_res/60:i)=kc_minutely(i-temporal_res/60:i)*increase; %apply CEE
            kc_minutely(i-temporal_res/60-1:i)=kc_minutely(i-temporal_res/60-1:i)*increase2; %apply CEE
        end
    end
    
    
    %% irradiance calculations following Muller and Trentman
    
    kc_minutely=kc_minutely';
    global_horizontal = kc_minutely .* global_horizontal_cs;
    direct_horizontal = zeros(numel(sun_obscured),1);
    direct_horizontal(kc_minutely < 1 & kc_minutely > 19/69) = direct_horizontal_cs(kc_minutely < 1 & kc_minutely > 19/69) .* (kc_minutely(kc_minutely < 1 & kc_minutely > 19/69) - 0.38*(1 - kc_minutely(kc_minutely < 1 & kc_minutely > 19/69))).^(2.5);
    direct_horizontal(kc_minutely>=1) = direct_horizontal_cs(kc_minutely>=1);
    direct_horizontal(direct_horizontal<0)=0;
    global_horizontal(global_horizontal<0)=0;
    diffuse_horizontal = global_horizontal - direct_horizontal;
    diffuse_to_global_ratio=diffuse_horizontal./global_horizontal;
    
    % Panel irradiance using Klucher model
    F=1-(diffuse_horizontal./global_horizontal).^2; % modulating factor
    isotropic=(1+cosd(panel_tilt))/2; % isotropic component - invariant to direct/global ratio
    horizonal=(1+F.*(sind(panel_tilt)/2).^3); % horizon brightening term
    circumsol = (1 + F .* (cosd(incident_angle)).^2 .* (sind(zenith_angle)).^3); % circumsolar diffuse irradiance
    panel_irradiance = diffuse_horizontal.*isotropic.*horizonal.*circumsol + direct_horizontal./cosd(zenith_angle).*cosd(incident_angle);
    
    %% Write the the outputs depending on the mode
    if write_mode == true
        csvwrite(['outputs',filesep,'Gt_house_',num2str(house),'.csv'],panel_irradiance) % Gt
        csvwrite(['outputs',filesep,'kc_house_',num2str(house),'.csv'],kc_minutely) % kc
    else
        house_panel_irradiance(:,house) = panel_irradiance;
        kc_minutely_all(:,house) = kc_minutely;
    end
end %repeat all of the above for each property

if write_mode == false
    csvwrite(['outputs',filesep,'Gt_all_houses',num2str(house),'.csv'],house_panel_irradiance) % Gt
    csvwrite(['outputs',filesep,'kc_all_houses',num2str(house),'.csv'],kc_minutely_all) % kc
end
