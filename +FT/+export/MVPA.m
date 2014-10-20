function MVPA()
% FT.export.MVPA
%
% Description: export the current dataset in an MVPA-compatible format.
% This involves flattening the data dimensions (channel, time, frequency)
% into one feature dimension adn combining trials across conditions. It
% exports time-frequency data if available and time-series data otherwise.
%
% Updated: 2014-10-20
% Peter Horak

%% Check stage and select an output file
global FT_DATA;
ds = struct;

if ~FT.tools.Validate('export_MVPA','done',{'segment_trials'},'todo',{'average'})
    return;
end

% Get the filepath the user wants
strPathDef = fullfile(FT_DATA.path.base_directory,'data.mat');
[strName,strPath] = uiputfile('*.mat','Export Data As...',strPathDef);
strPathOut = fullfile(strPath,strName);

%% Convert data to MVPA format
if FT_DATA.done.tfd
    % Data dimensions 
    nCond = numel(FT_DATA.power.data);
    nTrial = cellfun(@(x) size(x,4),FT_DATA.power.data);
    [nFreq,nTime,nChan,~] = size(FT_DATA.power.data{1});
    nFeature = nFreq*nTime*nChan;

    % Samples [nSamp x nFeature]
    samples = cellfun(@(x) reshape(x,1,[],1,size(x,4)),FT_DATA.power.data,'uni',false);
    samples = cellfun(@(x) permute(x,[4,2,1,3]),samples,'uni',false);
    ds.samples = cat(1,samples{:});
    
    % Feature attributes [1 x nFeature]
    freq = mod((1:nFeature)-1,nFreq)+1;
    time = mod(ceil((1:nFeature)/nFreq)-1,nTime)+1;
    chan = ceil((1:nFeature)/(nFreq*nTime));
    ds.fa = struct('chan',chan,'time',time,'freq',freq);
    
    % General attributes
    ds.a.dim.values{1} = reshape(FT_DATA.power.label,1,[]);
    ds.a.dim.values{2} = reshape(FT_DATA.power.time,1,[]);
    ds.a.dim.values{3} = reshape(FT_DATA.power.centers,1,[]);
else
    % Data dimensions
    nCond = numel(FT_DATA.data);
    nTrial= cellfun(@(x) numel(x.trial),FT_DATA.data);
    [nChan,nTime] = size(FT_DATA.data{1}.trial{1});
    nFeature = nChan*nTime;

    % Samples [nSamp x nFeature]
    samples = cellfun(@(x) cellfun(@(y) reshape(y,1,[]),x.trial,'uni',false),FT_DATA.data,'uni',false);
    samples = cat(2,samples{:});
    ds.samples = cat(1,samples{:});

    % Feature attributes [1 x nFeature]
    chan = mod((1:nFeature)-1,nChan)+1;
    time = ceil((1:nFeature)/nChan);
    ds.fa = struct('chan',chan,'time',time);
    
    % General attributes
    ds.a.dim.values{1} = reshape(FT_DATA.data{1}.label,1,[]);
    ds.a.dim.values{2} = reshape(FT_DATA.data{1}.time{1},1,[]);
end

% General attributes
ds.a.dim.labels = reshape(fieldnames(ds.fa),1,[]);
ds.a.vol.dim = cellfun(@(x) numel(x),ds.a.dim.values);

% Sample attributes [nSample x 1]
targets = arrayfun(@(x,y) x*ones(y,1),(1:nCond)',nTrial,'uni',false);
targets = cat(1,targets{:});
chunks = ones(size(targets));
labels = arrayfun(@(x) FT_DATA.epoch{x}.name,targets,'uni',false);
ds.sa.targets = targets;
ds.sa.chunks = chunks;
ds.sa.labels = labels;

%% Save data
% Get info about the variable ds
s = whos('ds');

% If ds is larger than 2GB, need to use MAT file version 7.3
if (s.bytes >= 2^31)
    %version 7.3 is compressed so much slower to read and write, so we only want
    %to do this if we have to
    fprintf('Data is > 2GB in size, using MAT file version 7.3...\n');
    save(strPathOut,'-v7.3','-struct','ds');
else
    fprintf('Data is < 2GB in size, using MAT file version 7.0...\n');
    save(strPathOut,'-struct','ds');
end

end

% ds.samples = [nSamp x nFeature]
% ds.sa.targets = 1:nConditions [nSamp x 1]
% ds.sa.chunks = 1:nBlock or could just be random [nSamp x 1]
% ds.sa.labels = {condition names} [nSamp x 1]
% 
% ds.fa.chan = [1 x nFeature]
% ds.fa.time = [1 x nFeature]
% ds.fa.freq = [1 x nFeature]
% 
% ds.a.dim.labels = {'chan','time','freq'}
% ds.a.dim.values{1} = channel names [1 x nChan]
% ds.a.dim.values{2} = time points [1 x nTime]
% ds.a.dim.values{3} = frequencies [1 x nFreq]
% ds.a.vol.dim = [nChan,nTime,nFreq]


% % Importing from MVPA
% % - Is there any reason to load a set from MVPA? What modifications would
% % it make that we'd want to load? What could we do after loading (only
% % average, save, and plot)?
% % - Lack of epoch will cause issues for +findpeaks and +reject
% if ismember('freq',ds.a.dim.labels)
%     FT_DATA.power.data
%     FT_DATA.power.label
%     FT_DATA.power.time
%     FT_DATA.power.centers
% else
%     FT_DATA.data
%     FT_DATA.data{:}.trial
%     FT_DATA.data{:}.label
%     FT_DATA.data{:}.time
% end
