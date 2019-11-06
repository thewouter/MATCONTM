function str = cutpath(str)
i = length(str);

while ((i > 0) && ((str(i) ~= '/') && (str(i) ~= '\')))
    str(i) = [];
    i = i-1;
end
if (i > 0)
   str(i) = []; 
end