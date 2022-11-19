"""
TPS Reference Functions

Author: 1Lt Gordon McCulloh
Last Updated: 18 Nov 2022

tps_func.py contains a list of reference packages and functions to be used in
other data analysis files. The user may simply copy-paste code into other 
scripts to reduce the time burden of data processing.
"""
# Import packages
from matplotlib import pyplot as plt
import numpy as np
import pandas as pd
import scipy.signal as ss
from scipy.stats import linregress
from scipy import integrate
from itertools import compress
from datetime import datetime
from matplotlib.animation import FuncAnimation
from mpl_toolkits.mplot3d import Axes3D

# Plotly, Dash
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from plotly.offline import plot
from plotly.graph_objects import *
from dash import Dash, html, dcc

# Plot styles
plt.style.use('seaborn-pastel')

# Assign the working directory
import os
path = r'C:\Users\1523471097A\Desktop'  # current folder
os.chdir(path)

# Assign CSV file names
filenames = ['example.csv',
             'eggsample.csv'] 

# Create data list, append datasets into the list
dataframes = []
for file in filenames:
    data = pd.read_csv(file)
    dataframe = pd.DataFrame(data)
    dataframes.append(dataframe)

# F-16 data types
cols = ['IRIG_TIME', 'Delta_Irig', 'AMB_AIR_TEMP', 'AMB_AIR_TEMP_C', 
        'EVENT', 'LEFT_FUEL_FLOW', 'FF1LE_ANA1', 'RIGHT_FUEL_FLOW',
        'FF1RE_ANA1', 'LEFT_AB_FUEL_FLOW', 'FF2LE_ANA1', 'RIGHT_AB_FUEL_FLOW',
        'FF2RE_ANA1', 'GPS_DAYS', 'GPS_HOURS', 'GPS_MINUTES', 'GPS_SECONDS',
        'GPS_MICROSECONDS', 'GPS_ALTITUDE', 'GPS_P_ALTM', 'GPS_P_ALTS',
        'GPS_LAT_DIRECT', 'GPS_LAT_DEG', 'GPS_LAT_MIN', 'GPS_LONG_DIRECT',
        'GPS_LONG_DEG', 'GPS_LONG_MIN', 'GPS_SPEED', 'ADC_PRESSURE_ALTITUDE',
        'ADC_MACH', 'ADC_COMPUTED_AIRSPEED', 'ADC_TRUE_AIRSPEED', 
        'ADC_TOTAL_AIR_TEMP', 'ADC_AMBIENT_AIR_TEMP', 'ADC_STATIC_PRESSURE',
        'ADC_AOA_UNCORRECTED', 'ADC_AOA_NORMALIZED', 'ADC_AOA_CORRECTED',
        'ADC_STATIC_PR_UNCORRECTED', 'EED_LEFT_FUEL_QTY', 
        'EED_LEFT_ENGINE_OIL_PRESSURE', 'EED_LEFT_ENGINE_RPM', 
        'EED_LEFT_ENGINE_EGT', 'EED_LEFT_ENGINE_NOZZLE_POS', 
        'EED_LEFT_ENGINE_FUEL_FLOW', 'EED_RIGHT_FUEL_QTY', 
        'EED_RIGHT_ENGINE_OIL_PRESSURE', 'EED_RIGHT_ENGINE_RPM', 
        'EED_RIGHT_ENGINE_EGT', 'EED_RIGHT_ENGINE_NOZZLE_POS', 
        'EED_RIGHT_ENGINE_FUEL_FLOW', 'ADC_FLAP_POS', 'ADC_LANDING_GEAR_POS', 
        'EGI_VE', 'EGI_VN', 'EGI_VZ', 'EGI_ALTITUDE', 'EGI_RADAR_ALTITUDE', 
        'EGI_ROLL_ANGLE', 'EGI_PITCH_ANGLE', 'EGI_TRUE_HEADING', 
        'EGI_MAGNETIC_HEADING', 'EGI_ACCEL_X', 'EGI_ACCEL_Y', 'EGI_ACCEL_Z', 
        'EGI_ROLL_RATE_P', 'EGI_PITCH_RATE_Q', 'EGI_YAW_RATE_R', 
        'PITCH_RATE_Q', 'ROLL_RATE_P', 'YAW_RATE_R', 'NY_LATERAL_ACCEL', 
        'NX_LONG_ACCEL', 'NZ_NORMAL_ACCEL', 'LAIL_POS', 'RAIL_POS', 'LAT_SP', 
        'LON_SP', 'STAB_POS', 'SPEED_BRK_POS', 'RUD_PED_POS', 'RUDDER_POS', 
        'LT_RUD_PED_FORC', 'LT_RUD_PED_FORCE_X', 'LT_RUD_PED_FORCE_Z', 
        'RT_RUD_PED_FORC', 'RT_RUD_PED_FORCE_X', 'RT_RUD_PED_FORCE_Z', 
        'STATIC_PRESSURE', 'TOTAL_PRESSURE', 'TAT_DEGC', 'TAT_DEGF', 'P_A', 
        'PLA_LEFT', 'PLA_RIGHT', 'LEFT_FUEL_TEMP_C', 'LEFT_FUEL_TEMP_F', 
        'RIGHT_FUEL_TEMP_C', 'RIGHT_FUEL_TEMP_F', 'PARO1_TEMP', 
        'PARO1_TEMP_K', 'PARO2_TEMP', 'PARO2_TEMP_K', 'LEFT_ENGINE_RPM_N1', 
        'RIGHT_ENGINE_RPM_N1', 'PRESS_ALT_IC', 'ADC_AIR_GND_WOW', 
        'LT_GEAR_WOW', 'NOSE_WOW', 'RT_GEAR_WOW', 'AIRSPEED_IC', 
        'AIRSPEED_TIC', 'MACH_IC	AOA	AOSS']

# Assign a dataframe from a single data set - e.g. example.csv
dat = pd.DataFrame(dataframes[0], columns=cols)

# Save plots
saveBool = 0
if saveBool:
    plt.savefig('example.png', dpi=100)
    
# Excel file to data dictionary
def excelToDict(filePath, fileName, **kwargs):
    fullPath = join(filePath, fileName)
    xlsx = read_excel(fullPath, skiprows=1, usecols='A:AC')
    return xlsx

# Find the desired element index in a list
def find_last(lst, sought_elt):
    for r_idx, elt in enumerate(reversed(lst)):
        if elt == sought_elt:
            return len(lst) - 1 - r_idx


# Find unique elements in a list
def getUnique(inputList):
    # inputArr = np.array(inputList)
    uList, idx = np.unique(inputList, return_index=True)
    uniqueList = list(uList[np.argsort(idx)])
    return uniqueList

# Grab the last element of a unique list
def getUniqueLast(inputList):
    uniqueList = getUnique(inputList)
    lastIndices = []
    uniqueListLast = []
    for uniqueItem in uniqueList:
        lastIndex = find_last(inputList, uniqueItem)
        lastIndices.append(lastIndex)
        uniqueListLast.append(inputList[lastIndex])
    return lastIndices, 

# Get an array from a dictionary
def arrayFromDict(dataDict, key):
    keyValList = []
    for shot in list(dataDict.keys()):
        keyValList.append(dataDict[shot][key])
    return np.array(keyValList)
