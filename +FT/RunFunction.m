function RunFunction(obj,evt,f)

% FT.RunFunction
%
% Description: run a FieldTrip processing function, catching any errors that
%              occur so that they can be reported
%
% Syntax: FT.RunFunction(obj,evt,f)
%
% In:
%       obj - the calling object, this will be uimenu object that runs the
%             command
%       evt - the calling event, again specified by the calling uimenu
%       f   - a handle to the FieldTrip function to run
%
% Out: 
%
% Updated: 2013-08-19
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%try running the command and catch any error
try
    f();
catch me
    %error was reaised, allow reporting
    FT.ProcessError(me);
end