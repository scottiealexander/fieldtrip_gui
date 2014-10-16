function ChannelCorr()

% ChannelCorr
%
% Description: 
%
% Syntax: ChannelCorr
%
% In: 
%
% Out: 
%
% Updated: 2013-10-25
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

%make sure we are ready to run
if ~FT.tools.Validate('channel_corr','done',{'segment_trials'},'todo',{'grand_average'})
    return;
end

[kChan,b] = listdlg('ListString',FT_DATA.data{1}.label,'Name','Choose Channels',...
                    'SelectionMode','multiple','ListSize',[180,300]);
                
if b
    if FT_DATA.done.average
        cD = cellfun(@(x) x.avg(kChan,:)',FT_DATA.data,'uni',false);
    else        
        cD = cellfun(@(x) Average(x.trial),FT_DATA.data,'uni',false);
    end
    
    cCor = cellfun(@corr,cD,'uni',false);
    nCond = numel(cCor);
    
    pFig = GetFigPosition(1200,500);
    h = figure('Units','pixels','MenuBar','none','Position',pFig,...
               'NumberTitle','off','Name','Channel Correlations',...
               'KeyPressFcn',@KeyPress);
    
    cPos = GetAxPosition(nCond);
    cor_min = min(cellfun(@(x) min(reshape(x,[],1)),cCor));
    
    hA = NaN(nCond,1);
    for k = 1:nCond
        hA(k) = axes('Parent',h,'Units','normalized','Position',cPos{k});
        image(cCor{k},'CDataMapping','scaled','Parent',hA(k));        
        colormap(hot(64));
        set(hA(k),'CLim',[cor_min 1],'XTick',[],'YTick',[]);
        set(get(hA(k),'Title'),'String',FT_DATA.epoch{k}.name);
    end
    colorbar('EastOutside');
    set(hA(end),'Position',cPos{end});
    cLabel = FT_DATA.data{1}.label(kChan);
    nLabel = numel(cLabel);
    if nLabel < 25
        cellfun(@(x,y) AddLabels(x,y,1:3),cLabel,num2cell(1:nLabel)');
    else        
        nRep = ceil(nLabel/nCond);
        kLabel = (1:nLabel)';
        kAx = repmat((1:nCond)',nRep,1);
        cellfun(@(x,y,z) AddLabels(x,y,z),cLabel,num2cell(kLabel),num2cell(kAx(kLabel)));
    end
end

%------------------------------------------------------------------------------%
function c = Average(c)
    c = reshape(c,1,1,[]);
    c = cat(3,c{:});
    c = mean(c,3);
    c = c(kChan,:)';
end
%------------------------------------------------------------------------------%
function pos = GetAxPosition(n)
    pad = 75/1200;
    pad_total = pad*(n+1);
    w_ax = (1-pad_total)/3;
    pos = cell(n,1);
    left = pad;
    for kP = 1:n
        pos{kP} = [left .2 w_ax .7];
        left = left+w_ax+pad;
    end
end
%------------------------------------------------------------------------------%
function AddLabels(str,n,kAx)
    for kL = kAx
        text(.2,n,str,'Parent',hA(kL),'HorizontalAlignment','right');    
        y = max(get(hA(kL),'YLim'))+.2;
        text(n,y,str,'Parent',hA(kL),'HorizontalAlignment','right',...
                    'Rotation',90);
    end
end
%------------------------------------------------------------------------------%
end