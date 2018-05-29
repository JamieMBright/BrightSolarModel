
%Start of the KC minutely code.
disp('Calculating minutely Kc values') %inform the user that the Kc calculations are being undertaken.
disp('   -extracting kc values from okta-based distributions');
disp('   -reanalysis of extended stable okta periods');
disp('   -determining cloud edge reflection chance');
disp('   -applying Kc values to baseline irradiance');

% Pick clearsky minutes from a normal distribution - one from each day (variation takes into account changes in atmospheric turbidity, etc)
% Select clear and cloudy properties for each day from appropriate distribution
% allow for structured fluctuations.
hours = length(time); %total number of hours
days = hours/24; %number of days
L=3600;
% season_hrly=weather_record(:,4); %hourly record of the season
obsc_min_lin=zeros(hours*60,1); %pre allocate memory
not_obscured = normrnd(0.99,0.08,days,1); % when the sky is not obscured, the kc value is taken from a normal distribution of mean 0.99 and std dev 0.08.
kc_residual=0.5;
xx=1:1:temporal_res*hours;
Y=1;
x=1;

for u_hour=1:length(wind_speed_sim)
    okta=cloud_amount_sim(u_hour);
    u_ref=wind_speed_sim(u_hour);
    resolution=round(L/(u_ref*temporal_res)); %must be a factor of 60  1,2,3,4,5,6,10,12,15,20,30
    switch resolution
        case {1,2,3,4,5,6}
        case {7,8}
            resolution=6;
        case {9,10,11}
            resolution=10;
        case {12,13}
            resoluion=12;
        case {14,15,16,17}
            resolution=15;
        case {18,19,20,21,22,23,24,25}
            resolution=20;
        case {26,27,28,29,30,31,32,33,34,35,36,37,38,39,40}
            resolution=20;
        case {41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60}
            resolution=20;
    end
    
    shift_factor=temporal_res/resolution; %used in indexing.
    obscured_factored=zeros(shift_factor+1,1); %pre allocate memory
    
    okta_factored=ones(shift_factor+1,1).*okta;
        
    % Pick cloud obscurity from the appropriate distribution
    obscured_factored(okta_factored<=6) = normrnd(0.6784, 0.2046, numel(okta_factored(okta_factored<=6)),1); %for okta of <=6, choose a kc from the normal distribution of mean 0.6784 and stddev 0.2046
    obscured_factored(okta_factored==7) = wblrnd(0.557736, 2.40609, numel(okta_factored(okta_factored==7)),1); %as above but for okta 7 and using weibul distribution
    obscured_factored(okta_factored>=8) = gamrnd(3.5624, 0.08668, numel(okta_factored(okta_factored>=8)),1); %as above but for okta 8 and using gamma distribution
   
    obscured_factored(1,1)=kc_residual;
   
    
    % Ensure sun_obscured hourly does not exceed 1
    while numel(obscured_factored(obscured_factored>1))>0 % limited obscured kc value to 1. if it is, re select from the okta 8 distribution.
        obscured_factored(obscured_factored>1)=gamrnd(3.5624, 0.08668, numel(obscured_factored(obscured_factored>1)), 1); %re select using okta 8 distribution
    end
    obscured_factored(obscured_factored<0.01)=0.01; %set a minimum.
    
    obscured_min_factored=zeros(60,1); %pre allocate memory
    
    x(length(x):length(x)+shift_factor-1)=u_hour*60-59:resolution:u_hour*60;
    Y(length(Y):length(Y)+shift_factor-1)=obscured_factored(1:shift_factor);
    
    
%     for i=1:length(obscured_factored)-1; %for every X mins in the simulation...
%         
%        intlinspace=linspace(obscured_factored(i),obscured_factored(i+1),resolution);%.*linspace(0.95,1.05,resolution); %a minutely resolution is the linear spaced minutely values from one kc to the next.
% %        int_cos=zeros(length((intlinspace)),1);
% %        indexing=1;
% %        
% %        if floor(i/2)/(i/2)==1
% %        a=pi();
% %        b=0;
% %        c=-1;
% %        else
% %        a=0;
% %        b=pi();
% %        c=1;
% %        end
% %        
% %        for j=a:pi()/(length(intlinspace)-1)*c:b%
% %        int_cos(indexing,1)=cos(j)/15+1 ; %apply a sinusoidal flux between the linspace
% %        indexing=indexing+1;
% %        end
%        obscured_min_factored(i*resolution-(resolution-1):i*resolution,1)=intlinspace;%.*int_cos';
% 
% 
%     end
%   obsc_min_lin(u_hour*temporal_res-(temporal_res-1):u_hour*temporal_res)=obscured_min_factored;        
%     
%     obscured_min(u_hour*temporal_res-(temporal_res-1):u_hour*temporal_res)=spline(x,obscured_factored(1:shift_factor),xx);%obscured_min_factored;
 kc_residual=Y(length(Y));

end



obscured_min=spline(x,Y,xx); %create a spline for the kc values

%calculate the linear profile of the kc values
y_lin=ones(min,1).*0.5; 
for i=1:length(x)-1
    x1=x(i);
    y1=x(i+1);
    
    a=Y(i);
    b=Y(i+1);
    n=y1-x1+1; %number of points required between both x values
    
    y_lin(x1:y1)=linspace(a,b,n);        
end

%find the difference between the spline and the linear (it is more than
%possible to be 300% error between the two. Linear is the preferred and
%more accurate method, spline offers much more realistic looking profiles,
%however has large propensity to fluctuate beyond 0-1 limits.
obscured_diff=abs(obscured_min-y_lin'); %find absolute difference
% obscured_diff=abs(y_lin'./obscured_min-1); %find the percentage difference 
obscured_min(obscured_diff>0.2)=y_lin(obscured_diff>0.2); %if the difference is greater than Xfraction, replace the spline with the linear (prevents too many extremes.


obscured_min(obscured_min<0.01)=y_lin(obscured_min<0.01); % if the kc value is below the lower limit, revert back to the linear profile. 

for i=1:length(obscured_min);
    if y_lin(i)>0.9 && obscured_diff(i)>0.05;
        obscured_min(i)=y_lin(i);
    end
end



% figure(5); plot(y_lin,'r');hold on;plot(obscured_min,'b');hold off


for i=1:length(wind_speed_sim)
    u_minutely(i*60-59:i*60)=wind_speed_sim(i); %create a vector containing 1minute resolution cloud speed values
end

    %For long periods of okta 0, apply a smoothing.
%     Period_of_Ok0=zeros(length(okta_minutely),1); %pre allocate memory
%     for i=2:length(okta_minutely)-1; %go through the okta minutely
%         if okta_minutely(i)==0 && okta_minutely(i+1)==0 && okta_minutely(i-1)~=0; %if this hour is the start of an okta 0 period...
%             Period_of_Ok0(i)=1; %.. indicate this with  a 1.
%         end
%         if okta_minutely(i)==0 && okta_minutely(i-1)==0 && okta_minutely(i+1)~=0; %if its the end of an okta 0 period...
%             Period_of_Ok0(i)=2; %...indicated with a 2
%         end
%         %now in format.. 00000100000002000000010002000000000100200000010000002 with a value for each minute
%     end
%     Ok0_duration=1; %this is the variable of the running tally of the clear sky duration
%     ok0_cutoff=3.5; %set the cutoff period in hours. and so if the period is >ok0_cutoff etc.
%     for i=1:length(Period_of_Ok0)-1 %loop through every minute
%         if Period_of_Ok0(i)==1 %if this is the start of an okta 0 period, as defined in previous loop.
%             if i+Ok0_duration==numel(Period_of_Ok0);break; end %if this is the end of the array, break the search. (important as will casue errors in indexing if this break is not here)
%             while Period_of_Ok0(i+Ok0_duration)~=2; %while the period of okta 0 is continuing...
%                 Ok0_duration=Ok0_duration+1; %...keep a running tally of the duration
%                 if i==numel(Period_of_Ok0); break; end %if its the end of the array, break the search
%                 if i+Ok0_duration==numel(Period_of_Ok0);break; end %if it is the end of the array, break the search.
%             end
%         end
%         if Ok0_duration>=ok0_cutoff*60; %if the duration is at least X hours or more...
%             obscured_min(i:i+Ok0_duration)= normrnd(1,0.0015,Ok0_duration+1,1);  %...adjust the hourly kc to go between the two linearly
%         end
%         Ok0_duration=1; %reset the duration tally variable
%     end
    
    %  for long periods of Ok8. REPEAT OF ABOVE, BUT FOR Okta 8.
%     Ok8_ind=zeros(length(okta_minutely),1);
%     for i=2:length(okta_minutely)-1;
%         if okta_minutely(i)==8 && okta_minutely(i+1)==8 && okta_minutely(i-1)~=8;        Ok8_ind(i)=1;    end
%         if okta_minutely(i)==8 && okta_minutely(i-1)==8 && okta_minutely(i+1)~=8;        Ok8_ind(i)=2;    end
%     end % place an indicator within Ok8_ind to mark the start and the end of an okta 8 period, will be in 00010000200 format now.
%     Ok8_duration=1; %reset the marker
%     ok8_cutoff=5; %set the okta 8 cutoff period
%     intervals=ok8_cutoff*4; %fix the number of intervals across any length of Ok8, at 4 times the number of hours, so 15 min intervals. For 5 hours, there would be 15 minute kc fluxes, for 10 hours the kc flux would be 30 mins.
%     for i=1:length(Ok8_ind)-1 %cycle through the indicators
%         if Ok8_ind(i)==1 %if this is the start of an okta 8 period
%             if i+Ok8_duration==numel(Ok8_ind);break; end %if its the end of the array, break the for loop, else errors.
%             while Ok8_ind(i+Ok8_duration)~=2; %while the period of okta 8 continues
%                 Ok8_duration=Ok8_duration+1; %keep tally of the duration
%                 if i==numel(Ok8_ind); break; end %if its the end of the array, break the while
%                 if i+Ok8_duration==numel(Ok8_ind);break; end %if its the end of the array, break the while
%             end
%         end
%         if Ok8_duration>=ok8_cutoff*temporal_res; %if the duration is at least X hours or more.
%             %instead of a straight linear between the start and end period (very much not the case in real life), there are a fixed amount of intervals between kc values for the whole duration of okta 8.
%             %for example. there are 20 intervals irregardless of duration.
%             els=zeros(1+intervals,1); %make blank array of each hour plus the start hour
%             for j=2:length(els); %loop through each hour in els.
%                 els(j)=ceil(Ok8_duration*((j-1)/intervals)); %find the element row reference to split the moment into sections (e.g.  to split 1 hour into 4 would be 1:15, 16:30, 31:45, 46:60)
%             end
%             
%             
%             for j=1:length(els)-1;
%                intlinspace=linspace(obscured_min(i+els(j)),obscured_min(i+els(j))*normrnd(1,0.1),els(j+1)-els(j)+1);
%                 int_cos=zeros(1,length(intlinspace));
%                 indexing=1;
%                if floor(j/2)/(j/2)==1
%                     a=pi();
%                     b=0;
%                     c=-1;
%                 else
%                     a=0;
%                     b=pi();
%                     c=1;
%                 end
%                 
%                 for k=a:pi()/(length(intlinspace)-1)*c:b%
%                     int_cos(1,indexing)=cos(k)/15+1 ; %apply a sinusoidal flux between the linspace
%                     indexing=indexing+1;
%                 end
%                           
%                 
%                 obscured_min(i+els(j):i+els(j+1))=intlinspace.*int_cos; %update the kcminutely in the appropraite place with linearly spaced kc values with small flux.
%             end
%             
%             %fluctuations are to become a function of the cloud speed. As we are assuming clouds are ~spherical in build, their thicknesses are assumed to oscillate appropriately
%             u_ok8duration=u_minutely(i:i+Ok8_duration-1)/1000;
%             
% %             fluxes=roundn(rand(intervals,1),-1); %fluxes is a series of random values for the random fluxes during clouded periods (similar to the gausian noise multiplier, however is less erratic, more smoothed like in real data)
%             
%             gap=ceil(Ok8_duration/intervals); %determine the length of each gap between kc values (currently a zig zag of straight linearly spaced values)
%             flux_min=zeros(Ok8_duration,1); %pre allocate memory
% %             for k=1:length(fluxes); %loop through the length of fluxes
% %                 flux_min(k*gap-(gap-1):k*gap,1)=fluxes(k,1); %produce a minutely resolution array of fluxes, called flux min. with "interval" sized constants of each random value of fluxes.
% %             end
%             
%             for k=1:length(flux_min); %apply increasing erratic fluxes based on the random value in fluxes
% %                 if flux_min(k,1)<0.4 %if the random value assigned is <0.4....
% %                     flux_min(k,2)=1+abs(normrnd(0,0.005)); %apply fluxes with a tiny std dev. (and so 40% of the time, a small flux is seen). This is abs to add a curved nature to the deviations
% %                 elseif flux_min(k,1)<0.7 % else if it is less than 0.7
% %                     flux_min(k,2)=1+abs(normrnd(0,0.03)); %and so 30% of the time, a std dev of 0.03 is used.
% %                 else flux_min(k,2)=1+abs(normrnd(0,0.05));% else the other 30% of the time a std dev of 0.05 is used. So for each gap, white noise is applied during long overcast periods.
% %                 end
%                 flux_min(k,2)=1+abs(normrnd(0,u_ok8duration(k)));
%             end
%             
%             obscured_min(i:i+Ok8_duration-1)=obscured_min(i:i+Ok8_duration-1).*flux_min(:,2)';% implement the random fluctuations to thekcMinutely code
%             
%         end
%         Ok8_duration=1; %reset the duration and loop again.
%     end
%     
