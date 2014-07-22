    function ERPImage()

% ERPImage
%
% Description: 
%
% Syntax: ERPImage
%
% In: 
%
% Out: 
%
% Updated: 2013-10-21
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

global FT_DATA;

if ~FT.tools.Validate('ERPImage','done',{'segment_trials'},'todo',{'average'})
    return;
end

cLabel = FT_DATA.data{1}.label;

pFig = GetFigPosition(600,400);
hF = figure('Units','pixels','OuterPosition',pFig,...
            'Name','ERP Image','NumberTitle','off','MenuBar','none',...
            'Color',[1 1 1],'KeyPressFcn',@KeyPress);

FT.PlotCtrl(hF,cLabel,@PlotOne);

%------------------------------------------------------------------------------%
function PlotOne(strChan)
    bChan = strcmpi(cLabel,strChan);
    cD = cellfun(@(x) cellfun(@(y) y(bChan,:),x.trial,'uni',false),FT_DATA.data,'uni',false);
    cD = cellfun(@(x) cat(1,x{:}),cD,'uni',false);

    %smoothing
    f = fspecial('gaussian',[10 10], 2);
    cFilt = cellfun(@(x) imfilter(x,f,'replicate'),cD,'uni',false);
    im_filt = cat(1,cFilt{:});
    
    hA = axes('Parent',hF,'Units','normalized','OuterPosition',[0 0 1 1],...
            'Box','off','LineWidth',2,'Color',[.8 .8 .8]);
    imagesc(im_filt,'Parent',hA);
    
    y = 0;
    for k = 1:numel(cD)
        y = y + size(cD{k},1);
        if k < numel(cD)
            line([0,size(im_filt,2)],[y,y],'Color',[0 0 0],'LineWidth',2,'Parent',hA);
        end
        text(3,y-3,FT_DATA.epoch{k}.name,'FontWeight','bold','Parent',hA);
    end

    time = FT_DATA.data{1}.time{1};
    [kT,xT] = GetAxLabels(time,6);

    if time(1) < 0
       kL = find(time>=0,1,'first');
       line([kL,kL],get(hA,'YLim'),'Color',[1 1 1],'LineWidth',2,'Parent',hA);       
    end
    xkT = arrayfun(@(x) find(time>=x,1,'first'),kT);
    set(hA,'XTick',xkT);
    set(hA,'XTickLabel',xT);

    set(get(hA,'title'),'String',strChan);
    set(get(hA,'xlabel'),'String','Time (sec)');
    set(get(hA,'ylabel'),'String','Trials');    
    
    hB = colorbar('peer',hA);
    set(get(hB,'YLabel'),'Interpreter','tex','String','Amplitude (\muV)');
end
%------------------------------------------------------------------------------%
end