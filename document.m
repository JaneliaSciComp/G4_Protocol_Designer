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
        
    end
    
    methods
        
%         function self = document()
%         
%             self.top_folder_path_ = '';
% %             self.Patterns_ = struct;
% %             self.Pos_funcs_ = struct;
% %             self.Ao_funcs_ = struct;
%         
%         end
       function [export_successful] = export(self, vars)
           
           %Check if experiment folder for that experiment name already
           %exists - if it does, confirm the user wants to recycle the old
           %folder and replace it with the new one.
            if exist(self.top_export_path_, 'dir') == 7
                question = strcat('A folder for experiment ', vars.experiment_name, ' already exists. Are you sure you want to replace it?');
                replace = questdlg(question);
                if strcmp(replace, 'Yes') == 1
                    confirm = strcat('Are you sure you want to send ', vars.experiment_name, ' to the recycle bin?');
                    confirmation = questdlg(confirm);
                    if strcmp(confirmation, 'Yes') == 1
                        recycle('on')
                        rmdir(self.top_export_path_,'s');
                    elseif strcmp(confirmation,'')==1 || strcmp(confirmation,'Cancel')==1
                        export_successful = 2; 
                        return;
                        
                    else
                        export_successful = 0;
                        return;

                    end
                elseif strcmp(replace,'') == 1 || strcmp(replace,'Cancel') == 1
                    export_successful = 2;
                    return;
                    
                    
                else
                    export_successful = 0;
                    return;
                end
               
                
            end
            
                        
            %[path, name, ext] =  fileparts(self.save_filename_);
            Exppath = self.top_export_path_;


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
               for i = 1:length(vars.block_trials(:,1))
                    
                    pat_list{i} = vars.block_trials{i,2};
                    if strcmp(vars.block_trials{i,3},'') == 0
                        func_list{func_count} = vars.block_trials{i,3};
                        func_count = func_count + 1;
                    end
                    if strcmp(vars.block_trials{i,4},'') == 0
                        ao_list{ao_count} = vars.block_trials{i,4};
                        ao_count = ao_count + 1;
                    end
                    if strcmp(vars.block_trials{i,5},'') == 0
                        ao_list{ao_count} = vars.block_trials{i,5};
                        ao_count = ao_count + 1;
                    end
                    if strcmp(vars.block_trials{i, 6},'') == 0
                        ao_list{ao_count} = vars.block_trials{i,6};
                        ao_count = ao_count + 1;
                    end
                    if strcmp(vars.block_trials{i,7},'') == 0
                        ao_list{ao_count} = vars.block_trials{i,7};
                        ao_count = ao_count + 1;
                    end
               end

               pat_list{end + 1} = vars.pretrial{2};
               pat_list{end + 1} = vars.posttrial{2};
               pat_list{end + 1} = vars.intertrial{2};
               
               if strcmp(vars.pretrial{3},'') == 0
                   func_list{end+1} = vars.pretrial{3};
               end
               if strcmp(vars.posttrial{3},'') == 0
                   func_list{end+1} = vars.posttrial{3};
               end
               if strcmp(vars.intertrial{3},'') == 0
                   func_list{end+1} = vars.intertrial{3};
               end
               
               for i = 4:7
                   if strcmp(vars.pretrial{i},'') == 0
                       ao_list{end+1} = vars.pretrial{i};
                   end
               end
               for i = 4:7
                   if strcmp(vars.posttrial{i},'') == 0
                       ao_list{end+1} = vars.posttrial{i};
                   end
               end
               for i = 4:7
                   if strcmp(vars.intertrial{i},'') == 0
                       ao_list{end+1} = vars.intertrial{i};
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
                        pfnparam = self.Pos_funcs_.(field).pfnparam;
                        save(filepath, 'pfnparam');
                        
                        num = regexp(filename,'\_','split');
                        pfnName = strcat('fun',num{2},'.pfn');
                        pfnList{m} = pfnName;
                        func_folder = fullfile(self.top_folder_path_, 'Functions');
                        pfnFilePath = fullfile(func_folder,pfnName);
                        pfnNewFilePath = fullfile(funcpath, pfnName);

                        pfn = fopen(pfnFilePath);
                        pfnData = fread(pfn);
                        newpfn = fopen(pfnNewFilePath, 'w');
                        fwrite(newpfn, pfnData);
                        fclose(pfn);
                        fclose(newpfn);
                
                    end
               end
               afnList = {};
               if exist('ao_list') ~= 0
                   ao_list = unique(ao_list);
                   num_ao = length(ao_list);
                   for n = 1:num_ao
                    
                        field = ao_list{n};
                        filename = strcat(field, '.mat');
                        filepath = fullfile(aopath, filename);
                        afnparam = self.Ao_funcs_.(field).afnparam;
                        save(filepath, 'afnparam');
                        
                        num = regexp(filename,'\_','split');
                        afnName = strcat('ao',num{2},'.afn');
                        afnList{n} = afnName;
                        ao_folder = fullfile(self.top_folder_path_, 'Analog Output Functions');
                        afnFilePath = fullfile(ao_folder,afnName);
                        afnNewFilePath = fullfile(aopath, afnName);
                        afn = fopen(afnFilePath);
                        afnData = fread(afn);
                        newafn = fopen(afnNewFilePath, 'w');
                        fwrite(newafn, afnData);
                        fclose(afn);
                        fclose(newafn);
                
                   end
               end
                              
               pat_list = unique(pat_list);
               patternList = { };
               pattNames = {};
               
               num_pats = length(pat_list);
               for k = 1:num_pats
                    
                    field = pat_list{k};
                    pattNames{k} = field;
                    filename = strcat(field,'.mat');
                    filepath = fullfile(patpath, filename);
                    pattern = self.Patterns_.(field).pattern;
                    save(filepath, 'pattern');
                    
                    num = regexp(filename,'\_','split');
                    patname = strcat(num{2},'.pat'); 
                    patternList{k} = patname;
                    patfilepath = fullfile(patpath, patname);
                    imported_patfilepath = fullfile(self.top_folder_path_, 'Patterns', patname);
                    pat = fopen(imported_patfilepath);
                    patData = fread(pat);
                    fileID = fopen(patfilepath,'w');
                    fwrite(fileID, patData);
                    fclose(pat);
                    fclose(fileID);
                
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
                    currentExp.pattern.x_num(j) = self.Patterns_.(field).pattern.x_num;
                    currentExp.pattern.y_num(j) = self.Patterns_.(field).pattern.y_num;
                    currentExp.pattern.gs_val(j) = self.Patterns_.(field).pattern.gs_val;
                    currentExp.pattern.arena_pitch(j) = self.Patterns_.(field).pattern.param.arena_pitch;
                    pat_list{j} = strcat(field, '.mat');
                    
                end
                currentExp.pattern.pattNames = pattNames;
                currentExp.pattern.patternList = patternList;%list of .pat files
                currentExp.pattern.num_patterns = num_pats;
                
                %currentExp.function
                if exist('func_list')~= 0
                    for k = 1:num_funcs
                        field = func_list{k};
                        currentExp.function.functionSize{k} = self.Pos_funcs_.(field).pfnparam.size;
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
                        currentExp.aoFunction.aoFunctionSize{p} = self.Ao_funcs_.(field).afnparam.size;  
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
        
        function saveas(self, path, exp_parameters)
            
            homemade_ext = '.g4p';

        %Replace .mat extension with homemade one
            
            [savepath, name, ext] = fileparts(path);
            savename = strcat(name, homemade_ext);
            self.top_export_path_ = fullfile(savepath, exp_parameters.experiment_name);
        %Get path to file you want to save including new extension    
            save_file = fullfile(self.top_export_path_, savename);
            self.save_filename_ = save_file;
            if isfile(save_file)
                question = 'This file already exists. Are you sure you want to replace it?';
                replace = questdlg(question);
                
                if strcmp(replace, 'Yes') == 1
                    confirm = strcat('Are you sure you want to send ', savename, ' to the recycle bin?');
                    confirmation = questdlg(confirm);
                    if strcmp(confirmation,'Yes') == 1

                        recycle('on');
                        delete(save_file);
                        temp_path = strcat(self.top_export_path_, 'temp');
                        movefile(self.top_export_path_, temp_path);
                        self.top_folder_path_ = temp_path;
                        
                    else
                        return;
                    end
                else
                    return;
                end
                
            else
                
                temp_path = '';

            end
            
            export_successful = self.export(exp_parameters);% 0 - export was unable to complete 1- export completed successfully 2-user canceled and export not attempted
            if export_successful == 0
                waitfor(errordlg("Export was unsuccessful. Please delete files to be overwritten manually and try again."));
                return;
                
            elseif export_successful == 2
                return;

            else
            
                save(self.save_filename_, 'exp_parameters');
                if strcmp(temp_path,'') == 0
                    rmdir(temp_path,'s');
                end
            end
            
        end
        
        function save(self, exp_parameters)
            
            if isempty(self.save_filename_) == 1
                waitfor(errordlg("You have not yet saved a new file. Please use 'save as'"));
            else
                export_successful = self.export(exp_parameters);
                if export_successful == 0
                    waitfor(errordlg("Export was unsuccessful. Please delete folders to be replaced and use save as."));
                    
                elseif export_successful == 2
                    
                    return;
                else

                save(self.save_filename_, 'exp_parameters');
                end                
            end
            
            
            
        end
        
        function import_file(self, file, path)

            file_full = fullfile(path, file);
            [filepath, name, ext] = fileparts(file_full);
            
            if strcmp(ext, '.mat') == 0
                
                waitfor(errordlg("Please make sure you are importing a .mat file"));
            
            elseif strncmp(file, 'Pattern', 7) == 1
                
                if isfield(self.Patterns_, name) == 1
                    waitfor(errordlg("A pattern of that name has already been imported."));
                else
                    self.Patterns_.(name) = load(file_full);
                end
                %add to Patterns_
                
            elseif strncmp(file, 'FunctionAO', 10) == 1
                
                if isfield(self.Ao_funcs_, name) == 1
                    waitfor(errordlg("An Analog Output Function of that name has already been imported."));
                else
                    self.Ao_funcs_.(name) = load(file_full);
                end
                
                %add to ao functions
                
            elseif strncmp(file, 'Function', 8) == 1
                
                if isfield(self.Pos_funcs_, name) == 1
                    waitfor(errordlg("A Position Function of that name has already been imported."));
                else
                    self.Pos_funcs_.(name) = load(file_full);
                end
                %add to pos funcs
                
            else
                
                waitfor(errordlg("Please make sure your file matches one of the following patterns: Pattern * .mat, FunctionAO * .mat, or Function * .mat"));
            
            end
        
        end
        
        
        function self = document(path)
            
            self.top_folder_path_ = path;

            %use fullfile to create the file path to each folder in
            %Experiment
            
            pat_folder = fullfile(self.top_folder_path_, 'Patterns');
            pos_folder = fullfile(self.top_folder_path_, 'Functions');
            ao_folder = fullfile(self.top_folder_path_, 'Analog Output Functions');
            %results_folder = fullfile(self.top_folder_path_, 'Results');
            currentExp_path = fullfile(self.top_folder_path_, 'currentExp.mat');

            if ~isfolder(pat_folder)

                errordlg("Cannot find the Patterns folder in Experiment.");

            end
            if ~isfolder(pos_folder)

                errordlg("Cannot find the Functions folder in Experiment.");

            end
            if ~isfolder(ao_folder)

                errordlg("Cannot find the Analog Output Functions folder in Experiment.");

            end
            if ~isfile(currentExp_path)

                errordlg("Cannot find the currentExp.mat file in Experiment.");

            end


            %pull all .mat filenames out of Patterns folder and make a
            %list of them

            %establishes what type of files I want to pull, *.mat
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
                %create path to kth .mat file in Patterns folder
                filepath = fullfile(pat_folder, string(list_pat_names(k)));
                [path, name, ext] = fileparts(filepath);
                self.Patterns_.(name) = load(filepath);
            end


            pos_file_pattern = sprintf('%s/*.mat', pos_folder);
            all_position_files = dir(pos_file_pattern);
            list_pos_names = {all_position_files.name};
            num_of_positions = length(list_pos_names);

            for m = 1:num_of_positions
                filepath = fullfile(pos_folder, string(list_pos_names(m)));
                [path, name, ext] = fileparts(filepath);
                self.Pos_funcs_.(name) = load(filepath);
            end

            ao_file_pattern = sprintf('%s/*.mat', ao_folder);
            all_ao_files = dir(ao_file_pattern);
            list_ao_names = {all_ao_files.name};
            num_of_ao = length(list_ao_names);

            for j = 1:num_of_ao
                filepath = fullfile(ao_folder, string(list_ao_names(j)));
                [path, name, ext] = fileparts(filepath);
                self.Ao_funcs_.(name) = load(filepath);
            end
            [path, name, ext] = fileparts(currentExp_path);
            self.currentExp_ = load(currentExp_path);
            self.save_filename_ = '';


        end

    end

end
     


