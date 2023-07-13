%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  TOWER FLYBY  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% tfb_c12.m
%
% Author:   1st Lt Gordon McCulloh, 23A
%           Derivative Authors: Capt Alex Brown (23A)
%                               1st Lt Noah Diamond (23A)
%                               Juan Jurado (ED)
%
% Date:     13 Feb - 3 Mar 2023
%
% Description: Data reduction and figure formatting for air data
% calibration from the Tower Flyby (TFB) events in February 2023. This file
% specifically belongs to the C-12 data group.
%
% Inputs:   CSV, XLSX - DAS/ACMI flight data
%           'tfb_master.csv' - (RAW)
%           'Swartz 13 Feb 302 Tower Flyby.csv' - ROLEX (DAS)
%           rolex - DAS data import toggle
%
% Outputs:  
%
% Paired files: testPointTitle.m - TPS figure formatting
%               TFB_calculator.m - arithmetic converting indicated
%                                  parameters to position corrected data
%               tpstime.m - convert IRIG to seconds
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc;

% Select DAS import option
rolex = 1;

% Import and assign master raw data
masterData = readtable('tfb_master.csv');

% Assign imported card data to working variables
rdg1 = str2double(table2array(masterData(2:12, 7)));  % grid reading
rdg2 = str2double(table2array(masterData(13:22, 7)));
rdg3 = str2double(table2array(masterData(23:33, 7)));
rdg4 = str2double(table2array(masterData(34:44, 7)));
rhoH1 = str2double(table2array(masterData(2:12, 8)));  % density altitude
rhoH2 = str2double(table2array(masterData(13:22, 8)));
rhoH3 = str2double(table2array(masterData(23:33, 8)));
rhoH4 = str2double(table2array(masterData(34:44, 8)));
Ta1 = str2double(table2array(masterData(2:12, 9)));  % ambient temperature
Ta2 = str2double(table2array(masterData(13:22, 9)));
Ta3 = str2double(table2array(masterData(23:33, 9)));
Ta4 = str2double(table2array(masterData(34:44, 9)));
fuel1 = str2double(table2array(masterData(2:12, 13)));  % fuel
fuel2 = str2double(table2array(masterData(13:22, 13)));
fuel3 = str2double(table2array(masterData(23:33, 13)));
fuel4 = str2double(table2array(masterData(34:44, 13)));
Hi1 = str2double(table2array(masterData(2:12, 14)));  % indicated altitude
Hi2 = str2double(table2array(masterData(13:22, 14)));
Hi3 = str2double(table2array(masterData(23:33, 14)));
Hi4 = str2double(table2array(masterData(34:44, 14)));
Vi1 = str2double(table2array(masterData(2:12, 15)));  % indicated velocity
Vi2 = str2double(table2array(masterData(13:22, 15)));
Vi3 = str2double(table2array(masterData(23:33, 15)));
Vi4 = str2double(table2array(masterData(34:44, 15)));
vvi1 = str2double(table2array(masterData(2:12, 16)));  % vertical velocity indicator
vvi2 = str2double(table2array(masterData(13:22, 16)));
vvi3 = str2double(table2array(masterData(23:33, 16)));
vvi4 = str2double(table2array(masterData(34:44, 16)));

% Pull and assign DAS data for Rolex
if rolex == 1
    % Import DAS data
    rolexData = readtable('Swartz 13 Feb 302 Tower Flyby.xlsx');

    % Pull the desired parameters from the DAS
%     Time1 = tpstime(rolexData.('IRIG_TIME'));  % paired file
    allEvents = rolexData.('EVENT');
    altitude = rolexData.('EGI_ALTITUDE');
    pressureAlt = rolexData.('ADC_PRESSURE_ALTITUDE');
    airspeed = rolexData.('AIRSPEED_IC');
    mach = rolexData.('MACH_IC');
    Tic = rolexData.('TAT_DEGC');

    % Select events of interest
    nEvents = max(allEvents);
    myEvents = linspace(1,nEvents,nEvents);
    ids = zeros(nEvents,1);

    % Identify the start and end index for selected events
    for ii = 1:nEvents
        ids(ii) = find(allEvents==myEvents(ii),1);
    end

    % Reduce data based on select event marker
%     eventTime1 = Time1(ids);
    eventAlt1 = altitude(ids);
    Hic1 = pressureAlt(ids);
    Vic1 = airspeed(ids);
    eventMach1 = mach(ids);
    eventTic1 = Tic(ids);
end

% Calculate instrument/position corrected parameters
[dPp1, Mic1, qcic1, dHpc1, dVpc1, dMpc1, M1, Hc1] = TFB_calculator(Hi1, Vi1, rdg1, Ta1, rhoH1);
[dPp2, Mic2, qcic2, dHpc2, dVpc2, dMpc2, M2, Hc2] = TFB_calculator(Hi2, Vi2, rdg2, Ta2, rhoH2);
[dPp3, Mic3, qcic3, dHpc3, dVpc3, dMpc3, M3, Hc3] = TFB_calculator(Hi3, Vi3, rdg3, Ta3, rhoH3);
[dPp4, Mic4, qcic4, dHpc4, dVpc4, dMpc4, M4, Hc4] = TFB_calculator(Hi4, Vi4, rdg4, Ta4, rhoH4);

% Pre-define legend for plots
legend4 = {'Swartz (302)', 'Artz (264)', 'Ritchie (197)', 'Weed (264)'};

% Plot Mic vs dPp/qcic, static position error
% Raw data
f = figure('Name','Static Position Error');
f.Position = [10 10 800 800];
scatter(Mic1,dPp1./qcic1,'k','Marker','square')
hold on
scatter(Mic2,dPp2./qcic2,'k', 'Marker','diamond')
scatter(Mic3,dPp3./qcic3,'k', 'Marker','o')
scatter(Mic4,dPp4./qcic4,'k', 'Marker','^')
grid on; grid minor;
% axis size
xlabel('Instrument Corrected Mach Number, $M_{ic}$','FontSize',16,'interpreter','latex');
ylabel('Static Pressure Error Coefficient, $\frac{\Delta P_{p}}{q_{cic}}$','FontSize',16,'interpreter','latex');
legend(legend4)
bigTitle = '\bf Northrop T-38C Position Error';
col1 = {'Configuration: Cruise';
    'Weight: XX,XXX pounds';
    'CG: XX percent'};
col2 = {'Data Basis: Tower Flyby';
    'Test Dates: 13-22 Feb 2023';
    'Test Day Data'};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);  % paired file
hold off

% Remove Rolex outlier
Mic1 = [Mic1(1:8); Mic1(10:11)]; 
dPp1 = [dPp1(1:8); dPp1(10:11)];
qcic1 = [qcic1(1:8); qcic1(10:11)];

% Second-order interpolation
pfit = polyfit([Mic1; Mic2; Mic3; Mic4], ...
    [dPp1./qcic1; dPp2./qcic2; dPp3./qcic3; dPp4./qcic4], 2);
pval = polyval(pfit, linspace(0.29, 0.92, 50));

% Confidence interval
sigY = std([dPp1./qcic1; dPp2./qcic2; dPp3./qcic3; dPp4./qcic4]);

% Plot Mic vs dPp/qcic, static position error
% Delete outliers, curve fit, confidence interval
f = figure('Name','Static Position Error w/ Curve Fit');
f.Position = [10 10 800 800];
scatter(Mic1,dPp1./qcic1,'k','Marker','diamond')
hold on
scatter(Mic2,dPp2./qcic2,'k','Marker','diamond')
scatter(Mic3,dPp3./qcic3,'k','Marker','diamond')
scatter(Mic4,dPp4./qcic4,'k','Marker','diamond')
plot(linspace(0.29, 0.92, 50), pval,'k','LineWidth', 3)  % fit, conf int
plot(linspace(0.29, 0.92, 50), pval+sigY, 'k', 'LineStyle', '--')
plot(linspace(0.29, 0.92, 50), pval-sigY, 'k', 'LineStyle', '--')
grid on; grid minor;
axis([0 1.0 -0.03 0.04])
xlabel('Instrument Corrected Mach Number, $M_{ic}$','FontSize',16,'interpreter','latex');
ylabel('Static Pressure Error Coefficient, $\frac{\Delta P_{p}}{q_{cic}}$','FontSize',16,'interpreter','latex');
% legend(legend4)
bigTitle = '\bf Northrop T-38C Position Error';
col1 = {'Configuration: Cruise';
    'Weight: 9,500-12,800 pounds';
    'CG: 18-20 percent'};
col2 = {'Data Basis: Tower Flyby';
    'Test Dates: 13-22 Feb 2023';
    'Test Day Data'};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);  % paired file
hold off

% Change temperature units
Ta1 = Ta1 + 273.15;
eventTic1 = eventTic1 + 273.15;

% Linear interpolation
pfit = polyfit(M1.^2/5, eventTic1./Ta1-1, 1);
xv = linspace(0, 0.18, 50);
pval = polyval(pfit, xv);

% 95% confidence interval
[~,cInt] = regress(eventTic1./Ta1-1, [ones(size(M1.^2/5)) M1.^2/5]);
cLow = cInt(1,1)+cInt(2,1)*xv;
cUpp = cInt(1,2)+cInt(2,2)*xv;

% Plot Mach parameter vs Temp parameter, temperature calibration
f = figure('Name','Temperature Calibration');
f.Position = [10 10 800 800];
scatter(M1.^2/5,eventTic1./Ta1-1,'k','Marker','diamond')
hold on
plot(xv, pval,'k','LineWidth', 1)  % fit
plot(xv, cLow,'k','LineStyle', '--')  % conf int
plot(xv, cUpp,'k','LineStyle', '--')
grid on; grid minor;
% axis([0 0.18 -0.45 0])
axis auto
xlabel('Mach Parameter, $M^2/5$','FontSize',16,'interpreter','latex');
ylabel('Temperature Parameter, $T_{ic}/T_a-1$','FontSize',16,'interpreter','latex');
% legend('Swartz (302)')
bigTitle = '\bf Northrop T-38C Temperature Calibration';
col1 = {'Configuration: Cruise';
    'Weight: 10,000-12,000 pounds';
    'CG: 19.25 percent'};
col2 = {'Data Basis: Tower Flyby';
    'Test Dates: 13 Feb 2023';
    'Test Day Data'};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);  % paired file
hold off