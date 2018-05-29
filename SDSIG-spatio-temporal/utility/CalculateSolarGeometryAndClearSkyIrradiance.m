%% Calculate solar geometry and clear-sky irradiance

% calculate solar angles and timings - using Muriel-Blanco algorithm
% All of this section is from Blanco-Muriel et al., 2001
% Solar Energy, 70(5), pp. 431-441.
disp('Calculating solar geoemetry using Blanco-Muriel (2001)')
julian_day = juliandate(time_1min_datevecs);
n = julian_day - 2451545;
Omega = 2.1429 - 0.0010394594 .* n;
L = 4.8950630 + 0.017202791698 .* n; % mean longitude_central
g = 6.2400600 + 0.0172019699 .* n; % mean anomaly
l = L + 0.03341607 .* sin(g) + 0.00034894 .* sin(2.*g) - 0.0001134 - 0.0000203 .* sin(Omega); % ecliptic longitude_central
ep = 0.4090928 - 6.2140e-9 .* n + 0.0000396 .* cos(Omega); % obliquity of the ecliptic
ra = mod(atan2(cos(ep).*sin(l),cos(l)),2*pi); % right ascension
delta = asin(sin(ep).*sin(l)); % declination - the usual meaning, but calculated from astronomical coordinates
gmst = 6.6974243242 + 0.0657098283 .* n + hours_1min +mins_1min./60 ; % GMT
lmst = (gmst.*15 + longitude_central).*pi/180; % local solar time
hour_angle = lmst-ra;
theta_z = acos(cosd(latitude_central).*cos(hour_angle).*cos(delta)+sin(delta).*sind(latitude_central)); % zenith
Parallax = 6371.01/149597890 .* sin(theta_z);
zenith_angle = (theta_z + Parallax).*180/pi; % adjustment to zenith due to parallax - use this one.
elevation = 90-zenith_angle; % elevation angle, i.e. complement of zenith
azimuth = atan(-sin(hour_angle)./(tan(delta).*cosd(latitude_central) - sind(latitude_central).*cos(hour_angle))); % azimuth angle of sun
incident_angle=real(acosd(sind(zenith_angle).*sind(panel_pitch_hrz).*cosd(panel_azimuth_hrz-azimuth)+cosd(zenith_angle).*cosd(panel_pitch_hrz))); % solar incident angle taking into account panel tilt and azimuth
eccentricity = 1 + 0.03344.*cos(2.*pi.*datevec2doy(time_1min_datevecs)./365.25 - 0.048869);
solar_constant = 1367.*eccentricity;

% Kasten airmass formula as a function of zenith angle
airmass = zeros(size(zenith_angle));
airmass(zenith_angle<=90) = (1 - height_above_sea_level_central./10000).*((cosd(zenith_angle(zenith_angle<=90))+0.50572.*(96.07995-zenith_angle(zenith_angle<=90)).^(-1.6364)).^(-1)); % Airmass as function of zenith angle, from Kasten and Young (1989) Applied Optics 28:47354738
airmass(zenith_angle>90)=Inf;

% Calculate Rayleigh optical depth as a function of airmass
Rayleigh=zeros(length(solar_constant),1);
Rayleigh(airmass<20) = 1./(6.6296+1.7513.*airmass(airmass<20)-0.1202.*airmass(airmass<20).^2+0.0065.*airmass(airmass<20).^3-0.00013.*airmass(airmass<20).^4);
Rayleigh(airmass>=20) = 1./(10.4+0.718.*airmass(airmass>=20));

disp('Extracting Linke turbidity');

if ~exist('supportingfiles\linke\LinkeTurbidity_Summary.mat','file')
    % Retrieve Linke Turbidity for nearest 1/12 degree grid square and month
    % from the SoDa monthly data files.
    % Conversion:Linke Turbidity = greyscale_value/20
    tiffData = Tiff('supportingfiles/linke/January.tif','r');   loadup = single(tiffData.read())/20; TL(:,:,1)=loadup; tiffData.close();
    tiffData = Tiff('supportingfiles/linke/February.tif','r');  loadup = single(tiffData.read())/20; TL(:,:,2)=loadup; tiffData.close();
    tiffData = Tiff('supportingfiles/linke/March.tif','r');     loadup = single(tiffData.read())/20; TL(:,:,3)=loadup; tiffData.close();
    tiffData = Tiff('supportingfiles/linke/April.tif','r');     loadup = single(tiffData.read())/20; TL(:,:,4)=loadup; tiffData.close();
    tiffData = Tiff('supportingfiles/linke/May.tif','r');       loadup = single(tiffData.read())/20; TL(:,:,5)=loadup; tiffData.close();
    tiffData = Tiff('supportingfiles/linke/June.tif','r');      loadup = single(tiffData.read())/20; TL(:,:,6)=loadup;  tiffData.close();
    tiffData = Tiff('supportingfiles/linke/July.tif','r');      loadup = single(tiffData.read())/20; TL(:,:,7)=loadup;  tiffData.close();
    tiffData = Tiff('supportingfiles/linke/August.tif','r');    loadup = single(tiffData.read())/20; TL(:,:,8)=loadup;  tiffData.close();
    tiffData = Tiff('supportingfiles/linke/September.tif','r'); loadup = single(tiffData.read())/20; TL(:,:,9)=loadup;  tiffData.close();
    tiffData = Tiff('supportingfiles/linke/October.tif','r');   loadup = single(tiffData.read())/20; TL(:,:,10)=loadup;  tiffData.close();
    tiffData = Tiff('supportingfiles/linke/November.tif','r');  loadup = single(tiffData.read())/20; TL(:,:,11)=loadup;  tiffData.close();
    tiffData = Tiff('supportingfiles/linke/December.tif','r');  loadup = single(tiffData.read())/20; TL(:,:,12)=loadup;  tiffData.close();
    clear tiffData loadup%clear all the tiff data.
    save('supportingfiles\linke\LinkeTurbidity_Summary.mat','TL');
else
   load('supportingfiles\linke\LinkeTurbidity_Summary.mat');
end
% find the latitude_central and longitude reference within the TL images
TL2_lon=linspace(-180,180,size(TL,2));
TL2_lat=flip(linspace(-90,90,size(TL,1)));
lon_ind=knnsearch(TL2_lon',longitude_central);
lat_ind=knnsearch(TL2_lat',latitude_central);
% extract the 12 monthly values from that pixel for all 12 months
LinkeTurbidity12months=squeeze(TL(lat_ind,lon_ind,:));
%Interpolate the monthly values to get a regular time series of TL
TL_times_monthly=datevec(datenum('15010000','ddmmyyyy'):365.25/12:datenum('15120000','ddmmyyyy'));
TL_times_monthly(:,3)=15; %15th day of each month
TL_times_monthly(:,4:6)=0; %midnight
TL_times_monthly=datenum(TL_times_monthly);
TL_times_1min=(datenum('01010000','ddmmyyyy'):1/1440:datenum('01010001','ddmmyyyy')-(1/1440))';
LinkeTurbidity_1year_in_1min_resolution=interp1(TL_times_monthly,LinkeTurbidity12months,TL_times_1min,'pchip');
sim_times=time_1min_datevecs;
sim_times(:,1)=0;
sim_times=datenum(sim_times);
TL_inds=knnsearch(TL_times_1min,sim_times);
LinkeTurbidity2=LinkeTurbidity_1year_in_1min_resolution(TL_inds);

% Calculate direct and diffuse clear sky irradiance with Hammer algorithm
disp('Calculating irradiances using Hammer algorithm (2003)')
diffuse_horizontal_cs =solar_constant.*(0.0065 + (-0.045 + 0.0646.*LinkeTurbidity2).*cosd(zenith_angle) + (0.014-0.0327.*LinkeTurbidity2).*cosd(zenith_angle).^2);
diffuse_horizontal_cs(diffuse_horizontal_cs<0)=0;
direct_horizontal_cs  = solar_constant.*exp(-0.8662.*LinkeTurbidity2.*Rayleigh.*airmass).*cosd(zenith_angle);
direct_horizontal_cs(direct_horizontal_cs==0)=0;
direct_horizontal_cs(isnan(direct_horizontal_cs))=0;
global_horizontal_cs  = direct_horizontal_cs+diffuse_horizontal_cs;
