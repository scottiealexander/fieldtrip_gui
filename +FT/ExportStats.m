function ExportStats(varargin)

% FT.ExportStats
%
% Description: 
%
% Syntax: FT.ExportStats
%
% In: 
%
% Out: 
%
% Updated: 2013-09-08
% Scottie Alexander
%
% Please report bugs to: scottiealexander11@gmail.com

dbstop if error;
global FT_DATA;

if numel(varargin) < 3 || isempty(varargin{3})
	return;
end

type = varargin{3};

if isfield(FT_DATA,'STATS')
	switch lower(type)
		case 'power'
			if all(cellfun(@(x) isfield(x,'power'),FT_DATA.STATS))
                hMsg = FT.UserInput('Writing stats to file',1);
                for kC = 1:numel(FT_DATA.data)
                    strPathOut = fullfile(fileparts(FT_DATA.path.dataset),[FT_DATA.current_dataset '-' FT_DATA.epoch{kC}.name '-power_spec.csv']);
%                     [strName,strDir] = uiputfile({'*.csv','Comma/Tab Seperated Spreadsheet (*.csv)'},'Select Output Path',strPathOut);

                    cLabel = cell(numel(FT_DATA.STATS{kC}.power),1);
                    s.field1 = FT_DATA.data{kC}.label;
                    cLabel{1,1} = 'channel';

                    for k = 1:numel(FT_DATA.STATS{kC}.power)
                        s.(['field' num2str(k+1)]) = reshape(FT_DATA.STATS{kC}.power{k}.data,[],1);
                        cLabel{k+1,1} = FT_DATA.STATS{kC}.power{k}.label;
                    end

                    if ~FT.io.WriteStruct(s,'output',strPathOut,'headers',cLabel)
                        me = MException('WriteStruct:WriteError',['Failed to write file ' strPathOut]);
                        FT.ProcessError(me);
                    else
                        FT_DATA.STATS{kC} = rmfield(FT_DATA.STATS{kC},'power');
                    end
                end
                if ishandle(hMsg)
                    close(hMsg);
                end
			else
				strMsg = ['\bf[\color{red}ERROR\color{black}]: Power spectra has not yet been ',...
				'calculated for this dataset.'];
				FT.UserInput(strMsg,0);
			end
		case 'peak'
% 			strPathOut = fullfile(fileparts(FT_DATA.path.dataset),[FT_DATA.current_dataset '-peak_stats.csv']);
% 			[strName,strDir] = uiputfile({'*.csv','Comma/Tab Seperated Spreadsheet (*.csv)'},'Select Output Path',strPathOut);
            fprintf('This is not done. Finish it!\n');
		otherwise

	end
else
	
end
