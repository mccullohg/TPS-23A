%%%%%%%%%%%%%%%%%%%%  MIGHTY HURON PERF ANALYSIS  %%%%%%%%%%%%%%%%%%%%
%
% perf_climb_descent.m
%
% Author: 1st Lt Gordon McCulloh, FTE (23A)
% Date: Mar - Jun 2023
% 
% Description: perf_climb_descent.m ingests DAS data from C-12 performance
% data flights for check climbs, check descents, and emergency descents. 
% Data is trimmed for individual maneuvers and plotted according to 
% performance analysis tool standards.
%
% Inputs: .csv file types
%
% Outputs: time, distance, and fuel to climb/descend charts
%
% Paired files: tpsread.m       - ingests .csv data and converts to .mat
%               tpstime.m       - converts IRIG time to seconds
%               perf_climbs.m   - ingests climb data and computes 
%                                 standardized time, distance, and fuel
%               perf_descents.m - likewise for descent data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot defaults
set(groot, 'DefaultTextInterpreter','tex');
set(groot, 'DefaultLegendInterpreter', 'tex');
set(groot, 'defaultAxesTickLabelInterpreter','tex'); 
set(groot,'DefaultAxesFontSize',16);
set(groot,'DefaultTextFontSize',12);
set(groot,'defaultAxesFontName','Times New Roman');
set(groot,'defaultTextFontName','Times New Roman');

% Constants
g = 32.174;  % ft/s^2
asl = 1116.4;  % ft/s

%% ---------- CLIMBS ------------
% INPUTS
filename = 'McCulloh 17 Mar 158 Accel, climb data group.csv';  % DAS file
myEvents = 3:4;  % event markers of interest

% C-12 climb model
timeMdl = [0, 7.1];  % min
altMdl = [5000, 20000];  % ft PA
fuelMdl = [0, 90];  % lbs
distMdl = [0, 22];  % nm

% Import DAS data
data = tpsread(filename);

% Pull working variables
dtIrig = data.Delta_Irig;  % time since das start
events = data.ICU_EVNT_CNT;  % event markers
ffL = data.FF_MASS_LE;  ffR = data.FF_MASS_RE;  % fuel flows
alt = data.ADC_ALT_29;  % altitude
kias = data.ADC_IAS;  % indicated airspeed
sat = data.ADC_SAT;  % static air temperature

% Generate indices to search data per the desired event markers
nEvents = length(myEvents);
ids = zeros(nEvents,1);
for ii = 1:nEvents
    ids(ii) = find(events == myEvents(ii),1);
end
idx0 = ids(1); idxf = ids(end);
eventedAlt = alt(idx0:idxf);

% Re-generate indices to adjust data for 5,000-20,000 PA
for jj = 1:length(eventedAlt)
    if eventedAlt(jj)<=5000 && eventedAlt(jj+1)>5000
        idx0 = ids(1)+jj;
    end
    if eventedAlt(jj)<=20000 && eventedAlt(jj+1)>20000
        idxf = ids(1)+jj-1;
    end
end

% Trim data according to the desired event markers
eventTime = dtIrig(idx0:idxf);
eventAlt = alt(idx0:idxf);
eventFF1 = ffL(idx0:idxf); eventFF2 = ffR(idx0:idxf);
eventKias = kias(idx0:idxf);
eventSat = sat(idx0:idxf);

% Time elapsed across a single maneuver
tm = eventTime - eventTime(1);

% Convert indicated to calibrated airspeed
eventKcas = 0.9908*eventKias+2.2611;  % kts

% Compute climb data
[tClimb, dClimb, fClimb] = perf_climbs(eventKcas,eventAlt,eventFF1,...
    eventFF1,eventSat,tm);  % right engine data errant

% Filter fuel data
order = 1;
framelen = 1001;
fClimbFilt = sgolayfilt(fClimb,order,framelen);

% Plot standardized time to climb
f = figure('Units','inches');
f.Position = [0 0 11 8.5];                                                                                                                                                                 
plot(tClimb,eventAlt,'k','LineWidth',3);
hold on
plot(timeMdl,altMdl,'k','LineWidth',1);
plot(timeMdl*1.1,altMdl,'k--','LineWidth',1);
plot(timeMdl*0.9,altMdl,'k--','LineWidth',1);
xlabel('Standardized Time to Climb, t (min)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
ylabel('Pressure Altitude, H_{c} (ft)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
axis([0 9 0 21000])
bigTitle = 'C-12 Time to Climb';
col1 = {'Configuration: Cruise';'Climb Schedule: Flight Manual';
        'PRPM: 1900';'Torque: MCP';
        'CG: 19.4%';};
col2 = {'Data Basis: Flight Test'; 'Test Date: 17 March 2023';
        'Test Day Data';'Temperature: ISA';
        'Weight: 11,800 lbs';};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off
exportAsJpeg('Huron_Climb_Time')

% Plot standardized fuel to climb
f = figure('Units','inches');
f.Position = [0 0 11 8.5];                                                                                                                                                                 
plot(fClimbFilt,eventAlt,'k','LineWidth',3);
hold on
plot(fuelMdl,altMdl,'k','LineWidth',1);
plot(fuelMdl*1.1,altMdl,'k--','LineWidth',1);
plot(fuelMdl*0.9,altMdl,'k--','LineWidth',1);
xlabel('Standardized Fuel to Climb (lbs)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
ylabel('Pressure Altitude, H_{c} (ft)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
axis([0 105 0 21000])
bigTitle = 'C-12 Fuel to Climb';
col1 = {'Configuration: Cruise';'Climb Schedule: Flight Manual';
        'PRPM: 1900';'Torque: MCP';
        'CG: 19.4%';};
col2 = {'Data Basis: Flight Test'; 'Test Date: 17 March 2023';
        'Test Day Data';'Temperature: ISA';
        'Weight: 11,800 lbs';};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off
exportAsJpeg('Huron_Climb_Fuel')

% Plot standardized distance to climb
f = figure('Units','inches');
f.Position = [0 0 11 8.5];                                                                                                                                                                 
plot(sort(dClimb),eventAlt,'k','LineWidth',3);
hold on
plot(distMdl,altMdl,'k','LineWidth',1);
plot(distMdl*1.1,altMdl,'k--','LineWidth',1);
plot(distMdl*0.9,altMdl,'k--','LineWidth',1);
xlabel('Standardized Distance to Climb (NM)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
ylabel('Pressure Altitude, H_{c} (ft)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
axis([0 25 0 21000])
bigTitle = 'C-12 Distance to Climb';
col1 = {'Configuration: Cruise';'Climb Schedule: Flight Manual';
        'PRPM: 1900';'Torque: MCP';
        'CG: 19.4%';};
col2 = {'Data Basis: Flight Test'; 'Test Date: 17 March 2023';
        'Test Day Data';'Temperature: ISA';
        'Weight: 11,800 lbs';};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off
exportAsJpeg('Huron_Climb_Distance')

%% ---------- DESCENTS ----------
% INPUTS
filename = 'Barrett 22 Mar 215 LA ST Perf FTT.csv';  % DAS file
dEvents = 9:10;  % event markers of descent
edEvents = 19:20;  % event markers of emergency descent

% C-12 descent model
timeMdl = [0, 10];  % min
altMdl = [20000, 5000];  % ft PA
fuelMdl = [0, 90];  % lbs
distMdl = [0, 48];  % nm

% Import DAS data
data = tpsread(filename);

% Pull working variables
dtIrig = data.Delta_Irig;  % time since das start
events = data.ICU_EVNT_CNT;  % event markers
ffL = data.FF_MASS_LE;  ffR = data.FF_MASS_RE;  % fuel flows
alt = data.ADC_ALT_29;  % altitude
kias = data.ADC_IAS;  % indicated airspeed
sat = data.ADC_SAT;  % static air temperature

% Generate indices to search data per the desired event markers
myEvents = [dEvents,edEvents];
nEvents = length(myEvents);
ids = zeros(nEvents,1);
for ii = 1:nEvents
    ids(ii) = find(events == myEvents(ii),1);
end
idx0d = ids(1); idxfd = ids(2);
idx0ed = ids(3); idxfed = ids(4);
dAlt = alt(idx0d:idxfd);
edAlt = alt(idx0ed:idxfed);

% Re-generate indices to adjust data for 20,000-5,000 PA
for jj = 1:(length(dAlt)-1)
    if dAlt(jj)>=20000 && dAlt(jj+1)<20000
        idx0d = ids(1)+jj;
    end
    if dAlt(jj)>=5000 && dAlt(jj+1)<5000
        idxfd = ids(1)+jj-1;
    end
end
for jj = 1:(length(edAlt)-1)
    if edAlt(jj)>=20000 && edAlt(jj+1)<20000
        idx0ed = ids(3)+jj;
    end
    if edAlt(jj)>=5000 && edAlt(jj+1)<5000
        idxfed = ids(3)+jj-1;
    end
end

% Trim data according to the desired event markers
dTime = dtIrig(idx0d:idxfd);
edTime = dtIrig(idx0ed:idxfed);
dAlt = alt(idx0d:idxfd);
edAlt = alt(idx0ed:idxfed);
dFF1 = ffL(idx0d:idxfd); dFF2 = ffR(idx0d:idxfd);
edFF1 = ffL(idx0ed:idxfed); edFF2 = ffR(idx0ed:idxfed);
dKias = kias(idx0d:idxfd);
edKias = kias(idx0ed:idxfed);
dSat = sat(idx0d:idxfd);
edSat = sat(idx0ed:idxfed);

% Time elapsed across a single maneuver
tmD = dTime - dTime(1);
tmED = edTime - edTime(1);

% Convert indicated to calibrated airspeed
dKcas = 0.9908*dKias+2.2611;  % kts
edKcas = 0.9908*edKias+2.2611;  % kts

% Compute descent data
[tDescent, dDescent, fDescent] = perf_descents(dKcas,dAlt,dFF1,dFF2,...
    dSat,tmD);
[tEmer, dEmer, fEmer] = perf_descents(edKcas,edAlt,edFF1,edFF2,...
    edSat,tmED);

% Filter fuel data
order = 1;
framelen = 3001;
fDescentFilt = sgolayfilt(fDescent,order,framelen);
fEmerFilt = sgolayfilt(fEmer,order,framelen);

% Plot standardized time to descend
f = figure('Units','inches');
f.Position = [0 0 11 8.5];                                                                                                                                                                 
plot(tDescent,dAlt,'k','LineWidth',3);
hold on
plot(tEmer,edAlt,'k','LineWidth',3);
plot(timeMdl,altMdl,'k','LineWidth',1);
plot(timeMdl*1.1,altMdl,'k--','LineWidth',1);
plot(timeMdl*0.9,altMdl,'k--','LineWidth',1);
xlabel('Standardized Time to Descend, t (min)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
ylabel('Pressure Altitude, H_{c} (ft)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
axis([0 11 0 21000])
bigTitle = 'C-12 Time to Descend';
col1 = {'Schedules: Flight Manual (FM), Emergency Descent (ED)';
        'Configuration: Cruise (FM), PA (ED)';
        'PRPM: 1700 (FM), 2000 (ED)';'Torque: A/R (FM), Idle (ED)';
        'CG: 19.4%';};
col2 = {'Data Basis: Flight Test'; 'Test Date: 22 March 2023';
        'Test Day Data';'Temperature: ISA';
        'Weight: 10,800-11,500 lbs';};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off
exportAsJpeg('Huron_Descent_Time')

% Plot standardized fuel to descend
f = figure('Units','inches');
f.Position = [0 0 11 8.5];                                                                                                                                                                 
plot(sort(fDescent),dAlt,'k','LineWidth',3);
hold on
plot(sort(fEmer),edAlt,'k','LineWidth',3);
plot(fuelMdl,altMdl,'k','LineWidth',1);
plot(fuelMdl*1.1,altMdl,'k--','LineWidth',1);
plot(fuelMdl*0.9,altMdl,'k--','LineWidth',1);
xlabel('Standardized Fuel to Descend (lbs)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
ylabel('Pressure Altitude, H_{c} (ft)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
axis([0 105 0 21000])
bigTitle = 'C-12 Fuel to Descend';
col1 = {'Schedules: Flight Manual (FM), Emergency Descent (ED)';
        'Configuration: Cruise (FM), PA (ED)';
        'PRPM: 1700 (FM), 2000 (ED)';'Torque: A/R (FM), Idle (ED)';
        'CG: 19.4%';};
col2 = {'Data Basis: Flight Test'; 'Test Date: 22 March 2023';
        'Test Day Data';'Temperature: ISA';
        'Weight: 10,800-11,500 lbs';};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off
exportAsJpeg('Huron_Descent_Fuel')

% Plot standardized distance to descend
f = figure('Units','inches');
f.Position = [0 0 11 8.5];                                                                                                                                                                 
plot(sort(dDescent),dAlt,'k','LineWidth',3);
hold on
plot(sort(dEmer),edAlt,'k','LineWidth',3);
plot(distMdl,altMdl,'k','LineWidth',1);
plot(distMdl*1.1,altMdl,'k--','LineWidth',1);
plot(distMdl*0.9,altMdl,'k--','LineWidth',1);
xlabel('Standardized Distance to Descend (NM)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
ylabel('Pressure Altitude, H_{c} (ft)','FontName','Helvetica','FontSize',16,'FontWeight','bold')
axis([0 60 0 21000])
bigTitle = 'C-12 Distance to Descend';
col1 = {'Schedules: Flight Manual (FM), Emergency Descent (ED)';
        'Configuration: Cruise (FM), PA (ED)';
        'PRPM: 1700 (FM), 2000 (ED)';'Torque: A/R (FM), Idle (ED)';
        'CG: 19.4%';};
col2 = {'Data Basis: Flight Test'; 'Test Date: 22 March 2023';
        'Test Day Data';'Temperature: ISA';
        'Weight: 10,800-11,500 lbs';};
subtitles = {col1,col2};
testPointTitle(bigTitle,subtitles);
hold off
exportAsJpeg('Huron_Descent_Distance')
