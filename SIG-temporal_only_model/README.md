# BrightSolarModel / Solar Irradiance Generator (SIG)
The Bright Solar Resource Model (later named the Solar Irradiance Generator, SIG) is detailed in the Journal of Solar Energy, vol 115, pp229-242, under the title "stochastic generation of synthetic minutely irradiance time series derived from mean hourly weather observation data". It is written by Jamie M. Bright, Chris J. Smith, Peter G. Taylor, and Rolf Crook. 

The model can provide 1-minute resolution irradiance upon an arbitrary plane for any location with mean hourly inputs of okta, cloud height, wind speed and pressure. It was designed using the BADC UKMO MIDAS data, though this cannot be provided for legal reasons. The statistics derived from them can be and have been included for the location of Cambourne, Cornwall, UK.

The model was originally produced in Matlab r2012a and released in 2015, it has since been updated and re-released using Matlab2016b. It is provided for use in matlab. The model is freely available for adoption, adaptation, and resubmission to this site. A citation to the paper must be made for all uses. 

## V.2 updated code base, SIG
Version 2 sees a significant overhaul of how the model is coded. Fundamentally it is the same, however, it is mch more efficient and user friendly now. There are methods described within how to remove a dependency on requiring cloud base height. It is left in the model as it is described within the paper this way. See other repositories for improved versions of this overall methodology. 
------------------------------------------
* brightsolarmodel.m --- This is the parent script used to trigger the whole simulation
* USER_DEFINED_VARIABLES.m --- This is where the user can input the required metadata to make the model work.
* LOAD_RAW_DATA_HERE.m --- This is where the user should upload the raw input data into single vector format. 

Other files of interest:
* supportingfiles/old-versions --- folder containing actual transition probability matrices and other statistics derived from the raw data for Leeds, UK. You could overwrite the Markov transition matrices sections with these should you wish.
* sun_obscured_options_generic.csv --- csv containing 1000 examples of hour cloud cover for each wind speed.
* cloud_sampling_technique.m --- iterative process of producing clouded hour samples for each okta and windspeed. 

-------------------------------------------


## V.1 - the original version released in 2015
------------------------------------------
* brightsolarmodel.m --- the model written in matlab
* data_preparation_generic.m --- script to convert raw badc data into the desired format of the script.
* supportingfiles --- folder containing the transition probability matrices and other statistics derived from the raw data. 
* sun_obscured_options_generic.csv --- csv containing 1000 examples of hour cloud cover for each wind speed.
* cloud_sampling_technique.m --- long iterative process of producing clouded hour samples for each okta and windspeed. 

-------------------------------------------

Suggested citations
for downloadable formats for endnote, bibtex etc. please visit:
http://www.sciencedirect.com/science/article/pii/S0038092X15001024

Bright, J.M.; Smith, C.J.; Taylor P.G.; Crook, R. 2015. Stochastic generation of synthetic minutely irradiance time series derived from mean hourly weather observation data. Journal of Solar Energy. Volume:115. Pages:229. DOI:doi:10.1016/j.solener.2015.02.032
