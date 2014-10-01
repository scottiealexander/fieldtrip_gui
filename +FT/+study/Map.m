classdef Map < handle

% FT.study.Map
%
% Description:
%
% Syntax: FT.study.Map
%
% In:
%
% Out:
%
% Updated: 2014-10-01
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

properties (Access=private)
    file;
    keys = {};
    values = {};
    modified = false;
end

methods
    %-------------------------------------------------------------------------%
    function self = Map(path_file)
        if strcmpi(path_file,'null')
            self.file = self.GetNullFile;
        else
            self.file = path_file;
            self.Read;
        end
    end
    %-------------------------------------------------------------------------%
    function val = Get(self,key)
        val = [];
        if ischar(key)
            b = strcmp(key,self.keys);
            if any(b)
                val = self.values{b};
            end
        end
    end
    %-------------------------------------------------------------------------%
    function Set(self,key,val)
        if iscell(key) && (numel(key)==numel(val))
            if isnumeric(val) || islogical(val) || ischar(val)
                val = num2cell(val);
            elseif ~iscell(val)
                error('Invlaid set');
            end            
            for k = 1:numel(key)
                self.SetOne(key{k},val{k});
            end
        else
            self.SetOne(key,val);
        end
    end
    %-------------------------------------------------------------------------%
    function b = IsKey(self,key)
        if ischar(key)
            b = any(strcmp(key,self.keys));
        else
            b = false;
        end
    end
    %-------------------------------------------------------------------------%
    function c = Keys(self)
        c = self.keys;
    end
    %-------------------------------------------------------------------------%
    function c = Values(self)
        c = self.values;
    end
    %-------------------------------------------------------------------------%
    function Save(self)
        if self.modified
            self.Write;
        end
    end
    %-------------------------------------------------------------------------%
    function id = GenerateId(self)
        if ~isempty(self.values)
            if all(cellfun(@isnumeric,self.values))
                id = max(cat(1,self.values{:})) + 1;
            elseif iscellstr(self.values)
                id = self.values{1};
                charset = [65:90 97:122];
                n = numel(charset);
                while any(strcmp(id,self.values))
                    id = char(charset(randi(n,1,6)));
                end
            else
                error('Failed to generate id: values are not uniform');
            end
        else
            id = 1;
        end
    end
    %-------------------------------------------------------------------------%
    function key = KeySelectionGUI(self,key_type)
        c = {{'text','string',['Select a ' key_type ':']},...
             {'listbox','string',self.keys,'tag','item'};...
             {'pushbutton','string','Load'},...
             {'pushbutton','string','Cancel'} ...
            };
        win = FT.tools.Win(c,'title',['Load ' key_type]);
        win.Wait;
        if strcmpi(win.res.btn,'load')
            key = self.keys{win.res.item};
        else
            key = [];
        end
    end
    %-------------------------------------------------------------------------%
    function display(self)
        fmt = ['%s => ' self.Format '\n'];

        for k = 1:numel(self.keys)
            fprintf(fmt,self.keys{k},self.values{k});
        end
    end
    %-------------------------------------------------------------------------%
    function delete(self)
        self.Save;
    end
    %-------------------------------------------------------------------------%
end

methods
    %-------------------------------------------------------------------------%
    function SetOne(self,key,val)        
        if ~ischar(key) || ~isempty(self.values) && ~strcmpi(class(val),class(self.values{1}))
            error('Invlaid set');
        end
        self.keys{end+1,1} = key;
        self.values{end+1,1} = val;
        self.modified = true;
    end
    %-------------------------------------------------------------------------%
    function Read(self)
        fid = fopen(self.file,'r');
        if fid > 0
            str = transpose(fread(fid,'*char'));
            fclose(fid);
            c = regexp(strtrim(str),'\n','split');
            c = c(~cellfun(@isempty,c));

            for k = 1:numel(c)
                re = regexp(c{k},'\s*"?(?<key>[^"\s:]*)"?[\s:]+(?<val>\S+)','names');
                if ~isempty(re)
                    self.keys{end+1,1} = re.key;
                    self.values{end+1,1} = re.val;
                else
                    fprintf('***WARNING***: regexp match failure\n');
                end
            end
            self.ConvertValues;
        end
    end
    %-------------------------------------------------------------------------%
    function Write(self)
        fid = fopen(self.file,'w');

        if fid < 1
            error('Unable to open file %s for writing...',self.file);
        end

        fmt = ['"%s": ' self.Format '\n'];

        for k = 1:numel(self.keys)
            fprintf(fid,fmt,self.keys{k},self.values{k});
        end
        fclose(fid);
        self.modified = false;
    end
    %-------------------------------------------------------------------------%
    function fmt = Format(self)
        if ~isempty(self.values)
            tmp = self.values{1};
        else
            tmp = 1;
        end
        if isa(tmp,'char')
            fmt = '%s';
        elseif isa(tmp,'cell') || isa(tmp,'struct')
            error('Invalid value detected');
        else
            if mod(tmp,1)
                fmt = '%f';
            else
                fmt = '%d';
            end
        end
    end
    %-------------------------------------------------------------------------%
    function ConvertValues(self)
        tmp = str2double(self.values);
        if ~any(isnan(tmp))
            self.values = num2cell(tmp);
        end
    end
    %-------------------------------------------------------------------------%    
end

methods (Access=private, Static=true)
    %-------------------------------------------------------------------------%
    function fp = GetNullFile
        if ispc
            fp = 'NUL:';
        else
            fp = '/dev/null';    
        end
    end
    %-------------------------------------------------------------------------%
end
end