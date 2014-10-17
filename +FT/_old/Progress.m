function Progress(varargin)

% FT.Progress
%
% Description: 
%
% Syntax: FT.Progress
%
% In: 
%
% Out: 
%
% Updated: 2014-01-22
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

persistent H_PROGRESS N_PROCESS N_DONE TIC_ID TIME_ELASPED ACTION;

if isempty(ACTION)
    ACTION = 'start';
end
switch ACTION
	case 'start'
		if ~isempty(varargin) && isnumeric(varargin{1})
			N_PROCESS = varargin{1};
			varargin(1) = [];
		else
			return;
		end
	case 'update'
		if ~isempty(varargin) && isnumeric(varargin{1}) && varargin{1} <= N_PROCESS
			N_DONE = varargin{1};
			varargin(1) = [];
		else
			N_DONE = N_DONE+1;
		end
end

opt = FT.ParseOpts(varargin,...
	'action' , ACTION	   ,...
	'title'  , 'Processing'	...
	);

switch lower(opt.action)
	case 'start'		
		TIME_ELASPED = [];

        if isempty(N_PROCESS)
        	error('N_PROCESS is empty');
        end
        
		H_PROGRESS = waitbar(0,'00% done | xx:xx:xx remaining');
		set(H_PROGRESS,'Name',opt.title,'CloseRequestFcn',@CleanUp,'Tag','FT_PROGRESS_BAR');
		drawnow;

		TIC_ID = tic;
        N_DONE = 0;
        ACTION = 'update';
	case 'update'
        
        if isempty(N_PROCESS)
        	error('N_PROCESS is empty');
        end
        
		%figure was closed so exit
        if ~ishandle(H_PROGRESS)
            CleanUp;
            return;
        end
        
	    TIME_ELASPED(end+1,1) = toc(TIC_ID);
	    tRem = nanmean(TIME_ELASPED,1) * (N_PROCESS-N_DONE);

	    %update the waitbar
	    strRem = sprintf('%02.0f%% done | %s remaining',(N_DONE/N_PROCESS)*100,FmtTime(tRem));
	    waitbar(N_DONE/N_PROCESS,H_PROGRESS,strRem);
	    drawnow;

        if N_DONE == N_PROCESS
            CleanUp;           
        else
            TIC_ID = tic;
        end
    case 'close'
        CleanUp;
	otherwise
		error('Invalid action - %s',opt.action);
end

%-------------------------------------------------------------------------%
function CleanUp(varargin)
%clean up on figure close or when the process is done
    if ~exist('H_PROGRESS','var')
    	H_PROGRESS = findobj('Tag','FT_PROGRESS_BAR');
    end
    if ~isempty(H_PROGRESS)
    	delete(H_PROGRESS);
    end
	[N_PROCESS, N_DONE, TIC_ID, TIME_ELASPED, ACTION, H_PROGRESS] = deal([]);	
end
%-------------------------------------------------------------------------%
function x = FmtTime(x)
%GOAL: format a duration in seconds as a hh:mm:ss string
    x = sprintf('%02d:%02d:%02.0f',floor(x/60^2),floor(rem(x,60^2)/60),rem(x,60));
end
%-------------------------------------------------------------------------%
end