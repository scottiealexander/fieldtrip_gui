function ProcessError(me)

% FT.ProcessError
%
% Description: display an error message and give the user the option to send an
%              error report
%
% Syntax: FT.ProcessError(me)
%
% In:
%       me - the MException object raised by the error
%
% Out: 
%
% Updated: 2013-08-08
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com
if isa(me,'MException')
    strMsg = ['\bfMATLAB has encountered the following error:\n\n\rm\color{red}'...
                  '"' me.message '"\n\n'...
                  '\color{black}Press "\bfIgnore\rm" to ignore the error and continue or\n'...
                  'press "\bfSend Report\rm" to send an error report to the developer.'];

    strResp = FT.UserInput(strMsg,0,'button',{'Ignore','Send Report','Details >>'},'wrap',true);

    if strcmpi(strResp,'send report')
        FT.ReportError(me);
    elseif strcmpi(strResp,'details >>')
        strMsg = [me.message 10 'In:'];
        for k = 1:numel(me.stack)
            strMsg = [strMsg 10 me.stack(k).file ' at ' num2str(me.stack(k).line)];
        end
        FT.UserInput(strMsg,0,'title','Error Details','button','OK','wrap',false);
    end
end
end