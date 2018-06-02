% These are the sytem settings for the SDSIG model.
% It is not recommended to change these settings, as some have key
% implications on the cloud fields that are produced. 
% It is accepted that the spatial domain sizee of 1.5km2 may not be large
% enough to satisfy the user, however. As a disclaimer, only 1.5km2 was
% tested for spatial correlation, and so no validation has been performed
% beyond this. 

%% These variables should not to be altered 
% These settings should not be changed for either explitic reasons, or
% because the implications of changing them are unsupported and therefore
% are likely to cause errors.

% the number of coverage options (0 to 10 out of 10) is always 11.
c_range = 11; 
%(horizontal angles for centre of doain in degs.
panel_pitch_hrz=0; panel_azimuth_hrz=0; 
% the corresponding y domain size, completing the spatial domain square.
domain_y_max=spatial_res; 
% the temporal resolution in seconds. Note this is only guaranteed for 60
% seconds. Changes in this variable are currently unsupported and may cause
% errors.
temporal_res=60;

%% Settings that can be altered
% Firstly, let me introduce the options below before discussing the
% implications of changing the values.

% 1)% the range of windspeeds in ms-1
u_range=25; 
% u_range is a fixed upper limit of permissible cloud motion speeds.
% Because the x-direction within the cloud field is a function of wind
% speed (3600*u), the domain grows linearly with each wind speed increment.
% An upper limimt of 25ms-1 is used here as an example.

% 2) number of cloud samples
num_of_samples=100;
% A cloud sample is a collection of clouds that pass over the spatial 
% domain within an hour. Each cloud is defined as a list of x and y
% coordinates, and a radius, x-y-r. Each cloud field is, therefore, 3 
% columns wide. The num_of_samples is how many different cloud fields are
% to be produced PER wind speed value PER cloud coverage range (c_range).

% 3) the size of the spatial domain
spatial_res=1500;
% the spatial resolution refers to the length of one side of the square
% that all the houses exist in. For example, a spatial_res=1500 defines a
% spatial domain of 1500m-by-1500m. The spatial domain is always square as
% it is implicit in many of the cloud motion calculations. The primary
% reason for setting the spatial_res at 1500 is a PC memory issue. This is
% discussed next.

% 4) the maximum number of clouds within a cloud field
max_num_of_clouds=500; 
% Each cloud sample may contain up to 'max_num_of_clouds' clouds within a
% cloud field sample. Note that this is a limiting factor, to produce a
% cloud field at high wind speed in a large spatial domain requires many
% clouds! 500 is recommended for a spatial resolution of 1500m and a
% u_range of 25. It is possible and probable that increasing either of
% these requires an increase in the max_num_of_clouds. When the cloud
% fields are being produced, a target coverage is set (e.g. 9/10 90%),
% clouds are then added untill this coverage is satisfied. Should the
% max_num_of_clouds be too low and the target coverage not be satistfied
% before that many clouds have been added, the cloud field is rejected.
% Should there be too few clouds allowed, the target number of cloud field
% options may never converge. Better to over estimate this value
% considering the memory implications discussed below. Once the cloud
% fields have been successfully produced, a figure is produced displaying
% the number of clouds required for each coverage and wind speed, so this
% can be tuned later.
% It could also be possible to dynamically set this. Perhaps:
%
% max_num_of_clouds = 500 * spatial_res^2/1500^2 * u_range/25;

%% Implications of changing the supported settings.
% Changes in the above variables have considerable computer memory
% implications. This is the reason for allow spatial_res of 1500.
% In order to calculat the computer memory requirements of these settings,
% consider how a cloud field is constructed.
%
% A cloud field is an x-y-r set of class doubles (8 Bytes per value), each
% cloud field is 3 columns wide, and the max_num_of_clouds defines how many
% rows are within each cloud field sample. So the size of 1 cloud field is
% therefore: 
%
%      cloud_field_memory =  8 Bytes * 3 columns * max_num_of_clouds
cloud_field_memory = 8 * 3 * max_num_of_clouds;
%
% For each unique wind speed value (u_range), there are num_of_samples
% number of samples per wind speed. This is then repeated for each value
% of cloud coverage (c_range below). Therefore, the number of cloud fields
% produced is:
%
%      number_of_cloud_fields = u_range * c_range * num_of_samples
%
number_of_cloud_fields = u_range * c_range * num_of_samples;
%
% The total memory requirements of the settings you choose is then the
% product and stpred in Bytes, such that:
proposed_memory_requirements = number_of_cloud_fields * cloud_field_memory;

%% Tips on saving memory:
% As c_range is fixed and u_range should realistically be around 25 and
% should also be assumed to be fixed. This means the only way to enact
% memory savings is through the max_num_of_clouds and the
% number_of_samples. The max_num_of_clouds is implicitly linked to the
% spatial domain, and should really be around 400 to 500 per 1.5km^2.
% Therefore, the two fundamentally important influencers are:
% - num_of_samples
% - spatial_res
%
% The number of samples is important. Should only 1 be assigned, this means
% that the same pattern of clouds will pass across the spatial domain every
% time that wind speed and coverage pairing is selected. 1000 is the
% default number of samples, however, consider how long the simulation is
% you are running, if only for 1 day, 1 would suffice. For a whole year or
% more, more are required.  The memory requirement to produce all cloud 
% fields per increment of 1 in num_of_samples for a 1.5 km^2 spatial domain 
% is 321.9 KiB. 
%
% The spatial_res is significantly important due to its impact on the
% number of clouds per sample. Consider the proposed formulation above:
% max_num_of_clouds = 500 * spatial_res^2/1500^2 * u_range/25;
% Doubling the spatial resolution has a 4 times impact on the max number
% of clouds, and therefore a 4 times impact on total memory. 
% The memory requirement to produce all cloud fields per increment of 1 
% in num_of_samples for a 3.0 km^2 spatial domain 1,287.6 KiB. 

% The user should consider the RAM of the PC they are running this model on
% and compare it to proposed_memory_requirements to assess whether their 
% proposed settings will be too big.

%% Saftey checks on memory requirements
% Get the user's memory specs.
[userview,systemview] = memory;

if proposed_memory_requirements > userview.MemAvailableAllArrays/2
    warning('Possible that the cloud field settings will demand too much system RAM')
end

if proposed_memory_requirements > userview.MemAvailableAllArrays/1.3
   error('The proposed cloud field sizings requires more PC memory than is available. Try reducing spatial_res or num_of_samples')
end





