function WriteDataset(strPathOut)

% WriteDataset
%
% Description: write a dataset to file, if dataset is > 2GB data is saved to a 
%              MAT file version 7.3, otherwise version 7.0 is used
%
% Syntax: WriteDataset(strPathOut)
%
% In: 
%       strPathOut - the path to write the data to
%
% Out: 
%
% Updated: 2013-08-14
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%number of bytes in a gigabyte
GB2BYTE = 2^30;

%get info about the FT_DATA struct
s = whos('FT_DATA');

%more than 2GB of data requires MAT file version 7.3
if s.bytes >= GB2BYTE*2
    %version 7.3 is compressed so much slower to read and write, so we only want
    %to do this if we have to
    fprintf('data is > 2GB in size, using MAT file version 7.3...\n');
    save(strPathOut,'-v7.3','-struct','FT_DATA');
else
    fprintf('data is < 2GB in size, using MAT file version 7.0...\n');
    save(strPathOut,'-struct','FT_DATA');
end
