function Update(silent)

% FT.Update
%
% Description: check for toolbox updates
%
% Syntax: FT.Update(silent)
%
% In: 
%
% Out: 
%
% Updated: 2014-05-09
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

[b,out] = system('which git');
gitdir  = fullfile(fileparts(fileparts(mfilename('fullpath'))),'.git');
if ~b && ~isempty(out) && exist(gitdir,'dir')
	DoUpdate;
elseif ~silent
	FT.UserInput('\bfAutomatic updates are not available for you system.\nSorry!',...
				1,'button','Ok');
end

%-----------------------------------------------------------------------------%
function DoUpdate
	x = pwd;
	gitdir = fileparts(gitdir); %make sure we are NOT in the .git directory
	cd(gitdir);
    system('git remote update >> /dev/null');
	[b,local]  = system('git rev-parse master >> /dev/null');
	[b,remote] = system('git rev-parse origin/master >> /dev/null');
	[b,base]   = system('git merge-base master origin/master >> /dev/null');
	cd(x);
	if strcmpi(local,remote)
		%everything is up-to-date		
		if ~silent
			FT.UserInput('\bfToolbox is up-to-date!',1,'button','Ok');
		end		
	elseif strcmpi(local,base)
		fprintf('CHANGES ARE AVAILABLE\n');
		%changes are available
		msg = '\bf[\color{red}UPDATE\color{black}]: An update is available for this toolbox.\nWould you like to install it now?';
		resp = FT.UserInput(msg,1,'title','Update Available','button',{'Yes','No'});
		if strcmpi(resp,'yes')
			cd(gitdir);
			[b,msg] = system('git pull origin master >> /dev/null');
			if b
				cd(x);
				me = MException('VersionMgmt:PullFail',['Toolbox update failed: ' msg]);
				FT.ProcessError(me);
			end
		end
	else		
		me = MException('VersionMgmt:InvalidId','Toolbox versions are inconsistent!');
		FT.ProcessError(me);
	end
end
%-----------------------------------------------------------------------------%
end
