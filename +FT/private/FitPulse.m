function r = FitPulse(data,varargin)

% FitPulse
%
% Description: calculate fit b/t cosine pulse model and the first pulse of the
%              event pulse sequence
%
% Syntax: r = FitPulse(data,<options>)
%
% In: 
%       data       - the data segment
%   options:
%       max_width  - (100) the maximum width (in samples) to allow, width greater
%                    than this value will get an 'r' of 0 (see outputs section)
%       neg_thresh - (-200) the initial negative threshold
%       pos_thresh - (100) threshold for first positive peak
%       plot       - (false) true to plot the data vs. model
%
% Out: 
%       r - the correlation coefficient between the data and model
%
% Updated: 2013-08-13
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

opt = FT.ParseOpts(varargin,...
    'max_width' , 100  ,...
    'neg_thresh', 200  ,...
    'pos_thresh', 100  ,...
    'plot'      , false ...
    );

%find the starting and ending indicies of the first cycle of the pulse sequence
kF = find(data<-abs(opt.neg_thresh),1,'first'); %the initial negative deflection from 0
kS = find(data(1:kF)>=0,1,'last'); %find closest preceeding 0 crossing

if isempty(kS)
    r = 0;
    return;
end

[~,kE] = findpeaks(data(kS:end),'minpeakheight',opt.pos_thresh);
kE = kE+(kS-1);

width = kE-kS;
if width <= opt.max_width
    %extract the first complete cycle    
    d = data(kS:kE);    

    %create the cosine model with same ~width and amplitude as the data
    w  = @(t,x)2*pi*x*t; %x = freq. t = time
    tM = linspace(0,width/1000,numel(d)); %follow same time scale/width as the data
    freq = (1000/width)*.75; %only take 3/4 of a cycle as we are modeling until the first positive peak
    model = cos(w(tM,freq)+(pi/2))*max(d); %construct the model

    %compare model with data
    r = corr(reshape(d,[],1),reshape(model,[],1));

    %optional plotting (make it look nice...)
    if opt.plot
        tD = linspace(0,numel(d)/1000,numel(d));
        figure;
        plot(tM,model,'r',tD,d,'b');
        title(['width = ' sprintf('%d',width) '; r = ' sprintf('%.05f',r)],'FontSize',12);
        legend('model','data','location','NorthWest');
        uiwait(gcf);
    end
else
    r = 0;
end
