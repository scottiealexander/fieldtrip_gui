function p = GetFigPosition(self,w,h,varargin)

% GetFigPosition
%
% Description: calculate a position vector in pixels given width and height of
%              the figure
%
% Syntax: p = GetFigPosition(width,height,<options>)
%
% In: 
%       width  - the width of the figure in pixels
%       height - the hight of the figure in pixels
%   options:
%       xoffset - (0) horizontal offset in pixels relative to the center of the
%                     screen (positive moves right, negative moves left)
%       yoffset - (0) vertical offset in pixels relative to the center of the
%                     screen (positive move up, negative moves down)
%       reference - ('center') the reference point for the x and y offsets, 
%                     one of: 'center', 'absolute'
%
% Out: 
%       p - the position of the figure as a 1x4 position vector in the order:
%           [left,bottom,width,height]
%
% Updated: 2014-04-30
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com
persistent SCREEN_SIZE

opt = self.ParseOptions(varargin,...
    'xoffset'   , 0        ,...
    'yoffset'   , 0        ,...
    'reference' , 'center'  ...
    );

%get the size of the screen in pixels
if isempty(SCREEN_SIZE)
    ROOT_UNITS = get(0,'Units');
    set(0,'Units','pixels');
    SCREEN_SIZE = get(0,'ScreenSize');
    set(0,'Units',ROOT_UNITS);
end

if w > SCREEN_SIZE(3)
    w = SCREEN_SIZE(3);
end
if h > SCREEN_SIZE(4)
    h = SCREEN_SIZE(4);    
end

%make the position vector
p = zeros(1,4);
p(1) = (SCREEN_SIZE(3)/2)-(w/2); %left
p(2) = (SCREEN_SIZE(4)/2)-(h/2); %bottom
p(3:4) = [w,h];                  %width and height

switch lower(opt.reference)        
    case 'absolute'
        if opt.xoffset > 0
            p(1) = p(1)-(p(1)-opt.xoffset);
        end
        if opt.yoffset > 0
            p(2) = p(2)-(p(2)-opt.yoffset);
        end
    otherwise %assume center reference
        p(1) = p(1)+opt.xoffset;
        p(2) = p(2)+opt.yoffset;
end

%move the figure left so that it stays onscreen
if p(1) + p(3) > SCREEN_SIZE(3)
    p(1) = p(1) - (p(1)+p(3)-SCREEN_SIZE(3));
end

if p(1) < 1
    p(1) = 1;
end

%move the figure down so that it stays onscreen
if p(2) + p(4) > SCREEN_SIZE(4)
    p(2) = p(2) - (p(2)+p(4)-SCREEN_SIZE(4));
end

if p(2) < 1
    p(2) = 1;
end