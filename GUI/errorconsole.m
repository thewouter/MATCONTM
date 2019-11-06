function errorconsole(varargin)
global sOutput


s = ['Error: ' sprintf(varargin{:}) ];

if ~isempty(sOutput) && (sOutput.outputhandle)

    fprintf(s);
    ss = get(sOutput.outputhandle, 'String');
    set( sOutput.outputhandle , 'String' ,   [ss ; s] , 'ListboxTop' , length(ss));
else
    fprintf(s)
    error(s);
    
    
end
