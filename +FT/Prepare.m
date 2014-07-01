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
    FT_DATA = struct('current_dataset','','analysis_name', '',...
         'size'     , []     ,...         
         'data'     , []     ,...
         'event'    , []     ,...
         'epoch'    , []     ,...
         'saved'    , false  ,...
         'gui'      , struct ,...
         'path'     , struct('base_directory','','raw_file','','dataset','',...
                      'template',''),...
         'template' , struct() ,...     
         'done'     , struct('rm_channel',false,'resample',false,'filter',false,...
                      'rereference',false,'read_events',false,'segmentation',false,...
                      'baseline_correction',false,'trial_rejection',false,...
                      'average',false),...
         'history'  , struct('rm_channel',[],'resample',[],'filter',[],...
                      'rereference',[],'add_channel',[],'detect_events',[],...
                      'segmentation',[],'baseline_correction',[],'trial_rejection',[])...
         );

    %screen size
    ROOT_UNITS = get(0,'Units');
    set(0,'Units','pixels');

    FT_DATA.gui.screen_size = get(0,'ScreenSize');
    set(0,'Units',ROOT_UNITS);
     
    FT_DATA.debug = false;

    %initial display mode
    FT_DATA.gui.display_mode = 'init';

    %initial display fields
    cInit = {'analysis_name','current_dataset','size'};
    FT_DATA.gui.display_fields.init = cInit;

    %preproc display fields
    cPreProc = [cInit {'saved',{'done','rm_channel'},{'done','resample'},...
               {'done','filter'},{'done','rereference'},{'done','read_events'}}];
    FT_DATA.gui.display_fields.preproc = cPreProc;
    
    %segmentation display fields
    cSegment = [cInit {'saved',{'done','segmentation'},{'done','baseline_correction'},...
        {'done','trial_rejection'}}];
    FT_DATA.gui.display_fields.segment = cSegment;
    
    %analysis display fields
    cAnalysis = [cInit {'saved',{'done','average'}}];
    FT_DATA.gui.display_fields.analysis = cAnalysis;
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