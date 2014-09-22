function Gui()

% FT.average.Gui
%
% Description: check the stage and then average trials
%
% Syntax: FT.average.Gui
%
% In: 
%
% Out:
%
% Updated: 2014-08-20
% Peter Horak
%
% See also: FT.average.Run

global FT_DATA;
files = {};

% Move to the analysis base directory
strDirCur = pwd;
if isdir(FT_DATA.path.base_directory)
    cd(FT_DATA.path.base_directory);
end

while (true)
    [strName, strPath, ind] = uigetfile('*.set','Pick a file');

    % Check that valid files were selected
    if isequal(strName,0) || isequal(strPath,0)
        return; % user selected cancel
    elseif ind ~= 1
        FT.UserInput('File extensions must be .set',1,'button',{'OK'},'title','NOTICE');
        continue;
    end
    
    % Add the selected file
    newFile = fullfile(strPath,strName);
    if ~ismember(newFile,files)
        try
            DATA = load(newFile,'-mat');
            if ~DATA.done.average
                error('averaging not performed')
            end
            files{end+1} = newFile;
        catch
            FT.UserInput('Invalid .set file',1,'button',{'OK'},'title','NOTICE');
            continue;
        end
    end

    % Query the user to continue adding files
    resp = FT.UserInput(['Datasets to average:\n' strjoin(files,'\n')],1,...
        'title','Include More Datasets?','button',{'Yes','No (Run)','Cancel'});
    if strcmpi(resp,'cancel')
        return;
    elseif strcmpi(resp,'no (run)')
        break;
    end
end
cd(strDirCur); % move back to the original directory

params.files = reshape(files,[],1);

hMsg = FT.UserInput('Calculating grand average of ERPs...',1);
me = FT.average.grand.Run(params);
if ishandle(hMsg)
    close(hMsg);
end

FT.ProcessError(me);

FT.UpdateGUI;

end
