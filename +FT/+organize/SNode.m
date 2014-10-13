classdef SNode < handle
% SNode (originally stood for Study/Subject Node)
%
% Description:
%   SNode defines a class for node objects. The nodes are designed for use
% in constructing a tree hierarchy to represent the organization of
% studies, templates, subjects, and datasets in an analysis.
%   The SNode class provides methods for adding and removing children. It
% also supports converting a tree of nodes to a tree of structs and back.
% This is to facilitate saving SNodes as structs, so that the saved file
% can be read without having access to the SNode class definition.
%   The class descends from the handle class so that references to nodes
% can be created. However, note that using this feature to create cyclical
% graphs may result in tostruct() and gettype() failing to complete
% execution.
%
% Constructors:
%   SNode(type,name)- create a node with the given type and name
%   SNode(struct)   - create a tree of nodes from a stree of structs
%
% Methods:
%   addchild(SNode) - add the given node as a child
%	removechild(SNode)  - remove child nodes matching the given one
%	myeq(SNode)     - compare the type and name attributes of two nodes
%	tostruct()      - convert the node and its decendents to a tree of structs
%	gettype(type)   - return all decendent leaves of a given type
%
% Updated: 2014-10-13
% Peter Horak

%-------------------------------------------------------------------------%
    properties(GetAccess=public,SetAccess=private)
        type = '';
        name = '';
        children = [];
    end
    
    methods
%-------------------------------------------------------------------------%
        % Constructor, takes a node type and name or a structure
        function self = SNode(varargin)
            if (nargin == 2) && iscellstr(varargin)
                self.type = varargin{1};
                self.name = varargin{2};
            elseif (nargin == 1) && isstruct(varargin{1})
                s = varargin{1};
                self = FT.organize.SNode(s.type,s.name);
                % recursively convert child structs to SNodes
                for i = 1:numel(s.children)
                    self.addchild(FT.organize.SNode(s.children(i)));
                end
            else
                error('SNode: unsupported constructor arguments')
            end
        end
%-------------------------------------------------------------------------%
        % Adds a node as a child. Returns the node unless there's already a
        % child of (name,type) in which case it returns the existing child
        function added = addchild(self,node)
            added = node;
            if isempty(self.children)
                % if there are no children, add the node as the first child
                self.children = node;
            else
                b = node.myeq(self.children);
                if any(b)
                    % a matching child already exists, return it
                    added = self.children(find(b,1,'first'));
                else
                    % otherwise, append the node as a new child
                    self.children(end+1) = node;
                end
            end
        end
%-------------------------------------------------------------------------%
        % Removes and returns any child nodes with the name and type as the
        % given node. Returns an empty array if no children are removed
        function removed = removechild(self,child)
            removed = [];
            if ~isempty(self.children)
                b = child.myeq(self.children); % matching children
                removed = self.children(b);
                self.children = self.children(~b); % remove the matches
            end
        end
%-------------------------------------------------------------------------%
        % Compares nodes based on their names and types
        function bEq = myeq(self,other)
            bEq = strcmp({self.name},{other.name}) & strcmp({self.type},{other.type});
        end
%-------------------------------------------------------------------------%
        % Returns the node and its descendants as a tree of nested structs
        function s = tostruct(self)
            schildren = arrayfun(@(c) c.tostruct,self.children);
            s = struct('type',self.type,'name',self.name,'children',schildren);
        end
%-------------------------------------------------------------------------%
        % Returns a cell array of "paths" for nodes of a given type. The
        % path is a cell of node names traversed to reach the target nodes.
        function cStr = gettype(self,type)
            if strcmp(self.type,type)
                % if the node is of the given type, return its name
                cStr = {self.name};
            elseif isempty(self.children)
                % if the node is a leaf but not of the given type, return {}
                cStr = {};
            else
                % otherwise, recursively continue to its children
                cStr = arrayfun(@(n) cellfun(@(cstr) cat(2,{self.name},cstr),n.gettype(type),'uni',false),self.children,'uni',false);
                cStr = cat(1,cStr{:});
            end
        end
%-------------------------------------------------------------------------%
    end
end
