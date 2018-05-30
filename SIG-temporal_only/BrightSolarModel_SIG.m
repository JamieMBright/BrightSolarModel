% +---------------------------------------------------------------------+
% |             Synthetic Irradiance Generator, SIG                     |
% +---------------------------------------------------------------------+
% | This script will produce 1-minutely resolution irradiance data upon |
% | an arbitrary plane of defined latitude, orientation and aspect for  |
% | a defined period of time.                                           |
% |                                                                     |
% | The script reads in hourly weather data (tested on MIDAS from the   |
% | British Atmospheric Data Centre)of variables: wind speed, cloud     |
% | cover, cloud height, wind speed and pressure. This allows the       |
% | production of discrete time Markov chains to stochastically produce |
% | the subsequent hour based on the current weather state.             |
% |                                                                     |
% | Cloud samples are made with cloud length following a single power   |
% | law distribution. Using the cloud cover, season, and the Klutcher   |
% | model, the optical thickness of the cloud is calculated along with  |
% | the diffuse and direct the irradiance is calculated.                |
% +---------------------------------------------------------------------+
% | Original data cannot be provided as per terms and conditions of the |
% | BADC. The Markov chains produced from the data have been provided   |
% | should the user wish to compare. There is room for the user to add  |
% | their own input data in order to produce the markov chains.         |
% |_____________________________________________________________________|
% | See license for permissions. Appropriate citaion is required.       |
% +---------------------------------------------------------------------+
% | Suggested citation: Bright, Jamie M.; Smith, Chris .J; Taylor, Peter|
% | G.; Crook, R. 2015. Stochastic generation of synthetic minutely     |
% | irradiance time series derived from mean hourly weather observation |
% | data. Journal of Solar Energy. 115 229-242.                         |
% | https://doi.org/10.1016/j.solener.2015.02.032                       |                                                                  |
% |                                                                     |
% | Created by: Dr Jamie M. Bright                                      |
% | Contributors: Dr Chris Smith, Dr Rolf Crook and Prof Peter Taylor   |
% |                                                                     |
% | Date completed: 30/01/2015                                          |
% | Date code updated: 30/05/2018                                       |
% +---------------------------------------------------------------------+
%% Preamble
InitialisePaths
Preamble

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
DeriveCloudCover

%% Solar geometry and clear-sky irradiance
CalculateSolarGeometryAndClearSkyIrradiance

%% Derive the clear-sky indices
ClearSkyIndices_SIG

%% Apply the clear-sky indices to the global horizontal irradiance
CombineClearSkyIndicesAndIrradianceComponents

%% Perform the Klucher tilt to obtain irradiance on an arbitrary plane
CalculateTiltedPanelIrradance
Postamble

%% Plots and figures
PlotsAndFigures
