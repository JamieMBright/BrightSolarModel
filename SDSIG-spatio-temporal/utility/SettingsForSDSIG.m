
c_range = 11;
u_range=15; % the range of windspeeds. standard=60. defined from 'Cloud_Sampling_Technique.m'. This is a length process and, whilst provided, it is recommended to just use the standard.
num_of_samples=500;% the number of options per windspeed per coverage. standard=1000
temporal_res=60;
spatial_res=1500;
max_num_of_clouds=1200;
panel_pitch_hrz=0; %(degs.) set the panel angle (measured from the horizontal).
panel_azimuth_hrz=0; %(degs.) set the orientation. measured from north, + to east, - to west. (-180 to 180. +-180=North, 0=south)
domain_y_max=spatial_res; %maximum size within the y direction. This is a function of the spatial resolution.

