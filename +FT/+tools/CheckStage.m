function bGood = CheckStage(strStage)

% FT.CheckStage
%
% Description: check that the stage has not been done already (if it is one
% of the stages that is known to cause issues when run multiple times)
%
% Syntax: bGood = FT.CheckStage(strStage)
%
% In:
%       strStage - the stage to check
%
% Out: 
%       bGood - true if processing should continue, false otherwise
%
% Updated: 2013-08-07
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
bGood = true;

if isfield(FT_DATA.done,strStage)
    %check to see if the stage has already been done
    if FT_DATA.done.(strStage)
        
        % Use red warning for operations that generally should not be rur twice
        if ismember(strStage,{'resample','filter','rereference','read_events',...
                'relabel_events','define_trials','segment_trials','baseline_trials',...
                'tfd','average'})
            color = 'red';
        else
            color = 'yellow';
        end
        
        %ask user if we want to re-run
        resp = FT.UserInput(['\bf\color{' color '}Warning\color{black}: ' strStage ' has already been performed. Continue?'],...
            strcmpi('yellow',color),'button',{'Continue','Cancel'},'title','Warning');
        if strcmpi(resp,'cancel')
            bGood = false;
        end
    end
end
end