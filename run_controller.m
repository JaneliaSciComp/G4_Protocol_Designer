classdef run_controller < handle
   
    properties
        model_;
        fig_;
        fly_name_;

        
    end
    
    
    properties (Dependent)
        model;
        fig;
        fly_name;
        
        
    end
    
    
    
    methods
        
        %contstructor
        function self = run_controller(model)
            self.fig_ = figure('units','pixels','MenuBar', 'none', ...
                'ToolBar', 'none', 'Resize', 'off');
            self.model_ = model;
            self.layout();

            
            
        
        end
        
        function layout(self)
           pix = get(0, 'screensize');
           fig_size = [.25*pix(3), .25*pix(4), .5*pix(3), .5*pix(4)];
           set(self.fig_,'Position',fig_size);
           
           
            start_button = uicontrol(self.fig_,'Style','pushbutton', 'String', 'Run', ...
                'units', 'pixels', 'Position', [fig_size(3) - 150, fig_size(4)*.33, 135, 100],'Callback', @self.run);
            settings_pan = uipanel(self.fig_, 'Title', 'Settings', 'units', 'pixels', ...
                'Position', [15, fig_size(4) - 215, 350, 200]);
            metadata_pan = uipanel(self.fig_, 'Title', 'Metadata', 'units', 'pixels', ...
                'Position', [fig_size(3) - 250, fig_size(4) - 315, 235, 300]);
            status_pan = uipanel(self.fig_, 'Title', 'Status', 'units', 'pixels', ...
                'Position', [15, 15, fig_size(3) - 30, fig_size(4)*.3]); 
            
            
            %Settings required from user
            exp_name_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Experiment Name:', ...
                'units', 'pixels', 'Position', [10, 160, 100, 15]);
            exp_name_box = uicontrol(settings_pan, 'Style', 'edit', 'String', self.model_.experiment_name_, 'units', 'pixels', 'Position', ...
                [115, 160, 150, 18], 'Callback', @update_experiment_name);
            fly_name_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Fly Name:', ...
                'units', 'pixels', 'Position', [10, 140, 100, 15]);
            fly_name_box = uicontrol(settings_pan, 'Style', 'edit', 'String', self.fly_name_, ...
                'units', 'pixels', 'Position', [115, 140, 150, 18], 'Callback', @self.update_fly_name);
            
        end
        
        function update_fly_name(self, src, event)
            
            self.set_fly_name(src.String);
            
        end
        
        function run(self, src, event)
            %Get necessary data
            
            experiment_name = self.model_.get_experiment_name();
            num_reps = self.model_.get_repetitions();
            randomize = self.model_.get_is_randomized();
            
            pretrial = self.model_.get_pretrial();
            block_trials = self.model_.get_block_trials();
            intertrial = self.model_.get_intertrial();
            posttrial = self.model_.get_posttrial();
            
            trial_duration = block_trials{1,12};
            intertrial_duration = intertrial{12};
            pretrial_duration = pretrial{12};
            posttrial_duration = posttrial{12};
            
            %Set initial index values to send to panel - NOT ALL OF THESE
            %WILL BE USED. IF THERE IS NO PRE/POST/INTER TRIAL THEN THE
            %VALUES WILL NEVER GET SENT BUT IT'S EASIER TO DEFINE THEM ALL
            %AT ONCE.
            %pretrial
            pretrial_mode = pretrial{1};
            pretrial_pat_id = self.model_.get_pattern_index(pretrial{2});
            pretrial_posfunc_id = self.model_.get_posfunc_index(pretrial{3});
            
            if ~isempty(pretrial{10})
                pretrial_gain = pretrial{10};
                pretrial_offset = pretrial{11};

                
            else
                pretrial_gain = 0;
                pretrial_offset = 0;

                
            end
            
            
            %first run of block_trials
%             trial_mode = block_trials{1,1};
%             pat_index = self.model_.get_pattern_index(block_trials{1,2});
%             posfunc_index = self.model_.get_posfunc_index(block_trials{1,3});
            if ~isempty(block_trials{1,10})
                LmR_gain = block_trials{1,10};
                LmR_offset = block_trials{1,11};
                
            else
                LmR_gain = 0;
                LmR_offset = 0;
                
            end
            
            %intertrial values
            intertrial_mode = intertrial{1};
            intertrial_pat_id = self.model_.get_pattern_index(intertrial{2});
            intertrial_posfunc_id = self.model_.get_posfunc_index(intertrial{3});
            if ~isempty(intertrial{10})
                intertrial_gain = intertrial{10};
                intertrial_offset = intertrial{11};
            else
                intertrial_gain = 0;
                intertrial_offset = 0;
                
            end
           
            %posttrial values
            posttrial_mode = posttrial{1};
            posttrial_pat_id = self.model_.get_pattern_index(posttrial{2});
            posttrial_posfunc_id = self.model_.get_posfunc_index(posttrial{3});
            if ~isempty(posttrial{10})
                posttrial_gain = posttrial{10};
                posttrial_offset = posttrial{11};
                
            else
                posttrial_gain = 0;
                posttrial_offset = 0;
                
            end
            
            
            %Checking to see if the intertrial has a pattern or not, bc a
            %pattern is needed for all modes. 
            
            %%%%%%%%%CONSIDER PUTTING IN A CHECKBOX WHICH ALLOWS THEM TO
            %%%%%%%%%DISABLE THE PRE, INTER, AND POST TRIALS so they don't
            %%%%%%%%%have to erase everything autofilled. 
            if strcmp(intertrial{2},'') == 1
                inter_type = 0;
            else
                inter_type = 1;
            end
 
            
            %pre_start indicates whether there is a pretrial or not
            
            if strcmp(pretrial{2},'') == 1
                pre_start = 0;
            else
                pre_start = 1; 
            end
            %%Get active channels from the model, create array of their
            %%numeric representations, ie if channels 1 and 3 are active,
            %%active_ao_channels will be [0,2]; 
            
            %THIS METHOD will create an array like [0, 2, 3] if ao channels
            %1,3, and 4 are active. Is this correct??????????????
            channels = [self.model_.get_is_chan1(), self.model_.get_is_chan2(), self.model_.get_is_chan3(), self.model_.get_is_chan4()];
            channel_nums = [1,2,3,4];
            
            j = 1;
            active_ao_channels = [];
            for channel = 1:4
                if channels(channel) == 1
                    active_ao_channels(j) = channel_nums(channel);
                    j = j + 1;
                end
                
                
            end
            pretrial_ao_funcs = [];
            ao_funcs = []; %first trial of block trials
            intertrial_ao_funcs = [];
            posttrial_ao_funcs = [];
            for i = 1:length(active_ao_channels)
                channel_num = active_ao_channels(i);
                pretrial_ao_indices(i) = self.model_.get_ao_index(pretrial{channel_num + 3});
                ao_indices(i) = self.model_.get_ao_index(block_trials{1,channel_num + 3});
                intertrial_ao_indices(i) = self.model_.get_ao_index(intertrial{channel_num + 3});
                posttrial_ao_indices(i) = self.model_.get_ao_index(posttrial{channel_num + 3});
            end
         
            
            
            %% PREPARE EXPERIMENT COFIGURATION
            if strcmp(self.model_.doc_.save_filename_,'') == 1
                waitfor(errordlg("You didn't save this experiment. Please go back and save then run the experiment again."));
                return
            end
            [experiment_path, g4p_filename, ext] = fileparts(self.model_.doc_.save_filename_);
            experiment_folder = experiment_path;

            num_conditions = length(self.model_.block_trials_(:,1));
            if ~exist(fullfile(experiment_folder,'Log Files'),'dir')
                mkdir(experiment_folder,'Log Files');
            end
            
            %check if log files already present
            if length(dir([experiment_folder '\Log Files\']))>2
                fprintf('unsorted files present in "Log Files" folder, remove before restarting experiment\n');
                return
            end
            if exist([experiment_folder '\Results\' self.fly_name_],'dir')
                fprintf('Results folder already exists with that fly name\n');
                return
            end
            
            %Start host
            connectHost;
            Panel_com('change_root_directory',experiment_folder);
            
            %set acive ao channels
            if exist('active_ao_channels','var') && ~isempty(active_ao_channels) &&sum(active_ao_channels)>0
                aobits = 0;
                for bit = active_ao_channels
                    aobits = bitset(aobits,bit);
                end
                Panel_com('set_active_ao_channels', dec2bin(aobits,4));
            end
            
            if pre_start==1 %start with 10 seconds of closed loop stripe fixation
                Panel_com('set_control_mode',pretrial_mode);
                Panel_com('set_gain_bias', [pretrial_gain, pretrial_offset]);
                Panel_com('set_pattern_id', pretrial_pat_id);
               
                for i = 1:length(pretrial_ao_funcs)
                    Panel_com('set_ao_function_id',[active_ao_channels(i), pretrial_ao_indices(i)]);%[channel number, index of ao func]
                end

                pause(0.01)
                Panel_com('start_display', (10*10))
            end
            
            start = input('press enter to start experiment');
            
            %% run experiment
            exp_seconds = num_reps*num_conditions*(trial_duration + intertrial_duration);
            fprintf(['Estimated experiment duration: ' num2str(exp_seconds/60) ' minutes\n']);
            
            
            %%create .mat file of experiment order
            if randomize == 1
                exp_order = NaN(num_reps, num_conditions);
                for rep_ind = 1:num_reps
                    exp_order(rep_ind,:) = randperm(num_conditions);
                end
            else
                exp_order = repmat(1:num_conditions,num_reps,1);
            end
            save([experiment_folder '\Log Files\exp_order.mat'],'exp_order')
            
            %start experiment log and trial loop
            Panel_com('stop_display');
            Panel_com('start_log');
            for r = 1:num_reps
                for c = 1:num_conditions
                    cond = exp_order(r,c); % + exclude_stripe
                    pat_id = self.model_.get_pattern_index(block_trials{cond,2});
                    pos_func_id = self.model_.get_posfunc_index(block_trials{cond,3});
                    trial_mode = block_trials{cond,1};
                    for i = 1:length(active_ao_channels)
                        ao_func_indices(i) = self.model_.get_ao_index(block_trials{cond, active_ao_channels(i)+3});
                    end
                    
                    %intertrial portion
                    
%%%%%%%%%%%%%%%%%%%%%%%%%%%DOES THERE NEED TO BE A TYPE 2???why does type 2
                    %%%%%%%set an ao function id but not type 1? 
                    if inter_type == 1
                        Panel_com('set_control_mode', intertrial_mode);
                        Panel_com('set_pattern_id', intertrial_pat_id );
                        Panel_com('set_position_x', 1);
                        Panel_com('start_display', (intertrial_duration*10));
                        pause(intertrial_duration);
                    elseif inter_type == 2
                        Panel_com('set_control_mode', 4);
                        Panel_com('set_gain_bias', [LmR_gain, LmR_offset]);
                        Panel_com('set_pattern_id', 1);
                        for i = 1:length(intertrial_ao_funcs)
                            Panel_com('set_ao_function_id',[active_ao_channels(i), intertrial_ao_indices(i)]);
                        end
                        pause(0.01)
                        Panel_com('start_display', (intertrial_duration*10));
                        pause(intertrial_duration+0.1);
                    end
                    %end of intertrial portion
                    
                     %trial portion
                    Panel_com('set_control_mode', trial_mode);
                    Panel_com('set_pattern_id', pat_id);
                    if ~isempty(block_trials{cond,10})
                        LmR_gain = block_trials{cond,10};
                        LmR_offset = block_trials{cond,11};
                        Panel_com('set_gain_bias', [LmR_gain, LmR_offset]);
                    end
                    if pos_func_id ~= 0
                        Panel_com('set_pattern_func_id', pos_func_id);
                    end
                    fprintf(['Rep ' num2str(r) ' of ' num2str(num_reps) ', cond ' num2str(c) ' of ' num2str(num_conditions) ': ' strjoin(self.model_.doc_.currentExp_.currentExp.pattern.pattNames(pat_id)) '\n']);
                    
                    %%%%%%How does this work? what does the zero represent?
                    %%%%%%What if there are more than one ao_functions?
                    for i = 1:length(active_ao_channels)
                        Panel_com('set_ao_function_id',[active_ao_channels(i), ao_func_indices(i)]);
                    end
                    pause(0.01)
                    Panel_com('start_display', (trial_duration*10)); %duration expected in 100ms units
                    pause(trial_duration+0.1)
                    %end of trial portion
                    

                end
            end
            
            %rename/move results folder
            Panel_com('stop_display');
            pause(1);
            Panel_com('stop_log');
            disconnectHost;
            pause(1);
            movefile([experiment_folder '\Log Files\*'],fullfile(experiment_folder,'Results',self.fly_name_));
            save([experiment_folder '\Log Files\exp_order.mat'],'exp_order')
            disp('Experiment complete');

            
        end
        

        
        
        %SETTERS

        function set_fly_name(self, new_value)
            self.fly_name_ = new_value;
        end
        
        
        %GETTERS
        
        function [output] = get_fly_name(self)
            output = self.fly_name_;
        end
        
        
    end
    
    
    
end