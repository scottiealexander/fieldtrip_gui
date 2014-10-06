function DataSummery(varargin)

% FT.DataSummery
%
% Description: display a summery of the data in a UserInput figure
%
% Syntax: FT.DataSummery
%
% In: 
%
% Out: 
%
% Updated: 2013-08-20
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%make sure we are ready to run
if ~FT.tools.Validate('summery')
    return;
end

if isstruct(FT_DATA.data) && isfield(FT_DATA.data,'trial')
    time = FT_DATA.data.time{1};
    nTrial = numel(FT_DATA.data.trial);
    nSamp = size(FT_DATA.data.trial{1},2);
    cLabel = FT_DATA.data.label;
    nCond = 0;
    fsample = FT_DATA.data.fsample;
elseif iscell(FT_DATA.data)
    if isfield(FT_DATA.data{1},'trial')
        time  = FT_DATA.data{1}.time{1};
        nTrial = sum(cellfun(@(x) numel(x.trial),FT_DATA.data));
    elseif isfield(FT_DATA.data{1},'avg')        
        nTrial = 1;
        time  = FT_DATA.data{1}.time;
    end
    nCond = numel(FT_DATA.data);
    nSamp = size(time,2);
    cLabel= FT_DATA.data{1}.label;
    fsample = FT_DATA.data{1}.fsample;
end

%file/dataset info
str = ['\bf% ---- File Info ---- %\rm' 10];
str = [str 'Original File: ' TxCol(FT_DATA.path.raw_file) 10];
str = [str 'Dataset File: ' TxCol(FT_DATA.path.dataset) 10];
str = [str 'Dataset Name: ' TxCol(FT_DATA.current_dataset) 10 10];

%data info
str = [str '\bf% ---- Data Info ---- %\rm' 10];
str = [str 'Format: ' TxCol(GetFormat) 10];
str = [str 'Number of Trials: ' TxCol(nTrial) 10];
str = [str 'Number of Conditions: ' TxCol(nCond) 10];
str = [str 'Number of Channels: ' TxCol(numel(cLabel)) 10];
str = [str 'Number of Samples: ' TxCol(nSamp) 10];
str = [str 'Sampling Rate [Hz]: ' TxCol(fsample) 10];
str = [str 'Time Range [sec]: ' TxCol(min(time)) ' - ' TxCol(max(time)) 10 10];

%preprocessing stages
str = [str '\bf% ---- Preprocessing ---- %\rm' 10];
str = [str 'Remove Channels: ' Bool2Str(FT_DATA.done.remove_channels) 10];
str = [str 'Add Channels: ' Bool2Str(FT_DATA.done.add_channels) 10];
str = [str 'Resample: ' Bool2Str(FT_DATA.done.resample) 10];
str = [str 'Filter: ' Bool2Str(FT_DATA.done.filter) 10];
str = [str 'Rereference: ' Bool2Str(FT_DATA.done.rereference) 10 10];
% str = [str FmtNewChan 10];

%segmentation
str = [str '\bf% ---- Segmentation ---- %\rm' 10];
str = [str 'Read Events: ' Bool2Str(FT_DATA.done.read_events) 10];
str = [str 'Relabel Events: ' Bool2Str(FT_DATA.done.relabel_events) 10];
str = [str 'Define Trials: ' Bool2Str(FT_DATA.done.define_trials) 10];
str = [str 'Segment Trials: ' Bool2Str(FT_DATA.done.segment_trials) 10];
str = [str 'Baseline Correction: ' Bool2Str(FT_DATA.done.baseline_trials) 10];
str = [str 'Trial Rejection: ' Bool2Str(FT_DATA.done.reject_trials) 10];

%more to come

%display the summery
FT.UserInput(str,1,'button','OK','title','Data Summery','wrap',false);

%------------------------------------------------------------------------------%
function s = Bool2Str(b)
%convert logicals to 'done' and 'not done' for preprocessing stages
    if b
        s = '\color{blue}DONE\color{black}';
    else
        s = '\color{yellow}NOT DONE\color{black}';
    end
end
%------------------------------------------------------------------------------%
function s = TxCol(b)
%converts number (or string) to a string colored blue
    s = ['\color{blue}' num2str(b) '\color{black}'];
end
%------------------------------------------------------------------------------%
function strFmt = GetFormat
    if isstruct(FT_DATA.data)
        if isfield(FT_DATA.data,'trial') && numel(FT_DATA.data.trial) > 1
            strFmt = 'segmented';
        else
            strFmt = 'continuous';
        end
    elseif iscell(FT_DATA.data)
        if isfield(FT_DATA.data{1},'trial')
            strFmt = 'segmented';
        elseif isfield(FT_DATA.data{1},'avg')
            strFmt = 'averaged';
        else
            strFmt = 'undefined';
        end
    else
        strFmt = 'undefined';
    end
end
%------------------------------------------------------------------------------%
end