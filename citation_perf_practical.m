%%%%%%%%%%%%%%%%%  PERF PRACTICAL EXAM  %%%%%%%%%%%%%%%%%
%
% citation_perf_practical.m
%
% Author: 1st Lt Gordon McCulloh, FTE (23A)
% Date: 16 May 2023
% 
% Description: plots the MCP specific excess power, turn performance, and
% alitude vs standardized time/distance/fuel to climb and descend using
% flight test data acquired 11 May 2023 in the C550 Citation II.
%
% Inputs: flight test data
%
% Outputs: time/distance/fuel to climb plots
%          specific excess power plots
%          turn performance doghouse plots
%
% Paired files: testPointTitle.m - TPS column header plotting function 
%               exportAsPdf.m - converts figures to pdf save files
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc;

% Set default formats
set(groot,'DefaultTextInterpreter','tex');
set(groot,'DefaultLegendInterpreter', 'tex');
set(groot,'defaultAxesTickLabelInterpreter','tex'); 
set(groot,'DefaultAxesFontSize',16);
set(groot,'DefaultTextFontSize',12);
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');

% Constants
alpha = 0.05;
asl = 1116.4;  % ft/s
g = 32.2;  % ft/s^2
rhosl = 0.002377;  % slug/ft^3
S = 342.6;  % ft^2

% ----- Data -----
% Climb
hClimb = 7000:1000:22000;
vClimb = [180 179 178 177 176 177 174 170 171 167 167 167 166 164 164 160];
tClimb = [0 24 47 70 95 115 136 161 189 214 242 273 304 336 370 402];
ffClimb = 2*[1110 1070 1030 1010 980 950 930 890 870 850 820 790 770 730 700 690];
tempClimb = 11:-2:-19;
% Descent
hDescent = 20000:-1000:10000;
vDescent = [235 228 224 222 224 223 220 221 220 226 221];
tDescent = [0 32 61 91 120 149 179 210 240 270 302];
ffDescent = 600*ones(1,11);
tempDescent = -15:2:5;
% Level Accel
hAccel = [25060 24980 24990 24990 25010 25030 25000 25000 25000 25010 25000 25090 25000];
vAccel = 110:10:230;
vH = 236.5;
tAccel = [0 5 14 24 37 48 61 75 90 108 132 154 206];
tempAccel = -24*ones(1,length(tAccel));
% Sawtooths
hSawtooth = [24500 25000 25500];
tempSawtooth = -24;
vSawMax1 = [153 152 152];
vSawMax2 = [152 152 152];
tSawMax1 = [0 22 43];
tSawMax2 = [0 20 40];
vSawLow1 = [114 115 115];
vSawLow2 = [115 115 115];
tSawLow1 = [0 22 49];
tSawLow2 = [0 23 44];
% Turns
hAnchor = 22800;
vAnchor = 179;
tempTurn = -20;
hTurn20 = 22840;
vTurn20 = 179;
tTurn20 = 235;
hTurn30 = 22800;
vTurn30 = 178;
tTurn30 = 146;
hTurnSlow = 23400;
vTurnSlow = 158;
tTurnSlow = 78;
% Incremental Drag
hDrag = [710 590];
vDrag = 147;

% --- Flight Manual Models ---
% Climb
tclimbMdl = [0 6.7];  % min
hclimbMdl = [7000 22000];  % ft PA
fuelclimbMdl = [0 192.8];  % lbs
distclimbMdl = [0 24.6];  % nm
% Descent
tdescentMdl = [0 5];  % min
hdescentMdl = [20000 10000];  % ft PA
fueldescentMdl = [0 50];  % lbs
distdescentMdl = [0 22.5];  % nm

% --- CLIMB ---
delta = (1-6.87559e-6*hClimb).^5.2559;
M = sqrt(5.*((1./delta.*((1+0.2.*((vClimb.*1.689)./asl).^2).^(7/2)-1)+1).^(2/7)-1));
rankineTest = ((tempClimb*1.8)+32)+460.67;  % R
a = sqrt(1.4*1716*rankineTest);  % ft/s

vtClimb = M.*a/1.689;  % kts
distClimb = vtClimb.*tClimb/3600;  % nm
theta = asind((max(hclimbMdl)-min(hclimbMdl))/(max(distClimb)*6076));  % deg
distClimb = cosd(theta)*distClimb;  % nm

fuelClimb = ffClimb.*tClimb/3600;  % lbs

f = figure('Units','inches');  % TIME
f.Position = [0 0 11 8.5];                                                                                                                                                                 
% scatter(tClimb/60,hClimb,80,'k','diamond','filled');
plot(tClimb/60,hClimb,'k','LineWidth',2);
hold on
grid minor
plot(tclimbMdl,hclimbMdl,'k','LineWidth',1);
plot(tclimbMdl*1.15,hclimbMdl,'k--','LineWidth',1);
plot(tclimbMdl*0.85,hclimbMdl,'k--','LineWidth',1);
xlabel('Standardized Time to Climb, t (min)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
ylabel('Pressure Altitude, H_{c} (ft)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
axis([0 8 0 25000])
bigTitle = 'Cessna Citation II Time to Climb';
col1 = {'Configuration: Cruise';'Climb Schedule: Flight Manual';
        'N1: 99-102 %';'Weight: 12,600 lbs';
        'CG: 285.5 in (30 %)';};
col2 = {'Data Basis: Flight Test'; 'Test Date: 11 May 2023';
        'Test Day Data';'Temperature: ISA+10°C'
        'Anti-Ice Systems: OFF';};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off
% exportAsPdf('Climb_Time');

f = figure('Units','inches');  % DISTANCE
f.Position = [0 0 11 8.5];                                                                                                                                                                 
% scatter(distClimb,hClimb,80,'k','diamond','filled');
plot(distClimb,hClimb,'k','LineWidth',2);
hold on
grid minor
plot(distclimbMdl,hclimbMdl,'k','LineWidth',1);
plot(distclimbMdl*1.15,hclimbMdl,'k--','LineWidth',1);
plot(distclimbMdl*0.85,hclimbMdl,'k--','LineWidth',1);
xlabel('Standardized Distance to Climb, S (nm)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
ylabel('Pressure Altitude, H_{c} (ft)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
axis([0 30 0 25000])
bigTitle = 'Cessna Citation II Distance to Climb';
col1 = {'Configuration: Cruise';'Climb Schedule: Flight Manual';
        'N1: 99-102 %';'Weight: 12,600 lbs';
        'CG: 285.5 in (30 %)';};
col2 = {'Data Basis: Flight Test'; 'Test Date: 11 May 2023';
        'Test Day Data';'Temperature: ISA+10°C'
        'Anti-Ice Systems: OFF';};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off
% exportAsPdf('Climb_Distance')

f = figure('Units','inches');  % FUEL
f.Position = [0 0 11 8.5];                                                                                                                                                                 
% scatter(fuelClimb,hClimb,80,'k','diamond','filled');
plot(fuelClimb,hClimb,'k','LineWidth',2')
hold on
grid minor
plot(fuelclimbMdl,hclimbMdl,'k','LineWidth',1);
plot(fuelclimbMdl*1.15,hclimbMdl,'k--','LineWidth',1);
plot(fuelclimbMdl*0.85,hclimbMdl,'k--','LineWidth',1);
xlabel('Standardized Fuel to Climb, W_{f} (lbs)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
ylabel('Pressure Altitude, H_{c} (ft)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
axis([0 240 0 25000])
bigTitle = 'Cessna Citation II Fuel to Climb';
col1 = {'Configuration: Cruise';'Climb Schedule: Flight Manual';
        'N1: 99-102 %';'Weight: 12,600 lbs';
        'CG: 285.5 in (30 %)';};
col2 = {'Data Basis: Flight Test'; 'Test Date: 11 May 2023';
        'Test Day Data';'Temperature: ISA+10°C'
        'Anti-Ice Systems: OFF';};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off
% exportAsPdf('Climb_Fuel');

% --- DESCENT ---
delta = (1-6.87559e-6*hDescent).^5.2559;
M = sqrt(5.*((1./delta.*((1+0.2.*((vDescent.*1.689)./asl).^2).^(7/2)-1)+1).^(2/7)-1));
rankineTest = ((tempDescent*1.8)+32)+460.67;
a = sqrt(1.4*1716*rankineTest);

vtDescent = M.*a/1.689;  % kts
distDescent = vtDescent.*tDescent/3600;  % nm
theta = asind((min(hdescentMdl)-max(hdescentMdl))/(max(distDescent)*6076));  %deg
distDescent = cosd(theta)*distDescent;  % nm

fuelDescent = ffDescent.*tDescent/3600;  % lbs

f = figure('Units','inches');  % TIME
f.Position = [0 0 11 8.5];                                                                                                                                                                 
% scatter(tDescent/60,hDescent,80,'k','diamond','filled');
plot(tDescent/60,hDescent,'k','LineWidth',2);
hold on
grid minor
plot(tdescentMdl,hdescentMdl,'k','LineWidth',1);
plot(tdescentMdl*1.15,hdescentMdl,'k--','LineWidth',1);
plot(tdescentMdl*0.85,hdescentMdl,'k--','LineWidth',1);
xlabel('Standardized Time to Descend, t (min)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
ylabel('Pressure Altitude, H_{c} (ft)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
axis([0 6 0 25000])
bigTitle = 'Cessna Citation II Time to Descend';
col1 = {'Configuration: Cruise';'Descent Schedule: Flight Manual';
        'Fuel Flow: 300 pph';'Weight: 11,300 lbs';
        'CG: 285.5 in (30 %)';};
col2 = {'Data Basis: Flight Test'; 'Test Date: 11 May 2023';
        'Test Day Data';'Temperature: ISA+10°C'
        'Anti-Ice Systems: OFF';};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off
% exportAsPdf('Descent_Time');

f = figure('Units','inches');  % DISTANCE
f.Position = [0 0 11 8.5];                                                                                                                                                                 
% scatter(distDescent,hDescent,80,'k','diamond','filled');
plot(distDescent,hDescent,'k','LineWidth',2);
hold on
grid minor
plot(distdescentMdl,hdescentMdl,'k','LineWidth',1);
plot(distdescentMdl*1.15,hdescentMdl,'k--','LineWidth',1);
plot(distdescentMdl*0.85,hdescentMdl,'k--','LineWidth',1);
xlabel('Standardized Distance to Descend, S (nm)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
ylabel('Pressure Altitude, H_{c} (ft)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
axis([0 26 0 25000])
bigTitle = 'Cessna Citation II Distance to Descend';
col1 = {'Configuration: Cruise';'Descent Schedule: Flight Manual';
        'Fuel Flow: 300 pph';'Weight: 11,300 lbs';
        'CG: 285.5 in (30 %)';};
col2 = {'Data Basis: Flight Test'; 'Test Date: 11 May 2023';
        'Test Day Data';'Temperature: ISA+10°C'
        'Anti-Ice Systems: OFF';};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off
% exportAsPdf('Descent_Distance');

f = figure('Units','inches');  % FUEL
f.Position = [0 0 11 8.5];                                                                                                                                                                 
% scatter(fuelDescent,hDescent,80,'k','diamond','filled');
plot(fuelDescent,hDescent,'k','LineWidth',2);
hold on
grid minor
plot(fueldescentMdl,hdescentMdl,'k','LineWidth',1);
plot(fueldescentMdl*1.15,hdescentMdl,'k--','LineWidth',1);
plot(fueldescentMdl*0.85,hdescentMdl,'k--','LineWidth',1);
xlabel('Standardized Fuel to Descend, W_{f} (lbs)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
ylabel('Pressure Altitude, H_{c} (ft)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
axis([0 60 0 25000])
bigTitle = 'Cessna Citation II Fuel to Descend';
col1 = {'Configuration: Cruise';'Descent Schedule: Flight Manual';
        'Fuel Flow: 300 pph';'Weight: 11,300 lbs';
        'CG: 285.5 in (30 %)';};
col2 = {'Data Basis: Flight Test'; 'Test Date: 11 May 2023';
        'Test Day Data';'Temperature: ISA+10°C'
        'Anti-Ice Systems: OFF';};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off
% exportAsPdf('Descent_Fuel');

% --- SPECIFIC EXCESS POWER ---
delta = (1-6.87559e-6*hAccel).^5.2559;
M = sqrt(5.*((1./delta.*((1+0.2.*((vAccel.*1.689)./asl).^2).^(7/2)-1)+1).^(2/7)-1));
rankineTest = ((tempAccel*1.8)+32)+460.67;
a = sqrt(1.4*1716*rankineTest);
vtAccel = M.*a;  % ft/s

delta = (1-6.87559e-6*hSawtooth).^5.2559;
MSawMax = sqrt(5.*((1./delta.*((1+0.2.*((mean(vSawMax2).*1.689)./asl).^2).^(7/2)-1)+1).^(2/7)-1));
MSawLow = sqrt(5.*((1./delta.*((1+0.2.*((mean(vSawLow2).*1.689)./asl).^2).^(7/2)-1)+1).^(2/7)-1));
rankineTest = ((tempSawtooth*1.8)+32)+460.67;
a = sqrt(1.4*1716*rankineTest);
vtSawMax = MSawMax.*a;  % ft/s
vtSawLow = MSawLow.*a;

psAccel = zeros(1,length(vtAccel));
vcAccel = zeros(1,length(vtAccel));
for ii = 1:(length(vtAccel)-1)
   psAccel(ii) = (hAccel(ii+1)-hAccel(ii))/(tAccel(ii+1)-tAccel(ii))+...
       (vtAccel(ii)+vtAccel(ii+1))/(2*g)*(vtAccel(ii+1)-vtAccel(ii))/(tAccel(ii+1)-tAccel(ii));
   vcAccel(ii) = (vAccel(ii)+vAccel(ii+1))/2;
end
vcAccel(length(vtAccel)) = vH;
psSawMax = (max(hSawtooth)-min(hSawtooth))/mean([max(tSawMax1) max(tSawMax2)]);
psSawLow = (max(hSawtooth)-min(hSawtooth))/max(tSawLow2);

f = figure('Units','inches'); 
f.Position = [0 0 11 8.5];                                                                                                                                                                 
scatter(vcAccel,psAccel,80,'k');
hold on
grid minor
scatter(mean(vSawMax2),psSawMax,100,'k','diamond','filled');
scatter(mean(vSawLow2),psSawLow,100,'k','diamond','filled');
xlabel('Calibrated Airspeed, V_{c} (KCAS)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
ylabel('Specific Excess Power, P_{s} (ft/s)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
axis([100 250 0 35])
bigTitle = 'Cessna Citation II Specific Excess Power';
col1 = {'Configuration: Cruise';'N1: 102%';
        'Weight: 11,700-12,300 lbs';'CG: 285.5 in (30 %)';};
col2 = {'Data Basis: Flight Test'; 'Test Date: 11 May 2023';
        'Test Day Data';'Temperature: ISA+10°C';};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off
% exportAsPdf('Spec_Excess_Power');

% --- TURN PERFORMANCE ---
omega20 = 360/tTurn20;  % deg/s
omega30 = 360/tTurn30;
omegaSlow = 360/tTurnSlow;
omegaTurns = [0 omega20 omega30 omegaSlow];

hTurns = [hAnchor hTurn20 hTurn30 hTurnSlow];
vTurns = [vAnchor vTurn20 vTurn30 vTurnSlow];
delta = (1-6.87559e-6*hTurns).^5.2559;
M = sqrt(5.*((1./delta.*((1+0.2.*((vTurns.*1.689)./asl).^2).^(7/2)-1)+1).^(2/7)-1));
rankineTest = ((tempTurn*1.8)+32)+460.67;
a = sqrt(1.4*1716*rankineTest);
vtTurns = M.*a;  % ft/s

nTurns = sqrt((deg2rad(omegaTurns).*vtTurns/2).^2+1);
radTurns = ((vtTurns.^2)*1.689)./(g*sqrt((nTurns.^2)-1));

[vTurns,i] = sort(vTurns);
omegaTurns = omegaTurns(i);

nConst = [1.1 1.25 1.5 2.0];
vPlot = linspace(100,300,101);
for ii = 1:length(nConst)
    for jj = 1:length(vPlot)
        omegaPlot(ii,jj)=rad2deg((g*sqrt(nConst(ii)^2-1)/(vPlot(jj)*1.689)));
    end
end

rPlot = [10000 5000 2500 1500];
for ii= 1:length(rPlot)
    for jj = 1:length(vPlot)
        radPlot(ii,jj)=rad2deg(vPlot(jj)*1.689/rPlot(ii));
    end
end

vStall = [103 106 111 122 146];  % flight conditions
angles = [0 20 30 45 60];
nStall = 1./cosd(angles);
omegaStall = rad2deg((g*sqrt(nStall.^2-1))./(vStall*1.689));

f = figure('Units','inches');
f.Position = [0 0 11 8.5]; 
data = scatter(vTurns,omegaTurns,100,'k','diamond','filled');
hold on
grid minor
plot(vPlot,omegaPlot(1:3,:),'k:');
plot(vPlot,radPlot,'k:');
plot(vPlot,omegaPlot(4,:),'k','LineWidth',2);
plot(vStall,omegaStall,'k','LineWidth',2);
xlabel('Calibrated Airspeed, V_{c} (KCAS)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
ylabel('Turn Rate, \omega (deg/sec)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
axis([100 250 0 15])
bigTitle = 'Cessna Citation II Sustained Turn Performance';
col1 = {'Configuration: Flaps 15°, Gear UP';'Altitude: 23,000 ft';
        'N1: 91, 92%';'Weight: 12,100-12,300 lbs';
        'CG: 285.5 in (30 %)';};
col2 = {'Data Basis: Flight Test'; 'Test Date: 11 May 2023';
        'Test Day Data';'Temperature: ISA+10°C';};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off
% exportAsPdf('Turn_Perf')

% --- INCREMENTAL DRAG DESCENT ---
tempTest = -21;
tempStd = -30.6;
wDrag = 11500;

rankineTest = ((tempTest*1.8)+32)+460.67;
rankineStd = ((tempStd*1.8)+32)+460.67;

ROD = mean(hDrag)/60;  % ft/s
vS = ROD*rankineTest/rankineStd;  % ft/s

hDrag = 23000;
delta = (1-6.87559e-6*hDrag).^5.2559;
M = sqrt(5.*((1./delta.*((1+0.2.*((vDrag.*1.689)./asl).^2).^(7/2)-1)+1).^(2/7)-1));
a = sqrt(1.4*1716*rankineTest);
vtDrag = M.*a;  % ft/s

gamma = asind(vS/vtDrag);
incDrag = wDrag*sind(gamma);
incDragCoeff = 2*incDrag/(rhosl*(vDrag*1.689)^2*S);
disp(incDragCoeff)