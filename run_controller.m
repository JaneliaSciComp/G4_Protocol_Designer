classdef run_controller < handle
   
    properties
        model_;
        fig_;
        fly_name_;
        progress_axes_;
        progress_bar_;
        %total_trials_;

        
    end
    
    
    properties (Dependent)
        model;
        fig;
        fly_name;
        progress_axes;
        progress_bar;
       % total_trials;
        
        
    end
    
    
    
    methods
        
        %contstructor
        function self = run_controller(model)
            self.fig_ = figure('units','pixels','MenuBar', 'none', ...
                'ToolBar', 'none', 'Resize', 'off');
            self.model_ = model;
            self.layout();
%             self.total_trials_ = self.model_.get_repetitions()*length(self.model_.block_trials_{:,1});
%             if strcmp(self.model_.pretrial{2},'') == 0
%                 self.total_trials_ = self.total_trials_ + 1;
%             end
%             if strcmp(self.model_.posttrial{2},'') == 0
%                 self.total_trials_ = self.total_trials_ + 1;
%             end
%             if strcmp(self.model_.intertrial{2},'') == 0
%                 self.total_trials_ = self.total_trials_ + self.model_.get_repetitions() - 1;%%%%%%%IS THIS CORRECT? IS THERE AN INTERTRIAL AFTER THE LAST repetition or before the first repetition?
%             end

            
            
        
        end
        
        function layout(self)
           pix = get(0, 'screensize');
           fig_size = [.25*pix(3), .25*pix(4), .5*pix(3), .5*pix(4)];
           set(self.fig_,'Position',fig_size);
           
           
            start_button = uicontrol(self.fig_,'Style','pushbutton', 'String', 'Run', ...
                'units', 'pixels', 'Position', [fig_size(3) - 130, fig_size(4)*.2 + 30, 115, 85],'Callback', @self.run);
            settings_pan = uipanel(self.fig_, 'Title', 'Settings', 'units', 'pixels', ...
                'Position', [15, fig_size(4) - 215, 350, 200]);
            metadata_pan = uipanel(self.fig_, 'Title', 'Metadata', 'units', 'pixels', ...
                'Position', [fig_size(3) - 250, fig_size(4) - 265, 200, 250]);
            status_pan = uipanel(self.fig_, 'Title', 'Status', 'units', 'pixels', ...
                'Position', [15, 15, fig_size(3) - 30, fig_size(4)*.2]); 
            self.progress_axes_ = axes(self.fig_, 'units','pixels', 'Position', [15, fig_size(4)*.2+30, fig_size(3) - 145 ,50]);
            self.progress_bar_ = barh(0, 'Parent', self.progress_axes_,'BaseValue', 0);
            self.progress_axes_.XAxis.Limits = [0 1];
            self.progress_axes_.YAxis.Visible = 'off';
            self.progress_axes_.XAxis.Visible = 'off';

            
            
            %Settings required from user
            exp_name_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Experiment Name:', ...
                'units', 'pixels', 'Position', [10, 160, 100, 15]);
            exp_name_box = uicontrol(settings_pan, 'Style', 'edit', 'String', self.model_.experiment_name_, 'units', 'pixels', 'Position', ...
                [115, 160, 150, 18], 'Callback', @update_experiment_name);
            fly_name_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Fly Name:', ...
                'units', 'pixels', 'Position', [10, 135, 100, 15]);
            fly_name_box = uicontrol(settings_pan, 'Style', 'edit', 'String', self.fly_name_, ...
                'units', 'pixels', 'Position', [115, 135, 150, 18], 'Callback', @self.update_fly_name);
            exp_type_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Experiment Type:', ...
                'units', 'pixels', 'Position', [10, 110, 100, 15]);
            exp_type = uicontrol(settings_pan, 'Style', 'popupmenu', 'String', {'Flight','Camera walk', 'Chip walk'}, ...
                'units', 'pixels', 'Position', [115, 110, 150, 18]);
            test_button = uicontrol(settings_pan, 'Style', 'pushbutton', 'String', 'Run Test Protocol', ...
                'units', 'pixels', 'Position', [180, 80, 150, 20], 'Callback', @self.run_test);
            
        end
        
        function update_fly_name(self, src, event)
            
            self.set_fly_name(src.String);
            
        end
        
        function update_progress(self, rep, cond)
            increment = 1/(self.model_.repetitions_ * length(self.model_.block_trials_(:,1)));

            distance = ((rep - 1)*length(self.model_.block_trials_(:,1)) + cond)*increment;
            self.progress_axes_.Title.String = "Rep " + rep + " of " + self.model_.repetitions_ + ", Trial " + cond + " of " + length(self.model_.block_trials_(:,1));
            self.progress_bar_.YData = distance;
            
            drawnow;
            
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
            if isempty(intertrial{2})
                inter_type = 0;
            else
                inter_type = 1;
            end
 
            
            %pre_start indicates whether there is a pretrial or not
            
            if isempty(pretrial{2})
                pre_start = 0;
            else
                pre_start = 1; 
            end
            
            %post_type indicates if there is a posttrial or not
            
            if isempty(posttrial{2})
                post_type = 0;
            else
                post_type = 1;
            end
            %%Get active channels from the model, create array of their
            %%numeric representations, ie if channels 1 and 3 are active,
            %%active_ao_channels will be [0,2]; 
            
            %THIS METHOD will create an array like [0, 2, 3] if ao channels
            %1,3, and 4 are active. Is this correct??????????????
            channels = [self.model_.get_is_chan1(), self.model_.get_is_chan2(), self.model_.get_is_chan3(), self.model_.get_is_chan4()];
            channel_nums = [0,1,2,3];
            
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
                pretrial_ao_indices(i) = self.model_.get_ao_index(pretrial{channel_num + 4});
                ao_indices(i) = self.model_.get_ao_index(block_trials{1,channel_num + 4});
                intertrial_ao_indices(i) = self.model_.get_ao_index(intertrial{channel_num + 4});
                posttrial_ao_indices(i) = self.model_.get_ao_index(posttrial{channel_num + 4});
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
                waitfor(errordlg('unsorted files present in "Log Files" folder, remove before restarting experiment\n'));
                return
            end
            if exist([experiment_folder '\Results\' self.fly_name_],'dir')
                waitfor(errordlg('Results folder already exists with that fly name\n'));
                return
            end
            
            %Start host
            connectHost;
            Panel_com('change_root_directory',experiment_folder);
            
            %set acive ao channels
            if exist('active_ao_channels','var') && ~isempty(active_ao_channels) &&sum(active_ao_channels)>0
                aobits = 0;
                for bit = active_ao_channels
                    aobits = bitset(aobits,bit+1); %plus 1 bc aochans are 0-3
                end
                Panel_com('set_active_ao_channels', dec2bin(aobits,4));
            end
            start = questdlg('Start Experiment?','Confirm Start','Start','Cancel','Start');
            if pre_start==1 %start with 10 seconds of closed loop stripe fixation
                Panel_com('set_control_mode',pretrial_mode);
                Panel_com('set_pattern_func_id',pretrial_posfunc_id);
                Panel_com('set_gain_bias', [pretrial_gain, pretrial_offset]);
                Panel_com('set_pattern_id', pretrial_pat_id);
               
                for i = 1:length(pretrial_ao_funcs)
                    Panel_com('set_ao_function_id',[active_ao_channels(i), pretrial_ao_indices(i)]);%[channel number, index of ao func]
                end
                
                if pretrial_mode == 2
                    Panel_com('set_frame_rate', pretrial{9});
                end
                
                if pretrial_mode == 3
                    Panel_com('set_position_x', pretrial{8});
                end
                
                pause(0.01)
                Panel_com('start_display', (pretrial_duration*10))
                pause(pretrial_duration);
            end
            
           
            switch start
                case 'Cancel'
                    Panel_com('stop_display')
                    disconnectHost;
                    return;
                case 'Start'
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
                        
                        self.update_progress(r, c);
                        cond = exp_order(r,c); % + exclude_stripe
                        pat_id = self.model_.get_pattern_index(block_trials{cond,2});
                        pos_func_id = self.model_.get_posfunc_index(block_trials{cond,3});
                        trial_mode = block_trials{cond,1};
                        for i = 1:length(active_ao_channels)
                            ao_func_indices(i) = self.model_.get_ao_index(block_trials{cond, active_ao_channels(i)+ 4});
                        end

                        %intertrial portion

    %%%%%%%%%%%%%%%%%%%%%%%%%%%DOES THERE NEED TO BE A TYPE 2???why does type 2
                        %%%%%%%set an ao function id but not type 1? 
                        if inter_type == 1
                            Panel_com('set_control_mode', intertrial_mode);
                            Panel_com('set_pattern_id', intertrial_pat_id );
                            Panel_com('set_pattern_func_id',intertrial_posfunc_id);
                            if intertrial_mode == 3
                                Panel_com('set_position_x', intertrial{8});
                            end
                            for i = 1:length(intertrial_ao_funcs)
                                Panel_com('set_ao_function_id',[active_ao_channels(i), intertrial_ao_indices(i)]);
                            end
                            if intertrial_mode == 2
                                Panel_com('set_frame_rate', intertrial{9});
                            end
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
                        %Panel_com('stop_display')
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
                        if trial_mode == 2
                            Panel_com('set_frame_rate',block_trials{cond,9});
                        end
                        if trial_mode == 3
                            Panel_com('set_position_x', block_trials{cond,8});
                        end
    %                     counter = "Rep " + num2str(r) + " of " + num2str(num_reps) + ", cond " + num2str(c) + " of " + num2str(num_conditions) +": " + strjoin(self.model_.doc_.currentExp_.currentExp.pattern.pattNames(pat_id));
    %                     disp(counter);

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
                
                if post_type == 1
                     Panel_com('set_control_mode', posttrial_mode);
                     Panel_com('set_pattern_id', posttrial_pat_id);
                     if ~isempty(posttrial{10})
                         Panel_com('set_gain_bias', [posttrial_gain, posttrial_offset]);
                     end
                     if pos_func_id ~= 0
                         Panel_com('set_pattern_func_id', posttrial_posfunc_id);
                     end
                     if posttrial_mode == 2
                         Panel_com('set_frame_rate', posttrial{9});
                     end
                     if posttrial_mode == 3
                         Panel_com('set_position_x',posttrial{8});
                     end
                     Panel_com('start_display',posttrial_duration*10);
                     pause(posttrial_duration);
                end
                %rename/move results folder
                Panel_com('stop_display');
                pause(1);
                Panel_com('stop_log');
                disconnectHost;
                pause(1);
                movefile([experiment_folder '\Log Files\*'],fullfile(experiment_folder,'Results',self.fly_name_));
                %save([experiment_folder '\Log Files\exp_order.mat'],'exp_order')
                self.progress_axes_.Title.String = "Experiment Completed.";
                drawnow;

            
            end
        end
        
        function run_test(self, src, event)
        
%             [testFilename, testFilepath] = uigetfile('*.g4p');
%             filepath = fullfile(testFilepath, testFilename);
%             
%             test_protocol_params = load(filepath, '-mat');
%             
            
   
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