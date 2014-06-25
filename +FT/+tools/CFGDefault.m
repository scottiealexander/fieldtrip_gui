function cfg = CFGDefault(varargin)

% CFGDefault
%
% Description: initialize a fieldtrip configuration struct with default settings
%
% Syntax: cfg = CFGDefault([cfg] = [])
%
% In: 
%
% Out:
%       cfg - a fieldtrip configuration struct with default setting initialized
%
% Updated: 2014-06-20
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

if ~isempty(varargin) && isstruct(varargin{1}) && numel(varargin{1})==1
    cfg = varargin{1};
else
    cfg = [];
end
cfg.trackcallinfo = 'off';
cfg.feedback      = 'no';