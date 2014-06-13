function ReportError(varargin)

% FT.ReportError
%
% Description: send an error report to the developer
%
% Syntax: FT.ReportError([me]=[])
%
% In:
%       [me] - the MException object raised by the error
%
% Out: 
%
% Updated: 2013-08-08
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com
dbstop if error;
strServer = '';

%get previous email to help user
if ispref('Internet') && ispref('Internet','E_mail')
    lastEmail = getpref('Internet','E_mail');
else
    lastEmail = '';
end

while isempty(strServer)
    %get the users email
    strEmail = FT.UserInput(['Please enter your \bfDartmouth\rm or \bfGoogle\rm email address:\n'...
               '(you will then be asked for your password)'],...
               1,'input',true,'inp_str',lastEmail,'title','Email address needed','wrap',false);

    %get the users password
    strPassword	= passcode;
    
    %parse the email address
    strServer = regexp(strEmail,'dartmouth.edu|gmail.com','match','once');

    switch lower(strServer)
        case 'dartmouth.edu'
            %dartmouth smtp server for outgoing mail: mailhub.dartmouth.edu
            strServer = 'mailhub.dartmouth.edu';
        case 'gmail.com'
            %google server for outgoing mail is: smtp.gmail.com
            strServer = 'smtp.gmail.com';
        otherwise
            strAns = FT.UserInput('Only Google and Dartmouth emails are supported, would you like to enter another email?',0,'button',{'Yes','No'});
            if strcmpi(strAns,'no')
                return;
            else
                strServer = '';
            end
    end
end

%set email preferences
setpref('Internet','E_mail',strEmail);
setpref('Internet','SMTP_Server',strServer);
setpref('Internet','SMTP_Username',strEmail);
setpref('Internet','SMTP_Password',strPassword);

%set matlab's smtp preferences
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth','true');
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
props.setProperty('mail.smtp.socketFactory.port','465');

%maske sure we have something to add to the email
if isempty(varargin) || isempty(varargin{1}) || ~ismember(class(varargin{1}),{'MException','struct'})
    me.message = 'Unknown';
    me.cause   = 'Unknown';
    me.stack   = struct;
else 
    me = varargin{1};
end

%format the message
strMsg = ['FieldTrip Error Report:' 10];
strMsg = [strMsg 'Date: ' datestr(now,29) 10];
strMsg = [strMsg 'Time: ' datestr(now,13) 10 10];
strMsg = [strMsg 'Error: ' 10 me.message 10 10];
strMsg = [strMsg 'Cause: ' 10 FT.Join(me.cause,10) 10 10];
strMsg = [strMsg 'Stack Trace: ' 10 FormatStack(me.stack)];

%send the email -- we really should add log file to this -- %
sendmail('scottiealexander11+ft@gmail.com','FieldTrip Error Report',strMsg);

%reset password!
setpref('Internet','SMTP_Password','********');

%------------------------------------------------------------------------------%
function str = FormatStack(s)
%format the stack structure for emailing
    if ~isempty(fieldnames(s))
        c = cell(numel(s),1);
        for k = 1:numel(s)
            c{k,1} = [s(k).file ' at ' num2str(s(k).line)];
        end
        str = FT.Join(c,10);
    else
        str = 'No stack trace available';
    end
end
%------------------------------------------------------------------------------%
end