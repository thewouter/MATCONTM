function  sortedlist = sortCellByFunc(celllist , func ,varargin) 
       [~ , indices] = sort( cellfun(func , celllist) );
       sortedlist = celllist(indices);
       
       
       if (~isempty(varargin))
          sortedlist = fliplr(sortedlist); 
       end
end