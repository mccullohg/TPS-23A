%%%%%%%%%%%%%%%%%%%%%%%%%%  FQ7111 HWK  %%%%%%%%%%%%%%%%%%%%%%%%%%
%
% lindesign_hwk.m
%
% Author: 1st Lt Gordon McCulloh, 23A
% Derivative Authors: n/a
% Date: 1 May 2023
% 
% Description: analysis of transfer functions for the F-16 3DOF,
% small-perturbation longitudinal model with no feedback control
%
% Inputs: transfer functions (q/de, alpha/de at 25% and 35% MAC)
%         true airspeed, altitude, AOA
%
% Outputs: open-loop impulse responses, step responses, and Bode plots
%
% Paired files: n/a
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc;

% Load latex formatting defaults
set(groot, 'defaultAxesTickLabelInterpreter','latex'); 
set(groot, 'defaultLegendInterpreter','latex');
set(groot, 'defaultTextInterpreter','latex');

% Hard-code inputs
vt = 709;  % ft/s
h = 10000; % ft
aoa = 1.1;  % deg
g = 32.174;  % ft/s^2

% 25% MAC
numQ25 = [-6.398, -5.381, -.02674, 0];
numAlpha25 = [-.069, -6.449, -.07183, -.06974];
denom25 = [1, 5.128, 43.45, 1.229, .5133];
tfQ25 = tf(numQ25,denom25);
tfAlpha25 = tf(numAlpha25,denom25);

% 35% MAC
numQ35 = [-6.86, -7.958, -.1641, 0];
numAlpha35 = [-.064, -6.449, -.0882, -.04336];
denom35 = [1, 2.242, -2.59, -.02724, -.003982];
tfQ35 = tf(numQ35,denom35);
tfAlpha35 = tf(numAlpha35,denom35);

% Actuator model
tfAct = tf(20,[1, 20.2]);

% Transfer functions
tfQ25 = tfQ25*tfAct;
tfAlpha25 = tfAlpha25*tfAct;
tfQ35 = tfQ35*tfAct;
tfAlpha35 = tfAlpha35*tfAct;

% Open-loop responses
t = linspace(0,5,1001);  % s

figure('Name','Open-Loop Responses')
suptitle('\bf Impulse Responses of the Open-Loop Longitudinal Linear Models');

subplot(2,1,1);
hold on
impulse(tfQ25, t);
impulse(tfAlpha25, t);
axis([0 2 -5 5]);
title('CG at 25% MAC')
legend('$q/\delta_e$','$\alpha/\delta_e$')
legend('$q/\delta_e$','$\alpha/\delta_e$')  % buggy labels
grid minor
hold off

subplot(2,1,2);
hold on 
impulse(tfQ35, t);
impulse(tfAlpha35, t);
axis([0 5 -50 5]);
title('CG at 35% MAC')
legend('$q/\delta_e$','$\alpha/\delta_e$')
legend('$q/\delta_e$','$\alpha/\delta_e$')
grid minor
hold off

% Short-period HQ analysis
tau25 = 1/max(abs(zero(tfQ25)));  % 25% MAC
fprintf('(25%% MAC) tau_theta2 = %.4f \n',tau25);
[omegaN, zeta, poles] = damp(tfQ25);
[poleMax, idx] = max(imag(poles));
tC25 = -1/real(poles(idx));
fprintf('omega_n: %.4f, zeta = %.4f \n',[omegaN(idx),zeta(idx)]);
fprintf('time constant = %.4f \n',tC25);
nAlpha25 = (vt/g)/tau25;
fprintf('n/alpha = %.4f \n',nAlpha25);
CAP25 = omegaN(idx)^2/nAlpha25;
fprintf('CAP = %.4f \n',CAP25);

tau35 = 1/max(abs(zero(tfQ35)));  % 35% MAC
fprintf('(35%% MAC) tau_theta2 = %.4f \n',tau35);
nAlpha35 = (vt/g)/tau35;
fprintf('n/alpha = %.4f \n',nAlpha35);

% Estimate effective time delay
figure('Name','Time Delay Estimate')
hold on
step(tfQ25,t);
step(tfQ35,t);
axis([0 .25 -1 0.1]);
title('Step Responses of Pitch Rate Models')
legend('CG at 25\% MAC','CG at 35\% MAC')
grid minor
hold off

% Bode plots
tfTheta25 = tfQ25*tf(1,[1 0]);
tfTheta35 = tfQ35*tf(1,[1 0]);

figure('Name','Q Bode')
bode(tfQ25,tfQ35);
title('q/\delta_{e} Bode Plots')
legend('CG at 25\% MAC','CG at 35\% MAC')

figure('Name','Theta Bode')
bode(tfTheta25,tfTheta35);
title('\theta/\delta_{e} Bode Plots')
legend('CG at 25\% MAC','CG at 35\% MAC')

figure('Name','Corrected Bode')
bode(-tfTheta25,-tfTheta35);
title('Corrected \theta/\delta_{e} Bode Plots')
legend('CG at 25\% MAC','CG at 35\% MAC')