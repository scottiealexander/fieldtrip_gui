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
if ~FT.CheckStage('summery')
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
str = [str 'Original File: ' FT_DATA.path.raw_file 10];
str = [str 'Dataset File: ' FT_DATA.path.dataset 10];
str = [str 'Dataset Name: ' FT_DATA.current_dataset 10 10];

%data info
str = [str '\bf% ---- Data Info ---- %\rm' 10];
str = [str 'Format: ' GetFormat 10];
str = [str 'Number of Trials: ' num2str(nTrial) 10];
str = [str 'Number of Conditions: ' num2str(nCond) 10];
str = [str 'Number of Channels: ' num2str(numel(cLabel)) 10];
str = [str 'Number of Samples: ' num2str(nSamp) 10];
str = [str 'Sampling Rate [Hz]: ' num2str(fsample) 10];
str = [str 'Time Range [sec]: ' num2str(min(time)) ' - ' num2str(max(time)) 10 10];

%preprocessing stages
str = [str '\bf% ---- Preprocessing ---- %\rm' 10];
str = [str 'Remove Channels: ' Bool2Str(FT_DATA.done.rm_channel) 10];
str = [str 'Resample: ' Bool2Str(FT_DATA.done.resample) 10];
str = [str 'Filter: ' Bool2Str(FT_DATA.done.filter) 10];
str = [str 'Rereference: ' Bool2Str(FT_DATA.done.rereference) 10];
str = [str FmtNewChan 10];

%segmentation
str = [str '\bf% ---- Segmentation ---- %\rm' 10];
str = [str 'Segment Trials: ' Bool2Str(FT_DATA.done.segmentation) 10];
str = [str 'Baseline Correction: ' Bool2Str(FT_DATA.done.baseline_correction) 10];
str = [str 'Trial Rejection: ' Bool2Str(FT_DATA.done.trial_rejection) 10];

%more to come

%display the summery
FT.UserInput(str,1,'button','OK','title','Data Summery','wrap',false);

%------------------------------------------------------------------------------%
function s = Bool2Str(b)
%convert logicals to 'done' and 'not done' for preprocessing stages
    if b
        s = 'DONE';
    else
        s = 'NOT DONE';
    end
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
function s = FmtNewChan
    if isfield(FT_DATA.history,'add_channel')
        chan = FT_DATA.history.add_channel;
        if ~isempty(chan)
            cFields = fieldnames(chan);
            cFields = cellfun(@(x) [x ' = ' chan.(x)],cFields,'uni',false);
            s = ['Add Channels: ' 10 '        ' FT.Join(cFields,[10 '        ']) 10];
        else
            s = '';
        end
    else
        s = '';
    end
end
%------------------------------------------------------------------------------%
end