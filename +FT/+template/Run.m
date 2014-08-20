function Run()

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
ext = ['*.' params.ext];

% move to the template's directory
[tempPath,tempName] = fileparts(FT_DATA.path.template);
strDirCur = pwd;
if isdir(tempPath)
    cd(tempPath);
end

% Neuralynx data files
if strcmpi('',params.ext)
    while (true)
        strPath = uigetdir(pwd,'Pick a file');
        
        if isequal(strPath,0)
            return; % user selected cancel
        end
        files{end+1} = strPath;

        % Don't keep duplicate entries
        files = unique(files);

        % Query the user to continue adding directories
        resp = FT.UserInput(['Files to analyze:\n' strjoin(files,'\n')],1,...
            'title','Include More Files?','button',{'Yes','No (Run)','Cancel'});
        if strcmpi(resp,'cancel')
            return;
        elseif strcmpi(resp,'no (run)')
            break;
        end
    end
% All other data files
else
    while (true)
        [strNames, strPath, ind] = uigetfile(ext,'Pick a file','MultiSelect','on');
        
        % Check that valid files were selected
        if isequal(strNames,0) || isequal(strPath,0)
            return; % user selected cancel
        elseif ind ~= 1
            FT.UserInput(['File extensions must be consistant with those in the template ('...
                ext ')'],1,'button',{'OK'},'title','NOTICE');
            continue;
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
end

% Return to original directory
cd(strDirCur);

nFiles = numel(files);
tSteps = numel(steps);

% For each data set specified
for i = 1:nFiles
    fprintf(1,'Processing ''%s'' (%i of %i)\n',files{i},i,nFiles);

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
            FT.io.WriteDataset(fullfile(steps{j}.params.path,[tempName...
                num2str(j) '_' strName num2str(i) '.set']));
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

%     % Save the processed data (only if there are multiple)
%     if ~isa(me,'MException') && nFiles > 1
%         FT.io.WriteDataset(fullfile(tempPath,[tempName '_' strName '.set']));
%     end
end

FT.UpdateGUI;

end