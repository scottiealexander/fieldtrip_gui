function RunFunction(f)

% FT.RunFunction
%
% Description: run a FieldTrip processing function, catching any errors that
%              occur so that they can be reported
%
% Syntax: FT.RunFunction(f)
%
% In:
%       f   - a handle to the FieldTrip function to run
%
% Out: 
%
% Updated: 2014-05-09
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

persistent inprogress;
if isempty(inprogress)
    inprogress = false;
end
c = onCleanup(@() ResetProgress);

% Only allow one operation to run at a time
if ~inprogress
    inprogress = true;

    %try running the command and catch any error
    try
        f();
    catch me
        %error was reaised, allow reporting
        FT.ProcessError(me);
    end

    inprogress = false;
end

%-------------------------------------------------------------------------%
function ResetProgress
    inprogress = false;
end
%-------------------------------------------------------------------------%
end