function ft_logmsg(cfg,varargin)

% ft_logmsg
%
% Description: 
%
% Syntax: ft_logmsg
%
% In: 
%
% Out: 
%
% Updated: 2013-12-12
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

if isfield(cfg,'feedback') && ~strcmpi(cfg.feedback,'no')
    fprintf(varargin{:});
else
    %NO MESSAGES
end