%% Time Logic
disp('Setting time logic')
temporal_resolution_of_input_data = 1; % hours
time=datenum(start_day,'ddmmyyyy'):temporal_resolution_of_input_data/24:datenum(end_day,'ddmmyyyy')-(temporal_resolution_of_input_data/24);
t_res=60; % temporal resolution in mins
time_datevecs=datevec(time);
years=time_datevecs(:,1);
months=time_datevecs(:,2);
days=time_datevecs(:,3);
hours_of_day=time_datevecs(:,4);
num_of_days=length(datenum(start_day,'ddmmyyyy'):datenum(end_day,'ddmmyyyy'));

time_1min_resolution=datenum(start_day,'ddmmyyyy'):1/1440:datenum(end_day,'ddmmyyyy')-(1/1440);
time_1min_datevecs=datevec(time_1min_resolution);
hours_1min=time_1min_datevecs(:,4);
mins_1min=time_1min_datevecs(:,5);
% Produce indices of seasons
seasons(months==3 | months==4 | months==5)=1;
seasons(months==6 | months==7 | months==8)=2;
seasons(months==9 | months==10 | months==11)=3;
seasons(months==12 | months==1 | months==2)=4;