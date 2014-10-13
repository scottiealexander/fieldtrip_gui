function Run()
% FT.template.Run
%
% Description: run the current template on a list of data files (either
% obtained from the analysis/study organization or by browsing for files)
%
% Updated: 2014-10-13
% Peter Horak

global FT_DATA;

if ~iscell(FT_DATA.template)
     FT.UserInput('\bf[\color{red}ERROR\color{black}]: Malformed template.',1,'title','Error','button',{'OK'});
     return;
elseif isempty(FT_DATA.template) || isempty(FT_DATA.path.template)
     FT.UserInput('No loaded template to run!',1,'title','Notice','button',{'OK'});
     return;
elseif ~strcmpi('io',FT_DATA.template{1}.operation)
     FT.UserInput('\bf[\color{red}ERROR\color{black}]: First operation in template must be to read a data file.',1,'title','Error','button',{'OK'});
end

files = {};
steps = FT_DATA.template(2:end);
params = FT_DATA.template{1}.params;
[tempPath,tempName] = fileparts(FT_DATA.path.template);
ext = ['*.' params.ext];

% Get all datasets associated with the current study (if any)
datasets = FT_DATA.organization.getdatasets;
validsets = cellfun(@(set) Verify(set{end},ext),datasets);
datasets = datasets(validsets);
subjects = [];

%%%%%%%%%%%%%%%%%%%%%%%% LOAD DATASETS BY STUDY %%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(datasets)
    setlabels = cell(size(datasets)); % list entries
    setpaths = cellfun(@(set) set{end},datasets,'uni',false); % file paths only
    subjects = cellfun(@(set) set{end-1},datasets,'uni',false); % dataset subjects only
    % Put list entries in the format "[SUBJECT] > [FILENAME.EXT]"
    for i = 1:numel(setlabels)
        [~,name,ext] = fileparts(setpaths{i});
        setlabels{i} = [subjects{i} ' > ' name ext];
    end
    
    % Let the user select the files to analyze from the list
    c = {{'text','string','Datasets:'},...
         {'listbox','string',setlabels,'tag','sets','max',numel(setlabels)};...
         {'pushbutton','string','Run'},...
         {'pushbutton','string','Cancel','validate',false}};
    win = FT.tools.Win(c,'title','Pick file(s)','grid',false);
    win.Wait;
    
    if ~strcmpi(win.res.btn,'run')
        return; % user selected cancel
    end
    
    files = setpaths(win.res.sets); % user-selected files
    subjects = subjects(win.res.sets); % corresponding subjects
else %%%%%%%%%%%%%%%%%%%%%% BROWSE DATA FILES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % move to the template's directory
    strDirCur = pwd;
    if isdir(tempPath)
        cd(tempPath);
    end

    while (true)
        [strNames, strPath, ind] = uigetfile(ext,'Pick a file(s)','MultiSelect','on');

        % Check that valid files were selected
        if isequal(strNames,0) || isequal(strPath,0)
            return; % user selected cancel
        elseif ind ~= 1
            FT.UserInput(['File extensions must be consistant with those in the template ('...
                ext ')'],1,'button',{'OK'},'title','NOTICE');
            continue;
        end

        % Neuralnyx file (load entire folder)
        if strcmpi(params.ext,'ncs')
            strNames = '';
        end

        % Add all files selected
        if ~iscell(strNames)
            files{end+1} = fullfile(strPath,strNames);
        else
            for i = 1:numel(strNames)
                files{end+1} = fullfile(strPath,strNames{i});
            end
        end

        % Don't keep duplicate files
        files = unique(files);

        % Query the user to continue adding files
        resp = FT.UserInput(['Files to analyze:\n' strjoin(files,'\n')],1,...
            'title','Include More Files?','button',{'Yes','No (Run)','Cancel'});
        if strcmpi(resp,'cancel')
            return;
        elseif strcmpi(resp,'no (run)')
            break;
        end
    end
    % Return to original directory
    cd(strDirCur);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%% END SELECT FILES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nFiles = numel(files);
tSteps = numel(steps);

% For each data set specified
for i = 1:nFiles
    fprintf(1,'Processing ''%s'' (%i of %i)\n',files{i},i,nFiles);

    % Make the source dataset's subject the current subjects
    if ~isempty(subjects)
        FT_DATA.organization.addnode('subject',subjects{i});
    end
    
    % Read in the data
    [strPath,strName] = fileparts(files{i});
    params.name = strName;
    params.path = strPath;
    params.full = files{i};
    me = FT.io.ReadDataset(params);
    
    if isa(me,'MException')
        fprintf(2,'[ERROR]: Could not read ''%s''\n',files{i});
        continue;
    end

    % Run each processing step
    for j = 1:tSteps
        op = strsplit(steps{j}.operation,'_');
        if strcmpi('save',op{1})
            FT.io.SaveDataset(true,fullfile(steps{j}.params.path,[tempName...
                '-' steps{j}.params.name '-' strName '.set']));
        elseif numel(op) == 1
            me = FT.(op{1}).Run(steps{j}.params);
        elseif numel(op) == 2
            me = FT.(op{2}).(op{1}).Run(steps{j}.params);
        else
            me = MException('FT:invalidOperation','Too many . references.');
        end

        if isa(me,'MException')
            fprintf(2,'[ERROR]: Aborting processing of ''%s''\n',files{i});
            fprintf(2,getReport(me));
            break;
        end
    end
end
fprintf('Complete.\n');

FT.UpdateGUI;
end

function b = Verify(path,target_ext)
    [~,~,ext] = fileparts(path);
    b = exist(path,'file') && strcmpi(ext,target_ext(2:end));
end
