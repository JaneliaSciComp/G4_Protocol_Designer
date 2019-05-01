classdef model_class < handle
    %MAIN MODEL with trial data (in the form of cell arrays) and other
    %parameters for submitting a run. 

    properties
%TRIALS
        pretrial_data_
        intertrial_data_
        block_trials_data_
        posttrial_data_
        pretrial_
        block_trials_
        intertrial_
        posttrial_
        
%OTHER PARAMETERS
        
        repetitions_
        is_randomized_
        doc_
        num_rows_
        configData_
        
%CHANNEL INFORMATION
        
        is_chan1_
        chan1_rate_
        is_chan2_
        chan2_rate_
        is_chan3_
        chan3_rate_
        is_chan4_
        chan4_rate_
     
%RUN INFORMATION

        experiment_name_
        %fly_name_
        
    end
    
    properties (Dependent)
        %pretrial_data
        pretrial
        block_trials
        intertrial
        posttrial
        repetitions
        is_randomized
        is_chan1
        chan1_rate
        is_chan2
        chan2_rate
        is_chan3
        chan3_rate
        is_chan4
        chan4_rate
        doc
        num_rows
        configData
        experiment_name
        %fly_name
     
    end
    
    methods
%CONSTRUCTOR (Set defaults here except trial defaults - set those in model_trial)
        function self = model_class()
            self.pretrial_data_ = model_trial() ;

            self.pretrial_ = {self.pretrial_data_.trial_mode_, self.pretrial_data_.pattern_name_, ...
            self.pretrial_data_.position_func_, self.pretrial_data_.ao1_, ...
            self.pretrial_data_.ao2_, self.pretrial_data_.ao3_, self.pretrial_data_.ao4_, ...
            self.pretrial_data_.frame_index_, self.pretrial_data_.frame_rate_, ...
            self.pretrial_data_.gain_, self.pretrial_data_.offset_, ...
            self.pretrial_data_.duration_, self.pretrial_data_.is_checked_};
            
            self.intertrial_data_ = model_trial() ;
            
            self.intertrial_ = {self.intertrial_data_.trial_mode_, self.intertrial_data_.pattern_name_, ...
            self.intertrial_data_.position_func_, self.intertrial_data_.ao1_, ...
            self.intertrial_data_.ao2_, self.intertrial_data_.ao3_, self.intertrial_data_.ao4_, ...
            self.intertrial_data_.frame_index_, self.intertrial_data_.frame_rate_, ...
            self.intertrial_data_.gain_, self.intertrial_data_.offset_, ...
            self.intertrial_data_.duration_, self.intertrial_data_.is_checked_};    
            
            self.block_trials_data_ = model_trial() ;
            
            self.block_trials_ = {self.block_trials_data_.trial_mode_, self.block_trials_data_.pattern_name_, ...
            self.block_trials_data_.position_func_, self.block_trials_data_.ao1_, ...
            self.block_trials_data_.ao2_, self.block_trials_data_.ao3_, self.block_trials_data_.ao4_, ...
            self.block_trials_data_.frame_index_, self.block_trials_data_.frame_rate_, ...
            self.block_trials_data_.gain_, self.block_trials_data_.offset_, ...
            self.block_trials_data_.duration_, self.block_trials_data_.is_checked_};
            
            
            self.posttrial_data_ = model_trial() ;
            
            self.posttrial_ = {self.posttrial_data_.trial_mode_, self.posttrial_data_.pattern_name_, ...
            self.posttrial_data_.position_func_, self.posttrial_data_.ao1_, ...
            self.posttrial_data_.ao2_, self.posttrial_data_.ao3_, self.posttrial_data_.ao4_, ...
            self.posttrial_data_.frame_index_, self.posttrial_data_.frame_rate_, ...
            self.posttrial_data_.gain_, self.posttrial_data_.offset_, ...
            self.posttrial_data_.duration_, self.posttrial_data_.is_checked_};
            
            settings_data = strtrim(regexp( fileread('G4_Protocol_Designer_settings.m'),'\n','split'));
            path_line = find(contains(settings_data,'Configuration File Path:'));
            path_index = strfind(settings_data{path_line},'Path: ');
            path = settings_data{path_line}(path_index+6:end);
            self.configData_ = strtrim(regexp( fileread(path),'\n','split'));
            
            %Find the appropriate lines in configData_ to edit and trim
            %newlines from beginning or end
            
            %number of screen rows
            numRows_line = find(contains(self.configData_,'Number of Rows'));
            %numRows = strtrim(self.configData_{numRows_line});
            self.num_rows_ = str2num(self.configData_{numRows_line}(end));
            
            %channel sample rates
            
            %Find the correct line in the config file for channel 1 sample
            %rate
            
            rate1_line = find(contains(self.configData_,'ADC0'));
            rate1 = strtrim(self.configData_{rate1_line});
            
            %Figure out how many digits are in the last half of this line
            %in the config file, in order to determine the sample rate
            digits1 = isstrprop(rate1,'digit');
            count1 = 0; %the count of 1's in digits, each signifying a number in the rate1 string
            for i = round(length(digits1)/2):length(digits1)
            
                if digits1(i) == 1
                    count1 = count1 + 1;
                end
            
            end
            self.chan1_rate_ = str2num(rate1((end-count1+1):end));
            
            
            rate2_line = find(contains(self.configData_,'ADC1'));
            rate2 = strtrim(self.configData_{rate2_line});
            
            digits2 = isstrprop(rate2,'digit');
            count2 = 0; %the count of 1's in digits, each signifying a number in the rate1 string
            for i = round(length(digits2)/2):length(digits2)
            
                if digits2(i) == 1
                    count2 = count2 + 1;
                end
            
            end
            self.chan2_rate_ = str2num(rate2((end-count2+1):end));
            
            rate3_line = find(contains(self.configData_,'ADC2'));
            rate3 = strtrim(self.configData_{rate3_line});
            
            digits3 = isstrprop(rate3,'digit');
            count3 = 0; %the count of 1's in digits, each signifying a number in the rate1 string
            for i = round(length(digits3)/2):length(digits3)
            
                if digits3(i) == 1
                    count3 = count3 + 1;
                end
            
            end
            
            self.chan3_rate_ = str2num(rate3((end-count3+1):end));
            
            rate4_line = find(contains(self.configData_,'ADC3'));
            rate4 = strtrim(self.configData_{rate4_line});
            
            digits4 = isstrprop(rate4,'digit');
            count4 = 0; %the count of 1's in digits, each signifying a number in the rate1 string
            for i = round(length(digits4)/2):length(digits4)
            
                if digits4(i) == 1
                    count4 = count4 + 1;
                end
            
            end
            
            self.chan4_rate_ = str2num(rate4((end-count4+1):end));
            
            self.repetitions_ = 1;
            self.is_randomized_ = 0;
            self.is_chan1_ = 0;
           
            self.is_chan2_ = 0;
           
            self.is_chan3_ = 0;
            
            self.is_chan4_ = 0;
            
            
            self.experiment_name_ = '';
%            self.fly_name_ = 'Fly Name';
            

            
%             self.doc_ = document();
     
        end
        
        function [index] = get_pattern_index(self, pat_name)
            if strcmp(pat_name,'') == 1
                index = 0;
            else
                fields = fieldnames(self.doc_.Patterns_);
                index = find(strcmp(fields, pat_name));
                
            end    
        end
        
        function [index] = get_posfunc_index(self, pos_name)
            if strcmp(pos_name,'') == 1
                index = 0;
            else
                fields = fieldnames(self.doc_.Pos_funcs_);
                index = find(strcmp(fields, pos_name));
            end
        end
        
        function [index] = get_ao_index(self, ao_name)
            if strcmp(ao_name,'') == 1
                index = 0;
            else
                fields = fieldnames(self.doc_.Ao_funcs_);
                index = find(strcmp(fields, ao_name));
            end
        end
        
        

%SETTERS
        function set_block_trial_property(self, index, new_value)
            if index(1) > size(self.block_trials_,1)
                self.block_trials_ = [self.block_trials_;new_value];
%                 block_data = self.block_trials_;
            
            else

                %If the user edited the pattern or position function, make sure
            %the file dimensions match
                if index(2) == 2 && strcmp(string(new_value),'') == 0
                patfield = new_value;
                patDim = length(self.doc_.Patterns_.(patfield).pattern.Pats(1,1,:));
                patRows = length(self.doc_.Patterns_.(patfield).pattern.Pats(:,1,1))/16;
                numrows = self.get_num_rows();
                    if strcmp(string(self.block_trials_{index(1),3}),'') == 0

                        posfield = self.block_trials_{index(1),3};
                        funcDim = self.doc_.Pos_funcs_.(posfield).pfnparam.frames;

                    else

                        patDim = 0;
                        funcDim = 0;

                    end

                elseif index(2) == 3 && strcmp(string(new_value),'') == 0 && strcmp(string(self.block_trials_{index(1),2}),'') == 0

                    posfield = new_value;
                    patfield = self.block_trials_{index(1),2};
                    patDim = length(self.doc_.Patterns_.(patfield).pattern.Pats(1,1,:));
                    funcDim = self.doc_.Pos_funcs_.(posfield).pfnparam.frames;
                    patRows = 0;
                    numrows = 0;
                else
                    patDim = 0;
                    funcDim = 0;
                    patRows = 0;
                    numrows = 0;
                end

                if patRows ~= numrows
                    waitfor(errordlg("Watch out! This pattern will not run on the size screen you have selected."));
                end
                if patDim ~= funcDim
                     waitfor(errordlg("Please make sure the dimension of your pattern and position functions match"));
                else

                     self.block_trials_{index(1), index(2)} = new_value;
                end
            end
        end
  
        
        function set_pretrial_property(self, index, new_value)
            %If the user edited the pattern or position function, make sure
            %the file dimensions match
            
            if index == 2 && strcmp(string(new_value),'') == 0
                patfield = new_value;
                patDim = length(self.doc_.Patterns_.(patfield).pattern.Pats(1,1,:));
                patRows = length(self.doc_.Patterns_.(patfield).pattern.Pats(:,1,1))/16;
                numrows = self.get_num_rows();
                if strcmp(string(self.pretrial_{3}),'') == 0
                    
                    posfield = self.pretrial_{3};
                    funcDim = self.doc_.Pos_funcs_.(posfield).pfnparam.frames;
                    
                else
                    
                    patDim = 0;
                    funcDim = 0;
                    
                end
                    
            elseif index == 3 && strcmp(string(new_value),'') == 0 && strcmp(string(self.pretrial_{2}),'') == 0

                posfield = new_value;
                patfield = self.pretrial_{2};
                patDim = length(self.doc_.Patterns_.(patfield).pattern.Pats(1,1,:));
                funcDim = self.doc_.Pos_funcs_.(posfield).pfnparam.frames;
                patRows = 0;
                numrows = 0;
            else
                patDim = 0;
                funcDim = 0;
                patRows = 0;
                numrows = 0;
            end
            
            if patRows ~= numrows
                waitfor(errordlg("Watch out! This pattern will not run on the size screen you have selected."));
            end

            if patDim ~= funcDim
                 waitfor(errordlg("Please make sure the dimension of your pattern and position functions match"));
            else

            self.pretrial_{index} =  new_value ;

            end
            
        end
        
        function set_intertrial_property(self, index, new_value)
%             %If the user edited the pattern or position function, make sure
            %the file dimensions match
           if index == 2 && strcmp(string(new_value),'') == 0
                patfield = new_value;
                patDim = length(self.doc_.Patterns_.(patfield).pattern.Pats(1,1,:));
                patRows = length(self.doc_.Patterns_.(patfield).pattern.Pats(:,1,1))/16;
                numrows = self.get_num_rows();
                if strcmp(string(self.intertrial_{3}),'') == 0
                    
                    posfield = self.intertrial_{3};
                    funcDim = self.doc_.Pos_funcs_.(posfield).pfnparam.frames;
                    
                else
                    
                    patDim = 0;
                    funcDim = 0;
                    
                end
                    
            elseif index == 3 && strcmp(string(new_value),'') == 0 && strcmp(string(self.intertrial_{2}),'') == 0

                posfield = new_value;
                patfield = self.intertrial_{2};
                patDim = length(self.doc_.Patterns_.(patfield).pattern.Pats(1,1,:));
                funcDim = self.doc_.Pos_funcs_.(posfield).pfnparam.frames;
                patRows = 0;
                numrows = 0;
            else
                patDim = 0;
                funcDim = 0;
                patRows = 0;
                numrows = 0;
            end
            
            if patRows ~= numrows
                waitfor(errordlg("Watch out! This pattern will not run on the size screen you have selected."));
            end

            if patDim ~= funcDim
                 waitfor(errordlg("Please make sure the dimension of your pattern and position functions match"));
            else
            self.intertrial_{index} =  new_value ;
            end
       
%             end
        end
        
        function set_posttrial_property(self, index, new_value)

            %If the user edited the pattern or position function, make sure
            %the file dimensions match
            if index == 2 && strcmp(string(new_value),'') == 0
                patfield = new_value;
                patDim = length(self.doc_.Patterns_.(patfield).pattern.Pats(1,1,:));
                patRows = length(self.doc_.Patterns_.(patfield).pattern.Pats(:,1,1))/16;
                numrows = self.get_num_rows();
                if strcmp(string(self.posttrial_{3}),'') == 0
                    
                    posfield = self.posttrial_{3};
                    funcDim = self.doc_.Pos_funcs_.(posfield).pfnparam.frames;
                    
                else
                    
                    patDim = 0;
                    funcDim = 0;
                    
                end
                    
            elseif index == 3 && strcmp(string(new_value),'') == 0 && strcmp(string(self.posttrial_{2}),'') == 0

                posfield = new_value;
                patfield = self.posttrial_{2};
                patDim = length(self.doc_.Patterns_.(patfield).pattern.Pats(1,1,:));
                funcDim = self.doc_.Pos_funcs_.(posfield).pfnparam.frames;
                patRows = 0;
                numrows = 0;
            else
                patDim = 0;
                funcDim = 0;
                patRows = 0;
                numrows = 0;
            end
            
            if patRows ~= numrows
                waitfor(errordlg("Watch out! This pattern will not run on the size screen you have selected."));
            end

            if patDim ~= funcDim
                 waitfor(errordlg("Please make sure the dimension of your pattern and position functions match"));
            else
            self.posttrial_{index} =  new_value ;
            end

        end
        
        function set_repetitions(self, new_value)
            self.repetitions_ = new_value ;           
        end
        
        function set_is_randomized(self, new_value)
            self.is_randomized_ = new_value;
        end
        
        function set_is_chan1(self, new_value)
            self.is_chan1_ = new_value;
        end
        
        function set_chan1_rate(self, new_value)
            self.chan1_rate_ = new_value;
        end
        
        function set_is_chan2(self, new_value)
            self.is_chan2_ = new_value;
        end
        
        function set_chan2_rate(self, new_value)
            self.chan2_rate_ = new_value;
        end
        
        function set_is_chan3(self, new_value)
            self.is_chan3_ = new_value;
        end
        
        function set_chan3_rate(self, new_value)
            self.chan3_rate_ = new_value;
        end
        
        function set_is_chan4(self, new_value)
            self.is_chan4_ = new_value;
        end
        
        function set_chan4_rate(self, new_value)
            self.chan4_rate_ = new_value;
        end
        
        function set_doc(self, new_value)
            self.doc_ = new_value;
        end
        
        function set_num_rows(self, new_value)
            self.num_rows_ = new_value;
        end
        
        function set_config_data(self, new_value, channel)
            
             if channel == 1
                newline = strcat("ADC0 Rate (Hz) = ", num2str(new_value));
                rate1_line = find(contains(self.configData_,'ADC0'));
                self.configData_{rate1_line} = newline;
                self.configData_{rate1_line} = convertStringsToChars(self.configData_{rate1_line});
                
            end
            
            if channel == 2
                newline = strcat("ADC1 Rate (Hz) = ", num2str(new_value));
                rate2_line = find(contains(self.configData_,'ADC1'));
                
                self.configData_{rate2_line} = newline;
                
                self.configData_{rate2_line} = convertStringsToChars(self.configData_{rate2_line});

          
            end
            
            
            if channel == 3
                newline = strcat("ADC2 Rate (Hz) = ", num2str(new_value));
                rate3_line = find(contains(self.configData_,'ADC2'));
                self.configData_{rate3_line} = newline;

                self.configData_{rate3_line} = convertStringsToChars(self.configData_{rate3_line});
            end
            
            if channel == 4
                newline = strcat("ADC3 Rate (Hz) = ", num2str(new_value));
                rate4_line = find(contains(self.configData_,'ADC3'));
                self.configData_{rate4_line} = newline;
                
                self.configData_{rate4_line} = convertStringsToChars(self.configData_{rate4_line});

            end
            
            if channel == 0

                newline = strcat("Number of Rows = ", num2str(new_value));
                numRows_line = find(contains(self.configData_,'Number of Rows'));
                self.configData_{numRows_line} = newline;
                
                self.configData_{numRows_line} = convertStringsToChars(self.configData_{numRows_line});

            end
            
            
        end
        
        function set_experiment_name(self, new_value)
            self.experiment_name_ = new_value;
        end
        
%         function set_fly_name(self, new_value)
%             self.fly_name_ = new_value;
%         end
        
        
        
%GETTERS        
        
        function output = get_pretrial(self)
            output = self.pretrial_;
        end
        
        function output = get_block_trials(self)
            output = self.block_trials_;
        end
        
        function output = get_intertrial(self)
            output = self.intertrial_;
        end
        
        function output = get_posttrial(self)
            output = self.posttrial_;
        end
        
        function output = get_repetitions(self)
            output = self.repetitions_;
        end
        
        function output = get_is_randomized(self)
            output = self.is_randomized_;
        end
        
        function output = get_is_chan1(self)
            output = self.is_chan1_;
        end
        
        function output = get_chan1_rate(self)
            output = self.chan1_rate_;
        end
        
        function output = get_is_chan2(self)
            output = self.is_chan2_;
        end
        
        function output = get_chan2_rate(self)
            output = self.chan2_rate_;
        end
        
        function output = get_is_chan3(self)
            output = self.is_chan3_;
        end
        
        function output = get_chan3_rate(self)
            output = self.chan3_rate_;
        end
        
        function output = get_is_chan4(self)
            output = self.is_chan4_;
        end
        
        function output = get_chan4_rate(self)
           output = self.chan4_rate_;
        end
        
        function output = get_doc(self)
            output = self.doc_;
        end
        
        function output = get_num_rows(self)
            output = self.num_rows_;
        end
        
        function output = get_config_data(self)
            output = self.configData_;
        end
        
        function output = get_experiment_name(self)
            output = self.experiment_name_;
        end
        
%         function output = get_fly_name(self)
%             output = self.fly_name_;
%         end
        
        
        

    end
end

