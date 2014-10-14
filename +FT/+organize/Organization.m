classdef Organization < handle
% Organization
%
% Description:
%   A class to keep track of the organization of studies, subjects,
% templates, and datasets using a tree of SNodes. It arranges the nodes in
% a predefined (hard-coded) hierarchy. There is a single root node to which
% studies can be added. Studies then contain child nodes representing
% templates or subjects. The subject nodes in turn have dataset nodes as
% children. The template and dataset nodes are leaves (no children) and
% their names correspond to filepaths. The study and subject names are
% user-defined but are required to be unique among siblings. The ascii art
% below illustrates the heirarchy of SNodes within the organization class.
%   The class also keeps track of a single current SNode for each level in
% the hierarchy. The class properties are references to these nodes. The
% root level always has the same current node, but the references for other
% levels may be empty if there is no corresponding current node.

%------------------------Organization Hierarchy --------------------------%
% root
%  + studies
%     - templates
%     + subjects
%        - datasets
%-------------------------------------------------------------------------%
%
% Constructors:
%   Organization()  - finds or creates a persistent file for the organization
%
% Methods:
%   getcurr()  - returns a struct of current node names
%	edit(type) - runs a GUI manage nodes of a given type
%   addnode(type,name)  - add a node with a given type and name
%   getdatasets() - returns all dataset nodes associated with a study
%   clearfrom(start)    - clear current nodes at and below the start type
%   getparenttype(type) - get the parent node type of the given node type
%
% Updated: 2014-10-13
% Peter Horak

%-------------------------------------------------------------------------%
    properties(GetAccess=public,SetAccess=private)
        file_path % path to file for saving the state of the tree
        % pointers to the current node at each level in the hierarchy
        root
        study = [];
        template = [];
        subject = [];
        dataset = [];
    end   
    
    methods
%-------------------------------------------------------------------------%
        % Constructor, initializes the root node of the organization tree
        function self = Organization()
            self.file_path = fullfile(FT.tools.BaseDir,'assets','tree.mat');
            % load the persistant tree from file or create it
            if exist(self.file_path,'file')
                load(self.file_path,'-mat','stree');
                self.root = FT.organize.SNode(stree);
            else
                self.root = FT.organize.SNode('root','analysis');
                self.savetree % write the new tree to file
            end
        end
%-------------------------------------------------------------------------%
        % Returns the current study, template, subject, and dataset names.
        % The template and dataset node names are shortened to their
        % respective file names and extensions (removing their paths).
        function s = getcurr(self)
            s = struct('study','','template','','subject','','dataset','');
            if ~isempty(self.study)
                s.study = self.study.name;
            end
            if ~isempty(self.template)
                [~,name,ext] = fileparts(self.template.name);
                s.template = [name ext]; % filepath -> filename.ext
            end
            if ~isempty(self.subject)
                s.subject = self.subject.name;
            end
            if ~isempty(self.dataset)
                [~,name,ext] = fileparts(self.dataset.name);
                s.dataset = [name ext]; % filepath -> filename.ext
            end
        end
%-------------------------------------------------------------------------%
        % Allow the user to add (create), delete, or load (make current)
        % nodes at the organizational level specified by type using a GUI.
        function rv_action = edit(self,type)
            rv_action = 'done'; % default action returned to Manage.m
            
            % Find the parent node type (level in hierarchy)
            parent = self.getparenttype(type);
            if isempty(parent), return, end % problem: unrecognized type
            
            % Move the parent level up until there is a current node
            % for its level in the hierarchy
            while isempty(self.(parent))
                type = parent;
                parent = self.getparenttype(type);
                if isempty(parent), return, end
                rv_action = 'notdone';
            end
            
            % Child nodes of the parent
            children = self.(parent).children;
            inds = []; names = [];
            if ~isempty(children)
                names = {children.name}; % cell of child node names
                types = {children.type}; % cell of child node types
                % only look at child nodes of the target type
                inds = find(strcmpi(type,types));
                names = names(inds);
            end
            
            % Disable listbox and some buttons if there are no child nodes
            enable = FT.tools.Ternary(isempty(names),'off','on');
            
            % Set the listbox to highlight the current node of the given
            % type if there is one and it's in the list of child names
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
            % Disable the new name field for nodes whose names are file paths
            if ismember(type,{'dataset','template'})
                c{3,2}(6:7) = {'enable','off'};
            end
            % Display the GUI
            win = FT.tools.Win(c,'title',sprintf('%s Manager',upper(type)),'grid',false,'focus','item');
            win.Wait;
            
            % Add a new node to the organization. If it's a dataset or a
            % template, load the corresponding files.
            if strcmpi(win.res.btn,'add')
                if strcmpi(type,'dataset')
                    FT.io.Gui;
                elseif strcmpi(type,'template')
                    FT.template.Load;
                else
                    FT.io.ClearDataset('cleartemplate',strcmpi(type,'study'));
                    self.addnode(type,win.res.newName);
                end
            
            % Remove the selected node from the organization.
            elseif strcmpi(win.res.btn,'delete')
                % clear the current node if it's the one to be removed
                current = self.(parent).children(inds(win.res.child));
                if (self.(type) == current)
                    self.clearfrom(type)
                    FT.io.ClearDataset('cleartemplate',ismember(type,{'study','template'}));
                end

                % remove the child node with the given name from the tree
                sn = FT.organize.SNode(type,names{win.res.child});
                self.(parent).removechild(sn);
                self.savetree
                
            % Make sure the loaded dataset, current template, and current
            % nodes match the one specified to load.
            elseif strcmpi(win.res.btn,'load')
                current = self.(parent).children(inds(win.res.child));
                % check if the specified node is already the current
                if (self.(type) == current)
                    % do nothing
                else % otherwise, update the analysis to match the target node
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
            
            % If no action was performed, assume the user is done
            if ~any(strcmpi(win.res.btn,{'add','delete','load'}))
                rv_action = 'done';
            % If the user deleted a node, assume s/he isn't done yet
            elseif strcmpi(win.res.btn,'delete')
                rv_action = 'notdone';
            end
            % Otherwise, go with the default return action set earlier
            
            % Validate new node names entered through the GUI
            function [b,name] = CheckName(name,names)
                % the name should be non-empty and unique
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
            % find the current node at the level above the given type
            parent = self.getparenttype(type);
            b = ~isempty(parent) && ~isempty(self.(parent));
            
            if b 
                % Attempt to add a new node
                sn = FT.organize.SNode(type,name);
                sn_added = self.(parent).addchild(sn);
                % Make the matching (added or existing) node the current
                self.clearfrom(type)
                self.(type) = sn_added;
                self.savetree
            end
        end
%-------------------------------------------------------------------------%
        % Get the paths of all the datasets associated with a study
        function cStr = getdatasets(self)
            cStr = {};
            % if there is a current study... 
            if ~isempty(self.study)
                % return all its descendent nodes of type dataset
                cStr = self.study.gettype('dataset');
            end
        end
%-------------------------------------------------------------------------%
        % Clear all current node pointers below a level in the hierarchy
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
                % root should never be cleared, so the option is not given
            end
        end

    end
%-------------------------------------------------------------------------%
    methods(Static=true,Access=private)
        % Get the parent node type of the given type - i.e. the type of
        % nodes one level above nodes of the given type in the hierarchy.
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
    methods(Access=private)
        % Save the analysis organization tree to file
        function savetree(self)
            stree = self.root.tostruct; %#ok
            save(self.file_path,'stree');
        end
    end
%-------------------------------------------------------------------------%
end
