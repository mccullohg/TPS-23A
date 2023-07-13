%%%%%%%%%%%%%%%%%%%%%%%%%%%%  TF6511A PROJECT  %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% stats_proj.m
%
% Authors: 1st Lt Gordon McCulloh, 23A
%          Seeeeeeee-12 Data Group
% Derivative Authors: Juan Jurado, TPS ED
% Date: 10 Mar 2023
% 
% Description: Data and statistical analysis code for TF 6511A: Statistics
% for Flight Testers group project, C-12 EPIC Modification.
%
% Inputs: Group-3_TakeoffData.mat - C-12 EPIC TO data file 
%         Group-3_Ps_Data.mat - C-12 EPIC vs Non-EPIC Ps data file
%
% Outputs: mdl - 4 parameter linear model for takeoff FQ
%          PI, CI - prediction/confidence intervals for mdl
%          residual validation - BP, KS, and DW test results 
%          detection plots - detection/false alarm analyis for Ps data
%
% Paired files: BPtest.m - Breusch-Pagan test for constant variance
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Evaluate Takeoff Performance
clear all; close all; clc;

set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');

% Load group 3 data
toData = load('Group-3_TakeoffData.mat');

% Load predictor variable (weight) and response variable (distance)
y = toData.groundRoll_ft;
x1 = toData.pressureAltitude;
x2 = toData.OAT_c;
x3 = toData.headWind_kts;
x4 = toData.takeoffWeight_lbs/1000;

N = length(y);

% Build design matrix using the two predictors
X = [ones(N,1), x1, x2, x3, x4];

% Use fitlm to fit linear model
mdl = fitlm([x1 x2 x3 x4],y)
betaHat = mdl.Coefficients.Estimate;

% Compare multiple intervals versus a band
X1band = linspace(min(x1),max(x1),100)'; % A smooth band of input conditions
Xh = [1, 3500, 8.07, 0, 12.5]; % One prediction at (y intercept*1, x1 = 3500 PA, x2 = 8.07 *C, x3 = 0 knt headwind, x4 = 12.5 klbs
g = size(Xh, 1); % Number of g simultaneous inferences
alpha = 0.05; % Significance level for the "family" of  inferences
alpha_b = alpha/g; % Significance level for each individual inference

P = length(betaHat); % Beta is P X 1
df = N - P; % Degrees of freedom = N - P
e = y - X*betaHat; % Error e = y - yHat
SSE = e'*e; % Sum of squared error is e^T * e
MSE = SSE/df; % Mean squared error is SSE / df
sigmaHat = sqrt(MSE); % Estimate of sigma is sqrt(MSE)

% Step 5: Build Xh, i.e., the input points where you want to predict 
M = size(Xh,1); % M (from slide 46 and 47) is the number of predictions

% Step 6: Predict the mean response at the input point(s)
yh = Xh*betaHat;

% Step 7: Compute the inference
tmult = tinv(1-alpha/2,df); % The "t" multiplier accounts for the area under the curve for this alpha
S = Xh*((X'*X)\Xh'); % This is the inside of the square root; it is an M x M matrix
m = 1; % or 2 (since we have 2 predictions), this is the "mth" predcition you want to draw an infrenrece around 
CI = tmult*sigmaHat*sqrt(S(m,m)) % this is the +- piece in slide 46
PI = tmult*sigmaHat*sqrt(1+ S(m,m)) % this is the +- piece in slide 47

% Print results
fprintf('Predicted Ground Roll 3500PA is #%d \n', yh);
fprintf('Confidence interval for prediction #%d is [%0.3f, %0.3f]\n', m, yh(m) - CI, yh(m) + CI);
fprintf('Prediction interval for prediction #%d is [%0.3f, %0.3f]\n', m, yh(m) - PI, yh(m) + PI);

%anova can be good to look at models as well
anova(mdl,'Summary')

% Prove our math matches fitlm
N = length(y);
X_manual = [ones(N,1), x1];
betaHat_man = X_manual\y;
yHat_man = X_manual*betaHat_man;

% residual analysis
% Compute residuals and plot diagnostics
yHat = mdl.Fitted;
eRaw = y-yHat;
eStd = mdl.Residuals.Standardized;

% Residual inspection
f = figure('Name','Residual Inspection');
f.Position = [0 0 800 600];
hold on

subplot(4,1,1);
plot(x1,eStd,'bo','MarkerFaceColor','b');
title('\bf Data Residual Visualization');
xlabel('Pressure Altitude');
ylabel('Stand. residual, $s_i$');
grid minor;

subplot(4,1,2);
plot(x2,eStd,'bo','MarkerFaceColor','b');
xlabel('OAT, $T_a$');
ylabel('Stand. residual, $s_i$');
grid minor;

subplot(4,1,3);
plot(x3,eStd,'bo','MarkerFaceColor','b');
xlabel('Head Wind');
ylabel('Stand. residual, $s_i$');
grid minor;

subplot(4,1,4);
plot(x4,eStd,'bo','MarkerFaceColor','b');
xlabel('Takeoff Weight');
ylabel('Stand. residual, $s_i$');
grid minor;
hold off

% Plot residual histograms
f = figure('Name','Residual Test for Normality');
f.Position = [0 0 800 600]; 
hold on
subplot(2,1,1);
histogram(eRaw,N,'Normalization','pdf');
title('\bf Data Residual Normality');
xlabel('Raw residual, $e_i$');
ylabel('$p(e_i)$');
grid minor;

subplot(2,1,2);
histogram(eStd,N,'Normalization','pdf');
xlabel('Stand. residual, $s_i$');
ylabel('$p(s_i)$');
grid minor;
hold off

% Kolmogorov-Smirnov test for normality
eSort = sort(eRaw);
sigma = sqrt(mdl.MSE);
CDF = cdf('Normal',eSort,0,sigma);
H = kstest(eRaw,'Alpha',alpha,'CDF',[eSort CDF]);
if H==0
    disp('K-S Test: Fail to reject H0, residuals are Normal')
else
    disp('K-S Test: Reject H0, residuals are NOT Normal')
end
[cdfY,cdfX] = ecdf(eSort);

% Durbin-Watson test for serial correlation
xDw = [ones(size(X, 1), 1) X];
[~,idx] = sort(x1,'ascend');
p = dwtest(mdl.Residuals.Raw(idx), x1);
if p < alpha
    disp('D-W Test: Reject H0, residuals are correlated for x1');
else
    disp('D-W Test: Fail to reject H0, residuals are uncorrelated for x1');
end

p = dwtest(mdl.Residuals.Raw(idx), x2);
if p < alpha
    disp('D-W Test: Reject H0, residuals are correlated for x2');
else
    disp('D-W Test: Fail to reject H0, residuals are uncorrelated for x2');
end

p = dwtest(mdl.Residuals.Raw(idx), x3);
if p < alpha
    disp('D-W Test: Reject H0, residuals are correlated for x3');
else
    disp('D-W Test: Fail to reject H0, residuals are uncorrelated for x3');
end

p = dwtest(mdl.Residuals.Raw(idx), x4);
if p < alpha
    disp('D-W Test: Reject H0, residuals are correlated for x4');
else
    disp('D-W Test: Fail to reject H0, residuals are uncorrelated for x4');
end

% Breusch-Pagan test for constant variance
[~,p,~] = BPtest([X y]);
if p > alpha
    disp('B-P Test: Fail to reject H0, residuals have constant variance')
else
    disp('B-P Test: Reject H0, residuals do not have constant variance')
end

%% Evaluate EPIC vs non-EPIC Specific Excess Power
clear all; close all; clc;

% Load group 3 data
psData = load('Group-3_Ps_Data.mat');

% Assign response variables (y)
psEpic = psData.specificExcessPowerEPIC_fps;
psNon = psData.specificExcessPowerNonEPIC_fps;

% Assign predictor variables (x1, ..., xn)
kias = psData.indicatedAirspeed_kts;

% Sample size
N = length(psEpic);

% EPIC vs non-EPIC distribution data
muEpic = mean(psEpic);
sigmaEpic = std(psEpic);
muNon = mean(psNon);
sigmaNon = std(psNon);

% Theoretical distributions
xBand = linspace(min([muEpic-3*sigmaEpic muNon-3*sigmaNon]), ...
    max([muEpic+3*sigmaEpic muNon+3*sigmaNon]), 1001)';

% Probability density functions
pdfEpic = normpdf(xBand, muEpic, sigmaEpic);
pdfNon = normpdf(xBand, muNon, sigmaNon);

f = figure('Name','Detection (static)');
f.Position = [0 0 750 540];
f.Color = [248 248 248]/255;
h(1) = plot(xBand, pdfEpic, 'b-', 'Linewidth', 2);
hold on
h(2) = plot(xBand, pdfNon, 'r-', 'Linewidth', 2);
h(3) = line([30.54;30.54],[0;max([pdfEpic(775); pdfNon(775)])],'Color','k','LineWidth',2);
h(4) = area(xBand(775:1001), pdfEpic(775:1001),'FaceColor','b','FaceAlpha',0.5,'EdgeAlpha',0);
h(5) = area(xBand(775:1001), pdfNon(775:1001),'FaceColor','r','FaceAlpha',0.5,'EdgeAlpha',0);
axis tight; grid minor;
legend(h,'EPIC Distribution','Non-EPIC Distribution','Detection Threshold',...
         'P(detection)','P(false alarm)','location','NorthWest');
title('\bf EPIC vs Non-EPIC Probability of Detection');
xlabel('Specific Excess Power, $P_s$');
ylabel('Probability');
hold off

% Animate detection threshold
f = figure('Name','Detection (animation)');
filename = 'detection.gif';
f.Position = [0 0 1000 800];
f.Color = [248 248 248]/255;
hold on
h(1) = plot(xBand, pdfEpic, 'b-', 'Linewidth', 2);
h(2) = plot(xBand, pdfNon, 'r-', 'Linewidth', 2);
h(3) = line([0;0],[0;max([pdfEpic; pdfNon])],'Color','k','LineWidth',2);
h(4) = area(nan, nan,'FaceColor','b','FaceAlpha',0.5,'EdgeAlpha',0);
h(5) = area(nan, nan,'FaceColor','r','FaceAlpha',0.5,'EdgeAlpha',0);
axis tight; grid minor;
legend(h,'EPIC Distribution','Non-EPIC Distribution','Detection Threshold',...
         'P(detection)','P(false alarm)','location','NorthWest');
title('\bf EPIC vs Non-EPIC Probability of Detection');
xlabel('Specific Excess Power, $P_s$');
ylabel('Probability');

ta = linspace(muEpic,30.54,101)';
for ii = 1:length(ta)
    set(h(3),'XData',[ta(ii);ta(ii)]);
    xVec = linspace(ta(ii),xBand(end),101)';
    pdfEpicNew = normpdf(xVec, muEpic, sigmaEpic);
    pdfNonNew = normpdf(xVec, muNon, sigmaNon);
    set(h(4),'XData',xVec,'YData',pdfEpicNew);
    set(h(5),'XData',xVec,'YData',pdfNonNew-pdfEpicNew);
    pause(0.01);
    drawnow
    frame = getframe(2);
    im = frame2im(frame);
    [imind, cm] = rgb2ind(im,256);
    if ii == 1
        imwrite(imind,cm,filename,'gif','Loopcount',inf);
    else
        imwrite(imind,cm,filename,'gif','WriteMode','append');
    end
end
hold off