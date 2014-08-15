function Run()

global FT_DATA;

if ~isempty(FT_DATA.template) && ~isempty(FT_DATA.path.template)

    files = {};
    steps = FT_DATA.template;
    ext = '*.*'; % *** FIX ME

    [strNames, strPath, ind] = uigetfile(ext,'Pick a file','MultiSelect','on');
    while (true)
        % Check that valid files were selected
        if isequal(strNames,0) || isequal(strPath,0)
            return; % user selected cancel
        elseif ind ~= 1
            FT.UserInput(['File extensions must be consistant with those in the template ('...
                ext ')'],1,'button',{'OK'},'title','NOTICE');
        else
            % Add all files selected
            if ~iscell(strNames)
                files{end+1} = fullfile(strPath,strNames);
            else
                for i = 1:numel(strNames)
                    files{end+1} = fullfile(strPath,strNames{i});
                end
            end
        end
        % Don't keep duplicate files
        files = unique(files);
        
        % Query the user to continue adding files
        resp = FT.UserInput(['Files to analyze:\n' strjoin(files,'\n')],1,...
            'title','Include More Files?','button',{'Yes','No (Run)','Cancel'});
        if strcmpi(resp,'yes')
            [strNames, strPath] = uigetfile(ext,'Pick a file','MultiSelect','on');
        elseif strcmpi(resp,'cancel')
            return;
        else % no (run)
            break;
        end
    end

    nFiles = numel(files);
    tSteps = numel(steps);
    
    % For each data set specified
    for i = 1:nFiles
        fprintf(1,'Processing ''%s'' (%i of %i)\n',files{i},i,nFiles);
        
        % Read in the data
        me = FT.io.ReadDataset(files{i});
        if isa(me,'MException')
            fprintf(2,'[ERROR]: Could not read ''%s''\n',files{i});
            continue;
        end
        
        % Run each processing step
        for j = 1:tSteps
            op = strsplit(steps{j}.operation,'_');
            if numel(op) == 1
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
        
        % Save the processed data
        if ~isa(me,'MException')
            [~,dataName] = fileparts(files{i});
            [tempPath,tempName] = fileparts(FT_DATA.path.template);
            FT.io.WriteDataset(fullfile(tempPath,[tempName '_' dataName '.set']));
        end
    end
end

FT.UpdateGUI;

end