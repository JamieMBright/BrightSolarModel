### Welcome to The Bright Solar Resource Model
Here you can download the Bright Solar Resource Model. You are invited to adopt, adapt and resubmit changes and alterations to this Github Repository. Please feel free to use this work as a 1-minute resolution irradiance input into your work, just ensure you cite the work appropriately (see Authors and Contributors).

### The Download
The download comes with the Matlab .m script, and with a supporting files folder. You will need access to Matlab, this version was written using Matlab r2012a.

Due to data protection terms and conditions, I am unable to provide the user with the raw input data for the model. Instead, the statistics drawn from this data are provided for the location of Cambourne, Cornwall, UK. Should you have access to the British Atmospheric Data Centre MIDAS data sets, you can use the data preparation script provided to get the data into the appropriate format. Note that adjustments will be required within the model script, this is detailed as comments within. The model will run without it, however the weather inputs will be for Cambourne, however the Earth-sun geometry calculations will provide the clear-sky irradiance for the input longitude and latitude. 

### A Little About the Model
This model synthetically produces a 1-minute resolution irradiance profile for a desired input location. The model takes mean hourly weather observation data and uses them to produce transition probability matrices. From here, weather variables are stochastically determined for each hour, before applying techniques to convert the weather variables into 1-minute resolution cloud cover. Depending on the weather conditions, atmospheric losses are applied to the calculated global clear-sky irradiance to give the global incident irradiance upon an arbitrary plane. 

The output is the incident irradiance upon a definable arbitrary plane, though this is also detailed as the irradiance sub-components of diffuse and beam.

The model at this stage has some limitations: 
* Cloud speed estimations >1km height.
* There is currently no spatial element beyond the initial input, separate simulations will not correlate. 
* Currently only a 1st order Markov process, there is potential to increase the order.

For a detailed description of the methodology, please see the paper published in the Journal of Solar Energy <link>.

### Authors and Contributors
The research was carried out by Jamie M. Bright (pm08jmb@leeds.ac.uk), Chris J. Smith, Peter G. Taylor, and Rolf Crook. 

This work was financially supported by the Engineering and Physical Sciences Research Council through the University of Leeds Centre for Doctoral Training in Low Carbon Technologies (grant number: EP/G036608/1).

All uses of this work must cite the paper published in the Journal of Solar Energy http://www.sciencedirect.com/science/article/pii/S0038092X15001024.

Bright, J.M.; Smith, C.J.; Taylor, P.G. & Crook, R. 2015. Stochastic Generation of Synthetic Minutely Irradiance Time Series Derived from Mean Hourly Weather Observation Data. The Journal of Solar Energy. Volume:115. Pages 229-242. DOI:doi:10.1016/j.solener.2015.02.032


### Support or Contact
Your first point of call should be to the open access paper in the Journal of Solar Energy <link>. Here you will find explanation of the mathematical procedures and the justification behind any assumptions. For queries about the workings of the Matlab software, you are advised to visit www.mathworks.com for solutions, the authors will not respond to Matlab usage queries. For any other queries please email jamiebright1@gmail.com with subject title "Bright Solar Model".
