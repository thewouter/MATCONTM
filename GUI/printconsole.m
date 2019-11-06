function printconsole(varargin)
global sOutput

if ~isempty(sOutput)
    if  ~isempty(sOutput.outputhandle)
        s = deblank(sprintf(varargin{:}));
        %fprintf(s);
        ss = get(sOutput.outputhandle, 'String');
        set( sOutput.outputhandle , 'String' ,  [ss;s] , 'ListboxTop' , length(ss));

        drawnow;
    else
        s = sprintf(varargin{:});
        sOutput.msgs = {sOutput.msgs{:} ,  s };
    end
else
    fprintf(varargin{:});
    
end

end
