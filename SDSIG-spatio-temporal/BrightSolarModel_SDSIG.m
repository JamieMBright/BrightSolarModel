% +---------------------------------------------------------------------+
% |             Synthetic Irradiance Time Series Generator              |
% +---------------------------------------------------------------------+
% | This script will produce 1-minutely resolution irradiance data upon |
% | an arbitrary plane of defined latitude, orientation and aspect for  |
% | a defined period of time.                                           |
% |                                                                     |
% | The script reads in UK hourly weather data from MIDAS records from  |
% | the British Atmospheric Data Centre. Analysis of the wind speed,    |
% | cloud cover, cloud height, wind speed and pressure allows the       |
% | production of discrete time Markov chains to stochastically produce |
% | the subsequent hour based on the current weather state.             |
% |                                                                     |
% | Cloud cover is produced with cloud length following a single power  |
% | law distribution. Using the cloud cover, season, and the Klutcher   |
% | model, the optical thickness of the cloud is calculated along with  |
% | the diffuse and direct the irradiance is calculated.                |
% +---------------------------------------------------------------------+
% | Original data cannot be provided as per terms and conditions of the |
% | BADC. The Markov chains produced from the data have been so the     |
% | weather conditions for Cambourne, UK can be reproduced.             |
% |_____________________________________________________________________|
% | Permission is given to adopt and adapt this methodology into any    |
% | application deemed fit. Appropriate citaion is required.            |
% +---------------------------------------------------------------------+
% | Suggested citation: Bright, Jamie M.; Smith, Chris .J; Taylor, Peter|
% | G.; Crook, R. 2015. Stochastic generation of synthetic minutely     |
% | irradiance time series derived from mean hourly weather observation |
% | data. Journal of Solar Energy. V(I).pp.DOI.                         |
% |                                                                     |
% | Created by: Jamie Bright and Chris Smith                            |
% | Contributors: Rolf Crook and Peter Taylor                           |
% |                                                                     |
% | Date completed: 30/01/2015                                          |
% | Code base updated on: 29/05/2018                                    |
% +---------------------------------------------------------------------+
%% Preamble
InitialisePaths
Preamble

%% SDSIG 
SettingsForSDSIG

%% USER DEFINED INPUTS TO THE SIG MODEL
USER_DEFINED_VARIABLES
SetTimeLogic % Time logic, User should not change this.
LOAD_RAW_DATA_HERE

%% Safety checks of user deefined input
UserDefinedVariablesSafetyCheck
InputDataSafteyCheck

%% Raw data conversions and statistics derivation
RawDataConversionsAndStatistics

%% Markov creation
ConstructMarkovChains

%% Cloud cover production
LoadCloudSamples

%% Produce cloud cover for the specified duration
DeriveStochasticWeather

%% Derive cloud cover within the spatial domain
DeriveCloudCoverAtEachHouse

%% Solar geometry and clear-sky irradiance
CalculateSolarGeometryAndClearSkyIrradiance

%% Derive the clear-sky indices
ClearSkyIndices_SDSIG

%% Apply the clear-sky indices to the global horizontal irradiance and tilt it for each house
CalculateTiltedIrradianceAtEachHouse

%% Finished
Postamble

%% Plots and figures
PlotsAndFigures

% THE OUTPUT VARIABLE OF INTEREST IS CALLED "house_panel_irradiance"
