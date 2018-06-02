# Notes on the data requirements.

There are 6 files that need to be filled in order to use the SDSIG.
- simulation_settings
- house_info
raw observation data of 
- cloud amount 
- cloud base height
- pressure
- wind speed

*Important*, the structure and format of these files is coded into the loading scripts within the model, changing lines, adding columns or not using desired format will cause errors.
That said, you can modify these loading routines in utility/LoadUserData.m to suit your needs.

## SIMULATION SETTINGS
The simulation settings is a text file asking for 5 simple inputs:


 start_day - must a date in the format of:  ddmmyyyy 
             e.g. 1st January 2018  = 01012018

 end_day   - must a date in the format of:  ddmmyyyy 
             e.g. 5th January 2020  = 05012020

 latitude_central  - must be a numeric vector matrix. Must be a single site
             Note that the SIG cannot provide time series
             with a relationship to each other, for that purpose, the
             modern SDSIG version should be used. The permissible range is
             -90 to 90 whereby -90 is the south pole, 90 is the north.
             e.g. 50.1234  
			 
 longitude_central - must be a numeric vector matrix. Must be a single site 
             Note that the SIG cannot provide time series
             with a relationship to each other, for that purpose, the
             modern SDSIG version should be used. The permissible range 
             is -180 to 180 whereby -180 is degrees west of the prime
             meridian (London), and 180 is degrees east.
             e.g. 140.877      
 

 height_above_sea_level - must be a numeric vector matrix. this is the
                          height above sea level of the associated site 
                          latitude and longitude in metres. e.g. 50
						  
						  
					
## House information				
					
The house information asks for 5 inputs per house in the simulation. This is the cartesian placement in respect to others wihtin the spatial domain in an x, y format. the elevation of the site (note that each house can have a different eleation, however, terrain shading is not incoroprated). The azimuth and tilt of the panel is required also.		
						  
To understand the X and Y, consider this concept. 
The size of the spatial domain is a square. The size of this square is defined by the variable spatial_res in utility/SettingsForSDSIG.m. Ensure you read the notes carefully within that particular script to understand the implications of changing it. The standard spatial domain is 1500m by 1500. 
The central latitude and longitude defines the centrepoint of the spatial domain, in this case (750,750). The X-Y grid is orthoganally aligned so that increasing Y is more North, decrasing is more South. Increasing X is more East, decreasing is more West. Placing one of your hoses at (0,750) would put this house 750m West of the central latitude. Placing a property at (1500,1500) would position the house 1060m North East of the centre point. 
To simulate cloud direction, the houses are rotated about the centre of the spatial domain 750,750 using the utility/matrot.m function. A house located at 1500,1500 circularly rotated 90deg would find itself outside of the spatial boundaries. It is then assigned the nearest permissible value within the domain. It is therefore encouraged to keep this limitation in mind and to attempt to not place your houses into the corners, and attempt to keep them within a radius of 750 about the central axis. 

 X and Y - cartesian coordinate of the house where (spatial_res/2, spatial_res/2) is
		    the centre of the spatial domain defined by latitude_central and longitude_central. This is in m and is bounded by spatial_res. E.g. X and Y must not be greater than spatial_res.
			
 height_above_sea_level - must be a numeric vector matrix. this is the
                          height above sea level of the associated site 
                          latitude and longitude in metres. e.g. 50

						  
 panel_pitch - must be a numeric vector matrix. This is the tilt of the 
               panels. permissible values are 0:90 whereby 0 represents a
               flat panel and 90 is fully verticle aiming towards the 
               azimuth angle.
               e.g. 30.35
 
 panel_azimuth - must be a numeric vector matrix.
                 the orientation of each panel measured where 0 is due
                 south and -180 or 180 is equal to due north. Negative
                 values indicate westerly while positive are easterly.
                 e.g.  -15.9

				 
## Raw observation data 
Each raw observation data must be in its own csv file as per the example files provided. there must be a header of 1 row, and two columns. The first is Time, the second is the observation data.
The pressure and clound amount MUST have the same time steps and duration.
Time steps must not have missing values and be a perfect 1-hour resolution set of time steps. Missing data should be left blank.

Time - The current required format is Matlab's datenum() format. 
       https://au.mathworks.com/help/matlab/ref/datenum.html
	   It is a numeric array that represents each point in time as the number of days from January 0, 0000. Each day is represented by 1, and so 0.5 represents 12 hours. and 1/24 is an hour. Should the user wish to change the format to a string or perhaps unixtime. They must themselves change the code in LoadUserData.m and perhaps consider the posixtime(), datetime(), datestr() or datevec() options. 

cloud amount - this is the measure of cloudiness. It is often reported in okta, 	
			   percentages or occasionally in FEW, SCAT, OVC etc. It is up to the user to convert the raw data into okta. Okta is a measurment system in eighths whereby 0 okta represents 0/8 and is completely clear. 8 okta represents 8/8 and is completely overcast. A special value of 9 okta exists and is used to define meteorological phenomenon such as fog whereby the clouds cannot be observed by observer or machine.
			   
pressure - this is the surface pressure at the location (mb). The pressure is used to 
		   define whether a above average or below average period exists. This is important as it defines the cloudiness in an attempt to represent low and high pressure systems (as each has distinct cloud behavioud). For this reason, each value of cloud_amount must have a corresponding pressure, else it cannot be binned. 

cloud base height - this is the height of the clouds as measured in decametres,
					or 10m. Note that due to restrictions on inferring the cloud speed from wind speed, the cloud base height is almost redundant. A future version of this code will remove the need for this. see the notes in the DeriveStochasticWeather.m script around line 170.
					
wind speed - this is the wind speed measured at 10m above surface in m/s. It is used
			 to infer the cloud speed. 