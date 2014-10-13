classdef SNode < handle
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
                self.children = node;
            else
                b = node.myeq(self.children);
                if any(b)
                    added = self.children(find(b,1,'first'));
                else
                    self.children(end+1) = node;
                end
            end
        end
%-------------------------------------------------------------------------%
        % Removes and returns any child nodes with the name and type of the
        % given node. Returns empty if no children are removed
        function removed = removechild(self,child)
            removed = [];
            if ~isempty(self.children)
                b = child.myeq(self.children);
                removed = self.children(b);
                self.children = self.children(~b);
            end
        end
%-------------------------------------------------------------------------%
        % Compares nodes based on their names and types
        function bEq = myeq(self,other)
            bEq = strcmp({self.name},{other.name}) & strcmp({self.type},{other.type});
        end
%-------------------------------------------------------------------------%
        % Returns the nodes as a tree of nested structs
        function s = tostruct(self)
            schildren = arrayfun(@(c) c.tostruct,self.children);
            s = struct('type',self.type,'name',self.name,'children',schildren);
        end
%-------------------------------------------------------------------------%
        % Returns a cell array of "paths" for nodes of a given type
        function cStr = gettype(self,type)
            if strcmp(self.type,type)
                % if the node is of the given type, return its name
                cStr = {self.name};
            elseif isempty(self.children)
                % if the node is a leaf but not the given type, return {}
                cStr = {};
            else
                % otherwise, preappend its name to the result children.tocstr
                cStr = arrayfun(@(n) cellfun(@(cstr) cat(2,{self.name},cstr),n.gettype(type),'uni',false),self.children,'uni',false);
                cStr = cat(1,cStr{:});
            end
        end
%-------------------------------------------------------------------------%
    end
end

%{
clear all
n1 = FT.organize.SNode('study','pct');
n2 = FT.organize.SNode('subj','es');
n3 = FT.organize.SNode('subj','sb');
n4 = FT.organize.SNode('file','/path/data1.edf');
n5 = FT.organize.SNode('file','/path/data2.edf');
n1.addchild(n2);
n1.addchild(n3);
n2.addchild(n4);
n2.addchild(n5);
n3.addchild(n5);
root = FT.organize.SNode('root','analysis');
root.addchild(n1);
%}