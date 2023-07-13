%%%%%%%%%%%%%%%%%%%%%%%%%%  FQ7311 HWK  %%%%%%%%%%%%%%%%%%%%%%%%%%
%
% autocontrol_hwk.m
%
% Author: 1st Lt Gordon McCulloh, 23A
% Derivative Authors: n/a
% Date: May 2023
% 
% Description: 
%
% Inputs: 
%
% Outputs: 
%
% Paired files: n/a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc;

% Load latex formatting defaults
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultTextInterpreter','latex');

% Flight conditions
vt = 709;  % ft/s
h = 10000; % ft
g = 32.174;  % ft/s^2

% F-16 Model with cg at 35% MAC
numQ = [-6.86, -7.958, -.1641, 0];
numAlpha = [-.064, -6.449, -.0882, -.04336];
denom = [1, 2.242, -2.59, -.02724, -.003982];
tfQ = tf(numQ,denom);
tfAlpha = tf(numAlpha,denom);

% Actuator model
tfAct = tf(20,[1, 20.2]);

% Transfer functions
tfQ = tfQ*tfAct;
tfAlpha = tfAlpha*tfAct;  

% -- Alpha to longitudinal stick command --
Kalpha0 = 1.86;
% Note: (-) is standard sign convention stick to alpha
tfAlphaCL = feedback(-tfAlpha,Kalpha0);  

figure('Name','Alpha/Stick Bode')
bode(tfAlphaCL);
title('Alpha to Longitudinal Stick Command');

% Transfer function for pitch rate with closed-loop alpha
tfDesignQ = minreal(tfQ/tfAlpha*tfAlphaCL);

% -- Pitch to longitudinal stick command --
Kq = 0.54;
tfQCL = feedback(tfDesignQ,Kq);

figure('Name','Pitch/Stick Bode')
bode(tfQCL);
title('Pitch to Longitudinal Stick Command');

% Display the poles, damping, and frequency of long. modes
damp(tfQCL)

