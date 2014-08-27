function [label,color] = ProcLabel(str,tag,evts)

% FT.events.relabel.ProcLabel
%
% Description: relabel events according to the given parameters
%
% Syntax: FT.events.relabel.ProcLabel
%
% In:   str - event label or name of a file containing an array of event labels (cellstr)
%       tag - value of events for which to apply the label(s)
%
% Out:  label - label(s) as a cellstr (either original label or labels from file)
%       color - RGP color indicating whether:
%           * No label was specified (white)
%           * The input (str) matches a valid label array file (blue)
%           * The input was interpreted as the label itself (green)
%
% Updated: 2014-08-21
% Peter Horak

global FT_DATA;

if isempty(str)
    % No label specified
    label = {'none'};
    color = [1 1 1]; % white
else
    strPath = fullfile(FT_DATA.path.base_directory,[str '.evta']);

    % The given string matches an .evta file in the current base directory
    if exist(strPath,'file') == 2
        % Try to load the file
        err = []; try map = load(strPath,'-mat','evta'); catch err; end

        if isa(err,'MException') || isempty(map) || ~iscellstr(map.evta)
            % Invalid event array file
            label = {str};
            color = [.8 1 .8]; %[1 1 .8]; % yellow
        elseif (length(map.evta) ~= sum(strcmpi(tag,evts))) && (length(map.evta) ~= 1)
            % Length of event array doesn't match the # of event occurances
            label = {str};
            color = [.8 1 .8]; %[1 .8 .8]; % red
        else
            % The given string corresponds to a valid event array file
            label = map.evta;
            color = [.8 1 1]; % blue
        end
    else
        % Given string matches no files and will be used as the label
        label = {str};
        color = [.8 1 .8]; % green
    end
end
end

