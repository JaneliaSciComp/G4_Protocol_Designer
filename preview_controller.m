classdef preview_controller < handle

    properties
         model_;

        fig_;
        im_;
        pat_axes_;
        pos_line_;
        ao1_line_;
        ao2_line_;
        ao3_line_;
        ao4_line_;
        dummy_line_;
         
    end
    
    properties (Dependent)
         model;

        fig;
        im;
        pat_axes;
        pos_line;
        ao1_line;
        ao2_line;
        ao3_line;
        ao4_line;
        dummy_line;

    end
    
    
    
    methods
 %CONSTRUCTOR
        function self = preview_controller(data, doc)
            self.model = preview_model(data, doc);
            
            self.fig = figure( 'Name', 'Trial Preview', 'NumberTitle', 'off','units', 'pixels'); 


            self.layout();
            self.update_layout();
            
        
        end
        
        
        function layout(self)


            pix = get(0, 'screensize'); 
            patternSize = size(self.model.pattern_data(:,:,1));
            pat_xlim = [0 length(self.model.pattern_data(1,:,1))];
            pat_ylim = [0 length(self.model.pattern_data(:,1,1))];

            %ratios of y direction to x direction in pattern/function
            %files so images don't get squished forced into axes that
            %don't fit the data correctly.

            yTOx_pat_ratio = patternSize(2)/patternSize(1);

            
            if self.model.mode ~= 6 %There only needs to be a spot for one position function

                %figure
                fig_height = pix(4)*.65;
                fig_width = pix(3)*.9;
                fig_x = (pix(3) - fig_width)/2;
                fig_y = (pix(4)-fig_height)/2;
                fig_pos = [fig_x, fig_y, fig_width, fig_height];


                %charts h/w
                chart_height = fig_height/2 - 200;
                pat_chart_width = chart_height*yTOx_pat_ratio;
                pos_chart_width = pat_chart_width;
                aoChart_height = chart_height/2 - 20;
                aoChart_width = pat_chart_width/2;
    %             ao2Chart_width = pat_chart_width/2;
    %             ao3Chart_width = pat_chart_width/2;
    %             ao4Chart_width = pat_chart_width/2;



                %title height plus buffer
                title_height = 100;
                aoTitle_height = title_height*.75;
                buffer = 50;

                %x/y positions of charts in figure
                patpos_x = 100;
                pos_y = 200;
                pat_y = pos_y + chart_height + title_height + buffer;
                ao_x = patpos_x + pat_chart_width + 150;
                ao1_y = pat_y + aoChart_height;
                ao2_y = ao1_y - aoTitle_height - aoChart_height;
                ao3_y = ao2_y - aoTitle_height - aoChart_height;
                ao4_y = ao3_y - aoTitle_height - aoChart_height;

                pat_pos = [patpos_x, pat_y, pat_chart_width, chart_height];
                pos_pos = [patpos_x, pos_y, pos_chart_width, chart_height];
                ao1_pos = [ao_x, ao1_y, aoChart_width, aoChart_height];
                ao2_pos = [ao_x, ao2_y, aoChart_width, aoChart_height];
                ao3_pos = [ao_x, ao3_y, aoChart_width, aoChart_height];
                ao4_pos = [ao_x, ao4_y, aoChart_width, aoChart_height];

                %graph dimensions based on screen size
            else %There needs to be space for two position functions
                
                %figure
                fig_height = pix(4)*.85;
                fig_width = pix(3)*.97;
                fig_x = (pix(3) - fig_width)/2;
                fig_y = (pix(4)-fig_height)/2;
                fig_pos = [fig_x, fig_y, fig_width, fig_height];


                %charts h/w
                chart_height = fig_height/3 - 200;
                pat_chart_width = chart_height*yTOx_pat_ratio;
                aoChart_height = chart_height/2 - 20;
                aoChart_width = pat_chart_width/2;
    %             ao2Chart_width = pat_chart_width/2;
    %             ao3Chart_width = pat_chart_width/2;
    %             ao4Chart_width = pat_chart_width/2;



                %title height plus buffer
                title_height = 100;
                aoTitle_height = title_height*.75;
                buffer = 50;

                %x/y positions of charts in figure
                patpos_x = 100;
                dummy_y = 150;
                pos_y = dummy_y + chart_height + title_height + buffer;
                pat_y = pos_y + chart_height + title_height + buffer;
                ao_x = patpos_x + pat_chart_width + 150;
                ao1_y = pat_y + aoChart_height;
                ao2_y = ao1_y - aoTitle_height - aoChart_height;
                ao3_y = ao2_y - aoTitle_height - aoChart_height;
                ao4_y = ao3_y - aoTitle_height - aoChart_height;

                pat_pos = [patpos_x, pat_y, pat_chart_width, chart_height];
                pos_pos = [patpos_x, pos_y, pat_chart_width, chart_height];
                dum_pos = [patpos_x, dummy_y, pat_chart_width, chart_height];
                ao1_pos = [ao_x, ao1_y, aoChart_width, aoChart_height];
                ao2_pos = [ao_x, ao2_y, aoChart_width, aoChart_height];
                ao3_pos = [ao_x, ao3_y, aoChart_width, aoChart_height];
                ao4_pos = [ao_x, ao4_y, aoChart_width, aoChart_height];

                
                
            end

                    %pat_num_frames = length(self.model.pattern_data(1,1,:));
            ao_xlabel = 'Time';
            ao_ylabel = 'Volts';
            
            set(self.fig, 'Position', fig_pos); %create overall figure for preview
            %Files are all loaded, now create figure and axes
            self.pat_axes = axes(self.fig, 'units', 'pixels', 'Position', pat_pos, ...
                'XLim', pat_xlim, 'YLim', pat_ylim);
            
            first_frame = self.get_first_frame();
           

            %fr_rate = cell2mat(data(9));
            self.im = imshow(self.model.pattern_data(:,:,first_frame), 'Colormap', gray);
            set(self.im, 'parent', self.pat_axes);
            title(self.pat_axes, 'Pattern Preview');


               %check for position and ao functions. if preset, set data,
               %if not, set to zero.
           if self.model.mode == 1
               if strcmp(self.model.data(3),'') == 1
                   waitfor(errordlg("To preview in mode one please enter a position function"));
                   return;
               else
                   
                   posSize = size(self.model.pos_data(:,:));
    %                pos_position = [patpos_x, pos_y, pos_chart_width, chart_height];
                   pos_title = 'Position Function Preview';
                   pos_xlabel = 'Time';
                   pos_ylabel = 'Frame Index';
                   self.pos_line = self.plot_function(self.fig, self.model.pos_data, pos_pos, pos_title, ...
                           pos_xlabel, pos_ylabel);
               end
           end
               
           if self.model.mode == 4 || self.model.mode == 5 || self.model.mode == 7
               
               self.create_dummy_function();
               if self.model.mode == 4 || self.model.mode == 7
                   pos_title = "Closed-loop displayed as 1 Hz sine wave";
               else
                   pos_title = "Closed-loop displayed as combination dummy function";
               end
               pos_xlabel = 'Time';
               pos_ylabel = 'Frame Index';
               self.dummy_line = self.plot_function(self.fig, self.model.dummy_data, pos_pos, pos_title, ...
                    pos_xlabel, pos_ylabel);
               
           end
           
           if self.model.mode == 6
           

                pos_title = 'Position Function Preview';
                pos_xlabel = 'Time';
                pos_ylabel = 'Frame Index';
                
                self.create_dummy_function();
                dummy_title = "closed loop displayed as 1 Hz sine wave";
                
                self.dummy_line = self.plot_function(self.fig, self.model.dummy_data, dum_pos, ...
                    dummy_title, pos_xlabel, pos_ylabel);
                self.pos_line = self.plot_function(self.fig, self.model.pos_data, pos_pos, ...
                    pos_title, pos_xlabel, pos_ylabel);
           
           
           end

           if strcmp(self.model.data(4),'') == 0

               ao1Size = size(self.model.ao1_data(:,:));
%                ao_position = [ao_x, ao1_y, ao1Chart_width, aoChart_height];
               ao1_title = 'Analog Output 1';
               self.ao1_line = self.plot_function(self.fig, self.model.ao1_data, ao1_pos, ao1_title, ...
                        ao_xlabel, ao_ylabel);

           else

               self.ao1_line = 0;
               ao1Size = [1,3];

           end

           if strcmp(self.model.data(5),'') == 0

               ao2Size = size(self.model.ao2_data(:,:));
               %ao_position = [ao_x, ao2_y, ao2Chart_width, aoChart_height];
               ao2_title = 'Analog Output 2';
               self.ao2_line = self.plot_function(self.fig, self.model.ao2_data, ao2_pos, ao2_title, ...
               ao_xlabel, ao_ylabel);

           else

               ao2Size = [1,3];
               self.ao2_line = 0;

           end

           if strcmp(self.model.data(6),'') == 0

               ao3Size = size(self.model.ao3_data(:,:));
               %ao_position = [ao_x, ao3_y, ao3Chart_width, aoChart_height];
               ao3_title = 'Analog Output 3';
               self.ao3_line = self.plot_function(self.fig, self.model.ao3_data, ao3_pos, ao3_title, ...
               ao_xlabel, ao_ylabel);

           else

               ao3Size = [1,3];
               self.ao3_line = 0;

           end

           if strcmp(self.model.data(7),'') == 0

               ao4Size = size(self.model.ao4_data(:,:));
              % ao_position = [ao_x, ao4_y, ao4Chart_width, aoChart_height];
               ao4_title = 'Analog Output 4';
               self.ao4_line = self.plot_function(self.fig, self.model.ao4_data, ao4_pos, ao4_title, ...
               ao_xlabel, ao_ylabel);

           else

               ao4Size = [1,3];
               self.ao4_line = 0;

           end
           

           
           playButton = uicontrol(self.fig, 'Style', 'pushbutton', 'String', 'Play', 'FontSize', ...
                14, 'units', 'pixels', 'Position', [(pat_pos(1) + pat_pos(3))/2 + 25, 75, 50, 25], 'Callback', @self.play);
           stopButton = uicontrol(self.fig, 'Style', 'pushbutton', 'String', 'Stop', 'FontSize', ...
                14, 'units', 'pixels', 'Position', [(pat_pos(1) + pat_pos(3))/2 - 50, 75, 50, 25], 'Callback', @self.stop);
           pauseButton = uicontrol(self.fig, 'Style', 'pushbutton', 'String', 'Pause', 'FontSize', ...
                14, 'units', 'pixels', 'Position', [ (pat_pos(1) + pat_pos(3))/2 + 100, 75, 90, 25], 'Callback', @self.pause);
           realtime = uicontrol(self.fig, 'Style', 'checkbox', 'String', 'Real-time speed', 'Value', ...
               self.model.is_realtime, 'FontSize', 14, 'Position', [ ((pat_pos(1) + pat_pos(3))/2 +215), 75, 200, 25],...
               'Callback', @self.set_realtime); 

           
        
        
        end
        
        
        function update_layout(self)
            first_frame = self.get_first_frame();

            set(self.im,'cdata',self.model.pattern_data(:,:,first_frame))
            
            xdata = [1,1];
            if self.pos_line ~= 0
                self.pos_line.XData = xdata;
      
            end
            if self.dummy_line ~= 0
                self.dummy_line.XData = xdata;
                %set dummy_line position
            end
            if self.ao1_line ~= 0
                self.ao1_line.XData = xdata;
                %set ao1_line position
            end
            if self.ao2_line ~= 0
                self.ao2_line.XData = xdata;%set ao2_line position
            end
            if self.ao3_line ~= 0
                self.ao3_line.XData = xdata;
                %set ao3_line position
            end
            if self.ao4_line ~= 0
                self.ao4_line.XData = xdata;
                %set ao4_line position
            end
            
        end
        
        function preview_Mode1(self)
            

        self.model.is_paused = false;
            
            if self.model.is_realtime == 1
                fr_rate = self.model.rt_frRate;
                aofr_rate = 1000;
                fr_increment = 1;
                ao_increment = 1;
                
            else
                fr_rate = self.model.slow_frRate;
                aofr_rate = (1000/self.model.rt_frRate)*fr_rate;
                fr_increment = 1;
                ao_increment = 1;
            end
            
            if self.pos_line == 0
                waitfor(errordlg("Please make sure you've entered a position function and try again."));
            else
                
                time = self.model.dur*1000;
%                aofr_rate = 1000;
                ratio = aofr_rate/fr_rate;
                count = 1;
                j = self.model.preview_index;
                numIt = 1;
                if self.ao1_line ~= 0
                    lineDist1 = length(self.model.ao1_data);
                end
                if self.ao2_line ~= 0
                    lineDist2 = length(self.model.ao2_data);
                end
                if self.ao3_line ~= 0
                    lineDist3 = length(self.model.ao3_data);
    
                end
                if self.ao4_line ~= 0
                    lineDist4 = length(self.model.ao4_data);
                end

                for i = self.model.preview_index:time
                    inside = tic;
                    if self.model.is_paused == false
                    %move ao lines
                    
                        if self.ao1_line ~= 0

                            if self.ao1_line.XData(1) >= lineDist1 %if line reaches end of graph and duration hasn't been reached, it starts at beginning again.
                                self.ao1_line.XData = [1,1];
                            else
                                self.ao1_line.XData = [self.ao1_line.XData(1) + ao_increment, self.ao1_line.XData(2) + ao_increment];
                            end
                        end
                        if self.ao2_line ~= 0

                            if self.ao2_line.XData(1) >= lineDist2
                                self.ao2_line.XData = [1,1];
                            else
                                self.ao2_line.XData = [self.ao2_line.XData(1) + ao_increment, self.ao2_line.XData(2) + ao_increment];
                            end
                        end
                        if self.ao3_line ~= 0

                            if self.ao3_line.XData(1) >= lineDist3
                                self.ao3_line.XData = [1,1];
                            else
                                self.ao3_line.XData = [self.ao3_line.XData(1) + ao_increment, self.ao3_line.XData(2) + ao_increment];
                            end
                        end
                        if self.ao4_line ~= 0

                            if self.ao4_line.XData(1) >= lineDist4
                                self.ao4_line.XData = [1,1];
                            else
                                self.ao4_line.XData = [self.ao4_line.XData(1) + ao_increment, self.ao4_line.XData(2) + ao_increment];
                            end
                        end
                        
                        
                        j = j + fr_increment; %%%THIS was below frame inside the count/ratio if statement - see if moving it out fixes the problem
                            if j > length(self.model.pos_data)
                                j = 1;
                            end

                        if count >= ratio

                            frame = self.model.pos_data(j);
                            

                            set(self.im,'cdata',self.model.pattern_data(:,:,frame));
                            if self.pos_line ~= 0
                                if self.pos_line.XData(1) >= length(self.model.pos_data)
                                    self.pos_line.XData = [1,1];
                                else
                                    self.pos_line.XData = [j,j];%[self.pos_line.XData(1) + fr_increment, self.pos_line.XData(2) + fr_increment];
                                end
                            end

                            self.model.preview_index = self.model.preview_index + 1;
                            %move pos line if it exists
                            %put up next frame
                            count = 1;

                        else

                            count = count + 1;

                        end

                        drawnow limitrate %nocallbacks
                        timeElapsed = toc(inside);

                        if self.model.is_realtime == 1
                            time_to_pause = ao_increment - (timeElapsed*1000);%if realtime, ao line moves once every millsecond no matter what.
                            if time_to_pause < 0
                                time_to_pause = 0;
                            end
                            java.lang.Thread.sleep(time_to_pause);
                            disp(timeElapsed*1000 + time_to_pause);
                            numIt = numIt + 1;
                        else

                            time_to_pause = (((1/fr_rate)/ratio)*1000) - (timeElapsed*1000);%if slow, ao line still moves same number of times but at ratio of whatever the pattern frame rate is.
                            if time_to_pause < 0
                                time_to_pause = 0;
                            end 
                            java.lang.Thread.sleep(time_to_pause);

                        end
                    
                    
                    else
                        
                        return;
                        
                    end
                
                end
            
            end

        end

        
        function preview_Mode2(self)

            if self.model.is_realtime == 1
                fr_rate = self.model.data{9};
            else
                fr_rate = self.model.slow_frRate;
            end

            self.model.is_paused = false;
            pat_num_frames = length(self.model.pattern_data(1,1,:));
            framesTot = self.model.dur * fr_rate;%%DO THEY WANT TO GO THROUGH WHOLE LIBRARY NO MATTER WHAT OR ONLY AS MANY FRAMES AS ALLOWED BY FRAME RATE/DURATION???
            
            if self.ao1_line ~= 0
 
                lineDist1 = length(self.model.ao1_data);
            end
            if self.ao2_line ~= 0
                lineDist2 = length(self.model.ao2_data);
            end
            if self.ao3_line ~= 0
                lineDist3 = length(self.model.ao3_data);
            end
            if self.ao4_line ~= 0
                lineDist4 = length(self.model.ao4_data);
            end

          
            for t = 1:framesTot
%                 tic
                if self.model.is_paused == false

                    set(self.im,'cdata',self.model.pattern_data(:,:,self.model.preview_index));

                        %this equals how far on the xaxis the bar should travel in the span of one frame
                    for s = 1:round(1/(fr_rate/1000), 0)
                        tic%disp(pos_line.XData(1));
                        if self.ao1_line ~= 0

                            if self.ao1_line.XData(1) == lineDist1
                                self.ao1_line.XData = [1,1];
                            else
                                self.ao1_line.XData = [self.ao1_line.XData(1) + 1, self.ao1_line.XData(2) + 1];
                            end


                        end

                        if self.ao2_line ~= 0

                            if self.ao2_line.XData(1) == lineDist2
                                self.ao2_line.XData = [1,1];
                            else
                                self.ao2_line.XData = [self.ao2_line.XData(1) + 1, self.ao2_line.XData(2) + 1];
                            end
                        end
                        if self.ao3_line ~= 0
                            if self.ao3_line.XData(1) == lineDist3
                                self.ao3_line.XData = [1,1];
                            else
                                self.ao3_line.XData = [self.ao3_line.XData(1) + 1, self.ao3_line.XData(2) + 1];
                            end
                        end
                        if self.ao4_line ~= 0
                            if self.ao4_line.XData(1) == lineDist4
                               self.ao4_line.XData = [1,1];
                            else
                               self.ao4_line.XData = [self.ao4_line.XData(1) + 1, self.ao4_line.XData(2) + 1];
                            end
                        end

                        drawnow limitrate %nocallbacks
                        
                        time = toc;
                        pauseTime = (1 - (time*1000/4));
                        if pauseTime < 0 
                            pauseTime = 0;
                        end

                        java.lang.Thread.sleep(pauseTime);
                        
                    end
                   
              
%                     time_taken = toc;
%                     time_to_pause = (1/fr_rate)-time_taken;
%                     if time_to_pause < 0
%                         time_to_pause = 0;
% 
%                     end
% 
%                         java.lang.Thread.sleep(time_to_pause*1000);
%                     end
                    
                    if self.model.preview_index == pat_num_frames
                        self.model.preview_index = 1;
                    else
                        self.model.preview_index = self.model.preview_index + 1;
                    end
                    
                else
                    
                    return;
                    
                end

            end

        end
        
        function preview_Mode3(self)
            
            %This preview just shows the single frame at the given index,
            %so just leave the layout up.
            
        end
        
        function preview_Mode4(self)
            
            self.model.is_paused = false;
            time = self.model.dur*1000;

            if self.model.is_realtime == 1
                fr_rate = self.model.rt_frRate;
            else 
                fr_rate = self.model.slow_frRate;
            end
            

            if self.pos_line == 0
                waitfor(errordlg("Please make sure you have entered a position function and try again."));
            else

                index = self.model.preview_index
                for j = self.model.preview_index:time
                    tic
                    
                    if self.model.is_paused == false
                        if index > length(self.model.dummy_data)
                            index = 1;
                        end
                        frame = self.model.dummy_data(index);

                        set(self.im,'cdata',self.model.pattern_data(:,:,frame));
                        if self.dummy_line ~= 0
                            self.dummy_line.XData = [self.dummy_line.XData(1) + 1, self.dummy_line.XData(2) + 1];
                        end

                        if self.ao1_line ~= 0
                            self.ao1_line.XData = [self.ao1_line.XData(1) + 1, self.ao1_line.XData(2) + 1];
                        end
                        if self.ao2_line ~= 0
                            self.ao2_line.XData = [self.ao2_line.XData(1) + 1, self.ao2_line.XData(2) + 1];
                        end
                        if self.ao3_line ~= 0
                            self.ao3_line.XData = [self.ao3_line.XData(1) + 1, self.ao3_line.XData(2) + 1];
                        end
                        if self.ao4_line ~= 0
                            self.ao4_line.XData = [self.ao4_line.XData(1) + 1, self.ao4_line.XData(2) + 1];
                        end

                        drawnow limitrate %nocallbacks
                        time_taken = toc;
                        
                        time_to_pause = ((1/fr_rate)*1000) - (time_taken*1000);
                        if time_to_pause < 0
                            time_to_pause = 0;
                        end

                        java.lang.Thread.sleep(time_to_pause);                        
                        self.model.preview_index = self.model.preview_index + 1;
                        index = index + 1;
                        
                        
                    end
                       


                end
            end
            
            
        end
        
        function preview_Mode5(self)
        end
        
        function preview_Mode6(self)
            
             
            
             self.model.is_paused = false;


            if self.model.is_realtime == 1
                fr_rate = self.model.rt_frRate;
            else 
                fr_rate = self.model.slow_frRate;
            end

           

            if self.pos_line == 0
                waitfor(errordlg("Please make sure you have entered a position function and try again."));
            else
                
                
                if length(self.model.dummy_data) ~= length(self.model.pos_data)
                    waitfor(errordlg("Please make sure your position function is the same length as your duration"));
                else
                
                    for i = self.model.preview_index:length(self.model.pos_data)
                        tic
                        if self.model.is_paused == false
                            
                            frame1 = self.model.dummy_data(i);
                            frame2 = self.model.pos_data(i);

                            set(self.im,'cdata',self.model.pattern_data(:,:,frame1, frame2));
                            if self.pos_line ~= 0
                                self.pos_line.XData = [self.pos_line.XData(1) + 1, self.pos_line.XData(2) + 1];
                            end
                            
                            if self.dummy_line ~= 0
                                self.dummy_line.XData = [self.dummy_line.XData(1) + 1, self.dummy_line.XData(2) + 1];
                            end
                            if self.ao1_line ~= 0
                                self.ao1_line.XData = [self.ao1_line.XData(1) + 1, self.ao1_line.XData(2) + 1];
                            end
                            if self.ao2_line ~= 0
                                self.ao2_line.XData = [self.ao2_line.XData(1) + 1, self.ao2_line.XData(2) + 1];
                            end
                            if self.ao3_line ~= 0
                                self.ao3_line.XData = [self.ao3_line.XData(1) + 1, self.ao3_line.XData(2) + 1];
                            end
                            if self.ao4_line ~= 0
                                self.ao4_line.XData = [self.ao4_line.XData(1) + 1, self.ao4_line.XData(2) + 1];
                            end

                            drawnow limitrate %nocallbacks
                             time_taken = toc;
                        
                            time_to_pause = ((1/fr_rate)*1000) - (time_taken*1000);
                            if time_to_pause < 0
                                time_to_pause = 0;
                            end

                            java.lang.Thread.sleep(time_to_pause);       
                            self.model.preview_index = self.model.preview_index + 1;


                        end



                    
                    
                    end
                end
            end
            
        end
        
        function preview_Mode7(self)
        end
        
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
            func_line = line('XData',[self.model.preview_index, self.model.preview_index],'YData',[ylim(1), ylim(2)]);
            title(graph_title);
            xlabel(x_label);
            ylabel(y_label);
                

        end
        
        function [first_frame] = get_first_frame(self)


            if self.model.mode == 1
                first_frame = self.model.pos_data(1);
            elseif self.model.mode == 2
                first_frame = 1;
            elseif self.model.mode == 3
                first_frame = self.model.data{8};
            elseif self.model.mode == 4 || self.model.mode == 7
                first_frame = 1;
            elseif self.model.mode == 5
                first_frame = 1; %Where the dummy_pos is the result of combining the original dummy (1 hz sine wave) and the pos function
            elseif self.model.mode == 6
                first_frame = [1, self.model.pos_data(1)];
            end

        
        end
        
        function create_dummy_function(self)
        


            
            ybound = length(self.model.pattern_data(1,1,:));

            %self.model.dummy_data = zeros(1,(dur*1000));
            
            if self.model.mode == 4 || self.model.mode == 7 || self.model.mode == 6
%                 frame = 1;
%                 direction = 'up';
%                for t = 1:(dur*1000)
%                    if strcmp(direction,'up') == 1
%                        
%                         self.model.dummy_data(t) = frame;
%                         frame = frame + 1;
%                    elseif strcmp(direction,'down') == 1
%                        
%                        self.model.dummy_data(t) = frame;
%                        frame = frame - 1;
%                    end
%                    if frame >= ybound
%                        direction = 'down';
%                    elseif frame <= 1
%                        direction = 'up';
%                    end
%                    
% 
%                 %self.model.dummy_data(t) = ybound*sin(2*pi*(t/1000)+(pi/2)) + ybound;
%                end
                time = self.model.dur*1000;
                sample_rate = 1;
                frequency = .001;
                step_size = 1/sample_rate;
                t = 0:step_size:(time - step_size);
                self.model.dummy_data = round((ybound/2 - 1)*sin(2*pi*frequency*t)+((ybound/2)+1),0);
            
            elseif self.model.mode == 5

                xlim = length(self.model.pos_data);
                dummy = zeros(1,xlim);
                ybnd = ybound/2;
                

                time = xlim;
                sample_rate = 1;
                frequency = .001;
                step_size = 1/sample_rate;
                t = 0:step_size:(time - step_size);
                dummy = round((ybnd - 1)*sin(2*pi*frequency*t)+(ybnd+1),0);
                
                
                for m = 1:xlim
                    self.model.dummy_data(m) = self.model.pos_data(m) + dummy(m);
                    if self.model.dummy_data(m) > ybound
                        factor = floor(self.model.dummy_data(m)/ybound);
                        self.model.dummy_data(m) = self.model.dummy_data(m) - (factor*ybound);
                        if self.model.dummy_data(m) == 0
                            self.model.dummy_data(m) = self.model.dummy_data(m) + 1;
                        end
                    end
                end
                
            end

                
        end
         


        
        function pause(self, src, event)
        
            self.model.is_paused = true;
        
        end
        
        function play(self, src, event)

            if self.model.mode == 1
               self.preview_Mode1();
            elseif self.model.mode == 2
                self.preview_Mode2();
            elseif self.model.mode == 3
                self.preview_Mode3();
            elseif self.model.mode == 4 
                self.preview_Mode4();
            elseif self.model.mode == 5
                self.preview_Mode4();
            elseif self.model.mode == 6
                self.preview_Mode6();
            else
                self.preview_Mode4();
            end
        end
        
        function stop(self, src, event)
        
            
            self.model.is_paused = true;
            self.model.preview_index = 1;
            self.update_layout();
            

        
        end
        
        function set_realtime(self, src, event)
            if self.model.is_realtime == 0
                self.model.is_realtime = 1;
            else
                self.model.is_realtime = 0;
            end
        end
        
        
        %GETTERS

        
        function value = get.model(self)
            value = self.model_;
        end
        
        
        function value = get.fig(self)
            value = self.fig_;
        end
        
        function value = get.im(self)
            value = self.im_;
        end
        function value = get.pat_axes(self)
            value = self.pat_axes_;
        end
        function value = get.pos_line(self)
            value = self.pos_line_;
        end
        function value = get.ao1_line(self)
            value = self.ao1_line_;
        end
        function value = get.ao2_line(self)
            value = self.ao2_line_;
        end
        function value = get.ao3_line(self)
            value = self.ao3_line_;
        end
        function value = get.ao4_line(self)
            value = self.ao4_line_;
        end
        function value = get.dummy_line(self)
            value = self.dummy_line_;
        end
        
        %SETTERS
        
        function set.model(self, value)
            self.model_ = value;
        end

        
        function set.fig(self, value)
            self.fig_ = value;
        end
        
        function set.im(self, value)
            self.im_ = value;
        end
        function set.pat_axes(self, value)
            self.pat_axes_ = value;
        end
        function set.pos_line(self, value)
            self.pos_line_ = value;
        end
        function set.ao1_line(self, value)
            self.ao1_line_ = value;
        end
        function set.ao2_line(self, value)
            self.ao2_line_ = value;
        end
        function set.ao3_line(self, value)
            self.ao3_line_ = value;
        end
        function set.ao4_line(self, value)
            self.ao4_line_ = value;
        end
        function set.dummy_line(self, value)
            self.dummy_line_ = value;
        end
        
        
    
    
    end
    



end