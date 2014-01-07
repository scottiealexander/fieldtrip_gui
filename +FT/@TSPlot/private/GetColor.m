function y = GetColor(varargin)

% GetColor
%
% Description: 
%
% Syntax: col = GetColor(x)
%
% In: 
%
% Out: 
%
% Updated: 2013-09-07
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com
persistent COL_MAP

if isempty(COL_MAP)
    strPathCol = fullfile(fileparts(mfilename('fullpath')),'color.txt');    
    fid = fopen(strPathCol,'r');

    if fid > 0
        str = reshape(cast(fread(fid,'char'),'char'),1,[]);
    else
        error(['could not open file: ' strPathCol]);
    end
    fclose(fid);

    COL_MAP = regexp(regexp(strtrim(str),'\n','split'),'\t+','split');
    COL_MAP = cat(1,COL_MAP{:});
end

if isempty(varargin)
    x = 1;
else
    x = varargin{1};
end

if ischar(x)
    y = GetCol(x);
elseif iscellstr(x)
    y = cellfun(@GetCol,x,'uni',false);
    y = cat(1,y{:});
elseif isnumeric(x)
    if x <= size(COL_MAP,1)
    	y = zeros(x,3);
        for k = 1:x
            y(k,:) = GetCol(COL_MAP{k});
        end
    else
        y = cellfun(@GetCol,COL_MAP(randi(size(COL_MAP,1),[x,1]),1),'uni',false);
        y = cat(1,y{:});
    end
else
    y = NaN;
end

%------------------------------------------------------------------------------%
function y = GetCol(col)
    y = str2double(regexp(COL_MAP{strcmpi(col,COL_MAP(:,1)),2},'\s+','split'));
end
%------------------------------------------------------------------------------%
end
