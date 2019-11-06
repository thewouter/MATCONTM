classdef InspectorPath < handle
    %INSPECTORPATH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        handle
        im        
        eventlistener
        
    end
    properties(Constant)
        NAMELIST = {'System' , 'Diagram' , 'Curve'}; 
        HEIGHT = 20; 
        DEFAUTLWIDTH = 50;
    end
    
    methods
        
        function obj = InspectorPath(parent , imodel,varargin)
           obj.handle = uipanel(parent,'Unit' , 'Pixels' , 'DeleteFcn', @(o,e) obj.destructor()...
           ,varargin{:});
           
           obj.im = imodel;
           
           obj.eventlistener = imodel.addlistener('listChanged' , @(o,e) obj.updatePath());
           obj.constructPath();
        end
        
        
        function updatePath(obj)
            if ~isempty(obj.handle); delete(allchild(obj.handle)); end;
            obj.constructPath();
        end
        
        function constructPath(obj)
            path = obj.im.getPath();
            
            h = uicontrol(obj.handle, 'Unit' , 'Pixels', 'String' , path{1} , 'Callback' , @(o,e) obj.im.goUpTo(1) ...
                ,'BackgroundColor' , 'white' );
            
            left = 1;
            bottom = 1;
            w = setOptimalPosition(h , left , bottom , 8 , obj.HEIGHT);
            left = left + w + 2;
            
            h = uicontrol(obj.handle,'Style' , 'text' ,  'Unit', 'Pixels' , 'String' , '://','BackgroundColor' , [0.95 0.95 0.95] );
            left = left + setOptimalPosition(h , left , 1 , 0 , obj.HEIGHT - 2);
            
            for i = 2:length(path)
                if (i ~= 2)
                    h = uicontrol(obj.handle,'Style' , 'text' ,  'Unit', 'Pixels' , 'String' , '/','BackgroundColor' , [0.95 0.95 0.95] );
                    w = setOptimalPosition(h , left , 1 , 0 , obj.HEIGHT - 2);
                    left = left + w + 1;
                end
                h = uicontrol(obj.handle, 'Unit' , 'Pixels', 'String' , [  obj.NAMELIST{i-1} '; ' path{i}] , 'Callback' , @(o,e) obj.im.goUpTo(i) ...
                    ,'BackgroundColor' , 'white' );
                
                w = setOptimalPosition(h , left , 1 , 50 , obj.HEIGHT);
                left = left + w + 2;
            end

             for i = length(path):length(obj.NAMELIST) 
                 if (i ~= 1)
                     h = uicontrol(obj.handle,'Style' , 'text' ,  'Unit', 'Pixels' , 'String' , '/','BackgroundColor' , [0.95 0.95 0.95] ,'Enable','off');
                     w = setOptimalPosition(h , left , 1 , 0 , obj.HEIGHT - 2);
                     left = left + w + 1;  
                 end
                 h = uicontrol(obj.handle, 'Unit' , 'Pixels', 'String' , [  obj.NAMELIST{i} '; ']  ...
                     ,'BackgroundColor' , 'white' , 'Enable' , 'off' );
                 w = setOptimalPosition(h , left , 1 , 50 , obj.HEIGHT);
                 left = left + w + 2;
             end
            
            
        end
        
        function destructor(obj)
           delete(obj.eventlistener);
           delete(obj);
        end
    end
    
end

function width = setOptimalPosition(handle , left, bottom , defaultwidth , height)
    ext = get(handle, 'Extent');
    width = ext(3) + 5;


    if (width < defaultwidth)
        width = defaultwidth;
    end
    set(handle , 'Position' , [left  bottom  width height]);

end


