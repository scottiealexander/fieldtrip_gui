function sOpt = ParseOpts(cOpts,varargin)

% FT.ParseOpts
%
% Description: simple optional argument parser
%
% Syntax: FT.ParseOpts(varargin,<defaults>)
%
% In: 
%       varargin - the varargin cell containing the param-value specification
%                  from the caller
%       defaults - a series of param-value pairs specifing a default value for
%                  each parameter
%
% Out: 
%       opt  - a struct of option values
%
% Updated: 2013-10-25
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%inorder for cell2struct to accept '2' as the dim (3rd) argument we need our
%cell to be a row cell
cOpts = reshape(cOpts,1,[]);

%convert cells to structs
if ~mod(numel(cOpts),2)
    %make sure there is an even number of parameter value pairs
    sOpt = cell2struct(cOpts(2:2:end),cOpts(1:2:end),2);
else
    %chop the last input as it doesn't have a matching item
    cOpts(end) = [];
    sOpt = cell2struct(cOpts(2:2:end),cOpts(1:2:end),2);
end

%make sure there is a value for every param in defaults
if mod(numel(varargin),2)
    me = MException('InvalidInput:MissingValues',...
        'the number of parameters and values in default cell do no match');
    throw(me);
end

sDef = cell2struct(varargin(2:2:end),varargin(1:2:end),2);

%merge the structs with precedence given to the callers values
cFields = fieldnames(sDef);
for k = 1:numel(cFields)
    if ~isfield(sOpt,cFields{k})
        sOpt.(cFields{k}) = sDef.(cFields{k});
    end
end