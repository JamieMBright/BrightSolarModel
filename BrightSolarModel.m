% +---------------------------------------------------------------------+
% |             Synthetic Irradiance Time Series Generator              |
% +---------------------------------------------------------------------+
% | This script will produce 1-minutely resolution irradiance data upon |
% | an arbitrary plane of defined latitude, orientation and aspect for  |
% | a defined period of time.                                           |
% |                                                                     |
% | The script reads in UK hourly weather data from MIDAS records from  |
% | the British Atmospheric Data Centre. Analysis of the wind speed,    |
% | cloud cover, cloud height, wind speed and pressure allows the       |
% | production of discrete time Markov chains to stochastically produce |
% | the subsequent hour based on the current weather state.             |
% |                                                                     |
% | Cloud cover is produced with cloud length following a single power  |
% | law distribution. Using the cloud cover, season, and the Klutcher   |
% | model, the optical thickness of the cloud is calculated along with  |
% | the diffuse and direct the irradiance is calculated.                |
% +---------------------------------------------------------------------+
% | Original data cannot be provided as per terms and conditions of the |
% | BADC. The Markov chains produced from the data have been so the     |
% | weather conditions for Cambourne, UK can be reproduced. The code to |
% | produce the markov chains is included but commented out. Described  |
% | is the format required of the input data.                           |
% |_____________________________________________________________________|
% | Permission is given to adopt and adapt this methodology into any    |
% | application deemed fit. Appropriate citaion is required.            |
% +---------------------------------------------------------------------+
% | Suggested citation: Bright, Jamie M.; Smith, Chris .J; Taylor, Peter|
% | G.; Crook, R. 2015. Stochastic generation of synthetic minutely     |
% | irradiance time series derived from mean hourly weather observation |
% | data. Journal of Solar Energy. V(I).pp.DOI.                         |
% |                                                                     |
% | Created by: Jamie Bright and Chris Smith                            |
% | Contributors: Rolf Crook and Peter Taylor                           |
% |                                                                     |
% | Date completed: 30/01/2015                                          |
% +---------------------------------------------------------------------+
%% Preamble
disp('Starting Simulation');
disp('------------------------------------');
tic %set a timer
read_file_check=exist('read_files','var'); %check to see if data is already loaded (time saving). Note that this will fail if running two differnet versions simultaneously nd "clear all" in the command window will be required.
data_exist_check=exist('sun_obscured_options','var'); %check if the data is truly loaded (if first run failes (i.e. typo in run_validation, then this will not load without this line)
if read_file_check==0;  %if it isn't already loaded...
    read_files='y'; %read in the files this simulation. 'y' is used from previous version. could be changed but not an issue.
elseif data_exist_check==0; %if it isn't already loaded...
    read_files='y';
else read_files=read_file_check; %if they aren't then set read_files to anything other than 'y' to skip.
end
%clear all other variables so new simulation can be performed
clearvars -except pressure data sun_obscured_options read_files run_validation wind_max pressure_avg cum_springhp_prob cum_summerhp_prob cum_autumnhp_prob cum_winterhp_prob cum_springlp_prob cum_summerlp_prob cum_autumnlp_prob cum_winterlp_prob springlpsys_mean springlpsys_std summerlpsys_mean summerlpsys_std autumnlpsys_mean autumnlpsys_std winterlpsys_mean winterlpsys_std springhpsys_mean springhpsys_std summerhpsys_mean summerhpsys_std autumnhpsys_mean autumnhpsys_std winterhpsys_mean winterhpsys_std cum_morningspring_prob cum_morningsummer_prob cum_morningautumn_prob cum_morningwinter_prob cum_wind_spring_prob cum_wind_summer_prob cum_wind_autumn_prob cum_wind_winter_prob cum_cloudheight_spring_prob cum_cloudheight_summer_prob cum_cloudheight_autumn_prob cum_cloudheight_winter_prob cum_PAAmarkov_prob cum_PBAmarkov_prob

%% User Defined Variables
% User defined variables to set
start_day=1; % choose the day number from which to start from
start_year=2001; % choose the year from which to start from. Not really important as leap years not currently accounted for.
num_of_years=7; % set the duration from the model to run (1/365.25 will select 1 day etc.)
num_of_days=365*6+366; %could account for leap years here, as per example.

latitude=50.2178; % set the latitude of the desired location. Currently Cambourne, UK
longitude=  -5.32656; % set the longitude of the desired location. Currently Cambourne, UK
height_above_sea_level=87; %meters above sea level. Currently Cambourne, UK
panel_pitch=0; %(degs.) set the panel angle (measured from the horizontal).
panel_azimuth=0; %(degs.) set the orientation. measured from north, + to east, - to west. (-180 to 180. +-180=North, 0=south)
%% Other Variables
u_range=60; % the range of windspeeds. standard=60. defined from 'Cloud_Sampling_Technique.m'. This is a length process and, whilst provided, it is recommended to just use the standard.
num_of_options=1000;% the number of options per windspeed per coverage. standard=1000
%% Sample Data
% Using BADC input data, this can be collated into the appropriate format
% using the data_preparation.m. If so comment out this section, and re-introduce the following commented-out section (ctrl+t uncomments, ctrl+r comments).

if read_files=='y'; % from preamble. If the data hasn't been read in yet, read it in.
    disp('1)Reading in Data Files')
    sun_obscured_options = csvread('supportingfiles/Sun_Obscured_Options_Generic.csv'); %Read in the sun obscured options, an array full of clouded hours in minutes(:,60).
    %files to be read in from the example site in Cambourne, UK. list is the list of variable names which have supporting files. it is important that \supportingfiles\ folder is in the working directory, else you will need to update the dlmread function.
    list={'wind_max','pressure_avg','cum_springhp_prob','cum_summerhp_prob','cum_autumnhp_prob','cum_winterhp_prob','cum_springlp_prob','cum_summerlp_prob','cum_autumnlp_prob','cum_winterlp_prob','springlpsys_mean','springlpsys_std','summerlpsys_mean','summerlpsys_std','autumnlpsys_mean','autumnlpsys_std','winterlpsys_mean','winterlpsys_std','springhpsys_mean','springhpsys_std','summerhpsys_mean','summerhpsys_std','autumnhpsys_mean','autumnhpsys_std','winterhpsys_mean','winterhpsys_std','cum_morningspring_prob','cum_morningsummer_prob','cum_morningautumn_prob','cum_morningwinter_prob','cum_wind_spring_prob','cum_wind_summer_prob','cum_wind_autumn_prob','cum_wind_winter_prob','cum_cloudheight_spring_prob','cum_cloudheight_summer_prob','cum_cloudheight_autumn_prob','cum_cloudheight_winter_prob','cum_PAAmarkov_prob','cum_PBAmarkov_prob'};
    disp('2)Loading Markov Chains')
    for i=1:length(list)
        name=list{1,i};
        x=dlmread(fullfile('supportingfiles',[name,'.txt']));
        assignin('base',name,x);
    end
else
    disp('1)Data already loaded')
    disp('2)Markov chains already loaded')
    disp('   -use "clear all" and retry if errors persist')
end
%% Reintroduce to create markov chains from your own input data using the data_preparation.m script

% % % % % % % %% Read In Data
% % % % % % % % Select appropriate location files
% % % % % % % disp('1)Reading in Data Files')
% % % % % % % if read_files=='y'; % from preamble. If the data hasn't been read in yet, read it in.
% % % % % % %     pressure=csvread('1395pressure2001to2012.csv'); %read in a separated spressure file produced using data_preparationg.m
% % % % % % %     data1=csvread('1395data2001to2012.csv');%read in csv file produced from data_preperation.m. Note not all these variables are required, only the time stamps, cloud total okta, cloud height, wind speed
% % % % % % %     % Data file: 1) hour% 2) cloud total (okta)% 3) Low cloud type% 4) Medium Cloud Type% 5) high cloud type% 6) cloud base height 7) pressure (msl)% 8)  1 - cloud ammount% 9)  1 - cloud type% 10) 1 - cloud height (decameters)% 11) 2    ""
% % % % % % %     % 12) 2    ""% 13) 2    ""% 14) 3    ""% 15) 3    ""% 16) 3    ""% 17) Air temp% 18) year% 19) hour of day 20) day number% insert 6 blank rows to fill with markov case, season, hp/lp systems x4% 27) wind direction% 28) wind speed
% % % % % % %     data2= zeros(length(data1),6); %These 6 blanks get utilised later in setting season number etc. required due to adjustment in data preparation, this line saves a significant amount of recoding.
% % % % % % %     data = [data1(:,1:20) data2 data1(:,20+1:end)]; %final preparation of the working data file.
% % % % % % %     sun_obscured_options = csvread('Sun_Obscured_Options_Generic.csv'); %Read in the sun obscured options, an array full of clouded hours in minutes(:,60).
% % % % % % % end
% % % % % % % %% Markov Creation
% % % % % % % disp('2)Constructing Markov Chains')
% % % % % % % % define the seasons.
% % % % % % % season=zeros(length(data),1); %pre allocate array
% % % % % % % for i=1:length(data)%For each hour measurement.  NB: Spring=Mar to May. Summer=Jun to Aug. Autumn=Sept to Nov. Winter=Dec to Feb
% % % % % % %     if isinteger(data(i,18)/4)== 1;%this is a method to check whether the year is a leap year. then updates the day at which the seasons start and end.
% % % % % % %         springstart=61;springend=152;summerstart=153;summerend=244;autumnstart=245;autumnend=335;%winterstart=and(1,336);winterend=and(60,366);
% % % % % % %     else springstart=60;springend=151;summerstart=152;summerend=243;autumnstart=244;autumnend=334;%winterstart=and(1,335);winterend=and(59,365);
% % % % % % %     end
% % % % % % %     if data(i,20)>= springstart && data(i,20)<=springend;        season(i,1)=1; %query the day number, then assign the appropriate season number, sp=1 su=2 etc.
% % % % % % %     elseif data(i,20)>=summerstart && data(i,20)<=summerend;        season(i,1)=2;
% % % % % % %     elseif data(i,20)>= autumnstart && data(i,20)<=autumnend;        season(i,1)=3;
% % % % % % %     else season(i,1)=4;
% % % % % % %     end
% % % % % % % end
% % % % % % % data(:,21)=season;%column 21 = season {1,2,3,4}
% % % % % % %
% % % % % % % % Assign a case number in order to populate the correct Markov Table. these cases will be used as a refference.
% % % % % % % pressure_avg=mean(pressure(:,2)); % Calculate the average pressure from the pressure input file.
% % % % % % % markovcase=zeros(length(data),1); % pre-allocate memory by making blank array for the markov cases.
% % % % % % % for i=1:length(data);%rows:21 = season.  7=mean sea level pressure
% % % % % % %     if data(i,21)==1 && data(i,7)<pressure_avg;            markovcase(i,1)=1; %different markov chains for each season and for above/below average pressure
% % % % % % %     elseif data(i,21)==1 && data(i,7)>pressure_avg;        markovcase(i,1)=2; %spring high pressure
% % % % % % %     elseif data(i,21)==2 && data(i,7)<pressure_avg;        markovcase(i,1)=3; %summer low pressure
% % % % % % %     elseif data(i,21)==2 && data(i,7)>pressure_avg;        markovcase(i,1)=4; %summer high pressure
% % % % % % %     elseif data(i,21)==3 && data(i,7)<pressure_avg;        markovcase(i,1)=5; %autumn low pressure etc.
% % % % % % %     elseif data(i,21)==3 && data(i,7)>pressure_avg;        markovcase(i,1)=6;
% % % % % % %     elseif data(i,21)==4 && data(i,7)<pressure_avg;        markovcase(i,1)=7;
% % % % % % %     elseif data(i,21)==4 && data(i,7)>pressure_avg;        markovcase(i,1)=8; %the if statement asks for the season number (1--4), and whether the current pressure is above/below the average pressure
% % % % % % %     end
% % % % % % % end
% % % % % % % data(:,22)=markovcase;%22=markovcase. Reintroduce the markov case into the data file.
% % % % % % %
% % % % % % % springlp=zeros(10,10); %pre-allocate memory for the 8 different markov chains
% % % % % % % springhp=zeros(10,10);summerlp=zeros(10,10);summerhp=zeros(10,10);autumnlp=zeros(10,10);autumnhp=zeros(10,10);winterlp=zeros(10,10);winterhp=zeros(10,10); %re[eat for each transition probability matrix
% % % % % % %
% % % % % % % %Assign okta of (0/8) a value of 10 for use in columns. this allows for indexing using the okta value
% % % % % % % for i=1:length(data); % column meaning = 2)hourly okta. 8,11,14)okta layer
% % % % % % %     if data(i,2)==0; data(i,2)=10; end %if the okta reading is 0, give value of 10
% % % % % % %     if data(i,8)==0; data(i,8)=10; end
% % % % % % %     if data(i,11)==0;data(i,11)=10;end
% % % % % % %     if data(i,14)==0;data(i,14)=10;end
% % % % % % % end
% % % % % % %
% % % % % % % for i=2:length(data); %for every data point in the observational data%  index key: i=next, i-1=now.
% % % % % % %     markov=data(i,22); %column 22 = markov case
% % % % % % %     if data(i-1,2)~=-9999 && data(i,2)~=-9999; %if a data point follows another (and is not a missing value of -9999) then...
% % % % % % %         switch markov; %switch to the appropriate transition probability matrix
% % % % % % %             case 1; %spring low pressure
% % % % % % %                 springlp(data(i-1,2),data(i,2))= springlp(data(i-1,2),data(i,2))+1; %tally/populate the markov chain in appropriate place
% % % % % % %             case 2; %spring high presusre
% % % % % % %                 springhp(data(i-1,2),data(i,2))= springhp(data(i-1,2),data(i,2))+1;
% % % % % % %             case 3; %summer low pressure
% % % % % % %                 summerlp(data(i-1,2),data(i,2))= summerlp(data(i-1,2),data(i,2))+1;
% % % % % % %             case 4; %summer high pressure
% % % % % % %                 summerhp(data(i-1,2),data(i,2))= summerhp(data(i-1,2),data(i,2))+1;
% % % % % % %             case 5; %autumn low pressure
% % % % % % %                 autumnlp(data(i-1,2),data(i,2))= autumnlp(data(i-1,2),data(i,2))+1;
% % % % % % %             case 6; %autumn high pressure
% % % % % % %                 autumnhp(data(i-1,2),data(i,2))= autumnhp(data(i-1,2),data(i,2))+1;
% % % % % % %             case 7; %winter low pressure
% % % % % % %                 winterlp(data(i-1,2),data(i,2))= winterlp(data(i-1,2),data(i,2))+1;
% % % % % % %             case 8; %winter high pressure
% % % % % % %                 winterhp(data(i-1,2),data(i,2))= winterhp(data(i-1,2),data(i,2))+1;
% % % % % % %         end
% % % % % % %     end
% % % % % % % end
% % % % % % % %total nummber of observations within each markov frequency array
% % % % % % % obsv_springlp=sum(sum(springlp),2);obsv_summerlp=sum(sum(summerlp),2);obsv_autumnlp=sum(sum(autumnlp),2);obsv_winterlp=sum(sum(winterlp),2);obsv_springhp=sum(sum(springhp),2);obsv_summerhp=sum(sum(summerhp),2);obsv_autumnhp=sum(sum(autumnhp),2);obsv_winterhp=sum(sum(winterhp),2);
% % % % % % % report=[obsv_springlp;obsv_summerlp;obsv_autumnlp;obsv_winterlp;obsv_springhp;obsv_summerhp;obsv_autumnhp;obsv_winterhp];
% % % % % % % if min(report)<1500;disp(['WARNING: too few observations - potentially inaccurate markov chains',1]);end % kick out an error message if there are too few observed transitions in the data
% % % % % % %
% % % % % % % % Required to create a markov chain that decides when a high pressure system changes to a low pressure system.
% % % % % % % for i=1:length(data); %for the length of the data..
% % % % % % %     if data(i,7)>pressure_avg; data(i,23)=1; %if the pressure is above average...
% % % % % % %     else  data (i,24)=1; % ...assign a value of 1. This is to keep a tally of pressure system length.
% % % % % % %     end %columns = 23)high pressure indicator, 24)low pressure indicator
% % % % % % % end
% % % % % % % for i=2:length(data)-1; % calculating the duration of the high pressure system, accounting for missing data points.
% % % % % % %     if data(i:i-5,7)==-9999;%if there are 5 missing data plots, end the duration count
% % % % % % %     elseif data(i,7)==-9999; %assuming that the missing data maintains same pressure as before.
% % % % % % %         data(i,25)=data(i-1,25); data(i+1,25)=data(i-1,25); %maintain the duration count
% % % % % % %     elseif data(i,23)==1 && data(i+1,23)==1;% 23)= high pressure indicator.
% % % % % % %         data(i+1,25)=data(i,25)+data(i+1,23); %keep a running tally of the duration.
% % % % % % %     end
% % % % % % % end
% % % % % % % for i=1:length(data)-1; %Using column 25 to do this.
% % % % % % %     if data(i+1,25)~=0; data(i,25)=0; end %remove all but the final duration count, and therefore the duration of each system
% % % % % % % end
% % % % % % % for i=2:length(data)-1; %repeat above for low pressure
% % % % % % %     if data(i:i-5,7)==-9999; %using column 26 to do this.
% % % % % % %     elseif data(i,7)==-9999; data(i,26)=data(i-1,26); data(i+1,26)=data(i-1,26);
% % % % % % %     elseif data(i,24)==1 && data(i+1,24)==1; data(i+1,26)=data(i,26)+data(i+1,24);
% % % % % % %     end
% % % % % % % end
% % % % % % % for i=1:length(data)-1;
% % % % % % %     if data(i+1,26)~=0; data(i,26)=0;  end
% % % % % % % end
% % % % % % % highpressure=zeros(length(data),2); %pre allocate memory
% % % % % % % lowpressure=zeros(length(data),2); %pre allocate memory
% % % % % % % highpressure(:,1)=data(:,21); %data(21)=season.  1)season
% % % % % % % highpressure(:,2)=data(:,25); %data(25)=durationhp 2)duration of hp system
% % % % % % % lowpressure(:,1)=data(:,21); %1)season
% % % % % % % lowpressure(:,2)=data(:,26); %2)duration of lp system
% % % % % % %
% % % % % % % %separate the typical length of a pressure system by season
% % % % % % % for i=1:length(highpressure);% 1)season% 2)duration of system%
% % % % % % %     if highpressure(i,1)==1;            highpressure(i,3)=highpressure(i,2); %if the season is 1, set the appropriate column to the pressure duration.
% % % % % % %     elseif highpressure(i,1)==2;        highpressure(i,4)=highpressure(i,2); %repeat for each season
% % % % % % %     elseif highpressure(i,1)==3;        highpressure(i,5)=highpressure(i,2); % columns 3-6 are each season spr-sum-aut-win with the appropriate duration inside
% % % % % % %     else highpressure(i,6)=highpressure(i,2);
% % % % % % %     end
% % % % % % % end
% % % % % % % for i=1:length(lowpressure); %repeat for low pressure.
% % % % % % %     if lowpressure(i,1)==1;              lowpressure(i,3)=lowpressure(i,2);
% % % % % % %     elseif lowpressure(i,1)==2;          lowpressure(i,4)=lowpressure(i,2);
% % % % % % %     elseif highpressure(i,1)==3;         lowpressure(i,5)=lowpressure(i,2);
% % % % % % %     else lowpressure(i,6)=lowpressure(i,2);
% % % % % % %     end
% % % % % % % end
% % % % % % % %tabulate the findings into the pressure system and season
% % % % % % % springhpsys=tabulate(highpressure(:,3)); %tabulate function produces the frequency of occurrence of each discreet value in the input matrix, therefore any value >0 is a unique duration observed in the data.
% % % % % % % summerhpsys=tabulate(highpressure(:,4));autumnhpsys=tabulate(highpressure(:,5));winterhpsys=tabulate(highpressure(:,6));springlpsys=tabulate(lowpressure(:,3));summerlpsys=tabulate(lowpressure(:,4));autumnlpsys=tabulate(lowpressure(:,5));winterlpsys=tabulate(lowpressure(:,6));
% % % % % % %
% % % % % % % %make a markov chain for the morning (between 1-5am)
% % % % % % % ammarkov=zeros(length(data),1);
% % % % % % % ammarkov(:,1)=data(:,19); %hour of day
% % % % % % % ammarkov(:,2)=data(:,21); %season
% % % % % % % ammarkov(:,3)=data(:,2); %okta
% % % % % % % %separate the okta number by season
% % % % % % % for i=1:length(ammarkov);
% % % % % % %     if ammarkov(i,1)<6; %for hours 0--5.
% % % % % % %         if ammarkov(i,2)==1;  %if the season is spring.
% % % % % % %             ammarkov(i,4)=ammarkov(i,3);%put the okta in appropriate column.
% % % % % % %         elseif ammarkov(i,2)==2; ammarkov(i,5)=ammarkov(i,3);%summer
% % % % % % %         elseif ammarkov(i,2)==3; ammarkov(i,6)=ammarkov(i,3);%autumn
% % % % % % %         else ammarkov(i,7)=ammarkov(i,3);%winter
% % % % % % %         end
% % % % % % %     end
% % % % % % % end
% % % % % % % %pre-allocate memory for the morning markov chains
% % % % % % % morningspring=zeros(10,10);morningsummer=zeros(10,10);morningautumn=zeros(10,10);morningwinter=zeros(10,10);
% % % % % % %
% % % % % % % %usage is (now,next)  i=next, i-1=now.
% % % % % % % for i=1:length(ammarkov); %change -9999 values to 0 %probably replaceable with ammarkov(ammarkov==-9999)=0, unless there are -9999 values in columns 1-3.
% % % % % % %     for j=4:7;
% % % % % % %         if ammarkov(i,j)==-9999;ammarkov(i,j)=0;end
% % % % % % %     end
% % % % % % % end
% % % % % % % %Make a tally of the total number of occurances of okta transition from the current state (Column(i)) to the future state  (Row(i+1))
% % % % % % % for i=2:length(ammarkov);%spring
% % % % % % %     if ammarkov(i-1,4)~=0 && ammarkov(i,4)~=0;
% % % % % % %         morningspring(ammarkov(i-1,4),ammarkov(i,4))=morningspring(ammarkov(i-1,4),ammarkov(i,4))+1;    end
% % % % % % % end
% % % % % % % for i=2:length(ammarkov);%summer
% % % % % % %     if ammarkov(i-1,5)~=0 && ammarkov(i,5)~=0; morningsummer(ammarkov(i-1,5),ammarkov(i,5))=morningsummer(ammarkov(i-1,5),ammarkov(i,5))+1;    end
% % % % % % % end
% % % % % % % for i=2:length(ammarkov);%autumn
% % % % % % %     if ammarkov(i-1,6)~=0 && ammarkov(i,6)~=0; morningautumn(ammarkov(i-1,6),ammarkov(i,6))=morningautumn(ammarkov(i-1,6),ammarkov(i,6))+1;    end
% % % % % % % end
% % % % % % % for i=2:length(ammarkov);%winter
% % % % % % %     if ammarkov(i-1,7)~=0 && ammarkov(i,7)~=0;  morningwinter(ammarkov(i-1,7),ammarkov(i,7))=morningwinter(ammarkov(i-1,7),ammarkov(i,7))+1;    end
% % % % % % % end
% % % % % % %
% % % % % % % %make transition matrices for wind speed
% % % % % % % windspeedupdate=data(:,28); %separate out the windspeeds
% % % % % % % windspeedupdate(windspeedupdate==0)=1; %windspeed of 0 knotts is now = 1 knott for indexing purposes
% % % % % % % data(:,28)=windspeedupdate; %replace the column with updated values
% % % % % % % wind_max=max(data(:,28)); % determine the maximum measured windspeed
% % % % % % % wind_spring=zeros(wind_max,wind_max);% pre allocate memory for wind markovs using the maximum wind speed for each season
% % % % % % % wind_summer=zeros(wind_max,wind_max);
% % % % % % % wind_autumn=zeros(wind_max,wind_max);
% % % % % % % wind_winter=zeros(wind_max,wind_max);
% % % % % % % for i=2:length(data); % i=next, i-1=now.
% % % % % % %     seasonmarker=data(i,21); %season
% % % % % % %     if data(i-1,28)~=-9999 && data(i,28)~=-9999; %if a data point follows another (and is not a missing value of -9999) (a genuine transition)
% % % % % % %         switch seasonmarker;
% % % % % % %             case 1; %spring
% % % % % % %                 wind_spring(data(i-1,28),data(i,28))= wind_spring(data(i-1,28),data(i,28))+1; %populate the markov chain tally in appropriate place
% % % % % % %             case 2; %summer
% % % % % % %                 wind_summer(data(i-1,28),data(i,28))= wind_summer(data(i-1,28),data(i,28))+1;
% % % % % % %             case 3; %autumn
% % % % % % %                 wind_autumn(data(i-1,28),data(i,28))= wind_autumn(data(i-1,28),data(i,28))+1;
% % % % % % %             case 4; %winter
% % % % % % %                 wind_winter(data(i-1,28),data(i,28))= wind_winter(data(i-1,28),data(i,28))+1;
% % % % % % %         end
% % % % % % %     end
% % % % % % % end
% % % % % % %
% % % % % % % cloudheightupdate1=[data(:,10),data(:,13),data(:,16)]; %take the cloud heights of the 3 levels measured
% % % % % % % cloudheightupdate1(cloudheightupdate1==-9999)=0/0; %make -9999 values a NaN for the nan mean;
% % % % % % % cloudheightupdate=round(nanmean(cloudheightupdate1,2)); %find the mean cloud height
% % % % % % % cloudheightupdate=round(cloudheightupdate./5).*5; % round it to the nearest 5.
% % % % % % % cloudheightupdate(isnan(cloudheightupdate)==1)=-9999;%replace NaN values to -9999
% % % % % % % cloudheightupdate(cloudheightupdate==0)=1; % for indexing. returned to 0 later. Note this is in decameters and no clouds were measured at 1decameter across every site chosen.
% % % % % % %
% % % % % % % data(:,6)=cloudheightupdate;
% % % % % % % cl_h_max=ceil(max(data(:,6)));
% % % % % % % cloudheight_spring=zeros(cl_h_max,cl_h_max);
% % % % % % % cloudheight_summer=zeros(cl_h_max,cl_h_max);
% % % % % % % cloudheight_autumn=zeros(cl_h_max,cl_h_max);
% % % % % % % cloudheight_winter=zeros(cl_h_max,cl_h_max);
% % % % % % % for i=2:length(data); % i=next, i-1=now.
% % % % % % %     seasonmarker=data(i,21); %season
% % % % % % %     if data(i-1,6)~=-9999 && data(i,6)~=-9999; %if a data point follows another (and is not a missing value of -9999)
% % % % % % %         switch seasonmarker;
% % % % % % %             case 1; %spring
% % % % % % %                 cloudheight_spring(data(i-1,6),data(i,6))= cloudheight_spring(data(i-1,6),data(i,6))+1; %populate the markov chain in appropriate place
% % % % % % %             case 2; %summer
% % % % % % %                 cloudheight_summer(data(i-1,6),data(i,6))= cloudheight_summer(data(i-1,6),data(i,6))+1;
% % % % % % %             case 3; %autumn
% % % % % % %                 cloudheight_autumn(data(i-1,6),data(i,6))= cloudheight_autumn(data(i-1,6),data(i,6))+1;
% % % % % % %             case 4; %winter
% % % % % % %                 cloudheight_winter(data(i-1,6),data(i,6))= cloudheight_winter(data(i-1,6),data(i,6))+1;
% % % % % % %         end
% % % % % % %     end
% % % % % % % end
% % % % % % % cloudheight_spring(1,1)=0; %cloud height of 1 is actually 0, no cloud. remove all chance of staying at 1.
% % % % % % % cloudheight_summer(1,1)=0;
% % % % % % % cloudheight_autumn(1,1)=0;
% % % % % % % cloudheight_winter(1,1)=0;
% % % % % % %
% % % % % % % %Analyse the Pressure
% % % % % % % Pmsl=pressure(:,2); %extract the pressure values
% % % % % % % Pmsl=round(Pmsl);
% % % % % % % Pmax=ceil(max(Pmsl)); %find the largest pressure
% % % % % % % PAAmarkov=zeros(Pmax,Pmax); %make blank array for above average Markov chain
% % % % % % % PBAmarkov=zeros(Pmax,Pmax); %make blank array for below average markov chain
% % % % % % % for i=1:length(Pmsl)-1; %for the length of the pressure readings
% % % % % % %  if Pmsl(i)<=ceil(pressure_avg) && Pmsl(i+1)<=ceil(pressure_avg) %if two consecutive measurements are below average
% % % % % % %      PBAmarkov(ceil(Pmsl(i)),ceil(Pmsl(i+1)))=PBAmarkov(ceil(Pmsl(i)),ceil(Pmsl(i+1)))+1; %keep a transition tally
% % % % % % %  end
% % % % % % %
% % % % % % %  if Pmsl(i)>ceil(pressure_avg) && Pmsl(i+1)>ceil(pressure_avg)
% % % % % % %      PAAmarkov(ceil(Pmsl(i)),ceil(Pmsl(i+1)))=PAAmarkov(ceil(Pmsl(i)),ceil(Pmsl(i+1)))+1;
% % % % % % %  end
% % % % % % % end
% % % % % % %
% % % % % % % % Produce the cumulative probability distribution of each pressure and% season possibility
% % % % % % % %This is done by dividing each state by the total number of times that state occured, or each tally is divided by the sum of the row.
% % % % % % % %after this the table is turned into a cumulative sum using the cumsum(x,2)function
% % % % % % % % seasonal high pressure
% % % % % % % springhp_prob=springhp./(sum(springhp,2)*ones(1,10)); %find the transition probability as P_ij/P*_i. See paper 2.2 on Markov chain creation.
% % % % % % % cum_springhp_prob=cumsum(springhp_prob,2); %convert into cumulative sum, this results in 0.....1 across entire length of each row.
% % % % % % % % this process is repeated for each of the markov chains for each season/pressure etc..
% % % % % % % summerhp_prob=summerhp./(sum(summerhp,2)*ones(1,10));       cum_summerhp_prob=cumsum(summerhp_prob,2);
% % % % % % % autumnhp_prob=autumnhp./(sum(autumnhp,2)*ones(1,10));       cum_autumnhp_prob=cumsum(autumnhp_prob,2);
% % % % % % % winterhp_prob=winterhp./(sum(winterhp,2)*ones(1,10));       cum_winterhp_prob=cumsum(winterhp_prob,2);
% % % % % % % % seasonal low pressure
% % % % % % % springlp_prob=springlp./(sum(springlp,2)*ones(1,10));       cum_springlp_prob=cumsum(springlp_prob,2);
% % % % % % % summerlp_prob=summerlp./(sum(summerlp,2)*ones(1,10));       cum_summerlp_prob=cumsum(summerlp_prob,2);
% % % % % % % autumnlp_prob=autumnlp./(sum(autumnlp,2)*ones(1,10));       cum_autumnlp_prob=cumsum(autumnlp_prob,2);
% % % % % % % winterlp_prob=winterlp./(sum(winterlp,2)*ones(1,10));       cum_winterlp_prob=cumsum(winterlp_prob,2);
% % % % % % % % low pressure system duration
% % % % % % % springlpsys(:,[2,3])=[];    springlpsys_mean=mean(springlpsys);  springlpsys_std=std(springlpsys); %find a typical mean system duration and standard deviation for implementation in the selection process later
% % % % % % % summerlpsys(:,[2,3])=[];    summerlpsys_mean=mean(summerlpsys);  summerlpsys_std=std(summerlpsys);
% % % % % % % autumnlpsys(:,[2,3])=[];    autumnlpsys_mean=mean(autumnlpsys);  autumnlpsys_std=std(autumnlpsys);
% % % % % % % winterlpsys(:,[2,3])=[];    winterlpsys_mean=mean(winterlpsys);  winterlpsys_std=std(winterlpsys);
% % % % % % % % high pressure system duration
% % % % % % % springhpsys(:,[2,3])=[];    springhpsys_mean=mean(springhpsys);  springhpsys_std=std(springhpsys);
% % % % % % % summerhpsys(:,[2,3])=[];    summerhpsys_mean=mean(summerhpsys);  summerhpsys_std=std(summerhpsys);
% % % % % % % autumnhpsys(:,[2,3])=[];    autumnhpsys_mean=mean(autumnhpsys);  autumnhpsys_std=std(autumnhpsys);
% % % % % % % winterhpsys(:,[2,3])=[];    winterhpsys_mean=mean(winterhpsys);  winterhpsys_std=std(winterhpsys);
% % % % % % % % produce morning markov chains for each season
% % % % % % % morningspring_prob=morningspring./(sum(morningspring,2)*ones(1,10));    cum_morningspring_prob=cumsum(morningspring_prob,2);
% % % % % % % morningsummer_prob=morningsummer./(sum(morningsummer,2)*ones(1,10));    cum_morningsummer_prob=cumsum(morningsummer_prob,2);
% % % % % % % morningautumn_prob=morningautumn./(sum(morningautumn,2)*ones(1,10));    cum_morningautumn_prob=cumsum(morningautumn_prob,2);
% % % % % % % morningwinter_prob=morningwinter./(sum(morningwinter,2)*ones(1,10));    cum_morningwinter_prob=cumsum(morningwinter_prob,2);
% % % % % % % % produce wind speed markov chains for each season
% % % % % % % wind_spring_prob=wind_spring./(sum(wind_spring,2)*ones(1,length(wind_spring)));    cum_wind_spring_prob=cumsum(wind_spring_prob,2);
% % % % % % % wind_summer_prob=wind_summer./(sum(wind_summer,2)*ones(1,length(wind_summer)));    cum_wind_summer_prob=cumsum(wind_summer_prob,2);
% % % % % % % wind_autumn_prob=wind_autumn./(sum(wind_autumn,2)*ones(1,length(wind_autumn)));    cum_wind_autumn_prob=cumsum(wind_autumn_prob,2);
% % % % % % % wind_winter_prob=wind_winter./(sum(wind_winter,2)*ones(1,length(wind_winter)));    cum_wind_winter_prob=cumsum(wind_winter_prob,2);
% % % % % % % % produce cloud height markov chains for each season
% % % % % % % cloudheight_spring_prob=cloudheight_spring./(sum(cloudheight_spring,2)*ones(1,length(cloudheight_spring)));    cum_cloudheight_spring_prob=cumsum(cloudheight_spring_prob,2);
% % % % % % % cloudheight_summer_prob=cloudheight_summer./(sum(cloudheight_summer,2)*ones(1,length(cloudheight_summer)));    cum_cloudheight_summer_prob=cumsum(cloudheight_summer_prob,2);
% % % % % % % cloudheight_autumn_prob=cloudheight_autumn./(sum(cloudheight_autumn,2)*ones(1,length(cloudheight_autumn)));    cum_cloudheight_autumn_prob=cumsum(cloudheight_autumn_prob,2);
% % % % % % % cloudheight_winter_prob=cloudheight_winter./(sum(cloudheight_winter,2)*ones(1,length(cloudheight_winter)));    cum_cloudheight_winter_prob=cumsum(cloudheight_winter_prob,2);
% % % % % % % %pressure
% % % % % % % PAAmarkov_prob=PAAmarkov./(sum(PAAmarkov,2)*ones(1,Pmax));  cum_PAAmarkov_prob=cumsum(PAAmarkov_prob,2);
% % % % % % % PBAmarkov_prob=PBAmarkov./(sum(PBAmarkov,2)*ones(1,Pmax));  cum_PBAmarkov_prob=cumsum(PBAmarkov_prob,2);


%% Produce Cloud Cover for the specified duration
disp('3)Generating Cloud Cover');
%define the seasons.% Spring=Mar to May.Summer=Jun to Aug. Autumn=Sept to Nov. Winter=Dec to Feb
springstart=60;springend=151;summerstart=152;summerend=243;autumnstart=244;autumnend=334;winterstart=and(1,335);winterend=and(59,365);
% set beginning weather system
if rand<0.5;start_pressure_sys=1; % 50:50 chance to start at either high...
else start_pressure_sys=0;        % ... or low pressure.
end
% determine start season  for the specified start point
if start_day>= springstart && start_day<=springend;     start_season=1;
elseif start_day>=summerstart && start_day<=summerend;  start_season=2;
elseif start_day>= autumnstart && start_day<=autumnend; start_season=3;
else                                                    start_season=4;
end
%determine the first markov chain required
switch start_season; %switch the start_season variable(1,2,3,4) to select the appropriate markov chain
    case 1;        weather_start=cum_morningspring_prob; %if current season is 1, spring, select the spring markov.
    case 2;        weather_start=cum_morningsummer_prob;
    case 3;        weather_start=cum_morningautumn_prob;
    case 4;        weather_start=cum_morningwinter_prob;
end

hours=ceil(num_of_days*24); %total number of hours in the simulation
day_number=start_day; %used for time keeping within the simulation
year=start_year;%used for time keeping within the simulation
pressure_sys=start_pressure_sys;%used to select the appropriate markov chain
current_season=start_season;%used to select the appropriate markov chain
hour_number=1; %for 1-24 loop. downfall: cannot begin simulation in the middle of the day

%define the weather pressure system duration using the observed mean pressure durations and the standard distributions. these are then used to select randomly from this distribution.
if pressure_sys==0; %if it is low pressure
    switch start_season; % find the current seasons pressure system
        case 1;            sys_duration=floor(normrnd(springlpsys_mean,springlpsys_std)); % determine a pressure system length from a normally distributed curve using the mean and std_dev seen in observations
        case 2;            sys_duration=floor(normrnd(summerlpsys_mean,summerlpsys_std));
        case 3;            sys_duration=floor(normrnd(autumnlpsys_mean,autumnlpsys_std));
        case 4;            sys_duration=floor(normrnd(winterlpsys_mean,winterlpsys_std));
    end
else % else if it is high pressure
    switch start_season; % find the current seasons pressure system
        case 1;            sys_duration=floor(normrnd(springhpsys_mean,springhpsys_std)); % based on the average observations from the weather data
        case 2;            sys_duration=floor(normrnd(summerhpsys_mean,summerhpsys_std));
        case 3;            sys_duration=floor(normrnd(autumnhpsys_mean,autumnhpsys_std));
        case 4;            sys_duration=floor(normrnd(winterhpsys_mean,winterhpsys_std));
    end
end
% select the approrpate cloudheight and wind transition probability matrix to use based on the current season.
switch start_season;
    case 1;        wind_start=cum_wind_spring_prob;cloud_height_start=cum_cloudheight_spring_prob;
    case 2;        wind_start=cum_wind_summer_prob;cloud_height_start=cum_cloudheight_summer_prob;
    case 3;        wind_start=cum_wind_autumn_prob;cloud_height_start=cum_cloudheight_autumn_prob;
    case 4;        wind_start=cum_wind_winter_prob;cloud_height_start=cum_cloudheight_winter_prob;
end
%select pressure
Pstart=round(pressure_avg); % start the pressure at the average pressure.
if pressure_sys==0; %if pressure system is low
    Pressure_markov=cum_PBAmarkov_prob; % the pressure moves with the markov chain
else Pressure_markov=cum_PAAmarkov_prob;
end
future_pressure=1+nansum(Pressure_markov(Pstart,:)<rand);

% Pre-allocate memory by making the arrays
weather_record = zeros(hours,10);
sun_obscured = zeros(hours*60,1);       sun_obs_record=zeros(hours*60,3);
u_ref=zeros(hours*60,1);                hour_x=zeros(hours*60,1);

% set the weather at the start of the day
current_weather_okta =ceil(rand*10); % select random start okta
future_weather_okta = 1 + sum(weather_start(current_weather_okta,:)<rand); % use morning weighted markov chain to select hour 1
current_wind_speed =ceil(rand*wind_max); % select random wind speed (1:50 knots)
future_wind_speed=1 + sum(wind_start(current_wind_speed,:)<rand);% use correct seasonal markov chain to select the windspeed
current_cloud_height=ceil(rand*250);%set cloud height at start of simulation
future_cloud_height=1+sum(cloud_height_start(current_cloud_height,:)<rand); % use appropriate markov chain to select start cloud height

% Produce the cloud cover over entire length of simulation as well as time requirements for irradiance calculations
% this loop goes through every hour of the desired simulation time and creates 1 minutely cloud cover.
for hour=1:hours; %hour is the increasing value from 1 to hours(the preset length of the simulation).
    current_weather_okta=future_weather_okta; % as the time progresses, the future state becomes the current state and a new future state is stochastically determined later in loop
    current_wind_speed=future_wind_speed; %as above
    current_cloud_height=future_cloud_height; % as above
    current_pressure=future_pressure; % as above
    month = ceil(day_number/30.501); % determine the current month (reasonably accurate method)
    
    % keep a record of events for each hour
    weather_record(hour,1)=hour_number;    weather_record(hour,2)=day_number;      weather_record(hour,3) = year;
    weather_record(hour,4)=current_season; weather_record(hour,5)=current_weather_okta;
    weather_record(hour,6) = pressure_sys; weather_record(hour,7)=sys_duration;
    %keep a minutely record of the month, season and pressure.
    month_record(hour*60-59:hour*60,1)= month; %the (hour*60-59:hour*60,) index is a good way of selecting the right set of minutes using the reference hour.
    season_record(hour*60-59:hour*60,1)=current_season;
    pressure_record(hour*60-59:hour*60,1)=current_pressure;
    
    %convert Okta number into its proportionate sky coverage (out of 10) %WMO 2700 code for cloud cover provides conversions of okta in 8ths to 10ths.
    switch current_weather_okta; %using whatever the current hour's okta value is, convert it according to the WMO 2700 code suggestions
        case 1; coverage=1;                 okta_minutely(hour*60-59:hour*60)=1;                %1/10 or less but not zero
        case 2; coverage=2+floor(2*rand);   okta_minutely(hour*60-59:hour*60)=2;                %2/10 - 3/10
        case 3; coverage=4;                 okta_minutely(hour*60-59:hour*60)=3;                %4/10
        case 4; coverage=5;                 okta_minutely(hour*60-59:hour*60)=4;                %5/10
        case 5; coverage= 6;                okta_minutely(hour*60-59:hour*60)=5;                %6/10
        case 6; coverage=7+floor(2*rand);   okta_minutely(hour*60-59:hour*60)=6;                %7/10 or 8/10
        case 7; coverage=9;                 okta_minutely(hour*60-59:hour*60)=7;                %9/10+ but not 10/10
        case 8; coverage=10;                okta_minutely(hour*60-59:hour*60)=8;                %10/10
        case 9; coverage=10;                okta_minutely(hour*60-59:hour*60)=9;                %sky obscured by fog and/or weather or other meteorlogical phenomena
        case 10; coverage=0;                okta_minutely(hour*60-59:hour*60)=0;                %0/10 (note that ockta 0 has been changed to 10 for array use)
    end
    
    weather_record(hour,8) = coverage; %update the records. These are not necessity, it just helps to have the hourly record should you want to see them.
    weather_record(hour,9) = current_cloud_height;
    coverage_vector(hour*60-59:hour*60,1) = coverage;
    
    %calculate the windspeed at the cloud height (met office):
    %u_ref=u10(log(zref/zoref))/(log(z10/zoref)) for <1km height. A distribution is used for above this. THIS is a significant limitation
    %to accurately determining the cloud speed and should be addressed more. It is difficult to do so without more detailed input data.
    if current_cloud_height<100; %height is in decameters. so below 100 is under 1km.
        u_ref=ceil(current_wind_speed*0.515*((log(current_cloud_height*10/0.14))/(log(10/0.14)))); %perform the met office interpolation %note the 0.515 conversion of knots to m/s. 0.14 is for a rural setting, this could perhaps be updated based on desired location.
    else % else use the ganrnd function above 1km.
        u_ref=round(gamrnd(2.7,2.144)); %gives mean of 3.49m/s with range 0-25 and 0.5% above 25.
    end
    if u_ref<1;        u_ref=1;    end % if the windspeed is too low, set it to the minimum
    if u_ref>60;       u_ref=60;   end % if the windspeed is too high, set it to the maximum
    
    weather_record(hour,10) = u_ref; %update the weather record.
    
    % populate sun_obscured depending on coverage value
    switch coverage
        case {1,2,3,4,5,6,7,8,9} %for coverage of 1-9.
            random=rand; % set a random value used in the below extraction from the options of sun obscured hours.
            sun_obscured(hour*60-59:hour*60,1)=sun_obscured_options(((u_range*num_of_options*(coverage-1))+ceil(num_of_options*u_ref-(random*num_of_options))),:); %note this is a complicated indexing that uses the coverage and the windspeed to randomly select 1 of the 1000 options for that particular C and u.
        case 10 %for fully overcast, the coverage for the hour is total, and so all 60 elements recieve a value of 1.
            sun_obscured(hour*60-59:hour*60,1) = 1; %sun_obscured is the primary array to come out of this long for loop.
    end
    
    %produce minutley hour fraction. This is each hour with minutely
    %decimals, e.g. minute 1 of hour 1 would be 1.00. minute 60 of hour 1 would be 1.983. This is for use later in the irradiance calculations
    hour_run=hour_number+(1/60):(1/60):hour_number+1; %calculate a temporary vector with the hour runs in.
    hour_x(hour*60-59:hour*60,1)=hour_run'; %fill with minutely hour fractions
    
    %determine if current year is leap year and add the additional day
    if floor(year/4)/(year/4)==1; %if the year is a multiple of 4
        days_in_year=366; %increase the days of the year to 366.
    else days_in_year=365; % else set it at 365.
    end
    
    % produce days for use in iradiance calculations
    day_run=linspace(day_number+hour*(1/60),day_number+(hour+1)*(1/60),60);%produce minutely day fraction 1/(60*24). Same as the hour run above, except the day run
    day(hour*60-59:hour*60,1)=day_run';
    
    %determine current season
    if day_number>= springstart && day_number<=springend;        current_season=1; %if the day number is between the start and end day value, determine the current season.
    elseif day_number>=summerstart && day_number<=summerend;     current_season=2;
    elseif day_number>= autumnstart && day_number<=autumnend;    current_season=3;
    else                                                         current_season=4;
    end
    
    % Determine length decision of next pressure system. ASSUMPTION: pressure system always switches from low to high.
    if sys_duration==0; %once the current pressure system has finished.
        if pressure_sys==0; %if it is currently a below average pressure system..
            pressure_sys=1;%... switch to an above average pressure system.
            switch current_season; % determine the length of the new pressure system based on season and the mean and standard deviation for that season.
                case 1;                    sys_duration=round(normrnd(springhpsys_mean,springhpsys_std)); %if it is spring, use spring mean and std_dev to get a new duration.
                case 2;                    sys_duration=round(normrnd(summerhpsys_mean,summerhpsys_std)); % and so on.
                case 3;                    sys_duration=round(normrnd(autumnhpsys_mean,autumnhpsys_std));
                case 4;                    sys_duration=round(normrnd(winterhpsys_mean,winterhpsys_std));
            end
        else pressure_sys=0; %...else switch to a below average pressure system
            switch current_season; %and as before, depending on the season, select a typical duration.
                case 1;                    sys_duration=round(normrnd(springlpsys_mean,springlpsys_std)); %if it is spring, use spring mean and std_dev to get a new duration.
                case 2;                    sys_duration=round(normrnd(summerlpsys_mean,summerlpsys_std));
                case 3;                    sys_duration=round(normrnd(autumnlpsys_mean,autumnlpsys_std));
                case 4;                    sys_duration=round(normrnd(winterlpsys_mean,winterlpsys_std));
            end
        end
    else sys_duration=sys_duration-1; % if pressure system hasn't finished yet, reduce the count by an hour.
    end
    
    % determine which markov chain to use for the future weather
    switch current_season; %switch the season, query the pressure
        case 1 % spring
            if pressure_sys==0;future_weather_markov=cum_springlp_prob; %if it is low pressure, use the spring low pressure transition probability matrix
            else future_weather_markov=cum_springhp_prob; % else use the spring high pressure transition probabilit matrix
            end
        case 2 % repeat for the reast of the seasons. summer
            if pressure_sys==0;future_weather_markov=cum_summerlp_prob;else future_weather_markov=cum_summerhp_prob;end
        case 3 % autumn
            if pressure_sys==0;future_weather_markov=cum_autumnlp_prob;else future_weather_markov=cum_autumnhp_prob;end
        case 4 % winter
            if pressure_sys==0;future_weather_markov=cum_winterlp_prob;else future_weather_markov=cum_winterhp_prob;end
    end
    
    %select the morning markov chain when hour number is 1-5am
    if hour_number<6; % if the hour is 1--5
        switch current_season; %determine the season and...
            case 1 ;                future_weather_markov=cum_morningspring_prob; %...select the appropriate morning seasonal transition probability matrix
            case 2 ;                future_weather_markov=cum_morningsummer_prob; % and repeat for each season.
            case 3 ;                future_weather_markov=cum_morningautumn_prob;
            case 4 ;                future_weather_markov=cum_morningwinter_prob;
        end
    end
    
    % select the appropriate markov chain for wind speed and cloud height depending on the season
    switch current_season; %switch the season and....
        case 1;            wind_start=cum_wind_spring_prob;cloud_height_start=cum_cloudheight_spring_prob; %... select the appropriate transition probability matrices.
        case 2;            wind_start=cum_wind_summer_prob;cloud_height_start=cum_cloudheight_summer_prob; % repeat for each season.
        case 3;            wind_start=cum_wind_autumn_prob;cloud_height_start=cum_cloudheight_autumn_prob;
        case 4;            wind_start=cum_wind_winter_prob;cloud_height_start=cum_cloudheight_winter_prob;
    end
    
    %select appropriate pressure markov chain
    if pressure_sys==0; %if pressure system is currently below average...
        Pressure_markov=cum_PBAmarkov_prob; %...select the below average markov chain
    else Pressure_markov=cum_PAAmarkov_prob;%... else select the above average markov chain
    end
    
    %Determine the future states using the appropriately selected transition probability matrices.
    future_cloud_height=1+sum(cloud_height_start(current_cloud_height,:)<rand); %matrix(current,all)<rand  turns all values in that row to a 1 or 0. the sum of that row then gives an indicative column, which is then the future system, as the columns and rows are discreet values for each variable.
    future_weather_okta=1+sum(future_weather_markov(current_weather_okta,:)<rand); %see the paper eq.10 for a better explanation
    future_wind_speed=1+sum(wind_start(current_wind_speed,:)<rand);
    future_pressure=1+nansum(Pressure_markov(current_pressure,:)<rand);
    
    % update the timing structures.
    hour_number=hour_number+1; %increase the hour_number by one on each iteration
    if hour_number==25; % if this hour number exceeds 25, reset it back to 1.
        hour_number=1;
        day_number=day_number+1;
        
        %once the day has been reset, check if it is the end of the year.
        if weather_record(hour,2)==days_in_year %if the new day is equal to the number of days in the year...
            day_number=1; %reset the day number
            hour_number=1; %reset the hour number
            %                 disp(['  Year ',num2str(year),' Complete']) %advise user that a year is complete. %reintroduce if you wish to see this information
            year=year+1; %update the year count.
        end
    end
end %and repeat until the simulation is complete
% if num_of_years >= 1.8;disp(['  Year ',num2str(year),' complete']);end %display to command window that the year is complete

%% Irradiance Calculations
disp('4)Calculating Baseline Irradiance') %inform the user that the irradiance calculations are being undertaken.

% calculate solar angles and timings - using Muriel-Blanco algorithm
disp('   -calculating solar angles and timings');
julian_day = (0:num_of_days*24*60-1)/(24*60)+2455927.5-1/48; % Julian day for every minute, starting at 23:30 on 31/12/2011, ending on
n = julian_day - 2451545;
Omega = 2.1429 - 0.0010394594 * n;
L = 4.8950630 + 0.017202791698 * n;
g = 6.2400600 + 0.0172019699 * n;
l = L + 0.03341607 * sin(g) + 0.00034894 * sin(2*g) - 0.0001134 - 0.0000203 * sin(Omega);
ep = 0.4090928 - 6.2140e-9 * n + 0.0000396 * cos(Omega);
ra = mod(atan2(cos(ep).*sin(l),cos(l)),2*pi);
delta = asin(sin(ep).*sin(l));
gmst = 6.6974243242 + 0.0657098283 * n + mod(hour_x'-2,24);
lmst = (gmst*15 + longitude)*pi/180;
hour_angle = lmst-ra;
theta_z = acos(cosd(latitude)*cos(hour_angle).*cos(delta)+sin(delta)*sind(latitude));
Parallax = 6371.01/149597890 * sin(theta_z);
zenith_angle = (theta_z + Parallax)*180/pi;
elevation = 90-zenith_angle;
azimuth = atan(-sin(hour_angle)./(tan(delta).*cosd(latitude) - sind(latitude).*cos(hour_angle)));
incident_angle=real(acosd(sind(zenith_angle).*sind(panel_pitch).*cosd(panel_azimuth-azimuth)+cosd(zenith_angle).*cosd(panel_pitch)))';
incident_angle=incident_angle';

Hammer_Upscale=ones(length(season_record),1).*1.0;
Hammer_Upscale(season_record==3)=1.045;
Hammer_Upscale(season_record<3)=0.995;
% Hammer_Upscale = 1; %1.045
% There is a difference between the clear-sky values generated by the
% Hammer algorithm and by the radiative transfer code, by a factor of
% 1.047 in summer and 1.043 in winter. As the values of k_c were generated
% using the raditive transfer model, multiplying back by the lower Hammer
% value will lead to an underestimate of the all-sky irradiance. Therefore,
% for the purposes of validating the model, the Hammer_Upscale factor is a
% multiplier for clear-sky irradiance. It is not a fudge factor in the true
% sense of the word, as they just represent different methods of
% calculating the clear-sky irradiance. The Hammer algorithm has been used
% because it is flexible and easy to code in Matlab, whereas using the
% radiative transfer solver would require calculating minutely clear sky
% irradiances in an external program which takes several hours to run, and
% every time you wanted to investigate a new place you would have to re-run
% the RT model.

% Hammer clearsky algorithm
disp('   -calculating clear sky global horizontal irradiance');
eccentricity = 1 + 0.03344*cos(2*pi*day/365.25 - 0.048869);  % from Suri 2004 - I prefer this def.
solar_constant = 1367*eccentricity;
clear eccentricity
airmass = zeros(1,length(month_record));
airmass(zenith_angle<=90) = (1 - height_above_sea_level/10000)*((cosd(zenith_angle(zenith_angle<=90))+0.50572*(96.07995-zenith_angle(zenith_angle<=90)).^(-1.6364)).^(-1));
airmass(zenith_angle>90)=Inf;
Rayleigh=zeros(length(solar_constant),1);
Rayleigh(airmass<20) = 1./(6.6296+1.7513*airmass(airmass<20)-0.1202*airmass(airmass<20).^2+0.0065*airmass(airmass<20).^3-0.00013*airmass(airmass<20).^4);
Rayleigh(airmass>=20) = 1./(10.4+0.718*airmass(airmass>=20));

disp('   -applying Linke Turbidity');
% get values from TIF file of Linke turbidities
% to keep memory as free as possible we will delete variables as soon as they become unnecessary and only save the lon/lat point of interest
lat_index=round((-latitude+1/24+90)*4320/360); %round the lattitude
lon_index = round((longitude+1/24+180)*4320/360); %round the longitude
LinkeTurbidity2=zeros(12,1);%pre allocate array with space for each month
tiffData = Tiff('supportingfiles/linke/January.tif','r'); %extract the linke turbidity data for the UK for January
loadup = single(tiffData.read())/20; %create large array of the data.
LinkeTurbidity2(1)=loadup(lat_index,lon_index); %extract the appropriate linke turbidity value for that latitude and longitude and place in array
clear loadup %clear the loadup data to save space
tiffData.close(); %close the tiff data
%repeat this process for each month
tiffData = Tiff('supportingfiles/linke/February.tif','r');  loadup = single(tiffData.read())/20; LinkeTurbidity2(2)=loadup(lat_index,lon_index); clear loadup; tiffData.close();
tiffData = Tiff('supportingfiles/linke/March.tif','r');     loadup = single(tiffData.read())/20; LinkeTurbidity2(3)=loadup(lat_index,lon_index); clear loadup; tiffData.close();
tiffData = Tiff('supportingfiles/linke/April.tif','r');     loadup = single(tiffData.read())/20; LinkeTurbidity2(4)=loadup(lat_index,lon_index); clear loadup; tiffData.close(); 
tiffData = Tiff('supportingfiles/linke/May.tif','r');       loadup = single(tiffData.read())/20; LinkeTurbidity2(5)=loadup(lat_index,lon_index); clear loadup; tiffData.close();
tiffData = Tiff('supportingfiles/linke/June.tif','r');      loadup = single(tiffData.read())/20; LinkeTurbidity2(6)=loadup(lat_index,lon_index); clear loadup; tiffData.close();
tiffData = Tiff('supportingfiles/linke/July.tif','r');      loadup = single(tiffData.read())/20; LinkeTurbidity2(7)=loadup(lat_index,lon_index); clear loadup; tiffData.close();
tiffData = Tiff('supportingfiles/linke/August.tif','r');    loadup = single(tiffData.read())/20; LinkeTurbidity2(8)=loadup(lat_index,lon_index); clear loadup; tiffData.close(); 
tiffData = Tiff('supportingfiles/linke/September.tif','r'); loadup = single(tiffData.read())/20; LinkeTurbidity2(9)=loadup(lat_index,lon_index); clear loadup; tiffData.close(); 
tiffData = Tiff('supportingfiles/linke/October.tif','r');   loadup = single(tiffData.read())/20; LinkeTurbidity2(10)=loadup(lat_index,lon_index); clear loadup; tiffData.close();
tiffData = Tiff('supportingfiles/linke/November.tif','r');  loadup = single(tiffData.read())/20; LinkeTurbidity2(11)=loadup(lat_index,lon_index); clear loadup; tiffData.close();
tiffData = Tiff('supportingfiles/linke/December.tif','r');  loadup = single(tiffData.read())/20; LinkeTurbidity2(12)=loadup(lat_index,lon_index); clear loadup; tiffData.close();
clear tiffData %clear all the tiff data.

diffuse_horizontal_cs = Hammer_Upscale .* solar_constant.*(0.0065 + (-0.045 + 0.0646.*LinkeTurbidity2(month_record)).*cosd(zenith_angle') + (0.014-0.0327.*LinkeTurbidity2(month_record)).*cosd(zenith_angle').^2);
diffuse_horizontal_cs(diffuse_horizontal_cs<0)=0;
direct_horizontal_cs  = Hammer_Upscale .* solar_constant.*exp(-0.8662.*LinkeTurbidity2(month_record).*Rayleigh.*airmass').*cosd(zenith_angle');
direct_horizontal_cs(direct_horizontal_cs==0)=0;
direct_horizontal_cs(isnan(direct_horizontal_cs))=0;
global_horizontal_cs  = direct_horizontal_cs+diffuse_horizontal_cs;


%Start of the KC minutely code.
disp('5)Calculating minutely Kc values') %inform the user that the Kc calculations are being undertaken.

okta_hourly = weather_record(:,5);%extract the hourly okta value from the weather record
diffs = [0 diff(sun_obscured')]; %calculate the difference between 0 and 1,0)
cloudover = find(diffs==-1); %find the number of clouded mins
clearup = find(diffs==1); %find the number of clear mins
kcMinutely=zeros(numel(sun_obscured),1); %pre allocate space

% Select clear and cloudy properties for each day from appropriate distribution
hours = numel(okta_hourly); %total number of hours (this is a redefined variable overwriting previous)
days = hours/24; %number of days
season_hrly=weather_record(:,4); %hourly record of the season
obscured_hrly=zeros(hours,1); %pre allocate the hourly obscured array

resolution=6; %must be a factor of 60  1,2,3,4,5,6,10,12,15,20,30,60. Discussed in paper, This could be improved by allowing a flexible feature to this. This allows fluxes every 6 mins.
shift_factor=60/resolution; %used in indexing.
obscured_factored=zeros(hours*shift_factor,1); %pre allocate memory
for i=1:length(okta_hourly) % loop through each hour
    okta_factored(i*shift_factor-(shift_factor-1):i*shift_factor)=okta_hourly(i);    %okta factored is the okta value every 6 mins.
end
for i=1:length(season_hrly)
    season_factored(i*shift_factor-(shift_factor-1):i*shift_factor)=season_hrly(i);    %season factored is the season repeated every 6 mins
end

obscured_min=zeros(hours*60,1); %pre allocate memory
not_obscured_min=zeros(hours*60,1); %pre allocate memory

% Pick cloud obscurity from the appropriate distribution
obscured_factored(okta_factored<=6) = normrnd(0.6784, 0.2046, numel(okta_factored(okta_factored<=6)),1); %for okta of <=6, choose a kc from the normal distribution of mean 0.6784 and stddev 0.2046
obscured_factored(okta_factored==7) = wblrnd(0.557736, 2.40609, numel(okta_factored(okta_factored==7)),1); %as above but for okta 7 and using weibul distribution
obscured_factored(okta_factored>=8) = gamrnd(3.5624, 0.08668, numel(okta_factored(okta_factored>=8)),1); %as above but for okta 8 and using gamma distribution
disp('   -extracting kc values from okta-based distributions');
% Ensure sun_obscured hourly does not exceed 1
while numel(obscured_factored(obscured_factored>1))>0 % limited obscured kc value to 1. if it is, re select from the okta 8 distribution.
    obscured_factored(obscured_factored>1)=gamrnd(3.5624, 0.08668, numel(obscured_factored(obscured_factored>1)), 1); %re select using okta 8 distribution
end

for i=1:length(obscured_factored)-1; %for every 6 mins in the simulation...
    obscured_min(i*resolution-(resolution-1):i*resolution)=linspace(obscured_factored(i),obscured_factored(i+1),resolution); %a minutely resolution is the linear spaced minutely values from one kc to the next.
end

% Pick clearsky minutes from a normal distribution - one from each day (variation takes into account changes in atmospheric turbidity, etc)
not_obscured = normrnd(0.99,0.08,days,1); % when the sky is not obscured, the kc value is taken from a normal distribution of mean 0.99 and std dev 0.08.

% Populate minutely kc value with appropriate value. Kc minutely is a vector containing every minute's kc value which will be used to calculate the panel irradiance.
kcMinutely(sun_obscured==1) = obscured_min(sun_obscured==1); %when the sun is obscured, apply the kc values from the obscured periods.
kcMinutely(sun_obscured==0) = not_obscured_min(sun_obscured==0); %when the sun is not obscured, apply the kc values for clear sky.
kcMinutely(sun_obscured==0) = not_obscured(ceil(find(sun_obscured==0)/1440));

kcMinutely(sun_obscured==1) = kcMinutely(sun_obscured==1) .* normrnd(1, 0.01+0.003*okta_minutely(sun_obscured==1)'); %apply a gaussian white noise multiplier based on the hourly okta for both clear and cloudy moments
kcMinutely(sun_obscured==0) = kcMinutely(sun_obscured==0) .* normrnd(1, 0.001+0.0015*okta_minutely(sun_obscured==0)'); % see eq 12 and 13 in the paper.

%For long periods of okta 0, apply a smoothing.
disp('   -reanalysis of extended stable okta periods');
Period_of_Ok0=zeros(length(okta_minutely),1); %pre allocate memory
for i=2:length(okta_minutely)-1; %go through the okta minutely
    if okta_minutely(i)==0 && okta_minutely(i+1)==0 && okta_minutely(i-1)~=0; %if this hour is the start of an okta 0 period...
        Period_of_Ok0(i)=1; %.. indicate this with  a 1.
    end
    if okta_minutely(i)==0 && okta_minutely(i-1)==0 && okta_minutely(i+1)~=0; %if its the end of an okta 0 period...
        Period_of_Ok0(i)=2; %...indicated with a 2
    end
    %now in format.. 00000100000002000000010002000000000100200000010000002 with a value for each minute
end
Ok0_duration=1; %this is the variable of the running tally of the clear sky duration
ok0_cutoff=3.5; %set the cutoff period in hours. and so if the period is >ok0_cutoff etc.
for i=1:length(Period_of_Ok0)-1 %loop through every minute
    if Period_of_Ok0(i)==1 %if this is the start of an okta 0 period, as defined in previous loop.
        if i+Ok0_duration==numel(Period_of_Ok0);break; end %if this is the end of the array, break the search. (important as will casue errors in indexing if this break is not here)
        while Period_of_Ok0(i+Ok0_duration)~=2; %while the period of okta 0 is continuing...
            Ok0_duration=Ok0_duration+1; %...keep a running tally of the duration
            if i==numel(Period_of_Ok0); break; end %if its the end of the array, break the search
            if i+Ok0_duration==numel(Period_of_Ok0);break; end %if it is the end of the array, break the search.
        end
    end
    if Ok0_duration>=ok0_cutoff*60; %if the duration is at least X hours or more...
        kcMinutely(i:i+Ok0_duration)= normrnd(1,0.0015,Ok0_duration+1,1);  %...adjust the hourly kc to go between the two linearly
    end
    Ok0_duration=1; %reset the duration tally variable
end

%  for long periods of Ok8. REPEAT OF ABOVE, BUT FOR Okta 8.
Ok8_ind=zeros(length(okta_minutely),1);
for i=2:length(okta_minutely)-1;
    if okta_minutely(i)==8 && okta_minutely(i+1)==8 && okta_minutely(i-1)~=8;        Ok8_ind(i)=1;    end
    if okta_minutely(i)==8 && okta_minutely(i-1)==8 && okta_minutely(i+1)~=8;        Ok8_ind(i)=2;    end
end
Ok8_duration=1;
ok8_cutoff=5; %the okta 8 cutoff period
intervals=ok8_cutoff*4; %20 intervals across any length of Ok8. For 5 hours, there would be 15 minute kc fluxes, for 10 hours the kc flux would be 30 mins.
for i=1:length(Ok8_ind)-1
    if Ok8_ind(i)==1 %if this is the start of an okta 8 period
        if i+Ok8_duration==numel(Ok8_ind);break; end %if its the end of the array, break the for loop
        while Ok8_ind(i+Ok8_duration)~=2; %while the period of okta 8 continues
            Ok8_duration=Ok8_duration+1; %keep tally of the duration
            if i==numel(Ok8_ind); break; end %if its the end of the array, break the while
            if i+Ok8_duration==numel(Ok8_ind);break; end %if its the end of the array, break the while
        end
    end
    if Ok8_duration>=ok8_cutoff*60; %if the duration is at least X hours or more.
        %instead of a straight linear between the start and end period (very much not the case in real life), there are a fixed amount of intervals between kc values for the whole duration of okta 8.
        %for example. there are 20 intervals irregardless of duration.
        els=zeros(1+intervals,1); %make blank array of each hour plus the start hour
        for j=2:length(els); %loop through each hour in els.
            els(j)=ceil(Ok8_duration*((j-1)/intervals)); %find the element row reference to split the moment into sections (e.g.  to split 1 hour into 4 would be 1:15, 16:30, 31:45, 46:60)
        end
        for j=1:length(els)-1;
            kcMinutely(i+els(j):i+els(j+1))=linspace(kcMinutely(i+els(j)),kcMinutely(i+els(j))*normrnd(1,0.1),els(j+1)-els(j)+1); %update the kcminutely in the appropraite place with linearly spaced kc values with small flux.
        end
        fluxes=roundn(rand(intervals,1),-1); %fluxes is a series of random values for the random fluxes during clouded periods (similar to the gausian noise multiplier, however is less erratic, more smoothed like in real data)
        gap=ceil(Ok8_duration/intervals); %determine the length of each gap between kc values (currently a zig zag of straight linearly spaced values)
        flux_min=zeros(length(Ok8_duration),1); %pre allocate memory
        for k=1:length(fluxes); %loop through the lengh of fluxes
            flux_min(k*gap-(gap-1):k*gap,1)=fluxes(k,1); %produce a minutely resolution array of fluxes, called flux min. with "interval" sized constants of each random value of fluxes.
        end
        for k=1:length(flux_min); %apply increasing erratic fluxes based on the random value in fluxes
            if flux_min(k,1)<0.4 %if the random value assigned is <0.4....
                flux_min(k,2)=1+abs(normrnd(0,0.005)); %apply fluxes with a tiny std dev. (and so 40% of the time, a small flux is seen). This is abs to add a curved nature to the deviations
            elseif flux_min(k,1)<0.7 % else if it is less than 0.7
                flux_min(k,2)=1+abs(normrnd(0,0.03)); %and so 30% of the time, a std dev of 0.03 is used.
            else flux_min(k,2)=1+abs(normrnd(0,0.05));% else the other 30% of the time a std dev of 0.05 is used. So for each gap, white noise is applied during long overcast periods.
            end
        end
        
        kcMinutely(i:i+Ok8_duration)=kcMinutely(i:i+Ok8_duration).*flux_min(:,2);% implement the random fluctuations to thekcMinutely code
        
    end
    Ok8_duration=1; %reset the duration and loop again.
end

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

disp('   -determining cloud edge reflection chance');
%Add irradiance peaks at moment of cloud shift, as observed in data. Increased reflected irradiance
%observed in observational data is a peak in irradiance just before and after a moment of cloud, this is due to increase reflected beam irradiance.
% to attempt to recreate this, fluxes based on a normrand distribution are applied to the minute before and after a cloud, limited to a chance  defined as:
chance=0.40;% 40% of the time, this will be applied
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
disp('   -applying Kc values to baseline irradiance');
global_horizontal = kcMinutely .* global_horizontal_cs;
direct_horizontal = zeros(numel(sun_obscured),1);
direct_horizontal(kcMinutely < 1 & kcMinutely > 19/69) = direct_horizontal_cs(kcMinutely < 1 & kcMinutely > 19/69) .* (kcMinutely(kcMinutely < 1 & kcMinutely > 19/69) - 0.38*(1 - kcMinutely(kcMinutely < 1 & kcMinutely > 19/69))).^(2.5);
direct_horizontal(kcMinutely>=1) = direct_horizontal_cs(kcMinutely>=1);
direct_horizontal(direct_horizontal<0)=0;
global_horizontal(global_horizontal<0)=0;
diffuse_horizontal = global_horizontal - direct_horizontal;
diffuse_to_global_ratio=diffuse_horizontal./global_horizontal;

% Panel irradiance - using Klucher model -calculate on any arbitraray plane
% from diffuse, hz and ghz and angles.
F=1-(diffuse_horizontal./global_horizontal).^2; % modulating factor
isotropic=(1+cosd(panel_pitch))/2;
horizonal=(1+F.*(sind(panel_pitch)/2).^3);
circumsol = (1 + F .* (cosd(incident_angle')).^2 .* (sind(zenith_angle')).^3);
panel_irradiance = diffuse_horizontal.*isotropic.*horizonal.*circumsol + direct_horizontal./cosd(zenith_angle').*cosd(incident_angle');
% take account of night
panel_irradiance = (panel_irradiance > 0).*panel_irradiance;

disp('------------------------------------');
disp('Complete');
%% Plots and figures
disp('Producing plots and figures')
%example plot 1 showing the irradiance.
r=0.9*rand; %random variable
rday=round(r*num_of_days); %select a random day from those simulated
dayofyear=rday-floor(rday/365)*365; % determine what day of the year this is (instead of day 730, this would be 365)
xstart=rday*24*60; %determine the start minute
xend=xstart+1440; %determine the end minute
yticks=[0,1]; %set the ytick locations for subplot2
ytickslabels={' ',' '}; %set the labels for subplot2
xticks=[0,60*4,60*8,60*12,60*16,60*20,1440]; %set the x tick locations
xtickslabels={'0','4','8','12','16','20','24'}; %set the xaxis labels for subplot 1
xxticks=[0,4,8,12,16,20,24]; %set the x tick labels for sub plot 2 and 3
yyticks=[0,3,6,9]; %set the y tick locations for subplot 1
okta_hourly(okta_hourly==10)=0; %alter back an okta of 10 to 0. 10 was used in simulation for indexing

figure(1); %begin figure 1
subplot(3,1,1) %create the first of 3 subplots. subplot(rows,cols,ref)
bar(okta_hourly((xstart/60)+2:24+(xstart/60)),'blue','BarWidth', 0.5) %make a bar of the okta number in blue with half width
ylabel('Okta Number') %label y axis
axis([0 24 0 9]) %set limits
set(gca,'YTick',yyticks,'XTick',xxticks,'XTickLabel',xtickslabels); %set the y and x ticks and labels.
v = axis; %set the axis
handle=title('a)'); %give it a label
set(handle,'Position',[2 v(4)*1.05 0]); %set axis location so that the title a) is in appropriate place

subplot(3,1,2) %subplot 2. 
bar(sun_obscured(xstart:xend),'black','BarWidth', 1) %make solid black bar plot of cloud cover
ylim([-0.25 1.25]) %set the y limits for asthetics
xlim([0 1440]) %set x limits
set(gca,'YTick',yticks,'YTickLabel',ytickslabels,'XTick',xticks,'XTickLabel',xtickslabels) %set the x and y ticks and labels
ylabel('Cloud Cover') % label the y axis
legend('cloud') % add a legend.
v = axis; %set the axis
handle=title('b)'); %give it a label
set(handle,'Position',[120 v(4)*1.05 0]); %set axis location so that the title b) is in appropriate place

subplot(3,1,3) %subplot 3
plot(panel_irradiance(xstart:xend),'r') %red line of panel irradiance
xlim([0 1440]) %set x axis limits
set(gca,'XTick',xticks,'XTickLabel',xtickslabels) %set the x axis ticks and labels
ylabel('Irradiance (Wm^-^2)') %label y axis
xlabel(['Hours of day number ',num2str(dayofyear)]); %label x axis with day of year included
v = axis; %set the axis
handle=title('c)'); %give it a label
set(handle,'Position',[120 v(4)*1.05 0]); %set axis location so that the title c) is in appropriate place



toc %switch off the timer and report the elapsed time



