% +-----------------------------------------------------------------------+
% |                    Hourly Cloud Cover Generator                       | 
% +-----------------------------------------------------------------------+
% | Creator: Jamie Bright 21/02/2014                                      |
% +-----------------------------------------------------------------------+
% | This script produces an array containing a multitiude of possibilities|
% | that an hour can take in terms of cloudiness. The array is 60 elements|
% | across, each representing an hour in minutes. The number of options is|
% | defined by the range of windspeeds, coverages and options of each     |
% | desired.                                                              |
% |                                                                       |
% | The script produces a single sample of (preferably) a large length and|
% | is populated using research carried out by Wood & Field, 2011, that   |
% | states that the horizontal cloud length is well represented using a   |
% | single power law relationship. The sample is a digital signal of ones |
% | and zeros representing cloudy or not cloudy. The sample is then       |
% | altered at a rate proportionate to the windspeed so that the distances| 
% | are now represented as a time (assuming that the clouds travel at the |
% | windspeed).                                                           |
% |                                                                       |
% | An hour is taken at random from the resampled vector and tested to    |
% | see what the coverage value ,n, is (n/10). The hour is then placed in |
% | appropriate bins according to the coverage value. Hours will be       |
% | contiunously taken until x number of options per windspeed per        |
% | coverage has been satisfied.                                          |
% |                                                                       |
% | The plots shown at the end show the probability of there being cloud  |
% | at each of the coverage bins. A coverage of 7/10 should offer a 0.7   |
% | chance of there being cloud at any minute. The overall probability    |
% | across allcoverage values 1:9 should be 0.5.                          |
% |                                                                       |
% | The ouput is used in a stochastic weather generator to produce        |
% | minutely resolution irradiance data from readily available hourly     |
% | averages.                                                             |
% +-----------------------------------------------------------------------+
% |                                      | X  = cloud length (decameters) |
% |  X = (Alpha + Beta*r) ^ (1/1-B)      | r  = random variable (0 to 1)  |
% |  Alpha = X1 ^ (1-B)                  | X1 = max cloud length          |
% |  Beta = X0 ^ (1-B)  - Alpha          | X0 = min cloud length          |
% |  B = 1.66                            | B  = exponent (by Wood & Field)|
% +-----------------------------------------------------------------------+ 
clear all
tic

% Change default axes fonts.
set(0,'DefaultAxesFontName', 'Times New Roman')
set(0,'DefaultAxesFontSize', 14)

% Change default text fonts.
set(0,'DefaultTextFontname', 'Times New Roman')
set(0,'DefaultTextFontSize', 14)

%% Variables
%VARIABLES TO SET
sample_length=2*10^8; % (decameters). ~3 mins at 10^8 Warning! high memory use beyond this.
num_of_options=1000;%number of sample hours per wind speed per coverage  (Timings: 10^7,100=17s. 10^7,1000=32s. 2*10^7,100=31s. 2*10 

%Other Start Variables
u_range=60;%all possible wind speeds (m/s). Met office highest measurement is 50knots up to 2500km highest cloud measurement ~60m/s
coverage_range=9;% coverages (1:9)/10. 0/10 and 10/10 are both all zeros or ones.
cloud_sample=zeros(1,sample_length); %pre-allocate memory. construct array of variable length
combined_record=zeros(sample_length,1); 
current_point_marker=1; %keep track of where in the sample the cloud starts
B=1.66; % Power Law Exponent /// p(x)=Cx^-B ///  (Wood & Field, 2011, Journal of Climate, Volume 24, p4800). 
x_min=10;%minimum cloud length (decameters). Power law applicible to 0.1-1500km (Wood & Field,2011)
x_max=150000;%maximum cloud length (decameters). (decameters selected as 10m=1 element resolution within vector)
alpha=x_max^(1-B); %to set power law {p(x)=Cx^-B} between limits and select random value...
beta=x_min^(1-B) - alpha; % powerlaw becomes x=(alpha+beta*rand)^(1/(1-B)). rand==0 gives x_max. rand==1 gives x_min.

%% Produce Sample
disp(['Producing Sample',1]);
%produce sample vector to pre-set sample length
while current_point_marker<length(cloud_sample); %run sample to the end.
    cloud_rand=rand; %produce randome value for use in power law
    cloud_length=floor((alpha+beta*cloud_rand)^(1/(1-B))); %apply single power law to produce a cloud length
    combined_record(current_point_marker,1)=cloud_length; % keep a log of the length for later plots (to prove power law)
    if cloud_length+current_point_marker>length(cloud_sample);cloud_length=length(cloud_sample)-current_point_marker;end % if the cloud length goes beyond vector length, limit it.
    cloud_sample(1,current_point_marker:current_point_marker+cloud_length)=1; %put the cloud in the array at the correct point
    current_point_marker=current_point_marker+cloud_length; % update the current point along the sample
    
    clear_rand=rand; %REPEAT the above process for a period of clear sky. Clear sky follows the same power law.
    clear_length=floor((alpha+beta*clear_rand)^(1/(1-B)));
    combined_record(current_point_marker,1)=clear_length;
    if clear_length+current_point_marker>length(cloud_sample);clear_length=length(cloud_sample)-current_point_marker;end
    cloud_sample(1,current_point_marker:current_point_marker+clear_length)=0;
    current_point_marker=current_point_marker+clear_length;
end

combined_record=tabulate(combined_record);%create frequency and probability stats using tabulate function
% num_of_clouds=sum(combined_record(2:length(combined_record),2))/2; %find the number of clouds produced over the sample range. (row 1=0 and is not a cloud, ignored)
% disp([num2str(num_of_clouds),' Clouds Produced']); %Display the number of clouds produced, needs to be very high to achieve a good accuracy

%% Reshape, Randomly Sample, Allocate 
% %make coverage arrays
% coverage_bin_1=zeros(num_of_options*u_range,60); % pre allocate space, size changes based on user pre-set variables
% coverage_bin_2=zeros(num_of_options*u_range,60); % each row is a separate hour that represents (1:9)/10 
% coverage_bin_3=zeros(num_of_options*u_range,60); % each column (1:60) is a minute of the hour
% coverage_bin_4=zeros(num_of_options*u_range,60);coverage_bin_5=zeros(num_of_options*u_range,60);coverage_bin_6=zeros(num_of_options*u_range,60);coverage_bin_7=zeros(num_of_options*u_range,60);coverage_bin_8=zeros(num_of_options*u_range,60);coverage_bin_9=zeros(num_of_options*u_range,60);
% disp(['Allocating Hours by Coverage and Windspeed ',1]);
% for u=1:u_range %cycle through all the different windspeeds
%     epm=u/(1/6);% epm = number of elements per minute. This is the resample rate to convert the cloud_sample (distance) into 1element=1minute according to the wind speed. 
%     cloud_resampled=resample(cloud_sample,1,epm); % resample(data,P,Q) resamples data such that the data is interpolated by a factor P(1) and then decimated by a factor Q(epm)
%     cloud_resampled(cloud_resampled<0.5)=0;%resampling casues lots of noise, to maintain perfect 0||1 values, round about 0.5
%     cloud_resampled(cloud_resampled>=0.5)=1;%rounding from 0.5 maintains the original sample's 0:1 split.
%     
%     entry_count=zeros(1,9); %pre allocate. This array is to keep a log of all the times the random hour represents each coverage
%     tally=zeros(1,9); %pre allocate. This array is to ensure only the num_of_options amount of sample hours is produced.
%     
%     while 1==1; %infinite loop, breaks when satisfied (if statement;break;end) (when all coverages and wind speeds have num_of_options amount of options)
%         r=rand*(1-(61/length(cloud_resampled))); % r limited to not be final 60 mins)
%         
%         sample_hour=cloud_resampled(ceil(r*length(cloud_resampled)):59+ceil(r*length(cloud_resampled)));
%         coverage=round(sum(sample_hour)/6);
%         switch coverage
%             case {0,10} %skip if 0 or 10
%             case 1
%                 entry_count(1,1)=entry_count(1,1)+1; %keep tally of entries into each case
%                 if entry_count(1,1)<=num_of_options; %if there arent enough case options yet, carry on 
%                     tally(1,1)=tally(1,1)+1; %keep a tally of options made (for exit and indexing)
%                     coverage_bin_1(u*num_of_options-(num_of_options-tally(1,1)),:)=sample_hour;%fill the array with sampled hour
%                 end
%             case 2
%                 entry_count(1,2)=entry_count(1,2)+1;
%                 if entry_count(1,2)<=num_of_options;tally(1,2)=tally(1,2)+1;coverage_bin_2(u*num_of_options-(num_of_options-tally(1,2)),:)=sample_hour;end;
%             case 3
%                 entry_count(1,3)=entry_count(1,3)+1;
%                 if entry_count(1,3)<=num_of_options;tally(1,3)=tally(1,3)+1;coverage_bin_3(u*num_of_options-(num_of_options-tally(1,3)),:)=sample_hour;end;
%             case 4
%                 entry_count(1,4)=entry_count(1,4)+1;
%                 if entry_count(1,4)<=num_of_options;tally(1,4)=tally(1,4)+1;coverage_bin_4(u*num_of_options-(num_of_options-tally(1,4)),:)=sample_hour;end;
%             case 5
%                 entry_count(1,5)=entry_count(1,5)+1;
%                 if entry_count(1,5)<=num_of_options;tally(1,5)=tally(1,5)+1;coverage_bin_5(u*num_of_options-(num_of_options-tally(1,5)),:)=sample_hour;end;
%             case 6
%                 entry_count(1,6)=entry_count(1,6)+1;
%                 if entry_count(1,6)<=num_of_options;tally(1,6)=tally(1,6)+1;coverage_bin_6(u*num_of_options-(num_of_options-tally(1,6)),:)=sample_hour;end;
%             case 7
%                 entry_count(1,7)=entry_count(1,7)+1;
%                 if entry_count(1,7)<=num_of_options;tally(1,7)=tally(1,7)+1;coverage_bin_7(u*num_of_options-(num_of_options-tally(1,7)),:)=sample_hour;end;
%             case 8
%                 entry_count(1,8)=entry_count(1,8)+1;
%                 if entry_count(1,8)<=num_of_options;tally(1,8)=tally(1,8)+1;coverage_bin_8(u*num_of_options-(num_of_options-tally(1,8)),:)=sample_hour;end;
%             case 9
%                 entry_count(1,9)=entry_count(1,9)+1;
%                 if entry_count(1,9)<=num_of_options;tally(1,9)=tally(1,9)+1;coverage_bin_9(u*num_of_options-(num_of_options-tally(1,9)),:)=sample_hour;end;
%         end
%         
%         if sum(tally)==(num_of_options*coverage_range);break;end %exit infinte loop once all coverages are full
%     end
% end
% 
% sun_obscured=[coverage_bin_1;coverage_bin_2;coverage_bin_3;coverage_bin_4;coverage_bin_5;coverage_bin_6;coverage_bin_7;coverage_bin_8;coverage_bin_9]; %for useable format in weather generator 
% %csvwrite('sun_obscured_options_generic_updated.csv',sun_obscured); %write to file (when required)
% 
% hourly_mean_by_coverage=zeros(coverage_range,60); %pre allocate memory. Used to show the hourly development of cloud for each coverage.
% hourly_mean_all=zeros(1,60);%pre allocate maemory. used to show the hourly development of cloud across all coverages (should be 50%)
% % each minute is 1||0. should be ~coverage/10.  
% for i=1:60; %cycle through the minutes of the hour
%     hourly_mean_by_coverage(1,i)=sum(sun_obscured(1:u_range*num_of_options,i))/(u_range*num_of_options);%take the mean of all values in each minute
%     hourly_mean_by_coverage(2,i)=sum(sun_obscured(1*u_range*num_of_options:2*u_range*num_of_options,i))/(u_range*num_of_options); %indexing is variable to user pre-set variables
%     hourly_mean_by_coverage(3,i)=sum(sun_obscured(2*u_range*num_of_options:3*u_range*num_of_options,i))/(u_range*num_of_options);
%     hourly_mean_by_coverage(4,i)=sum(sun_obscured(3*u_range*num_of_options:4*u_range*num_of_options,i))/(u_range*num_of_options);
%     hourly_mean_by_coverage(5,i)=sum(sun_obscured(4*u_range*num_of_options:5*u_range*num_of_options,i))/(u_range*num_of_options);
%     hourly_mean_by_coverage(6,i)=sum(sun_obscured(5*u_range*num_of_options:6*u_range*num_of_options,i))/(u_range*num_of_options);
%     hourly_mean_by_coverage(7,i)=sum(sun_obscured(6*u_range*num_of_options:7*u_range*num_of_options,i))/(u_range*num_of_options);
%     hourly_mean_by_coverage(8,i)=sum(sun_obscured(7*u_range*num_of_options:8*u_range*num_of_options,i))/(u_range*num_of_options);
%     hourly_mean_by_coverage(9,i)=sum(sun_obscured(8*u_range*num_of_options:9*u_range*num_of_options,i))/(u_range*num_of_options);
%     hourly_mean_all(1,i)=sum(sun_obscured(:,i))/(length(sun_obscured));
% end

%% Reporting and Plots
figure(1); %plot the cloud stats. Show a power law
loglog(combined_record(2:length(combined_record),1)./10,combined_record(2:length(combined_record),3))
title('Cloud Length Frequency'),xlabel('x, Cloud Length (km)'),ylabel('Probability p(x)'),
% 
% x_plot2=(1:60);
% figure(2); %plot the mean cloud cover for each minute across the hour
% plot(x_plot2, hourly_mean_by_coverage(9,:),'--',x_plot2, hourly_mean_by_coverage(8,:),':',x_plot2, hourly_mean_by_coverage(7,:),x_plot2, hourly_mean_by_coverage(6,:),x_plot2, hourly_mean_by_coverage(5,:),x_plot2, hourly_mean_by_coverage(4,:),x_plot2, hourly_mean_by_coverage(3,:),x_plot2, hourly_mean_by_coverage(2,:),x_plot2, hourly_mean_by_coverage(1,:))
% % title('Mean Cloud Cover Across all Hours (Split by Coverage'),
% xlabel('Minute of the Hour (mins)'),ylabel('Cloud Coverage Fraction')
% hleg=legend('C=9','C=8','C=7','C=6','C=5','C=4','C=3','C=2','C=1');%,'Location','BestOutside');
% 
% pos = get(gca,'Position'); %reduce the lenght of the X-axis (by 10%)
% pos(3)=.9*pos(3);
% set(gca,'Position',pos);
% pos = get(hleg,'Position'); % move the location of the legend by 115%
% pos(1) = 1.27*pos(1);
% set(hleg,'Position',pos);
% 
% 
% 
% 
% fig3mean=mean(hourly_mean_all);
% fig3mean=ones(1,60)*fig3mean;
% figure(3);%plot the overall mean cloud cover. The average coverage is 5 and so chance of any minute should be 0.5.
% plot(x_plot2,hourly_mean_all,'LineWidth',2,'Color','r')
% hold on
% plot(x_plot2,fig3mean,'LineWidth',1, 'LineStyle','--','Color','k');
% hold off
% % title('Mean Cloud Cover Across all Hours')
% xlabel('Minute of Hour (mins)')
% ylabel('Cloud Coverage Fraction')
% axis([0 60 0.485 0.5])
% disp(['Complete',1]);
% toc
% % 
% % figure(4);
% % rowselection=ceil(rand*length(sun_obscured));
% % totallength=length(sun_obscured);
% % plot(sun_obscured(rowselection,:),'Color','black')
% % title('Example plot of row ',num2str(rowselection),' out of',num2str(totallength)),xlabel('Minute of the Hour (mins)'),ylabel('Cloud Indicator'),
% % axis([0 60 -0.1 1.1])
% 
% 
% clear cloud_sample cloud_resampled