function Test

% Test
%
% Description: run unit tests on the various operation packages
%
% Syntax: Test
%
% In: 
%
% Out: 
%
% Updated: 2014-06-27
% Peter Horak
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;
if isempty(FT_DATA)
    FT.Prepare;
end

data_file = mfilename('fullpath');
data_file = [regexp(data_file,'.*/\+FT/','match','once') 'sample_data/TEST.set'];

fprintf('%% RESAMPLE, FILTER, REREFERENCE -------------------------- %%\n')
FT_DATA = load(data_file,'-mat');
FT.resample.Test
FT.filter.Test
FT.rereference.Test

fprintf('%% HILBERT PSD -------------------------------------------- %%\n')
FT_DATA = load(data_file,'-mat');
FT.tfd.Test('Hilbert');

fprintf('%% FOURIER PSD -------------------------------------------- %%\n')
FT_DATA = load(data_file,'-mat');
FT.tfd.Test('STFT');

end
