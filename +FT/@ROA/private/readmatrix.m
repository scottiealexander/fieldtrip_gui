% readmatrix
%
% Description: reads binary data element-by-element into a double matrix
%
% Syntax: x = readmatrix(path_file,idx,bytes)
%
% In:
% 	path_file - the path to a binary file as a string
% 	idx       - a N-length vector of indicies to read
% 	bytes     - the number of bytes-per-element of the datatype contained in
% 				path_file
% Out:
% 	x - a N-length vector of doubles
%
% Updated: 2014-04-21
% Scottie Alexander
%
% Please send bug reports to: scottiealexander11@gmail.com

strPathMx = fullfile(fileparts(mfilename('fullpath')),['readmatrix.' mexext]);

fprintf(2,'*** ERROR ***\n');
fprintf(2,'In place of the MEX file %s\nthis file (%s) was executed!\n',strPathMx,mfilename('fullpath'));
fprintf(2,'This likely means that the MEX file is missing or corrupted!\n');
error('See message above...');