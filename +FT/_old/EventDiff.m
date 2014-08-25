function report =  EventDiff(old,new)
report = cell(1,length(old));
j = 0;
for i = 1:numel(old)
    str = {'','','',''};
    if ~strcmpi(old(i).type,new(i).type)
        str{1} = sprintf('Type: %s => %s\n',old(i).type,new(i).type);
    end
    if old(i).value ~= new(i).value
        str{2} = sprintf('Val : %g => %g\n',old(i).value,new(i).value);
    end
    if old(i).sample ~= new(i).sample
        str{3} = sprintf('Samp: %g => %g\n',old(i).sample,new(i).sample);
    end
    if old(i).duration ~= new(i).duration
        str{4} = sprintf('Dur : %g => %g\n',old(i).duration,new(i).duration);
    end
    if ~all(strcmpi(str,''))
        j = j+1;
        report{j} = sprintf('Event #%d\n%s',i,strjoin(str));
    end
end

report = strjoin(report(1:j),'\n');
end