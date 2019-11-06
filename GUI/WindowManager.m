classdef WindowManager < handle
    %WINDOWMANAGER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        windows = struct();
        
        allowfunctions = struct();
        allowvals = struct();
        mainwindow = [];
        
        eventlistener
        
        sessiondata;
    end
    
    events
       windowChanged 
    end
    
    
    methods
        function obj = WindowManager(session , sessiondata)
           obj.sessiondata = sessiondata;
            
           obj.initWindowData()
           
           obj.windows.numeric = [];
           obj.allowfunctions.numeric = @() session.numericAllowed();
           obj.allowvals.numeric  = -1;
           
           obj.windows.starter = [];
           obj.allowfunctions.starter= @() session.starterAllowed();
           obj.allowvals.starter  = -1;
           
           obj.windows.continuer = [];
           obj.allowfunctions.continuer = @() session.continuerAllowed();
           obj.allowvals.continuer  = -1;
           
           
           obj.windows.monitor = [];
           obj.allowfunctions.monitor = @() 1;  
           obj.allowvals.monitor = -1;          

           obj.windows.browser = [];
           obj.allowfunctions.browser = @() 1;  
           obj.allowvals.browser = -1;                 
          
           obj.windows.browser2 = [];
           obj.allowfunctions.browser2 = @() 1;  
           obj.allowvals.browser2 = -1;                 
           
	   obj.windows.console = [];
           obj.allowfunctions.console = @() 1;  
           obj.allowvals.console = -1;    
           
           obj.windows.plotlayout2d = [];
           obj.allowfunctions.plotlayout2d = @() 1;  
           obj.allowvals.plotlayout2d = -1;
           
           obj.windows.plotlayout3d = [];
           obj.allowfunctions.plotlayout3d = @() 1;  
           obj.allowvals.plotlayout3d = -1;           
           
           obj.windows.diagramorganizer = [];
           obj.allowfunctions.diagramorganizer = @() ~isempty(session.system);  
           obj.allowvals.diagramorganizer = -1;           

           obj.windows.computemanifolds = [];
           obj.allowfunctions.computemanifolds =  @() session.starterAllowed();
           obj.allowvals.computemanifolds = -1;            
           
           obj.windows.managemanifolds = [];
           obj.allowfunctions.managemanifolds =  @() 1;
           obj.allowvals.managemanifolds = -1;            
           
           
           obj.windows.coloropt  = [];
           obj.allowfunctions.coloropt  =  @() 1;
           obj.allowvals.coloropt  = -1;             
           
           obj.mainwindow = [];
           
           obj.eventlistener = session.addlistener('stateChanged' , @(o,e) obj.sessionStateChanged());
        end
        
        function bool = isWindowOpenable(obj, tag)
                bool = (isempty(obj.windows.(tag)) && feval(obj.allowfunctions.(tag)));
        end
        function bool = isWindowOpen(obj, tag)
                bool = ~isempty(obj.windows.(tag));
        end       
        
        function closeWindow(obj,tag)
            obj.updateWindowData(tag);
            
            % HACKFIX 
            if (~isempty(obj.windows.(tag)))
                h = uicontrol( obj.windows.(tag) , 'Visible' , 'on' , 'Style' , 'edit' , 'Position' , [10000 10000 1 1]);
                uicontrol(h);
                drawnow;
            end
            
            delete(obj.windows.(tag));
            obj.windows.(tag) = [];
            obj.notify('windowChanged');
        end
      

        function window = createWindow(obj,tag)
           %conditie verdwenen FIXME
           window = figure('Visible' , 'off' , 'NumberTitle' , 'off' , 'Name' , WindowManager.getName(tag),'MenuBar' , 'none' );
           set(window,'CloseRequestFcn', @(src,ev) closeSubwindow( obj , tag ) , 'DeleteFcn' , @(src,ev) deleteWindow(src,ev)); 
           
           
           obj.windows.(tag) = window;
           obj.setWindowData(tag, window);
           obj.notify('windowChanged');
           
        end
        
        
        function window = demandWindow(obj,tag)
           if (~isempty(obj.windows.(tag)))
               delete(obj.windows.(tag));  %!! delete !!
           end
            
           window = figure('Visible' , 'off' , 'NumberTitle' , 'off' , 'Name' , WindowManager.getName(tag),'MenuBar' , 'none' );
           obj.setWindowData(tag, window);
           set(window,'CloseRequestFcn', @(src,ev) closeSubwindow( obj , tag )); 
           
           obj.windows.(tag) = window;
           obj.notify('windowChanged');            
        end
        
        
        function window = createMainWindow(obj)
            obj.mainwindow = figure('Visible', 'off' , 'NumberTitle' , 'off', 'MenuBar' , 'none' , ...
                'Name' , 'MatContM GUI','CloseRequestFcn', @(src,ev) closeMainwindow( obj) );

            obj.setWindowData('main' , obj.mainwindow);
            
            obj.notify('windowChanged');
            window = obj.mainwindow;
        end
        
        
        function closeSubWindows(obj)
            windowtags = fieldnames(obj.windows);
            for i = 1:length(windowtags)
          %     if (isWindowOpen(windowtags{i}))
                   closeWindow(obj , windowtags{i} );
          %     end
            end
            obj.notify('windowChanged');
            
        end
        function closeAllWindows(obj)
           set(obj.mainwindow, 'Visible' , 'off');
           drawnow;
            obj.closeSubWindows();
           
           obj.sessiondata.data.windowpos.main = get(obj.mainwindow , 'Position');
           delete(obj.mainwindow);
           obj.mainwindow = [];
        end
        
        function sessionStateChanged(obj)
            names = fieldnames(obj.windows);
            for i = 1:length(names)
                newval = feval(obj.allowfunctions.(names{i}));
                if(obj.allowvals.(names{i}) ~= newval)
                    obj.allowvals.(names{i}) = newval;
                    if ((~newval) && obj.isWindowOpen(names{i}))
		       printc(mfilename , [ 'window force closed: ' names{i} ]);
                       obj.closeWindow(names{i}); 
                    end
                    obj.notify('windowChanged');
                end 
            end  
            
        end
        
        function handle = getMainHandle(obj)
            handle = obj.mainwindow;
        end
     
        function initWindowData(obj)
            if (isfield(obj.sessiondata.data , 'windowpos' ) && (~isempty(obj.sessiondata.data.windowpos)) )
                %sanity check:
                windowtags = fieldnames(obj.windows);
                for i = 1:length(windowtags)
                    if (~isfield(obj.sessiondata.data.(windowtags{i})) && (~isempty(obj.sessiondata.data.(windowtags{i}))))
                        warning(['sessiondata.data.' windowtags{i} '  not found!']);
                        obj.sessiondata.data.windowpos = [];
                        obj.setDefaultWindowData();
                        return;
                    end
                end
            else
                obj.setDefaultWindowData();
                return;
            end
        end
        function setDefaultWindowData(obj)
            obj.sessiondata.data.windowpos.numeric   =   [ -1000 -1000 300   450];
            obj.sessiondata.data.windowpos.starter   =   [ -1000 -1000 320   530];
            obj.sessiondata.data.windowpos.continuer   =   [ -1000 -1000 380   530];          
            obj.sessiondata.data.windowpos.monitor   =   [ -1000 -1000 380 350];
            obj.sessiondata.data.windowpos.browser   =   [ -1000 -1000 680 400];
            obj.sessiondata.data.windowpos.browser2   =   [ -1000 -1000 680 400];
            obj.sessiondata.data.windowpos.console =  [-1000 -1000 560 420] ;
            obj.sessiondata.data.windowpos.main =  [-1000 -1000 640 270] ;
            obj.sessiondata.data.windowpos.plotlayout2d = [-1000 -1000  400 180] ;
            obj.sessiondata.data.windowpos.plotlayout3d = [-1000 -1000  400 280] ;
            obj.sessiondata.data.windowpos.diagramorganizer = [-1000 -1000  400 370] ;
            obj.sessiondata.data.windowpos.computemanifolds = [-1000 -1000  320   530];
            obj.sessiondata.data.windowpos.managemanifolds = [-1000 -1000  320   530];
            obj.sessiondata.data.windowpos.coloropt   =   [ -1000 -1000 600   450];
        end
        function setWindowData(obj , windowtag , whandle)

            pos = obj.sessiondata.data.windowpos.(windowtag);

            set(whandle , 'Position' , pos);
            if (pos(1) < -100)
                movegui(whandle, 'center');
            else
                movegui(whandle, 'onscreen');
            end
            
        end
        function updateWindowData(obj, windowtag)
            
            whandle = obj.windows.(windowtag);
            if (~isempty(whandle))
                obj.sessiondata.data.windowpos.(windowtag) = get(whandle , 'Position');
            end
        end
        

        
        
    end 
    methods(Static)
        function embed(fighandle, panelhandle)
           pos = get(fighandle, 'Position');
           set(panelhandle ,'Position' ,[0 0 pos(3) pos(4)]);
           set(panelhandle, 'Units' , 'normalize');
        end
        function name = getName( windowtag)
            namestruct = struct('numeric' , 'Numeric' , 'starter' , 'Starter' , 'continuer' ...
                , 'Continuer' , 'browser' , 'Data Browser' , 'browser2' , 'Data Browser'  , 'monitor' , 'Output' , 'plotlayout2d' , 'Layout', 'plotlayout3d' ...
                , 'Layout' , 'diagramorganizer' , 'Organize Diagrams' , 'computemanifolds' , 'Compute Manifolds' , 'managemanifolds' , 'Manage Manifolds' ...
                , 'coloropt' , 'Plot Properties');
            if (isfield(namestruct, windowtag))
                name = namestruct.(windowtag);
            else
                name = windowtag;
            end
        end
    end
end



function closeSubwindow(windowmanager, tag)
        windowmanager.closeWindow(tag);
end

function closeMainwindow(windowmanager)
        windowmanager.closeAllWindows();
end
function deleteWindow(src,ev)
    figure(src); %INPUT BUG FIX
    delete(src);
end
