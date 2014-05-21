function pos = GetAxPosition(h,n,varargin)

% GetAxPosition
%
% Description: calculate axes position for a 'row' of axes within the same
%              figure
%
% Syntax: pos = GetAxPosition(h,n,<options>)
%
% In: 
%       h - *EITHER* the handle to the figure in which the axes will appear *OR*
%           a 1x4 position vector specifying the position of the figure as:
%           [left,bottom,width,height] in *PIXELS*
%       n - the number of axes that will appear in the figure at once
%   options:
%       pad   - (75) the padding width in pixels
%       h_pad - (<pad>) the horizontal padding width in pixels
%       v_pad - (<pad>) the vertical padding width in pixels
%
% Out:
%       pos - a 'n' length cell of position vectors (in normalized figure units)
%             one for each axes ordered left-to-right
%
% Updated: 2014-01-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = FT.ParseOpts(varargin,...
    'pad'   , 75 ,...
    'h_pad' , [] ,...
    'v_pad' , []  ...
    );

%allow user to only set the pad option
opt.h_pad = Ternary(isempty(opt.h_pad),opt.pad,opt.h_pad);
opt.v_pad = Ternary(isempty(opt.h_pad),opt.pad,opt.v_pad);

%get the position of the figure in pixels
if ishandle(h) && strcmpi(get(h,'Type'),'figure')
    units = get(h,'Units');
    set(h,'Units','pixels');
    pFig = get(h,'Position');
    set(h,'Units',units);
elseif isnumeric(h) && numel(h) == 4 && all(h > 1)
    pFig = h;
else
    error('Invalid input: first input MUST be either the handle to a figure or the figures position in pixels');
end

l_pad = opt.h_pad/pFig(3);
b_pad = opt.v_pad/pFig(4);
pad_total = l_pad*(n+1);
w_ax = (1-pad_total)/n;
pos = cell(n,1);
left = l_pad;
for kP = 1:n
    pos{kP} = [left b_pad w_ax 1-(b_pad*2)];
    left = left+w_ax+l_pad;
end

end