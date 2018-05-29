%% User defined data safety checks
% class checks
if ~ischar(start_day)
    error('start_day is not an appropriate character string input of ''ddmmyyyy'' format')
end
if ~ischar(end_day)
        error('end_day is not an appropriate character string input of ''ddmmyyyy'' format')
end
if ~isnumeric(latitude)
        error('latitude is not an appropriate character string input of ''ddmmyyyy'' format')
end
if ~isnumeric(longitude)
        error('longitude is not an appropriate numeric input')
end
if ~isnumeric(panel_pitch)
         error('panel_pitch is not an appropriate numeric input')
end
if ~isnumeric(panel_azimuth)
         error('panel_azimuth is not an appropriate numeric input')
end

% size checks
if length(start_day)~=8
    error('start_day is not in format ''ddmmyyyy''')
end
if length(end_day)~=8
    error('end_day is not in format ''ddmmyyyy''')
end
check_size=length(latitude);
size_check=[length(latitude),length(longitude),length(panel_pitch),length(panel_azimuth)];
if sum(size_check==check_size)~=4
    error('latitude, longitude, panel_pitch and panel_azimuth must be of equal length')
end

%% reporting 

disp(['Dates:       ',datestr(datenum(start_day,'ddmmyyyy'),'dd/mm/yy'),' to ',datestr(datenum(end_day,'ddmmyyyy'),'dd/mm/yy')]);
disp(['Latitude:    ',num2str(latitude),' degrees'])
disp(['Longitude:   ',num2str(longitude),' degrees'])
disp(['Tilt:        ',num2str(panel_pitch),' degrees'])
disp(['Azimuth:     ',num2str(panel_azimuth),' degrees'])
disp('-------------------------------------------');