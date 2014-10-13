classdef Organization < handle
    
    properties(GetAccess=public,SetAccess=private)
        file_path % path of file for saving the state of the tree
        % pointers to the current node at each level in the hierarchy
        root
        study = [];
        template = [];
        subject = [];
        dataset = [];
    end   
    
    methods
%-------------------------------------------------------------------------%
        % Constructor, initializes the root node
        function self = Organization()
            self.file_path = fullfile(FT.tools.BaseDir,'assets','tree.mat');
            if exist(self.file_path,'file')
                load(self.file_path,'-mat','stree');
                self.root = FT.organize.SNode(stree);
            else
                self.root = FT.organize.SNode('root','analysis');
                self.savetree
            end
        end
%-------------------------------------------------------------------------%
        % Returns the current study, subject, and file names in a struct
        function s = getcurr(self)
            s = struct('study','','template','','subject','','dataset','');
            if ~isempty(self.study)
                s.study = self.study.name;
            end
            if ~isempty(self.template)
                [~,name,ext] = fileparts(self.template.name);
                s.template = [name ext];
            end
            if ~isempty(self.subject)
                s.subject = self.subject.name;
            end
            if ~isempty(self.dataset)
                [~,name,ext] = fileparts(self.dataset.name);
                s.dataset = [name ext];
            end
        end
%-------------------------------------------------------------------------%
        % Create, delete, or load (i.e. make current) nodes at the
        % organizational level (study/subject/datast) specified by type
        function rv_action = edit(self,type)
            rv_action = 'done';
            
            % Find the parent node type (level in hierarchy)
            parent = self.getparenttype(type);
            if isempty(parent), return, end
            
            % Move the parent level up until there is a current node
            % pointer for its level
            while isempty(self.(parent))
                type = parent;
                parent = self.getparenttype(type);
                if isempty(parent), return, end
                rv_action = 'notdone';
            end
            
            % Cell of strings of child node names
            children = self.(parent).children;
            inds = []; names = [];
            if ~isempty(children)
                names = {children.name};
                types = {children.type};
                inds = find(strcmpi(type,types));
                names = names(inds);
            end
            
            % Disable listbox and buttons if there are no child nodes
            enable = FT.tools.Ternary(isempty(names),'off','on');
            
            % Set the listbox to highlight the current
            val = 1;
            if ~isempty(self.(type))
                val = find(strcmp(self.(type).name,names),1,'first');
                if isempty(val), val = 1; end
            end
            
            % User input GUI
            c = {{'text','string','Existing:'},...
                 {'listbox','string',names,'value',val,'tag','child','enable',enable};...
                 {'pushbutton','string','Load','enable',enable,'validate',false},...
                 {'pushbutton','string','Delete','enable',enable,'validate',false};...
                 {'text','string','New Name:'},...
                 {'edit','string','','tag','newName','valfun',@(str) CheckName(str,names)};...
                 {'pushbutton','string','Add'},...
                 {'pushbutton','string','Done','validate',false}};
            % disable the new name window for nodes of type dataset
            if ismember(type,{'dataset','template'})
                c{3,2}(6:7) = {'enable','off'};
            end

            win = FT.tools.Win(c,'title',sprintf('%s Manager',upper(type)),'grid',false,'focus','item');
            win.Wait;
            
            action = win.res.btn;
            
            if strcmpi(action,'add') % type, win.res.newName
                % Add a new node to the organization. If it's a dataset or
                % template, load the corresponding files
                if strcmpi(type,'dataset')
                    FT.io.Gui;
                elseif strcmpi(type,'template')
                    FT.template.Load;
                else
                    FT.io.ClearDataset('cleartemplate',strcmpi(type,'study'));
                    self.addnode(type,win.res.newName);
                end
                
            elseif strcmpi(action,'delete') % type, parent, win.res.child
                % Clear the current node pointer if it's the one to be removed
                current = self.(parent).children(inds(win.res.child));
                if (self.(type) == current)
                    self.clearfrom(type)
                    FT.io.ClearDataset('cleartemplate',ismember(type,{'study','template'}));
                end

                % Remove the child node with the given name
                sn = FT.organize.SNode(type,names{inds(win.res.child)});
                self.(parent).removechild(sn);
                self.savetree
                
            elseif strcmpi(action,'load') % type, parent, win.res.child
                % If the current node is the one specified to load, do
                % nothing, but if it's not make updates to the analysis.
                current = self.(parent).children(inds(win.res.child));
                if (self.(type) == current)
                    % do nothing
                else
                    self.clearfrom(type);
                    self.(type) = current;
                    if strcmpi(type,'dataset')
                        FT.io.Read(current.name);
                    elseif strcmpi(type,'template')
                        FT.template.Load(current.name);
                    else
                        FT.io.ClearDataset('cleartemplate',strcmpi(type,'study'));
                    end
                end
            end
            
            if ~any(strcmpi(action,{'add','delete','load'}))
                rv_action = 'done';
            elseif strcmpi(action,'delete')
                rv_action = 'notdone';
            end
                
            FT.UpdateGUI;

            function [b,name] = CheckName(name,names)
                b = ~isempty(name) && ~any(strcmp(name,names));
                if ~b
                    name = 'Please choose a different study name.';
                end
            end
        end
%-------------------------------------------------------------------------%
        % Add a node to the organization unless one already exists with the
        % same name, type, and parent. Either way, make the node in this
        % position the current.
        function b = addnode(self,type,name)
            parent = self.getparenttype(type);
            b = ~isempty(parent) && ~isempty(self.(parent));% && exist(name,'file');
            
            if b 
                sn = FT.organize.SNode(type,name);
                sn_added = self.(parent).addchild(sn);
                self.clearfrom(type)
                self.(type) = sn_added;
                self.savetree
            end
        end
%-------------------------------------------------------------------------%
        % Get the paths of all the datasets associated with a study
        function cStr = getdatasets(self)
            cStr = {};
            if ~isempty(self.study)
                cStr = self.study.gettype('dataset');
            end
        end
%-------------------------------------------------------------------------%
        % Clear all current node pointers below a point in the hierarchy
        function clearfrom(self,start)
            switch lower(start)
                case 'dataset'
                    self.dataset = [];
                case 'subject'
                    self.dataset = [];
                    self.subject = [];
                case 'template'
                    self.template = [];
                case 'study'
                    self.dataset = [];
                    self.subject = [];
                    self.template = [];
                    self.study = [];
            end
        end
%-------------------------------------------------------------------------%
    end

    methods(Access=private)
        % Save the analysis organization tree
        function savetree(self)
            stree = self.root.tostruct;
            save(self.file_path,'stree');
        end
    end
%-------------------------------------------------------------------------%
    methods(Static=true,Access=private)
        % Get the parent node type of the given node type
        function parent = getparenttype(type)
            switch lower(type)
                case 'dataset'
                    parent = 'subject';
                case {'subject','template'}
                    parent = 'study';
                case 'study'
                    parent = 'root';
                otherwise
                    parent = '';
            end
        end
    end
%-------------------------------------------------------------------------%
end
