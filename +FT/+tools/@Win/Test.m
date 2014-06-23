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
%		w - an instance of the Win class
%
% Updated: 2014-06-23
% Scottie Alexander
%
% Please send bug reports to: scottiealexander11@gmail.com

c = {{'text','string',['Enter some value here' 10 'please if you may:']},...
	 {'edit','size',5,'string','blah','tag','edit1','valfun',{'inrange',0,255,true}};...
	 {'text','string','Enter some value:'},...
	 {'edit','size',5,'string','','tag','edit2','valfun',{'match','ch\d+',true,'a channel'}};...
	 {'text','string','Check the box:'},...
	 {'checkbox','size',15,'tag','checkbox'};...
	 {'pushbutton','string','Run','Callback',@cb_test},...
	 {'pushbutton','string','Cancel','validate',false}	 ...
	};

w = FT.tools.Win(c,'position',[0 0]);

%-----------------------------------------------------------------------------%
function cb_test(obj,varargin)
    fprintf('Hello world\n');
    w.BtnPush(obj,true);
end
%-----------------------------------------------------------------------------%
end