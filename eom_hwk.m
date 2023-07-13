%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  EOM HWK  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% eom_hwk.m
%
% Authors: 1st Lt Gordon McCulloh, 23A
%
% Date: 11 Mar 2023
% 
% Description: Visual analysis code for FQ 6111A: Equations of Motion
%
% Inputs: A/C Parameters, Transfer Function
%
% Outputs: A/C Response
%
% Paired files: none
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc;

%% Problem 7
alphaZero = -3;  % deg
vT = 280;  % ft/s
W = 636600;  % lb
S = 5500;  % ft^2
cbar = 27.31;  % ft
cm0 = 0.086;
cma = -1.26;  % 1/rad
cLa = 5.7;  % 1/rad
cmq = -20.8;  % 1/rad
cmde = -1.34;  % 1/rad
rhoSL = 0.002377;  % sl/ft^3

% A
deTrim = -(cm0+cma*(2*W/(rhoSL*vT^2*S)/cLa+deg2rad(alphaZero)))/cmde;
fprintf('7A. %.2f deg \n\n', rad2deg(deTrim));

% B
Q = linspace(-20,20,201);
deTrim = -(cm0+cma*(2*W/(rhoSL*vT^2*S)/cLa+deg2rad(alphaZero))+...
    +cbar/vT*cmq*deg2rad(Q))/cmde;

figure('Name','pitch rates vs. elevator angle')
plot(Q,rad2deg(deTrim),'k')
xlabel('Pitch Rate, Q [deg/s]')
ylabel('Elevator Angle, \delta_{e,trim} [deg]')
title('7B.  Elevator Angle as a Function of Pitch Rate')

% C
for ii = 1:length(Q)
    if deTrim(ii)<0 && deTrim(ii-1)>0
        Qc = Q(ii);
    end
end
fprintf('7C.  Pitch rate at zero elevator angle,  %.2f deg/s \n\n',Qc);

%% Problem 8
s = tf('s');
G = -361*(s+.0098)*(s+1.371)/((s^2+.008996*s+.003969)*(s^2+4.21*s+18.23));

figure('Name','elevator command to pitch attitude transfer function')
pzmap(G)
axis([-3 0.5 -4 4])
title({'8.  TF Elevator Command to Pitch Attitude',...
    'T-33, 10,000ft, M = 0.6'})

%% Problem 9
figure('Name','impulse response')
impulse(G)
title('9.  Impulse Response')

%% Problem 10
phi = linspace(0,360,1001);  % deg
theta = linspace(0,0,1001);
psi = linspace(180,180,1001); 
phiDot = 0;  % deg/s
thetaDot = 5;  
psiDot = 0;

P = -sin(deg2rad(theta)).*psiDot+phiDot;
Q = sin(deg2rad(phi)).*cos(deg2rad(theta)).*psiDot+...
    cos(deg2rad(phi)).*thetaDot;
R = cos(deg2rad(phi)).*cos(deg2rad(theta)).*psiDot-...
    sin(deg2rad(phi)).*thetaDot;

figure('Name','body axis roll/pitch/yaw rates')
plot(phi,P)
hold on 
plot(phi,Q)
plot(phi,R)
xlabel('Inertial Roll Angle, \phi [deg]')
ylabel('Body Axis Rates [deg/s]')
title('10.  P, Q, R as Functions of Roll Angle')
legend('P (Roll)','Q (Pitch)','R (Yaw)','location','southeast')
hold off