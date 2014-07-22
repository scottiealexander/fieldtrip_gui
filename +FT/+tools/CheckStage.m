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

if isfield(FT_DATA.done,strStage)
    %check to see if the stage has already been done
    if FT_DATA.done.(strStage)    
        %make the stage name more comprehendable
        switch lower(strStage)
            case 'remove_channel'
                strStage = 'Channel Removal';
            case 'resample'
                strStage = 'Resampling';
            case 'filter'
                strStage = 'Filtering';
            case 'rereference'
                strStage = 'Rereferencing';
            case 'read_events'
                strStage = 'Processing Events';
            case 'segment'
                strStage = 'Segmentation';
            case 'baseline';
                strStage = 'Baseline Correction';
            case 'tfd';
                strStage = 'Time-Frequency Decomposition';
            case 'average'
                strStage = 'ERP Averaging';
            otherwise
                %this should never happen
        end

        %ask user if we want to re-run
        resp = FT.UserInput(['\bf\color{red}Warning\color{black}: ' strStage ' has already been performed. Continue?'],...
                            0,'button',{'Continue','Cancel'},'title','Warning');
        if strcmpi(resp,'continue')
            bGood = true;
        else
            bGood = false;
        end
    else
        bGood = true;
    end
else
    %stage is not in the done struct so assume that the user is just checking
    %that data has been loaded
    bGood = true;
end