function [kL,cL] = GetAxLabels(v,n)

% GetvLabels
%
% Description: construct a cell of tick labels from a vector representing the
%              axes bin centers
%
% Syntax: cL = GetAxLabels(v,n)
%
% In:
%       v - a vector representing axes bin centers
%       n - the number of bins in 'v' to label (i.e the number of tick labels)
% Out:
%       kL - the tick locations
%       cL - a cell of strings representing the tick labels
%
% Updated: 2013-12-17
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

step = RoundN((abs(v(1))+abs(v(end)))/n,-1);

% if v(1) < 0 && v(end) > 0     
%     tmp = 0:-step:v(1);
%     cL = 0:step:v(end);
%     cL = [tmp(end:-1:1) cL(2:end)];       
% else
    kL = v(1):step:v(end);
% end

cL = arrayfun(@num2str,kL,'uni',false);

%------------------------------------------------------------------------------%
function x = RoundN(x,n)
    n = 10^(-n);
    x = round(x*n)/n;
end
%------------------------------------------------------------------------------%
end