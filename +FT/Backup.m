function Backup(varargin)

% FT.Backup
%
% Description: back up (tar/gzip) the +ex folder to the 'learn_matlab/_bak' directory
%
% Syntax: ex.Backup([force]=false)
%
% In: 
%       [force] - true to force processing where output exists
%
% Out: 
%
% Updated: 2013-12-18
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

strDirOut = '/mnt/tsestorage/scottie/HNP/fieldtrip_gui';

opt = FT.ParseOpts(varargin,...
    'force' , false ,...
    'all'   , false  ...
    );       

strDirBase = fileparts(fileparts(mfilename('fullpath')));

strDirBak = fullfile(strDirOut,'_bak');

if opt.all
    cNames = {'fieldtrip','+FT'};
else
    cNames = {'+FT'};
    
end
cNameOut = cellfun(@(x) [x '_' strrep(datestr(now,29),'-','') '.tar.gz'],cNames,'uni',false);

cPathOut = cellfun(@(x) fullfile(strDirBak,x),cNameOut,'uni',false);

for k = 1:numel(cPathOut)
    if exist(cPathOut{k},'file')==2 && ~opt.force
        fprintf('%s directory is already backed up!\n',cNames{k});
    else
        system(['rm -rf ' cPathOut{k}]);

        fprintf('backing up +FT directory...\n');
        if system(['cd ' strDirBase '; tar --create --gzip --file=' cNameOut{k}  ' +FT'])
            error('failed to back up %s directory',cNames{k});
        end
        if ~movefile(fullfile(strDirBase,cNameOut{k}),strDirBak)
            error('failed to move tar file to _bak dir');
        end
        fprintf('done!\n');
    end
end
