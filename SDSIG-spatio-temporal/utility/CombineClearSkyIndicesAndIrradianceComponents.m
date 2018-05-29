disp('Implementing clear-sky irradiance using Muller and Trentmann (2010)');
% Introduce cloud adjustment with kcMinutely. Beam irradiance relation due
% to Mueller and Trentmann (2010): Algorithm Theoretical Baseline Document
% Direct Irradiance at Surface CM-SAF Product CM-104
global_horizontal = kcMinutely .* global_horizontal_cs;
direct_horizontal = zeros(numel(sun_obscurred_sim),1);
direct_horizontal(kcMinutely < 1 & kcMinutely > 19/69) = direct_horizontal_cs(kcMinutely < 1 & kcMinutely > 19/69) .* (kcMinutely(kcMinutely < 1 & kcMinutely > 19/69) - 0.38*(1 - kcMinutely(kcMinutely < 1 & kcMinutely > 19/69))).^(2.5);
direct_horizontal(kcMinutely>=1) = direct_horizontal_cs(kcMinutely>=1);
direct_horizontal(direct_horizontal<0)=0;
global_horizontal(global_horizontal<0)=0;
diffuse_horizontal = global_horizontal - direct_horizontal;
diffuse_to_global_ratio=diffuse_horizontal./global_horizontal;
