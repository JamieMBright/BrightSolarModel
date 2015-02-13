# BrightSolarModel
The Bright Solar Resource Model is detailed in the Journal of Solar Energy under the title "stochastic generation of synthetic minutely irradiance time series derived from mean hourly weather observation data". It is written by Jamie M. Bright, Chris J. Smith, Peter G. Taylor, and Rolf Crook. 

The model can provide 1-minute resolution irradiance upon an arbitrary plane for any location with mean hourly inputs of okta, cloud height, wind speed and pressure. It was designed using the BADC UKMO MIDAS data, though this cannot be provided for legal reasons. The statistics derived from them can be and have been included for the location of Cambourne, Cornwall, UK.

The model was produced in Matlab r2012a. It is provided for use in matlab. The model is freely available for adoption, adaptation, and resubmission to this site. A citation to the paper must be made in all uses. 

------------------------------------------
* brightsolarmodel.m --- the model written in matlab
* data_preparation_generic.m --- script to convert raw badc data into the desired format of the script.
* supportingfiles --- folder containing the transition probability matrices and other statistics derived from the raw data. 
* sun_obscured_options_generic.csv --- csv containing 1000 examples of hour cloud cover for each wind speed.
* cloud_sampling_technique.m --- long iterative process of producing clouded hour samples for each okta and windspeed.
-------------------------------------------



Suggested citation (to be updated upon publication):
for downloadable formats for endnote, bibtex etc. please visit:
http://www.sciencedirect.com/science/article/xxx/xxxxxxxxxxxxxxxxxxxxxxxxxxx

Bright, J.M.; Smith, C.J.; Taylor P.G.; Crook, R. 2015. Stochastic generation of synthetic minutely irradiance time series derived from mean hourly weather observation data. Journal of Solar Energy. Volume:xx. Issue:xx. Pages:xx. DOI:xxxxxxx
