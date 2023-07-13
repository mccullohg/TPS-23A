function [D, cD] = cdCalc(W,alphaT,Fg,Fe,ax,az,it,rho,S,vT)
%%%%%%%%%%%%%%%%%%  DRAG CALCULATIONS  %%%%%%%%%%%%%%%%%%
%
% cdCalc.m
%
% Author: 1st Lt Gordon McCulloh, FTE (23A)
% Date: 4 May 2023
% 
% Description: calculate lift and coefficient of lift from aeromod data
%
% Inputs:   W [lbf]
%           alphaT [deg]
%           Fg [lbf]
%           Fe [lbf]
%           ax [ft/s^2]
%           az [ft/s^2]
%           it [deg]
%           rho [slug/ft^3]
%           S [ft^2]
%           vT [ft/s]
%
% Outputs:  D [lbf]
%           cD []
%
% Paired files: none
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
g = 32.17;  % ft/s^2

D = -W./g.*(ax.*cosd(alphaT)+az.*sind(alphaT))+Fg.*cosd(alphaT+it)-Fe;
cD = 2*D./(rho.*S.*vT.^2);  % c deez nuts

end