%% Construct Markov chains from NCEP Reanalysis data
disp('Constructing Markov transition matrices')

%% pre allocation or markov chains and intermediate variables
seasons_for_markov=zeros(size(cloud_amount));
markov_case=zeros(size(cloud_amount)).*NaN;
springlp=zeros(cloud_amount_range);
springhp=zeros(cloud_amount_range);
summerlp=zeros(cloud_amount_range);
summerhp=zeros(cloud_amount_range);
autumnlp=zeros(cloud_amount_range);
autumnhp=zeros(cloud_amount_range);
winterlp=zeros(cloud_amount_range);
winterhp=zeros(cloud_amount_range);
morningspring=zeros(cloud_amount_range);
morningsummer=zeros(cloud_amount_range);
morningautumn=zeros(cloud_amount_range);
morningwinter=zeros(cloud_amount_range);
wind_spring=zeros(wind_speed_range);
wind_summer=zeros(wind_speed_range);
wind_autumn=zeros(wind_speed_range);
wind_winter=zeros(wind_speed_range);
pressure_markov=zeros(pressure_range);
cloud_height_spring=zeros(cloud_height_range);
cloud_height_summer=zeros(cloud_height_range);
cloud_height_autumn=zeros(cloud_height_range);
cloud_height_winter=zeros(cloud_height_range);

%% Define the seasons.
months_for_markov=months;
%   Seasons are defined simplistically as
%   Spring=Mar to May. Summer=Jun to Aug.
%   Autumn=Sept to Nov. Winter=Dec to Feb
% whilst spring summer autumn and winter are northern hemisphere timings,
% and not all areasa have 4 seasons, the arbitrary separation of the year
% into 4 quarters will still produce meaningful differences
seasons_for_markov(months_for_markov==3 | months_for_markov==4 | months_for_markov==5)=1;
seasons_for_markov(months_for_markov==6 | months_for_markov==7 | months_for_markov==8)=2;
seasons_for_markov(months_for_markov==9 | months_for_markov==10 | months_for_markov==11)=3;
seasons_for_markov(months_for_markov==12 | months_for_markov==1 | months_for_markov==2)=4;

%% Markov case
%Assign a case number in order to populate the correct Markov Table. these cases will be used as a reference.
% Calculate the average pressure from the pressure input file.
% There will be 8 markov cases for each season and above and below pressure
markov_case(seasons_for_markov==1 & pressure<pressure_avg)=1; %spring low pressure etc.
markov_case(seasons_for_markov==1 & pressure>pressure_avg)=2;
markov_case(seasons_for_markov==2 & pressure<pressure_avg)=3;
markov_case(seasons_for_markov==2 & pressure>pressure_avg)=4;
markov_case(seasons_for_markov==3 & pressure<pressure_avg)=5;
markov_case(seasons_for_markov==3 & pressure>pressure_avg)=6;
markov_case(seasons_for_markov==4 & pressure<pressure_avg)=7;
markov_case(seasons_for_markov==4 & pressure>pressure_avg)=8;

%% Derive the transition matrices
% offset the cloud_amount by an hour, so column 1 is the previous cloud_amount and column 2 is the latter cloud_amount
cloud_amount_transitions=[cloud_amount(1:end-1),cloud_amount(2:end)];

for i=1:length(cloud_amount_transitions)
    %if a legitimate transition occured and is not showing NaN values.
    if sum(~isnan(cloud_amount_transitions(i,:)))==2
        % make a conversion from cloud_amount to index. This is reversed in
        % the simulation.
        previous=cloud_amount_transitions(i,1)-cloud_amount_min+1;
        current=cloud_amount_transitions(i,2)-cloud_amount_min+1;
        
        switch markov_case(i) %switch to the appropriate transition probability matrix
            case 1 %spring low pressure
                %tally/populate the markov chain in appropriate place
                springlp(previous,current)= springlp(previous,current)+1;
            case 2 %spring high presusre
                springhp(previous,current)= springhp(previous,current)+1;
            case 3 %summer low pressure
                summerlp(previous,current)= summerlp(previous,current)+1;
            case 4 %summer high pressure
                summerhp(previous,current)= summerhp(previous,current)+1;
            case 5 %autumn low pressure
                autumnlp(previous,current)= autumnlp(previous,current)+1;
            case 6 %autumn high pressure
                autumnhp(previous,current)= autumnhp(previous,current)+1;
            case 7 %winter low pressure
                winterlp(previous,current)= winterlp(previous,current)+1;
            case 8 %winter high pressure
                winterhp(previous,current)= winterhp(previous,current)+1;
        end
    end
end

%% kick out a warning message if there are too few observed transitions in the data
% total nummber of observations within each markov frequency array
obsv_springlp=sum(sum(springlp),2);
obsv_summerlp=sum(sum(summerlp),2);
obsv_autumnlp=sum(sum(autumnlp),2);
obsv_winterlp=sum(sum(winterlp),2);
obsv_springhp=sum(sum(springhp),2);
obsv_summerhp=sum(sum(summerhp),2);
obsv_autumnhp=sum(sum(autumnhp),2);
obsv_winterhp=sum(sum(winterhp),2);
report=[obsv_springlp;obsv_summerlp;obsv_autumnlp;obsv_winterlp;obsv_springhp;obsv_summerhp;obsv_autumnhp;obsv_winterhp];
if min(report)<250
    disp(['WARNING: too few observations - potentially inaccurate markov chains',1]);
end

%% make a markov chain for the morning (between 1-6am)
hours_for_markov=days;
seasons_before_6am=seasons_for_markov(hours_for_markov<=6);
cloud_amount_before_6am=cloud_amount(hours_for_markov<=6);
cloud_amount_before_6am_transitions=[cloud_amount_before_6am(1:end-1),cloud_amount_before_6am(2:end)];
%separate the cloud_amount number by season
for i=1:length(cloud_amount_before_6am_transitions)
    % if there is data in the tranasition
    if sum(~isnan(cloud_amount_before_6am_transitions(i,:)))==2
        %find the markov element to populate
        previous=cloud_amount_before_6am_transitions(i,1)-cloud_amount_min+1;
        current=cloud_amount_before_6am_transitions(i,2)-cloud_amount_min+1;
        % switch the season and populate the markov chain
        switch seasons_before_6am(i+1)
            case 1
                  morningspring(previous,current)=morningspring(previous,current)+1;
            case 2
                   morningsummer(previous,current)=morningsummer(previous,current)+1;    
            case 3
                   morningautumn(previous,current)=morningautumn(previous,current)+1;    
            case 4
                   morningwinter(previous,current)=morningwinter(previous,current)+1;    
        end        
    end    
end

%% make transition matrices for wind speed
wind_speed_transitions=[wind_speed(1:end-1),wind_speed(2:end)];
%separate the cloud_amount number by season
for i=1:length(wind_speed_transitions)
    % if there is data in the tranasition
    if sum(~isnan(wind_speed_transitions(i,:)))==2
        %find the markov element to populate
        previous=wind_speed_transitions(i,1)-wind_speed_min+1;
        current=wind_speed_transitions(i,2)-wind_speed_min+1;
        % switch the season and populate the markov chain
        switch seasons_for_markov(i+1)
            case 1
                  wind_spring(previous,current)=wind_spring(previous,current)+1;
            case 2
                   wind_summer(previous,current)=wind_summer(previous,current)+1;    
            case 3
                   wind_autumn(previous,current)=wind_autumn(previous,current)+1;    
            case 4
                   wind_winter(previous,current)=wind_winter(previous,current)+1;    
        end        
    end    
end

%% make transition matrices for cloud height
cloud_height_transitions=[cloud_base_height(1:end-1),cloud_base_height(2:end)];
%separate the cloud_amount number by season
for i=1:length(cloud_height_transitions)
    % if there is data in the tranasition
    if sum(~isnan(cloud_height_transitions(i,:)))==2
        %find the markov element to populate
        previous=cloud_height_transitions(i,1)-cloud_height_min+1;
        current=cloud_height_transitions(i,2)-cloud_height_min+1;
        % switch the season and populate the markov chain
        switch seasons_for_markov(i+1)
            case 1
                  cloud_height_spring(previous,current)=cloud_height_spring(previous,current)+1;
            case 2
                   cloud_height_summer(previous,current)=cloud_height_summer(previous,current)+1;    
            case 3
                   cloud_height_autumn(previous,current)=cloud_height_autumn(previous,current)+1;    
            case 4
                   cloud_height_winter(previous,current)=cloud_height_winter(previous,current)+1;    
        end        
    end    
end


%% Analyse the above average and below average Pressure for Markov chains
pressure_transitions=ceil([pressure(1:end-1),pressure(2:end)]);
% loop through each pressure transition
for i=1:length(pressure_transitions)
    if sum(~isnan(pressure_transitions(i,:)))==2
        previous=pressure_transitions(i,1)-pressure_min+1;
        current=pressure_transitions(i,2)-pressure_min+1;
        pressure_markov(previous,current)=pressure_markov(previous,current)+1;        
    end
end

%% Produce the cumulative probability distribution of each pressure and% season possibility
%This is done by dividing each state by the total number of times that state occured, or each tally is divided by the sum of the row.
%after this the table is turned into a cumulative sum using the cumsum(x,2)function

% seasonal high pressure
%find the transition probability as P_ij/P*_i. See paper 2.2 on Markov chain creation.
springhp_prob=springhp./(sum(springhp,2).*1); 
 %convert into cumulative sum, this results in 0.....1 across entire length of each row.
cum_springhp_prob=cumsum(springhp_prob,2);

% this process is repeated for each of the markov chains for each season/pressure etc..
summerhp_prob=summerhp./sum(summerhp,2); cum_summerhp_prob=cumsum(summerhp_prob,2);
autumnhp_prob=autumnhp./sum(autumnhp,2); cum_autumnhp_prob=cumsum(autumnhp_prob,2);
winterhp_prob=winterhp./sum(winterhp,2); cum_winterhp_prob=cumsum(winterhp_prob,2);
% seasonal low pressure
springlp_prob=springlp./sum(springlp,2); cum_springlp_prob=cumsum(springlp_prob,2);
summerlp_prob=summerlp./sum(summerlp,2); cum_summerlp_prob=cumsum(summerlp_prob,2);
autumnlp_prob=autumnlp./sum(autumnlp,2); cum_autumnlp_prob=cumsum(autumnlp_prob,2);
winterlp_prob=winterlp./sum(winterlp,2); cum_winterlp_prob=cumsum(winterlp_prob,2);
% produce morning markov chains for each season
morningspring_prob=morningspring./sum(morningspring,2); cum_morningspring_prob=cumsum(morningspring_prob,2);
morningsummer_prob=morningsummer./sum(morningsummer,2); cum_morningsummer_prob=cumsum(morningsummer_prob,2);
morningautumn_prob=morningautumn./sum(morningautumn,2); cum_morningautumn_prob=cumsum(morningautumn_prob,2);
morningwinter_prob=morningwinter./sum(morningwinter,2); cum_morningwinter_prob=cumsum(morningwinter_prob,2);
% produce wind speed markov chains for each season
wind_spring_prob=wind_spring./sum(wind_spring,2); cum_wind_spring_prob=cumsum(wind_spring_prob,2);
wind_summer_prob=wind_summer./sum(wind_summer,2); cum_wind_summer_prob=cumsum(wind_summer_prob,2);
wind_autumn_prob=wind_autumn./sum(wind_autumn,2); cum_wind_autumn_prob=cumsum(wind_autumn_prob,2);
wind_winter_prob=wind_winter./sum(wind_winter,2); cum_wind_winter_prob=cumsum(wind_winter_prob,2);
%pressure
pressure_markov_prob=pressure_markov./sum(pressure_markov,2); cum_pressure_markov_prob=cumsum(pressure_markov_prob,2);
% produce cloud height markov chains for each season
cloud_height_spring_prob=cloud_height_spring./(sum(cloud_height_spring,2)); cum_cloud_height_spring_prob=cumsum(cloud_height_spring_prob,2);
cloud_height_summer_prob=cloud_height_summer./(sum(cloud_height_summer,2)); cum_cloud_height_summer_prob=cumsum(cloud_height_summer_prob,2);
cloud_height_autumn_prob=cloud_height_autumn./(sum(cloud_height_autumn,2)); cum_cloud_height_autumn_prob=cumsum(cloud_height_autumn_prob,2);
cloud_height_winter_prob=cloud_height_winter./(sum(cloud_height_winter,2)); cum_cloud_height_winter_prob=cumsum(cloud_height_winter_prob,2);

