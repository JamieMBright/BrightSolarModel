
house_panel_irradiance=zeros(numel(house_coverages(1,:)),number_of_houses);

for house = 1:number_of_houses
    
    disp(['              ...for house: ',num2str(house)])
    panel_tilt=house_info(house,5) ;
    panel_orientation=house_info(house,4);
    panel_hasl=house_info(house,3);
    
    incident_angle=real(acosd(sind(zenith_angle).*sind(panel_tilt).*cosd(panel_orientation-azimuth)+cosd(zenith_angle).*cosd(panel_tilt))); % solar incident angle taking into account panel tilt and azimuth
    
    sun_obscured=house_coverages(house,:);
    sun_obscured(sun_obscured>1)=1;
    num_of_clouds_obscured_by=house_coverages(house,:);
    num_of_clouds_obscured_by(num_of_clouds_obscured_by==1)=0;
    num_of_clouds_obscured_by(num_of_clouds_obscured_by>1)=num_of_clouds_obscured_by(num_of_clouds_obscured_by>=1)./50;
       
    kcMinutely=zeros(numel(sun_obscured),1); %pre allocate space
    not_obscured_min=zeros(hours*60,1); %pre allocate memory
 
    % Populate minutely kc value with appropriate value. Kc minutely is a vector containing every minute's kc value which will be used to calculate the panel irradiance.
    kcMinutely(sun_obscured==1) = obscured_min(sun_obscured==1); %when the sun is obscured, apply the kc values from the obscured periods.
    kcMinutely(sun_obscured==0) = not_obscured_min(sun_obscured==0); %when the sun is not obscured, apply the kc values for clear sky.
    kcMinutely(sun_obscured==0) = not_obscured(ceil(find(sun_obscured==0)/1440));
    
    kcMinutely(sun_obscured==1) = kcMinutely(sun_obscured==1) .* normrnd(1, 0.01+0.03*coverage_1min_sim(sun_obscured==1)'); %apply a gaussian white noise multiplier based on the hourly okta for both clear and cloudy moments
    kcMinutely(sun_obscured==0) = kcMinutely(sun_obscured==0) .* normrnd(1, 0.001+0.0015*coverage_1min_sim(sun_obscured==0)'); % see eq 12 and 13 in the paper.
%     
    kcMinutely=kcMinutely-num_of_clouds_obscured_by';
    

    %Clear sky index - limit maximum by zenith angle according to curve fit by maxes.m
    for i=1:length(kcMinutely); %check each kc value in turn
        kcmax = 27.21*exp(-114*cosd(zenith_angle(i))) + 1.665*exp(-4.494*cosd(zenith_angle(i))) + 1.08; %detemine the theoretical maximum kc value based on the zenith
        if kcMinutely(i)>kcmax % if the current kc value is greater than it's maximum
            kcMinutely(i)=wblrnd(0.3, 1.7);    % re assign the value (randomly) within limits.
        end
        if kcMinutely(i)<0.01; % if the value is too small,
            kcMinutely(i)=0.01; % set it at the minimum. This prevents impossible kc values.
        end
    end
    
    %Add irradiance peaks at moment of cloud shift, as observed in data. Increased reflected irradiance
    %observed in observational data is a peak in irradiance just before and after a moment of cloud, this is due to increase reflected beam irradiance.
    % to attempt to recreate this, fluxes based on a normrand distribution are applied to the minute before and after a cloud, limited to a chance  defined as:
    chance=0.30;% 30% of the time, this will be applied
    for i=3:length(kcMinutely);
        a=rand; % select a random value to test against the chance variable.
        if sun_obscured(i-1)-sun_obscured(i)==1; % sun obscured is 0001111000 indicating cloud. if i-1 - i = 1. then i must be the end of a clouded period, and so...
            if a>chance; %if the random variable, a, is grater than the chance variable then...
                kcMinutely(i)=kcMinutely(i)*normrnd(1.05,0.01,1);%... apply a small increase in kc.
            end
        elseif sun_obscured(i-1)-sun_obscured(i)==-1; %else if i-1 - i=-1 (indicating the start of a clouded period, and so...
            if a>chance % if the chance is satisfied
                kcMinutely(i-1)=kcMinutely(i-1)*normrnd(1.05,0.01,1); %a pply a gentle increase in the kc value.
            end
        end
        % this does look less gradual, so the minute before leads up to the cloud every time also.
        if sun_obscured(i-2)-sun_obscured(i-1)==1; %if the minute is just after the minute after the cloud..
            if a>chance;...is satisfied within the chance....
                    kcMinutely(i)=kcMinutely(i)*normrnd(1.025,0.01,1); %...apply a smaller increase to the kc value
            end
        elseif sun_obscured(i-2)-sun_obscured(i-1)==-1; %else if the minute is just before the minute before the cloud...
            if a>chance; % ... and the chance is satisfied...
                kcMinutely(i)=kcMinutely(i)*normrnd(1.025,0.01,1); %... apply a smaller increase in kc value.
            end
        end % the result is rather asthetic and compares wonderfully to real data in terms of visuals.
    end
    
    %%% END OF KCMINUTELY CODE
    
    
    % Introduce cloud adjustment with kcMinutely. Beam irradiance relation due
    % to Mueller and Trentmann (2010): Algorithm Theoretical Baseline Document
    % Direct Irradiance at Surface CM-SAF Product CM-104
    global_horizontal = kcMinutely .* global_horizontal_cs;
    direct_horizontal = zeros(numel(sun_obscured),1);
    direct_horizontal(kcMinutely < 1 & kcMinutely > 19/69) = direct_horizontal_cs(kcMinutely < 1 & kcMinutely > 19/69) .* (kcMinutely(kcMinutely < 1 & kcMinutely > 19/69) - 0.38*(1 - kcMinutely(kcMinutely < 1 & kcMinutely > 19/69))).^(2.5);
    direct_horizontal(kcMinutely>=1) = direct_horizontal_cs(kcMinutely>=1);
    direct_horizontal(direct_horizontal<0)=0;
    global_horizontal(global_horizontal<0)=0;
    diffuse_horizontal = global_horizontal - direct_horizontal;
    diffuse_to_global_ratio=diffuse_horizontal./global_horizontal;
    
    % Panel irradiance - using Klucher model -calculate on any arbitrary plane
    % from diffuse, hz and ghz and angles.
    F=1-(diffuse_horizontal./global_horizontal).^2; % modulating factor
    isotropic=(1+cosd(panel_pitch_hrz))/2; % isotropic component - invariant to direct/global ratio
    horizonal=(1+F.*(sind(panel_pitch_hrz)/2).^3); % horizon brightening term
    circumsol = (1 + F .* (cosd(incident_angle)).^2 .* (sind(zenith_angle)).^3); % circumsolar diffuse irradiance
    panel_irradiance = diffuse_horizontal.*isotropic.*horizonal.*circumsol + direct_horizontal./cosd(zenith_angle).*cosd(incident_angle);
    
    % take account of night
    panel_irradiance = (panel_irradiance > 0).*panel_irradiance;
    
    house_panel_irradiance(:,house)=panel_irradiance;
    
end