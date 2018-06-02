% +---------------------------------------------------------------------+
% |    Spatially Decorrelating Solar Irradiance Generator, SDSIG        |
% +---------------------------------------------------------------------+
% | This script will produce 1-minutely resolution irradiance data upon |
% | an arbitrary plane of defined latitude, orientation and aspect for  |
% | a defined period of time. It will produce a time series for any     |
% | number of properties within an X-by-Y domain (validated for 1500m2).|
% | Each property can have individual orientation, tilt, and position   |
% | within the X,Y domain. The latitude and longitude provided are      |
% | assigned to all properties and is referred to as the central lat/lon|
% | 
% | The script requires inputs of cloud cover (okta), cloud base height,|
% | 10m wind speed and atmospheric pressure. Notes on how to remove the |
% | dependency on cloud base height are included in the stochastic      |
% | weather script. This model was tested using okta values taken from  |
% | UK hourly weather data decords downlaoded from MIDAS of the         |
% | British Atmospheric Data Centre. Analysis of the wind speed,        |
% | cloud cover, cloud height, wind speed and pressure allows the       |
% | production of discrete time Markov chains to stochastically produce |
% | the subsequent hour based on the current weather state.             |
% | The user can input their own data into the LOAD_RAW_DATA_HERE script|
% |                                                                     |
% | Cloud cover is produced with cloud length following a single power  |
% | law distribution. Cloud fields are produced. These cloud fields     |
% | represent the sky in a 2D plane. Clouds are repsresented using three|
% | values of x, y and r, where x,y define the centrepoint within the   |
% | spatial domain, and r defines the radius of the cloud, this means   |
% | that all clouds are represented as circles. With each time step, the|
% | clouds are moved according to the distacne covered based on the     |
% | cloud movement speed. Each property can be covered by any of the    |
% | clouds. This enablse spatially decorrelating profiles between       |
% | neighbouring properties within the domain.                          |
% |                                                                     |
% | Once cloud cover is derived, the irradiance is calculated at each   |
% | property on a tilted plane. The user is strongly recommended to     |
% | consult the published papers to learn more of the extent and        |
% | limitations of this methodology.                                    |
% +---------------------------------------------------------------------+
% | Please adhere to license. Appropriate citaion is required.          |
% +---------------------------------------------------------------------+
% |                 Required citations for full use                     |
% |   SIG originally developed:                                         |
% | Bright, Jamie M.; Smith, Chris .J; Taylor, Peter G.; Crook, R. 2015.|
% | Stochastic generation of synthetic minutely irradiance time series  |
% | derived from mean hourly weather observation data.                  |
% | Journal of Solar Energy. 115 229-242.                               |
% |                                                                     |    
% |   Clear-sky distributions discovered:                               |
% | Smith, Chris; Bright, Jamie M.; Crook, Rolf. 2017. Cloud cover      |
% | effect of clear-sky index distributions and differences between     |
% | human and automatic cloud observations.                             |
% | Journal of Solar Energy. 144 10-21.                                 |
% |                                                                     |
% |   SDSIG developed:                                                  |
% | Bright, Jamie M.; Babacan, Oytun; Kleissl, Jan; Taylor, Peter G.;   |
% | Crook, R. 2017. A synthetic, spatially decorrelating solar          |
% | irradiance generator and application to a LV grid model with high   |
% | PV penetration.                                                     |
% | Journal of Solar Energy. 147 83-98.                                 |   
% |                                                                     |
% |               Requested citations to give full story                |
% |   Development of cloud motion fields                                |
% | Bright, Jamie M.; Taylor, Peter G.; Crook, R. 2015.                 |
% | Methodology to Stochastically Generate Spatially Relevant 1-Minute  | 
% | Resolution Irradiance Time Series from Mean Hourly Weather Data.    |
% | 5th Solar Integration Workshop 2015, 19-20th October, Brussels,     |
% | Belgium.                                                            |
% |                                                                     |
% |   Development of spatial decorrelation premise                      |  
% | Bright, Jamie M.; Taylor, Peter, G. Crook, Rolf. 2015.              |
% | Methodology to stochastically generate synthetic 1-minute irradiance|
% | time-series derived from mean hourly weather observational data.    |
% | ISES Solar World Congress 2015, 8th-12th November 2015, Daegu,      |
% | South Korea.                                                        |
% +---------------------------------------------------------------------+
% | Created by: Dr Jamie M. Bright                                      |
% | Contributors: Dr Chris Smith, Dr Rolf Crook and Prof Peter G. Taylor|
% +---------------------------------------------------------------------+
% | Date completed: 30/01/2015                                          |
% | Code base updated on: 30/05/2018                                    |
% +---------------------------------------------------------------------+

house_panel_irradiance = SDSIG();

function hpa = SDSIG()

%% Preamble
addpath('utility\')
InitialisePaths

%% SDSIG 
SettingsForSDSIG

%% Load user data
LoadUserData

%% set time logic
SetTimeLogic 

%% Safety checks of user deefined input
UserDefinedVariablesSafetyCheck

%% Raw data conversions and statistics derivation
RawDataConversionsAndStatistics

%% Markov creation
ConstructMarkovChains

%% Cloud cover production
LoadCloudSamples

%% Produce cloud cover for the specified duration
DeriveStochasticWeather

%% Solar geometry and clear-sky irradiance at centre of spatial domain
CalculateSolarGeometryAndClearSkyIrradiance

%% Derive cloud cover within the spatial domain
CloudMotionAndClearSkyIndices

%% Apply the clear-sky indices to the global horizontal irradiance and tilt it for each house
CalculateTiltedIrradianceAtEachHouse

%% Finished
Postamble

%% Plots and figures
PlotsAndFigures

hpa = house_panel_irradiance;
end