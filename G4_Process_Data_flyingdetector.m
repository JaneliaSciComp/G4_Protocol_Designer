function G4_Process_Data_flyingdetector(exp_folder, trial_options)
%FUNCTION G4_Process_Data_flyingdetector(exp_folder, trial_options)
% 
% Inputs:
% exp_folder: path containing G4_TDMS_Logs file
% trial_options: 1x3 logical array [pre-trial, intertrial, post-trial]


%% user-defined parameters
%specify timeseries data channels
channel_order = {'LmR_chan', 'L_chan', 'R_chan', 'F_chan', 'Frame Position', 'LmR', 'LpR'};

%specify time ranges for parsing and data analysis
data_rate = 1000; % sample rate (in Hz) which all data will be aligned to
pre_dur = 1; %seconds before start of trial to include
post_dur = 1; %seconds after end of trial to include
da_start = 0; %seconds after start of trial
da_stop = 0; %seconds before end of trial
time_conv = 1000000; %converts seconds to micros (TDMS timestamps are in micros)


%% configure data processing
%specify exp folder to analyse and plot
if nargin==0
    exp_folder = uigetdir('C:/','Select a folder containing a G4_TDMS_Logs file');
    trial_options = [0 0 0]; %[pre-trial, inter-trial, post-trial]
end


%% process TDMS data
%load TDMS_logs
files = dir(exp_folder);
try
    TDMS_logs_name = files(contains({files.name},{'G4_TDMS_Logs'})).name;
catch
    error('cannot find G4_TDMS_Logs file in specified folder')
end
load(fullfile(exp_folder,TDMS_logs_name));

%get start times of trials
start_inds = find(strcmpi(Log.Commands.Name,'Start-Display'));
start_times = Log.Commands.Time(start_inds);
stop_inds = find(strcmpi(Log.Commands.Name,'Stop-Display'));
stop_times = Log.Commands.Time(stop_inds(end));
    
%get order of pattern IDs (maybe use for error-checking?)
set_pattern_inds = find(strcmpi(Log.Commands.Name,'Set Pattern ID'));
patterndata_order = Log.Commands.Data(set_pattern_inds);
patternID_order = cell2mat(cellfun(@PD_fun, patterndata_order,'UniformOutput',false));

%get order of control modes
set_mode_inds = find(strcmpi(Log.Commands.Name,'Set Control Mode'));
modedata_order = Log.Commands.Data(set_mode_inds);
modeID_order = cell2mat(cellfun(@str2double, modedata_order,'UniformOutput',false));
%error-checking to add: check that control mode matches conditions to plot

%load exp_order
load(fullfile(exp_folder,'exp_order.mat'));
exp_order = exp_order'; %change to [condition, repetition]
[num_conds, num_reps] = size(exp_order);

%get trial start and stop times based on input trial options
num_trials = numel(exp_order);
assert(length(start_times)==num_trials + trial_options(1) + trial_options(3) + ((num_trials-1)*trial_options(2)),...
    'unexpected number of trials detected - check that pre-trial, post-trial, and intertrial options are correct')
if trial_options(1)==0
    trial_start_ind = 1;
else
    trial_start_ind = 2;
end
if trial_options(3)==0
    trial_end_ind = length(start_times);
    start_times = [start_times stop_times(end)];
else
    trial_end_ind = length(start_times)-1;
end
if trial_options(2)==0
    trial_start_times = start_times(trial_start_ind:trial_end_ind);
    trial_stop_times = start_times(trial_start_ind+1:trial_end_ind+1);
    trial_modes = modeID_order(trial_start_ind:trial_end_ind);
else
    trial_start_times = start_times(trial_start_ind:2:trial_end_ind);
    trial_stop_times = start_times(trial_start_ind+1:2:trial_end_ind+1);
    trial_modes = modeID_order(trial_start_ind:2:trial_end_ind);
    intertrial_start_times = trial_stop_times(1:end-1);
    intertrial_stop_times = trial_start_times(2:end);
    intertrial_modes = modeID_order(trial_start_ind+1:2:trial_end_ind-1);
    assert(all(intertrial_modes-intertrial_modes(1)==0),...
        'unexpected order of trials and intertrials - check that pre-trial, post-trial, and intertrial options are correct')
end

%get condition durations and control modes
cond_dur = nan(num_conds, num_reps);
cond_modes = nan(num_conds, num_reps);
for cond = 1:num_conds
    for rep = 1:num_reps
        cond_trial = find(exp_order(:,rep)==cond) + num_conds*(rep-1);
        cond_dur(cond,rep) = (trial_stop_times(cond_trial) - trial_start_times(cond_trial))/time_conv;
        cond_modes(cond,rep) = trial_modes(cond_trial);
    end
end
assert(all(all((cond_modes-repmat(cond_modes(:,1),[1 num_reps]))==0)),...
    'unexpected order of trial modes - check that pre-trial, post-trial, and intertrial options are correct')
cond_modes = cond_modes(:,1)';
longest_dur = max(max(cond_dur));
%error-checking to add: check that all repeptitions have (nearly) the same duration

%get indices for all datatypes
Frame_ind = find(strcmpi(channel_order,'Frame Position'));
LmR_ind = find(strcmpi(channel_order,'LmR'));
LpR_ind = find(strcmpi(channel_order,'LpR'));
L_ind = find(strcmpi(channel_order,'L_chan'));
R_ind = find(strcmpi(channel_order,'R_chan'));
F_ind = find(strcmpi(channel_order,'F_chan'));
num_ts_datatypes = length(channel_order);
num_ADC_chans = length(Log.ADC.Channels);

%structure data by datatype/condition/repetition
ts_time = -pre_dur:1/data_rate:longest_dur+post_dur; 
ts_data = nan([num_ts_datatypes num_conds num_reps length(ts_time)]);
for trial=1:num_trials
    cond = exp_order(trial);
    rep = floor((trial-1)/num_conds)+1;
    
    %get analog input data
    for chan = 1:num_ADC_chans
        start_ind = find(Log.ADC.Time(chan,:)>=(trial_start_times(trial)-pre_dur*time_conv),1);
        stop_ind = find(Log.ADC.Time(chan,:)>(trial_stop_times(trial)+post_dur*time_conv),1)-1;
        if isempty(stop_ind)
            stop_ind = length(Log.ADC.Time(chan,:));
        end
        unaligned_time = (Log.ADC.Time(chan,start_ind:stop_ind) - trial_start_times(trial))/time_conv;
        ts_data(chan,cond,rep,:) = align_timeseries(ts_time, unaligned_time, Log.ADC.Volts(chan,start_ind:stop_ind), 'leave nan', 'mean');
    end
    
    %get frame position data, upsampled to match ADC timestamps
    start_ind = find(Log.Frames.Time(1,:)>=(trial_start_times(trial)-pre_dur*time_conv),1);
    stop_ind = find(Log.Frames.Time(1,:)>(trial_stop_times(trial)+post_dur*time_conv),1)-1;
    if isempty(stop_ind)
        stop_ind = length(Log.Frames.Time(1,:));
    end
    unaligned_time = (Log.Frames.Time(1,start_ind:stop_ind)-trial_start_times(trial))/time_conv;
    ts_data(Frame_ind,cond,rep,:) = align_timeseries(ts_time, unaligned_time, Log.Frames.Position(1,start_ind:stop_ind)+1, 'propagate', 'median');
end

%calculate LmR (Left - Right) and LpR (Left + Right)
ts_data(LmR_ind,:,:,:) = ts_data(L_ind,:,:,:) - ts_data(R_ind,:,:,:); %LmR
ts_data(LpR_ind,:,:,:) = ts_data(L_ind,:,:,:) + ts_data(R_ind,:,:,:); %LpR

%calculate values for tuning curves and histograms from time-series data
tc_data = nan([num_ts_datatypes num_conds num_reps]);
hist_datatypes = {'Frame Position', 'LmR', 'LpR'};
num_hist_datatypes = length(hist_datatypes); 
max_num_positions = nan(num_conds, num_reps);
data_start_ind = find(ts_time>=da_start,1);
for cond = 1:num_conds
    for rep = 1:num_reps
        data_stop_ind = find(ts_time>(cond_dur(cond,rep)-da_stop),1)-1;
        
        %calculate mean channel value during condition (used for tuning curves)
        tc_data(:,cond,rep) = nanmean(ts_data(:,cond,rep,data_start_ind:data_stop_ind),4);
        
        %calculate histograms by pattern position (used for closed-loop trials)
        max_num_positions(cond,rep) = squeeze(max(ts_data(Frame_ind,cond,rep,data_start_ind:data_stop_ind),[],4));
        min_num_position = squeeze(min(ts_data(Frame_ind,cond,rep,data_start_ind:data_stop_ind),[],4));
        if ~exist('hist_data','var')
            hist_data = nan([num_hist_datatypes num_conds num_reps max_num_positions(cond,rep)]);
        elseif max_num_positions(cond,rep)>size(hist_data,4)
            hist_data(:,:,:,size(hist_data,4)+1:max_num_positions(cond,rep)) = nan;
        end
        p = (min_num_position:max_num_positions(cond,rep));
        p_inds = squeeze(ts_data(Frame_ind,cond,rep,data_start_ind:data_stop_ind))==p;
        hist_data(1,cond,rep,p) = nansum(p_inds); %histogram of pattern position
        tmpdata = repmat(squeeze(ts_data(LmR_ind,cond,rep,data_start_ind:data_stop_ind)),[1 size(p,2)]);
        tmpdata(~p_inds) = nan;
        hist_data(2,cond,rep,p) = nanmean(tmpdata); %mean LmR by pattern position
        tmpdata = repmat(squeeze(ts_data(LpR_ind,cond,rep,data_start_ind:data_stop_ind)),[1 size(p,2)]);
        tmpdata(~p_inds) = nan;
        hist_data(3,cond,rep,p) = nanmean(tmpdata); %mean LpR by pattern position
    end
end

%calculate Frame histogram for intertrials
if trial_options(2)==1
    inter_inds = [];
    num_intertrials = num_trials-1;
    inter_dur = (intertrial_stop_times - intertrial_start_times)/time_conv;
    longest_dur = max(inter_dur);
    inter_ts_time = 0:1/data_rate:longest_dur; 
    inter_ts_data = nan([num_intertrials length(inter_ts_time)]);
    for i = 1:num_intertrials
        %get frame position data, upsampled to match ADC timestamps
        start_ind = find(Log.Frames.Time(1,:)>=intertrial_start_times(trial),1);
        stop_ind = find(Log.Frames.Time(1,:)>intertrial_stop_times(trial),1)-1;
        if isempty(stop_ind)
            stop_ind = length(Log.Frames.Time(1,:));
        end
        unaligned_time = (Log.Frames.Time(1,start_ind:stop_ind)-trial_start_times(trial))/time_conv;
        inter_ts_data(i,:) = align_timeseries(inter_ts_time, unaligned_time, Log.Frames.Position(1,start_ind:stop_ind)+1, 'propagate', 'median');
    end
    max_num_positions = max(max(inter_ts_data));
    min_num_position = min(min(inter_ts_data));
    
    p = reshape((min_num_position:max_num_positions),[1 1 length(p)]);
    p_inds = inter_ts_data==p;
    inter_hist_data = nansum(p_inds,3); %histogram of pattern position
else
    inter_hist_data = [];
end

%% save data
Data.channelNames.timeseries = channel_order; %cell array of channel names for timeseries data
Data.channelNames.histograms = hist_datatypes; %cell array of channel names for histograms
Data.histograms = hist_data; %[datatype, condition, repetition, pattern-position]
Data.interhistogram = inter_hist_data; %[repetition, pattern-position]
Data.timestamps = ts_time; %[1 timestamp]
Data.timeseries = ts_data; %[datatype, condition, repition, datapoint]
Data.summaries = tc_data; %[datatype, condition, repition]
Data.conditionModes = cond_modes; %[condition]
save(fullfile(exp_folder,'G4_Processed_Data.mat'),'Data');
