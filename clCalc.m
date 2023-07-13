function [L, cL] = clCalc(W,alphaT,Fg,ax,az,rho,S,vT)
%%%%%%%%%%%%%%%%%%  LIFT CALCULATIONS  %%%%%%%%%%%%%%%%%%
%
% clCalc.m
%
% Author: 1st Lt Gordon McCulloh, FTE (23A)
% Date: 4 May 2023
% 
% Description: calculate lift and coefficient of lift from aeromod data
%
% Inputs:   W [lbf]
%           alphaT [deg]
%           Fg [lbf]
%           ax [ft/s^2]
%           az [ft/s^2]
%           rho [slug/ft^3]
%           S [ft^2]
%           vT [ft/s]
%
% Outputs:  L [lbf]
%           cL []
%
% Paired files: none
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g = 32.17;  % ft/s^2

L = W./g.*(ax.*sind(alphaT)-az.*cosd(alphaT))-Fg.*sind(alphaT); 
cL = 2*L./(rho.*S.*vT.^2);

end