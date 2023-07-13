%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% LEVEL ACCELERATION AND SAWTOOTH CLIMB %%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all; close all; clc; 

%IMPORT THE DATA

fileName_1 = 'Olsen 5 Apr 378 LA ST Data pt1.csv';
data = readtable(fileName_1);

% Create variables for each parameter's name
timeName = 'IRIG_TIME'; 
eventName = 'EVENT_MARKER'; 
altitudeName = 'ALTITUDE_INU'; 
pressureAltName = 'PRESS_ALT_1553';
radAltName = 'RADAR_ALT';
calAirspeedName = 'CAL_AS_1553';
machName = 'MACH_1553';
aoaName = 'TRUE_AOA_1553';
tempName = 'TAT_DEGC';

%%
% Pull off the desired parameters from the data table "data"
time = datetime(data.(timeName),'InputFormat', 'DDD:HH:mm:ss.SSSSSSS'); 
allEvents = data.(eventName);
% altitude = data.(altitudeName);
pressureAlt = data.(pressureAltName)/1000;
radAlt = data.(radAltName);
calAirspeed = data.(calAirspeedName);
mach = data.(machName);
AOA = data.(aoaName);
temp = data.(tempName);

%%
close all;
myEvents = 0:max(allEvents); % Selected events
nEvents = length(myEvents); % Compute the length of the above vector
ids = zeros(nEvents,1); % Preallocate an empty vector with the same length 
% Identify the start and end index for selected evenets
for ii = 1:nEvents
    ii
    ids = find(allEvents==myEvents(ii),1);
    idxStart(ii) = ids(1); % The starting index is the index of the first event
    idxEnd(ii) = ids(end); % The final index is the index of the last event
    clear ids 
end

f = figure('Units','inches'); % Instantiate a figure object
f.Position = [1 1 8*1.2 6*1.2]; % [x, y, width, height] in inches

%altitude subplot
ax(1) = subplot(2,1,1);
plot(pressureAlt,'DisplayName','Pressure Altitude');
hold on 
grid on 
plot(idxStart,pressureAlt(idxStart),'.','markersize',20,'color',[0.4660 0.6740 0.1880],'DisplayName','Event Start');
for i = 1:length(myEvents)
    str = num2str(myEvents(i));
    text(idxStart(i), pressureAlt(idxStart(i)),str,'fontsize',10)
    
    
end 
ylabel('Pressure Altitude [ft]'); 
legend('show')

%airspeed subplot
ax(2) = subplot(2,1,2); 
plot(calAirspeed,'DisplayName','Airspeed');
hold on 
grid on 
plot(idxStart,calAirspeed(idxStart),'.','markersize',20,'color',[0.4660 0.6740 0.1880],'DisplayName','Event Start');
for i = 1:length(myEvents)
    str = num2str(myEvents(i));
    text(idxStart(i), calAirspeed(idxStart(i)),str,'fontsize',10)
    
    
end 
ylabel('Airspeed [KCAS]'); 
legend('show')
suptitle('Altitude and Airspeed')

linkaxes(ax,'x')
% linkdata on; 
% linkdata showdialog;
% 
% brush on; 
