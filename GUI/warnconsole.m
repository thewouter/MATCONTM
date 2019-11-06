function warnconsole(varargin)
global sOutput

    if (~isempty(sOutput)) && ~isempty(sOutput.outputhandle) 
        s = ['Warning: ' deblank(sprintf(varargin{:})) ];
        fprintf(s);
        ss = get(sOutput.outputhandle, 'String');
        set( sOutput.outputhandle , 'String' ,   [ss ; s] , 'ListboxTop' , length(ss));
    else
        s = ['Warning: ' deblank(sprintf(varargin{:})) ];
        fprintf(s);
        warning(s);
    end
end

