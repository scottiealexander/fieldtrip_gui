function Log(in)

% FT.tools.Log
%
% Description: prints an error message if the input is an exception or
% evaluates to false
%
% Syntax: FT.tools.Log(in)
%
% In: in - an exception or boolean expression to be tested
%
% Out:
%
% Updated: 2014-06-26
% Peter Horak
%
% Please report bugs to: scottiealexander11@gmail.com

if isa(in,'MException')
    s  = in.stack;
    file = regexprep(regexp(s(1).file,['FT' filesep '.*'],'match','once'),[filesep '\+|' filesep],'.');
    fprintf(2,'[ERROR]: line %d of %s\n --> %s\n\n',s(1).line,file,in.message);
elseif ~in
    [s,k] = dbstack('-completenames');
    k = min(k+1,numel(s));
    file = regexprep(regexp(s(k).file,['FT' filesep '.*'],'match','once'),[filesep '\+|' filesep],'.');
    fprintf('Test failed on line %d of %s\n',s(k).line,file);
end
end