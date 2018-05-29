

%number of sample hours per wind speed per coverage  (Timings: 10^7,100=17s. 10^7,1000=32s. 2*10^7,100=31s. 2*10
num_of_options=1000;
% typically, it seems that there are at least 90% unique cloud samples
% per bin across all speeds with 100 options. 

if exist('Sun_Obscured_Options_Generic.csv','file')
    disp('Loading store of cloud samples')
    %% Cloud cover options
    %Read in the sun obscured options, an array full of clouded hours in minutes(:,60).
    sun_obscured_options = csvread('Sun_Obscured_Options_Generic.csv');
    
else
    % if they dont exist, produce them
    ProduceCloudSamples(t_res,num_of_options,wind_speed_range)    
end