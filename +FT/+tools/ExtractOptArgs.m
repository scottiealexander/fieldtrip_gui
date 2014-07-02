function varargout = ExtractOptArgs(carg,varargin)
% ExtractOptArgs
%
% Description: 
%
% Syntax: ExtractOptArgs()
%
% In:
%
% Out: 
%
% Updated: 2014-06-27
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

if nargout ~= numel(varargin)
	error('The number of output arguments MUST match the number of default values!');
end

if isempty(carg)
	varargout = varargin;
else	
	for k = 1:nargout
		if ~isempty(carg{k})
			varargout{k} = carg{k};
		else		
			varargout{k} = varargin{k};
		end
	end
end