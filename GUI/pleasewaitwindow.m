function pleasewaitwindow(title, msg, donemsg, computefunc , varargin)



ff = figure('Visible', 'off' , 'NumberTitle' , 'off', 'MenuBar' , 'none' , 'Name' , title ,'CloseRequestFcn', @(o,e) 0,  'Position' , [0 0 length(msg)*10 40] , varargin{:});
movegui(ff, 'center');

pos = get(ff,'Position');
txt = uicontrol(ff, 'Style' , 'edit' , 'String' , msg , 'Enable' , 'inactive' , 'Position'  , [0 0 pos(3) pos(4)] );

set(ff,'Visible' , 'on');
drawnow;


try 
    computefunc();
    delete(ff);
    helphandle = helpdlg(donemsg, title);
    drawnow;
    
catch error
    warning(error.message)
    delete(ff);
end

%delete(ff);

end