function w = Test(varargin)
% FT.tools.Win.Test
%
% Description: test constructor for Win class
%
% Syntax: w = FT.tools.Win.Test()
%
% In:
%
% Out:
%       w - an instance of the Win class
%
% Updated: 2014-10-09
% Scottie Alexander
%
% Please send bug reports to: scottiealexander11@gmail.com

c = {{'text','string',['Enter some value here' 10 'please if you may:']},...
     {'edit','string','hello world','tag','edit1','valfun',{'inrange',0,255,true}};...
     {'text','string','Enter some value:'},...
     ... %setting len to 6 means gives us 6 chars of visible space (default = 5)
     {'edit','string','','len',6,'tag','edit2','valfun',{'match','ch\d+',false,'a channel or blank'}};...
     {'text','string','Check the box:'},...
     {'checkbox','tag','checkbox','Callback',@checkbox_cb};...
     {'text','string','Please choose an option:'},...
     {'listbox','string',{},'len',5,'tag','list'};...
     {'pushbutton','string','Run','Callback',@cb_test},...
     {'pushbutton','string','Cancel','validate',false}   ...
    };

w = FT.tools.Win(c,'title','Test','position',[0 0],'grid',true,'focus','edit2',varargin{:});
% w.Wait;

%-----------------------------------------------------------------------------%
function checkbox_cb(obj,varargin)
    if get(obj,'Value')
        w.SetElementProp('edit1','valfun',{'inrange',-1,0,true});
        w.SetElementProp('edit2','Enable','off');
    else
        w.SetElementProp('edit1','valfun',{'inrange',0,255,true});
        w.SetElementProp('edit2','Enable','on');
    end
end
%-----------------------------------------------------------------------------%
function cb_test(obj,varargin)
    fprintf('Hello world\n');
    w.BtnPush(obj,true);
end
%-----------------------------------------------------------------------------%
end