function  printc(id,varargin)
global console
%PRINTC Summary of this function goes here
%   Detailed explanation goes here

if  ~isempty(console)
    if (nargin == 0)
       console.print(' ' , '  '); 
    else
        if (etime(clock , console.stamp) > 1)
           console.print(' ', '  '); 
        end
        console.print(id , varargin{:});
        console.stamp = clock;
    end
end



end

