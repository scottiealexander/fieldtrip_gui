function me = Run(params)

% FT.findpeaks.Run
%
% Description: find peaks and valleys in segmented data
%
% Syntax: me = FT.findpeaks.Run(params)
%
% In:   params - a struct holding parameters from the user
%
% Out:  me - an empty matrix if processing finished with out error,
%            otherwise a MException object caught from the error
%
% Updated: 2014-09-23
% Peter Horak
%
% See also: FT.findpeaks.Gui

global FT_DATA;
me = [];

try
    %initialize important variables
    STAT = struct;
    FS = FT_DATA.data{1}.fsample;
    
    %user-specified parameters
    WINDOW = params.window;
    bSingle = params.bSingle;
    strDirOut = params.strDirOut;
    
    for k = 1:numel(FT_DATA.data)
        % --- OUTPUT PATH --- %
        if ~isempty(FT_DATA.path.dataset)
            [~,current_dataset] = fileparts(FT_DATA.path.dataset);
        elseif ~isempty(FT_DATA.path.raw_file)
            [~,current_dataset] = fileparts(FT_DATA.path.raw_file);
        else
            current_dataset = '';
        end
            
        if bSingle
            strPathOut = fullfile(strDirOut,[current_dataset '-' FT_DATA.epoch{k}.name '-peak_stats.csv']);

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
            cPathOut = cellfun(@(x) fullfile(strDirOut,[x '-' FT_DATA.epoch{k}.name '-' current_dataset '.csv']),fieldnames(STAT),'uni',false);
            fprintf('[INFO]: Writing files:\n%s\n',FT.Join(cPathOut,10));
            b = cellfun(@(x,y) FT.io.WriteStruct(STAT.(x),'output',y),fieldnames(STAT),cPathOut);
            if ~all(b)
                me = MException('WriteStruct:WriteError',['Failed to write file(s) :' 10 FT.Join(cPathOut(~b),10)]);
                FT.ProcessError(me);
            end
        end
    end
catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('findpeaks',params);
FT_DATA.done.findpeaks = isempty(me);

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