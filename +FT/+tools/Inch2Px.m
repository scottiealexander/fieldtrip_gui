function px = inch2px(in)
% FT.tools.inch2px
%
% Description: convert inchecs to pixels
%
% Syntax: px = FT.tools.inch2px(in)
%
% In:
%		in - a size in inches
%
% Out: 
%		px - input value converted to pixels
%
% Updated: 2014-03-31
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

persistent SCREENPXPERINCH;

if isempty(SCREENPXPERINCH)
	SCREENPXPERINCH = get(0,'ScreenPixelsPerInch');
end

px = SCREENPXPERINCH*in;
