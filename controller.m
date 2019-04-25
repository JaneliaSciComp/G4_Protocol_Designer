classdef controller < handle %Made this handle class because was having trouble getting setters to work, especially with struct properties. 

    properties
        model_ %contains all values
        preview_con_; %controller for the fullscreen preview
        run_con_;
        
        %Tables
        %tables_
        pretrial_table_
        intertrial_table_
        block_table_
        posttrial_table_
        
        %structs in which to load files as they are entered
        pre_files_
        block_files_
        inter_files_
        post_files_
        
        %tracking which file is in the current preview window
        current_preview_file_
        current_selected_cell_
        
        %Tracking position in in-window preview
        auto_preview_index_
        is_paused_
        
        %channel gui objects
        chan1_
        chan1_rate_box_
        chan2_
        chan2_rate_box_
        chan3_
        chan3_rate_box_
        chan4_
        chan4_rate_box_
        bg2_
        
        %Other values

        isSelect_all_


        %Other gui objects
        isRandomized_radio_
        isSequential_radio_
        bg_
        repetitions_box_
        isSelect_all_box_
        f_
        preview_panel
        hAxes_
        num_rows_3_
        num_rows_4_
        exp_name_box_

        %is_ao_visible_
    end

    properties(Dependent)

        pretrial_table
        intertrial_table
        posttrial_table
        block_table
        
        %Tracking which cell is selected in each table
        pre_selected_index
        inter_selected_index
        post_selected_index
        block_selected_index
        
        %Tracking position in in-window preview
        auto_preview_index
       
        chan1
        chan1_rate_box
        chan2
        chan2_rate_box
        chan3
        chan3_rate_box
        chan4
        chan4_rate_box
        bg2
        num_rows_3
        num_rows_4
        isSelect_all

        
%         isRandomized_box
%         repetitions_box
%         isSelect_all_box

        %is_ao_visible

    end


    methods
        
        
        
%CONSTRUCTOR---------------------------------------------------------------

        function self = controller()
           
            self.model_ = model_class();        
            self.isSelect_all_ = false;
            self.auto_preview_index_ = 1;
            screensize = get(0, 'screensize');

            self.f_ = figure('units', 'pixels', 'MenuBar', 'none', ...
                'ToolBar', 'none', 'Resize', 'off', 'outerposition', [screensize(3)*.1, screensize(4)*.1, 1600, 1000]);
           %ALL REST OF PROPERTIES ARE DEFINED IN LAYOUT         
          self.pre_files_ = struct('pattern', self.model_.pretrial_(2),...
               'position',self.model_.pretrial_(3),'ao1',self.model_.pretrial_(4),...
               'ao2',self.model_.pretrial_(5),'ao3',self.model_.pretrial_(6),...
               'ao4',self.model_.pretrial_(7));
           self.block_files_ = struct('pattern', string(self.model_.block_trials_(2)),...
               'position',string(self.model_.block_trials_(3)),'ao1',string(self.model_.block_trials_(4)),...
               'ao2',string(self.model_.block_trials_(5)),'ao3',string(self.model_.block_trials_(6)),...
               'ao4',string(self.model_.block_trials_(7)));
           self.inter_files_ = struct('pattern', self.model_.intertrial_(2),...
               'position',self.model_.intertrial_(3),'ao1',self.model_.intertrial_(4),...
               'ao2',self.model_.intertrial_(5),'ao3',self.model_.intertrial_(6),...
               'ao4',self.model_.intertrial_(7));
           self.post_files_ = struct('pattern', self.model_.posttrial_(2),...
               'position',self.model_.posttrial_(3),'ao1',self.model_.posttrial_(4),...
               'ao2',self.model_.posttrial_(5),'ao3',self.model_.posttrial_(6),...
               'ao4',self.model_.posttrial_(7));
           self.current_preview_file_ = '';
           self.current_selected_cell_ = struct('table', "", 'index', [0,0]);
           self.is_paused_ = false;
           self.layout_gui() ;
           self.update_gui() ;
           self.set_bg2_selection();
        end

%GUI LAYOUT METHOD DECLARES ALL OBJECTS ON SCREEN--------------------------

        function layout_gui(self)


            %PARAMETERS ONLY USED IN LAYOUT

            column_names_ = {'Mode', 'Pattern Name' 'Position Function', ...
                'AO 1', 'AO 2', 'AO 3', 'AO 4', ...
                'Frame Index', 'Frame Rate', 'Gain', 'Offset', 'Duration' ...
                'Select'};
            columns_editable_ = true;
            column_format_ = {'numeric', 'char', 'char', 'char', 'char','char', ...
                'char', 'numeric', 'numeric', 'numeric', 'numeric', 'numeric', 'logical'};
            font_size_ = 10;
            positions.pre = [350, 870, 1035, 50];
            %pos_pre_ = [350, 870, 1035, 50];
            positions.inter = [350, 815, 1035, 50];
            %pos_inter_ = [350, 815, 1035, 50];
            positions.block = [350, 585, 1035, 200];
            %pos_block_ = [350, 585, 1035, 200];
            positions.post = [350, 525, 1035, 50];
            %pos_post_ = [350, 525, 1035, 50];
            pos_panel_ = [350, 190, 1035, 325];
            pos_menu_ = [15, 875, 105, 40];



            pretrial_label_ = uicontrol(self.f_, 'Style', 'text', 'String', 'Pre-Trial', ...
               'Units', 'Pixels', 'FontSize', font_size_, ...
           'Position', [positions.pre(1) - 85, positions.pre(2) + 15, 78, 20]);

            self.pretrial_table_ = uitable(self.f_, 'data', self.model_.pretrial_, 'columnname', column_names_, ...
            'units', 'pixels', 'Position', positions.pre, 'ColumnEditable', columns_editable_, 'ColumnFormat', column_format_, ...
           'CellEditCallback', @self.update_model_pretrial, 'CellSelectionCallback', {@self.preview_selection, positions});

            intertrial_label_ = uicontrol(self.f_, 'Style', 'text', 'String', 'Inter-Trial', ...
               'units', 'pixels', 'FontSize', font_size_, ...
           'Position', [positions.inter(1) - 85, positions.inter(2) + 15, 78, 20]);

            self.intertrial_table_ = uitable(self.f_, 'data', self.model_.intertrial_, 'columnname', column_names_, ...
            'units', 'pixels', 'Position', positions.inter, 'ColumnEditable', columns_editable_, 'ColumnFormat', column_format_, ...
            'CellEditCallback', @self.update_model_intertrial, 'CellSelectionCallback', {@self.preview_selection, positions});

            blocktrial_label_ = uicontrol(self.f_, 'Style', 'text', 'String', 'Block Trials', ...
               'units', 'pixels', 'FontSize', font_size_, ...
           'Position', [positions.block(1) - 85, positions.block(2) + .5*positions.block(4), 78, 20]);

            self.block_table_ = uitable(self.f_, 'data', self.model_.block_trials_, 'columnname', column_names_, ...
            'units', 'pixels', 'Position', positions.block, 'ColumnEditable', columns_editable_, 'ColumnFormat', column_format_, ...
            'CellEditCallback', @self.update_model_block_trials, 'CellSelectionCallback', {@self.preview_selection, positions});


            posttrial_label_ = uicontrol(self.f_, 'Style', 'text', 'String', 'Post-Trial', ...
               'units', 'pixels', 'FontSize', font_size_, ...
           'Position', [positions.post(1) - 85, positions.post(2) + 15, 78, 20]);

            self.posttrial_table_ = uitable(self.f_, 'data', self.model_.posttrial_, 'columnname', column_names_, ...
            'units', 'pixels', 'Position', positions.post, 'ColumnEditable', columns_editable_, 'ColumnFormat', column_format_, ...
            'CellEditCallback', @self.update_model_posttrial, 'CellSelectionCallback', {@self.preview_selection, positions});

            add_trial_button = uicontrol(self.f_, 'Style', 'pushbutton','String','Add Trial','units', ...
            'pixels','Position', [positions.block(1) + positions.block(3), ...
                positions.block(2) + 20, 75, 20], 'Callback',@self.add_trial);

            delete_trial_button = uicontrol(self.f_, 'Style', 'pushbutton', 'String', 'Delete Trial', ...
                'units', 'pixels', 'Position', [positions.block(1) + positions.block(3), positions.block(2), ...
            75, 20], 'Callback', @self.delete_trial);

            self.isSelect_all_box_ = uicontrol(self.f_, 'Style', 'checkbox', 'String', 'Select All', 'Value', self.isSelect_all_, 'units', ...
                'pixels','FontSize', font_size_, 'Position', [positions.block(1) + positions.block(3) - 45, ... 
                positions.block(2) + positions.block(4) + 2, 78, 22], 'Callback', @self.select_all);

            invert_selection = uicontrol(self.f_, 'Style', 'pushbutton', 'String', 'Invert Selection', ...
                 'units', 'pixels', 'Position', [positions.block(1) + positions.block(3), ...
                positions.block(2) - 20, 75, 20], 'Callback', @self.invert_selection);

            up_button = uicontrol(self.f_, 'Style', 'pushbutton', 'String', 'Shift up', 'units', ...
                'pixels', 'Position', [positions.block(1) + positions.block(3), positions.block(2) + .65*positions.block(4), ...
                75, 20], 'Callback', @self.move_trial_up);

            down_button = uicontrol(self.f_, 'Style', 'pushbutton', 'String', 'Shift down', 'units', ...
                'pixels', 'Position', [positions.block(1) + positions.block(3), positions.block(2) + .35*positions.block(4), ...
                75, 20], 'Callback', @self.move_trial_down);
            
            autofill_button = uicontrol(self.f_, 'Style', 'pushbutton', 'String', 'Auto-Fill', ...
                'FontSize', 14, 'units', 'pixels', 'Position', [pos_panel_(1), pos_panel_(2) - 50, 100, 50], ...
                'Callback', @self.autofill);


            self.preview_panel = uipanel(self.f_, 'Title', 'Preview', 'FontSize', font_size_, 'units', 'pixels', ...
                'Position', pos_panel_);

            %code to make the above panel transparent, so the preview image
            %can be seen.
            jPanel = self.preview_panel.JavaFrame.getPrintableComponent;
            jPanel.setOpaque(false)
            jPanel.getParent.setOpaque(false)
            jPanel.getComponent(0).setOpaque(false)
            jPanel.repaint

            preview_button = uicontrol(self.f_, 'Style', 'pushbutton', 'String', 'Preview', 'Fontsize', ...
                font_size_, 'units', 'pixels', 'Position', [pos_panel_(1) + pos_panel_(3) + 2, ...
                pos_panel_(2), 75, 40], 'Callback', @self.full_preview);

            play_button = uicontrol(self.f_, 'Style', 'pushbutton', 'String', 'Play', 'FontSize', ...
                font_size_, 'units', 'pixels', 'Position', [pos_panel_(1) + .5*pos_panel_(3) - 120, ...
                pos_panel_(2) - 35, 75, 20], 'Callback', @self.preview_play);

            pause_button = uicontrol(self.f_, 'Style', 'pushbutton', 'String', 'Pause', 'FontSize', ...
                font_size_, 'units', 'pixels', 'Position', [pos_panel_(1) + .5*pos_panel_(3) - 35, ...
                pos_panel_(2) - 35, 75, 20], 'Callback', @self.preview_pause);

            stop_button = uicontrol(self.f_, 'Style', 'pushbutton', 'String', 'Stop', 'FontSize', ...
                font_size_, 'units', 'pixels', 'Position', [pos_panel_(1) + .5*pos_panel_(3) + 50, ...
                pos_panel_(2) - 35, 75, 20], 'Callback', @self.preview_stop);

            frameBack_button = uicontrol(self.f_, 'Style', 'pushbutton', 'String', 'Back Frame', 'FontSize', ...
                font_size_, 'units', 'pixels', 'Position', [pos_panel_(1) + .5*pos_panel_(3) - 205, ...
                pos_panel_(2) - 35, 75, 20], 'Callback', @self.frame_back);

            frameForward_button = uicontrol(self.f_, 'Style', 'pushbutton', 'String', 'Forward Frame', ...
                'FontSize', font_size_, 'units', 'pixels', 'Position', [pos_panel_(1) + .5*pos_panel_(3) ...
                + 135, pos_panel_(2) - 35, 90, 20], 'Callback', @self.frame_forward);

            self.hAxes_ = axes(self.f_, 'units', 'pixels', 'OuterPosition', [200, 125, 1280 ,427], 'XLim', [0 200], 'YLim', [0 65]);
            
            self.exp_name_box_ = uicontrol(self.f_, 'Style', 'edit', 'String', self.model_.experiment_name_, ...
                'FontSize', 14, 'units', 'pixels', 'Position', ...
                [pos_panel_(1)+ (pos_panel_(3)/2) - 200, pos_panel_(2) - 100, 400, 30], 'Callback', @self.update_experiment_name);
            
            exp_name_label = uicontrol(self.f_, 'Style', 'text', 'String', 'Experiment Name: ', ...
                'FontSize', 16, 'units', 'pixels', 'Position', [pos_panel_(1) + (pos_panel_(3)/2) - 375, ...
                pos_panel_(2) - 100, 150, 30]);


       %Drop down menu and associated labels and buttons

            menu = uimenu(self.f_, 'Text', 'File');
            menu_import = uimenu(menu, 'Text', 'Import', 'Callback', @self.imp_folder);
            menu_open = uimenu(menu, 'Text', 'Open', 'Callback', @self.open_file);
            menu_saveas = uimenu(menu, 'Text', 'Save as', 'Callback', @self.saveas);
            menu_save = uimenu(menu, 'Text', 'Save', 'Callback', @self.save);
            menu_copy = uimenu(menu, 'Text', 'Copy to...', 'Callback', @self.copy_to);
            menu_set = uimenu(menu, 'Text', 'Set Selected...', 'Callback', @self.set_selected);

       %Randomization
       
            self.bg_ = uibuttongroup(self.f_, 'units', 'pixels', 'Position', [15, positions.block(2) + positions.block(4) - 10, 130, 55], 'SelectionChangedFcn', @self.update_randomize);
       
       
            self.isRandomized_radio_ = uicontrol(self.bg_, 'Style', 'radiobutton', 'String', 'Randomize Trials', 'FontSize', font_size_, ...
                'units', 'pixels', 'Position', [1, 29, 130, 20]);
            
            self.isSequential_radio_ = uicontrol(self.bg_, 'Style', 'radiobutton', 'String', 'Sequential Trials', 'FontSize', font_size_, ...
                'units', 'pixels', 'Position', [1,7, 130, 20]);

       %Repetitions

            self.repetitions_box_ = uicontrol(self.f_, 'Style', 'edit', 'units', 'pixels', 'Position', ...
                [90, positions.block(2) + positions.block(4) - 45, 40, 20], 'Callback', @self.update_repetitions);

            repetitions_label_ = uicontrol(self.f_, 'Style', 'text', 'String', 'Repetitions:', 'FontSize', font_size_, ...
                'units', 'pixels', 'Position', [15, positions.block(2) + positions.block(4) - 45, 70, 20]);

       %Dry Run
            dry_run_ = uicontrol(self.f_, 'Style', 'pushbutton', 'String', 'Dry Run', 'FontSize', font_size_, 'units', 'pixels', 'Position', ...
                [pos_panel_(1) + pos_panel_(3) + 2, pos_panel_(2) - 40, 75, 40],'Callback',@self.dry_run);

       %Actual run button

            run_button =  uicontrol(self.f_, 'Style', 'pushbutton', 'String', 'Run Trials', 'FontSize', font_size_, 'units', 'pixels', 'Position', ...
                 [15, positions.block(2) + positions.block(4) - 110, 90, 50], 'Callback', @self.open_run_gui);

       %Channels to acquire

            chan_pan = uipanel(self.f_, 'Title', 'Acquire Channels:', 'FontSize', font_size_, 'units', 'pixels', ...
                'Position', [15, positions.block(2) + positions.block(4) - 240, 250, 120]);

            self.chan1_ = uicontrol(self.f_, 'Style', 'checkbox', 'String', 'Channel 1', 'Value', self.model_.is_chan1_, 'FontSize', font_size_, ...
                'units', 'pixels', 'Position', [20, positions.block(2) + positions.block(4) - 160, 80, 20], 'Callback', @self.update_chan1);

            self.chan1_rate_box_ = uicontrol(self.f_, 'Style', 'edit', 'String', num2str(self.model_.chan1_rate_), 'units', 'pixels', 'Position', ...
                [105, positions.block(2) + positions.block(4) - 160, 40, 20], 'Callback', @self.update_chan1_rate);

            chan1_rate_label = uicontrol(self.f_, 'Style', 'text', 'String', 'Sample Rate', 'FontSize', font_size_, ...
                'units', 'pixels', 'Position', [155, positions.block(2) + positions.block(4) - 160, 85, 20]);

            self.chan2_ = uicontrol(self.f_, 'Style', 'checkbox', 'String', 'Channel 2', 'Value', self.model_.is_chan2_, 'FontSize', font_size_, ...
                'units', 'pixels', 'Position', [20, positions.block(2) + positions.block(4) - 180, 80, 20], 'Callback', @self.update_chan2);

            self.chan2_rate_box_ = uicontrol(self.f_, 'Style', 'edit', 'String', num2str(self.model_.chan2_rate_), 'units', 'pixels', 'Position', ...
                [105, positions.block(2) + positions.block(4) - 180, 40, 20], 'Callback', @self.update_chan2_rate);

            chan2_rate_label = uicontrol(self.f_, 'Style', 'text', 'String', 'Sample Rate', 'FontSize', font_size_, ...
                'units', 'pixels', 'Position', [155, positions.block(2) + positions.block(4) - 180, 85, 20]);

            self.chan3_ = uicontrol(self.f_, 'Style', 'checkbox', 'String', 'Channel 3', 'Value', self.model_.is_chan3_, 'FontSize', font_size_, ...
                'units', 'pixels', 'Position', [20, positions.block(2) + positions.block(4) - 200, 80, 20], 'Callback', @self.update_chan3);

            self.chan3_rate_box_ = uicontrol(self.f_, 'Style', 'edit', 'String', num2str(self.model_.chan3_rate_), 'units', 'pixels', 'Position', ...
                [105, positions.block(2) + positions.block(4) - 200, 40, 20], 'Callback', @self.update_chan3_rate);

            chan3_rate_label = uicontrol(self.f_, 'Style', 'text', 'String', 'Sample Rate', 'FontSize', font_size_, ...
                'units', 'pixels', 'Position', [155, positions.block(2) + positions.block(4) - 200, 85, 20]);

            self.chan4_ = uicontrol(self.f_, 'Style', 'checkbox', 'String', 'Channel 4', 'Value', self.model_.is_chan4_, 'FontSize', font_size_, ...
                'units', 'pixels', 'Position', [20, positions.block(2) + positions.block(4) - 220, 80, 20], 'Callback', @self.update_chan4);

            self.chan4_rate_box_ = uicontrol(self.f_, 'Style', 'edit', 'String', num2str(self.model_.chan4_rate_), 'units', 'pixels', 'Position', ...
                [105, positions.block(2) + positions.block(4) - 220, 40, 20], 'Callback', @self.update_chan4_rate);

            chan4_rate_label = uicontrol(self.f_, 'Style', 'text', 'String', 'Sample Rate', 'FontSize', font_size_, ...
                'units', 'pixels', 'Position', [155, positions.block(2) + positions.block(4) - 220, 85, 20]);

            self.bg2_ = uibuttongroup(self.f_, 'units', 'pixels', 'Position', [15, positions.block(2) + positions.block(4) - 270, 250, 25], 'SelectionChangedFcn', @self.update_rowNum);
       
       
            self.num_rows_3_ = uicontrol(self.bg2_, 'Style', 'radiobutton', 'String', '3 Row Screen', 'FontSize', font_size_, ...
                'units', 'pixels', 'Position', [1, 3, 120, 19]);
            
            self.num_rows_4_ = uicontrol(self.bg2_, 'Style', 'radiobutton', 'String', '4 Row Screen', 'FontSize', font_size_, ...
                'units', 'pixels', 'Position', [121,3, 120, 19]);

        end
        
%UPDATE THE GUI VALUES FROM UPDATED MODEL DATA-----------------------------

        function update_gui(self)


            self.set_pretrial_table_data();
            self.set_intertrial_table_data();
            self.set_block_table_data();
            self.set_posttrial_table_data();
            self.set_bg_selection();
            self.set_repetitions_box_val();
            self.set_isSelect_all_box_val();
            self.set_chan1_val();
            self.set_chan2_val();
            self.set_chan3_val();
            self.set_chan4_val();
            self.set_chan1_rate_box_val();
            self.set_chan2_rate_box_val();
            self.set_chan3_rate_box_val();
            self.set_chan4_rate_box_val();
            self.set_bg2_selection();
            self.set_exp_name();
            


        end
        
%         function update_gui_block(self, x, y)
%             
%             self.set_block_table_data_xy(x, y);
%             
%         end
     
%UPDATE MODEL DATA FROM USER INPUT-----------------------------------------

%Update pretrial model data

        function update_model_pretrial(self, src, event)

            mode = self.model_.pretrial_{1};
            new = event.EditData;
            x = event.Indices(1);
            y = event.Indices(2);
            allow = self.check_editable(mode, y);
            %within_bounds = self.check_constraints(y, new); %Doesn't work
            %yet

            if allow == 1 %&& within_bounds == 1
                if y >= 2 && y <= 7

                    self.set_pretrial_files_(y, new);
                    self.model_.set_pretrial_property(y,new);
                elseif y ~= 13

                    self.model_.set_pretrial_property(y, str2num(new));

                else
                    self.model_.set_pretrial_property(y,new);
                end



    %             elseif within_bounds == 0
    %                 
    %                 waitfor(errordlg("The value you provided is out of bounds."));
    %                 self.layout_gui();

            else

                waitfor(errordlg("You cannot edit that field in this mode."));
                %self.layout_gui();


            end
            if y == 1
               
               self.clear_fields(str2num(new));
                
            end
            
             self.update_gui();
             %disp(self.pre_files_);

        end
        
%Update block trials model data        
        
        function update_model_block_trials(self, src, event)
            
            new = event.EditData;
            x = event.Indices(1);
            y = event.Indices(2);
            mode = cell2mat(self.model_.block_trials_(x, 1));
            allow = self.check_editable(mode, y);
            
            
            if allow == 1
                if y >= 2 && y <= 7
     
                    self.set_blocktrial_files_(x, y, new);
                    self.model_.set_block_trial_property([x,y], new);
                    %src.Data{x,y} = new;
                elseif y ~= 13
                    self.model_.set_block_trial_property([x,y], str2num(new));
                else
                    self.model_.set_block_trial_property([x,y], new);
                end
                %self.model_.block_trials_
            else
                
                waitfor(errordlg("You cannot edit that field in this mode."));

            end
            
            if y == 1
                
                self.clear_fields(str2num(new));
            
            end
            

            self.update_gui();
            %disp(self.block_files_);
            
        end
        
%Update intertrial model data        
        
        function update_model_intertrial(self, src, event)
            
            new = event.EditData;
            x = event.Indices(1);
            y = event.Indices(2);
            mode = cell2mat(self.model_.intertrial_(x, 1));
            allow = self.check_editable(mode, y);
            
            if allow == 1
                
                if y >= 2 && y <= 7
          
                    self.set_intertrial_files_(y,new);
                    self.model_.set_intertrial_property(y, new);
                elseif y~=13
                    self.model_.set_intertrial_property(y, str2num(new));
                %self.model_.intertrial_;
                else
                    self.model_.set_intertrial_property(y, new);
                end
            else
                
                waitfor(errordlg("You cannot edit that field in this mode."));
                %self.layout_gui();
            end
            
            if y == 1
               
                self.clear_fields(str2num(new));
                
            end
            self.update_gui();
            %disp(self.inter_files_);
        end
        
%Update posttrial model data

        function update_model_posttrial(self, src, event)
            new = event.EditData;
            x = event.Indices(1);
            y = event.Indices(2);
            mode = cell2mat(self.model_.posttrial_(x, 1));
            allow = self.check_editable(mode, y);
            
            if allow == 1
                
                if y >= 2 && y <= 7
          
                    self.set_posttrial_files_(y,new);
                    self.model_.set_posttrial_property(y, new);
                elseif y~=13
                    self.model_.set_posttrial_property(y, str2num(new));
                %self.model_.intertrial_;
                else
                    self.model_.set_posttrial_property(y, new);
                end

            else
                
                waitfor(errordlg("You cannot edit that field in this mode."));
                %self.layout_gui();
            end
            if y == 1
               
                self.clear_fields(str2num(new));
                
            end
            self.update_gui();
            %disp(self.post_files_);
        
        end
        
%Update repetitions        
        
        function update_repetitions(self, src, event)
        
            new = str2num(src.String);
            self.model_.set_repetitions(new);
            self.update_gui();
            %self.model_.repetitions_
        
        end

%Update Randomization

        function update_randomize(self, src, event)
            
            new = event.NewValue.String;
            if strcmp(new, 'Randomize Trials') == 1
                new_val = 1;
            else
                new_val = 0;
            end
            self.model_.set_is_randomized(new_val);
            self.update_gui();
            %self.model_.is_randomized_
            
        end
        
%Update channels being acquired (each separately)
        
        function update_chan1(self, src, event)
            
            new = src.Value;
            self.model_.set_is_chan1(new);
            self.update_gui();
            %self.model_.is_chan1_
        
        end
        
        function update_chan2(self, src, event)

            new = src.Value;
            self.model_.set_is_chan2(new);
            self.update_gui();
            %self.model_.is_chan2_

        end
        
        function update_chan3(self, src, event)

            new = src.Value;
            self.model_.set_is_chan3(new);
            self.update_gui();
            %self.model_.is_chan3_

        end
        
        function update_chan4(self, src, event)

            new = src.Value;
            self.model_.set_is_chan4(new);
            self.update_gui();
            %self.model_.is_chan4_
        
        end
 
%Update the frame rates of channels being collected        
        
        function update_chan1_rate(self, src, event)
            
            new = str2num(src.String);
            self.model_.set_chan1_rate(new);
            self.model_.set_config_data(new, 1);
            self.update_config_file();
            self.update_gui();
            %self.model_.chan1_rate_
            
        end
        
        function update_chan2_rate(self, src, event)
            
            new = str2num(src.String);
            if new ~= 1000 && new ~= 500
                waitfor(errordlg("You have entered a value other than 500 or 1000. Please double check your entry."));
            end
            self.model_.set_config_data(new,2);
            self.model_.set_chan2_rate(new);
            self.update_config_file();
            self.update_gui();
            %self.model_.chan2_rate_
            
        end
        
        function update_chan3_rate(self, src, event)
            
            new = str2num(src.String);
            if new ~= 1000 && new ~= 500
                waitfor(errordlg("You have entered a value other than 500 or 1000. Please double check your entry."));
            end
            self.model_.set_chan3_rate(new);
            self.model_.set_config_data(new, 3);
            self.update_config_file();
            self.update_gui();
            %self.model_.chan3_rate_
            
        end
        
        function update_chan4_rate(self, src, event)
            
            new = str2num(src.String);
            if new ~= 1000 && new ~= 500
                waitfor(errordlg("You have entered a value other than 500 or 1000. Please double check your entry."));
            end
            self.model_.set_chan4_rate(new);
            self.model_.set_config_data(new, 4);
            self.update_config_file();
            self.update_gui();
            %self.model_.chan4_rate_
            
        end
        
        function update_doc(self, new_value)
            
            self.model_.set_doc(new_value);
        end
        
        function update_preview_con(self, new_value)
            self.preview_con_ = new_value;
        end
        
        function update_rowNum(self, src, event)
            new = event.NewValue.String;
            if strcmp(new, '3 Row Screen') == 1
                new_val = 3;
            else
                new_val = 4;
            end
            %Check to make sure the number in the config file now matches
            %this new value
                
            self.model_.set_num_rows(new_val);%do this for other config updating
            self.model_.set_config_data(new_val, 0);
            self.update_config_file();
            self.set_bg2_selection();

%            self.update_gui();
        end
        
        function update_experiment_name(self, src, event)
            
            new_val = src.String;
            self.model_.set_experiment_name(new_val);
            self.update_gui();
        end
       
        
        function update_config_file(self)
            %open config file
            %change appropriate rate
            %save and close config file
            configData = self.model_.get_config_data();

            settings_data = strtrim(regexp( fileread('G4_Protocol_Designer_Settings.m'),'\n','split'));
            filepath_line = find(contains(settings_data,'Configuration File Path:'));
            exp = 'Path:';
            startIndex = regexp(settings_data{filepath_line},exp);
            start_filepath_index = startIndex + 6;
            config_filepath = settings_data{filepath_line}(start_filepath_index:end);
            fid = fopen(config_filepath,'w');
            fprintf(fid, '%s\n', configData{:});
            fclose(fid);
            
        end
        
     
        
%ADD ROW AND UPDATE MODEL DATA---------------------------------------------

        function add_trial(self, src, event)

            checkbox_column_data = horzcat(self.model_.block_trials_(1:end, end));
            checked_list = find(cell2mat(checkbox_column_data));
            checked_count = length(checked_list);
            x = size(self.model_.block_trials_,1) + 1;
            
          
            if checked_count == 0
                newRow = self.model_.block_trials_(end,1:end);
                y = 1;
                self.model_.set_block_trial_property([x,y],newRow);
            elseif checked_count == 1
                newRow = self.model_.block_trials_(checked_list(1),1:end-1);
                newRow{:,end+1} = false;
                %disp(newRow);
                y = 1;
                self.model_.set_block_trial_property([x,y], newRow);
                
                
            else 
                waitfor(errordlg("you can only have one row checked for this functionality"));
                      
                  
                
            end    
            self.block_files_.pattern(end + 1) = string(cell2mat(newRow(2)));
            self.block_files_.position(end + 1) = string(cell2mat(newRow(3)));
            self.block_files_.ao1(end + 1) = string(cell2mat(newRow(4)));
            self.block_files_.ao2(end + 1) = string(cell2mat(newRow(5)));
            self.block_files_.ao3(end + 1) = string(cell2mat(newRow(6)));
            self.block_files_.ao4(end + 1) = string(cell2mat(newRow(7)));
            
%             for i = 1:13
%                 
%                 self.update_gui_block(x, i)
%                 
%             end

            self.update_gui();
            
            
        
        end

%DELETE ROW AND UPDATE MODEL DATA------------------------------------------

        function delete_trial(self, src, event)
        
            checkbox_column_data = horzcat(self.model_.block_trials_(1:end, end));
            checked_list = find(cell2mat(checkbox_column_data));
            checked_count = length(checked_list);
            %disp(checked_list);
            
            if checked_count == 0
                waitfor(errordlg("You didn't select a trial to delete."));
            else
                
                for i = 1:checked_count
%                     for j = 1:13
%                          new = [];
%                
%                          x = checked_list(i) - (i - 1);
%                          self.model_.set_block_trial_property( ,new);
%                          self.model_.block_trials
%                     
                        self.model_.block_trials_(checked_list(i) - (i-1),:) = [];
                        %disp(self.model_.block_trials_);
%                     end
                
                end
                
            end
            
            self.update_gui();
                
        
        end
        
        
%MOVE TRIAL UP AND UPDATE MODEL DATA---------------------------------------

        function move_trial_up(self, src, event)
        
            checkbox_column_data = horzcat(self.model_.block_trials_(1:end, end));
            checked = find(cell2mat(checkbox_column_data));
            checked_count = length(checked);
            
            if checked_count == 0
                waitfor(errordlg("Please select a trial to shift upward."));
            elseif checked_count > 1
                waitfor(errordlg("Please select only one trial to shift upward."));
            else 
            
                selected = self.model_.block_trials_(checked, :);
                if checked == 1
                    waitfor(errordlg("I can't shift up any more."));
                    return;
                else
                    above_selected = self.model_.block_trials_(checked - 1, :);
                end
 
               
                self.model_.block_trials_(checked , :) = above_selected;
                self.model_.block_trials_(checked - 1, :) = selected;

                
            end
            
%             for i = 1:13
%                 self.update_gui_block(checked, i);
%                 self.update_gui_block(checked - 1, i);
%             end
              self.update_gui();
            
      
        end
        
        
%MOVE TRIAL DOWN AND UPDATE MODEL DATA-------------------------------------

        function move_trial_down(self, src, event)

            
            checkbox_column_data = horzcat(self.model_.block_trials_(1:end, end));
            checked = find(cell2mat(checkbox_column_data));
            checked_count = length(checked);
            
            if checked_count == 0
                waitfor(errordlg("Please select a trial to shift downward"));
            elseif checked_count > 1
                waitfor(errordlg("Please select only one trial to shift downward"));
            else 
                
                selected = self.model_.block_trials_(checked, :);
                
                if checked == length(self.model_.block_trials_(:,1))
                    waitfor(errordlg("I can't shift down any further."));
                    return;
                else
                    below_selected = self.model_.block_trials_(checked + 1, :);
                end
                    

                
                self.model_.block_trials_(checked, :) = below_selected;
                self.model_.block_trials_(checked + 1, :) = selected;

                
            end
%             
%             for i = 1:13
%                 self.update_gui_block(checked, i);
%                 self.update_gui_block(checked + 1, i);
%             end
            self.update_gui();
                
        end
        
%Autopopulate button, to be pressed after importing.
    function autofill(self, src, event)
        
        pat_index = 1; %Keeps track of the indices of patterns that are actually displayed (not cut due to screen size discrepancy)
        pat_indices = []; %A record of all pattern indices that match the screen size.
        
        doc = self.model_.doc_;
        pat_names = fieldnames(doc.Patterns_);
        pos_names = fieldnames(doc.Pos_funcs_);
        ao_names = fieldnames(doc.Ao_funcs_);
        
        num_pats = length(pat_names);
        num_pos = length(pos_names);
        num_ao = length(ao_names);

        pat1 = pat_names{pat_index};
        
        if length(doc.Patterns_.(pat1).pattern.Pats(:,1,1))/16 ~= self.model_.num_rows_
            while length(doc.Patterns_.(pat1).pattern.Pats(:,1,1)) ~= self.model_.num_rows_ && pat_index < length(pat_names)
                pat_index = pat_index + 1;
                pat1 = cell2mat(pat_names(pat_index));
            end
            
        end
        
        if pat_index == length(pat_names) && length(doc.Patterns_.(pat1).pattern.Pats(:,1,1))/16 ~= self.model_.num_rows_
            waitfor(errordlg("None of the patterns imported match the screen size selected. Please import a different folder or select a new screen size"));
            return;
        end
        
        pat_indices(1) = pat_index;
        if pat_index <= num_pos
            pos_index = pat_index;
        else 
            pos_index = 1;
        end
        if pat_index <= num_ao
            ao_index = pat_index;
        else
            ao_index = 1;
        end
        
        pos1 = cell2mat(pos_names(pos_index)); %Set initial position and ao functions to correspond to initial pattern.
        ao1 = cell2mat(ao_names(ao_index));
        
        
        
        if length(doc.Patterns_.(pat1).pattern.Pats(1,1,:)) ~= ...
                doc.Pos_funcs_.(pos1).pfnparam.frames
            pos1 = '';
        end
        

        
        self.model_.set_pretrial_property(2, pat1);
        self.model_.set_pretrial_property(3, pos1);
        self.model_.set_pretrial_property(4, ao1);
        
        self.model_.set_intertrial_property(2, pat1);
        self.model_.set_intertrial_property(3, pos1);
        self.model_.set_intertrial_property(4, ao1);
        
        self.model_.set_posttrial_property(2, pat1);
        self.model_.set_posttrial_property(3, pos1);
        self.model_.set_posttrial_property(4, ao1);
        
        self.model_.set_block_trial_property([1,2], pat1);
        self.model_.set_block_trial_property([1,3], pos1);
        self.model_.set_block_trial_property([1,4], ao1);
        
       
        
        j = 1; %will end up as the count of how many patterns are used. Acts as the indices to "pat_indices"
        pat_index = pat_index + 1;
        pos_index = pos_index + 1;
        ao_index = ao_index + 1;
        
        if pat_index < num_pats
        
            for i = pat_index:num_pats
                
                pat = pat_names{pat_index};
                if pos_index > num_pos %Make sure indices are in range 
                    pos_index = 1;
                end
                if ao_index > num_ao
                    ao_index = 1;
                end
                pos = pos_names{pos_index};
                ao = ao_names{ao_index};
                
                if length(doc.Patterns_.(pat).pattern.Pats(:,1,1))/16 ~= self.model_.num_rows_
                    pat_index = pat_index + 1;
                    pos_index = pos_index + 1;
                    ao_index = ao_index + 1;
                    
                    continue;
                end
                
                newrow = self.model_.block_trials_(end, 1:end);
                newrow{2} = cell2mat(pat_names(pat_index)); %Only executes if previous if statement did not. Sets new row's pattern

                newrow{3} = pos; 

                newrow{4} = ao; 
                pat_indices(j) = pat_index;
                j = j + 1;
                pat_index = pat_index + 1;
                pos_index = pos_index + 1;
                ao_index = ao_index + 1;
                
                if length(doc.Patterns_.(newrow{2}).pattern.Pats(1,1,:)) ~= ...
                        doc.Pos_funcs_.(newrow{3}).pfnparam.frames
                    newrow{3} = '';
                end

                self.model_.set_block_trial_property([j,1],newrow);
                self.block_files_.pattern(end + 1) = string(cell2mat(newrow(2)));
                self.block_files_.position(end + 1) = string(cell2mat(newrow(3)));
 

            end
            
        end

        
        self.update_gui();


    end

        
%MAIN MENU CALLBACK FUNCTIONS----------------------------------------------

%Import
    function imp_folder(self, src, event)
       
       answer = questdlg('Would you like to import an Experiment folder or a file?',...
           'Import', 'Folder', 'File', 'Cancel', 'Folder');
       
       switch answer
           case 'Folder'
                top_folder_path = uigetdir;
                if isequal (top_folder_path,0)
                    %do nothing
                else
                    imported_folder = document(top_folder_path);
                    self.update_doc(imported_folder);
                    [exp_path, exp_name] = fileparts(self.model_.doc_.top_folder_path_);
                    self.model_.set_experiment_name(exp_name);
                    self.update_gui();
                    set(self.num_rows_3_, 'Enable', 'off');
                    set(self.num_rows_4_, 'Enable', 'off');
                end
           case 'File'
               self.imp_file();
           case 'Cancel'
               %do nothing
       end
       


    end
    
    function imp_file(self)
    
        if isempty(self.model_.doc_) == 1
            waitfor(errordlg("You must import an Experiment folder first."));
        else
            [imported_file, path] = uigetfile;
            
            if isequal(imported_file,0)
                %do nothing
            else
                self.model_.doc_.import_file(imported_file, path);
            end
        end
        
        
       
    
    end
    
    

%Save As

    function saveas(self, src, event)

        [file, path] = uiputfile('*.mat','File Selection', self.model_.experiment_name_);
        full_path = fullfile(path, file);
        
        if file == 0
            return;
        end
        
    %get values of interest from model and store them in struct to save to mat file.
        vars.block_trials = self.model_.get_block_trials();
        vars.pretrial = self.model_.get_pretrial();
        vars.intertrial = self.model_.get_intertrial();
        vars.posttrial = self.model_.get_posttrial();
        vars.is_randomized = self.model_.get_is_randomized();
        vars.repetitions = self.model_.get_repetitions();
        vars.is_chan1 = self.model_.get_is_chan1();
        vars.is_chan2 = self.model_.get_is_chan2();
        vars.is_chan3 = self.model_.get_is_chan3();
        vars.is_chan4 = self.model_.get_is_chan4();
        vars.chan1_rate = self.model_.get_chan1_rate();
        vars.chan2_rate = self.model_.get_chan2_rate();
        vars.chan3_rate = self.model_.get_chan3_rate();
        vars.chan4_rate = self.model_.get_chan4_rate();
        vars.num_rows = self.model_.get_num_rows();
        vars.experiment_name = self.model_.get_experiment_name();
        
        
        
        self.model_.doc_.saveas(full_path, vars);
        

    end
    
%Save

    function save(self, src, event)
    %Controller gets up to data data from the model, then sends to the
    %document to save the file.
        
    %Get up to date variables from the model.
        vars.block_trials = self.model_.get_block_trials();
        vars.pretrial = self.model_.get_pretrial();
        vars.intertrial = self.model_.get_intertrial();
        vars.posttrial = self.model_.get_posttrial();
        vars.is_randomized = self.model_.get_is_randomized();
        vars.repetitions = self.model_.get_repetitions();
        vars.is_chan1 = self.model_.get_is_chan1();
        vars.is_chan2 = self.model_.get_is_chan2();
        vars.is_chan3 = self.model_.get_is_chan3;
        vars.is_chan4 = self.model_.get_is_chan4;
        vars.chan1_rate = self.model_.get_chan1_rate;
        vars.chan2_rate = self.model_.get_chan2_rate;
        vars.chan3_rate = self.model_.get_chan3_rate;
        vars.chan4_rate = self.model_.get_chan4_rate;
        vars.num_rows = self.model_.get_num_rows();
        vars.experiment_name = self.model_.get_experiment_name();
        
        self.model_.doc_.save(vars);

    end

%Open

    function open_file(self, src, event)
        %document open function opens the file, saves the data, and sends
        %data back to controller. 

        %controller then sends updated data to model and updates gui.
        
        %check if there is a doc_ - if not, import the parent folder of the
        %.g4p file.
        
        [filename, top_folder_path] = uigetfile('*.g4p');
        filepath = fullfile(top_folder_path, filename);
       
        if isequal (top_folder_path,0)
            
            %do nothing
        else
        
            if isempty(self.model_.doc_)

                    imported_folder = document(top_folder_path);
                    self.update_doc(imported_folder);
                    [exp_path, exp_name, ext] = fileparts(filepath);
                   % [exp_path, exp_name] = fileparts(self.model_.doc_.top_folder_path_);
                    self.model_.set_experiment_name(exp_name);
                    
                    self.update_gui();
                    
             end
            

            data = self.model_.doc_.open(filepath);
            m = self.model_;
            d = data.exp_parameters;
            
            %Set parameters outside tables
            
            m.set_repetitions(d.repetitions);
            m.set_is_randomized(d.is_randomized);
            m.set_is_chan1(d.is_chan1);
            m.set_is_chan2(d.is_chan2);
            m.set_is_chan3(d.is_chan3);
            m.set_is_chan4(d.is_chan4);
            m.set_chan1_rate(d.chan1_rate);
            m.set_config_data(d.chan1_rate, 1);
            m.set_chan2_rate(d.chan2_rate);
            m.set_config_data(d.chan2_rate, 2);
            m.set_chan3_rate(d.chan3_rate);
            m.set_config_data(d.chan3_rate, 3);
            m.set_chan4_rate(d.chan4_rate);
            m.set_config_data(d.chan4_rate, 4);
            m.set_num_rows(d.num_rows);
            m.set_config_data(d.num_rows, 0);
            self.update_config_file();

            
            for k = 1:13

                m.set_pretrial_property(k, cell2mat(d.pretrial(k)));
                m.set_intertrial_property(k, cell2mat(d.intertrial(k)));
                m.set_posttrial_property(k, cell2mat(d.posttrial(k)));

            end

            for i = 2:length(m.block_trials_(:, 1))
                m.block_trials_((i-(i-2)),:) = [];
            end
            block_x = length(d.block_trials(:,1));
            block_y = 1;

            for j = 1:block_x
                if j > length(m.block_trials_(:,1))
                    newrow = d.block_trials(j,1:end);
                    m.set_block_trial_property([j, block_y], newrow);
                else
                    for n = 1:13
                        m.set_block_trial_property([j, n], cell2mat(d.block_trials(j,n)));
                    end
                end

            end



            
            self.update_gui();
            set(self.num_rows_3_, 'Enable', 'off');
            set(self.num_rows_4_, 'Enable', 'off');
        end
    end
    
 
        
%Copy to        
        function copy_to(self, src, event)
        
            checkbox_column_data = horzcat(self.model_.block_trials_(1:end, end));
            checked = find(cell2mat(checkbox_column_data));
            checked_count = length(checked);
            
            if checked_count == 0
            
                disp("You must select a trial to copy over");
            
            elseif checked_count == 1
                
                selected = self.model_.block_trials_(checked,1:end-1);
                selected{:,end+1} = false;
                list = {'Pre-Trial', 'Inter-Trial', 'Post-Trial'};
                
                [indx,tf] = listdlg('ListString', list, 'PromptString', 'Select all desired locations');
                
                if tf == 0
                    %do nothing
                    
                else
                    
                    for i = 1:length(indx)
                    
                        if indx(i) == 1
                           
                            self.model_.pretrial_ = selected;
                            
                        elseif indx(i) == 2
                            
                            self.model_.intertrial_ = selected;
                            
                        elseif indx(i) == 3
                            
                            self.model_.posttrial_ = selected;
                            
                        else
                            disp("There has been an error, please try again.");
                        end
                    
                    end
                    
                end
                
                self.update_gui();
                
            else
                disp("You can only select one trial for this functionality");
            end
            
        end
        
%Set selected values to new trials

        function set_selected(self, src, event)
            
        %Check if any rows in the block are checked, add indexes of any
        %checked ones into checked_block
            checkbox_block_data = horzcat(self.model_.block_trials_(1:end, end));
            checked_block = find(cell2mat(checkbox_block_data));
            checked_block_count = length(checked_block);
        
            prompt = {'Trial Mode:', 'Pattern Name:', 'Position Function:', ...
                'AO1:', 'AO2:', 'AO3:', 'AO4:', 'Frame Index:', 'Frame Rate:', ...
                'Gain:', 'Offset:', 'Duration:'};
            title = 'Trial Values';
            dims = [1 30];
            definput = {'1', 'default', 'default', '', '', '', '', '1', '60', ...
                '1', '0', '3'};
            answer = inputdlg(prompt, title, dims, definput);
            if length(answer) == 0
                return;
            end
            
            answer{1} = str2num(answer{1});
            answer{8} = str2num(answer{8});
            answer{9} = str2num(answer{9});
            answer{10} = str2num(answer{10});
            answer{11} = str2num(answer{11});
            answer{12} = str2num(answer{12});

            answer{end+1} = false;

            
            for i = 1:length(answer)
                adjusted_answer{1,i} = answer{i};
            end
            
            
            if self.model_.pretrial_{13} == true
                self.model_.pretrial_ = adjusted_answer;
            end

            if self.model_.intertrial_{13} == true
                self.model_.intertrial_ = adjusted_answer;
            end

            if self.model_.posttrial_{13} == true
                self.model_.posttrial_ = adjusted_answer;
            end

            if checked_block_count ~= 0
                for i = 1:checked_block_count
                    self.model_.block_trials_(checked_block(i),:) = adjusted_answer;
                end

            end
            
            self.update_gui();
            %disp(self.model_.block_trials_(2,13));
        end

%END OF MAIN MENU CALLBACKS------------------------------------------------

%SELECT ALL CALLBACK-------------------------------------------------------

      function select_all(self, src, event)
        %assuming here that the number parameters will never differ between
        %trials. 
        l = length(self.model_.block_trials_(1,:));
        if src.Value == false  
        %disp(length(self.model_.block_trials_(:,1)));
            for i = 1:length(self.model_.block_trials_(:,1))
                if cell2mat(self.model_.block_trials_(i, l)) == 1
                    self.model_.set_block_trial_property([i, l], false);
                end
            end
            
        else
            for i = 1:length(self.model_.block_trials_(:,1))
                if cell2mat(self.model_.block_trials_(i, l)) == 0
                    self.model_.set_block_trial_property([i, l], true);
                end
            end
            
        end
        self.isSelect_all_ = src.Value;
        self.update_gui();
        
      end
      
%INVERT SELECTION CALLBACK-------------------------------------------------

        function invert_selection(self, src, event)

            L = length(self.model_.block_trials_(:,1));
            len = length(self.model_.block_trials_(1,:));

            for i = 1:L
                if cell2mat(self.model_.block_trials_(i,len)) == 0
                    self.model_.set_block_trial_property([i, len], true);
                elseif cell2mat(self.model_.block_trials_(i,len)) == 1
                    self.model_.set_block_trial_property([i,len], false);
                else
                    disp('There has been an error, the selected value must be true or false');
                end
            end

            self.update_gui();

        end

%IN SCREEN PREVIEW OF SELECTED CELL----------------------------------------

        function preview_selection(self, src, event, positions)
            %disp(event.Indices);
            if isempty(event.Indices) == 0
                
                x = event.Indices(1);
                y = event.Indices(2);
                
                self.current_selected_cell_.index = event.Indices;
                self.auto_preview_index_ = 1; %A new file has been selected so preview starts over at frame 1
                
                if y > 1 && y< 8

                    file = string(src.Data(x, y));
                 
                else
                    
                    file = '';
                    
                end
                
               
                
                 if src.Position == positions.pre
                    self.current_selected_cell_.table = "pre";
                    mode = cell2mat(self.model_.pretrial_(1));
                elseif src.Position == positions.inter
                    self.current_selected_cell_.table = "inter";
                    mode = cell2mat(self.model_.intertrial_(1));
                elseif src.Position == positions.block
                    self.current_selected_cell_.table = "block";
                    x = self.current_selected_cell_.index(1);
                    mode = cell2mat(self.model_.block_trials_(x, 1));
                 elseif src.Position == positions.post
                    self.current_selected_cell_.table = "post";
                    mode = cell2mat(self.model_.posttrial_(1));
                else
                    waitfor(errordlg("Something has gone wrong, table positions have been corrupted."));
                 end

                
                
                %At this point if the cell is empty, open a list dialog
                %with all possible filenames for the index. After they
                %select one, file becomes that string. 
                
                if strcmp(file,'') == 1
                
                    if isempty(self.model_.doc_) == 1
                        waitfor(errordlg("Nothing has been imported."));
                    end
                    if event.Indices(2) == 2
                        
                        pats = self.model_.doc_.Patterns_;
                        fields = fieldnames(pats);
                        [index, chose] = listdlg('ListString',fields,'SelectionMode','single');

                        if chose == 1
                            
                            chosen_pat = fields{index};
                            if length(self.model_.doc_.Patterns_.(chosen_pat).pattern.Pats(:,1,1))/16 ~= self.model_.num_rows_
                                waitfor(errordlg("This pattern will not run on the currently selected screen size. Please try again."));
                                return;
                            end
                            file = cell2mat(fields(index));

                            if strcmp(self.current_selected_cell_.table, "pre") == 1

                                self.model_.set_pretrial_property(event.Indices(2), file);
                                self.update_gui();

                            elseif strcmp(self.current_selected_cell_.table, "inter") == 1

                                self.model_.set_intertrial_property(event.Indices(2), file);
                                self.update_gui();

                            elseif strcmp(self.current_selected_cell_.table, "block") == 1
                                self.model_.set_block_trial_property(event.Indices, file);
                                self.update_gui();

                            elseif strcmp(self.current_selected_cell_.table, "post") == 1

                                self.model_.set_posttrial_property(event.Indices(2), file);
                                self.update_gui();

                            else
                                waitfor(errordlg("Make sure you haven't changed your selection."));
                            end
                            file = string(file);
                        end
                        
                    elseif event.Indices(2) == 3
                        disp(mode);
                        edit = self.check_editable(mode, 3);
                        disp(edit);
                        if edit == 1
                            pos = self.model_.doc_.Pos_funcs_;
                            fields = fieldnames(pos);
                            [index, chose] = listdlg('ListString',fields,'SelectionMode','single');
                            if chose == 1
                                file = cell2mat(fields(index));

                                if strcmp(self.current_selected_cell_.table, "pre") == 1

                                    self.model_.set_pretrial_property(event.Indices(2), file);
                                    self.update_gui();

                                elseif strcmp(self.current_selected_cell_.table, "inter") == 1

                                    self.model_.set_intertrial_property(event.Indices(2), file);
                                    self.update_gui();

                                elseif strcmp(self.current_selected_cell_.table, "block") == 1

                                    self.model_.set_block_trial_property(event.Indices, file);
                                    self.update_gui();

                                elseif strcmp(self.current_selected_cell_.table, "post") == 1

                                    self.model_.set_posttrial_property(event.Indices(2), file);
                                    self.update_gui();

                                else
                                    waitfor(errordlg("Make sure you haven't changed your selection."));
                                end
                                file = string(file);
                            end
                        end
                    elseif event.Indices(2) > 3 && event.Indices(2) < 8

                        ao = self.model_.doc_.Ao_funcs_;
                        fields = fieldnames(ao);
                        [index, chose] = listdlg('ListString',fields,'SelectionMode','single');
                        if chose == 1
                            file = cell2mat(fields(index));

                            if strcmp(self.current_selected_cell_.table, "pre") == 1

                                self.model_.set_pretrial_property(event.Indices(2), file);
                                self.update_gui();

                            elseif strcmp(self.current_selected_cell_.table, "inter") == 1

                                self.model_.set_intertrial_property(event.Indices(2), file);
                                self.update_gui();

                            elseif strcmp(self.current_selected_cell_.table, "block") == 1

                                self.model_.set_block_trial_property(event.Indices, file);
                                self.update_gui();

                            elseif strcmp(self.current_selected_cell_.table, "post") == 1

                                self.model_.set_posttrial_property(event.Indices(2), file);
                                self.update_gui();

                            else
                                waitfor(errordlg("Make sure you haven't changed your selection."));
                            end
                            file = string(file);
                        end
                        %Pull list dialog for AO functions
                    end
                    
                    
                end
                

                %%%%%%%%%%%I REUSE THIS CODE A LOT - CONSIDER MAKING IT ITS OWN FUNCTION   

                if strcmp(file,'') == 0
                    if event.Indices(2) == 2
                        if isempty(self.model_.doc_) == 1
                            waitfor(errordlg("You haven't imported anything yet"));
                        end

                        self.current_preview_file_ = self.model_.doc_.Patterns_.(file).pattern.Pats;

                        x = [0 length(self.current_preview_file_(1,:,1))];
                        y = [0 length(self.current_preview_file_(:,1,1))];
                        adjusted_file = zeros(y(2),x(2),length(self.current_preview_file_(1,1,:)));
                        max_num = max(self.current_preview_file_,[],[1 2]);
                        for i = 1:length(self.current_preview_file_(1,1,:))
                            
                            adjusted_matrix = self.current_preview_file_(:,:,i) ./ max_num(i);
                            adjusted_file(:,:,i) = adjusted_matrix(:,:,1);
                        end



                        %for i = 1:30
                        im = imshow(adjusted_file(:,:,self.auto_preview_index_), 'Colormap',gray);
                        set(im, 'parent', self.hAxes_)
                        colormap( self.hAxes_, gray )
                        set(self.hAxes_, 'XLim', x, 'YLim', y);
                       % pause(1/fr_rate);







                    elseif event.Indices(2) == 3


                        self.current_preview_file_ = self.model_.doc_.Pos_funcs_.(file).pfnparam.func;

                        xax = [0 length(self.current_preview_file_(1,:))];
                        yax = [min(self.current_preview_file_) max(self.current_preview_file_)];
                        set(self.hAxes_, 'XLim', xax, 'YLim', yax);
                        p = plot(self.current_preview_file_);
                        set(p, 'parent', self.hAxes_);


                    elseif event.Indices(2) > 3 && event.Indices(2) < 7

                        self.current_preview_file_ = self.model_.doc_.Ao_funcs_.(file).afnparam.func;

                        xax = [0 length(self.current_preview_file_(1,:))];
                        yax = [min(self.current_preview_file_) max(self.current_preview_file_)];
                        set(self.hAxes_, 'XLim', xax, 'YLim', yax);
                        p = plot(self.current_preview_file_);
                        set(p, 'parent', self.hAxes_);

                    end
                
                end

                

            end

        end


%FORWARD ONE FRAME ON IN SCREEN PREVIEW------------------------------------

        function frame_forward(self, src, event)

            if strcmp(self.current_selected_cell_.table, "pre")
                filename = string(self.pretrial_table_.Data(self.current_selected_cell_.index(2)));
            elseif strcmp(self.current_selected_cell_.table, "inter")
                filename = string(self.intertrial_table_.Data(self.current_selected_cell_.index(2)));

            elseif strcmp(self.current_selected_cell_.table, "block")
                filename = string(self.block_table_.Data(self.current_selected_cell_.index(1),self.current_selected_cell_.index(2)));

            elseif strcmp(self.current_selected_cell_.table, "post")
                filename = string(self.posttrial_table_.Data(self.current_selected_cell_.index(2)));

            else
                waitfor(errordlg("Please make sure you have selected a cell and try again"));
            end

            if strcmp(filename,'') == 0
                data = self.model_.doc_.Patterns_.(filename).pattern.Pats;
                self.auto_preview_index_ = self.auto_preview_index_ + 1;
                if self.auto_preview_index_ > length(data(1,1,:))
                    self.auto_preview_index_ = 1;
                end
                preview_data = data(:,:,self.auto_preview_index_);
                
                xax = [0 length(preview_data(1,:))];
                yax = [0 length(preview_data(:,1))];
                 
                max_num = max(preview_data,[],[1 2]);    
                adjusted_matrix = preview_data ./ max_num;
                
          

                % black = [1 1 1];
                 %white = [0 0 0];

                %for i = 1:30
                im = imshow(adjusted_matrix(:,:), 'Colormap', gray);
                set(im, 'parent', self.hAxes_)
                set(self.hAxes_, 'XLim', xax, 'YLim', yax);

            end


        end

%ONE FRAME BACK ON IN SCREEN PREVIEW---------------------------------------        
        
        function frame_back(self, src, event)

            if strcmp(self.current_selected_cell_.table, "pre")
                filename = string(self.pretrial_table_.Data(self.current_selected_cell_.index(2)));
            elseif strcmp(self.current_selected_cell_.table, "inter")
                filename = string(self.intertrial_table_.Data(self.current_selected_cell_.index(2)));

            elseif strcmp(self.current_selected_cell_.table, "block")
                filename = string(self.block_table_.Data(self.current_selected_cell_.index(1),self.current_selected_cell_.index(2)));

            elseif strcmp(self.current_selected_cell_.table, "post")
                filename = string(self.posttrial_table_.Data(self.current_selected_cell_.index(2)));

            else
                waitfor(errordlg("Please make sure you have selected a cell and try again"));
            end

            if strcmp(filename,'') == 0
                self.auto_preview_index_ = self.auto_preview_index_ - 1;

                if self.auto_preview_index_ < 1
                    self.auto_preview_index_ = length(self.current_preview_file_(1,1,:));
                end
                data = self.model_.doc_.Patterns_.(filename).pattern.Pats;
                preview_data = data(:,:,self.auto_preview_index_);
                
                xax = [0 length(preview_data(1,:))];
                yax = [0 length(preview_data(:,1))];
                 
                max_num = max(preview_data,[],[1 2]);    
                adjusted_matrix = preview_data ./ max_num;
                
          

                % black = [1 1 1];
                 %white = [0 0 0];

                %for i = 1:30
                im = imshow(adjusted_matrix(:,:), 'Colormap', gray);
                set(im, 'parent', self.hAxes_)
                set(self.hAxes_, 'XLim', xax, 'YLim', yax);
            end

        end

%PLAY THE IN SCREEN PREVIEW------------------------------------------------
        
        function preview_play(self, src, event)

            self.is_paused_ = false;

            if strcmp(self.current_selected_cell_.table, "pre")
                
                filename = string(self.pretrial_table_.Data(self.current_selected_cell_.index(2)));
                mode = cell2mat(self.model_.pretrial_(1));
                if mode == 2
                    fr_rate = cell2mat(self.model_.pretrial_(9));
                else
                    fr_rate = 30;
                end
                
            elseif strcmp(self.current_selected_cell_.table, "inter")
                
                filename = string(self.intertrial_table_.Data(self.current_selected_cell_.index(2)));
                mode = cell2mat(self.model_.intertrial_(1));
                if mode == 2
                    fr_rate = cell2mat(self.model_.intertrial_(9));
                else
                    fr_rate = 30;
                end
                
            elseif strcmp(self.current_selected_cell_.table, "block")
                
                filename = string(self.block_table_.Data(self.current_selected_cell_.index(1),self.current_selected_cell_.index(2)));
                mode = cell2mat(self.model_.block_trials_(self.current_selected_cell_.index(1), 1));
                if mode == 2
                    fr_rate = cell2mat(self.model_.block_trials_(self.current_selected_cell_.index(1), 9));
                else
                    fr_rate = 30;
                end
                
                
                
            elseif strcmp(self.current_selected_cell_.table, "post")
                filename = string(self.posttrial_table_.Data(self.current_selected_cell_.index(2)));
                mode = cell2mat(self.model_.posttrial_(1));
                if mode == 2
                    fr_rate = cell2mat(self.model_.posttrial_(9));
                else
                    fr_rate = 30;
                end
            else
                waitfor(errordlg("Please make sure you have selected a cell and try again"));
            end

            
            
            
%             
%             
%             x = [0 length(self.current_preview_file_(1,:,1))];
%                         y = [0 length(self.current_preview_file_(:,1,1))];
%                         adjusted_file = zeros(y(2),x(2),length(self.current_preview_file_(1,1,:)));
%                         for i = 1:length(self.current_preview_file_(1,1,:))
%                             max_num = max(self.current_preview_file_(:,:,i));    
%                             adjusted_matrix = self.current_preview_file_(:,:,i) ./ max_num;
%                             adjusted_file(:,:,i) = adjusted_matrix(:,:,1);
%                         end
% 
% 
%                         %disp("it worked!");
%                          black = [1 1 1];
%                          white = [0 0 0];
%                         %hAxes = gca; 
%                         
% 
%                         %for i = 1:30
%                         im = imshow(adjusted_file(:,:,self.auto_preview_index_), 'Colormap',gray);
%                         set(im, 'parent', self.hAxes_)
%                         colormap( self.hAxes_, gray )
%                         set(self.hAxes_, 'XLim', x, 'YLim', y);
%                        % pause(1/fr_rate);
            
            
            
            
            if strcmp(filename,'') == 0
                len = length(self.current_preview_file_(1,1,:));
                xax = [0 length(self.current_preview_file_(1,:,1))];
                yax = [0 length(self.current_preview_file_(:,1,1))];
                max_num = max(self.current_preview_file_,[],[1 2]);
                adjusted_file = zeros(yax(2), xax(2), len);
                for i = 1:len
                    adjusted_matrix = self.current_preview_file_(:,:,i) ./ max_num(i);
                    adjusted_file(:,:,i) = adjusted_matrix(:,:,1);
               
                    
                    
                end
                im = imshow(adjusted_file(:,:,self.auto_preview_index_), 'Colormap', gray);
                set(im,'parent', self.hAxes_);
                set(self.hAxes_, 'XLim', xax, 'YLim', yax );

                %while self.is_paused_ == 0    
                    for i = 1:len
                        if self.is_paused_ == false
                            self.auto_preview_index_ = self.auto_preview_index_ + 1;
                            if self.auto_preview_index_ > len
                                self.auto_preview_index_ = 1;
                            end
                            %imagesc(self.current_preview_file_.pattern.Pats(:,:,self.auto_preview_index_), 'parent', hAxes);
                            set(im,'cdata',adjusted_file(:,:,self.auto_preview_index_), 'parent', self.hAxes_);
                            drawnow

                            pause(1/fr_rate);



                        end
                     end
            end
        end

%PAUSE THE CURRENTLY PLAYING IN SCREEN PREVIEW-----------------------------        
        
        function preview_pause(self, src, event)


            self.is_paused_ = true;

        end

%STOP THE CURRENTLY PLAYING IN SCREEN PREVIEW------------------------------
        
        function preview_stop(self,src,event)

            self.is_paused_ = true;
            self.auto_preview_index_ = 1;

                        %hAxes = gca; 
            x = [0 length(self.current_preview_file_(1,:,1))];
            y = [0 length(self.current_preview_file_(:,1,1))];
     
            max_num = max(self.current_preview_file_,[],[1 2]);    
            adjusted_matrix = self.current_preview_file_(:,:,self.auto_preview_index_) ./ max_num(self.auto_preview_index_);
                
          

                % black = [1 1 1];
                 %white = [0 0 0];

                %for i = 1:30
            im = imshow(adjusted_matrix(:,:), 'Colormap', gray);
            set(im, 'parent', self.hAxes_)
            set(self.hAxes_, 'XLim', x, 'YLim', y);
                        



        end


%OPEN A FULL PREVIEW WINDOW OF SELECTED TRIAL------------------------------

        function full_preview(self, src, event)
                
          data = self.check_one_selected();
           if data == 0
               %do nothing
           else
               
               minicon = preview_controller(data, self.model_);
               self.update_preview_con(minicon);
               
               %For all cells that have a file, set the object in question
               %equal to a variable and get its size. If there's not one
               %there, set the size (for the axes) to
               %default [1,3] (for an x axis three times the length of y
               %axis)
           mode = data{1};
               if mode == 1
                   self.preview_con_.preview_Mode1();
               elseif mode == 2
                   self.preview_con_.preview_Mode2();
               elseif mode == 3
                   self.preview_con_.preview_Mode3();
               elseif mode == 4
                   self.preview_con_.preview_Mode4();
               elseif mode == 5
                   self.preview_con_.preview_Mode4();
               elseif mode == 6
                   self.preview_con_.preview_Mode6();
               elseif mode == 7
                   self.preview_con_.preview_Mode4();
               else
                   waitfor(errordlg("Please make sure you have entered a valid mode and try again."));
               end

%At this point, all axes should have been created and all existing
%functions should have been plotted. May change plotting method later in
%order to have the AO functions draw themselves in time.



            end



        end
        
%RUN A SINGLE TRIAL ON THE LED SCREENS TO MAKE SURE ITS WORKING------------

        function dry_run(self, src, event)
            
            experiment_name = self.model_.get_experiment_name();
            num_reps = 0;
            randomize = 0;
            trial = self.check_one_selected;
            %block_trials = self.model_.get_block_trials();
            trial_mode = trial{1};
            trial_duration = trial{12};
            %intertrial = self.model_.get_intertrial();
            LmR_gain = trial{10};
            LmR_offset = trial{11};
            pre_start = 0;
            experiment_folder = ['C:\matlabroot\G4\Experiments\' self.model_.experiment_name_];
            
            connectHost;
            Panel_com('change_root_directory', experiment_folder);
            start = input('press enter to start experiment');
            
            pattern_index = self.model_.get_pattern_index(trial{2});
            position_index = self.model_.get_posfunc_index(trial{3});
            ao_index = self.model_.get_ao_index(trial{4});
            Panel_com('set_control_mode', trial_mode);
            Panel_com('set_pattern_id', pattern_index); %HOW DOES THIS WORK? HOW DOES IT GET THE PATTERN DATA?
           % Panel_com('set_gain_bias', [LmR_gain LmR_offset])
            Panel_com('set_pattern_func_id', position_index);
            %fprintf(['Rep ' num2str(r) ' of ' num2str(num_reps) ', cond ' num2str(c) ' of ' num2str(num_conditions) ': ' strjoin(currentExp.pattern.pattNames(cond)) '\n']);
            Panel_com('set_ao_function_id',[0, ao_index]);
            pause(0.01)
            Panel_com('start_display', (trial_duration*10)); %duration expected in 100ms units
            pause(trial_duration+0.1)
            Panel_com('stop_display');
            %end of trial portion
                  
            
        end


        

%FULL PREVIEW FOR MODE 1---------------------------------------------------

        
        function animateMode1(self, src, event, data, pos_pos, ao1_pos, ao2_pos, ao3_pos, ao4_pos, f, pos_data, im, pat_obj)
            
             [pos, ao1, ao2, ao3, ao4] = self.create_preview_objects(data, pos_pos, ao1_pos, ao2_pos, ao3_pos, ao4_pos, f); %CREATE THIS FUNCTION TO RETURN AXES

            if pos == 0
                waitfor(errordlg("Please make sure you have entered a position function and try again."));
            else


                for i = self.auto_preview_index_:length(pos_data)
                    
                    if self.is_paused_ == false

                        frame = pos_data(i);
                        disp(frame);
                        set(im,'cdata',pat_obj(:,:,frame));

                        pos.XData = [self.auto_preview_index_ + 1, self.auto_preview_index_ + 1];

                        if ao1 ~= 0
                            ao1.XData = [self.auto_preview_index_ + 1, self.auto_preview_index_ + 1];
                        end
                        if ao2 ~= 0
                            ao2.XData = [self.auto_preview_index_ + 1, self.auto_preview_index_ + 1];
                        end
                        if ao3 ~= 0
                            ao3.XData = [self.auto_preview_index_ + 1, self.auto_preview_index_ + 1];
                        end
                        if ao4 ~= 0
                            ao4.XData = [self.auto_preview_index_ + 1, self.auto_preview_index_ + 1];
                        end

                        drawnow limitrate nocallbacks
                        java.lang.Thread.sleep(17);
                        
                        self.auto_preview_index_ = self.auto_preview_index_ + 1;
                        
                    else
                        
                        self.auto_preview_index_ = i;
                        
                    end
                       


                end
            end
        end
        


%CHECK IF PARTICULAR FILE EXISTS-------------------------------------------

        function [loaded_file] = check_file_exists(self, filename)

            if isfile(filename) == 0
                waitfor(errordlg("This file doesn't exist"));
                loaded_file = 0;
            else
                loaded_file = load(filename);
            end


        end

%PLOT A POSITION OR AO FUNCTION--------------------------------------------

        function [func_line] = plot_function(self, fig, func, position, graph_title, x_label, y_label)

                xlim = [0 length(func(1,:))];
                ylim = [min(func) max(func)];
                func_axes = axes(fig, 'units','pixels','Position', position, ...
                    'XLim', xlim, 'YLim', ylim);
                %title(func_axes, graph_title);
        %         xlabel(func_axes, x_label);
        %         ylabel(func_axes, y_label);
                p = plot(func);
                set(p, 'parent', func_axes);
                func_line = line('XData',[self.auto_preview_index_,self.auto_preview_index_],'YData',[ylim(1), ylim(2)]);
                title(graph_title);
                xlabel(x_label);
                ylabel(y_label);
                

        end
        
        function open_run_gui(self, src, event)
            
            self.run_con_ = run_controller(self.model_);
            
        end



%ERROR CATCHING FUNCTIONS--------------------------------------------------

%REFERENCE FOR Y INDEX VALUES
    %MODE y = 1, PAT NAME y = 2, POS FUNC y = 3, AO1-4 y = 4-7, Frame Ind y =
    %8, Frame Rate y = 9, Gain y = 10, Offset y = 11, Duration y = 12, Select y
    %= 13
    

%CHECK IF THE CELL IS EDITABLE---------------------------------------------

%Return true or false, on true the update function continues, on false the 
%gui is updated with the old data and an error message is displayed. 
        function [allow] = check_editable(self, mode, y) 


            allow = 1;

            %check that the field is editable based on the mode
            if isempty(mode)
                return;
            elseif mode == 1 && (7 < y) && (12 > y)

                allow = 0;

            elseif mode == 2 && (y ==3 || y == 8 || ((y > 9) && (y < 12)))

                allow = 0;

            elseif mode == 3 && (y == 3 || ((y > 8) && (y < 12)))

                allow = 0;

            elseif mode == 4 && (y == 3 || y == 8 || y == 9 )

                allow = 0;

            elseif (mode == 5 || mode == 6) && (y == 8 || y == 9)

                allow = 0;

            elseif mode == 7 && ( y == 3 || ((y > 7) && (y < 12)))

                allow = 0;

            end

        end

%CHECK THAT THE VALUE ENTERED IS WITHIN BOUNDS-----------------------------        
        
function [within_bounds] = check_constraints(self, y, new)
%Something's wrong with this function, get error with correct values, not
%sure why yet
    within_bounds = 1;
    if y == 1
        if new > 7 || new < 1
            within_bounds = 0;
        end
    elseif y == 8
        if new < 1
            within_bounds = 0;
        end
    elseif y == 9 
        %can you check the input for non-numeric characters somehow?
    elseif y == 10
        %same as above
    elseif y == 11
        %same as above
    elseif y == 12
        if new < 1
            within_bounds = 0;
        end
    end
end

%CLEAR APPROPRIATE FIELDS WHEN THE MODE IS CHANGED-------------------------

function clear_fields(self, mode)

    pos_fields = fieldnames(self.model_.doc_.Pos_funcs_);
    pat_fields = fieldnames(self.model_.doc_.Patterns_);
    pos = '';
    indx = [];
    rate = [];
    gain = [];
    offset = [];
    
    if mode == 1

        index_of_pat = find(strcmp(pat_fields(:), [self.model_.block_trials_{self.current_selected_cell_.index(1), 2}]));
        pos = cell2mat(pos_fields(index_of_pat));
        self.set_mode_dep_props(pos, indx, rate, gain, offset);
        
    elseif mode == 2
        
        rate = 60;
        self.set_mode_dep_props(pos, indx, rate, gain, offset);
        %frame rate, clear others
        
        
    elseif mode == 3

        indx = 1;
        self.set_mode_dep_props(pos, indx, rate, gain, offset);
        %frame index, clear others
        
    elseif mode == 4
        gain = 1;
        offset = 0;
        self.set_mode_dep_props(pos, indx, rate, gain, offset);
        %gain, offset, clear others
        
    elseif mode == 5
        index_of_pat = find(strcmp(pat_fields(:), [self.model_.block_trials_{self.current_selected_cell_.index(1), 2}]));
        pos = cell2mat(pos_fields(index_of_pat));
        gain = 1;
        offset = 0;
        self.set_mode_dep_props(pos, indx, rate, gain, offset);
        %pos, gain, offset, clear others
        
    elseif mode == 6
        
        index_of_pat = find(strcmp(pat_fields(:), [self.model_.block_trials_{self.current_selected_cell_.index(1), 2}]));
        pos = cell2mat(pos_fields(index_of_pat));
        gain = 1;
        offset = 0;
        self.set_mode_dep_props(pos, indx, rate, gain, offset);
        %pos, gain, offset, clear others
        
    elseif mode == 7
        
        self.set_mode_dep_props(pos, indx, rate, gain, offset);
        %clear all
        
    elseif isempty(mode)
        pos = '';
        indx ='';
        rate = '';
        gain = '';
        offset = '';
        self.set_mode_dep_props(pos, indx, rate, gain, offset);
        if strcmp(self.current_selected_cell_.table,"pre") == 1
            self.model_.set_pretrial_property(2, '');
            for i = 4:7
                self.model_.set_pretrial_property(i,'');
            end
            self.model_.set_pretrial_property(12,'');
            
        elseif strcmp(self.current_selected_cell_.table,"inter") == 1
            self.model_.set_intertrial_property(2, '');
            for i = 4:7
                self.model_.set_intertrial_property(i,'');
            end
            self.model_.set_intertrial_property(12,'');
            
            
        elseif strcmp(self.current_selected_cell_.table,"post") == 1
            self.model_.set_posttrial_property(2, '');
            for i = 4:7
                self.model_.set_posttrial_property(i,'');
            end
            self.model_.set_posttrial_property(12,'');
            
            
        else
            x = self.current_selected_cell_.index(1);
            self.model_.set_block_trial_property([x,2], '');
            for i = 4:7
                self.model_.set_block_trial_property([x,i],'');
            end
            self.model_.set_block_trial_property([x,12],'');
        end
        
    end

end

function set_mode_dep_props(self, pos, indx, rate, gain, offset)

    if strcmp(self.current_selected_cell_.table,"pre") == 1
        self.model_.set_pretrial_property(3, pos);
        self.model_.set_pretrial_property(8, indx);
        self.model_.set_pretrial_property(9, rate);
        self.model_.set_pretrial_property(10, gain);
        self.model_.set_pretrial_property(11, offset);
        self.set_pretrial_files_(3, pos);
            
    elseif strcmp(self.current_selected_cell_.table,"inter") == 1
        self.model_.set_intertrial_property(3, pos);
        self.model_.set_intertrial_property(8, indx);
        self.model_.set_intertrial_property(9, rate);
        self.model_.set_intertrial_property(10, gain);
        self.model_.set_intertrial_property(11, offset);
        self.set_intertrial_files_(3,pos);

    elseif strcmp(self.current_selected_cell_.table,"post") == 1
        self.model_.set_posttrial_property(3, pos);
        self.model_.set_posttrial_property(8, indx);
        self.model_.set_posttrial_property(9, rate);
        self.model_.set_posttrial_property(10, gain);
        self.model_.set_posttrial_property(11, offset);
        self.set_posttrial_files_(3,pos);

    else
        x = self.current_selected_cell_.index(1);
        self.model_.set_block_trial_property([x,3], pos);
        self.model_.set_block_trial_property([x,8], indx);
        self.model_.set_block_trial_property([x,9], rate);
        self.model_.set_block_trial_property([x,10], gain);
        self.model_.set_block_trial_property([x,11], offset);
        self.set_blocktrial_files_(self.current_selected_cell_.index(1),3,pos);

    end
    
    self.update_gui();


end

% function mismatched_sample_rates_dialog(self)
% 
%     d = dialog('Units','Normalized','Position',[.45,.45,.1,.1],'Name','Configuration File Mismatch');
%     warning = uicontrol('Parent',d,'Style','text','Units','Normalized','Position',[.1,.9,.75,.1],...
%         'String','The sample rates in the configuration file do not match those shown on the screen. Do you want to: ');
%     grp = uibuttongroup('Parent',d,'Units','Normalized','Position',[.1,.1,.75,.75],'SelectionChangedFcn',{@self.mismatched_sample_rates_response,d});
%     choice1 = uicontrol('Parent',grp,'Style','radiobutton','Units','Normalized','Position',[.1,.7,.75,.2],'String','Change configuration file to match screen.');
%     choice2 = uicontrol('Parent',grp,'Style','radiobutton','Units','Normalized','Position',[.1,.4,.75,.2],'String','Change screen to match configuration file.');
%     choice3 = uicontrol('Parent',grp,'Style','radiobutton','Units','Normalized','Position',[.1,.1,.75,.2],'String','Do nothing, will fix manually.');
% 
% end
% 
% function mismatched_sample_rates_response(self, src, event, d)
%     
%     if event.NewValue.Position(2) == .7
%         
%         self.update_config_file(self.model_.chan1_rate_, 1);
%         self.update_config_file(self.model_.chan2_rate_, 2);
%         self.update_config_file(self.model_.chan3_rate_, 3);
%         self.update_config_file(self.model_.chan4_rate_, 4);
%         
%     elseif event.NewValue.Position(2) == .4
%         
%         self.model_.set_chan1_rate(str2num(self.configData_{14}(end-3:end)));
%         self.model_.set_chan2_rate(str2num(self.configData_{15}(end-3:end)));
%         self.model_.set_chan3_rate(str2num(self.configData_{16}(end-3:end)));
%         self.model_.set_chan4_rate(str2num(self.configData_{17}(end-3:end)));
% 
%     else
%         %do nothing, they exited out of the dialog box
%         
%     end
%     
%     delete(d);
%     self.chan1_rate_box_.String = num2str(self.model_.chan1_rate_);
%     
% end





%CHECK THAT ONLY ONE TRIAL IS SELECTED-------------------------------------

%returns the data of the trial that is selected or an error if 0 or >1
%trials are selected

        function [data] = check_one_selected(self)

     %find selected rows in ALL tables

     %finds checked rows in block table
            checkbox_block_data = horzcat(self.model_.block_trials_(1:end, end));
            checked_block = find(cell2mat(checkbox_block_data));
            checked_block_count = length(checked_block);

     %Figures out which table has the selected row and ensures no more than
     %one table has a selected row
            if checked_block_count ~= 0
                checked_trial = 'block';
            end


            if cell2mat(self.model_.pretrial_(13)) == 1
                pretrial_checked = 1;
                checked_trial = 'pre';
            else 
                pretrial_checked = 0;

            end

            if cell2mat(self.model_.intertrial_(13)) == 1
                intertrial_checked = 1;
                checked_trial = 'inter';
            else 
                intertrial_checked = 0;
            end

            if cell2mat(self.model_.posttrial_(13)) == 1
                posttrial_checked = 1;
                checked_trial = 'post';
            else 
                posttrial_checked = 0;
            end

            all_checked = checked_block_count + pretrial_checked + intertrial_checked ...
                + posttrial_checked;

      %throw error if more or less than one is selected
            if all_checked == 0 
                waitfor(errordlg("You must selected a trial to preview"));
                data = 0;
            elseif all_checked > 1
                waitfor(errordlg("You can only select one trial at a time to preview"));
                data = 0;
            else
      %set data to correct table
                if strcmp(checked_trial,'pre')
                    data = self.model_.pretrial_;
                elseif strcmp(checked_trial,'inter')
                    data = self.model_.intertrial_;
                elseif strcmp(checked_trial, 'block')
                    data = self.model_.block_trials_(checked_block(1),:);
                elseif strcmp(checked_trial, 'post')
                    data = self.model_.posttrial_;
                else
                    waitfor(errordlg("Something went wrong. Please make sure you have exactly one trial selected and try again."));
                end
            end
        end




%GETTERS OF GUI OBJECT VALUES


%          function output = get.pretrial_table(self)
%             output = self.pretrial_table_;
%          end
% 
%          function output = get.intertrial_table(self)
%             output = self.intertrial_table_;
%          end
% 
%          function output = get.posttrial_table(self)
%             output = self.posttrial_table_;
%          end
% 
%          function output = get.block_table(self)
%             output = self.block_table_;
%          end
% 
%          function output = get.chan1(self)
%             output = self.chan1_;
%          end
% 
%          function output = get.chan2(self)
%             output = self.chan2_;
%          end
% 
%          function output = get.chan3(self)
%             output = self.chan3_;
%          end
%          
%          function output = get.chan4(self)
%             output = self.chan4_;
%          end
%          
%          function output = get.chan1_rate_box(self)
%             output = self.chan1_rate_box_;
%          end
%          
%          function output = get.chan2_rate_box(self)
%             output = self.chan2_rate_box_;
%          end
%          
%          function output = get.chan3_rate_box(self)
%             output = self.chan3_rate_box_;
%          end
%          
%          function output = get.chan4_rate_box(self)
%             output = self.chan4_rate_box_;
%          end
%          
%          function output = get.isSelect_all(self)
%             output = self.isSelect_all_;
%          end
%          
%          function output = get.isRandomized_box(self)
%             output = self.isRandomized_box_;
%          end
%          
%          function output = get.repetitions_box(self)
%             output = self.repetitions_box_;
%          end
         
%SETTERS OF GUI OBJECT VALUES



         function set_pretrial_table_data(self)
             class(self.model_.pretrial_);
            self.pretrial_table_.Data = self.model_.pretrial_;
         end

         function set_intertrial_table_data(self)
            self.intertrial_table_.Data = self.model_.intertrial_;
         end

         function set_posttrial_table_data(self)

            self.posttrial_table_.Data = self.model_.posttrial_;

         end

%          function set_block_table_data_xy(self, x, y)
 
%              
%              
%              %disp(self.model_.block_trials_);
% 
%              
%             self.block_table_.Data{x, y} = self.model_.block_trials_{x,y};
%             
%             
%             %set(self.block_table_, 'data', self.model_.block_trials_);
%          end
         
         function set_block_table_data(self)
             
               %%%%%%%%%%%%%%%%%%THIS IS NOT A GOOD PERMANENT SOLUTION FOR
%              %%%%%%%%%%%%%%%%%%THE SCROLLBAR JUMPING ISSUE. USING PAUSE CAN
%              %%%%%%%%%%%%%%%%%%UNDER CERTAIN CIRCUMSTANCES HAVE WEIRD
%              %%%%%%%%%%%%%%%%%%RESULTS, AND JAVA INTERVENTIONS MAY STOP
%              %%%%%%%%%%%%%%%%%%WORKING WITH ANY RELEASE. FIGURE OUT WHY
%              %%%%%%%%%%%%%%%%%%ADAM'S TABLE DOESN'T JUMP. -- ITS A
%              %%%%%%%%%%%%%%%%%%DIFFERENCE BETWEEN RELEASES. DOWNLOAD 2019
%              %%%%%%%%%%%%%%%%%%and see if that fixes it, if not, ask Mike
                %%%%%%%%%%%%%%%%%%if they have a release preference. 
             
            jTable = findjobj(self.block_table_);
            jScrollPane = jTable.getComponent(0);
            javaObjectEDT(jScrollPane);
            currentViewPos = jScrollPane.getViewPosition;
             
             self.block_table_.Data = self.model_.block_trials_;
             
                         
            pause(0);
            jScrollPane.setViewPosition(currentViewPos);
         end

         function set_bg_selection(self)
            if self.model_.is_randomized_ == 1
                set(self.bg_,'SelectedObject',self.isRandomized_radio_);
            else
                set(self.bg_,'SelectedObject',self.isSequential_radio_);
            end
         end

         function set_repetitions_box_val(self)
            self.repetitions_box_.String = num2str(self.model_.repetitions_);
         end
         
         function set_isSelect_all_box_val(self)
             self.isSelect_all_box_.Value = self.isSelect_all_;
         end

         function set_chan1_val(self)
            self.chan1_.Value = self.model_.is_chan1_;
         end
         
         function set_chan2_val(self)
            self.chan2_.Value = self.model_.is_chan2_;
         end
         
         function set_chan3_val(self)
            self.chan3_.Value = self.model_.is_chan3_;
         end
         
         function set_chan4_val(self)
            self.chan4_.Value = self.model_.is_chan4_;
         end
         
         function set_chan1_rate_box_val(self)

            self.chan1_rate_box_.String = num2str(self.model_.chan1_rate_);
         end
         
         function set_chan2_rate_box_val(self)

            self.chan2_rate_box_.String = num2str(self.model_.chan2_rate_);

         end

         function set_chan3_rate_box_val(self)

            self.chan3_rate_box_.String = num2str(self.model_.chan3_rate_);
         end
         
         function set_chan4_rate_box_val(self)
            self.chan4_rate_box_.String = num2str(self.model_.chan4_rate_);
         end
         
         function set_bg2_selection(self)
            
             value = get(self.num_rows_3_, 'Enable');
             if strcmp(value,'off') == 1
                 %do nothing
             else
                if self.model_.num_rows_ == 3
                    set(self.bg2_,'SelectedObject',self.num_rows_3_);
                else
                    set(self.bg2_,'SelectedObject',self.num_rows_4_);
                end
             end
            
         end
         
         function set_exp_name(self)
             set(self.exp_name_box_,'String', self.model_.experiment_name_);
         end

         
             
         
         
%          function [self] = setfield(self.pre_files_,'pattern', new)
%          
%             self.pre_files_.pattern = new;
%              
%          end
         
         
         function  set_pretrial_files_(self, y, new_value)
            
             new_value = string(new_value);
              
            if y == 2
                self.pre_files_.pattern = new_value;
            end
            if y == 3
                self.pre_files_.position = new_value;
            end
            if y == 4
                self.pre_files_.ao1 = new_value;
            end
            if y == 5
                self.pre_files_.ao2 = new_value;
            end
            if y == 6
                self.pre_files_.ao3 = new_value;
            end
            if y == 7
                self.pre_files_.ao4 = new_value;
            end
         end

         
         function  set_intertrial_files_(self, y, new_value)
             
             new_value = string(new_value);
            
            if y == 2
                self.inter_files_.pattern = new_value;
            end
            if y == 3
                self.inter_files_.position = new_value;
            end
            if y == 4
                self.inter_files_.ao1 = new_value;
            end
            if y == 5
                self.inter_files_.ao2 = new_value;
            end
            if y == 6
                self.inter_files_.ao3 = new_value;
            end
            if y == 7
                self.inter_files_.ao4 = new_value;
            end
         end
         
         
         function  set_posttrial_files_(self, y, new_value)
             
             new_value = string(new_value);
            
            if y == 2
                self.post_files_.pattern = new_value;
            end
            if y == 3
                self.post_files_.position = new_value;
            end
            if y == 4
                self.post_files_.ao1 = new_value;
            end
            if y == 5
                self.post_files_.ao2 = new_value;
            end
            if y == 6
                self.post_files_.ao3 = new_value;
            end
            if y == 7
                self.post_files_.ao4 = new_value;
            end
         end
         
         function  set_blocktrial_files_(self, x, y, new_value)
             
             new_value = string(new_value);
            
            if y == 2
                %disp(self.block_files_.pattern(x));
                self.block_files_.pattern(x) = new_value;
            end
            if y == 3
                self.block_files_.position(x) = new_value;
            end
            if y == 4
                self.block_files_.ao1(x) = new_value;
            end
            if y == 5
                self.block_files_.ao2(x) = new_value;
            end
            if y == 6
                self.block_files_.ao3(x) = new_value;
            end
            if y == 7
                self.block_files_.ao4(x) = new_value;
            end
         end
 
%          function self = set.pre_selected_index_(self, value)
%              self.pre_selected_index_ = value;
%          end
%          
%          function self = set.auto_preview_index_(self, value)
%              self.auto_preview_index_ = value;
%          end
%          


     end


end

