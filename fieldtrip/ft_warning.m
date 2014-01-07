function ft_warning(cfg,varargin)

% ft_warning
%
% Description: 
%
% Syntax: ft_warning
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
    warning(varargin{:});
else
    %NO MESSAGES
end