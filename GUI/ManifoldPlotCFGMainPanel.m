classdef ManifoldPlotCFGMainPanel < handle
    
   properties
        panelhandle;

        subpanel
        mainnode = [];
        eventlistener;
   end
    
    
   methods
       function obj = ManifoldPlotCFGMainPanel(wm , manifoldsplot ,varargin)
           
           windowlabel = ['plotlayout' num2str(manifoldsplot.getDimension()) 'd'];
           parent = wm.demandWindow(windowlabel);
           set(parent, 'CloseRequestFcn' , @(o,e) wm.closeWindow(windowlabel)); %%TOFIX
           
           closefunction = @() wm.closeWindow(windowlabel);
           
           obj.panelhandle = uipanel(parent, 'Unit' , 'Pixel'   , varargin{:});
           

           obj.mainnode = LayoutNode(-1,-1,'vertical');
           
           for i = 1:manifoldsplot.getDimension()
              obj.subpanel{i} =  ManifoldPlotCFGPanel(obj.panelhandle , i , manifoldsplot , @()  obj.regionEntered(manifoldsplot));
              obj.mainnode.addHandle(4,0,obj.subpanel{i}.panelhandle , 'minsize' , [Inf Inf]);
           end
           
           
           
           subnode = LayoutNode(1,0);
           
           subnode.addHandle(0,1,uicontrol(obj.panelhandle,'Style','pushbutton' , 'String' , 'Update',...
               'Callback' , @(o,e) manifoldsplot.redrawPlot() ), 'minsize' , [100 , 50],'margin' , [10 2]);
           obj.mainnode.addNode(subnode);
           
           subnode.addHandle(0,1,uicontrol(obj.panelhandle,'Style','pushbutton' , 'String' , 'OK',...
               'Callback' , @(o,e) obj.ok_call( manifoldsplot ,  closefunction)), 'minsize' , [100 , 50],'margin' , [10 2]);
           obj.mainnode.addNode(subnode);
           
           set(obj.panelhandle,  'ResizeFcn' , @(o,e) obj.doLayout());
           set(obj.panelhandle, 'Units' , 'normalize');
           obj.doLayout();           
           
           set(obj.panelhandle, 'DeleteFcn' , @(o,e) obj.destructor());
           
  

           obj.setRegion( manifoldsplot.getAxesRegion());
           obj.eventlistener = manifoldsplot.addlistener('regionChanged' , @(o,e) obj.regionManipulated(manifoldsplot));
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
          delete(obj);
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
       
       function regionEntered(obj, manifoldsplot)
           manifoldsplot.setAxesRegion(obj.getRegion());
       end
       
       function regionManipulated(obj , manifoldsplot)
          
          region = manifoldsplot.getAxesRegion();
          obj.setRegion(region);
           
       end
       
       function ok_call(obj, manifoldsplot , closefunction)
            manifoldsplot.redrawPlot();
            closefunction();
       end
       

       
       
       
   end
end
