%% Start of the KC minutely code.
disp('Probabilistically deriving clear-sky irradiance using SIG method') %inform the user that the Kc calculations are being undertaken.

kcMinutely=zeros(numel(sun_obscurred_sim),1); %pre allocate space
resolution=6; %must be a factor of 60  1,2,3,4,5,6,10,12,15,20,30,60. Discussed in paper, This could be improved by allowing a flexible feature to this. This allows fluxes every 6 mins.
shift_factor=t_res/resolution; %num of intervals
obscured_factored=zeros(length(time)*shift_factor,1); %pre allocate memory
okta_factored=zeros(length(time)*shift_factor,1); %pre allocate memory
for i=1:length(cloud_amount_sim) % loop through each hour
    okta_factored(i*shift_factor-(shift_factor-1):i*shift_factor)=cloud_amount_sim(i);    %okta factored is the okta value every 6 mins.
end

obscured_min=zeros(length(time)*t_res,1); %pre allocate memory
not_obscured_min=zeros(length(time)*t_res,1); %pre allocate memory

% Pick cloud obscurity from the appropriate distribution
obscured_factored(okta_factored<=6) = normrnd(0.6784, 0.2046, numel(okta_factored(okta_factored<=6)),1); %for okta of <=6, choose a kc from the normal distribution of mean 0.6784 and stddev 0.2046
obscured_factored(okta_factored==7) = wblrnd(0.557736, 2.40609, numel(okta_factored(okta_factored==7)),1); %as above but for okta 7 and using weibul distribution
obscured_factored(okta_factored>=8) = gamrnd(3.5624, 0.08668, numel(okta_factored(okta_factored>=8)),1); %as above but for okta 8 and using gamma distribution
disp('   -extracting kc values from okta-based distributions');
% Ensure sun_obscurred_sim hourly does not exceed 1
while numel(obscured_factored(obscured_factored>1))>0 % limited obscured kc value to 1. if it is, re select from the okta 8 distribution.
    obscured_factored(obscured_factored>1)=gamrnd(3.5624, 0.08668, numel(obscured_factored(obscured_factored>1)), 1); %re select using okta 8 distribution
end

for i=1:length(obscured_factored)-1 %for every 6 mins in the simulation...
    obscured_min(i*resolution-(resolution-1):i*resolution)=linspace(obscured_factored(i),obscured_factored(i+1),resolution); %a minutely resolution is the linear spaced minutely values from one kc to the next.
end

% Pick clearsky minutes from a normal distribution - one from each day (variation takes into account changes in atmospheric turbidity, etc)
not_obscured = normrnd(0.99,0.08,num_of_days,1); % when the sky is not obscured, the kc value is taken from a normal distribution of mean 0.99 and std dev 0.08.

% Populate minutely kc value with appropriate value. Kc minutely is a vector containing every minute's kc value which will be used to calculate the panel irradiance.
kcMinutely(sun_obscurred_sim==1) = obscured_min(sun_obscurred_sim==1); %when the sun is obscured, apply the kc values from the obscured periods.
kcMinutely(sun_obscurred_sim==0) = not_obscured_min(sun_obscurred_sim==0); %when the sun is not obscured, apply the kc values for clear sky.
kcMinutely(sun_obscurred_sim==0) = not_obscured(ceil(find(sun_obscurred_sim==0)/1440));

kcMinutely(sun_obscurred_sim==1) = kcMinutely(sun_obscurred_sim==1) .* normrnd(1, 0.01+0.003*cloud_amount_1min_sim(sun_obscurred_sim==1)'); %apply a gaussian white noise multiplier based on the hourly okta for both clear and cloudy moments
kcMinutely(sun_obscurred_sim==0) = kcMinutely(sun_obscurred_sim==0) .* normrnd(1, 0.001+0.0015*cloud_amount_1min_sim(sun_obscurred_sim==0)'); % see eq 12 and 13 in the paper.

% %For long periods of okta 0, apply a smoothing.
% disp('   -reanalysis of extended stable okta periods');
% Period_of_Ok0=zeros(length(okta_minutely),1); %pre allocate memory
% for i=2:length(okta_minutely)-1 %go through the okta minutely
%     if okta_minutely(i)==0 && okta_minutely(i+1)==0 && okta_minutely(i-1)~=0 %if this hour is the start of an okta 0 period...
%         Period_of_Ok0(i)=1; %.. indicate this with  a 1.
%     end
%     if okta_minutely(i)==0 && okta_minutely(i-1)==0 && okta_minutely(i+1)~=0 %if its the end of an okta 0 period...
%         Period_of_Ok0(i)=2; %...indicated with a 2
%     end
%     %now in format.. 00000100000002000000010002000000000100200000010000002 with a value for each minute
% end
% Ok0_duration=1; %this is the variable of the running tally of the clear sky duration
% ok0_cutoff=3.5; %set the cutoff period in hours. and so if the period is >ok0_cutoff etc.
% for i=1:length(Period_of_Ok0)-1 %loop through every minute
%     if Period_of_Ok0(i)==1 %if this is the start of an okta 0 period, as defined in previous loop.
%         if i+Ok0_duration==numel(Period_of_Ok0);break; end %if this is the end of the array, break the search. (important as will casue errors in indexing if this break is not here)
%         while Period_of_Ok0(i+Ok0_duration)~=2 %while the period of okta 0 is continuing...
%             Ok0_duration=Ok0_duration+1; %...keep a running tally of the duration
%             if i==numel(Period_of_Ok0); break; end %if its the end of the array, break the search
%             if i+Ok0_duration==numel(Period_of_Ok0);break; end %if it is the end of the array, break the search.
%         end
%     end
%     if Ok0_duration>=ok0_cutoff*t_res %if the duration is at least X hours or more...
%         kcMinutely(i:i+Ok0_duration)= normrnd(1,0.0015,Ok0_duration+1,1);  %...adjust the hourly kc to go between the two linearly
%     end
%     Ok0_duration=1; %reset the duration tally variable
% end
% 
% %  for long periods of Ok8. REPEAT OF ABOVE, BUT FOR Okta 8.
% Ok8_ind=zeros(length(okta_minutely),1);
% for i=2:length(okta_minutely)-1
%     if okta_minutely(i)==8 && okta_minutely(i+1)==8 && okta_minutely(i-1)~=8;        Ok8_ind(i)=1;    end
%     if okta_minutely(i)==8 && okta_minutely(i-1)==8 && okta_minutely(i+1)~=8;        Ok8_ind(i)=2;    end
% end
% Ok8_duration=1;
% ok8_cutoff=5; %the okta 8 cutoff period
% intervals=ok8_cutoff*4; %20 intervals across any length of Ok8. For 5 hours, there would be 15 minute kc fluxes, for 10 hours the kc flux would be 30 mins.
% for i=1:length(Ok8_ind)-1
%     if Ok8_ind(i)==1 %if this is the start of an okta 8 period
%         if i+Ok8_duration==numel(Ok8_ind);break; end %if its the end of the array, break the for loop
%         while Ok8_ind(i+Ok8_duration)~=2 %while the period of okta 8 continues
%             Ok8_duration=Ok8_duration+1; %keep tally of the duration
%             if i==numel(Ok8_ind); break; end %if its the end of the array, break the while
%             if i+Ok8_duration==numel(Ok8_ind);break; end %if its the end of the array, break the while
%         end
%     end
%     if Ok8_duration>=ok8_cutoff*t_res %if the duration is at least X hours or more.
%         %instead of a straight linear between the start and end period (very much not the case in real life), there are a fixed amount of intervals between kc values for the whole duration of okta 8.
%         %for example. there are 20 intervals irregardless of duration.
%         els=zeros(1+intervals,1); %make blank array of each hour plus the start hour
%         for j=2:length(els) %loop through each hour in els.
%             els(j)=ceil(Ok8_duration*((j-1)/intervals)); %find the element row reference to split the moment into sections (e.g.  to split 1 hour into 4 would be 1:15, 16:30, 31:45, 46:60)
%         end
%         for j=1:length(els)-1
%             kcMinutely(i+els(j):i+els(j+1))=linspace(kcMinutely(i+els(j)),kcMinutely(i+els(j))*normrnd(1,0.1),els(j+1)-els(j)+1); %update the kcminutely in the appropraite place with linearly spaced kc values with small flux.
%         end
%         fluxes=roundn(rand(intervals,1),-1); %fluxes is a series of random values for the random fluxes during clouded periods (similar to the gausian noise multiplier, however is less erratic, more smoothed like in real data)
%         gap=ceil(Ok8_duration/intervals); %determine the length of each gap between kc values (currently a zig zag of straight linearly spaced values)
%         flux_min=zeros(length(Ok8_duration),1); %pre allocate memory
%         for k=1:length(fluxes) %loop through the lengh of fluxes
%             flux_min(k*gap-(gap-1):k*gap,1)=fluxes(k,1); %produce a minutely resolution array of fluxes, called flux min. with "interval" sized constants of each random value of fluxes.
%         end
%         for k=1:length(flux_min) %apply increasing erratic fluxes based on the random value in fluxes
%             if flux_min(k,1)<0.4 %if the random value assigned is <0.4....
%                 flux_min(k,2)=1+abs(normrnd(0,0.005)); %apply fluxes with a tiny std dev. (and so 40% of the time, a small flux is seen). This is abs to add a curved nature to the deviations
%             elseif flux_min(k,1)<0.7 % else if it is less than 0.7
%                 flux_min(k,2)=1+abs(normrnd(0,0.03)); %and so 30% of the time, a std dev of 0.03 is used.
%             else
%                 flux_min(k,2)=1+abs(normrnd(0,0.05));% else the other 30% of the time a std dev of 0.05 is used. So for each gap, white noise is applied during long overcast periods.
%             end
%         end
%         
%         kcMinutely(i:i+Ok8_duration)=kcMinutely(i:i+Ok8_duration).*flux_min(:,2);% implement the random fluctuations to thekcMinutely code
%         
%     end
%     Ok8_duration=1; %reset the duration and loop again.
% end

%Clear sky index - limit maximum by zenith angle according to curve fit by maxes.m
for i=1:length(kcMinutely) %check each kc value in turn
    kcmax = 27.21*exp(-114*cosd(zenith_angle(i))) + 1.665*exp(-4.494*cosd(zenith_angle(i))) + 1.08; %detemine the theoretical maximum kc value based on the zenith
    if kcMinutely(i)>kcmax % if the current kc value is greater than it's maximum
        kcMinutely(i)=wblrnd(0.3, 1.7);    % re assign the value (randomly) within limits.
    end
    if kcMinutely(i)<0.01 % if the value is too small,
        kcMinutely(i)=0.01; % set it at the minimum. This prevents impossible kc values.
    end
end

disp('Applying cloud edge enhancement events');
%Add irradiance peaks at moment of cloud shift, as observed in data. Increased reflected irradiance
%observed in observational data is a peak in irradiance just before and after a moment of cloud, this is due to increase reflected beam irradiance.
% to attempt to recreate this, fluxes based on a normrand distribution are applied to the minute before and after a cloud, limited to a chance  defined as:
chance=0.40;% 40% of the time, this will be applied
for i=3:length(kcMinutely)
    a=rand; % select a random value to test against the chance variable.
    if sun_obscurred_sim(i-1)-sun_obscurred_sim(i)==1 % sun obscured is 0001111000 indicating cloud. if i-1 - i = 1. then i must be the end of a clouded period, and so...
        if a>chance %if the random variable, a, is grater than the chance variable then...
            kcMinutely(i)=kcMinutely(i)*normrnd(1.05,0.01,1);%... apply a small increase in kc.
        end
    elseif sun_obscurred_sim(i-1)-sun_obscurred_sim(i)==-1 %else if i-1 - i=-1 (indicating the start of a clouded period, and so...
        if a>chance % if the chance is satisfied
            kcMinutely(i-1)=kcMinutely(i-1)*normrnd(1.05,0.01,1); %a pply a gentle increase in the kc value.
        end
    end
    % this does look less gradual, so the minute before leads up to the cloud every time also.
    if sun_obscurred_sim(i-2)-sun_obscurred_sim(i-1)==1 %if the minute is just after the minute after the cloud..
        if a>chance%...is satisfied within the chance....
            kcMinutely(i)=kcMinutely(i)*normrnd(1.025,0.01,1); %...apply a smaller increase to the kc value
        end
    elseif sun_obscurred_sim(i-2)-sun_obscurred_sim(i-1)==-1 %else if the minute is just before the minute before the cloud...
        if a>chance % ... and the chance is satisfied...
            kcMinutely(i)=kcMinutely(i)*normrnd(1.025,0.01,1); %... apply a smaller increase in kc value.
        end
    end % the result is rather asthetic and compares wonderfully to real data in terms of visuals.
end
%%% END OF KCMINUTELY CODE