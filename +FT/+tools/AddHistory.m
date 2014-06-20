function AddHistory(field,cfg)

% FT.tools.AddHistory
%
% Description: add inofrmation about a operation to the history
%
% Syntax: FT.tools.AddHistory(field,cfg)
%
% In:
%		field - the history field to add too (e.g. 'filter')
%		cfg   - a config struct with information on the operation that was
%				preformed
%
% Out: 
%
% Updated: 2014-06-20
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

if ~isfield(FT_DATA.history,field) || isempty(FT_DATA.history.(field))
	FT_DATA.history.(field) = cfg;
elseif iscell(FT_DATA.history.(field))
	FT_DATA.history.(field) = reshape(FT_DATA.history.(field),[],1);
	FT_DATA.history.(field){end+1,1} = cfg;
else %if its a struct or some other type of array...???
	FT_DATA.history.(field) = {FT_DATA.history.(field);cfg};
end