%% extract Coefficients of KC distributions from Smith et al. 2017 inclusive of further extrapolation
filename = 'F:\PhD\DATA\DEMROES\Temporalvalidation\supportingfiles\coefficients.csv';
delimiter = ',';
startRow = 2;
formatSpec = '%s%f%f%s%f%f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);

coeff.obstype = dataArray{1,1}; %manual, auto observation reference
coeff.okta1 = dataArray{1,2}; % okta reference
coeff.elevmin =  dataArray{1,3}; %elevation reference
coeff.disttype =  dataArray{1,4}; % distribution type (burrIII or generalised Gamma)
coeff.scale =  dataArray{1,5}; % parameters
coeff.shape1 =  dataArray{1,6};
coeff.shape2 =  dataArray{1,7};

%% set constants for kc-distribution application
okta_hourly = weather_record(:,5);%extract the hourly okta value from the weather record
u_hourly=weather_record(:,10);%extract the hourly cloud speed data
hours = numel(okta_hourly); %total number of hours (this is a redefined variable overwriting previous)
days = hours/24; %number of days
L=3600; % a constant in determining the resolution of which the spline'd line will be applied
kc_residual=0; %the start residual value for the clear sky, it is used in first loop.
xx=1:1:temporal_res*hours; % length of simulation in minutes, used in spline function
Y=0.5; % pre allocation is too variable, so is redefined each iteration. Inefficient but practical.
x=0.5; % pre allocation is too variable, so is redefined each iteration. Inefficient but practical.
distribution_range=0.01:0.01:2; %select range to draw distributions from. if started at 0, Nan would be given and would disrupt future script. 2 is a contingency and highly rare except at low zeniths.
okta_hourly(okta_hourly==10)=0; %return all okta 0 moments to be represented by 0, not 10.
