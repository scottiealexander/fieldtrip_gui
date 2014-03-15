function Progress2(varargin)

% Progress2
%
% Description: 
%
% Syntax: Progress2
%
% In: 
%
% Out: 
%
% Updated: 2014-01-24
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

strPathProc = fullfile(fileparts(mfilename('fullpath')),'tmp','progress.txt');
strPathIfo  = fullfile(fileparts(mfilename('fullpath')),'tmp','info.txt');

if exist(strPathProc,'file')
    ACTION = 'update';
else
    ACTION = 'start';
end

if ~isempty(varargin) && ischar(varargin{1})
	ACTION = varragin{1};
end

switch lower(ACTION)
    case 'start'
        if isempty(varargin) || ~isnumeric(varargin{1}) || isempty(varargin{1})
            error('Invalid input, should be the number of processes');
        else
            process = varargin{1};
        end

        if numel(varargin) > 1 && ischar(varargin{2})
            title = varargin{2};
        else
            title = 'Processing';
        end

        tmr = timer('TimerFcn',@UpdateWaitbar,...
            'Period'        , .5                    ,...
            'ExecutionMode' , 'fixedDelay'          ,...
            'Tag'           , 'FT_PROGRESS_TIMER'    ...
            );
        
        H_PROGRESS = waitbar(0,'00% done | xx:xx:xx remaining');        
        set(H_PROGRESS,'Name',title,'CloseRequestFcn',@CleanUp,'Visible','on');
        drawnow;
        
        fid = fopen(strPathProc,'w');
        fclose(fid);

        TIC_ID = tic;
        WriteIfo(process,0,TIC_ID);
        start(tmr);

    case 'update'

        %increment done count
        UpdateProcFile;

        %get info on the current process
        ifo = ReadIfo;       

    case 'close'
        CleanUp;
    otherwise
        error('Invalid action - %s',opt.action);
end

%-------------------------------------------------------------------------%
function CleanUp(varargin)
%clean up on figure close or when the process is done    
    H_PROGRESS = findobj(allchild(0),'flat','Tag','TMWWaitbar');
    if ~isempty(H_PROGRESS)
        delete(H_PROGRESS);
    end
    tmr = timerfind('Tag','FT_PROGRESS_TIMER');
    if ~isempty(tmr)
    	if isvalid(tmr) && strcmpi(tmr.Running,'on')
    		stop(tmr);
    	end        
    	delete(tmr);
    end

    delete(strPathProc);
    delete(strPathIfo);
end
%-------------------------------------------------------------------------%
function UpdateWaitbar(varargin)
	%get info on the current process
    ifo = ReadIfo;

    %get new done count
    N_DONE = getfield(dir(strPathProc),'bytes');        
    
    %estimate time remaining
    total_time = sum([toc(uint64(ifo.tic_id)),ifo.time]);
    tRem = (total_time/N_DONE) * (ifo.process-N_DONE);

    %update the waitbar
    strRem = sprintf('%02.0f%% done | %s remaining',(N_DONE/ifo.process)*100,FmtTime(tRem));        
    waitbar(N_DONE/ifo.process,H_PROGRESS,strRem);
    drawnow;

    if N_DONE == ifo.process
            CleanUp();           
    else
        TIC_ID = tic;

        %update total time
        WriteIfo(ifo.process,total_time,TIC_ID);
    end
end
%-------------------------------------------------------------------------%
function UpdateProcFile
    id = tic;
    fid = -1;
    while fid < 0
        if toc(id) < 10
            fid = fopen(strPathProc,'a');
            pause(.1);
        else
            break;
        end
    end

    if fid > 0
        fprintf(fid,'%d',1);
    else
        fprintf('[ERROR]: %s\n','Time out waiting for progress file');
    end    
end
%-------------------------------------------------------------------------%
function WriteIfo(process,time,tic_id)
    fid = fopen(strPathIfo,'w');
    fprintf(fid,'process\t%d\n',process);
    fprintf(fid,'time\t%f\n',time);
    fprintf(fid,'tic_id\t%d\n',tic_id);
    fclose(fid);
end
%-------------------------------------------------------------------------%
function ifo = ReadIfo
    fid = fopen(strPathIfo,'r');
    str = transpose(char(fread(fid,'char')));
    fclose(fid);
    c = regexp(str,'\s+','split');
    ifo = cell2struct(num2cell(str2double(c(2:2:end))),c(1:2:end-1),2);
end
%-------------------------------------------------------------------------%
function x = FmtTime(x)
%GOAL: format a duration in seconds as a hh:mm:ss string
    x = sprintf('%02d:%02d:%02.0f',floor(x/60^2),floor(rem(x,60^2)/60),rem(x,60));
end
%-------------------------------------------------------------------------%
end