exp_folder = 'C:\Users\taylorl\Desktop\fly33';
trial_options = [1 1 1]; % [pre-trial, intertrial, post-trial]
metadata = struct;
metadata.experimenter = 'me';
metadata.experiment_name = 'exp';
metadata.experiment_protocol = 'protocol path';

%Turn experiment type (1,2, or 3) to matching word
%("Flight", etc)    
metadata.experiment_type = "Flight";
metadata.fly_name = 'fly1';
metadata.genotype = 'gg';
metadata.timestamp = 'time';
metadata.plotting_protocol = 'plot file';
metadata.processing_protocol = 'process file';
    metadata.do_plotting = "Yes";
    metadata.do_processing = "Yes";
metadata.plotting_command = "plot command";
metadata.fly_results_folder = "folder";
metadata.trial_options = trial_options;

%convert .tdms files into .mat struct
G4_TDMS_folder2struct(exp_folder)

%process data
G4_Process_Data_flyingdetector(exp_folder, trial_options)

%plot_data
G4_Plot_Data_flyingdetector(exp_folder, trial_options, metadata)
%plot_test(exp_folder, trial_options)

%% for more advanced plotting:
% CL_conds = []; %matrix of closed-loop (CL) conditions to plot as histograms
% OL_conds = [1 2 3 4; 5 6 7 8]; %matrix of open-loop (OL) conditions to plot as timeseries
% TC_conds = [1 2 3 4; 5 6 7 8]; %matrix of open-loop conditions to plot as tuning curves (TC)
% G4_Plot_Data_flyingdetector(exp_folder, trial_options, CL_conds, OL_conds, TC_conds)