classdef run_controller < handle
   
    properties
        model_;
        doc_;
        fig_;
        
        
        %GUI objects
        progress_axes_;
        progress_bar_;
        experimenter_box_
        exp_name_box_
        fly_name_box_
        fly_genotype_box_
        date_and_time_box_
        exp_type_menu_
        plotting_checkbox_
        plotting_textbox_
        processing_checkbox_
        processing_textbox_
        %total_trials_;

        
    end
    
    
    properties (Dependent)
        model;
        doc;
        fig;

        progress_axes;
        progress_bar;
        experimenter_box
        exp_name_box
        fly_name_box
        fly_genotype_box
        date_and_time_box
        exp_type_menu
        plotting_checkbox
        plotting_textbox
        processing_checkbox
        processing_textbox
       % total_trials;
        
        
    end
    
    
    
    methods
        
        %contstructor
        function self = run_controller(varargin)
            self.fig = figure('Name', 'Fly Experiment Conductor', 'NumberTitle', 'off', 'units','pixels','MenuBar', 'none', ...
                'ToolBar', 'none', 'Resize', 'off');
            self.model = run_model();
            self.doc = document();
            
            
            if ~isempty(varargin)
                
                self.doc = varargin{1};
                
            end
            
            self.layout();
%             self.total_trials_ = self.model.get_repetitions()*length(self.model.block_trials_{:,1});
%             if strcmp(self.model.pretrial{2},'') == 0
%                 self.total_trials_ = self.total_trials_ + 1;
%             end
%             if strcmp(self.model.posttrial{2},'') == 0
%                 self.total_trials_ = self.total_trials_ + 1;
%             end
%             if strcmp(self.model.intertrial{2},'') == 0
%                 self.total_trials_ = self.total_trials_ + self.model.get_repetitions() - 1;%%%%%%%IS THIS CORRECT? IS THERE AN INTERTRIAL AFTER THE LAST repetition or before the first repetition?
%             end

            
            
        
        end
        
        function layout(self)
           pix = get(0, 'screensize');
           fig_size = [.25*pix(3), .25*pix(4), .5*pix(3), .5*pix(4)];
           set(self.fig,'Position',fig_size);

           
           menu = uimenu(self.fig, 'Text', 'File');
           menu_open = uimenu(menu, 'Text', 'Open', 'Callback', @self.open_g4p_file);
         %  menu_clear = uimenu(menu, 'Text', 'Clear', 'Callback', @self.clear_data);
           
            start_button = uicontrol(self.fig,'Style','pushbutton', 'String', 'Run', ...
                'units', 'pixels', 'Position', [15, fig_size(4)- 305, 115, 85],'Callback', @self.run);
            settings_pan = uipanel(self.fig, 'Title', 'Settings', 'FontSize', 13, 'units', 'pixels', ...
                'Position', [15, fig_size(4) - 215, 370, 200]);
            metadata_pan = uipanel(self.fig, 'Title', 'Metadata', 'units', 'pixels', ...
                'FontSize', 13, 'Position', [fig_size(3) - 300, fig_size(4) - 265, 275, 250]);
            status_pan = uipanel(self.fig, 'Title', 'Status', 'FontSize', 13, 'units', 'pixels', ...
                'Position', [15, 15, fig_size(3) - 30, fig_size(4)*.2]); 
            self.progress_axes = axes(self.fig, 'units','pixels', 'Position', [15, fig_size(4)*.2+30, fig_size(3) - 15 ,50]);
            axes_label = uicontrol(self.fig, 'Style', 'text', 'String', 'Progress:', 'FontSize', 13, ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [15, fig_size(4)*.2 + 85, 100, 20]);
            self.progress_bar = barh(0, 'Parent', self.progress_axes,'BaseValue', 0);
            self.progress_axes.XAxis.Limits = [0 1];
           % self.progress_axes.YAxis.Visible = 'off';
           % self.progress_axes.XAxis.Visible = 'off';
           self.progress_axes.YTickLabel = [];
           self.progress_axes.XTickLabel = [];
           self.progress_axes.XTick = [];
           self.progress_axes.YTick = [];
           reps = self.doc.repetitions;
           for i = 1:reps
               x = (1/reps)*i;
               line('XData', [x, x], 'YDATA', [0,2]);
           end

            
            
            %Settings required from user
            experimenter_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Experimenter:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 200, 100, 15]);
            self.experimenter_box = uicontrol(metadata_pan, 'Style', 'edit', 'units', 'pixels', ...
                'String', self.model.experimenter, 'Position', [115, 200, 150, 18], 'Callback', @self.update_experimenter);
            exp_name_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Experiment Name:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 175, 100, 15]);
            self.exp_name_box = uicontrol(metadata_pan, 'Style', 'edit', 'String', self.doc.experiment_name, 'units', 'pixels', 'Position', ...
                [115, 175, 150, 18], 'Callback', @self.update_experiment_name);
            fly_name_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Fly Name:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 150, 100, 15]);
            self.fly_name_box = uicontrol(metadata_pan, 'Style', 'edit', 'String', self.model.fly_name, ...
                'units', 'pixels', 'Position', [115, 150, 150, 18], 'Callback', @self.update_fly_name);
            fly_genotype_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Fly Genotype', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 125, 100, 15]);
            self.fly_genotype_box = uicontrol(metadata_pan, 'Style', 'edit', 'units', 'pixels', ...
                'String', self.model.fly_genotype, 'Position', [115, 125, 150, 18], 'Callback', @self.update_genotype);
            date_and_time_label = uicontrol(metadata_pan, 'Style', 'text', 'String', 'Date and Time:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 100, 100, 15]);
            self.date_and_time_box = uicontrol(metadata_pan, 'Style', 'edit', 'String', datestr(now, 'mm-dd-yyyy HH:MM:SS'), ...
                'units', 'pixels', 'Position', [115, 100, 150, 18]);
            exp_type_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Experiment Type:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 150, 100, 15]);
            self.exp_type_menu = uicontrol(settings_pan, 'Style', 'popupmenu', 'String', {'Flight','Camera walk', 'Chip walk'}, ...
                'units', 'pixels', 'Position', [115, 150, 150, 18], 'Callback', @self.update_experiment_type);
            test_button = uicontrol(settings_pan, 'Style', 'pushbutton', 'String', 'Run Test Protocol', ...
                'units', 'pixels', 'Position', [210, 120, 150, 20], 'Callback', @self.run_test);
            plotting_checkbox_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Plotting?', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 95, 65, 15]);
            self.plotting_checkbox = uicontrol(settings_pan, 'Style', 'checkbox', 'Value', self.model.do_plotting, ...
                'units', 'pixels', 'Position', [80, 95, 15, 15], 'Callback', @self.update_do_plotting);
            plotting_filename_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Plotting Protocol:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [100, 95, 105, 15]);
            self.plotting_textbox = uicontrol(settings_pan, 'Style', 'edit', 'units', 'pixels', ...
                'String', self.model.plotting_file, 'Position', [210, 95, 150, 18], 'Callback', @self.update_plotting_file);
            processing_checkbox_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Processing?', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [10, 70, 65, 15]);
            self.processing_checkbox = uicontrol(settings_pan, 'Style', 'checkbox', 'Value', self.model.do_processing, ...
                'units', 'pixels', 'Position', [80, 70, 15, 15], 'Callback', @self.update_do_processing);
            processing_filename_label = uicontrol(settings_pan, 'Style', 'text', 'String', 'Processing Protocol:', ...
                'HorizontalAlignment', 'left', 'units', 'pixels', 'Position', [100, 70, 105, 15]);
            self.processing_textbox = uicontrol(settings_pan, 'Style', 'edit', 'units', 'pixels', ...
                'String', self.model.processing_file, 'Position', [210, 70, 150, 18], 'Callback', @self.update_processing_file);
            
            
        end
        
        function update_run_gui(self)
           
            self.experimenter_box.String = self.model.experimenter;
            self.exp_name_box.String = self.doc.experiment_name;
            self.fly_name_box.String = self.model.fly_name;
            self.fly_genotype_box.String = self.model.fly_genotype;
            self.date_and_time_box.String = datestr(now, 'mm-dd-yyyy HH:MM:SS');
            self.plotting_checkbox.Value = self.model.do_plotting;
            self.plotting_textbox.String = self.model.plotting_file;
            self.processing_checkbox.Value = self.model.do_processing;
            self.processing_textbox.String = self.model.processing_file;
            self.exp_type_menu.Value = self.model.experiment_type;
            
        end
        
        function update_fly_name(self, src, event)
            
            self.model.fly_name = src.String;
            
        end
        
        function update_experimenter(self, src, event)
            
            self.model.experimenter = src.String;
            
        end
        
        function update_experiment_name(self, src, event)
            
            errormsg = "The experiment has already been saved under this name. " ...
                + "If you would like to change the experiment name, close this window " ...
                + "and save it under the new name in the designer view.";
            waitfor(errordlg(errormsg));
            self.exp_name_box.String = self.doc.experiment_name;
        end
        
        function update_genotype(self, src, event)
            self.model.fly_genotype = src.String;
        end
        
        function update_do_plotting(self, src, event)
            self.model.do_plotting = src.Value;
        end
        
        function update_do_processing(self, src, event)
            self.model.do_processing = src.Value;
        end
        
        function update_plotting_file(self, src, event)
            self.model.plotting_file = src.String;
        end
        
        function update_processing_file(self, src, event)
            self.model.processing_file = src.String;
        end
        
        function update_experiment_type(self, src, event)
            self.model.experiment_type = src.Value;
        end
        
        function update_progress(self, rep, trial, cond)
            increment = 1/(self.doc.repetitions * length(self.doc.block_trials(:,1)));

            distance = ((rep - 1)*length(self.doc.block_trials(:,1)) + trial)*increment;
            self.progress_axes.Title.String = "Rep " + rep + " of " + self.doc.repetitions +...
                ", Trial " + trial + " of " + length(self.doc.block_trials(:,1)) + ". Condition number: " + cond;
            self.progress_bar.YData = distance;
            
            drawnow;
            
        end
        
        function test_progress_bar(self, src, event)
        
            reps = self.doc.repetitions;
            trials = length(self.doc.block_trials(:,1));
            for i = 1:reps
                for j = 1:trials
                    
                    self.update_progress(i,j);
                    pause(1);
                end
            end
        
        
        end
        
     
        function open_g4p_file(self, src, event)
           
            [filename, top_folder_path] = uigetfile('*.g4p');
            filepath = fullfile(top_folder_path, filename);
       
            if isequal (top_folder_path,0)
            
            %They hit cancel, do nothing
            else
                
                self.doc.import_folder(top_folder_path);
                [exp_path, exp_name, ext] = fileparts(filepath);
              % [exp_path, exp_name] = fileparts(self.doc.top_folder_path_);
                self.doc.experiment_name = exp_name;
                self.doc.save_filename = top_folder_path;
                
                data = self.doc.open(filepath);
                p = data.exp_parameters;
                
                self.doc.repetitions = p.repetitions;
                self.doc.is_randomized = p.is_randomized;
                self.doc.is_chan1 = p.is_chan1;
                self.doc.is_chan2 = p.is_chan2;
                self.doc.is_chan3 = p.is_chan3;
                self.doc.is_chan4 = p.is_chan4;
                self.doc.chan1_rate = p.chan1_rate;
                self.doc.set_config_data(p.chan1_rate, 1);
                self.doc.chan2_rate = p.chan2_rate;
                self.doc.set_config_data(p.chan2_rate, 2);
                self.doc.chan3_rate = p.chan3_rate;
                self.doc.set_config_data(p.chan3_rate, 3);
                self.doc.chan4_rate = p.chan4_rate;
                self.doc.set_config_data(p.chan4_rate, 4);
                self.doc.num_rows = p.num_rows;
                self.doc.set_config_data(p.num_rows, 0);
                self.doc.update_config_file();
                
                for k = 1:13

                    self.doc.set_pretrial_property(k, p.pretrial{k});
                    self.doc.set_intertrial_property(k, p.intertrial{k});
                    self.doc.set_posttrial_property(k, p.posttrial{k});

                end

                for i = 2:length(self.doc.block_trials(:, 1))
                    self.doc.block_trials((i-(i-2)),:) = [];
                end
                block_x = length(p.block_trials(:,1));
                block_y = 1;

                for j = 1:block_x
                    if j > length(self.doc.block_trials(:,1))
                        newrow = p.block_trials(j,1:end);
                        self.doc.set_block_trial_property([j, block_y], newrow);
                    else
                        for n = 1:13
                            self.doc.set_block_trial_property([j, n], p.block_trials{j,n});
                        end
                    end

                end
                
                self.update_run_gui();
                
                
            end

            
        end
        
        function run(self, src, event)
            %Get necessary data
            
            experiment_name = self.doc.experiment_name;
            num_reps = self.doc.repetitions;
            randomize = self.doc.is_randomized;
            
            pretrial = self.doc.pretrial;
            block_trials = self.doc.block_trials;
            intertrial = self.doc.intertrial;
            posttrial = self.doc.posttrial;
            
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
            pretrial_pat_id = self.doc.get_pattern_index(pretrial{2});
            pretrial_posfunc_id = self.doc.get_posfunc_index(pretrial{3});
            
            if ~isempty(pretrial{10})
                pretrial_gain = pretrial{10};
                pretrial_offset = pretrial{11};

                
            else
                pretrial_gain = 0;
                pretrial_offset = 0;

                
            end
            
            
            %first run of block_trials
%             trial_mode = block_trials{1,1};
%             pat_index = self.doc.get_pattern_index(block_trials{1,2});
%             posfunc_index = self.doc.get_posfunc_index(block_trials{1,3});
            if ~isempty(block_trials{1,10})
                LmR_gain = block_trials{1,10};
                LmR_offset = block_trials{1,11};
                
            else
                LmR_gain = 0;
                LmR_offset = 0;
                
            end
            
            %intertrial values
            intertrial_mode = intertrial{1};
            intertrial_pat_id = self.doc.get_pattern_index(intertrial{2});
            intertrial_posfunc_id = self.doc.get_posfunc_index(intertrial{3});
            if ~isempty(intertrial{10})
                intertrial_gain = intertrial{10};
                intertrial_offset = intertrial{11};
            else
                intertrial_gain = 0;
                intertrial_offset = 0;
                
            end
           
            %posttrial values
            posttrial_mode = posttrial{1};
            posttrial_pat_id = self.doc.get_pattern_index(posttrial{2});
            posttrial_posfunc_id = self.doc.get_posfunc_index(posttrial{3});
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
            ao1_funcs = {};
            ao1_funcs{1} = pretrial{4};
            for c = 1:length(block_trials(:,1))
                ao1_funcs{c+1} = block_trials{c,4};
            end
            ao1_funcs{end + 1} =  intertrial{4};
            ao1_funcs{end + 1} = posttrial{4};
            
            ao2_funcs = {};
            ao2_funcs{1} = pretrial{5};
            for c = 1:length(block_trials(:,1))
                ao2_funcs{c+1} = block_trials{c,5};
            end
            ao2_funcs{end + 1} =  intertrial{5};
            ao2_funcs{end + 1} = posttrial{5};
            
            ao3_funcs = {};
            ao3_funcs{1} = pretrial{6};
            for c = 1:length(block_trials(:,1))
                ao3_funcs{c+1} = block_trials{c,6};
            end
            ao3_funcs{end + 1} =  intertrial{6};
            ao3_funcs{end + 1} = posttrial{6};
            
            
            ao4_funcs = {};
            ao4_funcs{1} = pretrial{7};
            for c = 1:length(block_trials(:,1))
                ao4_funcs{c+1} = block_trials{c,7};
            end
            ao4_funcs{end + 1} =  intertrial{7};
            ao4_funcs{end + 1} = posttrial{7};
            
            ao1_active = 0;
            for i = 1:length(ao1_funcs)
                if ~strcmp(ao1_funcs{i},'')
                    ao1_active = 1;
                end
            end
            
            ao2_active = 0;
            for i = 1:length(ao2_funcs)
                if ~strcmp(ao2_funcs{i},'')
                    ao2_active = 1;
                end
            end
            
            ao3_active = 0;
            for i = 1:length(ao3_funcs)
                if ~strcmp(ao3_funcs{i},'')
                    ao3_active = 1;
                end
            end
            
            ao4_active = 0;
            for i = 1:length(ao4_funcs)
                if ~strcmp(ao4_funcs{i},'')
                    ao4_active = 1;
                end
            end
            channels = [ao1_active, ao2_active, ao3_active, ao4_active];
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
                pretrial_ao_indices(i) = self.doc.get_ao_index(pretrial{channel_num + 4});
                ao_indices(i) = self.doc.get_ao_index(block_trials{1,channel_num + 4});
                intertrial_ao_indices(i) = self.doc.get_ao_index(intertrial{channel_num + 4});
                posttrial_ao_indices(i) = self.doc.get_ao_index(posttrial{channel_num + 4});
            end
         
            
            
            %% PREPARE EXPERIMENT COFIGURATION
            if strcmp(self.doc.save_filename_,'') == 1
                waitfor(errordlg("You didn't save this experiment. Please go back and save then run the experiment again."));
                return
            end
            [experiment_path, g4p_filename, ext] = fileparts(self.doc.save_filename_);
            experiment_folder = experiment_path;

            num_conditions = length(self.doc.block_trials(:,1));
            if ~exist(fullfile(experiment_folder,'Log Files'),'dir')
                mkdir(experiment_folder,'Log Files');
            end
            
            %check if log files already present
            
            if length(dir([experiment_folder '\Log Files\']))>2
                waitfor(errordlg('unsorted files present in "Log Files" folder, remove before restarting experiment\n'));
                return
            end
            if exist([experiment_folder '\Results\' self.model.fly_name],'dir')
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
            Panel_com('start_log');
            pause(1);
            if pre_start==1 %start with 10 seconds of closed loop stripe fixation
                Panel_com('set_control_mode',pretrial_mode);
                if pretrial_posfunc_id ~= 0
                    Panel_com('set_pattern_func_id',pretrial_posfunc_id);
                end
                if ~isempty(pretrial_gain)
                    Panel_com('set_gain_bias', [pretrial_gain, pretrial_offset]);
                end
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
                
                for r = 1:num_reps
                    for c = 1:num_conditions
                        
                        cond = exp_order(r,c); % + exclude_stripe
                        self.update_progress(r, c, cond);
                        
                        pat_id = self.doc.get_pattern_index(block_trials{cond,2});
                        pos_func_id = self.doc.get_posfunc_index(block_trials{cond,3});
                        trial_mode = block_trials{cond,1};
                        for i = 1:length(active_ao_channels)
                            ao_func_indices(i) = self.doc.get_ao_index(block_trials{cond, active_ao_channels(i)+ 4});
                        end

                        

    %%%%%%%%%%%%%%%%%%%%%%%%%%%DOES THERE NEED TO BE A TYPE 2???why does type 2
                        %%%%%%%set an ao function id but not type 1? 
                        
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
    %                     counter = "Rep " + num2str(r) + " of " + num2str(num_reps) + ", cond " + num2str(c) + " of " + num2str(num_conditions) +": " + strjoin(self.doc.currentExp_.currentExp.pattern.pattNames(pat_id));
    %                     disp(counter);

                        %%%%%%How does this work? what does the zero represent?
                        %%%%%%What if there are more than one ao_functions?


                        for i = 1:length(active_ao_channels)
                            Panel_com('set_ao_function_id',[active_ao_channels(i), ao_func_indices(i)]);
                        end
                        pause(0.01)
                        Panel_com('start_display', (trial_duration*10)); %duration expected in 100ms units
                        pause(trial_duration)
                        %end of trial portion
                        
                        if r == num_reps && c == num_conditions
   
                            continue
                        end
                        
                        %intertrial portion
                        if inter_type == 1
 
                            Panel_com('set_control_mode', intertrial_mode);
                            Panel_com('set_pattern_id', intertrial_pat_id );
                            if intertrial_posfunc_id ~= 0
                                Panel_com('set_pattern_func_id',intertrial_posfunc_id);
                            end
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

                        

                    end
                end
                
                if post_type == 1
                    disp("This is the post-trial!");
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
                movefile([experiment_folder '\Log Files\*'],fullfile(experiment_folder,'Results',self.model.fly_name));
                %save([experiment_folder '\Log Files\exp_order.mat'],'exp_order')
                self.progress_axes.Title.String = "Experiment Completed.";
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

        
        function set.model(self, value)
            self.model_ = value;
        end
        
        function set.fig(self, value)
            self.fig_ = value;
        end
        
%         function set.fly_name(self, value)
%             self.model.fly_name_ = value;
%         end
        
        function set.progress_axes(self, value)
            self.progress_axes_ = value;
        end
        
        function set.progress_bar(self, value)
            self.progress_bar_ = value;
        end
        
        function set.doc(self, value)
            self.doc_ = value;
        end
        
        function set.experimenter_box(self, value)
            self.experimenter_box_ = value;
        end
        
        function set.exp_name_box(self, value)
            self.exp_name_box_ = value;
        end
        
        function set.fly_name_box(self, value)
            self.fly_name_box_ = value;
        end
        
        function set.fly_genotype_box(self, value)
            self.fly_genotype_box_ = value;
        end
        
        function set.date_and_time_box(self, value)
            self.date_and_time_box_ = value;
        end
        
        function set.exp_type_menu(self, value)
            self.exp_type_menu_ = value;
        end
        
        function set.plotting_checkbox(self, value)
            self.plotting_checkbox_ = value;
        end
        
        function set.plotting_textbox(self, value)
            self.plotting_textbox_ = value;
        end
        
        function set.processing_checkbox(self, value)
            self.processing_checkbox_ = value;
        end
        
        function set.processing_textbox(self, value)
            self.processing_textbox_ = value;
        end



        %GETTERS
        
        function value = get.model(self)
           value = self.model_;
        end
        
        function value = get.fig(self)
            value = self.fig_;
        end
        
%         function value = get.fly_name(self)
%             value = self.model.fly_name_;
%         end
        
        function value = get.progress_axes(self)
            value = self.progress_axes_;
        end
        
        function value = get.progress_bar(self)
            value = self.progress_bar_;
        end
        
        function value = get.doc(self)
            value = self.doc_;
        end
        
        function value = get.experimenter_box(self)
            value = self.experimenter_box_;
        end
        
        function value = get.exp_name_box(self)
            value = self.exp_name_box_;
        end
        
        function value = get.fly_name_box(self)
            value = self.fly_name_box_;
        end
        
        function value = get.fly_genotype_box(self)
            value = self.fly_genotype_box_;
        end
        
        function value = get.date_and_time_box(self)
            value = self.date_and_time_box_;
        end
        
        function value = get.exp_type_menu(self)
            value = self.exp_type_menu_;
        end
        
        function value = get.plotting_checkbox(self)
            value = self.plotting_checkbox_;
        end
        
        function value = get.plotting_textbox(self)
            value = self.plotting_textbox_;
        end
        
        function value = get.processing_checkbox(self)
            value = self.processing_checkbox_;
        end
        
        function value = get.processing_textbox(self)
            value = self.processing_textbox_;
        end
        
%         function [output] = get_fly_name(self)
%             output = self.model.fly_name_;
%         end
        
        
        
       
        
    end
    
    
    
end