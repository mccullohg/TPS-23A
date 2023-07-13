%%%%%%%%%%%%%%%%%%  MIGHTY HURON AEROMOD ANALYSIS  %%%%%%%%%%%%%%%%%%
%
% aeromod_huron_23a.m
%
% Author: 1st Lt Gordon McCulloh, FTE (23A)
% Date: 8 May 2023
% 
% Description: aeromod_huron_23a.m contains the main body of the
% aeromodeling code for the C-12 data group in the performance phase of the
% TPS curriculum. The script ingests a DAS file as well as the C-12 thrust
% models to generate lift curves and drag polars. Run section-by-section
% using the appropriate lift and drag models per configuration. Adjust
% filename, gross weight, event numbers, config/weight labels, and sample 
% rate as required for performance plots.
%
% Inputs:   filename - DAS file
%           alphaBias - AOA probe bias 
%           Wrc - roller coaster weight
%           Wwut - wind-up turn weight
%           eventRc - roller coaster event range
%           eventWut - wind-up turn event range
%           config - configuration label
%           speed - airspeed label
%           srRc/Wut - data sample rates
%
% Outputs: lift curve, drag polar
%
% Paired files: tpsread.m - import DAS data
%               testPointTitle.m - format plots
%               clCalc.m - calculate lift and coefficient of lift
%               cdCalc.m - calculate drag and coefficient of drag
%               thrustModel.m - calculate gross thrust according to the
%                               engine_prop_model spreadsheet
%
% Rolex/Gordon Data: W = [11700 11350 11600 11400 11300 11450 11550 11500]
%                    eventNums = [11 58 25 51 69 44 37 42]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT
cd '\\Fspm-fs-033v\tps$\Org\23-A\0. C12 Data Group\4. Reports\Aeromod\Gordons Most Excellent Code'
filename = 'McCulloh 27 Apr 158 Aeromod.csv';

% Set defaults for plots
set(groot,'DefaultTextInterpreter','tex');
set(groot,'DefaultLegendInterpreter', 'tex');
set(groot,'defaultAxesTickLabelInterpreter','tex'); 
set(groot,'DefaultAxesFontSize',16);
set(groot,'DefaultTextFontSize',16);
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');

% Import data 
data = tpsread(filename);

% Write data to variables;
events = data.ICU_EVNT_CNT;  
alphaV = data.POS_AOA;  % deg
vT = data.ADC_TAS;  % KTAS
q = data.AHRS_EPRT;  % deg/s
nx = data.AHRS_BLGA;  % g
nz = data.AHRS_BNMA;  % g
sat = data.ADC_SAT;  % deg C
pa = data.ADC_ALT_29;  % ft
tqL = data.TORQ_LE;
tqR = data.TORQ_RE;
vC = data.ADC_IAS;  % KIAS to KCAS

% Constants (tail 158)
g = 32.17;  % ft/s^2
rpm = 1700;
S = 303;  % ft^2
Lx = 18.5;  % ft
it = 0;  % deg 
Fe = 0;  % lbf 

% Data corrections
alphaBias = 3.5;  % deg
vT = 1.6878*vT;  % ft/s
vC = 1.6878*vC;  % ft/s
alphaT = rad2deg(deg2rad(alphaV)+deg2rad(q)*Lx./vT);  % deg
ax = nx*g;  % ft/s^2
az = -nz*g;  % ft/s^2 - body frame

%% Clean Config Models
% clModel = [0.000 0.700 0.750 0.800 0.850 0.900 0.950 1.000 1.050 1.100 ...
%     1.125 1.150];  % cT = 0
clModel = [0.000 0.700 0.750 0.800 0.850 0.900 0.950 1.000 1.050 1.100 ...
    1.125 1.150 1.200 1.225];  % cT = .15
% alphaModel = [-2.083 5.208 5.880 6.710 7.750 8.820 10.180 11.680 13.500 ...
%     16.040 19.980 20.000];  % cT = 0
alphaModel = [-2.122 4.668 5.280 6.010 6.900 7.900 9.060 10.390 11.820...
    13.450 14.420 15.730 19.850 20.000];  % cT = .15
clLower = clModel-0.1;  clUpper = clModel+0.1;  % eval criteria

clcd = [-0.50 -0.40 -0.30 -0.20 -0.10 0.00 0.05 0.10 0.15 0.20 0.25... 
    0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90...
    0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00];
cdModel = [0.04443 0.04055 0.03753 0.03537 0.03408 0.03365 0.03376 ...
    0.03408 0.03462 0.03537 0.03634 0.03753 0.03893 0.04055 0.04238 ...
    0.04443 0.04669 0.04917 0.05186 0.05477 0.05789 0.06123 0.06479 ...
    0.06856 0.07255 0.07675 0.08580 0.09571 0.10649 0.11813 0.13063 ...
    0.14399 0.15821 0.17329 0.18924 0.20605]; % cT = .15
cdLower = cdModel-0.03;   cdUpper = cdModel+0.03;  % eval criteria

%% Dirty Config Models
clModel = [0.000 0.700 1.000 1.050 1.100 1.150 1.200 1.250 1.300 1.350...
    1.400 1.450 1.500];
alphaModel = [-4.675 1.970 4.817 5.310 5.860 6.430 7.030 7.740 8.600...
    9.500 10.950 19.000 20.000];  % cT = .15
clLower = clModel-0.1;  clUpper = clModel+0.1;  % eval criteria

clcd = [-0.50 -0.40 -0.30 -0.20 -0.10 0.00 0.05 0.10 0.15 0.20 0.25... 
    0.30 0.35 0.40 0.45 0.50 0.55 0.60 0.65 0.70 0.75 0.80 0.85 0.90...
    0.95 1.00 1.10 1.20 1.30 1.40 1.50 1.60 1.70 1.80 1.90 2.00];
cdModel = [0.07432 0.06980 0.06629 0.06378 0.06227 0.06177 0.06190...
    0.06227 0.06290 0.06378 0.06491 0.06629 0.06792 0.06980 0.07194...
    0.07432 0.07696 0.07985 0.08298 0.08637 0.09001 0.09390 0.09805...
    0.10244 0.10708 0.11198 0.12252 0.13407 0.14662 0.16018 0.17474...
    0.19031 0.20688 0.22445 0.24303 0.26261];  % cT = .15
cdLower = cdModel-0.03;   cdUpper = cdModel+0.03;  % eval criteria

%% Clean Configuration
close all; clc;

% --- MANUAL ENTRY ---
Wrc = 11300;  Wwut = 11450;  % lbs
eventRC = 69:70;  eventWUT = 44:45;  % start:end
config = 'Cruise'; 
speed = '120 KIAS';
weight = '11,300-11,450 lbs';
srRc = 4;  srWut = 8;  % sample rate

% DAS data indices
idRc0 = find(events == eventRC(1),1); 
idRcf = find(events == eventRC(2),1);
idWut0 = find(events == eventWUT(1),1);
idWutf = find(events == eventWUT(2),1);


% Data sets
alphaTrc = alphaT(idRc0:idRcf)-alphaT(idRc0-10)+alphaBias;  % remove bias
alphaTwut = alphaT(idWut0:idWutf)-alphaT(idWut0-10)+alphaBias;
vTrc = vT(idRc0:idRcf);  vTwut = vT(idWut0:idWutf);
axRc = ax(idRc0:idRcf);  axWut = ax(idWut0:idWutf);
azRc = az(idRc0:idRcf);  azWut = az(idWut0:idWutf);

% Data points
satRc = sat(idRc0);  satWut = sat(idWut0);
paRc = pa(idRc0);  paWut = pa(idWut0);
tqRc = mean([tqL(idRc0),tqR(idRc0)]); 
tqWut = mean([tqL(idWut0),tqR(idWut0)]);
vCrc = vC(idRc0);  vCwut = vC(idWut0);

% Calculate thrust, lift, and drag
[FgRc,cTrc,rhoRc] = thrustModel('engine_prop_model.xlsx',vCrc,...
    vTrc(1),rpm,satRc,tqRc,paRc);
[FgWut,cTwut,rhoWut] = thrustModel('engine_prop_model.xlsx',vCwut,...
    vTwut(1),rpm,satWut,tqWut,paWut);
[Lrc,cLrc] = clCalc(Wrc,alphaTrc,FgRc,axRc,azRc,rhoRc,S,vTrc);
[Lwut,cLwut] = clCalc(Wwut,alphaTwut,FgWut,axWut,azWut,rhoWut,S,vTwut);
[Drc,cDrc] = cdCalc(Wrc,alphaTrc,FgRc,Fe,axRc,azRc,it,rhoRc,S,vTrc);
[Dwut,cDwut] = cdCalc(Wwut,alphaTwut,FgWut,Fe,axWut,azWut,it,rhoWut,...
    S,vTwut);

% Plot lift curve
f = figure('Units','inches');
f.Position = [0 0 11 8.5];
f.Name = 'Lift Curve';
hold on
h1 = scatter(alphaTrc(1:srRc:end),cLrc(1:srRc:end),'sk','filled');  % data
h2 = scatter(alphaTwut(1:srWut:end),cLwut(1:srWut:end),'ok');
plot(alphaModel,clModel,'k');  % model
plot(alphaModel,clLower,'--','color','k')
plot(alphaModel,clUpper,'--','color','k')
grid minor
axis tight
xlabel('Angle of Attack, \alpha (deg)','FontName','Helvetica',...
    'FontSize',16,'FontWeight','bold')
ylabel('Lift Coefficient, C_{L}','FontName','Helvetica',...
    'FontSize',16,'FontWeight','bold')
legend([h1(1),h2(1)],'Roller Coaster', 'Wind Up Turn','location','east');
bigTitle = (['C-12 Lift Curve: ',speed]);
col1 = {['Configuration: ',config];['Weight: ',weight];
        'CG: 19.3%';'Altitude: 15,000 ft';
        'Wing Reference Area: 303 sq ft'};
col2 = {'Data Basis: Flight Test';'Test Date: 27 April 2023';
        'Test Day Data';'PRPM: 1700';'Temperature: ISA'};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off

% Plot drag polar 
f = figure('Units','inches');
f.Position = [0 0 11 8.5];
f.Name = 'Drag Polar';
hold on
h1 = scatter(cDrc(1:srRc:end),cLrc(1:srRc:end),'sk','filled');  % data
h2 = scatter(cDwut(1:srWut:end),cLwut(1:srWut:end),'ok');
plot(cdModel,clcd,'k');  % model
plot(cdLower,clcd,'--','color','k')
plot(cdUpper,clcd,'--','color','k')
grid minor
axis tight
xlabel('Drag Coefficient, C_{D}','FontName','Helvetica',...
    'FontSize',16,'FontWeight','bold')
ylabel('Lift Coefficient, C_{L}','FontName','Helvetica',...
    'FontSize',16,'FontWeight','bold')
legend([h1(1),h2(1)],'Roller Coaster', 'Wind Up Turn','location','east');
bigTitle = (['C-12 Drag Polar: ',speed]);
col1 = {['Configuration: ',config];['Weight: ',weight];
        'CG: 19.3%';'Altitude: 15,000 ft';
        'Wing Reference Area: 303 sq ft'};
col2 = {'Data Basis: Flight Test';'Test Date: 27 April 2023';
        'Test Day Data';'PRPM: 1700';'Temperature: ISA'};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off

