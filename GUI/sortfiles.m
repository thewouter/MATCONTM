function files = sortfiles(files)

for i = 1:length(files)
    for j = (i-1):-1:1 
        if (files(j).datenum > files(j+1).datenum)
            tmp = files(j);
            files(j) = files(j+1);
            files(j+1) = tmp;
        end
        
    end
end

end