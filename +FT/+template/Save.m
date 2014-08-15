function Save()

global FT_DATA;

if ~isempty(FT_DATA.template) && ~isempty(FT_DATA.path.template)
    
    %user selects file
    strPathDef = FT_DATA.path.template;%default
    [strName,strPath] = uiputfile('*.template','Save Template',strPathDef);

    %construct the file path
    if isequal(strName,0) || isequal(strPath,0)
        return %user selected cancel
    else
        strPathOut = fullfile(strPath,strName);
    end

    %save the template
    save(strPathOut,'-struct','FT_DATA','template');
    FT_DATA.path.template = strPathOut;
end

FT.UpdateGUI;
end