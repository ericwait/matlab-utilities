function ErrorToWarning(err)
    str = newline;
    for i=length(err.stack):-1:1
        str = sprintf('%s\t%s line %d -->\n',str,err.stack(i).name, err.stack(i).line);
    end
    
    warning('%s\t\t%s\n',str,err.message);
end
