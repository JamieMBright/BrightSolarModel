disp('Translating the irradiance panel using Klucher (1979)');
    
% Panel irradiance - using Klucher model -calculate on any arbitrary plane
% from diffuse, hz and ghz and angles.
F=1-(diffuse_horizontal./global_horizontal).^2; % modulating factor
isotropic=(1+cosd(panel_pitch))/2; % isotropic component - invariant to direct/global ratio
horizonal=(1+F.*(sind(panel_pitch/2)).^3); % horizon brightening term
circumsol = (1 + F .* (cosd(incident_angle)).^2 .* (sind(zenith_angle)).^3); % circumsolar diffuse irradiance
panel_irradiance = diffuse_horizontal.*isotropic.*horizonal.*circumsol + direct_horizontal./cosd(zenith_angle).*cosd(incident_angle);

% take account of night
panel_irradiance = (zenith_angle < 90).*panel_irradiance;
