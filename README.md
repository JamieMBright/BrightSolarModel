# Welcome to The Bright Solar Resource Model
Here you can download the Bright Solar Resource Model. 
You are invited to adopt and adapt this work. Make a branch and work away.
Please feel free to use this work to generate spatio-temporal, 1-minute resolution irradiance time-series as inputs into your work, just ensure you cite the work appropriately (see Requested Citation section).

## The Download
The download contains the two version of the Bright Solar Resource Model.
- The Solar Irradiance Generator (SIG). This is a temporal only methodology that only produces irradiance for a single site. The methodology of the SIG was published in Bright et al. (2015, Solar Energy, ).
- The Spatially Decorrelating Solar Irradiance Generator (SDSIG). This is the first synthetic spatio-temporal irradiance generator in the world. It was published in Bright et al. (2017, Solar Energy, ) but also featured in some conference papers (detailed below). All the papers are freely available through my Research Gate profile.

Due to data protection terms and conditions, I am unable to provide the user with the raw input data for the model. For the SIG, I have provided the statistics drawn from the raw data and are provided for the location of Cambourne, Cornwall, UK. It is recommended that you use the SDSIG, even if you only want a single time series. This is because there are improvements to the clear-sky index methodology. 
 Note that adjustments will be required within the model script, this is detailed as comments within. The model will run without it, however the weather inputs will be for Cambourne, however the Earth-sun geometry calculations will provide the clear-sky irradiance for the input longitude and latitude. 

## A Little About the Model
This model synthetically produces a 1-minute resolution irradiance profile for a desired input location. The model takes mean hourly weather observation data and uses them to produce transition probability matrices. From here, weather variables are stochastically determined for each hour, before applying techniques to convert the weather variables into 1-minute resolution cloud cover. Depending on the weather conditions, atmospheric losses are applied to the calculated global clear-sky irradiance to give the global incident irradiance upon an arbitrary plane. 

The output is the incident irradiance upon a definable arbitrary plane, though this is also detailed as the irradiance sub-components of diffuse and beam.

The model at this stage has some limitations: 
* Cloud speed estimations >1km height.
* There is currently no spatial element beyond the initial input, separate simulations will not correlate. 
* Currently only a 1st order Markov process, there is potential to increase the order.

For a detailed description of the methodology, please see the paper published in the Journal of Solar Energy <link>.

## Authors and Contributors
The research was carried out by Jamie M. Bright (pm08jmb@leeds.ac.uk), Chris J. Smith, Peter G. Taylor, and Rolf Crook. 

This work was financially supported by the Engineering and Physical Sciences Research Council through the University of Leeds Centre for Doctoral Training in Low Carbon Technologies (grant number: EP/G036608/1).

All uses of this work must cite the paper published in the Journal of Solar Energy http://www.sciencedirect.com/science/article/pii/S0038092X15001024.

Bright, J.M.; Smith, C.J.; Taylor, P.G. & Crook, R. 2015. Stochastic Generation of Synthetic Minutely Irradiance Time Series Derived from Mean Hourly Weather Observation Data. The Journal of Solar Energy. Volume:115. Pages 229-242. DOI:doi:10.1016/j.solener.2015.02.032

## Requested Citation


## Support or Contact
Your first point of call should be to the open access paper in the Journal of Solar Energy <link>. Here you will find explanation of the mathematical procedures and the justification behind any assumptions. For queries about the workings of the Matlab software, you are advised to visit www.mathworks.com for solutions, the authors will not respond to Matlab usage queries. For any other queries please email jamiebright1@gmail.com with subject title "Bright Solar Model".


# License information

   Copyright 2018 Dr Jamie M. Bright

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.


