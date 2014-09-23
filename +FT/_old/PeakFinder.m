function PeakFinder()

% FT.PeakFinder
%
% Description: 
%
% Syntax: FT.PeakFinder
%
% In: 
%
% Out: 
%
% Updated: 2013-09-05
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com
dbstop if error
global FT_DATA;

%make sure we have data...
if ~FT.tools.Validate('findpeaks','done',{'segment_trials'})
    return;
end

%initialize the important variables
WINDOW = [NaN NaN];
STAT = struct;
FS = FT_DATA.data{1}.fsample;

%get the window in which to find peaks
cfg = FT.trials.baseline.Gui('Peak & Valley Finder');

if ~isempty(cfg) && isfield(cfg,'baselinewindow')
    WINDOW = round(cfg.baselinewindow*FS)+1; 
    
    resp = FT.UserInput('\bfWould you like the output to be:\n1 file per-condition or\n1 file per-statistic?',...
                        1,'button',{'Condition','Statistic'},'title','Output Format');
    if isempty(resp)
        return;
    else
        bSingle = strcmpi(resp,'condition');
    end
    
    FT.UserInput('Please select an output directory.',1,'button','OK');
    strDirOut = fileparts(FT_DATA.path.dataset);
    strDirOut = uigetdir(strDirOut,'Select Output Directory');
    
    if isequal(strDirOut,0)
        return;
    end
    
    hMsg = FT.UserInput('Finding peaks & valleys...',1);        
    
    for k = 1:numel(FT_DATA.data)
        % --- OUTPUT PATH --- %
        if bSingle
            strPathOut = fullfile(strDirOut,[FT_DATA.current_dataset '-' FT_DATA.epoch{k}.name '-peak_stats.csv']);

            %add channel labels
            STAT.channel = FT_DATA.data{k}.label;
        else
           %add channel label
           STAT.peak_amplitude.channel   = FT_DATA.data{k}.label;
           STAT.peak_latency.channel     = FT_DATA.data{k}.label;
           STAT.valley_amplitude.channel = FT_DATA.data{k}.label;
           STAT.valley_latency.channel   = FT_DATA.data{k}.label;
        end    
    
        %is this averaged data?
        if isfield(FT_DATA.data{k},'trial')
            cellfun(@(x,y) FindPeak(x,y),FT_DATA.data{k}.trial,num2cell(1:numel(FT_DATA.data{k}.trial)));
        elseif isfield(FT_DATA.data{k},'avg')
            FindPeak(FT_DATA.data{k}.avg,1);
        else
            error('could not find data. make sure data has been loaded before proceeding');
        end

        %write the data
        if bSingle
            %single file
            fprintf('[INFO]: Writing file: %s\n',strPathOut);
            if ~FT.io.WriteStruct(STAT,'output',strPathOut)
                me = MException('WriteStruct:WriteError',['Failed to write file ' strPathOut]);
                FT.ProcessError(me);
            end
        else
            %multiple files
            cPathOut = cellfun(@(x) fullfile(strDirOut,[x '-' FT_DATA.epoch{1}.name '-' FT_DATA.current_dataset '.csv']),fieldnames(STAT),'uni',false);
            fprintf('[INFO]: Writing files:\n%s\n',FT.Join(cPathOut,10));
            b = cellfun(@(x,y) FT.io.WriteStruct(STAT.(x),'output',y),fieldnames(STAT),cPathOut);
            if ~all(b)
                me = MException('WriteStruct:WriteError',['Failed to write file(s) :' 10 FT.Join(cPathOut(~b),10)]);
                FT.ProcessError(me);
            end
        end
    end
    if ishandle(hMsg)
        close(hMsg);
    end
end

%------------------------------------------------------------------------------%
function FindPeak(data,kTrial)
    
    strTrial = num2str(kTrial);
    
    [mx_amp,mx_lat] = max(data(:,WINDOW(1):WINDOW(2)),[],2);
    [mn_amp,mn_lat] = min(data(:,WINDOW(1):WINDOW(2)),[],2);
    
    %NOTE: latencies are converted to seconds relative to the time locking event
    %so tEvt is the latency of the timelocking event relative to the
    %start of the trial. if segments are defined relative to trial start then
    %tEvt is 0 and samples are just converted to seconds
    if bSingle
        STAT.(['max_amp_' strTrial ]) = reshape(mx_amp,[],1);
        STAT.(['max_lat_' strTrial ]) = (reshape(mx_lat,[],1) + WINDOW(1)-1)/FS - FT_DATA.epoch{1}.ifo.pre;
        STAT.(['min_amp_' strTrial ]) = reshape(mn_amp,[],1);
        STAT.(['min_lat_' strTrial ]) = (reshape(mn_lat,[],1) + WINDOW(1)-1)/FS - FT_DATA.epoch{1}.ifo.pre;
    else
        STAT.peak_amplitude.(['trial_' strTrial]) = reshape(mx_amp,[],1);
        STAT.peak_latency.(['trial_' strTrial]) = (reshape(mx_lat,[],1) + WINDOW(1)-1)/FS - FT_DATA.epoch{1}.ifo.pre;
        STAT.valley_amplitude.(['trial_' strTrial]) = reshape(mn_amp,[],1);
        STAT.valley_latency.(['trial_' strTrial]) = (reshape(mn_lat,[],1) + WINDOW(1)-1)/FS - FT_DATA.epoch{1}.ifo.pre;
    end
end
%------------------------------------------------------------------------------%
end
