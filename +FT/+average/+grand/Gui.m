function Gui

% FT.acerage.grand.Gui
%
% Description:
%
% Syntax: FT.acerage.grand.Gui
%
% In:
%
% Out:
%
% See also:
%       FT.average.grand.Run
%
% Updated: 2014-10-04
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

% Validate the dataset paths
datasets = FT_DATA.organization.getdatasets;
validsets = cellfun(@(set) FT.average.grand.Verify(set{end}),datasets);
datasets = datasets(validsets);

% Either no study is loaded or there are no valid datasets in it
if isempty(datasets)
    msg = 'No study and/or valid datasets found. Please add them before proceeding.';
    FT.UserInput(msg,0,'title','Not prepared to average','button','ok');
    return;
end

setlabels = cell(size(datasets)); % list entries
setpaths = cellfun(@(set) set{end},datasets,'uni',false); % file paths only
subjects = cellfun(@(set) set{end-1},datasets,'uni',false); % dataset subjects only
% Put list entries in the format "[SUBJECT] > [FILENAME.EXT]"
for i = 1:numel(setlabels)
    [~,name,ext] = fileparts(setpaths{i});
    setlabels{i} = [subjects{i} ' > ' name ext];
end

fmt = {'Subject-wise','Trial-wise'};

c = {... %select datasets
     {'text','string','Datasets:'},...
     {'listbox','string',setlabels,'tag','sets','max',numel(setlabels)};...
     ... %select format
     {'text','string','Format:'},...
     {'listbox','string',fmt,'tag','fmt'};...
     ... %buttons
     {'pushbutton','string','Plot','validate',false,'Callback',@DoPlot},...
     {'pushbutton','string','Close','validate',false}...
    };

win = FT.tools.Win(c,'title','Grand Average','grid',false);
win.Wait;

%-----------------------------------------------------------------------------%
function DoPlot(~,varargin)
    kplot = win.GetElementProp('sets','value');
    if ~isempty(kplot)
        param.files = setpaths(kplot);
        param.subjects = subjects(kplot);
        param.fmt = lower(fmt{win.GetElementProp('fmt','value')});
        me = FT.average.grand.Run(param);
        if isa(me,'MException')
            FT.ProcessError(me);
            return;
        elseif isempty(me)
            FT.UpdateGUI;            
            FT.view.PlotERP;            
        end
    end    
end
%-----------------------------------------------------------------------------%
end
