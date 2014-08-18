function me = Run(str)

% FT.events.relabel.Run
%
% Description: 
%
% Syntax: FT.events.relabel.Run(strPath)
%
% In: 
%       strPath - *ETHER* the path to an event file *OR* the contents of the
%                 event file
%
% Out: 
%
% SEE ALSO: FT.events.relabel.Gui
%
% Updated: 2014-07-15
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA
me = [];

try
    evt = FT.ReStruct(FT_DATA.event);

    %check if we've been given a file, if not assume is the event code file contents
    if exist(str,'file') == 2
        fid = fopen(str,'r');
        if fid < 0
            error('could not read event file');
        end
        str = reshape(cast(fread(fid,'char'),'char'),1,[]);
        fclose(fid);
    end

    %split into lines
    c = regexp(str,'\n','split');

    %remove comments and empty lines
    c = strtrim(c);
    bEmp = cellfun(@isempty,c);
    c = c(~bEmp);
    bCom = cellfun(@(x) x(1)=='#',c);
    c = c(~bCom);

    %seperate lhs and rhs
    re = regexp(c,'(?<new>[^=]*)\s*=\s*(?<old>.*)','names');
    re    = FT.ReStruct(cat(2,re{:}));

    %remove any errant whitespace from lhs
    cName = strtrim(re.new);

    %convert rhs into a usable matlab data format
    if iscell(re.old)
        cCode = cellfun(@FT.events.relabel.Parse,re.old,'uni',false);
    else
        cCode = {FT.events.relabel.Parse(re.old)};
    end

    %add new codes
    for k = 1:numel(cName)
       bSet = ismember(evt.value,cCode{k});
       evt.type(bSet) = cName(k);
    end

    FT_DATA.event = FT.ReStruct(evt);
    [~,FT_DATA.data.cfg] = FT.EditCfg(FT_DATA.data.cfg,'set','event',FT_DATA.event);
catch me
end

FT.tools.AddHistory('relabel_events',str);
FT_DATA.done.relabel_events = isempty(me);

end