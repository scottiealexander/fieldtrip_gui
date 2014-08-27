function me = Run(params)

% FT.filter.Run
%
% Description: filter data
%
% Syntax: me = FT.filter.Run(params)
%
% In: 
%       params - a struct holding the filtering parameters from the user
%             see 'FT.filter.Gui'
%
% Out:
%       me - an empty matrix if filtering finished with out error, otherwise a
%            MException object caught from the error
%
% Updated: 2014-08-27
% Peter Horak
%
% See also: FT.filter.Gui

global FT_DATA;
me = [];

try
    % Sample and Nyquist frequencies
    fs = FT_DATA.data.fsample;
    fnyq = fs/2;

    % Pick the selected channels from the data
    if strcmpi(params.channel,'all')
        params.channel = FT_DATA.data.label;
    end
    ch = ismember(FT_DATA.data.label,params.channel);
    data = FT_DATA.data.trial{1}(ch,:)';
    
    nSamp = size(data,1); % number of samples
%     filts = {}; % accumulate filters to cascade
    
    % Demean the data before filtering
    means = mean(data,1);
    data = data - ones(nSamp,1)*means;

    % Notch filter to remove line noise
    if ~isempty(params.notchfreq)
        q = 35; % Q-factor
        Ab = 3; % notch level: -(Ab)dB
        
        % Remove the given frequency plus up to three harmonics (sample frequency permitting)
        Wo = [1,2,3,4]*params.notchfreq/fnyq;
        for i = 1:sum(Wo < 1)
            [b,a] = iirnotch(Wo(i),Wo(i)/q,Ab);
            data = filtfilt(b,a,data);
%             filts{end+1} = dfilt.df2t(b,a);
        end
    end

    % Format frequencies to be input to the filter design function
    Wn = [params.hpfreq,params.lpfreq]/fnyq;
    type = 'none';
    
    % Other filter (low- high- stop- or band-pass)
    if ~isempty(Wn)
        % Determine filter type based on given hpfreq and lpfreq
        if ~isempty(params.lpfreq) && ~isempty(params.hpfreq)
            if params.hpfreq > params.lpfreq
                Wn = Wn([2,1]);
                type = 'stop';
            else
                type = 'bandpass';
            end
        elseif ~isempty(params.lpfreq)
            type = 'low';
        elseif ~isempty(params.hpfreq)
            type = 'high';
        end

        % Set the filter order and design based on given filter type
        switch (params.filttype)
            case 'butterworth'
                N = 8; % filter order
                filtfun = @(N,Wn,type) butter(N,Wn,type);
            case 'chebyshev'
                N = 8; % filter order
                filtfun = @(N,Wn,type) cheby1(N,0.5,Wn,type);
            case 'fir'
                N = 3*fix(fs);%3*fix(fs/min(Wn)); % filter order
                if (N > floor((nSamp-1)/30)) % /3
                    N = floor(nSamp/30)-1; % /3
                end
                if (rem(N,2) == 1)
                    N = N + 1;
                end
                filtfun = @(N,Wn,type) fir1(N,Wn,type);
            otherwise
                return; % should never happend
        end

        % Reduce the filter order until it becomes stable
        while (1)
            [b,a] = filtfun(N,Wn,type); % filter coefficients
            if any(abs(roots(a)) >= 1)
                if N == 1 % return
                    error('Calculated filter coefficients have poles outside the unit circle even with a filter order of 1.');
                else % continue
                    warning('Calculated filter coefficients have poles outside the unit circle. Reducing filter order from %d to %d.',N,N-1);
                    N = N - 1;
                end
            else break;
            end
        end
        
        % Apply the filter
        data = filtfilt(b,a,data);
%         filts{end+1} = dfilt.df2t(b,a);
    end
    
    % Add the mean back to the data (if it was not high-pass filtered)
    if ~any(strcmpi(type,{'high','bandpass'}))
        data = data + ones(nSamp,1)*means;
    end
    
%     % Visualize the filter before deciding to save the result
%     Hcas = dfilt.cascade(filts{:});
%     Hcas.freqz(512,fs);
%     resp = FT.UserInput('Apply Filter?',1,'button',{'Apply','Cancel'},'title','Apply Filter');
%     if ~strcmpi(resp,'apply'), return, end;

    % Write the filtered data into FT_DATA
    FT_DATA.data.trial{1}(ch,:) = data';
catch me
end

%mark data as not saved
FT_DATA.saved = false;

%update the history
FT.tools.AddHistory('filter',params);
FT_DATA.done.filter = isempty(me);

end