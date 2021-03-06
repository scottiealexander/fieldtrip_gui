classdef ROA < handle

% ROA
%
% Description: a read-only matrix-like class that, on construction, writes the
%			   data to disk and then reads from disk as needed
%
% Syntax: r = ROA(x)
%
% In:
%		x - a n-dimentional numeric or character matrix
%
% Out:
%		r - an instance of the ROA class that can be indexed *EXACTLY* like the
%			original matrix (x)
%
% Methods:
%		size   - get the size of the underlying matrix
%		lock   - prevent deletion of the underlying matrix
%		unlock - allow deletion of the underlying matrix
%		delete - delete the underlying matrix
%
% Updated: 2014-04-24
% Scottie Alexander
%
% Please send bug reports to scottiealexander11@gmail.com

%PRIVATE PROPERTIES-----------------------------------------------------------%
properties (Access=private)
	id;
	d_size;
	d_class;
	bytes;
	file;
	locked = false;
end
%PRIVATE PROPERTIES-----------------------------------------------------------%

%PUBLIC METHODS---------------------------------------------------------------%
methods
	%-------------------------------------------------------------------------%
	function r = ROA(x)
		if ~isnumeric(x) && ~ischar(x)
			error('input *MUST* be numeric or char!');
		end
		r.id = randi(1e6,1);
		r.file 	  = fullfile(fileparts(mfilename('fullpath')),...
						'private',['roa_' num2str(r.id) '.dat']);        
		r.d_size  = size(x);
		r.d_class = class(x);
		r.bytes   = getfield(whos('x'),'bytes') / numel(x);
		fid  = fopen(r.file,'w');
		if fid < 1
			error('could not open file %s!',r.file);
		end
		count = fwrite(fid,x,r.d_class);
		fclose(fid);
		if count ~= numel(x)
			error('Failed to write the correct number of bytes to file!');
		end
	end
	%-------------------------------------------------------------------------%
	function x = subsref(r,s)		
		switch s(1).type
		case '()'
			if ~all(cellfun(@r.checkref,s.subs))
				error('Invalid index detected');
			end
			b = strcmp(':',s.subs);
			s.subs(b) = arrayfun(@(x) 1:x,r.d_size(b),'uni',false);
			if numel(s.subs) > 1
				siz = cellfun(@numel,s.subs);
				nD  = numel(siz);

				%columns have to come first...!
				siz = [siz(2) siz(1) siz(3:end)];
				kSiz = [2,1,3:nD];
				for kD = 1:nD
					nR1 = prod(siz(kD-1:-1:1));
					nR2 = prod(siz(kD+1:end));
					s.subs{kSiz(kD)} = r.fill(s.subs{kSiz(kD)},nR1,nR2);
				end				
				kIdx = sub2ind(r.d_size,s.subs{:});
			else				
				kIdx = s.subs{1};
				if any(r.d_size == 1) && numel(r.d_size) == 2 && ~all(r.d_size==1)
					if r.d_size(1) > r.d_size(2)
						kIdx = reshape(kIdx,[],1);
					else
						kIdx = reshape(kIdx,1,[]);
					end
				end
				siz  = size(kIdx);
				kSiz = 1:numel(siz);
			end

			x = readmatrix(r.file,kIdx,r.bytes);		

			%reshape the output so that we get the same answer as what matlab would give
			x = permute(reshape(x,siz),kSiz);
		case '.'
			x = [];
			if ischar(s.subs) && ismethod(r,s.subs)
				r.(s.subs);
			else
				fprintf('[WARNING]: %s reference is not supported for instances of class ROA!\n',s.type);
				x = [];
			end
		otherwise			
			fprintf('[WARNING]: %s reference is not supported for instances of class ROA!\n',s.type);
			x = [];
		end
	end
	%-------------------------------------------------------------------------%
	function varargout = size(r,varargin)
		if isempty(varargin) || isempty(varargin{1})
			d = r.d_size;
		else
			nDim = numel(varargin{1});
			d = zeros(1,nDim);
			for k = 1:nDim
				if varargin{1}(k) > numel(r.d_size)
					d(k) = 1;
				else
					d(k) = r.d_size(varargin{1}(k));
				end
			end
		end
		if nargout > 1
			varargout = num2cell([d ones(1,nargout-numel(d))]);
		else
			varargout{1} = d;
		end
	end
	%-------------------------------------------------------------------------%
	function lock(r,varargin)
		r.locked = true;
	end
	%-------------------------------------------------------------------------%
	function unlock(r,varargin)
		r.locked = false;
	end
	%-------------------------------------------------------------------------%
	function display(r)
		ptn = [repmat('%dx',1,numel(r.d_size)-1) '%d'];
		fprintf(['<' ptn '> ROA\n'],r.d_size);
	end
	%-------------------------------------------------------------------------%
	function s = class(r)
		s = 'ROA';
	end
	%-------------------------------------------------------------------------%
	function delete(r)
		if ~r.locked			
			if exist(r.file,'file') == 2
				delete(r.file);
			end
		end
	end
	%-------------------------------------------------------------------------%
end
%PUBLIC METHODS---------------------------------------------------------------%

%STATIC METHODS---------------------------------------------------------------%
methods (Static=true,Access=private)
	%-------------------------------------------------------------------------%
	function x = fill(x,nR1,nR2)
		x = transpose(reshape(repmat(reshape(x,1,[]),nR1,1),[],1));
		x = repmat(x,1,nR2);
	end
	%-------------------------------------------------------------------------%
	function b = checkref(x)
		b = isnumeric(x) || (numel(x) == 1 && x == ':');
	end
	%-------------------------------------------------------------------------%
end
%STATIC METHODS---------------------------------------------------------------%
end
