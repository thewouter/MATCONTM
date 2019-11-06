classdef InspectorPanel
    %INSPECTORPANEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        panelhandle
    end
    
    methods
        
        function obj = InspectorPanel(parent, showPath , im, varargin)
            
            mainnode = LayoutNode(-1,-1,'vertical');
            
            obj.panelhandle = uipanel(parent, 'Unit' , 'Pixels'  , varargin{:} , 'BackgroundColor' , [0.95 0.95 0.95] ...
                , 'ResizeFcn' , @(o,e) obj.onResize(o,mainnode) , 'DeleteFcn' , @(o,e) delete(mainnode));
            
            
            ipm = InspectorPreviewModel(im.session,im);
            
            if (showPath)
                mainnode.addGUIobject(1,1,   InspectorPath( obj.panelhandle , im ,  ... 
                    'BackgroundColor' , [0.95 0.95 0.95]) , 'halign' , 'l' , 'minsize' , [Inf,20]);
            end
            subnode = LayoutNode(12,1);
            subnode.addGUIobject(1,3,InspectorList( obj.panelhandle , im ,'BackgroundColor' , 'white') , 'minsize' , [Inf,Inf] , 'margin' , [5,2]);
            subnode.addGUIobject(1,5,InspectorPreviewPanel(obj.panelhandle, ipm ) , 'minsize' , [Inf,Inf] , 'margin' , [5,2]);
            mainnode.addNode(subnode);
            mainnode.addGUIobject(1,1,InspectorCommandPanel(obj.panelhandle, im, 'BackgroundColor' , [0.95 0.95 0.95]),'minsize' , [Inf,30]);

            im.addlistener('shutdown' , @(o,e) close(parent) );
            mainnode.makeLayoutHappen( get( obj.panelhandle , 'Position') );

            set(obj.panelhandle, 'Units' , 'normalize');
        end
        
        function onResize(obj,handle,mainnode)
            
            units = get(handle, 'Units');
            set(handle,'Units' , 'Pixels');
            pos = get(handle, 'Position');
            if (~isempty(pos))
                mainnode.makeLayoutHappen( get(handle, 'Position'));
            end
            set(handle,'Units' , units);
        end
        
        
    end
    methods(Static)
        function startWindow(wm , im, varargin)

                f = wm.demandWindow('browser');

                set(f, 'Visible' , 'off'  );  %, 'WindowStyle' , 'modal');
                pos = get(f, 'Position');
                InspectorPanel(f , true , im , 'Position' , [0 0 pos(3) pos(4)] , varargin{:});
                set(f, 'Visible' , 'on');
        end
        function startWindowWoPath(wm  , im, windowlabel ,  varargin)

                f = wm.demandWindow(windowlabel);

                set(f, 'Visible' , 'off'  );  %, 'WindowStyle' , 'modal');
                pos = get(f, 'Position');
                InspectorPanel(f , false , im , 'Position' , [0 0 pos(3) pos(4)] , varargin{:});
                set(f, 'Visible' , 'on');
        end        
    end
    
end

