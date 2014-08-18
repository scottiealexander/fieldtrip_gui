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
% Updated: 2014-06-27
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

dbstop if error;

global FT_DATA;

FT.Update(true);

%prepare everything we need for our FieldTrip GUI analysis session
if ~FT.Prepare
    return;
end

%initialize the GUI figure
pFig = GetFigPosition(480,350,'xoffset',200,'yoffset',200,'reference','absolute');

h = figure('Units','pixels','OuterPosition',pFig,...
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

% File operations
hFileMenu = uimenu(h,'Label','File');

% Template operations
hTempMenu = uimenu(hFileMenu,'Label','Template');
uimenu(hTempMenu,'Label','Create Template','Callback',@(varargin) FT.RunFunction(@FT.template.Create));
uimenu(hTempMenu,'Label','Edit Current Template','Callback',@(varargin) FT.RunFunction(@FT.template.Edit));
uimenu(hTempMenu,'Label','Save Current Template','Callback',@(varargin) FT.RunFunction(@FT.template.Save));
uimenu(hTempMenu,'Label','Load Existing Template','Callback',@(varargin) FT.RunFunction(@FT.template.Load));
uimenu(hTempMenu,'Label','Run Current Template','Callback',@(varargin) FT.RunFunction(@FT.template.Run));

%read in data
hRead = uimenu(hFileMenu,'Label','Load Data');
uimenu(hRead,'Label','EEG File / Dataset','Callback',@FT.io.Gui,'Accelerator','L');
uimenu(hRead,'Label','Neuralynx Dataset','Callback',@FT.io.Gui);

%save
uimenu(hFileMenu,'Label','Save Dataset','Callback',@SaveDataset);

%save as
uimenu(hFileMenu,'Label','Save Dataset As...',...
    'Callback',@(x,y) SaveDataset(x,y,'as'),'Accelerator','S');

%save ERP
uimenu(hFileMenu,'Label','Save Average Dataset',...
    'Callback',@(x,y) SaveDataset(x,y,'avg'));

%clear 
uimenu(hFileMenu,'Label','Clear Dataset','Callback',@ClearDataset);

%quit
uimenu(hFileMenu,'Label','Quit','Callback',@QuitGUI);

% View operations
hViewMenu = uimenu(h,'Label','View');
uimenu(hViewMenu,'Label','Data Info','Callback',@(varargin) FT.RunFunction(@FT.DataSummery));
uimenu(hViewMenu,'Label','Channel Data','Callback',@(varargin) FT.RunFunction(@FT.PlotData));
uimenu(hViewMenu,'Label','Average ERP','Callback',@(varargin) FT.RunFunction(@FT.PlotERP));
uimenu(hViewMenu,'Label','ERP Image','Callback',@(varargin) FT.RunFunction(@FT.ERPImage));
uimenu(hViewMenu,'Label','Plot PSD','Callback',@(varargin) FT.RunFunction(@FT.PlotPSD));
uimenu(hViewMenu,'Label','Channel Correlations','Callback',@(varargin) FT.RunFunction(@FT.ChannelCorr));
uimenu(hViewMenu,'Label','Channel Coherence','Callback',@(varargin) FT.RunFunction(@FT.Coherence));    
uimenu(hViewMenu,'Label','Redraw GUI Display','Callback',@(varargin) FT.RunFunction(@FT.RedrawGUI));

% Preprocessing
hProcMenu = uimenu(h,'Label','Preprocessing');
uimenu(hProcMenu,'Label','Remove Channels','Callback',@(varargin) FT.RunFunction(@FT.channels.remove.Gui));
uimenu(hProcMenu,'Label','Add New Channel','Callback',@(varargin) FT.RunFunction(@FT.channels.add.Gui));
uimenu(hProcMenu,'Label','Resample Data','Callback',@(varargin) FT.RunFunction(@FT.resample.Gui));
uimenu(hProcMenu,'Label','Filter Data','Callback',@(varargin) FT.RunFunction(@FT.filter.Gui));
uimenu(hProcMenu,'Label','Rereference Data','Callback',@(varargin) FT.RunFunction(@FT.rereference.Gui));

% Segmentation
hSegMenu  = uimenu(h,'Label','Segmentation');
uimenu(hSegMenu,'Label','Process Events','Callback',@(varargin) FT.RunFunction(@FT.events.read.Gui));
uimenu(hSegMenu,'Label','Re-label Events','Callback',@(varargin) FT.RunFunction(@FT.events.relabel.Gui));
uimenu(hSegMenu,'Label','Manual Event Checking','Callback',@(varargin) FT.RunFunction(@FT.events.check.Gui));
uimenu(hSegMenu,'Label','Segment Trials','Callback',@(varargin) FT.RunFunction(@FT.trials.segment.Gui));
uimenu(hSegMenu,'Label','Baseline Correct','Callback',@(varargin) FT.RunFunction(@FT.trials.baseline.Gui));
uimenu(hSegMenu,'Label','Reject Trials','Callback',@(varargin) FT.RunFunction(@FT.trials.reject.Gui));

% Analysis
hAnaMenu  = uimenu(h,'Label','Analysis');
uimenu(hAnaMenu,'Label','Average ERPs','Callback',@(varargin) FT.RunFunction(@FT.AverageERP));
uimenu(hAnaMenu,'Label','Time-Frequency Decomposition','Callback',@(varargin) FT.RunFunction(@FT.tfd.Gui));
uimenu(hAnaMenu,'Label','ERP Grand Average','Callback',@(varargin) FT.RunFunction(@FT.GrandAverage));
uimenu(hAnaMenu,'Label','Find Peaks & Valleys','Callback',@(varargin) FT.RunFunction(@FT.PeakFinder));

% Update
hUpdMenu = uimenu(h,'Label','Update');
uimenu(hUpdMenu,'Label','Update Toolbox','Callback',@(varargin) FT.Update(false));

%-------------------------------------------------------------------------%
function SaveDataset(~,~,varargin)
%save the current state of the analysis
    [action,type] = deal('');
    if ~isempty(varargin) && ~isempty(varargin{1}) && ischar(varargin{1})
        action = varargin{1};
        switch lower(action)
            %save as?
            case {'as','avg'}
                %move into the subjects dir or base dir for this analysis
                if isfield(FT_DATA.path,'raw_file') && ~isempty(FT_DATA.path.raw_file)
                    strDir = fileparts(FT_DATA.path.raw_file);
                else
                    strDir = FT_DATA.path.base_directory;
                end
                if strcmpi(action,'avg')
                    type = FT.UserInput('\bfPlease select an average dataset type:',1,'button',{'ERP','PSD'},'title','Save Average Dataset');
                    type = lower(type);
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
            otherwise
                error('Unrecognized action: %s',action);
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
        
        % remove template and gui fields as these can change
        gui = FT_DATA.gui;
        FT_DATA.gui = rmfield(FT_DATA.gui,{'hAx','hText','sizText'});
        template = FT_DATA.template;
        FT_DATA = rmfield(FT_DATA,'template');
        template_path = FT_DATA.path.template;
        FT_DATA.path = rmfield(FT_DATA.path,'template');
        
        %save
        FT.io.WriteDataset(strPathOut);

        %averaged erp?
        if strcmpi(action,'avg') && FT_DATA.done.average
            AvgFileOps('add',type);
        end

        if ishandle(hMsg)
            close(hMsg);
        end
        
        % restore template and gui fields
        FT_DATA.gui = gui;
        FT_DATA.template = template;
        FT_DATA.path.template = template_path;
    end
    FT.UpdateGUI;
end
%-------------------------------------------------------------------------%
function ClearDataset(~,~)
    resp = FT.UserInput('Are you sure you want to clear the current dataset?',...
                        0,'button',{'Yes','Cancel'},'title','Clear Dataset?');
    if strcmpi(resp,'yes')
        %grab the fields that we will still need
        gui  = FT_DATA.gui;
        base = FT_DATA.path.base_directory;
        template_path = FT_DATA.path.template;
        template = FT_DATA.template;
        
        %renew the FT_DATA struct
        FT_DATA = [];
        FT.Prepare('type','data');
        
        %add the fields back in 
        gui.display_mode = 'init'; %set display mode back to initial
        FT_DATA.gui = gui;
        FT_DATA.path.base_directory = base;
        FT_DATA.path.template = template_path;
        FT_DATA.template = template;
        
        %update the GUI
        FT.UpdateGUI;
    end
end
%-------------------------------------------------------------------------%
function QuitGUI(obj,evt)
    if exist('FT_DATA','var') && isfield(FT_DATA,'gui') && isfield(FT_DATA,'saved')
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
    end
    fprintf(['*****\nThank you for using the FieldTrip GUI.\n'...
                 'Cleaning up and ending analysis session...\n*****\n']);
    if ishandle(h)
        GUICloseFcn('force');
    end
    clear('global','FT_DATA');
    evalin('base','clear FT_DATA');
    resp = FT.UserInput('Would you like to close MATLAB?',1,'button',{'Yes','No'},'title','Close MATLAB');
    if ~strcmpi(resp,'No')
        exit;
    end
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
end
