function GUI()

% FT.GUI
%
% Description: master GUI for fieldtrip toolbox
%
% Syntax: FT.GUI
%
% In: 
%
% Out: 
%
% Updated: 2013-08-30
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

dbstop if error;

global FT_DATA;

%prepare everything we need for our FieldTrip GUI analysis session
if ~FT.Prepare
    return;
end

%initialize the GUI figure
wFig = 480;
hFig = 350;
lFig = 200;
bFig = 200;

h = figure('Units','pixels','OuterPosition',[lFig bFig wFig hFig],...
           'Name','FieldTrip GUI','NumberTitle','off','MenuBar','none',...
           'CloseRequestFcn',@GUICloseFcn);

%axes for text display
FT_DATA.gui.hAx = axes('Visible','off','Units','normalized','Position',[0,0,1,1],...
           'Parent',h);

%the text
FT_DATA.gui.hText = text(.05,.90,'\bfAnalysis Name\rm:','Units','normalized','FontSize',12,...
            'Parent',FT_DATA.gui.hAx);

FT_DATA.gui.sizText = get(FT_DATA.gui.hText,'Extent');
FT.UpdateGUI;

%file operations
    hFileMenu = uimenu(h,'Label','File');

    %initialize or load a dataset for processing
    hInit = uimenu(hFileMenu,'Label','Initialize Analysis','Callback',@InitAnalysis,...
        'Accelerator','N');
    hLoad = uimenu(hFileMenu,'Label','Load Existing Analysis','Callback',@LoadAnalysis,...
        'Accelerator','I');

    %read in raw files
    hRead = uimenu(hFileMenu,'Label','Load Data');
    uimenu(hRead,'Label','EEG File / Dataset','Callback',@FileOps,'Accelerator','L');
    uimenu(hRead,'Label','Neuralynx Dataset','Callback',@FileOps);    
    
    %save
    uimenu(hFileMenu,'Label','Save Dataset','Callback',@SaveDataset);
    
    %save as
    uimenu(hFileMenu,'Label','Save Dataset As...',...
        'Callback',@(x,y) SaveDataset(x,y,'as'),'Accelerator','S');
    
    %clear 
    uimenu(hFileMenu,'Label','Clear Dataset','Callback',@ClearDataset);
    
    %quit
    uimenu(hFileMenu,'Label','Quit','Callback',@QuitGUI);
    
%view operations
    hViewMenu = uimenu(h,'Label','View');
    hViewIfo  = uimenu(hViewMenu,'Label','Data Info','Callback',@(x,y) FT.RunFunction(x,y,@FT.DataSummery));
    hViewData = uimenu(hViewMenu,'Label','Channel Data','Callback',@(x,y) FT.RunFunction(x,y,@FT.PlotData));
    hViewERPim= uimenu(hViewMenu,'Label','ERP Image','Callback',@(x,y) FT.RunFunction(x,y,@FT.ERPImage));
    hViewCorr = uimenu(hViewMenu,'Label','Channel Correlations','Callback',@(x,y) FT.RunFunction(x,y,@FT.ChannelCorr));
    hViewCoh  = uimenu(hViewMenu,'Label','Channel Coherence','Callback',@(x,y) FT.RunFunction(x,y,@FT.Coherence));
    hViewERP  = uimenu(hViewMenu,'Label','Average ERP','Callback',@(x,y) FT.RunFunction(x,y,@FT.PlotERP));    
    %hViewPow  = uimenu(hViewMenu,'Label','Average Power Spectra','Callback',@(x,y) FT.RunFunction(x,y,@() FT.PlotPower('spectra')));
    hViewSpec = uimenu(hViewMenu,'Label','Average Spectrogram','Callback',@(x,y) FT.RunFunction(x,y,@() FT.PlotPower('spectrogram')));
    hReDraw   = uimenu(hViewMenu,'Label','Redraw GUI Display','Callback',@(x,y) FT.RunFunction(x,y,@FT.RedrawGUI));
    
%preprocessing
    hProcMenu = uimenu(h,'Label','Preprocessing');
    hChanVeiw = uimenu(hProcMenu,'Label','Remove Channels','Callback',@(x,y) FT.RunFunction(x,y,@FT.RemoveChannels));
    hReSamp   = uimenu(hProcMenu,'Label','Resample Data','Callback',@(x,y) FT.RunFunction(x,y,@FT.Resample));
    hReFilt   = uimenu(hProcMenu,'Label','Filter Data','Callback',@(x,y) FT.RunFunction(x,y,@FT.Filter));
    hReRef    = uimenu(hProcMenu,'Label','Rereference Data','Callback',@(x,y) FT.RunFunction(x,y,@FT.Rereference));
    hNewChan  = uimenu(hProcMenu,'Label','Create New Channel','Callback',@(x,y) FT.RunFunction(x,y,@FT.NewChannel));
    hBPFilt   = uimenu(hProcMenu,'Label','Bandpass Filter','Callback',@(x,y) FT.RunFunction(x,y,@FT.BandPass));
    
%segmentation
    hSegMenu  = uimenu(h,'Label','Segmentation');
    hFndEvt   = uimenu(hSegMenu,'Label','Process Events','Callback',@(x,y) FT.RunFunction(x,y,@FT.ProcessEvents));
    hRecodeEvt= uimenu(hSegMenu,'Label','Re-label Events','Callback',@(x,y) FT.RunFunction(x,y,@FT.RecodeEvents));
    hChkEvt   = uimenu(hSegMenu,'Label','Manual Event Checking','Callback',@(x,y) FT.RunFunction(x,y,@FT.CheckEvents));
    hDefTrial = uimenu(hSegMenu,'Label','Segment Trials','Callback',@(x,y) FT.RunFunction(x,y,@FT.SegmentTrials));
    hBaseCor  = uimenu(hSegMenu,'Label','Baseline Correct','Callback',@(x,y) FT.RunFunction(x,y,@FT.BaselineCorrect));
    hArtRej   = uimenu(hSegMenu,'Label','Reject Trials','Callback',@(x,y) FT.RunFunction(x,y,@FT.RejectTrials));    

%analysis
    hAnaMenu  = uimenu(h,'Label','Analysis');
    hAvgERP   = uimenu(hAnaMenu,'Label','Average ERPs','Callback',@(x,y) FT.RunFunction(x,y,@FT.AverageERP));
    hPeak     = uimenu(hAnaMenu,'Label','Find Peaks & Valleys','Callback',@(x,y) FT.RunFunction(x,y,@FT.PeakFinder));
    hPower    = uimenu(hAnaMenu,'Label','Power Spectrum','Callback',@(x,y) FT.RunFunction(x,y,@FT.PowerSpec));
    hSpec     = uimenu(hAnaMenu,'Label','Spectrogram','Callback','disp(''@(x,y) FT.RunFunction(x,y,@FT.Spectrogram)'')');
    
% %template operations
%     hTempMenu = uimenu(h,'Label','Template');
%     hSaveTemplate = uimenu(hTempMenu,'Label','Save Current Template','Callback','disp(''save current template'')');
%     hEditTemplate = uimenu(hTempMenu,'Label','Edit Current Template','Callback','disp(''edit current template'')');
%     hLoadTemplate = uimenu(hTempMenu,'Label','Load Existing Template','Callback','disp(''load existing template'')');

%-------------------------------------------------------------------------%
function FileOps(obj,evt)
    
    %move to the analysis base dir
    strDirCur = pwd;
    if isdir(FT_DATA.path.base_directory)        
        cd(FT_DATA.path.base_directory);       
    end
    
    %figure out what the user is trying to load
    str = get(obj,'Label');
    
    switch lower(str)
        case 'load existing analysis'
            strPath = uigetdir(pwd,'Load Existing Analysis');
            if isequal(strPath,0)
                cd(strDirCur);
                return; %user selected cancel
            end
        case 'eeg file / dataset'
            [strName,strPath] = uigetfile('*','Load File');
            if ~isequal(strName,0) && ~isequal(strPath,0)
                strPath = fullfile(strPath,strName);
            else
                cd(strDirCur);
                return; %user selected cancel
            end
        case 'neuralynx dataset'
            strPath = uigetdir(pwd,'Load Neuralynx Dataset');
            if isequal(strPath,0)
                cd(strDirCur);
                return; %user selected cancel
            end
        otherwise
            %this should never happen
    end
     
    [~,strName] = fileparts(RmSlash(strPath));
    FT_DATA.current_dataset = strName;
    FT_DATA.path.raw_file = strPath;
    
    %move back to the original directory
    cd(strDirCur);        
    
    %read the data
    hMsg = FT.UserInput('Reading data from file, plese wait...',1);
    ReadDataset(strPath);
    
    if strcmpi(FT_DATA.gui.display_mode,'init')
        FT_DATA.gui.display_mode = 'preproc';
    end
    
    %update the display
    FT.UpdateGUI;
    
    if ishandle(hMsg)
        close(hMsg);
    end
end
%-------------------------------------------------------------------------%
function InitAnalysis(obj,evt)
    
    %make sure the user understands what we want
    strQ = '\fontsize{14}\bfPlease select a base diretcory for this analysis.';
    FT.UserInput(strQ,1,'button','OK');
    
    %get the base directory
    strPath = uigetdir(pwd,'Select Base Directory');
    if isequal(strPath,0)
        return; %user selected cancel
    end
    FT_DATA.path.base_directory = strPath;
    strName = FT.UserInput('Please enter a name for this analysis:',1,...
                        'title','Select Analysis Name',...
                        'button',{'OK','cancel'},'input',true,...
                        'inp_str',[strrep(datestr(now,29),'-','') '_Analysis']...
                        );
    if isempty(strName)
        return; %user selected cancel
    end
    
    FT_DATA.analysis_name = strName;    
    FT_DATA.path.template = fullfile(strPath,[strName '.template']);
    
    SaveAnalysisCfg;
    
    FT.UpdateGUI;
end
%-------------------------------------------------------------------------%
function LoadAnalysis(obj,evt)
    %get the base directory
    strPath = uigetdir(pwd,'Select Analysis Directory');
    if isequal(strPath,0)
        return; %user selected cancel
    end
    
    %set the base dir
    FT_DATA.path.base_directory = strPath;
    
    strPathCfg = fullfile(strPath,'analysis.cfg');
    
    if exist(strPathCfg,'file') ~= 2
        FT.UserInput(['Sorry, no analysis has been initialized in this directory.\n'...
            'Please use \bfFile->Initialize Analysis\rm\nto initialize an analysis.'],0,'button','OK');
        return;
    end
    
    fid = fopen(strPathCfg,'r');
    if fid < 0
        return;
    end
    str = cast(fread(fid,'char'),'char')';
    fclose(fid);
    s = FT.ReStruct(regexp(str,'(?<field>[\S]*)\t(?<value>[\S]*)','names'));
    for k = 1:numel(s.field)
        cField = regexp(s.field{k},'\.','split');
        if all(ismember(s.value{k},'0123456789.-+e'))
            val = str2double(s.value{k});
        else
            val = s.value{k};
        end
        FT_DATA = AssignField(FT_DATA,cField,val);
    end
    FT.UpdateGUI;
end
%-------------------------------------------------------------------------%
function SaveAnalysisCfg
%save the analysis configuration file
    strPathCfg = fullfile(FT_DATA.path.base_directory,'analysis.cfg');
    fid = fopen(strPathCfg,'w');
    if fid < 0
        return;
    end
    fprintf(fid,'analysis_name\t%s\npath.template\t%s\n',FT_DATA.analysis_name,FT_DATA.path.template);
    fclose(fid);
end
%-------------------------------------------------------------------------%
function SaveDataset(obj,evt,varargin)
%save the current state of the analysis

    %save or save as?
    if ~isempty(varargin) && ischar(varargin{1}) && strcmp(varargin{1},'as')
        %move into the subjects dir or base dir for this analysis
        if isfield(FT_DATA.path,'raw_file') && ~isempty(FT_DATA.path.raw_file)
            strDir = fileparts(FT_DATA.path.raw_file);
        else
            strDir = FT_DATA.path.base_directory;
        end
        
        %get the filepath the user wants to sue
        strPathDef = fullfile(strDir,[FT_DATA.current_dataset '.set']);
        [strName,strPath] = uiputfile('*.set','Save Analysis As...',strPathDef);
        
        %construct the file path
        if ~isequal(strName,0) && ~isequal(strPath,0)
            strPathOut = fullfile(strPath,strName);            
        else
            return; %user selected cancel
        end
    elseif ~FT_DATA.saved
        %get the most likely path name
        if ~isempty(FT_DATA.path.dataset)
            strPathOut = FT_DATA.path.dataset;
        elseif ~isempty(FT_DATA.path.raw_file)
            strPathOut = FT_DATA.path.raw_file;
        else            
            return; %nothing to save
        end
    else
        %user selected save and no changes have been made.
        FT.UserInput(['\bfNo changes have been made since the last save. '...
            'Use ''Save As'' to save a copy of the dataset'],1,'button','OK');
        return;
    end
    
    %force extension to be '.set'
    strPathOut = regexprep(strPathOut,'\.[\w\-\+\.]+$','.set');
    FT_DATA.path.dataset = strPathOut;
    
    %get the new dataset name
    [~,FT_DATA.current_dataset] = fileparts(strPathOut);
    
    %mark as saved
    FT_DATA.saved = true;
    
    if ~FT_DATA.debug
        hMsg = FT.UserInput('Saving dataset, plese wait...',1); 
        
        bAdd = false;
        
        if isfield(FT_DATA,'analysis_name')
            %save configuration
            SaveAnalysisCfg;

            %remove the analysis name and gui fields as these can change
            strName = FT_DATA.analysis_name;
            FT_DATA = rmfield(FT_DATA,'analysis_name');
            bAdd = true;
        end
        
        gui = FT_DATA.gui;
        FT_DATA.gui = rmfield(FT_DATA.gui,{'hAx','hText','sizText'});
        
        %save
        WriteDataset(strPathOut);
        if ishandle(hMsg)
            close(hMsg);
        end
        
        if bAdd
            FT_DATA.analysis_name = strName;
        end
        FT_DATA.gui = gui;
    end
    FT.UpdateGUI;
end
%-------------------------------------------------------------------------%
function ClearDataset(obj,evt)
    resp = FT.UserInput('Are you sure you want to clear the current dataset?',...
                        0,'button',{'Yes','Cancel'},'title','Clear Dataset?');
    if strcmpi(resp,'yes')
        %grab the fields that we will still need
        gui  = FT_DATA.gui;
        name = FT_DATA.analysis_name;
        base = FT_DATA.path.base_directory;
        template = FT_DATA.path.template;
        
        %renew the FT_DATA struct
        FT_DATA = [];
        FT.Prepare('type','data');
        
        %add the fields back in 
        gui.display_mode = 'init'; %set display mode back to initial
        FT_DATA.gui = gui;
        FT_DATA.analysis_name = name;
        FT_DATA.path.base_directory = base;
        FT_DATA.path.template = template;
        
        %update the GUI
        FT.UpdateGUI;
    end
end
%-------------------------------------------------------------------------%
function QuitGUI(obj,evt)
    if FT_DATA.saved || ~isfield(FT_DATA,'data') || isempty(FT_DATA.data)
        %data is saved or there is none, print our message and quit
    else        
        resp = FT.UserInput('\fontsize{14}\bfThis dataset has unsaved changes.\nWould you like to save them?',1,...
                'button',{'Yes','No'},'title','Unsaved Changes');
        if strcmpi(resp,'yes')
            SaveDataset(obj,evt,'as');
            if ~FT_DATA.saved
                return;
            end
        end
    end
    fprintf(['*****\nThank you for using the FieldTrip GUI.\n'...
                 'Cleaning up and ending analysis session...\n*****\n']);
    if ishandle(h)
        GUICloseFcn('force');
    end
    clear('global','FT_DATA');
    evalin('base','clear FT_DATA');
end
%-------------------------------------------------------------------------%
function GUICloseFcn(varargin)
%helps to prevent accidental closure of the main GUI figure
    if ~isempty(varargin) && ischar(varargin{1}) && strcmpi(varargin{1},'force')
        delete(h);
    else
        resp = FT.UserInput('Are you sure you want to close the GUI?',1,'button',{'No','Yes'});
        if strcmpi(resp,'yes')
            QuitGUI([],[]);
        end
    end
end
%-------------------------------------------------------------------------%
function s = AssignField(s,c,val)
%assign a field to the FT_DATA struct given a field path as a cell of field
%names
    if iscell(c) && numel(c) > 1        
        s.(c{1}) = AssignField(s.(c{1}),c{2:end},val);
    elseif iscell(c) && numel(c) == 1
        s.(c{1}) = val;
    elseif ischar(c)
        s.(c) = val;
    else
        %pass        
    end
end
%-------------------------------------------------------------------------%
function str = RmSlash(str)
%remove the trailing slash from a path if need be
    if str(end) == '/'
        str = str(1:end-1);
    end
end
%-------------------------------------------------------------------------%
end