function WriteTemplate()

% FT.WriteTemplate
%
% Description: convert a FT.GUI history struct to a template and write it 
%              to file
%
% Syntax: FT.WriteTemplate
%
% In: 
%
% Out: 
%
% Updated: 2013-08-07
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;


% *** TODO: Handle new history organization ***
sHist = FT_DATA.history;

cFields = fieldnames(sHist);
strAll = '';
for kF = 1:numel(cFields)
    str = Struct2Str(sHist.(cFields{kF}));
    strAll = [strAll '#' cFields{kF} 10 str];
    if kF < numel(cFields)
        strAll = [strAll 10 10];
    end
end

fid = fopen(FT_DATA.path.template,'w');
if fid > 0
    fwrite(fid,strAll,'char');
    fclose(fid);
else
    error('Failed to write template file...');
end

%-------------------------------------------------------------------------%
function str = Struct2Str(sIn)
    if isstruct(sIn)
        cHeaders = fieldnames(sIn);
        c(:,1) = cHeaders;

        %make sure all field contents are ready to be written
        for k = 1:numel(cHeaders)
            %format content correctly
                c{k,2} = SimpleJoin(sIn.(cHeaders{k}));
        end

        %tab delimiter
        cTab     = num2cell(repmat(char(9),size(c,1),1));
        cNewLine = num2cell(repmat(char(10),size(c,1),1));

        cOut = [c(:,1) cTab c(:,2) cNewLine];

        %reorganize cell to be grouped by row, and then put all group in a 1xN
        %cell so that newline feed will seperate out rows
        cOut = reshape(cOut',1,[]);

        %un-cell
        str  = cat(2,cOut{:});
    else
        str = '';
    end
end
%-------------------------------------------------------------------------%
function str = SimpleJoin(c)
%format everything pretty for printing
    if isnumeric(c) || islogical(c)
        c = arrayfun(@num2str,c,'uni',false);
    end
    if iscell(c)       
        str = ['"' FT.Join(reshape(c,1,[]),32) '"'];
    elseif ischar(c)
        str = ['"' c '"'];
    else
        fprintf('\n[ERROR]: Invalidly formatted input! Please email the developer with the circumstances of this error:\n');
        fprintf('***** email: scottiealexander11@gmail.com\n\n');
        error('see message above...');
    end
end
%-------------------------------------------------------------------------%
end