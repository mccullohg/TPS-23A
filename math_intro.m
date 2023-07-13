clear;
%% Vectors
% You are flying at 350 KTAS, with a ROC of 3000 ft/min
% What is your FPA?

KTAS = 350;
Vel = KTAS * 6076 / 60;
ROC = 3000;
FPA = asind(ROC/Vel)

% If we assume you are travelling East, write velocity vector (in fps)
% using a North, East, Down coordinate system

N = 0;
E = Vel * cosd(FPA);
D = - ROC;

Vel_Vec = [N; E; D;]


%% Vector Addition
% Continuing from the previous example
% Assuming you are flying with the same velocity vector, 
% You fire a missile with a velocity (at time t): 55,000 East, 2,000 Down
% What is the sum of these two vectors?

A_N = 0;
A_E = Vel * cosd(FPA);
A_D = - ROC;

A_Vel_Vec = [A_N; A_E; A_D;];

M_N = 0;
M_E = 55000;
M_D = 2000;

M_Vel_Vec = [M_N; M_E; M_D;];

A_Vel_Vec + M_Vel_Vec


%% Frame of Reference - Earth Fixed
% If we assume the missile travels at the sum of the two previous vectors
% What is its flight path from a ground observer?

Sum_Vel_Vec = A_Vel_Vec + M_Vel_Vec;

atand(-Sum_Vel_Vec(3)/Sum_Vel_Vec(2))


%% Frame of Reference - Body Fixed
% What is its flight path from a jet's perspective?
% Assume the jet's velocity vector is the X axis & ROC is the Z axis

atand(-M_Vel_Vec(3)/M_Vel_Vec(2))


%% Matrix Multiply
% Example of Matrix Multiplication

A = [1, 2, 3; 4, 5, 6]
B = [2, 3; 4, 5];
C = [3, 4; 5, 6; 7,8];

size(A)
size(B)
size(C)

D = A*C
size(D)

% Can't do, because dimension's don't match
% E = A * B

%% Coordinate Transforms
clear; 

theta = 0;
DCM = [cosd(theta), sind(theta); -sind(theta), cosd(theta)];

input = [1;0]

rotated = DCM*input

theta = 45;
DCM = [cosd(theta), sind(theta); -sind(theta), cosd(theta)];

rotated = DCM*input

%% Spring Mass Damper: 1st Order
% We assumed the solution to our spring, mass, damper system was
% A*exp(lambda*t) -- Assume A = 1
% If we assume that lamda is a real value we have two potential results
% lambda is negative or lambda is positive

%C=-1;
%m=1;
%k=1.25;
%lambda = -C/(2*m) - sqrt(C^2-4*m*k)/(2*m)

t = linspace(0,2,100);

% negative response
lambda = -2; % e.g., C = 2.5, m = 1, k = 1
neg_response = exp(lambda * t);
figure(1)
plot(t, neg_response, 'LineWidth',4.0)
xlabel('time')

% positive response
lambda = 1;
pos_response = exp(lambda * t);
figure(2)
plot(t, pos_response, 'LineWidth',4.0)
xlabel('time')


%% Spring Mass Damper: 2nd Order
% We assumed the solution to our spring, mass, damper system was
% A*exp(lambda*t) -- Assume A = 1
% If we assume that lamda is a complex value (alpha +/- j * beta * t)
% We can rearange the equation to be: A * exp(alpha) * cos(beta*t)
% we have two potential results alpha is negative or lambda is positive

t = linspace(0,10,100);
% negative response
alpha = -.5; % e.g., C = 1, m = 1, k = 1.25
beta = -1;
neg_response = exp(alpha * t).*cos(beta * t);
figure(3)
plot(t, neg_response, 'LineWidth',4.0)
xlabel('time')
hold on;
bound = exp(alpha*t);
plot(t, bound, '--r');
plot(t, -bound, '--r');
hold off;


alpha = .5; % e.g., C = -1, m = 1, k = 1.25
pos_response = exp(alpha * t).*cos(beta * t);
figure(4)
plot(t, pos_response, 'LineWidth',4.0)
xlabel('time')
hold on;
bound = exp(alpha*t);
plot(t, bound, '--r');
plot(t, -bound, '--r');
hold off;

%% State Space -- Spring Mass Damper's A Matrix
% We can represent the spring mass damper system as a matrix
clear; clc;

C=1;
m=1;
k=1.25;
A = [0, 1; -k/m, -C/m]

%% Linear Algebra - Determinate
% We use the determinant to calculate some properties of a matrix

det(A)

%% Linear Algebra - Eigen values & vectors
% The Eigen values are the same as the alpha and beta we calculated earlier

eig(A)


