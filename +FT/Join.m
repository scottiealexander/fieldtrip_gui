function str = Join(c,delim)

% FT.Join
%
% Description: join a cell of strings with a delimiter
%
% Syntax: str = FT.Join(c,delim)
%
% In: 
%       c     - a cell of strings
%       delim - the character to use as a delimiter
%
% Out:
%       str - the joined string
%
% Updated: 2013-08-05
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

if iscell(c) && all(cellfun(@ischar,c))
    c = reshape(c,1,[]);
    nOut = (size(c,2)*2)-1;
    cOut = cell(1,nOut);
    cOut(1,1:2:nOut) = c;
    cOut(1,2:2:nOut-1) = repmat({char(delim)},1,floor(nOut/2));
    str = cat(2,cOut{:});
elseif ischar(c)
    str = c;
else
    FT.UserInput(['\bf\color{red}An ERROR was encountered: \rm\color{black}'...
        'Please email the developer with the circumstances of this error at'...
        ' \bfscottiealexander11@gmail.com \rm- Thanks!'],0);
    error('Please email ''scottiealexander11@gmail.com'' with the circumstances of this error. Thanks.');
end