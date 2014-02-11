function Test(tmr,varargin)

% Test
%
% Description: 
%
% Syntax: Test
%
% In: 
%
% Out: 
%
% Updated: 2014-02-04
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

if strcmpi(tmr.Running,'on')
    fprintf('Stopping timer\n');
    stop(t);
end

fprintf('Deleting timer\n');
delete(t);