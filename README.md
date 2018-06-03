# Welcome to The Bright Solar Model
Here you can freely download the Bright Solar Model as detailed in the Journal of Solar Energy.
You are invited to adopt and adapt this work for whatever purpose you desire. All you have to do is download it and make any changes you wish. Better yet, use GitHub and make your own branch, this way you can keep your version kept up to date with any bug fixes and updates.

Use this work to generate spatio-temporal, 1-minute resolution irradiance time-series as inputs into your work. It is envisaged as inputs into PV power modelling, grid modelling, battery storage simulations, smart grid simulations etc. 

You must adhere to the (very flexible) license, which essentially mandates that you cite the work appropriately (see Requested Citation section).

## The Download
The download contains the two publised versions of the Bright Solar Resource Model:
- The Solar Irradiance Generator (SIG). This is a temporal only methodology that only produces irradiance for a single site. The methodology of the SIG was published in Bright et al. (2015, Solar Energy, v115 p229-242).
- The Spatially Decorrelating Solar Irradiance Generator (SDSIG). This is the first synthetic spatio-temporal irradiance generator in the world. It was published in Bright et al. (2017, Solar Energy, v147  p83-98) and also featured particular developments at international conferences (detailed below in Requested Citation). All the papers are freely available through my Research Gate profile.

Due to data protection terms and conditions, I am unable to provide the user with the raw input data for the model. For the SIG, I have provided the Markov transition matrices statistics drawn from the raw data and are provided for the location of Cambourne, Cornwall, UK. Note, however, that it is recommended that you use the SDSIG, even if you only want a single time series. This is because there are improvements to the clear-sky index methodology. 
The raw data that you need to run this is detailed in the A Little About the Model secction.

## A Little About the Model
I will only talk about the SDSIG, as this is the model expected to be used. 
The SDSIG model synthetically produces multiple 1-minute resolution irradiance time series for any tilt and orientation within a spatial domain. The model takes mean hourly weather observation data and uses them to produce transition probability matrices. From here, weather variables are stochastically determined for each hour using Markov Chain theory, before applying techniques to convert the weather variables into 1-minute resolution cloud cover. Depending on the weather conditions, atmospheric losses are applied to the calculated global clear-sky irradiance to give the global incident irradiance upon an arbitrary plane. 

The outputs are the incident irradiance upon definable arbitrary planes. There are also intermediary data that could also be of interest such as the clear-sky indices, clear-sky irradiance, the horizontal irradiance, and the tilted irradiance for each subcomponent.

The published version of the SDSIG has some limitations: 
* Cloud speed estimations >1km height are asasigned randomly, though suggestions how to calculate it are included.  
* Cloud motion direction is derived following a random walk and is not represented based on reality.

For a detailed description of the methodology, please see the published papers detailed in the Requested Citation section.

## Authors and Contributors
This research has primarily been carried out by Dr Jamie M. Bright. However, many people have played crucial roles in making it happen.
Dr Chris J. Smith was imperative in helping design the irradiance modeling and deriving the distributions of clear-sky index by solar elevation angle and cloud amount. Dr Rolf Crook and Prof. Peter G. Taylor were my PhD supervisors and always had valuable insight into the development, testing and publication of this work. Dr Oytun Babacan was a keen ally in testing the SDSIG on a grid simulation model, Oytun was guided by his PhD supervisor Prof. Jan Kleissl, who also acted as editor for the first paper. Prof Kleissl's input at that stage was extremely vital to the model's success. 

From 2012 to 2016, this work was financially supported by the Engineering and Physical Sciences Research Council through the University of Leeds Centre for Doctoral Training in Low Carbon Technologies (grant number: EP/G036608/1).
Thereafter, I have worked on this in my spare time.

## Requested Citation
To use this model, the following citations are to be used. 

Should you only use the SIG, then only this paper is required as a reference:
 * Bright, Jamie M., Smith, Chris J., Taylor, Peter G. and Crook R. 2015. Stochastic generation of synthetic minutely irradiance time series derived from mean hourly weather observation data. Solar Energy 115, 229-242.

The SDSIG has manu more publications where the developments are listed:
*	Bright, Jamie M., Babacan, Oytun, Kleissl, Jan., Taylor, Peter G. and Crook R. 2017. A synthetic, spatially decorrelating solar irradiance generator and application to a LV grid model with high PV penetration. Solar Energy 147, 83-98.
*	Smith, Chris J., Bright, Jamie M. and Crook R. 2017. Cloud cover effect of clear-sky index distributions and differences between human and automatic cloud observations. Solar Energy 144, 10-21.
*	Bright, Jamie M., Taylor, Peter G. and Crook R. 2015. Methodology to stochastically generate synthetic 1-minute irradiance time-series derived from mean hourly weather observational data. ISES Solar World Congress 2015, 8th-12th November 2015, Daegu, South Korea.
*	Bright, Jamie M., Smith, Chris J., Taylor, Peter G. and Crook R.. 2015. Stochastic generation of synthetic minutely irradiance time series derived from mean hourly weather observation data. Solar Energy 115, 229-242.
*	Bright, Jamie M., Taylor, Peter G. and Crook R. 2015. Methodology to Stochastically Generate Spatially Relevant 1-Minute Resolution Irradiance Time Series from Mean Hourly Weather Data. 5th Solar Integration workshop 2015, 19th-20th October 2015, Brussels, Belgium.

Alongside all these papers, I also request that you reference this GitHub repository so that future users may find it:
Bright, Jamie M. 2018. GitHub: The Bright Solar Model. https://jamiembright.github.io/BrightSolarModel/

## Support and Contact
For scientific queries, your first point of call should be to the open access papers. All of them are open access through Elsevier; they are also freely available through my ResearchGate contributions: https://www.researchgate.net/profile/Jamie_Bright2. Within those papers you will find explanation of the mathematical procedures and the justification behind any assumptions. 

For queries about code itself, you should first check the Matlab's comprehensive help pages www.mathworks.com for answers, the authors will not respond to Matlab usage queries. 

Should you find bugs in the code, please use the GitHub issues page to report it: https://github.com/JamieMBright/BrightSolarModel/issues/new?template=bug_report.md

If you feel that a certain feature is missing, you can request it at: https://github.com/JamieMBright/BrightSolarModel/issues/new?template=feature_request.md

For any other queries, please email jamiebright1@gmail.com, and I will try and help as best I can.

# License information
Copyright 2018 Dr Jamie M. Bright

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
You may obtain a copy of the License at:  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


