classdef ManifoldPlotCFGPanel
    %PLOTCONFIGPANEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        dimension;
        panelhandle;
        plotconf;
        
        regionLeftHandle
        regionRightHandle
        

        mainnode
        
        dim

        
    end
    
    
    methods
        function obj = ManifoldPlotCFGPanel(parent, dimension , manifoldsplot , notifyRegionUpdated  ,varargin)
            obj.dim = dimension;
            
            obj.panelhandle = uipanel(parent, 'Unit' , 'Pixel' ,'Title' , PlotConfiguration.AXTITLE{dimension}  ,...
                'DeleteFcn' , @(o,e) obj.destructor() , varargin{:});
            
            obj.mainnode = LayoutNode(-1,-1, 'vertical');
            
            
            coordnames = manifoldsplot.getCoordinateList();
            subnode = LayoutNode(1,0);
            node = LayoutNode(0,2);
            popuphandle = uicontrol(obj.panelhandle, 'Style' , 'popupmenu' , 'String' , coordnames ,'Value' , manifoldsplot.getCoordMap(dimension) , 'Callback' , @(o,e) coordSetCallback( o , dimension , manifoldsplot));
            node.addHandle(1,1, popuphandle,'minsize',[120 0]);
           
            
            subnode.addNode(node);
            
            
            subnode.addHandle(0,1,  uicontrol(obj.panelhandle , 'Units', 'Pixels' , 'Style' , 'popupmenu' ...
                , 'string' , {'Coordinates'} , 'Value' ,1    ), 'minsize' , [Inf 20] , 'margin', [5 5]);
            
            obj.mainnode.addNode(subnode);
            subnode = LayoutNode(1,0);
            subnode.addHandle(0,1,uicontrol(obj.panelhandle, 'Units','Pixels', 'Style' , 'text' , 'String' , 'Range:'));
            
            %[l,r] = plotconf.getRegion(obj.dimension);
            l = -400;
            r = 600;
            
            obj.regionLeftHandle = uicontrol(obj.panelhandle, 'Units','Pixels', 'Style'  , 'edit' , 'String' , num2str(l , '%.16g')  , 'Callback' ,@(o,e)  notifyRegionUpdated());
            obj.regionRightHandle = uicontrol(obj.panelhandle, 'Units','Pixels', 'Style'  , 'edit' , 'String', num2str(r,  '%.16g')   , 'Callback' ,@(o,e) notifyRegionUpdated());
            
            subnode.addHandle(0,2,obj.regionLeftHandle, 'minsize' , [Inf 20] , 'margin' , [5,5]);
            subnode.addHandle(0,1,uicontrol(obj.panelhandle,'Units','Pixels', 'Style' , 'text' , 'String' , '...' , 'Fontsize' ,13));
            subnode.addHandle(0,2,obj.regionRightHandle, 'minsize' , [Inf 20], 'margin' , [5,5]);
            
            obj.mainnode.addNode(subnode);
            
            
            
            data.extentfunction = @() obj.getExtent();
            data.node = obj.mainnode;
            set(obj.panelhandle , 'UserData' , data);
            
            
            set(obj.panelhandle, 'ResizeFcn' , @(o,e) obj.doLayout());
            obj.doLayout();
            
        end
        
        
        function [left , right] = getRegion(obj)
            left =  str2double(get(obj.regionLeftHandle, 'String'));
            right=  str2double(get(obj.regionRightHandle, 'String'));

        end
        function setRegion(obj, left, right)
            set( obj.regionLeftHandle, 'String' , num2str(left  , '%.16g'));
            set( obj.regionRightHandle,'String' , num2str(right , '%.16g'));
        end
        
        function destructor(obj)
            delete(obj.mainnode);
        end
        
        function [w,h] = getExtent(obj)
            [w,h] = obj.mainnode.getPrefSize();
            h = h + 20;
            w = w + 4;
        end
        
        
        function doLayout(obj)
            units = get(obj.panelhandle, 'Units');
            
            set(obj.panelhandle,'Units', 'Pixels');
            pos = get(obj.panelhandle, 'Position');
            if ~isempty(pos)
                pos(4) = max(pos(4) - 10,1);
                obj.mainnode.makeLayoutHappen(pos);
            end
            set(obj.panelhandle,'Units',units);
        end
        
    end
    
    
end
function coordSetCallback(handle , dim , manifoldsplot)
    manifoldsplot.setCoordMap(dim , get(handle , 'Value'));
end

