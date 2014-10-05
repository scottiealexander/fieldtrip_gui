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

if FT.tools.IsEmptyField('study_name')
    msg = '[ERROR]: No study has been loaded. Pleas load a study before averaging!';
    FT.UserInput(msg,0,'title','No study loaded','button','ok');
    return;
end

fmt = {'Subject-wise','Trial-wise'};
fmap = containers.Map('KeyType','char','ValueType','char');

tmp = repmat({'something-goes-here'},4,1);
tmp1 = repmat({'something-goes-here'},3,1);
tmp2 = repmat({'something-goes-here'},1,1);
conds = tmp;

c = {... %select datasets
     {'text','string','Datasets:'},...
     {'listbox','string',tmp,'tag','sets','max',2};,... %max > 1 allows multi selection
     {'pushbutton','string','Add','Callback',@(varargin) SetOps('add')},...
     {'pushbutton','string','Remove','Callback',@(varargin) SetOps('rm')};...
     ... %select format
     {'text','string','Format:'},...
     {'listbox','string',fmt,'tag','fmt'};...
     ... %buttons
     {'pushbutton','string','Plot','Callback',@(varargin) DoPlot},...
     {'pushbutton','string','Cancel'}...
    };

win = FT.tools.Win(c,'title','Grand Average','grid',false);
win.Wait;

%-----------------------------------------------------------------------------%
function DoPlot
    kplot = win.GetElementProp('sets','value');
    keys = fmap.keys;
    if ~isempty(kplot) && fmap.Count > 0
        param.files = fmap(keys(kplot));
        param.fmt = lower(fmt{win.GetElementProp('fmt','value')});
        FT.average.grand.Run(param)
    end
end
%-----------------------------------------------------------------------------%
function SetOps(action)
    switch lower(action)
    case 'add'
        name = FT.study.subject.Select;
        fpath = FT.study.subject.SelectFile(name);
        [~,fname] = fileparts(fpath);
        fname = [name filesep fname];
        fmap(fname) = fpath;
    case 'rm'
        krm = win.GetElementProp('sets','value');
        keys = fmap.keys;
        if ~isempty(krm) && krm > 0 && krm <= numel(keys)
            fmap.remove(keys(krm));
        end
    otherwise
        %should never happen...
    end
    v = fmap.Count;

    win.SetElementProp('sets','max',v);
    win.SetElementProp('sets','string',fmap.keys);
    win.SetElementProp('sets','value',v);
    win.ReSize;
    drawnow;    
end
% %-----------------------------------------------------------------------------%
% function 

% end
% %-----------------------------------------------------------------------------%
% function 

% end
% %-----------------------------------------------------------------------------%
% function 

% end
% %-----------------------------------------------------------------------------%
% function 

% end
% %-----------------------------------------------------------------------------%
end
