function str = label2tex(str)
    index = strfind(str, '_');
    if (index)
        str = [str(1:index) , '{' , str(index+1:end) , '}' ];
    end

end