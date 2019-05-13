classdef document < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        top_folder_path_
        top_export_path_
        Patterns_
        Pos_funcs_
        Ao_funcs_
        save_filename_
        currentExp_
        experiment_name_
        
        %Variables saved to .g4p files
        pretrial_
        block_trials_
        intertrial_
        posttrial_
        repetitions_
        is_randomized_
        num_rows_
        is_chan1_
        chan1_rate_
        is_chan2_
        chan2_rate_
        is_chan3_
        chan3_rate_
        is_chan4_
        chan4_rate_
        trial_data
        
        %Data to save to configuration file
        configData_
        
    end
    
    
    properties (Dependent)
        top_folder_path
        top_export_path
        Patterns
        Pos_funcs
        Ao_funcs
        save_filename
        currentExp
        experiment_name
        
        pretrial
        block_trials
        intertrial
        posttrial
        repetitions
        is_randomized
        num_rows
        is_chan1
        chan1_rate
        is_chan2
        chan2_rate
        is_chan3
        chan3_rate
        is_chan4
        chan4_rate
        
        configData
        
    end
    
    methods

%CONSTRUCTOR--------------------------------------------------------------        
        function self = document()

%Set these properties to empty values until they are needed
            
            self.top_folder_path = '';
            self.top_export_path = '';
            self.Patterns = struct;
            self.Pos_funcs = struct;
            self.Ao_funcs = struct;
            self.save_filename = '';
            self.currentExp = struct;
            self.experiment_name = '';
            self.trial_data = model_trial();
            
%Make table parameters into a cell array so they work with the tables more easily

            self.pretrial = self.trial_data.trial_array;
            self.intertrial = self.trial_data.trial_array;
            self.block_trials = self.trial_data.trial_array;
            self.posttrial = self.trial_data.trial_array;
            
%Get the path to the configuration file from settings and set the config data to the data within the configuration file

            settings_data = strtrim(regexp( fileread('G4_Protocol_Designer_settings.m'),'\n','split'));
            path_line = find(contains(settings_data,'Configuration File Path:'));
            path_index = strfind(settings_data{path_line},'Path: ');
            path = settings_data{path_line}(path_index+6:end);
            self.configData = strtrim(regexp( fileread(path),'\n','split'));
            
            %Find the appropriate lines in configData to edit
            
%Determine number of screen rows-------------------------------------------
            numRows_line = find(contains(self.configData,'Number of Rows'));
            self.num_rows = str2num(self.configData{numRows_line}(end));
            
%Determine channel sample rates--------------------------------------------

            rate1_line = find(contains(self.configData,'ADC0'));
            rate1 = strtrim(self.configData{rate1_line});
            
            %Figure out how many digits are in the last half of this line
            %in the config file, in order to determine the sample rate
            
            digits1 = isstrprop(rate1,'digit');
            count1 = 0; %the count of 1's in digits, each signifying a number in the rate1 string
            
            %Only look at the last half of digits, meaning only numbers in
            %the last half of the line. This way numbers in the title don't skew results (ie,
            %in ACD0 Rate (Hz) = 1000 we want to ignore the first 0)
            
            for i = round(length(digits1)/2):length(digits1)
            
                if digits1(i) == 1
                    count1 = count1 + 1;
                end
            
            end
            self.chan1_rate = str2num(rate1((end-count1+1):end));
            
%Do the same for channels 2, 3, and 4--------------------------------------

            rate2_line = find(contains(self.configData,'ADC1'));
            rate2 = strtrim(self.configData{rate2_line});
            
            digits2 = isstrprop(rate2,'digit');
            count2 = 0; %the count of 1's in digits, each signifying a number in the rate1 string
            for i = round(length(digits2)/2):length(digits2)
            
                if digits2(i) == 1
                    count2 = count2 + 1;
                end
            
            end
            self.chan2_rate = str2num(rate2((end-count2+1):end));
            
            rate3_line = find(contains(self.configData,'ADC2'));
            rate3 = strtrim(self.configData{rate3_line});
            
            digits3 = isstrprop(rate3,'digit');
            count3 = 0; %the count of 1's in digits, each signifying a number in the rate1 string
            for i = round(length(digits3)/2):length(digits3)
            
                if digits3(i) == 1
                    count3 = count3 + 1;
                end
            
            end
            
            self.chan3_rate = str2num(rate3((end-count3+1):end));
            
            rate4_line = find(contains(self.configData,'ADC3'));
            rate4 = strtrim(self.configData{rate4_line});
            
            digits4 = isstrprop(rate4,'digit');
            count4 = 0; %the count of 1's in digits, each signifying a number in the rate1 string
            for i = round(length(digits4)/2):length(digits4)
            
                if digits4(i) == 1
                    count4 = count4 + 1;
                end
            
            end
            
             self.chan4_rate = str2num(rate4((end-count4+1):end));
            
            self.repetitions = 1;
            self.is_randomized = 0;
            self.is_chan1 = 0;
           
            self.is_chan2 = 0;
           
            self.is_chan3 = 0;
            
            self.is_chan4 = 0;
        
        end
        
%SETTING INDIVIDUAL TRIAL PROPERTIES---------------------------------------

        function set_block_trial_property(self, index, new_value)
            
%Adding a new row

            if index(1) > size(self.block_trials,1)
                self.block_trials = [self.block_trials;new_value];
%                 block_data = self.block_trials;
            
            else

%If the user edited the pattern or position function, make sure the file dimensions match

                if index(2) == 2 && strcmp(string(new_value),'') == 0
                    patfield = new_value;
                    patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                    patRows = length(self.Patterns.(patfield).pattern.Pats(:,1,1))/16;
                    numrows = self.num_rows;
                
                    if strcmp(string(self.block_trials{index(1),3}),'') == 0

                        posfield = self.block_trials{index(1),3};
                        funcDim = self.Pos_funcs.(posfield).pfnparam.frames;

                    else

                        patDim = 0;
                        funcDim = 0;

                    end

                elseif index(2) == 3 && strcmp(string(new_value),'') == 0 && strcmp(string(self.block_trials{index(1),2}),'') == 0

                    posfield = new_value;
                    patfield = self.block_trials{index(1),2};
                    patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                    funcDim = self.Pos_funcs.(posfield).pfnparam.frames;
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
                    
%Set value
                     self.block_trials{index(1), index(2)} = new_value;
                end
            end
        end
        
%%%%%%%%%%%%%%%%%%%Consider making the dimension checking a single separate
%%%%%%%%%%%%%%%%%%%function

%Same as above for pretrial, intertrial, and posttrial

        function set_pretrial_property(self, index, new_value)
            %If the user edited the pattern or position function, make sure
            %the file dimensions match
            
            if index == 2 && strcmp(string(new_value),'') == 0
                patfield = new_value;
                patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                patRows = length(self.Patterns.(patfield).pattern.Pats(:,1,1))/16;
                numrows = self.num_rows;
                if strcmp(string(self.pretrial{3}),'') == 0
                    
                    posfield = self.pretrial{3};
                    funcDim = self.Pos_funcs.(posfield).pfnparam.frames;
                    
                else
                    
                    patDim = 0;
                    funcDim = 0;
                    
                end
                    
            elseif index == 3 && strcmp(string(new_value),'') == 0 && strcmp(string(self.pretrial{2}),'') == 0

                posfield = new_value;
                patfield = self.pretrial{2};
                patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                funcDim = self.Pos_funcs.(posfield).pfnparam.frames;
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

            self.pretrial{index} =  new_value ;

            end
            
        end
        
        function set_intertrial_property(self, index, new_value)
%             %If the user edited the pattern or position function, make sure
            %the file dimensions match
           if index == 2 && strcmp(string(new_value),'') == 0
                patfield = new_value;
                patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                patRows = length(self.Patterns.(patfield).pattern.Pats(:,1,1))/16;
                numrows = self.num_rows;
                if strcmp(string(self.intertrial{3}),'') == 0
                    
                    posfield = self.intertrial{3};
                    funcDim = self.Pos_funcs.(posfield).pfnparam.frames;
                    
                else
                    
                    patDim = 0;
                    funcDim = 0;
                    
                end
                    
            elseif index == 3 && strcmp(string(new_value),'') == 0 && strcmp(string(self.intertrial{2}),'') == 0

                posfield = new_value;
                patfield = self.intertrial{2};
                patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                funcDim = self.Pos_funcs.(posfield).pfnparam.frames;
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
            self.intertrial{index} =  new_value ;
            end
       
%             end
        end
        
        function set_posttrial_property(self, index, new_value)

            %If the user edited the pattern or position function, make sure
            %the file dimensions match
            if index == 2 && strcmp(string(new_value),'') == 0
                patfield = new_value;
                patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                patRows = length(self.Patterns.(patfield).pattern.Pats(:,1,1))/16;
                numrows = self.num_rows;
                if strcmp(string(self.posttrial{3}),'') == 0
                    
                    posfield = self.posttrial{3};
                    funcDim = self.Pos_funcs.(posfield).pfnparam.frames;
                    
                else
                    
                    patDim = 0;
                    funcDim = 0;
                    
                end
                    
            elseif index == 3 && strcmp(string(new_value),'') == 0 && strcmp(string(self.posttrial{2}),'') == 0

                posfield = new_value;
                patfield = self.posttrial{2};
                patDim = length(self.Patterns.(patfield).pattern.Pats(1,1,:));
                funcDim = self.Pos_funcs.(posfield).pfnparam.frames;
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
            self.posttrial{index} =  new_value ;
            end

        end
        
%SET THE CONFIGURATION FILE DATA-------------------------------------------

        function set_config_data(self, new_value, channel)
            
             if channel == 1
                newline = strcat("ADC0 Rate (Hz) = ", num2str(new_value));
                rate1_line = find(contains(self.configData,'ADC0'));
                self.configData{rate1_line} = newline;
                self.configData{rate1_line} = convertStringsToChars(self.configData{rate1_line});
                
            end
            
            if channel == 2
                newline = strcat("ADC1 Rate (Hz) = ", num2str(new_value));
                rate2_line = find(contains(self.configData,'ADC1'));
                self.configData{rate2_line} = newline;
                self.configData{rate2_line} = convertStringsToChars(self.configData{rate2_line});

            end
            
            if channel == 3
                newline = strcat("ADC2 Rate (Hz) = ", num2str(new_value));
                rate3_line = find(contains(self.configData,'ADC2'));
                self.configData{rate3_line} = newline;
                self.configData{rate3_line} = convertStringsToChars(self.configData{rate3_line});
            end
            
            if channel == 4
                newline = strcat("ADC3 Rate (Hz) = ", num2str(new_value));
                rate4_line = find(contains(self.configData,'ADC3'));
                self.configData{rate4_line} = newline;               
                self.configData{rate4_line} = convertStringsToChars(self.configData{rate4_line});

            end
            
            if channel == 0

                newline = strcat("Number of Rows = ", num2str(new_value));
                numRows_line = find(contains(self.configData,'Number of Rows'));
                self.configData{numRows_line} = newline; 
                self.configData{numRows_line} = convertStringsToChars(self.configData{numRows_line});

            end
            
            
        end
       
        
%EXPORT--------------------------------------------------------------------        
       function [export_successful] = export(self)
           

            Exppath = self.top_export_path;


            [Expstatus, Expmsg] = mkdir(Exppath);
            patpath = fullfile(Exppath,'Patterns');
            [patstatus, patmsg] = mkdir(patpath);
            funcpath = fullfile(Exppath, 'Functions');
            [funcstatus, funcmsg] = mkdir(funcpath);
            aopath = fullfile(Exppath, 'Analog Output Functions');
            [aostatus, aomsg] = mkdir(aopath);
            
            if Expstatus == 0
                waitfor(errordlg(Expmsg));
                export_successful = 0;
            
            elseif patstatus == 0
                waitfor(errordlg(patmsg));
                export_successful = 0;
            
            elseif funcstatus == 0
                waitfor(errordlg(funcmsg));
                export_successful = 0;
            elseif aostatus == 0
                waitfor(errordlg(aomsg));
                export_successful = 0;
            else
                
                %Get pattern names actually used in experiment
                %%%%%%%%%%SEPARATE THIS INTO ITS OWN FUNCTION LATER
               pat_list = { };
               func_list = { };
               ao_list = { };
               
               func_count = 1;
               ao_count = 1;
               for i = 1:length(self.block_trials(:,1))
                    
                    pat_list{i} = self.block_trials{i,2};
                    if strcmp(self.block_trials{i,3},'') == 0
                        func_list{func_count} = self.block_trials{i,3};
                        func_count = func_count + 1;
                    end
                    if strcmp(self.block_trials{i,4},'') == 0
                        ao_list{ao_count} = self.block_trials{i,4};
                        ao_count = ao_count + 1;
                    end
                    if strcmp(self.block_trials{i,5},'') == 0
                        ao_list{ao_count} = self.block_trials{i,5};
                        ao_count = ao_count + 1;
                    end
                    if strcmp(self.block_trials{i, 6},'') == 0
                        ao_list{ao_count} = self.block_trials{i,6};
                        ao_count = ao_count + 1;
                    end
                    if strcmp(self.block_trials{i,7},'') == 0
                        ao_list{ao_count} = self.block_trials{i,7};
                        ao_count = ao_count + 1;
                    end
               end

               pat_list{end + 1} = self.pretrial{2};
               pat_list{end + 1} = self.posttrial{2};
               pat_list{end + 1} = self.intertrial{2};
               
               if strcmp(self.pretrial{3},'') == 0
                   func_list{end+1} = self.pretrial{3};
               end
               if strcmp(self.posttrial{3},'') == 0
                   func_list{end+1} = self.posttrial{3};
               end
               if strcmp(self.intertrial{3},'') == 0
                   func_list{end+1} = self.intertrial{3};
               end
               
               for i = 4:7
                   if strcmp(self.pretrial{i},'') == 0
                       ao_list{end+1} = self.pretrial{i};
                   end
               end
               for i = 4:7
                   if strcmp(self.posttrial{i},'') == 0
                       ao_list{end+1} = self.posttrial{i};
                   end
               end
               for i = 4:7
                   if strcmp(self.intertrial{i},'') == 0
                       ao_list{end+1} = self.intertrial{i};
                   end
               end

               if exist('func_list') ~= 0

                    func_list = unique(func_list);
                    empty_cells = cellfun(@isempty, func_list);
                    for i = 1:length(empty_cells)
                        if empty_cells(i) == 1
                            func_list(i) = [];
                        end
                    end

                    num_funcs = length(func_list);
                    pfnList = {};
                    for m = 1:num_funcs
                        field = func_list{m};
                        filename = strcat(field, '.mat');
                        filepath = fullfile(funcpath, filename);
                        pfnparam = self.Pos_funcs.(field).pfnparam;
                        save(filepath, 'pfnparam');
                        
                        num = regexp(filename,'\_','split');
                        pfnName = strcat('fun',num{2},'.pfn');
                        pfnList{m} = pfnName;
                        func_folder = fullfile(self.top_folder_path, 'Functions');
                        pfnFilePath = fullfile(func_folder,pfnName);
                        if ~isfile(pfnFilePath)
                            errordlg(pfnFilePath + " does not exist in your imported directory. If you imported this .mat file separately, please move its associated .pfn file manually to your exported folder.");
                        else
                            pfnNewFilePath = fullfile(funcpath, pfnName);

                            pfn = fopen(pfnFilePath);
                            pfnData = fread(pfn);
                            newpfn = fopen(pfnNewFilePath, 'w');
                            fwrite(newpfn, pfnData);
                            fclose(pfn);
                            fclose(newpfn);
                        end
                
                    end
               end
               afnList = {};
               if exist('ao_list') ~= 0
                   ao_list = unique(ao_list);
                   empty_aocells = cellfun(@isempty, ao_list);
                    for i = 1:length(empty_aocells)
                        if empty_aocells(i) == 1
                            ao_list(i) = [];
                        end
                    end
                   num_ao = length(ao_list);
                   for n = 1:num_ao
                    
                        field = ao_list{n};
                        filename = strcat(field, '.mat');
                        filepath = fullfile(aopath, filename);
                        afnparam = self.Ao_funcs.(field).afnparam;
                        save(filepath, 'afnparam');
                        
                        num = regexp(filename,'\_','split');
                        afnName = strcat('ao',num{2},'.afn');
                        afnList{n} = afnName;
                        ao_folder = fullfile(self.top_folder_path, 'Analog Output Functions');
                        afnFilePath = fullfile(ao_folder,afnName);
                        if ~isfile(afnFilePath)
                            errordlg(afnFilePath + " does not exist in your imported directory. If you imported this .mat file separately, please move its associated .afn file to your exported folder manually.");
                        else
                            afnNewFilePath = fullfile(aopath, afnName);
                            afn = fopen(afnFilePath);
                            afnData = fread(afn);
                            newafn = fopen(afnNewFilePath, 'w');
                            fwrite(newafn, afnData);
                            fclose(afn);
                            fclose(newafn);
                        end
                
                   end
               end
                              
               pat_list = unique(pat_list);
               empty_patcells = cellfun(@isempty, pat_list);
                    for i = 1:length(empty_patcells)
                        if empty_patcells(i) == 1
                            pat_list(i) = [];
                        end
                    end
               patternList = { };
               pattNames = {};
               
               num_pats = length(pat_list);
               for k = 1:num_pats
                    
                    field = pat_list{k};
                    pattNames{k} = field;
                    filename = strcat(field,'.mat');
                    filepath = fullfile(patpath, filename);
                    pattern = self.Patterns.(field).pattern;
                    save(filepath, 'pattern');
                    
                    num = regexp(filename,'\_','split');
                    patname = strcat(num{2},'.pat'); 
                    patternList{k} = patname;
                    patfilepath = fullfile(patpath, patname);
                    imported_patfilepath = fullfile(self.top_folder_path, 'Patterns', patname);
                    if ~isfile(imported_patfilepath)
                        errordlg(imported_patfilepath + " does not exist in your imported directory. If you imported this item separately, please move it to your exported folder manually.");
                    else
                        pat = fopen(imported_patfilepath);
                        patData = fread(pat);
                        fileID = fopen(patfilepath,'w');
                        fwrite(fileID, patData);
                        fclose(pat);
                        fclose(fileID);
                    end

               end

%                 
                %Initialize entire currentExp structure so fields do not
                %get out of order
                
               currentExp.pattern.pattNames = { };
               currentExp.pattern.patternList = { };
               currentExp.pattern.x_num = [];
               currentExp.pattern.y_num = [];
               currentExp.pattern.gs_val = [];
               currentExp.pattern.arena_pitch = [];
               currentExp.pattern.num_patterns = 0;
               
               currentExp.function.functionName = {};
               currentExp.function.functionList = {};
               currentExp.function.functionSize = [];
               currentExp.function.numFunc = 0;
               
               
               currentExp.aoFunction.aoFunctionName = {};
               currentExp.aoFunction.aoFunctionList = {};
               currentExp.aoFunction.aoFunctionSize = [];
               currentExp.aoFunction.numaoFunc = 0;
               
               
               %Develop currentExp file from values in the used patterns,
               %funcs, and aofuncs
               
               %currentExp.pattern
                for j = 1:num_pats
                    field = pat_list{j};
                    currentExp.pattern.x_num(j) = self.Patterns.(field).pattern.x_num;
                    currentExp.pattern.y_num(j) = self.Patterns.(field).pattern.y_num;
                    currentExp.pattern.gs_val(j) = self.Patterns.(field).pattern.gs_val;
                    currentExp.pattern.arena_pitch(j) = self.Patterns.(field).pattern.param.arena_pitch;
                    pat_list{j} = strcat(field, '.mat');
                    
                end
                currentExp.pattern.pattNames = pattNames;
                currentExp.pattern.patternList = patternList;%list of .pat files
                currentExp.pattern.num_patterns = num_pats;
                
                %currentExp.function
                if exist('func_list')~= 0
                    for k = 1:num_funcs
                        field = func_list{k};
                        currentExp.function.functionSize{k} = self.Pos_funcs.(field).pfnparam.size;
                        func_list{k} = strcat(field, '.mat');
                        currentExp.function.functionName{k} = func_list{k};
                    end
                   % currentExp.function.functionName = num2cell(func_list);
                    currentExp.function.functionList = pfnList;%.pfn files
                    currentExp.function.numFunc = num_funcs;
                end
                
                if exist('ao_list')~= 0
                    for p = 1:num_ao
                        field = ao_list{p};
                        currentExp.aoFunction.aoFunctionSize{p} = self.Ao_funcs.(field).afnparam.size;  
                        ao_list{p} = strcat(field, '.mat');
                    end
                    currentExp.aoFunction.aoFunctionName = ao_list;
                    currentExp.aoFunction.aoFunctionList = afnList;%.afn files
                    currentExp.aoFunction.numaoFunc = num_ao;
                end
                

                
                currentExpFile = 'currentExp.mat';
                filepath = fullfile(Exppath, currentExpFile);

                save(filepath, 'currentExp');
                
                export_successful = 1;
               
                
                
            end
            
            end
        
        
        function [opened_data] = open(self, filepath)
            
  
            opened_data = load(filepath, '-mat');
   
        end
        
        function saveas(self, path, prog)
            
            homemade_ext = '.g4p';

        %Replace .mat extension with homemade one
            
            [savepath, name, ext] = fileparts(path);
            savename = strcat(name, homemade_ext);
            self.top_export_path = fullfile(savepath, self.experiment_name);
        %Get path to file you want to save including new extension    
            save_file = fullfile(self.top_export_path, savename);
            self.save_filename = save_file;
            if isfile(save_file)
                question = 'This file already exists. Are you sure you want to replace it?';
                replace = questdlg(question);
                
                if strcmp(replace, 'Yes') == 1
                    confirm = strcat('Are you sure you want to replace ', savename, '?');
                    confirmation = questdlg(confirm);
                    if strcmp(confirmation,'Yes') == 1

                        recycle('on');
                        delete(save_file);
                        temp_path = strcat(self.top_export_path, 'temp');
                        movefile(self.top_export_path, temp_path);
                        self.top_folder_path = temp_path;
                        
                    else
                        return;
                    end
                else
                    return;
                end
                
            else
                
                temp_path = '';

            end
            waitbar(.5, prog, 'Exporting...');
            export_successful = self.export();% 0 - export was unable to complete 1- export completed successfully 2-user canceled and export not attempted
            if export_successful == 0
                waitfor(errordlg("Export was unsuccessful. Please delete files to be overwritten manually and try again."));
                return;
                
            elseif export_successful == 2
                return;

            else
                exp_parameters = self.create_parameters_structure();
                save(self.save_filename, 'exp_parameters');
                if strcmp(temp_path,'') == 0
                    rmdir(temp_path,'s');
                end
            end
            waitbar(1, prog, 'Save Successful');
            close(prog);
            
        end
        
        function save(self)
            
            if isempty(self.save_filename) == 1
                waitfor(errordlg("You have not yet saved a new file. Please use 'save as'"));
            else
                export_successful = self.export();
                if export_successful == 0
                    waitfor(errordlg("Export was unsuccessful. Please delete folders to be replaced and use save as."));
                    
                elseif export_successful == 2
                    
                    return;
                else
                exp_parameters = self.create_parameters_structure();
                save(self.save_filename, 'exp_parameters');
                end                
            end
            
            
            
        end
 
%Import a file, called from controller when a file instead of folder is imported------------------------------------------------------
        function import_file(self, file, path)

            file_full = fullfile(path, file);
            [filepath, name, ext] = fileparts(file_full);
            
            if strcmp(ext, '.mat') == 0
                
                waitfor(errordlg("Please make sure you are importing a .mat file"));
            
            elseif strncmp(file, 'Pattern', 7) == 1
                
                if isfield(self.Patterns, name) == 1
                    waitfor(errordlg("A pattern of that name has already been imported."));
                    return;
                else
                    self.Patterns.(name) = load(file_full);

                    
                end
                %add to Patterns
                
            elseif strncmp(file, 'FunctionAO', 10) == 1
                
                if isfield(self.Ao_funcs, name) == 1
                    waitfor(errordlg("An Analog Output Function of that name has already been imported."));
                else
                    self.Ao_funcs.(name) = load(file_full);
                end
                
                %add to ao functions
                
            elseif strncmp(file, 'Function', 8) == 1
                
                if isfield(self.Pos_funcs, name) == 1
                    waitfor(errordlg("A Position Function of that name has already been imported."));
                else
                    self.Pos_funcs.(name) = load(file_full);
                end
                %add to pos funcs
                
            else
                
                waitfor(errordlg("Please make sure your file matches one of the following patterns: Pattern * .mat, FunctionAO * .mat, or Function * .mat"));
            
            end
        
        end
        
%Import an EXPERIMENT folder, called from import_folder after determining it's an experiment folder -----------------------------------------------------        
        function [imported_message] = import_experiment_folder(self, path)
            
            self.top_folder_path = path;
            pat_folder = fullfile(self.top_folder_path, 'Patterns');
            pos_folder = fullfile(self.top_folder_path, 'Functions');
            ao_folder = fullfile(self.top_folder_path, 'Analog Output Functions');
            currentExp_path = fullfile(self.top_folder_path, 'currentExp.mat');
            
            [partialpath, name] = fileparts(self.top_folder_path);
            self.experiment_name = name;
            
            if ~isfolder(pat_folder)
                waitfor(errordlg("Cannot find a Patterns folder. No patterns will be imported."));
                pat_folder = 0;
            end
            if ~isfolder(pos_folder)
                waitfor(errordlg("Cannot find a Functions folder. No position functions will be imported."));
                pos_folder = 0;
            end
            if ~isfolder(ao_folder)
                waitfor(errordlg("Cannot find an Analog Output Functions folder. No ao functions will be imported."));
                ao_folder = 0;
            end
            
            if isempty(fieldnames(self.currentExp))
                currentExp_replaced = 0;
                self.currentExp = load(currentExp_path);
            else
                currentExp_replaced = 1;
                self.currentExp = load(currentExp_path);
            end
            %self.save_filename = '';
            
            if pat_folder == 0
                %do nothing
            else 
                [pats_failed, pats_imported] = self.import_pattern_folder(pat_folder);
            end
            
            if pos_folder == 0
                %do nothing
            else
               [pos_failed, pos_imported] = self.import_function_folder(pos_folder);
            end
            
            if ao_folder == 0
                %do nothing
            else
               [ao_failed, ao_imported] = self.import_ao_folder(ao_folder);
            end
            
            imported_message = pats_imported + " patterns imported, " + pos_imported + " functions imported, and " + ao_imported + " AO functions imported." ...
                + newline + pats_failed + " patterns failed, " + pos_failed + " functions failed, and " + ao_failed + " AO functions failed.";
            if currentExp_replaced == 1
                imported_message = imported_message + newline + "1 currentExp file imported and replaced previous currentExp file.";
            else
                imported_message = imported_message + newline + "1 currentExp file imported.";
            end
            
            
        end
            
%Import a PATTERN folder, called from import_folder after determining the folder is a pattern folder, or from import_experiment_folder--------------
            
        function [pats_failed, pats_imported] = import_pattern_folder(self, pat_folder)
            %pull all .mat filenames out of Patterns folder and make a
            %list of them

            %establishes what type of files I want to pull, *.mat
            pats_failed = 0;
            pats_imported= 0;
            pat_file_pattern = sprintf('%s/*.mat', pat_folder);

            %takes all contents from pat_folder that match
            %pat_file_pattern and makes a list of them called
            %all_pattern_files
            all_pattern_files = dir(pat_file_pattern);

            %gets a list of just the pattern file names
            list_pat_names = {all_pattern_files.name};
            num_of_patterns = length(list_pat_names);

            %go through list and load each file
            for k = 1:num_of_patterns
                %check that a pattern of this name has not already been
                %imported
                filepath = fullfile(pat_folder, list_pat_names{k});
                [path, name, ext] = fileparts(filepath);
                if ~isfield(self.Patterns, name)
                    %create path to kth .mat file in Patterns folder
                    
                    self.Patterns.(name) = load(filepath);
                    pats_imported = pats_imported + 1;
                else
                    pats_failed = pats_failed + 1;
                end
            end
           
        end

%Import a function folder, called from sampe places as import_pattern folder-----------------------------------
        function [pos_failed, pos_imported] = import_function_folder(self, pos_folder)
            
            pos_imported = 0;
            pos_failed = 0;
            pos_file_pattern = sprintf('%s/*.mat', pos_folder);
            all_position_files = dir(pos_file_pattern);
            list_pos_names = {all_position_files.name};
            num_of_positions = length(list_pos_names);

            for m = 1:num_of_positions
                filepath = fullfile(pos_folder, list_pos_names{m});
                [path, name, ext] = fileparts(filepath);
                if ~isfield(self.Pos_funcs, name)
                    
                    self.Pos_funcs.(name) = load(filepath);
                    pos_imported = pos_imported + 1;
                    
                else
                    pos_failed = pos_failed + 1;
                end
            end
            
        end
        
%Import an AO folder, called from same places as import_pattern_folder-----------------------------------------------------
        function [ao_failed, ao_imported] = import_ao_folder(self, ao_folder)
            
            ao_failed = 0;
            ao_imported = 0;
            ao_file_pattern = sprintf('%s/*.mat', ao_folder);
            all_ao_files = dir(ao_file_pattern);
            list_ao_names = {all_ao_files.name};
            num_of_ao = length(list_ao_names);

            for j = 1:num_of_ao
                
                filepath = fullfile(ao_folder, list_ao_names{j});
                [path, name, ext] = fileparts(filepath);
                if ~isfield(self.Ao_funcs, name)
                    
                    self.Ao_funcs.(name) = load(filepath);
                    ao_imported = ao_imported + 1;
                else
                    ao_failed = ao_failed + 1;
                end
            end
            
            
        end
        
%Import a folder, called from the controller and calls more specific import functions for each type of folder ---------------------------------        
        function import_folder(self, path)
            
            exp_file = fullfile(path, 'currentExp.mat');
            
            pat_file_pattern = sprintf('%s/*.pat', path);
            all_pat_files = dir(pat_file_pattern);
            
            func_file_pattern = sprintf('%s/*.pfn',path);
            all_func_files = dir(func_file_pattern);
            
            ao_file_pattern = sprintf('%s/*.afn',path);
            all_ao_files = dir(ao_file_pattern);
            
            
            if isfile(exp_file)
                
                prog = waitbar(0, 'Importing...', 'WindowStyle', 'modal'); %start waiting bar
                imported_message = self.import_experiment_folder(path); %do the import
                waitbar(1, prog, 'Finishing...');
                close(prog); %finish and close the waiting bar
                waitfor(msgbox(imported_message, 'Import Successful')); %display message with import numbers.
                
            elseif ~isempty(all_pat_files)
                
                prog = waitbar(0, 'Importing...', 'WindowStyle', 'modal');
                [pats_failed, pats_imported] = self.import_pattern_folder(path);
                waitbar(1, prog, 'Finishing...');
                close(prog);
                imported_message = pats_imported + " patterns imported. " + newline + pats_failed + " patterns failed.";
                waitfor(msgbox(imported_message, 'Import Successful'));
                
            elseif ~isempty(all_func_files)
                prog = waitbar(0, 'Importing...', 'WindowStyle', 'modal');
                [pos_failed, pos_imported] = self.import_function_folder(path);
                waitbar(1, prog, 'Finishing...');
                close(prog);
                imported_message = pos_imported + " position functions imported. " + newline + pos_failed + " position functions failed.";
                waitfor(msgbox(imported_message, 'Import Successful'));
                
            elseif ~isempty(all_ao_files)
                
                prog = waitbar(0, 'Importing...', 'WindowStyle', 'modal');
                [ao_failed, ao_imported] = self.import_ao_folder(path);
                waitbar(1, prog, 'Finishing...');
                close(prog);
                imported_message = ao_imported + " AO functions imported. " + newline + ao_failed + " AO functions failed.";
                waitfor(msgbox(imported_message, 'Import Successful'));
                
            else
                waitfor(errordlg(['I do not recognize this as a pattern, function, ao, or experiment folder. ', ...
                'If it is an experiment folder, please make sure it has a currentExp.mat file. ', ...
                'If it is a pattern, function, or ao folder, please make sure it has the corresponding .pat, .pfn, or .afn files. ']));
                return;
            end



        end
    
%CREATE STRUCTURE TO SAVE TO .G4P FILE WHEN SAVING------------------------        
        function [vars] = create_parameters_structure(self)
        
            vars.block_trials = self.block_trials();
            vars.pretrial = self.pretrial();
            vars.intertrial = self.intertrial();
            vars.posttrial = self.posttrial();
            vars.is_randomized = self.is_randomized();
            vars.repetitions = self.repetitions();
            vars.is_chan1 = self.is_chan1();
            vars.is_chan2 = self.is_chan2();
            vars.is_chan3 = self.is_chan3();
            vars.is_chan4 = self.is_chan4();
            vars.chan1_rate = self.chan1_rate();
            vars.chan2_rate = self.chan2_rate();
            vars.chan3_rate = self.chan3_rate();
            vars.chan4_rate = self.chan4_rate();
            vars.num_rows = self.num_rows();
            vars.experiment_name = self.experiment_name;
        
        end
        
%GET THE INDEX OF A GIVEN PATTERN, POS, OR AO NAME-------------------------

  function [index] = get_pattern_index(self, pat_name)
            if strcmp(pat_name,'') == 1
                index = 0;
            else
                fields = fieldnames(self.Patterns);
                index = find(strcmp(fields, pat_name));
                
            end    
        end
        
        function [index] = get_posfunc_index(self, pos_name)
            if strcmp(pos_name,'') == 1
                index = 0;
            else
                fields = fieldnames(self.Pos_funcs);
                index = find(strcmp(fields, pos_name));
            end
        end
        
        function [index] = get_ao_index(self, ao_name)
            if strcmp(ao_name,'') == 1
                index = 0;
            else
                fields = fieldnames(self.Ao_funcs);
                index = find(strcmp(fields, ao_name));
            end
        end
        
        %Setters
        
        function set.top_folder_path(self, value)
            self.top_folder_path_ = value;
        end
        
        function set.top_export_path(self, value)
            self.top_export_path_ = value;
        end
        
        function set.Patterns(self, value)
            self.Patterns_ = value;
        end
        
        function set.Pos_funcs(self, value)
            self.Pos_funcs_ = value;
        end
        
        function set.Ao_funcs(self, value)
            self.Ao_funcs_ = value;
        end
        
        function set.save_filename(self, value)
            self.save_filename_ = value;
        end
        
        function set.currentExp(self, value)
            self.currentExp_ = value;
        end
        
        function set.experiment_name(self, value)
            self.experiment_name_ = value;
        end
        
        function set.pretrial(self, value)
            self.pretrial_ = value;
        end
        
        function set.intertrial(self, value)
            self.intertrial_ = value;
        end
        
        function set.block_trials(self, value)
            self.block_trials_ = value;
        end
        
        function set.posttrial(self, value)
            self.posttrial_ = value;
        end
        
        function set.repetitions(self, value)
            self.repetitions_ = value;
        end
        
        function set.is_randomized(self, value)
            self.is_randomized_ = value;
        end
        
        function set.num_rows(self, value)
            self.num_rows_ = value;
        end
        
         function set.is_chan1(self, value)
            self.is_chan1_ = value;
        end
        
        function set.is_chan2(self, value)
            self.is_chan2_ = value;
        end
        
        function set.is_chan3(self, value)
            self.is_chan3_ = value;
        end
        
        function set.is_chan4(self, value)
            self.is_chan4_ = value;
        end
        
        function set.chan1_rate(self, value)
            self.chan1_rate_ = value;
        end
        
        function set.chan2_rate(self, value)
            self.chan2_rate_ = value;
        end
        
        function set.chan3_rate(self, value)
            self.chan3_rate_ = value;
        end
        
        function set.chan4_rate(self, value)
            self.chan4_rate_ = value;
        end
        
        function set.configData(self, value)
            self.configData_ = value;
        end
        %Getters
        
        
        function value = get.top_folder_path(self)
            value = self.top_folder_path_;
        end
        
        function value = get.top_export_path(self)
            value = self.top_export_path_;
        end
        
        function value = get.Patterns(self)
            value = self.Patterns_;
        end
        
        function value = get.Pos_funcs(self)
            value = self.Pos_funcs_;
        end
        
        function value = get.Ao_funcs(self)
            value = self.Ao_funcs_;
        end
        
        function value = get.save_filename(self)
            value = self.save_filename_;
        end
        
        function value = get.currentExp(self)
            value = self.currentExp_;
        end
        
        function value = get.experiment_name(self)
            value = self.experiment_name_;
        end
        
        function output = get.pretrial(self)
            output = self.pretrial_;
        end
        
        function output = get.block_trials(self)
            output = self.block_trials_;
        end
        
        function output = get.intertrial(self)
            output = self.intertrial_;
        end
        
        function output = get.posttrial(self)
            output = self.posttrial_;
        end
        
        function output = get.repetitions(self)
            output = self.repetitions_;
        end
        
        function output = get.is_randomized(self)
            output = self.is_randomized_;
        end
        
        function output = get.is_chan1(self)
            output = self.is_chan1_;
        end
        
        function output = get.chan1_rate(self)
            output = self.chan1_rate_;
        end
        
        function output = get.is_chan2(self)
            output = self.is_chan2_;
        end
        
        function output = get.chan2_rate(self)
            output = self.chan2_rate_;
        end
        
        function output = get.is_chan3(self)
            output = self.is_chan3_;
        end
        
        function output = get.chan3_rate(self)
            output = self.chan3_rate_;
        end
        
        function output = get.is_chan4(self)
            output = self.is_chan4_;
        end
        
        function output = get.chan4_rate(self)
           output = self.chan4_rate_;
        end
        
        function output = get.num_rows(self)
            output = self.num_rows_;
        end
        
        function output = get.configData(self)
            output = self.configData_;
        end

    end

end
     


