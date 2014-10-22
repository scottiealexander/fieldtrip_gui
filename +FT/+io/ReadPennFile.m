function ReadPennFile(strPath)
% Comment *****

[base,name,~] = fileparts(strPath);

%% Get data format
samplerate = 400; % defaults: TJ->400, UP->512, BioLogic->256.03
gain = 1; % default for BioLogic
dataformat = 'int16'; % defaults: TJ->int16, Biologic->short

% Load from a file if possible
paramfile = fullfile(base,'params.txt');
if exist(paramfile,'file')
    in=fopen(paramfile,'rt');
    if (in ~= -1)
        f=0;
        % go through the file
        while~isempty(f)
            f=fscanf(in,'%s',1); 
            v = fgetl(in);
            % evaluate strings to get numbers (hopefully)
            if ischar(v) && ismember(f,{'samplerate','gain','dataformat'})
                v = eval(v);
            end
            % set the appropriate parameter to the given value
            switch f
                case 'samplerate'
                    samplerate = v;
                case 'gain'
                    gain = v;
                case 'dataformat'
                    dataformat = v;
            end
        end
        fclose(in);
    end
end

%% Load data
% Find all files sharing the directory with the given file
contents = reshape(dir(base),[],1);

% Only keep files starting with the same name as the given file
filenames = {contents(~[contents.isdir]).name};
filenames = filenames(strncmp(name,filenames,length(name)));

% Only keep files with numeric extensions
[~,~,ext] = cellfun(@(x) fileparts(x),filenames,'uni',false);
ext = cellfun(@(x) x(x~='.'),ext,'uni',false);
bGood = ~isnan(str2double(ext));
ext = ext(bGood);
filenames = filenames(bGood);

% Reconstruct file paths
filepaths = cellfun(@(x) fullfile(base,x),filenames,'uni',false);

% Read data for each channel
data = cell(size(filepaths));
for k = 1:numel(filepaths)
    try
        % read in data (and apply the gain)
        f = fopen(filepaths{k}, 'r','l');
        data{k} = gain*fread(f,Inf,dataformat);
        fclose(f);
    catch
        data{k} = [];
    end
end

% Remove channels that failed to load
bGood = cellfun(@(x) ~isempty(x),data);
ext = ext(bGood);
data = data(bGood);

% Reshape the data as a [chan x time] array
data = cellfun(@(x) reshape(x,1,[]),data,'uni',false);
data = cat(1,data{:});

%% Load electrode labels
% Label channels based on their numbers by default
labels = ext;

% Find the subject's base directory
strDirSubj = fileparts(fileparts(base));
[~,strSubj] = fileparts(strDirSubj);

% Look for a .mat file with electrode labels
strPathLabels = fullfile(strDirSubj,[strSubj '_talLocs_database.mat']);
if exist(strPathLabels,'file')
    load(strPathLabels,'subjTalEvents')
    if exist('subjTalEvents','var')
        chanNums = str2double(labels);
        % get channel numbers and labels from the labels file
        channels = [subjTalEvents.channel];
        tagNames = {subjTalEvents.tagName};
        % relabel channels whose numbers appear in the labels file
        bCommon = arrayfun(@(x) any(x==channels),chanNums);
        inds = arrayfun(@(x) find(x==channels,1,'first'),chanNums(bCommon));
        labels(bCommon) = tagNames(inds);
    end
end

%% Format data to be compatible with fieldtrip
ftdat.hdr = struct;
ftdat.label = labels';
ftdat.fsample = samplerate;
ftdat.trial = {data};
ftdat.time = {(0:1:(size(data,2)-1))/samplerate};
ftdat.sampleinfo = [1 size(data,2)];
ftdat.hdr = struct('Fs',samplerate,'nChans',size(data,1),...
    'label',ftdat.label,'nSamples',size(data,2),'nSamplesPre',0,'nTrials',1);
ftdat.cfg = struct('trackcallinfo','off','feedback','no',...
    'continuous','yes','trackconfig','off','checkconfig','loose',...
    'checksize',100000,'showcallinfo','yes','debug','no',...
    'trackdatainfo','no','trackparaminfo','no','warning',struct(),...
    'trl',[1 size(data,2) 0]);
    
global FT_DATA;
FT_DATA.data = ftdat;

end