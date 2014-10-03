classdef Map < handle

% FT.study.Map
%
% Description: a quick and simple mapping from string to numbers/strings
%              possibly read from a parameter:value text file (one per line)
%              includes: write-on-destruction, key selection GUI
%
% Syntax: mp = FT.study.Map(path_file)
%
% In:
%       path_file - the path to a text value containing parameter:value pairs
%                   one per line, pass the string 'null' to skip file 
%                   reading / writing
%
% Out:
%       mp - an instance of the FT.study.Map class
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
    function Remove(self,key)
        b = strcmp(key,self.keys);
        if any(b)
            self.keys(b) = [];
            self.values(b) = [];
            self.modified = true;
        end
    end
    %-------------------------------------------------------------------------%
    function b = isempty(self)
        b = isempty(self.keys);
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
    function key = KeySelectionGUI(self,key_type,varargin)
        opt = FT.ParseOpts(varargin,...            
            'btn1'    , 'Load'  ,...
            'btn2'    , 'Cancel' ...
            );
        if ~isempty(self.keys)
            c = {{'text','string',['Select a ' key_type ' to ' opt.btn1 ':']},...
                 {'listbox','string',self.keys,'tag','item'};...
                 {'pushbutton','string',opt.btn1},...
                 {'pushbutton','string',opt.btn2} ...
                };

            win = FT.tools.Win(c,'title',[opt.btn1 key_type],'focus','item');
            win.Wait;
            if strcmpi(win.res.btn,opt.btn1)
                key = self.keys{win.res.item};
            else
                key = [];
            end
        else
            c = {{'text','string',['No ' key_type ' currently exists!']};...
                 {'pushbutton','string','OK'}...
                };
            win = FT.tools.Win(c,'title',['No ' key_type ' exists']);
            win.Wait;
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