function Edit()
% FT.template.Edit
%
% Description: view (and remove) steps in the current template
%
% Updated: 2014-10-13
% Peter Horak

global FT_DATA;

if isempty(FT_DATA.template) || isempty(FT_DATA.path.template)
     FT.UserInput('No loaded template to view!',1,'title','Notice','button',{'OK'});
     return;
end

% Only list the operation in each step (don't show the parameters)
cOps = cellfun(@(x) x.operation,FT_DATA.template,'uni',false);
nOps = numel(cOps);
nums = regexprep(num2str(1:nOps),' *','\n');

c = {{'text','string','#'},{'text','string','Operation'};...
     {'text','string',nums},{'text','string',strjoin(cOps,'\n')};...
     {'text','string','Keep:'},...
     {'edit','string',num2str(nOps),'tag','nKeep','valfun',{'inrange',1,nOps,true}};...
     {'pushbutton','string','OK','validate',true},...
	 {'pushbutton','string','Cancel','validate',false}...
    };

win = FT.tools.Win(c,'title','Edit Template','grid',false,'focus','nKeep');
win.Wait;

% Crop the operations down to the number indicated to keep
if strcmpi(win.res.btn,'ok')
    FT_DATA.template = FT_DATA.template(1:win.res.nKeep);
end

end