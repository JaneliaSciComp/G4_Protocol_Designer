%Input is a struct p with fields containing all the necessary data for
 %running an experiment. The structure is:
 
 %p.pretrial - cell array with all table values
 %p.intertrial - "
 %p.posttrial - "
 %p.block_trials - "
 
 %The filenames in the table have to be converted to indices that can be
 %passed to panel_com. This has already been done and are saved as:
 
 %p.pretrial_pat_index
 %p.pretrial_pos_index - will be zero if no position function.
 %p.pretrial_ao_indices - if there are no active ao channels, this will be
            %empty. If there are, but the pretrial has no ao funcs, it will be zeros.
 
 %p.intertrial_pat_index
 %p.intertrial_pos_index
 %p.intertrial_ao_indices...etc the others follow the same naming
 %convention
 
 %note that p.block_pat/pos/ao indices arrays are m x n where m is number
 %of conditions and n is 1 in the case of pat/pos, or the number of active
 %channels in the case of ao.
 
 %p.active_ao_channels lists the channels that are active - [0 2 3] for
 %example means channels 1, 3, and 4 are active.
 
 %p.num_pretrial_frames gives the number of frames in the pretrial pattern
 %in case it needs to be randomized. p.num_block_frames is an array of
 %numbers, one per trial. Also p.num_intertrial_frames and
 %p.num_posttrial_frames.
 
 %other parameters include p.repetitions, p.is_randomized, and
 %p.save_filename

function run_on_screens_opt1(runcon, p)

%Get access to the figure and progress bar in the run gui.

    fig = runcon.fig;
    progress_bar = runcon.progress_bar;
    progress_axes = runcon.progress_axes;
    axes_label = runcon.axes_label;

 %Set up parameters
 
    active_ao_channels = p.active_ao_channels;
 %pretrial params-----------------------------------------------------
     if isempty(p.pretrial{1}) %no need to set up pretrial params
         pre_start = 0;
     else %set up pretrial params here
         pre_start = 1;
         pre_mode = p.pretrial{1};
         pre_pat = p.pretrial_pat_index;
         pre_pos = p.pretrial_pos_index;
         pre_ao_ind = p.pretrial_ao_indices;

         if isempty(p.pretrial{8})
             pre_frame_ind = 1;
         elseif strcmp(p.pretrial{8},'r')
             pre_frame_ind = 0; %use this later to randomize
         else
             pre_frame_ind = str2num(p.pretrial{8});
         end

         pre_frame_rate = p.pretrial{9};
         pre_gain = p.pretrial{10};
         pre_offset = p.pretrial{11};
         pre_dur = p.pretrial{12};
     end
 
 %intertrial params---------------------------------------------------
 
     if isempty(p.intertrial{1})
         inter_type = 0;%indicates whether or not there is an intertrial
     else
         inter_type = 1;
         inter_mode = p.intertrial{1};
         inter_pat = p.intertrial_pat_index;
         inter_pos = p.intertrial_pos_index;
         inter_ao_ind = p.intertrial_ao_indices;

         if isempty(p.intertrial{8})
             inter_frame_ind = 1;
         elseif strcmp(p.intertrial{8},'r')
             inter_frame_ind = 0; %use this later to randomize
         else
             inter_frame_ind = str2num(p.intertrial{8});
         end

         inter_frame_rate = p.intertrial{9};
         inter_gain = p.intertrial{10};
         inter_offset = p.intertrial{11};
         inter_dur = p.intertrial{12};
     end
 
 %posttrial params------------------------------------------------------
     if isempty(p.posttrial{1})
         post_type = 0;%indicates whether or not there is a posttrial
     else
         post_type = 1;
         post_mode = p.posttrial{1};
         post_pat = p.posttrial_pat_index;
         post_pos = p.posttrial_pos_index;
         post_ao_ind = p.posttrial_ao_indices;

         if isempty(p.posttrial{8})
             post_frame_ind = 1;
         elseif strcmp(p.posttrial{8},'r')
             post_frame_ind = 0; %use this later to randomize
         else
             post_frame_ind = str2num(p.posttrial{8});
         end

         post_frame_rate = p.posttrial{9};
         post_gain = p.posttrial{10};
         post_offset = p.posttrial{11};
         post_dur = p.posttrial{12};
     end
 
 %define static block trial params (will define the ones that change every
 %loop later)--------------------------------------------------------------
     block_trials = p.block_trials; 
     ao_indices = p.ao_indices;
     reps = p.repetitions;
     num_cond = length(block_trials(:,1)); %number of conditions
     
 
 %Start host and switch to correct directory
 
     connectHost;
     pause(10);
     Panel_com('change_root_directory', p.experiment_folder);
 
 %set active ao channels
     if ~isempty(active_ao_channels)
         aobits = 0;
        for bit = active_ao_channels
            aobits = bitset(aobits,bit+1); %plus 1 bc aochans are 0-3
        end
        Panel_com('set_active_ao_channels', dec2bin(aobits,4));
     end
%confirm start experiment
     start = questdlg('Start Experiment?','Confirm Start','Start','Cancel','Start');
 
     switch start
     
         case 'Cancel'
             disconnectHost;
             return;
         case 'Start' %rest of the code goes under this case
         
%Determine the total number of trials in order to define in what increments 
%the progress bar will progress.-------------------------------------------
            total_num_steps = 0; 
            if pre_start == 1
                total_num_steps = total_num_steps + 1;
            end
            if inter_type == 1
                

                total_num_steps = total_num_steps + reps*(2*num_cond) - 1;
                %2 times length of block_trials = num of block and inter trials in one repetition. 
                %Multiplied by repetitions = total num trials in block section. Minus 1 at 
                %end bc no intertrial after last block trial..

            end
            if post_type == 1
                total_num_steps = total_num_steps + 1;
            end

%Determine how long the experiment will take and update the title of the 
%progress bar to reflect it------------------------------------------------
            total_time = 0; 
            if inter_type == 1
                for i = 1:num_cond
                    total_time = total_time + p.block_trials{i,12} + inter_dur;
                end
                total_time = (total_time * reps) - inter_dur; %bc no intertrial before first rep OR after last rep of the block.
            else
                for i = 1:num_cond
                    total_time = total_time + p.block_trials{i,12};
                end
                total_time = total_time * reps;
            end

            if pre_start == 1
                total_time = total_time + pre_dur;
            end
            if post_type == 1
                total_time = total_time + post_dur;
            end

            axes_label.String = "Estimated experiment duration: " + num2str(total_time/60) + " minutes.";
            
%Will increment this every time a trial is completed to track how far along 
%in the experiment we are-------------------------------------------------
            num_trial_of_total = 0;

%Start log---------------------------------------------------------

             Panel_com('start_log');
             pause(1);

%run pretrial if it exists----------------------------------------

             if pre_start == 1
                 %First update the progress bar to show pretrial is running----
                 progress_axes.Title.String = "Running Pre-trial..."; 
                 num_trial_of_total = num_trial_of_total + 1;
                 progress_bar.YData = num_trial_of_total/total_num_steps;
                 drawnow;

                 Panel_com('set_control_mode',pre_mode);
                 %pause(1);
                 Panel_com('set_pattern_id', pre_pat);
                 %pause(1);
                 %randomize frame index if indicated
                 if pre_frame_ind == 0
                     pre_frame_ind = randperm(p.num_pretrial_frames, 1);
                     %pause(1);
                 end
                 Panel_com('set_position_x',pre_frame_ind);
                 %pause(1);

                 if pre_pos ~= 0
                     Panel_com('set_pattern_func_id', pre_pos);
                     %pause(1);
                 end

                 if ~isempty(pre_gain) %this assumes you'll never have gain without offset
                     Panel_com('set_gain_bias', [pre_gain, pre_offset]);
                     %pause(1);
                 end

                 if pre_mode == 2
                     Panel_com('set_frame_rate', pre_frame_rate);
                     %pause(1);
                 end

                 for i = 1:length(pre_ao_ind)
                     if pre_ao_ind(i) ~= 0 %if it is zero, there was no ao function for this channel
                         Panel_com('set_ao_function_id',[active_ao_channels(i), pre_ao_ind(i)]);%[channel number, index of ao func]
                        %pause(1);
                     end
                 end

                 pause(0.01);
                 Panel_com('start_display', (pre_dur*10));
                 if pre_dur == 0
                     w = waitforbuttonpress;
                 end
                 pause(pre_dur);
             end

%Now set up for block/inter loop --------------------------------------
             %Panel_com('stop_display');
             
             for r = 1:reps
                 for c = 1:num_cond
                     %define which condition we're using
                    cond = p.exp_order(r,c);
                    
                     %Update the progress bar----------------
                    num_trial_of_total = num_trial_of_total + 1;
                    progress_axes.Title.String = "Rep " + r + " of " + reps +...
                        ", Trial " + c + " of " + num_cond + ". Condition number: " + cond;
                    progress_bar.YData = num_trial_of_total/total_num_steps;
                    drawnow;
                    
                    %define parameters for this trial---------
                    trial_mode = block_trials{cond,1};
                    pat_id = p.block_pat_indices(cond);
                    pos_id = p.block_pos_indices(cond);
                    trial_ao_indices = ao_indices(cond,:);
                    
                    if isempty(block_trials{cond,8})
                        frame_ind = 1;
                    elseif strcmp(block_trials{cond,8},'r')
                        frame_ind = 0; %use this later to randomize
                    else
                       frame_ind = str2num(block_trials{cond,8});
                    end
                     
                    frame_rate = block_trials{cond, 9};
                    gain = block_trials{cond, 10};
                    offset = block_trials{cond, 11};
                    dur = block_trials{cond, 12};
                     
                    %Update panel_com-------------------
                    Panel_com('set_control_mode', trial_mode);
                    Panel_com('set_pattern_id', pat_id);
                    if ~isempty(block_trials{cond,10})
                        Panel_com('set_gain_bias', [gain, offset]);
                    end
                    if pos_id ~= 0
                        Panel_com('set_pattern_func_id', pos_id);
                    end
                    if trial_mode == 2
                        Panel_com('set_frame_rate',frame_rate);
                    end

                    Panel_com('set_position_x', frame_ind);
                    for i = 1:length(active_ao_channels)
                        Panel_com('set_ao_function_id',[active_ao_channels(i), trial_ao_indices(i)]);
                    end
                    pause(0.01)
                    
                    %Run block trial----------------------
                    Panel_com('start_display', (dur*10)); %duration expected in 100ms units
                    pause(dur)
                    %Panel_com('stop_display');
                    
                    %Tells loop to skip the intertrial if this is the last iteration of the last rep
                    if r == reps && c == num_cond
   
                        continue 
                    end
                    
        %Run inter-trial assuming there is one--------------------
                    if inter_type == 1
                    
                        %Update progress bar to indicate start of inter-trial
                        num_trial_of_total = num_trial_of_total + 1;
                        progress_axes.Title.String = "Rep " + r + " of " + reps +...
                            ", Trial " + c + " of " + num_cond + "Inter-trial running...";
                        progress_bar.YData = num_trial_of_total/total_num_steps;
                        drawnow;

                        %Run intertrial-------------------------
                        Panel_com('set_control_mode',inter_mode);
                        Panel_com('set_pattern_id', inter_pat);
                        
                        %randomize frame index if indicated
                        if inter_frame_ind == 0
                            inter_frame_ind = randperm(p.num_intertrial_frames, 1);
                        end
                        Panel_com('set_position_x',inter_frame_ind);

                        if inter_pos ~= 0
                            Panel_com('set_pattern_func_id', inter_pos);
                        end

                         if ~isempty(inter_gain) %this assumes you'll never have gain without offset
                             Panel_com('set_gain_bias', [inter_gain, inter_offset]);
                         end

                         if inter_mode == 2
                             Panel_com('set_frame_rate', inter_frame_rate);
                         end

                         for i = 1:length(inter_ao_ind)
                             if inter_ao_ind(i) ~= 0 %if it is zero, there was no ao function for this channel
                                 Panel_com('set_ao_function_id',[active_ao_channels(i), inter_ao_ind(i)]);%[channel number, index of ao func]
                             end
                         end

                         pause(0.01);
                         Panel_com('start_display', (inter_dur*10));
                         pause(inter_dur);
                    end 
                 end
             end
             
%Run post-trial if there is one--------------------------------------------

            if post_type == 1
                
                %Update progress bar------------

                 Panel_com('set_control_mode', post_mode);
                 Panel_com('set_pattern_id', post_pat);
                 if ~isempty(post_gain)
                     Panel_com('set_gain_bias', [post_gain, post_offset]);
                 end
                 if post_pos ~= 0
                     Panel_com('set_pattern_func_id', post_pos);
                 end
                 if post_mode == 2
                     Panel_com('set_frame_rate', post_frame_rate);
                 end
                 Panel_com('set_position_x',post_frame_ind);
                 for i = 1:length(post_ao_ind)
                     if post_ao_ind(i) ~= 0 %if it is zero, there was no ao function for this channel
                         Panel_com('set_ao_function_id',[active_ao_channels(i), post_ao_ind(i)]);%[channel number, index of ao func]
                     end
                 end

                 Panel_com('start_display',post_dur*10);
                 pause(post_dur);
            end
            
            Panel_com('stop_display');
            pause(1);
            Panel_com('stop_log');
            disconnectHost;
            pause(1);



         
     end



end
