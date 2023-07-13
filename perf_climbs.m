function [time, dist, fuel] = perf_climbs(KCAS, H, ff1, ff2, tempC, time)
%%%%%%%%%%%%%%%%%  MIGHTY HURON PERFORMANCE - CLIMB  %%%%%%%%%%%%%%%%%
%
% perf_climbs.m
%
% Author: 1st Lt Gordon McCulloh, FTE (23A)
% Date: May 2023
%  
% Description: perf_climbs.m ingests either handheld or DAS data as vectors
% for validation of the C-12 Flight Manual check climb models. Data is then
% manipulated to generate time, distance, and fuel to climb plots. This
% function is designed to be implemented in a larger performance script
% with the input data already processed and formatted.
%
% Inputs: KCAS, H (ft), ff1 (pph), ff2 (pph), tempC (deg C), time (s)
%
% Outputs: time (min), dist (nm), fuel (lbs)
%
% Paired files: N/A
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Flight manual models (reference)
timeMdl = [0, 7.1];  % min
altMdl = [5000, 20000];  % ft PA
fuelMdl = [0, 90];  % lbs
distMdl = [0, 22];  % nm

% Constants
asl = 1116.4;  % ft/s

% Airspeed conversions and distance calculation
delta = (1-6.87559e-6*H).^5.2559;
M = sqrt(5.*((1./delta.*((1+0.2.*((KCAS.*1.689)./asl).^2).^(7/2)-1)+1).^(2/7)-1));
tempR = ((tempC*1.8)+32)+460.67;  % Rankine
a = sqrt(1.4*1716*tempR);  % ft/s

% Solve for standardized distance
KTAS = M.*a/1.689;  % kts
dist = KTAS.*time/3600;  % nm
theta = asind((max(altMdl)-min(altMdl))/(max(dist)*6076));  % deg
dist = cosd(theta)*dist;  % nm

% Solve for standardized fuel
fuel = (ff1+ff2).*time/3600;  % lbs

% Convert time to minutes
time = time/60;  % min

end