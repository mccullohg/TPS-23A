function [beta0, beta1, beta2, ci] = stats_hwk(table1, alpha)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  TF6511A HWK  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% stats_hwk.m
%
% Author: 1st Lt Gordon McCulloh, 23A
% Derivative Authors: Juan Jurado, TPS ED
% Date: 3 Mar 2023
% 
% Description: Data and statistical analysis code for TF 6511A: Statistics
% for Flight Testers Take-Home Exercise
%
% Inputs: table1 - Linear model data (.csv)
%         alpha - confidence level (e.g. 0.05)
%
% Outputs: beta0, beta1, beta2 - model coefficients
%          ci - confidence interval coefficients
%          Breusch-Pagan test result
%          Kolmogorov-Smirnov test result
%          Durbin-Watson test result
%
% Paired files: BPtest.m - Breusch-Pagan test for constant variance
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Load data table
data = readtable(table1);

% Assign variables
x1 = data.x1;
y = data.y;

% Sample size
N = length(x1);

% Second-order model structure
xMdl = [ones(N,1), x1, x1.^2];
P = size(xMdl,2);  % model size

%% 8. Fit second-order model
% mdl = fitlm(x1, y);  % linear
mdl = fitlm(xMdl(:, 2:end), y);
yHat = mdl.Fitted;
betaHat = mdl.Coefficients.Estimate;  % model coefficients
beta0 = betaHat(1); beta1 = betaHat(2); beta2 = betaHat(3); 

%% 9. Validation tests
% Compute residuals
eRaw = y-yHat;  
eStd = mdl.Residuals.Standardized;

% Residual inspection
f = figure('Name','Residual Inspection');
f.Position = [0 0 800 600];
hold on
subplot(2,1,1);
plot(x1,eRaw,'bo','MarkerFaceColor','b');
title('\bf Data Residual Visualization');
xlabel('$x_1$');
ylabel('Raw residual value, $e_i$');
grid minor;

subplot(2,1,2);
plot(x1,eStd,'bo','MarkerFaceColor','b');
xlabel('$x_1$');
ylabel('Stand. residual value, $s_i$');
grid minor;
hold off

% Plot residual histograms
f = figure('Name','Residual Test for Normality');
f.Position = [0 0 800 600]; 
hold on
subplot(2,1,1);
histogram(eRaw,N,'Normalization','pdf');
title('\bf Data Residual Normality');
xlabel('Raw residual value, $e_i$');
ylabel('$p(e_i)$');
grid minor;

subplot(2,1,2);
histogram(eStd,N,'Normalization','pdf');
xlabel('Stand. residual value, $s_i$');
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

f = figure('Name','Komogorov-Smirnov Test');
f.Position = [0 0 700 600]; 
hold on; 
grid minor;
plot(cdfX, cdfY,'LineWidth',2);
plot(eSort, CDF,'r-','LineWidth',2);
legend('Empirical CDF of Residuals','Theoretical CDF of residuals','Location','NorthWest')
title('\bf Example Kolmogorov-Smirnov Test Plot');
xlabel('Ordered Residuals');
ylabel('Cumulative Distribution Function');

% Durbin-Watson test for serial correlation
xDw = [ones(size(xMdl, 1), 1) xMdl];
[~,idx] = sort(x1,'ascend');
p = dwtest(mdl.Residuals.Raw(idx), xDw);
if p < alpha
    disp('D-W Test: Reject H0, residuals are correlated');
else
    disp('D-W Test: Fail to reject H0, residuals are uncorrelated');
end

% Breusch-Pagan test for constant variance
[~,p,~] = BPtest([xMdl y]);
if p > alpha
    disp('B-P Test: Fail to reject H0, residuals have constant variance')
else
    disp('B-P Test: Reject H0, residuals do not have constant variance')
end

%% 10. 95% confidence intervals for each of the model coefficients

% t-test
t = tinv(1-alpha/2, N-P); 

% interval width
width = t*sqrt(mdl.MSE*diag(xMdl/((xMdl'*xMdl))*xMdl')); 

% inference
inference = [yHat-width yHat+width]; 

% inference coefficients
ci = coefCI(mdl,alpha);

% Plot confidence interval
f = figure('Name','Confidence Interval for Linear Model');
f.Position = [0 0 700 600];
plot(x1, y, 'bo','MarkerFaceColor','b')
hold on
plot(x1, yHat, 'r^')
plot(x1, inference, 'k:', 'LineWidth',2);
xlabel('$x_1$');
ylabel('y')
legend('data','model','95\% CI')
title('95\% Confidence Interval for Linear Model')
hold off

% Combined plot of results
f = figure('Name','Results');
f.Position = [0 0 1500 450];

subplot(1,3,1)
plot(x1, y, 'bo','MarkerFaceColor','b')
hold on
plot(x1, yHat, 'r^')
plot(x1, inference, 'k:', 'LineWidth',2);
hold off
xlabel('$x_1$');
ylabel('y')
legend('data, $\bf y$','Est. model response, $\bf \hat{y}$',...
    '95\% Conf. band')
title('\bf TF6511: Second-order Model with Inferences', 'Fontsize', 14)

subplot(1,3,2)
grid minor
plot(x1,eRaw,'bo','MarkerFaceColor','b');
xlabel('$x_1$');
ylabel('Raw residual value, $e_i$');
title('\bf Second-order Model Residuals', 'Fontsize', 14);

subplot(1,3,3)
grid minor
hold on
plot(cdfX, cdfY,'LineWidth',2);
plot(eSort, CDF,'r-','LineWidth',2);
hold off
legend('Empirical CDF of Residuals','Theoretical CDF of residuals','Location','NorthWest')
xlabel('Ordered Residuals');
ylabel('Cumulative Distribution Function');
title('\bf Example Kolmogorov-Smirnov Test Plot', 'Fontsize', 14);

end