classdef WindowLaunchButton < handle
    %WINDOWLAUNCHBUTTON Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
        eventlistener
        
        windowmanager
        launchfunction
        windowtag;
        
    end
    
    methods
        function obj =  WindowLaunchButton(parenthandle , wmanager,  uitype, launchfunction , windowtag , varargin)
            obj.windowmanager = wmanager;
            obj.launchfunction = launchfunction;
            obj.windowtag = windowtag;
            
            if (strcmp(uitype,'uimenu'))
               uiconstructor = @uimenu;
               vars = {'Label' , WindowManager.getName(windowtag)};
            else
                uiconstructor = @uicontrol;
                vars = {'String' , WindowManager.getName(windowtag) , 'Style' , 'pushbutton'};
            end
            
            
            obj.handle = uiconstructor( parenthandle , vars{:} , 'Callback' , @(o,e) obj.launchWindow() , varargin{:} );
            
            set(obj.handle,'DeleteFcn' , @(o,e) obj.destructor());
            obj.eventlistener = obj.windowmanager.addlistener('windowChanged' , @(o,e) obj.windowChanged());
        
            obj.windowChanged();
        end
        
        function launchWindow(obj)
            if (obj.windowmanager.isWindowOpenable( obj.windowtag))
                f = obj.windowmanager.createWindow(obj.windowtag);
                obj.launchfunction(f);
                set(f,'Visible' , 'on');
            end
        end
        
        function windowChanged(obj)
            set( obj.handle , 'Enable' , bool2str(  obj.windowmanager.isWindowOpenable(obj.windowtag) ) );
        end
        
        
        function destructor(obj)
            %D disp(['Destructor: ' mfilename]);
            delete(obj.eventlistener);
            delete(obj);
        end
        
    end
    
end


function result = bool2str( bool)
if  (bool)
    result = 'on';
else
    result = 'off';
end
end

