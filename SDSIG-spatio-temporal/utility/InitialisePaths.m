%% Script to initilise all the file paths where functions are located
if ispc
	home_dir=[pwd,'\'];
else
	home_dir=[pwd,'/'];
end
addpath(home_dir);
addpath([home_dir,'supportingfiles']);
addpath([home_dir,'supportingfiles',filesep,'temporary_files']);
addpath([home_dir,'utility']);
addpath([home_dir,'USER_INPUT_DATA']);

%% preamble

disp('-------------------------------------------');
disp('            Starting simulation');
disp('-------------------------------------------');
tic %set a timer
echo off


