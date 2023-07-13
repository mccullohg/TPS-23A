function [Fg,cT,rho] = thrustModel(filename,vC,vT,rpm,sat,avgTQ,pa0)
%%%%%%%%%%%%%%%%%%  MIGHTY HURON ENGINE MODEL  %%%%%%%%%%%%%%%%%%
%
% thrustModel.m
%
% Author: 1st Lt Gordon McCulloh, FTE (23A)
% Date: 4 May 2023
% 
% Description: thrustModel.m ingests the standard turboprop engine model
% for the C-12C contained in the engine_prop_model Excel spreadsheet.
%
% Inputs:   filename - 'engine_prop_model.xlsx'
%           vC [ft/s]
%           vT [ft/s]
%           rpm [rpm]
%           sat [deg C]
%           avgTQ [%] - average TQ across the maneuver
%           pa0 [ft] - starting pressure altitude
%
% Outputs:  Fg [lbf]
%           cT []
%           rho [slug/ft^3]
%
% Paired files: none
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Import data 
powerCoeff = readtable(filename,'Sheet','Power Coeff');
powerArray = table2array(powerCoeff);
thrustCoeff = readtable(filename,'Sheet','Thrust Coeff');
thrustArray = table2array(thrustCoeff);
efficiency = readtable(filename,'Sheet','Efficiency');
effArray = table2array(efficiency);

% Interpolate data and resize
powerInterp = imresize(powerArray(:,2:end),20,'bilinear');
thrustInterp = imresize(thrustArray(:,2:end),20,'bilinear');
effInterp = imresize(effArray(:,2:end),20,'bilinear');

% Search indices
ii = linspace(10,55,length(thrustInterp(1,:)));
jj = linspace(-0.1,3.95,length(thrustInterp(:,1)));

% Known quantities
aSL = 1116.5;  % ft/s
D = 8.208;  % ft - prop diameter

% Calibration
delta = (1-(6.87558e-6.*pa0))^5.2559;
M = sqrt(5*((((1./delta).*(((1+0.2.*(vC./aSL)^2).^(7/2))-1)+1).^(2/7))-1));
sat = sat./(1+0.2*0.69.*M.^2);
Ta = (sat+273.15)/(1+0.2*0.695*M);
theta = Ta/288.15;
sigma = delta/theta;
rho = sigma*0.0023769;

% Calculate coefficient of power
J = 101.4*vT./(rpm*D);  % advance ratio
Q = avgTQ.*2230/100;  % ft lbs - torque
shp = Q.*rpm*2*pi/60/550;  % hp
cP = shp*550./(rho.*(rpm/60).^3*D^5);  % coefficient of power

% Coefficient of thrust
[~,row] = min(abs(jj-J));
powerSearch = powerInterp(row,:);
[~,col] = min(abs(powerSearch(1:end)-cP));
cT = thrustInterp(row,col);

% Propeller efficiency
effP = effInterp(row,col);

% Calculate thrust
Fprop = effP*550*shp./vT;  % lbf - propeller
Fjet = 0.15/0.85*Fprop;  % lbf - jet
Fg = Fprop+Fjet;  % lbf

end