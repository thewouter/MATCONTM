classdef PlotConfigMainPanel
    
   properties
        panelhandle;
        %plotconf;
        subpanel
        mainnode = [];
        eventlistener;
   end
    
    
   methods
       function obj = PlotConfigMainPanel(wm ,   plotconf ,varargin)
           windowlabel = ['plotlayout' num2str(plotconf.getDimension()) 'd'];
           parent = wm.demandWindow(windowlabel);
           set(parent, 'CloseRequestFcn' , @(o,e) 0);
           
           closefunction = @() wm.closeWindow(windowlabel);
           
           obj.panelhandle = uipanel(parent, 'Unit' , 'Pixel'   , varargin{:});
           
           mainnode = LayoutNode(-1,-1,'vertical');

           obj.mainnode = mainnode;
           
           for i = 1:plotconf.getDimension()
              obj.subpanel{i} =  PlotConfigPanel(obj.panelhandle , plotconf , i);
              mainnode.addHandle(4,0,obj.subpanel{i}.panelhandle , 'minsize' , [Inf Inf]);
           end
           
           
           
           subnode = LayoutNode(1,0);
           
           subnode.addHandle(0,1,uicontrol(obj.panelhandle,'Style','pushbutton' , 'String' , 'OK',...
               'Callback' , @(o,e) obj.ok_call(plotconf,closefunction)), 'minsize' , [100 , 25],'margin' , [10 2]);
           mainnode.addNode(subnode);
           
           set(obj.panelhandle,  'ResizeFcn' , @(o,e) obj.doLayout());
           set(obj.panelhandle, 'Units' , 'normalize');
           obj.doLayout();           

           obj.eventlistener = plotconf.addlistener('regionChanged' , @(o,e) updateRegion(obj,plotconf));
           
           set(obj.panelhandle, 'DeleteFcn' , @(o,e) obj.destructor());
           
           plotconf.registerMainPanel(obj);
           
           set(parent, 'Visible' , 'on');
       end

       function doLayout(obj)
           units = get(obj.panelhandle, 'Units');
  
           set(obj.panelhandle,'Units', 'Pixels');
           obj.mainnode.makeLayoutHappen( get(obj.panelhandle, 'Position'));
           set(obj.panelhandle,'Units',units);
       end
       function destructor(obj)
          delete(obj.mainnode);
          delete(obj.eventlistener);
       end
       
       function region = getRegion(obj)
          d = length(obj.subpanel);
          region = zeros(1, 2*d);
          for i = 1:d
              [l,r] = obj.subpanel{i}.getRegion();
              region((2*i-1):(2*i)) = [l r];
          end
       end
       
       function setRegion(obj,region)
          d = length(obj.subpanel);
          for i = 1:d
              obj.subpanel{i}.setRegion(region(2*i-1),region(2*i));
          end           
       end
       
       function ok_call(obj,plotconf,closefunction)
            closefunction();
       end

       
       function updateRegion(obj,plotconf)
           d = length(obj.subpanel);
           for i = 1:d
                [l,r] = plotconf.getRegion(i);
                obj.subpanel{i}.setRegion(l,r);
           end
       end
       
   end
end