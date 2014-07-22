function PlotData(varargin)

% FT.PlotData
%
% Description: plot data using FT.tools.DataBrowser
%
% Syntax: FT.PlotData
%
% In: 
%
% Out: 
%
% Updated: 2014-07-28
% Peter Horak

global FT_DATA;

%make sure we are ready to run
if ~FT.tools.Validate('plot')
    return;
end

if ~FT_DATA.done.segment_trials
    FT.tools.DataBrowser(FT_DATA.data.time{1},FT_DATA.data.trial{1},'channel',4,FT_DATA.data.label);
else
    condition_names = cellfun(@(x) x.name,FT_DATA.epoch,'uni',false);
    c = {{'text','string','Condition #:'},...
         {'listbox','String',condition_names,'tag','condition'};...
         {'pushbutton','string','View'},...
         {'pushbutton','string','Cancel'}...
        };
    win = FT.tools.Win(c,'title','Condition Selection');
    uicontrol(win.GetElementProp('condition','h'));
    uiwait(win.h);
    
    if strcmpi(win.res.btn,'view')
        i = win.res.condition;
        FT.tools.DataBrowser(FT_DATA.data{i}.time{1},cat(3,FT_DATA.data{i}.trial{:}),'channel',4,FT_DATA.data{i}.label);
    end
end

end