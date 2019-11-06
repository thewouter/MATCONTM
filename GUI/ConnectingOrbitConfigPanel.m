classdef ConnectingOrbitConfigPanel < handle
    
    properties
       panelhandle;
       mainnode;
       eventlistener;
       eventlistener2;

       stable = [];
       unstable = [];
       conorbitcol = ConnectingOrbitCollection({});
       conorbit = [];
       handles = struct();

       
       manifoldcollection;
       startdata;
       session;
    end
    events
        
       settingChanged 
    end
    
    methods
        function str = getManifoldString(obj, stable)
            if (stable)
                if (isempty(obj.startdata.manifolddata.stable))
                   str = '<none>';
                else
                    str = obj.startdata.manifolddata.stable.toString('short');
                end
                
            else
                if (isempty(obj.startdata.manifolddata.unstable))
                    str = '<none>';
                else
                    str = obj.startdata.manifolddata.unstable.toString('short');
                end
                
            end
        end
        function str = getConOrbitString(obj)
                if (isempty(obj.startdata.manifolddata.conorbit))
                    str = '<none>';
                else
                    str = obj.startdata.manifolddata.conorbit.toString();
                end
        end
        
        function setManifold(obj , manifold , stable)
           if (stable)
               if(~ manifold.isStable())
                    errordlg('Please select a stable manifold' , 'Wrong type of manifold');
                    return  
               end
              obj.startdata.manifolddata.stable =  manifold;
              obj.notify('settingChanged');
           else
                if(manifold.isStable())
                    errordlg('Please select an unstable manifold' , 'Wrong type of manifold');
                    return  
               end              
               obj.startdata.manifolddata.unstable = manifold;
               obj.notify('settingChanged');
           end
            
        end
        
        function selectManifold(obj,  session ,  manifoldcollection , stable)
            InspectorManifolds.selectAManifold(session , ManifoldCollectionOverlay(manifoldcollection,stable) , @(mani) obj.setManifold(mani, stable));
        end
        
        
        
        function doLayout(obj , handle)
           pos = get(handle, 'Position');
           if (~isempty(pos)) %empty komt niet voor in dit geval (alleen bij normalized units van parentobject)
                obj.mainnode.makeLayoutHappen( get(handle, 'Position'));
           end            
        end
        
        function obj = ConnectingOrbitConfigPanel(parent, startdata ,  session , manifoldcollection , varargin)
            
            obj.startdata = startdata;
            obj.session = session;
            
            obj.panelhandle = uipanel(parent, 'Unit' , 'Pixel' , 'BackgroundColor' , [0.95 0.95 0.95]  , varargin{:});
            set(obj.panelhandle,'DeleteFcn' , @(o,e) obj.destructor() , 'ResizeFcn' , @(o,e) obj.doLayout(o));

            obj.eventlistener = obj.addlistener('settingChanged' , @(o,e) obj.onSettingChanged());
            obj.eventlistener2 = manifoldcollection.addlistener('settingChanged' , @(o,e) obj.onManifoldCollectionChanged());
            
            obj.manifoldcollection = manifoldcollection;
            data.extentfunction = @() obj.mainnode.getPrefSize();
            data.node = obj.mainnode;
            set(obj.panelhandle , 'UserData' , data);  
            obj.mainnode = LayoutNode(-1 , -1 , 'vertical');
            
            
            editboxsize = [120,20];
            
            subnode = LayoutNode(1,1);
            subsubnode = LayoutNode(1,1);
            subsubnode.addHandle(1,1,uicontrol( obj.panelhandle , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                    'String' ,  'Manifolds computed:' ), 'halign' , 'l', 'minsize' , [Inf,20]);            
                
            subsubnode.addGUIobject(1,1,EditBox( obj.panelhandle , @(x) 0 , @() num2str(manifoldcollection.getNrManifolds()) , manifoldcollection , [] , ... 
                    'Enable' , 'inactive' , 'Units', 'Pixels' , 'BackgroundColor' , [0.90 0.90 0.90]), 'minsize' , editboxsize);
                
            subnode.addNode(subsubnode);
            
            subnode.addHandle(1,1,uicontrol(obj.panelhandle , 'Style' , 'pushbutton' , 'String' , 'Compute Manifolds' , 'Callback' , @(src,ev) computeManifolds(session , manifoldcollection) ) , 'minsize' , [Inf,30]);
            
            obj.mainnode.addNode(subnode);
            
            
            subnode = LayoutNode(1,1);
            subnode.addHandle(1,1,uicontrol( obj.panelhandle , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                    'String' ,  'Unstable Manifold:' ), 'halign' , 'l', 'minsize' , [Inf,20]);
            subsubnode = LayoutNode(1,3);
                
             subsubnode.addGUIobject(1,3, EditBox(obj.panelhandle, @(x) 0 , @() obj.getManifoldString(false) , obj , [] ...
                 , 'Enable' , 'inactive' , 'Units', 'Pixels' , 'BackgroundColor' , [0.90 0.90 0.90] , 'HorizontalAlignment' , 'left') , 'minsize' , [Inf,20]);
                
            obj.handles.viewunstable =  uicontrol( obj.panelhandle , 'Style' , 'pushbutton' , 'Units', 'Pixels' , 'BackgroundColor' , [0.85 0.85 0.85] , 'HorizontalAlignment' , 'left' , ...
                    'String' ,  'view' ,  'Callback' , @(o,e)  manifoldtable.previewPanel(obj.startdata.manifolddata.unstable));
            subsubnode.addHandle(1,1, obj.handles.viewunstable , 'minsize' , [Inf,20]);            
            
            
            obj.handles.selectunstable =  uicontrol( obj.panelhandle , 'Style' , 'pushbutton' , 'Units', 'Pixels' , 'BackgroundColor' , [0.85 0.85 0.85] , 'HorizontalAlignment' , 'left' , ...
                    'String' ,  'select' , 'Callback', @(src,ev) obj.selectManifold(session , manifoldcollection,false) );
                
            subsubnode.addHandle(1,1, obj.handles.selectunstable , 'minsize' , [Inf,20]);
            
                
            subnode.addNode(subsubnode);
            obj.mainnode.addNode(subnode);
            
            
            
            subnode = LayoutNode(1,1);
            subnode.addHandle(1,1,uicontrol( obj.panelhandle , 'Style' , 'text' , 'Units', 'Pixels' , 'BackgroundColor' , [0.95 0.95 0.95] , 'HorizontalAlignment' , 'left' , ...
                    'String' ,  'Stable Manifold:' ), 'halign' , 'l', 'minsize' , [Inf,20]);
            subsubnode = LayoutNode(1,3);
            subsubnode.addGUIobject(1,3, EditBox(obj.panelhandle, @(x) 0 , @() obj.getManifoldString(true) , obj , [] ...
                 , 'Enable' , 'inactive' , 'Units', 'Pixels' , 'BackgroundColor' , [0.90 0.90 0.90] , 'HorizontalAlignment' , 'left') , 'minsize' , [Inf,20]);
           
            obj.handles.viewstable = uicontrol( obj.panelhandle , 'Style' , 'pushbutton' , 'Units', 'Pixels' , 'BackgroundColor' , [0.85 0.85 0.85] , 'HorizontalAlignment' , 'left' , ...
                    'String' ,  'view'  , 'Callback' , @(o,e)  manifoldtable.previewPanel(obj.startdata.manifolddata.stable) );
            subsubnode.addHandle(1,1, obj.handles.viewstable , 'minsize' , [Inf,20]);            
            
            obj.handles.selectstable = uicontrol( obj.panelhandle , 'Style' , 'pushbutton' , 'Units', 'Pixels' , 'BackgroundColor' , [0.85 0.85 0.85] , 'HorizontalAlignment' , 'left' , ...
                    'String' ,  'select' , 'Callback', @(src,ev) obj.selectManifold(session , manifoldcollection,true) );
            subsubnode.addHandle(1,1, obj.handles.selectstable , 'minsize' , [Inf,20]);
            
            subnode.addNode(subsubnode);
            obj.mainnode.addNode(subnode);
            
            subnode = LayoutNode(1,1);
            

            msg = 'Computing intersections between unstable and stable manifold ...';
            donemsg = 'Intersections computed between unstable and stable manifold.';
            
            obj.handles.intersectbutton = uicontrol( obj.panelhandle , 'Style' , 'pushbutton' , 'Units', 'Pixels'  , 'HorizontalAlignment' , 'left' , ...
                    'String' ,  'Compute Intersections', ...
                'Callback' , @(o,e) pleasewaitwindow('Computing intersections' , msg, donemsg, @() obj.computeIntersections()  ) );
            subnode.addHandle(1,1, obj.handles.intersectbutton , 'halign' , 'l');
            subsubnode = LayoutNode(1,2);
            

            subsubnode.addGUIobject(1,3, EditBox( obj.panelhandle , @(x) 0 , @() obj.getConOrbitString() , obj , [] , ...
                'Enable' , 'inactive' , 'Units', 'Pixels' , 'BackgroundColor' , [0.90 0.90 0.90] , 'HorizontalAlignment' , 'left') , 'minsize' , [Inf,20])
                
            
            obj.handles.intersectselectbutton = uicontrol( obj.panelhandle , 'Style' , 'pushbutton' , 'Units', 'Pixels' , 'BackgroundColor' , [0.85 0.85 0.85] , 'HorizontalAlignment' , 'left' , ...
                    'String' ,  'select' , 'Callback' , @(o,e) obj.selectIntersection());
            subsubnode.addHandle(1,1, obj.handles.intersectselectbutton , 'minsize' , [Inf,20]); 
            
            subnode.addNode(subsubnode);
            obj.mainnode.addNode(subnode);
            
            subnode = LayoutNode(1,1);
            subsubnode = LayoutNode(1,4);
            subnode.addNode(subsubnode);
            subsubnode = LayoutNode(1,1);
            obj.handles.plotbutton = uicontrol( obj.panelhandle , 'Style' , 'pushbutton' , 'Units', 'Pixels' , 'BackgroundColor' , [0.85 0.85 0.85] , 'HorizontalAlignment' , 'right' , ...
                    'String' ,  'Plot' , 'Callback' , @(o,e) obj.plotAll());
            subsubnode.addHandle(1,1, obj.handles.plotbutton , 'minsize' , [Inf,20] , 'haligh' , 'r'); 
            subnode.addNode(subsubnode);
            obj.mainnode.addNode(subnode);
            
            

            [~,h] = obj.mainnode.getPrefSize();
            %
            obj.mainnode.setOptions('Add', true, 'sliderthreshold' , [200 h] , 'panel' , obj.panelhandle);           
            
            obj.onSettingChanged();
            obj.mainnode.makeLayoutHappen(get(obj.panelhandle , 'Position'));
            
        end
        
        function plotAll(obj)
            %~isempty(obj.startdata.manifolddata.unstable) || ~isempty(obj.startdata.manifolddata.stable) ||  ~isempty(obj.startdata.manifolddata.conorbit) 
            mp = ManifoldsPlot(obj.session);
            if (~isempty(obj.startdata.manifolddata.unstable))
                mp.addManifold(obj.startdata.manifolddata.unstable);
            end
             if (~isempty(obj.startdata.manifolddata.stable))
                mp.addManifold(obj.startdata.manifolddata.stable);
             end           
            if (~isempty(obj.startdata.manifolddata.conorbit))
               mp.addOrbit( obj.startdata.manifolddata.conorbit );
            end
            mp.setupPlot();
        end
        
        
        function setIntersection(obj , intersection)
           obj.startdata.manifolddata.conorbit = intersection;
           obj.notify('settingChanged');
        end
        
        
        function selectIntersection(obj) 
            global session; %HACK  FIX
            InspectorConOrbits.selectAConOrbit(session , obj.startdata.manifolddata.conorbitcol , @(x) obj.setIntersection(x));
        end
        
        function computeIntersections(obj)
           if (isempty(obj.startdata.manifolddata.stable) || isempty(obj.startdata.manifolddata.unstable))
               return;
           end
           conorbitlist = ConnectingOrbit.findIntersections(obj.startdata.manifolddata.unstable, obj.startdata.manifolddata.stable);
           obj.startdata.manifolddata.conorbitcol.setComputedList(conorbitlist)
           obj.notify('settingChanged');
        end
        
        function destructor(obj)
           delete(obj.mainnode);
           delete(obj.eventlistener);
           delete(obj.eventlistener2);
           delete(obj); 
        end  
            
        function onManifoldCollectionChanged(obj)
           set(obj.handles.selectstable , 'Enable' , bool2str( obj.manifoldcollection.countManifolds(true) > 0 ));
           set(obj.handles.selectunstable , 'Enable' , bool2str( obj.manifoldcollection.countManifolds(false) > 0 ));   
           
           %auto fill in manifolds on creation:  place here  if required.
        end
        
        function onSettingChanged(obj)
           set(obj.handles.viewstable , 'Enable' , bool2str(~isempty(obj.startdata.manifolddata.stable)));
           set(obj.handles.viewunstable , 'Enable' , bool2str(~isempty(obj.startdata.manifolddata.unstable)));
           set(obj.handles.intersectbutton , 'Enable' , bool2str(~isempty(obj.startdata.manifolddata.unstable) && ~isempty(obj.startdata.manifolddata.stable)   ));
           set(obj.handles.plotbutton , 'Enable' ,  bool2str(~isempty(obj.startdata.manifolddata.unstable) || ~isempty(obj.startdata.manifolddata.stable) ||  ~isempty(obj.startdata.manifolddata.conorbit)  ));
        end
end
         
    
end

function computeManifolds(session , manifoldcollection)

mm = ManifoldModel(session, manifoldcollection);
f = session.getWindowManager().demandWindow('computemanifolds');
mp = ManifoldConfigPanel(f , mm);
set(f, 'Visible' , 'on');

end




function result = bool2str( bool)
if  (bool)
    result = 'on';
else
    result = 'off';
end
end
