function str = FormatId(id) 

% FormatId  
%
% Description: format a study or subject id as a string
%
% Syntax: str = FormatId(id) 
%
% In:
%       id - the study/subject id as a number
%
% Out:
%       str - the study/subject id as a properly formatted string
%
% Updated: 2014-10-01
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

%yes... it is that simple...
str = sprintf('%03d',id);