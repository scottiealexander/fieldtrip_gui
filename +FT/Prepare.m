function varargout = Prepare(varargin)

% FT.Prepare
%
% Description: prepare the FT_DATA struct and the matlab environment for fieldtrip
%
% Syntax: FT.Prepare(<options>)
%
% In: 
%   options:
%       type - ('all') one of:
%                       'all' : prepare everything
%                       'path': only prepare the Matlab search path for
%                               fieldtrip
%                       'data': only prepare (init from scratch) the FT_DATA 
%                               struct (***THIS WILL OVERWITE ANY EXISTING
%                               DATA***)
%
% Out: 
%
% Updated: 2014-06-27
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = FT.ParseOpts(varargin,...
    'type' , 'all' ...
    );

global FT_DATA;

if any(strcmpi(opt.type,{'all','data'}))
%------------------------------------------------------------------------------%
%initialize the FT_DATA struct    
    FT_DATA = struct('current_dataset','',...
         'size'     , []     ,...         
         'data'     , []     ,...
         'event'    , []     ,...
         'epoch'    , []     ,...
         'saved'    , false  ,...
         'gui'      , struct ,...
         'path'     , struct('base_directory','','raw_file','','dataset','',...
                      'template',''),...
         'template' , struct() ,...     
         'done'     , struct('remove_channels',false,...
                             'add_channels',false,...
                             'resample',false,...
                             'filter',false,...
                             'rereference',false,...
                             'read_events',false,...
                             'check_events',false,...
                             'relabel_events',false,...
                             'define_trials',false,...
                             'segment_trials',false,...
                             'baseline_trials',false,...
                             'reject_trials',false,...
                             'tfd',false,...
                             'average',false),...
         'history'  , struct()...
         );
    FT_DATA.template = {};
    FT_DATA.history = {};
    
    %screen size
    ROOT_UNITS = get(0,'Units');
    set(0,'Units','pixels');

    FT_DATA.gui.screen_size = get(0,'ScreenSize');
    set(0,'Units',ROOT_UNITS);
    
    %initial display mode
    FT_DATA.gui.display_mode = 'init';

    %initial display fields
    cInit = {{'path','template'},'current_dataset','size'};
    FT_DATA.gui.display_fields.init = cInit;

    %preproc display fields
    cPreProc = [cInit {'saved',{'done','remove_channels'},{'done','resample'},...
               {'done','filter'},{'done','rereference'},{'done','read_events'}}];
    FT_DATA.gui.display_fields.preproc = cPreProc;
    
    %segmentation display fields
    cAnalysis = [cInit {'saved',{'done','segment_trials'},{'done','baseline_trials'},...
        {'done','reject_trials'},{'done','tfd'},{'done','average'}}];
    FT_DATA.gui.display_fields.analysis = cAnalysis;
    
    %averaged display fields
    cAveraged = [cInit {'saved',{'done','average'},{'done','grand_average'}}];
    FT_DATA.gui.display_fields.averaged = cAveraged;
end

if any(strcmpi(opt.type,{'all','path'}))
%------------------------------------------------------------------------------%
% set up for fieldtrip
    %get matlab's entire search path
    strPath = path;

    %get file and path seperators for this platform
    if ispc
        %need an extra '\' to escape the pathsep on windows
        fs = ['\' filesep];
    else
        fs = filesep;
    end
    ps = ['\' pathsep];

    %extract the path to every 'fieldtrip' directory 
    % ***THIS IS REALLY IMPORTANT***
    pattern = [ps '?([' fs '\w]+[Ff]{1}ield[Tt]{1}rip[^' fs ps ']*' fs '?[\-\+\@\.\w' fs ']*)' ps '?'];    
    cDirRm = regexp(strPath,pattern,'tokens');
    cDirRm = cat(1,cDirRm{:});

    %temporarily remove all 'fieldtrip' directories (this ensure that there 
    %will be no clashes, and that we get the correct version of all fieldtrip
    %functions)
    if ~isempty(cDirRm) && numel(cDirRm) > 0
        rmpath(cDirRm{:});
    end

    %add the packaged version of fieldtrip to the matlab path
    strDirMain = fileparts(fileparts(mfilename('fullpath')));
    strDirFT = fullfile(strDirMain,'fieldtrip');    
    addpath(strDirMain,strDirFT);

    %and let fieldtrip set itself up
    hMsg = FT.UserInput('Initializing FieldTrip components... Please Wait.',1);
    try
        ft_defaults;
    catch me
        if ishandle(hMsg)
            close(hMsg);
        end
        s.message = ['An error was encountered trying to add FieldTrip to your matlab path. ',...
            'Please send an Error Report to the developer. Thanks!'];
        s.cause = me.cause;
        s.stack = me.stack;
        FT.ProcessError(s);
        varargout{1} = false;
        return;
    end
    
    %remove the hack ridden dropins that come with fieldtrip *IF* we have the
    %signal processing toolbox
    if license('test','Signal_Toolbox')
        rmpath(fullfile(strDirFT,'external','signal'));
    end
    
    if ishandle(hMsg)
        delete(hMsg);
    end
    varargout{1} = true;
%------------------------------------------------------------------------------%
end