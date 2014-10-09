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

if FT.tools.IsEmptyField('study_name')
    msg = '[ERROR]: No study has been loaded. Pleas load a study before averaging!';
    FT.UserInput(msg,0,'title','No study loaded','button','ok');
    return;
end

fmt = {'Subject-wise','Trial-wise'};
fmap = containers.Map('KeyType','char','ValueType','char');

BLANK = '              ';

c = {... %select datasets
     {'text','string','Datasets:'},...
     {'listbox','string',BLANK,'tag','sets','max',2};... %max > 1 allows multi selection
     {'pushbutton','string','Add','Callback',@(varargin) SetOps('add')},...
     {'pushbutton','string','Remove','Callback',@(varargin) SetOps('rm')};...
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
    keys = fmap.keys;
    if ~isempty(kplot) && fmap.Count > 0
        param.files = cellfun(@(x) fmap(x),keys(kplot),'uni',false);
        param.fmt = lower(fmt{win.GetElementProp('fmt','value')});
        me = FT.average.grand.Run(param);
        if isa(me,'MException')
            FT.ProcessError(me);
            return;
        else
            FT.UpdateGUI;            
            FT.PlotERP;            
        end
    end    
end
%-----------------------------------------------------------------------------%
function SetOps(action)
    ksel = win.GetElementProp('sets','value');
    switch lower(action)
    case 'add'
        name = FT.study.subject.Select;
        if ~isempty(name)
            fpath = FT.study.subject.SelectFile(name);
            if ~isempty(fpath)
                [b,msg] = FT.average.grand.Verify(fpath);
                if ~b
                    msg = ['[ERROR]: ' msg];
                    FT.UserInput(msg,0,'title','Invalid dataset','button','OK');
                    return;
                end
            else
                return;    
            end
            [~,fname] = fileparts(fpath);
            fname = [name filesep fname];
            fmap(fname) = fpath;
        else
            return;
        end
        ksel = 1:fmap.Count;
    case 'rm'        
        keys = fmap.keys;
        for k = 1:numel(ksel)
            if (1 <= ksel(k)) && (ksel(k) <= numel(keys))
                fmap.remove(keys(ksel(k)));
            end
        end
        ksel = fmap.Count;
    otherwise
        %should never happen...
    end    
    if ksel(1)
        win.SetElementProp('sets','string',fmap.keys);        
    else
        ksel = 1;
        win.SetElementProp('sets','string',BLANK);
    end
    win.SetElementProp('sets','max',numel(ksel));
    win.SetElementProp('sets','value',ksel);
    win.ReSize;
    win.SetFocus('sets');
    drawnow;    
end
%-----------------------------------------------------------------------------%
end
