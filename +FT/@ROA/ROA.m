classdef ROA < handle

%NOTE: for reading from an array, a ROA is on average ~.1ms slower per-element than a standard matlab double matrix, that's ~100sec slower for acessing 1,000,000 elements...

%TODO: implement consecutive bytes reading!

%PRIVATE PROPERTIES-----------------------------------------------------------%
properties (Access=private)
	debug = 0;
	data;
	d_size;
	d_class;
	bytes;
	file;
	file_id;
end
%PRIVATE PROPERTIES-----------------------------------------------------------%

%PUBLIC METHODS---------------------------------------------------------------%
methods
	%-------------------------------------------------------------------------%
	function r = ROA(x)		
		r.file 	  = fullfile(fileparts(mfilename('fullpath')),...
						'private',[num2str(randi(1e6,1)) '.dat']);
		r.d_size  = size(x);
		r.d_class = class(x);
		r.bytes   = getfield(whos('x'),'bytes') / numel(x);
		if ~r.debug
			fid  = fopen(r.file,'w');
			if fid < 1
				error('could not open file %s!',r.file);
			end
			count = fwrite(fid,x,r.d_class);
			fclose(fid);
		else
			r.data = x;
		end
	end
	%-------------------------------------------------------------------------%
	function x = subsref(r,s)		
		switch s.type
		case '()'
			% id = tic;
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

			if ~r.debug
				% r.file_id = fopen(r.file,'r');
				% [kIdx,kSort] = sort(kIdx);
				% c = r.groupconsecutive(kIdx);
				% n = numel(c);
				% x = cell(n,1);
				% for k = 1:n					
				% 	x{k} = r.fetch(c{k});					
				% end
				% fclose(r.file_id);
				% r.file_id = [];
				% x = cat(1,x{:});
				% x(kSort) = x;
                x = readmatrix(r.file,kIdx,r.bytes);
			else
				x = r.data(kIdx);
			end			

			%reshape the output so that we get the same answer as what matlab would give
			x = permute(reshape(x,siz),kSiz);
			% fprintf('TOTAL READ TIME = %.3f sec\n',toc(id));
		% case '{}'
		% 	fprintf('[WARNING]: cell reference is not implemented!\n');
		case '.'
			x = r.(s.subs);
		otherwise
			fprintf('[WARNING]: %s reference is not implemented!\n',s.type);
			x = [];
		end
	end
	%-------------------------------------------------------------------------%
	function x = fetch(r,kIdx)
		try
			fseek(r.file_id,(kIdx(1)-1)*r.bytes,-1);
			x = fread(r.file_id,numel(kIdx),r.d_class);
		catch me
			keyboard;
			fprintf('[WARNING]: caught error\n=>\t%s\nin ROA.fetch!\n',me.message);
			x = [];
		end
	end
	%-------------------------------------------------------------------------%
	function delete(r)		
		fid_all = fopen('all');
		if any(fid_all == r.file_id)
			fclose(r.file_id);
		end
		if exist(r.file,'file') == 2
			delete(r.file);
		end
	end
	%-------------------------------------------------------------------------%
end
%PUBLIC METHODS---------------------------------------------------------------%

%STATIC METHODS---------------------------------------------------------------%
methods (Static=true,Access=private)
	%-------------------------------------------------------------------------%
	function x = fill(x,nR1,nR2)
		x = reshape(repmat(reshape(x,1,[]),nR1,1),[],1)';
		x = repmat(x,1,nR2);
	end
	%-------------------------------------------------------------------------%
	function b = checkref(x)
		b = isnumeric(x) || (numel(x) == 1 && x == ':');
	end
	%-------------------------------------------------------------------------%
	function c = groupconsecutive(x)
		x = reshape(x,1,[]);
		c = mat2cell(x,1,diff([0,find(diff(x) ~= 1),length(x)]));
	end
	%-------------------------------------------------------------------------%
end
%STATIC METHODS---------------------------------------------------------------%
end